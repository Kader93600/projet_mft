import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { SessionForm } from "@/app/admin/sessions/session-form";
import { ChevronLeft } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function NewFormateurSessionPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // Formations habilitées pour ce formateur uniquement
  const { data: habs } = await supabase
    .from("trainer_formations")
    .select(
      "formation:formations!inner(id, slug, title, code, category, active)"
    )
    .eq("trainer_id", user.id);

  const formations = (habs ?? [])
    .map((h: any) => h.formation)
    .filter((f: any) => f?.active);

  // Liste des co-formateurs (mêmes formations habilitées)
  const formationIds = formations.map((f: any) => f.id);
  let trainers: any[] = [];
  if (formationIds.length > 0) {
    const { data } = await supabase
      .from("trainer_formations")
      .select("trainer:profiles!inner(id, full_name, email, disabled)")
      .in("formation_id", formationIds);
    const seen = new Set<string>();
    trainers = (data ?? [])
      .map((d: any) => d.trainer)
      .filter((t: any) => t && !t.disabled && !seen.has(t.id) && seen.add(t.id));
  }

  return (
    <div className="space-y-8 max-w-3xl">
      <div>
        <Link
          href="/formateur/sessions"
          className="inline-flex items-center gap-1 text-sm text-slate-600 hover:text-navy-900 transition"
        >
          <ChevronLeft className="h-4 w-4" />
          Retour aux sessions
        </Link>
        <h1 className="mt-3 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Planifier une nouvelle session
        </h1>
        <p className="mt-2 text-slate-600">
          Présentielle, distancielle (Zoom / Teams / Meet) ou hybride.
          Émargement Qualiopi automatique pour les stagiaires Premium.
        </p>
      </div>

      <SessionForm
        formations={formations}
        trainers={trainers}
        basePath="/formateur/sessions"
      />
    </div>
  );
}
