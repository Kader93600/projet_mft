import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import type { Json, Tables } from "@/lib/database.types";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { formatDateTime } from "@/lib/utils";
import { findFormation } from "@/lib/formations-config";
import { Shield } from "lucide-react";

export const dynamic = "force-dynamic";

// ── Libellés d'action (FR), lisibles par tous les admins ───────────────
const ACTION_LABELS: Record<string, string> = {
  // Pédagogie
  create_module: "Cours créé", update_module: "Cours modifié", delete_module: "Cours supprimé",
  create_lesson: "Leçon créée", update_lesson: "Leçon modifiée", delete_lesson: "Leçon supprimée",
  create_lesson_resource: "Ressource ajoutée", update_lesson_resource: "Ressource modifiée", delete_lesson_resource: "Ressource supprimée",
  create_quiz: "Exercice créé", update_quiz: "Exercice modifié", delete_quiz: "Exercice supprimé",
  create_question: "Question créée", update_question: "Question modifiée", delete_question: "Question supprimée",
  set_choices: "Réponses modifiées",
  create_qcm_question: "Question QCM créée", create_qr_question: "Question rédigée créée",
  attach_bank_question: "Question rattachée", detach_bank_question: "Question détachée", set_bank_questions: "Questions du quiz définies",
  create_placement_question: "Question de positionnement créée", update_placement_question: "Question de positionnement modifiée",
  delete_placement_question: "Question de positionnement supprimée", toggle_placement_question: "Question de positionnement (dé)activée",
  create_glossary_term: "Terme de glossaire créé", update_glossary_term: "Terme modifié", delete_glossary_term: "Terme supprimé",
  ai_generate_questions: "Questions générées (IA)",
  // Utilisateurs & classes
  create_student: "Stagiaire créé", create_trainer: "Formateur créé", create_admin: "Administrateur créé",
  update_profile: "Profil modifié", delete_user: "Compte supprimé",
  assign_group: "Affecté à une classe", bulk_assign_group: "Affectation en masse",
  assign_referent: "Référent assigné",
  create_group: "Classe créée", update_group: "Classe modifiée", delete_group: "Classe supprimée",
  reset_user_results: "Résultats réinitialisés", reset_quiz_results: "Quiz réinitialisé", reset_all_results: "Réinitialisation globale",
  delete_attempt: "Tentative supprimée", recompute_achievements_all: "Recalcul des badges",
  send_inactivity_reminder: "Relance inactivité",
  // Inscriptions / commercial
  enrollment_create: "Dossier créé", enrollment_update: "Dossier modifié",
  enrollment_delete: "Dossier supprimé", enrollment_status: "Statut dossier",
  payment_upsert: "Paiement enregistré", payment_delete: "Paiement supprimé",
  lead_status: "Statut prospect", lead_delete: "Prospect supprimé",
  funder_create: "Financeur créé", funder_update: "Financeur modifié", funder_delete: "Financeur supprimé",
  // Conformité / signatures / documents
  relance_signature: "Relance de signature",
  create_document: "Document d'accueil créé", update_document: "Document d'accueil modifié", delete_document: "Document d'accueil supprimé",
  update_formation_settings: "Paramètres formation",
  // Communication
  create_announcement: "Annonce créée", update_announcement: "Annonce modifiée",
  delete_announcement: "Annonce supprimée", publish_announcement: "Annonce publiée",
  create_badge: "Badge créé", update_badge: "Badge modifié", delete_badge: "Badge supprimé",
  create_coaching_note: "Note d'accompagnement créée", update_coaching_note: "Note modifiée", delete_coaching_note: "Note supprimée",
  create_coaching_session: "Séance d'accompagnement créée", update_coaching_session: "Séance modifiée", delete_coaching_session: "Séance supprimée",
  // Fichiers
  upload_media: "Fichier importé", delete_media: "Fichier supprimé",
};

function actionLabel(a: string): string {
  return ACTION_LABELS[a] ?? a.replace(/_/g, " ");
}
function actionTone(a: string): "success" | "navy" | "rose" | "gold" | "slate" {
  if (a.startsWith("delete_") || a.endsWith("_delete")) return "rose";
  if (a.startsWith("create_") || a === "enrollment_create" || a === "payment_upsert") return "success";
  if (a.endsWith("_status") || a.startsWith("reset_") || a.startsWith("relance") || a.startsWith("send_") || a.startsWith("recompute") || a === "ai_generate_questions") return "gold";
  if (a === "system") return "slate";
  return "navy";
}

