import Link from "next/link";
import { notFound } from "next/navigation";
import { createAdminClient } from "@/lib/supabase/admin";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { createFunder, updateFunder } from "../../actions";

export const dynamic = "force-dynamic";

export default async function FunderEditorPage({
  params,
}: {
  params: { id: string };
}) {
  const isNew = params.id === "new";
  // service_role : bypass RLS pour cohérence avec le listing parent
  // (qui passe déjà par admin client depuis le commit précédent).
  const supabase = createAdminClient();
  const [{ data: funder }, { data: users }] = await Promise.all([
    isNew
      ? Promise.resolve({ data: null })
      : supabase.from("funders").select("*").eq("id", params.id).single(),
    supabase.from("profiles").select("id, full_name, email").order("full_name"),
  ]);
  if (!isNew && !funder) notFound();
  const f: any = funder ?? {};

  const action = isNew ? createFunder : updateFunder.bind(null, f.id);

  return (
    <div className="space-y-8">
      <header>
        <Link href="/admin/enrollments" className="text-sm text-slate-500 hover:text-navy-900">
          ← Retour
        </Link>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
          {isNew ? "Nouveau financeur" : f.name}
        </h1>
      </header>

      <Card>
        <CardBody>
          <CardTitle>Financeur</CardTitle>
          <form action={action} className="mt-5 grid md:grid-cols-2 gap-4">
            <div>
              <Label htmlFor="name">Nom</Label>
              <Input id="name" name="name" defaultValue={f.name ?? ""} required />
            </div>
            <div>
              <Label htmlFor="kind">Type</Label>
              <select
                id="kind"
                name="kind"
                defaultValue={f.kind ?? "opco"}
                className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px]"
              >
                {["opco","cpf","employeur","pole_emploi","auto","autre"].map((k) => (
                  <option key={k} value={k}>{k}</option>
                ))}
              </select>
            </div>
            <div>
              <Label htmlFor="contact_email">Email contact</Label>
              <Input id="contact_email" name="contact_email" type="email" defaultValue={f.contact_email ?? ""} />
            </div>
            <div>
              <Label htmlFor="contact_phone">Téléphone</Label>
              <Input id="contact_phone" name="contact_phone" defaultValue={f.contact_phone ?? ""} />
            </div>
            <div>
              <Label htmlFor="siret">SIRET</Label>
              <Input id="siret" name="siret" defaultValue={f.siret ?? ""} />
            </div>
            <div>
              <Label htmlFor="portal_user_id">Utilisateur du portail</Label>
              <select
                id="portal_user_id"
                name="portal_user_id"
                defaultValue={f.portal_user_id ?? ""}
                className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px]"
              >
                <option value="">— Aucun —</option>
                {(users ?? []).map((u: any) => (
                  <option key={u.id} value={u.id}>
                    {u.full_name ?? u.email} ({u.email})
                  </option>
                ))}
              </select>
              <p className="text-xs text-slate-500 mt-1">
                Donne accès à <code>/financeur</code> en lecture.
              </p>
            </div>
            <div className="md:col-span-2">
              <Label htmlFor="notes">Notes internes</Label>
              <Textarea id="notes" name="notes" rows={3} defaultValue={f.notes ?? ""} />
            </div>
            <div className="md:col-span-2 flex justify-end">
              <Button type="submit" variant="gold">
                {isNew ? "Créer" : "Enregistrer"}
              </Button>
            </div>
          </form>
        </CardBody>
      </Card>
    </div>
  );
}
