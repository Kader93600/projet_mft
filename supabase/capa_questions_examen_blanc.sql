-- =====================================================================
-- BANQUE Capacité de transport léger — EXAMEN BLANC complet
-- 50 questions supplémentaires niveau examen final.
--
-- Mix :
--  - 40 QCM de synthèse (toutes thématiques mélangées)
--  - 10 QR (cas pratiques approfondis multi-modules)
--
-- Ces questions complètent supabase/capa_questions_premium.sql.
-- Tags : 'capa-3-5t' + 'examen-blanc' + thématique
-- source_ref='mft-original-2026-eb:N' (eb = examen blanc)
-- =====================================================================

DO $eb_capa$
DECLARE
  formation_uuid uuid;
BEGIN
  SELECT id INTO formation_uuid FROM public.formations WHERE slug = 'capacite-3-5t';
  IF formation_uuid IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable.';
  END IF;

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES

  -- ──── 1. Création d'entreprise ────────────────────────────────────
  (formation_uuid, 'qcm',
   'Pour créer une entreprise de coursier-livraison sans associé et avec un statut social proche du salariat, quelle forme est la plus adaptée ?',
   '[{"id":"a","label":"Auto-entrepreneur","is_correct":false},
     {"id":"b","label":"EURL","is_correct":false},
     {"id":"c","label":"SASU","is_correct":true},
     {"id":"d","label":"SCI","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-a','droit','cas-pratique'],
   'mft-original-2026-eb:1', true,
   'La SASU offre au dirigeant le statut d''assimilé-salarié (régime général de la Sécurité sociale) et permet de récupérer la TVA, contrairement à l''auto-entrepreneur. L''EURL impose le statut de TNS (moins protecteur).'),

  (formation_uuid, 'qcm',
   'Le capital social minimum d''une SARL est :',
   '[{"id":"a","label":"1 €","is_correct":true},
     {"id":"b","label":"7 500 €","is_correct":false},
     {"id":"c","label":"15 000 €","is_correct":false},
     {"id":"d","label":"37 000 €","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','examen-blanc','module-a','droit'],
   'mft-original-2026-eb:2', true,
   'Depuis 2003, le capital minimum d''une SARL est libre, fixé par les associés (minimum symbolique 1 €). Il n''y a plus de seuil légal.'),

  (formation_uuid, 'qcm',
   'L''immatriculation au Registre du Commerce et des Sociétés (RCS) doit intervenir :',
   '[{"id":"a","label":"Avant le démarrage de l''activité","is_correct":true},
     {"id":"b","label":"Dans les 3 mois suivant le démarrage","is_correct":false},
     {"id":"c","label":"Au premier jour du mois suivant la création","is_correct":false},
     {"id":"d","label":"Uniquement pour les SARL et SAS","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','examen-blanc','module-a','droit'],
   'mft-original-2026-eb:3', true,
   'L''immatriculation au RCS conditionne l''existence légale de la société commerciale. Elle est préalable au démarrage effectif de l''activité.'),

  (formation_uuid, 'qcm',
   'La dénomination sociale d''une SARL ne peut pas comporter :',
   '[{"id":"a","label":"Le nom du gérant uniquement","is_correct":false},
     {"id":"b","label":"Une expression de fantaisie","is_correct":false},
     {"id":"c","label":"Le nom d''un produit","is_correct":false},
     {"id":"d","label":"Un nom déjà utilisé par une autre société dans le même secteur","is_correct":true}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-a','droit','marque'],
   'mft-original-2026-eb:4', true,
   'La dénomination doit être disponible (pas de risque de confusion avec une marque ou société existante dans le même secteur). Vérification INPI recommandée.'),

  -- ──── 2. Capacité professionnelle & licence ──────────────────────
  (formation_uuid, 'qcm',
   'Pour obtenir l''attestation de capacité de transport léger par équivalence sans examen, il faut :',
   '[{"id":"a","label":"Au moins 5 ans d''expérience comme dirigeant d''entreprise de transport","is_correct":false},
     {"id":"b","label":"2 ans d''expérience en gestion d''entreprise de transport routier de marchandises","is_correct":true},
     {"id":"c","label":"Le permis poids lourd C","is_correct":false},
     {"id":"d","label":"La FIMO marchandises","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-c','reglementation'],
   'mft-original-2026-eb:5', true,
   'L''équivalence pour le transport léger est accordée après 2 ans d''expérience continue en gestion d''une entreprise de transport routier de marchandises au cours des 10 dernières années.'),

  (formation_uuid, 'qcm',
   'La capacité financière minimale exigée pour exercer le transport léger est :',
   '[{"id":"a","label":"900 € par véhicule","is_correct":false},
     {"id":"b","label":"1 800 € pour le premier véhicule, 900 € par véhicule supplémentaire","is_correct":true},
     {"id":"c","label":"5 000 € forfaitaire","is_correct":false},
     {"id":"d","label":"9 000 € pour le premier véhicule","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-c','reglementation','financier'],
   'mft-original-2026-eb:6', true,
   'Règlement (CE) n° 1071/2009 : 1 800 € pour le 1er véhicule ≤ 3,5T, puis 900 € pour chaque véhicule supplémentaire. Justifiée par fonds propres ou caution bancaire.'),

  (formation_uuid, 'qcm',
   'L''honorabilité professionnelle peut être perdue suite à :',
   '[{"id":"a","label":"Un seul retrait de point sur le permis","is_correct":false},
     {"id":"b","label":"Une condamnation pour banqueroute","is_correct":true},
     {"id":"c","label":"Un licenciement pour faute simple","is_correct":false},
     {"id":"d","label":"Une amende fiscale","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-c','reglementation'],
   'mft-original-2026-eb:7', true,
   'Les condamnations graves (banqueroute, abus de confiance, infractions graves au transport) entraînent la perte de l''honorabilité et l''interdiction d''exercer.'),

  (formation_uuid, 'qcm',
   'La licence de transport intérieur est délivrée par :',
   '[{"id":"a","label":"La préfecture","is_correct":false},
     {"id":"b","label":"La DREAL (Direction Régionale Environnement)","is_correct":true},
     {"id":"c","label":"La Chambre de Commerce","is_correct":false},
     {"id":"d","label":"Le ministère du Transport","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','examen-blanc','module-c','reglementation'],
   'mft-original-2026-eb:8', true,
   'La DREAL est le service déconcentré de l''État qui tient le registre des transporteurs et délivre les licences (intérieure, communautaire).'),

  (formation_uuid, 'qcm',
   'La copie conforme de la licence doit être présente :',
   '[{"id":"a","label":"Au siège social uniquement","is_correct":false},
     {"id":"b","label":"À bord de chaque véhicule en circulation","is_correct":true},
     {"id":"c","label":"Au domicile du dirigeant","is_correct":false},
     {"id":"d","label":"Uniquement lors des contrôles de la DREAL","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-c','reglementation','controle'],
   'mft-original-2026-eb:9', true,
   'Une copie certifiée conforme doit obligatoirement être présente à bord de chaque véhicule. Document contrôlable par la police, gendarmerie, DREAL.'),

  -- ──── 3. Contrats & responsabilité ────────────────────────────────
  (formation_uuid, 'qcm',
   'Le contrat type général s''applique :',
   '[{"id":"a","label":"Si les parties l''ont expressément choisi","is_correct":false},
     {"id":"b","label":"En l''absence de convention écrite entre les parties","is_correct":true},
     {"id":"c","label":"Uniquement pour les transports internationaux","is_correct":false},
     {"id":"d","label":"Pour les transports de marchandises dangereuses","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-c','reglementation','contrat'],
   'mft-original-2026-eb:10', true,
   'Le contrat type général (décret n° 99-269) s''applique de plein droit en l''absence de convention spécifique entre les parties.'),

  (formation_uuid, 'qcm',
   'En cas de perte d''un colis de 12 kg, l''indemnité due par le transporteur (transport intérieur) est plafonnée à :',
   '[{"id":"a","label":"23 € HT × 12 = 276 €","is_correct":true},
     {"id":"b","label":"Valeur déclarée par l''expéditeur","is_correct":false},
     {"id":"c","label":"750 € forfaitaire","is_correct":false},
     {"id":"d","label":"Aucune indemnité sans assurance","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-c','reglementation','indemnisation','cas-pratique'],
   'mft-original-2026-eb:11', true,
   'Indemnisation au poids : 23 € HT par kg manquant ou avarié, dans la limite de 750 € par colis (Contrat type général). Pour 12 kg : 276 €.'),

  (formation_uuid, 'qcm',
   'Le délai pour formuler une réclamation pour perte ou avarie après livraison est de :',
   '[{"id":"a","label":"24 heures","is_correct":false},
     {"id":"b","label":"3 jours ouvrables","is_correct":true},
     {"id":"c","label":"7 jours","is_correct":false},
     {"id":"d","label":"30 jours","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-c','reglementation'],
   'mft-original-2026-eb:12', true,
   'Le destinataire dispose de 3 jours ouvrables pour formuler une réclamation à compter de la date de réception, sous peine de présomption de bonne livraison.'),

  -- ──── 4. Activité commerciale ────────────────────────────────────
  (formation_uuid, 'qcm',
   'Une facture entre professionnels doit comporter obligatoirement :',
   '[{"id":"a","label":"Le numéro RCS uniquement","is_correct":false},
     {"id":"b","label":"Numéro SIREN, SIRET, RCS, mention TVA","is_correct":true},
     {"id":"c","label":"Uniquement les mentions de l''article R. 123-237","is_correct":false},
     {"id":"d","label":"Le bénéficiaire effectif de la société","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-b','commercial'],
   'mft-original-2026-eb:13', true,
   'Mentions obligatoires : SIREN, RCS, forme juridique, capital social, mention TVA (assujettissement et n° intracommunautaire si applicable), conditions de règlement, escompte, pénalités de retard.'),

  (formation_uuid, 'qcm',
   'En cas d''impayé d''un client, la première démarche amiable est :',
   '[{"id":"a","label":"Saisir directement le tribunal de commerce","is_correct":false},
     {"id":"b","label":"Envoyer une lettre de relance puis une mise en demeure","is_correct":true},
     {"id":"c","label":"Bloquer immédiatement les prochaines livraisons","is_correct":false},
     {"id":"d","label":"Inscrire la créance au passif du client","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','examen-blanc','module-b','commercial','recouvrement'],
   'mft-original-2026-eb:14', true,
   'Démarche graduée : relance simple, mise en demeure (LRAR), puis injonction de payer ou assignation. Privilégier l''amiable avant le contentieux.'),

  (formation_uuid, 'qcm',
   'Le délai de prescription pour recouvrer une créance commerciale entre professionnels est de :',
   '[{"id":"a","label":"1 an","is_correct":false},
     {"id":"b","label":"2 ans","is_correct":false},
     {"id":"c","label":"5 ans","is_correct":true},
     {"id":"d","label":"10 ans","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-b','commercial','recouvrement'],
   'mft-original-2026-eb:15', true,
   'La prescription des créances commerciales entre professionnels est de 5 ans (art. L. 110-4 C. commerce). Au-delà, action en paiement irrecevable.'),

  -- ──── 5. Comptabilité & gestion ─────────────────────────────────
  (formation_uuid, 'qcm',
   'L''amortissement linéaire d''un véhicule de 24 000 € sur 5 ans représente :',
   '[{"id":"a","label":"4 000 € par an","is_correct":false},
     {"id":"b","label":"4 800 € par an","is_correct":true},
     {"id":"c","label":"6 000 € par an","is_correct":false},
     {"id":"d","label":"12 000 € par an","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-d','financier','cas-pratique'],
   'mft-original-2026-eb:16', true,
   '24 000 / 5 = 4 800 € par an. Calcul de base de l''amortissement linéaire.'),

  (formation_uuid, 'qcm',
   'Si vos charges fixes mensuelles sont 8 000 € et votre marge sur coûts variables 12 € par km, votre seuil de rentabilité est de :',
   '[{"id":"a","label":"500 km/mois","is_correct":false},
     {"id":"b","label":"667 km/mois","is_correct":true},
     {"id":"c","label":"1 000 km/mois","is_correct":false},
     {"id":"d","label":"1 200 km/mois","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-d','financier','cas-pratique'],
   'mft-original-2026-eb:17', true,
   'Seuil = Charges fixes / Marge unitaire = 8 000 / 12 ≈ 667 km. Au-delà, l''entreprise est rentable.'),

  (formation_uuid, 'qcm',
   'La TVA sur le carburant utilisé par un véhicule utilitaire ≤ 3,5T affecté à un usage professionnel est :',
   '[{"id":"a","label":"Récupérable à 100 %","is_correct":true},
     {"id":"b","label":"Récupérable à 80 %","is_correct":false},
     {"id":"c","label":"Récupérable à 50 %","is_correct":false},
     {"id":"d","label":"Non récupérable","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-d','financier','tva'],
   'mft-original-2026-eb:18', true,
   'Pour un VU ≤ 3,5T à usage exclusivement professionnel, la TVA sur le carburant est intégralement récupérable. Pour un véhicule de tourisme : 80 % gazole, 0 % essence (sauf cas particuliers).'),

  (formation_uuid, 'qcm',
   'Un bilan comptable se présente toujours :',
   '[{"id":"a","label":"En liste : produits puis charges","is_correct":false},
     {"id":"b","label":"En tableau : actif à gauche, passif à droite, équilibre","is_correct":true},
     {"id":"c","label":"En graphique","is_correct":false},
     {"id":"d","label":"Sous forme de ratios uniquement","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','examen-blanc','module-d','financier'],
   'mft-original-2026-eb:19', true,
   'Le bilan est équilibré : Actif (emplois) = Passif (ressources). Présentation en deux colonnes opposées.'),

  -- ──── 6. Salariés & temps de travail ─────────────────────────────
  (formation_uuid, 'qcm',
   'Pour un chauffeur en CDI à 35h/semaine, les heures effectuées entre la 36e et la 43e heure sont majorées de :',
   '[{"id":"a","label":"10 %","is_correct":false},
     {"id":"b","label":"25 %","is_correct":true},
     {"id":"c","label":"50 %","is_correct":false},
     {"id":"d","label":"75 %","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','examen-blanc','module-e','salaries'],
   'mft-original-2026-eb:20', true,
   'Les 8 premières heures supplémentaires (36e à 43e) sont majorées à 25 %. Au-delà (44e et suivantes) : 50 %.'),

  (formation_uuid, 'qcm',
   'La période d''essai d''un CDI cadre est de :',
   '[{"id":"a","label":"1 mois renouvelable une fois","is_correct":false},
     {"id":"b","label":"3 mois renouvelables une fois (6 mois max)","is_correct":false},
     {"id":"c","label":"4 mois renouvelables une fois (8 mois max)","is_correct":true},
     {"id":"d","label":"6 mois non renouvelable","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-e','salaries'],
   'mft-original-2026-eb:21', true,
   'Code du travail art. L. 1221-19 : 4 mois pour les cadres, renouvelable une fois (8 mois max). 2 mois pour ETAM (4 max), 1 mois pour ouvriers/employés (2 max).'),

  (formation_uuid, 'qcm',
   'Un salarié en CDI souhaite démissionner. Il doit :',
   '[{"id":"a","label":"Obtenir l''accord de l''employeur","is_correct":false},
     {"id":"b","label":"Notifier sa démission par écrit et respecter le préavis","is_correct":true},
     {"id":"c","label":"Trouver un remplaçant","is_correct":false},
     {"id":"d","label":"Justifier sa démission par un motif sérieux","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','examen-blanc','module-e','salaries'],
   'mft-original-2026-eb:22', true,
   'La démission est un acte unilatéral du salarié, libre et n''a pas à être justifiée. Elle doit être claire, sans équivoque, et le préavis doit être respecté (sauf dispense).'),

  (formation_uuid, 'qcm',
   'La prime d''ancienneté dans la convention collective transport (CCNTRAAT) est attribuée à partir de :',
   '[{"id":"a","label":"6 mois d''ancienneté","is_correct":false},
     {"id":"b","label":"1 an","is_correct":false},
     {"id":"c","label":"2 ans","is_correct":true},
     {"id":"d","label":"5 ans","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-e','salaries','convention'],
   'mft-original-2026-eb:23', true,
   'CCNTRAAT : prime d''ancienneté à partir de 2 ans (2 %), évolutive jusqu''à 15 ans (15 %).'),

  (formation_uuid, 'qcm',
   'L''entretien professionnel obligatoire entre l''employeur et le salarié doit avoir lieu :',
   '[{"id":"a","label":"Tous les ans","is_correct":false},
     {"id":"b","label":"Tous les 2 ans","is_correct":true},
     {"id":"c","label":"Tous les 3 ans","is_correct":false},
     {"id":"d","label":"Uniquement à la demande du salarié","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-e','salaries','formation'],
   'mft-original-2026-eb:24', true,
   'L''entretien professionnel est obligatoire tous les 2 ans (Code du travail art. L. 6315-1). Distinct de l''entretien d''évaluation. Bilan tous les 6 ans.'),

  -- ──── 7. Sécurité ─────────────────────────────────────────────────
  (formation_uuid, 'qcm',
   'En période probatoire, le taux d''alcoolémie maximal autorisé est :',
   '[{"id":"a","label":"0,2 g/L de sang","is_correct":true},
     {"id":"b","label":"0,5 g/L","is_correct":false},
     {"id":"c","label":"0,8 g/L","is_correct":false},
     {"id":"d","label":"Tolérance zéro absolue","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-f','securite','permis'],
   'mft-original-2026-eb:25', true,
   'Permis probatoire : 0,2 g/L (sang) ou 0,1 mg/L (air expiré). Sanction immédiate au-delà : 6 points + amende.'),

  (formation_uuid, 'qcm',
   'L''alerte phonique d''un téléphone tenu en main au volant est :',
   '[{"id":"a","label":"Autorisée si à l''arrêt à un feu rouge","is_correct":false},
     {"id":"b","label":"Sanctionnée d''un retrait de 3 points","is_correct":true},
     {"id":"c","label":"Tolérée si moins de 5 secondes","is_correct":false},
     {"id":"d","label":"Sans sanction si simple consultation","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-f','securite','permis'],
   'mft-original-2026-eb:26', true,
   'L''usage d''un téléphone tenu en main au volant (même à l''arrêt à un feu) est sanctionné de 3 points + 135 € d''amende. Le kit mains-libres ne suffit plus en cas d''autres infractions.'),

  (formation_uuid, 'qcm',
   'La distance de sécurité minimale par temps de pluie est :',
   '[{"id":"a","label":"1 seconde","is_correct":false},
     {"id":"b","label":"2 secondes","is_correct":false},
     {"id":"c","label":"4 secondes","is_correct":true},
     {"id":"d","label":"50 mètres","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','examen-blanc','module-f','securite'],
   'mft-original-2026-eb:27', true,
   'Distance de sécurité doublée par temps de pluie (4 secondes au lieu de 2). Sur autoroute à 130 km/h, équivaut à ~145 mètres.'),

  (formation_uuid, 'qcm',
   'L''arrimage des marchandises est de la responsabilité :',
   '[{"id":"a","label":"De l''expéditeur uniquement","is_correct":false},
     {"id":"b","label":"Du destinataire","is_correct":false},
     {"id":"c","label":"Du transporteur","is_correct":true},
     {"id":"d","label":"Partagée entre expéditeur et transporteur","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-f','securite','responsabilite'],
   'mft-original-2026-eb:28', true,
   'Le transporteur est responsable de l''arrimage des marchandises sur son véhicule (art. R. 312-19 C. route). Sanction en cas de mauvais arrimage : amende, immobilisation, voire poursuites en cas d''accident.'),

  -- ──── 8. Multi-thématiques ────────────────────────────────────────
  (formation_uuid, 'qcm',
   'Une demande de capacité financière par cautionnement bancaire :',
   '[{"id":"a","label":"Est gratuite pour l''entreprise","is_correct":false},
     {"id":"b","label":"Coûte un % du montant cautionné par an","is_correct":true},
     {"id":"c","label":"N''est valable que 3 mois","is_correct":false},
     {"id":"d","label":"Remplace définitivement les fonds propres","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-c','reglementation','financier','cas-pratique'],
   'mft-original-2026-eb:29', true,
   'Le cautionnement bancaire est facturé annuellement (typiquement 1 à 3 % du montant). Alternative aux fonds propres pour la capacité financière.'),

  (formation_uuid, 'qcm',
   'Le commissionnaire de transport :',
   '[{"id":"a","label":"Est lui-même responsable de l''exécution du transport","is_correct":true},
     {"id":"b","label":"N''est qu''un intermédiaire sans responsabilité","is_correct":false},
     {"id":"c","label":"Doit avoir les mêmes véhicules que les transporteurs","is_correct":false},
     {"id":"d","label":"Travaille uniquement à l''international","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-c','reglementation'],
   'mft-original-2026-eb:30', true,
   'Le commissionnaire (Code commerce L. 132-1) est responsable de l''exécution du transport vis-à-vis de son commettant, même s''il sous-traite à un transporteur effectif.'),

  (formation_uuid, 'qcm',
   'En cas d''accident corporel responsable d''un de ses chauffeurs en mission, l''entreprise doit :',
   '[{"id":"a","label":"Prendre en charge sur sa trésorerie uniquement","is_correct":false},
     {"id":"b","label":"Déclarer immédiatement à son assurance et à la CPAM (AT-MP)","is_correct":true},
     {"id":"c","label":"Attendre l''avis de l''Inspecteur du travail","is_correct":false},
     {"id":"d","label":"Licencier le chauffeur","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-e','module-f','salaries','securite','cas-pratique'],
   'mft-original-2026-eb:31', true,
   'Déclaration AT obligatoire à la CPAM dans les 48h. L''assurance auto + responsabilité civile pro doivent aussi être informées immédiatement.'),

  (formation_uuid, 'qcm',
   'Le repos hebdomadaire d''un conducteur est généralement de :',
   '[{"id":"a","label":"24 heures","is_correct":false},
     {"id":"b","label":"45 heures consécutives","is_correct":true},
     {"id":"c","label":"36 heures","is_correct":false},
     {"id":"d","label":"48 heures","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-e','salaries','tachy'],
   'mft-original-2026-eb:32', true,
   'Repos hebdomadaire normal : 45h consécutives. Réductible à 24h une semaine sur deux, avec compensation à prendre dans les 3 semaines.'),

  (formation_uuid, 'qcm',
   'En cas de retard de livraison non justifié, l''indemnité maximale est plafonnée à :',
   '[{"id":"a","label":"10 % du prix de transport","is_correct":false},
     {"id":"b","label":"Montant du transport","is_correct":true},
     {"id":"c","label":"Préjudice subi prouvé","is_correct":false},
     {"id":"d","label":"Aucune indemnité due en transport routier","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-c','reglementation','contrat'],
   'mft-original-2026-eb:33', true,
   'Contrat type général : indemnité de retard plafonnée au montant du prix de transport (sauf préjudice supérieur prouvé).'),

  (formation_uuid, 'qcm',
   'L''économie d''énergie d''un comportement éco-conduite atteint typiquement :',
   '[{"id":"a","label":"2 à 5 %","is_correct":false},
     {"id":"b","label":"10 à 15 %","is_correct":true},
     {"id":"c","label":"25 à 30 %","is_correct":false},
     {"id":"d","label":"50 %","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','examen-blanc','module-d','module-f','financier','rse'],
   'mft-original-2026-eb:34', true,
   'L''éco-conduite (anticipation, vitesse stable, maintien régime moteur, pression pneus) permet 10 à 15 % d''économie de carburant en moyenne. Bénéfice écologique + financier direct.'),

  (formation_uuid, 'qcm',
   'Un client demande à payer en chèque un transport de 7 600 €. L''entreprise :',
   '[{"id":"a","label":"Doit refuser, le chèque étant interdit pour ce montant","is_correct":false},
     {"id":"b","label":"Accepte mais avec encaissement après 7 jours","is_correct":false},
     {"id":"c","label":"Peut accepter, mais doit vérifier le pouvoir et l''absence d''interdiction bancaire","is_correct":true},
     {"id":"d","label":"Ne peut accepter qu''un chèque certifié","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-b','commercial','paiement'],
   'mft-original-2026-eb:35', true,
   'Pas de plafond légal pour un chèque entre professionnels. Vérifications recommandées : Banque de France (FCC), pouvoir du signataire. Limite 1000 € pour les paiements en espèces.'),

  -- ──── 9. Cas pratiques avancés ────────────────────────────────────
  (formation_uuid, 'qcm',
   'Vous avez 2 chauffeurs en CDI 35h. Le premier a 10 ans d''ancienneté (prime 12 %). Sur un salaire de base 2 200 €, sa rémunération brute mensuelle hors heures supp est :',
   '[{"id":"a","label":"2 200 €","is_correct":false},
     {"id":"b","label":"2 264 €","is_correct":false},
     {"id":"c","label":"2 464 €","is_correct":true},
     {"id":"d","label":"2 640 €","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-d','module-e','financier','salaries','cas-pratique'],
   'mft-original-2026-eb:36', true,
   '2 200 + (2 200 × 12 %) = 2 200 + 264 = 2 464 €.'),

  (formation_uuid, 'qcm',
   'Pour 80 livraisons par jour, votre chauffeur dépasse les 9h de conduite à 11h alors qu''il restait 2 livraisons. Légalement :',
   '[{"id":"a","label":"Il finit ses livraisons puis prend son repos","is_correct":false},
     {"id":"b","label":"Il doit s''arrêter immédiatement et reprogrammer les livraisons","is_correct":true},
     {"id":"c","label":"Il peut continuer si commande urgente","is_correct":false},
     {"id":"d","label":"Il peut prolonger jusqu''à 12h","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-e','module-f','salaries','securite','tachy','cas-pratique'],
   'mft-original-2026-eb:37', true,
   'Limite stricte : 9h de conduite (10h max 2x/semaine). Au-delà : risque pénal pour le chauffeur ET l''entreprise. Les livraisons doivent être reprogrammées.'),

  (formation_uuid, 'qcm',
   'Un client refuse un colis à la livraison sans motif valable. Le transporteur :',
   '[{"id":"a","label":"Le restitue immédiatement à l''expéditeur","is_correct":false},
     {"id":"b","label":"Demande des instructions à l''expéditeur","is_correct":true},
     {"id":"c","label":"Conserve le colis sans frais","is_correct":false},
     {"id":"d","label":"Saisit le tribunal de commerce","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','examen-blanc','module-c','reglementation','cas-pratique'],
   'mft-original-2026-eb:38', true,
   'En cas d''empêchement à la livraison, le transporteur sollicite des instructions de l''expéditeur. Frais de stockage et de retour à la charge de ce dernier.'),

  (formation_uuid, 'qcm',
   'Vous achetez un VU d''occasion 18 000 € HT et le mettez en service en juillet. L''amortissement de la 1ère année (linéaire 5 ans, prorata) est :',
   '[{"id":"a","label":"3 600 €","is_correct":false},
     {"id":"b","label":"1 800 € (6 mois sur 12)","is_correct":true},
     {"id":"c","label":"900 €","is_correct":false},
     {"id":"d","label":"3 000 €","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-d','financier','cas-pratique'],
   'mft-original-2026-eb:39', true,
   'Annuité pleine = 18 000 / 5 = 3 600. Mise en service en juillet → 6 mois d''utilisation l''année 1 → 3 600 × 6/12 = 1 800 €.'),

  (formation_uuid, 'qcm',
   'Un sinistre détruit votre véhicule (valeur 15 000 €). L''assurance vous rembourse 12 000 €. La VNC (valeur nette comptable) au moment du sinistre était de 9 000 €. Le résultat de cession est :',
   '[{"id":"a","label":"Plus-value de 3 000 €","is_correct":true},
     {"id":"b","label":"Moins-value de 3 000 €","is_correct":false},
     {"id":"c","label":"Plus-value de 6 000 €","is_correct":false},
     {"id":"d","label":"Aucune plus-value","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-d','financier','cas-pratique'],
   'mft-original-2026-eb:40', true,
   'Résultat de cession = Prix de cession (12 000) – VNC (9 000) = +3 000 € de plus-value imposable.'),

  -- ──── 10. QR — examens approfondis (10 questions) ─────────────────
  (formation_uuid, 'qr',
   'Karim crée son entreprise de coursier-livraison. Il prévoit un démarrage avec 1 véhicule utilitaire (PTAC 3,2 T), pas de salarié, et 5 clients récurrents.

a. Quelle forme juridique recommandez-vous, et pourquoi ?
b. Quelle capacité (financière, professionnelle) doit-il justifier ?
c. Quels documents administratifs doit-il obtenir avant de démarrer ?
d. Listez 3 risques principaux à anticiper.',
   NULL, 5, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-a','module-c','droit','reglementation','mise-en-situation','qr'],
   'mft-original-2026-eb:41', true,
   NULL),

  (formation_uuid, 'qr',
   'Votre entreprise a 3 ans d''ancienneté. Vous identifiez 50 % de vos courses générées par 1 seul client (40 % du CA). Ce client demande une remise de 10 %.

a. Quels sont les risques de cette dépendance ?
b. Comment gérer commercialement cette demande de remise ?
c. Quelles pistes de diversification mettre en œuvre dans les 6 prochains mois ?
d. Comment formaliser une nouvelle convention pour mieux vous protéger juridiquement ?',
   NULL, 5, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-b','commercial','cas-pratique','mise-en-situation','qr'],
   'mft-original-2026-eb:42', true,
   NULL),

  (formation_uuid, 'qr',
   'Un de vos chauffeurs vient d''avoir un accident matériel sans tiers identifié sur l''autoroute. Pas de blessé, mais véhicule à remorquer.

a. Quels documents le chauffeur doit-il remplir ?
b. Quelles déclarations devez-vous faire (qui, quand) ?
c. Quel impact comptable et financier (immobilisations, primes, franchises) ?
d. Quelles actions préventives mettre en place pour l''avenir ?',
   NULL, 5, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-d','module-e','module-f','financier','salaries','securite','cas-pratique','qr'],
   'mft-original-2026-eb:43', true,
   NULL),

  (formation_uuid, 'qr',
   'Un client refuse de payer une facture de 4 800 € à échéance, prétextant un retard de livraison. Le retard est de 1 jour, prouvé non imputable au transporteur (intempéries).

a. Que prévoit le contrat type général sur le retard ?
b. Quelles démarches amiables engager dans l''ordre ?
c. Si l''amiable échoue, quelle procédure judiciaire choisir et pourquoi ?
d. Quels coûts et délais anticiper ?',
   NULL, 5, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-b','module-c','commercial','reglementation','recouvrement','qr'],
   'mft-original-2026-eb:44', true,
   NULL),

  (formation_uuid, 'qr',
   'Vous envisagez d''acheter un nouveau véhicule de 32 000 € HT. Vos ressources : 10 000 € de trésorerie, capacité de remboursement de 600 €/mois.

a. Quelles sont les 3 principales options de financement et leurs caractéristiques ?
b. Quelle est la solution la plus adaptée à votre situation ?
c. Quels indicateurs financiers (DSCR, capacité d''emprunt) regarder ?
d. Quelles garanties la banque pourrait-elle demander ?',
   NULL, 5, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-d','financier','financement','cas-pratique','qr'],
   'mft-original-2026-eb:45', true,
   NULL),

  (formation_uuid, 'qr',
   'Un de vos chauffeurs (CDI 35h, 5 ans d''ancienneté) souffre de mal de dos chronique. Le médecin du travail le déclare inapte à la conduite.

a. Quelles obligations avez-vous en tant qu''employeur ?
b. Quelle procédure de reclassement engager ?
c. Si reclassement impossible, quelle sortie envisager (motifs, indemnités) ?
d. Comment prévenir ce type de situation à l''avenir ?',
   NULL, 5, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-e','module-f','salaries','securite','medecine-travail','qr'],
   'mft-original-2026-eb:46', true,
   NULL),

  (formation_uuid, 'qr',
   'Un nouveau client e-commerçant vous propose 200 livraisons/jour à 8 € HT chacune. Coût de revient km : 0,75 €. Distance moyenne par livraison : 6 km.

a. Calculez le chiffre d''affaires journalier prévisionnel.
b. Calculez le coût de revient journalier.
c. Calculez la marge nette journalière puis mensuelle (22 jours).
d. Cette opportunité est-elle rentable ? Quels risques peuvent l''affecter ?',
   NULL, 5, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-b','module-d','commercial','financier','cas-pratique','qr'],
   'mft-original-2026-eb:47', true,
   NULL),

  (formation_uuid, 'qr',
   'Vous embauchez un chauffeur par CDD de 6 mois pour faire face à un surcroît d''activité saisonnier. Au bout de 4 mois, vous souhaitez le titulariser en CDI.

a. Quelles sont les conditions et règles à respecter ?
b. La période d''essai du CDI peut-elle être imposée ? Pourquoi ?
c. Quelles obligations administratives (DPAE, contrat, registre) ?
d. Quels avantages financiers/sociaux pour l''entreprise et le salarié ?',
   NULL, 5, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-e','salaries','cdi-cdd','qr'],
   'mft-original-2026-eb:48', true,
   NULL),

  (formation_uuid, 'qr',
   'Un contrôle DREAL inopiné dans votre entreprise révèle :
- 1 véhicule sans copie conforme de licence
- 1 chauffeur sans carte conducteur
- Mauvais arrimage sur 1 véhicule

a. Citez les sanctions encourues pour chaque infraction.
b. Quel impact sur votre honorabilité et la pérennité de votre licence ?
c. Quelles actions correctives immédiates engager ?
d. Comment renforcer vos procédures internes pour éviter une récidive ?',
   NULL, 5, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-c','module-f','reglementation','controle','securite','mise-en-situation','qr'],
   'mft-original-2026-eb:49', true,
   NULL),

  (formation_uuid, 'qr',
   'Vous souhaitez développer votre entreprise sur les 3 prochaines années :
de 1 à 5 véhicules, de 0 à 4 salariés.

a. Quels sont les 3 indicateurs de gestion à suivre mensuellement ?
b. Quelle stratégie financière (autofinancement, leasing, emprunt) ?
c. Quel impact sur la capacité financière exigée ?
d. Quelles exigences nouvelles en matière de DUERP, DPGF, AT-MP ?
e. Quelles formations obligatoires/recommandées pour vos futurs salariés ?',
   NULL, 5, 'difficile',
   ARRAY['capa-3-5t','examen-blanc','module-d','module-e','module-f','financier','salaries','securite','strategie','synthese','qr'],
   'mft-original-2026-eb:50', true,
   NULL)
  ON CONFLICT (source_ref) DO NOTHING;

  RAISE NOTICE 'Banque examen blanc Capa : 50 questions insérées (40 QCM + 10 QR).';
END
$eb_capa$;