// ── Type de cible (FR) ─────────────────────────────────────────────────
const TYPE_LABELS: Record<string, string> = {
  profile: "Compte utilisateur",
  enrollment: "Dossier d'inscription",
  enrollment_request: "Prospect (demande)",
  payment: "Paiement",
  funder: "Financeur",
  module: "Cours",
  lesson: "Leçon",
  lesson_resource: "Ressource de leçon",
  quiz: "Exercice / examen",
  question: "Question",
  question_bank: "Question (banque)",
  group: "Classe",
  announcement: "Annonce",
  badge: "Badge",
  coaching_note: "Note d'accompagnement",
  coaching_session: "Séance d'accompagnement",
  glossary_term: "Terme de glossaire",
  onboarding_document: "Document d'accueil",
  placement_question: "Question de positionnement",
  formation_settings: "Paramètres de formation",
  file: "Fichier",
  system: "Système",
};

const PACK_LABELS: Record<string, string> = { initial: "Initial", medium: "Medium", premium: "Premium" };
const STATUS_LABELS: Record<string, string> = {
  nouveau: "Nouveau", contacte: "Contacté", devis_envoye: "Devis envoyé", inscrit: "Inscrit", refuse: "Refusé",
  prospect: "Demande reçue", devis: "Devis envoyé", accord_financeur: "Accord financeur",
  a_payer: "Paiement à effectuer", en_cours: "Formation en cours", termine: "Formation terminée", abandon: "Abandon",
};
const ACCESS_LABELS: Record<string, string> = { invite: "invitation par e-mail", password: "mot de passe défini" };
/** Les valeurs viennent de `audit_log.metadata` (jsonb) → `Json`. */
type JsonValue = Json | undefined;
const pack = (v: JsonValue) => PACK_LABELS[String(v)] ?? String(v);
const status = (v: JsonValue) => STATUS_LABELS[String(v)] ?? String(v);
const formation = (v: JsonValue) => findFormation(String(v))?.code ?? String(v);

// ── Métadonnées JSON → phrase lisible ──────────────────────────────────
function humanizeDetails(action: string, metadata: Json | null): string | null {
  if (!metadata || typeof metadata !== "object" || Array.isArray(metadata) || Object.keys(metadata).length === 0) return null;
  // Après ces gardes, `metadata` est bien l'objet JSON de la métadonnée.
  const m = metadata;

  if (action === "enrollment_update") {
    if (m.pack_changed) return `Pack modifié : ${pack(m.previous_pack)} → ${pack(m.new_pack)}`;
    return "Mise à jour du dossier (pack inchangé)";
  }
  if (action === "lead_status" || action === "enrollment_status") {
    return `Nouveau statut : ${status(m.status)}`;
  }
  if (action === "create_student" || action === "create_trainer" || action === "create_admin") {
    const parts: string[] = [];
    if (m.email) parts.push(String(m.email));
    if (m.formation_slug) parts.push(`Formation : ${formation(m.formation_slug)}`);
    if (m.access_mode) parts.push(`Accès : ${ACCESS_LABELS[String(m.access_mode)] ?? m.access_mode}`);
    return parts.join(" · ") || null;
  }
  if (action === "funder_create" && m.name) return `Financeur : ${m.name}`;

  // Rendu générique : clés connues traduites, valeurs lisibles.
  const KEY: Record<string, string> = {
    status: "Statut", email: "E-mail", name: "Nom", title: "Titre", formation_slug: "Formation",
    access_mode: "Accès", pack: "Pack", new_pack: "Nouveau pack", count: "Nombre", role: "Rôle",
    group_id: "Classe", reason: "Motif", type: "Type", difficulty: "Difficulté",
  };
  const parts: string[] = [];
  for (const [k, v] of Object.entries(m)) {
    if (v === null || v === undefined || v === "" || v === false) continue;
    if (typeof v === "object") continue;
    let val: string = String(v);
    if (k === "status") val = status(v);
    else if (k === "access_mode") val = ACCESS_LABELS[String(v)] ?? val;
    else if (k === "pack" || k === "new_pack" || k === "previous_pack") val = pack(v);
    else if (k === "formation_slug") val = formation(v);
    else if (typeof v === "boolean") val = v ? "oui" : "non";
    const label = KEY[k];
    if (label) parts.push(`${label} : ${val}`);
    else if (typeof v === "string" && v.length < 40) parts.push(val);
  }
  return parts.length ? parts.slice(0, 4).join(" · ") : null;
}

