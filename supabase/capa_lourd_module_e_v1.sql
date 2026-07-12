-- =====================================================================
-- CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) — MODULE E : GESTION
-- COMMERCIALE ET FINANCIÈRE — v1 (juillet 2026) — LOT 6
--
-- Domaine E de l'annexe I du règlement (CE) n° 1071/2009 : coût de
-- revient (méthode du trinôme), tarification et indexation gazole,
-- seuil de rentabilité, lecture du bilan et du compte de résultat,
-- CAF, BFR, trésorerie et financement du matériel.
-- Références : indices et méthodologie CNR ; code des transports
-- (indexation gazole L. 3222-1 s.) ; code de commerce (délais de
-- paiement spécifiques transport : 30 jours).
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- Tous les corrigés chiffrés de ce module sont vérifiés par script.
-- =====================================================================

DO $capae$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'CAPA-LOURD-E-%';
  DELETE FROM public.modules WHERE slug = 'capa-lourd-gestion-commerciale-financiere';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module E — Gestion commerciale et financière',
    'capa-lourd-gestion-commerciale-financiere',
    v_bloc,
    'Piloter la rentabilité : coût de revient par la méthode du trinôme, tarification et indexation gazole, seuil de rentabilité, lecture du bilan et du compte de résultat, CAF, BFR, trésorerie et financement du matériel roulant.',
    'intermediaire',
    600,
    50
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 50, true);

  -- ─── Leçon 1 — Le coût de revient : la méthode du trinôme ──────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'cout-de-revient-trinome',
    'Le coût de revient : charges et méthode du trinôme',
    $mft$> 🎯 **Objectifs**
> - Classer les charges du transport en fixes et variables.
> - Calculer un coût de revient avec la méthode du trinôme.
> - Utiliser les bons inducteurs : kilomètre, heure, journée.

## Charges fixes, charges variables

- **Charges variables** : elles évoluent avec l'activité. Au kilomètre : carburant, pneumatiques, entretien courant, péages.
- **Charges fixes** : elles existent même camion à l'arrêt. À la journée ou à l'année : amortissement ou loyers du véhicule, assurances, taxe à l'essieu, coûts de structure (locaux, exploitation, gestion) ; à l'heure : salaires et charges des conducteurs (fixes à court terme).

> ❌ **Piège à éviter**
> Le salaire du conducteur n'est pas « variable » parce qu'il conduit plus ou moins : à court terme, c'est un coût lié au **temps de service**, pas aux kilomètres. Le confondre fausse tous les devis.

## La méthode du trinôme

La profession (méthodologie popularisée par le **CNR**, Comité national routier) décompose le coût d'une opération selon **trois inducteurs** :

| Terme | Inducteur | Contenu type |
| --- | --- | --- |
| Terme **kilométrique** | km parcourus | Carburant, pneus, entretien-réparations, péages |
| Terme **horaire** (personnel) | heures de service | Salaires + charges des conducteurs, frais de déplacement |
| Terme **journalier** (véhicule + structure) | jours d'exploitation | Amortissement/financement, assurances, taxes, structure |

**Coût de revient = (terme kilométrique × km) + (terme horaire × heures) + (terme journalier × jours)**

## Exemple guidé

Une journée d'exploitation d'un ensemble 44 t : 520 km, 11 h de service, avec un terme kilométrique de 0,68 €/km, un coût horaire conducteur chargé de 32 €/h et un terme journalier (véhicule + structure) de 320 €.

:::flow
1. Kilométrique | 520 × 0,68 = 353,60 €
2. Horaire | 11 × 32 = 352,00 €
3. Journalier | 320,00 €
:::

**Coût de la journée = 353,60 + 352,00 + 320,00 = 1 025,60 €**, soit 1 025,60 / 520 ≈ **1,97 €/km complet**. Ce coût kilométrique « tout compris » n'a de sens que pour CE profil d'exploitation : plus de kilomètres par jour diluent le journalier, plus d'attente le renchérit.

> 💡 **Astuce**
> Les **indices CNR** (gazole, coûts de revient) servent de référence de place : suivre leurs variations permet d'objectiver les hausses auprès des clients et d'alimenter les clauses de révision.

## Affiner : par véhicule, par ligne, par client

Le coût moyen d'entreprise cache des écarts : calculer le trinôme **par type de véhicule** (44 t, porteur), **par ligne** (péages réels, kilomètres à vide) et **par client** (attentes, contraintes horaires) révèle qui gagne et qui perd de l'argent. Les kilomètres **à vide** et les **heures d'attente** doivent être réintégrés dans le prix de quelqu'un.

## ✅ Synthèse

- Variables **au km** (carburant, pneus, entretien, péages) ; fixes **au jour** (véhicule, structure) ; conducteur **à l'heure**.
- **Trinôme : km × TK + heures × TH + jours × TJ.**
- Journée exemple : **1 025,60 €** ; le coût au km dépend du profil d'exploitation ; chasser les kilomètres à vide et les attentes non facturées.$mft$,
    $mft$Classement charges fixes/variables, méthode du trinôme (terme kilométrique, horaire conducteur, journalier véhicule+structure) avec exemple chiffré complet, indices CNR et analyse par ligne.$mft$,
    1, 55) RETURNING id INTO v_l1;

  -- ─── Leçon 2 — Du coût au prix : tarifer, indexer, vendre ──────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'tarification-indexation-gazole-seuil',
    'Du coût au prix : tarification, gazole et seuil de rentabilité',
    $mft$> 🎯 **Objectifs**
> - Passer du coût de revient au prix de vente avec une marge maîtrisée.
> - Appliquer l'indexation gazole légale dans les contrats et factures.
> - Calculer et interpréter le seuil de rentabilité.

## Du coût au prix

Le prix de vente couvre le **coût de revient complet** plus une **marge**. Deux pratiques : appliquer un coefficient au coût (coût × 1,12 pour viser 12 % de marge sur coût) ou raisonner en taux de marge sur le prix. L'essentiel : connaître son coût AVANT de répondre à un appel d'offres, intégrer les kilomètres à vide, les attentes, la saisonnalité, et refuser (ou re-tarifer) ce qui détruit de la valeur.

