"use client";

import { useState, useTransition } from "react";
import { Check, Loader2, Palette } from "lucide-react";
import { updateOrgBranding } from "./actions";

export function BrandingForm({
  orgId,
  initialLogoUrl,
  initialPrimaryColor,
}: {
  orgId: string;
  initialLogoUrl: string | null;
  initialPrimaryColor: string | null;
}) {
  const [logo, setLogo] = useState(initialLogoUrl ?? "");
  const [color, setColor] = useState(initialPrimaryColor ?? "");
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);

  // Valeur affichée dans le sélecteur natif (qui exige une couleur valide).
  const pickerValue = /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.test(color)
    ? color
    : "#0E1240";

  function save() {
    setError(null);
    setSaved(false);
    const fd = new FormData();
    fd.set("logo_url", logo.trim());
    fd.set("primary_color", color.trim());
    start(async () => {
      const r = await updateOrgBranding(orgId, fd);
      if (r.ok) {
        setSaved(true);
        setTimeout(() => setSaved(false), 2500);
      } else {
        setError(r.error);
      }
    });
  }

  return (
    <div className="space-y-4">
      {/* Logo */}
      <div>
        <label
          htmlFor="org-logo-url"
          className="block text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-1"
        >
          URL du logo (https)
        </label>
        <div className="flex items-center gap-3">
          {logo ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={logo}
              alt="Aperçu logo"
              className="h-10 w-10 rounded-lg object-contain border border-navy-100 bg-white shrink-0"
            />
          ) : (
            <div className="h-10 w-10 rounded-lg border border-dashed border-navy-200 bg-ivory flex items-center justify-center text-slate-400 shrink-0">
              <Palette className="h-4 w-4" />
            </div>
          )}
          <input
            id="org-logo-url"
            type="url"
            value={logo}
            onChange={(e) => setLogo(e.target.value)}
            placeholder="https://exemple.fr/logo.png"
            className="flex-1 h-10 rounded-xl border border-navy-200 bg-white px-3.5 text-sm text-navy-900"
          />
        </div>
      </div>

      {/* Couleur primaire */}
      <div>
        <label
          htmlFor="org-color-hex"
          className="block text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-1"
        >
          Couleur primaire (hex)
        </label>
        <div className="flex items-center gap-3">
          <input
            type="color"
            aria-label="Sélecteur de couleur"
            value={pickerValue}
            onChange={(e) => setColor(e.target.value)}
            className="h-10 w-12 rounded-lg border border-navy-200 bg-white p-1 cursor-pointer shrink-0"
          />
          <input
            id="org-color-hex"
            type="text"
            value={color}
            onChange={(e) => setColor(e.target.value)}
            placeholder="#0E1240"
            className="w-40 h-10 rounded-xl border border-navy-200 bg-white px-3.5 text-sm text-navy-900 font-mono"
          />
          {color && (
            <button
              type="button"
              onClick={() => setColor("")}
              className="text-xs text-slate-500 hover:text-navy-900"
            >
              Effacer
            </button>
          )}
        </div>
      </div>

      {error && (
        <div className="text-sm text-rose-700 bg-rose-50 border border-rose-200 rounded-lg px-3 py-2">
          {error}
        </div>
      )}

      <div className="flex items-center gap-3">
        <button
          type="button"
          onClick={save}
          disabled={pending}
          className="inline-flex items-center gap-2 rounded-xl bg-navy-900 text-white px-4 py-2.5 text-sm font-medium hover:bg-navy-800 disabled:opacity-60 transition-colors"
        >
          {pending ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : saved ? (
            <Check className="h-4 w-4" />
          ) : null}
          {saved ? "Enregistré" : "Enregistrer le branding"}
        </button>
        <span className="text-xs text-slate-500">
          Utilisé pour personnaliser l'espace des stagiaires de cette organisation.
        </span>
      </div>
    </div>
  );
}
