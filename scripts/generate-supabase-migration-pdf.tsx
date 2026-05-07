// =====================================================================
// Génère un PDF "Guide de migration SQL vers Supabase".
// Document à transmettre au client pour déployer la base sur son compte.
// Usage : npx tsx scripts/generate-supabase-migration-pdf.mjs
// Output : scripts/output/guide-migration-supabase.pdf
// =====================================================================

import React from "react";
import {
  Document,
  Page,
  Text,
  View,
  StyleSheet,
  renderToFile,
} from "@react-pdf/renderer";
import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUTPUT = resolve(__dirname, "output", "guide-migration-supabase.pdf");
mkdirSync(dirname(OUTPUT), { recursive: true });

// ---------- Couleurs (alignées DESIGN.md) ----------
const NAVY = "#0E1240";
const BRAND = "#2530D9";
const SIGNAL = "#9FE220";
const SIGNAL_DARK = "#609015";
const ROSE = "#e11d48";
const ROSE_LIGHT = "#fef2f2";
const AMBER = "#d97706";
const AMBER_LIGHT = "#fef3c7";
const EMERALD = "#059669";
const EMERALD_LIGHT = "#d1fae5";
const SLATE_500 = "#64748b";
const SLATE_700 = "#334155";
const SLATE_900 = "#0f172a";
const NAVY_50 = "#f8fafc";
const NAVY_100 = "#eef0f7";

// ---------- Styles ----------
const s = StyleSheet.create({
  page: {
    paddingTop: 38,
    paddingBottom: 60,
    paddingHorizontal: 44,
    fontFamily: "Helvetica",
    fontSize: 10,
    color: SLATE_900,
  },
  topBar: { height: 4, backgroundColor: SIGNAL, marginBottom: 16 },
  brandRow: { flexDirection: "row", alignItems: "center", gap: 10, marginBottom: 6 },
  brandTitle: { fontSize: 13, fontWeight: "bold", color: NAVY, letterSpacing: 0.4 },
  brandSubTitle: {
    fontSize: 13,
    fontWeight: "bold",
    color: SIGNAL_DARK,
    letterSpacing: 0.4,
    marginTop: 1,
  },
  metaLine: { fontSize: 8, color: SLATE_500, marginTop: 2 },
  h1: {
    fontSize: 22,
    fontWeight: "bold",
    color: NAVY,
    marginTop: 16,
    marginBottom: 4,
    letterSpacing: -0.3,
  },
  intro: {
    fontSize: 10,
    color: SLATE_700,
    lineHeight: 1.55,
    marginBottom: 14,
  },
  h2: {
    fontSize: 14,
    fontWeight: "bold",
    color: NAVY,
    marginTop: 18,
    marginBottom: 8,
    letterSpacing: -0.2,
  },
  h3: {
    fontSize: 11,
    fontWeight: "bold",
    color: NAVY,
    marginTop: 12,
    marginBottom: 6,
  },
  body: {
    fontSize: 9.5,
    color: SLATE_700,
    lineHeight: 1.55,
    marginBottom: 6,
  },
  bullet: {
    flexDirection: "row",
    fontSize: 9.5,
    color: SLATE_700,
    lineHeight: 1.55,
    marginBottom: 3,
  },
  bulletDot: { width: 12, color: BRAND, fontWeight: "bold" },
  card: {
    borderWidth: 1,
    borderColor: NAVY_100,
    borderRadius: 6,
    padding: 12,
    marginBottom: 12,
    backgroundColor: NAVY_50,
  },
  cardTitle: {
    fontSize: 10.5,
    fontWeight: "bold",
    color: NAVY,
    marginBottom: 6,
  },
  // Alerts
  alertWarn: {
    backgroundColor: AMBER_LIGHT,
    borderLeftWidth: 3,
    borderLeftColor: AMBER,
    padding: 10,
    borderRadius: 4,
    marginBottom: 10,
  },
  alertWarnTitle: {
    fontSize: 10,
    fontWeight: "bold",
    color: AMBER,
    marginBottom: 4,
  },
  alertWarnBody: { fontSize: 9, color: SLATE_700, lineHeight: 1.5 },
  alertCrit: {
    backgroundColor: ROSE_LIGHT,
    borderLeftWidth: 3,
    borderLeftColor: ROSE,
    padding: 10,
    borderRadius: 4,
    marginBottom: 10,
  },
  alertCritTitle: {
    fontSize: 10,
    fontWeight: "bold",
    color: ROSE,
    marginBottom: 4,
  },
  alertOk: {
    backgroundColor: EMERALD_LIGHT,
    borderLeftWidth: 3,
    borderLeftColor: EMERALD,
    padding: 10,
    borderRadius: 4,
    marginBottom: 10,
  },
  alertOkTitle: {
    fontSize: 10,
    fontWeight: "bold",
    color: EMERALD,
    marginBottom: 4,
  },
  // Group header
  groupHeader: {
    backgroundColor: NAVY,
    color: "white",
    padding: 8,
    borderRadius: 4,
    marginTop: 12,
    marginBottom: 6,
    fontSize: 11,
    fontWeight: "bold",
    letterSpacing: 0.2,
  },
  // Files list
  fileRow: {
    flexDirection: "row",
    paddingVertical: 3,
    paddingHorizontal: 4,
    fontSize: 9,
    borderBottomWidth: 0.5,
    borderBottomColor: NAVY_100,
  },
  fileRowAlt: {
    flexDirection: "row",
    paddingVertical: 3,
    paddingHorizontal: 4,
    fontSize: 9,
    borderBottomWidth: 0.5,
    borderBottomColor: NAVY_100,
    backgroundColor: NAVY_50,
  },
  fileNum: { width: 24, color: SLATE_500, fontWeight: "bold" },
  fileName: { width: 230, color: NAVY, fontFamily: "Courier" },
  fileDesc: { flex: 1, color: SLATE_700 },
  warnIcon: {
    color: AMBER,
    fontSize: 9,
    fontWeight: "bold",
    width: 12,
  },
  noWarn: { width: 12 },
  // Code block
  code: {
    backgroundColor: "#1e293b",
    color: "#e2e8f0",
    padding: 10,
    borderRadius: 4,
    fontSize: 8.5,
    fontFamily: "Courier",
    marginVertical: 6,
    lineHeight: 1.5,
  },
  // Footer
  pageFooter: {
    position: "absolute",
    bottom: 24,
    left: 44,
    right: 44,
    fontSize: 8,
    color: SLATE_500,
    textAlign: "center",
    borderTopWidth: 0.5,
    borderTopColor: NAVY_100,
    paddingTop: 8,
  },
});

