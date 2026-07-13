-- =====================================================================
-- CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : MODULE A : DROIT CIVIL : v1
-- (juillet 2026) : LOT 2
--
-- Domaine A de l'annexe I du règlement (CE) n° 1071/2009 : éléments
-- de droit civil nécessaires à l'exercice de la profession (contrats,
-- responsabilité, mandat, prescription, garanties).
-- Références : code civil (réforme des contrats 2016), code de commerce
-- (L. 133-1 s. pour le contrat de transport), loi du 14 février 2022
-- (statut de l'entrepreneur individuel).
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
--   Aucune inscription sur la formation (vérifié 12/07/2026).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- Angles volontairement distincts du module A de la Capacité ≤ 3,5 t
-- (aucune reprise des énoncés existants).
-- =====================================================================

DO $capaa$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'CAPA-LOURD-A-%';
  DELETE FROM public.modules WHERE slug = 'capa-lourd-droit-civil';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module A : Droit civil',
    'capa-lourd-droit-civil',
    v_bloc,
    'Les bases du droit civil pour diriger une entreprise de transport : personnes et patrimoine, formation et exécution des contrats, responsabilité civile, mandat et commission, prescriptions et garanties.',
    'intermediaire',
    540,
    10
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 10, true);

  -- ─── Leçon 1 : Personnes, patrimoine et capacité ────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'personnes-patrimoine-capacite',
    'Personnes, patrimoine et capacité',
    $mft$> 🎯 **Objectifs**
> - Distinguer personne physique et personne morale, et leurs attributs.
> - Expliquer la notion de patrimoine et la protection de l'entrepreneur individuel.
> - Identifier qui peut valablement s'engager par contrat.

## Personne physique, personne morale

Le droit reconnaît deux catégories de **sujets de droit** :

- la **personne physique** : tout être humain, de sa naissance à son décès ;
- la **personne morale** : un groupement (société, association, GIE) doté d'une existence juridique propre, distincte de celle de ses membres.

Une personne morale a ses propres attributs : un **nom** (dénomination sociale), un **domicile** (siège social), un **patrimoine** et la capacité d'agir en justice. Dans le transport, l'entreprise exploitante est le plus souvent une société (SARL, SAS) : c'est **elle** qui est inscrite au registre des transporteurs, titulaire de la licence, employeur des conducteurs.

> 📌 **À retenir**
> Quand une SAS de transport signe un contrat, c'est la personne morale qui s'engage, pas son dirigeant à titre personnel. Le dirigeant n'engage sa responsabilité propre qu'en cas de faute séparable de ses fonctions ou de garantie personnelle consentie.

## Le patrimoine

Le patrimoine est l'ensemble des **biens, droits et obligations** d'une personne : un actif (véhicules, créances clients, fonds de commerce) et un passif (dettes fournisseurs, emprunts). Toute personne a un patrimoine, et les créanciers se paient sur ce patrimoine.

### La protection de l'entrepreneur individuel

Depuis la loi du 14 février 2022, l'**entrepreneur individuel** bénéficie de plein droit d'une **séparation entre son patrimoine professionnel et son patrimoine personnel** : les créanciers professionnels ne peuvent saisir, en principe, que les biens utiles à l'activité. Par ailleurs, la **résidence principale** est insaisissable de droit par les créanciers professionnels.

> ⚠️ **Attention**
> Cette protection connaît des limites : renonciation possible au profit d'une banque, dettes fiscales et sociales en cas de manœuvres frauduleuses, et cautionnement personnel consenti par l'entrepreneur. Signer une caution personnelle fait retomber le risque sur le patrimoine privé.

## La capacité juridique

Pour s'engager valablement, il faut la **capacité** :

| Situation | Peut-elle contracter ? |
| --- | --- |
| Majeur non protégé | Oui, pleine capacité |
| Mineur non émancipé | Non pour les actes graves : représentation par les parents ou le tuteur |
| Majeur protégé (tutelle, curatelle) | Selon le régime : assistance ou représentation |

Un contrat conclu par une personne incapable est exposé à la **nullité**.

## Application transport

Avant de contracter avec un nouveau partenaire (client donneur d'ordre, sous-traitant), un transporteur vérifie : l'**existence juridique** (extrait Kbis), l'identité du **signataire** et son **pouvoir d'engager** la société (dirigeant, délégation de pouvoir), la solvabilité apparente.

> 💡 **Astuce**
> Le réflexe professionnel : Kbis de moins de 3 mois + vérification du signataire. Un contrat signé par une personne sans pouvoir peut être inopposable à la société prétendument engagée.

## ✅ Synthèse

- Deux sujets de droit : **personne physique** et **personne morale** ; la société de transport s'engage elle-même, par ses représentants.
- **Patrimoine** = actif + passif ; entrepreneur individuel 2022 : **séparation de plein droit** pro/perso, résidence principale insaisissable.
- La **capacité** conditionne la validité de l'engagement ; vérifier existence, signataire et pouvoirs avant de contracter.$mft$,
    $mft$Personnes physiques et morales, attributs de la personnalité, patrimoine et protection de l'entrepreneur individuel (loi 2022), capacité juridique et vérifications avant de contracter.$mft$,
    1, 40) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Le contrat : formation, validité, exécution ─────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'contrat-formation-validite-execution',
    'Le contrat : formation, validité et exécution',
    $mft$> 🎯 **Objectifs**
> - Citer les trois conditions de validité d'un contrat.
> - Reconnaître les clauses sensibles d'un contrat de prestation transport.
> - Dérouler les remèdes à l'inexécution, de la mise en demeure à la résolution.

## La formation du contrat

