import Link from "next/link";
import { redirect, notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card } from "@/components/ui/card";
import { MessageThread } from "@/components/message-thread";
import { FormationBadge } from "@/components/formation/formation-badge";
import { FormationStripe } from "@/components/formation/formation-stripe";
import { ArrowLeft } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function TrainerThreadPage({
  params,
}: {
  params: { conversationId: string };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();
  if (!profile || !["trainer", "admin", "super_admin"].includes(profile.role)) {
    redirect("/dashboard");
  }

  const { data: conv } = await supabase
    .from("conversations")
    .select("id, user_id")
    .eq("id", params.conversationId)
    .single();
  if (!conv) notFound();

  const [{ data: student }, { data: enrollments }, { data: messages }] =
    await Promise.all([
      supabase
        .from("profiles")
        .select("full_name, email")
        .eq("id", conv.user_id)
        .single(),
      supabase
        .from("enrollments")
        .select("formation_slug")
        .eq("user_id", conv.user_id),
      supabase
        .from("messages")
        .select("id, sender_id, sender_role, body, created_at, read_at")
        .eq("conversation_id", params.conversationId)
        .order("created_at"),
    ]);

  // Marque les messages stagiaire comme lus
  await supabase.rpc("mark_conversation_read", {
    p_conversation_id: params.conversationId,
  });

  const formationSlug =
    (enrollments ?? []).find((e: any) => e.formation_slug)?.formation_slug ??
    null;

  return (
    <div className="max-w-3xl mx-auto">
      {formationSlug && <FormationStripe slug={formationSlug} />}

      <div className="space-y-4 pt-6">
        <Link
          href="/formateur/messages"
          className="inline-flex items-center gap-1 text-sm text-slate-500 hover:text-navy-900"
        >
          <ArrowLeft className="h-3.5 w-3.5" />
          Retour à la messagerie
        </Link>

        <header className="flex items-center gap-3">
          <div className="h-12 w-12 rounded-full bg-navy-50 flex items-center justify-center text-navy-700 font-semibold">
            {(student?.full_name ?? student?.email ?? "?")
              .slice(0, 1)
              .toUpperCase()}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2">
              <h1 className="font-display text-xl font-semibold text-navy-950 truncate">
                {student?.full_name ?? student?.email ?? "Stagiaire"}
              </h1>
              {formationSlug && (
                <FormationBadge
                  slug={formationSlug}
                  size="sm"
                  icon
                  variant="soft"
                />
              )}
            </div>
            <div className="text-xs text-slate-500">{student?.email}</div>
          </div>
        </header>

        <Card className="overflow-hidden">
          <MessageThread
            conversationId={params.conversationId}
            messages={(messages ?? []) as any[]}
            viewerRole="trainer"
            viewerId={user.id}
          />
        </Card>
      </div>
    </div>
  );
}
