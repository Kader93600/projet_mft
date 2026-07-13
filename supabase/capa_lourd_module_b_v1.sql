-- =====================================================================
-- CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : MODULE B : DROIT COMMERCIAL
-- v1 (juillet 2026) : LOT 3
--
-- Domaine B de l'annexe I du règlement (CE) n° 1071/2009 : le commerçant
-- et ses obligations, le fonds de commerce, les sociétés commerciales,
-- les effets de commerce et les procédures collectives.
-- Références : code de commerce ; loi PACTE et registre national des
-- entreprises (RNE, 2023) ; livre VI du code de commerce (difficultés).
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $capab$
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
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-plus-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-plus-3-5t introuvable.';
  END IF;

  INSERT INTO public.blocs (id, code, title, description, "order")
  VALUES (30, 'CAPA-LOURD', 'Capacité de transport lourd > 3,5 t',
          'Programme officiel de l''examen d''attestation de capacité professionnelle en transport routier lourd de marchandises (annexe I du règlement CE 1071/2009).', 30)
  ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'CAPA-LOURD';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'CAPA-LOURD-B-%';
  DELETE FROM public.modules WHERE slug = 'capa-lourd-droit-commercial';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module B : Droit commercial',
    'capa-lourd-droit-commercial',
    v_bloc,
    'Le commerçant et ses obligations, le fonds de commerce et sa reprise, le choix de la forme sociale, les effets de commerce et le financement du poste clients, les entreprises en difficulté.',
    'intermediaire',
    540,
    20
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 20, true);

  -- ─── Leçon 1 : Le commerçant et ses obligations ─────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'commercant-actes-obligations',
    'Le commerçant, les actes de commerce et ses obligations',
    $mft$> 🎯 **Objectifs**
> - Définir le commerçant et reconnaître les actes de commerce.
> - Lister les obligations professionnelles du commerçant.
> - Situer le transport routier dans la sphère commerciale.

## Qui est commerçant ?

Est commerçant celui qui accomplit des **actes de commerce** à titre de **profession habituelle** et pour son propre compte. L'entreprise de transport routier de marchandises exerce une activité **commerciale par nature** : le transporteur est commerçant, qu'il exerce en nom propre ou par l'intermédiaire d'une société commerciale.

Parmi les actes de commerce : l'achat pour revendre, les opérations de banque, la location de meubles, et précisément **toute entreprise de transport**.

## Les obligations du commerçant

| Obligation | Contenu |
| --- | --- |
| Immatriculation | Au registre du commerce et des sociétés (RCS) et, depuis 2023, au registre national des entreprises (RNE) |
| Comptabilité | Livre-journal, grand livre, inventaire ; comptes annuels ; conservation 10 ans |
| Compte bancaire | Compte dédié à l'activité |
| Facturation | Factures conformes (mentions obligatoires, numérotation, délais de paiement) |
| Loyauté | Respect du droit de la concurrence, transparence tarifaire |

> 📌 **À retenir**
> L'immatriculation crée une **présomption de commercialité** et conditionne l'accès à des droits clés : bail commercial, inscription au registre des transporteurs, réponse aux appels d'offres.

## Les spécificités du droit commercial

- **Preuve libre** entre commerçants : tous moyens (courriels, factures, bons de livraison signés).
- **Solidarité présumée** entre codébiteurs commerçants.
- **Juridiction** : le tribunal de commerce tranche les litiges entre commerçants.
- **Prescription** de droit commun : 5 ans (sous réserve des délais spéciaux, comme l'an du contrat de transport).

## Application au transport

Le dirigeant d'une entreprise de transport combine trois casquettes juridiques : **commerçant** (obligations ci-dessus), **transporteur inscrit** au registre des transporteurs (module F) et **employeur** (droit social, module C). Une négligence comptable ou de facturation fragilise les trois à la fois : la capacité financière s'apprécie sur des comptes fiables.

> 💡 **Astuce**
> Les bons de livraison signés et archivés ne servent pas qu'à la paie des conducteurs : entre commerçants, ils font preuve de l'exécution de la prestation en cas de litige sur facture.

## ✅ Synthèse

- Le transport est un **acte de commerce** ; le transporteur est **commerçant**.
- Obligations : **immatriculation (RCS/RNE), comptabilité, compte dédié, facturation**.
- Entre commerçants : **preuve libre**, solidarité présumée, tribunal de commerce.$mft$,
    $mft$Le commerçant et les actes de commerce (dont le transport), les obligations d'immatriculation, de comptabilité et de facturation, et les règles propres aux litiges entre commerçants.$mft$,
    1, 40) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Le fonds de commerce ────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'fonds-de-commerce',
    'Le fonds de commerce : composition, cession, location-gérance',
    $mft$> 🎯 **Objectifs**
> - Identifier ce qui compose (et ce qui ne compose pas) un fonds de commerce.
> - Décrire les précautions d'une cession de fonds de transport.
> - Expliquer la location-gérance et le nantissement.

## La composition du fonds

Le **fonds de commerce** est un ensemble d'éléments affectés à l'exploitation :

