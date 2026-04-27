import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Crown, Medal, Trophy } from "lucide-react";
import { cn } from "@/lib/utils";

export const dynamic = "force-dynamic";

const PERIODS = [
  { value: "week", label: "Cette semaine" },
  { value: "month", label: "Ce mois-ci" },
  { value: "all", label: "Depuis toujours" },
] as const;

type Period = (typeof PERIODS)[number]["value"];

export default async function ClassementPage({
  searchParams,
}: {
  searchParams?: { p?: string };
}) {
  const period: Period = (
    PERIODS.find((p) => p.value === searchParams?.p)?.value ?? "month"
  ) as Period;

  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const [{ data: rows }, { data: myXp }, { data: mine }] = await Promise.all([
    supabase.rpc("leaderboard", { p_period: period, p_limit: 50 }),
    supabase.rpc("my_period_xp", { p_period: period }),
    supabase
      .from("user_gamification")
      .select("total_xp, level, active_days")
      .eq("user_id", user.id)
      .maybeSingle(),
  ]);

  const list = (rows ?? []) as any[];
  const myRank = list.find((r: any) => r.user_id === user.id)?.rank;
  const periodLabel =
    PERIODS.find((p) => p.value === period)?.label ?? "Cette semaine";

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Émulation</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Classement
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Les stagiaires les plus actifs de la promotion. Les noms sont anonymisés
          (initiales).
        </p>
      </header>

      {/* Sélecteur de période */}
      <div
        role="tablist"
        aria-label="Période du classement"
        className="inline-flex items-center rounded-xl border border-navy-100 bg-white p-0.5"
      >
        {PERIODS.map((p) => {
          const active = p.value === period;
          return (
            <Link
              key={p.value}
              role="tab"
              aria-selected={active}
              href={`/classement?p=${p.value}`}
              scroll={false}
              className={cn(
                "px-4 py-1.5 rounded-lg text-sm font-medium transition-colors",
                active
                  ? "bg-navy-900 text-white shadow-soft"
                  : "text-slate-600 hover:text-navy-900"
              )}
            >
              {p.label}
            </Link>
          );
        })}
      </div>

      {/* Récap perso */}
      <Card variant="gold">
        <CardBody className="grid grid-cols-3 gap-6">
          <Stat label="Mon niveau" value={(mine as any)?.level ?? 1} />
          <Stat
            label={`XP — ${periodLabel.toLowerCase()}`}
            value={`${(myXp as any) ?? 0}`}
          />
          <Stat label="Mon rang" value={myRank ? `#${myRank}` : "—"} />
        </CardBody>
      </Card>

      <Card>
        <CardBody className="p-0">
          <ul className="divide-y divide-navy-50">
            {list.map((r: any) => {
              const me = r.user_id === user.id;
              const Icon =
                r.rank === 1
                  ? Crown
                  : r.rank === 2
                  ? Trophy
                  : r.rank === 3
                  ? Medal
                  : null;
              return (
                <li
                  key={r.user_id}
                  className={cn(
                    "flex items-center gap-4 px-5 py-3",
                    me && "bg-gold-50"
                  )}
                >
                  <div
                    className={cn(
                      "h-9 w-9 rounded-xl flex items-center justify-center font-display font-semibold text-sm shrink-0",
                      r.rank === 1
                        ? "bg-gold-500 text-navy-900"
                        : r.rank === 2
                        ? "bg-navy-200 text-navy-900"
                        : r.rank === 3
                        ? "bg-gold-200 text-navy-900"
                        : "bg-navy-50 text-navy-700"
                    )}
                  >
                    {Icon ? <Icon className="h-4 w-4" /> : r.rank}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="font-medium text-navy-900 truncate">
                      {r.display_name}{" "}
                      {me && (
                        <span className="text-xs text-gold-700">(vous)</span>
                      )}
                    </div>
                    <div className="text-xs text-slate-500">
                      Niveau {r.level}
                    </div>
                  </div>
                  <Badge tone="gold" size="sm">
                    {r.total_xp} XP
                  </Badge>
                </li>
              );
            })}
            {list.length === 0 && (
              <li className="px-5 py-6 text-sm text-slate-500">
                Aucune activité sur cette période.
              </li>
            )}
          </ul>
        </CardBody>
      </Card>

      <div className="text-xs text-slate-500">
        Le classement est remis à zéro chaque {period === "week" ? "lundi" : period === "month" ? "1er du mois" : "—"} ; les anciens points restent visibles dans la vue "Depuis toujours".
      </div>
    </div>
  );
}

function Stat({ label, value }: { label: string; value: string | number }) {
  return (
    <div>
      <div className="text-[11px] uppercase tracking-wider text-gold-800">
        {label}
      </div>
      <div className="font-display text-2xl md:text-3xl font-semibold text-navy-900 mt-1">
        {value}
      </div>
    </div>
  );
}
