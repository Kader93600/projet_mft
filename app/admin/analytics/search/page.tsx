import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Search, AlertTriangle } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function SearchAnalyticsPage() {
  const supabase = await createClient();
  const { data: rows } = await supabase
    .from("search_top_queries")
    .select("*")
    .limit(100);

  const total = (rows ?? []).reduce((s: number, r: any) => s + r.searches, 0);
  const empty = (rows ?? []).reduce(
    (s: number, r: any) => s + r.empty_results,
    0
  );
  const emptyRate = total ? Math.round((empty / total) * 100) : 0;

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">Pédagogie</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Analyse des recherches
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Top des requêtes saisies par les stagiaires sur les 30 derniers
          jours, avec le taux de recherches sans résultat (signal de manque de
          contenu).
        </p>
      </header>

      <section className="grid sm:grid-cols-3 gap-4">
        <Card>
          <CardBody>
            <div className="text-xs uppercase tracking-wider text-slate-500">
              Recherches (30j)
            </div>
            <div className="font-display text-3xl font-semibold text-navy-900 mt-1">
              {total}
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <div className="text-xs uppercase tracking-wider text-slate-500">
              Sans résultat
            </div>
            <div className="font-display text-3xl font-semibold text-rose-700 mt-1">
              {empty}
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <div className="text-xs uppercase tracking-wider text-slate-500">
              Taux d'échec
            </div>
            <div className="font-display text-3xl font-semibold text-navy-900 mt-1">
              {emptyRate}%
            </div>
          </CardBody>
        </Card>
      </section>

      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          Top requêtes
        </h2>
        <Card>
          <CardBody className="p-0">
            {(rows ?? []).length === 0 ? (
              <div className="p-10 text-center text-sm text-slate-500">
                Pas encore de données — les recherches seront tracées dès la
                prochaine consultation.
              </div>
            ) : (
              <table className="w-full text-sm">
                <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                  <tr>
                    <th className="text-left px-6 py-3">Requête</th>
                    <th className="text-left px-6 py-3">Recherches</th>
                    <th className="text-left px-6 py-3">Sans résultat</th>
                    <th className="text-left px-6 py-3">Taux d'échec</th>
                    <th className="text-left px-6 py-3">Dernière</th>
                  </tr>
                </thead>
                <tbody>
                  {(rows ?? []).map((r: any) => (
                    <tr key={r.query} className="border-t border-navy-50">
                      <td className="px-6 py-3">
                        <div className="flex items-center gap-2 font-medium text-navy-900">
                          <Search className="h-3.5 w-3.5 text-slate-400" />
                          {r.query}
                        </div>
                      </td>
                      <td className="px-6 py-3 text-slate-700">{r.searches}</td>
                      <td className="px-6 py-3 text-slate-700">
                        {r.empty_results}
                      </td>
                      <td className="px-6 py-3">
                        {Number(r.empty_rate_pct) >= 50 ? (
                          <Badge tone="rose" size="sm">
                            <AlertTriangle className="h-3 w-3" />{" "}
                            {r.empty_rate_pct}%
                          </Badge>
                        ) : (
                          <span className="text-slate-600">
                            {r.empty_rate_pct}%
                          </span>
                        )}
                      </td>
                      <td className="px-6 py-3 text-slate-500 text-xs">
                        {new Date(r.last_searched_at).toLocaleDateString(
                          "fr-FR"
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </CardBody>
        </Card>
      </section>
    </div>
  );
}
