import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Flame, Sparkles, Trophy } from "lucide-react";
import { xpLevelFromTotal } from "@/lib/gamification/ranks";

export async function XpWidget() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // XP calculée directement depuis xp_events (la vue user_gamification est
  // filtrée role='student' pour le classement → ne couvrirait pas un staff
  // qui consulte son propre espace).
  const [{ data: xpRows }, { data: streak }] = await Promise.all([
    supabase.from("xp_events").select("points").eq("user_id", user.id),
    supabase.rpc("user_streak", { p_user: user.id }),
  ]);

  const totalXp = (xpRows ?? []).reduce(
    (s: number, r: any) => s + (r.points ?? 0),
    0
  );
  const level = xpLevelFromTotal(totalXp);
  // XP requis pour le début du niveau courant : (L-1)*L/2 * 100
  const curStart = ((level - 1) * level) / 2 * 100;
  const nextStart = (level * (level + 1)) / 2 * 100;
  const pct = Math.min(
    100,
    Math.round(((totalXp - curStart) / Math.max(1, nextStart - curStart)) * 100)
  );
  const current = (streak as any)?.[0]?.current_streak ?? 0;
  const longest = (streak as any)?.[0]?.longest_streak ?? 0;

  return (
    <Card variant="solid-navy" className="relative overflow-hidden">
      <div className="absolute inset-0 bg-mesh-navy opacity-40" />
      <CardBody className="relative grid md:grid-cols-[auto_1fr_auto] gap-6 items-center">
        <div className="flex items-center gap-4">
          <div className="h-14 w-14 rounded-2xl bg-gold-500 text-navy-900 flex items-center justify-center shrink-0">
            <Trophy className="h-7 w-7" />
          </div>
          <div>
            <div className="text-[11px] uppercase tracking-wider text-gold-300">
              Niveau
            </div>
            <div className="font-display text-3xl font-semibold">{level}</div>
          </div>
        </div>

        <div>
          <div className="flex items-center justify-between text-xs text-white/70 mb-1.5">
            <span>{totalXp} XP</span>
            <span>{nextStart} XP</span>
          </div>
          <div className="h-2 rounded-full bg-white/10 overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-gold-400 to-gold-600"
              style={{ width: `${pct}%` }}
            />
          </div>
          <div className="mt-2 text-xs text-white/60">
            Encore {Math.max(0, nextStart - totalXp)} XP avant le niveau {level + 1}
          </div>
        </div>

        <div className="flex gap-4">
          <div className="flex items-center gap-2 rounded-xl bg-white/5 border border-white/10 px-3 py-2">
            <Flame className="h-4 w-4 text-gold-400" />
            <div>
              <div className="text-[10px] uppercase tracking-wider text-white/60">
                Série
              </div>
              <div className="font-display text-lg font-semibold">
                {current}<span className="text-xs text-white/50"> j</span>
              </div>
            </div>
          </div>
          <div className="flex items-center gap-2 rounded-xl bg-white/5 border border-white/10 px-3 py-2">
            <Sparkles className="h-4 w-4 text-gold-400" />
            <div>
              <div className="text-[10px] uppercase tracking-wider text-white/60">
                Record
              </div>
              <div className="font-display text-lg font-semibold">
                {longest}<span className="text-xs text-white/50"> j</span>
              </div>
            </div>
          </div>
        </div>
      </CardBody>
    </Card>
  );
}
