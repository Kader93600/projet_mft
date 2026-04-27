"use client";
// Cette page s'affiche UNIQUEMENT si app/layout.tsx lui-même crashe.
// Pas de styles Tailwind ici, pas de fonts custom : on reste autonome.
import { useEffect } from "react";
import { captureException } from "@/lib/observability";

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    captureException(error, {
      level: "fatal",
      tags: { source: "global-error.tsx" },
      extra: { digest: error.digest },
    });
  }, [error]);

  return (
    <html lang="fr">
      <body
        style={{
          margin: 0,
          fontFamily:
            "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
          background: "#FAF8F4",
          color: "#0E1240",
          minHeight: "100vh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          padding: "40px 24px",
        }}
      >
        <main style={{ maxWidth: 480, textAlign: "center" }}>
          <div
            style={{
              display: "inline-flex",
              alignItems: "center",
              justifyContent: "center",
              width: 56,
              height: 56,
              borderRadius: 14,
              background: "#FEE2E2",
              color: "#B91C1C",
              fontSize: 24,
            }}
            aria-hidden
          >
            ⚠
          </div>
          <h1
            style={{
              fontSize: 24,
              fontWeight: 600,
              margin: "20px 0 8px",
              letterSpacing: "-0.02em",
            }}
          >
            Service momentanément indisponible
          </h1>
          <p style={{ fontSize: 15, color: "#475569", margin: "0 0 20px" }}>
            Une erreur critique s'est produite. Notre équipe a été notifiée
            automatiquement.
          </p>
          {error?.digest && (
            <p
              style={{
                fontSize: 11,
                color: "#94A3B8",
                fontFamily: "ui-monospace, SFMono-Regular, monospace",
                marginBottom: 24,
              }}
            >
              Référence : {error.digest}
            </p>
          )}
          <button
            onClick={() => reset()}
            style={{
              cursor: "pointer",
              padding: "10px 18px",
              borderRadius: 12,
              border: "none",
              background: "#0E1240",
              color: "#fff",
              fontWeight: 500,
              fontSize: 14,
            }}
          >
            Réessayer
          </button>
        </main>
      </body>
    </html>
  );
}
