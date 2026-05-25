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

/**
 * Autocomplétion d'adresse française via la Base Adresse Nationale
 * (api-adresse.data.gouv.fr — officielle, gratuite, sans clé, RGPD-friendly).
 *
 * Rend les 3 champs (adresse / code postal / ville) avec des `name` standards
 * → compatible avec un formulaire non contrôlé (FormData). Sélectionner une
 * suggestion remplit automatiquement code postal + ville.
 */
export function AddressAutocomplete({
  theme = "dark",
  defaultAddress = "",
  defaultPostcode = "",
  defaultCity = "",
  idPrefix = "addr",
}: {
  theme?: "dark" | "light";
  defaultAddress?: string;
  defaultPostcode?: string;
  defaultCity?: string;
  idPrefix?: string;
}) {
  const [address, setAddress] = useState(defaultAddress);
  const [postcode, setPostcode] = useState(defaultPostcode);
  const [city, setCity] = useState(defaultCity);
  const [suggestions, setSuggestions] = useState<Suggestion[]>([]);
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [active, setActive] = useState(-1);
  const boxRef = useRef<HTMLDivElement>(null);
  const skip = useRef(false);

  // Recherche debouncée sur la BAN.
  useEffect(() => {
    if (skip.current) {
      skip.current = false;
      return;
    }
    const q = address.trim();
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
        setOpen(sugg.length > 0);
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
  }, [address]);

  useEffect(() => {
    const onDown = (e: MouseEvent) => {
      if (boxRef.current && !boxRef.current.contains(e.target as Node))
        setOpen(false);
    };
    document.addEventListener("mousedown", onDown);
    return () => document.removeEventListener("mousedown", onDown);
  }, []);

  function pick(s: Suggestion) {
    skip.current = true;
    setAddress(s.name);
    setPostcode(s.postcode);
    setCity(s.city);
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
    : "block text-sm font-medium text-navy-900 mb-2";
  const inputCls = dark
    ? "w-full bg-night-50 border border-white/10 rounded-xl px-4 py-3 text-white placeholder:text-white/60 focus:border-signal-500 focus:outline-none focus:ring-2 focus:ring-signal-500/30"
    : "w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900 placeholder:text-slate-400 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15";
  const menuCls = dark
    ? "border-white/10 bg-night-100 text-white"
    : "border-navy-100 bg-white text-navy-900 shadow-raised";

  return (
    <>
      <div className="relative" ref={boxRef}>
        <label className={labelCls} htmlFor={`${idPrefix}-adresse`}>
          Adresse postale (facultatif)
        </label>
        <div className="relative">
          <input
            id={`${idPrefix}-adresse`}
            name="adresse"
            autoComplete="off"
            value={address}
            onChange={(e) => setAddress(e.target.value)}
            onKeyDown={onKeyDown}
            onFocus={() => suggestions.length > 0 && setOpen(true)}
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
                      : "bg-navy-50 text-navy-900"
                    : dark
                      ? "text-white/85 hover:bg-white/5"
                      : "text-navy-800 hover:bg-navy-50"
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
            Code postal (facultatif)
          </label>
          <input
            id={`${idPrefix}-code_postal`}
            name="code_postal"
            value={postcode}
            onChange={(e) => setPostcode(e.target.value)}
            placeholder="77100"
            inputMode="numeric"
            autoComplete="postal-code"
            className={inputCls}
          />
        </div>
        <div>
          <label className={labelCls} htmlFor={`${idPrefix}-ville`}>
            Ville (facultatif)
          </label>
          <input
            id={`${idPrefix}-ville`}
            name="ville"
            value={city}
            onChange={(e) => setCity(e.target.value)}
            placeholder="Meaux"
            autoComplete="address-level2"
            className={inputCls}
          />
        </div>
      </div>
    </>
  );
}
