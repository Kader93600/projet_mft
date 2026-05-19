import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Mail,
  Phone,
  Building2,
  UserCheck,
  FileText,
  UserPlus,
  Ban,
  Trash2,
  Download,
  Clock,
  MessageSquare,
  GraduationCap,
} from "lucide-react";
import { findFormation } from "@/lib/formations-config";
import {
  deleteFunder,
  deleteEnrollment,
  setRequestStatus,
  deleteEnrollmentRequest,
  setEnrollmentStatus,
} from "./actions";
import { Pencil, Trophy } from "lucide-react";
import { ConfirmAction } from "@/components/ui/confirm-action";

const REQUEST_STATUS_TONE: Record<string, "slate" | "navy" | "gold" | "success" | "rose"> = {
  nouveau: "slate",
  contacte: "navy",
  devis_envoye: "gold",
  inscrit: "success",
  refuse: "rose",
};
const REQUEST_STATUS_LABEL: Record<string, string> = {
  nouveau: "Nouveau",
  contacte: "Contacté",
  devis_envoye: "Devis envoyé",
  inscrit: "Inscrit",
  refuse: "Refusé",
};

export const dynamic = "force-dynamic";

const STATUS_TONE: Record<string, "gold" | "navy" | "success" | "slate" | "rose"> = {
  prospect: "slate",
  devis: "gold",
  accord_financeur: "gold",
  a_payer: "gold",
  en_cours: "navy",
  termine: "success",
  abandon: "slate",
  refuse: "rose",
};

function fmtEuros(cents: number) {
  return (cents / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
  });
}

/**
 * Extrait le slug de la formation visée :
 * 1) prioritairement `formation_slug` (rempli quand le lead choisit
 *    explicitement une formation depuis la page tarifs/inscription)
 * 2) sinon parse le message libre, qui contient souvent
 *    "Formation visée : <slug>" généré par le formulaire de contact.
 */
function extractFormationSlug(req: any): string | null {
  if (req.formation_slug) return req.formation_slug as string;
  const m = (req.message as string | null)?.match(
    /Formation\s+vis[ée]e\s*:\s*([a-z0-9-]+)/i,
  );
  return m ? m[1].toLowerCase() : null;
}

/** "aujourd'hui" / "hier" / "il y a Nj" */
function relativeAge(iso: string): string {
  const days = Math.floor(
    (Date.now() - new Date(iso).getTime()) / 86_400_000,
  );
  if (days <= 0) return "aujourd'hui";
  if (days === 1) return "hier";
  if (days < 7) return `il y a ${days}j`;
  if (days < 30) return `il y a ${Math.floor(days / 7)}sem`;
  return `il y a ${Math.floor(days / 30)}mois`;
}

/** "17 mai · 10:50" */
function fmtDateTime(iso: string): string {
  const d = new Date(iso);
  return `${d.toLocaleDateString("fr-FR", { day: "numeric", month: "short" })} · ${d.toLocaleTimeString("fr-FR", { hour: "2-digit", minute: "2-digit" })}`;
}

const FUNDING_LABEL: Record<string, string> = {
  auto: "Auto",
  cpf: "CPF",
  opco: "OPCO",
  france_travail: "France Travail",
  employeur: "Employeur",
  autre: "Autre",
};

const FUNDING_TONE: Record<string, "slate" | "navy" | "gold" | "success"> = {
  auto: "slate",
  cpf: "navy",
  opco: "gold",
  france_travail: "success",
  employeur: "navy",
};

