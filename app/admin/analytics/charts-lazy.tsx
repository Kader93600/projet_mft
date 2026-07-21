"use client";

// =====================================================================
// Wrappers lazy des graphiques Recharts de la page analytics.
//
// Recharts (~100 ko gzip) n'est téléchargé qu'au rendu client des
// graphiques, au lieu d'alourdir le First Load JS de /admin/analytics.
// La page (Server Component) importe depuis CE module ; les composants
// réels restent dans leurs fichiers d'origine.
// =====================================================================

import dynamic from "next/dynamic";

function ChartSkeleton({ h = "h-64" }: { h?: string }) {
  return (
    <div
      className={`${h} rounded-xl bg-navy-50/60 animate-pulse motion-reduce:animate-none`}
      aria-hidden="true"
    />
  );
}

export const TrendsChart = dynamic(
  () => import("./trends-chart").then((m) => m.TrendsChart),
  { ssr: false, loading: () => <ChartSkeleton /> },
);

export const CompletionBars = dynamic(
  () => import("./completion-bars").then((m) => m.CompletionBars),
  { ssr: false, loading: () => <ChartSkeleton /> },
);

export const FormationTrendsGrid = dynamic(
  () => import("./formation-trends").then((m) => m.FormationTrendsGrid),
  { ssr: false, loading: () => <ChartSkeleton h="h-40" /> },
);
