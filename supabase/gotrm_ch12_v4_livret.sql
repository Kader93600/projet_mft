-- =====================================================================
-- GOTRM — Chapitre 12 : Facturation, litiges et clôture des dossiers
-- Source : LIVRET_PRO_CCP1_GOTRM V2.pdf — pages 47 à 50
-- Idempotent — réimport sûr
-- =====================================================================

DO $ch12_v4$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson uuid;
  v_quiz uuid;
BEGIN
  -- Formation gotrm
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable.';
  END IF;

  -- Bloc BC1
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

  -- Nettoyage idempotent
  DELETE FROM public.modules WHERE slug = 'gotrm-ch12-facturation-litiges-cloture';
  DELETE FROM public.question_bank
    WHERE formation_id = v_formation
      AND source_ref LIKE 'mft-2026-gotrm-livret:ch12:%';

  -- Module
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Chapitre 12 — Facturation, litiges et clôture des dossiers',
    'gotrm-ch12-facturation-litiges-cloture',
    v_bloc,
    'Maîtriser la procédure de clôture d''un dossier transport, les mentions obligatoires d''une facture (CGI, LME), les types de litiges et les plafonds d''indemnisation des contrats types.',
    'avance',
    70,
    120
  )
  RETURNING id INTO v_module;

  -- Lien formation_modules
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 120, true)
  ON CONFLICT DO NOTHING;

  -- Leçon unique
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module,
    'Facturation, litiges et clôture des dossiers',
    'facturation-litiges',
    1,
    70,
$lesson$
# Chapitre 12 — Facturation, litiges et clôture des dossiers

La clôture d'un dossier de transport est la dernière étape du cycle d'exploitation. Elle couvre la vérification des documents retournés, la facturation de la prestation et le traitement des éventuels litiges. Ces tâches conditionnent directement la rentabilité de l'entreprise.

---

## 12.1 — La procédure de clôture d'un dossier

**MÉTHODE — 5 étapes**

**ÉTAPE 1 : Vérifier le retour des documents signés**
- Lettre de voiture / CMR signée par le destinataire (preuve de livraison)
- Bon de livraison signé, relevés de températures si transport frigorifique

**ÉTAPE 2 : Contrôler la conformité de l'opération**
- Livraison complète, dans les délais ? Réserves ou anomalies constatées ?

**ÉTAPE 3 : Renseigner le TMS**
- Statut final (livré / litige / avarie…), heures réelles, anomalies

**ÉTAPE 4 : Déclencher la facturation**
- Toutes les prestations facturables (transport + annexes + pied de facture)

**ÉTAPE 5 : Archiver le dossier**
- Durée de conservation minimale : **5 ans** (prescription commerciale)

---

## 12.2 — Les mentions obligatoires d'une facture de transport

| Mention | Contenu | Base légale |
|---|---|---|
| Numéro de facture | Numéro unique et séquentiel | CGI art. 289 |
| Date d'émission | Date de création de la facture | CGI art. 289 |
| Identité du vendeur | Raison sociale, adresse, SIRET, n° TVA intracommunautaire | CGI art. 289 |
| Identité de l'acheteur | Raison sociale et adresse du client facturé | CGI art. 289 |
| Description de la prestation | Nature, trajet, date, véhicule, références marchandise | Code des transports |
| Prix HT détaillé | Prix de chaque prestation individuellement | CGI art. 289 |
| Taux et montant de TVA | 20 % national / 0 % international | CGI art. 262 |
| Total TTC | Prix HT + TVA | CGI art. 289 |
| Conditions et délais de paiement | Délai, mode, pénalités de retard, indemnité forfaitaire 40 € | LME art. L441-6 |

