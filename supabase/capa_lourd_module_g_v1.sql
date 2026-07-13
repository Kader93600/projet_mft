-- =====================================================================
-- CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : MODULE G : NORMES TECHNIQUES
-- ET EXPLOITATION : v1 (juillet 2026) : LOT 7
--
-- Domaine G de l'annexe I du règlement (CE) n° 1071/2009 : masses et
-- dimensions des véhicules, surcharge, contrôle technique, équipements,
-- chargement/arrimage (contrats types, EN 12195), notions ADR.
-- Références : code de la route (R. 312-x masses et dimensions),
-- contrats types transport (code des transports), accord ADR.
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $capag$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid;
  v_l2 uuid;
  v_l3 uuid;
  v_l4 uuid;
  v_quiz uuid;
  v_q uuid;
  v_ord int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-plus-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-plus-3-5t introuvable.';
  END IF;

  INSERT INTO public.blocs (id, code, title, description, "order")
  VALUES (30, 'CAPA-LOURD', 'Capacité de transport lourd > 3,5 t',
          'Programme officiel de l''examen d''attestation de capacité professionnelle en transport routier lourd de marchandises (annexe I du règlement CE 1071/2009).', 30)
  ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'CAPA-LOURD';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'CAPA-LOURD-G-%';
  DELETE FROM public.modules WHERE slug = 'capa-lourd-normes-techniques-exploitation';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module G : Normes techniques et exploitation',
    'capa-lourd-normes-techniques-exploitation',
    v_bloc,
    'Le véhicule et son chargement : masses et dimensions réglementaires, surcharge et pesée, contrôle technique et équipements, répartition des charges et arrimage (contrats types, EN 12195), notions essentielles de l''ADR.',
    'intermediaire',
    540,
    70
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 70, true);

  -- ─── Leçon 1 : Masses et dimensions ────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'masses-dimensions-surcharge',
    'Masses, dimensions et surcharge',
    $mft$> 🎯 **Objectifs**
> - Mémoriser les masses et dimensions maximales des véhicules lourds.
> - Calculer une charge utile à partir du PTAC et du poids à vide.
> - Mesurer les risques et responsabilités de la surcharge.

## Les définitions à connaître

- **PV (poids à vide)** : véhicule en ordre de marche, sans chargement.
- **PTAC** : poids total autorisé en charge d'un véhicule isolé.
- **PTRA** : poids total roulant autorisé d'un ensemble (tracteur + semi-remorque, ou camion + remorque).
- **Charge utile (CU) = PTAC (ou PTRA) − poids à vide de l'ensemble.**

Exemple : ensemble articulé limité à 44 t, tracteur 7,4 t à vide + semi-remorque 7,6 t à vide → **charge utile = 44 − 15 = 29 t**.

## Les masses maximales en France

| Configuration | Masse maximale |
| --- | --- |
| Porteur 2 essieux | **19 t** |
| Porteur 3 essieux | **26 t** |
| Ensemble articulé 4 essieux | 38 t |
| Ensemble articulé **5 essieux et plus** | **44 t** |
| Charge maximale d'un essieu simple | **13 t** |

## Les dimensions maximales

| Dimension | Limite |
| --- | --- |
| Largeur | **2,55 m** (2,60 m pour les caisses frigorifiques) |
| Longueur ensemble articulé (tracteur + semi) | **16,50 m** |
| Longueur train routier (camion + remorque) | **18,75 m** |
| Hauteur | Pas de limite générale en France métropolitaine : vigilance ouvrages d'art (4 m et plus signalés) |

> ❌ **Piège à éviter**
> Le « 44 tonnes » n'est permis qu'avec **au moins 5 essieux**. Le même ensemble à 4 essieux est limité à 38 t : rouler à 44 t avec 4 essieux, c'est 6 t de surcharge ET des charges à l'essieu hors limites.

## La surcharge : un triple risque

1. **Sécurité** : distances de freinage allongées, tenue de route dégradée, usure prématurée (pneus, freins), risque accru de basculement.
2. **Sanctions** : amende par tranche de 1 000 kg de dépassement, aggravée pour les dépassements importants ; **immobilisation** du véhicule jusqu'à délestage ; responsabilité pénale possible du chef d'entreprise donneur d'instructions.
3. **Responsabilités civiles** : en cas d'accident, la surcharge pèse lourd dans le partage des responsabilités et vis-à-vis de l'assureur.

L'**expéditeur** engage aussi sa responsabilité lorsqu'il fournit une **déclaration de poids inexacte** : le transporteur documente les poids annoncés (lettre de voiture) et pèse en cas de doute (pont bascule).

> 💡 **Astuce**
> Réflexe de calcul avant chargement : CU disponible = PTRA − PV réel de l'ensemble (avec carburant plein et équipements). Comparer au poids annoncé de l'envoi AVANT d'accepter, pas au moment de la pesée de contrôle.

## ✅ Synthèse

- **19 t / 26 t / 38 t / 44 t (≥ 5 essieux)** ; essieu simple : **13 t**.
- **2,55 m** de large (2,60 frigo), **16,50 m** l'articulé, **18,75 m** le train routier.
- **CU = PTAC/PTRA − PV** ; surcharge : amendes par tranche, **immobilisation**, responsabilité de l'expéditeur en cas de fausse déclaration.$mft$,
    $mft$PV/PTAC/PTRA et charge utile (exemple 44 − 15 = 29 t), masses maximales (19/26/38/44 t, 13 t par essieu), dimensions (2,55 m, 16,50 m, 18,75 m), sanctions de la surcharge et responsabilité de l'expéditeur.$mft$,
    1, 50) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Véhicule en règle : CT, équipements, entretien ──────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'controle-technique-equipements-entretien',
    'Un véhicule en règle : contrôle technique, équipements, entretien',
    $mft$> 🎯 **Objectifs**
