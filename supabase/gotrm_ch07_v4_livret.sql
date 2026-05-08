-- =====================================================================
-- GOTRM — Chapitre 7 : Les documents de transport
-- Source : LIVRET_PRO_CCP1_GOTRM V2 — pages 26 à 28
-- Idempotent : suppression du module + des questions avant réinsertion
-- =====================================================================

DO $ch07_v4$
DECLARE
  v_formation uuid;
  v_bloc      int;
  v_module    uuid;
  v_lesson    uuid;
  v_quiz      uuid;
BEGIN
  -- 1) Formation gotrm
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable.';
  END IF;

  -- 2) Bloc BC1 (créé si absent)
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

  -- 3) Nettoyage idempotent
  DELETE FROM public.modules WHERE slug = 'gotrm-ch07-documents-transport';
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch07:%';

  -- 4) Module
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Chapitre 7 — Les documents de transport',
    'gotrm-ch07-documents-transport',
    v_bloc,
    'Maîtriser la lettre de voiture nationale et internationale (CMR), l''ordre de mission, la pochette de bord et les réserves sur les documents de transport.',
    'intermediaire',
    60,
    70
  )
  RETURNING id INTO v_module;

  -- 5) Lien formation_modules
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 70, true)
  ON CONFLICT DO NOTHING;

  -- 6) Leçon (markdown GFM, sans apostrophes échappées car dollar-quoting)
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module,
    'Les documents de transport',
    'documents-transport',
    1,
    60,
$lesson$
# Les documents de transport

> 🎯 **Objectifs pédagogiques**
> - Identifier les mentions obligatoires de la lettre de voiture nationale et les sanctions associées.
> - Comprendre le rôle et la structure de la lettre de voiture internationale (CMR) et le plafond d'indemnisation.
> - Distinguer l'ordre de mission interne des documents contractuels.
> - Constituer une pochette de bord conforme et connaître les amendes en cas d'absence.
> - Maîtriser la procédure des réserves sur les documents de transport (3 jours francs, LRAR, art. L.133-3).

