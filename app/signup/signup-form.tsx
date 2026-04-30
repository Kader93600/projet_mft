"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import {
  AlertCircle,
  CheckCircle2,
  User,
  Mail,
  Lock,
  ArrowRight,
  Loader2,
} from "lucide-react";

export function SignupForm() {
  const router = useRouter();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);
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
    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { full_name: fullName } },
    });
    if (error) {
      triggerShake();
      setError(translateAuthError(error.message));
      setLoading(false);
      return;
    }
    setSuccess(true);
    setTimeout(() => {
      router.push("/dashboard");
      router.refresh();
    }, 1800);
  }

  if (success) {
    return (
      <div
        role="status"
        className="relative overflow-hidden rounded-2xl bg-white border border-emerald-200 p-8 text-center"
      >
        {/* Halo festif */}
        <div
          aria-hidden
          className="absolute -top-20 left-1/2 -translate-x-1/2 h-64 w-96 rounded-full pointer-events-none opacity-50 motion-reduce:hidden"
          style={{
            background:
              "radial-gradient(closest-side, rgba(16,185,129,0.30), transparent 70%)",
          }}
        />
        {/* Confettis discrets */}
        <div
          aria-hidden
          className="absolute inset-0 pointer-events-none motion-reduce:hidden"
        >
          {[
            { l: "12%", t: "18%", c: "#10B981", d: 0, s: 5 },
            { l: "28%", t: "10%", c: "#9FE220", d: 0.1, s: 4 },
            { l: "48%", t: "16%", c: "#10B981", d: 0.2, s: 6 },
            { l: "70%", t: "8%", c: "#9FE220", d: 0.15, s: 5 },
            { l: "85%", t: "20%", c: "#10B981", d: 0.05, s: 4 },
            { l: "18%", t: "78%", c: "#9FE220", d: 0.3, s: 5 },
            { l: "44%", t: "82%", c: "#10B981", d: 0.4, s: 4 },
            { l: "76%", t: "76%", c: "#9FE220", d: 0.25, s: 5 },
          ].map((p, i) => (
            <span
              key={i}
              className="absolute rounded-full"
              style={{
                left: p.l,
                top: p.t,
                width: `${p.s}px`,
                height: `${p.s}px`,
                background: p.c,
                boxShadow: `0 0 10px ${p.c}`,
                opacity: 0.7,
                animation: `float-slow 4.5s ease-in-out ${p.d}s infinite, fade-up 0.8s ease-out ${p.d}s both`,
              }}
            />
          ))}
        </div>

        <div className="relative">
          <div
            className="mx-auto h-16 w-16 rounded-2xl bg-emerald-50 flex items-center justify-center"
            style={{ animation: "badge-unlock 0.7s both" }}
          >
            <CheckCircle2 className="h-8 w-8 text-emerald-600" />
          </div>
          <h3
            className="mt-5 font-display text-2xl font-semibold text-navy-950"
            style={{ animation: "fade-up 0.5s ease-out 0.2s both" }}
          >
            Bienvenue, {fullName.split(" ")[0] || "futur stagiaire"} !
          </h3>
          <p
            className="mt-2 text-sm text-slate-600 leading-relaxed max-w-xs mx-auto"
            style={{ animation: "fade-up 0.5s ease-out 0.3s both" }}
          >
            Votre compte est créé. Vérifiez vos emails pour valider votre
            adresse. Redirection en cours…
          </p>
          <div
            className="mt-6 inline-flex items-center gap-2 text-xs text-emerald-700 font-medium"
            style={{ animation: "fade-up 0.5s ease-out 0.4s both" }}
          >
            <Loader2 className="h-3.5 w-3.5 animate-spin motion-reduce:animate-none" />
            Préparation de votre espace…
          </div>
        </div>
      </div>
    );
  }

  return (
    <form
      onSubmit={onSubmit}
      className={
        "space-y-5 " +
        (shake ? "animate-[shake_0.5s_ease-in-out] motion-reduce:animate-none" : "")
      }
    >
      <div style={{ animation: "fade-up 0.4s ease-out both" }}>
        <Label htmlFor="fullName">Nom complet</Label>
        <div className="relative">
          <User className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input
            id="fullName"
            required
            autoComplete="name"
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
            placeholder="Prénom Nom"
            className="pl-10"
          />
        </div>
      </div>
      <div style={{ animation: "fade-up 0.4s ease-out 0.06s both" }}>
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
      <div style={{ animation: "fade-up 0.4s ease-out 0.12s both" }}>
        <Label htmlFor="password">Mot de passe</Label>
        <div className="relative">
          <Lock className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input
            id="password"
            type="password"
            required
            minLength={6}
            autoComplete="new-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Minimum 6 caractères"
            className="pl-10"
          />
        </div>
        <p className="mt-2 text-xs text-slate-500">
          Au moins 6 caractères. Évitez un mot de passe déjà utilisé ailleurs.
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
        disabled={loading}
        className="w-full group transition-transform active:scale-[0.98] motion-reduce:active:scale-100"
        size="lg"
        style={{ animation: "fade-up 0.4s ease-out 0.18s both" }}
      >
        {loading ? (
          <>
            <Loader2 className="h-4 w-4 animate-spin motion-reduce:animate-none" />
            Création…
          </>
        ) : (
          <>
            Créer mon compte
            <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0" />
          </>
        )}
      </Button>

      <p
        className="text-center text-xs text-slate-500"
        style={{ animation: "fade-up 0.4s ease-out 0.24s both" }}
      >
        En créant un compte, vous acceptez nos conditions d&apos;utilisation
        et notre politique de confidentialité.
      </p>
    </form>
  );
}

function translateAuthError(msg: string): string {
  const m = msg.toLowerCase();
  if (m.includes("already registered") || m.includes("already in use"))
    return "Cette adresse est déjà utilisée. Essayez de vous connecter.";
  if (m.includes("password") && m.includes("short"))
    return "Mot de passe trop court (6 caractères minimum).";
  if (m.includes("rate limit") || m.includes("too many"))
    return "Trop de tentatives. Réessayez dans quelques minutes.";
  if (m.includes("invalid email"))
    return "Adresse email invalide.";
  return msg;
}
