-- =====================================================================
-- GOTRM — Chapitre 10 : Encadrer une équipe de conducteurs
-- Source : LIVRET_PRO_CCP1_GOTRM V2.pdf (pages 37-41)
-- Idempotent : suppression / réinsertion module + question_bank ch10
-- =====================================================================

DO $ch10_v4$
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
  DELETE FROM public.modules WHERE slug = 'gotrm-ch10-encadrer-conducteurs';
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch10:%';

  -- Module
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Chapitre 10 — Encadrer une équipe de conducteurs',
    'gotrm-ch10-encadrer-conducteurs',
    v_bloc,
    'Donner des instructions claires, élaborer un plan de marche conforme à la RSE, analyser les relevés tachygraphe, identifier les infractions et préparer les éléments de paie des conducteurs.',
    'avance',
    75,
    100
  )
  RETURNING id INTO v_module;

  -- Liaison formation_modules
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 100, true)
  ON CONFLICT DO NOTHING;

  -- Leçon (markdown intégral PDF)
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module,
    'Encadrer une équipe de conducteurs',
    'encadrer-conducteurs',
    1,
    75,
$lesson$
# Chapitre 10 — Encadrer une équipe de conducteurs

Le gestionnaire est le premier interlocuteur quotidien des conducteurs. Au-delà de la dimension administrative et réglementaire, il a un véritable rôle d’encadrement opérationnel qui implique de donner des instructions claires, de planifier les missions en respectant la RSE, de contrôler les relevés tachygraphe et de veiller à la préparation correcte des éléments de paie.

---

## 10.1 — Donner des instructions claires et conformes

> **REGLEMENTATION**
>
> Une instruction donnée oralement que le conducteur n’a pas bien comprise est une **instruction non transmise**.
>
> Le gestionnaire doit s’assurer de la bonne compréhension en reformulant si nécessaire.
>
> Le gestionnaire engage sa **RESPONSABILITÉ PÉNALE** lorsqu’il donne des instructions qui conduisent un conducteur à commettre des infractions.

### Catégories d’instructions à transmettre

| Catégorie | Contenu des instructions |
|---|---|
| **La mission** | Heure de prise de service, adresse et heure de chargement, contact sur place, nature de la marchandise, instructions particulières, adresse et heure de livraison, contact destinataire |
| **Le véhicule** | Immatriculations tracteur et semi-remorque, équipements spéciaux, consignes de sécurité particulières |
| **Les contacts** | Numéro gestionnaire joignable à tout moment, numéros clients, procédure en cas d’aléa |
| **Les documents** | Vérification que la pochette de bord est COMPLÈTE avant le départ |

---

## 10.2 — Élaborer le plan de marche

Le plan de marche est la feuille de route détaillée du conducteur. Il permet de vérifier **AVANT** le départ que la mission est réalisable dans le respect de la RSE.

> **MÉTHODE — Élaborer un plan de marche**
>
> - **Étape 1** : Collecter les données (heure de prise de service, adresses, distances, durées manutention).
> - **Étape 2** : Calculer le temps de service total prévisionnel.
> - **Étape 3** : Vérifier la conformité RSE :
>   - Conduite journalière ≤ 9h ?
>   - Pause 45 min après 4h30 de conduite ?
>   - Temps de service total ≤ 12h ?
>   - Repos suffisant avant prise de service ?
> - **Étape 4** : Ajuster si nécessaire (décaler le départ, prévoir une étape, double équipage, sous-traitance).
> - **Étape 5** : Formaliser et transmettre l’ordre de mission.

### CAS PRATIQUE — PLAN DE MARCHE — MISSION BORDEAUX → LYON

**Mission :** Chargement à Bordeaux à 07h00 — Livraison à Lyon
**Distance :** 560 km — **Durée chargement :** 1h — **Durée déchargement :** 45 min
**Conducteur :** SANTOS R. — **Repos journalier précédent :** 11h (conforme)

**PLAN CORRIGÉ** (après correction d’une erreur de conduite continue) :

| Horaire | Activité |
|---|---|
| 06h00 | Prise de service |
| 06h00 → 07h00 | Trajet vers le lieu de chargement (1h de conduite) |
| 07h00 → 08h00 | Chargement chez l’expéditeur (1h de travail) |
| 08h00 → 12h30 | Conduite vers Lyon (4h30 — CUMUL CONDUITE : 5h30) |
| 12h30 → 13h15 | PAUSE 45 min obligatoire (dépassement 4h30 de conduite continue) |
| 13h15 → 13h45 | Conduite jusqu’au site de livraison (30 min — CUMUL CONDUITE : 6h00) |
| 13h45 → 14h30 | Déchargement (45 min) |

