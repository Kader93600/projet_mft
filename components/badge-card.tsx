"use client";
import { useEffect, useRef, useState } from "react";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import {
  Award,
  Sparkles,
  BookOpen,
  Library,
  Medal,
  ShieldCheck,
  Star,
  Trophy,
  Flame,
  Target,
  Zap,
  GraduationCap,
} from "lucide-react";

// Map EXPLICITE des icônes de badges (perf : `import * as Lucide`
// embarquait les ~1500 icônes du paquet dans le bundle de /reussites).
// Tout nom inconnu retombe sur Award.
const BADGE_ICONS: Record<string, React.ComponentType<{ className?: string }>> = {
  Award,
  Sparkles,
  BookOpen,
  Library,
  Medal,
  ShieldCheck,
  Star,
  Trophy,
  Flame,
  Target,
  Zap,
  GraduationCap,
};

function Icon({ name, className }: { name: string; className?: string }) {
  const C = BADGE_ICONS[name] ?? Award;
  return <C className={className} />;
}

const TIER_STYLES: Record<string, string> = {
  bronze: "bg-amber-50 text-amber-700 border-amber-200",
  silver: "bg-slate-50 text-slate-700 border-slate-200",
  gold: "bg-gold-50 text-gold-800 border-gold-200",
};

const TIER_GLOW: Record<string, string> = {
  bronze: "rgba(245,158,11,0.55)",
  silver: "rgba(148,163,184,0.55)",
  gold: "rgba(159,226,32,0.55)",
};

const TIER_LABEL: Record<string, string> = {
  bronze: "Bronze",
  silver: "Argent",
  gold: "Or",
};

/**
 * Carte de badge.
 *
 * Quand le badge passe de "non obtenu" à "obtenu" en live (par exemple suite
 * à un quiz réussi sur la même page), on déclenche une animation d'unlock :
 *  - bounce-in de l'icône (cubic-bezier overshoot)
 *  - flash signal autour de la card
 *  - particules confetti pendant ~700ms
 *
 * Pour les badges déjà obtenus à l'affichage initial, on joue une animation
 * d'entrée plus discrète (fade-up + scale léger).
 */
