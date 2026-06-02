"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
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
  PartyPopper,
} from "lucide-react";

/**
 * Formulaire d'activation de compte (invitation).
 *
 * Pré-requis : /auth/callback a déjà établi la session via verifyOtp
 * (flux token_hash) ou exchangeCodeForSession (flux PKCE). Ici on :
 *   1. vérifie la présence de la session (sinon lien invalide/expiré)
 *   2. définit le mot de passe (updateUser) — c'est ce qui "active" le compte
 *   3. exige l'acceptation des CGU
 *   4. redirige vers le dashboard (le middleware route ensuite l'onboarding)
 */
export function AcceptInvitationForm() {
  const router = useRouter();
  const [hasSession, setHasSession] = useState<"checking" | "yes" | "no">(
    "checking"
  );
  const [email, setEmail] = useState<string | null>(null);
  const [pwd, setPwd] = useState("");
  const [pwd2, setPwd2] = useState("");
  const [show, setShow] = useState(false);
  const [cgu, setCgu] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  useEffect(() => {
    const supabase = createClient();
    let mounted = true;
    supabase.auth.getSession().then(({ data }) => {
      if (!mounted) return;
      if (data.session) {
        setHasSession("yes");
        setEmail(data.session.user.email ?? null);
      } else {
        setHasSession("no");
      }
    });
    return () => {
      mounted = false;
    };
  }, []);

  const strength = scorePassword(pwd);
  const meetsRules = strength.score >= 3 && pwd.length >= 10;

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (pwd !== pwd2) {
      setError("Les deux mots de passe ne correspondent pas.");
      return;
    }
    if (!meetsRules) {
      setError(
        "Mot de passe trop faible : 10 caractères minimum, avec majuscules, chiffres et symboles."
      );
      return;
    }
    if (!cgu) {
      setError("Vous devez accepter les conditions générales pour continuer.");
      return;
    }
    setLoading(true);
    const supabase = createClient();
    const { error: upErr } = await supabase.auth.updateUser({
      password: pwd,
      data: { cgu_accepted_at: new Date().toISOString() },
    });
    if (upErr) {
      setError(translateAuthError(upErr.message));
      setLoading(false);
      return;
    }
    setSuccess(true);
    // Laisse l'animation de succès se jouer, puis entre dans l'espace.
    setTimeout(() => {
      router.push("/dashboard");
      router.refresh();
    }, 1600);
  }

  // ── Vérification du lien en cours ──
  if (hasSession === "checking") {
    return (
      <div className="flex flex-col items-center gap-3 py-10 text-slate-600 dark:text-[hsl(var(--text-muted))]">
        <Loader2 className="h-6 w-6 animate-spin text-brand-600 motion-reduce:animate-none" />
        <span className="text-sm">Vérification de votre invitation…</span>
      </div>
    );
  }

  // ── Lien invalide / expiré ──
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
            <div className="font-semibold">Lien d'invitation invalide</div>
            <p className="mt-1 text-rose-700/90">
              Ce lien a peut-être expiré ou a déjà été utilisé. Demandez à
              votre centre de formation de vous renvoyer une invitation.
            </p>
          </div>
        </div>
        <Link
          href="/invitation-expiree"
          className="inline-flex w-full items-center justify-center gap-2 rounded-xl bg-navy-900 px-4 py-3 text-sm font-semibold text-white hover:bg-navy-800 transition-colors active:scale-[0.98] motion-reduce:active:scale-100"
        >
          En savoir plus
          <ArrowRight className="h-4 w-4" />
        </Link>
      </div>
    );
  }

  // ── Succès ──
  if (success) {
    return (
      <div
        role="status"
        className="flex flex-col items-center gap-4 py-8 text-center"
        style={{ animation: "fade-up 0.4s ease-out both" }}
      >
        <div
          className="h-16 w-16 rounded-full bg-emerald-100 grid place-items-center"
          style={{ animation: "fade-up 0.45s cubic-bezier(0.23,1,0.32,1) both" }}
        >
          <PartyPopper className="h-8 w-8 text-emerald-700" />
        </div>
        <div>
          <div className="font-display text-xl font-semibold text-navy-900 dark:text-[hsl(var(--text))]">
            Compte activé
          </div>
          <p className="mt-1.5 text-sm text-slate-600 dark:text-[hsl(var(--text-muted))]">
            Bienvenue ! Nous vous emmenons dans votre espace…
          </p>
        </div>
        <Loader2 className="h-5 w-5 animate-spin text-brand-600 motion-reduce:animate-none" />
      </div>
    );
  }

  // ── Formulaire ──
  return (
    <form onSubmit={onSubmit} className="space-y-5">
      {email && (
        <div
          className="flex items-center gap-2.5 rounded-xl bg-navy-50 border border-navy-100 px-3.5 py-2.5 text-sm dark:bg-[hsl(var(--surface-2))] dark:border-[hsl(var(--border))]"
          style={{ animation: "fade-up 0.4s ease-out both" }}
        >
          <ShieldCheck className="h-4 w-4 text-emerald-600 flex-none" />
          <span className="text-slate-600 dark:text-[hsl(var(--text-muted))]">
            Invitation vérifiée pour{" "}
            <span className="font-semibold text-navy-900 dark:text-[hsl(var(--text))]">
              {email}
            </span>
          </span>
        </div>
      )}

      <div style={{ animation: "fade-up 0.4s ease-out 0.04s both" }}>
        <Label htmlFor="pwd">Mot de passe</Label>
        <div className="relative">
          <Lock className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input
            id="pwd"
            type={show ? "text" : "password"}
            required
            minLength={10}
            autoComplete="new-password"
            value={pwd}
            onChange={(e) => setPwd(e.target.value)}
            placeholder="Au moins 10 caractères"
            className="pl-10 pr-11"
          />
          <button
            type="button"
            onClick={() => setShow((v) => !v)}
            aria-label={show ? "Masquer le mot de passe" : "Afficher le mot de passe"}
            className="absolute right-3 top-1/2 -translate-y-1/2 h-7 w-7 rounded-md grid place-items-center text-slate-400 hover:text-navy-700 hover:bg-navy-50 transition-colors"
          >
            {show ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
          </button>
        </div>

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
              Sécurité : <span className="font-medium">{strength.label}</span>
            </div>
          </div>
        )}
      </div>

      <div style={{ animation: "fade-up 0.4s ease-out 0.08s both" }}>
        <Label htmlFor="pwd2">Confirmer le mot de passe</Label>
        <div className="relative">
          <Lock className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input
            id="pwd2"
            type={show ? "text" : "password"}
            required
            minLength={10}
            autoComplete="new-password"
            value={pwd2}
            onChange={(e) => setPwd2(e.target.value)}
            placeholder="Retapez votre mot de passe"
            className="pl-10"
          />
        </div>
        {pwd2 && pwd !== pwd2 && (
          <p className="mt-1.5 text-[11px] text-rose-700">
            Les mots de passe ne correspondent pas.
          </p>
        )}
        {pwd2 && pwd && pwd === pwd2 && (
          <p className="mt-1.5 text-[11px] text-emerald-700 inline-flex items-center gap-1">
            <Check className="h-3 w-3" />
            Les mots de passe correspondent.
          </p>
        )}
      </div>

      <label
        className="flex items-start gap-2.5 text-sm text-slate-600 dark:text-[hsl(var(--text-muted))] cursor-pointer select-none"
        style={{ animation: "fade-up 0.4s ease-out 0.12s both" }}
      >
        <input
          type="checkbox"
          checked={cgu}
          onChange={(e) => setCgu(e.target.checked)}
          className="mt-0.5 h-4 w-4 rounded border-navy-300 text-brand-600 focus:ring-brand-500"
        />
        <span>
          J'accepte les{" "}
          <Link
            href="/cgu"
            target="_blank"
            className="text-brand-700 underline underline-offset-2 hover:text-brand-900"
          >
            conditions générales
          </Link>{" "}
          et la{" "}
          <Link
            href="/confidentialite"
            target="_blank"
            className="text-brand-700 underline underline-offset-2 hover:text-brand-900"
          >
            politique de confidentialité
          </Link>
          .
        </span>
      </label>

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
        disabled={loading || !meetsRules || pwd !== pwd2 || !cgu}
        className="w-full group transition-transform active:scale-[0.98] motion-reduce:active:scale-100"
        size="lg"
        style={{ animation: "fade-up 0.4s ease-out 0.16s both" }}
      >
        {loading ? (
          <>
            <Loader2 className="h-4 w-4 animate-spin motion-reduce:animate-none" />
            Activation…
          </>
        ) : (
          <>
            Activer mon compte
            <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0" />
          </>
        )}
      </Button>
    </form>
  );
}

