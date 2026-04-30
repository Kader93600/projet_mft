import Link from "next/link";
import {
  Settings as SettingsIcon,
  Crown,
  Globe,
  Mail,
  Database,
  ShieldCheck,
  GraduationCap,
  Bell,
  ChevronRight,
  Info,
  ExternalLink,
} from "lucide-react";
import { LEGAL } from "@/lib/legal-config";

export const metadata = {
  title: "Configuration — Super Admin",
};

/**
 * Configuration globale plateforme — vue super-admin uniquement.
 *
 * Cette page agrège les liens vers toutes les configurations sensibles +
 * un résumé des paramètres de l'organisme (legal-config.ts).
 */

type Group = {
  label: string;
  hint: string;
  items: { href: string; icon: any; title: string; desc: string; external?: boolean }[];
};

const GROUPS: Group[] = [
  {
    label: "Configuration administrative",
    hint: "Réglages partagés avec l'espace admin classique.",
    items: [
      {
        href: "/admin/settings/formation",
        icon: GraduationCap,
        title: "Programme de formation",
        desc: "Référentiels, attestations, certificats officiels.",
      },
      {
        href: "/admin/settings/documents",
        icon: SettingsIcon,
        title: "Documents d'entrée",
        desc: "Convention, règlement, livret d'accueil.",
      },
      {
        href: "/admin/announcements",
        icon: Bell,
        title: "Annonces & communication",
        desc: "Diffusion d'annonces ciblées par formation ou globale.",
      },
      {
        href: "/admin/rgpd",
        icon: ShieldCheck,
        title: "RGPD",
        desc: "Demandes d'accès, rectification, effacement.",
      },
    ],
  },
  {
    label: "Régalien (super-admin uniquement)",
    hint: "Actions à fort impact — disponibles uniquement à ce rôle.",
    items: [
      {
        href: "/super-admin/roles",
        icon: Crown,
        title: "Gestion des rôles utilisateurs",
        desc: "Promouvoir / rétrograder admin · trainer · student.",
      },
      {
        href: "/super-admin/permissions",
        icon: ShieldCheck,
        title: "Matrice des permissions",
        desc: "Référence des actions autorisées par rôle.",
      },
      {
        href: "/super-admin/audit",
        icon: Database,
        title: "Journal d'audit complet",
        desc: "Historique horodaté de toutes les actions sensibles.",
      },
    ],
  },
];

export default function SuperAdminSettingsPage() {
  return (
    <div className="space-y-10">
      <header>
        <div className="flex items-center gap-2">
          <SettingsIcon className="h-4 w-4 text-signal-700" />
          <span className="eyebrow text-signal-700">Configuration globale</span>
        </div>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Réglages plateforme
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl leading-relaxed">
          Vue centralisée des configurations sensibles — pédagogie, conformité,
          régalien.
        </p>
      </header>

      {/* Identité de l'organisme — read-only summary */}
      <section className="rounded-2xl bg-white border border-navy-100 p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="font-display text-lg font-semibold text-navy-900 tracking-tight">
            Identité de l'organisme
          </h2>
          <span className="text-[11px] font-semibold uppercase tracking-wider text-amber-700 bg-amber-100 rounded-full px-2.5 py-1 inline-flex items-center gap-1">
            <Info className="h-3 w-3" />
            Modifié dans le code
          </span>
        </div>
        <p className="text-xs text-slate-500 mb-5">
          Ces valeurs proviennent de{" "}
          <code className="px-1.5 py-0.5 rounded bg-navy-50 text-navy-800 text-[12px] font-mono">
            lib/legal-config.ts
          </code>
          . Toute modification passe par un commit + déploiement.
        </p>
        <dl className="grid sm:grid-cols-2 gap-x-8 gap-y-3 text-sm">
          <Row label="Marque" value={LEGAL.brand} />
          <Row label="Raison sociale" value={LEGAL.legalName} />
          <Row label="SIREN" value={LEGAL.siren} />
          <Row label="SIRET" value={LEGAL.siret} />
          <Row label="Code APE" value={`${LEGAL.apeCode} — ${LEGAL.apeLabel}`} />
          <Row
            label="Adresse"
            value={`${LEGAL.address.street}, ${LEGAL.address.postalCode} ${LEGAL.address.city}`}
          />
          <Row
            label="N° d'activité OF"
            value={LEGAL.trainingActivityNumber}
            warn
          />
          <Row label="N° Qualiopi" value={LEGAL.qualiopiNumber} warn />
          <Row label="Email contact" value={LEGAL.email} icon={Mail} />
          <Row label="Site" value={LEGAL.website} icon={Globe} />
          <Row label="DPO" value={LEGAL.dpoEmail} icon={ShieldCheck} />
          <Row
            label="Hébergement"
            value={`${LEGAL.hosting.name} (${LEGAL.hosting.euDataCenter})`}
          />
        </dl>
      </section>

      {GROUPS.map((g) => (
        <section key={g.label} className="space-y-3">
          <div className="border-b border-navy-50 pb-3">
            <h2 className="font-display text-lg font-semibold text-navy-900 tracking-tight">
              {g.label}
            </h2>
            <p className="mt-0.5 text-xs text-slate-500">{g.hint}</p>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
            {g.items.map((item) => {
              const Icon = item.icon;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className="group flex items-start gap-4 rounded-2xl border border-navy-100 p-5 hover:border-brand-300 hover:shadow-soft transition"
                >
                  <div className="h-11 w-11 rounded-xl bg-brand-50 text-brand-700 flex items-center justify-center shrink-0 group-hover:scale-105 transition-transform">
                    <Icon className="h-5 w-5" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold text-navy-900 group-hover:text-brand-700 transition-colors flex items-center gap-1.5">
                      {item.title}
                      {item.external && <ExternalLink className="h-3.5 w-3.5" />}
                    </h3>
                    <p className="mt-1 text-xs text-slate-600 leading-relaxed">
                      {item.desc}
                    </p>
                  </div>
                  <ChevronRight className="h-4 w-4 text-slate-300 group-hover:text-brand-600 self-center shrink-0" />
                </Link>
              );
            })}
          </div>
        </section>
      ))}
    </div>
  );
}

function Row({
  label,
  value,
  icon: Icon,
  warn,
}: {
  label: string;
  value: string;
  icon?: any;
  warn?: boolean;
}) {
  const isPlaceholder = value.includes("[À COMPLÉTER]");
  return (
    <div className="flex items-baseline justify-between gap-4 border-b border-navy-50 pb-2">
      <dt className="text-xs uppercase tracking-wider text-slate-500 font-medium">
        {label}
      </dt>
      <dd
        className={
          "text-sm text-right truncate " +
          (isPlaceholder
            ? "text-amber-700 italic"
            : warn
            ? "text-navy-800 font-medium"
            : "text-navy-900 font-medium")
        }
      >
        {Icon && <Icon className="inline h-3.5 w-3.5 mr-1 text-slate-400" />}
        {value}
      </dd>
    </div>
  );
}
