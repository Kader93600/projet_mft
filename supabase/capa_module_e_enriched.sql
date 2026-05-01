-- =====================================================================
-- MODULE E — GESTION DES SALARIÉS (Capa -3,5T)
-- 5 leçons premium ~ 175 min.
-- =====================================================================

DO $mod_e$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation capacite-3-5t introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc défini.'; END IF;

  SELECT id INTO v_module FROM public.modules WHERE slug = 'capa-gestion-salaries' LIMIT 1;
  IF v_module IS NULL THEN
    INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
    VALUES (
      'Gestion des salariés et droit du travail',
      'capa-gestion-salaries',
      v_bloc,
      'Recruter, contractualiser, gérer le temps de travail, encadrer la relation employeur-salarié et appliquer la convention collective transport.',
      'intermediaire', 175, 50
    ) RETURNING id INTO v_module;
    INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
    VALUES (v_formation, v_module, 50, true) ON CONFLICT DO NOTHING;
  END IF;

  -- LEÇON 1 — Recruter et contractualiser
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'recruter-contractualiser') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'Recruter et contractualiser', 'recruter-contractualiser', 1, 35,
$l$
La première embauche change radicalement la structure d'une entreprise. Vous passez de **chef d'entreprise solo** à **employeur** avec ses obligations, ses risques, mais aussi ses leviers de croissance. Cette leçon vous donne le cadre.

:::objectifs
- Choisir le **bon contrat** (CDI / CDD / intérim).
- Maîtriser la **DPAE** et les premières démarches.
- Sécuriser le **contrat de travail** et la **période d'essai**.
:::

## Le choix du contrat

### CDI — Contrat à Durée Indéterminée

**La forme normale et générale** du contrat de travail. Pas de terme fixé à l'avance.

**Avantages employeur** :
- Stabilité de la relation.
- Image positive (recrutement, banque, clients).
- Pas de surcoût de fin (sauf rupture conventionnelle ou licenciement).

**Inconvénients** :
- Engagement long terme.
- Procédure lourde en cas de séparation.

### CDD — Contrat à Durée Déterminée

**Forme exceptionnelle**, autorisée uniquement dans les cas listés par la loi :

1. Remplacement (maternité, maladie, congé).
2. Accroissement temporaire d'activité.
3. Activité saisonnière.
4. Emploi d'usage (BTP, événementiel — pas le transport en règle générale).

**Conditions** :
- Durée maximale : **18 mois** (renouvellement compris).
- Renouvellement : 2 fois maximum.
- Indemnité de précarité : **10 % du salaire brut** versé.

:::piege
**Erreur courante** : signer un CDD pour "tester" un candidat. Ce motif est **illégal**. Si le tribunal requalifie, votre CDD devient CDI rétroactif + indemnités.
:::

### Intérim

**Mise à disposition** par une agence de travail temporaire.

**Avantages** : flexibilité maximale, pas de gestion administrative.
**Inconvénients** : coût élevé (~ 1,8 fois le salaire net).

**Quand l'utiliser** : pic d'activité ponctuel, urgence de remplacement, test d'un candidat avant CDD/CDI.

## La DPAE — Déclaration Préalable à l'Embauche

**Obligation absolue** : déclaration à l'URSSAF **AVANT** la prise de poste.

### Délais

- **Au plus tôt** : 8 jours avant l'embauche.
- **Au plus tard** : à la fin du jour précédant la prise de poste.

### Modalités

- En ligne sur **net-entreprises.fr** ou **urssaf.fr**.
- Renseigner : identité salarié, poste, type de contrat, dates.
- Récépissé à conserver.

:::law code="Code du travail" article="L. 1221-10" date="01/01/2024"
L'embauche d'un salarié ne peut intervenir qu'après déclaration nominative accomplie par l'employeur auprès des organismes de protection sociale.
:::

### Sanctions absence DPAE

**Travail dissimulé** : jusqu'à **3 ans de prison + 45 000 € d'amende** + redressement URSSAF + interdiction de gérer.

## Le contrat de travail

### Mentions obligatoires

1. **Identité** des parties (employeur, salarié).
2. **Lieu** de travail (ou mention "selon affectation").
3. **Date** d'embauche.
4. **Fonction et qualification** (par référence à la convention collective).
5. **Rémunération** (montant, structure, date de paiement).
6. **Durée du travail** (35h, temps partiel, etc.).
7. **Convention collective applicable** (CCNTRAAT pour le transport).
8. **Période d'essai** (durée, conditions de renouvellement).
9. **Mention RGPD** sur les données personnelles.

