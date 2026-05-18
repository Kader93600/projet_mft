"use client";

import { useState, useTransition } from "react";
import { Loader2, AlertCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { createOrganization } from "./actions";

export function CreateOrgForm() {
  const [pending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);

  return (
    <form
      action={(formData: FormData) => {
        setError(null);
        startTransition(async () => {
          try {
            const res = await createOrganization(formData);
            if (res && !res.ok) {
              setError(res.error ?? "Erreur inconnue");
            }
          } catch (e: any) {
            // redirect() throws a NEXT_REDIRECT — laisse passer
            if (e?.digest?.startsWith?.("NEXT_REDIRECT")) throw e;
            setError(e?.message ?? "Erreur");
          }
        });
      }}
      className="space-y-4"
    >
      <div className="grid md:grid-cols-2 gap-4">
        <Field
          name="name"
          label="Nom commercial *"
          placeholder="Transport Dupont"
          required
        />
        <Field
          name="legal_name"
          label="Raison sociale"
          placeholder="TRANSPORT DUPONT SAS"
        />
      </div>

      <div className="grid md:grid-cols-2 gap-4">
        <Field
          name="siret"
          label="SIRET"
          placeholder="123 456 789 00012"
          inputMode="numeric"
          maxLength={17}
        />
        <Field
          name="billing_email"
          label="Email de facturation *"
          placeholder="compta@transport-dupont.fr"
          type="email"
          required
        />
      </div>

      <div className="border-t border-navy-50 pt-4 mt-4">
        <h3 className="text-sm font-semibold text-navy-900 mb-3">
          Contact principal (deviendra administrateur)
        </h3>
        <div className="grid md:grid-cols-2 gap-4">
          <Field
            name="contact_full_name"
            label="Nom complet"
            placeholder="Marie Dupont"
          />
          <Field
            name="contact_email"
            label="Email du compte MFT existant"
            placeholder="marie@transport-dupont.fr"
            type="email"
            hint="Le contact doit avoir déjà un compte MFT. Sinon créez-le d'abord via /admin/users."
          />
        </div>
      </div>

      {error && (
        <div className="flex items-start gap-2 rounded-lg border border-rose-200 bg-rose-50 px-3 py-2.5 text-sm text-rose-800">
          <AlertCircle className="h-4 w-4 shrink-0 mt-0.5" />
          <div>{error}</div>
        </div>
      )}

      <div className="flex justify-end pt-2">
        <Button type="submit" disabled={pending} variant="gold">
          {pending ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" /> Création…
            </>
          ) : (
            "Créer l'organisation"
          )}
        </Button>
      </div>
    </form>
  );
}

function Field({
  name,
  label,
  hint,
  ...props
}: {
  name: string;
  label: string;
  hint?: string;
  required?: boolean;
  placeholder?: string;
  type?: string;
  inputMode?: any;
  maxLength?: number;
}) {
  return (
    <div>
      <label
        htmlFor={name}
        className="block text-[11px] uppercase tracking-wider text-slate-500 mb-1 font-semibold"
      >
        {label}
      </label>
      <input
        id={name}
        name={name}
        className="w-full rounded-lg border border-navy-100 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
        {...props}
      />
      {hint && (
        <p className="text-[11px] text-slate-500 mt-1 leading-snug">{hint}</p>
      )}
    </div>
  );
}
