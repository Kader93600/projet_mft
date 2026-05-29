import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { isStaff } from "@/lib/permissions";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { formatDateTime } from "@/lib/utils";
import { Mail, Paperclip } from "lucide-react";
import { NewEmailButton } from "./new-email-button";

export const dynamic = "force-dynamic";

const STATUS: Record<string, { label: string; tone: "success" | "rose" | "gold" | "slate" }> = {
  sent: { label: "Envoyé", tone: "success" },
  error: { label: "Erreur", tone: "rose" },
  queued: { label: "En file", tone: "gold" },
  opened: { label: "Lu", tone: "success" },
};

export default async function EmailsHistoryPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: me } = await supabase.from("profiles").select("role").eq("id", user.id).maybeSingle();
  if (!isStaff((me as any)?.role)) redirect("/dashboard");

  const admin = createAdminClient();
  const { data: logs, error } = await admin
    .from("email_log")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(200);

  const rows = (logs ?? []) as any[];
  const tableMissing = !!error && /relation .* does not exist|email_log/i.test(error.message);

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
            Suivi de vos communications email depuis la plateforme : historique
            des envois et leur statut. Cliquez sur une icône « email » dans les
            listes pour écrire à un stagiaire, un prospect ou un utilisateur.
          </p>
        </div>
        <NewEmailButton />
      </header>

      {tableMissing ? (
        <Card>
          <div className="px-5 py-12 text-center text-sm text-slate-500">
            La table <code className="font-mono text-navy-700">email_log</code> n'existe pas encore.
            Appliquez la migration <code className="font-mono text-navy-700">supabase/2026_05_29_email_log.sql</code>{" "}
            pour activer l'historique. L'envoi d'emails fonctionne déjà.
          </div>
        </Card>
      ) : (
        <Card>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                  <th className="text-left px-5 py-3 font-semibold">Date</th>
                  <th className="text-left px-5 py-3 font-semibold">Expéditeur</th>
                  <th className="text-left px-5 py-3 font-semibold">Destinataires</th>
                  <th className="text-left px-5 py-3 font-semibold">Objet</th>
                  <th className="text-left px-5 py-3 font-semibold">Statut</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((l) => {
                  const st = STATUS[l.status] ?? { label: l.status, tone: "slate" as const };
                  const recipients: string[] = l.recipients ?? [];
                  const nbAtt = Array.isArray(l.attachments_meta) ? l.attachments_meta.length : 0;
                  return (
                    <tr key={l.id} className="border-t border-navy-50">
                      <td className="px-5 py-3 text-xs text-slate-500 whitespace-nowrap">
                        {formatDateTime(l.created_at)}
                      </td>
                      <td className="px-5 py-3 text-xs text-slate-600">{l.sender_email ?? "—"}</td>
                      <td className="px-5 py-3 text-sm text-navy-900">
                        {recipients[0] ?? "—"}
                        {recipients.length > 1 && (
                          <span className="text-xs text-slate-400"> +{recipients.length - 1}</span>
                        )}
                      </td>
                      <td className="px-5 py-3 text-sm text-navy-900 max-w-xs truncate">
                        <span className="inline-flex items-center gap-1.5">
                          {nbAtt > 0 && <Paperclip className="h-3 w-3 text-slate-400" />}
                          {l.subject || <span className="text-slate-400 italic">(sans objet)</span>}
                        </span>
                      </td>
                      <td className="px-5 py-3">
                        <Badge tone={st.tone} size="sm">{st.label}</Badge>
                      </td>
                    </tr>
                  );
                })}
                {rows.length === 0 && (
                  <tr>
                    <td colSpan={5} className="px-5 py-16 text-center text-slate-400">
                      <Mail className="h-8 w-8 mx-auto mb-2 text-slate-300" />
                      Aucun email pour le moment.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </Card>
      )}
    </div>
  );
}
