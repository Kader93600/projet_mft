import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import type { Tables } from "@/lib/database.types";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Building2,
  Users,
  GraduationCap,
  Wallet,
  Hourglass,
  ArrowRight,
  ShieldCheck,
  type LucideIcon,
} from "lucide-react";
import { getOrganizationAccess } from "@/lib/organization/access";

export const dynamic = "force-dynamic";

/** Vue agrégée `organization_dashboard` (toutes colonnes nullable). */
type OrgDashboard = Tables<"organization_dashboard">;

/** Résultat du select `enrollments` + embeds `user:profiles!user_id`, `formation:formations`. */
type RecentEnrollment = Pick<
  Tables<"enrollments">,
  "id" | "status" | "pack" | "created_at" | "seats_reserved" | "total_amount_cents"
> & {
  user: Pick<Tables<"profiles">, "full_name" | "email"> | null;
  formation: Pick<Tables<"formations">, "title" | "slug" | "code"> | null;
};

const fmtEuros = (cents: number) =>
  (cents / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  });

export default async function OrganisationPage() {
  const access = await getOrganizationAccess();
  if (!access.allowed) {
    if (access.reason === "unauthenticated") redirect("/login");
    return (
      <div className="space-y-6 max-w-2xl">
        <header>
          <span className="eyebrow text-gold-700">Espace entreprise</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
            Aucune organisation
          </h1>
        </header>
        <Card>
          <CardBody className="text-sm text-slate-600">
            Votre compte n'est rattaché à aucune entreprise cliente. Si votre
            employeur a souscrit à MFT et souhaite vous donner accès à l'espace
            entreprise, contactez votre référent ou l'administration MFT.
          </CardBody>
        </Card>
      </div>
    );
  }

  if (!access.organization_id) {
    // Admin MFT sans orga rattachée → renvoyer vers /admin/organizations
    return (
      <div className="space-y-6 max-w-2xl">
        <header>
          <span className="eyebrow text-gold-700">Admin MFT</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
            Gestion des entreprises clientes
          </h1>
        </header>
        <Card>
          <CardBody className="space-y-3">
            <p className="text-sm text-slate-600">
              Vous n'êtes pas rattaché à une organisation. La gestion globale
              des organisations clientes se trouve dans l'admin.
            </p>
            <Link
              href="/admin/organizations"
              className="inline-flex items-center gap-1.5 rounded-xl bg-navy-900 hover:bg-navy-800 text-white px-3.5 py-2 text-sm font-medium transition-colors"
            >
              Voir /admin/organizations <ArrowRight className="h-3.5 w-3.5" />
            </Link>
          </CardBody>
        </Card>
      </div>
    );
  }

  const supabase = await createClient();

  const { data: dashboardRow } = await supabase
    .from("organization_dashboard")
    .select("*")
    .eq("organization_id", access.organization_id)
    .maybeSingle();
  // `?? {}` : la vue peut ne renvoyer aucune ligne (orga sans activité) →
  // toutes les colonnes sont alors absentes, d'où le Partial.
  const d: Partial<OrgDashboard> = (dashboardRow as OrgDashboard | null) ?? {};

  // 5 derniers enrollments de l'orga
  const { data: recentEnrollments } = await supabase
    .from("enrollments")
    .select(`
      id, status, pack, created_at, seats_reserved, total_amount_cents,
      user:profiles!user_id ( full_name, email ),
      formation:formations ( title, slug, code )
    `)
    .eq("organization_id", access.organization_id)
    .order("created_at", { ascending: false })
    .limit(5)
    // Le client n'étant pas câblé sur `Database`, postgrest infère les embeds
    // to-one comme des tableaux : on impose la forme réelle renvoyée par l'API.
    .overrideTypes<RecentEnrollment[], { merge: false }>();

  return (
    <div className="space-y-10">
      <header className="flex items-start justify-between gap-3 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
            <Building2 className="h-3.5 w-3.5" />
            Espace entreprise
          </span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
            {access.organization_name}
          </h1>
          <div className="mt-2 flex items-center gap-2 flex-wrap text-sm text-slate-600">
            <Badge
              tone={access.role === "org_admin" ? "gold" : "navy"}
              size="sm"
            >
              <ShieldCheck className="h-3 w-3" />
              {access.role === "org_admin"
                ? "Administrateur"
                : access.role === "org_viewer"
                ? "Consultation"
                : "Membre"}
            </Badge>
            {d.status && (
              <Badge tone="slate" size="sm">
                {d.status}
              </Badge>
            )}
          </div>
        </div>
        {access.is_org_admin && (
          <div className="flex flex-wrap gap-2">
            <Link
              href="/organisation/parametres/equipe"
              className="inline-flex items-center gap-1.5 rounded-xl bg-white border border-navy-200 hover:bg-navy-50 text-navy-900 px-3.5 py-2 text-sm font-medium transition-colors"
            >
              <Users className="h-4 w-4" />
              Gérer l'équipe
            </Link>
          </div>
        )}
      </header>

      {/* KPIs */}
      <section className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <Kpi
          icon={Users}
          label="Membres"
          value={String(d.members_total ?? 0)}
          hint={`${d.admins_count ?? 0} admin · ${d.learners_count ?? 0} stagiaires`}
        />
        <Kpi
          icon={GraduationCap}
          label="Inscriptions"
          value={String(d.enrollments_total ?? 0)}
          hint={`${d.enrollments_active ?? 0} en cours`}
        />
        <Kpi
          icon={Hourglass}
          label="Places en attente"
          value={String(d.seats_pending ?? 0)}
          hint={
            (d.seats_pending ?? 0) > 0
              ? "Stagiaires à inviter"
              : "Toutes les places assignées"
          }
          tone={(d.seats_pending ?? 0) > 0 ? "warning" : "default"}
        />
        <Kpi
          icon={Wallet}
          label="Budget engagé"
          value={fmtEuros(d.total_budget_cents ?? 0)}
          hint={`${fmtEuros(d.total_paid_cents ?? 0)} payé`}
        />
      </section>

      {/* Liens rapides */}
      <section className="grid md:grid-cols-2 gap-4">
        <Link href="/organisation/stagiaires" className="group">
          <Card className="h-full transition-all group-hover:shadow-raised group-hover:-translate-y-0.5">
            <CardBody className="flex items-start gap-3">
              <div className="h-10 w-10 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center shrink-0">
                <GraduationCap className="h-5 w-5" />
              </div>
              <div className="flex-1">
                <div className="font-display font-semibold text-navy-900 inline-flex items-center gap-1">
                  Mes stagiaires
                  <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
                </div>
                <p className="text-sm text-slate-600 mt-1">
                  Liste, progression, score moyen, certifications.
                </p>
              </div>
            </CardBody>
          </Card>
        </Link>

        {access.is_org_admin && (
          <Link href="/organisation/parametres/equipe" className="group">
            <Card className="h-full transition-all group-hover:shadow-raised group-hover:-translate-y-0.5">
              <CardBody className="flex items-start gap-3">
                <div className="h-10 w-10 rounded-xl bg-navy-50 border border-navy-200 text-navy-800 flex items-center justify-center shrink-0">
                  <Users className="h-5 w-5" />
                </div>
                <div className="flex-1">
                  <div className="font-display font-semibold text-navy-900 inline-flex items-center gap-1">
                    Équipe administratrice
                    <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
                  </div>
                  <p className="text-sm text-slate-600 mt-1">
                    Inviter des co-administrateurs ou rattacher des stagiaires.
                  </p>
                </div>
              </CardBody>
            </Card>
          </Link>
        )}
      </section>

      {/* Dernières inscriptions */}
      {(recentEnrollments ?? []).length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
            <GraduationCap className="h-5 w-5 text-gold-700" />
            Dernières inscriptions
          </h2>
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {(recentEnrollments ?? []).map((e) => (
                  <li
                    key={e.id}
                    className="px-5 py-3 flex items-center justify-between gap-3"
                  >
                    <div className="min-w-0">
                      <div className="font-medium text-navy-900">
                        {e.seats_reserved
                          ? "Place en attente"
                          : e.user?.full_name ??
                            e.user?.email?.split("@")[0] ??
                            "—"}
                      </div>
                      <div className="text-xs text-slate-500">
                        {e.formation?.code ?? "—"} · {e.formation?.title ?? "—"}{" "}
                        · {e.pack}
                      </div>
                    </div>
                    <div className="flex items-center gap-2 shrink-0">
                      <Badge tone="navy" size="sm">
                        {e.status}
                      </Badge>
                      <span className="font-display font-semibold text-sm tabular-nums text-navy-900">
                        {fmtEuros(e.total_amount_cents ?? 0)}
                      </span>
                    </div>
                  </li>
                ))}
              </ul>
            </CardBody>
          </Card>
        </section>
      )}
    </div>
  );
}

function Kpi({
  icon: Icon,
  label,
  value,
  hint,
  tone = "default",
}: {
  icon: LucideIcon;
  label: string;
  value: string;
  hint?: string;
  tone?: "default" | "warning";
}) {
  const iconBg =
    tone === "warning"
      ? "bg-amber-50 border-amber-200 text-amber-700"
      : "bg-gold-50 border-gold-200 text-gold-700";
  return (
    <Card>
      <CardBody className="p-4 sm:p-5">
        <div className="flex items-start gap-3">
          <div
            className={`h-10 w-10 rounded-xl border flex items-center justify-center shrink-0 ${iconBg}`}
          >
            <Icon className="h-5 w-5" />
          </div>
          <div className="min-w-0">
            <div className="text-[11px] uppercase tracking-wider text-slate-500 font-medium leading-tight">
              {label}
            </div>
            <div className="font-display text-2xl font-semibold text-navy-900 mt-0.5 tabular-nums leading-none">
              {value}
            </div>
            {hint && (
              <div className="text-[11px] text-slate-500 mt-1.5">{hint}</div>
            )}
          </div>
        </div>
      </CardBody>
    </Card>
  );
}
