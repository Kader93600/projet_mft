"use client";
import { useState, useTransition, useMemo } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { renderMarkdown } from "@/lib/markdown";
import { acceptDocument, selectFormation, completeOnboarding } from "./actions";
import { FormationStripe } from "@/components/formation/formation-stripe";
import { FormationBadge } from "@/components/formation/formation-badge";
import {
  FileSignature,
  Gavel,
  BookOpen,
  Check,
  Loader2,
  Sparkles,
  ArrowRight,
  ShieldCheck,
  Truck,
  Bus,
  GraduationCap,
  Car,
  Briefcase,
  Package,
  Award,
  Compass,
} from "lucide-react";

const META: Record<string, { icon: any; label: string; sub: string }> = {
  convention: {
    icon: FileSignature,
    label: "Convention de formation",
    sub: "Document contractuel entre vous et l'organisme",
  },
  reglement: {
    icon: Gavel,
    label: "Règlement intérieur",
    sub: "Règles applicables pendant la formation",
  },
  livret: {
    icon: BookOpen,
    label: "Livret d'accueil",
    sub: "Informations pratiques sur votre parcours",
  },
};

const ICONS: Record<string, any> = {
  Truck,
  Bus,
  GraduationCap,
  Car,
  Briefcase,
  Package,
  Award,
  ShieldCheck,
};

type DocStep = {
  id: string;
  type: string;
  title: string;
  version: number;
  content_md: string;
  accepted: boolean;
};

type CatalogItem = {
  slug: string;
  code: string;
  title: string;
  tagline: string;
  accent: string;
  iconName: string;
  category: string;
  duration: string;
};

