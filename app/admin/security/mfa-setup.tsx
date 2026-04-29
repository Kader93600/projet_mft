"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { ShieldCheck, KeyRound, Copy, Check } from "lucide-react";

interface EnrollResult {
  factorId: string;
  qrSvg: string;
  secret: string;
  uri: string;
}

export function MfaSetup() {
  const router = useRouter();
  const [enroll, setEnroll] = useState<EnrollResult | null>(null);
  const [code, setCode] = useState("");
  const [friendlyName, setFriendlyName] = useState("Mon téléphone");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);

  async function startEnroll() {
    setLoading(true);
    setError(null);
    const supabase = createClient();
    const { data, error } = await supabase.auth.mfa.enroll({
      factorType: "totp",
      friendlyName,
    });
    setLoading(false);
    if (error || !data) {
      setError(error?.message ?? "Impossible de démarrer l'enrôlement");
      return;
    }
    setEnroll({
      factorId: data.id,
      qrSvg: data.totp.qr_code,
      secret: data.totp.secret,
      uri: data.totp.uri,
    });
  }

  async function verify() {
    if (!enroll) return;
    setLoading(true);
    setError(null);
    const supabase = createClient();
    const { data: chal, error: chalErr } = await supabase.auth.mfa.challenge({
      factorId: enroll.factorId,
    });
    if (chalErr || !chal) {
      setLoading(false);
      setError(chalErr?.message ?? "Erreur lors du défi");
      return;
    }
    const { error: verErr } = await supabase.auth.mfa.verify({
      factorId: enroll.factorId,
      challengeId: chal.id,
      code: code.trim(),
    });
    setLoading(false);
    if (verErr) {
      setError(verErr.message);
      return;
    }
    setEnroll(null);
    setCode("");
    router.refresh();
  }

  async function copySecret() {
    if (!enroll) return;
    try {
      await navigator.clipboard.writeText(enroll.secret);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {}
  }

  if (!enroll) {
    return (
      <div className="space-y-4">
        <div>
          <Label htmlFor="friendly">Nom du facteur</Label>
          <Input
            id="friendly"
            value={friendlyName}
            onChange={(e) => setFriendlyName(e.target.value)}
            placeholder="Mon téléphone"
            maxLength={64}
          />
        </div>
        <Button onClick={startEnroll} disabled={loading}>
          <ShieldCheck className="h-4 w-4" />
          {loading ? "Préparation…" : "Générer le QR code"}
        </Button>
        {error && (
          <div className="text-sm text-rose-700 bg-rose-50 border border-rose-200 rounded-lg p-3">
            {error}
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="space-y-5">
      <div className="grid md:grid-cols-2 gap-6 items-start">
        <div className="rounded-2xl border border-navy-100 bg-ivory p-4 flex justify-center">
          <div className="bg-white p-3 rounded-lg">
            {/* Supabase renvoie une data URL (data:image/svg+xml;utf-8,...) */}
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={enroll.qrSvg}
              alt="QR code TOTP — scanner avec votre application d'authentification"
              className="h-44 w-44"
            />
          </div>
        </div>
        <div className="space-y-3">
          <div>
            <div className="text-xs uppercase tracking-wider text-slate-500 mb-1">
              Clé secrète (saisie manuelle)
            </div>
            <div className="flex items-center gap-2">
              <code className="flex-1 px-3 py-2 rounded-lg bg-navy-50 text-navy-900 text-xs font-mono break-all">
                {enroll.secret}
              </code>
              <button
                type="button"
                onClick={copySecret}
                className="h-9 w-9 rounded-lg border border-navy-200 hover:bg-navy-50 flex items-center justify-center"
                aria-label="Copier"
              >
                {copied ? (
                  <Check className="h-4 w-4 text-emerald-700" />
                ) : (
                  <Copy className="h-4 w-4 text-slate-600" />
                )}
              </button>
            </div>
          </div>
          <div className="text-xs text-slate-500">
            Conservez cette clé hors-ligne dans un endroit sûr — elle vous
            permet de récupérer l'accès en cas de perte de l'appareil.
          </div>
        </div>
      </div>

      <div className="border-t border-navy-100 pt-5">
        <Label htmlFor="otp">Code à 6 chiffres généré par votre application</Label>
        <div className="flex items-center gap-2 mt-1">
          <Input
            id="otp"
            value={code}
            onChange={(e) =>
              setCode(e.target.value.replace(/\D/g, "").slice(0, 6))
            }
            inputMode="numeric"
            autoComplete="one-time-code"
            placeholder="123456"
            className="font-mono tracking-widest text-lg"
            maxLength={6}
          />
          <Button
            onClick={verify}
            disabled={loading || code.length !== 6}
            variant="gold"
          >
            <KeyRound className="h-4 w-4" />
            Activer
          </Button>
        </div>
        {error && (
          <div className="mt-2 text-sm text-rose-700 bg-rose-50 border border-rose-200 rounded-lg p-3">
            {error}
          </div>
        )}
      </div>
    </div>
  );
}
