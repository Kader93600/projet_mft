// =====================================================================
// Email transactionnel via l'API HTTP de Resend (pas de SDK, juste fetch).
// Compatible Edge & Node runtimes.
// Si RESEND_API_KEY n'est pas défini, sendEmail() loggue et n'envoie rien
// (utile en dev). Aucune erreur n'est levée pour ne pas casser le parcours.
//
// Refonte 2026-05 : layout premium MFT (navy + signal-lime), responsive,
// compatible Outlook/Gmail/Apple Mail + dark mode iOS.
// =====================================================================

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
  const from =
    process.env.EMAIL_FROM_ADDRESS || `${LEGAL.brand} <noreply@example.com>`;
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
    // Ne pas spam Sentry pour les TypeError: fetch failed (transient :
    // timeout côté Resend, abort à la fin d'une fonction Vercel, etc.).
    // On loggue uniquement les erreurs durables.
    const msg = e instanceof Error ? e.message : "unknown";
    const isTransient =
      msg.includes("fetch failed") ||
      msg.includes("ETIMEDOUT") ||
      msg.includes("ECONNRESET") ||
      msg.includes("aborted");
    if (!isTransient) {
      await captureException(e, { tags: { service: "email" } });
    } else {
      // eslint-disable-next-line no-console
      console.warn("[email] transient send failure (not Sentry'd)", msg);
    }
    return { ok: false, error: msg };
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
// 1. Palette MFT (dupliquée ici pour ne pas dépendre de Tailwind config)
// =====================================================================

const COLORS = {
  navy: "#0E1240",
  navyLight: "#1f2547",
  signal: "#9FE220",
  signalDark: "#7CC30A",
  ivory: "#FAF8F4",
  gold: "#a16207",
  white: "#FFFFFF",
  slate900: "#0F172A",
  slate700: "#334155",
  slate500: "#64748B",
  slate300: "#CBD5E1",
  slate100: "#F1F5F9",
  border: "#E5E7EB",
  rose: "#e11d48",
  emerald: "#059669",
} as const;

