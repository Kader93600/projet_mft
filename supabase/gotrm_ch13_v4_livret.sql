-- ============================================================================
-- GOTRM — Chapitre 13 : Qualité, indicateurs de performance et analyse financière
-- Source : Livret pro CCP1 GOTRM v2 — pages 51 à 54
-- Idempotent : suppression et réinsertion du module + banque de questions
-- ============================================================================

DO $ch13_v4$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson uuid;
  v_quiz uuid;
BEGIN
  -- Formation GOTRM
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable.';
  END IF;

  -- Bloc BC1 (générique partagé)
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
  DELETE FROM public.modules WHERE slug = 'gotrm-ch13-kpi-rentabilite';
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch13:%';

  -- Module
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Chapitre 13 — Qualité, indicateurs de performance et analyse financière',
    'gotrm-ch13-kpi-rentabilite',
    v_bloc,
    'Maîtriser les KPI qualité et rentabilité (taux ponctualité, remplissage, km à vide), calculer un seuil de rentabilité, lire les Soldes Intermédiaires de Gestion (SIG) et analyser les écarts.',
    'avance',
    70,
    130
  )
  RETURNING id INTO v_module;

  -- Lien formation_modules
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 130, true)
  ON CONFLICT DO NOTHING;

  -- Leçon (markdown)
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module,
    'Qualité, indicateurs de performance et analyse financière',
    'kpi-rentabilite',
    1,
    70,
$lesson$
# Chapitre 13 — Qualité, indicateurs de performance et analyse financière

La maîtrise des indicateurs de performance est indispensable pour piloter une exploitation et rendre compte à la hiérarchie. Ce chapitre présente les principaux KPI qualité et rentabilité, ainsi que les outils d'analyse financière que le gestionnaire doit savoir utiliser.

---

## 13.1 — Les cinq piliers de la qualité de service

| Pilier | Description | Indicateur associé |
|---|---|---|
| Respect des délais | Livraison dans le créneau convenu | Taux de ponctualité (≥ 98 %) |
| Intégrité des marchandises | Livraison en bon état, sans avarie ni manquant | Taux d'avaries (minimiser) |
| Traçabilité | Capacité à informer le client en temps réel | Enregistrement systématique TMS |
| Réactivité | Gestion rapide et efficace des aléas | Délai de traitement des incidents |
| Conformité réglementaire | Transports réalisés dans le respect des règles | Absence d'infractions RSE et documentaires |

---

## 13.2 — Les indicateurs clés (KPI)

