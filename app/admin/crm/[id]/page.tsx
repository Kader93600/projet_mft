import Link from "next/link";
import { redirect, notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  ArrowLeft,
  Mail,
  Phone,
  Calendar,
  User as UserIcon,
  Tag as TagIcon,
  AlertCircle,
  Clock,
  Building2,
} from "lucide-react";
import { isStaff } from "@/lib/permissions";
import { LeadActionsBar } from "./actions-bar";
import { NoteForm } from "./note-form";
import { LeadTimeline } from "./timeline";
import { TagsEditor } from "./tags-editor";

export const dynamic = "force-dynamic";

const STATUS_LABEL: Record<string, string> = {
  nouveau: "Nouveau",
  contacte: "Contacté",
  devis_envoye: "Devis envoyé",
  inscrit: "Inscrit",
  refuse: "Refusé",
};

const STATUS_TONE: Record<string, "gold" | "navy" | "success" | "slate" | "rose"> = {
  nouveau: "gold",
  contacte: "navy",
  devis_envoye: "navy",
  inscrit: "success",
  refuse: "rose",
};

export default async function CrmLeadDetailPage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  if (!profile?.role || !isStaff(profile.role)) redirect("/dashboard");

  // Lead complet
  const { data: lead } = await supabase
    .from("enrollment_requests")
    .select(`
      *,
      assigned_admin:profiles!enrollment_requests_assigned_to_admin_id_fkey (
        id, full_name, email
      )
    `)
    .eq("id", params.id)
    .maybeSingle();
  if (!lead) notFound();

  // Notes
  const { data: notesRaw } = await supabase
    .from("lead_notes")
    .select(`
      id, kind, body, occurred_at, created_at,
      author:profiles!lead_notes_author_id_fkey ( full_name, email )
    `)
    .eq("enrollment_request_id", params.id)
    .order("occurred_at", { ascending: false })
    .limit(50);
  const notes = (notesRaw ?? []) as any[];

  // Activités (audit trail)
  const { data: activitiesRaw } = await supabase
    .from("lead_activities")
    .select(`
      id, kind, details, created_at,
      author:profiles!lead_activities_author_id_fkey ( full_name )
    `)
    .eq("enrollment_request_id", params.id)
    .order("created_at", { ascending: false })
    .limit(50);
  const activities = (activitiesRaw ?? []) as any[];

  const l = lead as any;
  const isMine = l.assigned_to_admin_id === user.id;
  const followupDue =
    l.next_followup_at && new Date(l.next_followup_at) <= new Date();
  const isSnoozed = l.snoozed_until && new Date(l.snoozed_until) > new Date();

  return (
    <div className="space-y-8">
      <div>
        <Link
          href="/admin/crm"
          className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
        >
          <ArrowLeft className="h-4 w-4" /> Pipeline
        </Link>
      </div>

      {/* Header */}
      <header className="flex items-start gap-4 flex-wrap">
        <div className="h-14 w-14 rounded-full bg-gradient-to-br from-brand-500 to-brand-700 text-white flex items-center justify-center font-display text-lg font-bold shrink-0">
          {(l.full_name ?? "?").slice(0, 2).toUpperCase()}
        </div>
        <div className="flex-1 min-w-0">
          <span className="eyebrow text-gold-700">Prospect</span>
          <h1 className="mt-1 font-display text-2xl md:text-3xl font-semibold text-navy-950 tracking-tight">
            {l.full_name}
          </h1>
          <div className="mt-2 flex items-center gap-3 flex-wrap text-sm text-slate-600">
            {l.email && (
              <a
                href={`mailto:${l.email}`}
                className="inline-flex items-center gap-1 hover:text-gold-700"
              >
                <Mail className="h-3.5 w-3.5" />
                {l.email}
              </a>
            )}
            {l.phone && (
              <a
                href={`tel:${l.phone}`}
                className="inline-flex items-center gap-1 hover:text-gold-700"
              >
                <Phone className="h-3.5 w-3.5" />
                {l.phone}
              </a>
            )}
          </div>
          <div className="mt-3 flex items-center gap-2 flex-wrap">
            <Badge tone={STATUS_TONE[l.status] ?? "slate"} size="sm">
              {STATUS_LABEL[l.status] ?? l.status}
            </Badge>
            {l.funding_kind && (
              <Badge tone="navy" size="sm">
                {l.funding_kind.toUpperCase()}
              </Badge>
            )}
            {l.assigned_admin && (
              <Badge tone="gold" size="sm">
                <UserIcon className="h-3 w-3" />
                {l.assigned_admin.full_name ??
                  l.assigned_admin.email?.split("@")[0]}
              </Badge>
            )}
            {followupDue && (
              <Badge tone="rose" size="sm">
                <AlertCircle className="h-3 w-3" />
                Relance due
              </Badge>
            )}
            {isSnoozed && (
              <Badge tone="slate" size="sm">
                <Clock className="h-3 w-3" />
                En pause jusqu'au{" "}
                {new Date(l.snoozed_until).toLocaleDateString("fr-FR", {
                  day: "2-digit",
                  month: "short",
                })}
              </Badge>
            )}
          </div>
        </div>
      </header>

      {/* Actions principales */}
      <LeadActionsBar
        leadId={l.id}
        currentStatus={l.status}
        isMine={isMine}
        isAssigned={!!l.assigned_to_admin_id}
        isSnoozed={!!isSnoozed}
        hasFollowup={!!l.next_followup_at}
      />

      <div className="grid lg:grid-cols-3 gap-6">
        {/* Colonne gauche : message + notes */}
        <div className="lg:col-span-2 space-y-6">
          {/* Message initial */}
          {l.message && (
            <Card>
              <CardBody>
                <h3 className="font-display font-semibold text-navy-900 mb-2 inline-flex items-center gap-2">
                  <Mail className="h-4 w-4 text-gold-700" />
                  Message initial
                </h3>
                <p className="text-sm text-navy-800 whitespace-pre-wrap leading-relaxed">
                  {l.message}
                </p>
                <p className="text-[11px] text-slate-500 mt-3">
                  Reçu le{" "}
                  {new Date(l.created_at).toLocaleDateString("fr-FR", {
                    day: "2-digit",
                    month: "long",
                    year: "numeric",
                    hour: "2-digit",
                    minute: "2-digit",
                  })}
                  {l.source && ` · Source : ${l.source}`}
                </p>
              </CardBody>
            </Card>
          )}

          {/* Formulaire ajouter une note */}
          {isMine && (
            <Card variant="gold">
              <CardBody>
                <h3 className="font-display font-semibold text-navy-900 mb-3">
                  Ajouter une note
                </h3>
                <NoteForm leadId={l.id} />
              </CardBody>
            </Card>
          )}

          {/* Liste des notes */}
          <section>
            <h2 className="font-display text-lg font-semibold text-navy-900 mb-3">
              Historique des échanges ({notes.length})
            </h2>
            {notes.length === 0 ? (
              <Card>
                <CardBody className="text-sm text-slate-500 text-center py-8">
                  Aucune note pour l'instant.
                </CardBody>
              </Card>
            ) : (
              <ul className="space-y-3">
                {notes.map((n) => (
                  <NoteItem key={n.id} note={n} />
                ))}
              </ul>
            )}
          </section>
        </div>

        {/* Colonne droite : sidebar */}
        <div className="space-y-6">
          {/* Tags */}
          <Card>
            <CardBody>
              <h3 className="font-display font-semibold text-navy-900 mb-3 inline-flex items-center gap-2">
                <TagIcon className="h-4 w-4 text-gold-700" />
                Tags
              </h3>
              <TagsEditor leadId={l.id} tags={l.tags ?? []} canEdit={isMine} />
            </CardBody>
          </Card>

          {/* Relance */}
          {l.next_followup_at && (
            <Card>
              <CardBody>
                <h3 className="font-display font-semibold text-navy-900 mb-3 inline-flex items-center gap-2">
                  <Calendar className="h-4 w-4 text-gold-700" />
                  Prochaine relance
                </h3>
                <p className="text-sm text-navy-900">
                  {new Date(l.next_followup_at).toLocaleDateString("fr-FR", {
                    weekday: "long",
                    day: "2-digit",
                    month: "long",
                    year: "numeric",
                    hour: "2-digit",
                    minute: "2-digit",
                  })}
                </p>
              </CardBody>
            </Card>
          )}

          {/* Détails techniques */}
          <Card>
            <CardBody>
              <h3 className="font-display font-semibold text-navy-900 mb-3 inline-flex items-center gap-2">
                <Building2 className="h-4 w-4 text-gold-700" />
                Détails
              </h3>
              <dl className="text-sm space-y-2">
                <Row label="Financement" value={l.funding_kind?.toUpperCase()} />
                <Row label="Source" value={l.source ?? "—"} />
                <Row
                  label="Reçu le"
                  value={new Date(l.created_at).toLocaleDateString("fr-FR", {
                    day: "2-digit",
                    month: "short",
                    year: "numeric",
                  })}
                />
                {l.updated_at && (
                  <Row
                    label="Mise à jour"
                    value={new Date(l.updated_at).toLocaleDateString("fr-FR", {
                      day: "2-digit",
                      month: "short",
                      year: "numeric",
                    })}
                  />
                )}
              </dl>
            </CardBody>
          </Card>

          {/* Timeline activités */}
          <section>
            <h2 className="font-display text-base font-semibold text-navy-900 mb-3">
              Historique automatique
            </h2>
            <LeadTimeline activities={activities} />
          </section>
        </div>
      </div>
    </div>
  );
}

