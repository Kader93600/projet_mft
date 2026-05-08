-- ============================================================================
-- GOTRM — Chapitre 17 : L'anglais professionnel en transport
-- Source : LIVRET_PRO_CCP1_GOTRM V2.pdf — pages 65 à 67
-- Idempotent : DELETE puis INSERT
-- ============================================================================

DO $ch17_v4$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid; v_lesson uuid; v_quiz uuid;
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

  -- Nettoyage idempotent
  DELETE FROM public.modules WHERE slug = 'gotrm-ch17-anglais-pro';
  DELETE FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref LIKE 'mft-2026-gotrm-livret:ch17:%';

  -- Création du module
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Chapitre 17 — L''anglais professionnel en transport',
          'gotrm-ch17-anglais-pro', v_bloc,
          'Maîtriser le vocabulaire B1 transport (shipper, carrier, waybill, POD, ETA, payload, reefer), les formules professionnelles pour passer une commande, informer d''un problème, gérer un litige, et savoir répondre à un client anglophone.',
          'intermediaire', 50, 170)
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 170, true) ON CONFLICT DO NOTHING;

  -- Leçon unique
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (v_module, 'L''anglais professionnel en transport', 'anglais-pro', 1, 50,
$lesson$
# Chapitre 17 — L'anglais professionnel en transport

Le référentiel CCP1 impose une maîtrise de l'anglais au niveau **B1 du CECRL**. En exploitation transport, l'anglais est utilisé pour communiquer avec des conducteurs, des clients ou des sous-traitants étrangers, renseigner les documents CMR et traiter des dossiers internationaux. Ce chapitre présente le vocabulaire et les formules indispensables.

---

## 17.1 — Vocabulaire fondamental

| Français | Anglais | Usage en exploitation |
|---|---|---|
| Expéditeur / Chargeur | Shipper / Consignor | The shipper is responsible for loading. |
| Destinataire | Consignee / Recipient | The consignee refused the delivery. |
| Donneur d'ordres | Principal / Client | The principal requires a quote. |
| Transporteur | Carrier / Haulier | The carrier is liable for the goods. |
| Sous-traitant | Subcontractor | We need a subcontractor for this run. |
| Lettre de voiture / CMR | Waybill / CMR consignment note | Please sign the CMR upon delivery. |
| Bon de livraison signé | POD — Proof of Delivery | Send the signed POD back to us. |
| Ordre de mission | Job sheet / Work order | The driver has received his job sheet. |
| Panne | Breakdown | The vehicle has broken down on the motorway. |
| Retard | Delay | There is a 2-hour delay due to traffic. |
| Avarie | Damage / Goods damage | The goods arrived with visible damage. |
| Manquant | Shortage / Missing items | Two pallets are missing. |
| Fret de retour | Back load / Return load | Can you find a back load from Bordeaux? |
| Charge utile | Payload / Load capacity | The maximum payload is 24,000 kg. |
| Véhicule frigorifique | Refrigerated truck / Reefer | We need a reefer for this shipment. |

---

## 17.2 — Formules de communication professionnelle

### Passer une commande ou confirmer une prestation

> **ENGLISH CORNER**
>
> - We would like to book a transport from [city] to [city] on [date].
> - Could you confirm the collection date and time?
> - Please find attached the booking confirmation.
> - We confirm the shipment of [X] pallets, total weight [X] kg.
> - The delivery is scheduled for [date] between [time] and [time].

### Informer d'un problème ou d'un aléa

> **ENGLISH CORNER**
>
> - I am writing to inform you that there is a delay on your shipment.
> - Unfortunately, the driver has experienced a breakdown near [location].
> - Due to heavy traffic, the estimated arrival time is now [time].
> - We are doing our best to resolve the situation as quickly as possible.
> - We will keep you updated on the progress of the shipment.
> - We apologize for the inconvenience caused.

### Gérer un litige ou des réserves

> **ENGLISH CORNER**
>
> - The consignee has noted reservations on the delivery note.
> - The goods arrived with visible damage — please see attached photos.
> - We kindly ask you to confirm the damage by registered letter.
> - We will investigate the matter and come back to you within 48 hours.

---

## 17.3 — Cas pratique

> **CAS PRATIQUE — REPONDRE A UN CLIENT ANGLOPHONE**
>
> A British client (LONDON TRADE Ltd) requests a quote by email :
>
> *"We need to ship 10 Euro pallets, 2,800 kg total, from Paris to Birmingham, collection next Monday."*

### MODEL ANSWER

**Subject:** Quote — Paris to Birmingham — 10 Euro pallets

Dear Sir/Madam,

Thank you for your enquiry. Please find below our offer for your shipment :

- **Origin:** Paris, France — **Destination:** Birmingham, United Kingdom
- **Quantity:** 10 Euro pallets — **Total weight:** 2,800 kg
- **Collection:** Monday [date] — **Estimated delivery:** Tuesday/Wednesday [date]
- **Price:** [X] € HT (VAT exempt — international transport)

Please note that customs formalities apply for UK shipments. We will require a commercial invoice and packing list from the shipper.

Please confirm your booking at your earliest convenience.

Kind regards,
[Name] — Transport Operations

---

## 17.4 — Vocabulaire essentiel

| Terme anglais | Traduction française |
|---|---|
| Carrier | Transporteur |
| Consignee | Destinataire |
| Consignor / Shipper | Expéditeur |
| Freight | Fret / marchandise / prix de transport |
| Haulier | Transporteur routier |
| POD (Proof of Delivery) | Bon de livraison signé par le destinataire |
| ETA (Estimated Time of Arrival) | Heure d'arrivée estimée |
| Breakdown | Panne mécanique |
| Claim | Réclamation / dossier litige |
| Shortage | Manquant |
| Reefer | Véhicule frigorifique |
| Back load | Fret de retour |
| Payload | Charge utile |
| Waybill | Lettre de voiture |

---

**À retenir :** le niveau B1 attendu suppose la capacité de **comprendre un email client**, de **rédiger une réponse claire** (devis, confirmation, information d'aléa) et d'utiliser correctement le **lexique CMR / POD / ETA / payload / reefer** dans un contexte international.
$lesson$,
'Vocabulaire B1 transport, formules pro, cas pratique bilingue.')
  RETURNING id INTO v_lesson;

  -- ==========================================================================
  -- BANQUE DE QUESTIONS — 10 QCM + 3 QR
  -- ==========================================================================
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES

  -- QCM 1 — facile
  (v_formation, v_module, 'qcm',
   'Comment dit-on « expéditeur / chargeur » en anglais professionnel ?',
   '[{"id":"a","label":"Consignee","is_correct":false},{"id":"b","label":"Shipper / Consignor","is_correct":true},{"id":"c","label":"Carrier","is_correct":false},{"id":"d","label":"Principal","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch17','livret','vocabulaire'],
   'mft-2026-gotrm-livret:ch17:qcm:1', true,
   'L''expéditeur (chargeur) se traduit par Shipper ou Consignor. Le Consignee est le destinataire et le Carrier le transporteur.'),

  -- QCM 2 — facile
  (v_formation, v_module, 'qcm',
   'Que signifie l''acronyme POD en transport international ?',
   '[{"id":"a","label":"Point of Departure","is_correct":false},{"id":"b","label":"Proof of Delivery","is_correct":true},{"id":"c","label":"Place of Destination","is_correct":false},{"id":"d","label":"Pallet on Demand","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch17','livret','acronymes'],
   'mft-2026-gotrm-livret:ch17:qcm:2', true,
   'POD = Proof of Delivery = bon de livraison signé par le destinataire. À renvoyer au donneur d''ordres après livraison.'),

  -- QCM 3 — facile
  (v_formation, v_module, 'qcm',
   'Comment traduit-on « véhicule frigorifique » en anglais ?',
   '[{"id":"a","label":"Tipper","is_correct":false},{"id":"b","label":"Reefer / Refrigerated truck","is_correct":true},{"id":"c","label":"Tanker","is_correct":false},{"id":"d","label":"Curtain-sider","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch17','livret','vocabulaire'],
   'mft-2026-gotrm-livret:ch17:qcm:3', true,
   'Reefer (abréviation courante) ou Refrigerated truck désigne un véhicule frigorifique en anglais professionnel.'),

  -- QCM 4 — facile
  (v_formation, v_module, 'qcm',
   'Que signifie ETA dans un échange transport ?',
   '[{"id":"a","label":"Estimated Time of Arrival","is_correct":true},{"id":"b","label":"European Transport Authority","is_correct":false},{"id":"c","label":"Express Tracking Alert","is_correct":false},{"id":"d","label":"Estimated Transit Allowance","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch17','livret','acronymes'],
   'mft-2026-gotrm-livret:ch17:qcm:4', true,
   'ETA = Estimated Time of Arrival = heure d''arrivée estimée. Donnée clé pour informer le destinataire d''un retard ou de l''avancement.'),

  -- QCM 5 — moyen
  (v_formation, v_module, 'qcm',
   'Vous voulez écrire « Il y a un retard de 2 heures dû à la circulation ». Quelle phrase est correcte ?',
   '[{"id":"a","label":"There is a 2-hour delay due to traffic.","is_correct":true},{"id":"b","label":"There has a delay of 2 hours by traffic.","is_correct":false},{"id":"c","label":"It is delaying 2 hours for the traffic.","is_correct":false},{"id":"d","label":"The traffic does a delay of 2 hours.","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch17','livret','formules'],
   'mft-2026-gotrm-livret:ch17:qcm:5', true,
   'Formule professionnelle de référence : "There is a 2-hour delay due to traffic." (cf. ENGLISH CORNER aléa).'),

  -- QCM 6 — moyen
  (v_formation, v_module, 'qcm',
   'Comment traduit-on « charge utile » en anglais transport ?',
   '[{"id":"a","label":"Total weight","is_correct":false},{"id":"b","label":"Gross vehicle mass","is_correct":false},{"id":"c","label":"Payload / Load capacity","is_correct":true},{"id":"d","label":"Tare weight","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch17','livret','vocabulaire'],
   'mft-2026-gotrm-livret:ch17:qcm:6', true,
   'Payload (ou Load capacity) désigne la charge utile, soit la masse maximale de marchandises transportable. Exemple : "The maximum payload is 24,000 kg."'),

  -- QCM 7 — moyen
  (v_formation, v_module, 'qcm',
   'Vous informez un client d''un manquant à la livraison. Quelle phrase utiliser ?',
   '[{"id":"a","label":"Two pallets are missing.","is_correct":true},{"id":"b","label":"Two pallets are breaking down.","is_correct":false},{"id":"c","label":"Two pallets are damaging.","is_correct":false},{"id":"d","label":"Two pallets are delaying.","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch17','livret','litige'],
   'mft-2026-gotrm-livret:ch17:qcm:7', true,
   'Shortage / Missing items = manquant. La phrase de référence est "Two pallets are missing." pour signaler un manquant.'),

  -- QCM 8 — moyen
  (v_formation, v_module, 'qcm',
   'Quel est le niveau d''anglais minimum exigé par le référentiel CCP1 GOTRM ?',
   '[{"id":"a","label":"A2 du CECRL","is_correct":false},{"id":"b","label":"B1 du CECRL","is_correct":true},{"id":"c","label":"B2 du CECRL","is_correct":false},{"id":"d","label":"C1 du CECRL","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch17','livret','referentiel'],
   'mft-2026-gotrm-livret:ch17:qcm:8', true,
   'Le référentiel CCP1 impose une maîtrise de l''anglais au niveau B1 du CECRL : comprendre un email client et rédiger une réponse pro.'),

  -- QCM 9 — difficile
  (v_formation, v_module, 'qcm',
   'Pour un transport Paris → Birmingham (UK), quelle mention TVA est correcte sur le devis ?',
   '[{"id":"a","label":"VAT 20% included","is_correct":false},{"id":"b","label":"VAT 5.5% domestic","is_correct":false},{"id":"c","label":"VAT exempt — international transport","is_correct":true},{"id":"d","label":"VAT to be confirmed by customs","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch17','livret','cas-pratique'],
   'mft-2026-gotrm-livret:ch17:qcm:9', true,
   'Pour un transport international (hors UE depuis Brexit pour le UK), la TVA française ne s''applique pas. Mention : "VAT exempt — international transport" (cf. model answer LONDON TRADE).'),

  -- QCM 10 — difficile
  (v_formation, v_module, 'qcm',
   'Pour un envoi vers le Royaume-Uni post-Brexit, quels documents le shipper doit-il fournir ?',
   '[{"id":"a","label":"CMR uniquement","is_correct":false},{"id":"b","label":"POD signé en avance","is_correct":false},{"id":"c","label":"Commercial invoice et packing list","is_correct":true},{"id":"d","label":"Carte grise du véhicule","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch17','livret','douane'],
   'mft-2026-gotrm-livret:ch17:qcm:10', true,
   'Le model answer LONDON TRADE le précise : "We will require a commercial invoice and packing list from the shipper." Documents indispensables pour les formalités douanières UK.'),

  -- ==========================================================================
  -- QR — Questions de rédaction (max_score = 5)
  -- ==========================================================================

  -- QR 1
  (v_formation, v_module, 'qr',
   'Rédigez en anglais (3 à 5 phrases) un email pour informer un client britannique que le conducteur a subi une **panne** près de Lille et que l''ETA est désormais 18h00 au lieu de 14h00. Utilisez le vocabulaire professionnel du chapitre.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch17','livret','redaction'],
   'mft-2026-gotrm-livret:ch17:qr:1', true,
   'Réponse type : "Dear Sir/Madam, I am writing to inform you that there is a delay on your shipment. Unfortunately, the driver has experienced a breakdown near Lille. The estimated time of arrival (ETA) is now 6:00 PM instead of 2:00 PM. We are doing our best to resolve the situation as quickly as possible. We apologize for the inconvenience caused. Kind regards." — vocabulaire attendu : breakdown, delay, ETA.'),

  -- QR 2
  (v_formation, v_module, 'qr',
   'Rédigez en anglais une **réponse de devis** (5 à 8 lignes) pour un client demandant le transport de 6 palettes Europe (1,500 kg) de Lyon à Manchester, collecte vendredi prochain. Mentionnez l''origine, la destination, la quantité, le poids, la collecte, l''ETA, le prix et la TVA.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch17','livret','redaction','cas-pratique'],
   'mft-2026-gotrm-livret:ch17:qr:2', true,
   'Réponse type : "Subject: Quote — Lyon to Manchester — 6 Euro pallets. Dear Sir/Madam, Thank you for your enquiry. Please find below our offer: Origin: Lyon, France — Destination: Manchester, United Kingdom; Quantity: 6 Euro pallets — Total weight: 1,500 kg; Collection: Friday [date]; Estimated delivery: Monday [date]; Price: [X] € HT (VAT exempt — international transport). Customs formalities apply: please provide a commercial invoice and packing list. Please confirm your booking at your earliest convenience. Kind regards." — structure attendue : objet + offre détaillée + mention douane + closing.'),

  -- QR 3
  (v_formation, v_module, 'qr',
   'Rédigez en anglais (4 à 6 phrases) un message à un client expliquant que **2 palettes sont arrivées endommagées** (avarie), avec photos en pièce jointe, et demandant la confirmation du litige par lettre recommandée.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch17','livret','redaction','litige'],
   'mft-2026-gotrm-livret:ch17:qr:3', true,
   'Réponse type : "Dear Sir/Madam, I am writing to inform you that the consignee has noted reservations on the delivery note. Two pallets arrived with visible damage — please see attached photos. We kindly ask you to confirm the damage by registered letter. We will investigate the matter and come back to you within 48 hours. Kind regards." — vocabulaire attendu : reservations, damage, registered letter.');

  -- ==========================================================================
  -- QUIZ d'entraînement (10 QCM uniquement)
  -- ==========================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Chapitre 17 — Quiz d''entraînement',
          'Quiz d''entraînement (10 questions) sur l''anglais professionnel transport.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm-livret:ch17:qcm:%';

  RAISE NOTICE '✓ Module Ch17 importé.';
END $ch17_v4$;
