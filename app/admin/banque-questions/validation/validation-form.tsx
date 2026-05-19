"use client";
import { useState, useTransition } from "react";
import { Card, CardBody } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { CheckCircle2, X, AlertCircle, Loader2, FileText } from "lucide-react";
import { validateQcm, deactivateQuestion } from "./actions";
import { stripHtml } from "@/lib/strip-html";

interface Choice {
  id: string;
  label: string;
  is_correct: boolean;
}

interface Question {
  id: string;
  statement: string;
  choices: Choice[];
  tags: string[];
  source_ref: string | null;
  difficulty: string;
}

export function ValidationForm({
  question,
  indexInPage,
  totalPending,
}: {
  question: Question;
  indexInPage: number;
  totalPending: number;
}) {
  const [selected, setSelected] = useState<string | null>(null);
  const [pending, startTransition] = useTransition();
  const [feedback, setFeedback] = useState<"idle" | "ok" | "err">("idle");
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [hidden, setHidden] = useState(false);

  // Module détecté à partir des tags
  const moduleTag = question.tags.find((t) => t.startsWith("module-"));
  const moduleLetter = moduleTag ? moduleTag.split("-")[1].toUpperCase() : "?";

  function onValidate() {
    if (!selected) {
      setErrorMsg("Sélectionnez une réponse");
      return;
    }
    setErrorMsg(null);
    startTransition(async () => {
      try {
        await validateQcm(question.id, selected);
        setFeedback("ok");
        setTimeout(() => setHidden(true), 600);
      } catch (e: any) {
        setFeedback("err");
        setErrorMsg(e.message ?? "Erreur");
        setTimeout(() => setFeedback("idle"), 2500);
      }
    });
  }

  function onSkip() {
    setHidden(true);
  }

  async function onDeactivate() {
    if (!confirm("Désactiver cette question (la garder hors circulation) ?"))
      return;
    startTransition(async () => {
      try {
        await deactivateQuestion(question.id);
        setHidden(true);
      } catch (e: any) {
        alert(e.message);
      }
    });
  }

  if (hidden) return null;

  return (
    <Card
      className={
        feedback === "ok"
          ? "border-emerald-300 bg-emerald-50/30"
          : feedback === "err"
          ? "border-rose-300"
          : ""
      }
    >
      <CardBody>
        <div className="flex items-start justify-between gap-3 mb-3">
          <div className="flex items-center gap-2 text-xs">
            <Badge tone="navy" size="sm">
              Module {moduleLetter}
            </Badge>
            <Badge tone="slate" size="sm">
              {question.difficulty}
            </Badge>
            {question.source_ref && (
              <span className="text-[10px] font-mono text-slate-400">
                {question.source_ref}
              </span>
            )}
          </div>
          <span className="text-[11px] uppercase tracking-wider text-slate-500">
            {indexInPage} / {totalPending}
          </span>
        </div>

        <h3 className="font-display text-lg font-semibold text-navy-900 leading-snug">
          {stripHtml(question.statement)}
        </h3>

        <fieldset className="mt-4 space-y-2">
          <legend className="sr-only">Choix de réponse</legend>
          {question.choices.map((c) => (
            <label
              key={c.id}
              className={
                "flex items-start gap-3 px-4 py-3 rounded-xl border cursor-pointer transition " +
                (selected === c.id
                  ? "border-signal-500 bg-signal-500/10"
                  : "border-navy-100 bg-white hover:border-navy-300")
              }
            >
              <input
                type="radio"
                name={`q-${question.id}`}
                value={c.id}
                checked={selected === c.id}
                onChange={() => setSelected(c.id)}
                className="mt-1 h-4 w-4 text-signal-500"
              />
              <div className="flex-1">
                <div className="flex items-baseline gap-2">
                  <span className="font-mono text-xs font-bold text-slate-500 uppercase">
                    {c.id}.
                  </span>
                  <span className="text-sm text-navy-900">{c.label}</span>
                </div>
              </div>
            </label>
          ))}
        </fieldset>

        {errorMsg && (
          <div className="mt-3 flex items-center gap-2 rounded-lg bg-rose-50 border border-rose-200 px-3 py-2 text-sm text-rose-800">
            <AlertCircle className="h-4 w-4" />
            {errorMsg}
          </div>
        )}

        <div className="mt-5 flex flex-wrap items-center gap-2 justify-between">
          <button
            onClick={onDeactivate}
            disabled={pending}
            className="text-xs text-rose-600 hover:text-rose-800 disabled:opacity-50"
          >
            Écarter cette question
          </button>
          <div className="flex gap-2">
            <Button
              variant="secondary"
              onClick={onSkip}
              disabled={pending}
              size="sm"
            >
              Passer
            </Button>
            <Button
              onClick={onValidate}
              disabled={!selected || pending}
              variant="gold"
              size="sm"
            >
              {pending ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" /> Validation…
                </>
              ) : feedback === "ok" ? (
                <>
                  <CheckCircle2 className="h-4 w-4" /> Validée !
                </>
              ) : (
                <>
                  <CheckCircle2 className="h-4 w-4" /> Valider et activer
                </>
              )}
            </Button>
          </div>
        </div>
      </CardBody>
    </Card>
  );
}
