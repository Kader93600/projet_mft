-- =====================================================================
-- CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : MODULE F : ACCÈS À LA
-- PROFESSION ET AU MARCHÉ : v1 (juillet 2026) : MODULE PILOTE
--
-- Contenu créé en l'absence des supports client, sur la base des
-- référentiels officiels :
--   - Règlement (CE) n° 1071/2009 (accès à la profession, annexe I)
--   - Règlement (CE) n° 1072/2009 (accès au marché, cabotage)
--   - Règlement (UE) 2020/1055 « paquet mobilité » (depuis 21/02/2022)
--   - Code des transports, partie 3 (L. 3211-1 s., R. 3211-1 s.)
--   - Arrêté du 28 décembre 2011 (examens attestation de capacité)
--   - Arrêté du 3 février 2012 (capacité financière)
--
-- ⚠ STATUT : TOUT le contenu question est inséré avec active = false
--   (« à valider »). Rien n'est visible des apprenants :
--   1) aucune inscription n'existe sur cette formation (vérifié le 12/07/2026)
--   2) les questions inactives sont exclues des parcours
--   La mise en production se fait via Admin > Banque de questions >
--   Validation, après relecture par le formateur.
--
-- Idempotent : DELETE ciblés par slug/source_ref puis INSERT.
--   Rejouable sans doublon (source_ref unique par question).
-- =====================================================================

DO $capaf$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid;
  v_l2 uuid;
  v_l3 uuid;
  v_l4 uuid;
  v_quiz uuid;
  v_q uuid;
  v_ord int := 0;
BEGIN
  -- ─── 1. Formation cible ─────────────────────────────────────────────
  SELECT id INTO v_formation FROM public.formations
   WHERE slug = 'capacite-plus-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-plus-3-5t introuvable dans public.formations.';
  END IF;

  -- ─── 2. Bloc dédié au lourd ─────────────────────────────────────────
  INSERT INTO public.blocs (id, code, title, description, "order")
  VALUES (30, 'CAPA-LOURD',
          'Capacité de transport lourd > 3,5 t',
          'Programme officiel de l''examen d''attestation de capacité professionnelle en transport routier lourd de marchandises (annexe I du règlement CE 1071/2009).',
          30)
  ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'CAPA-LOURD';
  IF v_bloc IS NULL THEN
    RAISE EXCEPTION 'Bloc CAPA-LOURD introuvable et non créé. Vérifie public.blocs.';
  END IF;

  -- ─── 3. Nettoyage idempotent du module pilote ──────────────────────
  DELETE FROM public.question_bank WHERE source_ref LIKE 'CAPA-LOURD-F-%';
  DELETE FROM public.modules WHERE slug = 'capa-lourd-acces-profession-marche';

  -- ─── 4. Module F ────────────────────────────────────────────────────
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module F : Accès à la profession et au marché',
    'capa-lourd-acces-profession-marche',
    v_bloc,
    'Les quatre exigences d''accès à la profession de transporteur lourd (établissement, honorabilité, capacités financière et professionnelle), le gestionnaire de transport, le registre et les licences, le transport international et le cabotage, les contrôles et sanctions.',
    'intermediaire',
    480,
    60
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 60, true);

  -- ─── 5. Leçon 1 : Les quatre exigences d'accès ─────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'quatre-exigences-acces-profession',
    'Les quatre exigences d''accès à la profession',
    $mft$> 🎯 **Objectifs**
> - Citer et expliquer les quatre exigences du règlement (CE) n° 1071/2009.
> - Chiffrer la capacité financière exigée pour une flotte lourde.
> - Définir le rôle et les limites du gestionnaire de transport.

## Pourquoi un accès réglementé ?

Le transport routier lourd de marchandises est une **profession réglementée** dans toute l'Union européenne. Nul ne peut exploiter des véhicules de plus de 3,5 tonnes pour le compte d'autrui sans y avoir été autorisé. Le socle commun est fixé par le **règlement (CE) n° 1071/2009**, complété en France par le code des transports.

L'article 3 du règlement impose **quatre exigences cumulatives** : les perdre, c'est perdre le droit d'exercer.

## 1. Un établissement stable et effectif

L'entreprise doit disposer en France de **locaux réels** où elle conserve ses documents essentiels (originaux des documents comptables, de gestion du personnel, des temps de conduite) et d'un **centre opérationnel** doté des équipements et installations techniques appropriés.

Depuis le paquet mobilité (21 février 2022), les véhicules affectés à l'international doivent **revenir au centre opérationnel au moins toutes les huit semaines**.

> ⚠️ **Attention**
> Une simple boîte aux lettres ou une domiciliation commerciale ne constitue pas un établissement. Les « sociétés boîtes aux lettres » sont précisément ce que le paquet mobilité vise à éliminer.

## 2. L'honorabilité professionnelle

Elle concerne l'entreprise, ses **dirigeants** et le **gestionnaire de transport**. Elle se perd notamment en cas de condamnations pénales graves ou répétées : infractions routières les plus graves, travail dissimulé, atteintes aux règles sociales du transport.

La perte d'honorabilité est prononcée par le **préfet de région** ; elle entraîne l'interdiction de gérer ou de diriger une entreprise de transport tant qu'elle n'est pas recouvrée.

## 3. La capacité financière

L'entreprise doit prouver chaque année qu'elle dispose de **capitaux et réserves suffisants** :

| Flotte lourde (> 3,5 t) | Montant exigé |
| --- | --- |
| Premier véhicule | 9 000 € |
| Chaque véhicule supplémentaire | 5 000 € |

Exemple : une flotte de 5 tracteurs = 9 000 + (4 × 5 000) = **29 000 €** de capacité exigée.

La preuve s'appuie sur les **capitaux propres** de la liasse fiscale, attestés par un expert-comptable ou un commissaire aux comptes. À défaut de capitaux suffisants, une **garantie bancaire ou d'assurance** peut compléter, dans la limite de la **moitié** de la capacité exigée (arrêté du 3 février 2012).

