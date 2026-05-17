"use client";

// =====================================================================
// Composant client invisible monté dans AuthLayout.
//
// Au premier mount de la session navigateur :
//   - POST /api/streak/checkin → la RPC `award_daily_login_xp` octroie
//     +5 XP (1 fois/jour) et un bonus streak si le stagiaire enchaîne
//     ≥ 3 jours consécutifs.
//   - Si du XP a été ajouté, on affiche un toast doré flottant pendant
//     ~6 s pour célébrer la régularité.
//
// Antifragile :
//   - sessionStorage évite de re-checker plusieurs fois dans le même
//     onglet (navigation interne = pas de nouvel appel).
//   - L'erreur réseau est silencieuse.
//   - La RPC est idempotente côté serveur (xp_events.ref_id = today).
// =====================================================================

import { useEffect, useState } from "react";
import { Flame, Sparkles, X } from "lucide-react";

const SESSION_KEY = "mft.daily-checkin.v1";

type CheckinResult = {
  awarded_login: number;
  awarded_streak: number;
  current_streak: number;
  longest_streak: number;
};

export function DailyCheckin() {
  const [reward, setReward] = useState<CheckinResult | null>(null);
  const [closing, setClosing] = useState(false);

  useEffect(() => {
    // Déjà checké dans cet onglet ? On ne refait pas l'appel.
    if (typeof window === "undefined") return;
    if (sessionStorage.getItem(SESSION_KEY)) return;
    sessionStorage.setItem(SESSION_KEY, "1");

    const ac = new AbortController();
    fetch("/api/streak/checkin", { method: "POST", signal: ac.signal })
      .then((r) => (r.ok ? r.json() : null))
      .then((data: CheckinResult | null) => {
        if (!data) return;
        // On affiche seulement si quelque chose a été octroyé aujourd'hui.
        if (data.awarded_login === 0 && data.awarded_streak === 0) return;
        setReward(data);
        // Auto-close après 6 s
        setTimeout(() => setClosing(true), 6_000);
        setTimeout(() => setReward(null), 6_400);
      })
      .catch(() => {
        // silencieux
      });

    return () => ac.abort();
  }, []);

  if (!reward) return null;

  const totalAwarded = reward.awarded_login + reward.awarded_streak;
  const hasStreakBonus = reward.awarded_streak > 0;

  return (
    <div
      role="status"
      aria-live="polite"
      className={[
        "fixed bottom-6 right-6 z-[100]",
        "flex items-start gap-3 rounded-2xl border border-gold-300 bg-gradient-to-br from-gold-50 to-amber-50",
        "shadow-raised px-4 py-3 pr-10 min-w-[300px] max-w-sm",
        "transition-all duration-400",
        closing ? "translate-y-2 opacity-0" : "translate-y-0 opacity-100",
      ].join(" ")}
      style={{ transitionTimingFunction: "cubic-bezier(0.19, 1, 0.22, 1)" }}
    >
      <div className="h-9 w-9 rounded-xl bg-gold-500 text-navy-900 flex items-center justify-center shrink-0">
        {hasStreakBonus ? (
          <Flame className="h-4 w-4" />
        ) : (
          <Sparkles className="h-4 w-4" />
        )}
      </div>

      <div className="flex-1 min-w-0">
        <div className="font-display text-sm font-semibold text-navy-900">
          {hasStreakBonus
            ? `Série de ${reward.current_streak} jours !`
            : "Bienvenue, voici votre bonus du jour"}
        </div>
        <div className="text-xs text-slate-700 mt-0.5">
          +{totalAwarded} XP
          {hasStreakBonus && (
            <span className="text-gold-700 font-medium">
              {" "}
              · dont +{reward.awarded_streak} XP de série
            </span>
          )}
        </div>
      </div>

      <button
        onClick={() => {
          setClosing(true);
          setTimeout(() => setReward(null), 400);
        }}
        aria-label="Fermer"
        className="absolute right-2 top-2 text-slate-500 hover:text-navy-900 transition-colors"
      >
        <X className="h-3.5 w-3.5" />
      </button>
    </div>
  );
}