// ── Types des lignes lues (dérivés des `select` ci-dessous) ────────────
type AuditRow = Tables<"audit_log">;
type ProfileRow = Pick<Tables<"profiles">, "id" | "full_name" | "email">;
type EnrollmentRow = Pick<Tables<"enrollments">, "id"> & {
  user: Pick<Tables<"profiles">, "full_name" | "email"> | null;
};
type LeadRow = Pick<Tables<"enrollment_requests">, "id" | "full_name" | "email">;

export default async function AuditLogPage() {
  const supabase = await createClient();
  const { data: logs } = await supabase
    .from("audit_log")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(200);

  const rows = (logs ?? []) as AuditRow[];

  // ── Résolution des cibles en noms lisibles (lecture service-role :
  //    page déjà réservée au staff). Requêtes batchées, pas de N+1. ──────
  const idsByType: Record<string, Set<string>> = { profile: new Set(), enrollment: new Set(), enrollment_request: new Set() };
  for (const l of rows) {
    if (l.target_id && l.target_type && idsByType[l.target_type]) idsByType[l.target_type].add(l.target_id);
  }
  const admin = createAdminClient();
  const pIds = [...idsByType.profile], eIds = [...idsByType.enrollment], rIds = [...idsByType.enrollment_request];
  const [profRes, enrRes, leadRes] = await Promise.all([
    pIds.length ? admin.from("profiles").select("id, full_name, email").in("id", pIds) : Promise.resolve({ data: [] as ProfileRow[] }),
    eIds.length ? admin.from("enrollments").select("id, user:profiles!user_id(full_name, email)").in("id", eIds) : Promise.resolve({ data: [] as EnrollmentRow[] }),
    rIds.length ? admin.from("enrollment_requests").select("id, full_name, email").in("id", rIds) : Promise.resolve({ data: [] as LeadRow[] }),
  ]);
  const profileMap = new Map<string, string>();
  ((profRes.data ?? []) as ProfileRow[]).forEach((p) => profileMap.set(p.id, p.full_name || p.email));
  const enrollMap = new Map<string, string>();
  ((enrRes.data ?? []) as EnrollmentRow[]).forEach((e) => enrollMap.set(e.id, e.user?.full_name || e.user?.email || ""));
  const leadMap = new Map<string, string>();
  ((leadRes.data ?? []) as LeadRow[]).forEach((r) => leadMap.set(r.id, r.full_name || r.email));

  function resolveName(l: AuditRow): string | null {
    if (!l.target_id) return null;
    if (l.target_type === "profile") return profileMap.get(l.target_id) || null;
    if (l.target_type === "enrollment") return enrollMap.get(l.target_id) || null;
    if (l.target_type === "enrollment_request") return leadMap.get(l.target_id) || null;
    return null;
  }

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
              {rows.map((log) => {
                const name = resolveName(log);
                const typeLabel = (log.target_type ? TYPE_LABELS[log.target_type] : null) ?? log.target_type ?? "—";
                const detail = humanizeDetails(log.action, log.metadata);
                return (
                  <tr key={log.id} className="border-t border-navy-50">
                    <td className="px-5 py-3 text-xs text-slate-500 whitespace-nowrap">
                      {formatDateTime(log.created_at)}
                    </td>
                    <td className="px-5 py-3">
                      <div className="text-sm font-medium text-navy-900">
                        {log.actor_email ?? "—"}
                      </div>
                    </td>
                    <td className="px-5 py-3">
                      <Badge tone={actionTone(log.action)} size="sm">
                        {actionLabel(log.action)}
                      </Badge>
                    </td>
                    <td className="px-5 py-3">
                      {name ? (
                        <>
                          <div className="text-sm text-navy-900">{name}</div>
                          <div className="text-[11px] text-slate-400">{typeLabel}</div>
                        </>
                      ) : (
                        <span className="text-sm text-slate-600">{typeLabel}</span>
                      )}
                    </td>
                    <td className="px-5 py-3 text-xs text-slate-600 max-w-sm">
                      {detail ?? <span className="text-slate-300">—</span>}
                    </td>
                  </tr>
                );
              })}
              {rows.length === 0 && (
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
