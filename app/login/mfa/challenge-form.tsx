"use client";
import { useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { Card, CardBody } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { KeyRound, LogOut } from "lucide-react";

export function MfaChallengeForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const next = searchParams.get("next") || "/dashboard";
  const [code, setCode] = useState("");
  const [factorId, setFactorId] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      const supabase = createClient();
      const { data, error } = await supabase.auth.mfa.listFactors();
      if (error || !data) {
        setError(error?.message ?? "Aucun facteur trouvé");
        return;
      }
      const verified = (data.totp ?? []).find((f) => f.status === "verified");
      if (!verified) {
        // Pas de facteur → renvoi direct vers le flux normal
        router.replace(next);
        return;
      }
      setFactorId(verified.id);
    })();
  }, [next, router]);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    if (!factorId) return;
    setLoading(true);
    setError(null);
    const supabase = createClient();
    const { data: chal, error: chalErr } = await supabase.auth.mfa.challenge({
      factorId,
    });
    if (chalErr || !chal) {
      setLoading(false);
      setError(chalErr?.message ?? "Erreur");
      return;
    }
    const { error: verErr } = await supabase.auth.mfa.verify({
      factorId,
      challengeId: chal.id,
      code: code.trim(),
    });
    setLoading(false);
    if (verErr) {
      setError(verErr.message);
      setCode("");
      return;
    }
    router.replace(next);
    router.refresh();
  }

  async function logout() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.replace("/login");
  }

  return (
    <Card>
      <CardBody>
        <form onSubmit={submit} className="space-y-4">
          <div>
            <Label htmlFor="otp">Code à 6 chiffres</Label>
            <Input
              id="otp"
              autoFocus
              value={code}
              onChange={(e) =>
                setCode(e.target.value.replace(/\D/g, "").slice(0, 6))
              }
              inputMode="numeric"
              autoComplete="one-time-code"
              placeholder="123456"
              className="font-mono tracking-widest text-lg text-center"
              maxLength={6}
            />
          </div>
          {error && (
            <div className="text-sm text-rose-700 bg-rose-50 border border-rose-200 rounded-lg p-3">
              {error}
            </div>
          )}
          <Button
            type="submit"
            disabled={loading || code.length !== 6 || !factorId}
            className="w-full justify-center"
            variant="gold"
          >
            <KeyRound className="h-4 w-4" />
            {loading ? "Vérification…" : "Valider"}
          </Button>
          <button
            type="button"
            onClick={logout}
            className="w-full text-sm text-slate-500 hover:text-navy-900 inline-flex items-center justify-center gap-1.5 pt-2"
          >
            <LogOut className="h-3.5 w-3.5" /> Annuler & se déconnecter
          </button>
        </form>
      </CardBody>
    </Card>
  );
}
