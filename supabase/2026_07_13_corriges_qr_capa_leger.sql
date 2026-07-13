-- =====================================================================
-- CORRIGÉS QR — CAPACITÉ LÉGÈRE (≤ 3,5 t) — 13/07/2026
--
-- Ajoute réponse-modèle (expected_answer) + barème (scoring_grid) aux 55
-- QR qui étaient actives SANS corrigé (donc inexploitables). Généré par
-- orchestration formateur + passe de vérification factuelle, puis
-- assemblé et QA-vérifié (couverture 55/55).
--
-- active = false : les questions repassent EN ATTENTE DE VALIDATION. Après
-- relecture, réactive-les via la bascule en masse de la banque de questions.
-- Les lignes marquées « ⚠️ À CONFIRMER » portent une donnée réglementaire à
-- vérifier avant activation.
--
-- Idempotent (UPDATE par source_ref + formation + type). À appliquer par l'admin.
-- =====================================================================

BEGIN;

UPDATE public.question_bank SET
  expected_answer = $corr$Étude de coût de revient VUL frigorifique (12 mois, 240 j/an, 90 000 km/an).

1a. Coûts détaillés :
Carburant : 90 000 km x 8,5 L/100 km = 7 650 L ; 7 650 x 1,68 = 12 852 euros/an.
Pneumatiques : 4 pneus x 130 = 520 euros pour 60 000 km, soit 0,00867 euro/km ; sur 90 000 km = 520 x (90 000/60 000) = 780 euros/an.
Masse salariale conducteur : salaire brut = net / (1 - 0,23) = 1 950 / 0,77 = 2 532,47 euros/mois. Charges patronales = 2 532,47 x 0,35 = 886,36 euros/mois. Coût mensuel (brut + patronales) = 3 418,83 euros ; x 12 = 41 025,97 euros. Frais de déplacement = 240 j x 10 = 2 400 euros. Masse salariale totale = 43 425,97 euros, arrondie à 43 426 euros/an.
Amortissement : base amortissable = 45 000 - (8% x 45 000) = 45 000 - 3 600 = 41 400 euros ; sur 5 ans = 41 400 / 5 = 8 280 euros/an.

1b. Autres dépenses annuelles :
Entretien et réparations : 0,022 x 90 000 = 1 980 euros/an.
Péages et stationnement : 0,018 x 90 000 = 1 620 euros/an.
Assurance véhicule et froid : 3 200 euros/an.
Assurance marchandises : 180 x 12 = 2 160 euros/an.
Charges de structure : 100 x 12 = 1 200 euros/an.
Contrôle technique frigorifique : 250 euros/an.
Divers (lavage, fournitures) : 550 euros/an.

2. Coût de revient :
2a. Tableau charges fixes / variables.
Charges VARIABLES (fonction du kilométrage) : carburant 12 852 ; pneumatiques 780 ; entretien et réparations 1 980 ; péages et stationnement 1 620. Total variables = 17 232 euros/an.
Charges FIXES (indépendantes du kilométrage) : masse salariale conducteur 43 426 ; amortissement 8 280 ; assurance véhicule et froid 3 200 ; assurance marchandises 2 160 ; charges de structure 1 200 ; contrôle technique 250 ; divers 550. Total fixes = 59 066 euros/an.

2b. Coût de revient total annuel = 17 232 + 59 066 = 76 298 euros/an.

2c. Formulations :
i. Monôme : CR/km = 76 298 / 90 000 = 0,848 euro/km (environ 0,85 euro/km).
ii. Binôme : terme variable = 17 232 / 90 000 = 0,1915 euro/km ; terme fixe journalier = 59 066 / 240 = 246,11 euros/jour. CR = 0,1915 euro/km x km + 246,11 euros/jour x jours.
iii. Trinôme (roulage / conducteur / véhicule) : terme kilométrique (charges variables) = 17 232 / 90 000 = 0,1915 euro/km ; terme conducteur = 43 426 / 240 = 180,94 euros/jour ; terme véhicule et structure (amortissement + assurances + structure + CT + divers = 15 640 euros) = 15 640 / 240 = 65,17 euros/jour. CR = 0,1915 euro/km x km + 180,94 euros/jour (conducteur) + 65,17 euros/jour (véhicule). Vérification : 17 232 + 43 426 + 15 640 = 76 298 euros.$corr$,
  scoring_grid    = $corr$1a. Carburant (2 pts : 7 650 L x 1,68 = 12 852 euros). 1a. Pneumatiques (2 pts : 780 euros, ratio 60 000 km). 1a. Masse salariale (3 pts : brut, charges patronales, frais de déplacement = 43 426 euros). 1a. Amortissement (2 pts : base 41 400 / 5 = 8 280 euros). 1b. Autres dépenses, 7 postes annualisés (3 pts). 2a. Tableau fixes/variables correct (3 pts : variables 17 232, fixes 59 066). 2b. CR total 76 298 euros (2 pts). 2c-i. Monôme 0,85 euro/km (1 pt). 2c-ii. Binôme (1 pt). 2c-iii. Trinôme (1 pt). Total = 20 points.$corr$,
  active = false
WHERE source_ref = 'manual' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleC:qr:1] : Capacité financière 2 700 euros vérifiée (1 800 + 900). [À CONFIRMER : délai exact d'instruction et de délivrance de la LTI par la DREAL (variable selon région et complétude du dossier). Vérifier également l'intitulé courant de la licence pour le régime léger : licence de transport intérieur (LTI).]
UPDATE public.question_bank SET
  expected_answer = $corr$a. Les 4 conditions cumulatives d'accès à la profession de transporteur public routier de marchandises (véhicules de 2,5 à 3,5 t de PTAC, régime léger) : 1) établissement stable et effectif en France ; 2) honorabilité professionnelle (du dirigeant et du gestionnaire de transport, casier judiciaire) ; 3) capacité professionnelle (attestation de capacité transport léger de marchandises jusqu'à 3,5 t) ; 4) capacité financière suffisante.

b. Capacité financière pour 2 VUL jusqu'à 3,5 t : 1 800 euros pour le 1er véhicule + 900 euros pour le 2e = 2 700 euros.

c. Démarches auprès de la DREAL (région du siège), dans l'ordre : 1) l'entreprise étant déjà immatriculée au RCS, constituer le dossier de demande d'inscription au registre électronique national des entreprises de transport par route ; 2) déposer auprès de la DREAL la demande d'autorisation d'exercer avec les justificatifs des 4 conditions (attestation de capacité, honorabilité, attestation de capacité financière, justificatif d'établissement) ; 3) la DREAL instruit, délivre l'autorisation d'exercer et inscrit l'entreprise au registre ; 4) demander la licence de transport intérieur (LTI), applicable aux véhicules jusqu'à 3,5 t ; 5) obtenir la licence et ses copies certifiées conformes (une par véhicule affecté).

d. Il faut prévoir un délai d'instruction par la DREAL de l'ordre de quelques semaines à quelques mois après dépôt d'un dossier complet.$corr$,
  scoring_grid    = $corr$a. Les 4 conditions cumulatives (1,5 pt : 0,375 par condition). b. Calcul capacité financière 2 700 euros (1 pt). c. Démarches DREAL et ordre logique, LTI et copies conformes (1,5 pt). d. Ordre de grandeur du délai d'instruction (1 pt). Total = 5 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleC:qr:1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleC:qr:2] : [À CONFIRMER : plafonds d'indemnisation en vigueur du contrat type général pour un envoi de moins de 3 tonnes (usuellement 23 euros/kg et plafond par colis souvent cité à 750 euros/colis). Vérifier les montants exacts à jour et le rattachement palette/colis avant diffusion.] Délai de 3 jours et forclusion (art. L.133-3) certains.
UPDATE public.question_bank SET
  expected_answer = $corr$a. Sous contrat type général (aucune convention écrite contraire), l'indemnisation des pertes et avaries est plafonnée. Pour un envoi de moins de 3 tonnes, la limite usuelle est de 23 euros par kilogramme de poids brut endommagé, sans pouvoir dépasser un plafond par colis. Sur la palette de 80 kg : 80 x 23 = 1 840 euros, montant ramené au plafond par colis applicable si la palette est traitée comme un colis. Dans tous les cas, la perte réelle de 6 000 euros n'est pas indemnisée intégralement : le destinataire ne perçoit qu'une fraction, du fait de la limitation légale d'indemnité.

b. Pour préserver son recours, s'agissant d'une avarie révélée à l'ouverture des cartons (avarie non apparente), le destinataire devait adresser au transporteur une protestation motivée par écrit (LRAR) dans les 3 jours, hors dimanches et jours fériés, suivant la réception (art. L.133-3 C. com.). Un simple appel téléphonique ne constitue pas une réserve régulière. Si l'avarie avait été apparente à la livraison, il aurait fallu inscrire des réserves précises et motivées sur la lettre de voiture au moment de la livraison.

c. La couverture optimale du transporteur : souscrire une assurance des marchandises transportées (couvrant la RC contractuelle du transporteur) et, pour une valeur élevée comme 25 000 euros, proposer au client une déclaration de valeur ou une assurance ad valorem afin de couvrir la valeur réelle au-delà des plafonds légaux.

d. S'il vous contacte 5 jours après la livraison, sans réserve écrite régulière adressée dans le délai de 3 jours (hors dimanches et fériés), l'action est en principe forclose : le recours contre le transporteur est éteint (art. L.133-3 C. com.), sauf faute lourde ou dol. Le seul appel téléphonique du 2e jour, non confirmé par écrit dans le délai, ne suffit pas.$corr$,
  scoring_grid    = $corr$a. Principe de limitation d'indemnité + calcul au poids et plafond par colis, perte réelle non couverte (1,5 pt). b. Avarie non apparente : protestation motivée LRAR sous 3 jours hors dimanches et fériés, art. L.133-3 (1,5 pt). c. Assurance marchandises / RC contractuelle + ad valorem (1 pt). d. Forclusion passé le délai, art. L.133-3 (1 pt). Total = 5 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleC:qr:2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Capacité financière pour 3 VUL jusqu'à 3,5 t : 1 800 euros (1er véhicule) + 900 euros x 2 (2e et 3e véhicules) = 1 800 + 1 800 = 3 600 euros. Ses 18 000 euros d'épargne dépassent donc l'exigence, mais l'épargne personnelle n'est pas en soi le justificatif attendu (voir b).

b. Trois modes de justification possibles : 1) capitaux propres figurant au bilan de l'entreprise (capital social libéré, fonds propres certifiés par l'expert-comptable) ; 2) garanties bancaires ou d'un établissement financier (caution), dans la limite admise ; 3) attestation de capacité financière délivrée par un organisme de caution ou une compagnie d'assurance. Pour une société nouvelle sans bilan, on privilégie l'apport en capital et/ou la garantie bancaire.

c. Risques pour le patrimoine : en SARL, la responsabilité est en principe limitée aux apports, mais la banque exige souvent une caution personnelle du dirigeant, qui engage son patrimoine propre. Sous le régime de la communauté légale, un engagement de caution portant sur les biens communs requiert le consentement exprès du conjoint (art. 1415 C. civ.) et peut exposer le patrimoine commun, donc les biens du couple. S'ajoute la responsabilité personnelle du dirigeant en cas de faute de gestion.

d. Trois actions concrètes avant d'immatriculer : 1) sécuriser le régime matrimonial (consulter un notaire, envisager un aménagement ou la séparation de biens, ou n'accepter une caution sur biens communs qu'avec consentement éclairé du conjoint au sens de l'art. 1415) ; 2) doter la société d'un capital suffisant et privilégier une garantie bancaire dédiée à la capacité financière plutôt qu'une caution personnelle illimitée ; 3) protéger la résidence principale et le patrimoine immobilier (la résidence principale est insaisissable de droit ; déclaration d'insaisissabilité chez le notaire pour les autres biens fonciers) et souscrire les assurances professionnelles.$corr$,
  scoring_grid    = $corr$a. Calcul 3 600 euros (1 pt). b. Trois modes de justification (1,5 pt : 0,5 chacun). c. Risques patrimoine : caution personnelle, art. 1415 communauté / conjoint, faute de gestion (1,5 pt). d. Trois actions concrètes avant immatriculation (1 pt). Total = 5 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleC:qr:3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Trois points juridiques à vérifier avant de signer : 1) l'existence d'un contrat de sous-traitance écrit conforme au contrat type sous-traitance, et le caractère rémunérateur du prix (interdiction de la sous-traitance à un prix abusivement bas ne couvrant pas les charges : carburant, péages, coût du conducteur) ; 2) la présence d'une clause de révision du prix du carburant (indexation gazole, obligatoire) ; 3) le délai de paiement et les garanties (assurances, responsabilités, action directe en paiement).

b. Le délai de 60 jours n'est pas légal en transport. Les prestations de transport bénéficient d'un délai de paiement dérogatoire plafonné à 30 jours à compter de la date d'émission de la facture (art. L.441-11 C. com., ex-L.441-6, dérogation propre au transport). Un délai de 60 jours est donc illicite.

c. Deux clauses essentielles : 1) le prix et ses modalités de révision, notamment la clause d'indexation du gazole (révision du prix de transport, art. L.3222-1 C. transports) ; 2) la définition précise de la prestation, des responsabilités et des assurances, avec rappel de la garantie de paiement / action directe.

d. Si le commissionnaire fait faillite, le transporteur sous-traitant dispose de l'action directe en paiement contre l'expéditeur et le destinataire (art. L.132-8 C. com.) : il peut réclamer le paiement de ses prestations au donneur d'ordre initial resté garant. Il doit par ailleurs déclarer sa créance auprès du mandataire judiciaire.$corr$,
  scoring_grid    = $corr$a. Trois points juridiques (1,5 pt : prix rémunérateur, clause gazole, délai/garanties). b. Délai illégal, plafond 30 jours en transport avec citation d'article (1,5 pt). c. Deux clauses essentielles (1 pt). d. Action directe art. L.132-8 + déclaration de créance (1 pt). Total = 5 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleC:qr:4' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Assurance OBLIGATOIRE : la seule assurance légalement obligatoire est la responsabilité civile circulation (assurance automobile du véhicule), qui couvre les dommages causés aux tiers par le véhicule en circulation.

