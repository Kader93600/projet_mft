import { z } from "zod";

// ============ Types réutilisés ============
export const uuid = z.string().uuid("Identifiant invalide");
export const emailSchema = z.string().email("Email invalide").max(254);
export const nonEmptyText = (max = 500) =>
  z.string().trim().min(1, "Champ requis").max(max);
export const optionalText = (max = 5000) =>
  z.string().trim().max(max).optional().nullable();
export const slugSchema = z
  .string()
  .trim()
  .min(1)
  .max(80)
  .regex(/^[a-z0-9-]+$/, "Slug invalide (a-z, 0-9, tiret uniquement)")
  .optional();

// ============ Profiles ============
export const updateProfileSchema = z.object({
  full_name: z.string().trim().max(120).nullable().optional(),
  email: emailSchema.nullable().optional(),
  phone: z
    .string()
    .trim()
    .max(30)
    .regex(/^[0-9+\-.\s()]*$/, "Téléphone invalide")
    .nullable()
    .optional(),
  notes: z.string().trim().max(2000).nullable().optional(),
  level: z.enum(["debutant", "intermediaire", "avance"]).optional(),
  role: z.enum(["student", "admin"]).optional(),
  group_id: uuid.nullable().optional(),
  disabled: z.boolean().optional(),
});

// ============ Groups ============
export const groupSchema = z.object({
  name: nonEmptyText(80),
  description: z.string().trim().max(500).nullable().optional(),
  academic_year: z.string().trim().max(20).nullable().optional(),
  color: z.enum(["navy", "gold", "emerald", "rose", "violet"]).default("navy"),
});

// ============ Modules ============
export const moduleCreateSchema = z.object({
  title: nonEmptyText(200),
  slug: slugSchema,
  bloc_id: z.number().int().positive(),
  // Slug formation OBLIGATOIRE à la création (lien formation_modules)
  formation_slug: z
    .string()
    .trim()
    .min(1, "La formation associée est obligatoire"),
  summary: z.string().trim().max(1000).optional(),
  difficulty: z.enum(["debutant", "intermediaire", "avance"]).default("debutant"),
  duration_min: z.number().int().min(5).max(600).default(30),
  order: z.number().int().min(0).max(9999).default(0),
  cover_url: z.string().url().max(500).nullable().optional(),
});

// À l'update, la formation_slug peut bouger (ré-affectation)
export const moduleUpdateSchema = moduleCreateSchema
  .partial()
  .extend({ formation_slug: z.string().trim().optional() });

// ============ Lessons ============
export const lessonCreateSchema = z.object({
  module_id: uuid,
  title: nonEmptyText(200),
  slug: slugSchema,
  content_md: z.string().max(100_000).optional(),
  summary_md: z.string().max(20_000).optional(),
  order: z.number().int().min(0).max(9999).default(0),
  cover_url: z.string().url().max(500).nullable().optional(),
  video_url: z.string().url().max(2000).nullable().optional(),
});

export const lessonUpdateSchema = lessonCreateSchema.partial().omit({ module_id: true });

// ============ Quizzes ============
export const quizCreateSchema = z.object({
  title: nonEmptyText(200),
  description: z.string().trim().max(1000).optional(),
  type: z.enum(["entrainement", "examen"]).default("entrainement"),
  module_id: uuid.nullable().optional(),
  // Slug formation OBLIGATOIRE à la création (lien formation_quizzes)
  formation_slug: z
    .string()
    .trim()
    .min(1, "La formation associée est obligatoire"),
  time_limit_s: z.number().int().min(30).max(14400).nullable().optional(),
  timer_enabled: z.boolean().default(true),
  pass_threshold: z.number().int().min(0).max(100).default(70),
  is_mock_exam: z.boolean().default(false),
  max_attempts: z.number().int().min(1).max(50).nullable().optional(),
  retake_delay_hours: z.number().int().min(0).max(720).default(0),
  shuffle_questions: z.boolean().default(false),
  shuffle_choices: z.boolean().default(false),
  require_fullscreen: z.boolean().default(false),
  show_explanations_mode: z.enum(["always", "after_pass", "never"]).default("always"),
});

