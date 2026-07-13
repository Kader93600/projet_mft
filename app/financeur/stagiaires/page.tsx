import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Users,
  Search,
  ChevronRight,
  Award,
  AlertCircle,
  CheckCircle2,
} from "lucide-react";
import { getFunderAccess } from "@/lib/funder/access";
import { sanitizeSearchTerm } from "@/lib/search";

export const dynamic = "force-dynamic";

const STATUS_LABEL: Record<string, string> = {
  prospect: "Prospect",
  devis: "Devis envoyé",
  accord_financeur: "Accord financeur",
  a_payer: "À payer",
  en_cours: "En cours",
  termine: "Terminée",
};

const STATUS_TONE: Record<string, "gold" | "navy" | "success" | "slate"> = {
  prospect: "slate",
  devis: "gold",
  accord_financeur: "gold",
  a_payer: "gold",
  en_cours: "navy",
  termine: "success",
};

export default async function FinanceurStagiairesPage({
  searchParams,
}: {
  searchParams?: { status?: string; q?: string };
}) {
  const access = await getFunderAccess();
  if (!access.allowed) {
    if (access.reason === "unauthenticated") redirect("/login");
    redirect("/financeur");
  }

  const supabase = createClient();
  const status = searchParams?.status;
  const q = searchParams?.q;

  let query = supabase
    .from("funder_student_details")
    .select("*")
    .order("enrollment_created_at", { ascending: false });

  if (access.funder_id) query = query.eq("funder_id", access.funder_id);
  if (status) query = query.eq("status", status);
  if (q) {
    const safe = sanitizeSearchTerm(q);
    if (safe) query = query.or(`full_name.ilike.%${safe}%,email.ilike.%${safe}%`);
  }

  const { data: students } = await query.limit(200);
  const list = (students ?? []) as any[];

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
          <Users className="h-3.5 w-3.5" />
          Stagiaires
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Mon portfolio
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          {list.length} stagiaire{list.length > 1 ? "s" : ""} financé
          {list.length > 1 ? "s" : ""} par {access.funder_name}. Cliquez sur un
          stagiaire pour voir le détail.
        </p>
      </header>

      {/* Filtres */}
      <form className="flex flex-wrap items-center gap-2">
        <div className="relative flex-1 min-w-[240px] max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <input
            name="q"
            defaultValue={q ?? ""}
            placeholder="Nom ou email…"
            className="w-full pl-9 pr-3 py-2 rounded-lg border border-navy-100 bg-white text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
          />
        </div>
        <select
          name="status"
          defaultValue={status ?? ""}
          className="rounded-lg border border-navy-100 bg-white text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-gold-400"
        >
          <option value="">Tous statuts</option>
          {Object.entries(STATUS_LABEL).map(([k, v]) => (
            <option key={k} value={k}>
              {v}
            </option>
          ))}
        </select>
        <button
          type="submit"
          className="rounded-lg bg-navy-900 hover:bg-navy-800 text-white text-sm font-medium px-4 py-2 transition-colors"
        >
          Filtrer
        </button>
      </form>

      {/* Tableau */}
      <Card>
        <CardBody className="p-0 overflow-x-auto">
          {list.length === 0 ? (
            <div className="text-center py-12 px-5">
              <p className="text-sm text-slate-500">
                Aucun stagiaire ne correspond à ces filtres.
              </p>
            </div>
          ) : (
            <table className="w-full text-sm">
              <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                <tr>
                  <th className="text-left px-4 py-3 font-semibold">Stagiaire</th>
                  <th className="text-left px-4 py-3 font-semibold">Formation</th>
                  <th className="text-right px-4 py-3 font-semibold">Progression</th>
                  <th className="text-right px-4 py-3 font-semibold">Score</th>
                  <th className="text-left px-4 py-3 font-semibold">Statut</th>
                  <th className="px-3 py-3" aria-label="Détail" />
                </tr>
              </thead>
              <tbody>
                {list.map((s) => {
                  const progressPct =
                    s.lessons_total > 0
                      ? Math.round((s.lessons_done / s.lessons_total) * 100)
                      : 0;
                  const isAtRisk =
                    s.status === "en_cours" &&
                    (s.days_since_last_activity == null ||
                      s.days_since_last_activity > 14);
                  return (
                    <tr
                      key={s.enrollment_id}
                      className="border-t border-navy-50 hover:bg-navy-50/40 cursor-pointer"
                    >
                      <td className="px-4 py-3">
                        <Link
                          href={`/financeur/stagiaires/${s.user_id}`}
                          className="block"
                        >
                          <div className="font-medium text-navy-900 hover:text-gold-700">
                            {s.full_name ?? s.email?.split("@")[0] ?? "—"}
                          </div>
                          <div className="text-xs text-slate-500">
                            {s.email}
                          </div>
                        </Link>
                      </td>
                      <td className="px-4 py-3">
                        <div className="text-navy-900">{s.formation_title}</div>
                        <div className="text-xs text-slate-500 capitalize">
                          {s.pack}
                        </div>
                      </td>
                      <td className="px-4 py-3 text-right">
                        <div className="font-display font-semibold text-navy-900 tabular-nums">
                          {progressPct}%
                        </div>
                        <div className="text-[11px] text-slate-500 tabular-nums">
                          {s.lessons_done}/{s.lessons_total} leçons
                        </div>
                      </td>
                      <td className="px-4 py-3 text-right">
                        <div className="font-display font-semibold tabular-nums text-navy-900">
                          {s.avg_score != null ? `${s.avg_score}%` : "—"}
                        </div>
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex flex-col gap-1 items-start">
                          <Badge
                            tone={STATUS_TONE[s.status] ?? "slate"}
                            size="sm"
                          >
                            {STATUS_LABEL[s.status] ?? s.status}
                          </Badge>
                          {s.certified && (
                            <Badge tone="success" size="sm">
                              <Award className="h-3 w-3" /> Certifié
                            </Badge>
                          )}
                          {isAtRisk && (
                            <Badge tone="rose" size="sm">
                              <AlertCircle className="h-3 w-3" /> Inactif
                            </Badge>
                          )}
                        </div>
                      </td>
                      <td className="px-3 py-3 text-slate-400">
                        <ChevronRight className="h-4 w-4" />
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          )}
        </CardBody>
      </Card>

      <div className="text-xs text-slate-500">
        Données extraites de la plateforme MFT en temps réel. Pour un export
        archivable (CSV/JSON), retournez sur la{" "}
        <Link href="/financeur" className="underline">
          page d'accueil
        </Link>
        .
      </div>
    </div>
  );
}
