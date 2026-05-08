-- =====================================================================
-- GOTRM — Chapitre 16 : Gestion des supports de charge
-- Source : LIVRET_PRO_CCP1_GOTRM V2.pdf (pages 63-64)
-- Idempotent : peut être exécuté plusieurs fois sans erreur.
-- =====================================================================

DO $ch16_v4$
DECLARE
  v_formation uuid;
  v_bloc      int;
  v_module    uuid;
  v_lesson    uuid;
  v_quiz      uuid;
BEGIN
  ------------------------------------------------------------------
  -- 1) Formation GOTRM
  ------------------------------------------------------------------
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable.';
  END IF;

  ------------------------------------------------------------------
  -- 2) Bloc BC1 (créé si absent)
  ------------------------------------------------------------------
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
  IF v_bloc IS NULL THEN
    INSERT INTO public.blocs (code, title, description, "order")
    VALUES ('BC1', 'Bloc 1 — Compétences générales', 'Bloc générique partagé.', 1)
    ON CONFLICT (code) DO NOTHING
    RETURNING id INTO v_bloc;
    IF v_bloc IS NULL THEN
      SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
    END IF;
  END IF;
  IF v_bloc IS NULL THEN
    RAISE EXCEPTION 'Bloc BC1 introuvable.';
  END IF;

  ------------------------------------------------------------------
  -- 3) Nettoyage idempotent
  ------------------------------------------------------------------
  DELETE FROM public.modules WHERE slug = 'gotrm-ch16-supports-charge';
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch16:%';

  ------------------------------------------------------------------
  -- 4) Module
  ------------------------------------------------------------------
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Chapitre 16 — Gestion des supports de charge',
    'gotrm-ch16-supports-charge',
    v_bloc,
    'Maîtriser les types de supports de charge (palettes EUR/ISO consignées, palettes pool CHEP/LPR, roll cages), les systèmes d''échange et de gestion, et le suivi des stocks par client.',
    'intermediaire',
    45,
    160
  )
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 160, true)
  ON CONFLICT DO NOTHING;

  ------------------------------------------------------------------
  -- 5) Leçon
  ------------------------------------------------------------------
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module,
    'Gestion des supports de charge',
    'supports-charge',
    1,
    45,
$lesson$
# Chapitre 16 — Gestion des supports de charge

Les supports de charge — palettes, rolls, caisses palettes — ont une valeur économique et font l'objet d'un suivi rigoureux. Une mauvaise gestion des palettes peut générer des litiges et des pertes financières significatives pour l'entreprise.

---

## 16.1 — Les types de supports et leur statut

| Support | Statut | Gestion | Valeur indicative |
|---|---|---|---|
| Palette EUR (EPAL) | Consignée ou échangeable | Échange 1 pour 1 à la livraison | 8 à 12 € |
| Palette ISO | Consignée ou à usage unique | Retour ou destruction selon accord | 10 à 15 € |
| Palette pool (CHEP, LPR…) | Louée — propriété du prestataire | Restitution au réseau pool | 0,15 à 0,25 €/jour |
| Roll cage / Roll | Consigné — propriété du distributeur | Retour obligatoire | 25 à 50 € |

---

## 16.2 — Les systèmes de gestion des palettes

### L'échange de palettes

Lors d'une livraison, le conducteur remet des palettes pleines et récupère un nombre identique de palettes vides en échange. Si le destinataire ne peut pas remettre de palettes vides immédiatement, le conducteur émet un bon de décharge signé. Le gestionnaire suit cette dette et la régularise lors d'un prochain passage.

### Le système pool

Dans le système pool (CHEP — palettes bleues, LPR — palettes rouges), les palettes appartiennent à un prestataire spécialisé. Les utilisateurs les louent, les utilisent, puis les restituent dans n'importe quel dépôt du réseau. Le gestionnaire transmet un bordereau de transfert au prestataire pour chaque mouvement.

---

## 16.3 — Le suivi des stocks de supports de charge

### MÉTHODE — Procédure à chaque livraison

1. Le conducteur note sur le BL : palettes livrées + palettes récupérées.
2. Si échange impossible : émettre un bon de décharge signé par le destinataire.
3. Le gestionnaire enregistre dans le TMS : solde palettes par client.
4. Suivi mensuel : balancer les comptes palettes par client.
5. En cas de dette persistante : relancer le client par écrit.
6. Pour palettes pool : transmettre le bordereau de transfert au prestataire.

### À RETENIR

- **Solde positif** = le client DOIT des palettes à l'entreprise.
- **Solde négatif** = l'entreprise DOIT des palettes au client (avoir à régulariser).
- Les palettes non récupérées représentent un coût réel : elles doivent être facturées si le client ne régularise pas.
- La clause de facturation des palettes non restituées doit figurer dans les CGV de l'entreprise.

---

