# Chantier contenus pédagogiques — suivi et architecture

> Créé le 12/07/2026. Contenus produits par IA sur référentiels officiels,
> en l'absence des supports client. **Tout passe par le statut « à valider »
> (`question_bank.active = false`) et une relecture formateur avant mise
> en production.** Ce document est LA source de vérité du chantier.

## 🎉 CHANTIER TERMINÉ — 6 formations vides comblées (13/07/2026)

Les **6 formations** qui étaient vides ont désormais un contenu complet :

| Formation | Modules | Questions | Examens blancs | Vérif. |
|---|---|---|---|---|
| Capacité > 3,5 t | 10 | 250 | 2 | QA + calculs script |
| FIMO / FCO | 6 | 160 | 2 | QA + calculs script |
| Taxi-VTC | 9 | 250 | 2 | QA + relecture agent (M1-M4) |
| ECSR | 6 | 160 | 2 | QA structurelle seule* |
| ERTV | 6 | 160 | 2 | QA structurelle seule* |
| Commissionnaire | 6 | 160 | 2 | QA structurelle seule* |
| **TOTAL produit** | **43** | **1 140** | **12** | — |

**QA globale finale : 432/432 QCM à réponse unique, 0 doublon sur les
1 140 énoncés, 0 tiret cadratin, 0 apostrophe fautive.**

\* **Important pour la validation** : ECSR, ERTV et Commissionnaire ont
passé ma **QA structurelle déterministe** (JSON, unicité, statuts,
examens blancs) mais **PAS la seconde relecture factuelle par agent**
(le workflow a manqué de crédits en fin de course). Ces 18 modules
reposent donc sur : les fiches de faits vérifiées fournies aux
rédacteurs + les marqueurs « à vérifier » sur les points mouvants + la
**validation formateur (obligatoire de toute façon)**. Priorité de
relecture : ces 3 formations, en particulier les chiffres réglementaires
(montants capacité financière voyageurs, plafonds DTS multimodal,
Incoterms, seuils VTC). Rien n'est actif sans validation humaine.

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
| 1 | Capa lourd — Module F (pilote) : 4 leçons, quiz, 12 QCM, 10 QC, 8 QR | `capa_lourd_module_f_v1.sql` | ✅ **appliqué en base** (30 questions à valider) |
| 2 | Capa lourd — Module A Droit civil : 4 leçons, quiz, 12 QCM, 10 QC, 8 QR | `capa_lourd_module_a_v1.sql` | ✅ livré, **à appliquer + valider** |
| 3 | Capa lourd — Module B Droit commercial : 4 leçons, quiz, 12 QCM, 10 QC, 8 QR | `capa_lourd_module_b_v1.sql` | ✅ livré, **à appliquer + valider** |
| 4 | Capa lourd — Module C Droit social : 4 leçons, quiz, 12 QCM, 10 QC, 8 QR | `capa_lourd_module_c_v1.sql` | ✅ livré, **à appliquer + valider** |
| 5 | Capa lourd — Module D Droit fiscal : 4 leçons, quiz, 12 QCM, 10 QC, 8 QR | `capa_lourd_module_d_v1.sql` | ✅ livré, **à appliquer + valider** |
| 6 | Capa lourd — Module E Gestion : 4 leçons, quiz, 12 QCM, 10 QC, 8 QR (19 calculs vérifiés par script) | `capa_lourd_module_e_v1.sql` | ✅ livré, **à appliquer + valider** |
| 7 | Capa lourd — Module G Normes techniques : 4 leçons, quiz, 12 QCM, 10 QC, 8 QR | `capa_lourd_module_g_v1.sql` | ✅ livré, **à appliquer + valider** |
| 8 | Capa lourd — Module H Sécurité routière : 4 leçons, quiz, 12 QCM, 10 QC, 8 QR | `capa_lourd_module_h_v1.sql` | ✅ livré, **à appliquer + valider** |
| 9 | Capa lourd — M0 Méthodo (2 leçons) + M9 Préparation (2 leçons, 6 QC + 4 QR transversales) + **2 examens blancs** (24 QCM ; 16 QCM + 8 QR, composés depuis la banque sans duplication) | `capa_lourd_module_m0_m9_v1.sql` | ✅ livré, **à appliquer + valider** |
| F1 | FIMO/FCO — Module 0 Qualification (FIMO/FCO/CQC) : 4 leçons, quiz, 12 QCM, 10 QC, 8 QR | `fimo_module_0_v1.sql` | ✅ livré, **à appliquer + valider** |
| F2 | FIMO/FCO — T1 Conduite rationnelle : 4 leçons, quiz, 12 QCM, 10 QC, 8 QR (4 calculs vérifiés) | `fimo_module_t1_v1.sql` | ✅ livré, **à appliquer + valider** |
| F3 | FIMO/FCO — T2 Réglementations (scénarios conducteur) : 4 leçons, quiz, 30 questions | `fimo_module_t2_v1.sql` | ✅ livré, **à appliquer + valider** |
| F4 | FIMO/FCO — T3 Santé/sécurité/sûreté : 4 leçons, quiz, 30 questions | `fimo_module_t3_v1.sql` | ✅ livré, **à appliquer + valider** |
| F5 | FIMO/FCO — T4 Service/image : 3 leçons, quiz, 30 questions | `fimo_module_t4_v1.sql` | ✅ livré, **à appliquer + valider** |
| F6 | FIMO/FCO — M5 Évaluation : 1 leçon, 10 questions transversales, **2 évaluations blanches** (20 QCM ; 10 QCM + 5 QR) | `fimo_module_m5_v1.sql` | ✅ livré, **à appliquer EN DERNIER + valider** |
| T1-9 | **Taxi-VTC complet** : 9 modules (cadre T3P, taxi vs VTC, gestion, sécurité, français/anglais, territoire, spécifique taxi, spécifique VTC, préparation), 29 leçons, 8 quiz + 2 examens blancs, 250 questions | `taxi_module_1..9_v1.sql` | ✅ livré (production multi-agents + QA orchestrateur), **à appliquer (1→8 puis 9) + valider** |
| … | ECSR, ERTV, Commissionnaire | — | 🔄 en production (workflow) |
| UI | Étape 10 — refonte admin banque/validation/imports | — | ⏳ |

