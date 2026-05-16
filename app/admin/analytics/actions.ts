"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import { uuid } from "@/lib/validations";
import { sendEmail } from "@/lib/email";
import { LEGAL } from "@/lib/legal-config";

export async function deleteAttempt(id: string) {
  const { supabase } = await requireAdmin();
  validate(uuid, id);
  // Le trigger SQL log_attempt_deletion alimente audit_log automatiquement
  const { error } = await supabase.from("quiz_attempts").delete().eq("id", id);
  if (error) throw new Error(error.message);
  revalidatePath("/admin/analytics");
  return { ok: true };
}

export async function resetQuizResults(quizId: string) {
  const { supabase } = await requireAdmin();
  validate(uuid, quizId);
  const { error } = await supabase
    .from("quiz_attempts")
    .delete()
    .eq("quiz_id", quizId);
  if (error) throw new Error(error.message);
  await auditLog("reset_quiz_results", "quiz", quizId);
  revalidatePath("/admin/analytics");
  return { ok: true };
}

export async function resetAllResults() {
  const { supabase } = await requireAdmin();
  const { error: e1 } = await supabase
    .from("quiz_attempts")
    .delete()
    .not("id", "is", null);
  const { error: e2 } = await supabase
    .from("lesson_progress")
    .delete()
    .not("id", "is", null);
  if (e1 || e2) throw new Error((e1 || e2)!.message);
  await auditLog("reset_all_results", "system", "all");
  revalidatePath("/admin/analytics");
  return { ok: true };
}

/**
 * Envoie un email de relance à un stagiaire inactif depuis le dashboard admin.
 */
export async function sendInactivityReminder(
  studentEmail: string,
  studentName: string | null,
  daysInactive: number,
  formationTitle: string
) {
  const { admin } = await requireAdmin();
  if (!studentEmail) throw new Error("Email destinataire manquant");

  const greeting = studentName ? `Bonjour ${studentName},` : "Bonjour,";
  const loginUrl = `${
    process.env.NEXT_PUBLIC_APP_URL || LEGAL.website
  }/login`;

  const html = `
    <!doctype html>
    <html lang="fr">
      <body style="font-family: -apple-system, sans-serif; color: #0E1240; max-width: 560px; margin: 0 auto; padding: 24px;">
        <div style="background: #0E1240; color: #fff; padding: 24px; border-radius: 12px;">
          <h1 style="margin: 0; font-size: 22px;">${greeting}</h1>
          <p style="margin: 12px 0 0; color: #cbd5e1; font-size: 15px;">
            Nous remarquons que vous n'avez pas consulté votre formation
            <strong style="color: #9FE220;">${formationTitle}</strong>
            depuis ${daysInactive} jours.
          </p>
        </div>
        <div style="padding: 20px 0; color: #334155; font-size: 14px; line-height: 1.6;">
          <p>Reprendre maintenant, c'est augmenter de <strong>35 %</strong> vos chances de réussite à l'examen final.</p>
          <p>Quelques minutes par jour suffisent pour rester sur la bonne trajectoire.</p>
          <p style="margin: 28px 0 12px;">
            <a href="${loginUrl}" style="display: inline-block; background: #9FE220; color: #0E1240; padding: 12px 24px; border-radius: 10px; text-decoration: none; font-weight: 600;">
              Reprendre ma formation
            </a>
          </p>
          <p style="font-size: 13px; color: #64748b; margin-top: 28px;">
            Besoin d'aide ? Répondez simplement à cet email, votre formateur référent reviendra vers vous.
          </p>
        </div>
        <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 32px 0;" />
        <p style="font-size: 11px; color: #94a3b8; text-align: center;">
          MA FORMATION TRANSPORT · ${LEGAL.website}<br />
          Vous recevez ce message car vous êtes inscrit à une de nos formations.
        </p>
      </body>
    </html>
  `;

  const result = await sendEmail({
    to: studentEmail,
    subject: `On vous attend sur ${formationTitle} 🎯`,
    html,
  });

  await auditLog("send_inactivity_reminder", "profile", studentEmail, {
    days_inactive: daysInactive,
    formation: formationTitle,
    sent_by: admin.email,
    delivery: result.ok ? "sent" : "failed",
  });

  revalidatePath("/admin/analytics");
  return result;
}