function escapeHtml(s: string): string {
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

// =====================================================================
// 2. Layout premium MFT — wrapper réutilisé par tous les templates
//
// Architecture HTML (table-based pour compat Outlook) :
//   - Preheader caché (texte preview boîte de réception)
//   - Stripe signal-lime décorative (4 px) en haut
//   - Header navy (logo brand + tagline)
//   - Corps blanc (titre + contenu)
//   - Footer slate clair (SIRET / OF / liens légaux)
//
// Compatible :
//   - Outlook 2007-365 (VML bouton, fallback table)
//   - Gmail web + mobile (Android + iOS)
//   - Apple Mail (incl. dark mode iOS via prefers-color-scheme)
//   - Yahoo, Hotmail, ProtonMail
// =====================================================================

export function emailLayout(
  title: string,
  body: string,
  opts?: { preheader?: string }
): string {
  const preheader = opts?.preheader ?? "";
  return `<!doctype html>
<html lang="fr">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="x-apple-disable-message-reformatting" />
  <meta name="color-scheme" content="light dark" />
  <meta name="supported-color-schemes" content="light dark" />
  <title>${escapeHtml(title)}</title>
  <!--[if mso]>
  <style type="text/css">
    table, td, div, h1, h2, p, a { font-family: Arial, Helvetica, sans-serif !important; }
  </style>
  <![endif]-->
  <style>
    /* Reset basique */
    body, table, td, p, a, h1, h2, div { -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
    table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-collapse: collapse; }
    img { border: 0; line-height: 100%; outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; }
    p { display: block; margin: 0; padding: 0; }
    a { text-decoration: none; }

    /* Mobile */
    @media only screen and (max-width: 600px) {
      .mft-container { width: 100% !important; max-width: 100% !important; border-radius: 0 !important; }
      .mft-px { padding-left: 22px !important; padding-right: 22px !important; }
      .mft-h1 { font-size: 22px !important; line-height: 1.25 !important; }
      .mft-cta a { display: block !important; }
    }

    /* Dark mode iOS / Apple Mail / Outlook iOS — couvre TOUT le contenu */
    @media (prefers-color-scheme: dark) {
      .mft-body { background-color: #0a0d24 !important; }
      .mft-container { background-color: #131838 !important; }

      /* Texte général */
      .mft-h1, .mft-text strong, .mft-step-title { color: #f8fafc !important; }
      .mft-text, .mft-text p, .mft-text li { color: #e2e8f0 !important; }
      .mft-muted, .mft-step-desc { color: #cbd5e1 !important; }
      .mft-text a { color: #93c5fd !important; }
      .mft-text a.mft-link-break { color: #93c5fd !important; }

      /* Cards génériques */
      .mft-card { background-color: #1c2349 !important; border-color: #2d3458 !important; color: #e2e8f0 !important; }
      .mft-card strong { color: #f8fafc !important; }
      .mft-card a { color: #93c5fd !important; }

      /* Variantes infoCard avec contraste élevé */
      .mft-info { background-color: #1e2a5e !important; border-color: #3b4d8c !important; color: #c7d2fe !important; }
      .mft-info strong, .mft-info a { color: #e0e7ff !important; }
      .mft-success { background-color: #064e3b !important; border-color: #047857 !important; color: #6ee7b7 !important; }
      .mft-success strong { color: #d1fae5 !important; }
      .mft-warning { background-color: #451a03 !important; border-color: #92400e !important; color: #fcd34d !important; }
      .mft-warning strong { color: #fef3c7 !important; }
      .mft-error { background-color: #450a0a !important; border-color: #b91c1c !important; color: #fca5a5 !important; }
      .mft-error strong { color: #fee2e2 !important; }

      /* Force les div/span internes des cards à hériter de la couleur du parent */
      .mft-info div, .mft-info span,
      .mft-success div, .mft-success span,
      .mft-warning div, .mft-warning span,
      .mft-error div, .mft-error span { color: inherit !important; }

      /* Score block */
      .mft-score-bg-success { background-color: #064e3b !important; border-color: #047857 !important; }
      .mft-score-bg-fail { background-color: #450a0a !important; border-color: #b91c1c !important; }
      .mft-score-text-success { color: #6ee7b7 !important; }
      .mft-score-text-fail { color: #fca5a5 !important; }

      /* Footer */
      .mft-footer { background-color: #0a0d24 !important; color: #cbd5e1 !important; border-color: #2d3458 !important; }
      .mft-footer strong { color: #f8fafc !important; }
      .mft-footer a { color: #e2e8f0 !important; }
    }
  </style>
</head>
<body class="mft-body" style="margin: 0; padding: 0; background-color: ${COLORS.ivory}; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; color: ${COLORS.slate900};">
  <!-- Preheader caché (preview inbox) -->
  <div style="display: none; max-height: 0; overflow: hidden; mso-hide: all; font-size: 1px; line-height: 1px; color: transparent;">
    ${escapeHtml(preheader)}
  </div>

  <!-- Wrapper -->
  <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%" class="mft-body" style="background-color: ${COLORS.ivory}; padding: 32px 12px;">
    <tr>
      <td align="center">

        <!-- Container 600 px -->
        <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="600" class="mft-container" style="max-width: 600px; background-color: ${COLORS.white}; border-radius: 18px; overflow: hidden; box-shadow: 0 4px 32px rgba(14, 18, 64, 0.08);">

          <!-- Stripe top signal-lime -->
          <tr>
            <td style="height: 5px; background-color: ${COLORS.signal}; line-height: 5px; font-size: 0;">&nbsp;</td>
          </tr>

          <!-- Header navy -->
          <tr>
            <td class="mft-px" style="background-color: ${COLORS.navy}; padding: 28px 36px; text-align: left;">
              <div style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, Helvetica, Arial, sans-serif; font-size: 11px; font-weight: 800; letter-spacing: 2.4px; text-transform: uppercase; color: ${COLORS.signal};">
                Ma Formation Transport
              </div>
              <div style="margin-top: 6px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, Helvetica, Arial, sans-serif; font-size: 12.5px; color: rgba(255,255,255,0.75); letter-spacing: 0.2px;">
                Préparation aux titres pros &amp; certifications transport
              </div>
            </td>
          </tr>

          <!-- Titre h1 -->
          <tr>
            <td class="mft-px" style="padding: 36px 36px 12px;">
              <h1 class="mft-h1" style="margin: 0; font-family: 'Inter', -apple-system, BlinkMacSystemFont, Helvetica, Arial, sans-serif; font-size: 27px; line-height: 1.22; font-weight: 700; color: ${COLORS.navy}; letter-spacing: -0.02em;">
                ${title}
              </h1>
            </td>
          </tr>

          <!-- Corps -->
          <tr>
            <td class="mft-px mft-text" style="padding: 12px 36px 32px; font-size: 15.5px; line-height: 1.65; color: ${COLORS.slate700};">
              ${body}
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td class="mft-footer mft-px" style="background-color: ${COLORS.slate100}; padding: 22px 36px 26px; font-size: 12px; color: ${COLORS.slate500}; border-top: 1px solid ${COLORS.border};">
              <div style="line-height: 1.65;">
                <strong style="color: ${COLORS.slate700}; letter-spacing: 0.2px;">${LEGAL.legalName}</strong>
                &middot; SIRET ${LEGAL.siret}
              </div>
              <div style="margin-top: 3px;">
                N° activité OF ${LEGAL.trainingActivityNumber} &middot; Qualiopi ${LEGAL.qualiopiNumber}
              </div>
              <div style="margin-top: 14px;">
                <a href="${LEGAL.website}/confidentialite" style="color: ${COLORS.navy}; text-decoration: underline;">Confidentialité</a>
                &nbsp;&middot;&nbsp;
                <a href="${LEGAL.website}/mes-donnees" style="color: ${COLORS.navy}; text-decoration: underline;">Mes préférences</a>
                &nbsp;&middot;&nbsp;
                <a href="${LEGAL.website}/contact" style="color: ${COLORS.navy}; text-decoration: underline;">Nous contacter</a>
              </div>
              <div class="mft-muted" style="margin-top: 14px; color: ${COLORS.slate500}; font-size: 11px; line-height: 1.5;">
                Vous recevez cet email parce que vous êtes en lien avec ${LEGAL.brand}.
                Si ce n'est pas votre cas, ignorez-le ou
                <a href="${LEGAL.website}/contact" style="color: ${COLORS.slate500}; text-decoration: underline;">contactez-nous</a>.
              </div>
            </td>
          </tr>

        </table>

      </td>
    </tr>
  </table>
</body>
</html>`;
}

// =====================================================================
// 3. Helpers de composition pour le body des templates
// =====================================================================

/**
 * Bouton CTA "bulletproof" (compatible Outlook via mso-padding-alt).
 *
 * Variantes :
 *   - 'primary' (défaut) : fond navy, texte blanc
 *   - 'signal'           : fond lime, texte navy — pour les actions à fort enjeu
 *   - 'ghost'            : bordure navy, texte navy — secondaire
 */
export function ctaButton(
  label: string,
  url: string,
  variant: "primary" | "signal" | "ghost" = "primary"
): string {
  const isGhost = variant === "ghost";
  const isSignal = variant === "signal";
  const bg = isGhost ? "transparent" : isSignal ? COLORS.signal : COLORS.navy;
  const fg = isGhost ? COLORS.navy : isSignal ? COLORS.navy : COLORS.white;
  const border = isGhost ? `2px solid ${COLORS.navy}` : "0";
  return `
<table role="presentation" cellpadding="0" cellspacing="0" border="0" align="center" class="mft-cta" style="margin: 32px auto;">
  <tr>
    <td align="center" style="border-radius: 12px; background-color: ${bg};">
      <a href="${url}" target="_blank" style="display: inline-block; padding: 14px 30px; font-size: 15px; font-weight: 600; color: ${fg}; text-decoration: none; border-radius: 12px; background-color: ${bg}; border: ${border}; mso-padding-alt: 14px 30px; letter-spacing: 0.2px;">
        ${escapeHtml(label)}
      </a>
    </td>
  </tr>
</table>`;
}

/**
 * Liste numérotée "Prochaines étapes" — 1, 2, 3 avec pastilles signal-lime
 * et descriptions courtes. Idéal pour les emails de confirmation/onboarding.
 */
export function nextSteps(
  steps: { title: string; description: string }[]
): string {
  return `
<table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%" style="margin: 16px 0 4px;">
  ${steps
    .map(
      (step, i) => `
  <tr>
    <td style="padding: 14px 0; ${i === 0 ? "" : `border-top: 1px solid ${COLORS.border};`}" valign="top">
      <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%">
        <tr>
          <td width="40" valign="top" style="padding-right: 14px; width: 40px;">
            <div style="width: 30px; height: 30px; border-radius: 50%; background-color: ${COLORS.signal}; color: ${COLORS.navy}; text-align: center; line-height: 30px; font-weight: 800; font-size: 13px; font-family: 'Inter', -apple-system, Helvetica, Arial, sans-serif;">
              ${i + 1}
            </div>
          </td>
          <td valign="top">
            <div class="mft-step-title" style="font-weight: 600; color: ${COLORS.navy}; font-size: 15px; font-family: 'Inter', -apple-system, Helvetica, Arial, sans-serif;">${escapeHtml(step.title)}</div>
            <div class="mft-step-desc" style="margin-top: 3px; color: ${COLORS.slate500}; font-size: 14px; line-height: 1.55;">${escapeHtml(step.description)}</div>
          </td>
        </tr>
      </table>
    </td>
  </tr>`
    )
    .join("")}
</table>`;
}

/**
 * Carte d'info colorée (success / warning / info) pour mettre en avant
 * un point important (succès paiement, échec quiz, alerte échéance).
 *
 * Note dark mode : chaque tone reçoit une classe spécifique (`mft-info`,
 * `mft-success`, etc.) qu'on overrride dans `@media (prefers-color-scheme: dark)`
 * pour garantir un contraste max (les couleurs claires deviennent claires
 * mais sur fond sombre, et inversement).
 */
export function infoCard(
  content: string,
  tone: "info" | "success" | "warning" | "error" = "info"
): string {
  const palettes = {
    info: { bg: "#EEF2FF", fg: COLORS.navy, border: "#C7D2FE" },
    success: { bg: "#ECFDF5", fg: COLORS.emerald, border: "#A7F3D0" },
    warning: { bg: "#FEF3C7", fg: "#92400E", border: "#FDE68A" },
    error: { bg: "#FEF2F2", fg: COLORS.rose, border: "#FECACA" },
  };
  const p = palettes[tone];
  const toneClass = `mft-${tone}`;
  return `
<table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%" class="${toneClass}" style="margin: 20px 0; background-color: ${p.bg}; border: 1px solid ${p.border}; border-radius: 12px;">
  <tr>
    <td style="padding: 16px 18px; color: ${p.fg}; font-size: 14.5px; line-height: 1.6;">
      ${content}
    </td>
  </tr>
</table>`;
}

/**
 * Bloc score (grand chiffre + label) — pour les emails de correction.
 */
export function scoreBlock(percent: number, passed: boolean): string {
  const color = passed ? COLORS.emerald : COLORS.rose;
  const bg = passed ? "#ECFDF5" : "#FEF2F2";
  const border = passed ? "#A7F3D0" : "#FECACA";
  const bgClass = passed ? "mft-score-bg-success" : "mft-score-bg-fail";
  const textClass = passed ? "mft-score-text-success" : "mft-score-text-fail";
  return `
<table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%" class="${bgClass}" style="margin: 24px 0; background-color: ${bg}; border: 1px solid ${border}; border-radius: 14px;">
  <tr>
    <td align="center" style="padding: 28px 20px;">
      <div class="${textClass}" style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, Helvetica, Arial, sans-serif; font-size: 52px; line-height: 1; font-weight: 800; color: ${color}; letter-spacing: -0.02em;">
        ${Math.round(percent)}%
      </div>
      <div class="${textClass}" style="margin-top: 8px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, Helvetica, Arial, sans-serif; font-size: 13px; font-weight: 700; letter-spacing: 1.6px; text-transform: uppercase; color: ${color};">
        ${passed ? "Examen réussi" : "Continuez la préparation"}
      </div>
    </td>
  </tr>
</table>`;
}

// =====================================================================
// 4. Templates fonctionnels
// =====================================================================

/**
 * Bienvenue après création de compte stagiaire.
 * Déclencheur : action onboarding (à brancher dans flow signup).
 */
export function welcomeEmail(input: { fullName: string; loginUrl: string }) {
  const firstName = (input.fullName ?? "").split(" ")[0] || "stagiaire";
  return {
    subject: `Bienvenue chez ${LEGAL.brand}`,
    html: emailLayout(
      `Bienvenue, ${escapeHtml(firstName)}`,
      `
      <p>Votre compte est créé : vous avez désormais accès à votre <strong>espace stagiaire</strong>, à vos modules de cours, aux quiz d'entraînement et aux examens blancs.</p>
      <p>Voici comment démarrer :</p>
      ${nextSteps([
        {
          title: "Connectez-vous à votre espace",
          description: "Identifiants reçus par email. Premier login : reset de mot de passe recommandé.",
        },
        {
          title: "Ouvrez votre premier module",
          description: "Le tableau de bord met en avant le module à reprendre. Tout votre parcours est tracé.",
        },
        {
          title: "Posez vos questions",
          description: "Votre référent pédagogique répond sous 24 h ouvrées. Répondez simplement à cet email.",
        },
      ])}
      ${ctaButton("Accéder à ma plateforme", input.loginUrl, "signal")}
      <p class="mft-muted" style="font-size: 13px; color: ${COLORS.slate500};">Bonne formation. L'équipe ${LEGAL.brand} reste à votre disposition.</p>
      `,
      { preheader: `Bienvenue ${firstName}, votre espace stagiaire est prêt.` }
    ),
  };
}

/**
 * Confirmation d'inscription (lead reçu).
 * Déclencheur : POST /api/contact ou /inscription/actions.
 */
export function enrollmentReceivedEmail(input: {
  fullName: string;
  formationTitle?: string;
}) {
  const firstName = (input.fullName ?? "").split(" ")[0];
  const greeting = firstName ? `, ${escapeHtml(firstName)}` : "";
  const formationDisplay = input.formationTitle
    ? escapeHtml(input.formationTitle)
    : LEGAL.rncpTitle;
  return {
    subject: `Demande d'inscription bien reçue`,
    html: emailLayout(
      `Merci${greeting}, c'est noté.`,
      `
      <p>Nous avons bien reçu votre demande d'inscription pour la formation <strong>${formationDisplay}</strong>. Voici ce qui va se passer dans les prochains jours :</p>
      ${nextSteps([
        {
          title: "Étude de votre dossier",
          description: "Nous analysons votre profil et vos modes de financement (CPF, OPCO, employeur, France Travail).",
        },
        {
          title: "Réponse personnalisée sous 48 h ouvrées",
          description: "Notre équipe vous recontacte pour valider le devis et préparer la convention de formation.",
        },
        {
          title: "Accès à votre espace stagiaire",
          description: "Une fois la convention signée, vous recevez vos identifiants et démarrez immédiatement.",
        },
      ])}
      ${infoCard(
        `Une question pendant l'attente ? Écrivez-nous directement à <a href="mailto:${LEGAL.email}" style="color: ${COLORS.navy}; font-weight: 600;">${LEGAL.email}</a> ou répondez à cet email — réponse sous 4 h ouvrées.`,
        "info"
      )}
      `,
      {
        preheader: `Demande reçue. Réponse sous 48 h ouvrées.`,
      }
    ),
  };
}

/**
 * Notification stagiaire : sa copie est corrigée et finalisée.
 * Déclencheur : action formateur "finaliser la correction".
 */
export function copyGradedEmail(input: {
  fullName: string;
  quizTitle: string;
  scorePct: number;
  passed: boolean;
  resultsUrl: string;
}) {
  const firstName = (input.fullName ?? "").split(" ")[0];
  const greeting = firstName ? `, ${escapeHtml(firstName)}` : "";
  return {
    subject: `Votre copie "${input.quizTitle}" a été corrigée`,
    html: emailLayout(
      `Votre note est disponible${greeting}`,
      `
      <p>Votre formateur a finalisé la correction de votre examen <strong>${escapeHtml(input.quizTitle)}</strong>.</p>
      ${scoreBlock(input.scorePct, input.passed)}
      <p>Sur la page de résultats, vous retrouverez :</p>
      <ul style="margin: 8px 0 16px; padding-left: 22px; color: ${COLORS.slate700};">
        <li style="margin-bottom: 6px;">Le <strong>détail question par question</strong> avec le bon corrigé</li>
        <li style="margin-bottom: 6px;">Les <strong>commentaires personnalisés</strong> de votre formateur</li>
        <li>Les <strong>axes de progression</strong> à retravailler avant l'examen final</li>
      </ul>
      ${ctaButton("Voir le détail et les commentaires", input.resultsUrl, "primary")}
      <p class="mft-muted" style="font-size: 13px; color: ${COLORS.slate500};">${
        input.passed
          ? "Bravo ! Continuez sur cette dynamique."
          : "Pas de panique : chaque session apporte des points clés. Reprenez les modules concernés à votre rythme."
      }</p>
      `,
      {
        preheader: `${Math.round(input.scorePct)}% — ${input.passed ? "examen réussi" : "à approfondir"}.`,
      }
    ),
  };
}

/**
 * Notification formateur : nouvelle copie en attente de correction.
 * Déclencheur : soumission d'un quiz mixte (QCM + QR) par un stagiaire.
 */
export function newCopyToGradeEmail(input: {
  trainerName: string;
  studentName: string;
  quizTitle: string;
  correctionUrl: string;
}) {
  const firstName = (input.trainerName ?? "").split(" ")[0];
  return {
    subject: `Nouvelle copie à corriger — ${input.studentName}`,
    html: emailLayout(
      `Bonjour ${escapeHtml(firstName)}`,
      `
      <p><strong>${escapeHtml(input.studentName)}</strong> vient de soumettre l'examen <strong>${escapeHtml(input.quizTitle)}</strong>. La copie contient des questions rédigées (QR) en attente de votre correction.</p>
      ${infoCard(
        `<strong>Délai habituel attendu :</strong> 48 à 72 h ouvrées. Le stagiaire reçoit sa note automatiquement dès que vous finalisez.`,
        "warning"
      )}
      ${ctaButton("Corriger maintenant", input.correctionUrl, "signal")}
      <p class="mft-muted" style="font-size: 13px; color: ${COLORS.slate500};">Vous pouvez également retrouver toutes vos copies en attente dans votre espace formateur, section <em>Corrections</em>.</p>
      `,
      { preheader: `Copie en attente — ${input.studentName}.` }
    ),
  };
}

/**
 * Notification admin : un nouveau lead vient d'arriver.
 * Déclencheur : soumission formulaire /contact.
 */
export function newLeadEmail(input: {
  fullName: string;
  email: string;
  phone?: string | null;
  fundingKind?: string | null;
  formation?: string | null;
  message?: string | null;
  adminUrl: string;
}) {
  const rows: string[] = [];
  rows.push(
    `<tr><td style="padding: 8px 14px 8px 0; color: ${COLORS.slate500}; font-size: 13.5px; vertical-align: top; width: 110px;">Email</td><td style="padding: 8px 0; font-size: 14.5px; color: ${COLORS.slate900};"><a href="mailto:${input.email}" style="color: ${COLORS.navy}; font-weight: 600;">${escapeHtml(input.email)}</a></td></tr>`
  );
  if (input.phone) {
    rows.push(
      `<tr><td style="padding: 8px 14px 8px 0; color: ${COLORS.slate500}; font-size: 13.5px; vertical-align: top;">Téléphone</td><td style="padding: 8px 0; font-size: 14.5px;"><a href="tel:${escapeHtml(input.phone)}" style="color: ${COLORS.navy}; font-weight: 600;">${escapeHtml(input.phone)}</a></td></tr>`
    );
  }
  if (input.formation) {
    rows.push(
      `<tr><td style="padding: 8px 14px 8px 0; color: ${COLORS.slate500}; font-size: 13.5px; vertical-align: top;">Formation</td><td style="padding: 8px 0; font-size: 14.5px; color: ${COLORS.slate900};">${escapeHtml(input.formation)}</td></tr>`
    );
  }
  if (input.fundingKind) {
    rows.push(
      `<tr><td style="padding: 8px 14px 8px 0; color: ${COLORS.slate500}; font-size: 13.5px; vertical-align: top;">Financement</td><td style="padding: 8px 0; font-size: 14.5px; color: ${COLORS.slate900};">${escapeHtml(input.fundingKind)}</td></tr>`
    );
  }
  const tableBlock = `
  <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%" class="mft-card" style="margin: 20px 0; background-color: ${COLORS.slate100}; border: 1px solid ${COLORS.border}; border-radius: 12px;">
    <tr><td style="padding: 14px 18px;">
      <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%">${rows.join(
        ""
      )}</table>
    </td></tr>
  </table>`;
  const messageBlock = input.message
    ? `<div class="mft-card" style="margin: 12px 0 20px; padding: 14px 18px; background-color: #FFFBEB; border-left: 3px solid ${COLORS.gold}; border-radius: 8px; font-size: 14px; color: ${COLORS.slate700}; line-height: 1.6; font-style: italic;">« ${escapeHtml(
        input.message.slice(0, 600)
      )} »</div>`
    : "";

  return {
    subject: `Nouveau lead — ${input.fullName}`,
    html: emailLayout(
      `Nouveau lead : ${escapeHtml(input.fullName)}`,
      `
      <p><strong>${escapeHtml(input.fullName)}</strong> vient de remplir le formulaire de contact. Voici ses informations :</p>
      ${tableBlock}
      ${messageBlock}
      ${ctaButton("Traiter le lead", input.adminUrl, "signal")}
      ${infoCard(
        `<strong>Recontactez sous 48 h ouvrées</strong> pour maximiser la conversion. Au-delà, le taux de réponse chute drastiquement.`,
        "warning"
      )}
      `,
      { preheader: `Nouveau lead — ${input.fullName}.` }
    ),
  };
}

/**
 * Rappel d'échéance de paiement (B2C / paiement en plusieurs fois).
 */
export function paymentReminderEmail(input: {
  fullName: string;
  amount: string;
  dueDate: string;
  payUrl?: string;
}) {
  const firstName = (input.fullName ?? "").split(" ")[0];
  return {
    subject: `Échéance à venir — ${input.amount}`,
    html: emailLayout(
      `Rappel d'échéance, ${escapeHtml(firstName)}`,
      `
      <p>Une échéance arrive bientôt :</p>
      ${infoCard(
        `<div style="font-size: 22px; font-weight: 600; color: ${COLORS.navy};">${escapeHtml(input.amount)}</div><div style="margin-top: 4px; color: ${COLORS.slate500}; font-size: 13.5px;">à régler avant le <strong>${escapeHtml(input.dueDate)}</strong></div>`,
        "warning"
      )}
      ${input.payUrl ? ctaButton("Régler en ligne", input.payUrl, "signal") : ""}
      <p class="mft-muted" style="font-size: 13px; color: ${COLORS.slate500};">Si vous avez déjà réglé, ignorez ce message. Pour toute question, répondez à cet email — réponse sous 4 h ouvrées.</p>
      `,
      { preheader: `Échéance ${input.amount} avant ${input.dueDate}.` }
    ),
  };
}

