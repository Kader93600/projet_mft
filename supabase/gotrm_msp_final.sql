-- =====================================================================
-- GOTRM (RNCP 40990) — EXAMEN BLANC FINAL au format MSP
-- Mise en Situation Professionnelle écrite : 4 dossiers d'exploitation
-- enchaînés (demande, planification, tournée, qualité), chronométrés 3 h.
-- Format identique à l'épreuve réelle, contenu intégralement reformulé.
-- =====================================================================

DO $msp$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid; v_quiz uuid;
  v_lesson_intro uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-msp-final-examen-blanc';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'MSP — Examen blanc final (format épreuve réelle)',
    'gotrm-msp-final-examen-blanc', v_bloc,
    'Examen blanc au format Mise en Situation Professionnelle (MSP) écrite : 4 dossiers d''exploitation enchaînés (demande de transport, planification, étude de tournée, qualité), chronométrés 3 heures. Format identique à l''épreuve réelle, contenu intégralement reformulé.',
    'avance', 180, 230
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 230, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:msp:%';

  -- =================================================================
  -- LEÇON : présentation entreprise et consignes
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Présentation entreprise et consignes MSP',
    'gotrm-msp-presentation-consignes', 1, 15,
$msplesson1$
# Examen blanc final — Mise en Situation Professionnelle (MSP)

## Format de l'épreuve

| Élément | Détail |
|---|---|
| Durée | **3 heures** chronométrées |
| Composition | **4 dossiers** d'exploitation enchaînés |
| Seuil de réussite | **50 %** sur l'ensemble |
| Format | Identique à l'épreuve réelle du titre professionnel |
| Calculatrice | Non scientifique autorisée |
| Documents | Aucun document autorisé |

## Présentation de l'entreprise

Vous êtes **gestionnaire des opérations** chez **TRANSPORTS LOGIDOC** depuis 8 mois. L'entreprise est implantée à **Châteauroux (Indre)** et compte :

- **42 véhicules** : 18 tracteurs 44 t (longue distance), 16 porteurs 19 t (régional), 8 véhicules ATP frigo (FRC)
- **52 conducteurs** salariés (CDI majoritairement)
- **Chiffre d'affaires** : 8,4 M€ HT (exercice clos)
- **Activités** : 60 % FTL longue distance France/UE, 25 % distribution régionale, 15 % spécifique frigo
- **Clients principaux** : 3 industriels (40 % CA), 12 chargeurs réguliers (35 %), 30 clients spots (25 %)

Vous rapportez à la directrice d'exploitation, **Mme Patricia VINCENDEAU**.

## Consignes générales

- Les 4 dossiers sont **indépendants** mais s'inscrivent dans le quotidien de l'entreprise.
- Vous pouvez les traiter dans **l'ordre de votre choix**.
- Pour chaque sous-question, **structure ta réponse** (paragraphes, listes, tableaux, calculs détaillés).
- Le correcteur valorise la **démarche** autant que le résultat.
- En cas de calcul, **pose les chiffres** et indique les unités.

## Vue d'ensemble des 4 dossiers

| Dossier | Thème | Volume estimé |
|---|---|---|
| **1** | Traitement d'une demande de transport | 30 min |
| **2** | Planification d'une tournée | 50 min |
| **3** | Étude de coût et cotation | 60 min |
| **4** | Gestion d'un litige et qualité de service | 40 min |

