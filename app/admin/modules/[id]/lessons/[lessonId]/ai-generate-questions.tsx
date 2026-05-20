"use client";

import { useState, useTransition } from "react";
import Link from "next/link";
import { Sparkles, Loader2, CheckCircle2, ArrowRight } from "lucide-react";
import { generateQuestionsForLesson } from "./ai-actions";

export function AiGenerateQuestions({ lessonId }: { lessonId: string }) {
  const [count, setCount] = useState(5);
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [created, setCreated] = useState<number | null>(null);

  function run() {
    setError(null);
    setCreated(null);
    start(async () => {
      const r = await generateQuestionsForLesson(lessonId, count);
      if (r.ok) setCreated(r.count);
      else setError(r.error);
    });
  }

  return (
    <div className="space-y-4">
      <p className="text-sm text-slate-600">
        Génère des QCM à partir du contenu de cette leçon avec l&apos;IA. Les
        questions sont créées en{" "}
        <strong className="text-navy-900">brouillon</strong> et doivent être
        validées avant d&apos;être utilisables.
      </p>

      <div className="flex items-center gap-3 flex-wrap">
        <label className="text-sm text-slate-600">
          Nombre&nbsp;:
          <select
            value={count}
            onChange={(e) => setCount(Number(e.target.value))}
            disabled={pending}
            className="ml-2 h-9 rounded-lg border border-navy-200 bg-white px-2 text-sm text-navy-900"
          >
            {[3, 5, 8, 10].map((n) => (
              <option key={n} value={n}>
                {n}
              </option>
            ))}
          </select>
        </label>

        <button
          type="button"
          onClick={run}
          disabled={pending}
          className="inline-flex items-center gap-2 rounded-xl bg-navy-900 text-white px-4 py-2.5 text-sm font-medium hover:bg-navy-800 disabled:opacity-60 transition-colors"
        >
          {pending ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Sparkles className="h-4 w-4" />
          )}
          {pending ? "Génération…" : "Générer des QCM (IA)"}
        </button>
      </div>

      {error && (
        <div className="text-sm text-rose-700 bg-rose-50 border border-rose-200 rounded-lg px-3 py-2">
          {error}
        </div>
      )}

      {created !== null && (
        <div className="flex items-center justify-between gap-3 flex-wrap rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3">
          <span className="inline-flex items-center gap-2 text-sm text-emerald-900">
            <CheckCircle2 className="h-4 w-4 text-emerald-600" />
            {created} question{created > 1 ? "s" : ""} créée
            {created > 1 ? "s" : ""} en brouillon.
          </span>
          <Link
            href="/admin/banque-questions/validation"
            className="inline-flex items-center gap-1 text-sm font-medium text-emerald-800 hover:text-emerald-900"
          >
            Valider les questions
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>
      )}
    </div>
  );
}