export const quizUpdateSchema = quizCreateSchema
  .partial()
  .extend({ formation_slug: z.string().trim().optional() });

// ============ Questions ============
export const questionCreateSchema = z.object({
  quiz_id: uuid,
  statement: nonEmptyText(2000),
  explanation: z.string().trim().max(5000).optional(),
  image_url: z.string().url().max(500).nullable().optional(),
  order: z.number().int().min(0).max(9999).default(0),
});

export const questionUpdateSchema = questionCreateSchema.partial().omit({ quiz_id: true });

export const choiceSchema = z.object({
  label: nonEmptyText(500),
  is_correct: z.boolean(),
  order: z.number().int().min(0).max(99),
});

export const choicesArraySchema = z
  .array(choiceSchema)
  .min(2, "Au moins 2 réponses requises")
  .max(10, "Maximum 10 réponses")
  .refine((arr) => arr.some((c) => c.is_correct), {
    message: "Au moins une bonne réponse est requise",
  });

// ============ Storage upload ============
export const MAX_UPLOAD_SIZE = 5 * 1024 * 1024; // 5 MB
export const ALLOWED_IMAGE_TYPES = [
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/gif",
  "image/svg+xml",
];

export function validateUpload(file: File) {
  if (file.size > MAX_UPLOAD_SIZE) {
    throw new Error("Fichier > 5 MB");
  }
  if (!ALLOWED_IMAGE_TYPES.includes(file.type)) {
    throw new Error("Format non autorisé (jpeg, png, webp, gif, svg uniquement)");
  }
  const ext = file.name.split(".").pop()?.toLowerCase() ?? "";
  if (!["jpg", "jpeg", "png", "webp", "gif", "svg"].includes(ext)) {
    throw new Error("Extension de fichier non autorisée");
  }
  return ext;
}

// ============ Formation settings ============
export const formationSettingsSchema = z.object({
  organisme_nom: nonEmptyText(160),
  organisme_siret: z.string().trim().max(20).nullable().optional(),
  organisme_num_da: z.string().trim().max(40).nullable().optional(),
  organisme_adresse: z.string().trim().max(300).nullable().optional(),
  organisme_email: z.string().trim().max(254).nullable().optional(),
  organisme_telephone: z.string().trim().max(30).nullable().optional(),
  organisme_responsable: z.string().trim().max(120).nullable().optional(),
  formation_titre: nonEmptyText(300),
  formation_rncp: z.string().trim().max(40),
  formation_duree_h: z.number().int().min(1).max(10000),
  formation_public: z.string().trim().max(2000).nullable().optional(),
  formation_prerequis: z.string().trim().max(2000).nullable().optional(),
  formation_objectifs: z.string().trim().max(5000).nullable().optional(),
  formation_methodes: z.string().trim().max(5000).nullable().optional(),
  formation_evaluation: z.string().trim().max(5000).nullable().optional(),
  formation_handicap: z.string().trim().max(2000).nullable().optional(),
  formation_referent_handicap: z.string().trim().max(200).nullable().optional(),
  formation_tarif: z.string().trim().max(200).nullable().optional(),
  formation_delai_acces: z.string().trim().max(500).nullable().optional(),
  indicateur_satisfaction: z.number().min(0).max(5).nullable().optional(),
  indicateur_reussite: z.number().min(0).max(100).nullable().optional(),
});

// ============ Satisfaction survey ============
const note = z.number().int().min(1).max(5);
export const surveySchema = z.object({
  type: z.enum(["chaud", "froid"]),
  note_globale: note,
  note_contenu: note,
  note_pedagogie: note,
  note_plateforme: note,
  note_accompagnement: note,
  points_forts: z.string().trim().max(2000).optional(),
  points_ameliorer: z.string().trim().max(2000).optional(),
  recommandation: z.number().int().min(0).max(10),
  situation_pro: z.enum(["emploi", "formation", "recherche", "autre"]).optional(),
  situation_detail: z.string().trim().max(1000).optional(),
});

