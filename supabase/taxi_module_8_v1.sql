-- =====================================================================
-- TAXI / VTC (T3P) : MODULE 8 : SPÉCIFIQUE VTC : REGISTRE, RÉSERVATION
-- ET PLATEFORMES : v1 (juillet 2026)
-- Épreuve spécifique VTC : obligations propres au régime (réservation
-- préalable, retour à la base, signalétique), relation économique aux
-- plateformes, construction d'une clientèle propre et standard de
-- service haut de gamme.
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $taxim8$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid;
  v_quiz uuid; v_q uuid; v_ord int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'taxi-vtc';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation taxi-vtc introuvable.'; END IF;

  INSERT INTO public.blocs (id, code, title, description, "order") VALUES (50, 'TAXI-VTC', 'Taxi et VTC : transport public particulier de personnes', 'Préparation aux examens taxi et VTC (T3P) organisés par les chambres de métiers et de l''artisanat : épreuves communes, spécifiques et pratique.', 50) ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'TAXI-VTC';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'TAXI-M8-%';
  DELETE FROM public.modules WHERE slug = 'vtc-specifique';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 8 : Spécifique VTC : registre, réservation et plateformes',
    'vtc-specifique', v_bloc,
    'Le régime propre au VTC : obligations du registre, réservation préalable et retour à la base, signalétique, relation aux plateformes et développement d''une clientèle propre.',
    'avance', 240, 80) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 80, true);

  -- ─── Leçon 1 : Les obligations propres au VTC ───────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'obligations-vtc',
    'Les obligations propres au VTC : réservation préalable et retour à la base',
    $mft$> 🎯 **Objectifs**
> - Situer le régime VTC dans le T3P : tout repose sur la réservation préalable.
> - Appliquer sans faute la règle du retour à la base entre deux courses.
> - Passer un contrôle sereinement : justificatif, horodatage, signalétique.

## Un métier construit sur la réservation préalable

