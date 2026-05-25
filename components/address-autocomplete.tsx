"use client";

import { useEffect, useRef, useState } from "react";
import { MapPin, Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";

interface Suggestion {
  id: string;
  label: string;
  name: string;
  postcode: string;
  city: string;
}

export interface AddressValue {
  address: string;
  postcode: string;
  city: string;
}

/**
 * Autocomplétion d'adresse française via la Base Adresse Nationale
 * (api-adresse.data.gouv.fr — officielle, gratuite, sans clé, RGPD-friendly).
 *
 * Deux modes :
 *  • Non contrôlé (par défaut) → rend 3 champs `name` standards
 *    (adresse / code_postal / ville) compatibles FormData. Utilisé par le
 *    formulaire de contact public.
 *  • Contrôlé → fournir `value` + `onChange` (le parent possède l'état).
 *    Utilisé par le back-office (formulaire React contrôlé, import de lead).
 *
 * Sélectionner une suggestion remplit automatiquement code postal + ville.
 */
export function AddressAutocomplete({
  theme = "dark",
  idPrefix = "addr",
  defaultAddress = "",
  defaultPostcode = "",
  defaultCity = "",
  value,
  onChange,
  labels,
}: {
  theme?: "dark" | "light";
  idPrefix?: string;
  defaultAddress?: string;
  defaultPostcode?: string;
  defaultCity?: string;
  /** Mode contrôlé : fournir `value` ET `onChange` (le parent gère l'état). */
  value?: AddressValue;
  onChange?: (next: AddressValue) => void;
  /** Libellés personnalisés (par défaut : variantes « (facultatif) »). */
  labels?: { address?: string; postcode?: string; city?: string };
}) {
  const controlled = value !== undefined && typeof onChange === "function";
  const [internal, setInternal] = useState<AddressValue>({
    address: defaultAddress,
    postcode: defaultPostcode,
    city: defaultCity,
  });
  const current = controlled ? (value as AddressValue) : internal;

  function update(patch: Partial<AddressValue>) {
    const next = { ...current, ...patch };
    if (controlled) onChange!(next);
    else setInternal(next);
  }

  const [suggestions, setSuggestions] = useState<Suggestion[]>([]);
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [active, setActive] = useState(-1);
  const boxRef = useRef<HTMLDivElement>(null);
  const skip = useRef(false);
  const focused = useRef(false);

  // Recherche debouncée sur la BAN. On ne déclenche que si le champ adresse
  // a le focus → une mise à jour programmatique (import d'un lead) ne fait
  // pas surgir le menu de suggestions.
  useEffect(() => {
    if (skip.current) {
      skip.current = false;
      return;
    }
    if (!focused.current) return;
    const q = current.address.trim();
    if (q.length < 3) {
      setSuggestions([]);
      setOpen(false);
      return;
    }
    const ctrl = new AbortController();
    const id = setTimeout(async () => {
      setLoading(true);
      try {
        const res = await fetch(
          `https://api-adresse.data.gouv.fr/search/?q=${encodeURIComponent(
            q
          )}&limit=5&autocomplete=1`,
          { signal: ctrl.signal }
        );
        const json = await res.json();
        const sugg: Suggestion[] = (json.features ?? []).map((f: any) => ({
          id: f.properties.id,
          label: f.properties.label,
          name: f.properties.name ?? f.properties.label,
          postcode: f.properties.postcode ?? "",
          city: f.properties.city ?? "",
        }));
        setSuggestions(sugg);
        setOpen(focused.current && sugg.length > 0);
        setActive(-1);
      } catch {
        /* abort / réseau : on ignore silencieusement */
      } finally {
        setLoading(false);
      }
    }, 280);
    return () => {
      clearTimeout(id);
      ctrl.abort();
    };
  }, [current.address]);

  useEffect(() => {
    const onDown = (e: MouseEvent) => {
      if (boxRef.current && !boxRef.current.contains(e.target as Node)) {
        setOpen(false);
        focused.current = false;
      }
    };
    document.addEventListener("mousedown", onDown);
    return () => document.removeEventListener("mousedown", onDown);
  }, []);

  function pick(s: Suggestion) {
    skip.current = true;
    update({ address: s.name, postcode: s.postcode, city: s.city });
    setSuggestions([]);
    setOpen(false);
    setActive(-1);
  }

  function onKeyDown(e: React.KeyboardEvent) {
    if (!open || suggestions.length === 0) return;
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setActive((a) => Math.min(a + 1, suggestions.length - 1));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setActive((a) => Math.max(a - 1, 0));
    } else if (e.key === "Enter" && active >= 0) {
      e.preventDefault();
      pick(suggestions[active]);
    } else if (e.key === "Escape") {
      setOpen(false);
    }
  }

  const dark = theme === "dark";
  const labelCls = dark
    ? "block text-[11px] font-semibold uppercase tracking-[0.16em] text-white/55 mb-2"
    : "block text-sm font-medium text-navy-900 dark:text-[hsl(var(--text))] mb-2";
  const inputCls = dark
    ? "w-full bg-night-50 border border-white/10 rounded-xl px-4 py-3 text-white placeholder:text-white/60 focus:border-signal-500 focus:outline-none focus:ring-2 focus:ring-signal-500/30"
    : "w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900 dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))] dark:border-[hsl(var(--border))] placeholder:text-slate-500 dark:placeholder:text-[hsl(var(--text-muted))] transition-all duration-150 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15 dark:focus:border-signal-500 dark:focus:ring-signal-500/20";
  const menuCls = dark
    ? "border-white/10 bg-night-100 text-white"
    : "border-navy-100 bg-white text-navy-900 shadow-raised dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))] dark:border-[hsl(var(--border))]";

  const lblAddress = labels?.address ?? "Adresse postale (facultatif)";
  const lblPostcode = labels?.postcode ?? "Code postal (facultatif)";
  const lblCity = labels?.city ?? "Ville (facultatif)";

  return (
    <>
      <div className="relative" ref={boxRef}>
        <label className={labelCls} htmlFor={`${idPrefix}-adresse`}>
          {lblAddress}
        </label>
        <div className="relative">
          <input
            id={`${idPrefix}-adresse`}
            name="adresse"
            autoComplete="off"
            value={current.address}
            onChange={(e) => update({ address: e.target.value })}
            onKeyDown={onKeyDown}
            onFocus={() => {
              focused.current = true;
              if (suggestions.length > 0) setOpen(true);
            }}
            onBlur={() => {
              focused.current = false;
            }}
            placeholder="Commencez à taper votre adresse…"
            className={inputCls}
            role="combobox"
            aria-expanded={open}
            aria-autocomplete="list"
            aria-controls={`${idPrefix}-suggestions`}
          />
          {loading && (
            <Loader2
              className={cn(
                "absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 animate-spin",
                dark ? "text-white/50" : "text-slate-400"
              )}
            />
          )}
        </div>

        {open && suggestions.length > 0 && (
          <ul
            id={`${idPrefix}-suggestions`}
            role="listbox"
            className={cn(
              "absolute z-30 mt-1.5 max-h-72 w-full overflow-auto rounded-xl border p-1 shadow-2xl",
              "motion-safe:animate-fade-up",
              menuCls
            )}
          >
            {suggestions.map((s, i) => (
              <li
                key={s.id}
                role="option"
                aria-selected={i === active}
                onMouseEnter={() => setActive(i)}
                onMouseDown={(e) => {
                  e.preventDefault();
                  pick(s);
                }}
                className={cn(
                  "flex cursor-pointer items-start gap-2 rounded-lg px-3 py-2 text-sm transition-colors",
                  i === active
                    ? dark
                      ? "bg-signal-500/15 text-white"
                      : "bg-navy-50 text-navy-900 dark:bg-white/5 dark:text-[hsl(var(--text))]"
                    : dark
                      ? "text-white/85 hover:bg-white/5"
                      : "text-navy-800 hover:bg-navy-50 dark:text-[hsl(var(--text))] dark:hover:bg-white/5"
                )}
              >
                <MapPin
                  className={cn(
                    "mt-0.5 h-4 w-4 shrink-0",
                    dark ? "text-signal-400" : "text-brand-600"
                  )}
                />
                <span className="leading-snug">{s.label}</span>
              </li>
            ))}
          </ul>
        )}
      </div>

      <div className="grid sm:grid-cols-2 gap-4">
        <div>
          <label className={labelCls} htmlFor={`${idPrefix}-code_postal`}>
            {lblPostcode}
          </label>
          <input
            id={`${idPrefix}-code_postal`}
            name="code_postal"
            value={current.postcode}
            onChange={(e) => update({ postcode: e.target.value })}
            placeholder="77100"
            inputMode="numeric"
            maxLength={10}
            autoComplete="postal-code"
            className={inputCls}
          />
        </div>
        <div>
          <label className={labelCls} htmlFor={`${idPrefix}-ville`}>
            {lblCity}
          </label>
          <input
            id={`${idPrefix}-ville`}
            name="ville"
            value={current.city}
            onChange={(e) => update({ city: e.target.value })}
            placeholder="Meaux"
            autoComplete="address-level2"
            className={inputCls}
          />
        </div>
      </div>
    </>
  );
}