### Mentions recommandées

- **Mobilité géographique** (pour adapter en cas de besoin).
- **Confidentialité** et non-concurrence (pour les fonctions sensibles).
- **Clause de dédit-formation** (si financement formation > 2 000 €).

### La période d'essai

| Catégorie | Durée maximale | Renouvellement |
|---|---|---|
| Ouvrier / Employé | **2 mois** | 1 fois (4 mois max) |
| Agent de maîtrise / Technicien | **3 mois** | 1 fois (6 mois max) |
| Cadre | **4 mois** | 1 fois (8 mois max) |

**Attention** : pour le transport, la convention collective peut imposer des durées différentes (souvent 1 mois pour conducteurs).

### La rupture pendant l'essai

**Pas de motif** à donner. Mais :

| Ancienneté du salarié | Préavis employeur |
|---|---|
| < 8 jours | 24 heures |
| 8 jours - 1 mois | 48 heures |
| 1 mois - 3 mois | 2 semaines |
| > 3 mois | 1 mois |

:::caspratique
**Karim recrute** son premier chauffeur (Patrick, ancien CDD chez un confrère).

**Étapes réalisées** :
1. Entretien d'embauche : compétences, motivation, références vérifiées.
2. **DPAE** envoyée la veille de l'embauche (récépissé conservé).
3. **Contrat CDI** signé en 2 exemplaires :
   - Coefficient 138 M (conducteur courte distance, CCNTRAAT).
   - Rémunération : 2 100 € brut + indemnité repas conventionnelle.
   - Période d'essai : 1 mois (conformément à la convention).
   - Convention collective applicable : CCNTRAAT.
4. **Carte BTP/transport** demandée (CIPI).
5. **Médecine du travail** : visite d'embauche programmée dans les 2 mois.
6. **Mutuelle obligatoire** : adhésion à effectuer dans les 30 jours.

Coût total embauche pour Karim : ~ 1 500 € (assurance, mutuelle, frais administratifs initiaux).

Coût mensuel salarié (brut + charges patronales 45 %) : 2 100 + 945 = **3 045 €/mois**, soit ~ 36 540 €/an.
:::

## La promesse d'embauche

**Important** : un email du type "On est OK pour démarrer le 15 mai au poste de chauffeur, salaire 2 100 €" peut constituer une **promesse d'embauche** juridiquement engageante.

**Si l'employeur se rétracte** : indemnités équivalentes à un licenciement sans cause réelle et sérieuse (jusqu'à 6 mois de salaire selon barème Macron).

:::conseil
Toujours formaliser une **proposition d'embauche** sous **2 conditions** : signature du contrat ET passage de la médecine du travail. Cela vous permet de revenir en arrière proprement si nécessaire.
:::

## En synthèse

| Étape | Délai | Document |
|---|---|---|
| Sélection candidat | - | Notes d'entretien |
| Promesse | - | Email avec conditions |
| DPAE | Avant prise de poste | Récépissé URSSAF |
| Contrat de travail | Jour 1 | 2 exemplaires signés |
| Médecine du travail | Sous 2 mois | Avis d'aptitude |
| Mutuelle | Sous 30 jours | Bulletin d'adhésion |
$l$,
$s$
**À retenir**
- CDI = forme normale, CDD = exceptions strictes, intérim = pic d'activité.
- DPAE obligatoire AVANT prise de poste (sinon travail dissimulé).
- Contrat écrit avec 9 mentions obligatoires + convention collective applicable.
- Période d'essai : durées selon catégorie + convention.
- Promesse d'embauche par email = engagement juridique réel.
$s$);
  END IF;

  -- LEÇON 2 — Temps de travail et paie
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'temps-travail-paie') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'Temps de travail et paie', 'temps-travail-paie', 2, 35,
$l$
La gestion du temps de travail et des heures supplémentaires est une **source classique de contentieux**. Bien géré, c'est un levier de motivation. Mal géré, c'est un risque prud'hommes garanti.

:::objectifs
- Maîtriser la **durée légale** et les heures supplémentaires.
- Comprendre la **structure d'un bulletin de paie**.
- Appliquer les **règles spécifiques transport** (CCNTRAAT).
:::

## La durée légale et les heures supplémentaires

### Durée légale

**35 heures par semaine** (ou 1 607 h/an en annualisation).

### Heures supplémentaires

**Calcul** : au-delà de 35h/semaine.

