"use client";
import * as React from "react";
import Link from "next/link";
import { Cookie } from "lucide-react";

const STORAGE_KEY = "gotrm.cookie.consent.v1";

type Choice = {
  essential: true;
  analytics: boolean;
  communications: boolean;
  newsletter: boolean;
  ts: string;
};

export function CookieBanner() {
  const [open, setOpen] = React.useState(false);
  const [details, setDetails] = React.useState(false);
  const [analytics, setAnalytics] = React.useState(false);
  const [communications, setCommunications] = React.useState(true);
  const [newsletter, setNewsletter] = React.useState(false);

  const containerRef = React.useRef<HTMLDivElement>(null);
  const headingId = React.useId();
  const descId = React.useId();
  const titleRef = React.useRef<HTMLHeadingElement>(null);
  const lastFocusedRef = React.useRef<HTMLElement | null>(null);

  React.useEffect(() => {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) setOpen(true);
    } catch {
      setOpen(true);
    }
  }, []);

  // Focus trap + restore previous focus + ESC to refuse-all
  React.useEffect(() => {
    if (!open) return;
    lastFocusedRef.current = (document.activeElement as HTMLElement) ?? null;
    // Move focus to dialog title
    requestAnimationFrame(() => titleRef.current?.focus());

    function getFocusable() {
      const root = containerRef.current;
      if (!root) return [] as HTMLElement[];
      return Array.from(
        root.querySelectorAll<HTMLElement>(
          'a[href], button:not([disabled]), input:not([disabled]), [tabindex]:not([tabindex="-1"])'
        )
      ).filter((el) => !el.hasAttribute("aria-hidden"));
    }

    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") {
        e.preventDefault();
        // ESC = refus minimal (essentiels seuls), conformément aux recommandations CNIL
        persist({ analytics: false, communications: false, newsletter: false });
        return;
      }
      if (e.key !== "Tab") return;
      const focusables = getFocusable();
      if (focusables.length === 0) return;
      const first = focusables[0];
      const last = focusables[focusables.length - 1];
      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    }
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("keydown", onKey);
      // Restore focus on close
      lastFocusedRef.current?.focus?.();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open]);

  function persist(c: Omit<Choice, "essential" | "ts">) {
    const choice: Choice = {
      essential: true,
      ...c,
      ts: new Date().toISOString(),
    };
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(choice));
    } catch {}
    setOpen(false);
    (Object.entries(c) as [string, boolean][]).forEach(([kind, granted]) => {
      fetch("/api/me/consent", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ kind, granted }),
      }).catch(() => {});
    });
  }

  if (!open) return null;

  return (
    <div
      ref={containerRef}
      role="dialog"
      aria-modal="true"
      aria-labelledby={headingId}
      aria-describedby={descId}
      className="fixed inset-x-0 bottom-0 z-40 p-3 md:p-5"
    >
      <div className="mx-auto max-w-3xl rounded-2xl border border-navy-100 bg-white shadow-float p-5 md:p-6">
        <div className="flex items-start gap-3">
          <div
            aria-hidden="true"
            className="h-10 w-10 rounded-xl bg-gold-100 text-gold-800 flex items-center justify-center shrink-0"
          >
            <Cookie className="h-5 w-5" />
          </div>
          <div className="flex-1">
            <h2
              ref={titleRef}
              id={headingId}
              tabIndex={-1}
              className="font-display text-lg font-semibold text-navy-950 outline-none"
            >
              Vos préférences de confidentialité
            </h2>
            <p id={descId} className="text-sm text-slate-600 mt-1">
              Nous utilisons des cookies essentiels au fonctionnement de la
              plateforme. Avec votre accord, nous activons aussi la mesure
              d'audience et certaines communications.{" "}
              <Link
                href="/confidentialite"
                className="text-navy-900 underline"
              >
                En savoir plus
              </Link>
              .
            </p>

            {details && (
              <fieldset className="mt-4 space-y-2 text-sm border-0 p-0">
                <legend className="sr-only">Catégories de cookies</legend>
                <ConsentRow
                  id="c-essential"
                  label="Cookies essentiels"
                  desc="Indispensables au fonctionnement (session, sécurité)."
                  checked
                  disabled
                />
                <ConsentRow
                  id="c-analytics"
                  label="Mesure d'audience"
                  desc="Statistiques anonymisées d'usage."
                  checked={analytics}
                  onChange={setAnalytics}
                />
                <ConsentRow
                  id="c-comms"
                  label="Communications"
                  desc="Rappels et notifications pédagogiques."
                  checked={communications}
                  onChange={setCommunications}
                />
                <ConsentRow
                  id="c-news"
                  label="Lettre d'information"
                  desc="Actualités et mises à jour."
                  checked={newsletter}
                  onChange={setNewsletter}
                />
              </fieldset>
            )}

            <div className="mt-5 flex flex-wrap items-center gap-2 justify-end">
              <button
                type="button"
                onClick={() => setDetails((v) => !v)}
                aria-expanded={details}
                aria-controls="cookie-details"
                className="text-sm text-slate-600 hover:text-navy-900 underline px-2 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-navy-900 rounded"
              >
                {details ? "Masquer le détail" : "Personnaliser"}
              </button>
              <button
                type="button"
                onClick={() =>
                  persist({
                    analytics: false,
                    communications: false,
                    newsletter: false,
                  })
                }
                className="px-4 py-2 rounded-xl border border-navy-200 text-sm font-medium text-navy-900 hover:bg-navy-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-navy-900"
              >
                Refuser tout
              </button>
              <button
                type="button"
                onClick={() =>
                  persist({ analytics, communications, newsletter })
                }
                className="px-4 py-2 rounded-xl border border-navy-200 text-sm font-medium text-navy-900 hover:bg-navy-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-navy-900"
              >
                Enregistrer mes choix
              </button>
              <button
                type="button"
                onClick={() =>
                  persist({
                    analytics: true,
                    communications: true,
                    newsletter: true,
                  })
                }
                className="px-4 py-2 rounded-xl bg-navy-900 text-white text-sm font-medium hover:bg-navy-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-gold-500"
              >
                Tout accepter
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function ConsentRow({
  id,
  label,
  desc,
  checked,
  onChange,
  disabled,
}: {
  id: string;
  label: string;
  desc: string;
  checked: boolean;
  onChange?: (v: boolean) => void;
  disabled?: boolean;
}) {
  return (
    <label
      htmlFor={id}
      className="flex items-start gap-3 rounded-xl border border-navy-100 bg-ivory px-4 py-3 cursor-pointer hover:border-navy-200"
    >
      <input
        id={id}
        type="checkbox"
        checked={checked}
        disabled={disabled}
        onChange={(e) => onChange?.(e.target.checked)}
        className="mt-0.5 h-5 w-5 rounded border-navy-300 text-navy-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-navy-900 disabled:opacity-60"
      />
      <span className="flex-1">
        <span className="block font-medium text-navy-900">{label}</span>
        <span className="block text-xs text-slate-500">{desc}</span>
        {disabled && (
          <span className="block text-[10px] uppercase tracking-wider text-slate-400 mt-1">
            Toujours actif
          </span>
        )}
      </span>
    </label>
  );
}
