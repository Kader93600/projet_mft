-- =====================================================================
-- COMMISSIONNAIRE DE TRANSPORT : MODULE 6 (FINAL)
-- PRÉPARATION À L'ÉVALUATION + 2 ÉVALUATIONS BLANCHES : v1 (juillet 2026)
--
-- ⚠ PRÉREQUIS : appliquer d'abord les modules 1 à 5 (COMM-M1 à COMM-M5).
--   Les évaluations blanches sont composées de questions EXISTANTES de
--   la banque (liaison par source_ref, aucune duplication) : si un
--   module manque, l'évaluation blanche sera partielle (NOTICE l'indique).
--
-- Contenu :
--   - 1 leçon : méthode des cas pratiques + tableau de synthèse M1-M5
--     + paires piégeuses + planning des derniers jours
--   - 10 questions transversales de synthèse (6 QC + 4 QR), à valider
--   - Évaluation blanche 1 : 20 QCM (4 par module), 30 min, seuil 60 %
--   - Évaluation blanche 2 : mixte 10 QCM + 5 QR, 90 min, seuil 60 %
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $commm6$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l uuid;
  v_eb1 uuid;
  v_eb2 uuid;
  v_count int;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'commissionnaire';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation commissionnaire introuvable.';
  END IF;

  INSERT INTO public.blocs (id, code, title, description, "order")
  VALUES (80, 'COMMISSIONNAIRE', 'Commissionnaire de transport',
          'Le métier de commissionnaire de transport : contrat de commission, responsabilités, organisation multimodale, douane et Incoterms, gestion et assurances.', 80)
  ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'COMMISSIONNAIRE';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'COMM-M6-%';
  DELETE FROM public.modules WHERE slug = 'comm-preparation';

  -- ═══════════════ MODULE 6 : PRÉPARATION À L'ÉVALUATION ═══════════════
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module 6 : Préparation à l''évaluation',
    'comm-preparation',
    v_bloc,
    'Méthode d''évaluation, synthèse des cinq modules du métier de commissionnaire et deux évaluations blanches en conditions.',
    'avance',
    180,
    60
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 60, true);

  -- ─── Leçon unique : réussir l'évaluation ────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'reussir-evaluation-comm',
    'Réussir l''évaluation : méthode et synthèse des cinq modules',
    $mft$> 🎯 **Objectifs**
> - Appliquer la méthode des cas pratiques : qualifier, dérouler, conclure.
> - Réviser en une page les points clés des modules 1 à 5.
> - Dérouler le planning des derniers jours avant l'évaluation.

## La méthode des cas pratiques

L'évaluation du commissionnaire se joue sur des cas concrets : un flux à organiser, un litige à dénouer, un Incoterm à recommander. Trois réflexes structurent presque toutes les réponses :

1. **Qualifier le contrat** : commission ou mandat ? La qualification ne se lit pas dans l'intitulé du document mais dans un **faisceau d'indices** : action en nom propre, liberté du choix des voies et des moyens, prix global. Tout le régime de responsabilité en découle : c'est TOUJOURS la première étape.
2. **Dérouler la chaîne des responsabilités et des délais** : qui répond (fait personnel ou garantie des substitués), envers qui, dans quel délai. Côté commettant, la prescription est d'**un an** ; côté transporteurs substitués, les délais de recours sont **propres à chaque mode** : les vérifier avant d'agir, jamais de mémoire.
3. **Choisir l'Incoterm** : identifier la famille (E, F, C, D), puis séparer systématiquement les deux curseurs : qui paie les **frais**, qui porte le **risque**. Une phrase pour chacun, jamais une phrase pour les deux.

Et pour rédiger, une seule ossature, quel que soit le sujet :

:::flow
1. Règle | Énoncer la règle applicable (qualification, fondement, principe)
2. Application | L'appliquer aux faits du cas, étape par étape
3. Conclusion | Répondre explicitement à la question posée
:::

## Le tableau de synthèse des cinq modules