> - Tenir les échéances de contrôle technique des véhicules lourds.
> - Citer les équipements réglementaires du poids lourd.
> - Bâtir un plan d'entretien qui protège la sécurité et les coûts.

## Le contrôle technique des véhicules lourds

Les véhicules lourds passent une **visite technique annuelle** dans un centre agréé, la première dans l'année qui suit la mise en circulation. Points majeurs : freinage, direction, liaisons au sol, pollution, équipements. Résultat favorable = vignette et procès-verbal à bord ; défaillances majeures ou critiques = contre-visite, voire interdiction de circuler.

> 📌 **À retenir**
> PL = **contrôle technique tous les ans** (contre 2 ans pour une voiture). Rouler sans contrôle valide : amende, immobilisation possible, et position indéfendable en cas d'accident.

## Les équipements réglementaires du poids lourd

- **Limiteur de vitesse** : bridage à **90 km/h** pour les véhicules de transport de marchandises de plus de 3,5 t.
- **Chronotachygraphe** en état, étalonné et vérifié périodiquement en atelier agréé (module C).
- Signalisation : plaques réflectorisées, gyrophare le cas échéant, disque de limitation.
- Sécurité : extincteur selon les cas (obligatoire en ADR), triangle, gilet haute visibilité, cales.
- **Pneumatiques** : profondeur de sculpture réglementaire (1 mm pour les PL), état sans blessure, pressions conformes : premier poste de sécurité et de consommation.

## L'entretien : une obligation et un levier économique

Le gestionnaire de transport « veille à l'entretien des véhicules » (règlement 1071/2009, module F) : c'est une **obligation d'exploitation**, contrôlable, pas une option.

:::flow
1. Préventif | Plan constructeur : vidanges, freins, distribution
2. Prédictif | Télématique : usure, consommation, alertes
3. Correctif | Réparations tracées, véhicule de remplacement
:::

Un plan d'entretien rigoureux : moins de pannes (donc moins de force majeure impossible à plaider, module A), un contrôle technique passé du premier coup, une consommation maîtrisée (pneus, réglages), une valeur de revente préservée (module E : coût total de détention).

> 💡 **Astuce**
> Tenir un **dossier par véhicule** : factures d'entretien, PV de contrôle technique, étalonnages tachy, pneumatiques. C'est exactement ce que la DREAL demande en contrôle en entreprise : l'avoir prêt, c'est un contrôle qui se passe bien.

## Choisir ses véhicules : les critères

Norme **Euro** du moteur (accès aux **zones à faibles émissions**, péages différenciés), motorisation (gazole, gaz, électrique selon les tournées), PTAC/CU adaptés aux flux réels, carrosserie (tautliner, frigo, benne), télématique embarquée, coût total de détention plutôt que prix d'achat.

## ✅ Synthèse

- CT lourd : **annuel**, centre agréé, contre-visite si défaillances.
- Équipements : **limiteur 90 km/h**, tachy étalonné, signalisation, pneus ≥ **1 mm**.
- Entretien : obligation du gestionnaire, dossier par véhicule, levier de coût et de sécurité ; choix des véhicules au **coût total** et à la norme **Euro/ZFE**.$mft$,
    $mft$Contrôle technique annuel des PL, limiteur 90 km/h, équipements et pneumatiques (1 mm), plan d'entretien préventif/prédictif/correctif, dossier par véhicule et critères de choix (Euro, ZFE, TCO).$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Charger et arrimer ──────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'chargement-repartition-arrimage',
    'Charger, répartir, arrimer',
    $mft$> 🎯 **Objectifs**
> - Répartir un chargement sans dépasser les charges à l'essieu.
> - Appliquer la répartition des rôles des contrats types (3 tonnes).
> - Dimensionner un arrimage selon les forces en jeu.

## Répartir la charge

Un chargement mal réparti dépasse la **charge à l'essieu** (13 t max sur essieu simple) même sans surcharge totale, dégrade la **stabilité** (centre de gravité haut ou décalé) et peut **délester l'essieu directeur** (perte de direction). Règles de terrain : centrer la charge sur les essieux porteurs, abaisser le centre de gravité, répartir uniformément, verrouiller les éléments mobiles, recalculer après livraisons partielles (une tournée qui se vide se re-répartit).

## Qui charge, qui arrime ? La règle des contrats types

> 📌 **À retenir**
> Contrat type « général » : pour les **envois de moins de 3 tonnes**, le **transporteur** exécute le chargement, le calage et l'arrimage ; pour les **envois de 3 tonnes et plus**, ces opérations incombent à l'**expéditeur**, le transporteur fournissant les indications nécessaires et **vérifiant** que le chargement ne compromet pas la sécurité de la circulation.

Conséquence pratique : même quand l'expéditeur charge, le conducteur **contrôle** (répartition visible, arrimage, fermetures) et fait des **réserves** en cas d'anomalie : la sécurité routière reste sous la responsabilité du transporteur qui prend la route.

## Les forces en jeu (référentiel EN 12195)

Au freinage, la charge subit vers l'avant une force pouvant atteindre **0,8 fois son poids** ; latéralement et vers l'arrière, **0,5 fois**. Un lot de 10 t « pousse » donc jusqu'à 8 t vers la cabine au freinage d'urgence : l'arrimage se **calcule**, il ne se devine pas.

### Les méthodes

- **Arrimage par blocage** : la charge bute contre les parois, cloisons, barres : la structure encaisse.
- **Arrimage couvrant (par friction)** : sangles par-dessus, tension qui plaque la charge au plancher : efficacité dépendant de la tension et du coefficient de friction (tapis antiglisse).
- **Arrimage direct** : élingues/chaînes reliant les points d'ancrage de la charge à ceux du véhicule (charges lourdes, engins).