function Row({ label, value }: { label: string; value: any }) {
  return (
    <div className="flex justify-between gap-3">
      <dt className="text-slate-500">{label}</dt>
      <dd className="text-navy-900 font-medium">{value ?? "—"}</dd>
    </div>
  );
}

function NoteItem({ note }: { note: any }) {
  const KIND_LABEL: Record<string, string> = {
    call: "Appel",
    email: "Email",
    sms: "SMS",
    meeting: "Rendez-vous",
    note: "Note",
  };
  const KIND_TONE: Record<string, "gold" | "navy" | "slate" | "success"> = {
    call: "gold",
    email: "navy",
    sms: "navy",
    meeting: "success",
    note: "slate",
  };
  return (
    <li>
      <Card>
        <CardBody className="space-y-2">
          <div className="flex items-center justify-between gap-2">
            <div className="flex items-center gap-2 flex-wrap">
              <Badge tone={KIND_TONE[note.kind] ?? "slate"} size="sm">
                {KIND_LABEL[note.kind] ?? note.kind}
              </Badge>
              <span className="text-xs text-slate-500">
                par{" "}
                {note.author?.full_name ??
                  note.author?.email?.split("@")[0] ??
                  "—"}
              </span>
            </div>
            <span className="text-[11px] text-slate-500">
              {new Date(note.occurred_at).toLocaleDateString("fr-FR", {
                day: "2-digit",
                month: "short",
                year: "numeric",
                hour: "2-digit",
                minute: "2-digit",
              })}
            </span>
          </div>
          <p className="text-sm text-navy-900 whitespace-pre-wrap leading-relaxed">
            {note.body}
          </p>
        </CardBody>
      </Card>
    </li>
  );
}