// ---------- Données : ordre des fichiers ----------
const GROUPS = [
  {
    title: "GROUPE 0 — Schéma de base",
    description:
      "Tables fondamentales et données initiales. À exécuter en TOUT PREMIER.",
    files: [
      { n: 1, name: "schema.sql", desc: "Tables fondamentales (profiles, formations, modules, lessons, quizzes, questions)" },
      { n: 2, name: "seed.sql", desc: "Données initiales (formations, blocs, modules GOTRM v1)" },
    ],
  },
  {
    title: "GROUPE 1 — Permissions & sécurité",
    description: "Rôles, helpers RLS et durcissement.",
    files: [
      { n: 3, name: "admin_extensions.sql", desc: "Tables admin (groups) — pré-requis de security.sql" },
      { n: 4, name: "permissions_v2_step1.sql", desc: "Enum super_admin", warn: true },
      { n: 5, name: "permissions_v2_step2.sql", desc: "Helpers is_admin / has_formation_access / audit_logs" },
      { n: 6, name: "trainer_role.sql", desc: "Rôle formateur + helper is_trainer" },
      { n: 7, name: "security.sql", desc: "Durcissement storage + RLS", warn: true },
      { n: 8, name: "qualiopi.sql", desc: "formation_settings (singleton) + satisfaction_surveys" },
      { n: 9, name: "profiles_student_fields.sql", desc: "Champs étendus profiles stagiaire" },
    ],
  },
  {
    title: "GROUPE 2 — Multi-formation",
    description:
      "Infrastructure pour gérer plusieurs formations (Capa, GOTRM, Taxi-VTC, etc.).",
    files: [
      { n: 10, name: "formations_v2.sql", desc: "Catalogue des 7 formations actives", warn: true },
      { n: 11, name: "formation_settings_multi.sql", desc: "Migration singleton → multi-formation", warn: true },
      { n: 12, name: "multi_formation_sprint1.sql", desc: "current_formation_id + user_has_formation + autofill" },
    ],
  },
  {
    title: "GROUPE 3 — Features fonctionnelles",
    description:
      "Modules métier : enrollments, paie, gamification, messagerie, etc.",
    files: [
      { n: 13, name: "enrollment.sql", desc: "Funders + enrollments" },
      { n: 14, name: "enrollment_extras.sql", desc: "Champs convention Qualiopi" },
      { n: 15, name: "pedagogy.sql", desc: "Vidéos, ressources de leçon, glossary_terms" },
      { n: 16, name: "lesson_versions.sql", desc: "Versioning des leçons" },
      { n: 17, name: "question_bank.sql", desc: "Banque QCM/QR multi-formations" },
      { n: 18, name: "exam_v2.sql", desc: "Drapeaux + relecture quiz_attempts" },
      { n: 19, name: "mock_exam.sql", desc: "Examens blancs (flags quizzes)" },
      { n: 20, name: "qr_grading.sql", desc: "Workflow correction questions rédigées" },
      { n: 21, name: "placement.sql", desc: "Banque test de positionnement" },
      { n: 22, name: "placement_extensions.sql", desc: "qtype + image + formation_id", warn: true },
      { n: 23, name: "placement_filter_by_formation.sql", desc: "RPC submit_placement filtrée par formation", warn: true },
      { n: 24, name: "onboarding.sql", desc: "Documents d'entrée + acceptances" },
      { n: 25, name: "onboarding_documents_content.sql", desc: "Contenu des 3 docs d'accueil", warn: true },
      { n: 26, name: "tracking.sql", desc: "lesson_views (suivi consultation)", warn: true },
      { n: 27, name: "search.sql", desc: "Recherche globale pg_trgm" },
      { n: 28, name: "search_logs.sql", desc: "Tracking des recherches stagiaires" },
      { n: 29, name: "messaging.sql", desc: "Notifications + conversations + messages" },
      { n: 30, name: "messaging_trainer.sql", desc: "Extension messagerie formateur", warn: true },
      { n: 31, name: "gamification.sql", desc: "XP events + levels + streaks" },
      { n: 32, name: "achievements.sql", desc: "Badges + certificates" },
      { n: 33, name: "leaderboard_periods.sql", desc: "Classement par période", warn: true },
      { n: 34, name: "xp_antifarm.sql", desc: "Anti-farming XP", warn: true },
      { n: 35, name: "coaching.sql", desc: "Référent + sessions + at_risk_students" },
      { n: 36, name: "bpf_views.sql", desc: "Vues Bilan Pédagogique et Financier" },
      { n: 37, name: "inactivity_alerts.sql", desc: "Suivi inactivité Qualiopi" },
      { n: 38, name: "accessibility.sql", desc: "Préférences a11y + adaptations" },
      { n: 39, name: "attendance_signed.sql", desc: "Émargement digital signé" },
      { n: 40, name: "funder_signature.sql", desc: "Signature financeur sur convention", warn: true },
      { n: 41, name: "payments_log.sql", desc: "Journal paiements Stripe" },
      { n: 42, name: "privacy.sql", desc: "Locale + consentements RGPD" },
      { n: 43, name: "realtime.sql", desc: "Publication Realtime", warn: true },
      { n: 44, name: "storage_content_media.sql", desc: "Bucket content-media + policies" },
    ],
  },
  {
    title: "GROUPE 4 — RLS multi-formation",
    description:
      "À exécuter APRÈS le contenu pédagogique (les modules doivent être rattachés à une formation).",
    files: [
      { n: 45, name: "multi_formation_sprint2.sql", desc: "RLS lecture par formation accessible", warn: true },
      { n: 46, name: "rls_formation_scoping.sql", desc: "Restriction modules/lessons/quizzes", warn: true },
    ],
  },
  {
    title: "GROUPE 5 — Glossaires",
    description:
      "Le fichier glossary_extensions.sql est PRÉ-REQUIS de tous les autres glossaires.",
    files: [
      { n: 47, name: "glossary_extensions.sql", desc: "Ajoute formation_id à glossary_terms", warn: true },
      { n: 48, name: "glossary_capa.sql", desc: "Glossaire Capacité 3,5 t (base)" },
      { n: 49, name: "glossary_capa_plus.sql", desc: "Glossaire Capacité 3,5 t (extension)" },
      { n: 50, name: "glossary_gotrm.sql", desc: "Glossaire GOTRM" },
      { n: 51, name: "glossary_ecsr.sql", desc: "Glossaire ECSR (enseignants conduite)" },
      { n: 52, name: "glossary_ertv.sql", desc: "Glossaire ERTV" },
      { n: 53, name: "glossary_fimo_fco.sql", desc: "Glossaire FIMO/FCO" },
      { n: 54, name: "glossary_taxi_vtc.sql", desc: "Glossaire Taxi/VTC" },
      { n: 55, name: "glossary_commissionnaire.sql", desc: "Glossaire Commissionnaire" },
    ],
  },
  {
    title: "GROUPE 6 — Contenus Capacité 3,5 T",
    description: "Test de positionnement + 6 modules pédagogiques densifiés.",
    files: [
      { n: 56, name: "placement_questions_seed.sql", desc: "200 questions positionnement (8 formations)", warn: true },
      { n: 57, name: "capa_module_a_v3_dense.sql", desc: "Module A — Cadre juridique (5 leçons, 60 QCM, 8 QR)" },
      { n: 58, name: "capa_module_b_v3_dense.sql", desc: "Module B — Activité commerciale (3 leçons, 36 QCM)" },
      { n: 59, name: "capa_module_c_v3_dense.sql", desc: "Module C — Cadre réglementaire (4 leçons, 48 QCM)" },
      { n: 60, name: "capa_module_d_v3_dense.sql", desc: "Module D — Activité financière (4 leçons, 48 QCM)" },
      { n: 61, name: "capa_module_e_v3_dense.sql", desc: "Module E — Salariés / droit social (4 leçons, 48 QCM)" },
      { n: 62, name: "capa_module_f_v3_dense.sql", desc: "Module F — Sécurité (4 leçons, 48 QCM)" },
    ],
  },
  {
    title: "GROUPE 7 — Contenus GOTRM",
    description: "BC01-03 + dossier pro + examens blancs + MSP final.",
    files: [
      { n: 63, name: "gotrm_bc01_01_v2.sql", desc: "BC01 — Leçon 1" },
      { n: 64, name: "gotrm_bc01_02_v2.sql", desc: "BC01 — Leçon 2" },
      { n: 65, name: "gotrm_bc01_03_v2.sql", desc: "BC01 — Leçon 3" },
      { n: 66, name: "gotrm_bc01_04_v2.sql", desc: "BC01 — Leçon 4" },
      { n: 67, name: "gotrm_bc01_05_v2.sql", desc: "BC01 — Leçon 5" },
      { n: 68, name: "gotrm_bc01_06_v2.sql", desc: "BC01 — Leçon 6" },
      { n: 69, name: "gotrm_bc01_07_v2.sql", desc: "BC01 — Leçon 7" },
      { n: 70, name: "gotrm_bc01_08_v2.sql", desc: "BC01 — Leçon 8" },
      { n: 71, name: "gotrm_bc01_09_v2.sql", desc: "BC01 — Leçon 9" },
      { n: 72, name: "gotrm_bc01_10_v2.sql", desc: "BC01 — Leçon 10" },
      { n: 73, name: "gotrm_bc02_01_v2.sql", desc: "BC02 — Leçon 1" },
      { n: 74, name: "gotrm_bc02_02_v2.sql", desc: "BC02 — Leçon 2" },
      { n: 75, name: "gotrm_bc03_01_v2.sql", desc: "BC03 — Leçon 1" },
      { n: 76, name: "gotrm_bc03_02_v2.sql", desc: "BC03 — Leçon 2" },
      { n: 77, name: "gotrm_module_exploitation.sql", desc: "Module exploitation transport" },
      { n: 78, name: "gotrm_dossier_pro_entretien.sql", desc: "Dossier professionnel + entretien" },
      { n: 79, name: "gotrm_examen_blanc_bc01.sql", desc: "Examen blanc BC01" },
      { n: 80, name: "gotrm_examen_blanc_bc02.sql", desc: "Examen blanc BC02" },
      { n: 81, name: "gotrm_examen_blanc_bc03.sql", desc: "Examen blanc BC03" },
      { n: 82, name: "gotrm_msp_final.sql", desc: "Mise en Situation Professionnelle finale" },
    ],
  },
  {
    title: "GROUPE 8 — Optimisations finales",
    description: "Indexes et durcissement, à exécuter EN DERNIER.",
    files: [
      { n: 83, name: "p2_indexes_and_hardening.sql", desc: "Indexes performance + contraintes NOT NULL", warn: true },
    ],
  },
  {
    title: "GROUPE 9 — Tests (optionnel)",
    description: "À ne PAS exécuter en production.",
    files: [
      { n: 84, name: "e2e_seed.sql", desc: "Seed Playwright pour tests bout-en-bout (DEV uniquement)", warn: true },
    ],
  },
];