- **Éléments incorporels** : la clientèle (l'élément essentiel), le nom commercial et l'enseigne, le **droit au bail**, les contrats transmissibles, les marques et licences d'exploitation privées.
- **Éléments corporels** : matériel et outillage (véhicules, matériels de manutention), marchandises.

> ❌ **Piège à éviter**
> Ne font pas partie du fonds : l'**immeuble** (les murs appartiennent au bailleur ou se vendent séparément), les **créances et dettes** (sauf clauses particulières), et surtout les **autorisations administratives personnelles**.

## Cession d'un fonds de transport : le point critique

Les titres administratifs du transporteur (inscription au registre des transporteurs, licence intérieure ou communautaire, copies conformes) sont **personnels et incessibles** : ils ne se vendent pas avec le fonds.

:::flow
1. Acquéreur | Doit détenir SA capacité professionnelle
2. Demande DREAL | Autorisation d'exercer à son nom
3. Reprise du fonds | Clientèle, bail, matériel, contrats
:::

L'acquéreur d'un fonds de transport doit donc remplir lui-même les **quatre exigences d'accès** (module F) et obtenir sa propre autorisation avant d'exploiter.

### Les formalités de la cession

Acte de cession, publicité (registres et annonces légales), **séquestre du prix** pendant les délais d'opposition des créanciers du vendeur, information préalable des salariés dans les PME, purge du droit de préemption éventuel. La clientèle étant l'élément essentiel, une clause de **non-concurrence** du vendeur (limitée dans le temps et l'espace) protège l'acquéreur.

## La location-gérance

Le propriétaire d'un fonds le donne en location à un **locataire-gérant** qui l'exploite **à ses risques et périls** contre une redevance. Utile pour tester une reprise ou préparer une transmission ; le locataire-gérant doit lui aussi détenir les autorisations de transport à son nom.

> ⚠️ **Attention**
> Pendant la période initiale de la location-gérance, le loueur peut rester solidairement tenu de certaines dettes d'exploitation ; les contrats prévoient soigneusement l'état du matériel roulant, l'entretien et l'assurance.

## Le nantissement du fonds

Le fonds peut être donné en **garantie** (nantissement) au profit d'un créancier, typiquement la banque qui finance la reprise : sûreté sans dépossession, inscrite au greffe, qui confère un droit de préférence sur le prix en cas de revente.

## ✅ Synthèse

- Fonds = **clientèle**, droit au bail, nom, matériel, marchandises ; **hors** fonds : immeuble, créances/dettes, **autorisations de transport (incessibles)**.
- Cession : formalités, séquestre du prix, non-concurrence ; l'acquéreur obtient **sa propre autorisation DREAL**.
- **Location-gérance** : exploitation aux risques du locataire-gérant contre redevance ; **nantissement** : le fonds en garantie.$mft$,
    $mft$Composition du fonds de commerce, incessibilité des autorisations de transport lors d'une cession, formalités et clause de non-concurrence, location-gérance et nantissement.$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Les sociétés commerciales ───────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'societes-commerciales',
    'Choisir sa société : SARL, SAS et les autres',
    $mft$> 🎯 **Objectifs**
> - Comparer les principales formes de sociétés commerciales.
> - Relier forme sociale, responsabilité et statut social du dirigeant.
> - Choisir une forme adaptée à une entreprise de transport lourd.

## Pourquoi passer en société ?

La société dote l'activité d'une **personnalité morale distincte** : patrimoine propre, continuité en cas de décès du dirigeant, entrée d'associés ou d'investisseurs, crédibilité vis-à-vis des donneurs d'ordre. En contrepartie : formalisme de création et de fonctionnement (statuts, assemblées, dépôt des comptes).

## Le panorama des formes usuelles

| Forme | Associés | Capital | Responsabilité | Dirigeant et statut social |
| --- | --- | --- | --- | --- |
| SARL / EURL | 1 à 100 | Libre | Limitée aux apports | Gérant ; majoritaire = travailleur non salarié (TNS), minoritaire ou égalitaire = assimilé salarié |
| SAS / SASU | 1 ou plus | Libre | Limitée aux apports | Président ; toujours assimilé salarié |
| SA | 2 (7 si cotée) | 37 000 € minimum | Limitée aux apports | Conseil et direction ; grandes structures |
| SNC | 2 ou plus | Libre | Indéfinie et solidaire | Tous les associés sont commerçants |

> ⚠️ **Attention**
> Dans la SNC, chaque associé répond **indéfiniment et solidairement** des dettes sociales : un seul impayé important peut atteindre les patrimoines personnels de tous. Forme à réserver à des configurations très particulières.

## SARL ou SAS : le vrai match du transport

- **SARL** : cadre légal balisé, protecteur pour des associés familiaux ; le gérant majoritaire relève du régime **TNS** (cotisations plus faibles, protection moindre).
- **SAS** : grande **liberté statutaire** (gouvernance, clauses d'entrée et de sortie, pactes), président **assimilé salarié** (protection sociale du régime général, hors assurance chômage) ; préférée en cas d'investisseurs ou de croissance externe.

La responsabilité « limitée aux apports » connaît des limites pratiques : **cautions personnelles** exigées par les banques et responsabilité pour **faute de gestion** en cas de liquidation (comblement de passif).

## Constitution : les étapes

:::timeline
1. **Rédaction des statuts** : forme, objet (transport public routier de marchandises), siège, capital, dirigeants.
2. **Dépôt du capital** : attestation de dépôt des fonds.
3. **Publicité** : annonce légale de constitution.
4. **Immatriculation** : dossier via le guichet unique ; RCS et RNE ; la société acquiert la personnalité morale.
5. **Après immatriculation** : demande d'autorisation d'exercer à la DREAL au nom de la société, assurances, comptes bancaires.
:::

> 📌 **À retenir**
> L'objet social doit couvrir l'activité réellement exercée. La société de transport demande **sa propre** inscription au registre des transporteurs : l'autorisation ne se « récupère » ni d'une autre société ni du dirigeant en nom propre.

## ✅ Synthèse

- Société = personnalité morale, **responsabilité limitée aux apports** (sauf SNC) ; limites : cautions et faute de gestion.
- **SARL** : cadre légal, gérant majoritaire TNS ; **SAS** : souplesse, président assimilé salarié.
- Constitution : statuts, dépôt du capital, annonce légale, **immatriculation**, puis autorisation DREAL au nom de la société.$mft$,
    $mft$Comparatif SARL/SAS/SA/SNC (responsabilité, statut social du dirigeant), limites de la responsabilité limitée, étapes de constitution et autorisation de transport au nom de la société.$mft$,
    3, 45) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Effets de commerce et entreprises en difficulté ─────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'effets-commerce-procedures-collectives',
    'Effets de commerce, affacturage et entreprises en difficulté',
    $mft$> 🎯 **Objectifs**
> - Utiliser les effets de commerce et l'affacturage pour financer le poste clients.
> - Distinguer les procédures amiables et collectives du livre VI.
> - Réagir en créancier averti face à un client défaillant.

## Financer le poste clients

Les délais de paiement pèsent lourd en trésorerie. Trois outils :

- la **lettre de change** : le tireur (fournisseur) donne l'ordre au tiré (client) de payer à échéance ; l'acceptation par le client renforce la créance ;
- le **billet à ordre** : le client s'engage lui-même à payer à échéance ;
- l'**escompte** : la banque avance immédiatement le montant de l'effet, moins agios, et encaisse à échéance ;
- l'**affacturage** : cession des factures à un factor qui finance, gère le recouvrement et, selon contrat, garantit l'impayé. Très répandu dans le transport, où les factures sont nombreuses et les marges serrées.

> 💡 **Astuce**
> Comparer le **coût complet** de l'affacturage (commission de financement + commission de service + fonds de garantie) au gain de trésorerie et au temps administratif économisé : sur de gros volumes de petites factures, il est souvent compétitif.

## Prévenir : les procédures amiables

- **Mandat ad hoc** : un mandataire, désigné par le président du tribunal, aide à négocier discrètement avec les créanciers.
- **Conciliation** : négociation encadrée (entreprise pas en cessation des paiements depuis plus de 45 jours) ; l'accord peut être homologué.

## Les procédures collectives

| Procédure | Situation | Objectif |
| --- | --- | --- |
| Sauvegarde | Difficultés insurmontables, pas de cessation des paiements | Se réorganiser sous protection du tribunal |
| Redressement judiciaire | Cessation des paiements, redressement possible | Poursuivre l'activité, apurer le passif (plan) |
| Liquidation judiciaire | Redressement manifestement impossible | Céder ou arrêter, réaliser les actifs |

La **cessation des paiements** : impossibilité de faire face au **passif exigible** avec l'**actif disponible**. Le dirigeant doit la déclarer au tribunal dans les **45 jours** (à défaut : faute de gestion possible).

> 🔍 **Focus**
> La **période suspecte** court de la date de cessation des paiements (fixée par le tribunal) au jugement d'ouverture : certains actes passés pendant cette période (paiements anormaux, sûretés nouvelles) peuvent être annulés.

## Le créancier face à la procédure

:::timeline
1. **Jugement d'ouverture publié au BODACC** : point de départ des délais.
2. **Déclaration des créances** : dans les **2 mois** de la publication, auprès du mandataire judiciaire ; à défaut, créance inopposable.
3. **Interdiction des paiements des créances antérieures** : plus de poursuite individuelle.
4. **Créances postérieures utiles** : payées à échéance ou par privilège.
:::

Réflexes du transporteur créancier : surveiller ses encours clients, déclarer dans les délais, mobiliser au bon moment son **droit de rétention** (module A) sur les marchandises détenues au titre du transport impayé, et vérifier une éventuelle clause de réserve de propriété pour les fournisseurs.

## ✅ Synthèse

- Poste clients : lettre de change, billet à ordre, **escompte**, **affacturage**.
- Amiable : mandat ad hoc, conciliation. Collectif : **sauvegarde**, **redressement**, **liquidation**.
- Cessation des paiements : déclaration sous **45 jours** ; créancier : **déclarer sous 2 mois** après le BODACC.$mft$,
    $mft$Effets de commerce, escompte et affacturage, procédures amiables (mandat ad hoc, conciliation) et collectives (sauvegarde, redressement, liquidation), délais clés : 45 jours et 2 mois.$mft$,
    4, 50) RETURNING id INTO v_l4;

  -- ─── Quiz d'entraînement ────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module,
    'Quiz : Droit commercial',
    'Validez les fondamentaux du module B : commerçant, fonds de commerce, sociétés, financement du poste clients et entreprises en difficulté.',
    'entrainement', 70, false)
  RETURNING id INTO v_quiz;

  -- ─── QCM (12) : 4 faciles / 5 moyens / 3 difficiles ────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Pourquoi l'exploitant d'une entreprise de transport routier de marchandises a-t-il la qualité de commerçant ?$mft$,
    $mft$[
      {"id":"a","label":"Parce que toute entreprise de transport est un acte de commerce exercé à titre de profession habituelle","is_correct":true},
      {"id":"b","label":"Parce qu'il est inscrit au registre des transporteurs","is_correct":false},
      {"id":"c","label":"Parce qu'il emploie des salariés","is_correct":false},
      {"id":"d","label":"Uniquement s'il réalise plus de 100 000 € de chiffre d'affaires","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-b','qcm-v1'], 'CAPA-LOURD-B-QCM-01', false,
    $mft$Le transport figure parmi les actes de commerce par nature : exercé à titre habituel et pour son propre compte, il confère la qualité de commerçant, indépendamment du chiffre d'affaires ou de l'effectif.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Lequel de ces éléments ne fait PAS partie du fonds de commerce cédé ?$mft$,
    $mft$[
      {"id":"a","label":"La clientèle","is_correct":false},
      {"id":"b","label":"Le droit au bail","is_correct":false},
      {"id":"c","label":"L'immeuble dans lequel s'exerce l'activité","is_correct":true},
      {"id":"d","label":"Le matériel d'exploitation","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-b','qcm-v1'], 'CAPA-LOURD-B-QCM-02', false,
    $mft$Le fonds comprend des éléments incorporels (clientèle, bail, nom) et corporels (matériel, marchandises) mais jamais l'immeuble lui-même, qui suit un régime distinct. Créances et dettes n'y figurent pas non plus, sauf stipulation.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Dans une SARL, la responsabilité des associés pour les dettes sociales est en principe :$mft$,
    $mft$[
      {"id":"a","label":"Limitée au montant de leurs apports","is_correct":true},
      {"id":"b","label":"Indéfinie et solidaire","is_correct":false},
      {"id":"c","label":"Limitée au double de leurs apports","is_correct":false},
      {"id":"d","label":"Inexistante dans tous les cas","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-b','qcm-v1'], 'CAPA-LOURD-B-QCM-03', false,
    $mft$SARL et SAS limitent la responsabilité aux apports. Limites pratiques : cautions personnelles consenties aux banques et responsabilité pour faute de gestion (comblement de passif) en cas de liquidation.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$La liquidation judiciaire est prononcée lorsque :$mft$,
    $mft$[
      {"id":"a","label":"L'entreprise est en cessation des paiements et son redressement est manifestement impossible","is_correct":true},
      {"id":"b","label":"L'entreprise connaît de simples difficultés passagères","is_correct":false},
      {"id":"c","label":"Le dirigeant le demande pour changer d'activité","is_correct":false},
      {"id":"d","label":"Un seul créancier n'a pas été payé à l'échéance","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-b','qcm-v1'], 'CAPA-LOURD-B-QCM-04', false,
    $mft$La liquidation suppose cessation des paiements + redressement manifestement impossible : l'activité cesse (sauf cession) et les actifs sont réalisés pour payer les créanciers.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Lors de la cession d'un fonds de commerce de transport, que deviennent la licence communautaire et l'inscription au registre des transporteurs du vendeur ?$mft$,
    $mft$[
      {"id":"a","label":"Elles sont transmises automatiquement à l'acquéreur avec le fonds","is_correct":false},
      {"id":"b","label":"Elles sont personnelles et incessibles : l'acquéreur doit obtenir sa propre autorisation","is_correct":true},
      {"id":"c","label":"Elles se transmettent si l'acte de cession le prévoit","is_correct":false},
      {"id":"d","label":"Elles sont vendues séparément aux enchères","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-b','qcm-v1'], 'CAPA-LOURD-B-QCM-05', false,
    $mft$Les titres administratifs du transporteur sont attachés à la personne autorisée : l'acquéreur doit remplir lui-même les quatre exigences d'accès et obtenir sa propre autorisation DREAL avant d'exploiter.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Entre commerçants, comment se prouve un contrat ou une livraison ?$mft$,
    $mft$[
      {"id":"a","label":"Uniquement par acte notarié","is_correct":false},
      {"id":"b","label":"Uniquement par écrit signé des deux parties","is_correct":false},
      {"id":"c","label":"Par tous moyens : la preuve est libre","is_correct":true},
      {"id":"d","label":"Uniquement par témoins","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-b','qcm-v1'], 'CAPA-LOURD-B-QCM-06', false,
    $mft$La liberté de la preuve entre commerçants permet d'invoquer courriels, factures, bons de livraison émargés : d'où l'importance d'archiver rigoureusement les documents d'exploitation.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Dans quel délai le dirigeant doit-il déclarer la cessation des paiements au tribunal ?$mft$,
    $mft$[
      {"id":"a","label":"15 jours","is_correct":false},
      {"id":"b","label":"30 jours","is_correct":false},
      {"id":"c","label":"45 jours","is_correct":true},
      {"id":"d","label":"90 jours","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-b','qcm-v1'], 'CAPA-LOURD-B-QCM-07', false,
    $mft$45 jours à compter de la cessation des paiements (impossibilité de faire face au passif exigible avec l'actif disponible), sauf demande de conciliation dans ce délai. Déclarer tardivement expose le dirigeant à des sanctions.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Quel est le statut social du président de SAS ?$mft$,
    $mft$[
      {"id":"a","label":"Travailleur non salarié (TNS) dans tous les cas","is_correct":false},
      {"id":"b","label":"Assimilé salarié, affilié au régime général (hors assurance chômage)","is_correct":true},
      {"id":"c","label":"Salarié avec droit à l'assurance chômage","is_correct":false},
      {"id":"d","label":"Aucun statut social","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-b','qcm-v1'], 'CAPA-LOURD-B-QCM-08', false,
    $mft$Le président de SAS est assimilé salarié : protection du régime général sur sa rémunération, mais pas d'assurance chômage au titre du mandat. Le gérant majoritaire de SARL relève, lui, du régime TNS.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Qu'est-ce que l'escompte d'un effet de commerce ?$mft$,
    $mft$[
      {"id":"a","label":"La banque avance immédiatement le montant de l'effet, moins agios, et encaisse à l'échéance","is_correct":true},
      {"id":"b","label":"Une remise commerciale accordée au client pour paiement comptant","is_correct":false},
      {"id":"c","label":"L'annulation pure et simple de la créance","is_correct":false},
      {"id":"d","label":"Le paiement de la facture en plusieurs mensualités","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-b','qcm-v1'], 'CAPA-LOURD-B-QCM-09', false,
    $mft$L'escompte transforme une créance à terme en trésorerie immédiate : la banque se rembourse à l'échéance auprès du tiré. À ne pas confondre avec l'escompte commercial (remise pour paiement anticipé).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Dans quel délai un créancier doit-il déclarer sa créance après l'ouverture d'une procédure collective de son client ?$mft$,
    $mft$[
      {"id":"a","label":"1 mois à compter du jugement","is_correct":false},
      {"id":"b","label":"2 mois à compter de la publication du jugement au BODACC","is_correct":true},
      {"id":"c","label":"6 mois à compter de la dernière facture","is_correct":false},
      {"id":"d","label":"Aucun délai : la déclaration est facultative","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-b','qcm-v1'], 'CAPA-LOURD-B-QCM-10', false,
    $mft$Deux mois à compter de la publication au BODACC (délai porté à quatre mois pour les créanciers hors métropole). Créance non déclarée = inopposable à la procédure : le transporteur créancier doit surveiller les publications.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Qu'est-ce que la « période suspecte » dans une procédure collective ?$mft$,
    $mft$[
      {"id":"a","label":"La période entre la date de cessation des paiements fixée par le tribunal et le jugement d'ouverture, pendant laquelle certains actes peuvent être annulés","is_correct":true},
      {"id":"b","label":"Les 45 jours accordés au dirigeant pour déclarer la cessation des paiements","is_correct":false},
      {"id":"c","label":"La période d'observation qui suit le jugement d'ouverture","is_correct":false},
      {"id":"d","label":"Le délai de 2 mois de déclaration des créances","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-b','qcm-v1'], 'CAPA-LOURD-B-QCM-11', false,
    $mft$Pendant la période suspecte, les actes anormaux (paiements de dettes non échues, donations, sûretés constituées pour dettes antérieures) peuvent être frappés de nullité afin de reconstituer l'actif.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Dans une location-gérance de fonds de commerce, qui exploite le fonds et à quel titre ?$mft$,
    $mft$[
      {"id":"a","label":"Le locataire-gérant, à ses risques et périls, contre une redevance versée au propriétaire","is_correct":true},
      {"id":"b","label":"Le propriétaire du fonds, pour le compte du locataire","is_correct":false},
      {"id":"c","label":"Un mandataire désigné par le tribunal de commerce","is_correct":false},
      {"id":"d","label":"Le bailleur des murs commerciaux","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-b','qcm-v1'], 'CAPA-LOURD-B-QCM-12', false,
    $mft$La location-gérance dissocie propriété et exploitation : le locataire-gérant exploite en son nom et à ses risques, paie une redevance, et doit détenir ses propres autorisations de transport.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$À quels registres une société commerciale de transport doit-elle être immatriculée ?$mft$,
   $mft$Au registre du commerce et des sociétés (RCS) et au registre national des entreprises (RNE), en plus du registre des transporteurs pour l'activité.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-b','question-courte'], 'CAPA-LOURD-B-QC-01', false,
   $mft$Accepter RCS seul ou RCS + RNE ; le registre des transporteurs (module F) est un bonus de transversalité.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez deux formes de sociétés dans lesquelles la responsabilité des associés est limitée à leurs apports.$mft$,
   $mft$La SARL (ou EURL) et la SAS (ou SASU) ; la SA également.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-b','question-courte'], 'CAPA-LOURD-B-QC-02', false,
   $mft$Deux formes suffisent. La SNC est le contre-exemple (responsabilité indéfinie et solidaire).$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Qu'est-ce que la liquidation judiciaire ?$mft$,
   $mft$La procédure collective qui met fin à l'activité d'une entreprise en cessation des paiements dont le redressement est manifestement impossible, avec réalisation des actifs pour payer les créanciers.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-b','question-courte'], 'CAPA-LOURD-B-QC-03', false,
   $mft$Deux idées attendues : redressement impossible + réalisation des actifs (une cession d'entreprise reste possible).$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Dans quel délai la cessation des paiements doit-elle être déclarée au tribunal ?$mft$,
   $mft$Dans les 45 jours, sauf demande d'ouverture d'une conciliation dans ce délai.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-b','question-courte'], 'CAPA-LOURD-B-QC-04', false,
   $mft$Accepter « 45 jours » ; la nuance conciliation est un bonus.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Quelles sont les deux grandes catégories d'éléments composant un fonds de commerce ? Donnez un exemple de chaque.$mft$,
   $mft$Les éléments incorporels (clientèle, droit au bail, nom commercial) et les éléments corporels (matériel, marchandises).$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-b','question-courte'], 'CAPA-LOURD-B-QC-05', false,
   $mft$Exiger les deux catégories + un exemple pertinent chacune. La clientèle est l'élément essentiel.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Définissez la location-gérance d'un fonds de commerce.$mft$,
   $mft$Le contrat par lequel le propriétaire d'un fonds le loue à un locataire-gérant qui l'exploite à ses risques et périls moyennant une redevance.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-b','question-courte'], 'CAPA-LOURD-B-QC-06', false,
   $mft$Trois éléments : location du fonds, exploitation aux risques du locataire, redevance.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Qu'est-ce que l'affacturage ?$mft$,
   $mft$La cession des factures clients à un factor qui finance immédiatement l'entreprise, gère le recouvrement et peut garantir les impayés, moyennant commissions.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-b','question-courte'], 'CAPA-LOURD-B-QC-07', false,
   $mft$Trois fonctions possibles du factor : financement, gestion du recouvrement, garantie. Deux sur trois suffisent avec l'idée de cession de factures.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quel est le régime social du gérant majoritaire de SARL ?$mft$,
   $mft$Travailleur non salarié (TNS), affilié à la sécurité sociale des indépendants.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-b','question-courte'], 'CAPA-LOURD-B-QC-08', false,
   $mft$Accepter « TNS » ou « indépendant ». Le président de SAS est, lui, assimilé salarié.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Après la publication au BODACC du jugement d'ouverture d'une procédure collective, de quel délai dispose un créancier pour déclarer sa créance ?$mft$,
   $mft$Deux mois à compter de la publication au BODACC.$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-b','question-courte'], 'CAPA-LOURD-B-QC-09', false,
   $mft$Sanction du retard : créance inopposable à la procédure (sauf relevé de forclusion).$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Pourquoi l'acquéreur d'un fonds de commerce de transport ne peut-il pas exploiter avec la licence du vendeur ?$mft$,
   $mft$Parce que les autorisations de transport (inscription au registre, licences) sont personnelles et incessibles : l'acquéreur doit remplir les exigences d'accès et obtenir sa propre autorisation.$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-b','question-courte'], 'CAPA-LOURD-B-QC-10', false,
   $mft$Idée clé : caractère personnel des titres administratifs, par opposition aux éléments cessibles du fonds.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Présentez les principales obligations professionnelles du commerçant et expliquez, pour chacune, son utilité concrète pour une entreprise de transport.$mft$,
   $mft$Réponse modèle. 1) Immatriculation (RCS et RNE) : donne l'existence juridique opposable, conditionne bail commercial, appels d'offres et inscription au registre des transporteurs. 2) Tenue d'une comptabilité régulière (livre-journal, grand livre, inventaire, comptes annuels, conservation 10 ans) : outil de pilotage des coûts de revient et support de la preuve de la capacité financière exigée chaque année. 3) Compte bancaire dédié : traçabilité des flux, séparation des patrimoines. 4) Facturation conforme (mentions, numérotation continue, délais de paiement) : conditionne le recouvrement, les pénalités de retard et l'indemnité forfaitaire de 40 €. 5) Loyauté commerciale et transparence tarifaire. Le respect de ces obligations sécurise à la fois le statut de commerçant, l'autorisation de transport et la solvabilité apparente vis-à-vis des banques et donneurs d'ordre.$mft$,
   $mft$Barème /5 : au moins quatre obligations exactes (2 pts) ; utilité concrète reliée au transport pour chacune (2 pts) ; lien explicite avec la capacité financière ou le registre des transporteurs (1 pt). Erreurs fréquentes : confondre obligations du commerçant et exigences d'accès à la profession ; oublier la conservation des documents comptables.$mft$,
   5, 'facile', ARRAY['capa-lourd','module-b','question-redigee'], 'CAPA-LOURD-B-QR-01', false,
   $mft$Restitution appliquée, transversale avec le module F (capacité financière).$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un artisan transporteur en nom propre envisage de créer une société avec un investisseur minoritaire. Comparez SARL et SAS pour ce projet et recommandez une forme en justifiant.$mft$,
   $mft$Réponse modèle. Points communs : responsabilité limitée aux apports, capital libre, crédibilité renforcée. SARL : cadre légal encadré et protecteur, coûts de fonctionnement contenus ; gérant majoritaire au régime TNS (cotisations plus faibles, protection moindre) ; cessions de parts encadrées (agrément), ce qui protège contre l'entrée de tiers mais rigidifie la sortie de l'investisseur. SAS : liberté statutaire (gouvernance sur mesure, actions de préférence, clauses d'entrée/sortie, pacte d'associés), président assimilé salarié (meilleure couverture, coût supérieur) ; instrument privilégié quand un investisseur entre au capital et exige des clauses financières précises. Recommandation argumentée : la SAS, car le projet intègre un investisseur minoritaire dont les droits (information, sortie, anti-dilution) se calibrent finement dans les statuts ; le fondateur conserve le contrôle opérationnel comme président. La SARL resterait défendable si la priorité était la minimisation des charges sociales du dirigeant majoritaire.$mft$,
   $mft$Barème /5 : comparaison exacte sur au moins trois critères pertinents (responsabilité, statut social du dirigeant, souplesse/cessions) (3 pts) ; recommandation cohérente avec le contexte investisseur (1,5 pt) ; nuance montrant les limites du choix écarté (0,5 pt). Erreurs fréquentes : affirmer qu'une forme dispense d'autorisation de transport ; croire le président de SAS couvert par l'assurance chômage.$mft$,
   5, 'facile', ARRAY['capa-lourd','module-b','question-redigee'], 'CAPA-LOURD-B-QR-02', false,
   $mft$Comparaison décisionnelle classique, contextualisée transport.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Cas pratique. Vous rachetez le fonds de commerce d'un transporteur régional (clientèle, 8 ensembles routiers, local en bail commercial, 12 conducteurs). Établissez la liste des points de vigilance juridiques de l'opération, dans l'ordre chronologique.$mft$,
   $mft$Réponse modèle. 1) Audit préalable : consistance de la clientèle (contrats clients transmissibles ?), état du matériel, situation sociale (les contrats de travail suivent le fonds de plein droit), litiges en cours, inscriptions de nantissement sur le fonds. 2) Capacité d'exploiter : engager AVANT l'acte la démarche d'autorisation DREAL à son nom (les licences du vendeur sont incessibles) : gestionnaire de transport, capacité financière calibrée sur 8 véhicules lourds (9 000 € + 7 × 5 000 € = 44 000 €), honorabilité. 3) Bail commercial : agrément éventuel du bailleur, destination des locaux compatible (stationnement PL), état des charges. 4) Acte de cession : prix ventilé, garantie d'actif et de passif ou clause de non-concurrence du vendeur, sort des contrats en cours. 5) Formalités : information préalable des salariés (PME), publicité de la cession, séquestre du prix pendant les oppositions des créanciers, inscription modificative aux registres. 6) Après reprise : bascule des assurances, mise à jour des copies conformes à hauteur de la flotte, information des clients.$mft$,
   $mft$Barème /5 : incessibilité des autorisations + démarche DREAL anticipée avec calcul de capacité financière (1,5 pt) ; reprise de plein droit des contrats de travail (1 pt) ; formalités de cession (publicité, séquestre, information salariés) (1,5 pt) ; bail et non-concurrence (0,5 pt) ; chronologie cohérente (0,5 pt). Erreurs fréquentes : croire les licences transmises avec le fonds ; oublier les salariés ; verser le prix sans séquestre.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-b','question-redigee'], 'CAPA-LOURD-B-QR-03', false,
   $mft$Cas de reprise complet, transversal modules B et F.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Votre entreprise subit des tensions de trésorerie durables mais n'est pas en cessation des paiements. Décrivez la gradation des dispositifs de traitement des difficultés jusqu'à la liquidation, en précisant quand la cessation des paiements doit être déclarée.$mft$,
   $mft$Réponse modèle. Phase amiable et confidentielle : mandat ad hoc (mandataire nommé par le président du tribunal pour aider à négocier) puis conciliation (possible tant que la cessation des paiements ne dure pas depuis plus de 45 jours ; accord constaté ou homologué). Phase judiciaire préventive : sauvegarde, ouverte sans cessation des paiements en cas de difficultés insurmontables : période d'observation, gel du passif antérieur, plan de sauvegarde. Si la cessation des paiements survient (actif disponible insuffisant pour le passif exigible), déclaration au tribunal dans les 45 jours : redressement judiciaire si le rétablissement est possible (poursuite d'activité, plan de redressement ou cession), liquidation judiciaire si le redressement est manifestement impossible (réalisation des actifs). Enjeux dirigeant : déclarer à temps (sinon faute de gestion), utiliser l'amiable tôt, protéger l'exploitation (les créances postérieures utiles sont payées par priorité).$mft$,
   $mft$Barème /5 : gradation complète amiable → sauvegarde → RJ → LJ (2 pts) ; définition correcte de la cessation des paiements (1 pt) ; délai de déclaration de 45 jours situé au bon moment (1 pt) ; critères d'orientation RJ vs LJ (1 pt). Erreurs fréquentes : placer la sauvegarde après la cessation des paiements ; confondre conciliation et redressement.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-b','question-redigee'], 'CAPA-LOURD-B-QR-04', false,
   $mft$Vue d'ensemble du livre VI orientée décision du dirigeant.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Votre entreprise de transport facture 180 000 € par mois à 60 jours et supporte un besoin de trésorerie chronique. Analysez l'intérêt et les limites de l'affacturage pour ce profil, puis listez les points à négocier avec le factor.$mft$,
   $mft$Réponse modèle. Intérêt : l'affacturage convertit immédiatement les factures en trésorerie (financement de l'ordre du montant facturé moins retenues), externalise relances et recouvrement (gain administratif sur de nombreuses petites factures typiques du transport), et peut inclure une garantie contre l'insolvabilité des clients : le besoin chronique lié aux 60 jours est directement traité. Limites : coût complet (commission de financement indexée + commission de service + participation à un fonds de garantie) ; retenue de garantie qui réduit le financement effectif ; clients parfois notés ou refusés par le factor ; dépendance au dispositif et image vis-à-vis de certains donneurs d'ordre. Points à négocier : périmètre des clients cédés (contrat global ou sélectif), taux et assiette des commissions, niveau de la retenue de garantie, gestion déléguée ou mandatée des relances, garantie avec ou sans recours, préavis de sortie, interfaçage avec la facturation.$mft$,
   $mft$Barème /5 : mécanisme correctement décrit (1 pt) ; adéquation argumentée au profil 60 jours/volume (1 pt) ; au moins trois limites réelles (1,5 pt) ; au moins quatre points de négociation pertinents (1,5 pt). Erreurs fréquentes : confondre affacturage et escompte ; croire la garantie d'impayé systématique ; ignorer le coût complet.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-b','question-redigee'], 'CAPA-LOURD-B-QR-05', false,
   $mft$Analyse financière appliquée au poste clients du transporteur.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Comparez la lettre de change et le chèque comme instruments de paiement entre professionnels : mécanisme, échéance, garanties et usage pertinent.$mft$,
   $mft$Réponse modèle. Lettre de change : le tireur (créancier) donne l'ordre au tiré (débiteur) de payer une somme à une échéance future au bénéficiaire ; instrument de crédit par excellence : elle matérialise un délai de paiement, peut être acceptée par le tiré (engagement cambiaire renforcé), endossée, avalisée (garantie d'un tiers) et escomptée en banque pour obtenir de la trésorerie immédiate. Chèque : ordre de paiement à vue sur une banque, payable dès présentation : aucun crédit, la provision doit être disponible et suffisante à l'émission ; l'émission sans provision expose à l'interdiction bancaire ; garanties limitées (pas d'acceptation). Usage pertinent : la lettre de change (ou le billet à ordre) pour organiser contractuellement des échéances avec des clients réguliers et mobiliser la créance par escompte ; le chèque pour des règlements immédiats, en déclin face au virement. Dans les deux cas, rigueur d'encaissement et suivi des impayés (protêt pour l'effet de commerce).$mft$,
   $mft$Barème /5 : mécanismes exacts des deux instruments (2 pts) ; opposition à vue / à échéance (1 pt) ; garanties propres à l'effet de commerce (acceptation, aval, escompte) (1,5 pt) ; conclusion d'usage pertinente (0,5 pt). Erreurs fréquentes : croire le chèque payable à une date future (post-daté sans effet) ; confondre aval et endossement.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-b','question-redigee'], 'CAPA-LOURD-B-QR-06', false,
   $mft$Comparaison technique des instruments de paiement du poste clients.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas professionnel. Vous apprenez par le BODACC que votre client GrandDistrib, qui vous doit 26 400 € de prestations livrées, est placé en redressement judiciaire. Trois transports sont en cours pour lui, marchandises encore dans vos entrepôts. Analysez la situation et bâtissez votre plan d'action de créancier.$mft$,
   $mft$Réponse modèle. Qualification : la créance de 26 400 € est antérieure au jugement d'ouverture : elle est gelée (interdiction des paiements, arrêt des poursuites individuelles) et doit être déclarée au mandataire judiciaire dans les deux mois de la publication au BODACC, sous peine d'inopposabilité. Les prestations en cours : le contrat peut se poursuivre (option de l'administrateur sur les contrats en cours) ; les prestations postérieures utiles à la procédure sont payées à échéance ou par privilège : exiger la confirmation de la poursuite et, à défaut de paiement comptant, sécuriser. Levier clé : le droit de rétention du voiturier sur les marchandises détenues au titre des transports impayés concernés ; l'exercer avec discernement (créances liées aux opérations, pas de voie de fait) et le faire valoir dans la procédure. Plan d'action : 1) déclarer la créance (justificatifs : factures, CMR, bons de livraison) ; 2) écrire à l'administrateur pour la poursuite des contrats en cours et les conditions de paiement ; 3) notifier l'exercice du droit de rétention ; 4) basculer les nouvelles prestations en paiement comptant ou garanti ; 5) suivre le plan (redressement, cession) et ajuster l'encours client.$mft$,
   $mft$Barème /5 : gel de la créance antérieure + déclaration sous 2 mois (1,5 pt) ; sort des contrats en cours et statut des créances postérieures (1,5 pt) ; mobilisation pertinente et prudente du droit de rétention (1 pt) ; plan d'action ordonné et réaliste (1 pt). Erreurs fréquentes : continuer à livrer sans garantie ; exercer une rétention sur des marchandises étrangères aux transports impayés ; oublier la déclaration de créance.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-b','question-redigee'], 'CAPA-LOURD-B-QR-07', false,
   $mft$Cas de synthèse procédures collectives côté créancier transporteur, transversal module A (droit de rétention).$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$« Entre commerçants, la preuve est libre. » Expliquez cette règle, ses justifications et ses conséquences pratiques pour l'organisation documentaire d'une entreprise de transport.$mft$,
   $mft$Réponse modèle. Règle : contre un commerçant, les actes de commerce se prouvent par tous moyens (factures, correspondances, courriels, bons de livraison, données télématiques), sans exiger d'écrit signé ni respecter les seuils de preuve civils. Justifications : rapidité et volume des affaires, confiance nécessaire aux transactions répétées, existence d'une comptabilité obligatoire qui peut faire preuve. Limites : la liberté de la preuve ne dispense pas de convaincre le juge (fiabilité, datation) et certains actes restent soumis à des écrits (cession de fonds, cautionnement). Conséquences pratiques : tout document d'exploitation devient un actif probatoire : faire émarger systématiquement les bons de livraison et lettres de voiture, horodater et archiver les courriels d'instruction, conserver les enregistrements de prise de commande, sécuriser l'archivage (10 ans pour les pièces comptables), tracer les réserves à la livraison. Une entreprise qui archive bien gagne ses litiges de facturation ; une entreprise qui archive mal les perd, même de bonne foi.$mft$,
   $mft$Barème /5 : énoncé exact de la règle et de son champ (1,5 pt) ; deux justifications (1 pt) ; au moins une limite (écrits exigés ou force probante) (1 pt) ; conséquences documentaires concrètes pour le transport (1,5 pt). Erreurs fréquentes : étendre la liberté de preuve aux litiges contre un non-commerçant ; en déduire qu'aucun écrit n'est jamais nécessaire.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-b','question-redigee'], 'CAPA-LOURD-B-QR-08', false,
   $mft$Argumentation sur une règle cardinale du droit commercial, appliquée à la documentation d'exploitation.$mft$);

  RAISE NOTICE 'Module B Capa lourd créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $capab$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Volumes : select "type", active, count(*) from question_bank
--     where source_ref like 'CAPA-LOURD-B-%' group by 1, 2;
--    → attendu : qcm/false = 12, qr/false = 18.
-- 2) QCM à bonne réponse unique :
--    select source_ref from question_bank
--     where source_ref like 'CAPA-LOURD-B-QCM-%'
--       and (select count(*) from jsonb_array_elements(choices) c
--             where (c->>'is_correct')::boolean) <> 1;   → 0 ligne.
-- 3) Doublons d'énoncés sur la formation :
--    select statement, count(*) from question_bank
--     where formation_id = (select id from formations where slug='capacite-plus-3-5t')
--     group by 1 having count(*) > 1;                    → 0 ligne.