Matériel : sangles avec étiquette (capacité **LC**, tension STF), points d'ancrage en nombre suffisant, protections d'arêtes, tapis antiglisse. Une sangle coupée, nouée ou sans étiquette est **hors service**.

:::flow
1. Analyser | Poids, centre de gravité, points de butée disponibles
2. Choisir | Blocage, friction, direct, ou combinaison
3. Dimensionner | Nombre de sangles selon forces 0,8/0,5 et LC
4. Contrôler | Tension, protections, re-tension après quelques km
:::

> ⚠️ **Attention**
> Les avaries par défaut d'arrimage sont l'un des premiers postes de litige : photos au chargement, réserves précises sur la lettre de voiture à l'enlèvement comme à la livraison. Sans réserves, la présomption de responsabilité du transporteur (module A) s'applique à plein.

## ✅ Synthèse

- Charge répartie : respecter **13 t/essieu**, centre de gravité bas, re-répartir en tournée.
- **< 3 t : le transporteur charge et arrime ; ≥ 3 t : l'expéditeur**, le transporteur vérifie.
- Forces : **0,8 G avant / 0,5 G latéral-arrière** ; blocage, friction (antiglisse), direct ; sangles étiquetées (LC), réserves systématiques.$mft$,
    $mft$Répartition des charges (13 t/essieu, centre de gravité, re-répartition en tournée), règle des contrats types (3 tonnes), forces EN 12195 (0,8/0,5 G), méthodes d'arrimage et réserves.$mft$,
    3, 50) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Les bases de l'ADR ──────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'bases-adr-matieres-dangereuses',
    'Matières dangereuses : les bases de l''ADR',
    $mft$> 🎯 **Objectifs**
> - Situer le champ de l'ADR et ses neuf classes de danger.
> - Identifier les obligations : formation, conseiller, documents, équipements.
> - Reconnaître les exemptions utilisables par un transporteur généraliste.

## L'ADR en deux mots

L'**ADR** est l'accord européen relatif au transport international des marchandises dangereuses par route, appliqué aussi au trafic intérieur (arrêté « TMD »). Il classe les matières, impose emballages, étiquetage, documents, équipements, formation et organisation.

## Les neuf classes de danger

| Classe | Danger |
| --- | --- |
| 1 | Matières et objets explosibles |
| 2 | Gaz |
| 3 | Liquides inflammables (carburants, vernis, solvants) |
| 4 | Solides inflammables et assimilés |
| 5 | Comburants et peroxydes |
| 6 | Matières toxiques et infectieuses |
| 7 | Matières radioactives |
| 8 | Matières corrosives |
| 9 | Dangers divers (dont piles au lithium) |

## Les obligations principales

