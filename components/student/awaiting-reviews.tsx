import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Hourglass, ArrowRight, Sparkles } from "lucide-react";

/**
 * Encart affiché sur le dashboard stagiaire : liste des copies de le stagiaire
 * encore en attente de correction. Masqué si aucune copie en attente.
 */
export async function StudentAwaitingReviews() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: pending } = await supabase
    .from("quiz_attempts")
    .select(
      "id, finished_at, qcm_score, quiz:quizzes(title, is_mock_exam)"
    )
    .eq("user_id", user.id)
    .eq("status", "awaiting_review")
    .order("finished_at", { ascending: false });

  const list = (pending ?? []) as any[];
  if (list.length === 0) return null;

  return (
    <section>
      <Card variant="gold">
        <CardBody>
          <div className="flex items-start gap-3">
            <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-gold-400 to-gold-600 text-white flex items-center justify-center shrink-0">
              <Hourglass className="h-5 w-5" />
            </div>
            <div className="flex-1">
              <div className="flex items-center justify-between gap-3 flex-wrap">
                <div>
                  <div className="eyebrow text-gold-800">
                    Copies en cours de correction
                  </div>
                  <h3 className="mt-1 font-display text-lg font-semibold text-navy-900">
                    {list.length} copie{list.length > 1 ? "s" : ""} en attente
                    de votre formateur
                  </h3>
                </div>
              </div>

              <ul className="mt-4 space-y-2">
                {list.map((a: any) => (
                  <li key={a.id}>
                    <Link
                      href={`/quiz/results/${a.id}`}
                      className="flex items-center gap-3 px-4 py-3 rounded-xl bg-white border border-gold-200 hover:border-gold-400 hover:shadow-soft transition group"
                    >
                      <Sparkles className="h-4 w-4 text-gold-700 shrink-0" />
                      <div className="flex-1 min-w-0">
                        <div className="font-medium text-navy-900 truncate">
                          {a.quiz?.title ?? "Quiz"}
                        </div>
                        <div className="text-xs text-slate-500 mt-0.5">
                          Soumis le{" "}
                          {a.finished_at
                            ? new Date(a.finished_at).toLocaleDateString(
                                "fr-FR"
                              )
                            : "—"}
                          {a.qcm_score !== null && (
                            <>
                              {" · "}
                              QCM : {Math.round(a.qcm_score)}%
                            </>
                          )}
                        </div>
                      </div>
                      <ArrowRight className="h-4 w-4 text-slate-400 group-hover:text-navy-900 group-hover:translate-x-1 transition" />
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </CardBody>
      </Card>
    </section>
  );
}