// ---------- Composants ----------
const Header = ({ title }) => (
  <View fixed>
    <View style={s.topBar} />
    <View style={s.brandRow}>
      <Text style={s.brandTitle}>MA FORMATION</Text>
      <Text style={s.brandSubTitle}>TRANSPORT</Text>
    </View>
    <Text style={s.metaLine}>{title}</Text>
  </View>
);

const Footer = () => (
  <Text
    style={s.pageFooter}
    fixed
    render={({ pageNumber, totalPages }) =>
      `MA FORMATION TRANSPORT · Guide de migration Supabase · Page ${pageNumber} / ${totalPages}`
    }
  />
);

const Bullet = ({ children }) => (
  <View style={s.bullet}>
    <Text style={s.bulletDot}>•</Text>
    <Text style={{ flex: 1 }}>{children}</Text>
  </View>
);

const FileRow = ({ file, alt }) => (
  <View style={alt ? s.fileRowAlt : s.fileRow} wrap={false}>
    <Text style={s.fileNum}>{file.n}.</Text>
    <Text style={s.warnIcon}>{file.warn ? "!" : ""}</Text>
    <Text style={s.fileName}>{file.name}</Text>
    <Text style={s.fileDesc}>{file.desc}</Text>
  </View>
);

// ---------- Pages ----------
const PageCover = () => (
  <Page size="A4" style={s.page}>
    <Header title="Guide de migration · Base de données Supabase" />
    <Footer />
    <Text style={s.h1}>Guide de migration SQL</Text>
    <Text style={s.intro}>
      Ce document décrit la procédure complète pour déployer la base de
      données de la plateforme MA FORMATION TRANSPORT sur un nouveau projet
      Supabase. Il liste les 84 fichiers SQL à exécuter, dans le bon ordre,
      avec les prérequis et les points d'attention.
    </Text>

    <View style={s.alertOk}>
      <Text style={s.alertOkTitle}>Ce que vous obtiendrez à la fin</Text>
      <Text style={s.alertWarnBody}>
        Une base Supabase complète, prête pour la production, avec :{"\n"}·
        7 formations configurées (Capa 3,5 t, GOTRM, Taxi-VTC, ECSR, ERTV,
        FIMO/FCO, Commissionnaire){"\n"}· Test de positionnement (200
        questions){"\n"}· Contenu pédagogique densifié pour Capa 3,5 t et
        GOTRM (modules + quiz + examens blancs){"\n"}· Glossaires complets
        par formation{"\n"}· Multi-formation, RLS sécurisée, gamification,
        messagerie, BPF, Qualiopi.
      </Text>
    </View>

    <Text style={s.h2}>Pré-requis</Text>
    <Bullet>Compte Supabase actif (plan Pro recommandé pour la production).</Bullet>
    <Bullet>Projet Supabase créé (région Europe — Paris ou Francfort).</Bullet>
    <Bullet>Accès au SQL Editor du projet (Dashboard → SQL Editor).</Bullet>
    <Bullet>Les 84 fichiers SQL téléchargés en local (dossier supabase/).</Bullet>

    <Text style={s.h2}>Méthode d'exécution recommandée</Text>
    <View style={s.card}>
      <Text style={s.cardTitle}>Méthode A — SQL Editor (interface web)</Text>
      <Text style={s.body}>
        1. Ouvrir le SQL Editor de votre projet Supabase.{"\n"}
        2. Pour chaque fichier dans l'ordre indiqué : créer une nouvelle
        requête, coller le contenu intégral du fichier, puis cliquer "Run".
        {"\n"}
        3. Vérifier qu'aucune erreur n'est remontée avant de passer au
        suivant.{"\n"}
        4. Pour les fichiers marqués "!", lire les notes critiques (page
        suivante) avant exécution.
      </Text>
    </View>

    <View style={s.card}>
      <Text style={s.cardTitle}>Méthode B — CLI Supabase (avancé)</Text>
      <Text style={s.body}>
        Pour les développeurs : utiliser psql ou la CLI Supabase pour
        scripter l'exécution séquentielle. Voir l'annexe en fin de
        document.
      </Text>
    </View>

    <Text style={s.h2}>Durée estimée</Text>
    <Bullet>Méthode A (manuel) : 90 à 120 minutes pour les 84 fichiers.</Bullet>
    <Bullet>Méthode B (CLI scripté) : 15 à 25 minutes.</Bullet>
  </Page>
);

