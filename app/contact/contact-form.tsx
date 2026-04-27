"use client";
import { useState } from "react";
import { useSearchParams } from "next/navigation";
import { ArrowRight, CheckCircle2 } from "lucide-react";
import { FORMATIONS } from "@/lib/formations-config";

export function ContactForm() {
  const params = useSearchParams();
  const presetFormation = params.get("formation") ?? "";
  const presetFinanceur = params.get("financeur") ?? "";

  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setLoading(true);
    const fd = new FormData(e.currentTarget);
    const payload = Object.fromEntries(fd.entries());
    try {
      const res = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      if (!res.ok) throw new Error();
      setSubmitted(true);
    } catch {
      alert("Une erreur est survenue. Réessayez ou écrivez-nous directement.");
    } finally {
      setLoading(false);
    }
  }

  if (submitted) {
    return (
      <div className="rounded-2xl border border-signal-500/40 bg-signal-500/10 p-8 text-center">
        <CheckCircle2 className="mx-auto h-10 w-10 text-signal-400" />
        <h3 className="mt-4 font-display text-xl font-semibold">
          Message bien reçu !
        </h3>
        <p className="mt-2 text-white/75">
          Notre équipe vous recontacte sous 24 h ouvrées.
        </p>
      </div>
    );
  }

  return (
    <form onSubmit={onSubmit} className="space-y-5">
      <div className="grid sm:grid-cols-2 gap-4">
        <Field name="firstName" label="Prénom" required />
        <Field name="lastName" label="Nom" required />
      </div>
      <div className="grid sm:grid-cols-2 gap-4">
        <Field
          name="email"
          label="Email"
          type="email"
          required
          autoComplete="email"
        />
        <Field
          name="phone"
          label="Téléphone"
          type="tel"
          autoComplete="tel"
        />
      </div>

      <div>
        <Label>Formation qui vous intéresse</Label>
        <select
          name="formation"
          defaultValue={presetFormation}
          className="w-full bg-night-50 border border-white/10 rounded-xl px-4 py-3 text-white focus:border-signal-500 focus:outline-none focus:ring-2 focus:ring-signal-500/30"
        >
          <option value="">— Je ne sais pas encore —</option>
          {FORMATIONS.map((f) => (
            <option key={f.slug} value={f.slug}>
              {f.code} — {f.title}
            </option>
          ))}
        </select>
      </div>

      <div>
        <Label>Mode de financement envisagé</Label>
        <select
          name="financeur"
          defaultValue={presetFinanceur}
          className="w-full bg-night-50 border border-white/10 rounded-xl px-4 py-3 text-white focus:border-signal-500 focus:outline-none focus:ring-2 focus:ring-signal-500/30"
        >
          <option value="">— À définir ensemble —</option>
          <option value="cpf">CPF / Mon Compte Formation</option>
          <option value="opco">OPCO (employeur)</option>
          <option value="pole_emploi">France Travail</option>
          <option value="employeur">Plan employeur</option>
          <option value="transitions_pro">Transitions Pro</option>
          <option value="auto">Auto-financement</option>
        </select>
      </div>

      <div>
        <Label>Votre message (optionnel)</Label>
        <textarea
          name="message"
          rows={5}
          placeholder="Parlez-nous de votre projet, vos disponibilités…"
          className="w-full bg-night-50 border border-white/10 rounded-xl px-4 py-3 text-white placeholder:text-white/30 focus:border-signal-500 focus:outline-none focus:ring-2 focus:ring-signal-500/30"
        />
      </div>

      <label className="flex items-start gap-3 text-sm text-white/65 cursor-pointer">
        <input
          type="checkbox"
          name="consent"
          required
          className="mt-0.5 h-4 w-4 rounded border-white/20 bg-night-50"
        />
        <span>
          J'accepte que mes données soient utilisées pour traiter ma demande,
          conformément à la{" "}
          <a href="/confidentialite" className="text-signal-400 underline">
            politique de confidentialité
          </a>
          .
        </span>
      </label>

      <button
        type="submit"
        disabled={loading}
        className="inline-flex items-center justify-center gap-2 w-full sm:w-auto rounded-2xl bg-signal-500 text-night px-6 py-3 text-sm font-semibold hover:bg-signal-400 disabled:opacity-60 disabled:cursor-not-allowed transition shadow-glow-signal"
      >
        {loading ? "Envoi…" : "Envoyer ma demande"}
        <ArrowRight className="h-4 w-4" />
      </button>
    </form>
  );
}

function Field({
  name,
  label,
  type = "text",
  required,
  autoComplete,
}: {
  name: string;
  label: string;
  type?: string;
  required?: boolean;
  autoComplete?: string;
}) {
  return (
    <div>
      <Label>
        {label}
        {required && <span className="text-signal-400 ml-1">*</span>}
      </Label>
      <input
        name={name}
        type={type}
        required={required}
        autoComplete={autoComplete}
        className="w-full bg-night-50 border border-white/10 rounded-xl px-4 py-3 text-white placeholder:text-white/30 focus:border-signal-500 focus:outline-none focus:ring-2 focus:ring-signal-500/30"
      />
    </div>
  );
}

function Label({ children }: { children: React.ReactNode }) {
  return (
    <span className="block text-[11px] font-semibold uppercase tracking-[0.16em] text-white/55 mb-2">
      {children}
    </span>
  );
}
