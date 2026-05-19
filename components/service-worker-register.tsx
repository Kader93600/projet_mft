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
 *
 * Kill-switch SW_CACHE_PURGE_VERSION : bump cette constante pour forcer
 * une purge complète des caches CacheStorage à la prochaine visite des
 * users. Utile après une migration data ou un fix qui rend l'ancien
 * HTML obsolète (dashboard fossilisé, etc.). Le flag est stocké dans
 * localStorage pour ne purger qu'une seule fois par version par user.
 */
import { useEffect } from "react";

const SW_CACHE_PURGE_VERSION = "2026-05-19-dashboard-fix";
const SW_CACHE_PURGE_KEY = "mft.sw.last_purge_version";

async function purgeAllCachesOnce() {
  try {
    if (
      typeof window === "undefined" ||
      typeof caches === "undefined" ||
      window.localStorage.getItem(SW_CACHE_PURGE_KEY) === SW_CACHE_PURGE_VERSION
    ) {
      return;
    }

    // Purge l'intégralité des CacheStorage (mft-v2-static, mft-v2-content,
    // mft-v3-*, et tout autre cache résiduel). Ne casse pas les futures
    // requêtes : Next.js recharge tout depuis le réseau.
    const keys = await caches.keys();
    await Promise.all(keys.map((k) => caches.delete(k)));

    // Désenregistre toutes les registrations SW existantes : le SW
    // suivant sera réinstallé proprement depuis /sw.js.
    if ("serviceWorker" in navigator) {
      const regs = await navigator.serviceWorker.getRegistrations();
      await Promise.all(regs.map((r) => r.unregister()));
    }

    window.localStorage.setItem(SW_CACHE_PURGE_KEY, SW_CACHE_PURGE_VERSION);

    // Reload une seule fois pour repartir d'une session 100% propre,
    // sinon la page courante reste rendue avec le HTML obsolète.
    window.location.reload();
  } catch (err) {
    // eslint-disable-next-line no-console
    console.warn("[SW] purge failed", err);
  }
}

export function ServiceWorkerRegister() {
  useEffect(() => {
    if (typeof window === "undefined") return;
    if (!("serviceWorker" in navigator)) return;
    if (process.env.NODE_ENV !== "production") return;

    const boot = async () => {
      // Kill-switch : purge unique des caches obsolètes
      await purgeAllCachesOnce();

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
      void boot();
    } else {
      window.addEventListener("load", () => void boot(), { once: true });
    }
  }, []);

  return null;
}
