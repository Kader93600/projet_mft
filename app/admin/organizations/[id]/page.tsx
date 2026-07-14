import Link from "next/link";
import { redirect, notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  ArrowLeft,
  Building2,
  Mail,
  Users,
  Wallet,
  Hash,
  ShieldCheck,
  Eye,
  GraduationCap,
  type LucideIcon,
} from "lucide-react";
import { isStaff } from "@/lib/permissions";
import { BrandingForm } from "./branding-form";
import type { Tables } from "@/lib/database.types";

export const dynamic = "force-dynamic";

/** Membre + embed `user:profiles(...)` (cf. select). */
type MemberRow = Pick<
  Tables<"organization_members">,
  "id" | "role" | "joined_at"
> & {
  user: Pick<Tables<"profiles">, "id" | "full_name" | "email"> | null;
};

const fmtEuros = (cents: number) =>
  (cents / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  });

const ROLE_LABEL: Record<string, string> = {
  org_admin: "Admin",
  org_viewer: "Lecture",
  org_learner: "Stagiaire",
};

const STATUS_LABEL: Record<string, string> = {
  trial: "Essai",
  active: "Active",
  suspended: "Suspendue",
  churned: "Résiliée",
};

const STATUS_TONE: Record<string, "gold" | "success" | "rose" | "slate"> = {
  trial: "gold",
  active: "success",
  suspended: "rose",
  churned: "slate",
};