| Module | L'essentiel à mobiliser |
| --- | --- |
| 1 : Le métier | Le commissionnaire organise le transport **en son nom propre** pour le compte du commettant ; qualification par **faisceau d'indices** (liberté d'organisation, choix des substitués, prix global) ; conditions d'accès à la profession : régime réformé, version applicable à vérifier avec votre formateur |
| 2 : Responsabilités | Double fondement : **fait personnel** (sa propre faute d'organisation) + **garantie des substitués** (il répond des transporteurs qu'il a choisis, à charge de recours contre eux) ; prescription **1 an** ; délais de recours **par mode** : chaque mode a le sien |
| 3 : Multimodal | Route internationale : plafond CMR **8,33 DTS/kg** (le DTS, unité de compte) ; **connaissement maritime négociable** (il représente la marchandise, sa remise conditionne la livraison) vs **LTA non négociable** (preuve du contrat) ; chaque segment a son document et son plafond |
| 4 : Incoterms et douane | Quatre familles **E, F, C, D** ; piège des C : **frais payés jusqu'à destination mais risque transféré au départ** ; **CIF : assurance souscrite par le vendeur** ; douane : numéro **EORI**, triptyque **espèce, origine, valeur**, transit externe **T1**, **autoliquidation de la TVA à l'import** |
| 5 : Gestion | **Vigilance sur les sous-traitants** (référencement, vérifications tracées, suivi) ; **trois étages d'assurance** (responsabilité du transporteur, responsabilité du commissionnaire, ad valorem sur la marchandise) ; **ad valorem proposée par écrit** (preuve du refus conservée) ; **débours** avancés pour le client = **BFR** à surveiller |