| Heures | Majoration |
|---|---|
| 36e à 43e (8 premières HS) | **+ 25 %** |
| 44e et au-delà | **+ 50 %** |

### Contingent annuel

- **220 heures/an** : contingent légal.
- Au-delà : avis du CSE + autorisation Inspection du travail.

### Repos compensateur

- Au-delà du contingent : **repos compensateur obligatoire** (100 % en + 25 % de majoration).
- Possibilité de remplacer la majoration par du repos.

:::caspratique
**Patrick — chauffeur** travaille 42h/semaine de manière régulière.

**Calcul de la paie hebdomadaire (taux horaire 13,85 €)** :
- 35h normales × 13,85 = **484,75 €**
- 7h supplémentaires (36e à 42e) × 13,85 × 1,25 = **121,21 €**
- **Salaire brut hebdo : 605,96 €**

Sur le mois (4,33 semaines en moyenne) : 605,96 × 4,33 = **2 623,80 € brut**.

**Si Karim ne déclarait pas les HS et payait juste 1 730 €** : Patrick saisit les prud'hommes 1 an plus tard. Récupération des HS sur 3 ans = ~ 12 000 € + dommages-intérêts.

**Risque** : licenciement sans cause si Karim sanctionne ensuite Patrick = **double condamnation**.
:::

## La règle des conducteurs (CCNTRAAT)

Le transport routier a ses propres règles, par dérogation au Code du travail :

### Forfait mensuel

Convention 79 (annexe transport marchandises) : possibilité de **forfait mensuel** :
- 169 heures/mois (équivalent 39h/semaine).
- 186 heures/mois (équivalent 43h/semaine).
- 203 heures/mois (équivalent 46h/semaine).

**Avantages** : simplifie la paie, intègre forfaitairement les HS.

**Inconvénients** : si dépassement réel régulier, requalification possible.

### Coefficients

Chaque salarié est classé par **coefficient hiérarchique** dans la grille CCNTRAAT :

| Coefficient | Catégorie | Exemple |
|---|---|---|
| 110 M | Conducteur léger débutant | Coursier débutant |
| 120 M | Conducteur léger | Coursier confirmé |
| 138 M | Conducteur courte distance | Chauffeur ≤ 3,5 T |
| 150 M | Conducteur grande distance | Chauffeur PL |

**Conséquence** : le **salaire minimum conventionnel** est fixé par coefficient (parfois supérieur au SMIC).

### Prime d'ancienneté

**À partir de 2 ans** d'ancienneté, par paliers :

| Ancienneté | Prime |
|---|---|
| 2 ans | 2 % |
| 5 ans | 4 % |
| 10 ans | 8 % |
| 15 ans | 12 % |

Calculée sur le salaire de base (hors primes et HS).

## Le bulletin de paie

### Structure type

```
Salaire de base                      2 100,00 €
+ Heures supp 25%                       121,21 €
+ Prime d'ancienneté 2%                  44,00 €
= Salaire brut                       2 265,21 €

- Cotisations sociales (~22 %)        - 498,35 €
= Salaire net imposable              1 766,86 €

- CSG-CRDS non déductibles              - 67,96 €
- Prélèvement à la source               - 88,00 €
= Salaire net à payer                1 610,90 €
```

### Charges patronales (en sus du brut)

**Total charges patronales transport** : ~ 45-50 % du salaire brut.

Exemples :
- URSSAF (santé, retraite de base, famille, AT-MP) : ~ 30 %.
- Retraite complémentaire (Agirc-Arrco, transport) : ~ 8 %.
- Chômage : ~ 4,05 %.
- Formation, taxe d'apprentissage : ~ 2 %.
- Mutuelle : forfait variable.

**Pour 2 100 € brut** : coût employeur ~ **3 045 €/mois** soit **36 540 €/an**.

:::piege
**Confusion brut/net** : un candidat parle souvent en **net**. L'employeur raisonne en **coût total**. Pour un net de 1 600 € : prévoir ~ 3 000 € de coût employeur (charges + pas-loin de doubler).
:::

## Les indemnités obligatoires (transport)

### Indemnité de repas

- Conducteurs en déplacement : **18,40 €/repas** (2025).
- Justificatif : note ou forfait conventionnel.
- **Non soumise à charges** dans les limites fiscales.

### Indemnité de découcher

- Si nuit hors du domicile : forfait conventionnel (~ 50-60 €).

### Indemnité de transport (domicile-travail)