export function BadgeCard({
  badge,
  earned,
  earnedAt,
  progress,
}: {
  badge: {
    name: string;
    description: string | null;
    icon: string;
    tier: string;
    points: number;
    category: string;
  };
  earned: boolean;
  earnedAt?: string | null;
  /**
   * Progression vers le déblocage (badges non earned uniquement).
   * Si fourni et badge non earned : on remplace "À débloquer" par une
   * mini-barre + libellé "Quiz réussis 3 / 5" pour donner un objectif
   * visible au stagiaire.
   */
  progress?: {
    current: number;
    target: number;
    percent: number;
    label: string;
  } | null;
}) {
  const wasEarnedRef = useRef<boolean>(earned);
  const [justUnlocked, setJustUnlocked] = useState(false);

  useEffect(() => {
    // Détecte la transition false → true (ex : nouveau badge débloqué)
    if (!wasEarnedRef.current && earned) {
      setJustUnlocked(true);
      const t = window.setTimeout(() => setJustUnlocked(false), 1800);
      return () => window.clearTimeout(t);
    }
    wasEarnedRef.current = earned;
  }, [earned]);

  const glow = TIER_GLOW[badge.tier] ?? TIER_GLOW.bronze;

  return (
    <div className="relative">
      {/* Confettis quand badge fraîchement débloqué */}
      {justUnlocked && (
        <div
          aria-hidden
          className="absolute inset-0 pointer-events-none z-10 motion-reduce:hidden"
        >
          {[
            { l: "10%", t: "10%", c: "#9FE220", d: 0 },
            { l: "85%", t: "12%", c: "#2530D9", d: 0.05 },
            { l: "20%", t: "85%", c: "#9FE220", d: 0.1 },
            { l: "78%", t: "82%", c: "#2530D9", d: 0.15 },
            { l: "50%", t: "5%", c: "#9FE220", d: 0.2 },
            { l: "5%", t: "55%", c: "#2530D9", d: 0.25 },
            { l: "92%", t: "55%", c: "#9FE220", d: 0.3 },
          ].map((p, i) => (
            <span
              key={i}
              className="absolute h-1.5 w-1.5 rounded-full"
              style={{
                left: p.l,
                top: p.t,
                background: p.c,
                boxShadow: `0 0 8px ${p.c}`,
                animation: `float-slow 1.2s ease-out ${p.d}s both, fade-up 1.2s ease-out ${p.d}s both`,
              }}
            />
          ))}
        </div>
      )}

      <Card
        className={cn(
          "h-full relative overflow-hidden",
          "transition-[transform,box-shadow,filter,opacity] duration-500 ease-out",
          earned
            ? "shadow-soft hover:shadow-raised hover:-translate-y-0.5 motion-reduce:hover:translate-y-0"
            : "opacity-55 grayscale hover:grayscale-0 hover:opacity-80"
        )}
        style={
          justUnlocked
            ? {
                boxShadow: `0 0 0 2px ${glow}, 0 12px 36px -10px ${glow}`,
                animation: "badge-unlock 0.7s both",
              }
            : undefined
        }
      >
        {/* Glow tier en arrière-plan, visible uniquement si earned */}
        {earned && (
          <div
            aria-hidden
            className="absolute -top-12 -right-12 h-32 w-32 rounded-full pointer-events-none opacity-40"
            style={{
              background: `radial-gradient(circle, ${glow}, transparent 70%)`,
            }}
          />
        )}

        <CardBody className="relative flex flex-col items-start gap-3">
          <div
            className={cn(
              "h-12 w-12 rounded-xl flex items-center justify-center border",
              "transition-transform duration-500 ease-out",
              TIER_STYLES[badge.tier] ?? TIER_STYLES.bronze
            )}
            style={
              justUnlocked
                ? { animation: "badge-unlock 0.7s 0.05s both" }
                : undefined
            }
          >
            <Icon name={badge.icon} className="h-6 w-6" />
            {justUnlocked && (
              <Sparkles
                className="absolute -top-1.5 -right-1.5 h-4 w-4 text-signal-500 animate-glow-pulse motion-reduce:animate-none"
                aria-hidden
              />
            )}
          </div>
          <div className="flex items-center gap-2">
            <Badge
              tone={badge.tier === "gold" ? "gold" : "slate"}
              size="sm"
            >
              {TIER_LABEL[badge.tier] ?? badge.tier}
            </Badge>
            <span className="text-xs text-slate-500">+{badge.points} pts</span>
          </div>
          <div>
            <div className="font-display font-semibold text-navy-900 leading-tight">
              {badge.name}
            </div>
            {badge.description && (
              <p className="text-sm text-slate-600 mt-1 line-clamp-2">
                {badge.description}
              </p>
            )}
          </div>
          {earned && earnedAt && (
            <div className="text-[11px] text-slate-500 mt-auto">
              Obtenu le{" "}
              {new Date(earnedAt).toLocaleDateString("fr-FR", {
                day: "2-digit",
                month: "short",
                year: "numeric",
              })}
            </div>
          )}
          {!earned && progress && progress.target > 0 && (
            <div className="w-full mt-auto pt-2 space-y-1.5">
              <div className="flex items-center justify-between text-[11px]">
                <span className="text-slate-500">{progress.label}</span>
                <span className="text-slate-700 font-medium tabular-nums">
                  {progress.current} / {progress.target}
                </span>
              </div>
              <div className="h-1 rounded-full bg-slate-100 overflow-hidden">
                <div
                  className="h-full bg-gradient-to-r from-gold-400 to-gold-600 transition-all duration-500"
                  style={{ width: `${progress.percent}%` }}
                />
              </div>
            </div>
          )}
          {!earned && !progress && (
            <div className="text-[11px] text-slate-400 mt-auto inline-flex items-center gap-1.5">
              <span className="h-1 w-1 rounded-full bg-slate-300" />
              À débloquer
            </div>
          )}
        </CardBody>
      </Card>
    </div>
  );
}