Le contrat naît de la rencontre d'une **offre** et d'une **acceptation**. Depuis la réforme de 2016, le code civil (art. 1128) exige **trois conditions de validité** :

1. le **consentement** des parties, libre et éclairé ;
2. leur **capacité** de contracter ;
3. un **contenu licite et certain**.

### Les vices du consentement

Le consentement est vicié par :

- l'**erreur** : croyance fausse sur une qualité essentielle de la prestation ;
- le **dol** : tromperie provoquée par des manœuvres, mensonges ou dissimulation intentionnelle ;
- la **violence** : contrainte physique, morale ou économique (abus de dépendance).

Un vice du consentement ouvre la **nullité relative** du contrat (seule la victime peut agir), tandis que l'illicéité du contenu relève de la **nullité absolue** (tout intéressé peut agir).

## La force obligatoire

> 📌 **À retenir**
> « Les contrats légalement formés tiennent lieu de loi à ceux qui les ont faits. » Le contrat s'impose aux parties comme une loi privée : on ne peut ni le modifier ni le rompre unilatéralement, sauf clause ou accord.

## Les clauses à examiner dans un contrat de transport ou de prestation

| Clause | Effet | Vigilance |
| --- | --- | --- |
| Clause pénale | Fixe d'avance l'indemnité due en cas de manquement | Le juge peut la modérer si elle est manifestement excessive ou dérisoire |
| Clause résolutoire | Résout le contrat de plein droit en cas de manquement défini | Généralement après mise en demeure restée infructueuse |
| Clause limitative de responsabilité | Plafonne l'indemnisation | Neutralisée si elle vide de sa substance l'obligation essentielle, ou en cas de faute lourde ou dolosive |
| Clause attributive de compétence | Désigne le tribunal | Valable entre commerçants si très apparente |

> 🔍 **Focus**
> Jurisprudence célèbre en messagerie : une clause qui limite l'indemnisation au prix du transport alors que le transporteur a manqué à son **obligation essentielle** de délai garanti peut être réputée non écrite. Les plafonds des contrats types transport restent, eux, applicables dans leurs conditions propres.

## L'inexécution et ses remèdes

:::timeline
1. **Constat du manquement** : retard, prestation non conforme, impayé.
2. **Mise en demeure** : lettre recommandée sommant d'exécuter : point de départ des dommages-intérêts et de la plupart des sanctions.
3. **Remèdes** : exception d'inexécution (suspendre sa propre prestation), exécution forcée, réduction du prix, résolution du contrat, dommages-intérêts.
:::

### La force majeure

L'article 1218 du code civil exonère le débiteur quand un événement **échappe à son contrôle**, était **imprévisible** à la conclusion et ses effets **irrésistibles** : le débiteur est libéré sans dommages-intérêts (suspension si l'empêchement est temporaire).

> ❌ **Piège à éviter**
> La panne du véhicule ou la défaillance d'un sous-traitant ne sont en principe **pas** des cas de force majeure : ce sont des aléas internes à l'exploitation, prévisibles et surmontables.

## ✅ Synthèse

- Validité : **consentement, capacité, contenu licite et certain** ; vices = erreur, dol, violence.
- Le contrat a **force obligatoire** ; clauses pénale, résolutoire, limitative à examiner de près.
- Réflexe : **mise en demeure** avant sanctions ; force majeure = échappe au contrôle + imprévisible + irrésistible.$mft$,
    $mft$Conditions de validité (art. 1128), vices du consentement et nullités, force obligatoire, clauses pénale/résolutoire/limitative, mise en demeure, remèdes à l'inexécution et force majeure.$mft$,
    2, 50) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : La responsabilité civile ────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'responsabilite-civile',
    'La responsabilité civile',
    $mft$> 🎯 **Objectifs**
> - Distinguer responsabilité contractuelle et responsabilité délictuelle.
> - Vérifier les trois conditions de la responsabilité.
> - Situer la responsabilité du transporteur et celle du commettant du fait de ses préposés.

## Deux ordres de responsabilité

| | Responsabilité contractuelle | Responsabilité délictuelle |
| --- | --- | --- |
| Situation | Un contrat lie l'auteur et la victime | Aucun contrat entre eux |
| Fondement | Inexécution ou mauvaise exécution du contrat | Fait dommageable (art. 1240 du code civil) |
| Exemple transport | Marchandise livrée avariée au client | Un tiers blessé par la chute d'un colis mal arrimé |

La règle du **non-cumul** : entre parties à un contrat, on agit sur le terrain contractuel, pas au choix.

## Les trois conditions

:::flow
1. Fait générateur | Faute, inexécution, fait d'une chose ou d'un préposé
2. Dommage | Matériel, corporel ou moral, certain et direct
3. Lien de causalité | Le fait a causé le dommage
:::

Sans l'une des trois, pas de responsabilité. Les **causes d'exonération** : force majeure, fait d'un tiers, faute de la victime (exonération totale ou partielle).

## Le fait des préposés

