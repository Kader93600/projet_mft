import Link from "next/link";
import { redirect, notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ArrowLeft, Award, User, BookOpen, Clock } from "lucide-react";
import { findFormation } from "@/lib/formations-config";
import { initials } from "@/lib/utils";
import { isStaff } from "@/lib/permissions";
import { FormationStripe } from "@/components/formation/formation-stripe";
import { FormationBadge } from "@/components/formation/formation-badge";
import { QrGradingForm } from "./qr-grading-form";
import { FinalizeForm } from "./finalize-form";
import type { Tables } from "@/lib/database.types";

export const dynamic = "force-dynamic";

// ── Types de lecture, calqués sur les `select()` de cette page ──────────
type AttemptRow = Pick<
  Tables<"quiz_attempts">,
  "id" | "user_id" | "quiz_id" | "status" | "qcm_score" | "qr_score" | "finished_at"
> & {
  student: Pick<Tables<"profiles">, "full_name" | "email"> | null;
  quiz: Pick<
    Tables<"quizzes">,
    "title" | "description" | "is_mock_exam" | "pass_threshold"
  > | null;
};

/** Critère de barème produit par le correcteur IA (colonne jsonb `ai_criteria`). */
type AiCriterion = { name: string; weight: number; awarded: number };

type QrResponseRow = Pick<
  Tables<"qr_responses">,
  | "id"
  | "question_id"
  | "student_answer"
  | "trainer_score"
  | "max_score"
  | "trainer_comment"
  | "graded_at"
  | "graded_by"
  | "submitted_at"
  | "ai_score"
  | "ai_feedback_md"
  | "ai_concerns"
  | "ai_graded_at"
> & {
  // Colonnes dont le type Postgres est plus large que le contrat réel :
  // `ai_criteria` est un jsonb écrit par le grader IA, `ai_confidence` un
  // text contraint aux trois niveaux ci-dessous.
  ai_criteria: AiCriterion[] | null;
  ai_confidence: "low" | "medium" | "high" | null;
  question: Pick<
    Tables<"question_bank">,
    "statement" | "expected_answer" | "scoring_grid" | "tags"
  > | null;
};

type FormationQuizRow = {
  formation: Pick<Tables<"formations">, "slug" | "code"> | null;
};

