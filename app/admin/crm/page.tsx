import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Users,
  Inbox,
  AlertCircle,
  CheckCircle2,
  Clock,
  UserPlus,
  ChevronRight,
  RotateCcw,
  Trash2,
} from "lucide-react";
import { isStaff } from "@/lib/permissions";
import { ConfirmAction } from "@/components/ui/confirm-action";
import {
  deleteEnrollmentRequest,
  setRequestStatus,
} from "../enrollments/actions";

export const dynamic = "force-dynamic";

const STATUS_LABEL: Record<string, string> = {
  nouveau: "Nouveau",
  contacte: "Contacté",
  devis_envoye: "Devis envoyé",
  inscrit: "Inscrit",
  refuse: "Refusé",
};

const PIPELINE_ORDER: Array<keyof typeof STATUS_LABEL> = [
  "nouveau",
  "contacte",
  "devis_envoye",
];

const STATUS_TONE: Record<string, "gold" | "navy" | "success" | "slate" | "rose"> = {
  nouveau: "gold",
  contacte: "navy",
  devis_envoye: "navy",
  inscrit: "success",
  refuse: "slate",
};

export default async function AdminCrmPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("role, full_name")
    .eq("id", user.id)
    .maybeSingle();
  if (!profile?.role || !isStaff(profile.role)) redirect("/dashboard");

  // Ma file : leads qui me sont assignés
  const { data: myQueueRaw } = await supabase
    .from("crm_my_queue")
    .select("*");
  const myQueue = (myQueueRaw ?? []) as any[];

  // Pipeline counters
  const { data: countersRaw } = await supabase
    .from("crm_pipeline_counters")
    .select("*");
  const counters = (countersRaw ?? []) as any[];

  // Leads non-assignés (pool global) — limité aux 3 statuts actifs
  const { data: poolRaw } = await supabase
    .from("enrollment_requests")
    .select(`
      id, full_name, email, phone, status, funding_kind, source, tags,
      created_at, snoozed_until, next_followup_at, message
    `)
    .is("assigned_to_admin_id", null)
    .in("status", PIPELINE_ORDER)
    .order("created_at", { ascending: false })
    .limit(60);
  const pool = (poolRaw ?? []) as any[];

  // Leads convertis ou refusés (statut terminal). Sans ce bloc, un lead
  // "inscrit" disparaît de toutes les vues admin alors qu'il n'a peut-être
  // pas encore son compte stagiaire / dossier créés → on perd des clients.
  const { data: closedRaw } = await supabase
    .from("enrollment_requests")
    .select(`
      id, full_name, email, phone, status, funding_kind, source,
      created_at, message, formation_slug
    `)
    .in("status", ["inscrit", "refuse"])
    .order("created_at", { ascending: false })
    .limit(60);
  const closed = (closedRaw ?? []) as any[];

  // Stats globales
  const totalNew = counters.find((c) => c.status === "nouveau")?.count ?? 0;
  const totalContacted =
    counters.find((c) => c.status === "contacte")?.count ?? 0;
  const totalQuote =
    counters.find((c) => c.status === "devis_envoye")?.count ?? 0;
  const totalUnassigned = counters.reduce(
    (s, c) => s + (c.unassigned_count ?? 0),
    0
  );
  const totalOverdue = counters.reduce(
    (s, c) => s + (c.overdue_count ?? 0),
    0
  );

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
          <Users className="h-3.5 w-3.5" />
          CRM — Pipeline commercial
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Pipeline des prospects
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Suivi des prospects entre le formulaire de contact et leur
          inscription. Prenez en charge un lead, ajoutez des notes après
          chaque échange, et planifiez vos relances.
        </p>
      </header>

      {/* KPIs */}
      <section className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <Kpi
          icon={Inbox}
          label="Nouveaux leads"
          value={String(totalNew)}
          hint={`${totalUnassigned} sans attribution`}
          tone={totalNew > 0 ? "warning" : "default"}
        />
        <Kpi
          icon={Clock}
          label="En cours d'échange"
          value={String(totalContacted)}
          hint={`${totalQuote} avec devis envoyé`}
        />
        <Kpi
          icon={UserPlus}
          label="Ma file"
          value={String(myQueue.length)}
          hint={
            myQueue.filter((l: any) => l.followup_due).length > 0
              ? `${myQueue.filter((l: any) => l.followup_due).length} relances dues`
              : "Tout est à jour"
          }
          tone={
            myQueue.filter((l: any) => l.followup_due).length > 0
              ? "warning"
              : "default"
          }
        />
        <Kpi
          icon={AlertCircle}
          label="Relances en retard"
          value={String(totalOverdue)}
          hint="Tous admins confondus"
          tone={totalOverdue > 0 ? "warning" : "default"}
        />
      </section>

      {/* Ma file */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <UserPlus className="h-5 w-5 text-gold-700" />
          Ma file ({myQueue.length})
        </h2>
        {myQueue.length === 0 ? (
          <Card>
            <CardBody className="text-center py-8">
              <div className="mx-auto h-12 w-12 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 flex items-center justify-center">
                <CheckCircle2 className="h-6 w-6" />
              </div>
              <p className="mt-3 font-medium text-navy-900">
                Vous n'avez aucun lead assigné
              </p>
              <p className="text-sm text-slate-600 mt-1">
                Sélectionnez un lead dans le pool ci-dessous et cliquez{" "}
                <strong>"Je prends"</strong> pour l'ajouter à votre file.
              </p>
            </CardBody>
          </Card>
        ) : (
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {myQueue.map((lead) => (
                  <LeadRow key={lead.id} lead={lead} showFollowup />
                ))}
              </ul>
            </CardBody>
          </Card>
        )}
      </section>

      {/* Pool non-assignés */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <Inbox className="h-5 w-5 text-gold-700" />
          Pool non-assigné ({pool.length})
        </h2>
        {pool.length === 0 ? (
          <Card>
            <CardBody className="text-center py-8">
              <p className="text-sm text-slate-500">
                Aucun lead en pool — tous les leads actifs ont un référent.
              </p>
            </CardBody>
          </Card>
        ) : (
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {pool.map((lead) => (
                  <LeadRow key={lead.id} lead={lead} />
                ))}
              </ul>
            </CardBody>
          </Card>
        )}
      </section>

      {/* Convertis & refusés — historique des leads terminaux.
          Indispensable pour retrouver un lead "inscrit" qui n'aurait pas
          encore vu son compte stagiaire créé (action manuelle requise). */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <CheckCircle2 className="h-5 w-5 text-emerald-600" />
          Convertis & refusés ({closed.length})
        </h2>
        <p className="text-sm text-slate-500 -mt-2 mb-4 max-w-2xl">
          Leads dont le statut a été passé à <strong>inscrit</strong> ou{" "}
          <strong>refusé</strong>. Un lead « inscrit » ne crée pas
          automatiquement son compte stagiaire : clic sur la ligne →{" "}
          <em>Créer le compte stagiaire</em> pour finaliser.
        </p>
        {closed.length === 0 ? (
          <Card>
            <CardBody className="text-center py-8">
              <p className="text-sm text-slate-500">
                Aucun lead clôturé pour l'instant.
              </p>
            </CardBody>
          </Card>
        ) : (
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {closed.map((lead) => (
                  <LeadRow key={lead.id} lead={lead} showCreateCta />
                ))}
              </ul>
            </CardBody>
          </Card>
        )}
      </section>
    </div>
  );
}

// ─── Composants ──────────────────────────────────────────────────────

function LeadRow({
  lead,
  showFollowup = false,
  showCreateCta = false,
}: {
  lead: any;
  showFollowup?: boolean;
  /** Affiche un CTA secondaire "Créer le compte stagiaire" — pour les
   *  leads "inscrit" qui n'ont pas encore leur profil créé. */
  showCreateCta?: boolean;
}) {
  const status = lead.status as keyof typeof STATUS_LABEL;
  const tone = STATUS_TONE[status] ?? "slate";
  const createdAt = new Date(lead.created_at);
  const ageDays = Math.floor(
    (Date.now() - createdAt.getTime()) / (1000 * 60 * 60 * 24)
  );
  const followupDue =
    showFollowup &&
    lead.next_followup_at &&
    new Date(lead.next_followup_at) <= new Date();
  const isSnoozed = lead.is_snoozed === true;

  // Pré-remplit /admin/users/new avec les infos du lead via query params
  const createUrl =
    `/admin/users/new` +
    `?email=${encodeURIComponent(lead.email ?? "")}` +
    `&full_name=${encodeURIComponent(lead.full_name ?? "")}` +
    `&phone=${encodeURIComponent(lead.phone ?? "")}` +
    (lead.formation_slug
      ? `&formation_slug=${encodeURIComponent(lead.formation_slug)}`
      : "") +
    (lead.funding_kind
      ? `&funding_kind=${encodeURIComponent(lead.funding_kind)}`
      : "");

  return (
    <li className="px-5 py-3.5 hover:bg-navy-50/30">
      <div className="flex items-center justify-between gap-3">
        <Link
          href={`/admin/crm/${lead.id}`}
          className="block min-w-0 flex-1 group"
        >
          <div className="flex items-center gap-2 flex-wrap mb-0.5">
            <span className="font-medium text-navy-900 group-hover:text-brand-700">
              {lead.full_name}
            </span>
            <Badge tone={tone} size="sm">
              {STATUS_LABEL[status] ?? status}
            </Badge>
            {followupDue && (
              <Badge tone="rose" size="sm">
                <AlertCircle className="h-3 w-3" />
                Relance due
              </Badge>
            )}
            {isSnoozed && (
              <Badge tone="slate" size="sm">
                <Clock className="h-3 w-3" />
                En pause
              </Badge>
            )}
            {Array.isArray(lead.tags) &&
              lead.tags.slice(0, 3).map((t: string) => (
                <span
                  key={t}
                  className="inline-flex items-center text-[10px] uppercase tracking-wider text-slate-500 bg-slate-100 border border-slate-200 rounded px-1.5 py-0.5"
                >
                  #{t}
                </span>
              ))}
          </div>
          <div className="text-xs text-slate-500">
            {lead.email} · Reçu il y a {ageDays} j
            {lead.funding_kind && (
              <span className="ml-1">· {lead.funding_kind.toUpperCase()}</span>
            )}
            {lead.formation_slug && (
              <span className="ml-1">· {lead.formation_slug.toUpperCase()}</span>
            )}
          </div>
        </Link>
        {showCreateCta && status === "inscrit" && (
          <Link
            href={createUrl}
            className="shrink-0 inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-signal-300 bg-signal-50 text-signal-800 text-xs font-semibold hover:bg-signal-100"
            title="Créer le compte stagiaire à partir des infos du lead"
          >
            <UserPlus className="h-3.5 w-3.5" />
            Créer le compte
          </Link>
        )}
        {showCreateCta && (
          <div className="shrink-0 flex items-center gap-1.5">
            {/* Réactiver : repasse en "contacté" pour réintégrer le pipeline */}
            <ConfirmAction
              action={setRequestStatus.bind(null, lead.id, "contacte")}
              title={
                status === "inscrit"
                  ? "Annuler l'inscription de ce lead ?"
                  : "Réactiver ce lead refusé ?"
              }
              description={
                status === "inscrit"
                  ? `Le lead « ${lead.full_name} » repassera en "Contacté" et réapparaîtra dans le pipeline. Cette action n'affecte pas un éventuel compte stagiaire déjà créé.`
                  : `Le lead « ${lead.full_name} » repassera en "Contacté" et réapparaîtra dans le pipeline pour être recontacté.`
              }
              confirmLabel="Réactiver"
              successMsg="Lead réactivé en Contacté"
              icon={<RotateCcw className="h-3.5 w-3.5" />}
              iconLabel={
                status === "inscrit" ? "Annuler l'inscription" : "Réactiver"
              }
              tone="navy"
              variant="soft"
            />
            {/* Supprimer : irréversible */}
            <ConfirmAction
              action={deleteEnrollmentRequest.bind(null, lead.id)}
              title="Supprimer définitivement ce lead ?"
              description={`Le lead « ${lead.full_name} » (${lead.email}) sera supprimé de la base CRM. Cette action est irréversible et n'affecte pas un éventuel compte stagiaire déjà créé.`}
              confirmLabel="Supprimer définitivement"
              successMsg="Lead supprimé"
              icon={<Trash2 className="h-3.5 w-3.5" />}
              iconLabel="Supprimer le lead"
              tone="rose"
              variant="soft"
            />
          </div>
        )}
        <ChevronRight className="h-4 w-4 text-slate-400 shrink-0" />
      </div>
    </li>
  );
}

function Kpi({
  icon: Icon,
  label,
  value,
  hint,
  tone = "default",
}: {
  icon: any;
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