b. Assurances RECOMMANDÉES compte tenu de l'activité (matériel de valeur jusqu'à 30 000 euros par envoi) : l'assurance des marchandises transportées (RC contractuelle du transporteur) pour les pertes, avaries et retards ; l'assurance ad valorem (à la valeur déclarée) pour couvrir la valeur réelle au-delà des plafonds légaux ; accessoirement une garantie dommages du véhicule et une protection juridique.

c. Différence entre RC circulation et RC contractuelle : la RC circulation est obligatoire et couvre les dommages causés aux tiers par le véhicule lors de sa circulation (accidents) ; elle ne couvre pas la marchandise transportée. La RC contractuelle (facultative) couvre la responsabilité du transporteur envers son client au titre de l'exécution du contrat de transport (pertes, avaries, retard de la marchandise).

d. L'ad valorem est une assurance fondée sur une déclaration de valeur : le client déclare la valeur réelle de l'envoi, une prime proportionnelle est payée, et l'indemnisation est portée à cette valeur réelle, au-delà des plafonds d'indemnisation du contrat type (indemnité au kilogramme et par colis). Elle est indispensable ici car un envoi de 30 000 euros dépasse largement les plafonds légaux : sans ad valorem, en cas de sinistre, l'indemnité serait limitée à quelques centaines d'euros seulement.$corr$,
  scoring_grid    = $corr$a. RC circulation seule obligatoire (1 pt). b. Assurances recommandées : marchandises transportées + ad valorem (1,5 pt). c. Distinction RC circulation / RC contractuelle (1,5 pt). d. Mécanisme et nécessité de l'ad valorem (1 pt). Total = 5 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleC:qr:5' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. La signature de la lettre de voiture sans observations n'est pas un obstacle définitif au recours. L'absence de réserves à la livraison fait présumer une réception conforme, mais la loi laisse au destinataire un délai pour protester par écrit. Le recours reste donc ouvert à condition d'adresser une protestation régulière dans le délai.

b. La protestation motivée par LRAR est valable pour les pertes et avaries (en particulier non apparentes, mais aussi apparentes non réservées à la livraison). Le délai est de 3 jours, hors dimanches et jours fériés, suivant la réception de la marchandise (art. L.133-3 C. com.).

c. Dans ce cas, la LRAR est valide. La livraison a lieu au jour J (signature sans réserve), l'appel a lieu J+1 (sans valeur juridique à lui seul), et la LRAR détaillée est adressée le surlendemain J+2, donc dans le délai de 3 jours hors dimanches et fériés. Étant motivée et adressée dans les temps, elle préserve le recours du destinataire.

d. Documents à conserver pour se défendre : l'exemplaire original de la lettre de voiture signée sans observations (preuve de l'absence de réserves à la livraison), les bons de livraison et émargements, les éventuelles photos et échanges écrits, ainsi que les preuves de dates (accusé de réception de la LRAR, cachets) permettant d'apprécier le respect ou le dépassement du délai de 3 jours.$corr$,
  scoring_grid    = $corr$a. Signature sans réserve non bloquante, délai de protestation ouvert (1,5 pt). b. Type d'avaries et délai de 3 jours hors dimanches et fériés, art. L.133-3 (1,5 pt). c. Application au cas : LRAR à J+2 dans le délai, donc valide (1 pt). d. Documents de preuve à conserver (1 pt). Total = 5 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleC:qr:6' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Contrat applicable : location de véhicule industriel avec conducteur, et non contrat de transport. Justification : c'est le client (donneur d'ordre) qui organise et dirige la prestation (il fournit chaque matin la liste des adresses et l'ordre de tournée) et qui a donc la maîtrise de l'organisation. Le prestataire se borne à mettre à disposition un véhicule et un conducteur sans maîtriser l'acheminement : la qualification retenue est bien la location avec conducteur. Dans un contrat de transport, à l'inverse, c'est le transporteur qui organise l'acheminement et répond de sa bonne fin.

b. Facturation : à la mise à disposition, au temps (forfait horaire ou de vacation), et non au poids ou à l'envoi. Ici, on facture la vacation du samedi de 8h à 13h (5 heures), éventuellement complétée d'un terme kilométrique, selon le contrat type location.

c. Responsabilité des avaries : en location avec conducteur, le locataire (le client) organise le transport et assume en principe la responsabilité des marchandises. Le loueur n'engage pas sa responsabilité de transporteur sur la bonne fin de l'acheminement ; il répond de la fourniture d'un véhicule en bon état et d'un conducteur apte, et n'est responsable qu'en cas de faute qui lui est propre (véhicule défectueux, faute du conducteur), selon le contrat type location.

d. Deux précautions juridiques dans le contrat écrit : 1) qualifier clairement le contrat de location de véhicule avec conducteur (et non de transport), conformément au contrat type location, en précisant la répartition des responsabilités ; 2) définir la mise à disposition (durée, plage horaire, prix au temps), les obligations respectives (le loueur fournit véhicule et conducteur en règle ; le locataire donne les instructions, organise la tournée et assume la responsabilité des marchandises) et la couverture d'assurance des marchandises.$corr$,
  scoring_grid    = $corr$a. Qualification location avec conducteur + justification par la maîtrise de l'organisation (1,5 pt). b. Facturation au temps / à la mise à disposition (1 pt). c. Responsabilité des avaries à la charge du locataire (1,5 pt). d. Deux précautions contractuelles (1 pt). Total = 5 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleC:qr:7' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Definition : le cout de revient kilometrique (CRKM) est le cout total supporte par l'entreprise pour parcourir un kilometre. On l'obtient en divisant l'ensemble des charges annuelles (charges fixes + charges variables) par le nombre de kilometres parcourus dans l'annee : CRKM = (charges fixes + charges variables) / km annuels. Les charges fixes (amortissement, assurances, salaire du conducteur, structure) sont independantes du kilometrage ; les charges variables (carburant, pneumatiques, entretien, peages) evoluent avec la distance.