**VÉRIFICATION RSE :**

- Conduite totale : 1h + 4h30 + 0h30 = **6h00 ≤ 9h** → CONFORME
- Temps de service total : **8h30 ≤ 12h** → CONFORME

---

## 10.3 — Analyser les relevés de temps de service

> **MÉTHODE — Ordre de vérification d’un relevé tachygraphe**
>
> 1. **REPOS JOURNALIERS** : ≥ 11h consécutives entre deux journées ? (ou 9h si réduction — maximum 3 fois par semaine)
> 2. **TEMPS DE CONDUITE** :
>    - Pas de période continue > 4h30 sans pause de 45 min ?
>    - Conduite journalière ≤ 9h (ou 10h max 2 fois/sem.) ?
>    - Conduite hebdomadaire ≤ 56h (semaine isolée) ?
>    - Conduite bi-hebdomadaire ≤ 90h ?
> 3. **PAUSES** : 45 min (ou 15+30 dans le bon ordre) après 4h30 de conduite ?
> 4. **TEMPS DE SERVICE** : ≤ 12h journalier ?
> 5. **DOCUMENTS MANUSCRITS** : justificatifs d’absence d’activité présents ?

---

## 10.4 — Identifier les infractions et alerter la hiérarchie

| Infraction | Gravité | Conséquence possible |
|---|---|---|
| Conduite continue > 4h30 sans pause | Contravention | Amende conducteur et entreprise |
| Pause insuffisante (< 45 min) | Contravention | Amende conducteur et entreprise |
| Conduite journalière > 9h sans dérogation | Contravention | Amende |
| Conduite journalière > 10h | Délit | Amende — poursuites pénales |
| Repos journalier < 9h | Délit | Amende — poursuites pénales |
| Dépassement > 20 % de la conduite journalière | Délit grave | IMMOBILISATION immédiate du véhicule |
| Repos journalier < 6h | Délit grave | IMMOBILISATION immédiate du véhicule |

> **REGLEMENTATION — Alerte écrite obligatoire**
>
> Situations nécessitant une **ALERTE HIÉRARCHIQUE** :
> - Infraction constatée sur les relevés d’un conducteur
> - Anomalie grave lors d’un contrôle sur route (PV, immobilisation…)
> - Conducteur refusant de respecter les instructions du gestionnaire
>
> L’alerte **DOIT** être formalisée par **ÉCRIT** (mail, rapport, mémo).
> Un signalement oral seul ne constitue pas une preuve suffisante.
>
> Le gestionnaire **NE PEUT PAS** sanctionner disciplinairement un conducteur.
> Toute procédure disciplinaire relève de la direction et des ressources humaines.

---

## 10.5 — Éléments de préparation de la paie des conducteurs

Le gestionnaire n’établit pas lui-même la fiche de paie, mais il **collecte et transmet** les données nécessaires à son calcul. Cette mission requiert la maîtrise des règles de la **Convention Collective Nationale des Transports Routiers (CCNTR)**.

### Données à collecter et transmettre

| Donnée à collecter | Source | Impact sur la paie |
|---|---|---|
| Heures de service réelles | Relevés tachygraphe / TMS | Base du calcul de la rémunération |
| Heures supplémentaires | Comparaison heures réelles vs durée légale | Majoration 25 % (8 premières) puis 50 % |
| Heures de nuit (22h-05h) | Relevés tachygraphe | Majoration conventionnelle |
| Heures dimanche / jours fériés | Planning + tachygraphe | Majoration conventionnelle |
| Frais de route | Fiches de route conducteur | Non soumis aux charges sociales dans les limites URSSAF |
| Absences (maladie, AT…) | Arrêts transmis aux RH | Impact sur salaire et charges |

> **À RETENIR — Durées légales hebdomadaires selon la CCNTR**
>
> - **Grand routier** (< 6 repos à domicile/mois) : durée légale **43h** / maxi semaine isolée **56h**
> - **Conducteur courte distance** : durée légale **39h** / maxi semaine isolée **52h**
> - **Conducteur messagerie** : durée légale **35h** / maxi semaine isolée **48h**
>
> Majorations heures supplémentaires : **+25 %** pour les 8 premières heures — **+50 %** au-delà.
> Frais de route (repas, couchage) : exonérés de cotisations sociales dans les limites fixées par l’URSSAF.

