import { createClient } from "@/lib/supabase/server";
import { isStaff } from "@/lib/permissions";
import { NextRequest, NextResponse } from "next/server";
import {
  Document,
  Page,
  Text,
  View,
  StyleSheet,
  renderToBuffer,
} from "@react-pdf/renderer";
import React from "react";
import { PdfLogoMark } from "@/lib/pdf-logo";
import type { Json, Tables } from "@/lib/database.types";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

// ── Formes exactes des lignes lues (miroir des `.select(...)` plus bas) ──

/** Stagiaire du rapport individuel (select `*` sur profiles). */
type ReportUser = Tables<"profiles">;

/**
 * Tentative listée dans les rapports.
 * `profiles` n'est embarqué que par le rapport GLOBAL (d'où l'optionalité).
 */
type ReportAttempt = Tables<"quiz_attempts"> & {
  quizzes: Pick<Tables<"quizzes">, "title" | "type"> | null;
  profiles?: Pick<Tables<"profiles">, "full_name" | "email"> | null;
};

/** Tentative détaillée (copie corrigée). */
type AttemptDetail = Tables<"quiz_attempts"> & {
  profiles: Pick<Tables<"profiles">, "id" | "full_name" | "email"> | null;
  quizzes: Pick<
    Tables<"quizzes">,
    "id" | "title" | "type" | "pass_threshold"
  > | null;
};

/** Une proposition de QCM (colonne jsonb `question_bank.choices`, ou table `choices`). */
type ReportChoice = { id: string; label: string; is_correct: boolean };

/** Question résolue (banque moderne ou fallback legacy `questions`). */
type ReportQuestion = {
  id: string;
  type: string;
  statement: string;
  explanation: string | null;
  display_order: number;
  choices: ReportChoice[] | null;
  max_score?: number | null;
};

/** Réponse rédigée + note formateur. */
type QrRow = Pick<
  Tables<"qr_responses">,
  | "question_id"
  | "student_answer"
  | "trainer_score"
  | "max_score"
  | "trainer_comment"
>;

/** `quiz_attempts.answers` : jsonb { [id de question]: réponse(s) }. */
type AnswersMap = Record<string, string | string[]>;

const styles = StyleSheet.create({
  page: {
    padding: 40,
    fontSize: 10,
    fontFamily: "Helvetica",
    color: "#0f172a",
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-end",
    marginBottom: 20,
    paddingBottom: 10,
    borderBottomWidth: 2,
    borderBottomColor: "#9FE220",
  },
  brand: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#0E1240",
  },
  subtitle: { fontSize: 9, color: "#64748b", marginTop: 2 },
  meta: { fontSize: 9, color: "#64748b" },

  h1: { fontSize: 14, fontWeight: "bold", color: "#0E1240", marginTop: 14, marginBottom: 8 },
  h2: { fontSize: 11, fontWeight: "bold", color: "#0E1240", marginTop: 10, marginBottom: 4 },

  kpiRow: { flexDirection: "row", gap: 8, marginBottom: 12 },
  kpiBox: {
    flex: 1,
    padding: 8,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: "#e2e8f0",
    backgroundColor: "#f8fafc",
  },
  kpiLabel: { fontSize: 8, color: "#64748b", textTransform: "uppercase" },
  kpiValue: { fontSize: 16, fontWeight: "bold", color: "#0E1240", marginTop: 2 },

  table: { marginTop: 6, borderWidth: 1, borderColor: "#e2e8f0", borderRadius: 4 },
  tr: { flexDirection: "row", borderBottomWidth: 1, borderBottomColor: "#e2e8f0" },
  trLast: { flexDirection: "row" },
  th: {
    padding: 6,
    fontWeight: "bold",
    fontSize: 8,
    color: "#475569",
    backgroundColor: "#f1f5f9",
    textTransform: "uppercase",
  },
  td: { padding: 6, fontSize: 9 },

  qBlock: {
    marginTop: 10,
    padding: 8,
    borderWidth: 1,
    borderColor: "#e2e8f0",
    borderRadius: 4,
    backgroundColor: "#ffffff",
  },
  qHeader: { flexDirection: "row", alignItems: "flex-start", marginBottom: 4 },
  qNum: {
    width: 18,
    height: 18,
    borderRadius: 9,
    backgroundColor: "#0E1240",
    color: "#9FE220",
    fontSize: 8,
    textAlign: "center",
    paddingTop: 3,
    marginRight: 6,
    fontWeight: "bold",
  },
  qStatement: { flex: 1, fontSize: 10, fontWeight: "bold", color: "#0E1240" },
  qBadge: {
    fontSize: 8,
    paddingHorizontal: 5,
    paddingVertical: 2,
    borderRadius: 3,
    marginLeft: 4,
    fontWeight: "bold",
  },
  choice: {
    flexDirection: "row",
    alignItems: "flex-start",
    paddingVertical: 3,
    paddingHorizontal: 5,
    marginTop: 3,
    borderRadius: 3,
    borderWidth: 1,
    borderColor: "#e2e8f0",
  },
  choiceMarker: {
    width: 12,
    fontSize: 9,
    fontWeight: "bold",
    marginRight: 4,
  },
  choiceLabel: { flex: 1, fontSize: 9 },
  choiceNote: { fontSize: 8, fontStyle: "italic" },
  explanation: {
    marginTop: 6,
    padding: 6,
    backgroundColor: "#fef3c7",
    borderLeftWidth: 2,
    borderLeftColor: "#9FE220",
    fontSize: 8,
    color: "#78350f",
  },

  footer: {
    position: "absolute",
    bottom: 24,
    left: 40,
    right: 40,
    fontSize: 8,
    color: "#94a3b8",
    borderTopWidth: 1,
    borderTopColor: "#e2e8f0",
    paddingTop: 6,
    flexDirection: "row",
    justifyContent: "space-between",
  },
});

