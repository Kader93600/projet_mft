import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Plus, GraduationCap, FileText, CheckCircle2 } from "lucide-react";
import { getAuthorizedFormationSlugs } from "@/lib/admin-guard";
import { QuizTable } from "./quiz-table";

export const dynamic = "force-dynamic";

export default async function AdminQuizzes() {
  const supabase = await createClient();
  const { slugs, isTrainerOnly } = await getAuthorizedFormationSlugs();

  const [
    { data: quizzes },
    { data: questions },
    { data: questionBank },
    { data: formationQuizzes },
    { data: formationModules },
    { data: allFormations },
    { data: allModules },
  ] = await Promise.all([
    supabase
      .from("quizzes")
      .select("*, modules(id, title)")
      .order("created_at", { ascending: false }),
    supabase.from("questions").select("quiz_id"),
    supabase.from("quiz_question_bank").select("quiz_id"),
    supabase
      .from("formation_quizzes")
      .select("quiz_id, formation:formations(slug, code)"),
    supabase
      .from("formation_modules")
      .select("module_id, formation:formations(slug, code)"),
    supabase.from("formations").select("slug, code").eq("active", true).order("code"),
    supabase
      .from("modules")
      .select("id, title")
      .order("bloc_id")
      .order("order"),
  ]);

  // Compteur de questions : on additionne `questions` + `quiz_question_bank`
  const counts = new Map<string, number>();
  (questions ?? []).forEach((q: any) => {
    counts.set(q.quiz_id, (counts.get(q.quiz_id) ?? 0) + 1);
  });
  (questionBank ?? []).forEach((q: any) => {
    counts.set(q.quiz_id, (counts.get(q.quiz_id) ?? 0) + 1);
  });

  // Mapping module_id → slug formation (via formation_modules)
  const formationByModule = new Map<string, string>();
  (formationModules ?? []).forEach((fm: any) => {
    if (fm.formation?.slug && !formationByModule.has(fm.module_id)) {
      formationByModule.set(fm.module_id, fm.formation.slug);
    }
  });

  // Mapping quiz_id → slug formation : 1) lien direct formation_quizzes, sinon 2) via module
  const formationByQuiz = new Map<string, string>();
  (formationQuizzes ?? []).forEach((fq: any) => {
    if (fq.formation?.slug && !formationByQuiz.has(fq.quiz_id)) {
      formationByQuiz.set(fq.quiz_id, fq.formation.slug);
    }
  });
  (quizzes ?? []).forEach((q: any) => {
    if (formationByQuiz.has(q.id)) return;
    const moduleId = q.module_id ?? q.modules?.id;
    if (moduleId && formationByModule.has(moduleId)) {
      formationByQuiz.set(q.id, formationByModule.get(moduleId)!);
    }
  });

  // Filtre trainer
  const allowed = new Set(slugs);
  const visibleQuizzes = (quizzes ?? []).filter((q: any) => {
    if (!isTrainerOnly) return true;
    const slug = formationByQuiz.get(q.id);
    return slug ? allowed.has(slug) : false;
  });

  return (
    <div className="space-y-8">
      <header className="flex items-end justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700">Administration</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Exercices & examens
          </h1>
          <p className="mt-2 text-slate-600">
            {visibleQuizzes.length} évaluation
            {visibleQuizzes.length > 1 ? "s" : ""}
            {isTrainerOnly && (
              <>
                {" "}sur {slugs.length} formation
                {slugs.length > 1 ? "s" : ""} habilité
                {slugs.length > 1 ? "es" : "e"}
              </>
            )}
            {!isTrainerOnly &&
              " · créez des entraînements et examens blancs."}
          </p>
        </div>
        <div className="flex items-center gap-2 flex-wrap justify-end">
          <Link
            href="/admin/banque-questions/new-qr"
            title="Créer une question rédigée (correction manuelle formateur)"
          >
            <Button variant="secondary" size="sm">
              <FileText className="h-3.5 w-3.5" />
              Nouvelle QR
            </Button>
          </Link>
          <Link
            href="/admin/banque-questions/new-qcm"
            title="Créer un QCM (correction automatique)"
          >
            <Button variant="secondary" size="sm">
              <CheckCircle2 className="h-3.5 w-3.5" />
              Nouveau QCM
            </Button>
          </Link>
          <Link href="/admin/quizzes/new">
            <Button variant="gold">
              <Plus className="h-4 w-4" />
              Nouvel exercice
            </Button>
          </Link>
        </div>
      </header>

      {/* Bandeau formateur : rappel du scope */}
      {isTrainerOnly && (
        <div className="rounded-2xl bg-emerald-50 border border-emerald-200 p-4 flex items-start gap-3">
          <GraduationCap className="h-5 w-5 text-emerald-700 shrink-0 mt-0.5" />
          <div className="text-sm text-emerald-900 flex-1">
            <strong>Espace formateur</strong> — quiz visibles : ceux des
            formations sur lesquelles vous êtes habilité ({slugs.join(", ") ||
              "aucune"}).
          </div>
        </div>
      )}

      <Card>
        <QuizTable
          rows={visibleQuizzes.map((q: any) => ({
            id: q.id,
            title: q.title,
            type: q.type,
            pass_threshold: q.pass_threshold,
            time_limit_s: q.time_limit_s,
            timer_enabled: q.timer_enabled,
            modules: q.modules
              ? { id: q.modules.id, title: q.modules.title }
              : null,
            module_id: q.module_id ?? q.modules?.id ?? null,
          }))}
          counts={Object.fromEntries(counts)}
          formationByQuiz={Object.fromEntries(formationByQuiz)}
          formations={(allFormations ?? []).map((f: any) => ({
            slug: f.slug,
            code: f.code,
          }))}
          modules={(allModules ?? []).map((m: any) => ({
            id: m.id,
            title: m.title,
          }))}
          emptyMessage={
            isTrainerOnly
              ? "Aucun quiz sur vos formations habilitées."
              : "Aucun quiz. Créez-en un pour démarrer."
          }
        />
      </Card>
    </div>
  );
}
