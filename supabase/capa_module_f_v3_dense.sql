-- =====================================================================
-- MODULE F — SÉCURITÉ (Capacité ≤ 3,5 T)
-- Version 3 (mai 2026) — REFONTE PÉDAGOGIQUE DENSIFIÉE
--
-- Diagnostic v2 corrigé :
--   ✓ Bug bloc : v_bloc résolu via slug fiable
--   ✓ Quiz : chaque quiz d'entraînement contient 12 QCM
--   ✓ Leçons : structure pédagogique pro
--   ✓ Banque : 48 QCM + 6 QR
--   ✓ Examen blanc : 13 QCM + 5 QR (60 min, seuil 50 %)
--
-- Référentiel décision du 2 avril 2012 :
--   QCM (~5) + QR (~2) + autres ≈ 14-18 pts/84
-- ▸ 4 leçons :
--   1. Permis, formation initiale et continue (FIMO/FCO)
--   2. Le véhicule : entretien, contrôle technique, dispositifs de sécurité
--   3. Chargement, gabarit, transports spéciaux et dangereux (ADR)
--   4. Sécurité au travail, écoconduite et transition environnementale
--
-- Idempotent. Pré-requis : formation 'capacite-3-5t'.
-- =====================================================================

DO $module_f_v3$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson_1 uuid;
  v_lesson_2 uuid;
  v_lesson_3 uuid;
  v_lesson_4 uuid;
  v_quiz_1 uuid;
  v_quiz_2 uuid;
  v_quiz_3 uuid;
  v_quiz_4 uuid;
  v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation capacite-3-5t introuvable.'; END IF;

  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
  IF v_bloc IS NULL THEN
    INSERT INTO public.blocs (code, title, description, "order")
    VALUES ('BC1', 'Bloc 1 — Compétences générales', 'Bloc générique partagé.', 1)
    ON CONFLICT (code) DO NOTHING RETURNING id INTO v_bloc;
    IF v_bloc IS NULL THEN SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1'; END IF;
  END IF;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Bloc BC1 introuvable.'; END IF;

  DELETE FROM public.modules WHERE slug = 'capa-securite';

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'Module F — Sécurité',
    'capa-securite',
    v_bloc,
    'Maîtriser permis et formations obligatoires (FIMO/FCO), entretenir un véhicule conforme, charger en respectant gabarit et arrimage, transporter des marchandises spéciales (ADR) et déployer une politique sécurité-environnement (EPI, écoconduite, ZFE).',
    'intermediaire',
    510, -- durée officielle Capacité ≤ 3,5 t (révision client 2026-05)
    60
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 60, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026:moduleF:%';

  -- =================================================================
  -- LEÇON 1 — Permis, formation initiale et continue
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Permis, formation initiale (FIMO) et continue (FCO)',
    'permis-fimo-fco',
    1, 50,
$lessonF1$
# Permis, formation initiale (FIMO) et continue (FCO)

> 🎯 **Objectifs pédagogiques**
>
> - **Identifier** les permis nécessaires selon le PTAC du véhicule.
> - **Comprendre** l'obligation de FIMO et FCO en transport rémunéré.
> - **Anticiper** les renouvellements et stages.
> - **Sanctionner** les conducteurs sans formation valide.
> - **Différencier** marchandises et voyageurs.

---

## Introduction

Conduire un véhicule de transport ne suffit pas : il faut aussi le **droit de transporter pour autrui**. Pour cela, le conducteur doit cumuler :
1. Le **permis** correspondant au véhicule.
2. La **formation initiale** (FIMO ou Titre Pro) qui ouvre l'aptitude professionnelle.
3. La **formation continue** (FCO) tous les 5 ans pour maintenir cette aptitude.

Faire rouler un conducteur sans FCO valide expose l'employeur à une **immobilisation immédiate du véhicule** et à une amende de **3 750 €** par infraction. C'est l'une des erreurs les plus coûteuses du secteur.

---

## 1. Les permis : panorama

### 1.1 Catégories applicables au transport ≤ 3,5 T

| Permis | PTAC autorisé | Remorque |
|---|---|---|
| **B** | ≤ 3,5 T | Remorque ≤ 750 kg, ou ensemble ≤ 4,25 T |
| **B96** | B + remorque jusqu'à 4 250 kg ensemble | Sans formation pratique additionnelle (juste 7h) |
| **BE** | B + remorque > 750 kg, ensemble jusqu'à 7 T | Examen séparé |
| **C1** | 3,5 T < PTAC ≤ 7,5 T | + remorque ≤ 750 kg |

**Rappel essentiel :** la **capacité ≤ 3,5 T** ne couvre que les véhicules de **PTAC ≤ 3 500 kg**. Au-delà, il faut la capacité grand transport (PL).

### 1.2 Le permis B est-il suffisant pour transporter ?

Le permis B autorise à **conduire** un véhicule jusqu'à 3,5 T. Mais pour **transporter pour autrui** (marchandises ou voyageurs) à titre rémunéré professionnel, il faut **en plus** :
- Une attestation de capacité professionnelle (le titulaire ou son préposé).
- Une **formation initiale** (FIMO Marchandises pour le transport de marchandises ; Titre Pro pour le voyageurs).
- Une **carte de qualification de conducteur (CQC)**, mise à jour tous les 5 ans après FCO.

**Cas de dispense FIMO/FCO** :
- Véhicules ≤ 3,5 T transportant ses propres marchandises (compte propre).
- Conducteurs « occasionnels » exemptés (dépannage, déménagements personnels).
- Véhicules d'urgence, militaires, agricoles.

Pour notre public capa ≤ 3,5 T en compte d'autrui (livraison express, e-commerce, courses) : **FIMO Marchandises obligatoire**.

---

## 2. La FIMO (Formation Initiale Minimale Obligatoire)

### 2.1 Public concerné

Tout conducteur qui transporte des marchandises pour le compte d'autrui en France :
- 140 h de formation théorique et pratique.
- Sanction : **carte de qualification (CQC)** de 5 ans.
- Délivrance : organismes agréés (Promotrans, AFTRAL, etc.).
- Coût : 2 200 à 3 000 € HT, finançable par OPCO Mobilités.

### 2.2 Programme indicatif (référentiel)

| Module | Heures | Contenus |
|---|---|---|
| Perfectionnement à la conduite rationnelle (sécurité) | 60 h | Conduite préventive, écoconduite, anticipation |
| Application des réglementations | 30 h | Code de la route, RSE, temps de conduite, pesées |
| Santé, sécurité, service | 30 h | Manutention, ergonomie, premier secours |
| Logistique et environnement | 20 h | Image entreprise, économie du transport |

### 2.3 Équivalences

- **Titre Pro Conducteur Routier Marchandises** = équivaut à FIMO.
- **CAP / Bac Pro Conducteur** = équivaut à FIMO.
- **Diplôme étranger de conducteur professionnel** = équivalence sur dossier.

---

## 3. La FCO (Formation Continue Obligatoire)

### 3.1 Principe

Tous les **5 ans**, le conducteur doit suivre **35 h de formation continue** sur 4-5 jours. Objectif : remettre à niveau les connaissances en sécurité, réglementation, écoconduite.

**Sans FCO valide → CQC périmée → infraction**.

### 3.2 Anticipation

