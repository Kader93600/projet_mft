import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card } from "@/components/ui/card";
import { FormationBadge } from "@/components/formation/formation-badge";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Plus,
  ChevronRight,
  HelpCircle,
  Clock,
  GraduationCap,
} from "lucide-react";
import { getAuthorizedFormationSlugs } from "@/lib/admin-guard";

export const dynamic = "force-dynamic";

export default async function AdminQuizzes() {
  const supabase = createClient();
  const { slugs, isTrainerOnly } = await getAuthorizedFormationSlugs();

  const [
    { data: quizzes },
    { data: questions },
    { data: questionBank },
    { data: formationQuizzes },
    { data: formationModules },
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
            Quiz & examens
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
        <Link href="/admin/quizzes/new">
          <Button variant="gold">
            <Plus className="h-4 w-4" /> Nouveau quiz
          </Button>
        </Link>
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
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                <th className="text-left px-5 py-3 font-semibold">Quiz</th>
                <th className="text-left px-5 py-3 font-semibold">Formation</th>
                <th className="text-left px-5 py-3 font-semibold">Type</th>
                <th className="text-left px-5 py-3 font-semibold">Module</th>
                <th className="text-left px-5 py-3 font-semibold">Questions</th>
                <th className="text-left px-5 py-3 font-semibold">Chrono</th>
                <th className="text-left px-5 py-3 font-semibold">Seuil</th>
                <th className="px-5 py-3" />
              </tr>
            </thead>
            <tbody>
              {visibleQuizzes.map((q: any) => (
                <tr
                  key={q.id}
                  className="border-t border-navy-50 hover:bg-navy-50/30 group"
                >
                  <td className="px-5 py-3.5">
                    <Link
                      href={`/admin/quizzes/${q.id}`}
                      className="font-medium text-navy-900 group-hover:text-gold-700"
                    >
                      {q.title}
                    </Link>
                  </td>
                  <td className="px-5 py-3.5">
                    {formationByQuiz.has(q.id) ? (
                      <FormationBadge
                        slug={formationByQuiz.get(q.id)}
                        size="sm"
                        icon
                      />
                    ) : (
                      <span className="text-xs text-slate-400">— Aucune —</span>
                    )}
                  </td>
                  <td className="px-5 py-3.5">
                    <Badge tone={q.type === "examen" ? "gold" : "navy"}>
                      {q.type}
                    </Badge>
                  </td>
                  <td className="px-5 py-3.5 text-slate-600 text-xs">
                    {q.modules?.title ?? <span className="text-slate-400">—</span>}
                  </td>
                  <td className="px-5 py-3.5">
                    <span className="inline-flex items-center gap-1 text-slate-600 text-xs">
                      <HelpCircle className="h-3.5 w-3.5" />
                      {counts.get(q.id) ?? 0}
                    </span>
                  </td>
                  <td className="px-5 py-3.5 text-xs">
                    {q.timer_enabled && q.time_limit_s ? (
                      <span className="inline-flex items-center gap-1 text-slate-600">
                        <Clock className="h-3.5 w-3.5" />
                        {Math.round(q.time_limit_s / 60)} min
                      </span>
                    ) : (
                      <span className="text-slate-400">—</span>
                    )}
                  </td>
                  <td className="px-5 py-3.5 text-slate-600 text-xs">
                    {q.pass_threshold}%
                  </td>
                  <td className="px-5 py-3.5 text-right">
                    <Link
                      href={`/admin/quizzes/${q.id}`}
                      className="inline-flex items-center gap-1 text-xs text-navy-700 group-hover:text-gold-700"
                    >
                      Éditer <ChevronRight className="h-3.5 w-3.5" />
                    </Link>
                  </td>
                </tr>
              ))}
              {visibleQuizzes.length === 0 && (
                <tr>
                  <td colSpan={7} className="px-5 py-16 text-center text-slate-400">
                    {isTrainerOnly
                      ? "Aucun quiz sur vos formations habilitées."
                      : "Aucun quiz. Créez-en un pour démarrer."}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
