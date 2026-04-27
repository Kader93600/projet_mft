"use client";
import { useMemo, useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ProgressBar } from "@/components/ui/progress";
import { ArrowLeft, ArrowRight, Loader2, Send } from "lucide-react";
import { submitPlacement } from "./actions";

type Question = {
  id: string;
  bloc_id: number;
  prompt: string;
  choices: string[];
  order: number;
  blocs: { code: string; title: string } | null;
};

export function PlacementWizard({ questions }: { questions: Question[] }) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [current, setCurrent] = useState(0);
  const [answers, setAnswers] = useState<Record<string, number>>({});
  const startedAt = useMemo(() => Date.now(), []);

  const q = questions[current];
  const total = questions.length;
  const answeredCount = Object.keys(answers).length;
  const pct = Math.round(((current + 1) / total) * 100);

  function pick(idx: number) {
    setAnswers((a) => ({ ...a, [q.id]: idx }));
  }

  function next() {
    setError(null);
    if (answers[q.id] === undefined) {
      setError("Sélectionnez une réponse avant de continuer.");
      return;
    }
    if (current < total - 1) setCurrent((c) => c + 1);
  }

  function prev() {
    setError(null);
    if (current > 0) setCurrent((c) => c - 1);
  }

  function submit() {
    if (answeredCount < total) {
      setError("Répondez à toutes les questions avant de valider.");
      return;
    }
    const duration_s = Math.round((Date.now() - startedAt) / 1000);
    start(async () => {
      try {
        await submitPlacement({ answers, duration_s });
        router.refresh();
        router.push("/positionnement");
      } catch (e: any) {
        setError(e.message ?? "Erreur");
      }
    });
  }

  return (
    <Card>
      <CardBody className="space-y-5">
        <div>
          <div className="flex items-center justify-between text-xs text-slate-500 font-medium">
            <span>
              Question {current + 1} / {total}
            </span>
            <span>{answeredCount} répondu{answeredCount > 1 ? "es" : "e"}</span>
          </div>
          <div className="mt-2">
            <ProgressBar value={pct} variant="gradient" />
          </div>
        </div>

        <div className="flex items-center gap-2">
          {q.blocs?.code && <Badge tone="navy" size="sm">{q.blocs.code}</Badge>}
          <span className="text-xs text-slate-500 truncate">{q.blocs?.title}</span>
        </div>

        <h2 className="font-display text-lg font-semibold text-navy-900 leading-snug">
          {q.prompt}
        </h2>

        <div className="space-y-2">
          {q.choices.map((c, i) => {
            const selected = answers[q.id] === i;
            return (
              <button
                type="button"
                key={i}
                onClick={() => pick(i)}
                className={
                  "w-full text-left px-4 py-3 rounded-xl border transition " +
                  (selected
                    ? "bg-gold-50 border-gold-300 text-navy-900"
                    : "bg-white border-navy-100 hover:bg-navy-50 text-slate-700")
                }
              >
                <div className="flex items-start gap-3">
                  <span
                    className={
                      "h-6 w-6 shrink-0 rounded-full border flex items-center justify-center text-xs font-semibold " +
                      (selected
                        ? "bg-gold-500 border-gold-500 text-navy-900"
                        : "border-slate-300 text-slate-500")
                    }
                  >
                    {String.fromCharCode(65 + i)}
                  </span>
                  <span className="text-sm">{c}</span>
                </div>
              </button>
            );
          })}
        </div>

        {error && (
          <p className="text-sm text-rose-700 bg-rose-50 border border-rose-200 px-3 py-2 rounded-lg">
            {error}
          </p>
        )}

        <div className="flex items-center justify-between pt-2">
          <Button
            variant="secondary"
            size="md"
            onClick={prev}
            disabled={current === 0 || pending}
          >
            <ArrowLeft className="h-3.5 w-3.5" /> Précédent
          </Button>
          {current < total - 1 ? (
            <Button size="md" onClick={next} disabled={pending}>
              Suivant <ArrowRight className="h-3.5 w-3.5" />
            </Button>
          ) : (
            <Button variant="gold" size="md" onClick={submit} disabled={pending}>
              {pending ? (
                <Loader2 className="h-3.5 w-3.5 animate-spin" />
              ) : (
                <Send className="h-3.5 w-3.5" />
              )}
              Valider mes réponses
            </Button>
          )}
        </div>
      </CardBody>
    </Card>
  );
}