Les documents de transport ont trois fonctions fondamentales : **juridique** (ils constituent la preuve du contrat de transport), **réglementaire** (certains sont obligatoires à bord sous peine d'amendes) et **opérationnelle** (ils assurent la traçabilité de la marchandise). Le gestionnaire est responsable de la constitution correcte de tous les dossiers documents avant chaque départ.

---

## 7.1 — La lettre de voiture nationale

> ⚠️ **Réglementation**
> Absence de lettre de voiture à bord ou lettre sans mentions obligatoires : **amende de 1 500 €**.

**Mentions obligatoires :**
- **Identification des parties** : expéditeur, destinataire, donneur d'ordres, transporteur.
- **Lieux et dates** : adresses exactes de chargement et de livraison, dates et heures prévues.
- **La marchandise** : nature, poids brut, nombre et type d'unités de charge, marques et numéros, ml ou volume si nécessaire, spécificités (ADR, ATP, fragilité, valeur déclarée).
- **Conditions commerciales** : port payé ou port dû, prestations annexes.

**Exemplaires : 3 originaux minimum**
→ Expéditeur (remis au chargement) — Conducteur (à bord pendant le transport) — Destinataire (remis à la livraison).

---

## 7.2 — La lettre de voiture internationale (CMR)

Pour tout transport international entre pays signataires de la **Convention de Genève**, la lettre de voiture **CMR** est obligatoire. Elle est établie en **3 exemplaires originaux** signés par l'expéditeur et le transporteur.

| Exemplaire | Identification | Destinataire |
|---|---|---|
| Exemplaire 1 | Fond rouge | Conservé par l'expéditeur au chargement |
| Exemplaire 2 | Fond bleu | Accompagne la marchandise — remis au destinataire à la livraison |
| Exemplaire 3 | Fond vert | Conservé par le transporteur |

> 📌 **À retenir**
> La CMR engage la responsabilité du transporteur dès la prise en charge de la marchandise jusqu'à sa livraison.
>
> **Plafond d'indemnisation CMR** en cas de perte ou avarie : **8,33 DTS par kg brut** de marchandise manquante.
>
> En cas de valeur élevée : recommander au client de souscrire une **déclaration de valeur** avant le transport.

---

## 7.3 — L'ordre de mission

Document **interne** par lequel le gestionnaire donne au conducteur les instructions précises de sa mission. Non obligatoire légalement, il est fortement recommandé pour garantir la traçabilité des instructions et éviter les incompréhensions.

**Contenu type :** identité du conducteur, immatriculations tracteur et semi-remorque, heure de prise de service, adresse et heure de chargement avec contact sur place, adresse et heure de livraison impérative avec contact destinataire, nature et quantité de la marchandise, instructions particulières, numéro du gestionnaire.

---

## 7.4 — La pochette de bord

La pochette de bord est l'ensemble des documents remis au conducteur avant son départ. Le gestionnaire est responsable de sa constitution complète et conforme.

| Document | Amende si absent à bord |
|---|---|
| Copie conforme de la licence de transport | 1 500 € |
| Certificat d'immatriculation (carte grise) | 38 € (présentation immédiate) / 750 € (sous 5 jours) |
| Attestation d'assurance | 750 € |
| Permis de conduire valide et adapté | 1 an de prison et/ou 1 500 € |
| Carte de Qualification Conducteur (CQC) | 150 € (immédiate) / 750 € (sous 5 jours) |
| Carte conducteur numérique | 6 mois de prison et/ou 3 750 € |
| Lettre de voiture | 1 500 € |
| Documents ADR (si matières dangereuses) | 1 500 € par document manquant |

---

## 7.5 — Les réserves sur les documents de transport

| Moment | Qui ? | Objet | Effets |
|---|---|---|---|
| Au chargement | Conducteur | Signaler l'état suspect de l'emballage ou de la marchandise | Protège le transporteur — prouve que les dommages existaient avant la prise en charge |
| À la livraison | Destinataire | Signaler tout dommage ou manquant constaté | Ouvre le droit à indemnisation — doit être précis et motivé |

> ⚠️ **Réglementation**
> Les réserves doivent être **PRÉCISES, MOTIVÉES et IDENTIFIABLES**.
> Des réserves vagues du type « sous réserve de déballage » ne sont pas juridiquement suffisantes.
>
> À la livraison, les réserves écrites sur le document doivent être confirmées par **LRAR** dans les **3 JOURS FRANCS** suivant la livraison (**article L.133-3 du Code de commerce**).
> Pour les particuliers (consommateurs) : **10 jours** (article L.224-65 du Code de la consommation).
>
> **FORCLUSION** : réserves non confirmées dans les délais = **perte du droit d'agir en justice**.

---

## 7.6 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| Lettre de voiture | Document central du contrat de transport accompagnant la marchandise |
| CMR | Convention relative au contrat de transport international de marchandises par route |
| Ordre de mission | Document interne donnant au conducteur les instructions de sa mission |
| Pochette de bord | Ensemble des documents remis au conducteur avant son départ |
| Réserves | Annotations écrites sur le document de transport signalant une anomalie |
| LRAR | Lettre Recommandée avec Accusé de Réception — mode de confirmation des réserves |
| 3 jours francs | Délai légal de confirmation des réserves — hors dimanches et jours fériés |
| Forclusion | Perte du droit d'agir en justice faute d'avoir respecté les délais légaux |
| Avarie | Dommage subi par la marchandise pendant le transport |
| Manquant | Colis présent sur le document de transport mais absent à la livraison |
$lesson$,
'Lettre de voiture nationale et CMR, ordre de mission, pochette de bord, réserves (3 jours francs, LRAR, art. L.133-3) et vocabulaire essentiel.'
  )
  RETURNING id INTO v_lesson;

  -- 7) Banque de questions : 10 QCM + 3 QR
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES
  -- ---------- QCM 1 (facile) ----------
  (v_formation, v_module, 'qcm',
   'Quelle est l''amende encourue en cas d''absence de lettre de voiture à bord ou de lettre sans mentions obligatoires ?',
   '[{"id":"a","label":"750 €","is_correct":false},{"id":"b","label":"1 500 €","is_correct":true},{"id":"c","label":"3 750 €","is_correct":false},{"id":"d","label":"38 €","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch07','livret'], 'mft-2026-gotrm-livret:ch07:qcm:1', true,
   'Selon le livret §7.1, l''absence de lettre de voiture à bord ou une lettre sans mentions obligatoires entraîne une amende de 1 500 €.'),

  -- ---------- QCM 2 (facile) ----------
  (v_formation, v_module, 'qcm',
   'Combien d''exemplaires originaux minimum doit comporter la lettre de voiture nationale ?',
   '[{"id":"a","label":"1","is_correct":false},{"id":"b","label":"2","is_correct":false},{"id":"c","label":"3","is_correct":true},{"id":"d","label":"4","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch07','livret'], 'mft-2026-gotrm-livret:ch07:qcm:2', true,
   '§7.1 : 3 originaux minimum, un pour l''expéditeur, un pour le conducteur, un pour le destinataire.'),

  -- ---------- QCM 3 (facile) ----------
  (v_formation, v_module, 'qcm',
   'Quelle est la couleur de fond de l''exemplaire CMR conservé par le transporteur ?',
   '[{"id":"a","label":"Fond rouge","is_correct":false},{"id":"b","label":"Fond bleu","is_correct":false},{"id":"c","label":"Fond vert","is_correct":true},{"id":"d","label":"Fond jaune","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch07','livret'], 'mft-2026-gotrm-livret:ch07:qcm:3', true,
   '§7.2 : Exemplaire 1 (rouge) = expéditeur, Exemplaire 2 (bleu) = destinataire, Exemplaire 3 (vert) = transporteur.'),

  -- ---------- QCM 4 (facile) ----------
  (v_formation, v_module, 'qcm',
   'Quelle convention internationale régit le transport de marchandises par route entre pays signataires ?',
   '[{"id":"a","label":"Convention de Vienne","is_correct":false},{"id":"b","label":"Convention de Genève (CMR)","is_correct":true},{"id":"c","label":"Convention de Paris","is_correct":false},{"id":"d","label":"Convention de Berne","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch07','livret'], 'mft-2026-gotrm-livret:ch07:qcm:4', true,
   '§7.2 : la CMR (Convention relative au contrat de transport international de marchandises par route) découle de la Convention de Genève.'),

  -- ---------- QCM 5 (moyen) ----------
  (v_formation, v_module, 'qcm',
   'Quel est le plafond d''indemnisation CMR en cas de perte ou avarie ?',
   '[{"id":"a","label":"8,33 € par kg brut","is_correct":false},{"id":"b","label":"8,33 DTS par kg brut de marchandise manquante","is_correct":true},{"id":"c","label":"23 € par kg net","is_correct":false},{"id":"d","label":"100 DTS par colis","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch07','livret'], 'mft-2026-gotrm-livret:ch07:qcm:5', true,
   '§7.2 : le plafond CMR est fixé à 8,33 DTS (Droits de Tirage Spéciaux) par kg brut de marchandise manquante.'),

  -- ---------- QCM 6 (moyen) ----------
  (v_formation, v_module, 'qcm',
   'L''ordre de mission est :',
   '[{"id":"a","label":"Un document obligatoire à bord sous peine d''amende","is_correct":false},{"id":"b","label":"Un document interne, non obligatoire mais fortement recommandé","is_correct":true},{"id":"c","label":"Un document contractuel signé par le destinataire","is_correct":false},{"id":"d","label":"Un substitut de la lettre de voiture","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch07','livret'], 'mft-2026-gotrm-livret:ch07:qcm:6', true,
   '§7.3 : document interne par lequel le gestionnaire donne les instructions de mission au conducteur. Non obligatoire légalement mais fortement recommandé pour la traçabilité.'),

  -- ---------- QCM 7 (moyen) ----------
  (v_formation, v_module, 'qcm',
   'Quelle est l''amende prévue en cas d''absence de la carte conducteur numérique ?',
   '[{"id":"a","label":"1 500 €","is_correct":false},{"id":"b","label":"750 €","is_correct":false},{"id":"c","label":"6 mois de prison et/ou 3 750 €","is_correct":true},{"id":"d","label":"150 € (immédiate) / 750 € (sous 5 jours)","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch07','livret'], 'mft-2026-gotrm-livret:ch07:qcm:7', true,
   '§7.4 (pochette de bord) : l''absence de carte conducteur numérique est sanctionnée par 6 mois de prison et/ou 3 750 €.'),

  -- ---------- QCM 8 (moyen) ----------
  (v_formation, v_module, 'qcm',
   'Pour le permis de conduire valide et adapté, quelle est la sanction si absent à bord ?',
   '[{"id":"a","label":"38 € immédiate","is_correct":false},{"id":"b","label":"750 €","is_correct":false},{"id":"c","label":"1 an de prison et/ou 1 500 €","is_correct":true},{"id":"d","label":"6 mois de prison et/ou 3 750 €","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch07','livret'], 'mft-2026-gotrm-livret:ch07:qcm:8', true,
   '§7.4 : permis de conduire valide et adapté absent → 1 an de prison et/ou 1 500 €.'),

  -- ---------- QCM 9 (difficile) ----------
  (v_formation, v_module, 'qcm',
   'Dans quel délai les réserves écrites à la livraison doivent-elles être confirmées par LRAR (relations entre professionnels) ?',
   '[{"id":"a","label":"24 heures","is_correct":false},{"id":"b","label":"3 jours francs (article L.133-3 du Code de commerce)","is_correct":true},{"id":"c","label":"10 jours","is_correct":false},{"id":"d","label":"30 jours","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch07','livret'], 'mft-2026-gotrm-livret:ch07:qcm:9', true,
   '§7.5 : les réserves doivent être confirmées par LRAR dans les 3 jours francs suivant la livraison (art. L.133-3 du Code de commerce). Pour les consommateurs : 10 jours (art. L.224-65 du Code de la consommation).'),

  -- ---------- QCM 10 (difficile) ----------
  (v_formation, v_module, 'qcm',
   'Que signifie la "forclusion" en matière de réserves sur documents de transport ?',
   '[{"id":"a","label":"Une amende administrative","is_correct":false},{"id":"b","label":"L''obligation de souscrire une déclaration de valeur","is_correct":false},{"id":"c","label":"La perte du droit d''agir en justice faute d''avoir respecté les délais légaux","is_correct":true},{"id":"d","label":"Le refus du destinataire de prendre livraison","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch07','livret'], 'mft-2026-gotrm-livret:ch07:qcm:10', true,
   '§7.5 et §7.6 : la forclusion est la perte du droit d''agir en justice quand les réserves ne sont pas confirmées dans les délais (3 jours francs entre pros, 10 jours pour les consommateurs).'),

  -- ---------- QR 1 ----------
  (v_formation, v_module, 'qr',
   'Citez les quatre catégories de mentions obligatoires de la lettre de voiture nationale et donnez un exemple précis pour chacune.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch07','livret','qr'], 'mft-2026-gotrm-livret:ch07:qr:1', true,
   '§7.1 — Les 4 catégories : (1) Identification des parties (expéditeur, destinataire, donneur d''ordres, transporteur) ; (2) Lieux et dates (adresses exactes de chargement et de livraison, dates et heures prévues) ; (3) La marchandise (nature, poids brut, nombre et type d''UC, marques et numéros, ml ou volume, spécificités ADR/ATP/fragilité/valeur déclarée) ; (4) Conditions commerciales (port payé ou port dû, prestations annexes).'),

  -- ---------- QR 2 ----------
  (v_formation, v_module, 'qr',
   'Décrivez la procédure de réserves à la livraison entre professionnels : sur quel support, quels critères de validité, quel délai et quelle conséquence en cas de non-respect ?',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch07','livret','qr'], 'mft-2026-gotrm-livret:ch07:qr:2', true,
   '§7.5 — Le destinataire signale tout dommage ou manquant directement sur le document de transport (lettre de voiture/CMR). Les réserves doivent être PRÉCISES, MOTIVÉES et IDENTIFIABLES (les formules vagues type « sous réserve de déballage » ne suffisent pas). Elles doivent ensuite être confirmées par LRAR dans les 3 jours francs suivant la livraison (article L.133-3 du Code de commerce). À défaut : forclusion = perte du droit d''agir en justice.'),

  -- ---------- QR 3 ----------
  (v_formation, v_module, 'qr',
   'Quels sont les trois exemplaires de la lettre de voiture CMR ? Indiquez la couleur, le détenteur et le rôle de chacun, ainsi que le plafond d''indemnisation applicable.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch07','livret','qr'], 'mft-2026-gotrm-livret:ch07:qr:3', true,
   '§7.2 — Exemplaire 1 (fond rouge) : conservé par l''expéditeur au chargement. Exemplaire 2 (fond bleu) : accompagne la marchandise et est remis au destinataire à la livraison. Exemplaire 3 (fond vert) : conservé par le transporteur. Plafond d''indemnisation CMR : 8,33 DTS par kg brut de marchandise manquante. Pour une valeur élevée, recommander au client une déclaration de valeur avant transport.');

  -- 8) Quiz d'entraînement
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Chapitre 7 — Quiz d''entraînement',
    'Quiz d''entraînement (10 questions) sur les documents de transport : lettre de voiture nationale et CMR, ordre de mission, pochette de bord, réserves.',
    'entrainement',
    NULL,
    70
  )
  RETURNING id INTO v_quiz;

  -- 9) Lien quiz ↔ banque de questions (uniquement les QCM)
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch07:qcm:%';

  RAISE NOTICE '✓ Module Ch7 (gotrm) importé : 1 leçon, 10 QCM + 3 QR, 1 quiz.';
END
$ch07_v4$;
