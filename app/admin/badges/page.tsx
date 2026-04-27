import { createClient } from "@/lib/supabase/server";
import { BadgeEditor } from "./badge-editor";

export const dynamic = "force-dynamic";

export default async function AdminBadgesPage() {
  const supabase = createClient();
  const { data: badges } = await supabase
    .from("badges")
    .select("*")
    .order("order")
    .order("created_at");

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Gamification</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Catalogue de badges
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Gérez les badges débloqués automatiquement par les stagiaires selon
          leurs critères de progression.
        </p>
      </header>
      <BadgeEditor badges={badges || []} />
    </div>
  );
}
