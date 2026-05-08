-- =====================================================================
-- GOTRM — Chapitre 9 : La réglementation sociale européenne (RSE)
-- Source : LIVRET_PRO_CCP1_GOTRM V2.pdf — pages 32 à 36
-- Idempotent : DELETE puis INSERT
-- =====================================================================

DO $ch09_v4$
DECLARE
  v_formation uuid;
  v_bloc      int;
  v_module    uuid;
  v_lesson    uuid;
  v_quiz      uuid;
BEGIN
  -- 1) Formation
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable.';
  END IF;

  -- 2) Bloc BC1 (générique)
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
  DELETE FROM public.modules WHERE slug = 'gotrm-ch09-rse-conducteurs';
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch09:%';

  -- 4) Module
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Chapitre 9 — La réglementation sociale européenne (RSE)',
    'gotrm-ch09-rse-conducteurs',
    v_bloc,
    'Maîtriser la RSE (règlement CE 561/2006) : temps de conduite, pauses, repos journaliers et hebdomadaires, temps de service, fonctionnement du tachygraphe et qualifications conducteurs (FIMO, FCO, CQC, ADR).',
    'avance',
    80,
    90
  )
  RETURNING id INTO v_module;

  -- 5) Lien formation_modules
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 90, true)
  ON CONFLICT DO NOTHING;

  -- 6) Leçon
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module,
    'La réglementation sociale européenne (RSE)',
    'rse-conducteurs',
    1,
    80,
$lesson$
# Chapitre 9 — La réglementation sociale européenne (RSE)

La réglementation sociale européenne (RSE) est l'ensemble des règles qui fixent les durées maximales de conduite et les temps de repos obligatoires pour les conducteurs de véhicules de transport de marchandises de plus de 3,5 tonnes dans toute l'Union Européenne. Elle est définie par le **règlement européen CE 561/2006**. Sa maîtrise est indispensable pour le gestionnaire, car il a l'obligation légale de planifier et contrôler les missions dans le respect de ces règles.

> **À RETENIR**
>
> La RSE sert deux objectifs fondamentaux :
> - **LA SÉCURITÉ ROUTIÈRE** : un conducteur fatigué est un danger pour lui-même et pour tous les usagers de la route.
> - **L'ÉQUITÉ DE LA CONCURRENCE** : des règles communes empêchent les entreprises de gagner des marchés en faisant travailler leurs conducteurs dans des conditions illégales.

---

## 9.1 — Les définitions fondamentales

| Terme RSE | Définition précise |
|---|---|
| La journée | Intervalle de temps au plus égal à 24 heures entre deux repos journaliers |
| La semaine | Intervalle courant du lundi 0h00 au dimanche 24h00 |
| La conduite | Activité de conduite d'un véhicule à moteur enregistrée par le tachygraphe |
| La pause | Période pendant laquelle le conducteur NE PEUT NI conduire NI effectuer d'autres tâches |
| Le repos | Toute période pendant laquelle le conducteur peut disposer librement de son temps |
| La disponibilité | Attente à l'arrêt — le conducteur reste à disposition sans conduire ni travailler activement |
| Les autres tâches | Tout sauf la conduite : chargement, déchargement, tâches administratives, nettoyage |
| Le temps de service | Conduite + autres tâches + disponibilité — N'inclut PAS les pauses et les repos |
| L'amplitude | Durée totale entre l'heure de prise de service et l'heure de fin de service |

---

## 9.2 — Les temps de conduite

