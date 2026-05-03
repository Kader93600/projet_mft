"use client";
import { useState } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import {
  AlertCircle,
  Mail,
  ArrowRight,
  Loader2,
  Check,
  Send,
} from "lucide-react";

/**
 * Formulaire dédié à la demande de réinitialisation.
 *
 * Envoie un mail Supabase qui pointe vers /auth/callback?next=/reset-password
 * pour que le code PKCE soit échangé côté serveur avant que le stagiaire
 * n'atterrisse sur le formulaire de nouveau mot de passe.
 */
export function ForgotPasswordForm() {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [sent, setSent] = useState(false);
  const [shake, setShake] = useState(false);

  function triggerShake() {
    setShake(true);
    window.setTimeout(() => setShake(false), 500);
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    const supabase = createClient();
    const redirectTo =
      typeof window !== "undefined"
        ? `${window.location.origin}/auth/callback?next=/reset-password`
        : undefined;
    const { error: err } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo,
    });
    setLoading(false);
    if (err) {
      triggerShake();
      setError(translateAuthError(err.message));
      return;
    }
    setSent(true);
  }

  if (sent) {
    return (
      <div
        role="status"
        className="space-y-5 text-center"
        style={{ animation: "fade-up 0.4s ease-out both" }}
      >
        <div className="mx-auto h-14 w-14 rounded-full bg-emerald-100 grid place-items-center">
          <Check className="h-7 w-7 text-emerald-700" />
        </div>
        <div>
          <h2 className="font-display text-lg font-semibold text-navy-900">
            Email envoyé.
          </h2>
          <p className="mt-2 text-sm text-slate-600 leading-relaxed">
            Si un compte existe avec l'adresse{" "}
            <span className="font-medium text-navy-900">{email}</span>, vous
            recevrez sous une minute un email avec un lien sécurisé. Le lien
            est valable <strong>1 heure</strong>.
          </p>
        </div>
        <div className="rounded-xl bg-navy-50 border border-navy-100 px-4 py-3 text-xs text-slate-600 text-left">
          <div className="font-semibold text-navy-900 mb-1 inline-flex items-center gap-1.5">
            <Mail className="h-3.5 w-3.5" />
            Pas reçu d'email ?
          </div>
          <ul className="space-y-1 list-disc pl-4">
            <li>Vérifiez votre dossier spam ou indésirables</li>
            <li>
              Patientez quelques minutes (la livraison peut être différée)
            </li>
            <li>
              Vérifiez la saisie de l'adresse :{" "}
              <button
                type="button"
                onClick={() => setSent(false)}
                className="font-medium text-brand-700 hover:underline"
              >
                modifier
              </button>
            </li>
          </ul>
        </div>
        <Link
          href="/login"
          className="inline-flex w-full items-center justify-center gap-2 rounded-xl bg-navy-900 px-4 py-3 text-sm font-semibold text-white hover:bg-navy-800 transition-colors"
        >
          Retour à la connexion
          <ArrowRight className="h-4 w-4" />
        </Link>
      </div>
    );
  }

  return (
    <form
      onSubmit={onSubmit}
      className={
        "space-y-5 transition-transform " +
        (shake
          ? "animate-[shake_0.5s_ease-in-out] motion-reduce:animate-none"
          : "")
      }
    >
      <div style={{ animation: "fade-up 0.4s ease-out both" }}>
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
            autoFocus
          />
        </div>
        <p className="mt-2 text-[11px] text-slate-500">
          L'email associé à votre compte stagiaire.
        </p>
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
        disabled={loading || !email}
        className="w-full group transition-transform active:scale-[0.98] motion-reduce:active:scale-100"
        size="lg"
        style={{ animation: "fade-up 0.4s ease-out 0.08s both" }}
      >
        {loading ? (
          <>
            <Loader2 className="h-4 w-4 animate-spin motion-reduce:animate-none" />
            Envoi…
          </>
        ) : (
          <>
            <Send className="h-4 w-4" />
            Envoyer le lien de réinitialisation
          </>
        )}
      </Button>
    </form>
  );
}

function translateAuthError(msg: string): string {
  const m = msg.toLowerCase();
  if (m.includes("rate limit") || m.includes("too many"))
    return "Trop de tentatives. Réessayez dans quelques minutes.";
  if (m.includes("network"))
    return "Connexion au serveur impossible. Vérifiez votre réseau.";
  if (m.includes("invalid email"))
    return "Adresse email invalide.";
  return msg;
}