Sur l'exemple de la leçon 1 : coût journée 1 025,60 € ; avec 12 % de marge sur coût, prix = 1 025,60 × 1,12 = **1 148,67 €**.

## L'indexation gazole : une protection légale

Le code des transports organise la **répercussion de la variation du prix du gazole** :

> 📌 **À retenir**
> - Si le contrat prévoit une **clause d'indexation gazole**, le prix est révisé selon la formule convenue (référence aux indices CNR).
> - À défaut de clause, le prix est **révisé de plein droit** pour tenir compte de la variation du coût du carburant entre la date du contrat et la date de réalisation (mécanisme légal dit du « pied de facture »).
> Cette protection est d'ordre public : un client ne peut pas l'écarter.

En pratique : mentionner la part gazole dans le prix, l'indice de référence et la périodicité de révision ; facturer la révision de façon lisible.

## Conditions de vente et paiement

- **Devis et CGV** : objet précis (nature, délais, conditions d'accès), prix HT, indexation, responsabilités et plafonds (contrats types), pénalités.
- **Délais de paiement** : pour le transport routier de marchandises, le délai convenu ne peut dépasser **30 jours** à compter de la date d'émission de la facture (régime spécial, plus court que le droit commun). Pénalités de retard + indemnité forfaitaire de 40 € par facture en retard.

## Le seuil de rentabilité

Le **seuil de rentabilité (SR)** est le chiffre d'affaires pour lequel le résultat est nul :

**SR = charges fixes / taux de marge sur coûts variables**, avec taux de MCV = (CA − charges variables) / CA.

Exemple : CA prévisionnel 1 800 000 €, charges variables 1 170 000 € (65 % du CA), charges fixes 540 000 €. Taux de MCV = 35 %. **SR = 540 000 / 0,35 = 1 542 857 €**. Point mort : 1 542 857 / 1 800 000 × 360 ≈ **309e jour** : l'entreprise ne commence à gagner de l'argent que début novembre. Résultat prévisionnel = 630 000 − 540 000 = **90 000 €**.

> 🎓 **Examen**
> Le jury attend la formule, le calcul posé, ET l'interprétation (« que se passe-t-il si le CA baisse de 10 % ? ») : avec 1 620 000 € de CA, la MCV tombe à 567 000 € et le résultat à 27 000 € : la marge de sécurité est mince.

## ✅ Synthèse

- Prix = coût complet + marge ; ne jamais coter sans coût de revient.
- Gazole : indexation contractuelle ou **révision légale de plein droit**.
- Paiement transport : **30 jours** maximum ; pénalités + 40 €.
- **SR = CF / taux de MCV** ; interpréter (point mort, marge de sécurité).$mft$,
    $mft$Passage du coût au prix avec marge, indexation gazole légale (clause ou révision de plein droit), délai de paiement spécial transport 30 jours, seuil de rentabilité calculé et interprété.$mft$,
    2, 50) RETURNING id INTO v_l2;

  -- ─── Leçon 3 — Lire bilan et compte de résultat ────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'bilan-compte-resultat-caf',
    'Lire le bilan, le compte de résultat et la CAF',
    $mft$> 🎯 **Objectifs**
> - Lire un bilan (ce que l'entreprise possède et doit) et un compte de résultat (ce qu'elle a gagné).
> - Calculer une CAF et comprendre son rôle.
> - Relier les capitaux propres à la capacité financière du transporteur.

## Le bilan : la photographie

Le **bilan** décrit le patrimoine à une date donnée :

| Actif (emplois) | Passif (ressources) |
| --- | --- |
| Immobilisations (véhicules, matériel, locaux) | Capitaux propres (capital, réserves, résultat) |
| Actif circulant : stocks, créances clients | Dettes financières (emprunts) |
| Trésorerie positive | Dettes fournisseurs, fiscales et sociales |

> 📌 **À retenir**
> Les **capitaux propres** du bilan sont la référence de la **capacité financière** exigée du transporteur (module F) : 9 000 € + 5 000 € par véhicule lourd supplémentaire. Un bilan dégradé menace directement l'autorisation d'exercer.

## Le compte de résultat : le film

Le **compte de résultat** cumule sur l'exercice les **produits** (prestations facturées) et les **charges** (carburant, salaires, péages, entretien, dotations aux amortissements, charges financières…). Solde : **bénéfice ou perte**.

Quelques repères d'analyse en transport : le carburant pèse souvent 20 à 30 % du chiffre d'affaires, la masse salariale 35 à 45 % ; la marge nette du secteur est structurellement faible (souvent 1 à 4 %) : la moindre dérive de coût non répercutée détruit le résultat.

## Les soldes intermédiaires utiles

:::flow
1. Chiffre d'affaires | Prestations de transport facturées
2. Valeur ajoutée | CA − consommations externes (carburant, péages, sous-traitance…)
3. EBE | VA − impôts et taxes − charges de personnel
4. Résultat d'exploitation | EBE − dotations aux amortissements
5. Résultat net | Après charges financières et impôt
:::

L'**EBE** (excédent brut d'exploitation) mesure la performance économique pure, avant politique d'amortissement et de financement : c'est l'indicateur préféré des banquiers du secteur.

## La CAF : le carburant du financement

La **capacité d'autofinancement** approxime la trésorerie potentielle générée par l'activité :

**CAF ≈ résultat net + dotations aux amortissements (et provisions) − reprises**

Les dotations sont des charges **non décaissées** : on les rajoute au résultat. La CAF finance les investissements (renouvellement du parc), le remboursement des emprunts et les dividendes. Une CAF durablement inférieure aux annuités d'emprunt annonce l'asphyxie.

## Exemple fil rouge