Pourquoi le connaitre avant de fixer ses tarifs : a) c'est le seuil en dessous duquel toute vente se fait a perte, donc il fixe le prix plancher ; b) il permet de calculer un prix de vente incluant une marge beneficiaire reelle et non un prix fixe au hasard ; c) il sert de base a la negociation commerciale et a la comparaison avec la concurrence ; d) il revele l'effet du volume (degressivite des charges fixes quand le kilometrage augmente) et aide a decider d'accepter ou non un trafic ; e) il conditionne la perennite de l'entreprise : sans CRKM maitrise, l'entreprise peut etre rentable en apparence et se retrouver en difficulte de tresorerie.$corr$,
  scoring_grid    = $corr$Definition correcte du CRKM avec formule (charges totales / km) : 2 pts / Distinction charges fixes vs charges variables et leurs composantes : 1 pt / Deux raisons pertinentes ou plus (prix plancher, eviter la vente a perte, base de marge, negociation, decision d'accepter un trafic) : 2 pts. Total 5 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Donnees : charges fixes 30 000 EUR, charges variables 15 000 EUR, 50 000 km.

a. CRKM : cout total = 30 000 + 15 000 = 45 000 EUR. CRKM = 45 000 / 50 000 = 0,90 EUR/km.

b. Prix de vente pour une marge de 20 %. Deux lectures possibles selon la definition retenue :
Marge de 20 % calculee sur le cout de revient (taux de marge) : PV = 0,90 x 1,20 = 1,08 EUR/km.
Marge de 20 % calculee sur le prix de vente (taux de marque) : PV = 0,90 / (1 - 0,20) = 0,90 / 0,80 = 1,125 EUR/km.
En pratique de gestion, une marge annoncee en pourcentage du cout de revient donne 1,08 EUR/km ; si l'enonce vise une marge sur le prix de vente, retenir 1,125 EUR/km. Il faut preciser la base de calcul choisie.$corr$,
  scoring_grid    = $corr$a. CRKM = 0,90 EUR/km avec calcul (45 000 / 50 000) : 2 pts / b. Prix de vente avec marge de 20 % (1,08 EUR/km sur cout, ou 1,125 EUR/km sur PV) : 2 pts / Precision de la base de calcul de la marge (cout vs prix de vente) : 1 pt. Total 5 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Le bilan est une photographie du patrimoine de l'entreprise a une date donnee (generalement la cloture de l'exercice). Il presente a gauche l'actif (ce que l'entreprise possede : immobilisations, stocks, creances, tresorerie) et a droite le passif (ce qu'elle doit et ses ressources : capitaux propres, emprunts, dettes fournisseurs et fiscales/sociales). Actif et passif sont toujours egaux.

Le compte de resultat recapitule l'activite sur une periode (l'exercice, 12 mois). Il oppose les produits (chiffre d'affaires, autres produits) aux charges (achats, charges externes, salaires, amortissements, impots) et degage le resultat (benefice ou perte).

Difference cle : le bilan est un etat de stock a un instant t (le patrimoine), le compte de resultat est un etat de flux sur une duree (la performance).

Exemples de postes : bilan : une immobilisation (le vehicule) a l'actif, un emprunt bancaire au passif. Compte de resultat : le chiffre d'affaires transport en produit, le carburant ou les salaires en charge.$corr$,
  scoring_grid    = $corr$Definition du bilan (patrimoine a une date, actif/passif) : 1 pt / Definition du compte de resultat (produits/charges sur une periode, resultat) : 1 pt / Formulation de la difference stock/patrimoine vs flux/periode : 1 pt / Un exemple de poste correct pour chacun : 1 pt. Total 4 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Donnees : CA 180 000, achats 32 000, charges externes 28 000, salaires + charges 60 000, impots et taxes 1 500, dotations aux amortissements 11 000.

a. Valeur ajoutee (VA) = production (CA) - consommations en provenance de tiers (achats + charges externes) = 180 000 - 32 000 - 28 000 = 120 000 EUR.

b. Excedent brut d'exploitation (EBE) = VA - charges de personnel - impots et taxes = 120 000 - 60 000 - 1 500 = 58 500 EUR.

c. Resultat d'exploitation = EBE - dotations aux amortissements = 58 500 - 11 000 = 47 500 EUR.
(EBE = 58 500 EUR, resultat d'exploitation = 47 500 EUR.)$corr$,
  scoring_grid    = $corr$a. VA = 120 000 EUR avec calcul : 2 pts / b. EBE = 58 500 EUR avec calcul (VA - personnel - impots/taxes) : 2 pts / c. Resultat d'exploitation = 47 500 EUR avec calcul (EBE - dotations) : 2 pts. Total 6 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr4' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Le resultat net est une notion comptable (produits moins charges) qui n'est pas la tresorerie disponible. On peut etre beneficiaire et manquer de liquidites car le resultat integre des ecritures sans mouvement de tresorerie immediat et ignore certains decaissements. De la vient le paradoxe d'un resultat positif accompagne d'un besoin de delai aupres de l'URSSAF.

Trois causes possibles :
1. Un besoin en fonds de roulement eleve : les clients paient a 30/60 jours alors que les charges (salaires, cotisations, carburant) sont reglees immediatement, ce qui immobilise la tresorerie dans les creances.
2. Le remboursement du capital des emprunts et les investissements (achat de vehicule) qui sortent de la tresorerie mais ne figurent pas en charges du compte de resultat (seuls les interets et l'amortissement y figurent).
3. Les decalages fiscaux et sociaux ou la constitution de stocks : echeances TVA/cotisations concentrees, ou tresorerie bloquee dans des stocks, ainsi que d'eventuels prelevements de l'exploitant.
(Autres causes recevables : croissance rapide non financee, impayes clients.)$corr$,
  scoring_grid    = $corr$Explication du paradoxe resultat comptable different de tresorerie (charges calculees, decalages, decaissements hors compte de resultat) : 2 pts / Trois causes pertinentes citees : 3 pts (1 pt par cause valable). Total 5 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr5' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Donnees : capitaux propres 60 000, dettes LT 80 000, immobilisations nettes 110 000, stocks 5 000, creances 35 000, fournisseurs 18 000, dettes fiscales/sociales 12 000.

a. Fonds de roulement (FR) = capitaux permanents - actif immobilise = (60 000 + 80 000) - 110 000 = 140 000 - 110 000 = 30 000 EUR. Le FR est positif : les ressources stables financent la totalite des immobilisations et degagent un excedent.

b. Besoin en fonds de roulement (BFR) = (stocks + creances) - (fournisseurs + dettes fiscales/sociales) = (5 000 + 35 000) - (18 000 + 12 000) = 40 000 - 30 000 = 10 000 EUR.

c. Tresorerie nette (TN) = FR - BFR = 30 000 - 10 000 = 20 000 EUR. Tresorerie nette positive : l'entreprise dispose d'une tresorerie saine, le FR couvre le BFR et laisse un excedent de 20 000 EUR.$corr$,
  scoring_grid    = $corr$a. FR = 30 000 EUR avec calcul (capitaux permanents - immobilisations) : 2 pts / b. BFR = 10 000 EUR avec calcul : 2 pts / c. TN = 20 000 EUR (FR - BFR) et commentaire de solvabilite : 2 pts. Total 6 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr6' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Enjeu : au demarrage, avec seulement 8 000 EUR d'apport, la ressource rare est la tresorerie, indispensable pour financer le besoin en fonds de roulement (decalage entre le paiement des charges et l'encaissement des clients).

Option 1, achat du VUL 18 000 EUR HT puis emprunt de 10 000 EUR de BFR : l'entreprise devient proprietaire du vehicule (element de patrimoine, amortissable, recuperation de la TVA sur un VUL), pas de loyer. Mais elle immobilise son apport dans le vehicule et doit s'endetter pour financer le BFR ; la capacite d'endettement est consommee des le depart et les mensualites de l'emprunt pesent sur la tresorerie.

Option 2, credit-bail 60 mois a 360 EUR/mois en gardant 8 000 EUR de tresorerie : cout total des loyers = 360 x 60 = 21 600 EUR, soit un surcout d'environ 3 600 EUR par rapport au prix d'achat de 18 000 EUR (prix du financement et de l'option d'achat finale). En contrepartie, les loyers sont des charges deductibles, la tresorerie de 8 000 EUR reste disponible pour financer le BFR sans emprunt, et la souplesse est plus grande. Le vehicule n'est pas propriete tant que l'option d'achat n'est pas levee.

Conclusion : pour un demarrage avec un apport faible, le credit-bail est generalement preferable car il preserve la tresorerie et finance le BFR sans dette bancaire supplementaire, au prix d'un surcout de financement acceptable. L'achat se justifie si l'entreprise dispose d'une tresorerie confortable et souhaite constituer un patrimoine.$corr$,
  scoring_grid    = $corr$Identification de l'enjeu tresorerie/BFR au demarrage : 1 pt / Analyse de l'option achat (propriete, TVA, immobilisation de l'apport, endettement) : 1,5 pt / Analyse de l'option credit-bail (preservation tresorerie, surcout 21 600 EUR, charges deductibles, pas de propriete) : 1,5 pt / Conclusion argumentee et coherente : 1 pt. Total 5 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr7' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleD:qr8] : [A CONFIRMER: le CRKM 0,95 EUR/km annonce est incoherent avec CF 30 000 EUR + CV 0,30 EUR/km a 60 000 km (qui donnent 0,80 EUR/km). Verifier l'intention de l'enonce (tarif de vente vs cout).]
UPDATE public.question_bank SET
  expected_answer = $corr$Donnees : CRKM 0,95 EUR/km a 60 000 km/an ; proposition 80 000 km/an a 0,88 EUR/km ; charges fixes 30 000 EUR, charges variables 0,30 EUR/km.

Raisonnement par le cout complet au nouveau volume : avec 80 000 km, cout total = charges fixes + charges variables = 30 000 + (0,30 x 80 000) = 30 000 + 24 000 = 54 000 EUR. Nouveau CRKM = 54 000 / 80 000 = 0,675 EUR/km. Le prix propose 0,88 EUR/km est tres superieur au cout de revient de 0,675 EUR/km : la marge unitaire est de 0,88 - 0,675 = 0,205 EUR/km, soit un benefice de 0,205 x 80 000 = 16 400 EUR/an.

Raisonnement par la marge sur cout variable (contribution) : chaque kilometre supplementaire ne coute que sa charge variable 0,30 EUR/km ; a 0,88 EUR/km il rapporte une marge sur cout variable de 0,58 EUR/km qui absorbe les charges fixes et degage du benefice.

Decision : il faut accepter. Meme si le tarif au kilometre (0,88) est inferieur au tarif actuel (0,95), la hausse du volume fait chuter le CRKM par degressivite des charges fixes, et l'operation reste largement beneficiaire.

[A CONFIRMER: incoherence interne de l'enonce. Avec charges fixes 30 000 EUR et charges variables 0,30 EUR/km, le CRKM a 60 000 km ressort a 0,80 EUR/km (30 000 + 18 000 = 48 000 / 60 000) et non 0,95 EUR/km. Le corrige s'appuie sur les charges fixes et variables fournies ; a confirmer avec le formateur si le 0,95 correspond a un tarif de vente ou a une autre structure de couts.]$corr$,
  scoring_grid    = $corr$Calcul du nouveau CRKM au volume de 80 000 km (0,675 EUR/km) : 3 pts / Raisonnement de degressivite des charges fixes ou marge sur cout variable (0,58 EUR/km) : 2 pts / Decision motivee d'accepter : 1 pt. Total 6 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr8' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Donnees : charges fixes 28 000 EUR/an, charges variables 0,32 EUR/km, tarif 0,95 EUR/km a 50 000 km. Le gazole augmente de 25 %, les charges variables passent a 0,40 EUR/km.

a. Situation actuelle : cout total = 28 000 + (0,32 x 50 000) = 28 000 + 16 000 = 44 000 EUR. CRKM actuel = 0,88 EUR/km. Chiffre d'affaires = 0,95 x 50 000 = 47 500 EUR. Marge actuelle = 47 500 - 44 000 = 3 500 EUR (soit 0,07 EUR/km).

b. Impact de la hausse : nouvelles charges variables = 0,40 x 50 000 = 20 000 EUR, soit +4 000 EUR par rapport aux 16 000 EUR initiaux. Nouveau cout total = 28 000 + 20 000 = 48 000 EUR. Nouveau CRKM = 0,96 EUR/km. Au tarif inchange de 0,95 EUR/km, l'entreprise vendrait a perte (0,95 < 0,96).

c. Hausse tarifaire a demander pour conserver la meme marge en euros (3 500 EUR) : nouveau CA necessaire = cout + marge = 48 000 + 3 500 = 51 500 EUR. Nouveau tarif = 51 500 / 50 000 = 1,03 EUR/km. Hausse = 1,03 - 0,95 = 0,08 EUR/km, soit +8,4 %. On retrouve logiquement que la hausse a repercuter par kilometre (0,08 EUR/km) est egale a la hausse du cout variable unitaire (0,40 - 0,32), le volume etant inchange.

Conclusion : impact de +4 000 EUR/an sur les couts ; il faut porter le tarif de 0,95 a 1,03 EUR/km pour preserver la marge de 3 500 EUR.$corr$,
  scoring_grid    = $corr$a. Situation actuelle : cout 44 000 EUR, marge 3 500 EUR : 2 pts / b. Nouveau cout 48 000 EUR et impact +4 000 EUR (ou nouveau CRKM 0,96 EUR/km) : 2 pts / c. Nouveau tarif 1,03 EUR/km (hausse +0,08 EUR/km) pour conserver la marge : 2 pts / Conclusion coherente : 1 pt. Total 7 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr9' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleD:qr10] : [A CONFIRMER: le bilan simplifie 2025 de MG TRANS cite en annexe est absent de l'enonce stocke ; fournir les montants pour permettre le chiffrage. Corrige livre au niveau methode/definitions.]
UPDATE public.question_bank SET
  expected_answer = $corr$Methode et definitions (les valeurs chiffrees se calculent a partir du bilan simplifie 2025 de MG TRANS figurant en annexe).

1. Fonds de Roulement Net Global (FRNG) : excedent des ressources stables (capitaux propres + dettes financieres a plus d'un an) sur les emplois stables (actif immobilise net). Il mesure la part des ressources durables qui finance le cycle d'exploitation. Calcul par le haut du bilan : FRNG = ressources stables - actif immobilise net = (capitaux propres + dettes a long terme) - immobilisations nettes. Un FRNG positif est un signe de securite financiere.

2. Besoin en Fonds de Roulement (BFR) : besoin de financement ne du decalage entre les emplois et les ressources du cycle d'exploitation. BFR = (stocks + creances d'exploitation) - dettes d'exploitation (fournisseurs + dettes fiscales et sociales). Un BFR positif traduit un besoin a financer ; negatif, une ressource degagee par le cycle.

3. Tresorerie Nette (TN) : liquidites reellement disponibles. Verification par les deux methodes :
Methode 1 (par le bas du bilan) : TN = disponibilites (tresorerie active) - concours bancaires courants (tresorerie passive).
Methode 2 (par la relation fondamentale) : TN = FRNG - BFR.
Les deux methodes doivent donner le meme montant : c'est le controle de coherence. Interpretation : TN positive = equilibre financier sain (le FRNG couvre le BFR) ; TN negative = dependance aux financements bancaires court terme.

[A CONFIRMER: les montants du bilan simplifie MG TRANS annonces en annexe ne figurent pas dans l'enonce transmis. Appliquer les formules ci-dessus aux valeurs de l'annexe pour obtenir les resultats chiffres.]$corr$,
  scoring_grid    = $corr$1. Definition du FRNG + formule (ressources stables - immobilisations) et calcul sur les donnees de l'annexe : 4 pts / 2. Definition du BFR + formule et calcul : 3 pts / 3. Definition de la TN + calcul + double verification (bas de bilan et FRNG - BFR) : 3 pts. Total 10 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr10' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleD:qr11] : [A CONFIRMER: convention de calcul du salaire brut retenue (brut = net / (1 - 21 %) = 2 177,22 EUR/mois) et classement de l'assurance marchandises et des frais de deplacement en charges fixes ; ces choix ne modifient pas le cout de revient total (54 842,88 EUR) mais peuvent changer la repartition fixes/variables selon la correction attendue.]
UPDATE public.question_bank SET
  expected_answer = $corr$Tous montants HT. Base d'activite : 190 km/jour, 22 jours/mois, soit 264 jours/an.

1. Kilometrage : mensuel = 190 x 22 = 4 180 km/mois ; annuel = 4 180 x 12 = 50 160 km/an.

2. Carburant : consommation annuelle = 50 160 x 5,6/100 = 2 808,96 L. Cout = 2 808,96 x 1,52 = 4 269,62 EUR/an.

3. Autres charges d'exploitation : entretien = 0,016 x 50 160 = 802,56 EUR ; pneumatiques = (4 x 125) / 75 000 x 50 160 = 500 / 75 000 x 50 160 = 334,40 EUR ; peages = 0,028 x 50 160 = 1 404,48 EUR ; charges de structure = 85 x 12 = 1 020 EUR ; frais de deplacement du conducteur = 9,00 x 264 = 2 376 EUR.

4. Assurances : assurance vehicule = 215 x 12 = 2 580 EUR/an ; assurance marchandises = 7,50 x 264 = 1 980 EUR/an.

5. Cout annuel du conducteur (salaire net 1 720 EUR/mois ; charges salariales 21 %, patronales 31 %). Le net represente 79 % du brut, donc salaire brut mensuel = 1 720 / 0,79 = 2 177,22 EUR. Charges salariales = 2 177,22 - 1 720 = 457,22 EUR/mois (comprises dans le brut, non ajoutees au cout employeur). Charges patronales = 31 % x 2 177,22 = 674,94 EUR/mois. Salaire brut annuel = 2 177,22 x 12 = 26 126,58 EUR ; charges patronales annuelles = 674,94 x 12 = 8 099,24 EUR. Cout total employeur = 26 126,58 + 8 099,24 = 34 225,82 EUR/an (hors frais de deplacement).

6. Amortissement : base amortissable = 32 500 - (10 % x 32 500) = 32 500 - 3 250 = 29 250 EUR. Amortissement annuel lineaire = 29 250 / 5 = 5 850 EUR/an.

7a. Ventilation. Charges variables (liees au km) : carburant 4 269,62 ; entretien 802,56 ; pneumatiques 334,40 ; peages 1 404,48. Charges fixes, colonne Conducteur : salaire brut 26 126,58 ; charges patronales 8 099,24 ; frais de deplacement 2 376. Colonne Vehicule : assurance vehicule 2 580 ; amortissement 5 850. Colonne Structure : charges de structure 1 020 ; assurance marchandises 1 980.
7b. Total charges variables = 6 811,06 EUR. Total charges fixes = 36 601,82 (conducteur) + 8 430 (vehicule) + 3 000 (structure) = 48 031,82 EUR. Cout de revient annuel total = 48 031,82 + 6 811,06 = 54 842,88 EUR/an.

8. Presentation du cout de revient (50 160 km, 264 jours) :
a) Monome : 54 842,88 / 50 160 = 1,093 EUR/km.
b) Binome : terme journalier = 48 031,82 / 264 = 181,94 EUR/jour ; terme kilometrique = 6 811,06 / 50 160 = 0,136 EUR/km. Cout = 181,94 EUR/jour + 0,136 EUR/km.
c) Trinome : terme kilometrique 0,136 EUR/km ; terme journalier conducteur = 36 601,82 / 264 = 138,64 EUR/jour ; terme journalier vehicule + structure = 11 430 / 264 = 43,30 EUR/jour.

9a. Chiffre d'affaires annuel = 265 x 264 = 69 960 EUR/an.
9b. Objectif de marge 15 % sur le prix de vente. Marge realisee = 69 960 - 54 842,88 = 15 117,12 EUR, soit un taux de marge sur CA de 15 117,12 / 69 960 = 21,6 %. Le CA minimum pour une marge de 15 % serait 54 842,88 / 0,85 = 64 521 EUR ; le CA reel (69 960 EUR) le depasse. La tournee respecte donc l'objectif, avec une marge (21,6 %) nettement superieure a 15 %.$corr$,
  scoring_grid    = $corr$Q1 km mensuel 4 180 / annuel 50 160 : 2 pts / Q2 conso 2 808,96 L et cout carburant 4 269,62 EUR : 3 pts / Q3 entretien 802,56, pneus 334,40, peages 1 404,48, structure 1 020, frais depl. 2 376 : 5 pts (1 par poste) / Q4 assurance vehicule 2 580 et marchandises 1 980 : 2 pts / Q5 salaire brut, charges salariales, patronales, cout total conducteur 34 225,82 : 4 pts / Q6 amortissement 5 850 : 2 pts / Q7 ventilation fixes/variables + cout de revient 54 842,88 : 4 pts / Q8 monome 1,093, binome, trinome : 3 pts (1 chacun) / Q9 CA 69 960 et verification marge 21,6 % > 15 % : 2 pts. Total 27 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr11' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleD:qr12] : [A CONFIRMER: donnees insuffisantes. Le CRKM 0,92 EUR/km (cout complet) ne permet pas d'isoler la marge sur cout variable par km. Il manque le prix de vente au km et/ou le cout variable au km pour un chiffrage numerique du kilometrage minimum.]
UPDATE public.question_bank SET
  expected_answer = $corr$Principe : pour ne pas degrader le resultat global, le supplement d'activite doit degager une marge sur cout variable supplementaire au moins egale au supplement de charges fixes cree par l'embauche (35 000 EUR/an).

