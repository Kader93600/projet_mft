"use client";
import { useEffect } from "react";
import Link from "next/link";
import { AlertTriangle, RotateCw, Home } from "lucide-react";
import { captureException } from "@/lib/observability";

export default function ErrorBoundary({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    captureException(error, {
      level: "error",
      tags: { source: "error.tsx" },
      extra: { digest: error.digest },
    });
  }, [error]);

  return (
    <div className="min-h-[60vh] flex items-center justify-center px-6">
      <div className="max-w-md w-full text-center">
        <div className="mx-auto h-14 w-14 rounded-2xl bg-rose-50 text-rose-700 flex items-center justify-center">
          <AlertTriangle className="h-7 w-7" />
        </div>
        <h1 className="mt-6 font-display text-2xl md:text-3xl font-semibold text-navy-950 tracking-tight">
          Une erreur est survenue
        </h1>
        <p className="mt-2 text-slate-600">
          Nous sommes désolés. Un signalement automatique vient d'être envoyé à
          notre équipe technique.
        </p>
        {error?.digest && (
          <p className="mt-2 text-[11px] font-mono text-slate-400">
            Référence : {error.digest}
          </p>
        )}
        <div className="mt-6 flex justify-center gap-3">
          <button
            onClick={() => reset()}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-navy-900 text-white text-sm font-medium hover:bg-navy-800"
          >
            <RotateCw className="h-4 w-4" /> Réessayer
          </button>
          <Link
            href="/"
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl border border-navy-200 text-sm font-medium text-navy-900 hover:bg-navy-50"
          >
            <Home className="h-4 w-4" /> Accueil
          </Link>
        </div>
      </div>
    </div>
  );
}
