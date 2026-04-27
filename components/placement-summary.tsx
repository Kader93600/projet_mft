import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ProgressBar } from "@/components/ui/progress";
import { Target, ArrowRight } from "lucide-react";

function levelLabel(level?: string) {
  return level === "avance"
    ? "Avancé"
    : level === "intermediaire"
    ? "Intermédiaire"
    : "Débutant";
}

export async function PlacementSummary() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: result } = await supabase
    .from("placement_results")
    .select("scores, level_per_bloc, recommended_bloc_id, taken_at")
    .eq("user_id", user.id)
    .maybeSingle();

  if (!result) return null;

  const { data: blocs } = await supabase
    .from("blocs")
    .select("id, code, title")
    .order("order");

  const recommended = blocs?.find((b: any) => b.id === result.recommended_bloc_id);

  return (
    <Card>
      <CardBody>
        <div className="flex items-center gap-2">
          <Target className="h-4 w-4 text-gold-700" />
          <span className="eyebrow text-gold-700">Votre positionnement</span>
        </div>
        <div className="mt-3 flex items-start justify-between gap-4 flex-wrap">
          <div>
            <div className="font-display text-lg font-semibold text-navy-900">
              {recommended
                ? `Priorité recommandée : ${recommended.code}`
                : "Profil équilibré sur les 3 blocs"}
            </div>
            {recommended && (
              <div className="text-sm text-slate-600 mt-0.5">{recommended.title}</div>
            )}
          </div>
          <Link
            href="/positionnement"
            className="text-sm font-medium text-navy-900 hover:text-gold-700 inline-flex items-center gap-1"
          >
            Détails
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>

        <div className="mt-4 grid sm:grid-cols-3 gap-3">
          {blocs?.map((b: any) => {
            const pct = (result.scores as any)?.[b.code] ?? 0;
            const lvl = (result.level_per_bloc as any)?.[b.code] ?? "debutant";
            return (
              <div key={b.id} className="rounded-xl border border-navy-100 p-3 bg-ivory/40">
                <div className="flex items-center justify-between">
                  <Badge tone="navy" size="sm">{b.code}</Badge>
                  <span className="text-[10px] font-medium text-slate-500 uppercase tracking-wide">
                    {levelLabel(lvl)}
                  </span>
                </div>
                <div className="mt-2">
                  <ProgressBar value={pct} variant="gradient" />
                  <div className="mt-1 text-xs text-slate-500">{pct}%</div>
                </div>
              </div>
            );
          })}
        </div>
      </CardBody>
    </Card>
  );
}
