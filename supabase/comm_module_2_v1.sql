-- =====================================================================
-- COMMISSIONNAIRE DE TRANSPORT : MODULE 2 : LE CONTRAT DE COMMISSION
-- ET LES RESPONSABILITÉS
-- v1 (juillet 2026) : LOT COMMISSIONNAIRE
-- Angle candidat : obligations croisées, double responsabilité (fait
-- personnel et garantie des substitués), prescription annale, chaîne
-- des recours et gestion d'un litige multimodal de bout en bout.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $commm2$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_l4 uuid;
  v_quiz uuid; v_q uuid; v_ord int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'commissionnaire';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation commissionnaire introuvable.'; END IF;

  INSERT INTO public.blocs (id, code, title, description, "order") VALUES (80, 'COMMISSIONNAIRE', 'Commissionnaire de transport', 'Le métier de commissionnaire de transport : contrat de commission, responsabilités, organisation multimodale, douane et Incoterms, gestion et assurances.', 80) ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'COMMISSIONNAIRE';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'COMM-M2-%';
  DELETE FROM public.modules WHERE slug = 'comm-contrat-responsabilites';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 2 : Le contrat de commission et les responsabilités',
    'comm-contrat-responsabilites', v_bloc,
    'Les obligations du commissionnaire, sa double responsabilité (fait personnel et garantie des substitués), les plafonds d''indemnisation et la gestion des litiges dans la chaîne.',
    'avance', 330, 20) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 20, true);

  -- ─── Leçon 1 : Les obligations du commissionnaire et du commettant ──
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'obligations-du-commissionnaire',
    'Les obligations du commissionnaire et de son commettant',
    $mft$> 🎯 **Objectifs**
> - Identifier les quatre obligations du commissionnaire : organiser avec diligence, conseiller, exécuter les instructions, rendre compte.
> - Mesurer la portée du devoir de conseil et la sanction du silence.
> - Connaître les obligations du commettant et le principe du privilège du commissionnaire.

## Organiser le transport avec diligence

Le commissionnaire de transport s'engage à faire parvenir la marchandise à destination, par les voies et moyens de son choix. Cette liberté d'organisation, qui fait toute la valeur du métier, a une contrepartie exigeante : la diligence. Elle se joue d'abord dans le choix des substitués : les juristes parlent de culpa in eligendo, la faute dans le choix. Confier un lot à un transporteur sans vérifier sa licence, son assurance, sa capacité réelle et sa réputation, c'est se préparer à répondre personnellement de la défaillance qui suivra. Le professionnel sérieux tient un référentiel de sous-traitants vivant : documents contrôlés à l'entrée puis périodiquement, incidents tracés dossier par dossier, partenaires défaillants écartés.

:::flow
1. Réception de l'ordre | Analyse du besoin : nature, valeur, délais, contraintes
2. Conseil au client | Mode adapté, emballage, assurance ad valorem si la valeur le justifie
3. Choix des substitués | Licence, assurance, capacité et réputation vérifiées
4. Exécution et suivi | Instructions transmises intégralement, incidents remontés sans délai
5. Compte rendu | Client informé, documents restitués, dossier archivé
:::

## Le devoir de conseil : l'obligation qui piège les silencieux

Le commissionnaire est un professionnel du transport face à un client qui, souvent, ne l'est pas. Il doit donc éclairer ses choix : recommander le mode le plus adapté (délai, fragilité, valeur de la marchandise), alerter sur un emballage insuffisant pour le trajet prévu, proposer une assurance ad valorem quand la valeur expédiée dépasse ce que les plafonds d'indemnisation permettraient de récupérer. Ce devoir de conseil est sanctionné : le commissionnaire qui se tait engage sa responsabilité personnelle, même si l'exécution matérielle du transport a été confiée à d'autres.

| Situation rencontrée | Le conseil attendu |
| --- | --- |
| Marchandise de forte valeur | Proposer par écrit une assurance ad valorem |
| Emballage visiblement insuffisant | Alerter le client et recommander un conditionnement adapté |
| Délai incompatible avec le mode envisagé | Proposer le mode qui tient l'engagement, en chiffrant l'écart de coût |
| Marchandise sensible (choc, humidité, température) | Recommander les précautions et le matériel adéquats |

> ⚠️ **Attention**
> Le conseil oral s'évapore, le conseil écrit protège. Une assurance ad valorem proposée par courriel et refusée par le client renverse la situation : le refus documenté devient votre meilleure pièce de défense en cas de sinistre.

## Exécuter les instructions et rendre compte

Les instructions du commettant s'exécutent à la lettre : un contre-remboursement signifie livrer contre paiement, une livraison contre document signifie ne remettre la marchandise que contre la pièce convenue. Le commissionnaire qui fait livrer sans encaisser le contre-remboursement s'expose à devoir la somme lui-même. Enfin, il rend compte : le commettant est tenu informé du déroulement de la mission, des incidents et de leurs suites, et reçoit les documents justificatifs. Un client qui découvre un problème par son propre destinataire est déjà un client perdu.

## Les obligations du commettant

Le contrat n'est pas à sens unique. Le commettant doit d'abord des informations exactes : nature de la marchandise, poids, dangerosité éventuelle. Une déclaration inexacte ou incomplète (poids minoré, matière dangereuse dissimulée) engage sa responsabilité pour les dommages qui en résultent. Il doit ensuite payer le prix convenu de la commission et des prestations.

> ❌ **Piège à éviter**
> Recopier sans réagir des déclarations manifestement incohérentes (un prix de vente sans rapport avec le poids annoncé, un conditionnement qui trahit une autre nature de produit) : la diligence professionnelle impose de questionner ce qui devrait alerter un spécialiste.

## Le privilège du commissionnaire

Pour garantir le paiement de ses créances, le commissionnaire bénéficie d'un privilège sur les marchandises : un client mauvais payeur ne peut pas exiger la libre disposition de ses lots comme si de rien n'était. Le périmètre exact de ce privilège (créances couvertes, marchandises concernées, conditions de mise en œuvre) est à vérifier dans les textes en vigueur avant de s'en prévaloir : le principe existe, ses contours se manient avec précision et, en pratique, avec l'appui d'un conseil juridique.

> 💡 **Astuce**
> Formalisez un questionnaire d'expédition systématique : nature exacte, poids vérifiable, valeur déclarée, matières dangereuses, contraintes de livraison. Ce document nourrit le conseil, cadre la responsabilité du commettant et devient une pièce maîtresse en cas de litige.

## ✅ Synthèse