> 💡 **Astuce**
> Pour les véhicules légers utilisés à l'international (2,5 à 3,5 t), des montants réduits s'appliquent depuis le 21 mai 2022 : 1 800 € pour le premier véhicule, 900 € par véhicule suivant.

## 4. La capacité professionnelle

Au moins une personne, le **gestionnaire de transport**, doit être titulaire de l'**attestation de capacité professionnelle en transport lourd**. Trois voies d'obtention :

1. **L'examen national annuel** : épreuve écrite (QCM + questions rédigées avec exercices), organisée une fois par an.
2. **L'équivalence de diplôme** : certains diplômes dispensent d'examen (par exemple des diplômes bac +2 spécialisés en transport, liste fixée par arrêté).
3. **L'expérience** : dispense possible pour les personnes prouvant la gestion continue d'une entreprise de transport pendant dix ans avant le 4 décembre 2009 (article 9 du règlement).

## Le gestionnaire de transport

C'est la personne physique qui **dirige effectivement et en permanence** les activités de transport : entretien des véhicules, vérification des contrats et documents, comptabilité de base, affectation des chargements et des conducteurs, vérification des procédures de sécurité.

Il doit avoir un **lien réel** avec l'entreprise : salarié, directeur, propriétaire, actionnaire ou dirigeant. À défaut, l'entreprise peut recourir à un **prestataire externe** dans des limites strictes :

> 📌 **À retenir**
> Un gestionnaire externe ne peut piloter que **4 entreprises au maximum**, avec une **flotte cumulée de 50 véhicules**. Un gestionnaire interne salarié peut, lui, exercer pour l'entreprise sans plafond de flotte.

## ✅ Synthèse

- Quatre exigences cumulatives : **établissement, honorabilité, capacité financière, capacité professionnelle**.
- Capacité financière lourd : **9 000 € / 5 000 €** ; garantie possible pour moitié au plus.
- Le **gestionnaire de transport** porte la capacité professionnelle et dirige effectivement l'activité.
- Retour des véhicules internationaux au centre opérationnel **toutes les 8 semaines**.$mft$,
    $mft$Les quatre exigences cumulatives d'accès à la profession (règlement CE 1071/2009), les montants de capacité financière du lourd et le statut du gestionnaire de transport.$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── 6. Leçon 2 : Autorisation, registre et titres de transport ────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'autorisation-registre-licences',
    'Autorisation d''exercer, registre et licences',
    $mft$> 🎯 **Objectifs**
> - Décrire le parcours administratif d'entrée dans la profession.
> - Distinguer licence de transport intérieur et licence communautaire.
> - Savoir quels documents doivent se trouver à bord d'un véhicule lourd.

## Le parcours d'entrée dans la profession

:::timeline
1. **Réunir les quatre exigences** : établissement, honorabilité, capacité financière, capacité professionnelle (gestionnaire désigné).
2. **Déposer la demande d'autorisation** : dossier auprès de la DREAL de la région du siège (DRIEAT en Île-de-France, DEAL outre-mer).
3. **Inscription au registre** : l'entreprise est inscrite au registre électronique national des entreprises de transport par route.
4. **Délivrance de la licence** : licence de transport intérieur ou licence communautaire, avec ses copies conformes numérotées.
5. **Exploitation et obligations continues** : mise à jour de la flotte, signalement des changements (siège, gestionnaire), preuve annuelle de capacité financière.
:::

## Le registre électronique national

Toute entreprise autorisée figure au **registre électronique national des entreprises de transport par route**, tenu sous l'autorité des DREAL et interconnecté au niveau européen (système ERRU). Le registre mentionne notamment l'identité de l'entreprise, son gestionnaire de transport, le nombre de véhicules et les sanctions éventuelles.

> 🔍 **Focus**
> L'interconnexion européenne ERRU permet à un État membre de signaler les infractions graves commises par un transporteur d'un autre État : les sanctions suivent l'entreprise partout dans l'Union.

## Licences et copies conformes

| Titre | Champ d'utilisation | Durée |
| --- | --- | --- |
| Licence de transport intérieur | Transport national, véhicules > 3,5 t | 10 ans renouvelable |
| Licence communautaire | Transport international dans l'UE et transit | 10 ans renouvelable |

L'**original** de la licence reste au siège de l'entreprise. Chaque véhicule moteur circule avec une **copie conforme numérotée** de la licence. Le nombre de copies conformes délivrées est plafonné par la capacité financière justifiée : impossible d'exploiter plus de véhicules que la capacité ne le permet.

> ⚠️ **Attention**
> La copie conforme est attachée à l'entreprise, pas au conducteur. En cas de contrôle sans copie conforme à bord, l'entreprise s'expose à une amende et le véhicule peut être immobilisé.

## L'attestation de conducteur

Lorsqu'une entreprise établie dans l'UE emploie un conducteur **ressortissant d'un pays tiers** (hors UE), ce conducteur doit détenir une **attestation de conducteur** délivrée à l'entreprise, à présenter lors des contrôles en transport international.

## Les documents de bord du transport lourd

À bord d'un véhicule lourd en exploitation, on doit notamment trouver :