Raisonnement sur le seuil de rentabilite : le seuil (en km) = charges fixes / marge sur cout variable par km. Actuellement il est de 38 000 km. En ajoutant 35 000 EUR de charges fixes, le nouveau seuil global devient : nouveau seuil = (charges fixes actuelles + 35 000) / marge sur cout variable par km = 38 000 + (35 000 / marge sur cout variable par km). Le kilometrage total minimum a assurer par les deux vehicules est donc de 38 000 km majores de 35 000 EUR divises par la marge unitaire sur cout variable.

Autrement dit, chaque kilometre supplementaire rapporte sa marge sur cout variable (prix de vente au km moins cout variable au km) ; il faut parcourir assez de kilometres supplementaires pour que cette marge cumulee atteigne 35 000 EUR. En dessous de ce total, l'embauche degrade le resultat ; au-dela, elle l'ameliore.

[A CONFIRMER: l'enonce ne fournit ni le prix de vente au km ni le cout variable au km ; seul le CRKM (cout complet) de 0,92 EUR/km est donne, ce qui ne permet pas d'isoler la marge sur cout variable unitaire necessaire au chiffrage. Fournir le tarif client et le cout variable par km pour obtenir le kilometrage total minimum exact (formule : 38 000 + 35 000 / marge sur cout variable par km).]$corr$,
  scoring_grid    = $corr$Principe : la marge supplementaire doit couvrir les 35 000 EUR de charges fixes ajoutees : 2 pts / Formule du nouveau seuil (nouveau seuil = 38 000 + 35 000 / marge sur cout variable par km) : 3 pts / Conclusion sur le kilometrage total minimum et l'effet sur le resultat : 1 pt. Total 6 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr12' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Mini-bilan (equilibre, total actif = total passif = 51 500 EUR).
Actif : immobilisations 35 000 ; stocks 1 000 ; creances clients 12 000 ; tresorerie 3 500. Total 51 500.
Passif : capitaux propres (capital social 5 000 + reserves 8 000 + resultat 4 500 = 17 500) ; emprunts long terme 18 000 ; fournisseurs 4 000 ; dettes fiscales et sociales 12 000. Total 51 500.

Indicateurs d'equilibre :
Capitaux permanents = capitaux propres + emprunts LT = 17 500 + 18 000 = 35 500 EUR.
Fonds de roulement (FR) = capitaux permanents - immobilisations = 35 500 - 35 000 = 500 EUR (positif mais tres faible).
Besoin en fonds de roulement (BFR) = (stocks + creances) - (fournisseurs + dettes fiscales/sociales) = (1 000 + 12 000) - (4 000 + 12 000) = 13 000 - 16 000 = -3 000 EUR (negatif : le cycle d'exploitation degage une ressource).
Tresorerie nette (TN) = FR - BFR = 500 - (-3 000) = 3 500 EUR, coherente avec la tresorerie du bilan (controle valide).

Conclusion sur la sante financiere : l'entreprise est equilibree et rentable (resultat positif de 4 500 EUR). Sa tresorerie est saine (3 500 EUR), soutenue par un BFR negatif (les dettes d'exploitation financent le cycle). Points de vigilance : le fonds de roulement est tres faible (500 EUR), donc une faible marge de securite ; l'autonomie financiere est moyenne (capitaux propres 17 500 / total 51 500 = 34 %) et l'endettement long terme (18 000 EUR) est legerement superieur aux capitaux propres. Sante financiere globalement correcte, mais fonds de roulement et niveau d'endettement a surveiller.$corr$,
  scoring_grid    = $corr$Mini-bilan structure et equilibre (actif/passif = 51 500 EUR), capitaux propres 17 500 : 2 pts / FR = 500 EUR : 1 pt / BFR = -3 000 EUR : 1 pt / TN = 3 500 EUR avec coherence : 1 pt / Ratios (autonomie/endettement) : 1 pt / Conclusion argumentee sur la sante financiere : 1 pt. Total 7 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr13' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Entreprise de prestation de services : la production de l'exercice = CA = 220 000 €.
a. Valeur ajoutée (VA) = Production (220 000) moins achats consommés (38 000) moins charges externes (32 000) = 150 000 €. Taux de VA = 150 000 / 220 000 = 68 %.
b. Excédent brut d'exploitation (EBE) = VA (150 000) moins impôts et taxes (2 100) moins salaires et charges sociales (78 000) = 69 900 €. Taux d'EBE / CA = 31,8 %.
c. Résultat d'exploitation = EBE (69 900) moins dotations aux amortissements (14 000) = 55 900 €.
d. Résultat courant / net (en l'absence de charges et produits financiers, exceptionnels et d'IS communiqués) ressort au niveau du résultat d'exploitation, soit environ 55 900 € (avant impôt sur les bénéfices).
Diagnostic (3 lignes) : la VA représente 68 % du CA, ce qui traduit une faible dépendance aux consommations externes, structure saine pour du transport. L'EBE à 31,8 % du CA est très confortable et couvre largement l'amortissement du parc. La rentabilité d'exploitation (25 % du CA) est solide : l'entreprise dégage une forte capacité d'autofinancement et peut investir ou se désendetter.$corr$,
  scoring_grid    = $corr$a. VA 2 pts (calcul 1 pt + taux/commentaire 1 pt) / b. EBE 2 pts (calcul 1 pt + taux/commentaire 1 pt) / c. Résultat d'exploitation 1 pt / d. Résultat courant-net 0,5 pt / Diagnostic 3 lignes 1,5 pt (0,5 pt par idée pertinente) = 7 pts$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr14' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Capacité d'autofinancement (CAF) simplifiée = résultat net (25 000) + dotations aux amortissements (18 000) = 43 000 €.
b. Variation du besoin en fonds de roulement (BFR) : l'augmentation des créances clients (+12 000) est un emploi (consomme de la trésorerie), l'augmentation des dettes fournisseurs (+5 000) est une ressource. Variation du BFR = 12 000 moins 5 000 = +7 000 € (le BFR augmente de 7 000, ce qui ampute la trésorerie).
c. Flux de trésorerie d'exploitation = CAF (43 000) moins variation du BFR (7 000) = 36 000 €.
d. Flux d'investissement = achat du véhicule = -28 000 €.
e. Flux de financement = remboursement d'emprunt = -8 000 €.
f. Variation de trésorerie de l'exercice = 36 000 moins 28 000 moins 8 000 = 0 €.
Explication : malgré un bon résultat et une CAF de 43 000 €, la trésorerie est restée stable car l'exploitation (36 000) a été intégralement absorbée par l'investissement véhicule (28 000) et le remboursement de l'emprunt (8 000). L'entreprise finance sa croissance par ses propres flux, sans dégrader ni améliorer sa trésorerie : situation équilibrée mais tendue, sans marge de sécurité dégagée cette année.$corr$,
  scoring_grid    = $corr$a. CAF 1,5 pt / b. Variation BFR 1,5 pt (sens des flux 0,5 pt inclus) / c. Flux d'exploitation 1 pt / d. Flux d'investissement 0,5 pt / e. Flux de financement 0,5 pt / f. Variation de trésorerie = 0 : 1 pt / Explication 1 pt = 7 pts$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr15' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Calcul des ratios clés pour chaque entreprise.
a. Entreprise X : taux d'EBE / CA = 45 000 / 300 000 = 15 % ; marge nette (RN/CA) = 12 000 / 300 000 = 4 % ; rentabilité financière (RN / capitaux propres) = 12 000 / 60 000 = 20 % ; autonomie financière (capitaux propres / total bilan) = 60 000 / 200 000 = 30 %.
b. Entreprise Y : taux d'EBE / CA = 70 000 / 280 000 = 25 % ; marge nette = 28 000 / 280 000 = 10 % ; rentabilité financière = 28 000 / 25 000 = 112 % ; autonomie financière = 25 000 / 180 000 = 13,9 %.
c. Comparaison : Y est nettement plus performante sur le cœur de métier (EBE 25 % contre 15 %, marge nette 10 % contre 4 %) et affiche une rentabilité des capitaux propres exceptionnelle (112 %), en partie liée à son faible niveau de fonds propres (effet de levier). X est structurellement plus solide (autonomie financière 30 % contre 14 %) mais dégage une rentabilité d'exploitation faible.
Conclusion : la plus saine sur le plan économique est l'entreprise Y, car elle dégage beaucoup plus de valeur sur son activité (EBE et marge nette double de X). Réserve importante : Y est sous-capitalisée (fonds propres de seulement 14 % du bilan), donc financièrement fragile en cas de retournement ; il faudrait renforcer ses capitaux propres. X est plus prudente au bilan mais devra impérativement redresser sa rentabilité d'exploitation.$corr$,
  scoring_grid    = $corr$a. Ratios de X (EBE/CA, marge nette, rentabilité financière, autonomie) : 2 pts / b. mêmes ratios de Y : 2 pts / c. Identification motivée de la plus saine + réserve sur la structure de Y : 2 pts = 6 pts$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr16' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. DSO (délai moyen de règlement clients) = créances clients / CA TTC x 365 = 75 000 / 360 000 x 365 = 76 jours (arrondi). Les clients règlent en moyenne à 76 jours.
b. DPO (délai moyen de règlement fournisseurs) = dettes fournisseurs / achats TTC x 365 = 22 000 / 95 000 x 365 = 85 jours (arrondi). L'entreprise paie ses fournisseurs à 85 jours.
c. Besoin de financement induit par l'écart : l'entreprise avance de la trésorerie à ses clients (créances 75 000) tandis que ses fournisseurs ne la financent qu'à hauteur de 22 000. Besoin de financement = créances clients moins dettes fournisseurs = 75 000 moins 22 000 = 53 000 €.
Commentaire : bien que le DPO (85 j) soit supérieur au DSO (76 j), les montants en jeu sont très déséquilibrés (les créances pèsent plus de 3 fois les dettes fournisseurs). L'entreprise doit donc financer 53 000 € de décalage de trésorerie, à couvrir par le fonds de roulement ou des outils court terme (affacturage, escompte). Le levier prioritaire est de réduire le DSO (relance, acomptes) car un DSO de 76 jours dépasse le plafond légal de paiement (60 jours à compter de la date de facture, ou 45 jours fin de mois — art. L.441-10 C. com.).$corr$,
  scoring_grid    = $corr$a. DSO calcul + interprétation : 2,5 pts / b. DPO calcul + interprétation : 2,5 pts / c. Besoin de financement = 53 000 € + commentaire : 2 pts = 7 pts$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr17' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Tableau de flux de trésorerie (méthode simplifiée à partir de l'EBE).
a. CAF (approche flux) = EBE (35 000) moins charges financières (4 200) moins IS (4 000) = 26 800 €. Les dotations aux amortissements (12 000) sont sans incidence sur la trésorerie et ne sont pas réintégrées ici puisqu'on part de l'EBE.
b. Flux net de trésorerie d'exploitation (FTE) = CAF (26 800) moins augmentation du BFR (18 000) = 8 800 €.
c. Flux net d'investissement = -22 000 € (acquisitions).
d. Flux net de financement = nouvel emprunt (+30 000) moins remboursements (-10 000) moins dividendes (-5 000) = +15 000 €.
e. Variation de trésorerie de l'exercice = 8 800 moins 22 000 plus 15 000 = +1 800 €.
Conclusion : la trésorerie progresse légèrement (+1 800 €), mais l'analyse est préoccupante. Le flux d'exploitation (8 800 €) ne couvre pas les investissements (22 000 €) : le programme d'investissement n'est financé que grâce à un nouvel emprunt de 30 000 €. L'entreprise est donc dépendante de l'endettement pour investir, et l'augmentation du BFR (18 000) absorbe les deux tiers de la CAF. Il faut surveiller le BFR et veiller à ce que la rentabilité d'exploitation progresse pour retrouver une autonomie de financement.$corr$,
  scoring_grid    = $corr$a. CAF 1,5 pt / b. Flux d'exploitation 1,5 pt / c. Flux d'investissement 1 pt / d. Flux de financement 1,5 pt / e. Variation de trésorerie = +1 800 € : 1 pt / Conclusion (dépendance à l'emprunt) 0,5 pt = 7 pts$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr18' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Autonomie financière = capitaux propres / total bilan = 45 000 / 138 000 = 32,6 %. En dessous du repère prudentiel de 33 %, l'entreprise est faiblement capitalisée.
b. Taux d'endettement (gearing) = dettes financières / capitaux propres = 65 000 / 45 000 = 144 %. Les dettes financières excèdent largement les fonds propres (seuil d'alerte au-delà de 100 %) : l'entreprise est surendettée.
c. Ratio d'endettement global = total des dettes / total bilan = (65 000 + 28 000) / 138 000 = 93 000 / 138 000 = 67,4 %. Les deux tiers du bilan sont financés par des dettes.
Diagnostic : structure financière déséquilibrée, dépendance excessive aux créanciers et gearing > 100 %.
Stratégie d'amélioration sur 24 mois :
1) Renforcer les capitaux propres : mise en réserve de la totalité des résultats (pas ou peu de dividendes), apport en compte courant d'associé bloqué ou augmentation de capital, pour viser une autonomie financière > 40 %.
2) Réduire les dettes financières : affecter la CAF au remboursement anticipé du principal, objectif ramener le gearing sous 100 % en 24 mois.
3) Améliorer la rentabilité et la CAF (optimisation des coûts, taux de remplissage, prix) pour autofinancer les prochains véhicules.
4) Privilégier le crédit-bail plutôt que l'emprunt pour les nouveaux matériels afin de ne pas alourdir l'endettement bancaire, et maîtriser le BFR (réduire le DSO).$corr$,
  scoring_grid    = $corr$a. Autonomie financière 1,5 pt (calcul + interprétation) / b. Gearing 1,5 pt / c. Ratio d'endettement global 1 pt / Diagnostic 0,5 pt / Stratégie 24 mois : 4 leviers 2,5 pts (0,5 à 0,75 pt par action pertinente) = 7 pts$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr19' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Hypothèses (à énoncer) : activité démarrant en janvier, aucune créance ni dette antérieure. CA encaissé à 60 jours (CA de janvier encaissé en mars). Achats payés à 30 jours (achats de janvier payés en février).
