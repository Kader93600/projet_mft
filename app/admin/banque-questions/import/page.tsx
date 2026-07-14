// =====================================================================
// /admin/banque-questions/import
//
// Workflow d'import en lot depuis un PDF (ou un copier-coller).
// Server component : fetch les formations + modules + historique des
// derniers imports. Délègue tout l'interactif au composant client
// ImportFlow.
// =====================================================================

import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { ArrowLeft, FileUp, Clock, CheckCircle2, AlertTriangle } from "lucide-react";
import { ImportFlow } from "./import-flow";
import type { Tables } from "@/lib/database.types";

export const dynamic = "force-dynamic";

/** `formations` — colonnes du select ci-dessous. */
type FormationOpt = Pick<Tables<"formations">, "id" | "slug" | "code" | "title">;

/** `formation_modules` — colonnes du select ci-dessous. */
type FormationModuleRow = Pick<
  Tables<"formation_modules">,
  "formation_id" | "module_id" | "display_order"
>;

/** `question_imports` + embed `formation:formations(code)`. */
type RecentImportRow = Pick<
  Tables<"question_imports">,
  "id" | "file_name" | "status" | "questions_count" | "created_at" | "formation_id"
> & { formation: Pick<Tables<"formations">, "code"> | null };

const STATUS_TONE: Record<string, { bg: string; fg: string; label: string }> = {
  extracted: { bg: "bg-slate-100", fg: "text-slate-700", label: "Extrait" },
  parsed:    { bg: "bg-amber-50",  fg: "text-amber-800", label: "Parsé" },
  inserted:  { bg: "bg-emerald-50", fg: "text-emerald-800", label: "Inséré" },
  failed:    { bg: "bg-rose-50",   fg: "text-rose-800",   label: "Échec" },
  aborted:   { bg: "bg-slate-100", fg: "text-slate-500",  label: "Annulé" },
};