Le VTC (voiture de transport avec chauffeur) appartient, comme le taxi, au transport public particulier de personnes (T3P). Mais son régime repose sur un principe unique qui commande TOUTES ses obligations : le VTC ne transporte que des clients qui ont réservé À L'AVANCE. Pas de station réservée, pas de client hélé dans la rue, pas de compteur : la course naît d'une réservation enregistrée avant la prise en charge, et tout le reste en découle. L'exploitant est inscrit au registre des VTC (inscription à renouveler périodiquement : la périodicité et les modalités exactes sont à vérifier dans les textes en vigueur au moment de votre examen), et le véhicule porte une signalétique dédiée : une vignette (macaron) apposée sur le véhicule, qui identifie l'activité VTC lors des contrôles (les modalités précises d'apposition sont également à vérifier dans les textes en vigueur).

> 📌 **À retenir**
> Retenez la logique plutôt que la liste : tout ce qui ressemble à de la maraude (chercher ou capter le client dans la rue) est interdit au VTC ; tout ce qui découle d'une réservation antérieure et prouvable constitue sa zone de travail.

## Le justificatif de réservation : votre pièce maîtresse en contrôle

En contrôle, vous devez présenter un justificatif de réservation préalable, sur support papier ou numérique : l'écran de l'application ou le mail de confirmation suffisent s'ils affichent les informations de la course. Le point que l'agent vérifie en premier : l'heure de la réservation doit être ANTÉRIEURE à l'heure de la prise en charge. C'est l'horodatage qui fait la preuve, pas la bonne foi.

> ⚠️ **Attention**
> Une réservation enregistrée à 14 h 32 pour une prise en charge à 14 h 30 ne justifie rien : elle démontre au contraire que le client était déjà là avant de réserver, donc une prise en charge assimilable à de la maraude. Faites toujours enregistrer la course AVANT d'ouvrir la portière.

## Entre deux courses : la règle du retour à la base

L'interdiction est absolue : pas de maraude, et pas de stationnement en attente de clientèle sur la voie publique. Entre deux courses, le VTC retourne à sa base (ou à un lieu de stationnement hors de la chaussée), sauf s'il peut justifier d'une réservation suivante, ou s'il stationne dans un parking autorisé.

:::flow
1. Fin de course | Le client est déposé, la course est terminée
2. Réservation suivante ? | Si une réservation justifiable est déjà enregistrée : route directe vers la prochaine prise en charge
3. Pas de réservation | Retour à la base ou à un lieu de stationnement hors de la chaussée
4. Alternative | Stationnement dans un parking autorisé en attendant la réservation suivante
:::

| Situation entre deux courses | Conforme ? |
| --- | --- |
| Réservation suivante enregistrée, en route vers la prise en charge | ✅ Oui : la réservation est justifiable |
| Stationné dans un parking public, application ouverte | ✅ Oui : hors chaussée, dans un parking autorisé |
| Arrêté le long du trottoir devant un hôtel « au cas où » | ❌ Non : attente de clientèle sur la voie publique |
| Tours lents autour de la gare en attendant qu'une course tombe | ❌ Non : c'est de la maraude |

## Aéroports et gares : dépose libre, reprise encadrée

Les zones aéroportuaires et les gares concentrent les contrôles, car la tentation y est maximale. La règle est simple : la dépose est libre (vous déposez votre client comme n'importe quel véhicule), mais la reprise n'est possible QUE sur réservation préalable, justificatif à l'appui. Après une dépose, il est interdit de rester dans la zone en espérant qu'une course tombe : vous repartez, ou vous stationnez dans un parking (souvent payant) en attendant l'heure d'une prise en charge déjà réservée.

> 💡 **Astuce**
> Beaucoup de chauffeurs intègrent le coût du parking aéroport dans leur devis de transfert : le client paie quelques euros de plus, et vous attendez sereinement, en règle, dans la zone prévue, au lieu de tourner en risquant le contrôle.

## ✅ Synthèse

- Le VTC ne travaille QUE sur réservation préalable : justificatif papier ou numérique présentable en contrôle, heure de réservation ANTÉRIEURE à la prise en charge.
- Entre deux courses : retour à la base ou lieu hors chaussée, sauf réservation suivante justifiable ou stationnement dans un parking autorisé.
- Signalétique : vignette (macaron) sur le véhicule ; inscription au registre des VTC à jour (modalités à vérifier dans les textes en vigueur).
- Aéroports et gares : dépose libre, reprise uniquement sur réservation avec justificatif.$mft$,
    $mft$La réservation préalable comme socle du régime VTC : justificatif horodaté présentable en contrôle, interdiction de maraude et règle du retour à la base entre deux courses, dépose libre mais reprise sur réservation en aéroport et en gare.$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Plateformes et indépendance ──────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'plateformes-et-independance',
    'Plateformes : travailler avec, sans en dépendre',
    $mft$> 🎯 **Objectifs**
> - Comprendre le modèle économique des plateformes : commission, tarification, données.
> - Mesurer et limiter le risque de dépendance économique.
> - Construire une clientèle propre : hôtels, entreprises, conciergeries, événements.

## Ce que la plateforme apporte, ce qu'elle retient

La plateforme de mise en relation apporte au chauffeur ce qui coûte le plus cher à obtenir seul : un flux de clients immédiat, sans prospection. En échange, elle prélève une commission sur chaque course et fixe elle-même le prix payé par le client : le chauffeur ne négocie pas le tarif, sa liberté se limite à accepter ou refuser les courses proposées. La plateforme détient aussi ce qui fait la valeur d'un fonds de commerce : la relation client, l'historique des courses, les données et la notation du chauffeur. Une désactivation de compte fait disparaître tout cela du jour au lendemain.

| Question | Course plateforme | Course clientèle propre |
| --- | --- | --- |
| Qui fixe le prix ? | La plateforme (imposé au client) | Vous, au devis |
| Qui détient le client et ses données ? | La plateforme | Vous |
| Commission ? | Oui, sur chaque course | Aucune |
| Que reste-t-il si la relation s'arrête ? | Rien : compte désactivé, tout disparaît | Le client, le contrat, l'historique |

## Les règles du jeu financier

Premier réflexe de gestion : raisonner en chiffre d'affaires, jamais en « ce qui arrive sur le compte ». En micro-entreprise, les cotisations sociales se calculent sur le chiffre d'affaires réalisé via la plateforme, commission comprise : la commission n'est pas déduite de la base de calcul dans ce régime. Le chauffeur qui raisonne sur le net reçu après commission sous-estime ses prélèvements et peut, sans le voir, accepter des courses à perte une fois le carburant, l'usure du véhicule et les cotisations comptés.

> ❌ **Piège à éviter**
> « J'ai reçu 3 000 €, je cotise sur 3 000 €. » Faux en micro-entreprise si la plateforme a facturé 4 000 € au client et gardé sa commission : la base de calcul, c'est le chiffre d'affaires, pas le virement. Ce point change complètement la rentabilité réelle d'une course.

## La dépendance économique : un risque qui se pilote

Travailler à 100 % pour une seule application, c'est confier son revenu à un algorithme et à des conditions que l'on ne négocie pas : baisse unilatérale des tarifs, modification des règles d'attribution, désactivation du compte. Le VTC indépendant peut cumuler plusieurs plateformes : c'est une première protection (comparer les conditions, basculer le volume vers la mieux-disante), mais elle ne suffit pas : toutes prélèvent une commission et toutes gardent la relation client.

> 🔍 **Zoom**
> Le dialogue social entre plateformes et travailleurs indépendants s'est structuré ces dernières années : une autorité dédiée (l'ARPE) organise la représentation des chauffeurs, et des accords de secteur ont vu le jour. Ce cadre évolue régulièrement : vérifiez l'état du droit au moment de votre examen et de votre installation.

## La clientèle propre : la vraie marge est là

Le chauffeur qui veut durer construit, en parallèle des plateformes, une clientèle qui lui appartient : hôtels (transferts de leurs clients), entreprises (déplacements de collaborateurs et de visiteurs), conciergeries (clientèle exigeante et récurrente), événements (salons, mariages, congrès). Sur ces courses : pas de commission, prix fixé par vous au devis, relation directe, fidélisation possible.

La méthode est commerciale : se présenter (carte, page professionnelle), proposer un devis clair, formaliser un contrat ou des conditions écrites avec les comptes réguliers (entreprise facturée au mois, hôtel avec grille de transferts), et fidéliser par la constance : ponctualité, véhicule impeccable, discrétion. La plateforme devient alors un COMPLÉMENT qui remplit les creux, et non plus la source unique de revenu.

> 🎓 **Pour l'examen**
> Retenez le triptyque : commission et prix imposés côté plateforme, liberté d'accepter ou de refuser les courses côté chauffeur, et clientèle propre comme levier principal de marge et d'indépendance.

## ✅ Synthèse

- La plateforme fixe le prix client et prélève une commission ; le chauffeur reste libre d'accepter ou de refuser les courses.
- Cotisations calculées sur le chiffre d'affaires réalisé via la plateforme (commission comprise en micro-entreprise) : raisonner en CA, jamais en net reçu.
- Dépendance économique : cumuler les plateformes, suivre ses chiffres, et surtout construire une clientèle propre (hôtels, entreprises, conciergeries, événements) : la vraie marge est là.
- Cadre du dialogue social des plateformes (ARPE, accords) : en évolution, à vérifier au moment de l'examen.$mft$,
    $mft$Le modèle économique des plateformes (commission, prix imposé au client, données et notation), la liberté du chauffeur d'accepter ou refuser, le calcul des cotisations sur le CA, le risque de dépendance et la construction d'une clientèle propre où se trouve la vraie marge.$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Gamme et service VTC ─────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'gamme-et-service-vtc',
    'Gamme, devis et service : la prestation VTC qui fidélise',
    $mft$> 🎯 **Objectifs**
> - Choisir un positionnement de gamme cohérent : berline affaires, van, éco.
> - Construire un devis et une confirmation écrite qui protègent les deux parties.
> - Gérer les attentes aéroport, les no-show et les acomptes sans conflit.

## Choisir sa gamme : un positionnement, pas une collection

| Positionnement | Clientèle visée | Ce qui est attendu |
| --- | --- | --- |
| Berline affaires | Cadres, directions, clientèle hôtelière | Discrétion, ponctualité absolue, confort, tenue soignée |
| Van (groupes et familles) | Familles, groupes, transferts aéroport, événements | Volume bagages, organisation, patience |
| Éco / compacte | Clientèle sensible au prix, trajets urbains | Prix serré, propreté irréprochable malgré le tarif |

Le positionnement commande tout : le véhicule, la tenue, le tarif, le discours commercial. Vouloir servir toutes les clientèles avec le même véhicule et le même tarif, c'est n'être la référence de personne.

## Le standard de prestation qui fait revenir

La prestation attendue d'un VTC se joue dans les détails, répétés à chaque course : véhicule impeccable (intérieur ET extérieur), bouteilles d'eau à disposition, chargeurs pour les principaux téléphones, aide systématique aux bagages, discrétion (on converse si le client engage la conversation, on respecte son silence sinon, et jamais de commentaire sur d'autres clients), conduite souple et climatisation réglée.

> 💡 **Astuce**
> Le haut de gamme ne se proclame pas, il se répète : c'est la CONSTANCE de la prestation (même niveau à la dixième course qu'à la première) qui transforme un client satisfait en client fidèle, puis en prescripteur.

## Devis et confirmation écrite : le prix ferme qui rassure

La force commerciale du VTC : un prix ferme, annoncé AVANT la course. Les bonnes pratiques du devis : le trajet précis (adresses de prise en charge et de destination), la durée estimée, le prix ferme TTC, et les conditions d'annulation (complétées, pour les transferts, des conditions d'attente et de no-show). Puis une confirmation ÉCRITE (mail, SMS, messagerie) reprenant ces éléments : c'est elle qui protège en cas de contestation.