## ✅ FORMATION TAXI-VTC : PRODUCTION TERMINÉE
9 modules, 29 leçons, 8 quiz + 2 examens blancs (24 QCM ; 16 QCM + 8 QR),
**250 questions** à valider. Production par agents parallèles sur fiches
de faits vérifiées, puis QA déterministe de l orchestrateur (12/12 QCM
par module à réponse unique, 48 refs d examens blancs toutes présentes,
tirets cadratins corrigés) et relecture factuelle adversariale par agent.
Points « à vérifier » systématiquement marqués dans les leçons :
PSC1/exigences locales, montants REVTC, conditions techniques véhicules
VTC, définitions locales des tarifs A/B/C/D, taux TVA transport, seuils
micro : le formateur tranche avec les textes en vigueur.
Cumul global (3 formations complètes) : **660 questions, 0 doublon**.

## ✅ FORMATION FIMO/FCO : PRODUCTION TERMINÉE
6 modules (M0, T1-T4, M5), 20 leçons, 5 quiz de module + 2 évaluations
blanches, **160 questions** (60 QCM + 60 QC + 40 QR), angle conducteur
(scénarios), toutes « à valider ».
Cumul global (2 formations complètes) : **410 questions, 0 doublon
vérifié sur l'ensemble, 156/156 QCM à réponse unique**.
⚠ Ordre d'application FIMO : lots F1→F5 puis F6 (les évaluations
blanches lient les questions des 5 modules par source_ref).

### Points signalés « à vérifier » (lots FIMO-3 à 6)
- T2 : règles 561/2006 réutilisées en scénarios (chiffres identiques
  aux modules capa C, formulations distinctes — 0 doublon vérifié) ;
  double équipage évoqué sans chiffrage détaillé (fenêtre 30 h) — le
  formateur peut approfondir.
