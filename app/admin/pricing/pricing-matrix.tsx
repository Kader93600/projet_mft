"use client";

import { useState, useTransition } from "react";
import {
  PACK_SLUGS,
  PACK_METADATA,
  isPackAvailableForFormation,
  fmtEuros,
  type PackSlug,
} from "@/lib/packs";
import { updatePackPriceAction } from "./actions";
import { Check, Pencil, Loader2, X, AlertCircle } from "lucide-react";

interface Formation {
  id: string;
  slug: string;
  code: string;
  title: string;
}

interface PriceCell {
  priceCents: number;
  compareAtCents: number | null;
  active: boolean;
}

interface Props {
  formations: Formation[];
  priceMap: Record<string, PriceCell>; // key: `${formationId}_${pack}`
}

interface EditState {
  formationId: string;
  pack: PackSlug;
  priceEuros: string; // saisi en euros (pas centimes) pour user-friendly
  compareAtEuros: string;
  active: boolean;
}

export function PricingMatrix({ formations, priceMap }: Props) {
  const [editing, setEditing] = useState<EditState | null>(null);
  const [feedback, setFeedback] = useState<{
    formationId: string;
    pack: PackSlug;
    type: "ok" | "error";
    message: string;
  } | null>(null);
  const [isPending, startTransition] = useTransition();

  const startEdit = (
    formationId: string,
    pack: PackSlug,
    cell: PriceCell | undefined,
  ) => {
    setEditing({
      formationId,
      pack,
      priceEuros: cell ? String(cell.priceCents / 100) : "",
      compareAtEuros: cell?.compareAtCents
        ? String(cell.compareAtCents / 100)
        : "",
      active: cell?.active ?? true,
    });
    setFeedback(null);
  };

  const cancelEdit = () => {
    setEditing(null);
    setFeedback(null);
  };

  const saveEdit = () => {
    if (!editing) return;
    const priceEuros = parseFloat(editing.priceEuros.replace(",", "."));
    const compareAtEuros = editing.compareAtEuros
      ? parseFloat(editing.compareAtEuros.replace(",", "."))
      : null;

    if (isNaN(priceEuros) || priceEuros <= 0) {
      setFeedback({
        formationId: editing.formationId,
        pack: editing.pack,
        type: "error",
        message: "Prix invalide (doit être > 0)",
      });
      return;
    }
    if (compareAtEuros != null && compareAtEuros <= priceEuros) {
      setFeedback({
        formationId: editing.formationId,
        pack: editing.pack,
        type: "error",
        message: "Le prix barré doit être supérieur au prix actuel",
      });
      return;
    }

    startTransition(async () => {
      const res = await updatePackPriceAction({
        formationId: editing.formationId,
        pack: editing.pack,
        priceCents: Math.round(priceEuros * 100),
        compareAtCents: compareAtEuros
          ? Math.round(compareAtEuros * 100)
          : null,
        active: editing.active,
      });
      if (res.ok) {
        setFeedback({
          formationId: editing.formationId,
          pack: editing.pack,
          type: "ok",
          message: "Prix mis à jour",
        });
        setEditing(null);
        // Force le rechargement des données (Next va revalider via revalidatePath)
        setTimeout(() => setFeedback(null), 2500);
        // Optimistic update — update the local priceMap pour UX immédiate
        // (la prochaine navigation rechargera la vraie valeur depuis la DB)
        const key = `${editing.formationId}_${editing.pack}`;
        priceMap[key] = {
          priceCents: Math.round(priceEuros * 100),
          compareAtCents: compareAtEuros
            ? Math.round(compareAtEuros * 100)
            : null,
          active: editing.active,
        };
      } else {
        setFeedback({
          formationId: editing.formationId,
          pack: editing.pack,
          type: "error",
          message: errorLabel(res.error || "unknown_error"),
        });
      }
    });
  };

  return (
    <div className="overflow-x-auto rounded-2xl border border-navy-100 bg-white shadow-soft">
      <table className="w-full">
        <thead>
          <tr className="border-b border-navy-100 text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-500 bg-slate-50/50">
            <th className="text-left p-4 w-1/3">Formation</th>
            {PACK_SLUGS.map((p) => (
              <th key={p} className="text-left p-4">
                <span
                  className="inline-block w-2 h-2 rounded-full mr-2 align-middle"
                  style={{ backgroundColor: PACK_METADATA[p].accent }}
                />
                {PACK_METADATA[p].name}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {formations.map((f) => (
            <tr
              key={f.id}
              className="border-b border-navy-100 last:border-b-0 hover:bg-slate-50/50 transition-colors"
            >
              <td className="p-4">
                <div className="font-semibold text-navy-950 text-sm">{f.code}</div>
                <div className="text-xs text-slate-500 mt-0.5 line-clamp-1">
                  {f.title}
                </div>
              </td>
              {PACK_SLUGS.map((pack) => {
                const key = `${f.id}_${pack}`;
                const cell = priceMap[key];
                const available = isPackAvailableForFormation(pack, f.slug);
                const isEditing =
                  editing?.formationId === f.id && editing?.pack === pack;
                const cellFeedback =
                  feedback?.formationId === f.id && feedback?.pack === pack
                    ? feedback
                    : null;

                return (
                  <td key={pack} className="p-3 align-top">
                    {!available ? (
                      <div className="text-xs text-slate-400 italic">
                        Non vendable
                      </div>
                    ) : isEditing ? (
                      <div className="space-y-2">
                        <div>
                          <label className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold block mb-1">
                            Prix (€)
                          </label>
                          <input
                            type="text"
                            inputMode="decimal"
                            value={editing.priceEuros}
                            onChange={(e) =>
                              setEditing({
                                ...editing,
                                priceEuros: e.target.value,
                              })
                            }
                            className="w-full bg-white border border-navy-200 rounded-md px-2.5 py-1.5 text-sm text-navy-950 focus:outline-none focus:border-gold-500 focus:ring-1 focus:ring-gold-500/30"
                            disabled={isPending}
                            autoFocus
                          />
                        </div>
                        <div>
                          <label className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold block mb-1">
                            Prix barré (€){" "}
                            <span className="text-slate-400 font-normal">— optionnel</span>
                          </label>
                          <input
                            type="text"
                            inputMode="decimal"
                            value={editing.compareAtEuros}
                            onChange={(e) =>
                              setEditing({
                                ...editing,
                                compareAtEuros: e.target.value,
                              })
                            }
                            placeholder="—"
                            className="w-full bg-white border border-navy-200 rounded-md px-2.5 py-1.5 text-sm text-navy-950 placeholder:text-slate-400 focus:outline-none focus:border-gold-500 focus:ring-1 focus:ring-gold-500/30"
                            disabled={isPending}
                          />
                        </div>
                        <label className="flex items-center gap-2 text-xs text-slate-700 cursor-pointer">
                          <input
                            type="checkbox"
                            checked={editing.active}
                            onChange={(e) =>
                              setEditing({
                                ...editing,
                                active: e.target.checked,
                              })
                            }
                            disabled={isPending}
                            className="accent-emerald-600 h-4 w-4"
                          />
                          Actif (visible publiquement)
                        </label>
                        <div className="flex gap-2 pt-1">
                          <button
                            type="button"
                            onClick={saveEdit}
                            disabled={isPending}
                            className="flex-1 inline-flex items-center justify-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-semibold bg-navy-900 text-white hover:bg-navy-800 disabled:opacity-50 transition-colors"
                          >
                            {isPending ? (
                              <Loader2 className="h-3.5 w-3.5 animate-spin" />
                            ) : (
                              <Check className="h-3.5 w-3.5" />
                            )}
                            Enregistrer
                          </button>
                          <button
                            type="button"
                            onClick={cancelEdit}
                            disabled={isPending}
                            className="inline-flex items-center justify-center px-2.5 py-1.5 rounded-md text-xs font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200 disabled:opacity-50 transition-colors"
                          >
                            <X className="h-3.5 w-3.5" />
                          </button>
                        </div>
                        {cellFeedback?.type === "error" && (
                          <div className="text-[11px] text-rose-600 flex items-start gap-1 leading-tight bg-rose-50 border border-rose-200 rounded px-2 py-1.5">
                            <AlertCircle className="h-3 w-3 mt-0.5 shrink-0" />
                            <span>{cellFeedback.message}</span>
                          </div>
                        )}
                      </div>
                    ) : (
                      <button
                        type="button"
                        onClick={() => startEdit(f.id, pack, cell)}
                        className="group w-full text-left p-2 -m-2 rounded-md hover:bg-slate-100 transition-colors"
                      >
                        {cell ? (
                          <>
                            <div className="flex items-baseline gap-2">
                              <span
                                className={
                                  "font-semibold text-lg " +
                                  (cell.active
                                    ? "text-navy-950"
                                    : "text-slate-400 line-through")
                                }
                              >
                                {fmtEuros(cell.priceCents)}
                              </span>
                              {cell.compareAtCents && (
                                <span className="text-xs text-slate-400 line-through">
                                  {fmtEuros(cell.compareAtCents)}
                                </span>
                              )}
                            </div>
                            <div className="flex items-center gap-1.5 mt-0.5 text-[10px] text-slate-400 group-hover:text-gold-700 transition-colors">
                              <Pencil className="h-2.5 w-2.5" />
                              {cell.active ? "Modifier" : "Inactif — modifier"}
                            </div>
                          </>
                        ) : (
                          <div className="text-xs text-slate-400 italic">
                            <span className="block">Pas de prix</span>
                            <span className="text-[10px] text-gold-700 mt-0.5 inline-flex items-center gap-1 font-semibold not-italic">
                              <Pencil className="h-2.5 w-2.5" />
                              Définir
                            </span>
                          </div>
                        )}
                        {cellFeedback?.type === "ok" && (
                          <div className="text-[10px] text-emerald-700 mt-1 flex items-center gap-1 font-semibold">
                            <Check className="h-2.5 w-2.5" />
                            {cellFeedback.message}
                          </div>
                        )}
                      </button>
                    )}
                  </td>
                );
              })}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function errorLabel(code: string): string {
  const map: Record<string, string> = {
    not_authenticated: "Non authentifié",
    forbidden: "Accès refusé (admin uniquement)",
    invalid_pack: "Pack invalide",
    invalid_price: "Prix invalide (doit être > 0)",
    price_too_high: "Prix trop élevé (max 1 000 000 €)",
    compare_at_must_be_greater: "Le prix barré doit être supérieur",
    capacite_only_initial:
      "Capacité ≤ 3,5 t accepte uniquement le pack Initial",
    price_must_be_positive: "Prix invalide",
  };
  return map[code] || `Erreur : ${code}`;
}
