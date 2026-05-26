// Génère le "Guide du présentateur" (PDF) accompagnant le PowerPoint
// d'audit Capacité <= 3,5 t. Miniatures slides + notes orales + FAQ.
//   npx tsx scripts/build-notes.tsx
//   -> livraison/notes-presentateur-capacite-3-5t.pdf
import React from "react";
import {
  Document, Page, View, Text, Image, Svg, Circle, Path, Rect, StyleSheet, renderToFile,
} from "@react-pdf/renderer";

const C = {
  night: "#0B0F24", navy: "#0E1240", navy2: "#161B3D", brand: "#2530D9",
  lime: "#9FE220", lime700: "#5C8A0F", gold: "#A16207", ivory: "#FAF8F4",
  surface: "#F2EFE8", paper: "#FFFFFF", slate: "#44506B", muted: "#6B7793",
  faint: "#9AA3B8", border: "#E4DFD5", borderDark: "#222A55", white: "#FFFFFF",
  whiteDim: "rgba(255,255,255,0.66)",
};
const PAD = 46;
const CW = 595.28 - 2 * PAD; // largeur contenu A4

const s = StyleSheet.create({
  light: { backgroundColor: C.ivory, paddingTop: 40, paddingBottom: 56, paddingHorizontal: PAD, fontFamily: "Helvetica", color: C.navy },
  dark: { backgroundColor: C.night, color: C.white, padding: 46, fontFamily: "Helvetica" },
  eyebrow: { fontFamily: "Helvetica-Bold", fontSize: 8, letterSpacing: 2, color: C.lime700 },
  h1: { fontFamily: "Helvetica-Bold", fontSize: 20, color: C.navy, lineHeight: 1.2 },
});

function Mark({ size = 30 }: { size?: number }) {
  return (
    <Svg viewBox="0 0 100 100" style={{ width: size, height: size }}>
      <Circle cx="50" cy="50" r="46" fill={C.navy} stroke={C.lime} strokeWidth="3" />
      <Path d="M37 80 L46 44 L54 44 L63 80 Z" fill={C.lime} />
      <Path d="M30 38 L50 29 L70 38 L50 47 Z" fill={C.white} />
      <Circle cx="62" cy="52.6" r="2.2" fill={C.lime} />
    </Svg>
  );
}
function Footer() {
  return (
    <View fixed style={{ position: "absolute", bottom: 24, left: PAD, right: PAD, flexDirection: "row", justifyContent: "space-between", borderTopWidth: 0.5, borderTopColor: C.border, paddingTop: 6 }}>
      <Text style={{ fontSize: 7, color: C.faint }}>Guide du présentateur · Capacité de transport (3,5 t et moins)</Text>
      <Text style={{ fontSize: 7, color: C.faint }} render={({ pageNumber, totalPages }) => `${pageNumber} / ${totalPages}`} />
    </View>
  );
}

const THUMB = (n: number) => `/tmp/pptxqa/thumbs/slide-${String(n).padStart(2, "0")}.png`;

