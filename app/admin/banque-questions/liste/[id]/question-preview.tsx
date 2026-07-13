import { RichTextDisplay } from "@/components/rich-text/rich-text-display";
import { CheckCircle2, AlertTriangle } from "lucide-react";

interface Choice {
  id?: string;
  label: string;
  is_correct: boolean;
  order?: number;
}

/**
 * Prévisualisation d'une question TELLE QUE le stagiaire la voit (énoncé +
 * choix / zone de réponse), avec les annotations réservées à l'admin :
 * - QCM : la bonne réponse est mise en évidence ;
 * - QR : le corrigé (réponse attendue + barème) est affiché, ou un
 *   avertissement clair quand il manque (question inexploitable).
 */
export function QuestionPreview({
  question,
}: {
  question: {
    type: string;
    statement: string;
    choices?: Choice[] | null;
    expected_answer?: string | null;
    scoring_grid?: string | null;
    max_score?: number | null;
  };
}) {
  const isQcm = question.type !== "qr";
  const choices = [...((question.choices ?? []) as Choice[])].sort(
    (a, b) => (a.order ?? 0) - (b.order ?? 0)
  );

  return (
    <div className="rounded-2xl border border-navy-100 bg-ivory p-6">
      <RichTextDisplay
        content={question.statement}
        className="font-display text-xl font-semibold text-navy-900 leading-snug"
      />

      {isQcm ? (
        <div
          className="mt-5 space-y-2.5"
          role="radiogroup"
          aria-label="Aperçu des choix de réponse"
        >
          {choices.map((c, i) => {
            const letter = String.fromCharCode(65 + i);
            return (
              <div
                key={c.id ?? i}
                className={`flex items-center gap-3 rounded-xl border px-4 py-3 ${
                  c.is_correct
                    ? "border-emerald-300 bg-emerald-50"
                    : "border-navy-100 bg-white"
                }`}
              >
                <span
                  className={`h-7 w-7 rounded-md text-xs font-semibold flex items-center justify-center shrink-0 ${
                    c.is_correct
                      ? "bg-emerald-600 text-white"
                      : "bg-navy-50 text-navy-700"
                  }`}
                >
                  {letter}
                </span>
                <span className="text-[15px] text-navy-900 flex-1">
                  {c.label}
                </span>
                {c.is_correct && (
                  <span className="inline-flex items-center gap-1 text-xs font-semibold text-emerald-700 shrink-0">
                    <CheckCircle2 className="h-4 w-4" /> Bonne réponse
                  </span>
                )}
              </div>
            );
          })}
        </div>
      ) : (
        <div className="mt-5 space-y-4">
          <div>
            <div className="text-[11px] uppercase tracking-wider text-slate-500 font-semibold mb-1">
              Zone de réponse du stagiaire
            </div>
            <div className="w-full rounded-xl border border-dashed border-navy-200 bg-white p-4 text-sm italic text-slate-400">
              Réponse rédigée, corrigée manuellement (barème /
              {question.max_score ?? "?"}).
            </div>
          </div>

          {question.expected_answer ? (
            <div className="rounded-xl border border-emerald-200 bg-emerald-50 p-4">
              <div className="text-[11px] uppercase tracking-wider text-emerald-700 font-semibold mb-1">
                Réponse attendue (corrigé)
              </div>
              <RichTextDisplay
                content={question.expected_answer}
                className="text-sm text-navy-900"
              />
              {question.scoring_grid && (
                <div className="mt-3 border-t border-emerald-200 pt-3">
                  <div className="text-[11px] uppercase tracking-wider text-emerald-700 font-semibold mb-1">
                    Barème
                  </div>
                  <RichTextDisplay
                    content={question.scoring_grid}
                    className="text-sm text-navy-900"
                  />
                </div>
              )}
            </div>
          ) : (
            <div className="flex items-start gap-2 rounded-xl border border-amber-300 bg-amber-50 p-4 text-sm text-amber-800">
              <AlertTriangle className="h-4 w-4 mt-0.5 shrink-0" />
              <span>
                Aucun corrigé (réponse attendue) : cette question rédigée est
                inexploitable en l'état, impossible de corriger une copie.
                À compléter avant de l'activer.
              </span>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
