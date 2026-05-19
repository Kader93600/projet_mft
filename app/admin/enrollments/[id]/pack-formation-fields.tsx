"use client";

import { useMemo, useState } from "react";
import { Sparkles, Check, AlertTriangle, MessageCircle, Users } from "lucide-react";
import {
  PACK_SLUGS,
  fmtEuros,
  isPackAvailableForFormation,
  PACK_METADATA,
  type PackSlug,
} from "@/lib/packs";

interface FormationOpt {
  id: string;
  slug: string;
  code: string;
  title: string;
}

interface PriceEntry {
  formationSlug: string;
  pack: PackSlug;
  priceCents: number;
}

interface Props {
  /** Liste de toutes les formations actives (catalogue DB). */
  formations: FormationOpt[];
  /** Tous les prix actifs (formation × pack). */
  prices: PriceEntry[];
  /** Pack actuel de l'enrollment (DEFAULT 'initial'). */
  defaultPack: PackSlug;
  /** formation_id actuel (uuid) ou null si legacy. */
  defaultFormationId: string | null;
  /** Coût pédagogique actuel en centimes (pour montrer le suggéré). */
  currentAmountCents: number;
  /** Callback pour pré-remplir le champ "Coût pédagogique" parent. */
  totalAmountInputId: string;
}

/**
 * Bloc Formation + Pack pour l'éditeur admin d'enrollment.
 *
 * - Sélecteur de formation (option vide = legacy / non rattaché)
 * - Pack en radio horizontal (Initial / Medium / Premium) avec ring d'accent
 * - Si Capacité ≤ 3,5 t : seul Initial est sélectionnable (les autres
 *   sont visuellement désactivés ; le trigger DB sécurise côté serveur)
 * - Affiche le prix catalogue pour la combinaison choisie + bouton
 *   "Appliquer ce tarif" qui écrit dans le champ Coût pédagogique parent
 * - Bandeau d'alerte si la combinaison choisie n'a pas de prix actif
 */
export function PackFormationFields({
  formations,
  prices,
  defaultPack,
  defaultFormationId,
  currentAmountCents,
  totalAmountInputId,
}: Props) {
  const [formationId, setFormationId] = useState<string>(
    defaultFormationId ?? "",
  );
  const [pack, setPack] = useState<PackSlug>(defaultPack);

  const formation = useMemo(
    () => formations.find((f) => f.id === formationId),
    [formations, formationId],
  );

  const isCapacite = formation?.slug === "capacite-3-5t";

  // Si on passe à Capacité, force le pack à initial
  const onChangeFormation = (newId: string) => {
    setFormationId(newId);
    const newFormation = formations.find((f) => f.id === newId);
    if (newFormation?.slug === "capacite-3-5t" && pack !== "initial") {
      setPack("initial");
    }
  };

  // Prix catalogue pour la combinaison actuelle
  const catalogPriceCents = useMemo(() => {
    if (!formation) return null;
    const found = prices.find(
      (p) => p.formationSlug === formation.slug && p.pack === pack,
    );
    return found?.priceCents ?? null;
  }, [formation, pack, prices]);

  // Variant de prix : "match" si total enrollment = catalog, "diff" si écart
  const priceMatch = useMemo(() => {
    if (catalogPriceCents == null) return "no-price" as const;
    if (currentAmountCents === 0) return "to-fill" as const;
    if (currentAmountCents === catalogPriceCents) return "match" as const;
    return "diff" as const;
  }, [catalogPriceCents, currentAmountCents]);

  // Action : écrit le prix catalogue dans le champ "total_amount_euros" parent
  const applyCatalogPrice = () => {
    if (catalogPriceCents == null) return;
    const el = document.getElementById(totalAmountInputId) as
      | HTMLInputElement
      | null;
    if (!el) return;
    el.value = (catalogPriceCents / 100).toFixed(2);
    el.dispatchEvent(new Event("input", { bubbles: true }));
    // Focus + bref highlight visuel
    el.focus();
    el.classList.add("ring-2", "ring-signal-500", "transition");
    window.setTimeout(() => {
      el.classList.remove("ring-2", "ring-signal-500", "transition");
    }, 1200);
  };

  return (
    <div className="md:col-span-2 rounded-2xl border border-navy-100 bg-ivory p-5 space-y-4">
      <div className="flex items-center gap-2">
        <Sparkles className="h-4 w-4 text-signal-700" />
        <div className="font-display text-sm font-semibold text-navy-950">
          Formation & Pack
        </div>
      </div>

      <input type="hidden" name="formation_id" value={formationId} />
      <input type="hidden" name="pack" value={pack} />

      {/* Formation */}
      <div>
        <label
          htmlFor="formation-select"
          className="text-[11px] font-semibold uppercase tracking-wider text-slate-600 mb-1.5 block"
        >
          Formation
        </label>
        <select
          id="formation-select"
          value={formationId}
          onChange={(e) => onChangeFormation(e.target.value)}
          className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900"
        >
          <option value="">— Non rattaché —</option>
          {formations.map((f) => (
            <option key={f.id} value={f.id}>
              {f.code} — {f.title}
            </option>
          ))}
        </select>
      </div>

      {/* Pack — radio horizontal */}
      <div>
        <div className="text-[11px] font-semibold uppercase tracking-wider text-slate-600 mb-2">
          Pack
        </div>
        <div className="grid grid-cols-3 gap-2">
          {PACK_SLUGS.map((slug) => {
            const meta = PACK_METADATA[slug];
            const disabled =
              !!formation && !isPackAvailableForFormation(slug, formation.slug);
            const active = pack === slug;
            return (
              <button
                key={slug}
                type="button"
                disabled={disabled}
                aria-pressed={active}
                onClick={() => setPack(slug)}
                className={
                  "relative flex flex-col items-start gap-1 rounded-xl p-3 text-left border " +
                  "transition-all duration-200 motion-reduce:transition-none " +
                  (disabled
                    ? "border-navy-100 bg-slate-50 text-slate-400 cursor-not-allowed"
                    : active
                      ? "border-transparent bg-white shadow-soft"
                      : "border-navy-100 bg-white hover:border-navy-200 hover:-translate-y-0.5 motion-reduce:hover:transform-none")
                }
                style={
                  active && !disabled
                    ? {
                        boxShadow: `0 0 0 2px ${meta.accent}55, 0 8px 20px -10px ${meta.accent}55`,
                      }
                    : undefined
                }
              >
                <div className="flex items-center justify-between w-full">
                  <span
                    className="text-[10px] font-bold uppercase tracking-[0.14em]"
                    style={{
                      color: disabled ? "#94a3b8" : meta.accent,
                    }}
                  >
                    {meta.name}
                  </span>
                  {active && !disabled && (
                    <Check
                      className="h-3.5 w-3.5"
                      strokeWidth={3}
                      style={{ color: meta.accent }}
                    />
                  )}
                </div>
                <div className="text-[12px] text-slate-700 leading-snug">
                  {slug === "initial" && "Cours + IA"}
                  {slug === "medium" && (
                    <span className="inline-flex items-center gap-1">
                      <MessageCircle className="h-3 w-3" />
                      Formateur dédié
                    </span>
                  )}
                  {slug === "premium" && (
                    <span className="inline-flex items-center gap-1">
                      <Users className="h-3 w-3" />
                      Présentiel + Zoom
                    </span>
                  )}
                </div>
              </button>
            );
          })}
        </div>
        {isCapacite && (
          <p className="mt-2 text-[12px] text-slate-500 leading-relaxed">
            La Capacité ≤ 3,5 t n'accepte que le pack <strong>Initial</strong>{" "}
            (règle DB). Les autres packs sont désactivés pour cette formation.
          </p>
        )}
      </div>

      {/* Helper de prix catalogue */}
      {formationId && (
        <PriceHelper
          state={priceMatch}
          catalogPriceCents={catalogPriceCents}
          currentAmountCents={currentAmountCents}
          packName={PACK_METADATA[pack].name}
          onApply={applyCatalogPrice}
        />
      )}
    </div>
  );
}

