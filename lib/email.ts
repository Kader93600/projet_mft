// Email transactionnel via l'API HTTP de Resend (pas de SDK, juste fetch).
// Compatible Edge & Node runtimes.
// Si RESEND_API_KEY n'est pas défini, sendEmail() loggue et n'envoie rien
// (utile en dev). Aucune erreur n'est levée pour ne pas casser le parcours.

import { captureException } from "./observability";
import { LEGAL } from "./legal-config";

const RESEND_URL = "https://api.resend.com/emails";

export interface SendEmailInput {
  to: string | string[];
  subject: string;
  html: string;
  text?: string;
  replyTo?: string;
  tags?: { name: string; value: string }[];
}

export async function sendEmail(input: SendEmailInput): Promise<{
  ok: boolean;
  id?: string;
  error?: string;
}> {
  const apiKey = process.env.RESEND_API_KEY;
  const from = process.env.EMAIL_FROM_ADDRESS || `${LEGAL.brand} <noreply@example.com>`;
  const replyTo = input.replyTo || process.env.EMAIL_REPLY_TO || LEGAL.email;

  if (!apiKey) {
    // eslint-disable-next-line no-console
    console.log("[email:dev]", { to: input.to, subject: input.subject });
    return { ok: true, id: "dev-noop" };
  }

  try {
    const res = await fetch(RESEND_URL, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from,
        to: Array.isArray(input.to) ? input.to : [input.to],
        subject: input.subject,
        html: input.html,
        text: input.text ?? stripHtml(input.html),
        reply_to: replyTo,
        tags: input.tags,
      }),
    });
    if (!res.ok) {
      const body = await res.text();
      await captureException(new Error(`Resend ${res.status}: ${body}`), {
        level: "error",
        tags: { service: "email" },
      });
      return { ok: false, error: body };
    }
    const data = (await res.json()) as { id: string };
    return { ok: true, id: data.id };
  } catch (e) {
    await captureException(e, { tags: { service: "email" } });
    return { ok: false, error: e instanceof Error ? e.message : "unknown" };
  }
}

function stripHtml(html: string): string {
  return html
    .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, "")
    .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "")
    .replace(/<[^>]+>/g, "")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

// =====================================================================
// Templates HTML simples (inline styles — compatibles Outlook/Gmail)
// =====================================================================

const BASE_STYLE = `font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:#0E1240;line-height:1.6;`;

export function emailLayout(title: string, body: string): string {
  return `<!doctype html><html lang="fr"><body style="margin:0;background:#FAF8F4;padding:24px 12px;${BASE_STYLE}">
  <table role="presentation" cellpadding="0" cellspacing="0" width="100%" style="max-width:560px;margin:0 auto;background:#fff;border-radius:16px;overflow:hidden;border:1px solid #E5E7EB">
    <tr><td style="padding:24px 28px;border-bottom:1px solid #F1F2F4">
      <div style="font-size:18px;font-weight:600;letter-spacing:1px;color:#0E1240">${LEGAL.brand}</div>
      <div style="font-size:11px;color:#64748B;text-transform:uppercase;letter-spacing:1px;margin-top:2px">Préparation au titre ${LEGAL.rncpCode}</div>
    </td></tr>
    <tr><td style="padding:24px 28px">
      <h1 style="font-size:20px;margin:0 0 12px;color:#0E1240">${title}</h1>
      ${body}
    </td></tr>
    <tr><td style="padding:18px 28px;background:#F8FAFC;border-top:1px solid #F1F2F4;font-size:11px;color:#64748B">
      ${LEGAL.legalName} · SIRET ${LEGAL.siret} · N° activité OF ${LEGAL.trainingActivityNumber}<br/>
      <a href="${LEGAL.website}/confidentialite" style="color:#0E1240">Confidentialité</a> ·
      <a href="${LEGAL.website}/mes-donnees" style="color:#0E1240">Gérer mes préférences</a>
    </td></tr>
  </table>
  </body></html>`;
}

export function welcomeEmail(input: {
  fullName: string;
  loginUrl: string;
}) {
  return {
    subject: `Bienvenue chez ${LEGAL.brand}`,
    html: emailLayout(
      `Bienvenue, ${input.fullName} 👋`,
      `<p>Votre compte a été créé. Vous pouvez dès à présent accéder à votre espace de formation, consulter vos modules et démarrer votre préparation.</p>
       <p style="margin:24px 0">
         <a href="${input.loginUrl}" style="display:inline-block;padding:12px 22px;background:#0E1240;color:#fff;text-decoration:none;border-radius:12px;font-weight:500">Accéder à ma plateforme</a>
       </p>
       <p style="font-size:13px;color:#64748B">Une question ? Répondez simplement à cet email.</p>`
    ),
  };
}

export function enrollmentReceivedEmail(input: { fullName: string }) {
  return {
    subject: `Demande d'inscription bien reçue`,
    html: emailLayout(
      `Merci ${input.fullName}, c'est noté.`,
      `<p>Nous avons bien reçu votre demande d'inscription au titre <strong>${LEGAL.rncpTitle}</strong> (${LEGAL.rncpCode}).</p>
       <p>Notre équipe vous recontacte sous <strong>48 heures ouvrées</strong> pour finaliser votre dossier (devis + convention).</p>
       <p style="font-size:13px;color:#64748B">Si vous avez besoin d'aide en attendant, écrivez-nous à <a href="mailto:${LEGAL.email}" style="color:#0E1240">${LEGAL.email}</a>.</p>`
    ),
  };
}