const PageNotesCritiques = () => (
  <Page size="A4" style={s.page}>
    <Header title="Notes critiques · Étapes spéciales" />
    <Footer />
    <Text style={s.h1}>Notes critiques</Text>
    <Text style={s.intro}>
      Les fichiers marqués d'un "!" dans la liste ordonnée nécessitent une
      attention particulière. Lisez ces notes AVANT d'exécuter le fichier
      concerné.
    </Text>

    <View style={s.alertCrit}>
      <Text style={s.alertCritTitle}>
        Étape 4 — permissions_v2_step1.sql (CRITIQUE)
      </Text>
      <Text style={s.alertWarnBody}>
        Ce fichier ajoute la valeur "super_admin" à un enum PostgreSQL.
        PostgreSQL impose qu'un ALTER TYPE ADD VALUE soit COMMITÉ avant
        d'être utilisé dans une autre transaction. Vous devez donc :{"\n"}·
        Exécuter step1 dans une requête SÉPARÉE.{"\n"}· Attendre la
        confirmation "Success" avant d'exécuter step2.{"\n"}· Si vous
        collez les deux fichiers dans une seule requête, step2 échouera
        avec une erreur "unsafe use of new value".
      </Text>
    </View>

    <View style={s.alertWarn}>
      <Text style={s.alertWarnTitle}>
        Étapes 7, 22, 23, 25, 26, 30, 33, 34, 40, 43 — pré-requis explicites
      </Text>
      <Text style={s.alertWarnBody}>
        Ces fichiers ont des pré-requis stricts sur des fichiers exécutés
        avant. Si vous suivez l'ordre numérique du présent document, les
        pré-requis sont respectés automatiquement. Ne pas sauter d'étape.
      </Text>
    </View>

    <View style={s.alertWarn}>
      <Text style={s.alertWarnTitle}>
        Étapes 45 et 46 — RLS multi-formation
      </Text>
      <Text style={s.alertWarnBody}>
        Les RLS lecture par formation (multi_formation_sprint2 et
        rls_formation_scoping) doivent être exécutées APRÈS l'insertion
        des modules pédagogiques (étapes 56 à 82). Si vous les exécutez
        avant, les contenus pédagogiques seront invisibles tant qu'ils ne
        sont pas rattachés à une formation.{"\n"}· Solution recommandée :
        suivre l'ordre du document — les modules sont seedés directement
        avec leur formation_id, donc l'ordre proposé fonctionne dans
        99 % des cas.
      </Text>
    </View>

    <View style={s.alertWarn}>
      <Text style={s.alertWarnTitle}>
        Étape 47 — glossary_extensions.sql (PRÉ-REQUIS)
      </Text>
      <Text style={s.alertWarnBody}>
        Ce fichier ajoute la colonne formation_id à la table
        glossary_terms. Il DOIT être exécuté AVANT tous les fichiers
        glossary_*.sql (étapes 48 à 55). Sinon les INSERT échouent avec
        "column formation_id does not exist".
      </Text>
    </View>

    <View style={s.alertWarn}>
      <Text style={s.alertWarnTitle}>
        Étape 56 — placement_questions_seed.sql (200 questions)
      </Text>
      <Text style={s.alertWarnBody}>
        Volumineux (200 questions sur 8 formations). Peut prendre 30-60
        secondes. Pré-requis : formations_v2 (étape 10) et
        placement_extensions (étape 22).
      </Text>
    </View>

    <View style={s.alertWarn}>
      <Text style={s.alertWarnTitle}>
        Étape 83 — p2_indexes_and_hardening.sql (DERNIER)
      </Text>
      <Text style={s.alertWarnBody}>
        Crée les indexes de performance et applique des contraintes NOT
        NULL sur formation_id. À exécuter EN DERNIER, après tout le
        contenu, sinon les contraintes échouent sur des lignes
        antérieures sans formation_id.
      </Text>
    </View>

    <View style={s.alertCrit}>
      <Text style={s.alertCritTitle}>
        Étape 84 — e2e_seed.sql (NE PAS exécuter en production)
      </Text>
      <Text style={s.alertWarnBody}>
        Ce fichier crée des comptes et données de test pour Playwright.
        Il ne doit JAMAIS être exécuté sur l'environnement de production.
        Réservé aux environnements de développement et CI uniquement.
      </Text>
    </View>
  </Page>
);