export default async function ImportPage() {
  const supabase = await createClient();

  const [
    { data: formations },
    { data: allModules },
    { data: formationModules },
    { data: lessons },
    { data: recentImports },
  ] = await Promise.all([
    supabase
      .from("formations")
      .select("id, slug, code, title")
      .order("code"),
    // Tous les modules. On les liera aux formations en JS via la table
    // de jointure ci-dessous. Fallback : si une formation n'a aucun
    // module rattaché, on affiche tous les modules (mieux qu'un select
    // vide qui empêche l'admin d'avancer).
    supabase
      .from("modules")
      .select("id, slug, title, \"order\"")
      .order("order"),
    supabase
      .from("formation_modules")
      .select("formation_id, module_id, display_order")
      .order("display_order"),
    supabase
      .from("lessons")
      .select("id, slug, title, module_id, \"order\"")
      .order("order"),
    supabase
      .from("question_imports")
      // Type de résultat explicite : la chaîne du `select` est concaténée,
      // or l'inférence supabase-js exige un littéral (cf. CLAUDE.md).
      .select<string, RecentImportRow>(
        "id, file_name, status, questions_count, created_at, formation_id, " +
          "formation:formations(code)",
      )
      .order("created_at", { ascending: false })
      .limit(10),
  ]);

  const formationsOpts = ((formations ?? []) as FormationOpt[]).map((f) => ({
    id: f.id,
    slug: f.slug,
    code: f.code,
    title: f.title,
  }));

  // Index des modules par id
  const moduleById = new Map<
    string,
    { id: string; slug: string; title: string }
  >();
  for (const m of allModules ?? []) {
    moduleById.set(m.id, { id: m.id, slug: m.slug, title: m.title });
  }
  const allModulesOpts = Array.from(moduleById.values());

  // Map formation → modules rattachés via la jointure
  const modulesByFormation: Record<
    string,
    { id: string; slug: string; title: string }[]
  > = {};
  for (const fm of (formationModules ?? []) as FormationModuleRow[]) {
    const formationId = fm.formation_id;
    const moduleId = fm.module_id;
    const m = moduleById.get(moduleId);
    if (!formationId || !m) continue;
    if (!modulesByFormation[formationId]) modulesByFormation[formationId] = [];
    modulesByFormation[formationId].push(m);
  }

  // Fallback : pour les formations sans rattachement explicite, on
  // expose tous les modules disponibles. L'admin peut ainsi avancer
  // sans devoir d'abord aller dans /admin/modules pour faire le mapping.
  for (const f of formationsOpts) {
    if (!modulesByFormation[f.id] || modulesByFormation[f.id].length === 0) {
      modulesByFormation[f.id] = allModulesOpts;
    }
  }

  const lessonsByModule: Record<
    string,
    { id: string; slug: string; title: string }[]
  > = {};
  for (const l of lessons ?? []) {
    if (!l.module_id) continue;
    if (!lessonsByModule[l.module_id]) lessonsByModule[l.module_id] = [];
    lessonsByModule[l.module_id].push({
      id: l.id,
      slug: l.slug,
      title: l.title,
    });
  }

  return (
    <div className="space-y-8">
      <header>
        <Link
          href="/admin/banque-questions"
          className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-navy-900"
        >
          <ArrowLeft className="h-3.5 w-3.5" />
          Retour à la banque
        </Link>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Import en lot
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl leading-relaxed">
          Uploadez un PDF (ou collez du texte) pour transformer rapidement un
          document fournisseur en questions de la banque. Le parser détecte
          QCM et QR, vous validez avant insertion.
        </p>
      </header>

      <Card>
        <CardBody>
          <CardTitle>Nouveau import</CardTitle>
          <ImportFlow
            formations={formationsOpts}
            modulesByFormation={modulesByFormation}
            lessonsByModule={lessonsByModule}
          />
        </CardBody>
      </Card>

      <section>
        <h2 className="eyebrow text-gold-700 mb-3">Imports récents</h2>
        {(!recentImports || recentImports.length === 0) ? (
          <Card>
            <CardBody>
              <p className="text-sm text-slate-500">
                Aucun import effectué pour le moment.
              </p>
            </CardBody>
          </Card>
        ) : (
          <Card>
            <CardBody className="p-0">
              <table className="w-full text-sm">
                <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                  <tr>
                    <th className="text-left px-4 py-2.5">Fichier</th>
                    <th className="text-left px-4 py-2.5">Formation</th>
                    <th className="text-right px-4 py-2.5">Questions</th>
                    <th className="text-left px-4 py-2.5">Statut</th>
                    <th className="text-left px-4 py-2.5">Date</th>
                  </tr>
                </thead>
                <tbody>
                  {recentImports.map((r) => {
                    const tone = STATUS_TONE[r.status] ?? STATUS_TONE.aborted;
                    return (
                      <tr key={r.id} className="border-t border-navy-50">
                        <td className="px-4 py-2.5 font-medium text-navy-900 truncate max-w-[280px]">
                          {r.file_name}
                        </td>
                        <td className="px-4 py-2.5 text-slate-600">
                          {r.formation?.code ?? "—"}
                        </td>
                        <td className="px-4 py-2.5 text-right text-navy-900 tabular-nums">
                          {r.questions_count}
                        </td>
                        <td className="px-4 py-2.5">
                          <span
                            className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[11px] font-semibold ${tone.bg} ${tone.fg}`}
                          >
                            {r.status === "inserted" && <CheckCircle2 className="h-3 w-3" />}
                            {r.status === "failed" && <AlertTriangle className="h-3 w-3" />}
                            {r.status === "parsed" && <FileUp className="h-3 w-3" />}
                            {r.status === "extracted" && <Clock className="h-3 w-3" />}
                            {tone.label}
                          </span>
                        </td>
                        <td className="px-4 py-2.5 text-slate-500">
                          {new Date(r.created_at).toLocaleString("fr-FR", {
                            day: "2-digit",
                            month: "2-digit",
                            year: "2-digit",
                            hour: "2-digit",
                            minute: "2-digit",
                          })}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </CardBody>
          </Card>
        )}
      </section>
    </div>
  );
}