// ============ Placement (positionnement initial) ============
export const placementQuestionSchema = z
  .object({
    bloc_id: z.number().int().positive(),
    qtype: z.enum(["qcm", "qr", "image"]).default("qcm"),
    formation_slug: z
      .string()
      .trim()
      .min(1, "La formation associée est obligatoire"),
    prompt: nonEmptyText(1000),
    choices: z.array(z.string().trim().max(300)).max(6).default([]),
    correct_index: z.number().int().min(0).max(5).default(0),
    expected_answer: z.string().trim().max(2000).nullable().optional(),
    image_url: z.string().url().max(2000).nullable().optional(),
    difficulty: z.enum(["facile", "standard", "difficile"]).default("standard"),
    order: z.number().int().min(0).default(0),
    active: z.boolean().default(true),
  })
  .superRefine((d, ctx) => {
    // QCM / image : 2-6 choix valides + correct_index dans la plage
    if (d.qtype === "qcm" || d.qtype === "image") {
      const valid = d.choices.filter((c) => c.length > 0);
      if (valid.length < 2) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["choices"],
          message: "Au moins 2 choix sont requis",
        });
      }
      if (d.correct_index >= valid.length) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["correct_index"],
          message: "L'index de la bonne réponse dépasse le nombre de choix",
        });
      }
    }
    // QR : pas de choix, expected_answer optionnelle (correction manuelle)
    // Image : URL d'image obligatoire
    if (d.qtype === "image" && !d.image_url) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["image_url"],
        message: "URL de l'image obligatoire pour le type 'image'",
      });
    }
  });

export const placementSubmitSchema = z.object({
  answers: z.record(z.string().uuid(), z.number().int().min(0).max(5)),
  duration_s: z.number().int().min(0).max(7200).optional(),
});

// ============ Ressources de leçon ============
const urlMax = z.string().trim().url("URL invalide").max(2000);

export const lessonResourceSchema = z.object({
  lesson_id: z.string().uuid(),
  kind: z.enum(["pdf", "video", "link", "doc", "image"]),
  title: nonEmptyText(200),
  url: urlMax,
  description: z.string().trim().max(500).optional().nullable(),
  size_kb: z.number().int().min(0).max(1_000_000).optional().nullable(),
  order: z.number().int().min(0).default(0),
});

// ============ Glossaire ============
export const glossaryTermSchema = z.object({
  term: nonEmptyText(120),
  definition_md: nonEmptyText(5000),
  bloc_id: z.number().int().positive().nullable().optional(),
  synonyms: z.array(z.string().trim().max(80)).max(20).default([]),
  source: z.string().trim().max(300).optional().nullable(),
});

// ============ Badges (Point #9) ============
export const badgeSchema = z.object({
  code: z
    .string()
    .trim()
    .min(2)
    .max(60)
    .regex(/^[a-z0-9_]+$/, "Code invalide (a-z, 0-9, _ uniquement)"),
  name: nonEmptyText(120),
  description: z.string().trim().max(500).optional().nullable(),
  icon: nonEmptyText(40),
  category: z.enum(["progression", "maitrise", "regularite", "excellence"]),
  tier: z.enum(["bronze", "silver", "gold"]),
  criteria: z.record(z.any()),
  points: z.number().int().min(0).max(1000).default(10),
  active: z.boolean().default(true),
  order: z.number().int().min(0).default(0),
});

// ============ Accompagnement formateur (Point #10) ============
export const coachingSessionSchema = z.object({
  user_id: uuid,
  trainer_id: uuid,
  scheduled_at: z.string().min(10),
  duration_min: z.number().int().min(5).max(480).default(30),
  mode: z.enum(["visio", "presentiel", "tel"]).default("visio"),
  meeting_url: z.string().trim().url().max(2000).optional().nullable(),
  location: z.string().trim().max(200).optional().nullable(),
  status: z.enum(["prevue", "tenue", "annulee", "no_show"]).default("prevue"),
  agenda: z.string().trim().max(4000).optional().nullable(),
  summary: z.string().trim().max(8000).optional().nullable(),
});

