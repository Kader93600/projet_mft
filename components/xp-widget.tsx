import { createClient } from "@/lib/supabase/server";
import { xpLevelFromTotal } from "@/lib/gamification/ranks";
import { XpWidgetView } from "@/components/xp-widget-view";

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
  const curStart = (((level - 1) * level) / 2) * 100;
  const nextStart = ((level * (level + 1)) / 2) * 100;
  const pct = Math.min(
    100,
    Math.round(((totalXp - curStart) / Math.max(1, nextStart - curStart)) * 100)
  );
  const currentStreak = (streak as any)?.[0]?.current_streak ?? 0;
  const longestStreak = (streak as any)?.[0]?.longest_streak ?? 0;

  return (
    <XpWidgetView
      level={level}
      totalXp={totalXp}
      nextStart={nextStart}
      pct={pct}
      currentStreak={currentStreak}
      longestStreak={longestStreak}
    />
  );
}