/* ─── Helpers ─────────────────────────────────────────────────────── */

function scorePassword(pwd: string): { score: number; label: string } {
  if (!pwd) return { score: 0, label: "—" };
  let score = 0;
  if (pwd.length >= 10) score++;
  if (pwd.length >= 14) score++;
  if (/[A-Z]/.test(pwd) && /[a-z]/.test(pwd)) score++;
  if (/\d/.test(pwd)) score++;
  if (/[^A-Za-z0-9]/.test(pwd)) score++;
  score = Math.min(score, 4);
  const labels = ["Très faible", "Faible", "Moyen", "Bon", "Excellent"];
  return { score, label: labels[score] };
}

function translateAuthError(msg: string): string {
  const m = msg.toLowerCase();
  if (m.includes("same as the old"))
    return "Le mot de passe doit être différent du précédent.";
  if (m.includes("weak password") || m.includes("at least"))
    return "Mot de passe trop faible. Minimum 10 caractères avec lettres, chiffres et symboles.";
  if (m.includes("rate limit") || m.includes("too many"))
    return "Trop de tentatives. Réessayez dans quelques minutes.";
  if (m.includes("expired") || m.includes("invalid") || m.includes("session"))
    return "Votre session d'activation a expiré. Demandez une nouvelle invitation.";
  return msg;
}
