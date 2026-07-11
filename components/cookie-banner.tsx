"use client";
import * as React from "react";
import Link from "next/link";
import { useTranslations } from "next-intl";
import { Cookie } from "lucide-react";

const STORAGE_KEY = "gotrm.cookie.consent.v1";

/** Événement émis à chaque enregistrement de choix (detail = Choice). */
export const CONSENT_CHANGED_EVENT = "mft:consent-changed";
/** Événement permettant de ré-ouvrir la bannière (lien « Gérer les cookies »). */
export const OPEN_BANNER_EVENT = "mft:open-cookie-banner";

type Choice = {
  essential: true;
  analytics: boolean;
  marketing: boolean;
  communications: boolean;
  newsletter: boolean;
  ts: string;
};

export function CookieBanner() {
  const t = useTranslations("cookies");
  const [open, setOpen] = React.useState(false);
  const [details, setDetails] = React.useState(false);
  const [analytics, setAnalytics] = React.useState(false);
  const [marketing, setMarketing] = React.useState(false);
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
      if (!raw) {
        setOpen(true);
        return;
      }
      const saved = JSON.parse(raw) as Partial<Choice>;
      // Validité du consentement : 6 mois (recommandation CNIL ≤ 13 mois,
      // annoncé « 6 mois » dans la politique de confidentialité).
      const SIX_MONTHS_MS = 182 * 24 * 60 * 60 * 1000;
      const age = saved.ts ? Date.now() - new Date(saved.ts).getTime() : Infinity;
      if (!Number.isFinite(age) || age > SIX_MONTHS_MS) {
        setOpen(true);
        return;
      }
      // Pré-remplit les toggles avec le choix existant (ré-ouverture
      // via « Gérer les cookies »).
      setAnalytics(saved.analytics === true);
      setMarketing(saved.marketing === true);
      setCommunications(saved.communications !== false);
      setNewsletter(saved.newsletter === true);
    } catch {
      setOpen(true);
    }
  }, []);

  // Ré-ouverture à la demande (lien « Gérer les cookies » du footer) —
  // exigence CNIL : le retrait du consentement doit être aussi simple
  // que son octroi.
  React.useEffect(() => {
    const onOpen = () => setOpen(true);
    window.addEventListener(OPEN_BANNER_EVENT, onOpen);
    return () => window.removeEventListener(OPEN_BANNER_EVENT, onOpen);
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
        persist({
          analytics: false,
          marketing: false,
          communications: false,
          newsletter: false,
        });
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
    // Notifie les consommateurs (PostHog, AcquisitionTracker…) pour
    // qu'ils s'activent / se désactivent immédiatement, sans rechargement.
    try {
      window.dispatchEvent(
        new CustomEvent(CONSENT_CHANGED_EVENT, { detail: choice })
      );
    } catch {}
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
      {/* max-h + scroll interne : en mobile (surtout 320px) la bannière
          couvrait ~75 % de l'écran ; on compacte icône/titre/texte < md. */}
      <div className="mx-auto max-w-3xl max-h-[85dvh] overflow-y-auto rounded-2xl border border-navy-100 bg-white shadow-float p-4 md:p-6 dark:bg-[hsl(var(--surface))] dark:border-[hsl(var(--border))]">
        <div className="flex items-start gap-3">
          <div
            aria-hidden="true"
            className="h-10 w-10 rounded-xl bg-gold-100 text-gold-800 hidden sm:flex items-center justify-center shrink-0"
          >
            <Cookie className="h-5 w-5" />
          </div>
          <div className="flex-1">
            <h2
              ref={titleRef}
              id={headingId}
              tabIndex={-1}
              className="font-display text-base md:text-lg font-semibold text-navy-950 dark:text-[hsl(var(--text))] outline-none"
            >
              {t("preferencesTitle")}
            </h2>
            <p id={descId} className="text-[13px] leading-snug md:text-sm md:leading-normal text-slate-600 dark:text-[hsl(var(--text-muted))] mt-1">
              {t("preferencesDescription")}{" "}
              <Link
                href="/confidentialite"
                className="text-navy-900 dark:text-signal-400 underline"
              >
                {t("learnMoreLink")}
              </Link>
              .
            </p>

            {details && (
              <fieldset className="mt-4 space-y-2 text-sm border-0 p-0">
                <legend className="sr-only">{t("categoriesLegend")}</legend>
                <ConsentRow
                  id="c-essential"
                  label={t("essential")}
                  desc={t("essentialDesc")}
                  alwaysActiveLabel={t("alwaysActive")}
                  checked
                  disabled
                />
                <ConsentRow
                  id="c-analytics"
                  label={t("analytics")}
                  desc={t("analyticsDesc")}
                  checked={analytics}
                  onChange={setAnalytics}
                />
                <ConsentRow
                  id="c-marketing"
                  label={t("marketing")}
                  desc={t("marketingDesc")}
                  checked={marketing}
                  onChange={setMarketing}
                />
                <ConsentRow
                  id="c-comms"
                  label={t("communications")}
                  desc={t("communicationsDesc")}
                  checked={communications}
                  onChange={setCommunications}
                />
                <ConsentRow
                  id="c-news"
                  label={t("newsletter")}
                  desc={t("newsletterDesc")}
                  checked={newsletter}
                  onChange={setNewsletter}
                />
              </fieldset>
            )}

            {/* Mobile : grille 2×2 compacte (refus au même niveau visuel que
                l'acceptation, exigence CNIL). Desktop : rangée alignée à droite. */}
            <div className="mt-4 md:mt-5 grid grid-cols-2 gap-2 md:flex md:flex-wrap md:items-center md:justify-end">
              <button
                type="button"
                onClick={() => setDetails((v) => !v)}
                aria-expanded={details}
                aria-controls="cookie-details"
                className="text-sm text-slate-600 dark:text-[hsl(var(--text-muted))] hover:text-navy-900 dark:hover:text-[hsl(var(--text))] underline px-2 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-navy-900 rounded"
              >
                {details ? t("hideDetails") : t("customize")}
              </button>
              <button
                type="button"
                onClick={() =>
                  persist({
                    analytics: false,
                    marketing: false,
                    communications: false,
                    newsletter: false,
                  })
                }
                className="px-4 py-2 rounded-xl border border-navy-200 dark:border-[hsl(var(--border))] text-sm font-medium text-navy-900 dark:text-[hsl(var(--text))] hover:bg-navy-50 dark:hover:bg-[hsl(var(--surface-2))] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-navy-900"
              >
                {t("rejectAll")}
              </button>
              <button
                type="button"
                onClick={() =>
                  persist({ analytics, marketing, communications, newsletter })
                }
                className="px-4 py-2 rounded-xl border border-navy-200 dark:border-[hsl(var(--border))] text-sm font-medium text-navy-900 dark:text-[hsl(var(--text))] hover:bg-navy-50 dark:hover:bg-[hsl(var(--surface-2))] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-navy-900"
              >
                {t("savePreferences")}
              </button>
              <button
                type="button"
                onClick={() =>
                  persist({
                    analytics: true,
                    marketing: true,
                    communications: true,
                    newsletter: true,
                  })
                }
                className="px-4 py-2 rounded-xl bg-navy-900 text-white text-sm font-medium hover:bg-navy-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-gold-500"
              >
                {t("acceptAll")}
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
  alwaysActiveLabel,
}: {
  id: string;
  label: string;
  desc: string;
  checked: boolean;
  onChange?: (v: boolean) => void;
  disabled?: boolean;
  alwaysActiveLabel?: string;
}) {
  return (
    <label
      htmlFor={id}
      className="flex items-start gap-3 rounded-xl border border-navy-100 dark:border-[hsl(var(--border))] bg-ivory dark:bg-[hsl(var(--surface-2))] px-4 py-3 cursor-pointer hover:border-navy-200"
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
        <span className="block font-medium text-navy-900 dark:text-[hsl(var(--text))]">{label}</span>
        <span className="block text-xs text-slate-500 dark:text-[hsl(var(--text-muted))]">{desc}</span>
        {disabled && alwaysActiveLabel && (
          <span className="block text-[10px] uppercase tracking-wider text-slate-400 mt-1">
            {alwaysActiveLabel}
          </span>
        )}
      </span>
    </label>
  );
}
