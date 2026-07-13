-- =====================================================================
-- COMMISSIONNAIRE DE TRANSPORT : MODULE 5 : GESTION, AFFRÈTEMENT
-- ET ASSURANCES : v1 (juillet 2026)
-- Coter et marger (achat, groupage, poids taxable, devise), affréter
-- en conformité (vigilance, sous-traitance saine), les trois étages
-- d'assurance et le devoir de conseil, trésorerie (débours, BFR)
-- et pilotage (marge par dossier, litiges, OTIF).
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $commm5$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'COMM-M5-%';
  DELETE FROM public.modules WHERE slug = 'comm-gestion-assurances';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 5 : Gestion, affrètement et assurances',
    'comm-gestion-assurances', v_bloc,
    'Coter et marger, affréter des transporteurs en toute conformité, assurer les marchandises et piloter la trésorerie spécifique du commissionnaire.',
    'avance', 330, 50) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 50, true);

  -- ─── Leçon 1 : Coter et marger ──────────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'coter-et-marger',
    'Coter et marger : le modèle économique du dossier',
    $mft$> 🎯 **Objectifs**
> - Décomposer le prix d'un dossier : achat de transport, prestations propres, marge.
> - Coter juste : coûts d'achat réels, effet groupage et poids taxable, risque devise.
> - Piloter la marge par dossier ET par client, et verrouiller le périmètre du devis.

## Ce que vend réellement le commissionnaire

Le commissionnaire ne vend pas des kilomètres : il vend une opération organisée de bout en bout. Son prix se décompose en trois blocs : l'**achat de transport** (le fret payé aux transporteurs routiers, aux compagnies maritimes ou aériennes, aux co-chargeurs), les **prestations propres** facturées en plus (formalités douanières, documentation, assurance souscrite pour le compte du client, coordination), et la **marge**, qui rémunère l'ingénierie du dossier et le risque porté. Conséquence directe : la marge se construit autant à l'achat qu'à la vente. Un dossier mal acheté est déjà un dossier perdu, quel que soit le talent du commercial.

## Acheter juste : le socle de la cotation

Deux grandes sources d'achat coexistent, avec des logiques opposées :

| Source d'achat | Fonctionnement | Usage typique |
| --- | --- | --- |
| Bourses de fret | Prix spot, négociés au coup par coup, volatils | Flux ponctuels, dépannages de capacité |
| Contrats de capacité | Prix et volumes garantis sur la durée | Flux réguliers, sécurisation des pointes |

Coter sur des prix « de mémoire » expose à vendre en dessous de son coût réel : la cotation part toujours des coûts d'achat **actualisés** (spot du jour, surcharges en vigueur, coût des prestations sous-traitées).

:::flow
1. Qualifier | Marchandise, poids et volume, origine-destination, délai, contraintes
2. Chiffrer l'achat | Fret réel (contrat ou spot), surcharges, prestations sous-traitées
3. Ajouter les prestations | Douane, documentation, assurance proposée par écrit
4. Poser la marge | Objectif du dossier, cohérence avec la marge annuelle du client
5. Verrouiller le devis | Inclus et exclus listés, devise, validité, conditions
:::

## L'effet groupage et le poids taxable

Le groupage est le levier de marge historique du métier : acheter un camion ou un conteneur complet, et le revendre en lots à plusieurs clients. Sa rentabilité repose sur le **remplissage** et sur la règle du **poids taxable** : on facture le plus élevé du poids réel et de l'équivalent volume, selon des équivalences d'usage :

| Mode | Équivalence usuelle |
| --- | --- |
| Maritime | 1 tonne = 1 m3 |
| Aérien | 1 tonne = 6 m3 |
| Route (groupage) | 1 tonne = 3 m3 (usage répandu, à vérifier dans les conditions générales de chaque opérateur) |

> 🔍 **Focus**
> Sans poids taxable, un client expédierait dix mètres cubes de coussins pour le prix de 80 kg : le camion serait plein et la recette vide. Ces équivalences sont des usages professionnels : le ratio réellement applicable est celui écrit dans vos conditions et dans celles de vos fournisseurs, à vérifier systématiquement, en particulier en groupage routier.

## Le risque devise

Sur l'international, on achète souvent en dollars (fret maritime, surcharges) et on vend en euros. Entre la cotation et le paiement, le cours bouge : une hausse du dollar ronge une marge cotée trop juste.

> ⚠️ **Attention**
> Trois parades usuelles : une marge de sécurité sur les dossiers à échéance lointaine, une clause d'ajustement devise dans le devis, ou une couverture de change sur les gros volumes. Le pire choix : ignorer le sujet et découvrir la perte au paiement.

## Marge par dossier ET marge par client

La marge par dossier détecte les opérations perdantes dès l'ouverture ; la marge par client révèle la réalité commerciale. Un client au tarif serré mais aux volumes réguliers qui remplissent vos groupages peut être plus précieux qu'un client à belle marge unitaire mais imprévisible : c'est la marge annuelle par client qui doit guider les renégociations.

## Le devis : un périmètre au cordeau

