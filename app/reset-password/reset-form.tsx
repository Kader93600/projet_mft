"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useTranslations } from "next-intl";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import {
  AlertCircle,
  Lock,
  ArrowRight,
  Loader2,
  Check,
  Eye,
  EyeOff,
  ShieldCheck,
} from "lucide-react";

/**
 * Formulaire de définition d'un nouveau mot de passe après clic sur le
 * lien de récupération reçu par email.
 *
 * Flux Supabase :
 *  1. /login → "Mot de passe oublié" → resetPasswordForEmail(redirectTo)
 *  2. Email reçu → clic → atterrit ici avec #access_token=...&type=recovery
 *  3. Supabase JS établit automatiquement une session de recovery
 *  4. supabase.auth.updateUser({ password }) → succès
 *  5. signOut + redirect vers /login?reset=success
 */
export function ResetPasswordForm() {
  const t = useTranslations("resetPassword");
  const router = useRouter();
  const [hasSession, setHasSession] = useState<"checking" | "yes" | "no">(
    "checking"
  );
  const [pwd, setPwd] = useState("");
  const [pwd2, setPwd2] = useState("");
  const [show, setShow] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  // Avec le flow PKCE @supabase/ssr, /auth/callback échange déjà le code
  // contre une session avant l'arrivée ici. On vérifie juste qu'elle est là.
  useEffect(() => {
    const supabase = createClient();
    let mounted = true;
    supabase.auth.getSession().then(({ data }) => {
      if (!mounted) return;
      setHasSession(data.session ? "yes" : "no");
    });
    return () => {
      mounted = false;
    };
  }, []);

  const strength = scorePassword(pwd, t);
  const meetsRules = strength.score >= 3 && pwd.length >= 8;

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (pwd !== pwd2) {
      setError(t("passwordsDontMatch"));
      return;
    }
    if (!meetsRules) {
      setError(t("rulesError"));
      return;
    }
    setLoading(true);
    const supabase = createClient();
    const { error: upErr } = await supabase.auth.updateUser({ password: pwd });
    if (upErr) {
      setError(translateAuthError(upErr.message));
      setLoading(false);
      return;
    }
    setSuccess(true);
    // Déconnecte la session de recovery puis renvoie sur /login
    await supabase.auth.signOut();
    setTimeout(() => {
      router.push("/login?reset=success");
      router.refresh();
    }, 1200);
  }

  if (hasSession === "checking") {
    return (
      <div className="flex flex-col items-center gap-3 py-8 text-slate-600 dark:text-[hsl(var(--text-muted))]">
        <Loader2 className="h-6 w-6 animate-spin text-brand-600 motion-reduce:animate-none" />
        <span className="text-sm">{t("checkingLink")}</span>
      </div>
    );
  }

  if (hasSession === "no") {
    return (
      <div
        role="alert"
        className="space-y-4"
        style={{ animation: "fade-up 0.4s ease-out both" }}
      >
        <div className="flex items-start gap-3 rounded-xl bg-rose-50 border border-rose-200 px-4 py-4 text-sm text-rose-800">
          <AlertCircle className="h-5 w-5 mt-0.5 flex-none" />
          <div>
            <div className="font-semibold">{t("invalidLinkTitle")}</div>
            <p className="mt-1 text-rose-700/90">
              {t("invalidLinkDescription")}
            </p>
          </div>
        </div>
        <Link
          href="/login"
          className="inline-flex w-full items-center justify-center gap-2 rounded-xl bg-navy-900 px-4 py-3 text-sm font-semibold text-white hover:bg-navy-800 transition-colors"
        >
          {t("backToLogin")}
          <ArrowRight className="h-4 w-4" />
        </Link>
      </div>
    );
  }

  if (success) {
    return (
      <div
        role="status"
        className="flex flex-col items-center gap-4 py-6 text-center"
        style={{ animation: "fade-up 0.4s ease-out both" }}
      >
        <div className="h-14 w-14 rounded-full bg-emerald-100 grid place-items-center">
          <ShieldCheck className="h-7 w-7 text-emerald-700" />
        </div>
        <div>
          <div className="font-display text-lg font-semibold text-navy-900 dark:text-[hsl(var(--text))]">
            {t("successTitle")}
          </div>
          <p className="mt-1 text-sm text-slate-600 dark:text-[hsl(var(--text-muted))]">
            {t("successRedirect")}
          </p>
        </div>
      </div>
    );
  }

  return (
    <form onSubmit={onSubmit} className="space-y-5">
      <div style={{ animation: "fade-up 0.4s ease-out both" }}>
        <Label htmlFor="pwd">{t("newPasswordLabel")}</Label>
        <div className="relative">
          <Lock className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input
            id="pwd"
            type={show ? "text" : "password"}
            required
            minLength={8}
            autoComplete="new-password"
            value={pwd}
            onChange={(e) => setPwd(e.target.value)}
            placeholder={t("newPasswordPlaceholder")}
            className="pl-10 pr-11"
          />
          <button
            type="button"
            onClick={() => setShow((v) => !v)}
            aria-label={show ? t("hidePassword") : t("showPassword")}
            className="absolute right-3 top-1/2 -translate-y-1/2 h-7 w-7 rounded-md grid place-items-center text-slate-400 hover:text-navy-700 hover:bg-navy-50 transition-colors"
          >
            {show ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
          </button>
        </div>

        {/* Indicateur de force */}
        {pwd && (
          <div className="mt-2 space-y-1">
            <div className="flex gap-1">
              {[0, 1, 2, 3].map((i) => (
                <div
                  key={i}
                  className={
                    "h-1 flex-1 rounded-full transition-colors " +
                    (i < strength.score
                      ? strength.score <= 1
                        ? "bg-rose-500"
                        : strength.score === 2
                        ? "bg-amber-500"
                        : strength.score === 3
                        ? "bg-emerald-500"
                        : "bg-emerald-600"
                      : "bg-navy-100")
                  }
                />
              ))}
            </div>
            <div className="text-[11px] text-slate-500 dark:text-[hsl(var(--text-muted))]">
              {t("strengthLabel")}{" "}
              <span className="font-medium">{strength.label}</span>
            </div>
          </div>
        )}
      </div>

      <div style={{ animation: "fade-up 0.4s ease-out 0.08s both" }}>
        <Label htmlFor="pwd2">{t("confirmLabel")}</Label>
        <div className="relative">
          <Lock className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input
            id="pwd2"
            type={show ? "text" : "password"}
            required
            minLength={8}
            autoComplete="new-password"
            value={pwd2}
            onChange={(e) => setPwd2(e.target.value)}
            placeholder={t("confirmPlaceholder")}
            className="pl-10"
          />
        </div>
        {pwd2 && pwd !== pwd2 && (
          <p className="mt-1.5 text-[11px] text-rose-700">
            {t("passwordsDontMatch")}
          </p>
        )}
        {pwd2 && pwd && pwd === pwd2 && (
          <p className="mt-1.5 text-[11px] text-emerald-700 inline-flex items-center gap-1">
            <Check className="h-3 w-3" />
            {t("passwordsMatch")}
          </p>
        )}
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
        disabled={loading || !meetsRules || pwd !== pwd2}
        className="w-full group transition-transform active:scale-[0.98] motion-reduce:active:scale-100"
        size="lg"
        style={{ animation: "fade-up 0.4s ease-out 0.16s both" }}
      >
        {loading ? (
          <>
            <Loader2 className="h-4 w-4 animate-spin motion-reduce:animate-none" />
            {t("updating")}
          </>
        ) : (
          <>
            {t("saveCta")}
            <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0" />
          </>
        )}
      </Button>

      <Link
        href="/login"
        className="block w-full text-center text-xs text-slate-500 dark:text-[hsl(var(--text-muted))] hover:text-navy-900 dark:hover:text-[hsl(var(--text))] transition-colors"
        style={{ animation: "fade-up 0.4s ease-out 0.2s both" }}
      >
        {t("cancel")}
      </Link>
    </form>
  );
}

