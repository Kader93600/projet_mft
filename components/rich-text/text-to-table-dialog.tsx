"use client";

import { useEffect, useMemo, useState } from "react";
import { X, Table as TableIcon, Sparkles, Check } from "lucide-react";
import {
  detectSeparator,
  parseTextAsTable,
  type Separator,
} from "@/lib/text-to-table";

/**
 * Dialog modale qui aide l'admin à convertir un texte sélectionné en
 * tableau HTML. Affiche une preview en temps réel selon le séparateur
 * choisi pour que l'admin voie immédiatement le résultat.
 *
 * Inspiré Notion : auto-détection + override possible, preview live,
 * 1ère ligne en-tête, ajout de colonne possible si la détection rate.
 */
export function TextToTableDialog({
  open,
  initialText,
  onCancel,
  onConfirm,
}: {
  open: boolean;
  initialText: string;
  onCancel: () => void;
  onConfirm: (separator: Separator, firstRowIsHeader: boolean) => void;
}) {
  const auto = useMemo(() => detectSeparator(initialText), [initialText]);
  const [separator, setSeparator] = useState<Separator>(auto.separator);
  const [firstRowIsHeader, setFirstRowIsHeader] = useState(true);

  // Recale le séparateur quand le texte change (ouverture de la modale)
  useEffect(() => {
    if (open) setSeparator(auto.separator);
  }, [open, auto.separator]);

  const parsed = useMemo(
    () => parseTextAsTable(initialText, separator),
    [initialText, separator],
  );

  // Quand 1ère ligne != header, on inclut tout dans body et on génère
  // un header vide.
  const displayHeader = firstRowIsHeader
    ? parsed.header
    : new Array(parsed.cols).fill("");
  const displayBody = firstRowIsHeader
    ? parsed.body
    : [parsed.header, ...parsed.body];

  if (!open) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label="Convertir le texte en tableau"
      className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-navy-950/40 backdrop-blur-sm animate-in fade-in duration-150"
    >
      <div className="w-full max-w-4xl max-h-[88vh] flex flex-col rounded-2xl bg-white shadow-float border border-navy-100">
        {/* Header */}
        <div className="flex items-center gap-3 px-5 py-3 border-b border-navy-100">
          <div className="h-9 w-9 rounded-xl bg-signal-100 inline-flex items-center justify-center">
            <TableIcon className="h-4 w-4 text-signal-700" />
          </div>
          <div className="flex-1">
            <h2 className="font-display text-lg font-semibold text-navy-950">
              Convertir le texte en tableau
            </h2>
            <p className="text-[12.5px] text-slate-600">
              Choisissez le séparateur de colonnes — l'aperçu se met à jour
              en temps réel.
            </p>
          </div>
          <button
            type="button"
            onClick={onCancel}
            className="h-8 w-8 rounded-md inline-flex items-center justify-center text-slate-500 hover:bg-navy-50"
            aria-label="Fermer"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Body : 2 colonnes : options + preview */}
        <div className="flex-1 overflow-y-auto grid md:grid-cols-[260px_1fr] gap-0">
          {/* Options */}
          <div className="px-5 py-4 border-r border-navy-100 bg-ivory">
            <div className="text-[11px] font-bold uppercase tracking-[0.14em] text-slate-600 mb-2">
              Séparateur de colonnes
            </div>

            {auto.confidence > 0.5 && (
              <div className="mb-3 rounded-lg border border-signal-200 bg-signal-50 px-2.5 py-2 text-[11.5px] text-signal-900 flex items-start gap-1.5">
                <Sparkles className="h-3 w-3 text-signal-700 mt-0.5 shrink-0" />
                <div>
                  <strong>Détection auto :</strong>{" "}
                  <SeparatorLabel sep={auto.separator} />
                </div>
              </div>
            )}

            <div className="space-y-1.5">
              <SepOption
                value="tab"
                label="Tabulation"
                desc="Copier-coller depuis Excel"
                current={separator}
                onChange={setSeparator}
              />
              <SepOption
                value="pipe"
                label="Pipe |"
                desc="Format markdown"
                current={separator}
                onChange={setSeparator}
              />
              <SepOption
                value="semicolon"
                label="Point-virgule"
                desc="CSV européen"
                current={separator}
                onChange={setSeparator}
              />
              <SepOption
                value="multispace"
                label="Espaces multiples"
                desc="Texte aligné à largeur fixe"
                current={separator}
                onChange={setSeparator}
              />
              <SepOption
                value="header-then-list"
                label="En-tête + liste"
                desc="Première ligne = colonnes, puis 1 cellule par ligne"
                current={separator}
                onChange={setSeparator}
              />
            </div>

            <div className="mt-4 pt-3 border-t border-navy-100">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={firstRowIsHeader}
                  onChange={(e) => setFirstRowIsHeader(e.target.checked)}
                  className="h-4 w-4 rounded border-navy-300 text-signal-500 focus:ring-signal-500"
                />
                <span className="text-[13px] text-navy-900">
                  Première ligne = en-tête
                </span>
              </label>
            </div>

            <div className="mt-3 text-[11.5px] text-slate-500 leading-relaxed">
              <strong className="text-navy-900">
                {parsed.cols}
              </strong>{" "}
              colonne{parsed.cols > 1 ? "s" : ""} ×{" "}
              <strong className="text-navy-900">
                {firstRowIsHeader ? parsed.body.length : parsed.body.length + 1}
              </strong>{" "}
              ligne(s) détectée(s)
            </div>
          </div>

          {/* Preview */}
          <div className="px-5 py-4 overflow-auto bg-white">
            <div className="text-[11px] font-bold uppercase tracking-[0.14em] text-slate-600 mb-2">
              Aperçu du tableau
            </div>
            <div className="rounded-lg border border-navy-100 overflow-x-auto">
              <table className="w-full border-collapse">
                <thead>
                  <tr>
                    {displayHeader.map((cell, i) => (
                      <th
                        key={i}
                        className="bg-navy-50 text-left font-semibold text-navy-900 px-3 py-1.5 border border-navy-100 text-[13px]"
                      >
                        {cell || (
                          <span className="text-slate-400 italic">
                            (col {i + 1})
                          </span>
                        )}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {displayBody.length === 0 ? (
                    <tr>
                      <td
                        colSpan={parsed.cols}
                        className="px-3 py-6 text-center text-[12px] text-slate-400 border border-navy-100"
                      >
                        Aucune ligne après l'en-tête.
                      </td>
                    </tr>
                  ) : (
                    displayBody.map((row, ri) => (
                      <tr key={ri}>
                        {row.map((cell, ci) => (
                          <td
                            key={ci}
                            className="px-3 py-1.5 border border-navy-100 align-top text-[13px] text-navy-900"
                          >
                            {cell || (
                              <span className="text-slate-300">·</span>
                            )}
                          </td>
                        ))}
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>

            <details className="mt-3">
              <summary className="text-[11px] font-semibold text-slate-500 cursor-pointer hover:text-navy-900">
                Voir le texte sélectionné
              </summary>
              <pre className="mt-2 max-h-[140px] overflow-auto rounded-lg border border-navy-100 bg-ivory p-2 text-[11.5px] text-slate-700 whitespace-pre-wrap font-mono">
                {initialText}
              </pre>
            </details>
          </div>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-end gap-2 px-5 py-3 border-t border-navy-100 bg-ivory">
          <button
            type="button"
            onClick={onCancel}
            className="px-3.5 py-2 rounded-lg text-sm font-semibold text-navy-700 hover:bg-navy-50"
          >
            Annuler
          </button>
          <button
            type="button"
            onClick={() => onConfirm(separator, firstRowIsHeader)}
            className="inline-flex items-center gap-1.5 px-4 py-2 rounded-lg text-sm font-semibold bg-signal-500 text-night-900 hover:bg-signal-400 transition"
          >
            <Check className="h-4 w-4" />
            Insérer le tableau
          </button>
        </div>
      </div>
    </div>
  );
}

function SepOption({
  value,
  label,
  desc,
  current,
  onChange,
}: {
  value: Separator;
  label: string;
  desc: string;
  current: Separator;
  onChange: (v: Separator) => void;
}) {
  const active = current === value;
  return (
    <button
      type="button"
      onClick={() => onChange(value)}
      className={
        "w-full text-left rounded-lg border px-2.5 py-1.5 transition " +
        (active
          ? "bg-navy-900 text-white border-navy-900"
          : "bg-white text-navy-800 border-navy-100 hover:border-navy-200 hover:bg-navy-50")
      }
    >
      <div className="text-[12.5px] font-semibold">{label}</div>
      <div
        className={
          "text-[10.5px] " + (active ? "text-white/70" : "text-slate-500")
        }
      >
        {desc}
      </div>
    </button>
  );
}

function SeparatorLabel({ sep }: { sep: Separator }) {
  const labels: Record<Separator, string> = {
    tab: "Tabulation",
    pipe: "Pipe |",
    semicolon: "Point-virgule",
    multispace: "Espaces multiples",
    "header-then-list": "En-tête + liste",
  };
  return <span>{labels[sep]}</span>;
}
