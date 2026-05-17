"use client";

// =====================================================================
// Indicateur réseau global.
//
// Affiche un bandeau sticky discret en haut de l'écran quand l'onglet
// passe en `offline`. Disparaît automatiquement au retour de la
// connectivité avec un court flash vert "reconnecté".
//
// Implémentation volontairement légère :
//   - écoute des events `online` / `offline` du navigateur
//   - aucun ping serveur (le SW gère déjà le cache offline)
//   - aria-live pour annonce aux lecteurs d'écran
// =====================================================================

import { useEffect, useState } from "react";
import { CloudOff, Wifi } from "lucide-react";

export function OfflineIndicator() {
  const [online, setOnline] = useState<boolean>(true);
  const [showReconnected, setShowReconnected] = useState(false);

  useEffect(() => {
    if (typeof navigator === "undefined") return;

    // État initial
    setOnline(navigator.onLine);

    const onOnline = () => {
      setOnline(true);
      setShowReconnected(true);
      window.setTimeout(() => setShowReconnected(false), 2500);
    };
    const onOffline = () => {
      setOnline(false);
      setShowReconnected(false);
    };

    window.addEventListener("online", onOnline);
    window.addEventListener("offline", onOffline);
    return () => {
      window.removeEventListener("online", onOnline);
      window.removeEventListener("offline", onOffline);
    };
  }, []);

  // Aucun bandeau si tout va bien et qu'on n'a pas eu de bascule récente
  if (online && !showReconnected) return null;

  return (
    <div
      role="status"
      aria-live="polite"
      className={[
        "fixed top-2 left-1/2 -translate-x-1/2 z-[99]",
        "inline-flex items-center gap-2 rounded-full px-3.5 py-1.5",
        "text-xs font-medium shadow-soft",
        "transition-all duration-400",
        online
          ? "bg-emerald-50 text-emerald-800 border border-emerald-200"
          : "bg-rose-50 text-rose-800 border border-rose-200",
      ].join(" ")}
      style={{ transitionTimingFunction: "cubic-bezier(0.19, 1, 0.22, 1)" }}
    >
      {online ? (
        <>
          <Wifi className="h-3.5 w-3.5" />
          Connexion rétablie
        </>
      ) : (
        <>
          <CloudOff className="h-3.5 w-3.5" />
          Hors ligne — les contenus déjà consultés restent accessibles
        </>
      )}
    </div>
  );
}