/* ─── Helpers ─────────────────────────────────────────────────────── */

type TFn = ReturnType<typeof useTranslations>;

function scorePassword(
  pwd: string,
  t: TFn,
): { score: number; label: string } {
  if (!pwd) return { score: 0, label: t("strength0") };
  let score = 0;
  if (pwd.length >= 8) score++;
  if (pwd.length >= 12) score++;
  if (/[A-Z]/.test(pwd) && /[a-z]/.test(pwd)) score++;
  if (/\d/.test(pwd)) score++;
  if (/[^A-Za-z0-9]/.test(pwd)) score++;
  // Plafond à 4
  score = Math.min(score, 4);
  const labels = [
    t("strength1"),
    t("strength2"),
    t("strength3"),
    t("strength4"),
    t("strength5"),
  ];
  return { score, label: labels[score] };
}

function translateAuthError(msg: string): string {
  const m = msg.toLowerCase();
  if (m.includes("same as the old"))
    return "Le nouveau mot de passe doit être différent de l'ancien.";
  if (m.includes("weak password") || m.includes("at least"))
    return "Mot de passe trop faible. Minimum 8 caractères avec lettres et chiffres.";
  if (m.includes("rate limit") || m.includes("too many"))
    return "Trop de tentatives. Réessayez dans quelques minutes.";
  if (m.includes("expired") || m.includes("invalid"))
    return "Lien de réinitialisation expiré ou invalide. Demandez-en un nouveau.";
  return msg;
}