> 📌 **À retenir : les paires piégeuses**
> - **Commissionnaire vs mandataire** : nom propre et liberté d'organisation d'un côté, action au nom du client de l'autre : la responsabilité change du tout au tout.
> - **CIF, frais vs risques** : le vendeur paie le transport (et l'assurance) jusqu'au port de destination, mais le risque passe à l'acheteur dès l'embarquement : deux curseurs, deux réponses.
> - **RC du transporteur vs ad valorem** : la responsabilité du transporteur est plafonnée (8,33 DTS/kg en CMR) ; seule l'assurance ad valorem couvre la **valeur réelle** déclarée.

> ⚠️ **Attention**
> Les conditions d'accès à la profession (module 1) ont été réformées : vérifiez avec votre formateur la version des textes applicable à votre session. Et à l'évaluation, ne citez jamais un chiffre dont vous doutez : une règle énoncée juste sans chiffre vaut mieux qu'un chiffre faux.

## Les derniers jours

:::timeline
1. **J-10 à J-6** : Évaluation blanche 1 (QCM) sans documents ; retour ciblé sur les deux modules les plus faibles ; relire les corrections et les explications, pas les leçons entières.
2. **J-5 à J-3** : Évaluation blanche 2 (mixte) en conditions réelles : rédiger réellement, chronomètre en marche ; confronter chaque réponse au barème, ligne à ligne.
3. **J-2** : Une seule page : le tableau de synthèse et les paires piégeuses ; refaire PAR ÉCRIT une question rédigée ratée.
4. **J-1** : Révision légère, logistique du jour J (trajet, convocation, matériel), coucher tôt.
5. **Jour J** : QCM en trois passes (certitudes, éliminations, inconnues en dernier) ; rédigé : règle, application, conclusion ; garder cinq minutes de relecture.
:::

## Derniers conseils

- **Lisez chaque question deux fois** : « qualifier », « conseiller », « chiffrer » appellent trois livrables différents.
- **Annoncez la qualification d'abord** : commission ou mandat, tout le raisonnement en découle.
- **Séparez frais et risques** dans toute question Incoterms : c'est là que se perdent le plus de points.
- **Ne rendez jamais une réponse vide** : la règle seule rapporte déjà des points.

## ✅ Synthèse

- Trois réflexes : **qualifier le contrat, dérouler responsabilités et délais, choisir l'Incoterm**.
- Un seul support de révision finale : **le tableau des cinq modules** et les paires piégeuses.
- Rédigé : **règle, application, conclusion** ; jamais de réponse vide.$mft$,
    $mft$La méthode des cas pratiques (qualifier le contrat, dérouler responsabilités et délais, choisir l'Incoterm), le tableau de synthèse des modules 1 à 5, les paires piégeuses (commissionnaire/mandataire, CIF frais/risques, RC transporteur/ad valorem) et le planning des derniers jours.$mft$,
    1, 45) RETURNING id INTO v_l;

  -- ─── Questions transversales de synthèse (6 QC) ─────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l, 'qr',
   $mft$Un chargeur hésite entre confier son flux à votre société ou à un simple mandataire. En une phrase, qu'est-ce qui distingue juridiquement le commissionnaire du mandataire ?$mft$,
   $mft$Le commissionnaire organise le transport en son nom propre pour le compte du commettant (avec liberté du choix des voies et des moyens), alors que le mandataire agit au nom et pour le compte de son client : les régimes de responsabilité en découlent.$mft$,
   2, 'facile', ARRAY['commissionnaire','module-6','question-courte'], 'COMM-M6-QC-01', false,
   $mft$La qualification s'apprécie par un faisceau d'indices, pas par l'intitulé du contrat.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Une palette est détruite par le transporteur routier que vous aviez affrété. Le commettant vous met en cause directement : sur quel fondement, et de quel recours disposez-vous ensuite ?$mft$,
   $mft$Sur la garantie du fait des substitués : le commissionnaire répond envers le commettant des transporteurs qu'il a choisis, à charge pour lui d'exercer ensuite un recours contre le transporteur fautif.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-6','question-courte'], 'COMM-M6-QC-02', false,
   $mft$À distinguer du fait personnel, qui sanctionne la propre faute d'organisation du commissionnaire.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Un commettant vous réclame l'indemnisation d'une avarie survenue il y a quatorze mois, sans aucune action ni acte interruptif entre-temps. Que lui opposez-vous ?$mft$,
   $mft$La prescription : les actions nées du contrat de commission de transport se prescrivent par un an ; à quatorze mois sans interruption, la demande est prescrite.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-6','question-courte'], 'COMM-M6-QC-03', false,
   $mft$Réflexe de gestion des litiges : vérifier aussi, côté recours, les délais propres à chaque mode.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$À l'import maritime, pourquoi le connaissement occupe-t-il une place à part parmi les documents de transport, comparé à la LTA aérienne ?$mft$,
   $mft$Parce qu'il peut être négociable : il représente la marchandise et sa remise conditionne la livraison, alors que la LTA n'est pas négociable (elle vaut preuve du contrat de transport).$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-6','question-courte'], 'COMM-M6-QC-04', false,
   $mft$Le circuit du connaissement (souvent bancaire) se sécurise ; celui de la LTA non négociable est plus simple.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Votre client importe pour la première fois depuis un pays hors Union européenne. Citez le numéro d'identification dont il doit disposer et les trois éléments de la déclaration qui déterminent les droits et taxes.$mft$,
   $mft$Le numéro EORI ; les trois éléments déclaratifs : l'espèce tarifaire, l'origine et la valeur en douane.$mft$,
   2, 'difficile', ARRAY['commissionnaire','module-6','question-courte'], 'COMM-M6-QC-05', false,
   $mft$Le triptyque espèce, origine, valeur est attendu au complet, correctement nommé.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Un commettant expédie des marchandises d'une valeur très supérieure aux plafonds de responsabilité. Quelle précaution prenez-vous sur l'assurance, et pourquoi sous cette forme ?$mft$,
   $mft$Proposer PAR ÉCRIT une assurance ad valorem (valeur réelle déclarée) et conserver la preuve de l'acceptation ou du refus : en cas de sinistre, le refus écrit démontre que le client savait que seuls les plafonds s'appliqueraient.$mft$,
   2, 'difficile', ARRAY['commissionnaire','module-6','question-courte'], 'COMM-M6-QC-06', false,
   $mft$L'écrit est probatoire : une proposition orale ne protège pas le commissionnaire.$mft$);

  -- ─── Questions rédigées transversales (4 QR, barème /5) ─────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l, 'qr',
   $mft$Cas de synthèse. Textile Rhône vous confie l'acheminement de 12 palettes vers Milan : vous choisissez librement le transporteur routier et facturez un prix global en votre nom. Une avarie survient pendant le transport. Le client soutient que vous n'êtes qu'un mandataire non responsable, puis laisse traîner sa réclamation. Qualifiez le contrat, déroulez la chaîne des responsabilités et rappelez les délais qui encadrent l'affaire.$mft$,
   $mft$Réponse modèle. Règle : la qualification ne dépend pas de l'intitulé mais d'un faisceau d'indices : organisation libre du transport, choix des voies et des moyens, prix global, action en nom propre. Application : ici, tous les indices convergent : liberté de choix du transporteur, prix global, facturation en nom propre : c'est un contrat de commission de transport, pas un mandat (le mandataire agit au nom du client et n'organise pas librement). Responsabilités : le commissionnaire répond de son fait personnel (faute propre d'organisation) et garantit le fait des transporteurs substitués : le commettant peut donc le rechercher pour l'avarie du routier, à charge pour le commissionnaire d'exercer son recours contre le transporteur effectif. Délais : la prescription des actions nées du contrat est d'un an : le client qui « laisse traîner » joue contre lui-même ; et le recours contre le transporteur obéit aux délais propres au mode routier, à vérifier avant toute action : réserves, notifications et dossier documenté (lettre de voiture, photos) à constituer immédiatement. Conclusion : contrat de commission, responsabilité envers le commettant sur les deux fondements, recours contre le routier à préserver sans attendre.$mft$,
   $mft$Barème /5 : qualification par faisceau d'indices avec les indices du cas cités (1,5 pt) ; distinction claire avec le mandataire (0,5 pt) ; double fondement fait personnel + garantie des substitués, avec le recours à charge (1,5 pt) ; délais : prescription d'un an et délais de recours propres au mode, avec la conséquence pratique (agir vite, documenter) (1,5 pt). Erreurs fréquentes : s'arrêter à l'intitulé du contrat ; oublier de préserver le recours contre le transporteur effectif.$mft$,
   5, 'difficile', ARRAY['commissionnaire','module-6','question-redigee'], 'COMM-M6-QR-01', false,
   $mft$Cas transversal modules 1 et 2 : qualification, chaîne des responsabilités, délais.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Conseil client. Un industriel exporte des machines vers la Corée par voie maritime. Il veut « payer le transport principal pour garder la main sur la logistique » mais « ne plus porter aucun risque dès que la marchandise a quitté son usine ». Il pense que CIF répond à ses deux attentes. Analysez sa demande (règle, application, conclusion) et conseillez-le.$mft$,
   $mft$Réponse modèle. Règle : les Incoterms se lisent en quatre familles E, F, C, D, avec deux curseurs distincts : qui paie les frais et qui porte le risque. Le piège de la famille C : le vendeur paie le transport principal jusqu'à destination, mais le risque est transféré à l'acheteur dès le départ (à l'embarquement) ; en CIF, le vendeur souscrit en outre l'assurance pour le voyage. Application : l'attente n° 1 est satisfaite : en CIF, c'est bien lui qui achète et paie le transport principal, donc il garde la main sur l'organisation. L'attente n° 2 ne l'est qu'en partie : le risque ne passe pas à la sortie de l'usine mais à l'embarquement sur le navire : entre l'usine et le port, le pré-acheminement voyage à ses risques. En revanche, dès l'embarquement, le risque est chez l'acheteur, ce qui est plus favorable qu'il ne le croit pour la traversée. Conclusion : CIF est un bon choix pour son besoin, à deux conditions : lui expliquer le point exact de transfert du risque (l'embarquement, pas l'usine) et l'obligation d'assurance qui pèse sur lui en tant que vendeur ; consigner ce conseil par écrit.$mft$,
   $mft$Barème /5 : familles E, F, C, D et distinction frais/risques posées en règle (1,5 pt) ; piège des C explicité : frais jusqu'à destination, risque transféré au départ (1,5 pt) ; CIF : assurance souscrite par le vendeur (1 pt) ; conclusion nuancée avec le point exact de transfert (embarquement, pas l'usine) et le conseil tracé par écrit (1 pt). Erreurs fréquentes : confondre transfert des frais et transfert des risques ; croire qu'en CIF le vendeur porte le risque jusqu'au port de destination.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-6','question-redigee'], 'COMM-M6-QR-02', false,
   $mft$Cas transversal module 4 : choisir et expliquer un Incoterm de la famille C sans confondre les deux curseurs.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Cas d'organisation. Vous montez un flux Shanghai vers Clermont-Ferrand pour un importateur français : conteneur maritime jusqu'au Havre, puis route. Le client veut dédouaner au plus près de chez lui et préserver sa trésorerie sur la TVA d'importation. Décrivez le montage documentaire et douanier, du connaissement à la livraison.$mft$,
   $mft$Réponse modèle. Documents de transport : au départ, un connaissement maritime, le cas échéant négociable : il représente la marchandise et sa remise conditionne la livraison, son circuit (souvent bancaire) se sécurise ; sur le segment routier, une lettre de voiture, en gardant à l'esprit que chaque mode a son régime de responsabilité (en route internationale, plafond CMR de 8,33 DTS par kilogramme). Douane : l'importateur doit disposer d'un numéro EORI ; la déclaration repose sur le triptyque espèce, origine, valeur. Pour dédouaner au plus près du client, la marchandise circule non dédouanée depuis Le Havre sous transit externe T1 jusqu'au bureau de douane intérieur proche de Clermont-Ferrand, où la déclaration d'importation est déposée. Trésorerie : l'autoliquidation de la TVA à l'import permet de déclarer et de déduire la TVA sur la déclaration de TVA, sans décaissement au moment du dédouanement : c'est exactement la réponse à la contrainte du client. Livraison : contrôles et réserves à chaque rupture de charge, documents archivés. Conclusion : le montage T1 + autoliquidation répond aux deux demandes ; le commissionnaire sécurise le connaissement, les trois éléments déclaratifs et la chaîne documentaire de bout en bout.$mft$,
   $mft$Barème /5 : connaissement maritime et son caractère négociable maîtrisés (1 pt) ; EORI et triptyque espèce, origine, valeur (1,5 pt) ; transit externe T1 correctement employé pour dédouaner à l'intérieur (1,5 pt) ; autoliquidation de la TVA à l'import reliée à la trésorerie du client (1 pt). Erreurs fréquentes : dédouaner au port par réflexe alors que le client demande l'inverse ; confondre marchandise sous T1 et marchandise déjà dédouanée.$mft$,
   5, 'difficile', ARRAY['commissionnaire','module-6','question-redigee'], 'COMM-M6-QR-03', false,
   $mft$Cas transversal modules 3 et 4 : multimodal, documents, transit T1 et TVA à l'import.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Plan d'action. Après un sinistre coûteux (marchandise de grande valeur détruite chez un sous-traitant mal référencé, client indemnisé au seul plafond et furieux), votre direction vous demande un plan pour que cela ne se reproduise pas : référencement des sous-traitants, dispositif d'assurance à trois étages, pratique commerciale sur l'ad valorem, et maîtrise des débours. Construisez-le.$mft$,
   $mft$Réponse modèle. 1) Vigilance sous-traitance : référencer AVANT de confier (documents et capacités vérifiés, vérifications tracées), suivre et réévaluer périodiquement le panel : le commissionnaire garantit ses substitués, la qualité du panel est donc sa première protection ; le sous-traitant du sinistre est suspendu le temps de l'analyse. 2) Trois étages d'assurance à remettre d'équerre : la responsabilité du transporteur (plafonnée : en CMR, 8,33 DTS par kilogramme), la responsabilité civile du commissionnaire (son fait personnel et sa garantie des substitués), et l'assurance ad valorem sur la marchandise (valeur réelle déclarée) : chaque étage couvre un risque distinct, aucun ne remplace les autres. 3) Ad valorem : désormais proposée PAR ÉCRIT à tout client dont la valeur excède les plafonds, preuve de l'acceptation ou du refus conservée au dossier : c'est le refus documenté qui aurait protégé la relation dans le sinistre en cause. 4) Débours et BFR : le commissionnaire avance des sommes pour le compte de ses clients (transport acheté, frais) : chaque avance creuse le besoin en fonds de roulement : facturer sans délai, encadrer les encours par client, suivre un indicateur mensuel. Conclusion : quatre chantiers, chacun avec un responsable et une échéance.$mft$,
   $mft$Barème /5 : référencement et suivi des sous-traitants avec traçabilité (1,25 pt) ; trois étages d'assurance distingués avec le rôle de chacun (1,5 pt) ; ad valorem proposée par écrit avec la logique probatoire (1,25 pt) ; débours reliés au BFR avec des mesures concrètes (1 pt). Erreurs fréquentes : croire que la responsabilité du transporteur couvre la valeur réelle ; proposer l'ad valorem oralement ; oublier le volet trésorerie.$mft$,
   5, 'difficile', ARRAY['commissionnaire','module-6','question-redigee'], 'COMM-M6-QR-04', false,
   $mft$Cas transversal modules 2 et 5 : sous-traitance, étages d'assurance, ad valorem, débours.$mft$);

  -- ═══════ ÉVALUATION BLANCHE 1 : QCM (20 questions, 30 min) ═══════════
  -- Composée de questions EXISTANTES des modules 1 à 5 (4 par module),
  -- liées par source_ref : aucune duplication de contenu.
  INSERT INTO public.quizzes (module_id, title, description, "type", time_limit_s, pass_threshold, is_mock_exam, shuffle_questions)
  VALUES (v_module, 'Évaluation blanche 1 : QCM des cinq modules',
    'Conditions proches de l''évaluation : 20 QCM couvrant les modules 1 à 5 (4 par module), 30 minutes, seuil 60 %. À faire sans documents.',
    'examen', 1800, 60, true, true)
  RETURNING id INTO v_eb1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_eb1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN (
    'COMM-M1-QCM-02','COMM-M1-QCM-05','COMM-M1-QCM-08','COMM-M1-QCM-11',
    'COMM-M2-QCM-02','COMM-M2-QCM-05','COMM-M2-QCM-08','COMM-M2-QCM-11',
    'COMM-M3-QCM-02','COMM-M3-QCM-05','COMM-M3-QCM-08','COMM-M3-QCM-11',
    'COMM-M4-QCM-02','COMM-M4-QCM-05','COMM-M4-QCM-08','COMM-M4-QCM-11',
    'COMM-M5-QCM-02','COMM-M5-QCM-05','COMM-M5-QCM-08','COMM-M5-QCM-11'
  );
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE 'Évaluation blanche 1 : % questions liées sur 20 attendues (si < 20 : appliquer les modules 1 à 5).', v_count;

  -- ══════ ÉVALUATION BLANCHE 2 : mixte (10 QCM + 5 QR, 90 min) ═════════
  INSERT INTO public.quizzes (module_id, title, description, "type", time_limit_s, pass_threshold, is_mock_exam, shuffle_questions)
  VALUES (v_module, 'Évaluation blanche 2 : épreuve mixte (QCM + rédigé)',
    'Simulation du format complet : 10 QCM (2 par module) puis 5 questions rédigées (1 par module), 90 minutes, seuil 60 %. Rédigez réellement vos réponses : la correction s''appuie sur les barèmes.',
    'examen', 5400, 60, true, false)
  RETURNING id INTO v_eb2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_eb2, id, ROW_NUMBER() OVER (ORDER BY (source_ref LIKE '%-QR-%'), source_ref)
  FROM public.question_bank
  WHERE source_ref IN (
    'COMM-M1-QCM-03','COMM-M1-QCM-09',
    'COMM-M2-QCM-03','COMM-M2-QCM-09',
    'COMM-M3-QCM-03','COMM-M3-QCM-09',
    'COMM-M4-QCM-03','COMM-M4-QCM-09',
    'COMM-M5-QCM-03','COMM-M5-QCM-09',
    'COMM-M1-QR-03','COMM-M2-QR-03','COMM-M3-QR-03',
    'COMM-M4-QR-03','COMM-M5-QR-03'
  );
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE 'Évaluation blanche 2 : % questions liées sur 15 attendues (10 QCM + 5 QR).', v_count;

  -- Rattachement des évaluations blanches au niveau formation
  INSERT INTO public.formation_quizzes (formation_id, quiz_id, is_mock_exam, display_order)
  VALUES (v_formation, v_eb1, true, 60), (v_formation, v_eb2, true, 61);

  RAISE NOTICE 'Module 6 commissionnaire créé : module %, 1 leçon, 6 QC + 4 QR transversales (inactives, à valider) + 2 évaluations blanches.', v_module;
END $commm6$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Les 2 évaluations blanches et leur composition :
--    select q.title, count(qqb.question_id) as nb_questions
--      from quizzes q left join quiz_question_bank qqb on qqb.quiz_id = q.id
--     where q.is_mock_exam and q.module_id in
--           (select id from modules where slug = 'comm-preparation')
--     group by q.title;   → 20 et 15.
-- 2) Questions transversales : select "type", active, count(*)
--      from question_bank where source_ref like 'COMM-M6-%'
--     group by 1, 2;      → qr/false = 10.
-- 3) Module et leçon du lot :
--    select m.slug, count(l.id) as lecons from modules m
--      left join lessons l on l.module_id = m.id
--     where m.slug = 'comm-preparation'
--     group by m.slug;    → 1 leçon.