// =====================================================================
// PriceHelper — bandeau d'aide selon l'état (match / diff / no-price)
// =====================================================================
function PriceHelper({
  state,
  catalogPriceCents,
  currentAmountCents,
  packName,
  onApply,
}: {
  state: "match" | "diff" | "to-fill" | "no-price";
  catalogPriceCents: number | null;
  currentAmountCents: number;
  packName: string;
  onApply: () => void;
}) {
  // État "no-price" : on n'affiche plus le bandeau d'avertissement
  // pour ne pas bruiter l'UI quand la matrice /admin/pricing n'est pas
  // remplie pour la combinaison choisie. L'admin saisit librement le
  // montant — c'est sa responsabilité de cohérence.
  if (state === "no-price") {
    return null;
  }

  if (state === "to-fill" && catalogPriceCents != null) {
    return (
      <div className="rounded-xl border border-signal-300 bg-signal-50/40 px-3.5 py-2.5 text-[13px] text-signal-900 flex items-center gap-3 flex-wrap">
        <Sparkles className="h-4 w-4 text-signal-700 shrink-0" />
        <span>
          Prix catalogue pack <strong>{packName}</strong>&nbsp;:{" "}
          <strong className="font-display">
            {fmtEuros(catalogPriceCents)}
          </strong>
        </span>
        <button
          type="button"
          onClick={onApply}
          className="ml-auto inline-flex items-center gap-1 text-[12px] font-semibold text-navy-950 bg-signal-500 hover:bg-signal-400 px-3 py-1 rounded-lg transition"
        >
          Appliquer ce tarif
        </button>
      </div>
    );
  }

  if (state === "match" && catalogPriceCents != null) {
    return (
      <div className="rounded-xl border border-emerald-200 bg-emerald-50/50 px-3.5 py-2.5 text-[13px] text-emerald-800 flex items-center gap-2">
        <Check className="h-4 w-4 shrink-0" strokeWidth={2.5} />
        <span>
          Coût conforme au catalogue ({fmtEuros(catalogPriceCents)} pour le
          pack {packName}).
        </span>
      </div>
    );
  }

  if (state === "diff" && catalogPriceCents != null) {
    const delta = currentAmountCents - catalogPriceCents;
    const direction = delta > 0 ? "supérieur" : "inférieur";
    return (
      <div className="rounded-xl border border-amber-200 bg-amber-50/60 px-3.5 py-2.5 text-[13px] text-amber-900 flex items-center gap-3 flex-wrap">
        <AlertTriangle className="h-4 w-4 text-amber-700 shrink-0" />
        <span>
          Coût pédagogique <strong>{direction}</strong> au prix catalogue (
          <strong>{fmtEuros(catalogPriceCents)}</strong> pour le pack{" "}
          {packName}, écart {fmtEuros(Math.abs(delta))}).
        </span>
        <button
          type="button"
          onClick={onApply}
          className="ml-auto inline-flex items-center gap-1 text-[12px] font-semibold text-navy-950 bg-amber-300 hover:bg-amber-400 px-3 py-1 rounded-lg transition"
        >
          Aligner sur le catalogue
        </button>
      </div>
    );
  }

  return null;
}
