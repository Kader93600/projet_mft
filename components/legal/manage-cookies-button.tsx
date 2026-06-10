"use client";
import { OPEN_BANNER_EVENT } from "@/components/cookie-banner";

/**
 * Ré-ouvre la bannière cookies (exigence CNIL : retirer son consentement
 * doit être aussi simple que le donner). Rendu comme un lien du footer.
 */
export function ManageCookiesButton({ dark }: { dark: boolean }) {
  return (
    <button
      type="button"
      onClick={() => window.dispatchEvent(new Event(OPEN_BANNER_EVENT))}
      className={
        "hover:underline text-left " +
        (dark ? "hover:text-white" : "hover:text-navy-900")
      }
    >
      Gérer les cookies
    </button>
  );
}
