"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

/**
 * Auto-refresh la page TV toutes les 30 secondes via router.refresh().
 * Touche Échap → quitte le mode TV et retourne au dashboard normal.
 */
export function TvAutoRefresh() {
  const router = useRouter();

  useEffect(() => {
    const interval = setInterval(() => {
      router.refresh();
    }, 30_000);

    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") {
        router.push("/admin/analytics");
      }
    }
    window.addEventListener("keydown", onKey);

    return () => {
      clearInterval(interval);
      window.removeEventListener("keydown", onKey);
    };
  }, [router]);

  return null;
}
