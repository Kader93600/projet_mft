import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/input";
import {
  ArrowLeft,
  ShieldPlus,
  Trash2,
  Award,
  CheckCircle2,
  Layers,
  Filter,
} from "lucide-react";
import {
  grantTrainerFormation,
  revokeTrainerFormation,
} from "../actions";
import { FORMATIONS, findFormation } from "@/lib/formations-config";
import { accentVars } from "@/lib/formation-accent";

export const dynamic = "force-dynamic";

export default async function FormateursAffectationsPage(
  props: {
    searchParams?: Promise<{ f?: string }>;
  }
) {
  const searchParams = await props.searchParams;
  const supabase = await createClient();

  const filterFormation = (searchParams?.f ?? "").trim();

  // Formateurs (et admins / super_admins qui pourraient enseigner)
  const { data: trainers } = await supabase
    .from("profiles")
    .select("id, full_name, email, role")
    .in("role", ["trainer", "admin", "super_admin"])
    .order("full_name", { ascending: true });

  // Habilitations existantes
  let habQuery = supabase
    .from("trainer_formations")
    .select(
      "id, trainer_id, formation_id, is_lead, can_grade, can_edit_content, granted_at, formation:formations(slug, code, title), trainer:profiles!trainer_formations_trainer_id_fkey(full_name, email, role)"
    )
    .order("granted_at", { ascending: false });
  if (filterFormation) {
    // Récupérer l'ID de la formation par slug
    const { data: f } = await supabase
      .from("formations")
      .select("id")
      .eq("slug", filterFormation)
      .single();
    if (f) habQuery = habQuery.eq("formation_id", f.id);
  }
  const { data: habilitations } = await habQuery;

  // Liste des formations BDD pour le formulaire
  const { data: dbFormations } = await supabase
    .from("formations")
    .select("id, slug, code, title")
    .order("display_order");

  return (
    <div className="space-y-8">
      <Link
        href="/admin/affectations"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Affectations
      </Link>

      <header>
        <span className="eyebrow text-brand-700">Formateurs</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
          Habiliter sur une formation
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Une habilitation autorise un formateur à encadrer une cohorte
          spécifique. Vous pouvez préciser ses capacités fines (notation,
          édition de contenus, statut de référent).
        </p>
      </header>

      {/* Filtres */}
      <section className="flex flex-wrap gap-2 items-center">
        <span className="inline-flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-500 mr-2">
          <Filter className="h-3.5 w-3.5" />
          Filtrer par formation
        </span>
        <Link
          href="/admin/affectations/formateurs"
          className={
            "px-3 py-1.5 rounded-full text-xs font-medium border transition " +
            (!filterFormation
              ? "bg-navy-900 text-white border-navy-900"
              : "bg-white text-slate-600 border-navy-100 hover:border-navy-300")
          }
        >
          Toutes
        </Link>
        {FORMATIONS.map((f) => (
          <Link
            key={f.slug}
            href={`/admin/affectations/formateurs?f=${f.slug}`}
            className={
              "px-3 py-1.5 rounded-full text-xs font-medium border transition " +
              (filterFormation === f.slug
                ? "text-white border-transparent"
                : "bg-white text-slate-600 border-navy-100 hover:border-navy-300")
            }
            style={
              filterFormation === f.slug
                ? { backgroundColor: f.accent, borderColor: f.accent }
                : undefined
            }
          >
            {f.code}
          </Link>
        ))}
      </section>

      {/* Formulaire d'habilitation */}
      <Card>
        <CardBody>
          <CardTitle>Nouvelle habilitation</CardTitle>
          <p className="text-sm text-slate-600 mt-1 mb-4">
            Si l'habilitation existe déjà pour ce couple (formateur, formation),
            elle sera mise à jour avec les nouvelles capacités.
          </p>
          <form
            action={grantTrainerFormation}
            className="grid md:grid-cols-2 gap-4"
          >
            <div>
              <Label htmlFor="trainer_id">Formateur</Label>
              <select
                id="trainer_id"
                name="trainer_id"
                required
                className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900"
              >
                <option value="">— Choisir —</option>
                {(trainers ?? []).map((t: any) => (
                  <option key={t.id} value={t.id}>
                    {t.full_name ?? t.email} ({t.role})
                  </option>
                ))}
              </select>
            </div>
            <div>
              <Label htmlFor="formation_id">Formation</Label>
              <select
                id="formation_id"
                name="formation_id"
                required
                className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900"
              >
                <option value="">— Choisir —</option>
                {(dbFormations ?? []).map((f: any) => (
                  <option key={f.id} value={f.id}>
                    {f.code} — {f.title}
                  </option>
                ))}
              </select>
            </div>

            <fieldset className="md:col-span-2 grid sm:grid-cols-3 gap-3">
              <legend className="sr-only">Capacités</legend>
              <Capability name="is_lead" label="Référent pédagogique" defaultChecked={false} />
              <Capability name="can_grade" label="Peut noter les copies" defaultChecked />
              <Capability name="can_edit_content" label="Peut éditer les contenus" defaultChecked={false} />
            </fieldset>

            <div className="md:col-span-2 flex justify-end">
              <Button type="submit" variant="gold">
                <ShieldPlus className="h-4 w-4" /> Habiliter
              </Button>
            </div>
          </form>
        </CardBody>
      </Card>

      {/* Liste des habilitations */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          Habilitations en cours ({(habilitations ?? []).length})
        </h2>
        <Card>
          <CardBody className="p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                <tr>
                  <th className="text-left px-6 py-3">Formateur</th>
                  <th className="text-left px-3 py-3">Formation</th>
                  <th className="text-left px-3 py-3">Capacités</th>
                  <th className="text-left px-3 py-3">Depuis</th>
                  <th className="text-right px-6 py-3">Action</th>
                </tr>
              </thead>
              <tbody>
                {(habilitations ?? []).length === 0 ? (
                  <tr>
                    <td
                      colSpan={5}
                      className="p-10 text-center text-sm text-slate-500"
                    >
                      Aucune habilitation pour ce filtre.
                    </td>
                  </tr>
                ) : (
                  (habilitations ?? []).map((h: any) => {
                    const f = h.formation?.slug
                      ? findFormation(h.formation.slug)
                      : null;
                    return (
                      <tr key={h.id} className="border-t border-navy-50">
                        <td className="px-6 py-3">
                          <div className="font-medium text-navy-900">
                            {h.trainer?.full_name ?? h.trainer?.email}
                          </div>
                          <div className="text-xs text-slate-500">
                            {h.trainer?.role}
                          </div>
                        </td>
                        <td className="px-3 py-3">
                          <span
                            className="formation-accent inline-flex items-center gap-1.5 px-2 py-0.5 rounded-md text-xs font-semibold border"
                            style={accentVars(f?.accent ?? "#9FE220")}
                          >
                            {h.formation?.code ?? "—"}
                          </span>
                        </td>
                        <td className="px-3 py-3">
                          <div className="flex flex-wrap gap-1">
                            {h.is_lead && (
                              <Badge tone="gold" size="sm">
                                <Award className="h-3 w-3" /> Lead
                              </Badge>
                            )}
                            {h.can_grade && (
                              <Badge tone="success" size="sm">
                                <CheckCircle2 className="h-3 w-3" /> Notation
                              </Badge>
                            )}
                            {h.can_edit_content && (
                              <Badge tone="navy" size="sm">
                                <Layers className="h-3 w-3" /> Édition
                              </Badge>
                            )}
                          </div>
                        </td>
                        <td className="px-3 py-3 text-xs text-slate-500">
                          {new Date(h.granted_at).toLocaleDateString("fr-FR")}
                        </td>
                        <td className="px-6 py-3 text-right">
                          <form
                            action={async () => {
                              "use server";
                              await revokeTrainerFormation(h.id);
                            }}
                          >
                            <button
                              type="submit"
                              className="text-rose-600 hover:text-rose-800 inline-flex items-center gap-1 text-xs"
                              aria-label="Révoquer"
                            >
                              <Trash2 className="h-3.5 w-3.5" />
                            </button>
                          </form>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </CardBody>
        </Card>
      </section>
    </div>
  );
}

function Capability({
  name,
  label,
  defaultChecked,
}: {
  name: string;
  label: string;
  defaultChecked?: boolean;
}) {
  return (
    <label className="flex items-center gap-2.5 px-3.5 py-2.5 rounded-xl border border-navy-100 bg-ivory cursor-pointer hover:border-brand-300">
      <input
        type="checkbox"
        name={name}
        defaultChecked={defaultChecked}
        className="h-4 w-4 rounded border-navy-300 text-brand-600 focus:ring-brand-500"
      />
      <span className="text-sm text-navy-900">{label}</span>
    </label>
  );
}