Le **commettant** (l'employeur) répond des dommages causés par ses **préposés** (salariés) dans leurs fonctions : l'entreprise de transport répond ainsi des fautes de conduite de ses conducteurs à l'égard des tiers. Le préposé qui agit **hors de ses fonctions**, sans autorisation et à des fins étrangères, engage sa seule responsabilité.

> ⚠️ **Attention**
> L'assurance de responsabilité civile professionnelle et l'assurance du véhicule sont indispensables mais ne couvrent pas tout : conduite sous stupéfiants, faute intentionnelle. L'entreprise conserve les franchises et le malus.

## La responsabilité du transporteur de marchandises

Sur le terrain **contractuel**, le transporteur routier est présumé responsable des **pertes et avaries** survenues entre la prise en charge et la livraison, ainsi que du **retard**. Il s'exonère en prouvant la force majeure, le **vice propre de la marchandise** ou la **faute de l'expéditeur** (emballage défectueux, déclaration inexacte). L'indemnisation est plafonnée par les **contrats types** ou la convention applicable, sauf faute inexcusable.

> 🎓 **Examen**
> Réflexe attendu : qualifier d'abord le terrain (contractuel ou délictuel), puis dérouler fait générateur, dommage, causalité, et chercher les exonérations. Les questions rédigées notent cette structure.

## ✅ Synthèse

- Contractuel entre parties au contrat, délictuel envers les tiers ; **non-cumul**.
- Trois conditions : **fait générateur, dommage, lien de causalité** ; exonérations : force majeure, fait d'un tiers, faute de la victime.
- Le **commettant répond de ses préposés** ; le transporteur est **présumé responsable** des avaries et du retard, avec plafonds d'indemnisation.$mft$,
    $mft$Responsabilité contractuelle vs délictuelle, non-cumul, les trois conditions et les exonérations, la responsabilité du commettant du fait des préposés et la présomption pesant sur le transporteur.$mft$,
    3, 45) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Mandat, commission, prescription et garanties ───────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'mandat-commission-prescription-garanties',
    'Mandat, commission, prescription et garanties',
    $mft$> 🎯 **Objectifs**
> - Différencier mandat et commission dans la chaîne du transport.
> - Appliquer les bons délais de prescription aux litiges transport.
> - Mobiliser les garanties du créancier, dont le droit de rétention du voiturier.

## Mandat et commission

Le **mandat** : le mandataire agit **au nom et pour le compte** du mandant ; les actes engagent directement le mandant. Exemple : un dirigeant donne mandat à son adjoint pour signer les contrats clients.

La **commission** : le commissionnaire agit **en son nom propre**, mais **pour le compte** d'un commettant. Le commissionnaire de transport organise librement l'acheminement (choix des transporteurs, des modes) et répond tant de son fait que de celui des transporteurs qu'il se substitue.

> 📌 **À retenir**
> Mandataire : transparent, il engage le mandant. Commissionnaire : écran, il s'engage lui-même envers le client et se retourne ensuite contre ses substitués. Cette distinction structure toute la chaîne contractuelle du transport.

## Les prescriptions

La prescription éteint l'action en justice à l'expiration d'un délai :

| Action | Délai |
| --- | --- |
| Droit commun (civil et commercial) | 5 ans |
| Actions nées du contrat de transport (avaries, pertes, retard, prix) | 1 an |
| Dommages corporels | 10 ans à compter de la consolidation |

> ❌ **Piège à éviter**
> Une facture de transport impayée se prescrit par **1 an**, pas 5. Le transporteur qui laisse traîner son recouvrement perd son action : il faut facturer vite, relancer vite, agir vite.

## Les garanties du créancier

Pour se prémunir contre l'impayé, le créancier peut mobiliser :

- le **cautionnement** : un tiers (souvent le dirigeant) s'engage à payer si le débiteur défaille ; engagement grave, formalisme protecteur ;
- le **gage** (meuble) et l'**hypothèque** (immeuble) : sûretés réelles donnant un droit de préférence ;
- la **clause de réserve de propriété** : le vendeur reste propriétaire jusqu'au paiement complet ;
- le **droit de rétention du voiturier** : le transporteur peut retenir la marchandise transportée jusqu'au paiement des sommes qui lui sont dues au titre de ce transport.

> 💡 **Astuce**
> Le droit de rétention est l'arme dissuasive du transporteur impayé, mais il s'exerce avec prudence : sur les créances liées à l'opération, sans dégrader la marchandise, et en mesurant le risque commercial.

## Recouvrer une créance : la gradation

:::timeline
1. **Relance amiable** : appel, courriel, puis lettre de relance.
2. **Mise en demeure** : recommandé avec AR : fait courir intérêts et délais.
3. **Injonction de payer** : procédure rapide et peu coûteuse pour créance certaine.
4. **Assignation au fond** : si la créance est contestée sérieusement.
:::

Entre professionnels, tout retard de paiement déclenche de plein droit des **pénalités de retard** et l'**indemnité forfaitaire de recouvrement de 40 €** par facture.

## ✅ Synthèse