// (n, intitulé, message clé, [ce qu'il faut dire])
const NOTES: [number, string, string, string[]][] = [
  [1, "Ouverture", "Poser un cadre sérieux et institutionnel.", [
    "Accueillez l'auditeur et présentez-vous (nom, fonction).",
    "Annoncez l'objet : présenter la formation Capacité (3,5 t et moins) et la façon dont l'école assure le suivi et la conformité.",
    "Rappelez que l'organisme est certifié Qualiopi et déclaré à la DREETS (les numéros sont affichés).",
  ]],
  [2, "Sommaire", "Annoncer le déroulé.", [
    "Présentez les 9 temps de la présentation.",
    "Donnez la durée indicative : 15 à 20 minutes.",
    "Invitez l'auditeur à poser ses questions à tout moment.",
  ]],
  [3, "L'organisme", "Montrer un organisme en règle et vérifiable.", [
    "Présentez l'école : centre spécialisé dans le transport, école en ligne.",
    "Pointez la carte d'identité à droite : SIRET, numéro de déclaration, Qualiopi, hébergement en UE.",
    "Insistez : toutes ces informations sont vérifiables.",
  ]],
  [4, "Focus Capacité (3,5 t et moins)", "Décrire la formation et sa structure.", [
    "Objectif : attestation de capacité pour exercer le transport léger de marchandises (3,5 t et moins).",
    "Présentez les 6 modules (du droit à la sécurité) couvrant tout le programme.",
    "Modalité : préparation à l'examen officiel, parcours souple, contenu dense.",
  ]],
  [5, "Parcours d'inscription", "Expliquer comment un stagiaire entre en formation.", [
    "Déroulez les 4 étapes : demande, création du dossier par l'administration, choix formation + pack, activation du compte.",
    "Précisez que les 3 packs sont des niveaux d'accompagnement ; le contenu pédagogique reste identique.",
  ]],
  [6, "Première connexion & documents", "Point fort : rien ne commence sans signatures.", [
    "Avant tout accès, le stagiaire valide son identité et signe les documents obligatoires (règlement intérieur, CGV, convention, livret d'accueil).",
    "Chaque signature est horodatée et scellée par une empreinte SHA-256 : preuve opposable.",
    "Souvent un point clé pour l'auditeur : montrez que l'accès est conditionné à ces signatures.",
  ]],
  [7, "Transition · Expérience stagiaire", "Annoncer la section.", [
    "Annoncez : voici concrètement ce que vit le stagiaire, et tout ce qui est tracé.",
  ]],
  [8, "Tableau de bord", "Le stagiaire est guidé en permanence.", [
    "Montrez la capture : à chaque connexion, le stagiaire voit sa progression et l'action suivante.",
    "Soulignez le suivi en temps réel.",
  ]],
  [9, "Modules pédagogiques", "Un contenu structuré et conforme.", [
    "Montrez un module : cours riches, vidéo d'introduction, leçons et quiz regroupés.",
    "Insistez sur la structure conforme au programme réglementaire.",
  ]],
  [10, "Quiz & examens", "Une évaluation double et sérieuse.", [
    "Deux types : QCM auto-corrigés et questions rédigées corrigées par un formateur (au plus près de l'examen).",
    "Les examens blancs se passent en conditions réelles : minuteur, plein écran, anti-triche.",
  ]],
  [11, "Suivi & motivation", "Tout est mesuré, l'échec est accompagné.", [
    "Progression, résultats et statistiques sont consultables à tout moment.",
    "Après un échec, les leçons à revoir sont proposées automatiquement (remédiation).",
    "La gamification motive sans dénaturer l'objectif : réussir l'examen.",
  ]],
  [12, "Documents du stagiaire", "Le stagiaire gère ses documents.", [
    "Il dépose ses justificatifs, accède à ses conventions et attestations, reçoit des notifications.",
    "Tout est tracé et consultable.",
  ]],
  [13, "Le formateur", "L'encadrement humain.", [
    "Le formateur suit ses stagiaires, corrige les questions rédigées, valide les examens.",
    "Il anime les sessions en direct et contre-signe les émargements.",
  ]],
  [14, "L'administration", "La gestion de l'organisme.", [
    "L'administration gère utilisateurs, formations, inscriptions, documents et signatures.",
    "Elle produit les exports et rapports utiles au pilotage et au contrôle.",
  ]],
  [15, "Transition · Conformité", "Annoncer le cœur de l'audit.", [
    "Annoncez : voici comment la plateforme répond aux exigences d'un organisme certifié.",
  ]],
  [16, "Les preuves Qualiopi", "Cocher, point par point, les exigences attendues.", [
    "Reprenez chaque ligne : positionnement, signatures, émargement matin/après-midi, suivi, satisfaction, réclamations, statistiques, archivage.",
    "Message : chaque exigence a une preuve concrète dans la plateforme.",
  ]],
  [17, "Traçabilité & émargement", "Prouver qui a fait quoi, et quand.", [
    "Montrez la feuille d'émargement : chaque présence est signée et scellée (empreinte + IP + horodatage).",
    "Mentionnez le journal d'audit conservé 5 ans et le reporting BPF prêt à exporter.",
  ]],
  [18, "La technique, simplement", "Rassurer sans jargon.", [
    "Restez simple : les données de chaque utilisateur sont cloisonnées, hébergées en Europe, sauvegardées.",
    "La protection des données (RGPD) est intégrée. Inutile d'entrer dans la technique.",
  ]],
  [19, "Pilotage & analytics", "Amélioration continue par la donnée.", [
    "L'école suit la réussite par formation, repère les stagiaires en difficulté, exporte ses indicateurs.",
    "Un appui pour l'amélioration continue (un critère Qualiopi).",
  ]],
  [20, "Conclusion", "Conclure et rassurer.", [
    "Résumez : une école moderne, conforme et sérieuse, pensée pour le suivi pédagogique et administratif.",
    "Proposez une démonstration en direct si l'auditeur le souhaite.",
    "Remerciez et laissez vos coordonnées.",
  ]],
];

