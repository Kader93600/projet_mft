import Link from "next/link";
import {
  Settings as SettingsIcon,
  GraduationCap,
  FileSignature,
  ShieldCheck,
  Lock,
  BookMarked,
  Accessibility,
  Bell,
  Palette,
  Database,
  ChevronRight,
} from "lucide-react";

export const metadata = {
  title: "Paramètres — Administration",
};

type Item = {
  href: string;
  icon: any;
  title: string;
  desc: string;
  badge?: string;
};

type Group = {
  label: string;
  hint?: string;
  items: Item[];
};

const GROUPS: Group[] = [
  {
    label: "Formation & pédagogie",
    hint: "Référentiels et documents officiels utilisés pour les certifications.",
    items: [
      {
        href: "/admin/settings/formation",
        icon: GraduationCap,
        title: "Programme de formation",
        desc: "Informations de référence pour attestations, certificats, feuilles de présence.",
        badge: "Qualiopi",
      },
      {
        href: "/admin/settings/documents",
        icon: FileSignature,
        title: "Documents d'entrée",
        desc: "Convention, règlement intérieur, livret d'accueil — versions publiées.",
      },
      {
        href: "/admin/glossary",
        icon: BookMarked,
        title: "Glossaire pédagogique",
        desc: "Définitions partagées dans tous les modules et fiches.",
      },
    ],
  },
  {
    label: "Conformité & sécurité",
    hint: "Obligations légales (Qualiopi, RGPD) et protection des comptes.",
    items: [
      {
        href: "/admin/rgpd",
        icon: ShieldCheck,
        title: "RGPD",
        desc: "Demandes d'accès, rectification, effacement, registre des traitements.",
      },
      {
        href: "/admin/security",
        icon: Lock,
        title: "Sécurité & MFA",
        desc: "Authentification multi-facteur, sessions actives, journaux de connexion.",
      },
      {
        href: "/admin/accessibilite",
        icon: Accessibility,
        title: "Accessibilité",
        desc: "Référent handicap, dispositifs adaptés, recueil de besoins spécifiques.",
        badge: "Indicateur 21",
      },
      {
        href: "/admin/audit",
        icon: Database,
        title: "Journal d'audit",
        desc: "Historique horodaté des actions admin (Qualiopi indicateur 32).",
      },
    ],
  },
  {
    label: "Communication",
    hint: "Annonces visibles par les stagiaires et notifications.",
    items: [
      {
        href: "/admin/announcements",
        icon: Bell,
        title: "Annonces",
        desc: "Publier une annonce ciblée par formation ou globale.",
      },
    ],
  },
];

export default function AdminSettingsPage() {
  const total = GROUPS.reduce((s, g) => s + g.items.length, 0);

  return (
    <div className="space-y-10">
      <header>
        <div className="flex items-center gap-2">
          <SettingsIcon className="h-4 w-4 text-signal-700" />
          <span className="eyebrow text-signal-700">Administration</span>
        </div>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Paramètres
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Configuration centrale de la plateforme — pédagogie, conformité,
          sécurité. {total} sections disponibles.
        </p>
      </header>

      {GROUPS.map((g, gi) => (
        <section key={g.label} className="space-y-4">
          {/* Header de groupe */}
          <div className="flex items-baseline justify-between gap-4 border-b border-navy-50 pb-3">
            <div>
              <h2 className="font-display text-lg font-semibold text-navy-900 tracking-tight">
                {g.label}
              </h2>
              {g.hint && (
                <p className="mt-0.5 text-xs text-slate-500">{g.hint}</p>
              )}
            </div>
            <span className="text-[11px] uppercase tracking-wider text-slate-400 font-medium">
              {g.items.length}{" "}
              {g.items.length > 1 ? "sections" : "section"}
            </span>
          </div>

          {/* Grille de cards */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
            {g.items.map((item, ii) => {
              const Icon = item.icon;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className="group relative rounded-2xl bg-white border border-navy-100 p-5 overflow-hidden transition-[transform,box-shadow,border-color] duration-300 hover:-translate-y-0.5 hover:shadow-raised hover:border-brand-300 motion-reduce:hover:translate-y-0"
                  style={{
                    animation: `fade-up 0.5s cubic-bezier(0.22, 1, 0.36, 1) ${
                      gi * 80 + ii * 50
                    }ms both`,
                  }}
                >
                  {/* Halo radial qui s'allume au hover */}
                  <div
                    aria-hidden
                    className="absolute -top-12 -right-12 h-32 w-32 rounded-full pointer-events-none opacity-0 group-hover:opacity-100 transition-opacity duration-500"
                    style={{
                      background:
                        "radial-gradient(circle, rgba(37,48,217,0.18) 0%, transparent 70%)",
                    }}
                  />
                  <div className="relative flex items-start gap-4">
                    <div className="h-11 w-11 rounded-xl bg-brand-50 text-brand-700 flex items-center justify-center shrink-0 transition-transform duration-300 group-hover:scale-105 motion-reduce:group-hover:scale-100">
                      <Icon className="h-5 w-5" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 flex-wrap">
                        <h3 className="font-semibold text-navy-900 group-hover:text-brand-700 transition-colors">
                          {item.title}
                        </h3>
                        {item.badge && (
                          <span className="inline-flex items-center text-[10px] font-bold uppercase tracking-wider text-amber-700 bg-amber-100 rounded-full px-2 py-0.5">
                            {item.badge}
                          </span>
                        )}
                      </div>
                      <p className="mt-1 text-xs text-slate-600 leading-relaxed">
                        {item.desc}
                      </p>
                    </div>
                    <ChevronRight className="h-4 w-4 text-slate-300 group-hover:text-brand-600 group-hover:translate-x-0.5 transition-all shrink-0 self-center motion-reduce:group-hover:translate-x-0" />
                  </div>
                </Link>
              );
            })}
          </div>
        </section>
      ))}
    </div>
  );
}
