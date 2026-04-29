import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card } from "@/components/ui/card";
import { FormationBadge } from "@/components/formation/formation-badge";
import { MessageCircle, ChevronRight } from "lucide-react";

export const dynamic = "force-dynamic";

type Row = {
  conversation_id: string;
  student_id: string;
  student_name: string | null;
  student_email: string | null;
  formation_slug: string | null;
  last_message_at: string;
  admin_unread: number;
  last_message_preview: string | null;
};

export default async function TrainerMessagesPage() {
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

  const { data, error } = await supabase.rpc("list_trainer_conversations");
  const rows: Row[] = (data as Row[]) ?? [];

  const totalUnread = rows.reduce((s, r) => s + (r.admin_unread || 0), 0);

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <header>
        <div className="flex items-center gap-2">
          <MessageCircle className="h-4 w-4 text-gold-700" />
          <span className="eyebrow text-gold-700">Espace formateur</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Messagerie stagiaires
        </h1>
        <p className="mt-2 text-slate-600">
          {rows.length} conversation{rows.length > 1 ? "s" : ""}
          {totalUnread > 0 && (
            <span className="ml-2 inline-flex items-center gap-1 rounded-full bg-rose-100 text-rose-700 px-2 py-0.5 text-xs font-medium">
              {totalUnread} non lu{totalUnread > 1 ? "s" : ""}
            </span>
          )}
        </p>
      </header>

      {error && (
        <div className="rounded-xl bg-rose-50 border border-rose-200 px-4 py-3 text-sm text-rose-700">
          Erreur de chargement : {error.message}
        </div>
      )}

      <Card>
        {rows.length === 0 ? (
          <div className="px-5 py-12 text-center text-slate-400 text-sm">
            Aucune conversation. Dès qu'un stagiaire de l'une de vos formations
            vous écrira, la conversation apparaîtra ici.
          </div>
        ) : (
          <ul className="divide-y divide-navy-50">
            {rows.map((r) => {
              const unread = r.admin_unread > 0;
              return (
                <li key={r.conversation_id}>
                  <Link
                    href={`/formateur/messages/${r.conversation_id}`}
                    className="flex items-center gap-4 px-5 py-4 hover:bg-navy-50/40 transition group"
                  >
                    <div
                      className={
                        "h-10 w-10 rounded-full flex items-center justify-center text-sm font-semibold shrink-0 " +
                        (unread
                          ? "bg-navy-900 text-white"
                          : "bg-navy-50 text-navy-700")
                      }
                    >
                      {(r.student_name ?? r.student_email ?? "?")
                        .slice(0, 1)
                        .toUpperCase()}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="font-medium text-navy-900 truncate">
                          {r.student_name ?? r.student_email ?? "Stagiaire"}
                        </span>
                        {r.formation_slug && (
                          <FormationBadge
                            slug={r.formation_slug}
                            size="xs"
                            icon
                            variant="soft"
                          />
                        )}
                        {unread && (
                          <span className="ml-auto inline-flex items-center justify-center rounded-full bg-rose-500 text-white text-[10px] font-bold h-5 min-w-5 px-1.5">
                            {r.admin_unread}
                          </span>
                        )}
                      </div>
                      <div className="mt-0.5 text-xs text-slate-500 truncate">
                        {r.last_message_preview ?? "—"}
                      </div>
                    </div>
                    <div className="text-[11px] text-slate-400 shrink-0">
                      {new Date(r.last_message_at).toLocaleString("fr-FR", {
                        day: "2-digit",
                        month: "short",
                        hour: "2-digit",
                        minute: "2-digit",
                      })}
                    </div>
                    <ChevronRight className="h-4 w-4 text-slate-300 group-hover:text-gold-700" />
                  </Link>
                </li>
              );
            })}
          </ul>
        )}
      </Card>
    </div>
  );
}
