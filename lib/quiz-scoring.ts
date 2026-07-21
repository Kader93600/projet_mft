// =====================================================================
// Scoring serveur des quiz (QUIZ-03).
//
// Recharge les bonnes réponses d'un quiz côté serveur et recalcule le
// score QCM à partir des réponses envoyées par le client. Le client ne
// fournit QUE ses choix (question_id → choice_id) : score, percentage,
// passed et status sont dérivés ici et jamais acceptés du navigateur.
//
// Couvre les 3 sources de questions (mêmes règles que app/quiz/[id]/page.tsx) :
//   1. table historique `questions` + `choices`
//   2. banque de questions liée via `quiz_question_bank`
//   3. tirage aléatoire `random_from_bank` : re-généré à l'identique via
//      l'RPC `generate_random_exam` et le seed déterministe `${userId}:${quizId}`
//
// Module serveur uniquement (utilisé par la server action de soumission
// et par /api/quiz/sync-offline). Ne pas importer côté client.
// =====================================================================

import type { SupabaseClient } from "@supabase/supabase-js";
import type { Tables } from "@/lib/database.types";

/** Forme d'un choix stocké en JSONB dans `question_bank.choices`. */
type BankChoice = {
  id?: string | null;
  label?: string;
  is_correct?: boolean | null;
};

/** `questions.select("id, choices(id, is_correct)")` */
type LegacyScoringRow = Pick<Tables<"questions">, "id"> & {
  choices: Pick<Tables<"choices">, "id" | "is_correct">[];
};

/** `question_bank(...)` embarqué dans `quiz_question_bank` */
type BankScoringRow = Pick<
  Tables<"question_bank">,
  "id" | "type" | "choices" | "active"
>;

type BankScoringLink = { question: BankScoringRow | null };

/** Ligne renvoyée par l'RPC `generate_random_exam`. */
type RandomPickRow = { id: string };

/** `bank_filters` (JSONB) d'un quiz en mode `random_from_bank`. */
type BankFilters = {
  formation_slug?: string;
  qcm_count?: number;
  qr_count?: number;
  difficulties?: string[] | null;
};

export interface QuizScoringData {
  /** QCM : question_id → ensemble des choice_id corrects. */
  correctByQuestion: Map<string, Set<string>>;
  /** Questions rédigées (QR) du quiz (correction manuelle). */
  qrIds: Set<string>;
  totalQcm: number;
}

/**
 * Convertit le JSONB `question_bank.choices` en (choice_id → is_correct),
 * avec le MÊME fallback d'id que l'assemblage côté page ("a", "b", "c"…)
 * pour que les réponses envoyées par le runner matchent toujours.
 */
function bankChoiceIds(choices: unknown): Array<{ id: string; isCorrect: boolean }> {
  return ((choices as BankChoice[] | null) ?? []).map((c, idx) => ({
    id: c.id ?? String.fromCharCode(97 + idx),
    isCorrect: !!c.is_correct,
  }));
}

/**
 * Charge les données de correction d'un quiz.
 *
 * @param admin   client service-role (lecture des bonnes réponses, bypass RLS)
 * @param session client session du stagiaire (RPC `generate_random_exam`,
 *                identique à la page pour reproduire le même tirage)
 */
export async function loadQuizScoringData(opts: {
  admin: SupabaseClient;
  session: SupabaseClient;
  quizId: string;
  userId: string;
  generationMode?: string | null;
  bankFilters?: unknown;
}): Promise<QuizScoringData> {
  const { admin, session, quizId, userId } = opts;

  const correctByQuestion = new Map<string, Set<string>>();
  const qrIds = new Set<string>();

  // Sources 1 & 2 en parallèle (indépendantes)
  const [{ data: legacyData }, { data: bankData }] = await Promise.all([
    admin
      .from("questions")
      .select("id, choices(id, is_correct)")
      .eq("quiz_id", quizId),
    admin
      .from("quiz_question_bank")
      .select("question:question_bank(id, type, choices, active)")
      .eq("quiz_id", quizId),
  ]);

  const legacyRows = (legacyData ?? []) as LegacyScoringRow[];
  for (const q of legacyRows) {
    const set = new Set<string>();
    for (const c of q.choices ?? []) {
      if (c.is_correct) set.add(c.id);
    }
    correctByQuestion.set(q.id, set);
  }

  const bankLinks = (bankData ?? []) as unknown as BankScoringLink[];
  for (const link of bankLinks) {
    const q = link.question;
    if (!q || q.active === false) continue;
    if (q.type === "qr") {
      qrIds.add(q.id);
      continue;
    }
    const set = new Set<string>();
    for (const c of bankChoiceIds(q.choices)) {
      if (c.isCorrect) set.add(c.id);
    }
    correctByQuestion.set(q.id, set);
  }

  // Source 3 : tirage aléatoire re-généré (seed stable user:quiz)
  if (
    correctByQuestion.size === 0 &&
    qrIds.size === 0 &&
    opts.generationMode === "random_from_bank"
  ) {
    const f = (opts.bankFilters as BankFilters | null) ?? {};
    const { data: random } = await session.rpc("generate_random_exam", {
      p_formation_slug: f.formation_slug,
      p_qcm_count: f.qcm_count ?? 30,
      p_qr_count: f.qr_count ?? 0,
      p_difficulty: f.difficulties ?? null,
      p_module_ids: null,
      p_seed: `${userId}:${quizId}`,
    });
    const picks = (random ?? []) as RandomPickRow[];
    if (picks.length > 0) {
      const { data: details } = await admin
        .from("question_bank")
        .select("id, type, choices")
        .in(
          "id",
          picks.map((r) => r.id),
        );
      const rows = (details ?? []) as Pick<
        Tables<"question_bank">,
        "id" | "type" | "choices"
      >[];
      for (const d of rows) {
        if (d.type === "qr") {
          qrIds.add(d.id);
          continue;
        }
        const set = new Set<string>();
        for (const c of bankChoiceIds(d.choices)) {
          if (c.isCorrect) set.add(c.id);
        }
        correctByQuestion.set(d.id, set);
      }
    }
  }

  return { correctByQuestion, qrIds, totalQcm: correctByQuestion.size };
}

export interface QcmScore {
  /** Nombre de bonnes réponses QCM. */
  score: number;
  totalQcm: number;
  /** Pourcentage arrondi, ou null si le quiz ne contient aucun QCM. */
  qcmPercentage: number | null;
}

/**
 * Score QCM serveur : compte les réponses dont le choice_id sélectionné
 * fait partie des bonnes réponses. Les clés inconnues (question hors
 * quiz) sont ignorées : impossible de gonfler le score avec des ids
 * forgés.
 */
export function computeQcmScore(
  answers: Record<string, string>,
  data: QuizScoringData,
): QcmScore {
  let score = 0;
  for (const [questionId, choiceId] of Object.entries(answers)) {
    const correct = data.correctByQuestion.get(questionId);
    if (correct && correct.has(choiceId)) score++;
  }
  const qcmPercentage =
    data.totalQcm > 0 ? Math.round((score / data.totalQcm) * 100) : null;
  return { score, totalQcm: data.totalQcm, qcmPercentage };
}