Encaissements : janvier 0 ; février 0 ; mars 22 000 € (CA de janvier).
Décaissements par mois :
- Janvier : salaires 7 500 + URSSAF 9 000 + leasing 1 800 + autres charges 2 200 + achats 0 = 20 500 €.
- Février : salaires 7 500 + leasing 1 800 + autres 2 200 + achats de janvier 6 500 = 18 000 €.
- Mars : salaires 7 500 + leasing 1 800 + autres 2 200 + achats de février 6 500 = 18 000 €.
Soldes de trésorerie :
- Solde initial : 12 000 €.
- Fin janvier : 12 000 + 0 moins 20 500 = -8 500 €.
- Fin février : -8 500 + 0 moins 18 000 = -26 500 € (point bas).
- Fin mars : -26 500 + 22 000 moins 18 000 = -22 500 €.
Conclusion : la trésorerie devient négative dès la fin janvier et atteint son point bas fin février à -26 500 €. Le décalage de 60 jours sur les encaissements, alors que salaires, charges et achats se paient sous 0 à 30 jours, crée un besoin de financement court terme structurel dès le premier mois. Actions nécessaires : négocier un acompte ou un délai clients plus court, mobiliser les créances (affacturage/cession Dailly), mettre en place une facilité de caisse ou un découvert autorisé d'au moins 27 000 €, et lisser l'URSSAF (mensualisation) pour éviter le pic de janvier.$corr$,
  scoring_grid    = $corr$Encaissements (décalage 60 j correctement appliqué) 1,5 pt / Décaissements mensuels (dont achats à 30 j et URSSAF en janvier) 2 pts / Soldes cumulés des 3 mois 2 pts / Conclusion (trésorerie négative + besoin de financement + actions) 1,5 pt = 7 pts$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr20' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Le donneur d'ordre paie à 90 jours et pèse 60 % du CA (180 000 € sur 300 000 €) : c'est à la fois un risque de trésorerie et un risque de dépendance. Quatre actions concrètes :
1) Mobiliser les créances par affacturage ou cession Dailly des factures du donneur d'ordre. Impact : trésorerie encaissée sous 24 à 48 h au lieu de 90 jours, soit jusqu'à environ 45 000 € de trésorerie libérée en permanence (un trimestre de facturation), pour un coût de l'ordre de 1 à 3 % des créances cédées.
2) Renégocier le délai de paiement. Le délai légal maximal est de 60 jours à compter de la date de facture (ou 45 jours fin de mois — art. L.441-10 C. com.) : 90 jours est non conforme. Impact : ramener le délai à 60 jours réduit d'un tiers l'encours financé (gain d'environ 15 000 € de trésorerie) sans dégrader la relation, en s'appuyant sur la règle légale.
3) Diversifier le portefeuille clients pour faire baisser la part du donneur d'ordre sous 40 % du CA (prospection, nouveaux comptes). Impact : réduction du risque de dépendance et de l'exposition d'impayé ; sécurise la pérennité si le donneur d'ordre part.
4) Souscrire une assurance-crédit et/ou proposer un escompte pour paiement anticipé (par exemple 1,5 % pour un règlement à 30 jours). Impact : l'assurance-crédit couvre le risque d'impayé sur les 180 000 € ; l'escompte accélère les encaissements pour un coût maîtrisé et volontaire du client.$corr$,
  scoring_grid    = $corr$4 actions attendues, 1,5 pt chacune (action pertinente 0,75 pt + impact chiffré/argumenté 0,75 pt) = 6 pts. La mention du plafond légal 60 j est valorisée dans l'action 2.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr21' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Prix du VUL : 28 000 € HT.
a. Emprunt bancaire : apport 4 000 €, montant emprunté 24 000 € sur 5 ans (60 mois) à 4,5 %. Prêt amortissable à mensualités constantes : mensualité d'environ 447 €. Total des mensualités = 447 x 60 = environ 26 840 €, dont intérêts environ 2 840 €. Coût total de l'opération = apport 4 000 + remboursements 26 840 = environ 30 840 € HT. Surcoût par rapport au prix : environ 2 840 € (le coût du crédit). À l'issue, le véhicule est votre propriété (inscrit à l'actif, amortissable).
b. Crédit-bail (leasing) : 60 loyers de 540 € = 32 400 €, plus option d'achat finale 800 € = 33 200 € HT. Aucun apport. Surcoût par rapport au prix : 5 200 €.
c. Comparaison et conclusion : l'emprunt est moins coûteux (environ 30 840 € contre 33 200 €, soit environ 2 360 € d'écart) et rend l'entreprise propriétaire immédiatement. Le crédit-bail est plus cher mais ne mobilise aucun apport, préserve la trésorerie et la capacité d'endettement bancaire, et les loyers sont intégralement déductibles. Recommandation : si vous disposez de la trésorerie et visez la constitution d'un patrimoine, choisissez l'emprunt (moins cher, propriété). Si vous voulez préserver votre trésorerie et votre capacité à emprunter pour d'autres besoins, choisissez le crédit-bail malgré son surcoût.$corr$,
  scoring_grid    = $corr$a. Coût total emprunt (mensualité + total + intérêts) 3 pts / b. Coût total crédit-bail (loyers + option) 2 pts / c. Comparaison chiffrée et conclusion selon le besoin (trésorerie vs propriété) 2 pts = 7 pts$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr22' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleD:qr23] : [À CONFIRMER: le calcul IR (impôt foyer ~4 330 €, coût marginal ~4 100 €) dépend du barème progressif et des seuils de tranches applicables l'année de l'épreuve ; recalculer avec le barème IR en vigueur. L'IS à taux réduit 15 % jusqu'à 42 500 € (soit IS = 5 250 €) et les conditions du régime PME sont à jour et confirmés.]
UPDATE public.question_bank SET
  expected_answer = $corr$a. IS de la SARL (régime PME) : le taux réduit d'IS de 15 % s'applique jusqu'à 42 500 € de bénéfice (conditions : CA < 10 M€, capital entièrement libéré détenu à au moins 75 % par des personnes physiques). Le bénéfice de 35 000 € étant inférieur à 42 500 €, il est intégralement taxé à 15 % : IS = 35 000 x 15 % = 5 250 €. Le bénéfice après IS (29 750 €) reste dans la société ; s'il est distribué en dividendes au dirigeant, il supporte en plus le prélèvement forfaitaire unique (30 %).
b. EI à l'IR, couple marié sans enfant (2 parts), revenu du conjoint 25 000 € : le bénéfice BIC de 35 000 € s'ajoute au revenu du foyer. Revenu imposable du foyer = 35 000 + 25 000 = 60 000 €. Quotient familial = 60 000 / 2 = 30 000 € par part. Application du barème progressif de l'IR (tranches à 0 %, 11 % puis 30 %) : impôt d'environ 2 165 € par part, soit environ 4 330 € pour le foyer. En isolant l'effet du bénéfice, l'IR supplémentaire généré par les 35 000 € de BIC est d'environ 4 100 € (le foyer sans ce bénéfice, sur les seuls 25 000 €, ne paierait qu'environ 220 €).
c. Comparaison : à l'IS, le prélèvement immédiat est de 5 250 €, mais le bénéfice reste dans la société et sera à nouveau taxé (PFU 30 %) lors de sa distribution : double imposition si le dirigeant veut disposer des fonds. À l'IR, le coût marginal du bénéfice est d'environ 4 100 €, et la totalité du résultat est directement disponible pour le foyer. À ce niveau de bénéfice, l'IR (EI) est donc généralement plus avantageux si le dirigeant a besoin de percevoir le résultat, alors que l'IS devient intéressant si le bénéfice est réinvesti dans l'entreprise (report d'imposition, taux réduit 15 %).$corr$,
  scoring_grid    = $corr$a. IS = 5 250 € (taux réduit 15 % correctement appliqué) 2,5 pts / b. Calcul IR foyer (revenu imposable, parts, barème) 3 pts / c. Comparaison motivée + arbitrage distribution/réinvestissement 1,5 pt = 7 pts$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr23' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Renault Clio (véhicule de tourisme, VP) : la TVA sur l'acquisition d'un véhicule de tourisme n'est pas déductible (exclusion du droit à déduction pour les véhicules conçus pour le transport de personnes). TVA récupérée sur le véhicule = 0 €. Sur le gazole : pour un véhicule de tourisme, la TVA sur le gazole est déductible à 80 %. Gazole 1 800 € HT, TVA à 20 % = 360 €, récupérable à 80 % = 288 €.
b. Trafic 2 places (VUL, véhicule utilitaire) : la TVA sur l'acquisition est intégralement déductible car le véhicule est affecté au transport de marchandises. TVA récupérée sur le véhicule = 28 000 x 20 % = 5 600 €. Sur le gazole : pour un utilitaire, la TVA sur le gazole est déductible à 100 %. Gazole 1 800 € HT, TVA = 360 €, récupérable à 100 % = 360 €.
c. Total TVA récupérée en année 1 : Clio (0 + 288) + Trafic (5 600 + 360) = 288 + 5 960 = 6 248 €.
Synthèse : le choix d'un utilitaire plutôt que d'un véhicule de tourisme permet de récupérer 5 600 € de TVA sur l'achat (contre 0 €) et 100 % de la TVA sur le carburant (contre 80 %), avantage de trésorerie et de coût déterminant pour l'activité de livraison.$corr$,
  scoring_grid    = $corr$a. Clio : TVA véhicule non déductible (0) + gazole 80 % = 288 € : 2,5 pts / b. Trafic : TVA véhicule 5 600 € + gazole 100 % = 360 € : 2,5 pts / c. Total 6 248 € + synthèse VP/VUL : 2 pts = 7 pts$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr24' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleD:qr25] : [À CONFIRMER: seuil de franchise en base de TVA pour les services (36 800 € repris de l'énoncé) et plafond du réel simplifié — seuils en cours de réforme 2025-2026 (projet d'abaissement unifié à 25 000 € suspendu). Vérifier le seuil réellement applicable l'année de l'épreuve. La déclaration annuelle CA12 et les acomptes semestriels juillet (~55 %) / décembre (~40 %) sont confirmés.]
UPDATE public.question_bank SET
  expected_answer = $corr$Situation : CA de 95 000 € HT en prestations de services, très supérieur au seuil de la franchise en base de TVA (36 800 € pour les services, énoncé). L'entreprise ne peut plus bénéficier de la franchise et bascule au régime réel simplifié d'imposition (RSI), applicable tant que le CA services reste sous le plafond du réel simplifié.
a. Démarches : déclarer le changement de régime au service des impôts des entreprises (SIE), obtenir/activer le numéro de TVA intracommunautaire, facturer désormais la TVA à 20 % avec mention sur toutes les factures (taux, montant HT, TVA, TTC), et tenir une comptabilité permettant le suivi de la TVA collectée et déductible.
b. Périodicité de déclaration : au régime réel simplifié, la déclaration de TVA est annuelle (formulaire CA12), déposée au plus tard début mai de l'année suivante. En cours d'année, l'entreprise verse deux acomptes semestriels calculés sur la TVA de l'exercice précédent : un acompte en juillet (environ 55 %) et un en décembre (environ 40 %), régularisés par la CA12.
c. Impact sur la trésorerie : l'entreprise collecte désormais la TVA (environ 19 000 € sur un CA de 95 000 €) qu'elle devra reverser, mais elle récupère aussi la TVA sur ses achats, son carburant et ses investissements (gain de trésorerie et de coût). Points de vigilance : décalage entre l'encaissement de la TVA collectée et son reversement (à provisionner), sortie de trésorerie liée aux acomptes de juillet et décembre, et effet prix pour les clients particuliers non assujettis (la TVA renchérit la prestation), neutre en revanche pour les clients professionnels qui la récupèrent.$corr$,
  scoring_grid    = $corr$a. Démarches (déclaration SIE, n° TVA intracommunautaire, facturation TVA) 2 pts / b. Périodicité : déclaration annuelle CA12 + 2 acomptes semestriels 2 pts / c. Impact trésorerie (collecte/reversement, récupération sur achats, acomptes, effet clients) 2 pts = 6 pts$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleD:qr25' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Hiérarchie des sources du droit du travail (du plus élevé au plus bas) : (1) bloc de constitutionnalité et normes internationales/européennes (traités, règlements et directives UE, conventions OIT), (2) la loi et les règlements (Code du travail), (3) les conventions et accords collectifs (accord de branche comme la CCN Transports routiers, puis accord d'entreprise), (4) le contrat de travail, (5) les usages et engagements unilatéraux de l'employeur, (6) le règlement intérieur et les notes de service. Une norme inférieure doit en principe respecter la norme supérieure.
b. Principe de faveur : lorsqu'un même sujet est réglé par plusieurs normes, on applique celle qui est la plus favorable au salarié, même si elle est de rang inférieur. Attention : depuis les ordonnances Macron de 2017, la primauté de l'accord d'entreprise sur l'accord de branche est devenue la règle dans de nombreux domaines (sauf blocs de compétence réservés à la branche : salaires minima, classifications, prévoyance, pénibilité, égalité, etc.), ce qui limite la portée classique du principe de faveur entre branche et entreprise.
c. Exemple : la loi fixe la durée légale à 35 h et un repos quotidien minimal de 11 h. Si la CCN ou le contrat prévoit une prime d'ancienneté ou 5 semaines de congés supplémentaires, c'est la disposition la plus favorable au salarié qui s'applique. À l'inverse, une clause du contrat prévoyant un salaire inférieur au minimum conventionnel est nulle et remplacée par le minimum conventionnel.$corr$,
  scoring_grid    = $corr$a. 2 pts : hiérarchie correctement ordonnée (au moins 4 niveaux : international/UE, loi, conventions/accords, contrat) / b. 2 pts : définition du principe de faveur (1 pt) + nuance ordonnances 2017 primauté accord d'entreprise (1 pt) / c. 1 pt : exemple pertinent et correct. Total = 5.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Règle applicable : le CDD conclu pour remplacer un salarié absent est un contrat à terme incertain licite, mais il doit obligatoirement, à peine d'irrégularité, être établi par écrit et comporter la définition précise de son motif, ce qui inclut le nom et la qualification de la personne remplacée (art. L.1242-12 C. trav.). L'absence de cette mention rend le contrat irrégulier.
