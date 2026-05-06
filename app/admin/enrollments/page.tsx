import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
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
} from "lucide-react";
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

export default async function AdminEnrollmentsPage() {
  const supabase = createClient();
  const [
    { data: enrollments },
    { data: funders },
    { data: overview },
    { data: requests },
  ] = await Promise.all([
    supabase
      .from("enrollments")
      .select(
        "*, user:profiles!enrollments_user_id_fkey(full_name, email), funder:funders(name, kind)"
      )
      .order("created_at", { ascending: false }),
    supabase.from("funders").select("*").order("name"),
    supabase.from("funder_overview").select("*"),
    supabase
      .from("enrollment_requests")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(30),
  ]);

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
      <header>
        <span className="eyebrow text-gold-700">Administration</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
          Inscriptions, financeurs & paiements
        </h1>
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
                    <th className="hidden md:table-cell text-left px-4 py-3">Financement</th>
                    <th className="hidden sm:table-cell text-left px-4 py-3">Statut</th>
                    <th className="hidden lg:table-cell text-left px-4 py-3">Reçue le</th>
                    <th className="text-right px-4 py-3 whitespace-nowrap">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {openReq.map((r: any) => (
                    <tr key={r.id} className="border-t border-navy-50">
                      <td className="px-4 py-3">
                        <div className="font-medium text-navy-900">{r.full_name}</div>
                        <div className="text-xs text-slate-500 flex items-center gap-2 flex-wrap">
                          <Mail className="h-3 w-3" />
                          <a href={`mailto:${r.email}`} className="hover:text-navy-900">
                            {r.email}
                          </a>
                          {r.phone && (
                            <>
                              <Phone className="h-3 w-3 ml-2" />
                              <a
                                href={`tel:${r.phone}`}
                                className="hover:text-navy-900"
                              >
                                {r.phone}
                              </a>
                            </>
                          )}
                        </div>
                      </td>
                      <td className="hidden md:table-cell px-4 py-3 capitalize text-slate-700">
                        {String(r.funding_kind).replace("_", " ")}
                      </td>
                      <td className="hidden sm:table-cell px-4 py-3">
                        <Badge tone={REQUEST_STATUS_TONE[r.status] ?? "slate"} size="sm">
                          {REQUEST_STATUS_LABEL[r.status] ?? r.status}
                        </Badge>
                      </td>
                      <td className="hidden lg:table-cell px-4 py-3 text-slate-500 whitespace-nowrap">
                        {new Date(r.created_at).toLocaleDateString("fr-FR")}
                      </td>
                      <td className="px-4 py-3">
                        <LeadActions request={r} />
                      </td>
                    </tr>
                  ))}
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
                      <div className="font-medium text-navy-900">
                        {e.user?.full_name ?? e.user?.email}
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
  // Construit l'URL "Créer dossier" en pré-remplissant nom/email
  const newEnrollmentUrl = `/admin/enrollments/new?email=${encodeURIComponent(
    r.email
  )}&name=${encodeURIComponent(r.full_name)}`;

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

      {/* Convertir en dossier (toujours dispo) */}
      <Link
        href={newEnrollmentUrl}
        title="Créer un dossier d'inscription"
        aria-label="Créer un dossier d'inscription"
        className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-gold-200 text-gold-800 hover:bg-gold-50 transition"
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