/**
 * Notification stagiaire inactif (cron quotidien).
 * Déclencheur : /api/cron/inactivity.
 */
export function inactivityReminderEmail(input: {
  fullName?: string | null;
  daysInactive: number;
  dashboardUrl: string;
}) {
  const firstName = ((input.fullName ?? "") as string).split(" ")[0];
  const greeting = firstName ? `, ${escapeHtml(firstName)}` : "";
  const days = Math.round(input.daysInactive);
  return {
    subject: "On vous attend pour reprendre votre formation",
    html: emailLayout(
      `On vous attend${greeting}`,
      `
      <p>Votre dernière activité sur la plateforme remonte à <strong>${days} jour${days > 1 ? "s" : ""}</strong>. On comprend, parfois la vie prend le dessus — mais la régularité est la clé pour réussir l'examen ${LEGAL.rncpCode}.</p>
      ${infoCard(
        `<strong>15 à 30 min par jour</strong> suffisent pour avancer sans craquer. Une leçon, un quiz, et c'est plié.`,
        "info"
      )}
      ${ctaButton("Reprendre ma formation", input.dashboardUrl, "signal")}
      <p>Besoin d'un coup de pouce ou d'un échange avec un référent pédagogique ? <strong>Répondez simplement à cet email.</strong> Nous vous recontactons sous 24 h ouvrées.</p>
      <p class="mft-muted" style="font-size: 13px; color: ${COLORS.slate500};">Vous ne voulez plus recevoir ces rappels ? <a href="${LEGAL.website}/mes-donnees" style="color: ${COLORS.slate500}; text-decoration: underline;">Gérez vos préférences ici</a>.</p>
      `,
      {
        preheader: `${days} jour${days > 1 ? "s" : ""} sans activité — reprenez en 15 min.`,
      }
    ),
  };
}

/**
 * Notification interne pour l'admin : un ou plusieurs leads ont une
 * relance due aujourd'hui. Déclenché par /api/cron/crm-followup.
 *
 * Note : c'est un email INTERNE (vers l'équipe MFT), pas vers le prospect.
 */
export function crmFollowupReminderEmail(input: {
  adminFullName?: string | null;
  leads: Array<{
    id: string;
    fullName: string;
    email: string;
    status: string;
    nextFollowupAt: string;
  }>;
  crmUrl: string;
}) {
  const firstName = ((input.adminFullName ?? "") as string).split(" ")[0];
  const greeting = firstName ? `, ${escapeHtml(firstName)}` : "";
  const count = input.leads.length;
  const listHtml = input.leads
    .map((l) => {
      const date = new Date(l.nextFollowupAt);
      return `<li style="margin-bottom: 8px;">
        <strong>${escapeHtml(l.fullName)}</strong>
        <span style="color: ${COLORS.slate500};"> — ${escapeHtml(l.email)} · ${escapeHtml(l.status)} · prévu ${date.toLocaleDateString("fr-FR")}</span>
      </li>`;
    })
    .join("\n");
  return {
    subject: `Vous avez ${count} relance${count > 1 ? "s" : ""} CRM à effectuer aujourd'hui`,
    html: emailLayout(
      `${count} relance${count > 1 ? "s" : ""} à faire${greeting}`,
      `
      <p>Voici vos prospects à recontacter aujourd'hui :</p>
      <ul style="padding-left: 18px; margin: 16px 0;">${listHtml}</ul>
      ${ctaButton("Ouvrir le CRM", input.crmUrl, "signal")}
      <p class="mft-muted" style="font-size: 13px; color: ${COLORS.slate500};">Pas le temps aujourd'hui ? Vous pouvez mettre un lead en pause depuis sa fiche pour reporter la relance.</p>
      `,
      {
        preheader: `${count} prospect${count > 1 ? "s" : ""} attend${count > 1 ? "ent" : ""} votre rappel.`,
      }
    ),
  };
}