export function OnboardingWizard({
  firstName,
  steps,
  catalog,
  selectedSlug,
}: {
  firstName: string;
  steps: DocStep[];
  catalog: CatalogItem[];
  selectedSlug: string | null;
}) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [err, setErr] = useState<string | null>(null);
  const [localAccepted, setLocalAccepted] = useState<Record<string, boolean>>(
    () => Object.fromEntries(steps.map((s) => [s.id, s.accepted]))
  );
  const [checked, setChecked] = useState(false);
  const [chosenSlug, setChosenSlug] = useState<string | null>(selectedSlug);
  const [filter, setFilter] = useState<string>("all");

  // Étapes ordonnées : 1) formation 2) docs 3) confirmation
  const formationDone = !!chosenSlug;
  const firstUnsignedDocIdx = steps.findIndex((s) => !localAccepted[s.id]);
  const allDocsDone = steps.length === 0 || firstUnsignedDocIdx === -1;

  // Index global : 0 = formation, 1..N = docs, N+1 = confirmation
  let stage: "formation" | "doc" | "done";
  if (!formationDone) stage = "formation";
  else if (!allDocsDone) stage = "doc";
  else stage = "done";

  // Total steps for the stepper visualization
  const totalSteps = 1 + steps.length + 1;
  const currentGlobalIdx =
    stage === "formation"
      ? 0
      : stage === "doc"
      ? 1 + firstUnsignedDocIdx
      : totalSteps - 1;

  const currentDoc = stage === "doc" ? steps[firstUnsignedDocIdx] : null;

  // ──────────────────────────────────────────────────────────────────
  // Étape 1 : Sélection formation
  // ──────────────────────────────────────────────────────────────────
  const categories = useMemo(() => {
    const set = new Set(catalog.map((c) => c.category));
    return ["all", ...Array.from(set)];
  }, [catalog]);

  const filtered =
    filter === "all" ? catalog : catalog.filter((c) => c.category === filter);

  const confirmFormation = () => {
    if (!chosenSlug) return;
    setErr(null);
    start(async () => {
      try {
        await selectFormation({ slug: chosenSlug });
      } catch (e: any) {
        setErr(e.message);
      }
    });
  };

  // ──────────────────────────────────────────────────────────────────
  // Étape 2 : Documents
  // ──────────────────────────────────────────────────────────────────
  const acceptCurrent = () => {
    if (!currentDoc) return;
    setErr(null);
    start(async () => {
      try {
        await acceptDocument({ document_id: currentDoc.id });
        setLocalAccepted((s) => ({ ...s, [currentDoc.id]: true }));
        setChecked(false);
      } catch (e: any) {
        setErr(e.message);
      }
    });
  };

  // ──────────────────────────────────────────────────────────────────
  // Étape 3 : Finalisation
  // ──────────────────────────────────────────────────────────────────
  const finish = () => {
    setErr(null);
    start(async () => {
      try {
        await completeOnboarding();
        router.push("/dashboard");
      } catch (e: any) {
        setErr(e.message);
      }
    });
  };

  // ════════════════════════════════════════════════════════════════════
  // RENDER
  // ════════════════════════════════════════════════════════════════════
  return (
    <div className="max-w-4xl mx-auto">
      {chosenSlug && <FormationStripe slug={chosenSlug} />}

      <div className="space-y-6 pt-6">
        {/* Header */}
        <div>
          <div className="flex items-center gap-2">
            <Sparkles className="h-4 w-4 text-gold-700" />
            <span className="eyebrow text-gold-700">Entrée en formation</span>
          </div>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Bienvenue, {firstName} 👋
          </h1>
          <p className="mt-2 text-slate-600 text-sm max-w-2xl">
            Trois étapes rapides pour démarrer : choisir votre formation, signer
            les documents d'entrée, puis accéder à votre espace personnalisé.
          </p>
        </div>

        {/* Stepper compact */}
        <div className="flex items-center gap-2">
          {[
            { label: "Formation", done: formationDone },
            ...steps.map((s) => ({
              label: META[s.type]?.label ?? s.title,
              done: localAccepted[s.id],
            })),
            { label: "Démarrer", done: false },
          ].map((step, i) => {
            const active = i === currentGlobalIdx;
            return (
              <div key={i} className="flex items-center gap-2 flex-1">
                <div
                  className={
                    "h-9 w-9 rounded-xl flex items-center justify-center text-sm font-semibold shrink-0 " +
                    (step.done
                      ? "bg-emerald-500 text-white"
                      : active
                      ? "bg-navy-900 text-white"
                      : "bg-navy-50 text-slate-500")
                  }
                >
                  {step.done ? <Check className="h-4 w-4" /> : i + 1}
                </div>
                <div className="hidden sm:block flex-1 min-w-0">
                  <div className="text-xs font-semibold text-navy-900 truncate">
                    {step.label}
                  </div>
                </div>
                {i < totalSteps - 1 && (
                  <div className="hidden sm:block h-px flex-1 bg-navy-100" />
                )}
              </div>
            );
          })}
        </div>

        {/* ÉTAPE 1 — Sélection de formation */}
        {stage === "formation" && (
          <div className="rounded-2xl bg-white border border-navy-100 shadow-soft overflow-hidden">
            <div className="px-6 py-4 border-b border-navy-50 flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-navy-50 text-navy-800 flex items-center justify-center">
                <Compass className="h-4 w-4" />
              </div>
              <div>
                <div className="font-display font-semibold text-navy-900">
                  Choisissez votre formation
                </div>
                <div className="text-xs text-slate-500">
                  Cette sélection adapte vos modules, examens et tableau de bord.
                </div>
              </div>
            </div>

            {/* Filtres catégories */}
            <div className="px-6 pt-4 flex flex-wrap gap-2">
              {categories.map((c) => (
                <button
                  key={c}
                  onClick={() => setFilter(c)}
                  className={
                    "px-3 py-1.5 rounded-full text-xs font-medium border transition " +
                    (filter === c
                      ? "bg-navy-900 text-white border-navy-900"
                      : "bg-white text-slate-600 border-navy-100 hover:bg-navy-50")
                  }
                >
                  {c === "all" ? "Toutes" : c}
                </button>
              ))}
            </div>

            {/* Cards formations */}
            <div
              key={filter /* re-stagger quand le filtre change */}
              className="px-6 py-5 grid grid-cols-1 sm:grid-cols-2 gap-3"
            >
              {filtered.map((f, i) => {
                const Icon = ICONS[f.iconName] ?? Truck;
                const active = chosenSlug === f.slug;
                return (
                  <button
                    key={f.slug}
                    type="button"
                    onClick={() => setChosenSlug(f.slug)}
                    aria-pressed={active}
                    style={{
                      animation: "fade-up 0.55s cubic-bezier(0.22, 1, 0.36, 1) both",
                      animationDelay: `${Math.min(i, 8) * 60}ms`,
                      // Variable CSS pour réutiliser l'accent partout sur la card
                      ["--accent" as any]: f.accent,
                    }}
                    className={
                      "relative text-left rounded-2xl border-2 p-4 group overflow-hidden " +
                      "transition-[transform,box-shadow,border-color,background] duration-300 ease-out " +
                      "motion-reduce:transition-none motion-reduce:!animate-none " +
                      (active
                        ? "border-[var(--accent)] bg-white shadow-raised -translate-y-0.5"
                        : "border-navy-100 bg-white hover:-translate-y-1 hover:shadow-raised hover:border-[var(--accent)] motion-reduce:hover:translate-y-0")
                    }
                  >
                    {/* Halo radial qui s'allume sur hover/active */}
                    <div
                      aria-hidden
                      className={
                        "absolute inset-0 rounded-2xl pointer-events-none transition-opacity duration-500 " +
                        (active ? "opacity-100" : "opacity-0 group-hover:opacity-100")
                      }
                      style={{
                        background: `radial-gradient(120% 80% at 0% 0%, ${f.accent}1A 0%, transparent 55%)`,
                      }}
                    />
                    {/* Trait accent vertical à gauche, animé */}
                    <span
                      aria-hidden
                      className={
                        "absolute left-0 top-3 bottom-3 w-[3px] rounded-r-full transition-all duration-300 ease-out " +
                        (active
                          ? "opacity-100 scale-y-100"
                          : "opacity-0 scale-y-50 group-hover:opacity-80 group-hover:scale-y-100")
                      }
                      style={{ background: f.accent, transformOrigin: "center" }}
                    />

                    <div className="relative flex items-start gap-3">
                      <div
                        className={
                          "h-11 w-11 rounded-xl flex items-center justify-center shrink-0 " +
                          "transition-transform duration-300 ease-out " +
                          (active
                            ? "scale-105"
                            : "group-hover:scale-105 motion-reduce:group-hover:scale-100")
                        }
                        style={{
                          background: `${f.accent}1F`,
                          color: f.accent,
                          boxShadow: active
                            ? `0 8px 24px -10px ${f.accent}66`
                            : undefined,
                        }}
                      >
                        <Icon className="h-5 w-5" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2">
                          <span
                            className="text-[10px] font-bold uppercase tracking-wider"
                            style={{ color: f.accent }}
                          >
                            {f.code}
                          </span>
                          {active && (
                            <Check
                              className="h-3.5 w-3.5"
                              style={{ color: f.accent }}
                            />
                          )}
                        </div>
                        <div className="mt-0.5 font-semibold text-[15px] text-navy-900 leading-snug">
                          {f.title}
                        </div>
                        <div className="mt-1 text-xs text-slate-600 line-clamp-2 leading-relaxed">
                          {f.tagline}
                        </div>
                        <div className="mt-2 text-[11px] uppercase tracking-wider text-slate-400 font-medium">
                          {f.duration}
                        </div>
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>

            {err && (
              <div className="px-6 pb-3 text-sm text-rose-700">{err}</div>
            )}

            <div className="px-6 py-4 bg-white border-t border-navy-50 flex items-center justify-between">
              <div className="text-xs text-slate-500">
                Étape 1 sur {totalSteps}
              </div>
              <Button
                onClick={confirmFormation}
                disabled={!chosenSlug || pending}
                variant="gold"
              >
                {pending ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" /> Inscription…
                  </>
                ) : (
                  <>
                    Confirmer ma formation
                    <ArrowRight className="h-4 w-4" />
                  </>
                )}
              </Button>
            </div>
          </div>
        )}

        {/* ÉTAPE 2 — Document courant */}
        {stage === "doc" && currentDoc && (
          <div className="rounded-2xl bg-white border border-navy-100 shadow-soft overflow-hidden">
            <div className="px-6 py-4 border-b border-navy-50 flex items-center gap-3">
              {chosenSlug && (
                <FormationBadge slug={chosenSlug} size="sm" icon variant="soft" />
              )}
              <div className="flex-1">
                <div className="font-display font-semibold text-navy-900">
                  {currentDoc.title}
                </div>
                <div className="text-xs text-slate-500">
                  Version {currentDoc.version} ·{" "}
                  {META[currentDoc.type]?.sub ?? ""}
                </div>
              </div>
            </div>

            <div className="px-6 py-5 max-h-[440px] overflow-y-auto bg-slate-50/60">
              <div
                className="prose-lesson text-sm"
                dangerouslySetInnerHTML={{
                  __html: renderMarkdown(currentDoc.content_md),
                }}
              />
            </div>

            <div className="px-6 py-4 bg-white border-t border-navy-50">
              <label className="flex items-start gap-3 cursor-pointer select-none">
                <input
                  type="checkbox"
                  checked={checked}
                  onChange={(e) => setChecked(e.target.checked)}
                  className="mt-0.5 h-4 w-4 accent-gold-500"
                />
                <span className="text-sm text-navy-900">
                  J'ai lu et j'accepte le document{" "}
                  <span className="font-semibold">{currentDoc.title}</span>{" "}
                  (version {currentDoc.version}). Je reconnais que mon
                  acceptation vaut signature électronique et sera horodatée.
                </span>
              </label>

              {err && <div className="mt-3 text-sm text-rose-700">{err}</div>}

              <div className="mt-4 flex items-center justify-between">
                <div className="text-xs text-slate-500">
                  Étape {currentGlobalIdx + 1} sur {totalSteps}
                </div>
                <Button
                  onClick={acceptCurrent}
                  disabled={!checked || pending}
                  variant="gold"
                >
                  {pending ? (
                    <>
                      <Loader2 className="h-4 w-4 animate-spin" /> Signature…
                    </>
                  ) : (
                    <>
                      Signer et continuer
                      <ArrowRight className="h-4 w-4" />
                    </>
                  )}
                </Button>
              </div>
            </div>
          </div>
        )}

        {/* ÉTAPE 3 — Confirmation finale */}
        {stage === "done" && (
          <div className="rounded-2xl bg-white border border-navy-100 shadow-soft p-8 text-center space-y-5">
            <div className="mx-auto h-16 w-16 rounded-2xl bg-gradient-to-br from-gold-400 to-gold-500 flex items-center justify-center shadow-soft">
              <ShieldCheck className="h-7 w-7 text-navy-900" />
            </div>
            <div>
              <span className="eyebrow text-gold-700">Onboarding terminé</span>
              <h2 className="mt-2 font-display text-2xl font-semibold text-navy-950">
                Tout est prêt, {firstName}.
              </h2>
              <p className="mt-2 text-slate-600 text-sm">
                Votre formation est sélectionnée, vos documents sont signés et
                archivés. Votre dashboard a été personnalisé.
              </p>
              {chosenSlug && (
                <div className="mt-4 flex justify-center">
                  <FormationBadge
                    slug={chosenSlug}
                    size="md"
                    icon
                    withTitle
                    variant="soft"
                  />
                </div>
              )}
            </div>

            {err && <div className="text-sm text-rose-700">{err}</div>}

            <Button
              onClick={finish}
              disabled={pending}
              variant="gold"
              size="lg"
            >
              {pending ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" /> Préparation…
                </>
              ) : (
                <>
                  Accéder à mon dashboard
                  <ArrowRight className="h-4 w-4" />
                </>
              )}
            </Button>
          </div>
        )}
      </div>
    </div>
  );
}
