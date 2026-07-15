-- =====================================================================
-- CORRIGÉS QR + ACTIVATION — 6 formations — 14/07/2026
-- Capa lourd, Commissionnaire, ECSR, ERTV, FIMO/FCO, Taxi-VTC
--
-- Pose la réponse-modèle (expected_answer) + le barème (scoring_grid) sur
-- les 370 QR qui en manquaient, PUIS active toutes les QR qui ont désormais
-- un corrigé (activation GARDÉE : jamais de QR active sans corrigé).
-- Généré par orchestration (agent formateur par domaine) + passe de
-- vérification factuelle, assemblé et QA-vérifié (couverture 370/370).
--
-- ⚠️ 104 des 370 corrigés portent un marqueur « À CONFIRMER » ou
--    « NON VÉRIFIÉ » : RELECTURE FORMATEUR REQUISE avant de les considérer
--    comme définitifs (6 domaines réglementaires spécialisés).
--
-- Transactionnel + idempotent. À appliquer dans le SQL editor Supabase.
-- =====================================================================

BEGIN;

-- ─── 1. Corrigés (370) ───
UPDATE public.question_bank SET
  expected_answer = $c370$Le délai de prescription de droit commun est de 5 ans.

Depuis la loi du 17 juin 2008 portant réforme de la prescription en matière civile, l'article 2224 du Code civil fixe à 5 ans la prescription de droit commun des actions personnelles ou mobilières, ce délai courant à compter du jour où le titulaire du droit a connu ou aurait dû connaître les faits lui permettant d'agir.

En matière commerciale, l'article L.110-4 du Code de commerce, également modifié par cette réforme, aligne la prescription des obligations nées entre commerçants (ou entre commerçants et non-commerçants) sur ce même délai de 5 ans (contre 10 ans auparavant).

Conclusion : en matière civile comme commerciale, le délai de prescription de droit commun est aujourd'hui de 5 ans. À noter que ce délai de droit commun ne s'applique pas au contrat de transport, soumis à une prescription spéciale abrégée d'un an.$c370$,
  scoring_grid    = $c370$Réponse correcte « 5 ans » : 1,5 pt. Référence ou justification (art. 2224 C. civ. / art. L.110-4 C. com., réforme de 2008, ou précision civil = commercial = 5 ans) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-A-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les trois vices du consentement, énumérés à l'article 1130 du Code civil, sont :

a. L'erreur : représentation fausse de la réalité qui a déterminé le consentement (erreur sur les qualités essentielles de la prestation ou sur la personne du cocontractant lorsque celle-ci est déterminante).

b. Le dol : manœuvres, mensonges ou dissimulation intentionnelle d'une information déterminante par un cocontractant pour tromper l'autre et provoquer son consentement (art. 1137 C. civ.).

c. La violence : contrainte physique ou morale exercée sur une partie pour la forcer à contracter, faisant naître la crainte d'exposer sa personne, sa fortune ou celles de ses proches à un mal considérable (art. 1140 C. civ.).

Lorsqu'il est établi, le vice du consentement entraîne la nullité relative du contrat.$c370$,
  scoring_grid    = $c370$L'erreur : 0,5 pt. Le dol : 0,5 pt. La violence : 0,5 pt. Mention de la sanction (nullité relative) ou définition correcte de l'ensemble : 0,5 pt. Total = 2 pts. (En pratique, 3 vices correctement cités sans définition = 1,5 pt.)$c370$
WHERE source_ref = 'CAPA-LOURD-A-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$On demande l'extrait Kbis (extrait K-bis).

Il s'agit de la « carte d'identité » officielle de l'entreprise, délivré par le greffe du tribunal de commerce à partir des informations du Registre du commerce et des sociétés (RCS). Il atteste de l'existence juridique de la société et mentionne notamment : la dénomination sociale, la forme juridique, le numéro d'immatriculation (SIREN), l'adresse du siège, le capital social, l'activité, ainsi que l'identité du ou des dirigeants et représentants légaux.

Avant de contracter avec un nouveau partenaire, l'exiger permet de vérifier que la société existe réellement, qu'elle est bien immatriculée, qu'elle n'est pas en procédure collective et que la personne signataire a le pouvoir de l'engager. Un Kbis récent (moins de 3 mois) est généralement réclamé.

(Depuis 2023, l'extrait d'immatriculation au Registre national des entreprises — RNE — tend à compléter le Kbis, mais l'extrait Kbis reste le document de référence.)$c370$,
  scoring_grid    = $c370$Réponse « extrait Kbis » (ou extrait K-bis / extrait RCS) : 1,5 pt. Précision sur son utilité ou son contenu (existence juridique, immatriculation RCS, dirigeants, absence de procédure collective) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-A-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les actions nées du contrat de transport se prescrivent par 1 an.

L'article L.133-6 du Code de commerce prévoit que les actions pour avaries, pertes ou retard auxquelles peut donner lieu le contrat de transport, ainsi que les actions relatives au paiement du prix du transport (et celles en remboursement), sont prescrites dans le délai d'un an.

Point de départ du délai : en principe, pour les avaries et pertes partielles, à compter du jour de la remise (livraison) de la marchandise ; pour la perte totale, à compter du jour où la marchandise aurait dû être livrée. En cas de dol ou d'infidélité (fraude), le délai est porté à cinq ans.

Ce délai spécial abrégé déroge à la prescription de droit commun de 5 ans. À titre de comparaison, en transport international routier, la CMR retient également une prescription d'un an (portée à trois ans en cas de dol).$c370$,
  scoring_grid    = $c370$Réponse correcte « 1 an » : 1,5 pt. Fondement ou précision (art. L.133-6 C. com., point de départ à la livraison, ou exception 5 ans en cas de dol) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-A-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Définition : la mise en demeure est l'acte par lequel un créancier interpelle formellement (somme) son débiteur d'exécuter son obligation devenue exigible. Elle prend généralement la forme d'une lettre recommandée avec accusé de réception ou d'un acte d'huissier (commissaire de justice), et doit contenir une interpellation suffisante ne laissant aucun doute sur la volonté du créancier d'obtenir l'exécution (art. 1344 du Code civil).

b. Effet principal : elle constate officiellement le retard du débiteur et fait courir les intérêts moratoires (intérêts de retard) à compter de sa réception (art. 1344-1 C. civ.). Elle constitue en outre le préalable nécessaire à la mise en jeu de la responsabilité contractuelle du débiteur (dommages et intérêts de retard, résolution, exécution forcée) et, s'agissant d'une obligation de délivrance d'un corps certain, elle met les risques de perte de la chose à la charge du débiteur.

En résumé : elle transforme un simple retard en retard fautif juridiquement sanctionnable et déclenche le cours des intérêts de retard.$c370$,
  scoring_grid    = $c370$Définition (sommation/interpellation formelle d'exécuter, forme LRAR ou acte d'huissier) : 1 pt. Effet principal (fait courir les intérêts moratoires et/ou préalable à la responsabilité contractuelle et aux dommages-intérêts de retard) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-A-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les deux ordres (ou régimes) de responsabilité civile sont :

a. La responsabilité civile contractuelle : elle naît de l'inexécution ou de la mauvaise exécution d'un contrat liant les parties (par exemple, le contrat de transport). Le débiteur qui manque à ses obligations contractuelles doit réparer le dommage causé à son cocontractant. Dans le transport, elle repose sur une obligation de résultat (acheminer la marchandise en bon état et dans les délais).

b. La responsabilité civile délictuelle (ou extracontractuelle, dite aussi quasi-délictuelle) : elle naît d'un dommage causé à un tiers en dehors de tout contrat, du fait d'une faute, d'une imprudence ou d'une négligence (fondement des articles 1240 et suivants du Code civil). Celui qui cause un dommage à autrui est tenu de le réparer.$c370$,
  scoring_grid    = $c370$a. Responsabilité contractuelle (inexécution d'un contrat) : 1 pt. b. Responsabilité délictuelle / extracontractuelle (dommage causé à un tiers hors contrat) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-A-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le montant forfaitaire est de 40 euros.

En cas de retard de paiement d'une facture entre professionnels, le débiteur est redevable de plein droit, sans qu'un rappel soit nécessaire, d'une indemnité forfaitaire pour frais de recouvrement fixée à 40 euros (article L.441-10 du Code de commerce). Cette indemnité est due par facture payée en retard et s'ajoute aux pénalités de retard. Lorsque les frais de recouvrement réellement exposés dépassent ce forfait, le créancier peut demander une indemnisation complémentaire sur justificatifs.$c370$,
  scoring_grid    = $c370$Montant exact de 40 euros : 1 pt. Précision « indemnité forfaitaire de recouvrement due de plein droit, par facture, entre professionnels » (art. L.441-10 C. com.) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-A-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La clause de réserve de propriété est une clause insérée au contrat de vente par laquelle le vendeur conserve la propriété de la marchandise vendue jusqu'au paiement intégral du prix par l'acheteur.

Ainsi, tant que le prix n'est pas totalement réglé, la marchandise reste juridiquement la propriété du vendeur, même si elle a déjà été livrée et se trouve entre les mains de l'acheteur. En cas de défaut de paiement (ou de procédure collective de l'acheteur), cette clause permet au vendeur de revendiquer et de récupérer la marchandise. Pour être opposable, elle doit avoir été convenue par écrit entre les parties au plus tard au moment de la livraison.$c370$,
  scoring_grid    = $c370$Idée que le vendeur reste propriétaire de la marchandise (transfert de propriété différé) : 1 pt. Condition « jusqu'au paiement intégral du prix » et finalité (garantie / revendication en cas de non-paiement) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-A-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les trois causes d'exonération de la responsabilité civile sont :

a. La force majeure (cas fortuit) : événement extérieur, imprévisible et irrésistible, échappant au contrôle du responsable.

b. La faute de la victime : lorsque le dommage résulte, en tout ou partie, du fait ou de la faute de la victime elle-même (exonération totale ou partielle).

c. Le fait d'un tiers : lorsque le dommage est imputable à l'intervention d'une personne étrangère au responsable présumé.

Ces trois causes, dites causes étrangères, permettent de rompre (totalement ou partiellement) le lien de causalité et d'exonérer la personne dont la responsabilité est recherchée. La force majeure suppose en outre les caractères d'extériorité, d'imprévisibilité et d'irrésistibilité.$c370$,
  scoring_grid    = $c370$Trois causes attendues, environ 0,67 pt chacune : force majeure / cas fortuit ; faute (ou fait) de la victime ; fait d'un tiers. Barème pratique : 2 causes correctes = 1 pt, 3 causes correctes = 2 pts. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-A-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Dans le contrat de transport, le transporteur est légalement présumé responsable des pertes et avaries survenues aux marchandises pendant le transport (obligation de résultat, article L.133-1 du Code de commerce) : il est garant de plein droit. Pour renverser cette présomption et s'exonérer, il lui appartient d'apporter la preuve de l'une des causes suivantes :

a. La force majeure (événement extérieur, imprévisible et irrésistible).

b. Le vice propre de la marchandise (défaut inhérent à la nature ou à l'état de la marchandise : produit périssable, fragilité intrinsèque, tare cachée…).

c. La faute de l'expéditeur, du destinataire ou de l'ayant droit (par exemple : emballage défectueux, chargement ou arrimage mal effectué par le client, déclaration erronée, instructions fautives).

La charge de la preuve pèse sur le transporteur : à défaut de démontrer l'une de ces causes exonératoires, sa responsabilité reste engagée dans les limites prévues par le contrat type ou le contrat conclu.$c370$,
  scoring_grid    = $c370$Rappel de la présomption de responsabilité / charge de la preuve incombant au transporteur : 0,5 pt. Citation des causes exonératoires (force majeure ; vice propre de la marchandise ; faute de l'expéditeur/destinataire/ayant droit) : 1,5 pt (0,5 pt par cause). Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-A-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le transport routier national de marchandises relève du taux normal de TVA, soit 20 %.

Justification : la prestation de transport de marchandises n'est pas visée par les taux réduits (5,5 % ou 10 %) réservés à certains biens et services limitativement énumérés (produits de première nécessité, restauration, certains transports de voyageurs, etc.). Elle est donc soumise au taux de droit commun de 20 %. Le transporteur facture la TVA au taux de 20 % sur le prix hors taxes de la prestation et la reverse au Trésor, après déduction de la TVA supportée sur ses charges.$c370$,
  scoring_grid    = $c370$2 points : réponse « 20 % » (taux normal) exacte. 0 point si autre taux cité (5,5 %, 10 %) ou absence de réponse. Bonus de raisonnement non comptabilisé au-delà du plafond de 2 points.$c370$
WHERE source_ref = 'CAPA-LOURD-D-QC-01' AND type='qr';

-- ⚠️ CAPA-LOURD-D-QC-02 : [À CONFIRMER: seuil historique 12 t de PTAC/PTRA pour la taxe à l'essieu (TSVR) — valeur exacte. Dispositif supprimé en 2021 (date de prise d'effet à confirmer, généralement retenue au 1er juillet 2021) — vérifier que le référentiel de formation attend toujours la valeur « 12 tonnes » et n'a pas retiré la question devenue obsolète.]
UPDATE public.question_bank SET
  expected_answer = $c370$La taxe spéciale sur certains véhicules routiers (TSVR), dite « taxe à l'essieu », était due pour les véhicules et ensembles de véhicules dont le poids total autorisé en charge (PTAC ou PTRA pour un ensemble) était égal ou supérieur à 12 tonnes.

Rappel : cette taxe frappait les poids lourds les plus susceptibles de dégrader la voirie, son montant variant selon le nombre d'essieux et le type de suspension (pneumatique ou mécanique). À noter que la taxe à l'essieu a été supprimée en France à compter du 1er juillet 2021 ; la réponse « 12 tonnes » correspond au seuil historiquement retenu par le référentiel et reste la réponse attendue tant que le support de formation n'a pas été actualisé.$c370$,
  scoring_grid    = $c370$2 points : réponse « 12 tonnes » de PTAC/PTRA. 0 point sinon (notamment 7,5 t ou 3,5 t). La suppression du dispositif depuis le 1er juillet 2021 ne pénalise pas le candidat mais doit être signalée.$c370$
WHERE source_ref = 'CAPA-LOURD-D-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le taux normal de l'impôt sur les sociétés (IS) est de 25 %.

Justification : depuis les exercices ouverts à compter du 1er janvier 2022, l'IS a été ramené à un taux normal unique de 25 % du bénéfice imposable, au terme de la trajectoire de baisse progressive engagée par les lois de finances successives. Un taux réduit de 15 % s'applique par ailleurs, sous conditions, à la fraction de bénéfice jusqu'à 42 500 € pour les PME remplissant les critères (chiffre d'affaires plafonné et capital détenu majoritairement par des personnes physiques) : ce point peut être mentionné mais la réponse attendue au taux normal reste 25 %.$c370$,
  scoring_grid    = $c370$2 points : réponse « 25 % » (taux normal). 0 point si autre taux (33,1/3 %, 28 %, etc.). La mention correcte du taux réduit de 15 % PME n'ajoute pas de points au-delà du plafond mais valorise la copie.$c370$
WHERE source_ref = 'CAPA-LOURD-D-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le remboursement partiel de la TICPE sur le gazole professionnel (« gazole professionnel marchandises ») est ouvert aux véhicules routiers dont le poids total autorisé en charge (PTAC) est égal ou supérieur à 7,5 tonnes, affectés au transport de marchandises.

Justification : ce dispositif permet aux transporteurs de récupérer une fraction de la taxe intérieure de consommation sur les produits énergétiques acquittée sur le gazole utilisé par leurs poids lourds, en déposant une demande de remboursement auprès de l'administration douanière sur la base des volumes consommés. Le seuil d'éligibilité est fixé à 7,5 tonnes de PTAC.$c370$,
  scoring_grid    = $c370$2 points : réponse « 7,5 tonnes » de PTAC. 0 point sinon (notamment 3,5 t ou 12 t).$c370$
WHERE source_ref = 'CAPA-LOURD-D-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La TVA grevant le gazole utilisé par les poids lourds (véhicules utilitaires exclus du champ de l'exclusion du droit à déduction) est déductible à 100 %.

Justification : le principe général exclut du droit à déduction la TVA sur les dépenses relatives aux véhicules conçus pour le transport de personnes ; toutefois, pour les véhicules utilitaires et poids lourds affectés au transport de marchandises, la TVA sur le gazole est intégralement déductible (100 %). Il convient de ne pas confondre avec le gazole consommé dans les véhicules de tourisme, déductible seulement à hauteur de 80 %.$c370$,
  scoring_grid    = $c370$2 points : réponse « 100 % » (déductibilité intégrale pour les poids lourds / véhicules utilitaires). 0 point si « 80 % » (qui vise le gazole des véhicules de tourisme) ou autre valeur.$c370$
WHERE source_ref = 'CAPA-LOURD-D-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$L'autoliquidation (ou « reverse charge ») est le mécanisme par lequel la TVA n'est pas facturée par le prestataire mais déclarée et acquittée directement par le client.

Dans une prestation de services intracommunautaire entre deux assujettis (B2B), la règle générale de territorialité (art. 259-1 du CGI, transposant l'art. 44 de la directive TVA 2006/112/CE) situe la taxation au lieu d'établissement du preneur. En conséquence :

- Le prestataire établi en France émet une facture HORS TAXES (mention obligatoire du type « Autoliquidation » ou « TVA due par le preneur, art. 283-2 du CGI ») et ne collecte donc aucune TVA.
- Le client, assujetti identifié à la TVA dans son propre État membre, autoliquide l'opération : il déclare lui-même la TVA due au taux de son pays (TVA collectée) et, corrélativement, la déduit sur la même déclaration (TVA déductible), l'opération étant en principe financièrement neutre pour lui.

Utilité : éviter au prestataire d'avoir à s'immatriculer et à reverser la TVA dans le pays du client. Les deux parties doivent disposer d'un numéro de TVA intracommunautaire valide, à contrôler (VIES), et l'opération est reportée sur la déclaration d'échanges de services (DES) pour le prestataire.$c370$,
  scoring_grid    = $c370$Définition du principe (la TVA est déclarée/acquittée par le client et non par le prestataire) : 1 pt. Application au cas B2B intracommunautaire (facture HT sans TVA côté prestataire + auto-déclaration puis déduction de la TVA par le preneur dans son pays) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-D-QC-06' AND type='qr';

-- ⚠️ CAPA-LOURD-D-QC-07 : [À CONFIRMER: la CVAE fait l'objet d'une suppression progressive dont le calendrier a été repoussé par plusieurs lois de finances successives (échéance décalée au-delà de 2027) ; à la date de 2026 la CVAE existe encore et la réponse attendue « CFE + CVAE » comme composantes de la CET reste valable. Vérifier l'état exact de la CVAE à la date d'examen si la question porte sur son taux ou son échéanc
UPDATE public.question_bank SET
  expected_answer = $c370$La contribution économique territoriale (CET), qui a remplacé la taxe professionnelle depuis 2010, se compose de deux prélèvements :

1. La CFE — cotisation foncière des entreprises : assise sur la valeur locative des biens immobiliers passibles de la taxe foncière et utilisés par l'entreprise pour son activité. Elle est perçue au profit des communes et EPCI.

2. La CVAE — cotisation sur la valeur ajoutée des entreprises : assise sur la valeur ajoutée produite par l'entreprise (due, pour la déclaration, à partir d'un certain seuil de chiffre d'affaires).

La CET est par ailleurs plafonnée en fonction de la valeur ajoutée.$c370$,
  scoring_grid    = $c370$CFE (cotisation foncière des entreprises) correctement identifiée : 1 pt. CVAE (cotisation sur la valeur ajoutée des entreprises) correctement identifiée : 1 pt. Total = 2 pts. (Le simple sigle exact suffit ; l'explication de l'assiette est un bonus non exigé.)$c370$
WHERE source_ref = 'CAPA-LOURD-D-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$En l'absence d'option particulière, le bénéfice d'une entreprise individuelle de transport est imposé à l'impôt sur le revenu (IR), au nom de l'exploitant, dans la catégorie des bénéfices industriels et commerciaux (BIC).

Explications :
- L'entreprise individuelle n'a pas de personnalité fiscale distincte de celle de l'entrepreneur : le résultat n'est pas imposé au niveau de l'entreprise mais directement dans la déclaration de revenus du chef d'entreprise, où il s'ajoute aux autres revenus du foyer et est soumis au barème progressif de l'IR.
- L'activité de transport routier étant une activité commerciale, le bénéfice relève des BIC (et non des BNC).
- Régime par défaut = imposition à l'IR. L'entrepreneur individuel peut toutefois, sur option, être assimilé à une EURL et opter pour l'assujettissement à l'impôt sur les sociétés (IS) ; à défaut d'option, c'est bien l'IR/BIC qui s'applique.$c370$,
  scoring_grid    = $c370$Imposition à l'impôt sur le revenu (IR) au nom de l'exploitant : 1 pt. Catégorie des bénéfices industriels et commerciaux (BIC) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-D-QC-08' AND type='qr';

-- ⚠️ CAPA-LOURD-D-QC-09 : [À CONFIRMER: le plafond du taux réduit d'IS à 15 % est de 42 500 € depuis les exercices ouverts à compter du 1er janvier 2023 (auparavant 38 120 €). Réponse retenue = 42 500 € à la date de 2026 ; vérifier qu'aucune loi de finances postérieure n'a modifié ce plafond avant l'examen.]
UPDATE public.question_bank SET
  expected_answer = $c370$Une PME éligible bénéficie du taux réduit d'impôt sur les sociétés de 15 % sur la fraction de son bénéfice imposable comprise entre 0 et 42 500 €. Au-delà de 42 500 €, le bénéfice est imposé au taux normal de l'IS (25 %).

Conditions d'éligibilité au taux réduit :
- Chiffre d'affaires hors taxes inférieur à 10 000 000 € au titre de l'exercice ;
- Capital entièrement libéré ;
- Capital détenu de manière continue à hauteur d'au moins 75 % par des personnes physiques (ou par des sociétés répondant elles-mêmes à ces conditions).

Le plafond de 42 500 € s'apprécie par période de douze mois.$c370$,
  scoring_grid    = $c370$Montant du plafond du taux réduit à 15 % correctement indiqué (42 500 €) : 1,5 pt. Mention du taux normal (25 %) applicable au-delà et/ou d'au moins une condition d'éligibilité (CA < 10 M€, capital libéré et détenu ≥ 75 % par des personnes physiques) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-D-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le délai de reprise de droit commun de l'administration fiscale est de trois ans.

Plus précisément, pour les principaux impôts (impôt sur le revenu, impôt sur les sociétés, TVA), le droit de reprise de l'administration s'exerce jusqu'à la fin de la troisième année qui suit celle au titre de laquelle l'imposition est due. Exemple : pour les revenus/résultats de l'année N, l'administration peut rectifier jusqu'au 31 décembre N+3.

Ce délai de trois ans est le délai « normal » ; il n'écarte pas l'existence de délais spéciaux plus longs dans certains cas (activité occulte, défaut de déclaration, fraude, etc.), qui constituent des exceptions au droit commun.$c370$,
  scoring_grid    = $c370$Délai de trois ans correctement indiqué : 1,5 pt. Précision de la computation (jusqu'au 31 décembre de la 3e année suivante, N+3) ou mention de la portée « droit commun » face aux délais spéciaux : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-D-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Pour l'analyse du coût de revient, les charges se répartissent en deux grandes catégories :

a. Les charges fixes (dites aussi charges de structure) : elles sont indépendantes du niveau d'activité et existent même véhicule à l'arrêt. Exemples : amortissement du véhicule, assurances, taxes à l'essieu, coûts de structure (locaux, encadrement), une partie du salaire du conducteur. Rapportées à l'unité produite (le kilomètre), elles diminuent quand l'activité augmente.

b. Les charges variables (dites aussi charges opérationnelles ou proportionnelles) : elles évoluent en fonction de l'activité, principalement du kilométrage parcouru. Exemples : carburant/gazole, pneumatiques, entretien et réparations, péages, lubrifiants.

Cette distinction est le fondement des méthodes de calcul du coût de revient (monôme, binôme, trinôme) et du seuil de rentabilité.$c370$,
  scoring_grid    = $c370$a. Charges fixes (ou de structure) correctement identifiées et caractérisées : 1 point. b. Charges variables (ou opérationnelles/proportionnelles) correctement identifiées et caractérisées : 1 point. Total = 2 points. (0,5 point par catégorie si seul le nom est cité sans caractérisation ; un exemple pertinent par catégorie peut compenser une définition partielle.)$c370$
WHERE source_ref = 'CAPA-LOURD-E-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le document comptable qui donne la photographie (l'image) du patrimoine de l'entreprise à une date donnée, c'est-à-dire à la clôture de l'exercice, est le BILAN.

Le bilan présente à cette date :
- à l'actif : ce que l'entreprise possède (emplois) : actif immobilisé (dont le matériel roulant) et actif circulant (stocks, créances clients, disponibilités) ;
- au passif : ce que l'entreprise doit et ses ressources (origine des financements) : capitaux propres et dettes.

À distinguer du compte de résultat, qui retrace l'activité (produits et charges) sur toute la durée de l'exercice et non la situation à un instant donné.$c370$,
  scoring_grid    = $c370$Réponse « le bilan » : 2 points. Si la bonne réponse est donnée mais confondue dans la formulation avec le compte de résultat : 1 point. Réponse erronée (compte de résultat, liasse fiscale, etc.) : 0 point. Total = 2 points.$c370$
WHERE source_ref = 'CAPA-LOURD-E-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La capacité d'autofinancement (CAF) mesure les ressources internes dégagées par l'activité et réellement disponibles pour financer l'entreprise (investissements, remboursement d'emprunts, distribution).

Formule simplifiée (méthode additive, à partir du résultat net) :

CAF = Résultat net de l'exercice + Dotations aux amortissements et provisions

Autrement dit, on repart du résultat net et on y rajoute les charges calculées qui n'ont pas donné lieu à un décaissement (les dotations aux amortissements et aux provisions), car elles ont diminué le résultat sans sortie de trésorerie.

Une version un peu plus complète retranche les reprises sur amortissements et provisions et neutralise les plus ou moins-values de cession : CAF = Résultat net + Dotations - Reprises + Valeur nette comptable des éléments cédés - Produits de cession. Pour la capacité de transport, la formule simplifiée « Résultat net + Dotations aux amortissements et provisions » est celle attendue.$c370$,
  scoring_grid    = $c370$« Résultat net (ou résultat de l'exercice) » comme point de départ : 1 point. « + Dotations aux amortissements et provisions » (charges non décaissées ajoutées) : 1 point. Total = 2 points. (La seule mention « résultat + amortissements » sans les provisions vaut 1,5 point ; bonus de compréhension non comptabilisé au-delà de 2 points.)$c370$
WHERE source_ref = 'CAPA-LOURD-E-QC-03' AND type='qr';

-- ⚠️ CAPA-LOURD-E-QC-04 : [À CONFIRMER: la répartition des charges entre terme journalier (mise à disposition : amortissement, assurances, taxes) et terme horaire (personnel de conduite) suit la convention CNR/monôme-binôme-trinôme du référentiel ; vérifier que le support de la formation « capacite-plus-3-5t » nomme bien les inducteurs « kilomètre / jour / heure » et n'inverse pas l'affectation des charges de structure. Co
UPDATE public.question_bank SET
  expected_answer = $c370$La méthode du trinôme décompose le coût de revient d'un véhicule en trois termes, chacun rattaché à un inducteur (unité d'œuvre) différent :

a. Le terme kilométrique : il regroupe les charges variables liées à la distance parcourue (carburant/gazole, pneumatiques, entretien-réparations, lubrifiants). Inducteur : le kilomètre parcouru (coût exprimé en €/km).

b. Le terme journalier (ou terme de mise à disposition) : il regroupe les charges liées à la détention du véhicule indépendamment des kilomètres (amortissement du véhicule, assurances, taxes à l'essieu, coûts de structure). Inducteur : le jour (ou la journée de mise à disposition du véhicule), coût exprimé en €/jour.

c. Le terme horaire : il regroupe les charges de personnel de conduite (rémunération du conducteur et charges associées). Inducteur : l'heure (de conduite / de travail du conducteur), coût exprimé en €/heure.

Le coût de revient total s'obtient en additionnant : (coût kilométrique x nombre de km) + (coût journalier x nombre de jours) + (coût horaire x nombre d'heures). Le monôme n'utilise que le km, le binôme le km et le jour, le trinôme ajoute l'heure.$c370$,
  scoring_grid    = $c370$Terme kilométrique + inducteur (le km) : 0,67 point. Terme journalier + inducteur (le jour/la mise à disposition) : 0,67 point. Terme horaire + inducteur (l'heure de conduite) : 0,66 point. Total = 2 points. (Un terme cité sans son inducteur : demi-crédit sur la fraction ; barème arrondi de sorte que la somme fasse 2.)$c370$
WHERE source_ref = 'CAPA-LOURD-E-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le seuil de rentabilité (ou point mort en valeur) est le chiffre d'affaires pour lequel l'entreprise ne réalise ni bénéfice ni perte : le résultat est nul, c'est-à-dire que la marge sur coûts variables couvre exactement les charges fixes.

Formule :

Seuil de rentabilité (en chiffre d'affaires) = Charges fixes / Taux de marge sur coûts variables

avec :
Taux de marge sur coûts variables = Marge sur coûts variables / Chiffre d'affaires
et Marge sur coûts variables = Chiffre d'affaires - Charges variables.

On peut donc aussi l'écrire : Seuil de rentabilité = Charges fixes x Chiffre d'affaires / (Chiffre d'affaires - Charges variables).

Le seuil de rentabilité est atteint lorsque : Marge sur coûts variables = Charges fixes.$c370$,
  scoring_grid    = $c370$Formule « Charges fixes / Taux de marge sur coûts variables » (ou équivalent CF x CA / MCV) : 1,5 point. Définition du taux de marge sur coûts variables (MCV/CA) ou de la condition MCV = CF : 0,5 point. Total = 2 points. (La seule condition « MCV = charges fixes » sans mise en forme de la formule vaut 1 point.)$c370$
WHERE source_ref = 'CAPA-LOURD-E-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le délai de paiement des factures de transport routier de marchandises est plafonné par la loi à 30 jours à compter de la date d'émission de la facture.

Raisonnement : le Code de commerce fixe un plafond de droit commun (60 jours, ou 45 jours fin de mois), mais il prévoit un délai dérogatoire, plus court, pour le secteur du transport. Pour le transport routier de marchandises, la location de véhicules avec ou sans conducteur, la commission de transport et les activités de transitaire, agent maritime, courtier de fret et commissionnaire en douane, le délai convenu ne peut jamais dépasser 30 jours à compter de la date d'émission de la facture (article L.441-11, II du Code de commerce, issu de la loi LME).

Ce plafond est impératif : toute clause fixant un délai supérieur est réputée nulle et expose à sanction. Il vise à protéger la trésorerie des transporteurs, dont le poste carburant et charges de personnel exige des décaissements rapides.$c370$,
  scoring_grid    = $c370$1 pt : indiquer le délai correct de 30 jours. / 0,5 pt : préciser le point de départ (date d'émission de la facture). / 0,5 pt : préciser qu'il s'agit d'un délai maximal impératif propre au transport (dérogatoire au droit commun 60 jours). Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-E-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le besoin en fonds de roulement (BFR) est le montant que l'entreprise doit financer pour couvrir le décalage de trésorerie né de son cycle d'exploitation, c'est-à-dire l'écart entre les dépenses engagées (achats, stocks, charges) et les recettes encaissées auprès des clients.

Formule : BFR = actif circulant d'exploitation - passif circulant d'exploitation, soit :
BFR = (Stocks + Créances clients) - Dettes fournisseurs (et dettes fiscales et sociales d'exploitation).

Interprétation :
- Un BFR positif signifie que le cycle d'exploitation consomme de la trésorerie : l'entreprise paie ses fournisseurs et ses charges avant d'être réglée par ses clients ; ce besoin doit être financé (par le fonds de roulement ou un crédit court terme).
- Dans le transport routier de marchandises, le BFR est souvent tendu car le transporteur décaisse immédiatement le carburant, les péages et les salaires, alors que le règlement des clients intervient à 30 jours.$c370$,
  scoring_grid    = $c370$1 pt : définition (besoin de financement lié au décalage du cycle d'exploitation entre décaissements et encaissements). / 0,5 pt : formule ou composantes (stocks + créances clients - dettes fournisseurs). / 0,5 pt : interprétation (BFR positif = trésorerie à financer / illustration transport). Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-E-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La loi prévoit un mécanisme légal et automatique de répercussion des variations du prix du gazole, qui s'applique de plein droit même en l'absence de clause d'indexation dans le contrat.

Principe (articles L.3222-1 et L.3222-2 du Code des transports, issus de la loi du 5 janvier 2006) : le prix de transport initialement convenu est révisé de plein droit pour prendre en compte la variation des charges de carburant survenue entre la date du contrat et la date de réalisation de l'opération de transport. La répercussion joue dans les deux sens, à la hausse comme à la baisse.

Modalités :
- Le transporteur doit faire apparaître sur la facture les charges de carburant supportées pour la réalisation de l'opération.
- La variation est calculée par référence à l'évolution d'un indice public du prix du gazole (indices CNR) rapportée à la part du carburant dans le prix.
- Ce dispositif est d'ordre public : il ne peut être écarté par les parties. En l'absence de clause négociée, c'est la formule légale qui s'applique.

Objectif : protéger le transporteur contre la volatilité du poste carburant, qui échappe à sa maîtrise, en garantissant l'ajustement du prix même sans clause contractuelle.$c370$,
  scoring_grid    = $c370$1 pt : la loi impose une révision automatique / de plein droit du prix en fonction de la variation du gazole, même sans clause d'indexation. / 0,5 pt : préciser que la répercussion joue à la hausse comme à la baisse, entre conclusion et réalisation du contrat. / 0,5 pt : préciser une modalité (mention des charges de carburant sur la facture / référence à un indice / caractère d'ordre public). Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-E-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La différence tient au traitement des dotations aux amortissements et aux provisions : l'EBE se calcule avant, le résultat d'exploitation après.

EBE (excédent brut d'exploitation) : il mesure la richesse dégagée par la seule activité d'exploitation, indépendamment de la politique d'investissement (amortissements), de financement et de la fiscalité sur le résultat.
EBE = Valeur ajoutée + subventions d'exploitation - impôts et taxes - charges de personnel.

Résultat d'exploitation : il repart de l'EBE et intègre en plus les éléments d'exploitation non décaissés/encaissés liés à l'usure et aux risques de l'actif :
Résultat d'exploitation = EBE + autres produits d'exploitation + reprises sur amortissements et provisions - dotations aux amortissements et provisions - autres charges d'exploitation.

En synthèse : le résultat d'exploitation tient compte des dotations aux amortissements et aux provisions (et de leurs reprises), que l'EBE ignore. L'EBE est donc un solde "brut" (proche de la trésorerie d'exploitation), tandis que le résultat d'exploitation est un solde "net" intégrant l'usure du matériel, ce qui est particulièrement significatif dans le transport où le parc de véhicules représente un amortissement lourd.$c370$,
  scoring_grid    = $c370$1 pt : identifier que la différence porte sur les dotations aux amortissements et provisions (EBE = avant, résultat d'exploitation = après). / 0,5 pt : caractériser l'EBE (solde brut, avant amortissements, indépendant de la politique d'investissement/financement). / 0,5 pt : caractériser le résultat d'exploitation (intègre dotations et reprises) ou illustration transport (poids des amortissements du parc). Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-E-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le crédit-bail (leasing) est un contrat de financement par lequel une société de crédit-bail (le bailleur) achète, sur indication de l'entreprise, un bien d'équipement (par exemple un véhicule ou un ensemble routier) et le met à la disposition de cette entreprise (le locataire) pour une durée déterminée, en contrepartie du versement de loyers périodiques. Le bien reste la propriété de la société de crédit-bail pendant toute la durée du contrat.

Caractéristique essentielle : le contrat comporte, à son terme, une promesse unilatérale de vente, c'est-à-dire une option d'achat permettant au locataire d'acquérir le bien pour une valeur résiduelle fixée dès l'origine (généralement faible).

Il se termine par la levée ou non de l'option d'achat. À l'échéance, le locataire a le choix entre trois possibilités :
1. lever l'option d'achat et devenir propriétaire du bien moyennant le paiement de la valeur résiduelle ;
2. restituer le bien au bailleur ;
3. renouveler le contrat de location (lorsque cela est prévu).

Intérêt pour le transporteur : il permet de financer et de renouveler le parc de véhicules sans immobiliser de capitaux propres au départ, tout en conservant la faculté de devenir propriétaire en fin de contrat.$c370$,
  scoring_grid    = $c370$1 pt : définition du crédit-bail (location d'un bien acheté par une société de crédit-bail contre des loyers, assortie d'une option d'achat). / 0,5 pt : indiquer qu'il se termine par la levée (ou non) de l'option d'achat à la valeur résiduelle. / 0,5 pt : citer les alternatives de fin de contrat (achat / restitution / renouvellement) ou l'intérêt pour le transporteur. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-E-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$L'entreprise de transport public routier de marchandises avec des véhicules de plus de 3,5 t doit justifier d'une capacité financière de 9 000 € pour le premier véhicule, puis de 5 000 € pour chacun des véhicules supplémentaires.

Exemple d'application : pour un parc de 3 véhicules lourds, le montant exigé est de 9 000 € + (2 x 5 000 €) = 19 000 €.

Ces capitaux propres (ou garanties admises) doivent être disponibles en permanence et sont vérifiés chaque année sur la base des comptes annuels.$c370$,
  scoring_grid    = $c370$1 point : montant exact du premier véhicule (9 000 €). 1 point : montant exact par véhicule supplémentaire (5 000 €). Total = 2 points.$c370$
WHERE source_ref = 'CAPA-LOURD-F-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le document présent à bord de chaque véhicule moteur qui prouve, lors d'un contrôle routier, que l'entreprise est autorisée à exercer est la copie certifiée conforme de la licence communautaire.

Pour le transport public de marchandises avec des véhicules de plus de 3,5 t, le titre requis est la licence communautaire (valable aussi bien pour le transport national qu'international au sein de l'Union). L'original est conservé au siège de l'entreprise ; une copie certifiée conforme est délivrée pour chaque véhicule inscrit et doit se trouver à bord pour être présentée aux forces de l'ordre ou aux agents de contrôle.

(À distinguer de la licence de transport intérieur, qui ne concerne que les véhicules de 3,5 t ou moins, hors champ du transport lourd.)$c370$,
  scoring_grid    = $c370$2 points : identification correcte de la copie certifiée conforme de la licence communautaire. 1 point seulement si l'élève cite « la licence » sans préciser qu'il s'agit de la copie conforme à bord. Total = 2 points.$c370$
WHERE source_ref = 'CAPA-LOURD-F-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$L'administration qui instruit la demande d'autorisation d'exercer la profession et qui tient le registre électronique national des entreprises de transport par route dans la région est la DREAL (Direction régionale de l'environnement, de l'aménagement et du logement).

En Île-de-France, cette compétence est exercée par la DRIEAT (Direction régionale et interdépartementale de l'environnement, de l'aménagement et des transports) ; en outre-mer, par la DEAL. C'est auprès de ce service que l'entreprise dépose son dossier d'accès à la profession (établissement, honorabilité, capacité professionnelle, capacité financière) et obtient son inscription au registre ainsi que sa licence.$c370$,
  scoring_grid    = $c370$2 points : réponse « DREAL » (ou DRIEAT en Île-de-France / DEAL en outre-mer). Total = 2 points. Aucun point si l'élève cite la préfecture, la CCI ou un autre organisme.$c370$
WHERE source_ref = 'CAPA-LOURD-F-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La licence communautaire est délivrée pour une durée maximale de 10 ans, renouvelable.

Les copies certifiées conformes délivrées pour chaque véhicule ont la même durée de validité que la licence dont elles sont issues. L'autorité vérifie au moins tous les cinq ans que l'entreprise remplit toujours les conditions d'accès à la profession, et la licence est renouvelée à son échéance si les quatre exigences (établissement, honorabilité, capacité professionnelle, capacité financière) demeurent satisfaites.$c370$,
  scoring_grid    = $c370$2 points : durée exacte de 10 ans. Total = 2 points. 0 point pour toute autre durée (5 ans, illimitée, etc.).$c370$
WHERE source_ref = 'CAPA-LOURD-F-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Après un transport international à charge dont le chargement a été entièrement livré dans l'État membre d'accueil, le transporteur est autorisé à réaliser jusqu'à 3 opérations de cabotage avec le même véhicule, dans un délai de 7 jours à compter de la date du dernier déchargement du transport international entrant.

Ces opérations doivent être réalisées à la suite du transport international ; elles sont justifiées par des documents attestant du transport entrant et de chaque déplacement en charge. À noter la période de carence : après une séquence de cabotage, le véhicule ne peut réaliser de nouvelles opérations de cabotage dans le même pays qu'après un délai d'attente (cooling-off) de 4 jours.$c370$,
  scoring_grid    = $c370$1 point : nombre exact d'opérations de cabotage (3). 1 point : délai exact (7 jours après le dernier déchargement). Total = 2 points.$c370$
WHERE source_ref = 'CAPA-LOURD-F-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$L'attestation de capacité professionnelle doit être détenue par le gestionnaire de transport désigné par l'entreprise, c'est-à-dire la personne physique qui dirige effectivement et en permanence les activités de transport de l'entreprise (Règl. CE 1071/2009).

Ce gestionnaire de transport :
- doit être titulaire de l'attestation de capacité professionnelle (obtenue par examen ou par équivalence de diplôme/expérience) ;
- doit résider dans l'Union européenne et avoir un lien réel avec l'entreprise ;
- peut être interne (dirigeant, associé ou salarié de l'entreprise) ou externe (prestataire lié par contrat).

En pratique, ce n'est donc pas nécessairement le chef d'entreprise lui-même : ce peut être un dirigeant, un associé, un salarié qualifié, ou un gestionnaire externe, dès lors que cette personne dirige réellement et de façon continue l'activité de transport. C'est l'entreprise qui doit disposer, à travers ce gestionnaire, de la capacité professionnelle exigée pour obtenir la licence.$c370$,
  scoring_grid    = $c370$Identification du gestionnaire de transport comme titulaire de l'attestation : 1 pt. Précision qu'il dirige effectivement et en permanence l'activité de transport et qu'il peut être interne ou externe (pas forcément le chef d'entreprise) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-F-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le gestionnaire de transport externe (prestataire non salarié de l'entreprise, lié par contrat) est soumis à deux plafonds cumulatifs fixés par le Règlement CE 1071/2009 (art. 4, § 2) :

a. Il ne peut être désigné comme gestionnaire de transport que pour un maximum de 4 entreprises différentes.

b. La flotte totale gérée à ce titre ne peut excéder 50 véhicules, tous parcs confondus.

Ces deux limites visent à garantir que le gestionnaire externe dirige réellement et en permanence l'activité de chaque entreprise, ce qui ne serait pas possible au-delà de ce seuil d'entreprises et de véhicules.$c370$,
  scoring_grid    = $c370$Limite de 4 entreprises maximum : 1 pt. Limite de 50 véhicules maximum au total : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-F-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$ERRU (European Registers of Road transport Undertakings, en français : Registres européens des entreprises de transport routier) est le système d'interconnexion électronique des registres électroniques nationaux des entreprises de transport routier des différents États membres.

Il sert à :
- permettre l'échange d'informations entre les autorités compétentes des États membres au sujet des entreprises de transport, de leurs gestionnaires de transport et de leurs licences ;
- faire circuler les données relatives à l'honorabilité, aux infractions graves à la réglementation (temps de conduite, poids, etc.) et aux sanctions (retrait de licence, déclaration d'inaptitude d'un gestionnaire) ;
- garantir un contrôle harmonisé et l'application homogène des règles d'accès à la profession dans toute l'Union européenne, notamment en évitant qu'une entreprise sanctionnée dans un pays contourne la sanction dans un autre.

En résumé, ERRU est l'outil européen d'interconnexion des registres nationaux qui permet la coopération administrative et le partage d'informations entre États membres sur les transporteurs routiers.$c370$,
  scoring_grid    = $c370$Identification d'ERRU comme interconnexion des registres électroniques nationaux des entreprises de transport : 1 pt. Explication de sa finalité (échange d'informations entre États membres sur honorabilité/infractions/licences, contrôle harmonisé) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-F-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Un délai de carence de 4 jours s'applique.

À l'issue d'une séquence de cabotage (opérations de transport intérieur effectuées à la suite d'un transport international), le véhicule ne peut pas réaliser de nouvelles opérations de cabotage dans le même État membre pendant une période de 4 jours suivant la fin du cabotage précédent (Règlement CE 1072/2009 modifié par le Paquet Mobilité, applicable depuis le 21 février 2022).

Ce délai vise à empêcher le cabotage systématique et permanent, qui reviendrait à un établissement de fait dans l'État d'accueil. Pour recommencer une séquence de cabotage dans ce même pays avec le même véhicule, il faut donc respecter ce délai de carence de 4 jours (le véhicule devant, entre-temps, avoir quitté le territoire de cet État membre).$c370$,
  scoring_grid    = $c370$Indication correcte du délai de carence de 4 jours : 1,5 pt. Contexte/justification (empêcher le cabotage systématique, entre deux séquences dans le même État avec le même véhicule) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-F-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Une garantie bancaire ou une garantie d'assurance peut être admise, en remplacement de la démonstration de la capacité financière par les capitaux propres, jusqu'à 50 % (la moitié) de la capacité financière exigée.

Autrement dit :
- au moins 50 % de la capacité financière requise doit être justifié par les capitaux propres de l'entreprise (attestés par les comptes annuels certifiés) ;
- les 50 % restants au maximum peuvent être couverts par une garantie donnée par une banque ou par un organisme d'assurance (caution).

La possibilité de recourir à une garantie est prévue par le Règlement CE 1071/2009 (art. 7) ; le plafond de 50 % résulte de la transposition française (Code des transports).

Exemple pour un premier véhicule lourd (capacité exigée de 9 000 €) : la garantie bancaire ou d'assurance ne peut couvrir que 4 500 € au maximum, les 4 500 € restants devant être justifiés par les capitaux propres.$c370$,
  scoring_grid    = $c370$Indication correcte du plafond de 50 % (moitié) de la capacité financière exigée : 1,5 pt. Précision que le complément doit être justifié par les capitaux propres (ou exemple chiffré cohérent) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-F-QC-10' AND type='qr';

-- ⚠️ CAPA-LOURD-G-QC-01 : Correction : la charge maximale par essieu isolé/moteur en France est de 13 t (Code de la route R.312-5), et non 12 t comme indiqué dans la version initiale. La condition d'essieux (5 minimum pour 44 t) est exacte. Le barème accordait déjà le point complémentaire de façon générique (« respect des charges par essieu »), donc la note reste inchangée à 2 pts.
UPDATE public.question_bank SET
  expected_answer = $c370$Un ensemble articulé (tracteur + semi-remorque) peut circuler à 44 tonnes de PTRA en France à condition de comporter au minimum 5 essieux.

Détail du raisonnement :
- La limite générale de PTRA d'un ensemble articulé à 4 essieux est de 38 tonnes (40 t dans certains transports).
- Le passage à 44 tonnes n'est admis que pour les ensembles comportant 5 essieux ou plus (typiquement tracteur 3 essieux + semi 2 essieux, ou tracteur 2 essieux + semi 3 essieux).
- Il faut également respecter les charges maximales par essieu (notamment 13 t sur un essieu isolé / essieu moteur) et disposer d'un véhicule dont la réception technique et la carte grise autorisent ce PTRA.

Conclusion : condition = 5 essieux minimum pour l'ensemble.$c370$,
  scoring_grid    = $c370$Condition principale correctement identifiée (au moins 5 essieux pour circuler à 44 t) : 1,5 pt. Précision complémentaire cohérente (rappel de la limite à 4 essieux 38/40 t, ou respect des charges par essieu) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-G-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le contrôle technique d'un poids lourd (véhicule de transport de marchandises de PTAC supérieur à 3,5 t) est annuel : il doit être réalisé tous les 12 mois.

Précisions :
- Le premier contrôle technique intervient dans l'année qui suit la première mise en circulation du véhicule.
- Il est ensuite renouvelé chaque année (périodicité de 12 mois), contrairement au véhicule léger dont la périodicité est de 2 ans après le premier contrôle à 4 ans.$c370$,
  scoring_grid    = $c370$Périodicité annuelle / tous les 12 mois indiquée : 1,5 pt. Précision correcte (champ des PL > 3,5 t ou premier contrôle dans l'année suivant la mise en circulation) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-G-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La largeur maximale autorisée d'un véhicule est de 2,55 mètres.

Exception admise : les véhicules à carrosserie isotherme (transport sous température dirigée, frigorifiques) équipés de parois d'au moins 45 mm d'épaisseur sont admis jusqu'à 2,60 mètres de largeur. Les rétroviseurs et certains équipements de signalisation ne sont pas comptés dans cette largeur.$c370$,
  scoring_grid    = $c370$Largeur maximale générale = 2,55 m : 1 pt. Exception correctement énoncée (2,60 m pour les carrosseries isothermes/frigorifiques à parois d'au moins 45 mm) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-G-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le PTRA (Poids Total Roulant Autorisé) désigne la masse maximale autorisée de l'ensemble routier en charge, c'est-à-dire le véhicule tracteur + la remorque ou semi-remorque + le chargement, lorsque le véhicule tracte.

Précisions :
- Le PTRA est fixé par le constructeur et figure sur le certificat d'immatriculation (carte grise), rubrique F.3.
- Il représente le poids maximal que l'ensemble attelé est autorisé à atteindre lorsqu'il roule (à distinguer du PTAC, qui ne concerne qu'un seul véhicule isolé).$c370$,
  scoring_grid    = $c370$Définition correcte (masse maximale autorisée de l'ensemble attelé en charge, tracteur + remorque/semi + chargement) : 1,5 pt. Précision pertinente (fixé par le constructeur / figure sur la carte grise, ou distinction avec le PTAC) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-G-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La charge utile d'un ensemble routier se calcule par la différence entre le poids total roulant autorisé et le poids à vide (tare) de l'ensemble :

Charge utile = PTRA − Tare de l'ensemble

où la tare de l'ensemble = poids à vide du tracteur + poids à vide de la remorque ou semi-remorque.

Autrement dit : CU = PTRA − (tare tracteur + tare remorque/semi). La charge utile représente le poids de marchandises que l'ensemble peut légalement transporter.$c370$,
  scoring_grid    = $c370$Formule correcte : Charge utile = PTRA − tare (poids à vide) de l'ensemble : 1,5 pt. Précision que la tare de l'ensemble = somme des poids à vide du tracteur et de la remorque/semi : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'CAPA-LOURD-G-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La longueur maximale autorisée d'un train routier (véhicule porteur + remorque) est de 18,75 mètres.

Point de repère utile pour ne pas confondre les gabarits de longueur :
- Véhicule isolé (porteur seul) : 12 m.
- Ensemble articulé (tracteur + semi-remorque) : 16,50 m.
- Train routier (porteur + remorque) : 18,75 m.

La largeur maximale reste 2,55 m (2,60 m pour les carrosseries frigorifiques). La hauteur n'est pas fixée réglementairement en France pour ces ensembles, au-delà des contraintes d'infrastructure (gabarit des ouvrages).$c370$,
  scoring_grid    = $c370$Réponse « 18,75 m » exacte : 2 points. Confusion avec le gabarit du semi-remorque (16,50 m) ou du porteur (12 m) : 0 point. Ordre de grandeur correct mais valeur imprécise (ex. « environ 18 m ») : 1 point.$c370$
WHERE source_ref = 'CAPA-LOURD-G-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Au freinage, l'arrimage doit retenir un effort dirigé vers l'avant égal à 0,8 fois le poids de la charge (soit 80 % du poids).

Explication : lors d'un freinage d'urgence, la décélération peut atteindre environ 0,8 g, ce qui projette la marchandise vers l'avant avec une force représentant 80 % de son poids. Le dispositif d'arrimage doit donc être dimensionné pour reprendre cet effort (norme EN 12195-1).

À titre de comparaison, les efforts à retenir latéralement et vers l'arrière sont de 0,5 fois le poids de la charge (50 %).$c370$,
  scoring_grid    = $c370$Réponse « 0,8 du poids / 80 % vers l'avant » : 2 points. Réponse donnant seulement « 0,5 » (valeur latérale/arrière) : 0 point. Bonne idée sans valeur chiffrée exacte : 1 point.$c370$
WHERE source_ref = 'CAPA-LOURD-G-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Selon le contrat type général, pour un envoi de 3 tonnes et plus, le chargement, le calage et l'arrimage incombent au donneur d'ordre (l'expéditeur/le chargeur), sous sa responsabilité. De la même manière, le déchargement incombe au destinataire.

Le transporteur, lui, fournit un véhicule adapté, le met à disposition en bon état, et le conducteur surveille les opérations et peut émettre des réserves s'il constate une exécution défectueuse.

À l'inverse, pour un envoi de moins de 3 tonnes, ces opérations (chargement, calage, arrimage, déchargement) sont réalisées par le transporteur, sous sa responsabilité.$c370$,
  scoring_grid    = $c370$Identifier le donneur d'ordre / expéditeur (et non le transporteur) pour les envois de 3 t et plus : 1 point. Préciser correctement le seuil de 3 tonnes et/ou la bascule vers le transporteur en dessous de 3 t : 1 point. Total 2 points.$c370$
WHERE source_ref = 'CAPA-LOURD-G-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La charge maximale autorisée sur un essieu simple (essieu le plus chargé) en France est de 13 tonnes (Code de la route, art. R.312-5).

Précisions utiles :
- Cette limite nationale de 13 t s'applique à l'essieu simple isolé, qu'il soit moteur ou non ; il n'existe pas, en droit français national, de plafond distinct « 12 t non moteur / 13 t moteur ».
- Essieu tandem (deux essieux rapprochés) : de l'ordre de 16 à 19 t selon l'écartement entre essieux.
- PTAC maximal d'un ensemble de 5 essieux : 44 tonnes.
- À ne pas confondre avec les valeurs harmonisées européennes applicables au trafic international (directive 96/53/CE) : essieu moteur 11,5 t, essieu simple non moteur 10 t — plus basses que la limite nationale française.$c370$,
  scoring_grid    = $c370$Réponse « 13 tonnes » : 2 points. Réponse « 12 tonnes » : 1 point (valeur proche mais non conforme au droit national français). Confusion avec une valeur européenne (10 t / 11,5 t) sans préciser le contexte international : 1 point. Autre valeur : 0 point.$c370$
WHERE source_ref = 'CAPA-LOURD-G-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Il s'agit de l'exemption ADR liée aux quantités transportées par unité de transport, dite exemption « 1.1.3.6 » (souvent appelée règle « des 1000 points »).

Principe : à chaque marchandise dangereuse est affecté un coefficient selon sa catégorie de transport ; en dessous d'un seuil de quantité maximale par unité de transport (plafond fixé à 1000 « points » en additionnant les quantités pondérées), le transport bénéficie d'un régime allégé. On échappe alors à une grande partie des exigences ADR : pas de certificat de formation ADR du conducteur, pas de plaques-étiquettes ni de panneau orange sur le véhicule, pas de document de transport ADR complet ni d'équipement de bord ADR intégral.

À ne pas confondre avec l'exemption « quantités limitées » (LQ), qui concerne le conditionnement en petits emballages et non le total transporté par unité de transport.$c370$,
  scoring_grid    = $c370$Citer l'exemption 1.1.3.6 / exemption liée aux quantités par unité de transport (ou « règle des 1000 points ») : 2 points. Réponse imprécise évoquant une exemption « sous seuil » sans la nommer correctement : 1 point. Confusion avec l'exemption « quantités limitées » (LQ) : 0 point.$c370$
WHERE source_ref = 'CAPA-LOURD-G-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Réponse : le permis de catégorie CE (anciennement EC).

Le permis C autorise la conduite d'un véhicule isolé de plus de 3,5 t (porteur). Dès que l'on attelle une semi-remorque à un tracteur routier pour former un ensemble articulé, il faut la catégorie CE, qui couvre la conduite d'un véhicule de catégorie C auquel est attelée une remorque ou semi-remorque dont le PTAC excède 750 kg. Le permis CE suppose la détention préalable du permis C.$c370$,
  scoring_grid    = $c370$2 points pour la réponse exacte « permis CE » (ou EC). 1 point si le candidat répond seulement « C » ou reste imprécis. 0 point sinon.$c370$
WHERE source_ref = 'CAPA-LOURD-H-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Réponse : à partir de 0,5 g d'alcool par litre de sang (soit 0,25 mg par litre d'air expiré).

Entre 0,5 g/L et 0,8 g/L de sang, la conduite constitue une contravention (amende forfaitaire, retrait de 6 points). À partir de 0,8 g/L de sang (0,40 mg/L d'air expiré), il s'agit d'un délit. À noter que pour les conducteurs en permis probatoire le seuil est abaissé à 0,2 g/L de sang (0,10 mg/L d'air expiré).$c370$,
  scoring_grid    = $c370$2 points pour « 0,5 g/L de sang » (ou l'équivalent 0,25 mg/L d'air expiré). 1 point si le seuil de 0,8 g/L (délit) est mentionné à la place, ou réponse partielle. 0 point sinon.$c370$
WHERE source_ref = 'CAPA-LOURD-H-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Réponse : 90 km/h sur autoroute.

Les véhicules de transport de marchandises dont le PTAC excède 3,5 t sont limités à 90 km/h sur autoroute. À titre de comparaison, sur les autres routes hors agglomération la limite est de 80 km/h. Sur les routes à chaussées séparées par un terre-plein central, elle reste de 90 km/h pour les PTAC de 3,5 à 12 t, mais tombe à 80 km/h au-delà de 12 t (et jusqu'à 50 km/h dans les descentes dangereuses signalées ou pour certains transports).$c370$,
  scoring_grid    = $c370$2 points pour « 90 km/h ». 1 point pour une réponse approchante mais imprécise. 0 point sinon.$c370$
WHERE source_ref = 'CAPA-LOURD-H-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Réponse : 5 ans.

Avant 60 ans, les catégories « lourdes » (C, CE, D, DE, ainsi que C1, C1E, D1, D1E) ont une durée de validité administrative de 5 ans. Le renouvellement est subordonné à une visite médicale d'aptitude. La périodicité se resserre ensuite avec l'âge (validité raccourcie au-delà de 60 ans).$c370$,
  scoring_grid    = $c370$2 points pour « 5 ans ». 0 point sinon.$c370$
WHERE source_ref = 'CAPA-LOURD-H-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Réponse : le Document Unique d'Évaluation des Risques Professionnels (DUERP), souvent appelé « document unique ».

Rendu obligatoire pour toute entreprise dès le premier salarié, il recense et évalue l'ensemble des risques pour la santé et la sécurité des travailleurs (unité de travail par unité de travail) et sert de base au programme d'actions de prévention. Il doit être tenu à jour et mis à disposition des salariés, du CSE, de l'inspection du travail et du service de prévention et de santé au travail.$c370$,
  scoring_grid    = $c370$2 points pour « Document Unique d'Évaluation des Risques Professionnels » (ou DUERP / document unique). 1 point si formulation approximative mais identifiable. 0 point sinon.$c370$
WHERE source_ref = 'CAPA-LOURD-H-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le protocole de sécurité est un document écrit obligatoire encadrant les opérations de chargement et de déchargement réalisées par une entreprise de transport (le transporteur) dans l'enceinte d'une entreprise d'accueil (chargeur, destinataire, plateforme). Il est régi par les articles R.4515-1 et suivants du Code du travail et remplace, pour ces opérations, le plan de prévention.

Rôle : organiser en amont la coordination entre l'entreprise d'accueil et le transporteur afin de prévenir les risques liés à l'opération (circulation dans l'enceinte, manutention, coactivité).

Contenu principal :
- Informations fournies par l'entreprise d'accueil : consignes de sécurité, lieu de livraison ou de prise en charge, modalités d'accès et de stationnement, caractéristiques du quai, matériels et engins de manutention mis à disposition, moyens de secours et personnes à contacter.
- Informations fournies par le transporteur : caractéristiques du véhicule, nature et conditionnement de la marchandise, précautions ou consignes particulières (marchandises dangereuses, sensibles).

Il est établi pour chaque entreprise de transport et vaut pour les opérations répétitives tant que les conditions restent identiques. Il s'applique quel que soit le tonnage du véhicule.$c370$,
  scoring_grid    = $c370$Définition (document écrit obligatoire pour les opérations de chargement/déchargement d'un transporteur dans l'enceinte d'une entreprise d'accueil) : 1 pt. Contenu / rôle (échange d'informations de sécurité entre les deux parties : accès, manutention, moyens de secours, nature de la marchandise) : 1 pt. Total = 2.$c370$
WHERE source_ref = 'CAPA-LOURD-H-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les véhicules de transport de marchandises dont le PTAC est supérieur à 7,5 tonnes font l'objet d'une interdiction générale et permanente de circulation le week-end.

Créneau : du samedi (ou de la veille d'un jour férié) à 22 heures jusqu'au dimanche (ou jour férié) à 22 heures.

Cette interdiction résulte de l'arrêté du 2 mars 2015 relatif à l'interdiction de circulation des véhicules de transport de marchandises de plus de 7,5 t de PTAC. Des dérogations existent (transports urgents, denrées périssables, animaux vivants, dépannage) et des interdictions complémentaires estivales et hivernales peuvent s'ajouter selon le calendrier fixé chaque année.$c370$,
  scoring_grid    = $c370$Bornes du créneau (samedi 22 h) : 1 pt. Fin du créneau (dimanche 22 h) : 1 pt. Total = 2. Une réponse mentionnant « tout le dimanche » ou « samedi 22 h au dimanche 22 h » est acceptée pour le plein.$c370$
WHERE source_ref = 'CAPA-LOURD-H-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La conduite après usage de stupéfiants constitue un délit, sanctionné indépendamment de tout accident et sans seuil de tolérance (tolérance zéro : la seule présence de stupéfiants dans l'organisme suffit).

Régime (article L.235-1 du Code de la route) :
- Peines encourues : 2 ans d'emprisonnement et 4 500 € d'amende.
- Retrait de 6 points sur le permis de conduire.
- Peines complémentaires : suspension ou annulation du permis, immobilisation du véhicule, obligation de stage de sensibilisation.

En cas de cumul avec un état alcoolique, ou en cas d'accident corporel, les peines sont aggravées. Le dépistage (salivaire, sanguin) peut être imposé au conducteur.$c370$,
  scoring_grid    = $c370$Qualification : il s'agit d'un délit avec tolérance zéro (aucun seuil) : 1 pt. Sanctions (au moins une peine correcte parmi : 2 ans d'emprisonnement / 4 500 € d'amende / retrait de 6 points / suspension ou annulation du permis) : 1 pt. Total = 2.$c370$
WHERE source_ref = 'CAPA-LOURD-H-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le sigle PAS désigne la conduite à tenir, dans l'ordre, par le témoin d'un accident :
- P : Protéger. Sécuriser les lieux et baliser (signaler l'accident, allumer les feux de détresse, poser le triangle de présignalisation, faire évacuer les personnes de la chaussée, couper le contact) afin d'éviter un suraccident.
- A : Alerter. Prévenir les secours (15 SAMU, 18 pompiers, 112 numéro d'urgence européen) en indiquant le lieu précis, la nature de l'accident, le nombre et l'état des victimes.
- S : Secourir. Porter secours aux victimes dans la limite de ses compétences, sans les déplacer sauf danger immédiat, en attendant l'arrivée des secours.$c370$,
  scoring_grid    = $c370$Développement correct des trois lettres (Protéger, Alerter, Secourir) : 2 pts (soit environ 0,66 pt par item, arrondi ; 1 pt si une seule des trois notions est manquante ou erronée). Total = 2.$c370$
WHERE source_ref = 'CAPA-LOURD-H-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le permis de conduire du groupe lourd (catégorie C) est soumis à un contrôle médical périodique dont la fréquence dépend de l'âge du conducteur :
- jusqu'à 60 ans : tous les 5 ans ;
- de 60 à 76 ans : tous les 2 ans ;
- au-delà de 76 ans : tous les ans.

Un conducteur âgé de 65 ans se situe dans la tranche 60-76 ans : il doit donc renouveler la visite médicale de son permis C tous les 2 ans. À défaut de visite valide, la validité de la catégorie lourde est suspendue et le conducteur n'est plus autorisé à conduire un véhicule du groupe lourd.$c370$,
  scoring_grid    = $c370$Réponse chiffrée exacte : tous les 2 ans : 1 pt. Justification par la tranche d'âge (60 à 76 ans) : 1 pt. Total = 2.$c370$
WHERE source_ref = 'CAPA-LOURD-H-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$On l'appelle le COMMETTANT (également désigné comme le donneur d'ordre). C'est la personne, physique ou morale, pour le compte de laquelle le commissionnaire de transport organise l'acheminement de la marchandise. Point clé à distinguer : le commissionnaire agit EN SON NOM PROPRE mais POUR LE COMPTE du commettant. Le commettant n'a de relation contractuelle qu'avec le commissionnaire ; il n'entre pas directement en rapport avec les transporteurs substitués, que le commissionnaire choisit librement. Réponses également acceptées comme équivalentes : donneur d'ordre, client donneur d'ordre. À écarter : « mandant », terme réservé au contrat de mandat (transitaire/mandataire), et « expéditeur », qui désigne un rôle logistique et non la qualité juridique de partie au contrat de commission.$c370$,
  scoring_grid    = $c370$Terme exact « commettant » (ou « donneur d'ordre ») : 1 pt. Justification correcte du positionnement (commissionnaire agit en son nom propre / pour le compte du commettant, ou distinction d'avec « mandant ») : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M1-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$L'engagement porte sur le RÉSULTAT : il s'agit d'une obligation de résultat. a) Analyse des faits : le chargeur n'impose ni le mode (route, fer, fluvial, combiné pour ce Lyon-Rotterdam) ni le transporteur, et paie un prix global. Cette liberté totale d'organisation contre un prix forfaitaire est la signature du contrat de commission de transport (et non d'un simple mandat où l'organisateur agirait sur instructions détaillées). b) Nature de l'engagement : parce qu'il organise librement, le commissionnaire s'engage à faire parvenir la marchandise à destination dans les conditions convenues (délai, intégrité). Il ne se libère pas en prouvant qu'il a mis en œuvre des moyens diligents (ce serait une obligation de moyens) ; il doit le résultat. c) Conséquence : le commissionnaire est présumé responsable en cas d'inexécution ou de mauvaise exécution et, en outre, il est garant de ses substitués. Il ne s'exonère qu'en établissant une cause étrangère (force majeure, vice propre de la marchandise, faute du commettant).$c370$,
  scoring_grid    = $c370$Réponse correcte « le résultat » / obligation de résultat : 1 pt. Justification (liberté d'organisation + prix global → engagement de résultat, ou opposition moyens/résultat) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M1-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le chargeur achète les trois « UN » suivants : 1) UN interlocuteur unique : un seul responsable qui pilote toute la chaîne de bout en bout (guichet unique), quel que soit le nombre de transporteurs, de modes ou de frontières. 2) UN prix global (forfaitaire) : une rémunération d'ensemble pour l'opération organisée, et non le détail des coûts de chaque maillon. 3) UNE responsabilité unique de bout en bout : le commissionnaire répond de la bonne fin de l'acheminement et il est garant du fait de ses substitués ; le chargeur n'a donc qu'un seul débiteur à actionner en cas de dommage ou de retard. En synthèse : un interlocuteur, un prix, une responsabilité. C'est la valeur ajoutée du commissionnaire par rapport au recours direct à plusieurs transporteurs.$c370$,
  scoring_grid    = $c370$0,5 pt par « UN » correctement identifié (interlocuteur unique ; prix global ; responsabilité unique de bout en bout) = 1,5 pt. Cohérence / formulation en trois « UN » et lien avec la valeur ajoutée : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M1-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les trois indices principaux du faisceau d'indices retenu par le juge pour qualifier une opération de commission de transport sont : 1) La LIBERTÉ D'ORGANISATION : l'organisateur choisit librement les voies, les modes et les transporteurs (le donneur d'ordre ne lui impose ni itinéraire, ni mode, ni sous-traitant). 2) L'ACTION EN SON NOM PROPRE : l'organisateur contracte avec les transporteurs substitués en son propre nom (et pour le compte du commettant), et non au nom du client comme le ferait un mandataire/transitaire. 3) LE PRIX GLOBAL (forfaitaire) : la rémunération est convenue de manière globale pour l'ensemble de l'opération, sans reddition de compte poste par poste, ce qui traduit une prestation d'organisation et non un simple mandat rémunéré. Rappel de méthode : c'est le faisceau (réunion de ces indices), et non un indice isolé, qui emporte la qualification ; à défaut, l'opération peut être requalifiée en mandat (transitaire) ou en contrat de transport.$c370$,
  scoring_grid    = $c370$0,5 pt par indice correct (liberté d'organisation ; action en son nom propre ; prix global/forfaitaire) = 1,5 pt. Mention du raisonnement par faisceau d'indices (appréciation globale) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M1-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$OUI. Le commettant peut demander réparation au commissionnaire, alors même que celui-ci n'a commis aucune faute personnelle. a) Fondement : le commissionnaire de transport est GARANT de ses substitués. Il répond de plein droit des dommages causés par les transporteurs et intermédiaires qu'il se substitue pour exécuter l'opération, comme de son propre fait. Cette responsabilité est indépendante de toute faute prouvée du commissionnaire lui-même. b) Application : le transporteur choisi ayant endommagé la marchandise, le commettant a un débiteur unique et direct, le commissionnaire, qu'il peut actionner sans avoir à rechercher ni prouver une faute de ce dernier. c) Recours et limites : après avoir indemnisé le commettant, le commissionnaire dispose d'une action récursoire contre le transporteur fautif (le vrai responsable du dommage). Il ne peut s'exonérer qu'en démontrant une cause d'exonération (force majeure, vice propre de la marchandise, faute du commettant) ; la responsabilité peut par ailleurs être plafonnée par les limitations d'indemnité applicables (clauses/plafonds du contrat type ou de la convention de transport du substitué). Le principe de garantie du fait des substitués figure aux articles L. 132-4 et suivants du Code de commerce (la garantie du fait de l'intermédiaire relevant plus précisément de l'article L. 132-5).$c370$,
  scoring_grid    = $c370$Réponse « oui » : 0,5 pt. Fondement correct = garant de ses substitués / responsabilité de plein droit sans faute personnelle : 1 pt. Élément complémentaire pertinent (action récursoire contre le transporteur, ou causes d'exonération, ou plafonds) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M1-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La différence essentielle tient au régime de responsabilité vis-à-vis des transporteurs et intervenants substitués.

a. Le commissionnaire de transport organise librement l'acheminement, en son nom propre et pour le compte du commettant. Il est tenu d'une obligation de résultat et il est GARANT de ses substitués : il répond de plein droit des dommages (avaries, pertes, retards) causés par les transporteurs qu'il se substitue, comme s'il les avait lui-même commis, sans que le client ait à prouver une faute personnelle du commissionnaire. Il ne peut s'exonérer qu'en établissant la force majeure, le vice propre de la marchandise ou la faute de l'expéditeur/destinataire.

b. Le mandataire (transitaire) agit au nom et pour le compte du mandant, sur ses instructions, sans liberté d'organisation. Il n'est tenu que d'une obligation de moyens : il ne répond que de ses propres fautes personnelles dûment prouvées (mauvaise exécution du mandat, erreur de réexpédition, négligence), et il n'est PAS garant des transporteurs qu'il met en relation avec son mandant.

En synthèse : le commissionnaire est responsable de plein droit du fait d'autrui (ses substitués) ; le transitaire n'est responsable que de sa propre faute prouvée.$c370$,
  scoring_grid    = $c370$1 pt : responsabilité du commissionnaire = obligation de résultat + garant de plein droit de ses substitués. 1 pt : responsabilité du mandataire/transitaire = obligation de moyens, répond seulement de sa faute personnelle prouvée, non garant des substitués. Total = 2.$c370$
WHERE source_ref = 'COMM-M1-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le réflexe professionnel attendu est de ne jamais se fier à une information réglementaire ancienne ou rapportée par un tiers, aussi assuré soit-il, et de vérifier soi-même le droit en vigueur au moment de la création.

a. Prendre conscience que le régime d'accès à la profession évolue (textes, conditions, seuils) : une connaissance datant de dix ans peut être périmée. L'assurance du confrère et son registre ne valent pas source de droit actuelle.

b. Vérifier auprès des sources officielles et à jour les conditions actuelles d'accès et d'inscription au registre des commissionnaires : exigence de capacité professionnelle spécifique de commissionnaire (attestation de capacité, par équivalence de diplôme, expérience ou examen), honorabilité professionnelle et capacité financière, puis inscription auprès de l'autorité compétente (DREAL/service de l'État en charge des transports) avant tout début d'activité.

En synthèse : réflexe de vérification à la source et à jour, plutôt que confiance à une pratique ou un souvenir ancien.$c370$,
  scoring_grid    = $c370$1 pt : identifier le risque = l'information a dix ans, la réglementation a pu changer, ne pas se fier à un tiers/souvenir. 1 pt : action concrète = vérifier le droit en vigueur à la source officielle (conditions actuelles d'inscription au registre : capacité professionnelle de commissionnaire, honorabilité, capacité financière). Total = 2.$c370$
WHERE source_ref = 'COMM-M1-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La formule résume le mécanisme de marge du commissionnaire : il VEND ses prestations à ses clients au détail, à l'unité (au colis, à l'envoi, au prix fractionné), tout en ACHETANT la capacité de transport en gros, en volume massifié (au camion complet, à la traction pleine, à des tarifs de gros négociés) ; en groupant de nombreux petits envois pour remplir des moyens de transport complets, il crée sa valeur ajoutée et sa marge par l'écart entre le prix de détail encaissé et le coût de gros supporté.$c370$,
  scoring_grid    = $c370$1 pt : « vendre au colis » = facturer au client au détail, à l'unité/envoi fractionné. 1 pt : « acheter au camion » = acheter la capacité en gros/massifiée (camion complet), la marge naissant du groupage et de l'écart détail/gros. Total = 2.$c370$
WHERE source_ref = 'COMM-M1-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Parce que la qualification juridique d'un contrat ne dépend pas de son intitulé mais de la réalité des prestations effectivement exécutées.

a. Le juge n'est pas lié par le nom que les parties ont donné au contrat (« prestations de transit ») ; il requalifie d'après la nature réelle de l'opération et les prestations concrètement fournies.

b. Dès lors que l'opérateur organise librement le transport, en son nom propre, pour le compte d'un commettant, et qu'il s'engage sur un résultat (acheminement de bout en bout), il exerce une activité de commission de transport, quel que soit l'intitulé retenu. Il est alors requalifié en commissionnaire et se voit appliquer le régime correspondant, notamment la responsabilité de plein droit du fait de ses substitués, plus lourde que celle du simple transitaire mandataire.

En synthèse : c'est le faisceau d'indices (liberté d'organisation, nom propre, obligation de résultat, garantie des substitués) qui commande la qualification, pas l'étiquette du contrat.$c370$,
  scoring_grid    = $c370$1 pt : principe = le juge qualifie d'après la réalité de la prestation, pas d'après l'intitulé du contrat. 1 pt : critères de la commission (organisation libre, en son nom propre, obligation de résultat) entraînant la requalification et la responsabilité de plein droit des substitués. Total = 2.$c370$
WHERE source_ref = 'COMM-M1-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Deux tendances de fond parmi les suivantes, chacune assortie d'une conséquence concrète pour l'offre de service :

a. Digitalisation et plateformes numériques (dématérialisation des documents, bourses de fret en ligne, IA d'affrètement). Conséquence concrète : l'offre doit intégrer la traçabilité en temps réel des envois, le suivi/tracking accessible au client et l'automatisation des cotations et de la réservation.

b. Transition écologique et décarbonation du transport. Conséquence concrète : développement d'offres multimodales (report modal rail/fluvial), optimisation du taux de remplissage et fourniture au client d'un calcul/reporting de l'empreinte carbone des expéditions.

Autres tendances recevables (avec conséquence associée) : essor du e-commerce et de la logistique du dernier kilomètre (offres de livraison rapide et de gestion des flux fractionnés et des retours) ; mondialisation et reconfiguration des chaînes d'approvisionnement (offres de sécurisation/diversification des routes, conseil supply chain) ; complexité douanière et réglementaire croissante (offre de conseil douanier, dédouanement centralisé, gestion de la conformité). Toute réponse citant deux tendances réelles avec une conséquence pertinente pour l'offre est acceptée.$c370$,
  scoring_grid    = $c370$1 pt par couple « tendance de fond + conséquence concrète et cohérente pour l'offre de service », pour deux tendances distinctes (0,5 pt la tendance seule sans conséquence exploitable). Total = 2.$c370$
WHERE source_ref = 'COMM-M1-QC-10' AND type='qr';

-- ⚠️ COMM-M2-QC-01 : [À CONFIRMER: plafond exact d'indemnisation du transporteur aérien pour marchandise sous la Convention de Montréal — 22 DTS/kg à l'origine, relevé à 26 DTS/kg depuis le 28/12/2019 (révision quinquennale OACI). Le corrigé reste volontairement qualitatif et n'affirme aucun chiffre.] Précision réglementaire ajoutée : la garantie du fait des substitués repose surtout sur l'art. L.132-6 C. com. (garant
UPDATE public.question_bank SET
  expected_answer = $c370$a. Qui indemnise en premier. C'est le COMMISSIONNAIRE de transport qui indemnise le client (commettant) en premier. Le commissionnaire est garant de ses substitués : il répond de plein droit du fait des transporteurs qu'il se substitue pour exécuter le déplacement (responsabilité contractuelle de résultat ; garantie des avaries et pertes, art. L.132-5, et garantie du fait du transporteur/commissionnaire substitué, art. L.132-6 du Code de commerce, la garantie de l'arrivée dans les délais relevant de l'art. L.132-4). Le client n'a donc pas à agir d'abord contre le transporteur aérien : il se retourne directement contre son commissionnaire, tenu de la bonne fin de l'opération. b. Ce qui se passe ensuite. Après avoir désintéressé le client, le commissionnaire exerce un recours (action récursoire / subrogatoire) contre le transporteur aérien substitué, auteur matériel du dommage. Ce recours s'exerce dans les termes et les limites du contrat de transport aérien : le commissionnaire ne récupère que ce que le régime aérien permet, la responsabilité du transporteur aérien étant plafonnée par la Convention de Montréal en cas de destruction de marchandise (limitation par kilogramme, sauf déclaration spéciale d'intérêt à la livraison ou faute équivalente au dol). Le commissionnaire supporte donc, le cas échéant, le différentiel entre l'indemnité versée au client et le plafond récupérable auprès du substitué. Point de méthode : le commissionnaire peut opposer à son client les mêmes causes d'exonération et limitations que celles dont bénéficie le transporteur substitué (il n'aggrave pas sa situation), mais il reste l'interlocuteur premier de l'indemnisation.$c370$,
  scoring_grid    = $c370$a. Le commissionnaire indemnise en premier, car garant de plein droit de ses substitués (obligation de résultat) : 1 pt. b. Recours récursoire/subrogatoire du commissionnaire contre le transporteur aérien substitué, dans les limites du régime aérien (plafond) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M2-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les quatre grandes obligations du commissionnaire de transport envers son commettant sont : 1. Organiser librement le transport : le commissionnaire choisit en son nom propre les voies, moyens et transporteurs (modes, itinéraires, sous-traitants) pour acheminer la marchandise ; c'est le coeur de sa fonction, par opposition au transporteur qui exécute et au mandataire/transitaire qui agit sur instructions. 2. Obligation de résultat (bonne fin de l'opération) : il s'engage à faire parvenir la marchandise à destination dans les conditions et délais convenus ; il ne s'agit pas d'une simple obligation de moyens. 3. Devoir d'information et de conseil : il doit renseigner et conseiller son commettant (choix des solutions, réglementations, douane, Incoterms, opportunité d'une assurance ad valorem, risques particuliers de l'envoi). 4. Répondre de ses substitués et rendre compte : il est garant du fait des transporteurs et intermédiaires qu'il se substitue, et il doit rendre compte de sa mission à son commettant (reddition de comptes, restitution des documents et sommes).$c370$,
  scoring_grid    = $c370$0,5 pt par obligation correctement identifiée (organiser librement le transport ; obligation de résultat / bonne fin ; devoir d'information et de conseil ; garantie des substitués et reddition de comptes). 4 x 0,5 = 2 pts. Tolérance : une formulation équivalente d'une des obligations est acceptée.$c370$
WHERE source_ref = 'COMM-M2-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Recevabilité. Non : l'action n'est pas recevable, elle est prescrite. b. Pourquoi. Les actions nées du contrat de transport et de commission de transport se prescrivent par un délai bref d'UN AN à compter, en cas de retard ou d'avarie, de la livraison de la marchandise (prescription annale, art. L.133-6 du Code de commerce, appliqué à la commission de transport). Ici, le client agit quatorze mois après la livraison, soit au-delà d'un an, et aucun acte interruptif de prescription n'est intervenu entre-temps (par exemple une reconnaissance de responsabilité, une citation en justice ou une mesure équivalente). Le délai a donc couru sans interruption et est expiré : l'action est éteinte par la prescription et sera déclarée irrecevable si le commissionnaire soulève la fin de non-recevoir. Réserve : ce délai annal ne joue pas en cas de fraude ou d'infidélité du transporteur/commissionnaire, hypothèse non caractérisée dans l'énoncé.$c370$,
  scoring_grid    = $c370$a. Action irrecevable / prescrite (conclusion) : 1 pt. b. Justification : prescription d'un an propre au transport et à la commission, point de départ à la livraison, dépassement (14 mois) et absence d'acte interruptif : 1 pt. Total = 2 pts. Bonus non obligatoire : réserve de la fraude/infidélité.$c370$
WHERE source_ref = 'COMM-M2-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Le grief invocable par le client. Le client peut reprocher au commissionnaire un manquement à son devoir d'information et de conseil. S'agissant d'une oeuvre d'art de grande valeur, le commissionnaire, professionnel averti, devait spontanément attirer l'attention du client sur l'insuffisance des plafonds légaux et contractuels d'indemnisation (limitation par colis / par kilogramme) au regard de la valeur réelle du bien, et lui proposer la souscription d'une assurance ad valorem (assurance de la marchandise à sa valeur déclarée). En s'abstenant de proposer cette couverture, le commissionnaire a privé le client de la possibilité de garantir intégralement son bien. b. La conséquence. Ce manquement engage la responsabilité personnelle du commissionnaire, distincte du plafond d'indemnisation du dommage matériel. Le préjudice réparable correspond à la perte de chance pour le client d'avoir été correctement assuré, c'est-à-dire, en pratique, à la différence entre l'indemnité plafonnée qu'il perçoit au titre du sinistre et la valeur réelle de l'oeuvre qu'une assurance ad valorem aurait couverte. Nuance : le commissionnaire peut atténuer sa responsabilité s'il démontre qu'il avait effectivement informé le client et que celui-ci a refusé l'assurance, ou que le client, professionnel, connaissait parfaitement la valeur et le besoin de couverture.$c370$,
  scoring_grid    = $c370$a. Identification du manquement : violation du devoir d'information et de conseil (défaut de proposition d'assurance ad valorem au vu de la valeur et de l'insuffisance des plafonds) : 1 pt. b. Conséquence : responsabilité du commissionnaire réparant la perte de chance d'être assuré / le différentiel entre indemnité plafonnée et valeur réelle : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M2-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Obligation violée. Le commettant (donneur d'ordre / expéditeur) a violé son obligation de déclaration exacte, complète et loyale de la marchandise remise au transport. Il doit fournir des indications conformes sur la nature, le poids et surtout la dangerosité du lot. En minorant le poids déclaré et en omettant la mention de dangerosité, il a manqué à cette obligation de déclaration et à son devoir de loyauté/bonne foi envers le commissionnaire ; s'agissant d'un lot dangereux, il a également méconnu les exigences propres au transport de marchandises dangereuses (déclaration et documentation ADR pour la route). b. Conséquences. 1) La fausse déclaration constitue une faute du commettant, cause d'exonération : le commissionnaire (et le transporteur substitué) n'est pas responsable des dommages résultant de ce vice de déclaration, dont l'expéditeur supporte seul les conséquences. 2) Le commettant doit garantir et indemniser le commissionnaire de tous les préjudices causés par sa déclaration inexacte ou incomplète : dommages aux autres marchandises, au matériel, aux tiers, surcoûts, immobilisation, amendes et sanctions administratives liées au défaut de déclaration de la dangerosité. 3) Le cas échéant, le commissionnaire est fondé à refuser ou interrompre l'acheminement du lot non conforme et peut engager la responsabilité du commettant, sans préjudice des sanctions réglementaires encourues par ce dernier pour transport de matière dangereuse non déclarée.$c370$,
  scoring_grid    = $c370$a. Obligation violée : obligation de déclaration exacte et complète de la marchandise (poids et dangerosité) incombant au commettant/expéditeur, devoir de loyauté (et régime ADR pour la dangerosité) : 1 pt. b. Conséquences : faute du commettant exonérant le commissionnaire + obligation du commettant de garantir/indemniser le commissionnaire des préjudices et sanctions (surcoûts, dommages, amendes) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M2-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le client d'un commissionnaire de transport « n'a qu'un interlocuteur » parce que le commissionnaire agit en son nom propre et est garant de ses substitués.

a. Un seul cocontractant. Le commettant (client) conclut un contrat de commission avec le seul commissionnaire, qui organise librement le transport en son nom propre. Le client n'est lié contractuellement à aucun des transporteurs, manutentionnaires ou entrepositaires que le commissionnaire s'est substitués : il ignore même souvent leur identité.

b. Responsabilité de plein droit du fait des substitués. Le commissionnaire répond des dommages causés par tous les intervenants qu'il s'est substitués comme s'il les avait causés lui-même (garantie de plein droit). En cas de sinistre, le client réclame donc au seul commissionnaire, sans avoir à identifier le maillon fautif ni à prouver sa faute personnelle.

c. Conséquence pratique. Le commissionnaire indemnise le client, puis exerce à son tour son recours contre le substitué réellement responsable. Pour le client, cela se traduit par un guichet unique, plus simple et plus sûr : une seule réclamation, un seul responsable désigné d'avance.$c370$,
  scoring_grid    = $c370$1 pt : identifier le fondement — le commissionnaire agit en son nom propre et est garant de ses substitués (responsabilité de plein droit du fait des transporteurs/intervenants substitués). / 1 pt : en tirer la conséquence pratique — le client réclame au seul commissionnaire, sans identifier le maillon fautif ni prouver sa faute ; le commissionnaire se retourne ensuite contre le substitué responsable. Total = 2.$c370$
WHERE source_ref = 'COMM-M2-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Sur un segment routier international soumis à la CMR (Convention de Genève de 1956), deux réflexes préservent le recours du commissionnaire contre le transporteur routier.

a. Émettre des réserves motivées dans les délais de la CMR (art. 30). En cas de pertes ou avaries apparentes, les réserves doivent être formulées au moment de la livraison, sur le document de transport (récépissé / lettre de voiture CMR). En cas d'avaries non apparentes, elles doivent être adressées par écrit dans les 7 jours suivant la livraison (dimanches et jours fériés non compris). À défaut de réserves dans ces délais, la marchandise est présumée avoir été livrée conforme, ce qui ruine le recours.

b. Agir avant l'expiration du délai de prescription et organiser une expertise contradictoire. L'action née d'un transport CMR se prescrit par 1 an (porté à 3 ans en cas de dol ou de faute équivalente au dol — art. 32). Il faut donc engager le recours ou interrompre/suspendre la prescription à temps (une réclamation écrite suspend le délai) et provoquer sans tarder une expertise contradictoire pour établir la cause, la nature et l'étendue du dommage, preuve indispensable au recours.

En résumé : (1) réserves régulières et motivées dans les délais CMR, (2) surveillance du délai de prescription d'un an et constitution de la preuve par expertise contradictoire.$c370$,
  scoring_grid    = $c370$1 pt : formuler des réserves motivées dans les délais CMR (à la livraison pour l'avarie apparente ; par écrit dans les 7 jours pour l'avarie non apparente), sous peine de présomption de livraison conforme. / 1 pt : préserver/interrompre le délai de prescription (1 an, 3 ans en cas de dol) et provoquer une expertise contradictoire pour établir le dommage. Total = 2.$c370$
WHERE source_ref = 'COMM-M2-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Sur une chaîne combinée mer + route dont l'origine du dommage n'est pas encore localisée, l'expertise ne vaut que si elle est contradictoire : chaque partie susceptible d'être responsable doit être convoquée pour que le rapport lui soit opposable.

a. Qui convoquer. Il faut convoquer tous les maillons potentiellement en cause et leurs assureurs :
- le transporteur maritime (armateur / compagnie ou son agent) ;
- le ou les transporteurs routiers (pré- et post-acheminement) ;
- le ou les manutentionnaires / opérateurs portuaires (empotage, dépotage, manutention à quai), souvent des lieux de dommage sur ce type de chaîne ;
- le cas échéant l'entrepositaire ;
- son propre assureur (RC du commissionnaire) et l'assureur facultés (marchandises) ;
- le commettant / réclamant.

b. Pourquoi. Parce que l'origine du dommage (mer, manutention ou route) est indéterminée : tant que le segment fautif n'est pas identifié, chaque intervenant doit être présent ou régulièrement appelé. Une expertise n'est opposable qu'aux parties qui y ont été convoquées ; un rapport établi hors la présence d'un substitué ne pourrait pas lui être opposé et ferait perdre le recours à son encontre. La convocation générale permet à la fois de localiser le dommage sur la chaîne et de préserver le recours contre le véritable responsable.$c370$,
  scoring_grid    = $c370$1 pt : citer les parties à convoquer — transporteur maritime, transporteur(s) routier(s), manutentionnaire/opérateur portuaire, et les assureurs concernés (RC commissionnaire et facultés). / 1 pt : justifier — l'expertise doit être contradictoire pour être opposable à chaque substitué, et l'origine du dommage étant inconnue il faut appeler tous les maillons pour localiser le sinistre et préserver le recours contre le vrai responsable. Total = 2.$c370$
WHERE source_ref = 'COMM-M2-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La formule résume la double contrainte qui pèse sur le commissionnaire, garant de ses substitués mais tributaire de délais pour se retourner contre eux.

a. « Il paie ». En tant que garant de plein droit des transporteurs et intervenants qu'il s'est substitués, le commissionnaire doit indemniser son commettant dès lors qu'un dommage survient dans la chaîne, sans que le client ait à prouver la faute du maillon fautif. Il ne peut pas se dérober à cette obligation d'indemnisation.

b. « Sans recours ». Son droit de récupérer les sommes versées auprès du transporteur réellement responsable (le recours) est enfermé dans des délais stricts : émission de réserves à la livraison ou dans les délais légaux, puis action avant l'expiration de la prescription (par ex. 1 an en CMR). S'il laisse « filer » ces délais — absence de réserves régulières, prescription acquise — son recours est éteint.

c. Conséquence. Le commissionnaire indemnise le client mais ne peut plus rien récupérer du substitué fautif : il supporte alors définitivement et sur ses propres deniers (ou ceux de son assureur) le poids du sinistre. La rigueur dans la gestion des délais de recours est donc une obligation professionnelle essentielle.$c370$,
  scoring_grid    = $c370$1 pt : expliquer le « il paie » — garant de ses substitués, le commissionnaire doit indemniser le client de plein droit. / 1 pt : expliquer le « sans recours » — l'expiration des délais (réserves, prescription) éteint son droit de se retourner contre le transporteur, si bien qu'il supporte définitivement la charge du sinistre. Total = 2.$c370$
WHERE source_ref = 'COMM-M2-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Quand un conteneur arrive avarié mais que l'origine du dommage est inconnue, notifier des réserves conservatoires à chaque substitué (et non au seul dernier transporteur) est une mesure de préservation des recours.

a. L'origine du dommage est indéterminée. Sur une chaîne conteneurisée, le dommage a pu naître à n'importe quel maillon : empotage, manutention portuaire au départ, transport maritime, dépotage, post-acheminement routier. Rien ne permet, au stade de la livraison, d'imputer l'avarie au seul dernier transporteur.

b. Chaque recours est autonome. Le commissionnaire a conclu un contrat distinct avec chaque substitué, soumis à ses propres règles, délais et présomptions. Faute de réserves formulées à l'égard d'un intervenant dans les délais qui lui sont applicables, celui-ci bénéficie d'une présomption de livraison conforme et le recours contre lui est perdu, même s'il se révèle ensuite être le vrai responsable.

c. Rôle des réserves conservatoires. En notifiant des réserves à tous les substitués, on interrompt cette forclusion à l'égard de chacun et l'on maintient ouverts tous les recours dans l'attente de l'expertise qui localisera le dommage. Si l'on ne visait que le dernier transporteur et que l'expertise désignait finalement le maritime ou le manutentionnaire, le recours contre le responsable réel serait déjà éteint. La réserve conservatoire « tous azimuts » est donc la seule façon de ne pas se retrouver à payer sans recours.$c370$,
  scoring_grid    = $c370$1 pt : l'origine du dommage étant inconnue, tout maillon peut être responsable et chaque recours est autonome, avec ses propres délais et sa propre présomption de livraison conforme. / 1 pt : des réserves adressées à chaque substitué préservent/n'éteignent pas le recours contre le véritable responsable une fois le dommage localisé, alors que viser le seul dernier transporteur ferait perdre le recours contre les autres. Total = 2.$c370$
WHERE source_ref = 'COMM-M2-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Signification des deux sigles :
- FCL = « Full Container Load » (conteneur complet) : le conteneur est réservé et empoté pour un seul client/une seule expédition ; l'unité de transport n'est pas partagée.
- LCL = « Less than Container Load » (conteneur de groupage) : la marchandise n'occupe qu'une partie du conteneur, qui est partagé entre plusieurs expéditions consolidées par le commissionnaire ou son agent.

b. Lequel correspond au groupage :
C'est le LCL qui correspond au groupage. Pour 5 palettes vers Montréal, volume qui ne remplit pas un conteneur complet, la solution économiquement cohérente est le LCL : la marchandise est groupée avec celle d'autres chargeurs, chacun ne payant que le volume/poids taxable qu'il occupe. Le FCL ne se justifierait que si le client voulait un conteneur dédié (sûreté, absence de rupture de charge, volume suffisant).$c370$,
  scoring_grid    = $c370$a. Signification correcte des deux sigles FCL et LCL (0,5 par sigle) = 1 pt. b. Identification du LCL comme mode de groupage avec justification (volume < conteneur complet) = 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M3-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Document qui matérialise le contrat :
Pour la partie routière internationale, le contrat de transport est matérialisé par la lettre de voiture CMR (établie en application de la Convention de Genève du 19 mai 1956, dite Convention CMR, applicable au transport routier international de marchandises). Elle constitue la preuve du contrat, de la prise en charge et de l'état de la marchandise.

b. Plafond d'indemnisation au kilo :
La Convention CMR limite l'indemnité du transporteur à 8,33 DTS (Droits de Tirage Spéciaux) par kilogramme de poids brut manquant ou avarié (article 23 de la Convention CMR). Ce plafond s'applique sauf déclaration de valeur ou déclaration d'intérêt spécial à la livraison, ou faute lourde/dol privant le transporteur du bénéfice de la limitation.$c370$,
  scoring_grid    = $c370$a. Identification de la lettre de voiture CMR comme document contractuel du routier international = 1 pt. b. Plafond de 8,33 DTS par kilogramme de poids brut manquant/avarié = 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M3-QC-02' AND type='qr';

-- ⚠️ COMM-M3-QC-03 : [À CONFIRMER: la liste exacte des « cinq critères » telle qu'enseignée dans le module M3. La formulation retenue (nature de la marchandise, délai, coût, distance/géographie, sûreté/réglementation) reflète les critères standards du choix modal, mais l'intitulé précis des cinq items du support de cours doit être vérifié pour aligner le barème. Le barème restant en 0,5 pt/critère (limite 4), il tolèr
UPDATE public.question_bank SET
  expected_answer = $c370$Le commissionnaire, libre d'organiser le transport mais tenu à une obligation de résultat, croise systématiquement plusieurs critères avant de recommander un mode. Quatre critères parmi les cinq attendus :
1. La nature de la marchandise (poids, volume, dimensions, dangerosité, périssabilité, valeur intrinsèque) ;
2. Le délai / l'urgence exigés par le client (date de mise à disposition, contraintes de livraison) ;
3. Le coût / budget (rapport prix-service, incidence sur le prix de revient du client) ;
4. La distance et la géographie origine-destination (accessibilité, ruptures de charge, infrastructures disponibles).
Cinquième critère fréquemment attendu : la sûreté / sécurité et les contraintes réglementaires-douanières (fiabilité, risque de vol ou d'avarie, formalités).
Citer quatre de ces critères, correctement formulés, suffit pour la note maximale.$c370$,
  scoring_grid    = $c370$0,5 pt par critère pertinent et correctement formulé, dans la limite de quatre critères = 2 pts. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M3-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Ce qu'est le DTS :
Le DTS (Droit de Tirage Spécial ; en anglais SDR, Special Drawing Right) est une unité de compte internationale créée et gérée par le Fonds Monétaire International (FMI). Sa valeur est déterminée à partir d'un panier de grandes devises (dollar américain, euro, yuan chinois, yen japonais, livre sterling). Les conventions de transport international (CMR pour la route, Règles de La Haye-Visby et Convention de Hambourg pour la mer, Convention de Montréal pour l'aérien) expriment leurs plafonds d'indemnisation en DTS, et non en euros, pour neutraliser les différences monétaires entre États.

b. Pourquoi l'indemnité en euros a changé entre deux courriers :
Parce que le plafond est fixé en DTS, unité stable, mais qu'il doit être converti en euros pour être communiqué au client. Or le taux de change DTS/euro évolue chaque jour (le panier de devises fluctue). La conversion effectuée à la date du premier courrier et celle effectuée à la date du second courrier ne donnent donc pas le même montant en euros, alors même que le plafond en DTS n'a pas bougé. La variation reflète uniquement l'évolution du cours du DTS entre les deux dates, pas une modification du droit à indemnisation.$c370$,
  scoring_grid    = $c370$a. Définition du DTS (unité de compte du FMI, panier de devises, référence des conventions transport) = 1 pt. b. Explication de la variation par la conversion DTS→euro à un taux de change quotidien fluctuant, le plafond en DTS restant inchangé = 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M3-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Pourquoi le connaissement est un « titre représentatif de la marchandise » :
Le connaissement maritime (bill of lading, B/L) ne se limite pas à prouver le contrat de transport et la prise en charge : il incorpore le droit sur la marchandise. La détention régulière du document vaut détention de la marchandise elle-même ; celui qui possède le connaissement original endossé est réputé avoir le droit d'exiger la livraison au port de destination. On dit qu'il « représente » la marchandise parce que le titre et la marchandise circulent ensemble juridiquement : transférer le connaissement, c'est transférer le droit de disposer de la cargaison.

b. Possibilité commerciale ouverte pendant la traversée :
Parce qu'il est négociable (transmissible par endossement lorsqu'il est établi « à ordre »), le connaissement permet de vendre, revendre ou nantir la marchandise alors qu'elle est encore en mer, sans attendre son arrivée. L'acheteur peut ainsi acquérir la cargaison par simple endossement du titre, ou le vendeur l'utiliser comme garantie (crédit documentaire, gage bancaire). Le connaissement rend donc la marchandise commercialement mobilisable pendant toute la traversée.$c370$,
  scoring_grid    = $c370$a. Explication du caractère représentatif : la possession du titre vaut droit sur la marchandise / droit d'en exiger la livraison = 1 pt. b. Possibilité de vendre, revendre ou nantir la marchandise en cours de transport grâce au caractère négociable/endossable = 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M3-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Contexte : conteneur FCL (Full Container Load) empoté par le client (chargement complet, un seul chargeur, un seul destinataire).

a. Le geste matériel : la pose du scellé (plombage). Une fois l'empotage terminé, le client (ou l'organisateur) ferme les portes du conteneur et y appose un scellé de sécurité à numéro unique (plomb / seal). Ce scellé, non réutilisable, ne peut être retiré qu'en le brisant : tant qu'il reste intact et que son numéro correspond, il atteste qu'aucun accès à la marchandise n'a eu lieu entre l'empotage et le dépotage.

b. La mention documentaire : le report du numéro de scellé sur le connaissement (bill of lading), assorti de la clause dite « Shipper's Load, Stowage and Count » (SLAC), équivalent français « dit contenir » / « chargé, arrimé et compté par le chargeur ». Cette mention indique que le transporteur n'a ni empoté ni vérifié le contenu : il ne reconnaît que la réception d'un conteneur plombé, dont le numéro de scellé est consigné.

Effet combiné : à l'arrivée, si le scellé est intact et que son numéro concorde avec celui du connaissement, il y a présomption d'intégrité du chargement jusqu'au dépotage ; la responsabilité de la nature et de la quantité empotées reste sur le chargeur (clause SLAC), tandis que le numéro de scellé fige la preuve qu'il n'y a pas eu d'intrusion pendant le transport.$c370$,
  scoring_grid    = $c370$a. Geste matériel = pose du scellé / plombage à numéro unique après empotage : 1 pt. b. Mention documentaire = report du numéro de scellé sur le connaissement + clause SLAC / « dit contenir » (transporteur ne vérifie pas le contenu) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M3-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Solution groupage maritime (LCL) de 12 palettes, Meaux vers Casablanca via Le Havre, décomposée en cinq segments :

1. Pré-acheminement routier : enlèvement des 12 palettes à Meaux et camionnage jusqu'à la plateforme de groupage du Havre (CFS, Container Freight Station).

2. Empotage / groupage au CFS du Havre : réception, contrôle et mise en conteneur des 12 palettes avec les envois d'autres chargeurs partageant la même destination (constitution d'un conteneur groupé LCL), établissement des documents (connaissement de groupage / house B/L).

3. Transport maritime principal : acheminement du conteneur du port du Havre au port de Casablanca (traversée maritime, sous couvert du connaissement).

4. Dégroupage / dépotage au CFS de Casablanca : déchargement du conteneur au port d'arrivée, dépotage et séparation des lots, mise à disposition des 12 palettes ; réalisation des formalités douanières d'importation.

5. Post-acheminement routier : livraison finale des 12 palettes du port / CFS de Casablanca jusqu'au destinataire.$c370$,
  scoring_grid    = $c370$0,4 pt par segment correctement identifié et ordonné (1. pré-acheminement routier Meaux→Le Havre ; 2. empotage/groupage au CFS du Havre ; 3. transport maritime Le Havre→Casablanca ; 4. dégroupage/dépotage + douane à Casablanca ; 5. post-acheminement/livraison finale). Total = 2 pts. Tolérance sur le placement de la douane import (segment 4 ou 5).$c370$
WHERE source_ref = 'COMM-M3-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La proposition d'assurance ad valorem (assurance des facultés couvrant la valeur commerciale réelle de la marchandise) doit être systématique et écrite pour deux raisons complémentaires.

a. Systématique, au titre du devoir de conseil. Le commissionnaire de transport est tenu d'une obligation d'information et de conseil envers son commettant. Or l'indemnisation due par le transporteur (et par le commissionnaire garant de ses substitués) est plafonnée par des limites légales ou conventionnelles exprimées par kilo ou par colis, très souvent inférieures à la valeur réelle des marchandises. Sans assurance ad valorem, le client est structurellement sous-indemnisé en cas de perte ou d'avarie. Ce risque existe sur tout envoi : le conseil doit donc être proposé sur chaque devis, non au cas par cas.

b. Écrite, pour la preuve et la protection du commissionnaire. En consignant par écrit la proposition d'assurance dans le devis, le commissionnaire se ménage la preuve qu'il a satisfait à son devoir de conseil. Si le client refuse la couverture ad valorem et subit ensuite un dommage supérieur aux plafonds, la trace écrite (proposition faite, éventuellement refus du client) protège le commissionnaire contre une action en responsabilité pour manquement au devoir de conseil. L'écrit transforme un conseil oral, invérifiable, en élément probant opposable.

En résumé : systématique parce que le devoir de conseil est général et que les plafonds légaux exposent tout envoi ; écrit parce que la charge de la preuve du conseil pèse sur le commissionnaire.$c370$,
  scoring_grid    = $c370$a. Systématique = devoir de conseil du commissionnaire + insuffisance des plafonds légaux d'indemnisation (par kg/colis) face à la valeur réelle : 1 pt. b. Écrite = constitution de la preuve du conseil, protection contre une action pour manquement au devoir de conseil (trace du refus éventuel du client) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M3-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Définition. En transport multimodal, un « dommage non localisé » est une perte ou une avarie dont on ne peut pas déterminer sur quel segment (ni sur quel mode) du parcours elle est survenue : on constate le dommage à l'arrivée, mais rien ne permet de dire s'il s'est produit pendant le pré-acheminement routier, le transport maritime, le tronçon ferroviaire, etc. Il s'oppose au dommage localisé, rattachable à une étape précise.

b. Pourquoi c'est le cas le plus délicat à indemniser. Le transport multimodal fait cohabiter plusieurs régimes de responsabilité, chacun propre à un mode et assorti de ses propres limites d'indemnisation : la CMR pour la route, les Règles de La Haye-Visby (ou Rotterdam / Hambourg) pour la mer, la CIM-COTIF pour le fer, la Convention de Montréal pour l'air. Ces régimes diffèrent par la loi applicable, les cas d'exonération, les plafonds (exprimés différemment, par kg ou par colis) et les délais. Tant que le dommage est localisé, on applique le régime du segment concerné (système dit « réseau »). Mais s'il est non localisé, on ignore quel régime activer : ni la loi applicable, ni le plafond d'indemnisation ne sont déterminés d'emblée. Il faut alors recourir à la règle supplétive prévue au contrat de transport multimodal (par exemple les conditions du document FIATA / MT B/L), qui fixe un régime de repli. D'où l'incertitude sur le montant indemnisable et la difficulté d'imputer la responsabilité à l'un des transporteurs substitués.$c370$,
  scoring_grid    = $c370$a. Définition = dommage dont le segment/mode de survenance ne peut être identifié (par opposition au dommage localisé) : 1 pt. b. Difficulté = coexistence de régimes de responsabilité et de plafonds différents selon les modes (CMR, La Haye-Visby, CIM-COTIF, Montréal) ; sans localisation, régime et plafond indéterminés → recours à une règle supplétive/de repli : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M3-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Articulation des deux plafonds sous les Règles de La Haye-Visby. La limitation de responsabilité du transporteur maritime combine deux plafonds alternatifs, exprimés en DTS (droits de tirage spéciaux) :
- un plafond par colis ou unité : 666,67 DTS ;
- un plafond par kilogramme de poids brut des marchandises perdues ou endommagées : 2 DTS/kg.
La règle retient le plafond le plus élevé des deux (celui le plus favorable à l'ayant droit à la marchandise) ; ce n'est donc pas au choix du transporteur, mais le résultat le plus haut qui s'applique.

b. Plafond jouant en l'espèce. Pour un colis de 40 kg :
- calcul par colis : 666,67 DTS ;
- calcul au poids : 40 kg × 2 DTS = 80 DTS.
666,67 DTS étant supérieur à 80 DTS, c'est le plafond par colis (666,67 DTS) qui s'applique. Pour un colis léger, la limite « par colis » l'emporte presque toujours sur la limite « au poids » ; l'inverse ne se vérifie que pour des colis lourds (au-delà d'environ 333 kg, seuil où les deux calculs s'égalisent).$c370$,
  scoring_grid    = $c370$a. Articulation = deux plafonds alternatifs (666,67 DTS par colis et 2 DTS/kg), on retient le plus élevé / le plus favorable à l'ayant droit : 1 pt. b. Application chiffrée = 666,67 DTS vs 40×2 = 80 DTS → le plafond par colis (666,67 DTS) joue : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M3-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Rectification. L'affirmation du stagiaire est doublement fausse : les Incoterms ne fixent NI le prix de la marchandise, NI le transfert de propriété.

Ce que les Incoterms répartissent réellement, entre le vendeur et l'acheteur :
a. La répartition des FRAIS (qui paie quoi : pré-acheminement, transport principal, assurance selon le terme, manutention, formalités et droits) ;
b. Le transfert des RISQUES (à quel point géographique précis le risque de perte ou d'avarie passe du vendeur à l'acheteur) ;
c. La répartition des OBLIGATIONS et TÂCHES logistiques et documentaires (organisation du transport, dédouanement export/import, fourniture des documents, assurance pour CIF/CIP).

En revanche, relèvent du contrat de vente et NON de l'Incoterm : le prix et les conditions de paiement, le transfert de propriété (régi par le droit applicable au contrat), la loi applicable et le règlement des litiges. Formule à retenir : l'Incoterm dit « qui fait quoi, qui paie quoi et qui supporte le risque jusqu'où », pas « combien » ni « qui devient propriétaire ».$c370$,
  scoring_grid    = $c370$1 pt : avoir corrigé les deux erreurs (l'Incoterm ne fixe pas le prix et ne règle pas le transfert de propriété, qui dépend du contrat de vente / droit applicable). 1 pt : avoir énoncé ce que répartissent réellement les Incoterms (frais + risques + obligations/tâches, dont le point de transfert des risques). Total = 2.$c370$
WHERE source_ref = 'COMM-M4-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les quatre Incoterms exclusivement maritimes (et par voies navigables intérieures) de la version 2020 sont :
a. FAS — Free Alongside Ship (franco le long du navire) ;
b. FOB — Free On Board (franco à bord) ;
c. CFR — Cost and Freight (coût et fret) ;
d. CIF — Cost, Insurance and Freight (coût, assurance et fret).

Ces quatre termes supposent une remise de la marchandise au port (le long du navire ou à bord) et ne conviennent donc pas au conteneur remis à un terminal ni au transport multimodal, pour lesquels on utilise plutôt FCA, CPT ou CIP. Les sept autres Incoterms 2020 (EXW, FCA, CPT, CIP, DAP, DPU, DDP) sont, eux, multimodaux / tous modes de transport.$c370$,
  scoring_grid    = $c370$0,5 pt par terme maritime correctement cité (FAS, FOB, CFR, CIF), soit 2 pts. Retirer les points en cas de confusion avec un terme multimodal (ex. FCA, CPT, CIP cités comme maritimes). Total = 2.$c370$
WHERE source_ref = 'COMM-M4-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le régime de transit T1 (transit externe de l'Union, marchandises non-Union) sert à faire circuler des marchandises tierces à l'intérieur du territoire douanier de l'Union EN SUSPENSION des droits de douane et de la TVA, tant qu'elles ne sont pas mises en libre pratique / dédouanées.

Utilité concrète pour votre client importateur :
a. Reporter le dédouanement : la marchandise débarquée au point d'entrée (port, aéroport) peut être acheminée sous douane jusqu'à un bureau de douane intérieur ou un entrepôt proche de son site, où les formalités d'importation et le paiement des droits et de la TVA sont réellement effectués. On ne paie pas les droits à la frontière d'entrée.
b. Fluidifier la logistique : la marchandise n'est pas bloquée au port ; elle circule jusqu'au lieu voulu sous couvert du document de transit, dédouanement au plus près du destinataire.
c. Trésorerie : la suspension des droits et taxes jusqu'au bureau de destination évite une avance de trésorerie au point d'entrée.

Contrepartie : le transit T1 exige une garantie (caution) couvrant la dette douanière suspendue et l'apurement du régime à l'arrivée au bureau de destination (respect des délais et de l'intégrité des scellés).$c370$,
  scoring_grid    = $c370$1 pt : avoir identifié le T1 comme régime de transit externe permettant la circulation de marchandises non-Union EN SUSPENSION des droits et taxes (pas de paiement à l'entrée). 1 pt : en avoir tiré l'utilité pour l'importateur (dédouanement reporté à un bureau intérieur / près du site, fluidité logistique et/ou avantage de trésorerie). Bonus admis sans dépasser 2 : mention de la garantie/apurement. Total = 2.$c370$
WHERE source_ref = 'COMM-M4-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le piège de la famille C (CFR, CIF, CPT, CIP) tient à la DISSOCIATION entre le point jusqu'où le vendeur paie et le point où le risque est transféré.

a. Le vendeur ORGANISE et PAIE le transport principal jusqu'au port ou au lieu de destination convenu (et souscrit en plus l'assurance pour CIF et CIP). L'acheteur voit donc un prix « rendu destination » et croit spontanément que le vendeur reste responsable de la marchandise jusqu'à l'arrivée.
b. Or le RISQUE, lui, est transféré à l'acheteur dès le DÉPART : à la mise à bord au port d'embarquement pour CFR et CIF, ou à la remise au premier transporteur pour CPT et CIP. Pendant tout le transport principal, c'est l'acheteur qui supporte la perte ou l'avarie, alors même qu'il n'a pas choisi le transporteur.

Conséquence pratique du piège : en cas de dommage survenu pendant le transport maritime ou principal, l'acheteur ne peut se retourner ni contre le vendeur (qui a rempli son obligation en remettant la marchandise au transporteur) ni facilement contre un transporteur qu'il n'a pas contracté. D'où l'importance de l'assurance : en CFR et CPT il n'y a AUCUNE assurance à la charge du vendeur (l'acheteur doit s'assurer lui-même) ; en CIF le vendeur ne doit qu'une couverture MINIMALE (type Institute Cargo Clauses C), tandis qu'en CIP la version 2020 impose désormais une couverture ÉTENDUE (type ICC A). Retenir : « le vendeur paie le transport mais l'acheteur porte le risque dès le départ ».$c370$,
  scoring_grid    = $c370$1 pt : avoir énoncé le cœur du piège, c'est-à-dire la dissociation entre le point où le vendeur paie (destination) et le point de transfert du risque (au départ : mise à bord CFR/CIF, remise au 1er transporteur CPT/CIP). 1 pt : en avoir tiré une conséquence correcte pour l'acheteur (il supporte le risque du transport principal) et/ou la nuance assurance (aucune en CFR/CPT ; minimale CIF vs étendue CIP en 2020). Total = 2.$c370$
WHERE source_ref = 'COMM-M4-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Contexte : EXW Osaka est l'Incoterm de MOINDRE obligation pour le vendeur japonais. Celui-ci met seulement la marchandise à disposition dans ses locaux à Osaka (emballée, non chargée) ; à partir de là, tout est à la charge de l'acheteur.

a. Qui vous mandate ? C'est votre client français (l'acheteur / importateur) qui vous mandate : il est le COMMETTANT, vous êtes le COMMISSIONNAIRE de transport. Vous agissez en votre nom propre, pour son compte, avec liberté d'organisation et une obligation de résultat ; vous êtes garant des transporteurs et sous-traitants que vous vous substituez.
b. Pour quelles étapes ? En EXW, vous devez organiser toute la chaîne à partir des locaux du vendeur à Osaka, soit :
- l'enlèvement et le chargement de la marchandise chez le vendeur à Osaka (en EXW le chargement incombe déjà à l'acheteur) ;
- le pré-acheminement terrestre jusqu'au port ou à l'aéroport japonais ;
- les formalités et le dédouanement EXPORT au Japon (déclaration, éventuelles licences) ;
- le transport principal international (maritime ou aérien) jusqu'en France ;
- l'assurance de la marchandise (recommandée, EXW n'en prévoyant aucune) ;
- le déchargement à l'arrivée et les formalités de dédouanement IMPORT en France, avec paiement des droits de douane et de la TVA ;
- le post-acheminement et la livraison finale jusqu'au site de votre client.

Point de vigilance à signaler au client : en EXW, le dédouanement export est juridiquement à la charge de l'acheteur, ce qui est souvent difficile à assumer dans le pays du vendeur ; en pratique on conseille de basculer sur FCA locaux du vendeur, où l'export incombe au vendeur, mieux placé pour l'accomplir.$c370$,
  scoring_grid    = $c370$1 pt : identification correcte du mandat (le client français / acheteur est le commettant qui mandate le commissionnaire ; le commissionnaire agit en son nom propre, pour le compte du commettant, garant de ses substitués). 1 pt : énumération des étapes couvertes en EXW (au minimum : enlèvement/pré-acheminement au Japon, dédouanement export Japon, transport principal, dédouanement import France + droits/TVA, livraison finale ; l'assurance et le conseil FCA valorisés sans dépasser 2). Total = 2.$c370$
WHERE source_ref = 'COMM-M4-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les deux notions correspondent à deux opérations juridiquement distinctes, souvent réalisées simultanément lors d'un import définitif, mais dissociables.

a. Mise en libre pratique (dimension douanière). C'est l'opération qui confère à une marchandise tierce (non-Union) le statut de marchandise « Union ». Elle suppose l'accomplissement des formalités d'importation, l'acquittement des droits de douane exigibles et l'application des mesures de politique commerciale (contrôles, normes, licences éventuelles). Une fois en libre pratique, la marchandise circule dans l'Union comme une marchandise d'origine communautaire : son sort douanier est réglé.

b. Mise à la consommation (dimension fiscale). C'est l'opération qui met la marchandise en circulation sur le marché intérieur d'un État membre, avec exigibilité et paiement des taxes intérieures, principalement la TVA et, le cas échéant, les accises. Elle règle le sort fiscal de la marchandise.

c. Articulation. À l'importation définitive, la déclaration vaut le plus souvent « mise en libre pratique ET à la consommation » (les deux ensemble). Mais on peut n'effectuer que la mise en libre pratique et suspendre la fiscalité, par exemple en plaçant ensuite la marchandise sous un régime suspensif ou un entrepôt : la marchandise est alors « Union » sur le plan douanier sans avoir supporté la TVA. Retenir : libre pratique = statut douanier / droits de douane ; mise à la consommation = taxation intérieure / TVA.$c370$,
  scoring_grid    = $c370$Mise en libre pratique correctement définie (statut Union, paiement des droits de douane, mesures de politique commerciale) : 1 pt. Mise à la consommation correctement définie (taxes intérieures, TVA/accises, mise sur le marché) : 1 pt. Total : 2 pts. Si un seul volet est traité ou si les deux sont confondus : plafonner à 1 pt. Bonus non cumulable au-delà de 2 pts.$c370$
WHERE source_ref = 'COMM-M4-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Toute déclaration en douane repose sur trois données fondamentales, souvent appelées « le trépied » de la déclaration : l'espèce, l'origine et la valeur.

a. L'espèce tarifaire. C'est le classement de la marchandise dans la nomenclature douanière (système harmonisé / nomenclature combinée), matérialisé par un code chiffré. Rôle : elle détermine le taux de droit de douane applicable ainsi que les réglementations particulières attachées au produit (normes, restrictions, prohibitions, contingents, mesures sanitaires).

b. L'origine. C'est la « nationalité » économique de la marchandise (pays où elle a été produite ou a subi sa dernière transformation substantielle). Rôle : elle détermine le taux de droit effectivement applicable selon qu'il existe ou non un accord préférentiel (droit réduit ou nul), ainsi que les mesures de politique commerciale (droits antidumping, contingents, embargos).

c. La valeur en douane. C'est le montant servant d'assiette au calcul des droits et taxes ad valorem. Rôle : elle constitue la base de calcul des droits de douane et de la TVA à l'import.

En résumé : l'espèce et l'origine fixent le taux, la valeur fixe l'assiette ; les trois combinées déterminent le montant des droits et taxes dus.$c370$,
  scoring_grid    = $c370$Espèce tarifaire citée + rôle (classement/nomenclature, détermine le taux et les réglementations) : 0,67 pt. Origine citée + rôle (nationalité économique, taux préférentiel et mesures de politique commerciale) : 0,67 pt. Valeur en douane citée + rôle (assiette des droits et de la TVA) : 0,66 pt. Total : 2 pts. Simple citation sans le rôle : demi-point par donnée.$c370$
WHERE source_ref = 'COMM-M4-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le mécanisme préserve la trésorerie parce qu'il supprime le décalage entre le paiement de la TVA à l'import et sa récupération.

a. Situation sans autoliquidation. La TVA à l'importation est traditionnellement acquittée auprès de la douane au moment du dédouanement : l'importateur décaisse immédiatement la TVA, puis ne la récupère que plus tard, par déduction sur sa déclaration de TVA périodique. Il supporte donc une avance de trésorerie sur toute la période séparant le paiement en douane du remboursement/imputation, avance d'autant plus lourde que les volumes importés sont élevés.

b. Situation avec autoliquidation. La TVA due à l'import n'est plus payée en douane : elle est portée directement sur la déclaration de TVA de l'importateur (en France, la CA3 auprès de la DGFiP), où elle est simultanément collectée (TVA due) et déduite (TVA déductible). L'opération se traduit par un simple jeu d'écritures : la TVA déclarée et la TVA déduite s'annulent, sans décaissement effectif pour l'entreprise en droit à déduction intégral.

c. Conséquence pour le client importateur. Il n'a plus à avancer la TVA au moment du passage en douane : la trésorerie qui était auparavant immobilisée reste disponible pour son exploitation. Le gain est un gain de trésorerie (et non un gain d'impôt : le montant de TVA dû in fine est identique).$c370$,
  scoring_grid    = $c370$Identification de l'avance de trésorerie dans le système classique (paiement en douane puis récupération différée) : 1 pt. Explication de la neutralité de l'autoliquidation (collecte et déduction simultanées sur la même déclaration, absence de décaissement, gain de trésorerie et non d'impôt) : 1 pt. Total : 2 pts.$c370$
WHERE source_ref = 'COMM-M4-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le crédit documentaire est un mécanisme de paiement contre documents : la banque s'engage à payer le vendeur sur remise d'un jeu de documents strictement conformes aux exigences du crédit. Le choix de l'incoterm est donc guidé par la nature des documents que le montage exige.

a. Logique documentaire. Le crédoc fonctionne d'autant mieux que le transport donne lieu à un document négociable et représentatif de la marchandise, typiquement le connaissement maritime (bill of lading). Ce titre permet à la banque de tenir la marchandise en garantie et de la transmettre par endossement : celui qui détient le connaissement contrôle la marchandise.

b. Pourquoi FOB et CIF. Ce sont des incoterms exclusivement maritimes, qui s'accompagnent normalement de l'émission d'un connaissement. Ils fournissent donc naturellement le document-clé attendu par les banques dans un crédoc. Avec CIF, le vendeur souscrit en outre le fret et l'assurance : il remet un jeu documentaire complet (facture commerciale, connaissement, police ou certificat d'assurance) qui correspond exactement à ce qu'exige le crédit documentaire. Avec FOB, l'acheteur maîtrise le transport principal tout en disposant du connaissement pour actionner le crédoc.

c. Comparaison. Les incoterms multimodaux (FCA, CPT, CIP, DAP, DDP) donnent souvent des documents de transport non négociables (lettre de voiture, LTA, CMR), moins adaptés pour servir de sûreté bancaire. D'où l'orientation traditionnelle du crédit documentaire vers FOB ou CIF, qui produisent le connaissement maritime attendu.$c370$,
  scoring_grid    = $c370$Rappel du principe du crédoc (paiement contre documents conformes) et rôle du connaissement négociable comme sûreté : 1 pt. Justification du choix FOB/CIF (incoterms maritimes générant un connaissement ; jeu documentaire complet fret+assurance pour CIF ; opposition aux documents multimodaux non négociables) : 1 pt. Total : 2 pts.$c370$
WHERE source_ref = 'COMM-M4-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La différence tient à ce que le prix facturé n'a pas le même contenu selon l'incoterm, alors que la valeur en douane, elle, obéit à une règle unique de composition.

a. Règle de la valeur en douane à l'import UE. La valeur en douane est en principe la valeur transactionnelle (prix réellement payé ou à payer), ajustée pour inclure les frais de transport et d'assurance jusqu'au point d'introduction dans le territoire douanier de l'Union. C'est donc, en substance, une valeur « CAF/CIF frontière de l'UE » : le fret et l'assurance jusqu'à la frontière doivent y figurer, quel que soit l'incoterm convenu.

b. Achat conclu FOB. Le prix facturé correspond à la marchandise chargée au port d'embarquement, sans le fret maritime ni l'assurance. Ce prix est donc inférieur à la valeur en douane : il faut y RÉINTÉGRER (ajouter) le fret et l'assurance jusqu'à la frontière de l'Union pour obtenir l'assiette correcte.

c. Achat conclu CIF. Le prix facturé inclut déjà le coût de la marchandise, le fret et l'assurance jusqu'au port de destination. La valeur transactionnelle CIF est donc d'emblée proche de la valeur en douane (sous réserve d'un éventuel retrait de la portion de transport intervenant au-delà du point d'entrée dans l'UE).

d. Conclusion. Pour une même marchandise, la base FOB affichée sur la facture est plus faible que la base CIF, ce qui explique que la « valeur » diffère selon l'incoterm. Mais une fois le fret et l'assurance réintégrés dans le cas FOB, les deux convergent : la valeur en douane inclut toujours le transport et l'assurance jusqu'à la frontière de l'Union, indépendamment de l'incoterm choisi.$c370$,
  scoring_grid    = $c370$Énoncé de la règle (valeur en douane = valeur transactionnelle incluant fret + assurance jusqu'à la frontière UE, valeur type CIF/CAF) : 1 pt. Application comparée FOB (prix hors fret/assurance, à réintégrer, base plus faible) vs CIF (fret/assurance déjà inclus, base proche de la valeur en douane) et convergence après ajustement : 1 pt. Total : 2 pts.$c370$
WHERE source_ref = 'COMM-M4-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le prix facturé au client par le commissionnaire se compose de deux grandes masses.

a. Les frais et débours (prix de revient du dossier) : c'est la somme de tout ce que le commissionnaire achète et avance pour le compte du client auprès de ses substitués et prestataires. On y trouve le prix des transports proprement dits (pré-acheminement, transport principal maritime/aérien/routier, post-acheminement), la manutention et l'empotage/dépotage, le magasinage, les frais de douane (débours des droits et taxes, TVA à l'importation, honoraires de déclaration), l'assurance des marchandises souscrite pour le compte du client, ainsi que les taxes et surcharges diverses. Ces éléments sont refacturés au client, en principe à l'euro près pour les débours proprement dits (droits, taxes).

b. La rémunération propre du commissionnaire : c'est sa commission (marge d'organisation), qui rémunère le service d'organisation libre du transport, la prise de responsabilité de garant des substitués et le risque commercial. Elle peut prendre la forme d'un forfait, d'un pourcentage ou de la marge dégagée entre le prix de vente et le prix d'achat des prestations.

En résumé : prix facturé = frais/débours des prestations sous-traitées (prix de revient) + commission/marge du commissionnaire.$c370$,
  scoring_grid    = $c370$a. Frais, débours et prestations sous-traitées refacturés (transport, douane, manutention, assurance, taxes) : 1 pt. b. Rémunération propre du commissionnaire (commission/marge d'organisation) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M5-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Dans un dossier de commission de transport, il faut distinguer trois étages d'assurance qui ne couvrent pas les mêmes risques.

a. La responsabilité civile contractuelle du commissionnaire lui-même : elle couvre la responsabilité de plein droit qu'il assume en qualité de garant de ses substitués (fautes des transporteurs et prestataires qu'il se substitue) ainsi que ses fautes personnelles d'organisation. C'est l'assurance RC « commissionnaire de transport ».

b. La responsabilité civile des transporteurs substitués : chaque voiturier ou transporteur substitué dispose de sa propre assurance RC, plafonnée par les limites légales ou conventionnelles d'indemnisation propres à chaque mode (CMR en routier international, contrat type en routier interne, règles maritimes/aériennes). C'est vers elle que le commissionnaire se retourne (action récursoire).

c. L'assurance de la marchandise (assurance facultés ou ad valorem) : souscrite pour le compte du client sur la valeur réelle des marchandises, elle couvre les avaries et pertes au-delà des plafonds de responsabilité des transporteurs. Elle est distincte des deux précédentes car elle indemnise la valeur du bien et non une responsabilité.

En synthèse : RC du commissionnaire, RC des transporteurs substitués, et assurance des marchandises (ad valorem).$c370$,
  scoring_grid    = $c370$a. RC du commissionnaire (garant des substitués) : 0,75 pt. b. RC des transporteurs substitués (plafonds légaux/conventionnels) : 0,75 pt. c. Assurance des marchandises / facultés ad valorem sur la valeur : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M5-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La trésorerie du commissionnaire est structurellement tendue à cause d'un décalage systématique entre ses décaissements et ses encaissements (besoin en fonds de roulement élevé).

a. Il avance des débours importants pour le compte du client : droits de douane, TVA à l'importation, taxes et surcharges. Ces sommes sont réglées immédiatement à l'administration ou aux prestataires, avant d'être refacturées puis encaissées.

b. Il paie ses substitués (transporteurs, manutentionnaires, dépositaires) à échéance courte, car ceux-ci exigent des délais de paiement brefs, alors que lui-même est réglé plus tard par ses clients (délais de 30, 45 ou 60 jours).

c. Cet effet de ciseau (payer avant d'être payé) génère un besoin de trésorerie permanent, d'autant plus lourd que les montants avancés (droits et taxes notamment) peuvent être très supérieurs à sa propre marge, laquelle ne représente qu'une fraction du dossier.

En résumé : le commissionnaire finance le décalage entre des décaissements précoces (débours douaniers et paiement des substitués) et des encaissements clients tardifs.$c370$,
  scoring_grid    = $c370$a. Avance des débours douaniers et taxes (droits, TVA import) : 0,75 pt. b. Paiement des substitués à court terme vs règlement client tardif (décalage/effet de ciseau) : 0,75 pt. c. BFR permanent, montants avancés supérieurs à la marge : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M5-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Avant d'affréter (se substituer) un transporteur, le donneur d'ordre (le commissionnaire) doit procéder à des vérifications obligatoires, notamment au titre de son devoir de vigilance en matière de sous-traitance.

a. La capacité et le titre d'exploitation du transporteur : inscription au registre des transporteurs et détention d'une licence de transport valide (licence communautaire pour l'international, licence de transport intérieur), avec des copies conformes en cours de validité correspondant au parc utilisé.

b. L'assurance de responsabilité civile du transporteur couvrant les marchandises transportées : attestation d'assurance en cours de validité, garantissant sa responsabilité de voiturier.

c. La régularité sociale et fiscale : attestation de vigilance URSSAF (justifiant du paiement des cotisations sociales et de la déclaration des salariés, dans le cadre de la lutte contre le travail dissimulé), complétée le cas échéant par un extrait Kbis récent.

D'autres contrôles sont utiles (existence juridique de l'entreprise, moyens matériels adaptés à la marchandise), mais les trois vérifications ci-dessus constituent le socle obligatoire.$c370$,
  scoring_grid    = $c370$a. Inscription au registre / licence de transport valide : 0,75 pt. b. Attestation d'assurance RC marchandises en cours de validité : 0,75 pt. c. Attestation de vigilance URSSAF (régularité sociale, travail dissimulé) : 0,5 pt. Total = 2 pts. Toute vérification pertinente équivalente (Kbis, existence juridique) est acceptée en substitution partielle.$c370$
WHERE source_ref = 'COMM-M5-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le poids taxable retenu est d'environ 333 kg (poids volumétrique), et non le poids réel de 200 kg.

a. Application du rapport d'équivalence poids/volume. L'usage donné est 1 tonne = 6 m3, c'est-à-dire que 6 m3 correspondent à 1 000 kg, soit 1 m3 = 1 000 / 6 = 166,67 kg.

b. Calcul du poids volumétrique (ou poids-volume). Le colis occupe 2 m3, donc son poids volumétrique = 2 m3 × 166,67 kg/m3 = 333,33 kg, arrondi à 333 kg.

c. Règle du poids taxable. La compagnie facture toujours au plus élevé des deux poids : le poids réel (200 kg) ou le poids volumétrique (333 kg). Ici, 333 kg > 200 kg : la marchandise est « légère et volumineuse », elle occupe plus de place que ne le laisse penser sa masse. On retient donc le poids taxable = 333 kg.

Conclusion : poids taxable = 333 kg, car il est supérieur au poids réel et la taxation aérienne s'effectue sur le plus fort du poids réel et du poids volumétrique.$c370$,
  scoring_grid    = $c370$a. Conversion du ratio 1 t = 6 m3 en 1 m3 = 166,67 kg : 0,5 pt. b. Calcul du poids volumétrique 2 m3 × 166,67 = 333 kg : 0,75 pt. c. Choix du poids taxable = plus élevé du réel et du volumétrique (333 kg > 200 kg) avec justification : 0,75 pt. Total = 2 pts.$c370$
WHERE source_ref = 'COMM-M5-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Précaution attendue : formaliser le conseil PAR ÉCRIT et en conserver la trace, de manière à pouvoir le prouver en cas de litige.

a. Le principe : le devoir de conseil du commissionnaire en matière d'assurance (informer le commettant sur les limites de sa responsabilité, notamment les plafonds d'indemnisation légaux/contractuels très inférieurs à la valeur réelle des marchandises, et lui proposer une assurance ad valorem couvrant la valeur réelle) reste théorique tant qu'il n'est pas matérialisé. Oralement, il est ininvocable : c'est parole contre parole.

b. La précaution qui le rend opposable : matérialiser ce conseil par un écrit daté et tracé (mention expresse dans le devis, la confirmation d'ordre ou les conditions particulières proposant la souscription d'une assurance ad valorem), et surtout, lorsque le client refuse cette assurance, faire acter ce refus par écrit (renonciation ou décharge signée du commettant, ou courriel/échange conservé). L'écrit conservé devient une preuve opposable : il démontre que le commissionnaire a bien exécuté son obligation de conseil et fait basculer la charge du choix (et donc du risque non couvert) sur le client qui a renoncé.

En synthèse : c'est la formalisation écrite et conservée (proposition d'assurance + refus signé du client) qui transforme le devoir de conseil en preuve opposable.$c370$,
  scoring_grid    = $c370$1 pt : identifier la précaution = formaliser le conseil par écrit et en conserver la trace (proposition écrite d'assurance ad valorem). 1 pt : préciser l'élément qui rend la preuve opposable = faire signer / conserver le refus (renonciation, décharge, écrit du client) reportant le risque sur le commettant. Total = 2.$c370$
WHERE source_ref = 'COMM-M5-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Deux dispositifs (deux suffisent ; plusieurs réponses valables) permettant de sécuriser les encours clients, c'est-à-dire de se prémunir contre le risque d'impayé :

a. L'assurance-crédit : un assureur garantit le paiement des créances clients en cas de défaillance/insolvabilité de l'acheteur, après analyse et fixation d'un encours garanti par client.

b. L'affacturage : cession des créances à un factor qui en assure le recouvrement, le financement (avance de trésorerie) et, en formule sans recours, la garantie contre l'impayé.

Autres réponses également recevables : garantie bancaire (caution, garantie à première demande / SBLC), demande d'acompte ou de paiement d'avance, fixation d'un plafond d'encours / limite de crédit par client avec blocage au-delà, effets de commerce (LCR, traite acceptée) ou paiement documentaire (crédit documentaire, remise documentaire), droit de rétention/gage sur la marchandise.

Une réponse complète cite deux dispositifs distincts et en explicite brièvement le mécanisme protecteur.$c370$,
  scoring_grid    = $c370$1 pt par dispositif pertinent et correctement nommé (max 2 dispositifs) : assurance-crédit, affacturage, garantie bancaire/caution, acompte, plafond d'encours, effets de commerce, crédit documentaire, droit de rétention, etc. Bonus attendu mais non noté séparément : mécanisme explicité. Total = 2.$c370$
WHERE source_ref = 'COMM-M5-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le commissionnaire est donneur d'ordre : à ce titre il est soumis à une obligation de vigilance vis-à-vis des sous-traitants/transporteurs qu'il se substitue. S'il continue d'affréter un transporteur en situation de travail dissimulé qu'il aurait dû détecter (défaut de vigilance), il encourt :

a. La solidarité financière (risque principal). En cas de manquement à son obligation de vigilance, le donneur d'ordre est tenu solidairement au paiement des sommes dues par le transporteur fautif : cotisations sociales et majorations dues à l'URSSAF, impôts et taxes, et le cas échéant rémunérations, indemnités et charges dues aux salariés employés dans des conditions de travail dissimulé. Il peut aussi perdre le bénéfice d'exonérations/aides publiques.

b. Le risque pénal et professionnel. Il s'expose à des poursuites pour recours au travail dissimulé / complicité (amendes, voire peines complémentaires), et à un risque d'image et de perte d'honorabilité pouvant affecter son inscription au registre.

La parade : exiger et vérifier périodiquement l'attestation de vigilance (URSSAF) du transporteur, ainsi que ses justificatifs d'inscription et de régularité, et conserver ces pièces. L'obligation de vigilance s'applique pour tout contrat d'un montant au moins égal à 5 000 EUR HT, et l'attestation de vigilance doit être obtenue lors de la conclusion du contrat puis renouvelée tous les 6 mois jusqu'à la fin de son exécution.$c370$,
  scoring_grid    = $c370$1,5 pt : identifier le risque central = solidarité financière du donneur d'ordre (paiement solidaire des cotisations sociales, impôts, salaires du transporteur en travail dissimulé) au titre du défaut d'obligation de vigilance. 0,5 pt : citer un second effet = risque pénal (recours/complicité de travail dissimulé) et/ou perte d'honorabilité, ou évoquer la parade (attestation de vigilance à vérifier). Total = 2.$c370$
WHERE source_ref = 'COMM-M5-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Le risque spécifique : le risque de change. La vente est libellée et encaissée en euros, alors qu'une charge majeure (le fret maritime) est achetée et payable en dollars à 45 jours. Entre la fixation du prix de vente (en EUR) et le décaissement du fret (en USD à 45 jours), si le dollar s'apprécie face à l'euro, le coût du fret converti en euros augmente sans que le prix de vente puisse être ajusté : la marge prévue est amputée, voire annulée. Le risque naît du décalage de devise (EUR encaissé / USD décaissé) combiné au décalage de temps (45 jours).

b. Comment le limiter : neutraliser l'exposition au cours du dollar. Principaux moyens :
- Couverture de change à terme : acheter les dollars nécessaires à terme (achat à terme / forward) auprès de sa banque, ce qui fige dès aujourd'hui le cours EUR/USD applicable dans 45 jours et sécurise le coût du fret en euros.
- Option de change : acheter une option d'achat de dollars (call USD) pour se garantir un cours plafond tout en gardant le bénéfice d'une évolution favorable (moyennant une prime).
- Adosser les devises : facturer le client dans la même devise que la charge (vente en USD) ou insérer une clause de révision / d'indexation change dans le contrat, reportant le risque sur le client.
- Compensation (netting) des flux USD entrants et sortants lorsqu'ils existent.

La réponse de référence : risque de change, couvert par un achat de devises à terme (ou une option de change), et/ou par une clause d'indexation devise dans le contrat.$c370$,
  scoring_grid    = $c370$1 pt : nommer le risque = risque de change (dépréciation de l'euro / appréciation du dollar entre la vente en EUR et le paiement du fret en USD à 45 jours, qui érode la marge). 1 pt : citer au moins un moyen de couverture pertinent = achat à terme de devises / change à terme, option de change, facturation dans la même devise ou clause d'indexation change. Total = 2.$c370$
WHERE source_ref = 'COMM-M5-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Ce que mesure l'OTIF : OTIF signifie On Time In Full, soit livré à temps et complet. C'est un indicateur de qualité de service qui mesure la proportion de livraisons (ou de commandes/lignes) honorées à la fois dans le délai convenu (On Time : respect de la date/du créneau promis) ET en totalité et conformité (In Full : quantité complète, sans manquant ni avarie, marchandise conforme). Une livraison n'est comptée OTIF que si les deux conditions sont réunies simultanément : livrée en retard OU incomplète = non-OTIF. C'est donc un indicateur exigeant, exprimé en pourcentage (nombre de livraisons parfaites / nombre total de livraisons).

b. Pourquoi le commissionnaire le suit client par client : parce que la performance logistique et les exigences ne sont pas les mêmes d'un client à l'autre, et que l'OTIF est un indicateur de la satisfaction et de la fidélisation de chaque client. Un suivi par client permet de : piloter la qualité de service réellement délivrée à chacun, détecter précocement les dérives sur un compte donné avant qu'il ne se plaigne ou parte à la concurrence, alimenter les revues de performance et les engagements contractuels de niveau de service (SLA, parfois assortis de pénalités ou de bonus/malus), cibler les actions correctives (transporteur, ligne, site) sur les clients concernés, et disposer d'un argument objectif de négociation commerciale. Un OTIF global masquerait les écarts : c'est la vision par client qui protège la relation et le chiffre d'affaires.$c370$,
  scoring_grid    = $c370$1 pt : définir l'OTIF = On Time In Full, taux de livraisons à la fois à l'heure et complètes/conformes (les deux conditions cumulées, en pourcentage). 1 pt : justifier le suivi client par client = indicateur de satisfaction/qualité de service propre à chaque client, permettant de détecter les dérives, piloter les SLA et sécuriser la relation commerciale. Total = 2.$c370$
WHERE source_ref = 'COMM-M5-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Distinction juridique en une phrase : le commissionnaire de transport organise librement le transport et agit en son nom propre pour le compte de son commettant, en assumant une obligation de résultat (il est garant de la bonne exécution et répond des substitués qu'il choisit), tandis que le mandataire (transitaire) agit au nom et pour le compte de son mandant, sur les instructions de celui-ci, sans liberté d'organisation et avec une simple obligation de moyens.

Éléments attendus :
- Commissionnaire : nom propre, liberté de choix des moyens et des sous-traitants, obligation de résultat, garant de ses substitués.
- Mandataire : au nom et pour le compte du mandant, agit sur instructions, obligation de moyens.$c370$,
  scoring_grid    = $c370$Total 2 points. (1 pt) Caractérisation du commissionnaire : agit en son nom propre + organise librement le transport (obligation de résultat / garant des substitués). (1 pt) Caractérisation du mandataire : agit au nom et pour le compte du mandant, sur instructions (obligation de moyens). Une réponse qui n'oppose pas les deux régimes plafonne à 1 pt.$c370$
WHERE source_ref = 'COMM-M6-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Fondement de la mise en cause directe : le commettant agit contre le commissionnaire de transport sur le fondement de sa responsabilité de plein droit du fait de ses substitués. Le commissionnaire est légalement garant de l'exécution du transport et répond des transporteurs qu'il se substitue comme de ses propres fautes (article L.132-6 du Code de commerce). Le commettant n'a donc pas à prouver une faute personnelle du commissionnaire : il lui suffit d'établir le dommage (destruction de la palette) survenu pendant le transport organisé par le commissionnaire. La responsabilité est engagée dans les limites et selon le régime applicable au transport considéré (ici, transport routier).

b. Recours ensuite : après avoir indemnisé le commettant, le commissionnaire dispose d'une action récursoire (recours en garantie) contre le transporteur routier substitué, auteur du dommage, pour se faire rembourser dans les limites de responsabilité et selon le régime propre à ce contrat de transport (contrat-type / CMR à l'international). Il subroge ainsi le commettant dans ses droits contre le voiturier fautif.$c370$,
  scoring_grid    = $c370$Total 2 points. (1 pt) Fondement : responsabilité de plein droit du commissionnaire, garant de ses substitués (répond du transporteur affrété comme de lui-même ; mise en cause directe sans preuve d'une faute personnelle). (1 pt) Recours : action récursoire / recours en garantie du commissionnaire contre le transporteur routier substitué, dans les limites du régime du transport.$c370$
WHERE source_ref = 'COMM-M6-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$On lui oppose la prescription. L'action en responsabilité née du contrat de commission de transport se prescrit par un an (prescription annale, article L.133-6 du Code de commerce, applicable au commissionnaire comme au transporteur). Le délai court à compter de la livraison (ou de la date à laquelle la marchandise aurait dû être livrée). L'avarie remontant à quatorze mois et aucun acte interruptif de prescription (action en justice, reconnaissance de responsabilité, etc.) n'étant intervenu, le délai d'un an est expiré : l'action du commettant est prescrite. On lui oppose donc une fin de non-recevoir tirée de la prescription, qui éteint définitivement son droit d'agir, sans avoir à discuter le fond de la réclamation.$c370$,
  scoring_grid    = $c370$Total 2 points. (1 pt) Identification de la prescription annale (délai d'un an) applicable à l'action contre le commissionnaire de transport. (1 pt) Application au cas : 14 mois écoulés sans acte interruptif > délai dépassé, donc action prescrite / fin de non-recevoir opposable. Réponse invoquant la prescription sans préciser le délai d'un an : 1 pt.$c370$
WHERE source_ref = 'COMM-M6-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le connaissement maritime (bill of lading) occupe une place à part parce qu'il est, à la différence de la LTA aérienne, un titre représentatif de la marchandise, négociable et transmissible par endossement.

Particularités du connaissement :
- Il cumule trois fonctions : reçu de la marchandise prise en charge par le transporteur, preuve du contrat de transport maritime, et surtout titre représentatif des marchandises.
- En tant que titre négociable (le plus souvent établi "à ordre"), il incorpore le droit sur la marchandise : celui qui en est le porteur légitime peut disposer de la marchandise et en obtenir la livraison au port de destination. Il se transmet par endossement, ce qui permet la vente des marchandises en cours de transport et son utilisation comme garantie (crédit documentaire).

Comparaison avec la LTA aérienne (lettre de transport aérien / AWB) :
- La LTA n'est pas un titre représentatif de la marchandise et n'est pas négociable. Elle vaut seulement reçu de la marchandise et preuve du contrat de transport aérien.
- Le destinataire prend livraison en justifiant de son identité (il est nommément désigné), et non en présentant le document : la détention de la LTA ne confère aucun droit de disposition sur la marchandise.

Conséquence pratique : à l'import maritime, la remise de la marchandise est subordonnée à la présentation d'un original du connaissement, ce qui en fait un instrument central du paiement et du financement du commerce international, à la différence de la LTA.$c370$,
  scoring_grid    = $c370$Total 2 points. (1 pt) Le connaissement est un titre représentatif de la marchandise, négociable / endossable (le porteur peut disposer de la marchandise et en prendre livraison). (1 pt) La LTA aérienne n'est pas négociable ni représentative : simple reçu et preuve du contrat, livraison au destinataire nommément désigné. Mention seule des fonctions reçu/preuve sans la fonction de titre représentatif : 1 pt.$c370$
WHERE source_ref = 'COMM-M6-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Numéro d'identification requis : le client doit disposer d'un numéro EORI (Economic Operator Registration and Identification), identifiant unique de l'opérateur économique attribué au sein de l'Union européenne, obligatoire pour réaliser des formalités douanières (import/export) avec les pays tiers.

b. Les trois éléments de la déclaration en douane qui déterminent les droits et taxes :
1. L'espèce tarifaire : le classement de la marchandise dans la nomenclature douanière (position/code de nomenclature), qui fixe le taux de droit applicable.
2. L'origine de la marchandise : origine douanière (préférentielle ou non préférentielle), qui conditionne le taux de droit et l'éventuel bénéfice d'un régime préférentiel.
3. La valeur en douane : l'assiette (généralement fondée sur la valeur transactionnelle) sur laquelle s'appliquent les droits de douane et la TVA à l'importation.

Ce sont ces trois paramètres (espèce, origine, valeur) qui, combinés, déterminent le montant des droits et taxes exigibles.$c370$,
  scoring_grid    = $c370$Total 2 points. (0,5 pt) Numéro EORI cité. (1,5 pt) Les trois éléments déterminant les droits et taxes, soit 0,5 pt chacun : espèce tarifaire (classement/nomenclature), origine, valeur en douane. Barème proportionnel si un seul ou deux éléments cités.$c370$
WHERE source_ref = 'COMM-M6-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Contexte : le commissionnaire de transport organise le déplacement en son nom propre et répond de plein droit du fait de ses substitués, mais son indemnisation est PLAFONNÉE (limites d'indemnité du contrat type « commission de transport » et des contrats types de transport applicables aux substitués : limites par kilo, par colis et par envoi). Face à une marchandise dont la valeur dépasse très largement ces plafonds, la couverture « responsabilité » ne suffit pas.

a. La précaution à prendre
Je fais souscrire une ASSURANCE AD VALOREM sur la marchandise, c'est-à-dire une assurance « facultés / marchandises transportées » couvrant la valeur réelle déclarée du bien, distincte de mon assurance de responsabilité civile professionnelle. Concrètement :
- j'attire par écrit l'attention du commettant sur l'existence des plafonds légaux et sur l'insuffisance de l'indemnité en cas de perte ou d'avarie totale ;
- je lui propose de souscrire (ou de me donner mandat écrit de souscrire pour son compte) une police marchandises ad valorem, sur la base d'une valeur déclarée correspondant à la valeur réelle de l'envoi ;
- à défaut, je recueille son refus exprès et écrit, afin de dégager ma responsabilité sur ce point.
Une solution complémentaire consiste à obtenir une déclaration de valeur / déclaration d'intérêt spécial à la livraison, qui relève contractuellement le plafond d'indemnité, mais elle reste plus coûteuse et moins protectrice que l'assurance de la chose elle-même.

b. Pourquoi sous cette forme (assurance de la marchandise et non de la responsabilité)
Parce que l'assurance ad valorem garantit la VALEUR RÉELLE du bien indépendamment des plafonds d'indemnité et indépendamment de la preuve d'une faute : elle couvre la chose transportée, pas seulement ma responsabilité. En cas de sinistre, le commettant est indemnisé à hauteur de la valeur assurée, là où la seule mise en jeu de ma responsabilité (ou de celle du transporteur substitué) n'aboutirait qu'à une indemnité plafonnée, très inférieure à la valeur de la marchandise. Cette forme protège donc à la fois le commettant (indemnisation intégrale) et le commissionnaire (pas d'exposition au-delà des plafonds, réduction du risque de litige), et elle est adaptée aux envois de forte valeur pour lesquels les limitations légales sont manifestement insuffisantes.$c370$,
  scoring_grid    = $c370$Total 2 points. a. Précaution (1 pt) : souscrire / faire souscrire une assurance ad valorem (assurance facultés-marchandises) sur la valeur réelle, en informant le commettant par écrit — 1 pt (0,5 si seulement « souscrire une assurance » sans préciser ad valorem/marchandises ni la valeur réelle). b. Justification de la forme (1 pt) : parce que la responsabilité du commissionnaire (et de ses substitués) est plafonnée et que l'assurance de la marchandise couvre la valeur réelle indépendamment des plafonds et de la faute — 1 pt (0,5 si la notion de plafond OU la couverture de la valeur réelle est citée sans relier les deux).$c370$
WHERE source_ref = 'COMM-M6-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Depuis 2016, le titre professionnel Enseignant de la Conduite et de la Sécurité Routière (ECSR) a remplacé le BEPECASER (Brevet pour l'Exercice de la Profession d'Enseignant de la Conduite Automobile et de la Sécurité Routière). Le BEPECASER, diplôme historique de la profession, a été supprimé et remplacé par ce titre professionnel de niveau 5 (anciennement niveau III), délivré par le ministère chargé de l'emploi, afin de rénover et de professionnaliser l'accès au métier d'enseignant de la conduite.$c370$,
  scoring_grid    = $c370$Identification correcte du diplôme remplacé (BEPECASER, sigle ou intitulé complet) : 1,5 pt. Précision du contexte (remplacement en 2016 par le titre pro ECSR de niveau 5) : 0,5 pt. Total : 2 pts.$c370$
WHERE source_ref = 'ECSR-M1-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$L'autorisation d'enseigner la conduite et la sécurité routière est délivrée par le préfet, c'est-à-dire par la préfecture du département de résidence du candidat. Elle est indispensable et doit être obtenue avant de dispenser toute première leçon : nul ne peut enseigner la conduite à titre onéreux sans détenir cette autorisation préfectorale, distincte du titre ou diplôme lui-même. Elle est délivrée sous conditions (aptitude, honorabilité, diplôme requis) et fait l'objet d'un renouvellement périodique.$c370$,
  scoring_grid    = $c370$Autorité correctement identifiée : le préfet / la préfecture : 1,5 pt. Précision utile (délivrance sous conditions, préalable obligatoire à tout enseignement à titre onéreux) : 0,5 pt. Total : 2 pts.$c370$
WHERE source_ref = 'ECSR-M1-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Trois lieux ou contextes d'exercice possibles pour un enseignant de la conduite (trois réponses attendues parmi) : a. une école de conduite (auto-école) traditionnelle, cadre d'exercice le plus courant ; b. une auto-école associative ou une structure d'insertion sociale et professionnelle (mobilité solidaire, publics en insertion) ; c. un organisme de formation, un centre de formation ou un CFA préparant aux métiers de la route et de la conduite. Autres contextes recevables : entreprise disposant d'une flotte de véhicules (formation interne des conducteurs), collectivité ou association de prévention menant des actions de sécurité routière, plateforme d'enseignement de la conduite en ligne encadrant des enseignants indépendants.$c370$,
  scoring_grid    = $c370$Trois contextes d'exercice pertinents et distincts cités : 2 pts (environ 0,67 pt par contexte correct). Deux contextes corrects : 1 pt. Un seul contexte correct : 0,5 pt. Total : 2 pts.$c370$
WHERE source_ref = 'ECSR-M1-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le projet de Karim (préparer le titre ECSR tout en étant salarié d'une école de conduite pendant sa formation) correspond à la voie de l'alternance, c'est-à-dire à un contrat d'apprentissage ou à un contrat de professionnalisation. Dans cette voie, l'apprenant partage son temps entre l'organisme de formation qui prépare au titre et l'auto-école employeuse où il exerce en situation professionnelle sous tutorat. Il acquiert ainsi une expérience de terrain rémunérée tout en préparant les deux CCP du titre. À noter : l'exercice effectif de l'enseignement de la conduite suppose l'obtention préalable de l'autorisation d'enseigner (le cas échéant à titre temporaire pendant la formation).$c370$,
  scoring_grid    = $c370$Identification de la voie de l'alternance : 1,5 pt. Précision du type de contrat (apprentissage et/ou professionnalisation) : 0,5 pt. Total : 2 pts.$c370$
WHERE source_ref = 'ECSR-M1-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le titre professionnel ECSR est structuré en deux CCP (certificats de compétences professionnelles) : a. CCP 1 : former des conducteurs à une mobilité sûre, autonome et responsable, dans la catégorie B (groupe léger). Il regroupe les compétences d'enseignement de la conduite du permis B, en s'appuyant sur le REMC (Référentiel pour l'Éducation à une Mobilité Citoyenne) : préparation à l'épreuve théorique (code) et à l'épreuve pratique, conception de séances, progression et évaluation formative des élèves. b. CCP 2 : sensibiliser l'ensemble des usagers de la route à l'adoption de comportements sûrs et responsables. Il couvre l'animation d'actions de sensibilisation et de prévention à la sécurité routière auprès de publics variés (au-delà du seul apprentissage du permis) : facteurs d'accident, risques routiers, comportements citoyens.$c370$,
  scoring_grid    = $c370$Objet du CCP 1 correctement résumé (former à la conduite / mobilité catégorie B) : 1 pt. Objet du CCP 2 correctement résumé (sensibiliser tous les usagers à des comportements sûrs et responsables) : 1 pt. Total : 2 pts.$c370$
WHERE source_ref = 'ECSR-M1-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le véhicule servant à l'enseignement pratique de la catégorie B doit répondre à des exigences spécifiques. Citer trois exigences parmi les suivantes :

a. Double commande : le véhicule est équipé d'une double commande permettant à l'enseignant d'agir au minimum sur le frein et sur le débrayage (embrayage), afin de pouvoir reprendre la main et garantir la sécurité à tout instant.

b. Rétroviseurs supplémentaires : présence de rétroviseurs additionnels pour l'enseignant (rétroviseur intérieur supplémentaire et rétroviseur extérieur côté passager) offrant une vision complète de l'environnement pour surveiller la circulation et anticiper.

c. Signalisation « auto-école » : dispositif apparent (panneau/inscription) signalant aux autres usagers qu'il s'agit d'un véhicule d'enseignement de la conduite, ce qui participe à la sécurité et à la tolérance des autres conducteurs.

Autres exigences recevables : véhicule en bon état d'entretien et conforme au contrôle technique, adapté à la catégorie enseignée (nombre de places, transmission), assuré pour l'enseignement de la conduite à titre onéreux.$c370$,
  scoring_grid    = $c370$3 exigences valides attendues : environ 0,67 point par exigence correctement citée (double commande frein/débrayage / rétroviseurs supplémentaires / signalisation auto-école ou autre exigence recevable). Total = 2 points. 2 exigences valides = 1,3 point ; 1 exigence = 0,7 point.$c370$
WHERE source_ref = 'ECSR-M1-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Étape obligatoire : réaliser une évaluation de départ (évaluation préalable) de l'élève avant la signature du contrat de formation. Elle est le plus souvent effectuée au moyen d'un support d'évaluation, dans le véhicule ou sur un outil dédié.

b. À quoi elle sert : elle permet d'estimer le volume prévisionnel de formation (nombre d'heures nécessaires pour atteindre le niveau requis), de personnaliser le parcours pédagogique en fonction des acquis et besoins de l'élève, et d'informer loyalement le futur élève afin qu'il s'engage en connaissance de cause (transparence sur la durée et le coût prévisibles). Le résultat de cette évaluation figure ensuite dans le contrat.$c370$,
  scoring_grid    = $c370$1 point : identifier l'étape obligatoire = l'évaluation de départ / évaluation préalable avant contrat. 1 point : en expliquer la finalité (estimer le volume d'heures prévisionnel, personnaliser le parcours et informer l'élève). Total = 2 points.$c370$
WHERE source_ref = 'ECSR-M1-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La « double tâche permanente » désigne le fait que l'enseignant assume simultanément et en continu deux missions pendant toute la leçon de conduite :

a. Une tâche de sécurité (co-pilotage) : surveiller en permanence l'environnement de circulation, anticiper les situations à risque et rester prêt à intervenir immédiatement (parole, aide au volant, double commande) pour garantir la sécurité de l'élève, des autres usagers et de lui-même. L'enseignant reste juridiquement responsable de la conduite du véhicule.

b. Une tâche pédagogique (enseignement) : observer l'élève, guider son action, expliquer, faire verbaliser, corriger et évaluer en temps réel afin de faire progresser l'apprentissage vers les objectifs de la séance.

La difficulté du métier tient à la gestion conjointe et ininterrompue de ces deux exigences, la sécurité primant toujours sur la progression pédagogique.$c370$,
  scoring_grid    = $c370$1 point : la dimension sécurité / co-pilotage (surveillance de l'environnement, intervention possible via double commande, responsabilité). 1 point : la dimension pédagogique (observer, guider, corriger, évaluer l'élève). Total = 2 points. Bonus valorisé sans dépasser 2 : préciser le caractère simultané et permanent et la primauté de la sécurité.$c370$
WHERE source_ref = 'ECSR-M1-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Rôle de l'ANTS (Agence Nationale des Titres Sécurisés) : c'est un organisme administratif de l'État. Elle gère les démarches dématérialisées du parcours (dépôt en ligne de la demande de permis, dossier, attribution du numéro NEPH) ainsi que la production, la fabrication et l'envoi du titre sécurisé qu'est le permis de conduire. Elle n'évalue pas le candidat. (Attention : la réservation des places de l'examen pratique ne relève pas de l'ANTS mais de la plateforme RdvPermis, gérée par la Sécurité routière / les DDT.)

b. Rôle de l'IPCSR (Inspecteur du Permis de Conduire et de la Sécurité Routière) : c'est un agent public qui fait passer et évalue les épreuves d'examen du permis (notamment l'épreuve pratique) et décide de la réussite ou de l'échec. Il intervient le jour de l'examen, sur le terrain, comme évaluateur.

En résumé : l'ANTS relève de l'administratif et du titre (la démarche en ligne et le « papier »), l'IPCSR relève de l'évaluation de l'examen (la personne qui juge la prestation). Ils n'interviennent ni au même moment ni pour la même fonction dans le parcours de l'élève.$c370$,
  scoring_grid    = $c370$1 point : rôle de l'ANTS correctement décrit (organisme administratif gérant les démarches dématérialisées, la demande/NEPH et la production/délivrance du titre permis). 1 point : rôle de l'IPCSR correctement décrit (inspecteur qui fait passer et évalue les épreuves d'examen). Total = 2 points. La distinction claire administratif/titre vs évaluateur d'examen est l'attendu central. Ne pas exiger — ni créditer comme rôle de l'ANTS — la réservation des places d'examen (elle relève de RdvPermis).$c370$
WHERE source_ref = 'ECSR-M1-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Réponse à donner au gérant : c'est faux, l'agrément de l'établissement ne dispense en rien de détenir une autorisation d'enseigner personnelle. Ce sont deux autorisations distinctes.

a. L'agrément d'exploitation est délivré par le préfet à l'établissement d'enseignement de la conduite (à l'exploitant/au gérant). Il autorise l'ouverture et l'exploitation de l'auto-école ; il porte sur la structure, ses locaux et son organisation.

b. L'autorisation d'enseigner est une autorisation individuelle, nominative et personnelle, délivrée par le préfet à l'enseignant. Elle est subordonnée à la détention du titre ou diplôme requis (titre professionnel ECSR, ou l'ancien BEPECASER). Elle est propre à la personne qui enseigne.

c. Conséquence : nul ne peut enseigner la conduite à titre onéreux sans être personnellement titulaire de cette autorisation, quelle que soit la situation de l'établissement. Enseigner sans autorisation personnelle constitue une infraction et engage la responsabilité de l'enseignant comme de l'exploitant. L'agrément de l'école et l'autorisation d'enseigner sont donc complémentaires mais non substituables.$c370$,
  scoring_grid    = $c370$1 point : affirmer clairement que non, l'agrément de l'établissement ne dispense pas de l'autorisation d'enseigner personnelle. 1 point : justifier par la distinction des deux titres (agrément = établissement/exploitant délivré par le préfet ; autorisation d'enseigner = individuelle, nominative, personnelle, subordonnée au titre ECSR) et/ou la conséquence (enseigner sans autorisation = infraction). Total = 2 points.$c370$
WHERE source_ref = 'ECSR-M1-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Réponse attendue (une phrase) : selon le REMC, la formation ne vise pas seulement la réussite à l'examen mais l'accès à une mobilité citoyenne, c'est-à-dire la capacité à conduire de façon autonome, sûre, responsable et respectueuse des autres usagers et de l'environnement, tout au long de la vie.

Éléments clés que doit contenir la phrase de l'élève-enseignant :
- dépasser le simple objectif « avoir le permis / réussir l'examen » ;
- viser une conduite autonome et sûre sur le long terme (au-delà du jour de l'examen) ;
- notion de responsabilité / citoyenneté (partage de la route, respect des autres usagers, de l'environnement).

Exemple de formulation acceptable : « L'examen n'est qu'une étape : le REMC vise à faire de vous un conducteur autonome, sûr et responsable pour toute votre vie de conducteur, pas seulement à vous faire réussir le jour J. »$c370$,
  scoring_grid    = $c370$Barème sur 2 points : 1 pt pour marquer le dépassement du seul objectif « réussir l'examen » (conduite autonome et sûre dans la durée) ; 1 pt pour la dimension citoyenne/responsable (respect des autres usagers, sécurité, mobilité citoyenne). Total = 2.$c370$
WHERE source_ref = 'ECSR-M2-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Âge de début de l'AAC (apprentissage anticipé de la conduite) : dès 15 ans.

b. Étape obligatoire de départ : le parcours débute obligatoirement par la formation initiale en auto-école (phase théorique et pratique), c'est-à-dire l'obtention de l'épreuve théorique générale (le code) puis une formation pratique initiale d'un minimum de 20 heures de conduite. Cette formation initiale est sanctionnée par une attestation de fin de formation initiale (AFFI) délivrée par l'enseignant, condition indispensable pour ensuite commencer la conduite accompagnée avec l'accompagnateur (phase précédée du rendez-vous préalable).

En résumé : début à 15 ans, en commençant par la formation initiale en école de conduite (code + 20 h minimum) validée par l'AFFI, avant la phase de conduite accompagnée.$c370$,
  scoring_grid    = $c370$Barème sur 2 points : 1 pt pour l'âge (15 ans) ; 1 pt pour l'étape de départ obligatoire = formation initiale en auto-école (code + formation pratique initiale d'au moins 20 h, validée par l'AFFI) avant la conduite accompagnée. Total = 2.$c370$
WHERE source_ref = 'ECSR-M2-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les trois attestations du parcours scolaire d'éducation routière et le niveau où chacune se passe :

a. APER — Attestation de Première Éducation à la Route : à l'école primaire (maternelle et élémentaire ; validée en fin de cycle du primaire).

b. ASSR 1 — Attestation Scolaire de Sécurité Routière de premier niveau : au collège, en classe de 5e.

c. ASSR 2 — Attestation Scolaire de Sécurité Routière de second niveau : au collège, en classe de 3e. (L'ASSR 2 est notamment exigée pour l'inscription à l'épreuve du permis pour les personnes nées à partir de 1988.)$c370$,
  scoring_grid    = $c370$Barème sur 2 points : les trois attestations correctement nommées et associées à leur niveau. 2 pts si les 3 couples (attestation + niveau) sont exacts ; 1 pt si 2 couples exacts ; 0 pt si 1 seul ou aucun. (APER = primaire, ASSR1 = 5e, ASSR2 = 3e). Total = 2.$c370$
WHERE source_ref = 'ECSR-M2-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les quatre niveaux de la matrice GDE (Goals for Driver Education), du plus concret au plus global :

1. Niveau 1 — Maniement et contrôle du véhicule : maîtrise technique du véhicule (commandes, manœuvres, tenue de route).

2. Niveau 2 — Maîtrise des situations de circulation : conduite dans le trafic, application des règles, adaptation aux différentes situations de circulation.

3. Niveau 3 — Objectifs et contexte de la conduite : buts et contexte du déplacement (pourquoi, où, quand, avec qui, dans quel état), choix qui influencent le trajet et la prise de risque.

4. Niveau 4 — Projet de vie et aptitudes personnelles : valeurs, style de vie, motivations et autoévaluation du conducteur qui déterminent son rapport au risque.

Logique : plus on monte dans les niveaux, plus les facteurs sont personnels et déterminants sur la sécurité, et moins ils sont travaillés dans la formation traditionnelle.$c370$,
  scoring_grid    = $c370$Barème sur 2 points : 2 pts si les 4 niveaux sont cités dans le bon ordre (véhicule → situations de circulation → objectifs/contexte du déplacement → projet de vie/aptitudes personnelles) ; 1 pt si les 4 niveaux sont présents mais l'ordre est incorrect, ou si seulement 3 niveaux corrects dans l'ordre ; 0 pt sinon. Total = 2.$c370$
WHERE source_ref = 'ECSR-M2-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les quatre compétences du REMC pour la catégorie B :

1. Compétence 1 — Maîtriser le maniement du véhicule dans un trafic faible ou nul.

2. Compétence 2 — Appréhender la route et circuler dans des conditions normales de circulation.

3. Compétence 3 — Circuler dans des conditions difficiles et partager la route avec les autres usagers.

4. Compétence 4 — Pratiquer une conduite autonome, sûre et économique.

Ces quatre compétences structurent la progression pédagogique et le livret d'apprentissage : elles vont de la maîtrise technique isolée vers une conduite autonome, sûre, économique et respectueuse de l'environnement.$c370$,
  scoring_grid    = $c370$Barème sur 2 points : 0,5 pt par compétence correctement énoncée (les 4 compétences : maniement en trafic faible/nul ; conditions normales ; conditions difficiles et partage de la route ; conduite autonome, sûre et économique). Total = 2.$c370$
WHERE source_ref = 'ECSR-M2-QC-05' AND type='qr';

-- ⚠️ ECSR-M2-QC-06 : Minimum légal 20 h (13 h en boîte automatique) : certain et exact. La moyenne nationale réelle citée « de l'ordre de 30 à 35 heures » est cohérente avec la communication officielle (Sécurité routière évoque ~35 h) mais reste une statistique à revérifier sur une source à jour avant diffusion. Barème conforme (1+1=2=max_score).
UPDATE public.question_bank SET
  expected_answer = $c370$Les deux chiffres ne mesurent pas la même chose, et c'est tout l'enjeu de la réponse à donner à l'élève.

a. Ce que représentent les 20 heures. Il s'agit du minimum légal de formation pratique fixé par la réglementation pour la catégorie B (20 heures de conduite en boîte manuelle, réduites à 13 heures en boîte automatique). C'est un plancher réglementaire en dessous duquel une auto-école n'a pas le droit de présenter un candidat à l'examen. Ce n'est donc pas une durée « recommandée » ni une durée « suffisante » : c'est le strict minimum administratif imposé, indépendant du niveau réel de l'élève.

b. Ce que représentent les 30 heures. C'est une estimation pédagogique personnalisée, issue de l'évaluation de départ et de la progression réelle de l'élève au regard du REMC (compétences à atteindre avant de conduire seul en sécurité). Le nombre d'heures nécessaire n'est pas le même pour tous : la moyenne réellement constatée pour obtenir le permis se situe nettement au dessus du minimum légal, de l'ordre de 30 à 35 heures. Proposer 30 heures, ce n'est pas contourner la loi, c'est viser un objectif de compétence et de sécurité, pas seulement le respect d'un seuil administratif.

Conclusion à formuler à l'élève : les 20 heures sont un minimum imposé par la loi, les 30 heures sont l'estimation de ce qu'il lui faudra vraisemblablement pour être réellement prêt et autonome. Le volume final sera ajusté à sa progression, à la hausse comme à la baisse.$c370$,
  scoring_grid    = $c370$a. Identifie les 20 h comme minimum légal réglementaire (plancher, non un optimum) : 1 point. b. Identifie les 30 h comme estimation pédagogique personnalisée liée à l'évaluation et aux compétences REMC (objectif de sécurité, non un contournement) : 1 point. Total : 2 points.$c370$
WHERE source_ref = 'ECSR-M2-QC-06' AND type='qr';

-- ⚠️ ECSR-M2-QC-07 : Valeurs exactes et en vigueur : durée minimale 1 an, distance minimale 3 000 km, deux rendez-vous pédagogiques obligatoires, AFFI comme document d'entrée en phase accompagnée. Seul point à contextualiser selon la date d'application retenue par le référentiel : l'âge minimal de présentation à l'épreuve pratique, abaissé à 17 ans depuis le 1er janvier 2024 (auparavant 17,5 ans en AAC). Barème confor
UPDATE public.question_bank SET
  expected_answer = $c370$Avant de présenter un élève ayant suivi l'apprentissage anticipé de la conduite (AAC, dès 15 ans) à l'épreuve pratique, l'enseignant vérifie que l'ensemble des conditions de la phase de conduite accompagnée sont réunies.

a. Conditions liées à la formation initiale. L'élève a validé sa formation initiale en école de conduite : réussite de l'épreuve théorique générale (code) et volume minimal de conduite atteint, matérialisés par l'attestation de fin de formation initiale (AFFI) qui ouvre la phase accompagnée.

b. Conditions de durée et de distance de la phase accompagnée. La phase de conduite accompagnée doit avoir duré au minimum 1 an et couvert au minimum 3 000 km parcourus avec l'accompagnateur.

c. Conditions de suivi pédagogique. Les rendez-vous pédagogiques obligatoires (au nombre de deux) ont bien été effectués avec l'enseignant, et le livret d'apprentissage est renseigné.

d. Conditions individuelles et avis de l'enseignant. L'élève a atteint l'âge requis pour se présenter à l'épreuve pratique, et l'enseignant délivre un avis favorable attestant que les compétences du REMC sont maîtrisées.

En synthèse, les deux vérifications centrales et spécifiques à l'AAC sont la durée minimale (1 an) et la distance minimale (3 000 km), complétées par la réalisation des deux rendez-vous pédagogiques et l'avis favorable.$c370$,
  scoring_grid    = $c370$Durée minimale de 1 an de conduite accompagnée : 0,5 point. Distance minimale de 3 000 km parcourus : 0,5 point. Réalisation des deux rendez-vous pédagogiques obligatoires (et livret renseigné) : 0,5 point. Formation initiale validée / avis favorable de l'enseignant / âge requis : 0,5 point. Total : 2 points. (Attribuer les 2 points dès lors que la durée et la distance sont citées avec au moins deux des autres conditions.)$c370$
WHERE source_ref = 'ECSR-M2-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Dispositif proposé. Après un échec à l'épreuve pratique, on propose au candidat la conduite supervisée. Elle permet, une fois la formation initiale suivie (code réussi et volume de conduite validé), de continuer à rouler accompagné d'un conducteur expérimenté, sans devoir enchaîner de nombreuses heures payantes en école. L'accès est notamment ouvert après un échec à l'épreuve pratique, après un rendez-vous préalable avec l'enseignant et sous réserve de l'accord de l'assureur ; l'accompagnateur doit être titulaire du permis B depuis au moins 5 ans sans interruption.

b. Pourquoi ce dispositif. La conduite supervisée répond exactement au besoin exprimé : progresser et gagner en expérience à moindre coût, entre deux présentations à l'examen. Elle augmente le kilométrage et la variété des situations rencontrées (conditions météo, trafic, nuit, longs trajets), ce qui consolide l'automatisation des compétences et réduit le stress le jour de l'examen, sans imposer de durée ni de kilométrage minimal réglementaire. C'est donc une alternative pertinente à la simple multiplication d'heures en auto-école, tout en gardant un cadre encadré et assuré.

Remarque : à 19 ans, la condition d'âge est remplie ; il n'y a pas d'obstacle de ce côté.$c370$,
  scoring_grid    = $c370$a. Nomme correctement le dispositif « conduite supervisée » : 1 point. b. Justifie l'intérêt (gagner de l'expérience et du kilométrage à moindre coût entre deux examens, cadre encadré et assuré, accessible après échec à l'épreuve pratique) : 1 point. Total : 2 points.$c370$
WHERE source_ref = 'ECSR-M2-QC-08' AND type='qr';

-- ⚠️ ECSR-M2-QC-09 : Valeurs vérifiées et exactes : permis probatoire 3 ans (2 ans en AAC), capital initial de 6 points montant à 12 par acquisition progressive, formation complémentaire post-permis de 7 h à suivre entre le 6e et le 12e mois donnant droit à une réduction d'un an de la période probatoire (sans infraction), stage de sensibilisation permettant de récupérer jusqu'à 4 points. Ces barèmes de points étant su
UPDATE public.question_bank SET
  expected_answer = $c370$Après l'obtention du permis, la formation du conducteur se poursuit à travers plusieurs dispositifs. Deux exemples avec leur effet principal :

a. Le permis probatoire. Le nouveau conducteur démarre avec un capital de 6 points sur une période probatoire de 3 ans (réduite à 2 ans en cas d'apprentissage anticipé de la conduite). Le capital augmente progressivement chaque année en l'absence d'infraction jusqu'à atteindre le maximum de 12 points. Effet principal : responsabiliser le jeune conducteur et l'inciter à la prudence pendant les premières années, statistiquement les plus accidentogènes, par une acquisition progressive des points et des sanctions renforcées.

b. La formation complémentaire post-permis. Le conducteur peut suivre, dans une fenêtre de quelques mois après l'obtention du permis (entre le 6e et le 12e mois), une formation d'une journée (7 heures) axée sur la conscience du risque et l'auto-évaluation. Effet principal : réduire d'un an la durée de la période probatoire lorsque aucune infraction n'a été commise, tout en renforçant la lucidité du conducteur sur ses propres limites.

Autre dispositif recevable en remplacement de l'un des deux : le stage de sensibilisation à la sécurité routière (récupération de points), dont l'effet principal est de récupérer jusqu'à 4 points et de retravailler les comportements à risque.$c370$,
  scoring_grid    = $c370$Premier dispositif correctement nommé avec son effet principal (ex. permis probatoire : acquisition progressive du capital de points / responsabilisation) : 1 point. Second dispositif correctement nommé avec son effet principal (ex. formation post-permis : réduction d'un an de la période probatoire, ou stage de récupération : jusqu'à 4 points) : 1 point. Total : 2 points.$c370$
WHERE source_ref = 'ECSR-M2-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La matrice GDE (Goals for Driver Education) hiérarchise la conduite en quatre niveaux : le niveau 1 correspond au maniement du véhicule (manœuvres, contrôle technique) ; le niveau 2 à la maîtrise des situations de circulation ; le niveau 3 aux objectifs et au contexte de la conduite (pourquoi, quand, avec qui, sur quel trajet on conduit) ; le niveau 4 aux aspirations personnelles, aux valeurs, au style de vie et au rapport au risque.

a. Le niveau 1 est rarement en cause chez les jeunes. La plupart des jeunes conducteurs possèdent des compétences techniques de base suffisantes : ils savent manœuvrer le véhicule. Le niveau 1 est une condition nécessaire mais non suffisante de la sécurité : maîtriser le véhicule n'empêche pas de s'exposer au danger. Les accidents ne s'expliquent donc que marginalement par un déficit de maniement.

b. Les niveaux 3 et 4 déterminent l'exposition au risque. Ce qui explique la suraccidentalité des jeunes se joue plus haut dans la matrice : les motivations et le contexte des trajets (niveau 3, par exemple conduire de nuit, le week-end, avec des passagers, après une soirée) et surtout les valeurs personnelles, la recherche de sensations, la pression du groupe, la surestimation de ses capacités et l'acceptation du risque (niveau 4). Ce sont ces décisions et ces attitudes qui conduisent à la vitesse excessive, à l'alcool, aux stupéfiants ou à la fatigue au volant, c'est-à-dire aux principaux facteurs d'accident.

Conclusion : on dit que les niveaux 3 et 4 « expliquent » mieux les accidents parce qu'ils gouvernent l'exposition au risque et les choix du conducteur, là où le niveau 1 ne conditionne que l'exécution technique. La pédagogie doit donc dépasser le simple maniement pour travailler l'auto-évaluation, les motivations et le rapport au risque.$c370$,
  scoring_grid    = $c370$a. Explique que le niveau 1 (maniement) est généralement acquis chez les jeunes et n'est donc pas la cause déterminante (condition nécessaire mais non suffisante) : 1 point. b. Explique que les niveaux 3 (contexte/objectifs des trajets) et 4 (valeurs, style de vie, prise de risque, auto-évaluation) gouvernent l'exposition au risque et les comportements accidentogènes : 1 point. Total : 2 points.$c370$
WHERE source_ref = 'ECSR-M2-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Avant de préparer une séance, l'enseignant situe l'élève à partir de deux sources d'information complémentaires :

a. Le livret d'apprentissage (ou livret de formation) de l'élève : il retrace la progression au regard des compétences du REMC, indique les objectifs déjà validés, ceux en cours d'acquisition et ceux non abordés. C'est le fil rouge du parcours.

b. La fiche de suivi / le bilan de la séance précédente : renseignée en fin de dernière séance, elle précise le niveau réel de maîtrise atteint, les difficultés rencontrées et le ou les objectifs proposés pour la suite.

En croisant ces deux sources, l'enseignant connaît le point de départ de l'élève et peut fixer un objectif de séance adapté, ni trop facile ni hors de portée.$c370$,
  scoring_grid    = $c370$a. Livret d'apprentissage / de formation cité : 1 pt
b. Fiche de suivi / bilan de la séance précédente cité : 1 pt
Total : 2 pts$c370$
WHERE source_ref = 'ECSR-M3-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les deux premiers temps d'une séance de conduite, dans l'ordre et avant la phase d'apprentissage proprement dite, sont :

a. L'accueil de l'élève : mise en confiance, échange sur son état du moment (fatigue, appréhension), et rappel de ce qui a été vu lors de la séance précédente.

b. L'annonce et la fixation de l'objectif de la séance (contrat pédagogique) : l'enseignant présente ce qui va être travaillé, en explique l'intérêt et s'assure que l'élève comprend et adhère à l'objectif. C'est ce contrat qui rend l'élève acteur et qui servira de référence au bilan final.

Ce n'est qu'ensuite que débute la phase d'apprentissage (mise en situation, guidage, entraînement).$c370$,
  scoring_grid    = $c370$a. 1er temps : accueil de l'élève : 1 pt
b. 2e temps : annonce / fixation de l'objectif (contrat pédagogique) : 1 pt
Ordre respecté exigé (accueil puis objectif). Une inversion des deux temps : 1 pt.
Total : 2 pts$c370$
WHERE source_ref = 'ECSR-M3-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Un bilan de fin de séance co-construit (l'enseignant fait s'auto-évaluer l'élève avant de compléter) comporte trois volets :

a. Les acquis : ce qui a été réussi et maîtrisé au regard de l'objectif fixé en début de séance.

b. Les points restant à travailler : les difficultés rencontrées, les erreurs récurrentes, ce qui n'est pas encore stabilisé.

c. L'objectif de la prochaine séance : ce qui découle logiquement des deux volets précédents et qui sera reporté sur le livret / la fiche de suivi.

Le caractère co-construit signifie que l'élève formule d'abord sa propre analyse ; l'enseignant confronte, ajuste et valide, ce qui développe la capacité d'auto-évaluation attendue par le REMC.$c370$,
  scoring_grid    = $c370$a. Les acquis / réussites : 0,75 pt
b. Les points à travailler / difficultés : 0,75 pt
c. L'objectif de la prochaine séance : 0,5 pt
(3 volets cités = 2 pts ; 2 volets = 1 pt ; 1 volet = 0,5 pt)
Total : 2 pts$c370$
WHERE source_ref = 'ECSR-M3-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La « leçon-promenade », où l'élève conduit sans objectif pédagogique défini, constitue une faute professionnelle pour plusieurs raisons convergentes :

a. Absence d'objectif = absence d'évaluation possible : sans objectif fixé et annoncé, on ne peut ni mesurer une progression, ni établir un bilan, ni renseigner utilement le livret. La séance ne s'inscrit dans aucune progression pédagogique.

b. Non-respect du cadre du REMC : la formation doit être structurée par des objectifs organisés en compétences et sous-objectifs. Conduire « pour rouler » sort de ce cadre et prive l'élève d'un apprentissage réellement construit.

c. Préjudice pour l'élève : le temps de conduite est un temps payé et souvent financé (CPF, permis à 1 euro). Une séance sans objectif fait perdre du temps et de l'argent à l'élève, sans le rapprocher de la réussite à l'examen ni de la sécurité en conduite autonome.

En résumé, enseigner suppose un objectif, une mise en situation adaptée et une évaluation : une leçon sans objectif ne remplit aucune de ces exigences.$c370$,
  scoring_grid    = $c370$a. Sans objectif, pas d'évaluation ni de progression mesurable : 1 pt
b. Non-conformité à la pédagogie par objectifs / REMC : 0,5 pt
c. Préjudice pour l'élève (temps et argent, financement) : 0,5 pt
(2 pts si au moins deux arguments pertinents et développés)
Total : 2 pts$c370$
WHERE source_ref = 'ECSR-M3-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Définition : le guidage décroissant consiste à réduire progressivement la quantité et la précision des consignes données par l'enseignant à mesure que l'élève gagne en autonomie, jusqu'à ce qu'il agisse seul.

b. Exemple concret : pour un changement de direction à une intersection.
- Au début (guidage fort) : « Au prochain carrefour, tu tournes à droite : mets ton clignotant maintenant, ralentis, contrôle ton rétroviseur et ton angle mort, serre à droite. »
- Ensuite (guidage allégé) : « Prends la prochaine à droite. »
- Enfin (guidage minimal) : « Dirige-toi vers le centre-ville. » L'élève identifie et réalise seul l'ensemble des actions (clignotant, contrôles, placement, allure).

Cette diminution graduelle de l'aide transfère la charge de la décision de l'enseignant vers l'élève et prépare la conduite autonome.$c370$,
  scoring_grid    = $c370$a. Définition correcte (réduction progressive de l'aide / des consignes à mesure que l'autonomie augmente) : 1 pt
b. Exemple concret et pertinent illustrant la décroissance du guidage : 1 pt
Total : 2 pts$c370$
WHERE source_ref = 'ECSR-M3-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Deux temps de la gestion pédagogique d'une intervention aux doubles commandes :

a. Le temps de l'action immédiate (sur l'instant, priorité à la sécurité). L'enseignant reprend le contrôle du véhicule (frein, embrayage, direction, arrêt de l'accélération) pour neutraliser le danger et sécuriser la situation. À ce moment, on n'explique pas et on ne commente pas : on agit. L'objectif est uniquement de garantir la sécurité des occupants et des autres usagers.

b. Le temps de l'analyse pédagogique différée (après coup, une fois la situation redevenue sûre et le véhicule à l'arrêt ou la circulation apaisée). L'enseignant revient sur l'événement avec l'élève : il fait verbaliser ce qui s'est passé, identifie la cause de l'intervention (défaut de détection, de décision ou d'action de l'élève), et construit avec lui une solution pour la fois suivante. C'est ce retour à froid, factuel et sans dévalorisation, qui transforme l'incident en apprentissage.

En résumé : d'abord sécuriser (agir), puis exploiter pédagogiquement (analyser avec l'élève). L'intervention aux doubles commandes n'est pédagogiquement utile que si le second temps a lieu.$c370$,
  scoring_grid    = $c370$a. Premier temps = action immédiate / reprise de contrôle pour sécuriser, sans commenter : 1 point. b. Second temps = analyse/retour différé avec l'élève (verbalisation, cause, remédiation) une fois la sécurité rétablie : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'ECSR-M3-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Les trois composantes d'un feedback factuel :
1. Le fait observable : décrire précisément le comportement ou l'action constatés, de façon objective et vérifiable (par exemple : « au carrefour, tu n'as pas contrôlé ton rétroviseur gauche avant de tourner »). On décrit ce qui s'est réellement passé, pas une impression.
2. L'effet ou la conséquence : expliquer l'incidence de ce fait sur la conduite, la sécurité ou la maîtrise du véhicule (par exemple : « du coup, tu n'as pas vu le cycliste qui arrivait dans ton angle mort »). Cela donne du sens au retour et le relie à un enjeu de sécurité.
3. La piste d'amélioration / attente concrète : indiquer ce qui est attendu la prochaine fois, de façon opérationnelle et atteignable (par exemple : « la prochaine fois, contrôle ton rétroviseur puis ton angle mort avant d'engager le virage »). Le feedback ouvre sur l'action suivante.

b. Ce que le feedback factuel ne vise jamais :
Il ne vise jamais la personne, sa valeur ou sa personnalité : ce n'est ni un jugement, ni une critique dévalorisante, ni une étiquette (« tu es nul », « tu ne comprends jamais rien »). Il porte sur le comportement observable et modifiable, pas sur l'individu. Son but est de faire progresser, pas de sanctionner ni de blesser l'estime de soi de l'élève.$c370$,
  scoring_grid    = $c370$a. Trois composantes citées (fait observable ; effet/conséquence ; piste d'amélioration attendue) : 1 point (les trois attendues ; tolérance d'une formulation équivalente). b. Ne vise jamais la personne / n'est pas un jugement de valeur sur l'individu : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'ECSR-M3-QC-07' AND type='qr';

-- ⚠️ ECSR-M3-QC-08 : Vérifié : la question ne demande que 3 aménagements, tous d'ordre pédagogique — le corrigé y répond largement et le barème somme à 2 = max_score. Le fond pédagogique est fiable et suffit à noter la copie. Le seul point à confirmer est la donnée réglementaire de l'aménagement de l'épreuve du code (version oralisée « dys », temps majoré, pièces justificatives) : à vérifier avant diffusion, mais il n
UPDATE public.question_bank SET
  expected_answer = $c370$Trois aménagements pédagogiques adaptés à un élève présentant un trouble DYS (dyslexie, dysphasie, dyspraxie…) ou un TDAH. En citer trois parmi :

1. Séquences plus courtes et fractionnées : découper la leçon en objectifs simples et progressifs, multiplier les pauses, éviter les séances trop longues qui épuisent l'attention (particulièrement utile en cas de TDAH). Une seule consigne à la fois.

2. Consignes claires, concrètes et reformulées : donner des instructions courtes, une par une, dans un langage simple ; faire reformuler l'élève pour vérifier la compréhension ; privilégier l'oral et la démonstration plutôt que l'écrit dense (utile en cas de dyslexie).

3. Supports multisensoriels et adaptés : recourir à des schémas, pictogrammes, démonstrations gestuelles, codes couleurs ; pour le code, proposer la lecture à voix haute des questions, un temps majoré, ou l'épreuve en version aménagée lorsque l'élève y a droit.

4. Répétition, sur-apprentissage et régularité : reprendre plusieurs fois les mêmes automatismes, espacer et répéter les acquis, maintenir un cadre et un déroulé de séance stables et prévisibles (rassurant, structurant pour le TDAH et les DYS).

5. Climat bienveillant et valorisation : réduire la pression et la peur de l'erreur, valoriser les réussites, encourager régulièrement pour soutenir la motivation et l'estime de soi.

[À CONFIRMER: modalités officielles d'aménagement de l'épreuve théorique générale (code) pour candidats DYS ou TDAH — épreuve en version « dys » à la lecture des questions oralisée / temps majoré, justificatifs médicaux à fournir. Vérifier les conditions exactes en vigueur auprès de la réglementation ECSR / du dispositif d'examen avant de les présenter comme certaines.]$c370$,
  scoring_grid    = $c370$Trois aménagements pertinents et distincts attendus, chacun valant environ 0,67 point (barème : 2 points si 3 aménagements corrects et distincts ; 1 point si 2 ; 0,5 point si 1 seul). Total = 2 points.$c370$
WHERE source_ref = 'ECSR-M3-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$L'auto-évaluation de l'élève pendant la formation prépare directement sa sécurité après le permis, pour les raisons suivantes :

a. Elle développe la conscience de ses propres limites. En apprenant à juger lui-même sa conduite (« ai-je bien anticipé ? étais-je à la bonne vitesse ? »), l'élève acquiert la capacité de repérer ses points faibles. Après le permis, seul dans son véhicule, il n'a plus l'enseignant pour lui signaler ses erreurs : c'est donc son propre regard critique qui devient le garde-fou.

b. Elle rend l'élève acteur et autonome de sa sécurité. L'auto-évaluation développe l'auto-régulation : savoir renoncer, adapter sa conduite à son état (fatigue, stress, alcool) et aux conditions (météo, trafic). C'est précisément l'objectif de la matrice GDE / du REMC : agir non seulement sur le maniement du véhicule, mais sur la lucidité du conducteur envers lui-même.

c. Elle installe une posture durable de progrès et d'humilité. Un conducteur qui sait s'auto-évaluer continue d'apprendre après l'examen, ne surestime pas ses compétences (moindre prise de risque des jeunes conducteurs) et sait remettre en question sa conduite. À l'inverse, un conducteur qui ne s'auto-évalue pas reproduit ses erreurs sans les voir.

En synthèse : la sécurité après le permis ne repose plus sur un contrôle externe (l'enseignant, l'examinateur) mais sur l'auto-contrôle du conducteur ; former à l'auto-évaluation, c'est transférer à l'élève la responsabilité de sa propre sécurité pour toute sa vie de conducteur.$c370$,
  scoring_grid    = $c370$1 point pour le mécanisme : l'auto-évaluation développe la conscience des limites / l'auto-contrôle qui remplace le contrôle externe de l'enseignant une fois seul au volant. 1 point pour la finalité sécurité durable : autonomie, auto-régulation (adaptation à son état et aux conditions), moindre surestimation / conducteur qui continue de progresser (lien REMC / matrice GDE valorisé). Total = 2 points.$c370$
WHERE source_ref = 'ECSR-M3-QC-09' AND type='qr';

-- ⚠️ ECSR-M3-QC-10 : Vérifié : les deux sous-questions (limite du rôle + conduite à tenir) sont traitées ; barème 1+1 = 2 = max_score. Le fond pédagogique et déontologique est fiable et suffit à noter. Point réglementaire à confirmer avant diffusion : le dispositif exact du contrôle médical de l'aptitude à la conduite (arrêté listant les affections, rôle du médecin agréé par la préfecture, procédure) — mentionné au co
UPDATE public.question_bank SET
  expected_answer = $c370$a. La limite de votre rôle :
L'enseignant de la conduite est un pédagogue, pas un professionnel de santé. Sa compétence porte sur l'apprentissage de la conduite et son adaptation pédagogique, pas sur le diagnostic ni le traitement de troubles médicaux. Lorsque des difficultés persistantes qui relèvent de la santé (détection visuelle défaillante, malaises) résistent à toutes les adaptations pédagogiques, on sort du champ pédagogique : le problème n'est plus un problème d'apprentissage mais possiblement un problème d'aptitude médicale à la conduite. L'enseignant n'a ni la légitimité ni les moyens de le résoudre, et il ne doit pas poser de diagnostic.

b. La conduite à tenir :
1. Nommer les faits avec bienveillance : exposer à l'élève, de façon factuelle et sans le dévaloriser, les difficultés objectivement constatées et le fait que les adaptations n'ont pas suffi à les lever.
2. Réorienter vers l'avis médical compétent : inviter l'élève à consulter un médecin (médecin traitant, ophtalmologiste selon le cas) afin d'évaluer son aptitude. Certaines pathologies ou déficiences relèvent d'un contrôle médical de l'aptitude à la conduite, le cas échéant devant un médecin agréé par la préfecture.
3. Ne pas cautionner une mise en danger : ne pas présenter à l'examen ni laisser conduire un élève dont l'inaptitude médicale compromettrait sa sécurité et celle des autres usagers, tant que la situation médicale n'a pas été évaluée. La sécurité prime sur la poursuite de la formation.
4. Tracer et rester dans son rôle : documenter la démarche, maintenir le dialogue, et reprendre la formation si et quand un avis médical favorable (avec éventuel aménagement) le permet.

[À CONFIRMER: cadre réglementaire précis du contrôle médical de l'aptitude à la conduite — liste des affections médicales incompatibles ou compatibles avec la conduite (arrêté en vigueur), recours au médecin agréé par la préfecture, obligations exactes de l'élève/candidat. Vérifier les références en vigueur avant de les présenter comme certaines.]$c370$,
  scoring_grid    = $c370$a. Limite du rôle correctement posée : l'enseignant n'est pas médecin, difficultés d'ordre médical hors du champ pédagogique, pas de diagnostic : 1 point. b. Conduite à tenir : réorientation vers un avis médical (le cas échéant médecin agréé) + ne pas cautionner une mise en danger (sécurité) : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'ECSR-M3-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Circuit d'inscription à l'épreuve théorique générale (ETG, « le code ») :

a. Obtenir un numéro NEPH (Numéro d'Enregistrement Préfectoral Harmonisé). L'élève doit d'abord être enregistré auprès des services de l'État, soit via son auto-école, soit en candidat libre en créant un dossier sur le site de l'ANTS (Agence nationale des titres sécurisés). Le NEPH est indispensable pour pouvoir réserver l'épreuve.

b. Choisir un opérateur agréé et réserver une place. L'ETG n'est plus organisée par l'État en salle de préfecture : elle est passée auprès d'opérateurs privés agréés (par exemple La Poste, SGS/Objectif Code, Bureau Veritas, DEKRA, Pointgab, Code'nGo). L'élève réserve en ligne un créneau et un centre, et règle les frais d'inscription (30 euros).

c. Se présenter le jour J avec les justificatifs. L'élève apporte une pièce d'identité valide et son NEPH (ou sa convocation). L'épreuve se déroule sur tablette : 40 questions, réussite à partir de 35 bonnes réponses sur 40. En cas d'échec, il peut se réinscrire auprès d'un opérateur et repasser l'épreuve.$c370$,
  scoring_grid    = $c370$a. NEPH via auto-école ou ANTS : 0,75 pt. b. Opérateur agréé + réservation en ligne payante (30 euros) : 0,75 pt. c. Justificatifs le jour J (pièce d'identité + NEPH) et principe de l'épreuve : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ECSR-M4-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Épreuve pratique du permis B :

a. Durée. L'épreuve pratique dure environ 32 minutes, dont à peu près 25 minutes de conduite effective (le reste étant consacré à l'accueil, aux vérifications, aux manœuvres et au bilan).

b. Les deux conditions cumulatives de réussite (elles doivent être remplies toutes les deux) :
1. Obtenir un minimum de 20 points sur 31 à la grille d'évaluation (le Certificat d'Examen au Permis de Conduire, CEPC).
2. Ne commettre aucune faute éliminatoire (par exemple une faute entraînant l'intervention de l'accompagnateur sur les commandes, ou une mise en danger d'un usager).

Ainsi, un candidat qui atteint 20 points mais commet une faute éliminatoire échoue, et inversement un candidat sans faute éliminatoire mais avec moins de 20 points échoue également.$c370$,
  scoring_grid    = $c370$a. Durée d'environ 32 minutes (dont ~25 min de conduite) : 0,5 pt. b1. Minimum 20 points sur 31 : 0,75 pt. b2. Aucune faute éliminatoire : 0,75 pt (le caractère cumulatif des deux conditions doit être explicite). Total = 2 pts.$c370$
WHERE source_ref = 'ECSR-M4-QC-02' AND type='qr';

-- ⚠️ ECSR-M4-QC-03 : [À CONFIRMER: la liste exacte des « cinq temps » peut correspondre à un modèle de déroulé propre au référentiel/support de la formation ECSR. La séquence proposée est cohérente avec la pédagogie REMC (recueil des représentations, méthodes actives, évaluation formative) mais l'intitulé précis des cinq étapes doit être aligné sur le cours de référence du module M4.]
UPDATE public.question_bank SET
  expected_answer = $c370$Les cinq temps d'un cours thématique structuré en séance collective, dans l'ordre :

1. Accueil et annonce de l'objectif : ouvrir la séance, situer le thème et énoncer clairement l'objectif pédagogique visé (ce que l'élève saura ou saura faire à la fin).
2. Recueil des représentations : faire s'exprimer les élèves sur ce qu'ils pensent déjà du thème (mise en situation, questionnement), afin de partir de leurs acquis et de leurs idées reçues.
3. Apport de contenus : structurer et compléter à partir des représentations recueillies, en apportant les connaissances et les faits utiles (méthodes actives, supports).
4. Application et échanges : faire manipuler, discuter, confronter les points de vue, appliquer à des situations concrètes pour ancrer l'apprentissage.
5. Synthèse et évaluation : reformuler l'essentiel, vérifier l'atteinte de l'objectif (évaluation formative) et faire le lien avec la conduite et la mobilité citoyenne (REMC).$c370$,
  scoring_grid    = $c370$Cinq temps attendus, dans le bon ordre : 0,4 pt par temps correctement nommé et situé (accueil/objectif ; recueil des représentations ; apport de contenus ; application/échanges ; synthèse/évaluation). Total = 2 pts. Ordre incorrect : retirer 0,5 pt sur l'ensemble.$c370$
WHERE source_ref = 'ECSR-M4-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$L'étape indispensable est le recueil des représentations des élèves (faire d'abord exprimer ce qu'ils pensent, croient ou savent déjà de l'alcool au volant) avant d'apporter le moindre fait ou chiffre.

Pourquoi c'est indispensable :
- Point de départ pédagogique : on part de ce que sait réellement le groupe, ce qui permet d'identifier les idées reçues et les fausses croyances (« un café dessaoule », « je tiens bien l'alcool », « quelques bières ça va ») pour ensuite les corriger avec des faits ciblés.
- Méthode active et implication : en faisant parler les élèves d'abord, on les rend acteurs de la séance ; l'apport de faits vient répondre à leurs propos, ce qui le rend plus percutant et mieux mémorisé qu'un exposé descendant.
- Adaptation du message : le recueil permet à l'enseignant d'ajuster son contenu au niveau et aux représentations réelles du groupe, plutôt que de délivrer un discours standard qui risque de tomber à côté ou de provoquer un rejet.

En résumé : sans recueil préalable des représentations, l'apport de faits reste un exposé magistral peu efficace ; avec lui, l'enseignant ancre les faits sur les conceptions des élèves et favorise un réel changement de comportement.$c370$,
  scoring_grid    = $c370$Étape identifiée = recueil des représentations (faire exprimer les élèves d'abord) : 1 pt. Justification pédagogique (au moins deux arguments parmi : partir des acquis/idées reçues, rendre l'élève acteur par une méthode active, adapter/ancrer le message pour un meilleur impact) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ECSR-M4-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le bachotage de séries consiste à mémoriser les réponses des questions déjà vues sans comprendre la règle qui les fonde : l'élève reconnaît des questions mais ne maîtrise pas les principes, si bien que la moindre reformulation ou une question inédite de la banque le met en échec. C'est une impasse car l'objectif de l'ETG n'est pas de « cocher juste » mais d'acquérir des connaissances transférables à des situations réelles de conduite ; un savoir non compris ne se transfère ni à l'examen renouvelé ni, surtout, à la sécurité au volant.$c370$,
  scoring_grid    = $c370$Idée 1 : mémorisation des réponses sans compréhension des règles, donc échec dès qu'une question est reformulée ou inédite (banque de questions qui tourne) : 1 pt. Idée 2 : l'ETG vise des connaissances transférables à la conduite réelle / la sécurité, qu'un savoir non compris ne permet pas d'atteindre : 1 pt. Réponse en deux phrases : condition de forme, sans point dédié. Total = 2 pts.$c370$
WHERE source_ref = 'ECSR-M4-QC-05' AND type='qr';

-- ⚠️ ECSR-M4-QC-06 : [À CONFIRMER: la liste exacte des situations classées faute éliminatoire (E) et leur libellé sur le bilan de compétences officiel de l'épreuve pratique B, à recaler sur la grille d'évaluation en vigueur. Les deux exemples fournis (feu rouge / refus de priorité et intervention de l'examinateur) sont conformes à la grille actuelle.]
UPDATE public.question_bank SET
  expected_answer = $c370$Une faute éliminatoire (codée E sur le bilan de compétences de l'examen pratique B) sanctionne un comportement dangereux ou une infraction grave, indépendamment du nombre de points accumulés par le candidat.

a. Deux exemples de fautes éliminatoires :
1) Le non-respect d'une règle de priorité ou d'un feu de signalisation (par exemple franchir un feu rouge, ne pas marquer l'arrêt à un STOP, refuser une priorité à droite ou à un piéton engagé sur un passage).
2) L'intervention de l'examinateur (ou de l'enseignant présent) sur les doubles commandes, sur le volant ou par un ordre verbal, rendue nécessaire pour éviter un accident ; on peut aussi citer la circulation à gauche de la chaussée dans un contexte dangereux, le franchissement d'une ligne continue de façon dangereuse ou la circulation à contresens.

b. Ce qu'elles entraînent : dès qu'une faute éliminatoire est constatée, l'épreuve est un échec quel que soit le total de points obtenu, y compris si le candidat avait par ailleurs suffisamment de points pour être reçu. La faute éliminatoire prime sur le décompte des points : elle traduit une mise en danger (du candidat, de l'examinateur ou d'un tiers) incompatible avec la délivrance du permis.$c370$,
  scoring_grid    = $c370$a. Deux exemples corrects de fautes éliminatoires : 1 pt (0,5 pt par exemple valable). b. Conséquence correctement énoncée (échec de l'épreuve quel que soit le total de points) : 1 pt. Total : 2 pts.$c370$
WHERE source_ref = 'ECSR-M4-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Démarche d'analyse (bilan à froid) après un échec à l'épreuve pratique, en trois étapes :

1) Accueillir et recueillir le ressenti de l'élève : dédramatiser l'échec, laisser l'élève s'exprimer et s'auto-évaluer (« comment as-tu vécu l'épreuve ? qu'est-ce qui a été difficile ? »). On sécurise la relation pédagogique avant toute analyse technique.

2) Analyser objectivement les causes à partir du bilan de l'examinateur : reprendre la grille d'évaluation, identifier la ou les fautes (notamment une éventuelle faute éliminatoire) et les compétences insuffisamment maîtrisées, en distinguant les causes techniques (maîtrise du véhicule, prise d'information, application des règles) des causes liées à la gestion émotionnelle (stress, précipitation).

3) Définir un plan de remédiation et de nouveaux objectifs : traduire les causes identifiées en objectifs pédagogiques concrets et mesurables, planifier les séances de reprise ciblées, puis reprogrammer une nouvelle présentation quand les compétences sont de nouveau acquises.$c370$,
  scoring_grid    = $c370$Trois étapes attendues, cohérentes et ordonnées (recueil du ressenti / analyse objective des causes via le bilan / plan de remédiation et nouveaux objectifs). Barème : environ 0,67 pt par étape pertinente, arrondi à 2 pts si les trois étapes sont citées et articulées ; 1,5 pt pour deux étapes correctes ; 1 pt pour une seule. Total : 2 pts.$c370$
WHERE source_ref = 'ECSR-M4-QC-07' AND type='qr';

-- ⚠️ ECSR-M4-QC-08 : [À CONFIRMER: le rattachement précis du taux de réussite aux obligations d'affichage / de qualité (référentiel Qualiopi, information consommateur) selon la réglementation en vigueur pour les auto-écoles. Le principe (taux de réussite suivi et affiché, Qualiopi requis pour les financements CPF) est exact ; seule la citation réglementaire précise reste à recaler.]
UPDATE public.question_bank SET
  expected_answer = $c370$Trois raisons professionnelles de ne présenter à l'examen que des élèves réellement prêts :

1) La sécurité routière et la responsabilité de l'enseignant : présenter un élève non prêt revient à valider (ou risquer de valider) un conducteur qui ne maîtrise pas les compétences de sécurité ; cela va à l'encontre de la mission de l'ECSR et de sa déontologie.

2) L'intérêt de l'élève et la préservation d'une ressource rare : les places d'examen sont limitées et les délais d'attente parfois longs ; un échec évitable fait perdre du temps, coûte de l'argent à l'élève (heures supplémentaires, nouvelle présentation) et peut le démotiver ou dégrader sa confiance.

3) La performance et la crédibilité de l'établissement : le taux de réussite est un indicateur suivi (affichage/information des consommateurs, exigences qualité type Qualiopi pour les financements, dont le CPF) ; ne présenter que des élèves prêts protège la réputation de l'auto-école et le bon usage des places attribuées.$c370$,
  scoring_grid    = $c370$Trois raisons professionnelles distinctes et pertinentes. Barème : environ 0,67 pt par raison valable ; 2 pts pour trois raisons correctes, 1,5 pt pour deux, 0,75 pt pour une. Total : 2 pts.$c370$
WHERE source_ref = 'ECSR-M4-QC-08' AND type='qr';

-- ⚠️ ECSR-M4-QC-09 : [À CONFIRMER: la durée officielle de la phase de conduite autonome (établie à environ 5 minutes dans le déroulé réglementaire actuel de l'épreuve pratique B) et les modalités officielles (fléchage, mémorisation d'itinéraire, recours au système de navigation). La réponse reste prudente en indiquant « plusieurs minutes » sans chiffrer, ce qui la met à l'abri d'une erreur ; à recaler si un chiffre pr
UPDATE public.question_bank SET
  expected_answer = $c370$Lors de la phase de conduite autonome de l'épreuve B, le candidat doit, pendant plusieurs minutes, rejoindre une destination ou suivre un itinéraire (à l'aide d'un fléchage directionnel, d'un système de navigation type GPS ou de consignes mémorisées) sans guidage continu de l'examinateur.

En quoi cela change ce qu'il faut enseigner en amont :

1) Développer l'autonomie décisionnelle : l'élève doit apprendre à prendre seul ses décisions (choix de voie, de trajectoire, d'allure) sans attendre une consigne, ce qui suppose de retirer progressivement le guidage pas à pas au profit de consignes plus globales pendant la formation.

2) Enseigner la prise d'information à visée directionnelle : lecture et anticipation des panneaux de direction, préparation des changements de direction à l'avance, suivi d'un itinéraire, et utilisation d'un système de navigation (regarder la route et non l'écran, gérer une erreur de trajet sans se déstabiliser).

3) Travailler la gestion mentale et l'auto-évaluation : gérer la charge mentale et le stress liés à l'absence de guidage, savoir se corriger seul, et développer la capacité d'auto-évaluation, compétences visées par le REMC au niveau de l'autonomie du conducteur.$c370$,
  scoring_grid    = $c370$Compréhension de ce qu'implique la phase autonome (conduire vers une destination / suivre un itinéraire ou fléchage / GPS sans guidage) : 1 pt. Conséquences pédagogiques en amont (développer l'autonomie décisionnelle, la prise d'information directionnelle et l'auto-évaluation / retrait progressif du guidage) : 1 pt. Total : 2 pts.$c370$
WHERE source_ref = 'ECSR-M4-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Deux techniques d'animation pour gérer un participant qui conteste systématiquement, sans crisper le groupe :

1) Écoute active et reformulation, en reconnaissant une part de vérité avant de nuancer : accuser réception de son propos sans le juger (« je comprends que tu n'aies jamais eu d'accident »), puis recadrer avec des faits objectifs plutôt qu'avec l'argument d'autorité (données d'accidentologie, rôle de la vitesse dans la distance d'arrêt et la gravité des chocs). On oppose des faits, pas des personnes.

2) Renvoyer la question au groupe (technique du rebond) : solliciter l'avis des autres participants (« qu'en pensez-vous, avez-vous vécu des situations différentes ? ») pour que la régulation vienne des pairs et non d'un face-à-face formateur/contestataire ; on peut aussi différer le débat (« notons ce point, on y revient à la pause ») pour ne pas monopoliser le temps collectif.$c370$,
  scoring_grid    = $c370$Deux techniques distinctes et adaptées à l'animation d'un groupe (par exemple écoute active/reformulation avec recadrage par les faits, et renvoi au groupe/différé). Barème : 1 pt par technique pertinente et correctement justifiée (le fait qu'elle évite de crisper le groupe). Total : 2 pts.$c370$
WHERE source_ref = 'ECSR-M4-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Principe attendu : transformer une intention vague et non mesurable (« sensibiliser à la vitesse ») en objectif pédagogique opérationnel, c'est-à-dire décrivant un comportement observable de l'apprenant, dans des conditions données et avec un critère de réussite (logique « qui fait quoi, dans quelles conditions, à quel niveau »).

b. Reformulation possible : « À l'issue de la séance, chaque élève sera capable de calculer et de comparer la distance d'arrêt à 50 km/h et à 90 km/h (distance de réaction pour un temps de réaction d'environ 1 seconde + distance de freinage), et d'en déduire l'incidence d'une hausse de vitesse sur le risque, avec au moins 80 % de réponses justes lors de l'exercice d'application. » On peut aussi viser un objectif comportemental (« identifier, sur une situation filmée, deux conséquences d'une vitesse excessive sur le champ de vision et la distance d'arrêt »). L'essentiel : un verbe d'action observable, une condition de réalisation et un critère d'évaluation, ce qui rend l'objectif évaluable contrairement au verbe « sensibiliser ».$c370$,
  scoring_grid    = $c370$a. Identifier le défaut de l'intention initiale (verbe non observable / non mesurable) et énoncer les composantes d'un objectif opérationnel (comportement observable + condition + critère) : 1 pt. b. Proposer une reformulation concrète et effectivement évaluable, avec un verbe d'action et un critère de réussite : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ECSR-M5-QC-01' AND type='qr';

-- ⚠️ ECSR-M5-QC-02 : [À CONFIRMER: la dénomination exacte et l'ordre canonique des « trois temps » tels qu'ils figurent dans le support de formation ECSR/REMC du module M5. La logique en trois phases (recueil des représentations, apport d'éléments objectifs, co-construction) est standard en animation de prévention, mais le libellé attendu par le référentiel interne doit être vérifié contre le cours.] Barème 0,7+0,7+0,
UPDATE public.question_bank SET
  expected_answer = $c370$Les trois temps d'une animation de prévention sur un facteur de risque, conduite sans moraliser (posture de facilitateur, pas de jugement), sont :

a. Temps 1 : faire émerger les représentations et le vécu du groupe. On part de ce que les participants pensent et vivent (questionnement ouvert, tour de table, brainstorming) plutôt que d'asséner un discours. Cela valorise la parole et évite la posture de donneur de leçons.

b. Temps 2 : apporter et confronter des éléments objectifs. On met en regard les représentations avec des faits, des données et des repères (statistiques d'accidentalité, mécanique de la distance d'arrêt, effets de l'alcool, des stupéfiants, de la fatigue). L'animateur informe sans culpabiliser.

c. Temps 3 : faire élaborer des solutions et un engagement. Le groupe construit lui-même des stratégies de prévention et des alternatives concrètes, ce qui favorise l'appropriation et le passage à l'action (méthode active, l'apprenant est acteur de la conclusion).$c370$,
  scoring_grid    = $c370$Un temps correctement identifié et explicité = 0,67 pt (arrondi) ; barème pratique : Temps 1 (représentations / vécu) : 0,7 pt ; Temps 2 (apport et confrontation de faits objectifs) : 0,7 pt ; Temps 3 (co-construction de solutions / engagement) : 0,6 pt. Total = 2 pts. Les trois temps sont exigés ; il manque un temps = retrait de la part correspondante.$c370$
WHERE source_ref = 'ECSR-M5-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Durée du stage : le stage de sensibilisation à la sécurité routière (dit « stage de récupération de points ») dure 2 jours consécutifs, soit 14 heures d'animation (deux journées de 7 heures), encadré par une équipe d'animateurs (un expert de la sécurité routière et un psychologue).

b. Points récupérés : le stage permet de récupérer jusqu'à 4 points, dans la limite du plafond du permis (12 points ; le solde ne peut jamais dépasser le capital maximal). Si le conducteur ne dispose pas de 4 points « manquants », il ne récupère que ce qui lui permet de revenir au plafond.

c. Repères complémentaires à mentionner : le stage est volontaire dans ce cas (récupération de points) et n'est possible qu'une fois par an (délai d'un an et un jour entre deux stages ouvrant droit à récupération). Il se distingue du stage imposé par la justice ou par la préfecture.$c370$,
  scoring_grid    = $c370$a. Durée exacte (2 jours / 14 heures) : 1 pt. b. Nombre de points récupérables (4 points, dans la limite du plafond de 12) : 1 pt. Total = 2 pts. Les précisions du c. (une fois par an, délai d'un an et un jour) sont valorisées mais ne rapportent pas de point supplémentaire au-delà de 2 ; elles peuvent compenser une imprécision mineure.$c370$
WHERE source_ref = 'ECSR-M5-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Évaluation à chaud : elle est réalisée immédiatement à la fin de la formation (ou de la séance). Elle mesure surtout la satisfaction, le ressenti et la perception des acquis à l'instant T. Outil : questionnaire de satisfaction de fin de session (ou tour de table / grille d'auto-évaluation « à chaud »).

b. Évaluation à froid : elle est réalisée à distance de la formation (quelques semaines à quelques mois plus tard). Elle mesure la rétention réelle des acquis et surtout le transfert en situation, c'est-à-dire le changement effectif de comportement. Outil : questionnaire de suivi envoyé plusieurs semaines après, entretien de bilan, ou observation en situation réelle de conduite / au poste de travail.

c. Idée clé à faire ressortir : l'évaluation à chaud renseigne sur la réaction et la satisfaction ; l'évaluation à froid renseigne sur l'efficacité durable (acquis et transfert). Les deux sont complémentaires.$c370$,
  scoring_grid    = $c370$a. Définir l'évaluation à chaud (moment : fin de formation ; objet : satisfaction / ressenti) AVEC un outil pertinent (questionnaire de satisfaction, tour de table) : 1 pt. b. Définir l'évaluation à froid (moment : à distance ; objet : rétention / transfert / changement de comportement) AVEC un outil pertinent (questionnaire de suivi, entretien, observation en situation) : 1 pt. Total = 2 pts. Un outil manquant ou hors sujet = retrait de 0,5 pt sur la part concernée.$c370$
WHERE source_ref = 'ECSR-M5-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Devant des lycéens : privilégier un angle centré sur la personne, l'émotion et l'expérience de pair à pair. Le public est jeune, souvent en phase d'apprentissage ou jeune conducteur, davantage sensible à l'usage social du téléphone (réseaux, messagerie). On travaille la prise de conscience du risque personnel (temps d'inattention, distance parcourue « à l'aveugle » pendant la lecture d'un message, surrisque de l'inexpérience), on s'appuie sur des mises en situation, des témoignages et le débat entre pairs plutôt que sur un discours réglementaire. Objectif : faire émerger un changement d'attitude et d'auto-perception.

b. Devant des salariés : privilégier un angle professionnel, organisationnel et juridique. Le téléphone au volant est abordé comme un enjeu de risque routier professionnel (le risque routier est une des premières causes d'accidents mortels du travail), avec la responsabilité de chacun mais aussi de l'employeur (obligation de sécurité, document unique, charte de bonnes pratiques, protocole « je ne réponds pas au volant »). On mobilise des arguments concrets : coût des accidents, désorganisation, cadre légal, et surtout des solutions organisationnelles (gestion des appels, plages sans sollicitation, consignes internes). Objectif : inscrire la prévention dans l'organisation du travail.

c. Point commun : le facteur de risque et les données objectives (distraction, allongement du temps de réaction) restent les mêmes ; seul l'angle d'entrée et les leviers de motivation sont adaptés au public.$c370$,
  scoring_grid    = $c370$a. Angle pertinent pour les lycéens (registre personnel / émotionnel / pair à pair, prise de conscience du risque individuel) : 1 pt. b. Angle pertinent pour les salariés (risque routier professionnel, responsabilité employeur / cadre juridique, leviers organisationnels) : 1 pt. Total = 2 pts. Une simple juxtaposition sans différenciation réelle des angles = 1 pt maximum.$c370$
WHERE source_ref = 'ECSR-M5-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Fait majeur légitimant l'action : le risque routier professionnel constitue la première cause d'accidents mortels au travail en France (cumul des accidents de trajet domicile-travail et des accidents de mission). Il touche toutes les entreprises, quel que soit le secteur, dès lors que des salariés se déplacent. Ce constat, relayé par la Sécurité routière et l'Assurance maladie (branche Risques professionnels), justifie qu'un employeur soit fondé et incité à conduire une démarche de prévention structurée.

b. Outil structurant proposé à l'employeur : l'intégration du risque routier (trajet et mission) dans le Document Unique d'Évaluation des Risques Professionnels (DUERP), obligatoire pour tout employeur. À partir de cette évaluation, on décline un plan d'actions de prévention agissant sur les quatre leviers reconnus : le déplacement (limiter/organiser les trajets), le véhicule (entretien, adaptation, équipements de sécurité), les communications (règles d'usage du téléphone au volant) et les compétences (sensibilisation et formation des salariés). L'ECSR se positionne comme intervenant sur le volet formation/sensibilisation de ce plan. On peut compléter par une charte interne de bonnes pratiques.$c370$,
  scoring_grid    = $c370$a. Identification du fait majeur (risque routier = 1re cause d'accidents mortels au travail, trajet + mission) : 1 pt. b. Proposition d'un outil structurant pertinent (intégration au DUERP et/ou plan de prévention structuré) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ECSR-M5-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Rôle d'information et d'orientation : l'ECSR informe la personne du parcours spécifique. Toute personne présentant un handicap moteur doit, préalablement, se soumettre à un examen médical réalisé par un médecin agréé par la préfecture (hors médecin traitant). C'est ce médecin, et non l'ECSR, qui statue sur l'aptitude à la conduite et prescrit, le cas échéant, les aménagements du véhicule et les restrictions qui seront portées sur le titre sous forme de codes/mentions restrictives. L'ECSR oriente donc la personne vers cette évaluation et ne se substitue jamais à l'avis médical.

b. Rôle de formation adaptée : une fois l'aptitude et les préconisations connues, l'ECSR dispense un enseignement individualisé dans un véhicule doté des aménagements adaptés (par exemple boîte automatique, commandes déportées, accélérateur/frein au cerceau ou à la main), en ajustant la progression pédagogique et le rythme au besoin de l'apprenant. Il peut réaliser une évaluation de départ pour définir les besoins, et travailler en lien avec les professionnels de santé/ergothérapeutes si nécessaire. Il veille à l'accessibilité de sa pédagogie et à la sécurité durant les leçons.$c370$,
  scoring_grid    = $c370$a. Rôle d'information/orientation vers le médecin agréé et non-substitution à l'avis médical (aptitude, aménagements, codes restrictifs) : 1 pt. b. Rôle de formation adaptée (véhicule aménagé, progression individualisée) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ECSR-M5-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Deux dispositifs, hors stages de récupération de points, dans lesquels un ECSR peut animer des actions de sensibilisation :

a. En milieu scolaire et périscolaire : interventions d'éducation à la sécurité routière et à une mobilité citoyenne (continuum éducatif), préparation et passage des attestations (type ASSR/APER), actions « permis piéton » ou « permis vélo », sensibilisation des jeunes aux risques.

b. En entreprise / auprès des employeurs : actions de prévention du risque routier professionnel (trajet et mission), demi-journées de sensibilisation des salariés, appui au volet formation du plan de prévention.

Autres réponses recevables : sensibilisation grand public organisée par une collectivité ou une association de sécurité routière ; actions auprès de publics spécifiques (seniors, deux-roues motorisés) ; rendez-vous pédagogiques dans le cadre de la conduite accompagnée.$c370$,
  scoring_grid    = $c370$1 pt par dispositif pertinent et correctement identifié, dans la limite de deux dispositifs (0,5 pt si cité mais mal caractérisé). Total = 2 pts.$c370$
WHERE source_ref = 'ECSR-M5-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Contenus de « physique accessible » retenus pour un atelier vitesse :
- La distance d'arrêt décomposée : distance d'arrêt = distance de réaction + distance de freinage. La distance de réaction correspond au trajet parcouru pendant le temps de réaction (de l'ordre d'une seconde, allongé par la fatigue, l'alcool, les distracteurs) et croît proportionnellement à la vitesse. La distance de freinage, elle, croît avec le carré de la vitesse.
- L'énergie cinétique : Ec = ½ m v². Point clé à faire ressortir : l'énergie dépend du carré de la vitesse, donc doubler la vitesse multiplie par quatre l'énergie à dissiper (et, à l'ordre de grandeur, la distance de freinage) ainsi que la violence d'un choc. On peut illustrer par des comparaisons parlantes (freinage à 50 vs 90 km/h, équivalent d'une chute de hauteur).

b. Justification pédagogique du choix : ces contenus sont volontairement vulgarisés pour être accessibles à un public non scientifique. On privilégie une démarche active (partir des représentations des participants, démonstrations, ordres de grandeur concrets plutôt que formules abstraites) afin de rendre tangible le caractère non linéaire de la vitesse (effet en v²). L'objectif est de marquer durablement les esprits et de favoriser le transfert vers un changement de comportement, plutôt que de transmettre un savoir théorique.$c370$,
  scoring_grid    = $c370$a. Contenus pertinents cités (au moins deux notions : distance d'arrêt = réaction + freinage / temps de réaction, et énergie cinétique en fonction du carré de la vitesse) : 1 pt. b. Justification pédagogique (accessibilité/vulgarisation, méthode active, effet en v² rendu concret, visée comportementale) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ECSR-M5-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Trois éléments incontournables d'une réponse à un appel à projets d'une collectivité pour des actions de sensibilisation :

a. Un diagnostic et une définition du public cible : analyse du besoin et du contexte local (accidentalité du territoire, publics visés : jeunes, seniors, usagers deux-roues, salariés), pour ajuster la proposition à la demande de la collectivité.

b. Des objectifs pédagogiques clairs et la démarche associée : objectifs formulés de façon mesurable, contenus et méthodes actives retenues, déroulé/scénario pédagogique de l'action, et modalités d'évaluation des acquis et de satisfaction (indicateurs de résultat).

c. Les moyens et modalités pratiques : intervenants qualifiés (ECSR titulaire de l'autorisation d'enseigner délivrée par la préfecture), moyens matériels (supports, éventuels simulateurs/ateliers), calendrier de mise en œuvre, budget détaillé, et modalités de bilan restitué à la collectivité.

Autres éléments recevables : références/expériences antérieures, respect du cadre réglementaire, communication autour de l'action.$c370$,
  scoring_grid    = $c370$3 éléments incontournables attendus. Diagnostic/public cible : 0,75 pt ; objectifs pédagogiques et démarche/évaluation : 0,75 pt ; moyens, budget et modalités pratiques : 0,5 pt. Total = 2 pts (barème dégressif : 2 éléments pertinents = 1,25 pt environ, 1 seul = 0,5 pt).$c370$
WHERE source_ref = 'ECSR-M5-QC-10' AND type='qr';

-- ⚠️ ECSR-M6-QC-01 : [À CONFIRMER: libellé exact des CCP1 et CCP2 selon le RNCP 40990 en vigueur. La distinction titre pro (ministère du Travail/DREETS) vs autorisation d'enseigner (préfecture) est exacte et constitue le piège classique du domaine ; le nombre de CCP (2), la nature formation/sensibilisation et l'autorité de délivrance sont fiables. Seul le phrasé précis des intitulés reste à caler sur le support M6.]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Nombre de CCP : le titre professionnel ECSR se compose de 2 CCP (Certificats de Compétences Professionnelles).

b. Intitulés :
- CCP1 : Former les conducteurs à un comportement autonome et responsable dans la conduite d'un véhicule de la catégorie B (préparation aux épreuves du permis B, enseignement individuel et collectif).
- CCP2 : Sensibiliser l'ensemble des usagers de la route à l'adoption de comportements sûrs et respectueux de l'environnement (actions de sensibilisation auprès de publics variés).

c. Autorité qui délivre le titre : le titre professionnel ECSR est délivré au nom du ministère chargé de l'Emploi (ministère du Travail), via la DREETS, sur proposition du jury. À ne pas confondre avec l'autorisation d'enseigner à titre onéreux, qui est, elle, délivrée par la préfecture et qui conditionne l'exercice du métier.$c370$,
  scoring_grid    = $c370$a. Nombre de CCP (2) : 0,5 pt. b. Les deux intitulés identifiés correctement (CCP1 formation / CCP2 sensibilisation) : 1 pt (0,5 par CCP). c. Autorité correcte : ministère du Travail / DREETS : 0,5 pt (bonus de rigueur si distinction avec l'autorisation préfectorale, sans dépasser le plafond). Total = 2.$c370$
WHERE source_ref = 'ECSR-M6-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. REMC : 4 compétences globales structurent le Référentiel pour l'Éducation à une Mobilité Citoyenne :
- Compétence 1 : maîtriser le maniement du véhicule dans un trafic faible ou nul ;
- Compétence 2 : appréhender la route et circuler dans des conditions normales ;
- Compétence 3 : circuler dans des conditions difficiles et partager la route avec les autres usagers ;
- Compétence 4 : pratiquer une conduite autonome, sûre et économique.

b. Matrice GDE : 4 niveaux hiérarchisés (du plus concret au plus personnel) :
- Niveau 1 : maniement du véhicule ;
- Niveau 2 : maîtrise des situations de circulation ;
- Niveau 3 : objectifs et contexte de la conduite (buts liés au trajet, pression sociale) ;
- Niveau 4 : projets de vie et compétences personnelles (valeurs, tendances, prise de risque).

Conclusion : 4 compétences pour le REMC et 4 niveaux pour la matrice GDE, d'où les deux « 4 ».$c370$,
  scoring_grid    = $c370$a. REMC = 4 compétences : 1 pt. b. Matrice GDE = 4 niveaux : 1 pt. (Le détail des intitulés n'est pas exigé pour le point mais valorise la réponse.) Total = 2.$c370$
WHERE source_ref = 'ECSR-M6-QC-02' AND type='qr';

-- ⚠️ ECSR-M6-QC-03 : [À CONFIRMER: la liste exacte des trois marqueurs attendus par le cours M6 pour la mise en situation. La triade proposée (objectif opérationnel, méthode active, évaluation formative) découle des ancrages pédagogiques du référentiel, mais le support de formation pourrait retenir une formulation différente, par exemple en incluant la notion de progression pédagogique.]
UPDATE public.question_bank SET
  expected_answer = $c370$Les trois marqueurs pédagogiques que le jury attend de retrouver dans la séance individuelle sont :

1. Un objectif pédagogique opérationnel, annoncé et mesurable : la séance vise une compétence précise et observable (ex. « à l'issue de la séance, l'élève franchit une intersection à sens giratoire en appliquant la procédure sans intervention »). Il conditionne le contenu et l'évaluation.

2. Une méthode active : l'élève est acteur de son apprentissage (questionnement, guidage, découverte, verbalisation par l'élève, auto-analyse), l'enseignant guide plutôt qu'il ne dicte. On évite le cours descendant.

3. Une évaluation formative avec bilan : point de départ (diagnostic du niveau réel de l'élève), régulation en cours de séance et bilan final co-construit (auto-évaluation de l'élève + retour du formateur), fixant la suite de la progression.

Ces trois marqueurs traduisent la logique objectif -> mise en activité -> évaluation qui structure toute séance de conduite conforme au REMC.$c370$,
  scoring_grid    = $c370$1. Objectif pédagogique opérationnel/annoncé : 0,67 pt. 2. Méthode active (élève acteur) : 0,67 pt. 3. Évaluation formative / bilan-diagnostic : 0,66 pt. Total = 2. (Barème équilibré, environ 0,66 pt par marqueur correctement identifié.)$c370$
WHERE source_ref = 'ECSR-M6-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$L'élève se trompe sur les deux épreuves. Il faut rétablir les seuils réels du permis B :

a. Épreuve théorique générale (le « code ») : elle comporte 40 questions ; il faut au minimum 35 bonnes réponses sur 40 pour être reçu. Avec 30 bonnes réponses, l'élève est donc recalé (30 < 35). « Être tranquille » à 30 est faux : la marge d'erreur autorisée n'est que de 5 questions.

b. Épreuve pratique : elle est notée sur un total de 31 points ; il faut obtenir au minimum 20 points sur 31, sans commettre de faute éliminatoire (comportement dangereux, non-respect d'un feu ou d'un stop, intervention nécessaire de l'examinateur, etc.) pour être reçu. « Il suffit de ne pas caler » est faux : un calage isolé n'est pas éliminatoire en soi, alors qu'à l'inverse une seule faute éliminatoire entraîne l'échec même avec un bon total de points. La réussite repose sur l'évaluation de compétences de conduite autonome et sûre, pas sur la seule absence de calage.

Message pédagogique : recadrer l'élève sur les vrais critères (35/40 au code, 20/31 en pratique + absence de faute éliminatoire) pour éviter une préparation sous-dimensionnée.$c370$,
  scoring_grid    = $c370$a. Seuil du code rétabli (35 bonnes réponses sur 40) et 30 identifié comme insuffisant : 1 pt. b. Seuil de la pratique rétabli (minimum 20 points sur 31) et notion de faute éliminatoire rappelée (le calage seul n'est pas le critère) : 1 pt. Total = 2.$c370$
WHERE source_ref = 'ECSR-M6-QC-04' AND type='qr';

-- ⚠️ ECSR-M6-QC-05 : [À CONFIRMER: les deux exigences précises attendues par le cours M6 pour caractériser une action de sensibilisation CCP2. La paire proposée (objectif de changement de comportement + démarche active adaptée au public) reflète l'esprit du référentiel, mais le support pourrait formuler différemment, par exemple en distinguant explicitement la prise en compte des représentations du public et l'évaluat
UPDATE public.question_bank SET
  expected_answer = $c370$Une véritable action de sensibilisation (CCP2) se distingue d'un simple exposé de rappels de règles par deux exigences :

1. Une visée de changement de comportement (objectif comportemental, non purement informatif) : l'action ne cherche pas seulement à transmettre ou rappeler des connaissances réglementaires, mais à faire évoluer les représentations, les attitudes et les comportements du public face au risque routier. On part de ce que le public sait et fait déjà (son vécu, ses représentations) pour l'amener à prendre conscience du risque et à modifier durablement ses pratiques.

2. Une démarche active, interactive et adaptée au public cible : le public est mis en activité (échanges, questionnement, mises en situation, analyse de cas), plutôt que placé en simple réception d'un discours descendant. L'action est construite en fonction des caractéristiques et des besoins du public visé (âge, expérience, contexte) et son impact est évalué. C'est cette interactivité ciblée qui différencie la sensibilisation de l'exposé magistral.$c370$,
  scoring_grid    = $c370$1. Visée de modification des comportements/représentations (objectif comportemental et non informatif) : 1 pt. 2. Démarche active/interactive adaptée au public cible : 1 pt. Total = 2.$c370$
WHERE source_ref = 'ECSR-M6-QC-05' AND type='qr';

-- ⚠️ ECSR-M6-QC-06 : [À CONFIRMER : la distinction d'objet des deux entretiens est fiable sur le fond car elle repose sur le cadre commun DGEFP des titres professionnels (arrêté du 22 décembre 2015) — l'entretien final vérifie la compréhension globale du métier et le respect des enjeux, l'entretien technique complète la mise en situation sur les compétences techniques/pédagogiques. En revanche, les intitulés et périmè
UPDATE public.question_bank SET
  expected_answer = $c370$La session d'examen du titre professionnel ECSR comporte plusieurs modalités d'évaluation, dont deux entretiens conduits par le jury à la suite de la mise en situation professionnelle. Ils poursuivent des objectifs distincts et complémentaires.

a. L'entretien technique
Il porte sur la dimension technique et pédagogique du métier. Conduit à l'appui de la mise en situation professionnelle, il permet au jury d'approfondir et de vérifier la maîtrise des compétences mobilisées par le candidat pendant cette mise en situation : conduite d'une séance d'enseignement (théorique ou pratique), choix pédagogiques, gestion de la séance, capacité à analyser sa propre prestation. Son objet est ciblé sur le « comment » : les gestes professionnels, les savoir-faire pédagogiques et techniques, et la justification des choix opérés lors de la situation évaluée. Il vise à compléter et fiabiliser l'appréciation portée sur les compétences observées.

b. L'entretien final
Il porte sur une vision globale et sur la posture professionnelle du candidat, au-delà des situations particulières évaluées. Son objet, commun à tous les titres professionnels (cadre DGEFP, arrêté du 22 décembre 2015 relatif au dispositif de certification des titres professionnels), est de permettre au jury de s'assurer que le candidat a une compréhension d'ensemble du métier d'enseignant de la conduite et de la sécurité routière et qu'il en respecte les enjeux : cadre réglementaire (autorisation d'enseigner délivrée par la préfecture, obligations liées à l'exercice), déontologie et responsabilité de l'éducateur, enjeux de sécurité routière et d'éducation à une mobilité citoyenne (REMC), prise en compte de la relation avec l'élève et des différents publics. Il vise à apprécier le professionnalisme, l'éthique et la capacité du candidat à se situer dans son métier.

En synthèse : l'entretien technique cible les compétences techniques et pédagogiques mobilisées dans la mise en situation (le « faire »), tandis que l'entretien final cible la compréhension globale du métier, la posture et le respect des enjeux réglementaires et déontologiques (le « se situer »).$c370$,
  scoring_grid    = $c370$a. Objet de l'entretien technique correctement identifié (approfondissement/vérification des compétences techniques et pédagogiques mobilisées dans la mise en situation professionnelle) : 1 point.
b. Objet de l'entretien final correctement identifié (vision globale du métier, posture professionnelle, respect des enjeux réglementaires et déontologiques) : 1 point.
Total : 2 points (= max_score).$c370$
WHERE source_ref = 'ECSR-M6-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La caractéristique fondamentale qui distingue un service régulier d'un service occasionnel tient au mode d'organisation et d'accès au transport.

Le service régulier assure le transport de voyageurs selon une fréquence et des horaires déterminés à l'avance, sur un itinéraire fixe, avec des points d'arrêt préétablis où les voyageurs peuvent monter et descendre. Il est ouvert à tous (accès au public), le voyageur voyageant individuellement au tarif affiché, quel que soit le nombre de personnes.

Le service occasionnel, à l'inverse, transporte un groupe constitué à l'avance (préconstitué), à la demande du donneur d'ordre. Il n'obéit pas à des horaires ni à un itinéraire imposés de manière permanente et n'est pas ouvert au public : chaque prestation résulte d'un contrat particulier.

En synthèse : le critère déterminant est la régularité et l'ouverture à tous (horaires, itinéraire et arrêts fixes, accès du public) du service régulier, opposée au caractère ponctuel et au groupe fermé du service occasionnel.$c370$,
  scoring_grid    = $c370$Distinction du service régulier (horaires/itinéraire/arrêts fixes, ouvert à tous) : 1 pt. Distinction du service occasionnel (groupe préconstitué, à la demande, non ouvert au public) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M1-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$En Île-de-France, l'autorité organisatrice qui organise l'ensemble des transports collectifs (train, RER, métro, tramway, bus et cars) est Île-de-France Mobilités (IDFM), anciennement dénommé le STIF (Syndicat des transports d'Île-de-France).

À ce titre, Île-de-France Mobilités définit l'offre (lignes, dessertes, fréquences), fixe les tarifs, finance les services et contractualise avec les opérateurs (RATP, SNCF, entreprises privées de bus et de cars).$c370$,
  scoring_grid    = $c370$Réponse « Île-de-France Mobilités » (ou STIF, ancienne dénomination acceptée) : 2 pts. Réponse partielle ou imprécise sur le rôle sans nommer l'autorité : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M1-QC-02' AND type='qr';

-- ⚠️ ERTV-M1-QC-03 : [À CONFIRMER: la « feuille de route » (feuille de route/journey form) est expressément exigée pour les services occasionnels INTERNATIONAUX (règl. CE 1073/2009) ; pour un service occasionnel purement national, le document de contrôle applicable doit être vérifié dans le référentiel officiel de la formation avant diffusion. Le barème accepte toutefois trois documents parmi une liste large et valide
UPDATE public.question_bank SET
  expected_answer = $c370$Lors d'un contrôle d'un car assurant un service occasionnel, le conducteur doit pouvoir présenter notamment les documents suivants (en citer trois) :

1. La feuille de route du service occasionnel, document de contrôle qui décrit le groupe transporté et le déroulement du voyage (exigée notamment pour les services occasionnels internationaux au titre du règlement CE 1073/2009).
2. La copie certifiée conforme de la licence communautaire (ou de la licence de transport intérieur), justifiant que l'entreprise est autorisée à exercer.
3. Les données du chronotachygraphe : carte conducteur (tachygraphe numérique) ou disques/feuilles d'enregistrement (tachygraphe analogique), permettant de vérifier les temps de conduite et de repos.

Autres documents également recevables : le permis de conduire du conducteur de catégorie appropriée (D), la carte de qualification de conducteur (FIMO/FCO), le certificat d'immatriculation du véhicule, l'attestation d'assurance et, le cas échéant, l'autorisation de transport international (pour un service occasionnel international).$c370$,
  scoring_grid    = $c370$Trois documents pertinents et valides cités (feuille de route, licence/copie conforme, données chronotachygraphe, permis D, carte FIMO/FCO, carte grise, attestation d'assurance, autorisation internationale) : 2 pts (environ 0,67 pt par document, arrondi). Deux documents corrects : 1 pt. Un seul ou hors sujet : 0 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M1-QC-03' AND type='qr';

-- ⚠️ ERTV-M1-QC-04 : [À CONFIRMER: la voie par « expérience » (souvent citée à 10 ans de direction continue) relève d'un dispositif transitoire/restrictif issu du règlement CE 1071/2009 et n'est plus largement ouverte aux nouveaux candidats ; la durée exacte et la liste des diplômes admis en équivalence doivent être vérifiées dans les textes en vigueur. Le chiffre de durée est volontairement omis dans le corrigé pour 
UPDATE public.question_bank SET
  expected_answer = $c370$À un candidat exploitant sans diplôme qui souhaite obtenir la capacité professionnelle en transport routier de personnes, on peut répondre qu'il existe trois voies d'accès :

a. Par examen : réussir l'examen écrit national d'attestation de capacité professionnelle en transport routier de personnes (véhicules de plus de 9 places), organisé une fois par an et géré par la DREAL. C'est la voie normale pour un candidat sans diplôme.

b. Par équivalence de diplôme : être titulaire de certains diplômes ou titres à finalité professionnelle (niveau requis en gestion/transport) inscrits sur la liste ouvrant droit à l'attestation par équivalence, ce qui dispense de l'examen.

c. Par expérience professionnelle : justifier avoir dirigé de façon continue une entreprise de transport routier de personnes pendant une durée déterminée (dispositif restrictif, à vérifier au regard des textes en vigueur), ce qui peut permettre la reconnaissance de la capacité.

Dans son cas (sans diplôme et sans expérience de direction), la voie à privilégier est l'inscription et la réussite de l'examen écrit annuel auprès de la DREAL.

Rappel utile : la capacité professionnelle est distincte des trois autres conditions d'accès à la profession (honorabilité, capacité financière de 9 000 € pour le premier véhicule puis 5 000 € par véhicule supplémentaire, établissement stable).$c370$,
  scoring_grid    = $c370$Mention de la voie par examen écrit annuel (DREAL) : 1 pt. Mention d'au moins une autre voie (équivalence de diplôme ou expérience professionnelle) : 0,5 pt. Orientation correcte du candidat sans diplôme vers l'examen : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M1-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Un service librement organisé (SLO) est un service régulier interurbain de transport de voyageurs par autocar, ouvert à tous, que les entreprises de transport peuvent créer et exploiter librement, sans être liées à un contrat de délégation de service public. Ces services (souvent appelés « autocars longue distance » ou « cars Macron ») ont été instaurés par la loi du 6 août 2015 pour la croissance, l'activité et l'égalité des chances économiques (loi « Macron »).

Régime selon la distance de la liaison :
a. Pour toute liaison dont la distance entre les deux arrêts est supérieure à 100 kilomètres, le service est totalement libre : l'entreprise l'ouvre sur simple déclaration, sans possibilité de régulation.
b. Pour les liaisons inférieures ou égales à 100 kilomètres, le service reste soumis à déclaration mais peut faire l'objet d'une régulation par l'Autorité de régulation des transports (ART, anciennement ARAFER), afin de protéger l'équilibre économique des services conventionnés existants.

En résumé : la liaison est totalement libre au-delà de 100 km.$c370$,
  scoring_grid    = $c370$Définition du SLO (service régulier par autocar ouvert à tous, librement organisé, issu de la loi de 2015) : 1 pt. Seuil de liberté totale au-delà de 100 km (et régulation possible en deçà par l'ART/ARAFER) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M1-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le critère de distinction tient au mode de rémunération et au transfert du risque d'exploitation.

a. Délégation de service public (DSP, ex. affermage, concession) : l'autorité organisatrice confie l'exploitation à un opérateur dont la rémunération est substantiellement liée aux résultats de l'exploitation. Le délégataire se rémunère en grande partie sur les recettes perçues auprès des usagers et supporte donc le risque commercial (risque de fréquentation et de recettes). Le contrat est régi par le code de la commande publique au titre des concessions.

b. Marché public : l'autorité paie un prix à l'opérateur en contrepartie du service rendu. L'opérateur n'assume pas le risque d'exploitation lié à la fréquentation, puisqu'il est réglé par la personne publique (les recettes restant à cette dernière). C'est un marché de services régi par les règles des marchés publics.

En synthèse : la ligne de partage est le transfert du risque d'exploitation au cocontractant (DSP) ou son maintien sur l'autorité qui rémunère par un prix (marché public).$c370$,
  scoring_grid    = $c370$1 pt : DSP caractérisée par une rémunération substantiellement liée aux résultats et le transfert du risque d'exploitation au délégataire (recettes usagers). 1 pt : marché public caractérisé par le paiement d'un prix par l'autorité et l'absence de risque d'exploitation supporté par l'opérateur. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M1-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le billet (ou document de contrôle / feuille de route) doit exister avant le départ parce qu'il est l'outil du contrôle sur route.

a. Preuve de la nature occasionnelle du service : lors d'un contrôle en cours de route, les agents doivent pouvoir vérifier immédiatement que le transport correspond bien à un service occasionnel régulièrement organisé. Un document établi a posteriori ne permettrait aucun contrôle en temps réel et n'aurait aucune valeur probante.

b. Groupe préconstitué et absence de ramassage : le service occasionnel transporte un groupe constitué à l'avance. Le document établi avant le départ atteste que la composition du voyage était arrêtée avant le début du service, ce qui interdit de prendre en charge de nouveaux voyageurs en cours de route. Régulariser au retour ouvrirait la porte à un service de ligne déguisé (ramassage successif), qui relèverait en réalité du régime des services réguliers et non de l'occasionnel.

En résumé : établi avant le départ, le document garantit la sincérité du contrôle et la distinction avec un service régulier ; établi au retour, il perdrait toute fonction de contrôle.$c370$,
  scoring_grid    = $c370$1 pt : le document doit permettre le contrôle sur route en temps réel de la nature occasionnelle du service (valeur probante perdue si régularisé après coup). 1 pt : il atteste d'un groupe préconstitué et interdit le ramassage en cours de route, évitant la requalification en service régulier. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M1-QC-07' AND type='qr';

-- ⚠️ ERTV-M1-QC-08 : [À CONFIRMER: la répartition exacte de la compétence transport scolaire (région vs AOM sur son ressort, autorités organisatrices de second rang) selon la rédaction retenue par le référentiel ERTV et l'état du droit à la date de l'examen.] Sur le fond, définition et compétence conformes au droit (loi NOTRe : région AO du transport non urbain et scolaire, hors ressort AOM). Somme du barème = max_sco
UPDATE public.question_bank SET
  expected_answer = $c370$a. Définition : le service régulier spécialisé (SRS) est un service régulier (itinéraire, points d'arrêt et horaires déterminés à l'avance, exploité de façon permanente) mais réservé à certaines catégories de voyageurs, à l'exclusion des autres. Les exemples classiques sont le transport scolaire, le transport de personnel (domicile-travail d'une entreprise) et le transport de personnes déterminées vers un établissement. Il se distingue du service régulier ordinaire, ouvert à tout public.

b. Qui en passe les marchés : c'est l'autorité organisatrice compétente. Pour le transport scolaire, la compétence est en principe exercée par la région (autorité organisatrice depuis la loi NOTRe), sauf sur le ressort territorial d'une autorité organisatrice de la mobilité (AOM) qui l'exerce alors. Ces autorités peuvent déléguer l'organisation à des autorités organisatrices de second rang. Pour le transport de personnel, le marché est passé par l'entreprise ou l'organisme employeur qui organise le service pour ses salariés.$c370$,
  scoring_grid    = $c370$1 pt : définition du SRS = service régulier réservé à des catégories déterminées de personnes (ex. scolaires, personnel), à l'exclusion des autres voyageurs. 1 pt : marchés passés par l'autorité organisatrice compétente (région pour le transport scolaire depuis la loi NOTRe, ou AOM sur son ressort ; entreprise pour le transport de personnel). Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M1-QC-08' AND type='qr';

-- ⚠️ ERTV-M1-QC-09 : [À CONFIRMER: le montant exact de la capacité financière exigée pour les véhicules légers voyageurs de 9 places au plus (base de comparaison) n'est pas fourni dans les ancrages ; à titre indicatif le régime léger est de l'ordre de 1 500 € pour le 1er véhicule + 900 € par véhicule supplémentaire, mais NE PAS citer ce chiffre dans le corrigé sans vérification du barème en vigueur à la date de l'exam
UPDATE public.question_bank SET
  expected_answer = $c370$En passant de véhicules n'excédant pas 9 places (régime dit léger) à des autocars de plus de 9 places (régime lourd), l'entreprise bascule dans le barème de capacité financière le plus élevé, soit 9 000 € pour le premier véhicule puis 5 000 € par véhicule supplémentaire, ce qui augmente fortement le montant de capitaux propres et réserves à justifier par rapport à l'exigence applicable aux seuls véhicules légers.$c370$,
  scoring_grid    = $c370$1 pt : identification du changement de régime (passage du léger, véhicules jusqu'à 9 places, au lourd, plus de 9 places). 1 pt : montant du régime lourd correctement cité (9 000 € pour le 1er véhicule + 5 000 € par véhicule supplémentaire) et sens de l'effet (forte hausse de l'exigence). Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M1-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Outre les pénalités de ponctualité, un cahier des charges de convention urbaine voyageurs comporte classiquement des exigences de qualité telles que :

a. Le service fait / la régularité de l'offre : réalisation effective des courses prévues (taux de kilomètres réalisés, respect des fréquences et de l'amplitude horaire), avec pénalités en cas de courses non assurées.

b. La qualité et l'état du matériel : propreté intérieure et extérieure des véhicules, âge moyen ou ancienneté maximale du parc, bon fonctionnement des équipements embarqués (validateurs, girouettes, information sonore et visuelle), accessibilité PMR.

c. L'information et la relation voyageurs : information à l'arrêt et à bord, information en temps réel, disponibilité de l'information en cas de perturbation, qualité de l'accueil et traitement des réclamations.

Autres exigences également recevables : sécurité et sûreté, continuité du service, mesures de satisfaction clientèle. Trois exigences pertinentes et distinctes suffisent.$c370$,
  scoring_grid    = $c370$2 pts si trois exigences de qualité pertinentes et distinctes sont citées (parmi : régularité/service fait, propreté et état du parc, accessibilité PMR, bon fonctionnement des équipements, information voyageurs, accueil/réclamations, sécurité-sûreté, satisfaction clientèle). Barème indicatif : environ 0,67 pt par exigence valable ; 1 pt seulement si deux exigences correctes, 0 pt si une seule ou hors sujet. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M1-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les deux curseurs qui définissent quand et à quel rythme une ligne fonctionne dans la journée sont :

a. L'amplitude horaire (le « quand ») : c'est la plage de fonctionnement de la ligne, de l'heure de la première course (premier départ) à l'heure de la dernière course (dernière arrivée). Elle fixe les bornes du service dans la journée (ex. de 5 h 30 à 0 h 30).

b. La fréquence, ou intervalle de passage (le « à quel rythme ») : c'est le temps qui sépare deux passages successifs à un même point d'arrêt (ex. un bus toutes les 20 minutes). On l'exprime soit en fréquence (nombre de passages par heure), soit en intervalle (minutes entre deux passages). Elle peut varier dans la journée : resserrée aux heures de pointe, élargie aux heures creuses.

En résumé : l'amplitude dit sur quelle plage la ligne roule, la fréquence dit à quelle cadence elle roule à l'intérieur de cette plage.$c370$,
  scoring_grid    = $c370$a. Amplitude horaire (plage de fonctionnement / première à dernière course) : 1 pt. b. Fréquence ou intervalle de passage (cadence entre deux passages) : 1 pt. Total = 2 pts. Accepter les synonymes (amplitude de service ; fréquence/intervalle/cadence). Pénaliser si un seul des deux curseurs est cité (1 pt).$c370$
WHERE source_ref = 'ERTV-M2-QC-01' AND type='qr';

-- ⚠️ ERTV-M2-QC-02 : [À CONFIRMER: le vocabulaire exact retenu par le référentiel ERTV pour « l'ensemble ordonné des courses d'un même véhicule » — plusieurs termes coexistent dans la profession (roulement véhicule, service voiture, tour de voiture, bloc véhicule). Vérifier le terme canonique attendu dans le support du Module 2 avant de figer le corrigé.]
UPDATE public.question_bank SET
  expected_answer = $c370$L'ensemble ordonné des courses (trajets) confiées à un même véhicule sur la journée s'appelle un roulement véhicule, aussi désigné selon les entreprises « service voiture », « tour de voiture » ou « bloc véhicule ». C'est le résultat de l'habillage : on enchaîne les courses successives d'un même autocar/autobus, avec ses battements aux terminus, depuis la sortie du dépôt jusqu'à la rentrée. Ce roulement définit l'emploi de la journée du véhicule et sert ensuite de support à l'affectation des conducteurs.

À ne pas confondre : le graphicage (construction des horaires/courses), l'habillage (regroupement des courses en services véhicule et en services agents) et le battement (temps de récupération au terminus).$c370$,
  scoring_grid    = $c370$Terme attendu identifiant la séquence journalière des courses d'un même véhicule : 2 pts. Accepter « roulement (véhicule) », « service voiture », « tour de voiture », « bloc véhicule ». Donner 1 pt seulement si la réponse reste vague (« un service ») sans préciser qu'il s'agit du véhicule, ou si confusion partielle avec l'habillage. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M2-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le document qui détaille au conducteur sa prise de service, ses courses, ses coupures (ou battements) et sa fin de service est la feuille de service (également appelée feuille de route ou fiche de service selon les entreprises).

Elle récapitule pour la journée : l'heure et le lieu de prise de service, la succession chronologique des courses à assurer (numéro de course, ligne, horaires de départ et d'arrivée, terminus), les temps de coupure ou de battement, ainsi que l'heure et le lieu de fin de service. C'est le document d'exploitation qui traduit, au niveau du conducteur, le service issu de l'habillage et du roulement.$c370$,
  scoring_grid    = $c370$Terme attendu : « feuille de service » (accepter « feuille de route » / « fiche de service ») : 2 pts. Donner 1 pt si la réponse décrit correctement la fonction du document mais sans le nommer précisément. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M2-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les temps de parcours doivent être relevés sur le terrain, aux heures de pointe, parce qu'une carte ne donne qu'une distance, pas un temps réellement réalisable. Le temps de parcours commercial dépend de conditions que la carte ignore :

a. Les conditions de circulation : congestion, feux tricolores, ralentissements, priorités, travaux. Ces facteurs sont maximaux aux heures de pointe et allongent fortement le temps réel.

b. L'exploitation voyageurs elle-même : temps d'arrêt aux points de montée/descente, échanges de voyageurs plus longs en heure de pointe, vente/validation à bord, accès PMR (déploiement de rampe, calage UFR).

c. La nécessité de dimensionner sur le cas le plus contraignant : c'est aux heures de pointe que les temps sont les plus longs. Bâtir l'horaire sur ces valeurs garantit la tenue de l'horaire, la régularité, le respect des correspondances et des battements suffisants aux terminus.

Conséquence : un temps estimé sur carte (donc trop optimiste) produirait des horaires intenables, générant retards accumulés, correspondances manquées, battements absorbés et, in fine, un sous-dimensionnement du nombre de véhicules et de conducteurs. Le relevé terrain aux heures de pointe fournit une base réaliste et robuste pour le graphicage.$c370$,
  scoring_grid    = $c370$Idée que la carte donne une distance mais pas le temps réel / que le temps dépend des conditions réelles (circulation, feux, arrêts voyageurs) : 1 pt. Idée que l'heure de pointe est le cas dimensionnant garantissant la tenue de l'horaire et la régularité (sinon retards, correspondances manquées, sous-dimensionnement) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M2-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Calcul du parc nécessaire :

Nombre de voitures = temps de cycle / fréquence (intervalle)
N = 80 min / 20 min = 4 voitures.

Raisonnement : le temps de cycle (80 min) est la durée totale pour qu'une même voiture revienne à son point de départ, aller + retour + battements aux terminus compris. Pour offrir un passage toutes les 20 minutes, il faut qu'une voiture se présente au départ tous les 20 minutes. Comme un tour complet dure 80 minutes, il faut donc 80 / 20 = 4 voitures qui se relaient, décalées chacune de 20 minutes, pour couvrir l'intégralité du cycle sans trou.

Vérification : 4 voitures espacées de 20 min couvrent 4 × 20 = 80 min, soit exactement le temps de cycle. La fréquence de 20 minutes est donc tenue.

Réponse : 4 voitures.$c370$,
  scoring_grid    = $c370$Résultat correct (4 voitures) : 1 pt. Méthode / formule justifiée : nombre de voitures = temps de cycle ÷ intervalle = 80 ÷ 20 : 1 pt. Total = 2 pts. Le résultat seul sans le calcul vaut 1 pt.$c370$
WHERE source_ref = 'ERTV-M2-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Rôle du battement au terminus
Le battement (ou temps de battement / temps de retournement) est la marge de temps prévue au terminus entre l'arrivée d'une course et le départ de la course suivante. Il remplit trois fonctions : absorber les retards accumulés en ligne (congestion, affluence, aléas) pour repartir à l'heure et régénérer l'horaire ; permettre au conducteur une courte coupure physiologique (descendre, se restaurer, aller aux toilettes) ; laisser le temps des opérations techniques et commerciales (changement de girouette/destination, vérification du véhicule, montée des voyageurs, relève éventuelle de conducteur).

b. Conséquences concrètes d'un battement trop court
Si le battement est insuffisant, le moindre retard pris en ligne n'est plus résorbé : il se reporte sur la course suivante et se propage tout au long de la journée (effet « boule de neige » sur le roulement). Le véhicule repart en retard, les correspondances et la régularité de la ligne se dégradent, l'exploitant peut être contraint de sauter des courses ou d'injecter un véhicule de réserve. Pour le conducteur, la pause disparaît de fait, ce qui accroît la fatigue et le stress, dégrade la conduite et la sécurité, et fragilise le respect des temps de pause et de la durée de service prévus par la réglementation.$c370$,
  scoring_grid    = $c370$a. Rôle du battement (résorption des retards + régénération de l'horaire, pause conducteur, opérations techniques/commerciales) : 1 pt. b. Conséquences d'un battement trop court (retard non résorbé qui se propage, dégradation de la régularité / perte de la pause et fatigue accrue) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M2-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Lors de l'habillage (affectation des services aux conducteurs), trois critères d'équité à respecter entre conducteurs sont :

1. L'équité de la charge de travail : répartir de façon comparable la durée de conduite et l'amplitude des services, afin qu'aucun conducteur ne cumule systématiquement les vacations les plus longues ou les plus pénibles.

2. L'équité des horaires pénibles et des repos : faire tourner équitablement les services défavorables (tôt le matin, tard le soir, coupés avec forte amplitude, week-ends et jours fériés) et garantir à chacun des temps de repos et des jours de repos comparables.

3. L'équité de rémunération et d'avantages : répartir de manière équilibrée les éléments variables (heures supplémentaires, primes, indemnités de coupure ou de découcher) pour que les services les mieux ou les moins rémunérés soient partagés dans le temps.

(Autres réponses recevables : rotation régulière des services par un roulement, équilibre des temps de coupure/battement, répartition équitable des lignes réputées difficiles.)$c370$,
  scoring_grid    = $c370$Trois critères d'équité attendus. Barème : environ 0,67 pt par critère pertinent et correctement justifié (≈ 0,7 + 0,7 + 0,6), arrondi à 2 pts pour trois critères valables. Deux critères seulement : 1 pt ; un seul : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M2-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Pour mutualiser (rentabiliser) un même autocar sur une journée, plusieurs usages peuvent se succéder. Trois usages types :

1. Le matin et en fin d'après-midi : service de transport scolaire (ramassage domicile-établissement puis retour), qui occupe les pointes du matin et du soir.

2. En milieu de journée (heures creuses) : service régulier interurbain de ligne ou service de transport à la demande (TAD), qui utilise le véhicule entre les deux pointes scolaires.

3. En soirée, le week-end ou pendant les vacances scolaires : service occasionnel / tourisme (sorties, excursions, transferts, voyages de groupe, location), qui absorbe les périodes où le scolaire et la ligne régulière sont inactifs.

La logique est de faire enchaîner sur le même véhicule des services dont les pointes de demande ne se chevauchent pas, afin d'augmenter le taux d'utilisation de l'autocar et d'amortir ses coûts fixes.$c370$,
  scoring_grid    = $c370$Trois usages compatibles et non simultanés attendus (ex. scolaire en pointe, ligne régulière ou TAD en heures creuses, occasionnel/tourisme en soirée ou week-end). Barème : environ 0,67 pt par usage pertinent (≈ 0,7 + 0,7 + 0,6) ; deux usages : 1 pt ; un seul : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M2-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Sur un service urbain lent, la vitesse commerciale est faible (arrêts fréquents, montées/descentes, congestion, feux) : le véhicule parcourt peu de kilomètres mais mobilise beaucoup de temps de conducteur et de véhicule. Or les principaux coûts d'exploitation d'un tel service sont des coûts liés au temps : salaire et charges du conducteur, immobilisation du véhicule, amortissement et frais fixes, qui courent proportionnellement à la durée de mise à disposition, non à la distance.

Le coût kilométrique rapporte la dépense aux kilomètres : sur un service lent, il devient très élevé et instable car le dénominateur (les km) est faible, ce qui donne une image trompeuse et difficile à comparer d'une ligne à l'autre. Le coût horaire rapporte la dépense au temps réellement consommé, qui est le facteur dimensionnant du service urbain ; il reflète mieux la ressource mobilisée (heures de conduite et heures véhicule), facilite la comparaison entre services et le calcul du prix d'un service au temps passé. C'est pourquoi, pour analyser un service urbain lent, le coût horaire est plus pertinent que le coût kilométrique.$c370$,
  scoring_grid    = $c370$Idée que le service urbain lent consomme surtout du temps et que les coûts dominants (conducteur, véhicule, coûts fixes) sont proportionnels au temps : 1 pt. Idée que le coût kilométrique est trompeur/instable avec peu de km alors que le coût horaire reflète la ressource réellement mobilisée et permet la comparaison : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M2-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Un bon habillage (construction des services de conducteurs à partir du graphicage et des roulements) agit simultanément sur deux leviers :

Sur les coûts : en enchaînant efficacement les tâches de conduite, il réduit les temps improductifs (temps morts, coupures inutiles, trajets haut-le-pied, attentes) et diminue l'amplitude payée sans conduite. Il permet de couvrir le service avec moins de conducteurs et moins d'heures rémunérées, donc de maîtriser la masse salariale, qui est le premier poste de coût d'un service de transport de voyageurs.

Sur la fatigue des conducteurs : en répartissant équitablement la charge, en respectant et en positionnant correctement les temps de pause, en limitant l'amplitude et les coupures excessives, et en garantissant des repos suffisants (dans le cadre du règlement CE 561/2006 et de la réglementation du travail), il préserve la vigilance et réduit la pénibilité.

Les deux effets sont liés : un habillage qui réduit les heures improductives sans dégrader les pauses et l'amplitude sert à la fois l'économie de l'exploitation et de bonnes conditions de travail, donc la sécurité. À l'inverse, chercher l'économie en supprimant pauses et battements ferait baisser un coût apparent mais augmenterait la fatigue, les risques et l'absentéisme.$c370$,
  scoring_grid    = $c370$Effet sur les coûts (réduction des temps improductifs / amplitude payée, moins d'heures et de conducteurs, maîtrise de la masse salariale) : 1 pt. Effet sur la fatigue (répartition équitable, respect des pauses et repos, limitation de l'amplitude, dans le cadre réglementaire) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M2-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Signification du sigle : SAEIV désigne le Système d'Aide à l'Exploitation et à l'Information des Voyageurs. C'est l'outil embarqué et centralisé (PC d'exploitation) qui repose sur la géolocalisation en temps réel des véhicules et sur une liaison de données/phonie entre le poste de commandement et les conducteurs.

b. Ses deux fonctions pour l'exploitation :
1) L'aide à l'exploitation (le volet AE) : suivi en temps réel de la position et de l'avance/du retard de chaque véhicule par rapport à l'horaire théorique, détection des écarts, aide à la régulation (rétablissement des intervalles, gestion des correspondances, communication conducteur-régulateur, alarme et appel d'urgence).
2) L'information des voyageurs (le volet IV) : diffusion d'une information fondée sur le temps réel, à bord (annonces sonores et visuelles du prochain arrêt) et aux points d'arrêt (temps d'attente réel), voire sur les canaux distants (application, site, bornes).

En résumé, le SAEIV sert d'un côté à piloter et réguler le réseau, de l'autre à informer le voyageur en temps réel.$c370$,
  scoring_grid    = $c370$a. Signification exacte du sigle (Système d'Aide à l'Exploitation et à l'Information des Voyageurs) : 1 point (0,5 si sigle approximatif mais sens correct). b. Les deux fonctions correctement identifiées et distinguées (aide à l'exploitation/régulation temps réel + information voyageurs) : 1 point, soit 0,5 par fonction. Total = 2.$c370$
WHERE source_ref = 'ERTV-M3-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Face à une panne immobilisant le véhicule en ligne avec des voyageurs à bord, les deux actions clés du régulateur envers ces voyageurs sont :

a. Mettre en sécurité et informer les voyageurs : s'assurer d'abord de leur sécurité (immobilisation correcte du véhicule, signalisation, maintien à bord ou évacuation vers un lieu sûr selon le danger), puis les tenir informés sans délai de la cause de l'arrêt et de la solution mise en place, afin d'éviter la panique et les initiatives dangereuses (descente sur la chaussée).

b. Organiser leur acheminement (transbordement) : déclencher une solution de continuité de transport, c'est-à-dire l'envoi d'un véhicule de remplacement ou le report des voyageurs sur une autre course, afin qu'ils poursuivent leur trajet et rejoignent leur destination ou leur correspondance.

Autrement dit : d'abord la sécurité et l'information des personnes, ensuite la prise en charge et le réacheminement.$c370$,
  scoring_grid    = $c370$a. Sécurité + information des voyageurs à bord (les rassurer, informer de la cause et de l'attente, veiller à leur sécurité) : 1 point. b. Organisation de l'acheminement/transbordement vers un véhicule de remplacement ou une autre course : 1 point. Total = 2. Accepter toute formulation équivalente ; une seule des deux actions = 1 point.$c370$
WHERE source_ref = 'ERTV-M3-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Quand la durée de la perturbation est inconnue, le principe est de ne jamais annoncer un délai que l'on ne peut pas tenir. Le message d'information doit contenir :

a. Les faits avérés : la nature de la perturbation (incident, panne, route coupée, etc.), la ou les lignes et le secteur concernés, et l'heure de constat, sans spéculer sur la cause si elle n'est pas confirmée.

b. La reconnaissance que la durée n'est pas encore connue, assortie d'un engagement de réactualisation : plutôt qu'un horaire de reprise incertain, on annonce l'heure de la prochaine information (le prochain point). Cela donne un repère fiable au voyageur.

c. Les conseils pratiques et solutions alternatives disponibles (itinéraire ou ligne de report, arrêt de substitution), et une formule de considération envers les voyageurs.

L'essentiel : dire ce que l'on sait, dire honnêtement que la durée n'est pas connue, et fixer un rendez-vous d'information plutôt qu'une fausse heure de reprise.$c370$,
  scoring_grid    = $c370$a. Les éléments factuels : nature/cause avérée, lignes et secteur concernés : 1 point. b. Le fait d'assumer que la durée est inconnue ET d'annoncer l'heure de la prochaine mise à jour (rendez-vous d'information) plutôt qu'un faux délai : 1 point. Les conseils/alternatives sont un bonus non décompté. Total = 2.$c370$
WHERE source_ref = 'ERTV-M3-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Un départ raté sur la première course du matin ne se rattrape presque jamais pour plusieurs raisons cumulatives propres au début de service :

a. Il n'y a pas de marge de récupération en tout début de journée : les temps de battement aux terminus et les marges de régulation intégrés au graphicage sont calculés pour absorber de petits aléas, pas un retard pris dès le départ du dépôt. Le retard initial se reporte donc intégralement sur toutes les courses suivantes du roulement, sans jamais être résorbé (effet de cascade).

b. La première course conditionne tout l'aval : elle assure souvent les premières correspondances (train, scolaires, autres lignes) et le premier chargement de voyageurs, qui n'attendent pas. Un départ manqué signifie des voyageurs laissés à quai et des correspondances perdues, dommages qui ne se "rattrapent" pas puisqu'ils sont déjà consommés.

c. Les moyens de secours sont réduits à cette heure : peu ou pas de véhicule de réserve ni de conducteur disponible pour insérer une course supplémentaire ou doubler, si bien que le régulateur ne dispose d'aucun levier immédiat pour combler le trou.

En synthèse : pas de marge horaire au démarrage, un retard qui se propage en cascade sur tout le roulement, et un préjudice immédiat (voyageurs et correspondances manqués) que le temps ne répare pas.$c370$,
  scoring_grid    = $c370$a. Absence de marge/battement en début de service et propagation en cascade du retard sur toutes les courses suivantes : 1 point. b. Préjudice immédiat et non récupérable (voyageurs à quai, correspondances manquées) et/ou absence de moyens de secours disponibles à cette heure : 1 point. Total = 2. Une seule raison solidement argumentée = 1 point.$c370$
WHERE source_ref = 'ERTV-M3-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Au-delà du suivi du jour même, la main courante d'exploitation (journal horodaté des événements et décisions de la régulation) sert notamment à :

a. L'analyse a posteriori et l'amélioration continue : en la relisant sur la durée, on identifie les incidents récurrents, les points noirs du réseau (arrêts, tronçons, horaires régulièrement en retard) et l'efficacité des mesures de régulation prises. Elle alimente le retour d'expérience et l'ajustement du graphicage/roulement.

b. La traçabilité et la justification (valeur de preuve) : elle constitue une trace horodatée opposable en cas de réclamation d'un voyageur, de litige, de contrôle de l'autorité organisatrice (AOM) ou d'enquête après incident/accident. Elle documente ce qui s'est passé, quand, et quelles décisions ont été prises.

Usages complémentaires acceptés : alimentation des indicateurs de qualité de service et du reporting contractuel envers l'AOM ; transmission/continuité d'information entre équipes de régulation successives.$c370$,
  scoring_grid    = $c370$Deux usages attendus, 1 point chacun (Total = 2). Sont acceptés, entre autres : (1) analyse a posteriori / retour d'expérience / détection des incidents récurrents et points noirs / amélioration du graphicage ; (2) traçabilité et valeur de preuve en cas de litige, réclamation, contrôle AOM ou enquête ; (3) production d'indicateurs de qualité de service et reporting contractuel. Créditer les deux premiers usages pertinents cités.$c370$
WHERE source_ref = 'ERTV-M3-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Ordre de priorité de traitement au poste de régulation face à trois aléas simultanés :

1. La sécurité des personnes d'abord. Tout aléa mettant en jeu l'intégrité physique des voyageurs, du conducteur ou des tiers (accident, malaise, incident véhicule susceptible d'être dangereux, agression) est traité en priorité absolue et sans délai. Rien ne passe avant la sécurité.

2. La continuité et le rétablissement du service ensuite. Une fois la sécurité assurée, on traite ce qui menace la production de l'offre : rupture de service (conducteur ou véhicule manquant), immobilisation d'une course, sauvegarde des correspondances structurantes. L'objectif est de limiter la propagation de la perturbation sur le reste du réseau.

3. L'information voyageurs et le confort en dernier. Ce qui relève de la qualité de service et du confort (retard mineur, information de perturbation, réclamation) est traité après, une fois le service sécurisé et rétabli. L'information reste néanmoins à déclencher rapidement en parallèle dès que la situation est stabilisée.

Règle mémo : Sécurité > Continuité du service > Information / Confort.$c370$,
  scoring_grid    = $c370$1 pt : sécurité des personnes citée en priorité n°1 ; 0,5 pt : continuité / rétablissement du service en priorité n°2 ; 0,5 pt : information voyageurs / confort en priorité n°3. Total = 2 pts. (Ordre correct exigé ; inverser sécurité et service = 0 sur les deux premiers points.)$c370$
WHERE source_ref = 'ERTV-M3-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Trois leviers licites de recomposition en cas de manque à la prise de service :

1. Mobiliser un conducteur de réserve (volant / conducteur de réserve prévu au roulement) : c'est la solution de premier recours, sans impact sur le reste du plan.

2. Rappeler un conducteur en repos ou lui proposer des heures supplémentaires, avec son accord et dans le strict respect des durées de travail, de conduite et de repos.

3. Réaffecter les moyens par ajustement du roulement / graphicage : glisser un conducteur depuis une course moins prioritaire, décaler un service, ou recourir à la sous-traitance / à l'affrètement d'un autre exploitant si le contrat le permet.

Limite à ne jamais franchir : ne jamais faire assurer le service au prix d'un dépassement des règles de conduite et de repos (Règlement CE 561/2006) ni des qualifications requises. On n'entame pas le repos quotidien ou hebdomadaire minimal, on ne dépasse pas les durées maximales de conduite, et on ne fait jamais conduire une personne inapte ou non habilitée. La sécurité prime toujours sur la continuité du service : mieux vaut supprimer une course que de la faire assurer illégalement.$c370$,
  scoring_grid    = $c370$1,5 pt : trois leviers licites cités (0,5 pt chacun : réserve/volant ; rappel avec accord dans le respect des temps ; réaffectation roulement/graphicage ou sous-traitance) ; 0,5 pt : limite = interdiction de dépasser les temps de conduite/repos (561/2006) ou de faire conduire un conducteur inapte/non habilité. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M3-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Indicateur calculé : le taux de réalisation de l'offre (aussi appelé taux de service produit ou taux de couverture des courses). Il mesure la part des courses réellement effectuées par rapport aux courses programmées.

Calcul : taux de réalisation = courses réalisées / courses prévues = 171 / 180 = 0,95, soit 95 %.

Lecture complémentaire : 9 courses n'ont pas été assurées (180 - 171), soit un taux de déprogrammation / suppression de 9 / 180 = 5 %. Un taux de réalisation de 95 % traduit une production correcte mais perfectible ; l'analyse des 9 courses supprimées (causes : manque de conducteur, véhicule, aléa de circulation) permet d'orienter les actions correctives.$c370$,
  scoring_grid    = $c370$1 pt : identification de l'indicateur (taux de réalisation / de service produit / de couverture de l'offre) ; 1 pt : valeur exacte 171/180 = 95 % avec le calcul posé. Total = 2 pts. (0,5 pt seulement si la valeur 95 % est donnée sans nommer correctement l'indicateur.)$c370$
WHERE source_ref = 'ERTV-M3-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Cause racine probable : le retard frappe la même course chaque matin indépendamment du conducteur, donc la cause n'est pas humaine mais structurelle. C'est le graphicage (l'horaire théorique) qui est mal calibré : le temps de parcours prévu pour cette course est sous-estimé au regard des conditions réelles de la tranche horaire du matin (trafic dense, affluence voyageurs aux arrêts, temps d'échange plus longs), et/ou le battement (temps de battement / marge de régulation) au terminus précédent est insuffisant pour absorber le décalage.

Correction appropriée : agir sur le graphicage, pas sur le conducteur. Recaler l'horaire théorique en allongeant le temps de parcours de cette course pour le rendre conforme au temps réellement constaté, et/ou augmenter le battement au terminus pour repartir à l'heure. On s'appuie sur les temps de parcours mesurés (données réelles) pour redimensionner la course, éventuellement en différenciant l'horaire de la pointe du matin de celui du reste de la journée. Sanctionner ou changer le conducteur serait inefficace puisque le problème persiste quel que soit lui.$c370$,
  scoring_grid    = $c370$1 pt : cause racine = graphicage / temps de parcours théorique sous-estimé (ou battement insuffisant), problème structurel et non conducteur ; 1 pt : correction = recaler l'horaire / allonger le temps de parcours (ou ajouter du battement) sur la base des temps réels. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M3-QC-09' AND type='qr';

-- ⚠️ ERTV-M3-QC-10 : [À CONFIRMER: la nature exacte de l'obligation (information simple préalable vs. validation formelle de l'AO avant diffusion) dépend des clauses du contrat de délégation propre au réseau; le corrigé retient le principe général de respect du circuit contractuel sans citer de disposition chiffrée.]
UPDATE public.question_bank SET
  expected_answer = $c370$Avant de publier un message de perturbation majeure sur l'appli et les réseaux sociaux du réseau, il faut vérifier ses obligations vis-à-vis de l'autorité organisatrice (AO), qui est propriétaire du réseau et du service délégué :

1. Les clauses du contrat / de la convention de délégation relatives à l'information voyageurs et à la communication de crise : qui est habilité à communiquer, selon quelles modalités et quels délais, et si l'AO doit valider ou être informée préalablement à toute diffusion externe en situation de perturbation majeure.

2. L'information effective de l'AO : s'assurer que l'AO est prévenue avant ou au plus tard simultanément à la diffusion publique, afin qu'elle ne découvre pas la perturbation par les réseaux sociaux et puisse tenir son propre discours institutionnel.

3. La cohérence et la validation du message : contenu conforme à la réalité de l'exploitation, cohérent avec la charte de communication et l'image de marque du réseau (qui appartient à l'AO), et, le cas échéant, validé par le circuit prévu (direction / AO) avant publication sur les canaux officiels.

En résumé : respecter le circuit de validation contractuel, informer l'AO en amont et garantir la cohérence du message avec la communication de l'AO.$c370$,
  scoring_grid    = $c370$1 pt : vérifier les obligations contractuelles / conventionnelles vis-à-vis de l'AO (qui communique, validation, délais prévus au contrat de délégation) ; 0,5 pt : informer l'AO en amont ou simultanément à la diffusion publique ; 0,5 pt : cohérence du message avec la charte / marque du réseau appartenant à l'AO et circuit de validation. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M3-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La FIMO voyageurs (140 h) n'est pas la seule voie d'accès à la qualification initiale de conducteur. Le candidat peut détenir cette qualification initiale par l'obtention d'un diplôme ou d'un titre professionnel de conduite routière de transport de voyageurs, inscrit au RNCP et reconnu comme valant qualification initiale (équivalence FIMO).

Concrètement :
a. Voie du diplôme/titre : préparer et obtenir un diplôme d'État ou un titre professionnel de conducteur de transport en commun de voyageurs (par exemple le CAP Conducteur routier « voyageurs » ou le Titre professionnel « Conducteur du transport routier interurbain de voyageurs »). La réussite à ce diplôme délivre la qualification initiale et permet la délivrance de la carte de qualification de conducteur (CQC), sans passer par le stage FIMO de 140 h.
b. Conséquence pratique : le conducteur reste ensuite soumis, comme tout titulaire de la FIMO, à la formation continue obligatoire (FCO) à renouveler périodiquement pour maintenir la validité de sa qualification.

En résumé, l'alternative à la FIMO est la qualification initiale par diplôme/titre professionnel voyageurs inscrit au RNCP, qui vaut équivalence et ouvre droit à la carte de qualification.$c370$,
  scoring_grid    = $c370$a. Identifier la voie du diplôme / titre professionnel de conducteur voyageurs (RNCP) valant équivalence FIMO : 1 pt. b. Préciser qu'il délivre la qualification initiale / donne accès à la carte de qualification (CQC), avec exemple pertinent (CAP ou Titre pro voyageurs) : 1 pt. Total = 2.$c370$
WHERE source_ref = 'ERTV-M4-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Non. Une ligne régulière urbaine dont le parcours est de 12 km n'entre pas dans le champ d'application du règlement (CE) n° 561/2006.

Raisonnement :
a. Le règlement 561/2006 prévoit une exclusion expresse pour les services réguliers de voyageurs dont le parcours de la ligne n'excède pas 50 km. Avec 12 km, la ligne est très en deçà de ce seuil : elle est donc exemptée des règles européennes de temps de conduite et de repos, et l'usage du chronotachygraphe communautaire n'est pas imposé à ce titre.
b. Cela ne signifie pas une absence totale de règles : ces conducteurs restent soumis aux règles sociales nationales (durée du travail, amplitude, coupures, repos prévus par le Code des transports et le droit du travail) ainsi qu'aux dispositions conventionnelles applicables au transport urbain.

Conclusion : ligne régulière ≤ 50 km = hors 561/2006, mais encadrement par la réglementation nationale du temps de travail.$c370$,
  scoring_grid    = $c370$a. Réponse « Non » justifiée par l'exclusion des services réguliers dont le parcours n'excède pas 50 km (12 km < 50 km) : 1 pt. b. Préciser que les conducteurs relèvent alors des règles sociales nationales (durée du travail / Code des transports) : 1 pt. Total = 2.$c370$
WHERE source_ref = 'ERTV-M4-QC-02' AND type='qr';

-- ⚠️ ERTV-M4-QC-03 : [À CONFIRMER: plafond d'amplitude de « l'ordre de 12 h » et ses conditions d'extension dans le transport routier de voyageurs. La définition de l'amplitude (partie notée) est certaine ; seule la valeur chiffrée du plafond, donnée à titre indicatif, doit être vérifiée dans le décret temps de travail applicable et la convention collective avant diffusion.]
UPDATE public.question_bank SET
  expected_answer = $c370$L'amplitude d'une journée de travail est l'intervalle de temps qui s'écoule entre la prise de service (début de la journée de travail) et la fin de service (dernière fin de travail de la journée).

Ce qu'elle recouvre :
a. Elle englobe la totalité des périodes de la journée : les temps de conduite, les autres travaux (accueil, billettique, manœuvres, contrôles, prises et fins de service), ainsi que les temps de coupure, de battement, d'attente et de disponibilité intercalés. L'amplitude est donc mesurée « bout à bout », coupures comprises.
b. Elle se distingue du temps de travail effectif : l'amplitude peut être nettement supérieure au temps de travail réellement décompté, précisément parce qu'elle inclut aussi les interruptions non travaillées de la journée. Seul le repos journalier (qui met fin à la journée) n'est pas compté dans l'amplitude.

Ordre de grandeur réglementaire : dans le transport routier de voyageurs, l'amplitude de la journée est plafonnée (de l'ordre de 12 h, avec des possibilités d'extension encadrées).$c370$,
  scoring_grid    = $c370$a. Définir l'amplitude comme l'intervalle entre la prise de service et la fin de service, coupures/attentes incluses : 1 pt. b. Préciser qu'elle englobe toutes les périodes (conduite, travaux, coupures, disponibilité) et se distingue du temps de travail effectif : 1 pt. Total = 2. (La mention du plafond chiffré est un bonus non exigé.)$c370$
WHERE source_ref = 'ERTV-M4-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$L'argument réglementaire propre au transport en commun est le seuil d'alcoolémie abaissé imposé par le Code de la route aux conducteurs de véhicules de transport en commun de personnes.

Développement :
a. Alors que le seuil de droit commun est fixé à 0,5 g/L de sang (0,25 mg/L d'air expiré), le conducteur d'un véhicule de transport en commun est soumis à un seuil abaissé de 0,2 g/L de sang (0,10 mg/L d'air expiré). Ce seuil très bas traduit une exigence de sécurité renforcée liée au grand nombre de personnes transportées.
b. Justification de la note de service : ce seuil de 0,2 g/L est si proche de zéro qu'il ne laisse aucune marge (un résidu de la veille, un médicament ou un aliment alcoolisé peut suffire à le dépasser). Imposer une règle interne « zéro alcool » est donc le seul moyen fiable de garantir le respect du seuil légal spécifique aux conducteurs de transport en commun et de protéger l'entreprise comme les voyageurs.

Conclusion : la règle interne s'appuie directement sur l'obligation légale d'un seuil abaissé (0,2 g/L) propre au transport en commun.$c370$,
  scoring_grid    = $c370$a. Citer le seuil d'alcoolémie abaissé propre au transport en commun (0,2 g/L de sang, contre 0,5 g/L en droit commun) : 1 pt. b. Relier ce seuil quasi nul à la justification d'une règle interne « zéro alcool » (aucune marge, sécurité renforcée des voyageurs) : 1 pt. Total = 2.$c370$
WHERE source_ref = 'ERTV-M4-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Au-delà de sa disponibilité et de son volontariat, deux vérifications conditionnent l'affectation légale du conducteur :

a. Sa situation au regard des temps de conduite et de repos (règlement 561/2006) : il faut s'assurer qu'il a bien pris son repos journalier (et hebdomadaire le cas échéant) et qu'il n'a pas déjà épuisé ses limites de conduite. Un conducteur volontaire mais qui n'a pas accompli son repos réglementaire ne peut pas être affecté : l'affectation serait illégale, l'accord du conducteur ne dispensant jamais du respect des temps de repos.

b. La validité de ses titres et de son aptitude : il faut contrôler que le conducteur détient un permis D en cours de validité, une carte de qualification de conducteur à jour (FIMO/FCO valide, la FCO étant à renouveler périodiquement) et une visite médicale d'aptitude en cours de validité. À défaut de l'un de ces documents, il ne peut légalement prendre le service.

Ces deux points (respect des temps de conduite/repos et validité des documents permis + qualification + aptitude médicale) sont les conditions cumulatives de la légalité de l'affectation.$c370$,
  scoring_grid    = $c370$a. Vérification de la situation temps de conduite / repos accomplis (561/2006), le volontariat ne dispensant pas du repos : 1 pt. b. Vérification de la validité des titres et de l'aptitude (permis D, carte de qualification / FCO, visite médicale à jour) : 1 pt. Total = 2. (Une seule vérification correcte = 1 pt.)$c370$
WHERE source_ref = 'ERTV-M4-QC-05' AND type='qr';

-- ⚠️ ERTV-M4-QC-06 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$On attend trois temps annexes distincts de la conduite, à intégrer au temps de travail effectif du conducteur de voyageurs. Trois exemples pertinents (toute réponse équivalente est acceptée) :

a. Temps de prise et de fin de service : tour de sécurité et contrôle du véhicule avant départ (niveaux, pneumatiques, éclairage, portes, dispositif PMR), insertion de la carte et démarrage du chronotachygraphe, renseignement de la feuille de route, remisage en fin de service.

b. Temps d'attente et de mise à disposition : périodes où le conducteur reste à la disposition de l'employeur sans conduire (attente au terminus, temps entre deux courses lorsqu'il ne peut disposer librement de son temps, immobilisation liée à l'exploitation).

c. Temps de tâches connexes d'exploitation : nettoyage et entretien courant du véhicule, ravitaillement en carburant, accueil et aide à la montée/descente des voyageurs (dont assistance PMR et manipulation de la palette), tâches administratives (billettique, comptage, encaissement, remise de recette).

Points clés du raisonnement : ces temps s'ajoutent à la conduite proprement dite pour former le temps de travail effectif ; ils se distinguent des coupures et pauses non travaillées, qui n'entrent pas dans le temps de travail. Le battement au terminus n'est du temps de travail que dans la mesure où le conducteur reste à disposition et ne peut vaquer librement à ses occupations.$c370$,
  scoring_grid    = $c370$Total 2 pts. 0,5 pt par temps annexe correct et distinct cité (jusqu'à 3 temps = 1,5 pt). + 0,5 pt pour la distinction rappelée entre temps de travail effectif (conduite + temps annexes) et coupures/pauses non travaillées. Un simple listage de 3 temps sans distinction = 1,5 pt.$c370$
WHERE source_ref = 'ERTV-M4-QC-06' AND type='qr';

-- ⚠️ ERTV-M4-QC-07 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER: conditions renforcées précises de la règle des 12 jours pour la conduite entre 22h et 06h (soit double équipage, soit temps de conduite ramené à 3 h) et nombre exact de repos hebdomadaires normaux de compensation dus au retour, à vérifier dans le texte consolidé du règl. CE 561/2006 art. 8 tel que modifié par le règl. CE 1073/2009. La dérog
UPDATE public.question_bank SET
  expected_answer = $c370$a. Dérogation étudiée : il s'agit de la « règle des 12 jours » applicable au transport occasionnel international de voyageurs, prévue par le règlement (CE) n° 561/2006 (article 8) tel que modifié pour ce type de service. Elle autorise, à titre exceptionnel, à reporter le repos hebdomadaire pour effectuer jusqu'à 12 périodes de 24 heures consécutives depuis le dernier repos hebdomadaire normal, ce qui rend juridiquement possible un circuit de 11 jours sans retour au point d'attache. Le circuit de 11 jours entre donc dans le plafond des 12 jours.

b. Précautions à prendre : vérifier que TOUTES les conditions d'ouverture de la dérogation sont réunies et le tracer avant d'accepter. En particulier : que le service est bien un service occasionnel unique et de dimension internationale ; que le conducteur a pris un repos hebdomadaire normal avant le départ ; qu'un ou deux repos hebdomadaires normaux (compensation) sont planifiés et pris au retour ; que les temps de conduite journaliers/hebdomadaires et les repos journaliers restent respectés pendant les 12 jours ; que les conditions renforcées liées à la conduite de nuit sont satisfaites. S'assurer que le chronotachygraphe et les documents attestent le respect de chaque condition, et refuser ou réaménager le circuit si l'une d'elles n'est pas remplie.

Conclusion : la dérogation est mobilisable (11 < 12 jours), mais son bénéfice est strictement conditionné ; la précaution centrale est de sécuriser en amont, par écrit, le respect des repos hebdomadaires encadrant la période et des conditions particulières.$c370$,
  scoring_grid    = $c370$Total 2 pts. a. Identification de la dérogation « 12 jours » en transport occasionnel international (règl. 561/2006) = 1 pt. b. Au moins une précaution valable (repos hebdomadaire normal avant/compensation après, vérification et traçabilité des conditions, respect des temps de conduite/repos journaliers) = 1 pt. Réponse citant seulement « dérogation possible » sans condition ni précaution = 1 pt maximum.$c370$
WHERE source_ref = 'ERTV-M4-QC-07' AND type='qr';

-- ⚠️ ERTV-M4-QC-08 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$On attend deux leviers d'organisation (et non de simples slogans de recrutement) permettant de pourvoir les services scolaires malgré la pénurie de conducteurs. Deux exemples pertinents :

a. Optimisation du graphicage et des roulements pour mutualiser les besoins : construire des services combinant le scolaire du matin et du soir avec d'autres activités de la journée (lignes régulières, transport à la demande, occasionnel, périscolaire) afin de reconstituer des temps de travail attractifs et de réduire le nombre de conducteurs requis. La polyvalence des conducteurs et la mutualisation entre lignes limitent le besoin en effectifs dédiés.

b. Recours à des formes d'emploi et d'affectation adaptées au rythme scolaire : contrats à temps partiel calés sur les périodes scolaires (type CPS, conducteurs en périodes scolaires), heures complémentaires/supplémentaires et annualisation du temps de travail, recours à des conducteurs de réserve ou en renfort, sous-traitance/affrètement ponctuel d'une partie des circuits.

Autres leviers acceptés : plan de formation interne (accès au permis D et à la FIMO/titre pro financés), redécoupage des circuits pour équilibrer les amplitudes, échange de conducteurs entre dépôts.$c370$,
  scoring_grid    = $c370$Total 2 pts. 1 pt par levier d'organisation valable et explicité (jusqu'à 2 leviers). Un levier seulement cité sans explication = 0,5 pt. Une réponse portant uniquement sur « recruter davantage » sans dimension organisationnelle (roulements, temps partiel scolaire, mutualisation, polyvalence, sous-traitance) = 0,5 pt maximum.$c370$
WHERE source_ref = 'ERTV-M4-QC-08' AND type='qr';

-- ⚠️ ERTV-M4-QC-09 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$La traçabilité des vérifications d'affectation (registre attestant que, avant chaque mise en service, l'exploitant a contrôlé que le conducteur dispose bien des titres et aptitudes requis) protège l'exploitant lors d'un contrôle en entreprise pour plusieurs raisons :

a. Elle apporte la preuve du respect de l'obligation de vérification : permis D en cours de validité et de la bonne catégorie, carte de qualification / FCO à jour, carte de conducteur du chronotachygraphe valide, visite médicale d'aptitude à jour, respect des temps de conduite et de repos disponibles pour la prise de service.

b. Elle matérialise la diligence de l'employeur et le sérieux de l'organisation : en cas de contrôle en entreprise (DREAL, inspection du travail), l'exploitant peut démontrer qu'il n'a pas affecté un conducteur non habilité ou inapte, ce qui limite ou écarte sa responsabilité, notamment la responsabilité pénale du dirigeant pour mise à disposition d'un conducteur ne remplissant pas les conditions.

c. Elle sécurise l'exploitation au quotidien : l'écrit daté et signé permet de dater le contrôle, d'identifier qui a affecté qui, et de reconstituer la chaîne de décision. Sans traçabilité, la vérification, même faite, est réputée non prouvée : c'est la preuve, autant que la vérification, qui protège l'entreprise.

Idée centrale attendue : la traçabilité transforme une vérification en preuve opposable, ce qui permet de démontrer la diligence de l'exploitant et de limiter sa responsabilité en cas de contrôle ou d'accident.$c370$,
  scoring_grid    = $c370$Total 2 pts. 1 pt pour l'idée que la traçabilité constitue une preuve du contrôle des titres/aptitudes (permis, FCO, carte conducteur, médical). + 1 pt pour l'idée que cette preuve démontre la diligence de l'employeur et limite/écarte sa responsabilité en cas de contrôle en entreprise. Réponse restant sur « c'est plus sérieux » sans notion de preuve ni de responsabilité = 0,5 pt.$c370$
WHERE source_ref = 'ERTV-M4-QC-09' AND type='qr';

-- ⚠️ ERTV-M4-QC-10 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER: valeurs chiffrées de l'amplitude maximale journalière en transport de voyageurs (usuellement 12 h, portée à 13 h voire davantage sous conditions par accord de branche) volontairement non affirmées ici ; à vérifier dans la CCN des transports routiers et les accords de branche voyageurs en vigueur avant diffusion. Le corrigé reste correct san
UPDATE public.question_bank SET
  expected_answer = $c370$a. Pourquoi l'amplitude est structurellement plus large que la durée du travail : l'amplitude est la durée qui sépare la prise de service de la fin de service, coupures comprises. Elle englobe donc, en plus du temps de travail effectif (conduite + temps annexes), les interruptions non travaillées : coupures, longues pauses, temps où le conducteur peut vaquer librement à ses occupations. Or l'exploitation du transport de voyageurs impose précisément ces interruptions : services scolaires en deux vacations (matin et soir) séparées par une coupure de plusieurs heures, pointes du matin et du soir sur les lignes urbaines/interurbaines, battements au terminus. La journée s'étire donc bien au-delà des heures réellement travaillées, ce qui creuse mécaniquement l'écart entre amplitude et durée du travail.

b. Où l'exploitant trouve les maxima applicables : les plafonds ne sont pas dans le règlement (CE) 561/2006 (qui fixe conduite et repos), mais dans le droit interne du travail applicable au secteur : le code du travail et surtout la convention collective nationale des transports routiers et le ou les accords de branche propres au transport de voyageurs, qui fixent l'amplitude maximale journalière et ses conditions de dépassement, ainsi que la contrepartie des coupures. C'est là que l'exploitant lit l'amplitude maximale autorisée et les cas de dérogation.

Synthèse attendue : amplitude = temps travaillé + coupures non travaillées imposées par l'exploitation voyageurs ; maxima à chercher dans le code du travail et la convention collective / accords de branche transport de voyageurs, et non dans le 561/2006.$c370$,
  scoring_grid    = $c370$Total 2 pts. a. 1 pt pour expliquer que l'amplitude inclut les coupures/interruptions non travaillées (liées aux vacations scolaires, pointes, battements) en plus du temps de travail. b. 1 pt pour situer les maxima dans le code du travail et la convention collective / accords de branche voyageurs (et non dans le règl. 561/2006). Distinction amplitude/durée du travail correcte mais source des maxima absente ou fausse = 1 pt.$c370$
WHERE source_ref = 'ERTV-M4-QC-10' AND type='qr';

-- ⚠️ ERTV-M5-QC-01 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Le moment critique : les accidents mortels ne se produisent pratiquement jamais pendant le roulage lui-même, mais aux abords immédiats du point d'arrêt, au moment de la montée et surtout de la descente des enfants, lorsque l'élève traverse la chaussée.

b. Le lieu précis : la traversée devant ou derrière le car, dans les angles morts du véhicule. L'enfant, masqué par la masse de l'autocar, s'engage sur la chaussée et est heurté soit par le car qui redémarre, soit par un autre véhicule qui double ou croise sans avoir vu l'élève.

Conséquence pédagogique attendue : le conducteur doit sécuriser la phase d'arrêt (immobilisation complète, feux, contrôle des angles morts, attente que l'enfant ait dégagé la chaussée) et éduquer les enfants à ne jamais traverser immédiatement devant ou derrière le car.$c370$,
  scoring_grid    = $c370$a. Moment : montée/descente et traversée de la chaussée aux points d'arrêt (et non pendant le roulage) = 1 pt. b. Lieu précis : devant ou derrière le car, dans les angles morts = 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M5-QC-01' AND type='qr';

-- ⚠️ ERTV-M5-QC-02 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$a. La seule voix autorisée : la direction de l'entreprise, c'est-à-dire le dirigeant ou le porte-parole unique qu'elle a expressément désigné (cellule de crise). Ni le conducteur impliqué, ni les autres salariés ne s'expriment auprès des familles ou des médias : la communication est centralisée pour rester cohérente et maîtrisée.

b. Le type de messages : des messages factuels, sobres et empathiques. On exprime la compassion envers les victimes et les familles, on donne les faits établis et vérifiés (nombre de personnes concernées, mesures de prise en charge, coopération avec les secours et l'enquête). On ne communique jamais sur les causes ni sur les responsabilités tant que l'enquête n'a pas conclu, et on évite toute déclaration spéculative ou défensive.$c370$,
  scoring_grid    = $c370$a. Voix autorisée : la direction / le porte-parole unique désigné (exclusion du conducteur et des salariés) = 1 pt. b. Type de messages : factuels, sobres et empathiques, sans se prononcer sur les causes/responsabilités = 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M5-QC-02' AND type='qr';

-- ⚠️ ERTV-M5-QC-03 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Les quatre étapes du traitement d'une réclamation voyageur, dans l'ordre :

1. Réception et enregistrement : accuser réception de la réclamation, l'enregistrer (traçabilité, date, identité du voyageur, objet) et remercier le client de son signalement.

2. Analyse / instruction : rechercher et vérifier les faits, recueillir les éléments internes (conducteur, exploitation, billettique, planning) pour comprendre ce qui s'est réellement passé et qualifier le bien-fondé de la réclamation.

3. Réponse : apporter au voyageur une réponse claire et personnalisée dans un délai raisonnable, avec, le cas échéant, la solution ou le geste commercial (excuses, dédommagement).

4. Suivi et clôture : mettre en oeuvre et vérifier les mesures correctives, archiver le dossier et exploiter la réclamation pour améliorer le service (analyse des récurrences).$c370$,
  scoring_grid    = $c370$0,5 pt par étape correctement citée ET dans le bon ordre (réception/enregistrement puis analyse puis réponse puis suivi/clôture). Ordre inversé ou étape manquante : retirer 0,5 pt par erreur. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M5-QC-03' AND type='qr';

-- ⚠️ ERTV-M5-QC-04 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER: référence réglementaire exacte du panneau « transport d'enfants » et modalités précises d'apposition/retrait à recaler sur le support de cours ERTV-M5 avant diffusion.]
UPDATE public.question_bank SET
  expected_answer = $c370$La signalisation « transport d'enfants » (panneaux réfléchissants à l'avant et à l'arrière) joue un double rôle :

a. Un rôle d'avertissement / de prévention envers les autres usagers : placée à l'avant comme à l'arrière, elle est visible des véhicules qui croisent et de ceux qui suivent. Elle signale la présence d'enfants à bord et incite les autres conducteurs à redoubler de vigilance et de prudence, notamment lors des arrêts, des montées et des descentes.

b. Un rôle réglementaire / de responsabilisation du conducteur : l'affichage n'est autorisé que lorsque le car transporte effectivement des enfants. Le conducteur doit donc l'apposer pendant le service scolaire et le retirer ou le masquer dès qu'il n'y a plus d'enfants à bord, afin de ne pas induire les autres usagers en erreur. La signalisation engage ainsi la conformité et la responsabilité de l'exploitant.$c370$,
  scoring_grid    = $c370$a. Rôle d'avertissement/prévention des autres usagers (visibilité avant et arrière, incitation à la prudence) = 1 pt. b. Rôle réglementaire : affichage uniquement en présence effective d'enfants, retrait/masquage sinon = 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M5-QC-04' AND type='qr';

-- ⚠️ ERTV-M5-QC-05 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Deux fautes commises :
1. Un refus de transport à caractère discriminatoire : le conducteur a refusé un voyageur en raison de son handicap. L'entreprise a une obligation d'accessibilité et de non-discrimination ; une rampe en panne ne dispense pas de chercher une solution, et le refus sec constitue un manquement grave à l'accueil et au principe d'égalité de traitement.
2. L'absence de signalement et de solution de substitution : le conducteur n'a prévenu ni l'exploitation ni sa hiérarchie de la panne de la rampe, et n'a proposé aucune alternative au voyageur (arrêt accessible, véhicule de substitution, prise en charge ultérieure, aide humaine). Il a laissé le client sans réponse.

b. Un risque pour l'entreprise (au choix) : un risque juridique majeur, la discrimination liée au handicap étant un délit susceptible de plainte et de sanction ; et/ou une atteinte à l'image et à la réputation de l'entreprise, pouvant aller jusqu'à des pénalités de l'autorité organisatrice, voire la remise en cause du contrat de délégation de service public.$c370$,
  scoring_grid    = $c370$a. Deux fautes : 0,5 pt chacune (refus discriminatoire lié au handicap ; absence de signalement / de solution de substitution) = 1 pt. b. Un risque pertinent pour l'entreprise (juridique/pénal, image, ou contractuel) = 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'ERTV-M5-QC-05' AND type='qr';

-- ⚠️ ERTV-M5-QC-06 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Trois équipements d'accessibilité attendus sur un véhicule de transport de voyageurs (accessibilité PMR/UFR) — trois réponses suffisent parmi :

1. Un dispositif d'accès de plain-pied : plancher surbaissé et/ou système d'agenouillement (kneeling), ou rampe/palette rétractable (manuelle ou électrique) permettant l'accès d'un fauteuil roulant.
2. Un emplacement dédié UFR (usager en fauteuil roulant) équipé d'un système d'ancrage/retenue du fauteuil et d'une ceinture pour l'occupant.
3. Une information voyageurs accessible : annonces sonores ET visuelles des arrêts (bandeau/afficheur + synthèse vocale), au bénéfice des personnes malvoyantes et malentendantes.

Autres réponses acceptables : bouton de demande d'arrêt spécifique / d'appel à hauteur accessible et repérable ; barres de maintien et mains courantes contrastées ; places assises réservées et signalées à proximité des portes ; contraste visuel des marches et nez de marche ; éclairage renforcé des accès.

Principe : l'accessibilité doit couvrir toute la chaîne du déplacement (montée, circulation intérieure, calage/maintien, information), pas seulement la montée à bord.$c370$,
  scoring_grid    = $c370$Barème sur 2 points : 0,67 point par équipement d'accessibilité correct et pertinent, dans la limite de trois (arrondi à 2/2 pour trois réponses justes). Soit 1 réponse = 0,5 ; 2 réponses = 1,5 ; 3 réponses = 2. Répétition d'un même équipement reformulé = compté une seule fois.$c370$
WHERE source_ref = 'ERTV-M5-QC-06' AND type='qr';

-- ⚠️ ERTV-M5-QC-07 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Trois équipements réglementaires de bord mobilisables pour évacuer un autocar — trois réponses suffisent parmi :

1. Le(s) marteau(x) brise-vitre, disposés à proximité des vitres latérales, pour créer une issue lorsque les portes sont inutilisables.
2. Les issues de secours du véhicule : fenêtres/vitres de secours, portes de secours et trappe(s) d'évacuation en toiture, permettant la sortie si l'accès normal est bloqué.
3. L'éclairage de secours (balisage lumineux intérieur) qui guide les passagers vers les sorties en cas de panne, de fumée ou d'accident.

Autres réponses acceptables et utiles à l'évacuation/sécurité : l'extincteur (maîtrise d'un départ de feu pour permettre l'évacuation) ; la trousse de premiers secours ; les triangles de présignalisation et le gilet de haute visibilité (sécuriser l'environnement après la sortie).

Principe attendu : citer des dispositifs qui permettent de sortir du véhicule (marteau, issues de secours, balisage) plutôt que de simples équipements de confort.$c370$,
  scoring_grid    = $c370$Barème sur 2 points : 0,67 point par équipement correct et pertinent pour l'évacuation, dans la limite de trois (3 réponses justes = 2/2). 1 réponse = 0,5 ; 2 = 1,5 ; 3 = 2. Un équipement de confort sans lien avec l'évacuation/sécurité n'est pas compté.$c370$
WHERE source_ref = 'ERTV-M5-QC-07' AND type='qr';

-- ⚠️ ERTV-M5-QC-08 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Un tableau de bord « arrangé » (chiffres enjolivés, retouchés ou lissés) remis à l'autorité organisatrice est une faute d'exploitation en soi, indépendamment de la mauvaise performance réelle, pour plusieurs raisons :

1. Manquement à l'obligation de loyauté et de transparence contractuelle : dans une délégation de service public ou un marché, l'exploitant doit rendre compte fidèlement (reporting sincère). Falsifier les indicateurs, c'est manquer à une obligation contractuelle et déontologique, ce qui constitue en soi une faute, sanctionnable indépendamment du niveau réel de performance.
2. Tromperie de l'autorité organisatrice dans sa décision : l'AO pilote le service à partir de ces indicateurs (régularité, ponctualité, fréquentation, réclamations). Des chiffres arrangés faussent son jugement, la privent de sa capacité de contrôle et l'empêchent de prendre les mesures correctives nécessaires.
3. Perte de confiance et risque contractuel majeur : la découverte d'une donnée falsifiée détruit la crédibilité de tout le reporting (même les données exactes deviennent suspectes), et expose à des pénalités, à la résiliation pour faute, voire à l'éviction lors du renouvellement — sanction bien plus lourde que celle attachée à de mauvais résultats reconnus.
4. Effet contre-productif sur la performance : masquer un problème empêche de le traiter. Les dysfonctionnements persistent, tandis qu'un mauvais chiffre présenté honnêtement, accompagné d'un plan d'action, est perçu comme une gestion maîtrisée.

En synthèse : de mauvais résultats sont un problème de performance, qui peut se corriger ; un tableau de bord arrangé est un problème d'intégrité, qui rompt la relation de confiance et engage la responsabilité de l'exploitant. On peut expliquer un mauvais chiffre, jamais un chiffre faux.$c370$,
  scoring_grid    = $c370$Barème sur 2 points : 1 point pour l'idée que la sincérité du reporting est une obligation contractuelle/déontologique, donc que la falsification est fautive en elle-même, quel que soit le résultat réel ; 1 point pour au moins une conséquence concrète correctement expliquée (AO trompée dans son pilotage/contrôle, perte de confiance, pénalités/résiliation/non-reconduction, ou problème non traité). Réponse citant les deux volets = 2/2.$c370$
WHERE source_ref = 'ERTV-M5-QC-08' AND type='qr';

-- ⚠️ ERTV-M5-QC-09 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$La liste des passagers doit être fiable AVANT le départ, et non reconstituée après un accident, pour des raisons de sécurité, de secours et de responsabilité :

1. Efficacité des secours et bilan humain : en cas d'accident, les services de secours doivent connaître immédiatement le nombre exact de personnes à bord pour dimensionner les moyens et, surtout, savoir combien de victimes rechercher. Une liste fiable établie avant le départ permet de vérifier que tout le monde est retrouvé (comptage / appel nominatif) et d'éviter qu'un passager éjecté ou inconscient ne soit oublié. Reconstituer la liste après coup, à partir de survivants sous le choc, est peu fiable et fait perdre un temps vital.
2. Impossibilité matérielle de reconstitution après l'accident : après un choc, un incendie ou une éjection, les témoignages sont incomplets et les personnes décédées ou grièvement blessées ne peuvent pas confirmer leur présence. La seule donnée fiable est celle figée avant le départ.
3. Information des familles et identification : une liste préétablie permet d'identifier rapidement les victimes et de prévenir les proches, ce qui est à la fois une obligation morale et un enjeu de gestion de crise.
4. Obligation et responsabilité de l'exploitant : notamment en service occasionnel/transport de groupes, la tenue d'une liste de passagers relève des obligations de l'organisateur/transporteur ; son absence ou son caractère approximatif engage sa responsabilité et constitue une faute d'exploitation. La liste sert aussi de preuve du service réellement effectué (nombre de participants, contrôle).

En synthèse : la liste est un outil de sécurité et de secours qui n'a de valeur que si elle est exacte au moment où le risque se réalise. Après l'accident, il est trop tard : on ne peut plus garantir qu'elle est complète, et c'est précisément à ce moment qu'on en a le plus besoin.$c370$,
  scoring_grid    = $c370$Barème sur 2 points : 1 point pour l'enjeu secours/comptage (savoir combien de personnes à bord pour n'oublier aucune victime et dimensionner les secours) ; 1 point pour un second argument valable (reconstitution impossible/non fiable après coup, identification et information des familles, ou obligation/responsabilité de l'exploitant et valeur de preuve). Les deux volets traités = 2/2.$c370$
WHERE source_ref = 'ERTV-M5-QC-09' AND type='qr';

-- ⚠️ ERTV-M5-QC-10 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$« La reconduction d'un contrat se gagne toute l'année, pas au moment du renouvellement. » Justification par deux mécanismes concrets — deux réponses suffisent parmi :

1. La qualité de service mesurée en continu : la régularité et la ponctualité, le respect des kilomètres et courses prévus, le faible taux de courses non assurées, la propreté et l'état du matériel, la sécurité (accidentologie) sont enregistrés jour après jour. Ces indicateurs alimentent le bilan que l'autorité organisatrice consultera au renouvellement ; on ne peut pas les redresser au dernier moment, ils reflètent douze mois d'exploitation.
2. La relation et la réactivité avec l'autorité organisatrice : un reporting régulier et sincère, une communication proactive en cas d'incident, un traitement rapide et suivi des réclamations des voyageurs, la force de proposition (optimisation des dessertes, économies, améliorations) construisent tout au long du contrat une confiance et une réputation de partenaire fiable, qui pèsent lourd au moment de choisir de reconduire.

Autres mécanismes acceptables : la satisfaction des voyageurs (enquêtes, baisse des plaintes) qui remonte aux élus/AO ; le respect des engagements sociaux et réglementaires (temps de conduite, sécurité, absence de contentieux) ; la maîtrise et la transparence sur les coûts ; l'anticipation des investissements (renouvellement du parc, accessibilité, transition énergétique) qui rassure sur la capacité à tenir le service dans la durée.

Principe attendu : l'AO reconduit sur la base d'un historique cumulé (données de performance + confiance relationnelle) qui se construit en continu et ne se rattrape pas à la date du renouvellement.$c370$,
  scoring_grid    = $c370$Barème sur 2 points : 1 point par mécanisme concret correctement justifié (lien explicité avec la décision de reconduction), dans la limite de deux. Un seul mécanisme = 1/2 ; deux mécanismes distincts et pertinents = 2/2. Deux formulations d'un même mécanisme = 1 point.$c370$
WHERE source_ref = 'ERTV-M5-QC-10' AND type='qr';

-- ⚠️ ERTV-M6-QC-01 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Ce sont les services occasionnels longue distance qui relèvent du règlement (CE) 561/2006, et non la ligne régulière de 38 km.

a. Champ d'application commun : le règlement 561/2006 s'applique au transport de voyageurs par véhicule construit ou aménagé pour transporter plus de 9 personnes (conducteur compris). Les deux services, assurés en autocars de 55 places, franchissent ce seuil : ce critère seul ne permet donc pas de les distinguer.

b. Le critère décisif est la nature et la longueur de la ligne. L'article 3, point a) du règlement exclut de son champ les services réguliers de transport de voyageurs dont le parcours de ligne (trajet) ne dépasse pas 50 km. La ligne régulière de 38 km est en dessous de ce seuil : elle est donc hors champ du 561/2006 et relève de la réglementation nationale du temps de travail.

c. Conclusion : les services occasionnels longue distance, qui ne bénéficient d'aucune dérogation de distance, sont soumis au 561/2006 (temps de conduite, pauses et repos). En service occasionnel international, ils peuvent en outre bénéficier de la dérogation dite « des 12 jours ».$c370$,
  scoring_grid    = $c370$a. Identification du service concerné (services occasionnels longue distance relèvent du 561/2006) : 1 point. b. Justification par le critère du parcours de ligne régulière inférieur ou égal à 50 km excluant la ligne de 38 km (art. 3 a) : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'ERTV-M6-QC-01' AND type='qr';

-- ⚠️ ERTV-M6-QC-02 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Non, il ne peut pas prendre le volant.

a. Règle applicable : pour les conducteurs de véhicules de transport en commun de voyageurs, le taux légal d'alcoolémie est abaissé à 0,2 g/L de sang (soit 0,10 mg/L d'air expiré), et non 0,5 g/L comme pour les autres conducteurs. Un circuit scolaire, assuré en véhicule de transport en commun, entre dans ce cadre.

b. Application au cas : le contrôle affiche 0,3 g/L, taux supérieur au seuil de 0,2 g/L applicable au transport en commun. Le conducteur est donc en infraction et ne peut légalement pas prendre son service ; l'exploitant doit l'écarter du volant et prévoir un remplacement.

c. Portée : ce seuil abaissé vaut quel que soit le service (scolaire, régulier, occasionnel) dès lors que le véhicule est un véhicule de transport en commun ; la présence d'enfants renforce l'exigence de sécurité mais ne crée pas une règle distincte.$c370$,
  scoring_grid    = $c370$a. Rappel du seuil de 0,2 g/L de sang propre au transport en commun de voyageurs : 1 point. b. Conclusion motivée (0,3 g/L > 0,2 g/L donc interdiction de prendre le volant) : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'ERTV-M6-QC-02' AND type='qr';

-- ⚠️ ERTV-M6-QC-03 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Le graphicage et l'habillage sont deux étapes successives de la construction de l'offre, mais ils ne portent pas sur le même objet.

a. Graphicage : c'est la construction des graphiques de circulation, c'est-à-dire la définition des courses (trajets) à réaliser et de leurs horaires de passage à partir de la demande de transport et des contraintes d'exploitation. Son objet est le véhicule et la course : il répond à la question « quels trajets, à quels horaires ». Le graphicage ignore encore qui conduira.

b. Habillage : c'est l'affectation du travail aux conducteurs, obtenue en découpant et regroupant les courses issues du graphicage en journées de service (vacations) attribuables à un agent, dans le respect de la réglementation du temps de travail et de conduite. Son objet est le travail du conducteur : il répond à la question « qui assure quelles courses, dans quelle journée de service ».

c. Enchaînement : le graphicage produit les courses, l'habillage les transforme en services de conduite ; viennent ensuite le roulement (succession des services sur plusieurs jours pour une équipe) et la gestion des battements (temps d'attente entre deux courses).$c370$,
  scoring_grid    = $c370$a. Définition du graphicage avec son objet (courses et horaires des véhicules) : 1 point. b. Définition de l'habillage avec son objet (affectation des courses aux conducteurs en journées de service) : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'ERTV-M6-QC-03' AND type='qr';

-- ⚠️ ERTV-M6-QC-04 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Le régulateur hiérarchise ses arbitrages selon un ordre de priorité décroissant, et accompagne chaque décision d'une obligation transversale d'information.

a. Priorité 1 : la sécurité au point d'arrêt. La sécurité des personnes prime sur toute considération commerciale ou d'horaire ; le régulateur traite d'abord le risque au point d'arrêt (protection des voyageurs, neutralisation du danger), quitte à dégrader la régularité.

b. Priorité 2 : la correspondance. Une fois la sécurité assurée, il préserve la continuité du déplacement des voyageurs en traitant la correspondance (attente, réacheminement, solution de report) pour éviter de laisser des voyageurs sans solution.

c. Priorité 3 : la régularité de la ligne. En dernier lieu seulement, il agit sur le respect de l'horaire et la régularité (rattrapage, resserrement des intervalles), car c'est l'enjeu le moins critique des trois.

d. Obligation transversale : chaque décision s'accompagne de l'information des voyageurs (et de la traçabilité vers le poste de commandement/PC). Informer en temps réel les usagers de la situation et de la solution retenue conditionne l'acceptabilité de chaque arbitrage.$c370$,
  scoring_grid    = $c370$a. Ordre correct des trois arbitrages : sécurité, puis correspondance, puis régularité : 1 point (0,5 si l'ordre n'est que partiellement juste). b. Identification de l'obligation transversale d'information des voyageurs attachée à chaque décision : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'ERTV-M6-QC-04' AND type='qr';

-- ⚠️ ERTV-M6-QC-05 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Avant tout raisonnement de planning (heures disponibles, enchaînement des courses), le régulateur doit d'abord s'assurer que le conducteur est légalement en droit de conduire. Les vérifications légales préalables sont les suivantes :

a. Permis de conduire de la catégorie requise (catégorie D pour l'autocar/autobus), valide et en cours de validité.

b. Qualification professionnelle à jour : FIMO voyageurs (qualification initiale) puis FCO (formation continue quinquennale), matérialisées par la carte de qualification de conducteur.

c. Aptitude médicale en cours de validité : le permis D est soumis à visite médicale périodique ; l'avis d'aptitude doit être valide à la date du service.

d. Carte de conducteur (chronotachygraphe) personnelle et valide, indispensable pour prendre le volant d'un véhicule équipé.

e. Situation au regard des temps de conduite et de repos : vérifier que le conducteur a pris ses repos réglementaires et qu'il dispose du potentiel de conduite nécessaire (règlement 561/2006), afin de ne pas le mettre en infraction dès la prise de service.

Ce n'est qu'une fois ces conditions légales réunies que l'on raisonne planning (compatibilité horaire, durée du service, battements).$c370$,
  scoring_grid    = $c370$Attribuer 1 point pour la mention des habilitations propres au conducteur (permis D valide, FIMO/FCO à jour, aptitude médicale, carte de conducteur) et 1 point pour la vérification de la situation temps de conduite/repos disponible (561/2006) avant tout calcul de planning. Barème indicatif : 0,5 par élément correctement cité, plafonné à 2 points. Total = 2 points.$c370$
WHERE source_ref = 'ERTV-M6-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Document réclamé en priorité
La cellule de crise réclame en priorité la liste nominative des passagers du groupe (le « manifeste passagers »), c'est-à-dire le relevé d'identité des personnes effectivement montées à bord. Dans un service occasionnel, cette liste est normalement annexée au document de contrôle du service (feuille de route) que le conducteur doit détenir à bord ; elle est complétée le cas échéant par les coordonnées de l'organisateur du voyage et le nom du conducteur affecté.

b. Usages de ce document
1. Dénombrer et identifier les victimes : confronter le nombre de personnes attendues à bord au nombre de personnes recensées sur les lieux, afin de repérer immédiatement d'éventuels blessés éjectés, dispersés ou manquants.
2. Alerter et informer les familles : disposer des identités permet de prévenir les proches de façon fiable et coordonnée, sans diffuser d'information erronée.
3. Coordonner avec les secours et les autorités : fournir aux services de secours (SAMU, pompiers, forces de l'ordre) et aux établissements hospitaliers une base nominative pour le tri, l'orientation et le suivi des victimes.
4. Sécuriser la communication et le volet administratif/assurantiel : alimenter la cellule de communication avec des données vérifiées et constituer une base fiable pour les déclarations aux assureurs, à l'autorité organisatrice et pour l'enquête ultérieure.$c370$,
  scoring_grid    = $c370$a. Identification du document prioritaire = liste nominative des passagers / manifeste (annexé à la feuille de route du service occasionnel) : 1 point. b. Usages : citer au moins deux usages pertinents parmi (dénombrement/identification des victimes, information des familles, coordination secours/hôpitaux/autorités, communication et suivi administratif/assurantiel) : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'ERTV-M6-QC-06' AND type='qr';

-- ⚠️ FIMO-M0-QC-01 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER: le nombre exact de « thèmes » attendu (3 domaines de connaissances au sens de la directive 2003/59/CE, ou un découpage plus fin propre au support de cours). La durée de 140 h est certaine ; le décompte des thèmes doit être aligné sur le référentiel/support utilisé par l'organisme.]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Durée de la FIMO marchandises : la Formation Initiale Minimale Obligatoire dure 140 heures, réparties sur 4 semaines environ, avant l'accès au métier de conducteur du transport routier de marchandises (véhicules de plus de 3,5 t de PTAC).

b. Nombre de thèmes couverts : le programme de la FIMO est structuré autour des grands domaines de connaissances fixés par la directive 2003/59/CE et sa transposition française, à savoir : le perfectionnement à la conduite rationnelle axée sur les règles de sécurité (dont l'éco-conduite et la maîtrise du chronotachygraphe), l'application des réglementations (temps de conduite et de repos du règlement CE 561/2006, arrimage et répartition des charges, PTAC et charge à l'essieu), et la santé, la sécurité routière et environnementale, le service et la logistique (gestes et postures, prévention des risques). Ces domaines sont eux-mêmes déclinés en thèmes dans le support de formation.$c370$,
  scoring_grid    = $c370$a. Durée = 140 heures : 1 point. b. Nombre de thèmes couverts (conforme au découpage du référentiel) : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'FIMO-M0-QC-01' AND type='qr';

-- ⚠️ FIMO-M0-QC-02 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Durée de la FCO : la Formation Continue Obligatoire dure 35 heures.

b. Périodicité : elle doit être renouvelée tous les 5 ans, tout au long de la carrière du conducteur, afin d'actualiser ses connaissances (réglementation sociale européenne, sécurité, éco-conduite, prévention des risques) et de maintenir la validité de sa qualification (carte de qualification de conducteur / CQC).$c370$,
  scoring_grid    = $c370$a. Durée = 35 heures : 1 point. b. Périodicité = tous les 5 ans : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'FIMO-M0-QC-02' AND type='qr';

-- ⚠️ FIMO-M0-QC-03 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$La qualification de conducteur (FIMO puis FCO) est exigée en transport de marchandises pour la conduite des véhicules dont le PTAC est supérieur à 3,5 tonnes, c'est-à-dire les véhicules relevant des catégories de permis C1, C1E, C et CE. En dessous de ce seuil (véhicules de 3,5 tonnes de PTAC ou moins, permis B), la qualification FIMO n'est pas requise.$c370$,
  scoring_grid    = $c370$Seuil correctement identifié : PTAC supérieur à 3,5 tonnes = 2 points (1 point si la notion de PTAC est citée mais le seuil est approximatif ou incomplet). Total = 2 points.$c370$
WHERE source_ref = 'FIMO-M0-QC-03' AND type='qr';

-- ⚠️ FIMO-M0-QC-04 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER: la liste exacte des titres/diplômes ouvrant dispense et leurs intitulés officiels en vigueur peuvent varier selon la mise à jour réglementaire ; vérifier l'intitulé précis attendu par le référentiel de l'organisme.]
UPDATE public.question_bank SET
  expected_answer = $c370$Deux titres ou diplômes professionnels dispensent de passer la FIMO marchandises (leur obtention vaut qualification initiale). On peut citer notamment :

a. Le CAP conducteur routier « marchandises » (anciennement CAP conducteur routier / CAP conducteur livreur de marchandises).

b. Le Titre professionnel de conducteur du transport routier de marchandises sur porteur ou sur tous véhicules (titre pro délivré par le ministère du Travail).

Autres réponses également acceptées : le Bac professionnel « Conducteur transport routier marchandises » (ou Bac pro exploitation des transports pour la partie conduite), le BEP conduite et services dans le transport routier. Toute paire de diplômes ou titres à finalité de conduite routière marchandises inscrits comme dispensant de la FIMO est recevable.$c370$,
  scoring_grid    = $c370$1 point par titre/diplôme valable correctement cité, dans la limite de 2. Total = 2 points.$c370$
WHERE source_ref = 'FIMO-M0-QC-04' AND type='qr';

-- ⚠️ FIMO-M0-QC-05 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Nom de la formation : il s'agit de la formation « passerelle » (passerelle voyageurs vers marchandises), qui permet à un conducteur déjà titulaire d'une qualification voyageurs de la faire valoir pour le transport de marchandises.

b. Durée : cette formation passerelle dure 35 heures (soit l'équivalent d'une semaine), au lieu des 140 heures d'une FIMO complète. À l'issue, le conducteur obtient la qualification marchandises et devra ensuite suivre la FCO marchandises selon la périodicité de 5 ans.$c370$,
  scoring_grid    = $c370$a. Nom = formation passerelle (voyageurs vers marchandises) : 1 point. b. Durée = 35 heures : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'FIMO-M0-QC-05' AND type='qr';

-- ⚠️ FIMO-M0-QC-06 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER: règle d'anticipation des 6 mois avant échéance faisant courir la nouvelle période de 5 ans à partir de la date d'échéance et non de la date du stage — vérifier le délai exact (6 mois) dans les textes en vigueur.]
UPDATE public.question_bank SET
  expected_answer = $c370$Question : À partir de quel événement se calcule l'échéance des 5 ans de la FCO ?

Corrigé :
La qualification du conducteur (matérialisée par la carte de qualification de conducteur, CQC) a une validité de 5 ans. L'échéance des 5 ans ne se compte pas à partir d'une date administrative quelconque, mais à partir de la date de la dernière qualification obtenue par le conducteur :

a. Pour un conducteur qui n'a encore jamais suivi de FCO : le délai de 5 ans court à compter de l'obtention de la qualification initiale (la FIMO, ou la qualification initiale longue équivalente).

b. Pour un conducteur déjà en activité : le délai de 5 ans court à compter de la date de la FCO précédente. Autrement dit, chaque FCO ouvre une nouvelle période de 5 ans, calculée par rapport à la précédente qualification (FIMO ou FCO).

En pratique, l'échéance à surveiller est donc la date de fin de validité de la qualification en cours (portée sur la CQC) : la FCO doit être terminée avant cette date pour garantir la continuité du droit à conduire. Nuance : lorsque la FCO est réalisée dans les 6 mois qui précèdent l'échéance, la nouvelle période de 5 ans est décomptée à partir de la date d'échéance de la qualification précédente, et non à partir de la date du stage, afin de ne pas pénaliser le conducteur qui anticipe.$c370$,
  scoring_grid    = $c370$Barème (total 2 pts) : a. Identifier l'événement de référence = date de la dernière qualification obtenue (FIMO pour la 1re FCO, sinon FCO précédente) : 1 pt. b. Expliquer le décompte des 5 ans à partir de cet événement et le lien avec la date de fin de validité de la CQC : 1 pt (dont 0,5 pt bonus admis pour la nuance des 6 mois d'anticipation, sans dépasser 2).$c370$
WHERE source_ref = 'FIMO-M0-QC-06' AND type='qr';

-- ⚠️ FIMO-M0-QC-07 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Question : Citez les trois titres personnels que le conducteur professionnel présente en contrôle routier.

Corrigé :
Les trois titres personnels (attachés à la personne du conducteur, à distinguer des documents du véhicule ou du transport) sont :

a. Le permis de conduire, en cours de validité et de la catégorie correspondant au véhicule conduit (C, C1, CE, C1E selon le cas).

b. La carte de qualification de conducteur (CQC), qui atteste que le conducteur possède une qualification en cours de validité (FIMO puis FCO à jour).

c. La carte de conducteur du chronotachygraphe (carte conducteur), personnelle et nominative, qui enregistre les temps de conduite, de repos, de travail et de disponibilité.

Ces trois titres sont individuels et incessibles ; leur présentation est exigée lors d'un contrôle routier.$c370$,
  scoring_grid    = $c370$Barème (total 2 pts) : trois titres attendus, environ 0,67 pt par titre correctement identifié. a. Permis de conduire (catégorie adaptée) ; b. Carte de qualification de conducteur (CQC) ; c. Carte de conducteur (chronotachygraphe). Tout titre non personnel cité (carte grise, attestation d'employeur, etc.) n'est pas compté.$c370$
WHERE source_ref = 'FIMO-M0-QC-07' AND type='qr';

-- ⚠️ FIMO-M0-QC-08 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Question : Un conducteur dont la FCO a expiré il y a deux ans veut reprendre le métier : que doit-il suivre ?

Corrigé :
a. Ce qu'il doit suivre : il doit suivre une FCO (Formation Continue Obligatoire, d'une durée de 35 heures) pour régulariser sa qualification avant de pouvoir reconduire à titre professionnel. La FCO peut être suivie à tout moment, y compris après l'expiration de la qualification.

b. Ce qu'il n'a PAS à refaire : il n'a pas à repasser la qualification initiale (FIMO). La péremption de la FCO ne fait pas perdre le bénéfice de la qualification initiale déjà acquise. Le conducteur qui a interrompu son activité et dont la qualification a expiré retrouve son droit à conduire en suivant simplement une nouvelle FCO. Il ne pourra toutefois exercer qu'une fois cette FCO effectuée et sa carte de qualification de conducteur renouvelée.$c370$,
  scoring_grid    = $c370$Barème (total 2 pts) : a. Réponse principale = suivre une FCO (35 h) : 1 pt (0,5 pt pour « FCO », 0,5 pt pour la durée 35 h). b. Préciser qu'il n'a pas à refaire la FIMO / que la qualification initiale reste acquise : 1 pt.$c370$
WHERE source_ref = 'FIMO-M0-QC-08' AND type='qr';

-- ⚠️ FIMO-M0-QC-09 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER: ages catégorie C — 21 ans sans qualification initiale longue / 18 ans avec qualification initiale longue, et statut exact de la FIMO accélérée (140 h) au regard de l'abaissement d'âge. Vérifier la distinction qualification initiale accélérée vs longue dans les textes (directive 2003/59/CE transposée) car les seuils d'âge en dépendent.]
UPDATE public.question_bank SET
  expected_answer = $c370$Question : Sans qualification initiale, à quel âge peut-on conduire en catégorie C ? Et avec la qualification ?

Corrigé :
a. Sans qualification initiale (ou avec la seule qualification initiale accélérée / FIMO 140 h) : la conduite en catégorie C est autorisée à partir de 21 ans.

b. Avec la qualification initiale longue (formation professionnelle longue de type titre professionnel ou diplôme, aboutissant à la qualification initiale complète) : la conduite en catégorie C est autorisée dès 18 ans.

Raisonnement : l'abaissement de l'âge minimal (de 21 à 18 ans) est la contrepartie d'une formation plus complète (qualification initiale longue) qui prépare le jeune conducteur à la conduite d'un poids lourd. La FIMO accélérée (140 h) ne suffit pas à elle seule à abaisser l'âge en catégorie C : elle permet de conduire dès 21 ans.$c370$,
  scoring_grid    = $c370$Barème (total 2 pts) : a. Âge sans qualification initiale longue = 21 ans : 1 pt. b. Âge avec la qualification initiale longue = 18 ans : 1 pt.$c370$
WHERE source_ref = 'FIMO-M0-QC-09' AND type='qr';

-- ⚠️ FIMO-M0-QC-10 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER: formulation exacte de l'exemption FIMO pour « transport de matériel/équipement/machines destinés à l'usage du conducteur dans l'exercice de son métier » et critère « la conduite ne constitue pas l'activité principale » tels que rédigés dans la réglementation en vigueur (art. correspondant du code / directive 2003/59/CE).]
UPDATE public.question_bank SET
  expected_answer = $c370$Question : Un maçon livre occasionnellement ses propres chantiers en camion de 19 t : pourquoi est-il exempté de FIMO, et quand cesserait-il de l'être ?

Corrigé :
a. Pourquoi il est exempté : il bénéficie de l'exemption prévue pour les conducteurs transportant du matériel, des équipements ou des marchandises qu'ils utilisent dans l'exercice de leur propre métier, à la condition que la conduite ne constitue pas leur activité principale. Le maçon transporte ses propres matériaux, vers ses propres chantiers, pour son propre compte, et de façon occasionnelle : la conduite reste accessoire à son métier de maçon. Cette exemption vise précisément les artisans et professionnels du bâtiment dans cette situation.

b. Quand il cesserait de l'être (perte de l'exemption) : il devrait alors suivre la FIMO dès lors que l'une de ces conditions n'est plus remplie, notamment si :
- la conduite du camion devient son activité principale (le transport prend le pas sur le métier de maçon) ;
- il effectue du transport pour le compte d'autrui (transport de marchandises appartenant à des tiers, contre rémunération), et non plus pour son seul compte propre ;
- les marchandises transportées ne servent plus à l'exercice de son propre métier.

En résumé, tant que la conduite demeure accessoire, occasionnelle et au service exclusif de son activité de maçon, l'exemption s'applique ; dès qu'elle devient l'activité principale ou du transport pour compte d'autrui, l'obligation de FIMO s'impose.$c370$,
  scoring_grid    = $c370$Barème (total 2 pts) : a. Motif de l'exemption = transport de matériel/marchandises utilisés dans l'exercice de son propre métier + conduite non principale (activité accessoire, compte propre, occasionnel) : 1 pt. b. Condition de perte de l'exemption = la conduite devient l'activité principale OU passage au transport pour compte d'autrui : 1 pt.$c370$
WHERE source_ref = 'FIMO-M0-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La « colonne vertébrale » réglementaire d'une journée de conduite (Règl. CE 561/2006) s'articule autour de quatre repères.

a. Conduite maximale continue : 4 h 30 de conduite au maximum sans interruption. Au-delà, la poursuite de la conduite constitue une infraction.

b. Pause : après ces 4 h 30, une pause d'au moins 45 minutes est obligatoire. Elle peut être fractionnée en deux tranches prises dans l'ordre, d'abord 15 minutes puis 30 minutes (15 + 30 = 45).

c. Plafond journalier : la durée de conduite journalière est de 9 heures, portée à 10 heures au maximum deux fois par semaine.

d. Repos journalier : un repos journalier normal de 11 heures consécutives, réductible à 9 heures (repos journalier réduit) au maximum trois fois entre deux repos hebdomadaires.

Synthèse à mémoriser : 4 h 30 de conduite, 45 minutes de pause, 9 h (voire 10 h 2 fois/semaine) de conduite journalière, 11 h de repos journalier (réductible à 9 h).$c370$,
  scoring_grid    = $c370$0,5 pt : conduite continue max 4 h 30. 0,5 pt : pause 45 min (bonus de justesse si fractionnement 15 + 30 cité). 0,5 pt : plafond journalier 9 h, 10 h max 2 fois/semaine. 0,5 pt : repos journalier 11 h, réductible à 9 h. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-M5-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Deux valeurs « 45 » structurent le temps de travail du conducteur, l'une en minutes, l'autre en heures.

a. 45 minutes : c'est la durée de la pause obligatoire après 4 h 30 de conduite continue (Règl. CE 561/2006). Elle peut être fractionnée en 15 minutes puis 30 minutes.

b. 45 heures : c'est la durée du repos hebdomadaire normal. Il est réductible à 24 heures (repos hebdomadaire réduit), la réduction devant ensuite être compensée.

Le piège pédagogique est de confondre les deux : 45 minutes concernent la pause dans la journée, 45 heures concernent le repos de la semaine.$c370$,
  scoring_grid    = $c370$1 pt : 45 minutes = pause obligatoire après 4 h 30 de conduite. 1 pt : 45 heures = repos hebdomadaire normal (réductible à 24 h). Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-M5-QC-02' AND type='qr';

-- ⚠️ FIMO-M5-QC-03 : [À CONFIRMER: les trois valeurs de 5 ans citées (FCO, CQC, carte conducteur du chronotachygraphe) sont réglementairement exactes et cohérentes avec l'énoncé « trois validités de 5 ans », mais l'intitulé exact des trois validités visées par le support de cours FIMO-M5 doit être confirmé ; une variante fréquente substitue le renouvellement quinquennal du permis poids lourd (visite médicale, jusqu'à 
UPDATE public.question_bank SET
  expected_answer = $c370$Trois documents ou obligations sont assortis d'une validité (ou d'une périodicité) de 5 ans dans l'activité du conducteur routier.

a. La FCO (Formation Continue Obligatoire) : elle doit être suivie tous les 5 ans pour maintenir le droit d'exercer la conduite à titre professionnel.

b. La carte de qualification de conducteur (CQC), qui matérialise la FIMO/FCO : sa durée de validité est de 5 ans (renouvelée à l'issue de chaque FCO).

c. La carte de conducteur du chronotachygraphe : sa durée de validité est de 5 ans, après quoi elle doit être renouvelée auprès de l'organisme émetteur.

À retenir : le rythme des 5 ans rythme à la fois la formation (FCO), le titre qui la prouve (CQC) et l'outil de contrôle du temps de conduite (carte conducteur).$c370$,
  scoring_grid    = $c370$Environ 0,67 pt (soit 2/3 de point) par validité correctement citée (FCO tous les 5 ans ; CQC valable 5 ans ; carte conducteur valable 5 ans), plafonné à 2 pts. Accepter, en remplacement de l'une d'elles, le renouvellement quinquennal du permis groupe lourd (visite médicale) si le stagiaire le justifie. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-M5-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Deux seuils d'alcoolémie encadrent la conduite et se distinguent par leur qualification juridique (taux mesurés dans le sang).

a. 0,5 g/L de sang (soit 0,25 mg/L d'air expiré) : de ce seuil jusqu'à moins de 0,8 g/L, l'infraction est une contravention. Elle est sanctionnée par une amende et un retrait de points sur le permis.

b. 0,8 g/L de sang (soit 0,40 mg/L d'air expiré) : à partir de ce seuil, l'infraction devient un délit, passible de peines plus lourdes (amende majorée, suspension ou annulation du permis, voire emprisonnement).

Rappel utile : pour les conducteurs de véhicules de transport en commun de personnes, le seuil est abaissé à 0,2 g/L ; la question porte toutefois sur les seuils généraux 0,5 et 0,8 g/L.$c370$,
  scoring_grid    = $c370$1 pt : 0,5 g/L = contravention (jusqu'à moins de 0,8 g/L). 1 pt : 0,8 g/L = délit. Bonus toléré sans point supplémentaire pour la conversion en air expiré (0,25 et 0,40 mg/L). Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-M5-QC-04' AND type='qr';

-- ⚠️ FIMO-M5-QC-05 : [À CONFIRMER: l'intitulé exact des « deux réflexes documentaires » attendus par le support FIMO-M5 n'est pas certain. L'interprétation retenue (contrôle/renseignement de la lettre de voiture à l'enlèvement, puis émargement/réserves à la livraison) est cohérente avec « de l'enlèvement à la livraison » et réglementairement juste, mais une lecture alternative viserait deux documents distincts, par ex
UPDATE public.question_bank SET
  expected_answer = $c370$Deux réflexes documentaires accompagnent chaque transport, de l'enlèvement de la marchandise jusqu'à sa livraison.

a. À l'enlèvement (chargement) : contrôler et renseigner le document de transport, la lettre de voiture (CMR à l'international). Le conducteur vérifie la conformité entre la marchandise et le document (nature, nombre de colis, poids), l'état apparent des marchandises et de l'emballage, et porte le cas échéant des réserves écrites dès le départ.

b. À la livraison : faire signer / émarger le document de transport par le destinataire et recueillir ses éventuelles réserves. Ce document daté et signé constitue la preuve de la bonne exécution de la livraison et protège juridiquement le transporteur.

Autrement dit, le même fil documentaire (la lettre de voiture) est renseigné et contrôlé au départ, puis émargé et assorti de réserves à l'arrivée.$c370$,
  scoring_grid    = $c370$1 pt : à l'enlèvement, contrôler / renseigner la lettre de voiture (document de transport, CMR) et porter des réserves si nécessaire. 1 pt : à la livraison, faire émarger le document et recueillir les réserves du destinataire (preuve de livraison). Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-M5-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Les trois mots de la réaction à un accident corporel, dans l'ordre : PROTÉGER, puis ALERTER, puis SECOURIR (moyen mnémotechnique « P.A.S. »).
  1. Protéger : supprimer ou isoler le danger (baliser, signaler, couper le contact) pour éviter le suraccident, sans se mettre soi-même en danger.
  2. Alerter : prévenir les secours (112 numéro d'urgence européen, 15 SAMU, 18 pompiers) en donnant un message précis (lieu, nature, nombre de victimes, état).
  3. Secourir : porter les premiers gestes de secours à la victime en attendant les secours.

b. Les deux délais de la déclaration d'accident du travail :
  - Le salarié (victime) dispose de 24 heures pour informer ou faire informer son employeur.
  - L'employeur dispose de 48 heures (dimanches et jours fériés non comptés) pour déclarer l'accident à la caisse primaire d'assurance maladie (CPAM).$c370$,
  scoring_grid    = $c370$a. Trois mots dans le bon ordre (Protéger, Alerter, Secourir) : 1 pt — 0,5 pt si un mot manque ou si l'ordre est erroné. b. Deux délais corrects (24 h salarié → employeur ; 48 h employeur → CPAM) : 1 pt — 0,5 pt par délai exact. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-M5-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$On l'appelle la plage (ou zone) verte du compte-tours, aussi désignée « zone économique » ou « plage de régime économique ». C'est la plage de régime moteur, généralement située autour du couple maximal, dans laquelle le moteur consomme le moins pour un rendement optimal. En conduite de croisière, on maintient l'aiguille du compte-tours dans cette zone verte et on utilise les rapports de boîte élevés pour y rester.$c370$,
  scoring_grid    = $c370$Réponse exacte « plage verte / zone verte (zone économique du compte-tours) » : 2 pts. 1 pt si la notion de zone/plage économique est évoquée sans la nommer « verte », ou si la réponse reste imprécise. 0 pt sinon. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T1-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$C'est le ralentisseur, aussi appelé frein continu ou frein d'endurance. Il permet de maintenir une vitesse stable dans une longue descente en produisant un couple de freinage permanent, sans solliciter les freins de service (mâchoires/plaquettes), ce qui évite leur échauffement et donc leur perte d'efficacité. On distingue notamment : le frein moteur, le ralentisseur sur l'échappement, le ralentisseur électromagnétique (type Telma) et le ralentisseur hydraulique (souvent intégré à la boîte). La bonne pratique consiste à aborder la descente à vitesse modérée, sur un rapport adapté, en utilisant le ralentisseur et en réservant les freins de service aux ralentissements ponctuels.$c370$,
  scoring_grid    = $c370$Réponse « ralentisseur » (ou frein continu / frein d'endurance) : 2 pts. 1 pt si seul « frein moteur » est cité sans la notion de ralentisseur/frein continu, ou si la réponse est partielle. 0 pt sinon. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T1-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Trois techniques d'éco-conduite (trois attendues parmi la liste suivante) :
  1. Anticiper la circulation : regarder loin, adapter son allure au trafic et aux feux pour éviter les accélérations et freinages brusques (conduite souple).
  2. Utiliser l'inertie du véhicule : lever le pied à l'approche d'un ralentissement ou d'une descente et rouler sur l'élan plutôt que d'accélérer puis freiner.
  3. Conduire dans la plage verte (régime économique) : passer rapidement les rapports supérieurs et rouler au régime le plus bas possible pour la vitesse souhaitée.
Autres réponses acceptées : maintenir une vitesse stable / utiliser le régulateur de vitesse ; couper le moteur lors des arrêts prolongés (éviter le ralenti inutile) ; contrôler la pression des pneumatiques ; limiter la résistance aérodynamique (déflecteurs, bâchage) ; entretenir régulièrement le véhicule.$c370$,
  scoring_grid    = $c370$Trois techniques d'éco-conduite valables et distinctes : 2 pts (environ 0,67 pt par technique). 1 pt si seulement une ou deux techniques correctes. 0 pt sinon. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T1-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$On l'appelle le fading (ou « fading des freins »). C'est la perte d'efficacité des freins de service provoquée par la surchauffe des garnitures et des disques/tambours lors d'un freinage prolongé ou répété, typiquement dans une longue descente. Sous l'effet de la chaleur, le coefficient de frottement chute et la course de la pédale s'allonge : le véhicule freine de moins en moins bien. La prévention consiste à utiliser le ralentisseur / frein continu et un rapport de boîte adapté pour préserver les freins de service.$c370$,
  scoring_grid    = $c370$Réponse « le fading » : 2 pts. 1 pt si la description (surchauffe entraînant la perte d'efficacité) est correcte mais le terme « fading » n'est pas donné. 0 pt sinon. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T1-QC-04' AND type='qr';

-- ⚠️ FIMO-T1-QC-05 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER: la plage de couple maximal (~1000 à 1500 tr/min / "zone verte") varie selon le moteur ; à ajuster sur la valeur exacte retenue par le support de formation.]
UPDATE public.question_bank SET
  expected_answer = $c370$On dit qu'un poids lourd moderne se conduit « au couple » parce que son moteur diesel développe son couple maximal (sa force de traction) dès les bas régimes, et non à haut régime comme on l'imaginerait.

a. Principe mécanique : le couple est la force de rotation que le moteur transmet aux roues. Sur un diesel suralimenté récent, ce couple maximal est disponible sur une plage de régimes basse et large (typiquement autour de 1 000 à 1 500 tr/min). C'est cette force, et non la vitesse de rotation, qui fait avancer et reprendre le véhicule en charge.

b. Conséquence pratique (éco-conduite) : le conducteur exploite cette plage économique (la « zone verte » du compte-tours) en passant les rapports tôt et en montant vite au rapport supérieur. Il laisse le couple « tirer » à bas régime plutôt que de faire monter le moteur dans les tours. Résultat : consommation, usure, bruit et émissions réduits, tout en conservant la puissance nécessaire.$c370$,
  scoring_grid    = $c370$a. Identifier que le couple maximal est disponible à bas régime et que c'est lui (et non le haut régime) qui tracte : 1 pt. b. En déduire la conduite associée — passer les rapports tôt, rester dans la plage économique / zone verte, laisser le couple tirer (bénéfice éco-conduite) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T1-QC-05' AND type='qr';

-- ⚠️ FIMO-T1-QC-06 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Ce que garantit l'ABS (système antiblocage des roues) : lors d'un freinage d'urgence, l'ABS empêche le blocage des roues. En conservant la rotation des roues, il maintient l'adhérence directionnelle : le véhicule reste dirigeable et le conducteur peut continuer à braquer pour esquiver un obstacle et garder la trajectoire. Il évite aussi la mise en portefeuille d'un ensemble articulé.

b. Ce que l'ABS ne fait PAS : il ne réduit pas la distance d'arrêt. L'ABS n'est pas une aide au freinage plus court ; sur certaines surfaces (gravier, neige, sol meuble) il peut même légèrement allonger la distance de freinage. Il ne dispense donc jamais de respecter les distances de sécurité ni d'anticiper.$c370$,
  scoring_grid    = $c370$a. Ce que l'ABS garantit — empêche le blocage des roues et conserve le contrôle directionnel (pouvoir braquer/diriger, esquiver) : 1 pt. b. Ce qu'il ne fait pas — ne raccourcit pas la distance d'arrêt (peut même l'allonger sur sol meuble) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T1-QC-06' AND type='qr';

-- ⚠️ FIMO-T1-QC-07 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER: la formulation "vitesse inférieure ou égale à celle à laquelle on gravirait la côte" est la règle mnémotechnique usuelle ; vérifier le libellé exact attendu par le référentiel de la formation.]
UPDATE public.question_bank SET
  expected_answer = $c370$Règle de vitesse pour aborder une longue descente en charge :

a. On aborde une descente à une vitesse maîtrisée, inférieure ou égale à celle à laquelle on gravirait cette même côte. La vitesse doit être réduite AVANT d'entrer dans la descente, et non pendant.

b. On engage un rapport suffisamment bas (le même, ou proche, que celui utilisé pour monter la pente) afin de bénéficier du frein moteur et des ralentisseurs (frein sur échappement, ralentisseur hydraulique ou électromagnétique). Le frein de service ne sert qu'en appoint, par actions brèves et espacées : l'utiliser en continu provoque l'échauffement et la perte d'efficacité des freins (fading). En charge, l'énergie à dissiper étant bien plus grande, cette règle est impérative.$c370$,
  scoring_grid    = $c370$a. Énoncer la règle de vitesse — aborder la descente à vitesse réduite, inférieure/égale à celle de montée, et ralentir AVANT la descente : 1 pt. b. Compléter par le rapport bas engagé + frein moteur/ralentisseur (frein de service en appoint seulement, éviter le fading) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T1-QC-07' AND type='qr';

-- ⚠️ FIMO-T1-QC-08 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER: le coefficient de poussée vers l'avant. EN 12195-1 retient 0,8 g → ≈ 8 tonnes-force pour 10 t. Certains supports FIMO enseignent "une force égale au poids" → 10 t. Retenir la valeur exacte attendue par le barème de la formation avant validation.]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Principe : en freinage d'urgence, la décélération est brutale et le chargement, par inertie, poursuit son mouvement vers l'avant. Un chargement mal (ou non) arrimé exerce alors sur la cloison / les moyens d'arrimage une poussée considérable dirigée vers l'avant.

b. Ordre de grandeur pour 10 tonnes : selon la norme d'arrimage EN 12195-1, on retient vers l'avant une décélération de l'ordre de 0,8 g. La poussée vaut alors environ 0,8 x 10 t, soit près de 8 tonnes-force. De nombreux supports pédagogiques arrondissent en disant que la charge « pèse » vers l'avant l'équivalent de son propre poids, soit jusqu'à 10 tonnes projetées vers la cabine. Dans les deux cas, la conclusion est la même : la force en jeu est de l'ordre de plusieurs tonnes, capable de défoncer la cloison de séparation et d'écraser la cabine, d'où l'obligation d'un arrimage dimensionné en conséquence.$c370$,
  scoring_grid    = $c370$a. Expliquer le phénomène — inertie : la charge continue vers l'avant et pousse contre la cabine lors du freinage : 1 pt. b. Donner l'ordre de grandeur chiffré (≈ 0,8 x le poids ≈ 8 t selon EN 12195-1, ou jusqu'à ≈ son poids soit 10 t selon le support) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T1-QC-08' AND type='qr';

-- ⚠️ FIMO-T1-QC-09 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Mécanisme : lorsque le conducteur lève le pied de l'accélérateur en laissant un rapport engagé, ce sont les roues qui, par l'inertie du véhicule, entraînent le moteur (et non l'inverse). Le moteur tourne donc sans avoir besoin d'être alimenté.

b. Coupure d'injection : détectant cette phase de décélération (pied levé, régime au-dessus du ralenti, rapport engagé), le calculateur d'injection coupe l'alimentation en carburant. Aucun gasoil n'est injecté : la consommation instantanée est quasi nulle. C'est l'effet de frein moteur.

c. Comparaison / enseignement éco-conduite : au point mort ou débrayé en descente, le moteur doit au contraire être alimenté pour tourner au ralenti et consomme donc du carburant. D'où la consigne : décélérer et retenir le véhicule rapport engagé (frein moteur) plutôt que débrayé, ce qui économise du carburant et sécurise la conduite.$c370$,
  scoring_grid    = $c370$a/b. Identifier la coupure d'injection en décélération — roues entraînant le moteur, calculateur coupant l'alimentation carburant (frein moteur), donc consommation nulle : 1 pt. c. Opposer au point mort/débrayé où le moteur consomme au ralenti, et en tirer la consigne d'éco-conduite : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T1-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Une sangle d'arrimage doit être retirée du service (mise au rebut) dès qu'elle présente l'un des défauts suivants ; il suffit d'en citer trois :

1. Coupures, déchirures ou entailles des fibres portantes de la sangle textile, ainsi qu'un effilochage important des bords.
2. Coutures de sécurité rompues ou arrachées (les fils de couture témoins servent justement d'indicateur d'usure).
3. Dommages dus à la chaleur, aux frottements ou aux UV : fibres fondues, brûlées, durcies ou décolorées.
4. Attaque par des produits chimiques (acides, bases, solvants) : taches, fragilisation, décoloration de la matière.
5. Élément métallique (cliquet-tendeur, crochets, boucle) déformé, fissuré, corrodé ou dont le mécanisme ne bloque plus.
6. Étiquette d'identification absente ou illisible (on ne connaît plus la charge admissible LC / la capacité de tension).

Toute sangle présentant un de ces défauts ne garantit plus sa résistance nominale : elle doit être remplacée et ne jamais être réparée par un nœud.$c370$,
  scoring_grid    = $c370$3 défauts valables attendus. 0,67 pt par défaut correctement cité et justifié (arrondi : 2 défauts = 1,5 pt ; 3 défauts = 2 pts). Total = 2 pts. Aucun point pour un défaut hors sujet (ex. sangle simplement sale mais intacte).$c370$
WHERE source_ref = 'FIMO-T1-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La pause devient obligatoire après 4 h 30 de conduite cumulée (temps de conduite continue ou additionné). Sa durée est de 45 minutes.

Cette pause de 45 minutes peut être prise en une seule fois ou fractionnée en deux périodes : d'abord une pause d'au moins 15 minutes, puis une pause d'au moins 30 minutes, à placer de manière à ce que la conduite n'excède jamais 4 h 30 sans avoir soldé les 45 minutes. Pendant la pause, le conducteur ne doit effectuer aucune conduite ni aucun autre travail ; ce temps est exclusivement consacré au repos.$c370$,
  scoring_grid    = $c370$1 pt : seuil de 4 h 30 de conduite cumulée. 1 pt : durée de 45 minutes (le fractionnement correct 15 min + 30 min est valorisé au sein de ce point, sans dépasser le total de 2 pts). Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T2-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$À l'arrêt (véhicule immobilisé), le sélecteur d'activités du chronotachygraphe se positionne sur l'une des trois positions suivantes :

a. Autre travail (symbole : deux marteaux croisés). Toute activité professionnelle autre que la conduite. Exemple : chargement ou déchargement du camion, manutention, contrôle du véhicule, formalités administratives ou douanières, nettoyage.

b. Disponibilité / mise à disposition (symbole : carré barré ou losange). Temps d'attente dont le conducteur connaît la durée à l'avance et pendant lequel il n'a pas à travailler, mais reste à disposition. Exemple : attente au quai lors du chargement effectué par autrui, attente à la douane ou au ferry, temps passé à côté du conducteur (double équipage) pendant que l'autre conduit.

c. Repos / coupure (symbole : lit ou chaise). Temps pendant lequel le conducteur dispose librement de son temps. Exemple : pause déjeuner, coupure de 45 minutes, repos journalier.$c370$,
  scoring_grid    = $c370$3 positions à identifier avec un exemple. 0,67 pt par position correctement nommée ET assortie d'un exemple pertinent (position seule sans exemple = 0,33 pt). Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T2-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$En excluant les titres personnels du conducteur (permis, carte de qualification/FIMO-FCO) et les papiers propres au véhicule (carte grise, contrôle technique, assurance), les documents liés au transport devant se trouver à bord sont :

1. Le document de transport de la marchandise : lettre de voiture (CMR à l'international, lettre de voiture nationale) ou récépissé, éventuellement accompagné du bon de livraison.
2. La copie certifiée conforme de la licence communautaire (ou la licence de transport intérieur pour les trajets nationaux) autorisant l'entreprise à effectuer le transport.
3. Les enregistrements du chronotachygraphe : la carte de conducteur en cours d'utilisation et les données/feuilles couvrant la journée en cours ainsi que les 28 jours précédents (avec, le cas échéant, l'attestation d'activité justifiant les jours sans conduite).
4. Le cas échéant, si la marchandise le nécessite : les documents ADR (transport de matières dangereuses : document de transport ADR et consignes écrites de sécurité) ou les documents sanitaires/douaniers propres au chargement.

Citer les documents de transport (lettre de voiture), la licence de transport et les enregistrements du tachygraphe couvre l'essentiel attendu.$c370$,
  scoring_grid    = $c370$1 pt : document de transport de la marchandise (lettre de voiture / CMR, bon de livraison). 0,5 pt : copie de la licence communautaire / de transport. 0,5 pt : enregistrements du chronotachygraphe (carte conducteur + jour courant et 28 jours précédents). Bonus fusionné (documents ADR le cas échéant) valorisé sans dépasser 2 pts. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T2-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le chargement d'un camion au hayon compte comme du travail (activité « autre travail », symbole des deux marteaux croisés au chronotachygraphe).

Au sens de la réglementation sociale européenne (Règl. CE 561/2006), constitue de l'« autre travail » toute activité professionnelle exercée par le conducteur en dehors de la conduite : les opérations de chargement et de déchargement, la manutention au hayon élévateur, l'arrimage en font partie. Ce temps ne peut donc être décompté ni comme pause ni comme repos, puisque le conducteur n'y dispose pas librement de son temps : il doit basculer le sélecteur sur la position « autre travail ». En conséquence, ce temps s'ajoute au temps de service et n'interrompt pas le décompte des 4 h 30 de conduite au titre d'une pause.$c370$,
  scoring_grid    = $c370$1,5 pt : réponse « travail » (autre travail) clairement identifiée. 0,5 pt : justification (le conducteur ne dispose pas librement de son temps / ne compte ni comme pause ni comme repos / position deux marteaux). Total = 2 pts. Réponse « pause » ou « repos » = 0 pt.$c370$
WHERE source_ref = 'FIMO-T2-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$En cas de vol de la carte de conducteur en cours de déplacement, le conducteur peut poursuivre son trajet pendant 15 jours au maximum (ou plus longtemps si c'est nécessaire pour ramener le véhicule à l'entreprise), à condition d'assurer manuellement l'enregistrement de son activité. Les deux gestes immédiats côté enregistrement sont :

a. Imprimer les données du chronotachygraphe en début et en fin de trajet (relevés papier justifiant l'activité tant que la carte est absente).

b. Porter sur ces tickets les mentions manuscrites permettant l'identification du conducteur (nom, prénom, numéro de permis ou de carte) et les signer.

(Ces gestes d'enregistrement s'accompagnent, sur le plan administratif, de la déclaration du vol aux autorités et de la demande de carte de remplacement sous 7 jours calendaires, mais la question porte sur le seul volet enregistrement.)$c370$,
  scoring_grid    = $c370$a. Impression des relevés en début et fin de trajet : 1 pt. b. Mentions manuscrites d'identification + signature sur les tickets : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T2-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Six périodes de 24 heures au maximum peuvent s'écouler entre la fin d'un repos hebdomadaire et le début du repos hebdomadaire suivant. Autrement dit, le conducteur doit avoir entamé son repos hebdomadaire au plus tard à la fin de la sixième période de 24 heures décomptée depuis la fin du précédent repos hebdomadaire (règlement CE 561/2006, art. 8). En pratique, cela impose au moins un repos hebdomadaire tous les six jours de travail.$c370$,
  scoring_grid    = $c370$Réponse « 6 périodes de 24 h » : 2 pts (1 pt si la réponse est approchée ou correctement justifiée mais chiffre inexact ; 0 sinon). Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T2-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$À la livraison, deux gestes sur la lettre de voiture (CMR) protègent l'entreprise en constituant la preuve de la bonne exécution du transport et en préservant les recours :

a. Faire dater et signer la lettre de voiture par le destinataire au moment de la réception : cela vaut accusé de réception et preuve de livraison, opposable en cas de contestation ultérieure.

b. Faire porter par le destinataire des réserves écrites précises et motivées sur la lettre de voiture en cas d'avarie, de manquant ou de retard constaté à la livraison (nature et étendue du dommage). À défaut de réserves motivées émises au moment de la livraison, la marchandise est réputée reçue en bon état, ce qui prive l'entreprise et son assureur de recours.$c370$,
  scoring_grid    = $c370$a. Faire dater et signer la lettre de voiture par le destinataire (preuve de livraison) : 1 pt. b. Faire consigner des réserves écrites précises et motivées en cas d'avarie/manquant : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T2-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Créneau d'interdiction : un poids lourd de plus de 7,5 tonnes de PTAC transportant de la marchandise générale ne peut pas circuler le week-end du samedi 22 heures au dimanche 22 heures (interdiction générale de circulation, à laquelle s'ajoutent la veille des jours fériés à partir de 22 h et le jour férié lui-même jusqu'à 22 h).

b. Conduite à tenir si la tournée du samedi risque de déborder : anticiper l'organisation pour terminer et être stationné avant 22 heures le samedi ; prévenir immédiatement l'exploitation afin de réaménager la tournée ; à défaut, marquer l'arrêt sur une aire adaptée et ne reprendre la route qu'après la levée de l'interdiction (dimanche 22 heures). Ne jamais rouler pendant le créneau interdit sans dérogation valable, sous peine de sanction. Cette gestion doit rester compatible avec les temps de conduite et de repos du règlement 561/2006.$c370$,
  scoring_grid    = $c370$a. Créneau samedi 22 h → dimanche 22 h (véhicule > 7,5 t) : 1 pt. b. Conduite à tenir : terminer/stationner avant 22 h le samedi, prévenir l'exploitation, ne pas rouler pendant l'interdiction : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T2-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Principe : le repos journalier fractionné consiste à prendre le repos journalier normal en deux tranches sur la période de 24 heures. La première période est d'au moins 3 heures consécutives et la seconde d'au moins 9 heures consécutives (règlement CE 561/2006, art. 4). Aucune autre décomposition n'est admise pour ce fractionnement.

b. Durée totale : en additionnant les deux tranches (3 h + 9 h), le repos journalier fractionné atteint au minimum 12 heures, soit une durée supérieure au repos journalier normal non fractionné de 11 heures.$c370$,
  scoring_grid    = $c370$a. Fractionnement en deux périodes de 3 h puis 9 h minimum : 1 pt. b. Durée totale minimale de 12 h : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T2-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Pourquoi ce décalage ?
Le chronotachygraphe numérique enregistre et affiche par défaut le temps universel coordonné (UTC), c'est-à-dire l'heure de référence internationale, alors que votre montre indique l'heure légale locale. En France, l'heure légale est en avance sur l'UTC : UTC+1 en heure d'hiver et UTC+2 en heure d'été. Il est donc normal de constater un écart d'une ou deux heures entre l'affichage de l'appareil (en UTC) et votre montre (heure locale). Ce décalage n'est pas une panne : l'UTC garantit une base horaire commune et incontestable pour tous les contrôles, quel que soit le pays traversé.

b. Quelle précaution en tirer ?
Le conducteur doit connaître le décalage en vigueur (1 h en hiver, 2 h en été) et en tenir compte à chaque saisie manuelle (début/fin de service, lieux, activités hors véhicule), afin de ne pas décaler ses saisies et créer une infraction apparente. L'heure locale n'est qu'une aide à la lecture affichée à l'écran ; ce sont bien les durées et horaires en UTC qui font foi lors d'un contrôle. Vérifier également que l'heure UTC de l'appareil reste juste (elle est resynchronisée automatiquement, mais une dérive doit être signalée pour réparation).$c370$,
  scoring_grid    = $c370$a. Identification du décalage UTC (temps de l'appareil) vs heure légale locale de la montre, avec l'écart +1 h/+2 h selon la saison : 1 pt. b. Précaution : tenir compte du décalage lors des saisies manuelles / l'UTC fait foi au contrôle : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T2-QC-10' AND type='qr';

-- ⚠️ FIMO-T3-QC-01 : [À CONFIRMER: la durée exacte attendue par le référentiel FIMO-FCO ; la valeur « 15 à 20 minutes » est la recommandation standard de sécurité routière (sieste flash), mais vérifier si le support de cours attend précisément « 20 minutes ». La fourchette 15-20 min est acceptée au barème.]
UPDATE public.question_bank SET
  expected_answer = $c370$Face aux premiers signes de fatigue au volant (bâillements, paupières lourdes, difficulté à fixer la route, perte de vigilance), la seule réponse efficace est de s'arrêter dans un endroit sûr (aire de repos, parking) et de faire une sieste courte, dite « sieste flash », d'une durée de l'ordre de 15 à 20 minutes.

Justification : au-delà de 20 minutes environ, on entre dans un sommeil profond et le réveil s'accompagne d'une inertie (somnolence résiduelle) qui rend la reprise de la conduite dangereuse. Une sieste de 15 à 20 minutes suffit à restaurer un niveau de vigilance correct sans provoquer cette inertie. Ni le café, ni la musique, ni l'ouverture de la fenêtre ne remplacent le sommeil : ils ne font que masquer la fatigue quelques minutes. La sieste s'articule aussi avec la réglementation (pause obligatoire de 45 minutes après 4 h 30 de conduite continue), mais dès les premiers signes de somnolence, l'arrêt doit être immédiat sans attendre l'échéance des 4 h 30.$c370$,
  scoring_grid    = $c370$Durée correcte de la sieste de récupération : environ 15 à 20 minutes : 1 pt. Justification (éviter le sommeil profond et l'inertie au réveil / s'arrêter dans un lieu sûr) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T3-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La règle des « trois points d'appui » s'applique à chaque montée et descente de la cabine (ou d'accès au véhicule, à la remorque, à la citerne, etc.). Elle impose de conserver en permanence trois points de contact avec le véhicule parmi les quatre membres :
- soit deux mains et un pied,
- soit deux pieds et une main,
de sorte qu'à tout instant seul un membre se déplace tandis que les trois autres assurent la stabilité.

En pratique : on monte et on descend face au véhicule (jamais dos au vide), en utilisant les marchepieds et les poignées prévus, mains libres (pas de charge, de téléphone ni de clés dans les mains), et l'on ne saute jamais de la cabine. Cette règle prévient les chutes de plain-pied et de hauteur, qui figurent parmi les premières causes d'accidents et de lésions (chevilles, genoux, dos) chez les conducteurs.$c370$,
  scoring_grid    = $c370$Énoncé du principe : conserver en permanence 3 points de contact (2 mains + 1 pied ou 2 pieds + 1 main), un seul membre se déplaçant à la fois : 1 pt. Application correcte : monter/descendre face au véhicule, mains libres, ne pas sauter : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T3-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Quel numéro appeler ?
En cas d'accident corporel, on compose le 112, numéro d'appel d'urgence unique européen, joignable gratuitement depuis tout téléphone dans l'ensemble de l'Union européenne. En France, on peut aussi appeler le 18 (sapeurs-pompiers) ou le 15 (SAMU) ; le 112 est toutefois à privilégier, notamment lors des déplacements à l'étranger.

b. Quelle information donner en premier ?
La première information à transmettre est la localisation précise de l'accident : autoroute ou route et son numéro, sens de circulation, point kilométrique (borne PK) ou repère le plus proche, commune. C'est l'élément indispensable pour que les secours soient acheminés sans délai, avant même de décrire le nombre de victimes et leur état, la nature de l'accident et les éventuels dangers (incendie, matières dangereuses).

Cette démarche s'inscrit dans la conduite à tenir « Protéger, Alerter, Secourir » : baliser et sécuriser les lieux, puis alerter, puis porter secours dans la limite de ses compétences.$c370$,
  scoring_grid    = $c370$a. Numéro d'urgence correct : 112 (ou 18 / 15 acceptés) : 1 pt. b. Première information : la localisation exacte de l'accident (route/PK/commune/sens) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T3-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les boîtes de médicaments portent un pictogramme triangulaire de mise en garde vis-à-vis de la conduite, décliné en trois niveaux de couleur et de risque croissants. La question porte sur les niveaux 2 et 3 :

Niveau 2 (triangle orange) : « Soyez très prudent. Ne pas conduire sans l'avis d'un professionnel de santé. » Le médicament peut altérer l'aptitude à conduire ; la conduite reste possible mais seulement après avoir demandé conseil à un médecin ou à un pharmacien, qui apprécie l'effet du produit sur le patient.

Niveau 3 (triangle rouge) : « Attention, danger : ne pas conduire. Pour la reprise de la conduite, demandez l'avis d'un médecin. » Le risque est majeur : la conduite est contre-indiquée pendant le traitement, et la reprise ne peut se faire qu'après avis médical explicite.

(Pour mémoire, le niveau 1, triangle jaune, signifie « Soyez prudent, ne pas conduire sans avoir lu la notice ».) Pour un conducteur professionnel, tout médicament portant un pictogramme de niveau 2 ou 3 impose de vérifier son aptitude auprès d'un professionnel de santé avant de prendre le volant.$c370$,
  scoring_grid    = $c370$Niveau 2 (triangle orange) : ne pas conduire sans l'avis d'un professionnel de santé : 1 pt. Niveau 3 (triangle rouge) : ne pas conduire / reprise sur avis médical : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T3-QC-04' AND type='qr';

-- ⚠️ FIMO-T3-QC-05 : [NON VÉRIFIÉ — relecture formateur requise] Fourchette 0,10 à 0,15 g/L/h communément enseignée en formation ; réponse acceptée si l'apprenant cite une valeur dans cette plage. Seuil 0,2 g/L pour conducteurs professionnels rappelé à titre de contexte.
UPDATE public.question_bank SET
  expected_answer = $c370$L'organisme élimine l'alcool très lentement, à un rythme d'environ 0,10 à 0,15 g/L de sang par heure en moyenne (souvent retenu autour de 0,15 g/L/h). Points essentiels attendus :

a. Vitesse d'élimination : l'alcoolémie ne baisse que d'environ 0,10 à 0,15 g par litre et par heure. À titre d'ordre de grandeur, il faut donc de l'ordre d'une heure à une heure et demie pour éliminer l'alcool contenu dans un seul verre standard (environ 0,20 à 0,25 g/L par verre).

b. Conséquence pratique pour le conducteur : rien n'accélère cette élimination (ni café, ni douche froide, ni air frais, ni effort physique). Seul le temps fait baisser l'alcoolémie. Un conducteur ayant bu la veille au soir peut donc rester au-dessus du seuil légal le lendemain matin au moment de la prise de service. Rappel du seuil applicable au transport routier : 0,2 g/L de sang (régime « quasi zéro » pour les conducteurs professionnels), contre 0,5 g/L pour le régime général.$c370$,
  scoring_grid    = $c370$a. Vitesse d'élimination correcte (~0,10 à 0,15 g/L par heure) : 1,5 pt. b. Conséquence pratique juste (seul le temps agit / risque le lendemain matin) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T3-QC-05' AND type='qr';

-- ⚠️ FIMO-T3-QC-06 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Trois EPI (équipements de protection individuelle) attendus pour les opérations réalisées hors de la cabine (attelage/dételage, bâchage/débâchage, arrimage, contrôle du chargement, intervention sur le bord de route) :

a. Le gilet de haute visibilité (rétroréfléchissant), obligatoire dès que le conducteur descend du véhicule sur ou aux abords de la chaussée, pour être vu des autres usagers.

b. Les chaussures de sécurité (à coquille, semelle antidérapante et anti-perforation), contre les chutes de charge, les écrasements et les glissades.

c. Les gants de manutention/protection, contre les coupures, pincements et agressions mécaniques lors de la manipulation des sangles, ridelles, béquilles et attelages.

Toute autre réponse pertinente est acceptée : casque ou lunettes de protection selon l'opération, vêtements adaptés, protection auditive en environnement bruyant.$c370$,
  scoring_grid    = $c370$Trois EPI valables cités : 0,67 pt par EPI correct (barème arrondi à 2 pts pour trois réponses justes). Deux EPI justes : ~1,3 pt ; un seul : ~0,7 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T3-QC-06' AND type='qr';

-- ⚠️ FIMO-T3-QC-07 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Le constat amiable tire sa force probante (sa valeur de preuve reconnue par les assureurs) du fait qu'il est rempli et validé contradictoirement sur les lieux, immédiatement après le choc. Quatre éléments attendus parmi les suivants :

a. Les signatures des deux conducteurs : elles matérialisent l'accord des parties sur les faits décrits ; un constat non signé par l'adversaire perd sa force probante.

b. La concordance des déclarations : les cases de circonstances cochées et les mentions des deux parties doivent être cohérentes entre elles (accord sur le déroulement).

c. Le croquis de l'accident : position des véhicules, sens de circulation, signalisation, qui doit être cohérent avec les cases cochées.

d. Les circonstances cochées (les cases numérotées) : décrivant précisément la manœuvre de chaque véhicule au moment du choc.

Autres éléments recevables : la date et l'heure, le lieu exact, l'identité des témoins, l'absence de rature ou de surcharge, le point de choc initial indiqué par la flèche. La règle d'or : une fois signé, le constat ne peut plus être modifié.$c370$,
  scoring_grid    = $c370$Quatre éléments valables cités : 0,5 pt chacun. Total = 2 pts. (Signatures des deux parties, concordance/cases cochées, croquis, date-lieu, témoins, absence de rature : toute combinaison de quatre éléments pertinents est acceptée.)$c370$
WHERE source_ref = 'FIMO-T3-QC-07' AND type='qr';

-- ⚠️ FIMO-T3-QC-08 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$En zone sensible (aires isolées, ports, approche du tunnel ou des ferries transmanche type Calais/Dunkerque, parkings non sécurisés), le contrôle anti-intrusion de la remorque (recherche de personnes cachées ou de dégradation des dispositifs de fermeture) doit être réalisé à chaque rupture de surveillance du véhicule. Moments attendus :

a. Avant le départ / au moment de la prise en charge de la remorque, pour partir d'un état de référence connu et scellé.

b. Après chaque arrêt où le véhicule a été laissé sans surveillance : pause, repas, repos, ravitaillement en carburant.

c. À chaque retour au véhicule (dès que l'on remonte à bord après s'être éloigné).

d. Juste avant l'entrée dans la zone contrôlée sensible : avant l'embarquement sur un ferry ou l'entrée du tunnel, avant le passage d'une frontière, à l'approche des zones connues pour les intrusions.

À chaque contrôle : vérifier l'intégrité des scellés/plombs, de la bâche, des portes et du système de fermeture (TIR/cadenas), et inspecter dessous et pourtour du véhicule.$c370$,
  scoring_grid    = $c370$Moments correctement identifiés : avant le départ (0,5 pt), après chaque arrêt sans surveillance / pause (0,5 pt), à chaque retour au véhicule (0,5 pt), avant l'entrée en zone contrôlée / embarquement ferry-tunnel-frontière (0,5 pt). Total = 2 pts. Deux moments pertinents suffisent pour la moitié des points.$c370$
WHERE source_ref = 'FIMO-T3-QC-08' AND type='qr';

-- ⚠️ FIMO-T3-QC-09 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Il ne faut jamais écrire une formule du type « je ne vous avais pas vu, désolé » sur un constat car :

a. C'est une reconnaissance de responsabilité (aveu de faute). Le constat sert à décrire objectivement des faits et des circonstances (cases et croquis), pas à s'excuser ni à s'accuser. Une telle phrase reconnaît explicitement un défaut de vigilance et vous désigne comme responsable.

b. Cette mention est opposable et engage votre assureur (et donc, en tant que conducteur professionnel, votre employeur) : elle peut faire basculer la répartition des torts à 100 % contre vous, alourdir le malus et compromettre la prise en charge, indépendamment de la réalité juridique de l'accident.

c. La détermination des responsabilités relève des assureurs à partir des circonstances cochées et du croquis, pas d'une appréciation personnelle ou d'une politesse portée sur le document. En résumé : sur un constat, on décrit, on ne s'excuse pas et on ne reconnaît jamais sa faute par écrit.$c370$,
  scoring_grid    = $c370$a. Identifier qu'il s'agit d'une reconnaissance de responsabilité / aveu de faute : 1 pt. b. En expliquer la conséquence (torts contre soi, engage l'assureur, compromet l'indemnisation) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T3-QC-09' AND type='qr';

-- ⚠️ FIMO-T3-QC-10 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Contexte : découverte de personnes cachées dans la remorque (passagers clandestins). Le conducteur n'a aucun pouvoir de police et sa sécurité, comme celle des personnes, prime.

a. Les deux interdits :
1) Ne jamais recourir à la force ni exercer de violence à l'égard des personnes découvertes (pas de contrainte physique, pas de geste agressif).
2) Ne jamais reprendre la route avec ces personnes à bord et ne pas les laisser s'enfuir : on n'organise ni leur transport, ni leur fuite, on n'entre pas dans un arrangement.

b. Les deux gestes corrects :
1) Alerter immédiatement les forces de l'ordre (police / gendarmerie, 17 ou 112) et prévenir son entreprise / exploitation.
2) Immobiliser et sécuriser le véhicule sur place, garder ses distances sans se mettre en danger, et attendre l'intervention des autorités sans détruire d'indices.$c370$,
  scoring_grid    = $c370$a. Deux interdits cités : 1 pt (0,5 pt par interdit correct). b. Deux gestes corrects cités : 1 pt (0,5 pt par geste correct). Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T3-QC-10' AND type='qr';

-- ⚠️ FIMO-T4-QC-01 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Le geste qui prévient l'essentiel des litiges est le contrôle contradictoire de la marchandise à la livraison, effectué conjointement avec le réceptionnaire AVANT de signer.

En pratique : vérifier ensemble la quantité (comptage des colis / palettes) et l'état apparent (emballages, traces de choc, humidité) au moment de la remise, puis, si un écart ou une avarie est constaté, porter des réserves précises, écrites, datées et complètes sur le document de livraison (bon de livraison / récépissé) avant la signature des deux parties. Des réserves claires et contradictoires figées avant signature rendent la responsabilité opposable et évitent les contestations ultérieures.$c370$,
  scoring_grid    = $c370$Identification du geste = contrôle contradictoire de la marchandise avec le réceptionnaire avant signature : 1 pt. Précision de l'action (vérification quantité/état ET inscription de réserves précises avant de signer) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T4-QC-01' AND type='qr';

-- ⚠️ FIMO-T4-QC-02 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$On l'appelle le sous-traitant, également désigné comme le transporteur affrété (ou « affrété »). C'est le transporteur qui exécute matériellement le transport pour le compte d'un donneur d'ordre (commissionnaire de transport ou autre transporteur), lequel reste responsable vis-à-vis du client final. Le donneur d'ordre qui confie l'opération est l'affréteur ; celui qui la réalise en sous-traitance est le sous-traitant / affrété.$c370$,
  scoring_grid    = $c370$Terme correct « sous-traitant » (ou « transporteur affrété ») : 2 pts. Réponse approchante mais imprécise / confusion avec l'affréteur : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T4-QC-02' AND type='qr';

-- ⚠️ FIMO-T4-QC-03 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Le conducteur est le représentant de l'entreprise chez le client : sa présentation conditionne l'image perçue. Trois éléments attendus (parmi) :
1) La tenue vestimentaire : propre, correcte et adaptée (tenue de l'entreprise si elle existe), sans négligence.
2) L'hygiène personnelle et le comportement : propreté, politesse, courtoisie, langage correct, amabilité envers le réceptionnaire.
3) La propreté et l'état du véhicule : camion propre, en bon état, aux couleurs / logos de l'entreprise.

Autres éléments recevables : la ponctualité et le respect des horaires de rendez-vous ; le respect des consignes du site (circulation, EPI, zones de livraison).$c370$,
  scoring_grid    = $c370$Trois éléments valables cités (tenue, hygiène/comportement, propreté du véhicule, ponctualité, respect des consignes...) : 2 pts au total, soit environ 0,66 pt par élément correct. Deux éléments seulement : 1 pt. Un seul : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T4-QC-03' AND type='qr';

-- ⚠️ FIMO-T4-QC-04 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Parce que l'émargement (signature datée du réceptionnaire sur le bon de livraison / récépissé) est la preuve de la livraison et de la remise de la marchandise au destinataire.

Sans émargement :
1) Le transporteur ne peut pas prouver qu'il a effectivement livré : sa responsabilité reste engagée et il peut être tenu pour responsable d'une perte, d'un manquant ou d'une non-livraison, même s'il a « rendu service ».
2) Il n'y a aucune décharge de responsabilité ni date de remise opposable : en cas de litige, de vol ou de contestation (« je n'ai rien reçu »), le conducteur et l'entreprise n'ont aucun élément probant et s'exposent à des réclamations et à des refus de paiement.

Déposer « pour dépanner » sans faire signer revient donc à livrer sans preuve : c'est à proscrire, quelle que soit la bonne volonté.$c370$,
  scoring_grid    = $c370$L'émargement est la preuve de la livraison / remise : 1 pt. Conséquence de son absence (responsabilité du transporteur engagée, aucune décharge ni preuve opposable en cas de litige) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T4-QC-04' AND type='qr';

-- ⚠️ FIMO-T4-QC-05 : [À CONFIRMER: sujet relation client (soft-skill, non réglementaire). L'intitulé exact des quatre temps varie selon le support pédagogique du centre ; la trame proposée (écouter / reformuler / proposer / conclure) est la version standard en relation client. Vérifier l'alignement avec le cours de référence. Barème et somme (4×0,5=2) corrects.]
UPDATE public.question_bank SET
  expected_answer = $c370$Méthode en quatre temps pour gérer un interlocuteur difficile (client mécontent, destinataire agressif, etc.) :

a. Écouter activement. Laisser la personne s'exprimer sans l'interrompre, accuser réception de son mécontentement, adopter une attitude calme et une posture ouverte. Objectif : faire baisser la tension et recueillir les faits.

b. Reformuler et comprendre. Reprendre avec ses propres mots le problème exposé (« Si je comprends bien, la palette livrée est abîmée... ») pour vérifier qu'on a bien saisi la demande et montrer à l'interlocuteur qu'il est entendu. Isoler le fait du ressenti.

c. Proposer / agir. Apporter une réponse ou une solution concrète dans son champ de responsabilité (émettre des réserves, contacter l'exploitation, proposer un arrangement), ou orienter vers le bon interlocuteur quand la décision dépasse ses attributions. Rester factuel et courtois, ne pas promettre ce qu'on ne peut pas tenir.

d. Conclure et valider. S'assurer de l'accord de l'interlocuteur sur la suite donnée, récapituler ce qui a été convenu, remercier et prendre congé de façon professionnelle. Rendre compte ensuite à l'exploitation.$c370$,
  scoring_grid    = $c370$a. Écouter activement / laisser s'exprimer, rester calme : 0,5 pt. b. Reformuler pour comprendre la demande : 0,5 pt. c. Proposer une solution ou orienter, rester factuel : 0,5 pt. d. Conclure, valider l'accord et rendre compte : 0,5 pt. Total = 2 pts (0,5 par temps correctement cité). Accepter toute formulation équivalente respectant l'enchaînement des quatre temps.$c370$
WHERE source_ref = 'FIMO-T4-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Lorsque le destinataire refuse une partie de la marchandise, le conducteur doit protéger juridiquement l'entreprise par deux gestes documentaires immédiats, sur le document de transport (lettre de voiture / CMR ou bon de livraison) :

a. Porter des réserves écrites, précises et datées, au moment de la remise : nature du refus, quantité et références des colis refusés, motif invoqué (marchandise abîmée, non conforme, manquante...). Des réserves vagues (« sous réserve ») sont sans valeur ; elles doivent être détaillées et motivées.

b. Faire contresigner ces réserves par le destinataire (signature et éventuellement cachet), conserver l'exemplaire du transporteur et prévenir sans délai l'exploitation. Ce contreseing rend les réserves opposables et déclenche le traitement du litige.$c370$,
  scoring_grid    = $c370$a. Porter des réserves écrites précises, datées et motivées sur le document de transport (quantité, motif) : 1 pt. b. Les faire contresigner par le destinataire et conserver / transmettre l'exemplaire à l'exploitation : 1 pt. Total = 2 pts. Une réponse citant les réserves sans le contreseing (ou l'inverse) ne vaut que 1 pt.$c370$
WHERE source_ref = 'FIMO-T4-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Trois segments du transport routier de marchandises et leur exigence dominante :

a. Messagerie / express (colis, palettes en groupage) : exigence dominante = le respect des délais et des créneaux de livraison (rapidité, ponctualité, nombreux points de livraison).

b. Lot complet / charge complète (un chargement, un destinataire) : exigence dominante = l'optimisation du taux de chargement et du coût de revient (remplir le véhicule, limiter les kilomètres à vide).

c. Température dirigée / frigorifique : exigence dominante = le maintien de la chaîne du froid et sa traçabilité (respect de la température de consigne de bout en bout).

Autres segments recevables avec leur exigence : citerne / vrac (sécurité, réglementation ADR pour les matières dangereuses) ; déménagement (soin de la manutention et de l'emballage).$c370$,
  scoring_grid    = $c370$Trois couples « segment + exigence dominante » attendus. Barème : 0,66 pt par couple correctement identifié (segment ET son exigence), total arrondi à 2 pts. Un segment cité sans son exigence dominante (ou une exigence mal associée) ne vaut que la moitié du point du couple. Accepter tout segment pertinent du TRM correctement associé à son exigence.$c370$
WHERE source_ref = 'FIMO-T4-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$À 9 h, dès que le retard de 45 minutes est certain (arrivée estimée à 10 h 45 au lieu de 10 h), le conducteur doit anticiper et informer, sans jamais chercher à rattraper le temps par une conduite dangereuse ou irrégulière :

a. Prévenir immédiatement (dès 9 h) son exploitation et/ou le client, ainsi que le destinataire, en annonçant le retard et la nouvelle heure d'arrivée estimée (environ 10 h 45). Informer tôt permet au destinataire de s'organiser et à l'exploitation de gérer la relation commerciale.

b. Ne pas compenser le retard au détriment de la sécurité et de la réglementation : pas d'excès de vitesse, pas d'entorse aux temps de conduite et de pause (pause obligatoire de 45 min après 4 h 30 de conduite continue, fractionnable en 15 + 30 min). Poursuivre la mission de façon sûre et consigner l'événement.$c370$,
  scoring_grid    = $c370$a. Prévenir sans délai, dès 9 h, l'exploitation / le client / le destinataire et communiquer la nouvelle heure estimée : 1 pt. b. Refuser de rattraper le retard par des infractions (vitesse, temps de conduite et pauses) et rouler en sécurité : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T4-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Trois postes économiques principaux sur lesquels le conducteur influe directement par sa conduite et son comportement :

a. Le carburant : premier poste de coût variable ; l'éco-conduite (anticipation, régime moteur, limitation des à-coups et de la vitesse, arrêt du moteur à l'arrêt prolongé) réduit directement la consommation de gazole.

b. L'usure du matériel et la maintenance : une conduite souple préserve les pneumatiques, les freins, l'embrayage et la transmission, et espace les interventions ; les contrôles quotidiens (pneus, niveaux) limitent les pannes.

c. La sinistralité : le conducteur agit directement sur le nombre d'accidents et de dégâts (casse de la marchandise, dommages au véhicule) et sur les pénalités et amendes ; moins de sinistres, c'est moins d'immobilisations, de franchises et de surprimes d'assurance.$c370$,
  scoring_grid    = $c370$Trois postes attendus. Barème : 0,66 pt par poste correctement cité, total arrondi à 2 pts. Postes acceptés : carburant / consommation ; usure du véhicule et maintenance (pneumatiques, freins, embrayage) ; sinistralité (accidents, casse marchandise, amendes). Un simple mot sans lien avec l'action du conducteur n'est pas compté.$c370$
WHERE source_ref = 'FIMO-T4-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Une réserve portée sur la lettre de voiture (LV / CMR) doit rester un CONSTAT et non une INTERPRÉTATION. En écrivant vous-même la cause probable du dommage (« erreur du chargeur »), vous commettez deux fautes :

a. Vous sortez de votre rôle et de votre compétence. Le conducteur constate un état apparent (ce qu'il voit, mesure, dénombre) : emballage déchiré, colis enfoncé, palette instable, produit mouillé, unités manquantes. Déterminer la CAUSE et désigner un RESPONSABLE relève d'une expertise (assureur, expert, tribunal), pas du chauffeur. Une cause écrite « au jugé » est une opinion invérifiable, contestable et sans valeur probante.

b. Vous fragilisez la valeur juridique de la réserve et pouvez vous retourner contre vous ou votre entreprise. La force d'une réserve tient à sa précision factuelle et au fait qu'elle est portée immédiatement et, dans l'idéal, contresignée par la partie présente (chargeur ou destinataire). En y ajoutant une accusation (« erreur du chargeur »), vous transformez un constat objectif en mise en cause subjective : la partie visée refusera de contresigner, la réserve perd sa portée, et l'attribution hâtive peut au contraire faire présumer que le transporteur avait connaissance/maîtrise du problème sans réagir. Cela peut donc engager la responsabilité du transporteur au lieu de la préserver.

En résumé : on décrit les faits (nature, localisation, étendue du dommage, quantités), de manière précise, datée et si possible contresignée ; on ne qualifie jamais soi-même la cause ni le fautif.$c370$,
  scoring_grid    = $c370$a. Le conducteur constate un état apparent (fait objectif) et n'est pas compétent pour établir la cause / désigner un responsable, qui relève de l'expertise : 1 pt.
b. Une cause/accusation écrite prive la réserve de sa valeur probante (non contresignée, contestable) et peut se retourner contre le transporteur ; la réserve doit rester factuelle, précise et si possible contradictoire : 1 pt.
Total = 2 pts.$c370$
WHERE source_ref = 'FIMO-T4-QC-10' AND type='qr';

-- ⚠️ TAXI-M1-QC-01 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Signification du sigle T3P : T3P signifie « Transport public particulier de personnes ». Il désigne l'activité de transport de personnes, à titre onéreux, effectuée avec un véhicule de moins de dix places (conducteur compris), sur réservation ou par prise en charge directe du client, par opposition au transport public collectif (bus, car).

b. Véhicules et activités concernés : le T3P regroupe trois familles d'activité :
1. les taxis (véhicules autorisés à stationner et à circuler en quête de clients, dits « en maraude », équipés d'un taximètre et d'un lumineux) ;
2. les VTC (voitures de transport avec chauffeur, uniquement sur réservation préalable) ;
3. les véhicules motorisés à deux ou trois roues (motos-taxis et scooters, transport de personnes à titre onéreux).
Pour l'examen préparé ici, seuls les taxis et les VTC (véhicules automobiles de moins de dix places) sont visés par la carte professionnelle T3P avec mention correspondante.$c370$,
  scoring_grid    = $c370$a. Définition correcte du sigle « Transport public particulier de personnes » : 1 point. b. Identification des véhicules ou activités concernés (au moins taxi et VTC ; bonus mental pour les VMDTR / motos-taxis) : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'TAXI-M1-QC-01' AND type='qr';

-- ⚠️ TAXI-M1-QC-02 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Autorité qui délivre la carte professionnelle T3P : c'est le préfet du département (services de la préfecture), sur demande du candidat ayant réussi l'examen T3P et rempli les conditions d'accès (permis, casier, visite médicale, PSC1). À Paris et dans les départements de la petite couronne, la compétence relève de la préfecture de police.

b. Mention figurant sur la carte selon l'activité : la carte porte la mention « taxi » pour l'exercice de l'activité de taxi, ou la mention « VTC » pour l'exercice de l'activité de voiture de transport avec chauffeur. La mention correspond à l'épreuve spécifique (taxi ou VTC) réussie en complément du tronc commun ; elle conditionne le type d'activité que le conducteur est autorisé à exercer.$c370$,
  scoring_grid    = $c370$a. Autorité correcte : le préfet / la préfecture (préfecture de police à Paris et petite couronne) : 1 point. b. Mention « taxi » ou « VTC » selon l'activité exercée : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'TAXI-M1-QC-02' AND type='qr';

-- ⚠️ TAXI-M1-QC-03 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Règle qui vous oblige à refuser : l'activité de VTC repose sur l'obligation de réservation préalable. Le VTC ne peut prendre en charge un client que si la course a été réservée à l'avance (application, plateforme, téléphone, contrat). Il est donc interdit de charger un client hélé ou monté spontanément en pleine rue, sans réservation.

b. Justification et conséquence : la prise en charge directe du client sur la voie publique, ainsi que le stationnement ou la circulation en quête de clientèle, constituent la « maraude », qui est un monopole réservé aux taxis (titulaires d'une autorisation de stationnement). Pour un VTC, accepter ce client reviendrait à exercer une maraude illicite, passible de sanctions (contravention, voire retrait de l'inscription au registre VTC). La bonne pratique consiste à expliquer poliment au client qu'une réservation préalable est nécessaire et, le cas échéant, à enregistrer une réservation en bonne et due forme avant le départ.$c370$,
  scoring_grid    = $c370$a. Identification de la règle : obligation de réservation préalable du VTC / interdiction de la maraude : 1 point. b. Justification correcte (la maraude est réservée aux taxis, refus obligatoire pour rester en règle) : 1 point. Total = 2 points.$c370$
WHERE source_ref = 'TAXI-M1-QC-03' AND type='qr';

-- ⚠️ TAXI-M1-QC-04 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$La loi Grandguillaume (loi n° 2016-1920 du 29 décembre 2016) a réorganisé le secteur du T3P. Ses deux apports majeurs sont :

a. La création d'un examen commun T3P, avec un tronc commun d'épreuves d'admissibilité identiques pour les candidats taxi et VTC, complété par une épreuve spécifique propre à chaque activité. L'organisation de cet examen a été confiée aux chambres de métiers et de l'artisanat (CMA), ce qui a harmonisé et professionnalisé l'accès au métier.

b. La suppression du recours au statut LOTI pour le transport de personnes de moins de dix places en zone urbaine. Cette mesure a mis fin au contournement consistant à exercer une activité de type VTC sous le régime LOTI (transport occasionnel), afin de clarifier les statuts (taxi, VTC) et de lutter contre la concurrence déloyale. La loi a par ailleurs renforcé l'encadrement des plateformes de mise en relation.$c370$,
  scoring_grid    = $c370$a. Premier apport : examen commun T3P avec tronc commun (organisation confiée aux CMA) : 1 point. b. Second apport : fin du recours au statut LOTI pour le transport particulier de moins de dix places / clarification des statuts et lutte contre la concurrence déloyale : 1 point. Total = 2 points. (Tout autre apport exact et majeur, comme le renforcement de l'encadrement des plateformes, peut être accepté à la place de l'un des deux.)$c370$
WHERE source_ref = 'TAXI-M1-QC-04' AND type='qr';

-- ⚠️ TAXI-M1-QC-05 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Les épreuves d'admissibilité du tronc commun de l'examen T3P sont identiques pour les candidats taxi et VTC. Elles se présentent sous forme de questionnaires (QCM/QRC) et portent notamment sur les matières suivantes :
1. la réglementation du transport public particulier de personnes (T3P) ;
2. la gestion (notions de gestion d'entreprise) ;
3. la sécurité routière ;
4. le français (compréhension et expression écrite de la langue française) ;
5. l'anglais (compréhension écrite d'un niveau élémentaire).
Trois matières communes attendues, au choix parmi cette liste : par exemple la réglementation du T3P, la gestion et la sécurité routière. (Ces épreuves communes sont complétées par une épreuve spécifique propre à l'activité taxi ou VTC, qui ne fait pas partie du tronc commun.)$c370$,
  scoring_grid    = $c370$1 point pour deux matières communes correctement citées (parmi : réglementation du T3P, gestion, sécurité routière, français, anglais) ; 1 point pour la troisième matière correcte. Total = 2 points. Aucune matière hors liste n'est comptabilisée.$c370$
WHERE source_ref = 'TAXI-M1-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Oui, il remplit la condition d'ancienneté.

Raisonnement : pour obtenir la carte professionnelle T3P, le conducteur doit être titulaire du permis B en cours de validité depuis au moins 3 ans. Ce délai est ramené à 2 ans lorsque le permis a été obtenu à l'issue d'un apprentissage anticipé de la conduite (conduite accompagnée / AAC).

Application au cas : le cousin a passé son permis en conduite accompagnée et le détient depuis 2 ans et 3 mois. Le seuil applicable est donc de 2 ans, et non de 3 ans. 2 ans et 3 mois étant supérieur à 2 ans, la condition d'ancienneté est satisfaite : il peut prétendre à la carte T3P au regard de ce critère (sous réserve des autres conditions : casier, visite médicale, PSC1, examen T3P).$c370$,
  scoring_grid    = $c370$Énoncé de la règle applicable (permis depuis 3 ans, ramené à 2 ans si conduite accompagnée) : 1 pt. Conclusion justifiée (2 ans 3 mois > 2 ans donc condition remplie) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M1-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Avant toute première course rémunérée (transport de personnes à titre onéreux), le conducteur doit impérativement détenir une assurance couvrant spécifiquement le transport de personnes à titre onéreux : une assurance responsabilité civile professionnelle (RC pro) garantissant les personnes transportées (les passagers) ainsi que les tiers.

Point clé : une assurance automobile "à usage privé" classique ne suffit pas et ne couvre pas l'activité de transport rémunéré. Le véhicule doit être assuré au titre de l'activité professionnelle de transport public particulier de personnes ; à défaut, le conducteur roule sans couverture valable, ce qui l'expose à de lourdes conséquences en cas d'accident.$c370$,
  scoring_grid    = $c370$Identification de l'assurance responsabilité civile professionnelle couvrant le transport de personnes à titre onéreux : 1 pt. Précision qu'elle garantit les passagers transportés / que l'assurance privée classique est insuffisante : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M1-QC-07' AND type='qr';

-- ⚠️ TAXI-M1-QC-08 : [À CONFIRMER: modalités précises de l'épreuve d'admission pratique T3P (durée, éventuelle prise en charge réelle d'un client, grille d'évaluation officielle) selon l'arrêté en vigueur — décrites ici de façon générale sans chiffre inventé.] Structure admissibilité (QCM tronc commun + spécifique) / admission (pratique) conforme au domaine. Barème = max_score (2).
UPDATE public.question_bank SET
  expected_answer = $c370$L'examen T3P comporte deux phases : une phase d'admissibilité (épreuves théoriques sous forme de QCM : tronc commun commun aux taxis et VTC, puis épreuve spécifique selon l'activité choisie taxi ou VTC), puis une phase d'admission.

L'épreuve d'admission est l'épreuve pratique de l'examen. Elle consiste en une mise en situation pratique de conduite : le candidat, déjà déclaré admissible aux QCM, est évalué au volant sur ses compétences de conduite professionnelle (sécurité et maîtrise du véhicule, respect du code de la route, conduite économique et confortable) ainsi que sur sa relation avec le client (accueil, prise en charge, comportement professionnel). La réussite de cette épreuve d'admission conditionne l'obtention de l'attestation de réussite à l'examen, préalable à la délivrance de la carte professionnelle par la préfecture.$c370$,
  scoring_grid    = $c370$Identification que l'épreuve d'admission est l'épreuve pratique / mise en situation de conduite (par opposition aux QCM d'admissibilité) : 1 pt. Description du contenu évalué (conduite professionnelle et/ou relation client) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M1-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Condition vérifiée : en consultant le bulletin n° 2 du casier judiciaire, l'administration contrôle la condition d'honorabilité professionnelle du candidat, c'est-à-dire l'absence de condamnations incompatibles avec l'exercice de la profession de conducteur de taxi ou de VTC (par exemple certaines infractions au code de la route graves, atteintes aux personnes, vols, infractions à caractère sexuel, etc.).

Conséquence d'une mention incompatible : si le bulletin n° 2 fait apparaître une condamnation incompatible avec la profession, le candidat ne satisfait pas à la condition d'honorabilité. La conséquence est le refus de délivrance de la carte professionnelle T3P (ou, si elle a déjà été délivrée, son retrait), le conducteur étant alors dans l'incapacité légale d'exercer l'activité.$c370$,
  scoring_grid    = $c370$Identification de la condition d'honorabilité professionnelle (absence de condamnation incompatible, via le B2) : 1 pt. Conséquence d'une mention incompatible : refus de délivrance / retrait de la carte professionnelle et impossibilité d'exercer : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M1-QC-09' AND type='qr';

-- ⚠️ TAXI-M1-QC-10 : [À CONFIRMER: qualification et quantum exacts (montant de l'amende, durée d'emprisonnement) de la pratique illégale de la maraude selon les articles du code des transports en vigueur — les types de sanctions sont cités sans chiffre inventé.] Deux sanctions distinctes bien fournies (véhicule + droit d'exercer), conformes au domaine. Barème = max_score (2).
UPDATE public.question_bank SET
  expected_answer = $c370$La maraude (stationner ou circuler sur la voie publique en quête de clients) est réservée aux taxis titulaires d'une autorisation de stationnement (ADS). Un conducteur qui la pratique sans y être autorisé (typiquement un VTC, ou un conducteur sans ADS) commet une infraction pénale. Au-delà de l'amende, il encourt notamment :

1. Des peines complémentaires portant sur le véhicule : immobilisation et/ou confiscation du véhicule ayant servi à commettre l'infraction.

2. Une mesure administrative ou une peine complémentaire portant sur le droit d'exercer : suspension ou retrait de la carte professionnelle, voire interdiction d'exercer l'activité (et, le cas échéant, suspension du permis de conduire).

À ces deux exemples s'ajoute, pour ce type de délit, un risque de peine d'emprisonnement, l'amende n'étant que l'une des composantes de la sanction.$c370$,
  scoring_grid    = $c370$Première sanction/risque correct au-delà de l'amende (ex. immobilisation ou confiscation du véhicule) : 1 pt. Seconde sanction/risque correct (ex. suspension ou retrait de la carte professionnelle / interdiction d'exercer, ou peine d'emprisonnement) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M1-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$C'est le TAXI qui peut prendre en charge ce client, et lui seul.

a. Identification du professionnel : le taxi. La scène décrite (un passant qui hèle un véhicule sur la voie publique pour un transport immédiat, sans réservation préalable) correspond à la prise en charge à la volée.

b. Fondement juridique : le taxi bénéficie du droit de MARAUDE, c'est-à-dire du droit de stationner et de circuler sur la voie publique en quête de clients, en vue d'une prise en charge immédiate. Ce droit découle de l'autorisation de stationnement (ADS) dont il est titulaire. Le VTC, lui, ne peut PAS prendre ce client : son activité repose sur la RÉSERVATION PRÉALABLE obligatoire ; il lui est interdit de marauder et de stationner sur la voie publique en attente de clientèle. Prendre un client hélé dans la rue constituerait pour un VTC une infraction (maraude illicite).$c370$,
  scoring_grid    = $c370$a. Désigne correctement le taxi comme seul professionnel habilité : 1 pt. b. Justifie par le droit de maraude / prise en charge immédiate lié à l'ADS, et rappelle que le VTC exige une réservation préalable (pas de maraude) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M2-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Auprès de qui : la demande de première autorisation de stationnement (ADS) se fait auprès de l'autorité compétente pour la délivrer, à savoir le MAIRE de la commune (ou le président de l'établissement public de coopération intercommunale lorsque la compétence a été transférée). Cas particulier : à Paris, l'autorité compétente est le PRÉFET DE POLICE.

b. Mécanisme d'attente : le candidat s'inscrit sur une LISTE D'ATTENTE tenue par l'autorité de délivrance. Les ADS sont ensuite attribuées selon l'ordre chronologique d'inscription sur cette liste, au fur et à mesure que des autorisations se libèrent ou sont créées. Depuis la loi du 1er octobre 2014 (dite loi Thévenoud), ces nouvelles ADS sont délivrées à titre GRATUIT et sont INCESSIBLES ; elles sont valables 5 ans et renouvelables.$c370$,
  scoring_grid    = $c370$a. Autorité de délivrance correcte : maire (ou EPCI), avec mention du préfet de police à Paris : 1 pt. b. Mécanisme = inscription sur la liste d'attente, attribution par ordre chronologique (ADS nouvelle gratuite et incessible) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M2-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Réponse à donner au client : le prix d'une course de taxi n'est pas librement négociable ; je ne peux pas vous « faire un prix » au sens d'un tarif fixé à ma convenance.

a. Un prix réglementé : les tarifs des taxis sont fixés par ARRÊTÉ PRÉFECTORAL (dans la limite d'un plafond national fixé chaque année par arrêté ministériel). Le chauffeur ne fixe donc pas librement son prix, contrairement au VTC dont la tarification est libre.

b. Un prix calculé par le compteur : le montant de la course est déterminé par le COMPTEUR HOROKILOMÉTRIQUE (taximètre), obligatoire dans tout taxi, qui combine prise en charge, tarif horaire et tarif kilométrique selon le tarif applicable (jour/nuit, zone, retour à vide). Le prix affiché au compteur s'impose.

Conclusion : je ne peux pas baisser arbitrairement le tarif réglementaire. Tout au plus, lorsque la réglementation le permet, un forfait peut s'appliquer (par exemple certains trajets forfaitisés) mais il reste encadré et ne relève pas d'une libre négociation de gré à gré.$c370$,
  scoring_grid    = $c370$a. Prix réglementé, fixé par arrêté préfectoral (pas de libre négociation) : 1 pt. b. Prix calculé/matérialisé par le taximètre (compteur horokilométrique) obligatoire : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M2-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Réponse à l'exploitant VTC : ce service est illégal en l'état ; il faut le refuser.

a. La réservation préalable est obligatoire : l'activité de VTC repose sur la RÉSERVATION PRÉALABLE. Un VTC ne peut pas prendre en charge un client de manière immédiate à la volée ni stationner ou circuler sur la voie publique en quête de clients : il n'a pas le droit de maraude.

b. L'affichage « véhicules libres autour de vous » constitue une maraude électronique interdite : le fait d'informer le client, avant la réservation, à la fois de la LOCALISATION et de la DISPONIBILITÉ d'un véhicule VTC circulant ou stationnant sur la voie publique est interdit. Cette information (localisation + disponibilité immédiate en temps réel) est réservée aux taxis. Proposer la prise en charge immédiate de véhicules « libres autour de vous » revient donc à empiéter sur le monopole de maraude des taxis.

Conclusion : l'application doit fonctionner sur le principe d'une réservation préalable ; elle ne peut pas présenter les VTC comme immédiatement disponibles et géolocalisés en vue d'une prise en charge sans réservation.$c370$,
  scoring_grid    = $c370$a. Rappelle l'obligation de réservation préalable / interdiction de maraude pour le VTC : 1 pt. b. Qualifie l'affichage disponibilité + localisation en temps réel de maraude électronique interdite, réservée aux taxis : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M2-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Ce que le premier chauffeur peut faire et que le second ne pourra jamais faire : CÉDER (vendre) son autorisation de stationnement à un successeur.

a. L'ADS de 2008 est cessible : elle a été délivrée AVANT la loi du 1er octobre 2014 (loi Thévenoud). Les ADS antérieures à cette réforme demeurent transmissibles : leur titulaire dispose d'un DROIT DE PRÉSENTATION d'un successeur à titre onéreux (après une durée minimale d'exploitation effective). À la cessation d'activité, ce chauffeur peut donc présenter un successeur et percevoir le prix de la cession de sa « licence ».

b. L'ADS de 2023 est incessible : délivrée après la réforme, elle est attribuée à titre GRATUIT, elle est INCESSIBLE et strictement personnelle (valable 5 ans, renouvelable). À la cessation d'activité, elle ne peut être ni vendue ni transmise : elle est restituée à l'autorité de délivrance et réattribuée au candidat suivant sur la liste d'attente.

Conclusion : seul le premier chauffeur (ADS d'avant 2014) peut monnayer/transmettre son autorisation via le droit de présentation ; le second ne le pourra jamais.$c370$,
  scoring_grid    = $c370$a. ADS antérieure au 1er octobre 2014 (loi Thévenoud) = cessible/vendable via droit de présentation d'un successeur : 1 pt. b. ADS postérieure = gratuite, incessible, restituée à la cessation (jamais vendable) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M2-QC-05' AND type='qr';

-- ⚠️ TAXI-M2-QC-06 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$L'inscription d'un exploitant au registre national des VTC suppose de constituer un dossier prouvant que l'entreprise remplit les conditions d'accès et d'exercice. Trois justificatifs attendus (parmi la liste réglementaire) :

a. Un justificatif d'immatriculation de l'entreprise : extrait Kbis pour une société ou justificatif d'immatriculation au registre national des entreprises (numéro SIREN) pour un exploitant individuel, prouvant l'existence légale de l'activité.

b. Une attestation d'assurance de responsabilité civile professionnelle couvrant l'activité de transport de personnes avec les véhicules concernés (responsabilité engagée à l'égard des passagers et des tiers).

c. Un justificatif de la garantie (capacité) financière de l'exploitant, destinée à garantir la solvabilité de l'entreprise vis-à-vis de son activité de transport.

Autres justificatifs recevables au même titre : le certificat d'immatriculation (carte grise) de chaque véhicule affecté à l'activité, attestant qu'il répond aux conditions techniques exigées ; la copie de la carte professionnelle VTC du ou des conducteurs. Trois de ces éléments cités correctement valident la réponse.$c370$,
  scoring_grid    = $c370$Justificatif 1 correct (immatriculation entreprise / Kbis / SIREN) : 0,75 pt. Justificatif 2 correct (assurance RC professionnelle) : 0,75 pt. Justificatif 3 correct (garantie financière, carte grise conforme ou carte pro conducteur) : 0,5 pt. Total = 2 pts. Deux justificatifs seulement : plafonner à 1,25 pt.$c370$
WHERE source_ref = 'TAXI-M2-QC-06' AND type='qr';

-- ⚠️ TAXI-M2-QC-07 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER: seuil exact de remise obligatoire de la note, retenu ici à 25 euros TTC (seuil général de l'arrêté du 3 décembre 1987) ; vérifier le seuil applicable spécifiquement aux courses de taxi dans l'arrêté en vigueur.]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Le principe. La réglementation sur l'information du consommateur en matière de prix (arrêté du 3 décembre 1987 et réglementation propre aux tarifs des courses de taxi) impose au chauffeur de délivrer une note dès lors que le prix de la course atteint ou dépasse un seuil fixé (seuil général de 25 euros TTC). Pour une course d'un montant élevé comme ici, la remise de la note est donc obligatoire et doit être faite spontanément, sans que le client ait à la demander. En deçà du seuil, la note n'est obligatoire que si le client la réclame, mais doit alors être remise.

b. Le contenu. La note doit être établie en double exemplaire (l'original remis au client, le double conservé par l'exploitant pendant la durée réglementaire) et comporter les mentions obligatoires : la date de rédaction, le nom et l'adresse de l'exploitant (prestataire), la date et l'heure (ou heures de début et de fin) de la course, le lieu de départ et d'arrivée, la somme totale à payer toutes taxes comprises, et, s'il le demande, le nom du client.

c. Application au cas. Le passager étant en droit d'obtenir un justificatif et le montant étant élevé, le chauffeur doit lui remettre la note sans discussion ; refuser serait une infraction à la réglementation sur l'information du consommateur.$c370$,
  scoring_grid    = $c370$a. Caractère obligatoire de la note au-delà du seuil et remise spontanée (obligatoire d'office pour un montant élevé, sur demande en dessous) : 1 pt. b. Mentions obligatoires de la note (au moins trois citées : identité exploitant, date/heures, montant TTC, etc.) et double exemplaire : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M2-QC-07' AND type='qr';

-- ⚠️ TAXI-M2-QC-08 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER: valeurs chiffrées exactes des conditions techniques VTC (dimensions minimales, puissance minimale, ancienneté maximale du véhicule) ; ne pas exiger de chiffre précis du candidat, le raisonnement suffit.]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Le fait d'acheter des véhicules récents, hybrides et haut de gamme ne dispense pas de vérifier la conformité au décret fixant les conditions techniques des véhicules affectés à l'activité de VTC : « récent » ne signifie pas « conforme ». Le décret impose des caractéristiques précises que même une berline neuve peut ne pas respecter.

b. Points à contrôler avant chaque acquisition : le nombre de places assises (véhicule de 4 à 9 places, conducteur compris) ; les dimensions minimales du véhicule (longueur et largeur minimales) ; le nombre de portes ; la puissance minimale du moteur ; l'ancienneté maximale du véhicule à sa première mise en circulation. Une motorisation hybride ou un modèle récent ne garantit aucun de ces critères (un modèle compact ou une citadine hybride peut être trop court, trop étroit ou insuffisamment puissant).

c. Raison de fond : ces conditions techniques conditionnent l'inscription du véhicule sur le registre et le droit de l'exploiter. Un véhicule non conforme ne pourra pas être régulièrement affecté à l'activité, l'achat serait alors inutile. De plus, la réglementation évolue : le décret peut être modifié entre deux acquisitions, d'où la nécessité de le consulter à jour avant chaque achat.$c370$,
  scoring_grid    = $c370$a. Idée que « récent/hybride » ne vaut pas conformité automatique au décret : 0,75 pt. b. Citation d'au moins deux critères techniques réels (places, dimensions, puissance, ancienneté, portes) : 0,75 pt. c. Conséquence : conformité indispensable à l'inscription/exploitation du véhicule et réglementation susceptible d'évoluer : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M2-QC-08' AND type='qr';

-- ⚠️ TAXI-M2-QC-09 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$a. Réponse : non, vous ne pouvez pas charger ce piéton dans la commune B pour un départ immédiat.

b. Justification. L'autorisation de stationnement (ADS) rattache le taxi à sa commune (ou à son ressort géographique de rattachement), la commune A. La maraude, c'est-à-dire la prise en charge d'un client qui hèle le taxi sur la voie publique ou le stationnement en quête de clientèle, n'est autorisée que dans cette commune de rattachement (et, le cas échéant, dans le périmètre d'une autorisation conjointe). Circulant dans la commune B, vous êtes hors de votre ressort : y prendre un client au hasard d'un hélage constituerait une maraude illégale, réservée aux taxis rattachés à la commune B.

c. Exception. Vous pourriez légalement effectuer une course au départ de la commune B uniquement dans le cadre d'une réservation préalable (course commandée). Un simple hélage de rue pour un départ immédiat n'entre pas dans ce cadre : vous devez refuser la prise en charge.$c370$,
  scoring_grid    = $c370$a. Réponse correcte (non, prise en charge impossible) : 0,5 pt. b. Justification par le rattachement de l'ADS et la maraude limitée à la commune de rattachement : 1 pt. c. Mention de l'exception de la réservation préalable (seule voie pour charger hors ressort) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M2-QC-09' AND type='qr';

-- ⚠️ TAXI-M2-QC-10 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Ce comportement méconnaît plusieurs règles propres au régime tarifaire des VTC.

a. Le caractère ferme du prix annoncé et l'obligation d'information préalable. La tarification VTC est libre, mais le prix doit être porté à la connaissance du client avant la réservation. Lorsqu'un prix forfaitaire est déterminé et annoncé au moment de la réservation (ici 45 euros), ce montant s'impose : il constitue le prix de la prestation. Facturer 58 euros à l'arrivée revient à modifier unilatéralement un prix ferme et à priver le client de l'information préalable exacte, ce qui est irrégulier.

b. L'interdiction d'un calcul horokilométrique en temps réel de type taximètre. Recalculer le prix « à cause des bouchons » d'après la durée réelle de la course revient à facturer comme un taxi au compteur. Or le VTC ne peut pas être équipé d'un taximètre ni facturer selon un dispositif horokilométrique mesurant en direct le temps d'immobilisation. Deux modes de fixation seulement sont admis : un prix forfaitaire déterminé lors de la réservation, ou un prix fondé sur la durée et la distance à condition que le client en ait été informé au préalable de manière claire. Un supplément improvisé fondé sur les embouteillages ne respecte ni l'un ni l'autre.

c. Conclusion. En annonçant un forfait de 45 euros puis en facturant 58 euros sur la base de la durée réellement subie, l'exploitant viole à la fois le caractère contraignant du prix communiqué à la réservation, l'obligation d'information préalable sur le prix, et l'interdiction du procédé de comptage horokilométrique réservé aux taxis.$c370$,
  scoring_grid    = $c370$a. Prix annoncé à la réservation ferme et opposable + obligation d'information préalable sur le prix : 1 pt. b. Interdiction du taximètre / du calcul horokilométrique en temps réel pour le VTC et rappel des deux modes admis (forfait ou durée-distance annoncés) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M2-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Une charge fixe est un coût que le chauffeur supporte que le véhicule roule ou non ; elle ne dépend pas du kilométrage parcouru. Trois exemples typiques attendus (toute combinaison de trois parmi la liste suivante est valable) :

1. L'assurance professionnelle du véhicule (contrat « transport public de personnes à titre onéreux »), payée à l'année quel que soit le nombre de courses.
2. Les cotisations sociales du dirigeant / de l'indépendant, notamment les cotisations minimales ou forfaitaires dues même en l'absence ou en cas de faiblesse de recettes.
3. La cotisation foncière des entreprises (CFE), due chaque année dès lors que l'activité est exercée.

Autres réponses également recevables : le loyer ou les mensualités de location du véhicule (LOA / LLD) et son amortissement ; les honoraires d'expert-comptable ; l'abonnement à une centrale de réservation, un central radio ou une plateforme ; pour le taxi, la redevance de location de l'autorisation de stationnement (ADS) lorsque le chauffeur est locataire ; la visite technique périodique et les frais administratifs récurrents. Ne sont PAS des charges fixes : le carburant, l'usure des pneus ou l'entretien courant, qui varient avec le kilométrage (charges variables).$c370$,
  scoring_grid    = $c370$1,5 pt : trois charges effectivement fixes correctement citées (0,5 pt par charge exacte). 0,5 pt : distinction correcte fixe / variable (ex. exclusion du carburant). Toute charge variable présentée comme fixe ne compte pas. Total 2 pts.$c370$
WHERE source_ref = 'TAXI-M3-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Parce que la garantie « tous risques » ne dit rien de l'USAGE déclaré : elle qualifie l'étendue des dommages couverts, pas la finalité du véhicule. Un contrat « usage privé » (ou « privé et trajet domicile-travail ») couvre uniquement les déplacements personnels. Or le taxi et le VTC exercent le transport de personnes À TITRE ONÉREUX, c'est-à-dire une activité professionnelle rémunérée avec transport de tiers payants.

Conséquences :
1. L'usage professionnel constitue une aggravation du risque non déclarée à l'assureur. En cas de sinistre survenu pendant une course rémunérée, l'assureur peut opposer une exclusion de garantie, voire la nullité du contrat pour fausse déclaration intentionnelle (article L.113-8 du Code des assurances), et refuser toute indemnisation, y compris envers les passagers.
2. La réglementation T3P impose de justifier d'une assurance couvrant le transport de personnes à titre onéreux ; l'attestation « usage privé » ne permet donc ni l'inscription/exercice, ni le contrôle.

Il faut donc souscrire un contrat spécifique « transport public de personnes » (usage professionnel taxi ou VTC), qui couvre les passagers transportés contre rémunération, quel que soit par ailleurs le niveau de garantie (au tiers ou tous risques).$c370$,
  scoring_grid    = $c370$1 pt : identifier que le problème porte sur l'USAGE déclaré (activité à titre onéreux / transport de tiers payants) et non sur l'étendue des garanties. 1 pt : citer au moins une conséquence concrète (exclusion de garantie / nullité pour fausse déclaration / non-indemnisation des passagers) et la nécessité d'un contrat professionnel dédié. Total 2 pts.$c370$
WHERE source_ref = 'TAXI-M3-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Il s'agit d'opposer deux régimes sociaux distincts selon la forme juridique.

1. Président de SASU : il relève du régime général de la Sécurité sociale en tant qu'« assimilé salarié ». Il bénéficie d'une protection sociale proche de celle d'un salarié (hors assurance chômage), les cotisations sont calculées sur la seule rémunération effectivement versée : s'il ne se verse rien, il n'y a pas de cotisation minimale. En contrepartie, le taux de cotisations sur salaire est plus élevé. Les dividendes qu'il perçoit ne sont pas soumis aux cotisations sociales (ils supportent les prélèvements sociaux du capital).

2. Gérant associé unique d'EURL : il est travailleur non salarié (TNS), affilié à la Sécurité sociale des indépendants (SSI, gérée par le régime général). Les cotisations sont globalement moins élevées mais la protection est plus réduite ; des cotisations minimales restent dues même sans revenu ou en cas de déficit. Par ailleurs, la part des dividendes dépassant 10 % du capital social (majoré des primes d'émission et des sommes en compte courant d'associé) est réintégrée dans l'assiette des cotisations sociales.

En résumé : SASU = assimilé salarié (régime général, cotisations sur rémunération versée, dividendes hors cotisations) ; EURL = TNS/SSI (cotisations moindres mais minimales dues, dividendes partiellement soumis à cotisations au-delà de 10 % du capital).$c370$,
  scoring_grid    = $c370$1 pt : président de SASU = assimilé salarié rattaché au régime général. 1 pt : gérant associé unique d'EURL = TNS affilié à la SSI. Bonus intégré (sans dépasser 2 pts) pour un élément différenciant correct : cotisations minimales TNS, dividendes SASU hors cotisations, ou seuil des 10 % du capital en EURL. Total 2 pts.$c370$
WHERE source_ref = 'TAXI-M3-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le coût de revient kilométrique complet correspond à l'ensemble des charges supportées par l'activité, rapporté au nombre total de kilomètres parcourus sur la période.

Formule générale :

Coût de revient au km = (Charges fixes annuelles + Charges variables annuelles) / Nombre total de kilomètres parcourus dans l'année

où :
- Charges fixes : assurance professionnelle, loyer/amortissement du véhicule, cotisations sociales, CFE, honoraires comptables, abonnements (centrale, plateforme), redevance ADS le cas échéant, etc. (indépendantes du kilométrage) ;
- Charges variables : carburant ou énergie, entretien et réparations, pneumatiques, usure/dépréciation liée à l'usage, péages, etc. (proportionnelles au kilométrage) ;
- Nombre de kilomètres : total annuel, courses en charge ET trajets à vide inclus, puisque tous les kilomètres consomment des charges.

Remarque pédagogique : c'est un coût « complet » car il additionne fixes + variables. On distingue ainsi le coût au km parcouru (tous km) du coût au km « en charge » (rapporté aux seuls km facturés), toujours supérieur du fait des kilomètres à vide. La comparaison de ce coût au tarif au km permet de vérifier la rentabilité de l'activité.$c370$,
  scoring_grid    = $c370$1,5 pt : formule correcte = (charges fixes + charges variables) / nombre de kilomètres parcourus. 0,5 pt : précision pertinente (kilomètres totaux à vide inclus, OU décomposition fixes/variables citée par des exemples). Total 2 pts.$c370$
WHERE source_ref = 'TAXI-M3-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le fait que le client reparte sans rien réclamer ne dispense en rien de vos obligations de recettes : l'encaissement en espèces est une recette imposable qui doit être tracée.

Ce qu'il faut faire :
1. Enregistrer la recette. Toute somme encaissée, y compris en espèces et même sans note remise au client, doit être inscrite dans votre suivi des recettes (livre / registre des recettes, ou logiciel de caisse) au jour le jour, avec la date et le montant. C'est la base de votre déclaration de chiffre d'affaires et de vos cotisations/impôts ; ne pas l'enregistrer constituerait une dissimulation de recettes.
2. Établir la note / le justificatif. Pour une course de taxi, la remise d'une note est obligatoire dès que le prix atteint 25 € TTC (arrêté du 3 décembre 1987 relatif à l'information du consommateur sur les prix), et, en deçà de ce seuil, elle doit être délivrée si le client la demande. Même si le client ne demande rien et repart, vous devez conserver la trace de l'opération (souche, double de note, ou enregistrement du taximètre/horodateur) pour justifier la recette en cas de contrôle.
3. Cohérence caisse / taximètre. Le montant encaissé doit correspondre à ce qu'affiche le compteur horokilométrique (taxi) ; on rapproche en fin de service le total du taximètre, la caisse espèces et le registre des recettes.

En résumé : on encaisse, on enregistre la recette et on conserve un justificatif, indépendamment du fait que le client réclame ou non sa note.$c370$,
  scoring_grid    = $c370$1,5 pt : enregistrer / déclarer la recette dans le livre ou registre des recettes malgré l'absence de demande (traçabilité, pas de dissimulation). 0,5 pt : conserver un justificatif / établir la note (souche, taximètre) pour un éventuel contrôle. Total 2 pts.$c370$
WHERE source_ref = 'TAXI-M3-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le salarié et le locataire-gérant exploitent tous deux une autorisation de stationnement (ADS) dont ils ne sont pas titulaires, mais leur statut diffère radicalement. Deux différences attendues (deux suffisent) :

a. Nature du lien juridique et statut social. Le salarié est lié au titulaire de l'ADS par un contrat de travail : il existe un lien de subordination (horaires, consignes, contrôle de l'employeur), il relève du régime général de la Sécurité sociale et perçoit un salaire. Le locataire-gérant est un travailleur indépendant (TNS) : il loue le droit d'exploiter l'ADS moyennant une redevance (loyer) versée au titulaire, sans lien de subordination, et relève du régime des indépendants.

b. Rémunération et risque économique. Le salarié touche un salaire fixe (ou fixe + variable) garanti quel que soit le niveau de recettes ; c'est l'employeur qui supporte le risque d'exploitation. Le locataire-gérant conserve les recettes de son activité mais doit d'abord payer la redevance et l'ensemble de ses charges : il supporte lui-même le risque économique et son revenu dépend directement de son chiffre d'affaires.

Autres différences recevables : autonomie de gestion (le locataire-gérant organise librement son activité), protection sociale (couverture du régime général plus protectrice pour le salarié), responsabilité (le locataire-gérant est responsable de l'exploitation à titre personnel).$c370$,
  scoring_grid    = $c370$a. 1 point pour une première différence correctement identifiée et justifiée (statut/lien juridique, régime social, mode de rémunération, autonomie, risque). b. 1 point pour une seconde différence distincte et correctement justifiée. Total = 2 points. Une seule différence valable = 1 point ; deux formulations de la même idée = 1 point.$c370$
WHERE source_ref = 'TAXI-M3-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Au-delà de la responsabilité civile circulation à usage professionnel (obligatoire), plusieurs garanties protègent l'activité et les revenus du chauffeur. Deux réponses attendues (deux suffisent) :

a. La prévoyance (contrat de prévoyance TNS, type Madelin) : elle couvre les risques d'incapacité de travail, d'invalidité et de décès en versant des indemnités journalières et un capital ou une rente. Elle compense la perte de revenus lorsque le chauffeur ne peut plus conduire.

b. La garantie perte d'exploitation (ou perte de recettes) : elle prend le relais du chiffre d'affaires en cas d'immobilisation du véhicule ou d'arrêt d'activité à la suite d'un sinistre garanti.

Autres réponses recevables : complémentaire santé (mutuelle TNS), assurance du véhicule tous risques ou intermédiaire (au-delà de la seule RC), garantie individuelle du conducteur (dommages corporels du chauffeur), protection juridique professionnelle, assurance responsabilité civile professionnelle (dommages causés aux clients/tiers hors circulation), et contrat de retraite complémentaire facultatif.$c370$,
  scoring_grid    = $c370$a. 1 point pour une première garantie ou contrat pertinent et correctement rattaché à la protection de l'activité/des revenus. b. 1 point pour une seconde garantie ou contrat distinct et pertinent. Total = 2 points. Réponse hors sujet (ex. RC circulation, déjà citée dans l'énoncé) = 0 pour cet item.$c370$
WHERE source_ref = 'TAXI-M3-QC-07' AND type='qr';

-- ⚠️ TAXI-M3-QC-08 : [À CONFIRMER: durée légale de conservation des relevés/pièces justificatives — 6 ans (LPF art. L102 B) côté fiscal, 10 ans (Code de commerce art. L123-22) côté comptable. Le raisonnement « pourquoi conserver » (preuve du CA/charges au réel + contrôle fiscal) reste valable indépendamment du chiffre.] Énoncé vérifié ; barème 1+1 = 2 = max_score.
UPDATE public.question_bank SET
  expected_answer = $c370$Un chauffeur imposé au réel doit conserver les relevés mensuels de sa plateforme pour plusieurs raisons convergentes :

a. Justification du chiffre d'affaires et des charges. Au régime réel, le résultat imposable est établi à partir des produits et des charges réels. Les relevés de la plateforme prouvent le montant exact des courses encaissées (chiffre d'affaires) et permettent de déduire la commission prélevée par la plateforme comme charge d'exploitation. Ils servent aussi de justificatifs pour la TVA (collectée et déductible) le cas échéant. Ce sont des pièces comptables justificatives qui appuient la déclaration.

b. Contrôle fiscal et obligation de conservation. En cas de vérification, l'administration fiscale peut demander la justification des sommes déclarées ; les relevés permettent de reconstituer et de prouver le chiffre d'affaires réel. À défaut de justificatifs, l'administration peut rejeter la comptabilité ou reconstituer les recettes. Ces documents doivent être conservés pendant le délai légal de conservation des pièces comptables et justificatifs (indicativement 6 ans au titre du droit de reprise fiscal). [À CONFIRMER: durée exacte de conservation applicable (6 ans au sens de l'article L102 B du LPF pour les pièces justificatives ; 10 ans pour les documents comptables au sens du Code de commerce)].$c370$,
  scoring_grid    = $c370$a. 1 point pour l'idée de justification/preuve du chiffre d'affaires et des charges (commission déductible, appui de la déclaration au réel). b. 1 point pour l'idée de contrôle fiscal / obligation de conservation des pièces justificatives (reconstitution des recettes, opposabilité à l'administration). Total = 2 points.$c370$
WHERE source_ref = 'TAXI-M3-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Calcul du coût kilométrique complet. Le coût complet annuel (charges + rémunération visée) est de 50 000 € pour 40 000 km parcourus. Coût kilométrique complet = 50 000 € / 40 000 km = 1,25 € / km.

b. Conclusion sur une course payée 1 € du kilomètre. Le prix de 1 €/km est inférieur au coût complet de 1,25 €/km : chaque kilomètre parcouru dégage une perte de 0,25 € (1,00 - 1,25). La course ne couvre pas l'intégralité des charges et de la rémunération visée ; elle est déficitaire au coût complet. Sur ce tarif, l'activité n'est pas rentable : il faut refuser ou renégocier ce niveau de prix, viser un tarif au moins égal à 1,25 €/km (avec marge au-delà), et/ou réduire les kilomètres à vide et les charges pour abaisser le coût kilométrique.$c370$,
  scoring_grid    = $c370$a. 1 point pour le calcul correct : 50 000 / 40 000 = 1,25 €/km (résultat juste avec la division posée). b. 1 point pour la conclusion correcte : 1 €/km < 1,25 €/km, donc course déficitaire (perte de 0,25 €/km) et non rentable. Total = 2 points. Bonne conclusion sans le chiffre de la perte : accepter 1 point si la comparaison est explicite.$c370$
WHERE source_ref = 'TAXI-M3-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La prévoyance est présentée comme indispensable pour un chauffeur travailleur non salarié (TNS) parce que sa protection sociale obligatoire est nettement plus faible que celle d'un salarié du régime général, alors que son revenu dépend entièrement de sa capacité à conduire. Éléments attendus :

a. Une couverture obligatoire insuffisante. Le régime des indépendants verse des indemnités journalières faibles (et souvent après un délai de carence) en cas d'arrêt de travail, et une couverture limitée de l'incapacité, de l'invalidité et du décès. Un chauffeur TNS n'a pas d'employeur pour maintenir son salaire : dès qu'il est arrêté, ses recettes s'arrêtent immédiatement alors que ses charges (loyer/redevance de l'ADS ou du véhicule, crédit, assurances, cotisations) continuent de courir.

b. Un métier exposé au risque d'arrêt et la protection de la famille. L'activité est physique et exposée (route, longues heures) ; un accident ou une maladie peut interrompre durablement, voire définitivement, la capacité à travailler. La prévoyance complète la couverture obligatoire : elle verse des indemnités journalières complémentaires en cas d'incapacité, une rente en cas d'invalidité, et un capital ou une rente aux proches en cas de décès. Elle sécurise ainsi le revenu du chauffeur et le niveau de vie de sa famille.$c370$,
  scoring_grid    = $c370$a. 1 point pour l'idée de protection sociale obligatoire faible du TNS et d'arrêt immédiat des revenus sans relais (pas d'employeur, indemnités journalières faibles). b. 1 point pour l'idée que la prévoyance comble ce manque (incapacité/invalidité/décès) et protège le revenu et/ou la famille. Total = 2 points.$c370$
WHERE source_ref = 'TAXI-M3-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Question : En fin de service de nuit, quels signes imposent l'arrêt immédiat pour une pause ?

En conduite de nuit, la vigilance chute et la somnolence peut s'installer très vite. Certains signaux d'alerte imposent de s'arrêter sans attendre, car ils annoncent un risque imminent de micro-sommeil.

Signes corporels et oculaires : bâillements répétés, paupières lourdes, picotements ou brûlures des yeux, envie de se frotter les yeux, vision qui se trouble, difficulté à garder les paupières ouvertes.

Signes de la vigilance et de la concentration : difficulté à fixer son attention, pensées qui vagabondent, impression de « décrocher » ou de ne plus se souvenir des derniers kilomètres, réactions plus lentes.

Signes physiques et posturaux : raideurs et douleurs de la nuque, du dos ou des épaules, besoin de changer sans cesse de position, sensation de froid ou au contraire coup de chaleur.

Signes comportementaux au volant : conduite qui se dégrade (vitesse irrégulière, trajectoire flottante, franchissement involontaire d'une ligne ou de la bande d'arrêt), le fait de sursauter, de ne pas avoir vu un panneau.

Conduite à tenir : dès l'apparition d'un seul de ces signes, s'arrêter en lieu sûr sans tenter de « tenir » jusqu'à destination. Le micro-sommeil dure quelques secondes mais suffit à provoquer une sortie de route. Repère de prévention : faire une pause régulièrement (recommandation usuelle : environ toutes les deux heures) et, en cas de somnolence, une courte sieste de quinze à vingt minutes reste le seul remède réellement efficace (le café ou l'air frais ne suppriment pas la dette de sommeil).$c370$,
  scoring_grid    = $c370$1 pt : citer plusieurs signes d'alerte pertinents (bâillements, paupières lourdes, picotements des yeux, baisse de concentration, micro-décrochages, raideurs, dégradation de la trajectoire) ; au moins trois signes distincts attendus. 1 pt : énoncer la bonne conduite à tenir (arrêt immédiat en lieu sûr dès le premier signe, pause / courte sieste, ne pas chercher à tenir jusqu'au bout). Total = 2.$c370$
WHERE source_ref = 'TAXI-M4-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Question : Qu'est-ce que la « poignée hollandaise » et quel accident prévient-elle ?

Définition : la poignée hollandaise (ou geste hollandais, du néerlandais « Dutch reach ») consiste à ouvrir la portière du véhicule avec la main la plus éloignée de la portière, et non avec la main la plus proche. Par exemple, le conducteur ouvre sa portière gauche avec la main droite ; un passager arrière ouvre la portière droite avec la main gauche.

Pourquoi ce geste : en utilisant la main opposée, on est naturellement obligé de tourner le buste et la tête vers l'arrière. Ce mouvement place le regard vers l'extérieur et vers l'arrière du véhicule et permet de contrôler l'angle mort avant d'ouvrir, c'est-à-dire de voir arriver un cycliste, un utilisateur de trottinette, un deux-roues motorisé ou un autre véhicule qui longe la voiture.

Accident évité : ce geste prévient l'accident dit d'« emportiérage » (le fait d'ouvrir une portière dans la trajectoire d'un usager qui survient), particulièrement dangereux pour les cyclistes et les deux-roues, qu'il peut faire chuter ou projeter. Pour un taxi, ce réflexe est essentiel au moment de la dépose des clients côté circulation.

Rappel : le Code de la route interdit d'ouvrir une portière lorsque cela constitue un danger ou une gêne pour les autres usagers.$c370$,
  scoring_grid    = $c370$1 pt : définition exacte du geste (ouvrir la portière avec la main opposée / la plus éloignée, ce qui oblige à tourner le buste et la tête pour contrôler l'arrière et l'angle mort). 1 pt : identifier l'accident prévenu, l'emportiérage, et sa cible (cyclistes / deux-roues survenant le long du véhicule). Total = 2.$c370$
WHERE source_ref = 'TAXI-M4-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Question : Qui est responsable du port de la ceinture d'un enfant mineur transporté dans le véhicule ?

Réponse : c'est le conducteur qui est responsable. Lorsque le passager est un mineur de moins de dix-huit ans, la réglementation met à la charge du conducteur le fait de veiller à ce que l'enfant soit correctement attaché (ceinture de sécurité et, selon l'âge et la taille, dispositif de retenue adapté). Le conducteur est verbalisable si l'enfant mineur n'est pas attaché.

Distinction importante : la règle change avec l'âge du passager. Pour un passager majeur (dix-huit ans et plus), chacun est personnellement responsable du port de sa propre ceinture et c'est lui qui serait sanctionné. Pour un mineur, la responsabilité pèse sur le conducteur.

Application au taxi : le chauffeur doit donc s'assurer, avant de démarrer, que tout enfant transporté est attaché et, pour les plus jeunes, disposer ou exiger un dispositif de retenue homologué adapté à sa taille et à son poids (obligation d'un dispositif homologué en principe jusqu'à 10 ans / 135 cm). Il ne peut pas se décharger de cette obligation sur l'enfant lui-même.$c370$,
  scoring_grid    = $c370$1 pt : désigner clairement le conducteur comme responsable pour un passager mineur de moins de 18 ans. 1 pt : justifier / nuancer correctement (obligation de veiller à l'attache et au dispositif de retenue adapté ; distinction avec le passager majeur qui est responsable de lui-même). Total = 2.$c370$
WHERE source_ref = 'TAXI-M4-QC-03' AND type='qr';

-- ⚠️ TAXI-M4-QC-04 : VÉRIFIÉ RÉGLEMENTAIREMENT : le seuil retenu (0,5 g/L sang / 0,25 mg/L air ; délit à 0,8 g/L / 0,40 mg/L) est CORRECT pour un chauffeur de taxi/VTC. Le seuil abaissé à 0,2 g/L (0,10 mg/L) NE vise PAS les taxis/VTC : il s'applique au permis probatoire et aux conducteurs de transport EN COMMUN de personnes (bus/autocars, véhicules > 8 places), catégorie dont les T3P ne relèvent pas. La seule réserve 
UPDATE public.question_bank SET
  expected_answer = $c370$Question : Fin de mariage, le client insiste pour trinquer alors qu'il reste des invités à raccompagner. Quels seuils continuent de s'appliquer malgré le contexte festif ?

Principe : le contexte festif ne change rien. En service, le chauffeur reste soumis aux mêmes règles que sur la route, et sa responsabilité professionnelle est même engagée puisqu'il transporte des personnes contre rémunération. Il refuse donc de consommer de l'alcool.

Seuil d'alcoolémie applicable : pour un chauffeur de taxi/VTC (hors permis probatoire), le taux légal reste 0,5 g d'alcool par litre de sang, soit 0,25 mg par litre d'air expiré. Au-delà, c'est une infraction (contravention) ; à partir de 0,8 g/L de sang (0,40 mg/L d'air expiré) il s'agit d'un délit. Ces seuils s'appliquent en permanence, quel que soit le motif de la course. Attention : si le conducteur est en période de permis probatoire, le seuil abaissé de 0,2 g/L de sang (0,10 mg/L d'air expiré) s'applique. En pratique, la seule marge sûre pour un professionnel au volant est de ne rien boire du tout.

Stupéfiants : tolérance zéro. La conduite après usage de produits stupéfiants est interdite et constitue un délit, sans seuil minimal.

Autres seuils / limites de service qui continuent de s'appliquer : les obligations de temps de conduite et de repos (amplitude de la journée de travail, pauses), l'obligation de vigilance et d'aptitude à conduire, ainsi que le respect du Code de la route. La fatigue de fin de soirée s'ajoute au risque et impose de rester d'autant plus strict.

Formulation attendue : le chauffeur remercie poliment, décline le verre, rappelle qu'il est en service et responsable de ses passagers, et termine ses courses à jeun.$c370$,
  scoring_grid    = $c370$1 pt : poser le principe que le contexte festif ne lève aucune obligation et refuser de boire en service. 1 pt : citer au moins un seuil chiffré correct (0,5 g/L de sang / 0,25 mg/L d'air expiré, ou tolérance zéro stupéfiants) et, idéalement, la limite du délit à 0,8 g/L. Total = 2.$c370$
WHERE source_ref = 'TAXI-M4-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Question : Un client demande la dépose « juste là », en double file devant une sortie de parking très fréquentée. Que proposez-vous et pourquoi ?

Réponse attendue : refuser poliment la dépose à cet endroit précis et proposer une alternative sûre à quelques mètres.

Ce que je fais : j'explique calmement au client que je ne peux pas m'arrêter là, puis je repère et propose un point de dépose sûr très proche (quelques mètres plus loin, après ou avant la sortie de parking, sur un emplacement où l'arrêt est autorisé et ne gêne personne). Le client n'a que quelques pas à faire.

Pourquoi (sécurité) : une dépose en double file devant une sortie de parking est dangereuse. Elle masque la visibilité entre les véhicules qui sortent du parking et les piétons ou les usagers qui circulent, elle oblige les clients à descendre côté circulation, et l'ouverture des portières expose au risque d'emportiérage pour les deux-roues et les cyclistes. Elle bloque aussi la sortie et crée un engorgement.

Pourquoi (réglementation) : l'arrêt en double file est un arrêt gênant, et devant une sortie de parking avec masque de visibilité il devient un arrêt dangereux, sanctionnable par le Code de la route. Le chauffeur reste responsable des conditions de descente de ses clients.

Message au client : présenter l'alternative comme un choix de sécurité et non un refus de service (« je vous dépose juste ici, à cinq mètres, c'est plus sûr pour vous et ça ne bloque pas la sortie »), ce qui préserve la qualité de service tout en respectant les règles.$c370$,
  scoring_grid    = $c370$1 pt : proposer la bonne solution (refuser cet emplacement et offrir un point de dépose sûr et autorisé tout proche, en gardant une posture de service). 1 pt : justifier par la sécurité et/ou la réglementation (arrêt gênant/dangereux en double file, masque de visibilité de la sortie, descente côté circulation / risque d'emportiérage, gêne à la circulation). Total = 2.$c370$
WHERE source_ref = 'TAXI-M4-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Après un accrochage matériel sans blessé avec un client à bord, la gestion se scinde en deux volets complémentaires.

a. Volet documentaire (constat et déclaration).
Sécuriser d'abord la scène (arrêt, signalisation, warnings). Remplir un constat amiable avec l'autre conducteur : identités, coordonnées, numéros de police d'assurance des deux véhicules, plaques, circonstances cochées, croquis clair et signatures des deux parties. Compléter par des photographies des dommages et de la position des véhicules, et relever l'identité d'éventuels témoins. Transmettre ensuite la déclaration à son assureur dans le délai légal (au minimum cinq jours ouvrés, fixé par le Code des assurances et repris au contrat). Consigner l'incident dans son suivi d'activité si l'exploitant l'exige.

b. Volet commercial (gestion du client).
S'assurer d'abord que le client va bien et le rassurer. Rester courtois et professionnel, présenter ses excuses pour la gêne. Assurer la continuité du service : si le véhicule est encore en état de rouler et sûr, proposer de terminer la course ; sinon organiser une solution de relais (autre véhicule, confrère, taxi) pour que le client arrive à destination. Ne pas facturer le temps d'immobilisation lié à l'accident et adapter le prix. Préserver la relation commerciale et l'image de l'entreprise.$c370$,
  scoring_grid    = $c370$a. Volet documentaire (constat amiable complet + déclaration assurance) : 1 pt. b. Volet commercial (sécurité/écoute du client, continuité de la course, gestion tarifaire et relationnelle) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M4-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La règle professionnelle consistant à régler l'application (GPS, plateforme, compteur) et à accepter les courses uniquement à l'arrêt répond à un double impératif.

a. Impératif de sécurité.
Manipuler un écran ou un téléphone en roulant détourne le regard de la route et les mains du volant : c'est une source majeure de distraction qui allonge le temps de réaction et provoque des embardées. Quelques secondes les yeux sur l'écran suffisent pour parcourir plusieurs dizaines de mètres sans contrôle visuel. Effectuer ces manipulations à l'arrêt supprime cette distraction et préserve la vigilance.

b. Impératif réglementaire.
L'usage d'un téléphone tenu en main en conduisant est interdit par le code de la route et sanctionné (amende et retrait de points). Régler l'application à l'arrêt, véhicule immobilisé, permet de rester conforme à la réglementation et d'éviter la sanction, tout en protégeant le client transporté et la responsabilité professionnelle du conducteur.$c370$,
  scoring_grid    = $c370$a. Raison de sécurité (distraction, regard/mains, temps de réaction) : 1 pt. b. Raison réglementaire (interdiction du téléphone tenu en main / manipulation en conduisant, sanction) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M4-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Trois usagers vulnérables typiques de la circulation urbaine et le réflexe qui protège chacun.

a. Les piétons (en particulier enfants, personnes âgées et personnes à mobilité réduite).
Réflexe : ralentir et anticiper à l'approche des passages piétons et des zones de rencontre, céder systématiquement le passage au piéton engagé ou manifestant l'intention de traverser, et couvrir le frein.

b. Les cyclistes.
Réflexe : respecter une distance latérale de sécurité au dépassement (au moins 1 mètre en agglomération, 1,50 mètre hors agglomération), contrôler l'angle mort avant de se rabattre, et vérifier avant d'ouvrir une portière (regard arrière, technique dite de la « main croisée ») pour éviter l'emportiérage.

c. Les deux-roues motorisés (scooters, motocyclistes).
Réflexe : contrôler les angles morts et signaler ses intentions tôt avec le clignotant, en tenant compte de la circulation interfiles et de la vitesse d'approche souvent sous-estimée de ces véhicules.

(Autres réponses recevables : enfants aux abords des écoles, personnes âgées, personnes à mobilité réduite, avec le réflexe de vigilance et d'anticipation associé.)$c370$,
  scoring_grid    = $c370$Trois usagers vulnérables correctement cités avec, pour chacun, le réflexe de protection pertinent. Barème global : 2 pts si les trois couples usager/réflexe sont corrects ; 1 pt si un ou deux seulement sont corrects et pertinents ; 0 sinon. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M4-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Réponse professionnelle face à une famille réservant un VTC avec un bébé, sans siège auto, le père proposant de le tenir dans ses bras.

a. Position à tenir.
Refuser, avec fermeté et courtoisie, de transporter l'enfant tenu dans les bras. Le port d'un enfant sur les genoux ou dans les bras est interdit et dangereux : en cas de choc, l'enfant est projeté ou écrasé, aucune ceinture prévue pour un adulte n'est adaptée à sa morphologie. Tout enfant de moins de dix ans doit voyager attaché dans un dispositif de retenue homologué adapté à son poids et à sa taille.

b. Justification et responsabilité.
Le conducteur est responsable du respect des règles de retenue des enfants transportés et engage sa responsabilité en cas d'accident comme de contrôle. À noter : la dérogation permettant à un enfant de voyager sans dispositif de retenue vise les taxis, non les VTC ; s'agissant ici d'un VTC, l'obligation de dispositif homologué s'applique pleinement. Et dans tous les cas — taxi comme VTC — transporter un bébé dans les bras reste interdit. Céder à la demande, même sous la pression du client, n'est pas une option.

c. Attitude commerciale et solutions.
Expliquer calmement la règle et la finalité (sécurité de l'enfant), sans culpabiliser la famille. Proposer une solution : fournir un siège ou un rehausseur si le véhicule en est équipé, inviter la famille à installer son propre dispositif, ou reporter/réorganiser la course. Préserver ainsi la sécurité, la conformité et la relation client.$c370$,
  scoring_grid    = $c370$a. Refus clair du transport de l'enfant dans les bras + obligation d'un dispositif de retenue homologué adapté : 1 pt. b/c. Justification (responsabilité du conducteur, sécurité) et attitude professionnelle avec solution proposée : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M4-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Prise de service à 19 h après une journée de déménagement presque sans sommeil : analyse du risque et décision professionnelle.

a. Analyse du risque.
La fatigue physique et le manque de sommeil altèrent la vigilance, allongent le temps de réaction, réduisent l'attention et le champ visuel, et exposent au risque de somnolence et de micro-sommeils au volant (assoupissements de quelques secondes, particulièrement redoutables la nuit et sur trajets monotones). Une dette de sommeil importante dégrade les capacités de conduite dans des proportions comparables à d'autres facteurs d'inaptitude. Le contexte (soirée, obscurité, fatigue accumulée) aggrave encore ce risque, pour le conducteur, ses clients et les autres usagers.

b. Décision professionnelle.
La sécurité prime sur le chiffre d'affaires : dans cet état, il faut renoncer à prendre le service. Concrètement : ne pas démarrer l'activité, prévenir l'exploitant ou la plateforme de son indisponibilité, se reposer et récupérer avant de reprendre. Si l'on est déjà en service et que la somnolence apparaît, s'arrêter en sécurité, faire une pause réparatrice (repos, éventuellement une courte sieste) avant de poursuivre. Conduire un client en étant à ce point fatigué serait une faute professionnelle engageant sa responsabilité.$c370$,
  scoring_grid    = $c370$a. Identification du risque lié à la fatigue/somnolence (baisse de vigilance, temps de réaction, micro-sommeils) : 1 pt. b. Décision responsable (renoncer au service / se reposer / prévenir, priorité à la sécurité) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M4-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Il s'agit de proposer son aide pour les bagages par une question courte, polie et directement compréhensible.

a. Formulation attendue (une au choix) :
« May I help you with your luggage? » (Puis-je vous aider avec vos bagages ?)
ou « Can I put your suitcases in the boot? » (en anglais américain : « ...in the trunk? ») — Puis-je mettre vos valises dans le coffre ?

b. Bonnes pratiques associées : le ton reste courtois (« May I... », « Can I... »), la phrase est brève et centrée sur l'action (aider / charger les valises). On accepte toute variante correcte et polie du même sens, par exemple « Do you need help with your bags? » ou « Let me help you with your suitcases. »$c370$,
  scoring_grid    = $c370$Question globale = 2 points. (1 pt) question en anglais correcte et compréhensible portant bien sur les bagages/valises ; (1 pt) formulation polie et adaptée à la prise en charge (offre d'aide ou proposition de charger dans le coffre). Réponse partielle (sens correct mais anglais approximatif, ou politesse absente) = 1 pt.$c370$
WHERE source_ref = 'TAXI-M5-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Traduction attendue :
« That will be twenty-five euros. Will you pay by card or in cash? »

Variantes acceptées, de sens équivalent :
« That's twenty-five euros. Would you like to pay by card or (in) cash? »
« It's twenty-five euros. Card or cash? » (registre plus direct mais correct).

Points de vigilance : le montant « vingt-cinq euros » se dit « twenty-five euros » ; « par carte » = « by card » ; « en espèces » = « in cash » (ou simplement « cash »).$c370$,
  scoring_grid    = $c370$Question globale = 2 points. (1 pt) première phrase correctement traduite avec le montant exact (twenty-five euros) ; (1 pt) proposition du choix de paiement correcte (by card / (in) cash). Erreur sur le montant ou omission d'une des deux options de paiement = 1 pt.$c370$
WHERE source_ref = 'TAXI-M5-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Il faut citer trois couples (paires) d'homophones grammaticaux fréquents, source d'erreurs à la relecture.

Réponse type (trois couples) :
1. « a » / « à » — « a » = verbe avoir (il a) ; « à » = préposition (à Paris).
2. « et » / « est » — « et » = conjonction (addition) ; « est » = verbe être (il est).
3. « ou » / « où » — « ou » = choix (l'un ou l'autre) ; « où » = lieu ou temps.

Autres couples également acceptés (au même titre) : « son » / « sont », « on » / « ont », « ces » / « ses », « ce » / « se », « la » / « là » / « l'a », « c'est » / « s'est ». Toute réponse citant trois paires pertinentes et correctement distinguées est valable ; l'essentiel est de nommer trois vrais couples d'homophones grammaticaux (pas des synonymes ni des accents isolés).$c370$,
  scoring_grid    = $c370$Question globale = 2 points, soit environ 0,66 pt par couple correctement cité. Barème pratique : (2 pts) trois couples justes ; (1 pt) un ou deux couples justes ; (0 pt) aucun couple valable ou confusion (homophones lexicaux hors sujet). On n'exige pas les définitions, seulement les paires ; les définitions justes confortent la note en cas de doute.$c370$
WHERE source_ref = 'TAXI-M5-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Deux informations à confirmer avant de démarrer avec un client étranger :

a. La destination (l'adresse ou le lieu exact d'arrivée).
b. Le mode de paiement (carte ou espèces) — ou, selon la formation, l'accord sur le tarif/l'estimation avant départ. Confirmer la destination et le paiement évite les malentendus et sécurise la course.

Exemple de formulation en anglais :
« Where would you like to go, please? » (destination)
« How would you like to pay: by card or in cash? » (paiement)

On accepte, pour la seconde information, une confirmation du prix/estimation : « The fare will be about twenty euros, is that all right? ». L'important est de citer deux informations pertinentes (destination + paiement/tarif) avec au moins un exemple correct en anglais.$c370$,
  scoring_grid    = $c370$Question globale = 2 points. (1 pt) les deux informations pertinentes citées (destination ET paiement ou tarif) — 0,5 pt si une seule ; (1 pt) au moins un exemple de formulation correct et compréhensible en anglais. Réponse citant les deux infos sans exemple anglais, ou avec un anglais fautif = 1 pt.$c370$
WHERE source_ref = 'TAXI-M5-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Technique attendue : la reformulation (reformuler la consigne à voix haute pour la faire valider par le client), éventuellement appuyée par une prise de notes des points clés (les trois étapes : déposer le client, remettre le pli à l'accueil, revenir le chercher à 15 h). C'est la technique de restitution/reformulation travaillée à l'épreuve de français (compréhension puis restitution d'un message oral).

b. Pourquoi : reformuler permet de vérifier qu'on a bien compris l'ensemble de la consigne, de mémoriser la séquence dans le bon ordre, de repérer et corriger tout de suite un malentendu, et de sécuriser la mission avant de l'exécuter. Noter l'heure (15 h) et l'ordre des tâches évite l'oubli d'une étape sur une consigne longue.

Réponses acceptées équivalentes : « je reformule / je répète la consigne avec mes mots pour confirmation », « je prends note des étapes et de l'heure », à condition que la justification (vérifier la compréhension / éviter l'oubli ou l'erreur) soit donnée.$c370$,
  scoring_grid    = $c370$Question globale = 2 points. (1 pt) technique correctement nommée (reformulation / restitution, éventuellement + prise de notes) ; (1 pt) justification pertinente (vérifier la bonne compréhension, mémoriser l'ordre des étapes, éviter l'oubli ou le malentendu avant d'exécuter). Technique nommée sans justification, ou justification sans technique claire = 1 pt.$c370$
WHERE source_ref = 'TAXI-M5-QC-05' AND type='qr';

-- ⚠️ TAXI-M5-QC-06 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Contexte : des travaux imposent de dévier de l'itinéraire annoncé. On attend deux phrases en anglais, l'une qui informe, l'autre qui rassure (raison du détour + maîtrise de la situation).

a. Phrase d'information (annonce du détour) :
« There are roadworks ahead, so I have to take a different route. »
(Variante acceptée : « Because of roadworks, I need to make a small detour. »)

b. Phrase pour rassurer (impact maîtrisé) :
« Don't worry, it will only add a few minutes and the fare won't change. »
(Variantes acceptées : « Please don't worry, I know a good alternative and we'll arrive safely. » / « It's just a short detour, everything is under control. »)

Attendu pédagogique : la première phrase explique la cause (roadworks / travaux) et annonce le changement d'itinéraire ; la seconde rassure sur le faible impact (temps, prix, sécurité). Anglais correct et poli (formule de politesse type « don't worry / please »).$c370$,
  scoring_grid    = $c370$Total = 2 points. a. Phrase d'information annonçant le détour et sa cause, en anglais correct : 1 pt. b. Phrase rassurante (impact limité : temps/prix/sécurité), en anglais correct et poli : 1 pt. Retirer 0,5 pt si une seule phrase est fournie ou si l'anglais est incompréhensible.$c370$
WHERE source_ref = 'TAXI-M5-QC-06' AND type='qr';

-- ⚠️ TAXI-M5-QC-07 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Contexte : le client hésite sur le chemin. On attend une question ouverte en anglais qui lui laisse le choix, puis une information utile pour décider.

a. Question laissant le choix :
« Would you prefer the fastest way by the motorway, or the shorter way through the city centre? »
(Variantes acceptées : « Which route would you like to take, the highway or the city roads? »)

b. Information ajoutée pour aider à décider :
« The motorway is usually quicker, but there may be more traffic at this time of day. »
(Variantes acceptées : « The city centre is nicer to see, but a little slower. » / « The highway costs a small toll but saves about ten minutes. »)

Attendu pédagogique : la question doit proposer une alternative claire (deux options) et laisser le client décider ; l'information ajoutée doit être concrète et utile (temps, trafic, péage, agrément) pour éclairer son choix. Ton courtois.$c370$,
  scoring_grid    = $c370$Total = 2 points. a. Question en anglais offrant un choix réel entre deux itinéraires (formulation ouverte/polie) : 1 pt. b. Information concrète et pertinente aidant à décider (temps, trafic, péage, distance) : 1 pt. Retirer 0,5 pt si la question est fermée (oui/non) sans réelle alternative, ou si l'information est absente.$c370$
WHERE source_ref = 'TAXI-M5-QC-07' AND type='qr';

-- ⚠️ TAXI-M5-QC-08 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Contexte : rédiger, en deux phrases, le message professionnel type adressé à une cliente qui a oublié son écharpe dans le véhicule. Le message doit signaler l'objet retrouvé et proposer une solution de restitution.

Message type (en français, professionnel et courtois) :
« Bonjour Madame, je me permets de vous contacter car vous avez oublié votre écharpe dans mon véhicule à l'issue de votre course. Je la conserve précieusement à votre disposition ; n'hésitez pas à me préciser le moment et le lieu qui vous conviennent pour que je vous la restitue. »

Variante plus concise acceptée :
« Bonjour Madame, vous avez oublié votre écharpe dans mon taxi ce jour. Je la garde en sécurité et reste à votre disposition pour convenir d'une remise. »

Attendu pédagogique : formule d'appel/politesse (Bonjour Madame), annonce claire de l'objet oublié (l'écharpe), et proposition de restitution (objet conservé + modalités de récupération). Deux phrases, registre professionnel, vouvoiement.$c370$,
  scoring_grid    = $c370$Total = 2 points. Phrase 1 : appel poli + annonce de l'objet oublié (l'écharpe) : 1 pt. Phrase 2 : objet conservé/en sécurité + proposition de restitution (modalités de récupération) : 1 pt. Retirer 0,5 pt en cas de registre non professionnel (tutoiement, absence de politesse) ou de message dépassant/n'atteignant pas deux phrases utiles.$c370$
WHERE source_ref = 'TAXI-M5-QC-08' AND type='qr';

-- ⚠️ TAXI-M5-QC-09 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Contexte : à l'approche de l'aéroport, le client pressé n'a donné aucune précision. On attend deux questions en anglais permettant de le déposer au bon endroit (terminal et départ/arrivée).

a. Première question (terminal / compagnie) :
« Which terminal do you need, or which airline are you flying with? »
(Variante acceptée : « Do you know your terminal number? »)

b. Seconde question (départ ou arrivée) :
« Are you departing or arriving? » c'est-à-dire « Do you need the departures or the arrivals area? »
(Variantes acceptées : « Is it for departures or arrivals? »)

Attendu pédagogique : les deux questions doivent cibler les informations indispensables à une dépose correcte à l'aéroport : le terminal (ou la compagnie aérienne, qui permet de le déduire) et la zone départs/arrivées. Anglais correct, questions claires et directes vu l'urgence.$c370$,
  scoring_grid    = $c370$Total = 2 points. a. Question en anglais sur le terminal ou la compagnie aérienne : 1 pt. b. Question en anglais sur la zone départs/arrivées : 1 pt. Accepter toute paire de questions pertinentes pour la dépose (terminal, compagnie, départs/arrivées, porte). Retirer 0,5 pt si une seule question est fournie ou si l'anglais est incompréhensible.$c370$
WHERE source_ref = 'TAXI-M5-QC-09' AND type='qr';

-- ⚠️ TAXI-M5-QC-10 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Question de méthode : pourquoi, à l'épreuve de français, une réponse en phrase complète rapporte-t-elle plus de points qu'une réponse exacte en un seul mot ?

Éléments de réponse attendus :
1. L'épreuve n'évalue pas seulement l'exactitude de l'information, mais aussi la maîtrise de la langue : construction de la phrase, syntaxe, orthographe et clarté de l'expression. Un seul mot ne permet pas de démontrer ces compétences.
2. La phrase complète prouve la compréhension et la capacité à communiquer de façon professionnelle avec le client : un mot isolé peut être juste par hasard ou rester ambigu, alors qu'une phrase montre que le candidat sait reformuler, contextualiser et se faire comprendre.

Synthèse : le barème récompense la compétence de communication (langue + clarté), pas uniquement le fait de trouver la bonne information. Répondre par une phrase complète, correctement rédigée, valorise donc à la fois le fond (la bonne réponse) et la forme (l'expression), d'où un score supérieur.$c370$,
  scoring_grid    = $c370$Total = 2 points. Idée 1 : l'épreuve évalue la maîtrise de la langue et l'expression (syntaxe, orthographe, clarté), pas seulement l'information exacte : 1 pt. Idée 2 : la phrase complète démontre la compréhension et la communication professionnelle (lève l'ambiguïté d'un mot isolé) : 1 pt. Accepter une réponse qui développe correctement l'un des deux axes de façon approfondie pour l'essentiel des points.$c370$
WHERE source_ref = 'TAXI-M5-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Axe à annoncer : l'autoroute A1, dite « autoroute du Nord ». Elle passe à proximité immédiate de l'aéroport Paris-Charles de Gaulle (Roissy est directement raccordé à l'A1) et file plein nord jusqu'à Lille.

b. Justification et trajet : l'A1 relie Roissy-CDG à Lille de façon quasi directe, sans changement d'autoroute majeur, sur environ 200 à 220 km (de l'ordre de 2 heures hors trafic). On dessert successivement la région de Roissy, Senlis, Compiègne, puis l'Artois (Arras) avant d'arriver sur la métropole lilloise. Aucun grand contournement n'est nécessaire : l'A1 constitue l'itinéraire de référence pour cette liaison.$c370$,
  scoring_grid    = $c370$a. Identifie le bon axe (A1 / autoroute du Nord) : 1 pt. b. Justifie (raccordement direct de CDG à l'A1, liaison directe vers Lille, ordre de grandeur distance/durée cohérent) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M6-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Gare de dépose : la gare de Paris-Lyon (gare de Lyon).

b. Pourquoi : à Paris, chaque grande gare est spécialisée par direction. La gare de Lyon dessert l'axe sud-est de la France : les TGV vers Lyon, la vallée du Rhône, Marseille et l'ensemble de la façade méditerranéenne y sont au départ. Un client voyageant vers Marseille en TGV part donc de la gare de Lyon (et non de la gare Montparnasse, qui dessert l'Ouest et le Sud-Ouest, ni de la gare du Nord ou de l'Est). Connaître cette répartition des gares parisiennes par grande direction évite de déposer le client au mauvais terminal et de lui faire manquer son train.$c370$,
  scoring_grid    = $c370$a. Nomme la bonne gare (Paris-Lyon / gare de Lyon) : 1 pt. b. Justifie par la spécialisation des gares parisiennes par direction (gare de Lyon = axe sud-est / Méditerranée) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M6-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Information à vérifier impérativement : l'échelle du plan (par exemple 1/10 000, soit 1 cm sur le plan = 100 m sur le terrain).

b. Pourquoi : la mesure faite à la règle ne donne qu'une distance sur le papier (en centimètres). Cette distance n'a de sens qu'une fois multipliée par l'échelle pour être convertie en distance réelle. Sans connaître l'échelle, la longueur mesurée n'est pas exploitable. Il faut également s'assurer de l'unité utilisée et vérifier que l'échelle est bien celle du plan consulté (les échelles diffèrent d'un plan à l'autre). Le calcul type est : distance réelle = distance mesurée sur le plan × dénominateur de l'échelle.$c370$,
  scoring_grid    = $c370$a. Cite l'échelle du plan comme information à vérifier : 1,5 pt. b. Explique correctement l'usage (conversion mesure sur plan → distance réelle via l'échelle) : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M6-QC-03' AND type='qr';

-- ⚠️ TAXI-M6-QC-04 : La fourchette (20-30 min) et la vitesse commerciale (~10-15 km/h) sont des ordres de grandeur professionnels estimés, non des valeurs réglementaires : elles varient selon la ville et le trafic. La notation porte sur la cohérence du raisonnement vitesse/temps et l'annonce en fourchette, pas sur des chiffres exacts ; toute réponse justifiée par un calcul temps = distance ÷ vitesse cohérent est recev
UPDATE public.question_bank SET
  expected_answer = $c370$a. Fourchette à annoncer : de l'ordre de 20 à 30 minutes pour 5 km.

b. Base du raisonnement : en hypercentre à l'heure de pointe, la vitesse commerciale (vitesse réellement pratiquée, feux, congestion et arrêts compris) tombe couramment autour de 10 à 15 km/h. On applique la relation temps = distance ÷ vitesse : à 15 km/h, 5 km demandent environ 20 minutes ; à 10 km/h, environ 30 minutes. D'où une estimation prudente de 20 à 30 minutes. Il s'agit d'une estimation professionnelle et non d'un temps garanti : on annonce une fourchette (et non une valeur unique) parce que le trafic aux heures de pointe est variable, et l'on précise au client que la durée dépend des conditions de circulation.$c370$,
  scoring_grid    = $c370$a. Annonce une fourchette cohérente (de l'ordre de 20 à 30 min, valeur voisine acceptée) : 1 pt. b. Justifie la base (vitesse commerciale faible en centre-ville aux heures de pointe ~10-15 km/h, calcul temps = distance ÷ vitesse, raisonnement en fourchette) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M6-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Trois critères à comparer avant de choisir entre l'autoroute à péage et l'itinéraire alternatif gratuit :

a. Le temps de parcours : gain de temps réel de l'autoroute une fois tenu compte du trafic (l'autoroute n'est pas toujours plus rapide en cas de bouchons).

b. Le coût : montant du péage, auquel s'ajoute la consommation de carburant, à mettre en regard de l'économie de péage de l'itinéraire gratuit (souvent plus long en kilomètres).

c. La distance / le kilométrage et les conditions de circulation : longueur respective des deux itinéraires, état du trafic, météo et facilité de conduite.

À retenir en plus : le choix d'un itinéraire à péage a une incidence sur le prix payé par le client. Le chauffeur doit informer le client et obtenir son accord avant d'emprunter un parcours à péage ; à défaut d'accord, le supplément de péage reste à la charge du chauffeur. Trois critères suffisent pour la note, mais la transparence envers le client est déterminante.$c370$,
  scoring_grid    = $c370$Trois critères pertinents attendus, environ 0,66 pt chacun (temps de parcours ; coût péage + carburant ; distance/kilométrage ou conditions de trafic). Barème pratique : 2 critères = 1,5 pt, 3 critères = 2 pts. Bonus de cohérence sans dépasser 2 pts si l'accord du client est mentionné. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M6-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Ce que révèle l'incident : le GPS n'est pas une source infaillible. Sa cartographie est mise à jour avec un décalage et ne reflète pas toujours les changements récents de voirie (nouvelle zone piétonne, sens interdit, travaux, rue barrée). L'incident montre qu'un GPS ne remplace pas la connaissance du terrain et la lecture de la signalisation réelle : le conducteur reste seul responsable du respect du code de la route et des arrêtés de circulation, même quand le GPS l'oriente vers une voie interdite.

b. Le réflexe à adopter : la signalisation sur le terrain prime toujours sur l'instruction du GPS. On ne s'engage jamais dans une rue interdite parce que le GPS le demande ; on lit les panneaux, on adapte l'itinéraire, et on entretient sa propre connaissance de la ville. En complément, on met régulièrement à jour la cartographie de son GPS et on croise l'application avec l'observation directe pour anticiper les fermetures et zones piétonnes.$c370$,
  scoring_grid    = $c370$a. Identifier que le GPS est faillible / cartographie non à jour et que la connaissance terrain reste indispensable : 1 pt. b. Énoncer le bon réflexe : la signalisation réelle prime sur le GPS, on ne s'engage pas dans une voie interdite (mise à jour de la carte acceptée en complément) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M6-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Deux réflexes professionnels à avoir avant de démarrer lorsque le client impose un itinéraire plus long que le vôtre :

1. Respecter le choix du client et le confirmer. Le client est en droit de choisir sa route ; le conducteur applique l'itinéraire demandé sans s'y opposer, après avoir reformulé/confirmé le trajet souhaité pour être sûr de bien l'avoir compris.

2. Informer clairement le client que cet itinéraire est plus long et donc plus coûteux, et s'assurer de son accord avant de partir. Cette transparence sur la distance, la durée et le prix (course au compteur pour le taxi) protège le professionnel de toute contestation ultérieure et matérialise le consentement du client.$c370$,
  scoring_grid    = $c370$Réflexe 1 : respecter et confirmer le choix d'itinéraire du client : 1 pt. Réflexe 2 : prévenir le client que le trajet est plus long/plus cher et obtenir son accord avant de démarrer : 1 pt. Total = 2 pts (1 pt par réflexe correctement énoncé).$c370$
WHERE source_ref = 'TAXI-M6-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Trois grandes gares parisiennes et une desserte caractéristique pour chacune (toute réponse cohérente parmi les exemples suivants est acceptée) :

1. Gare du Nord : dessert le nord de la France et l'international vers le nord (Lille, et liaisons internationales Eurostar vers Londres, Bruxelles et Amsterdam).

2. Gare de Lyon : dessert le sud-est de la France par TGV (Lyon, Marseille, Dijon, vallée du Rhône et Méditerranée).

3. Gare Montparnasse : dessert l'ouest et le sud-ouest par TGV Atlantique (Bretagne, Nantes, Bordeaux).

Autres réponses valables : Gare de l'Est (est de la France : Strasbourg, Nancy, Reims) ; Gare Saint-Lazare (Normandie : Rouen, Le Havre, Caen) ; Gare d'Austerlitz (centre et sud-ouest : Orléans, Limoges, Toulouse).$c370$,
  scoring_grid    = $c370$1 couple gare + desserte caractéristique correctement associé = 2/3 pt (env. 0,67 pt) ; trois couples corrects = 2 pts. Barème pratique : 3 gares correctes = 2 pts, 2 gares = 1,3 pt, 1 gare = 0,7 pt. Une gare citée sans desserte cohérente ne compte pas.$c370$
WHERE source_ref = 'TAXI-M6-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Méthode pour compter les sorties d'un rond-point sans se tromper :

On compte les sorties dans l'ordre où on les rencontre en tournant, c'est-à-dire dans le sens de circulation du rond-point (en France, sens anti-horaire, la première sortie se trouvant sur la droite). La première voie de sortie que l'on croise après être entré est la sortie n°1, la suivante la n°2, et ainsi de suite jusqu'à la troisième que l'on emprunte.

Points de vigilance : on compte chaque sortie réellement praticable, y compris les petites rues et les sorties que l'on ne prend pas ; on ne compte pas la voie par laquelle on est entré. En cas de doute, on ralentit et on refait un tour du rond-point plutôt que de sortir au mauvais endroit.$c370$,
  scoring_grid    = $c370$Méthode correcte : compter chaque sortie une à une dans le sens de circulation, en partant de la première voie rencontrée après l'entrée, jusqu'à la troisième : 2 pts. Réponse partielle (idée de compter dans l'ordre mais sans préciser le point de départ ou l'inclusion de toutes les sorties) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M6-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Trois actions de préparation avant la première course dans une ville inconnue :

1. Étudier la carte et la géographie de la ville : repérer les grands axes, le centre-ville, les gares, l'aéroport, les hôpitaux, les principaux hôtels, quartiers d'affaires et points d'intérêt, ainsi que les emplacements des stations de taxi (bornes).

2. Préparer et tester son outil de navigation : mettre à jour la cartographie du GPS ou de l'application, vérifier son bon fonctionnement, et l'utiliser en le croisant avec sa propre connaissance plutôt qu'en s'y fiant aveuglément.

3. Effectuer une reconnaissance sur le terrain : rouler dans la ville aux heures creuses pour mémoriser les itinéraires, repérer les sens uniques, les zones piétonnes, les conditions de circulation et de stationnement, et localiser concrètement les stations de taxi.$c370$,
  scoring_grid    = $c370$Chaque action de préparation pertinente = 2/3 pt (env. 0,67 pt) ; trois actions correctes = 2 pts. Barème pratique : 3 actions valables = 2 pts, 2 actions = 1,3 pt, 1 action = 0,7 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M6-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La plaque fixée à l'extérieur du véhicule (plaque ADS) porte deux informations qui identifient l'autorisation attachée au taxi :

1. Le numéro de l'autorisation de stationnement (ADS), c'est-à-dire le numéro de la « licence » qui autorise le véhicule à stationner et à marauder en quête de clients.

2. Le nom de la commune (ou de l'autorité) de rattachement qui a délivré cette autorisation, ce qui délimite le territoire d'exploitation principal du taxi.

Ces deux mentions permettent de rattacher le véhicule à une ADS précise et à la commune émettrice, et d'en assurer le contrôle.$c370$,
  scoring_grid    = $c370$1 pt : numéro de l'autorisation de stationnement (ADS / licence). 1 pt : commune (autorité) de rattachement qui a délivré l'ADS. Total = 2.$c370$
WHERE source_ref = 'TAXI-M7-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le prix affiché au taximètre (compteur horokilométrique) résulte de la combinaison de trois composantes, dans le cadre des tarifs fixés par arrêté préfectoral :

1. La prise en charge : montant fixe facturé au démarrage de la course, indépendant de la distance et du temps.

2. Le tarif kilométrique : montant proportionnel à la distance parcourue, décompté par le taximètre au fil des kilomètres (variable selon le tarif applicable : jour/nuit, en charge/retour, etc.).

3. Le tarif horaire (temps) : rémunération du temps, qui prend le relais lorsque le véhicule roule très lentement ou est à l'arrêt (attente, marche au pas, embouteillage).

Le montant total de la course est la somme de la prise en charge et de la part calculée soit au kilomètre, soit à l'heure selon la vitesse, dans le respect éventuel d'un minimum de perception.$c370$,
  scoring_grid    = $c370$Environ 0,67 pt par composante correctement citée (prise en charge ; tarif kilométrique/distance ; tarif horaire/temps d'attente). Barème pratique : 2 pts si les trois sont citées, ~1,3 pt pour deux, ~0,7 pt pour une. Total = 2.$c370$
WHERE source_ref = 'TAXI-M7-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le document est la prescription médicale de transport (PMT), établie et signée par le médecin prescripteur.

Elle atteste que l'état de santé du patient justifie un transport (assis, en taxi conventionné) et en précise le motif. C'est ce document qui ouvre le droit à la prise en charge par l'assurance maladie : sans prescription médicale de transport valable, la course effectuée par un taxi conventionné ne peut pas être facturée à l'assurance maladie (le patient devrait alors régler la course comme une course ordinaire). Le taxi doit par ailleurs être conventionné avec l'assurance maladie pour pratiquer le tiers payant sur cette base.$c370$,
  scoring_grid    = $c370$2 pts : identification correcte du document = prescription médicale de transport (accepter « bon de transport » / prescription de transport). 1 pt seulement si la réponse évoque un « certificat médical » sans nommer la prescription de transport. Total = 2.$c370$
WHERE source_ref = 'TAXI-M7-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Objet (à quoi ça sert) : la vérification périodique du taximètre garantit que l'instrument mesure exactement la distance et le temps et applique correctement les tarifs réglementés. Relevant de la métrologie légale, elle protège le consommateur contre un compteur déréglé (surfacturation) et assure la loyauté commerciale ; sans vignette de vérification en cours de validité, le taximètre n'est pas réputé fiable pour facturer.

Par qui : elle est réalisée non par le chauffeur mais par un organisme de vérification agréé en métrologie légale (vérificateur agréé), sous le contrôle de l'administration (services de l'État chargés de la métrologie / DREAL). L'instrument conforme reçoit une marque/vignette de vérification attestant sa validité.

Périodicité : il s'agit d'une vérification périodique annuelle (tous les ans), conformément à la réglementation de métrologie légale applicable aux taximètres.$c370$,
  scoring_grid    = $c370$1 pt : la finalité (garantir l'exactitude de la mesure/des tarifs, fiabilité du compteur, protection du client). 1 pt : l'auteur (organisme/vérificateur agréé de métrologie légale, sous contrôle de l'État/DREAL, et non le chauffeur). Total = 2. La périodicité chiffrée (annuelle) n'est pas exigée pour le barème mais peut être valorisée en bonus.$c370$
WHERE source_ref = 'TAXI-M7-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Composante qui prend le relais : le tarif horaire (facturation au temps), correspondant à l'attente / à la marche au pas.

Pourquoi : le taximètre calcule le prix selon deux modes qui basculent en fonction de la vitesse. Au-dessus d'un certain seuil de vitesse (vitesse de bascule), c'est le tarif kilométrique qui s'applique (on facture la distance). En dessous de ce seuil, à l'arrêt ou au pas dans un embouteillage, la distance parcourue devient quasi nulle et ne rémunérerait plus le chauffeur : le compteur bascule alors automatiquement sur le tarif horaire, qui décompte le temps d'immobilisation. Cela permet de rémunérer équitablement le temps passé par le chauffeur (véhicule et conducteur mobilisés) même sans kilomètres parcourus, tout en restant dans le cadre des tarifs fixés par arrêté préfectoral. Le client paie donc le temps d'attente et non une distance inexistante.$c370$,
  scoring_grid    = $c370$1 pt : identification de la composante = tarif horaire / facturation au temps (attente, marche au pas). 1 pt : justification = bascule en dessous d'un seuil de vitesse, car la distance ne rémunère plus le temps immobilisé (rémunération du temps du chauffeur). Total = 2.$c370$
WHERE source_ref = 'TAXI-M7-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Non, le chauffeur ne peut pas refuser une course au seul motif qu'elle est trop courte.

a. Principe applicable : un taxi en station ou en maraude, lumineux allumé et libre, est réputé en service ; il a l'obligation de prendre en charge le client qui le sollicite, quelle que soit la distance demandée. Une course de 500 mètres doit donc être acceptée comme n'importe quelle autre.

b. Conséquence d'un refus : le refus de course non justifié constitue un manquement (refus de prise en charge) exposant le chauffeur à une sanction (contravention et, en cas de récidive ou de manquement grave, mesures administratives sur l'autorisation d'exploiter). La brièveté du trajet n'est jamais un motif légitime.

c. Nuance : le chauffeur conserve la possibilité de refuser une course pour un motif légitime et objectif (client manifestement dangereux, agressif ou ne pouvant régler la course, sécurité compromise, destination hors ressort en fin de service selon les règles locales), mais jamais au prétexte d'un montant jugé insuffisant. Le tarif de la course, même courte, reste protégé par le montant minimal de perception fixé par l'arrêté préfectoral.$c370$,
  scoring_grid    = $c370$a. Réponse « non » + obligation de prise en charge du taxi en service quelle que soit la distance : 1 pt. b. Refus injustifié = manquement sanctionnable / distance non recevable comme motif : 0,5 pt. c. Mention d'un motif légitime réel (autre que la distance) ou du montant minimal de perception : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M7-QC-06' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Un taxi ne peut exercer la maraude (circuler ou stationner en quête de clientèle et prendre en charge un client hélé sur la voie) que dans le ressort géographique de son autorisation de stationnement (ADS).

a. Ressort de l'ADS : l'ADS est rattachée à une commune (ou à un service commun / une zone intercommunale lorsqu'un tel périmètre existe). C'est à l'intérieur de ce ressort que le taxi peut stationner aux emplacements réservés (têtes de station) et marauder.

b. Hors du ressort : en dehors de sa zone, le taxi ne peut ni marauder ni stationner en attente de clientèle. Il peut en revanche y déposer un client (trajet terminant hors zone) et, s'il a été réservé à l'avance, y prendre en charge le client qui l'a réservé.

c. Distinction avec le VTC : cette contrainte territoriale est propre au taxi ; elle découle du privilège de la maraude, que le VTC n'a pas (le VTC travaille uniquement sur réservation préalable, sans limite de zone pour la prise en charge réservée).$c370$,
  scoring_grid    = $c370$a. Maraude/stationnement limités au ressort de l'ADS (commune ou zone de rattachement) : 1 pt. b. Interdiction de marauder hors zone, mais dépôt possible et prise en charge sur réservation possible : 0,5 pt. c. Rattachement au privilège de la maraude / distinction avec le VTC : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M7-QC-07' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Outre la maraude proprement dite (client hélé sur la voie), l'activité du taxi repose sur plusieurs marchés complémentaires. Trois d'entre eux :

a. Les stations (têtes de station) : emplacements réservés sur la voie publique où le taxi stationne en attente ; c'est une source de clientèle régulière, notamment aux gares, aéroports, hôpitaux et pôles d'échange.

b. La réservation préalable : courses obtenues par téléphone, radio, centrale ou application mobile, ainsi que les comptes clients d'entreprises. Ce marché sécurise l'activité en programmant les courses à l'avance.

c. Le conventionné / marchés contractuels : transport de malades assis conventionné avec l'Assurance maladie (CPAM), transports scolaires, marchés avec des collectivités ou des entreprises. Ces contrats apportent un chiffre d'affaires récurrent et planifié.$c370$,
  scoring_grid    = $c370$Trois marchés valides attendus, environ 0,67 pt chacun (arrondi pour atteindre 2). Stations : 0,7 pt ; réservation préalable (téléphone / central / appli / comptes entreprises) : 0,7 pt ; conventionné ou marchés contractuels (transport médical assis CPAM, scolaire, collectivités) : 0,6 pt. Total = 2 pts. Toute réponse citant trois de ces canaux distincts obtient le maximum.$c370$
WHERE source_ref = 'TAXI-M7-QC-08' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$La distinction repose sur le taux de charge, c'est-à-dire la part de kilomètres parcourus avec un client à bord et donc facturés.

a. Retour en charge : après avoir déposé un client, le taxi reprend immédiatement une course dans l'autre sens (ou depuis une station bien alimentée). Le trajet de retour génère lui aussi une recette : les kilomètres sont productifs dans les deux sens, ce qui maximise le chiffre d'affaires par rapport aux coûts fixes et au carburant.

b. Retour à vide : le taxi revient sans client vers sa zone ou sa station. Ces kilomètres sont subis : ils consomment du carburant et du temps sans aucune recette, ce qui dégrade la rentabilité.

c. Logique économique : le chauffeur cherche à privilégier les positions et les créneaux où le retour a de fortes chances de se faire en charge (flux équilibrés entre deux pôles), car chaque kilomètre à vide est un coût sans revenu qui abaisse la marge de la journée.$c370$,
  scoring_grid    = $c370$a. Retour en charge = kilomètres du retour facturés / productifs (double recette) : 0,75 pt. b. Retour à vide = kilomètres sans recette mais avec coûts (carburant, temps) : 0,75 pt. c. Conclusion économique : optimiser le taux de charge / privilégier les positions à retour en charge pour préserver la marge : 0,5 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M7-QC-09' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Principe méconnu : l'obligation d'exploitation effective et continue de l'autorisation de stationnement (ADS). Une ADS n'est pas un droit dormant que l'on conserve en attendant une meilleure conjoncture : elle est délivrée pour être réellement exploitée. Laisser une ADS inexploitée pendant des mois méconnaît ce principe.

b. Ce à quoi il s'expose : l'autorité qui a délivré l'ADS (le maire, ou le préfet de police à Paris) peut constater le défaut d'exploitation et prononcer le retrait de l'autorisation. Le titulaire risque donc de perdre purement et simplement son ADS, sans indemnité.

c. Enjeu patrimonial : pour les ADS récentes délivrées à titre gratuit, l'autorisation est en outre incessible et strictement conditionnée à une exploitation effective ; l'inexploitation en accélère le retrait. Pour les ADS plus anciennes (cessibles), l'absence d'exploitation fait aussi peser un risque de retrait et compromet la valeur de revente. Dans tous les cas, la logique est la même : l'ADS se conserve en l'exploitant, pas en la gelant.$c370$,
  scoring_grid    = $c370$a. Identification du principe : obligation d'exploitation effective et continue de l'ADS : 1 pt. b. Sanction encourue : retrait de l'ADS par l'autorité de délivrance : 0,75 pt. c. Précision complémentaire (incessibilité/gratuité des ADS récentes conditionnée à l'exploitation, ou perte de valeur) : 0,25 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M7-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Document justificatif : c'est le justificatif de la réservation préalable (bon/ordre de course, confirmation de réservation ou contrat de mise à disposition). Le VTC ne pouvant pas faire de maraude, toute prise en charge doit reposer sur une réservation faite à l'avance ; le conducteur doit pouvoir en apporter la preuve à tout moment lors d'un contrôle. Ce justificatif fait le lien entre le client transporté et la réservation enregistrée (identité ou référence du client, date et heure de prise en charge, lieu de départ et de destination).

b. Formes de présentation : il peut être présenté soit sous forme papier (impression, bon de commande), soit sous forme dématérialisée/électronique (écran du smartphone, de la tablette ou du terminal de l'application de réservation). Les deux formes sont recevables ; l'essentiel est que le document soit disponible et présentable immédiatement au contrôle.$c370$,
  scoring_grid    = $c370$a. Identifier le justificatif de la réservation préalable comme document justifiant la prise en charge : 1 pt. b. Indiquer les deux formes de présentation possibles (papier et dématérialisée/électronique) : 1 pt (0,5 pt par forme). Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M8-QC-01' AND type='qr';

-- ⚠️ TAXI-M8-QC-02 : Correction du barème : la version initiale indiquait « 1 pt pour chaque mention » (soit 3 pts pour trois mentions), incohérent avec max_score = 2. Reformulé en 0,67 pt/mention plafonné à trois → total 2 pts. La valeur unitaire fractionnaire (0,67) est un arrondi de grille à valider par le concepteur ; l'échelle pratique (3=2 / 2≈1,3 / 1≈0,7) reste exacte au plafond.
UPDATE public.question_bank SET
  expected_answer = $c370$Trois mentions d'un devis VTC conforme (parmi les bonnes pratiques attendues) :

a. L'identification de l'entreprise : raison sociale/nom de l'exploitant, coordonnées, numéro SIREN et numéro d'inscription au registre des VTC.

b. La description détaillée de la prestation : trajet (lieu de départ et de destination), date et heure de prise en charge, éventuellement type de véhicule et nombre de passagers.

c. Le prix total à payer, exprimé TTC (tarification libre en VTC), avec le cas échéant le détail des éléments de prix et les conditions (durée de validité du devis, identité du client, date d'établissement).

Toute réponse citant trois de ces mentions (identité/coordonnées de l'exploitant, description de la course, prix TTC, validité du devis, identité du client, date) est acceptée.$c370$,
  scoring_grid    = $c370$0,67 pt par mention pertinente citée, plafonné aux trois mentions demandées. Barème pratique : 3 mentions correctes = 2 pts ; 2 mentions ≈ 1,3 pt ; 1 mention ≈ 0,7 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M8-QC-02' AND type='qr';

-- ⚠️ TAXI-M8-QC-03 : Correction du barème : la version initiale indiquait « 1 pt par type » (soit 3 pts pour trois types), incohérent avec max_score = 2. Reformulé en 0,67 pt/type plafonné à trois → total 2 pts. Valeur unitaire (0,67) = arrondi de grille à valider ; l'échelle pratique reste exacte au plafond.
UPDATE public.question_bank SET
  expected_answer = $c370$Trois types de clients à démarcher pour se constituer une clientèle propre, hors plateformes (exemples attendus, trois suffisent) :

a. Les hôtels (notamment de standing) et leurs conciergeries, qui commandent des transferts pour leurs clients.

b. Les entreprises et comptes affaires (déplacements de collaborateurs, séminaires, transferts de dirigeants, navettes gare/aéroport).

c. Les restaurants, agences de voyage et d'événementiel, établissements de santé (cliniques), ou une clientèle de particuliers fidélisés (abonnements, courses récurrentes).

Toute réponse citant trois catégories distinctes de prescripteurs ou de clients réguliers hors plateformes est acceptée.$c370$,
  scoring_grid    = $c370$0,67 pt par type de client pertinent, plafonné aux trois types demandés. Barème pratique : 3 types corrects = 2 pts ; 2 types ≈ 1,3 pt ; 1 type ≈ 0,7 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M8-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Le VTC n'a pas le droit de faire la maraude ni de stationner sur la voie publique en quête ou en attente de clients. À la fin d'une course sans réservation suivante enregistrée, les deux options conformes sont :

a. Regagner le lieu d'établissement de l'exploitant (base, local ou garage de l'entreprise) pour y attendre une nouvelle réservation.

b. Stationner sur un emplacement où le stationnement est régulièrement autorisé, en dehors de la voie publique/de la chaussée (par exemple un parking), et non en position de racolage ; le conducteur ne peut rester en stationnement sur la voie publique en attente de clientèle que s'il justifie d'une réservation à venir.

En résumé : retour à la base, ou stationnement sur un emplacement autorisé hors quête de clients ; la maraude et le stationnement d'attente sur la voie publique sont interdits.$c370$,
  scoring_grid    = $c370$a. Option 1 : regagner le lieu d'établissement / la base de l'exploitant : 1 pt. b. Option 2 : stationner sur un emplacement autorisé hors voie publique, sans se mettre en quête/attente de clients : 1 pt. Mention que la maraude est interdite valorisée mais non indispensable. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M8-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$En zone aéroportuaire, la distinction repose sur le principe VTC (réservation préalable, pas de maraude) :

a. Ce qui est libre : la prise en charge (et la dépose) de clients ayant effectué une réservation préalable. Un VTC peut librement venir déposer ou récupérer un client sur réservation, comme partout ailleurs.

b. Ce qui est conditionné : l'accès et le stationnement dans les zones dédiées de l'aéroport (aires d'attente, dépose-minute réservées, parkings professionnels). Le gestionnaire de la plateforme aéroportuaire soumet cet accès à des conditions : détention d'un badge ou d'une vignette/autorisation d'accès, paiement d'une redevance, respect des zones réservées et des règles de circulation propres au site. Le stationnement en attente de clients sur les zones réservées aux taxis, ainsi que toute forme de maraude, restent interdits au VTC.

En résumé : est libre la prise en charge sur réservation ; est conditionné l'accès/le stationnement dans les zones aéroportuaires dédiées (badge, redevance, zones réservées).$c370$,
  scoring_grid    = $c370$a. Identifier ce qui est libre : la prise en charge/dépose sur réservation préalable : 1 pt. b. Identifier ce qui est conditionné : l'accès et le stationnement dans les zones dédiées de l'aéroport (badge/autorisation, redevance, zones réservées gérées par l'exploitant aéroportuaire) : 1 pt. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M8-QC-05' AND type='qr';

-- ⚠️ TAXI-M8-QC-06 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$On dit que la vraie marge du VTC se trouve dans la clientèle propre parce que le passage par les plateformes de réservation ampute fortement la rentabilité de chaque course. a. Effet des plateformes : la plateforme prélève une commission significative sur chaque course (souvent de l'ordre de 20 à 30 % du prix payé par le client). Elle impose aussi ses prix, sa relation client et ne laisse au chauffeur aucune maîtrise de la fidélisation. La marge nette par course est donc mécaniquement réduite. b. Effet de la clientèle propre : quand le chauffeur travaille avec ses propres clients (démarchage direct, bouche-à-oreille, entreprises, site de réservation personnel), il encaisse 100 % du prix sans commission d'intermédiaire, fixe librement sa tarification (la tarification VTC est libre) et fidélise le client sur le long terme (courses régulières, transferts récurrents). C'est cette part directe, à marge pleine et récurrente, qui construit la rentabilité réelle de l'activité, la plateforme servant surtout à remplir les heures creuses.$c370$,
  scoring_grid    = $c370$1 pt : la commission de la plateforme (et l'absence de maîtrise du prix) réduit la marge par course. 1 pt : la clientèle propre supprime la commission, permet la tarification libre et la fidélisation, d'où une marge pleine et récurrente. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M8-QC-06' AND type='qr';

-- ⚠️ TAXI-M8-QC-07 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Pour un transfert aéroport avec un vol susceptible de retard, deux bonnes pratiques de gestion de l'attente sont : a. Suivre le numéro de vol en temps réel : demander systématiquement le numéro de vol à la réservation et surveiller son statut (heure d'atterrissage réelle) via un outil de suivi aérien, afin d'ajuster l'heure de prise en charge et de ne se présenter qu'au bon moment, sans attente inutile ni client livré à lui-même. b. Encadrer contractuellement l'attente à l'avance : convenir avec le client, dès le devis ou la confirmation, des conditions d'attente (durée de battement offerte après l'atterrissage, puis facturation du temps d'attente au-delà, modalités en cas d'annulation du vol). Cela évite tout litige et sécurise la rémunération du temps immobilisé. (Autres pratiques recevables : rester joignable et communiquer avec le client, prévoir un point de rencontre précis à la sortie des bagages, intégrer une marge de sécurité dans le planning.)$c370$,
  scoring_grid    = $c370$1 pt par bonne pratique pertinente et correctement expliquée, dans la limite de 2 pratiques. Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M8-QC-07' AND type='qr';

-- ⚠️ TAXI-M8-QC-08 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$L'erreur porte sur l'assiette de déclaration. a. Ce qu'il fait de faux : en micro-entreprise, il calcule ses cotisations sociales (et déclare son chiffre d'affaires) sur le montant net réellement viré par les plateformes, c'est-à-dire après déduction de leur commission. b. La règle : le micro-entrepreneur doit déclarer son chiffre d'affaires BRUT, soit le montant total payé par le client pour la course, avant toute commission. En régime micro, aucune charge n'est déductible du chiffre d'affaires (les frais et commissions sont réputés couverts par l'abattement forfaitaire) ; la commission de la plateforme n'a donc pas à être retranchée de l'assiette. c. Conséquence : en déclarant seulement le net, il sous-déclare son chiffre d'affaires, paie donc trop peu de cotisations et de contribution, et s'expose à un redressement URSSAF avec régularisation et pénalités en cas de contrôle.$c370$,
  scoring_grid    = $c370$1 pt : l'assiette correcte est le chiffre d'affaires brut (prix total payé par le client), la commission plateforme n'étant pas déductible en micro-entreprise. 1 pt : conséquence identifiée (sous-déclaration du CA, cotisations minorées, risque de redressement). Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M8-QC-08' AND type='qr';

-- ⚠️ TAXI-M8-QC-09 : [NON VÉRIFIÉ — relecture formateur requise] [À CONFIRMER : montant exact de l'amende et nature précise de la sanction (contravention ou délit, plafond d'amende, peine éventuelle, conditions de retrait/suspension de la carte professionnelle) pour prise en charge d'un client sans réservation préalable par un VTC, au regard du Code des transports en vigueur. Le corrigé reste volontairement qualitatif
UPDATE public.question_bank SET
  expected_answer = $c370$a. Qualification : le VTC est soumis à l'obligation de réservation PRÉALABLE. Une réservation horodatée APRÈS la prise en charge du client prouve qu'au moment où le client est monté à bord, aucune réservation préalable n'existait. La course a donc été prise en charge sans réservation préalable, ce qui équivaut à de la maraude (prise de client à la volée), strictement interdite au VTC et réservée au taxi disposant d'une autorisation de stationnement. L'horodatage a posteriori s'analyse comme une tentative de régulariser après coup, sans valeur probante. b. Conséquences : constat d'infraction pour exercice illégal de maraude / défaut de réservation préalable, avec sanction financière et risque de mesures administratives à l'encontre du chauffeur (pouvant aller jusqu'au retrait ou à la suspension de la carte professionnelle et à l'immobilisation du véhicule). La preuve de la réservation préalable étant obligatoire à bord, le chauffeur ne peut pas la produire valablement.$c370$,
  scoring_grid    = $c370$1 pt : la réservation postérieure caractérise l'absence de réservation préalable, assimilée à de la maraude interdite au VTC. 1 pt : conséquence (infraction constatée, sanction financière et risque administratif sur la carte professionnelle / le véhicule). Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M8-QC-09' AND type='qr';

-- ⚠️ TAXI-M8-QC-10 : [NON VÉRIFIÉ — relecture formateur requise]
UPDATE public.question_bank SET
  expected_answer = $c370$Trois arguments de différenciation propres au VTC face à un taxi, pour un client d'affaires en transferts réguliers : a. Prix connu et garanti à l'avance : la tarification VTC est libre et le prix est fixé et accepté au moment de la réservation (forfait), sans compteur horokilométrique ni surprise liée aux embouteillages ; le client d'affaires maîtrise et anticipe son budget de déplacement. b. Réservation planifiée et chauffeur attitré : la course se fait uniquement sur réservation préalable, ce qui permet de programmer des transferts récurrents, d'avoir un chauffeur dédié qui connaît les habitudes du client, et une prise en charge fiable à l'heure convenue (utile pour les vols et rendez-vous). c. Prestation et facturation adaptées à l'entreprise : véhicule haut de gamme et service soigné (discrétion, confort, silence propice au travail), avec une facturation détaillée facilitant la note de frais et la gestion comptable, voire un compte entreprise et un paiement centralisé. (Autre argument recevable : confidentialité et relation commerciale directe sans intermédiaire.)$c370$,
  scoring_grid    = $c370$0,5 pt pour chacun des trois arguments pertinents et propres au VTC (soit 1,5 pt) + 0,5 pt pour la qualité de la justification orientée client d'affaires (transferts réguliers, budget, note de frais). Total = 2 pts.$c370$
WHERE source_ref = 'TAXI-M8-QC-10' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Il s'agit de deux autorités distinctes, qu'il ne faut pas confondre.

a. L'autorisation de stationnement (ADS, communément appelée « licence »), qui permet à un taxi de stationner et de circuler en quête de clients (maraude) sur un territoire donné, est délivrée par le maire de la commune (ou, à Paris, par le préfet de police). C'est une autorisation attachée à un territoire d'exploitation.

b. La carte professionnelle de conducteur de taxi (comme celle de conducteur VTC) est délivrée par le préfet du département où le conducteur souhaite exercer (à Paris, le préfet de police). Elle atteste que la personne remplit les conditions d'aptitude (examen T3P réussi, casier, visite médicale, PSC1) et l'autorise à exercer le métier de conducteur.

En résumé : l'ADS autorise le stationnement/la maraude sur un territoire (autorité communale : le maire) ; la carte professionnelle autorise la personne à conduire (autorité préfectorale).$c370$,
  scoring_grid    = $c370$a. ADS délivrée par le maire (préfet de police à Paris) : 1 pt. b. Carte professionnelle délivrée par le préfet de département (préfet de police à Paris) : 1 pt. Total = 2.$c370$
WHERE source_ref = 'TAXI-M9-QC-01' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Ce qui lui est reproché : le conducteur VTC pratique une prise en charge irrégulière assimilable à de la maraude. Or la maraude, c'est-à-dire le fait de stationner ou de circuler en quête de clients et de prendre en charge un client qui n'a pas réservé, est strictement réservée aux taxis titulaires d'une ADS. Le VTC a l'obligation d'une réservation préalable : il ne peut ni racoler, ni stationner devant une gare ou un aéroport pour capter la clientèle de passage, ni prendre un client « à la volée ». Le stationnement en attente sur la voie publique en quête de clients lui est également interdit. Ce comportement l'expose à des sanctions (contravention, voire sanctions pénales et administratives).

b. Ce qu'il devrait pouvoir présenter : la preuve d'une réservation préalable de la course (justificatif de réservation émis avant la prise en charge, par exemple via une plateforme ou une centrale, comportant les éléments d'identification de la course). C'est ce document qui matérialise le caractère régulier de la prise en charge pour un VTC. Entre deux courses, il doit en principe regagner son lieu d'établissement (ou un lieu de stationnement hors chaussée), sauf s'il justifie d'une réservation à venir.$c370$,
  scoring_grid    = $c370$a. Identifier le grief : maraude/prise en charge sans réservation, interdite au VTC (maraude réservée aux taxis) : 1 pt. b. Justificatif de réservation préalable à présenter pour une prise en charge régulière : 1 pt. Total = 2.$c370$
WHERE source_ref = 'TAXI-M9-QC-02' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Les deux durées de cinq ans encadrent l'accès au marché de chaque profession.

a. Côté VTC : l'inscription au registre des exploitants VTC est valable cinq ans. Elle doit être renouvelée à l'échéance pour continuer d'exercer. C'est la condition d'accès à l'activité pour l'entreprise de VTC (justification notamment de la capacité financière, de l'assurance et des véhicules).

b. Côté taxi : les autorisations de stationnement (ADS) délivrées depuis la loi du 1er octobre 2014 (loi Thévenoud) sont incessibles et délivrées pour une durée de cinq ans, renouvelable (art. L3121-2 du Code des transports). Leur caractéristique principale est qu'elles sont personnelles et incessibles (on ne peut ni les vendre ni les transmettre), à la différence des anciennes ADS antérieures à la réforme qui, elles, demeurent cessibles.

En résumé : VTC = inscription au registre valable 5 ans (renouvelable) ; taxi = nouvelles ADS incessibles délivrées pour 5 ans (renouvelables).$c370$,
  scoring_grid    = $c370$a. VTC : inscription au registre VTC valable 5 ans (renouvelable) : 1 pt. b. Taxi : nouvelles ADS (loi 2014) incessibles, durée 5 ans renouvelable : 1 pt. Total = 2.$c370$
WHERE source_ref = 'TAXI-M9-QC-03' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$a. Réponse du taxi (course au compteur) : pour une course facturée au compteur, le taxi ne peut pas garantir un prix ferme à l'avance, car le montant final résulte de l'application du taximètre (compteur horokilométrique), selon les tarifs fixés par arrêté préfectoral (prise en charge, tarif kilométrique, tarif horaire d'attente/marche lente, suppléments éventuels). Il peut seulement donner une estimation indicative, le prix définitif dépendant de la distance réellement parcourue et du temps. Il existe toutefois des cas de forfaits réglementés (par exemple certains trajets aéroport) où un prix fixe s'applique ; hors ces forfaits, le prix au compteur ne peut être annoncé comme ferme.

b. Réponse du VTC : le VTC pratique une tarification libre et le prix est déterminé et connu lors de la réservation préalable. Il peut donc annoncer et garantir au client un prix ferme et définitif avant le départ, ce montant étant communiqué et accepté au moment de la réservation.

En résumé : le taxi au compteur ne peut promettre un prix ferme (montant issu du taximètre selon tarifs préfectoraux, hors forfaits) ; le VTC le peut, puisque son prix est libre et fixé dès la réservation.$c370$,
  scoring_grid    = $c370$a. Taxi : au compteur, pas de prix ferme garanti, montant issu du taximètre selon tarifs préfectoraux (estimation seulement ; forfaits réglementés = exception) : 1 pt. b. VTC : tarification libre, prix ferme fixé et connu à la réservation : 1 pt. Total = 2.$c370$
WHERE source_ref = 'TAXI-M9-QC-04' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Pour que la course d'un patient muni d'une prescription médicale de transport soit prise en charge par l'assurance maladie et facturée à la CPAM, plusieurs conditions cumulatives doivent être réunies :

a. Condition tenant au taxi : le taxi doit être conventionné avec l'assurance maladie, c'est-à-dire avoir signé la convention type locale conclue avec la CPAM (caisse primaire d'assurance maladie) du département. Seul un taxi conventionné peut pratiquer le tiers payant et facturer directement la course à la caisse. Un taxi non conventionné ne peut pas adresser sa facture à la CPAM.

b. Condition tenant au transport : la course doit correspondre à un transport médicalement justifié et faire l'objet d'une prescription médicale de transport établie par un médecin (préalablement au transport, sauf urgence), la prescription indiquant le mode de transport prescrit. La prise en charge suppose que ce transport soit remboursable au titre de la réglementation de l'assurance maladie (motif et conditions ouvrant droit à remboursement).

En pratique : taxi conventionné + prescription médicale de transport valide (transport remboursable) permettent la facturation à la CPAM, le plus souvent en tiers payant, la part éventuelle restant à charge (ticket modérateur) étant réglée par le patient ou sa complémentaire, sauf exonération.$c370$,
  scoring_grid    = $c370$a. Le taxi doit être conventionné avec l'assurance maladie (convention CPAM) pour facturer/pratiquer le tiers payant : 1 pt. b. Existence d'une prescription médicale de transport valide pour un transport remboursable : 1 pt. Total = 2.$c370$
WHERE source_ref = 'TAXI-M9-QC-05' AND type='qr';

UPDATE public.question_bank SET
  expected_answer = $c370$Contexte : un conducteur VTC qui vient d'achever une course (dépose du client) sans réservation suivante ne bénéficie PAS du droit de maraude, réservé aux seuls taxis. Il ne peut donc ni stationner ni circuler sur la voie publique en quête de clients.

a. Ce qu'il doit faire de son véhicule (règle du « retour à la base »)
Dès l'achèvement de la prestation, le conducteur VTC est tenu de regagner soit le lieu d'établissement de l'exploitant (la « base »), soit un lieu, situé hors de la chaussée (hors voie publique), où le stationnement est autorisé (par exemple un parking privé ou un emplacement de stationnement autorisé). Il lui est interdit de rester en stationnement sur la voie publique ou de circuler en centre-ville dans l'attente ou la recherche d'un client : ce comportement s'apparenterait à de la maraude, strictement interdite au VTC. Il ne peut donc pas se comporter comme un taxi qui attend le client sur la voie publique ou à une station.

b. L'exception
Le conducteur est dispensé de ce retour à la base s'il justifie d'une réservation préalable (nouvelle course déjà réservée) ou d'un contrat avec le client final. Dans ce cas, il peut demeurer sur place ou se diriger vers son prochain client sans avoir à regagner sa base. Concrètement, s'il reçoit ou détient déjà une réservation pour une course à venir, il n'a pas l'obligation de rentrer ; à défaut de toute réservation, le retour à la base (ou vers un stationnement autorisé hors voie publique) s'impose.

Synthèse : pas de maraude pour le VTC → obligation de retour à la base (ou stationnement hors voie publique autorisé) après chaque course, SAUF s'il justifie d'une réservation préalable / d'un contrat avec le client final.$c370$,
  scoring_grid    = $c370$a. Retour à la base : le VTC doit regagner le lieu d'établissement de l'exploitant ou un lieu de stationnement autorisé hors voie publique ; interdiction de stationner/circuler sur la voie publique en quête de clients (pas de maraude) = 1 point (0,5 pour la seule idée « il ne peut pas marauder / attendre sur la voie publique » ; 0,5 pour l'obligation positive de retour à la base ou stationnement hors chaussée). b. Exception : sauf s'il justifie d'une réservation préalable (ou d'un contrat avec le client final) = 1 point. Total = 2 points.$c370$
WHERE source_ref = 'TAXI-M9-QC-06' AND type='qr';

-- ─── 2. Activation gardée : n'active QUE les QR pourvues d'un corrigé ───
UPDATE public.question_bank SET active = true
WHERE type='qr' AND active = false
  AND expected_answer IS NOT NULL AND scoring_grid IS NOT NULL;

COMMIT;

-- CONTRÔLE (doit renvoyer 0) : aucune QR active sans corrigé.
-- SELECT count(*) FROM public.question_bank
--  WHERE type='qr' AND active AND (expected_answer IS NULL OR scoring_grid IS NULL);