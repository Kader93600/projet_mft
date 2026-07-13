-- =====================================================================
-- CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : MODULE D : DROIT FISCAL : v1
-- (juillet 2026) : LOT 5
--
-- Domaine D de l'annexe I du règlement (CE) n° 1071/2009 : TVA des
-- prestations de transport, fiscalité des carburants (TICPE) et des
-- véhicules (taxe à l'essieu), imposition des bénéfices (IR/IS),
-- impôts locaux (CFE/CVAE), obligations déclaratives.
-- ⚠ Les taux et barèmes fiscaux évoluent chaque loi de finances :
--   les chiffres mouvants sont signalés « à vérifier » au formateur.
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $capad$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'CAPA-LOURD-D-%';
  DELETE FROM public.modules WHERE slug = 'capa-lourd-droit-fiscal';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module D : Droit fiscal',
    'capa-lourd-droit-fiscal',
    v_bloc,
    'La fiscalité de l''entreprise de transport : TVA des prestations nationales et intracommunautaires, TICPE et remboursement gazole professionnel, taxe à l''essieu, imposition des bénéfices (IR/IS), CFE/CVAE et calendrier fiscal.',
    'intermediaire',
    540,
    40
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 40, true);

  -- ─── Leçon 1 : La TVA du transporteur ──────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'tva-du-transporteur',
    'La TVA du transporteur',
    $mft$> 🎯 **Objectifs**
> - Maîtriser le mécanisme collectée / déductible et la déclaration.
> - Facturer correctement un client français, européen ou hors UE.
> - Anticiper la facturation électronique obligatoire.

## Le mécanisme de la TVA

La TVA est un impôt sur la consommation, **neutre** pour l'entreprise assujettie : elle **collecte** la TVA sur ses ventes et **déduit** la TVA payée sur ses achats professionnels ; elle ne reverse que la différence.

> 📌 **À retenir**
> **TVA à payer = TVA collectée − TVA déductible.** Si la déductible excède la collectée, l'entreprise dispose d'un **crédit de TVA** (imputable ou remboursable).

## Les prestations de transport national

Le transport routier de marchandises en France est soumis au **taux normal de 20 %**. La facture mentionne le prix HT, le taux et le montant de TVA, le TTC.

### La TVA déductible du transporteur

- **Gazole et GNR** des poids lourds et véhicules utilitaires : TVA **déductible à 100 %** ;
- péages, réparations, pneumatiques, achats de matériel : déductibles s'ils sont engagés pour l'exploitation et correctement facturés ;
- restauration et hôtellerie des conducteurs en déplacement : déductibles dans les conditions habituelles (factures au nom de l'entreprise).

> ⚠️ **Attention**
> Pour les **véhicules de tourisme** de l'entreprise (voitures de service), la TVA sur le carburant n'est déductible qu'à **80 %** et la TVA sur l'achat du véhicule n'est pas déductible : ne pas mélanger les régimes PL et VP dans la comptabilité.

## Les prestations intracommunautaires et internationales

- **Transport intracommunautaire de biens pour un client assujetti (B2B)** : la prestation est localisée dans le pays du **preneur** ; le transporteur français facture **hors taxe** avec la mention « **autoliquidation** » et le numéro de TVA intracommunautaire du client, qui autoliquide la TVA dans son pays. Déclaration récapitulative des services à l'appui.
- **Transports liés à une exportation** (acheminement vers un port ou aéroport de sortie de l'UE, sous conditions documentaires) : **exonérés** de TVA.
- Vérifier systématiquement le **numéro de TVA intracommunautaire** du client (base VIES) avant de facturer HT.

## Déclarations et facturation électronique

Au régime réel normal, l'entreprise dépose une déclaration **CA3 mensuelle** (trimestrielle si la TVA annuelle est faible) et télérègle. La **facturation électronique** entre assujettis se généralise par étapes (réception pour tous, puis émission selon la taille de l'entreprise) : calendrier précis à vérifier, mais l'équipement (plateforme agréée, formats) se prépare dès maintenant.

## ✅ Synthèse

- **20 %** sur le transport national ; **TVA à payer = collectée − déductible**.
- Gazole PL : **100 % déductible** ; carburant des voitures de tourisme : 80 %.
- Intracommunautaire B2B : facture **HT + autoliquidation** (numéro TVA vérifié) ; transports liés à l'export : **exonérés**.
- CA3 mensuelle ; passage à la **facturation électronique** à anticiper.$mft$,
    $mft$Mécanisme collectée/déductible, taux 20 %, déductibilité du gazole PL à 100 %, autoliquidation intracommunautaire B2B, exonération des transports liés à l'export, CA3 et facturation électronique.$mft$,
    1, 50) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Carburants et fiscalité du véhicule ─────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'ticpe-taxe-essieu-vehicules',
    'TICPE, taxe à l''essieu : la fiscalité du véhicule',
    $mft$> 🎯 **Objectifs**
> - Comprendre la TICPE et actionner le remboursement gazole professionnel.
> - Identifier les véhicules soumis à la taxe à l'essieu et déclarer.
> - Cartographier les prélèvements qui pèsent sur le coût de revient.

## La TICPE