| Indicateur (KPI) | Formule de calcul | Cible indicative | Utilité |
|---|---|---|---|
| Taux de ponctualité | (Livraisons à l'heure / Total livraisons) × 100 | ≥ 98 % | Mesure le respect des délais |
| Taux de litiges | (Nb litiges / Nb opérations) × 100 | < 2 % | Mesure la qualité des opérations |
| Taux de km à vide | (Km sans charge / Km totaux) × 100 | < 15 % | Mesure l'optimisation de l'exploitation |
| Taux de remplissage | (Charge transportée / Capacité max) × 100 | ≥ 85 % | Mesure la rentabilité des véhicules |
| Consommation carburant | Litres consommés / 100 km | Selon norme véhicule | Suivi des coûts d'exploitation |
| Taux d'utilisation du parc | (Jours exploitation réels / Jours disponibles) × 100 | Maximiser | Mesure la disponibilité de la flotte |

### Exemple — Calcul du taux de ponctualité (Semaine 22)

- Livraisons prévues : 120
- Livraisons réalisées à l'heure : 108
- **Taux = (108 / 120) × 100 = 90 %**
- → ALERTE : en dessous de l'objectif de 98 %.
- Cause identifiée : 3 retards liés à des pannes sur le secteur Nord.
- Mesure corrective : renforcer la maintenance préventive des véhicules du secteur.

---

## 13.3 — Le seuil de rentabilité

Le seuil de rentabilité (ou point mort) est le niveau de chiffre d'affaires à partir duquel l'entreprise couvre l'intégralité de ses charges et commence à dégager un bénéfice. En dessous, elle est en perte ; au-dessus, elle est bénéficiaire.

| Notion | Formule | Signification |
|---|---|---|
| Marge sur Coût Variable (MCV) | CA − Charges Variables | Part du CA qui contribue à couvrir les charges fixes |
| Taux de MCV | (MCV / CA) × 100 | Pour chaque euro de CA, quelle part couvre les charges fixes |
| Seuil de rentabilité | Charges Fixes / Taux de MCV | Niveau de CA à partir duquel l'entreprise est rentable |
| Point mort | (SR / CA annuel) × 365 | Jour de l'année à partir duquel l'entreprise devient bénéficiaire |
| Marge de sécurité | CA réel − Seuil de rentabilité | CA que l'entreprise peut perdre avant d'être en perte |
| Résultat prévisionnel | MCV − Charges Fixes | Bénéfice ou perte attendu sur la période |

### Cas pratique — Calcul complet du seuil de rentabilité

**Données annuelles :**
- CA = 1 250 000 €
- Charges variables = 800 000 €
- Charges fixes = 310 000 €

**Calculs :**
- MCV = 1 250 000 − 800 000 = **450 000 €**
- Taux de MCV = 450 000 / 1 250 000 × 100 = **36 %**
- Seuil de rentabilité = 310 000 / 0,36 = **861 111 €**
- Point mort = (861 111 / 1 250 000) × 365 = **251 jours**
- → L'entreprise devient bénéficiaire à partir du 251e jour de l'année (début septembre).
- Marge de sécurité = 1 250 000 − 861 111 = **388 889 € (31,1 % du CA)**
- Résultat prévisionnel = 450 000 − 310 000 = **140 000 €**

---

## 13.4 — Les Soldes Intermédiaires de Gestion (SIG)

| SIG | Formule simplifiée | Ce qu'il mesure |
|---|---|---|
| Chiffre d'Affaires (CA) | Ventes de prestations HT | Volume d'activité commercial |
| Valeur Ajoutée (VA) | CA − Charges externes (sous-traitance, carburant, péages...) | Richesse créée par l'entreprise |
| EBE | VA − (Salaires + Charges sociales + Impôts) | Performance économique avant amortissements |
| Résultat d'exploitation (REX) | EBE − Dotations aux amortissements | Performance de l'activité transport |
| Résultat net | REX +/− Résultat financier − Impôts | Bénéfice ou perte finale de l'exercice |

### Point de vigilance

Un **EBE NÉGATIF** est un signal d'alarme grave.

Il signifie que l'activité ne couvre pas ses charges courantes avant même de payer les emprunts ou d'amortir le matériel.

Ce constat doit être signalé **IMMÉDIATEMENT** à la hiérarchie avec un compte rendu circonstancié.

---

## 13.5 — Analyse des écarts et mesures correctives

| Écart constaté | Causes probables | Mesures correctives |
|---|---|---|
| Taux km à vide élevé | Absences de rechargements, tournées mal optimisées | Publier les disponibilités sur bourse de fret dès le chargement |
| Consommation carburant > budget | Surconsommation, mauvaise conduite, hausse prix gazole | Formation éco-conduite, pied de facture, révision des itinéraires |
| Taux d'avaries en hausse | Arrimage insuffisant, véhicule inadapté | Renforcer consignes chargement, vérifier adéquation matériel |
| Marge insuffisante | Sous-tarification ou surcoûts non refacturés | Révision grille tarifaire, refacturation des prestations annexes |
| CA inférieur au budget | Perte de clients, baisse de volumes | Analyse des clients perdus, renforcement commercial |

---

## 13.6 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| KPI | Key Performance Indicator — indicateur clé de performance |
| Taux de ponctualité | Pourcentage de livraisons réalisées dans le délai convenu |
| Seuil de rentabilité | Niveau de CA à partir duquel toutes les charges sont couvertes |
| Point mort | Date de l'année à laquelle le seuil de rentabilité est atteint |
| Charges fixes | Charges indépendantes du niveau d'activité |
| Charges variables | Charges évoluant proportionnellement à l'activité |
| MCV | Marge sur Coût Variable = CA − Charges Variables |
| EBE | Excédent Brut d'Exploitation — principal indicateur de performance économique |
| SIG | Soldes Intermédiaires de Gestion — décomposition analytique du résultat |
| Écart | Différence entre un résultat réalisé et un objectif budgété |
| Mesure corrective | Action mise en place pour réduire un écart constaté |
$lesson$,
    'KPI qualité, seuil rentabilité, SIG, analyse écarts.'
  )
  RETURNING id INTO v_lesson;

  -- ==========================================================================
  -- BANQUE DE QUESTIONS — 12 QCM + 4 QR
  -- ==========================================================================

  INSERT INTO public.question_bank (
    formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation
  ) VALUES

  -- ----- QCM 1 (facile) — Pilier qualité
  (v_formation, v_module, 'qcm',
   'Parmi les cinq piliers de la qualité de service, lequel est associé au taux de ponctualité (≥ 98 %) ?',
   '[{"id":"a","label":"Intégrité des marchandises","is_correct":false},
     {"id":"b","label":"Respect des délais","is_correct":true},
     {"id":"c","label":"Traçabilité","is_correct":false},
     {"id":"d","label":"Conformité réglementaire","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch13','livret','qualite'],
   'mft-2026-gotrm-livret:ch13:qcm:1', true,
   'Le respect des délais — livraison dans le créneau convenu — est mesuré par le taux de ponctualité avec une cible ≥ 98 %.'),

  -- ----- QCM 2 (facile) — Cible km à vide
  (v_formation, v_module, 'qcm',
   'Quelle est la cible indicative du taux de km à vide ?',
   '[{"id":"a","label":"< 15 %","is_correct":true},
     {"id":"b","label":"≥ 85 %","is_correct":false},
     {"id":"c","label":"≥ 98 %","is_correct":false},
     {"id":"d","label":"< 2 %","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch13','livret','kpi'],
   'mft-2026-gotrm-livret:ch13:qcm:2', true,
   'Le taux de km à vide doit rester inférieur à 15 % : il mesure l''optimisation de l''exploitation (km sans charge / km totaux × 100).'),

  -- ----- QCM 3 (facile) — Formule taux de remplissage
  (v_formation, v_module, 'qcm',
   'Quelle est la formule du taux de remplissage ?',
   '[{"id":"a","label":"(Livraisons à l''heure / Total livraisons) × 100","is_correct":false},
     {"id":"b","label":"(Charge transportée / Capacité max) × 100","is_correct":true},
     {"id":"c","label":"(Km sans charge / Km totaux) × 100","is_correct":false},
     {"id":"d","label":"(Nb litiges / Nb opérations) × 100","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch13','livret','kpi'],
   'mft-2026-gotrm-livret:ch13:qcm:3', true,
   'Le taux de remplissage = (Charge transportée / Capacité max) × 100. Cible ≥ 85 %, il mesure la rentabilité des véhicules.'),

  -- ----- QCM 4 (facile) — Définition MCV
  (v_formation, v_module, 'qcm',
   'Que signifie l''acronyme MCV ?',
   '[{"id":"a","label":"Marge sur Charges Variables","is_correct":false},
     {"id":"b","label":"Marge sur Coût Variable","is_correct":true},
     {"id":"c","label":"Marge Comptable Valorisée","is_correct":false},
     {"id":"d","label":"Marge Conventionnelle de Vente","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch13','livret','vocabulaire'],
   'mft-2026-gotrm-livret:ch13:qcm:4', true,
   'MCV = Marge sur Coût Variable = CA − Charges Variables. C''est la part du CA qui contribue à couvrir les charges fixes.'),

  -- ----- QCM 5 (moyen) — Calcul ponctualité semaine 22
  (v_formation, v_module, 'qcm',
   'Sur 120 livraisons prévues semaine 22, 108 ont été réalisées à l''heure. Quel est le taux de ponctualité ?',
   '[{"id":"a","label":"85 %","is_correct":false},
     {"id":"b","label":"90 %","is_correct":true},
     {"id":"c","label":"95 %","is_correct":false},
     {"id":"d","label":"98 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch13','livret','kpi','calcul'],
   'mft-2026-gotrm-livret:ch13:qcm:5', true,
   'Taux = (108 / 120) × 100 = 90 %. ALERTE : en dessous de l''objectif de 98 %.'),

  -- ----- QCM 6 (moyen) — Formule seuil rentabilité
  (v_formation, v_module, 'qcm',
   'Comment calcule-t-on le seuil de rentabilité ?',
   '[{"id":"a","label":"CA − Charges Variables","is_correct":false},
     {"id":"b","label":"Charges Fixes / Taux de MCV","is_correct":true},
     {"id":"c","label":"MCV − Charges Fixes","is_correct":false},
     {"id":"d","label":"(SR / CA annuel) × 365","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch13','livret','rentabilite'],
   'mft-2026-gotrm-livret:ch13:qcm:6', true,
   'Seuil de rentabilité = Charges Fixes / Taux de MCV. C''est le niveau de CA à partir duquel l''entreprise est rentable.'),

  -- ----- QCM 7 (moyen) — Calcul Taux MCV cas pratique
  (v_formation, v_module, 'qcm',
   'CA = 1 250 000 € ; Charges variables = 800 000 €. Quel est le Taux de MCV ?',
   '[{"id":"a","label":"30 %","is_correct":false},
     {"id":"b","label":"36 %","is_correct":true},
     {"id":"c","label":"40 %","is_correct":false},
     {"id":"d","label":"64 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch13','livret','calcul','rentabilite'],
   'mft-2026-gotrm-livret:ch13:qcm:7', true,
   'MCV = 1 250 000 − 800 000 = 450 000 €. Taux MCV = 450 000 / 1 250 000 × 100 = 36 %.'),

  -- ----- QCM 8 (moyen) — Calcul EBE
  (v_formation, v_module, 'qcm',
   'Quelle est la formule simplifiée de l''EBE dans les SIG ?',
   '[{"id":"a","label":"CA − Charges externes","is_correct":false},
     {"id":"b","label":"VA − (Salaires + Charges sociales + Impôts)","is_correct":true},
     {"id":"c","label":"EBE − Dotations aux amortissements","is_correct":false},
     {"id":"d","label":"REX +/− Résultat financier − Impôts","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch13','livret','sig'],
   'mft-2026-gotrm-livret:ch13:qcm:8', true,
   'EBE = VA − (Salaires + Charges sociales + Impôts). Il mesure la performance économique avant amortissements.'),

  -- ----- QCM 9 (moyen) — Mesure corrective km à vide
  (v_formation, v_module, 'qcm',
   'Face à un taux de km à vide élevé, quelle est la mesure corrective recommandée ?',
   '[{"id":"a","label":"Renforcer la maintenance préventive","is_correct":false},
     {"id":"b","label":"Publier les disponibilités sur bourse de fret dès le chargement","is_correct":true},
     {"id":"c","label":"Formation éco-conduite des conducteurs","is_correct":false},
     {"id":"d","label":"Révision de la grille tarifaire","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch13','livret','ecarts'],
   'mft-2026-gotrm-livret:ch13:qcm:9', true,
   'Tournées mal optimisées et absences de rechargements provoquent des km à vide : la solution est de publier les disponibilités sur bourse de fret dès le chargement.'),

  -- ----- QCM 10 (difficile) — Calcul point mort
  (v_formation, v_module, 'qcm',
   'Avec un seuil de rentabilité de 861 111 € et un CA annuel de 1 250 000 €, quel est le point mort en jours ?',
   '[{"id":"a","label":"180 jours","is_correct":false},
     {"id":"b","label":"220 jours","is_correct":false},
     {"id":"c","label":"251 jours","is_correct":true},
     {"id":"d","label":"310 jours","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch13','livret','calcul','rentabilite'],
   'mft-2026-gotrm-livret:ch13:qcm:10', true,
   'Point mort = (SR / CA annuel) × 365 = (861 111 / 1 250 000) × 365 = 251 jours. L''entreprise devient bénéficiaire début septembre.'),

  -- ----- QCM 11 (difficile) — EBE négatif
  (v_formation, v_module, 'qcm',
   'Que signifie un EBE NÉGATIF et quelle réaction est attendue ?',
   '[{"id":"a","label":"Une situation normale en début d''exercice ; on attend la clôture annuelle","is_correct":false},
     {"id":"b","label":"L''activité ne couvre pas ses charges courantes : signaler IMMÉDIATEMENT à la hiérarchie avec un compte rendu circonstancié","is_correct":true},
     {"id":"c","label":"Un simple écart comptable corrigible par les dotations aux amortissements","is_correct":false},
     {"id":"d","label":"Un signal positif lié à un investissement en cours","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch13','livret','sig','vigilance'],
   'mft-2026-gotrm-livret:ch13:qcm:11', true,
   'Un EBE négatif est un signal d''alarme grave : l''activité ne couvre pas ses charges courantes avant même de payer les emprunts ou d''amortir le matériel. Ce constat doit être signalé IMMÉDIATEMENT à la hiérarchie avec un compte rendu circonstancié.'),

  -- ----- QCM 12 (difficile) — Marge de sécurité
  (v_formation, v_module, 'qcm',
   'CA réel = 1 250 000 € ; Seuil de rentabilité = 861 111 €. Quelle est la marge de sécurité (en € et en % du CA) ?',
   '[{"id":"a","label":"388 889 € soit 31,1 % du CA","is_correct":true},
     {"id":"b","label":"450 000 € soit 36 % du CA","is_correct":false},
     {"id":"c","label":"310 000 € soit 24,8 % du CA","is_correct":false},
     {"id":"d","label":"140 000 € soit 11,2 % du CA","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch13','livret','calcul','rentabilite'],
   'mft-2026-gotrm-livret:ch13:qcm:12', true,
   'Marge de sécurité = CA réel − Seuil de rentabilité = 1 250 000 − 861 111 = 388 889 € (31,1 % du CA). C''est le CA que l''entreprise peut perdre avant d''être en perte.'),

  -- ==========================================================================
  -- 4 QR — Cas pratiques calcul
  -- ==========================================================================

  -- ----- QR 1 (moyen) — Calcul MCV et Taux MCV
  (v_formation, v_module, 'qr',
   'Cas pratique : CA = 1 250 000 € — Charges variables = 800 000 € — Charges fixes = 310 000 €. Calculez la Marge sur Coût Variable (MCV) et le Taux de MCV en détaillant la démarche.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch13','livret','calcul','rentabilite'],
   'mft-2026-gotrm-livret:ch13:qr:1', true,
   'MCV = CA − Charges Variables = 1 250 000 − 800 000 = 450 000 €. Taux de MCV = (MCV / CA) × 100 = (450 000 / 1 250 000) × 100 = 36 %. La MCV représente la part du CA qui contribue à couvrir les charges fixes ; le taux de 36 % indique que pour chaque euro de CA, 36 centimes couvrent les charges fixes.'),

  -- ----- QR 2 (difficile) — Seuil de rentabilité et point mort
  (v_formation, v_module, 'qr',
   'À partir des mêmes données (CA = 1 250 000 € ; Charges fixes = 310 000 € ; Taux de MCV = 36 %), calculez le seuil de rentabilité et le point mort en jours. Indiquez la date approximative à laquelle l''entreprise devient bénéficiaire.',
   NULL,
   6, 'difficile', ARRAY['gotrm','ch13','livret','calcul','rentabilite'],
   'mft-2026-gotrm-livret:ch13:qr:2', true,
   'Seuil de rentabilité = Charges Fixes / Taux de MCV = 310 000 / 0,36 = 861 111 €. Point mort = (SR / CA annuel) × 365 = (861 111 / 1 250 000) × 365 = 251 jours. L''entreprise devient bénéficiaire à partir du 251e jour de l''année, soit début septembre.'),

  -- ----- QR 3 (difficile) — Marge de sécurité et résultat prévisionnel
  (v_formation, v_module, 'qr',
   'Toujours sur les mêmes données (CA = 1 250 000 € ; Charges variables = 800 000 € ; Charges fixes = 310 000 € ; SR = 861 111 €), calculez la marge de sécurité (en € et en % du CA) et le résultat prévisionnel.',
   NULL,
   6, 'difficile', ARRAY['gotrm','ch13','livret','calcul','rentabilite'],
   'mft-2026-gotrm-livret:ch13:qr:3', true,
   'Marge de sécurité = CA réel − Seuil de rentabilité = 1 250 000 − 861 111 = 388 889 €, soit 31,1 % du CA — c''est le CA que l''entreprise peut perdre avant d''être en perte. Résultat prévisionnel = MCV − Charges Fixes = 450 000 − 310 000 = 140 000 € de bénéfice attendu sur la période.'),

  -- ----- QR 4 (moyen) — Analyse écart ponctualité semaine 22
  (v_formation, v_module, 'qr',
   'Semaine 22 : 120 livraisons prévues, 108 réalisées à l''heure. Calculez le taux de ponctualité, comparez à la cible, identifiez la cause indiquée par le livret et proposez la mesure corrective associée.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch13','livret','kpi','ecarts'],
   'mft-2026-gotrm-livret:ch13:qr:4', true,
   'Taux = (108 / 120) × 100 = 90 %. Comparaison cible : ≥ 98 % → ALERTE, en dessous de l''objectif. Cause identifiée : 3 retards liés à des pannes sur le secteur Nord. Mesure corrective : renforcer la maintenance préventive des véhicules du secteur.');

  -- ==========================================================================
  -- QUIZ d'entraînement — 12 QCM
  -- ==========================================================================

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Chapitre 13 — Quiz d''entraînement',
    'Quiz d''entraînement (12 questions) sur les KPI et l''analyse financière.',
    'entrainement',
    NULL,
    70
  )
  RETURNING id INTO v_quiz;

  -- Liaison quiz <-> banque (uniquement les QCM)
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch13:qcm:%';

  RAISE NOTICE '✓ Module Ch13 importé.';
END $ch13_v4$;
