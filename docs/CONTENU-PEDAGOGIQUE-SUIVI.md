# Chantier contenus pédagogiques — suivi et architecture

> Créé le 12/07/2026. Contenus produits par IA sur référentiels officiels,
> en l'absence des supports client. **Tout passe par le statut « à valider »
> (`question_bank.active = false`) et une relecture formateur avant mise
> en production.** Ce document est LA source de vérité du chantier.

## 1. Audit de l'existant (12/07/2026, base de production)

| Formation | Modules | Leçons | QCM actifs | QR actives | Inscriptions |
|---|---|---|---|---|---|
| GOTRM | 42 | 163 | 184 | 68 | 5 |
| Capacité ≤ 3,5 t | 6 | 24 | 288 | 55 | 2 |
| Capacité > 3,5 t | 0 → **1 (pilote)** | 0 → **4** | 0 → **12 à valider** | 0 → **18 à valider** | 0 |
| FIMO / FCO | 0 | 0 | 0 | 0 | 0 |
| Taxi & VTC | 0 | 0 | 0 | 0 | 0 |
| Commissionnaire | 0 | 0 | 0 | 0 | 0 |
| ERTV | 0 | 0 | 0 | 0 | 0 |
| ECSR | 0 | 0 | 0 | 0 | 0 |

Constats clés :
- 6 formations vides sur 8 ; aucune n'a d'inscrit → les insertions y sont
  invisibles des apprenants (double sécurité avec `active=false`).
- **1 seule QR sur 123 possède un barème** (`scoring_grid`) : les
  « questions rédigées » avec barème sont à construire partout.
- Modèle : `question_bank.type` ∈ {`qcm`, `qr`} ; « question courte » et
  « question rédigée » se distinguent par tags (`question-courte` /
  `question-redigee`), `max_score` (2 vs 5) et présence du barème.
- Conventions : difficulté `facile|moyen|difficile`, tags kebab-case
  (`capa-lourd`, `module-f`, …), `source_ref` unique = clé anti-doublon.

## 2. Architecture pédagogique cible par formation

Chaque module = objectif, leçons riches (callouts 🎯📌⚠️💡✅🔍❌🎓,
tableaux, `:::flow`, `:::timeline`), quiz de validation, synthèse.
Volumes cibles par formation : **≥ 200 QC, ≥ 200 QR, QCM complémentaires,
2 examens blancs.** Répartition 30 % facile / 45 % moyen / 25 % difficile.

### Capacité > 3,5 t (10 modules — annexe I du règl. CE 1071/2009)
M0 Méthodo & examen · **MF Accès à la profession et au marché ✅ pilote** ·
MA Droit civil · MB Droit commercial · MC Droit social · MD Droit fiscal ·
ME Gestion commerciale et financière · MG Normes techniques & exploitation ·
MH Sécurité routière · M9 Préparation examen + 2 examens blancs.

### FIMO / FCO marchandises (référentiel arrêté du 3 janvier 2008 modifié)
M0 Cadre & titres (FIMO 140 h, FCO 35 h/5 ans, CQC) · T1 Conduite
rationnelle & sécurité (véhicule, chargement, arrimage) · T2 Réglementation
transport (règl. 561/2006, chronotachygraphe, documents) · T3 Santé,
sécurité routière & environnementale · T4 Service, logistique, image de
l'entreprise · M5 Évaluations + mises en situation.

### Taxi & VTC (examen CMA : tronc commun + spécialités)
M1 Réglementation T3P (cartes pro, ADS, loi Grandguillaume) ·
M2 Gestion d'entreprise · M3 Sécurité routière · M4 Français ·
M5 Anglais · M6 Connaissance du territoire · M7 Spécifique Taxi
(tarification, équipements) · M8 Spécifique VTC (réservation préalable) ·
M9 Préparation admissibilité + admission.

