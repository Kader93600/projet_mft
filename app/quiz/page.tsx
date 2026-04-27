import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Clock, Target, ArrowRight, Trophy, Dumbbell, ShieldAlert, Lock } from "lucide-react";

export default async function QuizListPage() {
  const supabase = createClient();
  const { data: quizzes } = await supabase
    .from("quizzes")
    .select("*, modules(title, slug)")
    .order("type", { ascending: false });

  // Récupère l'état de tentative pour chaque quiz (tentatives utilisées / délai)
  const states: Record<string, any> = {};
  await Promise.all(
    (quizzes || []).map(async (q: any) => {
      const { data } = await supabase.rpc("quiz_attempt_state", { p_quiz_id: q.id });
      states[q.id] = data;
    })
  );

  const entrainement = quizzes?.filter((q) => q.type === "entrainement") || [];
  const examen = quizzes?.filter((q) => q.type === "examen") || [];

  return (
    <div className="space-y-12">
      <header>
        <span className="eyebrow text-gold-700">Évaluation</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Quiz & Examens
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Mesurez votre maîtrise avec des entraînements ciblés ou confrontez-vous à une
          simulation fidèle au format officiel du jury.
        </p>
      </header>

      {examen.length > 0 && (
        <section>
          <div className="flex items-center gap-2 mb-5">
            <Trophy className="h-4 w-4 text-gold-600" />
            <h2 className="font-display text-xl font-semibold text-navy-900 tracking-tight">
              Examens blancs
            </h2>
          </div>
          <div className="grid md:grid-cols-2 gap-4">
            {examen.map((q: any) => (
              <QuizCard key={q.id} quiz={q} state={states[q.id]} />
            ))}
          </div>
        </section>
      )}

      <section>
        <div className="flex items-center gap-2 mb-5">
          <Dumbbell className="h-4 w-4 text-navy-700" />
          <h2 className="font-display text-xl font-semibold text-navy-900 tracking-tight">
            Entraînement par module
          </h2>
        </div>
        <div className="grid md:grid-cols-2 gap-4">
          {entrainement.map((q: any) => (
            <QuizCard key={q.id} quiz={q} state={states[q.id]} />
          ))}
        </div>
      </section>
    </div>
  );
}

function QuizCard({ quiz, state }: { quiz: any; state: any }) {
  const isMock = !!quiz.is_mock_exam;
  const isExam = quiz.type === "examen" || isMock;
  const blocked = state && state.allowed === false;
  const attemptsLeft =
    state?.attempts_max != null
      ? Math.max(0, state.attempts_max - state.attempts_used)
      : null;
  return (
    <Link href={`/quiz/${quiz.id}`} className="group">
      <Card
        variant={isExam ? "gold" : "default"}
        className="h-full group-hover:-translate-y-0.5 group-hover:shadow-raised transition-all"
      >
        <CardBody className="flex flex-col h-full">
          <div className="flex items-center justify-between gap-2">
            {isMock ? (
              <Badge tone="gold" size="sm">
                <ShieldAlert className="h-3 w-3" /> Examen blanc
              </Badge>
            ) : quiz.type === "examen" ? (
              <Badge tone="gold" size="sm">Mode examen</Badge>
            ) : (
              <Badge tone="navy" size="sm">Entraînement</Badge>
            )}
            {quiz.modules?.title && (
              <span className="text-[11px] uppercase tracking-wider text-slate-500 truncate max-w-[50%]">
                {quiz.modules.title}
              </span>
            )}
          </div>
          <h3 className="mt-4 font-display text-lg font-semibold text-navy-900 leading-snug">
            {quiz.title}
          </h3>
          {quiz.description && (
            <p className="mt-1.5 text-sm text-slate-600 line-clamp-2">{quiz.description}</p>
          )}

          {(attemptsLeft !== null || blocked) && (
            <div className="mt-3 flex items-center flex-wrap gap-2 text-xs">
              {attemptsLeft !== null && !blocked && (
                <span className="rounded-md bg-ivory border border-navy-100 px-2 py-0.5 text-navy-800">
                  {attemptsLeft} tentative{attemptsLeft > 1 ? "s" : ""} restante{attemptsLeft > 1 ? "s" : ""}
                </span>
              )}
              {blocked && state?.reason === "max_attempts" && (
                <span className="inline-flex items-center gap-1 rounded-md bg-rose-50 border border-rose-200 px-2 py-0.5 text-rose-800">
                  <Lock className="h-3 w-3" /> Plus de tentative
                </span>
              )}
              {blocked && state?.reason === "retake_delay" && state?.next_available_at && (
                <span className="inline-flex items-center gap-1 rounded-md bg-rose-50 border border-rose-200 px-2 py-0.5 text-rose-800">
                  <Clock className="h-3 w-3" />
                  Disponible {new Date(state.next_available_at).toLocaleDateString("fr-FR", {
                    day: "2-digit", month: "short", hour: "2-digit", minute: "2-digit",
                  })}
                </span>
              )}
            </div>
          )}

          <div className="mt-auto pt-5 flex items-center justify-between">
            <div className="flex items-center gap-4 text-xs text-slate-500">
              {quiz.time_limit_s && (
                <span className="inline-flex items-center gap-1">
                  <Clock className="w-3 h-3" /> {Math.round(quiz.time_limit_s / 60)} min
                </span>
              )}
              <span className="inline-flex items-center gap-1">
                <Target className="w-3 h-3" /> Seuil {quiz.pass_threshold}%
              </span>
            </div>
            <span className="inline-flex items-center gap-1 text-sm font-medium text-navy-900 group-hover:text-gold-700 transition-colors">
              {blocked ? "Détails" : "Démarrer"}
              <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
            </span>
          </div>
        </CardBody>
      </Card>
    </Link>
  );
}