export const coachingNoteSchema = z.object({
  user_id: uuid,
  trainer_id: uuid,
  body_md: nonEmptyText(8000),
  visible_to_student: z.boolean().default(false),
  pinned: z.boolean().default(false),
});

// ============ Accessibilité (Point #12) ============
export const a11yPrefsSchema = z.object({
  a11y_font_scale: z.number().min(0.85).max(1.6),
  a11y_dyslexia_font: z.boolean(),
  a11y_high_contrast: z.boolean(),
  a11y_reduced_motion: z.boolean(),
  a11y_underline_links: z.boolean(),
  a11y_notes: z.string().trim().max(2000).optional().nullable(),
  a11y_rqth: z.boolean(),
});

export const a11yRequestSchema = z.object({
  category: z.enum(["visuel", "auditif", "moteur", "cognitif", "dys", "autre"]),
  description: nonEmptyText(2000),
  adaptations_requested: z.string().trim().max(2000).optional().nullable(),
});

export const a11yAdminUpdateSchema = z.object({
  status: z.enum(["nouveau", "en_cours", "valide", "refuse", "clos"]),
  admin_response: z.string().trim().max(4000).optional().nullable(),
});

// ============ Inscription / Financement (Point #16) ============
export const fundingKindEnum = z.enum([
  "opco","cpf","employeur","pole_emploi","auto","autre",
]);

export const enrollmentRequestSchema = z.object({
  full_name: nonEmptyText(120),
  email: emailSchema,
  phone: z.string().trim().max(30).optional().nullable(),
  funding_kind: fundingKindEnum,
  message: z.string().trim().max(2000).optional().nullable(),
});

export const funderSchema = z.object({
  name: nonEmptyText(200),
  kind: fundingKindEnum,
  contact_email: z.string().trim().email().max(254).optional().nullable().or(z.literal("")),
  contact_phone: z.string().trim().max(30).optional().nullable(),
  siret: z.string().trim().max(20).optional().nullable(),
  portal_user_id: uuid.nullable().optional(),
  notes: z.string().trim().max(4000).optional().nullable(),
});

export const enrollmentSchema = z.object({
  user_id: uuid,
  funder_id: uuid.nullable().optional(),
  funding_kind: fundingKindEnum,
  session_label: z.string().trim().max(100).optional().nullable(),
  start_date: z.string().optional().nullable(),
  end_date: z.string().optional().nullable(),
  total_amount_cents: z.number().int().min(0).max(10_000_000).default(0),
  status: z.enum([
    "prospect","devis","accord_financeur","a_payer","en_cours","termine","abandon","refuse",
  ]),
  contract_url: z.string().url().max(2000).optional().nullable().or(z.literal("")),
  convention_url: z.string().url().max(2000).optional().nullable().or(z.literal("")),
  cpf_dossier_ref: z.string().trim().max(100).optional().nullable(),
});

export const paymentSchema = z.object({
  enrollment_id: uuid,
  due_date: z.string().min(10),
  amount_cents: z.number().int().min(0).max(10_000_000),
  paid_at: z.string().optional().nullable(),
  paid_amount_cents: z.number().int().min(0).max(10_000_000).default(0),
  method: z.enum(["virement","carte","prelevement","cpf","opco","autre"]).optional().nullable(),
  reference: z.string().trim().max(100).optional().nullable(),
  notes: z.string().trim().max(1000).optional().nullable(),
});

// ============ Helper : formatter une erreur Zod ============
export function formatZodError(err: unknown): string {
  if (err instanceof z.ZodError) {
    return err.errors.map((e) => `${e.path.join(".")} : ${e.message}`).join(" · ");
  }
  return (err as Error)?.message ?? "Erreur inconnue";
}