Compte de résultat simplifié : produits 2 400 000 € ; carburant 480 000 ; salaires et charges 960 000 ; péages 120 000 ; entretien 96 000 ; autres charges externes 360 000 ; impôts et taxes 60 000 ; dotations 180 000 ; charges financières 24 000. Total charges = 2 280 000 → **résultat avant impôt = 120 000 € (5 % du CA)** ; **CAF avant impôt = 120 000 + 180 000 = 300 000 €** : de quoi couvrir des annuités d'emprunt raisonnables ET préparer le renouvellement d'un tracteur.

## ✅ Synthèse

- **Bilan** = photographie (actif/passif) ; **capitaux propres** = clé de la capacité financière.
- **Compte de résultat** = film ; marges du TRM faibles : surveiller carburant et masse salariale en % du CA.
- **CAF ≈ résultat + dotations** : elle paie investissements et emprunts.$mft$,
    $mft$Bilan (actif/passif, capitaux propres = capacité financière), compte de résultat et repères sectoriels, soldes intermédiaires (VA, EBE), CAF = résultat + dotations, exemple chiffré complet.$mft$,
    3, 50) RETURNING id INTO v_l3;

  -- ─── Leçon 4 — Trésorerie, BFR et financement du matériel ──────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'tresorerie-bfr-financement',
    'Trésorerie, BFR et financement du matériel',
    $mft$> 🎯 **Objectifs**
> - Comprendre pourquoi le BFR du transporteur est structurellement élevé.
> - Construire et piloter un plan de trésorerie.
> - Choisir un mode de financement du matériel roulant.

## Le BFR : l'argent qui dort dans l'exploitation

Le **besoin en fonds de roulement** mesure l'argent immobilisé par le cycle d'exploitation :

**BFR = créances clients (+ stocks) − dettes fournisseurs**

Le transport encaisse **après** (clients à 30 jours et plus, parfois davantage en pratique) mais décaisse **vite** : gazole payé comptant ou à quelques jours (cartes), salaires chaque mois, péages prélevés. Résultat : un BFR élevé qui croît AVEC l'activité : les mois de forte croissance sont souvent les plus tendus en trésorerie.

Exemple : CA annuel TTC 2 160 000 € encaissé à 55 jours réels → créances clients ≈ 2 160 000 / 360 × 55 = **330 000 €**. Achats TTC 1 080 000 € payés à 30 jours → dettes fournisseurs ≈ 1 080 000 / 360 × 30 = **90 000 €**. **BFR ≈ 240 000 €** : c'est le financement permanent que l'exploitation exige, avant tout investissement.

## Le plan de trésorerie

Tableau mensuel des **encaissements** (clients, TICPE remboursée, apports) et **décaissements** (gazole, salaires, charges sociales, loyers, échéances d'emprunt, TVA, acomptes IS…). Objectif : détecter les **impasses** avant qu'elles n'arrivent.

> 💡 **Astuce**
> Face à une impasse prévisible : mobiliser les créances (affacturage, escompte : module B), négocier un différé, lisser les gros décaissements (mensualisation), relancer les retards clients (30 jours légaux !), différer un investissement. La pire option : la découvrir à découvert.

## Financer le matériel roulant

| Mode | Mécanique | Points clés |
| --- | --- | --- |
| Achat sur fonds propres | La CAF paie le véhicule | Pas d'intérêts, mais assèche la trésorerie |
| Emprunt bancaire | Propriété immédiate, annuités | Intérêts déductibles, amortissement du bien, dette au bilan |
| Crédit-bail (leasing) | Loyers, option d'achat finale | Loyers déductibles, pas de propriété pendant le contrat, souplesse de renouvellement, coût total souvent supérieur |
| Location longue durée | Loyers tout compris (entretien) | Budget lissé, pas d'option d'achat |

Critères de choix : coût total comparé, impact sur la trésorerie (apport initial), structure du bilan, politique de renouvellement du parc, fiscalité (déductibilité des loyers vs amortissements + intérêts).

> ⚠️ **Attention**
> Le crédit-bail n'inscrit pas le véhicule à l'actif pendant le contrat, mais l'engagement de loyers existe bel et bien : les banquiers le réintègrent dans leur analyse. Comparer toujours le **coût total de détention** (loyers + option d'achat vs prix + intérêts − valeur de revente).

## Les ratios de pilotage

- **Indépendance financière** : capitaux propres / total bilan (les banques aiment ≥ 25-30 %).
- **Capacité de remboursement** : dettes financières / CAF (au-delà de 3-4 années de CAF, prudence).
- **Trésorerie nette** = fonds de roulement − BFR : la traduire en jours de charges décaissables.

## ✅ Synthèse

