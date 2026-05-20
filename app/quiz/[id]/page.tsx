import { notFound } from "next/navigation";
import { getTranslations } from "next-intl/server";
import { createClient } from "@/lib/supabase/server";
import { QuizRunner } from "./quiz-runner";
import {
  resolveFormationFromQuiz,
  resolveFormationIdFromQuiz,
} from "@/lib/formation-resolver";

interface QuestionAnnex {
  pageNumber: number;
  label: string;
  /** URL signée (Supabase Storage), valide 1h. */
  signedUrl: string;
}

interface QuestionAttachment {
  id: string;
  kind: "image" | "pdf" | "document" | "other";
  fileName: string;
  mimeType: string;
  label: string | null;
  signedUrl: string;
}

interface UnifiedQuestion {
  /** id de la question (table source : "questions" ou "question_bank") */
  id: string;
  /** "qcm" (par défaut, compat ancien runner) ou "qr" (rédigée) */
  type: "qcm" | "qr";
  /** Source pour distinguer comment soumettre la réponse */
  source: "legacy" | "bank";
  statement: string;
  explanation?: string | null;
  /** QCM : choix triés. QR : tableau vide. */
  choices: Array<{
    id: string;
    label: string;
    is_correct: boolean;
    order: number;
  }>;
  /** QR : barème max */
  max_score?: number;
  /** Annexes PDF à afficher à côté de l'énoncé pendant la réponse. */
  annexes?: QuestionAnnex[];
  /** Annexes attachées directement à la question (images, PDF, doc). */
  attachments?: QuestionAttachment[];
}