const PageListe = ({ groups }) => (
  <Page size="A4" style={s.page} wrap>
    <Header title="Liste ordonnée des 84 fichiers SQL" />
    <Footer />
    <Text style={s.h1}>Liste ordonnée</Text>
    <Text style={s.intro}>
      Exécuter les fichiers de 1 à 84, dans cet ordre exact. Le symbole
      "!" indique un fichier avec note critique (cf. section précédente).
    </Text>

    {groups.map((group, gi) => (
      <View key={gi} wrap={false}>
        <Text style={s.groupHeader}>{group.title}</Text>
        <Text
          style={{
            fontSize: 9,
            color: SLATE_500,
            marginBottom: 4,
            fontStyle: "italic",
          }}
        >
          {group.description}
        </Text>
        {group.files.map((file, fi) => (
          <FileRow key={file.n} file={file} alt={fi % 2 === 1} />
        ))}
      </View>
    ))}
  </Page>
);

const PageVerification = () => (
  <Page size="A4" style={s.page}>
    <Header title="Vérification post-déploiement" />
    <Footer />
    <Text style={s.h1}>Vérifications post-déploiement</Text>
    <Text style={s.intro}>
      Après l'exécution des 84 fichiers, lancez ces requêtes de contrôle
      dans le SQL Editor pour confirmer que tout est en place.
    </Text>

    <Text style={s.h3}>1. Compter les formations</Text>
    <View style={s.code}>
      <Text>SELECT count(*) FROM public.formations WHERE active = true;</Text>
      <Text>{"\n"}-- Résultat attendu : 7 formations actives</Text>
    </View>

    <Text style={s.h3}>2. Compter les modules pédagogiques</Text>
    <View style={s.code}>
      <Text>{`SELECT f.code, count(fm.module_id) AS nb_modules
FROM public.formations f
LEFT JOIN public.formation_modules fm ON fm.formation_id = f.id
WHERE f.active = true
GROUP BY f.code
ORDER BY f.code;`}</Text>
    </View>
    <Text style={s.body}>
      Résultats attendus : Capa 3,5 T = 6 modules ; GOTRM = ~17 modules.
    </Text>

    <Text style={s.h3}>3. Compter les questions du test de positionnement</Text>
    <View style={s.code}>
      <Text>{`SELECT formation_id, count(*) AS nb_questions
FROM public.placement_questions
GROUP BY formation_id;`}</Text>
      <Text>{"\n"}-- Résultat attendu : ~200 questions réparties sur 8 formations</Text>
    </View>

    <Text style={s.h3}>4. Vérifier les helpers RLS</Text>
    <View style={s.code}>
      <Text>{`SELECT proname FROM pg_proc
WHERE proname IN ('is_admin','is_super_admin','is_trainer',
                  'has_formation_access','user_has_formation');`}</Text>
      <Text>{"\n"}-- Résultat attendu : 5 lignes</Text>
    </View>

    <Text style={s.h3}>5. Vérifier le bucket de stockage</Text>
    <View style={s.code}>
      <Text>SELECT id, name, public FROM storage.buckets;</Text>
      <Text>{"\n"}-- Le bucket "content-media" doit apparaître</Text>
    </View>

    <Text style={s.h2}>Configuration de l'application Next.js</Text>
    <Text style={s.body}>
      Une fois la base déployée, configurez les variables d'environnement
      de l'application :
    </Text>
    <View style={s.code}>
      <Text>{`# .env.local
NEXT_PUBLIC_SUPABASE_URL=https://VOTRE-PROJET.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...

# Les valeurs sont dans Supabase Dashboard
# → Project Settings → API`}</Text>
    </View>

    <Text style={s.h2}>Création du premier compte admin</Text>
    <Text style={s.body}>
      Sur un déploiement vierge, aucun compte admin n'existe. Procédure :
    </Text>
    <Bullet>1. Créer un compte stagiaire normal via l'interface (/inscription).</Bullet>
    <Bullet>2. Dans Supabase SQL Editor, promouvoir ce compte :</Bullet>
    <View style={s.code}>
      <Text>{`UPDATE public.profiles
SET role = 'super_admin'
WHERE email = 'votre@email.fr';`}</Text>
    </View>
    <Bullet>3. Se déconnecter / reconnecter pour rafraîchir la session.</Bullet>
  </Page>
);