export default async function AdminOrgDetailPage(
  props: {
    params: Promise<{ id: string }>;
  }
) {
  const params = await props.params;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profileRow } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  const profile = (profileRow ?? null) as Pick<
    Tables<"profiles">,
    "role"
  > | null;
  if (!profile?.role || !isStaff(profile.role)) redirect("/dashboard");

  const { data: orgRow } = await supabase
    .from("organizations")
    .select("*")
    .eq("id", params.id)
    .maybeSingle();
  const org = (orgRow ?? null) as Tables<"organizations"> | null;
  if (!org) notFound();

  const { data: dashboard } = await supabase
    .from("organization_dashboard")
    .select("*")
    .eq("organization_id", params.id)
    .maybeSingle();
  const d = (dashboard ?? {}) as Partial<Tables<"organization_dashboard">>;

  // `overrideTypes` (API supabase-js) : client non paramétré par `Database`
  // → l'embed to-one `user:profiles` est inféré en tableau alors que
  // PostgREST renvoie un objet.
  const { data: memberRows } = await supabase
    .from("organization_members")
    .select(`
      id, role, joined_at,
      user:profiles!organization_members_user_id_fkey ( id, full_name, email )
    `)
    .eq("organization_id", params.id)
    .order("role")
    .overrideTypes<MemberRow[], { merge: false }>();
  const members = memberRows ?? [];

  return (
    <div className="space-y-8">
      <div>
        <Link
          href="/admin/organizations"
          className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
        >
          <ArrowLeft className="h-4 w-4" /> Toutes les organisations
        </Link>
      </div>

      <header className="flex items-start justify-between gap-3 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
            <Building2 className="h-3.5 w-3.5" />
            Organisation cliente
          </span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
            {org.name}
          </h1>
          <div className="mt-2 flex items-center gap-2 flex-wrap text-sm text-slate-600">
            <Badge tone={STATUS_TONE[org.status] ?? "slate"} size="sm">
              {STATUS_LABEL[org.status] ?? org.status}
            </Badge>
            {org.legal_name && (
              <span className="text-xs text-slate-500">{org.legal_name}</span>
            )}
          </div>
        </div>
      </header>

      {/* Coordonnées */}
      <section className="grid md:grid-cols-2 gap-4">
        <Card>
          <CardBody className="space-y-2 text-sm">
            <h3 className="font-display font-semibold text-navy-900 mb-2">
              Coordonnées
            </h3>
            <Field icon={Mail} label="Email facturation" value={org.billing_email} />
            <Field icon={Hash} label="SIRET" value={org.siret ?? "—"} />
            <Field icon={Hash} label="N° TVA" value={org.vat_number ?? "—"} />
            <Field
              icon={Users}
              label="Contact principal"
              value={org.contact_full_name ?? "—"}
            />
          </CardBody>
        </Card>

        <Card>
          <CardBody className="space-y-2 text-sm">
            <h3 className="font-display font-semibold text-navy-900 mb-2">
              Statistiques
            </h3>
            <Stat
              icon={Users}
              label="Membres"
              value={`${d.members_total ?? 0} (${d.admins_count ?? 0} admin)`}
            />
            <Stat
              icon={GraduationCap}
              label="Inscriptions"
              value={`${d.enrollments_total ?? 0} (${d.enrollments_active ?? 0} actives)`}
            />
            <Stat
              icon={Wallet}
              label="Budget engagé"
              value={fmtEuros(d.total_budget_cents ?? 0)}
            />
            <Stat
              icon={Wallet}
              label="Encaissé"
              value={fmtEuros(d.total_paid_cents ?? 0)}
            />
          </CardBody>
        </Card>
      </section>

      {/* Membres */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <Users className="h-5 w-5 text-gold-700" />
          Membres ({members.length})
        </h2>
        <Card>
          <CardBody className="p-0">
            {members.length === 0 ? (
              <p className="text-sm text-slate-500 px-5 py-6">
                Aucun membre rattaché. Le contact principal n'a pas encore de
                compte MFT existant — créez-le via /admin/users puis rattachez-le
                ici.
              </p>
            ) : (
              <ul className="divide-y divide-navy-50">
                {members.map((m) => (
                  <li
                    key={m.id}
                    className="px-5 py-3 flex items-center justify-between gap-3"
                  >
                    <div className="min-w-0">
                      <div className="font-medium text-navy-900">
                        {m.user?.full_name ?? m.user?.email?.split("@")[0]}
                      </div>
                      <div className="text-xs text-slate-500">{m.user?.email}</div>
                    </div>
                    <Badge
                      tone={
                        m.role === "org_admin"
                          ? "gold"
                          : m.role === "org_viewer"
                          ? "navy"
                          : "slate"
                      }
                      size="sm"
                    >
                      {m.role === "org_admin" && <ShieldCheck className="h-3 w-3" />}
                      {m.role === "org_viewer" && <Eye className="h-3 w-3" />}
                      {ROLE_LABEL[m.role] ?? m.role}
                    </Badge>
                  </li>
                ))}
              </ul>
            )}
          </CardBody>
        </Card>
      </section>

      {/* Branding multi-centre */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <Building2 className="h-5 w-5 text-gold-700" />
          Branding (espace personnalisé)
        </h2>
        <Card>
          <CardBody>
            <BrandingForm
              orgId={org.id}
              initialLogoUrl={org.logo_url ?? null}
              initialPrimaryColor={org.primary_color ?? null}
            />
          </CardBody>
        </Card>
      </section>

      {org.notes && (
        <Card>
          <CardBody className="text-sm">
            <h3 className="font-display font-semibold text-navy-900 mb-2">
              Notes internes
            </h3>
            <p className="text-slate-700 whitespace-pre-wrap">{org.notes}</p>
          </CardBody>
        </Card>
      )}
    </div>
  );
}

function Field({
  icon: Icon,
  label,
  value,
}: {
  icon: LucideIcon;
  label: string;
  value: string;
}) {
  return (
    <div className="flex items-start gap-2">
      <Icon className="h-3.5 w-3.5 text-slate-400 shrink-0 mt-0.5" />
      <div className="min-w-0 flex-1">
        <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold">
          {label}
        </div>
        <div className="text-navy-900 truncate">{value}</div>
      </div>
    </div>
  );
}

function Stat({
  icon: Icon,
  label,
  value,
}: {
  icon: LucideIcon;
  label: string;
  value: string;
}) {
  return (
    <div className="flex items-center justify-between gap-2 py-1">
      <span className="text-slate-600 inline-flex items-center gap-1.5">
        <Icon className="h-3.5 w-3.5" /> {label}
      </span>
      <span className="font-medium text-navy-900 tabular-nums">{value}</span>
    </div>
  );
}