:::flow
1. Demande | Le client décrit son besoin : date, heure, trajet, passagers, bagages
2. Devis | Trajet, durée estimée, prix ferme TTC, conditions d'annulation et d'attente
3. Confirmation écrite | Le client accepte par écrit ; acompte éventuel encaissé
4. Veille | La veille et le jour J : trafic vérifié, vol suivi en temps réel
5. Prise en charge | Ponctualité, accueil nominatif, aide aux bagages
6. Facturation | Prix confirmé, facture envoyée, message de remerciement
:::

## Aéroport : suivi des vols, franchise d'attente, facturation

Un transfert aéroport se gère avec méthode : suivre le vol en temps réel (l'heure d'atterrissage RÉELLE fait foi, pas l'heure théorique), prévoir une franchise d'attente clairement annoncée au devis (par exemple un délai en minutes après l'atterrissage, pour laisser passer bagages et contrôles), et facturer l'attente au-delà de la franchise selon les conditions écrites. Le client prévenu à l'avance ne conteste pas ; le client qui découvre un supplément le conteste toujours.

## No-show et acomptes : se protéger sans se fâcher

Le no-show (client absent au rendez-vous et injoignable) est le risque commercial numéro un du VTC sur réservation : le créneau est perdu, le déplacement est fait. La protection tient en deux outils annoncés dès le devis : des conditions d'annulation écrites (délai au-delà duquel la course est due en tout ou partie) et un acompte encaissé à la confirmation pour les courses à enjeu (transferts très matinaux, longues distances, événements). Sans conditions écrites acceptées à l'avance, la facturation d'un no-show ou d'une attente sera difficile à défendre.

> ⚠️ **Attention**
> Les conditions se rédigent AVANT, jamais après : un supplément inventé au moment du litige détruit la confiance et la réputation en ligne. Tout ce qui peut se produire (retard de vol, attente, annulation tardive, no-show) doit avoir sa règle écrite dans le devis.

## Se différencier : face au taxi, face aux autres VTC

Face au taxi : le prix ferme annoncé à l'avance (quand le taxi facture au compteur), la prestation standardisée haut de gamme et la confirmation écrite. Face aux autres VTC : la constance, la ponctualité, la personnalisation (client reconnu, préférences mémorisées : température, silence, itinéraire) et le professionnalisme des documents (devis, factures, conditions claires). La différence ne se joue pas sur le prix le plus bas : elle se joue sur la confiance.

## ✅ Synthèse

- Un positionnement clair (berline affaires, van, éco) commande véhicule, tarif et discours.
- Prestation : véhicule impeccable, eau, chargeurs, aide bagages, discrétion : et surtout la constance.
- Devis : trajet, durée estimée, prix ferme TTC, conditions d'annulation ; confirmation écrite systématique.
- Aéroport : suivi du vol, franchise d'attente annoncée, facturation au-delà selon conditions écrites ; no-show et acomptes prévus dès le devis.$mft$,
    $mft$Le positionnement de gamme (berline affaires, van, éco), le standard de prestation (véhicule impeccable, eau, chargeurs, discrétion), le devis à prix ferme TTC avec confirmation écrite, la gestion des attentes aéroport (suivi de vol, franchise) et des no-show (conditions écrites, acomptes).$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Spécifique VTC',
    'Vérifiez le module 8 : réservation préalable et retour à la base, relation aux plateformes, devis et service haut de gamme.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un agent vous contrôle devant la gare alors qu'un client monte à bord de votre VTC. Que devez-vous pouvoir présenter pour justifier cette prise en charge ?$mft$,
    $mft$[
      {"id":"a","label":"Un justificatif de réservation préalable, sur papier ou sur écran, dont l'heure est antérieure à la prise en charge","is_correct":true},
      {"id":"b","label":"La carte grise et l'attestation d'assurance suffisent","is_correct":false},
      {"id":"c","label":"Le ticket imprimé d'un compteur horokilométrique","is_correct":false},
      {"id":"d","label":"Une autorisation de stationnement délivrée par la mairie","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-8','qcm-v1'], 'TAXI-M8-QCM-01', false,
    $mft$Le VTC ne travaille que sur réservation préalable prouvable, sur support papier ou numérique. Le compteur et l'autorisation de stationnement relèvent du régime taxi ; les documents du véhicule ne justifient pas la course.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Vous venez de déposer un client au terminal d'un aéroport. Un voyageur s'approche et vous propose de payer en espèces pour rejoindre le centre-ville. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous refusez : sans réservation préalable enregistrée, cette prise en charge serait de la maraude, interdite au VTC","is_correct":true},
      {"id":"b","label":"Vous acceptez : le paiement en espèces est autorisé","is_correct":false},
      {"id":"c","label":"Vous acceptez si le trajet est court","is_correct":false},
      {"id":"d","label":"Vous acceptez à condition de lui accorder une remise","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-8','qcm-v1'], 'TAXI-M8-QCM-02', false,
    $mft$Le problème n'est ni le mode de paiement ni la distance : c'est l'absence de réservation antérieure à la prise en charge. En zone aéroportuaire, la reprise sans réservation est particulièrement contrôlée.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Sur une course apportée par une plateforme de mise en relation, qui fixe le prix payé par le client, et quelle liberté reste-t-il au chauffeur ?$mft$,
    $mft$[
      {"id":"a","label":"La plateforme fixe le prix ; la liberté du chauffeur est d'accepter ou de refuser les courses proposées","is_correct":true},
      {"id":"b","label":"Le chauffeur fixe librement le prix de chaque course proposée par l'application","is_correct":false},
      {"id":"c","label":"Le client fixe le prix en enchérissant entre plusieurs chauffeurs","is_correct":false},
      {"id":"d","label":"Le prix est fixé par la chambre de métiers et de l'artisanat","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-8','qcm-v1'], 'TAXI-M8-QCM-03', false,
    $mft$La tarification est imposée par la plateforme au client ; le chauffeur ne négocie pas ce prix, mais il reste libre d'accepter ou de refuser chaque course. La chambre de métiers organise l'examen, elle ne fixe aucun tarif.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un client d'hôtel vous demande un devis pour un transfert vers l'aéroport. Quelles mentions font un devis conforme aux bonnes pratiques du VTC ?$mft$,
    $mft$[
      {"id":"a","label":"Le trajet, la durée estimée, le prix ferme TTC et les conditions d'annulation","is_correct":true},
      {"id":"b","label":"Un prix indicatif qui sera ajusté au compteur à l'arrivée","is_correct":false},
      {"id":"c","label":"Le prix hors taxes uniquement, les conditions se discutant le jour J","is_correct":false},
      {"id":"d","label":"La marque du véhicule et le prix, rien d'autre","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-8','qcm-v1'], 'TAXI-M8-QCM-04', false,
    $mft$Le devis VTC annonce un prix ferme TTC avec le trajet, la durée estimée et les conditions d'annulation. Le prix « ajusté au compteur » est le modèle du taxi, et un prix hors taxes ou sans conditions ouvre la porte aux litiges.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Il est 15 h, votre prochaine réservation est à 16 h 15 à l'autre bout de la ville. Aucune course intermédiaire n'est enregistrée. Où attendez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"À votre base ou dans un parking autorisé : pas d'attente de clientèle sur la voie publique","is_correct":true},
      {"id":"b","label":"Le long du trottoir devant les hôtels, l'application ouverte","is_correct":false},
      {"id":"c","label":"En roulant lentement autour de la gare pour rester disponible","is_correct":false},
      {"id":"d","label":"Sur une station de taxis inoccupée, puisqu'elle est vide","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-8','qcm-v1'], 'TAXI-M8-QCM-05', false,
    $mft$Entre deux courses, la règle est le retour à la base ou le stationnement hors chaussée (parking autorisé). Attendre en voirie devant les hôtels, tourner autour de la gare ou occuper une station de taxis expose au grief de maraude.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$En contrôle, votre application affiche : réservation enregistrée à 9 h 41, prise en charge du client à 9 h 38. Quelle est la situation ?$mft$,
    $mft$[
      {"id":"a","label":"Le justificatif ne couvre pas la course : la réservation doit être antérieure à la prise en charge, la situation est assimilable à une prise en charge sans réservation","is_correct":true},
      {"id":"b","label":"Trois minutes d'écart sont tolérées, tout est en règle","is_correct":false},
      {"id":"c","label":"Peu importe l'ordre des heures, seul compte le paiement par l'application","is_correct":false},
      {"id":"d","label":"Il suffit de modifier l'heure de réservation devant l'agent","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-8','qcm-v1'], 'TAXI-M8-QCM-06', false,
    $mft$C'est l'horodatage qui prouve la réservation préalable : une réservation postérieure démontre l'inverse. Aucune tolérance de principe n'existe, et falsifier le justificatif devant l'agent aggraverait la situation.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un chauffeur réalise la totalité de son activité via une seule application. Son compte est désactivé du jour au lendemain. Qu'illustre cette situation et quelle en est la parade ?$mft$,
    $mft$[
      {"id":"a","label":"La dépendance économique envers une plateforme ; la parade : cumuler plusieurs plateformes et développer une clientèle propre","is_correct":true},
      {"id":"b","label":"Un simple problème technique ; il suffit d'attendre la réactivation","is_correct":false},
      {"id":"c","label":"L'interdiction du cumul de plateformes ; il aurait dû signer une exclusivité","is_correct":false},
      {"id":"d","label":"Un risque couvert par l'assurance du véhicule","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-8','qcm-v1'], 'TAXI-M8-QCM-07', false,
    $mft$Mono-plateforme = revenu suspendu à une décision unilatérale : c'est la définition de la dépendance économique. Le cumul de plateformes est possible, et la clientèle propre est la protection durable ; aucune assurance véhicule ne couvre ce risque commercial.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Vous attendez un client à l'aéroport ; son vol atterrit avec 50 minutes de retard. Votre devis prévoyait une franchise d'attente après l'atterrissage. Quelle gestion est correcte ?$mft$,
    $mft$[
      {"id":"a","label":"Suivre l'heure d'atterrissage réelle, décompter la franchise à partir de celle-ci et facturer l'attente au-delà selon les conditions écrites du devis","is_correct":true},
      {"id":"b","label":"Repartir au bout de quinze minutes et déclarer un no-show","is_correct":false},
      {"id":"c","label":"Facturer un supplément décidé sur le moment, annoncé au client à son arrivée","is_correct":false},
      {"id":"d","label":"Décompter l'attente depuis l'heure théorique du vol, quoi qu'il arrive","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-8','qcm-v1'], 'TAXI-M8-QCM-08', false,
    $mft$Le suivi du vol fait démarrer la prestation à l'atterrissage réel ; la franchise puis la facturation suivent les conditions annoncées à l'avance. Un supplément improvisé ou un départ prématuré sont indéfendables et détruisent la relation.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$En micro-entreprise, une plateforme a facturé 4 000 € de courses à vos clients ce mois-ci et vous a reversé 3 000 € après commission. Sur quelle base vos cotisations sociales se calculent-elles ?$mft$,
    $mft$[
      {"id":"a","label":"Sur les 4 000 € de chiffre d'affaires réalisés via la plateforme : la commission n'est pas déduite de la base dans ce régime","is_correct":true},
      {"id":"b","label":"Sur les 3 000 € effectivement reçus","is_correct":false},
      {"id":"c","label":"Sur les 1 000 € de commission","is_correct":false},
      {"id":"d","label":"Sur le bénéfice restant après carburant et entretien","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-8','qcm-v1'], 'TAXI-M8-QCM-09', false,
    $mft$En micro-entreprise, la base des cotisations est le chiffre d'affaires, commission comprise. Raisonner sur le net reçu ou sur un « bénéfice » après charges conduit à sous-estimer les prélèvements et à accepter des courses à perte.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Après une dépose en gare, vous restez stationné sur la dépose-minute, application ouverte, « au cas où » une réservation tombe dans les minutes qui viennent. Un agent vous contrôle. Votre situation est-elle défendable ?$mft$,
    $mft$[
      {"id":"a","label":"Non : sans réservation déjà enregistrée, c'est une attente de clientèle sur la voie publique, interdite ; il fallait repartir ou rejoindre un parking autorisé","is_correct":true},
      {"id":"b","label":"Oui : l'application ouverte vaut réservation en cours","is_correct":false},
      {"id":"c","label":"Oui : la dépose-minute autorise toute attente de moins de dix minutes","is_correct":false},
      {"id":"d","label":"Oui : vous venez de déposer un client, vous êtes donc en service","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-8','qcm-v1'], 'TAXI-M8-QCM-10', false,
    $mft$L'espoir d'une réservation n'est pas une réservation : seule une course déjà enregistrée et justifiable autorise l'attente en vue d'une prise en charge. La dépose est libre ; la reprise et l'attente ne le sont pas.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Trois chauffeurs organisent leur activité : A travaille en exclusivité avec une plateforme contre un bonus ; B cumule trois plateformes sans clientèle directe ; C cumule deux plateformes et développe hôtels et entreprises en direct. Qui protège le mieux sa marge et son indépendance à long terme ?$mft$,
    $mft$[
      {"id":"a","label":"C : le multi-plateformes limite la dépendance, et la clientèle propre, sans commission et au prix fixé par le chauffeur, porte la vraie marge","is_correct":true},
      {"id":"b","label":"A : le bonus d'exclusivité compense largement la dépendance","is_correct":false},
      {"id":"c","label":"B : trois plateformes suffisent, la prospection directe est une perte de temps","is_correct":false},
      {"id":"d","label":"Aucun : la marge d'un VTC ne dépend pas de son organisation commerciale","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-8','qcm-v1'], 'TAXI-M8-QCM-11', false,
    $mft$B réduit le risque de désactivation mais reste commissionné sur 100 % de son activité ; A cumule dépendance et prix imposés. C combine les deux protections : diversification des sources ET courses en direct où il fixe ses prix.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Réservation à 5 h 30 pour un transfert aéroport : devis accepté par écrit, acompte encaissé, conditions de no-show prévues. À 5 h 50, le client ne répond ni à la porte ni au téléphone. Que pouvez-vous faire ?$mft$,
    $mft$[
      {"id":"a","label":"Constater le no-show (appels et messages tracés) et appliquer les conditions écrites acceptées au devis, notamment sur l'acompte","is_correct":true},
      {"id":"b","label":"Facturer le double du prix pour compenser le préjudice","is_correct":false},
      {"id":"c","label":"Rien : un no-show ne peut jamais donner lieu à facturation","is_correct":false},
      {"id":"d","label":"Rester devant le domicile jusqu'à ce que le client apparaisse","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-8','qcm-v1'], 'TAXI-M8-QCM-12', false,
    $mft$Les conditions écrites acceptées à l'avance rendent la retenue défendable ; sans elles, la facturation serait fragile. Improviser une pénalité supérieure au devis ou attendre indéfiniment n'est ni défendable ni professionnel.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$En contrôle, quel document justifie votre prise en charge d'un client en VTC, et sous quelles formes peut-il être présenté ?$mft$,
   $mft$Le justificatif de réservation préalable, présentable sur support papier ou numérique (écran de l'application, mail de confirmation), avec une heure de réservation antérieure à la prise en charge.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-8','question-courte'], 'TAXI-M8-QC-01', false,
   $mft$Justificatif de réservation + les deux supports admis.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez trois mentions d'un devis VTC conforme aux bonnes pratiques.$mft$,
   $mft$Par exemple : le trajet, la durée estimée, le prix ferme TTC, les conditions d'annulation (et les conditions d'attente pour un transfert).$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-8','question-courte'], 'TAXI-M8-QC-02', false,
   $mft$Trois mentions distinctes attendues.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Citez trois types de clients à démarcher pour construire une clientèle propre, hors plateformes.$mft$,
   $mft$Par exemple : les hôtels, les entreprises, les conciergeries, les organisateurs d'événements (salons, mariages, congrès).$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-8','question-courte'], 'TAXI-M8-QC-03', false,
   $mft$Trois cibles distinctes.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Votre course se termine et aucune réservation suivante n'est enregistrée. Quelles sont vos deux options de stationnement conformes ?$mft$,
   $mft$Retourner à la base (ou à un lieu de stationnement hors de la chaussée) ou stationner dans un parking autorisé en attendant la réservation suivante.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-8','question-courte'], 'TAXI-M8-QC-04', false,
   $mft$Retour à la base + parking autorisé.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$En zone aéroportuaire, qu'est-ce qui est libre pour un VTC et qu'est-ce qui est conditionné ?$mft$,
   $mft$La dépose d'un client est libre ; la reprise n'est possible que sur réservation préalable, avec justificatif présentable en contrôle.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-8','question-courte'], 'TAXI-M8-QC-05', false,
   $mft$Dépose libre, reprise sur réservation justifiable.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Pourquoi dit-on que « la vraie marge » du VTC se trouve dans la clientèle propre ?$mft$,
   $mft$Parce que sur ces courses il n'y a pas de commission de plateforme, que le chauffeur fixe lui-même son prix au devis et qu'il détient la relation client, qu'il peut fidéliser (contrats, facturation régulière).$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-8','question-courte'], 'TAXI-M8-QC-06', false,
   $mft$Pas de commission + prix libre + relation détenue.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un transfert aéroport avec un vol susceptible de retard : citez deux bonnes pratiques de gestion de l'attente.$mft$,
   $mft$Suivre le vol en temps réel (l'heure d'atterrissage réelle fait foi) et annoncer au devis une franchise d'attente, avec facturation au-delà selon les conditions écrites.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-8','question-courte'], 'TAXI-M8-QC-07', false,
   $mft$Suivi du vol + franchise annoncée à l'avance.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$En micro-entreprise, un chauffeur calcule ses cotisations sur les virements reçus des plateformes, après commission. Quelle erreur commet-il ?$mft$,
   $mft$Les cotisations se calculent sur le chiffre d'affaires réalisé via la plateforme, commission comprise : en raisonnant sur le net reçu, il sous-estime ses prélèvements et sa rentabilité réelle.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-8','question-courte'], 'TAXI-M8-QC-08', false,
   $mft$Base = chiffre d'affaires, pas le net reçu.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$En contrôle, l'horodatage montre une réservation enregistrée APRÈS la prise en charge du client. Quelle est la conséquence ?$mft$,
   $mft$Le justificatif ne prouve pas de réservation préalable : la course est assimilable à une prise en charge sans réservation (maraude), interdite au VTC, ce qui expose le chauffeur à des sanctions.$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-8','question-courte'], 'TAXI-M8-QC-09', false,
   $mft$Réservation postérieure = pas de réservation préalable.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un client d'affaires hésite entre vous et un taxi pour ses transferts réguliers. Citez trois arguments de différenciation propres au VTC.$mft$,
   $mft$Par exemple : le prix ferme TTC connu avant la course (contre une facturation au compteur), la prestation standardisée haut de gamme (véhicule impeccable, eau, chargeurs, discrétion), la confirmation écrite avec conditions claires (annulation, attente), la personnalisation d'un service régulier.$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-8','question-courte'], 'TAXI-M8-QC-10', false,
   $mft$Trois arguments distincts, orientés prix ferme et service.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ─────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Expliquez la règle du retour à la base : ce qu'elle interdit, ce qu'elle impose entre deux courses, et ses deux aménagements. Illustrez avec une journée type d'un chauffeur VTC en ville.$mft$,
   $mft$Réponse modèle. Ce que la règle interdit : la maraude (chercher ou attendre le client dans la rue) et le stationnement en attente de clientèle sur la voie publique : le VTC ne capte jamais un client qui n'a pas réservé. Ce qu'elle impose : entre deux courses, le chauffeur retourne à sa base ou à un lieu de stationnement hors de la chaussée. Deux aménagements : il peut rester en circulation s'il justifie d'une réservation suivante (course enregistrée, justificatif à l'appui), et il peut stationner dans un parking autorisé en attendant la prochaine course. Journée type : 8 h, transfert réservé la veille vers l'aéroport ; la réservation de 10 h 30 étant déjà enregistrée, le chauffeur roule directement vers cette prise en charge (réservation justifiable) ; à midi, aucune course : il stationne dans un parking public, application ouverte ; à 15 h, dépose en gare : interdiction de rester sur la dépose-minute « au cas où » : il repart vers sa base ; à 18 h, une réservation tombe pendant qu'il est au parking : il part la réaliser. Chaque déplacement de la journée se rattache soit à une réservation prouvable, soit à un retour vers la base ou un parking.$mft$,
   $mft$Barème /5 : interdictions exactes (maraude, attente de clientèle en voirie) (1,5 pt) ; obligation de retour à la base ou lieu hors chaussée (1 pt) ; les deux aménagements : réservation suivante justifiable et parking autorisé (1,5 pt) ; illustration cohérente sur une journée (1 pt). Erreurs fréquentes : croire que l'application ouverte vaut réservation ; confondre parking autorisé et stationnement en voirie.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-8','question-redigee'], 'TAXI-M8-QR-01', false,
   $mft$La règle centrale du régime VTC, expliquée et illustrée.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Décrivez, étape par étape, la procédure complète d'un transfert aéroport réussi : de la demande du client à la facturation, en intégrant la gestion d'un vol retardé.$mft$,
   $mft$Réponse modèle. 1) Demande : recueillir la date, le numéro de vol, le terminal, le nombre de passagers et de bagages. 2) Devis : trajet précis, durée estimée, prix ferme TTC, conditions d'annulation, franchise d'attente après l'atterrissage et tarif de l'attente au-delà. 3) Confirmation écrite (mail, SMS) reprenant tous ces éléments, avec acompte éventuel encaissé pour les courses à enjeu (très matinales, longue distance). 4) Veille : vérifier le trafic et commencer le suivi du vol. 5) Jour J : suivre l'heure d'atterrissage RÉELLE (elle fait foi, pas l'heure théorique), se positionner en conséquence, message au client à l'atterrissage, accueil nominatif, aide aux bagages, eau et chargeurs à bord. 6) Vol retardé : pas de panique ni de supplément improvisé : la franchise d'attente se décompte à partir de l'atterrissage réel, et l'attente au-delà se facture selon les conditions écrites du devis ; le client, prévenu dès le devis, ne conteste pas. 7) Facturation : prix confirmé (plus l'éventuelle attente prévue), facture envoyée rapidement, message de remerciement. La qualité de ce déroulé, répété avec constance, transforme un transfert en client régulier.$mft$,
   $mft$Barème /5 : devis complet (trajet, durée, prix ferme TTC, conditions) (1,5 pt) ; confirmation écrite et acompte éventuel (1 pt) ; suivi du vol et gestion du retard par la franchise annoncée (1,5 pt) ; prise en charge et facturation professionnelles (1 pt). Erreurs fréquentes : décompter l'attente depuis l'heure théorique du vol ; improviser un supplément non prévu au devis.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-8','question-redigee'], 'TAXI-M8-QR-02', false,
   $mft$La procédure du transfert aéroport, du devis à la facture.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Contrôle devant une grande gare : vous venez de faire monter un client. Détaillez ce que l'agent va vérifier, ce qui rend votre situation régulière, et trois erreurs qui la rendraient irrégulière.$mft$,
   $mft$Réponse modèle. Ce que l'agent vérifie : d'abord le justificatif de réservation préalable, présentable sur support papier ou numérique (écran de l'application, mail de confirmation) ; ensuite l'horodatage : l'heure de réservation doit être antérieure à l'heure de prise en charge ; enfin la signalétique du véhicule, la vignette (macaron) qui identifie l'activité VTC (ses modalités précises d'apposition sont à vérifier dans les textes en vigueur), et la cohérence de la course (client, trajet). Situation régulière : la réservation a été enregistrée avant l'arrivée du client à la voiture, le justificatif s'affiche immédiatement, la vignette est en place : en gare, la reprise sur réservation justifiée est parfaitement licite. Trois erreurs qui rendraient la situation irrégulière : 1) une réservation enregistrée après la prise en charge (ou saisie devant l'agent) : elle prouve la maraude au lieu de l'écarter ; 2) avoir attendu le client en stationnement sur la voie publique (dépose-minute, trottoir) sans réservation préalablement enregistrée : attente de clientèle interdite ; 3) l'absence de justificatif présentable ou de signalétique sur le véhicule. La règle qui résume tout : en gare comme à l'aéroport, la dépose est libre, la reprise se prouve.$mft$,
   $mft$Barème /5 : points de contrôle exacts (justificatif, horodatage, signalétique) (2 pts) ; conditions de régularité (réservation antérieure prouvable, reprise licite en gare) (1,5 pt) ; trois irrégularités pertinentes (1,5 pt). Erreurs fréquentes : penser qu'une réservation prise sur le trottoir « juste avant » régularise la course ; oublier que le support numérique est parfaitement admis.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-8','question-redigee'], 'TAXI-M8-QR-03', false,
   $mft$Le contrôle en gare décomposé : vérifications, régularité, erreurs.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Comparez une course apportée par une plateforme et une course de votre clientèle propre sur quatre plans : fixation du prix, détention de la relation client et des données, marge, risques. Concluez sur la stratégie d'équilibre à viser.$mft$,
   $mft$Réponse modèle. Fixation du prix : sur plateforme, le prix est imposé au client par l'application, le chauffeur ne le négocie pas (sa liberté : accepter ou refuser la course) ; en clientèle propre, le chauffeur fixe son prix au devis, ferme et TTC. Relation client et données : la plateforme détient le client, l'historique, les données et la notation : une désactivation efface tout ; en direct, le client, le contrat et l'historique appartiennent au chauffeur. Marge : la course plateforme supporte une commission systématique, et les cotisations se calculent sur le chiffre d'affaires (commission comprise en micro-entreprise) ; la course directe n'a pas de commission : c'est là que se trouve la vraie marge. Risques : côté plateforme, la dépendance économique (baisse unilatérale des tarifs, changement d'algorithme, désactivation) ; côté clientèle propre, l'effort de prospection, et des litiges (no-show, attente) à prévenir par des conditions écrites et des acomptes. Stratégie d'équilibre : cumuler plusieurs plateformes pour remplir les creux et diversifier, tout en développant méthodiquement hôtels, entreprises, conciergeries et événements : la plateforme comme complément, la clientèle propre comme socle de marge et d'indépendance.$mft$,
   $mft$Barème /5 : quatre plans traités avec exactitude (prix, relation et données, marge, risques) (3 pts) ; risques équilibrés des deux modèles (1 pt) ; conclusion stratégique : multi-plateformes en complément, clientèle propre en levier de marge (1 pt). Erreurs fréquentes : oublier que le chauffeur reste libre de refuser les courses plateforme ; présenter la clientèle propre comme sans contrainte (prospection, conditions écrites à prévoir).$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-8','question-redigee'], 'TAXI-M8-QR-04', false,
   $mft$Plateforme contre clientèle propre : la comparaison structurée.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Cas chiffré : ce mois-ci, les plateformes ont facturé 6 000 € de courses à vos clients et prélevé 25 % de commission ; votre clientèle propre a réglé 2 000 € en direct. Vous êtes en micro-entreprise. Analysez : sommes réellement encaissées, base de calcul des cotisations, poids réel de la commission, et levier prioritaire pour améliorer la marge le mois suivant.$mft$,
   $mft$Réponse modèle. Encaissements : les plateformes prélèvent 25 % de 6 000 €, soit 1 500 € de commission : elles reversent 4 500 € ; la clientèle propre règle 2 000 € sans commission : total encaissé 6 500 €. Base des cotisations : en micro-entreprise, les cotisations se calculent sur le chiffre d'affaires réalisé, commission comprise pour la part plateforme : soit 8 000 € (6 000 € via plateformes + 2 000 € en direct), et non les 6 500 € encaissés. Poids réel de la commission : 1 500 € de commission sur la part plateforme, auxquels s'ajoutent des cotisations calculées sur 6 000 € et non sur 4 500 € : chaque euro facturé via la plateforme rapporte donc nettement moins qu'un euro facturé en direct, une fois commission et cotisations déduites. Levier prioritaire : déplacer du volume vers la clientèle propre : à montant facturé égal, une course directe échappe à la commission et le prix y est fixé par le chauffeur. Concrètement : prospecter hôtels, entreprises et conciergeries, systématiser devis et conditions écrites, proposer une facturation mensuelle aux comptes réguliers, et suivre chaque mois la part du chiffre d'affaires réalisée en direct.$mft$,
   $mft$Barème /5 : encaissements exacts (4 500 € + 2 000 € = 6 500 €) (1 pt) ; base de cotisations correcte : 8 000 € de chiffre d'affaires, commission comprise (1,5 pt) ; analyse du poids réel de la commission cumulée aux cotisations (1,5 pt) ; levier prioritaire argumenté : accroître la part de clientèle propre (1 pt). Erreurs fréquentes : calculer les cotisations sur les 6 500 € encaissés ; déduire la commission comme une charge en micro-entreprise.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-8','question-redigee'], 'TAXI-M8-QR-05', false,
   $mft$Le cas chiffré commission + cotisations : lecture de la marge réelle.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Vous lancez votre activité VTC dans une métropole avec un seul véhicule. Choisissez un positionnement (berline affaires, van ou éco), justifiez ce choix, décrivez le standard de prestation associé et la manière dont vous vous différenciez du taxi et des autres VTC.$mft$,
   $mft$Réponse modèle (un autre positionnement cohérent est recevable). Choix : la berline affaires. Justification : elle vise une clientèle solvable et récurrente (cadres, directions, clientèle hôtelière), directement compatible avec la construction d'une clientèle propre (hôtels, entreprises, conciergeries) : c'est le positionnement qui convertit le mieux un service soigné en contrats réguliers. Standard de prestation : véhicule impeccable intérieur et extérieur à chaque course, bouteilles d'eau, chargeurs pour les principaux téléphones, aide systématique aux bagages, discrétion totale (conversation seulement si le client l'engage, aucun commentaire sur d'autres clients), ponctualité absolue, tenue soignée, conduite souple. Outils : devis avec trajet, durée estimée, prix ferme TTC et conditions d'annulation ; confirmation écrite systématique ; suivi des vols et franchise d'attente pour les transferts. Différenciation face au taxi : le prix ferme connu avant la course (contre la facturation au compteur), la prestation standardisée et la confirmation écrite. Face aux autres VTC : la constance (même niveau à chaque course), la personnalisation (préférences mémorisées : température, silence, itinéraire) et le professionnalisme documentaire. Le tout doit rester cohérent : véhicule, tenue, tarif et discours racontent la même promesse.$mft$,
   $mft$Barème /5 : choix justifié et cohérent avec une cible identifiée (1,5 pt) ; standard de prestation complet et concret (1,5 pt) ; différenciation face au taxi (prix ferme, service, écrit) (1 pt) ; différenciation face aux autres VTC (constance, personnalisation) (1 pt). Tout positionnement (affaires, van, éco) est recevable si l'ensemble est cohérent. Erreurs fréquentes : vouloir servir toutes les clientèles à la fois ; se différencier uniquement par le prix le plus bas.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-8','question-redigee'], 'TAXI-M8-QR-06', false,
   $mft$Positionnement, standard de service et différenciation argumentés.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Vous réalisez aujourd'hui 90 % de votre chiffre d'affaires via une seule plateforme. Construisez un plan d'action sur douze mois pour réduire cette dépendance : actions commerciales, outils, jalons et indicateurs de suivi.$mft$,
   $mft$Réponse modèle. Mois 1 et 2 : diagnostic chiffré (part du chiffre d'affaires par source, coût réel des courses plateforme une fois commission et cotisations comptées) ; inscription sur une ou deux plateformes supplémentaires (le cumul est possible) pour diversifier immédiatement ; création des outils : devis type (trajet, durée estimée, prix ferme TTC, conditions d'annulation, d'attente et de no-show), modèle de facture, page professionnelle, cartes. Mois 3 à 6 : prospection ciblée : hôtels du secteur (rencontrer les réceptions, proposer une grille de transferts), entreprises (déplacements réguliers, facturation mensuelle), conciergeries, organisateurs d'événements ; objectif : signer les premiers comptes réguliers avec conditions écrites. Mois 6 à 12 : fidéliser par la constance (ponctualité, véhicule impeccable, discrétion), demander des recommandations, monter la part directe et réallouer : les plateformes deviennent un complément qui remplit les creux. Indicateurs mensuels : part du chiffre d'affaires par source (objectif : la plateforme principale sous un seuil que l'on se fixe), nombre de comptes réguliers actifs, marge par course, taux de no-show maîtrisé. Veille : suivre l'évolution du cadre du dialogue social des plateformes (ARPE, accords), qui bouge régulièrement.$mft$,
   $mft$Barème /5 : diagnostic initial chiffré (part de CA par source, coût réel des courses plateforme) (1 pt) ; diversification immédiate multi-plateformes (0,5 pt) ; plan de prospection concret vers hôtels, entreprises, conciergeries, événements avec outils (devis, conditions écrites, contrats) (2 pts) ; jalons et indicateurs mesurables sur douze mois (1,5 pt). Erreurs fréquentes : plan d'intentions sans indicateurs ; couper brutalement la plateforme avant d'avoir sécurisé la clientèle propre.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-8','question-redigee'], 'TAXI-M8-QR-07', false,
   $mft$Le plan de désengagement progressif vis-à-vis des plateformes.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Deux litiges la même semaine : (1) un client no-show à 5 h 30 pour un transfert avec devis écrit accepté, acompte encaissé et conditions d'annulation ; (2) un client conteste 40 € d'attente facturés après un vol retardé, alors qu'aucune franchise ni tarif d'attente ne figuraient dans vos échanges. Analysez chaque situation, ce que vous pouvez défendre, et les règles à systématiser.$mft$,
   $mft$Réponse modèle. Cas 1 : position solide. Les conditions de no-show et d'annulation ont été acceptées PAR ÉCRIT avant la course et un acompte a été encaissé ; le no-show se constate proprement : appels et messages horodatés, attente raisonnable sur place. L'application des conditions (retenue de l'acompte ou facturation prévue) est défendable ; la communication reste factuelle et courtoise : rappel du devis accepté, pièces à l'appui. Cas 2 : position fragile. L'attente était réelle, mais aucune franchise ni tarif n'avaient été annoncés : le client découvre un supplément après coup, ce qui est contestable et dégrade la réputation. Traitement : geste commercial (abandon ou réduction du supplément), et surtout correction immédiate du processus. Règles à systématiser : tout événement prévisible (retard de vol, attente, annulation tardive, no-show) a sa règle ÉCRITE dans le devis ; confirmation écrite systématique reprenant prix ferme TTC et conditions ; acompte pour les courses à enjeu (très matinales, longue distance, événements) ; suivi du vol avec franchise décomptée de l'atterrissage réel ; traces conservées (messages, horaires). Conclusion : la protection du VTC se construit avant la course, jamais au moment du litige.$mft$,
   $mft$Barème /5 : cas 1 analysé : conditions écrites préalables + constat tracé = application défendable (1,5 pt) ; cas 2 analysé : supplément non annoncé = position fragile, traitement commercial (1,5 pt) ; règles systématisées : conditions écrites complètes, confirmation, acompte, franchise annoncée, traces (1,5 pt) ; conclusion : la protection se prépare avant la course (0,5 pt). Erreurs fréquentes : croire qu'un no-show est toujours facturable même sans conditions écrites ; répondre au litige en improvisant une pénalité.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-8','question-redigee'], 'TAXI-M8-QR-08', false,
   $mft$Deux litiges comparés : ce qui se défend, ce qui se corrige.$mft$);

  RAISE NOTICE 'Module 8 Taxi/VTC (spécifique VTC) créé : module %, 3 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $taxim8$;
