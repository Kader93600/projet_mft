"use client";

import { useEffect, useState, useTransition } from "react";
import {
  FileText,
  X,
  Send,
  Loader2,
  CheckCircle2,
  AlertCircle,
} from "lucide-react";
import { sendQuote } from "../actions";

export interface QuoteDefaults {
  clientEmail: string;
  formationTitle: string;
  durationLabel: string;
  modalityLabel: string;
  fundingLabel: string;
}

/**
 * Bouton + modal de génération de devis.
 * Pré-remplit ce qu'on connaît (formation, durée, modalité, financement),
 * l'admin complète le montant et les précisions, puis "Générer & envoyer"
 * produit un PDF et l'envoie au prospect par email (Resend).
 */
export function QuoteDialog({
  leadId,
  defaults,
}: {
  leadId: string;
  defaults: QuoteDefaults;
}) {
  const [open, setOpen] = useState(false);
  const [pending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [done, setDone] = useState<string | null>(null);

  // Champs du formulaire
  const [formationTitle, setFormationTitle] = useState(defaults.formationTitle);
  const [amount, setAmount] = useState("");
  const [fundingLabel, setFundingLabel] = useState(defaults.fundingLabel);
  const [durationLabel, setDurationLabel] = useState(defaults.durationLabel);
  const [hours, setHours] = useState("");
  const [modalityLabel, setModalityLabel] = useState(defaults.modalityLabel);
  const [startDate, setStartDate] = useState("");
  const [validityDays, setValidityDays] = useState("30");
  const [notes, setNotes] = useState("");

  const noEmail = !defaults.clientEmail;

  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape" && !pending) setOpen(false);
    };
    window.addEventListener("keydown", onKey);
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      window.removeEventListener("keydown", onKey);
      document.body.style.overflow = prev;
    };
  }, [open, pending]);

  function reset() {
    setError(null);
    setDone(null);
  }

  function submit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    const amountEuros = Number(amount.replace(",", "."));
    if (!formationTitle.trim()) {
      setError("Indiquez l'intitulé de la formation.");
      return;
    }
    if (!Number.isFinite(amountEuros) || amountEuros <= 0) {
      setError("Indiquez un montant valide (en euros).");
      return;
    }
    startTransition(async () => {
      const res = await sendQuote(leadId, {
        formationTitle: formationTitle.trim(),
        amountEuros,
        fundingLabel: fundingLabel.trim(),
        durationLabel: durationLabel.trim(),
        hours: hours.trim(),
        modalityLabel: modalityLabel.trim(),
        startDate,
        validityDays: Number(validityDays) || 30,
        notes: notes.trim(),
      });
      if (!res.ok) {
        setError(res.error ?? "Une erreur est survenue.");
        return;
      }
      setDone((res as { sentTo?: string }).sentTo ?? defaults.clientEmail);
    });
  }

  const inputCls =
    "w-full rounded-lg border border-navy-200 bg-white px-3 py-2 text-sm text-navy-900 outline-none transition-colors focus:border-brand-400 focus:ring-2 focus:ring-brand-100 disabled:opacity-60";
  const labelCls =
    "block text-[11px] font-semibold uppercase tracking-wider text-slate-500 mb-1.5";

  return (
    <>
      <button
        type="button"
        onClick={() => {
          reset();
          setOpen(true);
        }}
        disabled={noEmail}
        title={
          noEmail
            ? "Ce prospect n'a pas d'email — devis impossible"
            : "Générer un devis et l'envoyer par email"
        }
        className="inline-flex items-center gap-1.5 rounded-lg bg-signal-500 hover:bg-signal-400 text-night-900 px-3 py-1.5 text-sm font-semibold shadow-glow-signal transition-[transform,background-color] duration-200 ease-premium active:scale-[0.97] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-signal-500 focus-visible:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed disabled:shadow-none motion-reduce:transition-none motion-reduce:active:scale-100"
      >
        <FileText className="h-3.5 w-3.5" />
        Générer le devis
      </button>

      {open && (
        <div
          className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto p-4 sm:p-8"
          role="dialog"
          aria-modal="true"
          aria-label="Générer un devis"
        >
          <div
            className="fixed inset-0 bg-navy-950/50 backdrop-blur-sm"
            onClick={() => !pending && setOpen(false)}
          />
          <div className="relative w-full max-w-lg rounded-2xl bg-white shadow-2xl border border-navy-100 my-auto">
            {/* Header */}
            <div className="flex items-center justify-between gap-3 px-6 py-4 border-b border-navy-100">
              <h2 className="font-display text-lg font-semibold text-navy-950 inline-flex items-center gap-2">
                <FileText className="h-5 w-5 text-brand-600" />
                Générer un devis
              </h2>
              <button
                type="button"
                onClick={() => !pending && setOpen(false)}
                aria-label="Fermer"
                className="inline-flex h-8 w-8 items-center justify-center rounded-lg text-slate-500 hover:bg-navy-50 hover:text-navy-900 transition-colors"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            {done ? (
              <div className="px-6 py-10 text-center">
                <div className="mx-auto h-12 w-12 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 flex items-center justify-center">
                  <CheckCircle2 className="h-6 w-6" />
                </div>
                <p className="mt-3 font-semibold text-navy-900">
                  Devis envoyé
                </p>
                <p className="text-sm text-slate-600 mt-1">
                  Le PDF a été envoyé à <strong>{done}</strong>. Le statut du
                  lead est passé à « Devis envoyé ».
                </p>
                <button
                  type="button"
                  onClick={() => setOpen(false)}
                  className="mt-5 inline-flex items-center rounded-lg bg-navy-900 hover:bg-navy-800 text-white px-4 py-2 text-sm font-medium transition-colors"
                >
                  Fermer
                </button>
              </div>
            ) : (
              <form onSubmit={submit} className="px-6 py-5 space-y-4">
                <p className="text-xs text-slate-500 -mt-1">
                  Champs pré-remplis depuis la fiche : complétez le montant et
                  ajustez si besoin, puis envoyez.
                </p>

                <div>
                  <label className={labelCls}>Intitulé de la formation *</label>
                  <input
                    className={inputCls}
                    value={formationTitle}
                    onChange={(e) => setFormationTitle(e.target.value)}
                    placeholder="Ex. Gestionnaire des opérations de transport…"
                    disabled={pending}
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className={labelCls}>Montant net de TVA (€) *</label>
                    <input
                      className={inputCls}
                      value={amount}
                      onChange={(e) => setAmount(e.target.value)}
                      inputMode="decimal"
                      placeholder="Ex. 2500"
                      disabled={pending}
                    />
                  </div>
                  <div>
                    <label className={labelCls}>Validité (jours)</label>
                    <input
                      className={inputCls}
                      value={validityDays}
                      onChange={(e) => setValidityDays(e.target.value)}
                      inputMode="numeric"
                      disabled={pending}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className={labelCls}>Durée</label>
                    <input
                      className={inputCls}
                      value={durationLabel}
                      onChange={(e) => setDurationLabel(e.target.value)}
                      placeholder="Ex. 12 semaines"
                      disabled={pending}
                    />
                  </div>
                  <div>
                    <label className={labelCls}>Volume horaire</label>
                    <input
                      className={inputCls}
                      value={hours}
                      onChange={(e) => setHours(e.target.value)}
                      placeholder="Ex. 140 h"
                      disabled={pending}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className={labelCls}>Modalité</label>
                    <input
                      className={inputCls}
                      value={modalityLabel}
                      onChange={(e) => setModalityLabel(e.target.value)}
                      placeholder="Ex. Mixte"
                      disabled={pending}
                    />
                  </div>
                  <div>
                    <label className={labelCls}>Financement envisagé</label>
                    <input
                      className={inputCls}
                      value={fundingLabel}
                      onChange={(e) => setFundingLabel(e.target.value)}
                      placeholder="Ex. CPF"
                      disabled={pending}
                    />
                  </div>
                </div>

                <div>
                  <label className={labelCls}>Début prévu (optionnel)</label>
                  <input
                    type="date"
                    className={inputCls}
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                    disabled={pending}
                  />
                </div>

                <div>
                  <label className={labelCls}>Précisions (optionnel)</label>
                  <textarea
                    className={inputCls + " min-h-[70px] resize-y"}
                    value={notes}
                    onChange={(e) => setNotes(e.target.value)}
                    placeholder="Conditions particulières, remise, échéancier…"
                    disabled={pending}
                  />
                </div>

                {error && (
                  <div className="flex items-start gap-2 rounded-lg border border-rose-200 bg-rose-50 px-3 py-2 text-xs text-rose-800">
                    <AlertCircle className="h-3.5 w-3.5 shrink-0 mt-0.5" />
                    {error}
                  </div>
                )}

                <div className="flex items-center justify-end gap-2 pt-1">
                  <button
                    type="button"
                    onClick={() => setOpen(false)}
                    disabled={pending}
                    className="inline-flex items-center rounded-lg border border-navy-200 bg-white px-4 py-2 text-sm font-medium text-navy-900 hover:bg-navy-50 transition-colors disabled:opacity-60"
                  >
                    Annuler
                  </button>
                  <button
                    type="submit"
                    disabled={pending}
                    className="inline-flex items-center gap-1.5 rounded-lg bg-navy-900 hover:bg-navy-800 text-white px-4 py-2 text-sm font-semibold transition-colors disabled:opacity-60"
                  >
                    {pending ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      <Send className="h-4 w-4" />
                    )}
                    Générer &amp; envoyer
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}
    </>
  );
}
