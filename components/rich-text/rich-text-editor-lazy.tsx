"use client";

// =====================================================================
// Wrapper lazy du RichTextEditor (TipTap).
//
// TipTap + extensions pèsent lourd (~120 ko gzip) : en important
// l'éditeur via next/dynamic, son bundle n'est téléchargé qu'au moment
// où un écran l'affiche réellement (édition de leçon, validation QR,
// composeur d'email…), pas au chargement initial de la page.
//
// Utiliser CE module partout à la place de "./rich-text-editor".
// =====================================================================

import dynamic from "next/dynamic";

export const RichTextEditor = dynamic(
  () => import("./rich-text-editor").then((m) => m.RichTextEditor),
  {
    ssr: false,
    loading: () => (
      <div
        className="min-h-[180px] rounded-xl border border-navy-100 bg-navy-50/40 animate-pulse motion-reduce:animate-none"
        aria-hidden="true"
      />
    ),
  },
);
