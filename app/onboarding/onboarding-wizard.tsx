"use client";
import { useState, useTransition, useMemo } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { renderMarkdown } from "@/lib/markdown";
import { acceptDocument } from "./actions";
import {
  FileSignature,
  Gavel,
  BookOpen,
  Check,
  Loader2,
  Sparkles,
  ArrowRight,
  ShieldCheck,
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

type Step = {
  id: string;
  type: string;
  title: string;
  version: number;
  content_md: string;
  accepted: boolean;
};

export function OnboardingWizard({
  firstName,
  steps,
}: {
  firstName: string;
  steps: Step[];
}) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [err, setErr] = useState<string | null>(null);
  const [localAccepted, setLocalAccepted] = useState<Record<string, boolean>>(
    () => Object.fromEntries(steps.map((s) => [s.id, s.accepted]))
  );
  const [checked, setChecked] = useState(false);

  // Index de l'étape en cours : 1ère non acceptée, ou "done" sinon
  const currentIndex = useMemo(() => {
    const i = steps.findIndex((s) => !localAccepted[s.id]);
    return i === -1 ? steps.length : i;
  }, [steps, localAccepted]);

  const current = steps[currentIndex];
  const allDone = currentIndex >= steps.length;

  const acceptCurrent = () => {
    if (!current) return;
    setErr(null);
    start(async () => {
      try {
        await acceptDocument({ document_id: current.id });
        setLocalAccepted((s) => ({ ...s, [current.id]: true }));
        setChecked(false);
        // Si c'était le dernier, redirection dans l'effet
      } catch (e: any) {
        setErr(e.message);
      }
    });
  };

  if (allDone) {
    return (
      <div className="max-w-xl mx-auto pt-10 space-y-6 text-center">
        <div className="mx-auto h-16 w-16 rounded-2xl bg-gradient-to-br from-gold-400 to-gold-500 flex items-center justify-center shadow-soft">
          <ShieldCheck className="h-7 w-7 text-navy-900" />
        </div>
        <div>
          <span className="eyebrow text-gold-700">Onboarding terminé</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Tout est prêt, {firstName}.
          </h1>
          <p className="mt-2 text-slate-600">
            Vos documents sont signés et archivés. Vous pouvez commencer la
            formation.
          </p>
        </div>
        <Button
          onClick={() => router.push("/dashboard")}
          variant="gold"
          size="lg"
        >
          Accéder au dashboard
          <ArrowRight className="h-4 w-4" />
        </Button>
      </div>
    );
  }

  const meta = META[current.type] || {
    icon: FileSignature,
    label: current.title,
    sub: "",
  };
  const Icon = meta.icon;

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      {/* Header + progression */}
      <div>
        <div className="flex items-center gap-2">
          <Sparkles className="h-4 w-4 text-gold-700" />
          <span className="eyebrow text-gold-700">Entrée en formation</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Bienvenue, {firstName} — quelques documents à valider
        </h1>
        <p className="mt-2 text-slate-600 text-sm">
          Avant de commencer, merci de lire et accepter les documents
          suivants. Votre signature électronique est horodatée et archivée.
        </p>
      </div>

      {/* Stepper */}
      <div className="flex items-center gap-2">
        {steps.map((s, i) => {
          const done = localAccepted[s.id];
          const active = i === currentIndex;
          return (
            <div key={s.id} className="flex items-center gap-2 flex-1">
              <div
                className={
                  "h-9 w-9 rounded-xl flex items-center justify-center text-sm font-semibold shrink-0 " +
                  (done
                    ? "bg-emerald-500 text-white"
                    : active
                    ? "bg-navy-900 text-white"
                    : "bg-navy-50 text-slate-500")
                }
              >
                {done ? <Check className="h-4 w-4" /> : i + 1}
              </div>
              <div className="hidden sm:block flex-1 min-w-0">
                <div className="text-xs font-semibold text-navy-900 truncate">
                  {META[s.type]?.label ?? s.title}
                </div>
                {done && (
                  <div className="text-[10px] text-emerald-700 font-medium">
                    Signé
                  </div>
                )}
              </div>
              {i < steps.length - 1 && (
                <div className="hidden sm:block h-px flex-1 bg-navy-100" />
              )}
            </div>
          );
        })}
      </div>

      {/* Carte document courant */}
      <div className="rounded-2xl bg-white border border-navy-100 shadow-soft overflow-hidden">
        <div className="px-6 py-4 border-b border-navy-50 flex items-center gap-3">
          <div className="h-10 w-10 rounded-xl bg-navy-50 text-navy-800 flex items-center justify-center">
            <Icon className="h-4 w-4" />
          </div>
          <div>
            <div className="font-display font-semibold text-navy-900">
              {current.title}
            </div>
            <div className="text-xs text-slate-500">
              Version {current.version} · {meta.sub}
            </div>
          </div>
        </div>

        {/* Contenu scrollable */}
        <div className="px-6 py-5 max-h-[440px] overflow-y-auto bg-slate-50/60">
          <div
            className="prose-lesson text-sm"
            dangerouslySetInnerHTML={{
              __html: renderMarkdown(current.content_md),
            }}
          />
        </div>

        {/* Acceptation */}
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
              <span className="font-semibold">{current.title}</span> (version{" "}
              {current.version}). Je reconnais que mon acceptation vaut
              signature électronique et sera horodatée.
            </span>
          </label>

          {err && (
            <div className="mt-3 text-sm text-rose-700">{err}</div>
          )}

          <div className="mt-4 flex items-center justify-between">
            <div className="text-xs text-slate-500">
              Étape {currentIndex + 1} sur {steps.length}
            </div>
            <Button
              onClick={acceptCurrent}
              disabled={!checked || pending}
              variant="gold"
            >
              {pending ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" /> Signature en cours…
                </>
              ) : currentIndex === steps.length - 1 ? (
                <>
                  Terminer l'onboarding
                  <Check className="h-4 w-4" />
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
    </div>
  );
}
