-- =====================================================================
-- Test de positionnement — banque de questions pour les 8 formations
-- =====================================================================
-- 200 questions au total :
--   8 formations × 25 questions chacune
--   Réparties par bloc : 9 BC1 + 9 BC2 + 7 BC3 (cohérent avec le
--   référentiel pédagogique mis en place dans formations_v2.sql)
--
-- Pré-requis :
--   - public.formations seedée (formations_v2.sql)
--   - public.blocs présent (BC1 / BC2 / BC3 — schema.sql + seed.sql)
--   - public.placement_questions étendue avec formation_id
--     (placement_extensions.sql)
--
-- Idempotent : DELETE ciblé par formation_id avant INSERT.
-- Format choices : array JSON de 4 options ; correct_index 0-based.
-- =====================================================================

DO $placement_seed$
DECLARE
  v_gotrm uuid;
  v_ertv uuid;
  v_ecsr uuid;
  v_fimo uuid;
  v_taxi uuid;
  v_commiss uuid;
  v_capa uuid;
  v_capa_plus uuid;

  v_bc1 int;
  v_bc2 int;
  v_bc3 int;
BEGIN
  -- ─── Résolution des IDs formations ─────────────────────────────────
  SELECT id INTO v_gotrm     FROM public.formations WHERE slug = 'gotrm';
  SELECT id INTO v_ertv      FROM public.formations WHERE slug = 'ertv';
  SELECT id INTO v_ecsr      FROM public.formations WHERE slug = 'ecsr';
  SELECT id INTO v_fimo      FROM public.formations WHERE slug = 'fimo-fco';
  SELECT id INTO v_taxi      FROM public.formations WHERE slug = 'taxi-vtc';
  SELECT id INTO v_commiss   FROM public.formations WHERE slug = 'commissionnaire';
  SELECT id INTO v_capa      FROM public.formations WHERE slug = 'capacite-3-5t';
  SELECT id INTO v_capa_plus FROM public.formations WHERE slug = 'capacite-plus-3-5t';

  IF v_gotrm IS NULL OR v_ertv IS NULL OR v_ecsr IS NULL
     OR v_fimo IS NULL OR v_taxi IS NULL OR v_commiss IS NULL
     OR v_capa IS NULL OR v_capa_plus IS NULL THEN
    RAISE EXCEPTION 'Au moins une formation est manquante. Joue d''abord formations_v2.sql.';
  END IF;

  SELECT id INTO v_bc1 FROM public.blocs WHERE code = 'BC1';
  SELECT id INTO v_bc2 FROM public.blocs WHERE code = 'BC2';
  SELECT id INTO v_bc3 FROM public.blocs WHERE code = 'BC3';

  IF v_bc1 IS NULL OR v_bc2 IS NULL OR v_bc3 IS NULL THEN
    RAISE EXCEPTION 'Blocs BC1/BC2/BC3 manquants. Joue seed.sql.';
  END IF;

  -- ─── Nettoyage idempotent (uniquement les questions des 8 formations
  --     gérées ici) ──────────────────────────────────────────────────
  DELETE FROM public.placement_questions
   WHERE formation_id IN (
     v_gotrm, v_ertv, v_ecsr, v_fimo,
     v_taxi, v_commiss, v_capa, v_capa_plus
   );

  -- ============================================================
  -- 1. GOTRM — Gestionnaire des Opérations de Transport Routier
  -- ============================================================
  INSERT INTO public.placement_questions
    (formation_id, bloc_id, prompt, choices, correct_index, difficulty, "order", active)
  VALUES
  -- BC1 Exploitation (9)
  (v_gotrm, v_bc1, 'Quelle est la durée maximale de conduite journalière (règlement CE 561/2006) ?',
   '["8 h","9 h, 10 h deux fois par semaine","11 h","12 h"]'::jsonb, 1, 'standard', 1, true),
  (v_gotrm, v_bc1, 'Après 4 h 30 de conduite, quelle est la durée minimale de pause obligatoire ?',
   '["30 min","45 min (en une ou deux fractions)","1 h","15 min"]'::jsonb, 1, 'standard', 2, true),
  (v_gotrm, v_bc1, 'La lettre de voiture CMR est obligatoire pour :',
   '["Tout transport en France","Tout transport international routier de marchandises","Uniquement les transports ADR","Les transports de plus de 7,5 t"]'::jsonb, 1, 'standard', 3, true),
  (v_gotrm, v_bc1, 'Quel temps de repos quotidien réduit est autorisé (au maximum 3 fois entre 2 repos hebdo) ?',
   '["7 h","9 h","10 h","11 h"]'::jsonb, 1, 'standard', 4, true),
  (v_gotrm, v_bc1, 'Que désigne le sigle TMD ?',
   '["Transport Multimodal de Distribution","Transport de Marchandises Dangereuses","Tachygraphe Mobile Digital","Tarif Marchand Distance"]'::jsonb, 1, 'facile', 5, true),
  (v_gotrm, v_bc1, 'L''accord ADR concerne :',
   '["Les transports frigorifiques","Les marchandises dangereuses par route","Les transports d''animaux vivants","Les transports en citerne uniquement"]'::jsonb, 1, 'facile', 6, true),
  (v_gotrm, v_bc1, 'Quelle est la durée maximale hebdomadaire de conduite ?',
   '["48 h","56 h","60 h","45 h"]'::jsonb, 1, 'standard', 7, true),
  (v_gotrm, v_bc1, 'Le cabotage en France pour un transporteur communautaire est limité à :',
   '["1 opération en 7 jours","3 opérations en 7 jours","Illimité","5 opérations en 30 jours"]'::jsonb, 1, 'difficile', 8, true),
  (v_gotrm, v_bc1, 'Que signifie "réserve" sur un bon de livraison ?',
   '["Stock disponible chez le client","Mention motivée du destinataire en cas d''anomalie","Marge commerciale","Provision comptable"]'::jsonb, 1, 'standard', 9, true),

  -- BC2 Pilotage des trafics sous-traités (9)
  (v_gotrm, v_bc2, 'Dans un appel d''offres transport, le cahier des charges précise principalement :',
   '["Uniquement le prix attendu","Les exigences opérationnelles, qualité et tarifaires","Les noms des sous-traitants à utiliser","Le bilan comptable du chargeur"]'::jsonb, 1, 'standard', 1, true),
  (v_gotrm, v_bc2, 'La sous-traitance "rang 1" désigne :',
   '["Le 1er sous-traitant directement contracté par le donneur d''ordre","Le sous-traitant du sous-traitant","Une opération multimodale","Un transport intra-groupe"]'::jsonb, 0, 'standard', 2, true),
  (v_gotrm, v_bc2, 'Quel critère NE figure PAS classiquement dans une grille de notation fournisseur ?',
   '["Taux de service","Tarification","Couleur de la flotte","Qualité du reporting"]'::jsonb, 2, 'facile', 3, true),
  (v_gotrm, v_bc2, 'Un litige transport sur perte totale de la marchandise est limité par défaut à :',
   '["8,33 DTS / kg (CMR)","Sans limite","20 € / kg","100 % de la valeur déclarée"]'::jsonb, 0, 'difficile', 4, true),
  (v_gotrm, v_bc2, 'Délai légal pour formuler une réserve écrite après livraison (CMR) :',
   '["Immédiat ou 7 jours pour avaries non apparentes","30 jours","48 h pour tout","21 jours"]'::jsonb, 0, 'difficile', 5, true),
  (v_gotrm, v_bc2, 'Un contrat-type s''applique :',
   '["Toujours obligatoirement","À défaut de convention écrite entre les parties","Uniquement aux transports internationaux","Uniquement aux ADR"]'::jsonb, 1, 'standard', 6, true),
  (v_gotrm, v_bc2, 'Le terme "RFA" en achats transport signifie :',
   '["Remise de Fin d''Année","Référencement Fournisseur Annuel","Risque Financier Aval","Régulation Flotte Affrétée"]'::jsonb, 0, 'standard', 7, true),
  (v_gotrm, v_bc2, 'L''indice CNR sert principalement à :',
   '["Calculer la TVA","Réviser les prix transport (gazole, salaires…)","Mesurer la qualité de service","Auditer les sous-traitants"]'::jsonb, 1, 'standard', 8, true),
  (v_gotrm, v_bc2, 'Que vérifie-t-on en priorité avant de référencer un sous-traitant ?',
   '["Sa licence de transport et ses attestations sociales/fiscales","La couleur de ses camions","Le nom de son dirigeant","Sa banque"]'::jsonb, 0, 'facile', 9, true),

  -- BC3 Optimisation moyens (7)
  (v_gotrm, v_bc3, 'Le coût de revient au kilomètre (CRKM) inclut :',
   '["Uniquement le carburant","Charges fixes + charges variables / km parcourus","Le salaire du dirigeant uniquement","Les amortissements seulement"]'::jsonb, 1, 'standard', 1, true),
  (v_gotrm, v_bc3, 'Un taux de remplissage cible "bon" se situe généralement :',
   '["Sous 50 %","Au-dessus de 85 %","Exactement 100 %","Variable selon la météo"]'::jsonb, 1, 'standard', 2, true),
  (v_gotrm, v_bc3, 'Un KPI qualité "taux de service" mesure :',
   '["Les réclamations clients","Les livraisons effectuées dans les délais sur total","Le chiffre d''affaires","La marge brute"]'::jsonb, 1, 'facile', 3, true),
  (v_gotrm, v_bc3, 'Une démarche RSE inclut typiquement :',
   '["Économique, social, environnemental","Uniquement environnemental","Uniquement social","Uniquement économique"]'::jsonb, 0, 'facile', 4, true),
  (v_gotrm, v_bc3, 'L''éco-conduite peut réduire la consommation de carburant de :',
   '["1 à 2 %","5 à 15 %","30 à 50 %","Aucun impact mesurable"]'::jsonb, 1, 'standard', 5, true),
  (v_gotrm, v_bc3, 'Quel outil de pilotage visuel est le plus adapté au suivi quotidien d''exploitation ?',
   '["Bilan annuel","Tableau de bord avec KPI temps réel","Plan de trésorerie 5 ans","Note de service"]'::jsonb, 1, 'facile', 6, true),
  (v_gotrm, v_bc3, 'La norme ISO 14001 concerne :',
   '["La qualité","Le management environnemental","La sécurité","Les marchandises dangereuses"]'::jsonb, 1, 'difficile', 7, true),

  -- ============================================================
  -- 2. ERTV — Exploitant Régulation Transport Voyageurs
  -- ============================================================
  -- BC1 Réglementation transport voyageurs (9)
  (v_ertv, v_bc1, 'Le permis D autorise la conduite :',
   '["De véhicules > 3,5 t","De véhicules de transport en commun de plus de 9 personnes (conducteur compris)","D''autocars uniquement à l''international","De taxis"]'::jsonb, 1, 'facile', 1, true),
  (v_ertv, v_bc1, 'Une licence communautaire est délivrée par :',
   '["La préfecture / DREAL","La SNCF","Le maire","Bruxelles directement"]'::jsonb, 0, 'standard', 2, true),
  (v_ertv, v_bc1, 'Le règlement (CE) 1071/2009 fixe :',
   '["La capacité financière, professionnelle et l''honorabilité","Les tarifs minimaux","Les couleurs des autocars","Les délais de livraison"]'::jsonb, 0, 'standard', 3, true),
  (v_ertv, v_bc1, 'Un service "occasionnel" en transport de voyageurs est :',
   '["Une ligne régulière","Un service à la demande non planifié","Le scolaire","Le RER"]'::jsonb, 1, 'standard', 4, true),
  (v_ertv, v_bc1, 'La capacité financière exigée pour le 1er véhicule de TC voyageurs :',
   '["1 800 €","9 000 €","50 000 €","100 000 €"]'::jsonb, 1, 'difficile', 5, true),
  (v_ertv, v_bc1, 'Le règlement (UE) 181/2011 traite :',
   '["Du tachygraphe","Des droits des passagers en autobus et autocar","Des limites de vitesse","Des dimensions des véhicules"]'::jsonb, 1, 'difficile', 6, true),
  (v_ertv, v_bc1, 'Pour un autocar, le temps de conduite continue avant pause est de :',
   '["3 h 30","4 h 30","5 h","6 h"]'::jsonb, 1, 'standard', 7, true),
  (v_ertv, v_bc1, 'Le transport scolaire relève principalement :',
   '["Du Ministère des Transports","De la Région (autorité organisatrice)","De la commune obligatoirement","Du préfet"]'::jsonb, 1, 'standard', 8, true),
  (v_ertv, v_bc1, 'Une "double équipage" en transport voyageurs permet :',
   '["De doubler la durée de conduite journalière","De ne pas faire de pause","De rouler à 100 km/h","De cumuler les indemnités"]'::jsonb, 0, 'standard', 9, true),

  -- BC2 Régulation et exploitation (9)
  (v_ertv, v_bc2, 'En cas de retard d''un autocar > 2 h sur trajet > 250 km, l''opérateur doit :',
   '["Rien de spécifique","Proposer un repas / hébergement le cas échéant","Rembourser intégralement","Prévenir la police"]'::jsonb, 1, 'difficile', 1, true),
  (v_ertv, v_bc2, 'L''affectation des conducteurs sur les services s''appelle :',
   '["Le graphicage","La feuille de route","L''habillage des véhicules","Le routage"]'::jsonb, 0, 'difficile', 2, true),
  (v_ertv, v_bc2, 'Un PDU est :',
   '["Plan de Déplacements Urbains","Permis de Déchargement Unique","Programme de Distribution Urbaine","Procédure Douanière Unifiée"]'::jsonb, 0, 'standard', 3, true),
  (v_ertv, v_bc2, 'Quel logiciel-type est utilisé pour la régulation en TC urbain ?',
   '["SAEIV (Système d''Aide à l''Exploitation et Information Voyageurs)","SAP","ERP comptable","CRM commercial"]'::jsonb, 0, 'standard', 4, true),
  (v_ertv, v_bc2, 'En cas de panne autocar avec passagers, la priorité est :',
   '["Sécuriser les passagers et organiser le transfert","Réparer sur place","Continuer à vitesse réduite","Demander aux passagers de descendre seuls"]'::jsonb, 0, 'facile', 5, true),
  (v_ertv, v_bc2, 'Le KPI "ponctualité" se calcule sur :',
   '["Les départs/arrivées dans une fenêtre de tolérance","Le chiffre d''affaires","Le nombre de passagers","La consommation de carburant"]'::jsonb, 0, 'facile', 6, true),
  (v_ertv, v_bc2, 'Le coefficient de remplissage en TC voyageurs représente :',
   '["Voyageurs.km / places.km offertes","Recettes / dépenses","Litres / 100 km","Pannes / véhicules"]'::jsonb, 0, 'standard', 7, true),
  (v_ertv, v_bc2, 'Une billettique sans contact utilise principalement :',
   '["NFC / RFID","WiFi","GPS","Bluetooth Low Energy uniquement"]'::jsonb, 0, 'facile', 8, true),
  (v_ertv, v_bc2, 'En urbain, une "fréquence" exprime :',
   '["Le nombre de passages par heure","La distance entre arrêts","La taille du véhicule","Le tarif"]'::jsonb, 0, 'facile', 9, true),

  -- BC3 Relation client et management (7)
  (v_ertv, v_bc3, 'Un PMR est :',
   '["Personne à Mobilité Réduite","Plan de Maintenance Régulière","Prestation Multi-Réseau","Permis de Mouvement Régional"]'::jsonb, 0, 'facile', 1, true),
  (v_ertv, v_bc3, 'L''accessibilité PMR des arrêts est encadrée par :',
   '["La loi de 2005","Le Code du travail","Le règlement CE 561/2006","Le Code rural"]'::jsonb, 0, 'standard', 2, true),
  (v_ertv, v_bc3, 'Une posture "client" en exploitation TC consiste à :',
   '["Imposer ses contraintes","Anticiper, informer, s''excuser quand nécessaire","Renvoyer toute responsabilité","Ignorer les réclamations"]'::jsonb, 1, 'facile', 3, true),
  (v_ertv, v_bc3, 'Une réunion d''équipe quotidienne (briefing) sert à :',
   '["Distribuer les paies","Aligner consignes, sécurité, points particuliers du jour","Vendre des billets","Réviser les véhicules"]'::jsonb, 1, 'facile', 4, true),
  (v_ertv, v_bc3, 'Un entretien individuel annuel doit être :',
   '["Optionnel","Tracé, daté et signé","Public","Filmé"]'::jsonb, 1, 'standard', 5, true),
  (v_ertv, v_bc3, 'La formation continue obligatoire pour les conducteurs voyageurs (FCO) dure :',
   '["7 h","21 h","35 h tous les 5 ans","70 h"]'::jsonb, 2, 'standard', 6, true),
  (v_ertv, v_bc3, 'En cas d''agression d''un conducteur, le bon réflexe est :',
   '["Riposter","Sécuriser, alerter, déclarer (main courante / dépôt de plainte) et suivi RH","Ignorer","Sanctionner les passagers"]'::jsonb, 1, 'standard', 7, true),

  -- ============================================================
  -- 3. ECSR — Enseignant Conduite Sécurité Routière
  -- ============================================================
  -- BC1 Pédagogie de la conduite (9)
  (v_ecsr, v_bc1, 'La REMC est :',
   '["Référentiel pour l''Éducation à une Mobilité Citoyenne","Régime des Examens en Moto Catégorie","Règlement Européen Mobilité Conducteurs","Réseau d''Écoles de Mobilité Communales"]'::jsonb, 0, 'facile', 1, true),
  (v_ecsr, v_bc1, 'Une compétence pédagogique combine :',
   '["Savoirs uniquement","Savoir, savoir-faire, savoir-être","Examens uniquement","Notes uniquement"]'::jsonb, 1, 'facile', 2, true),
  (v_ecsr, v_bc1, 'Une séance de conduite efficace commence par :',
   '["Démarrer immédiatement","Un objectif annoncé et un point sur la séance précédente","Une mise en garde sévère","Un exercice de vitesse"]'::jsonb, 1, 'facile', 3, true),
  (v_ecsr, v_bc1, 'L''auto-évaluation de l''élève vise à :',
   '["Le décourager","Développer son autonomie et sa lucidité","Réduire le temps de cours","Remplacer l''évaluation"]'::jsonb, 1, 'standard', 4, true),
  (v_ecsr, v_bc1, 'Une consigne pédagogique efficace est :',
   '["Longue et détaillée","Brève, claire, opérationnelle, vérifiable","Implicite","Variable selon l''humeur"]'::jsonb, 1, 'standard', 5, true),
  (v_ecsr, v_bc1, 'Le transfert d''apprentissage signifie :',
   '["Changer d''auto-école","Réutiliser un acquis dans un nouveau contexte","Transférer les frais","Passer du théorique au pratique uniquement"]'::jsonb, 1, 'difficile', 6, true),
  (v_ecsr, v_bc1, 'Une posture "facilitatrice" privilégie :',
   '["Les questions ouvertes et la verbalisation par l''élève","Le cours magistral pur","La sanction systématique","Le silence absolu"]'::jsonb, 0, 'standard', 7, true),
  (v_ecsr, v_bc1, 'Le livret d''apprentissage AAC est destiné :',
   '["À tout candidat permis B","Aux candidats à la conduite accompagnée","Aux examinateurs uniquement","Aux assureurs"]'::jsonb, 1, 'standard', 8, true),
  (v_ecsr, v_bc1, 'Le RNQ (Référentiel National Qualité) impose à une auto-école :',
   '["Un local minimal","Des engagements qualité audités (Qualiopi-like)","Des tarifs imposés","Une flotte 100 % électrique"]'::jsonb, 1, 'difficile', 9, true),

  -- BC2 Connaissance véhicule et route (9)
  (v_ecsr, v_bc2, 'Le coefficient de roulement dépend principalement de :',
   '["La couleur du véhicule","Le revêtement, les pneus, le poids, la météo","La marque uniquement","La climatisation"]'::jsonb, 1, 'standard', 1, true),
  (v_ecsr, v_bc2, 'À 90 km/h sur route sèche, la distance de freinage est environ :',
   '["10 m","45 m","100 m","200 m"]'::jsonb, 1, 'standard', 2, true),
  (v_ecsr, v_bc2, 'L''ABS sert à :',
   '["Augmenter la puissance moteur","Empêcher le blocage des roues au freinage et garder la directionnalité","Réduire la consommation","Climatiser"]'::jsonb, 1, 'facile', 3, true),
  (v_ecsr, v_bc2, 'L''ESP (contrôle de stabilité) :',
   '["Réduit la consommation","Corrige la trajectoire en cas de perte d''adhérence","Allume les phares","Désactive l''ABS"]'::jsonb, 1, 'facile', 4, true),
  (v_ecsr, v_bc2, 'La distance de sécurité minimale en ligne droite :',
   '["1 seconde","2 secondes (au minimum)","½ seconde","30 m fixe"]'::jsonb, 1, 'facile', 5, true),
  (v_ecsr, v_bc2, 'En sortie de virage avec sous-virage, on doit :',
   '["Accélérer","Lever le pied progressivement, corriger doucement la direction","Freiner brutalement","Tirer le frein à main"]'::jsonb, 1, 'difficile', 6, true),
  (v_ecsr, v_bc2, 'Un véhicule "boîte automatique" sur permis B traditionnel :',
   '["Pas autorisé","Autorisé sans restriction","Autorisé mais code 78 si formation BVA uniquement","Réservé aux pros"]'::jsonb, 2, 'standard', 7, true),
  (v_ecsr, v_bc2, 'La pression des pneus se vérifie :',
   '["Pneus chauds","Pneus froids","Après lavage","Une fois par an"]'::jsonb, 1, 'facile', 8, true),
  (v_ecsr, v_bc2, 'Le code de la route exige une visibilité minimale en aquaplanage :',
   '["Aucune adaptation","Réduction de vitesse, distance allongée, anticipation","Roulez plus vite pour aspirer l''eau","Freinage pulsé maximum"]'::jsonb, 1, 'standard', 9, true),

  -- BC3 Cadre réglementaire et déontologique (7)
  (v_ecsr, v_bc3, 'L''autorisation d''enseigner s''appelle :',
   '["BEPECASER","Carte verte","CCPCT","Permis pro"]'::jsonb, 0, 'standard', 1, true),
  (v_ecsr, v_bc3, 'L''agrément d''une auto-école est délivré par :',
   '["La préfecture","La mairie","Pôle Emploi","La région"]'::jsonb, 0, 'standard', 2, true),
  (v_ecsr, v_bc3, 'La déontologie d''un ECSR impose notamment :',
   '["Aucune obligation","Confidentialité, neutralité, respect, sécurité","De choisir ses élèves","De facturer librement les heures"]'::jsonb, 1, 'facile', 3, true),
  (v_ecsr, v_bc3, 'Un contrat de formation à la conduite doit comporter :',
   '["Programme, durée, prix, conditions","Uniquement le tarif","Une simple poignée de main","La marque du véhicule"]'::jsonb, 0, 'standard', 4, true),
  (v_ecsr, v_bc3, 'Un mineur en formation doit avoir :',
   '["Aucune autorisation","Une autorisation parentale écrite","Un avocat","Une licence FFM"]'::jsonb, 1, 'facile', 5, true),
  (v_ecsr, v_bc3, 'Le secret professionnel s''applique :',
   '["Jamais","À toutes les informations personnelles de l''élève","Uniquement aux comptes bancaires","Seulement après accident"]'::jsonb, 1, 'standard', 6, true),
  (v_ecsr, v_bc3, 'Une fraude à l''examen entraîne :',
   '["Un avertissement","Une sanction (annulation, interdiction de représentation)","Une simple remontrance","Aucune conséquence"]'::jsonb, 1, 'standard', 7, true),

  -- ============================================================
  -- 4. FIMO / FCO — Conducteur professionnel marchandises
  -- ============================================================
  -- BC1 Conduite rationnelle et sécurité (9)
  (v_fimo, v_bc1, 'L''éco-conduite repose principalement sur :',
   '["Anticipation, régulation, rapport poids/puissance, allure constante","Vitesse maximale","Surrégime moteur","Freinage tardif"]'::jsonb, 0, 'facile', 1, true),
  (v_fimo, v_bc1, 'En montée, la conduite optimale sur PL impose :',
   '["Un régime moteur élevé en permanence","Anticiper en gardant le couple maxi","Rouler en roue libre","Utiliser le frein moteur"]'::jsonb, 1, 'standard', 2, true),
  (v_fimo, v_bc1, 'La distance de sécurité conseillée en PL hors agglomération :',
   '["1 s","2 s minimum","3 s minimum (≈ 50 m à 90 km/h)","½ s"]'::jsonb, 2, 'standard', 3, true),
  (v_fimo, v_bc1, 'Le ralentisseur (frein moteur ou retarder) sert à :',
   '["Démarrer","Soulager les freins de service en descente","Économiser le carburant en plat","Faire chauffer le moteur"]'::jsonb, 1, 'standard', 4, true),
  (v_fimo, v_bc1, 'Une vérification "départ" inclut systématiquement :',
   '["Niveaux, pneus, feux, documents bord","Uniquement le carburant","Uniquement les pneus","Le téléphone"]'::jsonb, 0, 'facile', 5, true),
  (v_fimo, v_bc1, 'L''angle mort à droite d''un PL est :',
   '["Inexistant","Particulièrement dangereux pour cyclistes/piétons","Visible directement","Compensé par l''ABS"]'::jsonb, 1, 'facile', 6, true),
  (v_fimo, v_bc1, 'Le chargement est mal arrimé : conséquence principale :',
   '["Aucune","Risque déplacement, accident, contravention","Économie de carburant","Meilleur freinage"]'::jsonb, 1, 'facile', 7, true),
  (v_fimo, v_bc1, 'La vitesse maxi d''un PL > 12 t sur autoroute est :',
   '["80 km/h","90 km/h","100 km/h","110 km/h"]'::jsonb, 1, 'standard', 8, true),
  (v_fimo, v_bc1, 'Le tachygraphe numérique doit être :',
   '["Optionnel","Utilisé en permanence avec carte conducteur","Activé uniquement à l''international","Vidé chaque jour"]'::jsonb, 1, 'standard', 9, true),

  -- BC2 Réglementation (9)
  (v_fimo, v_bc2, 'Le repos hebdomadaire normal est de :',
   '["24 h","45 h","36 h","48 h"]'::jsonb, 1, 'standard', 1, true),
  (v_fimo, v_bc2, 'Un repos hebdo réduit (24 h) doit être compensé :',
   '["Jamais","Avant la fin de la 3e semaine suivante","Sous 6 mois","Sous 1 an"]'::jsonb, 1, 'difficile', 2, true),
  (v_fimo, v_bc2, 'La carte conducteur est délivrée par :',
   '["L''employeur","Chronoservices (en France)","La SNCF","Le constructeur du camion"]'::jsonb, 1, 'standard', 3, true),
  (v_fimo, v_bc2, 'Sur PL ADR, la signalisation orange (panneau orange) indique :',
   '["Charge dangereuse","Charge alimentaire","Convoi exceptionnel","Ramassage scolaire"]'::jsonb, 0, 'facile', 4, true),
  (v_fimo, v_bc2, 'Le permis CE autorise la conduite :',
   '["Uniquement véhicules ≤ 7,5 t","Ensembles articulés > 750 kg de remorque (cat. C + remorque)","Autocars","Taxis"]'::jsonb, 1, 'standard', 5, true),
  (v_fimo, v_bc2, 'La FCO (formation continue obligatoire) doit être renouvelée :',
   '["Tous les ans","Tous les 5 ans","Tous les 10 ans","Une seule fois"]'::jsonb, 1, 'facile', 6, true),
  (v_fimo, v_bc2, 'En cas d''accident corporel, le conducteur PL doit :',
   '["Continuer sa route","Sécuriser, alerter, secourir, informer son employeur","Effacer les preuves","Filmer pour les réseaux"]'::jsonb, 1, 'facile', 7, true),
  (v_fimo, v_bc2, 'La lettre de voiture est obligatoire en :',
   '["Transport national de + de 3 t","Transport international (CMR) systématiquement","Tout déménagement","Aucun cas"]'::jsonb, 1, 'standard', 8, true),
  (v_fimo, v_bc2, 'L''alcoolémie maximale autorisée pour un conducteur PL :',
   '["0,5 g/L","0,2 g/L","0,8 g/L","Aucune limite"]'::jsonb, 1, 'standard', 9, true),

  -- BC3 Santé, sécurité, environnement (7)
  (v_fimo, v_bc3, 'Une bonne hygiène de vie pour un conducteur PL inclut :',
   '["Sommeil suffisant, hydratation, alimentation équilibrée","Café à volonté","Repas express uniquement","Aucune importance"]'::jsonb, 0, 'facile', 1, true),
  (v_fimo, v_bc3, 'Le micro-sommeil au volant est dangereux car :',
   '["Inexistant","Survient sans signal franc, à toute heure","Toujours précédé d''un bâillement","Uniquement la nuit"]'::jsonb, 1, 'standard', 2, true),
  (v_fimo, v_bc3, 'La consommation moyenne d''un PL 40 t est environ :',
   '["10 L/100 km","30 L/100 km (variable selon profil)","100 L/100 km","5 L/100 km"]'::jsonb, 1, 'standard', 3, true),
  (v_fimo, v_bc3, 'Un système Stop & Start sur PL :',
   '["Coupe le moteur à l''arrêt prolongé","N''existe pas","Augmente la consommation","Désactive les freins"]'::jsonb, 0, 'facile', 4, true),
  (v_fimo, v_bc3, 'Le port des EPI lors du chargement est :',
   '["Optionnel","Obligatoire selon la situation (gants, chaussures, gilet…)","Uniquement la nuit","Uniquement à l''étranger"]'::jsonb, 1, 'facile', 5, true),
  (v_fimo, v_bc3, 'En cas de feu moteur, le bon geste est :',
   '["Ouvrir le capot en grand","Couper contact, alerter, utiliser un extincteur si possible et s''éloigner","Verser de l''eau sur le moteur","Continuer pour s''éloigner"]'::jsonb, 1, 'standard', 6, true),
  (v_fimo, v_bc3, 'La norme Euro VI vise à :',
   '["Augmenter la puissance","Réduire NOx, particules et polluants","Augmenter la charge utile","Imposer une couleur"]'::jsonb, 1, 'standard', 7, true),

  -- ============================================================
  -- 5. Taxi & VTC
  -- ============================================================
  -- BC1 Réglementation (9)
  (v_taxi, v_bc1, 'Une carte professionnelle Taxi est délivrée par :',
   '["La mairie","Le préfet de département","Le ministère","Une auto-école"]'::jsonb, 1, 'facile', 1, true),
  (v_taxi, v_bc1, 'Un VTC ne peut PAS :',
   '["Maraude (prendre client à la volée sans réservation)","Utiliser une appli de réservation","Faire des courses interurbaines","Imprimer un reçu"]'::jsonb, 0, 'standard', 2, true),
  (v_taxi, v_bc1, 'Un Taxi peut stationner :',
   '["N''importe où","Aux emplacements réservés (stations) avec ADS","Uniquement devant les hôtels","Sur trottoir"]'::jsonb, 1, 'facile', 3, true),
  (v_taxi, v_bc1, 'L''ADS (Autorisation de Stationnement) est :',
   '["Cessible sous conditions","Gratuite","Renouvelable chaque année automatiquement","Réservée aux VTC"]'::jsonb, 0, 'standard', 4, true),
  (v_taxi, v_bc1, 'Un VTC doit revenir à son lieu d''établissement :',
   '["Jamais","Sauf nouvelle réservation","Toutes les heures","Uniquement le soir"]'::jsonb, 1, 'standard', 5, true),
  (v_taxi, v_bc1, 'L''horodateur (compteur) du Taxi est :',
   '["Optionnel","Obligatoire et homologué","Réservé aux longues distances","Vendu librement"]'::jsonb, 1, 'facile', 6, true),
  (v_taxi, v_bc1, 'Le tarif d''un Taxi est fixé :',
   '["Librement","Par arrêté préfectoral (en zone tarif réglementé)","Par la mairie","Par l''Europe"]'::jsonb, 1, 'standard', 7, true),
  (v_taxi, v_bc1, 'La signalétique extérieure d''un VTC autorisée est :',
   '["Lumineux Taxi","Vignette VTC réglementaire (macaron)","Aucune","Bandeau publicitaire libre"]'::jsonb, 1, 'standard', 8, true),
  (v_taxi, v_bc1, 'La formation initiale Taxi/VTC se conclut par :',
   '["Un examen théorique commun + spécialité","Un simple QCM gratuit","Un entretien d''embauche","Un stage à l''étranger"]'::jsonb, 0, 'standard', 9, true),

  -- BC2 Gestion d''activité (9)
  (v_taxi, v_bc2, 'Une activité Taxi/VTC peut être exercée :',
   '["Uniquement en SAS","En micro-entreprise, EI, société (SARL/SAS), salarié","Uniquement en société","Uniquement comme salarié"]'::jsonb, 1, 'facile', 1, true),
  (v_taxi, v_bc2, 'La TVA collectée par un VTC est :',
   '["0 %","10 % sur le transport de personnes","20 % sur tout","Exonérée toujours"]'::jsonb, 1, 'standard', 2, true),
  (v_taxi, v_bc2, 'Le seuil de franchise TVA en micro-entreprise prestation :',
   '["77 700 €","36 800 € (à vérifier annuellement)","100 000 €","Aucun seuil"]'::jsonb, 1, 'difficile', 3, true),
  (v_taxi, v_bc2, 'Une assurance obligatoire spécifique pour Taxi/VTC :',
   '["RC professionnelle transport de personnes","RC privée seulement","Multirisque habitation","Aucune"]'::jsonb, 0, 'facile', 4, true),
  (v_taxi, v_bc2, 'La rentabilité d''un Taxi dépend principalement de :',
   '["Marque du véhicule","Taux de course payée / km parcouru","Couleur de carrosserie","Météo locale uniquement"]'::jsonb, 1, 'standard', 5, true),
  (v_taxi, v_bc2, 'Un reçu doit comporter :',
   '["Date, montant, immat, identité du chauffeur (selon réglementation)","Uniquement le montant","Aucune mention","Le numéro client"]'::jsonb, 0, 'standard', 6, true),
  (v_taxi, v_bc2, 'Le RGPD impose au Taxi/VTC :',
   '["Aucune obligation","Information client + sécurisation des données traitées","Diffusion publique des trajets","Vente des données autorisée"]'::jsonb, 1, 'standard', 7, true),
  (v_taxi, v_bc2, 'Le CPF peut financer :',
   '["Le permis B et certaines formations Taxi/VTC éligibles","Aucune formation","Uniquement les masters","Le carburant"]'::jsonb, 0, 'facile', 8, true),
  (v_taxi, v_bc2, 'Un compte bancaire dédié à l''activité est :',
   '["Inutile","Recommandé / obligatoire selon statut","Interdit","Réservé aux SARL"]'::jsonb, 1, 'standard', 9, true),

  -- BC3 Sécurité et conduite (7)
  (v_taxi, v_bc3, 'Conduire un Taxi en état d''ivresse :',
   '["Toléré sous 0,5 g","Sanction renforcée car transport public de personnes","Aucune sanction","Uniquement contravention"]'::jsonb, 1, 'facile', 1, true),
  (v_taxi, v_bc3, 'Le passager au siège passager :',
   '["Doit toujours être attaché","N''est pas tenu d''attacher la ceinture","Peut être debout","Peut détacher la ceinture en circulation"]'::jsonb, 0, 'facile', 2, true),
  (v_taxi, v_bc3, 'Un client agressif : la priorité du chauffeur est :',
   '["Riposter","Sécuriser, alerter (17), ne pas insister, déclarer","Insulter","Filmer"]'::jsonb, 1, 'facile', 3, true),
  (v_taxi, v_bc3, 'L''entretien régulier du véhicule est :',
   '["Optionnel","Obligatoire (sécurité passagers + image)","Annuel uniquement","Confié au client"]'::jsonb, 1, 'facile', 4, true),
  (v_taxi, v_bc3, 'En cas d''accident avec passager :',
   '["Continuer la course","S''arrêter, sécuriser, alerter, constat","Demander au client de finir le trajet à pied","Effacer la course de l''appli"]'::jsonb, 1, 'facile', 5, true),
  (v_taxi, v_bc3, 'L''éco-conduite réduit la consommation jusqu''à :',
   '["1 %","10–20 %","50 %","Pas d''effet"]'::jsonb, 1, 'standard', 6, true),
  (v_taxi, v_bc3, 'Un GPS bien utilisé doit être :',
   '["Tenu en main","Fixé / paramétré avant départ, voix activée","Désactivé en ville","Uniquement la nuit"]'::jsonb, 1, 'facile', 7, true),

  -- ============================================================
  -- 6. Commissionnaire de transport
  -- ============================================================
  -- BC1 Cadre juridique (9)
  (v_commiss, v_bc1, 'Un commissionnaire de transport :',
   '["Conduit lui-même","Organise le transport pour le compte d''autrui","Vend des camions","Loue uniquement"]'::jsonb, 1, 'facile', 1, true),
  (v_commiss, v_bc1, 'L''attestation de capacité commissionnaire est nationale et :',
   '["Délivrée par la mairie","Délivrée par l''autorité administrative compétente après examen","Achetable","Optionnelle"]'::jsonb, 1, 'standard', 2, true),
  (v_commiss, v_bc1, 'Le contrat-type commission s''applique :',
   '["Toujours","À défaut de convention écrite contraire","Uniquement à l''international","Uniquement en ADR"]'::jsonb, 1, 'standard', 3, true),
  (v_commiss, v_bc1, 'La responsabilité du commissionnaire est :',
   '["Forfaitaire CMR","De résultat (sauf cas d''exonération)","Inexistante","Limitée à 1 €"]'::jsonb, 1, 'difficile', 4, true),
  (v_commiss, v_bc1, 'La capacité financière exigée pour commissionnaire :',
   '["1 800 €","100 000 € (entreprise déjà existante)","9 000 €","50 000 €"]'::jsonb, 1, 'difficile', 5, true),
  (v_commiss, v_bc1, 'L''Incoterm DDP signifie :',
   '["Delivered Duty Paid","Door Direct Pickup","Department of Delivery Plan","Direct Distance Pricing"]'::jsonb, 0, 'standard', 6, true),
  (v_commiss, v_bc1, 'L''Incoterm EXW met les coûts/risques :',
   '["Sur le vendeur","Sur l''acheteur dès enlèvement","Partagés 50/50","Sur le transporteur"]'::jsonb, 1, 'standard', 7, true),
  (v_commiss, v_bc1, 'Le BL (Bill of Lading) est utilisé en :',
   '["Routier","Maritime","Aérien","Ferroviaire"]'::jsonb, 1, 'standard', 8, true),
  (v_commiss, v_bc1, 'La LTA est utilisée en :',
   '["Maritime","Aérien","Routier","Ferroviaire"]'::jsonb, 1, 'standard', 9, true),

  -- BC2 Multimodal et international (9)
  (v_commiss, v_bc2, 'Le transport "multimodal" combine :',
   '["Un seul mode","Plusieurs modes (route, mer, fer, air) sous un même contrat","Aucun mode","Uniquement route + air"]'::jsonb, 1, 'facile', 1, true),
  (v_commiss, v_bc2, 'Un EVP désigne :',
   '["Équivalent Vingt Pieds (conteneur)","Échange Volontaire Premium","Émission de Véhicule Polluant","Espace Vacant Palette"]'::jsonb, 0, 'standard', 2, true),
  (v_commiss, v_bc2, 'Le carnet TIR sert à :',
   '["Faciliter le transit douanier international par route","Acheter un véhicule","Payer la TVA","Faire l''ADR"]'::jsonb, 0, 'difficile', 3, true),
  (v_commiss, v_bc2, 'Le code SH (Système Harmonisé) :',
   '["Classification douanière mondiale","Logiciel d''horaires","Norme sécurité","Indice pétrolier"]'::jsonb, 0, 'standard', 4, true),
  (v_commiss, v_bc2, 'Le DAU (document administratif unique) est utilisé pour :',
   '["Les déclarations en douane","Le tachygraphe","Les amendes","Le contrôle technique"]'::jsonb, 0, 'standard', 5, true),
  (v_commiss, v_bc2, 'Un transit douanier T1 concerne :',
   '["Marchandises non communautaires en suspension de droits","Tout transport intra-UE","Uniquement le luxe","Les marchandises agricoles"]'::jsonb, 0, 'difficile', 6, true),
  (v_commiss, v_bc2, 'Le poids volumique aérien standard est :',
   '["1 m³ = 167 kg","1 m³ = 1 000 kg","1 m³ = 50 kg","Aucun ratio"]'::jsonb, 0, 'difficile', 7, true),
  (v_commiss, v_bc2, 'L''AEO (OEA) est :',
   '["Un statut d''opérateur économique agréé en douane","Une assurance maritime","Un syndicat","Un code postal"]'::jsonb, 0, 'difficile', 8, true),
  (v_commiss, v_bc2, 'Le vrac liquide est principalement transporté en :',
   '["Citerne","Conteneur palettisé","Caisse","Sac"]'::jsonb, 0, 'facile', 9, true),

  -- BC3 Économie et gestion (7)
  (v_commiss, v_bc3, 'Le freight forwarder calcule sa marge sur :',
   '["Différence entre tarif d''achat (transporteur) et tarif de vente (client)","Le carburant","La TVA","Les pénalités"]'::jsonb, 0, 'standard', 1, true),
  (v_commiss, v_bc3, 'Une assurance ad valorem :',
   '["Couvre la valeur déclarée des marchandises","Couvre uniquement la RC","Est interdite","Concerne uniquement l''ADR"]'::jsonb, 0, 'standard', 2, true),
  (v_commiss, v_bc3, 'Le BSCC (cautionnement) sert à :',
   '["Garantir la solvabilité auprès des transporteurs","Payer la TVA","Acheter des véhicules","Couvrir les pénalités"]'::jsonb, 0, 'difficile', 3, true),
  (v_commiss, v_bc3, 'Un TMS (Transport Management System) sert à :',
   '["Cuisiner","Piloter, optimiser et tracer les opérations transport","Imprimer des étiquettes uniquement","Recruter"]'::jsonb, 1, 'facile', 4, true),
  (v_commiss, v_bc3, 'Un KPI clé en commission de transport :',
   '["Marge brute par dossier","Météo","Couleur des camions","Nombre d''appels"]'::jsonb, 0, 'standard', 5, true),
  (v_commiss, v_bc3, 'Le BFR (besoin en fonds de roulement) :',
   '["Argent nécessaire à financer le cycle d''exploitation","Bilan annuel","Ratio salarial","Bénéfice net"]'::jsonb, 0, 'standard', 6, true),
  (v_commiss, v_bc3, 'L''assurance RC commissionnaire est :',
   '["Optionnelle","Indispensable / obligatoire en pratique","Réservée à l''international","Interdite"]'::jsonb, 1, 'facile', 7, true),

  -- ============================================================
  -- 7. Capacité ≤ 3,5 t (Capacité légère)
  -- ============================================================
  -- BC1 Réglementation (9)
  (v_capa, v_bc1, 'L''attestation de capacité ≤ 3,5 t est exigée pour :',
   '["Tout véhicule routier","Exploiter avec des véhicules motorisés > 0,5 t et ≤ 3,5 t en compte d''autrui","Uniquement les VTC","Uniquement à l''international"]'::jsonb, 1, 'standard', 1, true),
  (v_capa, v_bc1, 'L''examen national capacité ≤ 3,5 t est de type :',
   '["Oral","QCM","Mémoire","Pratique uniquement"]'::jsonb, 1, 'facile', 2, true),
  (v_capa, v_bc1, 'La licence de transport intérieur (LTI) est délivrée par :',
   '["DREAL","La mairie","La SNCF","L''ANTS"]'::jsonb, 0, 'standard', 3, true),
  (v_capa, v_bc1, 'Un VUL (véhicule utilitaire léger) typique :',
   '["≤ 3,5 t PTAC","> 12 t","< 0,5 t","Tracteur agricole"]'::jsonb, 0, 'facile', 4, true),
  (v_capa, v_bc1, 'L''honorabilité professionnelle :',
   '["Casier judiciaire compatible (non condamné pour certaines infractions)","N''existe pas","Réservée aux dirigeants étrangers","Optionnelle"]'::jsonb, 0, 'standard', 5, true),
  (v_capa, v_bc1, 'La capacité financière VL est de :',
   '["1 800 € pour 1er véhicule, 900 € par suivant","9 000 €","50 000 €","Aucune"]'::jsonb, 0, 'difficile', 6, true),
  (v_capa, v_bc1, 'Le contrat type "messagerie" s''applique :',
   '["Aux livraisons palettes lourdes","Aux envois ≤ 3 t en VL","Au déménagement","Au TMD"]'::jsonb, 1, 'standard', 7, true),
  (v_capa, v_bc1, 'Un VL employé en messagerie est limité à :',
   '["7,5 t","3,5 t PTAC (catégorie B)","12 t","19 t"]'::jsonb, 1, 'facile', 8, true),
  (v_capa, v_bc1, 'L''immatriculation flotte est traçée via :',
   '["Le SIV","Le RNIPP","La DREAL uniquement","Le Trésor public"]'::jsonb, 0, 'standard', 9, true),

  -- BC2 Gestion d''entreprise (9)
  (v_capa, v_bc2, 'Le statut juridique recommandé pour démarrer seul :',
   '["SA obligatoire","Micro-entreprise, EI ou EURL/SASU","Association","Coopérative"]'::jsonb, 1, 'facile', 1, true),
  (v_capa, v_bc2, 'La TVA en messagerie nationale est généralement :',
   '["20 %","10 % uniquement","0 %","5,5 %"]'::jsonb, 0, 'standard', 2, true),
  (v_capa, v_bc2, 'L''URSSAF gère :',
   '["Cotisations sociales","TVA","Impôts sur les sociétés","Permis de conduire"]'::jsonb, 0, 'facile', 3, true),
  (v_capa, v_bc2, 'Un compte de résultat fait apparaître :',
   '["Produits − charges = résultat","Actif − passif","Solde bancaire uniquement","Liste des clients"]'::jsonb, 0, 'standard', 4, true),
  (v_capa, v_bc2, 'Un seuil de rentabilité indique :',
   '["Le CA pour couvrir l''ensemble des charges","Le bénéfice net","Le coût d''un véhicule","Le PIB"]'::jsonb, 0, 'standard', 5, true),
  (v_capa, v_bc2, 'Le coût km moyen d''un VUL diesel est environ :',
   '["0,10 €/km","0,40 € à 0,60 €/km (variable)","2 €/km","5 €/km"]'::jsonb, 1, 'difficile', 6, true),
  (v_capa, v_bc2, 'L''amortissement comptable d''un VUL :',
   '["1 an","Linéaire 4-5 ans typiquement","20 ans","Pas d''amortissement"]'::jsonb, 1, 'standard', 7, true),
  (v_capa, v_bc2, 'Un contrat de location longue durée (LLD) :',
   '["Inclut souvent entretien et assurance","Achat immédiat","Sans loyer","Réservé aux SARL"]'::jsonb, 0, 'facile', 8, true),
  (v_capa, v_bc2, 'Un devis transport doit comporter :',
   '["Identité, prestation, prix, conditions","Uniquement le prix","Aucune mention","Couleur du véhicule"]'::jsonb, 0, 'facile', 9, true),

  -- BC3 Sécurité et qualité (7)
  (v_capa, v_bc3, 'Le PTAC du véhicule désigne :',
   '["Poids Total Autorisé en Charge","Périmètre Tarifaire d''Action Commerciale","Plan Total d''Activité Conducteur","Permis Type Auto Camion"]'::jsonb, 0, 'facile', 1, true),
  (v_capa, v_bc3, 'Un véhicule en surcharge :',
   '["Risque amende, immobilisation, accident","Aucune conséquence","Réduction d''assurance","Bonus carburant"]'::jsonb, 0, 'facile', 2, true),
  (v_capa, v_bc3, 'L''arrimage de la marchandise est :',
   '["Optionnel","Obligatoire (sécurité, art. R. 312 c. route)","Confié au client","Réalisé en roulant"]'::jsonb, 1, 'facile', 3, true),
  (v_capa, v_bc3, 'Un constat amiable doit être :',
   '["Rédigé sur place, signé des deux parties","Envoyé sous 6 mois","Oral","Inutile"]'::jsonb, 0, 'facile', 4, true),
  (v_capa, v_bc3, 'Un suivi des kilomètres / consommation sert à :',
   '["Optimiser et détecter dérives","Décorer le bureau","Punir les conducteurs","Aucune utilité"]'::jsonb, 0, 'standard', 5, true),
  (v_capa, v_bc3, 'L''entretien préventif d''un VUL :',
   '["Inutile","Selon plan constructeur (vidange, pneus, freins…)","Tous les 5 ans","Tous les 100 000 km uniquement"]'::jsonb, 1, 'facile', 6, true),
  (v_capa, v_bc3, 'Un EPI de base pour livraison palettes :',
   '["Chaussures de sécurité, gants, gilet HV","Casque moto","Lunettes de soleil","Aucun"]'::jsonb, 0, 'facile', 7, true),

  -- ============================================================
  -- 8. Capacité > 3,5 t (Capacité lourde)
  -- ============================================================
  -- BC1 Réglementation (9)
  (v_capa_plus, v_bc1, 'L''attestation de capacité > 3,5 t s''obtient via :',
   '["Examen national écrit (8 h)","Achat","Cours en ligne libre","Pratique uniquement"]'::jsonb, 0, 'facile', 1, true),
  (v_capa_plus, v_bc1, 'Un véhicule articulé > 3,5 t est régi par :',
   '["Le permis B","Le permis CE / règles PL","Aucun permis","Le permis D"]'::jsonb, 1, 'facile', 2, true),
  (v_capa_plus, v_bc1, 'La capacité financière 1er véhicule > 3,5 t :',
   '["1 800 €","9 000 €","50 000 €","100 000 €"]'::jsonb, 1, 'difficile', 3, true),
  (v_capa_plus, v_bc1, 'Tout véhicule par tranche supplémentaire (> 3,5 t) requiert :',
   '["1 800 € de capacité financière","5 000 € de capacité financière","50 000 €","Rien"]'::jsonb, 1, 'difficile', 4, true),
  (v_capa_plus, v_bc1, 'Le règlement (CE) 1071/2009 impose à l''entreprise :',
   '["Établissement réel et stable","Aucun lieu fixe","Une adresse postale uniquement","Un coffre-fort"]'::jsonb, 0, 'standard', 5, true),
  (v_capa_plus, v_bc1, 'La licence communautaire est valable :',
   '["1 an","10 ans (renouvelable)","À vie","6 mois"]'::jsonb, 1, 'standard', 6, true),
  (v_capa_plus, v_bc1, 'Le tachygraphe est obligatoire pour PL > :',
   '["1,5 t","3,5 t (avec exemptions limitées)","7,5 t","12 t"]'::jsonb, 1, 'standard', 7, true),
  (v_capa_plus, v_bc1, 'Le contrat-type général s''applique :',
   '["Toujours obligatoirement","À défaut de convention écrite","Uniquement à l''international","Uniquement TMD"]'::jsonb, 1, 'standard', 8, true),
  (v_capa_plus, v_bc1, 'Les 4 conditions d''accès à la profession sont :',
   '["Honorabilité, capacité professionnelle, capacité financière, établissement","CV + lettre de motivation","Examen + permis","Bilan + assurance"]'::jsonb, 0, 'difficile', 9, true),

  -- BC2 Gestion d''entreprise (9)
  (v_capa_plus, v_bc2, 'Une EI à responsabilité limitée :',
   '["EIRL (séparation des patrimoines)","Société anonyme","Coopérative","Association"]'::jsonb, 0, 'standard', 1, true),
  (v_capa_plus, v_bc2, 'La rentabilité d''un PL se mesure prioritairement par :',
   '["Marge sur CA / km","Couleur du camion","Météo","Nombre de feux verts"]'::jsonb, 0, 'standard', 2, true),
  (v_capa_plus, v_bc2, 'Le CRKM permet :',
   '["Déterminer un prix de vente couvrant les coûts","Calculer la TVA","Lire le tachy","Acheter du carburant moins cher"]'::jsonb, 0, 'standard', 3, true),
  (v_capa_plus, v_bc2, 'Un fonds de roulement positif signifie :',
   '["L''entreprise finance correctement son cycle","Faillite imminente","Trop de salariés","Aucune information"]'::jsonb, 0, 'difficile', 4, true),
  (v_capa_plus, v_bc2, 'Le BFR négatif est typique :',
   '["Du transport longue distance","De la grande distribution avec stocks faibles","De l''industrie lourde","De l''agriculture"]'::jsonb, 1, 'difficile', 5, true),
  (v_capa_plus, v_bc2, 'Un investissement véhicule peut être financé par :',
   '["Crédit-bail, location longue durée, autofinancement, prêt","Carte de paiement uniquement","Don","CPF"]'::jsonb, 0, 'facile', 6, true),
  (v_capa_plus, v_bc2, 'L''indice CNR pour le gazole sert :',
   '["À indexer les prix transport sur le carburant","À fixer la TVA","À calculer la paie","Aucun usage"]'::jsonb, 0, 'standard', 7, true),
  (v_capa_plus, v_bc2, 'La grille de salaires conventionnelle (CCNTR) :',
   '["Optionnelle","Convention collective applicable obligatoirement","Régionale uniquement","Réservée aux PL > 12 t"]'::jsonb, 1, 'standard', 8, true),
  (v_capa_plus, v_bc2, 'Un indicateur d''activité-clé en transport :',
   '["Taux de remplissage","Météo","Nombre de cafés","Couleur"]'::jsonb, 0, 'facile', 9, true),

  -- BC3 Sécurité et qualité (7)
  (v_capa_plus, v_bc3, 'La visite technique d''un PL > 3,5 t :',
   '["Annuelle","Tous les 5 ans","Tous les 6 mois pour certaines catégories","Jamais"]'::jsonb, 0, 'standard', 1, true),
  (v_capa_plus, v_bc3, 'L''ADR encadre :',
   '["Le transport de marchandises dangereuses par route","Les périssables","L''international uniquement","Les frigos"]'::jsonb, 0, 'facile', 2, true),
  (v_capa_plus, v_bc3, 'Le permis matières dangereuses (ADR) est :',
   '["Optionnel","Obligatoire pour conducteurs concernés","Délivré par la mairie","Achetable"]'::jsonb, 1, 'facile', 3, true),
  (v_capa_plus, v_bc3, 'Le DUER est :',
   '["Document Unique d''Évaluation des Risques (entreprise)","Document Européen Routier","Déclaration Unifiée Entreprise Régionale","Diplôme de conducteur"]'::jsonb, 0, 'standard', 4, true),
  (v_capa_plus, v_bc3, 'La norme ISO 9001 concerne :',
   '["Le management de la qualité","L''environnement","La sécurité","La comptabilité"]'::jsonb, 0, 'standard', 5, true),
  (v_capa_plus, v_bc3, 'Une démarche RSE en transport vise notamment :',
   '["Réduction CO₂, conditions de travail, éthique fournisseurs","Augmenter les vitesses","Diminuer les pauses","Délocaliser"]'::jsonb, 0, 'standard', 6, true),
  (v_capa_plus, v_bc3, 'Une indemnité kilométrique conducteur (frais déplacement) :',
   '["Cadrée par convention collective et URSSAF","Libre","Interdite","Sans plafond"]'::jsonb, 0, 'difficile', 7, true);

  RAISE NOTICE 'Placement seed : 200 questions insérées (8 formations × 25 questions).';
END $placement_seed$;
