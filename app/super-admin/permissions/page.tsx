import Link from "next/link";
import {
  ShieldCheck,
  Crown,
  UserCog,
  GraduationCap,
  User,
  Lock,
  Database,
  ChevronRight,
  Info,
} from "lucide-react";

export const metadata = {
  title: "Permissions — Super Admin",
};

/**
 * Page de référence des permissions.
 *
 * Affiche la matrice des rôles × actions, fidèle à `lib/permissions.ts` et aux
 * helpers SQL. Cette page est consultative : la modification se fait par le code
 * (politiques RLS + helpers TS) pour des raisons de sécurité — on ne change pas
 * une permission via l'UI sans relecture / migration.
 */

type Action = {
  category: string;
  label: string;
  super_admin: boolean;
  admin: boolean;
  trainer: boolean;
  student: boolean;
};

const MATRIX: Action[] = [
  // Pédagogie
  { category: "Pédagogie", label: "Lire les modules / leçons publiés", super_admin: true, admin: true, trainer: true, student: true },
  { category: "Pédagogie", label: "Créer / éditer modules et leçons", super_admin: true, admin: true, trainer: false, student: false },
  { category: "Pédagogie", label: "Créer / éditer quiz & examens", super_admin: true, admin: true, trainer: false, student: false },
  { category: "Pédagogie", label: "Banque de questions (validation)", super_admin: true, admin: true, trainer: false, student: false },
  { category: "Pédagogie", label: "Corriger les copies QR", super_admin: true, admin: true, trainer: true, student: false },
  { category: "Pédagogie", label: "Tests de positionnement", super_admin: true, admin: true, trainer: false, student: false },

  // Stagiaires
  { category: "Stagiaires", label: "Voir la liste des stagiaires affectés", super_admin: true, admin: true, trainer: true, student: false },
  { category: "Stagiaires", label: "Voir tous les stagiaires", super_admin: true, admin: true, trainer: false, student: false },
  { category: "Stagiaires", label: "Notes pédagogiques / référent / RDV", super_admin: true, admin: true, trainer: true, student: false },
  { category: "Stagiaires", label: "Inscriptions / financements", super_admin: true, admin: true, trainer: false, student: false },
  { category: "Stagiaires", label: "Gérer les groupes / classes", super_admin: true, admin: true, trainer: false, student: false },

  // Communication
  { category: "Communication", label: "Messagerie avec ses stagiaires", super_admin: true, admin: true, trainer: true, student: true },
  { category: "Communication", label: "Publier une annonce", super_admin: true, admin: true, trainer: false, student: false },
  { category: "Communication", label: "Envoyer une notification ciblée", super_admin: true, admin: true, trainer: false, student: false },

  // Conformité / Qualiopi
  { category: "Conformité", label: "Configurer le programme de formation", super_admin: true, admin: true, trainer: false, student: false },
  { category: "Conformité", label: "Documents d'entrée (convention…)", super_admin: true, admin: true, trainer: false, student: false },
  { category: "Conformité", label: "Glossaire pédagogique", super_admin: true, admin: true, trainer: false, student: false },
  { category: "Conformité", label: "Badges / certificats", super_admin: true, admin: true, trainer: false, student: false },
  { category: "Conformité", label: "Export BPF / rapports Qualiopi", super_admin: true, admin: true, trainer: false, student: false },
  { category: "Conformité", label: "RGPD : voir & traiter les demandes", super_admin: true, admin: true, trainer: false, student: false },

  // Régalien (super_admin uniquement)
  { category: "Régalien", label: "Gérer les rôles utilisateurs", super_admin: true, admin: false, trainer: false, student: false },
  { category: "Régalien", label: "Journal d'audit complet", super_admin: true, admin: false, trainer: false, student: false },
  { category: "Régalien", label: "Configuration globale plateforme", super_admin: true, admin: false, trainer: false, student: false },
  { category: "Régalien", label: "Anonymisation / suppression compte", super_admin: true, admin: false, trainer: false, student: false },
];

const ROLES = [
  { key: "super_admin", label: "Super admin", icon: Crown, color: "text-signal-700 bg-signal-100" },
  { key: "admin", label: "Admin", icon: ShieldCheck, color: "text-brand-700 bg-brand-50" },
  { key: "trainer", label: "Formateur", icon: GraduationCap, color: "text-emerald-700 bg-emerald-50" },
  { key: "student", label: "Stagiaire", icon: User, color: "text-slate-600 bg-slate-100" },
] as const;

