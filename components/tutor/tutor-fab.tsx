"use client";

// =====================================================================
// FAB (Floating Action Button) du tuteur IA.
//
// Affiché en bas à droite à partir du moment où l'utilisateur est
// connecté ET a accès (gate Premium côté serveur dans AuthLayout).
//
// Au clic : ouvre le TutorDrawer. Cmd/Ctrl + K aussi.
// =====================================================================

import { useEffect, useState } from "react";
import { Sparkles } from "lucide-react";
import { TutorDrawer } from "./tutor-drawer";

export function TutorFab({
  formationSlug,
}: {
  formationSlug?: string | null;
}) {
  const [open, setOpen] = useState(false);

  // Raccourci clavier : Cmd/Ctrl + Shift + K
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (
        (e.metaKey || e.ctrlKey) &&
        e.shiftKey &&
        e.key.toLowerCase() === "k"
      ) {
        e.preventDefault();
        setOpen((v) => !v);
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        aria-label="Ouvrir le tuteur IA"
        title="Tuteur IA (⌘+Shift+K)"
        className={[
          "fixed bottom-5 right-5 md:bottom-7 md:right-7 z-[95]",
          "h-12 w-12 md:h-14 md:w-14 rounded-full",
          "bg-gradient-to-br from-gold-400 to-gold-600 text-navy-950",
          "shadow-raised hover:shadow-elevated hover:-translate-y-0.5",
          "flex items-center justify-center transition-all duration-300",
          "focus:outline-none focus:ring-4 focus:ring-gold-300/40",
          "group",
        ].join(" ")}
        style={{ transitionTimingFunction: "cubic-bezier(0.19, 1, 0.22, 1)" }}
      >
        <Sparkles className="h-5 w-5 md:h-6 md:w-6 transition-transform group-hover:rotate-12 group-hover:scale-110" />
        <span
          aria-hidden
          className="absolute inset-0 rounded-full ring-2 ring-gold-300/60 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
        />
      </button>

      <TutorDrawer
        open={open}
        onClose={() => setOpen(false)}
        formationSlug={formationSlug}
      />
    </>
  );
}
