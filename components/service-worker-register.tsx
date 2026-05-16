"use client";

/**
 * Enregistre /sw.js au chargement de la page pour activer :
 *   • le précache de la page /offline
 *   • la fonctionnalité PWA installable (bannière d'install navigateur)
 *
 * Idempotent : `navigator.serviceWorker.register` réutilise une
 * registration existante. lib/push.ts peut donc aussi appeler register
 * sans conflit pour les Web Push notifications.
 *
 * Désactivé en développement pour éviter le cache agressif qui pourrait
 * masquer les changements de code en local.
 */
import { useEffect } from "react";

export function ServiceWorkerRegister() {
  useEffect(() => {
    if (typeof window === "undefined") return;
    if (!("serviceWorker" in navigator)) return;
    if (process.env.NODE_ENV !== "production") return;

    const register = () => {
      navigator.serviceWorker
        .register("/sw.js", { scope: "/" })
        .catch((err) => {
          // eslint-disable-next-line no-console
          console.warn("[SW] register failed", err);
        });
    };

    // Attend que la page soit complètement chargée pour ne pas
    // ralentir le rendering critique.
    if (document.readyState === "complete") {
      register();
    } else {
      window.addEventListener("load", register, { once: true });
    }
  }, []);

  return null;
}
