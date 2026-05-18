// =====================================================================
// POST /api/tutor/ask
//
// Endpoint principal du chat IA tuteur.
//
//   1. Auth + gate Premium (lib/tutor/access.ts)
//   2. Rate limit (5 messages/min/utilisateur)
//   3. Si conversation_id absent → on en crée une
//   4. Embed la question utilisateur (OpenAI text-embedding-3-small)
//   5. RPC search_lesson_chunks(top 6) sur la formation contextuelle
//   6. Construit le system prompt avec les chunks pertinents
//   7. Stream Claude Sonnet 4 → SSE vers le client
//   8. À la fin : insert message user + assistant + citations + coût
//      + bump quota mensuelle
//
// Format SSE :
//   event: chunk
//   data: { "delta": "...text..." }
//
//   event: done
//   data: { "message_id": "...", "conversation_id": "...", "citations": [...] }
//
//   event: error
//   data: { "error": "..." }
// =====================================================================

import { NextRequest } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { rateLimit } from "@/lib/rate-limit";
import { getTutorAccess } from "@/lib/tutor/access";
import { embedOne } from "@/lib/tutor/embeddings";
import {
  askStream,
  estimateCostCents,
  type ChatMessage,
} from "@/lib/tutor/claude";
import { buildTutorSystem, type RagChunk } from "@/lib/tutor/prompts";
import { checkModeration } from "@/lib/tutor/moderation";
import { getQuotaStatus, buildQuotaExceededMessage } from "@/lib/tutor/quota";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

interface AskBody {
  conversation_id?: string;
  question?: string;
  formation_slug?: string | null;
}

// Encodage SSE — un helper pour ne pas oublier les `\n\n`
function sseEvent(event: string, data: unknown): Uint8Array {
  const payload = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
  return new TextEncoder().encode(payload);
}

