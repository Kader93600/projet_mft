"use client";
import { useEffect, useRef } from "react";
import { usePathname } from "next/navigation";

/**
 * Composant invisible qui envoie un ping au serveur toutes les 30 secondes
 * tant que l'utilisateur est actif. Arrête de pinger après 5 min d'inactivité
 * (ou quand l'onglet est caché).
 *
 * Détecte automatiquement si on est sur une page leçon (/modules/slug/lecons/id)
 * pour mesurer aussi le temps passé par leçon.
 */
export function SessionTracker({ lessonId }: { lessonId?: string }) {
  const pathname = usePathname();
  const lastActivity = useRef(Date.now());
  const intervalRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    // Marque l'activité sur interactions utilisateur
    const bump = () => {
      lastActivity.current = Date.now();
    };
    ["click", "keydown", "mousemove", "scroll", "touchstart"].forEach((e) =>
      window.addEventListener(e, bump, { passive: true })
    );

    function ping() {
      // Skip si inactif depuis > 5 min ou onglet caché
      if (document.hidden) return;
      if (Date.now() - lastActivity.current > 5 * 60_000) return;

      fetch("/api/session/ping", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          path: pathname,
          lesson_id: lessonId,
        }),
        keepalive: true,
      }).catch(() => {
        // Silencieux : le tracking ne doit jamais casser l'UX
      });
    }

    // Premier ping immédiat puis toutes les 30s
    ping();
    intervalRef.current = setInterval(ping, 30_000);

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
      ["click", "keydown", "mousemove", "scroll", "touchstart"].forEach((e) =>
        window.removeEventListener(e, bump)
      );
    };
  }, [pathname, lessonId]);

  return null;
}