- Quatre obligations : **organiser avec diligence** (substitués fiables, culpa in eligendo), **conseiller** (mode, emballage, assurance ad valorem), **exécuter les instructions** (contre-remboursement, livraison contre document), **rendre compte**.
- Le devoir de conseil est **sanctionné** : le silence du professionnel est une faute personnelle ; l'écrit est sa protection.
- Le commettant doit des **informations exactes** (nature, poids, dangerosité) et le **paiement** ; le commissionnaire dispose d'un **privilège** sur les marchandises (périmètre exact à vérifier).$mft$,
    $mft$Les quatre obligations du commissionnaire (organiser avec diligence, conseiller, exécuter les instructions, rendre compte), le devoir de conseil sanctionné, les obligations du commettant et le privilège garantissant les créances.$mft$,
    1, 40) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : La double responsabilité ─────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'double-responsabilite',
    'La double responsabilité : une tête pour toute la chaîne',
    $mft$> 🎯 **Objectifs**
> - Distinguer la responsabilité du fait personnel et la garantie du fait des substitués.
> - Expliquer pourquoi le client n'a qu'un interlocuteur dans toute la chaîne.
> - Situer les limites : plafonds calés sur le substitué, plafonds propres, faute lourde ou dolosive.

## Deux fondements, un seul débiteur

La responsabilité du commissionnaire repose sur deux piliers qu'il faut savoir distinguer, parce qu'ils n'obéissent pas aux mêmes règles.

