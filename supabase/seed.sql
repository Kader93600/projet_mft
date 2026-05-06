-- =====================================================================
-- MA FORMATION TRANSPORT — Données pédagogiques enrichies
-- RNCP 40990 (blocs, modules, leçons, quiz, examens blancs)
-- Version sans DO blocks pour compatibilité Supabase SQL Editor
-- =====================================================================

-- --------- BLOCS RNCP 40990 ---------
insert into blocs (code, title, description, "order") values
('BC1', 'Concevoir, organiser et piloter des opérations de transport',
 'Planifier des opérations de transport routier de marchandises, gérer la réglementation, la documentation, la relation client et les imprévus.', 1),
('BC2', 'Piloter les trafics sous-traités',
 'Sélectionner, contractualiser et suivre les sous-traitants, gérer les appels d''offres et les litiges.', 2),
('BC3', 'Optimiser les moyens liés à l''activité transport',
 'Calculer les coûts de revient, analyser la rentabilité, mettre en place des KPI qualité et une démarche RSE.', 3)
on conflict (code) do nothing;

-- --------- MODULES ---------
insert into modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
select b.id, v.slug, v.title, v.summary, v.difficulty::user_level, v.duration_min, v."order"
from (values
  ('BC1', 'planification-tournees', 'Planification et organisation des tournées', 'Optimiser les tournées, construire un plan de transport, gérer les temps de conduite et de repos.', 'debutant', 75, 1),
  ('BC1', 'reglementation-transport', 'Réglementation du transport routier', 'CMR, temps de conduite (règlement 561/2006), TMD (ADR), documents obligatoires, cabotage.', 'intermediaire', 90, 2),
  ('BC1', 'relation-client', 'Relation client et gestion des litiges', 'Contrats type, bon de livraison, réserves, responsabilité du transporteur, qualité de service.', 'debutant', 60, 3),
  ('BC2', 'appels-offres', 'Appels d''offres et contractualisation', 'Cahier des charges, grille tarifaire, critères de sélection, contrats de sous-traitance.', 'intermediaire', 60, 1),
  ('BC2', 'suivi-sous-traitants', 'Suivi et qualité des sous-traitants', 'Indicateurs, audits, gestion des non-conformités, fidélisation.', 'avance', 55, 2),
  ('BC3', 'cout-revient', 'Coût de revient kilométrique (CRKM)', 'Charges fixes, charges variables, calcul et analyse du prix de revient, indices CNR.', 'intermediaire', 75, 1),
  ('BC3', 'kpi-rentabilite', 'KPI et pilotage de la rentabilité', 'Taux de remplissage, marge par tournée, tableaux de bord, démarche RSE.', 'avance', 60, 2)
) as v(bloc_code, slug, title, summary, difficulty, duration_min, "order")
join blocs b on b.code = v.bloc_code
on conflict (slug) do nothing;

-- =====================================================================
-- LEÇONS — MODULE 1 : PLANIFICATION ET TOURNÉES
-- =====================================================================

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'introduction', 'Introduction et enjeux',
$md$## Contexte

Le **transport routier de marchandises** assure environ **89 % du transport intérieur de fret en France**, soit plus de 320 milliards de tonnes-kilomètres chaque année. Le rôle du **gestionnaire des opérations (GOTRM)** est central : il planifie, coordonne et optimise l'acheminement des marchandises dans le respect du cadre réglementaire.

## Le métier de GOTRM

Le gestionnaire des opérations de transport routier de marchandises intervient à trois niveaux :

- **Opérationnel** : affectation quotidienne des véhicules et conducteurs, construction des tournées, gestion des aléas
- **Tactique** : négociation avec sous-traitants, analyse des coûts, plan de transport hebdomadaire
- **Stratégique** : contribution aux appels d'offres, démarche qualité, politique RSE

## Pourquoi planifier ?

> Une bonne planification peut réduire les coûts d'exploitation de **15 à 25 %** et diminuer les émissions de CO₂ d'autant.

Trois objectifs fondamentaux :

- **Qualité de service** : respecter les délais promis au client (taux de service > 98 %)
- **Rentabilité** : maximiser le taux de remplissage et minimiser les kilomètres à vide
- **Conformité** : temps de conduite, repos, documents, ADR, tachygraphe

## Les leviers du planificateur

- **Choix du véhicule** : PTAC, carrosserie (bâché, frigo, citerne, benne), équipements (hayon, chariot), motorisation (Euro VI, GNV, électrique)
- **Affectation du conducteur** : qualifications FIMO/FCO, ADR, habilitation hayon, temps disponibles
- **Construction de la tournée** : point de départ, séquence de livraisons, retour à vide ou fret retour
- **Anticipation des aléas** : trafic, météo, retards client, pannes, grèves

## Indicateurs à surveiller

| Indicateur | Formule | Cible |
|------------|---------|-------|
| Taux de remplissage | Tonnage réel / PTAC utile | > 85 % |
| Kilomètres à vide | km vide / km total | < 15 % |
| Taux de service | livraisons à l'heure / total | > 98 % |
| Productivité conducteur | km ou t·km / jour | selon activité |
| Coût du km | charges totales / km parcourus | selon CRKM |

## Les outils du quotidien

- **TMS** (Transport Management System) : planification assistée, optimisation
- **Géolocalisation** : suivi temps réel, preuves de livraison
- **Chronotachygraphe** : conformité temps de conduite
- **EDI / API client** : réception automatique des commandes
$md$,
$md$**À retenir** : planifier concilie service, coût et conformité. KPI clés : remplissage > 85 %, km vides < 15 %, taux de service > 98 %.$md$,
1
from modules m where m.slug='planification-tournees'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'temps-conduite', 'Temps de conduite et repos',
$md$## Règlement (CE) 561/2006

Ce règlement européen encadre les temps de conduite, pauses et repos des conducteurs de véhicules de plus de 3,5 t de PTAC et de transport de voyageurs > 9 places.

### Temps de conduite

- **Journalier** : 9 h (extensible à 10 h **deux fois par semaine**)
- **Hebdomadaire** : 56 h max (lundi 0h → dimanche 24h)
- **Bi-hebdomadaire** : 90 h sur deux semaines consécutives

### Pauses

- **45 min** après 4 h 30 de conduite cumulée
- Peut être fractionnée : **15 min + 30 min** (obligatoirement dans cet ordre)
- La pause remet le compteur 4h30 à zéro

### Repos journalier

