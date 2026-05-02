import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { UsersTable } from "./users-table";
import { Button } from "@/components/ui/button";
import { UserPlus } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function AdminUsers() {
  const supabase = createClient();
  const [{ data: users }, { data: groups }, { data: attempts }] = await Promise.all([
    supabase
      .from("profiles")
      .select("*")
      .order("created_at", { ascending: false }),
    supabase.from("groups").select("id, name, color").order("name"),
    supabase.from("quiz_attempts").select("user_id, percentage"),
  ]);

  const statsByUser = new Map<string, { count: number; avg: number }>();
  (attempts ?? []).forEach((a: any) => {
    const cur = statsByUser.get(a.user_id) ?? { count: 0, avg: 0 };
    cur.count++;
    cur.avg = ((cur.avg * (cur.count - 1)) + (a.percentage || 0)) / cur.count;
    statsByUser.set(a.user_id, cur);
  });

  const enriched = (users ?? []).map((u) => ({
    ...u,
    attempts_count: statsByUser.get(u.id)?.count ?? 0,
    avg_score: Math.round(statsByUser.get(u.id)?.avg ?? 0),
  }));

  return (
    <div className="space-y-8">
      <header className="flex items-end justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700">Administration</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Utilisateurs
          </h1>
          <p className="mt-2 text-slate-600">
            {users?.length ?? 0} comptes · gérez rôles, groupes, activité et
            accès.
          </p>
        </div>
        <Link href="/admin/users/new">
          <Button variant="gold">
            <UserPlus className="h-4 w-4" /> Nouveau stagiaire
          </Button>
        </Link>
      </header>

      <UsersTable users={enriched} groups={groups ?? []} />
    </div>
  );
}
