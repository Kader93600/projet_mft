"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { renderMarkdown } from "@/lib/markdown";
import { acceptDocument } from "@/app/onboarding/actions";
import { FileSignature, Loader2, AlertCircle, ChevronDown } from "lucide-react";
import type { PendingDoc } from "@/lib/onboarding-docs";

/**
 * Documents publiés non encore signés, présentés hors onboarding.
 * Reprend la cérémonie de signature : nom + lecture + case + horodatage/IP
 * (via l'action acceptDocument, partagée avec le wizard d'onboarding).
 */
export function PendingDocs({
  docs,
  fullName,
}: {
  docs: PendingDoc[];
  fullName: string;
}) {
  const router = useRouter();
  const [name, setName] = useState(fullName);
  const [checked, setChecked] = useState<Record<string, boolean>>({});
  const [signingId, setSigningId] = useState<string | null>(null);
  const [pending, start] = useTransition();
  const [err, setErr] = useState<string | null>(null);

  if (docs.length === 0) return null;

  function sign(id: string) {
    setErr(null);
    if (name.trim().length < 2) {
      setErr("Saisissez votre nom complet pour signer.");
      return;
    }
    setSigningId(id);
    start(async () => {
      try {
        await acceptDocument({ document_id: id, signature_name: name.trim() });
        router.refresh();
      } catch (e: any) {
        setErr(e?.message ?? "Une erreur est survenue.");
      } finally {
        setSigningId(null);
      }
    });
  }

  return (
    <section className="space-y-4">
      <div className="rounded-2xl border border-gold-200 bg-gold-50/60 p-5">
        <h2 className="font-display text-xl font-semibold text-navy-900 inline-flex items-center gap-2">
          <FileSignature className="h-5 w-5 text-gold-700" />
          Documents à signer ({docs.length})
        </h2>
        <p className="text-sm text-slate-600 mt-1 max-w-2xl">
          Merci de lire et de signer les documents ci-dessous. Votre signature
          électronique (nom, date et heure) est enregistrée comme preuve.
        </p>
        <div className="mt-3 max-w-sm">
          <label
            htmlFor="sig-name"
            className="block text-[11px] font-semibold uppercase tracking-wider text-slate-500 mb-1.5"
          >
            Votre nom complet (signature)
          </label>
          <input
            id="sig-name"
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Prénom NOM"
            autoComplete="name"
            className="w-full rounded-lg border border-navy-200 bg-white px-3 py-2 text-sm text-navy-900 outline-none transition-colors focus:border-gold-400 focus:ring-2 focus:ring-gold-100"
          />
        </div>
        {err && (
          <div className="mt-3 flex items-center gap-2 text-sm text-rose-700">
            <AlertCircle className="h-4 w-4" />
            {err}
          </div>
        )}
      </div>

      {docs.map((d) => {
        const busy = signingId === d.id && pending;
        return (
          <div key={d.id} className="rounded-2xl border border-navy-100 bg-white">
            <div className="px-6 pt-5 pb-3 border-b border-navy-50">
              <div className="font-display font-semibold text-navy-900">
                {d.title}
              </div>
              <div className="text-xs text-slate-500 mt-0.5">
                Version {d.version}
              </div>
            </div>
            <div className="px-6 py-4">
              <details className="group">
                <summary className="cursor-pointer text-sm font-medium text-navy-900 hover:text-gold-700 list-none inline-flex items-center gap-1.5">
                  <ChevronDown className="h-4 w-4 transition-transform group-open:rotate-180" />
                  Lire le document
                </summary>
                <div
                  className="prose-lesson text-sm mt-4 max-h-[420px] overflow-y-auto bg-slate-50/60 p-4 rounded-xl"
                  dangerouslySetInnerHTML={{
                    __html: renderMarkdown(d.content_md),
                  }}
                />
              </details>

              <label className="mt-4 flex items-start gap-3 cursor-pointer select-none">
                <input
                  type="checkbox"
                  checked={!!checked[d.id]}
                  onChange={(e) =>
                    setChecked((s) => ({ ...s, [d.id]: e.target.checked }))
                  }
                  className="mt-0.5 h-4 w-4 accent-gold-500"
                />
                <span className="text-sm text-navy-900">
                  J'ai lu et j'accepte{" "}
                  <span className="font-semibold">{d.title}</span> (version{" "}
                  {d.version}).
                </span>
              </label>

              <div className="mt-4 flex justify-end">
                <button
                  type="button"
                  onClick={() => sign(d.id)}
                  disabled={!checked[d.id] || name.trim().length < 2 || pending}
                  className="inline-flex items-center gap-1.5 rounded-lg bg-gold-500 hover:bg-gold-600 text-night-900 px-4 py-2 text-sm font-semibold transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {busy ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <FileSignature className="h-4 w-4" />
                  )}
                  Signer
                </button>
              </div>
            </div>
          </div>
        );
      })}
    </section>
  );
}