- **Normal** : 11 h consécutives
- **Réduit** : 9 h consécutives (maximum 3 fois entre deux repos hebdomadaires)
- **Fractionné** : 3 h + 9 h (9 h obligatoirement d'un seul tenant)
- À prendre dans les **24 heures** suivant la fin du précédent repos

### Repos hebdomadaire

- **Normal** : 45 h
- **Réduit** : 24 h (possible une semaine sur deux, compensation obligatoire dans les 3 semaines)
- À prendre au plus tard après **6 périodes de 24 heures** de travail

## Cas pratiques

**Exemple 1 — Journée type :**
6h00 départ → 10h30 pause 45 min → 11h15 reprise → 14h45 pause 45 min → 15h30 reprise jusqu'à 16h30. Conduite : 4h30 + 3h30 + 1h = 9h ✅

**Exemple 2 — Extension à 10 h :**
Autorisée 2 fois par semaine. Doit être notée sur la feuille d'activité et reste soumise aux règles de pause.

## Chronotachygraphe

Le **chronotachygraphe numérique** (obligatoire depuis 2006) enregistre automatiquement :
- Temps de conduite (symbole volant)
- Autre travail (marteaux croisés)
- Disponibilité (carré)
- Repos (lit)

La carte conducteur contient 28 jours de données. Les entreprises doivent télécharger les données **tous les 90 jours max** pour le véhicule et **tous les 28 jours** pour le conducteur.

## Contrôles et sanctions

Les contrôles DREAL/gendarmerie/police peuvent remonter **28 jours** en arrière (jour en cours + 28 jours précédents).

| Infraction | Sanction |
|------------|----------|
| Dépassement conduite < 10 % | 135 € (contravention 4ᵉ classe) |
| Dépassement > 20 % | 1 500 € |
| Absence de carte | 750 € |
| Manipulation du tachygraphe | jusqu'à 30 000 € et prison |
$md$,
$md$**Retenir** : 4h30 → pause 45 min. Conduite 9h/j (10h 2x/sem), 56h/sem, 90h/2sem. Repos 11h/j, 45h/sem. Contrôle sur 28 jours.$md$,
2
from modules m where m.slug='planification-tournees'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'cmr-documents', 'La lettre de voiture CMR',
$md$## La CMR, document clé

La **Convention de Genève du 19 mai 1956** (CMR) régit le transport international de marchandises par route entre États signataires. La lettre de voiture CMR en est le document d'exécution.

### Rôle juridique

- **Preuve du contrat** entre l'expéditeur et le transporteur
- **Reçu** de la marchandise (et de son état apparent)
- **Titre de transport** exigible par les autorités de contrôle

### Mentions obligatoires (article 6)

1. Lieu et date d'établissement
2. Nom et adresse de l'expéditeur
3. Nom et adresse du transporteur
4. Lieu et date de prise en charge
5. Lieu prévu de livraison
6. Nom et adresse du destinataire
7. Dénomination courante de la marchandise et mode d'emballage
8. Nombre de colis, marques et numéros
9. Poids brut ou quantité
10. Frais afférents au transport
11. Instructions pour les formalités de douane
12. Mention « transport soumis à la CMR »

### Les 3 exemplaires

- **Rouge** → expéditeur (preuve de prise en charge)
- **Bleu** → transporteur (titre de transport)
- **Vert** → destinataire (preuve de livraison)

Un 4ᵉ exemplaire est souvent conservé par l'entreprise.

### Réserves à la livraison

En cas de dommages apparents (emballages endommagés, colis manquants, marchandise abîmée), le destinataire doit porter sur la CMR des **réserves précises, motivées et datées**.

> « 3 cartons défoncés sur 15, marchandise visible, photos prises » ✅
> « Sous réserve » ou « colis endommagé » ❌ (trop vague → inopposables)

Sans réserves, **présomption de livraison conforme** (article 30 CMR).

### Délais de prescription

- **Pertes/avaries apparentes** : réserves à la livraison, action en justice dans l'année
- **Pertes/avaries non apparentes** : réserves écrites dans les **7 jours** (samedi, dimanche et jours fériés non compris)
- **Retard** : réserves dans les **21 jours**

## Transport intérieur : la LVM

Pour le transport national, c'est la **Lettre de Voiture Métropolitaine (LVM)** qui s'applique, régie par le Code des transports. Elle fonctionne de manière similaire mais avec des délais différents :
- Réserves à la livraison pour avaries apparentes
- **3 jours** (hors dimanches et jours fériés) pour les avaries non apparentes
$md$,
$md$**CMR** : preuve + reçu + titre. 3 exemplaires (rouge/bleu/vert). Réserves précises et motivées obligatoires. Délai 7 jours en international, 3 jours en national.$md$,
3
from modules m where m.slug='planification-tournees'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'optimisation-tournees', 'Optimisation des tournées et TMS',
$md$## Construire une tournée optimale

### Les contraintes à prendre en compte

- **Véhicule** : PTAC, volume utile, hauteur sous barres, hayon, frigo
- **Conducteur** : qualifications, temps disponibles restants
- **Client** : fenêtres horaires, équipements de quai, PMR
- **Marchandise** : compatibilité (frais/sec), gerbage, FIFO
- **Réglementation** : conduite continue, pauses, ADR, poids par essieu

### Les méthodes de construction

**Méthode du « plus proche voisin »** : depuis le dépôt, on ajoute le point le plus proche non encore servi, puis on recommence. Simple mais sous-optimale.

**Méthode de Clarke & Wright (savings)** : on calcule les économies réalisées en regroupant deux points sur une tournée. On privilégie les plus grosses économies.

**Algorithmes modernes (TMS)** : résolution du Vehicle Routing Problem (VRP) avec contraintes. Les TMS comme Shiptify, AnyTrack, PTV Route Optimiser, etc. proposent en quelques secondes des solutions impossibles à calculer manuellement.

### Bénéfices typiques d'un TMS

| Gain | Fourchette observée |
|------|---------------------|
| Kilomètres parcourus | −10 à −20 % |
| Temps de planification | −60 à −80 % |
| Taux de remplissage | +5 à +15 % |
| Taux de service | +2 à +5 pts |

## Le plan de transport

Document de pilotage hebdomadaire qui définit :
- Les **lignes régulières** (navette A→B tous les lundis)
- Les **rotations** (A→B→C→A avec fret retour)
- Les **ressources affectées** (véhicule, remorque, conducteur)
- Les **horaires cibles**

Un bon plan de transport minimise les kilomètres à vide et maximise l'utilisation des ressources. L'objectif est souvent un **taux de retour chargé > 80 %** sur les lignes principales.

## Groupage, dégroupage, messagerie

- **Lot complet (FTL)** : un seul client remplit le véhicule (franco de terminal à terminal)
- **Groupage (LTL)** : plusieurs expéditions combinées dans un même véhicule
- **Messagerie** : colis de moins de 3 t avec réseau de plateformes (Chronopost, DPD, Geodis…)

Le groupage impose plus de manutention mais améliore le taux de remplissage pour les faibles volumes.
$md$,
$md$**Optimisation** : PTAC + fenêtres + réglementation. Un TMS réduit les km de 10 à 20 %. Viser > 80 % de retours chargés sur les lignes.$md$,
4
from modules m where m.slug='planification-tournees'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'gestion-aleas', 'Gestion des aléas et des retards',
$md$## Typologie des aléas

Un plan de transport parfait n'existe pas : la fonction d'exploitation consiste aussi à **absorber les aléas** sans rompre le service.

### Aléas côté ressources

- **Panne véhicule** → véhicule de secours, dépannage, report tournée
- **Maladie conducteur** → intérim, réaffectation, sous-traitance
- **Crevaison, incident** → perte de 1 à 3 h en moyenne

### Aléas côté trafic / externe

- **Embouteillage, accident** → surveiller Waze/Sytadin, pré-alerter le client
- **Intempéries** (neige, verglas) → plans hiver, B1 sur pneus, interdictions PL
- **Grèves** (blocages, raffineries) → constituer des stocks de gazole

### Aléas côté client

- **Retard de chargement** chez l'expéditeur → notifier, décompter temps d'attente
- **Refus de livraison** → contacter le donneur d'ordre, retour en dépôt
- **Quai fermé / client absent** → seconde présentation, stockage temporaire

## Méthode de traitement

1. **Détecter** l'aléa le plus tôt possible (géoloc, alerte conducteur)
2. **Qualifier** : nature, durée estimée, impact client
3. **Décider** : réaffectation, sous-traitance, décalage, annulation
4. **Informer** le client de façon **proactive** (ne jamais laisser découvrir le retard)
5. **Documenter** : CRKM impacté, temps d'attente facturable, éventuel litige

## Temps d'attente et indemnités

Les **conditions générales de vente** prévoient généralement :
- Temps d'attente franc : 30 min
- Au-delà : facturation **horaire** (ex. 55 €/h selon CCV)
- Pour > 4 h d'attente : possibilité d'émettre un **bon pour accord** ou de repartir

## Indicateurs de maîtrise des aléas

- **Taux de service** : livraisons à l'heure / livraisons totales
- **Délai moyen de retard** en cas de retard
- **Taux de rupture** : tournées non effectuées / tournées prévues
- **Nombre de litiges** / 1000 livraisons

> La qualité du service client ne se juge pas quand tout va bien mais quand un aléa survient.
$md$,
$md$**Aléas** : détecter tôt, informer le client, documenter. Le temps d'attente est facturable au-delà du délai franc. Mesurer avec taux de service, retard moyen, taux de rupture.$md$,
5
from modules m where m.slug='planification-tournees'
on conflict (module_id, slug) do nothing;

-- =====================================================================
-- LEÇONS — MODULE 2 : RÉGLEMENTATION
-- =====================================================================

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'introduction', 'Introduction à la réglementation',
$md$## Panorama réglementaire

Le transport routier de marchandises est encadré par plusieurs strates :

- **National** : Code des transports, décrets d'application, LOTI, contrats types
- **Européen** : Règlements 561/2006 (temps de conduite), 1071/2009 (accès profession), 1072/2009 (accès marché)
- **International** : CMR, ADR (matières dangereuses), AETR (pays non-UE), ATP (périssables)

## L'accès à la profession (règlement 1071/2009)

Pour exercer, l'entreprise doit satisfaire **4 conditions cumulatives** :

1. **Honorabilité professionnelle** du gestionnaire de transport (extrait de casier B2 vierge des infractions listées)
2. **Capacité financière** : 9 000 € pour le 1er véhicule, 5 000 € par véhicule supplémentaire (> 3,5 t)
3. **Capacité professionnelle** : attestation de capacité obtenue par examen ou équivalence (bac +2 transport, 10 ans d'expérience)
4. **Établissement stable** en France (locaux, matériels, documents)

Le respect de ces conditions est vérifié par la **DREAL**, qui délivre la **licence de transport** :
- **Licence communautaire** (> 3,5 t) : transports nationaux et internationaux
- **Licence de transport intérieur** (≤ 3,5 t, VUL, messagerie légère)

## L'ADR (matières dangereuses)

L'Accord européen ADR (Accord relatif au transport international des marchandises Dangereuses par Route) classe les matières en **9 classes** :

| Classe | Nature |
|--------|--------|
| 1 | Matières et objets explosibles |
| 2 | Gaz |
| 3 | Liquides inflammables |
| 4 | Matières solides inflammables |
| 5 | Matières comburantes et peroxydes |
| 6 | Matières toxiques et infectieuses |
| 7 | Matières radioactives |
| 8 | Matières corrosives |
| 9 | Matières et objets dangereux divers |

### Obligations transporteur

- **Formation** du conducteur (attestation ADR 5 ans)
- **Équipement** du véhicule (2 extincteurs, signalisation orange, cales, gilets…)
- **Document de transport ADR** (n° ONU, désignation officielle, classe, groupe d'emballage)
- **Conseiller à la sécurité** obligatoire pour les entreprises concernées
- **Consignes écrites** remises au conducteur, dans la langue qu'il comprend

### Seuils d'exemption (1.1.3.6)

Les "petites quantités" sont dispensées des obligations les plus lourdes. Ex. : 1 000 points pour la catégorie de transport 3 (gazole, fuel).
$md$,
$md$**Accès profession** : honorabilité, 9 000 €, attestation de capacité, établissement. **ADR** : 9 classes, formation conducteur, conseiller sécurité, consignes écrites.$md$,
1
from modules m where m.slug='reglementation-transport'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'contrats-types', 'Contrats types de transport',
$md$## Rôle des contrats types

Les **contrats types** s'appliquent **de plein droit** en l'absence de convention écrite entre les parties (article L. 1432-2 du Code des transports). Ils fixent les droits et obligations par défaut.

## Les principaux contrats types

- **Contrat type général** (décret 99-269 modifié) : transport public de marchandises
- **Contrat type sous-traitance** : relations entre opérateurs
- **Contrat type location** : location de véhicule avec conducteur
- **Contrats spécialisés** : citernes, frigo, déménagement, fonds et valeurs, matières dangereuses, vrac…

## Points clés du contrat type général

### Délais de mise à disposition et d'enlèvement

- Masse ≤ 3 t : 30 min cumulées (chargement + déchargement)
- Masse > 3 t : variable selon poids (barème dans le contrat type)

### Indemnisation des pertes et avaries

- **Pertes totales ou partielles** : au poids réel, dans la limite de **14 €/kg** (contrat type général) ou 23 € DTS/kg (CMR international)
- **Retard** : réparé dans la limite du **prix du transport**
- Exclusions : vice propre, force majeure, faute de l'expéditeur

### Déclaration de valeur

L'expéditeur peut déclarer une **valeur supérieure** aux plafonds légaux. Cela engage le transporteur au-delà des plafonds mais entraîne une surtaxe et nécessite souvent une assurance ad valorem.

### Intérêt spécial à la livraison

L'expéditeur peut fixer un montant représentant l'intérêt qu'il attache à la livraison dans les délais. Règle identique : surtaxe et assurance.

## Contrat type sous-traitance

Encadre la relation **donneur d'ordre / sous-traitant**. Points clés :

- **Prix** : rémunération couvrant l'ensemble des charges (carburant, péages, charges sociales…)
- **Délai de paiement légal** : 30 jours à compter de la date d'émission de la facture (L. 441-10 Code de commerce pour le transport)
- **Action directe** (L. 132-8 C. com.) : le transporteur a une action directe en paiement contre l'expéditeur et le destinataire en cas de défaillance du commissionnaire

> L'action directe est **d'ordre public** : on ne peut y déroger par contrat.
$md$,
$md$**Contrats types** : s'appliquent à défaut d'écrit. Indemnisation 14 €/kg (national), 23 DTS/kg (CMR). Action directe L. 132-8 : paiement garanti.$md$,
2
from modules m where m.slug='reglementation-transport'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'responsabilite-transporteur', 'Responsabilité du transporteur',
$md$## Principe : une obligation de résultat

Le transporteur est tenu à une **obligation de résultat** : livrer la marchandise au lieu prévu, dans les délais, en bon état. En cas de manquement, sa responsabilité est **présumée**.

## Les cas d'exonération

Le transporteur n'est exonéré que s'il prouve :

- **La force majeure** : événement imprévisible, irrésistible, extérieur
- **Le vice propre** de la marchandise (ex. fruits sur-mûrs)
- **La faute de l'expéditeur** (mauvais emballage, erreur d'adresse, mauvais arrimage)
- **La faute du destinataire**
- **Un vice caché du véhicule** reconnu impossible à détecter (rare)

Les grèves ne sont **pas automatiquement** de la force majeure (jurisprudence au cas par cas).

## Plafonds légaux d'indemnisation

| Régime | Plafond |
|--------|---------|
| National < 3 t (envoi) | 23 € / kg manquant ou avarié (ou 750 € par envoi si plus favorable) |
| National ≥ 3 t | 14 € / kg (plafond 2 300 € / t) |
| CMR international | 8,33 DTS / kg (≈ 10 €/kg) |
| Retard | Prix du transport |

DTS = Droit de Tirage Spécial (FMI), environ 1,20 € en 2024.

## Dol ou faute lourde

Les plafonds **sautent** si le transporteur a commis :
- Un **dol** (faute intentionnelle)
- Une **faute lourde** (comportement d'une gravité exceptionnelle)

Exemple : vol de marchandise par le conducteur qui s'endort sur un parking non gardé → faute lourde possible.

## Déclaration de sinistre

- Constater immédiatement les dommages
- Porter des **réserves motivées** sur la lettre de voiture / CMR
- Informer le transporteur par écrit dans les délais :
  - **Apparents** : à la livraison
  - **Non apparents** : 3 j national, 7 j international
- Conserver **tous les justificatifs** (factures, photos, constats)
- Chiffrer le préjudice : coût d'achat HT + éventuels frais

## Assurances

- **RC Contractuelle transporteur** : obligatoire, couvre jusqu'au plafond légal
- **Assurance Ad Valorem / Faculté** : couvre la valeur réelle (à la charge de l'expéditeur ou du commissionnaire)
- **RC Exploitation** : dommages causés aux tiers en dehors du contrat
$md$,
$md$**Présomption** de responsabilité du transporteur. Exonération : force majeure, vice propre, faute expé/dest. Plafond 14 €/kg (national), 8,33 DTS/kg (CMR). Sautent en cas de dol/faute lourde.$md$,
3
from modules m where m.slug='reglementation-transport'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'cabotage-international', 'Cabotage et transport international',
$md$## Le cabotage (règlement 1072/2009)

Le **cabotage** consiste à réaliser des transports **intérieurs dans un pays** autre que celui d'immatriculation du véhicule.

### Règles applicables (en 2024)

- **Maximum 3 opérations** de cabotage consécutives dans un pays
- **Dans les 7 jours** suivant un transport international déchargé dans ce pays
- Ou **1 opération** dans chaque pays de transit, sous 3 jours

### Paquet Mobilité (applicable progressivement)

- **Période de carence** : après 3 opérations, attendre **4 jours** avant un nouveau cabotage dans le même pays
- **Retour au pays d'établissement** : obligatoire toutes les **8 semaines** pour chaque véhicule
- **Tachygraphe intelligent V2** obligatoire

### Documents à bord

- Licence communautaire originale
- Copies conformes pour les autres véhicules
- CMR ou LVM pour chaque opération de cabotage
- Preuves des transports internationaux antérieurs

### Sanctions

Cabotage illégal : jusqu'à **15 000 €** et immobilisation du véhicule.

## Transport international : les documents

### Cas général

- **CMR** : contrat de transport
- **Facture commerciale** : valeur, Incoterms
- **Liste de colisage** (packing list)
- **Document douanier** : DAU (Document Administratif Unique) si hors UE, T1 / T2 (transit communautaire)

### Marchandises spécifiques

- **ADR** : consignes écrites, document de transport
- **ATP** (frais) : attestation ATP du véhicule
- **Animaux vivants** : certificats sanitaires, plan de marche
- **Déchets** : notification préalable selon règlement 1013/2006

## Incoterms 2020

Règles internationales définissant qui (vendeur ou acheteur) prend en charge le transport, l'assurance, les formalités. 11 termes, les plus fréquents :

| Incoterm | Transport | Douane export | Douane import |
|----------|-----------|--------------|--------------|
| EXW | Acheteur | Acheteur | Acheteur |
| FCA | Acheteur | Vendeur | Acheteur |
| CPT / CIP | Vendeur (hors risques) | Vendeur | Acheteur |
| DAP / DPU | Vendeur | Vendeur | Acheteur |
| DDP | Vendeur | Vendeur | Vendeur |

Le GOTRM doit savoir lire un Incoterm pour comprendre **qui supporte quoi** dans la chaîne logistique.
$md$,
$md$**Cabotage** : 3 opérations en 7 j + carence 4 j (Paquet Mobilité). **International** : CMR + facture + packing list + douane. Incoterms = répartition des responsabilités.$md$,
4
from modules m where m.slug='reglementation-transport'
on conflict (module_id, slug) do nothing;

-- =====================================================================
-- LEÇONS — MODULE 3 : RELATION CLIENT
-- =====================================================================

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'contrat-transport', 'Le contrat de transport',
$md$## Définition (art. L. 1432-2 C. des transports)

Le **contrat de transport** lie trois acteurs :

- L'**expéditeur** (donneur d'ordre), qui remet la marchandise
- Le **transporteur**, qui l'achemine
- Le **destinataire**, à qui elle est remise

Le destinataire n'est pas signataire, mais il **adhère** au contrat à la livraison (peut exercer des réserves).

## Commissionnaire vs transporteur

- **Transporteur** : exécute matériellement le déplacement (moyens propres)
- **Commissionnaire de transport** : organise en son nom mais pour le compte du client, en choisissant librement les moyens (routier, fer, mer, aérien, sous-traitants)

Le commissionnaire a une obligation de résultat et répond des faits de ses sous-traitants (art. L. 132-5 C. com.).

## Les 9 mentions obligatoires (LVM)

1. Date de rédaction
2. Noms et adresses expéditeur, destinataire, transporteur
3. Lieu et date de prise en charge
4. Lieu prévu de livraison
5. Nature et poids / volume de la marchandise
6. Nombre d'objets et marques d'identification
7. Prix du transport et frais accessoires
8. Instructions particulières (température, ADR…)
9. Conditions d'exécution (délais, franchise…)

## Phases du contrat

1. **Commande** : oralement ou par écrit, puis confirmée
2. **Prise en charge** : signature LVM/CMR
3. **Acheminement** : sous la responsabilité du transporteur
4. **Livraison** : remise au destinataire, signature, réserves éventuelles
5. **Paiement** : 30 jours max (L. 441-10 C. com.)

## Conditions Générales de Vente (CGV)

Les CGV du transporteur régissent les points non couverts par le contrat type :
- Modalités de paiement (acompte, délais, pénalités)
- Temps d'attente francs et surcharges horaires
- Frais de second passage, de retour
- Modalités de litiges (tribunal compétent, prescription 1 an)

> Les CGV ne peuvent être opposées que si elles ont été **portées à la connaissance du client** avant la commande.
$md$,
$md$**3 parties** : expéditeur, transporteur, destinataire. Le commissionnaire organise, le transporteur exécute. Paiement 30 j. Prescription transport = 1 an.$md$,
1
from modules m where m.slug='relation-client'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'reclamations-litiges', 'Réclamations et litiges',
$md$## Typologie des litiges transport

- **Avaries** : marchandise endommagée
- **Pertes** : totale ou partielle
- **Retards** : dépassement des délais convenus
- **Non-respect des conditions** : température, arrimage, fenêtres horaires
- **Litiges administratifs** : erreurs de facturation, bordereaux manquants

## Procédure à la livraison

1. **Inspection visuelle** du destinataire
2. **Réserves** si besoin : précises, motivées, datées, signées **contradictoirement** par le conducteur
3. **Photos** de l'état des colis et de la marchandise
4. Si litige grave : **constat d'huissier** ou **expertise amiable**
5. Confirmation écrite au transporteur dans les délais (3 j national / 7 j CMR)

## Traitement d'une réclamation

### Étape 1 — Accusé de réception (sous 48 h)

> « Nous accusons réception de votre réclamation du [date] concernant [n° LV/CMR]. Nous l'étudions et revenons vers vous sous 15 jours. »

### Étape 2 — Instruction (sous 15 j)

- Vérifier les faits : LVM/CMR, réserves, preuves
- Interroger le conducteur, consulter les données tachygraphe, géoloc
- Quantifier le préjudice et chiffrer l'indemnité dans les plafonds légaux

### Étape 3 — Proposition d'accord

- Indemnité dans la limite du plafond
- Éventuel geste commercial (remise sur transport futur)
- Procès-verbal de règlement amiable signé

### Étape 4 — Médiation / contentieux

En cas d'échec : médiateur des entreprises, tribunal de commerce (prescription 1 an).

## Indicateurs de suivi

- **Taux de litiges** : nombre de litiges / 1000 livraisons — cible < 2 ‰
- **Délai moyen de traitement** : cible < 15 jours
- **Coût des litiges** : montant indemnisé / CA
- **Taux de récidive** (même client / même type) : signal d'alerte qualité

## Prévention

- Photos systématiques au chargement et à la livraison
- Formation réserves à tous les conducteurs
- Emballage adapté : jamais transporter si emballage manifestement insuffisant → réserves à la prise en charge
- Arrimage conforme (EN 12195-1)
$md$,
$md$**Litige** : réserves précises, datées, signées. AR sous 48h, réponse sous 15 j. Plafond légal ou accord amiable. KPI : taux de litige < 2 ‰.$md$,
2
from modules m where m.slug='relation-client'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'qualite-service', 'Qualité de service et satisfaction client',
$md$## La qualité perçue

La qualité d'un service de transport se mesure sur **5 dimensions** (modèle SERVQUAL adapté) :

- **Fiabilité** : respect des délais promis
- **Réactivité** : capacité à traiter les demandes et aléas
- **Sécurité** : marchandise intacte, conducteur professionnel
- **Information** : suivi, preuves, communication proactive
- **Empathie** : écoute, personnalisation

## Les engagements type

| Indicateur | Engagement |
|------------|------------|
| Taux de service on-time-in-full (OTIF) | ≥ 98 % |
| Taux de casse / perte | ≤ 0,2 % |
| Accusé de réception commande | < 2 h |
| Retour POD (preuve de livraison) | J+1 |
| Délai de traitement réclamation | < 15 j |

## Les outils de fidélisation

- **Rendez-vous périodiques** (QBR = Quarterly Business Review)
- **Reporting mensuel** : KPI, litiges, actions correctives
- **Enquête satisfaction** annuelle (NPS = Net Promoter Score)
- **Co-construction** : projets communs (démarche verte, digitalisation POD)

## Digitalisation de la preuve de livraison (e-POD)

L'**e-POD** (signature électronique) remplace progressivement le bon papier. Avantages :
- Retour immédiat (vs J+2 en papier)
- Réserves tracées avec photo
- Facturation plus rapide
- Base de données exploitable

## Démarche d'amélioration continue

Méthode **PDCA** (Plan – Do – Check – Act) :

1. **Plan** : identifier un problème récurrent (ex. retards sur le client X)
2. **Do** : mettre en place une action (nouvelle fenêtre de livraison)
3. **Check** : mesurer sur 1 mois
4. **Act** : ancrer si positif, ajuster sinon

## Certifications qualité transport

- **ISO 9001** : système de management de la qualité (générique)
- **SQAS** : Safety & Quality Assessment for Sustainability (chimie)
- **IFS / BRC Logistic** : alimentaire
- **OEA** : Opérateur Économique Agréé (douane, sécurité)
$md$,
$md$**Qualité** : 5 dimensions (fiabilité, réactivité, sécurité, info, empathie). KPI phare : OTIF ≥ 98 %. e-POD, QBR, PDCA pour progresser. Certifications : ISO 9001, SQAS, IFS, OEA.$md$,
3
from modules m where m.slug='relation-client'
on conflict (module_id, slug) do nothing;

-- =====================================================================
-- LEÇONS — MODULE 4 : APPELS D'OFFRES
-- =====================================================================

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'cahier-charges', 'Cahier des charges et dossier d''appel d''offres',
$md$## Pourquoi un appel d'offres ?

Les chargeurs lancent des appels d'offres pour :
- **Optimiser les coûts** (mise en concurrence)
- **Sécuriser les capacités** sur 1 à 3 ans
- **Sélectionner** des partenaires fiables
- **Se conformer** à leurs obligations (code des marchés publics, gouvernance)

## Structure d'un DCE (Dossier de Consultation des Entreprises)

1. **Règlement de consultation** : procédure, critères, délais, confidentialité
2. **Cahier des charges techniques (CCTP)** : description du besoin
3. **CCAP** (conditions administratives) : obligations, pénalités, durée
4. **Annexes chiffrées** : volumes, origines/destinations, tarifs cible
5. **Modèle de grille tarifaire** à compléter

## Points clés du CCTP

- **Volumétrie** : nombre d'envois, poids, m³, LDM (mètres de plancher)
- **Origines / Destinations** : zones postales, liste de sites
- **Fréquences** : quotidienne, hebdomadaire, ponctuelle
- **Contraintes** : hayon, frigo, ADR, livraisons de nuit…
- **SLA** (Service Level Agreement) : OTIF attendu, pénalités

## La grille tarifaire

Format typique : **tranches de poids × zones**.

| Zone / tranche | 1–100 kg | 101–500 kg | 501–1000 kg | > 1t (€/100 kg) |
|---|---|---|---|---|
| Z1 (< 100 km) | 42 € | 78 € | 115 € | 9,20 € |
| Z2 (100–300 km) | 58 € | 110 € | 165 € | 13,50 € |
| Z3 (> 300 km) | 85 € | 162 € | 240 € | 19,80 € |

Autres formats : **€/km**, **€/tonne-km**, **forfait par envoi**, **à l'heure**.

## Calendrier type

| Étape | Délai |
|-------|-------|
| Publication DCE | J0 |
| Questions / réponses | J+15 |
| Remise des offres | J+30 |
| Audition finalistes | J+45 |
| Attribution | J+60 |
| Démarrage contrat | J+90 |

## Obligations du candidat

- **Respect strict** du format (sinon élimination)
- **Cohérence** du tarif proposé avec le CRKM
- **Références clients** similaires
- **Certifications** (ISO, SQAS, OEA…)
- **Attestations** URSSAF, fiscale, assurances, licence de transport
$md$,
$md$**DCE** = règlement + CCTP + CCAP + grille. Analyser : volumes, fréquences, SLA. Ne jamais répondre hors format. Anticiper 2-3 mois entre publication et démarrage.$md$,
1
from modules m where m.slug='appels-offres'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'evaluation-transporteurs', 'Évaluation et sélection des transporteurs',
$md$## Les critères de sélection

L'analyse d'une offre ne se limite pas au prix. Une pondération classique :

| Critère | Poids | Sous-critères |
|---------|------:|---------------|
| Prix | 40 % | Grille, révision, options |
| Qualité | 25 % | OTIF historique, certifications |
| Capacité | 15 % | Flotte, sous-traitants, backup |
| RSE | 10 % | Euro VI, GNV, scope 1-2-3 |
| Solidité financière | 10 % | CA, résultats, score Altares |

## Analyse financière

- **Chiffre d'affaires** : minimum 3× le montant du marché attendu
- **Résultat net** : positif 3 ans, marge opérationnelle > 2 %
- **Ratios de liquidité** : BFR, endettement
- **Score de défaillance** (Altares, Ellisphere) : A, B, C…

Un transporteur en difficulté financière est un risque majeur (défaillance en pleine saison).

## Audit opérationnel

Avant attribution, le chargeur peut organiser une **visite site** :
- Nombre de quais, parc véhicules, âge moyen
- TMS, tracking temps réel, WMS
- Formation conducteurs, ADR, FCO à jour
- Ambiance, propreté, sécurité

## Scoring des réponses

Mise en équation simple : **score = Σ (note × poids)**.

Exemple :
- Transporteur A : prix 16/20, qualité 18/20, capacité 15/20, RSE 14/20, finance 17/20
- Score = 16×0,4 + 18×0,25 + 15×0,15 + 14×0,1 + 17×0,1 = **16,25 / 20**

## Négociation

Après analyse, le chargeur peut :
- **Shortlister** 2-3 candidats
- **Auditionner** (présentation 1-2 h)
- **Négocier** : prix, durée, pénalités, clauses de révision
- **Contractualiser** : signature contrat cadre

## Pièges à éviter

- ❌ Prix trop bas : risque de défaillance, dumping social
- ❌ Dépendance à un seul transporteur (> 70 % du volume)
- ❌ Absence de clause de révision carburant → inflation non répercutée
- ❌ Pénalités irréalistes (non applicables juridiquement)
$md$,
$md$**Sélection** = prix (40 %) + qualité (25 %) + capacité (15 %) + RSE (10 %) + finance (10 %). Vérifier solidité financière, auditer site, négocier clause carburant.$md$,
2
from modules m where m.slug='appels-offres'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'contractualisation', 'Contractualisation et clauses clés',
$md$## Le contrat cadre

Formalise la relation sur la **durée** (souvent 1 à 3 ans). Il intègre :

- Objet, périmètre, volumes estimés (non engageants)
- **Grille tarifaire** annexée
- **Clause de révision** carburant, salaires, péages
- **SLA** et **pénalités**
- **Durée**, renouvellement, résiliation
- **Confidentialité**, propriété des données
- **RSE**, éthique, compliance

## Clause de révision carburant

Obligatoire pour les contrats de plus de 3 mois (art. L. 3222-1 C. transports).

Formule type CNR :
`P1 = P0 × (1 + k × (I1 − I0) / I0)`

- P0 = prix initial
- k = part du gazole dans le prix (en général 20 à 30 %)
- I = indice gazole CNR

Révision mensuelle ou trimestrielle.

## Pénalités

| Événement | Pénalité type |
|-----------|--------------|
| Retard de livraison | 5 à 10 % du prix du transport |
| Casse / perte | Plafond légal ou valeur déclarée |
| Absence POD J+2 | Forfait 10 à 30 € |
| Non-conformité froid | 100 % + remboursement marchandise |
| OTIF < 95 % (mensuel) | Malus 2 à 5 % du CA |

Les pénalités doivent être **proportionnées** (sinon clause réputée non écrite).

## Durée et sortie

- **Durée initiale** : 1 an reconductible ou 3 ans fermes
- **Préavis de résiliation** : 3 mois usuel
- **Résiliation pour faute** : mise en demeure + délai 30 j
- **Clause de réversibilité** : données, remise d'actifs, transition

## Gouvernance

Un bon contrat prévoit :
- **Comité de pilotage** trimestriel (QBR)
- **Reporting mensuel** standardisé
- **Plan de progrès** (amélioration continue)
- **Procédure de gestion de crise**

## Clause RSE

De plus en plus fréquente :
- Engagement flotte Euro VI / Crit'Air 1-2
- Scope 1 & 2 communiqué mensuellement (calcul CO₂ transport)
- Objectifs de réduction (ex. −20 % CO₂ / t·km en 3 ans)
- Audit social sous-traitants
$md$,
$md$**Contrat cadre** : 1–3 ans, grille annexée, clause révision carburant **obligatoire**. Pénalités proportionnées. Prévoir QBR, reporting, réversibilité et clause RSE.$md$,
3
from modules m where m.slug='appels-offres'
on conflict (module_id, slug) do nothing;

-- =====================================================================
-- LEÇONS — MODULE 5 : SUIVI SOUS-TRAITANTS
-- =====================================================================

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'kpi-sous-traitants', 'KPI et indicateurs de performance',
$md$## Pourquoi piloter les sous-traitants ?

Dans le transport, la sous-traitance peut représenter **40 à 80 %** du volume traité. Sans pilotage fin, le chargeur subit les dérives qualité et coûts.

## Les KPI incontournables

### Qualité de service

- **Taux de service (OTIF)** : livraisons conformes / total — cible ≥ 98 %
- **Taux de casse/perte** : sinistres / envois — cible ≤ 0,2 %
- **Taux de POD J+1** : preuves retournées à J+1 — cible ≥ 95 %
- **Taux de litiges** : litiges / 1000 envois — cible < 2 ‰

### Productivité

- **Délai d'acheminement moyen** : temps transit en heures
- **Taux de remplissage** véhicule
- **Taux de refus** de commande

### Conformité

- **% FCO valides** sur les conducteurs
- **% Euro VI** sur la flotte engagée
- **Attestations URSSAF / fiscales** à jour

## Modèle de tableau de bord

| Transporteur | Volume (€) | OTIF | Casse | POD J+1 | Litiges | Score |
|--------------|-----------:|-----:|------:|--------:|--------:|------:|
| Alpha | 120 k€ | 99,1 % | 0,08 % | 97 % | 1,2 ‰ | A |
| Bravo | 85 k€ | 97,4 % | 0,14 % | 92 % | 2,8 ‰ | B |
| Charlie | 62 k€ | 94,8 % | 0,35 % | 85 % | 5,1 ‰ | C |

Codes couleur : A (vert, > 95 % pondéré), B (orange, 85–95 %), C (rouge, < 85 %).

## Fréquence de revue

- **Hebdomadaire** : performance opérationnelle, incidents
- **Mensuelle** : KPI consolidés, plan d'action
- **Trimestrielle (QBR)** : bilan, projets communs, engagements
- **Annuelle** : renégociation, renouvellement, remise en concurrence

## Gestion des dérives

1. **Alerte** dès 2 mois consécutifs sous seuil
2. **Plan de progrès** écrit avec objectifs chiffrés et deadlines
3. **Mise en demeure** si absence de progression
4. **Dégradation de volume** ou résiliation

Traçabilité indispensable : emails, comptes rendus de QBR, courriers AR.
$md$,
$md$**KPI** sous-traitants : OTIF ≥ 98 %, casse ≤ 0,2 %, POD J+1 ≥ 95 %, litiges < 2 ‰. Revues hebdo / mensuel / trimestriel. Plan de progrès si dérive.$md$,
1
from modules m where m.slug='suivi-sous-traitants'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'audits-conformite', 'Audits et conformité',
$md$## Objectifs d'un audit sous-traitant

- **Vérifier la conformité** réglementaire et contractuelle
- **Valider la capacité opérationnelle** (flotte, personnel, process)
- **Identifier les risques** RH, financiers, environnementaux
- **Construire un plan de progrès** partagé

## Périodicité

- **Audit initial** : avant attribution du marché
- **Audit de suivi** : annuel, ou en cas de dérive KPI
- **Audit flash** : ponctuel, sur site, sans préavis

## Check-list d'audit (extrait)

### Volet réglementaire

- [ ] Licence de transport valide (copie conforme à bord)
- [ ] Attestations URSSAF, fiscales, AT/MP récentes
- [ ] Attestations assurance RC transporteur, marchandises
- [ ] FCO valide pour tous les conducteurs (5 ans)
- [ ] FIMO pour les nouveaux entrants
- [ ] ADR si concerné, conseiller à la sécurité
- [ ] Tachygraphes téléchargés 90 j (véhicule) / 28 j (conducteur)

### Volet opérationnel

- [ ] TMS, outil de tracking, liens EDI
- [ ] Procédure POD, e-POD
- [ ] Procédure gestion des réclamations
- [ ] Formation conducteurs (safety, eco-conduite)
- [ ] Parc véhicules : âge moyen, Crit'Air

### Volet social

- [ ] Contrats de travail conformes CCN
- [ ] Salaires au moins conventionnels
- [ ] Absence de travail dissimulé (vigilance renforcée)
- [ ] Représentation du personnel

### Volet financier

- [ ] K-bis récent
- [ ] Bilans 3 derniers exercices
- [ ] Score de défaillance

## Le devoir de vigilance

Depuis la loi 2017-399, les donneurs d'ordre ont un **devoir de vigilance** sur leurs sous-traitants en matière de :
- Droits humains et libertés fondamentales
- Santé et sécurité des personnes
- Environnement

Les entreprises > 5 000 salariés doivent publier un **plan de vigilance**.

Conséquence pratique : documenter l'audit social et le suivi.

## Non-conformité détectée : que faire ?

1. **Mineure** : action corrective sous 30 j, pas d'impact volume
2. **Majeure** : suspension des nouvelles affectations, plan sous 15 j
3. **Critique** : arrêt immédiat, contentieux si besoin

Traçabilité : rapport d'audit signé, plan d'action, suivi.
$md$,
$md$**Audit** = initial + annuel + flash. Check-list : réglementaire + opérationnel + social + financier. **Devoir de vigilance** : documenter. Non-conformité critique → arrêt immédiat.$md$,
2
from modules m where m.slug='suivi-sous-traitants'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'litiges-sous-traitance', 'Gestion des litiges sous-traitance',
$md$## Typologie des litiges

- **Opérationnels** : retards, casse, refus de charger
- **Administratifs** : PO retournés, factures erronées
- **Financiers** : impayés, retenues de garantie
- **Légaux** : travail dissimulé, URSSAF, défaillance

## L'action directe (L. 132-8 C. com.)

Règle fondamentale : le **transporteur effectif** (sous-traitant) a une **action directe en paiement** contre :
- L'**expéditeur** (chargeur)
- Le **destinataire**

…en cas de défaillance du commissionnaire / donneur d'ordre.

Conséquence : si l'affréteur fait faillite, le chargeur peut devoir **payer deux fois** (d'où l'intérêt d'assurances et garanties).

## Travail dissimulé et responsabilité solidaire

Art. L. 8222-1 et suivants C. travail : le donneur d'ordre est **solidairement responsable** du paiement des impôts, taxes et cotisations sociales dues par son sous-traitant si celui-ci a recours au travail dissimulé.

**Obligation de vigilance** pour les contrats > 5 000 € HT : demander et vérifier tous les 6 mois :
- Attestation de vigilance URSSAF
- K-bis < 3 mois
- Liste nominative des salariés étrangers

## Résolution amiable

1. **Rencontre physique** ou call : toujours privilégier
2. **Proposition d'accord** chiffrée et écrite
3. **Protocole transactionnel** signé (art. 2044 C. civ.)
4. **Médiation** des entreprises (gratuite, confidentielle)

## Procédure judiciaire

Si l'amiable échoue :
- **Injonction de payer** (créance certaine, liquide, exigible)
- **Tribunal de commerce** : compétent entre professionnels
- **Prescription** : 1 an pour le contrat de transport

## Prévention des litiges

- **Contrat de sous-traitance écrit** systématique
- **Conditions de paiement** claires (30 j fin de mois)
- **POD électronique** obligatoire à J+1
- **Portail sous-traitant** pour dématérialiser les échanges
- **Cautionnement** pour les gros volumes
$md$,
$md$**Action directe** L. 132-8 : le sous-traitant peut poursuivre le chargeur. **Responsabilité solidaire** travail dissimulé : vérifier attestations tous les 6 mois. Prescription transport = 1 an.$md$,
3
from modules m where m.slug='suivi-sous-traitants'
on conflict (module_id, slug) do nothing;

-- =====================================================================
-- LEÇONS — MODULE 6 : COÛT DE REVIENT
-- =====================================================================

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'crkm-calcul', 'Calcul du coût de revient kilométrique',
$md$## Le CRKM, outil central de pilotage

Le **Coût de Revient Kilométrique** mesure ce que coûte 1 km roulé par un véhicule. Indispensable pour :

- Établir des **tarifs** cohérents
- Comparer les véhicules, les tournées
- **Négocier** avec sous-traitants et clients
- Identifier les postes à optimiser

## Structure du coût

### Charges fixes (indépendantes des km)

- **Amortissement** du véhicule (6 à 8 ans)
- **Assurances** (RC, dommages, marchandise)
- **Taxe à l'essieu** (TSVR)
- **Frais de structure** : administration, commercial, informatique
- **Salaire conducteur** (part fixe : 151,67 h base)
- **Visite technique**, contrôles obligatoires

### Charges variables (proportionnelles aux km)

- **Carburant** (poste n°1 : ~30 à 35 %)
- **Pneumatiques**
- **Entretien / réparations**
- **Péages**
- **AdBlue**
- Partie variable du salaire (frais de route, primes)

## La formule

`CRKM = (Charges fixes annuelles / Km parcourus annuels) + Charges variables au km`

On peut aussi raisonner en **coût horaire** pour les activités à forte attente (déménagement, messagerie urbaine) :
`CRK horaire = Charges fixes / Heures travaillées`

## Exemple chiffré (tracteur 40 t)

Véhicule roulant 120 000 km/an, 230 jours actifs :

| Poste | Montant annuel |
|-------|---------------:|
| Amortissement tracteur + remorque | 18 000 € |
| Assurance | 6 500 € |
| Taxe essieu | 450 € |
| Frais de structure | 12 500 € |
| Salaire + charges conducteur | 52 000 € |
| **Total fixe** | **89 450 €** |
| Carburant (30 L/100 × 1,55 €) | 55 800 € |
| Pneus (0,035 €/km) | 4 200 € |
| Entretien | 8 400 € |
| Péages (0,11 €/km) | 13 200 € |
| AdBlue | 1 100 € |
| **Total variable** | **82 700 €** |
| **TOTAL** | **172 150 €** |

**CRKM** = 89 450 / 120 000 + 82 700 / 120 000 = 0,745 + 0,689 = **1,43 €/km**

Pour un AR Paris-Marseille (1 580 km) → coût direct **≈ 2 260 €**. Tarif client = coût direct × (1 + marge) + frais généraux.

## Coût horaire

Avec 230 j × 9 h = 2 070 h utiles :
Coût horaire = 172 150 / 2 070 = **83,2 €/h**

Utile pour les devis d'attente ou d'affrètement court.
$md$,
$md$**CRKM** = (charges fixes / km) + charges variables /km. Carburant = 30-35 % du total. Pour un 40 t, CRKM réel = 1,30 à 1,50 €/km selon activité.$md$,
1
from modules m where m.slug='cout-revient'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'analyse-comparative', 'Analyse comparative et devis',
$md$## Analyser un devis client

Pour établir un tarif de transport, on part du CRKM auquel on ajoute :

1. **Marge commerciale** : 8 à 15 % selon activité
2. **Frais commerciaux** : 2 à 5 %
3. **Risque litige / impayé** : 1 à 3 %

`Prix de vente = CRKM × km × (1 + marge + frais + risque)`

## Méthode des postes de coût (CNR)

Le **Comité National Routier** publie mensuellement des **indices** détaillés par activité :

- **Longue distance 40 t** : 53 % variable, 47 % fixe
- **Régional 40 t** : 48 / 52
- **Messagerie VUL** : 40 / 60
- **Location longue durée** : 30 / 70

## Indicateur de rentabilité : seuil de rentabilité

Point mort = charges fixes annuelles / (prix moyen km − charges variables km)

Exemple : charges fixes 89 450 €, marge unitaire 0,60 €/km
Point mort = 89 450 / 0,60 = **149 083 km**

Le véhicule doit rouler > 149 083 km pour couvrir ses fixes.

## Comparaison véhicule propre vs sous-traitance

| Critère | Flotte propre | Sous-traitance |
|---------|---------------|----------------|
| Coût | 1,35–1,45 €/km | 1,45–1,70 €/km |
| Flexibilité | Faible | Forte |
| Contrôle qualité | Fort | Moyen |
| Charge CAPEX | Élevée | Nulle |
| Risque social | Élevé (conflits) | Transféré |
| Image / marque | Fort | Moindre |

Arbitrage classique : **80 % flotte propre + 20 % sous-traitance** pour absorber les pics.

## Cas pratique — devis

Un client demande un tarif pour un AR Paris → Lyon → Paris de **940 km** avec retour **à vide**, frigo −5 °C.

- CRKM frigo longue distance : 1,55 €/km
- Marge 12 %, frais 3 %, risque 2 % → coefficient 1,17
- Prix direct : 940 × 1,55 = 1 457 €
- Prix de vente : 1 457 × 1,17 = **1 705 € HT**

Si retour chargé à 80 %, prix de revient effectif partagé → tarif possible 1 250 € HT sur ce trajet.
$md$,
$md$**Prix de vente** = CRKM × km × (1 + marge + frais + risque). Indices CNR pour valider la structure. Point mort = fixes / marge unitaire. Retour chargé change tout.$md$,
2
from modules m where m.slug='cout-revient'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'indices-revision', 'Indices et révision des prix',
$md$## Pourquoi une clause de révision ?

Les contrats de transport durent en général 1 à 3 ans. Les **charges évoluent** (gazole, salaires, péages). Sans clause, le transporteur subit l'inflation.

## Obligation légale (art. L. 3222-1)

Pour tout contrat > 3 mois, **la répercussion du gazole est de plein droit** : le prix facturé doit être ajusté en fonction des variations du prix du gazole professionnel.

## Formule CNR standard

`P_n = P_0 × ( 1 + k × (I_n − I_0) / I_0 )`

- P_0 = prix initial
- P_n = prix révisé
- k = part du gazole (20 à 30 % selon type de transport)
- I_0 = indice gazole à la signature
- I_n = indice gazole de révision (mensuel)

## Exemple

Contrat signé le 01/01/2024 au prix de 1 000 € / trajet.
- k = 0,25 (transport longue distance)
- I_0 (janvier 2024) = 1,45 €/L
- I_n (juin 2024) = 1,58 €/L

P_n = 1 000 × (1 + 0,25 × (1,58 − 1,45) / 1,45) = 1 000 × (1 + 0,0224) = **1 022,40 €**

## Clause de révision complète

Une clause robuste inclut :

- Indice carburant (CNR)
- Indice **salaire** (taux horaire conventionnel)
- Indice **péages**
- Périodicité de révision (mensuelle, trimestrielle)
- Modalités de communication (avis écrit 15 j avant)

## Autres indices utiles

- **CNR longue distance 40 t** : indice global
- **INSEE transport de marchandises** : indice des prix à la production
- **Indice péage** : publié par ASF, Vinci, Sanef
- **SMIC** et **minima conventionnels** : impact charges

## Piège fréquent

Certains contrats prévoient une clause **avec plafond** (ex. +5 % max/an). Cette clause est potentiellement **nulle** pour la partie gazole (art. L. 3222-1 d'ordre public).

## Mise en pratique

1. Suivre mensuellement les indices CNR
2. Envoyer **fichier de révision** au client avant le 10 du mois
3. Appliquer la nouvelle grille à partir du 1er du mois M+1
4. Archiver tous les justificatifs (preuve en cas de contrôle)
$md$,
$md$**Révision gazole** = de plein droit (L. 3222-1). Formule CNR : P_n = P_0 × (1 + k × ΔI / I_0). Périodicité mensuelle / trimestrielle. Ne pas plafonner le gazole.$md$,
3
from modules m where m.slug='cout-revient'
on conflict (module_id, slug) do nothing;

-- =====================================================================
-- LEÇONS — MODULE 7 : KPI ET RENTABILITÉ
-- =====================================================================

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'tableaux-bord', 'Tableaux de bord transport',
$md$## Principes d'un bon tableau de bord

Un TDB efficace respecte la règle **SMART** :

- **S**pécifique : indicateur clair, sans ambiguïté
- **M**esurable : chiffré, objectivable
- **A**tteignable : réaliste
- **R**elevant : lié à un objectif business
- **T**emporellement défini : fréquence, période

## Les 4 familles de KPI

### 1. Productivité

- **Km / jour / véhicule** : cible 500–700 km longue distance
- **Tonnes-km / an**
- **Taux de remplissage** : masse réelle / PTAC utile
- **Taux de km à vide**
- **Rotation véhicule** : nombre de tournées / jour

### 2. Qualité

- **OTIF** (On-Time In-Full)
- **Taux de litiges**
- **Taux de POD J+1**
- **NPS** (Net Promoter Score)

### 3. Économique

- **CRKM réel** vs budget
- **Marge par tournée**
- **CA / véhicule / mois**
- **Taux de sous-traitance**
- **DSO** (Days Sales Outstanding, délai de paiement client)

### 4. Sécurité / RSE

- **Accidents** / 1 M km
- **Consommation moyenne** L/100 km
- **Émissions CO₂** en g/t·km
- **% Euro VI** / Crit'Air 1

## Fréquence de reporting

| KPI | Fréquence | Destinataire |
|-----|-----------|--------------|
| Incidents | Jour | Exploitation |
| OTIF, vols, refus | Semaine | Resp. exploitation |
| Marge, CRKM | Mois | Direction, commerce |
| RSE, sinistres | Trim. | COMEX, clients |

## Exemple de dashboard mensuel

| KPI | Cible | Réalisé | Écart |
|-----|-------|--------|-------|
| OTIF | 98 % | 97,6 % | -0,4 pt |
| CRKM | 1,40 € | 1,44 € | +2,9 % |
| Taux remplissage | 85 % | 82 % | -3 pts |
| Accidents / Mkm | < 2 | 1,4 | ✅ |
| CO₂ g/t·km | 75 | 73,8 | ✅ |

## Anti-patterns

- ❌ Trop d'indicateurs (> 15) : perte d'attention
- ❌ KPI non alignés avec la stratégie
- ❌ Absence de **cible** : « on regarde » = « on ne décide pas »
- ❌ Pas de responsable associé à chaque KPI
$md$,
$md$**KPI SMART**. 4 familles : productivité, qualité, économique, RSE. Max 10-12 KPI pilotés. Cible + responsable + fréquence pour chacun.$md$,
1
from modules m where m.slug='kpi-rentabilite'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'rse-transport', 'RSE et transition écologique',
$md$## Le transport face à la décarbonation

Le transport routier représente environ **30 %** des émissions de GES en France et **plus de 6 %** pour le seul fret. La décarbonation est :

- Un **impératif réglementaire** (ZFE, Fit for 55, CSRD)
- Une **attente client** (scope 3 des chargeurs)
- Un **enjeu de compétitivité** (accès aux marchés, financement)

## Cadre réglementaire

- **CSRD** (2024) : reporting extra-financier obligatoire, grandes entreprises
- **ZFE** : zones à faibles émissions (métropoles > 150 000 hab.)
- **Eurovignette 2022** : péages modulés selon CO₂
- **Fin vente PL thermiques** : 2040 (UE)

## Calcul des émissions

Méthode **ADEME / décret 2017-639** (information GES) :

`Émissions (kg CO₂) = quantité énergie × facteur d'émission`

- Gazole : **3,17 kg CO₂ / L** (2024)
- GNV fossile : 2,73 kg CO₂ / kg
- Électricité (mix fr) : 0,057 kg CO₂ / kWh

Ramené en **g CO₂ / t·km** :
- Fret longue distance : 70–90 g/t·km
- Fret urbain : 200–400 g/t·km

## Leviers de décarbonation

### Court terme

- **Éco-conduite** : −5 à −10 % de consommation
- **Optimisation tournées** (TMS) : −10 à −20 % km
- **Taux de remplissage** amélioré
- **Pneus basse résistance**, aérodynamique

### Moyen terme

- **Bio-GNV** : −80 % CO₂ vs gazole
- **B100** (colza) : −60 %
- **HVO** : −85 %
- **Modal shift** vers le rail / fleuve

### Long terme

- **Électrique** : urbain, régional court
- **Hydrogène** : longue distance, chantier, maturité 2030+
- **Rétrofit** ?

## Labels et certifications

- **Objectif CO₂** (ADEME + fédérations) : engagement chiffré
- **ISO 14001** : système de management environnemental
- **Ecovadis** : note RSE demandée par les chargeurs
- **SBTi** : Science Based Targets (alignement 1,5 °C)

## Piloter sa transition

1. **Mesurer** (scope 1 carburant + scope 2 électricité + scope 3 sous-traitance)
2. **Fixer des cibles** (ex. −30 % t·km en 2030)
3. **Agir** : éco-conduite, TMS, renouvellement flotte
4. **Reporter** annuellement (CSRD, Ecovadis, clients)
5. **Communiquer** factuel (greenwashing = risque)
$md$,
$md$**3,17 kg CO₂ / L** gazole. Leviers : éco-conduite (−10 %), TMS, bio-GNV (−80 %). CSRD 2024, ZFE, label Objectif CO₂. Mesurer → cibler → agir → reporter.$md$,
2
from modules m where m.slug='kpi-rentabilite'
on conflict (module_id, slug) do nothing;

insert into lessons (module_id, slug, title, content_md, summary_md, "order")
select m.id, 'rentabilite-client', 'Rentabilité par client et par tournée',
$md$## Pourquoi analyser par client ?

Loi de Pareto souvent observée en transport : **20 % des clients génèrent 80 % de la marge**… mais parfois aussi **20 % des clients détruisent 50 % de la marge** (petites tournées éclatées, temps d'attente, litiges).

## Calcul de marge client

`Marge client = CA − coûts directs alloués − coûts indirects alloués`

### Coûts directs

- Kilomètres parcourus × CRKM variable
- Heures dédiées × coût horaire
- Sous-traitance
- Litiges et avoirs

### Coûts indirects

- Part fixe véhicule (au prorata des km)
- Structure (au prorata du CA ou du nombre d'envois)

## Exemple d'analyse

| Client | CA | Km | Heures | Litiges | Marge € | Marge % |
|--------|---:|---:|------:|--------:|--------:|--------:|
| Alpha | 180 k€ | 120 k | 1 600 | 0,5 % | 28 k€ | 15,5 % |
| Bravo | 95 k€ | 88 k | 1 200 | 0,2 % | 14 k€ | 14,7 % |
| Charlie | 60 k€ | 75 k | 1 400 | 1,8 % | −3,5 k€ | **−5,8 %** |

→ Charlie détruit de la valeur : à renégocier ou sortir.

## Actions possibles sur clients non rentables

1. **Renégocier** (hausse 3–7 %, réduction services annexes)
2. **Repositionner** sur une offre différente (groupage vs lot)
3. **Restructurer** la tournée (massification, jours fixes)
4. **Sortir** en dernier recours (préavis 3 mois)

## Rentabilité par tournée

Chaque jour, chaque tournée doit être **jaugée** :

| Tournée | CA | Coût | Marge € | Marge % |
|---------|----:|----:|------:|------:|
| T1 Paris-Lille AR chargé | 1 850 € | 1 520 € | 330 € | 17,8 % |
| T2 Paris-Rennes retour vide | 1 450 € | 1 380 € | 70 € | 4,8 % |
| T3 navette urbaine | 780 € | 650 € | 130 € | 16,7 % |

La T2 est limite : chercher fret retour ou renégocier.

## Leviers d'amélioration de la marge

- **Yield management** : prix variable selon demande
- **Tarifs zones** ajustés (remote area surcharge)
- **Temps d'attente** facturés strictement
- **Frais annexes** (hayon, rendez-vous, 2ᵉ présentation)
- **Clause de révision** rigoureusement appliquée
- **Massification** (moins d'envois unitaires)

## Pilotage mensuel

- Top 10 clients (CA, marge, tendance)
- Flops 10 clients (marge négative, alerte)
- Top / flop tournées
- Carburant consommé vs indice facturé
- Litiges > 1 000 € (liste nominative)
$md$,
$md$**80/20** en transport. Calculer marge par client (direct + indirect). Sortir les perdants (renégo → restructurer → arrêter). Surveiller tournées individuellement. Yield management, frais annexes.$md$,
3
from modules m where m.slug='kpi-rentabilite'
on conflict (module_id, slug) do nothing;

-- =====================================================================
-- QUIZZES
-- =====================================================================

insert into quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
select m.id, 'Quiz — Planification & temps de conduite',
       'Testez vos connaissances sur la planification, le règlement 561/2006 et la CMR.',
       'entrainement', 1200, 70
from modules m
where m.slug='planification-tournees'
  and not exists (select 1 from quizzes where title='Quiz — Planification & temps de conduite');

insert into quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
select m.id, 'Quiz — Réglementation transport',
       'ADR, contrats types, responsabilité, cabotage, Incoterms.',
       'entrainement', 1200, 70
from modules m
where m.slug='reglementation-transport'
  and not exists (select 1 from quizzes where title='Quiz — Réglementation transport');

insert into quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
select m.id, 'Quiz — Relation client',
       'Contrat de transport, réserves, litiges, qualité de service.',
       'entrainement', 900, 70
from modules m
where m.slug='relation-client'
  and not exists (select 1 from quizzes where title='Quiz — Relation client');

insert into quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
select m.id, 'Quiz — Appels d''offres et sous-traitance',
       'DCE, grille tarifaire, sélection, clauses contractuelles.',
       'entrainement', 1200, 70
from modules m
where m.slug='appels-offres'
  and not exists (select 1 from quizzes where title='Quiz — Appels d''offres et sous-traitance');

insert into quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
select m.id, 'Quiz — Suivi des sous-traitants',
       'KPI, audit, vigilance, action directe, litiges.',
       'entrainement', 900, 70
from modules m
where m.slug='suivi-sous-traitants'
  and not exists (select 1 from quizzes where title='Quiz — Suivi des sous-traitants');

insert into quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
select m.id, 'Quiz — Coût de revient',
       'CRKM, charges fixes/variables, indices CNR, révision des prix.',
       'entrainement', 1200, 70
from modules m
where m.slug='cout-revient'
  and not exists (select 1 from quizzes where title='Quiz — Coût de revient');

insert into quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
select m.id, 'Quiz — KPI et rentabilité',
       'Tableaux de bord, RSE, CO₂, analyse client.',
       'entrainement', 900, 70
from modules m
where m.slug='kpi-rentabilite'
  and not exists (select 1 from quizzes where title='Quiz — KPI et rentabilité');

insert into quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
select null, 'Examen blanc GOTRM — Session 1',
       'Simulation complète couvrant les 3 blocs. 30 questions, 45 min, 60 % pour réussir. Inclut des cas pratiques.',
       'examen', 2700, 60
where not exists (select 1 from quizzes where title='Examen blanc GOTRM — Session 1');

insert into quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
select null, 'Examen blanc GOTRM — Session 2',
       'Deuxième simulation avec calculs de CRKM, cas d''appels d''offres et gestion de litiges. 30 questions, 45 min.',
       'examen', 2700, 60
where not exists (select 1 from quizzes where title='Examen blanc GOTRM — Session 2');

-- =====================================================================
-- QUESTIONS — Quiz Planification & temps de conduite
-- =====================================================================
insert into questions (quiz_id, statement, explanation, "order")
select q.id, v.statement, v.explanation, v."order"
from (values
  ('Après combien de temps de conduite continue une pause de 45 min est-elle obligatoire ?', 'Le règlement 561/2006 impose une pause de 45 min après 4h30 de conduite cumulée.', 1),
  ('Quelle est la durée maximale de conduite hebdomadaire ?', '56 h sur une semaine, 90 h sur deux semaines consécutives.', 2),
  ('Sur combien de jours un contrôle DREAL peut-il remonter ?', 'Le contrôle porte sur la journée en cours et les 28 jours précédents.', 3),
  ('Quel document sert de preuve du contrat de transport international routier ?', 'La lettre de voiture CMR établie en 3 exemplaires (rouge/bleu/vert).', 4),
  ('Quelle est la capacité financière exigée pour le 1er véhicule (règlement 1071/2009) ?', '9 000 € pour le premier véhicule, 5 000 € par véhicule supplémentaire.', 5),
  ('Combien de fois par semaine peut-on porter la conduite journalière à 10 h ?', 'Deux fois par semaine maximum, le reste étant à 9 h.', 6),
  ('La pause de 45 min peut-elle être fractionnée ?', 'Oui en 15 min + 30 min obligatoirement dans cet ordre.', 7),
  ('Quelle est la durée du repos journalier normal ?', '11 h consécutives, réductible à 9 h trois fois par semaine.', 8),
  ('Quel est le délai maximum pour prendre un repos hebdomadaire après le précédent ?', 'Au plus tard à la fin de la 6e période de 24 h de travail.', 9),
  ('Quel taux de remplissage est considéré comme bon en longue distance ?', 'On vise au minimum 85 % de la charge utile pour être rentable.', 10),
  ('En cas de dommage apparent à la livraison, que doit faire le destinataire ?', 'Porter des réserves précises, motivées et datées sur la CMR, signées contradictoirement.', 11),
  ('Quelle couleur de l''exemplaire CMR revient au transporteur ?', 'Rouge = expéditeur, Bleu = transporteur, Vert = destinataire.', 12),
  ('Qu''est-ce qu''un TMS en transport ?', 'Transport Management System : logiciel d''optimisation et pilotage des opérations.', 13),
  ('Quel est le délai franc de temps d''attente généralement prévu par les CGV ?', '30 minutes, au-delà desquelles le temps d''attente est facturable.', 14),
  ('Pour une opération de cabotage, combien d''opérations max en 7 jours ?', '3 opérations de cabotage après un transport international, dans les 7 jours.', 15)
) as v(statement, explanation, "order")
cross join quizzes q
where q.title='Quiz — Planification & temps de conduite'
  and not exists (select 1 from questions q2 where q2.quiz_id=q.id and q2."order"=v."order");

insert into choices (question_id, label, is_correct, "order")
select qu.id, v.label, v.is_correct, v."order"
from (values
  (1, '3 heures', false, 1), (1, '4 heures', false, 2), (1, '4 h 30', true, 3), (1, '6 heures', false, 4),
  (2, '45 h', false, 1), (2, '48 h', false, 2), (2, '56 h', true, 3), (2, '60 h', false, 4),
  (3, '7 jours', false, 1), (3, '14 jours', false, 2), (3, '28 jours', true, 3), (3, '90 jours', false, 4),
  (4, 'Le bon de livraison', false, 1), (4, 'La lettre de voiture CMR', true, 2), (4, 'Le connaissement', false, 3), (4, 'Le manifeste', false, 4),
  (5, '5 000 €', false, 1), (5, '9 000 €', true, 2), (5, '15 000 €', false, 3), (5, '30 000 €', false, 4),
  (6, '1 fois', false, 1), (6, '2 fois', true, 2), (6, '3 fois', false, 3), (6, 'Tous les jours', false, 4),
  (7, 'Non, jamais', false, 1), (7, 'Oui, 15+30 min dans cet ordre', true, 2), (7, 'Oui, 30+15 min dans cet ordre', false, 3), (7, 'Oui, 20+25 min', false, 4),
  (8, '8 h', false, 1), (8, '9 h', false, 2), (8, '11 h', true, 3), (8, '12 h', false, 4),
  (9, '5 jours', false, 1), (9, '6 jours', true, 2), (9, '7 jours', false, 3), (9, '10 jours', false, 4),
  (10, '50 %', false, 1), (10, '70 %', false, 2), (10, '85 %', true, 3), (10, '100 %', false, 4),
  (11, 'Rien, accepter la livraison', false, 1), (11, 'Des réserves précises et datées', true, 2), (11, 'Refuser la marchandise', false, 3), (11, 'Appeler la gendarmerie', false, 4),
  (12, 'Rouge', false, 1), (12, 'Bleu', true, 2), (12, 'Vert', false, 3), (12, 'Jaune', false, 4),
  (13, 'Tachygraphe', false, 1), (13, 'Logiciel de planification transport', true, 2), (13, 'Formation conducteur', false, 3), (13, 'Norme ISO', false, 4),
  (14, '15 min', false, 1), (14, '30 min', true, 2), (14, '1 h', false, 3), (14, '2 h', false, 4),
  (15, '1', false, 1), (15, '2', false, 2), (15, '3', true, 3), (15, '5', false, 4)
) as v(qorder, label, is_correct, "order")
join questions qu on qu."order"=v.qorder
join quizzes q on q.id=qu.quiz_id and q.title='Quiz — Planification & temps de conduite'
where not exists (select 1 from choices c where c.question_id=qu.id and c."order"=v."order");

-- =====================================================================
-- QUESTIONS — Quiz Réglementation transport
-- =====================================================================
insert into questions (quiz_id, statement, explanation, "order")
select q.id, v.statement, v.explanation, v."order"
from (values
  ('Combien de classes de matières dangereuses compte l''ADR ?', '9 classes, de 1 (explosifs) à 9 (matières dangereuses diverses).', 1),
  ('Quelle est la durée de validité d''une attestation de formation conducteur ADR ?', '5 ans, renouvelable par recyclage.', 2),
  ('Quel règlement européen fixe les règles d''accès à la profession de transporteur ?', 'Le règlement (CE) 1071/2009.', 3),
  ('Quel est le plafond d''indemnisation en transport national pour un envoi > 3 t ?', '14 €/kg ou 2 300 €/t selon le contrat type général.', 4),
  ('Quel est le plafond d''indemnisation en CMR international ?', '8,33 DTS/kg (environ 10 €/kg).', 5),
  ('Dans quels cas les plafonds d''indemnisation sautent-ils ?', 'En cas de dol ou faute lourde du transporteur.', 6),
  ('Combien d''opérations de cabotage sont autorisées après un transport international ?', 'Maximum 3 opérations dans les 7 jours suivant le déchargement.', 7),
  ('Quel document atteste qu''un véhicule frigo est conforme aux normes ATP ?', 'L''attestation ATP, délivrée après inspection.', 8),
  ('Un transporteur est exonéré de responsabilité en cas de :', 'Force majeure, vice propre, faute de l''expéditeur ou du destinataire.', 9),
  ('Quel Incoterm signifie que le vendeur livre chez l''acheteur, droits acquittés ?', 'DDP = Delivered Duty Paid.', 10),
  ('Le délai de paiement légal en transport est de :', '30 jours à compter de l''émission de la facture (L. 441-10 C. com.).', 11),
  ('Quel est le délai de prescription d''une action en responsabilité contre le transporteur ?', '1 an à compter de la livraison (ou de la date prévue).', 12),
  ('Que signifie la clause d''action directe (L. 132-8) ?', 'Le transporteur effectif peut réclamer son paiement à l''expéditeur ou au destinataire en cas de défaillance du commissionnaire.', 13),
  ('Quelle autorité délivre la licence de transport ?', 'La DREAL (Direction Régionale de l''Environnement, de l''Aménagement et du Logement).', 14),
  ('Quelle est la nouvelle obligation issue du Paquet Mobilité concernant les véhicules ?', 'Retour au pays d''établissement au moins toutes les 8 semaines.', 15)
) as v(statement, explanation, "order")
cross join quizzes q
where q.title='Quiz — Réglementation transport'
  and not exists (select 1 from questions q2 where q2.quiz_id=q.id and q2."order"=v."order");

insert into choices (question_id, label, is_correct, "order")
select qu.id, v.label, v.is_correct, v."order"
from (values
  (1, '5', false, 1), (1, '7', false, 2), (1, '9', true, 3), (1, '12', false, 4),
  (2, '2 ans', false, 1), (2, '3 ans', false, 2), (2, '5 ans', true, 3), (2, '10 ans', false, 4),
  (3, '561/2006', false, 1), (3, '1071/2009', true, 2), (3, '1072/2009', false, 3), (3, 'CMR', false, 4),
  (4, '8 €/kg', false, 1), (4, '14 €/kg', true, 2), (4, '23 €/kg', false, 3), (4, '30 €/kg', false, 4),
  (5, '5 DTS/kg', false, 1), (5, '8,33 DTS/kg', true, 2), (5, '14 DTS/kg', false, 3), (5, '25 DTS/kg', false, 4),
  (6, 'Jamais', false, 1), (6, 'Dol ou faute lourde', true, 2), (6, 'Simple négligence', false, 3), (6, 'Retard mineur', false, 4),
  (7, '1 opération', false, 1), (7, '2 opérations', false, 2), (7, '3 opérations', true, 3), (7, '5 opérations', false, 4),
  (8, 'Certificat CE', false, 1), (8, 'Attestation ATP', true, 2), (8, 'FCO', false, 3), (8, 'Label HACCP', false, 4),
  (9, 'Pluie normale', false, 1), (9, 'Force majeure, vice propre, faute expé/dest', true, 2), (9, 'Panne véhicule', false, 3), (9, 'Retard du conducteur', false, 4),
  (10, 'EXW', false, 1), (10, 'FCA', false, 2), (10, 'DAP', false, 3), (10, 'DDP', true, 4),
  (11, '15 jours', false, 1), (11, '30 jours', true, 2), (11, '45 jours', false, 3), (11, '60 jours', false, 4),
  (12, '6 mois', false, 1), (12, '1 an', true, 2), (12, '2 ans', false, 3), (12, '5 ans', false, 4),
  (13, 'Droit de rétention', false, 1), (13, 'Poursuite directe expéditeur/destinataire', true, 2), (13, 'Clause résolutoire', false, 3), (13, 'Action en référé', false, 4),
  (14, 'Préfecture', false, 1), (14, 'DREAL', true, 2), (14, 'URSSAF', false, 3), (14, 'Ministère', false, 4),
  (15, 'Retour tous les 2 semaines', false, 1), (15, 'Retour toutes les 4 semaines', false, 2), (15, 'Retour toutes les 8 semaines', true, 3), (15, 'Aucun retour obligatoire', false, 4)
) as v(qorder, label, is_correct, "order")
join questions qu on qu."order"=v.qorder
join quizzes q on q.id=qu.quiz_id and q.title='Quiz — Réglementation transport'
where not exists (select 1 from choices c where c.question_id=qu.id and c."order"=v."order");

-- =====================================================================
-- QUESTIONS — Quiz Relation client
-- =====================================================================
insert into questions (quiz_id, statement, explanation, "order")
select q.id, v.statement, v.explanation, v."order"
from (values
  ('Combien d''acteurs sont parties au contrat de transport ?', 'Trois : expéditeur, transporteur et destinataire (qui adhère à la livraison).', 1),
  ('Quelle différence entre commissionnaire et transporteur ?', 'Le commissionnaire organise en son nom mais pour le compte d''autrui, le transporteur exécute matériellement.', 2),
  ('Quel est le délai pour signaler des avaries non apparentes en national ?', '3 jours ouvrables (hors dimanches et jours fériés).', 3),
  ('Quel est le délai pour signaler des avaries non apparentes en CMR ?', '7 jours calendaires (hors samedi, dimanche et jours fériés).', 4),
  ('Qu''est-ce qu''un e-POD ?', 'Electronic Proof of Delivery : signature électronique de livraison.', 5),
  ('Que signifie l''acronyme OTIF ?', 'On Time In Full : livraison complète et à l''heure.', 6),
  ('Quelle est la cible usuelle d''OTIF en B2B ?', 'Au moins 98 % de livraisons conformes et à l''heure.', 7),
  ('Que prévoit le contrat type en cas d''impossibilité de livrer ?', 'Retour en dépôt, stockage facturable, deuxième présentation facturable.', 8),
  ('Qu''est-ce qu''un NPS ?', 'Net Promoter Score : mesure la probabilité qu''un client recommande.', 9),
  ('Les CGV sont opposables au client si :', 'Elles ont été portées à sa connaissance avant la commande et acceptées.', 10),
  ('Que signifie une réserve "sous réserve de déballage" ?', 'Elle est considérée comme imprécise et potentiellement inopposable.', 11),
  ('Dans une démarche PDCA, que signifie le "C" ?', 'Check = vérifier, mesurer le résultat de l''action menée.', 12),
  ('Qu''est-ce qu''une QBR ?', 'Quarterly Business Review : revue trimestrielle client / transporteur.', 13),
  ('Le bon de livraison signé vaut-il preuve de livraison sans réserves ?', 'Oui, si aucune réserve précise n''est mentionnée, il y a présomption de livraison conforme.', 14),
  ('Quel délai typique pour accuser réception d''une réclamation ?', 'Sous 48 h maximum pour une gestion qualité.', 15)
) as v(statement, explanation, "order")
cross join quizzes q
where q.title='Quiz — Relation client'
  and not exists (select 1 from questions q2 where q2.quiz_id=q.id and q2."order"=v."order");

insert into choices (question_id, label, is_correct, "order")
select qu.id, v.label, v.is_correct, v."order"
from (values
  (1, '2', false, 1), (1, '3', true, 2), (1, '4', false, 3), (1, '5', false, 4),
  (2, 'Aucune, termes synonymes', false, 1), (2, 'Le commissionnaire organise, le transporteur exécute', true, 2), (2, 'Le transporteur est plus cher', false, 3), (2, 'Juridique uniquement', false, 4),
  (3, '24 h', false, 1), (3, '3 jours', true, 2), (3, '7 jours', false, 3), (3, '15 jours', false, 4),
  (4, '3 jours', false, 1), (4, '7 jours', true, 2), (4, '14 jours', false, 3), (4, '21 jours', false, 4),
  (5, 'Un tachygraphe', false, 1), (5, 'Une preuve électronique de livraison', true, 2), (5, 'Un logiciel de paie', false, 3), (5, 'Une norme ISO', false, 4),
  (6, 'Operational Transport International Fee', false, 1), (6, 'On Time In Full', true, 2), (6, 'Order Time In Future', false, 3), (6, 'On The International Fleet', false, 4),
  (7, '80 %', false, 1), (7, '90 %', false, 2), (7, '98 %', true, 3), (7, '100 %', false, 4),
  (8, 'Rien, perte sèche', false, 1), (8, 'Retour dépôt, 2e présentation facturable', true, 2), (8, 'Laisser sur le trottoir', false, 3), (8, 'Offrir à l''acheteur', false, 4),
  (9, 'Net Price Score', false, 1), (9, 'Net Promoter Score (satisfaction/recommandation)', true, 2), (9, 'Nouveau Process Sécurité', false, 3), (9, 'Non Paid Service', false, 4),
  (10, 'Toujours opposables', false, 1), (10, 'Si portées à connaissance avant commande', true, 2), (10, 'Seulement si signées', false, 3), (10, 'Jamais', false, 4),
  (11, 'Elle est parfaitement valable', false, 1), (11, 'Elle est imprécise et inopposable', true, 2), (11, 'Elle protège le destinataire', false, 3), (11, 'Elle oblige le transporteur', false, 4),
  (12, 'Compter', false, 1), (12, 'Check = vérifier/mesurer', true, 2), (12, 'Corriger', false, 3), (12, 'Contrôler la qualité', false, 4),
  (13, 'Quality Building Review', false, 1), (13, 'Quarterly Business Review', true, 2), (13, 'Quota Billing Report', false, 3), (13, 'Quick Brief Report', false, 4),
  (14, 'Non, jamais', false, 1), (14, 'Oui, présomption de conformité sans réserves', true, 2), (14, 'Seulement avec photo', false, 3), (14, 'Seulement en CMR', false, 4),
  (15, '24 h', false, 1), (15, '48 h', true, 2), (15, '5 jours', false, 3), (15, '15 jours', false, 4)
) as v(qorder, label, is_correct, "order")
join questions qu on qu."order"=v.qorder
join quizzes q on q.id=qu.quiz_id and q.title='Quiz — Relation client'
where not exists (select 1 from choices c where c.question_id=qu.id and c."order"=v."order");

-- =====================================================================
-- QUESTIONS — Quiz Appels d'offres
-- =====================================================================
insert into questions (quiz_id, statement, explanation, "order")
select q.id, v.statement, v.explanation, v."order"
from (values
  ('Que contient généralement un CCTP ?', 'Le cahier des charges techniques : volumes, destinations, fréquences, contraintes techniques.', 1),
  ('Dans un scoring classique, quelle est la part du prix ?', 'Environ 40 % dans une pondération équilibrée (sur 100).', 2),
  ('Quelle règle suivre sur la dépendance à un sous-traitant ?', 'Ne pas dépasser 70 % du volume chez un seul prestataire pour maîtriser le risque.', 3),
  ('Qu''est-ce qu''un score de défaillance Altares ?', 'Une notation de solidité financière / probabilité de défaillance de l''entreprise.', 4),
  ('La clause de révision carburant est-elle obligatoire ?', 'Oui, de plein droit pour tout contrat > 3 mois (art. L. 3222-1 C. transports).', 5),
  ('Quelle est une valeur typique du coefficient k (part gazole) en longue distance ?', 'Environ 0,25 à 0,30 (25 à 30 % du prix).', 6),
  ('Un préavis de résiliation usuel dans un contrat transport est :', '3 mois, permettant la continuité du service.', 7),
  ('Dans un DCE, que trouve-t-on dans le règlement de consultation ?', 'La procédure, les critères d''attribution, les délais, les règles de confidentialité.', 8),
  ('Que permet d''apprécier une visite de site ?', 'La réalité opérationnelle : flotte, quais, outils, ambiance, formation, sécurité.', 9),
  ('Quel CA minimum recommandé par rapport au marché ?', 'Au moins 3 fois le montant du marché pour limiter la dépendance du sous-traitant.', 10),
  ('Qu''est-ce qu''une clause de réversibilité ?', 'Elle organise la restitution des données et actifs en fin de contrat pour faciliter la transition.', 11),
  ('Quelle certification atteste d''un management qualité générique ?', 'ISO 9001.', 12),
  ('Qu''est-ce qu''un OEA ?', 'Opérateur Économique Agréé : statut douanier facilitant les échanges internationaux.', 13),
  ('Les pénalités disproportionnées peuvent être :', 'Requalifiées ou réduites par le juge, voire réputées non écrites.', 14),
  ('Dans un grille poids × zones, comment varie en général le €/kg ?', 'Il décroît avec le poids (plus on charge, moins le coût unitaire est élevé).', 15)
) as v(statement, explanation, "order")
cross join quizzes q
where q.title='Quiz — Appels d''offres et sous-traitance'
  and not exists (select 1 from questions q2 where q2.quiz_id=q.id and q2."order"=v."order");

insert into choices (question_id, label, is_correct, "order")
select qu.id, v.label, v.is_correct, v."order"
from (values
  (1, 'Conditions de paiement uniquement', false, 1), (1, 'Le cahier des charges technique (volumes, contraintes...)', true, 2), (1, 'Les tarifs concurrents', false, 3), (1, 'Les sanctions', false, 4),
  (2, '20 %', false, 1), (2, '40 %', true, 2), (2, '60 %', false, 3), (2, '80 %', false, 4),
  (3, 'Aucune règle', false, 1), (3, '< 70 % du volume chez un seul', true, 2), (3, '< 100 %', false, 3), (3, 'Toujours 50/50', false, 4),
  (4, 'Note commerciale', false, 1), (4, 'Solidité financière / risque défaillance', true, 2), (4, 'Qualité de service', false, 3), (4, 'Niveau RSE', false, 4),
  (5, 'Optionnelle', false, 1), (5, 'Obligatoire > 3 mois', true, 2), (5, 'Interdite', false, 3), (5, 'Seulement international', false, 4),
  (6, '5 %', false, 1), (6, '10 %', false, 2), (6, '25-30 %', true, 3), (6, '50 %', false, 4),
  (7, '1 semaine', false, 1), (7, '1 mois', false, 2), (7, '3 mois', true, 3), (7, '1 an', false, 4),
  (8, 'La procédure et critères', true, 1), (8, 'La grille tarifaire', false, 2), (8, 'Les bilans', false, 3), (8, 'La liste des conducteurs', false, 4),
  (9, 'La fiscalité', false, 1), (9, 'La réalité opérationnelle', true, 2), (9, 'Le climat social', false, 3), (9, 'La communication', false, 4),
  (10, '1×', false, 1), (10, '3×', true, 2), (10, '10×', false, 3), (10, 'Aucun minimum', false, 4),
  (11, 'Une clause de non-concurrence', false, 1), (11, 'L''organisation de la transition/restitution', true, 2), (11, 'Une pénalité', false, 3), (11, 'Une confidentialité', false, 4),
  (12, 'ISO 14001', false, 1), (12, 'ISO 9001', true, 2), (12, 'ISO 45001', false, 3), (12, 'ISO 27001', false, 4),
  (13, 'Un certificat RSE', false, 1), (13, 'Un statut douanier avantageux', true, 2), (13, 'Une agence publique', false, 3), (13, 'Une assurance', false, 4),
  (14, 'Inattaquables', false, 1), (14, 'Réduites ou réputées non écrites', true, 2), (14, 'Doublées', false, 3), (14, 'Toujours valables', false, 4),
  (15, 'Il augmente', false, 1), (15, 'Il décroît avec le poids', true, 2), (15, 'Il reste stable', false, 3), (15, 'Il varie aléatoirement', false, 4)
) as v(qorder, label, is_correct, "order")
join questions qu on qu."order"=v.qorder
join quizzes q on q.id=qu.quiz_id and q.title='Quiz — Appels d''offres et sous-traitance'
where not exists (select 1 from choices c where c.question_id=qu.id and c."order"=v."order");

-- =====================================================================
-- QUESTIONS — Quiz Suivi des sous-traitants
-- =====================================================================
insert into questions (quiz_id, statement, explanation, "order")
select q.id, v.statement, v.explanation, v."order"
from (values
  ('Un sous-traitant réalise 97 livraisons à l''heure sur 100. Son OTIF est :', 'OTIF = conformes/total = 97/100 = 97 %.', 1),
  ('Quelle cible standard pour le taux de casse / perte ?', '≤ 0,2 %, soit moins de 2 envois endommagés sur 1000.', 2),
  ('À quelle fréquence faut-il vérifier l''attestation de vigilance URSSAF ?', 'Tous les 6 mois pour les contrats > 5 000 € HT.', 3),
  ('Quel article encadre l''action directe du transporteur ?', 'L. 132-8 du Code de commerce.', 4),
  ('Quelle est la période de prescription du contrat de transport ?', '1 an à compter de la date de livraison (ou prévue).', 5),
  ('Dans un tableau de bord, un sous-traitant "C" correspond à :', 'Un score inférieur à 85 % : performance à remettre à niveau ou à exclure.', 6),
  ('Qu''est-ce qu''un audit flash ?', 'Un audit ponctuel sur site, sans préavis ou avec préavis court.', 7),
  ('La loi sur le devoir de vigilance concerne les entreprises de :', 'Plus de 5 000 salariés (ou 10 000 dans le monde).', 8),
  ('Un sous-traitant n''a pas payé ses cotisations. Qui est solidairement responsable ?', 'Le donneur d''ordre, s''il n''a pas vérifié l''attestation de vigilance.', 9),
  ('Que faire face à une non-conformité critique ?', 'Arrêter immédiatement les affectations et engager une procédure contractuelle.', 10),
  ('Quel est le principal risque d''une dépendance > 70 % sur un sous-traitant ?', 'Rupture de service en cas de défaillance, perte de marge, dépendance commerciale.', 11),
  ('Qu''est-ce qu''un plan de progrès ?', 'Un document chiffré avec objectifs et deadlines pour redresser la performance.', 12),
  ('Quel document le sous-traitant doit fournir à chaque commande ?', 'Un CMR ou une lettre de voiture signée contradictoirement.', 13),
  ('Dans un tableau de bord, quel code couleur pour un score entre 85 et 95 % ?', 'Orange (B) : performance à surveiller avec plan de progrès.', 14),
  ('Le taux de POD J+1 mesure :', 'Le pourcentage de preuves de livraison retournées à J+1 (qualité administrative).', 15)
) as v(statement, explanation, "order")
cross join quizzes q
where q.title='Quiz — Suivi des sous-traitants'
  and not exists (select 1 from questions q2 where q2.quiz_id=q.id and q2."order"=v."order");

insert into choices (question_id, label, is_correct, "order")
select qu.id, v.label, v.is_correct, v."order"
from (values
  (1, '70 %', false, 1), (1, '93 %', false, 2), (1, '97 %', true, 3), (1, '100 %', false, 4),
  (2, '0,2 %', true, 1), (2, '1 %', false, 2), (2, '5 %', false, 3), (2, '10 %', false, 4),
  (3, 'Tous les mois', false, 1), (3, 'Tous les 6 mois', true, 2), (3, '1 fois par an', false, 3), (3, 'Jamais', false, 4),
  (4, 'L. 441-10', false, 1), (4, 'L. 132-8', true, 2), (4, 'L. 3222-1', false, 3), (4, 'L. 1432-2', false, 4),
  (5, '6 mois', false, 1), (5, '1 an', true, 2), (5, '2 ans', false, 3), (5, '5 ans', false, 4),
  (6, 'Excellence', false, 1), (6, 'À sortir ou redresser', true, 2), (6, 'Standard', false, 3), (6, 'Top performer', false, 4),
  (7, 'Audit annuel planifié', false, 1), (7, 'Audit ponctuel sans préavis', true, 2), (7, 'Audit comptable', false, 3), (7, 'Audit commercial', false, 4),
  (8, '> 500', false, 1), (8, '> 1 000', false, 2), (8, '> 5 000', true, 3), (8, '> 20 000', false, 4),
  (9, 'Personne', false, 1), (9, 'Le donneur d''ordre', true, 2), (9, 'L''URSSAF', false, 3), (9, 'Le salarié', false, 4),
  (10, 'Envoyer un avertissement', false, 1), (10, 'Arrêt immédiat + procédure', true, 2), (10, 'Attendre 6 mois', false, 3), (10, 'Baisser le prix', false, 4),
  (11, 'Aucun', false, 1), (11, 'Rupture de service + perte de marge', true, 2), (11, 'Gain commercial', false, 3), (11, 'Stabilité', false, 4),
  (12, 'Un audit', false, 1), (12, 'Un document chiffré objectifs/deadlines', true, 2), (12, 'Un bilan', false, 3), (12, 'Un plan stratégique', false, 4),
  (13, 'Une facture', false, 1), (13, 'Un CMR / LV signé', true, 2), (13, 'Un devis', false, 3), (13, 'Un bordereau', false, 4),
  (14, 'Vert', false, 1), (14, 'Orange', true, 2), (14, 'Rouge', false, 3), (14, 'Bleu', false, 4),
  (15, 'Poids en tonnes', false, 1), (15, '% preuves retournées à J+1', true, 2), (15, 'Chiffre d''affaires', false, 3), (15, 'Km parcourus', false, 4)
) as v(qorder, label, is_correct, "order")
join questions qu on qu."order"=v.qorder
join quizzes q on q.id=qu.quiz_id and q.title='Quiz — Suivi des sous-traitants'
where not exists (select 1 from choices c where c.question_id=qu.id and c."order"=v."order");

-- =====================================================================
-- QUESTIONS — Quiz Coût de revient
-- =====================================================================
insert into questions (quiz_id, statement, explanation, "order")
select q.id, v.statement, v.explanation, v."order"
from (values
  ('Parmi ces postes, lequel est une charge variable ?', 'Le carburant varie avec les km. Amortissement/assurance/salaire fixe sont des charges fixes.', 1),
  ('Charges fixes 80 000 €/an, 100 000 km/an, variables 0,60 €/km. Quel CRKM ?', '80 000/100 000 + 0,60 = 0,80 + 0,60 = 1,40 €/km.', 2),
  ('Le 1er poste de coût d''un 40 t est généralement :', 'Le carburant (~30-35 %), suivi du salaire conducteur.', 3),
  ('Un véhicule roule 150 000 km/an. Charges fixes 90 000 €. Part fixe/km ?', '90 000 / 150 000 = 0,60 €/km.', 4),
  ('L''amortissement d''un tracteur 40 t est généralement étalé sur :', '6 à 8 ans, selon la politique comptable.', 5),
  ('Que représente AdBlue dans le coût ?', 'Un additif (solution d''urée) pour les moteurs diesel récents (SCR), part variable modeste.', 6),
  ('CNR = Comité National... ?', 'Comité National Routier, qui publie les indices de coûts.', 7),
  ('Formule de révision gazole : k représente :', 'La part du gazole dans le prix du transport (20-30 % typiquement).', 8),
  ('Un véhicule roule 120 000 km et facture 180 000 €. Prix/km ?', '180 000 / 120 000 = 1,50 €/km.', 9),
  ('Point mort à 90 000 € charges fixes, marge unitaire 0,60 €/km :', '90 000 / 0,60 = 150 000 km.', 10),
  ('Comparer flotte propre vs sous-traitance : l''avantage de la sous-traitance est :', 'Flexibilité et transfert du risque CAPEX et social.', 11),
  ('La marge commerciale en transport longue distance est souvent de :', '8 à 15 % selon l''intensité concurrentielle.', 12),
  ('Pour un AR Paris-Lyon de 940 km à 1,55 €/km, quel coût direct ?', '940 × 1,55 = 1 457 €.', 13),
  ('Le CRKM permet de :', 'Établir les tarifs, négocier, comparer véhicules et tournées, identifier les postes à optimiser.', 14),
  ('La taxe à l''essieu est :', 'Une taxe annuelle payée par le propriétaire d''un véhicule PL (charge fixe).', 15)
) as v(statement, explanation, "order")
cross join quizzes q
where q.title='Quiz — Coût de revient'
  and not exists (select 1 from questions q2 where q2.quiz_id=q.id and q2."order"=v."order");

insert into choices (question_id, label, is_correct, "order")
select qu.id, v.label, v.is_correct, v."order"
from (values
  (1, 'Amortissement', false, 1), (1, 'Assurance', false, 2), (1, 'Carburant', true, 3), (1, 'Salaire fixe', false, 4),
  (2, '1,20 €/km', false, 1), (2, '1,40 €/km', true, 2), (2, '1,60 €/km', false, 3), (2, '0,80 €/km', false, 4),
  (3, 'Amortissement', false, 1), (3, 'Carburant', true, 2), (3, 'Entretien', false, 3), (3, 'Péages', false, 4),
  (4, '0,45 €/km', false, 1), (4, '0,60 €/km', true, 2), (4, '0,75 €/km', false, 3), (4, '0,90 €/km', false, 4),
  (5, '3 ans', false, 1), (5, '6 à 8 ans', true, 2), (5, '15 ans', false, 3), (5, '25 ans', false, 4),
  (6, 'Un carburant alternatif', false, 1), (6, 'Un additif SCR (urée)', true, 2), (6, 'Un pneu spécial', false, 3), (6, 'Une assurance', false, 4),
  (7, 'National Routes', false, 1), (7, 'National Routier', true, 2), (7, 'Normes Routières', false, 3), (7, 'Nouveau Routier', false, 4),
  (8, 'La marge', false, 1), (8, 'La part du gazole dans le prix', true, 2), (8, 'Le nombre de km', false, 3), (8, 'Le prix au litre', false, 4),
  (9, '1,20 €/km', false, 1), (9, '1,35 €/km', false, 2), (9, '1,50 €/km', true, 3), (9, '1,80 €/km', false, 4),
  (10, '100 000 km', false, 1), (10, '120 000 km', false, 2), (10, '150 000 km', true, 3), (10, '180 000 km', false, 4),
  (11, 'Plus cher', false, 1), (11, 'Flexibilité + transfert risques', true, 2), (11, 'Plus de contrôle qualité', false, 3), (11, 'Plus d''image', false, 4),
  (12, '1-3 %', false, 1), (12, '8-15 %', true, 2), (12, '30-40 %', false, 3), (12, '50 %+', false, 4),
  (13, '940 €', false, 1), (13, '1 200 €', false, 2), (13, '1 457 €', true, 3), (13, '2 000 €', false, 4),
  (14, 'Seulement facturer', false, 1), (14, 'Tarifer, négocier, comparer, optimiser', true, 2), (14, 'Gérer les paies', false, 3), (14, 'Recruter', false, 4),
  (15, 'Une charge variable', false, 1), (15, 'Une charge fixe annuelle', true, 2), (15, 'Un crédit', false, 3), (15, 'Un pourcentage', false, 4)
) as v(qorder, label, is_correct, "order")
join questions qu on qu."order"=v.qorder
join quizzes q on q.id=qu.quiz_id and q.title='Quiz — Coût de revient'
where not exists (select 1 from choices c where c.question_id=qu.id and c."order"=v."order");

-- =====================================================================
-- QUESTIONS — Quiz KPI et rentabilité
-- =====================================================================
insert into questions (quiz_id, statement, explanation, "order")
select q.id, v.statement, v.explanation, v."order"
from (values
  ('La règle "SMART" pour un KPI signifie :', 'Spécifique, Mesurable, Atteignable, Relevant, Temporellement défini.', 1),
  ('Le facteur d''émission du gazole est environ :', '3,17 kg CO₂ par litre (ADEME 2024).', 2),
  ('Combien de familles de KPI structurent un bon TDB ?', '4 : productivité, qualité, économique, sécurité/RSE.', 3),
  ('Que mesure le DSO ?', 'Days Sales Outstanding : délai moyen de paiement des clients en jours.', 4),
  ('La loi de Pareto en transport dit souvent :', '20 % des clients génèrent 80 % de la marge.', 5),
  ('La CSRD est applicable depuis :', '2024 (exercice 2024, rapport 2025), pour les grandes entreprises.', 6),
  ('Le bio-GNV permet une réduction de CO₂ de :', 'Environ -80 % par rapport au gazole fossile.', 7),
  ('Une ZFE est :', 'Une Zone à Faibles Émissions, restreignant l''accès selon Crit''Air.', 8),
  ('L''émission typique en longue distance est de :', '70-90 g CO₂ / tonne-kilomètre.', 9),
  ('Le label Objectif CO₂ est porté par :', 'L''ADEME en partenariat avec les fédérations professionnelles.', 10),
  ('Si un client génère 60 k€ CA et -3 k€ de marge, il faut :', 'Renégocier, restructurer, ou en dernier recours sortir (préavis 3 mois).', 11),
  ('Un bon nombre de KPI pilotés est de :', '10 à 12 maximum pour ne pas diluer l''attention.', 12),
  ('Que signifie SBTi ?', 'Science Based Targets initiative : alignement des engagements sur la trajectoire 1,5 °C.', 13),
  ('L''éco-conduite permet de réduire la consommation de :', '5 à 10 % selon la rigueur du programme.', 14),
  ('Une bonne pratique tarifaire : facturer strictement :', 'Les temps d''attente au-delà du délai franc, frais annexes (hayon, 2e présentation).', 15)
) as v(statement, explanation, "order")
cross join quizzes q
where q.title='Quiz — KPI et rentabilité'
  and not exists (select 1 from questions q2 where q2.quiz_id=q.id and q2."order"=v."order");

insert into choices (question_id, label, is_correct, "order")
select qu.id, v.label, v.is_correct, v."order"
from (values
  (1, 'Standard, Maintenable, Actuel, Rapide, Traçable', false, 1), (1, 'Spécifique, Mesurable, Atteignable, Relevant, Temporel', true, 2), (1, 'Simple, Moderne, Avancé, Rigoureux, Total', false, 3), (1, 'Stratégique, Marge, Actif, Rentable, Tactique', false, 4),
  (2, '1,5 kg CO₂/L', false, 1), (2, '2,5 kg CO₂/L', false, 2), (2, '3,17 kg CO₂/L', true, 3), (2, '5 kg CO₂/L', false, 4),
  (3, '2', false, 1), (3, '3', false, 2), (3, '4', true, 3), (3, '6', false, 4),
  (4, 'Coût de vente', false, 1), (4, 'Délai moyen de paiement client (jours)', true, 2), (4, 'Dépenses variables', false, 3), (4, 'Stock moyen', false, 4),
  (5, '50 % font 50 %', false, 1), (5, '20 % font 80 % de la marge', true, 2), (5, '10 % font 10 %', false, 3), (5, 'Tous égaux', false, 4),
  (6, '2020', false, 1), (6, '2024', true, 2), (6, '2026', false, 3), (6, '2030', false, 4),
  (7, '-10 %', false, 1), (7, '-30 %', false, 2), (7, '-80 %', true, 3), (7, '-100 %', false, 4),
  (8, 'Zone Frigo Européenne', false, 1), (8, 'Zone à Faibles Émissions', true, 2), (8, 'Zone Franche Électrique', false, 3), (8, 'Zone Fiscale Étendue', false, 4),
  (9, '10-20 g/t·km', false, 1), (9, '40-50 g/t·km', false, 2), (9, '70-90 g/t·km', true, 3), (9, '200+ g/t·km', false, 4),
  (10, 'L''ONU', false, 1), (10, 'L''ADEME et les fédérations', true, 2), (10, 'L''UE uniquement', false, 3), (10, 'La DREAL', false, 4),
  (11, 'Ne rien faire', false, 1), (11, 'Renégocier, restructurer, sortir', true, 2), (11, 'Augmenter les volumes', false, 3), (11, 'Baisser les prix', false, 4),
  (12, '3-5', false, 1), (12, '10-12', true, 2), (12, '25-30', false, 3), (12, '50+', false, 4),
  (13, 'Société de Bourse', false, 1), (13, 'Science Based Targets initiative', true, 2), (13, 'Safety Business Tool', false, 3), (13, 'Standard Business Transport', false, 4),
  (14, '1-2 %', false, 1), (14, '5-10 %', true, 2), (14, '25-35 %', false, 3), (14, '50 %+', false, 4),
  (15, 'Jamais', false, 1), (15, 'Temps d''attente et frais annexes', true, 2), (15, 'Seulement les péages', false, 3), (15, 'Uniquement le carburant', false, 4)
) as v(qorder, label, is_correct, "order")
join questions qu on qu."order"=v.qorder
join quizzes q on q.id=qu.quiz_id and q.title='Quiz — KPI et rentabilité'
where not exists (select 1 from choices c where c.question_id=qu.id and c."order"=v."order");


-- =====================================================================
-- QUESTIONS — Examen blanc Session 1 (30 questions avec cas pratiques)
-- =====================================================================
insert into questions (quiz_id, statement, explanation, "order")
select q.id, v.statement, v.explanation, v."order"
from (values
  ('[BC1] Après 4h30 de conduite continue, un conducteur doit prendre une pause de :', 'Règlement 561/2006 : 45 min (fractionnable 15+30 dans cet ordre).', 1),
  ('[BC1] CAS PRATIQUE : Un conducteur part à 6h00, conduit 4h30 puis fait une pause de 45 min. À partir de quelle heure peut-il reprendre la route ?', '6h00 + 4h30 = 10h30, fin de pause = 10h30 + 0h45 = 11h15.', 2),
  ('[BC1] CAS PRATIQUE : Conduite 4h30 + pause 45 min + conduite 3h30 + pause 45 min + conduite ? Combien de km possibles à 75 km/h moyen avec 9 h max ?', '9 h max − 8 h déjà faites = 1 h restante → 75 km.', 3),
  ('[BC1] CAS PRATIQUE : Un conducteur a enregistré 52 h de conduite cette semaine. Combien peut-il encore conduire ?', 'Plafond 56 h/sem → 56 − 52 = 4 h restantes.', 4),
  ('[BC1] La lettre de voiture CMR comporte combien d''exemplaires ?', '3 : rouge (expéditeur), bleu (transporteur), vert (destinataire).', 5),
  ('[BC1] CAS PRATIQUE : Lors de la livraison, 2 palettes sur 20 sont visiblement endommagées. Que faire ?', 'Porter des réserves précises (nombre, dommage, photos) sur la CMR avant signature.', 6),
  ('[BC1] La capacité financière exigée pour le 1er véhicule est :', '9 000 € selon règlement 1071/2009, puis 5 000 € par véhicule supplémentaire.', 7),
  ('[BC1] ADR : combien de classes de matières dangereuses ?', '9 classes (1 explosifs à 9 divers).', 8),
  ('[BC1] CAS PRATIQUE : Votre conducteur se voit contrôler à 15h30. Les contrôleurs demandent les données tachy. Sur combien de jours ?', 'Jour en cours + 28 jours précédents.', 9),
  ('[BC1] Le délai de prescription de l''action contre le transporteur est de :', '1 an à compter de la livraison (ou prévue).', 10),
  ('[BC2] CAS PRATIQUE : Votre sous-traitant réalise 87 livraisons conformes sur 100. Son OTIF est :', 'OTIF = 87/100 = 87 %. Insuffisant, plan de progrès à engager.', 11),
  ('[BC2] Vous devez vérifier l''attestation URSSAF d''un sous-traitant tous les :', '6 mois pour les contrats > 5 000 € HT (vigilance travail dissimulé).', 12),
  ('[BC2] CAS PRATIQUE : Votre commissionnaire est en redressement. Le chargeur peut-il être poursuivi par le sous-traitant ?', 'Oui, action directe L. 132-8 : paiement réclamable à expéditeur ou destinataire.', 13),
  ('[BC2] Dans un scoring d''appel d''offres, le critère "prix" pèse typiquement :', 'Environ 40 % dans une pondération équilibrée.', 14),
  ('[BC2] CAS PRATIQUE : Grille proposée à 1,35 €/km pour un marché 800 000 km/an. Votre CRKM est de 1,30 €/km. Marge ?', '(1,35 − 1,30) × 800 000 = 40 000 € soit 3,7 %, très faible.', 15),
  ('[BC2] Le contrat type général s''applique :', 'De plein droit en l''absence de convention écrite entre les parties.', 16),
  ('[BC2] Le délai légal de paiement en transport est :', '30 jours à compter de l''émission de la facture (L. 441-10).', 17),
  ('[BC2] La clause de révision gazole est :', 'D''ordre public, obligatoire > 3 mois (L. 3222-1).', 18),
  ('[BC3] CAS PRATIQUE : Charges fixes 95 000 €, variables 0,65 €/km, 110 000 km/an. CRKM ?', '(95 000/110 000) + 0,65 = 0,864 + 0,65 ≈ 1,51 €/km.', 19),
  ('[BC3] CAS PRATIQUE : Un AR de 600 km avec retour à vide et CRKM 1,40 €/km. Coût direct ?', '600 × 1,40 = 840 €. Ajouter marge, frais et risque pour le prix de vente.', 20),
  ('[BC3] Le carburant représente environ quelle part du coût total d''un PL 40 t ?', '30 à 35 % du coût total, premier poste de charges variables.', 21),
  ('[BC3] CAS PRATIQUE : Indice gazole passe de 1,45 à 1,60 €/L. Avec k=0,25 et P0=1000 €, quel prix révisé ?', 'P = 1000 × (1 + 0,25 × (1,60−1,45)/1,45) = 1000 × 1,0259 ≈ 1 025,90 €.', 22),
  ('[BC3] Cible usuelle du taux de remplissage en longue distance ?', 'Au moins 85 % pour rentabiliser le trajet.', 23),
  ('[BC3] Facteur d''émission du gazole (ADEME) :', '3,17 kg CO₂/L environ.', 24),
  ('[BC3] CAS PRATIQUE : Un client génère 75 k€ de CA et −4 k€ de marge sur 12 mois. Priorité d''action ?', 'Renégociation immédiate avec plan chiffré ; à défaut, restructuration ou sortie avec préavis.', 25),
  ('[BC3] L''éco-conduite peut réduire la consommation de :', '5 à 10 % selon programme et suivi.', 26),
  ('[BC3] Le point mort d''un véhicule est :', 'Le nombre de km nécessaire pour couvrir les charges fixes = fixes / marge km.', 27),
  ('[BC3] Dans une démarche PDCA, "D" signifie :', 'Do = mettre en œuvre l''action planifiée.', 28),
  ('[BC3] CAS PRATIQUE : Votre flotte émet 110 g CO₂/t·km. Bon/mauvais vs benchmark longue distance ?', 'Benchmark = 70-90 g/t·km → votre flotte est au-dessus, marge de progrès.', 29),
  ('[BC3] Une ZFE concerne quelles collectivités en France ?', 'Les métropoles de plus de 150 000 habitants (régulation selon Crit''Air).', 30)
) as v(statement, explanation, "order")
cross join quizzes q
where q.title='Examen blanc GOTRM — Session 1'
  and not exists (select 1 from questions q2 where q2.quiz_id=q.id and q2."order"=v."order");

insert into choices (question_id, label, is_correct, "order")
select qu.id, v.label, v.is_correct, v."order"
from (values
  (1, '30 min', false, 1), (1, '45 min', true, 2), (1, '1 h', false, 3), (1, '2 h', false, 4),
  (2, '10h30', false, 1), (2, '11h00', false, 2), (2, '11h15', true, 3), (2, '12h00', false, 4),
  (3, '0 km', false, 1), (3, '50 km', false, 2), (3, '75 km', true, 3), (3, '150 km', false, 4),
  (4, '0 h', false, 1), (4, '2 h', false, 2), (4, '4 h', true, 3), (4, '8 h', false, 4),
  (5, '1', false, 1), (5, '2', false, 2), (5, '3', true, 3), (5, '4', false, 4),
  (6, 'Signer sans réserves', false, 1), (6, 'Réserves précises et motivées sur la CMR', true, 2), (6, 'Refuser tout', false, 3), (6, 'Appeler la police', false, 4),
  (7, '5 000 €', false, 1), (7, '9 000 €', true, 2), (7, '15 000 €', false, 3), (7, '30 000 €', false, 4),
  (8, '5', false, 1), (8, '7', false, 2), (8, '9', true, 3), (8, '12', false, 4),
  (9, '7 jours', false, 1), (9, '14 jours', false, 2), (9, '28 jours', true, 3), (9, '90 jours', false, 4),
  (10, '6 mois', false, 1), (10, '1 an', true, 2), (10, '2 ans', false, 3), (10, '5 ans', false, 4),
  (11, '70 %', false, 1), (11, '80 %', false, 2), (11, '87 %', true, 3), (11, '100 %', false, 4),
  (12, '1 mois', false, 1), (12, '6 mois', true, 2), (12, '1 an', false, 3), (12, '3 ans', false, 4),
  (13, 'Non, jamais', false, 1), (13, 'Oui, action directe L. 132-8', true, 2), (13, 'Seulement avec décision de justice', false, 3), (13, 'Uniquement à l''étranger', false, 4),
  (14, '10 %', false, 1), (14, '25 %', false, 2), (14, '40 %', true, 3), (14, '70 %', false, 4),
  (15, '100 000 €', false, 1), (15, '40 000 €', true, 2), (15, '200 000 €', false, 3), (15, '0 €', false, 4),
  (16, 'Seulement si signé', false, 1), (16, 'De plein droit à défaut d''écrit', true, 2), (16, 'Jamais', false, 3), (16, 'Sur demande uniquement', false, 4),
  (17, '15 jours', false, 1), (17, '30 jours', true, 2), (17, '60 jours', false, 3), (17, '90 jours', false, 4),
  (18, 'Optionnelle', false, 1), (18, 'Obligatoire > 3 mois', true, 2), (18, 'Illégale', false, 3), (18, 'Seulement national', false, 4),
  (19, '1,15 €/km', false, 1), (19, '1,30 €/km', false, 2), (19, '1,51 €/km', true, 3), (19, '1,80 €/km', false, 4),
  (20, '500 €', false, 1), (20, '840 €', true, 2), (20, '1 200 €', false, 3), (20, '1 500 €', false, 4),
  (21, '10-15 %', false, 1), (21, '20-25 %', false, 2), (21, '30-35 %', true, 3), (21, '50-60 %', false, 4),
  (22, '1 000 €', false, 1), (22, '1 025,90 €', true, 2), (22, '1 150 €', false, 3), (22, '1 225 €', false, 4),
  (23, '50 %', false, 1), (23, '70 %', false, 2), (23, '85 %', true, 3), (23, '100 %', false, 4),
  (24, '1,5 kg/L', false, 1), (24, '2,2 kg/L', false, 2), (24, '3,17 kg/L', true, 3), (24, '5,5 kg/L', false, 4),
  (25, 'Ne rien faire', false, 1), (25, 'Renégocier / restructurer / sortir', true, 2), (25, 'Baisser les prix', false, 3), (25, 'Augmenter les volumes', false, 4),
  (26, '0-1 %', false, 1), (26, '5-10 %', true, 2), (26, '25-30 %', false, 3), (26, '50 %+', false, 4),
  (27, 'Le prix minimum', false, 1), (27, 'Charges fixes / marge au km', true, 2), (27, 'Le prix maximum', false, 3), (27, 'Le CRKM', false, 4),
  (28, 'Découvrir', false, 1), (28, 'Do = mettre en œuvre', true, 2), (28, 'Déléguer', false, 3), (28, 'Décider', false, 4),
  (29, 'Excellent, sous benchmark', false, 1), (29, 'Au-dessus du benchmark, marge de progrès', true, 2), (29, 'Impossible à interpréter', false, 3), (29, 'Sous 50 g/t·km', false, 4),
  (30, 'Toutes les communes', false, 1), (30, 'Métropoles > 150 000 hab.', true, 2), (30, 'Uniquement Paris', false, 3), (30, 'Aucune en France', false, 4)
) as v(qorder, label, is_correct, "order")
join questions qu on qu."order"=v.qorder
join quizzes q on q.id=qu.quiz_id and q.title='Examen blanc GOTRM — Session 1'
where not exists (select 1 from choices c where c.question_id=qu.id and c."order"=v."order");

-- =====================================================================
-- QUESTIONS — Examen blanc Session 2 (30 questions, focus cas pratiques)
-- =====================================================================
insert into questions (quiz_id, statement, explanation, "order")
select q.id, v.statement, v.explanation, v."order"
from (values
  ('[BC1] CAS PRATIQUE : Conducteur A a travaillé 10h de conduite hier et 10h aujourd''hui. Combien de fois est-ce autorisé par semaine ?', '2 fois max par semaine selon 561/2006.', 1),
  ('[BC1] CAS PRATIQUE : Livraison prévue à 14h chez un client. Votre conducteur arrive à 17h suite à un embouteillage. Action recommandée ?', 'Notifier proactivement le client, documenter l''aléa, facturer le temps d''attente si applicable.', 2),
  ('[BC1] Un conducteur transportant 500 kg de gazole est-il concerné par l''ADR ?', 'Le gazole est ADR classe 3 mais sous le seuil 1.1.3.6 (< 1000 points) des exemptions partielles.', 3),
  ('[BC1] Quelle forme doit prendre une réserve efficace sur la CMR ?', 'Précise, motivée, datée et signée contradictoirement par le conducteur.', 4),
  ('[BC1] CAS PRATIQUE : Repos journalier réduit à 9 h pris 4 fois dans la semaine. Conforme ?', 'Non : maximum 3 fois entre deux repos hebdomadaires.', 5),
  ('[BC1] Le conducteur d''un 26 t en messagerie urbaine est-il soumis au règlement 561/2006 ?', 'Oui, dès que le PTAC > 3,5 t.', 6),
  ('[BC1] CAS PRATIQUE : Marchandise refusée par le destinataire. Frais ?', 'Retour dépôt, stockage + 2e présentation facturables selon CGV/contrat type.', 7),
  ('[BC1] L''Incoterm EXW signifie :', 'Ex Works : vendeur met à disposition dans ses locaux, acheteur prend tout en charge.', 8),
  ('[BC1] Le conseiller à la sécurité ADR est obligatoire :', 'Pour les entreprises transportant, chargeant ou déchargeant des matières dangereuses au-delà des seuils.', 9),
  ('[BC1] CAS PRATIQUE : 3 cartons vides déclarés, 2 cartons manquants à la livraison. Plafond indemnisation si 3 t et 50 kg manquants ?', '50 × 14 € = 700 € (national, contrat type général).', 10),
  ('[BC2] CAS PRATIQUE : Sous-traitant Alpha : 150 k€ CA, OTIF 98 %, casse 0,08 %. Classement ?', 'Score A (vert) : performance excellente.', 11),
  ('[BC2] CAS PRATIQUE : Appel d''offres reçu le 1/3. Remise des offres le 30/3. Vous avez 1 semaine de congés du 10 au 17/3. Pouvez-vous répondre ?', 'Oui, il reste ~20 jours utiles. Organiser la réponse en amont/après les congés.', 12),
  ('[BC2] CAS PRATIQUE : Votre sous-traitant Bravo a son attestation URSSAF du 01/01. Aujourd''hui 15/08. Que faire ?', 'Demander une attestation à jour : l''obligation est semestrielle.', 13),
  ('[BC2] CAS PRATIQUE : Critères scoring : prix 40, qualité 30, capacité 20, RSE 10. Candidat obtient 15/20, 17/20, 14/20, 12/20. Score total ?', '(15×0,4)+(17×0,3)+(14×0,2)+(12×0,1) = 6+5,1+2,8+1,2 = 15,1/20.', 14),
  ('[BC2] Une pénalité de 50 % du prix du transport pour 1 jour de retard est :', 'Probablement disproportionnée donc susceptible d''être requalifiée.', 15),
  ('[BC2] Loi sur le devoir de vigilance : seuil d''assujettissement ?', '> 5 000 salariés en France (ou 10 000 à l''international).', 16),
  ('[BC2] CAS PRATIQUE : Transporteur dépose le bilan. Le chargeur a déjà payé le commissionnaire. Expose-t-il un risque ?', 'Oui : action directe L. 132-8 possible, paiement potentiellement dû deux fois.', 17),
  ('[BC2] Dans un bon contrat cadre, la clause de réversibilité :', 'Organise la transition et la restitution des données en fin de contrat.', 18),
  ('[BC3] CAS PRATIQUE : Véhicule : fixes 85 000 €, variables 0,70 €/km, 95 000 km/an. CRKM ?', '(85 000/95 000)+0,70 = 0,895+0,70 ≈ 1,59 €/km.', 19),
  ('[BC3] CAS PRATIQUE : Même véhicule, vous devez facturer un AR Paris-Nantes de 770 km avec 12 % de marge + 3 % frais. Prix de vente ?', '770 × 1,59 = 1 224,30 € × 1,15 = 1 407,95 € ≈ 1 408 € HT.', 20),
  ('[BC3] CAS PRATIQUE : Indice gazole 1,50 → 1,68 €/L. k=0,28, P0=2 500 €. Prix révisé ?', 'P = 2 500 × (1+0,28×(1,68−1,50)/1,50) = 2 500 × 1,0336 = 2 584 €.', 21),
  ('[BC3] CAS PRATIQUE : Flotte 50 véhicules, consommation moyenne 33 L/100 km, 100 000 km chacun. Emissions totales annuelles ?', '50 × 100 000 × 33/100 × 3,17 kg = 50 × 33 000 × 3,17 = ≈ 5 230 tonnes CO₂.', 22),
  ('[BC3] Le Comité National Routier publie :', 'Des indices de coûts mensuels par typologie de transport (pour révisions).', 23),
  ('[BC3] CAS PRATIQUE : Client X : CA 110 k€, km 60 k, CRKM alloué 1,45 €/km, litiges 2 500 €. Marge ?', '110 000 − (60 000 × 1,45) − 2 500 = 110 000 − 87 000 − 2 500 = 20 500 € (18,6 %).', 24),
  ('[BC3] Dans un scope émissions, la sous-traitance transport entre dans :', 'Scope 3 (émissions indirectes amont/aval).', 25),
  ('[BC3] CAS PRATIQUE : Point mort d''un véhicule : fixes 100 000 €, marge unitaire 0,70 €/km. Km ?', '100 000 / 0,70 ≈ 142 857 km.', 26),
  ('[BC3] Le HVO permet une réduction CO₂ d''environ :', 'Environ -85 % par rapport au gazole fossile (selon origine matière).', 27),
  ('[BC3] CAS PRATIQUE : Taux remplissage mesuré 72 %. Tournées organisées en lots complets FTL. Action recommandée ?', 'Chercher du groupage, massifier, revoir le plan de transport pour remonter vers 85 %.', 28),
  ('[BC3] Une assurance ad valorem couvre :', 'La valeur réelle de la marchandise au-delà des plafonds légaux (à la charge du chargeur en général).', 29),
  ('[BC3] CAS PRATIQUE : Réclamation client reçue le 5, traitée le 28. Délai ?', '23 jours : au-delà de la cible qualité (< 15 j), à améliorer.', 30)
) as v(statement, explanation, "order")
cross join quizzes q
where q.title='Examen blanc GOTRM — Session 2'
  and not exists (select 1 from questions q2 where q2.quiz_id=q.id and q2."order"=v."order");

insert into choices (question_id, label, is_correct, "order")
select qu.id, v.label, v.is_correct, v."order"
from (values
  (1, '1', false, 1), (1, '2', true, 2), (1, '3', false, 3), (1, 'Illimité', false, 4),
  (2, 'Ne rien dire', false, 1), (2, 'Notifier + documenter + facturer attente', true, 2), (2, 'Annuler la livraison', false, 3), (2, 'Facturer le double', false, 4),
  (3, 'Classe 9', false, 1), (3, 'Classe 3, sous seuil 1000 points', true, 2), (3, 'Classe 1', false, 3), (3, 'Non ADR du tout', false, 4),
  (4, 'Une mention "sous réserve"', false, 1), (4, 'Précise, motivée, datée, contradictoire', true, 2), (4, 'Orale uniquement', false, 3), (4, 'Sans signature', false, 4),
  (5, 'Oui, toujours possible', false, 1), (5, 'Non, max 3 fois', true, 2), (5, 'Oui 1 fois', false, 3), (5, 'Oui 5 fois', false, 4),
  (6, 'Non', false, 1), (6, 'Oui, PTAC > 3,5 t', true, 2), (6, 'Seulement en international', false, 3), (6, 'Uniquement > 26 t', false, 4),
  (7, 'Rien à facturer', false, 1), (7, 'Retour + stockage + 2e présentation', true, 2), (7, 'Rendre à l''expéditeur gratuitement', false, 3), (7, 'Détruire la marchandise', false, 4),
  (8, 'Vendeur livre chez acheteur', false, 1), (8, 'Mise à disposition en locaux vendeur', true, 2), (8, 'Vendeur paie la douane', false, 3), (8, 'Frais maritimes inclus', false, 4),
  (9, 'Pour toutes les entreprises', false, 1), (9, 'Dès qu''on charge/transporte/décharge MD > seuils', true, 2), (9, 'Jamais obligatoire', false, 3), (9, 'Seulement classe 1', false, 4),
  (10, '0 €', false, 1), (10, '700 €', true, 2), (10, '2 500 €', false, 3), (10, '14 000 €', false, 4),
  (11, 'C (rouge)', false, 1), (11, 'B (orange)', false, 2), (11, 'A (vert)', true, 3), (11, 'D', false, 4),
  (12, 'Non, impossible', false, 1), (12, 'Oui, ~20 jours utiles', true, 2), (12, 'Oui, sans préparation', false, 3), (12, 'Non, refuser la consultation', false, 4),
  (13, 'Rien, elle est valable 1 an', false, 1), (13, 'Demander une à jour (6 mois écoulés)', true, 2), (13, 'Résilier le contrat', false, 3), (13, 'Facturer une pénalité', false, 4),
  (14, '13,5/20', false, 1), (14, '14,7/20', false, 2), (14, '15,1/20', true, 3), (14, '16,2/20', false, 4),
  (15, 'Raisonnable', false, 1), (15, 'Disproportionnée, requalifiable', true, 2), (15, 'Insuffisante', false, 3), (15, 'Obligatoire', false, 4),
  (16, '500 salariés', false, 1), (16, '1 000', false, 2), (16, '5 000 en France', true, 3), (16, '50 000', false, 4),
  (17, 'Non, risque nul', false, 1), (17, 'Oui, risque action directe L. 132-8', true, 2), (17, 'Seulement si impayé', false, 3), (17, 'Risque à l''international uniquement', false, 4),
  (18, 'Interdit', false, 1), (18, 'Organise transition et restitution', true, 2), (18, 'Pénalités', false, 3), (18, 'Confidentialité', false, 4),
  (19, '1,30 €/km', false, 1), (19, '1,45 €/km', false, 2), (19, '1,59 €/km', true, 3), (19, '1,80 €/km', false, 4),
  (20, '1 200 €', false, 1), (20, '1 408 €', true, 2), (20, '1 650 €', false, 3), (20, '2 000 €', false, 4),
  (21, '2 500 €', false, 1), (21, '2 584 €', true, 2), (21, '2 800 €', false, 3), (21, '3 000 €', false, 4),
  (22, '1 200 t', false, 1), (22, '3 500 t', false, 2), (22, '~5 230 t', true, 3), (22, '12 000 t', false, 4),
  (23, 'Des taxes', false, 1), (23, 'Des indices de coûts mensuels', true, 2), (23, 'Des lois', false, 3), (23, 'Des formations', false, 4),
  (24, '5 000 €', false, 1), (24, '20 500 €', true, 2), (24, '50 000 €', false, 3), (24, '−10 000 €', false, 4),
  (25, 'Scope 1', false, 1), (25, 'Scope 2', false, 2), (25, 'Scope 3', true, 3), (25, 'Hors scope', false, 4),
  (26, '100 000 km', false, 1), (26, '~142 857 km', true, 2), (26, '200 000 km', false, 3), (26, '70 000 km', false, 4),
  (27, '-20 %', false, 1), (27, '-50 %', false, 2), (27, '-85 %', true, 3), (27, '-100 %', false, 4),
  (28, 'Rien à faire', false, 1), (28, 'Massifier / groupage pour remonter à 85 %', true, 2), (28, 'Diminuer la flotte', false, 3), (28, 'Augmenter les prix', false, 4),
  (29, 'RC du transporteur', false, 1), (29, 'Valeur réelle marchandise au-delà plafonds', true, 2), (29, 'Les salaires', false, 3), (29, 'Les véhicules', false, 4),
  (30, '15 j, conforme', false, 1), (30, '23 j, au-delà de la cible', true, 2), (30, 'Excellent délai', false, 3), (30, 'Anormalement rapide', false, 4)
) as v(qorder, label, is_correct, "order")
join questions qu on qu."order"=v.qorder
join quizzes q on q.id=qu.quiz_id and q.title='Examen blanc GOTRM — Session 2'
where not exists (select 1 from choices c where c.question_id=qu.id and c."order"=v."order");