b. Risque principal : requalification en CDI. Le salarié peut saisir le conseil de prud'hommes ; l'affaire est portée directement devant le bureau de jugement qui statue dans un délai court (art. L.1245-2). Faute de mention obligatoire (ici le nom du remplacé) ou d'écrit conforme, le CDD est réputé conclu pour une durée indéterminée.
c. Conséquences financières et juridiques pour la SARL : versement d'une indemnité de requalification au moins égale à un mois de salaire (art. L.1245-2) ; si la relation est ensuite rompue, la rupture s'analyse en licenciement sans cause réelle et sérieuse (indemnité de licenciement, indemnité compensatrice de préavis, dommages-intérêts) ; requalification de la relation en CDI. Recommandation : régulariser immédiatement le contrat en y portant le nom et la qualification de la salariée remplacée.$corr$,
  scoring_grid    = $corr$a. 2 pts : mention obligatoire du nom/qualification du remplacé et exigence d'écrit (art. L.1242-12) / b. 1,5 pt : risque de requalification en CDI et saisine prud'homale / c. 1,5 pt : conséquences financières (indemnité de requalification ≥ 1 mois + rupture = licenciement sans cause). Total = 5.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Avantages du CDI pour l'employeur : contrat de droit commun sans formalisme de motif, pas de prime de précarité, souplesse d'organisation dans la durée, fidélisation et montée en compétence du salarié, image d'employeur stable (facilite le recrutement). Inconvénient : rupture encadrée (procédure de licenciement, motif réel et sérieux, coût potentiel).
b. Avantages du CDD pour l'employeur : réponse à un besoin temporaire et précisément identifié, terme connu à l'avance (pas de procédure de licenciement à l'échéance), adaptation à la charge. Inconvénients : cas de recours limitativement énumérés, formalisme strict (écrit, motif, mentions), durée et renouvellements plafonnés, prime de précarité de 10 % à l'échéance, requalification en CDI si irrégularité.
c. Cas d'usage : CDI pour un besoin permanent et durable de l'entreprise (poste de conducteur pérenne, activité structurelle). CDD uniquement pour un besoin temporaire limitativement prévu par la loi : remplacement d'un salarié absent, accroissement temporaire d'activité (pics saisonniers), emploi saisonnier, CDD d'usage. Le CDD ne peut jamais pourvoir durablement un emploi lié à l'activité normale et permanente.$corr$,
  scoring_grid    = $corr$a. 1,5 pt : avantages/inconvénients du CDI pour l'employeur / b. 1,5 pt : avantages/inconvénients du CDD (dont prime précarité 10 % et cas de recours limités) / c. 2 pts : cas d'usage correct (CDI = besoin permanent ; CDD = besoin temporaire avec exemples de motifs légaux). Total = 5.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleE:qr4] : [À CONFIRMER: assiette exacte de la prime d'ancienneté CCN Transports routiers (1 % calculé sur le taux/salaire conventionnel de la catégorie, potentiellement différent du salaire réel) — vérifier le barème conventionnel en vigueur 2026 avant de figer le total.]
UPDATE public.question_bank SET
  expected_answer = $corr$Données : 40 h/semaine, taux horaire 12,40 € brut, prime d'ancienneté CCN 1 % (2 ans). La durée légale est de 35 h ; les heures au-delà sont des heures supplémentaires majorées de 25 % (les 8 premières).
a. Base mensualisée (35 h) : 35 h × 52/12 = 151,67 h. 151,67 h × 12,40 € = 1 880,71 € brut.
b. Heures supplémentaires : 5 h/semaine au-delà de 35 h, mensualisées : 5 × 52/12 = 21,67 h/mois, majorées de 25 % : 21,67 h × 12,40 € × 1,25 ≈ 335,88 €.
c. Prime d'ancienneté 1 % : appliquée sur le salaire de base conventionnel. En la calculant sur la base mensualisée : 1 % × 1 880,71 € = 18,81 € (à ajuster si l'énoncé retient une assiette conventionnelle différente).
d. Salaire brut mensuel total : 1 880,71 + 335,88 + 18,81 ≈ 2 235,40 € brut.$corr$,
  scoring_grid    = $corr$a. 2 pts : base mensualisée correcte (151,67 h × 12,40 = 1 880,71 €) / b. 2 pts : heures supplémentaires mensualisées à +25 % (≈ 335,88 €) / c. 1 pt : prime d'ancienneté 1 % (≈ 18,81 €) / d. 1 pt : total cohérent (≈ 2 235 €). Total = 6.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr4' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Temps de conduite : période durant laquelle le conducteur est effectivement au volant. Il est encadré par la réglementation sociale européenne / le Code des transports (durées maximales de conduite journalière, hebdomadaire, coupures et repos), dans un objectif de sécurité routière.
b. Temps de travail effectif (TTE) : temps pendant lequel le salarié est à la disposition de l'employeur et se conforme à ses directives sans pouvoir vaquer à ses occupations personnelles (art. L.3121-1 C. trav.). Il englobe la conduite mais aussi les chargements/déchargements, l'attente commandée, les formalités, l'entretien du véhicule.
c. Enjeux de la distinction : (1) le TTE sert de base au calcul du salaire, des heures supplémentaires et des durées maximales de travail ; (2) le temps de conduite relève d'une logique de sécurité et de contrôle (chronotachygraphe, sanctions spécifiques) ; (3) certaines périodes (temps de disposition, coupures) ne sont pas du TTE et ne sont pas rémunérées comme telles. Confondre les deux fausse la paie et expose à des infractions distinctes.$corr$,
  scoring_grid    = $corr$a. 1 pt : définition du temps de conduite et finalité sécurité / b. 1 pt : définition du TTE (art. L.3121-1) / c. 2 pts : enjeux de la distinction (base de rémunération/heures sup vs cadre sécurité, périmètres différents). Total = 4.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr5' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Qualification : chute en descendant de la cabine sur le lieu et le temps de travail = accident du travail. Obligation de déclaration : l'employeur déclare l'AT à la CPAM dans les 48 heures (hors dimanche et jours fériés) et remet au salarié une feuille d'accident. Le défaut de déclaration est sanctionné.
b. Faute inexcusable de l'employeur : l'absence de DUER à jour et l'absence d'EPI caractérisent un manquement à l'obligation de sécurité (obligation de moyens renforcée, jurisprudence depuis 2015). Le salarié peut demander la reconnaissance de la faute inexcusable, ce qui ouvre droit à une majoration de la rente/indemnité en capital et à la réparation des préjudices (souffrances, préjudice esthétique, d'agrément).
c. Conséquences financières : coût de l'AT imputé au compte employeur avec hausse du taux de cotisation AT/MP ; en cas de faute inexcusable, la CPAM avance les sommes puis en récupère le montant auprès de l'employeur (action récursoire).
d. Sanctions pénales et administratives : le DUER est obligatoire ; son absence et le défaut de fourniture des EPI constituent des infractions à la santé-sécurité (amendes, mise en demeure de l'inspection du travail, responsabilité pénale du chef d'entreprise en cas de manquement grave). Recommandation : établir/mettre à jour le DUER, fournir et faire porter les EPI, tracer les consignes.$corr$,
  scoring_grid    = $corr$a. 1 pt : qualification AT + déclaration CPAM sous 48 h / b. 2 pts : faute inexcusable (manquement obligation de sécurité, DUER + EPI) et ses effets (majoration, préjudices) / c. 1,5 pt : conséquences financières (taux AT/MP, action récursoire CPAM) / d. 1,5 pt : sanctions pénales/administratives (DUER et EPI obligatoires). Total = 6.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr6' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Poursuite de la relation après le terme : un CDD qui se poursuit après l'échéance du terme sans nouveau contrat écrit devient automatiquement un CDI (art. L.1243-11 C. trav.), avec reprise de l'ancienneté au premier jour du CDD. Les 2 mois de mission supplémentaires sans avenant transforment donc la relation en CDI.
b. Requalification possible : au-delà de la poursuite, le recours pour accroissement temporaire d'activité (factures de Noël) puis le maintien du salarié sur 2 mois supplémentaires laissent penser que le poste correspond à un besoin durable ; le salarié peut demander la requalification en CDI avec indemnité de requalification au moins égale à un mois de salaire.
c. Le licenciement 3 semaines après : la relation étant devenue un CDI, la rupture doit suivre la procédure de licenciement (convocation, entretien préalable, notification motivée). Ici aucune procédure ni motif réel et sérieux : le licenciement est sans cause réelle et sérieuse.
d. Risques financiers cumulés : indemnité de requalification (≥ 1 mois de salaire), indemnité compensatrice de préavis, indemnité de licenciement, indemnité pour licenciement sans cause réelle et sérieuse (barème Macron selon l'ancienneté), éventuellement rappel de prime de précarité si due. Recommandation : ne jamais laisser courir un CDD au-delà du terme sans contrat écrit.$corr$,
  scoring_grid    = $corr$a. 2 pts : poursuite après terme sans écrit = CDI automatique (art. L.1243-11) avec reprise d'ancienneté / b. 1,5 pt : requalification en CDI et indemnité de requalification ≥ 1 mois / c. 2 pts : licenciement sans procédure ni motif = sans cause réelle et sérieuse / d. 1,5 pt : chiffrage des risques cumulés (préavis, licenciement, dommages-intérêts barème). Total = 7.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr7' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Heures travaillées : lundi 9 + mardi 10 + mercredi 9,5 + jeudi 8,5 + vendredi 7 + samedi 4 = 48 h sur la semaine. Taux horaire 13 € brut, pas d'heures structurelles.
a. Heures normales (35 h) : 35 × 13 = 455,00 €.
b. Heures supplémentaires majorées de 25 % (de la 36e à la 43e heure, soit 8 h) : 8 × 13 × 1,25 = 8 × 16,25 = 130,00 €.
c. Heures supplémentaires majorées de 50 % (au-delà de la 43e heure, soit de la 44e à la 48e = 5 h) : 5 × 13 × 1,50 = 5 × 19,50 = 97,50 €.
d. Salaire brut hebdomadaire total : 455,00 + 130,00 + 97,50 = 682,50 € brut.
Contrôle des heures supplémentaires : 8 h à 25 % + 5 h à 50 % = 13 h ; 35 + 13 = 48 h.$corr$,
  scoring_grid    = $corr$a. 1 pt : total des heures = 48 h / b. 2 pts : identification des seuils (35 h normales, 36-43 h à +25 %, au-delà à +50 %) / c. 1,5 pt : calcul des 8 h à +25 % = 130 € / d. 1,5 pt : calcul des 5 h à +50 % = 97,50 € / e. 1 pt : total hebdomadaire = 682,50 €. Total = 7.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr8' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleE:qr9] : [À CONFIRMER: durée exacte du préavis pour un conducteur (ouvrier) dans la CCN Transports routiers en fonction de l'ancienneté et du coefficient — vérifier la grille conventionnelle 2026, qui peut différer du minimum légal de 2 mois.]
UPDATE public.question_bank SET
  expected_answer = $corr$a. Motif et procédure de licenciement économique : la perte d'un client représentant 60 % du CA peut constituer une cause économique (difficultés économiques / menace sur la compétitivité) à condition d'être réelle et sérieuse. Procédure pour un licenciement individuel : recherche préalable de reclassement, convocation à un entretien préalable (LRAR ou remise en main propre, délai minimal de 5 jours ouvrables avant l'entretien), entretien, puis notification par LRAR motivée en respectant le délai légal ; proposition du contrat de sécurisation professionnelle (CSP) obligatoire dans les entreprises de moins de 1 000 salariés (son acceptation dispense d'exécuter le préavis, l'indemnité de préavis finançant le dispositif) ; information de la DREETS.
b. Indemnité légale de licenciement : ancienneté 7 ans, salaire de référence 2 600 €. Barème : 1/4 de mois par an pour les 10 premières années. 7 × (2 600 / 4) = 7 × 650 = 4 550 €.
c. Préavis : le préavis légal pour une ancienneté ≥ 2 ans est de 2 mois ; la CCN Transports routiers fixe la durée applicable selon la catégorie (ouvrier/employé). À retenir : 2 mois de préavis (soit 2 × 2 600 = 5 200 € si non exécuté), sous réserve d'une durée conventionnelle plus favorable.
d. Autres points : respect de l'ordre des critères, priorité de réembauche pendant 1 an, remise des documents de fin de contrat (certificat de travail, attestation France Travail, solde de tout compte).$corr$,
  scoring_grid    = $corr$a. 2 pts : cause économique + procédure (reclassement, entretien préalable, notification, CSP, DREETS) / b. 2 pts : calcul indemnité légale = 4 550 € (1/4 mois × 7 ans) / c. 1,5 pt : préavis 2 mois (légal ≥ 2 ans) et chiffrage / d. 1,5 pt : obligations annexes (priorité de réembauche, documents de fin de contrat). Total = 7.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr9' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Obligations administratives liées à l'embauche du premier salarié :
1. Déclaration préalable à l'embauche (DPAE) auprès de l'URSSAF, au plus tôt 8 jours avant l'embauche et au plus tard dans les instants précédant la prise de poste (elle vaut immatriculation employeur, affiliation régime, demande de visite médicale).
2. Rédaction et remise du contrat de travail écrit (obligatoire pour un CDD ou un temps partiel ; recommandé pour tout CDI), dans les délais légaux.
3. Inscription sur le registre unique du personnel, tenu dès le premier salarié.
4. Affiliation à une caisse de retraite complémentaire (Agirc-Arrco) et mise en place de la mutuelle santé complémentaire d'entreprise obligatoire.
5. Adhésion à un service de prévention et de santé au travail (SPST) et organisation de la visite d'information et de prévention (VIP) dans les 3 mois suivant la prise de poste (avant l'embauche pour un poste à risque ou un travailleur suivi de façon renforcée).
6. Établissement/mise à jour du document unique d'évaluation des risques professionnels (DUERP) et affichage des informations obligatoires (horaires, consignes sécurité, coordonnées inspection du travail, médecine du travail).
7. Mise en place de la paie et des déclarations sociales via la DSN (déclaration sociale nominative), remise du bulletin de paie.$corr$,
  scoring_grid    = $corr$6 pts au total, 1 pt par bloc d'obligation correctement cité avec organisme/délai : DPAE URSSAF (8 j) = 1 pt / contrat écrit = 1 pt / registre unique du personnel = 1 pt / retraite complémentaire + mutuelle = 1 pt / SPST + visite médicale (3 mois) = 1 pt / DUERP + affichages + DSN/paie = 1 pt. Total = 6.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr10' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Qualification et obligation : regards insistants, propos déplacés à connotation sexuelle et contacts physiques non sollicités répétés relèvent du harcèlement sexuel (art. L.1153-1 C. trav.). L'employeur est tenu d'une obligation de sécurité et de prévention : il doit agir dès qu'il a connaissance des faits, sans attendre.