- **BFR = clients − fournisseurs** : structurellement élevé en TRM (exemple : 240 000 €) et croissant avec l'activité.
- **Plan de trésorerie mensuel** : anticiper les impasses, mobiliser les créances à temps.
- Financement : comparer **coût total de détention** (achat/emprunt vs crédit-bail vs LLD) et l'impact bilan/trésorerie.$mft$,
    $mft$BFR structurellement élevé (exemple chiffré 240 000 €), plan de trésorerie mensuel et leviers anti-impasse, comparaison achat/emprunt/crédit-bail/LLD, ratios d'indépendance et de remboursement.$mft$,
    4, 50) RETURNING id INTO v_l4;

  -- ─── Quiz d'entraînement ────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module,
    'Quiz — Gestion commerciale et financière',
    'Validez les fondamentaux du module E : coût de revient, tarification, seuil de rentabilité, bilan, CAF, BFR et financement.',
    'entrainement', 70, false)
  RETURNING id INTO v_quiz;

  -- ─── QCM (12) — 4 faciles / 5 moyens / 3 difficiles ────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Parmi ces charges d'une entreprise de transport, laquelle est une charge variable (liée aux kilomètres parcourus) ?$mft$,
    $mft$[
      {"id":"a","label":"Le carburant","is_correct":true},
      {"id":"b","label":"L'assurance du véhicule","is_correct":false},
      {"id":"c","label":"L'amortissement du tracteur","is_correct":false},
      {"id":"d","label":"Le loyer des locaux","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-e','qcm-v1'], 'CAPA-LOURD-E-QCM-01', false,
    $mft$Carburant, pneumatiques, entretien courant et péages varient avec les kilomètres. Assurance, amortissement et loyers existent même véhicule à l'arrêt : charges fixes.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Qu'est-ce que le seuil de rentabilité ?$mft$,
    $mft$[
      {"id":"a","label":"Le chiffre d'affaires pour lequel le résultat est nul","is_correct":true},
      {"id":"b","label":"Le bénéfice maximal atteignable","is_correct":false},
      {"id":"c","label":"Le montant minimal de capitaux propres exigé","is_correct":false},
      {"id":"d","label":"Le prix de vente minimal d'une prestation","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-e','qcm-v1'], 'CAPA-LOURD-E-QCM-02', false,
    $mft$Au seuil de rentabilité, la marge sur coûts variables couvre exactement les charges fixes : en dessous l'entreprise perd de l'argent, au-dessus elle en gagne.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Quel document comptable présente le patrimoine de l'entreprise à une date donnée (ce qu'elle possède et ce qu'elle doit) ?$mft$,
    $mft$[
      {"id":"a","label":"Le compte de résultat","is_correct":false},
      {"id":"b","label":"Le bilan","is_correct":true},
      {"id":"c","label":"Le plan de trésorerie","is_correct":false},
      {"id":"d","label":"La liasse de TVA","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-e','qcm-v1'], 'CAPA-LOURD-E-QCM-03', false,
    $mft$Le bilan est la photographie du patrimoine (actif/passif) à la clôture ; le compte de résultat est le film des produits et charges de l'exercice.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Comment calcule-t-on, en première approche, la capacité d'autofinancement (CAF) ?$mft$,
    $mft$[
      {"id":"a","label":"Résultat net + dotations aux amortissements (− reprises)","is_correct":true},
      {"id":"b","label":"Chiffre d'affaires − charges variables","is_correct":false},
      {"id":"c","label":"Capitaux propres − dettes financières","is_correct":false},
      {"id":"d","label":"Trésorerie de clôture − trésorerie d'ouverture","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-e','qcm-v1'], 'CAPA-LOURD-E-QCM-04', false,
    $mft$La CAF réintègre au résultat les charges calculées non décaissées (dotations) : elle mesure la trésorerie potentielle dégagée par l'activité, qui finance investissements et remboursements d'emprunts.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Dans la méthode du trinôme, quels sont les trois termes du coût de revient d'une opération de transport ?$mft$,
    $mft$[
      {"id":"a","label":"Terme kilométrique, terme horaire (conducteur), terme journalier (véhicule et structure)","is_correct":true},
      {"id":"b","label":"Carburant, péages, salaires","is_correct":false},
      {"id":"c","label":"Charges fixes, charges variables, marge","is_correct":false},
      {"id":"d","label":"Coût d'achat, coût d'entretien, coût de revente","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-e','qcm-v1'], 'CAPA-LOURD-E-QCM-05', false,
    $mft$Coût = (TK × km) + (TH × heures) + (TJ × jours). Chaque terme regroupe les charges pilotées par son inducteur : km (carburant, pneus, entretien, péages), heures (conducteur), jours (véhicule, structure).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un contrat de transport ne contient aucune clause d'indexation gazole. Le prix du carburant augmente fortement entre la commande et la réalisation. Que prévoit la loi ?$mft$,
    $mft$[
      {"id":"a","label":"Le prix est révisé de plein droit pour tenir compte de la variation du coût du gazole","is_correct":true},
      {"id":"b","label":"Le transporteur supporte seul la hausse","is_correct":false},
      {"id":"c","label":"Le contrat devient caduc","is_correct":false},
      {"id":"d","label":"Le client peut refuser toute facturation complémentaire","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-e','qcm-v1'], 'CAPA-LOURD-E-QCM-06', false,
    $mft$Protection légale d'ordre public du code des transports : à défaut de clause, révision de plein droit du prix en fonction de la variation du coût du carburant (mécanisme du pied de facture, indices CNR en référence).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quel est le délai de paiement maximal applicable aux factures de transport routier de marchandises ?$mft$,
    $mft$[
      {"id":"a","label":"30 jours à compter de la date d'émission de la facture","is_correct":true},
      {"id":"b","label":"45 jours fin de mois","is_correct":false},
      {"id":"c","label":"60 jours nets","is_correct":false},
      {"id":"d","label":"90 jours par accord entre professionnels","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-e','qcm-v1'], 'CAPA-LOURD-E-QCM-07', false,
    $mft$Régime spécial du transport : 30 jours maximum à compter de l'émission de la facture, dérogatoire au droit commun (60 jours / 45 jours fin de mois). Les retards déclenchent pénalités + indemnité de 40 €.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Pourquoi le besoin en fonds de roulement (BFR) d'un transporteur est-il structurellement élevé ?$mft$,
    $mft$[
      {"id":"a","label":"Parce qu'il encaisse ses clients à 30 jours et plus alors qu'il décaisse vite (gazole, salaires, péages)","is_correct":true},
      {"id":"b","label":"Parce qu'il détient d'importants stocks de marchandises","is_correct":false},
      {"id":"c","label":"Parce que ses fournisseurs exigent des acomptes à un an","is_correct":false},
      {"id":"d","label":"Parce que la TVA n'est jamais récupérable en transport","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-e','qcm-v1'], 'CAPA-LOURD-E-QCM-08', false,
    $mft$Décalage structurel : encaissements clients différés, décaissements rapides (carburant quasi comptant, salaires mensuels). Le BFR croît avec l'activité : les phases de croissance tendent la trésorerie.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Pourquoi ajoute-t-on les dotations aux amortissements au résultat pour calculer la CAF ?$mft$,
    $mft$[
      {"id":"a","label":"Parce que ce sont des charges calculées qui n'entraînent aucune sortie de trésorerie sur l'exercice","is_correct":true},
      {"id":"b","label":"Parce qu'elles sont remboursées par l'administration fiscale","is_correct":false},
      {"id":"c","label":"Parce qu'elles augmentent le chiffre d'affaires","is_correct":false},
      {"id":"d","label":"Parce qu'elles sont payées par le client final","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-e','qcm-v1'], 'CAPA-LOURD-E-QCM-09', false,
    $mft$La dotation constate l'usure d'un bien déjà payé : charge comptable sans décaissement. La CAF neutralise ces charges calculées pour approcher la trésorerie réellement générée.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Une journée d'exploitation : 480 km à 0,65 €/km de terme kilométrique, 10 h à 32 €/h de conducteur, terme journalier de 330 €. Quel est le coût de revient de la journée ?$mft$,
    $mft$[
      {"id":"a","label":"962 €","is_correct":true},
      {"id":"b","label":"958 €","is_correct":false},
      {"id":"c","label":"1 042 €","is_correct":false},
      {"id":"d","label":"878 €","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-e','qcm-v1'], 'CAPA-LOURD-E-QCM-10', false,
    $mft$Trinôme : (480 × 0,65) + (10 × 32) + 330 = 312 + 320 + 330 = 962 €. Poser les trois termes séparément avant d'additionner évite les erreurs d'étourderie, fréquentes sur cette question.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Charges fixes de 300 000 € et taux de marge sur coûts variables de 40 % : quel est le seuil de rentabilité ?$mft$,
    $mft$[
      {"id":"a","label":"120 000 €","is_correct":false},
      {"id":"b","label":"500 000 €","is_correct":false},
      {"id":"c","label":"750 000 €","is_correct":true},
      {"id":"d","label":"1 200 000 €","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-e','qcm-v1'], 'CAPA-LOURD-E-QCM-11', false,
    $mft$SR = charges fixes / taux de MCV = 300 000 / 0,40 = 750 000 €. À ce chiffre d'affaires, la marge sur coûts variables (750 000 × 40 % = 300 000 €) couvre exactement les charges fixes.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Quelle est la caractéristique principale du crédit-bail pour financer un tracteur ?$mft$,
    $mft$[
      {"id":"a","label":"L'entreprise paie des loyers déductibles et ne devient propriétaire qu'en levant l'option d'achat finale","is_correct":true},
      {"id":"b","label":"L'entreprise est propriétaire dès la signature et amortit le véhicule","is_correct":false},
      {"id":"c","label":"C'est une subvention publique à l'investissement","is_correct":false},
      {"id":"d","label":"C'est un prêt sans intérêts consenti par le constructeur","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-e','qcm-v1'], 'CAPA-LOURD-E-QCM-12', false,
    $mft$Crédit-bail : location avec promesse de vente ; loyers déductibles, pas de propriété (donc pas d'amortissement) pendant le contrat, transfert par la levée d'option finale. Comparer le coût total de détention avec l'achat à crédit.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Quelles sont les deux grandes catégories de charges pour l'analyse du coût de revient ?$mft$,
   $mft$Les charges variables (liées à l'activité, au kilomètre) et les charges fixes (indépendantes de l'activité).$mft$,
   2, 'facile', ARRAY['capa-lourd','module-e','question-courte'], 'CAPA-LOURD-E-QC-01', false,
   $mft$Un exemple de chaque est un bonus (carburant / assurance).$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quel document comptable donne la photographie du patrimoine de l'entreprise à la clôture ?$mft$,
   $mft$Le bilan.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-e','question-courte'], 'CAPA-LOURD-E-QC-02', false,
   $mft$Actif (ce que l'entreprise possède) / passif (ses ressources et dettes).$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Donnez la formule simplifiée de la capacité d'autofinancement (CAF).$mft$,
   $mft$CAF = résultat net + dotations aux amortissements et provisions (− reprises).$mft$,
   2, 'facile', ARRAY['capa-lourd','module-e','question-courte'], 'CAPA-LOURD-E-QC-03', false,
   $mft$L'idée clé : réintégrer les charges calculées non décaissées.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Citez les trois termes de la méthode du trinôme et leur inducteur respectif.$mft$,
   $mft$Le terme kilométrique (kilomètres parcourus), le terme horaire du personnel de conduite (heures de service) et le terme journalier véhicule/structure (jours d'exploitation).$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-e','question-courte'], 'CAPA-LOURD-E-QC-04', false,
   $mft$Exiger les trois termes ET les trois inducteurs.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Donnez la formule du seuil de rentabilité.$mft$,
   $mft$Seuil de rentabilité = charges fixes / taux de marge sur coûts variables (taux de MCV = (CA − charges variables) / CA).$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-e','question-courte'], 'CAPA-LOURD-E-QC-05', false,
   $mft$Accepter la formule avec le taux exprimé en pourcentage ou en fraction.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Quel est le délai de paiement maximal des factures de transport routier de marchandises ?$mft$,
   $mft$30 jours à compter de la date d'émission de la facture.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-e','question-courte'], 'CAPA-LOURD-E-QC-06', false,
   $mft$Régime spécial transport, plus court que le droit commun.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Donnez la définition du besoin en fonds de roulement (BFR).$mft$,
   $mft$L'argent immobilisé par le cycle d'exploitation : créances clients (+ stocks) − dettes fournisseurs.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-e','question-courte'], 'CAPA-LOURD-E-QC-07', false,
   $mft$En transport : clients payés à 30 jours et plus, décaissements rapides → BFR élevé.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Que prévoit la loi lorsque le prix du gazole varie entre la conclusion du contrat de transport et sa réalisation, en l'absence de clause d'indexation ?$mft$,
   $mft$La révision de plein droit du prix du transport pour tenir compte de la variation du coût du carburant (mécanisme légal, d'ordre public).$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-e','question-courte'], 'CAPA-LOURD-E-QC-08', false,
   $mft$Dit « pied de facture » ; référence usuelle aux indices CNR.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quelle différence sépare l'excédent brut d'exploitation (EBE) du résultat d'exploitation ?$mft$,
   $mft$Les dotations aux amortissements (et provisions) : le résultat d'exploitation = EBE − dotations.$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-e','question-courte'], 'CAPA-LOURD-E-QC-09', false,
   $mft$L'EBE mesure la performance économique avant politique d'amortissement et de financement.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Qu'est-ce que le crédit-bail et par quoi se termine-t-il ?$mft$,
   $mft$Une location de matériel avec loyers déductibles, assortie d'une option d'achat que l'entreprise peut lever en fin de contrat pour devenir propriétaire.$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-e','question-courte'], 'CAPA-LOURD-E-QC-10', false,
   $mft$Pas de propriété (ni d'amortissement) pendant le contrat ; comparer le coût total avec l'achat à crédit.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) — barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Classez les postes suivants en charges variables (au kilomètre), charges horaires (personnel) ou charges journalières/fixes, en justifiant brièvement : carburant, assurance flotte, salaires et charges des conducteurs, pneumatiques, amortissement du tracteur, péages, loyer du dépôt, entretien-réparations.$mft$,
   $mft$Réponse modèle. Variables au kilomètre : carburant (consommation proportionnelle aux km), pneumatiques (usure kilométrique), péages (payés par trajet), entretien-réparations (croît avec l'usage, part kilométrique dominante). Horaires (personnel) : salaires et charges des conducteurs : ils rémunèrent le temps de service (conduite, attente, quai), pas les kilomètres. Journalières/fixes : assurance flotte (due véhicule roulant ou pas), amortissement du tracteur (constate l'usure/l'obsolescence sur la durée, indépendamment du planning quotidien), loyer du dépôt (charge de structure). Justification d'ensemble : chaque poste est rattaché à l'inducteur qui pilote réellement sa consommation : c'est la base de la méthode du trinôme et la condition de devis fiables.$mft$,
   $mft$Barème /5 : 0,5 pt par poste correctement classé (4 pts) ; 1 pt pour la qualité des justifications (inducteurs explicités, pas de classement arbitraire). Erreurs fréquentes : classer les salaires en variable kilométrique ; oublier que l'entretien suit majoritairement le kilométrage.$mft$,
   5, 'facile', ARRAY['capa-lourd','module-e','question-redigee'], 'CAPA-LOURD-E-QR-01', false,
   $mft$Exercice de classement fondamental, préalable à tout calcul de coût.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Expliquez pourquoi le BFR d'une entreprise de transport est structurellement élevé et croît avec l'activité, puis proposez quatre leviers concrets pour le réduire ou le financer.$mft$,
   $mft$Réponse modèle. Structure : le transporteur encaisse tard (clients à 30 jours légaux, souvent plus en pratique du fait des retards) et décaisse tôt (gazole quasi comptant via cartes, salaires et charges mensuels, péages prélevés) ; il n'a presque pas de stocks mais un poste clients massif. Le BFR = créances − dettes fournisseurs est donc positif et important. Croissance : chaque euro de chiffre d'affaires supplémentaire génère immédiatement des décaissements (gazole, paie) alors que l'encaissement arrive 30 à 60 jours plus tard : croître AUGMENTE le besoin, d'où des crises de trésorerie paradoxales en pleine réussite commerciale. Leviers : 1) facturer immédiatement à la livraison (dématérialisation) et relancer systématiquement dès l'échéance (délai légal 30 jours + pénalités + 40 €) ; 2) mobiliser les créances : affacturage ou escompte pour convertir le poste clients en trésorerie ; 3) négocier les décaissements : mensualisation des échéances, conditions des cartes carburant, calendrier fournisseurs ; 4) demander des acomptes ou des paiements à réception pour les gros dossiers ponctuels ; 5) piloter par un plan de trésorerie mensuel pour anticiper les impasses au lieu de les subir.$mft$,
   $mft$Barème /5 : mécanisme encaisse tard / décaisse tôt (1,5 pt) ; explication de la croissance du BFR avec l'activité (1,5 pt) ; quatre leviers concrets et pertinents (2 pts). Erreurs fréquentes : attribuer le BFR aux stocks ; proposer « augmenter le CA » comme solution (cela aggrave le besoin à court terme).$mft$,
   5, 'facile', ARRAY['capa-lourd','module-e','question-redigee'], 'CAPA-LOURD-E-QR-02', false,
   $mft$Compréhension du paradoxe trésorerie/croissance propre au TRM.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Cas chiffré. Une journée type d'un ensemble 44 t : 520 km, 11 h de service conducteur, terme kilométrique 0,68 €/km, coût horaire conducteur chargé 32 €/h, terme journalier (véhicule + structure) 320 €. a) Calculez le coût de revient de la journée. b) Quel prix facturer pour dégager 12 % de marge sur coût ? c) Le client impose 2 h d'attente supplémentaires non prévues : quel est le nouveau coût, et que doit faire le transporteur ?$mft$,
   $mft$Réponse modèle. a) Kilométrique : 520 × 0,68 = 353,60 € ; horaire : 11 × 32 = 352,00 € ; journalier : 320,00 €. Coût de revient = 353,60 + 352 + 320 = 1 025,60 €. b) Prix = 1 025,60 × 1,12 = 1 148,67 € (arrondi au centime). c) Deux heures d'attente ajoutent 2 × 32 = 64 € de coût horaire : nouveau coût = 1 089,60 € ; la marge prévue fond de 64 € si le prix reste inchangé (marge résiduelle : 1 148,67 − 1 089,60 = 59,07 €, soit environ 5,4 % du coût au lieu de 12 %). Le transporteur doit facturer les attentes (clause d'attente au contrat, tarif horaire annoncé), au minimum les documenter (heures d'arrivée/départ signées) pour les négocier, et intégrer ce client « chronophage » dans sa tarification future.$mft$,
   $mft$Barème /5 : trois termes posés et coût 1 025,60 € (2 pts) ; prix 1 148,67 € (1 pt) ; surcoût 64 € et nouveau coût 1 089,60 € (1 pt) ; réaction commerciale (facturation/documentation des attentes) (1 pt). Erreurs fréquentes : oublier un terme ; appliquer la marge sur le prix au lieu du coût sans le préciser ; ignorer l'effet des attentes sur la marge.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-e','question-redigee'], 'CAPA-LOURD-E-QR-03', false,
   $mft$Calcul de trinôme complet avec sensibilité aux attentes, format examen.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Cas chiffré. Budget prévisionnel : chiffre d'affaires 1 800 000 €, charges variables 1 170 000 €, charges fixes 540 000 €. a) Calculez le taux de marge sur coûts variables, le seuil de rentabilité et le point mort en jours (année de 360 jours). b) Quel est le résultat prévisionnel ? c) Le CA chute de 10 % à structure inchangée : recalculez le résultat et commentez.$mft$,
   $mft$Réponse modèle. a) MCV = 1 800 000 − 1 170 000 = 630 000 € ; taux de MCV = 630 000 / 1 800 000 = 35 %. SR = 540 000 / 0,35 = 1 542 857 € (arrondi). Point mort = 1 542 857 / 1 800 000 × 360 ≈ 309e jour : l'entreprise ne devient bénéficiaire qu'en toute fin d'exercice. b) Résultat = MCV − CF = 630 000 − 540 000 = 90 000 € (5 % du CA). c) CA à 1 620 000 € ; les charges variables suivent l'activité (65 % du CA) : MCV = 1 620 000 × 35 % = 567 000 € ; résultat = 567 000 − 540 000 = 27 000 €. Commentaire : une baisse de 10 % du CA détruit 70 % du résultat (90 000 → 27 000) : levier opérationnel élevé, typique du transport (charges fixes lourdes) ; la marge de sécurité (CA − SR = 257 143 €, soit 14 % du CA) est mince : chaque point de remplissage et chaque hausse non répercutée comptent.$mft$,
   $mft$Barème /5 : taux de MCV 35 % (0,75 pt) ; SR 1 542 857 € (1 pt) ; point mort ≈ 309 jours (0,75 pt) ; résultat 90 000 € (0,5 pt) ; recalcul à −10 % : 27 000 € (1,25 pt) ; commentaire sur le levier/la marge de sécurité (0,75 pt). Erreurs fréquentes : diviser les CF par le taux de charges variables ; faire chuter les charges fixes avec le CA.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-e','question-redigee'], 'CAPA-LOURD-E-QR-04', false,
   $mft$Seuil de rentabilité complet avec test de sensibilité, cœur de l'épreuve.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Cas chiffré. Compte de résultat simplifié : produits 2 400 000 € ; carburant 480 000 ; salaires et charges 960 000 ; péages 120 000 ; entretien 96 000 ; autres charges externes 360 000 ; impôts et taxes 60 000 ; dotations aux amortissements 180 000 ; charges financières 24 000. a) Calculez le résultat avant impôt et la CAF avant impôt. b) Analysez la structure des coûts (poids du carburant et de la masse salariale en % du CA) et le niveau de marge. c) L'entreprise doit rembourser 220 000 € d'annuités d'emprunt l'an prochain : qu'en concluez-vous ?$mft$,
   $mft$Réponse modèle. a) Total des charges = 480 000 + 960 000 + 120 000 + 96 000 + 360 000 + 60 000 + 180 000 + 24 000 = 2 280 000 €. Résultat avant impôt = 2 400 000 − 2 280 000 = 120 000 € (5 % du CA). CAF avant impôt = 120 000 + 180 000 (dotations) = 300 000 €. b) Carburant : 480 000 / 2 400 000 = 20 % du CA ; masse salariale : 960 000 / 2 400 000 = 40 % : structure conforme aux standards du TRM (carburant 20-30 %, salaires 35-45 %) ; marge avant impôt de 5 %, correcte pour le secteur mais sensible : 1 point de dérive carburant non répercuté (24 000 €) ampute le résultat de 20 %. c) CAF 300 000 € > annuités 220 000 € : l'entreprise couvre ses remboursements avec 80 000 € de marge de manœuvre (avant impôt et dividendes) : soutenable, mais un investissement supplémentaire important devrait s'appuyer sur cette CAF résiduelle réduite : prudence sur les nouveaux engagements ou renfort de fonds propres.$mft$,
   $mft$Barème /5 : total charges et résultat 120 000 € (1,5 pt) ; CAF 300 000 € (1 pt) ; pourcentages 20 % / 40 % et lecture sectorielle (1,25 pt) ; comparaison CAF/annuités avec conclusion nuancée (1,25 pt). Erreurs fréquentes : oublier les dotations dans la CAF ; comparer les annuités au résultat au lieu de la CAF.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-e','question-redigee'], 'CAPA-LOURD-E-QR-05', false,
   $mft$Lecture financière complète d'un compte de résultat de transporteur.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un chargeur vous consulte pour une navette quotidienne régulière sur 12 mois. Décrivez votre méthode pour construire le devis, de l'analyse de l'exploitation à la clause gazole, en explicitant chaque étape.$mft$,
   $mft$Réponse modèle. 1) Analyser l'exploitation : kilométrage précis de la boucle (chargé/à vide), temps de service (conduite, chargement, attentes annoncées), contraintes (horaires, hayon, matières particulières), possibilité de fret retour pour réduire les kilomètres à vide. 2) Chiffrer le coût par le trinôme : terme kilométrique (carburant au prix du jour, pneus, entretien, péages réels de l'itinéraire), terme horaire conducteur (temps de service complet, pas seulement la conduite), terme journalier (amortissement du véhicule dédié, assurances, taxes, quote-part de structure) : coût journalier puis annuel. 3) Ajouter les spécificités : saisonnalité, remplacements du conducteur (congés), aléas (attente au-delà d'un forfait inclus, facturée au tarif horaire annoncé). 4) Fixer le prix : marge cible explicite sur le coût complet ; prix par jour ou par tournée ; conditions de révision annuelle. 5) Sécuriser le contrat : clause d'indexation gazole (référence indice CNR, périodicité mensuelle, formule sur la part gazole du prix) : à défaut la révision légale s'appliquerait, mais la clause claire évite les litiges ; délais de paiement 30 jours, pénalités, conditions de résiliation avec préavis. 6) Réviser en cours de contrat : suivi mensuel de la rentabilité réelle (attentes constatées, gazole) et application effective de l'indexation.$mft$,
   $mft$Barème /5 : analyse d'exploitation complète dont kilomètres à vide et attentes (1,5 pt) ; chiffrage trinôme correct (1,5 pt) ; clause gazole précise (indice, périodicité, part gazole) (1 pt) ; conditions contractuelles (30 jours, attentes, révision) (1 pt). Erreurs fréquentes : coter au seul coût kilométrique moyen ; oublier remplacements et congés du conducteur dédié ; clause gazole vague.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-e','question-redigee'], 'CAPA-LOURD-E-QR-06', false,
   $mft$Méthode de devis bout en bout, synthèse des leçons 1 et 2.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas d'arbitrage. Pour renouveler un tracteur, deux options : achat 110 000 € financé par emprunt sur 5 ans (intérêts totaux de l'ordre de 11 500 €), amortissement linéaire 5 ans ; ou crédit-bail 60 loyers de 2 100 € avec option d'achat finale 5 000 €. Comparez les deux options (coût total, trésorerie, comptabilité/fiscalité) et donnez les critères de décision.$mft$,
   $mft$Réponse modèle. Coût total : achat = 110 000 + 11 500 ≈ 121 500 € (avant valeur de revente, qui vient en déduction du coût réel de détention) ; crédit-bail = 60 × 2 100 + 5 000 = 126 000 + 5 000 = 131 000 € : le crédit-bail coûte environ 9 500 € de plus, prix de la souplesse. Trésorerie : l'achat exige souvent un apport et pèse sur la capacité d'emprunt ; le crédit-bail préserve la trésorerie initiale et lisse la charge. Comptabilité/fiscalité : achat = actif immobilisé + amortissement 22 000 €/an déductible + intérêts déductibles + dette au bilan ; crédit-bail = loyers intégralement déductibles (25 200 €/an), pas d'actif ni de dette apparente pendant le contrat (mais engagement réel, réintégré par les banques), propriété seulement à la levée d'option. Critères de décision : coût total de détention incluant la valeur de revente estimée, tension de trésorerie actuelle, politique de renouvellement (garder 8 ans → achat souvent gagnant ; tourner à 4-5 ans → crédit-bail pertinent), covenants bancaires et image du bilan (capacité financière du transporteur), fiscalité effective de l'entreprise. Conclusion attendue : pas de réponse universelle : chiffrer le coût total, puis trancher selon trésorerie et durée de détention prévue.$mft$,
   $mft$Barème /5 : coûts totaux exacts (121 500 € vs 131 000 €) avec la nuance valeur de revente (2 pts) ; différences de trésorerie (1 pt) ; traitement comptable/fiscal des deux options (1,5 pt) ; critères de décision pertinents (0,5 pt). Erreurs fréquentes : comparer sans l'option d'achat ni les intérêts ; croire le crédit-bail « invisible » pour les banques.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-e','question-redigee'], 'CAPA-LOURD-E-QR-07', false,
   $mft$Arbitrage de financement chiffré, grand classique de l'épreuve rédigée.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas chiffré. CA annuel TTC 2 160 000 € encaissé en moyenne à 55 jours ; achats et charges externes TTC 1 080 000 € payés en moyenne à 30 jours ; stocks négligeables. a) Estimez le BFR (année de 360 jours). b) L'entreprise vise +20 % d'activité l'an prochain : estimez le BFR futur et le financement additionnel requis. c) Proposez trois actions pour contenir cette dérive.$mft$,
   $mft$Réponse modèle. a) Créances clients = 2 160 000 / 360 × 55 = 6 000 × 55 = 330 000 €. Dettes fournisseurs = 1 080 000 / 360 × 30 = 3 000 × 30 = 90 000 €. BFR ≈ 330 000 − 90 000 = 240 000 €. b) À +20 % et délais constants, le BFR croît proportionnellement : 240 000 × 1,20 = 288 000 €, soit un besoin additionnel de 48 000 € à financer AVANT d'encaisser le premier euro de croissance : c'est le coût de trésorerie de la croissance. c) Actions : réduire le délai clients réel (facturation immédiate, relances à J+1 de l'échéance, application des pénalités et des 40 €, acomptes sur les nouveaux contrats) : chaque jour gagné vaut 6 000 € de trésorerie ; mobiliser les créances (affacturage) pour financer le poste clients pendant la croissance ; négocier les délais fournisseurs et lisser les décaissements (mensualisations) ; sécuriser une ligne court terme dimensionnée AVANT le pic. Mention utile : le délai légal transport étant de 30 jours, un délai réel de 55 jours signale des retards à combattre plutôt qu'à financer.$mft$,
   $mft$Barème /5 : BFR 240 000 € posé et calculé (2 pts) ; projection 288 000 € et besoin additionnel 48 000 € (1,5 pt) ; trois actions dont au moins une sur le délai clients avec le rappel des 30 jours légaux (1,5 pt). Erreurs fréquentes : oublier de raisonner en TTC ; croire que la croissance améliore mécaniquement la trésorerie ; financer les retards clients au lieu de les combattre.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-e','question-redigee'], 'CAPA-LOURD-E-QR-08', false,
   $mft$Calcul de BFR et coût de trésorerie de la croissance, avec le levier « jour de CA ».$mft$);

  RAISE NOTICE 'Module E Capa lourd créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $capae$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Volumes : select "type", active, count(*) from question_bank
--     where source_ref like 'CAPA-LOURD-E-%' group by 1, 2;
--    → attendu : qcm/false = 12, qr/false = 18.
-- 2) QCM à bonne réponse unique :
--    select source_ref from question_bank
--     where source_ref like 'CAPA-LOURD-E-QCM-%'
--       and (select count(*) from jsonb_array_elements(choices) c
--             where (c->>'is_correct')::boolean) <> 1;   → 0 ligne.
-- 3) Doublons d'énoncés sur la formation :
--    select statement, count(*) from question_bank
--     where formation_id = (select id from formations where slug='capacite-plus-3-5t')
--     group by 1 having count(*) > 1;                    → 0 ligne.