- T3 : élimination alcool ~0,10-0,15 g/L/h (ordre de grandeur
  pédagogique), pictogrammes médicaments 2/3 — confirmer les
  formulations ; sanctions « passagers clandestins » volontairement
  non chiffrées (variables selon pays).
- T4 : contenu comportemental — relecture de ton par le formateur.
- M5 : modalités précises de l'évaluation FIMO (nombre de questions,
  seuils) renvoyées au centre — à préciser selon les textes.

## ✅ FORMATION CAPACITÉ > 3,5 T : PRODUCTION TERMINÉE
10 modules (M0, A-H, M9), 36 leçons, 8 quiz de module + 2 examens
blancs, **250 questions** (96 QCM + 86 QC + 68 QR), toutes « à
valider », **0 doublon vérifié sur l'ensemble** (le contrôle du lot 9 a
détecté et corrigé 2 QC intra-fichier qui reprenaient l'énoncé d'un
QCM : F-QC-04 et H-QC-06 reformulées).
⚠ Le module F ayant déjà été appliqué en base, **ré-appliquer
`capa_lourd_module_f_v1.sql`** (idempotent) pour bénéficier de la
reformulation, puis appliquer H et M0/M9.
Prochaine étape : validation formateur module par module (checklist
ci-dessous), puis production des 5 formations restantes.

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

### Points signalés « à vérifier » (lot FIMO-2 — Thème 1)
- Contenu technique (couple/zone verte, fading, ABS/ESP/AEBS, coupure
  d'injection) : conforme à l'enseignement standard — relecture
  formateur conduite recommandée.
- Forces d'arrimage (0,8/0,5 du poids) : réutilisées côté conducteur
  avec formulations distinctes du module G capa (0 doublon vérifié).
- Valeur d'étude 1,60 €/L dans le cas télématique : explicitement
  marquée « à ajuster au prix réel » dans l'énoncé et le corrigé.

### Points signalés « à vérifier » (lot FIMO-1 — Module 0)
- FIMO 140 h / FCO 35 h / passerelle 35 h / carte 5 ans : stables,
  relecture de confirmation (arrêté du 3 janvier 2008 modifié).
- Liste exacte des exemptions de qualification (dont « activité
  accessoire ») : vérifier la rédaction en vigueur.
- Modalités précises de l'évaluation finale FIMO (nombre de questions,
  seuils) : volontairement non chiffrées dans la leçon — le formateur
  peut les préciser selon les textes applicables.
- Organisme de délivrance des cartes (demande en ligne) : la leçon reste
  générique — préciser l'opérateur actuel si souhaité.

### Points signalés « à vérifier » (lot 8 — Module H)
- Vitesses PL (90/80/80/50) et interdistance 50 m : stables, confirmer.
- Interdictions week-end > 7,5 t (sam 22 h → dim 22 h) et régime des
  dérogations denrées périssables : vérifier l'arrêté en vigueur.
- Validités médicales du permis lourd (5/2/1 ans aux bornes 60/76 ans) :
  confirmer les seuils d'âge exacts.
- Alcool 0,5/0,8 g/L et téléphone 135 € + 3 points : stables, confirmer.
- Protocole de sécurité (R. 4515-4 s.) et déclaration AT 48 h : confirmer
  les rédactions en vigueur.

### Points signalés « à vérifier » (lot 7 — Module G)
- Masses/dimensions (19/26/38/44 t, 13 t essieu, 2,55/2,60 m,
  16,50/18,75 m) : stables, relecture de confirmation (R. 312-x).
- Sanctions surcharge : « amende par tranche de 1 000 kg, aggravée pour
  gros dépassements » — vérifier les classes exactes de contraventions
  en vigueur (la leçon reste volontairement générale).
- Hauteur : pas de limite générale en métropole — confirmer la
  formulation.
- Contrats types (règle des 3 t) : vérifier la rédaction actuelle du
  contrat type général.
- ADR : seuils 1.1.3.6 (« 1 000 points »), pneus PL 1 mm, extincteurs —
  à confirmer dans l'édition ADR en vigueur (biennale).

