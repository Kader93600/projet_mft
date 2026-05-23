"use client";
import { useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { cn } from "@/lib/utils";
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
  const [notice, setNotice] = useState<string | null>(null);
  const [shake, setShake] = useState(false);
  const [flipped, setFlipped] = useState(false);

  // Toasts via querystring (?reset=success après reset, ?error=... après callback)
  useEffect(() => {
    if (searchParams.get("reset") === "success") {
      setNotice(
        "Votre mot de passe a bien été mis à jour. Connectez-vous avec vos nouveaux identifiants."
      );
    }
    const err = searchParams.get("error");
    if (err) setError(err);
  }, [searchParams]);

  function triggerShake() {
    setShake(true);
    window.setTimeout(() => setShake(false), 650);
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setNotice(null);
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
    // Succès → retournement 3D de la carte vers la face « réussite », puis redirection.
    setFlipped(true);
    window.setTimeout(() => {
      router.push("/dashboard");
      router.refresh();
    }, 1200);
  }

  return (
    <div className="[perspective:1400px]">
      <div
        className={cn(
          "relative transition-transform duration-[600ms] ease-premium",
          "[transform-style:preserve-3d] [-webkit-transform-style:preserve-3d]",
          "motion-reduce:transition-none",
          flipped && "[transform:rotateY(180deg)]",
          shake && !flipped && "animate-flip-shake motion-reduce:animate-none"
        )}
      >
        {/* ─── Face avant : formulaire ─────────────────────────────── */}
        <div
          className="[backface-visibility:hidden] [-webkit-backface-visibility:hidden]"
          aria-hidden={flipped}
        >
          <form onSubmit={onSubmit} className="space-y-5">
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
                  disabled={loading}
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
                  disabled={loading}
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
            {notice && (
              <div
                role="status"
                className="flex items-start gap-2 rounded-xl bg-emerald-50 border border-emerald-200 px-3.5 py-3 text-sm text-emerald-800"
                style={{ animation: "fade-up 0.3s ease-out both" }}
              >
                <Check className="h-4 w-4 mt-0.5 flex-none" />
                <span>{notice}</span>
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
        </div>

        {/* ─── Face arrière : réussite ─────────────────────────────── */}
        <div
          aria-hidden={!flipped}
          className="absolute inset-0 flex flex-col items-center justify-center gap-4 rounded-xl bg-white text-center [transform:rotateY(180deg)] [backface-visibility:hidden] [-webkit-backface-visibility:hidden] dark:bg-[hsl(var(--surface))]"
        >
          <SuccessCheck active={flipped} />
          <div>
            <p className="font-display text-xl font-semibold text-navy-950 dark:text-[hsl(var(--text))]">
              Connexion réussie
            </p>
            <p className="mt-1 text-sm text-slate-500 dark:text-[hsl(var(--text-muted))]">
              Redirection vers votre espace…
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

/** Coche SVG tracée + onde, déclenchées une fois la carte retournée. */
function SuccessCheck({ active }: { active: boolean }) {
  return (
    <span className="relative inline-flex h-20 w-20 items-center justify-center">
      <span
        className={cn(
          "absolute inset-0 rounded-full bg-emerald-400/25",
          active ? "motion-safe:animate-ping-once opacity-0" : "opacity-0"
        )}
      />
      <span className="absolute inset-0 rounded-full bg-emerald-50 dark:bg-emerald-500/15" />
      <svg viewBox="0 0 52 52" className="relative h-12 w-12" aria-hidden="true">
        <circle
          cx="26"
          cy="26"
          r="23"
          fill="none"
          strokeWidth="2.5"
          className="stroke-emerald-500/25"
        />
        <path
          d="M16 27 l7 7 l13 -15"
          fill="none"
          strokeWidth="3.5"
          strokeLinecap="round"
          strokeLinejoin="round"
          className={cn(
            "stroke-emerald-500 [stroke-dasharray:40]",
            active
              ? "[stroke-dashoffset:40] motion-safe:animate-check-draw motion-reduce:[stroke-dashoffset:0]"
              : "[stroke-dashoffset:40]"
          )}
        />
      </svg>
    </span>
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