- **Prise en charge employeur 50 %** des frais d'abonnement transport en commun.
- Possibilité de forfait mobilités durables (jusqu'à 800 €/an, exonéré).

### Frais de repas non transport

- En entreprise : ticket restaurant (52 % employeur, 48 % salarié, jusqu'à 6,91 €/jour exonérés).

## En synthèse

| Sujet | Règle |
|---|---|
| Durée légale | 35h/semaine, 1 607 h/an |
| HS | 25 % (36-43h), 50 % (44h+) |
| Contingent | 220 h/an légal |
| Forfait CCNTRAAT | 169h, 186h, 203h |
| Prime d'ancienneté | À partir de 2 ans, 2 % par palier |
| Charges patronales | ~ 45-50 % du brut |
:::conseil
**Logiciel de paie** : indispensable dès 1 salarié. Pegasus, PayFit, Sage Paie. Coût 25-50 €/mois. Évite les erreurs fatales.
:::
$l$,
$s$
**À retenir**
- 35h légales, HS majorées 25 % puis 50 %.
- Forfait mensuel CCNTRAAT (169/186/203 h) simplifie la gestion.
- Coefficients hiérarchiques et salaires minimums conventionnels.
- Prime d'ancienneté à partir de 2 ans (2 %), évolutive.
- Coût employeur = brut × ~ 1,45 (charges patronales).
- Indemnités repas/découcher non soumises à charges (transport).
$s$);
  END IF;

  -- LEÇON 3 — Management et discipline
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'management-discipline') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'Management, discipline et procédures', 'management-discipline', 3, 35,
$l$
Manager une petite équipe de transport, c'est conjuguer **proximité** (équipe à taille humaine) et **rigueur** (sécurité, conformité, qualité). Cette leçon vous donne les outils pour cadrer la relation et anticiper les tensions.

:::objectifs
- Comprendre le **règlement intérieur** et son rôle.
- Maîtriser la **procédure disciplinaire** (avertissement, mise à pied, licenciement).
- Anticiper les **conflits** par un management préventif.
:::

## Le règlement intérieur

**Obligatoire** dans les entreprises de **≥ 50 salariés**. Recommandé dès **20 salariés**. Pour les TPE : facultatif mais utile.

### Contenu

1. **Hygiène et sécurité** : EPI, alcoolémie, drogues.
2. **Discipline** : nature des sanctions (avertissement, mise à pied, licenciement).
3. **Droits de la défense** : convocation préalable, assistance.
4. **Harcèlement** : prévention, procédure.

### Procédure d'adoption

1. Rédaction par l'employeur.
2. Consultation du **CSE**.
3. **Dépôt** au greffe du conseil de prud'hommes.
4. **Affichage** dans l'entreprise.
5. Transmission à l'**Inspection du travail**.

## La gradation des sanctions

### Niveau 1 : Avertissement écrit

**Pour quoi** : retard isolé, manquement mineur (oubli ponctuel).

**Procédure** : courrier signé par le dirigeant, daté, consigné dans le dossier salarié.

**Effet** : aucune répercussion sur le salaire ou le poste.

### Niveau 2 : Mise à pied disciplinaire

**Pour quoi** : faute plus grave (insulte, comportement inapproprié, négligence répétée).

**Procédure** :
1. **Convocation** à entretien préalable (LRAR ou remis en mains propres) — 5 jours minimum avant.
2. **Entretien** : explication, possibilité d'assistance.
3. **Notification** de la sanction (LRAR), entre 2 jours et 1 mois après.

**Effet** : suspension du contrat sans rémunération (1 à 3 jours typiquement).

### Niveau 3 : Licenciement pour cause réelle et sérieuse

**Pour quoi** : faute grave OU motif personnel sérieux (insuffisance professionnelle, mésentente).

**Procédure** :
1. **Mise à pied conservatoire** (si faute grave + sécurité menacée).
2. **Convocation** à entretien préalable (LRAR ou remis).
3. **Entretien** (5 jours minimum après convocation).
4. **Notification** : entre 2 jours après l'entretien et 1 mois après.
5. **Préavis** sauf faute grave (1-2 mois selon ancienneté).
6. **Indemnités** :
   - Indemnité de licenciement (sauf faute grave).
   - Solde de tout compte.
   - Reçu pour solde.

:::law code="Code du travail" article="L. 1232-1" date="01/01/2024"
Tout licenciement pour motif personnel est motivé et justifié par une cause réelle et sérieuse.
:::

### Niveau 4 : Faute grave / faute lourde

**Faute grave** : rend impossible le maintien du salarié dans l'entreprise (vol, alcoolémie en service, abandon de poste).