export default async function QuizPage({ params }: { params: { id: string } }) {
  const t = await getTranslations("quiz");
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Choix du client : students en service_role pour bypass RLS
  let isStaff = false;
  if (user) {
    const { data: meRole } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();
    isStaff =
      meRole?.role === "admin" ||
      meRole?.role === "super_admin" ||
      meRole?.role === "trainer";
  }
  const { createAdminClient } = await import("@/lib/supabase/admin");
  const reader = isStaff || !user ? supabase : createAdminClient();

  const { data: quiz } = await reader
    .from("quizzes")
    .select("*")
    .eq("id", params.id)
    .single();
  if (!quiz) notFound();

  // Gate par formation : ce quiz appartient-il à une formation où
  // l'utilisateur est inscrit ? Sinon, 404. Staff = accès libre.
  //
  // ⚠️ Deux types de rattachement à couvrir (sinon faille d'isolation) :
  //   - quiz lié à un MODULE (quiz.module_id) → via formation_modules
  //   - quiz GLOBAL (examen blanc final, module_id NULL) → via
  //     formation_quizzes. Avant ce fix, les quiz globaux n'étaient
  //     PAS gatés : un stagiaire capacite-3-5t pouvait ouvrir un
  //     examen global GOTRM en devinant son UUID.
  if (user && !isStaff) {
    const { data: enrollments } = await reader
      .from("enrollments")
      .select("formation_id")
      .eq("user_id", user.id)
      .not("formation_id", "is", null)
      .neq("status", "refuse")
      .neq("status", "abandon");
    const enrolledIds = (enrollments ?? [])
      .map((e: any) => e.formation_id as string)
      .filter(Boolean);
    if (enrolledIds.length === 0) notFound();

    if (quiz.module_id) {
      // Quiz rattaché à un module
      const { count } = await reader
        .from("formation_modules")
        .select("module_id", { count: "exact", head: true })
        .eq("module_id", quiz.module_id)
        .in("formation_id", enrolledIds);
      if (!count) notFound();
    } else {
      // Quiz global (examen blanc final) — rattachement direct via
      // formation_quizzes
      const { count } = await reader
        .from("formation_quizzes")
        .select("quiz_id", { count: "exact", head: true })
        .eq("quiz_id", quiz.id)
        .in("formation_id", enrolledIds);
      if (!count) notFound();
    }
  }

  // Source 1 : table historique "questions" (rattachée au quiz)
  const { data: legacyQuestions } = await reader
    .from("questions")
    .select(
      "id, statement, explanation, order, choices(id, label, is_correct, order)"
    )
    .eq("quiz_id", quiz.id)
    .order("order");

  const fromLegacy: UnifiedQuestion[] = (legacyQuestions || []).map(
    (q: any) => ({
      id: q.id,
      type: "qcm",
      source: "legacy",
      statement: q.statement,
      explanation: q.explanation,
      choices: [...q.choices].sort((a: any, b: any) => a.order - b.order),
    })
  );

  // Source 2 : banque de questions (lien via quiz_question_bank)
  // On récupère `active` pour filtrer les questions désactivées : le
  // reader student est en service_role (bypass RLS), donc la policy
  // qbank_student_read (active=true) ne s'applique pas — sans ce filtre
  // explicite, une question désactivée mais toujours liée serait servie.
  const { data: bankLinks } = await reader
    .from("quiz_question_bank")
    .select(
      "display_order, question:question_bank(id, type, statement, choices, max_score, explanation, annex_pages, annex_labels, import_id, active)"
    )
    .eq("quiz_id", quiz.id)
    .order("display_order");

  const fromBank: UnifiedQuestion[] = (bankLinks || [])
    .filter((link: any) => link.question && link.question.active !== false)
    .map((link: any) => {
    const q = link.question;
    if (q.type === "qr") {
      return {
        id: q.id,
        type: "qr",
        source: "bank",
        statement: q.statement,
        explanation: q.explanation ?? null,
        choices: [],
        max_score: q.max_score ?? 4,
        annex_pages_raw: q.annex_pages,
        annex_labels_raw: q.annex_labels,
        import_id_raw: q.import_id,
      } as any;
    }
    const choices = ((q.choices as any[]) ?? []).map((c, idx) => ({
      id: c.id ?? String.fromCharCode(97 + idx),
      label: c.label,
      is_correct: !!c.is_correct,
      order: idx,
    }));
    return {
      id: q.id,
      type: "qcm",
      source: "bank",
      statement: q.statement,
      explanation: q.explanation ?? null,
      choices,
      annex_pages_raw: q.annex_pages,
      annex_labels_raw: q.annex_labels,
      import_id_raw: q.import_id,
    } as any;
  });

  const list = [...fromLegacy, ...fromBank];

  // Si quiz en mode random et aucune question linkée → tirage à la volée
  if (
    list.length === 0 &&
    (quiz as any).generation_mode === "random_from_bank"
  ) {
    const f = (quiz as any).bank_filters ?? {};
    const { data: random } = await supabase.rpc("generate_random_exam", {
      p_formation_slug: f.formation_slug,
      p_qcm_count: f.qcm_count ?? 30,
      p_qr_count: f.qr_count ?? 0,
      p_difficulty: f.difficulties ?? null,
      p_module_ids: null,
    });

    if (random) {
      // Recharge les détails complets (choices, max_score) pour chaque id tiré
      const ids = (random as any[]).map((r) => r.id);
      const { data: details } = await reader
        .from("question_bank")
        .select("id, type, statement, choices, max_score, explanation")
        .in("id", ids);

      const byId = new Map((details ?? []).map((d: any) => [d.id, d]));
      for (const r of random as any[]) {
        const d = byId.get(r.id);
        if (!d) continue;
        if (d.type === "qr") {
          list.push({
            id: d.id,
            type: "qr",
            source: "bank",
            statement: d.statement,
            explanation: d.explanation ?? null,
            choices: [],
            max_score: d.max_score ?? 4,
          });
        } else {
          const choices = ((d.choices as any[]) ?? []).map(
            (c: any, idx: number) => ({
              id: c.id ?? String.fromCharCode(97 + idx),
              label: c.label,
              is_correct: !!c.is_correct,
              order: idx,
            })
          );
          list.push({
            id: d.id,
            type: "qcm",
            source: "bank",
            statement: d.statement,
            explanation: d.explanation ?? null,
            choices,
          });
        }
      }
    }
  }

  // ── Annexes : pour chaque question qui en a, on génère une signed URL
  // vers le PDF source stocké. On regroupe par import_id pour éviter de
  // ré-générer la même URL plusieurs fois.
  const importIds = new Set<string>();
  for (const q of list as any[]) {
    if (q.import_id_raw && q.annex_pages_raw && q.annex_pages_raw.length > 0) {
      importIds.add(q.import_id_raw);
    }
  }
  const signedByImport = new Map<string, string>();
  if (importIds.size > 0) {
    const { data: importRows } = await reader
      .from("question_imports")
      .select("id, pdf_storage_path")
      .in("id", [...importIds]);
    for (const ir of importRows ?? []) {
      if (!ir.pdf_storage_path) continue;
      const { data: signed } = await supabase.storage
        .from("question-imports")
        .createSignedUrl(ir.pdf_storage_path, 60 * 60); // 1h
      if (signed?.signedUrl) {
        signedByImport.set(ir.id, signed.signedUrl);
      }
    }
  }

  for (const q of list as any[]) {
    if (!q.annex_pages_raw || q.annex_pages_raw.length === 0) {
      delete q.annex_pages_raw;
      delete q.annex_labels_raw;
      delete q.import_id_raw;
      continue;
    }
    const signedUrl = signedByImport.get(q.import_id_raw);
    if (!signedUrl) {
      delete q.annex_pages_raw;
      delete q.annex_labels_raw;
      delete q.import_id_raw;
      continue;
    }
    q.annexes = (q.annex_pages_raw as number[]).map(
      (pageNumber: number, i: number) => ({
        pageNumber,
        label: q.annex_labels_raw?.[i] ?? t("annexPage", { page: pageNumber }),
        signedUrl,
      }),
    );
    delete q.annex_pages_raw;
    delete q.annex_labels_raw;
    delete q.import_id_raw;
  }

  // ── Attachments libres (image/PDF/doc uploadés à la main) ─────────
  // Fetch les attachments des questions de la banque uniquement (les
  // questions legacy n'en ont pas).
  const bankQuestionIds = (list as any[])
    .filter((q) => q.source === "bank")
    .map((q) => q.id);
  if (bankQuestionIds.length > 0) {
    const { data: attRows } = await reader
      .from("question_attachments")
      .select(
        "id, question_id, storage_path, file_name, mime_type, kind, label, display_order",
      )
      .in("question_id", bankQuestionIds)
      .order("display_order");

    for (const a of attRows ?? []) {
      const { data: signed } = await supabase.storage
        .from("question-attachments")
        .createSignedUrl(a.storage_path, 60 * 60);
      if (!signed?.signedUrl) continue;
      const q = (list as any[]).find((x) => x.id === a.question_id);
      if (!q) continue;
      if (!q.attachments) q.attachments = [];
      q.attachments.push({
        id: a.id,
        kind: a.kind,
        fileName: a.file_name,
        mimeType: a.mime_type,
        label: a.label,
        signedUrl: signed.signedUrl,
      });
    }
  }

  const { data: attemptState } = await supabase.rpc("quiz_attempt_state", {
    p_quiz_id: quiz.id,
  });

  // Résolution de la formation associée — slug pour l'UI, ID pour le payload INSERT
  const [formationSlug, formationId] = await Promise.all([
    resolveFormationFromQuiz(quiz.id),
    resolveFormationIdFromQuiz(quiz.id),
  ]);

  return (
    <QuizRunner
      quiz={quiz}
      questions={list}
      attemptState={(attemptState as any) ?? null}
      formationSlug={formationSlug}
      formationId={formationId}
    />
  );
}