> **REGLEMENTATION**
>
> **CONDUITE CONTINUE MAXIMALE : 4h30**
> - Pause obligatoire de 45 minutes
> - Fractionnement autorisé : 15 min + 30 min (dans cet ordre — JAMAIS l'inverse)
>
> **CONDUITE JOURNALIÈRE MAXIMALE : 9 heures**
> - Extensible à 10 heures, mais 2 fois par semaine MAXIMUM
>
> **CONDUITE HEBDOMADAIRE MAXIMALE : 56 heures** (semaine isolée)
> **CONDUITE BI-HEBDOMADAIRE MAXIMALE : 90 heures** (sur 2 semaines consécutives)
>
> **NOMBRE DE JOURS DE CONDUITE CONSÉCUTIFS MAXIMUM : 6 jours**

---

## 9.3 — Les temps de repos

| Type de repos | Durée minimale | Conditions |
|---|---|---|
| Repos journalier normal | 11 heures consécutives | Par période de 24 heures |
| Repos journalier réduit | 9 heures consécutives | 3 fois MAXIMUM par semaine — compensation obligatoire |
| Repos journalier fractionné | 3 heures + 9 heures | Dans cet ordre uniquement — total : 12 heures |
| Repos journalier double équipage | 9 heures consécutives | Par période de 30 heures |
| Repos hebdomadaire normal | 45 heures consécutives | Par semaine calendaire (lundi-dimanche) |
| Repos hebdomadaire réduit | 24 heures consécutives | 1 semaine sur 2 MAXIMUM (transport national) |

> **REGLEMENTATION**
>
> INTERDIT de prendre le repos hebdomadaire NORMAL à bord du véhicule.
>
> Compensation d'un repos hebdomadaire réduit : elle doit être prise en bloc, rattachée à un repos d'au moins 9h, avant la fin de la 3e semaine suivant la semaine concernée.

---

## 9.4 — Le temps de service

> **À RETENIR**
>
> **Temps de service maximum journalier : 12 heures**
> (10 heures si le conducteur travaille de nuit — entre 22h et 5h)
>
> **Durées hebdomadaires légales selon la catégorie :**
> - **Grand routier** (< 6 repos à domicile par mois) : durée légale 43h / maxi semaine isolée 56h
> - **Conducteur courte distance** : durée légale 39h / maxi semaine isolée 52h
> - **Conducteur messagerie** : durée légale 35h / maxi semaine isolée 48h
>
> **Pauses interrompant le travail continu :**
> - Après 6h de travail continu : pause de 30 minutes
> - Après 9h de travail continu : pause de 45 minutes

---

## 9.5 — Tableau de synthèse RSE

| Règle | Durée / Limite |
|---|---|
| Conduite continue maximum | 4h30 |
| Pause après conduite continue | 45 min (ou 15+30 min dans cet ordre) |
| Conduite journalière maximum | 9h (extensible 10h, 2 fois/semaine maximum) |
| Conduite hebdomadaire maximum | 56h (semaine isolée) / 90h (2 semaines) |
| Jours de conduite consécutifs maximum | 6 jours |
| Repos journalier normal | 11h consécutives |
| Repos journalier réduit | 9h — 3 fois maximum par semaine |
| Repos journalier fractionné | 3h + 9h (dans cet ordre) |
| Repos hebdomadaire normal | 45h consécutives |
| Repos hebdomadaire réduit | 24h — 1 semaine sur 2 maximum (national) |
| Temps de service journalier maximum | 12h (10h si travail de nuit) |

---

## 9.6 — Le tachygraphe

Le chronotachygraphe est l'appareil enregistreur obligatoire sur tous les véhicules de transport de marchandises de plus de 3,5 tonnes. Il enregistre en permanence l'activité du conducteur (conduite, travail, disponibilité, repos), la vitesse du véhicule et les données de position.

| Type | Fonctionnement | Statut |
|---|---|---|
| Tachygraphe numérique | Lit une carte conducteur à puce — édite des tickets imprimés | Obligatoire sur les véhicules neufs depuis 2006 |
| Tachygraphe analogique (disque) | Enregistrement sur disque en celluloïd | En voie de disparition — véhicules anciens uniquement |

> **REGLEMENTATION**
>
> **Contrôles sur route** : le conducteur doit présenter les enregistrements de la journée en cours et les données des **56 jours précédents**.
>
> **Conservation en entreprise** : 1 an minimum — à disposition des agents de contrôle (DREAL, inspection du travail).
>
> Utilisation de la carte d'un autre conducteur ou falsification des données : **infraction pénale grave**.
>
> Obligation de présenter les données sur demande des forces de l'ordre.

---

## 9.7 — Les qualifications et formations des conducteurs

| Qualification | Description | Durée / Périodicité |
|---|---|---|
| Permis C | Poids lourds isolés (porteurs) > 3,5 t | Renouvellement 5 ans (< 60 ans), 2 ans (60-75 ans) |
| Permis CE | Ensemble articulé (tracteur + semi > 750 kg) | Même périodicité |
| FIMO | Formation Initiale Minimale Obligatoire | 140 heures — obtenue une seule fois |
| FCO | Formation Continue Obligatoire | 35 heures tous les 5 ans — financement entreprise |
| CQC | Carte de Qualification Conducteur | Délivrée après FIMO ou FCO — renouvellement 5 ans |
| Certificat ADR | Transport de matières dangereuses | Valable 5 ans — formations de spécialisation par classe |

---

## 9.8 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| RSE | Réglementation Sociale Européenne — règlement CE 561/2006 |
| Temps de service | Conduite + autres tâches + disponibilité — exclut pauses et repos |
| Amplitude | Durée entre prise de service et fin de service |
| Pause | Période obligatoire interrompant la conduite continue — ne compte pas dans le repos |
| Repos journalier normal | 11h consécutives — entre deux journées de travail |
| Repos hebdomadaire normal | 45h consécutives — par semaine calendaire |
| Double équipage | Deux conducteurs dans le même véhicule se relayant à la conduite |
| Grand routier | Conducteur prenant moins de 6 repos journaliers à domicile par mois |
| ADR | Accord pour le transport de marchandises Dangereuses par la Route |
$lesson$,
'RSE règlement CE 561/2006 : conduite (4h30/9h/56h/90h), pauses (45 min ou 15+30), repos journalier (11h/9h) et hebdomadaire (45h/24h), temps de service (12h), tachygraphe et qualifications (FIMO 140h, FCO 35h/5 ans, CQC, ADR).'
  )
  RETURNING id INTO v_lesson;

  -- 7) Banque de questions : 12 QCM + 4 QR
  INSERT INTO public.question_bank (
    formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation
  ) VALUES

  -- ============== QCM 1 — facile ==============
  (v_formation, v_module, 'qcm',
   'Quel règlement européen définit la réglementation sociale européenne (RSE) applicable au transport de marchandises ?',
   '[
     {"id":"a","label":"Règlement CE 561/2006","is_correct":true},
     {"id":"b","label":"Règlement CE 1071/2009","is_correct":false},
     {"id":"c","label":"Règlement CE 1072/2009","is_correct":false},
     {"id":"d","label":"Directive 2003/59/CE","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch09','livret','rse'],
   'mft-2026-gotrm-livret:ch09:qcm:1', true,
   'La RSE est définie par le règlement européen CE 561/2006, applicable aux véhicules de transport de marchandises de plus de 3,5 tonnes dans toute l''Union Européenne.'),

  -- ============== QCM 2 — facile ==============
  (v_formation, v_module, 'qcm',
   'Quelle est la durée maximale de conduite continue avant pause obligatoire ?',
   '[
     {"id":"a","label":"4 heures","is_correct":false},
     {"id":"b","label":"4 heures 30","is_correct":true},
     {"id":"c","label":"5 heures","is_correct":false},
     {"id":"d","label":"6 heures","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch09','livret','conduite'],
   'mft-2026-gotrm-livret:ch09:qcm:2', true,
   'La conduite continue maximale est de 4h30, suivie d''une pause obligatoire de 45 minutes (fractionnable en 15 min + 30 min, dans cet ordre).'),

  -- ============== QCM 3 — facile ==============
  (v_formation, v_module, 'qcm',
   'Quelle est la durée minimale du repos journalier normal ?',
   '[
     {"id":"a","label":"9 heures consécutives","is_correct":false},
     {"id":"b","label":"10 heures consécutives","is_correct":false},
     {"id":"c","label":"11 heures consécutives","is_correct":true},
     {"id":"d","label":"12 heures consécutives","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch09','livret','repos'],
   'mft-2026-gotrm-livret:ch09:qcm:3', true,
   'Le repos journalier normal est de 11 heures consécutives par période de 24 heures.'),

  -- ============== QCM 4 — facile ==============
  (v_formation, v_module, 'qcm',
   'Combien d''heures dure la formation FIMO (Formation Initiale Minimale Obligatoire) ?',
   '[
     {"id":"a","label":"35 heures","is_correct":false},
     {"id":"b","label":"70 heures","is_correct":false},
     {"id":"c","label":"105 heures","is_correct":false},
     {"id":"d","label":"140 heures","is_correct":true}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch09','livret','fimo'],
   'mft-2026-gotrm-livret:ch09:qcm:4', true,
   'La FIMO dure 140 heures et n''est obtenue qu''une seule fois. Elle est complétée ensuite par la FCO (35h tous les 5 ans).'),

  -- ============== QCM 5 — moyen ==============
  (v_formation, v_module, 'qcm',
   'La conduite journalière peut être étendue de 9h à 10h. À quelle fréquence maximum cette extension est-elle autorisée ?',
   '[
     {"id":"a","label":"1 fois par semaine maximum","is_correct":false},
     {"id":"b","label":"2 fois par semaine maximum","is_correct":true},
     {"id":"c","label":"3 fois par semaine maximum","is_correct":false},
     {"id":"d","label":"Sans limite","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch09','livret','conduite'],
   'mft-2026-gotrm-livret:ch09:qcm:5', true,
   'La conduite journalière de 9h peut être portée à 10h, mais 2 fois par semaine MAXIMUM.'),

  -- ============== QCM 6 — moyen ==============
  (v_formation, v_module, 'qcm',
   'Quelles sont les limites de conduite hebdomadaire et bi-hebdomadaire selon la RSE ?',
   '[
     {"id":"a","label":"48h par semaine / 80h sur 2 semaines","is_correct":false},
     {"id":"b","label":"56h par semaine / 90h sur 2 semaines","is_correct":true},
     {"id":"c","label":"60h par semaine / 100h sur 2 semaines","is_correct":false},
     {"id":"d","label":"45h par semaine / 90h sur 2 semaines","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch09','livret','conduite'],
   'mft-2026-gotrm-livret:ch09:qcm:6', true,
   'Conduite hebdomadaire maximale : 56h (semaine isolée). Conduite bi-hebdomadaire maximale : 90h sur 2 semaines consécutives.'),

  -- ============== QCM 7 — moyen ==============
  (v_formation, v_module, 'qcm',
   'Quelle est la règle pour le fractionnement de la pause de 45 minutes après 4h30 de conduite continue ?',
   '[
     {"id":"a","label":"15 min + 30 min, dans cet ordre uniquement","is_correct":true},
     {"id":"b","label":"30 min + 15 min, dans cet ordre uniquement","is_correct":false},
     {"id":"c","label":"3 x 15 min, à répartir librement","is_correct":false},
     {"id":"d","label":"15 min + 15 min + 15 min, dans cet ordre","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch09','livret','pause'],
   'mft-2026-gotrm-livret:ch09:qcm:7', true,
   'Le fractionnement autorisé est 15 min + 30 min, JAMAIS l''inverse. L''ordre est strict.'),

  -- ============== QCM 8 — moyen ==============
  (v_formation, v_module, 'qcm',
   'Que comprend le « temps de service » au sens de la RSE ?',
   '[
     {"id":"a","label":"Conduite + autres tâches + disponibilité — pauses et repos exclus","is_correct":true},
     {"id":"b","label":"Conduite uniquement","is_correct":false},
     {"id":"c","label":"Conduite + pauses + repos","is_correct":false},
     {"id":"d","label":"Toute la durée entre prise et fin de service (amplitude)","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch09','livret','temps-service'],
   'mft-2026-gotrm-livret:ch09:qcm:8', true,
   'Le temps de service = conduite + autres tâches + disponibilité. Il N''INCLUT PAS les pauses et les repos. À ne pas confondre avec l''amplitude (durée totale prise–fin de service).'),

  -- ============== QCM 9 — moyen ==============
  (v_formation, v_module, 'qcm',
   'Quelle est la durée du repos hebdomadaire réduit, et à quelle fréquence est-il autorisé ?',
   '[
     {"id":"a","label":"24h consécutives, 1 semaine sur 2 maximum (transport national)","is_correct":true},
     {"id":"b","label":"36h consécutives, chaque semaine","is_correct":false},
     {"id":"c","label":"24h consécutives, sans limite de fréquence","is_correct":false},
     {"id":"d","label":"45h consécutives, 1 semaine sur 2 maximum","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch09','livret','repos-hebdo'],
   'mft-2026-gotrm-livret:ch09:qcm:9', true,
   'Le repos hebdomadaire réduit est de 24h consécutives, autorisé 1 semaine sur 2 maximum en transport national. Il doit être compensé.'),

  -- ============== QCM 10 — difficile ==============
  (v_formation, v_module, 'qcm',
   'Lors d''un contrôle sur route, quelle profondeur de données le conducteur doit-il pouvoir présenter ?',
   '[
     {"id":"a","label":"Les 7 jours précédents","is_correct":false},
     {"id":"b","label":"Les 28 jours précédents","is_correct":false},
     {"id":"c","label":"Les 56 jours précédents (en plus de la journée en cours)","is_correct":true},
     {"id":"d","label":"Les 90 jours précédents","is_correct":false}
   ]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch09','livret','tachygraphe','controle'],
   'mft-2026-gotrm-livret:ch09:qcm:10', true,
   'Le conducteur doit présenter les enregistrements de la journée en cours et les données des 56 jours précédents. La conservation en entreprise est de 1 an minimum.'),

  -- ============== QCM 11 — difficile ==============
  (v_formation, v_module, 'qcm',
   'En double équipage, quelle est la durée minimale du repos journalier et sur quelle période ?',
   '[
     {"id":"a","label":"11 heures par période de 24 heures","is_correct":false},
     {"id":"b","label":"9 heures consécutives par période de 30 heures","is_correct":true},
     {"id":"c","label":"9 heures par période de 24 heures","is_correct":false},
     {"id":"d","label":"3h + 9h par période de 30 heures","is_correct":false}
   ]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch09','livret','double-equipage'],
   'mft-2026-gotrm-livret:ch09:qcm:11', true,
   'En double équipage, le repos journalier est de 9 heures consécutives par période de 30 heures (et non 24h comme en équipage simple).'),

  -- ============== QCM 12 — difficile ==============
  (v_formation, v_module, 'qcm',
   'Pour un conducteur « grand routier » (< 6 repos à domicile par mois), quelle est la durée légale hebdomadaire de service et le maximum sur une semaine isolée ?',
   '[
     {"id":"a","label":"35h légales / maxi 48h","is_correct":false},
     {"id":"b","label":"39h légales / maxi 52h","is_correct":false},
     {"id":"c","label":"43h légales / maxi 56h","is_correct":true},
     {"id":"d","label":"45h légales / maxi 60h","is_correct":false}
   ]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch09','livret','grand-routier'],
   'mft-2026-gotrm-livret:ch09:qcm:12', true,
   'Grand routier : durée légale 43h / maxi semaine isolée 56h. Courte distance : 39h / 52h. Messagerie : 35h / 48h.'),

  -- ============== QR 1 ==============
  (v_formation, v_module, 'qr',
   'Un conducteur a effectué cette semaine : lundi 9h, mardi 10h, mercredi 9h, jeudi 10h, vendredi 9h. Il vous demande s''il peut conduire 9h samedi. Justifiez votre réponse en citant deux règles.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch09','livret','cas-pratique','conduite'],
   'mft-2026-gotrm-livret:ch09:qr:1', true,
   'Réponse : OUI, mais avec vigilance. Cumul conduite : 9+10+9+10+9 = 47h, donc samedi 9h porte le total à 56h, soit la limite hebdomadaire MAXIMALE (semaine isolée). Règle 1 : 56h hebdo maximum atteintes — aucun dépassement possible. Règle 2 : il a déjà utilisé ses 2 extensions à 10h autorisées par semaine (mardi et jeudi), donc samedi est limité à 9h. Règle 3 (à mentionner) : 6 jours de conduite consécutifs maximum — samedi est le 6e jour, dimanche sera obligatoirement repos.'),

  -- ============== QR 2 ==============
  (v_formation, v_module, 'qr',
   'Expliquez la différence entre « pause », « repos » et « disponibilité » au sens de la RSE, et précisez si chacune compte ou non dans le temps de service.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch09','livret','cas-pratique','definitions'],
   'mft-2026-gotrm-livret:ch09:qr:2', true,
   'PAUSE : période pendant laquelle le conducteur NE PEUT NI conduire NI effectuer d''autres tâches. NE compte PAS dans le temps de service. REPOS : toute période pendant laquelle le conducteur peut disposer librement de son temps. NE compte PAS dans le temps de service. DISPONIBILITÉ : attente à l''arrêt — le conducteur reste à disposition sans conduire ni travailler activement (ex : attente chargement). COMPTE dans le temps de service. Le temps de service = conduite + autres tâches + disponibilité (pauses et repos exclus).'),

  -- ============== QR 3 ==============
  (v_formation, v_module, 'qr',
   'Un conducteur a pris un repos hebdomadaire réduit de 24h en semaine 12. Quelles sont vos obligations en tant que gestionnaire concernant la compensation ? Donnez les règles précises.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch09','livret','cas-pratique','compensation'],
   'mft-2026-gotrm-livret:ch09:qr:3', true,
   'Obligations : (1) Calculer la compensation due = 45h (normal) - 24h (réduit pris) = 21h à compenser. (2) La compensation doit être prise EN BLOC (pas fractionnée). (3) Elle doit être rattachée à un repos d''au moins 9h. (4) Délai : avant la fin de la 3e semaine SUIVANT la semaine concernée — donc avant la fin de la semaine 15. (5) Vérifier qu''on respecte la règle « 1 semaine sur 2 maximum » en transport national : la semaine suivante doit comporter un repos hebdomadaire normal de 45h. (6) Rappeler : INTERDIT de prendre le repos hebdomadaire normal à bord du véhicule.'),

  -- ============== QR 4 ==============
  (v_formation, v_module, 'qr',
   'Citez les six qualifications/formations principales d''un conducteur poids lourd, leur objet et leur périodicité de renouvellement.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch09','livret','cas-pratique','qualifications'],
   'mft-2026-gotrm-livret:ch09:qr:4', true,
   '(1) PERMIS C : poids lourds isolés (porteurs) > 3,5 t — renouvellement 5 ans (< 60 ans), 2 ans (60-75 ans). (2) PERMIS CE : ensemble articulé (tracteur + semi > 750 kg) — même périodicité. (3) FIMO : Formation Initiale Minimale Obligatoire — 140h, obtenue une seule fois. (4) FCO : Formation Continue Obligatoire — 35h tous les 5 ans, financée par l''entreprise. (5) CQC : Carte de Qualification Conducteur — délivrée après FIMO ou FCO, renouvellement 5 ans. (6) CERTIFICAT ADR : transport de matières dangereuses — valable 5 ans, formations de spécialisation par classe de marchandise.');

  -- 8) Quiz d'entraînement
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Chapitre 9 — Quiz d''entraînement',
    'Quiz d''entraînement (12 questions) sur la réglementation sociale européenne (RSE) : temps de conduite, repos, tachygraphe et qualifications conducteurs.',
    'entrainement',
    NULL,
    70
  )
  RETURNING id INTO v_quiz;

  -- 9) Liaison quiz <-> banque (QCM uniquement)
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch09:qcm:%';

  RAISE NOTICE '✓ Module Ch9 (RSE) importé : 1 leçon, 12 QCM + 4 QR, 1 quiz.';
END $ch09_v4$;