## 16.4 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| Support de charge | Dispositif permettant le groupage et la manutention des marchandises |
| Palette consignée | Palette appartenant à l'expéditeur, remise contre restitution |
| Palette pool | Palette appartenant à un prestataire (CHEP, LPR…) louée par les utilisateurs |
| Échange de palettes | Remise de palettes pleines contre récupération de palettes vides à la livraison |
| Bon de décharge | Document signé attestant l'impossibilité d'échange immédiat |
| Dette palettes | Solde : le client doit des palettes à l'entreprise |
| CHEP | Prestataire de palettes pool bleues — réseau mondial |
| EPAL | European Pallet Association — certification qualité des palettes EUR |
| Consigne | Valeur monétaire d'un support récupérée à la restitution |
$lesson$,
    'Types supports, échange palettes, système pool, suivi stocks.'
  )
  RETURNING id INTO v_lesson;

  ------------------------------------------------------------------
  -- 6) Banque de questions — 8 QCM + 3 QR
  ------------------------------------------------------------------
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES
  -- ============== QCM 1 (facile) ==============
  (v_formation, v_module, 'qcm',
   'Quelle est la valeur indicative d''une palette EUR (EPAL) selon le livret ?',
   '[{"id":"a","label":"4 à 6 €","is_correct":false},
     {"id":"b","label":"8 à 12 €","is_correct":true},
     {"id":"c","label":"15 à 20 €","is_correct":false},
     {"id":"d","label":"25 à 50 €","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch16','livret','palette-eur'],
   'mft-2026-gotrm-livret:ch16:qcm:1', true,
   'La palette EUR (EPAL) a une valeur indicative de 8 à 12 €. Elle est consignée ou échangeable, avec échange 1 pour 1 à la livraison.'),

  -- ============== QCM 2 (facile) ==============
  (v_formation, v_module, 'qcm',
   'Quel est le statut d''une palette pool (CHEP, LPR) ?',
   '[{"id":"a","label":"Consignée — propriété de l''expéditeur","is_correct":false},
     {"id":"b","label":"Louée — propriété du prestataire","is_correct":true},
     {"id":"c","label":"À usage unique — propriété du transporteur","is_correct":false},
     {"id":"d","label":"Échangeable — propriété du destinataire","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch16','livret','pool'],
   'mft-2026-gotrm-livret:ch16:qcm:2', true,
   'Les palettes pool (CHEP — bleues, LPR — rouges) sont louées : elles restent la propriété du prestataire spécialisé. Les utilisateurs les louent, les utilisent puis les restituent dans n''importe quel dépôt du réseau.'),

  -- ============== QCM 3 (facile) ==============
  (v_formation, v_module, 'qcm',
   'Que signifie un solde positif sur le compte palettes d''un client ?',
   '[{"id":"a","label":"L''entreprise doit des palettes au client","is_correct":false},
     {"id":"b","label":"Le client doit des palettes à l''entreprise","is_correct":true},
     {"id":"c","label":"Les comptes sont équilibrés","is_correct":false},
     {"id":"d","label":"Le client a payé sa consigne","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch16','livret','solde'],
   'mft-2026-gotrm-livret:ch16:qcm:3', true,
   'Solde positif = le client DOIT des palettes à l''entreprise. À l''inverse, solde négatif = l''entreprise doit des palettes au client (avoir à régulariser).'),

  -- ============== QCM 4 (moyen) ==============
  (v_formation, v_module, 'qcm',
   'Quel document doit émettre le conducteur lorsque l''échange de palettes est impossible à la livraison ?',
   '[{"id":"a","label":"Une lettre de voiture","is_correct":false},
     {"id":"b","label":"Un bon de décharge signé par le destinataire","is_correct":true},
     {"id":"c","label":"Un bordereau de transfert au prestataire","is_correct":false},
     {"id":"d","label":"Une facture de consigne","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch16','livret','bon-decharge'],
   'mft-2026-gotrm-livret:ch16:qcm:4', true,
   'Si le destinataire ne peut pas remettre de palettes vides immédiatement, le conducteur émet un bon de décharge signé. Le gestionnaire suit cette dette et la régularise lors d''un prochain passage.'),

  -- ============== QCM 5 (moyen) ==============
  (v_formation, v_module, 'qcm',
   'Quelle est la valeur indicative journalière d''une palette pool ?',
   '[{"id":"a","label":"0,05 à 0,10 €/jour","is_correct":false},
     {"id":"b","label":"0,15 à 0,25 €/jour","is_correct":true},
     {"id":"c","label":"0,50 à 1,00 €/jour","is_correct":false},
     {"id":"d","label":"1,00 à 2,00 €/jour","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch16','livret','pool','tarif'],
   'mft-2026-gotrm-livret:ch16:qcm:5', true,
   'Une palette pool (CHEP, LPR…) est facturée 0,15 à 0,25 €/jour. Elle reste la propriété du prestataire et est restituée au réseau pool.'),

  -- ============== QCM 6 (moyen) ==============
  (v_formation, v_module, 'qcm',
   'Pour les palettes pool, quel document le gestionnaire transmet-il au prestataire pour chaque mouvement ?',
   '[{"id":"a","label":"Un bon de décharge","is_correct":false},
     {"id":"b","label":"Un bordereau de transfert","is_correct":true},
     {"id":"c","label":"Un avoir de régularisation","is_correct":false},
     {"id":"d","label":"Une lettre de voiture CMR","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch16','livret','pool','bordereau'],
   'mft-2026-gotrm-livret:ch16:qcm:6', true,
   'Dans le système pool, le gestionnaire transmet un bordereau de transfert au prestataire (CHEP, LPR…) pour chaque mouvement de palettes.'),

  -- ============== QCM 7 (difficile) ==============
  (v_formation, v_module, 'qcm',
   'Selon la procédure du livret, à quelle étape le conducteur intervient-il en cas d''impossibilité d''échange ?',
   '[{"id":"a","label":"Étape 1 — note sur le BL","is_correct":false},
     {"id":"b","label":"Étape 2 — émission d''un bon de décharge signé","is_correct":true},
     {"id":"c","label":"Étape 4 — suivi mensuel","is_correct":false},
     {"id":"d","label":"Étape 5 — relance écrite","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch16','livret','procedure'],
   'mft-2026-gotrm-livret:ch16:qcm:7', true,
   'La procédure à chaque livraison comporte 6 étapes. L''étape 2 consiste, en cas d''échange impossible, à émettre un bon de décharge signé par le destinataire. Les étapes 3 à 6 (enregistrement TMS, suivi mensuel, relance, bordereau pool) relèvent du gestionnaire.'),

  -- ============== QCM 8 (difficile) ==============
  (v_formation, v_module, 'qcm',
   'Où doit obligatoirement figurer la clause de facturation des palettes non restituées ?',
   '[{"id":"a","label":"Sur le bon de livraison uniquement","is_correct":false},
     {"id":"b","label":"Dans les CGV de l''entreprise","is_correct":true},
     {"id":"c","label":"Sur le bordereau de transfert pool","is_correct":false},
     {"id":"d","label":"Dans la lettre de voiture CMR","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch16','livret','cgv','facturation'],
   'mft-2026-gotrm-livret:ch16:qcm:8', true,
   'Les palettes non récupérées représentent un coût réel : elles doivent être facturées si le client ne régularise pas. La clause de facturation des palettes non restituées doit figurer dans les CGV de l''entreprise pour être opposable.'),

  -- ============== QR 1 ==============
  (v_formation, v_module, 'qr',
   'Citez les 4 types de supports de charge présentés dans le livret avec leur valeur indicative.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch16','livret','qr','supports'],
   'mft-2026-gotrm-livret:ch16:qr:1', true,
   'Les 4 supports : (1) Palette EUR/EPAL — consignée ou échangeable — 8 à 12 € ; (2) Palette ISO — consignée ou à usage unique — 10 à 15 € ; (3) Palette pool (CHEP, LPR…) — louée — 0,15 à 0,25 €/jour ; (4) Roll cage / Roll — consigné — 25 à 50 €.'),

  -- ============== QR 2 ==============
  (v_formation, v_module, 'qr',
   'Décrivez la différence entre le système d''échange de palettes et le système pool.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch16','livret','qr','systemes'],
   'mft-2026-gotrm-livret:ch16:qr:2', true,
   'Échange de palettes : à la livraison, le conducteur remet des palettes pleines et récupère un nombre identique de palettes vides ; si l''échange est impossible, un bon de décharge signé est émis et la dette est régularisée plus tard. Système pool (CHEP — bleues, LPR — rouges) : les palettes appartiennent à un prestataire spécialisé qui les loue ; les utilisateurs les restituent dans n''importe quel dépôt du réseau, et un bordereau de transfert est transmis au prestataire pour chaque mouvement.'),

  -- ============== QR 3 ==============
  (v_formation, v_module, 'qr',
   'Énumérez les 6 étapes de la procédure de suivi des supports de charge à chaque livraison.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch16','livret','qr','procedure'],
   'mft-2026-gotrm-livret:ch16:qr:3', true,
   'Procédure à chaque livraison : (1) le conducteur note sur le BL les palettes livrées + palettes récupérées ; (2) si échange impossible, émettre un bon de décharge signé par le destinataire ; (3) le gestionnaire enregistre dans le TMS le solde palettes par client ; (4) suivi mensuel : balancer les comptes palettes par client ; (5) en cas de dette persistante : relancer le client par écrit ; (6) pour palettes pool : transmettre le bordereau de transfert au prestataire.');

  ------------------------------------------------------------------
  -- 7) Quiz d'entraînement (8 QCM uniquement)
  ------------------------------------------------------------------
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Chapitre 16 — Quiz d''entraînement',
    'Quiz d''entraînement (8 questions) sur la gestion des supports de charge.',
    'entrainement',
    NULL,
    70
  )
  RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch16:qcm:%';

  RAISE NOTICE '✓ Module Ch16 (Gestion des supports de charge) importé avec succès.';
END $ch16_v4$;