function fmt(date: string | null | undefined) {
  if (!date) return "—";
  try {
    return new Date(date).toLocaleDateString("fr-FR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
    });
  } catch {
    return "—";
  }
}

function Report({
  mode,
  user,
  attempts,
  globalKPI,
  now,
}: {
  mode: "user" | "global";
  user?: ReportUser | null;
  attempts: ReportAttempt[];
  globalKPI?: { total: number; avg: number; rate: number };
  now: string;
}) {
  return React.createElement(
    Document,
    {},
    React.createElement(
      Page,
      { size: "A4", style: styles.page },
      // Header
      React.createElement(
        View,
        { style: styles.header },
        React.createElement(
          View,
          { style: { flexDirection: "row", alignItems: "center", gap: 10 } },
          React.createElement(PdfLogoMark, { size: 32 }),
          React.createElement(
            View,
            {},
            React.createElement(Text, { style: styles.brand }, "MA FORMATION TRANSPORT"),
            React.createElement(
              Text,
              { style: styles.subtitle },
              mode === "user"
                ? `Rapport individuel — ${user?.full_name || user?.email || "—"}`
                : "Rapport global d'activité"
            )
          )
        ),
        React.createElement(Text, { style: styles.meta }, `Généré le ${now}`)
      ),

      // KPIs
      mode === "user"
        ? React.createElement(
            View,
            { style: styles.kpiRow },
            kpi("Tentatives", String(attempts.length)),
            kpi(
              "Score moyen",
              `${
                attempts.length
                  ? Math.round(
                      attempts.reduce((s, a) => s + (a.percentage || 0), 0) /
                        attempts.length
                    )
                  : 0
              }%`
            ),
            kpi(
              "Réussite",
              `${
                attempts.length
                  ? Math.round(
                      (attempts.filter((a) => a.passed).length / attempts.length) * 100
                    )
                  : 0
              }%`
            )
          )
        : React.createElement(
            View,
            { style: styles.kpiRow },
            kpi("Tentatives totales", String(globalKPI?.total ?? 0)),
            kpi("Score moyen", `${globalKPI?.avg ?? 0}%`),
            kpi("Taux de réussite", `${globalKPI?.rate ?? 0}%`)
          ),

      // Info user
      mode === "user" && user
        ? React.createElement(
            View,
            {},
            React.createElement(Text, { style: styles.h2 }, "Informations"),
            React.createElement(
              Text,
              {},
              `Email : ${user.email || "—"}   |   Téléphone : ${
                user.phone || "—"
              }   |   Inscrit le ${fmt(user.created_at)}`
            )
          )
        : null,

      // Table
      React.createElement(Text, { style: styles.h1 }, "Résultats détaillés"),
      React.createElement(
        View,
        { style: styles.table },
        // Head
        React.createElement(
          View,
          { style: styles.tr },
          React.createElement(Text, { style: [styles.th, { width: "35%" }] }, "Quiz"),
          mode === "global"
            ? React.createElement(
                Text,
                { style: [styles.th, { width: "25%" }] },
                "Stagiaire"
              )
            : React.createElement(Text, { style: [styles.th, { width: "15%" }] }, "Type"),
          React.createElement(Text, { style: [styles.th, { width: "12%" }] }, "Score"),
          React.createElement(Text, { style: [styles.th, { width: "13%" }] }, "Résultat"),
          React.createElement(Text, { style: [styles.th, { width: "15%" }] }, "Date")
        ),
        // Rows
        ...(attempts.length === 0
          ? [
              React.createElement(
                View,
                { style: styles.trLast, key: "empty" },
                React.createElement(
                  Text,
                  { style: [styles.td, { width: "100%", color: "#94a3b8" }] },
                  "Aucune tentative enregistrée."
                )
              ),
            ]
          : attempts.map((a, i) =>
              React.createElement(
                View,
                {
                  key: a.id,
                  style: i === attempts.length - 1 ? styles.trLast : styles.tr,
                },
                React.createElement(
                  Text,
                  { style: [styles.td, { width: "35%" }] },
                  a.quizzes?.title ?? "—"
                ),
                mode === "global"
                  ? React.createElement(
                      Text,
                      { style: [styles.td, { width: "25%" }] },
                      a.profiles?.full_name || a.profiles?.email || "—"
                    )
                  : React.createElement(
                      Text,
                      { style: [styles.td, { width: "15%" }] },
                      a.quizzes?.type ?? "—"
                    ),
                React.createElement(
                  Text,
                  {
                    style: [
                      styles.td,
                      {
                        width: "12%",
                        fontWeight: "bold",
                        // `percentage` est nullable en base ; `null >= 70`
                        // valant `false` en JS, `?? 0` conserve exactement le
                        // même résultat de couleur.
                        color:
                          (a.percentage ?? 0) >= 70
                            ? "#059669"
                            : (a.percentage ?? 0) >= 50
                            ? "#d97706"
                            : "#dc2626",
                      },
                    ],
                  },
                  `${a.percentage}%`
                ),
                React.createElement(
                  Text,
                  {
                    style: [
                      styles.td,
                      {
                        width: "13%",
                        color: a.passed ? "#059669" : "#64748b",
                      },
                    ],
                  },
                  a.passed ? "Réussi" : "Échoué"
                ),
                React.createElement(
                  Text,
                  { style: [styles.td, { width: "15%", color: "#64748b" }] },
                  fmt(a.started_at || a.finished_at)
                )
              )
            )),
      ),

      // Footer
      React.createElement(
        View,
        { style: styles.footer, fixed: true },
        React.createElement(Text, {}, "MA FORMATION TRANSPORT — Rapport confidentiel"),
        React.createElement(
          Text,
          {},
          mode === "user" ? user?.email || "" : "Usage administrateur"
        )
      )
    )
  );
}

