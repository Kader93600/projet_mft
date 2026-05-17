"use client";

// =====================================================================
// useTutor — hook React qui pilote une session de chat IA tuteur.
//
// État géré :
//   - conversationId : id de la conv en cours (créée à la 1ère question)
//   - messages       : historique affiché (user + assistant)
//   - streaming      : true pendant que Claude répond
//   - error          : message d'erreur lisible
//
// API :
//   - send(question)  : envoie une question et stream la réponse
//   - loadConv(id)    : recharge l'historique d'une conv existante
//   - reset()         : repart d'une conv neuve (pas de fetch serveur)
//   - stop()          : annule un stream en cours (AbortController)
//
// Le hook consomme l'SSE de /api/tutor/ask :
//   event: chunk → on append au dernier message assistant
//   event: done  → on fige le message_id + citations
//   event: error → on remonte l'erreur, on revert l'optimistic update
// =====================================================================

import { useCallback, useRef, useState } from "react";

export interface TutorCitation {
  chunk_id: string;
  lesson_id: string;
  lesson_title: string;
  module_slug: string;
  module_title: string;
  similarity: number;
  snippet: string;
}

export interface TutorMessage {
  id: string;
  role: "user" | "assistant";
  content: string;
  citations?: TutorCitation[];
  /** Marqueur pour les messages en cours de stream. */
  streaming?: boolean;
}

export interface UseTutorState {
  conversationId: string | null;
  messages: TutorMessage[];
  streaming: boolean;
  error: string | null;
}

export interface UseTutorOptions {
  /** Slug de la formation contextuelle (filtre RAG). */
  formationSlug?: string | null;
}

export function useTutor(opts: UseTutorOptions = {}) {
  const [state, setState] = useState<UseTutorState>({
    conversationId: null,
    messages: [],
    streaming: false,
    error: null,
  });
  const abortRef = useRef<AbortController | null>(null);

  const loadConv = useCallback(async (id: string) => {
    try {
      const res = await fetch(`/api/tutor/conversations/${id}/messages`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const json = (await res.json()) as {
        messages: Array<{
          id: string;
          role: "user" | "assistant";
          content: string;
          citations: TutorCitation[] | null;
        }>;
      };
      setState({
        conversationId: id,
        messages: json.messages.map((m) => ({
          id: m.id,
          role: m.role,
          content: m.content,
          citations: m.citations ?? undefined,
        })),
        streaming: false,
        error: null,
      });
    } catch (e: any) {
      setState((s) => ({ ...s, error: e?.message ?? "load_failed" }));
    }
  }, []);

  const reset = useCallback(() => {
    abortRef.current?.abort();
    setState({
      conversationId: null,
      messages: [],
      streaming: false,
      error: null,
    });
  }, []);

  const stop = useCallback(() => {
    abortRef.current?.abort();
    setState((s) => ({ ...s, streaming: false }));
  }, []);

  const send = useCallback(
    async (question: string) => {
      const trimmed = question.trim();
      if (!trimmed) return;

      // Optimistic : on ajoute le message user + un placeholder assistant
      const userMsg: TutorMessage = {
        id: `local-user-${Date.now()}`,
        role: "user",
        content: trimmed,
      };
      const assistantMsg: TutorMessage = {
        id: `local-assistant-${Date.now()}`,
        role: "assistant",
        content: "",
        streaming: true,
      };
      setState((s) => ({
        ...s,
        messages: [...s.messages, userMsg, assistantMsg],
        streaming: true,
        error: null,
      }));

      const ac = new AbortController();
      abortRef.current = ac;

      try {
        const res = await fetch("/api/tutor/ask", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            conversation_id: state.conversationId,
            question: trimmed,
            formation_slug: opts.formationSlug,
          }),
          signal: ac.signal,
        });

        if (!res.ok) {
          // Lit la réponse JSON pour remonter une raison utile (forbidden,
          // rate_limited, …)
          const err = await res.json().catch(() => ({}));
          throw new Error(
            err.reason || err.error || `HTTP ${res.status}`
          );
        }
        if (!res.body) throw new Error("no_body");

        // Parse l'SSE manuellement (l'API native EventSource ne supporte
        // pas POST)
        const reader = res.body.getReader();
        const decoder = new TextDecoder("utf-8");
        let buffer = "";

        while (true) {
          const { value, done } = await reader.read();
          if (done) break;
          buffer += decoder.decode(value, { stream: true });

          // Découpe par paquets séparés par "\n\n"
          let idx = buffer.indexOf("\n\n");
          while (idx !== -1) {
            const raw = buffer.slice(0, idx);
            buffer = buffer.slice(idx + 2);

            const lines = raw.split("\n");
            let event = "message";
            let data = "";
            for (const line of lines) {
              if (line.startsWith("event:")) event = line.slice(6).trim();
              else if (line.startsWith("data:"))
                data += line.slice(5).trim();
            }
            let parsed: any = null;
            try {
              parsed = JSON.parse(data);
            } catch {
              parsed = data;
            }

            if (event === "chunk" && parsed?.delta) {
              setState((s) => {
                const msgs = [...s.messages];
                const last = msgs[msgs.length - 1];
                if (last?.role === "assistant") {
                  msgs[msgs.length - 1] = {
                    ...last,
                    content: last.content + parsed.delta,
                  };
                }
                return { ...s, messages: msgs };
              });
            } else if (event === "done") {
              setState((s) => {
                const msgs = [...s.messages];
                const last = msgs[msgs.length - 1];
                if (last?.role === "assistant") {
                  msgs[msgs.length - 1] = {
                    ...last,
                    id: parsed?.message_id ?? last.id,
                    citations: parsed?.citations ?? undefined,
                    streaming: false,
                  };
                }
                return {
                  ...s,
                  conversationId:
                    parsed?.conversation_id ?? s.conversationId,
                  messages: msgs,
                  streaming: false,
                };
              });
            } else if (event === "error") {
              throw new Error(parsed?.message || parsed?.error || "stream_error");
            }

            idx = buffer.indexOf("\n\n");
          }
        }
      } catch (e: any) {
        // Si l'utilisateur a stoppé volontairement, on n'affiche pas d'erreur
        const aborted = ac.signal.aborted;
        setState((s) => {
          const msgs = [...s.messages];
          const last = msgs[msgs.length - 1];
          // Si l'assistant n'a rien produit, on retire le placeholder
          if (last?.role === "assistant" && last.content === "") {
            msgs.pop();
          } else if (last?.role === "assistant" && last.streaming) {
            msgs[msgs.length - 1] = { ...last, streaming: false };
          }
          return {
            ...s,
            messages: msgs,
            streaming: false,
            error: aborted ? null : e?.message ?? "send_failed",
          };
        });
      } finally {
        abortRef.current = null;
      }
    },
    [state.conversationId, opts.formationSlug]
  );

  return {
    ...state,
    send,
    stop,
    reset,
    loadConv,
  };
}
