import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { UsersTable } from "./users-table";
import { Button } from "@/components/ui/button";
import { UserPlus, Crown, GraduationCap } from "lucide-react";
import { sanitizeSearchTerm } from "@/lib/search";

export const dynamic = "force-dynamic";

const PAGE_SIZE = 50;

export default async function AdminUsers(
  props: {
    searchParams?: Promise<{ page?: string; q?: string }>;
  }
) {
  const searchParams = await props.searchParams;
  const supabase = await createClient();

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
    const safe = sanitizeSearchTerm(q);
    if (safe)
      usersQuery = usersQuery.or(
        `email.ilike.%${safe}%,full_name.ilike.%${safe}%`
      );
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
          <p className="mt-2 text-slate-600 max-w-2xl">
            {total} compte{total > 1 ? "s" : ""}
            {q && ` correspondant à « ${q} »`} · pilotage RH : rôles,
            groupes, activité, accès. Pour inscrire un client à une
            formation, préférez{" "}
            <Link
              href="/admin/enrollments"
              className="text-brand-700 underline hover:text-brand-900"
            >
              Inscriptions & paiements
            </Link>
            .
          </p>
        </div>
        <div className="flex items-center gap-2 flex-wrap justify-end">
          <Link href="/admin/users/new-admin">
            <Button
              variant="secondary"
              size="sm"
              className="bg-amber-50 text-amber-700 border-amber-200 hover:bg-amber-100 hover:border-amber-300 hover:text-amber-800 dark:bg-amber-500/10 dark:text-amber-300 dark:border-amber-500/30 dark:hover:bg-amber-500/20 dark:hover:text-amber-200"
            >
              <Crown className="h-3.5 w-3.5" /> Admin
            </Button>
          </Link>
          <Link href="/admin/users/new-trainer">
            <Button
              variant="secondary"
              size="sm"
              className="bg-brand-50 text-brand-700 border-brand-200 hover:bg-brand-100 hover:border-brand-300 hover:text-brand-800 dark:bg-brand-500/10 dark:text-brand-300 dark:border-brand-500/30 dark:hover:bg-brand-500/20 dark:hover:text-brand-200"
            >
              <GraduationCap className="h-3.5 w-3.5" /> Formateur
            </Button>
          </Link>
          <Link href="/admin/users/new">
            <Button variant="gold">
              <UserPlus className="h-4 w-4" /> Stagiaire
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