Le premier est la **responsabilité du fait personnel** : le commissionnaire répond de ses fautes propres. Mauvais choix de transporteur (le sous-traitant sans assurance, notoirement défaillant, retenu pour préserver la marge), défaut de conseil (l'assurance ad valorem jamais proposée), erreur documentaire (une adresse mal reportée, un document manquant au passage portuaire), instruction du client oubliée ou mal transmise : autant de fautes qui lui appartiennent en propre, quelle que soit la qualité de l'exécution du transport lui-même.

Le second est la **garantie du fait des substitués** : le commissionnaire répond envers son client des avaries, des pertes et des retards causés par les transporteurs qu'il s'est substitués, à charge de recours contre eux. Il n'a pas commis de faute : il garantit. C'est le prix de sa liberté d'organisation : il a choisi les maillons, il en répond.

| | Fait personnel | Garantie des substitués |
| --- | --- | --- |
| Origine | Faute propre du commissionnaire | Défaillance d'un transporteur substitué |
| Exemples | Mauvais choix de transporteur, défaut de conseil, erreur documentaire | Avarie, perte, retard imputables au substitué |
| Plafond | Plafonds propres (contrat type commission, montants à vérifier) | Par référence aux plafonds applicables au transporteur substitué |
| Recours | Aucun : la faute est la sienne | Recours contre le substitué fautif |

## Un interlocuteur unique : le confort qui fait vendre le métier

Pour le client, la conséquence est précieuse : quel que soit le maillon défaillant (armateur, routier, aérien, manutentionnaire substitué), il n'a **qu'un interlocuteur** : son commissionnaire. Pas besoin d'identifier le fautif, de décortiquer les régimes juridiques de chaque mode ni de poursuivre un armateur à l'autre bout du monde : il actionne le commissionnaire, qui indemnise puis fait son affaire des recours. Cette simplicité est l'argument commercial central du métier : le commissionnaire vend une chaîne sans couture, il en assume donc la couture juridique.

:::flow
1. Sinistre | Le transporteur substitué perd ou avarie la marchandise
2. Réclamation | Le client actionne son commissionnaire, interlocuteur unique
3. Indemnisation | Le commissionnaire paie, par référence aux plafonds du substitué
4. Recours | Le commissionnaire se retourne contre le transporteur fautif
:::

## Les limites : plafonds et faute lourde

La garantie des substitués n'est pas un chèque en blanc. Elle est **plafonnée par référence aux plafonds applicables au transporteur substitué** : la logique est que le commissionnaire ne doit pas payer à son client plus que ce qu'il pourra récupérer auprès du maillon fautif. Si le régime du transporteur limite l'indemnité, la garantie du commissionnaire s'aligne sur cette limite.

Sa responsabilité personnelle connaît ses **propres plafonds** : le contrat type applicable à la commission de transport en prévoit (montants à vérifier dans le texte en vigueur). Mais ces plafonds sautent en cas de **faute personnelle lourde ou dolosive** : le commissionnaire qui confie sciemment un lot à un transporteur qu'il sait défaillant et non assuré, ou qui dissimule un incident à son client, s'expose à une réparation intégrale.

> 🔍 **Zoom**
> Un même dossier mélange souvent les deux fondements : l'avarie vient du substitué (garantie plafonnée), mais le client reproche AUSSI au commissionnaire de ne pas lui avoir proposé d'assurance ad valorem (faute personnelle). Les deux terrains se plaident séparément, avec des plafonds différents : savoir les dissocier, c'est déjà savoir défendre le dossier.

> 📌 **À retenir**
> Fait personnel : mes fautes, mes plafonds. Garantie des substitués : leurs défaillances, leurs plafonds, mon recours. Faute lourde ou dolosive : plus de plafond du tout.

## ✅ Synthèse

- Deux fondements : **fait personnel** (fautes propres : choix, conseil, documents) et **garantie des substitués** (avaries, pertes, retards des transporteurs choisis, à charge de recours).
- Le client bénéficie d'un **interlocuteur unique** : le commissionnaire porte juridiquement toute la chaîne.
- Limites : garantie **calée sur les plafonds du substitué** ; responsabilité personnelle **plafonnée par le contrat type** (montants à vérifier) ; **faute lourde ou dolosive** : réparation intégrale.$mft$,
    $mft$La responsabilité du fait personnel (fautes propres) et la garantie du fait des substitués (à charge de recours), l'interlocuteur unique offert au client, et les limites : plafonds calés sur le substitué, plafonds propres, faute lourde ou dolosive.$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Prescription et recours ──────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'prescription-et-recours',
    'Prescription annale et chaîne des recours',
    $mft$> 🎯 **Objectifs**
> - Retenir la prescription d'un an des actions nées du contrat de commission.
> - Dérouler la chaîne des recours du destinataire jusqu'au transporteur fautif.
> - Comprendre pourquoi la gestion des délais est un métier à part entière.

## Un an : la prescription annale

Les actions nées du contrat de commission se prescrivent par **un an**, comme en transport. Passé ce délai, sauf cause d'interruption ou de suspension, l'action est éteinte : le client qui réclame quatorze mois après la livraison se heurte à la prescription, quelle que soit la réalité du dommage. Cette brièveté n'est pas une anomalie : toute la chaîne du transport vit sur des délais courts, pensés pour que les litiges se traitent à chaud, quand les preuves existent encore.

## La chaîne des recours : chacun son maillon, chacun son délai

Un litige de bout en bout remonte la chaîne dans un ordre logique :

:::flow
1. Livraison | Le destinataire prend des réserves écrites, précises, immédiates
2. Réclamation | Le client actionne son commissionnaire dans l'année
3. Notifications | Le commissionnaire notifie chaque substitué dans SES délais
4. Recours | Action contre le maillon fautif dans le délai propre à son mode
:::

Le point critique est l'étape 3 : chaque mode de transport a **ses propres délais** de réserves et d'action, qui ne s'alignent pas sur le délai dont dispose le client contre le commissionnaire.

| Segment | Réflexes et délais à surveiller |
| --- | --- |
| Maritime | Réserves très rapides à la livraison : un délai de trois jours est souvent cité, à vérifier selon le régime applicable au connaissement |
| Routier international (CMR) | Réserves à la livraison, puis action dans le délai d'un an |
| Aérien | Protestations écrites dans des délais courts, propres au régime applicable, à vérifier dossier par dossier |

> ⚠️ **Attention**
> Ce tableau donne des ordres de grandeur de vigilance, pas un mémento juridique : avant toute notification, vérifiez le régime exact applicable au segment concerné (convention, contrat type, connaissement). Le réflexe professionnel, lui, est constant : notifier vite, par écrit, en conservant la preuve de l'envoi.

## Payer sans recours : le scénario noir

Voici le piège central du métier. Le client dispose d'un an contre le commissionnaire. Mais si, pendant ce temps, le commissionnaire n'a pas préservé ses recours (réserves maritimes expirées en quelques jours, protestation aérienne hors délai), il se retrouve dans la pire des positions : **tenu d'indemniser son client, incapable de récupérer auprès du fautif**. Il paie sans recours. Le dommage vient d'un tiers, la perte finit chez lui, uniquement parce qu'un délai a filé.

C'est pourquoi la gestion des délais est un métier : registre des délais ouvert dès la réception du dossier, échéances par substitué et par mode, alertes avant expiration, modèles de notification prêts à partir. Dans un service litiges bien tenu, on notifie d'abord, on analyse ensuite.

## Conserver les preuves de chaque segment

Le recours se gagne avec des pièces : le document de transport de chaque segment (connaissement maritime, lettre de voiture CMR, lettre de transport aérien), les réserves prises à chaque interface, les photos, les correspondances, les rapports de manutention. Un dossier de commission est un empilement de contrats de transport : il faut pouvoir rejouer chaque maillon devant un expert ou un juge. Archiver systématiquement, dès le dossier ouvert, coûte quelques minutes ; reconstituer un dossier un an plus tard est souvent impossible.

> 🎓 **Pour l'examen**
> Retenez la formule : le commissionnaire qui laisse filer un délai de recours paie sans recours. Elle résume la leçon : la garantie envers le client survit, le recours contre le substitué meurt, et l'écart entre les deux se lit directement au compte de résultat.

## ✅ Synthèse

- **Prescription annale** : les actions nées du contrat de commission se prescrivent par un an, comme en transport.
- Chaîne des recours : **réserves du destinataire, réclamation au commissionnaire, notifications à chaque substitué dans SES délais, recours contre le fautif**.
- Délais propres à chaque mode : maritime très court (trois jours souvent cités, à vérifier), CMR : réserves à la livraison et action dans l'année.
- Délai manqué = **payer sans recours** : registre des délais, alertes, notifications immédiates, preuves de chaque segment conservées.$mft$,
    $mft$La prescription d'un an des actions nées du contrat de commission, la chaîne des recours (réserves, réclamation, notifications, action), les délais propres à chaque mode et le scénario du commissionnaire qui paie sans recours.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Gérer un litige de bout en bout ──────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'gerer-un-litige-bout-en-bout',
    'Gérer un litige de bout en bout : le conteneur avarié',
    $mft$> 🎯 **Objectifs**
> - Dérouler la chronologie idéale d'un litige multimodal, du constat au recours.
> - Éviter les trois erreurs fatales : réserves tardives, expertise non contradictoire, délai manqué.
> - Anticiper le litige dès le contrat : plafonds, assurance proposée par écrit.

## Le cas fil rouge

Votre commettant, un importateur de mobilier, vous a confié l'acheminement d'un conteneur : segment maritime, puis post-acheminement routier jusqu'à son client final. Ce matin, à la livraison, le destinataire ouvre les portes : cartons écrasés sur deux rangées, traces d'humidité au fond. L'origine du dommage est inconnue : mer, port ou route, personne ne peut le dire. Tout ce que vous ferez, ou ne ferez pas, dans les prochains jours décidera de qui paiera.

## La chronologie idéale

:::timeline
J0 | Réserves écrites, précises et immédiates du destinataire sur le document de livraison, photos à l'appui ; marchandise conservée en l'état
J0 | Notification du sinistre au commissionnaire ; ouverture du dossier, information du commettant
J+1 à J+3 | Notifications conservatoires à CHAQUE substitué (armateur, routier, manutentionnaire le cas échéant), chacun dans SES délais, les délais maritimes étant les plus courts
J+2 à J+8 | Expertise contradictoire : tous les maillons convoqués par écrit, constat commun de l'état et des causes probables
Ensuite | Chiffrage : valeur de la perte, plafonds applicables segment par segment ; négociation et indemnisation du client
Enfin | Recours contre le ou les maillons désignés par l'expertise, dans les délais préservés
:::

Trois mots portent toute la chronologie : **immédiat** (les réserves), **tous** (les substitués notifiés), **contradictoire** (l'expertise).

## L'expertise contradictoire : convoquer tout le monde

Amiable ou judiciaire, l'expertise n'a de valeur que si elle est **contradictoire** : chaque maillon de la chaîne doit être convoqué et mis en mesure d'assister aux opérations. Une expertise menée entre le seul destinataire et le commissionnaire sera contestée par l'armateur absent : « je n'y étais pas, ce constat ne m'est pas opposable ». Convoquez par écrit, avec preuve de la convocation, tous les intervenants, y compris ceux qui semblent hors de cause : l'origine du dommage réserve des surprises, et le maillon négligé aujourd'hui est le recours perdu de demain.

## Le chiffrage : une valeur, plusieurs plafonds

Le préjudice se chiffre deux fois. D'abord la valeur réelle de la perte : factures, poids, quantités avariées. Ensuite le plafond applicable : il dépend du segment où le dommage sera localisé, chaque mode ayant son régime. Le même carton écrasé ne s'indemnise pas pareil selon qu'il a souffert en mer ou sur la route. D'où l'importance de l'expertise pour localiser le dommage, et du dossier documentaire pour rejouer chaque segment.

## Les erreurs fatales

> ❌ **Piège à éviter**
> Trois erreurs ruinent les dossiers, toujours les mêmes : les **réserves tardives** (le dommage constaté « la semaine suivante » devient improuvable), l'**expertise non contradictoire** (conclusions inopposables aux absents), le **délai de recours manqué** (le commissionnaire paie sans recours). Les trois ont un point commun : elles se jouent dans les tout premiers jours, quand le dossier paraît encore « petit ».

## Anticiper dès le contrat : le litige se gagne avant le sinistre

Le meilleur dossier de litige se prépare quand tout va bien. Avec le client : des **clauses de plafonds** pour la responsabilité personnelle du commissionnaire, cohérentes avec le contrat type applicable (montants à vérifier) ; une **proposition d'assurance ad valorem écrite** dès que la valeur dépasse ce que les plafonds couvriraient, avec acceptation ou refus signé : le refus documenté ferme le front du défaut de conseil ; une **procédure de réclamation** annexée au contrat : réserves immédiates, notification rapide, conservation de la marchandise en l'état pour l'expertise. En interne : le registre des délais et les modèles de notification vus à la leçon précédente.

> 💡 **Astuce**
> Constituez une « mallette sinistre » prête à l'emploi : check-list du jour J, modèles de réserves et de notifications par mode, liste des experts habituels, trame de convocation contradictoire. Le jour du conteneur avarié, on exécute, on n'improvise pas.

## ✅ Synthèse

- Chronologie : **réserves immédiates, notification au commissionnaire, notifications conservatoires à chaque substitué dans ses délais, expertise contradictoire, chiffrage, indemnisation, recours**.
- Expertise : **tous les maillons convoqués par écrit**, sinon conclusions inopposables.
- Erreurs fatales : réserves tardives, expertise non contradictoire, délai de recours manqué.
- Le litige s'anticipe au contrat : **plafonds, assurance ad valorem proposée par écrit, procédure de réclamation** annexée.$mft$,
    $mft$Le litige multimodal déroulé sur un cas fil rouge (conteneur avarié) : chronologie idéale, expertise contradictoire, chiffrage par segment, erreurs fatales et clauses contractuelles qui préparent la défense avant le sinistre.$mft$,
    4, 45) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Contrat de commission et responsabilités',
    'Vérifiez le module 2 : obligations du commissionnaire, double responsabilité, prescription et gestion des litiges.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Votre client, un fabricant de verrerie, vous remet des caisses au cerclage visiblement insuffisant pour un trajet routier de 900 km. Que devez-vous faire ?$mft$,
    $mft$[
      {"id":"a","label":"L'alerter par écrit sur l'insuffisance de l'emballage et lui recommander un conditionnement adapté : c'est votre devoir de conseil","is_correct":true},
      {"id":"b","label":"Charger sans commentaire : l'emballage relève du seul client","is_correct":false},
      {"id":"c","label":"Refuser définitivement la mission sans explication","is_correct":false},
      {"id":"d","label":"Faire ré-emballer la marchandise à ses frais sans le prévenir","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-2','qcm-v1'], 'COMM-M2-QCM-01', false,
    $mft$Le devoir de conseil est sanctionné : laisser partir un emballage inadapté sans alerte écrite engage la responsabilité personnelle du commissionnaire. Le silence (b), le refus sec (c) et l'initiative non autorisée (d) ne remplacent pas le conseil.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Le transporteur routier que vous avez choisi perd deux palettes de votre client. Vers qui le client doit-il se tourner pour être indemnisé ?$mft$,
    $mft$[
      {"id":"a","label":"Vers vous, son commissionnaire : vous garantissez le fait de vos substitués, à charge pour vous de vous retourner contre le transporteur","is_correct":true},
      {"id":"b","label":"Directement et uniquement vers le transporteur routier, seul fautif","is_correct":false},
      {"id":"c","label":"Vers l'assureur du destinataire, quel qu'il soit","is_correct":false},
      {"id":"d","label":"Vers personne : la perte chez un sous-traitant n'ouvre droit à rien","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-2','qcm-v1'], 'COMM-M2-QCM-02', false,
    $mft$La garantie du fait des substitués fait du commissionnaire l'interlocuteur unique du client : il indemnise puis exerce son recours contre le routier. Le client n'a pas à courir après le maillon fautif (b), et la perte reste évidemment indemnisable (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un commettant vous menace d'une action en justice pour une avarie survenue il y a quatorze mois, sans aucun acte interruptif entre-temps. Que pouvez-vous lui opposer ?$mft$,
    $mft$[
      {"id":"a","label":"La prescription : les actions nées du contrat de commission se prescrivent par un an, comme en transport","is_correct":true},
      {"id":"b","label":"Rien : ces actions se prescrivent par cinq ans","is_correct":false},
      {"id":"c","label":"Le fait qu'un commissionnaire n'est jamais responsable des avaries","is_correct":false},
      {"id":"d","label":"L'obligation pour le client d'attendre deux ans avant d'agir","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-2','qcm-v1'], 'COMM-M2-QCM-03', false,
    $mft$La prescription annale gouverne les actions nées du contrat de commission : à quatorze mois sans interruption, l'action est éteinte. Le délai de droit commun (b) ne s'applique pas ici, et le commissionnaire reste bien responsable dans le délai (c).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$À l'ouverture d'un conteneur chez le destinataire final, les cartons du fond sont écrasés et mouillés. Quel est le tout premier geste qui conditionne la suite du dossier ?$mft$,
    $mft$[
      {"id":"a","label":"Des réserves écrites, précises et immédiates du destinataire sur le document de livraison, photos à l'appui","is_correct":true},
      {"id":"b","label":"Jeter les cartons abîmés pour libérer le quai","is_correct":false},
      {"id":"c","label":"Attendre la fin du déballage complet la semaine suivante pour faire un point global","is_correct":false},
      {"id":"d","label":"Appeler directement l'armateur pour négocier un geste commercial","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-2','qcm-v1'], 'COMM-M2-QCM-04', false,
    $mft$Les réserves immédiates figent l'état de la marchandise : sans elles, tout devient improuvable. Jeter (b) détruit la preuve, attendre (c) rend le dommage contestable, et négocier sans dossier (d) affaiblit tous les recours.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Votre commettant a déclaré « pièces détachées » pour un lot contenant en réalité des aérosols inflammables non signalés. Un incident survient au transbordement. Sur quel terrain sa responsabilité est-elle engagée ?$mft$,
    $mft$[
      {"id":"a","label":"Le manquement à son obligation de fournir des informations exactes sur la nature et la dangerosité de la marchandise","is_correct":true},
      {"id":"b","label":"Aucun : la qualification de la marchandise appartient au seul commissionnaire","is_correct":false},
      {"id":"c","label":"Le défaut de paiement du prix de la commission","is_correct":false},
      {"id":"d","label":"Le non-respect du privilège du commissionnaire","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-2','qcm-v1'], 'COMM-M2-QCM-05', false,
    $mft$Le commettant doit des informations exactes (nature, poids, dangerosité) : la dissimulation engage sa responsabilité pour les dommages qui en résultent. Le paiement (c) et le privilège (d) sont des sujets distincts, et la qualification n'incombe pas au seul commissionnaire (b).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un client vous doit plusieurs factures et vous détenez encore ses marchandises en entrepôt dans le cadre de vos missions. De quel mécanisme disposez-vous pour garantir vos créances ?$mft$,
    $mft$[
      {"id":"a","label":"Du privilège du commissionnaire sur les marchandises, dont le périmètre exact doit être vérifié avant de s'en prévaloir","is_correct":true},
      {"id":"b","label":"Du droit de vendre immédiatement les marchandises sans aucune formalité","is_correct":false},
      {"id":"c","label":"Du droit de saisir le compte bancaire du client par simple courrier","is_correct":false},
      {"id":"d","label":"D'aucun mécanisme : le commissionnaire est un créancier ordinaire","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-2','qcm-v1'], 'COMM-M2-QCM-06', false,
    $mft$Le privilège du commissionnaire garantit ses créances sur les marchandises qu'il détient ; son périmètre exact se vérifie dans les textes avant toute mise en œuvre. Vente sauvage (b) et saisie par courrier (c) n'existent pas, et le commissionnaire n'est pas un créancier ordinaire (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Une machine de grande valeur voyage sans assurance ad valorem : vous ne l'avez jamais proposée. Elle est détruite par la faute du transporteur substitué et le plafond applicable laisse au client une perte importante. Que risque le commissionnaire au-delà de la garantie du substitué ?$mft$,
    $mft$[
      {"id":"a","label":"Une mise en cause de sa responsabilité personnelle pour défaut de conseil : il aurait dû proposer l'assurance ad valorem","is_correct":true},
      {"id":"b","label":"Rien : seule la garantie des substitués peut jouer, dans tous les cas","is_correct":false},
      {"id":"c","label":"Une amende administrative automatique","is_correct":false},
      {"id":"d","label":"La confiscation de la machine détruite","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-2','qcm-v1'], 'COMM-M2-QCM-07', false,
    $mft$Le défaut de conseil est une faute personnelle qui se plaide en plus de la garantie des substitués : le client peut réclamer le préjudice causé par l'assurance jamais proposée. Il ne s'agit ni d'une sanction administrative (c) ni d'une confiscation (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un client vous notifie une avarie sur un segment maritime deux mois après la livraison ; aucune réserve n'a été prise à l'arrivée et vous n'avez rien notifié à l'armateur. Quel est le principal danger pour vous ?$mft$,
    $mft$[
      {"id":"a","label":"Devoir indemniser votre client tout en ayant perdu votre recours contre l'armateur : les délais propres au maritime sont très courts","is_correct":true},
      {"id":"b","label":"Aucun : votre délai d'un an contre le client vous protège aussi contre l'armateur","is_correct":false},
      {"id":"c","label":"Une simple pénalité de retard sur la facture","is_correct":false},
      {"id":"d","label":"Le transfert automatique du litige au destinataire","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-2','qcm-v1'], 'COMM-M2-QCM-08', false,
    $mft$Le client dispose d'un an contre le commissionnaire, mais le recours contre l'armateur obéit aux délais propres du maritime, bien plus courts : les laisser filer, c'est payer sans recours. Le délai annal du client ne se transpose pas au recours (b).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Pourquoi une expertise après avarie doit-elle être contradictoire, en convoquant tous les maillons de la chaîne de transport ?$mft$,
    $mft$[
      {"id":"a","label":"Pour que ses conclusions soient opposables à chaque intervenant : une expertise menée sans un maillon lui sera difficilement opposable","is_correct":true},
      {"id":"b","label":"Pour partager les frais d'expertise à parts égales, uniquement","is_correct":false},
      {"id":"c","label":"Parce que la loi interdit toute expertise amiable","is_correct":false},
      {"id":"d","label":"Pour retarder le dossier et laisser courir la prescription","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-2','qcm-v1'], 'COMM-M2-QCM-09', false,
    $mft$Le contradictoire conditionne l'opposabilité : le maillon absent contestera le constat. L'expertise amiable reste possible (c), et la question des frais (b) est secondaire par rapport à la valeur juridique des conclusions.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Marchandise perdue par le transporteur substitué : le client réclame 60 000 euros ; par hypothèse, les plafonds applicables à ce transporteur limitent l'indemnité récupérable à 18 000 euros. Sans faute personnelle de votre part, que devez-vous au client au titre de la garantie des substitués ?$mft$,
    $mft$[
      {"id":"a","label":"Une indemnité calculée par référence aux plafonds applicables au transporteur substitué : vous ne devez pas payer plus que ce que vous pouvez récupérer","is_correct":true},
      {"id":"b","label":"Les 60 000 euros intégralement, la garantie étant illimitée par principe","is_correct":false},
      {"id":"c","label":"Rien : la garantie des substitués ne couvre pas les pertes totales","is_correct":false},
      {"id":"d","label":"Le double du plafond, à titre de pénalité","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-2','qcm-v1'], 'COMM-M2-QCM-10', false,
    $mft$La garantie des substitués est plafonnée par référence aux plafonds du transporteur fautif : le commissionnaire indemnise sur cette base puis récupère par son recours. Elle n'est ni illimitée (b), ni exclue pour les pertes totales (c), ni punitive (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Vous avez confié un lot à un transporteur que vous saviez dépourvu d'assurance et déjà défaillant sur trois dossiers récents, pour préserver votre marge. Le lot est perdu. Quelle conséquence possible sur les plafonds d'indemnisation ?$mft$,
    $mft$[
      {"id":"a","label":"Votre faute personnelle, si elle est qualifiée de lourde ou dolosive, peut écarter les plafonds : vous risquez une réparation intégrale","is_correct":true},
      {"id":"b","label":"Aucune : les plafonds s'appliquent quelles que soient les circonstances","is_correct":false},
      {"id":"c","label":"Les plafonds sont simplement réduits de moitié","is_correct":false},
      {"id":"d","label":"Le client perd tout droit à indemnisation pour vous avoir choisi","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-2','qcm-v1'], 'COMM-M2-QCM-11', false,
    $mft$Choisir sciemment un substitué défaillant et non assuré relève du mauvais choix fautif : qualifiée de lourde ou dolosive, cette faute personnelle fait sauter les plafonds. Ils ne sont ni intangibles (b) ni réduits mécaniquement (c).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Conteneur avarié après un acheminement mer puis route : l'origine du dommage est encore inconnue. Quelle action préserve le mieux vos recours dès les premiers jours ?$mft$,
    $mft$[
      {"id":"a","label":"Notifier des réserves conservatoires à chaque substitué, chacun dans ses propres délais, sans attendre de connaître le maillon fautif","is_correct":true},
      {"id":"b","label":"Attendre le rapport d'expertise définitif avant toute notification","is_correct":false},
      {"id":"c","label":"Notifier uniquement le dernier transporteur routier, le plus facile à joindre","is_correct":false},
      {"id":"d","label":"Notifier uniquement l'armateur, le maritime étant toujours présumé fautif","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-2','qcm-v1'], 'COMM-M2-QCM-12', false,
    $mft$Tant que l'origine est inconnue, chaque recours doit être préservé dans les délais propres de chaque mode : on notifie tout le monde d'abord, on analyse ensuite. Attendre l'expertise (b) ou ne notifier qu'un maillon (c, d) sacrifie les autres recours.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l2, 'qr',
   $mft$Le transporteur aérien que vous avez substitué détruit un colis de votre client. Qui indemnise le client en premier, et que se passe-t-il ensuite ?$mft$,
   $mft$Le commissionnaire indemnise son client au titre de la garantie des substitués, puis exerce son recours contre le transporteur aérien fautif.$mft$,
   2, 'facile', ARRAY['commissionnaire','module-2','question-courte'], 'COMM-M2-QC-01', false,
   $mft$Un interlocuteur pour le client, un recours pour le commissionnaire.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Citez les quatre grandes obligations du commissionnaire envers son commettant.$mft$,
   $mft$Organiser le transport avec diligence (choix de substitués fiables), conseiller le client (mode, emballage, assurance ad valorem), exécuter ses instructions (contre-remboursement, livraison contre document) et rendre compte.$mft$,
   2, 'facile', ARRAY['commissionnaire','module-2','question-courte'], 'COMM-M2-QC-02', false,
   $mft$Les quatre obligations structurent tout le module.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un client veut vous assigner quatorze mois après la livraison pour un retard, sans acte interruptif entre-temps. Son action est-elle recevable ? Pourquoi ?$mft$,
   $mft$Non : les actions nées du contrat de commission se prescrivent par un an, comme en transport ; le délai est expiré.$mft$,
   2, 'facile', ARRAY['commissionnaire','module-2','question-courte'], 'COMM-M2-QC-03', false,
   $mft$Prescription annale du contrat de commission.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Une œuvre d'art de grande valeur part sans que vous ayez proposé d'assurance ad valorem. En cas de sinistre, que peut vous reprocher le client ?$mft$,
   $mft$Un manquement à votre devoir de conseil : faute personnelle du commissionnaire, sanctionnée, car la proposition d'assurance ad valorem (de préférence écrite) s'impose face à une marchandise de forte valeur.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-2','question-courte'], 'COMM-M2-QC-04', false,
   $mft$Le silence du professionnel est une faute ; l'écrit est sa protection.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Votre commettant a minoré le poids déclaré et omis la mention de dangerosité de son lot. Quelle obligation a-t-il violée et quelle en est la conséquence ?$mft$,
   $mft$Son obligation de fournir des informations exactes (nature, poids, dangerosité) : il engage sa responsabilité pour les dommages qui résultent de ses déclarations inexactes.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-2','question-courte'], 'COMM-M2-QC-05', false,
   $mft$Informations exactes : la première obligation du commettant.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Pourquoi dit-on que le client d'un commissionnaire « n'a qu'un interlocuteur » en cas de sinistre ?$mft$,
   $mft$Parce que le commissionnaire répond à la fois de ses fautes personnelles et des défaillances des transporteurs qu'il s'est substitués : le client l'actionne lui seul, à charge pour le commissionnaire de se retourner contre le maillon fautif.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-2','question-courte'], 'COMM-M2-QC-06', false,
   $mft$Double responsabilité = interlocuteur unique.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Une avarie apparaît sur le segment routier international (régime CMR) d'un dossier que vous avez organisé. Citez les deux réflexes qui préservent votre recours contre le transporteur.$mft$,
   $mft$Faire prendre des réserves à la livraison, puis agir contre le transporteur dans le délai d'un an prévu par la CMR.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-2','question-courte'], 'COMM-M2-QC-07', false,
   $mft$Réserves à la livraison + action dans l'année.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Vous organisez une expertise après une avarie sur une chaîne mer plus route. Qui devez-vous convoquer et pourquoi ?$mft$,
   $mft$Tous les maillons de la chaîne (armateur, transporteur routier, manutentionnaires le cas échéant) : l'expertise contradictoire rend ses conclusions opposables à chacun ; un maillon absent pourra les contester.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-2','question-courte'], 'COMM-M2-QC-08', false,
   $mft$Contradictoire = opposable.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Expliquez la formule : « le commissionnaire qui laisse filer un délai de recours paie sans recours ».$mft$,
   $mft$Il reste tenu envers son client au titre de la garantie des substitués, mais son action contre le transporteur fautif est éteinte si le délai propre à ce mode est dépassé : il supporte alors seul l'indemnisation, sans pouvoir la récupérer.$mft$,
   2, 'difficile', ARRAY['commissionnaire','module-2','question-courte'], 'COMM-M2-QC-09', false,
   $mft$La garantie survit, le recours meurt : l'écart finit au compte de résultat.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Conteneur avarié, origine du dommage inconnue : pourquoi notifier des réserves conservatoires à chaque substitué plutôt qu'au seul dernier transporteur ?$mft$,
   $mft$Parce que tant que le maillon fautif n'est pas identifié, chaque recours doit être préservé dans les délais propres à chaque mode : ne notifier qu'un seul maillon revient à perdre les autres recours si l'expertise désigne un autre responsable.$mft$,
   2, 'difficile', ARRAY['commissionnaire','module-2','question-courte'], 'COMM-M2-QC-10', false,
   $mft$Notifier tout le monde d'abord, analyser ensuite.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ─────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Expliquez le devoir de conseil du commissionnaire à travers trois situations concrètes (choix du mode, emballage, assurance ad valorem), puis précisez ce qu'il risque en cas de silence et comment il se protège.$mft$,
   $mft$Réponse modèle. Le commissionnaire est le professionnel du transport face à un client qui, souvent, ne l'est pas : il doit conseiller. Choix du mode : pour une marchandise urgente ou fragile, il recommande le mode adapté (délai, sensibilité, valeur), au lieu d'appliquer mécaniquement la solution la moins chère. Emballage : s'il constate un conditionnement insuffisant pour le trajet prévu, il alerte le client par écrit et recommande un emballage adapté ; charger sans rien dire, c'est endosser le risque. Assurance ad valorem : lorsque la valeur de la marchandise dépasse ce que les plafonds d'indemnisation permettraient de récupérer, il propose une assurance ad valorem, de préférence par écrit. En cas de silence, le devoir de conseil étant sanctionné, le commissionnaire engage sa responsabilité personnelle : le client indemnisé au seul plafond lui reprochera de ne pas l'avoir éclairé. Protection : la trace écrite. Un conseil formulé par courriel et refusé par le client renverse la charge : le refus documenté devient la meilleure défense du commissionnaire.$mft$,
   $mft$Barème /5 : trois situations concrètes correctement traitées (3 pts, 1 pt chacune) ; sanction du silence : responsabilité personnelle (1 pt) ; protection par l'écrit (refus documenté) (1 pt). Erreurs fréquentes : rester sur « il doit conseiller » sans situations concrètes ; oublier que le conseil oral non prouvé ne protège pas.$mft$,
   5, 'facile', ARRAY['commissionnaire','module-2','question-redigee'], 'COMM-M2-QR-01', false,
   $mft$Le devoir de conseil en situations, sa sanction et sa preuve.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$« Le client d'un commissionnaire n'a qu'un interlocuteur. » Expliquez la double responsabilité du commissionnaire (fait personnel et garantie des substitués) et illustrez chaque volet par un exemple.$mft$,
   $mft$Réponse modèle. Le commissionnaire répond sur deux fondements distincts. Premier volet : la responsabilité du fait personnel, pour ses fautes propres : mauvais choix de transporteur (confier un lot à un sous-traitant non assuré ou notoirement défaillant), défaut de conseil (ne pas proposer d'assurance ad valorem pour une marchandise de forte valeur), erreur documentaire ou instruction mal transmise. Exemple : un commissionnaire qui oublie de transmettre la consigne de livraison contre document répond de sa propre négligence. Second volet : la garantie du fait des substitués : il répond envers son client des avaries, pertes et retards causés par les transporteurs qu'il s'est substitués, à charge de recours contre eux. Exemple : le transporteur routier choisi perd deux palettes ; le client se retourne vers son commissionnaire, qui l'indemnise puis exerce son recours contre le routier. Intérêt pour le client : il n'a ni à identifier le maillon fautif ni à poursuivre un armateur lointain : un seul interlocuteur, son commissionnaire, porte juridiquement l'ensemble de la chaîne.$mft$,
   $mft$Barème /5 : fait personnel défini avec des exemples de fautes propres (1,5 pt) ; garantie des substitués définie avec la notion de recours (1,5 pt) ; un exemple pertinent par volet (1 pt) ; intérêt pour le client : interlocuteur unique (1 pt). Erreurs fréquentes : confondre les deux fondements ; oublier la mention « à charge de recours ».$mft$,
   5, 'facile', ARRAY['commissionnaire','module-2','question-redigee'], 'COMM-M2-QR-02', false,
   $mft$La double responsabilité expliquée et illustrée.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Cas chiffré. Une presse industrielle de 60 000 euros, sans assurance ad valorem, est détruite par la faute du transporteur routier que vous avez substitué. Par hypothèse, les plafonds applicables à ce transporteur limitent l'indemnité récupérable à 18 000 euros. Déterminez ce que vous devez à votre client, d'abord sans faute personnelle de votre part, puis dans l'hypothèse où vous n'avez jamais proposé l'assurance ad valorem.$mft$,
   $mft$Réponse modèle. Premier temps, sans faute personnelle : la garantie des substitués est plafonnée par référence aux plafonds applicables au transporteur substitué. Vous devez donc au client une indemnité calée sur les 18 000 euros récupérables auprès du routier : le principe est que le commissionnaire ne doit pas payer plus que ce qu'il peut récupérer. Vous indemnisez, puis exercez votre recours contre le transporteur. Second temps, avec défaut de conseil : ne jamais avoir proposé d'assurance ad valorem pour une machine de 60 000 euros constitue une faute personnelle. Le client peut alors rechercher votre responsabilité propre pour le préjudice causé par le conseil manqué : la différence entre la valeur perdue et l'indemnité plafonnée, soit ici 42 000 euros, en tout ou partie selon l'appréciation du juge. Votre responsabilité personnelle connaît ses propres plafonds (montants du contrat type commission à vérifier), écartés en cas de faute lourde ou dolosive. Leçon du cas : la proposition écrite d'assurance, acceptée ou refusée, aurait fermé ce second front.$mft$,
   $mft$Barème /5 : garantie plafonnée par référence au substitué, indemnité calée sur 18 000 euros (1,5 pt) ; logique « ne pas payer plus que ce que l'on récupère » et recours (1 pt) ; défaut de conseil ouvrant la responsabilité personnelle sur le différentiel (1,5 pt) ; nuances : plafonds propres à vérifier, faute lourde ou dolosive, valeur de l'écrit (1 pt). Erreurs fréquentes : faire payer 60 000 euros au commissionnaire sans faute personnelle ; ignorer le recours contre le transporteur.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-2','question-redigee'], 'COMM-M2-QR-03', false,
   $mft$Cas chiffré : plafonds de la garantie et front du défaut de conseil.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Procédure. Décrivez, étape par étape et dans l'ordre, la chaîne des recours après une avarie constatée par le destinataire final sur un dossier que vous avez organisé (segment maritime puis routier), en précisant les délais à surveiller à chaque étape.$mft$,
   $mft$Réponse modèle. Étape 1 : le destinataire prend des réserves écrites, précises et immédiates à la livraison ; sans elles, tout le dossier s'affaiblit. Étape 2 : le client notifie sa réclamation au commissionnaire ; les actions nées du contrat de commission se prescrivent par un an, comme en transport. Étape 3 : le commissionnaire, sans attendre d'identifier le maillon fautif, notifie des réserves conservatoires à chaque substitué dans les délais propres à chaque mode : en maritime, des délais très courts (trois jours souvent cités, à vérifier selon le régime applicable) ; en routier international sous CMR, réserves à la livraison puis action dans le délai d'un an. Étape 4 : expertise contradictoire convoquant tous les maillons, puis chiffrage (valeur de la perte, plafonds applicables par segment). Étape 5 : indemnisation du client, puis recours contre le ou les responsables désignés. En parallèle : conservation des documents de transport de chaque segment (connaissement, CMR, réserves, photos, correspondances). Sans preuves ni délais tenus, le commissionnaire paie sans recours.$mft$,
   $mft$Barème /5 : réserves immédiates du destinataire (0,5 pt) ; réclamation du client et prescription annale de la commission (1 pt) ; notifications conservatoires à chaque substitué dans les délais propres à chaque mode, avec prudence sur le délai maritime (1,5 pt) ; expertise contradictoire et chiffrage par segment (1 pt) ; indemnisation puis recours et conservation des preuves (1 pt). Erreurs fréquentes : attendre l'expertise pour notifier ; croire que le délai d'un an du client couvre aussi les recours contre les substitués.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-2','question-redigee'], 'COMM-M2-QR-04', false,
   $mft$La chaîne des recours ordonnée avec ses délais.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Plan d'action. Ce matin, le destinataire final de votre commettant découvre un conteneur avarié (cartons écrasés et mouillés) à la livraison. Rédigez votre plan d'action des huit premiers jours, dans l'ordre, avec l'objectif de chaque action.$mft$,
   $mft$Réponse modèle. Jour J : faire confirmer les réserves écrites, précises et immédiates du destinataire sur le document de livraison, avec photos ; objectif : figer l'état de la marchandise. Jour J également : ouverture du dossier, information du commettant, conservation de la marchandise en l'état (rien jeter, rien réparer). J+1 à J+3 : notifications conservatoires à chaque substitué (armateur, routier, manutentionnaire le cas échéant), chacun dans ses propres délais, les délais maritimes étant très courts ; objectif : préserver tous les recours tant que l'origine du dommage est inconnue. J+2 à J+8 : organisation d'une expertise contradictoire, tous les maillons convoqués par écrit ; objectif : des conclusions opposables à chacun. En parallèle : collecte des documents de chaque segment (connaissement, CMR, bons de livraison) et premier chiffrage : valeur de la perte, plafonds applicables par segment. En fin de période : point avec le client sur le calendrier d'indemnisation et les recours envisagés. Les trois pièges à éviter : réserves tardives, expertise non contradictoire, délai de notification manqué.$mft$,
   $mft$Barème /5 : réserves immédiates et conservation en l'état (1 pt) ; notifications conservatoires à chaque substitué dans ses délais (1,5 pt) ; expertise contradictoire avec convocation écrite de tous les maillons (1 pt) ; preuves et chiffrage par segment (1 pt) ; information du client et pièges identifiés (0,5 pt). Erreurs fréquentes : notifier le seul dernier transporteur ; laisser le destinataire jeter la marchandise avant expertise.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-2','question-redigee'], 'COMM-M2-QR-05', false,
   $mft$Plan d'action J0 à J+8 sur le cas fil rouge.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Analyse. Votre commettant a déclaré 12 tonnes de « pièces métalliques » ; le lot pèse en réalité 17 tonnes et contient des bombes aérosols non signalées. Un incident de chargement survient chez le transporteur substitué. Analysez les responsabilités croisées : ce que le commettant a violé, ce que l'on pourrait vous reprocher, et comment vous auriez dû traiter le dossier.$mft$,
   $mft$Réponse modèle. Côté commettant : il a violé son obligation de fournir des informations exactes sur la nature, le poids et la dangerosité de la marchandise. Cette double inexactitude (poids minoré, dangerosité dissimulée) engage sa responsabilité pour les dommages qui en résultent : incident de chargement, surcharge, mise en danger. Côté commissionnaire : on pourrait rechercher une faute personnelle si des indices visibles auraient dû l'alerter (documents incohérents, conditionnement révélateur, valeur sans rapport avec le poids annoncé) et qu'il n'a posé aucune question : la diligence professionnelle ne se limite pas à recopier les déclarations du client. En revanche, si rien ne permettait de déceler la fraude, le commissionnaire n'a pas à répondre de déclarations mensongères qu'il ne pouvait pas vérifier. Traitement correct du dossier : questionnaire d'expédition précis (nature exacte, poids vérifiable, matières dangereuses), demande de documents complémentaires en cas de doute, refus ou régularisation avant départ si l'incohérence persiste, et trace écrite de chaque échange : cette traçabilité départage les responsabilités le jour de l'incident.$mft$,
   $mft$Barème /5 : violation par le commettant de l'obligation d'informations exactes, avec ses deux volets (1,5 pt) ; conséquence : responsabilité du commettant pour les dommages résultants (1 pt) ; analyse nuancée de la position du commissionnaire selon les indices décelables (1,5 pt) ; traitement correct : questionnaire, vérifications, écrit (1 pt). Erreurs fréquentes : exonérer totalement le commissionnaire par principe ; ou l'accabler alors que la fraude était indécelable.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-2','question-redigee'], 'COMM-M2-QR-06', false,
   $mft$Responsabilités croisées autour d'une déclaration mensongère.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Comparez deux dossiers identiques d'avarie maritime de 30 000 euros. Dossier A : réserves prises à la livraison, notification à l'armateur dès le premier jour, action engagée dans les délais. Dossier B : réserves tardives et notification à l'armateur après l'expiration de ses délais. Comparez le dénouement financier des deux dossiers pour le commissionnaire et tirez-en les règles d'organisation d'un service litiges.$mft$,
   $mft$Réponse modèle. Dossier A : le client actionne le commissionnaire dans l'année ; celui-ci l'indemnise au titre de la garantie des substitués, dans la limite des plafonds applicables à l'armateur, puis récupère l'indemnité par son recours : l'opération est financièrement à peu près neutre, hors temps passé et franchise éventuelle. Dossier B : la garantie envers le client demeure, le commissionnaire indemnise. Mais son recours contre l'armateur est éteint, les délais maritimes, très courts (trois jours souvent cités pour les réserves, à vérifier), étant dépassés : il paie sans recours et supporte seul la charge, dans la limite des plafonds. La différence entre A et B ne tient ni au fond du droit ni aux faits : elle tient à la gestion des délais. Règles d'organisation : un registre des délais par dossier et par mode, alimenté dès l'ouverture ; des alertes avant échéance ; des modèles de notification prêts à partir ; la conservation systématique des documents de chaque segment ; et un réflexe : notifier d'abord, analyser ensuite. La gestion des délais est un métier : elle sépare un dossier remboursé d'une perte sèche.$mft$,
   $mft$Barème /5 : dénouement du dossier A : indemnisation puis récupération par recours (1,5 pt) ; dénouement du dossier B : garantie maintenue mais recours éteint, perte sèche (1,5 pt) ; identification de la cause : gestion des délais et non le fond du droit (0,5 pt) ; règles d'organisation concrètes : registre, alertes, modèles, preuves (1,5 pt). Erreurs fréquentes : croire que la garantie envers le client tombe aussi dans le dossier B ; proposer des règles vagues sans outillage concret.$mft$,
   5, 'difficile', ARRAY['commissionnaire','module-2','question-redigee'], 'COMM-M2-QR-07', false,
   $mft$Deux dossiers, deux dénouements : la valeur de la gestion des délais.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Plan d'action contractuel. Vous reprenez le portefeuille clients d'un commissionnaire dont les contrats ne comportent ni plafond ni trace des conseils donnés. Construisez le dispositif contractuel et documentaire à mettre en place avec les clients pour maîtriser votre exposition en cas de litige, et justifiez chaque élément.$mft$,
   $mft$Réponse modèle. Premier chantier : les plafonds. Insérer dans les conditions contractuelles des plafonds d'indemnisation pour la responsabilité personnelle du commissionnaire, cohérents avec les contrats types applicables (montants à vérifier), en rappelant que la garantie des substitués reste calée sur les plafonds des transporteurs : le client sait ce qu'il récupérerait dans chaque scénario. Deuxième chantier : le conseil tracé. Systématiser la proposition écrite d'assurance ad valorem dès que la valeur déclarée dépasse ce que les plafonds couvriraient, avec acceptation ou refus signé du client : le refus documenté est la meilleure défense contre un grief de défaut de conseil. Troisième chantier : l'information sur les limites. Annexer une notice claire sur les plafonds par mode et sur les délais de réclamation, et prévoir une procédure : réserves immédiates, notification rapide, conservation de la marchandise en l'état pour l'expertise contradictoire. Justification d'ensemble : sauf faute lourde ou dolosive, ce dispositif borne l'exposition, transforme le devoir de conseil en preuve écrite et accélère les litiges : chacun connaît les règles avant le sinistre, pas après.$mft$,
   $mft$Barème /5 : plafonds contractuels pour la responsabilité personnelle, avec prudence sur les montants (1,5 pt) ; proposition d'assurance ad valorem écrite avec acceptation ou refus signé (1,5 pt) ; information sur les limites et procédure de réclamation (réserves, délais, expertise) (1,5 pt) ; réserve de la faute lourde ou dolosive qui écarte les plafonds (0,5 pt). Erreurs fréquentes : promettre une exonération totale de responsabilité ; oublier que la garantie des substitués reste calée sur les plafonds des transporteurs.$mft$,
   5, 'difficile', ARRAY['commissionnaire','module-2','question-redigee'], 'COMM-M2-QR-08', false,
   $mft$Le dispositif contractuel qui prépare la défense avant le sinistre.$mft$);

  RAISE NOTICE 'Module 2 Commissionnaire créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $commm2$;