const FAQ: [string, string][] = [
  ["Les signatures électroniques ont-elles valeur de preuve ?", "Oui : signature électronique simple mais probante (horodatage, empreinte SHA-256, adresse IP et appareil enregistrés). Adaptée et suffisante pour l'usage en formation (Qualiopi / FOAD)."],
  ["Comment prouvez-vous l'assiduité à distance ?", "Par un émargement détaillé séance par séance (avec la durée), en complément de l'émargement par demi-journée pour les sessions synchrones."],
  ["Où sont stockées les données ?", "Dans l'Union européenne (datacenters à Paris et Francfort), en conformité avec le RGPD."],
  ["Que se passe-t-il en cas d'échec d'un stagiaire ?", "La plateforme propose automatiquement les leçons à revoir (remédiation) et le formateur peut intervenir."],
  ["Pouvez-vous fournir les preuves lors d'un contrôle ?", "Oui : exports (BPF, CSV), journal d'audit conservé 5 ans, attestations et certificats générés à la demande."],
  ["Y a-t-il un test de positionnement à l'entrée ?", "Oui : il adapte le parcours et reste conservé au dossier du stagiaire."],
  ["Et les éléments encore « à compléter » ?", "Soyez transparent : le médiateur de la consommation et les taux de satisfaction / réussite seront renseignés après la première cohorte ; le dispositif de collecte est déjà en place."],
];

function Note({ e }: { e: [number, string, string, string[]] }) {
  const [n, titre, key, say] = e;
  const tw = 198, th = tw * (7.5 / 13.333);
  return (
    <View wrap={false} style={{ flexDirection: "row", marginBottom: 15 }}>
      <View style={{ borderWidth: 0.75, borderColor: C.border, borderRadius: 4, marginRight: 16, alignSelf: "flex-start" }}>
        <Image src={THUMB(n)} style={{ width: tw, height: th, borderRadius: 4 }} />
      </View>
      <View style={{ flex: 1 }}>
        <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 8, color: C.lime700, letterSpacing: 1.5 }}>{`SLIDE ${n}`}</Text>
        <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 13, color: C.navy, marginTop: 2 }}>{titre}</Text>
        <View style={{ flexDirection: "row", marginTop: 6, marginBottom: 6 }}>
          <View style={{ width: 3, backgroundColor: C.lime, borderRadius: 2, marginRight: 7 }} />
          <Text style={{ flex: 1, fontSize: 9, color: C.navy, fontFamily: "Helvetica-Bold", lineHeight: 1.3 }}>{key}</Text>
        </View>
        {say.map((t, i) => (
          <View key={i} style={{ flexDirection: "row", marginBottom: 3.5 }}>
            <View style={{ width: 3.5, height: 3.5, borderRadius: 2, backgroundColor: C.lime700, marginTop: 3.5, marginRight: 6 }} />
            <Text style={{ flex: 1, fontSize: 9, color: C.slate, lineHeight: 1.35 }}>{t}</Text>
          </View>
        ))}
      </View>
    </View>
  );
}

