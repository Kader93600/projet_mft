"use client";

import { useEffect, useState } from "react";
import { BarChart3, Check, AlertCircle } from "lucide-react";
import {
  isTrackingEnabled,
  optInTracking,
  optOutTracking,
} from "@/lib/analytics";

/**
 * Bandeau RGPD pour basculer le tracking analytics (PostHog) on/off.
 * Doit être placé dans /mes-donnees (page RGPD du stagiaire).
 *
 * État persistant dans le localStorage côté navigateur (géré par PostHog).
 */
export function AnalyticsOptOutToggle() {
  const [enabled, setEnabled] = useState<boolean | null>(null);

  useEffect(() => {
    // PostHog n'est pas dispo en SSR → on lit l'état au mount.
    setEnabled(isTrackingEnabled());
  }, []);

  function toggle() {
    if (enabled) {
      optOutTracking();
      setEnabled(false);
    } else {
      optInTracking();
      setEnabled(true);
    }
  }

  if (enabled === null) {
    return null; // évite un flicker au premier render
  }

  return (
    <div className="rounded-2xl border border-navy-100 bg-white p-5">
      <div className="flex items-start gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-50 text-brand-700 flex items-center justify-center shrink-0">
          <BarChart3 className="h-5 w-5" />
        </div>
        <div className="flex-1 min-w-0">
          <h3 className="font-display text-base font-semibold text-navy-950">
            Mesure d'audience pédagogique
          </h3>
          <p className="text-sm text-slate-600 mt-1 leading-relaxed">
            Nous mesurons votre progression (leçons consultées, quiz passés,
            modules terminés) pour améliorer le parcours pédagogique. Les
            données sont hébergées en Europe (Francfort, Allemagne), votre
            adresse IP est anonymisée et nous ne partageons jamais vos
            informations avec des tiers.
          </p>
          <div className="mt-4 flex items-center gap-3 flex-wrap">
            <button
              type="button"
              onClick={toggle}
              className={
                "inline-flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-semibold transition " +
                (enabled
                  ? "bg-signal-500/15 text-signal-800 border border-signal-500/30 hover:bg-signal-500/25"
                  : "bg-rose-50 text-rose-800 border border-rose-200 hover:bg-rose-100")
              }
            >
              {enabled ? (
                <>
                  <Check className="h-4 w-4" />
                  Mesure d'audience activée
                </>
              ) : (
                <>
                  <AlertCircle className="h-4 w-4" />
                  Mesure d'audience désactivée
                </>
              )}
            </button>
            <span className="text-xs text-slate-500">
              Cliquez pour {enabled ? "désactiver" : "réactiver"}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}
