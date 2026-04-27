import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { formatDate } from "@/lib/utils";
import { MarkAllReadButton } from "./mark-all-button";
import {
  Megaphone,
  MessageCircle,
  ClipboardCheck,
  Info,
  Bell,
} from "lucide-react";

export const dynamic = "force-dynamic";

const ICONS: any = {
  announcement: Megaphone,
  message: MessageCircle,
  quiz_result: ClipboardCheck,
  system: Info,
};

const TONE: any = {
  announcement: "bg-gold-50 text-gold-700 border-gold-200",
  message: "bg-navy-50 text-navy-700 border-navy-100",
  quiz_result: "bg-emerald-50 text-emerald-700 border-emerald-200",
  system: "bg-slate-50 text-slate-700 border-slate-200",
};

export default async function NotificationsPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: notifs } = await supabase
    .from("notifications")
    .select("*")
    .eq("user_id", user.id)
    .order("created_at", { ascending: false })
    .limit(100);

  const unread = (notifs ?? []).filter((n) => !n.read_at).length;

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <header className="flex items-start justify-between">
        <div>
          <div className="flex items-center gap-2">
            <Bell className="h-4 w-4 text-gold-700" />
            <span className="eyebrow text-gold-700">Boîte de réception</span>
          </div>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Notifications
          </h1>
          <p className="mt-2 text-slate-600 text-sm">
            {unread > 0
              ? `${unread} non lue${unread > 1 ? "s" : ""}`
              : "Tout est à jour."}
          </p>
        </div>
        {unread > 0 && <MarkAllReadButton />}
      </header>

      {(notifs ?? []).length === 0 ? (
        <Card>
          <CardBody className="py-16 text-center">
            <Bell className="h-8 w-8 text-slate-300 mx-auto" />
            <p className="mt-4 text-slate-500 text-sm">
              Vous n'avez pas encore reçu de notification.
            </p>
          </CardBody>
        </Card>
      ) : (
        <Card>
          <div className="divide-y divide-navy-50">
            {(notifs ?? []).map((n: any) => {
              const Icon = ICONS[n.type] ?? Info;
              const tone = TONE[n.type] ?? TONE.system;
              const unread = !n.read_at;
              const inner = (
                <div
                  className={
                    "flex items-start gap-3 px-5 py-4 transition " +
                    (unread ? "bg-gold-50/20" : "")
                  }
                >
                  <div
                    className={
                      "h-9 w-9 rounded-xl border flex items-center justify-center shrink-0 " +
                      tone
                    }
                  >
                    <Icon className="h-4 w-4" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <div className="font-semibold text-navy-900 text-sm truncate">
                        {n.title}
                      </div>
                      {unread && (
                        <span className="h-2 w-2 rounded-full bg-rose-500 shrink-0" />
                      )}
                    </div>
                    {n.body && (
                      <div className="text-sm text-slate-600 mt-0.5 line-clamp-2">
                        {n.body}
                      </div>
                    )}
                    <div className="text-xs text-slate-400 mt-1">
                      {formatDate(n.created_at)}
                    </div>
                  </div>
                </div>
              );
              return n.link_url ? (
                <Link
                  key={n.id}
                  href={n.link_url}
                  className="block hover:bg-navy-50/40"
                >
                  {inner}
                </Link>
              ) : (
                <div key={n.id}>{inner}</div>
              );
            })}
          </div>
        </Card>
      )}
    </div>
  );
}
