import { createClient } from "@/lib/supabase/server";
import { BadgeCard } from "@/components/badge-card";
import { Card, CardBody } from "@/components/ui/card";
import { Trophy, Sparkles } from "lucide-react";

const CATEGORY_LABEL: Record<string, string> = {
  progression: "Progression",
  regularite: "Régularité",
  excellence: "Excellence",
  maitrise: "Maîtrise",
};

export default async function ReussitesPage() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return null;

  const [{ data: badges }, { data: myBadges }] = await Promise.all([
    supabase.from("badges").select("*").eq("active", true).order("order"),
    supabase.from("user_badges").select("badge_id, earned_at").eq("user_id", user.id),
  ]);

  const earnedMap = new Map(
    (myBadges || []).map((b: any) => [b.badge_id, b.earned_at])
  );

  const earnedList = (badges || []).filter((b: any) => earnedMap.has(b.id));
  const totalPoints = earnedList.reduce(
    (acc: number, b: any) => acc + (b.points ?? 0),
    0
  );

  // Grouper par catégorie
  const byCategory: Record<string, any[]> = {};
  (badges || []).forEach((b: any) => {
    const c = b.category ?? "progression";
    if (!byCategory[c]) byCategory[c] = [];
    byCategory[c].push(b);
  });

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">Vos réussites</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Badges & progression
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Chaque étape franchie débloque un badge. Ils reflètent votre
          engagement et votre maîtrise des blocs de compétence.
        </p>
      </header>

      <div className="grid md:grid-cols-3 gap-4">
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="h-12 w-12 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center">
              <Trophy className="h-6 w-6" />
            </div>
            <div>
              <div className="text-xs uppercase tracking-wider text-slate-500">
                Badges débloqués
              </div>
              <div className="font-display text-2xl font-semibold text-navy-900">
                {earnedList.length} / {(badges || []).length}
              </div>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="h-12 w-12 rounded-xl bg-navy-50 border border-navy-100 text-navy-800 flex items-center justify-center">
              <Sparkles className="h-6 w-6" />
            </div>
            <div>
              <div className="text-xs uppercase tracking-wider text-slate-500">
                Points cumulés
              </div>
              <div className="font-display text-2xl font-semibold text-navy-900">
                {totalPoints}
              </div>
            </div>
          </CardBody>
        </Card>
      </div>

      {Object.entries(byCategory).map(([cat, list]) => (
        <section key={cat}>
          <h2 className="font-display text-xl font-semibold text-navy-900 tracking-tight mb-4">
            {CATEGORY_LABEL[cat] ?? cat}
          </h2>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {list.map((b: any) => (
              <BadgeCard
                key={b.id}
                badge={b}
                earned={earnedMap.has(b.id)}
                earnedAt={earnedMap.get(b.id) ?? null}
              />
            ))}
          </div>
        </section>
      ))}
    </div>
  );
}