export default async function CorrectionDetailPage({
  params,
}: {
  params: { attemptId: string };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  // Sécurité : trainer ou staff
  const { data: me } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();
  if (!me?.role || !["trainer", "admin", "super_admin"].includes(me.role)) {
    redirect("/dashboard");
  }

  // Charger la tentative.
  // `select<Query, Result>` : sans client générique <Database>, postgrest-js
  // ne connaît pas la cardinalité des embeds et les infère en tableaux ;
  // on fournit donc explicitement le type de ligne (to-one → objet).
  const { data: attempt } = await supabase
    .from("quiz_attempts")
    .select<string, AttemptRow>(
      `id, user_id, quiz_id, status, qcm_score, qr_score, finished_at,
       student:profiles!quiz_attempts_user_id_fkey(full_name, email),
       quiz:quizzes(title, description, is_mock_exam, pass_threshold)`
    )
    .eq("id", params.attemptId)
    .maybeSingle();
  if (!attempt) notFound();

  // Vérification d'accès trainer : doit être affecté ou staff
  if (!isStaff(me.role)) {
    const { data: assignment } = await supabase
      .from("trainer_assignments")
      .select("id")
      .eq("trainer_id", user.id)
      .eq("student_id", attempt.user_id)
      .maybeSingle();
    if (!assignment) {
      // Vérifier l'habilitation par formation via formation_quizzes
      const { data: fq } = await supabase
        .from("formation_quizzes")
        .select("formation_id")
        .eq("quiz_id", attempt.quiz_id);
      let allowed = false;
      if (fq && fq.length > 0) {
        const fqRows = fq as Pick<
          Tables<"formation_quizzes">,
          "formation_id"
        >[];
        const { data: hab } = await supabase
          .from("trainer_formations")
          .select("id")
          .eq("trainer_id", user.id)
          .in(
            "formation_id",
            fqRows.map((x) => x.formation_id)
          );
        allowed = !!hab?.length;
      }
      if (!allowed) redirect("/formateur/corrections");
    }
  }

  // Charger les QR responses + textes des questions (depuis question_bank)
  // Sprint 3.3 : on récupère aussi les colonnes ai_* pour permettre au
  // formateur d'utiliser la proposition Claude comme point de départ.
  const { data: responses } = await supabase
    .from("qr_responses")
    .select<string, QrResponseRow>(
      `id, question_id, student_answer, trainer_score, max_score,
       trainer_comment, graded_at, graded_by, submitted_at,
       ai_score, ai_feedback_md, ai_criteria, ai_confidence,
       ai_concerns, ai_graded_at,
       question:question_bank(statement, expected_answer, scoring_grid, tags)`
    )
    .eq("attempt_id", params.attemptId)
    .order("submitted_at");

  const aiEnabled = process.env.FEATURE_AI_TUTOR === "true";

  const list = responses ?? [];
  const ungradedCount = list.filter((r) => !r.graded_at).length;
  const allGraded = list.length > 0 && ungradedCount === 0;
  const isAlreadyGraded = attempt.status === "graded";

  // Slug formation pour affichage
  const { data: fq } = await supabase
    .from("formation_quizzes")
    .select<string, FormationQuizRow>("formation:formations(slug, code)")
    .eq("quiz_id", attempt.quiz_id)
    .maybeSingle();
  const formationSlug = fq?.formation?.slug;
  const formation = formationSlug ? findFormation(formationSlug) : null;

  const student = attempt.student;
  const quiz = attempt.quiz;

  return (
    <div>
      {formationSlug && <FormationStripe slug={formationSlug} />}
      <div className="space-y-8 pt-6">
      <Link
        href="/formateur/corrections"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Toutes les copies
      </Link>

      {/* Header */}
      <header>
        <div className="flex items-start gap-4 flex-wrap">
          <div className="h-14 w-14 rounded-full bg-gradient-to-br from-brand-500 to-brand-700 text-white flex items-center justify-center font-display text-lg font-bold shrink-0">
            {initials(student?.full_name ?? student?.email ?? "?")}
          </div>
          <div className="flex-1 min-w-0">
            <h1 className="font-display text-2xl md:text-3xl font-semibold text-navy-950 tracking-tight">
              Correction — {student?.full_name ?? student?.email}
            </h1>
            <div className="mt-2 flex items-center gap-3 text-sm text-slate-600 flex-wrap">
              {formation && (
                <span
                  className="inline-flex items-center px-2 py-0.5 rounded text-xs font-semibold"
                  style={{
                    backgroundColor: `${formation.accent}22`,
                    color: formation.accent,
                    border: `1px solid ${formation.accent}55`,
                  }}
                >
                  {formation.code}
                </span>
              )}
              <span className="inline-flex items-center gap-1">
                <BookOpen className="h-3.5 w-3.5" />
                {quiz?.title}
              </span>
              {quiz?.is_mock_exam && (
                <Badge tone="gold" size="sm">
                  <Award className="h-3 w-3" /> Examen blanc
                </Badge>
              )}
              {attempt.finished_at && (
                <span className="inline-flex items-center gap-1 text-xs text-slate-500">
                  <Clock className="h-3 w-3" />
                  Soumis le{" "}
                  {new Date(attempt.finished_at).toLocaleDateString("fr-FR", {
                    day: "2-digit",
                    month: "long",
                    year: "numeric",
                  })}
                </span>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Récap QCM auto (si présent) */}
      {attempt.qcm_score !== null && (
        <Card>
          <CardBody className="flex items-center justify-between gap-4">
            <div>
              <div className="text-[11px] uppercase tracking-wider text-slate-500 font-semibold">
                Score QCM (auto-corrigé)
              </div>
              <div className="font-display text-2xl font-semibold text-navy-900 mt-1">
                {Math.round(attempt.qcm_score)}%
              </div>
            </div>
            <div className="text-right">
              <div className="text-xs text-slate-500">
                Pondération finale (par défaut)
              </div>
              <div className="text-sm font-medium text-navy-900">
                70 % QCM · 30 % rédigées
              </div>
            </div>
          </CardBody>
        </Card>
      )}

      {/* Liste QR à corriger */}
      <section>
        <div className="flex items-center justify-between mb-4 flex-wrap gap-2">
          <h2 className="font-display text-xl font-semibold text-navy-900">
            Questions rédigées ({list.length})
          </h2>
          <Badge tone={ungradedCount > 0 ? "rose" : "success"} size="sm">
            {ungradedCount > 0
              ? `${ungradedCount} en attente`
              : "Toutes corrigées"}
          </Badge>
        </div>

        <div className="space-y-4">
          {list.map((r, i) => (
            <QrGradingForm
              key={r.id}
              response={{
                id: r.id,
                index: i + 1,
                statement: r.question?.statement ?? "—",
                expected_answer: r.question?.expected_answer,
                scoring_grid: r.question?.scoring_grid,
                student_answer: r.student_answer,
                trainer_score: r.trainer_score,
                max_score: r.max_score,
                trainer_comment: r.trainer_comment,
                graded_at: r.graded_at,
                tags: r.question?.tags ?? [],
                ai_score: r.ai_score,
                ai_feedback_md: r.ai_feedback_md,
                ai_criteria: r.ai_criteria,
                ai_confidence: r.ai_confidence,
                ai_concerns: r.ai_concerns,
                ai_graded_at: r.ai_graded_at,
              }}
              disabled={isAlreadyGraded}
              aiEnabled={aiEnabled}
            />
          ))}
        </div>
      </section>

      {/* Finalisation */}
      <section>
        <Card variant={allGraded && !isAlreadyGraded ? "gold" : undefined}>
          <CardBody>
            <CardTitle>Finalisation</CardTitle>
            {isAlreadyGraded ? (
              <p className="mt-2 text-sm text-emerald-700 inline-flex items-center gap-1.5">
                <Award className="h-4 w-4" /> Cette copie a déjà été finalisée.
              </p>
            ) : (
              <FinalizeForm
                attemptId={params.attemptId}
                disabled={!allGraded}
                ungradedCount={ungradedCount}
              />
            )}
          </CardBody>
        </Card>
      </section>
      </div>
    </div>
  );
}