b. Procédure étape par étape : (1) recueillir le signalement de la salariée, la protéger et l'informer de ses droits (droit de saisir le référent harcèlement, le CSE, l'inspection du travail, le Défenseur des droits) ; (2) déclencher sans délai une enquête interne impartiale, en associant le référent harcèlement du CSE et/ou le référent employeur, en respectant la confidentialité et le contradictoire ; (3) prendre des mesures conservatoires pour faire cesser les faits (éloignement des deux personnes, réaménagement des postes/horaires, éventuelle mise à pied conservatoire du salarié mis en cause) sans faire peser la sanction sur la victime ; (4) au vu des conclusions, engager une procédure disciplinaire à l'encontre de l'auteur si les faits sont établis (le harcèlement sexuel justifie une sanction pouvant aller jusqu'au licenciement pour faute grave) ; (5) informer la victime des suites, assurer son suivi (orientation vers le médecin du travail) et veiller à l'absence de représailles ; (6) tracer par écrit chaque étape.
c. Risques en cas d'inaction : manquement à l'obligation de sécurité engageant la responsabilité civile de l'employeur (dommages-intérêts), voire responsabilité pénale, et prise d'acte/résiliation judiciaire aux torts de l'employeur.$corr$,
  scoring_grid    = $corr$a. 1 pt : qualification harcèlement sexuel + obligation de sécurité/agir sans délai / b. 5 pts : procédure (recueil et protection 1 pt, enquête interne impartiale + référent/CSE 2 pts, mesures conservatoires sans sanctionner la victime 1 pt, sanction disciplinaire de l'auteur 1 pt) / c. 1 pt : risques en cas d'inaction (responsabilité employeur). Total = 7.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr11' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Procédure de rupture conventionnelle : (1) un ou plusieurs entretiens entre l'employeur et le salarié, qui peut se faire assister ; (2) signature de la convention de rupture fixant la date de rupture et le montant de l'indemnité, avec remise d'un exemplaire à chaque partie ; (3) délai de rétractation de 15 jours calendaires ouvert à chacune des parties à compter de la signature ; (4) à l'issue, demande d'homologation à la DREETS, qui dispose de 15 jours ouvrables pour se prononcer (silence = homologation tacite) ; (5) la rupture ne peut intervenir avant l'homologation.
b. Indemnité minimale : elle ne peut être inférieure à l'indemnité légale de licenciement. Ancienneté 4 ans, salaire 2 400 € brut. Barème : 1/4 de mois par an pour les 10 premières années. 4 × (2 400 / 4) = 4 × 600 = 2 400 €.
c. Résultat : indemnité spécifique de rupture conventionnelle minimale = 2 400 € brut (montant pouvant être négocié à la hausse). Le salarié bénéficie par ailleurs de l'allocation chômage sous conditions.$corr$,
  scoring_grid    = $corr$a. 1 pt : entretien(s) et assistance possible du salarié / b. 1,5 pt : signature de la convention + délai de rétractation de 15 jours calendaires / c. 1,5 pt : homologation DREETS (15 jours ouvrables) / d. 2 pts : calcul de l'indemnité minimale = 2 400 € (1/4 mois × 4 ans). Total = 6.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr12' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleE:qr13] : Correction réglementaire apportée : la CSSCT n'est PAS obligatoire à 50 salariés (seulement à 300, ou établissements à risque / décision inspection) — à 50 salariés le CSE absorbe les missions du CHSCT. Participation : déclenchée après 50 salariés maintenus 5 années consécutives, pas au seuil de 12 mois. [À CONFIRMER: délais précis de mise en conformité 2026 (échéance du règlement intérieur) et montants/plafonds exacts des sanctions financières — vérifier les seuils et calendriers en vigueur au 1er janvier 2026.]
UPDATE public.question_bank SET
  expected_answer = $corr$Franchissement du seuil de 50 salariés (atteint et maintenu 12 mois consécutifs). Principales obligations nouvelles :
1. CSE aux attributions élargies : au-delà du CSE des entreprises de 11 à 49 salariés, mise en place des attributions étendues (consultations récurrentes, expertises, budget de fonctionnement et budget des activités sociales et culturelles).
2. Attributions santé-sécurité du CSE : à 50 salariés, le CSE reprend les missions de l'ancien CHSCT (analyse des risques, inspections, enquêtes AT). En revanche, la commission santé, sécurité et conditions de travail (CSSCT) distincte n'est PAS obligatoire à 50 salariés : elle ne l'est qu'à partir de 300 salariés (ou dans certains établissements à risque type Seveso/nucléaire, ou sur décision de l'inspection du travail).
3. Règlement intérieur obligatoire : à établir dans un délai déterminé après le franchissement du seuil (procédure de consultation du CSE et dépôt).
4. Participation des salariés aux résultats : obligation de mettre en place un accord de participation, mais seulement après avoir employé au moins 50 salariés pendant 5 années civiles consécutives (le franchissement à 12 mois déclenche les obligations CSE, pas immédiatement la participation).
5. Index de l'égalité professionnelle femmes-hommes : calcul et publication annuelle de l'index à partir de 50 salariés.
6. Contributions sociales à taux plein : notamment FNAL au taux plein, et autres obligations liées au seuil (contribution formation ; l'obligation d'emploi de travailleurs handicapés s'applique déjà dès 20 salariés).
Calendrier : la plupart des obligations liées au CSE s'appliquent après le maintien du seuil pendant 12 mois consécutifs, avec des délais de mise en conformité propres (règlement intérieur), la participation obéissant à la règle des 5 années consécutives. Sanctions en cas de non-respect : délit d'entrave pour le CSE (amende pénale), pénalité financière pouvant aller jusqu'à 1 % de la masse salariale pour l'index égalité non publié ou non conforme, redressements URSSAF pour les contributions, sanctions pour absence de règlement intérieur.$corr$,
  scoring_grid    = $corr$7 pts au total : CSE élargi (attributions, budgets ASC) 1,5 pt / attributions santé-sécurité du CSE — CSSCT distincte seulement à 300 salariés 1 pt / règlement intérieur 1 pt / accord de participation (règle des 5 ans) 1,5 pt / index égalité professionnelle 1 pt / contributions à taux plein (FNAL, etc.) + mention du calendrier et des sanctions 1 pt. Total = 7.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr13' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Hypothèse de charges patronales : 42 % du brut (comme indiqué dans le lot).
a. Option CDI, 2 200 € brut/mois : salaire brut annuel = 2 200 × 12 = 26 400 €. Coût employeur = 26 400 × 1,42 = 37 488 € sur 12 mois.
b. Option CDD 12 mois avec prime de précarité 10 % : salaire brut annuel = 26 400 € ; prime de précarité = 10 % × 26 400 = 2 640 € (versée en fin de contrat et soumise à charges) ; brut total = 29 040 €. Coût employeur = 29 040 × 1,42 = 41 236,80 € sur 12 mois.
c. Comparaison : le CDD coûte 41 236,80 - 37 488 = 3 748,80 € de plus sur l'année, essentiellement du fait de la prime de précarité (10 %) et des charges associées.
d. Recommandation : le poste de chauffeur décrit correspond à un besoin durable (CDD présenté comme renouvelable pour un emploi permanent), ce qui rend le recours au CDD juridiquement fragile (risque de requalification) et plus coûteux. Recommander le CDI, sauf besoin réellement temporaire et limité dans le temps (remplacement, pic saisonnier), auquel cas le CDD reste justifié malgré son surcoût.$corr$,
  scoring_grid    = $corr$a. 2 pts : coût CDI = 37 488 € (26 400 × 1,42) / b. 2 pts : coût CDD = 41 236,80 € (prime précarité 10 % incluse puis × 1,42) / c. 1 pt : écart chiffré (≈ 3 749 €) et cause (prime de précarité) / d. 1 pt : recommandation argumentée selon le caractère permanent ou temporaire du besoin. Total = 6.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr14' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleE:qr15] : [À CONFIRMER: le calcul exact du net imposable intègre normalement la réintégration de la CSG/CRDS non déductible (env. 2,90 % du brut soumis), ce qui le majore légèrement par rapport au net à payer avant impôt ; l'énoncé étant simplifié (un seul taux salarial de 22 %), le corrigé retient l'assiette nette des cotisations. Préciser au stagiaire la méthode attendue par le jury.]
UPDATE public.question_bank SET
  expected_answer = $corr$Données : brut total 2 350 € dont 80 € de prime de panier non soumise ; cotisations salariales 22 %, PAS 5 %, charges patronales 42 % sur le brut soumis.
a. Brut soumis à cotisations : 2 350 - 80 = 2 270 €.
b. Cotisations salariales : 22 % × 2 270 = 499,40 €.
c. Net à payer avant impôt : brut total - cotisations salariales = 2 350 - 499,40 = 1 850,60 € (la prime de panier de 80 € reste versée mais non soumise).
d. Net imposable (approche simplifiée d'examen) : assiette soumise nette des cotisations = 2 270 - 499,40 = 1 770,60 € (la prime de panier, frais professionnels, est exclue de l'assiette imposable).
e. Prélèvement à la source : 5 % × 1 770,60 = 88,53 €.
f. Net à payer après impôt : 1 850,60 - 88,53 = 1 762,07 €.
g. Coût total entreprise : charges patronales = 42 % × 2 270 = 953,40 € ; coût total = brut soumis 2 270 + charges 953,40 + prime non soumise 80 = 3 303,40 €.$corr$,
  scoring_grid    = $corr$a. 1 pt : brut soumis = 2 270 € (2 350 - 80) / b. 1,5 pt : cotisations salariales 22 % = 499,40 € / c. 1,5 pt : net imposable ≈ 1 770,60 € (prime panier exclue) / d. 1,5 pt : PAS 5 % (≈ 88,53 €) et net à payer (≈ 1 762 €) / e. 1,5 pt : coût total entreprise = 3 303,40 € (2 270 + 953,40 + 80). Total = 7.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleE:qr15' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Titre de conduite : le conducteur doit détenir un permis B en cours de validité (suffisant pour un VUL dont le PTAC est inférieur ou égal à 3,5 t). La visite médicale du permis n'est pas exigée pour la seule catégorie B lorsqu'on reste sous 3,5 t.

b. Qualification professionnelle (FIMO/FCO/CQC) : point clé de distinction lourd/léger. L'obligation de qualification initiale (FIMO) et de formation continue (FCO), matérialisée par la carte de qualification de conducteur (CQC), ne concerne QUE la conduite de véhicules de transport de marchandises dont le PTAC dépasse 3,5 t (permis C). Pour un conducteur de VUL inférieur ou égal à 3,5 t en compte d'autrui, il n'y a donc PAS d'obligation de FIMO ni de FCO. À retenir : c'est le PTAC du véhicule conduit, non le statut de l'entreprise, qui déclenche l'obligation.

c. Formations complémentaires selon l'activité : formation ADR (conducteur) si transport de marchandises dangereuses au-dessus des seuils d'exemption ; formations internes obligatoires à la sécurité au poste (arrimage, gestes et postures, utilisation du hayon) au titre du Code du travail ; le cas échéant, habilitations spécifiques (denrées sous température dirigée, etc.).

d. Périodicité des renouvellements : pour mémoire, lorsqu'une FCO est requise (véhicules de plus de 3,5 t), elle se renouvelle tous les 5 ans ; le certificat ADR conducteur se renouvelle également tous les 5 ans ; la validité administrative du permis (titre sécurisé) est de 15 ans mais ne rouvre pas de droit de conduite. Pour l'activité VUL inférieur ou égal à 3,5 t stricte, aucune périodicité de type FCO ne s'applique.$corr$,
  scoring_grid    = $corr$a. 1 pt : permis B valide identifié comme titre suffisant pour VUL inférieur ou égal à 3,5 t. / b. 2 pts : distinction lourd/léger correctement posée, absence d'obligation FIMO/FCO/CQC sous 3,5 t (critère = PTAC du véhicule). / c. 1 pt : au moins deux formations complémentaires pertinentes (ADR si MD, formations sécurité/arrimage internes). / d. 1 pt : périodicités correctes citées (FCO 5 ans et ADR 5 ans pour le lourd, absence de FCO en léger). Total 5.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleF:qr1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Signalement et traçabilité (conducteur) : dès qu'il constate l'anomalie (freinage qui tire à droite), le conducteur doit la signaler immédiatement à l'exploitant et la consigner par écrit sur une fiche de défaut (ou carnet de bord / bon d'anomalie). L'écrit date, décrit le symptôme et engage la remontée d'information.

b. Évaluation du danger et immobilisation : le freinage est un organe de sécurité. Un défaut de freinage rend le véhicule potentiellement dangereux : le principe est l'immobilisation immédiate du véhicule tant que le diagnostic n'est pas fait. Le conducteur ne doit pas poursuivre une tournée avec un véhicule susceptible de mettre en danger. En cas de doute sur la gravité, on ne prend pas le risque : on immobilise.

c. Diagnostic, réparation et remise en service (exploitant) : l'exploitant fait réaliser le diagnostic et la réparation par un professionnel qualifié (garage/atelier), trace l'intervention dans le carnet d'entretien du véhicule, puis ne remet le véhicule en service qu'après contrôle de la remise en conformité. La fiche de défaut est soldée et archivée.

d. Responsabilités : l'employeur a l'obligation de mettre à disposition un véhicule en bon état de marche et d'entretien (obligation de sécurité de résultat vis-à-vis du salarié et des tiers) ; le conducteur a l'obligation d'alerter et de ne pas circuler sciemment avec un véhicule dangereux (à défaut, mise en danger et partage de responsabilité en cas d'accident). En cas d'accident lié à un défaut connu et non traité, la responsabilité civile et pénale de l'entreprise et de son dirigeant peut être engagée.$corr$,
  scoring_grid    = $corr$a. 1,5 pt : signalement immédiat et consignation écrite (fiche de défaut / carnet de bord). / b. 1,5 pt : reconnaissance du frein comme organe de sécurité et immobilisation du véhicule. / c. 1 pt : réparation par un professionnel, traçabilité et remise en service après contrôle. / d. 1 pt : partage des responsabilités employeur (véhicule en bon état) / conducteur (alerte, non-circulation). Total 5.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleF:qr2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleF:qr3] : [À CONFIRMER: numéro UN, groupe d'emballage et catégorie de transport exacts du white-spirit du client (UN 1300 GE III / cat 3, seuil 1 000 L ; ou GE II / cat 2, seuil 333 L selon le point d'éclair), sur la version ADR en vigueur 2026. La conclusion d'exemption (200 L) tient dans les deux hypothèses, mais vérifier la fiche produit avant diffusion.]
UPDATE public.question_bank SET
  expected_answer = $corr$a. Identification et vérification du seuil ADR : le white-spirit relève de la classe 3 (liquides inflammables), généralement UN 1300 (« térébenthine, succédané de »), groupe d'emballage III, catégorie de transport 3 (à confirmer sur la fiche de sécurité / le document ADR du produit précis, car certains white-spirits à point d'éclair plus bas relèvent du groupe d'emballage II, catégorie de transport 2). La règle décisive est l'exemption partielle du 1.1.3.6 (quantités transportées par unité de transport). Pour la catégorie de transport 3, le seuil est de 1 000 (unités = litres pour un liquide, coefficient 1) ; pour la catégorie de transport 2, il est de 333. 200 L restent en dessous des deux seuils : l'opération peut donc bénéficier de l'exemption partielle 1.1.3.6 quel que soit le groupe d'emballage retenu.

b. Formations : sous le seuil du 1.1.3.6, le conducteur n'a PAS besoin du certificat de formation ADR (formation spécialisée + examen). En revanche, la formation de sensibilisation générale au titre du chapitre 1.3 (adaptée à la fonction) reste obligatoire pour toute personne intervenant dans le transport. Au-dessus du seuil (par exemple si l'on dépassait la quantité maximale correspondant à la catégorie de transport), le certificat ADR conducteur deviendrait obligatoire, ainsi que la signalisation orange, le matériel de bord complet, etc.

c. Autorisations, équipements et documents : emballages homologués UN et compatibles, correctement fermés et arrimés ; étiquetage de danger classe 3 sur les colis ; document de transport mentionnant le numéro UN, la désignation, la classe, le groupe d'emballage et les quantités (avec le calcul 1.1.3.6) ; extincteur adapté à bord ; interdiction de fumer pendant les opérations ; bonne aération et absence de source d'ignition. Aucune autorisation administrative particulière au-delà de ces obligations tant qu'on reste sous le seuil.$corr$,
  scoring_grid    = $corr$a. 2 pts : identification classe 3 / groupe d'emballage / catégorie de transport et calcul du seuil 1.1.3.6 (200 L inférieurs au seuil, exemption partielle). / b. 2 pts : pas de certificat ADR conducteur sous le seuil mais formation de sensibilisation 1.3 obligatoire, bascule au certificat ADR au-dessus du seuil. / c. 2 pts : emballages homologués + étiquetage + document de transport + extincteur/interdiction de fumer/arrimage. Total 6.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleF:qr3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$a. Charge utile théorique : CU = PTAC - PV (masse à vide) = 3 500 - 2 200 = 1 300 kg. Le véhicule peut donc emporter 1 300 kg de charge ajoutée (conducteur, carburant, chargement) sans dépasser le PTAC.

b. Conversion du carburant : le gasoil a une masse volumique d'environ 0,84 kg/L. 80 L pèsent donc environ 80 x 0,84 = 67 kg (arrondi).

c. Charge réelle additionnée : conducteur 75 kg + gasoil 67 kg + marchandises 1 200 kg = 1 342 kg.

d. Comparaison et surcharge : charge réelle 1 342 kg contre CU 1 300 kg, soit un dépassement d'environ 42 kg (de l'ordre de 3 %). Il y a donc surcharge : il faut retirer environ 42 kg de marchandises (ou ne charger que 1 158 kg de fret) pour rester dans le PTAC. Remarque pédagogique : si le poids à vide fourni correspond à la masse en ordre de marche incluant déjà conducteur et carburant, seule la marchandise (1 200 kg) serait à comparer aux 1 300 kg et il n'y aurait pas de surcharge ; l'énoncé demandant d'additionner conducteur, carburant et marchandises, on conclut à une légère surcharge d'environ 42 kg.$corr$,
  scoring_grid    = $corr$a. 2 pts : calcul correct de la charge utile CU = 3 500 - 2 200 = 1 300 kg. / b. 1,5 pt : conversion du gasoil en masse (80 L x ~0,84 = ~67 kg). / c. 1 pt : addition de la charge réelle (75 + 67 + 1 200 = 1 342 kg). / d. 0,5 pt : conclusion surcharge d'environ 42 kg et action corrective. Total 5.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleF:qr4' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