export default async function AdminEnrollmentsPage() {
  // Le middleware admin a déjà vérifié les permissions avant d'entrer
  // ici. On utilise le client service_role pour bypass total des RLS :
  // certaines policies obscures (org_admin avec organization_id NULL,
  // funder cross-check, etc.) peuvent empêcher un super_admin de voir
  // l'intégralité des enrollments via le client server classique.
  const supabase = createClient(); // session admin pour mutations
  const admin = createAdminClient(); // service_role pour lectures

  const [
    { data: enrollments },
    { data: funders },
    { data: overview },
    { data: requests },
  ] = await Promise.all([
    admin
      .from("enrollments")
      .select(
        "*, user:profiles!user_id(full_name, email), funder:funders(name, kind)"
      )
      .order("created_at", { ascending: false }),
    admin.from("funders").select("*").order("name"),
    admin.from("funder_overview").select("*"),
    admin
      .from("enrollment_requests")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(30),
  ]);
  // Note : supabase (session) reste utilisé implicitement par les
  // server actions appelées depuis les boutons de cette page.
  void supabase;

  const openReq = (requests ?? []).filter(
    (r: any) => !["inscrit", "refuse"].includes(r.status)
  );

  const totals = (enrollments ?? []).reduce(
    (acc: any, e: any) => {
      acc.total += e.total_amount_cents ?? 0;
      acc.paid += e.paid_amount_cents ?? 0;
      return acc;
    },
    { total: 0, paid: 0 }
  );

  return (
    <div className="space-y-10">
      <header className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700">Administration</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
            Inscriptions, financeurs & paiements
          </h1>
          <p className="mt-2 text-sm text-slate-600 max-w-2xl">
            Vue commerciale : leads, dossiers, paiements. Pour inscrire
            un nouveau client de A à Z (compte + dossier), cliquez sur{" "}
            <strong>+ Nouveau stagiaire</strong>.
          </p>
        </div>
        <div className="flex items-center gap-2 shrink-0">
          <Link href="/admin/users/new">
            <Button variant="gold">
              <UserPlus className="h-4 w-4" />+ Nouveau stagiaire
            </Button>
          </Link>
        </div>
      </header>

      {/* KPIs */}
      <section className="grid md:grid-cols-4 gap-4">
        <Kpi label="Dossiers actifs" value={(enrollments ?? []).filter((e: any) => e.status === "en_cours").length} />
        <Kpi label="Demandes à traiter" value={openReq.length} />
        <Kpi label="Budget engagé" value={fmtEuros(totals.total)} />
        <Kpi label="Encaissé" value={fmtEuros(totals.paid)} accent />
      </section>

      {/* Demandes d'inscription */}
      {openReq.length > 0 && (
        <section>
          <div className="flex items-center justify-between mb-3 gap-3">
            <h2 className="eyebrow text-gold-700">Leads à contacter</h2>
            <a
              href="/api/admin/export/leads"
              className="inline-flex items-center gap-2 h-8 px-3 rounded-lg border border-navy-200 bg-white text-xs text-navy-800 hover:bg-navy-50 transition"
              title="Télécharger un CSV de tous les leads"
            >
              <Download className="h-3.5 w-3.5" /> CSV
            </a>
          </div>
          <Card>
            <CardBody className="p-0 overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                  <tr>
                    <th className="text-left px-4 py-3">Contact</th>
                    <th className="hidden md:table-cell text-left px-4 py-3">Formation &amp; pack</th>
                    <th className="hidden md:table-cell text-left px-4 py-3">Financement</th>
                    <th className="hidden xl:table-cell text-left px-4 py-3">Message</th>
                    <th className="hidden sm:table-cell text-left px-4 py-3">Statut</th>
                    <th className="hidden lg:table-cell text-left px-4 py-3">Reçue</th>
                    <th className="text-right px-4 py-3 whitespace-nowrap">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {openReq.map((r: any) => {
                    const fSlug = extractFormationSlug(r);
                    const formation = fSlug ? findFormation(fSlug) : null;
                    const message =
                      typeof r.message === "string" ? r.message.trim() : "";
                    // Le formulaire de contact préfixe parfois le message
                    // par "Formation visée : X" — on retire ce préfixe pour
                    // ne garder que le contenu utile dans la cellule message.
                    const cleanMessage = message
                      .replace(
                        /Formation\s+vis[ée]e\s*:\s*[a-z0-9-]+\s*\.?\s*/i,
                        "",
                      )
                      .trim();
                    return (
                      <tr key={r.id} className="border-t border-navy-50">
                        <td className="px-4 py-3 align-top">
                          <div className="font-medium text-navy-900">
                            {r.full_name}
                          </div>
                          <div className="mt-1 text-xs text-slate-500 flex items-center gap-2 flex-wrap">
                            <a
                              href={`mailto:${r.email}`}
                              className="inline-flex items-center gap-1 hover:text-navy-900"
                            >
                              <Mail className="h-3 w-3" />
                              {r.email}
                            </a>
                            {r.phone && (
                              <a
                                href={`tel:${r.phone}`}
                                className="inline-flex items-center gap-1 hover:text-navy-900"
                              >
                                <Phone className="h-3 w-3" />
                                {r.phone}
                              </a>
                            )}
                          </div>
                        </td>
                        <td className="hidden md:table-cell px-4 py-3 align-top">
                          <div className="flex flex-col gap-1">
                            {formation ? (
                              <span
                                className="inline-flex items-center gap-1.5 self-start rounded-md border px-1.5 py-0.5 text-[11px] font-semibold uppercase tracking-wider"
                                style={{
                                  backgroundColor: `${formation.accent}15`,
                                  borderColor: `${formation.accent}55`,
                                  color: formation.accent,
                                }}
                                title={formation.title}
                              >
                                <GraduationCap className="h-3 w-3" />
                                {formation.code}
                              </span>
                            ) : (
                              <span className="text-xs text-slate-400 italic">
                                non précisée
                              </span>
                            )}
                            {r.pack_slug && (
                              <PackChip pack={r.pack_slug} />
                            )}
                          </div>
                        </td>
                        <td className="hidden md:table-cell px-4 py-3 align-top">
                          <Badge
                            tone={FUNDING_TONE[r.funding_kind] ?? "slate"}
                            size="sm"
                          >
                            {FUNDING_LABEL[r.funding_kind] ??
                              String(r.funding_kind).replace("_", " ")}
                          </Badge>
                        </td>
                        <td className="hidden xl:table-cell px-4 py-3 align-top max-w-[260px]">
                          {cleanMessage ? (
                            <div
                              className="text-xs text-slate-700 leading-snug line-clamp-3"
                              title={cleanMessage}
                            >
                              <MessageSquare className="inline h-3 w-3 mr-1 -mt-0.5 text-slate-400" />
                              {cleanMessage}
                            </div>
                          ) : (
                            <span className="text-xs text-slate-400 italic">
                              —
                            </span>
                          )}
                        </td>
                        <td className="hidden sm:table-cell px-4 py-3 align-top">
                          <Badge
                            tone={REQUEST_STATUS_TONE[r.status] ?? "slate"}
                            size="sm"
                          >
                            {REQUEST_STATUS_LABEL[r.status] ?? r.status}
                          </Badge>
                        </td>
                        <td
                          className="hidden lg:table-cell px-4 py-3 align-top whitespace-nowrap"
                          title={new Date(r.created_at).toLocaleString(
                            "fr-FR",
                          )}
                        >
                          <div className="text-xs text-slate-700">
                            {fmtDateTime(r.created_at)}
                          </div>
                          <div className="text-[11px] text-slate-500 inline-flex items-center gap-1 mt-0.5">
                            <Clock className="h-3 w-3" />
                            {relativeAge(r.created_at)}
                          </div>
                        </td>
                        <td className="px-4 py-3 align-top">
                          <LeadActions request={r} />
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </CardBody>
          </Card>
        </section>
      )}

      {/* Enrollments */}
      <section>
        <div className="flex items-center justify-between mb-4">
          <h2 className="eyebrow text-gold-700">Dossiers</h2>
          <Link href="/admin/enrollments/new">
            <Button size="sm">+ Nouveau dossier</Button>
          </Link>
        </div>
        <Card>
          <CardBody className="p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                <tr>
                  <th className="text-left px-4 py-3">Stagiaire</th>
                  <th className="hidden md:table-cell text-left px-4 py-3">Financeur</th>
                  <th className="hidden xl:table-cell text-left px-4 py-3">Session</th>
                  <th className="hidden lg:table-cell text-right px-4 py-3">Montant</th>
                  <th className="hidden lg:table-cell text-right px-4 py-3">Payé</th>
                  <th className="hidden sm:table-cell text-left px-4 py-3">Statut</th>
                  <th className="text-right px-4 py-3 whitespace-nowrap">Actions</th>
                </tr>
              </thead>
              <tbody>
                {(enrollments ?? []).map((e: any) => (
                  <tr key={e.id} className="border-t border-navy-50">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2 flex-wrap">
                        <span className="font-medium text-navy-900">
                          {e.user?.full_name ?? e.user?.email}
                        </span>
                        <PackChip pack={e.pack ?? "initial"} />
                      </div>
                      <div className="text-xs text-slate-500">{e.user?.email}</div>
                    </td>
                    <td className="hidden md:table-cell px-4 py-3 text-slate-700">
                      {e.funder?.name ?? e.funding_kind}
                    </td>
                    <td className="hidden xl:table-cell px-4 py-3 text-slate-600">
                      {e.session_label ?? "—"}
                      <div className="text-xs text-slate-400">
                        {e.start_date ?? "—"} → {e.end_date ?? "—"}
                      </div>
                    </td>
                    <td className="hidden lg:table-cell px-4 py-3 text-right font-medium">
                      {fmtEuros(e.total_amount_cents)}
                    </td>
                    <td className="hidden lg:table-cell px-4 py-3 text-right">
                      {fmtEuros(e.paid_amount_cents)}
                    </td>
                    <td className="hidden sm:table-cell px-4 py-3">
                      <Badge tone={STATUS_TONE[e.status] ?? "slate"} size="sm">
                        {e.status}
                      </Badge>
                    </td>
                    <td className="px-4 py-3">
                      <EnrollmentActions enrollment={e} />
                    </td>
                  </tr>
                ))}
                {(!enrollments || enrollments.length === 0) && (
                  <tr>
                    <td colSpan={7} className="px-4 py-6 text-sm text-slate-500">
                      Aucun dossier enregistré.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </CardBody>
        </Card>
      </section>

      {/* Funders */}
      <section>
        <div className="flex items-center justify-between mb-4">
          <h2 className="eyebrow text-gold-700">Financeurs</h2>
          <Link href="/admin/enrollments/funders/new">
            <Button size="sm">+ Nouveau financeur</Button>
          </Link>
        </div>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          {(funders ?? []).map((f: any) => {
            const ov = (overview ?? []).find((o: any) => o.funder_id === f.id);
            return (
              <Card key={f.id}>
                <CardBody>
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-center gap-2">
                      <Building2 className="h-4 w-4 text-gold-600" />
                      <CardTitle className="text-base">{f.name}</CardTitle>
                    </div>
                    <Badge size="sm">{f.kind}</Badge>
                  </div>
                  {f.contact_email && (
                    <p className="text-xs text-slate-600 mt-2 truncate">
                      {f.contact_email}
                    </p>
                  )}
                  <div className="mt-4 grid grid-cols-2 gap-3 text-xs">
                    <div>
                      <div className="text-slate-500">Dossiers</div>
                      <div className="font-semibold text-navy-900">
                        {ov?.enrollments_total ?? 0}
                      </div>
                    </div>
                    <div>
                      <div className="text-slate-500">Budget</div>
                      <div className="font-semibold text-navy-900">
                        {fmtEuros(ov?.budget_total_cents ?? 0)}
                      </div>
                    </div>
                  </div>
                  <div className="mt-4 flex items-center justify-end gap-1">
                    {f.contact_email && (
                      <a
                        href={`mailto:${f.contact_email}`}
                        title={`Email — ${f.contact_email}`}
                        aria-label={`Email — ${f.contact_email}`}
                        className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-navy-200 text-navy-800 hover:bg-navy-50 transition"
                      >
                        <Mail className="h-3.5 w-3.5" />
                      </a>
                    )}
                    {f.contact_phone && (
                      <a
                        href={`tel:${f.contact_phone}`}
                        title={`Appeler — ${f.contact_phone}`}
                        aria-label={`Appeler — ${f.contact_phone}`}
                        className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-navy-200 text-navy-800 hover:bg-navy-50 transition"
                      >
                        <Phone className="h-3.5 w-3.5" />
                      </a>
                    )}
                    <Link
                      href={`/admin/enrollments/funders/${f.id}`}
                      title="Modifier"
                      aria-label="Modifier le financeur"
                      className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-gold-200 text-gold-800 hover:bg-gold-50 transition"
                    >
                      <Pencil className="h-3.5 w-3.5" />
                    </Link>
                    <ConfirmAction
                      action={deleteFunder.bind(null, f.id)}
                      title="Supprimer ce financeur ?"
                      description={`Supprime « ${f.name} ». Les dossiers existants rattachés à ce financeur seront détachés (pas supprimés).`}
                      confirmLabel="Supprimer"
                      successMsg="Financeur supprimé"
                      iconLabel="Supprimer le financeur"
                      icon={<Trash2 className="h-3.5 w-3.5" />}
                      tone="rose"
                      variant="solid"
                    />
                  </div>
                </CardBody>
              </Card>
            );
          })}
        </div>
      </section>
    </div>
  );
}

function LeadActions({ request: r }: { request: any }) {
  const isNouveau = r.status === "nouveau";
  const isContacte = r.status === "contacte";
  // URL "Convertir en stagiaire" — pré-remplit le formulaire complet
  // (compte auth + profil + dossier d'inscription) avec les infos du lead.
  // À la création réussie, le lead est auto-marqué "inscrit" côté action
  // server (cf. createStudent dans app/admin/users/actions.ts).
  const formationSlug = extractFormationSlug(r);
  const convertUrl =
    `/admin/users/new` +
    `?email=${encodeURIComponent(r.email ?? "")}` +
    `&full_name=${encodeURIComponent(r.full_name ?? "")}` +
    `&phone=${encodeURIComponent(r.phone ?? "")}` +
    (formationSlug
      ? `&formation_slug=${encodeURIComponent(formationSlug)}`
      : "") +
    (r.funding_kind
      ? `&funding_kind=${encodeURIComponent(r.funding_kind)}`
      : "");

  return (
    <div className="flex items-center justify-end gap-1">
      {/* Avancer dans le pipeline : nouveau → contacté */}
      {isNouveau && (
        <form action={setRequestStatus.bind(null, r.id, "contacte")}>
          <ActionBtn
            title="Marquer comme contacté"
            tone="navy"
            type="submit"
          >
            <UserCheck className="h-3.5 w-3.5" />
          </ActionBtn>
        </form>
      )}

      {/* contacté → devis envoyé */}
      {isContacte && (
        <form action={setRequestStatus.bind(null, r.id, "devis_envoye")}>
          <ActionBtn title="Devis envoyé" tone="navy" type="submit">
            <FileText className="h-3.5 w-3.5" />
          </ActionBtn>
        </form>
      )}

      {/* Convertir en stagiaire (compte + dossier en une fois) */}
      <Link
        href={convertUrl}
        title="Convertir en stagiaire (créer compte + dossier)"
        aria-label="Convertir en stagiaire"
        className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-signal-300 bg-signal-50 text-signal-800 hover:bg-signal-100 transition"
      >
        <UserPlus className="h-3.5 w-3.5" />
      </Link>

      {/* Refuser */}
      <form action={setRequestStatus.bind(null, r.id, "refuse")}>
        <ActionBtn title="Refuser ce lead" tone="rose" type="submit">
          <Ban className="h-3.5 w-3.5" />
        </ActionBtn>
      </form>

      {/* Supprimer définitivement */}
      <ConfirmAction
        action={deleteEnrollmentRequest.bind(null, r.id)}
        title="Supprimer ce lead ?"
        description={`Supprime définitivement la demande de ${r.full_name} (${r.email}).`}
        confirmLabel="Supprimer"
        successMsg="Lead supprimé"
        iconLabel="Supprimer définitivement"
        icon={<Trash2 className="h-3.5 w-3.5" />}
        tone="rose"
        variant="solid"
      />
    </div>
  );
}

function EnrollmentActions({ enrollment: e }: { enrollment: any }) {
  const closed = ["termine", "abandon", "refuse"].includes(e.status);
  const inProgress = e.status === "en_cours";
  const userEmail = e.user?.email as string | undefined;

  return (
    <div className="flex items-center justify-end gap-1">
      {/* Contact email */}
      {userEmail && (
        <a
          href={`mailto:${userEmail}`}
          title={`Email — ${userEmail}`}
          aria-label={`Email — ${userEmail}`}
          className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-navy-200 text-navy-800 hover:bg-navy-50 transition"
        >
          <Mail className="h-3.5 w-3.5" />
        </a>
      )}

      {/* Gérer (détail / édition) — action primaire */}
      <Link
        href={`/admin/enrollments/${e.id}`}
        title="Gérer le dossier"
        aria-label="Gérer le dossier"
        className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-gold-200 text-gold-800 hover:bg-gold-50 transition"
      >
        <Pencil className="h-3.5 w-3.5" />
      </Link>

      {/* Marquer terminé : uniquement si en cours */}
      {inProgress && (
        <form action={setEnrollmentStatus.bind(null, e.id, "termine")}>
          <ActionBtn
            title="Marquer comme terminé"
            tone="navy"
            type="submit"
          >
            <Trophy className="h-3.5 w-3.5" />
          </ActionBtn>
        </form>
      )}

      {/* Marquer abandon : tant que pas clôturé */}
      {!closed && (
        <form action={setEnrollmentStatus.bind(null, e.id, "abandon")}>
          <ActionBtn title="Marquer abandon" tone="rose" type="submit">
            <Ban className="h-3.5 w-3.5" />
          </ActionBtn>
        </form>
      )}

      {/* Suppression définitive */}
      <ConfirmAction
        action={deleteEnrollment.bind(null, e.id)}
        title="Supprimer ce dossier ?"
        description={`Supprime définitivement le dossier de ${
          e.user?.full_name ?? e.user?.email ?? "ce stagiaire"
        }. Toutes les informations financières et historiques liées seront perdues.`}
        confirmLabel="Supprimer"
        successMsg="Dossier supprimé"
        iconLabel="Supprimer définitivement"
        icon={<Trash2 className="h-3.5 w-3.5" />}
        tone="rose"
        variant="solid"
      />
    </div>
  );
}

function ActionBtn({
  children,
  title,
  tone = "navy",
  type,
  variant = "soft",
}: {
  children: React.ReactNode;
  title: string;
  tone?: "navy" | "gold" | "rose";
  type?: "button" | "submit";
  variant?: "soft" | "solid";
}) {
  const palette: Record<string, string> = {
    navy:
      variant === "solid"
        ? "bg-navy-900 text-white hover:bg-navy-800"
        : "border-navy-200 text-navy-800 hover:bg-navy-50",
    gold:
      variant === "solid"
        ? "bg-gold-600 text-white hover:bg-gold-700"
        : "border-gold-200 text-gold-800 hover:bg-gold-50",
    rose:
      variant === "solid"
        ? "bg-rose-600 text-white hover:bg-rose-700"
        : "border-rose-200 text-rose-700 hover:bg-rose-50",
  };
  return (
    <button
      type={type ?? "button"}
      title={title}
      aria-label={title}
      className={`inline-flex h-7 w-7 items-center justify-center rounded-lg border transition ${
        variant === "solid" ? "border-transparent" : ""
      } ${palette[tone]}`}
    >
      {children}
    </button>
  );
}

function Kpi({
  label,
  value,
  accent,
}: {
  label: string;
  value: any;
  accent?: boolean;
}) {
  return (
    <div
      className={`rounded-2xl border p-5 ${
        accent
          ? "bg-gold-50 border-gold-200"
          : "bg-white border-navy-100"
      }`}
    >
      <div className="text-xs uppercase tracking-wider text-slate-500">{label}</div>
      <div className="mt-1 font-display text-2xl font-semibold text-navy-900">
        {value}
      </div>
    </div>
  );
}

/**
 * Petit badge "pack" affiché à côté du nom du stagiaire — repérage visuel
 * rapide depuis la liste admin.
 */
function PackChip({ pack }: { pack: "initial" | "medium" | "premium" }) {
  const styles: Record<typeof pack, { bg: string; fg: string; label: string }> = {
    initial: {
      bg: "bg-signal-100/60 border-signal-300",
      fg: "text-signal-800",
      label: "Initial",
    },
    medium: {
      bg: "bg-brand-50 border-brand-200",
      fg: "text-brand-700",
      label: "Medium",
    },
    premium: {
      bg: "bg-amber-50 border-amber-200",
      fg: "text-amber-700",
      label: "Premium",
    },
  };
  const s = styles[pack];
  return (
    <span
      className={`inline-flex items-center px-1.5 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-[0.10em] border ${s.bg} ${s.fg}`}
      title={`Pack ${s.label}`}
    >
      {s.label}
    </span>
  );
}
