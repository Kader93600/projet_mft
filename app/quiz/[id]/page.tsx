import { notFound } from "next/navigation";
import { getTranslations } from "next-intl/server";
import { createClient } from "@/lib/supabase/server";
import { QuizRunner } from "./quiz-runner";
import {
  resolveFormationFromQuiz,
  resolveFormationIdFromQuiz,
} from "@/lib/formation-resolver";
import type { Tables } from "@/lib/database.types";

// ── Types des lignes lues (dérivés des `select` réels ci-dessous) ────
// Le client Supabase n'est pas câblé sur `Database` (cf. CLAUDE.md) :
// les `data` sont donc `any` et on les annote explicitement ici.

/** `quizzes.select("*")`. `type` / `show_explanations_mode` sont des `text`
 *  en base mais contraints à ces valeurs (contrat partagé avec QuizRunner). */
type QuizRow = Omit<Tables<"quizzes">, "type" | "show_explanations_mode"> & {
  type: "entrainement" | "examen";
  show_explanations_mode: "always" | "after_pass" | "never";
};

/** `questions.select("id, statement, explanation, order, choices(...)")` */
type LegacyQuestionRow = Pick<
  Tables<"questions">,
  "id" | "statement" | "explanation" | "order"
> & {
  choices: Pick<Tables<"choices">, "id" | "label" | "is_correct" | "order">[];
};

/** Forme d'un choix stocké en JSONB dans `question_bank.choices`. */
type BankChoice = {
  id?: string | null;
  label: string;
  is_correct?: boolean | null;
};

/** `question_bank(...)` embarqué dans `quiz_question_bank` */
type BankQuestionRow = Pick<
  Tables<"question_bank">,
  | "id"
  | "type"
  | "statement"
  | "choices"
  | "max_score"
  | "explanation"
  | "annex_pages"
  | "annex_labels"
  | "import_id"
  | "active"
>;

/** `quiz_question_bank.select("display_order, question:question_bank(...)")` */
type BankLinkRow = Pick<Tables<"quiz_question_bank">, "display_order"> & {
  question: BankQuestionRow | null;
};

/** `question_bank.select("id, type, statement, choices, max_score, explanation")` */
type BankDetailRow = Pick<
  Tables<"question_bank">,
  "id" | "type" | "statement" | "choices" | "max_score" | "explanation"
>;

/** Ligne renvoyée par l'RPC `generate_random_exam`. */
type RandomPickRow = { id: string };

/** `question_imports.select("id, pdf_storage_path")` */
type ImportRow = Pick<Tables<"question_imports">, "id" | "pdf_storage_path">;

/** `question_attachments.select(...)` — `kind` est un `text` contraint. */
type AttachmentRow = Omit<
  Pick<
    Tables<"question_attachments">,
    | "id"
    | "question_id"
    | "storage_path"
    | "file_name"
    | "mime_type"
    | "kind"
    | "label"
    | "display_order"
  >,
  "kind"
> & { kind: QuestionAttachment["kind"] };

/** `bank_filters` (JSONB) d'un quiz en mode `random_from_bank`. */
type BankFilters = {
  formation_slug?: string;
  qcm_count?: number;
  qr_count?: number;
  difficulties?: string[] | null;
};

/** Retour de l'RPC `quiz_attempt_state` (contrat partagé avec QuizRunner). */
type AttemptState = {
  allowed: boolean;
  reason: string | null;
  attempts_used: number;
  attempts_max: number | null;
  next_available_at: string | null;
  last_attempt_at: string | null;
};

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

/**
 * Question en cours de construction : porte temporairement les champs bruts
 * (`*_raw`) nécessaires à la résolution des annexes, supprimés avant l'envoi
 * au runner.
 */
type BuildingQuestion = UnifiedQuestion & {
  annex_pages_raw?: number[];
  annex_labels_raw?: string[];
  import_id_raw?: string | null;
};

