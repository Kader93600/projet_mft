import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { getAuthorizedFormationSlugs } from "@/lib/admin-guard";
import { SessionForm } from "../session-form";
import { ChevronLeft } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function NewSessionPage() {
  const supabase = createClient();
  const { slugs, isStaff } = await getAuthorizedFormationSlugs();

  // Formations accessibles (staff = toutes, trainer = ses formations)
  let q = supabase
    .from("formations")
    .select("id, slug, title, code, category")
    .eq("active", true)
    .order("display_order");
  if (!isStaff) q = q.in("slug", slugs.length ? slugs : ["__none__"]);
  const { data: formations } = await q;

  // Liste des formateurs (admin uniquement)
  const { data: trainers } = await supabase
    .from("profiles")
    .select("id, full_name, email")
    .in("role", ["trainer", "admin", "super_admin"])
    .eq("disabled", false)
    .order("full_name");

  return (
    <div className="space-y-8 max-w-3xl">
      <div>
        <Link
          href="/admin/sessions"
          className="inline-flex items-center gap-1 text-sm text-slate-600 hover:text-navy-900 transition"
        >
          <ChevronLeft className="h-4 w-4" />
          Retour aux sessions
        </Link>
        <h1 className="mt-3 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Planifier une nouvelle session
        </h1>
        <p className="mt-2 text-slate-600">
          Une session présentielle, distancielle (Zoom / Teams / Meet) ou
          hybride. Émargement Qualiopi automatique pour les Premium.
        </p>
      </div>

      <SessionForm
        formations={formations ?? []}
        trainers={trainers ?? []}
      />
    </div>
  );
}
