"use client";
import { useEffect, useRef, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import type { EmailOtpType } from "@supabase/supabase-js";
import { createClient } from "@/lib/supabase/client";
import { Loader2, AlertCircle, ArrowRight, ShieldCheck } from "lucide-react";

/**
 * Vérifie le jeton d'invitation/recovery CÔTÉ CLIENT (anti-prefetch).
 *
 * Un scanner de liens (Outlook Safe Links, antivirus) fait un GET sans
 * exécuter ce JS → il ne consomme donc pas le lien à usage unique.
 * Seul un vrai navigateur déclenche verifyOtp ici.
 *
 * Deux formes de lien tolérées :
 *  - ?token_hash=...&type=invite|recovery   (recommandé, PKCE-safe)
 *  - #access_token=...&refresh_token=...     (lien implicite historique)
 */
export function ActivateClient() {
  const router = useRouter();
  const params = useSearchParams();
  const [phase, setPhase] = useState<"verifying" | "error">("verifying");
  const [message, setMessage] = useState<string>("");
  const ran = useRef(false);

  useEffect(() => {
    if (ran.current) return; // évite la double exécution en mode strict
    ran.current = true;

    const supabase = createClient();
    const next = sanitizeNext(params.get("next"));

    async function run() {
      const tokenHash = params.get("token_hash");
      const type = (params.get("type") as EmailOtpType | null) ?? "invite";

      // ── Cas 1 : token_hash en query ──
      if (tokenHash) {
        const { error } = await supabase.auth.verifyOtp({
          type,
          token_hash: tokenHash,
        });
        if (!error) return router.replace(next);
        return fail(error.message);
      }

      // ── Cas 2 : tokens dans le fragment (#access_token=…) ──
      if (typeof window !== "undefined" && window.location.hash) {
        const hash = new URLSearchParams(window.location.hash.slice(1));
        const access_token = hash.get("access_token");
        const refresh_token = hash.get("refresh_token");
        const hashError = hash.get("error_description") || hash.get("error");
        if (access_token && refresh_token) {
          const { error } = await supabase.auth.setSession({
            access_token,
            refresh_token,
          });
          if (!error) return router.replace(next);
          return fail(error.message);
        }
        if (hashError) return fail(hashError);
      }

      // ── Déjà connecté ? (lien rejoué après succès) ──
      const { data } = await supabase.auth.getSession();
      if (data.session) return router.replace(next);

      fail("Lien invalide ou incomplet.");
    }

    function fail(_raw: string) {
      setMessage(
        "Ce lien d'invitation a expiré ou a déjà été utilisé. Demandez un nouveau lien, nous vous l'envoyons aussitôt."
      );
      setPhase("error");
    }

    run();
  }, [params, router]);

  if (phase === "verifying") {
    return (
      <div className="flex flex-col items-center gap-4 py-10 text-center">
        <div className="relative">
          <Loader2 className="h-9 w-9 animate-spin text-brand-600 motion-reduce:animate-none" />
        </div>
        <div>
          <div className="font-display text-lg font-semibold text-navy-900 dark:text-[hsl(var(--text))]">
            Vérification en cours
          </div>
          <p className="mt-1 text-sm text-slate-600 dark:text-[hsl(var(--text-muted))]">
            Validation de votre lien d'invitation…
          </p>
        </div>
      </div>
    );
  }

  return (
    <div
      role="alert"
      className="space-y-4"
      style={{ animation: "fade-up 0.4s ease-out both" }}
    >
      <div className="flex items-start gap-3 rounded-xl bg-rose-50 border border-rose-200 px-4 py-4 text-sm text-rose-800">
        <AlertCircle className="h-5 w-5 mt-0.5 flex-none" />
        <div>
          <div className="font-semibold">Lien expiré ou déjà utilisé</div>
          <p className="mt-1 text-rose-700/90">{message}</p>
        </div>
      </div>
      <Link
        href="/invitation-expiree"
        className="inline-flex w-full items-center justify-center gap-2 rounded-xl bg-navy-900 px-4 py-3 text-sm font-semibold text-white hover:bg-navy-800 transition-colors active:scale-[0.98] motion-reduce:active:scale-100"
      >
        Recevoir un nouveau lien
        <ArrowRight className="h-4 w-4" />
      </Link>
      <p className="flex items-center justify-center gap-1.5 text-[11px] text-slate-400">
        <ShieldCheck className="h-3 w-3" />
        Lien sécurisé à usage unique
      </p>
    </div>
  );
}

function sanitizeNext(next: string | null): string {
  if (next && next.startsWith("/") && !next.startsWith("//")) return next;
  return "/bienvenue";
}
