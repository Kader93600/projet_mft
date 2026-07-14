import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Users, ArrowLeft, ShieldCheck, Eye } from "lucide-react";
import { getOrganizationAccess } from "@/lib/organization/access";
import { TeamMemberActions } from "./team-actions";

export const dynamic = "force-dynamic";

const ROLE_LABEL: Record<string, string> = {
  org_admin: "Administrateur",
  org_viewer: "Lecture seule",
  org_learner: "Stagiaire",
};

const ROLE_TONE: Record<string, "gold" | "navy" | "slate"> = {
  org_admin: "gold",
  org_viewer: "navy",
  org_learner: "slate",
};

export default async function TeamPage() {
  const access = await getOrganizationAccess();
  if (!access.allowed) {
    if (access.reason === "unauthenticated") redirect("/login");
    redirect("/organisation");
  }
  if (!access.is_org_admin) redirect("/organisation");
  if (!access.organization_id) redirect("/admin/organizations");

  const supabase = await createClient();
  const { data: members } = await supabase
    .from("organization_members")
    .select(`
      id, role, joined_at,
      user:profiles!organization_members_user_id_fkey ( id, full_name, email )
    `)
    .eq("organization_id", access.organization_id)
    .order("role")
    .order("joined_at");

  const list = (members ?? []) as any[];
  const admins = list.filter((m) => m.role === "org_admin");
  const viewers = list.filter((m) => m.role === "org_viewer");
  const learners = list.filter((m) => m.role === "org_learner");

  return (
    <div className="space-y-8">
      <div>
        <Link
          href="/organisation"
          className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
        >
          <ArrowLeft className="h-4 w-4" /> Tableau de bord
        </Link>
      </div>

      <header>
        <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
          <Users className="h-3.5 w-3.5" />
          Équipe
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Membres de l'organisation
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          {list.length} membre{list.length > 1 ? "s" : ""} dans{" "}
          {access.organization_name}. Pour ajouter un nouveau membre, créez
          d'abord son compte stagiaire MFT, puis contactez l'administration
          pour le rattacher.
        </p>
      </header>

      {/* Section administrateurs */}
      {admins.length > 0 && (
        <section>
          <h2 className="font-display text-lg font-semibold text-navy-900 mb-3 inline-flex items-center gap-2">
            <ShieldCheck className="h-4 w-4 text-gold-700" />
            Administrateurs ({admins.length})
          </h2>
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {admins.map((m) => (
                  <MemberRow key={m.id} member={m} canRemove={m.user?.id !== undefined} />
                ))}
              </ul>
            </CardBody>
          </Card>
        </section>
      )}

      {/* Section lecture seule */}
      {viewers.length > 0 && (
        <section>
          <h2 className="font-display text-lg font-semibold text-navy-900 mb-3 inline-flex items-center gap-2">
            <Eye className="h-4 w-4 text-navy-700" />
            Lecture seule ({viewers.length})
          </h2>
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {viewers.map((m) => (
                  <MemberRow key={m.id} member={m} canRemove />
                ))}
              </ul>
            </CardBody>
          </Card>
        </section>
      )}

      {/* Section stagiaires */}
      {learners.length > 0 && (
        <section>
          <h2 className="font-display text-lg font-semibold text-navy-900 mb-3 inline-flex items-center gap-2">
            <Users className="h-4 w-4 text-slate-700" />
            Stagiaires ({learners.length})
          </h2>
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {learners.map((m) => (
                  <MemberRow key={m.id} member={m} canRemove />
                ))}
              </ul>
            </CardBody>
          </Card>
        </section>
      )}

      <Card variant="gold">
        <CardBody className="text-sm text-slate-700">
          <p className="font-medium text-navy-900 mb-2">
            Ajouter un membre à votre organisation
          </p>
          <p>
            Cette action nécessite que la personne ait déjà un compte MFT.
            Demandez-lui de créer son compte sur{" "}
            <Link href="/login" className="text-gold-700 underline">
              maformationtransport.fr/login
            </Link>
            , puis communiquez son email à l'administration MFT qui finalisera
            le rattachement à votre organisation.
          </p>
        </CardBody>
      </Card>
    </div>
  );
}

function MemberRow({
  member,
  canRemove,
}: {
  member: any;
  canRemove: boolean;
}) {
  const u = member.user;
  return (
    <li className="px-5 py-3 flex items-center justify-between gap-3">
      <div className="min-w-0">
        <div className="font-medium text-navy-900">
          {u?.full_name ?? u?.email?.split("@")[0] ?? "—"}
        </div>
        <div className="text-xs text-slate-500">
          {u?.email} · Membre depuis le{" "}
          {new Date(member.joined_at).toLocaleDateString("fr-FR", {
            day: "2-digit",
            month: "short",
            year: "numeric",
          })}
        </div>
      </div>
      <div className="flex items-center gap-2 shrink-0">
        <Badge tone={ROLE_TONE[member.role] ?? "slate"} size="sm">
          {ROLE_LABEL[member.role] ?? member.role}
        </Badge>
        {canRemove && <TeamMemberActions memberId={member.id} />}
      </div>
    </li>
  );
}