export async function POST(req: NextRequest) {
  // ── Feature flag ────────────────────────────────────────────────────
  if (process.env.FEATURE_AI_TUTOR !== "true") {
    return new Response(
      JSON.stringify({ error: "feature_disabled" }),
      { status: 503, headers: { "Content-Type": "application/json" } }
    );
  }

  // ── Auth ────────────────────────────────────────────────────────────
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return new Response(
      JSON.stringify({ error: "unauth" }),
      { status: 401, headers: { "Content-Type": "application/json" } }
    );
  }

  // ── Body ────────────────────────────────────────────────────────────
  let body: AskBody;
  try {
    body = await req.json();
  } catch {
    return new Response(
      JSON.stringify({ error: "invalid_json" }),
      { status: 400, headers: { "Content-Type": "application/json" } }
    );
  }
  const question = (body.question ?? "").trim();
  if (!question || question.length < 3) {
    return new Response(
      JSON.stringify({ error: "question_too_short" }),
      { status: 400, headers: { "Content-Type": "application/json" } }
    );
  }
  if (question.length > 2000) {
    return new Response(
      JSON.stringify({ error: "question_too_long" }),
      { status: 400, headers: { "Content-Type": "application/json" } }
    );
  }

  // ── Gate Premium ────────────────────────────────────────────────────
  const access = await getTutorAccess(body.formation_slug ?? null);
  if (!access.allowed) {
    return new Response(
      JSON.stringify({ error: "forbidden", reason: access.reason }),
      { status: 403, headers: { "Content-Type": "application/json" } }
    );
  }

  // ── Modération pré-prompt (OpenAI Moderations API, gratuite) ─────────
  // Si flaggé : on ne consomme pas Anthropic, on stream une réponse
  // polie directement. Self-harm = traitement empathique avec orientation
  // vers les ressources d'aide humaine.
  const moderation = await checkModeration(question);
  if (moderation.outcome !== "ok") {
    return streamModerationRefusal({
      supabase,
      userId: user.id,
      question,
      formationSlug: body.formation_slug ?? null,
      conversationId: body.conversation_id ?? null,
      moderationOutcome: moderation.outcome,
      flaggedCategories: moderation.flagged_categories,
      refusalMessage: moderation.user_message ?? "Je ne peux pas répondre à ce message.",
    });
  }

  // ── Rate limit (anti-spam court terme) ──────────────────────────────
  // 5 messages/minute par utilisateur.
  const rl = await rateLimit({
    key: `tutor:${user.id}`,
    limit: 5,
    windowSec: 60,
  });
  if (!rl.ok) {
    return new Response(
      JSON.stringify({
        error: "rate_limited",
        retry_after_ms: rl.reset - Date.now(),
      }),
      {
        status: 429,
        headers: {
          "Content-Type": "application/json",
          "Retry-After": String(Math.ceil((rl.reset - Date.now()) / 1000)),
        },
      }
    );
  }

  // ── Quota strict mensuel (200 msg/mois Premium, illimité staff) ─────
  // Admin/trainer = override (access.pack === 'premium' artificiel dans
  // getTutorAccess). On détecte le staff via la requête sur profiles
  // pour ne pas surcharger getTutorAccess.
  const { data: roleData } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  const isStaff =
    roleData?.role === "admin" ||
    roleData?.role === "super_admin" ||
    roleData?.role === "trainer";

  const quota = await getQuotaStatus(user.id, isStaff);
  if (!quota.allowed) {
    return new Response(
      JSON.stringify({
        error: "quota_exceeded",
        message: buildQuotaExceededMessage(quota),
        used: quota.used,
        limit: quota.limit,
        resets_at: quota.resets_at,
      }),
      { status: 429, headers: { "Content-Type": "application/json" } }
    );
  }

  // ── Conversation : crée si nouveau ──────────────────────────────────
  let conversationId = body.conversation_id ?? null;
  if (!conversationId) {
    const { data: conv, error: convErr } = await supabase
      .from("tutor_conversations")
      .insert({
        user_id: user.id,
        title: question.slice(0, 80),
        context_formation_slug: body.formation_slug ?? null,
      })
      .select("id")
      .single();
    if (convErr || !conv) {
      console.error("[tutor/ask] create conv error", convErr);
      return new Response(
        JSON.stringify({ error: "create_conv_failed" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
    conversationId = conv.id;
  } else {
    // Vérifie que la conv appartient au user
    const { data: conv } = await supabase
      .from("tutor_conversations")
      .select("id, user_id")
      .eq("id", conversationId)
      .maybeSingle();
    if (!conv || conv.user_id !== user.id) {
      return new Response(
        JSON.stringify({ error: "conversation_not_found" }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );
    }
  }

  // ── Embed + RAG search ──────────────────────────────────────────────
  let chunks: RagChunk[] = [];
  try {
    const embedding = await embedOne(question);
    const { data: searchResults, error: searchErr } = await supabase.rpc(
      "search_lesson_chunks",
      {
        query_embedding: embedding as unknown as string, // Supabase JS sérialise auto
        match_count: 6,
        formation_filter: body.formation_slug ?? null,
      }
    );
    if (searchErr) {
      console.error("[tutor/ask] search error", searchErr);
    } else {
      chunks = (searchResults ?? []) as RagChunk[];
    }
  } catch (e) {
    console.error("[tutor/ask] embed/search error", e);
    // On continue malgré tout : le prompt sans chunks dira que la
    // base est vide, ce qui est plus utile qu'un 500.
  }

  // ── Historique conv (5 derniers messages) ───────────────────────────
  const { data: history } = await supabase
    .from("tutor_messages")
    .select("role, content, created_at")
    .eq("conversation_id", conversationId)
    .order("created_at", { ascending: false })
    .limit(10);

  const historyMessages: ChatMessage[] = (history ?? [])
    .reverse()
    .filter((m) => m.role === "user" || m.role === "assistant")
    .map((m) => ({
      role: m.role as "user" | "assistant",
      content: m.content,
    }));

  // ── Persiste le message user IMMÉDIATEMENT ──────────────────────────
  // (avant le stream pour qu'il soit visible même si Claude time-out)
  const { error: userMsgErr } = await supabase.from("tutor_messages").insert({
    conversation_id: conversationId,
    role: "user",
    content: question,
  });
  if (userMsgErr) {
    console.error("[tutor/ask] insert user msg error", userMsgErr);
  }

  // ── Stream Claude ───────────────────────────────────────────────────
  const systemPrompt = buildTutorSystem({
    chunks,
    similarityThreshold: 0.65,
  });

  const stream = new ReadableStream<Uint8Array>({
    async start(controller) {
      let finalText = "";
      let inputTokens = 0;
      let outputTokens = 0;
      let cancelled = false;

      try {
        const iter = await askStream({
          system: systemPrompt,
          messages: [
            ...historyMessages,
            { role: "user", content: question },
          ],
          maxTokens: 1024,
          temperature: 0.3,
          signal: req.signal,
          onDone: (m) => {
            inputTokens = m.inputTokens;
            outputTokens = m.outputTokens;
          },
        });

        for await (const delta of iter) {
          if (cancelled) break;
          finalText += delta;
          controller.enqueue(sseEvent("chunk", { delta }));
        }
      } catch (e: any) {
        console.error("[tutor/ask] stream error", e);
        controller.enqueue(
          sseEvent("error", {
            error: "stream_failed",
            message: e?.message ?? "unknown",
          })
        );
        controller.close();
        return;
      }

      // ── Persistance post-stream ───────────────────────────────────
      const citations = chunks
        .filter((c) => c.similarity >= 0.65)
        .map((c) => ({
          chunk_id: c.chunk_id,
          lesson_id: c.lesson_id,
          lesson_title: c.lesson_title,
          module_slug: c.module_slug,
          module_title: c.module_title,
          similarity: c.similarity,
          snippet: c.content.slice(0, 240),
        }));

      const costCents = estimateCostCents(inputTokens, outputTokens);

      const { data: inserted, error: insertErr } = await supabase
        .from("tutor_messages")
        .insert({
          conversation_id: conversationId,
          role: "assistant",
          content: finalText,
          citations,
          tokens_in: inputTokens,
          tokens_out: outputTokens,
          cost_cents: costCents,
          moderation_passed: true,
        })
        .select("id")
        .single();

      if (insertErr) {
        console.error("[tutor/ask] insert assistant msg error", insertErr);
      }

      // Bump le quota mensuel (best-effort)
      await supabase
        .rpc("bump_tutor_quota", {
          p_user: user.id,
          p_messages: 1,
          p_cost_cents: costCents,
        })
        .then(({ error }) => {
          if (error) console.error("[tutor/ask] bump quota error", error);
        });

      controller.enqueue(
        sseEvent("done", {
          message_id: inserted?.id ?? null,
          conversation_id: conversationId,
          citations,
        })
      );
      controller.close();
    },
    cancel() {
      // Le client a fermé la connexion — on laisse Claude finir en
      // arrière-plan (le signal req.signal annule déjà l'appel SDK).
    },
  });

  return new Response(stream, {
    headers: {
      "Content-Type": "text/event-stream; charset=utf-8",
      "Cache-Control": "no-cache, no-transform",
      Connection: "keep-alive",
      "X-Accel-Buffering": "no", // Désactive le buffering Vercel/Nginx
    },
  });
}

// =====================================================================
// Stream une réponse de refus modération sans toucher Anthropic.
//
// La réponse est néanmoins persistée dans tutor_messages avec
// moderation_passed=false pour traçabilité (utile pour audit + détection
// de patterns abusifs).
// =====================================================================
async function streamModerationRefusal(args: {
  supabase: ReturnType<typeof createClient>;
  userId: string;
  question: string;
  formationSlug: string | null;
  conversationId: string | null;
  moderationOutcome: "blocked" | "self_harm";
  flaggedCategories: string[];
  refusalMessage: string;
}): Promise<Response> {
  const {
    supabase,
    userId,
    question,
    formationSlug,
    conversationId: incomingConvId,
    moderationOutcome,
    flaggedCategories,
    refusalMessage,
  } = args;

  // Crée/réutilise la conv (même logique que le flux normal)
  let conversationId = incomingConvId;
  if (!conversationId) {
    const { data: conv } = await supabase
      .from("tutor_conversations")
      .insert({
        user_id: userId,
        title: question.slice(0, 80),
        context_formation_slug: formationSlug,
      })
      .select("id")
      .single();
    conversationId = conv?.id ?? null;
  }

  // Persiste le message user (pour traçabilité)
  if (conversationId) {
    await supabase.from("tutor_messages").insert({
      conversation_id: conversationId,
      role: "user",
      content: question,
    });
  }

  // Stream la réponse de refus en simulant un chunk unique
  const stream = new ReadableStream<Uint8Array>({
    async start(controller) {
      const encoder = new TextEncoder();

      // Envoie le texte complet en 1 chunk SSE (pas de streaming réel)
      controller.enqueue(
        encoder.encode(
          `event: chunk\ndata: ${JSON.stringify({ delta: refusalMessage })}\n\n`
        )
      );

      // Persiste le message assistant avec moderation_passed=false
      if (conversationId) {
        const { data: inserted } = await supabase
          .from("tutor_messages")
          .insert({
            conversation_id: conversationId,
            role: "assistant",
            content: refusalMessage,
            citations: [],
            tokens_in: 0,
            tokens_out: 0,
            cost_cents: 0,
            moderation_passed: false,
          })
          .select("id")
          .single();

        // Log d'audit (visible côté admin pour suivre les patterns)
        console.warn("[tutor/ask] message modéré", {
          user_id: userId,
          conversation_id: conversationId,
          outcome: moderationOutcome,
          categories: flaggedCategories,
        });

        controller.enqueue(
          encoder.encode(
            `event: done\ndata: ${JSON.stringify({
              message_id: inserted?.id ?? null,
              conversation_id: conversationId,
              citations: [],
              moderated: true,
              moderation_outcome: moderationOutcome,
            })}\n\n`
          )
        );
      } else {
        controller.enqueue(
          encoder.encode(
            `event: done\ndata: ${JSON.stringify({
              moderated: true,
              moderation_outcome: moderationOutcome,
            })}\n\n`
          )
        );
      }

      controller.close();
    },
  });

  return new Response(stream, {
    headers: {
      "Content-Type": "text/event-stream; charset=utf-8",
      "Cache-Control": "no-cache, no-transform",
      Connection: "keep-alive",
      "X-Accel-Buffering": "no",
    },
  });
}