- la **copie conforme** de la licence (intérieure ou communautaire) ;
- la **lettre de voiture** (nationale ou CMR à l'international) ;
- les données du **chronotachygraphe** et la carte conducteur ;
- l'attestation de conducteur le cas échéant ;
- les documents du véhicule (certificat d'immatriculation, assurance, contrôle technique).

## ✅ Synthèse

- Autorisation délivrée par la **DREAL**, inscription au **registre électronique national**, échange européen via **ERRU**.
- **Licence intérieure** pour le national, **licence communautaire** pour l'international : 10 ans, original au siège, copie conforme numérotée à bord.
- Le plafond de copies conformes découle de la **capacité financière**.
- Conducteur de pays tiers : **attestation de conducteur** obligatoire.$mft$,
    $mft$Le parcours DREAL et le registre électronique national, la licence intérieure et la licence communautaire avec leurs copies conformes, et les documents de bord obligatoires.$mft$,
    2, 40) RETURNING id INTO v_l2;

  -- ─── 7. Leçon 3 : International et cabotage ────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'transport-international-cabotage',
    'Transport international et cabotage',
    $mft$> 🎯 **Objectifs**
> - Identifier les opérations couvertes par la licence communautaire.
> - Appliquer sans erreur les règles de cabotage (3 en 7, entrée à vide, carence).
> - Citer les preuves à conserver pour justifier un cabotage régulier.

## Le transport international sous licence communautaire

La **licence communautaire** (règlement CE 1072/2009) couvre les transports internationaux de marchandises pour compte d'autrui entre États membres : trajets **bilatéraux** (France vers Allemagne), **triangulaires** (Allemagne vers Italie par un transporteur français) et **en transit**.

## Le cabotage : définition

Le **cabotage** est un transport intérieur réalisé **dans un autre État membre** que celui d'établissement, à titre temporaire, dans la continuité d'un transport international.

:::flow
1. Transport international | Livraison complète dans l'État d'accueil
2. Cabotage autorisé | Jusqu'à 3 opérations en 7 jours
3. Retour ou nouveau transport international | Fin de la séquence de cabotage
:::

## Les règles à connaître par cœur

> 📌 **À retenir**
> - Après un transport international **à charge** entièrement livré : **3 opérations de cabotage maximum en 7 jours** dans l'État d'accueil.
> - Entrée **à vide** dans un État traversé : **1 seule opération de cabotage dans les 3 jours** suivant l'entrée, toujours dans la limite globale des 7 jours.
> - Depuis le 21 février 2022 (paquet mobilité) : **période de carence de 4 jours** avant de recommencer un cabotage avec le même véhicule dans le même État membre.

## Les preuves à conserver

Le transporteur doit pouvoir présenter des **preuves claires** du transport international préalable et de chaque cabotage : lettres de voiture **CMR**, dates de chargement et de livraison, immatriculations. Sans preuve, le cabotage est présumé irrégulier.

Exemple chiffré : un ensemble routier français livre intégralement à Munich le lundi 10 h (transport international à charge). Il peut réaliser au plus **3 cabotages en Allemagne** jusqu'au lundi suivant 10 h, dernier déchargement inclus dans les 7 jours. Il repart ensuite (international ou retour France) et ne pourra re-caboter en Allemagne avec ce véhicule qu'après **4 jours** de carence.

> ❌ **Piège à éviter**
> Le délai de 7 jours court à partir du **dernier déchargement du transport international**, pas à partir du premier cabotage. À l'examen, vérifiez toujours le point de départ du décompte.

## Détachement des conducteurs

Depuis la directive (UE) 2020/1057, le cabotage et le transport triangulaire relèvent des **règles du détachement** : rémunération du pays d'accueil et déclaration préalable via le système européen. Les transports bilatéraux en sont exemptés.

## ✅ Synthèse

- Licence communautaire = international UE ; le cabotage prolonge un international **à charge**.
- **3 cabotages / 7 jours** ; entrée à vide : **1 cabotage / 3 jours** ; carence de **4 jours** avant une nouvelle séquence dans le même État.
- Conservez les **CMR** : sans preuve, pas de cabotage régulier.
- Cabotage et triangulaire = conducteur **détaché** (rémunération du pays d'accueil).$mft$,
    $mft$La licence communautaire, les règles de cabotage 3 opérations en 7 jours, l'entrée à vide, la carence de 4 jours du paquet mobilité et les preuves CMR à conserver.$mft$,
    3, 45) RETURNING id INTO v_l3;

  -- ─── 8. Leçon 4 : Contrôles, sanctions, perte des exigences ────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'controles-sanctions-perte-exigences',
    'Contrôles, sanctions et perte des exigences',
    $mft$> 🎯 **Objectifs**
> - Identifier les autorités de contrôle et leurs pouvoirs.
> - Relier chaque manquement à sa sanction administrative ou pénale.
> - Expliquer les conséquences de la perte d'une exigence d'accès.

## Qui contrôle le transport routier ?

- **Contrôleurs des transports terrestres (DREAL)** : en entreprise et sur route, accès aux documents sociaux et d'exploitation.
- **Forces de l'ordre** (police, gendarmerie, douanes) : contrôles routiers, pesées, chronotachygraphe.
- **Inspection du travail** : durées du travail, détachement, travail illégal.

## Les sanctions administratives

Prononcées après avis de la commission régionale des sanctions administratives :

| Manquement | Sanction possible |
| --- | --- |
| Perte d'une exigence d'accès | Suspension puis retrait de l'autorisation d'exercer |
| Infractions graves et répétées | Retrait temporaire ou définitif des copies conformes |
| Cabotage irrégulier (transporteur non résident) | Interdiction temporaire de cabotage en France |
| Manquements du gestionnaire | Déclaration d'inaptitude à gérer |

La **radiation du registre** interdit toute activité de transport public routier : c'est la sanction administrative ultime.

## Les sanctions pénales

L'exercice de la profession **sans inscription au registre** est un délit sanctionné pénalement (code des transports, art. L. 3452-6 : jusqu'à un an d'emprisonnement et 15 000 € d'amende). D'autres manquements relèvent de contraventions de 4e ou 5e classe : absence de copie conforme à bord, défaut de lettre de voiture, entraves aux règles du chronotachygraphe pouvant aller jusqu'au délit.

> ⚠️ **Attention**
> Le dirigeant peut être **pénalement responsable** des infractions commises dans l'exploitation (durées de conduite, surcharge). Déléguer la gestion n'exonère pas de tout : la délégation doit être réelle, avec autorité, compétence et moyens.

## La perte des exigences en pratique

:::flow
1. Événement | Condamnation, capitaux insuffisants, départ du gestionnaire
2. Signalement | L'entreprise informe la DREAL (obligation continue)
3. Régularisation | Délai accordé : nouveau gestionnaire, recapitalisation
4. À défaut | Suspension, retrait, radiation du registre
:::

Un délai de régularisation est généralement accordé : par exemple, remplacer un gestionnaire de transport parti ou décédé, ou reconstituer la capacité financière. L'absence de régularisation dans le délai entraîne la perte de l'autorisation.

