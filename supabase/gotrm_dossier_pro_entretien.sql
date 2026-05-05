-- =====================================================================
-- GOTRM (RNCP 40990) — DOSSIER PROFESSIONNEL & BANQUE ENTRETIEN JURY
-- - Template structuré du dossier professionnel (~ 25 pages cible)
-- - Banque de 30 questions d'entretien technique reformulées
-- =====================================================================

DO $dossier_entretien$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid; v_quiz uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid; v_lesson_5 uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-dossier-pro-entretien';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Dossier professionnel & entretien jury',
    'gotrm-dossier-pro-entretien', v_bloc,
    'Préparation à la soutenance jury : template structuré du dossier professionnel (25 pages), conseils pour la présentation orale, et banque de 30 questions d''entretien technique reformulées de jurys passés.',
    'avance', 240, 240
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 240, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:entretien:%';

  -- =================================================================
  -- LEÇON 1 — Structure générale du dossier professionnel
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Structure générale du dossier professionnel (25 pages)',
    'gotrm-dossier-pro-01-structure', 1, 50,
$dl1$
# Structure générale du dossier professionnel

Le dossier professionnel (DP) est l'**un des 3 livrables** de l'examen GOTRM (avec la mise en situation écrite et l'entretien). Il **précède la soutenance** orale et sert de support à l'entretien avec le jury.

> 🎯 **Objectif du DP**
>
> Démontrer au jury que vous avez **acquis et exercé** les compétences du titre professionnel à travers des **situations professionnelles réelles** vécues en entreprise (en stage, alternance ou activité salariée).

---

## 1. Format imposé

| Élément | Norme |
|---|---|
| Volume | **25 pages maximum** (hors annexes) |
| Format | A4, recto, marges 2,5 cm |
| Police | Times 12 ou Arial 11, interligne 1,5 |
| Pagination | Bas de page, à droite |
| Reliure | Spirale ou couverture cartonnée souple |
| Nombre d'exemplaires | 3 (1 jury, 1 centre, 1 candidat) |

---

## 2. Structure obligatoire (ordre des chapitres)

| Page(s) | Section | Volume cible |
|---|---|---|
| 1 | Page de garde | — |
| 2 | Sommaire détaillé | 1 page |
| 3-4 | Préambule / introduction | 2 pages |
| 5-7 | Présentation de l'entreprise d'accueil | 3 pages |
| 8-10 | Présentation du service exploitation | 3 pages |
| 11-13 | **Activité 1 — BC01 : Concevoir et organiser** | 3 pages |
| 14-16 | **Activité 2 — BC01 : Piloter une opération** | 3 pages |
| 17-19 | **Activité 3 — BC02 : Sous-traitance** | 3 pages |
| 20-22 | **Activité 4 — BC03 : Optimiser les moyens** | 3 pages |
| 23 | Conclusion et perspectives | 1 page |
| 24-25 | Annexes (sélectionnées, max 5) | 2 pages |

---

## 3. Page de garde — modèle

```
[LOGO du centre de formation]                  [Photo candidat optionnel]

   DOSSIER PROFESSIONNEL

Titre Professionnel : Gestionnaire des Opérations
de Transport Routier de Marchandises (GOTRM)
Niveau 5 — RNCP 40990

Session : [mois année]

Présenté par :  [Prénom NOM]
                Né(e) le [date] à [ville]
                Demeurant : [adresse complète]
                Tél : [numéro]
                Mail : [adresse mail]

Lieu de stage / activité : [nom de l'entreprise]
Adresse de l'entreprise : [adresse complète]
Tuteur en entreprise : [nom + fonction]

Centre de formation : [nom + adresse]
Formateur référent : [nom]

Date de soutenance : [JJ/MM/AAAA]
```

---

## 4. Sommaire — modèle détaillé

```
SOMMAIRE

PRÉAMBULE ........................................................ 3

1. PRÉSENTATION DE L'ENTREPRISE D'ACCUEIL ........................ 5
   1.1 Activité, secteur et chiffres clés ........................ 5
   1.2 Organisation et organigramme .............................. 6
   1.3 Parc, conducteurs et clientèle ............................ 7

2. PRÉSENTATION DU SERVICE EXPLOITATION ......................... 8
   2.1 Composition et missions ................................... 8
   2.2 Outils et environnement de travail ........................ 9
   2.3 Mes missions et mon périmètre ............................. 10

3. ACTIVITÉ 1 — TRAITER UNE DEMANDE ET CONCEVOIR
   UNE OPÉRATION DE TRANSPORT (BC01) ............................. 11
   3.1 Contexte et besoin client ................................. 11
   3.2 Démarche mise en œuvre .................................... 12
   3.3 Résultats et enseignements ................................ 13

4. ACTIVITÉ 2 — PILOTER UNE OPÉRATION DE TRANSPORT
   ET GÉRER UN ALÉA (BC01) ...................................... 14
   4.1 Contexte ................................................. 14
   4.2 Démarche ................................................. 15
   4.3 Résultats et bilan ....................................... 16

5. ACTIVITÉ 3 — PILOTER UN TRAFIC SOUS-TRAITÉ (BC02) ........... 17
   5.1 Contexte et enjeux ....................................... 17
   5.2 Démarche ................................................. 18
   5.3 Résultats et bilan ....................................... 19

6. ACTIVITÉ 4 — OPTIMISER LES MOYENS (BC03) .................... 20
   6.1 Contexte ................................................. 20
   6.2 Démarche ................................................. 21
   6.3 Résultats et bilan ....................................... 22

CONCLUSION ET PERSPECTIVES ...................................... 23

ANNEXES ......................................................... 24
   Annexe 1 : ...
   Annexe 2 : ...
   ...
```

---

## 5. Préambule (2 pages) — points à couvrir

**Objectifs** :
- Se présenter (parcours, motivation pour le métier)
- Expliquer le choix de la formation GOTRM
- Présenter la démarche du dossier
- Annoncer les 4 activités professionnelles décrites

**Plan suggéré** :

```
1. Présentation personnelle (15 lignes)
   - Parcours antérieur (formation, expériences)
   - Motivation pour le transport et la logistique

2. Choix de la formation (15 lignes)
   - Pourquoi le titre GOTRM
   - Adéquation avec le projet professionnel
   - Modalités suivies (formation continue, alternance, etc.)

3. Présentation de l'entreprise et du stage (10 lignes)
   - Contexte d'accueil
   - Période concernée
   - Tuteur et environnement

4. Démarche du dossier (15 lignes)
   - 4 activités sélectionnées (1 par compétence majeure)
   - Méthode d'analyse (contexte / démarche / résultats)
   - Posture réflexive sur les acquis
```

---

## 6. Présentation de l'entreprise (3 pages) — éléments à couvrir

### Activité et secteur (1 page)

- Forme juridique (SARL, SAS, SA, EURL...)
- SIREN, code NAF (4941A pour TRM, 4941B pour déménagement, 5229B pour commission)
- Date de création, dirigeants
- Chiffre d'affaires (HT, exercice clos)
- Effectif (administratif + conducteurs)
- Marchés desservis (national, UE, international)
- Spécialités (FTL, LTL, distribution, ATP, ADR, exceptionnel...)

### Organisation et organigramme (1 page)

Inclure un organigramme schématique :

```
                Directeur Général
                       |
       ___________________________________________
      |                |                |          |
   Direction       Direction       Direction    Direction
   Exploitation   Commerciale    Administrative Maintenance
        |                                  |       |
   ---------                                       |
  |    |    |                                      |
  Exp1 Exp2 Exp3                                   |
                                              Atelier
                                         (mécaniciens)
                Conducteurs (52)
```

### Parc, conducteurs et clientèle (1 page)

- Composition du parc (par type, âge moyen, vignettes Crit'Air)
- Effectif conducteurs (ancienneté moyenne, qualifications spécifiques ADR/ATP)
- Top 5 ou 10 clients (% du CA)
- Engagements RSE éventuels (Objectif CO2, ISO, etc.)

---

## 7. Présentation du service exploitation (3 pages)

### Composition et missions (1 page)

- Effectif du service (combien d'exploitants, dispatchers, etc.)
- Hiérarchie et reporting
- Périmètre géographique et fonctionnel
- Volume hebdomadaire de missions traitées

### Outils et environnement (1 page)

- TMS utilisé (nom du logiciel, fonctionnalités principales)
- Télématique embarquée (marque, fonctions)
- ERP / comptabilité
- Bourses de fret utilisées (Teleroute, Trans.eu, Timocom...)
- Outils de communication (téléphone, app conducteur)

### Mes missions et mon périmètre (1 page)

- Description précise de votre poste pendant la période d'observation
- Tâches quotidiennes confiées
- Niveau d'autonomie progressif
- Évolution sur la période (de l'observation à la prise en charge)
- Référent / tuteur quotidien

---

## 8. Conseils transverses

| Erreur fréquente | Comment l'éviter |
|---|---|
| Description trop générale de l'entreprise | Donner des **chiffres précis** (CA, effectif, km, %) |
| Activités trop vagues ou théoriques | Décrire des **situations vécues** datées et chiffrées |
| Pas de lien avec le référentiel | Citer les **compétences** du titre à chaque activité |
| Annexes trop nombreuses ou non pertinentes | Maximum **5 annexes** réellement éclairantes |
| Fautes d'orthographe / typo | **Faire relire** par 2 personnes avant impression |
| Fichier rendu en retard | Anticiper la **finalisation 3 semaines avant** la soutenance |

---

> ✅ **À retenir**
>
> - **25 pages** maximum, hors annexes (max 5).
> - Structure imposée : **page de garde, sommaire, préambule, entreprise, service, 4 activités, conclusion, annexes**.
> - 4 activités professionnelles **vécues** (pas théoriques) et **chiffrées**.
> - Anticiper la finalisation 3 semaines avant la soutenance.
$dl1$,
'Format DP : 25 pages, structure imposée (préambule, entreprise, service, 4 activités, conclusion, annexes max 5), modèles de page de garde et sommaire.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Comment rédiger une activité professionnelle
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Rédiger une activité professionnelle (méthode CDR)',
    'gotrm-dossier-pro-02-activite-cdr', 2, 50,
$dl2$
# Rédiger une activité professionnelle — méthode CDR (Contexte / Démarche / Résultats)

Chacune des 4 activités de votre DP doit suivre une **structure stricte** en 3 parties. Cette structure est ce que le jury attend et **note**.

> 🎯 **La règle d'or**
>
> Une activité = **3 pages maximum** = **1 page par section** (Contexte, Démarche, Résultats).

---

## 1. Section CONTEXTE (≈ 1 page)

### Objectif

Poser le **cadre précis** de la situation professionnelle qu'on a vécue.

### Plan recommandé

| Sous-section | Volume | Contenu |
|---|---|---|
| Cadre général | 5-10 lignes | Période, lieu, équipe, demande initiale |
| Acteurs concernés | 5-10 lignes | Client, sous-traitant, conducteur, hiérarchie |
| Enjeux | 10-15 lignes | Pourquoi cette activité était importante (chiffres) |
| Compétences mobilisées | 5-10 lignes | Lien avec le référentiel BC01/BC02/BC03 |

### Exemple — Activité 1 (BC01)

```
1.1 Cadre général

Période : du 12 mars au 24 mars 2026
Lieu : Service exploitation de TRANSPORTS LOGIDOC (Châteauroux, 36)
Demande initiale : un client industriel, MOULAGES PRÉCIS DU CENTRE
(MPC, Issoudun), sollicite une cotation urgente pour un transport
de 3 palettes vers la région parisienne, en J+1.

1.2 Acteurs concernés

- M. Anthony GAVOTTE, responsable expéditions chez MPC
  (donneur d'ordre)
- Service exploitation TLD : moi-même + 2 collègues exploitants
- Conducteur potentiel : Karim BOUKADJANI (porteur 12 t)
- Direction commerciale : Mme Patricia VINCENDEAU (validation
  tarifaire pour les nouveaux clients)

1.3 Enjeux

MPC est un nouveau client potentiel. Une démarche maîtrisée
permettait de :
- Sécuriser une première mission rentable (CA estimé 380 € HT)
- Vérifier la solidité du client avant engagement (encours 8 000 €)
- Démontrer notre capacité à répondre rapidement (délai 2 h)
- Ouvrir une relation durable (volume potentiel estimé : 3 missions
  par mois soit 14 k€ de CA annuel)

1.4 Compétences mobilisées

Cette activité mobilise les compétences clés du bloc BC01 :
- Traiter une demande de transport et qualifier le besoin
- Élaborer une cotation et une offre commerciale
- Vérifier les éléments de conformité contractuelle (CGT, RPC)
- Communiquer avec le client de façon professionnelle
```

---

## 2. Section DÉMARCHE (≈ 1 page)

### Objectif

Décrire **ce que vous avez fait**, étape par étape, en valorisant la **méthode et les outils**.

### Plan recommandé

| Sous-section | Volume |
|---|---|
| Étapes clés (numérotées) | Liste détaillée |
| Outils mobilisés | TMS, Excel, calcul CRT |
| Difficultés rencontrées | Concrètes |
| Choix tactiques | Argumentés |

### Exemple — Activité 1 (BC01) — démarche

```
2.1 Étapes de mon intervention

Étape 1 — Réception et qualification de la demande (J, 9h15)
   - Lecture du mail de M. Gavotte
   - Identification de 9 informations bloquantes manquantes
   - Décision : pas de cotation possible en l'état

Étape 2 — Mail de relance structuré (J, 9h30 — envoi 9h45)
   - Rédaction d'un mail courtois, numéroté, avec engagement
     de cotation sous 2 h après réponse
   - Validation par ma référente avant envoi

Étape 3 — Vérifications préalables (J, 9h30 — 10h15)
   - Consultation Infogreffe : MPC (SIREN 850 642 318), créée
     en 2012, chiffre 2024 = 4,2 M€, capitaux propres positifs,
     aucune procédure
   - Demande de plafond Coface : accordé 12 000 €

Étape 4 — Réception des éléments client (J, 11h45)
   - Adresse enlèvement : Issoudun, ZI sud
   - Adresse livraison : Coignières (78)
   - Poids total : 480 kg, palettes EUR gerbables
   - Quai disponibles aux 2 extrémités, sans hayon nécessaire

Étape 5 — Calcul de la cotation (J, 13h30 — 14h00)
   - Distance : 280 km commerciaux + 280 km retour à vide
   - Application du CRT : 580 € de coût direct
   - Marge nette cible : 10 %, prix proposé : 644 € HT
   - Intégration de la clause RPC standard (CNR mensuel,
     part carburant 30 %)

Étape 6 — Envoi du devis et conditions (J, 14h00)
   - Devis n° 2026-0317 envoyé à M. Gavotte
   - CGT jointes en annexe PDF (mentions plafonds 33 €/kg
     ou 1 000 €/colis, prescription 1 an, juridiction
     compétente Châteauroux)
   - Validité du devis : 14 jours

2.2 Outils mobilisés

- Outlook (mails entrants/sortants)
- Infogreffe (vérification)
- Coface portail (encours)
- TMS Optitrans (saisie commande prévisionnelle)
- Tableur Excel (calcul CRT manuel pour vérification)

2.3 Difficultés rencontrées

- M. Gavotte a tardé à répondre (réponse à 11h45 au lieu de
  l'objectif 11h00). J'ai dû le relancer par téléphone à 11h30.
- Le poids final (480 kg) était sensiblement inférieur à mon
  estimation initiale (3 palettes pourraient peser 700 kg).
  Cela a légèrement amélioré la marge.

2.4 Choix tactique

J'ai choisi d'appliquer un prix « équitable » plutôt qu'un prix
de pénétration agressif. La logique : ce client peut devenir
récurrent ; partir sur un prix trop bas créerait un précédent
difficile à remonter ensuite.
```

---

## 3. Section RÉSULTATS (≈ 1 page)

### Objectif

Démontrer l'**impact concret** de votre action, avec des **chiffres**.

### Plan recommandé

| Sous-section | Volume |
|---|---|
| Résultat factuel | Quantifié |
| Bénéfices pour l'entreprise | Court et long terme |
| Bénéfices pour le client | Satisfaction |
| Auto-évaluation | Réflexive |
| Pistes d'amélioration | Concrètes |

### Exemple — Activité 1 (BC01) — résultats

```
3.1 Résultat factuel

- Devis envoyé sous 4 h 45 (objectif respecté < 5 h)
- Devis accepté par MPC le lendemain à 10h30
- Mission exécutée le 13 mars sans incident
- Facturation honorée sous 18 jours (DSO record positif)
- CA réalisé : 644 € HT (marge brute 51 %, marge nette 10,5 %)

3.2 Bénéfices pour l'entreprise

Court terme :
- Nouveau client gagné avec une mission rentable
- Cas formateur pour mes collègues juniors

Long terme :
- MPC nous a confié 3 missions supplémentaires sur les 6
  semaines suivantes (CA cumulé : 2 100 € HT)
- Engagement informel pour 1 mission/mois minimum
- Référence ajoutée à notre portefeuille industriel

3.3 Bénéfices pour le client

- Réactivité supérieure aux attentes (devis sous 5 h)
- Documentation claire (CGT, conditions)
- Pas de surprise tarifaire (RPC bien expliquée)
- Communication structurée

3.4 Auto-évaluation

Points forts :
+ Méthode rigoureuse de qualification
+ Vérification client systématique
+ Tarification cohérente, ni trop basse ni trop élevée

Points à améliorer :
- J'aurais pu demander une garantie de paiement (acompte)
  pour cette première mission, vu le caractère nouveau
  de la relation
- Le mail de relance était bien construit mais peut-être
  un peu long ; certains clients préfèrent les listes
  ultra-condensées

3.5 Pistes d'amélioration

- Standardiser un template de mail de qualification dans
  le TMS (gain de temps sur les futures demandes)
- Mettre en place une checklist visuelle pour les
  vérifications nouveaux clients (Infogreffe + Coface
  + référence sectorielle)
- Discuter avec ma hiérarchie de la possibilité d'imposer
  un acompte de 20 % pour toute première mission > 500 €
```

---

## 4. Trame récapitulative pour les 4 activités

| Activité | Bloc | Thème suggéré | Compétence majeure |
|---|---|---|---|
| **1** | BC01 | Demande de transport et cotation | Concevoir et organiser |
| **2** | BC01 | Planification + gestion d'un aléa | Piloter en temps réel |
| **3** | BC02 | Sourcing/sélection d'un sous-traitant OU audit qualité d'un sous-traitant existant | Sous-traitance |
| **4** | BC03 | Calcul d'un coût de revient OU démarche RSE OU adaptation ZFE | Optimisation des moyens |

### Conseil clé

Choisissez **4 activités VÉCUES** différentes mais cohérentes, qui montrent que vous avez **balayé l'ensemble des compétences** du référentiel. Évitez de répéter 4 fois le même type de tâche.

---

> ✅ **À retenir**
>
> - Chaque activité = **3 pages**, structure **CDR** (Contexte / Démarche / Résultats).
> - **Chiffrer systématiquement** : durées, montants, pourcentages, KPI.
> - **Lien explicite avec le référentiel** : citer les compétences du titre.
> - **Auto-évaluation honnête** : points forts ET points à améliorer.
$dl2$,
'Méthode CDR (Contexte / Démarche / Résultats), 1 page par section, 4 activités à choisir sur 4 thèmes différents, exemple complet rédigé.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Conclusion, annexes et finalisation
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Conclusion, annexes et finalisation',
    'gotrm-dossier-pro-03-conclusion-annexes', 3, 35,
$dl3$
# Conclusion, annexes et finalisation

Les 3 dernières pages du DP sont souvent **bâclées** par les candidats. C'est une erreur : elles laissent au jury la **dernière impression** du dossier.

---

## 1. La conclusion (1 page)

### Objectif

Synthétiser ce que vous **avez appris** et ouvrir sur votre **avenir professionnel**.

### Plan recommandé

```
CONCLUSION

1. Bilan des compétences acquises (15-20 lignes)

   À travers les 4 activités présentées, j'ai pu mobiliser et
   consolider les compétences essentielles du titre GOTRM :
   - Concevoir une opération de transport (BC01)
   - Piloter un aléa avec la conformité R561 (BC01)
   - Sélectionner un sous-traitant (BC02)
   - Optimiser un coût de revient (BC03)

   Au-delà de la maîtrise technique, cette période m'a permis
   de développer des compétences transverses :
   - Communication professionnelle (clients, collègues, hiérarchie)
   - Résolution de problèmes en environnement contraint
   - Lecture rapide d'une situation pour identifier les enjeux
   - Travail en équipe avec mes collègues exploitants

2. Difficultés et apprentissages (10-15 lignes)

   Les principales difficultés rencontrées sur la période :
   - La maîtrise du TMS Optitrans : courbe d'apprentissage
     d'environ 3 semaines, surmontée grâce à mon tuteur.
   - La gestion du stress en situation de crise (Dossier 2,
     l'aléa client à La Châtre).
   - La rigueur juridique sur les vérifications préalables
     (notamment le contrat-type général).

3. Perspectives professionnelles (10-15 lignes)

   À l'issue de cette formation et après obtention du titre,
   mon projet professionnel est de :
   - Court terme (6-12 mois) : devenir exploitant senior dans
     une PME de transport spécialisée.
   - Moyen terme (3-5 ans) : évoluer vers un poste de
     responsable d'exploitation ou de directeur d'agence.
   - Long terme (> 5 ans) : envisager une création d'entreprise
     OU une spécialisation dans la commission de transport.

4. Remerciements (5 lignes)

   Je remercie [tuteur en entreprise], [formateur], [direction
   de l'entreprise] et l'ensemble des conducteurs et exploitants
   de [entreprise] pour leur accueil et leurs enseignements.
```

### Erreurs à éviter

| Erreur | Impact |
|---|---|
| Conclusion trop courte (5-10 lignes) | Le jury sent un effort tronqué |
| Conclusion qui répète le préambule | Manque de réflexivité |
| Pas de perspectives claires | Donne l'impression de ne pas savoir où on va |
| Critique négative de l'entreprise | À PROSCRIRE absolument (déloyauté) |

---

## 2. Les annexes (max 2 pages, max 5 annexes)

### Choix des annexes

Les annexes doivent **éclairer** le contenu, pas le surcharger. Privilégier :

| ✅ À inclure | ❌ À éviter |
|---|---|
| Organigramme entreprise | Brochure commerciale |
| Capture d'écran TMS commentée | Doc constructeur véhicule |
| CMR/LV signée (anonymisée si données sensibles) | Plan de la ville |
| Tableau Excel CRT que vous avez construit | Photos de groupe |
| Extrait du contrat-type pertinent | Trop de captures sans lien |

### Format des annexes

- Chaque annexe : 1 page maximum
- Numérotation claire (Annexe 1, Annexe 2...)
- **Titre explicite** en haut de chaque annexe
- Une **légende** sous chaque document
- Référence de l'annexe dans le corps du DP (« voir Annexe 3 »)

### Exemple de présentation

```
                ANNEXE 1
   Lettre de voiture nationale signée
   (Mission Issoudun → Coignières du 13 mars 2026)
   ----------------------------------------------

[Image / capture / tableau]

Légende : Cette LVN illustre les mentions obligatoires
appliquées dans le cadre de la mission décrite en
Activité 1 (page 12). Les données sensibles (n° de
téléphone client, prix) ont été masquées.
```

---

## 3. Liste de vérification finale (avant impression)

| ✓ | Élément à vérifier |
|---|---|
| ☐ | Page de garde complète (avec date de soutenance) |
| ☐ | Sommaire avec pagination correcte |
| ☐ | Numérotation des pages cohérente |
| ☐ | Aucun en-tête/pied de page incomplet |
| ☐ | Polices et tailles homogènes dans tout le document |
| ☐ | Marges respectées (2,5 cm) |
| ☐ | Aucune erreur d'orthographe (relecture par 2 personnes) |
| ☐ | Aucune coquille dans les chiffres (CA, %, plafonds) |
| ☐ | Cohérence noms de personnes / entreprises (anonymisation si demandée) |
| ☐ | Annexes numérotées et titrées |
| ☐ | Bibliographie / sources si textes cités |
| ☐ | 25 pages MAXIMUM (hors annexes) |
| ☐ | 3 exemplaires reliés prêts |

---

## 4. Calendrier de finalisation recommandé

| Semaine | Action |
|---|---|
| **S-12 à S-8** | Rédaction des 4 activités au fur et à mesure |
| **S-7** | Première version complète (brouillon) |
| **S-6** | Relecture personnelle + ajustements |
| **S-5** | Relecture par formateur + intégration commentaires |
| **S-4** | Relecture par 1 ou 2 personnes externes (orthographe) |
| **S-3** | Version finale, mise en forme professionnelle |
| **S-2** | Impression et reliure |
| **S-1** | Préparation de la soutenance orale |
| **Jour J** | Soutenance |

---

## 5. Erreurs fatales à éviter absolument

❌ **Plagiat** : recopier des extraits de cours, de wikipedia, d'un DP trouvé en ligne. Détecté facilement par les jurys, c'est éliminatoire.

❌ **Activités fictives** : décrire des situations qu'on n'a pas vécues. L'entretien démasque ces fraudes en 5 minutes.

❌ **Confidentialité** : divulguer des données sensibles (tarifs précis, noms de conducteurs, secrets commerciaux). Anonymiser ou demander l'accord de l'entreprise.

❌ **Absence de chiffres** : un DP sans chiffres n'a pas de profondeur. Mettre des chiffres partout (CA, %, durées, distances, montants).

❌ **Style trop scolaire** : « j'ai vu, on m'a montré, on m'a expliqué ». Préférer la voix active : « j'ai analysé, j'ai proposé, j'ai validé, j'ai mesuré ».

---

> ✅ **À retenir**
>
> - **Conclusion en 4 parties** : bilan compétences, difficultés, perspectives, remerciements.
> - **Annexes** : maximum 5, ciblées, avec légende et référencement dans le corps.
> - **Calendrier de finalisation** : commencer à S-12, finaliser à S-2.
> - Erreurs fatales : plagiat, activités fictives, confidentialité, absence de chiffres.
$dl3$,
'Conclusion en 4 parties (bilan compétences, difficultés, perspectives, remerciements), max 5 annexes ciblées, calendrier S-12 à J-1, erreurs fatales à éviter.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Préparer et réussir la soutenance orale
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Préparer et réussir la soutenance orale (entretien jury)',
    'gotrm-dossier-pro-04-soutenance-orale', 4, 50,
$dl4$
# Préparer et réussir la soutenance orale

L'entretien avec le jury est la **dernière épreuve** du titre GOTRM. Il dure **45 minutes** : **15 minutes de présentation** par le candidat puis **30 minutes d'entretien** avec le jury.

> 🎯 **Objectif**
>
> Convaincre le jury que vous avez **acquis et internalisé** les compétences du titre, à travers votre maîtrise du DP et votre capacité à répondre à des questions techniques.

---

## 1. Format précis de l'épreuve

| Phase | Durée | Contenu |
|---|---|---|
| **Présentation** | 15 min | Présentation par le candidat (avec ou sans support) |
| **Entretien jury** | 30 min | Questions/réponses sur le DP + questions techniques |
| **Délibération** | (hors candidat) | Validation par le jury |

### Composition du jury

- **2 ou 3 jurés** : professionnels du transport (commissionnaires, chefs d'exploitation), formateurs, conseillers institutionnels
- Posture : bienveillante mais exigeante
- Notation : appréciation sur les 3 livrables (mise en situation écrite, dossier pro, entretien)

---

## 2. Préparer la présentation orale (15 min)

### Structure recommandée

| Section | Durée | Contenu |
|---|---|---|
| 1. Salutation et présentation | 1 min | Nom, parcours, motivation |
| 2. Présentation entreprise et service | 2 min | Synthèse rapide (sans recopier le DP) |
| 3. Activité 1 — focus | 3 min | CDR rapide + apprentissages |
| 4. Activité 2 — focus | 3 min | CDR rapide + apprentissages |
| 5. Activité 3 — focus | 2 min | CDR rapide + apprentissages |
| 6. Activité 4 — focus | 2 min | CDR rapide + apprentissages |
| 7. Conclusion et perspectives | 2 min | Bilan acquis + projet professionnel |

### Astuce : la règle des 30 secondes

Le jury n'a pas relu votre DP en détail. Pour chaque activité, en **30 secondes**, le jury doit comprendre :
- Le contexte (qui, quand, quoi)
- Ce que vous avez fait
- Le résultat chiffré

Si vous tenez cette discipline, votre présentation est claire.

### Support visuel : oui ou non ?

**Recommandé** : un support PowerPoint synthétique de **8-10 slides maximum**.

Plan du support :
1. Page de garde (nom, titre, date)
2. Sommaire
3. Présentation entreprise (1 slide)
4. Activité 1 (1 slide)
5. Activité 2 (1 slide)
6. Activité 3 (1 slide)
7. Activité 4 (1 slide)
8. Conclusion (1 slide)
9. Page de remerciements

**À éviter** :
- Slides surchargées (max 6 lignes par slide)
- Texte qu'on lit à haute voix (insupportable)
- Animations clignotantes
- Polices fantaisistes

### Conseils pour la voix et la posture

| Bonne pratique | Pourquoi |
|---|---|
| **Respiration** ample avant de commencer | Calme la voix |
| **Articulation** appuyée | Audibilité |
| **Rythme posé** (pas trop rapide) | Compréhension |
| **Regard** balayant les jurés | Engagement |
| **Posture** droite (debout ou assis) | Crédibilité |
| **Mains** mobilisées (sans excès) | Conviction |

---

## 3. L'entretien (30 min) — types de questions

Le jury pose **3 types de questions**, dans cet ordre approximatif :

### Type 1 — Questions de clarification sur le DP (5-10 min)

Le jury revient sur des points précis de votre DP pour vérifier que **vous avez bien vécu** ces situations.

| Exemple | But du jury |
|---|---|
| « Vous parlez d'un CRT calculé à 580 €. Pouvez-vous nous redonner le détail des coûts ? » | Vérifier la maîtrise réelle |
| « Comment avez-vous procédé pour vérifier la solidité de MPC ? » | Anti-fraude (DP fictif ?) |
| « Pourquoi avez-vous choisi cette marge nette de 10 % ? » | Compréhension business |

### Type 2 — Questions techniques sur le référentiel (10-15 min)

Le jury teste votre **maîtrise** de l'ensemble du référentiel GOTRM (pas seulement des activités décrites).

| Exemple | Compétence évaluée |
|---|---|
| « Quels sont les 3 critères de la force majeure ? » | BC01 — Litiges |
| « Combien de pays sont signataires de la CMR ? » | BC01 — International |
| « Que prévoit le paquet mobilité pour les VUL > 2,5 t à partir de juillet 2026 ? » | BC01 — R561 |
| « Comment calcule-t-on le NPS ? » | BC01 — Relation client |
| « Citez 3 vérifications obligatoires avant de sous-traiter » | BC02 |
| « Quelle est l'autonomie typique d'un véhicule électrique 12 t en 2026 ? » | BC03 — RSE |

→ La banque de 30 questions ci-dessous prépare exactement à ce type de questions.

### Type 3 — Mise en situation imprévue (5-10 min)

Le jury vous présente un **cas pratique** sur place et vous demande de réagir.

Exemples :
- « Un client vous appelle pour vous annoncer qu'il refuse une livraison qu'on vient de lui faire. Que faites-vous dans les 30 prochaines minutes ? »
- « Vous découvrez qu'un de vos sous-traitants emploie des conducteurs non déclarés. Réaction ? »
- « Un de vos conducteurs a 26 % de turnover dans son équipe. Plan d'action ? »

→ Les 4 dossiers du **MSP final** vous préparent à ce type de questions.

---

## 4. Erreurs fatales à éviter en entretien

❌ **Improviser sur des connaissances qu'on n'a pas** : le jury repère immédiatement le bluff. Mieux vaut dire « je ne suis pas sûr, je vérifierais sur place avec mon TMS » qu'une réponse hasardeuse.

❌ **Critiquer son entreprise ou son tuteur** : signal de mauvaise loyauté professionnelle. Toujours rester courtois.

❌ **Justifier ses erreurs** : si le jury pointe une faiblesse, **reconnaître l'écart** et proposer une amélioration plutôt que de défendre coûte que coûte.

❌ **Réponses vagues** : « ça dépend », « peut-être », « je crois que ». Préférer des réponses précises avec chiffres et références.

❌ **Manque de regard** : fixer ses notes, le sol ou le plafond. Toujours **regarder le jury** quand on parle.

❌ **Téléphone allumé / vibreur** : silence absolu. Couper avant d'entrer.

---

## 5. Conseils logistiques pour le jour J

| Élément | Détail |
|---|---|
| **Tenue** | Tenue professionnelle (chemise / chemisier, costume / tailleur, chaussures soignées) |
| **Documents** | Apporter 4 exemplaires papier du DP (1 pour chaque juré + 1 de secours) |
| **Support** | Clé USB + cloud backup du PowerPoint (si support utilisé) |
| **Anticipation** | Arriver **30 min en avance** sur le centre d'examen |
| **Mental** | Repas léger 2 h avant, pas d'alcool la veille, dormir 7-8 h |
| **Calculatrice** | Calculatrice non scientifique (pour mise en situation imprévue) |

---

## 6. Récapitulatif — Top 10 conseils

1. **Connaître son DP par cœur** (chiffres, dates, étapes)
2. **Maîtriser les 14 modules du référentiel** (banque entretien)
3. **Préparer un support visuel** synthétique (max 10 slides)
4. **Répéter au moins 3 fois** la présentation à voix haute (chronométrer)
5. **Anticiper les questions difficiles** et y préparer des réponses
6. **Adopter une posture de professionnel** (tenue, regard, voix)
7. **Reconnaître ses faiblesses** plutôt que de bluffer
8. **Toujours répondre par des chiffres** quand c'est possible
9. **Conclure positivement** sur ses perspectives
10. **Remercier le jury** à la fin (« Je vous remercie de votre attention »)

---

> ✅ **À retenir**
>
> - **15 min** de présentation + **30 min** d'entretien = 45 min total.
> - **3 types de questions** : clarification DP, techniques référentiel, mise en situation.
> - **Préparer 8-10 slides** synthétiques + répéter 3 fois minimum.
> - **Reconnaître ses limites** plutôt que bluffer — le jury valorise l'honnêteté.
$dl4$,
'Format soutenance : 15 min présentation + 30 min entretien (3 types de questions : clarification DP, technique, mise en situation), conseils tenue/voix/posture, top 10 conseils.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- LEÇON 5 — Banque de 30 questions d'entretien jury (consignes)
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Banque de 30 questions d''entretien jury — consignes',
    'gotrm-dossier-pro-05-banque-entretien', 5, 30,
$dl5$
# Banque de 30 questions d'entretien jury — consignes

Cette banque rassemble **30 questions techniques** que les jurys posent fréquemment en entretien, regroupées par bloc de compétences. Les questions sont **reformulées** à partir de retours de jurys (pas de plagiat).

> 🎯 **Comment utiliser cette banque**
>
> 1. **Lisez** chaque question.
> 2. **Répondez à voix haute** sans regarder la correction.
> 3. **Comparez** avec la correction-modèle proposée.
> 4. **Notez-vous** : 0 = je ne sais pas, 1 = je connais en gros, 2 = je maîtrise.
> 5. **Repassez** sur les questions notées 0 ou 1 jusqu'à atteindre 2.

---

## Répartition des 30 questions

| Bloc | Nombre | Thèmes principaux |
|---|---|---|
| BC01 | 18 | Demande, contrat-CMR, cotation, R561, douane-Incoterms, planification, ADR-ATP, relation client, litiges, KPI |
| BC02 | 6 | Cadre juridique, AO, audits, conflits |
| BC03 | 6 | Coûts, TCO, RSE, ZFE, KPI durables |

---

## Format des questions

Chaque question est :
- **Courte** (3-5 lignes maximum)
- **Précise** (réponse attendue claire)
- **Représentative** des attentes réelles d'un jury

La correction-modèle donne :
- La **réponse principale** (point central attendu)
- Les **éléments complémentaires** (ce qu'un excellent candidat ajoute)
- Les **textes ou chiffres** à citer

---

## Astuce : structure type d'une réponse en entretien

Pour chaque question, préférez une réponse en **3 étapes** :

```
1. Réponse directe (1 phrase)
   « Le plafond CMR est de 8,33 DTS par kilogramme. »

2. Explication (1-2 phrases)
   « Cette règle vient de l'article 23 §3 de la CMR. En 2026,
   1 DTS vaut environ 1,30 € soit ~10,80 €/kg. »

3. Nuance ou cas limite (1 phrase)
   « Ce plafond peut sauter en cas de faute lourde
   (article 29 CMR), auquel cas l'indemnisation est intégrale. »
```

Cette structure montre la **maîtrise progressive** du sujet : connaissance, compréhension, application.

---

## Lien avec les autres ressources

Cette banque s'utilise en **complément** de :
- Les **70 quizzes d'entraînement** des 14 modules
- Les **3 examens blancs synthétiques** (BC01, BC02, BC03)
- Le **MSP final** pour les mises en situation

Lancez le quiz « Banque entretien jury » dans cette même page pour faire défiler les 30 questions.

Bon courage !
$dl5$,
'Banque de 30 questions techniques d''entretien jury (18 BC01, 6 BC02, 6 BC03), à utiliser pour s''auto-évaluer en complément des quizzes et examens blancs.'
  ) RETURNING id INTO v_lesson_5;

  -- =================================================================
  -- 30 QUESTIONS D'ENTRETIEN — toutes en QR (rédigées)
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, source_ref, type, statement, choices, max_score, difficulty, tags, active, explanation) VALUES

  -- BC01 (18 questions)
  (v_formation, 'mft-2026-gotrm:entretien:01', 'qr',
   'Citez les 5 acteurs principaux d''une opération de transport routier de marchandises et précisez le rôle de chacun en une phrase.',
   NULL, 1, 'facile', ARRAY['entretien','bc01','acteurs'], true,
   'Réponse attendue : (1) **Expéditeur** (chargeur) : confie la marchandise au transporteur. (2) **Destinataire** : reçoit la marchandise à l''arrivée et signe la lettre de voiture. (3) **Transporteur public routier (TPR)** : exécute matériellement le transport. (4) **Commissionnaire de transport** : organise le transport en son nom propre pour le compte du client (peut être le donneur d''ordre). (5) **Donneur d''ordre** : entité juridique qui passe commande (souvent confondue avec l''expéditeur).'),

  (v_formation, 'mft-2026-gotrm:entretien:02', 'qr',
   'Quelle différence faites-vous entre un commissionnaire et un transporteur public ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc01','commissionnaire'], true,
   'Réponse attendue : Le **transporteur public** EXÉCUTE matériellement le transport (il a un parc et des conducteurs). Le **commissionnaire** ORGANISE le transport en son nom propre, sous-traitant à un ou plusieurs transporteurs publics. Le commissionnaire est responsable des fautes des transporteurs qu''il a sélectionnés (article L. 132-3 du Code de commerce). Une entreprise peut cumuler les 2 statuts. Le commissionnaire doit avoir une licence commissionnaire (LCB) en plus du capacitaire.'),

  (v_formation, 'mft-2026-gotrm:entretien:03', 'qr',
   'Pour un transport national en l''absence de convention écrite, quel texte s''applique automatiquement ?',
   NULL, 1, 'facile', ARRAY['entretien','bc01','contrat-type'], true,
   'Réponse attendue : Le **contrat-type général**, défini par le **décret 99-269 du 6 avril 1999** (modifié par décrets postérieurs). Il s''applique à tout transport national en l''absence de convention écrite particulière entre les parties. Pour les spécialités (matières dangereuses, sous-traitance, déménagement, citerne...), des contrats-types dédiés existent (ex : décret 2003-1295 pour la sous-traitance).'),

  (v_formation, 'mft-2026-gotrm:entretien:04', 'qr',
   'Quel est le plafond d''indemnisation en transport national selon le contrat-type général ?',
   NULL, 1, 'facile', ARRAY['entretien','bc01','plafond-indemnisation'], true,
   'Réponse attendue : **33 €/kg de marchandise endommagée OU 1 000 €/colis**, le moindre des deux étant retenu (article 21 du contrat-type général). Pour le retard, l''indemnité est limitée au **prix du transport** sauf clause d''intérêt spécial à la livraison. Ces plafonds peuvent sauter en cas de **faute lourde ou dol** du transporteur, auquel cas l''indemnisation est intégrale. Les plafonds peuvent être augmentés par **déclaration de valeur** sur la lettre de voiture, contre supplément de prix.'),

  (v_formation, 'mft-2026-gotrm:entretien:05', 'qr',
   'Quel est le plafond CMR international et comment se calcule-t-il en 2026 ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc01','cmr','plafond'], true,
   'Réponse attendue : **8,33 DTS par kilogramme** brut manquant ou avarié (article 23 §3 CMR). En 2026, 1 DTS ≈ 1,30 € (variable quotidiennement), soit environ **10,80 €/kg**. Le DTS (Droit de Tirage Spécial) est l''unité de compte du FMI. Le plafond peut sauter en cas de **dol ou faute équivalente** (article 29 CMR), auquel cas l''indemnisation est intégrale. Possibilité de relever le plafond par **déclaration de valeur** (article 24) ou **intérêt spécial à la livraison** (article 26), contre supplément de prix.'),

  (v_formation, 'mft-2026-gotrm:entretien:06', 'qr',
   'Quels sont les 3 critères cumulatifs de la force majeure exonératoire ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc01','force-majeure'], true,
   'Réponse attendue : (1) **Extérieur** : événement extérieur à l''activité du transporteur (pas une panne mécanique, pas une grève annoncée). (2) **Imprévisible** : impossible à anticiper raisonnablement (pas une pluie en hiver, pas un embouteillage chronique). (3) **Irrésistible** : impossible à éviter ou aux conséquences inévitables. Les 3 critères sont **cumulatifs**. Les juges interprètent restrictivement : seuls des événements rares et exceptionnels (tempête majeure imprévue, attentat, blocage soudain) sont reconnus.'),

  (v_formation, 'mft-2026-gotrm:entretien:07', 'qr',
   'Quel est le temps de conduite quotidien maximum pour un conducteur soumis à la R561 ?',
   NULL, 1, 'facile', ARRAY['entretien','bc01','r561','conduite'], true,
   'Réponse attendue : **9 heures par jour** en standard, prolongeables à **10 heures** maximum **2 fois par semaine**. La conduite hebdomadaire est plafonnée à **56 h** et la conduite bihebdomadaire (2 semaines glissantes) à **90 h**. Une **pause de 45 min** est obligatoire après 4 h 30 de conduite cumulée (fractionnable en 15 min puis 30 min, dans cet ordre uniquement).'),

  (v_formation, 'mft-2026-gotrm:entretien:08', 'qr',
   'Que prévoit le paquet mobilité pour les VUL de plus de 2,5 t en transport international à partir de juillet 2026 ?',
   NULL, 1, 'difficile', ARRAY['entretien','bc01','r561','paquet-mobilite'], true,
   'Réponse attendue : À partir du **1er juillet 2026**, les **véhicules utilitaires de 2,5 t à 3,5 t** (PTAC) en transport **international** seront soumis à la **R561** comme les véhicules > 3,5 t : obligation de **chronotachygraphe** (smart gen.2v2), respect des **temps de conduite et repos**, formation conducteurs. Cela impacte fortement la messagerie internationale en VUL (notamment vers le UK post-Brexit). Les transports nationaux et les VUL ≤ 2,5 t restent exemptés.'),

  (v_formation, 'mft-2026-gotrm:entretien:09', 'qr',
   'Quelle est la différence entre repos journalier normal, fractionné et réduit en R561 ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc01','r561','repos'], true,
   'Réponse attendue : (1) **Normal** : 11 h consécutives dans une période de 24 h. (2) **Fractionné** : 3 h + 9 h (total ≥ 12 h, dans cet ordre uniquement). (3) **Réduit** : 9 h consécutives, **maximum 3 fois entre deux repos hebdomadaires**, sans compensation depuis le paquet mobilité. Le repos hebdomadaire est de 45 h (réduit à 24 h × 1 fois sur 2 semaines avec compensation 21 h). Depuis août 2020, le repos hebdomadaire **régulier (45 h) est interdit en cabine** — l''entreprise doit fournir un hébergement.'),

  (v_formation, 'mft-2026-gotrm:entretien:10', 'qr',
   'Quels sont les 3 exemplaires de la lettre de voiture CMR et leur destination ?',
   NULL, 1, 'facile', ARRAY['entretien','bc01','cmr','exemplaires'], true,
   'Réponse attendue : (1) **Rouge** : remis à l''**expéditeur** (chargeur). (2) **Bleu** : suit la **marchandise** et est remis au **destinataire** à la livraison. (3) **Vert** : conservé par le **transporteur** dans ses archives. Mémo : **R**ouge = **R**este chez l''expéditeur ; **B**leu = **B**ouge avec la marchandise ; **V**ert = **V**it dans les archives. La CMR comporte 14 mentions obligatoires (article 6) : parties, lieux, marchandise, frais, instructions douanières, etc.'),

  (v_formation, 'mft-2026-gotrm:entretien:11', 'qr',
   'Combien d''Incoterms 2020 existe-t-il et quels sont les 4 réservés au transport maritime ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc01','incoterms'], true,
   'Réponse attendue : **11 Incoterms 2020** au total : 7 multimodaux (EXW, FCA, CPT, CIP, DAP, DPU, DDP) et **4 réservés au transport maritime** (et fluvial intérieur) : **FAS, FOB, CFR, CIF**. Pour la route, l''air ou le multimodal : utiliser FCA, CPT, CIP, DAP, DPU ou DDP. Erreur fréquente à éviter : utiliser FOB ou CIF pour un transport routier — c''est invalide juridiquement.'),

  (v_formation, 'mft-2026-gotrm:entretien:12', 'qr',
   'Qu''est-ce que la RPC en transport et pourquoi est-elle obligatoire ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc01','rpc'], true,
   'Réponse attendue : **RPC** = Répercussion du Prix du Carburant. Mécanisme légal d''indexation du prix de transport sur la variation du gazole. **Obligation d''ordre public** selon l''**article L. 3222-1 du Code des transports** : aucune clause ne peut y renoncer. À défaut de clause expresse, l''indexation s''applique automatiquement. L''indice de référence standard est le **CNR** (Comité National Routier), mensuel. La part carburant typique : **30 % pour un porteur**, 35 % pour un TRR longue distance, 25 % pour la distribution urbaine. Sanctions pénales en cas de refus du donneur d''ordre : 15 000 € amende.'),

  (v_formation, 'mft-2026-gotrm:entretien:13', 'qr',
   'Décrivez les 9 classes de matières dangereuses ADR.',
   NULL, 1, 'difficile', ARRAY['entretien','bc01','adr'], true,
   'Réponse attendue : **9 classes ADR** : (1) Matières et objets explosibles, (2) Gaz, (3) Liquides inflammables (essence, gazole), (4) Solides inflammables (4.1, 4.2, 4.3), (5) Comburants et peroxydes (5.1, 5.2), (6) Toxiques et infectieux (6.1, 6.2), (7) Radioactifs, (8) Corrosifs (acides, bases), (9) Matières et objets dangereux divers (batteries lithium, amiante). Chaque matière a un **numéro ONU** unique à 4 chiffres (ex : UN1203 = essence). Le **panneau orange** (30×40 cm) porte le code danger et le n° ONU. Le **conseiller à la sécurité (CSTMD)** est obligatoire au-delà des seuils d''exemption.'),

  (v_formation, 'mft-2026-gotrm:entretien:14', 'qr',
   'Qu''est-ce qu''un véhicule FRC en ATP et quelles températures peut-il maintenir ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc01','atp','frc'], true,
   'Réponse attendue : **FRC** = **F**rigorifique **R**enforcé classe **C**. Véhicule isotherme avec groupe frigorifique mécanique, capable de maintenir des températures de **-20 °C à +12 °C**. C''est le standard polyvalent du marché : permet de transporter à la fois des **surgelés** (glaces, viande hachée) et des **frais** (lait, charcuterie) avec un seul véhicule. L''**attestation ATP** est délivrée pour 6 ans initialement, puis renouvelée par périodes de 3 ans (en France : Cemafroid). Un enregistreur de température continu est obligatoire avec conservation 12 mois minimum.'),

  (v_formation, 'mft-2026-gotrm:entretien:15', 'qr',
   'Quelles sont les 3 catégories de transport exceptionnel et le délai d''instruction TIE-PI typique ?',
   NULL, 1, 'difficile', ARRAY['entretien','bc01','exceptionnel'], true,
   'Réponse attendue : (1) **Catégorie 1** (mineure) : ≤ 20 m, ≤ 3 m, ≤ 48 t — autorisation permanente possible, sans accompagnement. (2) **Catégorie 2** (intermédiaire) : 20-25 m, 3-4 m, 48-72 t — autorisation au cas par cas, **1 voiture pilote**, instruction **4-6 semaines**. (3) **Catégorie 3** (majeure) : > 25 m, > 4 m ou > 72 t — autorisation spécifique, **2 voitures pilotes + escorte gendarmerie** souvent, instruction **8-12 semaines**. Le téléservice est **TIE-PI** (Transports Intérieurs Exceptionnels - Procédure Informatisée). Vitesse limitée : 60 km/h hors agglo, 30 km/h en agglo. Anticiper **3-4 mois** pour une catégorie 3.'),

  (v_formation, 'mft-2026-gotrm:entretien:16', 'qr',
   'Comment se calcule le NPS et quelle est la cible secteur transport B2B ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc01','nps','satisfaction'], true,
   'Réponse attendue : **NPS = % Promoteurs − % Détracteurs**. Échelle 0-10 sur la question « Recommanderiez-vous notre entreprise ? ». **Promoteurs** : 9-10. **Passifs** : 7-8 (non comptés). **Détracteurs** : 0-6. Échelle de -100 à +100. Cible secteur **transport B2B France : 20-30** (moyenne). > 40 = top quartile. > 50 = excellent. < 0 = mauvais (plus de détracteurs que de promoteurs). Le NPS doit être **bouclé** : revenir vers les détracteurs sous 30 jours avec les actions menées suite à leur retour.'),

  (v_formation, 'mft-2026-gotrm:entretien:17', 'qr',
   'Quels sont les délais de réserves apparentes et non apparentes en transport national et CMR ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc01','reserves'], true,
   'Réponse attendue : (1) **National** (article L. 133-3 Code commerce + contrat-type général) : **réserves apparentes** au moment de la livraison ; **réserves non apparentes** dans **3 jours ouvrés**. (2) **CMR international** (article 30) : **réserves apparentes** à la livraison ; **réserves non apparentes** dans **7 jours ouvrés** ; pour le **retard** : **21 jours** ; pour la **perte présumée** : 30 jours après le délai convenu (ou 60 jours après prise en charge). Une réserve **vague** (« sous réserve de déballage ») est généralement jugée **inopposable** au transporteur. Préférer des réserves précises et chiffrées.'),

  (v_formation, 'mft-2026-gotrm:entretien:18', 'qr',
   'Quels sont les 6 KPI essentiels d''un tableau de bord exploitation ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc01','kpi'], true,
   'Réponse attendue : (1) **Taux de remplissage** (poids et volume, max des deux), cible > 80 % en LTL, > 85 % en FTL. (2) **Ponctualité** (livraisons dans la fenêtre RDV), cible > 95 %. (3) **Taux de retour à vide**, cible < 15 % en TRM longue distance. (4) **Consommation moyenne** (L/100 km), cible 26-30 pour porteur 19 t. (5) **Coût km commercial**, cible < 1,40 € pour porteur 19 t. (6) **Productivité conducteur** (km/jour ou points livrés/h). À compléter par les KPI clients (NPS, churn, litiges) et RH (turnover, accidents).'),

  -- BC02 (6 questions)
  (v_formation, 'mft-2026-gotrm:entretien:19', 'qr',
   'Quelles sont les vérifications obligatoires avant de sous-traiter selon l''article L. 8222-1 ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc02','verifications'], true,
   'Réponse attendue : **Avant la conclusion** du contrat **et tous les 6 mois** ensuite, le donneur d''ordre doit vérifier : (1) **KBIS** récent (< 3 mois), (2) **Attestation URSSAF de vigilance** (< 6 mois), (3) **Attestation fiscale** à jour, (4) **DPAE** (Déclaration Préalable À l''Embauche) cohérente avec le parc et le volume. Spécifique au transport : licence transport (LTI/LTM), bulletins n°2 dirigeants (honorabilité), attestation RC professionnelle. À défaut : risque de **complicité de travail dissimulé** (75 000 € amende + solidarité financière + suspension licence).'),

  (v_formation, 'mft-2026-gotrm:entretien:20', 'qr',
   'Qu''est-ce qu''un « prix abusivement bas » en sous-traitance et quelle sanction encourt le donneur d''ordre ?',
   NULL, 1, 'difficile', ARRAY['entretien','bc02','prix-abusivement-bas'], true,
   'Réponse attendue : Article **L. 3222-3** du Code des transports : un prix est qualifié d''abusivement bas s''il **ne couvre pas les coûts d''exploitation** du sous-traitant (carburant, conducteur, amortissement, structure) et le met en risque économique structurel. Pratique **interdite**. Sanction : **amende administrative jusqu''à 90 000 €** pour le donneur d''ordre. Bonne pratique : avoir un **barème interne minimum** par type de mission/véhicule (€/km, €/h, forfaits) et tracer toutes les négociations. À ne pas confondre avec une simple négociation tarifaire.'),

  (v_formation, 'mft-2026-gotrm:entretien:21', 'qr',
   'Quelle est la pondération recommandée pour un appel d''offres sous-traitance équilibré ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc02','ao'], true,
   'Réponse attendue : Pondération équilibrée : **Prix 30-40 %**, **Qualité de service / SLA 25-30 %**, **Capacité technique 15-20 %**, **Solidité financière 10-15 %**, **RSE et certifications 5-10 %**. Mettre 100 % sur le prix mène au **moins-disant** destructeur (sous-traitant fragile, risques sécurité, perte d''honorabilité par contagion). Une AO bien construite inclut **seuils éliminatoires** (KBIS valide, licence en cours), un **cahier des charges** structuré en 8 sections, et une **visite terrain** des 3 finalistes (1/2 journée minimum).'),

  (v_formation, 'mft-2026-gotrm:entretien:22', 'qr',
   'Que prévoit l''article L. 442-1 du Code de commerce concernant la rupture de relation commerciale ?',
   NULL, 1, 'difficile', ARRAY['entretien','bc02','rupture-brutale'], true,
   'Réponse attendue : Article **L. 442-1 du Code de commerce** : « Engage la responsabilité de son auteur le fait, dans le cadre de relations commerciales, de **rompre brutalement, même partiellement, une relation commerciale établie**. » 3 critères : **relation établie** (durée significative + volumes réguliers), **rupture brutale** (sans préavis raisonnable), **préjudice causé**. Préavis raisonnable indicatif : **< 1 an = 1-2 mois**, 1-3 ans = 3-6 mois, **3-10 ans = 6-12 mois**, > 10 ans = 12-24 mois. Cette protection est **d''ordre public**, distincte du préavis contractuel.'),

  (v_formation, 'mft-2026-gotrm:entretien:23', 'qr',
   'Quels sont les 4 niveaux de constatation d''un audit sous-traitant et leurs délais de régularisation ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc02','audit'], true,
   'Réponse attendue : (1) **Non-conformité majeure** (NC majeure) : risque légal, financier ou sécuritaire — régularisation < **30 jours**. (2) **Non-conformité mineure** (NC mineure) : écart sans impact immédiat — régularisation < **90 jours**. (3) **Observation** : point d''amélioration recommandé — plan moyen terme. (4) **Bonne pratique** : à documenter et partager. Un audit terrain dure typiquement **1/2 journée** (réunion ouverture, revue documents, visite locaux et parc, échanges, clôture). Notation typique sur 100 points (5 sections : administratif 20, véhicules 25, conducteurs 25, procédures 15, conformité spécifique 15).'),

  (v_formation, 'mft-2026-gotrm:entretien:24', 'qr',
   'Que doit faire un sous-traitant pour pouvoir lui-même sous-traiter (cascade) ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc02','cascade'], true,
   'Réponse attendue : Article **L. 3221-3** du Code des transports : la sous-traitance en cascade nécessite l''**information explicite du donneur d''ordre principal**. Une cascade non déclarée peut entraîner : annulation du contrat, amendes, perte d''honorabilité professionnelle (suspension de la licence). Le sous-traitant doit aussi respecter les règles de capacité et d''honorabilité (R3411-1 Code des transports). Conseil : insérer dans le contrat avec le sous-traitant une **clause stricte sur la cascade** + audit terrain régulier pour détecter les sous-traitances occultes.'),

  -- BC03 (6 questions)
  (v_formation, 'mft-2026-gotrm:entretien:25', 'qr',
   'Quelle est la formule du Coût de Revient Transport (CRT) ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc03','crt'], true,
   'Réponse attendue : **CRT = (Km totaux × Coût km variable) + (Heures totales × Coût horaire fixe) + Coûts spécifiques mission**. Le **coût km variable** comprend : carburant, entretien, pneumatiques, péages, lubrifiants/AdBlue. Le **coût horaire fixe** comprend : conducteur, amortissement véhicule, assurances/taxes (au prorata), frais de structure (au prorata). Pour un porteur 19 t en 2026 : coût km variable ~ 0,59 €/km, coût horaire fixe ~ 41,5 €/h. Toujours penser **km commerciaux** (chargés) vs km totaux : un véhicule à 50 % de retour à vide a un coût km commercial **doublé**.'),

  (v_formation, 'mft-2026-gotrm:entretien:26', 'qr',
   'Quel est le coût km global typique d''un porteur 19 t en 2026 ?',
   NULL, 1, 'facile', ARRAY['entretien','bc03','cout-km'], true,
   'Réponse attendue : **~ 1,22 à 1,30 €/km total** (toutes charges incluses) en 2026 pour un porteur 19 t en cycle régional, sur la base de 110 000 km/an. Décomposition : **carburant ~ 32 %**, **conducteur ~ 30 %**, structure ~ 8 %, amortissement ~ 8 %, entretien et pneus ~ 8 %, péages ~ 5 %, assurances/taxes ~ 4 %, lubrifiants ~ 3 %. Le prix de vente cible est typiquement **1,40-1,55 €/km commercial** pour atteindre une marge nette de 8-12 %. Un retour à vide trop élevé (> 20 %) compromet la rentabilité.'),

  (v_formation, 'mft-2026-gotrm:entretien:27', 'qr',
   'Quels sont les 3 modes de financement principaux d''un véhicule industriel et leurs avantages comparés ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc03','financement'], true,
   'Réponse attendue : (1) **Achat avec crédit** : propriété immédiate, amortissement déductible (linéaire ou dégressif), suramortissement véhicules propres +40 %, mais mobilise capacité d''endettement. (2) **Crédit-bail** : loueur propriétaire, loyers 100 % déductibles, **option d''achat à la fin** (1-5 % de la valeur résiduelle), préserve la capacité d''endettement. (3) **LLD** (Location Longue Durée) : pas de propriété finale, **service entretien souvent inclus**, simplicité opérationnelle, idéal pour utilitaires à renouveler souvent (3-5 ans). Mix recommandé pour PME : achat pour véhicules cœur, crédit-bail pour complément, LLD pour utilitaires.'),

  (v_formation, 'mft-2026-gotrm:entretien:28', 'qr',
   'Que sont les vignettes Crit''Air E et 1 et quelles sont leurs caractéristiques principales ?',
   NULL, 1, 'moyen', ARRAY['entretien','bc03','critair','zfe'], true,
   'Réponse attendue : (1) **Crit''Air E** (vignette **verte**) : véhicules **zéro émission directe** — électriques et hydrogène. Accès garanti à toutes les ZFE. Aucune restriction prévue. (2) **Crit''Air 1** (vignette **violette**) : véhicules à **gaz** (GNV, bioGNV), **hybrides rechargeables**, et hybrides essence récents. Accès maintenu aux ZFE jusqu''à 2030 dans la plupart des grandes métropoles. À horizon **2030**, la plupart des grandes ZFE (Paris, Lyon, Marseille...) prévoient l''interdiction des Crit''Air 2, 3, 4, 5 — seuls les Crit''Air E (et parfois 1) seront autorisés.'),

  (v_formation, 'mft-2026-gotrm:entretien:29', 'qr',
   'Que prévoit le suramortissement véhicules propres et jusqu''à quand est-il valable ?',
   NULL, 1, 'difficile', ARRAY['entretien','bc03','suramortissement'], true,
   'Réponse attendue : **Suramortissement véhicules propres** = déduction supplémentaire de **40 % de la valeur d''origine**, étalée sur la durée d''amortissement, en plus de l''amortissement classique. Concerne les véhicules **gaz (GNV/bioGNV)**, **électriques**, et **hydrogène** de PTAC ≥ 2,6 t. Valable **jusqu''en 2030** (à confirmer chaque loi de finances). Cumulable avec aides ADEME (5-25 k€/véhicule) et aides régionales. Pour un véhicule électrique de 220 k€, le suramortissement représente une économie fiscale d''environ **22 k€ étalée sur 6 ans**, ce qui réduit considérablement le coût net d''acquisition.'),

  (v_formation, 'mft-2026-gotrm:entretien:30', 'qr',
   'Que désignent les 3 scopes du bilan carbone d''une entreprise de transport ?',
   NULL, 1, 'difficile', ARRAY['entretien','bc03','bilan-carbone','scopes'], true,
   'Réponse attendue : (1) **Scope 1** : émissions **directes** liées à la combustion sur sites contrôlés — pour un transporteur, c''est essentiellement le **carburant des véhicules** (gazole : facteur d''émission **2,52 kg CO2eq/L**). (2) **Scope 2** : émissions **indirectes** liées à l''**énergie achetée** (électricité des locaux, par exemple). (3) **Scope 3** : autres émissions indirectes — déplacements professionnels, achats de véhicules amortis, sous-traitance, fin de vie du parc. Pour un porteur 19 t à 28 L/100 km × 110 000 km/an : Scope 1 = 30 800 L × 2,52 = **77,6 tCO2eq/véhicule/an**. Le **BEGES** (Bilan d''Émissions de GES) est obligatoire pour les entreprises > 500 salariés (DROM > 250) tous les 4 ans. La directive **CSRD** (UE 2024) étend progressivement le reporting ESG aux PME.');

  -- =================================================================
  -- QUIZ : Banque entretien 30 questions
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Banque entretien jury — 30 questions techniques',
    'Banque de 30 questions de type entretien jury, à utiliser pour s''auto-évaluer et préparer la soutenance orale. Toutes les questions sont en format rédigé (QR) avec correction-modèle. Pas de chronomètre, pas de seuil — l''objectif est l''entraînement.',
    'entrainement', NULL, 70
  ) RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, qb.id, ROW_NUMBER() OVER (ORDER BY qb.source_ref)
  FROM public.question_bank qb
  WHERE qb.formation_id = v_formation
    AND qb.source_ref LIKE 'mft-2026-gotrm:entretien:%';

  RAISE NOTICE '✅ GOTRM dossier pro & banque entretien chargés : 5 leçons + 30 QR entretien.';
END
$dossier_entretien$;
