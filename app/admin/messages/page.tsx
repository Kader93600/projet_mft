import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { formatDate, initials } from "@/lib/utils";
import { MessagesInbox } from "./messages-inbox";
import { Inbox } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function AdminMessagesPage({
  searchParams,
}: {
  searchParams: { c?: string };
}) {
  const supabase = createClient();
  const {
    data: { user: admin },
  } = await supabase.auth.getUser();

  // Liste des conversations avec dernier message
  const { data: conversations } = await supabase
    .from("conversations")
    .select("id, user_id, admin_unread, last_message_at, profiles!conversations_user_id_fkey(full_name, email)")
    .order("last_message_at", { ascending: false });

  const selectedId = searchParams.c ?? conversations?.[0]?.id;

  let messages: any[] = [];
  let selected: any = null;
  if (selectedId) {
    const [{ data: msgs }, { data: conv }] = await Promise.all([
      supabase
        .from("messages")
        .select("*")
        .eq("conversation_id", selectedId)
        .order("created_at"),
      supabase
        .from("conversations")
        .select("id, user_id, profiles!conversations_user_id_fkey(full_name, email)")
        .eq("id", selectedId)
        .single(),
    ]);
    messages = msgs ?? [];
    selected = conv;
    if ((conv as any)?.id) {
      await supabase.rpc("mark_conversation_read", { p_conversation_id: (conv as any).id });
    }
  }

  return (
    <div className="space-y-6">
      <header className="flex items-center justify-between">
        <div>
          <span className="eyebrow text-gold-700">Communication</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Messagerie
          </h1>
        </div>
        <Badge tone="slate" size="sm">
          <Inbox className="h-3 w-3" /> {conversations?.length ?? 0} conversation
          {(conversations?.length ?? 0) > 1 ? "s" : ""}
        </Badge>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-[320px_1fr] gap-5">
        {/* Liste conversations */}
        <Card className="overflow-hidden">
          <div className="px-4 pt-4 pb-2 border-b border-navy-50">
            <CardTitle className="text-sm">Conversations</CardTitle>
          </div>
          <div className="divide-y divide-navy-50 max-h-[560px] overflow-y-auto">
            {(conversations ?? []).length === 0 && (
              <div className="px-4 py-10 text-center text-sm text-slate-400">
                Aucun message.
              </div>
            )}
            {(conversations ?? []).map((c: any) => {
              const active = c.id === selectedId;
              const name = c.profiles?.full_name || c.profiles?.email || "—";
              return (
                <Link
                  key={c.id}
                  href={`/admin/messages?c=${c.id}`}
                  className={
                    "block px-4 py-3 hover:bg-navy-50/50 transition " +
                    (active ? "bg-navy-50/70" : "")
                  }
                >
                  <div className="flex items-center gap-3">
                    <div className="h-9 w-9 rounded-full bg-navy-900 text-gold-400 flex items-center justify-center font-semibold text-[11px] shrink-0">
                      {initials(name)}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between gap-2">
                        <span className="font-medium text-sm text-navy-900 truncate">
                          {name}
                        </span>
                        {c.admin_unread > 0 && (
                          <span className="inline-flex items-center justify-center h-5 min-w-[20px] px-1.5 rounded-full bg-rose-500 text-white text-[10px] font-bold">
                            {c.admin_unread}
                          </span>
                        )}
                      </div>
                      <div className="text-xs text-slate-500 truncate">
                        {c.profiles?.email}
                      </div>
                      <div className="text-[10px] text-slate-400 mt-0.5">
                        {formatDate(c.last_message_at)}
                      </div>
                    </div>
                  </div>
                </Link>
              );
            })}
          </div>
        </Card>

        {/* Thread */}
        <Card className="overflow-hidden">
          {selected ? (
            <>
              <div className="px-6 py-3 border-b border-navy-50 flex items-center gap-3">
                <div className="h-9 w-9 rounded-full bg-navy-900 text-gold-400 flex items-center justify-center font-semibold text-[11px]">
                  {initials(
                    selected.profiles?.full_name || selected.profiles?.email
                  )}
                </div>
                <div>
                  <div className="font-semibold text-navy-900 text-sm">
                    {selected.profiles?.full_name || "—"}
                  </div>
                  <Link
                    href={`/admin/users/${selected.user_id}`}
                    className="text-xs text-slate-500 hover:text-navy-900"
                  >
                    {selected.profiles?.email} · Fiche complète →
                  </Link>
                </div>
              </div>
              <MessagesInbox
                conversationId={selected.id}
                messages={messages as any[]}
                adminId={admin?.id ?? ""}
              />
            </>
          ) : (
            <CardBody className="py-20 text-center text-sm text-slate-400">
              Sélectionnez une conversation pour commencer.
            </CardBody>
          )}
        </Card>
      </div>
    </div>
  );
}