**Conséquence** : pas de préavis, pas d'indemnité de licenciement.

**Faute lourde** : faute grave + intention de nuire à l'entreprise. Très rare. Pas d'indemnité de congés payés.

:::caspratique
**Cas réel** : un chauffeur a été surpris **en état d'ébriété** au volant lors d'un contrôle routier. Police vous appelle.

**Réflexes immédiats** :
1. **Mise à pied conservatoire** par téléphone : "Tu rentres immédiatement, tu es suspendu en attendant la suite."
2. Convocation à entretien préalable LRAR sous 24-48h.
3. Entretien : recueillir les explications, vérifier la procédure police.
4. Notification du **licenciement pour faute grave**.

**Pas de préavis, pas d'indemnité de licenciement** (faute grave caractérisée).

**Risque pour vous** : si pas de procédure rigoureuse, le licenciement peut être requalifié en "sans cause réelle" → 6 mois de salaire d'indemnité = ~ 12 000 € à payer.

**Préventif** : mention claire dans le contrat ET le règlement intérieur sur la tolérance zéro alcool/drogues.
:::

## L'avertissement et la prescription

### Délai de prescription

- **2 mois** entre les faits et l'engagement de la procédure.
- **Au-delà** : sanction non recevable.

### Cumul des sanctions

- Pas de **2 sanctions** pour les mêmes faits.
- Une faute "ancienne" (déjà sanctionnée par avertissement) peut servir de **contexte** pour une faute nouvelle.

## Le management préventif

### 1. L'entretien annuel

**Obligatoire** : entretien professionnel **tous les 2 ans** (Code du travail L. 6315-1).

**Recommandé** : entretien annuel d'évaluation **chaque année**.

**Contenu** :
- Bilan de l'année écoulée.
- Objectifs pour l'année suivante.
- Besoins en formation.
- Évolution professionnelle souhaitée.

### 2. La communication régulière

- **Réunion d'équipe** mensuelle (15-30 min suffisent).
- **Brief quotidien** : 5 minutes au démarrage.
- **Information** sur les évolutions (salaires, contrats clients, nouveaux clients).

### 3. La reconnaissance

- **Verbalisation** : "Bravo pour cette mission rondement menée."
- **Primes ponctuelles** : pour objectifs atteints, qualité, fidélité.
- **Avantages** : tickets restaurant, mutuelle premium, journées de formation.

### 4. La résolution de conflits

**3 étapes** :
1. **Écoute individuelle** : recueillir le ressenti.
2. **Médiation** : faire dialoguer les parties.
3. **Décision** : trancher si nécessaire, rappeler les règles.

:::piege
**Ne jamais "balayer sous le tapis"** un conflit. Il revient toujours plus fort. Mieux vaut un échange tendu de 30 minutes qu'un mois de tension diffuse.
:::

## En synthèse

| Sanction | Procédure | Effet |
|---|---|---|
| Avertissement | Courrier signé | Trace au dossier |
| Mise à pied | Convocation + entretien + notification | 1-3 jours sans solde |
| Licenciement personnel | Convocation + entretien + notification + préavis | Indemnités + solde |
| Faute grave | Idem + mise à pied conservatoire | Pas d'indemnité licenciement |
:::conseil
**Documenter systématiquement** : email après échange, compte-rendu d'entretien, fiche de suivi. En cas de prud'hommes, c'est votre seule défense.
:::
$l$,
$s$
**À retenir**
- Règlement intérieur : recommandé dès 20 salariés.
- 4 niveaux de sanction : avertissement, mise à pied, licenciement, faute grave.
- Procédure : convocation LRAR + 5 jours + entretien + notification 2 j à 1 mois.
- Délai de prescription : 2 mois entre faits et action.
- Entretien professionnel obligatoire tous les 2 ans.
- Documenter chaque échange = défense en cas de prud'hommes.
$s$);
  END IF;

  -- LEÇON 4 — Convention collective et social
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'convention-collective-social') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'CCNTRAAT et obligations sociales', 'convention-collective-social', 4, 35,
$l$
La **CCNTRAAT** (Convention Collective Nationale des Transports Routiers et Activités Auxiliaires du Transport) est le **texte de référence** du secteur. Elle complète et adapte le Code du travail. La connaître, c'est éviter des erreurs coûteuses.

:::objectifs
- Maîtriser les **dispositifs spécifiques** de la CCNTRAAT.
- Connaître les **obligations sociales** (médecine du travail, mutuelle, prévoyance).
- Préparer les **représentants du personnel** (CSE).
:::