### Points signalés « à vérifier » (lot 6 — Module E)
- Délai de paiement transport 30 jours (L. 441-11 c. com.) : stable,
  confirmer la rédaction.
- Indexation gazole (L. 3222-1/L. 3222-2 c. transports) : mécanisme
  d'ordre public, formulation à valider.
- Repères sectoriels (carburant 20-30 % du CA, salaires 35-45 %, marge
  nette 1-4 %) : ordres de grandeur CNR à ajuster si besoin.
- Les 19 calculs des corrigés (trinôme, SR, CAF, BFR, crédit-bail) sont
  vérifiés par script — relecture métier néanmoins recommandée.

### Points signalés « à vérifier » (lot 5 — Module D)
- Remboursement TICPE gazole professionnel : seuil 7,5 t stable, mais
  tarif au litre et trajectoire de réduction fixés en loi de finances —
  à actualiser chaque année (les leçons ne chiffrent volontairement pas).
- IS 25 % / 15 % jusqu'à 42 500 € (conditions PME) : stable, confirmer.
- CVAE : extinction progressive, calendrier mouvant — vérifier.
- Facturation électronique : échéances 2026-2027 évoquées sans dates
  fermes dans la leçon — préciser selon le calendrier en vigueur.
- TVA gazole 100 % PL / 80 % essence-carburant VP : confirmer les taux
  de déductibilité en vigueur.

### Points signalés « à vérifier » (lot 4 — Module C)
- Règlement 561/2006 : chiffres stables (9/10 h, 56/90 h, 45 min 15+30,
  11/9 h, 45/24 h) — relecture de confirmation.
- Paquet mobilité : retour conducteur 4 semaines (3 si deux repos réduits
  consécutifs à l'international) et interdiction du repos normal en
  cabine — formulations à valider.
- Téléchargements tachy 28 j (carte) / 90 j (véhicule) : délais français
  à confirmer dans l'arrêté en vigueur.
- Temps de service français des roulants (décret 83-40 modifié) : la
  leçon renvoie volontairement aux textes sans chiffrer — le formateur
  peut ajouter les plafonds par catégorie s'il le souhaite.
- Échéances de mise à niveau du tachygraphe intelligent V2 : calendrier
  européen évolutif, à actualiser chaque année.

### Points signalés « à vérifier » (lot 3 — Module B)
- Délais de déclaration : cessation des paiements 45 jours (L. 631-4) et
  déclaration des créances 2 mois après BODACC (R. 622-24) — confirmer.
- RNE (registre national des entreprises, 2023) : formulation à valider.
- Statuts sociaux des dirigeants (gérant majoritaire TNS / président SAS
  assimilé salarié) : stable, vérifier l'absence de réforme récente.
- Location-gérance : le régime de solidarité initiale du loueur a évolué ;
  la leçon reste générale, le formateur peut préciser.

### Points signalés « à vérifier » (lot 2 — Module A)
- Prescription annale du contrat de transport : art. L. 133-6 c. com. —
  confirmer la rédaction en vigueur.
- Indemnité forfaitaire de recouvrement 40 € (D. 441-5 c. com.) — stable,
  vérifier qu'aucune revalorisation n'est intervenue.
- Statut entrepreneur individuel (loi 2022-172) et insaisissabilité de la
  résidence principale : formulations à valider.
- Jurisprudence « obligation essentielle » (messagerie express) : la leçon
  la mobilise sans citer d'arrêt ; le formateur peut ajouter la référence.

### Points signalés « à vérifier » (lot 1 — pilote)
- Sanction pénale exercice sans inscription : art. L. 3452-6 (1 an /
  15 000 €) — confirmer la rédaction en vigueur.
- Modalités précises de l'épreuve écrite annuelle (nombre de questions,
  barème, date) : fixées par décision annuelle, à actualiser chaque année.
- Dispense d'examen par expérience (art. 9 règl. 1071/2009, gestion
  continue 10 ans avant le 4/12/2009) : formulation à valider.