Bon courage !
$msplesson1$,
'Présentation TRANSPORTS LOGIDOC (Châteauroux, 42 véhicules, 8,4 M€ CA) et consignes MSP : 4 dossiers en 3 h, seuil 50 %.'
  ) RETURNING id INTO v_lesson_intro;

  -- =================================================================
  -- DOSSIER 1 — Traitement d'une demande de transport
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, source_ref, type, statement, choices, max_score, difficulty, tags, active, explanation) VALUES
  (v_formation, 'mft-2026-gotrm:msp:dossier:1', 'qr',
$msp_d1$
# DOSSIER 1 — Traitement d'une demande de transport (≈ 30 min)

## Contexte

Lundi matin 9 h 15. Vous recevez un email de M. Anthony GAVOTTE, responsable expéditions chez **MOULAGES PRÉCIS DU CENTRE** (Issoudun, 36) :

> Bonjour,
>
> Pourriez-vous nous établir un devis pour un transport urgent ? Nous avons besoin de livrer 3 palettes vers notre client en région parisienne. C'est urgent, idéalement demain.
>
> Merci par retour.
>
> Anthony Gavotte
> Tél : 02.54.XX.XX.XX

Vous ne connaissez pas ce client. Une recherche rapide indique qu'il s'agit d'une PME de moulage plastique, 25 salariés, en activité depuis 14 ans.

## Travail à faire

**Question 1.1 — Qualification de la demande (8 points)**

Listez **toutes les informations manquantes** pour pouvoir établir une cotation fiable. Classez-les en :

a. **Bloquantes** (sans elles, impossible de coter)
b. **Importantes** (à demander mais pouvant faire l'objet d'hypothèses si urgent)
c. **Secondaires** (à clarifier mais ne bloquent pas la cotation)

**Question 1.2 — Mail de relance (5 points)**

Rédigez le **mail de relance** que vous adressez à M. Gavotte pour obtenir les informations manquantes. Le mail doit être :
- Professionnel et courtois
- Structuré (numérotation des questions)
- Engageant sur un délai de réponse de votre part
- Signé proprement

**Question 1.3 — Vérifications préalables (4 points)**

Au-delà de la qualification de la demande, quelles **3 vérifications préalables** allez-vous mener concernant l'entreprise MOULAGES PRÉCIS DU CENTRE avant d'engager une mission ? Justifiez chaque vérification.

**Question 1.4 — Délais de cotation (3 points)**

Quel **délai de cotation** annoncez-vous à M. Gavotte ? Justifiez votre choix.
$msp_d1$,
NULL, 20, 'difficile',
ARRAY['msp', 'demande-transport', 'qualification', 'cas-pratique'],
true,
$msp_d1_corr$
# Correction Dossier 1

## Question 1.1 — Qualification de la demande (8 points)

**Informations bloquantes (4 points) :**
- Adresse précise d'enlèvement à Issoudun (rue, n°, nom du site)
- Adresse précise de livraison en région parisienne (ville, code postal, rue)
- Date et créneau d'enlèvement (date précise + plage horaire)
- Date et créneau de livraison (J+1 = lendemain matin ? après-midi ? créneau précis ?)

**Informations importantes (3 points) :**
- Poids brut total des 3 palettes (ou poids unitaire)
- Volume / hauteur des palettes (savoir si gerbables)
- Nature de la marchandise (pour estimer fragilité, ADR éventuel, IMO)
- Conditionnement (palettes EUR 80×120 ou autre format)
- Type de véhicule possible : porteur 19 t suffisant ou semi nécessaire ? Hayon ?
- Conditions de manutention au chargement et au déchargement (quai, transpalette, gerbeur, hayon)

**Informations secondaires (1 point) :**
- Valeur déclarée de la marchandise (pour assurance et déclaration de valeur sur CMR)
- Conditions de paiement souhaitées
- Existence de contraintes particulières (RDV strict, accès limité, créneau ZFE)
- Contre-remboursement éventuel
- Référence interne client pour le bon de commande

## Question 1.2 — Mail de relance (5 points)

```
Objet : RE: Demande de cotation transport — Issoudun → région parisienne
       (réf TLD-2026-XXXX)

Bonjour M. Gavotte,

Je vous remercie de votre demande et reviens vers vous rapidement
pour pouvoir vous établir une cotation précise.

Afin d'optimiser au mieux notre proposition, pourriez-vous me
préciser les éléments suivants :

1. Adresse exacte d'enlèvement à Issoudun (rue + n°).
2. Adresse exacte de livraison en région parisienne (ville,
   code postal, rue).
3. Date et créneau d'enlèvement souhaités.
4. Date et créneau de livraison souhaités.
5. Poids brut total des 3 palettes (ou poids unitaire).
6. Volume ou hauteur des palettes (gerbables ou non gerbables ?).
7. Nature de la marchandise et conditionnement.
8. Conditions de manutention :
   - Au chargement : quai disponible ? hayon nécessaire ?
   - À la livraison : quai disponible ? hayon nécessaire ?
9. La marchandise nécessite-t-elle un véhicule particulier
   (température dirigée, ADR…) ?

Sur la base de ces éléments, je vous adresserai une cotation
détaillée sous 2 heures ouvrées.

Restant à votre disposition pour tout complément,

Cordialement,

[Votre prénom NOM]
Gestionnaire d'exploitation
TRANSPORTS LOGIDOC
Tél direct : 02.54.XX.XX.XX
contact@transports-logidoc.fr
```

Évaluation :
- Salutation et formule de politesse adaptées (1 pt)
- Numérotation claire des questions (1 pt)
- Couverture de toutes les informations bloquantes (1,5 pt)
- Engagement de délai de réponse précis (0,5 pt)
- Signature professionnelle complète (1 pt)

## Question 1.3 — Vérifications préalables (4 points)

Trois vérifications obligatoires avant tout engagement avec un nouveau client :

**1. Vérification de la solidité financière (1,5 pt)**
Consultation gratuite sur Infogreffe ou Societe.com pour vérifier :
- Existence légale et SIREN actif
- Absence de procédure collective (sauvegarde, redressement, liquidation)
- Bilans des 3 derniers exercices (rentabilité, fonds propres)
- Pas d'inscription d'hypothèque ou nantissement récent

Justification : éviter de livrer pour un client risquant de ne pas payer.

**2. Vérification de l'assurance crédit ou souscription d'une encours (1 pt)**
Si l'entreprise a une assurance crédit (Coface, Atradius), demande de plafond pour ce client. Sinon, fixation d'un encours interne maximal (par exemple 8 000 € pour une première collaboration).

**3. Vérification réputationnelle et historique (1,5 pt)**
- Recherche internet (avis, presse)
- Consultation éventuelle d'autres transporteurs (réseau professionnel)
- Vérification de l'existence physique de l'adresse de livraison (cohérent avec l'activité ?)
- Référence d'un autre fournisseur si possible

Justification : prévenir les fraudes (faux clients, marchandise détournée).

## Question 1.4 — Délais de cotation (3 points)

**Délai annoncé : 2 heures ouvrées après réception des éléments complets.**

Justification :
- Une cotation simple sur un trajet régional standard ne demande que 15-30 min de calcul.
- 2 heures laissent une marge pour vérifier la disponibilité des véhicules, contrôler le coût km de référence, valider le prix avec un éventuel responsable commercial.
- Annoncer 2 heures permet de gérer les imprévus tout en montrant de la réactivité.
- Pour un nouveau client, on évite l'engagement immédiat (trop court = improvisation).
- En cas d'urgence absolue exprimée par le client, possibilité de réduire à 1 heure mais c'est un choix tactique commercial.
$msp_d1_corr$);

  -- =================================================================
  -- DOSSIER 2 — Planification d'une tournée
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, source_ref, type, statement, choices, max_score, difficulty, tags, active, explanation) VALUES
  (v_formation, 'mft-2026-gotrm:msp:dossier:2', 'qr',
$msp_d2$
# DOSSIER 2 — Planification d'une tournée (≈ 50 min)

## Contexte

Mardi 8 h 30. Mme Vincendeau vous confie la planification d'une **tournée de distribution** pour le compte d'un client récurrent : **DISTRIBUTION CENTRE-VAL DE LOIRE** (grossiste boulangerie-pâtisserie).

Le véhicule disponible : **porteur 12 t avec hayon arrière**, conducteur Karim BOUKADJANI (CDI, ancienneté 4 ans, CQC valide, FCO 2 ans).

Le conducteur prend son service à **6 h 00** au dépôt de Châteauroux. Sa fenêtre de service est de **9 heures maximum** (retour au dépôt avant 15 h 00).

**Liste des 9 livraisons à effectuer** ce mardi matin :

| Pt | Client | Ville | Créneau RDV | Poids | Particularités |
|----|--------|-------|-------------|-------|----------------|
| A | Boulangerie LE PAIN DORÉ | Issoudun (36) | 7h-9h | 110 kg | Quai accessible |
| B | Pâtisserie THÉVENIN | Vatan (36) | 7h-9h | 95 kg | Hayon + transpalette |
| C | BOULANGERIE DU CENTRE | Vierzon (18) | 8h-10h | 140 kg | Quai accessible |
| D | Pâtisserie MARCHANDIN | Bourges (18) | 8h-11h | 80 kg | Hayon |
| E | LES DÉLICES DE CHARLES | Saint-Florent-sur-Cher (18) | 8h-11h | 65 kg | Hayon |
| F | Boulangerie LAFOND | La Châtre (36) | 9h-12h | 120 kg | Quai accessible |
| G | LA HUCHE D'OR | Issoudun (36) | 9h-12h | 90 kg | Hayon |
| H | Pâtisserie GUYET | Châteauroux (36) | 9h-13h | 75 kg | Quai |
| I | BOULANGERIE DAMAS | Argenton-sur-Creuse (36) | 10h-13h | 105 kg | Hayon |

**Poids total** : 880 kg (largement sous le PTAC du porteur 12 t).

**Distances indicatives entre points** (km par la route, depuis Châteauroux dépôt) :

| Vers | Distance (km) | Temps trajet à 50 km/h moyen |
|------|---------------|------------------------------|
| A — Issoudun | 38 | 45 min |
| B — Vatan | 50 | 60 min |
| C — Vierzon | 70 | 1 h 25 |
| D — Bourges | 65 | 1 h 20 |
| E — Saint-Florent | 80 | 1 h 35 |
| F — La Châtre | 35 | 40 min |
| G — Issoudun | 38 | 45 min |
| H — Châteauroux centre | 5 | 10 min |
| I — Argenton-sur-Creuse | 28 | 35 min |

**Temps moyen par livraison** (déchargement + signature) : **15 minutes** par point standard, **20 minutes** si hayon.

## Travail à faire

**Question 2.1 — Construction de la tournée optimale (10 points)**

Construisez la tournée optimale en respectant tous les créneaux RDV et en minimisant les kilomètres totaux.

Présentez votre solution sous forme de **tableau ordonné** avec, pour chaque étape :
- L'heure d'arrivée prévisionnelle
- L'heure de départ après livraison
- Les kilomètres parcourus depuis le point précédent

**Question 2.2 — Vérification de la conformité R561 (5 points)**

Le conducteur Karim Boukadjani prend son service à 6 h 00. Vérifiez la conformité de votre tournée par rapport au règlement (CE) 561/2006 :

- Temps de conduite total cumulé
- Position de la pause obligatoire de 45 minutes
- Respect du temps de service maximum de 9 h

Si la pause R561 n'est pas naturellement intégrée, **réorganisez** votre tournée pour la respecter.

**Question 2.3 — Aléa imprévu (5 points)**

À 9 h 30, alors que vous êtes en cours de tournée, le client F (LAFOND, La Châtre) appelle pour signaler que sa boulangerie sera **fermée le matin** suite à un dégât des eaux et qu'il souhaite reporter la livraison à l'après-midi.

Que faites-vous ? Listez **3 options possibles** et argumentez votre **décision** finale, en indiquant les conséquences sur la tournée.
$msp_d2$,
NULL, 20, 'difficile',
ARRAY['msp', 'planification', 'tournee', 'r561', 'cas-pratique'],
true,
$msp_d2_corr$
# Correction Dossier 2

## Question 2.1 — Construction de la tournée optimale (10 points)

**Méthode** : appliquer la méthode des clusters (regroupement géographique) puis ordonnancer en respectant les créneaux RDV.

**Cluster Sud-Est** : H (Châteauroux), F (La Châtre), I (Argenton-sur-Creuse)
**Cluster Nord** : A (Issoudun), G (Issoudun), B (Vatan), C (Vierzon)
**Cluster Est** : D (Bourges), E (Saint-Florent-sur-Cher)

**Tournée proposée** (départ dépôt Châteauroux 6 h 00) :

| Étape | Action | km parcourus | Heure arrivée | Durée arrêt | Heure départ |
|-------|--------|--------------|---------------|-------------|--------------|
| 1 | Dépôt → A (Issoudun, créneau 7-9h) | 38 | 6h45 | 15 min (quai) | 7h00 |
| 2 | A → G (Issoudun, créneau 9-12h, en avance OK) | 5 | 7h05 | 20 min (hayon) | 7h25 |
| 3 | G → B (Vatan, créneau 7-9h) | 22 | 8h00 | 20 min (hayon) | 8h20 |
| 4 | B → C (Vierzon, créneau 8-10h) | 30 | 9h00 | 15 min (quai) | 9h15 |
| 5 | C → D (Bourges, créneau 8-11h) | 35 | 9h55 | 20 min (hayon) | 10h15 |
| 6 | D → E (Saint-Florent, créneau 8-11h) | 18 | 10h35 | 20 min (hayon) | 10h55 |
| 7 | E → H (Châteauroux centre, créneau 9-13h) | 60 | 12h05 | 15 min (quai) | 12h20 |
| 8 | H → F (La Châtre, créneau 9-12h... voir Q2.3) | 35 | 13h00 | 15 min (quai) | 13h15 |
| 9 | F → I (Argenton, créneau 10-13h) | 25 | 13h55 | 20 min (hayon) | 14h15 |
| 10 | I → Dépôt | 28 | 14h50 | — | — |

**Total kilomètres** : 38 + 5 + 22 + 30 + 35 + 18 + 60 + 35 + 25 + 28 = **296 km**

**Total temps de service** : 6 h 00 → 14 h 50 = 8 h 50 (sous la limite de 9 h)

Note : F est en limite de créneau (créneau 9-12h, livraison à 13h). À discuter avec le client OU réorganiser. Voir question 2.3 (l'aléa résout justement ce point).

## Question 2.2 — Vérification de la conformité R561 (5 points)

**Calcul du temps de conduite cumulé** :

Conduite cumulée jusqu'au point E (Saint-Florent) : 38 + 5 + 22 + 30 + 35 + 18 ≈ 148 km / 50 km/h ≈ **2 h 50 de conduite cumulée**.

Pas encore de pause R561 nécessaire à ce stade (limite 4 h 30).

Conduite cumulée jusqu'au retour : 296 km / 50 km/h ≈ **5 h 55 de conduite totale**.

**Limite R561 : pause obligatoire de 45 min après 4 h 30 de conduite cumulée.**

Avec la tournée actuelle, on dépasse 4 h 30 de conduite cumulée vers le point H (Châteauroux centre, après 5 + 22 + 30 + 35 + 18 + 60 = 170 km depuis A, soit ~3 h 25 + 45 min trajet initial = 4 h 10 de conduite). Limite atteinte juste avant le point H.

**Solution** : intégrer une **pause de 45 min** au point H (Châteauroux centre, 12h05-12h50), qui est déjà un créneau de livraison long (créneau 9-13h) et où le conducteur peut déjeuner tranquillement.

**Tournée révisée avec pause** :
- Départ : 6h00, retour 14h50
- Pause R561 : 12h05-12h50 (45 min sur Châteauroux, accolée à la livraison H)
- **Total temps de service** : 8 h 50 (6h00-14h50) — OK sous 9 h
- **Total conduite** : ~ 5 h 55 — OK sous 9 h
- **Pause R561** : OK (intégrée logiquement à la livraison H)

## Question 2.3 — Aléa imprévu (5 points)

**Trois options possibles** :

**Option A** : Maintenir le passage à La Châtre ce matin si possible
- Vérifier avec le client F si quelqu'un peut être présent malgré le dégât des eaux
- Si oui : maintenir la livraison comme prévue
- Évaluation : peu probable étant donné la situation

**Option B** : Reporter F à l'après-midi (proposition du client)
- Modifier la tournée : passer F en fin de tournée
- Conséquence sur le planning : décalage de la fin de tournée d'environ 1 heure
- Risque : dépassement éventuel des 9 h de service du conducteur

**Option C** : Re-planifier F sur une autre tournée demain ou en fin de semaine
- Annuler la livraison du jour
- Re-programmer dans la prochaine tournée du secteur
- Avantage : pas de perturbation du planning du jour
- Inconvénient : retard de livraison de 24-48 h pour le client

**Décision recommandée : Option C** (report sur prochaine tournée)

**Justifications** :
1. **Conformité R561** : la tournée actuelle est déjà à la limite des 9 h de service. Un retour décalé d'1 heure ferait dépasser les 9 h, créant une infraction.
2. **Optimisation économique** : revenir à La Châtre cet après-midi représenterait 70 km supplémentaires de retour à vide (Châteauroux → La Châtre → Châteauroux).
3. **Respect du conducteur** : Karim termine déjà à 14h50 ; lui imposer un retour spécifique l'après-midi alourdit sa journée.
4. **Engagement client** : proposer une re-livraison demain matin (mercredi 7-9h) avec une priorité absolue est acceptable commercialement.

**Communication client** :
- Appel immédiat à M. LAFOND pour confirmer la décision
- Programmation d'une livraison prioritaire mercredi matin
- Excuses pour le report et engagement sur la nouvelle date
- Documentation de l'incident dans le dossier client

**Conséquences sur la tournée du mardi** :
- Étape 8 supprimée (F)
- Tournée raccourcie : 296 - 35 - 25 = 236 km
- Retour anticipé au dépôt vers 13h55
- Possibilité d'utiliser le conducteur pour une autre mission l'après-midi
$msp_d2_corr$);

  -- =================================================================
  -- DOSSIER 3 — Étude de coût et cotation
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, source_ref, type, statement, choices, max_score, difficulty, tags, active, explanation) VALUES
  (v_formation, 'mft-2026-gotrm:msp:dossier:3', 'qr',
$msp_d3$
# DOSSIER 3 — Étude de coût et cotation (≈ 60 min)

## Contexte

Mercredi 14 h. Vous étudiez la rentabilité d'une **nouvelle relation commerciale** avec **PROFILÉS ALU DU BERRY** (PAB), qui souhaite vous confier une **ligne régulière** :

- **Trajet** : Châteauroux → Lille → Châteauroux
- **Volume** : 2 allers-retours par semaine sur 50 semaines/an
- **Marchandise** : profilés aluminium, 22 t en moyenne par voyage aller (retour à vide convenu)
- **Véhicule type** : tracteur 44 t + semi-remorque rideaux coulissants

## Données techniques de votre flotte

**Distance Châteauroux ↔ Lille** : 530 km par autoroute par trajet simple.

**Coûts de référence — tracteur 44 t longue distance** (saisis dans votre comptabilité analytique 2026) :

| Poste de coût | Valeur annuelle | Notes |
|---|---|---|
| Acquisition tracteur | 130 000 € HT | Valeur résiduelle 30 % à 7 ans |
| Acquisition semi-remorque | 35 000 € HT | Valeur résiduelle 25 % à 8 ans |
| Carburant | Conso 31 L/100 km | Prix gazole 1,42 €/L HT |
| Conducteur | 52 000 €/an | Coût employeur, 1 900 h travaillées/an |
| Entretien et pneus | 13 500 €/an | Tracteur + semi |
| Péages | 0,18 €/km | Autoroute |
| Assurances et taxes | 5 800 €/an | RC + tous risques + taxe à l'essieu |
| Frais de structure | 14 200 €/an | Imputés par véhicule |
| Lubrifiants et AdBlue | 2 800 €/an | — |

**Hypothèse** : ce tracteur fait 130 000 km totaux par an au total.

## Travail à faire

**Question 3.1 — Calcul du coût de revient kilométrique (12 points)**

Calculez le **coût de revient kilométrique total** de ce tracteur 44 t, en détaillant le calcul poste par poste.

Présentez vos résultats dans un **tableau récapitulatif** avec :
- Le coût annuel par poste
- Le coût kilométrique par poste (€/km)
- Le pourcentage de chaque poste dans le coût total

**Question 3.2 — Coût d'un voyage Châteauroux ↔ Lille A/R (5 points)**

Calculez le **coût de revient d'un voyage A/R** (1 060 km au total : 530 km chargés + 530 km à vide).

Quel est le **coût km commercial** (rapporté aux seuls km chargés) ?

**Question 3.3 — Cotation et marge (8 points)**

Le client PAB vous indique un **prix marché** indicatif pour ce trajet : **870 € HT par voyage A/R**.

a. Quelle marge nette dégagez-vous à ce prix ? Calcul détaillé.

b. Cette marge est-elle suffisante ? Justifiez.

c. Quel **prix HT minimum** négocieriez-vous pour atteindre une marge nette de 8 % ?

d. Quels sont les **3 leviers** pour améliorer la rentabilité de cette ligne ?

**Question 3.4 — Indexation gazole (clause RPC) (5 points)**

PAB souhaite signer un **contrat annuel** à 870 € HT le voyage A/R.

a. Cette clause d'indexation est-elle obligatoire ? Citez le texte légal applicable.

b. Rédigez la **clause d'indexation gazole** que vous insérez dans le contrat (formule, indice de référence, périodicité, part carburant retenue).

c. Si l'indice CNR augmente de **6 %** sur le mois de mai par rapport au mois de référence, quel est le **nouveau prix** du voyage A/R applicable en juin ? Calcul détaillé.
$msp_d3$,
NULL, 30, 'difficile',
ARRAY['msp', 'cout-revient', 'cotation', 'rpc', 'cas-pratique'],
true,
$msp_d3_corr$
# Correction Dossier 3

## Question 3.1 — Calcul du coût de revient kilométrique (12 points)

**Calculs détaillés poste par poste** :

**1. Amortissement tracteur**
- Base amortissable : 130 000 − (130 000 × 30 %) = 130 000 − 39 000 = 91 000 €
- Amortissement annuel : 91 000 / 7 = 13 000 €/an
- Coût km : 13 000 / 130 000 = **0,100 €/km**

**2. Amortissement semi-remorque**
- Base amortissable : 35 000 − (35 000 × 25 %) = 35 000 − 8 750 = 26 250 €
- Amortissement annuel : 26 250 / 8 = 3 281 €/an (arrondi à 3 281 €)
- Coût km : 3 281 / 130 000 = **0,025 €/km**

**3. Carburant**
- Consommation annuelle : 31 × 130 000 / 100 = 40 300 L/an
- Coût annuel : 40 300 × 1,42 = 57 226 €/an
- Coût km : 57 226 / 130 000 = **0,440 €/km**

**4. Conducteur**
- Coût annuel : 52 000 €
- Coût km : 52 000 / 130 000 = **0,400 €/km**

**5. Entretien et pneus**
- Coût annuel : 13 500 €
- Coût km : 13 500 / 130 000 = **0,104 €/km**

**6. Péages**
- Coût km : **0,180 €/km** (donné directement)
- Coût annuel : 0,180 × 130 000 = 23 400 €/an

**7. Assurances et taxes**
- Coût annuel : 5 800 €
- Coût km : 5 800 / 130 000 = **0,045 €/km**

**8. Frais de structure**
- Coût annuel : 14 200 €
- Coût km : 14 200 / 130 000 = **0,109 €/km**

**9. Lubrifiants et AdBlue**
- Coût annuel : 2 800 €
- Coût km : 2 800 / 130 000 = **0,022 €/km**

**Tableau récapitulatif** :

| Poste | Annuel (€) | €/km | % du total |
|---|---|---|---|
| Amortissement tracteur | 13 000 | 0,100 | 7 % |
| Amortissement semi | 3 281 | 0,025 | 2 % |
| Carburant | 57 226 | 0,440 | 31 % |
| Conducteur | 52 000 | 0,400 | 28 % |
| Entretien et pneus | 13 500 | 0,104 | 7 % |
| Péages | 23 400 | 0,180 | 13 % |
| Assurances et taxes | 5 800 | 0,045 | 3 % |
| Structure | 14 200 | 0,109 | 8 % |
| Lubrifiants et AdBlue | 2 800 | 0,022 | 2 % |
| **TOTAL** | **185 207** | **1,425** | **100 %** |

**Coût de revient kilométrique total : ~ 1,42 €/km**

Observations :
- Carburant + conducteur représentent 59 % du coût total — top 2 postes à surveiller.
- Péages élevés (13 %) car ligne autoroute longue distance.
- Structure 8 % — niveau correct pour une PME.

## Question 3.2 — Coût d'un voyage Châteauroux ↔ Lille A/R (5 points)

**Distance totale A/R** : 530 + 530 = **1 060 km**
**Distance chargée** : 530 km (un seul trajet aller chargé)
**Retour à vide** : 530 km

**Coût total du voyage** : 1 060 × 1,425 = **1 510,50 €**

**Coût km commercial** (rapporté aux km chargés) : 1 510,50 / 530 = **2,85 €/km commercial**

**Observation importante** : le retour à vide à 100 % double mécaniquement le coût km commercial par rapport au coût km total.

## Question 3.3 — Cotation et marge (8 points)

### a. Marge nette à 870 € HT (2 pts)

- CA par voyage : 870 €
- Coût de revient : 1 510,50 €
- **Résultat : -640,50 € de PERTE par voyage**
- Marge nette : -640,50 / 870 = **-73,6 %** (déficitaire)

**À 870 € HT, la mission est très largement déficitaire. Refus immédiat à ce prix.**

### b. Cette marge est-elle suffisante ? (1 pt)

**Non, totalement insuffisante. La marge est négative.** Accepter ce contrat reviendrait à perdre 640 €/voyage soit ~ 64 000 €/an (2 voyages × 50 semaines).

### c. Prix minimum pour 8 % de marge nette (3 pts)

Formule : **Prix = Coût / (1 − Marge nette)**

Prix minimum = 1 510,50 / (1 − 0,08) = 1 510,50 / 0,92 = **1 642 € HT par voyage A/R**

Soit un prix proche du double de l'offre du client. Cela montre que le « prix marché » annoncé par PAB n'est pas crédible OU repose sur une hypothèse de retour chargé non communiquée.

### d. Trois leviers pour améliorer la rentabilité (2 pts)

**Levier 1 — Trouver un fret retour** : passer de 100 % à 30 % de retour à vide diviserait le coût km commercial par ~ 1,4. Action : démarchage chargeurs Lille-Châteauroux (industrie, agroalimentaire), bourses de fret (Teleroute, B2Pweb).

**Levier 2 — Engagement de volume avec contrepartie tarifaire** : si PAB peut s'engager sur 2 ans avec un volume garanti, négocier une revoyure annuelle des tarifs et obtenir une visibilité financière permettant d'optimiser la planification.

**Levier 3 — Optimisation interne** : éco-conduite (-5 à -10 % carburant = -25 à -50 €/voyage), maintenance préventive (réduction pannes), formation conducteur dédié à la ligne (gain de productivité 5-8 %).

## Question 3.4 — Indexation gazole (clause RPC) (5 points)

### a. Obligation légale (1 pt)

**Oui, la clause d'indexation gazole est OBLIGATOIRE.**

Texte applicable : **article L. 3222-1 du Code des transports**, qui rend la répercussion du prix du carburant **d'ordre public**. Aucune clause contractuelle ne peut y renoncer. À défaut de clause expresse, l'indexation s'applique automatiquement (alinéa 2 du même article).

### b. Rédaction de la clause RPC (3 pts)

```
Article X — Indexation du prix sur la variation du prix du carburant

Conformément à l'article L. 3222-1 du Code des transports,
le prix mentionné au présent contrat est indexé chaque mois
sur la variation de l'indice gazole national publié par le
Comité National Routier (CNR), base mensuelle.

La part carburant retenue est fixée à 35 % du prix de transport,
correspondant au profil d'exploitation longue distance pour ce
type de véhicule.

Formule d'indexation appliquée mensuellement :

Prix indexé = Prix de référence × [1 + (Variation indice CNR × 35 %)]

L'indice de référence est celui du mois de [mois de signature
du contrat]. La répercussion s'applique de plein droit sur
toutes les factures émises au cours du mois suivant la
publication de l'indice.
```

### c. Calcul du nouveau prix (1 pt)

- Variation indice : +6 %
- Part carburant : 35 %
- Coefficient : 1 + (6 % × 35 %) = 1 + 0,021 = 1,021

**Nouveau prix : 870 × 1,021 = 888,27 € HT** (arrondi à **888 € HT**)

Soit une hausse de 18 € par voyage suite à la hausse du gazole de 6 %.

Note : dans ce cas pratique, le prix de référence à 870 € est largement insuffisant. La clause RPC ne corrige que la part carburant — pas le déséquilibre structurel du tarif. La négociation initiale doit donc se faire sur un prix juste (1 642 € HT minimum) avant d'appliquer la clause RPC.
$msp_d3_corr$);

  -- =================================================================
  -- DOSSIER 4 — Gestion d'un litige et qualité de service
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, source_ref, type, statement, choices, max_score, difficulty, tags, active, explanation) VALUES
  (v_formation, 'mft-2026-gotrm:msp:dossier:4', 'qr',
$msp_d4$
# DOSSIER 4 — Gestion d'un litige et qualité de service (≈ 40 min)

## Contexte

Jeudi 10 h 30. Vous recevez le courrier suivant en LRAR de la part d'un client habituel, **MEUBLES TRADITION (Bourges)** :

> Madame, Monsieur,
>
> Suite à la livraison effectuée le 14 mai dernier par votre transporteur,
> nous vous écrivons pour vous notifier les avaries constatées sur la
> marchandise, soit 2 armoires (réf. ARM-2200 et ARM-2400) endommagées
> au niveau des panneaux latéraux.
>
> Le préjudice s'élève à 3 800 € HT (valeur des armoires en rayon).
>
> Notre conducteur a signé la lettre de voiture sans réserve à l'arrivée
> car les emballages extérieurs ne présentaient aucun dommage apparent.
> Les avaries n'ont été constatées qu'après déballage en atelier
> le 16 mai (soit 2 jours ouvrés après la livraison).
>
> Nous vous demandons l'indemnisation intégrale des 3 800 € HT.
>
> Cordialement,
> R. CHAUMETTE — Direction des achats
> MEUBLES TRADITION

**Éléments du dossier que vous récupérez auprès de l'exploitation** :
- Lettre de voiture nationale (LVN) signée à l'arrivée le 14 mai par le destinataire SANS RÉSERVE
- Photo du chargement chez l'expéditeur (palettes correctement filmées et arrimées)
- Pas de photo à l'arrivée
- Tracking GPS : pas d'incident notable, vitesse moyenne respectée
- Données tachygraphe conformes
- Marchandise : 4 armoires sur palette, poids total 380 kg, transport régional Charleville-Mézières → Bourges

## Travail à faire

**Question 4.1 — Analyse juridique (8 points)**

a. Quelle est la **position juridique** du transporteur ? Citez les textes applicables (Code de commerce, contrat-type général).

b. Le destinataire a signé sans réserve, mais a constaté l'avarie le 16 mai (2 jours ouvrés après la livraison du 14). **A-t-il respecté les délais légaux** pour formuler des réserves non apparentes ? Argumentez.

c. À supposer que la responsabilité du transporteur soit retenue, quel est le **plafond légal d'indemnisation** ? Calculez précisément.

**Question 4.2 — Réponse formelle au client (7 points)**

Rédigez la **réponse formelle** à adresser à MEUBLES TRADITION en LRAR. La réponse doit :

- Accuser réception courtoise
- Présenter les faits objectivement
- Exposer la position juridique de votre entreprise
- Proposer une solution constructive (transaction)
- Signer professionnellement

**Question 4.3 — Plan d'action préventif (5 points)**

Au-delà du traitement du litige, **3 actions préventives** à mettre en place pour éviter la répétition de ce type de situation.

Pour chaque action, précisez :
- L'objectif visé
- Le délai de mise en œuvre
- Le coût estimé
- L'indicateur de succès

**Question 4.4 — Pilotage qualité (5 points)**

Mme Vincendeau souhaite que vous mettiez en place un **tableau de bord qualité mensuel** pour suivre les litiges et la satisfaction client.

Listez les **5 KPI** essentiels à intégrer, avec :
- Leur formule de calcul
- Leur cible (valeur attendue)
- Leur source de données
- Leur fréquence de mesure
$msp_d4$,
NULL, 25, 'difficile',
ARRAY['msp', 'litige', 'qualite', 'kpi', 'cas-pratique'],
true,
$msp_d4_corr$
# Correction Dossier 4

## Question 4.1 — Analyse juridique (8 points)

### a. Position juridique du transporteur (3 pts)

**Cadre légal applicable** :
- **Article L. 133-1 du Code de commerce** : le transporteur est garant de la perte et des avaries, sauf cas de force majeure ou vice propre. **Présomption de responsabilité** : c'est au transporteur de prouver une cause d'exonération, pas au destinataire de prouver une faute.
- **Décret 99-269 du 6 avril 1999 modifié** (contrat-type général) : applicable en transport routier national à défaut de convention écrite particulière.
- **Article L. 133-3 du Code de commerce** : encadre les délais de réserves.

Le transporteur est donc **présumé responsable** dès la prise en charge et jusqu'à la livraison effective, sauf à prouver une cause d'exonération.

### b. Respect des délais de réserves (3 pts)

**Le destinataire a signé sans réserve à l'arrivée.** En transport national, l'article L. 133-3 du Code de commerce et le contrat-type général imposent :

- **Réserves apparentes** : à formuler **immédiatement** sur le bordereau de livraison ou la LVN, à la livraison.
- **Réserves non apparentes** : à formuler dans un délai de **3 jours ouvrés** à compter de la livraison.

**Calcul du délai dans ce cas** :
- Livraison : 14 mai (mardi)
- Constatation des avaries : 16 mai (jeudi) — soit J+2 ouvrés
- Le délai de **3 jours ouvrés** est respecté

**Toutefois**, plusieurs faiblesses dans la position du destinataire :
- La signature sans réserve à l'arrivée crée une présomption de conformité difficile à renverser.
- Les emballages n'ayant pas été endommagés (selon les dires du client), il est difficile pour lui de prouver que l'avarie est intervenue **pendant le transport** plutôt qu'au déballage en atelier.
- Charge de la preuve : c'est désormais au destinataire de **prouver** que l'avarie a eu lieu pendant le transport, ce qui est très difficile sans réserves au déchargement et sans photo à l'arrivée.

### c. Plafond légal d'indemnisation (2 pts)

Application du **contrat-type général** (décret 99-269) :

**Plafond = le moindre des deux :**
- 33 €/kg : 380 kg × 33 € = **12 540 €**
- 1 000 €/colis : 4 armoires × 1 000 € = **4 000 €**

**Plafond retenu : 4 000 €** (le moindre des deux)

Mais **seules 2 armoires** sont endommagées :
- Plafond pour 2 armoires endommagées : 2 × 1 000 € = **2 000 €**
- OU plafond proportionnel poids : 190 kg × 33 € = 6 270 €
- Le moindre : **2 000 €**

**Le plafond légal applicable serait donc de 2 000 €**, soit moins que les 3 800 € réclamés par le client.

## Question 4.2 — Réponse formelle au client (7 points)

```
TRANSPORTS LOGIDOC
Z.I. Le Poinçonnet
36330 Le Poinçonnet
Tél : 02 54 XX XX XX
contact@transports-logidoc.fr

                                              Châteauroux, le 18 mai 2026
                                              Lettre recommandée
                                              avec accusé de réception

MEUBLES TRADITION
À l'attention de M. R. CHAUMETTE
Direction des achats
[Adresse Bourges]

Objet : Réclamation concernant la livraison du 14 mai 2026
       — Référence dossier TLD-2026-XXXX

Madame, Monsieur,

Nous accusons réception de votre courrier en date du XX mai 2026
relatif à la livraison effectuée par nos services le 14 mai
dernier, par lequel vous nous signalez des avaries constatées
sur deux armoires de votre commande.

Nous vous remercions de nous avoir saisis de cette difficulté.
Après analyse complète du dossier, nous souhaitons partager avec
vous les éléments suivants, dans un esprit constructif.

1. Faits constatés

Le bordereau de livraison a été signé sans réserve par votre
représentant à la livraison du 14 mai. Les emballages des
quatre armoires ne présentaient à cette occasion aucun signe
extérieur de détérioration.

Le chargement chez l'expéditeur avait été photographié et
contrôlé : palettes filmées et arrimées conformément aux
règles de l'art. Le suivi GPS et les données tachygraphes du
trajet confirment l'absence de tout incident en route.

Les avaries n'ont été constatées qu'après déballage en atelier,
le 16 mai, soit deux jours ouvrés après la livraison.

2. Position juridique

Le contrat-type général (décret 99-269 modifié) prévoit, à
l'article L. 133-3 du Code de commerce, un délai de trois jours
ouvrés pour formuler des réserves non apparentes après livraison.
Vous avez respecté ce délai, ce que nous notons.

En revanche, la signature sans réserve à l'arrivée et l'absence
de dommage apparent sur les emballages rendent juridiquement
difficile l'établissement d'un lien de causalité entre le
transport et les avaries constatées au déballage.

Par ailleurs, et conformément au même contrat-type, le plafond
légal d'indemnisation pour deux colis endommagés s'établit à
2 000 € (le moindre des deux entre 33 €/kg et 1 000 €/colis).

3. Proposition

Sans reconnaissance de responsabilité dépassant le cadre légal,
et afin de maintenir notre relation commerciale dans les
meilleures conditions, nous vous proposons :

- Une indemnité forfaitaire de 2 200 €, soit le plafond légal
  majoré d'un geste commercial de 10 %.
- Un engagement de notre part à mettre en place dès ce mois-ci
  un protocole renforcé de photographies systématiques à
  l'arrivée pour les marchandises sensibles, et à vous en
  communiquer les premiers résultats sous 30 jours.

Cette proposition est exclusive de toute autre réclamation
ultérieure sur ce dossier et est valable 30 jours à compter
de la présente.

Nous restons naturellement à votre entière disposition pour en
échanger lors d'un rendez-vous, à votre convenance.

Veuillez agréer, Madame, Monsieur, l'expression de nos
salutations distinguées.

[Prénom NOM]
Gestionnaire d'exploitation
TRANSPORTS LOGIDOC
```

Points de notation :
- Structure formelle (en-tête, objet, formule d'appel, formule finale) : 1 pt
- Présentation factuelle objective : 1,5 pt
- Argumentation juridique solide : 1,5 pt
- Proposition constructive (transaction + geste) : 1,5 pt
- Engagement préventif et porte ouverte au dialogue : 1 pt
- Signature professionnelle complète : 0,5 pt

## Question 4.3 — Plan d'action préventif (5 points)

**Action 1 — Photographie systématique au chargement ET à l'arrivée**
- Objectif : tracer l'état réel de la marchandise aux deux extrémités du transport pour neutraliser les contestations de type « avarie au déballage ».
- Délai de mise en œuvre : sous 30 jours
- Coût estimé : 2 500 € (équipement smartphones rugged + procédure documentée + formation conducteurs)
- Indicateur de succès : 100 % des missions sensibles avec double photo (chargement et déchargement) dans les 90 jours

**Action 2 — Briefing conducteurs sur l'importance des réserves de réception**
- Objectif : que les conducteurs sensibilisent activement les destinataires à la nécessité de vérifier la marchandise et de formuler les réserves apparentes au déchargement.
- Délai de mise en œuvre : sous 15 jours
- Coût estimé : 1 800 € (deux sessions de formation × 1 demi-journée + supports)
- Indicateur de succès : taux de réserves formulées au déchargement (à monitorer mensuellement) ; cible : multiplier par 2 le taux de réserves dans les 6 mois.

**Action 3 — Mise à jour des CGV/CGT**
- Objectif : intégrer dans les Conditions Générales de Transport remises à chaque client la mention claire des délais de réserves, plafonds d'indemnisation et procédures à suivre.
- Délai de mise en œuvre : sous 90 jours (audit juridique préalable nécessaire)
- Coût estimé : 4 500 € (cabinet juridique pour mise à jour CGT + intégration dans le devis numérique)
- Indicateur de succès : 100 % des nouveaux contrats avec CGT mises à jour signées par le client dans les 6 mois.

## Question 4.4 — Pilotage qualité (5 points)

**Tableau de bord qualité mensuel — 5 KPI essentiels**

| KPI | Formule | Cible | Source | Fréquence |
|---|---|---|---|---|
| **Taux de litiges** | (Nb litiges du mois / Nb missions facturées) × 100 | < 1 % | CRM tickets + ERP missions | Mensuelle |
| **Taux d'avaries** | (Nb missions avec avarie déclarée / Nb total missions) × 100 | < 0,3 % | Registre incidents | Mensuelle |
| **Coût de la non-qualité** | Indemnités versées + frais procédure + temps interne valorisé | < 0,8 % du CA mensuel | Comptabilité + RH | Mensuelle |
| **Délai moyen de réponse aux réclamations** | Moyenne (heure de réponse formelle − heure de réception) en heures ouvrées | < 24 h ouvrées | CRM tickets | Mensuelle |
| **NPS client (Net Promoter Score)** | % promoteurs (notes 9-10) − % détracteurs (notes 0-6) | > 25 (cible secteur) | Enquête trimestrielle Typeform | Trimestrielle |

**Présentation visuelle recommandée** :
- Tableau de bord 1 page diffusé le 5e jour ouvré du mois suivant
- Code couleur 🟩 (cible atteinte) / 🟧 (vigilance) / 🟥 (critique)
- Évolution graphique sur 12 mois glissants pour chaque KPI
- Diffusion : direction d'exploitation, direction commerciale, direction générale
- Revue mensuelle en comité direction (60 min) avec actions correctives sur les KPI rouges
$msp_d4_corr$);

  -- =================================================================
  -- QUIZ MSP : 4 dossiers en 1 examen 3 h
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Examen MSP final — 4 dossiers d''exploitation (3 h)',
    'Format identique à l''épreuve réelle du titre professionnel. 4 dossiers d''exploitation enchaînés (demande, planification, étude de coût, litige). 3 heures chronométrées, seuil 50 %.',
    'examen', 10800, 50
  ) RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, qb.id, ROW_NUMBER() OVER (ORDER BY qb.source_ref)
  FROM public.question_bank qb
  WHERE qb.formation_id = v_formation
    AND qb.source_ref IN (
      'mft-2026-gotrm:msp:dossier:1',
      'mft-2026-gotrm:msp:dossier:2',
      'mft-2026-gotrm:msp:dossier:3',
      'mft-2026-gotrm:msp:dossier:4'
    );

  RAISE NOTICE '✅ GOTRM MSP final chargé : 4 dossiers d''exploitation, 3 h, seuil 50 %%.';
END
$msp$;