export default async function QuizPage(props: { params: Promise<{ id: string }> }) {
  const params = await props.params;
  const t = await getTranslations("quiz");
  const supabase = await createClient();
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
  // Client session : RLS scopées réparées (bug récursion corrigé).
  const reader = supabase;

  const { data: quizRow } = await reader
    .from("quizzes")
    .select("*")
    .eq("id", params.id)
    .single();
  const quiz: QuizRow | null = quizRow;
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
    const enrollmentRows: Pick<Tables<"enrollments">, "formation_id">[] =
      enrollments ?? [];
    const enrolledIds = enrollmentRows
      .map((e) => e.formation_id)
      .filter((id): id is string => !!id);
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

  // Sources 1 & 2 récupérées en parallèle (indépendantes) :
  //   1. table historique "questions" (rattachée au quiz)
  //   2. banque de questions (lien via quiz_question_bank)
  const [{ data: legacyQuestions }, { data: bankLinks }] = await Promise.all([
    reader
      .from("questions")
      .select(
        "id, statement, explanation, order, choices(id, label, is_correct, order)"
      )
      .eq("quiz_id", quiz.id)
      .order("order"),
    reader
      .from("quiz_question_bank")
      .select(
        "display_order, question:question_bank(id, type, statement, choices, max_score, explanation, annex_pages, annex_labels, import_id, active)"
      )
      .eq("quiz_id", quiz.id)
      .order("display_order")
      // `overrideTypes` : le client n'étant pas câblé sur `Database`,
      // supabase-js infère l'embed to-one `question_bank` comme un tableau.
      // PostgREST renvoie un objet (FK simple) — override compile-time.
      .overrideTypes<BankLinkRow[], { merge: false }>(),
  ]);

  const legacyRows: LegacyQuestionRow[] = legacyQuestions || [];
  const fromLegacy: BuildingQuestion[] = legacyRows.map((q) => ({
    id: q.id,
    type: "qcm",
    source: "legacy",
    statement: q.statement,
    explanation: q.explanation,
    choices: [...q.choices].sort((a, b) => a.order - b.order),
  }));

  // Note : on récupère `active` pour filtrer les questions désactivées —
  // le reader student est en service_role (bypass RLS), donc la policy
  // qbank_student_read (active=true) ne s'applique pas ; sans ce filtre
  // explicite, une question désactivée mais toujours liée serait servie.
  const bankLinkRows: BankLinkRow[] = bankLinks || [];
  const fromBank: BuildingQuestion[] = bankLinkRows
    .filter(
      (link): link is BankLinkRow & { question: BankQuestionRow } =>
        !!link.question && link.question.active !== false,
    )
    .map((link): BuildingQuestion => {
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
      };
    }
    const choices = ((q.choices as BankChoice[] | null) ?? []).map((c, idx) => ({
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
    };
  });

  const list: BuildingQuestion[] = [...fromLegacy, ...fromBank];

  // Si quiz en mode random et aucune question linkée → tirage à la volée
  if (list.length === 0 && quiz.generation_mode === "random_from_bank") {
    const f = (quiz.bank_filters as BankFilters | null) ?? {};
    // Seed déterministe (user:quiz) → le tirage est STABLE d'un
    // rechargement à l'autre pendant la passation (corrige le bug où
    // recharger la page changeait les questions en cours d'épreuve).
    const examSeed = user ? `${user.id}:${quiz.id}` : null;
    const { data: random } = await supabase.rpc("generate_random_exam", {
      p_formation_slug: f.formation_slug,
      p_qcm_count: f.qcm_count ?? 30,
      p_qr_count: f.qr_count ?? 0,
      p_difficulty: f.difficulties ?? null,
      p_module_ids: null,
      p_seed: examSeed,
    });

    if (random) {
      // Recharge les détails complets (choices, max_score) pour chaque id tiré
      const picks: RandomPickRow[] = random;
      const ids = picks.map((r) => r.id);
      const { data: details } = await reader
        .from("question_bank")
        .select("id, type, statement, choices, max_score, explanation")
        .in("id", ids);

      const detailRows: BankDetailRow[] = details ?? [];
      const byId = new Map(detailRows.map((d) => [d.id, d] as const));
      for (const r of picks) {
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
          const choices = ((d.choices as BankChoice[] | null) ?? []).map(
            (c, idx) => ({
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
  for (const q of list) {
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
    const importRowList: ImportRow[] = importRows ?? [];
    const withPath = importRowList.filter(
      (ir): ir is ImportRow & { pdf_storage_path: string } =>
        !!ir.pdf_storage_path,
    );
    if (withPath.length > 0) {
      // Batch : 1 seul appel storage au lieu de N (createSignedUrls pluriel)
      const { data: signedList } = await supabase.storage
        .from("question-imports")
        .createSignedUrls(
          withPath.map((ir) => ir.pdf_storage_path),
          60 * 60, // 1h
        );
      const urlByPath = new Map(
        (signedList ?? []).map((s) => [s.path, s.signedUrl] as const),
      );
      for (const ir of withPath) {
        const u = urlByPath.get(ir.pdf_storage_path);
        if (u) signedByImport.set(ir.id, u);
      }
    }
  }

  for (const q of list) {
    if (!q.annex_pages_raw || q.annex_pages_raw.length === 0) {
      delete q.annex_pages_raw;
      delete q.annex_labels_raw;
      delete q.import_id_raw;
      continue;
    }
    const signedUrl = q.import_id_raw
      ? signedByImport.get(q.import_id_raw)
      : undefined;
    if (!signedUrl) {
      delete q.annex_pages_raw;
      delete q.annex_labels_raw;
      delete q.import_id_raw;
      continue;
    }
    const labels = q.annex_labels_raw;
    q.annexes = q.annex_pages_raw.map((pageNumber, i) => ({
      pageNumber,
      label: labels?.[i] ?? t("annexPage", { page: pageNumber }),
      signedUrl,
    }));
    delete q.annex_pages_raw;
    delete q.annex_labels_raw;
    delete q.import_id_raw;
  }

  // ── Attachments libres (image/PDF/doc uploadés à la main) ─────────
  // Fetch les attachments des questions de la banque uniquement (les
  // questions legacy n'en ont pas).
  const bankQuestionIds = list
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

    const rows: AttachmentRow[] = attRows ?? [];
    if (rows.length > 0) {
      // Batch : 1 seul appel storage au lieu de N (createSignedUrls pluriel)
      const { data: signedList } = await supabase.storage
        .from("question-attachments")
        .createSignedUrls(
          rows.map((a) => a.storage_path),
          60 * 60,
        );
      const urlByPath = new Map(
        (signedList ?? []).map((s) => [s.path, s.signedUrl] as const),
      );
      for (const a of rows) {
        const signedUrl = urlByPath.get(a.storage_path);
        if (!signedUrl) continue;
        const q = list.find((x) => x.id === a.question_id);
        if (!q) continue;
        if (!q.attachments) q.attachments = [];
        q.attachments.push({
          id: a.id,
          kind: a.kind,
          fileName: a.file_name,
          mimeType: a.mime_type,
          label: a.label,
          signedUrl,
        });
      }
    }
  }

  // attemptState + résolution formation (slug pour l'UI, ID pour le
  // payload INSERT) : 3 lectures indépendantes lancées en parallèle.
  const [{ data: attemptStateRaw }, formationSlug, formationId] =
    await Promise.all([
      supabase.rpc("quiz_attempt_state", { p_quiz_id: quiz.id }),
      resolveFormationFromQuiz(quiz.id),
      resolveFormationIdFromQuiz(quiz.id),
    ]);
  const attemptState: AttemptState | null = attemptStateRaw ?? null;

  // ── QUIZ-03 : en mode examen, ne JAMAIS embarquer les bonnes réponses
  // ni les explications dans le payload client (elles étaient lisibles
  // dans les données de la page → fuite du corrigé pendant l'épreuve).
  // Le scoring est fait côté serveur (server action submitQuizAttempt) ;
  // l'entraînement conserve is_correct pour la correction immédiate et
  // le mode hors-ligne.
  const isExamMode = quiz.type === "examen" || !!quiz.is_mock_exam;
  const clientQuestions: UnifiedQuestion[] = isExamMode
    ? list.map((q) => ({
        ...q,
        explanation: null,
        choices: q.choices.map((c) => ({ ...c, is_correct: false })),
      }))
    : list;

  return (
    <QuizRunner
      quiz={quiz}
      questions={clientQuestions}
      attemptState={attemptState}
      formationSlug={formationSlug}
      formationId={formationId}
    />
  );
}