> 🎓 **Examen**
> Les questions rédigées de l'examen adorent les scénarios de perte d'exigence : « le gestionnaire quitte l'entreprise », « les capitaux propres deviennent insuffisants ». Structurez toujours : exigence touchée, obligation de signalement, délai de régularisation, sanction à défaut.

## ✅ Synthèse

- Contrôles : **DREAL**, forces de l'ordre, inspection du travail ; volet entreprise et volet routier.
- Administratif : suspension, **retrait**, radiation, interdiction de cabotage, inaptitude du gestionnaire.
- Pénal : délit d'exercice **sans inscription**, contraventions documentaires, responsabilité du dirigeant.
- Perte d'exigence : **signaler, régulariser dans le délai**, sinon retrait.$mft$,
    $mft$Les autorités de contrôle, l'échelle des sanctions administratives et pénales, la responsabilité du dirigeant et la procédure de régularisation en cas de perte d'une exigence.$mft$,
    4, 40) RETURNING id INTO v_l4;

  -- ─── 9. Quiz d'entraînement du module ──────────────────────────────
  -- NB : les questions liées sont créées active=false ; le quiz ne
  -- devient réellement jouable qu'après validation des questions.
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module,
    'Quiz : Accès à la profession et au marché',
    'Vérifiez les fondamentaux du module F : exigences d''accès, gestionnaire, licences, cabotage, sanctions.',
    'entrainement', 70, false)
  RETURNING id INTO v_quiz;

  -- ─── 10. QCM (12) : répartition 4 faciles / 5 moyens / 3 difficiles ─
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Quelles sont les quatre exigences cumulatives d'accès à la profession de transporteur routier lourd fixées par le règlement (CE) n° 1071/2009 ?$mft$,
    $mft$[
      {"id":"a","label":"Établissement, honorabilité, capacité financière, capacité professionnelle","is_correct":true},
      {"id":"b","label":"Diplôme, casier vierge, flotte en propre, assurance marchandises","is_correct":false},
      {"id":"c","label":"Établissement, ancienneté de 2 ans, capacité financière, permis CE","is_correct":false},
      {"id":"d","label":"Honorabilité, capacité financière, certification Qualiopi, gestionnaire","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-f','qcm-v1'], 'CAPA-LOURD-F-QCM-01', false,
    $mft$Article 3 du règlement (CE) n° 1071/2009 : établissement stable et effectif, honorabilité, capacité financière et capacité professionnelle. Les quatre sont cumulatives et doivent être maintenues en permanence.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Quelle capacité financière une entreprise doit-elle justifier pour exploiter 4 véhicules de plus de 3,5 tonnes ?$mft$,
    $mft$[
      {"id":"a","label":"20 000 €","is_correct":false},
      {"id":"b","label":"24 000 €","is_correct":true},
      {"id":"c","label":"29 000 €","is_correct":false},
      {"id":"d","label":"36 000 €","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-f','qcm-v1'], 'CAPA-LOURD-F-QCM-02', false,
    $mft$Lourd : 9 000 € pour le premier véhicule puis 5 000 € par véhicule supplémentaire. Soit 9 000 + (3 × 5 000) = 24 000 €.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un gestionnaire de transport externe (prestataire) peut diriger les activités de transport de :$mft$,
    $mft$[
      {"id":"a","label":"2 entreprises et 20 véhicules au maximum","is_correct":false},
      {"id":"b","label":"4 entreprises et 50 véhicules cumulés au maximum","is_correct":true},
      {"id":"c","label":"Un nombre illimité d'entreprises s'il est disponible","is_correct":false},
      {"id":"d","label":"5 entreprises dans la même région uniquement","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-f','qcm-v1'], 'CAPA-LOURD-F-QCM-03', false,
    $mft$Article 4 §2 du règlement 1071/2009 : le gestionnaire externe est limité à 4 entreprises et à une flotte cumulée de 50 véhicules.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Depuis le paquet mobilité, les véhicules affectés au transport international doivent revenir au centre opérationnel de l'entreprise au moins :$mft$,
    $mft$[
      {"id":"a","label":"Toutes les 4 semaines","is_correct":false},
      {"id":"b","label":"Toutes les 6 semaines","is_correct":false},
      {"id":"c","label":"Toutes les 8 semaines","is_correct":true},
      {"id":"d","label":"Tous les 3 mois","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-f','qcm-v1'], 'CAPA-LOURD-F-QCM-04', false,
    $mft$Règlement (UE) 2020/1055, applicable depuis le 21 février 2022 : retour des véhicules au centre opérationnel au moins toutes les huit semaines (exigence d'établissement).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Où doit se trouver l'original de la licence communautaire pendant l'exploitation ?$mft$,
    $mft$[
      {"id":"a","label":"À bord de chaque véhicule","is_correct":false},
      {"id":"b","label":"Au siège de l'entreprise","is_correct":true},
      {"id":"c","label":"À la DREAL qui l'a délivrée","is_correct":false},
      {"id":"d","label":"Chez le gestionnaire de transport","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-f','qcm-v1'], 'CAPA-LOURD-F-QCM-05', false,
    $mft$L'original reste au siège ; chaque véhicule moteur circule avec une copie conforme numérotée. C'est la copie conforme qui est contrôlée sur route.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quelle est la durée maximale de validité de la licence communautaire ?$mft$,
    $mft$[
      {"id":"a","label":"5 ans","is_correct":false},
      {"id":"b","label":"7 ans","is_correct":false},
      {"id":"c","label":"10 ans renouvelable","is_correct":true},
      {"id":"d","label":"Illimitée tant que les exigences sont remplies","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-f','qcm-v1'], 'CAPA-LOURD-F-QCM-06', false,
    $mft$La licence communautaire est délivrée pour une durée maximale de dix ans, renouvelable ; en France la licence de transport intérieur suit le même régime de validité.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$L'attestation de conducteur est exigée pour :$mft$,
    $mft$[
      {"id":"a","label":"Tout conducteur effectuant du transport international","is_correct":false},
      {"id":"b","label":"Les conducteurs ressortissants de pays tiers employés par une entreprise établie dans l'UE","is_correct":true},
      {"id":"c","label":"Les conducteurs intérimaires uniquement","is_correct":false},
      {"id":"d","label":"Les conducteurs de véhicules de plus de 44 tonnes","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-f','qcm-v1'], 'CAPA-LOURD-F-QCM-07', false,
    $mft$Règlement 1072/2009 : l'attestation de conducteur couvre le conducteur non ressortissant d'un État membre employé régulièrement par un transporteur de l'UE, présentée aux contrôles en international.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Après un transport international à charge entièrement livré en Espagne, un transporteur français peut y réaliser au maximum :$mft$,
    $mft$[
      {"id":"a","label":"1 cabotage dans les 3 jours","is_correct":false},
      {"id":"b","label":"3 cabotages dans les 7 jours","is_correct":true},
      {"id":"c","label":"5 cabotages dans les 10 jours","is_correct":false},
      {"id":"d","label":"Des cabotages illimités pendant 7 jours","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-f','qcm-v1'], 'CAPA-LOURD-F-QCM-08', false,
    $mft$Règle de base du cabotage (règlement 1072/2009, art. 8) : 3 opérations maximum dans les 7 jours suivant le dernier déchargement du transport international à charge.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un véhicule entre à vide en Belgique dans le cadre d'un transport international. Quelles règles de cabotage s'appliquent ?$mft$,
    $mft$[
      {"id":"a","label":"3 cabotages en 7 jours, comme après une entrée en charge","is_correct":false},
      {"id":"b","label":"1 cabotage maximum dans les 3 jours suivant l'entrée à vide","is_correct":true},
      {"id":"c","label":"Aucun cabotage n'est possible après une entrée à vide","is_correct":false},
      {"id":"d","label":"2 cabotages dans les 5 jours","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-f','qcm-v1'], 'CAPA-LOURD-F-QCM-09', false,
    $mft$Entrée à vide dans un État membre : une seule opération de cabotage autorisée dans les 3 jours suivant l'entrée, dans la limite globale des 7 jours de la séquence.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Depuis le 21 février 2022, avant de recommencer un cabotage dans le même État membre avec le même véhicule, l'entreprise doit respecter :$mft$,
    $mft$[
      {"id":"a","label":"Une carence de 4 jours","is_correct":true},
      {"id":"b","label":"Une carence de 7 jours","is_correct":false},
      {"id":"c","label":"Un retour obligatoire au siège","is_correct":false},
      {"id":"d","label":"Aucune contrainte particulière","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-f','qcm-v1'], 'CAPA-LOURD-F-QCM-10', false,
    $mft$Paquet mobilité (règlement 2020/1055) : période de carence (cooling-off) de 4 jours avant une nouvelle séquence de cabotage dans le même État membre avec le même véhicule.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$L'exercice de la profession de transporteur public routier sans inscription au registre expose à :$mft$,
    $mft$[
      {"id":"a","label":"Une simple contravention de 3e classe","is_correct":false},
      {"id":"b","label":"Un délit pouvant aller jusqu'à un an d'emprisonnement et 15 000 € d'amende","is_correct":true},
      {"id":"c","label":"Un avertissement de la DREAL sans sanction","is_correct":false},
      {"id":"d","label":"Une amende forfaitaire de 135 €","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-f','qcm-v1'], 'CAPA-LOURD-F-QCM-11', false,
    $mft$Code des transports, art. L. 3452-6 : exercer sans inscription au registre est un délit (jusqu'à 1 an d'emprisonnement et 15 000 € d'amende). À distinguer des contraventions documentaires (copie conforme absente, etc.).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$À défaut de capitaux propres suffisants, la capacité financière peut être complétée par une garantie bancaire ou d'assurance :$mft$,
    $mft$[
      {"id":"a","label":"Pour la totalité du montant exigé","is_correct":false},
      {"id":"b","label":"Dans la limite de la moitié du montant exigé","is_correct":true},
      {"id":"c","label":"Dans la limite du quart du montant exigé","is_correct":false},
      {"id":"d","label":"Uniquement pour les entreprises de moins de 5 véhicules","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-f','qcm-v1'], 'CAPA-LOURD-F-QCM-12', false,
    $mft$Arrêté du 3 février 2012 : la garantie (banque ou assurance) ne peut couvrir plus de la moitié de la capacité financière exigée ; le solde doit être justifié par les capitaux propres attestés.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── 11. QUESTIONS COURTES (10) : type qr, tag question-courte ─────
  -- Réponse attendue en quelques mots ; max_score 2 ; correction rapide.
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Quels montants de capacité financière une entreprise de transport lourd doit-elle justifier pour son premier véhicule, puis pour chaque véhicule supplémentaire ?$mft$,
   $mft$9 000 € pour le premier véhicule et 5 000 € par véhicule supplémentaire.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-f','question-courte'], 'CAPA-LOURD-F-QC-01', false,
   $mft$Montants applicables aux véhicules de plus de 3,5 t (arrêté du 3 février 2012). Variantes acceptées : « 9000 puis 5000 euros ».$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Quel document, présent à bord de chaque véhicule moteur, prouve lors d'un contrôle routier que l'entreprise est autorisée à exercer ?$mft$,
   $mft$La copie conforme numérotée de la licence (licence communautaire ou licence de transport intérieur).$mft$,
   2, 'facile', ARRAY['capa-lourd','module-f','question-courte'], 'CAPA-LOURD-F-QC-02', false,
   $mft$L'original reste au siège ; seule la copie conforme circule. Accepter « copie conforme de la licence ».$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Quelle administration instruit la demande d'autorisation d'exercer et tient le registre des transporteurs dans votre région ?$mft$,
   $mft$La DREAL (DRIEAT en Île-de-France, DEAL outre-mer).$mft$,
   2, 'facile', ARRAY['capa-lourd','module-f','question-courte'], 'CAPA-LOURD-F-QC-03', false,
   $mft$Direction régionale de l'environnement, de l'aménagement et du logement. Accepter DREAL seul.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Pour combien d'années, au maximum, la licence communautaire est-elle délivrée ?$mft$,
   $mft$Dix ans, renouvelable.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-f','question-courte'], 'CAPA-LOURD-F-QC-04', false,
   $mft$Règlement (CE) n° 1072/2009. Accepter « 10 ans ».$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Après un transport international à charge entièrement livré, combien d'opérations de cabotage sont autorisées dans l'État d'accueil, et dans quel délai ?$mft$,
   $mft$Trois opérations de cabotage au maximum, dans les sept jours suivant le dernier déchargement.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-f','question-courte'], 'CAPA-LOURD-F-QC-05', false,
   $mft$Règle « 3 en 7 » (règlement 1072/2009, art. 8). Exiger les deux éléments : nombre et délai.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Dans l'entreprise, qui doit être titulaire de l'attestation de capacité professionnelle en transport lourd ?$mft$,
   $mft$Le gestionnaire de transport (la personne qui dirige effectivement et en permanence l'activité transport).$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-f','question-courte'], 'CAPA-LOURD-F-QC-06', false,
   $mft$Accepter « le gestionnaire de transport » seul ; bonus si le candidat précise la direction effective et permanente.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Quelles sont les deux limites chiffrées imposées à un gestionnaire de transport externe (prestataire) ?$mft$,
   $mft$Quatre entreprises au maximum et une flotte cumulée de cinquante véhicules au maximum.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-f','question-courte'], 'CAPA-LOURD-F-QC-07', false,
   $mft$Article 4 §2 du règlement 1071/2009 : « 4 entreprises / 50 véhicules ». Exiger les deux chiffres.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$À quoi sert le système européen ERRU ?$mft$,
   $mft$À interconnecter les registres électroniques nationaux des entreprises de transport pour échanger entre États membres les informations sur les entreprises et leurs infractions graves.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-f','question-courte'], 'CAPA-LOURD-F-QC-08', false,
   $mft$European Register of Road Transport Undertakings. L'idée clé : les sanctions suivent l'entreprise dans toute l'UE.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quel délai de carence s'applique avant de recommencer une séquence de cabotage dans le même État membre avec le même véhicule ?$mft$,
   $mft$Quatre jours (période de carence du paquet mobilité, applicable depuis le 21 février 2022).$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-f','question-courte'], 'CAPA-LOURD-F-QC-09', false,
   $mft$Règlement (UE) 2020/1055. Accepter « 4 jours » ; la date d'entrée en vigueur est un bonus.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Jusqu'à quelle fraction de la capacité financière exigée une garantie bancaire ou d'assurance peut-elle être admise ?$mft$,
   $mft$Jusqu'à la moitié (50 %) du montant exigé ; le reste doit être couvert par les capitaux propres.$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-f','question-courte'], 'CAPA-LOURD-F-QC-10', false,
   $mft$Arrêté du 3 février 2012. Exiger la notion de moitié/50 %.$mft$);

  -- ─── 12. QUESTIONS RÉDIGÉES (8) : type qr, barème détaillé ─────────
  -- Réponse construite attendue ; max_score 5 ; scoring_grid = barème.
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Expliquez les quatre exigences d'accès à la profession de transporteur routier lourd de marchandises. Pour chacune, précisez ce qu'elle recouvre concrètement.$mft$,
   $mft$Réponse modèle. 1) Établissement stable et effectif : locaux réels en France où sont conservés les documents essentiels de l'entreprise, et centre opérationnel équipé ; depuis le paquet mobilité, retour des véhicules internationaux au centre au moins toutes les 8 semaines. 2) Honorabilité : absence de condamnations incompatibles pour l'entreprise, ses dirigeants et le gestionnaire de transport (infractions routières graves, travail dissimulé) ; perte prononcée par le préfet. 3) Capacité financière : capitaux et réserves d'au moins 9 000 € pour le premier véhicule lourd et 5 000 € par véhicule supplémentaire, prouvés par les capitaux propres attestés, complétés au besoin par une garantie limitée à la moitié. 4) Capacité professionnelle : attestation de capacité détenue par le gestionnaire de transport, obtenue par examen national, équivalence de diplôme ou expérience de direction reconnue. Ces quatre exigences sont cumulatives et permanentes.$mft$,
   $mft$Barème /5 : 1 pt par exigence correctement nommée ET expliquée (4 pts) ; 1 pt pour le caractère cumulatif et permanent (ou un chiffrage exact : 9 000/5 000 €, 8 semaines). Erreurs fréquentes : confondre capacité financière et chiffre d'affaires ; oublier que l'honorabilité couvre aussi le gestionnaire ; citer l'assurance marchandises (hors sujet).$mft$,
   5, 'facile', ARRAY['capa-lourd','module-f','question-redigee'], 'CAPA-LOURD-F-QR-01', false,
   $mft$Question de restitution structurée, niveau fondamental du module. Référence : règlement (CE) n° 1071/2009, art. 3 à 7.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Comparez la licence de transport intérieur et la licence communautaire : champ d'utilisation, durée, documents associés à bord. Dans quel cas une entreprise doit-elle détenir la seconde ?$mft$,
   $mft$Réponse modèle. La licence de transport intérieur couvre le transport public routier national avec des véhicules de plus de 3,5 t ; la licence communautaire couvre le transport international entre États membres de l'UE (bilatéral, triangulaire, transit) et le cabotage qui en découle. Les deux sont délivrées pour dix ans au maximum, renouvelables. Dans les deux cas, l'original reste au siège et chaque véhicule moteur circule avec une copie conforme numérotée ; le nombre de copies est plafonné par la capacité financière. Une entreprise doit détenir la licence communautaire dès qu'elle réalise des transports internationaux intra-UE ; pour une activité purement nationale, la licence intérieure suffit.$mft$,
   $mft$Barème /5 : champ national vs international correctement opposé (2 pts) ; durée 10 ans (0,5 pt) ; original au siège + copie conforme à bord (1 pt) ; lien copies conformes/capacité financière (0,5 pt) ; cas d'exigence de la licence communautaire (1 pt). Erreurs fréquentes : croire que la licence communautaire remplace l'inscription au registre ; attacher la copie conforme au conducteur.$mft$,
   5, 'facile', ARRAY['capa-lourd','module-f','question-redigee'], 'CAPA-LOURD-F-QR-02', false,
   $mft$Comparaison structurée ; références : règlements 1071/2009 et 1072/2009, code des transports R. 3211-x.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Cas pratique. La SARL TransNord exploite 6 porteurs de 19 t et souhaite mettre en service 2 tracteurs supplémentaires. Ses capitaux propres attestés s'élèvent à 30 000 €. a) Calculez la capacité financière exigée après extension. b) L'entreprise peut-elle satisfaire l'exigence, et comment ?$mft$,
   $mft$Réponse modèle. a) Flotte après extension : 8 véhicules lourds. Capacité exigée = 9 000 € + (7 × 5 000 €) = 44 000 €. b) Capitaux propres disponibles : 30 000 €, soit un manque de 14 000 €. Une garantie bancaire ou d'assurance peut compléter dans la limite de la moitié de l'exigence (22 000 € maximum) : une garantie de 14 000 € est donc admissible. L'entreprise peut satisfaire l'exigence en produisant l'attestation de capitaux propres (expert-comptable ou commissaire aux comptes) plus une garantie d'au moins 14 000 € ; à défaut, elle devra renoncer à des copies conformes (flotte réduite) ou se recapitaliser.$mft$,
   $mft$Barème /5 : calcul exact 44 000 € avec détail (2 pts, dont 0,5 pour la formule) ; identification du manque de 14 000 € (1 pt) ; règle de la garantie limitée à la moitié et vérification 14 000 ≤ 22 000 (1,5 pt) ; solution opérationnelle (attestation + garantie, ou réduction de flotte) (0,5 pt). Erreurs fréquentes : appliquer 9 000 € à chaque véhicule ; oublier que le premier véhicule est à 9 000 € ; admettre une garantie totale.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-f','question-redigee'], 'CAPA-LOURD-F-QR-03', false,
   $mft$Exercice de calcul emblématique de l'épreuve rédigée. Références : arrêté du 3 février 2012.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Le gestionnaire de transport de votre entreprise démissionne au 1er septembre. Décrivez la procédure à suivre et les risques encourus si rien n'est fait.$mft$,
   $mft$Réponse modèle. La capacité professionnelle est une exigence permanente : le départ du gestionnaire doit être signalé sans délai à la DREAL (obligation d'information sur tout changement affectant les exigences). L'entreprise demande à bénéficier du délai de régularisation prévu pour recruter ou désigner un nouveau gestionnaire titulaire de l'attestation (interne, ou prestataire externe dans la limite de 4 entreprises et 50 véhicules). Pendant ce délai, l'activité peut continuer. Plan d'action : signalement DREAL, recherche d'un titulaire (salarié, dirigeant, externe), mise à jour du registre, vérification du lien réel et de la direction effective. Risques à défaut : constat de perte de l'exigence, suspension puis retrait de l'autorisation d'exercer et radiation du registre, avec interdiction de poursuivre l'activité.$mft$,
   $mft$Barème /5 : signalement à la DREAL (1 pt) ; existence d'un délai de régularisation (1 pt) ; voies de remplacement, y compris externe avec ses limites 4/50 (1,5 pt) ; sanctions à défaut : suspension, retrait, radiation (1,5 pt). Erreurs fréquentes : croire qu'on peut exercer durablement sans gestionnaire ; oublier le signalement ; proposer un « prête-nom » sans direction effective (motif d'inaptitude).$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-f','question-redigee'], 'CAPA-LOURD-F-QR-04', false,
   $mft$Question de procédure très fréquente à l'examen. Références : règlement 1071/2009, art. 13 ; code des transports.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Analyse de situation. Un ensemble routier français livre intégralement un chargement à Milan le lundi à 9 h. Il réalise ensuite : un transport Milan-Turin mardi, un Turin-Rome mercredi, un Rome-Florence jeudi, puis un Florence-Bologne le vendredi. Cette séquence est-elle régulière ? Justifiez précisément.$mft$,
   $mft$Réponse modèle. Le transport international à charge a été entièrement livré lundi 9 h : la séquence de cabotage en Italie est ouverte pour 3 opérations maximum dans les 7 jours. Milan-Turin (1), Turin-Rome (2) et Rome-Florence (3) sont réguliers : trois cabotages dans le délai. Le Florence-Bologne du vendredi est une quatrième opération de cabotage dans le même État : il est irrégulier, même si l'on reste dans les 7 jours, car le plafond de 3 opérations est dépassé. L'entreprise s'expose aux sanctions de l'État d'accueil (amende, interdiction temporaire de cabotage) ; les preuves CMR de chaque opération seront contrôlées. Pour être régulier, le véhicule aurait dû quitter l'Italie ou réaliser un nouveau transport international avant toute nouvelle opération intérieure, puis respecter la carence de 4 jours avant de re-caboter en Italie.$mft$,
   $mft$Barème /5 : identification du point de départ (livraison complète lundi) (1 pt) ; décompte correct des 3 premières opérations régulières (1,5 pt) ; qualification du 4e transport comme cabotage irrégulier avec le bon motif (plafond, pas le délai) (1,5 pt) ; conséquences/sanctions ou condition de reprise (carence 4 jours) (1 pt). Erreurs fréquentes : compter le transport international comme un cabotage ; invoquer le dépassement des 7 jours au lieu du plafond de 3.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-f','question-redigee'], 'CAPA-LOURD-F-QR-05', false,
   $mft$Cas d'application du cabotage avec piège classique sur le motif d'irrégularité. Référence : règlement 1072/2009, art. 8.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Justifiez, en vous appuyant sur les objectifs du paquet mobilité, l'obligation de retour des véhicules au centre opérationnel toutes les huit semaines. Quels comportements cette règle vise-t-elle à empêcher ?$mft$,
   $mft$Réponse modèle. Le paquet mobilité (2020) vise à garantir une concurrence loyale et de meilleures conditions sociales dans le transport européen. L'obligation de retour des véhicules toutes les huit semaines renforce l'exigence d'établissement stable et effectif : elle empêche les « sociétés boîtes aux lettres » immatriculées dans un État à bas coûts alors que l'activité réelle se déroule ailleurs, et le nomadisme permanent des flottes qui ne repassent jamais par leur pays d'établissement. Couplée au retour périodique des conducteurs et aux règles de détachement, elle rattache concrètement l'exploitation au pays d'établissement, facilite les contrôles (documents, véhicules) et réduit le dumping social. Limite : la règle a un coût (trajets de repositionnement), ce qui alimente le débat sur son bilan environnemental.$mft$,
   $mft$Barème /5 : lien avec l'exigence d'établissement effectif (1,5 pt) ; ciblage des sociétés boîtes aux lettres / flottes nomades (1,5 pt) ; cohérence avec les autres mesures du paquet (retour des conducteurs, détachement) (1 pt) ; recul critique ou mention des contrôles facilités (1 pt). Erreurs fréquentes : confondre retour des véhicules (8 semaines) et droit au retour des conducteurs ; y voir une règle de sécurité routière.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-f','question-redigee'], 'CAPA-LOURD-F-QR-06', false,
   $mft$Question d'argumentation sur le sens de la règle. Référence : règlement (UE) 2020/1055, considérants et art. 5.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas professionnel. Le gérant unique de la SAS RoulExpress est condamné pour travail dissimulé. Analysez les conséquences possibles sur l'entreprise au regard des exigences d'accès à la profession, et les démarches envisageables.$mft$,
   $mft$Réponse modèle. Le travail dissimulé figure parmi les infractions faisant perdre l'honorabilité professionnelle. L'honorabilité s'apprécie pour l'entreprise, ses dirigeants et le gestionnaire : la condamnation du gérant unique menace directement l'exigence. Le préfet de région peut prononcer la perte d'honorabilité après procédure contradictoire ; l'entreprise perd alors une exigence d'accès, s'exposant à la suspension puis au retrait de l'autorisation et à la radiation du registre. Si le gérant était aussi gestionnaire de transport, il peut être déclaré inapte à gérer. Démarches envisageables : présenter des observations lors de la procédure contradictoire, réorganiser la gouvernance (nouveau dirigeant, nouveau gestionnaire honorables, avec direction effective réelle), solliciter le maintien le temps de la réorganisation, et à terme la réhabilitation ou le relèvement pour recouvrer l'honorabilité. À défaut de régularisation, cessation de l'activité de transport public.$mft$,
   $mft$Barème /5 : qualification du travail dissimulé comme atteinte à l'honorabilité (1 pt) ; portée de l'exigence (dirigeants ET gestionnaire) (1 pt) ; rôle du préfet et procédure contradictoire (1 pt) ; échelle des conséquences (suspension, retrait, radiation, inaptitude) (1 pt) ; démarches de réorganisation crédibles, sans prête-nom (1 pt). Erreurs fréquentes : limiter les conséquences à une amende ; proposer un dirigeant de paille ; ignorer la procédure contradictoire.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-f','question-redigee'], 'CAPA-LOURD-F-QR-07', false,
   $mft$Cas transversal honorabilité/sanctions. Références : règlement 1071/2009 art. 6 ; code des transports R. 3211-x (procédure préfectorale).$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Votre entreprise est convoquée pour un contrôle DREAL en entreprise. Construisez le plan de préparation : documents à tenir à disposition et points de vigilance, classés par exigence contrôlée.$mft$,
   $mft$Réponse modèle. 1) Établissement : justificatifs des locaux (bail, factures), présence des documents originaux au siège, registre des véhicules et suivi des retours (8 semaines) pour l'international. 2) Honorabilité : extraits Kbis à jour, identité des dirigeants et du gestionnaire (les bulletins n° 2 sont consultés par l'administration). 3) Capacité financière : dernière liasse fiscale, attestation de capitaux propres par l'expert-comptable ou le commissaire aux comptes, contrats de garantie éventuels, cohérence avec le nombre de copies conformes. 4) Capacité professionnelle : attestation de capacité du gestionnaire, contrat ou mandat prouvant la direction effective et permanente (et la limite 4 entreprises/50 véhicules si externe). 5) Exploitation : licences et copies conformes, lettres de voiture, données du chronotachygraphe et cartes conducteurs, suivi des temps de conduite, attestations de conducteur pays tiers. Points de vigilance : classement à jour, concordance flotte réelle/copies conformes, signalements de changements déjà effectués auprès de la DREAL.$mft$,
   $mft$Barème /5 : plan structuré par exigence (1 pt) ; documents pertinents pour au moins 4 des 5 rubriques (2 pts) ; cohérence flotte/copies conformes et capacité financière (1 pt) ; volet social/chronotachygraphe (0,5 pt) ; réflexe de signalement préalable des changements (0,5 pt). Erreurs fréquentes : liste en vrac sans structure ; oublier le volet capacité financière ; confondre contrôle DREAL et contrôle URSSAF.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-f','question-redigee'], 'CAPA-LOURD-F-QR-08', false,
   $mft$Question de plan d'action opérationnel, format apprécié du jury. Synthèse de tout le module F.$mft$);

  RAISE NOTICE 'Module F Capa lourd créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $capaf$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION (à lancer après le script)
-- =====================================================================
-- 1) Volumes attendus :  12 qcm / 18 qr, tous active = false
--    select "type", active, count(*) from question_bank
--     where source_ref like 'CAPA-LOURD-F-%' group by 1, 2;
-- 2) Chaque QCM a exactement une bonne réponse :
--    select source_ref from question_bank
--     where source_ref like 'CAPA-LOURD-F-QCM-%'
--       and (select count(*) from jsonb_array_elements(choices) c
--             where (c->>'is_correct')::boolean) <> 1;
--    → doit renvoyer 0 ligne.
-- 3) Aucun doublon d'énoncé :
--    select statement, count(*) from question_bank
--     where formation_id = (select id from formations where slug='capacite-plus-3-5t')
--     group by 1 having count(*) > 1;  → 0 ligne.