export default function PermissionsPage() {
  const grouped = MATRIX.reduce<Record<string, Action[]>>((acc, a) => {
    (acc[a.category] ??= []).push(a);
    return acc;
  }, {});

  return (
    <div className="space-y-8">
      <header>
        <div className="flex items-center gap-2">
          <ShieldCheck className="h-4 w-4 text-signal-700" />
          <span className="eyebrow text-signal-700">Régalien</span>
        </div>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Matrice des permissions
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl leading-relaxed">
          Référence des actions autorisées par rôle. Aligné sur les helpers
          <code className="mx-1 px-1.5 py-0.5 rounded bg-navy-50 text-navy-800 text-[13px] font-mono">
            lib/permissions.ts
          </code>
          et les politiques RLS Supabase.
        </p>
      </header>

      <div className="rounded-2xl bg-amber-50 border border-amber-200 p-4 flex items-start gap-3">
        <Info className="h-5 w-5 text-amber-700 shrink-0 mt-0.5" />
        <div className="text-sm text-amber-900">
          <strong>Modification :</strong> les permissions ne se modifient pas
          depuis l'interface. Toute évolution passe par une revue de code
          (helpers TypeScript + politiques RLS) et une migration SQL versionnée.
          Pour assigner un rôle à un utilisateur, voir{" "}
          <Link href="/super-admin/roles" className="underline font-semibold">
            Gestion des rôles
          </Link>
          .
        </div>
      </div>

      {Object.entries(grouped).map(([category, actions]) => (
        <section key={category} className="space-y-3">
          <h2 className="font-display text-lg font-semibold text-navy-900 tracking-tight">
            {category}
          </h2>
          <div className="rounded-2xl bg-white border border-navy-100 overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-navy-50/60">
                <tr>
                  <th className="text-left px-5 py-3 font-semibold text-navy-700 text-xs uppercase tracking-wider">
                    Action
                  </th>
                  {ROLES.map((r) => {
                    const Icon = r.icon;
                    return (
                      <th
                        key={r.key}
                        className="text-center px-3 py-3 font-semibold text-navy-700 text-[11px] uppercase tracking-wider"
                      >
                        <span className="inline-flex items-center gap-1.5">
                          <Icon className="h-3.5 w-3.5" />
                          <span className="hidden sm:inline">{r.label}</span>
                        </span>
                      </th>
                    );
                  })}
                </tr>
              </thead>
              <tbody>
                {actions.map((a) => (
                  <tr key={a.label} className="border-t border-navy-50">
                    <td className="px-5 py-3 text-slate-700">{a.label}</td>
                    {ROLES.map((r) => (
                      <td key={r.key} className="text-center px-3 py-3">
                        {a[r.key as keyof Action] ? (
                          <span className="inline-flex h-5 w-5 items-center justify-center rounded-full bg-emerald-100">
                            <span className="h-1.5 w-1.5 rounded-full bg-emerald-600" />
                          </span>
                        ) : (
                          <span className="inline-block text-slate-300">—</span>
                        )}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      ))}

      <section className="rounded-2xl bg-white border border-navy-100 p-6">
        <h2 className="font-display text-lg font-semibold text-navy-900 mb-4">
          Liens utiles
        </h2>
        <div className="grid sm:grid-cols-2 gap-3">
          <Link
            href="/super-admin/roles"
            className="group flex items-center justify-between rounded-xl border border-navy-100 p-4 hover:border-brand-300 hover:shadow-soft transition"
          >
            <span className="flex items-center gap-3">
              <UserCog className="h-5 w-5 text-brand-700" />
              <span className="font-medium text-navy-900 group-hover:text-brand-700">
                Gestion des rôles
              </span>
            </span>
            <ChevronRight className="h-4 w-4 text-slate-300 group-hover:text-brand-600" />
          </Link>
          <Link
            href="/super-admin/audit"
            className="group flex items-center justify-between rounded-xl border border-navy-100 p-4 hover:border-brand-300 hover:shadow-soft transition"
          >
            <span className="flex items-center gap-3">
              <Database className="h-5 w-5 text-brand-700" />
              <span className="font-medium text-navy-900 group-hover:text-brand-700">
                Journal d'audit
              </span>
            </span>
            <ChevronRight className="h-4 w-4 text-slate-300 group-hover:text-brand-600" />
          </Link>
          <Link
            href="/admin/security"
            className="group flex items-center justify-between rounded-xl border border-navy-100 p-4 hover:border-brand-300 hover:shadow-soft transition"
          >
            <span className="flex items-center gap-3">
              <Lock className="h-5 w-5 text-brand-700" />
              <span className="font-medium text-navy-900 group-hover:text-brand-700">
                MFA & sécurité comptes
              </span>
            </span>
            <ChevronRight className="h-4 w-4 text-slate-300 group-hover:text-brand-600" />
          </Link>
        </div>
      </section>
    </div>
  );
}