function AttemptReport({
  attempt,
  questions,
  qrByQuestion,
  now,
}: {
  attempt: AttemptDetail;
  questions: ReportQuestion[];
  qrByQuestion: Record<string, QrRow | undefined>;
  now: string;
}) {
  const answers = (attempt.answers ?? {}) as AnswersMap;
  const student = attempt.profiles;
  const quiz = attempt.quizzes;

  return React.createElement(
    Document,
    {},
    React.createElement(
      Page,
      { size: "A4", style: styles.page, wrap: true },
      // Header
      React.createElement(
        View,
        { style: styles.header },
        React.createElement(
          View,
          { style: { flexDirection: "row", alignItems: "center", gap: 10 } },
          React.createElement(PdfLogoMark, { size: 32 }),
          React.createElement(
            View,
            {},
            React.createElement(Text, { style: styles.brand }, "MA FORMATION TRANSPORT"),
            React.createElement(
              Text,
              { style: styles.subtitle },
              `Copie corrigée — ${quiz?.title ?? "Quiz"}`
            )
          )
        ),
        React.createElement(Text, { style: styles.meta }, `Généré le ${now}`)
      ),

      // Info bloc
      React.createElement(
        View,
        { style: styles.kpiRow },
        kpi("Stagiaire", student?.full_name || student?.email || "—"),
        kpi("Score", `${attempt.score}/${attempt.total} (${attempt.percentage}%)`),
        kpi("Résultat", attempt.passed ? "Réussi" : "Échoué")
      ),
      React.createElement(
        Text,
        { style: [styles.meta, { marginBottom: 4 }] },
        `Type : ${quiz?.type ?? "—"}   |   Seuil : ${
          quiz?.pass_threshold ?? 70
        }%   |   Durée : ${
          attempt.duration_s ? Math.round(attempt.duration_s / 60) + " min" : "—"
        }   |   Passé le ${fmt(attempt.finished_at || attempt.started_at)}`
      ),

      React.createElement(Text, { style: styles.h1 }, "Détail des réponses"),

      ...questions.map((q, i) => {
        const raw = answers[q.id];
        const picked: string[] = Array.isArray(raw)
          ? raw
          : raw != null && raw !== ""
            ? [raw]
            : [];
        const pickedSet = new Set(picked);
        const choices: ReportChoice[] = q.choices ?? [];

        // ── Question rédigée (QR) : réponse libre + note formateur ──────────
        if (q.type === "qr" || choices.length === 0) {
          const r = qrByQuestion[q.id];
          const graded = r && r.trainer_score != null;
          return React.createElement(
            View,
            { key: q.id, style: styles.qBlock, wrap: false },
            React.createElement(
              View,
              { style: styles.qHeader },
              React.createElement(Text, { style: styles.qNum }, String(i + 1)),
              React.createElement(Text, { style: styles.qStatement }, q.statement),
              React.createElement(
                Text,
                {
                  style: [
                    styles.qBadge,
                    {
                      backgroundColor: graded ? "#d1fae5" : "#fef3c7",
                      color: graded ? "#065f46" : "#78350f",
                    },
                  ],
                },
                graded
                  ? `${r.trainer_score}/${r.max_score ?? q.max_score ?? 1}`
                  : "À corriger"
              )
            ),
            React.createElement(
              View,
              { style: [styles.choice, { borderColor: "#e2e8f0" }] },
              React.createElement(
                Text,
                { style: styles.choiceLabel },
                r?.student_answer ? String(r.student_answer) : "(Aucune réponse)"
              )
            ),
            r?.trainer_comment
              ? React.createElement(
                  Text,
                  { style: styles.explanation },
                  `Commentaire formateur : ${r.trainer_comment}`
                )
              : null,
            q.explanation
              ? React.createElement(
                  Text,
                  { style: styles.explanation },
                  `Explication : ${q.explanation}`
                )
              : null
          );
        }

        // ── QCM ─────────────────────────────────────────────────────────────
        const correctIds = new Set(
          choices.filter((c) => c.is_correct).map((c) => c.id)
        );
        const isCorrect =
          pickedSet.size > 0 &&
          pickedSet.size === correctIds.size &&
          [...pickedSet].every((id) => correctIds.has(id));

        return React.createElement(
          View,
          { key: q.id, style: styles.qBlock, wrap: false },
          // Statement row
          React.createElement(
            View,
            { style: styles.qHeader },
            React.createElement(Text, { style: styles.qNum }, String(i + 1)),
            React.createElement(Text, { style: styles.qStatement }, q.statement),
            React.createElement(
              Text,
              {
                style: [
                  styles.qBadge,
                  {
                    backgroundColor: isCorrect ? "#d1fae5" : "#fee2e2",
                    color: isCorrect ? "#065f46" : "#991b1b",
                  },
                ],
              },
              isCorrect ? "Correct" : "Incorrect"
            )
          ),
          // Choices
          ...choices.map((c) => {
            const isSel = pickedSet.has(c.id);
            const isOk = !!c.is_correct;
            // Color logic
            let bg = "#ffffff";
            let border = "#e2e8f0";
            let note = "";
            let noteColor = "#64748b";
            if (isSel && isOk) {
              bg = "#d1fae5";
              border = "#10b981";
              note = "✓ Sélection correcte";
              noteColor = "#065f46";
            } else if (isSel && !isOk) {
              bg = "#fee2e2";
              border = "#ef4444";
              note = "✗ Mauvaise réponse";
              noteColor = "#991b1b";
            } else if (!isSel && isOk) {
              bg = "#fef3c7";
              border = "#9FE220";
              note = "Bonne réponse (non choisie)";
              noteColor = "#78350f";
            }
            return React.createElement(
              View,
              {
                key: c.id,
                style: [
                  styles.choice,
                  { backgroundColor: bg, borderColor: border },
                ],
              },
              React.createElement(
                Text,
                { style: [styles.choiceMarker, { color: noteColor }] },
                isSel ? "■" : "□"
              ),
              React.createElement(Text, { style: styles.choiceLabel }, c.label),
              note
                ? React.createElement(
                    Text,
                    { style: [styles.choiceNote, { color: noteColor }] },
                    note
                  )
                : null
            );
          }),
          // Explanation
          q.explanation
            ? React.createElement(
                Text,
                { style: styles.explanation },
                `Explication : ${q.explanation}`
              )
            : null
        );
      }),

      // Footer
      React.createElement(
        View,
        { style: styles.footer, fixed: true },
        React.createElement(Text, {}, "MA FORMATION TRANSPORT — Copie corrigée"),
        React.createElement(
          Text,
          {
            render: ({
              pageNumber,
              totalPages,
            }: {
              pageNumber: number;
              totalPages: number;
            }) => `${pageNumber} / ${totalPages}`,
          }
        )
      )
    )
  );
}

