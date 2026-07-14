import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { ArrowLeft, UserPlus, Trash2, Filter } from "lucide-react";
import {
  assignStudentToFormation,
  removeStudentEnrollment,
} from "../actions";
import { FORMATIONS, findFormation } from "@/lib/formations-config";
import { sanitizeSearchTerm } from "@/lib/search";

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

export default async function StagiairesAffectationsPage(
  props: {
    searchParams?: Promise<{ f?: string; q?: string }>;
  }
) {
  const searchParams = await props.searchParams;
  const supabase = await createClient();

  const filterFormation = (searchParams?.f ?? "").trim();
  const search = (searchParams?.q ?? "").trim();

  // Stagiaires (200 max)
  let studentsQuery = supabase
    .from("profiles")
    .select("id, full_name, email")
    .eq("role", "student")
    .order("full_name", { ascending: true })
    .limit(200);
  if (search) {
    const safe = sanitizeSearchTerm(search);
    if (safe)
      studentsQuery = studentsQuery.or(
        `full_name.ilike.%${safe}%,email.ilike.%${safe}%`
      );
  }
  const { data: students } = await studentsQuery;

  // Inscriptions
  let enrollQuery = supabase
    .from("enrollments")
    .select(
      "id, user_id, formation_slug, status, funding_kind, created_at, user:profiles!user_id(full_name, email)"
    )
    .not("formation_slug", "is", null)
    .order("created_at", { ascending: false })
    .limit(300);
  if (filterFormation) {
    enrollQuery = enrollQuery.eq("formation_slug", filterFormation);
  }
  const { data: enrollments } = await enrollQuery;

  return (
    <div className="space-y-8">
      <Link
        href="/admin/affectations"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Affectations
      </Link>

      <header>
        <span className="eyebrow text-signal-700">Stagiaires</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
          Affecter à une formation
        </h1>
      </header>

      {/* Filtres */}
      <section className="flex flex-wrap gap-2 items-center">
        <span className="inline-flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-500 mr-2">
          <Filter className="h-3.5 w-3.5" />
          Filtrer par formation
        </span>
        <Link
          href="/admin/affectations/stagiaires"
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
            href={`/admin/affectations/stagiaires?f=${f.slug}`}
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

      {/* Formulaire d'affectation */}
      <Card>
        <CardBody>
          <CardTitle>Nouvelle affectation</CardTitle>
          <p className="text-sm text-slate-600 mt-1 mb-4">
            Inscrire un stagiaire à une formation. Le statut sera "en_cours" par
            défaut — vous pourrez l'ajuster ensuite via la page Inscriptions.
          </p>
          <form
            action={assignStudentToFormation}
            className="grid md:grid-cols-3 gap-4 items-end"
          >
            <div>
              <Label htmlFor="student_id">Stagiaire</Label>
              <select
                id="student_id"
                name="student_id"
                required
                className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900"
              >
                <option value="">— Choisir —</option>
                {(students ?? []).map((s: any) => (
                  <option key={s.id} value={s.id}>
                    {s.full_name ?? s.email}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <Label htmlFor="formation_slug">Formation</Label>
              <select
                id="formation_slug"
                name="formation_slug"
                required
                defaultValue={filterFormation || ""}
                className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900"
              >
                <option value="">— Choisir —</option>
                {FORMATIONS.map((f) => (
                  <option key={f.slug} value={f.slug}>
                    {f.code} — {f.title}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <Label htmlFor="funding_kind">Financement</Label>
              <select
                id="funding_kind"
                name="funding_kind"
                defaultValue="auto"
                className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900"
              >
                <option value="auto">Auto-financement</option>
                <option value="cpf">CPF</option>
                <option value="opco">OPCO</option>
                <option value="employeur">Employeur</option>
                <option value="pole_emploi">France Travail</option>
                <option value="autre">Autre</option>
              </select>
            </div>
            <div className="md:col-span-3 flex justify-end">
              <Button type="submit" variant="gold">
                <UserPlus className="h-4 w-4" /> Inscrire
              </Button>
            </div>
          </form>
        </CardBody>
      </Card>

      {/* Liste des inscriptions */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          Inscriptions actives ({(enrollments ?? []).length})
        </h2>
        <Card>
          <CardBody className="p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                <tr>
                  <th className="text-left px-6 py-3">Stagiaire</th>
                  <th className="text-left px-3 py-3">Formation</th>
                  <th className="text-left px-3 py-3">Financement</th>
                  <th className="text-left px-3 py-3">Statut</th>
                  <th className="text-left px-3 py-3">Inscrit le</th>
                  <th className="text-right px-6 py-3">Action</th>
                </tr>
              </thead>
              <tbody>
                {(enrollments ?? []).length === 0 ? (
                  <tr>
                    <td
                      colSpan={6}
                      className="p-10 text-center text-sm text-slate-500"
                    >
                      Aucune inscription pour ce filtre.
                    </td>
                  </tr>
                ) : (
                  (enrollments ?? []).map((e: any) => {
                    const f = e.formation_slug
                      ? findFormation(e.formation_slug)
                      : null;
                    return (
                      <tr key={e.id} className="border-t border-navy-50">
                        <td className="px-6 py-3">
                          <div className="font-medium text-navy-900">
                            {e.user?.full_name ?? e.user?.email}
                          </div>
                          <div className="text-xs text-slate-500">
                            {e.user?.email}
                          </div>
                        </td>
                        <td className="px-3 py-3">
                          <span
                            className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-md text-xs font-semibold"
                            style={{
                              backgroundColor: `${f?.accent ?? "#9FE220"}22`,
                              color: f?.accent ?? "#609015",
                              border: `1px solid ${f?.accent ?? "#9FE220"}55`,
                            }}
                          >
                            {f?.code ?? e.formation_slug}
                          </span>
                        </td>
                        <td className="px-3 py-3 text-xs uppercase tracking-wider text-slate-600">
                          {e.funding_kind}
                        </td>
                        <td className="px-3 py-3">
                          <Badge tone={STATUS_TONE[e.status] ?? "slate"} size="sm">
                            {e.status}
                          </Badge>
                        </td>
                        <td className="px-3 py-3 text-xs text-slate-500">
                          {new Date(e.created_at).toLocaleDateString("fr-FR")}
                        </td>
                        <td className="px-6 py-3 text-right">
                          <form
                            action={async () => {
                              "use server";
                              await removeStudentEnrollment(e.id);
                            }}
                          >
                            <button
                              type="submit"
                              className="text-rose-600 hover:text-rose-800 inline-flex items-center gap-1 text-xs"
                              aria-label="Supprimer"
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
