import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { SessionForm } from "@/app/admin/sessions/session-form";
import { ChevronLeft } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function EditFormateurSessionPage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: session } = await supabase
    .from("live_sessions")
    .select(
      `
        *,
        formation:formations!inner(id, slug)
      `
    )
    .eq("id", params.id)
    .single();

  if (!session) notFound();

  // Vérif habilitation
  const { data: hab } = await supabase
    .from("trainer_formations")
    .select("trainer_id")
    .eq("trainer_id", user.id)
    .eq("formation_id", (session.formation as any).id)
    .maybeSingle();
  if (!hab) {
    const { data: me } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();
    if (me?.role !== "admin" && me?.role !== "super_admin") {
      redirect("/formateur/sessions");
    }
  }

  // Formations habilitées pour ce formateur
  const { data: habs } = await supabase
    .from("trainer_formations")
    .select(
      "formation:formations!inner(id, slug, title, code, category, active)"
    )
    .eq("trainer_id", user.id);
  const formations = (habs ?? [])
    .map((h: any) => h.formation)
    .filter((f: any) => f?.active);

  // Co-formateurs
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
          href={`/formateur/sessions/${params.id}`}
          className="inline-flex items-center gap-1 text-sm text-slate-600 hover:text-navy-900 transition"
        >
          <ChevronLeft className="h-4 w-4" />
          Retour à la session
        </Link>
        <h1 className="mt-3 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Modifier la session
        </h1>
      </div>

      <SessionForm
        formations={formations}
        trainers={trainers}
        sessionId={params.id}
        basePath="/formateur/sessions"
        initial={{
          title: session.title,
          description: session.description,
          formation_id: session.formation_id,
          kind: session.kind,
          start_at: session.start_at,
          end_at: session.end_at,
          location: session.location,
          meeting_provider: session.meeting_provider,
          meeting_url: session.meeting_url,
          meeting_password: session.meeting_password,
          max_participants: session.max_participants,
          trainer_id: session.trainer_id,
          notes_internal: session.notes_internal,
        }}
      />
    </div>
  );
}