/** Notif stagiaire : sa copie est corrigée. */
export function copyGradedEmail(input: {
  fullName: string;
  quizTitle: string;
  scorePct: number;
  passed: boolean;
  resultsUrl: string;
}) {
  return {
    subject: `Votre copie "${input.quizTitle}" a été corrigée`,
    html: emailLayout(
      `${input.fullName}, votre note est disponible !`,
      `<p>Votre formateur a finalisé la correction de l'examen <strong>${input.quizTitle}</strong>.</p>
       <p style="font-size:24px;font-weight:bold;color:${input.passed ? "#16a34a" : "#e11d48"};margin:16px 0">
         ${Math.round(input.scorePct)}% — ${input.passed ? "Examen réussi" : "Continuez la préparation"}
       </p>
       <p style="margin:24px 0">
         <a href="${input.resultsUrl}" style="display:inline-block;padding:12px 22px;background:#0E1240;color:#fff;text-decoration:none;border-radius:12px;font-weight:500">Voir le détail et les commentaires</a>
       </p>
       <p style="font-size:13px;color:#64748B">Bonne continuation dans votre préparation !</p>`
    ),
  };
}

/** Notif formateur : nouvelle copie à corriger. */
export function newCopyToGradeEmail(input: {
  trainerName: string;
  studentName: string;
  quizTitle: string;
  correctionUrl: string;
}) {
  return {
    subject: `Nouvelle copie à corriger — ${input.studentName}`,
    html: emailLayout(
      `Bonjour ${input.trainerName},`,
      `<p><strong>${input.studentName}</strong> vient de soumettre l'examen <strong>${input.quizTitle}</strong>.</p>
       <p>La copie contient des questions rédigées en attente de votre correction.</p>
       <p style="margin:24px 0">
         <a href="${input.correctionUrl}" style="display:inline-block;padding:12px 22px;background:#9FE220;color:#0E1240;text-decoration:none;border-radius:12px;font-weight:600">Corriger maintenant</a>
       </p>
       <p style="font-size:13px;color:#64748B">Le stagiaire reçoit sa note dès que vous finalisez. Délai habituel : 48 à 72 h ouvrées.</p>`
    ),
  };
}

/** Notif admin : un nouveau lead vient d'arriver dans enrollment_requests. */
export function newLeadEmail(input: {
  fullName: string;
  email: string;
  phone?: string | null;
  fundingKind?: string | null;
  formation?: string | null;
  message?: string | null;
  adminUrl: string;
}) {
  const lines: string[] = [];
  lines.push(`<p><strong>${input.fullName}</strong> vient de demander à être recontacté.</p>`);
  lines.push(`<table style="margin:16px 0;border-collapse:collapse;font-size:14px"><tbody>`);
  lines.push(`<tr><td style="padding:6px 12px;color:#64748B">Email</td><td style="padding:6px 12px"><a href="mailto:${input.email}" style="color:#0E1240">${input.email}</a></td></tr>`);
  if (input.phone) {
    lines.push(`<tr><td style="padding:6px 12px;color:#64748B">Téléphone</td><td style="padding:6px 12px"><a href="tel:${input.phone}" style="color:#0E1240">${input.phone}</a></td></tr>`);
  }
  if (input.formation) {
    lines.push(`<tr><td style="padding:6px 12px;color:#64748B">Formation visée</td><td style="padding:6px 12px">${input.formation}</td></tr>`);
  }
  if (input.fundingKind) {
    lines.push(`<tr><td style="padding:6px 12px;color:#64748B">Financement</td><td style="padding:6px 12px">${input.fundingKind}</td></tr>`);
  }
  lines.push(`</tbody></table>`);
  if (input.message) {
    lines.push(`<p style="margin-top:12px;font-size:13px;color:#475569"><em>« ${input.message.replace(/</g, "&lt;").slice(0, 500)} »</em></p>`);
  }
  lines.push(`<p style="margin:24px 0"><a href="${input.adminUrl}" style="display:inline-block;padding:12px 22px;background:#9FE220;color:#0E1240;text-decoration:none;border-radius:12px;font-weight:600">Traiter le lead</a></p>`);
  lines.push(`<p style="font-size:12px;color:#94A3B8">Recontactez sous 48 h ouvrées pour maximiser la conversion.</p>`);

  return {
    subject: `Nouveau lead — ${input.fullName}`,
    html: emailLayout(`Nouveau lead à contacter`, lines.join("\n")),
  };
}

export function paymentReminderEmail(input: {
  fullName: string;
  amount: string;
  dueDate: string;
  payUrl?: string;
}) {
  return {
    subject: `Échéance à venir — ${input.amount}`,
    html: emailLayout(
      `Rappel d'échéance`,
      `<p>Bonjour ${input.fullName},</p>
       <p>Une échéance de <strong>${input.amount}</strong> arrive le <strong>${input.dueDate}</strong>.</p>
       ${input.payUrl ? `<p style="margin:24px 0"><a href="${input.payUrl}" style="display:inline-block;padding:12px 22px;background:#9FE220;color:#0E1240;text-decoration:none;border-radius:12px;font-weight:600">Régler en ligne</a></p>` : ""}
       <p style="font-size:13px;color:#64748B">Si vous avez déjà réglé, ignorez cet email.</p>`
    ),
  };
}
