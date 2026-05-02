import { createClient } from "@/lib/supabase/server";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { formatDate } from "@/lib/utils";
import { Shield } from "lucide-react";

export const dynamic = "force-dynamic";

const ACTION_LABELS: Record<string, { label: string; tone: string }> = {
  create_module: { label: "Module créé", tone: "success" },
  update_module: { label: "Module modifié", tone: "navy" },
  delete_module: { label: "Module supprimé", tone: "slate" },
  create_lesson: { label: "Leçon créée", tone: "success" },
  update_lesson: { label: "Leçon modifiée", tone: "navy" },
  delete_lesson: { label: "Leçon supprimée", tone: "slate" },
  create_quiz: { label: "Quiz créé", tone: "success" },
  update_quiz: { label: "Quiz modifié", tone: "navy" },
  delete_quiz: { label: "Quiz supprimé", tone: "slate" },
  create_question: { label: "Question créée", tone: "success" },
  update_question: { label: "Question modifiée", tone: "navy" },
  delete_question: { label: "Question supprimée", tone: "slate" },
  set_choices: { label: "Réponses modifiées", tone: "navy" },
  create_group: { label: "Classe créée", tone: "success" },
  update_group: { label: "Classe modifiée", tone: "navy" },
  delete_group: { label: "Classe supprimée", tone: "slate" },
  assign_group: { label: "Stagiaire assigné", tone: "navy" },
  bulk_assign_group: { label: "Assignation en masse", tone: "navy" },
  update_profile: { label: "Profil modifié", tone: "navy" },
  delete_user: { label: "Compte supprimé", tone: "slate" },
  reset_user_results: { label: "Résultats réinitialisés", tone: "gold" },
  reset_quiz_results: { label: "Quiz réinitialisé", tone: "gold" },
  reset_all_results: { label: "Reset global", tone: "slate" },
  delete_attempt: { label: "Tentative supprimée", tone: "slate" },
  upload_media: { label: "Fichier uploadé", tone: "navy" },
};

export default async function AuditLogPage() {
  const supabase = createClient();
  const { data: logs } = await supabase
    .from("audit_log")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(200);

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Administration</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Journal d'audit
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Traçabilité des 200 dernières actions sensibles. Conservez ces données
          au moins 5 ans (obligation Qualiopi).
        </p>
      </header>

      <Card>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                <th className="text-left px-5 py-3 font-semibold">Date</th>
                <th className="text-left px-5 py-3 font-semibold">Auteur</th>
                <th className="text-left px-5 py-3 font-semibold">Action</th>
                <th className="text-left px-5 py-3 font-semibold">Cible</th>
                <th className="text-left px-5 py-3 font-semibold">Détails</th>
              </tr>
            </thead>
            <tbody>
              {(logs ?? []).map((log: any) => {
                const a = ACTION_LABELS[log.action] ?? {
                  label: log.action,
                  tone: "slate",
                };
                return (
                  <tr key={log.id} className="border-t border-navy-50">
                    <td className="px-5 py-3 text-xs text-slate-500 whitespace-nowrap">
                      {formatDate(log.created_at)}
                    </td>
                    <td className="px-5 py-3">
                      <div className="text-sm font-medium text-navy-900">
                        {log.actor_email ?? "—"}
                      </div>
                    </td>
                    <td className="px-5 py-3">
                      <Badge tone={a.tone as any} size="sm">
                        {a.label}
                      </Badge>
                    </td>
                    <td className="px-5 py-3 text-xs">
                      <span className="text-slate-500">{log.target_type}</span>
                      {log.target_id && (
                        <span className="font-mono text-slate-400 ml-1">
                          #{log.target_id.slice(0, 8)}
                        </span>
                      )}
                    </td>
                    <td className="px-5 py-3 text-xs text-slate-500 max-w-xs truncate">
                      {log.metadata
                        ? JSON.stringify(log.metadata)
                        : <span className="text-slate-300">—</span>}
                    </td>
                  </tr>
                );
              })}
              {(!logs || logs.length === 0) && (
                <tr>
                  <td colSpan={5} className="px-5 py-16 text-center text-slate-400">
                    <Shield className="h-8 w-8 mx-auto mb-2 text-slate-300" />
                    Aucune entrée. Les actions sensibles apparaîtront ici.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
