import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { isStaff } from "@/lib/permissions";
import { Card } from "@/components/ui/card";
import { Mail } from "lucide-react";
import { NewEmailButton } from "./new-email-button";
import { InboxTable } from "./inbox-table";
import type { Tables } from "@/lib/database.types";

export const dynamic = "force-dynamic";

type Tab = "inbox" | "sent" | "all";

/**
 * Ligne d'`email_log` telle qu'attendue par <InboxTable />.
 *
 * Les colonnes de la boîte de réception (`direction`, `from_name`, `labels`,
 * `assigned_to`, `read_at`) sont apportées par la migration
 * `supabase/2026_05_30_email_inbox.sql` et ne figurent pas encore dans
 * `Tables<"email_log">` (types générés avant application de la migration —
 * d'où le garde-fou `tableMissing` plus bas). On les déclare explicitement.
 */
type EmailRow = Pick<
  Tables<"email_log">,
  "id" | "sender_id" | "sender_email" | "subject" | "status" | "created_at" | "context" | "error"
> & {
  direction: "inbound" | "outbound";
  from_name: string | null;
  recipients: string[] | null;
  cc: string[] | null;
  bcc: string[] | null;
  body_html: string;
  labels: string[] | null;
  assigned_to: string | null;
  read_at: string | null;
};

/** Assignables : `select("id, full_name, email, role")` sur `profiles`. */
type AdminRow = Pick<Tables<"profiles">, "id" | "full_name" | "email" | "role">;
/** Ligne renvoyée par le `select("role")` sur `profiles`. */
type RoleRow = Pick<Tables<"profiles">, "role">;

export default async function EmailsPage(
  props: {
    searchParams?: Promise<{ tab?: string }>;
  }
) {
  const searchParams = await props.searchParams;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: meData } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  const me = meData as RoleRow | null;
  if (!isStaff(me?.role)) redirect("/dashboard");

  const tab: Tab = (["inbox", "sent", "all"] as Tab[]).includes(searchParams?.tab as Tab)
    ? (searchParams!.tab as Tab)
    : "inbox";

  const admin = createAdminClient();

  // Liste des assignables (admin / super-admin).
  const { data: admins } = await admin
    .from("profiles")
    .select("id, full_name, email, role")
    .in("role", ["admin", "super_admin"]);

  // Compteurs pour les onglets.
  const [{ count: inboxCount }, { count: unreadCount }, { count: sentCount }, { count: allCount }, listRes] = await Promise.all([
    admin.from("email_log").select("*", { count: "exact", head: true }).eq("direction", "inbound"),
    admin.from("email_log").select("*", { count: "exact", head: true }).eq("direction", "inbound").is("read_at", null),
    admin.from("email_log").select("*", { count: "exact", head: true }).eq("direction", "outbound"),
    admin.from("email_log").select("*", { count: "exact", head: true }),
    (() => {
      let q = admin.from("email_log").select("*").order("created_at", { ascending: false }).limit(200);
      if (tab === "inbox") q = q.eq("direction", "inbound");
      else if (tab === "sent") q = q.eq("direction", "outbound");
      return q;
    })(),
  ]);

  const tableMissing = !!listRes.error && /relation .* does not exist|email_log/i.test(listRes.error.message);
  const rows = (listRes.data ?? []) as EmailRow[];

  const tabs: { id: Tab; label: string; count: number | null; badge?: number }[] = [
    { id: "inbox", label: "Reçus", count: inboxCount ?? 0, badge: unreadCount ?? 0 },
    { id: "sent", label: "Envoyés", count: sentCount ?? 0 },
    { id: "all", label: "Tous", count: allCount ?? 0 },
  ];

  return (
    <div className="space-y-8">
      <header className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <span className="eyebrow text-gold-700">Communication</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight inline-flex items-center gap-2.5">
            <Mail className="h-7 w-7 text-brand-700" />
            Boîte de réception
          </h1>
          <p className="mt-2 text-slate-600 max-w-2xl">
            Suivi de vos communications email depuis la plateforme : reçus,
            envoyés et leurs statuts. Cliquez sur une ligne pour ouvrir le
            message, attribuer un responsable ou poser un libellé.
          </p>
        </div>
        <NewEmailButton />
      </header>

      {/* Onglets */}
      <div className="flex items-center gap-1 border-b border-navy-100">
        {tabs.map((t) => {
          const active = t.id === tab;
          return (
            <Link
              key={t.id}
              href={`/admin/emails?tab=${t.id}`}
              className={
                "relative px-4 py-2.5 text-sm font-medium transition-colors " +
                (active
                  ? "text-navy-950 border-b-2 border-navy-900 -mb-px"
                  : "text-slate-500 hover:text-navy-900")
              }
            >
              <span>{t.label}</span>
              <span className="ml-1.5 text-xs text-slate-400 tabular-nums">{t.count}</span>
              {t.badge && t.badge > 0 ? (
                <span className="ml-1.5 inline-flex h-4 min-w-[16px] items-center justify-center rounded-full bg-signal-500 px-1 text-[10px] font-bold text-night-900 tabular-nums">
                  {t.badge}
                </span>
              ) : null}
            </Link>
          );
        })}
      </div>

      {tableMissing ? (
        <Card>
          <div className="px-5 py-12 text-center text-sm text-slate-500">
            Appliquez les migrations{" "}
            <code className="font-mono text-navy-700">supabase/2026_05_29_email_log.sql</code>{" "}
            puis{" "}
            <code className="font-mono text-navy-700">supabase/2026_05_30_email_inbox.sql</code>{" "}
            pour activer la boîte de réception. L'envoi fonctionne déjà.
          </div>
        </Card>
      ) : (
        <InboxTable rows={rows} admins={(admins ?? []) as AdminRow[]} tab={tab} />
      )}
    </div>
  );
}
