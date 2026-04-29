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
            <div className="px-6 py-5 grid grid-cols-1 sm:grid-cols-2 gap-3">
              {filtered.map((f) => {
                const Icon = ICONS[f.iconName] ?? Truck;
                const active = chosenSlug === f.slug;
                return (
                  <button
                    key={f.slug}
                    type="button"
                    onClick={() => setChosenSlug(f.slug)}
                    className={
                      "text-left rounded-xl border-2 p-4 transition group " +
                      (active
                        ? "border-navy-900 bg-navy-50/40 shadow-soft"
                        : "border-navy-100 bg-white hover:border-navy-300")
                    }
                  >
                    <div className="flex items-start gap-3">
                      <div
                        className="h-10 w-10 rounded-xl flex items-center justify-center shrink-0"
                        style={{
                          background: `${f.accent}22`,
                          color: f.accent,
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
                            <Check className="h-3.5 w-3.5 text-emerald-600" />
                          )}
                        </div>
                        <div className="mt-0.5 font-semibold text-sm text-navy-900 leading-tight">
                          {f.title}
                        </div>
                        <div className="mt-1 text-xs text-slate-600 line-clamp-2">
                          {f.tagline}
                        </div>
                        <div className="mt-2 text-[11px] text-slate-500">
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