const PageAnnexeCLI = () => (
  <Page size="A4" style={s.page}>
    <Header title="Annexe · Méthode CLI scriptée" />
    <Footer />
    <Text style={s.h1}>Annexe — Exécution scriptée (CLI)</Text>
    <Text style={s.intro}>
      Pour les déploiements automatisés ou répétés (staging, recettes),
      voici un script bash qui exécute les 84 fichiers dans l'ordre via
      psql.
    </Text>

    <Text style={s.h3}>Pré-requis CLI</Text>
    <Bullet>psql installé localement (paquet postgresql-client).</Bullet>
    <Bullet>URL de connexion Postgres du projet Supabase (Settings → Database).</Bullet>
    <Bullet>Format : postgresql://postgres.[ref]:[pwd]@[region].pooler.supabase.com:6543/postgres</Bullet>

    <Text style={s.h3}>Script bash</Text>
    <View style={s.code}>
      <Text>{`#!/bin/bash
set -e
DB_URL="postgresql://postgres.xxx:PASSWORD@aws-0-eu-west-3.pooler.supabase.com:6543/postgres"
SUPA_DIR="./supabase"

FILES=(
  schema.sql seed.sql admin_extensions.sql
  permissions_v2_step1.sql
  permissions_v2_step2.sql
  trainer_role.sql security.sql qualiopi.sql
  profiles_student_fields.sql
  formations_v2.sql formation_settings_multi.sql
  multi_formation_sprint1.sql
  enrollment.sql enrollment_extras.sql
  pedagogy.sql lesson_versions.sql question_bank.sql
  exam_v2.sql mock_exam.sql qr_grading.sql
  placement.sql placement_extensions.sql placement_filter_by_formation.sql
  onboarding.sql onboarding_documents_content.sql
  tracking.sql search.sql search_logs.sql
  messaging.sql messaging_trainer.sql
  gamification.sql achievements.sql leaderboard_periods.sql xp_antifarm.sql
  coaching.sql bpf_views.sql inactivity_alerts.sql
  accessibility.sql attendance_signed.sql funder_signature.sql
  payments_log.sql privacy.sql realtime.sql storage_content_media.sql
  multi_formation_sprint2.sql rls_formation_scoping.sql
  glossary_extensions.sql
  glossary_capa.sql glossary_capa_plus.sql
  glossary_gotrm.sql glossary_ecsr.sql glossary_ertv.sql
  glossary_fimo_fco.sql glossary_taxi_vtc.sql glossary_commissionnaire.sql
  placement_questions_seed.sql
  capa_module_a_v3_dense.sql capa_module_b_v3_dense.sql
  capa_module_c_v3_dense.sql capa_module_d_v3_dense.sql
  capa_module_e_v3_dense.sql capa_module_f_v3_dense.sql
  gotrm_bc01_01_v2.sql gotrm_bc01_02_v2.sql gotrm_bc01_03_v2.sql
  gotrm_bc01_04_v2.sql gotrm_bc01_05_v2.sql gotrm_bc01_06_v2.sql
  gotrm_bc01_07_v2.sql gotrm_bc01_08_v2.sql gotrm_bc01_09_v2.sql
  gotrm_bc01_10_v2.sql
  gotrm_bc02_01_v2.sql gotrm_bc02_02_v2.sql
  gotrm_bc03_01_v2.sql gotrm_bc03_02_v2.sql
  gotrm_module_exploitation.sql gotrm_dossier_pro_entretien.sql
  gotrm_examen_blanc_bc01.sql gotrm_examen_blanc_bc02.sql
  gotrm_examen_blanc_bc03.sql gotrm_msp_final.sql
  p2_indexes_and_hardening.sql
)

for f in "\${FILES[@]}"; do
  echo "→ Exécution : $f"
  psql "$DB_URL" -f "$SUPA_DIR/$f" || {
    echo "❌ Erreur sur $f — arrêt"
    exit 1
  }
done

echo "✓ Migration terminée — 83 fichiers exécutés"`}</Text>
    </View>

    <View style={s.alertWarn}>
      <Text style={s.alertWarnTitle}>Notes</Text>
      <Text style={s.alertWarnBody}>
        · Le script ci-dessus exécute 83 fichiers (production). Le
        fichier 84 (e2e_seed.sql) est volontairement omis.{"\n"}· En cas
        d'erreur, le script s'arrête et indique le fichier fautif.
        Corriger puis relancer en commençant à ce fichier.{"\n"}· Tous
        les fichiers SQL livrés sont idempotents : ils peuvent être
        relancés sans casser les données existantes (DELETE puis INSERT
        des contenus, CREATE IF NOT EXISTS pour le schéma).
      </Text>
    </View>

    <Text style={s.h2}>Support</Text>
    <Text style={s.body}>
      En cas de difficulté pendant la migration, contactez l'équipe
      technique avec :{"\n"}· Le numéro de l'étape concernée (1 à 84).
      {"\n"}· Le message d'erreur PostgreSQL exact.{"\n"}· Une capture
      d'écran du SQL Editor montrant la requête fautive.
    </Text>
  </Page>
);