UPDATE public.question_bank SET
  expected_answer = $corr$Cinq leviers chiffrés (ordres de grandeur usuels, à valider par le suivi télématique de la flotte) :

a. Éco-conduite (formation + suivi des conducteurs) : anticipation, régime moteur bas, arrêt du ralenti inutile. Gain typique de 10 à 15 % de carburant, durable si la conduite est suivie par télématique.

b. Entretien et pression des pneumatiques : pneus bien gonflés (contrôle mensuel), filtres et huile à jour, choix de pneus à faible résistance au roulement. Gain de 3 à 5 %.

c. Bridage de la vitesse / usage du régulateur : abaisser et lisser la vitesse (par exemple 110 au lieu de 130 sur autoroute, régulateur en charge stable). Gain de 5 à 10 % sur les trajets rapides.

d. Optimisation des tournées et du taux de chargement : logiciel d'optimisation d'itinéraires, regroupement des livraisons, réduction des kilomètres à vide. Gain de 10 à 20 % sur les kilomètres parcourus, donc autant de carburant.

e. Allègement et aérodynamique : suppression des galeries et charges mortes inutiles, chargement optimisé, absence de surcharge. Gain de 2 à 5 %.

Levier transverse : équiper les 5 VUL de télématique embarquée pour mesurer, comparer les conducteurs et pérenniser les gains ; envisager le renouvellement progressif vers des motorisations plus sobres. Cumulés, ces leviers peuvent représenter 15 à 25 % d'économie de carburant sur la flotte.$corr$,
  scoring_grid    = $corr$5 pts : un point par levier pertinent et distinct (éco-conduite, entretien/pneus, vitesse/régulateur, optimisation des tournées, allègement/aérodynamique). / 1 pt : chiffrage crédible associé à chaque levier (ordres de grandeur cohérents) et/ou levier de suivi télématique. Total 6.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleF:qr5' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleF:qr6] : [À CONFIRMER: calendrier exact de la ZFE de Paris / Métropole du Grand Paris et l'échéance d'exclusion des Crit'Air 2 (l'énoncé retient 2027, mais ce calendrier a été plusieurs fois reporté/assoupli et le contrôle sanction n'est pas nécessairement effectif à cette date). Vérifier la date en vigueur et le régime des dérogations et laissez-passer avant diffusion.]
UPDATE public.question_bank SET
  expected_answer = $corr$a. Diagnostic et anticipation : recenser précisément les 5 VUL Euro 5 / Crit'Air 2 et cartographier la part de chiffre d'affaires réalisée dans le périmètre parisien. La ZFE exclut la vignette Crit'Air 2 : sans action, ces véhicules perdent l'accès à Paris. Construire un rétroplanning aligné sur l'échéance annoncée (2027) avec des jalons d'investissement.

b. Renouvellement de la flotte vers des véhicules éligibles : remplacer progressivement par des VUL Crit'Air 1 (motorisations récentes essence/gaz) ou, mieux et plus pérenne, Crit'Air 0 / électriques (voire hydrogène). Le rétrofit électrique d'un VUL existant est une option à étudier. Mobiliser les aides : bonus écologique, prime à la conversion, aides locales/régionales et métropolitaines, dispositifs de suramortissement, et arbitrer achat / LLD / LOA via un calcul de coût total de possession (TCO).

c. Solutions organisationnelles complémentaires : recourir aux dérogations et laissez-passer journaliers (en nombre limité) pour la transition ; mettre en place un hub logistique en périphérie avec derniers kilomètres assurés en véhicules propres ou vélos-cargo ; sous-traiter ponctuellement la partie parisienne à un transporteur déjà équipé en véhicules éligibles.

d. Pilotage financier : étaler l'investissement sur 2 à 3 exercices, prioriser les véhicules les plus exposés au périmètre parisien, et sécuriser le plan par un calcul de TCO intégrant aides, énergie et maintenance.$corr$,
  scoring_grid    = $corr$a. 1 pt : diagnostic de l'exposition et anticipation du calendrier ZFE. / b. 2 pts : renouvellement vers Crit'Air 1/0 ou électrique/rétrofit + mobilisation des aides et TCO. / c. 1,5 pt : solutions organisationnelles (hub périphérie, sous-traitance, dérogations/laissez-passer). / d. 0,5 pt : étalement et priorisation des investissements. Total 5.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleF:qr6' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

-- ⚠️ À CONFIRMER [mft-2026:moduleF:qr7] : [À CONFIRMER: montants exacts des sanctions en cas de conduite sans FCO/CQC valide (classe de contravention pour le conducteur et amende encourue par l'employeur/personne morale) sur le barème en vigueur 2026.]
UPDATE public.question_bank SET
  expected_answer = $corr$Rappel préalable indispensable : la CQC (matérialisant la FIMO/FCO) n'est exigée que pour conduire un véhicule de transport de marchandises de plus de 3,5 t. Si les livraisons GMS sont réalisées avec un VUL inférieur ou égal à 3,5 t, la CQC n'est pas requise et le problème disparaît. Le corrigé ci-dessous répond dans l'hypothèse où le conducteur doit conduire un véhicule de plus de 3,5 t (donc soumis à CQC).

a. Aujourd'hui et demain : OUI, il peut rouler. La CQC expire dans 5 jours, elle est donc encore valide aujourd'hui et demain. Tant que la date de fin de validité n'est pas atteinte, le conducteur est en règle et l'employeur aussi. On peut donc assurer les deux premières journées sans irrégularité.

b. Le 6e jour avec une CQC périmée (véhicule de plus de 3,5 t) : la conduite devient illégale (défaut de qualification / FCO non valide). Sanctions pour le conducteur : contravention et risque d'immobilisation du véhicule. Sanctions pour l'employeur / l'entreprise : le fait de laisser conduire un salarié sans qualification valide expose la personne morale et le dirigeant à une amende nettement plus élevée que celle du conducteur, à sa responsabilité en cas de contrôle ou d'accident, et à un risque sur la couverture assurance. En léger (inférieur ou égal à 3,5 t), aucune de ces sanctions ne s'applique puisque la CQC n'est pas requise.

c. Trois solutions opérationnelles immédiates pour ne pas pénaliser le client GMS : 1) affecter les deux livraisons à un autre conducteur de l'entreprise déjà à jour de sa FCO/CQC ; 2) recourir à un conducteur en intérim ou en CDD qualifié, ou sous-traiter les deux tournées critiques à un transporteur partenaire ; 3) rechercher une place de FCO en urgence dans un autre centre de formation (ou, si le véhicule peut être un VUL inférieur ou égal à 3,5 t, réaliser ces livraisons avec un tel véhicule ne nécessitant pas la CQC).

d. Organisation RH pérenne : mettre en place un tableau de suivi des échéances individuelles (permis, FCO/CQC, visites médicales, ADR) avec alertes automatiques 4 à 6 mois avant expiration ; inscrire les conducteurs en FCO très en amont (ne jamais attendre le dernier mois) ; maintenir une polyvalence en gardant plusieurs conducteurs à jour pour couvrir les absences ; conventionner avec un ou plusieurs organismes de formation pour sécuriser les places.$corr$,
  scoring_grid    = $corr$a. 2 pts : réponse OUI justifiée (CQC encore valide car expire dans 5 jours). / b. 2 pts : illégalité au 6e jour + sanctions distinctes conducteur (contravention/immobilisation) et employeur (amende plus lourde, responsabilité), avec le rappel du seuil 3,5 t. / c. 1 pt : trois solutions opérationnelles distinctes et réalistes. / d. 1 pt : dispositif RH de suivi des échéances + anticipation des inscriptions FCO. Total 6.$corr$,
  active = false
WHERE source_ref = 'mft-2026:moduleF:qr7' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'capacite-3-5t');

COMMIT;

-- CONTRÔLE : doit renvoyer 55 (toutes les QR ont désormais un corrigé).
-- SELECT count(*) FROM public.question_bank qb
--   JOIN public.formations f ON f.id=qb.formation_id
--  WHERE f.slug='capacite-3-5t' AND qb.type='qr'
--    AND qb.expected_answer IS NOT NULL AND qb.scoring_grid IS NOT NULL;