function Guide() {
  return (
    <Document title="Guide du présentateur — Capacité (3,5 t et moins)" author="MA FORMATION TRANSPORT">
      {/* Couverture */}
      <Page size="A4" style={s.dark}>
        <View style={{ position: "absolute", top: 0, left: 0, right: 0, height: 5, backgroundColor: C.lime }} />
        <View style={{ flexDirection: "row", alignItems: "center", marginTop: 8 }}>
          <Mark size={34} />
          <View style={{ marginLeft: 10 }}>
            <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 12, color: C.white }}>MA FORMATION</Text>
            <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 12, color: C.lime, marginTop: -2 }}>TRANSPORT</Text>
          </View>
        </View>
        <View style={{ flexGrow: 1, justifyContent: "center" }}>
          <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 9, color: C.lime, letterSpacing: 3 }}>GUIDE DU PRÉSENTATEUR</Text>
          <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 30, color: C.white, marginTop: 12, lineHeight: 1.1 }}>Vos notes pour présenter</Text>
          <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 30, color: C.white, lineHeight: 1.1 }}>à l'administration</Text>
          <Text style={{ fontSize: 12, color: C.whiteDim, marginTop: 16, maxWidth: 380, lineHeight: 1.5 }}>
            Pour chaque diapositive du PowerPoint « Capacité de transport (3,5 t et moins) » : le message clé et ce que vous pouvez dire. À la fin, les questions probables de l'auditeur et leurs réponses.
          </Text>
        </View>
        <Text style={{ fontSize: 8, color: C.faint }}>Document interne · à utiliser avec la présentation PowerPoint · Édition mai 2026</Text>
      </Page>

      {/* Conseils */}
      <Page size="A4" style={s.light}>
        <Footer />
        <Text style={s.eyebrow}>AVANT DE COMMENCER</Text>
        <Text style={[s.h1, { marginTop: 6 }]}>Réussir votre présentation</Text>
        <View style={{ marginTop: 16 }}>
          {[
            ["Durée", "Prévoyez 15 à 20 minutes de présentation, puis un temps d'échange. Ne lisez pas les slides mot à mot : appuyez-vous sur le visuel et reformulez."],
            ["Ton", "Restez factuel, posé et rassurant. Vous ne « vendez » pas : vous montrez un dispositif sérieux et conforme."],
            ["Interaction", "Invitez l'auditeur à poser ses questions à tout moment, et notez-les. Une question est une occasion de prouver la conformité."],
            ["Démonstration", "Ayez un compte de démonstration ouvert : si l'auditeur le souhaite, montrez en direct une signature, un émargement ou un module."],
            ["Supports", "Apportez une version imprimée de ce guide et du dossier de présentation. Gardez les numéros (SIRET, NDA, Qualiopi) à portée de main."],
            ["Transparence", "Sur les points encore « à compléter » (médiateur, taux après la 1re cohorte), soyez transparent : voir la FAQ en fin de guide."],
          ].map(([h, b], i) => (
            <View key={i} style={{ flexDirection: "row", marginBottom: 11 }}>
              <View style={{ width: 96 }}>
                <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 10.5, color: C.lime700 }}>{h}</Text>
              </View>
              <Text style={{ flex: 1, fontSize: 10, color: C.slate, lineHeight: 1.4 }}>{b}</Text>
            </View>
          ))}
        </View>
      </Page>

      {/* Fiches par slide (flux auto-paginé) */}
      <Page size="A4" style={s.light}>
        <Footer />
        <Text style={s.eyebrow}>NOTES, DIAPOSITIVE PAR DIAPOSITIVE</Text>
        <Text style={[s.h1, { marginTop: 6, marginBottom: 12 }]}>Ce qu'il faut dire</Text>
        {NOTES.map((e) => (
          <Note key={e[0]} e={e} />
        ))}
      </Page>

      {/* FAQ */}
      <Page size="A4" style={s.light}>
        <Footer />
        <Text style={s.eyebrow}>EN CAS DE QUESTION</Text>
        <Text style={[s.h1, { marginTop: 6 }]}>Questions probables de l'auditeur</Text>
        <View style={{ marginTop: 14 }}>
          {FAQ.map(([q, a], i) => (
            <View key={i} style={{ marginBottom: 12, borderLeftWidth: 3, borderLeftColor: C.lime, paddingLeft: 10 }}>
              <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 10.5, color: C.navy, marginBottom: 3 }}>{q}</Text>
              <Text style={{ fontSize: 9.5, color: C.slate, lineHeight: 1.4 }}>{a}</Text>
            </View>
          ))}
        </View>
      </Page>
    </Document>
  );
}

const OUT = "livraison/notes-presentateur-capacite-3-5t.pdf";
renderToFile(<Guide />, OUT)
  .then(() => console.log("✓ Guide généré : " + OUT))
  .catch((e) => { console.error(e); process.exit(1); });
