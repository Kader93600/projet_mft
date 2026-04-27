import Link from "next/link";
import { LEGAL } from "@/lib/legal-config";
import { ShieldCheck } from "lucide-react";

const LINKS = [
  { href: "/mentions-legales", label: "Mentions légales" },
  { href: "/cgu", label: "CGU" },
  { href: "/cgv", label: "CGV" },
  { href: "/confidentialite", label: "Confidentialité" },
  { href: "/retractation", label: "Rétractation" },
  { href: "/reglement-interieur", label: "Règlement intérieur" },
  { href: "/accessibilite", label: "Accessibilité" },
];

export function LegalFooter({ variant = "light" }: { variant?: "light" | "dark" }) {
  const dark = variant === "dark";
  return (
    <footer
      className={
        "border-t " +
        (dark
          ? "bg-navy-950 text-white/70 border-white/10"
          : "bg-white text-slate-600 border-navy-100")
      }
    >
      <div className="max-w-7xl mx-auto px-6 py-8 grid gap-6 md:grid-cols-3">
        <div>
          <div
            className={
              "font-display text-base font-semibold " +
              (dark ? "text-white" : "text-navy-950")
            }
          >
            {LEGAL.brand}
          </div>
          <p className="mt-2 text-xs leading-relaxed">
            Organisme de formation déclaré n°{" "}
            <span className="font-mono">{LEGAL.trainingActivityNumber}</span>,
            certifié Qualiopi ({LEGAL.qualiopiNumber}) — Spécialiste des
            métiers réglementés du transport.
          </p>
          <p className="mt-2 text-[11px] inline-flex items-center gap-1.5">
            <ShieldCheck className="h-3 w-3 text-signal-500" /> Données hébergées
            en Union européenne
          </p>
        </div>

        <nav aria-label="Liens légaux" className="md:col-span-2">
          <ul className="grid grid-cols-2 sm:grid-cols-3 gap-x-4 gap-y-2 text-sm">
            {LINKS.map((l) => (
              <li key={l.href}>
                <Link
                  href={l.href}
                  className={
                    "hover:underline " +
                    (dark ? "hover:text-white" : "hover:text-navy-900")
                  }
                >
                  {l.label}
                </Link>
              </li>
            ))}
            <li>
              <a
                href={`mailto:${LEGAL.email}`}
                className={
                  "hover:underline " +
                  (dark ? "hover:text-white" : "hover:text-navy-900")
                }
              >
                Nous contacter
              </a>
            </li>
          </ul>
        </nav>
      </div>

      <div
        className={
          "border-t text-[11px] " +
          (dark ? "border-white/10" : "border-navy-50")
        }
      >
        <div className="max-w-7xl mx-auto px-6 py-4 flex flex-wrap items-center justify-between gap-2">
          <span>
            © {new Date().getFullYear()} {LEGAL.legalName} — Tous droits réservés.
          </span>
          <span>
            SIRET {LEGAL.siret} · {LEGAL.address.city}, {LEGAL.address.country}
          </span>
        </div>
      </div>
    </footer>
  );
}