function kpi(label: string, value: string) {
  return React.createElement(
    View,
    { style: styles.kpiBox },
    React.createElement(Text, { style: styles.kpiLabel }, label),
    React.createElement(Text, { style: styles.kpiValue }, value)
  );
}

export async function GET(req: NextRequest) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "Non authentifié" }, { status: 401 });
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();
  if (!isStaff(profile?.role))
    return NextResponse.json({ error: "Accès refusé" }, { status: 403 });

  const userId = req.nextUrl.searchParams.get("user");
  const attemptId = req.nextUrl.searchParams.get("attempt");
  const now = new Date().toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });

  // React 19 : `React.ReactElement` vaut désormais `ReactElement<unknown>`, non
  // assignable au paramètre de renderToBuffer. On dérive le type directement de
  // la signature de la lib plutôt que de caster.
  let element: Parameters<typeof renderToBuffer>[0];
  let filename = "rapport-gotrm.pdf";

  if (attemptId) {
    // NB : quiz_attempts a 2 FK vers profiles (user_id + graded_by) → l'embed
    // doit être désambiguïsé via le nom de contrainte, sinon PostgREST renvoie
    // une erreur (masquée auparavant en « Tentative introuvable »).
    const { data: attemptData, error: attemptErr } = await supabase
      .from("quiz_attempts")
      .select(
        "*, profiles!quiz_attempts_user_id_fkey(id, full_name, email), quizzes(id, title, type, pass_threshold)"
      )
      .eq("id", attemptId)
      .single();
    const attempt = attemptData as AttemptDetail | null;
    if (attemptErr)
      return NextResponse.json(
        { error: `Erreur lecture tentative: ${attemptErr.message}` },
        { status: 500 }
      );
    if (!attempt)
      return NextResponse.json({ error: "Tentative introuvable" }, { status: 404 });
    // Détail des questions : modèle moderne quiz_question_bank → question_bank
    // (le quiz_runner stocke la réponse dans attempt.answers indexée par id de
    // question). Fallback legacy `questions`/`choices` pour les anciens quiz.
    type BankLinkRow = Pick<Tables<"quiz_question_bank">, "display_order"> & {
      question: Pick<
        Tables<"question_bank">,
        "id" | "type" | "statement" | "choices" | "explanation" | "max_score"
      > | null;
    };
    const [{ data: bankLinks }, { data: qrRows }] = await Promise.all([
      // `overrideTypes` : sans le générique `Database` sur le client,
      // supabase-js infère l'embed en tableau alors que PostgREST renvoie un
      // objet (relation *-vers-un).
      supabase
        .from("quiz_question_bank")
        .select(
          "display_order, question:question_bank(id, type, statement, choices, explanation, max_score)"
        )
        .eq("quiz_id", attempt.quiz_id)
        .order("display_order")
        .overrideTypes<BankLinkRow[], { merge: false }>(),
      supabase
        .from("qr_responses")
        .select(
          "question_id, student_answer, trainer_score, max_score, trainer_comment"
        )
        .eq("attempt_id", attemptId),
    ]);
    type LegacyQuestionRow = Pick<
      Tables<"questions">,
      "id" | "statement" | "explanation" | "order"
    > & { choices: Tables<"choices">[] | null };

    let resolvedQuestions: ReportQuestion[] = (bankLinks ?? [])
      .map((l): ReportQuestion | null =>
        l.question
          ? {
              ...l.question,
              // `question_bank.choices` est une colonne jsonb : on la restreint
              // à la forme réellement stockée (liste de propositions QCM).
              choices: l.question.choices as ReportChoice[] | null,
              display_order: l.display_order ?? 0,
            }
          : null
      )
      .filter((q): q is ReportQuestion => q !== null);
    if (resolvedQuestions.length === 0) {
      const { data: legacy } = await supabase
        .from("questions")
        .select("id, statement, explanation, order, choices(*)")
        .eq("quiz_id", attempt.quiz_id)
        .order("order");
      resolvedQuestions = ((legacy ?? []) as LegacyQuestionRow[]).map((q) => ({
        id: q.id,
        type: "qcm",
        statement: q.statement,
        explanation: q.explanation,
        display_order: q.order ?? 0,
        choices: (q.choices ?? [])
          .slice()
          .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
          .map((c) => ({
            id: c.id,
            label: c.label,
            is_correct: c.is_correct,
          })),
      }));
    }
    const qrByQuestion: Record<string, QrRow | undefined> = {};
    for (const r of (qrRows ?? []) as QrRow[]) qrByQuestion[r.question_id] = r;
    element = AttemptReport({
      attempt,
      questions: resolvedQuestions,
      qrByQuestion,
      now,
    });
    const safe = (attempt.profiles?.full_name || attempt.profiles?.email || "etudiant")
      .replace(/[^a-z0-9]+/gi, "-")
      .toLowerCase();
    filename = `copie-${safe}-${attempt.quizzes?.title
      ?.replace(/[^a-z0-9]+/gi, "-")
      .toLowerCase() ?? "quiz"}.pdf`;
  } else if (userId) {
    const [{ data: targetUserData }, { data: attempts }] = await Promise.all([
      supabase.from("profiles").select("*").eq("id", userId).single(),
      supabase
        .from("quiz_attempts")
        .select("*, quizzes(title, type)")
        .eq("user_id", userId)
        .order("started_at", { ascending: false }),
    ]);
    const targetUser = targetUserData as ReportUser | null;
    element = Report({
      mode: "user",
      user: targetUser,
      attempts: (attempts ?? []) as ReportAttempt[],
      now,
    });
    filename = `rapport-${(targetUser?.full_name || targetUser?.email || "etudiant")
      .replace(/[^a-z0-9]+/gi, "-")
      .toLowerCase()}.pdf`;
  } else {
    const { data: attempts } = await supabase
      .from("quiz_attempts")
      .select(
        "*, profiles!quiz_attempts_user_id_fkey(full_name, email), quizzes(title, type)"
      )
      .order("finished_at", { ascending: false })
      .limit(200);
    const list = (attempts ?? []) as ReportAttempt[];
    const total = list.length;
    const avg =
      total > 0
        ? Math.round(list.reduce((s, a) => s + (a.percentage || 0), 0) / total)
        : 0;
    const passed = list.filter((a) => a.passed).length;
    const rate = total > 0 ? Math.round((passed / total) * 100) : 0;
    element = Report({
      mode: "global",
      attempts: list,
      globalKPI: { total, avg, rate },
      now,
    });
    filename = `rapport-global-${new Date().toISOString().slice(0, 10)}.pdf`;
  }

  const buffer = await renderToBuffer(element);
  return new NextResponse(new Uint8Array(buffer), {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="${filename}"`,
      "Cache-Control": "no-store",
    },
  });
}
