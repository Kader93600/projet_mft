import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import {
  ArrowLeft,
  CheckCircle2,
  ShieldCheck,
  PenLine,
  FileSignature,
} from "lucide-react";
import { signEnrollment } from "./actions";

export const dynamic = "force-dynamic";

function fmtEuros(cents: number) {
  return (cents / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
  });
}

const STATUS_LABEL: Record<string, string> = {
  prospect: "Prospect",
  devis: "Devis envoyé",
  accord_financeur: "Accord financeur",
  a_payer: "À régler",
  en_cours: "Formation en cours",
  termine: "Terminée",
};

export default async function FinanceurEnrollmentPage(
  props: {
    params: Promise<{ id: string }>;
  }
) {
  const params = await props.params;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: e } = await supabase
    .from("enrollments")
    .select(
      "*, user:profiles!user_id(full_name, email), funder:funders(name, kind)"
    )
    .eq("id", params.id)
    .maybeSingle();
  if (!e) notFound();

  const signed = !!e.funder_signed_at;

  return (
    <div className="space-y-8 max-w-3xl">
      <Link
        href="/financeur"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Retour aux dossiers
      </Link>

      <header>
        <span className="eyebrow text-gold-700">Dossier</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
          {e.user?.full_name ?? e.user?.email}
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          {e.session_label ?? "Formation GOTRM"} · {e.funder?.name}
        </p>
      </header>

      <Card>
        <CardBody className="grid sm:grid-cols-3 gap-6">
          <Field label="Statut" value={STATUS_LABEL[e.status] ?? e.status} />
          <Field
            label="Coût pédagogique"
            value={fmtEuros(e.total_amount_cents ?? 0)}
          />
          <Field label="Réglé" value={fmtEuros(e.paid_amount_cents ?? 0)} />
          <Field label="Début" value={e.start_date ?? "—"} />
          <Field label="Fin prévue" value={e.end_date ?? "—"} />
          <Field
            label="Heures"
            value={
              e.hours_total ? `${e.hours_total} h` : "—"
            }
          />
        </CardBody>
      </Card>

      {/* Signature */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-3 flex items-center gap-2">
          <FileSignature className="h-5 w-5 text-gold-700" />
          Convention de financement
        </h2>

        {signed ? (
          <Card variant="gold">
            <CardBody>
              <div className="flex items-start gap-3">
                <div className="h-10 w-10 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
                  <CheckCircle2 className="h-5 w-5" />
                </div>
                <div className="flex-1">
                  <CardTitle>Signée</CardTitle>
                  <div className="text-sm text-slate-700 mt-1">
                    Par <strong>{e.funder_signed_by_name}</strong>
                    {e.funder_signed_by_email && (
                      <> · {e.funder_signed_by_email}</>
                    )}
                  </div>
                  <div className="text-xs text-slate-500 mt-1">
                    Le{" "}
                    {new Date(e.funder_signed_at).toLocaleString("fr-FR", {
                      dateStyle: "long",
                      timeStyle: "short",
                    })}
                    {e.funder_signature_ip && (
                      <> · IP {e.funder_signature_ip}</>
                    )}
                  </div>
                  {e.funder_signature_hash && (
                    <details className="mt-3 text-xs">
                      <summary className="cursor-pointer text-slate-500">
                        Empreinte de preuve (SHA-256)
                      </summary>
                      <code className="mt-1 block text-[10px] break-all text-slate-700 bg-white p-2 rounded-lg border border-navy-100">
                        {e.funder_signature_hash}
                      </code>
                    </details>
                  )}
                </div>
              </div>
            </CardBody>
          </Card>
        ) : (
          <Card>
            <CardBody>
              <p className="text-sm text-slate-600 mb-4">
                En signant, vous reconnaissez avoir pris connaissance des
                conditions du financement (montant, dates, stagiaire) et
                autorisez l'exécution de la formation. La signature électronique
                horodatée tient lieu d'accord ferme.
              </p>
              <form
                action={async (fd) => {
                  "use server";
                  await signEnrollment(params.id, fd);
                }}
                className="space-y-4"
              >
                <div>
                  <Label htmlFor="name">Nom du signataire</Label>
                  <Input
                    id="name"
                    name="name"
                    required
                    placeholder="Prénom Nom"
                    autoComplete="name"
                  />
                </div>
                <div>
                  <Label htmlFor="email">E-mail (optionnel)</Label>
                  <Input
                    id="email"
                    name="email"
                    type="email"
                    placeholder="signataire@opco.fr"
                    autoComplete="email"
                  />
                </div>
                <label className="flex items-start gap-3 text-sm text-slate-700 cursor-pointer">
                  <input
                    type="checkbox"
                    name="ack"
                    required
                    className="mt-0.5 h-4 w-4 rounded border-navy-300"
                  />
                  <span>
                    Je certifie avoir lu et approuvé les conditions du dossier
                    de financement n° {params.id.slice(0, 8)} pour un montant
                    de {fmtEuros(e.total_amount_cents ?? 0)}.
                  </span>
                </label>
                <div className="flex justify-end">
                  <Button type="submit" variant="gold">
                    <PenLine className="h-4 w-4" /> Signer électroniquement
                  </Button>
                </div>
              </form>
              <div className="mt-4 text-xs text-slate-500 flex items-start gap-2">
                <ShieldCheck className="h-3.5 w-3.5 mt-0.5 shrink-0" />
                <span>
                  Signature horodatée et IP-traçée (eIDAS niveau 1). Une
                  empreinte SHA-256 du dossier est stockée pour preuve.
                </span>
              </div>
            </CardBody>
          </Card>
        )}
      </section>
    </div>
  );
}

function Field({ label, value }: { label: string; value: any }) {
  return (
    <div>
      <div className="text-[11px] uppercase tracking-wider text-slate-500">
        {label}
      </div>
      <div className="mt-0.5 font-medium text-navy-900">{value}</div>
    </div>
  );
}