// ---------- Page : Mode d'emploi APIs & Services externes ----------
const PageApisIntro = () => (
  <Page size="A4" style={s.page}>
    <Header title="Mode d'emploi · APIs & services externes" />
    <Footer />
    <Text style={s.h1}>Mode d'emploi APIs & services</Text>
    <Text style={s.intro}>
      La base Supabase ne fait pas tout : la plateforme s'appuie sur 5
      services externes pour les paiements, les emails, le rate-limiting
      et l'observabilité. Cette section liste les comptes à créer, les
      clés à récupérer, et les variables d'environnement à renseigner.
    </Text>

    <Text style={s.groupHeader}>Vue d'ensemble — services à provisionner</Text>
    <View style={{ marginTop: 6 }}>
      <View style={s.fileRow} wrap={false}>
        <Text style={[s.fileName, { width: 100 }]}>Service</Text>
        <Text style={[s.fileName, { width: 100 }]}>Rôle</Text>
        <Text style={s.fileDesc}>Criticité</Text>
      </View>
      <View style={s.fileRowAlt} wrap={false}>
        <Text style={[s.fileName, { width: 100 }]}>Supabase</Text>
        <Text style={[s.fileDesc, { width: 100 }]}>BDD + Auth + Storage</Text>
        <Text style={s.fileDesc}>OBLIGATOIRE — cœur du système</Text>
      </View>
      <View style={s.fileRow} wrap={false}>
        <Text style={[s.fileName, { width: 100 }]}>Resend</Text>
        <Text style={[s.fileDesc, { width: 100 }]}>Envoi emails transac.</Text>
        <Text style={s.fileDesc}>OBLIGATOIRE — convocations, factures, notifs</Text>
      </View>
      <View style={s.fileRowAlt} wrap={false}>
        <Text style={[s.fileName, { width: 100 }]}>Stripe</Text>
        <Text style={[s.fileDesc, { width: 100 }]}>Paiements en ligne</Text>
        <Text style={s.fileDesc}>OBLIGATOIRE si financement direct</Text>
      </View>
      <View style={s.fileRow} wrap={false}>
        <Text style={[s.fileName, { width: 100 }]}>Upstash Redis</Text>
        <Text style={[s.fileDesc, { width: 100 }]}>Rate limiting</Text>
        <Text style={s.fileDesc}>RECOMMANDÉ — protège contre brute-force</Text>
      </View>
      <View style={s.fileRowAlt} wrap={false}>
        <Text style={[s.fileName, { width: 100 }]}>Sentry</Text>
        <Text style={[s.fileDesc, { width: 100 }]}>Monitoring erreurs</Text>
        <Text style={s.fileDesc}>RECOMMANDÉ — alertes & debug prod</Text>
      </View>
      <View style={s.fileRow} wrap={false}>
        <Text style={[s.fileName, { width: 100 }]}>Vercel Cron</Text>
        <Text style={[s.fileDesc, { width: 100 }]}>Tâches planifiées</Text>
        <Text style={s.fileDesc}>OBLIGATOIRE — alerte inactivité Qualiopi</Text>
      </View>
    </View>

    <Text style={s.h2}>1. Supabase (déjà configuré côté SQL)</Text>
    <Text style={s.body}>
      Une fois les 84 fichiers SQL exécutés, récupérez les 3 clés API
      depuis Dashboard Supabase → Project Settings → API :
    </Text>
    <Bullet>NEXT_PUBLIC_SUPABASE_URL — URL publique du projet (https://xxx.supabase.co)</Bullet>
    <Bullet>NEXT_PUBLIC_SUPABASE_ANON_KEY — clé anonyme (lecture publique)</Bullet>
    <Bullet>SUPABASE_SERVICE_ROLE_KEY — clé service (toute-puissante, JAMAIS exposée côté client)</Bullet>

    <View style={s.alertCrit}>
      <Text style={s.alertCritTitle}>Sécurité clés Supabase</Text>
      <Text style={s.alertWarnBody}>
        La SERVICE_ROLE_KEY contourne toutes les RLS. Elle ne doit
        JAMAIS apparaître dans le code client (NEXT_PUBLIC_*),
        uniquement côté serveur (route handlers, server actions, cron).
      </Text>
    </View>

    <Text style={s.h2}>2. Resend (emails transactionnels)</Text>
    <Text style={s.body}>
      Resend gère l'envoi des emails : convocations stagiaires, accusés
      d'inscription, notifications messagerie, factures, alertes
      formateur, exports RGPD.
    </Text>
    <Text style={s.h3}>Étapes</Text>
    <Bullet>Créer un compte sur resend.com (plan gratuit : 3 000 emails/mois).</Bullet>
    <Bullet>Vérifier votre domaine d'envoi (ex : maformationtransport.fr) — 4 enregistrements DNS à ajouter (SPF, DKIM, DMARC, MX).</Bullet>
    <Bullet>Créer une API Key dans Resend Dashboard → API Keys.</Bullet>
    <Bullet>Renseigner les variables :</Bullet>
    <View style={s.code}>
      <Text>{`RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxxxxxxxxx
EMAIL_FROM_ADDRESS=ne-pas-repondre@maformationtransport.fr
EMAIL_REPLY_TO=contact@maformationtransport.fr
LEADS_NOTIFY_EMAIL=admin@maformationtransport.fr`}</Text>
    </View>

    <View style={s.alertWarn}>
      <Text style={s.alertWarnTitle}>Sans Resend configuré</Text>
      <Text style={s.alertWarnBody}>
        Les inscriptions fonctionnent toujours (les enregistrements sont
        créés en base), mais aucun email ne part. Les stagiaires ne
        reçoivent ni leur confirmation ni leurs convocations.
      </Text>
    </View>
  </Page>
);

const PageApisStripe = () => (
  <Page size="A4" style={s.page}>
    <Header title="Mode d'emploi · Stripe, Upstash, Sentry, Cron" />
    <Footer />
    <Text style={s.h1}>3. Stripe (paiements en ligne)</Text>
    <Text style={s.body}>
      Stripe gère les paiements stagiaires (financement personnel ou
      acompte) et stocke les transactions dans la table payments_log.
    </Text>
    <Text style={s.h3}>Étapes</Text>
    <Bullet>Créer un compte sur stripe.com (KYC obligatoire pour activer le mode Live).</Bullet>
    <Bullet>Récupérer les clés API dans Dashboard Stripe → Developers → API keys :</Bullet>
    <View style={s.code}>
      <Text>{`STRIPE_SECRET_KEY=sk_live_xxxx          # PRODUCTION
# ou en recette :
STRIPE_SECRET_KEY=sk_test_xxxx          # TEST`}</Text>
    </View>
    <Bullet>Configurer le webhook : Dashboard Stripe → Developers → Webhooks → Add endpoint :</Bullet>
    <View style={s.code}>
      <Text>{`URL : https://VOTRE-DOMAINE.com/api/stripe/webhook
Events : checkout.session.completed,
         payment_intent.succeeded,
         payment_intent.payment_failed`}</Text>
    </View>
    <Bullet>Récupérer le Signing Secret du webhook :</Bullet>
    <View style={s.code}>
      <Text>STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxx</Text>
    </View>

    <View style={s.alertWarn}>
      <Text style={s.alertWarnTitle}>Mode Test vs Production</Text>
      <Text style={s.alertWarnBody}>
        En recette/staging : utiliser sk_test_*. En production :
        sk_live_*. Le Signing Secret est différent entre les deux modes.
        Toujours tester avec une carte test (4242 4242 4242 4242) avant
        de basculer en Live.
      </Text>
    </View>

    <Text style={s.h1}>4. Upstash Redis (rate limiting)</Text>
    <Text style={s.body}>
      Upstash gère la limitation de débit sur les endpoints sensibles
      (login, inscription, contact, recherche). Protège contre les
      attaques brute-force et le scraping.
    </Text>
    <Text style={s.h3}>Étapes</Text>
    <Bullet>Créer un compte sur upstash.com (plan gratuit : 10 000 requêtes/jour).</Bullet>
    <Bullet>Créer une base Redis (région Europe, type "Regional").</Bullet>
    <Bullet>Récupérer URL + Token dans la console Upstash :</Bullet>
    <View style={s.code}>
      <Text>{`UPSTASH_REDIS_REST_URL=https://xxx.upstash.io
UPSTASH_REDIS_REST_TOKEN=AYxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`}</Text>
    </View>

    <View style={s.alertWarn}>
      <Text style={s.alertWarnTitle}>Sans Upstash configuré</Text>
      <Text style={s.alertWarnBody}>
        Le rate-limiting est désactivé silencieusement (les endpoints
        fonctionnent, mais sans protection). À configurer impérativement
        avant ouverture publique du site.
      </Text>
    </View>

    <Text style={s.h1}>5. Sentry (monitoring erreurs)</Text>
    <Text style={s.body}>
      Sentry capture les erreurs JavaScript côté client et serveur,
      avec stack traces et alertes Slack/email.
    </Text>
    <Text style={s.h3}>Étapes</Text>
    <Bullet>Créer un compte sur sentry.io (plan gratuit : 5 000 erreurs/mois).</Bullet>
    <Bullet>Créer un projet "Next.js".</Bullet>
    <Bullet>Récupérer le DSN dans Settings → Client Keys (DSN) :</Bullet>
    <View style={s.code}>
      <Text>{`NEXT_PUBLIC_SENTRY_DSN=https://xxx@oxxx.ingest.sentry.io/xxx
SENTRY_ENVIRONMENT=production`}</Text>
    </View>

    <Text style={s.h1}>6. Vercel Cron (tâches planifiées)</Text>
    <Text style={s.body}>
      L'application a une tâche cron quotidienne pour détecter les
      stagiaires inactifs (Qualiopi : suivi obligatoire). Configurée
      via vercel.json (déjà présent dans le repo).
    </Text>
    <Text style={s.h3}>Étapes</Text>
    <Bullet>Générer un secret aléatoire (ex : openssl rand -hex 32).</Bullet>
    <Bullet>Renseigner dans Vercel → Project Settings → Environment Variables :</Bullet>
    <View style={s.code}>
      <Text>{`CRON_SECRET=ABCdef1234567890... (32+ chars aléatoires)`}</Text>
    </View>
    <Bullet>Vercel exécute automatiquement /api/cron/inactivity à 06:00 UTC chaque jour.</Bullet>

    <View style={s.alertOk}>
      <Text style={s.alertOkTitle}>Vérification cron</Text>
      <Text style={s.alertWarnBody}>
        Après déploiement Vercel, contrôler dans Dashboard → Logs →
        filtrer "cron" : un appel doit apparaître à 06:00 UTC chaque
        jour. Sinon, vérifier vercel.json et le CRON_SECRET.
      </Text>
    </View>
  </Page>
);

const PageApisRecap = () => (
  <Page size="A4" style={s.page}>
    <Header title="Récapitulatif · Variables d'environnement complètes" />
    <Footer />
    <Text style={s.h1}>Variables d'environnement (.env)</Text>
    <Text style={s.intro}>
      Liste exhaustive des 16 variables d'environnement à renseigner
      dans Vercel (Project Settings → Environment Variables) ou en
      local dans .env.local. Distinguer les environnements
      Production / Preview / Development.
    </Text>

    <Text style={s.groupHeader}>Bloc 1 — Application</Text>
    <View style={s.code}>
      <Text>{`# URL publique de l'application (sans slash final)
NEXT_PUBLIC_APP_URL=https://maformationtransport.fr
NODE_ENV=production`}</Text>
    </View>

    <Text style={s.groupHeader}>Bloc 2 — Supabase</Text>
    <View style={s.code}>
      <Text>{`NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...   # SERVEUR UNIQUEMENT`}</Text>
    </View>

    <Text style={s.groupHeader}>Bloc 3 — Resend (emails)</Text>
    <View style={s.code}>
      <Text>{`RESEND_API_KEY=re_xxxxxxxxxxx
EMAIL_FROM_ADDRESS=ne-pas-repondre@maformationtransport.fr
EMAIL_REPLY_TO=contact@maformationtransport.fr
LEADS_NOTIFY_EMAIL=admin@maformationtransport.fr`}</Text>
    </View>

    <Text style={s.groupHeader}>Bloc 4 — Stripe (paiements)</Text>
    <View style={s.code}>
      <Text>{`STRIPE_SECRET_KEY=sk_live_xxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxx`}</Text>
    </View>

    <Text style={s.groupHeader}>Bloc 5 — Upstash Redis (rate limit)</Text>
    <View style={s.code}>
      <Text>{`UPSTASH_REDIS_REST_URL=https://xxx.upstash.io
UPSTASH_REDIS_REST_TOKEN=AYx...`}</Text>
    </View>

    <Text style={s.groupHeader}>Bloc 6 — Sentry (monitoring)</Text>
    <View style={s.code}>
      <Text>{`NEXT_PUBLIC_SENTRY_DSN=https://xxx@oxxx.ingest.sentry.io/xxx
SENTRY_ENVIRONMENT=production`}</Text>
    </View>

    <Text style={s.groupHeader}>Bloc 7 — Cron (Vercel)</Text>
    <View style={s.code}>
      <Text>{`CRON_SECRET=ABCdef1234567890... (générer 32+ chars aléatoires)`}</Text>
    </View>

    <Text style={s.h2}>Checklist de mise en production</Text>
    <Bullet>Domaine acheté + DNS pointant vers Vercel.</Bullet>
    <Bullet>SSL/TLS activé automatiquement par Vercel (gratuit, auto-renouvellement).</Bullet>
    <Bullet>Domaine Resend vérifié (DNS SPF/DKIM/DMARC propagé).</Bullet>
    <Bullet>Stripe en mode Live + KYC validé + webhook actif.</Bullet>
    <Bullet>Upstash Redis créé et accessible.</Bullet>
    <Bullet>Sentry projet créé et DSN renseigné.</Bullet>
    <Bullet>16 variables d'env renseignées dans Vercel (Production + Preview).</Bullet>
    <Bullet>vercel.json présent dans le repo (cron déjà configuré).</Bullet>
    <Bullet>Premier compte super_admin créé via SQL (cf. page Vérifications).</Bullet>
    <Bullet>Tests manuels : inscription, paiement test, envoi email, login.</Bullet>

    <View style={s.alertOk}>
      <Text style={s.alertOkTitle}>Coût mensuel estimé (production)</Text>
      <Text style={s.alertWarnBody}>
        Supabase Pro : 25 $/mois · Resend : 0 à 20 $ selon volume ·
        Stripe : 1,4 % + 0,25 € par transaction · Upstash : gratuit
        jusqu'à 10 k req/jour · Sentry : gratuit jusqu'à 5 k erreurs ·
        Vercel Pro : 20 $/mois (pour cron + analytics).{"\n"}{"\n"}
        Total infra fixe : ≈ 65 $/mois (hors commissions Stripe).
      </Text>
    </View>
  </Page>
);

// ---------- Document ----------
const Doc = () => (
  <Document
    title="Guide de migration Supabase — MA FORMATION TRANSPORT"
    author="MA FORMATION TRANSPORT"
    subject="Procédure de déploiement de la base de données SQL"
  >
    <PageCover />
    <PageNotesCritiques />
    <PageListe groups={GROUPS} />
    <PageVerification />
    <PageApisIntro />
    <PageApisStripe />
    <PageApisRecap />
    <PageAnnexeCLI />
  </Document>
);

// ---------- Génération ----------
(async () => {
  console.log("→ Génération du PDF...");
  await renderToFile(<Doc />, OUTPUT);
  console.log(`✓ PDF généré : ${OUTPUT}`);
})();
