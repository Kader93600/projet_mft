import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getAuthorizedFormationSlugs } from "@/lib/admin-guard";
import { SessionForm } from "../../session-form";
import { ChevronLeft } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function EditSessionPage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient();
  const { slugs, isStaff } = await getAuthorizedFormationSlugs();

  const { data: session } = await supabase
    .from("live_sessions")
    .select(
      `
        *,
        formation:formations!inner(slug)
      `
    )
    .eq("id", params.id)
    .single();

  if (!session) notFound();
  if (!isStaff && !slugs.includes((session.formation as any).slug)) {
    redirect("/admin/sessions");
  }

  let q = supabase
    .from("formations")
    .select("id, slug, title, code, category")
    .eq("active", true)
    .order("display_order");
  if (!isStaff) q = q.in("slug", slugs.length ? slugs : ["__none__"]);
  const { data: formations } = await q;

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
          href={`/admin/sessions/${params.id}`}
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
        formations={formations ?? []}
        trainers={trainers ?? []}
        sessionId={params.id}
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