> **REGLEMENTATION**
>
> **TVA en transport routier :**
> - Transport national (France) : TVA 20 % sur la facture finale.
> - Transport international : EXONÉRÉ de TVA — règle de territorialité (CGI art. 262).
>   Mention obligatoire sur la facture : « Exonération TVA — Article 262 CGI ».
>
> **Délais de paiement (Loi de Modernisation de l'Économie) :**
> - Délai légal maximum : 30 jours à compter de la date d'émission de la facture.
> - Par accord contractuel : jusqu'à 60 jours date de facture ou 45 jours fin de mois.
> - En cas de dépassement : pénalités de retard (taux BCE + 10 points) + indemnité forfaitaire 40 €.

---

## 12.3 — Les types de litiges transport

| Type de litige | Description | Délai de réserves |
|---|---|---|
| Avarie caractérisée | Dommage visible au déchargement (casse, mouille, déformation) | Immédiat + confirmation LRAR 3 jours francs |
| Avarie occulte | Dommage invisible à la livraison, découvert au déballage | LRAR dans les 3 jours francs suivant la découverte |
| Manquant total ou partiel | Colis présent sur le document mais absent à la livraison | Immédiat + confirmation LRAR 3 jours francs |
| Retard | Non-respect du délai contractuel de livraison | Après mise en demeure restée sans réponse |

> **REGLEMENTATION**
>
> **FORCLUSION** : les réserves non confirmées par LRAR dans les 3 jours francs = perte du droit d'agir en justice.
> Pour les particuliers (consommateurs) : 10 jours.
> Le silence du conducteur lors des réserves vaut ACCEPTATION.
>
> **Causes d'exonération du transporteur (aucune indemnisation possible) :**
> - Vice propre de la marchandise (défaut inhérent à la marchandise elle-même)
> - Défaut d'emballage signalé par des réserves au chargement
> - Faute de l'expéditeur ou du destinataire
> - Cas de force majeure (événement imprévisible, irrésistible et extérieur)

---

## 12.4 — Les plafonds d'indemnisation

| Contrat type | Base | Envoi < 3 tonnes | Envoi ≥ 3 tonnes |
|---|---|---|---|
| Contrat type général | Par kg manquant ou avarié | 33 €/kg | 20 €/kg |
| Contrat type général | Par colis perdu ou avarié | 1 000 €/colis | — |
| Contrat type général | Par tonne d'envoi | — | 3 200 €/tonne |
| Contrat type température dirigée | Par kg | 23 €/kg | 14 €/kg |
| Contrat type température dirigée | Par colis | 750 €/colis | — |
| Contrat type température dirigée | Par tonne | — | 4 000 €/tonne |

> **À RETENIR**
>
> Le plafond retenu est **TOUJOURS le plus petit** des deux calculs applicables.
> En cas de retard : plafond d'indemnisation = montant du prix du transport.
> Les plafonds NE s'appliquent PAS en cas de : dol (faute intentionnelle grave), faute lourde inexcusable, ou déclaration de valeur souscrite avant le transport.

> **CAS PRATIQUE — CALCUL D'INDEMNISATION — AVARIE 3 COLIS**
>
> **Avarie** : 3 colis endommagés — **Poids total avarié** : 180 kg
> **Nature** : marchandises générales — **Lot total** : 2,5 tonnes (envoi < 3 t)
> **Contrat type général, envoi < 3 tonnes** :
>
> - **Option 1 (par kg)** : 180 kg × 33 €/kg = **5 940 €**
> - **Option 2 (par colis)** : 3 colis × 1 000 €/colis = **3 000 €**
> - → **Plafond retenu = le PLUS PETIT = 3 000 €**
>
> **MAIS** : l'expéditeur avait souscrit une **déclaration de valeur de 8 000 €** pour les 3 colis.
> → Les plafonds ne s'appliquent plus → **indemnisation jusqu'à la valeur déclarée (8 000 €)**.

---

## 12.5 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| Clôture de dossier | Validation finale après livraison, contrôle documents et déclenchement de la facturation |
| Facture | Document comptable réclamant le paiement d'une prestation réalisée |
| Avoir | Document correctif réduisant ou annulant une facture émise |
| Exonération TVA | Absence de TVA sur les transports internationaux |
| Pied de facture | Révision du prix de transport liée à l'évolution du prix du carburant (CNR) |
| Litige transport | Désaccord entre client et transporteur sur l'exécution du contrat |
| Avarie caractérisée | Dommage visible au déchargement ou lors de la manutention |
| Avarie occulte | Dommage non visible à la livraison — découvert au déballage |
| LRAR | Lettre Recommandée avec Accusé de Réception — confirmation légale des réserves |
| Plafond d'indemnisation | Limite maximale de remboursement prévue par les contrats types |
| Déclaration de valeur | Déclaration préalable supprimant les plafonds légaux d'indemnisation |
| Forclusion | Perte du droit d'agir en justice faute d'avoir respecté les délais |
| Prescription commerciale | Délai de 5 ans au-delà duquel une action en justice n'est plus recevable |
$lesson$,
    'Clôture dossier (5 étapes, archivage 5 ans), 8 mentions facture (CGI 289/262, LME L441-6), 4 types litiges (LRAR 3 jours francs), plafonds indemnisation (33/20 €/kg, 1000 €/colis, 3200 €/tonne) et cas pratique déclaration de valeur.'
  )
  RETURNING id INTO v_lesson;

  -- =====================================================================
  -- BANQUE DE QUESTIONS — 12 QCM + 4 QR
  -- =====================================================================
  INSERT INTO public.question_bank (
    formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation
  ) VALUES

  -- ----- QCM 1 (facile) -----
  (v_formation, v_module, 'qcm',
   'Quelle est la durée minimale d''archivage d''un dossier de transport (prescription commerciale) ?',
   '[{"id":"a","label":"2 ans","is_correct":false},{"id":"b","label":"3 ans","is_correct":false},{"id":"c","label":"5 ans","is_correct":true},{"id":"d","label":"10 ans","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch12','livret','cloture'], 'mft-2026-gotrm-livret:ch12:qcm:1', true,
   'Étape 5 de la clôture : archivage minimum 5 ans (prescription commerciale).'),

  -- ----- QCM 2 (facile) -----
  (v_formation, v_module, 'qcm',
   'Quelle est la 3e étape de la procédure de clôture d''un dossier ?',
   '[{"id":"a","label":"Vérifier le retour des documents signés","is_correct":false},{"id":"b","label":"Renseigner le TMS (statut, heures, anomalies)","is_correct":true},{"id":"c","label":"Déclencher la facturation","is_correct":false},{"id":"d","label":"Archiver le dossier","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch12','livret','cloture'], 'mft-2026-gotrm-livret:ch12:qcm:2', true,
   'Étape 1 : documents signés. Étape 2 : conformité. Étape 3 : TMS. Étape 4 : facturation. Étape 5 : archivage.'),

  -- ----- QCM 3 (facile) -----
  (v_formation, v_module, 'qcm',
   'Quel est le taux de TVA applicable à un transport routier national en France ?',
   '[{"id":"a","label":"0 %","is_correct":false},{"id":"b","label":"5,5 %","is_correct":false},{"id":"c","label":"10 %","is_correct":false},{"id":"d","label":"20 %","is_correct":true}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch12','livret','tva'], 'mft-2026-gotrm-livret:ch12:qcm:3', true,
   'Transport national : TVA 20 %. Transport international : exonéré (CGI art. 262).'),

  -- ----- QCM 4 (facile) -----
  (v_formation, v_module, 'qcm',
   'Quel est le délai légal maximum de paiement d''une facture (LME) à compter de la date d''émission ?',
   '[{"id":"a","label":"15 jours","is_correct":false},{"id":"b","label":"30 jours","is_correct":true},{"id":"c","label":"60 jours","is_correct":false},{"id":"d","label":"90 jours","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch12','livret','lme'], 'mft-2026-gotrm-livret:ch12:qcm:4', true,
   'LME (art. L441-6) : délai légal max 30 jours date d''émission ; par accord 60 jours date facture ou 45 jours fin de mois.'),

  -- ----- QCM 5 (moyen) -----
  (v_formation, v_module, 'qcm',
   'Quelle base légale impose les conditions et délais de paiement (pénalités de retard, indemnité forfaitaire 40 €) sur la facture ?',
   '[{"id":"a","label":"CGI art. 289","is_correct":false},{"id":"b","label":"CGI art. 262","is_correct":false},{"id":"c","label":"LME art. L441-6","is_correct":true},{"id":"d","label":"Code des transports","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch12','livret','lme'], 'mft-2026-gotrm-livret:ch12:qcm:5', true,
   'Loi de Modernisation de l''Économie (LME) art. L441-6 : conditions et délais de paiement, pénalités, indemnité forfaitaire 40 €.'),

  -- ----- QCM 6 (moyen) -----
  (v_formation, v_module, 'qcm',
   'Quelle mention doit obligatoirement figurer sur une facture de transport international ?',
   '[{"id":"a","label":"« TVA 20 % applicable »","is_correct":false},{"id":"b","label":"« Exonération TVA — Article 262 CGI »","is_correct":true},{"id":"c","label":"« TVA réduite 5,5 % »","is_correct":false},{"id":"d","label":"« Hors champ d''application TVA »","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch12','livret','tva'], 'mft-2026-gotrm-livret:ch12:qcm:6', true,
   'Transport international : exonéré de TVA (règle de territorialité CGI art. 262). Mention obligatoire : « Exonération TVA — Article 262 CGI ».'),

  -- ----- QCM 7 (moyen) -----
  (v_formation, v_module, 'qcm',
   'Quel est le délai de réserves pour une avarie occulte (découverte au déballage) ?',
   '[{"id":"a","label":"Immédiat à la livraison","is_correct":false},{"id":"b","label":"LRAR dans les 3 jours francs suivant la découverte","is_correct":true},{"id":"c","label":"LRAR dans les 10 jours","is_correct":false},{"id":"d","label":"Après mise en demeure restée sans réponse","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch12','livret','litige'], 'mft-2026-gotrm-livret:ch12:qcm:7', true,
   'Avarie occulte : dommage invisible à la livraison, découvert au déballage → LRAR dans les 3 jours francs suivant la découverte.'),

  -- ----- QCM 8 (moyen) -----
  (v_formation, v_module, 'qcm',
   'Quelle est la conséquence d''une réserve non confirmée par LRAR dans les 3 jours francs ?',
   '[{"id":"a","label":"Indemnisation réduite de moitié","is_correct":false},{"id":"b","label":"Forclusion : perte du droit d''agir en justice","is_correct":true},{"id":"c","label":"Application du contrat type général uniquement","is_correct":false},{"id":"d","label":"Aucune conséquence si la réserve a été notée sur la lettre de voiture","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch12','livret','forclusion'], 'mft-2026-gotrm-livret:ch12:qcm:8', true,
   'Forclusion : réserves non confirmées par LRAR dans les 3 jours francs = perte du droit d''agir en justice. 10 jours pour les particuliers.'),

  -- ----- QCM 9 (moyen) -----
  (v_formation, v_module, 'qcm',
   'Quel est le plafond d''indemnisation au kg pour un envoi < 3 tonnes en contrat type général ?',
   '[{"id":"a","label":"14 €/kg","is_correct":false},{"id":"b","label":"20 €/kg","is_correct":false},{"id":"c","label":"23 €/kg","is_correct":false},{"id":"d","label":"33 €/kg","is_correct":true}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch12','livret','plafond'], 'mft-2026-gotrm-livret:ch12:qcm:9', true,
   'Contrat type général, envoi < 3 t : 33 €/kg. Envoi ≥ 3 t : 20 €/kg. Température dirigée : 23 €/kg (< 3 t) et 14 €/kg (≥ 3 t).'),

  -- ----- QCM 10 (difficile) -----
  (v_formation, v_module, 'qcm',
   'Pour un envoi ≥ 3 tonnes en contrat type général, quel est le plafond par tonne ?',
   '[{"id":"a","label":"1 000 €/tonne","is_correct":false},{"id":"b","label":"3 200 €/tonne","is_correct":true},{"id":"c","label":"4 000 €/tonne","is_correct":false},{"id":"d","label":"750 €/tonne","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch12','livret','plafond'], 'mft-2026-gotrm-livret:ch12:qcm:10', true,
   'Contrat type général, envoi ≥ 3 t : 3 200 €/tonne. Température dirigée ≥ 3 t : 4 000 €/tonne.'),

  -- ----- QCM 11 (difficile) -----
  (v_formation, v_module, 'qcm',
   'Dans quel cas les plafonds d''indemnisation NE s''appliquent PAS ?',
   '[{"id":"a","label":"Avarie caractérisée constatée à la livraison","is_correct":false},{"id":"b","label":"Manquant partiel signalé par LRAR","is_correct":false},{"id":"c","label":"Déclaration de valeur souscrite avant le transport","is_correct":true},{"id":"d","label":"Retard de livraison","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch12','livret','plafond'], 'mft-2026-gotrm-livret:ch12:qcm:11', true,
   'Les plafonds ne s''appliquent PAS en cas de : dol (faute intentionnelle grave), faute lourde inexcusable, ou déclaration de valeur souscrite avant le transport.'),

  -- ----- QCM 12 (difficile) -----
  (v_formation, v_module, 'qcm',
   'Laquelle de ces situations EXONÈRE le transporteur de toute indemnisation ?',
   '[{"id":"a","label":"Avarie occulte signalée par LRAR dans les 3 jours","is_correct":false},{"id":"b","label":"Vice propre de la marchandise","is_correct":true},{"id":"c","label":"Manquant constaté à la livraison","is_correct":false},{"id":"d","label":"Retard de plus de 24 heures","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch12','livret','exoneration'], 'mft-2026-gotrm-livret:ch12:qcm:12', true,
   'Causes d''exonération : vice propre, défaut d''emballage signalé par réserves au chargement, faute expéditeur/destinataire, force majeure.'),

  -- =====================================================================
  -- QR — Cas pratiques calcul d'indemnisation
  -- =====================================================================

  -- ----- QR 1 -----
  (v_formation, v_module, 'qr',
   'CAS PRATIQUE : 3 colis endommagés, poids total avarié 180 kg, lot total 2,5 tonnes (envoi < 3 t), contrat type général. Calculez l''Option 1 (par kg) et l''Option 2 (par colis), puis indiquez le plafond retenu si AUCUNE déclaration de valeur n''a été souscrite.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch12','livret','cas-pratique','plafond'], 'mft-2026-gotrm-livret:ch12:qr:1', true,
   'Option 1 (par kg) : 180 × 33 = 5 940 €. Option 2 (par colis) : 3 × 1 000 = 3 000 €. Plafond retenu = le PLUS PETIT = 3 000 €.'),

  -- ----- QR 2 -----
  (v_formation, v_module, 'qr',
   'Reprenez le cas précédent : 3 colis avariés, 180 kg, contrat type général envoi < 3 t. L''expéditeur avait souscrit une DÉCLARATION DE VALEUR de 8 000 € pour les 3 colis. Quel montant sera versé ? Justifiez la règle juridique.',
   NULL,
   6, 'difficile', ARRAY['gotrm','ch12','livret','cas-pratique','declaration-valeur'], 'mft-2026-gotrm-livret:ch12:qr:2', true,
   'La déclaration de valeur souscrite avant le transport supprime l''application des plafonds légaux. → Indemnisation jusqu''à la valeur déclarée = 8 000 €. Les plafonds (3 000 €) ne s''appliquent plus.'),

  -- ----- QR 3 -----
  (v_formation, v_module, 'qr',
   'Énumérez les 8 mentions obligatoires d''une facture de transport (avec leur base légale principale).',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch12','livret','facture'], 'mft-2026-gotrm-livret:ch12:qr:3', true,
   '1) Numéro de facture (CGI 289), 2) Date d''émission (CGI 289), 3) Identité vendeur SIRET TVA intra (CGI 289), 4) Identité acheteur (CGI 289), 5) Description prestation (Code des transports), 6) Prix HT détaillé (CGI 289), 7) Taux et montant TVA 20 %/0 % (CGI 262), 8) Total TTC (CGI 289). + Conditions/délais paiement, indemnité 40 € (LME L441-6).'),

  -- ----- QR 4 -----
  (v_formation, v_module, 'qr',
   'CAS PRATIQUE : Un envoi de 4 tonnes en contrat type TEMPÉRATURE DIRIGÉE est totalement avarié. Calculez l''indemnisation maximale (base : par kg ET par tonne), puis indiquez le plafond retenu.',
   NULL,
   6, 'difficile', ARRAY['gotrm','ch12','livret','cas-pratique','temperature-dirigee'], 'mft-2026-gotrm-livret:ch12:qr:4', true,
   'Envoi ≥ 3 t en température dirigée : 14 €/kg et 4 000 €/tonne. Option par kg : 4 000 × 14 = 56 000 €. Option par tonne : 4 × 4 000 = 16 000 €. Plafond retenu = le PLUS PETIT = 16 000 €.');

  -- =====================================================================
  -- QUIZ — entraînement
  -- =====================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Chapitre 12 — Quiz d''entraînement',
    'Quiz d''entraînement (12 questions) sur la facturation, les litiges et la clôture des dossiers.',
    'entrainement',
    NULL,
    70
  )
  RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch12:qcm:%';

  RAISE NOTICE '✓ Module Ch12 (Facturation, litiges, clôture) importé — 12 QCM + 4 QR.';
END $ch12_v4$;