### CAS PRATIQUE — CALCUL DES ÉLÉMENTS DE PAIE — GRAND ROUTIER

**Conducteur :** SANTOS R. — **Catégorie :** Grand routier — **Taux horaire brut :** 14,50 €
**Durée légale :** 43h/semaine — **Mois de 4 semaines** — **Heures réalisées :** 201h

**Calculs :**

- Heures légales du mois : **43h × 4 = 172h**
- Heures supplémentaires : **201h − 172h = 29h**
- 8 premières h sup : **8 × 14,50 € × 1,25 = 145,00 €**
- 21 h suivantes : **21 × 14,50 € × 1,50 = 456,75 €**
- Heures normales : **172h × 14,50 € = 2 494,00 €**

**ÉLÉMENTS À TRANSMETTRE AU SERVICE PAIE :**

- Salaire de base : **2 494,00 €**
- Heures supplémentaires 25 % : **145,00 €**
- Heures supplémentaires 50 % : **456,75 €**

---

## 10.6 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| Plan de marche | Feuille de route détaillée décomposant heure par heure une mission de transport |
| Conduite continue | Durée de conduite sans interruption — limitée à 4h30 |
| Pause obligatoire | 45 min (ou 15+30 min dans le bon ordre) interrompant la conduite continue |
| Infraction RSE | Non-respect des durées de conduite ou de repos imposées par le règlement CE 561/2006 |
| Immobilisation | Mesure imposée lors d’un contrôle en cas d’infraction grave |
| CCNTR | Convention Collective Nationale des Transports Routiers |
| Grand routier | Conducteur prenant moins de 6 repos journaliers à domicile par mois |
| Heures supplémentaires | Heures travaillées au-delà de la durée légale — majorées à 25 % puis 50 % |
| Frais de route | Indemnités compensant les repas et hébergements en déplacement professionnel |
$lesson$,
'Instructions, plan de marche RSE, analyse relevés, infractions, paie.'
  )
  RETURNING id INTO v_lesson;

  -- =====================================================================
  -- BANQUE DE QUESTIONS — 12 QCM + 4 QR
  -- =====================================================================
  INSERT INTO public.question_bank (
    formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation
  ) VALUES
  -- ---------------- QCM 1 (facile) ----------------
  (v_formation, v_module, 'qcm',
   'Selon l''encadré REGLEMENTATION (10.1), une instruction donnée oralement que le conducteur n''a pas bien comprise est considérée comme :',
   '[
     {"id":"a","label":"Une instruction valable, le conducteur devait demander des précisions","is_correct":false},
     {"id":"b","label":"Une instruction non transmise","is_correct":true},
     {"id":"c","label":"Une instruction provisoire en attente d''écrit","is_correct":false},
     {"id":"d","label":"Une instruction valable uniquement pour les missions courtes","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch10','livret','instructions'],
   'mft-2026-gotrm-livret:ch10:qcm:1', true,
   'Le livret précise qu''une instruction non comprise est une instruction non transmise — le gestionnaire doit reformuler.'),

  -- ---------------- QCM 2 (facile) ----------------
  (v_formation, v_module, 'qcm',
   'Dans le tableau des catégories d''instructions (10.1), à quelle catégorie appartient la vérification que la pochette de bord est COMPLÈTE avant le départ ?',
   '[
     {"id":"a","label":"La mission","is_correct":false},
     {"id":"b","label":"Le véhicule","is_correct":false},
     {"id":"c","label":"Les contacts","is_correct":false},
     {"id":"d","label":"Les documents","is_correct":true}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch10','livret','instructions'],
   'mft-2026-gotrm-livret:ch10:qcm:2', true,
   'La catégorie "Les documents" couvre la vérification de la pochette de bord avant départ.'),

  -- ---------------- QCM 3 (facile) ----------------
  (v_formation, v_module, 'qcm',
   'Selon la méthode du plan de marche (10.2), quelle est la première étape ?',
   '[
     {"id":"a","label":"Calculer le temps de service total prévisionnel","is_correct":false},
     {"id":"b","label":"Vérifier la conformité RSE","is_correct":false},
     {"id":"c","label":"Collecter les données (heure de prise de service, adresses, distances, durées manutention)","is_correct":true},
     {"id":"d","label":"Formaliser et transmettre l''ordre de mission","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch10','livret','plan-de-marche'],
   'mft-2026-gotrm-livret:ch10:qcm:3', true,
   'Étape 1 : collecter les données. Étape 2 : calculer. Étape 3 : vérifier RSE. Étape 4 : ajuster. Étape 5 : formaliser.'),

  -- ---------------- QCM 4 (facile) ----------------
  (v_formation, v_module, 'qcm',
   'Selon le tableau "À RETENIR" (10.5), quelle est la durée légale hebdomadaire d''un conducteur Grand routier selon la CCNTR ?',
   '[
     {"id":"a","label":"35h","is_correct":false},
     {"id":"b","label":"39h","is_correct":false},
     {"id":"c","label":"43h","is_correct":true},
     {"id":"d","label":"48h","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch10','livret','paie','ccntr'],
   'mft-2026-gotrm-livret:ch10:qcm:4', true,
   'CCNTR : Grand routier 43h légales / 56h max. Courte distance 39h / 52h. Messagerie 35h / 48h.'),

  -- ---------------- QCM 5 (moyen) ----------------
  (v_formation, v_module, 'qcm',
   'Dans le cas pratique Bordeaux → Lyon (10.2), quelle est la durée totale de conduite calculée et le verdict de conformité RSE ?',
   '[
     {"id":"a","label":"5h30 — non conforme (dépassement 4h30 continue)","is_correct":false},
     {"id":"b","label":"6h00 — CONFORME (≤ 9h)","is_correct":true},
     {"id":"c","label":"8h30 — non conforme (dépassement 9h journalières)","is_correct":false},
     {"id":"d","label":"4h30 — CONFORME","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch10','livret','plan-de-marche','rse'],
   'mft-2026-gotrm-livret:ch10:qcm:5', true,
   'Conduite totale = 1h + 4h30 + 0h30 = 6h00, inférieure à la limite journalière de 9h, donc CONFORME.'),

  -- ---------------- QCM 6 (moyen) ----------------
  (v_formation, v_module, 'qcm',
   'Dans le cas pratique Bordeaux → Lyon, à 12h30 le conducteur cumule 5h30 de conduite. Pourquoi une PAUSE de 45 min est-elle obligatoire à ce moment précis ?',
   '[
     {"id":"a","label":"Parce que le temps de service journalier dépasse 9h","is_correct":false},
     {"id":"b","label":"Parce que la conduite continue dépasse 4h30 sans pause","is_correct":true},
     {"id":"c","label":"Parce que le repos journalier précédent était insuffisant","is_correct":false},
     {"id":"d","label":"Parce que la convention collective impose une pause à 12h30","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch10','livret','rse','pause'],
   'mft-2026-gotrm-livret:ch10:qcm:6', true,
   'La règle RSE impose une pause de 45 min après 4h30 de conduite continue. À 12h30, le conducteur a roulé 4h30 d''affilée (08h00→12h30).'),

  -- ---------------- QCM 7 (moyen) ----------------
  (v_formation, v_module, 'qcm',
   'Selon la méthode d''analyse d''un relevé tachygraphe (10.3), quel est le premier point à vérifier ?',
   '[
     {"id":"a","label":"Le temps de conduite continue","is_correct":false},
     {"id":"b","label":"Les pauses 45 min","is_correct":false},
     {"id":"c","label":"Les repos journaliers (≥ 11h consécutives, ou 9h max 3 fois/semaine)","is_correct":true},
     {"id":"d","label":"Les documents manuscrits justifiant les absences d''activité","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch10','livret','tachygraphe'],
   'mft-2026-gotrm-livret:ch10:qcm:7', true,
   'Ordre méthodique : 1. Repos journaliers — 2. Temps de conduite — 3. Pauses — 4. Temps de service — 5. Documents manuscrits.'),

  -- ---------------- QCM 8 (moyen) ----------------
  (v_formation, v_module, 'qcm',
   'Selon le tableau des infractions (10.4), une conduite journalière supérieure à 10h est qualifiée de :',
   '[
     {"id":"a","label":"Contravention — simple amende","is_correct":false},
     {"id":"b","label":"Délit — amende et poursuites pénales","is_correct":true},
     {"id":"c","label":"Délit grave — immobilisation immédiate du véhicule","is_correct":false},
     {"id":"d","label":"Manquement administratif sans sanction pénale","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch10','livret','infractions'],
   'mft-2026-gotrm-livret:ch10:qcm:8', true,
   'Conduite > 10h = délit. Dépassement > 20 % de la conduite journalière OU repos < 6h = délit grave (immobilisation).'),

  -- ---------------- QCM 9 (moyen) ----------------
  (v_formation, v_module, 'qcm',
   'Selon le tableau des infractions (10.4), quelles sont les deux infractions qualifiées de "délit grave" entraînant une IMMOBILISATION immédiate du véhicule ?',
   '[
     {"id":"a","label":"Conduite > 4h30 sans pause et pause < 45 min","is_correct":false},
     {"id":"b","label":"Conduite journalière > 9h et repos journalier < 9h","is_correct":false},
     {"id":"c","label":"Dépassement > 20 % de la conduite journalière et repos journalier < 6h","is_correct":true},
     {"id":"d","label":"Conduite journalière > 10h et conduite hebdomadaire > 56h","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch10','livret','infractions'],
   'mft-2026-gotrm-livret:ch10:qcm:9', true,
   'Seuls le dépassement > 20 % de la conduite journalière et le repos journalier < 6h sont qualifiés de délit grave avec immobilisation immédiate.'),

  -- ---------------- QCM 10 (difficile) ----------------
  (v_formation, v_module, 'qcm',
   'Selon l''encadré REGLEMENTATION (10.4) sur l''alerte hiérarchique, quelle affirmation est correcte ?',
   '[
     {"id":"a","label":"Un signalement oral au directeur suffit comme preuve","is_correct":false},
     {"id":"b","label":"L''alerte doit être formalisée par écrit (mail, rapport, mémo) et le gestionnaire ne peut pas sanctionner disciplinairement","is_correct":true},
     {"id":"c","label":"Le gestionnaire peut sanctionner directement le conducteur en cas d''infraction grave","is_correct":false},
     {"id":"d","label":"L''alerte écrite n''est obligatoire qu''en cas d''immobilisation du véhicule","is_correct":false}
   ]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch10','livret','alerte','rh'],
   'mft-2026-gotrm-livret:ch10:qcm:10', true,
   'L''alerte DOIT être écrite. Le gestionnaire NE PEUT PAS sanctionner ; toute procédure disciplinaire relève de la direction et des RH.'),

  -- ---------------- QCM 11 (difficile) ----------------
  (v_formation, v_module, 'qcm',
   'Cas pratique paie Grand routier (10.5) : conducteur 14,50 €/h, mois de 4 semaines, durée légale 43h/sem, 201h réalisées. Combien d''heures supplémentaires sont calculées et comment se répartissent-elles ?',
   '[
     {"id":"a","label":"36h sup : 8h × 25 % + 28h × 50 %","is_correct":false},
     {"id":"b","label":"29h sup : 8h × 25 % (145,00 €) + 21h × 50 % (456,75 €)","is_correct":true},
     {"id":"c","label":"29h sup toutes majorées à 50 %","is_correct":false},
     {"id":"d","label":"45h sup : 8h × 25 % + 37h × 50 %","is_correct":false}
   ]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch10','livret','paie','heures-supplementaires'],
   'mft-2026-gotrm-livret:ch10:qcm:11', true,
   'Heures légales = 43 × 4 = 172h. Heures sup = 201 − 172 = 29h. 8 premières × 14,50 × 1,25 = 145,00 €. 21 suivantes × 14,50 × 1,50 = 456,75 €.'),

  -- ---------------- QCM 12 (difficile) ----------------
  (v_formation, v_module, 'qcm',
   'Concernant la responsabilité du gestionnaire (10.1) et les frais de route (10.5), quelle combinaison est correcte ?',
   '[
     {"id":"a","label":"Le gestionnaire engage uniquement sa responsabilité civile ; les frais de route sont soumis aux charges sociales","is_correct":false},
     {"id":"b","label":"Le gestionnaire engage sa responsabilité PÉNALE quand ses instructions conduisent à des infractions ; les frais de route sont exonérés de cotisations sociales dans les limites URSSAF","is_correct":true},
     {"id":"c","label":"Le gestionnaire n''engage aucune responsabilité personnelle ; les frais de route sont toujours imposables","is_correct":false},
     {"id":"d","label":"Le gestionnaire engage sa responsabilité pénale ; les frais de route sont exonérés sans limite","is_correct":false}
   ]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch10','livret','responsabilite','urssaf'],
   'mft-2026-gotrm-livret:ch10:qcm:12', true,
   'Encadré 10.1 : responsabilité PÉNALE pour instructions à risque. Tableau 10.5 : frais de route non soumis aux charges sociales DANS LES LIMITES URSSAF.'),

  -- ---------------- QR 1 (cas pratique plan de marche) ----------------
  (v_formation, v_module, 'qr',
   'Dans le cas pratique Bordeaux → Lyon, expliquez en détail la séquence horaire à partir de 12h30 jusqu''à la fin de la mission, en précisant pour chaque créneau l''activité, la durée et le cumul de conduite. Concluez sur la conformité RSE (conduite totale et temps de service total).',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch10','livret','plan-de-marche','cas-pratique'],
   'mft-2026-gotrm-livret:ch10:qr:1', true,
   'Réponse attendue : 12h30 → 13h15 PAUSE 45 min obligatoire (dépassement 4h30 conduite continue). 13h15 → 13h45 conduite vers le site de livraison (30 min, cumul conduite 6h00). 13h45 → 14h30 déchargement (45 min). Conduite totale : 1h + 4h30 + 0h30 = 6h00 ≤ 9h → CONFORME. Temps de service total : 8h30 ≤ 12h → CONFORME.'),

  -- ---------------- QR 2 (méthode tachygraphe) ----------------
  (v_formation, v_module, 'qr',
   'Énumérez dans l''ordre les 5 points de vérification d''un relevé tachygraphe (10.3) en précisant pour chaque point les seuils ou critères clés à contrôler.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch10','livret','tachygraphe','methode'],
   'mft-2026-gotrm-livret:ch10:qr:2', true,
   '1. Repos journaliers : ≥ 11h consécutives (ou 9h max 3 fois/semaine). 2. Temps de conduite : pas de continue > 4h30 sans pause, journalière ≤ 9h (10h max 2 fois/sem), hebdo ≤ 56h, bi-hebdo ≤ 90h. 3. Pauses : 45 min (ou 15+30 dans le bon ordre) après 4h30. 4. Temps de service ≤ 12h journalier. 5. Documents manuscrits : justificatifs d''absence d''activité présents.'),

  -- ---------------- QR 3 (cas pratique paie) ----------------
  (v_formation, v_module, 'qr',
   'Cas pratique paie Grand routier (10.5) : SANTOS R., taux horaire brut 14,50 €, durée légale 43h/sem, mois de 4 semaines, 201h réalisées. Détaillez tous les calculs (heures légales, heures sup 25 %, heures sup 50 %, heures normales) et listez les éléments à transmettre au service paie.',
   NULL,
   6, 'difficile', ARRAY['gotrm','ch10','livret','paie','cas-pratique'],
   'mft-2026-gotrm-livret:ch10:qr:3', true,
   'Heures légales du mois : 43h × 4 = 172h. Heures sup : 201h − 172h = 29h. 8 premières h sup : 8 × 14,50 € × 1,25 = 145,00 €. 21 h suivantes : 21 × 14,50 € × 1,50 = 456,75 €. Heures normales : 172h × 14,50 € = 2 494,00 €. Éléments à transmettre : Salaire de base 2 494,00 € + H. sup 25 % 145,00 € + H. sup 50 % 456,75 €.'),

  -- ---------------- QR 4 (alerte hiérarchique) ----------------
  (v_formation, v_module, 'qr',
   'Citez les trois situations imposant une ALERTE HIÉRARCHIQUE selon l''encadré REGLEMENTATION (10.4), précisez la forme obligatoire de cette alerte, et indiquez la limite des pouvoirs disciplinaires du gestionnaire.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch10','livret','alerte','rh'],
   'mft-2026-gotrm-livret:ch10:qr:4', true,
   'Trois situations : 1) infraction constatée sur les relevés d''un conducteur, 2) anomalie grave lors d''un contrôle sur route (PV, immobilisation), 3) conducteur refusant de respecter les instructions du gestionnaire. Forme obligatoire : ÉCRITE (mail, rapport, mémo) — un signalement oral seul ne constitue pas une preuve suffisante. Limite : le gestionnaire NE PEUT PAS sanctionner disciplinairement ; toute procédure disciplinaire relève de la direction et des ressources humaines.');

  -- =====================================================================
  -- QUIZ D''ENTRAÎNEMENT — 12 QCM
  -- =====================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Chapitre 10 — Quiz d''entraînement',
    'Quiz d''entraînement (12 questions) sur l''encadrement d''une équipe de conducteurs.',
    'entrainement',
    NULL,
    70
  )
  RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch10:qcm:%';

  RAISE NOTICE '✓ Module Ch10 importé.';
END $ch10_v4$;