Le flou se paie en litiges. Un devis professionnel liste par écrit les prestations **incluses** et **exclues** (frais d'inspection, de magasinage, de scanner, surestaries), la devise, la durée de validité et les conditions applicables.

> ❌ **Piège à éviter**
> « Formalités comprises » sans liste détaillée : le jour où surgissent des frais d'inspection ou de magasinage, chacun estime que c'est à l'autre de payer : contestation, avoir commercial, marge détruite.

## ✅ Synthèse

- Prix = **achat de transport + prestations propres + marge** : la marge se gagne d'abord à l'achat.
- Groupage : facturer au **poids taxable** (le plus élevé du réel et de l'équivalent volume) ; équivalences d'usage à vérifier au contrat.
- International : traiter le **risque devise** ; pilotage : marge par dossier ET par client.
- Devis : inclus et exclus **écrits** : le flou se paie en litiges.$mft$,
    $mft$Le prix du dossier (achat + prestations + marge), la cotation sur coûts réels, le poids taxable du groupage (équivalences par mode), le risque devise, la marge par dossier et par client, le devis à périmètre précis.$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Affréter en toute conformité ─────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'affreter-conforme',
    'Affréter en toute conformité : choisir et contrôler ses transporteurs',
    $mft$> 🎯 **Objectifs**
> - Dérouler les vérifications obligatoires avant de confier un transport.
> - Mesurer votre exposition quand un sous-traitant défaille ou travaille illégalement.
> - Construire une politique de sous-traitance saine et durable.

## Affréter, c'est répondre de son choix

Le commissionnaire exécute par d'autres, mais son client ne connaît que lui. Choisir un transporteur n'est donc jamais un simple acte d'achat : c'est un engagement dont vous répondez. Le droit sanctionne la **faute dans le choix** (culpa in eligendo) : confier un lot à un transporteur dont vous auriez dû détecter l'incapacité ou l'illégalité, c'est déjà une faute qui vous est propre, indépendamment de celle du transporteur.

## Les vérifications obligatoires du donneur d'ordre

| Vérification | Contenu | Rythme |
| --- | --- | --- |
| Habilitation professionnelle | Licence et inscription du transporteur au registre | Au référencement, puis suivi de validité |
| Attestations sociales | Attestation de vigilance URSSAF : dispositif de lutte contre le travail dissimulé | Tous les 6 mois au-delà des seuils |
| Assurance | Attestation d'assurance en cours de validité | Au référencement, puis à chaque échéance |

> 📌 **À retenir**
> Ces vérifications ne sont pas un luxe administratif : elles constituent le devoir de vigilance du donneur d'ordre. Un dossier de référencement complet et daté est aussi votre meilleure pièce de défense le jour où un affrété se révèle défaillant.

## Quand le sous-traitant défaille ou triche

Si le transporteur choisi abandonne le lot, perd la marchandise ou se révèle en situation de travail dissimulé, votre exposition est triple :

- **responsabilité du choix** : vous répondez d'avoir sélectionné (ou conservé) un prestataire dont les signaux d'alerte étaient visibles ;
- **solidarités sociales possibles** : le donneur d'ordre qui n'a pas exercé sa vigilance peut être appelé à payer des cotisations et dettes sociales du sous-traitant fraudeur ;
- **dommage commercial** : c'est VOTRE client qui subit l'incident, et votre nom qui est sur le dossier.

## Le prix qui permet la conformité

Un prix d'achat anormalement bas n'est pas une aubaine : c'est un signal. À 40 % sous le marché, le transporteur ne peut pas payer correctement ses conducteurs, entretenir ses véhicules et respecter les temps de conduite. Le jour où la fraude éclate, elle éclabousse le donneur d'ordre qui en a profité.

> ❌ **Piège à éviter**
> Accepter systématiquement le moins-disant en se disant « ses obligations ne me regardent pas ». Elles vous regardent : la vigilance est votre obligation légale, et le différentiel de prix sera retenu comme un indice que vous ne pouviez pas ignorer.

## Une charte de sous-traitance saine

La conformité se construit dans la durée, pas au coup par coup :

:::flow
1. Identifier | Besoin de capacité, présélection sur spécialité et réputation
2. Collecter | Licence, attestation de vigilance URSSAF, attestation d'assurance
3. Contrôler | Authenticité, dates de validité, cohérence du prix avec la conformité
4. Contractualiser | Conditions d'affrètement, sous-affrètement interdit sans accord écrit
5. Suivre | Renouvellement des attestations, taux de litige, revue périodique
:::

Fidéliser sa capacité est un investissement : des volumes réguliers, des prix qui permettent de travailler proprement et des paiements à l'heure attachent les bons transporteurs. En période de pénurie de capacité, ce sont vos affrétés fidèles qui vous sauvent, pas la bourse de fret.

## Le sous-affrètement en cascade

Dernier point de contrôle : savoir QUI roule réellement. Le sous-affrètement en cascade (votre affrété recède le transport à un autre, qui recède à son tour) vous fait perdre toute maîtrise : vous ne connaissez ni la licence, ni l'assurance, ni la conformité sociale de celui qui transporte. L'encadrement du double affrètement abusif existe, sa portée exacte restant à vérifier dans les textes applicables ; contractuellement, la parade est simple et doit être systématique : interdiction de sous-affréter sans votre accord écrit, avec déréférencement à la clé.

> 💡 **Astuce**
> Contrôle simple et dissuasif : comparer l'immatriculation du véhicule qui se présente au chargement avec celle du transporteur référencé. Un écart non annoncé déclenche un appel immédiat à l'affrété.

## ✅ Synthèse

- Vérifications obligatoires : **licence/registre, attestations sociales (vigilance URSSAF, 6 mois au-delà des seuils), assurance**.
- Sous-traitant défaillant ou illégal : **faute dans le choix + solidarités sociales possibles** : votre dossier de vigilance est votre défense.
- Un **prix anormalement bas** est un signal d'alerte, pas une aubaine.
- Sous-affrètement : **jamais sans accord écrit** ; fidéliser sa capacité paie plus que le moins-disant.$mft$,
    $mft$Les vérifications obligatoires du donneur d'ordre (licence, vigilance URSSAF semestrielle au-delà des seuils, assurance), la responsabilité du choix et les solidarités sociales, le prix anormalement bas comme signal, la charte de sous-traitance et le contrôle du sous-affrètement en cascade.$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Les trois étages de l'assurance ──────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'assurances',
    'Les trois étages de l''assurance et le devoir de conseil',
    $mft$> 🎯 **Objectifs**
> - Distinguer les trois étages d'assurance d'un dossier et leurs logiques.
> - Savoir quand et comment proposer l'assurance ad valorem : par écrit, à chaque dossier sensible.
> - Connaître les limites : franchises et exclusions classiques.

## Trois étages, trois logiques

La confusion entre « assurances » coûte très cher. Un dossier de commission mobilise trois couvertures distinctes, qui ne protègent ni les mêmes personnes ni les mêmes intérêts :

| Étage | Qui souscrit | Ce qui est couvert | Limites |
| --- | --- | --- | --- |
| RC du transporteur | Le transporteur | SA responsabilité, quand elle est engagée | Indemnisation plafonnée, causes d'exonération |
| RC professionnelle du commissionnaire | Le commissionnaire | Ses fautes propres et sa garantie des transporteurs substitués | Franchises et plafonds de police |
| Assurance marchandises ad valorem | Le commissionnaire pour le compte du client (ou le client lui-même) | La VALEUR réelle de la marchandise | Franchise, exclusions de police |

> ❌ **Piège à éviter**
> Dire au client « le transport est assuré ». La RC du transporteur assure le transporteur, pas la marchandise : elle suppose que sa responsabilité soit établie, et elle indemnise dans la limite de plafonds souvent très inférieurs à la valeur des biens. Le client qui croit sa marchandise couverte découvre l'écart le jour du sinistre.

## L'ad valorem : couvrir la valeur, pas la faute

L'assurance marchandises dite ad valorem renverse la logique : elle couvre les **dommages à la marchandise pour sa valeur réelle**, sans plafond de responsabilité et sans que le client ait à prouver une faute de quiconque. Souscrite dossier par dossier ou par police d'abonnement, elle est proposée par le commissionnaire **pour le compte de son client**, et refacturée comme une prestation.

> 🔍 **Focus**
> Deux formules classiques : la garantie « tous risques » (dommages et pertes, sauf exclusions) et la garantie « FAP sauf » (franc d'avaries particulières sauf), qui ne couvre les avaries que si elles résultent d'événements limitativement énumérés. Le choix se raisonne selon la marchandise, le trajet et le budget du client.

## Le devoir de conseil : proposer PAR ÉCRIT

Le cœur du métier est là. Sur chaque **dossier sensible** (valeur de la marchandise supérieure aux plafonds d'indemnisation du transporteur, marchandise fragile, trajet risqué), le commissionnaire doit **proposer l'assurance ad valorem par écrit** : ligne dédiée du devis, montant de la prime, et trace de la réponse du client.

- Le client **accepte** : la marchandise est couverte à sa valeur, la prime est facturée.
- Le client **refuse par écrit** : il a fait un choix éclairé ; en cas de sinistre au-delà des plafonds, la différence reste à sa charge.
- Le commissionnaire **n'a rien proposé** : le défaut de proposition est une faute de conseil ; c'est alors sa RC professionnelle qui sera recherchée pour la différence entre la valeur réelle et l'indemnité plafonnée.

> 📌 **À retenir**
> Le refus écrit du client vaut autant que son acceptation : il prouve que le conseil a été donné. La proposition orale, elle, n'existe pas le jour du litige.

## Franchises et exclusions : lire la police

Aucune police ne couvre tout. Deux exclusions classiques reviennent dans la plupart des contrats marchandises :

- l'**emballage insuffisant ou inadapté** : la marchandise fragile expédiée sans calage adapté n'est pas garantie ;
- le **vice propre** : la marchandise qui se détériore par sa propre nature (denrée qui fermente, métal qui s'oxyde) n'est pas un dommage assurable.

S'y ajoute la **franchise**, part du dommage restant à la charge de l'assuré : elle se lit AVANT le sinistre, pas après.

> 💡 **Astuce**
> Faites de la proposition d'assurance une ligne standard de tous vos devis, avec deux cases : « acceptée » ou « refusée ». Le réflexe devient automatique, la preuve aussi, et la prestation dégage au passage une marge récurrente.

## ✅ Synthèse

- Trois étages : **RC transporteur** (sa responsabilité, plafonnée), **RC pro du commissionnaire** (ses fautes, sa garantie des substitués), **ad valorem** (la valeur réelle, pour le compte du client).
- Devoir de conseil : proposer l'ad valorem **par écrit à chaque dossier sensible** ; le défaut de proposition coûte la différence.
- Lire la police : **franchise** et exclusions classiques (**emballage insuffisant, vice propre**).$mft$,
    $mft$Les trois étages (RC transporteur plafonnée, RC professionnelle du commissionnaire, assurance marchandises ad valorem pour le compte du client), le devoir de conseil par écrit sur les dossiers sensibles, franchises et exclusions classiques (emballage insuffisant, vice propre).$mft$,
    3, 45) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Trésorerie et pilotage ───────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'tresorerie-et-pilotage',
    'Trésorerie et pilotage : les spécificités financières du métier',
    $mft$> 🎯 **Objectifs**
> - Comprendre pourquoi la trésorerie du commissionnaire est structurellement tendue.
> - Sécuriser les débours et les encours clients.
> - Construire le tableau de bord de pilotage : marge, litiges, qualité.

## Le commissionnaire avance l'argent des autres

Spécificité financière du métier : le commissionnaire **avance** avant d'encaisser. Il paie le fret à ses transporteurs, et règle pour le compte de ses clients des sommes qui ne lui appartiennent pas : droits de douane, TVA le cas échéant. Ces avances sont les **débours**, refacturés au client. Or le client paie à 30 ou 60 jours :

:::timeline
1. **Jour J** : le dossier s'exécute : vous engagez le fret et réglez les débours (droits de douane, TVA le cas échéant).
2. **J + quelques jours** : vous facturez le client : fret, prestations propres, débours refacturés.
3. **J + 30 à 60 jours** : le client règle : entre-temps, votre trésorerie a porté l'intégralité du dossier.
:::

## Le BFR : la rançon de la croissance

Ce décalage permanent entre décaissements et encaissements forme le **besoin en fonds de roulement** (BFR). Paradoxe à comprendre absolument : plus l'activité croît, plus la trésorerie se tend, car chaque nouveau dossier ajoute son avance au stock d'avances en cours. Une entreprise **rentable** peut ainsi mourir **insolvable**.

> ⚠️ **Attention**
> Le scénario classique de défaillance du commissionnaire n'est pas la mévente : c'est le gros client gagné, avec de lourds débours de douane et un paiement à 60 jours, qui assèche la trésorerie pendant que le compte de résultat affiche de beaux dossiers rentables.

## Sécuriser : conditions d'intervention et encours

- **Conditions d'intervention** : sur les dossiers à forts débours, exiger le paiement des débours **d'avance**, ou des garanties, avant d'engager les fonds.
- **Encours par client** : fixer un plafond d'encours, le suivre en temps réel, et le couvrir par une **assurance-crédit** qui indemnise en cas de défaillance du client.
- **Sûretés** : la profession invoque un privilège sur les marchandises détenues, en garantie des créances ; les conditions exactes d'exercice de cette garantie restent à vérifier selon les conditions de vente et les textes applicables : ne jamais bâtir sa sécurité financière sur ce seul mécanisme.
- **Discipline de facturation et de relance** : facturer le jour du dossier (pas en fin de mois), relancer dès le premier jour de retard.

## Piloter : le tableau de bord du commissionnaire

Le pilotage transforme la comptabilité en outil de décision. Six indicateurs forment le socle :

| Indicateur | Ce qu'il révèle | Fréquence |
| --- | --- | --- |
| Marge par dossier (temps réel) | Les dossiers perdants, dès l'ouverture | Continue |
| Marge annuelle par client | La vraie valeur de chaque relation | Mensuelle |
| Litiges provisionnés | Le coût réel des sinistres en cours | Mensuelle |
| Taux de litige par transporteur | Le mauvais transporteur coûte sa marge | Mensuelle |
| OTIF par client | La qualité perçue : à l'heure ET complet | Mensuelle |
| Encours et retards clients | Le risque d'impayé qui se forme | Hebdomadaire |

> 💡 **Astuce**
> Le taux de litige par transporteur est l'indicateur le plus rentable du tableau : un affrété 5 % moins cher mais générateur de litiges à répétition coûte, en indemnités non récupérées et en temps de gestion, bien plus que son avantage tarifaire. Le calcul en coût complet tranche en quelques lignes.

> 🎓 **Pour l'examen**
> Sachez restituer la chaîne logique : débours avancés + paiement client à 30-60 jours = BFR sensible ; sécurisation par conditions d'intervention, plafonds d'encours et assurance-crédit ; pilotage par marge par dossier ET par client, litiges provisionnés, taux de litige par transporteur et OTIF.

## ✅ Synthèse

- Le commissionnaire **avance** (fret, débours : douane, TVA le cas échéant) et encaisse à **30-60 jours** : BFR structurellement sensible.
- Sécuriser : **débours d'avance ou garanties, plafonds d'encours, assurance-crédit**, facturation et relance disciplinées.
- Piloter : **marge par dossier en temps réel et par client, litiges provisionnés, taux de litige par transporteur, OTIF**.
- Rentable ne veut pas dire solvable : la croissance se **finance**.$mft$,
    $mft$Les débours avancés (fret, douane, TVA le cas échéant) face au paiement client à 30-60 jours, le BFR qui croît avec l'activité, la sécurisation (débours d'avance, encours, assurance-crédit) et le tableau de bord (marge par dossier et par client, litiges, taux de litige par transporteur, OTIF).$mft$,
    4, 45) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Gestion, affrètement et assurances',
    'Vérifiez le module 5 : cotation et marge, affrètement conforme, assurances et trésorerie du commissionnaire.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un client vous demande une cotation en groupage aérien pour une caisse de 250 kg occupant 3 m3. Selon l'usage du fret aérien (1 tonne = 6 m3), sur quelle base taxable cotez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"500 kg : l'équivalent volume (3 m3) dépasse le poids réel, on retient le plus élevé des deux","is_correct":true},
      {"id":"b","label":"250 kg : le poids réel s'applique toujours, quel que soit le volume","is_correct":false},
      {"id":"c","label":"3 000 kg : chaque mètre cube vaut une tonne","is_correct":false},
      {"id":"d","label":"125 kg : la moitié du poids réel, par usage commercial","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-5','qcm-v1'], 'COMM-M5-QCM-01', false,
    $mft$En aérien, 3 m3 équivalent à 500 kg taxables (1 t = 6 m3) : on facture le plus élevé du poids réel et de l'équivalent volume, sinon le volumineux léger voyagerait à perte. Le ratio 1 tonne = 1 m3 est l'usage maritime, pas aérien.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Votre client expédie des équipements électroniques dont la valeur dépasse très largement les plafonds d'indemnisation du transporteur. Que devez-vous lui proposer ?$mft$,
    $mft$[
      {"id":"a","label":"Une assurance marchandises ad valorem souscrite pour son compte, proposée par écrit","is_correct":true},
      {"id":"b","label":"Rien : la RC du transporteur couvrira la valeur réelle","is_correct":false},
      {"id":"c","label":"Votre RC professionnelle, qui indemnisera automatiquement le client","is_correct":false},
      {"id":"d","label":"Un doublement du prix de transport en guise de garantie","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-5','qcm-v1'], 'COMM-M5-QCM-02', false,
    $mft$Seule l'ad valorem couvre la valeur réelle sans plafond ni preuve de faute : la RC du transporteur indemnise au plafond, et votre RC pro couvre vos fautes, pas la valeur de la marchandise du client.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Vous repérez sur une bourse de fret un transporteur inconnu, disponible et bien placé en prix. Avant de lui confier votre lot, vous devez impérativement vérifier :$mft$,
    $mft$[
      {"id":"a","label":"Sa licence (inscription au registre), ses attestations sociales et son attestation d'assurance","is_correct":true},
      {"id":"b","label":"Uniquement son prix et sa disponibilité : le reste le regarde","is_correct":false},
      {"id":"c","label":"L'ancienneté et la couleur de ses véhicules","is_correct":false},
      {"id":"d","label":"Rien : la bourse de fret garantit la conformité de ses membres","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-5','qcm-v1'], 'COMM-M5-QCM-03', false,
    $mft$Le donneur d'ordre exerce un devoir de vigilance : habilitation, attestations sociales et assurance se vérifient AVANT de confier le transport. Ni le prix ni la présence sur une bourse ne valent contrôle de conformité.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Vous réglez 9 000 € de droits de douane à l'importation pour le compte d'un client, qui vous les remboursera avec sa facture payable à 60 jours. Comment appelle-t-on ces sommes avancées ?$mft$,
    $mft$[
      {"id":"a","label":"Des débours : des avances faites pour le compte du client, refacturées à l'identique","is_correct":true},
      {"id":"b","label":"Une marge exceptionnelle sur le dossier","is_correct":false},
      {"id":"c","label":"Une provision pour litige","is_correct":false},
      {"id":"d","label":"Un escompte commercial consenti au client","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-5','qcm-v1'], 'COMM-M5-QCM-04', false,
    $mft$Les débours sont des sommes avancées pour le compte du client (douane, TVA le cas échéant) : ils ne créent aucune marge mais pèsent sur la trésorerie jusqu'au paiement. Ni provision (charge estimée) ni escompte (remise pour paiement anticipé).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Le dossier du client Alpha sort à 4 % de marge, très en dessous de votre cible. Avant de renégocier, votre direction demande la marge annuelle PAR CLIENT. Pourquoi ?$mft$,
    $mft$[
      {"id":"a","label":"Parce qu'un client peut être rentable globalement : ses volumes réguliers remplissent vos groupages et portent la marge d'autres dossiers","is_correct":true},
      {"id":"b","label":"Parce que la marge par dossier n'a aucune signification en commission de transport","is_correct":false},
      {"id":"c","label":"Parce que la réglementation impose une marge minimale par client","is_correct":false},
      {"id":"d","label":"Parce que la marge par client ne peut se calculer qu'en fin d'exercice","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-5','qcm-v1'], 'COMM-M5-QCM-05', false,
    $mft$Les deux lectures se complètent : la marge par dossier détecte les opérations perdantes, la marge par client mesure la valeur réelle de la relation (effet de remplissage des groupages). Aucun texte n'impose de marge minimale, et le calcul par client se fait en continu.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre transporteur affrété régulier vous a remis son attestation de vigilance URSSAF il y a huit mois, et votre volume d'affaires avec lui dépasse les seuils. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous exigez une attestation à jour : au-delà des seuils, elle se renouvelle tous les six mois","is_correct":true},
      {"id":"b","label":"Rien : l'attestation reste valable tant que le contrat d'affrètement dure","is_correct":false},
      {"id":"c","label":"Vous attendez le prochain contrôle de l'URSSAF chez le transporteur","is_correct":false},
      {"id":"d","label":"Vous demandez une copie de sa licence à la place","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-5','qcm-v1'], 'COMM-M5-QCM-06', false,
    $mft$La vigilance est périodique : au-delà des seuils, l'attestation URSSAF se renouvelle tous les six mois ; à huit mois, votre dossier n'est plus à jour. La licence est une autre vérification, elle ne remplace pas l'attestation sociale.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Avarie totale sur un dossier de forte valeur : le transporteur indemnise au plafond de sa responsabilité, très en dessous de la valeur réelle. Vous n'aviez jamais proposé d'assurance ad valorem à ce client. Qui supporte le plus probablement la différence ?$mft$,
    $mft$[
      {"id":"a","label":"Vous, commissionnaire : le défaut de proposition écrite d'assurance sur un dossier sensible est une faute de conseil","is_correct":true},
      {"id":"b","label":"Le client : il lui appartenait d'y penser seul","is_correct":false},
      {"id":"c","label":"Le transporteur : il doit indemniser au-delà de ses plafonds","is_correct":false},
      {"id":"d","label":"Personne : une marchandise non assurée n'est jamais indemnisée","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-5','qcm-v1'], 'COMM-M5-QCM-07', false,
    $mft$Le devoir de conseil impose de proposer l'ad valorem par écrit sur les dossiers sensibles : à défaut, la RC professionnelle du commissionnaire est recherchée pour la différence. Le transporteur, lui, reste dans ses plafonds, et le client indemnisé partiellement au titre de la RC transporteur.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Vous payez vos transporteurs à 30 jours, vos clients vous règlent à 60 jours, et votre chiffre d'affaires double en six mois. Quel est l'effet mécanique sur votre trésorerie ?$mft$,
    $mft$[
      {"id":"a","label":"Le besoin en fonds de roulement augmente : vous financez un décalage de plus en plus lourd, même si chaque dossier est rentable","is_correct":true},
      {"id":"b","label":"La trésorerie s'améliore automatiquement puisque le chiffre d'affaires monte","is_correct":false},
      {"id":"c","label":"Aucun effet : les flux entrants et sortants s'équilibrent toujours","is_correct":false},
      {"id":"d","label":"Le BFR diminue puisque les clients sont plus nombreux","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-5','qcm-v1'], 'COMM-M5-QCM-08', false,
    $mft$Chaque dossier ajoute son avance (fret payé à 30 jours, encaissement à 60) au stock d'avances en cours : la croissance gonfle le BFR. Croire que le chiffre d'affaires « fait » la trésorerie est l'erreur qui rend une entreprise rentable insolvable.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Votre devis d'import maritime indiquait « transport et formalités ». À la facture, le client refuse de payer les frais de scanner et de magasinage apparus au port. Quelle est la cause racine du litige ?$mft$,
    $mft$[
      {"id":"a","label":"Un périmètre de devis imprécis : les prestations incluses et exclues n'étaient pas listées par écrit","is_correct":true},
      {"id":"b","label":"La mauvaise foi du client, contre laquelle rien n'est possible","is_correct":false},
      {"id":"c","label":"Le niveau de votre marge, trop élevé sur ce dossier","is_correct":false},
      {"id":"d","label":"L'absence d'assurance ad valorem sur le dossier","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-5','qcm-v1'], 'COMM-M5-QCM-09', false,
    $mft$Le flou du périmètre se paie en litiges : « formalités » sans liste laisse chaque partie décider de ce qui est compris. La marge et l'assurance n'ont rien à voir avec ce différend, et la « mauvaise foi » n'existe que parce que l'écrit manque.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un transporteur vous propose un prix inférieur de 40 % au marché sur une liaison régulière. Quel est le principal risque à l'accepter ?$mft$,
    $mft$[
      {"id":"a","label":"Un prix qui ne permet pas d'exploiter en conformité expose aussi le donneur d'ordre : travail dissimulé et défaillances retombent sur celui qui en a profité","is_correct":true},
      {"id":"b","label":"Aucun : c'est une bonne affaire à saisir immédiatement","is_correct":false},
      {"id":"c","label":"Un simple risque de qualité de service, sans aucune conséquence juridique","is_correct":false},
      {"id":"d","label":"Le risque que les autres transporteurs s'alignent à la baisse","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-5','qcm-v1'], 'COMM-M5-QCM-10', false,
    $mft$À 40 % sous le marché, la conformité (salaires, entretien, temps de conduite) n'est pas finançable : le différentiel devient un indice que le donneur d'ordre ne pouvait ignorer, avec solidarités sociales possibles. Réduire le sujet à la qualité de service occulte l'exposition juridique.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Sinistre déclaré sur une police marchandises ad valorem : l'expertise établit que la marchandise, fragile, voyageait sans calage dans des cartons inadaptés fournis par l'expéditeur. Position probable de l'assureur ?$mft$,
    $mft$[
      {"id":"a","label":"Refus de garantie : l'emballage insuffisant est une exclusion classique des polices marchandises","is_correct":true},
      {"id":"b","label":"Indemnisation intégrale : l'ad valorem couvre tout, sans aucune exception","is_correct":false},
      {"id":"c","label":"Indemnisation doublée, à titre de sanction du transporteur","is_correct":false},
      {"id":"d","label":"Transfert automatique du dossier vers la RC du commissionnaire","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-5','qcm-v1'], 'COMM-M5-QCM-11', false,
    $mft$Aucune police ne couvre tout : l'emballage insuffisant et le vice propre sont les exclusions types des assurances marchandises. L'ad valorem supprime le plafond et la preuve de la faute, pas les exclusions de la police ; et la RC du commissionnaire suppose une faute de sa part.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Le transporteur T1 est 5 % moins cher que T2, mais son taux de litige atteint 8 % contre 0,5 % pour T2. Comment devez-vous arbitrer ?$mft$,
    $mft$[
      {"id":"a","label":"En coût complet : indemnités non récupérées, temps de gestion et clients mécontents peuvent rendre T1 plus cher que son avantage tarifaire","is_correct":true},
      {"id":"b","label":"Toujours T1 : le prix d'achat est le seul critère objectif","is_correct":false},
      {"id":"c","label":"Toujours T2 : le taux de litige est le seul critère qui compte","is_correct":false},
      {"id":"d","label":"Alterner les deux à parts égales, pour rester équitable","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-5','qcm-v1'], 'COMM-M5-QCM-12', false,
    $mft$L'arbitrage se calcule : au coût d'achat s'ajoutent le coût des litiges (indemnités, gestion) et l'impact client (OTIF dégradé). Un critère unique (prix seul ou litiges seuls) comme l'alternance « équitable » ignorent ce calcul en coût complet.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$De quoi se compose le prix facturé au client par un commissionnaire sur un dossier ?$mft$,
   $mft$De l'achat de transport (le fret payé aux transporteurs), des prestations propres (formalités douanières, documentation, assurance) et de la marge du commissionnaire.$mft$,
   2, 'facile', ARRAY['commissionnaire','module-5','question-courte'], 'COMM-M5-QC-01', false,
   $mft$Les trois blocs attendus : achat + prestations + marge.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez les trois étages d'assurance à distinguer dans un dossier de commission de transport.$mft$,
   $mft$La RC du transporteur (sa responsabilité, plafonnée), la RC professionnelle du commissionnaire (ses fautes et sa garantie des substitués) et l'assurance marchandises ad valorem (la valeur réelle, souscrite pour le compte du client).$mft$,
   2, 'facile', ARRAY['commissionnaire','module-5','question-courte'], 'COMM-M5-QC-02', false,
   $mft$Trois étages avec leur logique propre.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Pourquoi la trésorerie du commissionnaire est-elle structurellement tendue ?$mft$,
   $mft$Parce qu'il avance le fret et les débours (droits de douane, TVA le cas échéant) pour le compte de ses clients et n'est payé qu'à 30 ou 60 jours : il finance en permanence ce décalage (BFR sensible).$mft$,
   2, 'facile', ARRAY['commissionnaire','module-5','question-courte'], 'COMM-M5-QC-03', false,
   $mft$Avances + délai de paiement = BFR.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Avant d'affréter un transporteur, citez trois vérifications obligatoires du donneur d'ordre.$mft$,
   $mft$Sa licence (inscription au registre des transporteurs), ses attestations sociales (attestation de vigilance URSSAF, à renouveler tous les six mois au-delà des seuils) et son attestation d'assurance en cours de validité.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-5','question-courte'], 'COMM-M5-QC-04', false,
   $mft$Licence + vigilance sociale + assurance.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$En groupage aérien (usage 1 tonne = 6 m3), un colis de 200 kg occupe 2 m3 : quel poids taxable retenez-vous, et pourquoi ?$mft$,
   $mft$Environ 333 kg : 2 m3 équivalent à environ 333 kg (2/6 de tonne), supérieur au poids réel de 200 kg ; on facture le plus élevé du poids réel et de l'équivalent volume.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-5','question-courte'], 'COMM-M5-QC-05', false,
   $mft$Calcul de l'équivalent volume + règle du plus élevé.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quelle précaution transforme votre devoir de conseil en matière d'assurance en preuve opposable ?$mft$,
   $mft$La proposition ÉCRITE d'assurance ad valorem à chaque dossier sensible, conservée au dossier avec la réponse du client (acceptation ou refus).$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-5','question-courte'], 'COMM-M5-QC-06', false,
   $mft$L'écrit, y compris le refus écrit du client.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Citez deux dispositifs permettant de sécuriser vos encours clients.$mft$,
   $mft$Par exemple : le paiement d'avance des débours (ou des garanties) avant d'engager les fonds, et l'assurance-crédit assortie d'un plafond d'encours par client (avec relance dès le premier retard).$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-5','question-courte'], 'COMM-M5-QC-07', false,
   $mft$Deux dispositifs distincts attendus.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Que risque un commissionnaire qui continue d'affréter un transporteur dont il aurait dû détecter le travail dissimulé ?$mft$,
   $mft$Sa responsabilité pour faute dans le choix (culpa in eligendo) et des solidarités sociales possibles (paiement de cotisations et dettes sociales du sous-traitant fraudeur), en plus du dommage commercial et d'image.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-5','question-courte'], 'COMM-M5-QC-08', false,
   $mft$Faute de choix + solidarités sociales.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Vous vendez en euros un dossier dont le fret maritime s'achète en dollars, payable dans 45 jours : quel risque spécifique pèse sur la marge, et comment le limiter ?$mft$,
   $mft$Le risque de change : si le dollar monte entre la cotation et le paiement, la marge fond ; on le limite par une marge de sécurité, une clause d'ajustement devise au devis ou une couverture de change sur les gros volumes.$mft$,
   2, 'difficile', ARRAY['commissionnaire','module-5','question-courte'], 'COMM-M5-QC-09', false,
   $mft$Risque de change nommé + au moins une parade.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Que mesure l'indicateur OTIF, et pourquoi le commissionnaire le suit-il client par client ?$mft$,
   $mft$OTIF (On Time In Full) mesure la part des livraisons effectuées à l'heure ET complètes : c'est la qualité telle que le client la perçoit ; suivi client par client (et par transporteur), il alerte sur une dégradation de service avant que le client ne parte.$mft$,
   2, 'difficile', ARRAY['commissionnaire','module-5','question-courte'], 'COMM-M5-QC-10', false,
   $mft$Définition (à l'heure et complet) + usage de pilotage.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un prospect vous lance : « Vous ne possédez aucun camion et vous facturez plus cher que le transporteur : à quoi servez-vous ? » Expliquez-lui le modèle économique du commissionnaire et la valeur que paie réellement son entreprise.$mft$,
   $mft$Réponse modèle. Le prix du commissionnaire se décompose en trois blocs : l'achat de transport, négocié au meilleur coût réel (contrats de capacité pour les flux réguliers, bourses de fret pour le ponctuel), les prestations propres (formalités douanières, documentation, assurance proposée et souscrite pour le compte du client) et la marge, qui rémunère l'organisation et le risque porté. Ce que le client paie réellement : un interlocuteur unique sur une chaîne qui en compte beaucoup ; l'effet groupage, grâce auquel il ne paie que sa part de camion ou de conteneur (au poids taxable) au lieu d'un véhicule entier ; des transporteurs vérifiés (licence, attestations sociales, assurance), là où un achat en direct l'exposerait seul ; le conseil en assurance sur les dossiers sensibles ; et la gestion des incidents et litiges. Comparer le seul prix facial est donc trompeur : la comparaison honnête se fait en coût complet, en intégrant le temps interne économisé, les risques évités et les litiges pris en charge. Le commissionnaire coûte une marge ; il fait économiser une organisation.$mft$,
   $mft$Barème /5 : décomposition du prix en trois blocs (1,5 pt) ; au moins trois éléments de valeur concrets (groupage/poids taxable, conformité des transporteurs, conseil assurance, gestion des litiges) (2 pts) ; argument du coût complet face au prix facial (1 pt) ; qualité de l'argumentation client (0,5 pt). Erreurs fréquentes : répondre par le statut juridique au lieu de la valeur ; oublier les prestations propres ; opposer commissionnaire et transporteur au lieu d'expliquer leur articulation.$mft$,
   5, 'facile', ARRAY['commissionnaire','module-5','question-redigee'], 'COMM-M5-QR-01', false,
   $mft$Le modèle économique défendu face à un prospect sceptique.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Comparez l'assurance de responsabilité du transporteur et l'assurance marchandises ad valorem : qui souscrit, ce qui est couvert, les limites de chacune, et dans quel cas vous devez recommander la seconde.$mft$,
   $mft$Réponse modèle. La RC du transporteur est souscrite par le transporteur pour couvrir SA responsabilité : elle ne joue que si cette responsabilité est engagée, et elle indemnise dans la limite de plafonds, souvent très inférieurs à la valeur des marchandises ; en cas de cause d'exonération ou de plafond atteint, le client n'est pas rempli de ses droits. L'assurance marchandises ad valorem inverse la logique : souscrite par le commissionnaire pour le compte de son client (ou par le client), elle couvre les dommages à la marchandise pour sa valeur réelle, sans plafond de responsabilité et sans preuve de faute à apporter, en formule tous risques ou FAP sauf ; ses limites sont la franchise et les exclusions de police (emballage insuffisant, vice propre). Recommandation : sur tout dossier sensible, notamment quand la valeur dépasse les plafonds d'indemnisation du transporteur, l'ad valorem doit être proposée PAR ÉCRIT, avec trace de l'acceptation ou du refus : le défaut de proposition est une faute de conseil qui coûte au commissionnaire la différence entre valeur réelle et indemnité plafonnée.$mft$,
   $mft$Barème /5 : logique de la RC transporteur (responsabilité engagée + plafonds) (1,5 pt) ; logique de l'ad valorem (valeur réelle, sans plafond ni faute, pour le compte du client) (1,5 pt) ; limites correctes des deux côtés (exonérations et plafonds ; franchise et exclusions) (1 pt) ; cas de recommandation et exigence de l'écrit (1 pt). Erreurs fréquentes : confondre « le transporteur est assuré » et « la marchandise est assurée » ; oublier que l'ad valorem conserve franchise et exclusions.$mft$,
   5, 'facile', ARRAY['commissionnaire','module-5','question-redigee'], 'COMM-M5-QR-02', false,
   $mft$Deux logiques d'assurance comparées et le déclencheur du conseil.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Cas chiffré. Groupage routier avec équivalence contractuelle 1 tonne = 3 m3 : envoi de 900 kg occupant 3,6 m3. Vous vendez 210 € la tonne taxable, plus 60 € de formalités douanières et 35 € d'assurance ad valorem. Vos coûts : 190 € de fret acheté, 35 € de traitement douane, 22 € de prime d'assurance. Calculez le poids taxable, le prix de vente total, la marge en euros et en pourcentage du prix, puis dites si votre cible de 25 % est atteinte.$mft$,
   $mft$Réponse modèle. Poids taxable : 3,6 m3 avec l'équivalence 1 t = 3 m3 donnent 1,2 tonne d'équivalent volume, supérieure au poids réel de 0,9 tonne : on retient 1,2 tonne taxable. Prix de vente : 1,2 t x 210 € = 252 € de fret, plus 60 € de formalités et 35 € d'assurance, soit 347 € au total. Coûts d'achat : 190 € de fret + 35 € de douane + 22 € de prime = 247 €. Marge du dossier : 347 - 247 = 100 €, soit environ 28,8 % du prix de vente : la cible de 25 % est atteinte. Lecture utile : la marge ne vient pas que du fret (62 € sur le transport) ; les prestations y contribuent (25 € sur la douane, 13 € sur l'assurance), ce qui illustre le modèle achat + prestations + marge. Deux réflexes complètent le calcul : vérifier la cohérence avec la marge annuelle du client (un dossier correct peut masquer un client globalement perdant) et verrouiller par écrit le périmètre du devis pour que ces 100 € ne partent pas en litige.$mft$,
   $mft$Barème /5 : poids taxable correct avec justification (équivalent volume supérieur au poids réel) (1,5 pt) ; prix de vente exact (347 €) (1 pt) ; marge exacte en euros et en pourcentage (100 € ; environ 29 %) et conclusion sur la cible (1,5 pt) ; lecture économique (part des prestations dans la marge, marge par client, périmètre écrit) (1 pt). Erreurs fréquentes : facturer le poids réel ; oublier les prestations dans le prix ou dans les coûts ; calculer le pourcentage sur le coût au lieu du prix de vente.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-5','question-redigee'], 'COMM-M5-QR-03', false,
   $mft$Cotation complète chiffrée : poids taxable, prix, marge, cible.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre agence perd deux transporteurs réguliers et doit référencer rapidement de nouveaux affrétés. Rédigez la procédure de référencement et de suivi, du premier contact au pilotage dans la durée.$mft$,
   $mft$Réponse modèle. 1) Présélection : cibler des transporteurs adaptés (spécialité, zone, capacité), réputation vérifiée auprès du réseau. 2) Collecte documentaire : licence et inscription au registre des transporteurs, attestation de vigilance URSSAF, attestation d'assurance en cours de validité, coordonnées bancaires et justificatifs d'identité de l'entreprise. 3) Contrôles : authenticité et dates de validité des documents, cohérence du prix proposé avec une exploitation conforme : un prix anormalement bas est un signal d'alerte, pas une aubaine. 4) Contractualisation : conditions d'affrètement écrites, interdiction de sous-affréter sans accord écrit préalable, engagements de service. 5) Suivi dans la durée : renouvellement des attestations (tous les six mois au-delà des seuils pour la vigilance URSSAF), tableau de bord par transporteur (taux de litige, ponctualité), contrôle ponctuel des immatriculations à l'enlèvement, revue annuelle du panel. 6) Fidélisation de capacité : volumes réguliers, paiements à l'heure, prix permettant la conformité : ce sont les affrétés fidèles qui sécurisent les pointes, pas la bourse de fret. Chaque étape laisse une trace datée : le dossier de vigilance est aussi votre défense.$mft$,
   $mft$Barème /5 : collecte documentaire complète (licence/registre, vigilance URSSAF, assurance) (1,5 pt) ; contrôles dont la cohérence prix/conformité (1 pt) ; contractualisation avec clause de sous-affrètement (1 pt) ; suivi périodique daté (renouvellements, taux de litige) et fidélisation de capacité (1,5 pt). Erreurs fréquentes : procédure « one shot » sans renouvellement semestriel ; oublier la clause de sous-affrètement ; retenir le prix comme critère unique.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-5','question-redigee'], 'COMM-M5-QR-04', false,
   $mft$La procédure de référencement transporteur, de la collecte au pilotage.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un client régulier vous confie un lot d'équipements d'une valeur très supérieure aux plafonds d'indemnisation du transporteur. Avarie totale en cours de route. Analysez qui indemnise quoi dans deux hypothèses : (a) vous aviez proposé l'assurance ad valorem par écrit et le client l'avait refusée ; (b) vous n'aviez rien proposé.$mft$,
   $mft$Réponse modèle. Socle commun : la responsabilité du transporteur, si elle est engagée, débouche sur une indemnité plafonnée, très inférieure à la valeur du lot ; la question porte donc sur la différence. Hypothèse (a) : la proposition écrite d'ad valorem, conservée au dossier avec le refus du client, prouve que le devoir de conseil a été rempli ; le client, informé, a fait un choix éclairé et supporte la différence entre la valeur réelle et l'indemnité plafonnée ; sa réclamation contre vous est très fragile, sauf faute distincte de votre part dans l'organisation du transport. Hypothèse (b) : le défaut de proposition sur un dossier manifestement sensible constitue une faute de conseil ; votre RC professionnelle est recherchée pour la différence, que votre assureur paiera dans les limites de la police (franchise à votre charge, sinistralité qui renchérit vos primes), avec en prime une relation client abîmée. Leçon opérationnelle : la ligne « assurance ad valorem : acceptée / refusée » systématique sur le devis coûte quelques secondes par dossier et déplace des dizaines de milliers d'euros de risque.$mft$,
   $mft$Barème /5 : socle correct (indemnité du transporteur plafonnée, enjeu = la différence) (1 pt) ; hypothèse (a) : conseil rempli, choix éclairé, différence au client (1,5 pt) ; hypothèse (b) : faute de conseil, RC pro recherchée, conséquences (franchise, primes, relation) (1,5 pt) ; leçon opérationnelle de la proposition écrite systématique (1 pt). Erreurs fréquentes : faire payer le transporteur au-delà de ses plafonds ; croire que le refus oral du client suffit à protéger le commissionnaire.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-5','question-redigee'], 'COMM-M5-QR-05', false,
   $mft$Le sinistre au-dessus des plafonds : deux hypothèses, deux issues.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Vous gagnez un compte import important : gros débours de douane, paiement client à 60 jours. Trois mois plus tard, votre trésorerie est au plus bas alors que tous les dossiers sont rentables. Construisez votre plan d'action pour financer la croissance sans casser la relation commerciale.$mft$,
   $mft$Réponse modèle. Diagnostic : chaque dossier avance le fret et les débours (droits de douane, TVA le cas échéant) encaissés à 60 jours ; la croissance empile ces avances : le BFR explose, sans qu'aucun dossier ne soit déficitaire : rentable ne veut pas dire solvable. Plan d'action : 1) conditions d'intervention : négocier le paiement d'avance des débours (ou des garanties) avant tout engagement de fonds, en expliquant au client que ces sommes sont les siennes, pas une prestation ; 2) encours : fixer un plafond d'encours pour ce compte, le couvrir par une assurance-crédit, suivre l'encours en temps réel ; 3) discipline de facturation : facturer le jour du dossier, relancer dès le premier jour de retard ; 4) négociation commerciale : acompte ou délai réduit sur la part débours, quitte à conserver 60 jours sur les honoraires ; 5) pilotage : prévision de trésorerie hebdomadaire, marge par dossier en temps réel, provision des litiges. Le privilège invoqué sur les marchandises détenues peut compléter la panoplie, mais ses conditions d'exercice sont à vérifier : on ne bâtit pas sa sécurité financière dessus.$mft$,
   $mft$Barème /5 : diagnostic BFR correct (avances + 60 jours, croissance qui tend la trésorerie) (1,5 pt) ; débours d'avance ou garanties comme mesure clé (1 pt) ; encours plafonné + assurance-crédit + discipline de facturation/relance (1,5 pt) ; pilotage (prévision de trésorerie, marge temps réel) et prudence sur le privilège marchandises (1 pt). Erreurs fréquentes : répondre « augmenter les prix » sans traiter le décalage de trésorerie ; confondre rentabilité et solvabilité.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-5','question-redigee'], 'COMM-M5-QR-06', false,
   $mft$Plan de trésorerie : financer la croissance d'un compte à forts débours.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Contrôle sur route : le lot que vous aviez confié au transporteur A circulait dans le véhicule d'une entreprise inconnue. Vous découvrez que A a sous-affrété à B, qui a recédé le transport à C, dont le conducteur n'était pas déclaré. Analysez les risques pour vous, donneur d'ordre, puis les mesures immédiates et durables à prendre.$mft$,
   $mft$Réponse modèle. Risques : vous avez perdu toute maîtrise de la chaîne : vous ne connaissez ni la licence, ni l'assurance, ni la conformité sociale de C, qui détient pourtant la marchandise de votre client ; le conducteur non déclaré signe un travail dissimulé, avec solidarités sociales possibles remontant au donneur d'ordre qui n'a pas exercé sa vigilance ; votre responsabilité pour faute dans le choix (culpa in eligendo) peut être recherchée si des signaux étaient visibles (prix anormalement bas de A, pratiques connues) ; en cas de sinistre, la chaîne des recours est incertaine ; et c'est votre nom que voit le client. Mesures immédiates : localiser et sécuriser la marchandise, vérifier l'assurance effective de C, informer votre client factuellement, mise en demeure écrite de A, gel des affrètements avec A. Mesures durables : clause d'interdiction de sous-affrètement sans accord écrit avec déréférencement à la clé (l'encadrement du sous-affrètement en cascade existe, sa portée exacte étant à vérifier : le contrat, lui, s'applique sûrement), contrôle des immatriculations à l'enlèvement, audit périodique du panel, fidélisation de capacité pour réduire le recours au spot.$mft$,
   $mft$Barème /5 : risques complets (perte de maîtrise, travail dissimulé et solidarités, faute dans le choix, recours incertains) (2 pts) ; mesures immédiates ordonnées (sécuriser, vérifier, informer, mise en demeure) (1,5 pt) ; mesures durables (clause écrite, contrôle des immatriculations, fidélisation) (1,5 pt). Erreurs fréquentes : se croire protégé parce que « c'est A qui a fauté » ; oublier le client final dans la gestion de crise.$mft$,
   5, 'difficile', ARRAY['commissionnaire','module-5','question-redigee'], 'COMM-M5-QR-07', false,
   $mft$Sous-affrètement en cascade découvert : analyse et plan de reprise en main.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas chiffré. Sur une liaison régulière (400 dossiers par an, achat moyen 500 €), le transporteur T1 est 5 % moins cher que T2. Taux de litige constaté : 6 % pour T1, 1 % pour T2 ; coût complet moyen d'un litige (indemnités non récupérées, temps de gestion) : 700 €. Comparez les deux options en coût complet, concluez, puis indiquez les indicateurs à inscrire au tableau de bord pour éviter ce type d'angle mort.$mft$,
   $mft$Réponse modèle. Coût d'achat : T1 = 400 x 500 = 200 000 € ; T2, 5 % plus cher, soit 525 € le dossier = 210 000 € : avantage apparent de 10 000 € pour T1. Coût des litiges : T1 génère 6 % x 400 = 24 litiges x 700 € = 16 800 € ; T2 : 1 % x 400 = 4 litiges x 700 € = 2 800 € : surcoût de 14 000 € pour T1. Coût complet : T1 = 216 800 €, T2 = 212 800 € : T1 coûte 4 000 € de PLUS malgré son prix d'achat inférieur, avant même de compter l'effet commercial (OTIF dégradé chez les clients touchés, risque de perte de compte) : conclusion, T2. Tableau de bord pour ne plus subir cet angle mort : taux de litige PAR transporteur (l'indicateur décisif ici), coût moyen et provision des litiges ouverts, marge par dossier en temps réel (elle encaisse les indemnités non récupérées), OTIF par client, revue mensuelle du panel transporteurs croisant prix d'achat et coût des litiges.$mft$,
   $mft$Barème /5 : calcul d'achat exact et avantage apparent (10 000 €) (1 pt) ; calcul des litiges exact (16 800 € contre 2 800 €) (1,5 pt) ; conclusion en coût complet correcte (T1 plus cher de 4 000 €) avec mention de l'effet client (1,5 pt) ; tableau de bord pertinent (taux de litige par transporteur, provisions, marge temps réel, OTIF) (1 pt). Erreurs fréquentes : conclure sur le seul prix d'achat ; oublier de multiplier le taux de litige par le volume ; ignorer l'impact commercial non chiffré.$mft$,
   5, 'difficile', ARRAY['commissionnaire','module-5','question-redigee'], 'COMM-M5-QR-08', false,
   $mft$Arbitrage transporteurs en coût complet et tableau de bord associé.$mft$);

  RAISE NOTICE 'Module 5 Commissionnaire créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $commm5$;
