import { createClient } from "@/lib/supabase/server";
import { Card } from "@/components/ui/card";
import { GroupsManager } from "./groups-manager";

export const dynamic = "force-dynamic";

export default async function AdminGroups() {
  const supabase = createClient();
  const [{ data: groups }, { data: profiles }] = await Promise.all([
    supabase.from("groups").select("*").order("created_at", { ascending: false }),
    supabase
      .from("profiles")
      .select("id, full_name, email, group_id, role")
      .eq("role", "student"),
  ]);

  // Enrichir chaque groupe avec le nombre d'stagiaires
  const enriched = (groups ?? []).map((g) => ({
    ...g,
    students_count: (profiles ?? []).filter((p) => p.group_id === g.id).length,
  }));

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Organisation</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Classes & groupes
        </h1>
        <p className="mt-2 text-slate-600">
          Organisez vos stagiaires en promotions pour un suivi personnalisé.
        </p>
      </header>

      <GroupsManager groups={enriched} students={profiles ?? []} />
    </div>
  );
}
