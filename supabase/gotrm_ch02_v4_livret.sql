-- =====================================================================
-- GOTRM — Chapitre 2 : Les véhicules, les carrosseries et les marchandises
-- Source : Livret CCP1 GOTRM V2 (pages 6-10)
-- Version : v4 livret (reproduction fidèle du PDF)
-- =====================================================================

DO $ch02_v4$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson uuid;
  v_quiz uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;

  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
  IF v_bloc IS NULL THEN
    INSERT INTO public.blocs (code, title, description, "order")
    VALUES ('BC1', 'Bloc 1 — Compétences générales', 'Bloc générique partagé.', 1)
    ON CONFLICT (code) DO NOTHING RETURNING id INTO v_bloc;
    IF v_bloc IS NULL THEN SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1'; END IF;
  END IF;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Bloc BC1 introuvable.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-ch02-vehicules-marchandises';

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch02:%';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Chapitre 2 — Les véhicules, les carrosseries et les marchandises',
          'gotrm-ch02-vehicules-marchandises', v_bloc,
          'Maîtriser les types de véhicules, carrosseries, poids réglementaires (PTAC, PTRA, PMA, CU), notions de poids taxable et de mètre linéaire, ainsi que les règles d''arrimage et d''optimisation du chargement.',
          'intermediaire', 75, 20)
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 20, true) ON CONFLICT DO NOTHING;

  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (v_module, 'Les véhicules, les carrosseries et les marchandises',
          'vehicules-carrosseries-marchandises', 1, 75,
$lesson$
# Les véhicules, les carrosseries et les marchandises

> 🎯 **Objectifs pédagogiques**
>
> Maîtriser les types de véhicules et carrosseries, identifier les poids et dimensions réglementaires, calculer un poids taxable, et appliquer les règles d'arrimage et d'optimisation du chargement.

Avant de choisir un véhicule pour une opération, le gestionnaire doit maîtriser les caractéristiques techniques des différents types de véhicules et connaître les propriétés de la marchandise à transporter. Ce chapitre donne les bases nécessaires pour prendre les bonnes décisions d'affectation.

## 2.1 — Les types de véhicules de transport de marchandises

| Type de véhicule | Description | PTAC max France | Longueur max | Formule charge utile (CU) |
|---|---|---|---|---|
| Porteur (véhicule solo) | Véhicule monobloc : cabine et caisse forment un seul ensemble | 26 000 kg | 12 m | CU = PMA – Tare porteur |
| Ensemble articulé (tracteur + semi-remorque) | Tracteur (cabine) + semi-remorque sur sellette d'attelage | 44 000 kg | 16,50 m | CU = PMA – Tare TRR – Tare SREM |
| Train routier (porteur + remorque) | Porteur avec sa propre caisse + remorque complète | 44 000 kg | 18,75 m | CU = PMA – Tare porteur – Tare remorque |
| Train double (EMS) | Ensemble articulé + remorque supplémentaire — usage expérimental | 60 000 kg | 25,25 m | CU = PMA – ensemble des tares |

> 📌 **À retenir**
>
> PMA = Poids Maximum Autorisé = le plus petit entre le PTAC de la carte grise et le poids maximum autorisé par le Code de la route.
>
> CU (Charge Utile) = PMA – somme des tares (poids à vide des véhicules).
>
> Exemple : Ensemble articulé — PTRA 44 000 kg — Tare TRR 8 200 kg — Tare SREM 6 800 kg → CU = 29 000 kg.
>
> Attention : le gestionnaire engage sa responsabilité pénale s'il remet un fret dépassant la charge utile.

## 2.2 — Les types de carrosseries

| Carrosserie | Description | Usage principal | Dimensions utiles semi-remorque standard |
|---|---|---|---|
| Fourgon rigide | Parois et toit rigides — chargement par l'arrière uniquement | Messagerie, colis fragiles | 13,60 m × 2,40 m |
| Tautliner (bâché) | Parois latérales souples coulissantes sur toute la longueur | Palettes industrielles, lots complets | 13,60 m × 2,40 m |
| Plateau | Pas de parois ni de toit — marchandise arrimée sur le plancher | Matériaux de construction, machines hors gabarit | 13,20 m × 2,55 m |
| PLSC (plateau ridelles) | Plateau avec ridelles amovibles — déchargement latéral possible | Palettes lourdes, big-bags | 13,60 m × 2,40 m |
| Frigorifique (isotherme) | Caisse isotherme avec groupe froid — certification ATP obligatoire | Denrées périssables à température dirigée | 13,60 m × 2,40 m |
| Citerne | Réservoir fixe pour liquides, gaz ou produits en vrac | Alimentaire, chimique, pétrolier | Variable selon produit |

> ⚠️ **Réglementation**
>
> Certification ATP (Accord sur les Transports Périssables) :
>
> Tout véhicule transportant des denrées périssables à température dirigée doit être certifié ATP. Contrôle obligatoire tous les 3 ans.
>
> Classes principales : FRA (jusqu'à –20 °C, surgelés) — FRB (jusqu'à –10 °C) — FRC (0 à +4 °C, produits laitiers).
>
> Le gestionnaire qui confie une marchandise à température dirigée à un véhicule non certifié ATP engage sa responsabilité.

## 2.3 — Les poids et dimensions réglementaires

> ⚠️ **Réglementation**
>
> Poids maximum autorisé pour un ensemble articulé : 44 tonnes sur routes nationales et autoroutes.
>
> Gabarit maximum : largeur 2,55 m (2,60 m pour les caisses isothermes) — hauteur 4 m.
>
> Au-delà de ces gabarits légaux : transport en convoi exceptionnel.
>
> Autorisation préfectorale obligatoire + escorte selon la classe du convoi.

## 2.4 — La marchandise : nature et conditionnement

Chaque marchandise a des propriétés physiques qui déterminent le choix du véhicule et les conditions de transport. Avant tout chiffrage, le gestionnaire collecte systématiquement les informations suivantes : nature et état de la marchandise, poids brut total, dimensions, nombre et type d'unités de charge, conditions particulières (température, danger, fragilité, valeur).

| Catégorie | Exemples | Contrainte principale |
|---|---|---|
| Faible densité | Mousse, textile, meubles, emballages vides | Occupent beaucoup de volume pour peu de poids → poids volumétrique |
| Forte densité | Métaux, granit, masses indivisibles | Très lourdes pour un faible volume → risque dépassement CU |
| Grande longueur | Tubes, fers, poteaux, bois de charpente | Plateau obligatoire — arrimage spécifique |
| Vrac liquide | Lait, jus de fruits, solvants, carburants | Citerne — habilitations ADR si produit dangereux |
| Vrac pulvérulent | Farine, sucre, sable, ciment | Citerne spéciale ou benne |
| Produits périssables | Viandes, laitages, légumes, fleurs | Véhicule frigorifique certifié ATP obligatoire |
| Matières dangereuses | Produits chimiques, explosifs, gaz | Réglementation ADR — véhicule homologué — conducteur certifié |

## 2.5 — Le poids réel, le poids volumétrique et le poids taxable

Lorsqu'une marchandise est légère mais volumineuse, elle occupe tout l'espace disponible dans le véhicule sans en utiliser la capacité en poids. Le transporteur ne peut pas charger d'autres clients : il perd du chiffre d'affaires. Pour compenser cela, il applique un coefficient volumétrique et un coefficient métrique, fixés librement par l'entreprise.

| Type de poids | Formule de calcul | Coefficients courants |
|---|---|---|
| Poids réel (brut) | Poids effectif de la marchandise + emballage + support de charge | Lu sur la balance |
| Poids volumétrique | Volume total (m³) × coefficient volumétrique (kg/m³) | 250 kg/m³ messagerie — 330 kg/m³ lots partiels |
| Poids métrique | Mètres linéaires × coefficient métrique (kg/ml) | 1 790 kg/ml en lots partiels |
| Poids taxable | Maximum des 3 valeurs ci-dessus | C'est sur ce poids que s'applique le tarif |

> 📌 **À retenir**
>
> Volume d'une palette = Longueur (m) × Largeur (m) × Hauteur totale (m).
>
> Hauteur totale = hauteur marchandise + hauteur palette (0,15 m pour palette EUR ou ISO).
>
> Le coefficient volumétrique N'EST PAS fixé par la loi : chaque entreprise le détermine librement.
>
> POIDS TAXABLE = max (poids réel / poids volumétrique / poids métrique).

## 2.6 — Le mètre linéaire

Le mètre linéaire (ml) désigne la longueur de plancher occupée par un envoi dans le véhicule, indépendamment de la hauteur ou de la largeur de la marchandise. Il est utilisé pour tarifer les envois qui occupent une part importante du plancher sans remplir toute la capacité en poids.

| Type de palette | Largeur | Coefficient ml (semi-remorque 2,40 m) | Nb max dans un semi 13,60 m |
|---|---|---|---|
| Palette EUR (EPAL) | 1 200 × 800 mm | 0,40 ml (3 palettes côte à côte par rang) | 34 palettes (13,60 / 0,40) |
| Palette ISO | 1 200 × 1 000 mm | 0,50 ml (2 palettes côte à côte par rang) | 27 palettes (13,60 / 0,50) |

## 2.7 — Optimisation et sécurité du chargement

Avant tout chargement, le gestionnaire vérifie quatre points : le poids total de la marchandise est inférieur à la charge utile du véhicule ; le volume total tient dans les dimensions intérieures ; les marchandises peuvent être agencées dans l'espace disponible ; l'ordre de chargement respecte l'ordre de déchargement (la marchandise du dernier destinataire est chargée en premier).

> ⚠️ **Réglementation**
>
> Répartition des charges : le centre de gravité doit être le plus bas possible, les charges lourdes plaquées vers l'avant.
>
> Arrimage obligatoire avec des moyens conformes : sangles (norme NF G 36-034), cales, chaînes, tapis antiglisse.
>
> Les bâches, parois et ridelles ne sont PAS des moyens d'arrimage.
>
> Les moyens d'arrimage doivent être resserrés après les 50 premiers kilomètres et après tout choc.
>
> En cas de dommages corporels causés par un chargement défectueux : responsabilité civile ET pénale du transporteur, du conducteur et potentiellement du gestionnaire (articles 221-6 et 222-19 Code pénal).

## 2.8 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| PTAC | Poids Total Autorisé en Charge — poids maximum légal d'un véhicule chargé (carte grise) |
| PTRA | Poids Total Roulant Autorisé — pour un ensemble de véhicules (tracteur + semi) |
| PMA | Poids Maximum Autorisé — le plus petit entre PTAC et poids max autorisé par le Code de la route |
| Tare (PV) | Poids du véhicule à vide |
| Charge utile (CU) | Poids maximum de marchandise transportable = PMA – tare(s) |
| Tautliner | Semi-remorque à bâches latérales coulissantes |
| ATP | Accord sur les Transports Périssables — certification des véhicules frigorifiques |
| ADR | Accord pour le transport de marchandises Dangereuses par la Route |
| Poids volumétrique | Volume (m³) × coefficient volumétrique de l'entreprise |
| Poids taxable | Maximum des trois : poids réel, volumétrique et métrique |
| Mètre linéaire (ml) | Longueur de plancher occupée dans le véhicule |
| Arrimage | Positionnement et maintien sécurisé des charges dans le véhicule |
$lesson$,
'Types de véhicules, carrosseries, poids réglementaires, poids taxable, mètre linéaire, arrimage.')
  RETURNING id INTO v_lesson;

  -- ===================================================================
  -- Banque de questions : 12 QCM + 3 QR
  -- ===================================================================
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES

  -- QCM 1 (facile)
  (v_formation, v_module, 'qcm',
   'Quelle est la longueur maximale autorisée pour un ensemble articulé (tracteur + semi-remorque) ?',
   '[{"key":"a","text":"12 m","correct":false},{"key":"b","text":"16,50 m","correct":true},{"key":"c","text":"18,75 m","correct":false},{"key":"d","text":"25,25 m","correct":false}]'::jsonb,
   1, 'facile', ARRAY['vehicules','dimensions'], 'mft-2026-gotrm-livret:ch02:qcm:1', true,
   'Selon le tableau 2.1 du livret, l''ensemble articulé a une longueur maximale de 16,50 m.'),

  -- QCM 2 (facile)
  (v_formation, v_module, 'qcm',
   'Que signifie le sigle PTAC ?',
   '[{"key":"a","text":"Poids Total à Charger","correct":false},{"key":"b","text":"Poids Total Autorisé en Charge","correct":true},{"key":"c","text":"Poids Total Admissible Camion","correct":false},{"key":"d","text":"Poids Tracteur Autorisé Conducteur","correct":false}]'::jsonb,
   1, 'facile', ARRAY['vocabulaire','poids'], 'mft-2026-gotrm-livret:ch02:qcm:2', true,
   'PTAC = Poids Total Autorisé en Charge — poids maximum légal d''un véhicule chargé, indiqué sur la carte grise.'),

  -- QCM 3 (facile)
  (v_formation, v_module, 'qcm',
   'Quelle carrosserie est obligatoirement utilisée pour transporter des denrées à température dirigée ?',
   '[{"key":"a","text":"Tautliner","correct":false},{"key":"b","text":"Plateau","correct":false},{"key":"c","text":"Frigorifique certifié ATP","correct":true},{"key":"d","text":"Fourgon rigide","correct":false}]'::jsonb,
   1, 'facile', ARRAY['carrosseries','atp'], 'mft-2026-gotrm-livret:ch02:qcm:3', true,
   'Le livret précise qu''un véhicule transportant des denrées périssables à température dirigée doit être certifié ATP.'),

  -- QCM 4 (facile)
  (v_formation, v_module, 'qcm',
   'Combien de palettes EUR (EPAL) peut-on charger au maximum dans une semi-remorque de 13,60 m ?',
   '[{"key":"a","text":"27","correct":false},{"key":"b","text":"30","correct":false},{"key":"c","text":"33","correct":false},{"key":"d","text":"34","correct":true}]'::jsonb,
   1, 'facile', ARRAY['metre-lineaire','palettes'], 'mft-2026-gotrm-livret:ch02:qcm:4', true,
   '13,60 m / 0,40 ml par palette EUR = 34 palettes maximum (3 palettes côte à côte par rang).'),

  -- QCM 5 (moyen)
  (v_formation, v_module, 'qcm',
   'Comment se calcule la charge utile (CU) d''un ensemble articulé ?',
   '[{"key":"a","text":"CU = PTAC + Tare","correct":false},{"key":"b","text":"CU = PMA – Tare TRR – Tare SREM","correct":true},{"key":"c","text":"CU = PTRA + Tare semi","correct":false},{"key":"d","text":"CU = PMA + ensemble des tares","correct":false}]'::jsonb,
   1, 'moyen', ARRAY['poids','charge-utile'], 'mft-2026-gotrm-livret:ch02:qcm:5', true,
   'Pour un ensemble articulé : CU = PMA – Tare tracteur (TRR) – Tare semi-remorque (SREM).'),

  -- QCM 6 (moyen)
  (v_formation, v_module, 'qcm',
   'Comment est défini le poids taxable d''un envoi ?',
   '[{"key":"a","text":"La somme du poids réel et du poids volumétrique","correct":false},{"key":"b","text":"La moyenne des trois poids (réel, volumétrique, métrique)","correct":false},{"key":"c","text":"Le maximum des trois poids (réel, volumétrique, métrique)","correct":true},{"key":"d","text":"Le minimum des trois poids (réel, volumétrique, métrique)","correct":false}]'::jsonb,
   1, 'moyen', ARRAY['poids-taxable'], 'mft-2026-gotrm-livret:ch02:qcm:6', true,
   'POIDS TAXABLE = max (poids réel / poids volumétrique / poids métrique). C''est sur ce poids que s''applique le tarif.'),

  -- QCM 7 (moyen)
  (v_formation, v_module, 'qcm',
   'Quel est le PTAC maximum d''un porteur (véhicule solo) en France ?',
   '[{"key":"a","text":"19 000 kg","correct":false},{"key":"b","text":"26 000 kg","correct":true},{"key":"c","text":"32 000 kg","correct":false},{"key":"d","text":"44 000 kg","correct":false}]'::jsonb,
   1, 'moyen', ARRAY['vehicules','ptac'], 'mft-2026-gotrm-livret:ch02:qcm:7', true,
   'D''après le tableau 2.1, le PTAC max France d''un porteur est de 26 000 kg.'),

  -- QCM 8 (moyen)
  (v_formation, v_module, 'qcm',
   'Quelle norme régit les sangles d''arrimage selon le livret ?',
   '[{"key":"a","text":"NF G 36-034","correct":true},{"key":"b","text":"ISO 9001","correct":false},{"key":"c","text":"NF EN 12195","correct":false},{"key":"d","text":"ADR 2023","correct":false}]'::jsonb,
   1, 'moyen', ARRAY['arrimage','reglementation'], 'mft-2026-gotrm-livret:ch02:qcm:8', true,
   'Le livret cite explicitement la norme NF G 36-034 pour les sangles d''arrimage.'),

  -- QCM 9 (moyen)
  (v_formation, v_module, 'qcm',
   'Quel est le coefficient volumétrique courant pour la messagerie ?',
   '[{"key":"a","text":"150 kg/m³","correct":false},{"key":"b","text":"250 kg/m³","correct":true},{"key":"c","text":"330 kg/m³","correct":false},{"key":"d","text":"1 790 kg/m³","correct":false}]'::jsonb,
   1, 'moyen', ARRAY['poids-volumetrique'], 'mft-2026-gotrm-livret:ch02:qcm:9', true,
   'Le tableau 2.5 indique 250 kg/m³ pour la messagerie et 330 kg/m³ pour les lots partiels.'),

  -- QCM 10 (difficile)
  (v_formation, v_module, 'qcm',
   'Pour un ensemble articulé : PTRA 44 000 kg, Tare TRR 8 200 kg, Tare SREM 6 800 kg. Quelle est la charge utile ?',
   '[{"key":"a","text":"15 000 kg","correct":false},{"key":"b","text":"22 000 kg","correct":false},{"key":"c","text":"29 000 kg","correct":true},{"key":"d","text":"35 800 kg","correct":false}]'::jsonb,
   1, 'difficile', ARRAY['poids','calcul'], 'mft-2026-gotrm-livret:ch02:qcm:10', true,
   'CU = PMA – Tare TRR – Tare SREM = 44 000 – 8 200 – 6 800 = 29 000 kg (exemple du livret).'),

  -- QCM 11 (difficile)
  (v_formation, v_module, 'qcm',
   'À quel moment les moyens d''arrimage doivent-ils être resserrés selon la réglementation ?',
   '[{"key":"a","text":"Uniquement à l''arrivée","correct":false},{"key":"b","text":"Après les 50 premiers kilomètres et après tout choc","correct":true},{"key":"c","text":"Toutes les 4 heures de conduite","correct":false},{"key":"d","text":"Une fois par jour","correct":false}]'::jsonb,
   1, 'difficile', ARRAY['arrimage','reglementation'], 'mft-2026-gotrm-livret:ch02:qcm:11', true,
   'Le livret indique que les moyens d''arrimage doivent être resserrés après les 50 premiers kilomètres et après tout choc.'),

  -- QCM 12 (difficile)
  (v_formation, v_module, 'qcm',
   'Quelle classe ATP correspond aux produits surgelés (jusqu''à –20 °C) ?',
   '[{"key":"a","text":"FRA","correct":true},{"key":"b","text":"FRB","correct":false},{"key":"c","text":"FRC","correct":false},{"key":"d","text":"FRD","correct":false}]'::jsonb,
   1, 'difficile', ARRAY['atp','frigorifique'], 'mft-2026-gotrm-livret:ch02:qcm:12', true,
   'FRA = jusqu''à –20 °C (surgelés) ; FRB = jusqu''à –10 °C ; FRC = 0 à +4 °C (produits laitiers).'),

  -- QR 1
  (v_formation, v_module, 'qr',
   'Un client confie au transporteur 10 m³ de mousse pour un poids réel de 800 kg. Le coefficient volumétrique de l''entreprise est de 250 kg/m³. Calculez le poids volumétrique et indiquez le poids taxable retenu, en justifiant votre raisonnement.',
   NULL, 5, 'moyen', ARRAY['poids-taxable','calcul'], 'mft-2026-gotrm-livret:ch02:qr:1', true,
   'Poids volumétrique = 10 m³ × 250 kg/m³ = 2 500 kg. Poids réel = 800 kg. Le poids taxable = max (poids réel / poids volumétrique / poids métrique) = 2 500 kg. La mousse est légère mais volumineuse : appliquer le poids volumétrique compense la perte de capacité de chargement.'),

  -- QR 2
  (v_formation, v_module, 'qr',
   'Un gestionnaire confie un transport de viandes fraîches à un véhicule non certifié ATP, après promesse du conducteur de respecter la chaîne du froid. À l''arrivée, la marchandise est avariée. Quelles responsabilités sont engagées et pourquoi ?',
   NULL, 5, 'difficile', ARRAY['atp','responsabilite'], 'mft-2026-gotrm-livret:ch02:qr:2', true,
   'Le livret précise que le gestionnaire qui confie une marchandise à température dirigée à un véhicule non certifié ATP engage sa responsabilité. Sont engagées : la responsabilité du transporteur (perte de marchandise, indemnisation du client), celle du conducteur, et celle du gestionnaire qui a affecté un véhicule non conforme. La certification ATP est obligatoire pour les denrées périssables — la promesse orale ne remplace pas la certification.'),

  -- QR 3
  (v_formation, v_module, 'qr',
   'Pour un envoi de 13 palettes EUR à charger dans une semi-remorque de 13,60 m × 2,40 m, calculez le nombre de mètres linéaires occupés et expliquez l''intérêt du calcul du poids métrique pour la tarification.',
   NULL, 5, 'difficile', ARRAY['metre-lineaire','tarification'], 'mft-2026-gotrm-livret:ch02:qr:3', true,
   'Avec 3 palettes EUR côte à côte par rang, 13 palettes occupent 13/3 = 4,33 rangs, soit ceil(13/3) = 5 rangs × 0,80 m = 4 m. Coefficient ml : 0,40 ml × 13 ÷ 3 ≈ 1,73 ml. Le poids métrique = mètres linéaires × coefficient métrique (1 790 kg/ml en lots partiels) permet de facturer l''espace plancher occupé même si l''envoi est léger : le transporteur ne pouvant pas remplir le plancher avec d''autres clients, le poids métrique compense la perte commerciale.');

  -- ===================================================================
  -- Quiz d'entraînement
  -- ===================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Chapitre 2 — Quiz d''entraînement',
          'Quiz d''entraînement (12 questions) sur les véhicules, carrosseries et marchandises.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch02:qcm:%';

  RAISE NOTICE '✓ Module Ch2 importé : 1 leçon, 12 QCM, 3 QR, 1 quiz d''entraînement.';
END $ch02_v4$;
