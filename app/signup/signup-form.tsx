"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { AlertCircle, CheckCircle2, User, Mail, Lock, ArrowRight } from "lucide-react";

export function SignupForm() {
  const router = useRouter();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

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
      setError(error.message);
      setLoading(false);
      return;
    }
    setSuccess(true);
    setTimeout(() => {
      router.push("/dashboard");
      router.refresh();
    }, 1500);
  }

  if (success) {
    return (
      <div className="flex items-start gap-3 rounded-xl bg-emerald-50 border border-emerald-200 px-4 py-4 text-emerald-800 text-sm">
        <CheckCircle2 className="h-5 w-5 mt-0.5 flex-none" />
        <div>
          <p className="font-semibold">Compte créé.</p>
          <p className="text-emerald-700/90">Vérifiez vos emails pour valider votre adresse. Redirection en cours…</p>
        </div>
      </div>
    );
  }

  return (
    <form onSubmit={onSubmit} className="space-y-5">
      <div>
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
      <div>
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
        <div className="flex items-start gap-2 rounded-xl bg-rose-50 border border-rose-200 px-3.5 py-3 text-sm text-rose-700">
          <AlertCircle className="h-4 w-4 mt-0.5 flex-none" />
          <span>{error}</span>
        </div>
      )}

      <Button type="submit" disabled={loading} className="w-full group" size="lg">
        {loading ? "Création…" : (
          <>
            Créer mon compte
            <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5" />
          </>
        )}
      </Button>

      <p className="text-center text-xs text-slate-500">
        En créant un compte, vous acceptez nos conditions d&apos;utilisation
        et notre politique de confidentialité.
      </p>
    </form>
  );
}
