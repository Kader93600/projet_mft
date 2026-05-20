import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
  upsertEnrollment,
  upsertPayment,
  deletePayment,
  deleteEnrollment,
} from "../actions";
import { listActivePackPrices } from "@/lib/pricing-server";
import { type PackSlug } from "@/lib/packs";
import { PackFormationFields } from "./pack-formation-fields";

export const dynamic = "force-dynamic";

export default async function EnrollmentEditorPage({
  params,
}: {
  params: { id: string };
}) {
  const isNew = params.id === "new";
  // Client session : RLS réparées, is_admin() autorise le staff.
  const supabase = createClient();

  const [
    { data: enrollment },
    { data: users },
    { data: funders },
    { data: formations },
    activePrices,
  ] = await Promise.all([
    isNew
      ? Promise.resolve({ data: null })
      : supabase
          .from("enrollments")
          .select("*, payments:payment_schedule(*)")
          .eq("id", params.id)
          .single(),
    // Tous les profils sauf super_admin sont éligibles à un dossier
    // (un admin/trainer peut être inscrit à une formation en test, mais
    // un super_admin ne devrait pas l'être). On retire le filtre strict
    // sur role='student' qui masquait les comptes non-bascules en student.
    supabase
      .from("profiles")
      .select("id, full_name, email, role")
      .neq("role", "super_admin")
      .order("full_name"),
    supabase.from("funders").select("id, name, kind").order("name"),
    supabase
      .from("formations")
      .select("id, slug, code, title")
      .order("code"),
    listActivePackPrices(),
  ]);

  if (!isNew && !enrollment) notFound();
  const e: any = enrollment ?? {};
  const defaultPack: PackSlug = (e.pack as PackSlug) ?? "initial";

  const formationsOpts = (formations ?? []).map((f: any) => ({
    id: f.id,
    slug: f.slug,
    code: f.code,
    title: f.title,
  }));

  const pricesForClient = activePrices.map((p) => ({
    formationSlug: p.formationSlug,
    pack: p.pack,
    priceCents: p.priceCents,
  }));

  return (
    <div className="space-y-8">
      <header className="flex items-center justify-between">
        <div>
          <Link href="/admin/enrollments" className="text-sm text-slate-500 hover:text-navy-900">
            ← Retour
          </Link>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
            {isNew ? "Nouveau dossier" : "Dossier d'inscription"}
          </h1>
        </div>
      </header>

      <Card>
        <CardBody>
          <CardTitle>Informations</CardTitle>
          <form action={upsertEnrollment} className="mt-5 grid md:grid-cols-2 gap-4">
            {!isNew && <input type="hidden" name="id" value={e.id} />}
            <div>
              <Label htmlFor="user_id">Stagiaire</Label>
              <select
                id="user_id"
                name="user_id"
                defaultValue={e.user_id ?? ""}
                required
                className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px]"
              >
                <option value="">— Sélectionner —</option>
                {(users ?? []).map((u: any) => {
                  const roleLabel =
                    u.role === "admin"
                      ? " [admin]"
                      : u.role === "trainer"
                        ? " [formateur]"
                        : "";
                  return (
                    <option key={u.id} value={u.id}>
                      {u.full_name ?? u.email} ({u.email}){roleLabel}
                    </option>
                  );
                })}
              </select>
            </div>
            <div>
              <Label htmlFor="funder_id">Financeur</Label>
              <select
                id="funder_id"
                name="funder_id"
                defaultValue={e.funder_id ?? ""}
                className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px]"
              >
                <option value="">— Aucun / auto —</option>
                {(funders ?? []).map((f: any) => (
                  <option key={f.id} value={f.id}>
                    {f.name} ({f.kind})
                  </option>
                ))}
              </select>
            </div>
            <div>
              <Label htmlFor="funding_kind">Nature du financement</Label>
              <select
                id="funding_kind"
                name="funding_kind"
                defaultValue={e.funding_kind ?? "auto"}
                className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px]"
              >
                {["opco","cpf","employeur","pole_emploi","auto","autre"].map((k) => (
                  <option key={k} value={k}>{k}</option>
                ))}
              </select>
            </div>
            <div>
              <Label htmlFor="status">Statut</Label>
              <select
                id="status"
                name="status"
                defaultValue={e.status ?? "prospect"}
                className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px]"
              >
                {[
                  "prospect","devis","accord_financeur","a_payer",
                  "en_cours","termine","abandon","refuse",
                ].map((s) => (
                  <option key={s} value={s}>{s}</option>
                ))}
              </select>
            </div>
            <div>
              <Label htmlFor="session_label">Session</Label>
              <Input id="session_label" name="session_label" defaultValue={e.session_label ?? ""} />
            </div>
            <div>
              <Label htmlFor="total_amount_euros">Coût pédagogique (€)</Label>
              <Input
                id="total_amount_euros"
                name="total_amount_euros"
                type="number"
                step="0.01"
                defaultValue={((e.total_amount_cents ?? 0) / 100).toFixed(2)}
              />
            </div>

            {/* Phase 4 : sélecteur Formation + Pack avec helper de prix DB */}
            <PackFormationFields
              formations={formationsOpts}
              prices={pricesForClient}
              defaultPack={defaultPack}
              defaultFormationId={e.formation_id ?? null}
              currentAmountCents={e.total_amount_cents ?? 0}
              totalAmountInputId="total_amount_euros"
            />
            <div>
              <Label htmlFor="start_date">Début</Label>
              <Input id="start_date" name="start_date" type="date" defaultValue={e.start_date ?? ""} />
            </div>
            <div>
              <Label htmlFor="end_date">Fin</Label>
              <Input id="end_date" name="end_date" type="date" defaultValue={e.end_date ?? ""} />
            </div>
            <div className="md:col-span-2">
              <Label htmlFor="contract_url">URL contrat</Label>
              <Input id="contract_url" name="contract_url" defaultValue={e.contract_url ?? ""} />
            </div>
            <div className="md:col-span-2">
              <Label htmlFor="convention_url">URL convention</Label>
              <Input id="convention_url" name="convention_url" defaultValue={e.convention_url ?? ""} />
            </div>
            <div className="md:col-span-2">
              <Label htmlFor="cpf_dossier_ref">Réf. dossier CPF</Label>
              <Input id="cpf_dossier_ref" name="cpf_dossier_ref" defaultValue={e.cpf_dossier_ref ?? ""} />
            </div>

            <div className="md:col-span-2 flex justify-between items-center">
              {!isNew && (
                <form action={deleteEnrollment.bind(null, e.id)}>
                  <button
                    type="submit"
                    className="text-sm font-medium text-rose-700 hover:underline"
                  >
                    Supprimer le dossier
                  </button>
                </form>
              )}
              <Button type="submit" variant="gold">
                {isNew ? "Créer" : "Enregistrer"}
              </Button>
            </div>
          </form>
        </CardBody>
      </Card>

      {!isNew && (
        <Card>
          <CardBody>
            <CardTitle>Échéancier</CardTitle>
            <div className="mt-4 space-y-2">
              {(e.payments ?? []).map((p: any) => (
                <form
                  key={p.id}
                  action={upsertPayment}
                  className="grid md:grid-cols-[1fr_1fr_1fr_1fr_1fr_auto] gap-2 items-end p-3 rounded-xl border border-navy-100"
                >
                  <input type="hidden" name="id" value={p.id} />
                  <input type="hidden" name="enrollment_id" value={e.id} />
                  <div>
                    <label className="text-[11px] font-semibold text-slate-500">Échéance</label>
                    <Input type="date" name="due_date" defaultValue={p.due_date} />
                  </div>
                  <div>
                    <label className="text-[11px] font-semibold text-slate-500">Montant €</label>
                    <Input
                      type="number"
                      step="0.01"
                      name="amount_euros"
                      defaultValue={(p.amount_cents / 100).toFixed(2)}
                    />
                  </div>
                  <div>
                    <label className="text-[11px] font-semibold text-slate-500">Payé le</label>
                    <Input type="date" name="paid_at" defaultValue={p.paid_at ? String(p.paid_at).slice(0,10) : ""} />
                  </div>
                  <div>
                    <label className="text-[11px] font-semibold text-slate-500">Payé €</label>
                    <Input
                      type="number"
                      step="0.01"
                      name="paid_amount_euros"
                      defaultValue={((p.paid_amount_cents ?? 0) / 100).toFixed(2)}
                    />
                  </div>
                  <div>
                    <label className="text-[11px] font-semibold text-slate-500">Méthode</label>
                    <select
                      name="method"
                      defaultValue={p.method ?? ""}
                      className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3 text-sm"
                    >
                      <option value="">—</option>
                      {["virement","carte","prelevement","cpf","opco","autre"].map((m) => (
                        <option key={m} value={m}>{m}</option>
                      ))}
                    </select>
                  </div>
                  <div className="flex flex-col gap-1">
                    <Button type="submit" size="sm">OK</Button>
                    <button
                      formAction={deletePayment.bind(null, p.id)}
                      className="text-[11px] text-rose-700 hover:underline"
                    >
                      Suppr.
                    </button>
                  </div>
                </form>
              ))}

              {/* Nouvelle échéance */}
              <form
                action={upsertPayment}
                className="grid md:grid-cols-[1fr_1fr_1fr_1fr_1fr_auto] gap-2 items-end p-3 rounded-xl bg-navy-50"
              >
                <input type="hidden" name="enrollment_id" value={e.id} />
                <div>
                  <label className="text-[11px] font-semibold text-slate-500">Échéance</label>
                  <Input type="date" name="due_date" required />
                </div>
                <div>
                  <label className="text-[11px] font-semibold text-slate-500">Montant €</label>
                  <Input type="number" step="0.01" name="amount_euros" required />
                </div>
                <div>
                  <label className="text-[11px] font-semibold text-slate-500">Payé le</label>
                  <Input type="date" name="paid_at" />
                </div>
                <div>
                  <label className="text-[11px] font-semibold text-slate-500">Payé €</label>
                  <Input type="number" step="0.01" name="paid_amount_euros" defaultValue="0" />
                </div>
                <div>
                  <label className="text-[11px] font-semibold text-slate-500">Méthode</label>
                  <select
                    name="method"
                    className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3 text-sm"
                  >
                    <option value="">—</option>
                    {["virement","carte","prelevement","cpf","opco","autre"].map((m) => (
                      <option key={m} value={m}>{m}</option>
                    ))}
                  </select>
                </div>
                <Button type="submit" size="sm" variant="gold">+ Ajouter</Button>
              </form>
            </div>
          </CardBody>
        </Card>
      )}
    </div>
  );
}
