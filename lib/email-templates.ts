// =====================================================================
// Bibliothèque de modèles d'emails + variables dynamiques.
// Utilisée par le composer interne (components/email/email-composer.tsx).
// Les variables {{prenom}}, {{formation}}, … sont remplacées au moment de
// l'insertion du modèle, à partir du contexte (destinataire, dossier…).
// =====================================================================
import { LEGAL } from "./legal-config";

export type EmailCategory =
  | "stagiaire"
  | "formateur"
  | "administratif"
  | "commercial";

export interface EmailTemplate {
  id: string;
  category: EmailCategory;
  label: string;
  subject: string;
  body: string; // HTML simple, avec variables {{…}}
}

export const CATEGORY_LABELS: Record<EmailCategory, string> = {
  stagiaire: "Stagiaires",
  formateur: "Formateurs",
  administratif: "Administratif",
  commercial: "Commercial / marketing",
};

export const EMAIL_VARIABLES: { key: string; label: string }[] = [
  { key: "prenom", label: "Prénom" },
  { key: "nom", label: "Nom" },
  { key: "formation", label: "Formation" },
  { key: "module", label: "Module" },
  { key: "examen", label: "Examen" },
  { key: "date", label: "Date" },
  { key: "date_session", label: "Date de session" },
  { key: "montant", label: "Montant" },
  { key: "score", label: "Score" },
  { key: "ecole", label: "Nom de l'école" },
];

/** Remplace {{cle}} par sa valeur ; laisse le placeholder si inconnu. */
export function renderTemplate(
  text: string,
  vars: Record<string, string | undefined>
): string {
  return text.replace(/\{\{\s*([a-z_]+)\s*\}\}/gi, (m, key: string) => {
    const v = vars[key];
    return v !== undefined && v !== "" ? v : m;
  });
}

const SIGN = `<p>Cordialement,</p><p><strong>${LEGAL.brand}</strong><br/>${LEGAL.email} · ${LEGAL.phone}</p>`;

export const DEFAULT_SIGNATURE = SIGN;

const t = (
  id: string,
  category: EmailCategory,
  label: string,
  subject: string,
  body: string
): EmailTemplate => ({ id, category, label, subject, body: body + SIGN });