La **taxe intérieure de consommation sur les produits énergétiques** est incluse dans le prix du carburant à la pompe : c'est l'un des premiers postes de fiscalité du transporteur, noyé dans le poste carburant (20 à 30 % du coût de revient d'un poids lourd).

### Le remboursement « gazole professionnel »

Le transport routier de marchandises bénéficie d'un **remboursement partiel de TICPE** sur le gazole consommé par les véhicules de **7,5 tonnes et plus** :

:::flow
1. Consommer | Gazole des PL ≥ 7,5 t, factures et justificatifs conservés
2. Demander | Demande périodique auprès de l'administration (téléservice)
3. Percevoir | Remboursement partiel, par litre, selon le tarif en vigueur
:::

Conditions pratiques : véhicules immatriculés dans l'entreprise (ou pris en location), consommations justifiées (factures, cartes carburant), demande dans les délais.

> ⚠️ **Attention**
> Le **tarif du remboursement et sa trajectoire évoluent en loi de finances** (le dispositif est engagé dans une réduction progressive) : vérifier chaque année le taux applicable et l'échéancier. Ne jamais chiffrer un budget pluriannuel sur le tarif d'aujourd'hui sans réserve.

## La taxe à l'essieu

La **taxe sur certains véhicules routiers** (dite taxe à l'essieu) frappe les véhicules ou ensembles de **12 tonnes et plus** de PTAC utilisés en France :

| Paramètre | Effet |
| --- | --- |
| Silhouette et nombre d'essieux | Détermine la catégorie tarifaire |
| Suspension pneumatique | Tarif réduit par rapport aux autres suspensions |
| Usage particulier | Exonérations ciblées (véhicules spécialisés) |

Elle est déclarée et payée auprès de l'administration fiscale (gestion DGFiP), sur une base annuelle. Le défaut de déclaration expose à des rappels et pénalités, révélés au premier contrôle.

## Les autres prélèvements liés aux véhicules

- **Taxes sur l'affectation des véhicules de tourisme à des fins économiques** (ex-TVS) : elles visent les **voitures de tourisme** de l'entreprise (véhicules de direction ou de service), pas les poids lourds.
- **Péages** : soumis à TVA (déductible pour l'exploitation) ; les dispositifs de télépéage fournissent les relevés justificatifs.
- **Certificats et cartes grises** : taxes régionales à l'immatriculation.

> 💡 **Astuce**
> Chaque euro de fiscalité véhicule doit se retrouver dans le **coût de revient kilométrique** (module E : gestion) : TICPE nette de remboursement, taxe à l'essieu annualisée, péages affectés par ligne. Une tarification qui ignore ces postes vend à perte sans le savoir.

## ✅ Synthèse

- TICPE incluse dans le prix du gazole ; **remboursement partiel** pour les PL **≥ 7,5 t**, sur demande, tarif **à vérifier chaque année**.
- **Taxe à l'essieu** : véhicules **≥ 12 t**, tarif selon essieux et **suspension pneumatique**, gestion DGFiP.
- Ex-TVS : voitures de tourisme uniquement ; péages avec TVA déductible.$mft$,
    $mft$TICPE et remboursement gazole professionnel (PL ≥ 7,5 t, demande périodique, tarif évolutif), taxe à l'essieu (≥ 12 t, suspension pneumatique, DGFiP), taxes véhicules de tourisme et péages.$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : L'imposition des bénéfices ──────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'imposition-des-benefices',
    'IR ou IS : l''imposition des bénéfices',
    $mft$> 🎯 **Objectifs**
> - Distinguer l'imposition à l'IR (BIC) et à l'IS.
> - Appliquer les taux d'IS, dont le taux réduit PME.
> - Utiliser amortissements et charges déductibles à bon escient.

## Deux logiques d'imposition

- **Entreprise individuelle** : le bénéfice relève des **BIC** (bénéfices industriels et commerciaux) et s'ajoute aux revenus du foyer, imposé au barème progressif de l'**impôt sur le revenu** ; cotisations sociales du dirigeant calculées sur le bénéfice. Option possible pour l'assimilation à une EURL soumise à l'IS.
- **Société (SARL, SAS…)** : le bénéfice est imposé à l'**impôt sur les sociétés** au niveau de la société ; le dirigeant est imposé personnellement sur sa **rémunération** (traitements et salaires) et sur les **dividendes** distribués.

## Les taux de l'IS

| Bénéfice | Taux |
| --- | --- |
| Jusqu'à 42 500 € (PME éligibles) | **15 %** (taux réduit) |
| Au-delà | **25 %** (taux normal) |

Conditions du taux réduit : chiffre d'affaires inférieur à 10 M€ et capital entièrement libéré, détenu à 75 % au moins par des personnes physiques (directement ou via des PME répondant aux mêmes critères).

Exemple : bénéfice imposable de 60 000 € dans une SAS de transport éligible : 42 500 × 15 % = 6 375 € ; (60 000 − 42 500) × 25 % = 4 375 € ; **IS total = 10 750 €**.

## Le résultat imposable : produits − charges

Le résultat fiscal part du résultat comptable, avec des retraitements. Charges **déductibles** si elles sont engagées dans l'intérêt de l'exploitation, justifiées et comptabilisées : carburant, péages, entretien, salaires et cotisations, loyers, assurances, honoraires, **amortissements**.

### Les amortissements du matériel roulant

L'amortissement répartit le coût d'un investissement sur sa durée d'usage : un tracteur acquis 96 000 € amorti en 6 ans en linéaire = **16 000 € de charge par an**. L'amortissement est une charge **non décaissée** : il diminue le bénéfice imposable sans sortie de trésorerie l'année en cours (l'argent est sorti à l'achat ou via l'emprunt).

> ❌ **Piège à éviter**
> Ne sont pas déductibles : les amendes et pénalités (excès de vitesse, surcharge…), l'IS lui-même, les dépenses somptuaires. Les amendes routières de l'entreprise ne réduisent jamais l'impôt.

## Acomptes et liquidation

L'IS se paie par **acomptes trimestriels**, avec un solde à la liquidation après la clôture. Côté IR, l'entrepreneur individuel est prélevé à la source via des acomptes calculés sur le bénéfice. Dans les deux cas : anticiper la trésorerie fiscale dans le budget (module E).

## ✅ Synthèse

- Entreprise individuelle : bénéfice **BIC à l'IR** ; société : **IS** puis imposition personnelle du dirigeant (rémunération, dividendes).
- IS : **15 % jusqu'à 42 500 €** (PME éligibles), **25 %** au-delà.
- Charges déductibles justifiées + **amortissements** ; jamais les **amendes**.$mft$,
    $mft$BIC/IR pour l'entreprise individuelle vs IS pour les sociétés, taux 15 % jusqu'à 42 500 € (PME) puis 25 %, charges déductibles, amortissements du matériel roulant et non-déductibilité des amendes.$mft$,
    3, 45) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Impôts locaux, calendrier et contrôle ───────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'impots-locaux-calendrier-controle',
    'Impôts locaux, calendrier fiscal et contrôle',
    $mft$> 🎯 **Objectifs**
> - Identifier les impôts locaux dus par l'entreprise de transport.
> - Construire le calendrier fiscal annuel de l'entreprise.
> - Se préparer sereinement à un contrôle fiscal.

## Les impôts locaux de l'entreprise

- **CFE** (cotisation foncière des entreprises) : assise sur la valeur locative des locaux professionnels (bureaux, ateliers, entrepôts), due dans chaque commune d'implantation ; cotisation minimum fixée par la collectivité.
- **CVAE** (cotisation sur la valeur ajoutée des entreprises) : due au-delà d'un seuil de chiffre d'affaires ; le dispositif est engagé dans une **extinction progressive** (calendrier de suppression à vérifier en loi de finances).
- CFE + CVAE forment la **contribution économique territoriale (CET)**, plafonnée en fonction de la valeur ajoutée.
- **Taxe foncière** : due par l'entreprise propriétaire de ses locaux ; en location, le bail précise sa refacturation éventuelle.

## Le calendrier fiscal type du transporteur

:::timeline
1. **Mensuel** : CA3 (TVA) : déclaration et télérèglement.
2. **Trimestriel** : Acomptes d'IS ; le cas échéant demandes périodiques de remboursement TICPE.
3. **Annuel (printemps)** : Liasse fiscale et déclaration de résultats ; solde d'IS ; déclarations CFE/CVAE selon situation.
4. **Annuel (fin d'année)** : Paiement CFE ; taxe à l'essieu selon échéance ; revue fiscale de clôture.
:::

> 💡 **Astuce**
> Un simple tableau des échéances, tenu avec l'expert-comptable, évite les pénalités de retard (majorations et intérêts) qui sont, elles, **non déductibles**.

## Le contrôle fiscal

L'administration peut contrôler sur pièces (du bureau) ou sur place (**vérification de comptabilité**). Le **délai de reprise** de droit commun court en général jusqu'à la fin de la **troisième année** suivant celle au titre de laquelle l'impôt est dû (exemple : les exercices 2023 à 2025 contrôlables en 2026).

Droits et garanties du contribuable : avis de vérification préalable, assistance d'un conseil, débat oral et contradictoire, charte du contribuable vérifié, voies de recours. Obligations : présenter la comptabilité (dont le **fichier des écritures comptables, FEC**), les pièces justificatives, les relevés.

> ⚠️ **Attention**
> Cohérence inter-administrations : les données sociales (DSN), les données du chronotachygraphe et la facturation peuvent être rapprochées. Des factures de gazole sans kilométrage cohérent, des salaires sans DSN : autant de signaux qui déclenchent et aggravent un contrôle.

## Bonnes pratiques

- Justificatifs numérisés et classés par exercice (10 ans pour les pièces comptables).
- Séparation stricte pro/perso (comptes, cartes carburant).
- Revue annuelle avec l'expert-comptable : TVA, TICPE, essieu, IS, paie.
- Documentation des choix (amortissements, provisions) pour les défendre.

## ✅ Synthèse

- **CFE** (+ CVAE en extinction) = CET ; taxe foncière selon propriété.
- Calendrier : **CA3 mensuelle, acomptes IS trimestriels, liasse annuelle**, CFE en fin d'année.
- Contrôle : délai de reprise **3 ans**, FEC exigible, garanties du contribuable ; l'arme absolue reste le **justificatif classé**.$mft$,
    $mft$CFE et CVAE (CET), taxe foncière, calendrier fiscal annuel du transporteur, contrôle fiscal avec délai de reprise de 3 ans, FEC et bonnes pratiques documentaires.$mft$,
    4, 45) RETURNING id INTO v_l4;

  -- ─── Quiz d'entraînement ────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module,
    'Quiz : Droit fiscal',
    'Validez les fondamentaux du module D : TVA, TICPE, taxe à l''essieu, IS et impôts locaux.',
    'entrainement', 70, false)
  RETURNING id INTO v_quiz;

  -- ─── QCM (12) : 4 faciles / 5 moyens / 3 difficiles ────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Quel taux de TVA s'applique aux prestations de transport routier de marchandises réalisées en France ?$mft$,
    $mft$[
      {"id":"a","label":"5,5 %","is_correct":false},
      {"id":"b","label":"10 %","is_correct":false},
      {"id":"c","label":"20 %","is_correct":true},
      {"id":"d","label":"0 % dans tous les cas","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-d','qcm-v1'], 'CAPA-LOURD-D-QCM-01', false,
    $mft$Le transport national de marchandises relève du taux normal de 20 %. Les exonérations concernent des situations précises (transports liés à l'exportation, autoliquidation intracommunautaire).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$La TVA sur le gazole consommé par les poids lourds de l'entreprise est déductible à hauteur de :$mft$,
    $mft$[
      {"id":"a","label":"50 %","is_correct":false},
      {"id":"b","label":"80 %","is_correct":false},
      {"id":"c","label":"100 %","is_correct":true},
      {"id":"d","label":"Elle n'est pas déductible","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-d','qcm-v1'], 'CAPA-LOURD-D-QCM-02', false,
    $mft$Gazole des poids lourds et utilitaires : TVA déductible à 100 %. La limite de 80 % concerne le carburant des véhicules de tourisme.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$À partir de quel PTAC un véhicule ou ensemble routier est-il soumis à la taxe à l'essieu ?$mft$,
    $mft$[
      {"id":"a","label":"3,5 tonnes","is_correct":false},
      {"id":"b","label":"7,5 tonnes","is_correct":false},
      {"id":"c","label":"12 tonnes","is_correct":true},
      {"id":"d","label":"19 tonnes","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-d','qcm-v1'], 'CAPA-LOURD-D-QCM-03', false,
    $mft$La taxe sur certains véhicules routiers (taxe à l'essieu) vise les véhicules de 12 tonnes et plus. Ne pas confondre avec le seuil de 7,5 t du remboursement TICPE.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Quel est le taux normal de l'impôt sur les sociétés en France ?$mft$,
    $mft$[
      {"id":"a","label":"15 %","is_correct":false},
      {"id":"b","label":"25 %","is_correct":true},
      {"id":"c","label":"28 %","is_correct":false},
      {"id":"d","label":"33,33 %","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-d','qcm-v1'], 'CAPA-LOURD-D-QCM-04', false,
    $mft$Taux normal : 25 %. Le taux réduit de 15 % s'applique, pour les PME éligibles, à la fraction de bénéfice n'excédant pas 42 500 €.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Le remboursement partiel de TICPE « gazole professionnel » du transport de marchandises est réservé aux véhicules :$mft$,
    $mft$[
      {"id":"a","label":"De 3,5 tonnes et plus","is_correct":false},
      {"id":"b","label":"De 7,5 tonnes et plus","is_correct":true},
      {"id":"c","label":"De 12 tonnes et plus","is_correct":false},
      {"id":"d","label":"De 44 tonnes uniquement","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-d','qcm-v1'], 'CAPA-LOURD-D-QCM-05', false,
    $mft$Seuil du remboursement gazole professionnel marchandises : 7,5 t et plus, sur demande périodique avec justificatifs. Le tarif au litre évolue en loi de finances.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Vous transportez des marchandises de Lyon à Munich pour un client allemand assujetti (numéro de TVA valide). Comment facturez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Hors taxe, avec mention de l'autoliquidation et le numéro de TVA du client","is_correct":true},
      {"id":"b","label":"Avec TVA française à 20 %","is_correct":false},
      {"id":"c","label":"Avec TVA allemande","is_correct":false},
      {"id":"d","label":"Avec une double TVA franco-allemande partagée","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-d','qcm-v1'], 'CAPA-LOURD-D-QCM-06', false,
    $mft$Prestation B2B intracommunautaire : localisée chez le preneur ; le client allemand autoliquide la TVA dans son pays. Facture HT + mention autoliquidation + numéros de TVA des deux parties (vérification VIES).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Jusqu'à quel montant de bénéfice le taux réduit d'IS de 15 % s'applique-t-il pour une PME éligible ?$mft$,
    $mft$[
      {"id":"a","label":"38 120 €","is_correct":false},
      {"id":"b","label":"42 500 €","is_correct":true},
      {"id":"c","label":"50 000 €","is_correct":false},
      {"id":"d","label":"100 000 €","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-d','qcm-v1'], 'CAPA-LOURD-D-QCM-07', false,
    $mft$42 500 € de bénéfice au taux de 15 % pour les PME (CA < 10 M€, capital libéré détenu à 75 % au moins par des personnes physiques) ; au-delà, 25 %.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$De quoi se compose la contribution économique territoriale (CET) ?$mft$,
    $mft$[
      {"id":"a","label":"De la CFE et de la CVAE","is_correct":true},
      {"id":"b","label":"De la taxe foncière et de la taxe d'habitation","is_correct":false},
      {"id":"c","label":"De la TVA et de l'IS","is_correct":false},
      {"id":"d","label":"De la TICPE et de la taxe à l'essieu","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-d','qcm-v1'], 'CAPA-LOURD-D-QCM-08', false,
    $mft$CET = CFE (assise sur la valeur locative des locaux) + CVAE (assise sur la valeur ajoutée, en extinction progressive), avec plafonnement en fonction de la valeur ajoutée.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Sur un mois, votre entreprise a collecté 12 000 € de TVA sur ses ventes et payé 4 000 € de TVA sur ses achats. Que déclare-t-elle ?$mft$,
    $mft$[
      {"id":"a","label":"8 000 € de TVA à payer","is_correct":true},
      {"id":"b","label":"16 000 € de TVA à payer","is_correct":false},
      {"id":"c","label":"4 000 € de crédit de TVA","is_correct":false},
      {"id":"d","label":"12 000 € de TVA à payer","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-d','qcm-v1'], 'CAPA-LOURD-D-QCM-09', false,
    $mft$TVA à payer = collectée (12 000) − déductible (4 000) = 8 000 €. Si la déductible dépassait la collectée, l'écart constituerait un crédit de TVA imputable ou remboursable.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un transport routier acheminant des marchandises de Dijon au port du Havre en vue de leur exportation hors UE est, sous conditions documentaires :$mft$,
    $mft$[
      {"id":"a","label":"Exonéré de TVA","is_correct":true},
      {"id":"b","label":"Soumis à la TVA au taux de 20 %","is_correct":false},
      {"id":"c","label":"Soumis à un taux réduit de 10 %","is_correct":false},
      {"id":"d","label":"Hors du champ de la TVA sans condition","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-d','qcm-v1'], 'CAPA-LOURD-D-QCM-10', false,
    $mft$Les prestations de transport directement liées à une exportation de biens hors de l'UE sont exonérées de TVA, à condition de pouvoir justifier du lien avec l'exportation (documents douaniers, lettre de voiture).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quel équipement du véhicule permet de bénéficier d'un tarif réduit de taxe à l'essieu ?$mft$,
    $mft$[
      {"id":"a","label":"La suspension pneumatique de l'essieu moteur","is_correct":true},
      {"id":"b","label":"Le limiteur de vitesse","is_correct":false},
      {"id":"c","label":"Le chronotachygraphe intelligent","is_correct":false},
      {"id":"d","label":"Les pneumatiques basse consommation","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-d','qcm-v1'], 'CAPA-LOURD-D-QCM-11', false,
    $mft$Le barème distingue les véhicules selon silhouette, nombre d'essieux et type de suspension : la suspension pneumatique, moins agressive pour la chaussée, bénéficie d'un tarif réduit.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$En 2026, jusqu'à quels exercices l'administration fiscale peut-elle en principe exercer son droit de reprise (délai de droit commun) ?$mft$,
    $mft$[
      {"id":"a","label":"Les exercices 2023, 2024 et 2025","is_correct":true},
      {"id":"b","label":"Uniquement l'exercice 2025","is_correct":false},
      {"id":"c","label":"Les exercices depuis 2016","is_correct":false},
      {"id":"d","label":"Tous les exercices sans limite","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-d','qcm-v1'], 'CAPA-LOURD-D-QCM-12', false,
    $mft$Délai de reprise de droit commun : jusqu'à la fin de la troisième année suivant celle au titre de laquelle l'impôt est dû. En 2026, les exercices 2023 à 2025 restent contrôlables (délais étendus en cas de fraude).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Quel taux de TVA s'applique au transport routier national de marchandises ?$mft$,
   $mft$Le taux normal de 20 %.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-d','question-courte'], 'CAPA-LOURD-D-QC-01', false,
   $mft$Prestation de services au taux normal.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$À partir de quel tonnage la taxe à l'essieu est-elle due ?$mft$,
   $mft$À partir de 12 tonnes de PTAC.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-d','question-courte'], 'CAPA-LOURD-D-QC-02', false,
   $mft$Taxe sur certains véhicules routiers, gérée par la DGFiP.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quel est le taux normal de l'impôt sur les sociétés ?$mft$,
   $mft$25 %.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-d','question-courte'], 'CAPA-LOURD-D-QC-03', false,
   $mft$Avec un taux réduit de 15 % jusqu'à 42 500 € pour les PME éligibles.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Quel est le seuil de tonnage pour bénéficier du remboursement partiel de TICPE (gazole professionnel marchandises) ?$mft$,
   $mft$7,5 tonnes et plus.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-d','question-courte'], 'CAPA-LOURD-D-QC-04', false,
   $mft$À ne pas confondre avec les 12 t de la taxe à l'essieu.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$À quelle hauteur la TVA sur le gazole des poids lourds est-elle déductible ?$mft$,
   $mft$À 100 %.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-d','question-courte'], 'CAPA-LOURD-D-QC-05', false,
   $mft$80 % seulement pour le carburant des véhicules de tourisme.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Que signifie « autoliquidation » de la TVA dans une prestation intracommunautaire B2B ?$mft$,
   $mft$Le prestataire facture hors taxe et c'est le client assujetti qui déclare et paie la TVA dans son propre pays.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-d','question-courte'], 'CAPA-LOURD-D-QC-06', false,
   $mft$Mention obligatoire sur la facture + numéros de TVA intracommunautaire des deux parties.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$De quels deux prélèvements se compose la contribution économique territoriale ?$mft$,
   $mft$De la CFE (cotisation foncière des entreprises) et de la CVAE (cotisation sur la valeur ajoutée des entreprises).$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-d','question-courte'], 'CAPA-LOURD-D-QC-07', false,
   $mft$La CVAE est en extinction progressive (calendrier à vérifier).$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Comment le bénéfice d'une entreprise individuelle de transport est-il imposé, en l'absence d'option particulière ?$mft$,
   $mft$Dans la catégorie des BIC, au barème progressif de l'impôt sur le revenu du foyer de l'exploitant.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-d','question-courte'], 'CAPA-LOURD-D-QC-08', false,
   $mft$Par opposition à la société soumise à l'IS ; une option pour l'IS est possible via l'assimilation EURL.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Jusqu'à quel montant de bénéfice une PME éligible bénéficie-t-elle du taux réduit d'IS de 15 % ?$mft$,
   $mft$Jusqu'à 42 500 € de bénéfice imposable.$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-d','question-courte'], 'CAPA-LOURD-D-QC-09', false,
   $mft$Conditions : CA < 10 M€, capital libéré détenu à 75 % au moins par des personnes physiques.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Quel est le délai de reprise de droit commun de l'administration fiscale ?$mft$,
   $mft$Jusqu'à la fin de la troisième année suivant celle au titre de laquelle l'impôt est dû (« 3 ans »).$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-d','question-courte'], 'CAPA-LOURD-D-QC-10', false,
   $mft$Délais étendus en cas d'activité occulte ou de fraude.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Expliquez le mécanisme de la TVA pour une entreprise de transport, en illustrant par un exemple chiffré simple (ventes, achats, TVA due).$mft$,
   $mft$Réponse modèle. La TVA est collectée par l'entreprise sur ses prestations (TVA collectée, au taux de 20 % en transport national) et payée sur ses achats professionnels (TVA déductible : gazole des PL à 100 %, péages, entretien, investissements). L'entreprise ne supporte pas la taxe : elle reverse la différence. Exemple : au mois M, prestations facturées 50 000 € HT → TVA collectée 10 000 € ; achats (gazole 12 000 € HT, péages et entretien 8 000 € HT) → TVA déductible (12 000 + 8 000) × 20 % = 4 000 €. TVA à payer sur la CA3 : 10 000 − 4 000 = 6 000 €. Si la déductible excède la collectée (gros investissement), l'écart devient un crédit de TVA, imputable sur les mois suivants ou remboursable. Conditions de déduction : dépenses engagées pour l'exploitation, factures conformes au nom de l'entreprise.$mft$,
   $mft$Barème /5 : mécanisme collectée/déductible/neutralité (1,5 pt) ; exemple chiffré cohérent et calcul exact (2 pts) ; crédit de TVA (0,75 pt) ; conditions de forme de la déduction (0,75 pt). Erreurs fréquentes : additionner au lieu de soustraire ; oublier que la TVA sur véhicules de tourisme suit un régime restreint.$mft$,
   5, 'facile', ARRAY['capa-lourd','module-d','question-redigee'], 'CAPA-LOURD-D-QR-01', false,
   $mft$Mécanisme fondamental avec application chiffrée.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Décrivez le dispositif de remboursement partiel de TICPE dont bénéficie le transport routier de marchandises : véhicules concernés, conditions, démarche et points de vigilance.$mft$,
   $mft$Réponse modèle. La TICPE est incluse dans le prix du gazole. Les entreprises de transport routier de marchandises peuvent obtenir un remboursement partiel de la taxe sur le gazole consommé par leurs véhicules de 7,5 tonnes et plus, immatriculés dans l'entreprise ou pris en location. Conditions : consommations justifiées (factures, relevés de cartes carburant rattachés aux véhicules éligibles), activité de transport pour compte d'autrui. Démarche : demande périodique dématérialisée auprès de l'administration, dans les délais, avec conservation des justificatifs en cas de contrôle. Points de vigilance : le tarif de remboursement au litre est fixé par la loi de finances et le dispositif est engagé dans une trajectoire de réduction progressive : vérifier chaque année le taux applicable ; isoler dans la comptabilité les consommations des véhicules < 7,5 t (non éligibles) ; intégrer la TICPE nette de remboursement dans le coût de revient kilométrique et dans les clauses gazole des contrats clients.$mft$,
   $mft$Barème /5 : seuil 7,5 t et principe du remboursement partiel (1,5 pt) ; conditions et justificatifs (1 pt) ; démarche périodique dématérialisée (1 pt) ; vigilance sur l'évolution du tarif + répercussion au coût de revient (1,5 pt). Erreurs fréquentes : confondre avec le seuil de 12 t de la taxe à l'essieu ; croire le remboursement automatique sans demande.$mft$,
   5, 'facile', ARRAY['capa-lourd','module-d','question-redigee'], 'CAPA-LOURD-D-QR-02', false,
   $mft$Dispositif clé du poste carburant, à jour de la logique de trajectoire.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Cas chiffré. Au mois de mars, TransEst facture 60 000 € HT de prestations nationales. Ses achats du mois : gazole PL 15 000 € HT, péages 4 000 € HT, réparation d'un tracteur 6 000 € HT, essence de la voiture de tourisme du dirigeant 500 € HT. Calculez la TVA due au titre de mars.$mft$,
   $mft$Réponse modèle. TVA collectée : 60 000 × 20 % = 12 000 €. TVA déductible : gazole PL 15 000 × 20 % = 3 000 € (déductible à 100 %) ; péages 4 000 × 20 % = 800 € ; réparation 6 000 × 20 % = 1 200 € ; essence du véhicule de tourisme 500 × 20 % = 100 €, déductible à 80 % seulement, soit 80 €. Total déductible = 3 000 + 800 + 1 200 + 80 = 5 080 €. TVA à payer = 12 000 − 5 080 = 6 920 €, à déclarer sur la CA3 de mars. Remarque attendue : la restriction à 80 % ne vise que le carburant du véhicule de tourisme ; tous les autres postes, engagés pour l'exploitation, ouvrent droit à déduction intégrale sur factures conformes.$mft$,
   $mft$Barème /5 : collectée 12 000 € (1 pt) ; déductions PL/péages/réparation exactes (1,5 pt) ; traitement à 80 % de l'essence VP (80 €) (1,5 pt) ; total et TVA due 6 920 € (1 pt). Erreurs fréquentes : déduire 100 % sur le véhicule de tourisme ; oublier un poste ; erreur d'arithmétique non vérifiée.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-d','question-redigee'], 'CAPA-LOURD-D-QR-03', false,
   $mft$Calcul de CA3 avec le piège classique du véhicule de tourisme.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Votre entreprise commence à travailler pour un industriel belge assujetti et pour un particulier français qui déménage. Précisez le traitement TVA de chaque facture et les vérifications à effectuer.$mft$,
   $mft$Réponse modèle. Client belge assujetti (B2B intracommunautaire) : la prestation de transport de biens est localisée dans le pays du preneur (Belgique) ; la facture est établie hors taxe avec la mention « autoliquidation », le numéro de TVA intracommunautaire du client et celui de l'entreprise ; le client belge autoliquide la TVA belge. Vérifications : validité du numéro de TVA du client dans la base VIES (capture conservée), déclaration récapitulative des services (état récapitulatif) déposée au titre du mois, preuve de la réalité de la prestation (lettre de voiture internationale). Client particulier français (B2C national) : prestation taxable en France au taux de 20 % ; facture TTC avec TVA française collectée, reversée via la CA3. Point d'attention : le régime B2B hors taxe ne vaut que pour un preneur assujetti identifié ; facturer HT un client sans numéro valide expose l'entreprise à un rappel de TVA avec pénalités.$mft$,
   $mft$Barème /5 : localisation chez le preneur + facture HT autoliquidation pour le Belge (1,5 pt) ; vérification VIES + état récapitulatif (1,5 pt) ; TVA française 20 % pour le particulier (1 pt) ; risque de rappel si numéro non vérifié (1 pt). Erreurs fréquentes : facturer la TVA française au client belge assujetti ; étendre l'autoliquidation au particulier.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-d','question-redigee'], 'CAPA-LOURD-D-QR-04', false,
   $mft$Deux traitements TVA opposés à sécuriser, avec les réflexes documentaires.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un transporteur individuel (bénéfice stable autour de 55 000 €) envisage de passer en SASU. Comparez les logiques d'imposition avant/après et identifiez les paramètres à arbitrer, sans chercher un chiffrage exhaustif.$mft$,
   $mft$Réponse modèle. Avant (entreprise individuelle) : le bénéfice BIC est imposé en totalité au barème progressif de l'IR du foyer, qu'il soit prélevé ou non, et sert d'assiette aux cotisations sociales TNS. Après (SASU à l'IS) : la société paie l'IS sur son résultat (15 % jusqu'à 42 500 € si éligible, 25 % au-delà) ; le dirigeant est imposé personnellement sur ce qu'il perçoit : rémunération de président (assimilé salarié : charges sociales plus élevées, meilleure protection) et/ou dividendes (après IS, imposés au prélèvement forfaitaire unique sauf option barème). Paramètres à arbitrer : niveau de rémunération nécessaire au train de vie (ce qui reste en société n'est pas imposé à l'IR : capacité d'autofinancement pour renouveler la flotte) ; coût social comparé TNS vs assimilé salarié ; protection sociale souhaitée ; distribution ou capitalisation des résultats ; frottements de passage (apport du fonds, formalités) ; incidence sur la capacité financière exigée (capitaux propres de la société). Conclusion de méthode : la SASU devient intéressante quand une part significative du résultat peut rester investie dans l'entreprise ; un chiffrage précis avec l'expert-comptable s'impose avant décision.$mft$,
   $mft$Barème /5 : logique IR/BIC totalité vs IS + flux au dirigeant (2 pts) ; taux IS 15/25 correctement mobilisés (0,5 pt) ; au moins quatre paramètres d'arbitrage pertinents (2 pts) ; conclusion de méthode prudente (0,5 pt). Erreurs fréquentes : comparer uniquement les taux nominaux ; oublier les cotisations sociales ; croire les dividendes exonérés.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-d','question-redigee'], 'CAPA-LOURD-D-QR-05', false,
   $mft$Arbitrage structurel classique, traité en logique et paramètres.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Construisez le plan de maîtrise de la fiscalité « flotte » d'une entreprise de 15 poids lourds (dont 12 de 44 t et 3 porteurs de 7,5 t) : prélèvements concernés, actions de récupération et d'optimisation, organisation documentaire.$mft$,
   $mft$Réponse modèle. Prélèvements : TICPE incluse dans le gazole (poste majeur) ; taxe à l'essieu pour les véhicules ≥ 12 t (les 12 ensembles de 44 t ; les porteurs de 7,5 t n'y sont pas soumis) ; TVA sur carburant, péages, entretien (récupérable) ; taxes à l'immatriculation. Actions de récupération : remboursement partiel de TICPE sur le gazole des 15 véhicules (tous ≥ 7,5 t), demandes périodiques avec justificatifs ; déduction intégrale de la TVA (gazole PL 100 %, péages, maintenance) ; tarif réduit de taxe à l'essieu si suspensions pneumatiques. Optimisation : suivi de la consommation par véhicule (cartes carburant nominatives) pour fiabiliser les demandes et détecter les dérives ; intégration de la TICPE nette et de la taxe à l'essieu annualisée dans le coût de revient et les clauses d'indexation gazole des contrats ; veille annuelle loi de finances (trajectoire du gazole professionnel). Organisation : échéancier fiscal (CA3, demandes TICPE, essieu, acomptes IS), classement par véhicule et par exercice, revue annuelle avec l'expert-comptable, contrôle interne des factures carburant (rapprochement litres/kilomètres).$mft$,
   $mft$Barème /5 : cartographie exacte des prélèvements avec la distinction 7,5 t / 12 t appliquée à la flotte (1,5 pt) ; actions de récupération TICPE + TVA (1,5 pt) ; intégration au coût de revient et aux contrats (1 pt) ; organisation documentaire et veille (1 pt). Erreurs fréquentes : soumettre les 7,5 t à la taxe à l'essieu ; ignorer le rapprochement litres/kilomètres qui crédibilise les demandes.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-d','question-redigee'], 'CAPA-LOURD-D-QR-06', false,
   $mft$Plan d'action fiscal flotte, transversal avec le module E (coût de revient).$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Cas chiffré. La SARL RoulOuest (CA 3,2 M€, capital détenu par deux personnes physiques, éligible au taux réduit) dégage un bénéfice imposable de 60 000 €. a) Calculez l'IS dû. b) Le gérant envisage 10 000 € de travaux somptuaires et 2 500 € d'amendes routières en charges : quel impact fiscal ? c) Citez deux leviers légaux pour alléger l'IS futur.$mft$,
   $mft$Réponse modèle. a) IS : 42 500 × 15 % = 6 375 € ; (60 000 − 42 500) = 17 500 × 25 % = 4 375 € ; IS total = 10 750 €. b) Les dépenses somptuaires et les amendes ne sont pas déductibles : si elles ont été passées en charges, elles sont réintégrées au résultat fiscal : le bénéfice imposable ne diminue pas de 12 500 € ; les inscrire en déduction expose à un rappel avec pénalités : impact fiscal nul en légalité, risque en cas de déduction indue. c) Leviers légaux : investir avec des amortissements (renouvellement du parc : charge déductible étalée), optimiser la rémunération du dirigeant (charge déductible pour la société, arbitrage global avec l'imposition personnelle), constituer des provisions justifiées (litiges, gros entretien selon les règles), utiliser les dispositifs en vigueur (suramortissements éventuels pour véhicules propres : à vérifier dans la loi de finances applicable). Toute optimisation reste documentée et défendable en contrôle.$mft$,
   $mft$Barème /5 : calcul exact 6 375 + 4 375 = 10 750 € (2 pts) ; non-déductibilité amendes/somptuaires + notion de réintégration (1,5 pt) ; deux leviers légaux pertinents et prudents (1,5 pt). Erreurs fréquentes : appliquer 25 % à tout le bénéfice ; déduire les amendes ; proposer des leviers hasardeux non documentés.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-d','question-redigee'], 'CAPA-LOURD-D-QR-07', false,
   $mft$Calcul IS deux tranches + réintégrations, très proche du format examen.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Votre entreprise reçoit un avis de vérification de comptabilité portant sur les trois derniers exercices. Préparez la vérification : droits et garanties, documents à réunir, conduite à tenir pendant le contrôle.$mft$,
   $mft$Réponse modèle. Droits et garanties : avis de vérification préalable mentionnant les exercices contrôlés et la faculté de se faire assister d'un conseil (l'expert-comptable) ; charte du contribuable vérifié ; débat oral et contradictoire avec le vérificateur ; à l'issue, proposition de rectification motivée ouvrant un délai de réponse, puis voies de recours (observations, hiérarchie, commissions, contentieux). Documents à réunir : fichier des écritures comptables (FEC) de chaque exercice, livres comptables, liasses fiscales, factures d'achats et de ventes classées, relevés bancaires, justificatifs spécifiques transport (factures gazole et demandes TICPE, taxe à l'essieu, contrats clients et lettres de voiture, DSN et paie). Conduite : désigner un interlocuteur unique ; répondre précisément sans extrapoler ; tracer les demandes et remises de documents ; faire vérifier la cohérence des données croisées (TVA/CA, gazole/kilomètres, paie/DSN) avant le contrôle ; corriger spontanément les anomalies mineures détectées. Objectif : démontrer une comptabilité régulière, sincère et probante ; en cas de désaccord, argumenter par écrit dans les délais.$mft$,
   $mft$Barème /5 : garanties procédurales citées (avis, conseil, contradictoire, recours) (1,5 pt) ; FEC + pièces générales (1 pt) ; justificatifs spécifiques transport (TICPE, essieu, lettres de voiture) (1,5 pt) ; conduite et rapprochements de cohérence (1 pt). Erreurs fréquentes : ignorer le FEC ; improviser les réponses ; laisser partir des originaux sans traçabilité.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-d','question-redigee'], 'CAPA-LOURD-D-QR-08', false,
   $mft$Préparation de contrôle fiscal orientée transport, avec les croisements de données sectoriels.$mft$);

  RAISE NOTICE 'Module D Capa lourd créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $capad$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Volumes : select "type", active, count(*) from question_bank
--     where source_ref like 'CAPA-LOURD-D-%' group by 1, 2;
--    → attendu : qcm/false = 12, qr/false = 18.
-- 2) QCM à bonne réponse unique :
--    select source_ref from question_bank
--     where source_ref like 'CAPA-LOURD-D-QCM-%'
--       and (select count(*) from jsonb_array_elements(choices) c
--             where (c->>'is_correct')::boolean) <> 1;   → 0 ligne.
-- 3) Doublons d'énoncés sur la formation :
--    select statement, count(*) from question_bank
--     where formation_id = (select id from formations where slug='capacite-plus-3-5t')
--     group by 1 having count(*) > 1;                    → 0 ligne.
