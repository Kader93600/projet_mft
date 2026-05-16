"use client";

import { Printer } from "lucide-react";

/**
 * Bouton "Imprimer / Export PDF".
 * Utilise window.print() avec une feuille de style print dédiée.
 * Pas de dépendance externe (PDF généré par le navigateur).
 */
export function PrintButton() {
  return (
    <button
      type="button"
      onClick={() => window.print()}
      className="inline-flex items-center gap-1.5 px-3 h-9 rounded-lg text-xs font-semibold bg-white border border-navy-200 text-navy-900 hover:bg-navy-50 transition print:hidden"
      title="Imprimer ou exporter en PDF"
    >
      <Printer className="h-3.5 w-3.5" />
      Export PDF
    </button>
  );
}