- **Mandat** = agir au nom d'autrui ; **commission** = en son nom propre pour le compte d'autrui.
- Prescriptions : **5 ans** droit commun, **1 an** contrat de transport.
- Garanties : cautionnement, sûretés réelles, réserve de propriété, **droit de rétention du voiturier** ; recouvrement gradué, 40 € d'indemnité forfaitaire par facture entre pros.$mft$,
    $mft$Mandat vs commission, prescriptions applicables (5 ans droit commun, 1 an transport), cautionnement et sûretés, droit de rétention du voiturier et gradation du recouvrement.$mft$,
    4, 45) RETURNING id INTO v_l4;

  -- ─── Quiz d'entraînement ────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module,
    'Quiz : Droit civil',
    'Validez les fondamentaux du module A : contrats, responsabilité, mandat, prescriptions, garanties.',
    'entrainement', 70, false)
  RETURNING id INTO v_quiz;

  -- ─── QCM (12) : 4 faciles / 5 moyens / 3 difficiles ────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quelles sont les trois conditions de validité d'un contrat depuis la réforme du droit des contrats (art. 1128 du code civil) ?$mft$,
    $mft$[
      {"id":"a","label":"Consentement, capacité, contenu licite et certain","is_correct":true},
      {"id":"b","label":"Écrit signé, témoin, enregistrement","is_correct":false},
      {"id":"c","label":"Offre, publicité, prix payé d'avance","is_correct":false},
      {"id":"d","label":"Consentement, cause, objet et écrit obligatoire","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-a','qcm-v1'], 'CAPA-LOURD-A-QCM-01', false,
    $mft$Art. 1128 : consentement des parties, capacité de contracter, contenu licite et certain. L'écrit n'est pas une condition générale de validité (le contrat de transport se prouve par tous moyens, la lettre de voiture en étant l'instrument usuel).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quels sont les trois vices du consentement ?$mft$,
    $mft$[
      {"id":"a","label":"Erreur, dol, violence","is_correct":true},
      {"id":"b","label":"Erreur, retard, insolvabilité","is_correct":false},
      {"id":"c","label":"Dol, lésion, mauvaise foi","is_correct":false},
      {"id":"d","label":"Violence, incapacité, illicéité","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-a','qcm-v1'], 'CAPA-LOURD-A-QCM-02', false,
    $mft$Erreur (croyance fausse), dol (tromperie intentionnelle), violence (contrainte, y compris abus de dépendance économique). L'incapacité et l'illicéité sont d'autres causes de nullité, pas des vices du consentement.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Une facture de transport routier de marchandises impayée doit être réclamée en justice dans un délai de :$mft$,
    $mft$[
      {"id":"a","label":"6 mois","is_correct":false},
      {"id":"b","label":"1 an","is_correct":true},
      {"id":"c","label":"5 ans","is_correct":false},
      {"id":"d","label":"10 ans","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-a','qcm-v1'], 'CAPA-LOURD-A-QCM-03', false,
    $mft$Les actions nées du contrat de transport se prescrivent par un an (code de commerce, art. L. 133-6) : cela vaut pour les avaries et retards, mais aussi pour l'action en paiement du prix du transport.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un piéton est blessé par la chute d'un colis mal arrimé sur un camion. Sur quel terrain sa demande d'indemnisation se place-t-elle vis-à-vis du transporteur ?$mft$,
    $mft$[
      {"id":"a","label":"Responsabilité contractuelle","is_correct":false},
      {"id":"b","label":"Responsabilité délictuelle","is_correct":true},
      {"id":"c","label":"Garantie des vices cachés","is_correct":false},
      {"id":"d","label":"Aucun recours possible","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-a','qcm-v1'], 'CAPA-LOURD-A-QCM-04', false,
    $mft$Aucun contrat ne lie le piéton au transporteur : la responsabilité est délictuelle (art. 1240 et suivants). Le terrain contractuel est réservé aux parties liées par un contrat.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quels sont les trois caractères cumulatifs de la force majeure (art. 1218 du code civil) ?$mft$,
    $mft$[
      {"id":"a","label":"Échappe au contrôle du débiteur, imprévisible à la conclusion, effets irrésistibles","is_correct":true},
      {"id":"b","label":"Extérieur, prévisible, coûteux","is_correct":false},
      {"id":"c","label":"Soudain, climatique, déclaré en préfecture","is_correct":false},
      {"id":"d","label":"Imprévisible, assurable, temporaire","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-a','qcm-v1'], 'CAPA-LOURD-A-QCM-05', false,
    $mft$Art. 1218 : événement échappant au contrôle du débiteur, qui ne pouvait être raisonnablement prévu lors de la conclusion et dont les effets ne peuvent être évités par des mesures appropriées. Une panne ou la défaillance d'un sous-traitant ne remplissent généralement pas ces critères.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quel est l'effet principal d'une clause pénale insérée dans un contrat de prestation ?$mft$,
    $mft$[
      {"id":"a","label":"Elle fixe d'avance l'indemnité due en cas de manquement, le juge pouvant la modérer si elle est manifestement excessive","is_correct":true},
      {"id":"b","label":"Elle transforme le litige civil en affaire pénale","is_correct":false},
      {"id":"c","label":"Elle interdit toute résiliation du contrat","is_correct":false},
      {"id":"d","label":"Elle supprime l'obligation de mise en demeure dans tous les cas","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-a','qcm-v1'], 'CAPA-LOURD-A-QCM-06', false,
    $mft$La clause pénale évalue forfaitairement et d'avance les dommages-intérêts. Malgré son nom, elle n'a rien de pénal ; le juge peut la réviser si elle est manifestement excessive ou dérisoire.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Quelle est la différence essentielle entre le mandataire et le commissionnaire de transport ?$mft$,
    $mft$[
      {"id":"a","label":"Le mandataire agit au nom du mandant ; le commissionnaire agit en son nom propre pour le compte du commettant","is_correct":true},
      {"id":"b","label":"Le mandataire est toujours salarié, le commissionnaire jamais","is_correct":false},
      {"id":"c","label":"Le commissionnaire ne répond jamais des transporteurs qu'il choisit","is_correct":false},
      {"id":"d","label":"Aucune : ce sont deux noms du même statut","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-a','qcm-v1'], 'CAPA-LOURD-A-QCM-07', false,
    $mft$Le commissionnaire s'engage personnellement envers son client et répond de son fait comme de celui de ses substitués ; le mandataire, transparent, engage directement le mandant.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Depuis la loi du 14 février 2022, quelle protection bénéficie de plein droit à l'entrepreneur individuel ?$mft$,
    $mft$[
      {"id":"a","label":"La séparation automatique de ses patrimoines professionnel et personnel","is_correct":true},
      {"id":"b","label":"Une exonération totale de ses dettes professionnelles","is_correct":false},
      {"id":"c","label":"L'interdiction pour les banques d'exiger une caution","is_correct":false},
      {"id":"d","label":"Un capital social minimum garanti par l'État","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-a','qcm-v1'], 'CAPA-LOURD-A-QCM-08', false,
    $mft$Le statut unique de l'entrepreneur individuel sépare de plein droit patrimoine professionnel et personnel : les créanciers professionnels n'ont en principe pour gage que les biens utiles à l'activité. La renonciation ponctuelle (au profit d'une banque) et le cautionnement restent possibles.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$L'entreprise de transport répond-elle des dommages causés aux tiers par un conducteur salarié pendant une livraison ?$mft$,
    $mft$[
      {"id":"a","label":"Oui : le commettant répond des faits de ses préposés dans l'exercice de leurs fonctions","is_correct":true},
      {"id":"b","label":"Non : chaque salarié répond seul de ses fautes","is_correct":false},
      {"id":"c","label":"Uniquement si le dirigeant était présent dans le véhicule","is_correct":false},
      {"id":"d","label":"Uniquement si la victime est un client de l'entreprise","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-a','qcm-v1'], 'CAPA-LOURD-A-QCM-09', false,
    $mft$Responsabilité du commettant du fait de ses préposés : l'employeur répond des dommages causés par le salarié dans ses fonctions. Limite : l'abus de fonctions (acte hors fonctions, sans autorisation, à des fins étrangères).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Avant de réclamer des dommages-intérêts pour retard de paiement à un débiteur, quelle formalité est en principe requise ?$mft$,
    $mft$[
      {"id":"a","label":"Déposer plainte au commissariat","is_correct":false},
      {"id":"b","label":"Adresser une mise en demeure","is_correct":true},
      {"id":"c","label":"Saisir directement la cour d'appel","is_correct":false},
      {"id":"d","label":"Faire constater l'impayé par huissier sous 48 h","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-a','qcm-v1'], 'CAPA-LOURD-A-QCM-10', false,
    $mft$La mise en demeure (lettre recommandée sommant d'exécuter) constate officiellement le manquement : elle fait courir les intérêts moratoires et conditionne, sauf exceptions, les dommages-intérêts. Entre professionnels, les pénalités de retard courent toutefois de plein droit dès l'échéance.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Une clause limitant l'indemnisation du client au prix du transport peut être écartée par le juge lorsque :$mft$,
    $mft$[
      {"id":"a","label":"Elle contredit l'obligation essentielle du contrat ou en cas de faute lourde ou dolosive","is_correct":true},
      {"id":"b","label":"Le client est un professionnel averti","is_correct":false},
      {"id":"c","label":"Le montant du litige dépasse 10 000 €","is_correct":false},
      {"id":"d","label":"Le contrat a été conclu oralement","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-a','qcm-v1'], 'CAPA-LOURD-A-QCM-11', false,
    $mft$Une clause limitative qui vide de sa substance l'obligation essentielle est réputée non écrite (jurisprudence rendue en matière de messagerie express) ; la faute lourde ou dolosive fait également échec aux limitations. Les plafonds légaux des contrats types obéissent à leur régime propre.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Le droit de rétention du voiturier permet au transporteur de :$mft$,
    $mft$[
      {"id":"a","label":"Retenir la marchandise transportée jusqu'au paiement des créances liées à ce transport","is_correct":true},
      {"id":"b","label":"Vendre immédiatement la marchandise sans formalité","is_correct":false},
      {"id":"c","label":"Retenir n'importe quel bien du débiteur, même sans lien avec le transport","is_correct":false},
      {"id":"d","label":"Suspendre le permis de conduire du débiteur","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-a','qcm-v1'], 'CAPA-LOURD-A-QCM-12', false,
    $mft$Le voiturier peut retenir la marchandise jusqu'au paiement des sommes dues au titre du transport concerné : moyen de pression légal, à manier avec discernement. Il ne confère pas un droit de vente immédiate et ne s'étend pas aux créances étrangères à l'opération.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l4, 'qr',
   $mft$Quel est le délai de prescription de droit commun en matière civile et commerciale ?$mft$,
   $mft$Cinq ans.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-a','question-courte'], 'CAPA-LOURD-A-QC-01', false,
   $mft$Art. 2224 du code civil (et L. 110-4 du code de commerce). À distinguer du délai d'un an propre au contrat de transport.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Citez les trois vices du consentement.$mft$,
   $mft$L'erreur, le dol et la violence.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-a','question-courte'], 'CAPA-LOURD-A-QC-02', false,
   $mft$Les trois vices ouvrent la nullité relative du contrat. Accepter toute formulation citant les trois termes.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Quel document officiel demande-t-on à un nouveau partenaire commercial pour vérifier l'existence juridique de sa société ?$mft$,
   $mft$Un extrait Kbis (immatriculation au registre du commerce et des sociétés), idéalement de moins de trois mois.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-a','question-courte'], 'CAPA-LOURD-A-QC-03', false,
   $mft$Accepter « Kbis ». Le réflexe complet ajoute la vérification des pouvoirs du signataire.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Dans quel délai se prescrivent les actions nées du contrat de transport (avaries, retard, paiement du prix) ?$mft$,
   $mft$Un an.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-a','question-courte'], 'CAPA-LOURD-A-QC-04', false,
   $mft$Code de commerce, art. L. 133-6. Vaut aussi bien contre le transporteur (avaries) que pour lui (impayés).$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Qu'est-ce qu'une mise en demeure et quel est son effet principal ?$mft$,
   $mft$Une sommation formelle d'exécuter (généralement par lettre recommandée) : elle constate le manquement et fait courir les dommages-intérêts et intérêts de retard.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-a','question-courte'], 'CAPA-LOURD-A-QC-05', false,
   $mft$Deux idées attendues : sommation formelle + point de départ des sanctions (intérêts, dommages-intérêts, jeu de la clause résolutoire).$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quels sont les deux ordres de responsabilité civile ?$mft$,
   $mft$La responsabilité contractuelle (entre parties à un contrat) et la responsabilité délictuelle (envers les tiers).$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-a','question-courte'], 'CAPA-LOURD-A-QC-06', false,
   $mft$Bonus si le candidat mentionne la règle du non-cumul entre les deux ordres.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Quel montant forfaitaire d'indemnité de recouvrement est dû de plein droit par facture payée en retard entre professionnels ?$mft$,
   $mft$Quarante euros (40 €) par facture.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-a','question-courte'], 'CAPA-LOURD-A-QC-07', false,
   $mft$Indemnité forfaitaire de frais de recouvrement, cumulable avec les pénalités de retard ; complément possible sur justificatifs.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Qu'est-ce qu'une clause de réserve de propriété ?$mft$,
   $mft$Une clause par laquelle le vendeur reste propriétaire du bien vendu jusqu'au paiement complet du prix.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-a','question-courte'], 'CAPA-LOURD-A-QC-08', false,
   $mft$Utile en cas d'impayé ou de procédure collective de l'acheteur : le vendeur peut revendiquer le bien.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez les trois causes d'exonération de la responsabilité civile.$mft$,
   $mft$La force majeure, le fait d'un tiers et la faute de la victime.$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-a','question-courte'], 'CAPA-LOURD-A-QC-09', false,
   $mft$Exonération totale ou partielle selon que la cause est exclusive ou concurrente du fait du responsable.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Par quels moyens le transporteur présumé responsable des avaries peut-il s'exonérer ?$mft$,
   $mft$En prouvant la force majeure, le vice propre de la marchandise ou la faute de l'expéditeur (par exemple un emballage défectueux ou une déclaration inexacte).$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-a','question-courte'], 'CAPA-LOURD-A-QC-10', false,
   $mft$Trois causes attendues ; un exemple concret est un plus. La présomption pèse sur le transporteur entre prise en charge et livraison.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l2, 'qr',
   $mft$Expliquez les trois conditions de validité d'un contrat et illustrez chacune par un exemple tiré de l'activité d'une entreprise de transport.$mft$,
   $mft$Réponse modèle. 1) Le consentement : accord libre et éclairé des parties ; exemple : un devis de transport accepté sans manœuvre trompeuse sur les délais ou le prix ; un consentement obtenu par dol (fausse promesse de volume) est vicié. 2) La capacité : les signataires doivent pouvoir s'engager ; exemple : vérifier que le signataire du contrat cadre a le pouvoir d'engager la société cliente (dirigeant ou délégataire). 3) Le contenu licite et certain : la prestation doit être déterminée ou déterminable et légale ; exemple : un contrat portant sur un transport de marchandises prohibées a un contenu illicite et encourt la nullité absolue ; un prix indexé sur le gazole selon une formule précise est un contenu certain. La réunion des trois conditions rend le contrat valable et obligatoire.$mft$,
   $mft$Barème /5 : 1 pt par condition correctement expliquée (3 pts) ; 1,5 pt pour la pertinence des trois illustrations transport ; 0,5 pt pour la sanction (nullité) en cas de défaut. Erreurs fréquentes : exiger un écrit comme condition de validité ; confondre contenu illicite (nullité absolue) et vice du consentement (nullité relative).$mft$,
   5, 'facile', ARRAY['capa-lourd','module-a','question-redigee'], 'CAPA-LOURD-A-QR-01', false,
   $mft$Restitution structurée avec application professionnelle. Référence : code civil, art. 1128.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Comparez la responsabilité contractuelle et la responsabilité délictuelle : situations couvertes, fondement, exemples dans le transport routier. Pourquoi parle-t-on de non-cumul ?$mft$,
   $mft$Réponse modèle. La responsabilité contractuelle répare le dommage causé par l'inexécution d'un contrat entre les parties : le transporteur qui livre une marchandise avariée à son client répond sur ce terrain, avec les plafonds éventuels du contrat ou du contrat type. La responsabilité délictuelle répare le dommage causé à un tiers hors de tout contrat (art. 1240 du code civil) : le piéton blessé par un colis tombé du camion agit sur ce fondement. Dans les deux cas, trois conditions : fait générateur, dommage, lien de causalité. Le non-cumul signifie que la victime liée par un contrat ne peut pas choisir le terrain délictuel pour contourner les règles contractuelles (plafonds, prescription d'un an) : le régime applicable est imposé par la situation.$mft$,
   $mft$Barème /5 : distinction claire des deux situations (1,5 pt) ; fondements cités (0,5 pt) ; deux exemples transport pertinents (1,5 pt) ; explication correcte du non-cumul et de son enjeu pratique (1,5 pt). Erreurs fréquentes : croire que la victime choisit librement son terrain ; oublier que les trois conditions valent pour les deux ordres.$mft$,
   5, 'facile', ARRAY['capa-lourd','module-a','question-redigee'], 'CAPA-LOURD-A-QR-02', false,
   $mft$Comparaison classique de l'épreuve rédigée, appliquée au transport.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas pratique. La société TransSud livre un client régulier le 5 mars N. La facture de 4 200 € reste impayée malgré des relances. Le 20 juin N+1, le dirigeant envisage enfin d'agir en justice. Que lui conseillez-vous ? Analysez les délais et proposez la marche à suivre.$mft$,
   $mft$Réponse modèle. L'action en paiement du prix d'un transport naît du contrat de transport : elle se prescrit par un an (L. 133-6 du code de commerce), en principe à compter de la livraison du 5 mars N. Le 20 juin N+1, le délai d'un an est expiré depuis la mi-mars N+1 : l'action en justice est prescrite, sauf cause d'interruption intervenue entre-temps (reconnaissance de dette écrite du débiteur, action en justice, acte d'exécution forcée ; une simple relance amiable n'interrompt pas la prescription). Conseils : vérifier l'existence d'un acte interruptif ; à défaut, tenter le recouvrement amiable (le paiement volontaire d'une dette prescrite reste valable) ; en tirer les leçons d'organisation : facturer immédiatement, relancer tôt, mettre en demeure rapidement et, au besoin, lancer une injonction de payer avant l'expiration du délai d'un an.$mft$,
   $mft$Barème /5 : identification du délai d'un an spécifique au transport (1,5 pt) ; calcul correct et conclusion de prescription acquise (1,5 pt) ; nuance sur les causes d'interruption et le paiement volontaire (1 pt) ; recommandations d'organisation crédibles (1 pt). Erreurs fréquentes : appliquer 5 ans ; croire qu'une relance simple interrompt la prescription.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-a','question-redigee'], 'CAPA-LOURD-A-QR-03', false,
   $mft$Cas de prescription, piège favori de l'examen. Référence : L. 133-6 c. com. ; art. 2240 s. c. civ. (interruption).$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Décrivez la procédure graduée de recouvrement d'une facture de transport impayée, de la relance au juge, en précisant l'intérêt de chaque étape.$mft$,
   $mft$Réponse modèle. 1) Relance amiable (appel, courriel, courrier) : préserve la relation commerciale, résout la majorité des retards. 2) Mise en demeure en recommandé avec AR : constate officiellement le manquement, fait courir les intérêts, prépare la preuve ; entre professionnels s'ajoutent de plein droit les pénalités de retard et l'indemnité forfaitaire de 40 € par facture. 3) Injonction de payer devant le tribunal compétent : procédure rapide, peu coûteuse, adaptée aux créances certaines non sérieusement contestables ; le juge rend une ordonnance exécutoire à défaut d'opposition. 4) Assignation au fond si la créance est contestée ; à l'issue, exécution forcée par commissaire de justice (saisies). En parallèle : surveiller la prescription d'un an du contrat de transport et, le cas échéant, mobiliser le droit de rétention sur les marchandises d'un transport en cours au profit de la même créance.$mft$,
   $mft$Barème /5 : les 4 étapes dans l'ordre avec leur intérêt (2,5 pts) ; mention des pénalités et de l'indemnité de 40 € (0,5 pt) ; vigilance prescription 1 an (1 pt) ; mobilisation pertinente du droit de rétention ou de l'exécution forcée (1 pt). Erreurs fréquentes : saisir directement le juge du fond pour une créance simple ; oublier la mise en demeure ; ignorer la prescription courte.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-a','question-redigee'], 'CAPA-LOURD-A-QR-04', false,
   $mft$Plan d'action opérationnel de recouvrement, transposable en entreprise.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Analyse de situations. a) Une tempête exceptionnelle, non annoncée, ferme l'autoroute 24 h et fait manquer une livraison à heure garantie. b) Le tracteur tombe en panne suite à un défaut d'entretien et la livraison échoue. Dans chaque cas, la force majeure exonère-t-elle le transporteur ?$mft$,
   $mft$Réponse modèle. Critères (art. 1218 du code civil) : événement échappant au contrôle du débiteur, raisonnablement imprévisible à la conclusion, aux effets irrésistibles. a) La tempête exceptionnelle non annoncée remplit a priori les trois critères : extérieure à l'entreprise, imprévisible, insurmontable (fermeture d'autoroute) ; la force majeure exonère le transporteur des dommages-intérêts pour retard, sous réserve d'avoir pris les mesures raisonnables (information du client, itinéraire de repli impossible). b) La panne liée à un défaut d'entretien échoue au premier critère : l'entretien du matériel relève du contrôle de l'entreprise ; l'événement n'est ni extérieur ni irrésistible (maintenance préventive, véhicule de remplacement). Pas d'exonération : la responsabilité contractuelle du transporteur est engagée. Conclusion de méthode : appliquer les trois critères un à un, sans s'arrêter au caractère « soudain » de l'événement.$mft$,
   $mft$Barème /5 : rappel des trois critères (1,5 pt) ; analyse correcte du cas a avec conclusion d'exonération (1,5 pt) ; analyse correcte du cas b avec refus motivé (1,5 pt) ; qualité de la méthode critère par critère (0,5 pt). Erreurs fréquentes : qualifier toute intempérie de force majeure sans vérifier l'imprévisibilité ; exonérer la panne au motif qu'elle est involontaire.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-a','question-redigee'], 'CAPA-LOURD-A-QR-05', false,
   $mft$Application dirigée de l'art. 1218 sur deux cas contrastés.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Votre entreprise hésite à passer par un commissionnaire de transport ou à mandater un intermédiaire pour organiser ses flux. Expliquez la différence entre les deux statuts et ses conséquences en matière de responsabilité pour votre entreprise cliente.$mft$,
   $mft$Réponse modèle. Le mandataire agit au nom et pour le compte du mandant : les contrats qu'il conclut engagent directement le client, qui devient partie aux contrats de transport et supporte les recours correspondants ; le mandataire ne répond que de ses fautes de mandat (mauvais choix manifeste, dépassement de pouvoir). Le commissionnaire agit en son nom propre pour le compte du commettant : il conclut lui-même les contrats avec les transporteurs, assume une obligation de résultat sur l'acheminement et répond à la fois de son fait personnel et du fait des transporteurs substitués ; le client dispose ainsi d'un interlocuteur unique contre lequel agir, le commissionnaire exerçant ensuite ses recours. Conséquences pratiques : la commission offre une garantie plus large (responsabilité du fait des substitués) souvent avec plafonds propres ; le mandat laisse au client la maîtrise et les risques des contrats de transport. Le choix dépend du besoin de garantie, du volume et de la capacité du client à gérer les recours.$mft$,
   $mft$Barème /5 : définition exacte des deux statuts (2 pts) ; conséquence clé : responsabilité du commissionnaire du fait des substitués vs transparence du mandat (2 pts) ; conclusion opérationnelle argumentée (1 pt). Erreurs fréquentes : faire du commissionnaire un simple courtier ; croire que le mandataire garantit l'acheminement.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-a','question-redigee'], 'CAPA-LOURD-A-QR-06', false,
   $mft$Distinction structurante pour le domaine A et passerelle vers la formation Commissionnaire.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Cas professionnel. Un entrepreneur individuel de transport lourd sollicite un prêt pour deux tracteurs. La banque exige une renonciation à la séparation des patrimoines et une caution de son conjoint. Analysez les risques patrimoniaux et conseillez l'entrepreneur.$mft$,
   $mft$Réponse modèle. Principe depuis la loi du 14 février 2022 : le patrimoine personnel de l'entrepreneur individuel est séparé de plein droit du patrimoine professionnel, gage des seuls créanciers professionnels ; la résidence principale est de surcroît insaisissable. La renonciation demandée par la banque, possible pour un engagement déterminé, ré-expose le patrimoine personnel à hauteur du prêt : risque direct sur l'épargne et les biens personnels. La caution du conjoint ajoute un second débiteur sur son patrimoine propre ; selon le régime matrimonial et le consentement donné, les biens communs peuvent également être exposés. Conseils : négocier des alternatives (gage sur les véhicules financés, nantissement, garantie d'un organisme de cautionnement professionnel, assurance emprunteur renforcée) ; limiter strictement la renonciation et la caution en montant et en durée ; mesurer l'engagement avant signature (mentions et information annuelle des cautions) ; à défaut d'alternative, envisager le passage en société pour cantonner le risque.$mft$,
   $mft$Barème /5 : rappel du principe de séparation 2022 et de l'insaisissabilité de la résidence principale (1,5 pt) ; analyse du double risque renonciation + caution du conjoint, avec la dimension biens communs (1,5 pt) ; au moins deux alternatives crédibles de garantie (1 pt) ; réflexes de limitation (montant, durée) ou évocation du passage en société (1 pt). Erreurs fréquentes : croire la protection 2022 absolue face à une renonciation signée ; ignorer l'exposition du conjoint caution.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-a','question-redigee'], 'CAPA-LOURD-A-QR-07', false,
   $mft$Cas de synthèse patrimoine/garanties orienté décision. Références : loi n° 2022-172 ; régime du cautionnement.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un contrat cadre de messagerie stipule : « L'indemnité due par le transporteur, quelle que soit la cause du dommage, ne pourra excéder le prix du transport. » Le client, qui avait payé une option « livraison garantie avant 9 h » pour des pièces bloquant une chaîne de production, subit un retard de 2 jours. Analysez la portée de cette clause.$mft$,
   $mft$Réponse modèle. Qualification : clause limitative de responsabilité, en principe valable entre professionnels. Limites : elle est écartée en cas de faute lourde ou dolosive du transporteur ; surtout, lorsqu'elle contredit la portée de l'obligation essentielle souscrite, elle est réputée non écrite : ici, l'option « garantie avant 9 h », payée spécifiquement, érige le délai en obligation essentielle ; limiter l'indemnité au seul prix du transport vide cette garantie de sa substance. Le client peut donc soutenir que la clause est réputée non écrite pour le manquement à la garantie de délai et réclamer la réparation de son préjudice prouvé (dans les conditions du droit commun et des textes applicables au transport ; les plafonds légaux des contrats types, d'origine réglementaire, obéissent à leur régime propre et ne tombent pas devant la même analyse). Méthode attendue : qualifier la clause, identifier l'obligation essentielle, confronter les deux, conclure sur l'indemnisation.$mft$,
   $mft$Barème /5 : qualification correcte de la clause (0,5 pt) ; validité de principe entre pros et exceptions faute lourde/dolosive (1 pt) ; identification de l'obligation essentielle créée par l'option payée (1,5 pt) ; conclusion motivée : clause réputée non écrite pour ce manquement (1,5 pt) ; distinction avec les plafonds réglementaires des contrats types (0,5 pt). Erreurs fréquentes : déclarer toute clause limitative nulle par principe ; confondre clause contractuelle et plafond réglementaire.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-a','question-redigee'], 'CAPA-LOURD-A-QR-08', false,
   $mft$Analyse critique inspirée de la jurisprudence messagerie sur l'obligation essentielle.$mft$);

  RAISE NOTICE 'Module A Capa lourd créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $capaa$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Volumes :
--    select "type", active, count(*) from question_bank
--     where source_ref like 'CAPA-LOURD-A-%' group by 1, 2;
--    → attendu : qcm/false = 12, qr/false = 18.
-- 2) QCM à bonne réponse unique :
--    select source_ref from question_bank
--     where source_ref like 'CAPA-LOURD-A-QCM-%'
--       and (select count(*) from jsonb_array_elements(choices) c
--             where (c->>'is_correct')::boolean) <> 1;   → 0 ligne.
-- 3) Doublons d'énoncés sur la formation :
--    select statement, count(*) from question_bank
--     where formation_id = (select id from formations where slug='capacite-plus-3-5t')
--     group by 1 having count(*) > 1;                    → 0 ligne.