export const EMAIL_TEMPLATES: EmailTemplate[] = [
  // ── Stagiaires ─────────────────────────────────────────────────────
  t("welcome", "stagiaire", "Bienvenue",
    "Bienvenue chez {{ecole}} !",
    "<p>Bonjour {{prenom}},</p><p>Bienvenue chez {{ecole}} ! Votre espace de formation est désormais accessible. Vous y trouverez vos cours, vos quiz et le suivi de votre progression.</p><p>Bonne formation,</p>"),
  t("enroll_ok", "stagiaire", "Inscription validée",
    "Votre inscription à {{formation}} est validée",
    "<p>Bonjour {{prenom}},</p><p>Nous avons le plaisir de vous confirmer que votre inscription à la formation <strong>{{formation}}</strong> est validée. Vous pouvez dès à présent commencer votre parcours.</p>"),
  t("docs_missing", "stagiaire", "Documents manquants",
    "Documents manquants pour votre dossier",
    "<p>Bonjour {{prenom}},</p><p>Pour finaliser votre dossier d'inscription à <strong>{{formation}}</strong>, il nous manque un ou plusieurs documents. Merci de les déposer depuis votre espace, rubrique « Mes documents ».</p>"),
  t("course_reminder", "stagiaire", "Rappel de cours",
    "Reprenez votre formation {{formation}}",
    "<p>Bonjour {{prenom}},</p><p>Vous n'avez pas avancé depuis quelques jours sur <strong>{{formation}}</strong>. La régularité est la clé de la réussite : reconnectez-vous pour reprendre là où vous vous étiez arrêté.</p>"),
  t("exam_reminder", "stagiaire", "Rappel d'examen",
    "Votre examen {{examen}} approche",
    "<p>Bonjour {{prenom}},</p><p>Votre examen <strong>{{examen}}</strong> est prévu le <strong>{{date}}</strong>. Pensez à réviser et à passer les examens blancs disponibles dans votre espace pour vous mettre en conditions réelles.</p>"),
  t("validation", "stagiaire", "Formation validée",
    "Félicitations : formation {{formation}} validée",
    "<p>Bonjour {{prenom}},</p><p>Félicitations ! Vous avez validé l'ensemble des modules de la formation <strong>{{formation}}</strong>. Votre attestation est disponible dans votre espace.</p>"),
  t("congrats", "stagiaire", "Félicitations (résultat)",
    "Bravo pour votre score de {{score}} !",
    "<p>Bonjour {{prenom}},</p><p>Bravo ! Vous avez obtenu un score de <strong>{{score}}</strong>. Continuez sur cette lancée, vous êtes sur la bonne voie pour réussir votre examen.</p>"),
  t("absence", "stagiaire", "Absence constatée",
    "Absence à la session du {{date_session}}",
    "<p>Bonjour {{prenom}},</p><p>Nous avons constaté votre absence à la session du <strong>{{date_session}}</strong>. Merci de nous indiquer le motif et de prendre contact avec nous pour le rattrapage éventuel.</p>"),
  t("late", "stagiaire", "Retard de progression",
    "Votre progression sur {{formation}}",
    "<p>Bonjour {{prenom}},</p><p>Votre progression sur <strong>{{formation}}</strong> est en retard par rapport au planning prévu. Nous restons à votre disposition pour vous aider à reprendre le rythme.</p>"),
  t("admin_reminder", "stagiaire", "Relance administrative",
    "Action requise sur votre dossier",
    "<p>Bonjour {{prenom}},</p><p>Une action est requise pour faire avancer votre dossier de formation. Merci de vous connecter à votre espace ou de nous recontacter dans les meilleurs délais.</p>"),
  t("payment_reminder", "stagiaire", "Relance de paiement",
    "Rappel : règlement de {{montant}}",
    "<p>Bonjour {{prenom}},</p><p>Sauf erreur de notre part, le règlement de <strong>{{montant}}</strong> relatif à votre formation <strong>{{formation}}</strong> reste en attente. Merci de procéder au paiement ou de nous contacter si besoin.</p>"),

  // ── Formateurs ─────────────────────────────────────────────────────
  t("correction_pending", "formateur", "Correction en attente",
    "Copies à corriger",
    "<p>Bonjour {{prenom}},</p><p>Des copies de questions rédigées sont en attente de correction dans votre espace formateur. Merci d'en prendre connaissance dès que possible.</p>"),
  t("new_student", "formateur", "Nouveau stagiaire",
    "Un nouveau stagiaire vous est affecté",
    "<p>Bonjour {{prenom}},</p><p>Un nouveau stagiaire a été affecté à la formation <strong>{{formation}}</strong> que vous encadrez. Vous pouvez consulter son dossier et suivre sa progression depuis votre espace.</p>"),
  t("pedago_reminder", "formateur", "Rappel pédagogique",
    "Point de suivi pédagogique",
    "<p>Bonjour {{prenom}},</p><p>Merci de bien vouloir mettre à jour le suivi pédagogique de vos stagiaires et de vérifier les émargements de la semaine.</p>"),
  t("meeting", "formateur", "Réunion d'équipe",
    "Réunion pédagogique le {{date}}",
    "<p>Bonjour {{prenom}},</p><p>Une réunion pédagogique est organisée le <strong>{{date}}</strong>. Votre présence est importante. Vous trouverez l'ordre du jour en pièce jointe.</p>"),
  t("student_followup", "formateur", "Suivi stagiaire",
    "Suivi d'un stagiaire en difficulté",
    "<p>Bonjour {{prenom}},</p><p>Un stagiaire de <strong>{{formation}}</strong> semble rencontrer des difficultés. Pourriez-vous le contacter et proposer un accompagnement adapté ?</p>"),

  // ── Administratif ──────────────────────────────────────────────────
  t("doc_request", "administratif", "Demande de document",
    "Document requis pour votre dossier",
    "<p>Bonjour {{prenom}},</p><p>Dans le cadre de votre inscription à <strong>{{formation}}</strong>, merci de nous transmettre le document demandé afin de compléter votre dossier administratif.</p>"),
  t("convention", "administratif", "Convention de formation",
    "Convention de formation à signer",
    "<p>Bonjour {{prenom}},</p><p>Veuillez trouver ci-joint la convention de formation relative à <strong>{{formation}}</strong>. Merci de la lire, de la signer et de nous la retourner.</p>"),
  t("financement", "administratif", "Financement",
    "Prise en charge de votre formation",
    "<p>Bonjour {{prenom}},</p><p>Concernant le financement de votre formation <strong>{{formation}}</strong> (CPF, OPCO, France Travail, employeur…), voici les éléments nécessaires au montage de votre dossier de prise en charge.</p>"),
  t("convocation", "administratif", "Convocation",
    "Convocation à la session du {{date_session}}",
    "<p>Bonjour {{prenom}},</p><p>Vous êtes convoqué(e) à la session de formation <strong>{{formation}}</strong> le <strong>{{date_session}}</strong>. La convocation officielle est jointe à cet email.</p>"),
  t("signature_missing", "administratif", "Signature manquante",
    "Signature requise sur vos documents",
    "<p>Bonjour {{prenom}},</p><p>Un ou plusieurs documents obligatoires sont en attente de votre signature électronique. Merci de vous connecter à votre espace pour les signer (cela ne prend qu'une minute).</p>"),
  t("emargement", "administratif", "Émargement",
    "Pensez à émarger vos sessions",
    "<p>Bonjour {{prenom}},</p><p>Nous vous rappelons l'importance d'émarger chaque session suivie depuis votre espace. L'émargement atteste de votre présence et conditionne votre prise en charge.</p>"),

  // ── Commercial / marketing ─────────────────────────────────────────
  t("lead_followup", "commercial", "Relance prospect",
    "Votre projet de formation transport",
    "<p>Bonjour {{prenom}},</p><p>Vous avez récemment manifesté de l'intérêt pour nos formations transport. Êtes-vous toujours intéressé(e) ? Nous serions ravis d'échanger sur votre projet et les financements possibles.</p>"),
  t("promo", "commercial", "Offre promotionnelle",
    "Offre spéciale sur nos formations",
    "<p>Bonjour {{prenom}},</p><p>Profitez d'une offre spéciale sur nos formations transport. Contactez-nous pour en savoir plus et réserver votre place.</p>"),
  t("cart_reminder", "commercial", "Demande non finalisée",
    "Finalisez votre inscription",
    "<p>Bonjour {{prenom}},</p><p>Votre demande d'inscription à <strong>{{formation}}</strong> n'a pas été finalisée. Notre équipe reste disponible pour vous accompagner dans les dernières étapes.</p>"),
  t("review_request", "commercial", "Demande d'avis",
    "Votre avis nous intéresse",
    "<p>Bonjour {{prenom}},</p><p>Vous avez suivi la formation <strong>{{formation}}</strong>. Votre avis compte beaucoup : pourriez-vous prendre deux minutes pour nous laisser un retour ?</p>"),
  t("loyalty", "commercial", "Fidélisation",
    "Continuez à vous former avec {{ecole}}",
    "<p>Bonjour {{prenom}},</p><p>Merci de votre confiance. Pour aller plus loin, découvrez nos autres formations qui pourraient compléter votre parcours et faire évoluer votre carrière.</p>"),
];

export function templatesByCategory(): Record<EmailCategory, EmailTemplate[]> {
  const out = { stagiaire: [], formateur: [], administratif: [], commercial: [] } as Record<EmailCategory, EmailTemplate[]>;
  for (const tpl of EMAIL_TEMPLATES) out[tpl.category].push(tpl);
  return out;
}
