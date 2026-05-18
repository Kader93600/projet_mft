"use client";

// =====================================================================
// ShareCard — Hero du programme de parrainage.
//
// Affiche le code unique du stagiaire en grand, avec :
//   • Copie en 1 clic du code seul
//   • Copie d'un lien d'invitation pré-construit
//   • Bouton de partage natif (Web Share API) sur mobile
//   • Bouton WhatsApp avec message pré-rempli
//   • Bouton email avec sujet + corps pré-remplis
//
// Couleurs : palette gold/navy MFT. Pas de glassmorphism, pas de gradient
// text. Tags Markdown autorisés dans la pré-rédaction des messages.
// =====================================================================

import { useState } from "react";
import { Card, CardBody } from "@/components/ui/card";
import { Copy, Check, Share2, Mail, MessageCircle, Link2 } from "lucide-react";

const SHARE_INTRO = `Salut ! Je suis sur MA FORMATION TRANSPORT pour préparer mon titre pro. Si tu envisages la même chose, prends mon code parrainage : tu auras 10 % de réduction et tu m'aideras à débloquer un avantage. À très vite !`;

export function ShareCard({ code }: { code: string }) {
  const [copied, setCopied] = useState<"code" | "link" | null>(null);

  const baseUrl =
    typeof window !== "undefined" ? window.location.origin : "https://maformationtransport.fr";
  const inviteLink = `${baseUrl}/inscription?ref=${encodeURIComponent(code)}`;

  const fullMessage = `${SHARE_INTRO}\n\nMon code : ${code}\nInscription : ${inviteLink}`;

  const copyToClipboard = async (value: string, kind: "code" | "link") => {
    try {
      await navigator.clipboard.writeText(value);
      setCopied(kind);
      setTimeout(() => setCopied(null), 2000);
    } catch {
      // Fallback minimal — pas dramatique sur navigateur ancien
      window.prompt("Copiez le contenu :", value);
    }
  };

  const shareNative = async () => {
    if (typeof navigator === "undefined" || !navigator.share) return;
    try {
      await navigator.share({
        title: "MA FORMATION TRANSPORT — Code de parrainage",
        text: SHARE_INTRO,
        url: inviteLink,
      });
    } catch {
      // L'utilisateur a annulé, pas grave
    }
  };

  const whatsappUrl = `https://wa.me/?text=${encodeURIComponent(fullMessage)}`;
  const mailtoUrl = `mailto:?subject=${encodeURIComponent(
    "Une formation pro qui vaut le coup"
  )}&body=${encodeURIComponent(fullMessage)}`;

  const canShareNative =
    typeof navigator !== "undefined" && typeof navigator.share === "function";

  return (
    <Card variant="solid-navy" className="relative overflow-hidden">
      <div className="absolute inset-0 bg-mesh-navy opacity-40" aria-hidden />
      <CardBody className="relative p-6 sm:p-8 grid lg:grid-cols-[1fr_auto] gap-6 items-center">
        <div>
          <div className="text-[11px] uppercase tracking-wider text-gold-300 font-medium">
            Votre code de parrainage
          </div>
          <div className="mt-2 flex items-center gap-2 flex-wrap">
            <code className="font-display text-3xl sm:text-4xl font-bold text-white tabular-nums tracking-wider select-all">
              {code}
            </code>
            <button
              type="button"
              onClick={() => copyToClipboard(code, "code")}
              aria-label="Copier le code"
              className="h-9 w-9 rounded-lg bg-white/10 hover:bg-white/15 border border-white/15 text-white flex items-center justify-center transition-colors"
            >
              {copied === "code" ? (
                <Check className="h-4 w-4 text-signal-400" />
              ) : (
                <Copy className="h-4 w-4" />
              )}
            </button>
          </div>
          <p className="mt-4 text-sm text-white/70 max-w-md">
            Communiquez ce code à votre filleul ou partagez le lien
            d'inscription préparé ci-contre.
          </p>
        </div>

        <div className="flex flex-col gap-2 lg:min-w-[240px]">
          <button
            type="button"
            onClick={() => copyToClipboard(inviteLink, "link")}
            className="inline-flex items-center justify-between gap-2 rounded-xl bg-white/10 hover:bg-white/15 border border-white/15 text-white px-4 py-2.5 text-sm font-medium transition-colors"
          >
            <span className="inline-flex items-center gap-2">
              <Link2 className="h-4 w-4" />
              {copied === "link" ? "Lien copié" : "Copier le lien"}
            </span>
            {copied === "link" ? (
              <Check className="h-3.5 w-3.5 text-signal-400" />
            ) : (
              <Copy className="h-3.5 w-3.5 text-white/60" />
            )}
          </button>

          <a
            href={whatsappUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-white px-4 py-2.5 text-sm font-medium transition-colors"
          >
            <MessageCircle className="h-4 w-4" />
            Partager sur WhatsApp
          </a>

          <a
            href={mailtoUrl}
            className="inline-flex items-center gap-2 rounded-xl bg-white/10 hover:bg-white/15 border border-white/15 text-white px-4 py-2.5 text-sm font-medium transition-colors"
          >
            <Mail className="h-4 w-4" />
            Envoyer par email
          </a>

          {canShareNative && (
            <button
              type="button"
              onClick={shareNative}
              className="inline-flex items-center gap-2 rounded-xl bg-gold-500 hover:bg-gold-400 text-navy-900 px-4 py-2.5 text-sm font-medium transition-colors"
            >
              <Share2 className="h-4 w-4" />
              Partager
            </button>
          )}
        </div>
      </CardBody>
    </Card>
  );
}