## La CCNTRAAT : structure

**IDCC 0016** — applicable à toute entreprise de transport routier.

### Annexes

| Annexe | Concerne |
|---|---|
| **Annexe 1** | Ouvriers (conducteurs, manutentionnaires) — la plus utilisée |
| **Annexe 2** | Employés (administratifs, sédentaires) |
| **Annexe 3** | TAM (Techniciens Agents de Maîtrise) |
| **Annexe 4** | Cadres |

### Apports majeurs vs Code du travail

1. **Salaires minimums conventionnels** par coefficient (souvent > SMIC).
2. **Prime d'ancienneté** dès 2 ans.
3. **Forfaits** mensuels d'heures spécifiques transport.
4. **Indemnités de déplacement** (repas, découcher).
5. **Procédure de licenciement** légèrement adaptée.
6. **Préavis** majorés.

## Les obligations sociales obligatoires

### 1. Médecine du travail

**Obligation** : adhérer à un **Service de Prévention et de Santé au Travail Interentreprises (SPSTI)** ou créer un service interne (entreprises ≥ 500).

**Visites** :
- **Embauche** : visite d'information et de prévention dans les **2 mois** (sauf postes à risque : visite préalable obligatoire).
- **Périodique** : tous les 5 ans (salariés sans risque) ou tous les 4 ans + intermédiaire à 2 ans (postes à risque).
- **Reprise** : après arrêt > 30 jours.
- **Prédateur** : sur demande de l'employeur, du salarié ou du médecin.

**Coût** : ~ 100 € par salarié et par an.

### 2. Mutuelle santé

**Obligatoire depuis 2016** : couverture santé collective pour TOUS les salariés.

**Conditions** :
- Couverture minimum : **panier de soins** légal.
- Financement : **employeur ≥ 50 %** de la cotisation.
- Caractère collectif : tous les salariés (sauf cas de dispense).

**Coût employeur** : ~ 30-50 €/mois/salarié.

### 3. Prévoyance

**Obligatoire en transport** depuis la convention collective.

**Couvre** :
- **Décès** : capital aux ayants droit.
- **Invalidité** : rente complémentaire.
- **Incapacité de travail** : indemnités journalières complémentaires aux IJSS.

**Coût** : ~ 1-1,5 % du salaire brut, partagé employeur/salarié.

### 4. Retraite complémentaire

**Agirc-Arrco** pour les non-cadres et cadres.

**Cotisation** : ~ 8 % du salaire brut, dont 60 % employeur.

### 5. Formation continue

