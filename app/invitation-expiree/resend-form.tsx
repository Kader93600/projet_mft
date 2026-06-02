"use client";
import { useState, useTransition } from "react";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { Mail, ArrowRight, Loader2, CheckCircle2, AlertCircle } from "lucide-react";
import { resendInvitation } from "./actions";

export function ResendInvitationForm() {
  const [email, setEmail] = useState("");
  const [pending, startTransition] = useTransition();
  const [done, setDone] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    startTransition(async () => {
      const res = await resendInvitation(email);
      if (res.ok) setDone(true);
      else setError(res.error ?? "Une erreur est survenue.");
    });
  }

  if (done) {
    return (
      <div
        role="status"
        className="flex flex-col items-center gap-4 py-4 text-center"
        style={{ animation: "fade-up 0.4s ease-out both" }}
      >
        <div className="h-14 w-14 rounded-full bg-emerald-100 grid place-items-center">
          <CheckCircle2 className="h-7 w-7 text-emerald-700" />
        </div>
        <div>
          <div className="font-display text-lg font-semibold text-navy-900 dark:text-[hsl(var(--text))]">
            Demande enregistrée
          </div>
          <p className="mt-1.5 text-sm text-slate-600 dark:text-[hsl(var(--text-muted))]">
            Si un compte en attente d'activation correspond à cette adresse,
            un nouveau lien d'invitation vient d'être envoyé. Pensez à
            vérifier vos spams.
          </p>
        </div>
      </div>
    );
  }

  return (
    <form onSubmit={onSubmit} className="space-y-5">
      <div>
        <Label htmlFor="email">Adresse email</Label>
        <div className="relative">
          <Mail className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input
            id="email"
            type="email"
            required
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="vous@exemple.fr"
            className="pl-10"
          />
        </div>
      </div>

      {error && (
        <div
          role="alert"
          className="flex items-start gap-2 rounded-xl bg-rose-50 border border-rose-200 px-3.5 py-3 text-sm text-rose-700"
          style={{ animation: "fade-up 0.3s ease-out both" }}
        >
          <AlertCircle className="h-4 w-4 mt-0.5 flex-none" />
          <span>{error}</span>
        </div>
      )}

      <Button
        type="submit"
        disabled={pending || !email.trim()}
        className="w-full group transition-transform active:scale-[0.98] motion-reduce:active:scale-100"
        size="lg"
      >
        {pending ? (
          <>
            <Loader2 className="h-4 w-4 animate-spin motion-reduce:animate-none" />
            Envoi…
          </>
        ) : (
          <>
            Recevoir un nouveau lien
            <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0" />
          </>
        )}
      </Button>
    </form>
  );
}
