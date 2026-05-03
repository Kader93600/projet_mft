"use client";
import { useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import {
  AlertCircle,
  Mail,
  Lock,
  ArrowRight,
  Loader2,
  Check,
  KeyRound,
} from "lucide-react";

export function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [shake, setShake] = useState(false);

  // Toasts via querystring (?reset=success après reset, ?error=... après callback)
  useEffect(() => {
    if (searchParams.get("reset") === "success") {
      setSuccess(
        "Votre mot de passe a bien été mis à jour. Connectez-vous avec vos nouveaux identifiants."
      );
    }
    const err = searchParams.get("error");
    if (err) setError(err);
  }, [searchParams]);

  function triggerShake() {
    setShake(true);
    window.setTimeout(() => setShake(false), 500);
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccess(null);
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) {
      triggerShake();
      setError(translateAuthError(error.message));
      setLoading(false);
      return;
    }
    setSuccess("Connexion réussie. Redirection…");
    window.setTimeout(() => {
      router.push("/dashboard");
      router.refresh();
    }, 400);
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
          />
        </div>
      </div>

      <div style={{ animation: "fade-up 0.4s ease-out 0.08s both" }}>
        <div className="flex items-center justify-between mb-2">
          <Label htmlFor="password" className="mb-0">
            Mot de passe
          </Label>
          <Link
            href="/forgot-password"
            className="text-xs text-slate-500 hover:text-brand-700 transition-colors inline-flex items-center gap-1"
          >
            <KeyRound className="h-3 w-3" />
            Mot de passe oublié ?
          </Link>
        </div>
        <div className="relative">
          <Lock className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input
            id="password"
            type="password"
            required
            minLength={6}
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
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
      {success && (
        <div
          role="status"
          className="flex items-start gap-2 rounded-xl bg-emerald-50 border border-emerald-200 px-3.5 py-3 text-sm text-emerald-800"
          style={{ animation: "fade-up 0.3s ease-out both" }}
        >
          <Check className="h-4 w-4 mt-0.5 flex-none" />
          <span>{success}</span>
        </div>
      )}

      <Button
        type="submit"
        disabled={loading}
        className="w-full group transition-transform active:scale-[0.98] motion-reduce:active:scale-100"
        size="lg"
        style={{ animation: "fade-up 0.4s ease-out 0.16s both" }}
      >
        {loading ? (
          <>
            <Loader2 className="h-4 w-4 animate-spin motion-reduce:animate-none" />
            Connexion…
          </>
        ) : (
          <>
            Se connecter
            <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0" />
          </>
        )}
      </Button>
    </form>
  );
}

function translateAuthError(msg: string): string {
  const m = msg.toLowerCase();
  if (m.includes("invalid login credentials"))
    return "Email ou mot de passe incorrect.";
  if (m.includes("email not confirmed"))
    return "Email non confirmé. Vérifiez votre boîte de réception.";
  if (m.includes("rate limit") || m.includes("too many"))
    return "Trop de tentatives. Réessayez dans quelques minutes.";
  if (m.includes("user not found"))
    return "Aucun compte n'est associé à cet email.";
  if (m.includes("network"))
    return "Connexion au serveur impossible. Vérifiez votre réseau.";
  return msg;
}