/**
 * Confirmation de paiement Stripe reçu.
 * Déclencheur : webhook /api/stripe/webhook (checkout.session.completed).
 */
export function paymentReceivedEmail(input: {
  fullName?: string | null;
  amountCents: number;
  loginUrl: string;
  invoiceUrl?: string | null;
}) {
  const firstName = ((input.fullName ?? "") as string).split(" ")[0];
  const greeting = firstName ? `, ${escapeHtml(firstName)}` : "";
  const amountFormatted = (input.amountCents / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
  });
  return {
    subject: "Paiement reçu — Bienvenue à bord",
    html: emailLayout(
      `Paiement confirmé${greeting}`,
      `
      <p>Merci pour votre confiance. Votre paiement a bien été enregistré :</p>
      ${infoCard(
        `<div style="font-size: 24px; font-weight: 600; color: ${COLORS.emerald};">${amountFormatted}</div><div style="margin-top: 4px; color: ${COLORS.slate500}; font-size: 13.5px;">Encaissé via Stripe · Reçu disponible dans votre espace</div>`,
        "success"
      )}
      <p>Voici ce qui arrive dans les minutes qui viennent :</p>
      ${nextSteps([
        {
          title: "Convention de formation (PDF)",
          description: "Document officiel à signer électroniquement, envoyé séparément par email.",
        },
        {
          title: "Convocation et accès plateforme",
          description: "Identifiants de connexion + modalités d'accès à votre espace stagiaire.",
        },
        {
          title: "Démarrage du parcours",
          description: "Premier module disponible immédiatement. Votre formateur référent prend contact sous 48 h.",
        },
      ])}
      ${ctaButton("Accéder à ma plateforme", input.loginUrl, "signal")}
      ${
        input.invoiceUrl
          ? `<p class="mft-muted" style="font-size: 13px; color: ${COLORS.slate500};">Besoin de la facture ? <a href="${input.invoiceUrl}" style="color: ${COLORS.navy}; text-decoration: underline; font-weight: 600;">Téléchargez-la ici</a>.</p>`
          : ""
      }
      <p class="mft-muted" style="font-size: 13px; color: ${COLORS.slate500};">Une question ? Répondez à cet email — réponse sous 4 h ouvrées.</p>
      `,
      {
        preheader: `Paiement de ${amountFormatted} reçu. Bienvenue à bord.`,
      }
    ),
  };
}