### Commissionnaire de transport
M1 Cadre juridique de la commission · M2 Contrat de commission &
responsabilités · M3 Organisation des transports & multimodal ·
M4 International & douane (Incoterms) · M5 Assurances & litiges ·
M6 Gestion financière · M7 Préparation examen.
⚠ Programme exact de l'examen à faire confirmer par le formateur.

### ERTV — Exploitant régulateur transport de voyageurs
M1 Cadre réglementaire voyageurs (services réguliers, occasionnels, SLO) ·
M2 Conception d'offre, graphicage & habillage · M3 Exploitation &
régulation · M4 Réglementation sociale voyageurs · M5 Sécurité &
accessibilité PMR · M6 Qualité & relation AO · M7 Préparation évaluation.
⚠ Référentiel RNCP à faire confirmer (blocs de compétences exacts).

### ECSR — Enseignant de la conduite (titre pro, 2 CCP)
CCP1 Former à la conduite (REMC, séances individuelles/collectives,
évaluation) — 4 modules · CCP2 Sensibiliser à la sécurité routière
(publics spécifiques, actions) — 3 modules · M8 Préparation session titre.

### Compléments GOTRM & Capacité ≤ 3,5 t
GOTRM : 68 QR → 200 (+132) + 200 QC. Capa léger : 55 QR → 200 (+145)
+ 200 QC + renfort QCM difficiles. Dédoublonnage par `source_ref` et
revue des énoncés existants avant chaque lot.

## 3. Méthode de production par lots

1 lot = 1 module complet (4-6 leçons + 12-20 QCM + 15-25 QC + 8-15 QR)
dans UN fichier SQL idempotent `supabase/<formation>_module_<x>_v1.sql` :
- pattern DO-block du pilote (résolution par slug, DELETE ciblé, INSERT) ;
- `source_ref` uniques préfixés (`CAPA-LOURD-F-…`) ;
- questions `active=false` ; requêtes de contrôle en fin de fichier ;
- validation automatique avant livraison : JSON des choix (1 bonne
  réponse exactement), unicité des `source_ref`, comptages.

Application : par Abdelkader dans le SQL editor Supabase (ou via MCP sur
demande explicite). Jamais d'activation automatique.

## 4. Suivi de production

| Lot | Contenu | Fichier | État |
|---|---|---|---|
| 1 | Capa lourd — Module F (pilote) : 4 leçons, quiz, 12 QCM, 10 QC, 8 QR | `capa_lourd_module_f_v1.sql` | ✅ livré, **à appliquer + valider** |
| 2+ | Capa lourd — M0, MA…M9 | — | ⏳ après validation pilote |
| … | FIMO/FCO, Taxi-VTC, ECSR, ERTV, Commissionnaire | — | ⏳ |
| UI | Étape 10 — refonte admin banque/validation/imports | — | ⏳ |

## 5. Checklist de validation formateur (par lot)

- [ ] Lire chaque leçon : exactitude réglementaire, ton, niveau.
- [ ] Vérifier les chiffres réglementaires signalés (montants, délais,
      seuils) — en particulier ceux marqués ⚠ ci-dessous.
- [ ] Passer le quiz du module : chaque QCM a une seule bonne réponse
      plausible, les distracteurs sont crédibles, l'explication est juste.
- [ ] Relire QC : la réponse attendue est la seule raisonnable ; ajouter
      des variantes acceptées si besoin.
- [ ] Relire QR : réponse modèle complète, barème applicable tel quel.
- [ ] Activer les questions validées (Admin → Banque → Validation),
      corriger ou supprimer les autres.
- [ ] Vérifier les compteurs du dashboard après activation.

### Points signalés « à vérifier » (lot 1 — pilote)
- Sanction pénale exercice sans inscription : art. L. 3452-6 (1 an /
  15 000 €) — confirmer la rédaction en vigueur.
- Modalités précises de l'épreuve écrite annuelle (nombre de questions,
  barème, date) : fixées par décision annuelle, à actualiser chaque année.
- Dispense d'examen par expérience (art. 9 règl. 1071/2009, gestion
  continue 10 ans avant le 4/12/2009) : formulation à valider.
