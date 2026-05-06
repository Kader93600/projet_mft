import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { UsersTable } from "./users-table";
import { Button } from "@/components/ui/button";
import { UserPlus, Download } from "lucide-react";

export const dynamic = "force-dynamic";

const PAGE_SIZE = 50;

export default async function AdminUsers({
  searchParams,
}: {
  searchParams?: { page?: string; q?: string };
}) {
  const supabase = createClient();

  const page = Math.max(1, Number(searchParams?.page ?? 1) || 1);
  const q = (searchParams?.q ?? "").toString().trim();
  const from = (page - 1) * PAGE_SIZE;
  const to = from + PAGE_SIZE - 1;

  // Recherche server-side : ILIKE sur email + full_name (couvre la base
  // entière, pas seulement la page courante)
  let usersQuery = supabase
    .from("profiles")
    .select("*", { count: "exact" })
    .order("created_at", { ascending: false })
    .range(from, to);
  if (q) {
    const safe = q.replace(/[%_]/g, "\\$&"); // échappe les wildcards SQL
    usersQuery = usersQuery.or(`email.ilike.%${safe}%,full_name.ilike.%${safe}%`);
  }

  const [{ data: users, count }, { data: groups }] = await Promise.all([
    usersQuery,
    supabase.from("groups").select("id, name, color").order("name"),
  ]);

  // Stats : agrégat sur les tentatives — on ne fetche que celles des users
  // de la page courante (évite de tirer la table entière à chaque visite)
  const userIds = (users ?? []).map((u: any) => u.id);
  const { data: attempts } = userIds.length
    ? await supabase
        .from("quiz_attempts")
        .select("user_id, percentage")
        .in("user_id", userIds)
    : { data: [] as any[] };

  const statsByUser = new Map<string, { count: number; avg: number }>();
  (attempts ?? []).forEach((a: any) => {
    const cur = statsByUser.get(a.user_id) ?? { count: 0, avg: 0 };
    cur.count++;
    cur.avg = (cur.avg * (cur.count - 1) + (a.percentage || 0)) / cur.count;
    statsByUser.set(a.user_id, cur);
  });

  const enriched = (users ?? []).map((u: any) => ({
    ...u,
    attempts_count: statsByUser.get(u.id)?.count ?? 0,
    avg_score: Math.round(statsByUser.get(u.id)?.avg ?? 0),
  }));

  const total = count ?? 0;
  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));

  return (
    <div className="space-y-8">
      <header className="flex items-end justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700">Administration</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Utilisateurs
          </h1>
          <p className="mt-2 text-slate-600">
            {total} compte{total > 1 ? "s" : ""}
            {q && ` correspondant à « ${q} »`} · gérez rôles, groupes,
            activité et accès.
          </p>
        </div>
        <div className="flex items-center gap-2">
          <a
            href="/api/admin/export/users"
            className="inline-flex items-center gap-2 h-9 px-3 rounded-lg border border-navy-200 bg-white text-sm text-navy-800 hover:bg-navy-50 transition"
            title="Télécharger un CSV de tous les utilisateurs"
          >
            <Download className="h-4 w-4" /> CSV
          </a>
          <Link href="/admin/users/new">
            <Button variant="gold">
              <UserPlus className="h-4 w-4" /> Nouveau stagiaire
            </Button>
          </Link>
        </div>
      </header>

      <UsersTable
        users={enriched}
        groups={groups ?? []}
        pagination={{
          page,
          pageSize: PAGE_SIZE,
          total,
          totalPages,
          q,
        }}
      />
    </div>
  );
}
