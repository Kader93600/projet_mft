import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { formatDate } from "@/lib/utils";
import { Thermometer, Snowflake, Star, Users } from "lucide-react";

export const dynamic = "force-dynamic";

function StatTile({
  label,
  value,
  hint,
}: {
  label: string;
  value: string;
  hint?: string;
}) {
  return (
    <div className="p-4 rounded-xl border border-navy-100 bg-white">
      <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold">
        {label}
      </div>
      <div className="mt-1 font-display text-2xl font-semibold text-navy-900">
        {value}
      </div>
      {hint && <div className="text-xs text-slate-500 mt-0.5">{hint}</div>}
    </div>
  );
}

function StarBar({ value }: { value: number | null }) {
  const v = value ?? 0;
  return (
    <div className="flex items-center gap-1">
      {[1, 2, 3, 4, 5].map((n) => (
        <Star
          key={n}
          className={
            n <= Math.round(v)
              ? "h-3.5 w-3.5 fill-gold-400 text-gold-500"
              : "h-3.5 w-3.5 text-slate-300"
          }
        />
      ))}
      <span className="ml-1 text-xs font-semibold text-navy-900">
        {value ? value.toFixed(1) : "—"}
      </span>
    </div>
  );
}

export default async function SurveysPage() {
  const supabase = createClient();

  const [{ data: stats }, { data: surveys }] = await Promise.all([
    supabase.from("survey_stats").select("*"),
    supabase
      .from("satisfaction_surveys")
      .select("*, profiles(full_name, email)")
      .order("submitted_at", { ascending: false })
      .limit(50),
  ]);

  const chaud = stats?.find((s: any) => s.type === "chaud");
  const froid = stats?.find((s: any) => s.type === "froid");

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Qualiopi · Satisfaction</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Évaluations des stagiaires
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Agrégats et détail des enquêtes de satisfaction à chaud (fin de
          formation) et à froid (plusieurs mois après).
        </p>
      </header>

      {/* Agrégats */}
      <div className="grid md:grid-cols-2 gap-4">
        {[
          { key: "chaud", label: "À chaud", icon: Thermometer, color: "rose", data: chaud },
          { key: "froid", label: "À froid", icon: Snowflake, color: "sky", data: froid },
        ].map(({ key, label, icon: Icon, color, data }) => (
          <Card key={key}>
            <CardBody>
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-2">
                  <Icon
                    className={
                      color === "rose"
                        ? "h-4 w-4 text-rose-500"
                        : "h-4 w-4 text-sky-500"
                    }
                  />
                  <CardTitle className="text-base">Évaluation {label}</CardTitle>
                </div>
                <Badge tone="slate" size="sm">
                  {data?.total ?? 0} réponses
                </Badge>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <StatTile
                  label="Globale"
                  value={data?.avg_globale ? `${data.avg_globale}/5` : "—"}
                />
                <StatTile
                  label="Contenu"
                  value={data?.avg_contenu ? `${data.avg_contenu}/5` : "—"}
                />
                <StatTile
                  label="Pédagogie"
                  value={data?.avg_pedagogie ? `${data.avg_pedagogie}/5` : "—"}
                />
                <StatTile
                  label="Plateforme"
                  value={data?.avg_plateforme ? `${data.avg_plateforme}/5` : "—"}
                />
                <StatTile
                  label="Accompagnement"
                  value={
                    data?.avg_accompagnement
                      ? `${data.avg_accompagnement}/5`
                      : "—"
                  }
                />
                <StatTile
                  label="Recommandation (NPS)"
                  value={data?.avg_nps ? `${data.avg_nps}/10` : "—"}
                />
              </div>
            </CardBody>
          </Card>
        ))}
      </div>

      {/* Liste détaillée */}
      <Card>
        <div className="px-6 pt-5 pb-3 border-b border-navy-50 flex items-center gap-2">
          <Users className="h-4 w-4 text-slate-500" />
          <CardTitle className="text-base">Dernières évaluations</CardTitle>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                <th className="text-left px-5 py-3 font-semibold">Stagiaire</th>
                <th className="text-left px-5 py-3 font-semibold">Type</th>
                <th className="text-left px-5 py-3 font-semibold">Note globale</th>
                <th className="text-left px-5 py-3 font-semibold">NPS</th>
                <th className="text-left px-5 py-3 font-semibold">Commentaires</th>
                <th className="text-right px-5 py-3 font-semibold">Date</th>
              </tr>
            </thead>
            <tbody>
              {(surveys ?? []).map((s: any) => (
                <tr
                  key={s.id}
                  className="border-t border-navy-50 hover:bg-navy-50/30 align-top"
                >
                  <td className="px-5 py-3.5">
                    <div className="font-medium text-navy-900">
                      {s.profiles?.full_name || "—"}
                    </div>
                    <div className="text-xs text-slate-500">
                      {s.profiles?.email}
                    </div>
                  </td>
                  <td className="px-5 py-3.5">
                    <Badge
                      tone={s.type === "chaud" ? "gold" : "navy"}
                      size="sm"
                    >
                      {s.type === "chaud" ? "À chaud" : "À froid"}
                    </Badge>
                  </td>
                  <td className="px-5 py-3.5">
                    <StarBar value={s.note_globale} />
                  </td>
                  <td className="px-5 py-3.5">
                    <span
                      className={
                        "inline-flex items-center justify-center h-7 min-w-[2.5rem] px-2 rounded-lg text-xs font-bold " +
                        (s.recommandation >= 9
                          ? "bg-emerald-100 text-emerald-700"
                          : s.recommandation >= 7
                          ? "bg-gold-100 text-gold-800"
                          : "bg-rose-100 text-rose-700")
                      }
                    >
                      {s.recommandation}/10
                    </span>
                  </td>
                  <td className="px-5 py-3.5 max-w-xs">
                    {s.points_forts && (
                      <div className="text-xs text-emerald-700 line-clamp-2">
                        + {s.points_forts}
                      </div>
                    )}
                    {s.points_ameliorer && (
                      <div className="text-xs text-rose-700 line-clamp-2 mt-1">
                        − {s.points_ameliorer}
                      </div>
                    )}
                  </td>
                  <td className="px-5 py-3.5 text-right text-xs text-slate-500">
                    {formatDate(s.submitted_at)}
                  </td>
                </tr>
              ))}
              {(!surveys || surveys.length === 0) && (
                <tr>
                  <td
                    colSpan={6}
                    className="px-5 py-16 text-center text-slate-400"
                  >
                    Aucune évaluation pour le moment.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
