"use client";
import * as React from "react";

// Wrapper anti-copie léger pour les contenus pédagogiques.
// - Bloque copy / cut / contextmenu / drag
// - select-none par CSS
// - N'empêche pas la lecture par screen reader (aria-hidden non utilisé)
// Note : protection raisonnable, pas une DRM. Le user-agent peut toujours
// inspecter le HTML — c'est un signal "ces contenus sont protégés".
export function ProtectedContent({ children }: { children: React.ReactNode }) {
  const ref = React.useRef<HTMLDivElement>(null);

  React.useEffect(() => {
    const el = ref.current;
    if (!el) return;
    function block(e: Event) {
      e.preventDefault();
    }
    el.addEventListener("copy", block);
    el.addEventListener("cut", block);
    el.addEventListener("contextmenu", block);
    el.addEventListener("dragstart", block);
    return () => {
      el.removeEventListener("copy", block);
      el.removeEventListener("cut", block);
      el.removeEventListener("contextmenu", block);
      el.removeEventListener("dragstart", block);
    };
  }, []);

  return (
    <div
      ref={ref}
      className="select-none [&_*]:select-none"
      // Désactive la sélection sur Safari/iOS
      style={{ WebkitUserSelect: "none", userSelect: "none" }}
    >
      {children}
    </div>
  );
}
