"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { renderMarkdown } from "@/lib/markdown";
import { SignaturePad } from "@/components/signature-pad";
import { submitMandatorySignature } from "./actions";
import {
  ShieldCheck,
  ChevronDown,
  Loader2,
  AlertCircle,
  CheckCircle2,
  PenLine,
} from "lucide-react";

type Doc = {
  id: string;
  type: string;
  title: string;
  version: number;
  content_md: string;
};

export function SignatureFlow({
  docs,
  fullName,
}: {
  docs: Doc[];
  fullName: string;
}) {
  const router = useRouter();
  const [checked, setChecked] = useState<Record<string, boolean>>({});
  const [signature, setSignature] = useState<string | null>(null);
  const [pending, start] = useTransition();
  const [err, setErr] = useState<string | null>(null);

  const acceptedCount = docs.filter((d) => checked[d.id]).length;
  const allChecked = docs.length > 0 && acceptedCount === docs.length;
  const ready = allChecked && !!signature;

  function submit() {
    setErr(null);
    if (!allChecked) {
      setErr("Veuillez lire et accepter chacun des documents.");
      return;
    }
    if (!signature) {
      setErr("Veuillez apposer votre signature ci-dessus.");
      return;
    }
    start(async () => {
      const res = await submitMandatorySignature(signature);
      if (!res.ok) {
        setErr(res.error ?? "Une erreur est survenue.");
        return;
      }
      router.push("/dashboard");
      router.refresh();
    });
  }

  return (
    <div className="space-y-6">
      {/* En-tête rassurant */}
      <div className="rounded-2xl border border-navy-100 bg-white p-6 shadow-soft">
        <div className="flex items-start gap-4">
          <span className="h-12 w-12 rounded-2xl bg-gradient-to-br from-signal-300 to-signal-500 text-night-900 flex items-center justify-center shrink-0 shadow-glow-signal">
            <ShieldCheck className="h-6 w-6" />
          </span>
          <div>
            <span className="eyebrow text-signal-700">Étape obligatoire</span>
            <h1 className="mt-1 font-display text-2xl md:text-3xl font-semibold text-navy-950 tracking-tight">
              Signez vos documents d'entrée en formation
            </h1>
            <p className="mt-2 text-slate-600 text-[15px] leading-relaxed">
              Avant d'accéder à votre espace, merci de lire et de signer les
              documents ci-dessous. Votre signature est{" "}
              <strong className="text-navy-900">horodatée et sécurisée</strong>,
              conservée comme preuve, et réutilisée pour vos émargements de
              présence.
            </p>
          </div>
        </div>

        {/* Progression */}
        <div className="mt-5 flex items-center gap-3">
          <div className="h-2 flex-1 rounded-full bg-navy-50 overflow-hidden">
            <div
              className="h-full rounded-full bg-signal-500 transition-[width] duration-300 ease-premium"
              style={{
                width: `${docs.length ? (acceptedCount / docs.length) * 100 : 0}%`,
              }}
            />
          </div>
          <span className="text-xs font-medium text-slate-500 tabular-nums">
            {acceptedCount} / {docs.length} accepté
            {acceptedCount > 1 ? "s" : ""}
          </span>
        </div>
      </div>

      {/* Documents */}
      {docs.map((d, i) => {
        const isChecked = !!checked[d.id];
        return (
          <div
            key={d.id}
            className={
              "rounded-2xl border bg-white transition-colors " +
              (isChecked ? "border-signal-300" : "border-navy-100")
            }
          >
            <div className="px-6 pt-5 pb-3 border-b border-navy-50 flex items-center gap-3">
              <span className="h-8 w-8 rounded-lg bg-navy-50 text-navy-700 flex items-center justify-center text-sm font-semibold shrink-0">
                {isChecked ? (
                  <CheckCircle2 className="h-4 w-4 text-emerald-600" />
                ) : (
                  i + 1
                )}
              </span>
              <div className="flex-1 min-w-0">
                <div className="font-display font-semibold text-navy-900">
                  {d.title}
                </div>
                <div className="text-xs text-slate-500">Version {d.version}</div>
              </div>
            </div>
            <div className="px-6 py-4">
              <details className="group" open={i === 0}>
                <summary className="cursor-pointer text-sm font-medium text-navy-900 hover:text-signal-700 list-none inline-flex items-center gap-1.5">
                  <ChevronDown className="h-4 w-4 transition-transform group-open:rotate-180" />
                  Lire le document
                </summary>
                <div
                  className="prose-lesson text-sm mt-4 max-h-[380px] overflow-y-auto bg-slate-50/60 p-4 rounded-xl border border-navy-50"
                  dangerouslySetInnerHTML={{
                    __html: renderMarkdown(d.content_md),
                  }}
                />
              </details>

              <label className="mt-4 flex items-start gap-3 cursor-pointer select-none">
                <input
                  type="checkbox"
                  checked={isChecked}
                  onChange={(e) =>
                    setChecked((s) => ({ ...s, [d.id]: e.target.checked }))
                  }
                  className="mt-0.5 h-4 w-4 accent-signal-500"
                />
                <span className="text-sm text-navy-900">
                  J'ai lu et j'accepte{" "}
                  <span className="font-semibold">{d.title}</span> (version{" "}
                  {d.version}).
                </span>
              </label>
            </div>
          </div>
        );
      })}

      {/* Signature */}
      <div className="rounded-2xl border border-navy-100 bg-white p-6 shadow-soft">
        <h2 className="font-display text-lg font-semibold text-navy-900 inline-flex items-center gap-2">
          <PenLine className="h-5 w-5 text-signal-700" />
          Votre signature
        </h2>
        <p className="text-sm text-slate-600 mt-1 mb-4">
          {fullName ? (
            <>
              <span className="font-medium text-navy-900">{fullName}</span>, en
              signant ci-dessous, vous reconnaissez avoir lu et accepté
              l'ensemble des documents.
            </>
          ) : (
            "En signant ci-dessous, vous reconnaissez avoir lu et accepté l'ensemble des documents."
          )}
        </p>
        <SignaturePad onChange={setSignature} />
      </div>

      {err && (
        <div className="flex items-start gap-2 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-800">
          <AlertCircle className="h-4 w-4 shrink-0 mt-0.5" />
          {err}
        </div>
      )}

      {/* Validation */}
      <div className="sticky bottom-4">
        <button
          type="button"
          onClick={submit}
          disabled={!ready || pending}
          className="w-full inline-flex items-center justify-center gap-2 rounded-xl bg-signal-500 text-night-900 px-6 py-3.5 text-[15px] font-semibold shadow-glow-signal transition-[transform,background-color,opacity] duration-200 ease-premium hover:bg-signal-400 active:scale-[0.99] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-signal-500 focus-visible:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed disabled:shadow-none motion-reduce:transition-none motion-reduce:active:scale-100"
        >
          {pending ? (
            <>
              <Loader2 className="h-5 w-5 animate-spin" /> Enregistrement…
            </>
          ) : (
            <>
              <ShieldCheck className="h-5 w-5" /> Valider et accéder à ma
              formation
            </>
          )}
        </button>
        {!ready && (
          <p className="mt-2 text-center text-xs text-slate-500">
            {!allChecked
              ? "Acceptez tous les documents pour continuer."
              : "Apposez votre signature pour continuer."}
          </p>
        )}
      </div>
    </div>
  );
}