**1 % du salaire brut** dans les entreprises < 11 salariés (collecté par l'OPCO Mobilités).

**Au-delà** : taux variables selon taille et accords.

**Utilisation** :
- Plan de développement des compétences.
- CPF (Compte Personnel de Formation) : 500 €/an pour chaque salarié.

## Les représentants du personnel — CSE

### Seuils d'effectif

| Effectif | Obligation |
|---|---|
| < 11 salariés | Aucune |
| 11-49 | CSE simplifié (1-2 membres) |
| 50-249 | CSE classique |
| ≥ 250 | CSE + commissions spécialisées |

### Mise en place du CSE

**Procédure** :
1. **Information** des salariés (affichage).
2. **Calcul** du nombre de sièges selon l'effectif.
3. **Élections** : 1er tour (collèges), 2nd si nécessaire.
4. **Procès-verbaux** déposés à l'Inspection du travail.

### Compétences du CSE

- **Réclamations** individuelles et collectives.
- **Santé, sécurité, conditions de travail**.
- **Information-consultation** sur les décisions économiques et sociales (orientation, plan).
- **Activités sociales et culturelles** (en mutuelle ou directement).

:::caspratique
**Karim** atteint 13 salariés.

**Obligations nouvelles** :
1. **Mise en place du CSE simplifié** (2 sièges + 2 suppléants).
2. **Élections** organisées dans les 90 jours suivant le franchissement.
3. **Première réunion** du CSE : présentation des missions, agenda annuel.
4. **Crédit d'heures** délégué (10h/mois pour le titulaire dans une TPE).

**Coût annuel** : ~ 0,5 % de la masse salariale (réunions, formation, expertise externe occasionnelle).
:::

## Les obligations annuelles

### Bilan social

**Obligatoire** ≥ 300 salariés. Pour les autres : **DOETH** (Déclaration Obligatoire d'Emploi des Travailleurs Handicapés) si ≥ 20 salariés.

**Travailleurs handicapés** : 6 % de l'effectif minimum, sinon contribution AGEFIPH.

### Index égalité H/F

**Obligatoire** ≥ 50 salariés. Note sur 100 publiée chaque année. Si < 75/100 : actions correctrices.

### Bilan formation

**Plan de développement des compétences** : programme annuel des formations à dispenser.

## En synthèse

| Obligation | Seuil / Modalité |
|---|---|
| CCNTRAAT | Toutes entreprises transport |
| Médecine du travail | Toutes (SPSTI) |
| Mutuelle santé | Toutes (depuis 2016) |
| Prévoyance | Toutes (CCNTRAAT) |
| Retraite Agirc-Arrco | Toutes |
| OPCO formation | Toutes (taux selon effectif) |
| CSE | ≥ 11 salariés |
| DOETH | ≥ 20 salariés |
| Index égalité H/F | ≥ 50 salariés |
:::conseil
**Externaliser la paie** : un cabinet expert-comptable spécialisé transport (Marathon, Ades) facture 35-50 €/bulletin. Coût marginal vs sécurité juridique majeure.
:::
$l$,
$s$
**À retenir**
- CCNTRAAT IDCC 0016 = texte de référence transport.
- 4 annexes : ouvriers, employés, TAM, cadres.
- Médecine du travail + mutuelle + prévoyance + Agirc-Arrco = obligatoires.
- CSE obligatoire dès 11 salariés (simplifié), 50 salariés (classique).
- DOETH ≥ 20, Index égalité ≥ 50, Bilan social ≥ 300.
- Externaliser la paie = sécurité juridique.
$s$);
  END IF;

  -- LEÇON 5 — Cas pratiques salariés
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'cas-pratiques-salaries') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'Cas pratiques de synthèse — Salariés', 'cas-pratiques-salaries', 5, 35,
$l$
4 cas pratiques mobilisant l'ensemble du module.

## Cas n° 1 — La première embauche

**Situation** : votre activité explose, vous embauchez votre premier chauffeur. Salaire net cible : 1 800 €.

**Question** : quel est le coût total pour l'entreprise ?

:::caspratique
**Calcul** :

**Du net au brut** :
- Net 1 800 € → brut ~ 2 350 € (charges salariales 23 %).

**Du brut au coût employeur** :
- Brut 2 350 € + charges patronales 47 % = **3 455 €/mois**.

**Coût annuel** :
- 3 455 × 12 = **41 460 €/an**.

**Charges associées** :
- Médecine du travail : 100 €/an.
- Mutuelle (50 %) : 240 €/an.
- Prévoyance : 350 €/an.
- Vêtements travail : 200 €/an.
- **Total : ~ 42 350 €/an** soit **3 530 €/mois**.

**Vérification rentabilité** : si ce chauffeur produit 60 000 km/an facturés à 0,90 €/km = **54 000 € de CA**. Marge brute = 54 000 - 42 350 = **11 650 €**. Plus la marge sur le surplus d'activité que vous, le dirigeant, pouvez consacrer à du commercial. Embauche rentable.
:::

## Cas n° 2 — Heures supp non payées

**Situation** : un chauffeur prétend avoir fait 8h supp/semaine non payées sur les 6 derniers mois. Il saisit les prud'hommes. Vous n'avez pas de relevé d'heures précis.

**Question** : que risquez-vous ?

:::caspratique
**Analyse** :

**Charge de la preuve** :
- En cas de litige sur les heures, **l'employeur** doit prouver les heures effectivement travaillées.
- Sans relevé précis (carnet de bord, GPS, planning), c'est la parole du salarié qui prime.

**Calcul théorique** :
- 8h supp × 26 semaines × 13,85 €/h × 1,25 majoration = **3 596 €**.
- + intérêts de retard.
- + dommages-intérêts si préjudice prouvé.

**Total possible : 4 000-5 000 €** + frais de procédure.

**Préventif** :
- **Tachy**graphe ou GPS pour traçabilité (même non obligatoire).
- **Ordre de mission** signé en début de journée.
- **Bordereau** d'activité quotidien rempli par le chauffeur.
- **Logiciel de gestion** : MyDrivers, Trasfic, etc.

**Coût d'un relevé d'heures fiable** : ~ 30 €/mois/chauffeur. Coût d'un litige perdu : 5 000 €. Calcul vite fait.
:::

## Cas n° 3 — Le licenciement pour insuffisance professionnelle