La formation doit être effectuée **avant** la date de péremption de la CQC. Si dépassée :
- Conducteur en infraction → 3 750 € amende.
- Véhicule immobilisé.
- Employeur co-responsable (s'il a laissé rouler).

**Bonne pratique RH** : tableau de bord avec dates de péremption, alertes 6 mois avant échéance, planification annuelle des stages.

### 3.3 Coût et financement

- Coût FCO : 700 à 1 000 € HT.
- Financement : OPCO Mobilités, plan de développement des compétences, CPF possible.

---

## 4. Le permis à points

### 4.1 Mécanisme

Tout conducteur a **12 points** sur son permis (capital). Une infraction retire 1 à 6 points selon gravité.

| Infraction | Retrait |
|---|---|
| Téléphone tenu en main | 3 pts (+ 135 € amende) |
| Excès vitesse < 20 km/h | 1 pt |
| Excès vitesse 20-30 km/h | 2 pts |
| Excès vitesse 30-40 km/h | 3 pts |
| Excès vitesse 40-50 km/h | 4 pts |
| Excès vitesse > 50 km/h | 6 pts (+ 1 500 € + suspension) |
| Conduite sous emprise alcool 0,5-0,8 g/L | 6 pts |
| Conduite sous emprise alcool > 0,8 g/L | 6 pts + délit |
| Conduite sous stupéfiants | 6 pts + délit |
| Délit de fuite | 6 pts + délit |

**Récupération de points** : 1 point après 6 mois sans infraction (exclu si 4 pts perdus + délit), récupération totale après 2 ans, ou stage de récupération (4 pts max, 1 fois par an).

### 4.2 Permis professionnel

Pas de permis « pro » spécifique au sens points, mais le permis du conducteur professionnel est sensible : un permis suspendu = conducteur inutilisable. L'employeur doit donc **vérifier régulièrement** la validité.

---

## 5. Cas pratique d'examen

**Énoncé :** vous embauchez un conducteur en CDI le 15 mai. Sa CQC arrive à expiration le 30 juin. Vous prévoyez de le faire rouler dès le 16 mai.

**Questions :**
1. Pouvez-vous le faire rouler avant le 30 juin ?
2. Que se passe-t-il s'il roule encore le 1er juillet sans nouvelle FCO ?
3. Quelle est votre obligation RH ?

**Correction :**

1. **Oui** entre le 16 mai et le 30 juin (CQC encore valide).
2. **Infraction** : conducteur 3 750 € + véhicule immobilisé. Employeur co-responsable. Possible licenciement pour faute si l'employeur démontre avoir prévenu et organisé.
3. **Programmer la FCO immédiatement** (appel organisme agréé), avant le 30 juin. Conserver la convocation pour preuve. Si FCO ne peut être tenue à temps : retirer le conducteur du planning.

---

## 6. Mini-exercice à faire seul

Un conducteur est embauché avec un permis B obtenu il y a 6 mois. Il a 21 ans. Il doit conduire un VUL pour livrer des colis pour le compte d'un client e-commerce.

**Quelles formations / autorisations doit-il avoir ?**

> 💡 Réponse à la fin du module.

---

## 7. Glossaire

- **PTAC** : Poids Total Autorisé en Charge. Masse maximale du véhicule chargé.
- **FIMO** : Formation Initiale Minimale Obligatoire. 140 h pour devenir conducteur professionnel.
- **FCO** : Formation Continue Obligatoire. 35 h tous les 5 ans.
- **CQC** : Carte de Qualification de Conducteur. Atteste FIMO + FCO en cours.
- **OPCO Mobilités** : Opérateur de Compétences finançant la formation transport.
- **Compte propre** : transport effectué pour ses propres besoins (pas de tiers payant le transport).
- **Compte d'autrui** : transport effectué contre rémunération pour un client.

---

## 8. Synthèse opérationnelle

1. **Permis B** suffit pour conduire ≤ 3,5 T, mais **pas pour transporter** pour autrui.
2. **FIMO 140 h** obligatoire pour transport pour autrui (sauf compte propre).
3. **CQC** délivrée à l'issue, valable 5 ans.
4. **FCO 35 h** tous les 5 ans pour la maintenir.
5. **Sans FCO valide** : 3 750 € amende, immobilisation, employeur co-responsable.
6. **12 points** au permis, récupération 6 mois ou 2 ans ou stage.
7. **Vérifier** régulièrement la validité des permis et CQC.
8. **Financement OPCO** disponible pour FIMO et FCO.

---

## 🎓 Ce que l'examinateur peut demander

- Différence permis B / B96 / BE.
- Champ d'application FIMO / FCO.
- Périodicité FCO (5 ans, 35 h).
- Conséquence d'une CQC expirée.
- QR : « Quelles formations un conducteur de VUL doit-il posséder pour transporter pour autrui ? »

---

## 📋 Mémo à imprimer

```
PERMIS  ≤ 3,5 T

  B    : véhicule ≤ 3,5 T, remorque ≤ 750 kg
  B96  : ensemble ≤ 4 250 kg (formation 7 h)
  BE   : remorque > 750 kg, ensemble ≤ 7 T

FORMATIONS PROFESSIONNELLES

  FIMO : 140 h, à l'embauche en compte d'autrui
       : Coût 2 200-3 000 € HT, OPCO finance
  CQC  : délivrée par FIMO, valable 5 ans
  FCO  : 35 h tous les 5 ans
       : Coût 700-1 000 € HT
  Sans CQC valide : 3 750 € + immobilisation

PERMIS À POINTS
  12 pts capital
  1 point récupéré après 6 mois sans infraction
  Récupération totale après 2 ans
  Stage récup. : 4 pts max, 1 fois/an

⚠ Vérifier dates de péremption CQC : alerte 6 mois avant
```
$lessonF1$,
'Identifier les permis (B, B96, BE), connaître les formations obligatoires (FIMO/FCO) et anticiper les renouvellements de CQC — sans formation valide, immobilisation et amende 3 750 €.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Le véhicule : entretien et contrôle
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Le véhicule : entretien, contrôle technique, dispositifs de sécurité',
    'vehicule-entretien-controle-technique',
    2, 50,
$lessonF2$
# Le véhicule : entretien, contrôle technique, dispositifs de sécurité

> 🎯 **Objectifs pédagogiques**
>
> - **Programmer** un entretien préventif annuel.
> - **Respecter** la périodicité du contrôle technique.
> - **Identifier** les dispositifs obligatoires (chronotachygraphe, EAD).
> - **Réagir** à une défaillance (immobilisation, fiche défaut).
> - **Anticiper** la fin de vie du véhicule (renouvellement, vente).

---

## Introduction

Un véhicule **mal entretenu** vous coûte cher : **+30 % de carburant**, accidents évités de justesse, immobilisations subies. Un véhicule **non conforme** au contrôle technique vous coûte encore plus cher : amende, immobilisation immédiate, refus de prise en charge en cas d'accident. La maintenance n'est pas un luxe, c'est la condition de l'exploitation.

À l'examen, on attend que vous connaissiez :
1. La périodicité du CT.
2. Les dispositifs obligatoires.
3. Les sanctions en cas de défaillance.

---

## 1. L'entretien préventif

### 1.1 Le carnet d'entretien

Un véhicule de transport doit avoir un **carnet d'entretien** à jour, recensant :
- Les vidanges (huile, filtres) selon préconisation constructeur.
- Les remplacements (courroie distribution, freins, pneus).
- Les contrôles techniques.
- Les réparations majeures.

**À conserver** au moins 5 ans pour transparence en cas de revente.

### 1.2 Périodicités types pour un VUL

| Opération | Périodicité |
|---|---|
| Vidange moteur | 15 000 à 30 000 km (selon constructeur) |
| Filtre à air | 30 000 km |
| Filtre carburant | 60 000 km |
| Plaquettes de frein | 30 000 à 80 000 km (selon usage) |
| Pneus | 5-7 ans ou usure |
| Courroie distribution | 100 000 à 160 000 km |
| Liquide de frein | 2 ans |

### 1.3 Vérifications quotidiennes (avant départ)

- Pression et état des pneus.
- Niveaux (huile, lave-glace, liquide de refroidissement).
- Feux (route, croisement, stop, clignotants).
- Rétroviseurs propres et bien réglés.
- Frein à main et frein de service.
- État de la charge et arrimage.
- Documents de bord (carte grise, assurance, FNI).

**Bonne pratique** : check-list signée tous les matins par le conducteur.

---

## 2. Le contrôle technique (CT)

### 2.1 Périodicité

| Catégorie | Périodicité |
|---|---|
| **VUL ≤ 3,5 T** (utilitaire) | 4 ans après mise en circulation, puis **tous les 2 ans** |
| **VP ≤ 3,5 T** (voiture particulière) | 4 ans, puis tous les 2 ans (pré-CT vente : 6 mois) |
| **PL > 3,5 T** | **Tous les ans** dès la 1re année |
| **Transport voyageurs** | Tous les 6 mois si > 9 places |

**Rappel** : pour notre public capacité ≤ 3,5 T, c'est le régime VUL ou VP.

### 2.2 Centres agréés

Le CT s'effectue dans un **centre agréé** par le ministère (réseau Securitest, Auto Sécurité, Auto Bilan…). Coût : 60 à 110 € selon centre.

### 2.3 Résultats possibles

| Résultat | Délai pour régulariser | Conséquence |
|---|---|---|
| **Favorable** | — | Vignette verte, valable 2 ans (VUL) |
| **Défavorable mineur** | 2 mois pour contre-visite | Pas d'immobilisation immédiate |
| **Défavorable majeur** | 2 mois | Le véhicule reste utilisable mais doit revenir |
| **Défavorable critique** | Immédiate | **Immobilisation** : interdiction de circuler hors trajet vers réparateur ou domicile |

### 2.4 Sanctions

- Défaut de CT : amende **135 € forfaitaire** (jusqu'à 750 €).
- Récidive : **immobilisation immédiate** + retrait de la carte grise.
- Vente d'un véhicule sans CT à jour < 6 mois : **vente nulle**.

---

## 3. Les dispositifs obligatoires de sécurité

### 3.1 Chronotachygraphe

**Obligatoire pour véhicules > 3,5 T.** Pour les ≤ 3,5 T, il est facultatif mais **devient obligatoire** dans certains cas (notamment activité longue distance européenne post-2026 selon évolutions règlementaires).

Fonction : enregistre le temps de conduite, de pause, de repos. Lecture par carte conducteur (personnelle).

### 3.2 EAD (Éthylotest Anti-Démarrage)

Obligatoire :
- Sur les **autocars de transport public** depuis 2010.
- Sur véhicules conduits par récidivistes alcool (peine complémentaire).

Pas obligatoire en transport ≤ 3,5 T marchandises hors récidive.

### 3.3 ABS, ESP, AEB, etc.

Tous les véhicules neufs depuis 2015-2018 doivent être équipés :
- **ABS** : freinage anti-blocage.
- **ESP** : contrôle de stabilité.
- **AEB** : freinage d'urgence automatique (depuis 2022 pour PL).
- **LDW** : alerte de franchissement de ligne.

### 3.4 Limiteur de vitesse

| Catégorie | Limitation |
|---|---|
| VUL ≤ 3,5 T | Pas de bridage obligatoire (vitesse normale du Code) |
| PL > 3,5 T (marchandises) | Bridé à **90 km/h** |
| Autocar (voyageurs) | Bridé à **100 km/h** |

### 3.5 Caméra de recul / capteurs

Obligatoires sur PL neufs (DVS, Direct Vision Standard) en zone urbaine sensible (Londres, certaines métropoles européennes).

---

## 4. La fiche défaut et l'immobilisation

### 4.1 La fiche défaut

Document interne par lequel le conducteur signale toute anomalie. Doit être tracé, daté, signé. À l'employeur de réparer ou immobiliser.

**Exemple :** « Frein avant gauche faiblesse, signalé le 12/05, conducteur Dupont. »

### 4.2 L'immobilisation

L'immobilisation peut être :
- **Volontaire** (employeur ou conducteur juge le véhicule dangereux).
- **Imposée** (gendarmerie, contrôle CT défavorable critique).

Pendant l'immobilisation : véhicule ne peut **pas circuler** hors trajet vers atelier ou domicile (immobilisation administrative).

---

## 5. Cas pratique d'examen

**Énoncé :** un de vos conducteurs revient avec un VUL qui « tire à droite au freinage ». Le contrôle technique date de 4 mois (favorable). Que faites-vous ?

**Correction :**

1. **Émission immédiate d'une fiche défaut** par le conducteur.
2. **Immobilisation volontaire** : véhicule ne repart pas tant que diagnostic non posé.
3. **Diagnostic atelier** : étrier coincé, pneu sous-gonflé, géométrie déréglée ?
4. **Réparation** documentée dans le carnet d'entretien.
5. Si problème de freinage avéré : **CT volontaire** ou contre-visite à programmer.
6. **Continuer à exploiter sans réparation** = mise en danger d'autrui (5 ans + 75 000 € si accident grave).

---

## 6. Mini-exercice à faire seul

Vous achetez un VUL d'occasion mis en circulation le 15/03/2022. Aujourd'hui : 06/05/2026.

**Le CT est-il obligatoire ? Quand sera la prochaine échéance ?**

> 💡 Réponse à la fin du module.

---

## 7. Glossaire

- **CT** : Contrôle Technique périodique en centre agréé.
- **PTAC** : Poids Total Autorisé en Charge.
- **EAD** : Éthylotest Anti-Démarrage.
- **ABS / ESP / AEB / LDW** : dispositifs de sécurité électronique.
- **Chronotachygraphe** : enregistreur de temps de conduite et repos.
- **Fiche défaut** : document interne de signalement d'anomalie.
- **Immobilisation** : interdiction de circuler.

---

## 8. Synthèse opérationnelle

1. **Carnet d'entretien** à jour, vidanges et remplacements selon préconisation constructeur.
2. **Vérifications quotidiennes** : pneus, niveaux, feux, freins.
3. **CT VUL** : 4 ans après mise en circulation, puis tous les 2 ans.
4. **Sanction** défaut CT : 135 € + immobilisation possible.
5. **Chronotachygraphe** : obligatoire > 3,5 T.
6. **Limitation vitesse** : 90 km/h PL, 100 km/h autocars.
7. **Fiche défaut** + immobilisation = chaîne de sécurité.
8. **Mise en danger** d'autrui = pénal (5 ans + 75 000 €).

---

## 🎓 Ce que l'examinateur peut demander

- Périodicité du CT pour VUL ≤ 3,5 T.
- Conséquence d'un CT défavorable critique.
- Dispositifs obligatoires (chronotachygraphe, ABS).
- Sanction d'un véhicule sans CT.
- QR : « Quelle est la procédure quand un conducteur signale une défaillance ? »

---

## 📋 Mémo à imprimer

```
ENTRETIEN PRÉVENTIF VUL
  Vidange moteur     : 15-30 000 km
  Plaquettes frein   : 30-80 000 km
  Pneus              : 5-7 ans / usure
  Courroie distrib.  : 100-160 000 km
  Liquide frein      : 2 ans

CONTRÔLE TECHNIQUE
  VUL ≤ 3,5 T : 4 ans MEC, puis tous les 2 ans
  PL > 3,5 T  : tous les ans
  Voyageurs   : tous les 6 mois
  Sanction défaut : 135 € (jusqu'à 750 €) + immobilisation

DISPOSITIFS OBLIGATOIRES
  Chronotachygraphe  : > 3,5 T
  Limiteur 90 km/h   : PL marchandises
  Limiteur 100 km/h  : autocars
  ABS, ESP           : tous neufs (depuis 2015-18)
  AEB                : PL neufs depuis 2022

CHAÎNE SÉCURITÉ
  1. Vérifs quotidiennes par conducteur
  2. Fiche défaut signée si anomalie
  3. Immobilisation si dangereux
  4. Diagnostic + réparation atelier
  5. Carnet d'entretien tenu à jour
```
$lessonF2$,
'Programmer un entretien préventif, respecter la périodicité du CT (VUL : 4 ans puis 2 ans), identifier les dispositifs obligatoires (chronotachygraphe, ABS, limiteur) et réagir à une défaillance par la fiche défaut.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Chargement, gabarit, transports spéciaux et dangereux (ADR)
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Chargement, gabarit, transports spéciaux et dangereux (ADR)',
    'chargement-gabarit-adr',
    3, 50,
$lessonF3$
# Chargement, gabarit, transports spéciaux et dangereux (ADR)

> 🎯 **Objectifs pédagogiques**
>
> - **Calculer** la charge utile et le respect du PTAC.
> - **Maîtriser** les règles d'arrimage et de gabarit.
> - **Identifier** les transports exceptionnels.
> - **Comprendre** la réglementation ADR (matières dangereuses).
> - **Anticiper** les autorisations spécifiques (déchets, animaux vivants).

---

## Introduction

Charger un véhicule semble trivial. C'est en fait l'**une des principales causes d'accidents** du transport routier : surcharge, chargement non arrimé, gabarit dépassé. La gendarmerie a des **balances mobiles** sur les axes principaux, et les amendes commencent à **750 € par tonne en surcharge**.

Pour les marchandises dangereuses, c'est encore plus sérieux : un transporteur qui livre une bouteille d'acétylène sans formation ADR met en danger sa propre vie et celle des autres. Cette leçon vous arme pour 5-8 points d'examen.

---

## 1. Le PTAC et la charge utile

### 1.1 Définitions

- **PTAC** : Poids Total Autorisé en Charge. Inscrit sur la carte grise (case F.2). C'est la masse maxi autorisée pour le véhicule chargé.
- **PV** : Poids à Vide. Véhicule équipé, plein de carburant, prêt à rouler, sans charge.
- **CU (Charge Utile)** : PTAC − PV = ce que vous pouvez charger.

**Exemple** : Renault Trafic L2H1 — PTAC 2 800 kg, PV 1 950 kg → **CU = 850 kg**.

### 1.2 La surcharge

Toute surcharge est sanctionnée par tranche de 5 % :

| Dépassement | Amende |
|---|---|
| < 5 % du PTAC | 90 € (contravention 4e classe) |
| 5 à 20 % | 135 € + immobilisation possible |
| > 20 % | 1 500 € + immobilisation immédiate + déchargement obligatoire |

**Rappel** : le PTAC inclut le conducteur (forfait 75 kg) + carburant + outillage + chargement.

### 1.3 La répartition des charges

La charge doit être **répartie de manière équilibrée** entre les essieux. Dépassement d'un essieu seul = sanction même si PTAC global respecté.

**Bonne pratique** : charger les colis les plus lourds **au plus près de l'essieu avant** (ou centré sur l'essieu).

---

## 2. L'arrimage

### 2.1 Principe

Tout chargement doit être **arrimé** : maintenu en place pour ne pas se déplacer en cas de freinage, virage, ou choc. Norme de référence : **EN 12195-1** (forces dynamiques 0,8 g vers l'avant, 0,5 g latéralement et vers l'arrière).

### 2.2 Méthodes d'arrimage

- **Sangles cliquet** : la plus utilisée en VUL. Tension calculée selon la charge.
- **Chaînes** : pour les charges lourdes (engins, structures).
- **Filets** : sur PL en bâché, plus rare en VUL.
- **Cales et taquets** : pour empêcher le glissement axial.
- **Couvertures antidérapantes** : pour augmenter le coefficient de friction (souvent oubliées, pourtant très efficaces).

### 2.3 Sanction d'un chargement mal arrimé

- **750 €** d'amende (contravention 4e classe).
- **Responsabilité pénale** en cas d'accident causé par chute de charge.
- **Garantie d'assurance** souvent refusée si arrimage défaillant.

### 2.4 Cas pratique

**Énoncé** : vous chargez 5 cartons de 50 kg sur le plancher d'un Trafic. Vous filez 30 km en autoroute. Faut-il arrimer ?

**Réponse** : OUI, sans hésitation. Au premier coup de frein d'urgence à 110 km/h, ces 250 kg deviennent des **projectiles** qui peuvent traverser la cloison de cabine. Sangle cliquet sur tout le lot, ou cales antidérapantes minimum.

---

## 3. Le gabarit

### 3.1 Dimensions maximales standard

| Dimension | VUL ≤ 3,5 T | PL marchandises |
|---|---|---|
| Longueur | 12 m | 18,75 m (semi-remorque) |
| Largeur | 2,55 m | 2,55 m |
| Hauteur | 4 m | 4 m |
| Hauteur grand volume | — | 4,30 m possible (dérogations) |

### 3.2 Le transport exceptionnel

Au-delà de ces dimensions, on parle de **transport exceptionnel** (TE) qui nécessite :
- Une **autorisation** préfectorale (1re catégorie : convois ≤ 25 m × 3 m × 4,5 m × 48 t ; 2e catégorie au-delà).
- Un **itinéraire imposé** (évitement de ponts faibles, tunnels).
- Un **véhicule pilote** au-delà de certaines dimensions.
- Une **signalisation lumineuse** et **panneaux** spécifiques.

Le transport ≤ 3,5 T est **rarement exceptionnel** par sa masse, mais peut l'être par ses dimensions (charges longues, débord arrière). Au-delà de **3 m de débord arrière**, signalisation obligatoire (drapeau rouge ou panneau).

---

## 4. Les marchandises dangereuses : ADR

### 4.1 Qu'est-ce que l'ADR ?

ADR = **Accord européen relatif au transport international des marchandises Dangereuses par Route**. Texte international qui classifie les matières et impose des règles.

### 4.2 Les 9 classes ADR

| Classe | Matière |
|---|---|
| 1 | Matières et objets explosibles |
| 2 | Gaz (butane, propane, oxygène) |
| 3 | Liquides inflammables (essence, alcool, peintures) |
| 4 | Solides inflammables, auto-inflammables |
| 5 | Comburants et peroxydes |
| 6 | Toxiques et infectieuses |
| 7 | Matières radioactives |
| 8 | Matières corrosives (acide, soude) |
| 9 | Diverses (matières dangereuses pour l'environnement) |

### 4.3 Le seuil 1 000 points (exemption partielle)

L'ADR s'applique avec **toute la rigueur** au-delà d'un seuil exprimé en « points » (selon classe). En dessous : **exemption partielle** = quelques règles seulement (formation 8 h, étiquettes, fiche de sécurité, extincteur).

**Exemple** : transporter 100 L d'essence en un voyage = au-dessus du seuil → ADR plein. Transporter 50 L = exemption partielle.

### 4.4 Formations

- **Formation ADR de base** (3 jours, ~700 € HT) : obligatoire pour tout conducteur transportant des matières dangereuses au-delà du seuil.
- **Spécialisations** : citernes, classe 1 (explosifs), classe 7 (radioactifs).

### 4.5 Documents obligatoires

- Document de transport (avec n° ONU, classe, groupe d'emballage).
- **Consignes écrites** en cabine.
- Certificat ADR du conducteur.

### 4.6 Équipements

- Extincteurs (selon PTAC).
- Cales, lampe portative non métallique, gilet, gants, lunettes.
- **Plaques orange** rétroréfléchissantes à l'avant et à l'arrière.

---

## 5. Autres transports spéciaux

### 5.1 Animaux vivants

Réglementation européenne CE 1/2005. Selon durée et espèce :
- Formation conducteur (carte de compétence transporteur d'animaux).
- Autorisation de transport (préfecture).
- Densité maximum, abreuvement, repos.

### 5.2 Denrées périssables

- Véhicule **frigorifique** ou **isotherme** selon ATP (Accord sur les Transports Périssables).
- Attestation ATP délivrée par centre agréé.
- Périodicité de renouvellement : 6 ans, puis 3 ans.

### 5.3 Déchets

- **Récépissé de transport de déchets** délivré par préfecture (obligatoire si volume > 0,5 t/voyage non dangereux, > 0,1 t dangereux).
- Bordereau de suivi.
- Sanctions lourdes en cas de transport illégal (jusqu'à 75 000 € + 2 ans).

### 5.4 Transport de fonds

- Régulé par CNAPS (Conseil National des Activités Privées de Sécurité).
- Véhicules blindés, agents armés, formations spécifiques.
- Hors champ capacité ≤ 3,5 T classique mais à connaître.

---

## 6. Cas pratique d'examen

**Énoncé :** vous transportez en VUL 10 bonbonnes de 5 L de white-spirit (classe 3 ADR, point d'éclair < 60°C) pour un client d'industrie. Le total est 50 L.

**Questions :**
1. ADR plein ou exemption partielle ?
2. Quel formation conducteur ?
3. Quels documents en cabine ?

**Correction :**

1. 50 L × 5 = 250 L total. Le seuil de la classe 3 / GE III est généralement **1 000 points**. À 50 L (50 points par L = à vérifier sur l'instruction de transport) la quantité est en règle générale **sous le seuil** → exemption partielle.
2. **Formation ADR « petites quantités » 8 h** suffisante.
3. Document de transport indiquant n° ONU 1300, classe 3, GE III ; consignes écrites ; fiche de sécurité du fournisseur.

---

## 7. Mini-exercice à faire seul

Votre VUL a un PTAC de 3 200 kg, PV 1 800 kg, et vous transportez vous (75 kg) + carburant 60 L (~50 kg) + 12 palettes de 100 kg.

**Êtes-vous en surcharge ? De combien ?**

> 💡 Réponse à la fin du module.

---

## 8. Glossaire

- **PTAC** : Poids Total Autorisé en Charge.
- **PV** : Poids à Vide.
- **CU** : Charge Utile = PTAC − PV.
- **Arrimage** : système de maintien du chargement.
- **Transport exceptionnel** : convoi dépassant les gabarits standards.
- **ADR** : Accord européen sur le transport de marchandises dangereuses.
- **ATP** : Accord sur le Transport de denrées Périssables.
- **N° ONU** : code à 4 chiffres identifiant chaque matière dangereuse.

---

## 9. Synthèse opérationnelle

1. **PTAC** sur carte grise. Surcharge sanctionnée par tranche de 5 %.
2. **Charge utile = PTAC − PV**. Inclut conducteur, carburant, charge.
3. **Arrimage obligatoire** (norme EN 12195-1). 750 € si défaut.
4. **Gabarit standard** ≤ 3,5 T : 12 m × 2,55 m × 4 m.
5. **9 classes ADR**. Formation 3 jours pour ADR plein.
6. **Plaques orange** + documents obligatoires en transport ADR.
7. **ATP** pour denrées périssables (frigo / isotherme).
8. **Récépissé déchets** obligatoire pour transport de déchets pro.

---

## 4. Corrections des mini-exercices du module

### Leçon 1 (jeune conducteur)
- Permis B (déjà valide).
- **Pas de FIMO requise** s'il transporte pour le compte du client e-commerce et que l'employeur est dispensé (compte propre du e-commerce ?). En réalité : si le e-commerce sous-traite à votre entreprise, vous êtes en compte d'autrui → **FIMO requise**.
- Vérification : carte grise, assurance, FNI à bord.
- Sa CQC commence à courir dès la fin de FIMO.

### Leçon 2 (CT)
- Mise en circulation 15/03/2022. Premier CT obligatoire au plus tard 4 ans après → **15/03/2026**.
- Aujourd'hui 06/05/2026 : **CT en retard de 1 mois 21 j** → 135 € amende + à programmer immédiatement.
- Prochaine échéance après ce CT : 2 ans plus tard.

### Leçon 3 (surcharge VUL)
- Charge réelle : 75 (conducteur) + 50 (carburant) + 1 200 (palettes) = 1 325 kg en charge.
- Total véhicule chargé : 1 800 + 1 325 = **3 125 kg**.
- PTAC 3 200 kg → **OK**, marge de 75 kg.

---

## 🎓 Ce que l'examinateur peut demander

- Calcul charge utile à partir du PTAC.
- Conséquence d'une surcharge.
- Règles d'arrimage et sanction.
- Classes ADR et formation requise.
- QR : « Que faire si un client vous demande de transporter une matière classée 3 ADR ? »

---

## 📋 Mémo à imprimer

```
PTAC – CU – PV
  PTAC = max sur carte grise (case F.2)
  PV   = à vide, prêt à rouler
  CU   = PTAC − PV
  Surcharge < 5 %     : 90 €
  Surcharge 5-20 %    : 135 € + immobilisation possible
  Surcharge > 20 %    : 1 500 € + immobilisation + déchargement

ARRIMAGE
  Norme EN 12195-1 (0,8 g av., 0,5 g lat./ar.)
  Sangles cliquet, chaînes, cales, antidérapants
  Sanction défaut : 750 € (+ pénal si accident)

GABARIT VUL ≤ 3,5 T
  Long. 12 m | Larg. 2,55 m | Haut. 4 m
  Au-delà = transport exceptionnel (autorisation préfecture)

ADR — 9 CLASSES
  1 explosifs | 2 gaz | 3 inflammables liq. | 4 solides inflam.
  5 comburants | 6 toxiques | 7 radioactifs | 8 corrosifs | 9 div.
  Seuil 1 000 pts → ADR plein, sous → exemption partielle
  Formation : 3 j (700 €) ADR plein, 8 h petites quantités
  Plaques orange + documents en cabine
```
$lessonF3$,
'Calculer charge utile et arrimer correctement, respecter le gabarit et les règles ADR pour les matières dangereuses, anticiper les transports spéciaux (déchets, animaux, frigo) — sanctions lourdes en cas d''infraction.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Sécurité au travail, écoconduite et environnement
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Sécurité au travail, écoconduite et transition environnementale',
    'securite-ecoconduite-environnement',
    4, 50,
$lessonF4$
# Sécurité au travail, écoconduite et transition environnementale

> 🎯 **Objectifs pédagogiques**
>
> - **Identifier** les principaux risques professionnels du conducteur.
> - **Mettre en place** une politique de prévention efficace.
> - **Pratiquer** l'écoconduite pour économiser carburant et CO₂.
> - **Anticiper** les ZFE (Zones à Faibles Émissions).
> - **Préparer** la transition vers véhicules propres.

---

## Introduction

Le transport routier est l'un des secteurs **les plus à risques** : 1er secteur en accidents du travail au km parcouru, 2e en troubles musculo-squelettiques (TMS), 3e en stress chronique. Un conducteur correctement formé, équipé et reposé représente :
- Moins d'accidents (économie sur la cotisation AT/MP).
- Moins de carburant (-10 à -15 % avec écoconduite).
- Moins d'arrêts maladie (TMS, dépression).
- Plus de productivité.

À l'examen, on attend une vision **opérationnelle** : ce qu'on met en place concrètement, pourquoi, à quel coût.

---

## 1. Les principaux risques du conducteur

### 1.1 Cartographie

| Risque | Fréquence transport | Mesure |
|---|---|---|
| Accident de la route | ★★★★★ | Formation, écoconduite, écran téléphone |
| Manutention manuelle (port de charges) | ★★★★ | Aides mécaniques, transpalette, hayon |
| Chutes de hauteur (cabine, bâche) | ★★★ | Marchepieds antidérapants, EPI |
| TMS (lombalgies, épaules) | ★★★★ | Sièges réglables, alternance tâches |
| Stress, fatigue, dépression | ★★★★ | Respect repos, planning humain, suivi médical |
| Agression (zones sensibles) | ★★ | Procédures, formation, alarmes |
| Exposition produits dangereux | ★★ | EPI, formation ADR |

### 1.2 Le DUER spécifique conducteur

Le DUER (vu dans Module E) doit comporter une **fiche conducteur** :
- Liste des risques identifiés.
- Mesures de prévention (formation, EPI, procédures).
- Évaluation gravité × fréquence.
- Plan d'action priorisé.

### 1.3 Les EPI conducteur

- **Chaussures de sécurité** S1 ou S3 : antidérapantes, embout protégé.
- **Gilet haute visibilité** classe 2 minimum (présence à bord obligatoire art. R. 416-19 C. route + à porter en cas d'arrêt sur autoroute).
- **Gants** anti-coupure, anti-vibration ou imperméables selon usage.
- **Protections auditives** si dépôt bruyant (atelier, quai logistique).
- **Lunettes de sécurité** pour sangles, chaînes (risque de fouet).

---

## 2. La fatigue et la sécurité routière

### 2.1 Le facteur fatigue

La fatigue cause **30 % des accidents mortels** sur autoroute. Réflexes en baisse, vigilance dégradée, micro-sommeils. **À 18 h éveillé, c'est l'équivalent de 0,5 g/L d'alcool** dans le sang en termes de réflexes.

### 2.2 Bonnes pratiques

- **Pause toutes les 2 h** (ou 4 h 30 max conduite continue).
- **Repos quotidien 11 h consécutives**.
- **Ne pas planifier des journées de 12 h amplitude** sans nécessité.
- **Reconnaître les signaux** : bâillements répétés, paupières lourdes, ennui, irritabilité → arrêt immédiat 20 min sieste.

### 2.3 La conduite sous influence

- **Alcool** : 0,5 g/L dans le sang max. Au-delà : amende, points, suspension. > 0,8 g/L = délit (2 ans + 4 500 €).
- **Stupéfiants** : tolérance zéro. Test salivaire obligatoire. Délit de plein droit.
- **Médicaments** : pictogrammes orange (vigilance), rouge (interdit). À vérifier sur la notice.

L'employeur doit :
- Sensibiliser annuellement.
- Proposer un dépistage volontaire (alcool/drogues) en accord CSE.
- Sanctionner si infraction (faute grave possible).

---

## 3. L'écoconduite

### 3.1 Définition et bénéfices

L'écoconduite consiste à conduire de façon **anticipée et économe**. Bénéfices mesurés :
- **− 10 à 15 % de carburant**.
- **− 10 à 15 % de CO₂**.
- **− 30 % d'usure freins/pneus**.
- **− 50 % d'accidents** (statistiques constructeurs).

### 3.2 Les 7 règles clés

1. **Anticiper** : regarder loin, lever le pied avant la nécessité.
2. **Démarrer doucement** : pas de plein gaz, accélération progressive.
3. **Rouler à vitesse stable** : régulateur de vitesse autoroute.
4. **Passer les rapports tôt** : 1 500 à 2 000 tours/min en diesel.
5. **Limiter la climatisation** : 1-2 L/100 km de surconsommation à fond.
6. **Pneus bien gonflés** : -0,3 bar = +3 % de carburant.
7. **Couper le moteur** dès 30 secondes d'arrêt.

### 3.3 Calcul d'économie

**Hypothèse** : VUL parcourant 50 000 km/an avec consommation 8 L/100.
- Sans écoconduite : 50 000 × 8/100 = 4 000 L × 1,80 € = **7 200 €/an**.
- Avec écoconduite (-12 %) : 3 520 L × 1,80 € = **6 336 €/an**.
- **Économie : 864 €/an** par véhicule.

Sur une flotte de 5 véhicules : **4 320 €/an**. Pour une formation écoconduite à 350 €/conducteur, ROI < 1 an.

---

## 4. Les ZFE (Zones à Faibles Émissions)

### 4.1 Principe

Depuis 2020, les agglomérations > 150 000 habitants doivent instaurer une **ZFE** : zone interdite aux véhicules les plus polluants, identifiés par la **vignette Crit'Air**.

### 4.2 Le système Crit'Air

| Vignette | Type véhicule |
|---|---|
| **Crit'Air 1** (verte) | Électrique, hydrogène, hybride rechargeable |
| **Crit'Air 1** (violette) | Essence Euro 5/6 (depuis 2011) |
| **Crit'Air 2** (jaune) | Diesel Euro 5/6 (depuis 2011) |
| **Crit'Air 3** (orange) | Diesel Euro 4 (2006-2010) |
| **Crit'Air 4** (rouge) | Diesel Euro 3 (2001-2005) |
| **Crit'Air 5** (gris) | Diesel Euro 2 (1997-2000) |
| **Non classé** | Avant 1997 |

### 4.3 Calendrier prévisionnel

| ZFE | 2024 | 2025 | 2026 | 2030 |
|---|---|---|---|---|
| Paris | Crit'Air 4+ exclus | Crit'Air 3+ | Crit'Air 2+ | Tout sauf élec/H2 |
| Lyon | Crit'Air 5+ exclus | Crit'Air 4+ | Crit'Air 3+ | … |
| Métropoles >150 k | Variable | Crit'Air 5+ | Crit'Air 4+ | … |

⚠️ **Ces calendriers ont été assouplis en 2025-2026** suite aux concertations. Vérifier les arrêtés locaux à jour.

### 4.4 Conséquences pour le transporteur

- Vérifier la **vignette Crit'Air** de chaque véhicule.
- **Ne pas circuler** dans les ZFE avec véhicule non autorisé : amende **68 €** (VUL) à **135 €** (PL).
- **Anticiper le renouvellement** de flotte vers Crit'Air 1-2 pour rester opérationnel.

---

## 5. La transition vers véhicules propres

### 5.1 Les options 2026

| Carburant / motorisation | Avantages | Inconvénients |
|---|---|---|
| **Diesel Euro 6d** | Mature, autonomie, infra | Crit'Air 2, exclu à terme |
| **Essence Euro 6 hybride** | Polyvalent | +20 % consommation que diesel |
| **GPL/GNV** | Crit'Air 1, économique | Réseau limité |
| **Électrique batterie (BEV)** | Crit'Air 1, faible TCO | Autonomie 250-400 km, recharge 1-2 h |
| **Hydrogène (FCEV)** | Crit'Air 1, autonomie 500 km | Coût élevé, stations rares |
| **HVO (huile végétale)** | Compatible diesel, -90 % CO₂ | Pas Crit'Air 1, prix +20 % |

### 5.2 Les aides à la transition

- **Bonus écologique** électrique : jusqu'à 6 000 € pour VUL.
- **Prime à la conversion** : variable selon revenu et véhicule remplacé.
- **Aides locales** ZFE : prime supplémentaire pour transporteurs (Paris, Lyon).
- **Suramortissement fiscal** : 40 % la première année pour véhicules propres > 3,5 T.

### 5.3 Stratégie flotte

- **Court terme (2026-2028)** : maintenir Diesel Euro 6d + commencer 1-2 véhicules électriques pour livraison urbaine.
- **Moyen terme (2028-2030)** : 50 % de la flotte en électrique + bornes au dépôt.
- **Long terme (> 2030)** : 100 % véhicules propres exigée par ZFE.

---

## 6. Cas pratique d'examen

**Énoncé :** vous gérez 5 VUL diesel Euro 5 (Crit'Air 2) faisant des livraisons à Paris. À partir du 1er janvier 2027, Paris exclut Crit'Air 2.

**Questions :**
1. Que faire ?
2. Quel coût estimé ?
3. Quelle stratégie de financement ?

**Correction :**

1. **Renouveler la flotte** vers Crit'Air 1 (électrique ou hydrogène) ou Crit'Air 1 violette (essence hybride). Calendrier serré.
2. **Coût** : 5 × 35 000 € HT = 175 000 € en VUL électriques neufs (avant aides). Avec bonus 5 × 6 000 = 30 000 € → coût net **145 000 €**.
3. **Financement** : crédit-bail (préserver trésorerie) sur 5 ans, mensualité ~ 580 € × 5 véhicules = 2 900 €/mois. À facturer dans le coût de revient (environ +0,07 €/km par véhicule).

---

## 7. Mini-exercice à faire seul

Sur une formation écoconduite à 320 €/conducteur, quelle économie sur carburant attendre par conducteur faisant 60 000 km/an et 9 L/100 km de moyenne ? Calcul ROI.

> 💡 Réponse à la fin du module.

---

## 8. Glossaire

- **EPI** : Équipement de Protection Individuelle.
- **DUER** : Document Unique d'Évaluation des Risques.
- **TMS** : Troubles Musculo-Squelettiques.
- **Écoconduite** : conduite anticipée et économe (-10 à 15 % carburant).
- **ZFE** : Zone à Faibles Émissions, réservée aux Crit'Air autorisés.
- **Crit'Air** : vignette de classement environnemental du véhicule.
- **BEV** : Battery Electric Vehicle (électrique pur).
- **HVO** : Huile Végétale Hydrotraitée, biocarburant.

---

## 9. Synthèse opérationnelle

1. **Risques conducteur** : route, manutention, TMS, stress.
2. **EPI obligatoires** : chaussures S1/S3, gilet HV, gants.
3. **Pause toutes les 2 h** + repos quotidien 11 h.
4. **Alcool** : 0,5 g/L max, 0,8+ = délit.
5. **Écoconduite** : -10 à 15 % carburant, ROI formation < 1 an.
6. **ZFE** : Crit'Air obligatoire dans agglomérations > 150 000 hab.
7. **Renouvellement flotte** : Crit'Air 1 d'ici 2030 dans grandes ZFE.
8. **Aides** : bonus écologique, conversion, suramortissement.

---

## 4. Corrections des mini-exercices du module

### Leçon 4 (ROI écoconduite)
- Sans formation : 60 000 × 9 / 100 = 5 400 L × 1,80 € = **9 720 €/an**.
- Avec formation (-12 %) : 4 752 L × 1,80 € = **8 553,60 €/an**.
- **Économie : 1 166 €/an** par conducteur.
- Coût formation : 320 €.
- **ROI : 320 / 1 166 ≈ 3,3 mois** → bénéfice net dès la 4e mois.

---

## 🎓 Ce que l'examinateur peut demander

- Risques principaux du conducteur et mesures de prévention.
- Bénéfices chiffrés de l'écoconduite.
- Vignettes Crit'Air et calendrier ZFE.
- Aides à la transition véhicules propres.
- QR : « Comment réduire la consommation de carburant d'une flotte ? »

---

## 📋 Mémo à imprimer

```
RISQUES CONDUCTEUR
  Route | Manutention | TMS | Stress | Agression | ADR

EPI OBLIGATOIRES
  Chaussures S1/S3 | Gilet HV classe 2 | Gants

CONDUITE / FATIGUE
  Pause 2 h | Repos quotidien 11 h | Amplitude 12 h max
  Reconnaître bâillement, paupières lourdes → 20 min sieste

ALCOOL / DROGUES
  Alcool max 0,5 g/L (perm. > 0,8 = délit)
  Drogues : tolérance zéro

ÉCOCONDUITE — 7 RÈGLES
  1. Anticiper      2. Démarrer doux    3. Vitesse stable
  4. Passage rapports tôt (1 500 t/min) 5. Limiter clim
  6. Pneus gonflés  7. Moteur coupé > 30 sec
  ROI : -10 à 15 % carburant, formation rentable < 1 an

ZFE / CRIT'AIR
  Crit'Air 1 : élec, H2, hybride rech.
  Crit'Air 2 : diesel Euro 5-6 (depuis 2011)
  Calendrier : Crit'Air 2+ exclus Paris dès 2027
  Amende : 68 € VUL / 135 € PL

TRANSITION FLOTTE
  Bonus 6 000 € VUL électrique
  Suramortissement 40 % véhicules propres
  Crédit-bail recommandé (préserver trésorerie)
```
$lessonF4$,
'Identifier les risques professionnels (route, manutention, TMS), pratiquer l''écoconduite (-12 % carburant) et anticiper la transition ZFE / véhicules propres — la sécurité paie cash dès la première année.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE DE QUESTIONS — 48 QCM + 6 QR (schéma question_bank correct)
  -- =================================================================

  -- ===== LEÇON 1 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le permis B autorise à conduire un véhicule de :',
   '[{"id":"a","label":"≤ 1,5 T","is_correct":false},{"id":"b","label":"≤ 3,5 T","is_correct":true},{"id":"c","label":"≤ 7,5 T","is_correct":false},{"id":"d","label":"≤ 12 T","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-1','permis'], 'mft-2026:moduleF:l1:q1', true,
   'Permis B : véhicule ≤ 3,5 T PTAC + remorque ≤ 750 kg, ou ensemble ≤ 4,25 T.'),
  (v_formation, v_module, 'qcm', 'La FIMO est :',
   '[{"id":"a","label":"Facultative","is_correct":false},{"id":"b","label":"La Formation Initiale Minimale Obligatoire (140 h) pour transport pour autrui","is_correct":true},{"id":"c","label":"Une formation pour les administratifs","is_correct":false},{"id":"d","label":"Réservée aux conducteurs > 3,5 T","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-1','fimo'], 'mft-2026:moduleF:l1:q2', true,
   'FIMO = 140 h obligatoires pour transport pour autrui (marchandises ou voyageurs). Délivre la CQC.'),
  (v_formation, v_module, 'qcm', 'La FCO doit être suivie :',
   '[{"id":"a","label":"Tous les ans","is_correct":false},{"id":"b","label":"Tous les 5 ans, 35 h","is_correct":true},{"id":"c","label":"À l''embauche uniquement","is_correct":false},{"id":"d","label":"Jamais","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-1','fco'], 'mft-2026:moduleF:l1:q3', true,
   'FCO : 35 h tous les 5 ans pour maintenir la CQC valide.'),
  (v_formation, v_module, 'qcm', 'Faire rouler un conducteur sans CQC valide expose à :',
   '[{"id":"a","label":"Aucune sanction","is_correct":false},{"id":"b","label":"Une amende de 3 750 € + immobilisation du véhicule","is_correct":true},{"id":"c","label":"Un avertissement","is_correct":false},{"id":"d","label":"135 € seulement","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-1','sanction'], 'mft-2026:moduleF:l1:q4', true,
   '3 750 € amende + immobilisation immédiate. Employeur co-responsable.'),
  (v_formation, v_module, 'qcm', 'Le permis B96 :',
   '[{"id":"a","label":"N''existe pas","is_correct":false},{"id":"b","label":"Permet ensemble ≤ 4 250 kg avec formation 7 h","is_correct":true},{"id":"c","label":"Remplace le permis BE","is_correct":false},{"id":"d","label":"Concerne les motos","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-f','capa-3-5t','lecon-1','permis'], 'mft-2026:moduleF:l1:q5', true,
   'B96 = extension du B avec formation 7 h pour ensemble ≤ 4 250 kg. Sans examen pratique additionnel.'),
  (v_formation, v_module, 'qcm', 'Un transport en compte propre :',
   '[{"id":"a","label":"Nécessite la FIMO","is_correct":false},{"id":"b","label":"N''est pas soumis à la FIMO","is_correct":true},{"id":"c","label":"Doit avoir un chronotachygraphe","is_correct":false},{"id":"d","label":"Concerne uniquement les voyageurs","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-1','compte-propre'], 'mft-2026:moduleF:l1:q6', true,
   'Compte propre = mes propres marchandises. Pas de FIMO requise.'),
  (v_formation, v_module, 'qcm', 'Le coût indicatif d''une FIMO 140 h est de :',
   '[{"id":"a","label":"300 €","is_correct":false},{"id":"b","label":"2 200 à 3 000 € HT","is_correct":true},{"id":"c","label":"10 000 €","is_correct":false},{"id":"d","label":"Gratuit toujours","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-1','cout'], 'mft-2026:moduleF:l1:q7', true,
   'FIMO 2 200-3 000 € HT, finançable par OPCO Mobilités, plan de développement, CPF.'),
  (v_formation, v_module, 'qcm', 'Un permis a un capital de :',
   '[{"id":"a","label":"6 points","is_correct":false},{"id":"b","label":"8 points","is_correct":false},{"id":"c","label":"12 points","is_correct":true},{"id":"d","label":"20 points","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-1','points'], 'mft-2026:moduleF:l1:q8', true,
   '12 points capital. 1 point récupéré après 6 mois sans infraction.'),
  (v_formation, v_module, 'qcm', 'Tenir un téléphone en main au volant retire :',
   '[{"id":"a","label":"1 point","is_correct":false},{"id":"b","label":"2 points","is_correct":false},{"id":"c","label":"3 points + 135 € amende","is_correct":true},{"id":"d","label":"6 points","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-1','points'], 'mft-2026:moduleF:l1:q9', true,
   'Téléphone tenu en main : 3 points + 135 €.'),
  (v_formation, v_module, 'qcm', 'Le Titre Pro Conducteur Routier :',
   '[{"id":"a","label":"Ne dispense pas de la FIMO","is_correct":false},{"id":"b","label":"Équivaut à la FIMO","is_correct":true},{"id":"c","label":"Est inférieur à la FIMO","is_correct":false},{"id":"d","label":"N''existe pas","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-f','capa-3-5t','lecon-1','titre-pro'], 'mft-2026:moduleF:l1:q10', true,
   'Titre Pro Conducteur Routier (RNCP) équivaut à la FIMO. Idem CAP/Bac Pro Conducteur.'),
  (v_formation, v_module, 'qcm', 'L''OPCO Mobilités :',
   '[{"id":"a","label":"Délivre le permis","is_correct":false},{"id":"b","label":"Finance la formation transport","is_correct":true},{"id":"c","label":"Vend des véhicules","is_correct":false},{"id":"d","label":"Contrôle les vitesses","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-1','opco'], 'mft-2026:moduleF:l1:q11', true,
   'OPCO Mobilités finance FIMO, FCO, ADR…'),
  (v_formation, v_module, 'qcm', 'En cas de CQC périmée, le conducteur est en infraction :',
   '[{"id":"a","label":"À partir du jour J+1 de péremption","is_correct":true},{"id":"b","label":"Tolérance 6 mois","is_correct":false},{"id":"c","label":"Tolérance 1 an","is_correct":false},{"id":"d","label":"Aucune sanction si l''employeur en est informé","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-1','cqc'], 'mft-2026:moduleF:l1:q12', true,
   'Aucune tolérance : dès J+1, infraction. D''où l''importance d''alertes RH 6 mois avant.');

  -- ===== LEÇON 2 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le contrôle technique d''un VUL ≤ 3,5 T se fait :',
   '[{"id":"a","label":"Tous les 6 mois","is_correct":false},{"id":"b","label":"À 4 ans, puis tous les 2 ans","is_correct":true},{"id":"c","label":"Tous les ans","is_correct":false},{"id":"d","label":"Tous les 5 ans","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-2','ct'], 'mft-2026:moduleF:l2:q1', true,
   'CT VUL : 4 ans après mise en circulation, puis tous les 2 ans.'),
  (v_formation, v_module, 'qcm', 'Un PL > 3,5 T doit passer le CT :',
   '[{"id":"a","label":"Tous les 2 ans","is_correct":false},{"id":"b","label":"Tous les ans","is_correct":true},{"id":"c","label":"Tous les 6 mois","is_correct":false},{"id":"d","label":"Jamais","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-2','ct'], 'mft-2026:moduleF:l2:q2', true,
   'PL > 3,5 T : CT annuel dès la 1re année.'),
  (v_formation, v_module, 'qcm', 'L''amende pour défaut de CT est de :',
   '[{"id":"a","label":"35 €","is_correct":false},{"id":"b","label":"135 € (jusqu''à 750 €)","is_correct":true},{"id":"c","label":"1 500 €","is_correct":false},{"id":"d","label":"3 750 €","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-2','sanction'], 'mft-2026:moduleF:l2:q3', true,
   '135 € forfaitaire, majorée à 750 € si non payée. Récidive = immobilisation.'),
  (v_formation, v_module, 'qcm', 'Le chronotachygraphe est obligatoire pour :',
   '[{"id":"a","label":"Tous les VUL","is_correct":false},{"id":"b","label":"Véhicules > 3,5 T (avec exceptions)","is_correct":true},{"id":"c","label":"Uniquement le transport voyageurs","is_correct":false},{"id":"d","label":"Aucun véhicule","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-2','chrono'], 'mft-2026:moduleF:l2:q4', true,
   'Chronotachygraphe : obligatoire > 3,5 T.'),
  (v_formation, v_module, 'qcm', 'Un PL marchandises est bridé à :',
   '[{"id":"a","label":"80 km/h","is_correct":false},{"id":"b","label":"90 km/h","is_correct":true},{"id":"c","label":"100 km/h","is_correct":false},{"id":"d","label":"130 km/h","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-2','vitesse'], 'mft-2026:moduleF:l2:q5', true,
   'PL marchandises 90 km/h. Autocars 100 km/h.'),
  (v_formation, v_module, 'qcm', 'Une vidange moteur d''un VUL diesel se fait typiquement tous les :',
   '[{"id":"a","label":"1 000 km","is_correct":false},{"id":"b","label":"15 000 à 30 000 km","is_correct":true},{"id":"c","label":"100 000 km","is_correct":false},{"id":"d","label":"500 000 km","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-2','vidange'], 'mft-2026:moduleF:l2:q6', true,
   'Vidange diesel VUL : 15 000 à 30 000 km selon constructeur.'),
  (v_formation, v_module, 'qcm', 'Un CT défavorable critique :',
   '[{"id":"a","label":"Permet 2 mois pour régulariser","is_correct":false},{"id":"b","label":"Immobilise le véhicule immédiatement","is_correct":true},{"id":"c","label":"N''existe pas","is_correct":false},{"id":"d","label":"Coûte juste 50 € de plus","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-2','ct'], 'mft-2026:moduleF:l2:q7', true,
   'Défavorable critique = immobilisation immédiate. Trajet réparateur ou domicile uniquement.'),
  (v_formation, v_module, 'qcm', 'Vendre un véhicule sans CT à jour de < 6 mois :',
   '[{"id":"a","label":"Pas de problème","is_correct":false},{"id":"b","label":"Rend la vente nulle (acheteur peut annuler)","is_correct":true},{"id":"c","label":"Coûte 100 € à l''acheteur","is_correct":false},{"id":"d","label":"Ne concerne que les neufs","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-2','vente'], 'mft-2026:moduleF:l2:q8', true,
   'Acheteur peut faire annuler la vente si CT > 6 mois (art. R. 323-22 C. route).'),
  (v_formation, v_module, 'qcm', 'L''ABS, l''ESP, le LDW sont :',
   '[{"id":"a","label":"Des marques de véhicules","is_correct":false},{"id":"b","label":"Des dispositifs électroniques de sécurité","is_correct":true},{"id":"c","label":"Des permis","is_correct":false},{"id":"d","label":"Des assurances","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-2','dispositifs'], 'mft-2026:moduleF:l2:q9', true,
   'ABS = anti-blocage. ESP = stabilité. LDW = alerte ligne. AEB = freinage urgence.'),
  (v_formation, v_module, 'qcm', 'L''EAD (Éthylotest Anti-Démarrage) est obligatoire :',
   '[{"id":"a","label":"Sur tous les véhicules","is_correct":false},{"id":"b","label":"Sur autocars de transport public + récidivistes alcool","is_correct":true},{"id":"c","label":"Uniquement sur PL","is_correct":false},{"id":"d","label":"Jamais","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-f','capa-3-5t','lecon-2','ead'], 'mft-2026:moduleF:l2:q10', true,
   'EAD obligatoire sur autocars depuis 2010 et sur véhicules conduits par récidivistes alcool.'),
  (v_formation, v_module, 'qcm', 'Une fiche défaut sert à :',
   '[{"id":"a","label":"Sanctionner le conducteur","is_correct":false},{"id":"b","label":"Tracer formellement une anomalie pour décision atelier","is_correct":true},{"id":"c","label":"Calculer le salaire","is_correct":false},{"id":"d","label":"Embaucher un mécanicien","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-2','fiche'], 'mft-2026:moduleF:l2:q11', true,
   'Fiche défaut : document interne tracé, daté, signé.'),
  (v_formation, v_module, 'qcm', 'Faire rouler un véhicule défectueux peut entraîner :',
   '[{"id":"a","label":"Aucune conséquence","is_correct":false},{"id":"b","label":"Mise en danger d''autrui : 5 ans + 75 000 € si accident grave","is_correct":true},{"id":"c","label":"Une simple amende","is_correct":false},{"id":"d","label":"Un retrait de 1 point","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-f','capa-3-5t','lecon-2','penal'], 'mft-2026:moduleF:l2:q12', true,
   'Mise en danger = délit. Si accident grave : 5 ans + 75 000 € (homicide) ou 3 ans + 45 000 € (blessures).');

  -- ===== LEÇON 3 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le PTAC d''un véhicule est inscrit :',
   '[{"id":"a","label":"Sur le pare-brise","is_correct":false},{"id":"b","label":"Sur la carte grise (case F.2)","is_correct":true},{"id":"c","label":"Sur l''assurance","is_correct":false},{"id":"d","label":"Sur la plaque","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-3','ptac'], 'mft-2026:moduleF:l3:q1', true,
   'Carte grise case F.2 = PTAC.'),
  (v_formation, v_module, 'qcm', 'La charge utile (CU) se calcule :',
   '[{"id":"a","label":"PTAC + PV","is_correct":false},{"id":"b","label":"PTAC − PV","is_correct":true},{"id":"c","label":"PV − PTAC","is_correct":false},{"id":"d","label":"PV × 2","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-3','cu'], 'mft-2026:moduleF:l3:q2', true,
   'CU = PTAC − PV.'),
  (v_formation, v_module, 'qcm', 'Une surcharge entre 5 et 20 % du PTAC entraîne :',
   '[{"id":"a","label":"Pas d''amende","is_correct":false},{"id":"b","label":"135 € + immobilisation possible","is_correct":true},{"id":"c","label":"3 750 €","is_correct":false},{"id":"d","label":"6 mois prison","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-3','surcharge'], 'mft-2026:moduleF:l3:q3', true,
   '5-20 % : 135 € + immobilisation possible. > 20 % : 1 500 € + immobilisation + déchargement.'),
  (v_formation, v_module, 'qcm', 'Un chargement non arrimé peut coûter :',
   '[{"id":"a","label":"35 €","is_correct":false},{"id":"b","label":"750 € + responsabilité pénale en cas d''accident","is_correct":true},{"id":"c","label":"Aucune amende","is_correct":false},{"id":"d","label":"Toujours immobilisation immédiate","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-3','arrimage'], 'mft-2026:moduleF:l3:q4', true,
   '750 € + risque pénal majeur (mise en danger, blessures involontaires).'),
  (v_formation, v_module, 'qcm', 'La largeur maximale standard d''un VUL est de :',
   '[{"id":"a","label":"2 m","is_correct":false},{"id":"b","label":"2,55 m","is_correct":true},{"id":"c","label":"3 m","is_correct":false},{"id":"d","label":"4 m","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-3','gabarit'], 'mft-2026:moduleF:l3:q5', true,
   'Largeur max 2,55 m. Au-delà = transport exceptionnel.'),
  (v_formation, v_module, 'qcm', 'L''ADR est :',
   '[{"id":"a","label":"L''Accord Détaillé pour les Routiers","is_correct":false},{"id":"b","label":"L''Accord européen sur le transport de marchandises Dangereuses par Route","is_correct":true},{"id":"c","label":"Un syndicat","is_correct":false},{"id":"d","label":"Une assurance","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-3','adr'], 'mft-2026:moduleF:l3:q6', true,
   'ADR : Accord européen relatif au transport international des marchandises dangereuses par route.'),
  (v_formation, v_module, 'qcm', 'Combien de classes de matières dangereuses définit l''ADR ?',
   '[{"id":"a","label":"3","is_correct":false},{"id":"b","label":"6","is_correct":false},{"id":"c","label":"9","is_correct":true},{"id":"d","label":"18","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-3','adr'], 'mft-2026:moduleF:l3:q7', true,
   '9 classes : explosifs, gaz, inflammables liq., solides inflam., comburants, toxiques, radioactifs, corrosifs, divers.'),
  (v_formation, v_module, 'qcm', 'La formation ADR de base dure :',
   '[{"id":"a","label":"1 jour","is_correct":false},{"id":"b","label":"3 jours (~700 € HT)","is_correct":true},{"id":"c","label":"2 semaines","is_correct":false},{"id":"d","label":"Aucune","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-3','adr'], 'mft-2026:moduleF:l3:q8', true,
   'ADR base : 3 jours, ~700 € HT. Spécialisations en sus.'),
  (v_formation, v_module, 'qcm', 'Les plaques orange ADR sont placées :',
   '[{"id":"a","label":"Au plafond","is_correct":false},{"id":"b","label":"À l''avant et à l''arrière du véhicule","is_correct":true},{"id":"c","label":"Sur le pare-brise","is_correct":false},{"id":"d","label":"Sur les roues","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-3','adr'], 'mft-2026:moduleF:l3:q9', true,
   'Plaques orange à l''avant et à l''arrière + étiquettes losanges sur les côtés.'),
  (v_formation, v_module, 'qcm', 'L''ATP (Accord sur les Transports Périssables) concerne :',
   '[{"id":"a","label":"Les véhicules frigorifiques et isothermes","is_correct":true},{"id":"b","label":"L''alcool","is_correct":false},{"id":"c","label":"Les bois","is_correct":false},{"id":"d","label":"Les voitures","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-f','capa-3-5t','lecon-3','atp'], 'mft-2026:moduleF:l3:q10', true,
   'ATP = certification du véhicule pour transport de denrées périssables.'),
  (v_formation, v_module, 'qcm', 'Pour transporter ses propres déchets pro non dangereux > 0,5 t/voyage, il faut :',
   '[{"id":"a","label":"Rien","is_correct":false},{"id":"b","label":"Un récépissé de transport de déchets délivré par préfecture","is_correct":true},{"id":"c","label":"La FIMO","is_correct":false},{"id":"d","label":"Un permis spécifique","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-f','capa-3-5t','lecon-3','dechets'], 'mft-2026:moduleF:l3:q11', true,
   'Récépissé préfecture obligatoire dès 0,5 t/voyage non dangereux.'),
  (v_formation, v_module, 'qcm', 'La norme d''arrimage de référence en Europe est :',
   '[{"id":"a","label":"ISO 9001","is_correct":false},{"id":"b","label":"EN 12195-1","is_correct":true},{"id":"c","label":"FIA","is_correct":false},{"id":"d","label":"CE 561/2006","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-f','capa-3-5t','lecon-3','arrimage'], 'mft-2026:moduleF:l3:q12', true,
   'EN 12195-1. Forces dynamiques : 0,8 g vers l''avant, 0,5 g latéralement.');

  -- ===== LEÇON 4 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'L''écoconduite permet de réduire la consommation de carburant de :',
   '[{"id":"a","label":"1 %","is_correct":false},{"id":"b","label":"10 à 15 %","is_correct":true},{"id":"c","label":"30 %","is_correct":false},{"id":"d","label":"50 %","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-4','ecoconduite'], 'mft-2026:moduleF:l4:q1', true,
   '-10 à 15 % carburant + -30 % usure + -50 % accidents.'),
  (v_formation, v_module, 'qcm', 'Une ZFE :',
   '[{"id":"a","label":"Autorise tous les véhicules","is_correct":false},{"id":"b","label":"Limite l''accès selon la vignette Crit''Air","is_correct":true},{"id":"c","label":"Concerne uniquement Paris","is_correct":false},{"id":"d","label":"Est facultative","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-4','zfe'], 'mft-2026:moduleF:l4:q2', true,
   'ZFE obligatoire dans agglomérations > 150 000 hab.'),
  (v_formation, v_module, 'qcm', 'Un véhicule électrique (BEV) reçoit la vignette :',
   '[{"id":"a","label":"Crit''Air 1","is_correct":true},{"id":"b","label":"Crit''Air 3","is_correct":false},{"id":"c","label":"Non classé","is_correct":false},{"id":"d","label":"Crit''Air 5","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-4','crit-air'], 'mft-2026:moduleF:l4:q3', true,
   'Crit''Air 1 (verte ou violette pour électrique/hydrogène/hybride rechargeable).'),
  (v_formation, v_module, 'qcm', 'Un diesel Euro 5 (depuis 2011) est classé :',
   '[{"id":"a","label":"Crit''Air 1","is_correct":false},{"id":"b","label":"Crit''Air 2 (jaune)","is_correct":true},{"id":"c","label":"Crit''Air 4","is_correct":false},{"id":"d","label":"Non classé","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-4','crit-air'], 'mft-2026:moduleF:l4:q4', true,
   'Diesel Euro 5/6 = Crit''Air 2.'),
  (v_formation, v_module, 'qcm', 'L''obligation de pause après 4 h 30 de conduite continue :',
   '[{"id":"a","label":"15 min","is_correct":false},{"id":"b","label":"30 min","is_correct":false},{"id":"c","label":"45 min","is_correct":true},{"id":"d","label":"1 h","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-4','pause'], 'mft-2026:moduleF:l4:q5', true,
   'Conduite continue maxi 4 h 30, suivie de 45 min. Règlement 561/2006.'),
  (v_formation, v_module, 'qcm', 'Le bonus écologique pour VUL électrique 2026 (entreprise) peut atteindre :',
   '[{"id":"a","label":"500 €","is_correct":false},{"id":"b","label":"6 000 €","is_correct":true},{"id":"c","label":"30 000 €","is_correct":false},{"id":"d","label":"Aucune aide","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-4','bonus'], 'mft-2026:moduleF:l4:q6', true,
   'Bonus VUL électrique : jusqu''à 6 000 € pour entreprise.'),
  (v_formation, v_module, 'qcm', 'Le taux d''alcool maximum autorisé au volant en France est de :',
   '[{"id":"a","label":"0,2 g/L","is_correct":false},{"id":"b","label":"0,5 g/L","is_correct":true},{"id":"c","label":"0,8 g/L","is_correct":false},{"id":"d","label":"1 g/L","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-4','alcool'], 'mft-2026:moduleF:l4:q7', true,
   '0,5 g/L sang max. > 0,8 g/L = délit (2 ans + 4 500 €).'),
  (v_formation, v_module, 'qcm', 'Un EPI obligatoirement présent à bord d''un véhicule de transport :',
   '[{"id":"a","label":"Le casque de chantier","is_correct":false},{"id":"b","label":"Le gilet haute visibilité","is_correct":true},{"id":"c","label":"Une perceuse","is_correct":false},{"id":"d","label":"Une caméra","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-f','capa-3-5t','lecon-4','epi'], 'mft-2026:moduleF:l4:q8', true,
   'Gilet HV obligatoire à bord (présence + port en cas d''arrêt sur autoroute).'),
  (v_formation, v_module, 'qcm', 'À 18 h éveillé, les réflexes du conducteur :',
   '[{"id":"a","label":"Sont meilleurs","is_correct":false},{"id":"b","label":"Équivalent à 0,5 g/L d''alcool","is_correct":true},{"id":"c","label":"Sont identiques à l''éveil","is_correct":false},{"id":"d","label":"Disparaissent totalement","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-f','capa-3-5t','lecon-4','fatigue'], 'mft-2026:moduleF:l4:q9', true,
   '18 h éveillé = équivalent 0,5 g/L. À 24 h = 1 g/L.'),
  (v_formation, v_module, 'qcm', 'Le suramortissement fiscal pour véhicule propre permet :',
   '[{"id":"a","label":"Aucun avantage","is_correct":false},{"id":"b","label":"Une déduction supplémentaire de 40 % la 1re année","is_correct":true},{"id":"c","label":"Un crédit d''impôt","is_correct":false},{"id":"d","label":"Un report d''IS","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-f','capa-3-5t','lecon-4','fiscal'], 'mft-2026:moduleF:l4:q10', true,
   'Suramortissement = 40 % de la valeur d''acquisition déductible en plus.'),
  (v_formation, v_module, 'qcm', 'Le HVO (Huile Végétale Hydrotraitée) :',
   '[{"id":"a","label":"Est interdit","is_correct":false},{"id":"b","label":"Est compatible diesel et réduit CO₂ de 90 %","is_correct":true},{"id":"c","label":"Concerne uniquement l''aviation","is_correct":false},{"id":"d","label":"Coûte le même prix","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-f','capa-3-5t','lecon-4','hvo'], 'mft-2026:moduleF:l4:q11', true,
   'HVO = biocarburant utilisable dans diesel modernes. -90 % CO₂. Crit''Air reste 2.'),
  (v_formation, v_module, 'qcm', 'Un pneu sous-gonflé de 0,3 bar entraîne :',
   '[{"id":"a","label":"Pas d''effet","is_correct":false},{"id":"b","label":"+3 % de carburant","is_correct":true},{"id":"c","label":"-3 % de carburant","is_correct":false},{"id":"d","label":"+30 % de carburant","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-f','capa-3-5t','lecon-4','pneus'], 'mft-2026:moduleF:l4:q12', true,
   'Pneu sous-gonflé : +3 % carburant par 0,3 bar manquants + usure prématurée.');

  -- ===== 6 QR =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qr',
   'Quelles formations un conducteur de VUL doit-il posséder pour transporter des marchandises pour le compte d''autrui ? Périodicité du renouvellement ?',
   NULL, 5, 'moyen', ARRAY['module-f','capa-3-5t','qr','formations'], 'mft-2026:moduleF:qr1', true,
   'Permis B, FIMO Marchandises 140 h (ou équivalence Titre Pro/CAP/Bac Pro), CQC valable 5 ans, FCO 35 h tous les 5 ans. Sans CQC : 3 750 € + immobilisation. Coût FIMO ~2 500 €, FCO ~800 €, OPCO Mobilités finance.'),
  (v_formation, v_module, 'qr',
   'Procédure quand un conducteur signale une défaillance sur son véhicule (ex : freins qui tirent à droite). Étapes et responsabilités ?',
   NULL, 5, 'difficile', ARRAY['module-f','capa-3-5t','qr','fiche-defaut'], 'mft-2026:moduleF:qr2', true,
   '(1) Fiche défaut tracée, datée, signée. (2) Évaluation gravité. (3) Immobilisation volontaire si dangereux. (4) Diagnostic atelier. (5) Réparation documentée. (6) CT volontaire si freinage. Sécurité de résultat employeur. Faire rouler sans réparation = mise en danger d''autrui (5 ans + 75 000 €).'),
  (v_formation, v_module, 'qr',
   'Un client demande de transporter en VUL 200 L de white-spirit (classe 3 ADR). Vérifications, formations, autorisations requises ?',
   NULL, 6, 'difficile', ARRAY['module-f','capa-3-5t','qr','adr'], 'mft-2026:moduleF:qr3', true,
   'Vérifier seuil ADR (1 000 points classe 3). Formation ADR base 3 j (~700 €) ou 8 h petites quantités. Documents : transport (n° ONU 1300, classe 3, GE III), consignes écrites, fiche sécurité, certificat ADR conducteur. Équipements : extincteur, cales, lampe non métallique, EPI, plaques orange.'),
  (v_formation, v_module, 'qr',
   'Calculez la charge utile d''un Renault Master L3H2 (PTAC 3 500 kg, PV 2 200 kg). Conducteur 75 kg + 80 L de gasoil + 1,2 t de marchandises. Surcharge ?',
   NULL, 5, 'moyen', ARRAY['module-f','capa-3-5t','qr','calcul'], 'mft-2026:moduleF:qr4', true,
   'CU = 1 300 kg. Charge embarquée = 75 + 70 + 1 200 = 1 345 kg. Total chargé = 3 545 kg. Surcharge = 45 kg (1,3 %). Sanction : 90 € (< 5 %). À corriger.'),
  (v_formation, v_module, 'qr',
   'Comment réduire significativement la consommation de carburant d''une flotte de 5 VUL ? 5 leviers chiffrés.',
   NULL, 6, 'moyen', ARRAY['module-f','capa-3-5t','qr','ecoconduite'], 'mft-2026:moduleF:qr5', true,
   '(1) Écoconduite (-12 %, ROI <1 an). (2) Pneus gonflés (-3 % par 0,3 bar). (3) Régulateur (-5 à 8 %). (4) Suppression galerie (-5 à 10 %). (5) Renouvellement Euro 6 (-10 à 20 %). Économie 5 VUL × 50 000 km × 8 L/100 = 36 000 €/an, gain ~6 500 €/an.'),
  (v_formation, v_module, 'qr',
   'Vous gérez 5 VUL diesel Euro 5 (Crit''Air 2) qui livrent à Paris. Paris exclut Crit''Air 2 dès 2027. Stratégie ?',
   NULL, 5, 'difficile', ARRAY['module-f','capa-3-5t','qr','zfe'], 'mft-2026:moduleF:qr6', true,
   '(1) Diagnostic flotte (âge, valeur). (2) Renouvellement 12-18 mois vers VUL électriques. 175 000 € HT − 30 000 € bonus = 145 000 € net. (3) Crédit-bail 60 mois ~580 €/mois × 5 = 2 900 €/mois. (4) Borne dépôt + aides locales. Démarrer dès 2026.'),

  (v_formation, v_module, 'qr',
   'Un de vos conducteurs salariés se présente le matin avec une CQC qui expire dans 5 jours. La FCO suivante n''est programmée que dans 3 semaines (places complètes chez l''organisme). Vous avez 2 livraisons critiques pour un client GMS prévues les 6 jours qui suivent.

a. Pouvez-vous le faire rouler aujourd''hui et demain ? Pourquoi ?
b. Que se passe-t-il s''il roule le 6e jour avec une CQC périmée ? Sanctions pour lui et pour vous ?
c. Quelles 3 solutions opérationnelles immédiates pour ne pas pénaliser le client GMS ?
d. Quelle organisation RH pour ne plus revivre cette situation ?',
   NULL, 6, 'difficile', ARRAY['module-f','capa-3-5t','qr','cqc','rh','cas-pratique'], 'mft-2026:moduleF:qr7', true,
   'Correction attendue : a. OUI, tant que la CQC est valide il peut rouler normalement. La FCO doit être effectuée AVANT la date de péremption. b. Conducteur en infraction dès J+1 de péremption : amende 3 750 € + immobilisation immédiate du véhicule. Employeur co-responsable s''il a laissé rouler en connaissance de cause : amende 3 750 € à 7 500 € + suspension possible de la licence. c. (1) Recherche urgente d''une session FCO express (Promotrans, AFTRAL, ECF — il existe des stages le week-end ou en intensif 3 jours), (2) Sous-traitance des livraisons à un partenaire dûment licencié pour les jours concernés, (3) Affectation du conducteur aux opérations internes (quai, manutention, administratif) jusqu''au stage. d. Mise en place d''un tableau de bord RH avec dates de péremption CQC et alertes 6 mois avant échéance ; planification annuelle des stages FCO en début d''année (janvier) ; abonnement à 2 organismes de formation pour multiplier les disponibilités ; budget formation provisionné dès le 1er janvier.');

  -- =================================================================
  -- QUIZZES (4 entraînement + 1 examen blanc)
  -- =================================================================

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Permis et formations — Quiz',
          'Quiz d''entraînement (12 questions) sur permis B/B96/BE, FIMO, FCO et CQC.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026:moduleF:l1:%';

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Véhicule et contrôle technique — Quiz',
          'Quiz d''entraînement (12 questions) sur entretien, CT, chronotachygraphe, ABS, EAD et fiche défaut.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026:moduleF:l2:%';

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Chargement, gabarit et ADR — Quiz',
          'Quiz d''entraînement (12 questions) sur PTAC, charge utile, arrimage, gabarit, ADR (9 classes).',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026:moduleF:l3:%';

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Sécurité et environnement — Quiz',
          'Quiz d''entraînement (12 questions) sur écoconduite (-12 % carburant), Crit''Air, ZFE et alcool/fatigue.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026:moduleF:l4:%';

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (v_module, 'Examen blanc — Module F Sécurité',
          'Examen blanc reproduisant les conditions de l''examen national : 13 QCM représentatifs des 4 leçons + 5 QR, durée 60 min, seuil 50 %.',
          'examen', 3600, 50, true)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref IN (
     'mft-2026:moduleF:l1:q2','mft-2026:moduleF:l1:q3','mft-2026:moduleF:l1:q4','mft-2026:moduleF:l1:q6',
     'mft-2026:moduleF:l2:q1','mft-2026:moduleF:l2:q3','mft-2026:moduleF:l2:q4','mft-2026:moduleF:l2:q12',
     'mft-2026:moduleF:l3:q2','mft-2026:moduleF:l3:q4','mft-2026:moduleF:l3:q7',
     'mft-2026:moduleF:l4:q2','mft-2026:moduleF:l4:q7',
     'mft-2026:moduleF:qr1','mft-2026:moduleF:qr2','mft-2026:moduleF:qr3','mft-2026:moduleF:qr5','mft-2026:moduleF:qr7'
   );

  RAISE NOTICE '✓ Module F v3 dense importé : 4 leçons (permis/FIMO/FCO, véhicule/CT, chargement/ADR, sécurité/écoconduite/ZFE), 48 QCM, 7 QR, 5 quiz.';

END $module_f_v3$;
