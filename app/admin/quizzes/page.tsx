import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Plus, ChevronRight, HelpCircle, Clock } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function AdminQuizzes() {
  const supabase = createClient();
  const [{ data: quizzes }, { data: questions }] = await Promise.all([
    supabase
      .from("quizzes")
      .select("*, modules(title)")
      .order("created_at", { ascending: false }),
    supabase.from("questions").select("quiz_id"),
  ]);

  const counts = new Map<string, number>();
  (questions ?? []).forEach((q: any) => {
    counts.set(q.quiz_id, (counts.get(q.quiz_id) ?? 0) + 1);
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
            {quizzes?.length ?? 0} évaluations · créez des entraînements et examens blancs.
          </p>
        </div>
        <Link href="/admin/quizzes/new">
          <Button variant="gold">
            <Plus className="h-4 w-4" /> Nouveau quiz
          </Button>
        </Link>
      </header>

      <Card>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                <th className="text-left px-5 py-3 font-semibold">Quiz</th>
                <th className="text-left px-5 py-3 font-semibold">Type</th>
                <th className="text-left px-5 py-3 font-semibold">Module</th>
                <th className="text-left px-5 py-3 font-semibold">Questions</th>
                <th className="text-left px-5 py-3 font-semibold">Chrono</th>
                <th className="text-left px-5 py-3 font-semibold">Seuil</th>
                <th className="px-5 py-3" />
              </tr>
            </thead>
            <tbody>
              {(quizzes ?? []).map((q: any) => (
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
              {(!quizzes || quizzes.length === 0) && (
                <tr>
                  <td colSpan={7} className="px-5 py-16 text-center text-slate-400">
                    Aucun quiz. Créez-en un pour démarrer.
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