- **Formation** : conducteur titulaire d'un **certificat ADR** (formation de base, spécialisations citernes/explosifs/radioactifs) pour les transports non exemptés ; personnel d'exploitation sensibilisé (chapitre 1.3).
- **Conseiller à la sécurité TMD** : toute entreprise qui expédie, transporte, charge ou décharge des marchandises dangereuses au-delà des exemptions doit désigner un **conseiller à la sécurité** (interne ou externe), qui audite, conseille et établit le rapport annuel.
- **Documents de bord** : document de transport avec les mentions ADR (numéro ONU, désignation, classe, groupe d'emballage), **consignes écrites** (fiche réflexe accident), certificat de formation du conducteur.
- **Équipements** : extincteurs, calage, signalisation **panneau orange**, équipements de protection listés par les consignes écrites.
- **Étiquetage et placardage** : étiquettes de danger sur les colis, plaques-étiquettes et panneaux orange sur les véhicules selon les cas.

## Les exemptions à connaître

> 🔍 **Focus**
> - **Quantités limitées (LQ)** : petits conditionnements grand public (marquage spécifique) largement allégés.
> - **Exemption « 1.1.3.6 » dite des 1 000 points** : sous un seuil de quantité par unité de transport (calcul par catégorie de transport, plafond en « points »), le transport échappe à une grande partie des exigences (pas de certificat ADR conducteur, pas de panneau orange), la formation de sensibilisation et le document de transport restant requis.
> Ces exemptions font gagner beaucoup de souplesse au transporteur généraliste : encore faut-il **calculer** et documenter le respect du seuil.

## Sanctions et enjeux

Manquements ADR : amendes, immobilisation, responsabilité pénale en cas d'accident, et incidence sur l'**honorabilité** (module F) pour les infractions les plus graves. Au-delà de la sanction : un sinistre TMD engage des dommages potentiellement majeurs (personnes, environnement).

## ✅ Synthèse

- ADR : **9 classes** ; le généraliste croise surtout les classes 3, 8, 9 et 2.
- Obligations : **certificat conducteur**, **conseiller à la sécurité**, document de transport + **consignes écrites**, équipements, **panneau orange**.
- Exemptions **LQ** et **1 000 points** : à calculer et documenter ; en dessous, régime allégé mais jamais zéro obligation.$mft$,
    $mft$Champ de l'ADR et 9 classes de danger, obligations (certificat conducteur, conseiller à la sécurité, documents et consignes écrites, panneau orange), exemptions LQ et 1 000 points, sanctions.$mft$,
    4, 45) RETURNING id INTO v_l4;

  -- ─── Quiz d'entraînement ────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module,
    'Quiz : Normes techniques et exploitation',
    'Validez les fondamentaux du module G : masses et dimensions, contrôle technique, arrimage et ADR.',
    'entrainement', 70, false)
  RETURNING id INTO v_quiz;

  -- ─── QCM (12) : 4 faciles / 5 moyens / 3 difficiles ────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Quelle est la masse maximale autorisée en France pour un ensemble articulé d'au moins 5 essieux ?$mft$,
    $mft$[
      {"id":"a","label":"40 tonnes","is_correct":false},
      {"id":"b","label":"44 tonnes","is_correct":true},
      {"id":"c","label":"38 tonnes","is_correct":false},
      {"id":"d","label":"48 tonnes","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-g','qcm-v1'], 'CAPA-LOURD-G-QCM-01', false,
    $mft$44 t pour les ensembles d'au moins 5 essieux ; 38 t à 4 essieux. Le nombre d'essieux conditionne la masse totale ET le respect des charges à l'essieu.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$À quelle fréquence un véhicule lourd de transport de marchandises passe-t-il le contrôle technique ?$mft$,
    $mft$[
      {"id":"a","label":"Tous les 6 mois","is_correct":false},
      {"id":"b","label":"Tous les ans","is_correct":true},
      {"id":"c","label":"Tous les 2 ans","is_correct":false},
      {"id":"d","label":"Tous les 4 ans","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-g','qcm-v1'], 'CAPA-LOURD-G-QCM-02', false,
    $mft$Visite technique annuelle en centre agréé, la première dans l'année suivant la mise en circulation. Les voitures particulières sont à 2 ans : ne pas confondre.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Quelle est la largeur maximale autorisée d'un véhicule de transport (hors caisses frigorifiques) ?$mft$,
    $mft$[
      {"id":"a","label":"2,50 m","is_correct":false},
      {"id":"b","label":"2,55 m","is_correct":true},
      {"id":"c","label":"2,60 m","is_correct":false},
      {"id":"d","label":"3,00 m","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-g','qcm-v1'], 'CAPA-LOURD-G-QCM-03', false,
    $mft$2,55 m en général ; 2,60 m admis pour les véhicules à caisse frigorifique (parois épaisses). Au-delà : transport exceptionnel.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Combien l'ADR compte-t-il de classes de danger ?$mft$,
    $mft$[
      {"id":"a","label":"6","is_correct":false},
      {"id":"b","label":"9","is_correct":true},
      {"id":"c","label":"12","is_correct":false},
      {"id":"d","label":"15","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-g','qcm-v1'], 'CAPA-LOURD-G-QCM-04', false,
    $mft$Neuf classes, des explosibles (1) aux dangers divers (9, dont piles au lithium). Le généraliste croise surtout les classes 3 (liquides inflammables), 8 (corrosifs) et 9.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Quelle est la masse maximale d'un porteur à 2 essieux ?$mft$,
    $mft$[
      {"id":"a","label":"16 tonnes","is_correct":false},
      {"id":"b","label":"19 tonnes","is_correct":true},
      {"id":"c","label":"26 tonnes","is_correct":false},
      {"id":"d","label":"12 tonnes","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-g','qcm-v1'], 'CAPA-LOURD-G-QCM-05', false,
    $mft$Porteur 2 essieux : 19 t ; 3 essieux : 26 t. La charge maximale d'un essieu simple (13 t) reste à respecter dans la répartition.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Quelle est la longueur maximale d'un ensemble articulé (tracteur + semi-remorque) ?$mft$,
    $mft$[
      {"id":"a","label":"15,00 m","is_correct":false},
      {"id":"b","label":"16,50 m","is_correct":true},
      {"id":"c","label":"18,75 m","is_correct":false},
      {"id":"d","label":"20,00 m","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-g','qcm-v1'], 'CAPA-LOURD-G-QCM-06', false,
    $mft$16,50 m pour l'ensemble articulé ; 18,75 m pour le train routier (porteur + remorque). Deux chiffres à ne pas intervertir à l'examen.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Selon le contrat type général, qui exécute le chargement, le calage et l'arrimage pour un envoi de 12 tonnes ?$mft$,
    $mft$[
      {"id":"a","label":"L'expéditeur, le transporteur vérifiant que le chargement ne compromet pas la sécurité","is_correct":true},
      {"id":"b","label":"Le transporteur dans tous les cas","is_correct":false},
      {"id":"c","label":"Le destinataire","is_correct":false},
      {"id":"d","label":"Un prestataire agréé par la DREAL","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-g','qcm-v1'], 'CAPA-LOURD-G-QCM-07', false,
    $mft$Règle des 3 tonnes : envois ≥ 3 t chargés/calés/arrimés par l'expéditeur, le transporteur fournissant les indications et vérifiant ; envois < 3 t : opérations à la charge du transporteur.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$À quelle vitesse le limiteur des véhicules de transport de marchandises de plus de 3,5 t est-il réglé ?$mft$,
    $mft$[
      {"id":"a","label":"80 km/h","is_correct":false},
      {"id":"b","label":"90 km/h","is_correct":true},
      {"id":"c","label":"100 km/h","is_correct":false},
      {"id":"d","label":"110 km/h","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-g','qcm-v1'], 'CAPA-LOURD-G-QCM-08', false,
    $mft$Limiteur réglé à 90 km/h pour les véhicules de marchandises de plus de 3,5 t. Neutraliser ou trafiquer le limiteur est une infraction grave.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un ensemble a un PTRA de 44 t ; le tracteur pèse 7,4 t à vide et la semi-remorque 7,6 t à vide. Quelle est la charge utile ?$mft$,
    $mft$[
      {"id":"a","label":"29 tonnes","is_correct":true},
      {"id":"b","label":"36,6 tonnes","is_correct":false},
      {"id":"c","label":"44 tonnes","is_correct":false},
      {"id":"d","label":"22 tonnes","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-g','qcm-v1'], 'CAPA-LOURD-G-QCM-09', false,
    $mft$CU = PTRA − poids à vide de l'ensemble = 44 − (7,4 + 7,6) = 44 − 15 = 29 t. Toujours déduire les DEUX poids à vide, tracteur et semi.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Quelle est la charge maximale autorisée sur un essieu simple en France ?$mft$,
    $mft$[
      {"id":"a","label":"10 tonnes","is_correct":false},
      {"id":"b","label":"11,5 tonnes","is_correct":false},
      {"id":"c","label":"13 tonnes","is_correct":true},
      {"id":"d","label":"16 tonnes","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-g','qcm-v1'], 'CAPA-LOURD-G-QCM-10', false,
    $mft$13 t sur essieu simple en France. Une répartition défaillante peut dépasser cette limite sans dépasser la masse totale : les deux contrôles sont distincts à la pesée.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Au freinage d'urgence, quelle force vers l'avant l'arrimage doit-il pouvoir retenir (référentiel EN 12195) ?$mft$,
    $mft$[
      {"id":"a","label":"0,5 fois le poids de la charge","is_correct":false},
      {"id":"b","label":"0,8 fois le poids de la charge","is_correct":true},
      {"id":"c","label":"1,5 fois le poids de la charge","is_correct":false},
      {"id":"d","label":"0,2 fois le poids de la charge","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-g','qcm-v1'], 'CAPA-LOURD-G-QCM-11', false,
    $mft$0,8 G vers l'avant, 0,5 G en latéral et vers l'arrière : un lot de 10 t pousse jusqu'à 8 t vers la cabine. L'arrimage se dimensionne par calcul (LC des sangles, friction, blocage).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Une entreprise expédie et transporte régulièrement des marchandises dangereuses au-delà des seuils d'exemption. Que doit-elle faire ?$mft$,
    $mft$[
      {"id":"a","label":"Désigner un conseiller à la sécurité TMD (interne ou externe)","is_correct":true},
      {"id":"b","label":"Simplement souscrire une assurance spécifique","is_correct":false},
      {"id":"c","label":"Demander une licence communautaire renforcée","is_correct":false},
      {"id":"d","label":"Rien de particulier si les quantités restent raisonnables","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-g','qcm-v1'], 'CAPA-LOURD-G-QCM-12', false,
    $mft$Le conseiller à la sécurité TMD est obligatoire au-delà des exemptions : il audite les procédures, conseille l'entreprise et établit un rapport annuel. S'y ajoutent formation des conducteurs, documents et équipements.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$À quelle condition d'essieux un ensemble articulé peut-il circuler à 44 tonnes en France ?$mft$,
   $mft$Avec au moins 5 essieux.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-g','question-courte'], 'CAPA-LOURD-G-QC-01', false,
   $mft$À 4 essieux, la limite retombe à 38 t.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Quelle est la périodicité du contrôle technique d'un poids lourd ?$mft$,
   $mft$Annuelle (première visite dans l'année suivant la mise en circulation).$mft$,
   2, 'facile', ARRAY['capa-lourd','module-g','question-courte'], 'CAPA-LOURD-G-QC-02', false,
   $mft$Accepter « tous les ans ».$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Quelle est la largeur maximale d'un véhicule, et l'exception admise ?$mft$,
   $mft$2,55 m en général ; 2,60 m pour les caisses frigorifiques.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-g','question-courte'], 'CAPA-LOURD-G-QC-03', false,
   $mft$Exiger les deux valeurs.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Que désigne le PTRA d'un ensemble routier ?$mft$,
   $mft$Le poids total roulant autorisé : la masse maximale de l'ensemble tracteur + remorque (ou semi-remorque) en charge.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-g','question-courte'], 'CAPA-LOURD-G-QC-04', false,
   $mft$À distinguer du PTAC (véhicule isolé).$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Donnez la formule de la charge utile d'un ensemble routier.$mft$,
   $mft$Charge utile = PTRA (ou PTAC) − poids à vide de l'ensemble (tracteur + semi-remorque).$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-g','question-courte'], 'CAPA-LOURD-G-QC-05', false,
   $mft$Penser à déduire les deux poids à vide.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Quelle est la longueur maximale d'un train routier (porteur + remorque) ?$mft$,
   $mft$18,75 m.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-g','question-courte'], 'CAPA-LOURD-G-QC-06', false,
   $mft$Contre 16,50 m pour l'ensemble articulé.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quelle force vers l'avant l'arrimage doit-il retenir au freinage, en proportion du poids de la charge ?$mft$,
   $mft$0,8 fois le poids de la charge (0,8 G) ; 0,5 G en latéral et vers l'arrière.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-g','question-courte'], 'CAPA-LOURD-G-QC-07', false,
   $mft$Référentiel EN 12195 ; le 0,8 avant est l'élément attendu.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Selon le contrat type général, à qui incombent le chargement, le calage et l'arrimage d'un envoi de 3 tonnes et plus ?$mft$,
   $mft$À l'expéditeur, le transporteur fournissant les indications nécessaires et vérifiant que le chargement ne compromet pas la sécurité.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-g','question-courte'], 'CAPA-LOURD-G-QC-08', false,
   $mft$En dessous de 3 t : opérations à la charge du transporteur.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Quelle est la charge maximale sur un essieu simple en France ?$mft$,
   $mft$13 tonnes.$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-g','question-courte'], 'CAPA-LOURD-G-QC-09', false,
   $mft$Contrôlée indépendamment de la masse totale lors des pesées.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Comment s'appelle l'exemption ADR qui permet, sous un seuil de quantités par unité de transport, d'échapper à une grande partie des exigences (certificat conducteur, panneau orange) ?$mft$,
   $mft$L'exemption liée aux quantités par unité de transport, dite « des 1 000 points » (1.1.3.6).$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-g','question-courte'], 'CAPA-LOURD-G-QC-10', false,
   $mft$Accepter « 1 000 points » ; la sensibilisation du personnel et le document de transport restent dus.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Définissez PV, PTAC, PTRA et charge utile, puis calculez : un tracteur de 7,9 t à vide attelé à une semi-remorque de 7,1 t à vide, ensemble autorisé à 44 t. Quelle charge utile ? Quel poids total si l'on charge 27 t ?$mft$,
   $mft$Réponse modèle. PV : poids du véhicule à vide en ordre de marche. PTAC : poids total autorisé en charge d'un véhicule isolé. PTRA : poids total roulant autorisé d'un ensemble (tracteur + semi ou porteur + remorque). Charge utile : ce que l'on peut charger = PTRA (ou PTAC) − poids à vide de l'ensemble. Calcul : poids à vide de l'ensemble = 7,9 + 7,1 = 15 t ; charge utile = 44 − 15 = 29 t. Avec 27 t chargées : poids total = 15 + 27 = 42 t, inférieur au PTRA de 44 t : l'ensemble est en règle sur la masse totale, sous réserve du respect des charges à l'essieu (13 t maximum sur essieu simple) grâce à une répartition correcte.$mft$,
   $mft$Barème /5 : quatre définitions exactes (2 pts) ; CU = 29 t avec le détail (1,5 pt) ; poids total 42 t et conclusion de conformité (1 pt) ; réserve sur les charges à l'essieu (0,5 pt). Erreurs fréquentes : oublier un des deux poids à vide ; confondre PTAC et PTRA.$mft$,
   5, 'facile', ARRAY['capa-lourd','module-g','question-redigee'], 'CAPA-LOURD-G-QR-01', false,
   $mft$Définitions + calcul de base des masses, incontournable.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Présentez les obligations qui garantissent qu'un poids lourd est « en règle » techniquement (contrôle technique, équipements, entretien) et expliquez le rôle du gestionnaire de transport à cet égard.$mft$,
   $mft$Réponse modèle. Contrôle technique : visite annuelle en centre agréé (première dans l'année suivant la mise en circulation) ; défaillances majeures/critiques = contre-visite voire interdiction de circuler ; preuve à bord. Équipements : limiteur de vitesse réglé à 90 km/h, chronotachygraphe étalonné et vérifié périodiquement, pneumatiques conformes (sculpture minimale 1 mm pour les PL, état, pressions), signalisation et équipements de sécurité (triangle, gilet, extincteur selon les cas). Entretien : le règlement 1071/2009 confie au gestionnaire de transport le soin de veiller à l'entretien des véhicules : plan de maintenance préventive (échéances constructeur), suivi des alertes (télématique), réparations tracées ; dossier par véhicule (factures, PV de CT, étalonnages) présentable en contrôle DREAL. Enjeux : sécurité routière, validité de l'exploitation (un véhicule non conforme immobilisé désorganise les tournées), coûts (consommation, pannes, valeur de revente) et responsabilité : en cas d'accident avec un défaut d'entretien connu, l'entreprise et son gestionnaire répondent de leur carence.$mft$,
   $mft$Barème /5 : CT annuel et conséquences (1,5 pt) ; au moins trois équipements réglementaires dont limiteur 90 (1,5 pt) ; entretien organisé + dossier par véhicule (1 pt) ; rôle du gestionnaire et enjeu de responsabilité (1 pt). Erreurs fréquentes : CT à 2 ans ; réduire l'entretien à une question de coûts sans le volet réglementaire.$mft$,
   5, 'facile', ARRAY['capa-lourd','module-g','question-redigee'], 'CAPA-LOURD-G-QR-02', false,
   $mft$Vue d'ensemble conformité technique, transversale avec le module F.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Cas pratique. À la pesée, votre ensemble 5 essieux affiche 45,8 t pour 44 t autorisées. Le client avait annoncé 28 t de marchandises sur la lettre de voiture ; la charge utile de l'ensemble est de 29 t. Analysez la situation : infractions, conséquences immédiates, responsabilités et actions correctives.$mft$,
   $mft$Réponse modèle. Constat : dépassement de 1,8 t de la masse maximale autorisée. Analyse des causes : CU 29 t et poids annoncé 28 t auraient dû passer (15 + 28 = 43 t) : le chargement réel pèse donc environ 30,8 t, soit près de 2,8 t de plus que la déclaration : déclaration de poids inexacte de l'expéditeur probable (ou pesée d'origine défaillante). Conséquences immédiates : amende par tranche de 1 000 kg de dépassement (deux tranches entamées), immobilisation possible du véhicule jusqu'à délestage : organiser le transbordement de l'excédent, retard et coûts. Responsabilités : le transporteur répond de la circulation d'un véhicule en surcharge, mais l'expéditeur engage sa responsabilité pour la fausse déclaration (recours possible, y compris pour les frais d'immobilisation) : la lettre de voiture mentionnant les 28 t annoncés est la pièce clé. Actions : réserves écrites immédiates, pesée contradictoire documentée, refacturation des surcoûts à l'expéditeur, et en prévention : peser au chargement en cas de doute (pont bascule, capteurs), clauses contractuelles sur les écarts de poids, sensibiliser ce client.$mft$,
   $mft$Barème /5 : chiffrage correct de l'écart réel (~2,8 t vs déclaration) (1,5 pt) ; sanctions et immobilisation (1 pt) ; partage des responsabilités transporteur/expéditeur avec le rôle de la lettre de voiture (1,5 pt) ; actions correctives et préventives (1 pt). Erreurs fréquentes : s'arrêter aux 1,8 t sans remonter à la fausse déclaration ; oublier l'immobilisation.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-g','question-redigee'], 'CAPA-LOURD-G-QR-03', false,
   $mft$Cas de surcharge complet : calcul, droit et réaction opérationnelle.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Expliquez pourquoi la répartition de la charge importe autant que son poids total, et donnez la méthode pratique pour bien répartir un chargement de palettes dans une semi-remorque, y compris en cours de tournée.$mft$,
   $mft$Réponse modèle. Enjeux : une masse totale conforme peut masquer un essieu en dépassement (13 t maximum sur essieu simple) : infraction à la pesée par essieu ; un centre de gravité haut ou décalé dégrade stabilité et freinage (risque de renversement en courbe) ; un avant délesté réduit l'adhérence de l'essieu directeur (perte de direction) ; enfin la structure du plancher a ses limites locales. Méthode : connaître les reports de charge (abaques ou calculateur de chargement) ; placer les palettes lourdes centrées sur la zone des essieux porteurs, en abaissant le centre de gravité (lourd en bas) ; répartir symétriquement gauche/droite ; combler ou caler les vides pour empêcher tout déplacement ; verrouiller portes et cloisons. En tournée : après chaque livraison partielle, re-répartir et re-tendre l'arrimage : une semi qui se vide de l'arrière concentre la charge restante et peut surcharger un essieu ou déstabiliser l'ensemble. Trace : plan de chargement, photos, consignes aux conducteurs.$mft$,
   $mft$Barème /5 : les trois risques distincts (essieu, stabilité/CdG, délestage directeur) (2 pts) ; méthode de placement concrète (1,5 pt) ; ré-équilibrage en cours de tournée (1 pt) ; traçabilité/consignes (0,5 pt). Erreurs fréquentes : raisonner uniquement en masse totale ; ignorer l'effet des livraisons partielles.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-g','question-redigee'], 'CAPA-LOURD-G-QR-04', false,
   $mft$Répartition des charges : risques et méthode opérationnelle.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Litige. Un envoi de 8 tonnes de machines, chargé et arrimé par l'expéditeur, arrive endommagé : les sangles ont lâché dans une bretelle. Le client réclame au transporteur. Analysez les responsabilités au regard du contrat type et dites comment le conducteur aurait dû sécuriser la situation au départ.$mft$,
   $mft$Réponse modèle. Règle applicable : envoi ≥ 3 t : le chargement, le calage et l'arrimage incombaient à l'expéditeur (contrat type général). Mais le transporteur reste présumé responsable des avaries survenues pendant le transport (module A) : pour s'exonérer, il doit prouver que le dommage provient d'un arrimage défectueux réalisé par l'expéditeur : la cause exonératoire type « faute de l'expéditeur ». Éléments décisifs : réserves formulées AU DÉPART sur la lettre de voiture (arrimage insuffisant, sangles inadaptées), photos, refus éventuel de partir sans correction : le conducteur doit vérifier que le chargement ne compromet pas la sécurité et signaler toute anomalie apparente ; sans réserve au départ, prouver la faute de l'expéditeur devient difficile et la présomption joue contre le transporteur. Au cas présent : si l'arrimage était visiblement défaillant et sans réserve, le transporteur supporte une part de responsabilité (défaut de vérification) ; si le vice était caché (sangles d'apparence correcte mais défectueuses), la faute de l'expéditeur est plaidable. Conduite au départ : contrôle visuel systématique, exigence de correction, réserves écrites précises, sinon refus de prise en charge ; en roulant : re-tension après les premiers kilomètres.$mft$,
   $mft$Barème /5 : règle des 3 t correctement appliquée (1 pt) ; articulation avec la présomption de responsabilité et la cause exonératoire (1,5 pt) ; rôle décisif des réserves au départ (1,5 pt) ; conduite pratique du conducteur (1 pt). Erreurs fréquentes : croire que « l'expéditeur a chargé » suffit à exonérer ; oublier le devoir de vérification du transporteur.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-g','question-redigee'], 'CAPA-LOURD-G-QR-05', false,
   $mft$Litige d'arrimage croisant contrats types et présomption de responsabilité (module A).$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Rédigez la check-list de départ d'un conducteur de poids lourd, organisée en trois volets : documents, véhicule, chargement. Précisez pour chaque item pourquoi il compte.$mft$,
   $mft$Réponse modèle. Documents : permis CE et carte de qualification (CQC) valides (droit de conduire), carte de conducteur tachy (traçabilité, module C), copie conforme de la licence (contrôle DREAL, module F), lettre de voiture complétée (preuve du contrat et des poids annoncés), documents ADR le cas échéant (consignes écrites, certificat), attestation de contrôle technique et assurance à bord. Véhicule : contrôle visuel de sécurité : pneumatiques (état, pression), freinage (fuites d'air), éclairage et signalisation, rétroviseurs, attelage et béquilles, niveaux, propreté des plaques ; tachygraphe fonctionnel, carte insérée, sélecteur d'activité correct ; carburant et AdBlue. Chargement : conformité poids annoncé/CU (pas de surcharge), répartition correcte (essieux, centre de gravité), arrimage vérifié (tension, protections, antiglisse), portes et hayon verrouillés, réserves écrites si anomalie. Pourquoi : chaque volet neutralise une famille de risques : sanction administrative (documents), accident mécanique (véhicule), avarie/renversement et responsabilité (chargement) ; la check-list signée trace la diligence de l'entreprise.$mft$,
   $mft$Barème /5 : volet documents complet dont CQC + copie conforme + LV (1,5 pt) ; volet véhicule avec les points de sécurité majeurs (1,5 pt) ; volet chargement avec poids/répartition/arrimage/réserves (1,5 pt) ; justifications et logique de traçabilité (0,5 pt). Erreurs fréquentes : oublier la copie conforme ou la CQC ; check-list « moteur » sans le volet chargement.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-g','question-redigee'], 'CAPA-LOURD-G-QR-06', false,
   $mft$Check-list opérationnelle transversale (modules C, F, G).$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas professionnel. Une PME de transport général se voit proposer de livrer chaque semaine des fûts de vernis (liquide inflammable, classe 3) pour un client industriel. Analysez les obligations ADR applicables et la démarche pour accepter ce trafic en règle, y compris l'hypothèse d'une exemption.$mft$,
   $mft$Réponse modèle. Qualification : vernis = marchandise dangereuse de classe 3 : l'ADR s'applique (emballages homologués, étiquetage des colis, document de transport avec numéro ONU et mentions, interdictions de chargement en commun le cas échéant). Démarche : 1) obtenir du client les informations produit (numéro ONU, groupe d'emballage, quantités par envoi) ; 2) vérifier l'hypothèse d'exemption « 1 000 points » (1.1.3.6) : selon la catégorie de transport du produit et les quantités hebdomadaires par unité de transport, le trafic peut rester sous le seuil : alors pas de certificat ADR conducteur ni de panneau orange, mais formation de sensibilisation (1.3) du personnel, document de transport conforme et équipements de base ; calcul documenté et contrôlé à chaque envoi ; 3) si le seuil est dépassé : conducteurs titulaires du certificat ADR de base, consignes écrites à bord, extincteurs et équipements listés, panneau orange, et désignation d'un conseiller à la sécurité TMD (interne ou externe) avec rapport annuel ; 4) dans tous les cas : vérifier l'assurance (extension TMD), former les exploitants, intégrer les surcoûts au prix (module E) et tracer les quantités transportées. Refuser le trafic tant que la conformité n'est pas en place : un sinistre TMD non conforme est indéfendable.$mft$,
   $mft$Barème /5 : qualification classe 3 + exigences colis/document (1 pt) ; exemption 1 000 points correctement expliquée avec ses limites (1,5 pt) ; régime complet au-delà du seuil (certificat, consignes, panneau orange, conseiller) (1,5 pt) ; démarche de décision et gestion des risques (assurance, prix, traçabilité) (1 pt). Erreurs fréquentes : tout ou rien (ignorer l'exemption OU s'en servir sans calcul) ; oublier le conseiller à la sécurité.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-g','question-redigee'], 'CAPA-LOURD-G-QR-07', false,
   $mft$Cas ADR réaliste pour transporteur généraliste, avec l'arbre de décision exemption/régime complet.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre flotte de 18 tracteurs (normes Euro V et VI) dessert de plus en plus de métropoles à zones à faibles émissions. Construisez la réflexion de renouvellement : critères techniques, économiques et réglementaires, et étapes d'un plan à 3 ans.$mft$,
   $mft$Réponse modèle. Critères réglementaires : cartographier les ZFE desservies et leurs calendriers de restriction (vignettes Crit'Air) : les Euro V risquent l'exclusion progressive des centres : croiser tournées réelles et restrictions pour prioriser. Critères techniques : motorisations alternatives (gaz, électrique, HVO selon disponibilité) vs Euro VI diesel récent : autonomie, charge utile préservée, réseau d'avitaillement sur les lignes, maintenance et compétences atelier. Critères économiques : coût total de détention comparé (prix ou loyers, énergie, entretien, péages différenciés, fiscalité et aides à l'acquisition éventuelles, valeur de revente des Euro V avant décote), impact sur la capacité financière (capitaux propres, module F) et choix de financement (achat/crédit-bail, module E). Plan à 3 ans : année 1 : remplacer les Euro V les plus exposés aux ZFE (affectations urbaines), tester une motorisation alternative sur une ligne adaptée ; année 2 : étendre selon retour d'expérience (consommation réelle, disponibilité), renégocier les financements ; année 3 : solde des Euro V, flotte cœur en Euro VI/alternatif ; en continu : réaffecter les véhicules anciens aux tournées hors ZFE, former les conducteurs (éco-conduite, spécificités), suivre les indicateurs (coût/km par motorisation).$mft$,
   $mft$Barème /5 : croisement ZFE/tournées comme point de départ (1,5 pt) ; critères techniques ET économiques structurés dont TCO (2 pts) ; plan séquencé réaliste avec réaffectations (1 pt) ; indicateurs de suivi (0,5 pt). Erreurs fréquentes : plan « tout électrique » sans analyse des lignes ; ignorer la valeur de revente et le calendrier ZFE.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-g','question-redigee'], 'CAPA-LOURD-G-QR-08', false,
   $mft$Stratégie de flotte face aux ZFE, sujet d'actualité transversal E/F/G.$mft$);

  RAISE NOTICE 'Module G Capa lourd créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $capag$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Volumes : select "type", active, count(*) from question_bank
--     where source_ref like 'CAPA-LOURD-G-%' group by 1, 2;
--    → attendu : qcm/false = 12, qr/false = 18.
-- 2) QCM à bonne réponse unique :
--    select source_ref from question_bank
--     where source_ref like 'CAPA-LOURD-G-QCM-%'
--       and (select count(*) from jsonb_array_elements(choices) c
--             where (c->>'is_correct')::boolean) <> 1;   → 0 ligne.
-- 3) Doublons d'énoncés sur la formation :
--    select statement, count(*) from question_bank
--     where formation_id = (select id from formations where slug='capacite-plus-3-5t')
--     group by 1 having count(*) > 1;                    → 0 ligne.
