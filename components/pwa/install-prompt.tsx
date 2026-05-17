"use client";

// =====================================================================
// PWA install prompt
//
// Chrome / Edge / Samsung Internet émettent l'évènement
// `beforeinstallprompt` lorsque les critères PWA sont remplis (manifest
// valide + service worker enregistré + HTTPS + critères d'engagement).
// On intercepte cet évènement pour différer le prompt natif et le
// déclencher au clic sur notre bouton "Installer l'application".
//
// iOS Safari n'émet PAS cet évènement → on affiche un message
// d'instructions manuelles (Partager → Sur l'écran d'accueil).
//
// Anti-spam :
//   - Si l'utilisateur clique "Plus tard", on attend 7 jours avant de
//     re-proposer (localStorage `mft.pwa-install.snoozed-until`).
//   - Si l'app est déjà installée (display-mode: standalone), on
//     n'affiche rien.
//   - Si l'utilisateur a explicitement refusé l'install natif, on
//     n'insiste plus (localStorage `mft.pwa-install.dismissed`).
// =====================================================================

import { useEffect, useState } from "react";
import { Download, Smartphone, X } from "lucide-react";

const STORAGE_KEYS = {
  snoozedUntil: "mft.pwa-install.snoozed-until",
  dismissed: "mft.pwa-install.dismissed",
};

const SNOOZE_MS = 7 * 24 * 60 * 60 * 1000; // 7 jours

type DeferredPrompt = Event & {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
};

function isStandalone(): boolean {
  if (typeof window === "undefined") return false;
  return (
    window.matchMedia?.("(display-mode: standalone)").matches ||
    // iOS Safari
    // @ts-expect-error : propriété non-standard
    window.navigator?.standalone === true
  );
}

function isIos(): boolean {
  if (typeof window === "undefined") return false;
  const ua = window.navigator.userAgent;
  return /iPhone|iPad|iPod/i.test(ua) && !/CriOS|FxiOS|EdgiOS/.test(ua);
}

export function PwaInstallPrompt() {
  const [deferred, setDeferred] = useState<DeferredPrompt | null>(null);
  const [showIosHint, setShowIosHint] = useState(false);
  const [hidden, setHidden] = useState(true);

  useEffect(() => {
    if (typeof window === "undefined") return;
    if (isStandalone()) return; // déjà installée
    if (localStorage.getItem(STORAGE_KEYS.dismissed) === "1") return;

    const snoozedUntil = Number(localStorage.getItem(STORAGE_KEYS.snoozedUntil) || 0);
    if (snoozedUntil > Date.now()) return;

    const onBeforeInstall = (e: Event) => {
      e.preventDefault();
      setDeferred(e as DeferredPrompt);
      setHidden(false);
    };

    window.addEventListener("beforeinstallprompt", onBeforeInstall);

    // iOS Safari : pas d'évènement → on propose l'install manuelle
    // après 5 s pour ne pas perturber le premier rendu.
    let iosTimer: number | undefined;
    if (isIos()) {
      iosTimer = window.setTimeout(() => {
        setShowIosHint(true);
        setHidden(false);
      }, 5000);
    }

    const onInstalled = () => {
      // Une fois installée : on n'affiche plus le prompt.
      setDeferred(null);
      setShowIosHint(false);
      setHidden(true);
      localStorage.setItem(STORAGE_KEYS.dismissed, "1");
    };
    window.addEventListener("appinstalled", onInstalled);

    return () => {
      window.removeEventListener("beforeinstallprompt", onBeforeInstall);
      window.removeEventListener("appinstalled", onInstalled);
      if (iosTimer) window.clearTimeout(iosTimer);
    };
  }, []);

  if (hidden) return null;

  const snooze = () => {
    localStorage.setItem(
      STORAGE_KEYS.snoozedUntil,
      String(Date.now() + SNOOZE_MS)
    );
    setHidden(true);
  };

  const dismissForever = () => {
    localStorage.setItem(STORAGE_KEYS.dismissed, "1");
    setHidden(true);
  };

  const install = async () => {
    if (!deferred) return;
    try {
      await deferred.prompt();
      const choice = await deferred.userChoice;
      if (choice.outcome === "dismissed") {
        // Refus utilisateur → on n'insiste plus.
        dismissForever();
      }
      setDeferred(null);
      setHidden(true);
    } catch {
      setHidden(true);
    }
  };

  return (
    <div
      role="dialog"
      aria-labelledby="pwa-install-title"
      className={[
        "fixed bottom-4 left-4 right-4 md:left-auto md:right-6 md:bottom-6 md:max-w-sm z-[95]",
        "rounded-2xl border border-navy-100 bg-white shadow-raised",
        "p-4 pr-10",
      ].join(" ")}
    >
      <button
        type="button"
        onClick={snooze}
        aria-label="Plus tard"
        className="absolute right-2 top-2 text-slate-400 hover:text-navy-900 transition-colors"
      >
        <X className="h-3.5 w-3.5" />
      </button>

      <div className="flex items-start gap-3">
        <div className="h-10 w-10 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center shrink-0">
          {showIosHint ? (
            <Smartphone className="h-5 w-5" />
          ) : (
            <Download className="h-5 w-5" />
          )}
        </div>
        <div className="min-w-0 flex-1">
          <h3
            id="pwa-install-title"
            className="font-display font-semibold text-navy-900 text-[15px] leading-snug"
          >
            {showIosHint
              ? "Ajouter à l'écran d'accueil"
              : "Installer MA FORMATION TRANSPORT"}
          </h3>
          <p className="text-xs text-slate-600 mt-1 leading-relaxed">
            {showIosHint ? (
              <>
                Sur iOS, tapez{" "}
                <span aria-label="bouton partager" className="font-medium">
                  Partager
                </span>{" "}
                puis{" "}
                <span className="font-medium">Sur l&apos;écran d&apos;accueil</span>{" "}
                pour accéder à vos modules en un clic et continuer hors ligne.
              </>
            ) : (
              <>
                Accès rapide depuis votre écran d&apos;accueil. Consultez vos
                modules même sans connexion.
              </>
            )}
          </p>

          <div className="mt-3 flex flex-wrap gap-2">
            {!showIosHint && (
              <button
                type="button"
                onClick={install}
                disabled={!deferred}
                className={[
                  "inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5",
                  "text-sm font-medium text-white",
                  "bg-navy-900 hover:bg-navy-800 transition-colors",
                  "focus:outline-none focus:ring-2 focus:ring-gold-400 focus:ring-offset-2",
                  !deferred && "opacity-50 cursor-not-allowed",
                ].join(" ")}
              >
                <Download className="h-3.5 w-3.5" />
                Installer
              </button>
            )}
            <button
              type="button"
              onClick={snooze}
              className="inline-flex items-center rounded-lg px-3 py-1.5 text-sm font-medium text-slate-600 hover:text-navy-900 hover:bg-navy-50 transition-colors"
            >
              Plus tard
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
