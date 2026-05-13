import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
  FileSignature,
  CreditCard,
  CalendarCheck2,
  CheckCircle2,
  Clock,
  AlertCircle,
} from "lucide-react";
import { submitEnrollmentRequest } from "./actions";
import { findFormation } from "@/lib/formations-config";
import { listActivePackPrices } from "@/lib/pricing-server";
import { isPackSlug, type PackSlug } from "@/lib/packs";
import { PackPicker } from "./pack-picker";

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

const STATUS_LABEL: Record<string, string> = {
  prospect: "Demande reçue",
  devis: "Devis envoyé",
  accord_financeur: "Accord financeur reçu",
  a_payer: "Paiement à effectuer",
  en_cours: "Formation en cours",
  termine: "Formation terminée",
  abandon: "Dossier abandonné",
  refuse: "Demande refusée",
};

const FUNDING_LABEL: Record<string, string> = {
  opco: "OPCO",
  cpf: "CPF / Mon Compte Formation",
  employeur: "Employeur",
  pole_emploi: "France Travail (ex-Pôle Emploi)",
  auto: "Auto-financement",
  autre: "Autre",
};

function fmtEuros(cents: number) {
  return (cents / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
  });
}

export default async function InscriptionPage({
  searchParams,
}: {
  searchParams?: { formation?: string; financeur?: string; pack?: string };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // Pré-remplissage depuis ?formation=... (lien depuis le catalogue / home)
  const presetFormationSlug = (searchParams?.formation ?? "").trim();
  const presetFunding = (searchParams?.financeur ?? "").trim();
  const rawPack = (searchParams?.pack ?? "").trim();
  const presetPackSlug: PackSlug | undefined = isPackSlug(rawPack)
    ? rawPack
    : undefined;
  const presetFormation = presetFormationSlug
    ? findFormation(presetFormationSlug)
    : undefined;

  const [
    { data: profile },
    { data: enrollments },
    { data: req },
    activePrices,
  ] = await Promise.all([
    supabase.from("profiles").select("full_name, email").eq("id", user.id).single(),
    supabase
      .from("enrollments")
      .select(
        "*, funder:funders(name, kind), payments:payment_schedule(id, due_date, amount_cents, paid_amount_cents, paid_at, method, reference)"
      )
      .eq("user_id", user.id)
      .order("created_at", { ascending: false }),
    supabase
      .from("enrollment_requests")
      .select("*")
      .eq("user_id", user.id)
      .order("created_at", { ascending: false })
      .limit(1),
    listActivePackPrices(),
  ]);

  // Convertit en payload simple pour le client component
  const pricesForClient = activePrices.map((p) => ({
    formationSlug: p.formationSlug,
    pack: p.pack,
    priceCents: p.priceCents,
    compareAtCents: p.compareAtCents,
  }));

  const current = (enrollments ?? [])[0];
  const lastReq = (req ?? [])[0];

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">Mon dossier</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Inscription & financement
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl leading-relaxed">
          Suivez l'avancement de votre dossier, vos justificatifs et vos
          échéances en un seul endroit. Un conseiller dédié vous accompagne à
          chaque étape.
        </p>
      </header>

      {/* Dossier en cours */}
      {current ? (
        <section className="space-y-5">
          <Card>
            <CardBody>
              <div className="flex items-start justify-between gap-4 flex-wrap">
                <div>
                  <span className="eyebrow text-gold-700">Dossier</span>
                  <CardTitle className="mt-1">
                    {current.session_label ?? "Formation GOTRM"}
                  </CardTitle>
                  <p className="text-sm text-slate-600 mt-1">
                    Financement : <strong>{FUNDING_LABEL[current.funding_kind]}</strong>
                    {current.funder?.name && <> · {current.funder.name}</>}
                  </p>
                </div>
                <Badge tone={STATUS_TONE[current.status] ?? "slate"}>
                  {STATUS_LABEL[current.status] ?? current.status}
                </Badge>
              </div>

              <div className="mt-6 grid md:grid-cols-4 gap-4">
                <Info label="Début" value={current.start_date ?? "—"} icon={CalendarCheck2} />
                <Info label="Fin prévue" value={current.end_date ?? "—"} icon={CalendarCheck2} />
                <Info
                  label="Coût pédagogique"
                  value={fmtEuros(current.total_amount_cents ?? 0)}
                  icon={CreditCard}
                />
                <Info
                  label="Réglé"
                  value={fmtEuros(current.paid_amount_cents ?? 0)}
                  icon={CheckCircle2}
                />
              </div>

              <div className="mt-5 flex flex-wrap gap-2">
                <a
                  href={`/api/enrollments/${current.id}/devis`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 text-sm font-medium px-3 py-1.5 rounded-lg border border-navy-200 hover:bg-navy-50 text-navy-900"
                >
                  <FileSignature className="h-4 w-4" /> Devis (PDF)
                </a>
                <a
                  href={`/api/enrollments/${current.id}/convention`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 text-sm font-medium px-3 py-1.5 rounded-lg border border-navy-200 hover:bg-navy-50 text-navy-900"
                >
                  <FileSignature className="h-4 w-4" /> Convention (PDF)
                </a>
                {current.start_date && (
                  <a
                    href={`/api/enrollments/${current.id}/convocation`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-2 text-sm font-medium px-3 py-1.5 rounded-lg border border-navy-200 hover:bg-navy-50 text-navy-900"
                  >
                    <FileSignature className="h-4 w-4" /> Convocation (PDF)
                  </a>
                )}
              </div>

              {(current.contract_url || current.convention_url) && (
                <div className="mt-3 flex flex-wrap gap-2">
                  {current.contract_url && (
                    <a
                      href={current.contract_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-2 text-sm text-navy-900 hover:text-gold-700 font-medium"
                    >
                      <FileSignature className="h-4 w-4" /> Contrat de formation
                    </a>
                  )}
                  {current.convention_url && (
                    <a
                      href={current.convention_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-2 text-sm text-navy-900 hover:text-gold-700 font-medium"
                    >
                      <FileSignature className="h-4 w-4" /> Convention
                    </a>
                  )}
                </div>
              )}
            </CardBody>
          </Card>

          {/* Échéances */}
          {current.payments && current.payments.length > 0 && (
            <Card>
              <CardBody className="p-0">
                <div className="px-6 py-4 border-b border-navy-50">
                  <CardTitle className="text-base">Échéancier</CardTitle>
                </div>
                <table className="w-full text-sm">
                  <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                    <tr>
                      <th className="text-left px-6 py-3">Échéance</th>
                      <th className="text-left px-6 py-3">Montant</th>
                      <th className="text-left px-6 py-3">Statut</th>
                      <th className="text-left px-6 py-3">Méthode</th>
                    </tr>
                  </thead>
                  <tbody>
                    {[...current.payments]
                      .sort(
                        (a: any, b: any) =>
                          +new Date(a.due_date) - +new Date(b.due_date)
                      )
                      .map((p: any) => (
                        <tr key={p.id} className="border-t border-navy-50">
                          <td className="px-6 py-3">
                            {new Date(p.due_date).toLocaleDateString("fr-FR")}
                          </td>
                          <td className="px-6 py-3 font-medium text-navy-900">
                            {fmtEuros(p.amount_cents)}
                          </td>
                          <td className="px-6 py-3">
                            {p.paid_at ? (
                              <Badge tone="success" size="sm">
                                <CheckCircle2 className="h-3 w-3" /> Réglé
                              </Badge>
                            ) : new Date(p.due_date) < new Date() ? (
                              <Badge tone="rose" size="sm">
                                <AlertCircle className="h-3 w-3" /> En retard
                              </Badge>
                            ) : (
                              <Badge tone="gold" size="sm">
                                <Clock className="h-3 w-3" /> Attendu
                              </Badge>
                            )}
                          </td>
                          <td className="px-6 py-3 text-slate-600">
                            {p.method ?? "—"}
                          </td>
                        </tr>
                      ))}
                  </tbody>
                </table>
              </CardBody>
            </Card>
          )}
        </section>
      ) : (
        /* Pas de dossier : formulaire de demande + sélecteur de pack */
        <section>
          <Card>
            <CardBody>
              <CardTitle>Démarrer votre inscription</CardTitle>
              <p className="text-sm text-slate-600 mt-1.5 leading-relaxed">
                Choisissez votre pack, remplissez vos coordonnées en 2 minutes.
                Un conseiller vous rappelle sous{" "}
                <strong className="text-navy-900">48 h ouvrées</strong> pour
                constituer le dossier de financement adapté.
              </p>

              {lastReq && lastReq.status !== "refuse" && (
                <div className="mt-4 rounded-xl border border-gold-200 bg-gold-50 px-4 py-3 text-sm text-gold-900">
                  Votre demande du{" "}
                  {new Date(lastReq.created_at).toLocaleDateString("fr-FR")}{" "}
                  est au statut <strong>{lastReq.status}</strong>.
                </div>
              )}

              <form
                action={submitEnrollmentRequest}
                className="mt-7 space-y-8"
              >
                {/* ── 1. Pack picker ──────────────────────────────────── */}
                <div>
                  <div className="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500 mb-3">
                    1. Votre pack
                  </div>
                  <PackPicker
                    prices={pricesForClient}
                    defaultFormationSlug={presetFormation?.slug}
                    defaultPackSlug={presetPackSlug}
                  />
                </div>

                {/* ── 2. Coordonnées ──────────────────────────────────── */}
                <div>
                  <div className="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500 mb-3">
                    2. Vos coordonnées
                  </div>
                  <div className="grid md:grid-cols-2 gap-4">
                    <div>
                      <Label htmlFor="full_name">Nom complet</Label>
                      <Input
                        id="full_name"
                        name="full_name"
                        defaultValue={profile?.full_name ?? ""}
                        required
                      />
                    </div>
                    <div>
                      <Label htmlFor="email">Email</Label>
                      <Input
                        id="email"
                        name="email"
                        type="email"
                        defaultValue={profile?.email ?? user.email ?? ""}
                        required
                      />
                    </div>
                    <div>
                      <Label htmlFor="phone">Téléphone</Label>
                      <Input id="phone" name="phone" type="tel" />
                    </div>
                    <div>
                      <Label htmlFor="funding_kind">
                        Financement souhaité
                      </Label>
                      <select
                        id="funding_kind"
                        name="funding_kind"
                        defaultValue={presetFunding || "auto"}
                        className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900"
                      >
                        {Object.entries(FUNDING_LABEL).map(([v, l]) => (
                          <option key={v} value={v}>
                            {l}
                          </option>
                        ))}
                      </select>
                    </div>
                    <div className="md:col-span-2">
                      <Label htmlFor="message">
                        Votre projet en quelques lignes (optionnel)
                      </Label>
                      <Textarea
                        id="message"
                        name="message"
                        rows={4}
                        placeholder="Métier visé, calendrier souhaité, employeur actuel… Tout ce qui nous aidera à mieux vous accompagner."
                      />
                    </div>
                  </div>
                </div>

                {/* ── 3. Soumettre ────────────────────────────────────── */}
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 pt-2 border-t border-navy-50">
                  <p className="text-xs text-slate-500 leading-relaxed max-w-md">
                    Vos données sont utilisées pour traiter votre demande
                    uniquement. Aucun engagement à ce stade.
                  </p>
                  <Button
                    type="submit"
                    variant="gold"
                    className="w-full sm:w-auto justify-center"
                  >
                    Envoyer ma demande
                  </Button>
                </div>
              </form>
            </CardBody>
          </Card>
        </section>
      )}
    </div>
  );
}

function Info({
  label,
  value,
  icon: Icon,
}: {
  label: string;
  value: any;
  icon: any;
}) {
  return (
    <div className="rounded-xl border border-navy-100 bg-ivory p-4">
      <div className="flex items-center gap-2 text-[11px] uppercase tracking-wider text-slate-500">
        <Icon className="h-3.5 w-3.5" /> {label}
      </div>
      <div className="mt-1 font-display text-lg font-semibold text-navy-900">
        {value}
      </div>
    </div>
  );
}