**Situation** : un chauffeur en CDI depuis 18 mois multiplie les retards, accroche le véhicule, gère mal la relation client. Vous voulez le licencier. Pas de faute grave, mais un manque de compétences évident.

**Question** : quelle est la procédure ?

:::caspratique
**Démarche** :

**1. Documenter l'insuffisance** :
- Plaintes clients (emails).
- Constats de retards (planning, échanges).
- Sinistres véhicule (devis réparation).
- Compte-rendus d'entretiens informels.

**2. Entretien professionnel formel** :
- Faire le point sur les difficultés.
- **Plan d'amélioration** sur 3 mois (formation, accompagnement, objectifs précis).
- Compte-rendu signé.

**3. Si le plan échoue** :
- **Convocation** à entretien préalable (LRAR).
- **Entretien** 5 jours plus tard.
- **Notification** licenciement pour insuffisance professionnelle.

**4. Conséquences financières** :
- **Préavis** : 2 mois (CCNTRAAT, ancienneté > 6 mois).
- **Indemnité de licenciement** : 1/4 mois × ancienneté = (1/4) × 1,5 × 2 100 = **787 €**.
- **Solde de tout compte** : congés payés, RTT.
- **Total** : ~ 5 000-6 000 € (préavis + indemnités).

**Risque** : si le plan d'amélioration n'a pas été réel ou la procédure mal suivie → requalification "sans cause réelle" → 6 mois de salaire d'indemnité = ~ 12 600 €.

**Conseil** : faire valider la procédure par un **avocat en droit du travail** (300-500 € pour une consultation). Investissement rentable.
:::

## Cas n° 4 — La discrimination présumée

**Situation** : une salariée enceinte vous annonce sa grossesse. Vous l'aviez prévue pour une promotion. Vous ne donnez plus de nouvelles de la promotion. 6 mois plus tard, elle saisit le défenseur des droits pour discrimination.

**Question** : quels sont vos risques ?

:::caspratique
**Analyse** :

**Cadre juridique** :
- **Discrimination en raison de la grossesse** = délit pénal (3 ans + 45 000 €).
- **Présomption de discrimination** : si la salariée présente des éléments laissant supposer une discrimination, c'est à l'**employeur** de prouver qu'il n'y a pas de discrimination.

**Risques concrets** :
1. Conseil de prud'hommes : indemnités jusqu'à 24 mois de salaire si licenciement nul.
2. Défenseur des droits : recommandation, médiation, mise en demeure.
3. Procédure pénale possible.
4. **Dégâts d'image** dans la profession.

**Bonne pratique** :
1. **Documenter** la décision de promotion **AVANT** l'annonce de grossesse.
2. **Si la promotion est légitime** : la maintenir, la salariée pouvant être promue malgré la grossesse.
3. **Si motifs économiques réels** (autres collaborateurs plus performants) : documenter par écrit avec critères objectifs.
4. **Maintenir le dialogue** : entretiens réguliers, accompagnement de la maternité.

**Préventif** :
- **Politique RH écrite** sur la non-discrimination.
- **Formation des managers** sur les biais inconscients.
- **Index égalité H/F** suivi mensuellement.

**Conseil** : ne **jamais** prendre de décision RH dans les 6 mois suivant une annonce de grossesse sans avoir documenté préalablement les critères objectifs.
:::

## En synthèse module E

Vous maîtrisez les **4 piliers** de la gestion salariale :

1. **Recruter** dans les règles (DPAE, contrat, période d'essai).
2. **Payer** correctement (heures supp, conventions, charges).
3. **Manager** avec rigueur (sanctions, procédures).
4. **Respecter** les obligations sociales (CCNTRAAT, médecine du travail, CSE).

:::conseil
La gestion RH est probablement le **risque juridique majeur** d'une PME. Plus que les contrôles fiscaux. Investir dans la formation RH et un bon expert-comptable est rentable dès la 1ère erreur évitée.
:::
$l$,
$s$
**À retenir — Synthèse module E**
- Première embauche : prévoir 1,7-1,8 fois le salaire net en coût employeur.
- Heures supp : la charge de la preuve incombe à l'employeur.
- Licenciement insuffisance pro : plan d'amélioration documenté avant.
- Décision RH après annonce grossesse = risque maximal de discrimination.
- Investir dans formation RH + avocat conseil = rentable dès la 1ère erreur évitée.
$s$);
  END IF;

  RAISE NOTICE 'Module E (Capa - Salariés) : 5 leçons premium créées.';
END $mod_e$;
