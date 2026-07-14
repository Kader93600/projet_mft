-- =====================================================================
-- CORRIGÉS QR — GOTRM (RNCP 40990, CCP1) — 14/07/2026
--
-- Ajoute réponse-modèle (expected_answer) + barème (scoring_grid) aux 68
-- QR qui étaient actives SANS corrigé (donc inexploitables : impossible de
-- corriger une copie). Généré par orchestration (agent formateur + passe de
-- vérification factuelle : 561/2006, capacité financière, poids/dimensions,
-- art. L.133-3), puis assemblé et QA-vérifié (couverture 68/68).
--
-- active = false : les questions repassent EN ATTENTE DE VALIDATION. Après
-- relecture, réactive-les via la bascule en masse de la banque de questions.
-- Les lignes « ⚠️ À CONFIRMER » portent une donnée à vérifier avant activation.
--
-- Idempotent (UPDATE par source_ref + formation + type). À appliquer par l'admin.
-- =====================================================================

BEGIN;

-- ⚠️ À CONFIRMER [import:d33c7a85-0a81-4708-b38e-e06f8f02ec90#Ch01_Exercice_1.1.pdf:mp5pgrox:q1] : [À CONFIRMER: l'énoncé est ambigu — le transport est « facturé à MECA-CONCEPT », entité absente du contexte et du tableau des acteurs. Deux lectures : (a) tiers payeur désigné (lecture retenue), (b) coquille pour MD France. Dans les deux cas la conclusion « port payé » tient, mais l'énoncé mériterait d'être clarifié par le concepteur.] [À CONFIRMER: intitulé et seuil exacts du titre d'exploitation exigible (licence communautaire > 3,5 t / licence de transport intérieur ≤ 3,5 t) au regard de la rédaction du Code des transports en vigueur en 2026.] Barème vérifié : 3 + 2 + 1 = 6 = max_score. Aucun chiffre du bloc réglementaire (561/2006, capacité financière, poids/dimensions) n'est mobilisé par cet exercice ; seule la règle des 3 jours de l'art. L.133-3 est citée, conformément à l'ancrage haute confiance.
UPDATE public.question_bank SET
  expected_answer = $corr$1. Rôle de chacun des acteurs

- MD France (Clermont-Fd) : expéditeur / donneur d'ordre (remettant). Elle passe commande du transport auprès de TRANSGO et remet les 18 palettes EUR au départ ; elle est partie au contrat de transport.
- RENAULT (Montpellier) : destinataire. Client de MD France, il prend livraison, vérifie l'état des palettes et formule, le cas échéant, les réserves (réserves motivées à la livraison ; pour une avarie non apparente, protestation motivée par écrit dans les 3 jours, hors dimanches et jours fériés — art. L.133-3 du Code de commerce).
- TRANSGO : transporteur contractuel agissant en organisateur (commissionnaire de transport / donneur d'ordre de la sous-traitance). N'ayant pas de véhicule disponible, elle confie l'exécution à un tiers mais reste responsable de la bonne fin de l'opération vis-à-vis de MD France (responsabilité du fait de son substitué).
- ZALTO : transporteur effectif (voiturier), sous-traitant référencé de TRANSGO. Il réalise matériellement le déplacement avec son véhicule et son conducteur.

À ajouter hors tableau : MECA-CONCEPT = payeur du transport (tiers payeur désigné au contrat) ; le prix du transport lui est facturé, sans qu'il soit expéditeur physique ni destinataire.

2. Port payé ou port dû ?

Rappel : le port est « payé » lorsque le prix du transport est réglé à l'amont (expéditeur / donneur d'ordre ou payeur désigné au départ) ; il est « dû » lorsqu'il est réglé par le destinataire à l'arrivée.
Ici, le transport n'est pas facturé au destinataire RENAULT, mais à MECA-CONCEPT, côté donneur d'ordre. L'opération est donc réalisée en PORT PAYÉ : RENAULT prend livraison sans avoir à régler le prix du transport.

3. Document à présenter par ZALTO avant toute affectation

La copie conforme de la licence de transport : licence communautaire pour les véhicules de plus de 3,5 t (transport intérieur et international), licence de transport intérieur pour les véhicules n'excédant pas 3,5 t. Elle atteste de l'inscription au registre national des transporteurs et du respect des quatre conditions d'accès à la profession (établissement, honorabilité professionnelle, capacité financière, capacité professionnelle).
En pratique, le dossier de référencement du sous-traitant comprend aussi : le contrat de sous-traitance écrit, l'attestation d'assurance « marchandises transportées », l'attestation de vigilance URSSAF (art. L.8222-1 du Code du travail), l'extrait Kbis.$corr$,
  scoring_grid    = $corr$Total : 6 points (= max_score)

Q1 – Rôles des acteurs : 3 points (0,75 pt par acteur du tableau)
- MD France = expéditeur / donneur d'ordre : 0,75
- RENAULT = destinataire : 0,75
- TRANSGO = transporteur contractuel / commissionnaire (donneur d'ordre de la sous-traitance) : 0,75
- ZALTO = transporteur effectif (voiturier) sous-traitant : 0,75
(l'identification de MECA-CONCEPT comme payeur / tiers payeur ne donne pas de point supplémentaire mais est attendue pour justifier Q2)

Q2 – Port payé / port dû : 2 points
- Réponse « port payé » : 1 pt
- Justification exacte (le prix n'est pas mis à la charge du destinataire à l'arrivée : il est facturé côté donneur d'ordre / au payeur désigné) : 1 pt
- 0 pt à la justification si l'apprenant se borne à recopier l'énoncé

Q3 – Document exigé de ZALTO : 1 point
- Copie conforme de la licence de transport (licence communautaire ou licence de transport intérieur) : 1 pt
- Tolérance : 0,5 pt si seule l'attestation de vigilance URSSAF ou l'attestation d'assurance est citée, sans la licence

Somme : 3 + 2 + 1 = 6 points ✔$corr$,
  active = false
WHERE source_ref = 'import:d33c7a85-0a81-4708-b38e-e06f8f02ec90#Ch01_Exercice_1.1.pdf:mp5pgrox:q1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [import:fe74f583-5eef-461c-8c13-8dfe00dea7e4#Ch01_Exercice_1.2.pdf:mp7fi23j:q1] : [À CONFIRMER: dénomination et référence exactes du contrat type applicable aux transports sous température dirigée en vigueur en 2026 (contrats types codifiés en annexe du Code des transports et refondus ces dernières années).] [À CONFIRMER: seuil de tonnage (usuellement 3 tonnes) délimitant le champ du contrat type « messagerie » dans sa rédaction en vigueur — non cité dans le corrigé par prudence.] Barème vérifié : 5 × 0,40 = 2,00 = max_score (2). Les cinq lignes du tableau sont traitées ; les seules références chiffrées de la réglementation sociale (561/2006, 165/2014) sont mentionnées sans valeur numérique inventée.
UPDATE public.question_bank SET
  expected_answer = $corr$Tableau complété (type de transport / réglementation principale applicable)

1) 18 palettes de Clermont-Fd → Montpellier, véhicule complet
- Type : transport routier de marchandises intérieur (national), en lot complet / charge complète (un expéditeur, un destinataire, pas de rupture de charge).
- Réglementation : droit interne du contrat de transport — Code de commerce (art. L.133-1 et suivants) et Code des transports ; à défaut de convention écrite, le contrat type « général » applicable aux transports publics routiers de marchandises pour lesquels il n'existe pas de contrat type spécifique. S'y ajoutent, pour le conducteur, le règlement CE 561/2006 (temps de conduite et de repos) et le règlement UE 165/2014 (tachygraphe).

2) 5 colis de Paris → Toulouse, livraison J+1 via plateforme de tri
- Type : transport de messagerie (envoi de détail, groupage, passage sur plateforme de tri, rupture de charge) ; messagerie express compte tenu du délai J+1.
- Réglementation : contrat type « messagerie », dans le cadre du Code de commerce et du Code des transports ; règlement CE 561/2006 et règlement UE 165/2014 pour le conducteur.

3) 8 palettes de Lyon → Barcelone (Espagne)
- Type : transport routier international de marchandises (intracommunautaire), en lot partiel ou groupage.
- Réglementation : Convention CMR du 19 mai 1956, applicable de plein droit dès lors que la prise en charge et la livraison se situent dans deux pays différents dont l'un au moins est partie à la Convention. Licence communautaire obligatoire ; règlements CE 561/2006 et UE 165/2014 ; règles de détachement issues du paquet mobilité.

4) Produits laitiers à +4 °C, Paris → Bordeaux
- Type : transport national sous température dirigée (frigorifique) de denrées périssables.
- Réglementation : accord ATP (engins et équipements attestés ATP) et sa déclinaison en droit interne ; paquet hygiène (règlements CE 178/2002 et 852/2004) : maîtrise de la chaîne du froid, traçabilité, relevés de température ; contrat type applicable aux transports sous température dirigée.

5) Produits chimiques corrosifs, camion homologué, Strasbourg → Hambourg
- Type : transport international de marchandises dangereuses (classe 8, matières corrosives).
- Réglementation : accord ADR, complété en France par l'arrêté « TMD ». Obligations : véhicule et emballages/citernes agréés, plaques-étiquettes et panneaux orange, document de transport ADR, consignes écrites, conducteur titulaire du certificat de formation ADR, conseiller à la sécurité désigné. La Convention CMR régit par ailleurs le contrat de transport international.$corr$,
  scoring_grid    = $corr$Total : 2 points (= max_score), soit 0,40 pt par ligne du tableau (5 lignes)

Pour chaque ligne : 0,20 pt pour le type de transport, 0,20 pt pour la réglementation principale.

- Ligne 1 (Clermont-Fd → Montpellier, véhicule complet) : lot complet / transport national = 0,20 ; contrat type général + Code de commerce / Code des transports (règl. CE 561/2006 accepté) = 0,20
- Ligne 2 (Paris → Toulouse, J+1) : messagerie / messagerie express = 0,20 ; contrat type messagerie = 0,20
- Ligne 3 (Lyon → Barcelone) : transport international intracommunautaire = 0,20 ; Convention CMR (licence communautaire acceptée en complément) = 0,20
- Ligne 4 (produits laitiers +4 °C) : transport sous température dirigée / frigorifique = 0,20 ; accord ATP et/ou paquet hygiène (chaîne du froid) = 0,20
- Ligne 5 (produits corrosifs, Strasbourg → Hambourg) : marchandises dangereuses (classe 8) = 0,20 ; accord ADR = 0,20

Une réponse exacte mais laconique (« CMR », « ADR », « ATP ») est créditée de la totalité du point de réglementation. Aucune pénalité pour un complément juste non demandé.

Somme : 5 × 0,40 = 2,00 points ✔$corr$,
  active = false
WHERE source_ref = 'import:fe74f583-5eef-461c-8c13-8dfe00dea7e4#Ch01_Exercice_1.2.pdf:mp7fi23j:q1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch01:ex1.1] : [À CONFIRMER: MECA-CONCEPT n'est ni défini dans le contexte ni listé dans le tableau des acteurs : soit tiers payeur désigné, soit coquille pour MD France. La conclusion « port payé » est valable dans les deux hypothèses, mais l'énoncé gagnerait à être clarifié.] [À CONFIRMER: intitulé et seuil exacts du titre d'exploitation exigible (licence communautaire > 3,5 t / licence de transport intérieur ≤ 3,5 t) selon la rédaction du Code des transports en vigueur en 2026.] Barème vérifié : 3 + 2 + 1 = 6 = max_score. Les seuls chiffres réglementaires cités (capacité financière 9 000/5 000 et 1 800/900 €, délai de 3 jours de l'art. L.133-3) proviennent des ancrages haute confiance.
UPDATE public.question_bank SET
  expected_answer = $corr$1. Rôle de chacun des acteurs

- MD France (Clermont-Fd) : expéditeur / donneur d'ordre (remettant). Elle passe commande du transport et remet les 18 palettes EUR au départ ; elle est partie au contrat de transport.
- RENAULT (Montpellier) : destinataire. Client de MD France, il prend livraison, vérifie l'état des palettes et formule, s'il y a lieu, les réserves sur la lettre de voiture (pour une avarie non apparente : protestation motivée écrite dans les 3 jours, hors dimanches et jours fériés — art. L.133-3 du Code de commerce, à peine de forclusion).
- TRANSGO : transporteur contractuel agissant en organisateur (commissionnaire de transport / donneur d'ordre de la sous-traitance). N'ayant pas de véhicule disponible, elle confie l'exécution à un tiers mais demeure responsable de la bonne fin de l'opération vis-à-vis de MD France (responsabilité du fait de son substitué).
- ZALTO : transporteur effectif (voiturier), sous-traitant référencé de TRANSGO. Il réalise matériellement le déplacement avec son véhicule et son conducteur.

À ajouter hors tableau : MECA-CONCEPT = payeur du transport (tiers payeur désigné au contrat) ; le prix du transport lui est facturé.

2. Port payé ou port dû ?

Rappel : port payé = le prix du transport est réglé à l'amont, par l'expéditeur / le donneur d'ordre (ou le payeur désigné au départ) ; port dû = le prix est réglé par le destinataire à l'arrivée.
Le transport n'étant pas facturé au destinataire RENAULT mais à MECA-CONCEPT, côté donneur d'ordre, l'opération est réalisée en PORT PAYÉ. RENAULT prend livraison sans avoir à régler le prix du transport.

3. Document à présenter par ZALTO avant toute affectation

La copie conforme de la licence de transport : licence communautaire pour les véhicules de plus de 3,5 t, licence de transport intérieur pour les véhicules n'excédant pas 3,5 t. Elle atteste de l'inscription au registre national des transporteurs et du respect des quatre conditions d'accès à la profession (établissement, honorabilité, capacité financière, capacité professionnelle).
Rappel utile (capacité financière) : pour le transport lourd (> 3,5 t), 9 000 € pour le premier véhicule puis 5 000 € par véhicule supplémentaire ; pour le transport léger (2,5 à 3,5 t), 1 800 € pour le premier véhicule puis 900 € par véhicule supplémentaire.
Le dossier de référencement d'un sous-traitant comporte par ailleurs : contrat de sous-traitance écrit, attestation d'assurance marchandises transportées, attestation de vigilance URSSAF (art. L.8222-1 du Code du travail), extrait Kbis.$corr$,
  scoring_grid    = $corr$Total : 6 points (= max_score)

Q1 – Rôles des acteurs : 3 points (0,75 pt par acteur du tableau)
- MD France = expéditeur / donneur d'ordre : 0,75
- RENAULT = destinataire : 0,75
- TRANSGO = transporteur contractuel / commissionnaire (donneur d'ordre de la sous-traitance) : 0,75
- ZALTO = transporteur effectif (voiturier) sous-traitant : 0,75
(identification de MECA-CONCEPT comme payeur : pas de point dédié, mais attendue pour justifier Q2)

Q2 – Port payé / port dû : 2 points
- Réponse « port payé » : 1 pt
- Justification exacte (le prix n'est pas mis à la charge du destinataire à l'arrivée, il est facturé côté donneur d'ordre) : 1 pt

Q3 – Document exigé de ZALTO : 1 point
- Copie conforme de la licence de transport (licence communautaire / licence de transport intérieur) : 1 pt
- Tolérance : 0,5 pt si seule l'attestation de vigilance URSSAF ou l'attestation d'assurance est citée

Somme : 3 + 2 + 1 = 6 points ✔$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch01:ex1.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch01:ex1.2] : [À CONFIRMER: intitulé et référence exacts du contrat type applicable aux transports sous température dirigée en vigueur en 2026 (contrats types codifiés en annexe du Code des transports, refondus ces dernières années).] [À CONFIRMER: seuil de tonnage (usuellement 3 tonnes) délimitant le champ du contrat type « messagerie » — volontairement non chiffré dans le corrigé.] Barème vérifié : 5 × 1,20 = 6,00 = max_score (6). Les cinq lignes du tableau sont traitées. Les valeurs du règlement CE 561/2006 citées en ligne 1 (4 h 30 / 45 min fractionnables 15 + 30 / 9 h portées à 10 h deux fois par semaine) correspondent aux ancrages haute confiance.
UPDATE public.question_bank SET
  expected_answer = $corr$Tableau complété (type de transport / réglementation principale applicable)

1) 18 palettes de Clermont-Fd → Montpellier, véhicule complet
- Type : transport routier de marchandises intérieur (national) en lot complet (un expéditeur, un destinataire, pas de rupture de charge).
- Réglementation : droit interne du contrat de transport — Code de commerce (art. L.133-1 et suivants) et Code des transports ; à défaut de convention écrite, contrat type « général » applicable aux transports publics routiers de marchandises pour lesquels il n'existe pas de contrat type spécifique. Réglementation sociale européenne : règlement CE 561/2006 (conduite continue 4 h 30 puis pause de 45 min, fractionnable en 15 + 30 ; conduite journalière 9 h, portée à 10 h deux fois par semaine) et règlement UE 165/2014 (tachygraphe).

2) 5 colis de Paris → Toulouse, livraison J+1 via plateforme de tri
- Type : transport de messagerie (envoi de détail, groupage, passage sur plateforme de tri, rupture de charge) ; messagerie express au vu du délai J+1.
- Réglementation : contrat type « messagerie », dans le cadre du Code de commerce et du Code des transports ; règlements CE 561/2006 et UE 165/2014 pour le conducteur.

3) 8 palettes de Lyon → Barcelone (Espagne)
- Type : transport routier international de marchandises (intracommunautaire), lot partiel ou groupage.
- Réglementation : Convention CMR du 19 mai 1956, applicable de plein droit dès lors que la prise en charge et la livraison se situent dans deux pays différents dont l'un au moins est partie à la Convention. Licence communautaire obligatoire ; règlements CE 561/2006 et UE 165/2014 ; règles de détachement issues du paquet mobilité.

4) Produits laitiers à +4 °C, Paris → Bordeaux
- Type : transport national sous température dirigée (frigorifique), denrées périssables.
- Réglementation : accord ATP (engins et équipements attestés ATP) et sa déclinaison en droit interne ; paquet hygiène (règlements CE 178/2002 et 852/2004) : maîtrise de la chaîne du froid, traçabilité, relevés de température ; contrat type applicable aux transports sous température dirigée.

5) Produits chimiques corrosifs, camion homologué, Strasbourg → Hambourg
- Type : transport international de marchandises dangereuses (classe 8, matières corrosives).
- Réglementation : accord ADR, complété en France par l'arrêté « TMD ». Obligations : véhicule et emballages/citernes agréés, plaques-étiquettes et panneaux orange, document de transport ADR, consignes écrites, conducteur titulaire du certificat de formation ADR, conseiller à la sécurité désigné. La Convention CMR régit par ailleurs le contrat de transport international.$corr$,
  scoring_grid    = $corr$Total : 6 points (= max_score), soit 1,20 pt par ligne du tableau (5 lignes)

Pour chaque ligne : 0,60 pt pour le type de transport, 0,60 pt pour la réglementation principale.

- Ligne 1 (Clermont-Fd → Montpellier, véhicule complet) : lot complet / transport national = 0,60 ; contrat type général + Code de commerce / Code des transports (règl. CE 561/2006 accepté en complément) = 0,60
- Ligne 2 (Paris → Toulouse, J+1) : messagerie / messagerie express = 0,60 ; contrat type messagerie = 0,60
- Ligne 3 (Lyon → Barcelone) : transport international intracommunautaire = 0,60 ; Convention CMR (licence communautaire acceptée en complément) = 0,60
- Ligne 4 (produits laitiers +4 °C) : transport sous température dirigée / frigorifique = 0,60 ; accord ATP et/ou paquet hygiène (chaîne du froid) = 0,60
- Ligne 5 (produits corrosifs, Strasbourg → Hambourg) : transport de marchandises dangereuses (classe 8) = 0,60 ; accord ADR = 0,60

Une réponse exacte mais laconique (« CMR », « ADR », « ATP ») est créditée de la totalité du point de réglementation. Aucune pénalité pour un complément juste et non demandé.

Somme : 5 × 1,20 = 6,00 points ✔$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch01:ex1.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ 1.3 : les 3 phases du transport et les priorités du gestionnaire

RAPPEL DE MÉTHODE
Le gestionnaire de transport intervient sur trois phases : AVANT (préparation, prise de commande, tarification, affectation véhicule/conducteur, ordre de mission), PENDANT (suivi, gestion des aléas, relation client en temps réel), APRÈS (retour et contrôle des documents, facturation, analyse des indicateurs).

TABLEAU DE RÉPONSE

1. Panne sur l'A71 (mission en cours)
Phase : PENDANT le transport.
Action prioritaire : sécuriser d'abord (conducteur en sécurité derrière la glissière, gilet, triangle, véhicule signalé), puis déclencher l'assistance ou le dépannage. Ensuite seulement, évaluer l'impact sur la livraison, informer le client du retard et organiser la solution de substitution (transbordement, véhicule de remplacement, réaffectation de la tournée). Penser également à l'impact sur le temps de service du conducteur (RSE 561/2006) : l'immobilisation peut compromettre la fin de la mission dans la journée de conduite.
Justification : c'est la seule situation qui engage la sécurité des personnes et la continuité d'une prestation déjà vendue. Elle passe avant tout le reste.

2. Demande de tarif pour 22 palettes Clermont-Ferrand vers Paris
Phase : AVANT le transport (phase commerciale et de préparation).
Action prioritaire : qualifier la demande avant de chiffrer (poids réel, dimensions et gerbabilité des palettes, mètres linéaires occupés, nature de la marchandise, date et créneaux d'enlèvement et de livraison, hayon ou quai, valeur pour l'assurance). Puis vérifier la faisabilité (véhicule disponible, capacité en charge utile et en mètres linéaires) et construire le prix à partir du coût de revient prévisionnel (charges fixes + charges variables + charges de structure) majoré de la marge, avant d'envoyer l'offre écrite.
Justification : un tarif annoncé sans qualification expose l'entreprise à vendre à perte ou à s'engager sur un transport irréalisable.

3. Taux de kilomètres à vide de la semaine
Phase : APRÈS le transport (exploitation, contrôle de gestion, analyse de performance).
Action prioritaire : extraire les données d'exploitation de la semaine (kilomètres totaux et kilomètres en charge par véhicule), calculer le taux avec la formule : taux de km à vide = (km à vide / km totaux) x 100, puis transmettre à la direction avec un commentaire d'analyse et des pistes d'amélioration (recherche de fret retour, réorganisation des tournées).
Justification : c'est un indicateur de pilotage, important mais non urgent. Il est traité après les urgences opérationnelles.

4. Ordre de mission incompris par un conducteur
Phase : AVANT le transport (l'ordre de mission a été remis mais la mission n'est pas encore exécutée).
Action prioritaire : reprendre l'ordre de mission point par point avec le conducteur (lieux, horaires, nature et quantité de la marchandise, consignes de chargement, documents à faire signer), lever l'ambiguïté et rediffuser un ordre de mission corrigé et écrit, daté et tracé.
Justification : un ordre de mission mal compris est bloquant pour le départ et générateur d'erreurs (mauvais site, mauvaise marchandise, litige). Il doit être traité avant les tâches purement analytiques.

ORDRE DE TRAITEMENT RECOMMANDÉ DANS LA MATINÉE
1) la panne (sécurité et transport en cours), 2) l'ordre de mission incompris (bloquant pour un départ), 3) la demande de tarif (enjeu commercial, à traiter dans la journée), 4) le taux de km à vide (indicateur, non urgent).$corr$,
  scoring_grid    = $corr$Total 6 points.
- Situation 1 (panne A71) : phase « pendant » 0,5 pt ; action prioritaire (sécuriser puis dépanner, puis informer le client et proposer une solution de substitution) 1 pt. Sous-total 1,5 pt.
- Situation 2 (demande de tarif) : phase « avant » 0,5 pt ; action prioritaire (qualifier la demande, vérifier la faisabilité, chiffrer à partir du coût de revient et envoyer une offre écrite) 1 pt. Sous-total 1,5 pt.
- Situation 3 (taux de km à vide) : phase « après » 0,5 pt ; action prioritaire (extraire les données, calculer km à vide / km totaux x 100, transmettre avec analyse) 1 pt. Sous-total 1,5 pt.
- Situation 4 (ordre de mission incompris) : phase « avant » 0,5 pt ; action prioritaire (reprendre l'OM avec le conducteur, clarifier et rediffuser un OM écrit corrigé) 1 pt. Sous-total 1,5 pt.
Total des sous-totaux : 4 x 1,5 = 6 pts.
Bonus de cohérence : si le candidat hiérarchise correctement les 4 situations entre elles (sécurité d'abord), valoriser dans la partie « action » sans dépasser le total. Retirer 0,5 pt sur l'action si la réponse reste générique et sans priorisation.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch01:ex1.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ 1.4 : classement des missions dans les 3 phases du transport

AVANT LE TRANSPORT (préparation et organisation)
- Préparer la tournée : analyser la commande, définir l'ordre des points d'enlèvement et de livraison, calculer les distances et les temps, vérifier la compatibilité avec la réglementation sociale européenne (règlement CE 561/2006 : conduite continue de 4 h 30 maximum suivie d'une pause de 45 min, conduite journalière de 9 h, portée à 10 h deux fois par semaine au maximum), éditer l'ordre de mission et les documents de transport (lettre de voiture).
- Choisir le véhicule : vérifier l'adéquation entre la marchandise et le véhicule (charge utile suffisante, mètres linéaires, type de carrosserie, hayon, température dirigée si nécessaire), la disponibilité du véhicule et sa validité (contrôle technique, entretien).

PENDANT LE TRANSPORT (exécution et suivi)
- Suivre le conducteur pendant la livraison : suivre la position et l'avancement (télématique embarquée, contacts), s'assurer du respect des horaires et des consignes, gérer les aléas (retard, encombrement, refus de marchandise, avarie, panne), informer le client en temps réel.

APRÈS LE TRANSPORT (clôture, contrôle et valorisation)
- Vérifier les documents au retour : récupérer et contrôler la lettre de voiture ou le récépissé signé, les bons de livraison émargés, relever les éventuelles réserves du destinataire, les anomalies, les temps d'attente et les frais annexes. Point de vigilance : en cas d'avarie non apparente, le destinataire dispose de 3 jours, non compris les dimanches et jours fériés, pour adresser une protestation motivée écrite (art. L.133-3 du Code de commerce), à défaut de quoi son action est éteinte (forclusion).
- Préparer la facturation : rapprocher la prestation réalisée de la commande et du tarif convenu, intégrer les prestations annexes (attente, hayon, retour à vide) et transmettre les éléments au service facturation.

SYNTHÈSE
| Phase | Missions |
| Avant le transport | Préparer la tournée ; choisir le véhicule |
| Pendant le transport | Suivre le conducteur pendant la livraison |
| Après le transport | Vérifier les documents au retour ; préparer la facturation |

À RETENIR : la qualité de la phase « avant » conditionne la fluidité de la phase « pendant », et la rigueur documentaire de la phase « après » conditionne la facturation, la preuve en cas de litige et l'analyse de la rentabilité.$corr$,
  scoring_grid    = $corr$Total 6 points.
- « Préparer la tournée » classé en AVANT : 1 pt.
- « Choisir le véhicule » classé en AVANT : 1 pt.
- « Suivre le conducteur pendant la livraison » classé en PENDANT : 1 pt.
- « Vérifier les documents au retour » classé en APRÈS : 1 pt.
- « Préparer la facturation » classé en APRÈS : 1 pt.
- Justification et enrichissement (le candidat explicite au moins une action concrète attachée à chaque phase, par exemple contrôle de la charge utile, respect des temps de conduite, gestion des aléas, relevé des réserves) : 1 pt.
Total : 5 + 1 = 6 pts.
Aucun point n'est accordé pour une mission mal classée ; pas de demi-point sur les 5 premiers items.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch01:ex1.4' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.1] : Lecture du tableau dégradé de l'énoncé CONFIRMÉE par relecture en base : TR12+SR27 PTRA 44 000 / PTAC tracteur 35 000 / PV 8 200 / PV semi 6 800 ; TR18+SR31 PTRA 40 000 / PTAC tracteur 38 000 / PV 7 400 / PV semi 7 200 ; PORT-11 PTAC 26 000 / PV 8 150 ; PORT-12 PTAC 19 000 / PV 7 500. Tous les calculs recontrôlés (29 000 / 25 400 / 17 850 / 11 500 kg) et barème = 6 = max_score. Point résiduel : [À CONFIRMER: la classe ATP exigée pour les surgelés à −18 °C n'est volontairement pas chiffrée dans le corrigé (formulation « engin frigorifique renforcé permettant de maintenir −18 °C ou moins »). Si le concepteur souhaite exiger la mention d'une classe ATP précise, la faire valider avant publication.] Recommandation éditoriale : reformater le tableau du parc dans l'énoncé (colonnes fusionnées) pour lever toute ambiguïté PTAC/PTRA côté stagiaire.
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ 2.1 : charge utile du parc TRANSGO

LECTURE DES DONNÉES DE L'ÉNONCÉ
| Véhicule | Type | PTRA | PTAC | PV tracteur/porteur | PV semi | Carrosserie |
| TR12 + SR27 | Ensemble articulé | 44 000 kg | 35 000 kg | 8 200 kg | 6 800 kg | Fourgon |
| TR18 + SR31 | Ensemble articulé | 40 000 kg | 38 000 kg | 7 400 kg | 7 200 kg | Plateau |
| PORT-11 | Porteur solo | — | 26 000 kg | 8 150 kg | — | PLSC |
| PORT-12 | Porteur solo | — | 19 000 kg | 7 500 kg | — | Frigorifique |
Attention : pour un ensemble articulé, la colonne PTAC (35 000 / 38 000 kg) est celle du TRACTEUR seul. Elle ne sert PAS au calcul de la charge utile de l'ensemble : c'est un piège classique.

RAPPEL DES FORMULES
- Ensemble articulé (tracteur + semi-remorque) : CU = PTRA − (PV tracteur + PV semi-remorque).
- Porteur solo : CU = PTAC − PV.
Le PTRA (poids total roulant autorisé) est le poids maximal autorisé de l'ensemble en charge.

1) CALCUL DE LA CHARGE UTILE DES 4 VÉHICULES

a) TR12 + SR27, ensemble articulé, fourgon
PV total = 8 200 + 6 800 = 15 000 kg
CU = 44 000 − 15 000 = 29 000 kg, soit 29 t.

b) TR18 + SR31, ensemble articulé, plateau
PV total = 7 400 + 7 200 = 14 600 kg
CU = 40 000 − 14 600 = 25 400 kg, soit 25,4 t.

c) PORT-11, porteur solo, PLSC
CU = 26 000 − 8 150 = 17 850 kg, soit 17,85 t.

d) PORT-12, porteur solo, frigorifique
CU = 19 000 − 7 500 = 11 500 kg, soit 11,5 t.

2) ENVOI DE 22 t (22 000 kg) : QUEL(S) VÉHICULE(S) ?
On retient tout véhicule dont la CU est supérieure ou égale à 22 000 kg.
- TR12 + SR27 : CU 29 000 kg > 22 000 kg → possible (marge 7 000 kg).
- TR18 + SR31 : CU 25 400 kg > 22 000 kg → possible (marge 3 400 kg).
- PORT-11 : CU 17 850 kg < 22 000 kg → impossible.
- PORT-12 : CU 11 500 kg < 22 000 kg → impossible.
Réponse : seuls les deux ensembles articulés peuvent réaliser l'envoi. Le choix final dépend du conditionnement et du mode de chargement : le fourgon TR12 + SR27 impose un chargement par l'arrière, le plateau TR18 + SR31 permet un chargement latéral ou par le dessus mais exige un bâchage et un arrimage adaptés. En l'absence d'autre contrainte, on privilégie TR12 + SR27 (marge de charge utile la plus élevée et marchandise protégée).

3) ENVOI DE 8,5 t DE PRODUITS SURGELÉS À −18 °C
Seul le PORT-12 est un véhicule frigorifique : c'est donc le seul véhicule utilisable, et il est obligatoire.
Vérification de la capacité : CU = 11 500 kg > 8 500 kg à charger. Marge de 3 000 kg : l'envoi est réalisable.
Rappel réglementaire : le transport de denrées surgelées à −18 °C impose un engin de transport sous température dirigée, agréé au titre de l'accord ATP (attestation de conformité en cours de validité à bord), de la classe frigorifique permettant de maintenir la température de la marchandise à −18 °C ou moins (engin frigorifique « renforcé »). Le groupe froid doit être en fonctionnement, la température enregistrée en continu et la chaîne du froid documentée.$corr$,
  scoring_grid    = $corr$Total 6 points.
- Question 1, calcul des charges utiles (3 pts) : formule correcte de l'ensemble articulé, CU = PTRA − somme des PV, et formule du porteur, CU = PTAC − PV (0,5 pt) ; CU TR12 + SR27 = 29 000 kg (0,75 pt) ; CU TR18 + SR31 = 25 400 kg (0,75 pt) ; CU PORT-11 = 17 850 kg (0,5 pt) ; CU PORT-12 = 11 500 kg (0,5 pt). Utiliser le PTAC du tracteur (35 000 / 38 000 kg) au lieu du PTRA fait perdre la totalité des points du calcul concerné.
- Question 2, envoi de 22 t (1,5 pt) : sélection des deux ensembles articulés (1 pt, soit 0,5 pt par ensemble correctement retenu) ; exclusion motivée des deux porteurs par insuffisance de charge utile (0,5 pt).
- Question 3, surgelés à −18 °C (1,5 pt) : désignation du PORT-12, seul véhicule frigorifique (0,5 pt) ; vérification que la CU de 11 500 kg couvre les 8 500 kg (0,5 pt) ; mention de l'obligation d'un engin sous température dirigée agréé ATP et du maintien de la chaîne du froid (0,5 pt).
Total : 3 + 1,5 + 1,5 = 6 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.2] : Données recontrôlées ligne à ligne contre les tableaux de l'énoncé en base (TR15/TR17/TR18, SR45/SR47/SR49, PO22/PO24, RE87/RE89) : toutes conformes. Les 7 calculs sont exacts et le barème totalise 6 pts = max_score. [À CONFIRMER: cas 5, TR18 + SR47 + SR47 avec dolly. Le corrigé plafonne la charge utile au PTRA du tracteur (44 000 kg), d'où 19 300 kg. Si le concepteur attend un raisonnement de type ensemble modulaire (EMS/duo-trailer) avec un poids total roulant supérieur, le résultat change : faire valider l'intention pédagogique. Rappel : le train double n'est pas autorisé en circulation générale en France, ce qui mérite d'être signalé explicitement aux stagiaires.]
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ 2.2 : charge utile des ensembles RAPID ROUTE

RAPPEL DES FORMULES
- Ensemble articulé (tracteur + semi-remorque) : CU = PTRA du tracteur − (PV tracteur + PV semi-remorque).
- Porteur seul : CU = PTAC − PV.
- Train routier (porteur + remorque) : CU = (PTAC porteur − PV porteur) + (PTAC remorque − PV remorque), dans la limite du poids total roulant de l'ensemble.
Données de l'énoncé : TR15 (2 essieux, PTAC 19 000, PTRA 40 000, PV 7 800) ; TR17 (3 essieux, PTAC 26 000, PTRA 44 000, PV 8 400) ; TR18 (3 essieux, PTAC 26 000, PTRA 44 000, PV 8 900) ; SR45 (3 essieux, tautliner, PV 6 500) ; SR47 (3 essieux, frigorifique ATP, PV 7 400) ; SR49 (2 essieux, plateau, PV 5 900) ; PO22 (2 essieux, fourgon, PTAC 19 000, PV 7 200) ; PO24 (3 essieux, plateau ridelles, PTAC 26 000, PV 10 300) ; RE87 (2 essieux, PTAC 18 000, PV 4 800) ; RE89 (3 essieux, PTAC 18 000, PV 5 400).

1) TR15 + SR45 (tautliner)
PV total = 7 800 + 6 500 = 14 300 kg
CU = 40 000 − 14 300 = 25 700 kg, soit 25,7 t.
Remarque : le tracteur TR15 est un 2 essieux dont le PTRA est limité à 40 000 kg ; l'ensemble ne peut donc pas être exploité à 44 t, même si le nombre total d'essieux (2 + 3 = 5) le permettrait.

2) PO24 + RE87 (train routier)
CU porteur = 26 000 − 10 300 = 15 700 kg
CU remorque = 18 000 − 4 800 = 13 200 kg
CU totale = 15 700 + 13 200 = 28 900 kg, soit 28,9 t.
Contrôle : PTAC porteur + PTAC remorque = 26 000 + 18 000 = 44 000 kg, conforme au plafond national de 44 t, l'ensemble comptant 3 + 2 = 5 essieux.

3) TR17 + SR49 (plateau)
PV total = 8 400 + 5 900 = 14 300 kg
CU = 44 000 − 14 300 = 29 700 kg, soit 29,7 t.
Contrôle : 3 essieux au tracteur et 2 essieux à la semi, soit 5 essieux, ce qui autorise 44 t en national.

4) PO22 seul (fourgon)
CU = 19 000 − 7 200 = 11 800 kg, soit 11,8 t.

5) TR18 + SR47 + SR47 avec dolly (PV dolly = 1 000 kg)
PV total = 8 900 + 7 400 + 7 400 + 1 000 = 24 700 kg
CU = 44 000 − 24 700 = 19 300 kg, soit 19,3 t.
Remarque pédagogique : la charge utile reste plafonnée par le PTRA du tracteur (44 000 kg). L'ajout d'une seconde semi-remorque et d'un dolly ajoute du poids mort sans augmenter le poids total roulant autorisé : la charge utile chute donc fortement par rapport à un simple ensemble articulé. Cette configuration de type « train double » n'est pas admise en circulation générale sur le réseau routier français (longueur maximale d'un train double : 18,75 m, hors dérogations et expérimentations).

6) TR18 + SR49 (plateau)
PV total = 8 900 + 5 900 = 14 800 kg
CU = 44 000 − 14 800 = 29 200 kg, soit 29,2 t.

7) PO22 + RE89 (train routier)
CU porteur = 19 000 − 7 200 = 11 800 kg
CU remorque = 18 000 − 5 400 = 12 600 kg
CU totale = 11 800 + 12 600 = 24 400 kg, soit 24,4 t.
Contrôle : 19 000 + 18 000 = 37 000 kg, inférieur au plafond de 44 t : aucune restriction de ce fait.

SYNTHÈSE DES RÉSULTATS
1. TR15 + SR45 : 25 700 kg
2. PO24 + RE87 : 28 900 kg
3. TR17 + SR49 : 29 700 kg
4. PO22 : 11 800 kg
5. TR18 + SR47 + SR47 + dolly : 19 300 kg
6. TR18 + SR49 : 29 200 kg
7. PO22 + RE89 : 24 400 kg
Ensemble le plus performant en charge utile : TR17 + SR49, avec 29,7 t.$corr$,
  scoring_grid    = $corr$Total 6 points, répartis sur les 7 calculs et la maîtrise des formules.
- Formules correctement posées (CU ensemble articulé = PTRA − somme des PV ; CU train routier = somme des CU des éléments ; CU porteur = PTAC − PV) : 0,75 pt.
- Calcul 1, TR15 + SR45 = 25 700 kg : 0,75 pt.
- Calcul 2, PO24 + RE87 = 28 900 kg : 0,75 pt.
- Calcul 3, TR17 + SR49 = 29 700 kg : 0,75 pt.
- Calcul 4, PO22 = 11 800 kg : 0,5 pt.
- Calcul 5, TR18 + SR47 + SR47 + dolly = 19 300 kg : 1 pt (0,5 pt pour le PV total de 24 700 kg, 0,5 pt pour le plafonnement par le PTRA de 44 000 kg).
- Calcul 6, TR18 + SR49 = 29 200 kg : 0,75 pt.
- Calcul 7, PO22 + RE89 = 24 400 kg : 0,75 pt.
Total : 0,75 + 0,75 + 0,75 + 0,75 + 0,5 + 1 + 0,75 + 0,75 = 6 pts.
Bonification implicite : une erreur de report unique répercutée sur un seul calcul n'est pénalisée qu'une fois. Confondre le PTAC et le PTRA du tracteur pour un ensemble articulé (par ex. utiliser 19 000 kg pour TR15 ou 26 000 kg pour TR17/TR18) entraîne la perte de la totalité des points du calcul concerné.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.3] : [À CONFIRMER: la largeur utile du plateau n'est pas donnée dans l'énoncé, contrairement aux exercices 2.4 et 2.5 qui indiquent 2,40 m. Le corrigé retient 2,40 m par défaut ; il serait préférable d'ajouter cette donnée à l'énoncé.] [À CONFIRMER: convention de calcul des mètres linéaires du chapitre 2. Méthode retenue (rangée) : ml = 2 × 4,60 = 9,20 ml → poids taxable 16 468 kg. Méthode alternative (surface au sol / largeur utile) : 20,24 / 2,40 = 8,43 ml → 15 095 kg. Les exercices 2.4 et 2.5 imposent explicitement le raisonnement par rangée, ce qui plaide pour 9,20 ml ; harmoniser avant publication.] Aucune donnée réglementaire chiffrée n'est mobilisée : les coefficients 330 kg/m³ et 1 790 kg/ml sont fournis par l'énoncé.
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ — Exercice 2.3 (TRANSGO / GH LOGISTIQUE, Moulins → Bari)

Rappel de méthode : le poids taxable est le plus élevé des trois poids obtenus (poids réel, poids volumétrique, poids métrique). Il sert d'assiette à la tarification.

1. VOLUME TOTAL
Dimensions d'une unité : 4,60 m × 2,20 m × 1,85 m.
Volume unitaire = 4,60 × 2,20 × 1,85 = 18,722 m³.
Volume total = 18,722 × 2 = 37,444 m³, arrondi à 37,44 m³.

2. POIDS VOLUMÉTRIQUE
Poids volumétrique = volume × coefficient volumétrique = 37,444 × 330 = 12 356,52 kg, soit environ 12 357 kg.

3. MÈTRES LINÉAIRES
L'énoncé ne précise pas la largeur utile du plateau : on retient la largeur utile standard d'un véhicule de transport routier, soit 2,40 m (rappel : la largeur hors tout réglementaire est de 2,55 m, 2,60 m en frigorifique).
Largeur d'une unité : 2,20 m. Deux unités côte à côte demanderaient 2 × 2,20 = 4,40 m, très supérieur à la largeur utile : une seule unité peut donc être placée par rangée.
Les groupes n'étant pas gerbables, les deux unités sont posées au sol l'une derrière l'autre, chacune consommant sa longueur, soit 4,60 m.
Mètres linéaires = 4,60 × 2 = 9,20 ml.

4. POIDS MÉTRIQUE
Poids métrique = ml × coefficient métrique = 9,20 × 1 790 = 16 468 kg.

5. POIDS TAXABLE
Comparaison : poids réel 6 500 kg ; poids volumétrique 12 357 kg ; poids métrique 16 468 kg.
Poids taxable = 16 468 kg (le poids métrique, le plus élevé des trois).

Commentaire : l'envoi est un envoi « encombrant ». Le poids retenu pour la facturation est environ 2,5 fois le poids réel, ce qui traduit l'immobilisation d'une longue portion du plancher du véhicule. Le grutage impose par ailleurs un plateau (pas de palettisation), d'où l'absence de calcul par palette.

Tableau de synthèse :
- Volume total : 4,60 × 2,20 × 1,85 × 2 → 37,44 m³
- Poids volumétrique : 37,444 × 330 → 12 357 kg
- Mètres linéaires : 4,60 × 2 (1 unité par rangée, non gerbable) → 9,20 ml
- Poids métrique : 9,20 × 1 790 → 16 468 kg
- Poids taxable : max (6 500 ; 12 357 ; 16 468) → 16 468 kg$corr$,
  scoring_grid    = $corr$Total : 6 points (= max_score)
- Q1 Volume total : 1 pt (0,5 pt volume unitaire 18,722 m³ ; 0,5 pt total 37,44 m³)
- Q2 Poids volumétrique : 1 pt (0,5 pt formule volume × 330 ; 0,5 pt résultat 12 357 kg, tolérance 12 356 à 12 357 kg)
- Q3 Mètres linéaires : 1,5 pt (0,75 pt justification d'une seule unité par rangée, largeur 2,20 m contre 2,40 m utiles, et absence de gerbage ; 0,75 pt résultat 9,20 ml)
- Q4 Poids métrique : 1,5 pt (0,5 pt formule ml × 1 790 ; 1 pt résultat 16 468 kg)
- Q5 Poids taxable : 1 pt (0,5 pt comparaison explicite des trois poids ; 0,5 pt retenue du plus élevé, 16 468 kg)
Tolérance de correction : le candidat qui calcule les ml par la surface au sol (20,24 m² / 2,40 m = 8,43 ml, soit un poids métrique de 15 095 kg et un poids taxable de 15 095 kg) obtient l'intégralité des points de Q3 à Q5 si la démarche est explicitée et la comparaison finale correcte.
Pénalité : aucune unité indiquée ou arrondi manifestement faux : moins 0,5 pt sur la sous-question concernée. Résultat correct sans détail de calcul : moitié des points de la sous-question.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ — Exercice 2.4 (NORD FRET / TISSEX EUROPE, Lille → Varsovie)

Rappel de méthode : poids taxable = poids le plus élevé entre poids réel, poids volumétrique et poids métrique.

1. VOLUME TOTAL
Comme l'indique l'énoncé, un rouleau posé à plat est traité par son encombrement parallélépipédique : longueur × diamètre × diamètre.
Volume unitaire = 1,50 × 1,20 × 1,20 = 2,16 m³.
Volume total = 2,16 × 12 = 25,92 m³.

2. POIDS VOLUMÉTRIQUE
Poids volumétrique = 25,92 × 330 = 8 553,60 kg, soit environ 8 554 kg.

3. MÈTRES LINÉAIRES
Les rouleaux sont gerbables sur 2 niveaux : seule la moitié des rouleaux repose au sol, soit 12 / 2 = 6 rouleaux au sol.
L'énoncé précise que la largeur d'un rouleau (1,20 m, son diamètre) n'autorise qu'un rouleau par voie sur une largeur utile de 2,40 m (deux rouleaux côte à côte exigeraient exactement 2,40 m, sans aucun jeu de calage). Chaque rouleau au sol occupe donc une rangée et consomme sa longueur, soit 1,50 m.
Mètres linéaires = 6 × 1,50 = 9,00 ml.

4. POIDS MÉTRIQUE
Poids métrique = 9,00 × 1 790 = 16 110 kg.

5. POIDS TAXABLE
Comparaison : poids réel 2 400 kg ; poids volumétrique 8 554 kg ; poids métrique 16 110 kg.
Poids taxable = 16 110 kg (le poids métrique).

Commentaire : marchandise très légère mais très encombrante. Le poids taxable représente près de 7 fois le poids réel : c'est le volume et surtout l'emprise au sol, non la masse, qui déterminent le prix. Le gerbage sur 2 niveaux divise par deux l'emprise au sol et donc le poids métrique : sans gerbage, on aurait eu 12 × 1,50 = 18,00 ml, soit 32 220 kg taxables.

Tableau de synthèse :
- Volume total : 1,50 × 1,20 × 1,20 × 12 → 25,92 m³
- Poids volumétrique : 25,92 × 330 → 8 554 kg
- Mètres linéaires : (12 / 2) × 1,50 → 9,00 ml
- Poids métrique : 9,00 × 1 790 → 16 110 kg
- Poids taxable : max (2 400 ; 8 554 ; 16 110) → 16 110 kg$corr$,
  scoring_grid    = $corr$Total : 6 points (= max_score)
- Q1 Volume total : 1 pt (0,5 pt encombrement unitaire L × Ø × Ø = 2,16 m³ ; 0,5 pt total 25,92 m³)
- Q2 Poids volumétrique : 1 pt (0,5 pt formule volume × 330 ; 0,5 pt résultat 8 554 kg, tolérance 8 553 à 8 554 kg)
- Q3 Mètres linéaires : 1,5 pt (0,5 pt prise en compte du gerbage sur 2 niveaux, soit 6 rouleaux au sol ; 0,5 pt un rouleau par voie, chaque rouleau consommant 1,50 m ; 0,5 pt résultat 9,00 ml)
- Q4 Poids métrique : 1,5 pt (0,5 pt formule ml × 1 790 ; 1 pt résultat 16 110 kg)
- Q5 Poids taxable : 1 pt (0,5 pt comparaison explicite des trois poids ; 0,5 pt retenue de 16 110 kg)
Pénalité : oubli du gerbage (18 ml au lieu de 9 ml) : 0 pt sur Q3 et moitié des points sur Q4 et Q5 si le raisonnement de comparaison reste exact. Poids réel retenu comme poids taxable : 0 pt sur Q5.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.4' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ — Exercice 2.5 (TRANSALPEX / SODIBRICO, Marseille → Milan)

Rappel de méthode : poids taxable = poids le plus élevé entre poids réel, poids volumétrique et poids métrique.

1. VOLUME TOTAL
Volume d'une palette = 1,20 × 0,80 × 1,60 = 1,536 m³.
Volume total = 1,536 × 18 = 27,648 m³, arrondi à 27,65 m³.

2. POIDS VOLUMÉTRIQUE
Poids volumétrique = 27,648 × 330 = 9 123,84 kg, soit environ 9 124 kg.

3. MÈTRES LINÉAIRES
Les palettes EUR (1,20 m × 0,80 m) sont chargées par paires côte à côte : c'est le côté 1,20 m qui est placé dans le sens de la largeur du véhicule, soit 2 × 1,20 = 2,40 m, ce qui correspond exactement à la largeur utile. Chaque rangée de 2 palettes consomme donc 0,80 m de longueur de plancher, soit 0,40 ml par palette (repère à retenir : une palette EUR au sol = 0,40 ml).
Les palettes ne sont pas gerbables : toutes reposent au sol.
Nombre de rangées = 18 / 2 = 9 rangées.
Mètres linéaires = 9 × 0,80 = 7,20 ml (contrôle : 18 × 0,40 = 7,20 ml).

4. POIDS MÉTRIQUE
Poids métrique = 7,20 × 1 790 = 12 888 kg.

5. POIDS TAXABLE
Comparaison : poids réel 10 800 kg ; poids volumétrique 9 124 kg ; poids métrique 12 888 kg.
Poids taxable = 12 888 kg (le poids métrique).

Commentaire : le carrelage est une marchandise dense (600 kg par palette). Le poids volumétrique est ici inférieur au poids réel, ce qui est caractéristique d'une marchandise lourde ; c'est néanmoins l'emprise au sol (poids métrique) qui l'emporte, du fait de l'interdiction de gerber. Un gerbage sur 2 niveaux aurait ramené l'emprise à 3,60 ml, soit 6 444 kg de poids métrique, et le poids taxable serait alors devenu le poids réel, 10 800 kg.

Tableau de synthèse :
- Volume total : 1,20 × 0,80 × 1,60 × 18 → 27,65 m³
- Poids volumétrique : 27,648 × 330 → 9 124 kg
- Mètres linéaires : (18 / 2) × 0,80 → 7,20 ml
- Poids métrique : 7,20 × 1 790 → 12 888 kg
- Poids taxable : max (10 800 ; 9 124 ; 12 888) → 12 888 kg$corr$,
  scoring_grid    = $corr$Total : 6 points (= max_score)
- Q1 Volume total : 1 pt (0,5 pt volume unitaire 1,536 m³ ; 0,5 pt total 27,65 m³)
- Q2 Poids volumétrique : 1 pt (0,5 pt formule volume × 330 ; 0,5 pt résultat 9 124 kg, tolérance 9 123 à 9 124 kg)
- Q3 Mètres linéaires : 1,5 pt (0,5 pt 2 palettes par rangée et 9 rangées, aucune palette gerbée ; 0,5 pt une rangée consomme 0,80 m de plancher, soit 0,40 ml par palette ; 0,5 pt résultat 7,20 ml)
- Q4 Poids métrique : 1,5 pt (0,5 pt formule ml × 1 790 ; 1 pt résultat 12 888 kg)
- Q5 Poids taxable : 1 pt (0,5 pt comparaison explicite des trois poids, avec mention du poids réel de 10 800 kg ; 0,5 pt retenue de 12 888 kg)
Tolérance de correction : le candidat qui, lisant « palettes EUR (80 cm de large) », place 3 palettes de front (3 × 0,80 = 2,40 m) et compte 6 rangées de 1,20 m aboutit également à 7,20 ml : accepter l'intégralité des points de Q3 si le raisonnement est explicité.
Pénalité : candidat retenant le poids réel ou le poids volumétrique sans comparer les trois valeurs : 0 pt sur Q5.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.5' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.6] : [À CONFIRMER: capacité de référence de la semi-remorque de 13,60 m. Le calcul strict de l'énoncé (4,80 ml restants / 0,40 ml par palette) donne 12 palettes EUR supplémentaires, soit 34 palettes au total ; la valeur professionnelle usuellement retenue est de 33 palettes EUR au sol, ce qui donnerait 11 palettes supplémentaires. Le barème accepte les deux réponses si le raisonnement est justifié, mais la convention du cours doit être fixée.] [À CONFIRMER: l'énoncé ne précise ni le poids de la commande ni le caractère non gerbable des big-bags ni la largeur utile du véhicule (2,40 m). Le corrigé retient ces trois hypothèses (non gerbable, 2,40 m utiles) et signale la réserve sur la charge utile ; il serait préférable de compléter l'énoncé.] Seule donnée réglementaire citée : PTAC 44 t à 5 essieux en national, mentionnée à titre de réserve et conforme au référentiel.
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ — Exercice 2.6 (TRANSGO / LES SUCRERIES D'AUVERGNE, Clermont-Ferrand → Rhône-Alpes)

1. MÈTRES LINÉAIRES OCCUPÉS PAR LA COMMANDE
Palette EUR : 1,20 m × 0,80 m. Chargée en travers (côté 1,20 m dans le sens de la largeur), on place 2 palettes côte à côte : 2 × 1,20 = 2,40 m, soit la largeur utile d'une semi-remorque standard. Chaque rangée de 2 palettes consomme 0,80 m de longueur de plancher, soit 0,40 ml par palette.
Les big-bags posés sur palette ne sont pas gerbables (forme souple et instable) : toutes les palettes reposent au sol.
Nombre de rangées = 22 / 2 = 11 rangées.
Mètres linéaires = 11 × 0,80 = 8,80 ml (contrôle : 22 × 0,40 = 8,80 ml).

2. PLACE DISPONIBLE ET COMPLÉMENT DE FRET
Longueur utile de la semi-remorque : 13,60 m.
Longueur restante = 13,60 − 8,80 = 4,80 ml.
Oui, il reste de la place : le véhicule n'est rempli qu'à 8,80 / 13,60 = 64,7 % de sa longueur utile.
Nombre de rangées supplémentaires = 4,80 / 0,80 = 6 rangées, soit 6 × 2 = 12 palettes EUR supplémentaires (contrôle : 4,80 / 0,40 = 12 palettes).
Réponse : 12 palettes EUR supplémentaires peuvent être chargées, sous réserve du respect de la charge utile du véhicule, du PTAC (44 t maximum en national à 5 essieux) et de la bonne répartition des charges sur les essieux.
Remarque professionnelle : la capacité usuellement retenue pour une semi-remorque de 13,60 m est de 33 palettes EUR au sol (jeux de calage, épaisseur des ridelles) ; le complément serait alors de 33 − 22 = 11 palettes. La démarche de calcul strictement demandée ici conduit à 12 palettes (soit 34 au total). Les deux réponses sont acceptées si elles sont justifiées.
Intérêt commercial : cette place résiduelle permet un groupage ou un fret de complément, qui améliore le taux de remplissage et donc la marge sur le voyage.

3. TYPE DE CARROSSERIE
Pour des big-bags de sucre, sensibles à l'humidité, chargés au quai par chariot élévateur et à décharger latéralement, il faut une semi-remorque bâchée à rideaux coulissants (tautliner, ou PLSC : plateau à ridelles, savoyarde à bâche coulissante). Elle offre :
- l'ouverture latérale complète des rideaux, indispensable au déchargement par le côté et à la reprise des big-bags au chariot ou à la potence ;
- une bâche étanche protégeant la marchandise de l'humidité, contrairement au plateau nu ;
- une souplesse de chargement au quai (ouverture arrière ou ouverture des rideaux).
Si la reprise des big-bags doit se faire par le dessus (grue, palan), on choisira une version à toit ouvrant ou coulissant.
À écarter : la caisse fourgon, qui interdit le déchargement latéral ; le plateau nu, qui ne protège pas de l'humidité en l'absence de bâchage complémentaire.$corr$,
  scoring_grid    = $corr$Total : 6 points (= max_score)
- Q1 Mètres linéaires : 2 pts (0,5 pt dimensions de la palette EUR 1,20 × 0,80 m ; 0,5 pt 2 palettes en travers par rangée sur 2,40 m de large, soit 0,40 ml par palette ; 0,5 pt 11 rangées, palettes non gerbables ; 0,5 pt résultat 8,80 ml)
- Q2 Place disponible : 2,5 pts (0,5 pt longueur restante 13,60 − 8,80 = 4,80 ml ; 0,5 pt réponse explicite « oui, il reste de la place » ; 1 pt nombre de palettes supplémentaires : 4,80 / 0,40 = 12 palettes EUR — accepter 11 palettes si la capacité usuelle de 33 palettes est invoquée et justifiée ; 0,5 pt réserve sur la charge utile / le PTAC / la répartition des essieux, ou mention de l'intérêt du fret de complément)
- Q3 Carrosserie : 1,5 pt (1 pt semi-remorque bâchée à rideaux coulissants, tautliner ou PLSC ; 0,5 pt justification par le déchargement latéral ET la protection contre l'humidité ; la mention du toit ouvrant ou coulissant pour une reprise par le dessus est valorisée dans la justification, sans dépassement du total)
Pénalité : réponse « fourgon » ou « plateau nu » : 0 pt sur Q3. Oubli de la non-gerbabilité conduisant à diviser l'emprise par 2 : 0 pt sur Q1 et report d'erreur non pénalisé en Q2 si la méthode est juste.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.6' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.4bis] : [A CONFIRMER: le classement administratif du convoi exceptionnel pour une largeur de 3,20 m (categories definies par la largeur, la longueur et la masse, arrete relatif au transport exceptionnel) n'est volontairement pas chiffre dans le corrige : ne pas exiger de categorie du candidat, ni de nombre de vehicules d'accompagnement, avant validation du texte en vigueur.] [A CONFIRMER: la capacite d'une semi de 13,60 m est enoncee tantot a 33, tantot a 34 palettes EUR selon les supports ; le corrige accepte les deux et le bareme neutralise l'ecart.] Valeurs tenues pour certaines : 0,40 ml par palette EUR, largeur utile d'environ 2,45 m, largeur maximale de droit commun 2,55 m (2,60 m pour les engins isothermes/frigorifiques).
UPDATE public.question_bank SET
  expected_answer = $corr$1. Calcul des mètres linéaires (ml)
Une palette EUR mesure 0,80 m x 1,20 m. La largeur utile intérieure d'une semi-remorque est d'environ 2,45 m, ce qui permet de charger soit 3 palettes de front dans le sens de la largeur (3 x 0,80 = 2,40 m) sur une profondeur de 1,20 m, soit 2 palettes de front (2 x 1,20 = 2,40 m) sur une profondeur de 0,80 m. Dans les deux cas on retient la regle usuelle : 1 palette EUR = 0,40 ml.
Metres lineaires occupes = 22 x 0,40 = 8,80 ml.
(Verification pratique : 22 / 3 = 7,33 rangees, soit 8 rangees entamees x 1,20 m = 9,60 m si l'on refuse de casser une rangee. Valeur theorique retenue : 8,80 ml ; valeur pratique : 9,60 m.)

2. Place disponible sur la semi-remorque de 13,60 m
Longueur utile : 13,60 m. Capacite theorique = 13,60 / 0,40 = 34 palettes EUR ; en pratique on retient 33 palettes EUR (calage, jeu de chargement).
Lineaire restant : 13,60 - 8,80 = 4,80 ml.
Palettes EUR supplementaires : 4,80 / 0,40 = 12 palettes (soit 11 palettes si l'on retient la capacite pratique de 33 : 33 - 22 = 11).
Il reste donc de la place. En raisonnant en rangees pleines : 13,60 - 9,60 = 4,00 m, soit 3 rangees completes de 3 palettes = 9 palettes.
Reserve indispensable : le remplissage volumetrique ne doit pas conduire a un depassement de la charge utile (respect du PTAC / PTRA et de la repartition des charges par essieu). Le poids doit donc etre verifie avant d'accepter le complement de fret.

3. Carrosserie adaptee aux big-bags avec dechargement lateral
Semi-remorque bachee a rideaux coulissants (tautliner) sur chassis plateau, de preference avec toit coulissant/ouvrant.
Justification : les rideaux coulissants liberent tout le cote du vehicule et autorisent la prise et la depose des big-bags et des palettes au chariot elevateur depuis le quai ; la bache protege le sucre en poudre de l'humidite (plateau nu exclu) ; le toit ouvrant permet le cas echeant une manutention par le dessus (grue, palan). Prevoir les moyens d'arrimage adaptes (sangles, barres, tapis antiglisse), l'arrimage etant une obligation partagee du chargeur et du transporteur.

Exercice 2.4 : choisir le bon vehicule
A. 15 palettes de pieces mecaniques, 14 t, dechargement lateral au chariot : ensemble articule bache a rideaux coulissants (tautliner 13,60 m). Justification : ouverture laterale integrale pour la prise au chariot, protection de la marchandise, charge utile suffisante (14 t ; 15 palettes = 6,00 ml).
B. Viandes fraiches, 8 t, 0 a +4 degres : vehicule frigorifique sous attestation ATP de classe FRC (engin renforce, groupe frigorifique). Justification : denrees perissables sous temperature dirigee, engin ATP en cours de validite, enregistrement des temperatures, respect de la chaine du froid (paquet hygiene). Pour de la viande suspendue, prevoir un amenagement a crochets (rails, penderie).
C. Beton en vrac, 22 t, dechargement par bascule : semi-remorque benne basculante (benne TP). Justification : le vrac se decharge par gravite en basculant la benne. Si le beton est livre frais et pret a l'emploi, la solution devient le camion malaxeur (toupie).
D. Machines industrielles hors gabarit, 35 t, largeur 3,20 m : ensemble porte-engins surbaisse (plateau surbaisse ou remorque extensible) circulant sous le regime du transport exceptionnel. Justification : 3,20 m depasse la largeur de droit commun de 2,55 m ; il faut une autorisation de transport exceptionnel, un itineraire autorise, la signalisation reglementaire (panneaux, gyrophares) et, selon le classement du convoi, un ou des vehicules d'accompagnement (voiture pilote).
E. Cartons de cosmetiques fragiles, 3 t, livraison urbaine en rues etroites : porteur fourgon leger (VUL jusqu'a 3,5 t ou petit porteur), equipe d'un hayon elevateur. Justification : gabarit compatible avec la circulation et le stationnement en ville, protection integrale de marchandises fragiles, hayon en l'absence de quai chez le destinataire ; verifier la conformite aux regles de ZFE (vignette Crit'Air) et aux restrictions horaires de livraison en centre-ville.$corr$,
  scoring_grid    = $corr$Total 6 points.
Q1 (metres lineaires) : 1,5 pt. 0,5 pt pour la regle 1 palette EUR = 0,40 ml (justifiee par le format 0,80 x 1,20 m et la largeur utile d'environ 2,45 m) ; 1 pt pour le resultat 22 x 0,40 = 8,80 ml.
Q2 (place disponible) : 1,5 pt. 0,5 pt pour le lineaire restant (13,60 - 8,80 = 4,80 ml) ; 0,5 pt pour le nombre de palettes supplementaires (accepter 12 en theorique, 11 en pratique sur une base de 33 palettes, ou 9 en rangees pleines des lors que le raisonnement est explicite) ; 0,5 pt pour la reserve sur la charge utile (PTAC/PTRA, essieux) ou pour le calcul en rangees pleines.
Q3 (carrosserie big-bags) : 1 pt. 0,5 pt pour la semi bachee a rideaux coulissants (tautliner) ; 0,5 pt pour la justification (acces lateral au chariot, protection contre l'humidite, toit ouvrant possible, arrimage).
Tableau exercice 2.4 : 2 pts, soit 0,4 pt par ligne A a E (0,2 pt pour le vehicule adapte, 0,2 pt pour la justification). Aucun point sur la ligne si le vehicule propose est incompatible avec la contrainte speciale (ex. : plateau nu pour les viandes, bache pour du vrac beton).
Controle de coherence : 1,5 + 1,5 + 1 + 2 = 6 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.4bis' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$1. Informations manquantes a obtenir avant de chiffrer
Identification du client : raison sociale, SIRET, adresse de facturation, nom et coordonnees de l'interlocuteur, client deja reference ou nouveau (encours, conditions de paiement, solvabilite).
Marchandise : nature exacte du produit, caractere dangereux (ADR) ou non, denree perissable ou temperature dirigee, valeur declaree (assurance ad valorem), sensibilite (fragile, humidite, vol).
Unites de manutention : nombre de palettes, type (EUR, perdues, autres formats), dimensions et hauteur de chaque palette, gerbabilite, poids unitaire et poids total, metres lineaires occupes.
Lieux : adresses completes d'enlevement et de livraison (rue, code postal, commune), contacts sur site, contraintes d'acces (hauteur, tonnage, rues etroites, ZFE, centre-ville).
Dates et horaires : jour precis d'enlevement et de livraison, creneaux horaires, prise de rendez-vous obligatoire ou non, degre d'urgence, caractere ponctuel ou recurrent (trafic regulier).
Moyens de chargement et de dechargement : quai, chariot elevateur, transpalette, hayon elevateur necessaire, dechargement lateral ou par l'arriere, temps d'attente previsible.
Nature de la prestation : lot complet, lot partiel ou groupage ; vehicule specifique attendu (bache, frigorifique, plateau).
Aspects commerciaux et juridiques : conditions de paiement, qui supporte le prix du transport (port paye ou port du), regime applicable (contrat type general ou contrat type specifique a defaut de convention ecrite), documents attendus (lettre de voiture, recepisse, bon de livraison), besoin d'une assurance complementaire (declaration de valeur ou d'interet special a la livraison).

2. Modele d'email de demande d'informations complementaires
De : exploitation@transgo.fr
A : m.dupont@client.fr
Objet : Votre demande de transport Clermont-Ferrand vers Paris : informations complementaires

Bonjour Monsieur Dupont,
Nous vous remercions de votre demande et nous sommes a votre disposition pour vous etablir une offre.
Afin de vous adresser un prix ferme et adapte, pourriez-vous nous preciser : la nature de la marchandise et son caractere eventuellement dangereux ou perissable ; le nombre de palettes, leurs dimensions, leur hauteur, leur gerbabilite et le poids total ; les adresses completes d'enlevement et de livraison ainsi que les contacts sur place ; la date et le creneau horaire souhaites pour le chargement et la date de livraison attendue ; enfin les moyens de manutention disponibles aux deux extremites (quai, chariot, ou besoin d'un hayon elevateur).
Des reception de ces elements, nous vous transmettrons notre proposition tarifaire sous 24 heures.
Restant a votre disposition, nous vous prions d'agreer, Monsieur, l'expression de nos salutations distinguees.
Prenom NOM, service exploitation, TRANSGO, telephone.$corr$,
  scoring_grid    = $corr$Total 6 points.
Q1 (informations manquantes) : 4 pts. 0,5 pt par famille d'informations correctement identifiee, dans la limite de 8 familles : identite et donnees commerciales du client ; nature de la marchandise (dont ADR ou temperature dirigee) ; nombre, type, dimensions, hauteur, gerbabilite des palettes ; poids total et metres lineaires ; adresses completes et contraintes d'acces ; dates, horaires et urgence ; moyens de chargement et de dechargement (dont hayon) ; type de prestation et conditions commerciales/juridiques. Une enumeration non regroupee est creditee si au moins huit informations pertinentes distinctes sont citees (0,5 pt par groupe de deux informations, plafonne a 4 pts).
Q2 (email professionnel) : 2 pts. 0,5 pt pour la forme (champs De/A/Objet renseignes, objet explicite, formule d'appel, formule de politesse, signature) ; 0,5 pt pour le format demande (5 a 8 lignes, francais professionnel, pas de faute majeure) ; 1 pt pour le contenu (reprise d'au moins cinq informations manquantes citees en Q1 et engagement de reponse chiffree).
Controle de coherence : 4 + 2 = 6 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch03:ex3.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$Hypotheses retenues : vitesse commerciale 68 km/h (consigne TRANSGO), temps de service maximal 10 h par jour (consigne TRANSGO), pause repas 1 h, conducteur seul.

1. Temps de conduite Amsterdam vers Echirolles
Temps de conduite = distance / vitesse commerciale = 1 054 / 68 = 15,5 h, soit 15 h 30 de conduite.

2. Temps de service global de la mission
Chargement : 1 h 30 ; conduite : 15 h 30 ; dechargement : 1 h 30.
Temps de travail (temps de service) = 1 h 30 + 15 h 30 + 1 h 30 = 18 h 30.
En ajoutant la pause repas d'une heure (qui n'est pas du temps de travail mais qui allonge l'amplitude), la duree totale de la mission ressort a 19 h 30.
Il faut en outre integrer les interruptions de conduite du reglement CE 561/2006 : 15 h 30 de conduite imposent au minimum 3 pauses de 45 min (une apres chaque tranche de 4 h 30 de conduite continue : a 4 h 30, 9 h 00 et 13 h 30 ; la pause pouvant etre fractionnee en 15 min puis 30 min), soit 2 h 15 supplementaires. L'amplitude reelle atteindrait donc environ 21 h 45 (19 h 30 + 2 h 15).

3. Analyse de faisabilite au regard de la reglementation sociale europeenne (reglement CE 561/2006)
Conduite journaliere : maximum 9 h, portee a 10 h deux fois par semaine. La mission exige 15 h 30 de conduite, soit un depassement de 5 h 30 meme en retenant la derogation a 10 h. Non conforme.
Conduite continue : au-dela de 4 h 30 de conduite ininterrompue, pause obligatoire de 45 min (fractionnable 15 + 30). La mission impose au moins 3 interruptions, incompatibles avec le delai demande.
Repos journalier : le conducteur doit prendre 11 h de repos journalier consecutives (reductible a 9 h, trois fois maximum entre deux repos hebdomadaires), ce qui interdit d'enchainer l'integralite du trajet.
Consigne interne TRANSGO : temps de service limite a 10 h par jour, alors que la mission en demande 18 h 30 : depassement de 8 h 30.
Controle horaire : chargement le lundi 18/03 a 14 h 00, fin de chargement a 15 h 30. Meme en retenant la derogation a 10 h de conduite plus 2 pauses de 45 min, le conducteur atteindrait au mieux 15 h 30 + 10 h 00 + 1 h 30 = mardi 03 h 00, en ayant deja depasse sa duree de service ; il lui resterait 5 h 30 de conduite et il devrait d'abord prendre son repos journalier de 9 h a 11 h, ce qui reporte l'arrivee au mardi apres-midi au plus tot, sans compter le dechargement de 1 h 30. La livraison du mardi 19/03 a 8 h 00 est donc impossible.
Conclusion : la mission n'est pas realisable en une seule journee avec un conducteur seul ; elle est irrealisable en l'etat.
Remarque : si Martin LACHAUD doit en outre rejoindre Amsterdam depuis Cologne (272 km, soit 272 / 68 = 4 h 00 de conduite d'approche) et effectuer la collecte sur 4 sites, le deficit s'aggrave encore (conduite totale d'environ 19 h 30 hors temps de collecte).

4. Solutions d'exploitation envisageables
Solution privilegiee : affecter la mission a un equipage en double (deux conducteurs a bord). En conduite en equipage, la pause de 45 min peut etre prise a bord du vehicule conduit par l'autre conducteur (le vehicule continue de rouler), chaque conducteur restant dans sa limite individuelle de 9 h (10 h deux fois par semaine) ; le repos journalier de 9 h doit etre pris dans les 30 heures suivant la fin du repos journalier ou hebdomadaire precedent. Les 15 h 30 de conduite peuvent alors etre reparties (par exemple 8 h 00 et 7 h 30) : depart 15 h 30 le lundi, arrivee vers 07 h 00 le mardi, dechargement possible des 08 h 00. La livraison du mardi 19/03 a 8 h 00 devient tenable, sous reserve des arrets techniques (carburant, peages, controle).
Autres solutions acceptables : relais de conducteurs (echange de tracteur ou de conducteur a mi-parcours, sur un site relais en Alsace ou en Bourgogne) ; sous-traitance ou affretement aupres d'un confrere inscrit au registre electronique national des entreprises de transport, apres verification de sa licence, de son assurance et de son attestation de vigilance URSSAF ; anticipation du chargement (depart le dimanche soir ou le lundi matin) ; renegociation avec HANSA-FLEX de l'heure de livraison (report au mardi en fin de journee), formalisee par ecrit.
Solution a proscrire : demander au conducteur de depasser ses temps de conduite. Cela expose l'entreprise et le gestionnaire de transport a des sanctions (amendes, perte d'honorabilite), engage leur responsabilite penale et peut faire perdre le benefice de l'assurance en cas d'accident.$corr$,
  scoring_grid    = $corr$Total 6 points.
Q1 (temps de conduite) : 1 pt. 0,5 pt pour la formule (distance / vitesse commerciale) ; 0,5 pt pour le resultat 1 054 / 68 = 15,5 h, soit 15 h 30.
Q2 (temps de service global) : 1,5 pt. 0,5 pt pour l'addition chargement 1 h 30 + conduite 15 h 30 + dechargement 1 h 30 = 18 h 30 ; 0,5 pt pour la prise en compte de la pause repas de 1 h (amplitude 19 h 30) ; 0,5 pt pour la mention des pauses reglementaires de 45 min par tranche de 4 h 30 (au moins 3 pauses, soit 2 h 15, amplitude d'environ 21 h 45).
Q3 (analyse RSE) : 2 pts. 0,5 pt pour la limite de conduite journaliere (9 h, 10 h deux fois par semaine) et le constat du depassement ; 0,5 pt pour la conduite continue (4 h 30 puis 45 min de pause, fractionnable 15 + 30) ; 0,5 pt pour le repos journalier de 11 h (reductible a 9 h, trois fois entre deux repos hebdomadaires) et/ou le depassement du temps de service interne de 10 h ; 0,5 pt pour la conclusion argumentee par le calcul horaire (livraison mardi 8 h impossible avec un conducteur seul).
Q4 (solution d'exploitation) : 1,5 pt. 1 pt pour une solution pertinente (double equipage, relais de conducteurs, affretement ou sous-traitance, renegociation ecrite du delai) ; 0,5 pt pour la justification reglementaire ou commerciale associee. Aucun point sur la question si le candidat propose de depasser les temps de conduite.
Controle de coherence : 1 + 1,5 + 2 + 1,5 = 6 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch03:ex3.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch03:ex3.3] : [A CONFIRMER: la masse maximale autorisee de 40 t pour un ensemble articule en transport international intracommunautaire (directive 96/53/CE), la limite de 44 t a 5 essieux etant celle admise en national, ainsi que l'ordre de grandeur de la charge utile (24 a 26 t selon la tare). La conclusion de la demande 3 reste vraie dans toutes les hypotheses : meme a 44 t de PTRA, la charge utile (de l'ordre de 28 t) reste inferieure aux 35 t demandees, donc deux voyages sont necessaires.] [A CONFIRMER: la denomination retenue pour le materiel (citerne silo a dechargement pneumatique pour vrac granulaire) ; une benne cerealiere etanche et bachee est egalement admise et le bareme ne penalise pas ce choix.] Elements tenus pour certains : ATP FRC pour les denrees a 0-4 degres, 0,40 ml par palette EUR, temps de conduite du reglement CE 561/2006, obligations de verification du sous-traitant (licence, assurance, attestation de vigilance).
UPDATE public.question_bank SET
  expected_answer = $corr$Tableau complete.

Demande 1 : 22 palettes de pieces mecaniques, Clermont-Ferrand vers Barcelone, livraison sous 48 h, 15 t.
Contraintes : transport international intracommunautaire ; distance d'environ 750 a 800 km ; 22 palettes EUR = 22 x 0,40 = 8,80 ml, compatibles avec une semi de 13,60 m ; 15 t de marchandise ; delai de 48 h.
Solution retenue : lot complet en ensemble articule bache a rideaux coulissants (tautliner 13,60 m), un conducteur seul, realise en propre.
Justification : le lineaire (8,80 ml) et le poids (15 t) sont compatibles avec la charge utile d'un ensemble articule ; les rideaux coulissants facilitent la manutention au chariot. A environ 800 km, la conduite avoisine 11 a 12 h : le trajet doit etre reparti sur deux journees (maximum 9 h de conduite par jour, 10 h deux fois par semaine, pause de 45 min toutes les 4 h 30, repos journalier de 11 h reductible a 9 h) ; le delai de 48 h est donc tenu. Documents : lettre de voiture CMR, licence communautaire a bord.

Demande 2 : 3 palettes de produits laitiers frais, Lyon vers Marseille, livraison en J+1, 0 a 4 degres.
Contraintes : denrees perissables sous temperature dirigee ; lot partiel (3 palettes, soit 1,20 ml) ; distance d'environ 320 km ; delai J+1.
Solution retenue : groupage ou affretement sur une ligne frigorifique reguliere Lyon-Marseille, avec un porteur ou une semi frigorifique sous attestation ATP de classe FRC.
Justification : un lot de 3 palettes ne rentabilise pas un vehicule complet ; le groupage frigorifique permet de tenir le delai J+1 au meilleur cout. L'engin doit etre sous ATP FRC en cours de validite, avec relevé et enregistrement des temperatures (chaine du froid, paquet hygiene) et une prise en charge a temperature de consigne controlee au chargement.

Demande 3 : 35 t de granules plastiques en vrac, Thiers vers Liege.
Contraintes : vrac granulaire (produit sec, sensible a l'humidite et a la contamination) ; transport international ; masse de marchandise de 35 t, superieure a la charge utile d'un seul ensemble articule.
Solution retenue : semi-remorque citerne silo pour vrac granulaire/pulverulent (chargement par le dessus, dechargement pneumatique par compresseur), avec deux vehicules ou deux rotations.
Justification : le vrac granulaire exige une citerne silo (ou, a defaut, une benne cerealiere etanche et bachee) et exclut une semi bachee a palettes. En transport routier international intracommunautaire, la masse maximale autorisee d'un ensemble articule est de 40 t (44 t etant la limite admise en national a 5 essieux) : avec une tare d'ensemble de l'ordre de 15 a 16 t, la charge utile ressort a environ 24 a 26 t. Meme sous l'hypothese la plus favorable, les 35 t ne peuvent pas etre acheminees en un seul voyage : il faut deux ensembles (ou deux rotations), a integrer dans la cotation et le planning. Prevoir la lettre de voiture CMR et le certificat de nettoyage/lavage de la citerne (compatibilite avec le produit precedent).

Demande 4 : conducteur habituel absent, mission urgente Clermont-Ferrand vers Paris, aucun vehicule disponible.
Contraintes : absence simultanee de ressource humaine et de materiel ; urgence ; obligation de continuite de service envers le client.
Solution retenue : sous-traiter la mission (affretement) a un confrere inscrit au registre electronique national des entreprises de transport, ou recourir a une location de vehicule avec conducteur.
Justification : l'affretement permet d'honorer l'engagement pris envers le client sans rompre le contrat ; le donneur d'ordre reste responsable vis-a-vis de son client. Verifications prealables obligatoires : licence de transport et inscription au registre du sous-traitant, attestation d'assurance de responsabilite contractuelle, attestation de vigilance URSSAF (lutte contre le travail dissimule) ; relation formalisee par ecrit dans le cadre du contrat type de sous-traitance (remuneration du sous-traitant, delais de paiement). Les solutions purement internes (conducteur interimaire, reaffectation d'un conducteur du planning) ne sont pas mobilisables ici puisqu'aucun vehicule n'est disponible.$corr$,
  scoring_grid    = $corr$Total 6 points, soit 1,5 pt par ligne du tableau (4 lignes).
Chaque ligne : 0,5 pt pour l'identification correcte des contraintes ; 0,5 pt pour la solution retenue ; 0,5 pt pour la justification (technique, reglementaire ou economique).
Ligne 1 (Clermont - Barcelone) : contraintes international, 8,80 ml, 15 t, 48 h ; solution lot complet en tautliner 13,60 m ; justification compatibilite charge/lineaire et faisabilite du delai au regard des temps de conduite (trajet sur 2 jours), CMR et licence communautaire.
Ligne 2 (Lyon - Marseille) : contraintes temperature dirigee et lot partiel (1,20 ml) ; solution groupage ou affretement frigorifique ; justification ATP FRC en validite, chaine du froid, non-rentabilite d'un vehicule complet.
Ligne 3 (Thiers - Liege) : contraintes vrac granulaire, international, 35 t ; solution citerne silo a dechargement pneumatique (accepter une benne cerealiere etanche et bachee si le candidat justifie la protection du produit) ; justification retenue dans les 0,5 pt de justification : charge utile insuffisante en un seul vehicule, d'ou deux ensembles ou deux rotations, et incompatibilite d'une semi bachee a palettes. Aucun point supplementaire hors bareme.
Ligne 4 (conducteur absent) : contraintes absence de ressource et urgence ; solution sous-traitance/affretement (ou location avec conducteur) ; justification verification de la licence, de l'assurance et de l'attestation de vigilance, contrat type de sous-traitance, maintien de la responsabilite envers le client.
Controle de coherence : 4 x 1,5 = 6 points (le bareme initial prevoyait un bonus de 0,5 pt sur la ligne 3, qui portait le total a 6,5 : il est supprime).$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch03:ex3.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.1] : [À CONFIRMER: les valeurs chiffrées de l'annexe (données d'exploitation HT sur 12 mois : kilométrage annuel, jours d'exploitation, postes de charges, chiffre d'affaires) ne figurent ni dans le champ statement en base ni dans annex_pages/annex_labels (vides) — vérifié par requête SQL. Le corrigé est donc volontairement méthodologique : il faut y injecter les montants de l'annexe PDF d'origine et les résultats numériques attendus, puis repasser needs_review à false. Vérifications faites : max_score = 6 et le barème somme exactement à 6 ; les 4 sous-questions de l'énoncé sont traitées ; la marge de 10 % est bien traitée comme marge sur prix de vente (PV = CR / 0,90). Aucun chiffre réglementaire n'a été inventé ; formulation de la taxe véhicule mise à jour (taxe annuelle sur l'utilisation des véhicules lourds, ex-taxe à l'essieu), sans montant.]
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ. Étude de rentabilité annuelle d'un véhicule (CLARA TRANS SAS). Barème sur 6 points.

Avertissement méthodologique : l'annexe chiffrée (données d'exploitation HT sur 12 mois) n'est pas reproduite dans l'énoncé stocké. Le corrigé ci-dessous fixe la démarche exigée, les formules et la structure de réponse attendue ; le correcteur applique ces formules aux valeurs de l'annexe remise au stagiaire. Aucune valeur numérique n'est inventée.

1. COÛT DE REVIENT ANNUEL DU VÉHICULE (ventilation en trois familles imposée par l'énoncé)

a) Charges variables (proportionnelles au kilométrage) :
- carburant = (consommation aux 100 km / 100) x prix HT du litre x kilométrage annuel ;
- pneumatiques = (prix HT d'un train de pneus / durée de vie kilométrique) x kilométrage annuel ;
- entretien et réparations (part proportionnelle au km) ;
- lubrifiants et AdBlue ;
- péages, s'ils sont rattachés au kilométrage par l'annexe (sinon les traiter en charges de trafic).
Total CV annuelles = somme de ces postes.

b) Charges fixes liées au véhicule (supportées dès la détention, indépendamment du kilométrage) :
- amortissement = (valeur d'acquisition HT hors pneumatiques - valeur résiduelle) / durée d'amortissement ; ou, en location, le loyer de crédit-bail / LLD ;
- charges financières (intérêts d'emprunt) ;
- assurances (RC circulation, marchandises transportées, flotte) ;
- taxes et obligations réglementaires : taxe annuelle sur l'utilisation des véhicules lourds de transport de marchandises (ex-taxe à l'essieu, codifiée au CIBS), carte grise amortie, contrôles techniques ;
- coût du personnel de conduite : salaire brut annuel + charges patronales + frais de déplacement (repas, casse-croûte, découchers). Poste fixe dès lors que le conducteur est affecté à demeure au véhicule ; on le fait apparaître en sous-total distinct à l'intérieur des charges fixes.
Total CF véhicule annuelles = somme de ces postes.

c) Charges de structure (frais généraux de l'entreprise imputés au véhicule) :
- personnel administratif et d'exploitation, direction ;
- locaux (loyers, énergie), télécom, informatique ;
- assurances de l'entreprise, honoraires, communication.
Clé d'imputation au véhicule : celle que retient l'annexe (pourcentage des charges d'exploitation, prorata du nombre de véhicules, ou forfait par véhicule). Toute clé cohérente et explicitée est acceptée.

Coût de revient annuel = Charges variables + Charges fixes véhicule (conduite incluse) + Charges de structure.

2. COÛT DE REVIENT JOURNALIER

Coût de revient journalier = Coût de revient annuel / nombre de jours d'exploitation annuels (jours réellement travaillés par le véhicule figurant à l'annexe, hors congés, week-ends et immobilisations).

3. TERME KILOMÉTRIQUE ET TERME JOURNALIER (expression binôme)

- Terme kilométrique (euros/km) = total des charges variables annuelles / kilométrage annuel. Il mesure le coût d'un kilomètre supplémentaire.
- Terme journalier (euros/jour) = (charges fixes véhicule + charges de structure) / nombre de jours d'exploitation. Il mesure le coût de mise à disposition du véhicule et du conducteur pour une journée, même sans rouler.
Expression binôme : CR = (terme kilométrique x nombre de km) + (terme journalier x nombre de jours).
Contrôle de cohérence exigé : terme km x km annuels + terme journalier x jours annuels doit redonner le coût de revient annuel de la question 1.
Piège : ne jamais diviser les charges fixes par le kilométrage ni les charges variables par les jours.

4. SEUIL DE RENTABILITÉ (dans l'ordre de l'énoncé : jours, kilomètres, CAC)

Principe : le seuil est atteint lorsque la marge sur coût variable couvre exactement les charges fixes (résultat = 0).
Données : CF = charges fixes véhicule + structure ; CV = charges variables annuelles ; CA annuel (annexe, ou recette journalière x jours d'exploitation).
- Marge sur coût variable : MCV = CA - CV.
- Taux de MCV : t = MCV / CA.
- MCV journalière = CA journalier - charges variables journalières (charges variables journalières = terme kilométrique x kilométrage moyen journalier).

o Seuil de rentabilité en nombre de jours d'exploitation : SR jours = CF / MCV journalière, ou de façon équivalente CAC / CA journalier. Arrondi à l'entier SUPÉRIEUR (le seuil doit être atteint). À comparer au nombre de jours d'exploitation prévus.
o Seuil de rentabilité en kilomètres : SR km = SR jours x kilométrage moyen journalier (kilométrage annuel / jours d'exploitation) ; ou directement SR km = CAC / recette moyenne au kilomètre. À comparer au kilométrage annuel.
o Chiffre d'affaires critique : CAC = CF / t. À comparer au CA annuel prévisionnel.
On conclut par la marge de sécurité (CA annuel - CAC), l'indice de sécurité (marge de sécurité / CA x 100) et le point mort (date d'atteinte du seuil dans l'année).

CONTRÔLE DE LA MARGE IMPOSÉE (10 % du prix de vente)
La direction impose une marge commerciale minimale de 10 % SUR LE PRIX DE VENTE.
- Taux de marge réalisé = (CA - coût de revient) / CA x 100. L'exigence est respectée si ce taux est supérieur ou égal à 10 %.
- Prix de vente minimal : PV = coût de revient / (1 - 0,10) = coût de revient / 0,90.
Toute majoration du coût de revient par 1,10 est fausse : elle exprime une marge sur coût de revient, et non sur prix de vente.
Conclusion attendue : le véhicule est rentable si le CA prévisionnel dépasse le CAC ET si le taux de marge sur prix de vente atteint au moins 10 %.$corr$,
  scoring_grid    = $corr$Barème sur 6 points (total = max_score de la question, vérifié).

Q1. Coût de revient annuel — 2 pts
- ventilation correcte des charges variables : 0,75
- charges fixes liées au véhicule, amortissement et personnel de conduite inclus : 0,75
- charges de structure et clé d'imputation explicitée : 0,5
Le total annuel doit être juste (tolérance d'arrondi : 1 euro). Une charge mal classée (ex. carburant en fixe) = -0,25 par erreur, dans la limite du sous-total concerné.

Q2. Coût de revient journalier — 0,5 pt
- division du coût de revient annuel par le nombre de jours d'exploitation de l'annexe, résultat juste : 0,5

Q3. Terme kilométrique et terme journalier — 1,5 pt
- terme kilométrique = charges variables / kilométrage annuel, en euros/km : 0,75
- terme journalier = (charges fixes véhicule + structure) / jours d'exploitation, en euros/jour : 0,75
0 sur la question si les charges fixes sont divisées par le kilométrage (ou l'inverse). Contrôle de cohérence binôme = coût annuel : valorisé, non coté.

Q4. Seuil de rentabilité — 2 pts
- MCV et taux de MCV : 0,5
- seuil de rentabilité en nombre de jours d'exploitation (arrondi à l'entier supérieur) : 0,5
- seuil de rentabilité en kilomètres : 0,5
- chiffre d'affaires critique CAC = CF / t : 0,5

Commentaire final sur la marge de 10 % sur prix de vente (PV = CR / 0,90) : bonus de cohérence sans point supplémentaire ; une logique fausse (CR x 1,10, marge sur coût de revient) est pénalisée de 0,5 sur Q4.
Erreur d'unité (euros/km confondu avec euros/jour) : -0,25 par occurrence.
Une méthode alternative correcte donnant le bon résultat est acceptée.

TOTAL : 2 + 0,5 + 1,5 + 2 = 6 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.2] : [À CONFIRMER: l'annexe des éléments d'exploitation et financiers HT du porteur POR 85 (carburant, pneumatiques, entretien, amortissement, assurances, taxes, salaire conducteur, frais de structure) est absente de la base — vérifié par requête SQL : le statement est tronqué juste avant l'annexe et annex_pages est vide. Seuls 110 000 km/an, 220 jours/an et 784 euros HT/jour sont certains ; les valeurs dérivées (500 km/jour, 172 480 euros de CA annuel, 1,568 euro/km) en découlent par calcul direct et ont été revérifiées. Les résultats numériques des coûts et des seuils doivent être complétés depuis l'annexe d'origine avant de repasser needs_review à false. Vérifications faites : max_score = 6 et le barème somme exactement à 6 ; les formes monôme/binôme/trinôme sont désormais présentées dans l'ordre a) b) c) de l'énoncé ; les deux méthodes exigées en Q2 sont bien distinctes. Aucun chiffre inventé.]
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ. Étude de rentabilité de la tournée du porteur POR 85 (TRANSGO). Barème sur 6 points.

DONNÉES CERTAINES DE L'ÉNONCÉ : 110 000 km parcourus par an ; 220 jours d'exploitation par an ; chiffre d'affaires journalier 784 euros HT.
GRANDEURS DIRECTEMENT DÉDUCTIBLES (à faire figurer, elles conditionnent tout le reste) :
- kilométrage moyen journalier = 110 000 / 220 = 500 km/jour ;
- chiffre d'affaires annuel = 784 x 220 = 172 480 euros HT ;
- recette moyenne au kilomètre = 784 / 500 = 1,568 euro/km (ou 172 480 / 110 000 = 1,568 euro/km).

Avertissement : l'annexe des éléments d'exploitation et financiers HT (montants des postes de charges) n'est pas reproduite dans l'énoncé stocké. Le corrigé donne la démarche et les formules à appliquer aux montants de l'annexe ; aucune valeur de charge n'est inventée.

1. CALCUL DES COÛTS D'EXPLOITATION SOUS LES TROIS FORMES

Étape préalable — classer les charges de l'annexe :
- charges kilométriques (variables) : carburant, pneumatiques, entretien et réparations, lubrifiants et AdBlue, éventuellement péages ;
- charges journalières de détention du véhicule : amortissement (ou loyer), charges financières, assurances, taxes véhicule ;
- charges de personnel de conduite : salaire brut, charges patronales, frais de route ;
- charges de structure : frais généraux imputés au véhicule.
Remarque de méthode : il est conseillé de calculer d'abord le trinôme (le plus fin), puis d'en déduire le binôme par regroupement et le monôme par totalisation. La réponse est présentée ci-dessous dans l'ordre a) b) c) de l'énoncé.

a) Forme monôme — un seul terme, au kilomètre.
- Coût de revient annuel total = charges variables + charges fixes véhicule + personnel de conduite + structure.
- Coût de revient au km = coût de revient annuel / 110 000 km.
Expression : CR = coût au km x nombre de km.

b) Forme binôme — deux termes.
- Terme kilométrique (euros/km) = charges variables annuelles / 110 000.
- Terme journalier (euros/jour) = (charges fixes véhicule + personnel de conduite + structure) / 220.
Expression : CR = (terme km x km) + (terme journalier x jours).

c) Forme trinôme — trois termes.
- Terme kilométrique (euros/km) = charges kilométriques annuelles / 110 000.
- Terme journalier de détention (euros/jour) = charges journalières véhicule annuelles / 220.
- Terme de conduite (euros/jour, ou terme horaire si l'annexe raisonne en heures) = coût annuel du personnel de conduite / 220 (ou / nombre d'heures annuelles).
Les charges de structure sont, selon la présentation de l'annexe, soit ajoutées comme terme journalier complémentaire, soit réparties en pourcentage sur les trois termes ; la solution doit être explicitée.
Expression : CR = (terme km x km) + (terme journalier véhicule x jours) + (terme conduite x jours).

CONTRÔLE DE COHÉRENCE (attendu) : appliquées à 110 000 km et 220 jours, les trois formes doivent redonner le même coût de revient annuel.

2. ANALYSE DE LA RENTABILITÉ (deux méthodes différentes exigées)

Chiffre d'affaires annuel = 784 x 220 = 172 480 euros HT.

Méthode 1 — approche globale par comparaison des coûts et des recettes :
- Résultat annuel = 172 480 - coût de revient annuel.
- Taux de marge sur prix de vente = (CA - coût de revient) / CA x 100.
L'activité est rentable si le résultat est positif.

Méthode 2 — approche unitaire par comparaison au coût de revient journalier (ou kilométrique) :
- Coût de revient journalier = coût de revient annuel / 220 ; comparaison aux 784 euros de recette journalière : la tournée est rentable si 784 > coût de revient journalier.
- Ou : comparaison de la recette au kilomètre (1,568 euro/km) au coût de revient au kilomètre issu de la forme monôme.
Les deux méthodes doivent conduire à la même conclusion ; cette convergence est l'élément attendu.

SEUILS DE RENTABILITÉ. On pose CF = charges fixes annuelles totales (détention véhicule + personnel de conduite + structure) et CV = charges variables annuelles.
- MCV annuelle = 172 480 - CV ; taux de MCV : t = MCV / 172 480.
- MCV journalière = 784 - charges variables journalières, les charges variables journalières valant terme kilométrique x 500 km.
- MCV kilométrique = 1,568 - terme kilométrique.

a) Seuil de rentabilité en kilomètres : SR km = CF / MCV kilométrique, ou SR jours x 500 km, ou CAC / 1,568. À comparer aux 110 000 km annuels.
b) Seuil de rentabilité en jours d'exploitation : SR jours = CF / MCV journalière, ou CAC / 784. Arrondi à l'entier SUPÉRIEUR. À comparer aux 220 jours d'exploitation ; l'écart constitue la marge de sécurité en jours.
c) Chiffre d'affaires critique : CAC = CF / t.

CONCLUSION ATTENDUE : dire explicitement si le CA annuel de 172 480 euros dépasse le CAC, si les 220 jours dépassent le seuil en jours et si les 110 000 km dépassent le seuil en kilomètres ; puis chiffrer la marge de sécurité (172 480 - CAC), l'indice de sécurité (marge de sécurité / 172 480 x 100) et situer le point mort dans l'année.$corr$,
  scoring_grid    = $corr$Barème sur 6 points (total = max_score de la question, vérifié).

Q1. Calcul des coûts d'exploitation — 3 pts
- classement des charges (variables / fixes véhicule / personnel / structure) : 0,5
- a) forme monôme : coût de revient annuel / 110 000 km, en euros/km : 0,5
- b) forme binôme : terme kilométrique + terme journalier regroupé (jours = 220) : 0,75
- c) forme trinôme : trois termes justes, unités correctes, traitement explicite des frais de structure : 1
- contrôle de cohérence entre les trois formes (même coût annuel) : 0,25

Q2. Analyse de la rentabilité — 3 pts
- reconstitution du CA annuel : 784 x 220 = 172 480 euros HT (et/ou 500 km/jour, 1,568 euro/km) : 0,5
- deux méthodes DISTINCTES de vérification de la rentabilité (comparaison globale CA / coût de revient annuel ET comparaison unitaire journalière ou kilométrique) : 0,75 — 0,4 seulement si une seule méthode est développée
- a) seuil de rentabilité en kilomètres : 0,5
- b) seuil de rentabilité en jours d'exploitation (arrondi à l'entier supérieur) : 0,5
- c) chiffre d'affaires critique CAC = CF / taux de MCV : 0,5
- conclusion argumentée avec marge de sécurité / indice de sécurité : 0,25

Pénalités : -0,25 par erreur d'unité (euros/km confondu avec euros/jour) ; -0,25 si les charges fixes sont ramenées au kilomètre pour établir le seuil. Les résultats justes obtenus par une méthode alternative correcte sont acceptés.

TOTAL : 3 + 3 = 6 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.3] : [À CONFIRMER: l'annexe chiffrée du porteur 19 tonnes (kilométrage journalier et annuel, nombre de jours d'exploitation, valeur d'achat et durée d'amortissement, consommation, prix du carburant, coût du conducteur, frais de structure) n'est pas présente en base — vérifié par requête SQL : statement tronqué avant l'annexe, annex_pages vide. Seuls le CA de 679 euros HT/jour, la marge brute minimale de 7 % du prix de vente et la durée contractuelle de 5 ans sont certains. Les résultats numériques (coût de revient, seuils, taux de marge) doivent être complétés depuis l'annexe d'origine avant de repasser needs_review à false. Vérifications faites : max_score = 6 et le barème somme exactement à 6 ; les 3 questions et les sous-questions a) b) c) sont traitées dans l'ordre de l'énoncé ; la marge de 7 % est bien traitée comme marge sur prix de vente (PV = CR / 0,93, et non CR x 1,07). Aucun chiffre inventé.]
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ. Étude de rentabilité d'une tournée régulière en porteur 19 tonnes (DISTRIGO, Clermont-Ferrand, contrat de 5 ans). Barème sur 6 points.

DONNÉES CERTAINES DE L'ÉNONCÉ : chiffre d'affaires prévisionnel 679 euros HT par jour ; marge brute minimale moyenne imposée 7 % du prix de vente ; durée contractuelle de 5 ans — ce qui justifie d'aligner la durée d'amortissement du porteur sur la durée du contrat si l'annexe le prévoit.

Avertissement : l'annexe chiffrée (conditions d'exploitation et postes de charges du porteur 19 tonnes) n'est pas reproduite dans l'énoncé stocké. Le corrigé fournit la démarche, les formules et les critères de correction ; aucune valeur de charge n'est inventée.

1. CALCUL DU COÛT DE REVIENT (trois méthodes)

Étape préalable : reconstituer, à partir de l'annexe, le nombre de jours d'exploitation annuels et le kilométrage annuel (km parcourus par jour x nombre de jours d'exploitation), puis ventiler les charges :
- charges variables (kilométriques) : carburant [(consommation aux 100 km / 100) x prix HT du litre x km annuels], pneumatiques, entretien et réparations, lubrifiants et AdBlue, éventuellement péages ;
- charges fixes de détention du véhicule : amortissement [(valeur d'achat HT hors pneumatiques - valeur de revente) / durée retenue, cohérente avec le contrat de 5 ans] ou loyer, intérêts financiers, assurances, taxes véhicule ;
- charges de personnel de conduite : salaire brut annuel, charges patronales, frais de déplacement ;
- charges de structure : frais généraux imputés au véhicule selon la clé de l'annexe.
Remarque de méthode : le trinôme se calcule en pratique en premier, le binôme s'en déduit par regroupement et le monôme par totalisation. La réponse est présentée ci-dessous dans l'ordre a) b) c) de l'énoncé.

a) Méthode du monôme — un seul terme.
- Coût de revient annuel total = charges variables + charges fixes véhicule + personnel + structure.
- Coût de revient au kilomètre = coût de revient annuel / kilométrage annuel.
CR = coût au km x nombre de km.

b) Méthode du binôme — deux termes.
- Terme kilométrique (euros/km) = charges variables annuelles / kilométrage annuel.
- Terme journalier unique (euros/jour) = (charges fixes véhicule + personnel + structure) / nombre de jours d'exploitation.
CR = (terme km x km) + (terme journalier x jours).

c) Méthode du trinôme — trois termes.
- Terme kilométrique (euros/km) = charges variables annuelles / kilométrage annuel.
- Terme journalier de détention (euros/jour) = charges fixes véhicule annuelles / jours d'exploitation.
- Terme de conduite (euros/jour, ou terme horaire si l'annexe raisonne en heures) = coût annuel du conducteur / jours d'exploitation.
Les frais de structure sont ajoutés selon la présentation retenue (terme journalier complémentaire ou pourcentage appliqué au total) ; le choix doit être explicité.
CR = (terme km x km) + (terme journalier véhicule x jours) + (terme conduite x jours).

CONTRÔLE : les trois méthodes doivent conduire au même coût de revient annuel.

2. ANALYSE DE LA RENTABILITÉ (deux méthodes différentes exigées)

Chiffre d'affaires annuel = 679 euros x nombre de jours d'exploitation annuels de l'annexe.
CF = charges fixes véhicule + personnel de conduite + structure ; CV = charges variables annuelles.
- MCV annuelle = CA annuel - CV ; taux de MCV : t = MCV / CA annuel.
- MCV journalière = 679 - charges variables journalières (= terme kilométrique x km parcourus par jour).
- MCV kilométrique = recette au km (CA annuel / km annuels) - terme kilométrique.

Méthode 1 — analytique, par le taux de marge sur coût variable : CAC = CF / t, puis SR jours = CAC / 679 et SR km = SR jours x km journaliers.
Méthode 2 — par la marge sur coût variable unitaire : SR jours = CF / MCV journalière, SR km = CF / MCV kilométrique, puis CAC = SR jours x 679.
Les deux méthodes doivent donner des résultats identiques aux arrondis près : cette convergence est l'élément attendu.

a) Seuil de rentabilité en kilomètres : nombre de kilomètres à parcourir pour absorber les charges fixes ; à comparer au kilométrage annuel prévu.
b) Seuil de rentabilité en jours d'exploitation : arrondi à l'entier SUPÉRIEUR ; à comparer au nombre de jours d'exploitation prévus.
c) Chiffre d'affaires critique : CAC = CF / t ; à comparer au CA annuel prévisionnel.
Conclusion : marge de sécurité (CA - CAC), indice de sécurité (marge de sécurité / CA x 100) et point mort (date d'atteinte du seuil dans l'année).

3. ANALYSE DE LA MARGE BRUTE (exigence de 7 % du prix de vente)

La direction impose une marge brute minimale moyenne de 7 % DU PRIX DE VENTE.
- Marge brute réalisée = CA - coût de revient, sur une même base (annuelle, ou journalière : 679 - coût de revient journalier).
- Taux de marge sur prix de vente = (CA - coût de revient) / CA x 100 = (679 - coût de revient journalier) / 679 x 100.
- Exigence respectée si ce taux est supérieur ou égal à 7 %.
- Prix de vente minimal correspondant à l'exigence : PV mini = coût de revient / (1 - 0,07) = coût de revient / 0,93.
Toute application d'un coefficient 1,07 au coût de revient est FAUSSE : elle exprime une marge sur coût de revient et non sur prix de vente.
Justification attendue : comparer explicitement le taux obtenu au seuil de 7 %, conclure sur la validation ou non du projet et, si l'exigence n'est pas atteinte, indiquer le prix de vente journalier minimal à négocier avec le client (coût de revient journalier / 0,93) ainsi que les leviers d'action (réduction du coût de revient, augmentation du kilométrage utile, suppression des retours à vide, renégociation de la durée d'amortissement sur les 5 ans du contrat).$corr$,
  scoring_grid    = $corr$Barème sur 6 points (total = max_score de la question, vérifié).

Q1. Calcul du coût de revient — 2,5 pts
- ventilation des charges et reconstitution du kilométrage annuel / des jours d'exploitation : 0,5
- a) méthode du monôme : 0,5
- b) méthode du binôme : 0,75
- c) méthode du trinôme : 0,75
Unités justes exigées (euros/km, euros/jour). Contrôle de cohérence entre les trois méthodes : valorisé, non coté.

Q2. Analyse de la rentabilité — 2,5 pts
- mise en oeuvre effective de DEUX méthodes distinctes et convergentes : 0,75 (0,4 si une seule méthode)
- a) seuil de rentabilité en kilomètres : 0,5
- b) seuil de rentabilité en jours d'exploitation (arrondi à l'entier supérieur) : 0,5
- c) chiffre d'affaires critique : 0,5
- conclusion chiffrée avec marge de sécurité / indice de sécurité : 0,25

Q3. Analyse de la marge brute — 1 pt
- calcul du taux de marge sur prix de vente : (CA - coût de revient) / CA : 0,5
- comparaison au seuil de 7 % et conclusion justifiée, avec prix de vente minimal = coût de revient / 0,93 si l'exigence n'est pas atteinte : 0,5
Le calcul d'une marge sur coût de revient (coefficient 1,07) ne rapporte AUCUN point sur cette question.

Pénalité générale : -0,25 par erreur d'unité.

TOTAL : 2,5 + 2,5 + 1 = 6 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.4] : [À CONFIRMER: l'annexe 1 (conditions d'exploitation définies par le service commercial : distances de la tournée, nombre de semaines d'exploitation, tarif client, salaire et taux de charges patronales, taux d'absentéisme, valeur et durée d'amortissement du véhicule, consommation, prix du carburant, frais de structure) n'est pas stockée en base — vérifié par requête SQL : statement tronqué sur « ANNEXE 1 : A — Conditions d'exploitation », annex_pages vide. Seuls le rythme du lundi au vendredi (5 jours/semaine), le démarrage au 1er janvier et l'affectation exclusive d'un véhicule neuf sont certains. Le NOMBRE DE SEMAINES D'EXPLOITATION ANNUELLES n'est volontairement pas fixé dans ce corrigé (la mention « souvent 47 semaines » de la version précédente a été retirée pour ne pas induire un chiffre non sourcé) : il doit impérativement être repris de l'annexe. Tous les résultats numériques restent à compléter avant de repasser needs_review à false. Vérifications faites : max_score = 6 et le barème somme exactement à 6 ; les 6 questions de l'énoncé sont traitées ; le chaînage Q2 (masse salariale absentéisme compris) vers Q3 (terme de conduite) est explicité. Aucun chiffre inventé.]
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ. Étude économique d'une nouvelle tournée de camionnage (TRMTRANS, Rennes — client TRY PROD). Barème sur 6 points.

DONNÉES CERTAINES DE L'ÉNONCÉ : tournée régulière réalisée du lundi au vendredi, soit 5 jours par semaine ; démarrage au 1er janvier ; véhicule neuf affecté exclusivement à ce trafic.
L'annexe 1 (conditions d'exploitation définies par le service commercial) n'est pas reproduite dans l'énoncé stocké. Le corrigé donne la démarche, les formules et les points de contrôle ; aucune valeur numérique n'est inventée. En particulier, le nombre de semaines d'exploitation annuelles DOIT être relevé dans l'annexe et n'est pas fixé ici.

1. KILOMÉTRAGE HEBDOMADAIRE ET ANNUEL

- Kilométrage hebdomadaire = somme des distances des tournées quotidiennes du lundi au vendredi (ou distance d'une tournée type x 5 jours), trajets d'approche et retours à vide au dépôt inclus s'ils figurent à l'annexe.
- Nombre de semaines d'exploitation annuelles : à RELEVER dans l'annexe (52 semaines diminuées des semaines de congés payés et de fermeture ; la valeur de l'annexe fait foi — ne rien présumer).
- Nombre de jours d'exploitation annuels = nombre de semaines d'exploitation x 5.
- Kilométrage annuel = kilométrage hebdomadaire x nombre de semaines d'exploitation ; contrôle : doit être égal à kilométrage journalier moyen x nombre de jours d'exploitation.

2. COÛT RÉEL DE LA MASSE SALARIALE BRUTE ANNUELLE, ABSENTÉISME COMPRIS

- Salaire brut annuel du conducteur = salaire mensuel brut x 12, majoré des heures supplémentaires, primes conventionnelles et éventuel 13e mois prévus par l'annexe.
- Charges patronales = salaire brut annuel x taux de charges patronales de l'annexe.
- Frais de déplacement (indemnités de repas, casse-croûte, découchers) = nombre d'indemnités x montant unitaire x jours concernés. Ces frais ne sont pas des salaires mais entrent dans le coût du conducteur.
- Coût de l'absentéisme : le véhicule devant rouler tous les jours ouvrés, l'absence du conducteur titulaire impose un remplacement. Surcoût = coût salarial chargé x taux d'absentéisme de l'annexe (ou coût journalier chargé x nombre de jours d'absence à remplacer).
Méthode équivalente et acceptée : appliquer le coefficient (1 + taux d'absentéisme) à la masse salariale chargée.
- Coût réel de la masse salariale = salaire brut + charges patronales + frais de déplacement + surcoût d'absentéisme.

3. COÛTS D'EXPLOITATION SOUS LES TROIS FORMES (ordre de l'énoncé : trinôme, binôme, monôme)

Ventilation préalable : charges variables (carburant, pneumatiques, entretien et réparations, lubrifiants et AdBlue, péages) ; charges fixes de détention (amortissement du véhicule neuf ou loyer, intérêts, assurances, taxes véhicule) ; coût du conducteur calculé en 2 ; frais de structure imputés au véhicule.

o Forme trinôme :
- terme kilométrique (euros/km) = charges variables annuelles / kilométrage annuel ;
- terme journalier de détention (euros/jour) = charges fixes véhicule annuelles / nombre de jours d'exploitation ;
- terme de conduite (euros/jour) = coût réel de la masse salariale annuelle (question 2) / nombre de jours d'exploitation.
Les frais de structure sont ajoutés selon la présentation de l'annexe (terme journalier complémentaire ou pourcentage) ; le choix doit être explicité.
o Forme binôme :
- terme kilométrique inchangé ;
- terme journalier unique = (charges fixes véhicule + coût réel du conducteur + structure) / nombre de jours d'exploitation.
o Forme monôme :
- coût de revient au kilomètre = coût de revient annuel total / kilométrage annuel.
CONTRÔLE : les trois formes doivent redonner le même coût de revient annuel.

4. CHIFFRE D'AFFAIRES HEBDOMADAIRE ET ANNUEL

- CA hebdomadaire = somme des recettes des livraisons de la semaine, calculées selon le tarif de l'annexe (forfait par tournée, prix au kilomètre, prix à la tonne ou par point de livraison, selon la condition commerciale retenue).
- CA annuel = CA hebdomadaire x nombre de semaines d'exploitation.
- On en déduit : CA journalier = CA hebdomadaire / 5 ; recette moyenne au kilomètre = CA annuel / kilométrage annuel.

5. RENTABILITÉ (en kilomètres, en jours d'exploitation, en CAC)

CF = charges fixes véhicule + coût réel du conducteur + structure ; CV = charges variables annuelles.
- MCV annuelle = CA annuel - CV ; taux de MCV : t = MCV / CA annuel.
- MCV journalière = CA journalier - charges variables journalières (= terme kilométrique x kilométrage journalier moyen).

o Seuil de rentabilité en kilomètres = seuil en jours x kilométrage journalier moyen, ou CAC / recette moyenne au km ; à comparer au kilométrage annuel.
o Seuil de rentabilité en jours d'exploitation = CF / MCV journalière, ou CAC / CA journalier ; arrondi à l'entier SUPÉRIEUR ; à comparer au nombre de jours d'exploitation prévus.
o Chiffre d'affaires critique : CAC = CF / t ; à comparer au CA annuel.
La tournée démarrant le 1er janvier, on situe le POINT MORT (date d'atteinte du seuil dans l'année civile, calculée à partir du nombre de jours d'exploitation nécessaires) et on chiffre la marge de sécurité (CA annuel - CAC) et l'indice de sécurité (marge de sécurité / CA annuel x 100).

6. MARGE DÉGAGÉE PAR LE TRAFIC

- Marge brute annuelle (en euros) = CA annuel - coût de revient annuel.
- Taux de marge sur prix de vente = (CA annuel - coût de revient annuel) / CA annuel x 100.
- Marge journalière = CA journalier - coût de revient journalier.
Conclusion attendue : dire si le trafic est bénéficiaire, chiffrer le résultat et le taux de marge, et rappeler que pour obtenir un taux de marge cible x sur le prix de vente, le prix de vente se calcule par PV = coût de revient / (1 - x) et non par majoration du coût de revient de x pour cent. Proposer, le cas échéant, une révision tarifaire ou une optimisation de la tournée (réduction des kilomètres à vide, regroupement des points de livraison).$corr$,
  scoring_grid    = $corr$Barème sur 6 points (total = max_score de la question, vérifié).

Q1. Kilométrage hebdomadaire et annuel — 0,75 pt
- kilométrage hebdomadaire sur 5 jours (lundi-vendredi) : 0,25
- nombre de semaines et de jours d'exploitation retenus conformément à l'annexe : 0,25
- kilométrage annuel juste : 0,25

Q2. Coût réel de la masse salariale brute annuelle, absentéisme compris — 1 pt
- salaire brut annuel : 0,25
- charges patronales : 0,25
- frais de déplacement : 0,25
- prise en compte du surcoût d'absentéisme : 0,25 (0 si l'absentéisme est ignoré)

Q3. Coûts d'exploitation sous trois formes — 1,5 pt
- trinôme : 0,6
- binôme : 0,5
- monôme : 0,4
Unités justes exigées ; contrôle de cohérence entre les trois formes valorisé.

Q4. Chiffre d'affaires hebdomadaire et annuel — 0,75 pt
- CA hebdomadaire (application correcte du tarif de l'annexe) : 0,4
- CA annuel = CA hebdomadaire x nombre de semaines d'exploitation : 0,35

Q5. Rentabilité — 1,5 pt
- marge sur coût variable et taux de MCV : 0,3
- seuil de rentabilité en kilomètres : 0,4
- seuil de rentabilité en jours d'exploitation (arrondi à l'entier supérieur) : 0,4
- chiffre d'affaires critique (CAC) : 0,4

Q6. Marge dégagée par le trafic — 0,5 pt
- marge brute annuelle en euros : 0,25
- taux de marge sur prix de vente et conclusion : 0,25

Pénalités : -0,25 par erreur d'unité (euros/km confondu avec euros/jour) ; -0,25 si le coût du conducteur retenu au Q3 n'est pas celui, absentéisme compris, calculé au Q2.

TOTAL : 0,75 + 1 + 1,5 + 0,75 + 1,5 + 0,5 = 6 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.4' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.5] : [À CONFIRMER: la grille tarifaire MATO MESSAGERIE et la liste des envois sont dans une annexe image (annex_pages) non lisible depuis le statement ; les prix HT chiffrés attendus doivent être renseignés par le formateur à partir de l'annexe 1. Les chiffres 22 et 18 EUR/100 kg de l'exemple sont explicitement illustratifs. Vérifié : max_score = 6, somme du barème = 6. Règles 250 kg/m3, poids réel de référence, arrondi kg supérieur et payant-pour confirmées par le texte de l'énoncé lui-même.]
UPDATE public.question_bank SET
  expected_answer = $corr$COTATION EN MESSAGERIE (MATO MESSAGERIE, Clermont-Ferrand 63)

Méthode à appliquer pour CHAQUE envoi, dans cet ordre :

1) Déterminer le poids réel (somme des poids bruts des colis de l'envoi). C'est le poids de référence : les conditions d'application MATO MESSAGERIE précisent que « le poids pris en compte pour la facturation sera le poids réel ».

2) Déterminer le poids volumétrique, à l'aide du rapport d'équivalence donné en annexe 1 (A - Conditions d'application) : 250 kg/m3.
   Volume total (m3) = longueur x largeur x hauteur x nombre de colis.
   Poids volumétrique (kg) = Volume total (m3) x 250.

3) Retenir le poids taxable = le PLUS ÉLEVÉ entre poids réel et poids volumétrique. L'énoncé est explicite : la facturation volumétrique ne s'applique QUE si le poids volumétrique est supérieur au poids réel (cas des envois légers et volumineux).
   Arrondir le poids de taxation au kilogramme supérieur (règle donnée en annexe).

4) Lire le prix dans la grille tarifaire MATO MESSAGERIE au croisement :
   - de la tranche de poids correspondant au poids taxable,
   - et de la zone / du département de destination (départ Clermont-Ferrand 63).
   Selon la structure de la grille, le prix est soit un forfait (tranches basses, envois de détail), soit un prix aux 100 kg : dans ce cas Prix = (Poids taxable / 100) x prix aux 100 kg, avec application du minimum de perception s'il est prévu.

5) Appliquer la règle du PAYANT-POUR (expressément exigée par l'annexe). Le tarif étant dégressif, on compare le prix obtenu avec le poids taxable réel au prix obtenu en taxant l'envoi au poids plancher de la tranche supérieure. On facture le MOINS-DISANT pour le client : si taxer l'envoi comme s'il pesait le minimum de la tranche supérieure donne un prix inférieur, on facture ce prix (l'envoi est dit « payant pour X kg »).
   Exemple de raisonnement (chiffres purement illustratifs, NON tirés de l'annexe) : envoi taxable de 480 kg ; tranche 100-499 kg à 22 EUR/100 kg ; tranche 500-999 kg à 18 EUR/100 kg. Prix au poids réel = 4,80 x 22 = 105,60 EUR. Prix payant-pour 500 kg = 5,00 x 18 = 90,00 EUR. On facture 90,00 EUR HT (payant pour 500 kg).

6) Ajouter, le cas échéant, les frais et majorations prévus aux conditions d'application (frais de dossier / de sûreté, surcharge gazole, majoration hayon, livraison sur rendez-vous, etc.), puis annoncer le PRIX HT DE L'ENVOI (arrondi monétaire à 2 décimales).

7) Présenter le résultat sous forme de tableau : Envoi / Destination / Poids réel / Volume (m3) / Poids volumétrique / Poids taxable arrondi / Tranche retenue / Prix brut / Payant-pour éventuel / Prix HT retenu.

Points de vigilance attendus du candidat :
- Ne jamais additionner poids réel et poids volumétrique : on retient le plus fort des deux.
- Toujours arrondir le poids de taxation au kg supérieur AVANT lecture de la grille.
- Systématiquement tester le payant-pour à chaque envoi situé en fin de tranche : c'est la clé de l'exercice.
- Vérifier le minimum de perception : le prix facturé ne peut lui être inférieur.

[À CONFIRMER : les valeurs chiffrées finales (prix HT de chaque envoi) dépendent de la grille tarifaire MATO MESSAGERIE et de la liste des envois figurant dans l'annexe 1 (document image joint), non reproduites dans l'énoncé stocké. Le correcteur applique la méthode ci-dessus aux données de l'annexe et confronte les résultats du candidat à son propre corrigé chiffré. En revanche, le rapport 250 kg/m3, l'arrondi au kg supérieur, la primauté du poids réel et l'obligation d'appliquer le payant-pour sont, eux, explicitement donnés par l'énoncé et ne sont pas discutables.]$corr$,
  scoring_grid    = $corr$Barème sur 6 points (à répartir sur l'ensemble des envois de l'annexe) :
- Calcul correct du poids réel de chaque envoi : 0,5 pt
- Calcul correct du volume (m3) de chaque envoi : 1 pt
- Application correcte du rapport d'équivalence 250 kg/m3 et calcul du poids volumétrique : 1 pt
- Choix correct du poids taxable (le plus élevé des deux) et arrondi au kg supérieur : 1 pt
- Lecture correcte de la grille (bonne tranche de poids, bonne zone de destination) : 1 pt
- Application correcte de la règle du payant-pour (comparaison avec le plancher de la tranche supérieure, choix du prix le plus favorable au client) : 1 pt
- Prix HT final juste, présentation claire du tableau de cotation, unités et arrondis monétaires (2 décimales) : 0,5 pt
Total = 6,0 points (= max_score).
Pénalité : erreur de report d'un poids taxable juste vers une mauvaise ligne de grille = -0,5 pt. L'absence totale de test du payant-pour se traduit par la non-acquisition du critère correspondant (1 pt), sans double sanction.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.5' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.6] : [CORRECTION APPORTÉE: la version initiale annonçait « 0,50 ml par palette 80 x 120 » et « 0,60 ml par palette 100 x 120 », valeurs fausses et contradictoires avec sa propre formule ml = surface / 2,40. Les valeurs exactes sont 0,40 ml (EUR 80 x 120 : 0,96 m2 / 2,40) et 0,50 ml (ISO 100 x 120 : 1,20 m2 / 2,40), cohérentes avec les standards 33 europalettes et 26 palettes ISO au sol sur un plancher de 13,60 m.] [À CONFIRMER: la grille tarifaire TDM TPS, la liste des commandes et surtout le rapport d'équivalence kg/mètre linéaire figurent dans une annexe image non lisible depuis la base. La valeur de 1 500 kg/ml est un usage professionnel courant, à valider contre l'annexe avant diffusion aux stagiaires. Vérifié : max_score = 6, somme du barème = 6.]
UPDATE public.question_bank SET
  expected_answer = $corr$COTATION AU MÈTRE LINÉAIRE (TDM TPS, Strasbourg 67) — MARCHANDISES NON GERBABLES

Principe : une marchandise non gerbable occupe la surface au sol du plancher du véhicule sans qu'on puisse superposer d'autres palettes par-dessus. On ne peut donc pas facturer au seul poids réel : on facture l'ESPACE OCCUPÉ, exprimé en mètres linéaires (ml) de plancher, converti en poids taxable au moyen du rapport d'équivalence de la grille.

Méthode à appliquer pour CHAQUE commande :

1) Calculer le nombre de mètres linéaires occupés.
   Largeur utile du plancher d'une semi-remorque standard : 2,40 m (à ne pas confondre avec la largeur hors tout du véhicule, 2,55 m, ou 2,60 m en frigorifique).
   Formule générale : ml = Surface au sol occupée (m2) / 2,40
   Surface au sol d'une palette = longueur x largeur.
   Cas usuels (application directe de la formule) :
   - Palette EUR 80 x 120 : surface 0,96 m2 -> 0,96 / 2,40 = 0,40 ml par palette. Contrôle de cohérence : 13,60 m de plancher / 0,40 = 34, soit les 33 europalettes au sol d'une semi standard.
   - Palette ISO / industrielle 100 x 120 : surface 1,20 m2 -> 1,20 / 2,40 = 0,50 ml par palette. Contrôle : 13,60 / 0,50 = 27, soit les 26 palettes 100 x 120 au sol d'une semi standard.
   Si les palettes étaient gerbables sur 2 niveaux, on diviserait le nombre de ml par 2 ; ici les marchandises sont NON GERBABLES, donc AUCUNE division : chaque palette consomme sa surface au sol pleine.
   Arrondir le nombre de ml selon la règle de la grille (usuellement au 0,1 ml supérieur ; parfois au 0,5 ml supérieur).

2) Convertir les mètres linéaires en poids taxable au moyen du rapport d'équivalence de la grille tarifaire TDM TPS.
   Poids taxable ml (kg) = Nombre de ml x équivalence (kg/ml).
   L'équivalence usuelle du marché est 1 ml = 1 500 kg, mais c'est la valeur de la grille de l'annexe qui fait foi.

3) Retenir le poids de taxation = le PLUS ÉLEVÉ entre :
   - le poids réel de l'envoi,
   - le poids issu du métrage linéaire,
   - le cas échéant, le poids volumétrique si la grille en prévoit un.
   Arrondir au kg supérieur.

4) Lire le prix dans la grille tarifaire au croisement de la tranche de poids taxable et de la zone / du département de destination (départ Strasbourg 67) ; appliquer la règle du payant-pour si le plancher de la tranche supérieure est plus avantageux ; vérifier le minimum de perception.

5) Ajouter les majorations éventuelles prévues aux conditions d'application (surcharge gazole, hayon, majoration « non gerbable » si la grille la prévoit explicitement) et annoncer le MONTANT HT DU TRANSPORT (2 décimales).

6) Présenter un tableau : Commande / Nombre et format de palettes / Surface au sol / ml / Poids équivalent ml / Poids réel / Poids taxable retenu / Tranche / Montant HT.

Points de vigilance attendus :
- Ne pas gerber : une palette non gerbable occupe toujours sa surface au sol complète, quel que soit son poids ou sa hauteur.
- Utiliser la largeur utile de 2,40 m (et non 2,55 m, largeur hors tout réglementaire du véhicule).
- Comparer systématiquement poids réel et poids issu du ml : on facture le plus fort des deux.
- Ne pas oublier le payant-pour et le minimum de perception.

[À CONFIRMER : le rapport d'équivalence exact (kg par mètre linéaire), les tranches, les zones et la grille tarifaire TDM TPS figurent dans l'annexe image, non reproduite ici. La valeur de 1 500 kg/ml doit être remplacée par celle de l'annexe si elle diffère. La liste des commandes (nombre et format de palettes, poids réels, destinations) doit également être lue dans l'annexe.]$corr$,
  scoring_grid    = $corr$Barème sur 6 points :
- Identification du principe de la cotation au mètre linéaire pour marchandise non gerbable (pas de gerbage, surface au sol pleine) : 0,5 pt
- Calcul correct de la surface au sol occupée par les palettes de chaque commande : 1 pt
- Conversion correcte en mètres linéaires (largeur utile 2,40 m ; 0,40 ml pour une palette 80 x 120, 0,50 ml pour une palette 100 x 120) et arrondi conforme à la grille : 1,5 pt
- Conversion des ml en poids taxable via le rapport d'équivalence de la grille : 1 pt
- Comparaison poids réel / poids ml et choix du poids de taxation le plus élevé : 1 pt
- Lecture correcte de la grille, payant-pour et minimum de perception, montant HT final juste et présenté clairement : 1 pt
Total = 6,0 points (= max_score).
Pénalité : gerbage appliqué à tort (division des ml par 2) = -1,5 pt (critère « conversion en ml » non acquis). Utilisation de 2,55 m au lieu de 2,40 m comme largeur utile = -0,5 pt.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.6' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.7] : [CORRECTION APPORTÉE: la version initiale qualifiait de « taux de marque sur coût » la marge exprimée en pourcentage du coût de revient. C'est un contresens : marge sur coût = taux de MARGE ; marge sur prix de vente = taux de MARQUE. Terminologie rectifiée dans le corrigé et le barème.] [À CONFIRMER: aucune donnée chiffrée (coûts unitaires, distances, tonnages, taux et base de marge) n'est disponible dans l'énoncé stocké en base — et cet exercice ne comporte même pas de bloc « Annexe à consulter ». La liste des commandes et les données d'exploitation d'ATLANTIC FRET SERVICES doivent être récupérées auprès du formateur pour établir le corrigé chiffré. Les valeurs 620,00 EUR et 12 % sont explicitement illustratives. Vérifié : max_score = 6, somme du barème = 6 ; les durées 561/2006 citées sont conformes au règlement.]
UPDATE public.question_bank SET
  expected_answer = $corr$COÛT DE REVIENT ET PRIX DE VENTE HT (ATLANTIC FRET SERVICES) — LOTS COMPLETS

Démarche en trois temps pour chaque envoi.

A. RECONSTITUER LE COÛT DE REVIENT (STRUCTURE TRINÔME)
Le coût de revient d'un transport de lot complet se décompose en trois termes :
1) Terme de DISTANCE (charges variables kilométriques) : carburant, pneumatiques, entretien-réparations, lubrifiants.
   Coût de distance = Coût kilométrique unitaire (EUR/km) x Kilométrage total de la mission (aller + retour, ou aller + approche, selon l'énoncé).
2) Terme de TEMPS : il regroupe les charges de détention du véhicule (amortissement, assurances, taxes, frais financiers) et les charges de personnel de conduite (salaires, charges sociales, frais de déplacement).
   Coût de temps = Coût horaire (ou journalier) unitaire x Nombre d'heures (ou de jours) mobilisés par la mission — temps de conduite ET temps de service : chargement, déchargement, attentes.
3) Terme de STRUCTURE : frais généraux et de gestion de l'entreprise, exprimés soit en pourcentage du coût d'exploitation, soit en montant forfaitaire par mission.

Coût de revient de l'envoi = Coût de distance + Coût de temps + Charges de structure
(+ charges directes affectables à la mission : péages, frais de bac, frais d'immobilisation, etc.)

Rappel de vocabulaire attendu : le monôme facture au seul kilomètre ; le binôme combine un terme de distance et un terme de temps ; le trinôme y ajoute un terme fixe / de structure.

B. CALCULER LE PRIX DE VENTE HT
Deux formulations, selon la base de marge retenue par l'énoncé — le candidat doit indiquer EXPLICITEMENT laquelle il applique et la justifier :
- Marge exprimée en pourcentage du COÛT DE REVIENT (taux de marge sur coût) :
  Prix de vente HT = Coût de revient x (1 + taux)
  Exemple (chiffres illustratifs, NON tirés de l'exercice) : coût de revient 620,00 EUR, taux 12 % -> PV HT = 620,00 x 1,12 = 694,40 EUR.
- Marge exprimée en pourcentage du PRIX DE VENTE / du chiffre d'affaires (taux de marque) :
  Prix de vente HT = Coût de revient / (1 - taux)
  Exemple : coût de revient 620,00 EUR, taux de marque 12 % -> PV HT = 620,00 / 0,88 = 704,55 EUR.
Attention à la confusion classique : « % du coût » = taux de MARGE ; « % du prix de vente » = taux de MARQUE. Les deux formules ne donnent pas le même résultat.

C. VÉRIFIER ET COMMENTER
- Cohérence économique : ramener le prix de vente au kilomètre (PV HT / km) et à la tonne (PV HT / tonnage transporté) et comparer aux ordres de grandeur du marché.
- Faisabilité réglementaire de la mission au regard du règlement (CE) n° 561/2006 : conduite continue de 4 h 30 maximum, suivie d'une pause de 45 minutes (fractionnable en 15 min puis 30 min, dans cet ordre) ; conduite journalière de 9 h, portée à 10 h deux fois par semaine au maximum ; conduite hebdomadaire limitée à 56 h et à 90 h sur deux semaines consécutives ; repos journalier de 11 h (réductible à 9 h, trois fois entre deux repos hebdomadaires). Si la mission dépasse ces limites, il faut prévoir un second conducteur (équipage) ou un découcher — ce qui alourdit le terme de temps et donc le coût de revient.
- Présentation en tableau : Envoi / Distance / Temps de service / Coût de distance / Coût de temps / Structure / Coût de revient / Marge / Prix de vente HT.

[À CONFIRMER : les coûts unitaires (coût kilométrique, coût horaire ou journalier, taux de frais de structure, taux et base de marge) ainsi que les caractéristiques des envois (distances, temps, tonnages) figurent dans la liste des commandes et les données d'exploitation d'ATLANTIC FRET SERVICES fournies avec l'exercice, non reproduites dans l'énoncé stocké. Les montants chiffrés attendus doivent être établis à partir de ces données.]$corr$,
  scoring_grid    = $corr$Barème sur 6 points :
- Identification de la structure trinôme du coût de revient (distance / temps / structure) : 0,5 pt
- Calcul correct du terme de distance (kilométrage total de la mission x coût kilométrique) : 1,25 pt
- Calcul correct du terme de temps (heures ou jours mobilisés, y compris chargement, déchargement et attentes, x coût horaire ou journalier) : 1,25 pt
- Prise en compte des charges de structure et des charges directes affectables (péages, frais annexes) : 1 pt
- Coût de revient total juste pour chaque envoi : 1 pt
- Passage correct au prix de vente HT : base de marge explicitée et formule cohérente — x (1 + taux) si marge sur coût de revient, / (1 - taux) si taux de marque sur prix de vente — et résultat juste : 1 pt
Total = 6,0 points (= max_score).
Valorisation (dans la limite du barème, sans dépassement) : la vérification de la faisabilité de la mission au regard du règlement (CE) n° 561/2006 et le commentaire du prix au km ou à la tonne peuvent compenser une imprécision mineure sur un autre critère.
Pénalité : confusion taux de marge / taux de marque non justifiée = -0,5 pt sur le dernier critère.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.7' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.8] : [À CONFIRMER: la grille tarifaire TRANSGO (tranches de tonnage, zones, prix à la tonne, minima de perception) et la liste des commandes sont dans une annexe image non lisible depuis la base ; le corrigé chiffré doit être complété par le formateur. Les chiffres 42 EUR/t et 36 EUR/t de l'exemple sont explicitement illustratifs. Vérifié : max_score = 6, somme du barème = 6 ; TVA 20 % sur le transport intérieur de marchandises, indexation gazole (C. transports, art. L.3222-1) et PTAC 44 t / 5 essieux conformes au référentiel.]
UPDATE public.question_bank SET
  expected_answer = $corr$COTATION AU TARIF PAR TONNE (TRANSGO, Clermont-Ferrand 63) — LOTS COMPLETS ET PARTIELS

Méthode à appliquer pour CHAQUE commande :

1) Qualifier la nature de l'envoi :
   - LOT COMPLET : le véhicule est réservé au seul client, le tonnage approche la charge utile ; taxation sur la base du tonnage transporté (ou du tonnage forfaitaire de la tranche « complet » si la grille en prévoit un).
   - LOT PARTIEL / groupage : plusieurs envois cohabitent dans le véhicule ; taxation au poids réellement remis, tranche par tranche.

2) Déterminer le poids taxable en tonnes.
   - Partir du poids réel de l'envoi, converti en tonnes.
   - Si l'envoi est volumineux et léger, comparer avec le poids volumétrique ou le poids issu du métrage linéaire, lorsque la grille prévoit un tel rapport d'équivalence, et retenir le PLUS ÉLEVÉ.
   - Appliquer l'arrondi prévu par la grille (généralement à la tonne ou à la demi-tonne supérieure).

3) Lire dans la grille tarifaire TRANSGO le prix à la tonne au croisement :
   - de la tranche de tonnage,
   - et de la zone kilométrique ou du département de destination, au départ de Clermont-Ferrand (63).

4) Calculer le prix brut :
   Prix HT = Poids taxable (t) x Prix à la tonne (EUR/t)
   Vérifier le MINIMUM DE PERCEPTION de la tranche : si le prix calculé lui est inférieur, c'est le minimum de perception qui est facturé.

5) Appliquer la règle du PAYANT-POUR, le tarif à la tonne étant dégressif : comparer le prix obtenu au tonnage réel avec le prix obtenu en taxant l'envoi au tonnage plancher de la tranche supérieure. On retient le montant le plus faible pour le client.
   Exemple de raisonnement (chiffres purement illustratifs, NON tirés de l'annexe) : envoi de 9,4 t ; tranche 5 à 9,9 t à 42 EUR/t ; tranche 10 à 14,9 t à 36 EUR/t. Prix au poids réel = 9,4 x 42 = 394,80 EUR ; prix payant-pour 10 t = 10 x 36 = 360,00 EUR. On facture 360,00 EUR HT (payant pour 10 tonnes).

6) Ajouter les majorations et frais annexes prévus aux conditions d'application : surcharge gazole (l'indexation obligatoire du prix du transport sur la variation du gazole est prévue par le code des transports, art. L.3222-1), frais de sûreté, majoration pour matières particulières, immobilisation du véhicule au-delà de la durée franche de chargement ou de déchargement, hayon, livraison sur rendez-vous.

7) Annoncer le montant HT de la cotation, arrondi à 2 décimales, puis, si l'énoncé le demande, le montant TTC (TVA à 20 % sur les prestations de transport intérieur de marchandises).

8) Présenter un tableau récapitulatif : Commande / Destination / Nature (complet ou partiel) / Poids réel / Poids taxable / Tranche et zone / Prix à la tonne / Prix brut / Payant-pour / Majorations / Prix HT.

Points de vigilance attendus :
- Le payant-pour doit être testé pour CHAQUE commande située en fin de tranche : c'est l'attendu principal de l'exercice.
- Ne pas oublier le minimum de perception sur les petits tonnages.
- Ne pas confondre le poids brut de la marchandise et la charge utile du véhicule (rappel : PTAC maximal 44 t à 5 essieux en transport national, soit une charge utile de l'ordre de 25 à 28 t selon le matériel).

[À CONFIRMER : les tranches de tonnage, les zones, les prix à la tonne, les minima de perception et la liste des commandes figurent dans la grille tarifaire TRANSGO en annexe (document image joint), non reproduite ici. Les montants HT attendus doivent être calculés à partir de cette annexe.]$corr$,
  scoring_grid    = $corr$Barème sur 6 points :
- Qualification correcte de chaque envoi (lot complet ou lot partiel) : 0,5 pt
- Détermination correcte du poids taxable en tonnes, avec arrondi conforme à la grille : 1 pt
- Lecture correcte de la grille TRANSGO (bonne tranche de tonnage et bonne zone de destination au départ de Clermont-Ferrand) : 1,5 pt
- Calcul du prix brut (poids taxable x prix à la tonne) : 1 pt
- Application de la règle du payant-pour et du minimum de perception : 1,5 pt
- Prix HT final juste, majorations et frais annexes intégrés, présentation en tableau avec arrondis monétaires à 2 décimales : 0,5 pt
Total = 6,0 points (= max_score).
Pénalité : l'oubli systématique du payant-pour sur les envois de fin de tranche entraîne la non-acquisition du critère correspondant (-1,5 pt), sans double sanction sur les autres critères.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.8' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.9] : [À CONFIRMER : la grille tarifaire de l'annexe n'est pas accessible en base ; le prix HT (Q7) et l'application chiffrée du « payant pour » (Q8) doivent être complétés par le formateur.] Ambiguïté à lever dans l'énoncé : les dimensions sont annoncées « palette comprise » (2,08 m) alors que le tableau de calcul ajoute 0,15 m de hauteur de palette. Les deux hypothèses conduisent au même poids taxable (15 800 kg, dicté par le poids métrique), mais l'énoncé gagnerait à être harmonisé. Vérifié : calculs exacts (2,1408 m³ ; 47,0976 m³ ; 15 542 kg ; 8,80 ml ; 15 752 kg ; 15 800 kg) et somme du barème = 6 = max_score. Aucune donnée réglementaire chiffrée (561/2006, capacité financière, poids/dimensions, L.133-3) n'est mobilisée dans cet exercice.
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ 4.9 - Tarification d'un lot partiel : poids taxable et grille (22 palettes, Issoire vers Collonges-la-Rouge, 260 km)

Rappel de méthode : sur un lot partiel, le poids taxable est le PLUS ÉLEVÉ des trois poids (poids réel, poids volumétrique, poids métrique). Ce poids taxable, arrondi à la centaine de kg supérieure, sert ensuite d'entrée dans la grille tarifaire, croisée avec la tranche kilométrique.

1. Volume unitaire d'une palette (marchandise + support)
En appliquant la formule imposée par le tableau de l'exercice (hauteur + 0,15 m de hauteur de palette) :
0,80 m × 1,20 m × (2,08 + 0,15) = 0,96 × 2,23 = 2,1408 m³, soit environ 2,141 m³ par palette.
(Variante : si l'on retient 2,08 m comme hauteur totale, palette comprise, le volume unitaire est de 0,80 × 1,20 × 2,08 = 1,9968 m³. Cela ne change pas le poids taxable final : voir point 6.)

2. Volume total des 22 palettes
2,1408 × 22 = 47,0976 m³, arrondi à 47,10 m³.
(Variante 2,08 m : 1,9968 × 22 = 43,93 m³.)

3. Poids volumétrique (coefficient 330 kg/m³)
47,0976 × 330 = 15 542,2 kg, soit environ 15 542 kg.
(Variante 2,08 m : 43,93 × 330 = 14 497 kg.)

4. Mètres linéaires (coefficient d'occupation du plancher)
Les palettes EUR 0,80 × 1,20 m sont chargées deux de front : le côté 1,20 m est pris dans la largeur (2 × 1,20 = 2,40 m, soit la largeur utile du plancher) et le côté 0,80 m dans le sens de la longueur. Chaque palette occupe donc 0,80 / 2 = 0,40 ml, conformément à la formule du tableau de l'exercice (22 × 0,40).
Mètres linéaires = 22 × 0,40 = 8,80 ml.

5. Poids métrique (coefficient 1 790 kg/ml)
8,80 × 1 790 = 15 752 kg.

6. Poids taxable
Comparaison des trois poids :
- poids réel : 1 200 kg ;
- poids volumétrique : 15 542 kg (ou 14 497 kg selon la variante de hauteur) ;
- poids métrique : 15 752 kg.
Le poids le plus élevé est le poids métrique : 15 752 kg. Arrondi à la centaine supérieure : POIDS TAXABLE = 15 800 kg (soit 15,8 t). Dans les deux hypothèses de hauteur, c'est le poids métrique qui l'emporte : le résultat est stable.
Commentaire : la marchandise est très légère et très volumineuse (big-bags de plus de 2 m de haut) ; c'est l'encombrement, et non la masse réelle, qui détermine le prix. C'est précisément l'objet des coefficients volumétrique et métrique.

7. Lecture de la grille et prix de vente HT
On entre dans la grille avec le poids taxable de 15 800 kg et la tranche kilométrique correspondant à 260 km (tranches de 25 km : 260 km relève de la tranche 251-275 km, colonne lue à 275 km selon la présentation de la grille).
Prix HT = tarif lu dans la case (en euros pour 100 kg) × 158 (nombre de centaines de kg), ou lecture directe du prix forfaitaire si la grille est exprimée en euros par envoi.
[À CONFIRMER : la grille tarifaire figure en annexe de l'exercice et n'est pas reproduite en base ; le formateur doit reporter la valeur exacte de la case (15 800 kg × tranche 260 km) et effectuer le produit.]

8. Règle du « payant pour »
Principe : la grille étant dégressive, il peut arriver que le prix calculé au poids taxable réel soit SUPÉRIEUR au prix obtenu en facturant au poids plancher de la tranche de poids immédiatement supérieure. Dans ce cas, on retient le prix le plus favorable au client : l'envoi est facturé « payant pour » le poids plancher de la tranche supérieure.
Application : avec 15 800 kg, on compare le prix de la case 15 800 kg au prix de la tranche supérieure calculé à son poids plancher (par exemple 16 000 kg ou la tranche suivante de la grille). Si ce second prix est inférieur, on le retient et l'on porte sur la facture la mention « payant pour 16 000 kg » (ou la tranche effectivement retenue).
[À CONFIRMER : la mise en oeuvre chiffrée du « payant pour » dépend des valeurs de la grille en annexe.]$corr$,
  scoring_grid    = $corr$Barème sur 6 points :
- Q1 volume unitaire correct (0,80 × 1,20 × 2,23 = 2,1408 m³) : 0,5 pt
- Q2 volume total des 22 palettes (47,10 m³) : 0,5 pt
- Q3 poids volumétrique (47,0976 × 330 = 15 542 kg) : 0,75 pt
- Q4 mètres linéaires (22 × 0,40 = 8,80 ml) : 0,75 pt
- Q5 poids métrique (8,80 × 1 790 = 15 752 kg) : 0,75 pt
- Q6 poids taxable = le plus élevé des trois poids, arrondi à 15 800 kg : 1,25 pt (0,75 pt pour la comparaison des trois poids, 0,5 pt pour l'arrondi à la centaine supérieure)
- Q7 lecture correcte de la grille (poids taxable 15 800 kg × tranche 251-275 km) et calcul du prix HT : 1 pt
- Q8 énoncé et application de la règle du « payant pour » (comparaison avec le poids plancher de la tranche supérieure, mention portée sur la facture) : 0,5 pt
Total : 0,5 + 0,5 + 0,75 + 0,75 + 0,75 + 1,25 + 1 + 0,5 = 6 points (= max_score).
Pénalité de 0,25 pt par erreur d'unité ou d'arrondi non répétée. Accepter la variante de hauteur (2,08 m sans ajout des 0,15 m) dès lors que la démarche est juste et que le poids métrique est bien retenu comme poids taxable.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.9' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.10] : Calculs vérifiés : 15,7 / 142,5 = 0,110175 (+11,02 %) ; 4 200 × 28 % = 1 176 euros ; 1 176 × 0,110175 = 129,57 euros ; total HT 4 329,57 euros. Somme du barème = 6 = max_score. [À CONFIRMER : le montant de l'amende pénale (15 000 euros) et la référence exacte de l'article du code des transports qui la prévoit — le chiffre est donné sous réserve dans le corrigé et n'est pas exigé au barème.] Les articles L.3222-1 et L.3222-2 (indexation gazole obligatoire, d'ordre public) et l'indemnité forfaitaire de recouvrement de 40 euros (art. L.441-10 C. com.) sont des ancrages fiables. Correction apportée par rapport à la version précédente : suppression de la mention d'un « droit de rétention » du transporteur sur la marchandise, qui n'est pas reconnu de façon générale au transporteur routier (contrairement au commissionnaire de transport) et constituait une affirmation juridique risquée. Vérifier enfin que le contrat MECA POLE ne prévoit pas un indice CNR autre que l'indice gazole professionnel.
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ 4.10 - Pied de facture carburant (TRANSGOTRM / MECA POLE)

Données : part carburant contractuelle 28 % ; indice CNR gazole de référence 142,5 ; indice CNR du mois de facturation 158,2 ; prix HT de la prestation mensuelle 4 200 euros.

1. Variation de l'indice CNR
Variation = (indice du mois - indice de référence) / indice de référence
= (158,2 - 142,5) / 142,5 = 15,7 / 142,5 = 0,110175, soit +11,02 % (arrondi à deux décimales).
Le gazole a donc augmenté de 11,02 % depuis la signature du contrat.

2. Montant du pied de facture carburant
Étape a : part carburant du prix HT = 4 200 × 28 % = 1 176,00 euros.
Étape b : pied de facture = part carburant × variation de l'indice = 1 176,00 × 0,110175 = 129,57 euros (arrondi au centime ; 129,56 euros si l'on applique le taux arrondi de 11,02 %).
Formule condensée : 4 200 × 28 % × [(158,2 - 142,5) / 142,5] = 129,57 euros.

3. Montant total HT de la facture
Total HT = prix de la prestation + pied de facture carburant = 4 200,00 + 129,57 = 4 329,57 euros HT.
(TVA 20 % : 865,91 euros ; TTC : 5 195,48 euros, si la question de la TVA est posée.)
Sur la facture, les deux éléments doivent apparaître distinctement : d'une part le prix de transport HT, d'autre part la ligne de variation de la charge de carburant. La facture doit en effet faire apparaître les charges de carburant supportées par l'entreprise pour la réalisation de l'opération de transport.

4. Sanction encourue par un client qui refuserait de payer ce supplément
- L'indexation du prix du transport sur la variation du prix du gazole est une disposition d'ordre public du code des transports (articles L.3222-1 et L.3222-2). Elle s'applique de plein droit : le client ne peut pas y renoncer contractuellement et une clause contraire est réputée non écrite. Le refus de payer le pied de facture est donc dépourvu de fondement juridique.
- Conséquence civile : le transporteur peut poursuivre le recouvrement de la somme en justice (action en paiement, injonction de payer), avec les pénalités de retard applicables entre professionnels (taux contractuel, au minimum trois fois le taux d'intérêt légal) et l'indemnité forfaitaire de recouvrement de 40 euros par facture (art. L.441-10 du code de commerce).
- Conséquence pénale : le fait, pour le donneur d'ordre, de méconnaître l'obligation de répercussion des variations du prix du gazole est sanctionné par une amende prévue par le code des transports (montant de l'ordre de 15 000 euros). [À CONFIRMER : montant exact de l'amende et référence précise de l'article de sanction — ne pas énoncer le chiffre comme certain devant les stagiaires sans vérification du texte en vigueur.]
- Le transporteur peut également suspendre l'exécution des prestations futures en cas de non-paiement persistant, dans les conditions prévues au contrat ou au contrat type applicable.$corr$,
  scoring_grid    = $corr$Barème sur 6 points :
- Q1 formule de la variation d'indice posée correctement [(158,2 - 142,5) / 142,5] : 0,5 pt ; résultat +11,02 % (ou 0,110175) : 0,5 pt. Sous-total 1 pt
- Q2 part carburant 4 200 × 28 % = 1 176 euros : 0,75 pt ; pied de facture 1 176 × 11,02 % = 129,57 euros : 0,75 pt. Sous-total 1,5 pt
- Q3 total HT = 4 200 + 129,57 = 4 329,57 euros : 1 pt ; présentation en deux lignes distinctes sur la facture (prix de transport / variation de la charge carburant) : 0,5 pt. Sous-total 1,5 pt
- Q4 caractère d'ordre public de l'indexation gazole (art. L.3222-1 et L.3222-2 du code des transports), clause contraire réputée non écrite, refus non fondé : 1 pt ; sanction encourue : sanction pénale prévue par le code des transports (amende) et/ou pénalités de retard + indemnité forfaitaire de 40 euros : 1 pt. Sous-total 2 pts
Total : 1 + 1,5 + 1,5 + 2 = 6 points (= max_score).
Tolérance d'arrondi acceptée entre 129,56 et 129,57 euros (donc total HT entre 4 329,56 et 4 329,57 euros). Le point « sanction » est acquis dès lors que le stagiaire cite soit la sanction pénale, soit les pénalités de retard et l'indemnité de 40 euros ; le montant exact de l'amende n'est pas exigible.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.10' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.1] : [À CONFIRMER : le prix du transport principal Clermont-Ferrand vers Lille résulte de l'exercice 4.8 (grille tarifaire en annexe) et n'est pas disponible en base ; le formateur doit reporter le montant exact dans le corrigé et dans le total HT.] Incohérence de l'énoncé à harmoniser : le contexte nomme le client « TECHNIBOIS » alors que les données fournies et l'adresse mail indiquent « TECHNOBOIS » (b.martin@technobois.fr) ; l'adresse de l'entreprise comporte également une coquille (« 145 avenue de Charles de Gaull »). Vérifié : somme du barème = 6 = max_score ; 52,13 + 52,13 = 104,26 euros HT ; aucune donnée réglementaire chiffrée à risque (les seules références citées, L.3222-1/L.3222-2 pour le gazole et le délai de paiement de 30 jours à compter de l'émission de la facture en transport, sont des ancrages fiables).
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ 5.1 - Offre commerciale positive (EUROFRET LOGISTIQUE vers TECHNOBOIS)

Attendus : un e-mail professionnel, structuré et personnalisé, reprenant l'intégralité des éléments de l'étude tarifaire de l'exercice 4.8 et engageant l'entreprise (prix HT détaillé, durée de validité, conditions de règlement, CGV).

PROPOSITION DE CORRIGÉ

De : service.exploitation@eurolog.fr
À : b.martin@technobois.fr
Objet : Offre de transport Clermont-Ferrand vers Lille - votre demande - notre référence dossier TR25-532

Monsieur Martin,

Nous vous remercions de la confiance que vous témoignez à EUROFRET LOGISTIQUE et avons le plaisir de vous adresser notre proposition pour l'acheminement de votre envoi entre Clermont-Ferrand et Lille.

1. Caractéristiques de la prestation
- Enlèvement : TECHNOBOIS, 117 avenue Pasteur, 63000 Clermont-Ferrand, le 23/03/20AA à 10h00.
- Livraison : Lille, le 23/03/20AA avant 15h00.
- Nature de l'envoi et poids taxable : conformément aux éléments communiqués et à notre étude tarifaire de référence (exercice 4.8).
- Moyens affectés : ensemble routier adapté et conducteur qualifié.

2. Conditions financières (prix HT)
- Prix du transport principal (lecture de la grille : poids taxable × tranche kilométrique Clermont-Ferrand/Lille, étude 4.8) : ......... euros HT.
- Chargement par le conducteur, 1 heure : 52,13 euros HT.
- Déchargement par le conducteur, 1 heure : 52,13 euros HT.
- Sous-total des prestations annexes : 104,26 euros HT.
- TOTAL HT : prix du transport + 104,26 euros HT.
- TVA 20 % et total TTC calculés sur ce montant.
Ce prix s'entend hors variation du prix du gazole : la répercussion de cette variation s'applique de plein droit conformément aux articles L.3222-1 et L.3222-2 du code des transports.

3. Conditions de l'offre
- Validité de l'offre : 30 jours à compter de ce jour.
- Prestation soumise, à défaut de convention écrite, au contrat type applicable (contrat type « général » pour les envois de moins de trois tonnes ou de trois tonnes et plus, selon la nature de l'envoi).
- Règlement à 30 jours à compter de la date d'émission de la facture (délai légal maximal en transport, art. L.441-11 du code de commerce).
- Nos conditions générales de vente sont jointes au présent message.

Nous restons à votre disposition pour tout ajustement (horaires, hayon, prise de rendez-vous). Pour confirmer, il vous suffit de nous retourner ce message avec la mention « bon pour accord » en rappelant notre référence TR25-532.

Dans l'attente de votre retour, nous vous prions d'agréer, Monsieur Martin, l'expression de nos salutations distinguées.

[Prénom NOM]
Gestionnaire de transport
EUROFRET LOGISTIQUE
145 avenue Charles de Gaulle, 63000 Clermont-Ferrand
service.exploitation@eurolog.fr

POINTS CLÉS ATTENDUS DU STAGIAIRE
- Objet d'e-mail explicite mentionnant la référence dossier TR25-532.
- Reprise exacte des coordonnées de l'expéditeur (EUROFRET LOGISTIQUE, 145 avenue Charles de Gaulle, 63000 Clermont-Ferrand) et du destinataire (M. Bernard MARTIN, b.martin@technobois.fr).
- Rappel des dates et heures confirmées : chargement le 23/03/20AA à 10h00, livraison le 23/03/20AA avant 15h00.
- Chiffrage complet et détaillé, ligne par ligne, en HT, avec les deux prestations annexes à 52,13 euros (soit 104,26 euros).
- Mention de la durée de validité de l'offre et des conditions de règlement.
- Ton commercial positif, formule d'appel, formule de politesse, signature complète.$corr$,
  scoring_grid    = $corr$Barème sur 6 points :
- Forme de l'e-mail : expéditeur, destinataire, objet explicite avec la référence TR25-532, formule d'appel, formule de politesse, signature complète : 1,5 pt
- Rappel exact de la prestation : adresses d'enlèvement et de livraison, date et heure de chargement (23/03/20AA à 10h00), livraison (23/03/20AA avant 15h00) : 1 pt
- Chiffrage détaillé : prix du transport issu de l'étude 4.8 : 1 pt ; chargement 52,13 euros et déchargement 52,13 euros correctement ajoutés (104,26 euros) : 0,75 pt ; total HT exact (et TVA/TTC) : 0,75 pt. Sous-total 2,5 pts
- Conditions de l'offre : durée de validité, conditions de règlement, référence au contrat type ou aux CGV, indexation gazole : 0,5 pt
- Qualité rédactionnelle : ton commercial positif, orthographe, syntaxe, absence de familiarité : 0,5 pt
Total : 1,5 + 1 + 2,5 + 0,5 + 0,5 = 6 points (= max_score).
Le prix du transport principal (issu de la grille de l'exercice 4.8) est noté sur la cohérence de la démarche : le point est acquis si le montant repris est celui de l'étude 4.8 et s'il est correctement additionné aux prestations annexes.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ 5.2 - Réponse négative argumentée (EUROFRET LOGISTIQUE vers MÉTAL AUVERGNE)

Attendus : un e-mail qui refuse la date demandée sans jamais fermer la relation commerciale. Structure de référence : remerciement, annonce claire du refus, motif factuel et objectif, solution alternative précise et datée, engagement, formule de politesse. Le refus doit être sans ambiguïté sur la date du 23/03/20AA, mais formulé positivement.

PROPOSITION DE CORRIGÉ

De : service.exploitation@eurolog.fr
À : [contact] MÉTAL AUVERGNE
Objet : Votre demande d'enlèvement du 23/03/20AA (5 fardeaux de barres métalliques) - notre proposition de report au 26/03/20AA

Madame, Monsieur,

Nous vous remercions de votre confiance et de votre demande d'enlèvement de 5 fardeaux de barres métalliques le 23/03/20AA à 9h00.

Après étude technique de votre dossier, cette opération requiert un véhicule plateau certifié pour un chargement par grue, seul matériel apte à garantir la sécurité de l'arrimage et la conformité de votre envoi. Or notre unique plateau habilité, immatriculé SREM-03, est immobilisé pour visite technique jusqu'au 25/03/20AA. Nous ne sommes donc pas en mesure d'assurer l'enlèvement à la date souhaitée, et nous préférons vous en informer immédiatement plutôt que de nous engager sur une date que nous ne pourrions pas tenir.

Nous vous proposons la solution suivante :
- enlèvement le 26/03/20AA sur votre site (heure à convenir, par exemple 9h00) ;
- véhicule plateau SREM-03, chargement par grue, arrimage conforme, conducteur habilité ;
- prix et conditions inchangés par rapport à notre proposition initiale.

Si cette date ne convenait pas à vos impératifs de production, nous pouvons étudier avec vous une solution de substitution : affrètement auprès d'un confrère disposant d'un plateau adapté au chargement par grue, ou aménagement du créneau de mise à quai. N'hésitez pas à nous indiquer votre préférence.

En vous renouvelant nos regrets pour ce contretemps et en vous remerciant de votre compréhension, nous vous prions d'agréer, Madame, Monsieur, l'expression de nos salutations distinguées.

[Prénom NOM]
Gestionnaire de transport
EUROFRET LOGISTIQUE
145 avenue Charles de Gaulle, 63000 Clermont-Ferrand
service.exploitation@eurolog.fr

POINTS CLÉS ATTENDUS DU STAGIAIRE
- Refus explicite de la date du 23/03/20AA, sans faux-fuyant ni ambiguïté.
- Motif technique, objectif et vérifiable : plateau certifié pour chargement par grue indispensable ; SREM-03 en visite technique jusqu'au 25/03/20AA.
- Argument de sécurité et de responsabilité (refus de charger sur un matériel inadapté), qui valorise le professionnalisme du transporteur.
- Solution alternative concrète et datée : enlèvement le 26/03/20AA, matériel et conditions tarifaires identiques.
- Ouverture (affrètement, autre créneau) et maintien de la relation commerciale.
- Ton courtois, formulation positive (préférer « nous vous proposons » à « nous ne pouvons pas »).$corr$,
  scoring_grid    = $corr$Barème sur 6 points :
- Forme de l'e-mail : expéditeur, destinataire, objet explicite mentionnant la demande et le report, formule d'appel, formule de politesse, signature : 1,5 pt
- Annonce claire et sans ambiguïté du refus de la date du 23/03/20AA : 1 pt
- Motif objectif et argumenté : nécessité d'un plateau certifié pour chargement par grue, indisponibilité du SREM-03 en visite technique jusqu'au 25/03/20AA, argument sécurité et arrimage : 1,5 pt
- Solution alternative précise : enlèvement le 26/03/20AA, même matériel et mêmes conditions, proposition d'horaire : 1,5 pt
- Qualité rédactionnelle et maintien de la relation commerciale : formulation positive, regrets exprimés, ouverture à d'autres solutions, orthographe : 0,5 pt
Total : 1,5 + 1 + 1,5 + 1,5 + 0,5 = 6 points (= max_score).
Retirer 1 pt si la réponse laisse planer un doute sur la faisabilité au 23/03/20AA ; retirer 1 pt si aucune alternative datée n'est proposée.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.3] : Vérifié sur l'énoncé : le prix de transport est bien « à reporter par l'élève » (donnée de l'ex. 4.8) et la seule prestation annexe fournie est « Déchargement conducteur : 1h → 52,13 € HT ». Barème = 6 pts = max_score. [À CONFIRMER: le « modèle d'e-mail ci-dessous » à compléter figure dans l'annexe non chargée ; la trame proposée peut différer du gabarit exact attendu (rubriques imposées). À CONFIRMER: le taux de TVA attendu (20 %, taux normal métropole) et le délai de paiement retenu (30 jours, plafond légal du secteur transport) si l'annexe impose d'autres conditions.]
UPDATE public.question_bank SET
  expected_answer = $corr$OFFRE COMMERCIALE PAR E-MAIL (dossier TR25-118, Société ALPINA)

1) Structure attendue de l'e-mail

De : service.exploitation@eurolog.fr
À : s.lambert@alpina-sa.fr
Objet : Offre commerciale, transport Clermont-Ferrand / Lyon, dossier TR25-118

Madame LAMBERT,

Suite à votre demande, nous avons le plaisir de vous adresser notre proposition tarifaire pour l'opération suivante.

- Client : Société ALPINA, 28 rue des Artisans, 63000 Clermont-Ferrand
- Nature de la marchandise : pièces mécaniques, 8 palettes EUR
- Enlèvement : Clermont-Ferrand, le 14/04/20AA à 8h30
- Livraison : Lyon, le 14/04/20AA avant 17h00
- Référence dossier : TR25-118

Détail de la proposition (HT) :
- Transport principal Clermont-Ferrand / Lyon : prix de vente HT calculé à l'exercice 4.8 (coût de revient majoré de la marge). L'énoncé indique expressément « Prix transport (ex. 4.8) : à reporter par l'élève » : ce montant est donc une donnée à reporter, il n'est pas à recalculer ici.
- Déchargement par le conducteur (1 h) : 52,13 euros HT (seule prestation annexe fournie par l'énoncé).
- Total HT = prix transport (ex. 4.8) + 52,13 euros HT
- TVA 20 % (taux normal, France métropolitaine) : total HT x 0,20
- Total TTC : total HT x 1,20

Conditions :
- Prix hors taxes, valable 30 jours, hors gazole (indexation gazole obligatoire, art. L.3222-1 du code des transports).
- Prestation exécutée sous le régime du contrat type général applicable aux transports publics routiers de marchandises (à défaut de convention écrite).
- Paiement à 30 jours date d'émission de la facture (plafond légal propre au transport, art. L.441-11 du code de commerce).
- Toute heure d'attente ou de manutention supplémentaire sera facturée en sus.

Restant à votre disposition pour tout complément, nous vous prions d'agréer, Madame, l'expression de nos salutations distinguées.

[Prénom NOM]
Gestionnaire de transport, EUROFRET LOGISTIQUE
service.exploitation@eurolog.fr

2) Points de méthode évalués
- Reprise fidèle des données du dossier (destinataire, trajet, dates et heures, 8 palettes EUR, référence TR25-118).
- Report du prix calculé en 4.8 sans le recalculer, augmenté de la seule prestation annexe facturable dans ce dossier : le déchargement conducteur (1 h = 52,13 euros HT).
- PIÈGE : aucune livraison sur rendez-vous n'est demandée ici (contrairement à l'exercice 5.4). Facturer une prestation de rendez-vous serait une erreur ; de même, la durée de déchargement est de 1 h, il n'y a donc aucune proratisation à faire (52,13 euros HT et non 2 x 52,13).
- Distinction HT / TVA / TTC.
- Mention des conditions commerciales : validité de l'offre, indexation gazole, contrat type, délai de paiement.
- Registre professionnel : formule d'appel, corps structuré, formule de politesse, signature.$corr$,
  scoring_grid    = $corr$Barème sur 6 points :
- Objet, destinataire et rappel complet des éléments du dossier (trajet, dates et heures, 8 palettes EUR, réf. TR25-118) : 1,5 pt
- Report correct du prix de transport calculé à l'exercice 4.8 : 1 pt
- Ajout et libellé de la prestation annexe, déchargement conducteur 1 h = 52,13 euros HT (sans facturer de rendez-vous, non demandé dans ce dossier) : 1 pt
- Total HT, TVA 20 %, total TTC calculés correctement : 1 pt
- Conditions commerciales (validité de l'offre, indexation gazole, contrat type, paiement à 30 jours) : 1 pt
- Qualité rédactionnelle et présentation professionnelle (formule d'appel, structure, politesse, signature) : 0,5 pt

Total : 1,5 + 1 + 1 + 1 + 1 + 0,5 = 6 points (= max_score).$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.4] : Vérifié sur l'énoncé : le contexte indique explicitement « 18 palettes, ce qui nécessite 2 heures de manutention par le conducteur », et les données fournies sont « Déchargement conducteur : 1h → 52,13 € HT / Livraison sur rendez-vous : 35,00 € HT ». La proratisation 2 x 52,13 = 104,26 € HT et l'addition 104,26 + 35,00 = 139,26 € HT sont donc confirmées. Barème = 6 pts = max_score. [À CONFIRMER: l'énoncé chargé ne dit pas littéralement que la livraison est « sur rendez-vous » ; la mention du tarif de rendez-vous dans les données fournies (absent du dossier ALPINA de l'ex. 5.3) le sous-entend fortement, mais l'annexe non chargée doit le confirmer. À CONFIRMER: le taux de TVA (20 %) et le gabarit exact du modèle d'e-mail à compléter, qui figure dans l'annexe.]
UPDATE public.question_bank SET
  expected_answer = $corr$OFFRE COMMERCIALE PAR E-MAIL (dossier TR25-274, BATI PRO)

1) Structure attendue de l'e-mail

De : service.exploitation@eurolog.fr
À : j.renard@batipro.fr
Objet : Offre commerciale, transport Clermont-Ferrand / Toulouse, dossier TR25-274

Monsieur RENARD,

Nous vous remercions de votre consultation et avons le plaisir de vous adresser notre proposition pour l'opération suivante.

- Client : BATI PRO, 54 boulevard de l'Industrie, 63100 Clermont-Ferrand
- Nature de la marchandise : matériaux de chantier, 18 palettes EUR
- Enlèvement : Clermont-Ferrand, le 07/05/20AA à 7h00
- Livraison : Toulouse, le 08/05/20AA avant 12h00, sur rendez-vous
- Référence dossier : TR25-274

Détail de la proposition (HT) :
- Transport principal Clermont-Ferrand / Toulouse : prix de vente HT calculé à l'exercice 4.8 (donnée « à reporter par l'élève »).
- Manutention par le conducteur : le tarif fourni est de 52,13 euros HT pour 1 heure ; l'énoncé précise que les 18 palettes nécessitent 2 heures de manutention, d'où 2 x 52,13 = 104,26 euros HT.
- Livraison sur rendez-vous : 35,00 euros HT.
- Total HT = prix transport (ex. 4.8) + 104,26 + 35,00 = prix transport + 139,26 euros HT
- TVA 20 % : total HT x 0,20
- Total TTC : total HT x 1,20

Conditions :
- Prix hors taxes, valable 30 jours, hors gazole (indexation gazole obligatoire, art. L.3222-1 du code des transports).
- Prestation soumise au contrat type général applicable aux transports publics routiers de marchandises.
- Livraison effectuée sur rendez-vous ; tout dépassement du temps de mise à disposition contractuel donnera lieu à facturation d'attente.
- Paiement à 30 jours date de facture (art. L.441-11 du code de commerce).

Nous restons à votre disposition et vous prions d'agréer, Monsieur, l'expression de nos salutations distinguées.

[Prénom NOM]
Gestionnaire de transport, EUROFRET LOGISTIQUE
service.exploitation@eurolog.fr

2) Points de méthode évalués
- PIÈGE PRINCIPAL : le tarif de manutention est donné pour 1 heure (52,13 euros HT). Le contexte précise que 18 palettes exigent 2 heures : il faut donc proratiser (2 x 52,13 = 104,26 euros HT) et non reprendre 52,13 euros tel quel.
- La livraison sur rendez-vous (35,00 euros HT) est facturée en sus : c'est la seconde prestation annexe fournie par l'énoncé, et son ajout constitue précisément la différence avec le dossier ALPINA (ex. 5.3).
- Arithmétique : 104,26 + 35,00 = 139,26 euros HT de prestations annexes, à ajouter au prix de transport reporté de l'exercice 4.8, avant TVA à 20 %.
- L'opération se déroule sur deux jours (chargement le 07/05 à 7h00, livraison le 08/05 avant 12h00). Ce séquencement est compatible avec le règlement CE 561/2006 : conduite journalière limitée à 9 heures (10 h deux fois par semaine au maximum) et repos journalier de 11 heures (réductible à 9 heures, trois fois entre deux repos hebdomadaires) intercalé entre les deux journées.$corr$,
  scoring_grid    = $corr$Barème sur 6 points :
- Objet, destinataire et rappel complet des éléments du dossier (trajet, dates et heures, 18 palettes EUR, réf. TR25-274) : 1,5 pt
- Report correct du prix de transport calculé à l'exercice 4.8 : 1 pt
- Manutention conducteur proratisée à 2 heures : 2 x 52,13 = 104,26 euros HT : 1,5 pt
- Facturation de la livraison sur rendez-vous : 35,00 euros HT : 0,5 pt
- Total HT (prix transport + 139,26 euros), TVA 20 %, total TTC exacts : 1 pt
- Conditions commerciales et qualité rédactionnelle (validité, gazole, contrat type, paiement, politesse, signature) : 0,5 pt

Total : 1,5 + 1 + 1,5 + 0,5 + 1 + 0,5 = 6 points (= max_score).$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.4' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.5] : Vérifié sur l'énoncé : les quatre consignes internes (sous-traitants référencés, marge 12 % minimum sur le prix de vente client, mention du rendez-vous, horaires impérativement renseignés) sont bien celles du texte, et les coordonnées de TRANSGO LOGISTIQUE sont reprises à l'identique. Barème = 6 pts = max_score. Aucune valeur chiffrée n'a été inventée. [À CONFIRMER: la grille tarifaire, la liste des sous-traitants référencés et le détail des expéditions à traiter figurent dans l'annexe non chargée ; le corrigé ne fournit que la méthode et la trame. À CONFIRMER: l'interprétation de la marge de 12 % « sur le prix de vente client » (taux de marge rapporté au prix de vente, d'où coût maximal = PV x 0,88, et non taux de marque rapporté au coût d'achat qui donnerait coût = PV / 1,12), qui conditionne le plafond de coût d'affrètement.]
UPDATE public.question_bank SET
  expected_answer = $corr$CONFIRMATION D'AFFRÈTEMENT, TRANSGO LOGISTIQUE

Méthode en trois temps, à appliquer à chaque expédition (les trois étapes du travail à réaliser).

Étape 1, choisir le sous-traitant
- Consigne interne impérative : ne retenir qu'un transporteur figurant sur la liste des sous-traitants référencés par TRANSGO LOGISTIQUE.
- Vérifier l'adéquation avec l'expédition : zone géographique desservie, carrosserie et matériel requis (bâché à rideaux coulissants, frigorifique ATP, plateau, hayon, grue), capacité en charge utile et en nombre de palettes, disponibilité aux dates et heures demandées.
- À qualité de service égale, retenir le sous-traitant dont le prix d'achat permet de respecter la marge minimale de l'entreprise.

Étape 2, calculer le coût d'affrètement et contrôler la marge
- Lire dans la grille tarifaire fournie le prix correspondant à la relation (départ / destination) et à la tranche de poids ou de nombre de palettes, puis ajouter les majorations éventuelles (rendez-vous, attente, hayon, retour à vide).
- Contrôle de la marge, consigne interne : la marge commerciale de TRANSGO est de 12 % minimum sur le prix de vente client.
  Marge = Prix de vente client moins Coût d'affrètement.
  Taux de marge = (Prix de vente moins Coût d'affrètement) / Prix de vente >= 12 %.
  Le coût d'affrètement ne doit donc pas dépasser 88 % du prix de vente :
  Coût maximal admissible = Prix de vente x 0,88.
  Exemple de raisonnement (méthode, sans valeur inventée) : pour un prix de vente client de 1 000 euros HT, le coût d'affrètement maximal est de 1 000 x 0,88 = 880 euros HT ; un sous-traitant à 900 euros HT serait refusé (taux de marge = (1000 - 900) / 1000 = 10 %, inférieur à 12 %).
- Si le coût du sous-traitant dépasse ce plafond : retenir un autre sous-traitant référencé, renégocier le prix d'achat, ou revoir le prix de vente avec le client.

Étape 3, compléter la confirmation d'affrètement (mentions attendues)
- Identification de l'affréteur (donneur d'ordre) : TRANSGO LOGISTIQUE, 145 avenue Édouard Michelin, 63100 Clermont-Ferrand, tél. 04 73 88 52 10, exploitation@transgo-logistique.fr.
- Identification du sous-traitant (voiturier) : raison sociale, adresse, contact, numéro de licence.
- Numéro et date de la confirmation, référence du dossier / de l'expédition.
- Lieu et adresse de chargement, DATE ET HEURE de chargement (consigne interne : horaires impérativement renseignés).
- Lieu et adresse de livraison, DATE ET HEURE de livraison, avec mention expresse « LIVRAISON SUR RENDEZ-VOUS » lorsque c'est le cas (consigne interne).
- Nature de la marchandise, nombre et type de colis ou palettes, poids, volume, mètres linéaires, conditionnement.
- Type de véhicule exigé et matériel imposé (hayon, sangles, ATP, grue).
- Prix d'achat convenu HT, régime gazole (indexation, art. L.3222-1 du code des transports), conditions et délai de paiement (30 jours, art. L.441-11 du code de commerce).
- Consignes particulières : instructions de manutention, documents à retourner (lettre de voiture signée, bon de livraison émargé), délai de retour des documents, obligation de signaler tout incident sans délai.
- Cadre juridique : opération soumise au contrat type sous-traitance ; interdiction pour le sous-traitant de sous-traiter à son tour sans accord écrit de TRANSGO ; fourniture de l'attestation de vigilance URSSAF, des attestations d'assurance et de la copie de la licence de transport.
- Signature et cachet des deux parties, retour de la confirmation signée avant exécution.

Application attendue
Pour chaque expédition de l'annexe, le candidat doit : nommer le sous-traitant retenu et justifier ce choix (référencé, matériel et zone adaptés, disponible) ; présenter le calcul du coût d'affrètement issu de la grille (prix de base plus majorations) ; vérifier explicitement que le taux de marge atteint au moins 12 % du prix de vente (coût <= PV x 0,88) ; produire la confirmation complète, horaires de chargement et de livraison renseignés et mention du rendez-vous éventuel.$corr$,
  scoring_grid    = $corr$Barème sur 6 points :
- Choix d'un sous-traitant référencé, justifié par l'adéquation véhicule / zone / capacité / disponibilité, pour chaque expédition : 1,5 pt
- Calcul du coût d'affrètement à partir de la grille tarifaire, majorations comprises : 1,5 pt
- Contrôle de la marge minimale de 12 % du prix de vente (marge = PV moins coût d'achat ; coût maximal admissible = PV x 0,88) et conclusion motivée : 1 pt
- Confirmation d'affrètement complète : identification des deux parties, référence, marchandise, type de véhicule, prix HT, conditions de paiement, consignes et retour des documents : 1,5 pt
- Respect des deux consignes internes formelles : horaires de chargement et de livraison renseignés, mention explicite de la livraison sur rendez-vous : 0,5 pt

Total : 1,5 + 1,5 + 1 + 1,5 + 0,5 = 6 points (= max_score).$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.5' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch06:ex6.1] : CORRECTION IMPORTANTE par rapport à la version précédente : l'énoncé chargé donne les FCO au 03/06/20AB, 19/04/20AD et 10/12/20AC, toutes postérieures au 18/03/20AA avec la convention de datation 20AA < 20AB < 20AC < 20AD. Aucune FCO n'est donc échue : il était erroné d'écarter un conducteur pour ce motif. Le seul critère discriminant est le repos journalier jusqu'à 14h. [À CONFIRMER: la mention « REPOS JOURNALIER jusqu'à 14h » suit immédiatement la ligne de Martin LACHAUD dans l'énoncé ; elle lui est donc rattachée dans le corrigé, mais la mise en page d'origine (annexe/tableau) doit le confirmer — si elle se rapporte à un autre conducteur, l'affectation nominative de la commande 532 change (le véhicule et la logique restent identiques).] [À CONFIRMER: les dates de FCO peuvent, dans certains sujets, désigner la date de la DERNIÈRE FCO suivie et non l'échéance ; dans cette lecture, une FCO passée depuis plus de 5 ans écarterait le conducteur — l'annexe doit préciser l'intitulé exact de la colonne.] [À CONFIRMER: la capacité de 33 palettes EUR au sol retenue pour un semi de 13,60 m (SREM-01 / SREM-03) et le fait que SREM-03, désigné comme plateau, ne dispose pas d'une grue auxiliaire ; l'énoncé ne mentionne aucun équipement de grue.]
UPDATE public.question_bank SET
  expected_answer = $corr$AFFECTATION DES MOYENS, jeudi 18/03/20AA

Moyens disponibles rappelés par l'énoncé
Véhicules : TRR-01 + SREM-01 (semi FOURGON, CU 29 t) ; TRR-02 + SREM-03 (semi PLATEAU, CU 27 t) ; PORT-02 (porteur FRIGORIFIQUE ATP FRC, CU 8,5 t).
Conducteurs : Jean-Paul LEBLANC (CE, FIMO valide, FCO 03/06/20AB) ; Thierry MULLER (CE, FCO 19/04/20AD) ; Martin LACHAUD (CE, FCO 10/12/20AC), en REPOS JOURNALIER jusqu'à 14h.

Analyse des conducteurs (à faire avant toute affectation)
- Les trois conducteurs sont titulaires du permis CE : aucun n'est écarté sur ce critère.
- FCO : la qualification initiale (FIMO) est complétée par une FCO à renouveler tous les 5 ans. Avec la convention de datation de l'énoncé (20AA = année en cours, puis 20AB, 20AC, 20AD pour les années suivantes), les trois échéances de FCO (03/06/20AB, 19/04/20AD, 10/12/20AC) sont TOUTES postérieures au 18/03/20AA : aucune FCO n'est échue, aucun conducteur n'est écarté à ce titre. Le candidat doit néanmoins procéder au contrôle et le justifier.
- Disponibilité (règl. CE 561/2006) : le repos journalier est de 11 heures consécutives, réductible à 9 heures trois fois entre deux repos hebdomadaires. Martin LACHAUD est en repos journalier jusqu'à 14h : il ne peut prendre aucun service avant 14h, donc aucun chargement matinal. Seuls LEBLANC et MULLER sont mobilisables sur la journée complète.

Commande 532, Clermont-Ferrand vers Montpellier : 34 palettes de pièces mécaniques, 780 kg, déchargement à quai.
- Poids : 780 kg, sans difficulté au regard de charges utiles de 27 à 29 t.
- Déchargement à quai : compatible avec l'ouverture arrière du semi fourgon TRR-01 + SREM-01. C'est le véhicule adapté (marchandise protégée, quai).
- Difficulté : un semi standard de 13,60 m reçoit 33 palettes EUR au sol (3 rangées de 11) ; 34 palettes dépassent donc la capacité au sol. L'affectation en moyens propres n'est possible que si une palette au moins est gerbable, ce qui est plausible compte tenu de la très faible densité (780 kg au total), mais doit être confirmé par le client / l'expéditeur.
- Affectation retenue : TRR-01 + SREM-01, conducteur Jean-Paul LEBLANC (CE, FIMO et FCO valides, disponible dès le matin). À défaut d'accord sur le gerbage, la palette excédentaire part en groupage ou l'expédition est affrétée.

Commande 528, Moulins vers Bari (Italie) : 2 groupes électrogènes, 6 500 kg, manutention par grue.
- Le poids (6,5 t) serait compatible avec le plateau TRR-02 + SREM-03 (CU 27 t), et le plateau est bien la carrosserie adaptée à des colis lourds manutentionnés par grue.
- IMPOSSIBILITÉ en moyens propres, pour deux motifs : (1) aucun véhicule disponible n'est équipé d'une grue auxiliaire, alors que la manutention par grue est imposée ; (2) il s'agit d'un transport international longue distance (Moulins vers le sud de l'Italie, environ 1 800 km) qui immobilise véhicule et conducteur plusieurs jours, ce qui est incompatible avec une affectation sur la seule journée du 18/03 et avec les temps de conduite du règlement CE 561/2006 (9 h de conduite journalière, 10 h deux fois par semaine au maximum).
- Solution alternative : AFFRÈTEMENT d'un transporteur sous-traitant référencé disposant d'un plateau avec grue auxiliaire (ou d'un porte-engins) et pratiquant la relation France-Italie ; à défaut, faire intervenir un prestataire de levage aux deux extrémités et confier le transport à un affrété spécialisé.

Commande 540, Issoire vers Collonges : 22 palettes EUR de sucre en poudre, déchargement latéral.
- IMPOSSIBILITÉ en moyens propres : le déchargement latéral exige un semi bâché à rideaux coulissants (tautliner) ou un plateau. Or (1) le fourgon TRR-01 + SREM-01 n'ouvre que par l'arrière et est de toute façon affecté à la commande 532 ; (2) le porteur frigorifique PORT-02 est hors sujet (CU 8,5 t et capacité en palettes très inférieure à 22 palettes de sucre, denrée dense) ; (3) le plateau TRR-02 + SREM-03 autoriserait bien un déchargement latéral mais ne protège pas une denrée alimentaire des intempéries et des souillures, ce qui est incompatible avec du sucre en poudre.
- Solution alternative : AFFRÈTEMENT d'un transporteur référencé disposant d'un semi bâché à rideaux coulissants (tautliner), seul matériel permettant à la fois la protection de la denrée et le déchargement latéral ; à défaut, négocier avec le client un déchargement par l'arrière à quai, ce qui permettrait alors d'utiliser un fourgon.

SynthÈse
- 532 : affectée en moyens propres, TRR-01 + SREM-01 + LEBLANC (sous réserve du gerbage de la 34e palette).
- 528 : impossible en moyens propres (pas de grue, international longue distance) → affrètement d'un plateau-grue ou porte-engins référencé.
- 540 : impossible en moyens propres (aucun tautliner au parc) → affrètement d'un tautliner référencé, ou renégociation du mode de déchargement.
- Martin LACHAUD, en repos journalier jusqu'à 14h, ne peut être affecté à aucun chargement du matin ; Thierry MULLER reste disponible en réserve.$corr$,
  scoring_grid    = $corr$Barème sur 6 points :
- Commande 532 : véhicule fourgon TRR-01 + SREM-01 retenu, déchargement à quai justifié, et identification de la contrainte des 34 palettes (au-delà des 33 palettes EUR au sol d'un semi de 13,60 m) avec solution (gerbage, ou groupage / affrètement du reliquat) : 1,5 pt
- Commande 528 : identification de l'impossibilité (aucun véhicule équipé de grue auxiliaire ; relation internationale longue distance incompatible avec une affectation sur la journée) : 1 pt ; solution alternative pertinente (affrètement d'un plateau-grue ou porte-engins référencé, ou prestataire de levage) : 0,5 pt
- Commande 540 : identification de l'impossibilité (fourgon incompatible avec un déchargement latéral et déjà affecté ; frigo PORT-02 sous-dimensionné, CU 8,5 t ; plateau inadapté à une denrée alimentaire) : 1 pt ; solution alternative pertinente (affrètement d'un tautliner, ou renégociation du mode de déchargement) : 0,5 pt
- Contrôle des conducteurs : permis CE, contrôle de la validité FIMO / FCO (renouvellement tous les 5 ans ; ici les trois échéances 20AB, 20AC, 20AD sont postérieures au 18/03/20AA, donc valides), et prise en compte du repos journalier de 11 h du règl. CE 561/2006 pour écarter Martin LACHAUD (repos jusqu'à 14h) de toute opération matinale : 1 pt
- Raisonnement structuré (véhicule, puis conducteur, puis conclusion), cohérence d'ensemble, aucun moyen affecté deux fois le même jour : 0,5 pt

Total : 1,5 + 1 + 0,5 + 1 + 0,5 + 1 + 0,5 = 6 points (= max_score).$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch06:ex6.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$CONCLUSION GÉNÉRALE : NON, TRANSROADSTAR ne peut pas être affrété en l'état au 18/03/20AA. Le dossier administratif comporte une anomalie bloquante : l'attestation de vigilance URSSAF est périmée.

1) ANALYSE DOCUMENT PAR DOCUMENT (au 18/03/20AA)

• Extrait Kbis, émis le 15/02/20AA : CONFORME. Il date de moins d'un mois. L'usage professionnel (et la plupart des cahiers des charges) exige un Kbis de moins de trois mois : le document est donc exploitable. Il atteste l'existence juridique de l'entreprise, son immatriculation au RCS et l'identité du dirigeant.

• Licence communautaire, valide jusqu'au 22/08/20AB : CONFORME. Elle est valable bien au-delà de la date de la mission. Elle est indispensable ici car la relation Clermont-Ferrand vers Porto est un transport international : une licence de transport intérieur ne suffirait pas. Rappel : une copie conforme de la licence doit se trouver à bord du véhicule.

• Attestation d'assurance RC, valide jusqu'au 30/06/20AA : CONFORME. Elle couvre la période de la mission. Vérifier toutefois qu'elle couvre bien la responsabilité contractuelle du transporteur et les marchandises transportées à l'international.

• Attestation de vigilance URSSAF, émise le 14/09/20AB, soit le 14/09 de l'année précédente : NON CONFORME. L'attestation de vigilance a une durée de validité de six mois. Émise le 14/09 de l'année N-1, elle est périmée depuis le 14/03/20AA, soit quatre jours avant la date du contrôle. Anomalie bloquante.

• Attestation de vigilance fiscale (régularité fiscale), émise le 01/03/20AA : CONFORME. Elle date de moins d'un mois.

2) POURQUOI L'ANOMALIE EST BLOQUANTE

Le donneur d'ordre est tenu d'une obligation de vigilance (articles L.8222-1 et D.8222-5 du Code du travail) : pour tout contrat d'un montant au moins égal à 5 000 euros HT, il doit se faire remettre par son cocontractant une attestation de vigilance à jour, puis la renouveler tous les six mois jusqu'à la fin de l'exécution du contrat. À défaut, le donneur d'ordre encourt la solidarité financière en cas de travail dissimulé du sous-traitant : il peut être tenu au paiement des cotisations sociales, majorations et pénalités, des rémunérations dues, et au remboursement des aides publiques perçues. S'y ajoutent la responsabilité pénale du dirigeant et le risque de perte d'honorabilité professionnelle.

3) PROCÉDURE À SUIVRE EN CAS D'ANOMALIE

a) Ne pas confirmer l'affrètement : aucun ordre de transport, aucune confirmation d'affrètement n'est émis tant que la situation n'est pas régularisée.
b) Contacter immédiatement TRANSROADSTAR par écrit (courriel avec accusé de réception) et exiger une attestation de vigilance URSSAF de moins de six mois.
c) Contrôler l'authenticité du document reçu sur le site urssaf.fr à l'aide du code de sécurité figurant sur l'attestation. Cette vérification est obligatoire et doit être tracée.
d) Si le document est fourni et authentifié : mettre à jour le dossier sous-traitant, enregistrer la date du contrôle et la prochaine échéance (six mois), puis poursuivre la procédure d'affrètement (négociation, confirmation écrite, instructions, planning).
e) Si le document n'est pas fourni, est refusé ou révèle une dette sociale : renoncer à l'affrètement et rechercher un autre sous-traitant référencé, la mission étant urgente. Le cas échéant, suspendre TRANSROADSTAR du panel.
f) Dans tous les cas : archiver les pièces et la preuve du contrôle, l'entreprise devant pouvoir démontrer sa vigilance lors d'un contrôle URSSAF ou DREETS.

4) TABLEAU DE SYNTHÈSE
Extrait Kbis 15/02/20AA : CONFORME — moins de 3 mois (usage professionnel).
Licence communautaire 22/08/20AB : CONFORME — valide et adaptée à l'international (Clermont-Fd → Porto).
Attestation assurance RC 30/06/20AA : CONFORME — couvre la période de la mission.
Attestation URSSAF 14/09/20AB (année N-1) : NON CONFORME — périmée depuis le 14/03/20AA (validité 6 mois).
Attestation fiscale 01/03/20AA : CONFORME — récente.$corr$,
  scoring_grid    = $corr$Total 6 points.

1. Analyse des 5 documents (2,5 pts) : 0,5 pt par document correctement qualifié conforme ou non conforme AVEC justification (Kbis récent ; licence communautaire valide et adaptée à l'international ; assurance RC couvrant la mission ; URSSAF périmée ; attestation fiscale récente). Aucun point si la seule mention O/N est portée sans justification.

2. Identification de l'anomalie bloquante et calcul de la péremption (1,5 pt) : attestation de vigilance URSSAF émise le 14/09 de l'année N-1, validité 6 mois, donc périmée depuis le 14/03/20AA au regard du 18/03/20AA (1 pt) ; conclusion explicite « non, l'affrètement est impossible en l'état » (0,5 pt).

3. Enjeu juridique (1 pt) : obligation de vigilance du donneur d'ordre pour tout contrat d'au moins 5 000 euros HT, à renouveler tous les 6 mois (0,5 pt) ; risque de solidarité financière en cas de travail dissimulé, paiement des cotisations et pénalités, remboursement des aides (0,5 pt).

4. Procédure de régularisation (1 pt) : suspendre l'affrètement (0,25) ; demander par écrit une attestation de moins de 6 mois (0,25) ; vérifier l'authenticité sur urssaf.fr via le code de sécurité (0,25) ; à défaut de régularisation, renoncer et recourir à un autre sous-traitant référencé, avec traçabilité et archivage (0,25).

Contrôle du barème : 2,5 + 1,5 + 1 + 1 = 6 points = max_score.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch06:ex6.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$ORDRE CHRONOLOGIQUE DE LA PROCÉDURE D'AFFRÈTEMENT PONCTUEL

1. Identifier précisément les caractéristiques de l'opération.
On ne peut ni rechercher ni négocier sans un cahier des charges clair : nature et poids de la marchandise, nombre et type de supports, volume et mètres linéaires de plancher, type de véhicule et d'équipement exigés (tautliner, température dirigée, hayon, ADR), lieux et dates de chargement et de livraison, horaires et rendez-vous imposés, valeur de la marchandise, régime juridique applicable (contrat type national ou Convention CMR à l'international).

2. Rechercher un sous-traitant disponible et adapté.
Consultation du panel de transporteurs affrétés référencés, puis à défaut d'une bourse de fret. Le sous-traitant doit être adapté (matériel, zone géographique, qualifications, agréments) et disponible aux dates voulues.

3. Vérifier la situation administrative du sous-traitant.
Contrôle préalable et impératif AVANT tout engagement : licence de transport (intérieur ou communautaire selon la relation), extrait Kbis, attestation d'assurance RC, attestation de vigilance URSSAF de moins de six mois (vérifiée sur urssaf.fr), attestation de régularité fiscale. Cette étape précède la négociation : on ne négocie pas avec un sous-traitant que l'on ne pourra pas retenir.

4. Négocier et convenir du prix de l'affrètement.
Négociation du prix et des conditions (délais de paiement, frais d'attente, pénalités, gazole). Le prix doit préserver la marge de l'affréteur et ne pas être abusivement bas.

5. Émettre et transmettre la CONFIRMATION D'AFFRÈTEMENT.
Document écrit qui matérialise le contrat de sous-traitance et engage les deux parties : identité des parties, référence de l'opération, marchandise, lieux et dates, prix convenu, conditions particulières. C'est la preuve du contrat en cas de litige.

6. Transmettre toutes les instructions nécessaires au sous-traitant.
Instructions d'exécution : adresses exactes, contacts sur site, codes et horaires d'accès, consignes de manutention et d'arrimage, documents à faire signer (lettre de voiture ou CMR), consignes en cas d'incident, exigences de suivi et de preuve de livraison.

7. Reporter l'opération sur le planning.
Enregistrement de l'affrètement dans le planning d'exploitation : suivi de l'opération, traçabilité, relance, puis rapprochement de la facture du sous-traitant avec la confirmation d'affrètement.

RÉPONSE SYNTHÉTIQUE (dans l'ordre de la liste de l'énoncé)
Reporter l'opération sur le planning = 7
Négocier et convenir du prix de l'affrètement = 4
Émettre et transmettre la confirmation d'affrètement = 5
Vérifier la situation administrative du sous-traitant = 3
Identifier précisément les caractéristiques de l'opération = 1
Rechercher un sous-traitant disponible et adapté = 2
Transmettre toutes les instructions nécessaires au sous-traitant = 6

Rappel de fond : l'affrètement ne dégage pas l'affréteur de sa responsabilité de transporteur contractuel vis-à-vis de son client.$corr$,
  scoring_grid    = $corr$Total 6 points.

1. Numérotation des 7 étapes (3,5 pts) : 0,5 pt par étape correctement positionnée (1 Identifier les caractéristiques ; 2 Rechercher un sous-traitant ; 3 Vérifier la situation administrative ; 4 Négocier le prix ; 5 Émettre la confirmation d'affrètement ; 6 Transmettre les instructions ; 7 Reporter sur le planning). Plafond 3,5 pts.

2. Justification de l'antériorité du contrôle administratif sur la négociation (1 pt) : le candidat explique qu'on n'engage pas la négociation avec un sous-traitant dont la situation n'est pas vérifiée (obligation de vigilance, risque de solidarité financière).

3. Rôle de la confirmation d'affrètement (1 pt) : écrit qui matérialise le contrat de sous-traitance, engage les parties et sert de preuve en cas de litige (0,5) ; contenu attendu, prix, dates, marchandise, conditions particulières (0,5).

4. Rôle du report au planning (0,5 pt) : suivi de l'opération, traçabilité et rapprochement ultérieur avec la facture du sous-traitant.

Tolérance : si le candidat intervertit les étapes 3 et 4 (négociation avant contrôle administratif), retirer 1 pt sur le bloc 1 et refuser le point du bloc 2, sans autre pénalité.

Contrôle du barème : 3,5 + 1 + 1 + 0,5 = 6 points = max_score.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch06:ex6.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch06:ex6.4] : [À CONFIRMER : les annexes de l'exercice 6.4 (fiche client SUPRAMA, cahier des charges, commandes, liste des véhicules et disponibilités, liste des conducteurs et planning des absences, liste des transporteurs affrétés référencés) ne sont pas présentes dans l'énoncé stocké en base. Le corrigé est donc méthodologique : les affectations nominatives (quel conducteur, quel véhicule, pour quelle commande), le choix précis du sous-traitant pour la commande n°306 et le prix d'affrètement doivent être complétés à partir des annexes du sujet original avant publication.] [À CONFIRMER : l'intitulé de la question 1 est tronqué dans l'énoncé stocké (« À l'aide de l'… numéros d'ordre. ») — restaurer le libellé complet avant publication, il conditionne la formulation exacte de la partie 1 du corrigé.] Vérifications faites : somme du barème = 3,5 + 2,5 = 6 = max_score ; règles 561/2006 conformes aux anchors ; gabarits conformes (16,50 m / 18,75 m / 2,55 m — 2,60 m frigo / 44 t sur 5 essieux) — formulation « poids total roulant autorisé 44 t » retenue car il s'agit d'un ensemble articulé (le PTAC 44 t vise le véhicule ou l'ensemble selon le cas). Aucun chiffre inventé.
UPDATE public.question_bank SET
  expected_answer = $corr$AVERTISSEMENT : l'énoncé stocké renvoie à des annexes (fiche client SUPRAMA, cahier des charges, commandes allers et retours, liste des véhicules et disponibilités, liste des conducteurs et planning des absences, liste des transporteurs affrétés référencés) qui ne sont pas reproduites, et l'intitulé de la question 1 est tronqué (« À l'aide de l'… numéros d'ordre. »). Le corrigé ci-dessous fixe la méthode attendue et les règles de contrôle ; les affectations nominatives, le choix du sous-traitant et le prix d'affrètement doivent être renseignés à partir des annexes du sujet original.

PARTIE 1 : PLANIFIER LES ENVOIS SUPRAMA (affectation véhicules et conducteurs, par numéro d'ordre)

1) Dépouiller les commandes. Pour chaque commande : numéro d'ordre, référence, lieu et date de chargement, lieu et date de livraison, poids, nombre de palettes, mètres linéaires, contraintes particulières (température dirigée, hayon, ADR, rendez-vous imposé, horaires d'ouverture). Identifier allers et retours pour construire des rotations et limiter les kilomètres à vide.

2) Contrôler la faisabilité matérielle. Compatibilité marchandise / véhicule : type de carrosserie, charge utile (PTAC ou PTRA diminué de la tare), volume et mètres linéaires disponibles. Rappels de gabarit en national : longueur maximale 16,50 m pour un ensemble tracteur + semi-remorque et 18,75 m pour un train double (véhicule + remorque) ; largeur 2,55 m, portée à 2,60 m pour les véhicules à température dirigée ; hauteur non limitée par le code de la route mais contrainte par le gabarit routier (usage 4,00 m) ; poids total roulant autorisé 44 t sur 5 essieux en transport national. Écarter tout envoi qui conduirait à une surcharge.

3) Contrôler la faisabilité réglementaire (règlement CE 561/2006) pour chaque conducteur pressenti :
- conduite continue de 4 h 30 maximum, puis pause de 45 minutes, fractionnable en 15 minutes puis 30 minutes ;
- conduite journalière de 9 h, portée à 10 h deux fois par semaine au maximum ;
- conduite hebdomadaire de 56 h maximum et 90 h sur deux semaines consécutives ;
- repos journalier de 11 h, réductible à 9 h trois fois entre deux repos hebdomadaires ;
- repos hebdomadaire de 45 h, réductible à 24 h avec compensation.
En déduire l'amplitude et le temps de service et vérifier que l'heure de mise à quai est atteignable sans infraction. Si la mission n'est pas réalisable par un seul conducteur sur la journée, prévoir une coupure, un découché, un relais ou un équipage.

4) Contrôler la disponibilité des ressources. Croiser le planning des absences (congés, arrêts, formations) et celui des véhicules (contrôle technique, entretien, immobilisation, véhicule déjà affecté). Un conducteur absent ou un véhicule indisponible interdit l'affectation.

5) Affecter et arbitrer. Attribuer à chaque commande, dans l'ordre des numéros d'ordre, un conducteur et un véhicule compatibles, en optimisant le taux de remplissage et les retours en charge. Les envois non couvrables en propre (pas de véhicule ou pas de conducteur disponible, destination hors zone, urgence) basculent en affrètement. Justifier chaque affectation par écrit : commande, véhicule, conducteur, motif, respect des temps de conduite et de la charge utile.

PARTIE 2 : AFFRÉTER LA COMMANDE N°306, RÉFÉRENCE B325, À DESTINATION DE MADRID (annexe 2)

1) Justifier le recours à l'affrètement : destination internationale (Espagne) hors zone d'exploitation habituelle, absence de véhicule ou de conducteur disponible sur la période, ou coût prohibitif d'un retour à vide.

2) Sélectionner le transporteur affrété dans la liste des sous-traitants référencés (annexe 2), en retenant celui qui réunit tous les critères : il dessert la zone Espagne / péninsule ibérique ; il dispose du matériel adapté à la référence B325 (carrosserie, charge utile, volume) ; il est disponible aux dates de chargement et de livraison ; son prix est le plus favorable à qualité de service égale, sans être abusivement bas.

3) Contrôler impérativement, avant tout engagement, sa situation administrative : licence de transport communautaire en cours de validité (obligatoire à l'international), extrait Kbis, attestation d'assurance RC couvrant l'international, attestation de vigilance URSSAF de moins de six mois vérifiée sur urssaf.fr, attestation de régularité fiscale.

4) Négocier le prix d'affrètement, puis émettre une confirmation d'affrètement écrite : identité des parties, référence de la commande, nature et poids de la marchandise, lieux et dates de chargement et de livraison, prix convenu, conditions particulières.

5) Transmettre les instructions et les documents : lettre de voiture CMR (le transport France vers Espagne relève de la Convention CMR), coordonnées et contacts sur site, consignes de chargement et d'arrimage, exigences de preuve de livraison.

6) Reporter l'opération sur le planning d'exploitation, assurer le suivi jusqu'à la livraison, puis rapprocher la facture du sous-traitant de la confirmation d'affrètement.

Point de vigilance : l'affrètement ne dégage pas RAPID ROUTE de sa responsabilité. En qualité de transporteur contractuel, RAPID ROUTE demeure responsable de la bonne exécution du transport vis-à-vis de SUPRAMA.$corr$,
  scoring_grid    = $corr$Total 6 points.

PARTIE 1 : planification des envois (3,5 pts)
- Exploitation des commandes et identification des contraintes de chaque envoi (poids, palettes, mètres linéaires, dates, contraintes particulières) : 0,5 pt.
- Contrôle de la faisabilité matérielle : compatibilité véhicule / marchandise, charge utile et volume, absence de surcharge, gabarit respecté (16,50 m semi ; 18,75 m train double ; 2,55 m de large, 2,60 m en température dirigée ; 44 t sur 5 essieux) : 0,75 pt.
- Contrôle de la faisabilité réglementaire (règlement CE 561/2006) : conduite continue 4 h 30 puis pause 45 min (fractionnable 15 + 30), conduite journalière 9 h (10 h deux fois par semaine), hebdomadaire 56 h et 90 h sur deux semaines, repos journalier 11 h (réductible à 9 h, trois fois entre deux repos hebdomadaires), repos hebdomadaire 45 h (réductible à 24 h avec compensation) : 1 pt (0,5 pt si au moins trois règles sont correctement citées ; 1 pt si elles sont effectivement appliquées aux missions).
- Croisement des disponibilités humaines (planning des absences) et matérielles (indisponibilités véhicules) : 0,75 pt.
- Affectation effective conducteur et véhicule pour chaque commande, par numéro d'ordre, avec justification écrite : 0,5 pt.

PARTIE 2 : affrètement de la commande n°306 réf. B325 vers Madrid (2,5 pts)
- Justification du recours à l'affrètement (destination internationale hors zone ou absence de ressource disponible) : 0,5 pt.
- Choix motivé du transporteur affrété parmi les référencés : zone desservie, matériel adapté, disponibilité, prix : 0,75 pt.
- Contrôle préalable de la situation administrative du sous-traitant, dont la licence communautaire et l'attestation de vigilance URSSAF de moins de six mois : 0,75 pt.
- Formalisation par une confirmation d'affrètement écrite, transmission des instructions et de la lettre de voiture CMR, report au planning : 0,5 pt.

Pénalité : toute affectation générant une infraction aux temps de conduite ou une surcharge annule le point d'affectation correspondant.

Contrôle du barème : 3,5 + 2,5 = 6 points = max_score.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch06:ex6.4' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch07:ex7.1] : [À CONFIRMER : les montants exacts des amendes et la classe de contravention applicables à chaque défaut de document à bord (copie conforme de la licence communautaire, carte conducteur, CQC, etc.) n'ont volontairement pas été chiffrés, conformément à la règle de non-invention. Si le formateur souhaite afficher des montants, les faire valider sur la base du Code des transports et du Code de la route en vigueur en 2026.] [À CONFIRMER : le régime de l'attestation/carte verte d'assurance — la vignette d'assurance n'est plus obligatoire sur le pare-brise en France depuis avril 2024 (contrôle par le Fichier des véhicules assurés) ; vérifier la formulation retenue dans le support de cours avant publication, l'énoncé continuant de lister « attestation d'assurance » comme document de la pochette de bord.] [À CONFIRMER : le régime précis des obligations de déclaration de détachement applicable en 2026 sur une relation France vers Allemagne (Paquet mobilité), susceptible d'évolution.] Vérifications faites : les 9 lignes du tableau de l'énoncé sont toutes traitées (O/N + sanction) ; somme du barème = 2,25 + 1,75 + 1,5 + 0,5 = 6 = max_score ; délai L.133-3 (3 jours hors dimanches et fériés) correctement rappelé et distingué du délai CMR de 7 jours pour les dommages non apparents ; FCO tous les 5 ans et données tachygraphe « jour en cours + 28 jours précédents » conformes. Le barème est conçu pour ne pas pénaliser l'absence de montants chiffrés.
UPDATE public.question_bank SET
  expected_answer = $corr$POCHETTE DE BORD : MISSION INTERNATIONALE CLERMONT-FERRAND vers COLOGNE (Allemagne)

Principe : sur une relation intracommunautaire, la pochette de bord comprend trois familles de documents : ceux de l'entreprise et du véhicule, ceux du conducteur, ceux de la marchandise. Tous doivent être présentés à toute réquisition des agents de contrôle, en France comme en Allemagne.

1) Copie conforme de la licence de transport communautaire : OBLIGATOIRE.
Elle prouve que l'entreprise est inscrite au registre des transporteurs et habilitée à réaliser du transport international. Une copie conforme numérotée doit se trouver à bord de chaque véhicule. Absence : procès-verbal, amende, immobilisation possible du véhicule ; si l'entreprise n'est en réalité pas titulaire de la licence, exercice illégal de la profession (sanction pénale, retrait éventuel de la licence).

2) Certificat d'immatriculation (carte grise) du tracteur et de la semi-remorque : OBLIGATOIRE.
Identification du véhicule, exigée à bord. Absence : contravention, obligation de présentation ultérieure, risque d'immobilisation.

3) Attestation d'assurance : OBLIGATOIRE à bord dans le contexte international.
Elle justifie l'assurance obligatoire de responsabilité civile du véhicule. Nuance à connaître : depuis avril 2024, la vignette (« papillon vert ») n'est plus à apposer sur le pare-brise en France, le contrôle s'effectuant via le Fichier des véhicules assurés ; l'attestation (mémo, et carte verte pour les pays hors espace de contrôle européen) reste néanmoins remise au conducteur et exigible lors d'un contrôle à l'étranger. Absence du document : contravention. Défaut réel d'assurance : délit, amende lourde, immobilisation et confiscation possible du véhicule.

4) Permis de conduire valide, catégorie CE : OBLIGATOIRE.
Le conducteur doit détenir la catégorie correspondant à l'ensemble conduit (CE pour un ensemble articulé). Non-présentation : contravention. Conduite sans permis valide (expiré, non détenu, suspendu) : délit exposant à une amende, une peine d'emprisonnement, l'immobilisation du véhicule, ainsi qu'à la mise en cause de l'employeur.

5) Carte de qualification de conducteur (CQC) ou permis portant le code harmonisé 95 : OBLIGATOIRE.
Elle atteste de la formation initiale (FIMO) et de la formation continue (FCO, à renouveler tous les cinq ans). Absence : contravention et interdiction de poursuivre la mission ; l'employeur qui fait conduire un conducteur non qualifié engage sa responsabilité.

6) Carte conducteur du tachygraphe numérique : OBLIGATOIRE.
Elle enregistre les temps de conduite, de travail et de repos. Le conducteur doit pouvoir présenter les données de la journée en cours et des 28 jours précédents. Absence, carte non insérée ou défectueuse : contravention. Manipulation ou falsification du tachygraphe : délit, avec immobilisation du véhicule.

7) Lettre de voiture CMR : OBLIGATOIRE.
Le transport France vers Allemagne relève de la Convention CMR. La lettre de voiture CMR est établie en trois exemplaires originaux (expéditeur, transporteur, marchandise) et matérialise le contrat de transport. Absence : contravention et, surtout, perte de la preuve du contrat, des réserves et de la déclaration de valeur, ce qui expose lourdement le transporteur en cas de litige (avarie, manquant, retard). Rappel utile : en régime intérieur, l'avarie non apparente doit faire l'objet d'une protestation motivée écrite adressée dans les 3 jours, non compris les dimanches et jours fériés (art. L.133-3 du code de commerce), à peine de forclusion ; sous CMR, le délai de réserves pour dommage non apparent est de 7 jours.

8) Passeport ou carte nationale d'identité : OBLIGATOIRE.
Même dans l'espace Schengen, le conducteur doit pouvoir justifier de son identité et de sa nationalité lors d'un contrôle ou en cas de rétablissement temporaire des contrôles aux frontières. Pour un ressortissant de l'Union européenne, une carte nationale d'identité en cours de validité suffit. Absence : contrôle d'identité prolongé, refus de franchissement, retard de la mission.

9) Ordre de mission interne : NON OBLIGATOIRE au sens réglementaire.
C'est un document d'entreprise (feuille de route) qui n'est pas exigé à bord par la réglementation. Il reste fortement recommandé : il porte les instructions d'exécution (adresses, contacts, horaires, consignes de chargement et de déchargement, conduite à tenir en cas d'incident). Son absence n'entraîne aucune sanction administrative, mais expose l'entreprise à des erreurs d'exécution et à des litiges avec le client.

À NE PAS OUBLIER selon la mission :
- données ou disques du tachygraphe couvrant la journée en cours et les 28 jours précédents ;
- documents ADR si la marchandise est dangereuse : consignes écrites, certificat ADR du conducteur, certificat d'agrément du véhicule ;
- documents de détachement du conducteur lorsque l'opération entre dans le champ du détachement (Paquet mobilité) ;
- justificatif du contrôle technique en cours de validité.$corr$,
  scoring_grid    = $corr$Total 6 points.

1. Qualification O/N des 9 documents (2,25 pts) : 0,25 pt par ligne correcte. Les huit premiers documents sont obligatoires ; seul l'ordre de mission interne n'est pas obligatoire au sens réglementaire. Le point de cette dernière ligne n'est accordé que si le candidat répond « Non » ET précise qu'il reste fortement recommandé.

2. Justification de l'utilité des documents (1,75 pt) : 0,25 pt par justification pertinente, plafonné à 1,75 pt (licence communautaire = habilitation de l'entreprise à l'international ; carte grise = identification du véhicule ; assurance = RC obligatoire ; permis CE = habilitation à conduire l'ensemble ; CQC = FIMO et FCO ; carte conducteur = enregistrement des temps de conduite et de repos ; CMR = contrat de transport international ; CNI ou passeport = justification de l'identité).

3. Sanctions ou conséquences en cas d'absence (1,5 pt) : 0,25 pt par sanction correctement caractérisée, plafonné à 1,5 pt. Est attendue la distinction entre la simple non-présentation d'un document (contravention, régularisation possible) et le défaut réel du titre, qui constitue une infraction lourde voire un délit (défaut d'assurance, conduite sans permis valide, fraude au tachygraphe, exercice illégal de la profession), avec immobilisation possible du véhicule. La mention du risque probatoire lié à l'absence de CMR (perte de la preuve du contrat et des réserves) est valorisée dans ce total.

4. Compléments propres à l'international (0,5 pt) : citer au moins deux des éléments suivants : données du tachygraphe des 28 jours précédents, documents ADR le cas échéant, documents de détachement du conducteur, contrôle technique en cours de validité.

Règle de notation : aucun point n'est retiré si le candidat n'indique pas de montant d'amende ; la nature de la sanction suffit.

Contrôle du barème : 2,25 + 1,75 + 1,5 + 0,5 = 6 points = max_score.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch07:ex7.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$Contexte : livraison de 18 palettes de pièces mécaniques chez RENAULT TRUCKS (Montpellier) ; 2 palettes présentent un filmage déchiré et des cartons écrasés (avaries APPARENTES, constatées à la livraison).

1) Validité juridique des réserves

a) « Sous réserve de déballage » : réserve NON VALABLE. Une réserve n'a d'effet que si elle est précise, motivée et significative : elle doit décrire la nature du dommage, son étendue et identifier les colis concernés. Une formule générale, vague ou de style (« sous réserve de déballage », « sous réserve de contrôle », « sous réserve de vérification ») est inopérante : elle équivaut à une absence de réserve et ne renverse pas la présomption de livraison conforme. Le destinataire est alors réputé avoir reçu la marchandise en bon état.

b) « 2 palettes n°14 et n°17 : filmage déchiré, cartons écrasés en surface » : réserve VALABLE. Elle est précise (palettes identifiées par leur numéro), motivée (nature du dommage décrite : filmage déchiré, cartons écrasés) et quantifiée (2 palettes sur 18). Elle porte sur des avaries apparentes constatées contradictoirement à la livraison et est portée sur le document de transport (bon de livraison / lettre de voiture), signé par le destinataire et contresigné par le conducteur. Elle conserve le recours du destinataire contre le transporteur.

2) Délai de confirmation par LRAR

Les réserves portées sur le document de transport doivent être confirmées par une protestation motivée écrite adressée au transporteur (LRAR ou autre acte extrajudiciaire) dans les 3 jours, non compris les dimanches et jours fériés, suivant celui de la réception de la marchandise (art. L.133-3 du Code de commerce). Le délai court à compter du lendemain de la livraison. La protestation doit reprendre et motiver les réserves (nature et importance du dommage, colis concernés).
Remarque : lorsque les réserves ont été acceptées contradictoirement par le transporteur au moment de la livraison, la protestation n'est en principe plus nécessaire ; en pratique, on la confirme systématiquement par LRAR dans les 3 jours pour sécuriser le recours.

3) Conséquence du non-respect du délai

Forclusion : l'action contre le transporteur est éteinte (art. L.133-3 C. com.). Toute action, principale ou reconventionnelle, fondée sur l'avarie devient irrecevable, sauf fraude ou infidélité du transporteur. Le destinataire (ou son assureur) perd son recours et supporte le préjudice, même si l'avarie est réelle et imputable au transporteur.

4) Mesures à prendre par le conducteur sur place

- Ne pas quitter les lieux sans document de transport signé ; ne pas refuser purement et simplement la livraison sans instruction de l'exploitation.
- Faire porter les réserves de manière précise et motivée sur le bon de livraison / la lettre de voiture (colis identifiés, nature et étendue du dommage) et refuser les formules vagues.
- Rendre les réserves contradictoires : signature du destinataire ET contresignature du conducteur, qui peut ajouter ses propres observations (dommage non imputable au transport, palettes mal filmées ou mal calées au chargement, etc.).
- Prendre des photos datées des palettes n°14 et n°17 (filmage, cartons, calage, arrimage) et de l'état du chargement dans la remorque.
- Informer immédiatement l'exploitation / le gestionnaire de transport pour décision (laisser la marchandise, la reprendre, expertise éventuelle).
- Conserver un exemplaire du document revêtu des réserves et le transmettre à l'entreprise, qui déclarera le sinistre à son assureur (RC contractuelle du transporteur) et informera l'expéditeur / le donneur d'ordre.
- Ne reconnaître aucune responsabilité au nom de l'entreprise.$corr$,
  scoring_grid    = $corr$Total 6 points (= max_score).

Q1 — Validité des réserves (2 pts)
- a) Réserve « sous réserve de déballage » déclarée NON valable, car imprécise / formule de style / vaut absence de réserve : 1 pt (0,5 pt si la réponse est juste sans justification).
- b) Réserve b) déclarée VALABLE car précise, motivée, quantifiée, colis identifiés, portée sur le document et contresignée : 1 pt (0,5 pt si la réponse est juste sans justification).

Q2 — Délai (1,5 pt)
- Délai de 3 jours : 0,75 pt.
- Précisions : « non compris les dimanches et jours fériés », protestation motivée écrite par LRAR, visa de l'art. L.133-3 C. com. : 0,75 pt (0,25 pt par élément, plafonné à 0,75).

Q3 — Sanction (1 pt)
- Forclusion / extinction de l'action, irrecevabilité du recours contre le transporteur : 1 pt (0,5 pt si l'idée de perte du recours est donnée sans le terme « forclusion » ni la portée).

Q4 — Mesures du conducteur (1,5 pt)
- 0,25 pt par mesure pertinente citée, plafonné à 1,5 pt : réserves précises et motivées sur le document ; contradictoire / contresignature ; photos datées ; information immédiate de l'exploitation ; conservation d'un exemplaire ; transmission pour déclaration de sinistre ; ne pas reconnaître de responsabilité.

Contrôle : 2 + 1,5 + 1 + 1,5 = 6 pts.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch07:ex7.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch07:ex7.3] : [À CONFIRMER: le document de lettre de voiture de l'annexe n'est pas disponible dans l'énoncé stocké en base ; la ventilation exacte Présente/Manquante des 12 mentions doit être vérifiée sur le document réel avant publication du corrigé. Aucun article précis n'est cité sur les mentions obligatoires (volontairement, pour ne pas avancer une référence non vérifiée).]
UPDATE public.question_bank SET
  expected_answer = $corr$Corrigé méthodologique — grille de contrôle des mentions obligatoires de la lettre de voiture.

Rappel : la lettre de voiture est le document qui matérialise le contrat de transport ; elle doit accompagner tout transport public routier de marchandises et comporter les mentions prévues par le contrat type général et la réglementation des transports (mentions équivalentes en international avec la lettre de voiture CMR). Le candidat coche « Présente » lorsque la mention figure effectivement sur le document de l'annexe et « Manquante » lorsqu'elle en est absente. Toute mention manquante doit être signalée et réclamée avant le départ : son absence prive le transporteur d'une preuve de l'exécution du contrat et peut engager la responsabilité du donneur d'ordre.

Grille des 12 mentions demandées et rôle de chacune :
1. Nom et adresse de l'expéditeur — identification du cocontractant qui remet la marchandise.
2. Nom et adresse du destinataire — identification de la personne à qui la marchandise doit être remise.
3. Adresse exacte de chargement — lieu (et le cas échéant quai / site) de prise en charge.
4. Adresse exacte de livraison — lieu précis de mise à disposition.
5. Date et heure de chargement prévues — base du calcul des temps d'attente et des éventuelles pénalités.
6. Nature de la marchandise — dénomination usuelle et mentions particulières (température dirigée, ADR, denrées).
7. Nombre d'unités de charge — nombre de colis, palettes ou contenants remis.
8. Poids brut total — base du calcul de l'indemnisation en cas de perte ou d'avarie (limitation d'indemnité au kilo) et du contrôle de la charge utile / du PTAC.
9. Conditions de paiement (port payé / port dû) — désignation du payeur du prix du transport.
10. Signature de l'expéditeur — preuve de la remise de la marchandise et de l'exactitude des données déclarées.
11. Signature du transporteur — preuve de la prise en charge, point de départ de la présomption de bon état apparent.
12. Numéro de la lettre de voiture — identification et traçabilité du document.

Exploitation attendue :
- Pour chaque mention absente du document de l'annexe : croix dans la colonne « Manquante » + conséquence (impossibilité de prouver la prise en charge, de calculer l'indemnisation faute de poids, d'imputer le prix faute de mention port payé / port dû, de décompter les temps d'attente faute de date et heure, de tracer le document faute de numéro).
- Conclusion attendue : le gestionnaire de transport ne laisse pas partir le véhicule avec une lettre de voiture incomplète. Il fait compléter les mentions manquantes par l'expéditeur, fait signer le document par l'expéditeur et par le conducteur, et conserve un exemplaire (exemplaire expéditeur, exemplaire transporteur, exemplaire destinataire).

[À CONFIRMER : le document (lettre de voiture) de l'annexe n'est pas accessible dans l'énoncé stocké en base — celui-ci ne contient que le tableau des 12 mentions à cocher. Le corrigé ci-dessus fournit la grille de contrôle et la méthode ; la ventilation exacte « Présente / Manquante » doit être calée sur le document réel de l'annexe avant publication.]$corr$,
  scoring_grid    = $corr$Total 6 points (= max_score).

- Identification correcte de chaque mention comme « présente » ou « manquante » d'après le document de l'annexe : 4 pts, soit environ 0,33 pt par ligne correctement cochée (12 lignes), arrondi au demi-point en faveur du candidat.
- Justification de l'importance des mentions manquantes (preuve de la prise en charge, base d'indemnisation liée au poids, imputation du prix port payé / port dû, temps d'attente, traçabilité) : 1 pt.
- Conduite à tenir par le gestionnaire (faire compléter la lettre de voiture AVANT le départ, faire signer expéditeur et transporteur, conserver un exemplaire) : 1 pt.

Contrôle : 4 + 1 + 1 = 6 pts.

Remarque correcteur : la répartition Présente / Manquante doit être calée sur le document réel de l'annexe.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch07:ex7.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch08:ex8.1] : [À CONFIRMER: l'annexe 2 (puits de commandes, absences conducteurs, indisponibilités véhicules) n'est pas disponible dans l'énoncé stocké en base ; le corrigé chiffré (affectations conducteur/véhicule/commande, jour par jour) doit être établi à partir de l'annexe réelle avant publication. Les seuils RSE cités proviennent du règlement CE 561/2006 (ancrage haute confiance).]
UPDATE public.question_bank SET
  expected_answer = $corr$Corrigé méthodologique — ZALTO TRANS (Carcassonne), transport national et international de produits alimentaires liquides en vrac ; construction du planning transport de la semaine suivante.

Avertissement : l'annexe 2 (puits de commandes, liste des conducteurs avec absences, liste des véhicules avec indisponibilités) n'est pas jointe à l'énoncé stocké. La démarche et les contraintes ci-dessous constituent le corrigé de référence ; les affectations chiffrées doivent être calées sur les données réelles de l'annexe.

1) Démarche attendue

Étape 1 — Dépouiller le puits de commandes : pour chaque commande, relever le lieu de chargement, le lieu de livraison, la date et le créneau imposés, le produit (liquides alimentaires en vrac, donc citerne alimentaire dédiée), le volume ou la quantité, la distance et le temps de trajet estimé.

Étape 2 — Recenser les ressources : liste des conducteurs réellement disponibles jour par jour (retirer congés, arrêts, formations / FCO) ; liste des véhicules disponibles (retirer contrôle technique, entretien, immobilisation, lavage de citerne).

Étape 3 — Croiser besoins et ressources : affecter à chaque commande un couple conducteur + véhicule compatible — matériel (citerne alimentaire, compartimentage, volume, PTAC/PTRA et charge utile), habilitations et permis du conducteur, cohérence géographique (national / international, longue distance / régional).

Étape 4 — Vérifier la faisabilité réglementaire de chaque mission (règlement CE 561/2006) :
- conduite continue : 4 h 30 maximum, puis pause de 45 minutes (fractionnable en 15 min puis 30 min) ;
- conduite journalière : 9 h, portée à 10 h deux fois par semaine au maximum ;
- conduite hebdomadaire : 56 h maximum ; 90 h maximum sur deux semaines consécutives ;
- repos journalier : 11 h, réductible à 9 h trois fois entre deux repos hebdomadaires ;
- repos hebdomadaire : 45 h, réductible à 24 h avec compensation.
On en déduit le nombre de jours nécessaires par mission longue distance et l'impossibilité d'enchaîner certaines rotations sur une même journée.

Étape 5 — Équilibrer et arbitrer : répartir la charge entre conducteurs, éviter les surcharges et les véhicules inutilisés, intégrer les temps de lavage / nettoyage des citernes entre deux produits alimentaires différents, ménager une marge d'aléa.

Étape 6 — Traiter les commandes non couvertes : si les ressources internes sont insuffisantes, envisager l'affrètement (sous-traitance auprès d'un confrère inscrit au registre des transporteurs), le décalage négocié de la date avec le client, ou le refus argumenté. Toute solution doit être justifiée.

2) Restitution attendue

Un tableau de planning par jour de la semaine et par conducteur indiquant, pour chaque mission : le conducteur, le véhicule (immatriculation ou numéro de parc), la commande, le chargement (lieu, date, heure), la livraison (lieu, date, heure), le kilométrage et le temps de conduite estimé, et le contrôle du respect des temps de conduite et de repos. Les conducteurs absents et les véhicules indisponibles apparaissent grisés ou signalés. Une ligne de commentaires justifie les arbitrages (affrètement, report, refus).

[À CONFIRMER : les affectations chiffrées conducteur / véhicule / commande dépendent de l'annexe 2, non accessible ici.]$corr$,
  scoring_grid    = $corr$Total 6 points (= max_score).

- Prise en compte complète du puits de commandes (toutes les commandes traitées, aucune oubliée) : 1 pt.
- Respect des absences des conducteurs et des indisponibilités des véhicules (aucune ressource affectée alors qu'elle est indisponible) : 1,5 pt.
- Compatibilité matériel / mission (citerne alimentaire adaptée, volume et charge utile compatibles, lavage de citerne intercalé en cas de changement de produit) : 1 pt.
- Respect de la réglementation sociale européenne dans la construction du planning (conduite continue 4 h 30 puis pause 45 min ; conduite journalière 9 h, 10 h deux fois par semaine ; 56 h hebdomadaires et 90 h sur deux semaines ; repos journalier 11 h réductible à 9 h ; repos hebdomadaire 45 h réductible à 24 h avec compensation) : 1,5 pt.
- Traitement argumenté des commandes non couvertes (affrètement, report négocié ou refus motivé) et lisibilité du planning restitué : 1 pt.

Contrôle : 1 + 1,5 + 1 + 1,5 + 1 = 6 pts.

Remarque correcteur : le barème s'applique aux affectations réelles issues de l'annexe 2 ; toute solution différente mais cohérente et respectant les contraintes est acceptée.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch08:ex8.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch08:ex8.2] : [À CONFIRMER: l'annexe (tableau des distances/temps de trajet entre Clermont-Ferrand, Chamalières, Gerzat, Thiers et Beaumont, et durées de déchargement) n'est pas disponible dans l'énoncé stocké ; les horaires d'arrivée et le temps de service total doivent être recalculés sur ces données réelles. À confirmer également : (a) la limite de temps de service de 12 h est posée par l'énoncé (elle relève du code du travail et des accords transport, non du règlement CE 561/2006) ; (b) la capacité du véhicule — l'ordre de grandeur de 33 palettes europe est donné à titre indicatif, le véhicule affecté n'étant pas précisé dans l'énoncé.]
UPDATE public.question_bank SET
  expected_answer = $corr$Corrigé de référence — tournée du conducteur MULLER, départ du dépôt de Clermont-Ferrand le lundi 04/04 à 6 h 00.

Avertissement : le tableau des distances et des temps de trajet / de déchargement figure dans l'annexe, non accessible dans l'énoncé stocké. La logique de résolution, les contraintes et la méthode de calcul ci-dessous constituent le corrigé attendu ; les horaires et le temps de service total doivent être recalculés sur les données réelles de l'annexe.

1) Ordre optimal de livraison

Principe : la contrainte horaire prime sur l'optimisation kilométrique. On classe les clients par degré de contrainte décroissant.
- B (IGM, Gerzat) : créneau IMPÉRATIF et étroit, 9 h 00 à 11 h 00, donc contrainte la plus dure. Gerzat est au nord immédiat de Clermont-Ferrand.
- D (CONSERVES BEAUMONT, Beaumont) : créneau étroit 14 h 00 à 16 h 00. Beaumont est au sud immédiat de Clermont-Ferrand, donc se place naturellement au retour.
- A (MECA-CONCEPT, Chamalières) : créneau large du matin, 8 h 00 à 12 h 00. Chamalières est limitrophe de Clermont-Ferrand (ouest).
- C (THIERS BÂTIMENT, Thiers) : créneau très large, 10 h 00 à 17 h 00, mais site le plus éloigné (est du département), donc variable d'ajustement.

Ordre retenu : dépôt Clermont-Ferrand (départ 6 h 00), puis A Chamalières (dès l'ouverture du créneau, à partir de 8 h 00), puis B Gerzat (dans le créneau impératif 9 h 00 - 11 h 00), puis C Thiers (arrivée en fin de matinée ou début d'après-midi, dans le créneau 10 h 00 - 17 h 00, pause méridienne prise sur place ou en route), puis D Beaumont (dans le créneau 14 h 00 - 16 h 00), puis retour au dépôt.
Variante également acceptée si les temps de route de l'annexe l'imposent : B (Gerzat) dès 9 h 00, puis A (Chamalières) avant 12 h 00, puis C (Thiers), puis D (Beaumont). Le critère décisif est que B soit servi entre 9 h 00 et 11 h 00 et D entre 14 h 00 et 16 h 00 ; C, dont le créneau est le plus large, absorbe l'ajustement.
À écarter : l'ordre purement géographique (Chamalières, Beaumont, Gerzat, Thiers), qui minimise le kilométrage mais viole le créneau impératif de B et le créneau de D.

Chargement : total transporté = 8 + 5 + 3 + 6 = 22 palettes. Vérifier la compatibilité avec la capacité du véhicule (à titre indicatif, une semi-remorque standard emporte de l'ordre de 33 palettes europe au sol) et charger en ordre inverse de livraison (dernier livré au fond) pour limiter les manutentions et sécuriser l'arrimage.

2) Temps de service total

Définition : temps de service = temps de conduite + temps de livraison (déchargement, formalités, attente à quai) + autres travaux ; les pauses et coupures en sont exclues. À distinguer de l'amplitude, qui est la durée entre la prise de service et la fin de service, pauses comprises.
Méthode de calcul :
Temps de service = somme des temps de conduite (dépôt vers A, A vers B, B vers C, C vers D, D vers dépôt) + somme des temps de déchargement chez les 4 clients (+ autres travaux : contrôles, émargement des documents).
Si la conduite cumulée de l'annexe vaut X heures et le déchargement Y minutes par client, alors temps de service = X + 4 × Y. L'amplitude ajoute à ce total la pause de 45 min et la pause repas.

3) Respect de la réglementation

- Conduite continue : maximum 4 h 30 de conduite ininterrompue, puis pause de 45 minutes, fractionnable en une coupure de 15 minutes suivie d'une coupure de 30 minutes (règlement CE 561/2006). Attention : les déchargements sont des « autres travaux » et NON des pauses ; ils n'interrompent donc pas le décompte de la conduite continue. Il faut cumuler la conduite entre deux pauses et positionner explicitement la pause de 45 min (par exemple à Thiers, entre la livraison de C et la route vers D, ou lors de la pause méridienne).
- Conduite journalière : 9 h maximum (10 h deux fois par semaine au plus). Sur une tournée départementale (Puy-de-Dôme), cette limite n'est en principe pas atteinte.
- Temps de service : la limite de 12 h est posée par l'énoncé ; elle est respectée dès lors que le service, entre la prise de service à 6 h 00 et le retour au dépôt en fin d'après-midi, reste inférieur à 12 h — à vérifier par le calcul de la question 2.
- Conclusion attendue : la tournée est réalisable dans le respect de la réglementation sociale À CONDITION d'inscrire explicitement au planning la pause de 45 minutes et de ne jamais dépasser 4 h 30 de conduite continue.

[À CONFIRMER : les temps de trajet et de déchargement figurent dans l'annexe, non accessible ; les horaires d'arrivée et le temps de service total doivent être recalculés sur ces données.]$corr$,
  scoring_grid    = $corr$Total 6 points (= max_score).

Q1 — Ordre de livraison (2,5 pts)
- Ordre proposé respectant le créneau impératif de B (9 h 00 - 11 h 00) : 1 pt.
- Respect du créneau de D (14 h 00 - 16 h 00) et du créneau matinal de A (8 h 00 - 12 h 00), C (10 h 00 - 17 h 00) servant de variable d'ajustement : 1 pt.
- Justification du raisonnement (priorité des contraintes horaires sur l'optimisation kilométrique ; chargement en ordre inverse de livraison ; total de 22 palettes compatible avec la capacité du véhicule) : 0,5 pt.

Q2 — Temps de service (2 pts)
- Méthode correcte : temps de service = conduite + déchargements + autres travaux, pauses exclues : 1 pt.
- Calcul exact à partir des données de l'annexe et distinction explicite amplitude / temps de service : 1 pt.

Q3 — Respect de la RSE (1,5 pt)
- Conduite continue : 4 h 30 maximum puis pause de 45 min, fractionnable en 15 + 30 ; les déchargements ne sont pas des pauses : 0,75 pt.
- Vérification du temps de service (limite de 12 h posée par l'énoncé) et conclusion argumentée, avec positionnement explicite de la pause au planning : 0,75 pt.

Contrôle : 2,5 + 2 + 1,5 = 6 pts.

Remarque correcteur : tout ordre de tournée différent est accepté dès lors que les créneaux impératifs de B et de D sont respectés et que le raisonnement est justifié.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch08:ex8.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch08:ex8.3] : Barème vérifié : 1,5 + 1,5 + 1,5 + 1 + 0,5 = 6 = max_score. Données de l'énoncé confirmées (Montpellier lundi 14 h 30, PLSC, 68 km/h, LACHAUD jusqu'à 21 h 00, pas de travail 21 h - 6 h sans autorisation, dépôt Clermont-Ferrand). [À CONFIRMER: la liste des offres de fret figure dans une annexe non incluse dans l'énoncé stocké en base. Le corrigé fournit la méthode complète, les filtres et les calculs attendus, mais l'offre à retenir et les valeurs numériques (distances, prix, créneaux, poids, volumes) doivent être renseignées à partir du tableau d'annexe. Le crédit de conduite déjà consommé par le conducteur LACHAUD le lundi n'est pas non plus précisé dans l'énoncé et doit être repris de l'annexe.] La mention initiale d'une charge utile PLSC de « 24 à 25 t / 33 palettes » a été retirée du corrigé : ce n'est pas une donnée réglementaire mais une caractéristique du véhicule, à lire dans l'annexe, la charge utile réelle dépendant du PTRA (44 t en national, 5 essieux) et de la tare de l'ensemble.
UPDATE public.question_bank SET
  expected_answer = $corr$Méthode de sélection de l'offre de fret retour (à appliquer au tableau d'offres de l'annexe).

Étape 1 : contraintes à poser avant tout calcul
- Point de départ : Montpellier, ensemble routier TRR-01 / SREM-01 disponible le lundi à 14 h 30 (fin de la livraison).
- Matériel : semi-remorque bâchée PLSC. Toute offre exigeant un autre matériel (frigorifique, citerne, benne, plateau, porte-voitures, marchandises ADR si le conducteur n'est pas habilité, hayon) est éliminée d'office, quel que soit son prix.
- Destination utile : le fret doit ramener l'ensemble vers Clermont-Ferrand ou sur son axe de retour. Un fret qui éloigne du dépôt (par exemple vers l'Espagne, la Côte d'Azur ou le Sud-Ouest lointain) n'a d'intérêt que s'il est enchaînable et fortement rémunérateur.
- Fenêtre horaire : le conducteur LACHAUD est disponible jusqu'à 21 h 00 ; consigne interne DHM TRANS, aucun travail entre 21 h 00 et 6 h 00 sans autorisation de l'exploitation. Toute solution imposant une fin de service après 21 h 00 est écartée, sauf demande d'autorisation à l'exploitation.
- Contrainte RSE (CE 561/2006) : conduite continue de 4 h 30 maximum, puis interruption de 45 min (fractionnable en 15 min puis 30 min, dans cet ordre) ; conduite journalière de 9 h au maximum, portable à 10 h deux fois par semaine. Le temps de conduite déjà effectué le lundi (approche jusqu'à Montpellier) doit être déduit du crédit de conduite restant.
- Vitesse commerciale imposée : 68 km/h (consigne interne).

Étape 2 : calculs à conduire pour chaque offre compatible PLSC
1. Temps d'approche = distance Montpellier → lieu de chargement / 68 km/h.
2. Heure d'arrivée au chargement = 14 h 30 + temps d'approche + interruptions RSE éventuelles.
3. Vérification de la compatibilité avec le créneau de mise à disposition du chargement indiqué dans l'annexe.
4. Temps de chargement, puis heure de fin de service. Contrôle : fin de service au plus tard à 21 h 00 et conduite cumulée du jour inférieure ou égale à 9 h (10 h si dérogation encore disponible).
5. Faisabilité du lendemain : distance restante lieu de chargement → lieu de livraison, puis livraison → Clermont-Ferrand, divisée par 68 km/h, à comparer au créneau de livraison exigé et au plafond de conduite journalière.
6. Vérification du poids et du volume de l'offre par rapport à la capacité du PLSC décrit dans l'annexe (charge utile et nombre de palettes europe admissibles).
7. Rentabilité : prix du fret rapporté aux kilomètres réellement engagés (produit au kilomètre), sachant que le retour à vide serait de toute façon un coût pur sans recette.

Étape 3 : décision attendue
L'offre retenue est celle qui satisfait simultanément les cinq filtres suivants :
- matériel compatible PLSC ;
- lieu de chargement atteignable dans le crédit de conduite restant et avec une fin de service au plus tard à 21 h 00 ;
- itinéraire orienté vers Clermont-Ferrand ou son axe de retour ;
- poids et volume dans les limites du véhicule ;
- meilleur produit au kilomètre parmi les offres restantes.
La réponse doit être justifiée en écartant explicitement chaque offre non retenue par le motif qui la disqualifie (matériel inadapté, horaire incompatible, dépassement RSE, détour non rentable, surcharge).

Étape 4 : formalisation
La décision est confirmée à la bourse de fret, puis un ordre de mission est transmis au conducteur avec les coordonnées du chargeur, les créneaux de chargement et de livraison, la nature de la marchandise et le plan de marche du lendemain.$corr$,
  scoring_grid    = $corr$Critère 1 Analyse des contraintes (1,5 pt) : identification du matériel imposé, semi-remorque bâchée PLSC (0,5) ; prise en compte de la disponibilité du conducteur LACHAUD jusqu'à 21 h 00 et de l'interdiction de travail entre 21 h 00 et 6 h 00 sans autorisation (0,5) ; rappel des limites RSE applicables, conduite continue 4 h 30 puis interruption 45 min et conduite journalière 9 h (0,5).
Critère 2 Calculs de temps (1,5 pt) : temps d'approche calculé à la vitesse commerciale de 68 km/h pour chaque offre retenue (0,75) ; heures d'arrivée au chargement et de fin de service correctement déterminées (0,75).
Critère 3 Élimination argumentée des offres non retenues (1,5 pt) : chaque offre écartée est justifiée par un motif précis (matériel, horaire, RSE, détour, poids ou volume) (1,5).
Critère 4 Choix de l'offre et justification économique (1 pt) : offre sélectionnée cohérente avec l'ensemble des contraintes (0,5) ; justification par le produit au kilomètre et l'évitement du retour à vide (0,5).
Critère 5 Formalisation de la décision (0,5 pt) : confirmation à la bourse de fret et transmission d'un ordre de mission au conducteur (0,5).
Total : 6 points (= max_score).$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch08:ex8.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch09:ex9.1] : Barème vérifié : 1,5 + 1,5 + 2,5 + 0,5 = 6 = max_score. Calculs revérifiés : 1 045 / 68 = 15,3676 h → 15 h 22 ; J1 = 3 h 30 (238 km) + 4 h 30 (306 km) + 1 h (68 km) = 9 h / 612 km ; J2 = 433 km / 68 = 6 h 22, dont 4 h 30 (306 km) + 1 h 52 (127 km) ; repos 19 h 45 → 06 h 45 = 11 h, achevé avant la fin de la période de 24 h ouverte lundi 08 h 00. Les seuils cités (4 h 30 / 45 min, 9 h - 10 h deux fois par semaine, 11 h / 9 h, 45 h / 24 h) sont des anchors haute confiance du règlement CE 561/2006. [À CONFIRMER: l'énoncé mentionne un « retour du conducteur au dépôt de Clermont-Ferrand prévu le mardi », ce qui est incompatible avec un aller de 1 045 km étalé sur deux jours (le retour représenterait 1 045 km supplémentaires). Le corrigé retient la lecture standard : mission aller simple Clermont-Ferrand → Amsterdam achevée le mardi, la mention du retour étant sans incidence sur les quatre questions posées. Vérifier l'intention de l'auteur ou reformuler l'énoncé.]
UPDATE public.question_bank SET
  expected_answer = $corr$1. Temps total de conduite
Distance 1 045 km, vitesse commerciale 68 km/h.
T = 1 045 / 68 = 15,3676 h, arrondi à 15,37 h, soit 15 h 22 de conduite effective (0,3676 x 60 = 22 min).

2. Faisabilité en une seule journée
Non, la mission est irréalisable en une seule journée.
Le règlement CE 561/2006 fixe la durée de conduite journalière à 9 h, portable à 10 h deux fois par semaine au maximum. Or la mission exige 15 h 22 de conduite, soit plus de 5 h au-delà même du plafond dérogatoire de 10 h.
S'y ajoutent les autres temps de service : chargement 1 h, déchargement 1 h 30, pause repas 1 h et les interruptions obligatoires (45 min après 4 h 30 de conduite continue), ce qui porterait l'amplitude bien au-delà des limites admissibles.
Conclusion : la mission doit obligatoirement être étalée sur deux journées de travail séparées par un repos journalier.

3. Plan de marche conforme sur deux jours (proposition)
LUNDI
08 h 00 - 09 h 00 : prise de poste et chargement à Clermont-Ferrand (1 h, activité « autre tâche »).
09 h 00 - 12 h 30 : conduite 3 h 30 (3,5 x 68 = 238 km).
12 h 30 - 13 h 30 : pause repas 1 h, qui vaut interruption de conduite (au moins 45 min exigées ; ici 1 h, donc conforme) et qui remet le compteur de conduite continue à zéro.
13 h 30 - 18 h 00 : conduite 4 h 30 (4,5 x 68 = 306 km), soit le maximum de conduite continue autorisé.
18 h 00 - 18 h 45 : interruption 45 min.
18 h 45 - 19 h 45 : conduite 1 h (68 km).
Fin de service 19 h 45. Conduite du jour : 3 h 30 + 4 h 30 + 1 h 00 = 9 h 00 (plafond normal respecté, sans recours à la dérogation de 10 h). Distance parcourue : 9 x 68 = 612 km. Amplitude 08 h 00 - 19 h 45 = 11 h 45.

REPOS JOURNALIER : 19 h 45 (lundi) à 06 h 45 (mardi), soit 11 h consécutives (repos journalier normal). Il est bien pris à l'intérieur de la période de 24 h ouverte le lundi à 08 h 00 (fin du repos à 06 h 45, avant mardi 08 h 00).

MARDI
Distance restante : 1 045 - 612 = 433 km, soit 433 / 68 = 6,37 h = 6 h 22 de conduite.
06 h 45 - 11 h 15 : conduite 4 h 30 (306 km).
11 h 15 - 12 h 00 : interruption 45 min.
12 h 00 - 13 h 52 : conduite 1 h 52 (127 km). Arrivée Amsterdam 13 h 52.
13 h 52 - 15 h 22 : déchargement 1 h 30.
Conduite du mardi : 6 h 22, inférieure au plafond de 9 h. La conduite continue n'excède jamais 4 h 30. Total conduite mission : 9 h 00 + 6 h 22 = 15 h 22, cohérent avec la question 1.
Le plan est donc conforme au règlement CE 561/2006. Toute variante est acceptée dès lors qu'elle respecte : conduite continue de 4 h 30 maximum suivie d'une interruption de 45 min (fractionnable en 15 min puis 30 min, dans cet ordre), conduite journalière de 9 h maximum (10 h admis deux fois par semaine), et un repos journalier d'au moins 11 h consécutives entre les deux journées.

4. Type de repos pris entre le lundi soir et le mardi matin
Il s'agit d'un repos journalier normal, d'une durée d'au moins 11 heures consécutives (ici exactement 11 h, de 19 h 45 à 06 h 45). Ce n'est pas un repos hebdomadaire, lequel est de 45 h (réductible à 24 h avec compensation) et doit débuter au plus tard après six périodes de 24 h depuis la fin du repos hebdomadaire précédent. Le repos journalier peut, le cas échéant, être réduit à 9 h consécutives, trois fois au maximum entre deux repos hebdomadaires, sans compensation ; ce n'est pas nécessaire ici. Il peut être pris dans le véhicule à l'arrêt dès lors que celui-ci est équipé de couchettes.$corr$,
  scoring_grid    = $corr$Q1 Temps total de conduite (1,5 pt) : formule distance / vitesse posée (0,5) ; résultat 15,37 h (0,5) ; conversion correcte en 15 h 22 (0,5).
Q2 Faisabilité (1,5 pt) : réponse « non, mission infaisable en une journée » (0,5) ; rappel du plafond de conduite journalière de 9 h, portable à 10 h deux fois par semaine (0,5) ; comparaison chiffrée 15 h 22 > 10 h et prise en compte des autres temps de service et des interruptions (0,5).
Q3 Plan de marche sur deux jours (2,5 pts) : conduite journalière plafonnée à 9 h le premier jour (0,5) ; respect de la conduite continue de 4 h 30 suivie d'une interruption de 45 min, y compris le mardi (0,75) ; intégration des temps de chargement 1 h, pause repas 1 h et déchargement 1 h 30 (0,5) ; répartition kilométrique cohérente entre les deux jours, 612 km puis 433 km ou équivalent (0,5) ; horaires complets et lisibles du départ à l'arrivée (0,25).
Q4 Type de repos (0,5 pt) : identification du repos journalier normal de 11 h consécutives, distinct du repos hebdomadaire (0,5).
Total : 6 points (= max_score).$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch09:ex9.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch09:ex9.2] : Barème vérifié : Q1 (2 + 1,5 + 0,5 = 4) + Q2 (0,5 + 0,75 + 0,25 + 0,5 = 2) = 6 = max_score. [À CONFIRMER: le relevé hebdomadaire d'activités du conducteur Nicolas DURAND figure dans une annexe non incluse dans l'énoncé stocké en base. Le corrigé fournit la grille de contrôle exhaustive et la trame de la note, mais la liste nominative des infractions constatées et les écarts chiffrés doivent être complétés à partir du tableau d'annexe. La répartition des 2 pts de la première puce de Q1 devra être ajustée au nombre exact d'infractions attendues.] Les seuils RSE cités (4 h 30 / 45 min, 9 h - 10 h deux fois par semaine, 56 h, 90 h sur deux semaines, 11 h / 9 h trois fois, 45 h / 24 h avec compensation, six périodes de 24 h) relèvent du règlement CE 561/2006 (anchors haute confiance). Les seuils internes (15 min de vérifications, 10 h - 12 h de service, prise de poste 5 h 00, fin de poste 22 h 00, pause 30 min après 6 h, interdiction samedi 22 h - dimanche 22 h) sont repris littéralement de l'annexe 1 présente dans l'énoncé et ont été recontrôlés mot à mot.
UPDATE public.question_bank SET
  expected_answer = $corr$1. Contrôle des activités de la semaine du conducteur Nicolas DURAND

Le contrôle se conduit en deux grilles distinctes, à appliquer ligne par ligne au relevé tachygraphique de l'annexe.

Grille A : infractions à la réglementation sociale européenne (règlement CE 561/2006)
- Conduite continue supérieure à 4 h 30 sans interruption d'au moins 45 min (interruption fractionnable en 15 min puis 30 min, dans cet ordre).
- Conduite journalière supérieure à 9 h ; dérogation à 10 h admise deux fois par semaine seulement, donc infraction dès la troisième journée à plus de 9 h ou dès qu'une journée dépasse 10 h.
- Conduite hebdomadaire supérieure à 56 h.
- Conduite cumulée sur deux semaines consécutives supérieure à 90 h.
- Repos journalier inférieur à 11 h consécutives ; repos réduit inférieur à 9 h ; plus de trois repos journaliers réduits entre deux repos hebdomadaires.
- Repos hebdomadaire inférieur à 45 h ; repos hebdomadaire réduit inférieur à 24 h ; repos réduit non compensé (la compensation doit être rattachée à un repos d'au moins 9 h et prise avant la fin de la troisième semaine suivante).
- Repos hebdomadaire débutant au-delà de six périodes de 24 h depuis la fin du repos hebdomadaire précédent.

Grille B : non-respects des consignes internes TRANS EXPRESS (annexe 1)
- Vérifications de prise de poste absentes ou d'une durée supérieure à 15 minutes.
- Temps de service quotidien supérieur à 10 h sans validation de l'exploitation, ou supérieur à 12 h en toute hypothèse.
- Prise de poste antérieure à 5 h 00 sans accord préalable.
- Fin de poste postérieure à 22 h 00 sans accord préalable.
- Absence de pause d'au moins 30 min après 6 h de travail continu.
- Conduite entre le samedi 22 h 00 et le dimanche 22 h 00 sans autorisation exceptionnelle.
- Incident ou anomalie non signalé au service exploitation.

Pour chaque journée du relevé, l'apprenant doit indiquer la nature du manquement, l'écart chiffré (par exemple : conduite continue de 5 h 10, soit 40 min au-delà du seuil de 4 h 30) et la qualification retenue : infraction RSE ou non-respect d'une consigne interne. Une même journée peut cumuler les deux qualifications. Il est essentiel de distinguer les deux registres : la consigne interne est opposable au salarié sur le terrain disciplinaire mais n'est pas sanctionnée par les services de contrôle, alors que l'infraction RSE expose l'entreprise et le conducteur à une amende et peut engager la responsabilité pénale du dirigeant ainsi que l'honorabilité professionnelle du gestionnaire de transport.

2. Note d'information à la hiérarchie (trame attendue)

Émetteur : le gestionnaire de transport. Destinataire : M. MARTIN, responsable d'exploitation. Objet : analyse des relevés d'activités du conducteur Nicolas DURAND, semaine concernée. Date. Signature.

Corps de la note :
- Rappel du contexte : contrôle hebdomadaire des activités à partir des données du chronotachygraphe.
- Constats 1 : liste des infractions RSE relevées, journée par journée, avec l'écart chiffré.
- Constats 2 : liste des non-respects des consignes internes, avec renvoi à l'annexe 1.
- Analyse des risques : sanctions encourues en cas de contrôle, atteinte à l'honorabilité professionnelle du gestionnaire de transport, risque d'accident lié à la fatigue, incidence sur l'assurance et sur la relation client.
- Propositions : entretien avec le conducteur, rappel écrit des consignes, adaptation des plans de marche et des délais promis aux clients, renforcement du contrôle des données tachygraphiques, formation de rappel si nécessaire.
- Formule de conclusion.

La note doit rester courte, factuelle, sans jugement de valeur, et distinguer clairement les faits constatés des mesures proposées.$corr$,
  scoring_grid    = $corr$Q1 Contrôle des activités (4 pts) : identification correcte des infractions RSE relevées dans le relevé, avec la règle applicable et l'écart chiffré (2 pts, à répartir au prorata du nombre d'infractions attendues, soit environ 0,5 pt par infraction correctement caractérisée) ; identification des non-respects des consignes internes TRANS EXPRESS par renvoi à l'annexe 1 (1,5 pt) ; distinction explicite entre infraction réglementaire et manquement à une consigne interne (0,5 pt).
Q2 Note d'information (2 pts) : forme respectée, émetteur, destinataire, objet, date, signature (0,5) ; exposé factuel et hiérarchisé des anomalies constatées (0,75) ; analyse des risques encourus, sanctions, honorabilité, sécurité (0,25) ; propositions d'actions correctives concrètes (0,5).
Total : 6 points (= max_score).$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch09:ex9.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch09:ex9.3] : Barème vérifié : 2,5 + 1,5 + 1 + 1 = 6 = max_score. Calcul de contrôle vérifié : 90 - 56 = 34 h. [À CONFIRMER: le tableau hebdomadaire des activités et le total de conduite de la semaine précédente ne figurent pas dans l'énoncé stocké en base (annexe manquante, l'énoncé ne comporte que les quatre consignes de travail). Le corrigé fournit la méthode, les seuils applicables et la structure de réponse, mais les valeurs numériques (infractions journalières, total hebdomadaire, cumul bi-hebdomadaire) doivent être renseignées à partir du tableau. Sans la semaine N-1, la question 4 ne peut être tranchée numériquement.] Les seuils cités (4 h 30 / 45 min fractionnable 15 + 30, 9 h - 10 h deux fois par semaine, 56 h, 90 h sur deux semaines, 11 h / 9 h trois fois, 45 h / 24 h avec compensation, semaine lundi 00 h 00 - dimanche 24 h 00) relèvent du règlement CE 561/2006 (anchors haute confiance).
UPDATE public.question_bank SET
  expected_answer = $corr$1. Colonne « infractions » du tableau hebdomadaire
Pour chaque journée du relevé, la colonne est complétée en confrontant les activités enregistrées aux seuils du règlement CE 561/2006 :
- conduite continue : au-delà de 4 h 30 sans interruption d'au moins 45 min, prise en une fois ou fractionnée en 15 min puis 30 min dans cet ordre, l'infraction est constituée ;
- conduite journalière : le plafond est de 9 h, portable à 10 h deux fois par semaine seulement ; l'infraction est relevée dès la troisième journée portée à 10 h, ou dès qu'une journée dépasse 10 h ;
- repos journalier : au moins 11 h consécutives, réductibles à 9 h consécutives trois fois au maximum entre deux repos hebdomadaires (sans compensation) ; en deçà, infraction ;
- repos hebdomadaire : au moins 45 h, réductible à 24 h avec compensation ; il doit débuter au plus tard après six périodes de 24 h depuis la fin du repos hebdomadaire précédent.
Mention « RAS » lorsque la journée est conforme ; sinon libellé précis de l'infraction et écart chiffré (par exemple : conduite continue 5 h 00, dépassement de 30 min ; conduite journalière 10 h 30, dépassement de 30 min au-delà du plafond dérogatoire de 10 h).

2. Total de conduite de la semaine
Le total s'obtient en additionnant les durées de conduite de chaque journée, du lundi au dimanche : au sens du règlement CE 561/2006, la semaine court du lundi 00 h 00 au dimanche 24 h 00. Poser l'addition détaillée jour par jour, puis convertir les minutes en heures (par exemple 6 x 60 min = 6 h). Le total ainsi obtenu constitue la conduite hebdomadaire à comparer au plafond.

3. Conformité de la conduite hebdomadaire
Le règlement CE 561/2006 fixe la durée maximale de conduite hebdomadaire à 56 heures. La conduite de la semaine est conforme si le total calculé à la question 2 est inférieur ou égal à 56 h ; elle est non conforme et constitue une infraction dès le premier dépassement, à qualifier par l'écart en heures et minutes.

4. Conformité de la conduite bi-hebdomadaire
Le même règlement plafonne la conduite cumulée sur deux semaines consécutives à 90 heures. On additionne la conduite de la semaine analysée et celle de la semaine précédente (ou suivante, selon les données du tableau). Si le cumul est inférieur ou égal à 90 h, la conduite bi-hebdomadaire est conforme ; dans le cas contraire, il y a infraction et l'écart doit être chiffré.
Remarque : les deux plafonds sont cumulatifs et indépendants. Une semaine peut respecter le plafond de 56 h tout en rendant le cumul bi-hebdomadaire non conforme (par exemple 50 h après une semaine à 45 h, soit 95 h sur deux semaines). Symétriquement, une semaine à 56 h impose de limiter la semaine suivante à 34 h de conduite au maximum (90 - 56 = 34).$corr$,
  scoring_grid    = $corr$Q1 Colonne infractions (2,5 pts) : conduite continue de 4 h 30 et interruption de 45 min correctement contrôlées (0,75) ; conduite journalière de 9 h, portable à 10 h deux fois par semaine, correctement contrôlée (0,75) ; repos journalier de 11 h, réductible à 9 h trois fois entre deux repos hebdomadaires, correctement contrôlé (0,5) ; repos hebdomadaire de 45 h, réductible à 24 h avec compensation, correctement contrôlé (0,5).
Q2 Total de conduite hebdomadaire (1,5 pt) : addition complète des durées de conduite de chaque journée, du lundi au dimanche (1) ; conversion et résultat exacts en heures et minutes (0,5).
Q3 Conformité hebdomadaire (1 pt) : rappel du plafond de 56 h (0,5) ; comparaison chiffrée et conclusion argumentée, avec l'écart le cas échéant (0,5).
Q4 Conformité bi-hebdomadaire (1 pt) : rappel du plafond de 90 h sur deux semaines consécutives (0,5) ; cumul des deux semaines, comparaison et conclusion argumentée (0,5).
Total : 6 points (= max_score).$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch09:ex9.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch09:ex9.4] : [À CONFIRMER: (1) Cohérence interne des millésimes codés de l'énoncé : le contrôle est daté du 18/03/20AA alors que la FCO est indiquée comme suivie en octobre 20AC (postérieur, si l'on retient la convention AA = année en cours, AB = AA+1, AC = AA+2). Le corrigé retient l'intention pédagogique : toutes les qualifications sont valides au jour du contrôle, seule l'ADR classe 8 fait défaut. (2) En ADR, les classes 2 à 9 (dont la classe 8) relèvent de la formation de BASE ; seules les classes 1 (explosifs) et 7 (radioactifs) font l'objet d'une spécialisation, qui suppose normalement une base en cours de validité. L'énoncé raisonne en 'certificat ADR classe 8' : vérifier la formulation attendue par le référentiel de l'épreuve avant diffusion.]
UPDATE public.question_bank SET
  expected_answer = $corr$CONCLUSION : NON, le conducteur Martin LACHAUD n'est PAS qualifié pour cette mission. Il ne peut pas l'effectuer légalement.

Tableau d'analyse du dossier conducteur (contrôle effectué le 18/03/20AA) :

1) Permis CE — VALIDE (jusqu'au 15/04/20AB). Observation : échéance proche ; le permis groupe lourd est délivré pour une durée limitée sous réserve d'un avis médical périodique. Anticiper la visite médicale et le renouvellement du titre.

2) FIMO — VALIDE (obtenue en 2019). La FIMO (formation initiale minimale obligatoire, 140 h) est acquise définitivement ; elle est ensuite entretenue par la FCO tous les 5 ans.

3) FCO — VALIDE (suivie en octobre 20AC, validité jusqu'en octobre 20AH, soit le cycle de 5 ans). Observation : le stage FCO (35 h) devra être renouvelé avant l'échéance d'octobre 20AH.

4) CQC (carte de qualification de conducteur) — VALIDE (jusqu'en octobre 20AH). Elle matérialise la FIMO/FCO et doit être présentée à tout contrôle.

5) Carte de conducteur (chronotachygraphe) — VALIDE (jusqu'au 23/11/20AC). Observation : carte délivrée pour 5 ans ; la demande de renouvellement doit être déposée en amont de l'échéance (environ 15 jours avant) pour éviter toute rupture de service.

6) Certificat ADR classe 8 (matières corrosives) — NON DÉTENU : c'est le POINT BLOQUANT. Le conducteur ne détient qu'un certificat ADR classe 7 (matières radioactives), qui est une spécialisation et ne couvre pas les matières corrosives de la classe 8. Le transport de marchandises dangereuses de la classe 8 au-dessus des seuils d'exemption exige un certificat de formation ADR en cours de validité couvrant cette classe (formation de base, complétée le cas échéant par la spécialisation citerne si le transport est réalisé en citerne).

DÉCISION DU GESTIONNAIRE DE TRANSPORT :
- Refuser d'affecter Martin LACHAUD à la mission Strasbourg - Rotterdam : l'envoyer constituerait une infraction (réglementation ADR et arrêté TMD), engageant la responsabilité pénale de l'entreprise et du gestionnaire de transport, avec immobilisation quasi certaine du véhicule en cas de contrôle (transport international transitant par l'Allemagne et les Pays-Bas).
- Affecter à sa place un conducteur titulaire d'un certificat ADR valide couvrant la classe 8 (et la spécialisation citerne si le transport est réalisé en citerne).
- À défaut de conducteur disponible : sous-traiter la mission à un transporteur habilité ADR, ou reporter la mission après inscription de M. LACHAUD à la formation ADR de base.
- Vérifier également les obligations connexes de l'entreprise pour ce transport : désignation d'un conseiller à la sécurité TMD, document de transport ADR, équipements de sécurité et signalisation (plaques orange, étiquettes de danger), consignes écrites.
- Actions RH complémentaires : inscrire M. LACHAUD à la formation ADR de base (planification) et mettre à jour le tableau de suivi des habilitations pour anticiper les échéances (permis 15/04/20AB, carte conducteur 23/11/20AC, FCO/CQC octobre 20AH).$corr$,
  scoring_grid    = $corr$Total 6 points.
- Permis CE : valide au 18/03/20AA, échéance 15/04/20AB signalée : 0,75 pt
- FIMO : valide (acquise en 2019, entretenue par la FCO) : 0,75 pt
- FCO : valide (cycle de 5 ans, échéance octobre 20AH) : 0,75 pt
- CQC : valide jusqu'en octobre 20AH : 0,75 pt
- Carte de conducteur : valide jusqu'au 23/11/20AC, renouvellement à anticiper : 0,75 pt
- Certificat ADR classe 8 : NON détenu ; la classe 7 (radioactifs) ne couvre pas la classe 8 (corrosifs) ; point bloquant clairement identifié : 1,5 pt
- Décision motivée : refus d'affectation + solution de remplacement (conducteur ADR classe 8, sous-traitance ou report) et inscription en formation : 0,75 pt
Total = 0,75 x 5 + 1,5 + 0,75 = 6,00 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch09:ex9.4' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch10:ex10.1] : [À CONFIRMER: l'énoncé indique un trajet dépôt (Clermont-Ferrand) - Voiron de « 15 min selon distancier », donnée géographiquement incohérente (Voiron est à plus de 300 km de Clermont-Ferrand) et en tension avec la ligne « Conduite Voiron → Clermont » de 238 km. Le corrigé retient littéralement les données de l'énoncé (238 km à 68 km/h + approches de 15 min). Vérifier le distancier de référence de l'épreuve : si les 15 min correspondent seulement à un repositionnement local, la conduite totale passe à 3 h 30 (ou 3 h 45) et l'heure de fin à 16 h 45, sans modifier la conclusion de conformité RSE.]
UPDATE public.question_bank SET
  expected_answer = $corr$1) TEMPS DE CONDUITE
Trajet EMS EMBOUTISSAGE (Voiron, 38) - MECA-CONCEPT (Chamalières, 63) : 238 km à la vitesse commerciale retenue de 68 km/h.
T = 238 / 68 = 3,5 h, soit 3 h 30 de conduite.
En ajoutant les trajets d'approche du plan de marche (dépôt - Voiron : 15 min ; retour au dépôt : 15 min), la conduite totale de la journée s'établit à 3 h 30 + 0 h 15 + 0 h 15 = 4 h 00.

2) HEURE PRÉVISIONNELLE DE FIN DE MISSION
Plan de marche (lundi 28/03/20AA) :
- 08 h 00 : prise de service, départ du dépôt. Conduite 0 h 15.
- 08 h 15 : arrivée chez EMS EMBOUTISSAGE (Voiron). Chargement 2 h 00 (autre travail, pas de conduite). Cumul conduite 0 h 15 / cumul service 0 h 15.
- 10 h 15 : départ de Voiron. Conduite. Cumul service 2 h 15.
- 12 h 30 : arrêt pour la pause repas, après 2 h 15 de conduite continue. Cumul conduite 2 h 30.
- 12 h 30 - 13 h 30 : pause repas 1 h 00 (vaut pause au sens du règlement CE 561/2006, supérieure aux 45 min requises).
- 13 h 30 : reprise de la conduite ; solde de conduite = 3 h 30 - 2 h 15 = 1 h 15.
- 14 h 45 : arrivée chez MECA-CONCEPT (Chamalières). Déchargement 2 h 00. Cumul conduite 3 h 45.
- 16 h 45 : départ ; retour au dépôt, conduite 0 h 15. Cumul conduite 4 h 00.
- 17 h 00 : FIN DE SERVICE.
HEURE PRÉVISIONNELLE DE FIN DE MISSION : 17 h 00.

3) CONFORMITÉ À LA RÉGLEMENTATION SOCIALE EUROPÉENNE (règl. CE 561/2006)
- Conduite continue : 2 h 15 puis 1 h 15 ; le seuil de 4 h 30 de conduite continue n'est jamais atteint. CONFORME.
- Pause : 1 h 00 prise en une seule fois, supérieure au minimum de 45 min (fractionnable en 15 min puis 30 min). CONFORME (la pause n'était même pas obligatoire au regard de la conduite continue réalisée).
- Conduite journalière : 4 h 00, très inférieure au maximum de 9 h (10 h admises deux fois par semaine). CONFORME.
- Repos journalier : 11 h prises la nuit précédente (minimum 11 h, réductible à 9 h trois fois entre deux repos hebdomadaires). CONFORME.
- Amplitude : 08 h 00 - 17 h 00 = 9 h 00, inférieure au plafond de 12 h de la CCNTR. Temps de service (travail effectif) = 9 h 00 - 1 h 00 de pause = 8 h 00, inférieur au maximum quotidien de 10 h. CONFORME.
CONCLUSION : la mission CMD-204 est réalisable par un seul conducteur sur la journée du lundi 28/03/20AA, dans le respect de la RSE (règl. CE 561/2006) et de la CCNTR.

4) PÉRIODES D'ACTIVITÉ DU CONDUCTEUR (symboles du chronotachygraphe)
- Conduite (volant) : 4 h 00 au total (0 h 15 + 2 h 15 + 1 h 15 + 0 h 15).
- Autres travaux (marteaux croisés) : 4 h 00 (chargement 2 h 00 + déchargement 2 h 00), auxquels s'ajoutent les temps de prise et de fin de service.
- Pause / disponibilité (coupure) : 1 h 00 (pause repas 12 h 30 - 13 h 30).
- Repos journalier (lit) : hors amplitude — 11 h avant la prise de service, puis repos journalier à compter de 17 h 00.
Total amplitude : 4 h 00 (conduite) + 4 h 00 (autres travaux) + 1 h 00 (pause) = 9 h 00.$corr$,
  scoring_grid    = $corr$Total 6 points.
- Q1. Temps de conduite : 238 / 68 = 3,5 h = 3 h 30 (1 pt) ; prise en compte des trajets d'approche, conduite totale 4 h 00 (0,5 pt). Sous-total 1,5 pt
- Q2. Plan de marche horaire cohérent (chargement 2 h, pause repas 12 h 30 - 13 h 30, déchargement 2 h, retour dépôt) : 0,75 pt ; heure de fin de mission exacte 17 h 00 : 0,75 pt. Sous-total 1,5 pt
- Q3. Conformité RSE : conduite continue < 4 h 30 (0,4 pt) ; pause >= 45 min respectée (0,4 pt) ; conduite journalière < 9 h (0,35 pt) ; repos journalier 11 h et amplitude < 12 h (0,35 pt). Sous-total 1,5 pt
- Q4. Identification et totalisation des périodes d'activité : conduite 4 h, autres travaux 4 h, pause 1 h, repos hors amplitude (total amplitude 9 h) : 1,5 pt
Total = 1,5 x 4 = 6,00 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch10:ex10.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$Principe directeur : le gestionnaire de transport alerte sa hiérarchie dès qu'une situation dépasse son niveau de délégation, engage la responsabilité de l'entreprise (réglementaire, pénale, contractuelle) ou compromet la sécurité. Les simples aléas d'exploitation se traitent au niveau de l'exploitation, sans alerte formelle.

1) Le conducteur MULLER a effectué 57 h de conduite cette semaine.
Alerte hiérarchie : OUI, immédiate.
Justification : le règlement CE 561/2006 plafonne la durée de conduite hebdomadaire à 56 h. Avec 57 h, l'infraction est constituée (dépassement d'1 h). Il faut aussi vérifier le plafond de 90 h de conduite sur deux semaines consécutives.
Type d'alerte : alerte réglementaire et sécurité, à caractère urgent. Arrêt du conducteur, remontée au responsable d'exploitation et à la direction, analyse des causes (défaut de planification), traçabilité écrite, régularisation et mesures correctives (l'infraction est sanctionnable pour le conducteur comme pour l'entreprise, avec risque sur l'honorabilité du gestionnaire de transport).

2) Le conducteur LACHAUD arrive 20 min en retard à son chargement.
Alerte hiérarchie : NON.
Justification : aléa d'exploitation mineur, sans conséquence réglementaire ni sécurité, relevant du niveau de délégation du gestionnaire de transport.
Type d'alerte : simple information opérationnelle. Prévenir le site de chargement / le client, réajuster le plan de marche, tracer l'incident. Une remontée hiérarchique ne s'imposerait qu'en cas de répétition ou de mise en cause d'un délai contractuel assorti de pénalités.

3) TRANSROADSTAR a une licence de transport expirée.
Alerte hiérarchie : OUI, immédiate.
Justification : un sous-traitant dont la licence de transport n'est plus valide n'est plus habilité à exercer. Lui confier une mission exposerait l'entreprise donneuse d'ordre (transport illégal, exercice sans titre, responsabilité du donneur d'ordre) et priverait le transport de couverture assurantielle.
Type d'alerte : alerte réglementaire et juridique. Suspendre immédiatement toute affectation à ce sous-traitant, informer la direction et le service achats/juridique, exiger la licence en cours de validité (et l'attestation de vigilance URSSAF) avant toute reprise, réaffecter les missions en cours.

4) Un conducteur refuse de signer son ordre de mission.
Alerte hiérarchie : OUI.
Justification : le refus met en cause l'exécution du contrat de travail et peut révéler un désaccord social ou une contestation des conditions de la mission (temps de conduite, sécurité, droit de retrait). Le gestionnaire de transport ne peut ni contraindre le salarié, ni le sanctionner seul.
Type d'alerte : alerte hiérarchique RH / sociale. Recueillir et formaliser par écrit le motif du refus, informer le responsable d'exploitation et le service RH, ne pas envoyer le conducteur en mission sans arbitrage, vérifier que le refus ne signale pas une infraction potentielle (dépassement des temps de conduite, véhicule non conforme).

5) Taux de km à vide : 18 % cette semaine (objectif < 15 %).
Alerte hiérarchie : OUI, mais non urgente (alerte de gestion).
Justification : aucune infraction, mais un écart de 3 points par rapport à l'objectif, qui dégrade la marge (kilomètres non rémunérés, carburant, usure, temps de conduite consommé) et l'empreinte environnementale.
Type d'alerte : alerte de performance / gestion, à intégrer au reporting hebdomadaire ou mensuel, assortie d'un plan d'action : recherche de fret retour, groupage, bourses de fret, optimisation des tournées, analyse des lignes déficitaires.$corr$,
  scoring_grid    = $corr$Total 6 points, soit 1,2 point par situation, réparti pour chacune ainsi : réponse OUI/NON correcte 0,4 pt ; justification pertinente (référence réglementaire ou enjeu identifié) 0,5 pt ; type d'alerte et action associée 0,3 pt.
- Situation 1 (MULLER : 57 h > 56 h — plafond hebdomadaire du règl. CE 561/2006 ; alerte réglementaire urgente) : 1,2 pt
- Situation 2 (LACHAUD : retard de 20 min ; pas d'alerte, simple information opérationnelle) : 1,2 pt
- Situation 3 (TRANSROADSTAR : licence expirée ; alerte juridique immédiate, suspension du sous-traitant) : 1,2 pt
- Situation 4 (refus de signature ; alerte RH/sociale, formalisation écrite du motif) : 1,2 pt
- Situation 5 (km à vide 18 % ; alerte de gestion non urgente, plan d'action) : 1,2 pt
Total = 1,2 x 5 = 6,00 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch10:ex10.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$Données de l'énoncé : Thierry MULLER, grand routier (moins de 6 repos par mois à domicile). Durée conventionnelle de service : 43 h/semaine. Taux horaire brut : 15,20 euros. Mois de 4 semaines complètes, 196 h de service, dont 16 h de nuit (22 h - 05 h) et 0 h le dimanche. Frais de route : 22 nuits x 39,48 euros et 28 repas x 15,96 euros.

1) HEURES LÉGALES (CONVENTIONNELLES) DU MOIS
43 h x 4 semaines = 172 h.

2) HEURES SUPPLÉMENTAIRES TOTALES
196 h - 172 h = 24 h supplémentaires.

3) HEURES SUPPLÉMENTAIRES MAJORÉES À 25 % (les 8 premières)
8 x 15,20 x 1,25 = 8 x 19,00 = 152,00 euros.

4) HEURES SUPPLÉMENTAIRES MAJORÉES À 50 % (les restantes)
24 - 8 = 16 h. 16 x 15,20 x 1,50 = 16 x 22,80 = 364,80 euros.

5) SALAIRE DE BASE
172 h x 15,20 = 2 614,40 euros.

6) MAJORATION POUR TRAVAIL DE NUIT (heures entre 22 h et 05 h)
16 h x 15,20 x 20 % = 16 x 3,04 = 48,64 euros.

7) MAJORATION POUR TRAVAIL DU DIMANCHE
0 h de dimanche, donc 0,00 euro.

8) FRAIS DE COUCHAGE
22 nuits x 39,48 = 868,56 euros.

9) FRAIS DE REPAS
28 repas x 15,96 = 446,88 euros.

10) TOTAL DES FRAIS DE ROUTE (exonérés)
868,56 + 446,88 = 1 315,44 euros.

RÉCAPITULATIF
Salaire brut = salaire de base + heures supplémentaires (25 % et 50 %) + majoration de nuit
= 2 614,40 + 152,00 + 364,80 + 48,64 = 3 179,84 euros bruts.
Total versé au conducteur (salaire brut + frais de route) = 3 179,84 + 1 315,44 = 4 495,28 euros.
POINTS DE VIGILANCE :
- Les frais de route sont un remboursement de frais professionnels, et non du salaire : ils ne supportent ni cotisations sociales ni impôt sur le revenu tant qu'ils respectent les barèmes conventionnels, et ils doivent figurer distinctement sur le bulletin de paie (ils n'entrent donc pas dans l'assiette des cotisations ni dans le calcul des heures supplémentaires).
- Seule la partie « salaire » (3 179,84 euros) est soumise à cotisations.$corr$,
  scoring_grid    = $corr$Total 6 points.
- Heures légales (conventionnelles) du mois : 43 x 4 = 172 h : 0,5 pt
- Heures supplémentaires totales : 196 - 172 = 24 h : 0,5 pt
- Heures supplémentaires à 25 % : 8 x 15,20 x 1,25 = 152,00 euros : 1 pt
- Heures supplémentaires à 50 % : (24 - 8) x 15,20 x 1,50 = 364,80 euros : 1 pt
- Salaire de base : 172 x 15,20 = 2 614,40 euros : 0,75 pt
- Majoration de nuit : 16 x 15,20 x 20 % = 48,64 euros : 0,75 pt
- Frais de couchage : 22 x 39,48 = 868,56 euros : 0,5 pt
- Frais de repas : 28 x 15,96 = 446,88 euros : 0,5 pt
- Total des frais de route exonérés : 1 315,44 euros, avec distinction salaire / frais professionnels : 0,5 pt
Total = 0,5 + 0,5 + 1 + 1 + 0,75 + 0,75 + 0,5 + 0,5 + 0,5 = 6,00 points.
Bonus de cohérence (non coté séparément) : salaire brut 3 179,84 euros ; total versé 4 495,28 euros.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch10:ex10.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$MÉTHODE EN 5 ÉTAPES APPLIQUÉE À LA PANNE DU TRR-05 / SREM-05 (mardi 23/03/20AA, 11h45, A71 à hauteur de Riom)

Étape 1 — Identifier le problème (qualifier les faits)
Recueillir auprès de Thierry MULLER les éléments objectifs : nature de l'avarie (panne moteur, véhicule immobilisé), localisation précise (A71 à hauteur de Riom, sens de circulation, PK ou aire, bande d'arrêt d'urgence ou non), heure de survenance (11h45 le 23/03), état du conducteur et sécurisation immédiate (gilet haute visibilité, triangle de présignalisation, mise en sécurité derrière la glissière), état de la marchandise (18 palettes de pièces mécaniques, non périssables, non sensibles, non ADR), immobilisation confirmée par le service dépannage avec un délai d'intervention de 3 heures minimum. Vérifier les documents de bord, le contrat d'assistance / dépannage et le contrat d'assurance du véhicule.

Étape 2 — Évaluer les conséquences
- Délai : dépannage à 3 h minimum, soit une intervention vers 14h45 au plus tôt, suivie d'une réparation sur place ou d'un remorquage. La livraison SKODA à Montpellier prévue à 15h00 est donc impossible à tenir (Clermont-Ferrand – Montpellier représente environ 330 km, soit de l'ordre de 3 h 30 à 4 h de conduite). Retard prévisible de plusieurs heures.
- Réglementaire (règlement CE 561/2006) : contrôler les temps déjà réalisés par MULLER — conduite continue de 4 h 30 maximum avant une pause de 45 minutes (fractionnable en 15 min puis 30 min), conduite journalière de 9 h (10 h deux fois par semaine au maximum), repos journalier de 11 h (réductible à 9 h, trois fois entre deux repos hebdomadaires). L'attente du dépanneur est enregistrée en autre tâche ou en disponibilité selon le cas, mais elle consomme l'amplitude et peut rendre la poursuite de la mission impossible.
- Commercial : risque de rupture d'approvisionnement de la ligne de production du client, pénalités éventuelles, atteinte à l'image de l'entreprise.
- Économique : coût du dépannage et du remorquage, du transbordement, du véhicule et du conducteur de relève, de l'immobilisation du tracteur et de la semi-remorque.

Étape 3 — Mettre en œuvre une solution (transbordement + relève)
Solution retenue : engager immédiatement l'ensemble routier TRR-02 / SREM-01 (fourgon) disponible au dépôt de Clermont-Ferrand, situé à 15 km, avec le conducteur Martin LACHAUD, immédiatement disponible.
- Faire déplacer le véhicule en panne vers une aire ou une zone sécurisée si c'est possible ; à défaut, organiser le transbordement après remorquage sur un site sûr (le transbordement est interdit sur la bande d'arrêt d'urgence et sur les voies de circulation).
- Transbordement des 18 palettes du SREM-05 vers le SREM-01, avec contrôle contradictoire du nombre et de l'état des colis, prise de photos et émargement d'un bon de transbordement.
- Établir l'ordre de mission de LACHAUD : adresse du client SKODA à Montpellier, documents de transport, lettre de voiture annotée de la mention du transbordement et du changement de véhicule.
- Vérifier la compatibilité de la mission avec les temps de conduite et de repos de LACHAUD (561/2006) et l'adéquation du fourgon (capacité, hauteur, hayon si nécessaire, PTAC et charge utile suffisants pour 18 palettes).
- Gérer le retour de MULLER : attente du dépanneur ou récupération par un véhicule de service, en respectant son repos journalier de 11 h.
- Maintenir la commande du dépannage et organiser le rapatriement du TRR-05 / SREM-05 à l'atelier.
Estimation : transbordement achevé vers 13h30-14h00, puis route vers Montpellier ; arrivée réaliste en fin d'après-midi (ordre de grandeur 18h00), à faire confirmer par le client, avec report au lendemain matin en première position si le site de réception est fermé.

Étape 4 — Informer les interlocuteurs
- Le client SKODA : appel immédiat, avant l'heure de livraison prévue, puis confirmation écrite par courriel.
- Le conducteur MULLER : consignes de sécurité, d'attente et de report des temps sur le chronotachygraphe.
- Le conducteur LACHAUD : ordre de mission et consignes de transbordement.
- L'atelier, le service dépannage / assistance et l'assureur.
- La direction d'exploitation et le service commercial.
- Le cas échéant, le donneur d'ordre ou l'expéditeur des pièces (MECA-CONCEPT / chargeur).

Étape 5 — Tracer l'événement
- Enregistrement de l'aléa dans le TMS : horodatage 11h45, code incident « panne mécanique », véhicule TRR-05 / SREM-05, position, nature et conséquences.
- Rapport d'incident du conducteur, photos, bon d'intervention du dépanneur, bon de transbordement signé.
- Mise à jour de la lettre de voiture (mention du transbordement et du nouveau véhicule), du planning des conducteurs et de la disponibilité du parc.
- Enregistrement des coûts pour refacturation ou déclaration de sinistre, alimentation de l'historique de fiabilité du véhicule (maintenance préventive) et des indicateurs qualité (taux de service, retards).

MESSAGE AU CLIENT SKODA (appel immédiat, confirmé par écrit)
« Objet : Livraison du 23/03 – 18 palettes de pièces mécaniques – Information retard
Bonjour,
Notre véhicule assurant votre livraison prévue ce jour à 15h00 est immobilisé depuis 11h45 sur l'autoroute A71, à hauteur de Riom, en raison d'une panne moteur. Nous avons immédiatement mis en place une solution de substitution : un second ensemble routier et un conducteur de relève partent de notre dépôt de Clermont-Ferrand afin de transborder l'intégralité de vos 18 palettes, qui sont intactes et sécurisées.
Compte tenu de cette opération, la livraison ne pourra pas être effectuée à 15h00. Nous estimons une présentation sur votre site en fin d'après-midi, aux alentours de 18h00. Merci de nous confirmer si cet horaire est compatible avec vos contraintes de réception ; à défaut, nous vous proposons une livraison demain matin dès l'ouverture, traitée en priorité absolue.
Nous vous tiendrons informé dès le départ du véhicule de relève et vous prions de nous excuser pour ce désagrément.
Cordialement, le service exploitation TRANS EXPRESS. »
Le message est factuel et transparent, il annonce la solution avant que le client ne constate lui-même le retard, propose une alternative et engage un suivi.$corr$,
  scoring_grid    = $corr$Total 6 points (barème détaillé : 0,75 + 1 + 1,75 + 0,75 + 0,75 + 1 = 6).
- Étape 1, identification du problème (0,75 pt) : faits qualifiés (nature, lieu, heure), sécurisation du conducteur, état des 18 palettes.
- Étape 2, évaluation des conséquences (1 pt) : impossibilité de tenir 15h00 démontrée (3 h de dépannage + environ 3 h 30 à 4 h de trajet), 0,5 ; conséquences réglementaires (règlement CE 561/2006 : 4 h 30 de conduite continue, pause 45 min, 9 h de conduite journalière, 11 h de repos journalier), commerciales et économiques, 0,5.
- Étape 3, mise en œuvre de la solution (1,75 pt) : choix du transbordement sur le TRR-02 / SREM-01 avec relève par LACHAUD, 0,75 ; modalités opérationnelles (zone sécurisée, transbordement interdit sur BAU, contrôle contradictoire des 18 palettes, documents, ordre de mission), 0,5 ; prise en compte des temps de conduite et de repos des deux conducteurs et du retour de MULLER, 0,5.
- Étape 4, information des interlocuteurs (0,75 pt) : client prévenu sans délai, avant l'heure de livraison (0,25) ; liste des autres interlocuteurs internes et externes (0,5).
- Étape 5, traçabilité (0,75 pt) : saisie TMS horodatée, rapport d'incident, bon de transbordement, mise à jour de la lettre de voiture et du planning, suivi des coûts.
- Message au client SKODA (1 pt) : structure professionnelle et objet clair (0,25), annonce factuelle et transparente du problème (0,25), solution et nouvel horaire proposés (0,25), demande de confirmation, excuses et engagement de suivi (0,25).
Pénalité possible de 0,5 pt en cas de solution non réaliste (par exemple attendre la réparation, ou transborder sur la bande d'arrêt d'urgence) ou de langage non professionnel dans le message client.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch11:ex11.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch11:ex11.2] : [À CONFIRMER: l'énoncé stocké en base s'arrête sur la mention « Programme initial de la tournée » sans le tableau correspondant (clients, heures de passage, durées de déchargement, contraintes horaires). Seul le client B est identifiable, via la question 3 (« heure impérative »). Le corrigé fournit donc la méthode de recalcul et le raisonnement de priorisation, sans pouvoir nommer les autres clients ni chiffrer les nouvelles heures d'arrivée. Action : réintégrer le tableau de la tournée dans le statement, puis compléter le corrigé avec la liste nominative des clients impactés et les heures recalculées (+1 h 45).]
UPDATE public.question_bank SET
  expected_answer = $corr$GESTION D'UN RETARD EN CASCADE (embouteillage sur l'A72, retard estimé 1 h 45, signalé à 9h15 par le conducteur Thierry MULLER)

Principe : un retard survenu au cours d'une tournée de distribution se propage à toutes les livraisons situées en aval du point de blocage. Le raisonnement consiste à recalculer les heures d'arrivée prévisionnelles, à identifier les clients dont le créneau n'est plus tenable, puis à traiter en priorité les rendez-vous impératifs.

1. Clients impactés
Sont impactés tous les clients restant à livrer après 9h15, c'est-à-dire ceux situés en aval de l'incident dans le programme de tournée. Il faut reconstituer le nouvel horaire prévisionnel en ajoutant 1 h 45 à chaque heure d'arrivée théorique restante (les temps de déchargement et les temps de conduite entre points restant inchangés). Les clients déjà livrés avant 9h15 ne sont pas concernés. Sont particulièrement impactés :
- les clients dont la fenêtre horaire de réception est dépassée une fois le retard reporté ;
- le client B, qui dispose d'une heure de livraison impérative ;
- les clients situés en fin de tournée, dont la livraison risque de tomber après l'heure de fermeture du site.
Il faut par ailleurs contrôler le temps de service du conducteur (règlement CE 561/2006 : conduite continue de 4 h 30 maximum suivie d'une pause de 45 minutes, fractionnable en 15 min puis 30 min ; conduite journalière de 9 h ; repos journalier de 11 h) : l'attente dans l'embouteillage est du temps de conduite ou d'autre tâche, elle consomme l'amplitude et peut rendre la fin de tournée impossible dans la journée.

2. Ordre d'appel des clients et justification
On contacte les clients par ordre de criticité, et non par ordre géographique :
1er : le client B, parce que son heure de livraison est impérative (rendez-vous ferme, plage de réception non négociable, risque de refus de la marchandise ou de pénalité). C'est le seul dont le retard est réellement bloquant.
2e : les clients dont la fenêtre horaire est étroite ou dont la fermeture est proche (risque de livraison manquée et de retour à vide).
3e : les clients à réception souple, prévenus par simple information de courtoisie.
Justification : anticiper vaut mieux que subir. Prévenir un client avant l'heure prévue préserve la relation commerciale, lui permet de réorganiser sa réception et évite un litige, alors qu'un client qui découvre lui-même le retard le vit comme une faute du transporteur.

3. Solution proposée pour le client B (heure impérative)
Plusieurs options, à combiner selon la faisabilité :
- Réordonnancer la tournée : livrer B en premier en inversant l'ordre des points, si la position géographique le permet et si les autres clients acceptent un décalage.
- Négocier avec B un report du créneau dans la journée (nouvelle heure ferme), après appel de son service réception.
- Engager un véhicule de renfort ou une navette au départ du dépôt de Clermont-Ferrand pour livrer B dans le créneau imposé, avec transbordement de sa marchandise.
- En dernier recours, sous-traiter la livraison de B à un confrère ou à une messagerie locale, ou reporter la livraison au lendemain matin en première position, avec l'accord écrit du client.
Dans tous les cas : obtenir l'accord du client sur la solution retenue, le tracer par écrit (courriel ou SMS de confirmation) et enregistrer l'aléa ainsi que la décision dans le TMS.

4. SMS professionnel au client B
« TRANS EXPRESS – Bonjour, votre livraison prévue ce jour est impactée par un blocage important sur l'A72 (retard estimé 1 h 45). Nous mettons tout en œuvre pour respecter votre créneau impératif : le véhicule est réorienté vers votre site en priorité. Nouvelle heure d'arrivée estimée : [heure]. Merci de nous confirmer si ce créneau reste compatible ; à défaut, nous vous proposons une livraison de renfort dans votre plage horaire. Contact exploitation : [nom, téléphone]. Nous vous prions de nous excuser pour ce désagrément. »
Le SMS est court, identifie l'expéditeur, expose la cause, l'impact chiffré, la solution et la nouvelle heure, demande une confirmation et laisse un contact.$corr$,
  scoring_grid    = $corr$Total 6 points (barème détaillé : 1,5 + 1,5 + 2 + 1 = 6).
- Question 1, clients impactés (1,5 pt) : méthode de recalcul des heures d'arrivée par report du retard de 1 h 45 sur tous les points restants (0,75) ; identification correcte des clients en aval de 9h15, dont le client B, et prise en compte des fenêtres horaires ainsi que du temps de service du conducteur (0,75).
- Question 2, ordre et justification des appels (1,5 pt) : priorisation par criticité, client B en premier (0,75) ; justification par l'anticipation, la préservation de la relation commerciale et l'évitement du litige (0,75).
- Question 3, solution pour le client B (2 pts) : au moins deux solutions pertinentes et réalistes parmi réordonnancement de la tournée, renégociation du créneau, véhicule de renfort avec transbordement, sous-traitance, report avec accord (1,25) ; formalisation de l'accord client et traçabilité TMS (0,75).
- Question 4, SMS professionnel (1 pt) : identification de l'entreprise et concision (0,25), cause et impact annoncés (0,25), solution et nouvelle heure estimée (0,25), demande de confirmation, contact et formule d'excuse (0,25).
Tolérance de correction : tant que le tableau du programme de tournée n'est pas rétabli dans l'énoncé, la question 1 est notée sur la méthode de recalcul et non sur l'exactitude des heures ou des noms de clients.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch11:ex11.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch11:ex11.3] : [À CONFIRMER: deux points de forme sur la question 1. (1) Décompte du délai de l'article L.133-3 : la formulation historique du texte exclut « les dimanches et jours de fête légale », tandis que la rédaction en vigueur vise « les trois jours, non compris les jours fériés, qui suivent celui de la réception ». Selon la lecture retenue, l'échéance à partir d'une réception le vendredi 28/03 est soit le mardi 01/04 (dimanche exclu, lecture retenue dans le corrigé et conforme à l'ancrage pédagogique du référentiel), soit le lundi 31/03 (dimanche non exclu). Vérifier la rédaction exacte de L.133-3 en vigueur en 2026 et harmoniser corrigé + cours ; en attendant, le barème accepte toute date correctement justifiée. (2) L'année de l'énoncé est « 20AA » : le fait que le 28/03 tombe un vendredi est une donnée de l'énoncé, non vérifiable calendairement, et la présence éventuelle d'un jour férié dans l'intervalle ne peut pas être tranchée.]
UPDATE public.question_bank SET
  expected_answer = $corr$REFUS PARTIEL DE LIVRAISON — PRODUITS SURGELÉS (client FRUITS SECS, Mâcon, vendredi 28/03, 14h30, conducteur Martin LACHAUD)

Contexte : rupture de la chaîne du froid constatée à la réception — 5 palettes de fruits congelés à maintenir à −18 °C, température relevée dans la caisse à −12 °C, seuil critique maximal fixé à −15 °C. Le client accepte 2 palettes avec réserves et refuse 3 palettes.

1. Confirmation des réserves sur les 2 palettes acceptées
- Les réserves doivent être portées sur le document de transport (lettre de voiture ou récépissé) au moment même de la livraison. Elles doivent être précises, motivées et significatives, par exemple : « température relevée −12 °C à 14h30 au lieu de −18 °C contractuels, seuil critique −15 °C, 2 palettes acceptées sous réserve de contrôle qualité ultérieur ». Des réserves vagues du type « sous réserve de déballage » sont sans valeur.
- L'étendue réelle du dommage n'étant pas apparente (l'altération des fruits congelés ne se révèle qu'après contrôle qualité), l'article L.133-3 du Code de commerce impose que les réserves soient confirmées par une protestation motivée écrite adressée au transporteur, par acte extrajudiciaire ou par lettre recommandée (avec accusé de réception dans la pratique), dans les trois jours suivant celui de la réception, non compris les dimanches et les jours fériés. À défaut, il y a forclusion : l'action contre le transporteur pour avarie ou perte partielle est éteinte. La confirmation n'est en principe pas exigée lorsque le transporteur a expressément accepté et contresigné les réserves, mais la prudence commande de la faire dans tous les cas.
- Application au cas d'espèce : la réception a lieu le vendredi 28/03. Le délai court à compter du lendemain ; en excluant le dimanche 30/03, les trois jours utiles conduisent à un envoi de la lettre recommandée au plus tard le mardi 01/04 (à ajuster si un jour férié tombe dans cet intervalle, ce qui repousserait d'autant l'échéance).
- Rôle du gestionnaire de transport : demander au conducteur d'exiger que les réserves soient écrites et contresignées sur les deux exemplaires du document de transport, en récupérer une copie, alerter le service litiges pour que la confirmation écrite soit suivie côté transporteur, et émettre lui-même des réserves auprès du sous-traitant ou du loueur du groupe frigorifique le cas échéant.

2. Décisions d'exploitation sur les 3 palettes refusées
- Ne jamais abandonner ni détruire la marchandise de sa propre initiative : le transporteur n'est ni propriétaire ni destinataire. Le refus de réception caractérise un empêchement à la livraison : le transporteur doit demander des instructions à l'expéditeur ou au donneur d'ordre, et il reste gardien de la marchandise.
- Maintenir impérativement le groupe frigorifique en fonctionnement et ramener la consigne à −18 °C pour éviter toute aggravation, en relevant et en enregistrant les températures (impression du disque ou du relevé de l'enregistreur de température).
- Faire constater l'état de la marchandise : relevé contradictoire des températures avec le client, photos, impression du ticket de l'enregistreur, recours éventuel à un expert ou à un commissaire de justice si l'enjeu financier le justifie.
- Demander par écrit des instructions au donneur d'ordre ou à l'expéditeur, dans un délai court : retour au dépôt en zone de quarantaine sous température dirigée, retour à l'expéditeur, réexpédition vers un autre destinataire, mise à disposition dans un entrepôt frigorifique tiers, ou destruction (uniquement sur instruction écrite du propriétaire ou sur décision des services vétérinaires, avec bordereau de destruction, s'agissant de denrées alimentaires).
- Suivre et imputer au dossier litige tous les frais engagés (immobilisation, retour, entreposage frigorifique, destruction).
- Bloquer les 3 palettes en attente d'instruction : elles ne doivent pas être remises dans un circuit de livraison.

3. Interlocuteurs à contacter dans les deux heures
- Le conducteur Martin LACHAUD : consignes précises, rédaction du rapport d'incident, maintien du froid, interdiction de repartir sans instruction.
- Le client destinataire FRUITS SECS : formalisation du refus et des réserves, récupération des documents signés.
- Le donneur d'ordre / expéditeur, propriétaire de la marchandise : information immédiate et demande d'instruction écrite.
- Le service exploitation et la direction, ainsi que le service litiges / qualité de TRANS EXPRESS.
- L'assureur « marchandises transportées » et le courtier : déclaration de sinistre.
- L'atelier ou le prestataire de maintenance du groupe frigorifique : diagnostic de la panne, cause probable de la remontée en température, intervention.
- Le cas échéant, le responsable qualité / HACCP de l'entreprise et le prestataire d'entreposage frigorifique de repli.

4. Informations et événements à enregistrer dans le TMS
- Identification du dossier : numéro de mission ou d'ordre de transport, date et heure de l'événement (28/03 à 14h30), lieu (Mâcon), conducteur (LACHAUD), véhicule et caisse frigorifique, client FRUITS SECS.
- Nature de l'aléa : rupture de la chaîne du froid, température constatée −12 °C, température contractuelle −18 °C, seuil critique −15 °C.
- Statut de la livraison : livraison partielle — 2 palettes livrées avec réserves, 3 palettes refusées (statut « refusé » ou « en attente d'instruction ») — avec motif codifié.
- Documents rattachés : lettre de voiture avec réserves scannée, relevé ou ticket de l'enregistreur de température, photos, rapport d'incident du conducteur, échanges écrits avec le donneur d'ordre.
- Chronologie horodatée des actions : appel au donneur d'ordre, instruction reçue, destination des 3 palettes, retour au dépôt ou entreposage, déclaration de sinistre, envoi de la protestation motivée par lettre recommandée, avec alerte de suivi sur l'échéance du délai de trois jours de l'article L.133-3.
- Volet financier et qualité : coûts de l'incident (retour, entreposage, destruction, immobilisation), imputation au dossier litige, ouverture d'une fiche de non-conformité, action corrective (contrôle et maintenance préventive du groupe froid, pré-refroidissement de la caisse, contrôle de la température au chargement).$corr$,
  scoring_grid    = $corr$Total 6 points (barème détaillé : 1,75 + 1,75 + 1,25 + 1,25 = 6).
- Question 1, réserves et confirmation (1,75 pt) : réserves précises et motivées portées sur le document de transport au moment de la livraison (0,5) ; nécessité de confirmer par une protestation motivée écrite, par lettre recommandée ou acte extrajudiciaire, adressée au transporteur (0,5) ; délai de trois jours suivant la réception, non compris les dimanches et jours fériés, fondement de l'article L.133-3 du Code de commerce, et sanction de forclusion (0,5) ; application datée au cas d'espèce à partir de la réception du vendredi 28/03 (0,25 — accepter toute date correctement justifiée par le décompte retenu).
- Question 2, décisions d'exploitation sur les 3 palettes refusées (1,75 pt) : maintien du froid et enregistrement des températures, interdiction de détruire ou d'abandonner la marchandise (0,5) ; demande d'instruction écrite au donneur d'ordre au titre de l'empêchement à la livraison, transporteur gardien de la marchandise (0,75) ; constat contradictoire, preuves et options de destination (retour dépôt sous température dirigée, retour expéditeur, entrepôt frigorifique, destruction sur instruction écrite) avec suivi des frais (0,5).
- Question 3, interlocuteurs dans les deux heures (1,25 pt) : au moins cinq interlocuteurs pertinents parmi conducteur, client destinataire, donneur d'ordre / expéditeur, exploitation / direction, service litiges, assureur, atelier ou prestataire du groupe frigorifique (0,25 par interlocuteur pertinent, plafonné à 1,25).
- Question 4, traçabilité TMS (1,25 pt) : identification du dossier et horodatage (0,25) ; nature de l'aléa et températures relevées (0,25) ; statut de la livraison partielle et motifs codifiés (0,25) ; pièces justificatives rattachées — lettre de voiture avec réserves, relevé de température, photos, rapport d'incident (0,25) ; chronologie des actions, coûts et non-conformité qualité avec action corrective (0,25).$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch11:ex11.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$FACTURATION DE LA MISSION TR25-532 (MECA-CONCEPT → RENAULT TRUCKS, Clermont-Ferrand → Montpellier). Facture émise le 23/03/20AA, paiement à 30 jours date de facture.

1. Total HT de la facture
Transport principal HT ......... 456,80 €
Prestations annexes HT ......... 104,26 €
Pied de facture (gazole) HT ..... 18,50 €
TOTAL HT = 456,80 + 104,26 + 18,50 = 579,56 €
Remarque : le pied de facture gazole n'est ni une remise ni une taxe. C'est un poste de facturation à part entière, issu du mécanisme légal d'indexation obligatoire du prix du transport sur la variation du prix du gazole (articles L.3222-1 et L.3222-2 du Code des transports). Il entre donc bien dans l'assiette HT.

2. TVA (transport national)
Une prestation de transport routier de marchandises réalisée intégralement en France, entre deux points du territoire national, relève du taux normal de TVA, soit 20 %.
TVA = 579,56 × 0,20 = 115,912 → arrondi à 115,91 €.

3. Montant TTC
TOTAL TTC = 579,56 + 115,91 = 695,47 €.

Récapitulatif du pied de facture :
Transport principal HT ............. 456,80 €
Prestations annexes HT ............. 104,26 €
Pied de facture (gazole) HT ......... 18,50 €
TOTAL HT ........................... 579,56 €
TVA 20 % ........................... 115,91 €
TOTAL TTC .......................... 695,47 €

4. Mention obligatoire relative aux pénalités de retard
Toute facture doit mentionner la date d'échéance du règlement — ici le 22/04/20AA, soit 30 jours après la date d'émission du 23/03/20AA — ainsi que le taux des pénalités de retard exigibles le jour suivant la date de règlement figurant sur la facture. Ces pénalités sont dues de plein droit, sans qu'un rappel soit nécessaire.
Mention type : « En cas de retard de paiement, des pénalités de retard sont exigibles le jour suivant la date de règlement figurant sur la facture, sans qu'un rappel soit nécessaire. Taux applicable : taux d'intérêt appliqué par la Banque centrale européenne à son opération de refinancement la plus récente, majoré de 10 points de pourcentage ; ce taux ne peut être inférieur à trois fois le taux d'intérêt légal. Tout retard de paiement entraîne en outre l'exigibilité d'une indemnité forfaitaire pour frais de recouvrement de 40 €, sans préjudice d'une indemnisation complémentaire sur justificatifs si les frais réellement exposés sont supérieurs. »
Rappel sectoriel important : en transport routier de marchandises, en location de véhicules avec ou sans conducteur et en commission de transport, le délai de paiement convenu ne peut dépasser 30 jours à compter de la date d'émission de la facture (article L.441-11 du Code de commerce). Le délai contractuel de 30 jours date de facture retenu ici est donc conforme, et ne pourrait pas être allongé.

5. Indemnité forfaitaire pour frais de recouvrement
Le montant de l'indemnité forfaitaire légalement due en cas de retard de paiement est de 40 € par facture impayée (article L.441-10 du Code de commerce, montant fixé par l'article D.441-5). Elle s'ajoute aux pénalités de retard, elle est due de plein droit, et le créancier peut demander une indemnisation complémentaire, sur justificatifs, si les frais de recouvrement réellement exposés dépassent ce montant.$corr$,
  scoring_grid    = $corr$Total 6 points (barème détaillé : 1 + 1 + 1 + 2 + 1 = 6).
- Question 1, total HT (1 pt) : addition correcte des trois postes, 456,80 + 104,26 + 18,50 = 579,56 € (0,75) ; justification de l'intégration du pied de facture gazole dans l'assiette HT — poste de facturation issu de l'indexation gazole obligatoire, ni remise ni taxe (0,25).
- Question 2, TVA (1 pt) : identification du taux normal de 20 % pour un transport national (0,5) ; calcul exact 579,56 × 0,20 = 115,91 € (0,5).
- Question 3, TTC (1 pt) : 579,56 + 115,91 = 695,47 € (0,75) ; présentation correcte du pied de facture HT / TVA / TTC (0,25).
- Question 4, mention des pénalités de retard (2 pts) : mention de la date d'échéance, ici le 22/04/20AA (0,5) ; taux des pénalités — taux BCE majoré de 10 points, plancher de trois fois le taux d'intérêt légal (0,75) ; exigibilité de plein droit sans rappel nécessaire (0,25) ; rappel du plafond légal de 30 jours date de facture propre au transport routier, article L.441-11 du Code de commerce (0,5).
- Question 5, indemnité forfaitaire (1 pt) : montant de 40 € par facture (0,75) ; caractère de plein droit et possibilité d'une indemnisation complémentaire sur justificatifs (0,25).
Aucun point sur les questions 1 à 3 si le pied de facture gazole est omis de l'assiette HT ou traité comme une remise ou une taxe.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch12:ex12.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$1) RECEVABILITÉ DU LITIGE
Oui, le litige est recevable.
L'avarie est apparente (mouille visible sur 2 palettes). Le destinataire a formulé des réserves précises, motivées et complètes sur la lettre de voiture au moment de la livraison (des réserves vagues du type « sous réserve de déballage » seraient inopposables au transporteur).
Ces réserves ont été confirmées par lettre recommandée avec accusé de réception 2 jours après la livraison, donc dans le délai de 3 jours (non compris les dimanches et jours fériés) prévu par l'article L.133-3 du Code de commerce. À défaut, l'action aurait été forclose.
Le destinataire conserve ensuite un an pour agir (prescription annale de l'article L.133-6 du Code de commerce).
Conditions cumulatives réunies : réserves écrites et motivées à la livraison + confirmation par LRAR dans le délai légal, donc dossier recevable.
Sur le fond, le transporteur est responsable de plein droit des pertes et avaries (présomption de responsabilité, article L.133-1 du Code de commerce), sauf preuve d'une cause exonératoire (force majeure, vice propre de la marchandise, faute de l'ayant droit).

2) PLAFOND D'INDEMNISATION (contrat type général, envoi inférieur à 3 tonnes)
Régime applicable : envoi de 2,2 t, donc inférieur à 3 t. Double limitation : 33 euros par kilogramme de marchandise manquante ou avariée, sans pouvoir dépasser 1 000 euros par colis perdu ou avarié.
a) Par kg : 280 kg x 33 euros = 9 240 euros
b) Par colis : 2 palettes avariées x 1 000 euros = 2 000 euros
c) Plafond retenu : le plus faible des deux montants, soit 2 000 euros.
Indemnité due = plus petit montant entre le préjudice réel prouvé (3 800 euros) et le plafond (2 000 euros), soit 2 000 euros.
L'ayant droit supporte donc un reste à charge de 3 800 - 2 000 = 1 800 euros.

3) DÉPASSEMENT DU PLAFOND
Oui, le plafond peut être écarté dans les cas suivants :
- dol ou faute inexcusable (faute lourde) du transporteur ou de ses préposés ;
- déclaration de valeur souscrite par l'expéditeur, qui se substitue au plafond légal ;
- déclaration d'intérêt spécial à la livraison (préjudice lié au retard) ;
- convention écrite contraire entre les parties, prévoyant une indemnité supérieure ;
- le contrat type est supplétif : les parties peuvent y déroger par accord exprès.
À noter : la charge de la preuve de la faute inexcusable pèse sur celui qui l'invoque.

4) EFFET D'UNE DÉCLARATION DE VALEUR DE 4 500 EUROS
La déclaration de valeur, mentionnée sur la lettre de voiture et facturée par un supplément de prix (ad valorem), substitue le montant déclaré au plafond réglementaire.
Le plafond passerait de 2 000 euros à 4 500 euros.
L'indemnité resterait limitée au préjudice réellement subi et prouvé, soit 3 800 euros (l'indemnisation est réparatrice, jamais lucrative).
Gain pour l'expéditeur : 3 800 - 2 000 = 1 800 euros d'indemnisation supplémentaire, en contrepartie du supplément de prix payé au transporteur.$corr$,
  scoring_grid    = $corr$Q1 Recevabilité (2 pts) : avarie apparente identifiée 0,5 ; réserves précises et motivées portées sur la LV à la livraison 0,5 ; confirmation LRAR dans les 3 jours hors dimanches et fériés (art. L.133-3), délai respecté 0,5 ; conclusion « litige recevable » (mention de la prescription annale art. L.133-6 ou de la présomption de responsabilité art. L.133-1 valorisée) 0,5.
Q2 Plafond (2 pts) : régime « envoi < 3 t » correctement identifié 0,25 ; a) 280 x 33 = 9 240 euros 0,5 ; b) 2 x 1 000 = 2 000 euros 0,5 ; c) plafond retenu = 2 000 euros (le plus faible) 0,5 ; indemnité due 2 000 euros au lieu de 3 800 euros 0,25.
Q3 Dépassement du plafond (1 pt) : 0,25 par cas cité et correct parmi dol/faute inexcusable, déclaration de valeur, déclaration d'intérêt spécial, convention écrite contraire (max 1 pt).
Q4 Déclaration de valeur (1 pt) : substitution du montant déclaré au plafond légal 0,4 ; indemnité limitée au préjudice réel 3 800 euros 0,4 ; contrepartie = supplément de prix ad valorem 0,2.
Total = 6 points (= max_score).$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch12:ex12.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$1) RECEVABILITÉ DU LITIGE
Oui, le litige est recevable.
Il s'agit d'avaries apparentes (dommages visibles liés à un défaut d'arrimage). Les deux conditions cumulatives sont réunies :
- des réserves écrites, précises, motivées et complètes ont été portées sur la lettre de voiture au moment de la livraison (nature du dommage, nombre de palettes concernées, cause apparente) ;
- ces réserves ont été confirmées par lettre recommandée avec accusé de réception dans le délai réglementaire de 3 jours, non compris les dimanches et jours fériés (article L.133-3 du Code de commerce).
À défaut, il y aurait eu forclusion, c'est-à-dire extinction du droit d'agir. L'action se prescrit ensuite par un an (article L.133-6 du Code de commerce).
Sur le fond, le défaut d'arrimage relève en principe de la responsabilité du transporteur (présomption de responsabilité de plein droit, article L.133-1), sauf à démontrer une cause exonératoire : force majeure, vice propre de la marchandise, faute de l'ayant droit (par exemple un chargement et un arrimage réalisés par l'expéditeur et acceptés sans réserve).

2) PLAFOND D'INDEMNISATION (contrat type général, envoi égal ou supérieur à 3 tonnes)
Envoi de 5,8 t, donc régime « envoi égal ou supérieur à 3 t ». Double limitation : 20 euros par kilogramme de marchandise manquante ou avariée, sans pouvoir dépasser, par envoi, le produit du poids brut de l'envoi exprimé en tonnes par 3 200 euros.
a) Limite au poids avarié : 1 150 kg x 20 euros = 23 000 euros
b) Limite par envoi : 5,8 t x 3 200 euros = 18 560 euros
c) Plafond retenu : le plus faible des deux, soit 18 560 euros.
Préjudice réel prouvé : 7 200 euros.
Indemnité due = 7 200 euros, car le préjudice réel est inférieur au plafond. L'ayant droit est ici intégralement indemnisé (le plafond ne joue pas).

3) DÉPASSEMENT DU PLAFOND RÉGLEMENTAIRE
Le plafond peut être écarté :
- en cas de dol ou de faute inexcusable (faute lourde) du transporteur ou de ses préposés ;
- en présence d'une déclaration de valeur souscrite par l'expéditeur ;
- en présence d'une déclaration d'intérêt spécial à la livraison (préjudice de retard) ;
- par convention écrite contraire, le contrat type n'étant que supplétif de la volonté des parties.

4) INCIDENCE D'UNE DÉCLARATION DE VALEUR
La déclaration de valeur, portée sur la lettre de voiture et facturée par un supplément de prix (ad valorem), substitue le montant déclaré aux plafonds réglementaires.
Dans ce dossier, elle n'aurait eu aucune incidence financière : le préjudice réel (7 200 euros) est déjà très inférieur au plafond légal (18 560 euros), donc l'ayant droit est déjà indemnisé intégralement. La déclaration de valeur n'aurait généré qu'un coût supplémentaire sans contrepartie.
Elle n'a d'intérêt que lorsque la valeur réelle des marchandises transportées dépasse le plafond réglementaire (marchandises de forte valeur au kilo : électronique, cosmétiques, pharmacie).$corr$,
  scoring_grid    = $corr$Q1 Recevabilité (2 pts) : avarie apparente 0,25 ; réserves écrites précises et motivées sur la LV à la livraison 0,5 ; confirmation LRAR sous 3 jours hors dimanches et fériés, art. L.133-3, sinon forclusion 0,75 ; conclusion « recevable » + présomption de responsabilité du transporteur (art. L.133-1) ou prescription annale (art. L.133-6) 0,5.
Q2 Plafond (2 pts) : régime « envoi >= 3 t » identifié 0,25 ; 1 150 x 20 = 23 000 euros 0,5 ; 5,8 x 3 200 = 18 560 euros 0,75 ; plafond retenu 18 560 euros (le plus faible) 0,25 ; indemnité due = préjudice réel 7 200 euros car inférieur au plafond 0,25.
Q3 Dépassement du plafond (1 pt) : 0,25 par cas exact parmi dol/faute inexcusable, déclaration de valeur, déclaration d'intérêt spécial, convention écrite contraire (max 1 pt).
Q4 Déclaration de valeur (1 pt) : principe de substitution au plafond légal, contre supplément de prix 0,5 ; constat qu'ici elle est sans incidence puisque le préjudice réel est inférieur au plafond 0,5.
Total = 6 points (= max_score).$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch12:ex12.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch12:ex12.4] : [À CONFIRMER: l'annexe de l'exercice 12.4 (tableau des requêtes et réclamations clients TRANSGO / VIANDES OCCITANES) n'est pas accessible en base — le champ statement renvoie seulement à une pièce jointe (« Annexe à consulter »). Le corrigé fourni est une trame méthodologique complète assortie d'un barème proportionnel calé sur max_score = 6. Il devra être décliné situation par situation, avec les calculs chiffrés, une fois le contenu du tableau annexé récupéré.] Correction apportée : suppression du délai « 48 h » d'accusé de réception et du délai « 5 jours » de déclaration à l'assureur, qui ne sont pas des délais réglementaires (le délai de déclaration dépend du contrat d'assurance). Seuls les délais légaux sont cités (3 jours hors dimanches et fériés, art. L.133-3 ; prescription 1 an, art. L.133-6).
UPDATE public.question_bank SET
  expected_answer = $corr$MÉTHODE ATTENDUE (le tableau de l'annexe doit être complété situation par situation, selon la trame ci-dessous).

Pour chaque requête ou réclamation, le candidat doit dérouler quatre temps :

1) QUALIFIER LA SITUATION
Identifier la nature du dommage : perte totale, perte partielle ou manquant, avarie apparente, avarie non apparente, retard à la livraison, rupture de la chaîne du froid, refus de marchandise, non-conformité documentaire, réclamation commerciale sans dommage matériel.

2) VÉRIFIER LA RECEVABILITÉ
- Avarie ou manquant apparent : réserves écrites, précises et motivées sur la lettre de voiture au moment de la livraison, puis confirmation par LRAR dans les 3 jours, non compris les dimanches et jours fériés (article L.133-3 du Code de commerce).
- Avarie non apparente ou retard : protestation motivée par écrit (LRAR) dans ce même délai de 3 jours ; à défaut, forclusion.
- Prescription : un an à compter de la livraison (article L.133-6 du Code de commerce).
- Réserves vagues (« sous réserve de déballage », « sous réserve de contrôle ») : inopposables au transporteur, donc irrecevables.

3) DÉTERMINER LA RESPONSABILITÉ
Le transporteur est responsable de plein droit des pertes et avaries (présomption de responsabilité, article L.133-1 du Code de commerce). Il ne s'exonère qu'en prouvant :
- la force majeure ;
- le vice propre de la marchandise (produit déjà non conforme au départ, emballage défectueux fourni par l'expéditeur) ;
- la faute de l'ayant droit (chargement, calage ou arrimage réalisés par l'expéditeur, température de départ non conforme, adresse erronée).
En transport frigorifique (activité de TRANSGO pour VIANDES OCCITANES) : contrôler l'enregistreur de température, la conformité ATP du véhicule, la température au chargement relevée sur la lettre de voiture. Une température de chargement déjà non conforme exonère le transporteur ; une défaillance du groupe frigorifique l'engage.

4) ACTIONS À MENER ET INTERLOCUTEURS
- Accuser réception de la réclamation sans délai et ouvrir un dossier litige dans le TMS.
- Rassembler les preuves : lettre de voiture avec réserves, photos, bon de livraison, données du chronotachygraphe, relevé de température, rapport du conducteur.
- Faire réaliser une expertise contradictoire si le montant est significatif ou la responsabilité contestée.
- Interlocuteurs : conducteur, exploitation, client donneur d'ordres (VIANDES OCCITANES), destinataire, assureur RC transporteur (déclaration dans le délai prévu au contrat d'assurance), expert, éventuellement le sous-traitant et son assureur si l'opération a été sous-traitée.
- Actions correctives : plan d'action qualité (formation à l'arrimage, contrôle systématique de la température au chargement, maintenance préventive du groupe froid, procédure de prise de réserves).

5) CALCUL DE L'INDEMNISATION (contrat type général)
- Envoi inférieur à 3 t : 33 euros par kg de marchandise manquante ou avariée, sans dépasser 1 000 euros par colis.
- Envoi égal ou supérieur à 3 t : 20 euros par kg de marchandise manquante ou avariée, sans dépasser le produit du poids brut de l'envoi en tonnes par 3 200 euros.
- Retard : indemnité limitée au prix du transport (hors droits, taxes et frais divers), sur justification d'un préjudice.
- Indemnité due = plus petit montant entre le préjudice réel prouvé et le plafond applicable.
- Plafond écarté en cas de dol ou de faute inexcusable, de déclaration de valeur ou de déclaration d'intérêt spécial à la livraison.

CONCLUSION TYPE À PORTER DANS LA COLONNE « ACTIONS À MENER » : pour chaque ligne, indiquer la qualification, la recevabilité (oui ou non, avec le fondement), le responsable présumé, l'action immédiate, l'interlocuteur, puis le calcul de l'indemnisation chiffré lorsque le dommage est matériel.$corr$,
  scoring_grid    = $corr$Barème par situation du tableau de l'annexe, réparti à parts égales sur les lignes à traiter, chaque ligne étant notée sur 4 critères :
- Qualification correcte de la situation (perte, avarie apparente ou non apparente, retard, rupture de la chaîne du froid) : 25 % des points de la ligne.
- Recevabilité et fondement juridique cités (réserves sur la LV, LRAR sous 3 jours hors dimanches et fériés, art. L.133-3 ; prescription annale art. L.133-6 ; présomption de responsabilité art. L.133-1) : 25 %.
- Actions à mener et interlocuteurs identifiés (ouverture du dossier TMS, preuves, expertise contradictoire, déclaration à l'assurance RC transporteur, information du donneur d'ordres, action corrective) : 25 %.
- Calcul de l'indemnisation exact lorsqu'il est requis (bon régime < 3 t ou >= 3 t, double plafond appliqué, indemnité = min(préjudice réel ; plafond)) : 25 %.
Exemple pour un tableau de 4 situations : 1,5 point par situation, soit 0,375 par critère. Total = 6 points (= max_score), à répartir au prorata du nombre réel de lignes de l'annexe.
Toute réponse hors sujet ou tout plafond inventé est sanctionné par 0 sur le critère concerné.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch12:ex12.4' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$ORDRE CHRONOLOGIQUE DE CLÔTURE D'UN DOSSIER AVEC RÉSERVES

1. Photographier la marchandise avariée avant déchargement.
2. Vérifier le retour du CMR signé avec réserves.
3. Informer le donneur d'ordres de l'existence des réserves.
4. Ouvrir un dossier de suivi litige dans le TMS.
5. Transmettre le dossier à l'assurance RC transporteur.
6. Déclencher la facturation du transport.
7. Enregistrer le statut final dans le TMS : « clôturé avec réserves ».
8. Archiver le dossier (CMR signé + photos + échanges TMS).

JUSTIFICATION DE LA LOGIQUE
- Étapes 1 et 2 : la preuve se constitue sur le terrain, au moment même de la livraison. Les photographies sont prises avant déchargement, tant que la marchandise est encore dans la configuration où le dommage est constaté. Le CMR portant des réserves précises, motivées et datées est la pièce maîtresse du dossier : sans lui, l'action est fragilisée, la confirmation par LRAR devant intervenir dans les 3 jours, non compris les dimanches et jours fériés (article L.133-3 du Code de commerce).
- Étape 3 : le donneur d'ordres doit être informé sans délai, à la fois par devoir d'information contractuel et parce qu'il décide de la suite commerciale (avoir, remplacement, refus).
- Étape 4 : l'ouverture du dossier litige dans le TMS assure la traçabilité, le suivi des échanges et la maîtrise des délais (forclusion à 3 jours, prescription annale de l'article L.133-6).
- Étape 5 : la déclaration à l'assurance RC transporteur doit intervenir dans le délai prévu au contrat d'assurance (délai contractuel, à vérifier au contrat : ce n'est pas un délai légal).
- Étape 6 : la facturation du transport n'est pas suspendue par le litige. La prestation a été exécutée et le prix reste dû ; le litige suit une voie indemnitaire distincte, sans compensation unilatérale.
- Étapes 7 et 8 : le statut « clôturé avec réserves » puis l'archivage complet (CMR signé, photographies, échanges TMS, correspondances, décompte d'indemnisation) permettent de reconstituer le dossier pendant toute la durée de la prescription.$corr$,
  scoring_grid    = $corr$0,75 point par étape correctement positionnée, soit 8 x 0,75 = 6 points (= max_score).
Ordre attendu : 1 = Photographier la marchandise avariée avant déchargement ; 2 = Vérifier le retour du CMR signé avec réserves ; 3 = Informer le donneur d'ordres de l'existence des réserves ; 4 = Ouvrir un dossier de suivi litige dans le TMS ; 5 = Transmettre le dossier à l'assurance RC transporteur ; 6 = Déclencher la facturation du transport ; 7 = Enregistrer le statut final dans le TMS « clôturé avec réserves » ; 8 = Archiver le dossier (CMR signé + photos + échanges TMS).
Tolérance : l'inversion des étapes 5 et 6 (déclaration à l'assurance et facturation), menées en parallèle dans la pratique, n'est pas pénalisée ; les deux positions sont alors comptées justes.
Aucune étape ne peut recevoir de point partiel. Total = 6 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch12:ex12.5' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch13:ex13.1] : [À CONFIRMER: l'énoncé ne fournit aucun tableau d'objectifs et renvoie à une annexe non lisible en base. Les seuils d'alerte retenus (ponctualité 95 %, km à vide 15 %, litiges 1 %, remplissage 90 %, utilisation du parc 95 %) sont des seuils professionnels usuels, non réglementaires. Si l'annexe de l'exercice contient une grille d'objectifs propre à TRANS EXPRESS, ce sont ces seuils qui priment pour la question 2 et il faut ajuster corrigé et barème en conséquence.] Tous les résultats numériques du corrigé sont, eux, entièrement déduits des données du champ statement et ont été recalculés (128/142 = 90,14 % ; 3 200/14 800 = 21,62 % ; 4/142 = 2,82 % ; 186/232 = 80,17 % ; 40/40 = 100 %). Aucune donnée réglementaire (561/2006, capacité financière, poids et dimensions, L.133-3) n'est mobilisée par cet exercice.
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ - Exercice 13.1 : calculer et analyser les indicateurs KPI (TRANS EXPRESS, semaine 38)

DONNÉES DE L'ÉNONCÉ : 142 livraisons prévues, 128 livraisons à l'heure, 14 800 km parcourus dont 3 200 km à vide, 4 litiges ouverts pour 142 opérations, charge utile disponible 29 t x 8 véhicules = 232 t, charge transportée 186 t, 40 jours d'exploitation réalisés sur 40 jours disponibles (5 jours x 8 véhicules).

1) CALCUL DE L'ENSEMBLE DES INDICATEURS

a) Taux de service / ponctualité = livraisons à l'heure / livraisons prévues
= 128 / 142 = 0,9014 soit 90,14 %
Corollaire : taux de retard = 14 / 142 = 9,86 % (14 livraisons hors délai).

b) Taux de kilomètres à vide = km à vide / km totaux
= 3 200 / 14 800 = 0,2162 soit 21,62 %
Corollaire : taux de km en charge = 11 600 / 14 800 = 78,38 %.

c) Taux de litiges = litiges ouverts / nombre total d'opérations
= 4 / 142 = 0,0282 soit 2,82 %

d) Taux de remplissage (utilisation de la charge utile) = charge transportée / charge utile disponible
= 186 / 232 = 0,8017 soit 80,17 %
Charge utile non valorisée : 232 - 186 = 46 t.
Coefficient de chargement moyen = 186 t / 8 véhicules = 23,25 t par véhicule (sur 29 t de charge utile).

e) Taux d'utilisation (disponibilité) du parc = jours d'exploitation réalisés / jours disponibles
= 40 / 40 = 1 soit 100 %

f) Indicateurs complémentaires exploitables :
- kilométrage moyen par véhicule : 14 800 / 8 = 1 850 km sur la semaine, soit 370 km par jour ;
- kilométrage moyen par livraison : 14 800 / 142 = 104,2 km ;
- km à vide par véhicule : 3 200 / 8 = 400 km.

2) IDENTIFICATION DES KPI EN SITUATION D'ALERTE
(seuils professionnels usuels retenus, à défaut d'objectifs fournis par l'annexe : ponctualité supérieure ou égale à 95 %, km à vide inférieurs ou égaux à 15 %, litiges inférieurs ou égaux à 1 %, remplissage supérieur ou égal à 90 %, utilisation du parc supérieure ou égale à 95 %)

- Taux de ponctualité 90,14 % : ALERTE (objectif 95 %, écart de près de 5 points, 14 livraisons hors délai).
- Taux de km à vide 21,62 % : ALERTE FORTE (objectif 15 % maximum ; l'excès représente 6,62 points, soit 0,0662 x 14 800 = 980 km parcourus inutilement sur la semaine).
- Taux de litiges 2,82 % : ALERTE (objectif 1 % maximum, soit près de trois fois le seuil admis).
- Taux de remplissage 80,17 % : ALERTE (objectif 90 %, 46 tonnes de charge utile non valorisées).
- Taux d'utilisation du parc 100 % : CONFORME, aucune alerte. Point de vigilance seulement : aucun véhicule de réserve en cas de panne ou de pic d'activité.

3) CAUSES PROBABLES ET MESURES CORRECTIVES

Ponctualité (90,14 %)
- Causes probables : plannings de tournées trop optimistes (temps de conduite et de service sous-estimés), congestion et créneaux de livraison mal positionnés, attentes prolongées au chargement ou au déchargement, aléas (pannes, absences de conducteurs).
- Mesures correctives : recalibrer les temps de tournée à partir des données réelles (géolocalisation, chronotachygraphe), prévoir des marges de sécurité, optimiser l'ordonnancement des points de livraison via le TMS, négocier des créneaux horaires réalistes avec les clients, mesurer et facturer les temps d'attente sur site.

Kilomètres à vide (21,62 %)
- Causes probables : absence de fret de retour organisé, déséquilibre des flux aller et retour, mauvaise affectation des véhicules, retours à vide systématiques vers le dépôt de Clermont-Ferrand.
- Mesures correctives : rechercher du fret de retour (bourses de fret, groupage, partenariats avec des chargeurs sur les axes de retour), regrouper les tournées, revoir le zonage et l'affectation véhicule/mission, inscrire un objectif de taux de retour en charge dans le suivi hebdomadaire.

Taux de litiges (2,82 %)
- Causes probables : défauts de calage et d'arrimage, manutention inadaptée, emballages insuffisants, formalisme des lettres de voiture et des réserves mal maîtrisé, formation insuffisante des conducteurs.
- Mesures correctives : analyser les 4 litiges (typologie, imputation, coût), rappeler les règles d'arrimage et de prise de réserves à la livraison (réserves précises et motivées sur la lettre de voiture, confirmation écrite au transporteur), former les conducteurs, instaurer un contrôle contradictoire à l'enlèvement et une preuve de livraison photographique, suivre mensuellement le coût des litiges.

Taux de remplissage (80,17 %)
- Causes probables : envois partiels non groupés, plans de chargement non optimisés, véhicules surdimensionnés au regard des envois, contraintes de dates imposées par les clients.
- Mesures correctives : développer le groupage et la massification, adapter la typologie du parc (porteurs pour les petits envois), optimiser les plans de chargement, fixer un seuil minimal de remplissage au départ, suivre le taux de remplissage par tournée.

SYNTHÈSE ATTENDUE : la semaine 38 présente un parc totalement mobilisé (100 %) mais mal exploité : trop de kilomètres à vide (21,62 %), remplissage insuffisant (80,17 %) et qualité de service dégradée (ponctualité 90,14 %, litiges 2,82 %). Les leviers prioritaires sont la réduction des kilomètres à vide et l'amélioration du remplissage, qui agissent directement sur le coût de revient au kilomètre en charge, puis la fiabilisation des plannings pour restaurer la qualité de service.$corr$,
  scoring_grid    = $corr$Total : 6 points (= max_score)

1) Calcul des indicateurs (3 points)
- Taux de ponctualité 128/142 = 90,14 % : 0,5 pt
- Taux de km à vide 3 200/14 800 = 21,62 % : 0,75 pt
- Taux de litiges 4/142 = 2,82 % : 0,5 pt
- Taux de remplissage 186/232 = 80,17 % : 0,75 pt
- Taux d'utilisation du parc 40/40 = 100 % : 0,5 pt
(formule posée + résultat exact ; la moitié des points reste acquise si la formule est juste et le résultat faux ; tolérance d'arrondi à 0,01 point de pourcentage)

2) Identification des KPI en alerte (1,5 point)
- 0,375 pt par KPI correctement classé en alerte (ponctualité, km à vide, litiges, remplissage), avec référence à un seuil ou objectif cohérent
- Retirer 0,5 pt si le taux d'utilisation du parc (100 %) est classé à tort en alerte

3) Causes probables et mesures correctives (1,5 point)
- 0,375 pt par KPI en alerte traité : 0,1875 pt pour une cause probable pertinente et 0,1875 pt pour une mesure corrective adaptée et opérationnelle

Contrôle de cohérence : 3 + 1,5 + 1,5 = 6 points.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch13:ex13.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch13:ex13.2] : [À CONFIRMER: les valeurs chiffrées du bilan et du compte de résultat de MANU TRANS figurent dans l'annexe jointe à la question et ne sont pas présentes dans le champ statement lu en base (vérifié par requête SQL). Le corrigé fournit la méthode, les formules et les interprétations attendues, mais les résultats numériques (FRNG, BFR, TN, délais clients et fournisseurs, VA, EBE pour 20AA et 20AB) doivent être calculés et insérés à partir de l'annexe.] [À CONFIRMER: convention de 360 ou 365 jours pour le calcul des délais de paiement, selon la consigne de l'annexe ; le corrigé retient 360 jours, usage le plus répandu en analyse financière.] [À CONFIRMER: l'énoncé, tronqué dans le champ statement, s'arrête sur « L'excédent brut d'exploitation, » — vérifier que la question 4 ne demande pas d'autres SIG (REX, RCAI, CAF) dans l'annexe ; si oui, compléter le corrigé et redistribuer les 1,5 pt de la partie 4.] Le délai légal de 30 jours à compter de la date d'émission de la facture, propre au transport routier de marchandises (art. L.441-11 C. com.), n'est utilisé que comme élément de commentaire, sans incidence sur les calculs.
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ - Exercice 13.2 : analyse comptable et financière (MANU TRANS)

Remarque de correction : les montants du bilan et du compte de résultat figurent dans l'annexe jointe à l'énoncé (non lisible dans le champ statement). Le corrigé ci-dessous fournit la méthode exigée, les formules attendues et les interprétations types ; le correcteur applique ces formules aux chiffres des exercices 20AA et 20AB de l'annexe.

1) DÉFINITIONS
- Le bilan est un document de synthèse qui présente, à une date donnée (la clôture de l'exercice), la situation patrimoniale de l'entreprise. Il recense à l'actif les emplois (actif immobilisé, stocks, créances clients, disponibilités) et au passif les ressources (capitaux propres, provisions, dettes financières, dettes fournisseurs, dettes fiscales et sociales). C'est une photographie : total actif = total passif.
- Le compte de résultat est un document de synthèse qui récapitule, pour une période donnée (l'exercice comptable), les charges et les produits classés en trois niveaux : exploitation, financier et exceptionnel. Il explique la formation du résultat de l'exercice (bénéfice si les produits excèdent les charges, perte dans le cas inverse). C'est un film de l'activité.

2) ANALYSE DU BILAN (20AA et 20AB)
a) FRNG (fonds de roulement net global)
FRNG = Ressources stables (capitaux propres + provisions + dettes financières à plus d'un an) - Emplois stables (actif immobilisé, selon la présentation retenue par l'annexe).
Contrôle par le bas de bilan : FRNG = actif circulant (stocks + créances + disponibilités) - dettes à court terme.
Interprétation : un FRNG positif signifie que les ressources durables financent la totalité des immobilisations et dégagent une marge de sécurité pour le cycle d'exploitation.

b) BFR (besoin en fonds de roulement)
BFR = Actif circulant d'exploitation (stocks + créances clients et comptes rattachés + autres créances d'exploitation) - Dettes d'exploitation (fournisseurs et comptes rattachés + dettes fiscales et sociales + autres dettes d'exploitation), hors disponibilités et hors concours bancaires courants.
Interprétation : besoin de financement né du décalage entre les encaissements clients et les décaissements fournisseurs.

c) TN (trésorerie nette), deux méthodes qui doivent converger :
TN = FRNG - BFR
TN = Disponibilités et valeurs mobilières de placement - Concours bancaires courants et soldes créditeurs de banque.

d) Comparaison et interprétation 20AA / 20AB (attendu type pour une filiale en difficulté de trésorerie)
La dégradation résulte d'un effet de ciseau : un FRNG qui stagne ou se réduit (investissements financés sans ressources stables suffisantes, remboursement d'emprunts, distribution de résultat) face à un BFR qui augmente (créances clients en hausse, allongement des délais de règlement, stocks en hausse, crédit fournisseurs réduit). Lorsque le BFR dépasse le FRNG, la trésorerie nette devient négative et l'entreprise recourt aux concours bancaires courants, coûteux, ce qui dégrade encore le résultat financier. Le candidat doit chiffrer les variations en valeur et en pourcentage, puis conclure sur la cause dominante.

3) DÉLAIS DE PAIEMENT (TVA 20 %)
a) Les postes du bilan (créances clients, dettes fournisseurs) sont TTC alors que le chiffre d'affaires et les achats du compte de résultat sont HT : il faut homogénéiser en passant le CA et les achats en TTC (coefficient 1,20).
- Délai clients (jours) = [(Créances clients et comptes rattachés + effets escomptés non échus) / (Chiffre d'affaires HT x 1,20)] x 360
- Délai fournisseurs (jours) = [Dettes fournisseurs et comptes rattachés / ((Achats + autres charges externes) HT x 1,20)] x 360
Arrondir au nombre de jours supérieur, comme le demande expressément l'énoncé.

b) Commentaire attendu
- L'allongement du délai clients entre 20AA et 20AB traduit un relâchement du recouvrement, des litiges ou des retards de facturation, et consomme de la trésorerie (hausse du BFR).
- Un raccourcissement du délai fournisseurs (pression des fournisseurs, perte de confiance) accroît mécaniquement le BFR.
- Rappel du cadre légal applicable au transport routier de marchandises : le délai de paiement est plafonné à 30 jours à compter de la date d'émission de la facture (délai spécifique et d'ordre public, article L.441-11 du code de commerce). Un délai clients très supérieur à 30 jours constitue une anomalie à corriger.
- Conclusion : l'écart défavorable entre le délai clients et le délai fournisseurs est une cause directe du BFR élevé et donc des difficultés de trésorerie.

4) SOLDES INTERMÉDIAIRES DE GESTION (20AA et 20AB)
- Valeur ajoutée (VA) = Production de l'exercice (chiffre d'affaires) - Consommations en provenance des tiers (carburant, pneumatiques, entretien, achats de transport et sous-traitance, autres achats et charges externes : péages, assurances, locations).
Lecture transport : la VA mesure la richesse créée ; elle est structurellement réduite par le poids du carburant, des péages et de la sous-traitance.
- Excédent brut d'exploitation (EBE) = VA + Subventions d'exploitation - Impôts, taxes et versements assimilés - Charges de personnel (salaires + charges sociales).
Lecture transport : l'EBE mesure la performance économique pure, avant politique d'amortissement et de financement ; il est très sensible au poids des charges de personnel de conduite.
Interprétation attendue : si la VA progresse alors que l'EBE se dégrade, la cause est une progression des charges de personnel et des impôts et taxes plus rapide que l'activité. Un EBE faible compromet la capacité à couvrir les amortissements et les frais financiers, donc le renouvellement du parc, et alimente les difficultés de trésorerie.

PRÉCONISATIONS CORRECTIVES ATTENDUES
- Sur le BFR : relancer et sécuriser le recouvrement client, faire respecter le délai légal de 30 jours propre au transport, facturer sans délai, obtenir des acomptes, réduire les stocks de pièces et de pneumatiques, renégocier les délais fournisseurs, étudier l'affacturage.
- Sur le FRNG : renforcer les capitaux propres (apport en compte courant, augmentation de capital), consolider ou rééchelonner les dettes financières, financer les véhicules en crédit-bail ou en location plutôt que sur trésorerie, céder les actifs non productifs.
- Sur la rentabilité : réviser les tarifs et appliquer la clause d'indexation gazole, réduire les kilomètres à vide, améliorer le taux de remplissage, maîtriser les charges de structure, limiter le recours aux concours bancaires courants.$corr$,
  scoring_grid    = $corr$Total : 6 points (= max_score)

1) Définitions du bilan et du compte de résultat (1 point)
- Bilan : photographie du patrimoine à une date donnée, emplois à l'actif et ressources au passif : 0,5 pt
- Compte de résultat : charges et produits d'une période, formation du résultat, trois niveaux (exploitation, financier, exceptionnel) : 0,5 pt

2) FRNG, BFR, TN pour 20AA et 20AB, avec interprétation (2 points)
- FRNG : formule correcte et calcul exact sur les deux exercices : 0,5 pt
- BFR : formule correcte et calcul exact sur les deux exercices : 0,5 pt
- TN : par différence FRNG - BFR et recoupement par le bas de bilan : 0,5 pt
- Comparaison chiffrée et interprétation (effet de ciseau FRNG/BFR, trésorerie négative, recours aux concours bancaires) : 0,5 pt
(la moitié des points reste acquise si la formule est juste et le résultat faux ; le détail des calculs est exigé par l'énoncé)

3) Délais de paiement clients et fournisseurs (1,5 point)
- Passage des montants HT en TTC (coefficient 1,20) : 0,25 pt
- Délai clients pour 20AA et 20AB, arrondi au jour supérieur : 0,5 pt
- Délai fournisseurs pour 20AA et 20AB, arrondi au jour supérieur : 0,5 pt
- Commentaire (évolution des délais, effet sur le BFR, rappel du délai légal de 30 jours propre au transport) : 0,25 pt

4) Soldes intermédiaires de gestion (1,5 point)
- Valeur ajoutée 20AA et 20AB (formule et résultat) : 0,75 pt
- Excédent brut d'exploitation 20AA et 20AB (formule et résultat) : 0,75 pt

Contrôle de cohérence : 1 + 2 + 1,5 + 1,5 = 6 points.
Pénalité (dans la limite du total) : retirer 0,25 pt en l'absence totale de détail des calculs, expressément exigé par l'énoncé.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch13:ex13.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch13:ex13.3] : [À CONFIRMER: les montants du bilan 20AA et du compte de résultat 20AB de MG EXPRESS figurent dans l'annexe jointe à la question et ne sont pas présents dans le champ statement lu en base (vérifié par requête SQL). Les résultats numériques (FRNG, BFR, TN, VA, EBE, REX, RCAI, CAF) et l'identification précise de l'anomalie doivent être complétés à partir de l'annexe.] [À CONFIRMER: la structure exacte du tableau à compléter (question 3), imposée par l'annexe ; le corrigé propose une structure Solde / 20AA / 20AB / variation en valeur / variation en pourcentage / commentaire.] Aucun chiffre réglementaire n'est mobilisé par cet exercice.
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ - Exercice 13.3 : analyser les SIG et détecter une anomalie (MG EXPRESS)

Remarque de correction : les montants du bilan 20AA et du compte de résultat 20AB figurent dans l'annexe jointe à l'énoncé (non lisible dans le champ statement). Le corrigé donne la méthode, les formules attendues, la structure du tableau et la logique de détection de l'anomalie ; le correcteur applique ces formules aux chiffres de l'annexe.

1) ANALYSE DU BILAN 20AA
a) FRNG = Ressources stables (capitaux propres + provisions pour risques et charges + dettes financières à plus d'un an) - Emplois stables (actif immobilisé).
Vérification par le bas de bilan : FRNG = actif circulant total - dettes à court terme.
Interprétation : un FRNG positif signifie que les immobilisations sont intégralement financées par des ressources durables et qu'il subsiste une marge pour le cycle d'exploitation.

b) BFR = (Stocks + créances clients et comptes rattachés + autres créances d'exploitation) - (Dettes fournisseurs et comptes rattachés + dettes fiscales et sociales + autres dettes d'exploitation). Les disponibilités et les concours bancaires courants sont exclus.
Interprétation : besoin de financement du cycle d'exploitation lié au décalage entre l'encaissement des clients et le règlement des fournisseurs.

c) TN = FRNG - BFR, à recouper avec TN = disponibilités - concours bancaires courants.
Interprétation : une TN positive traduit une autonomie financière à court terme ; une TN négative traduit une dépendance aux découverts et financements bancaires à court terme.

2) SOLDES INTERMÉDIAIRES DE GESTION 20AB (cascade à respecter)
- Valeur ajoutée (VA) = Chiffre d'affaires (production de l'exercice) - Consommations en provenance des tiers (carburant, pneumatiques, entretien, achats de transport et sous-traitance, autres achats et charges externes : péages, assurances, locations, honoraires).
- Excédent brut d'exploitation (EBE) = VA + Subventions d'exploitation - Impôts, taxes et versements assimilés - Charges de personnel (salaires et charges sociales).
- Résultat d'exploitation (REX) = EBE + Autres produits d'exploitation + Reprises sur amortissements, dépréciations et provisions et transferts de charges - Dotations aux amortissements, dépréciations et provisions - Autres charges d'exploitation.
- Résultat courant avant impôt (RCAI) = REX + Produits financiers - Charges financières.
- Capacité d'autofinancement (CAF), méthode soustractive à partir de l'EBE :
CAF = EBE + autres produits encaissables (produits financiers encaissables, transferts de charges, autres produits d'exploitation) - autres charges décaissables (charges financières, autres charges d'exploitation) + produits exceptionnels encaissables - charges exceptionnelles décaissables - participation des salariés - impôt sur les bénéfices.
Rappel : les dotations et reprises (non décaissables ou non encaissables), les produits de cession d'immobilisations et la valeur comptable des éléments d'actif cédés ne sont pas intégrés.
Contrôle par la méthode additive : CAF = Résultat net + dotations aux amortissements, dépréciations et provisions - reprises + valeur comptable des éléments d'actif cédés - produits de cession d'éléments d'actif - quote-part de subventions d'investissement virée au résultat.

3) TABLEAU DE SYNTHÈSE ET DÉTECTION DE L'ANOMALIE
Structure du tableau (une ligne par solde) :
Solde | 20AA | 20AB | Variation en valeur | Variation en pourcentage | Commentaire
Lignes : VA, EBE, REX, RCAI, CAF.

Méthode de détection attendue : repérer la rupture de cohérence dans la cascade, c'est-à-dire le solde qui évolue à contre-courant des autres. Cas typiques en transport routier :
- le chiffre d'affaires et la valeur ajoutée progressent mais l'EBE recule : la cause est la progression des charges de personnel et des impôts et taxes plus rapide que la richesse créée ;
- l'EBE se maintient mais le REX chute : la cause est une forte dotation aux amortissements (renouvellement du parc) ou une dotation aux provisions exceptionnelle (litiges) ;
- le REX est correct mais le RCAI s'effondre : la cause est le poids des charges financières (endettement, découverts, crédit-bail financier), cohérent avec une trésorerie nette négative en 20AA.
Le candidat doit nommer l'anomalie, la chiffrer (variation en valeur et en pourcentage), en identifier la cause précise dans le compte de résultat, puis conclure : une CAF en recul, voire insuffisante pour couvrir le remboursement des emprunts, met en péril le renouvellement du parc et l'équilibre financier de MG EXPRESS.

PRÉCONISATIONS ATTENDUES : réviser la politique tarifaire et appliquer l'indexation gazole, réduire les consommations en provenance des tiers (sous-traitance, carburant, kilomètres à vide), maîtriser la masse salariale (heures supplémentaires, effectif rapporté à l'activité), revoir le mode de financement du parc (crédit-bail ou location longue durée), résorber le BFR pour alléger les charges financières.$corr$,
  scoring_grid    = $corr$Total : 6 points (= max_score)

1) Analyse du bilan 20AA (1,5 point)
- FRNG : formule (ressources stables - emplois stables, ou contrôle par le bas de bilan) et résultat exact : 0,5 pt
- BFR : formule (actif circulant d'exploitation - dettes d'exploitation, hors trésorerie) et résultat exact : 0,5 pt
- TN : TN = FRNG - BFR, recoupée avec disponibilités - concours bancaires courants : 0,5 pt
(la moitié des points reste acquise si la formule est juste et le résultat faux)

2) Soldes intermédiaires de gestion 20AB (3 points)
- Valeur ajoutée : 0,5 pt
- Excédent brut d'exploitation : 0,5 pt
- Résultat d'exploitation : 0,5 pt
- Résultat courant avant impôt : 0,5 pt
- Capacité d'autofinancement (méthode soustractive à partir de l'EBE ou méthode additive, avec neutralisation correcte des éléments non décaissables et non encaissables) : 1 pt

3) Tableau complété et détection de l'anomalie (1,5 point)
- Tableau correctement renseigné (soldes 20AA et 20AB, variations en valeur et en pourcentage) : 0,5 pt
- Identification chiffrée du solde qui rompt la cohérence de la cascade : 0,5 pt
- Explication de la cause (charges de personnel, dotations aux amortissements ou charges financières selon les chiffres de l'annexe) et conséquence sur la CAF et le renouvellement du parc : 0,5 pt

Contrôle de cohérence : 1,5 + 3 + 1,5 = 6 points.
Pénalités (dans la limite du total) : retirer 0,25 pt si les calculs ne sont pas détaillés ; retirer 0,25 pt si la cascade des SIG n'est pas respectée.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch13:ex13.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch14:ex14.1] : Calculs revérifiés à partir des données de l'énoncé : 0,820 x 580 = 475,60 kgCO2e ; 8/24 = 1/3 ; 475,60/3 = 158,53 kgCO2e ; 0,040 x 580 = 23,20 kgCO2e ; 23,20/3 = 7,73 kgCO2e ; gain 150,80 kgCO2e soit 95,1 %. Exacts. [À CONFIRMER: le dispositif d'information sur les émissions de gaz à effet de serre des prestations de transport a évolué depuis le décret n° 2011-1336 du 24 octobre 2011 (entré en vigueur le 1er octobre 2013), notamment avec la loi d'orientation des mobilités et ses textes d'application (extension du CO2 à l'ensemble des gaz à effet de serre) et les travaux européens de type CountEmissionsEU. Vérifier, pour la session 2026, quel texte et quelle date d'entrée en vigueur sont attendus par le référentiel ; la réponse de référence historiquement retenue au titre GOTRM, et celle explicitement appelée par l'énoncé (« Indiquer le décret »), reste le décret n° 2011-1336 du 24 octobre 2011, applicable au 1er octobre 2013.] Anomalie à corriger dans la banque de questions : incohérence de nom de client dans l'énoncé (TECHNIBOIS INDUSTRIE dans le contexte et le travail à réaliser, MECA-CONCEPT dans le tableau des données fournies) ; le corrigé neutralise l'ambiguïté.
UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ - Exercice 14.1 : calculer et communiquer l'information CO2 (TRANSATLANTIC LOGISTIQUE)

DONNÉES : ensemble articulé de 44 t, trajet Paris - Bordeaux de 580 km, 24 t de marchandises transportées dont 8 t pour le client TECHNIBOIS INDUSTRIE, facteur d'émission ADEME de 0,820 kgCO2e/km.
Remarque : le tableau des données fournies mentionne un client MECA-CONCEPT ; il s'agit du même envoi de 8 t sur 24 t, le raisonnement et les résultats sont identiques (incohérence de nom à corriger dans l'énoncé, voir note).

ÉTAPE PRÉALABLE - TABLEAU DE CALCUL À COMPLÉTER
Calcul | Formule | Résultat
- Émission totale du véhicule | 0,820 kgCO2e/km x 580 km | 475,60 kgCO2e
- Part de l'envoi du client | 8 t / 24 t | 0,3333 soit 33,33 % (un tiers)
- CO2 imputable au client | 475,60 x 1/3 | 158,53 kgCO2e (soit environ 0,159 tCO2e)
Méthode : allocation au prorata de la masse transportée (unité de mesure retenue : la tonne), conformément à la méthodologie de calcul de l'information sur les émissions de gaz à effet de serre des prestations de transport.

1) MENTION ENVIRONNEMENTALE À FAIRE FIGURER SUR LA FACTURE
Rédaction attendue (sur la facture ou sur un document annexé remis au client) :
« Information sur la quantité de gaz à effet de serre émise à l'occasion de la prestation de transport (article L.1431-3 du code des transports).
Prestation : transport routier de marchandises Paris - Bordeaux, 580 km, ensemble articulé de 44 tonnes, motorisation gazole.
Envoi TECHNIBOIS INDUSTRIE : 8 tonnes sur une charge totale transportée de 24 tonnes, soit une part de 33,33 %.
Source des données : valeurs de référence ADEME, facteur d'émission de 0,820 kgCO2e/km ; méthode de calcul : niveau 1 (valeurs par défaut) ; périmètre : émissions du puits à la roue (production et distribution de la source d'énergie + fonctionnement du véhicule).
Quantité de CO2e imputable à votre envoi : 158,53 kgCO2e, soit environ 0,16 tonne équivalent CO2. »
Éléments obligatoirement présents : la prestation concernée, la quantité de gaz à effet de serre exprimée en masse de CO2 équivalent, la source des facteurs d'émission et la méthode de calcul retenue. L'information est fournie gratuitement au bénéficiaire de la prestation, au plus tard dans les deux mois qui suivent la fin de celle-ci.

2) TEXTE IMPOSANT L'OBLIGATION ET ENTRÉE EN VIGUEUR
- Fondement législatif : article L.1431-3 du code des transports, issu de la loi Grenelle II du 12 juillet 2010.
- Décret d'application (réponse attendue par l'énoncé) : décret n° 2011-1336 du 24 octobre 2011 relatif à l'information sur la quantité de dioxyde de carbone émise à l'occasion d'une prestation de transport, complété par l'arrêté du 10 avril 2012 fixant les valeurs de niveau 1.
- Date d'entrée en vigueur : 1er octobre 2013.
- Champ d'application : toute prestation de transport de personnes, de marchandises ou de déménagement dont le point d'origine ou de destination se situe en France, quel que soit le mode. Le prestataire doit informer le bénéficiaire de la quantité de gaz à effet de serre émise.

3) RECALCUL AVEC UN VÉHICULE ÉLECTRIQUE (facteur d'émission de 0,040 kgCO2e/km)
- Émission totale du véhicule : 0,040 x 580 = 23,20 kgCO2e
- Part de l'envoi : 8 / 24 = 1/3 (33,33 %)
- CO2 imputable au client : 23,20 x 1/3 = 7,73 kgCO2e

COMPARAISON ET COMMENTAIRE
- Gain d'émissions pour l'envoi : 158,53 - 7,73 = 150,80 kgCO2e évités.
- Réduction relative : 150,80 / 158,53 = 95,1 % d'émissions en moins (le rapport des facteurs d'émission, 0,820 / 0,040 = 20,5, divise les émissions par 20,5).
- Analyse attendue : le passage à l'électrique réduit très fortement les émissions du puits à la roue, mais la comparaison doit être nuancée (autonomie sur un trajet de 580 km, masse de la batterie qui réduit la charge utile, disponibilité des infrastructures de recharge, coût d'acquisition, mix électrique retenu pour le facteur d'émission, émissions liées à la fabrication de la batterie non incluses dans un facteur d'usage). Les autres leviers de décarbonation restent l'éco-conduite, l'amélioration du taux de remplissage, la réduction des kilomètres à vide, le report modal (rail, fluvial) et les carburants alternatifs (B100, bioGNV, HVO).$corr$,
  scoring_grid    = $corr$Total : 6 points (= max_score)

1) Mention environnementale sur la facture (2,5 points)
- Émission totale du véhicule : 0,820 x 580 = 475,60 kgCO2e : 0,75 pt
- Part de l'envoi : 8/24 = 33,33 % (un tiers) : 0,5 pt
- CO2 imputable au client : 475,60 x 1/3 = 158,53 kgCO2e : 0,75 pt
- Rédaction de la mention comportant les éléments obligatoires (prestation concernée, quantité en CO2e, source des facteurs d'émission ADEME, méthode de niveau 1, périmètre du puits à la roue) : 0,5 pt (0,25 pt si la mention est incomplète)

2) Texte réglementaire et entrée en vigueur (1,5 point)
- Décret n° 2011-1336 du 24 octobre 2011 (ou fondement : article L.1431-3 du code des transports) : 1 pt
- Entrée en vigueur au 1er octobre 2013 : 0,5 pt
(la citation de l'arrêté du 10 avril 2012 relatif aux valeurs de niveau 1 est valorisée sans dépasser le total de la partie)

3) Recalcul en motorisation électrique (2 points)
- Émission totale : 0,040 x 580 = 23,20 kgCO2e : 0,75 pt
- CO2 imputable au client : 23,20 x 1/3 = 7,73 kgCO2e : 0,75 pt
- Comparaison chiffrée (gain de 150,80 kgCO2e, soit environ 95 % de réduction) et commentaire critique (autonomie, charge utile, recharge, périmètre du facteur d'émission) : 0,5 pt

Contrôle de cohérence : 2,5 + 1,5 + 2 = 6 points.
Pénalités (dans la limite du total) : retirer 0,25 pt si les unités (kgCO2e) sont absentes ; retirer 0,25 pt en cas d'arrondi incohérent ou de règle de trois non posée.
Tolérance d'arrondi : 158,53 kgCO2e (ou 158,5) et 7,73 kgCO2e (ou 7,7) sont acceptés.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch14:ex14.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch14:ex14.2] : [À CONFIRMER: correspondance norme Euro / Crit'Air retenue = grille POIDS LOURDS (Euro VI = Crit'Air 1, Euro V = 2, Euro IV = 3, Euro III = 4). L'énoncé ne précise pas le PTAC des véhicules TRR : s'il s'agit de VUL de moins de 3,5 t, la grille est différente (Euro 6 = Crit'Air 2, Euro 5 et Euro 4 = Crit'Air 3, Euro 3 = Crit'Air 4) et seul TRR-01 serait autorisé. Le barème prévoit les deux hypothèses.] [À CONFIRMER: état exact de la réglementation ZFE-m du Grand Paris applicable en 2026 (seuil d'interdiction Crit'Air 3, plages horaires, dérogations, calendrier), le cadre national des ZFE ayant évolué récemment. Vérifier l'arrêté métropolitain en vigueur avant diffusion.] Vérifications faites : 4 sous-questions traitées ; barème = 6 = max_score.
UPDATE public.question_bank SET
  expected_answer = $corr$1. Compléter la colonne « Vignette Crit'Air »

Les véhicules TRR de TRANS EXPRESS sont des véhicules de transport routier de marchandises (poids lourds, catégories N2/N3). Pour les poids lourds diesel, la correspondance officielle norme Euro / certificat qualité de l'air (Crit'Air) est la suivante :

- TRR-01 (FF-514-DD), Euro 6/VI : Crit'Air 1
- TRR-02 (HS-189-YG), Euro 5/V : Crit'Air 2
- TRR-03 (DD-461-VV), Euro 4/IV : Crit'Air 3
- TRR-04 (FM-698-ZZ), Euro 3/III : Crit'Air 4

Méthode : la vignette Crit'Air dépend de deux paramètres, la catégorie du véhicule (VP/VUL d'une part ; poids lourds, autobus et autocars d'autre part) et la motorisation/norme Euro. La grille des poids lourds n'est pas celle des véhicules légers : pour un VUL diesel, Euro 6 = Crit'Air 2, Euro 5 et Euro 4 = Crit'Air 3, Euro 3 = Crit'Air 4.

2. Véhicules autorisés dans la ZFE de Paris en 2026

Dans la ZFE-m de la Métropole du Grand Paris, la restriction en vigueur interdit la circulation des véhicules classés Crit'Air 3 et au-delà (Crit'Air 3, 4, 5 et non classés) pendant les plages horaires réglementées. Sont donc autorisés les véhicules électriques/hydrogène (vignette verte), Crit'Air 1 et Crit'Air 2.

- TRR-01 (Euro 6, Crit'Air 1) : AUTORISÉ
- TRR-02 (Euro 5, Crit'Air 2) : AUTORISÉ
- TRR-03 (Euro 4, Crit'Air 3) : NON AUTORISÉ
- TRR-04 (Euro 3, Crit'Air 4) : NON AUTORISÉ

Le gestionnaire affecte donc en priorité TRR-01 et TRR-02 aux tournées Paris intra-muros.

3. Solution à court terme pour assurer les livraisons avec les véhicules interdits

Plusieurs solutions immédiates, sans investissement, peuvent être combinées :

- Réaffecter les tournées : concentrer TRR-01 et TRR-02 sur les livraisons en ZFE et basculer TRR-03 et TRR-04 sur les trafics hors ZFE (province, périphérie, grands axes), avec révision du planning d'exploitation.
- Mettre en place une rupture de charge en périphérie : décharger les véhicules interdits sur une plateforme/espace de logistique urbaine (ELU/CDU) situé hors ZFE, puis assurer le dernier kilomètre avec un véhicule conforme (Crit'Air 1 ou 2, VUL électrique, vélo-cargo).
- Recourir à la sous-traitance ou à la location courte durée d'un véhicule conforme (Crit'Air 1/2 ou 100 % électrique) pour absorber le surcroît d'activité.
- Solliciter les dérogations et facilités prévues par l'arrêté ZFE : dérogations locales, laissez-passer temporaires (« pass ZFE » de quelques jours par an), livraisons hors des plages horaires restreintes lorsque la réglementation le permet.

4. Deux actions relevant de la démarche RSE réduisant durablement les émissions

Citer deux actions parmi, par exemple :

- Renouveler la flotte : investir dans des véhicules à faibles émissions (électriques, GNV/bioGNV, hydrogène) ou à défaut Euro VI récents, et sortir progressivement les Euro 3 et Euro 4 du parc.
- Adhérer à un dispositif volontaire de réduction des émissions de CO2 (programme national de type « Objectif CO2 » / charte d'engagements volontaires), avec plan d'actions et suivi d'indicateurs.
- Former les conducteurs à l'éco-conduite et suivre les consommations par véhicule et par conducteur.
- Optimiser l'exploitation : massification et optimisation des tournées, réduction des kilomètres à vide, amélioration du taux de remplissage, logiciels d'optimisation, report modal (rail-route, fluvial) sur les longues distances.
- Entretien préventif du parc, contrôle de la pression des pneumatiques, bridage des vitesses.
- Développer une logistique urbaine décarbonée (véhicules électriques, cyclologistique) pour le dernier kilomètre.$corr$,
  scoring_grid    = $corr$Barème sur 6 points (total = 2 + 1,5 + 1,5 + 1 = 6).

Q1 (2 pts) : vignettes Crit'Air. 0,5 pt par véhicule correctement classé (TRR-01 Crit'Air 1 ; TRR-02 Crit'Air 2 ; TRR-03 Crit'Air 3 ; TRR-04 Crit'Air 4). Barème appliqué à la grille POIDS LOURDS ; accepter la grille VUL (Euro 6 = Crit'Air 2, Euro 5 et Euro 4 = Crit'Air 3, Euro 3 = Crit'Air 4) si le candidat justifie explicitement la catégorie de véhicule retenue (l'énoncé ne précise pas le PTAC).

Q2 (1,5 pt) : 0,5 pt pour l'énoncé de la règle (seuls électrique/hydrogène, Crit'Air 1 et Crit'Air 2 sont admis ; Crit'Air 3 et au-delà interdits) ; 1 pt pour l'application correcte aux 4 véhicules (0,25 pt par véhicule). Si le candidat a retenu la grille VUL, noter la cohérence de l'application (seul TRR-01 autorisé) plutôt que le résultat.

Q3 (1,5 pt) : 1,5 pt pour une solution opérationnelle immédiate cohérente et argumentée (réaffectation des tournées, rupture de charge en périphérie + dernier kilomètre conforme, sous-traitance ou location d'un véhicule conforme, dérogations/pass ZFE). Une seule solution correctement expliquée suffit ; retirer 0,5 pt si la solution est citée sans explication de mise en oeuvre.

Q4 (1 pt) : 0,5 pt par action RSE pertinente et durable (renouvellement de flotte bas carbone, démarche volontaire de réduction du CO2, éco-conduite, optimisation des tournées et du taux de remplissage, report modal, logistique urbaine décarbonée). Ne pas compter les mesures purement palliatives déjà valorisées en Q3.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch14:ex14.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch15:ex15.1] : [À CONFIRMER: régime d'autorisation applicable au transport France / Maroc (autorisation bilatérale franco-marocaine ou contingent CEMT-ITF) et pertinence du carnet TIR sur cette relation.] [À CONFIRMER: intitulés à jour des formalités britanniques (GVMS, déclaration sommaire d'entrée) et statut douanier exact des envois vers la Suisse (transit commun NCTS, T1/T2).] Vérifications faites : les 5 relations du tableau sont traitées, avec les 4 colonnes demandées ; barème = 6 = max_score.
UPDATE public.question_bank SET
  expected_answer = $corr$Principe de raisonnement : trois questions à se poser pour chaque relation.
(a) Le transport est-il international ? Si oui, la lettre de voiture CMR est obligatoire (Convention de Genève du 19 mai 1956, applicable dès lors que le pays de chargement ou le pays de livraison est partie à la Convention).
(b) Le trajet franchit-il la frontière extérieure de l'union douanière de l'UE ? Si oui, formalités douanières obligatoires ; si le trajet reste intra-UE (marché unique), aucune formalité douanière.
(c) Quel titre d'exploitation permet d'effectuer le transport ? Licence communautaire (copie certifiée conforme à bord) pour tout transport intra-UE et pour l'accès au marché ; autorisation bilatérale ou autorisation CEMT/ITF pour les pays tiers, sauf accord spécifique.

Tableau complété :

1) Clermont-Ferrand -> Cologne (Allemagne)
- Document CMR : OUI (transport international entre deux États parties à la CMR).
- Douane : NON (échange intracommunautaire, marché unique).
- Licence requise : licence communautaire (copie certifiée conforme à bord) + attestation de conducteur si le conducteur est ressortissant d'un pays tiers.
- Document douanier : aucun. Facture commerciale et obligations déclaratives de l'expéditeur (état récapitulatif TVA, enquête statistique EMEBI) hors document de transport.

2) Moulins -> Bari (Italie)
- Document CMR : OUI.
- Douane : NON (intra-UE).
- Licence requise : licence communautaire.
- Document douanier : aucun (mêmes obligations déclaratives statistiques et TVA que ci-dessus).

3) Lyon -> Londres (Royaume-Uni)
- Document CMR : OUI (le Royaume-Uni est partie à la CMR).
- Douane : OUI (pays tiers depuis le Brexit, sortie de l'union douanière).
- Licence requise : licence communautaire ; l'accord de commerce et de coopération UE / Royaume-Uni permet le transport bilatéral sans autorisation CEMT.
- Documents douaniers : déclaration d'exportation (DAU / EX1) et justificatif de sortie, déclaration de transit T1 le cas échéant, numéro EORI, facture commerciale, liste de colisage, preuve d'origine préférentielle, formalités britanniques à l'entrée (déclaration sommaire d'entrée, enregistrement du mouvement au système GVMS).

4) Clermont-Ferrand -> Marrakech (Maroc)
- Document CMR : OUI (le Maroc est partie à la Convention CMR).
- Douane : OUI (pays tiers, hors union douanière).
- Licence requise : licence communautaire pour la partie UE + autorisation de transport délivrée dans le cadre de l'accord bilatéral franco-marocain (le transit par l'Espagne reste couvert par la licence communautaire).
- Documents douaniers : déclaration d'exportation (DAU / EX1), transit (T1/T2, voire carnet TIR selon l'itinéraire), facture commerciale, certificat de circulation EUR.1 (origine préférentielle, accord d'association UE-Maroc), liste de colisage.

5) Strasbourg -> Genève (Suisse)
- Document CMR : OUI (la Suisse est partie à la CMR).
- Douane : OUI (la Suisse est hors UE et hors union douanière, même si elle appartient à l'espace Schengen).
- Licence requise : licence communautaire ; l'accord UE / Suisse sur le transport de marchandises et de voyageurs par rail et par route dispense d'autorisation bilatérale ou CEMT pour le trafic bilatéral.
- Documents douaniers : déclaration d'exportation (DAU / EX1), document de transit commun T1/T2 (la Suisse applique la convention de transit commun, procédure NCTS), facture commerciale, EUR.1, liste de colisage.

Synthèse : la CMR est requise dans les cinq cas (transport international). Les formalités douanières ne concernent que les trois relations vers pays tiers (Royaume-Uni, Maroc, Suisse). Une autorisation en sus de la licence communautaire n'est réellement nécessaire que pour le Maroc.$corr$,
  scoring_grid    = $corr$Barème sur 6 points (total = 5 x 1 pt + 1 pt = 6).

5 relations x 1 pt = 5 pts, répartis à l'intérieur de chaque ligne :
- 0,25 pt : CMR O/N correct.
- 0,25 pt : douane O/N correct.
- 0,25 pt : titre d'exploitation / licence correct (licence communautaire ; accord UE-RU ; accord UE-Suisse ; autorisation bilatérale pour le Maroc).
- 0,25 pt : document(s) douanier(s) correct(s), ou mention « aucun » pour les relations intra-UE.

1 pt : justification du raisonnement d'ensemble (distinction intra-UE / pays tiers, champ d'application de la CMR, obligation de détenir à bord la copie certifiée conforme de la licence communautaire). Accorder 0,5 pt si la distinction est faite sans référence aux textes.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch15:ex15.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch15:ex15.2] : [À CONFIRMER: quantum exact des sanctions pénales du cabotage illégal et de la responsabilité du donneur d'ordre (retenus ici à un an d'emprisonnement et 15 000 euros d'amende) et articles du code des transports correspondants — à vérifier dans la version en vigueur en 2026.] [À CONFIRMER: articulation exacte de la période de carence de 4 jours introduite par le règlement (UE) 2020/1055 (elle s'applique au véhicule, non à l'entreprise).] Vérifications faites : 4 sous-questions traitées ; chronologie du cas recalculée (déchargement 25/03, fenêtre jusqu'au 01/04, l'opération 4 du 30/03 est dans le délai mais dépasse le plafond de 3 opérations) ; barème = 6 = max_score. Règles 3 opérations / 7 jours conformes au règlement (CE) 1072/2009.
UPDATE public.question_bank SET
  expected_answer = $corr$1. Réglementation applicable au cabotage routier en France

Le cabotage est régi par le règlement (CE) n° 1072/2009, modifié par le règlement (UE) 2020/1055 (Paquet mobilité). Règles à retenir :

- Le cabotage n'est autorisé qu'à la suite d'un transport international entrant, une fois la marchandise de ce transport international entièrement déchargée dans l'État membre d'accueil (caractère temporaire, cabotage « consécutif »).
- Nombre maximal : 3 opérations de cabotage au maximum.
- Durée : dans un délai de 7 jours à compter du déchargement du transport international entrant.
- Période de carence (cooling-off) : à l'issue de la période de cabotage, le même véhicule ne peut pas effectuer de nouvelles opérations de cabotage dans le même État membre pendant 4 jours.
- Le transporteur doit pouvoir présenter la preuve du transport international entrant et de chaque opération de cabotage (lettres de voiture, CMR), ainsi que sa licence communautaire.

2. Les quatre opérations peuvent-elles être réalisées ?

NON. Le transport international entrant a été déchargé à Paris le lundi 25/03. La période de cabotage court donc du 25/03 jusqu'au 01/04 (7 jours). Les quatre opérations projetées se situent toutes dans cette fenêtre de 7 jours :
- Opération 1, Paris -> Lyon, mardi 26/03 : dans les délais, 1re opération, RÉGULIÈRE.
- Opération 2, Lyon -> Marseille, mercredi 27/03 : dans les délais, 2e opération, RÉGULIÈRE.
- Opération 3, Marseille -> Bordeaux, vendredi 29/03 : dans les délais, 3e opération, RÉGULIÈRE.
- Opération 4, Bordeaux -> Toulouse, samedi 30/03 : encore dans la fenêtre de 7 jours, mais il s'agit de la 4e opération, donc au-delà du plafond de 3 opérations : IRRÉGULIÈRE.

La contrainte violée n'est donc pas la durée mais le nombre d'opérations. IBERTRANS LOGISTICA doit renoncer à l'opération n° 4, ou la faire précéder d'un nouveau transport international entrant, ou la confier à un autre véhicule (l'exigence de carence de 4 jours s'appliquant au véhicule qui vient de caboter en France).

3. Sanctions encourues en cas de cabotage irrégulier

- Sanctions pénales : l'exercice illégal du cabotage est puni d'un an d'emprisonnement et de 15 000 euros d'amende (code des transports, dispositions réprimant l'exécution illégale de transports de cabotage).
- Sanctions administratives et immédiates : immobilisation du véhicule aux frais du transporteur jusqu'à régularisation, consignation, procès-verbal de l'administration (DREAL, forces de l'ordre).
- Sanctions sur le titre d'exploitation : retrait des copies certifiées conformes de la licence communautaire, voire retrait de la licence par l'État membre d'établissement, atteinte à l'honorabilité professionnelle du gestionnaire de transport et de l'entreprise (inscription au registre électronique national / ERRU).
- Amendes en cas de défaut de présentation des preuves de cabotage lors d'un contrôle.

4. Conséquences pour TRANSGOTRM en qualité de donneur d'ordre

- Coresponsabilité du donneur d'ordre : le code des transports met à sa charge une obligation de vigilance ; celui qui, sciemment, recourt à un transporteur en situation de cabotage illégal encourt les mêmes peines que le transporteur (un an d'emprisonnement et 15 000 euros d'amende).
- Responsabilité contractuelle et financière : remise en cause du contrat, solidarité financière, prise en charge des frais liés à l'immobilisation du véhicule, désorganisation de la chaîne de transport, retards de livraison à indemniser vis-à-vis du client final.
- Conséquences professionnelles : atteinte à l'honorabilité de TRANSGOTRM et de son gestionnaire de transport, contrôles renforcés, atteinte à l'image, perte de référencement chez les chargeurs.
- Bonnes pratiques : contrôle documentaire préalable du sous-traitant (licence communautaire, attestation de régularité sociale et fiscale, preuve du transport international entrant, décompte des opérations de cabotage), clause contractuelle de conformité, traçabilité des lettres de voiture.$corr$,
  scoring_grid    = $corr$Barème sur 6 points (total = 1,5 + 2 + 1,5 + 1 = 6).

Q1 (1,5 pt) : 0,5 pt pour le maximum de 3 opérations de cabotage ; 0,5 pt pour le délai de 7 jours à compter du déchargement du transport international entrant ; 0,25 pt pour le rappel du préalable (transport international entrant entièrement déchargé) ; 0,25 pt pour la référence au règlement (CE) 1072/2009 modifié par le règlement (UE) 2020/1055 ou pour la mention de la carence de 4 jours.

Q2 (2 pts) : 0,5 pt pour le calcul correct de la fenêtre (déchargement le 25/03 + 7 jours, soit jusqu'au 01/04) ; 1 pt pour la conclusion exacte (opérations 1, 2 et 3 régulières ; opération 4 irrégulière car 4e opération) ; 0,5 pt pour la justification (c'est le plafond du nombre d'opérations qui est dépassé, non le délai) et pour une solution de régularisation proposée.

Q3 (1,5 pt) : 0,75 pt pour la sanction pénale (un an d'emprisonnement et 15 000 euros d'amende) ; 0,75 pt pour au moins deux sanctions complémentaires (immobilisation du véhicule, retrait des copies de la licence communautaire, atteinte à l'honorabilité, inscription au registre ERRU).

Q4 (1 pt) : 0,5 pt pour la coresponsabilité pénale du donneur d'ordre au titre de son obligation de vigilance ; 0,5 pt pour au moins deux conséquences complémentaires (responsabilité contractuelle et financière, honorabilité, image, retards et indemnisation, contrôles renforcés) ou pour l'énoncé des contrôles préalables à opérer sur le sous-traitant.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch15:ex15.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

-- ⚠️ À CONFIRMER [mft-2026-gotrm-ccp1-qr-v2:ch15:ex15.3] : [À CONFIRMER: identification du preneur de la prestation de transport. En DAP, le donneur d'ordre est le vendeur français (SA MBL MECANIC), d'où l'application de la TVA française à 20 % retenue ici (301,43 euros, total TTC 1 808,56 euros). Si l'énoncé attend que le transporteur facture le client espagnol assujetti, la prestation relève de l'autoliquidation (facture HT, mention article 44 de la directive 2006/112/CE). Les deux hypothèses sont traitées.] [À CONFIRMER: références exactes de l'obligation d'information sur les émissions de GES des prestations de transport (article L.1431-3 du code des transports et décret d'application en vigueur en 2026, périmètre puits à la roue, valeurs de niveau 1).] [À CONFIRMER: interprétation de la marge de 10 % « sur le prix de vente HT », traitée ici en marge en dedans (PV = CR / 0,90).] Vérifications faites : 6 sous-questions traitées ; calculs recontrôlés (867/68 = 12,75 h ; 15,75 h ; 533,21 + 426,51 + 396,70 = 1 356,42 euros ; 1 356,42/0,9 = 1 507,13 euros ; TVA 20 % = 301,43 euros ; TTC = 1 808,56 euros ; 867 x 0,820 = 710,94 kgCO2e) ; barème = 6 = max_score.
UPDATE public.question_bank SET
  expected_answer = $corr$1. Obligations liées à l'Incoterm DAP Barcelone (Incoterms 2020)

DAP = Delivered At Place, rendu au lieu de destination convenu (ici Barcelone).

- Qui organise le transport ? Le VENDEUR (SA MBL MECANIC). Il choisit le transporteur et organise l'acheminement de Chamalières jusqu'à Barcelone.
- Qui prend en charge les frais de transport ? Le VENDEUR, jusqu'au lieu de destination convenu. Le déchargement au lieu de destination reste à la charge de l'acheteur (différence avec DPU, où le vendeur décharge). Les droits et taxes d'importation éventuels sont à la charge de l'acheteur (différence avec DDP).
- Jusqu'à quel point le vendeur est-il responsable ? Le transfert des risques s'opère au lieu de destination convenu (Barcelone), lorsque la marchandise est mise à disposition de l'acheteur sur le moyen de transport arrivant, prête à être déchargée. Le vendeur supporte donc les risques de perte ou d'avarie sur tout le trajet jusqu'à Barcelone. Il n'a pas d'obligation d'assurance envers l'acheteur, mais a tout intérêt à souscrire une assurance ad valorem compte tenu de la charge des risques. Formalités d'exportation à la charge du vendeur, formalités d'importation à la charge de l'acheteur.

2. Coût de revient de la mission par la méthode du trinôme

Méthode : CR = (TK x km) + (TH x heures) + (TJ x jours)

Calcul des heures :
- Temps de conduite = distance / vitesse commerciale = 867 / 68 = 12,75 h (12 h 45 min)
- Temps de chargement + déchargement = 1 h 30 + 1 h 30 = 3 h
- Total des heures de mission = 12,75 + 3 = 15,75 h (15 h 45 min)

Terme kilométrique : 0,615 x 867 = 533,21 euros (533,205 arrondi)
Terme horaire : 27,08 x 15,75 = 426,51 euros
Terme journalier : 198,35 x 2 = 396,70 euros

Coût de revient de la mission = 533,21 + 426,51 + 396,70 = 1 356,42 euros HT.

3. Prix de vente HT

La marge de 10 % est appliquée sur le prix de vente (marge « en dedans »), conformément à l'énoncé :
PV HT = CR / (1 - 0,10) = 1 356,42 / 0,90 = 1 507,13 euros HT.
Marge = 1 507,13 - 1 356,42 = 150,71 euros, soit bien 10 % du prix de vente.

Remarque de méthode : si la marge était appliquée sur le coût de revient (marge « en dehors »), on obtiendrait 1 356,42 x 1,10 = 1 492,06 euros HT. L'énoncé précisant « marge sur le prix de vente HT », c'est le premier calcul qui est retenu.

4. TVA applicable

La prestation est un transport intracommunautaire de biens. La règle générale de territorialité (article 259-1 du CGI, transposant l'article 44 de la directive 2006/112/CE) situe la prestation au lieu d'établissement du PRENEUR assujetti.

- Ici, le preneur du transport est la SA MBL MECANIC : vendeur en DAP, c'est elle qui organise et paie le transport, donc le donneur d'ordre du transporteur. Elle est assujettie et établie en France : la prestation est soumise à la TVA française au taux normal de 20 %.
- Montant : TVA = 1 507,13 x 0,20 = 301,43 euros ; total TTC = 1 507,13 + 301,43 = 1 808,56 euros.

À noter : si le preneur avait été le client espagnol assujetti (cas d'un Incoterm de type EXW ou FCA), la prestation aurait été située en Espagne, facturée hors taxe avec la mention « Autoliquidation, article 44 de la directive 2006/112/CE », la TVA étant acquittée par le preneur espagnol. Le seul franchissement d'une frontière ne dispense donc pas de TVA : c'est la qualité et le lieu d'établissement du preneur qui commandent.

5. Émissions de CO2 de la prestation

Émissions = distance x facteur d'émission = 867 km x 0,820 kgCO2e/km = 710,94 kgCO2e, soit environ 0,711 tonne de CO2e.

6. Mention environnementale à porter sur la facture

Le prestataire doit informer son client de la quantité de gaz à effet de serre émise par la prestation (obligation d'information GES, article L.1431-3 du code des transports et textes d'application). La mention figure sur la facture ou dans un document joint et précise la valeur, l'unité et la méthode/source des données.

Exemple de rédaction :
« Information sur la quantité de gaz à effet de serre émise par la prestation de transport (article L.1431-3 du code des transports) : 710,94 kgCO2e, soit 0,711 tCO2e, pour un trajet de 867 km. Calcul effectué selon la méthode réglementaire, à partir d'un facteur d'émission de 0,820 kgCO2e/km (valeur de niveau 1, données de référence par défaut), périmètre du puits à la roue. »$corr$,
  scoring_grid    = $corr$Barème sur 6 points (total = 1 + 2 + 1 + 1 + 0,5 + 0,5 = 6).

Q1 (1 pt) : 0,25 pt organisation du transport par le vendeur ; 0,25 pt frais de transport à la charge du vendeur jusqu'à Barcelone (déchargement et formalités d'importation à la charge de l'acheteur) ; 0,5 pt transfert des risques au lieu de destination convenu, marchandise mise à disposition sur le véhicule arrivant, non déchargée.

Q2 (2 pts) : 0,5 pt calcul du temps de conduite (867 / 68 = 12,75 h) et du temps total de mission (15,75 h) ; 0,5 pt terme kilométrique (0,615 x 867 = 533,21 euros) ; 0,5 pt terme horaire (27,08 x 15,75 = 426,51 euros) ; 0,25 pt terme journalier (198,35 x 2 = 396,70 euros) ; 0,25 pt total du coût de revient (1 356,42 euros) et présentation détaillée du trinôme. Tolérance d'arrondi de plus ou moins 1 euro sur le total.

Q3 (1 pt) : 1 pt pour le prix de vente HT de 1 507,13 euros obtenu par division par 0,90 (marge en dedans). N'accorder que 0,5 pt si le candidat applique une marge en dehors (1 492,06 euros) sans justification.

Q4 (1 pt) : 0,5 pt pour l'énoncé de la règle de territorialité (TVA due au lieu d'établissement du preneur assujetti, article 259-1 du CGI) ; 0,5 pt pour la conclusion chiffrée cohérente avec le preneur identifié (preneur français SA MBL MECANIC : TVA française à 20 %, soit 301,43 euros, total TTC 1 808,56 euros ; preneur espagnol assujetti : facturation HT avec mention d'autoliquidation). Les deux conclusions sont acceptées si le preneur est correctement identifié et justifié.

Q5 (0,5 pt) : 867 x 0,820 = 710,94 kgCO2e (0,711 tCO2e). 0,25 pt si la formule est posée sans résultat exact.

Q6 (0,5 pt) : mention environnementale complète comportant la valeur chiffrée en kgCO2e, le rappel de l'obligation d'information GES et la méthode ou le facteur d'émission utilisé. 0,25 pt si la valeur seule est reprise sans référence à l'obligation réglementaire.$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch15:ex15.3' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ EXERCICE 16.1 (6 points)

1) Tableau de suivi complété (solde = palettes livrées − palettes récupérées)

| Date | Client | Pal. livrées | Pal. récupérées | Solde semaine | Observations |
|---|---|---|---|---|---|
| 24/03 | MECA-LOG | 18 | 18 | 0 | Échange équilibré, aucune dette |
| 24/03 | SKODA | 12 | 0 | +12 | Absence d'échange — BL signé : le client doit 12 palettes |
| 25/03 | GEMA SAS | 6 | 8 | −2 | Régularisation partielle : TRANSGO doit 2 palettes au client |
| 26/03 | LES SUCRERIES | 22 | 20 | +2 | Le client doit 2 palettes |
| 27/03 | FRUITS-ROUGES | 10 | 0 | +10 | Destinataire absent — report : le client doit 10 palettes |
| 28/03 | MECA-LOG | 14 | 16 | −2 | TRANSGO doit 2 palettes au client |
| **Total semaine** | | **82** | **62** | **+20** | Solde net en faveur de TRANSGO |

Contrôle : 82 palettes livrées − 62 palettes récupérées = +20 palettes dues à TRANSGO.
Soldes cumulés par client : SKODA +12 ; FRUITS-ROUGES +10 ; LES SUCRERIES +2 ; MECA-LOG 0 + (−2) = −2 ; GEMA SAS −2.

2) Client présentant la dette palettes la plus importante
Le client SKODA, avec un solde de +12 palettes Europe non restituées. Il devance FRUITS-ROUGES (+10 palettes).

3) Action à entreprendre concernant SKODA
Il s'agit d'une absence d'échange sur une livraison dont le BL a été signé (12 palettes livrées, 0 reprise) : la dette est donc établie et opposable au client.
Actions à conduire :
- tracer immédiatement la dette dans le compte palettes (fiche de suivi, bon de dette / bon d'échange non honoré) ;
- adresser au client un relevé de compte palettes accompagné de la copie du BL signé mentionnant 12 palettes livrées et 0 palette reprise ;
- demander la restitution des 12 palettes lors de la prochaine tournée, ou à défaut leur facturation à la valeur de consigne (12 € par palette, soit 144 €) ;
- fixer un délai de régularisation et prévoir une relance écrite (mail, puis mise en demeure) en cas de non-réponse.

4) Valeur financière de la dette
Base retenue : 12 € par palette Europe (donnée de l'énoncé).
Dette totale (solde net de la semaine, ligne « Total ») : 20 palettes × 12 € = **240 €**.
Détail si l'on ne compense pas les soldes négatifs :
- créances de TRANSGO (soldes positifs) : 12 + 2 + 10 = 24 palettes → 24 × 12 € = 288 € ;
- dettes de TRANSGO envers les clients (soldes négatifs) : 2 + 2 = 4 palettes → 4 × 12 € = 48 € ;
- position nette : 288 € − 48 € = 240 €.
Réponse attendue : 240 € (la présentation détaillée 288 € / 48 € / 240 € est valorisée ; 288 € est accepté s'il est explicitement présenté comme le total des seules créances clients, sans compensation).$corr$,
  scoring_grid    = $corr$Total : 6 points

Q1 — Tableau complété (3 points)
- 0,5 pt par ligne de solde exacte (6 lignes : 0 / +12 / −2 / +2 / +10 / −2) = 3 pts
- Totaux exigés (82 livrées, 62 récupérées, +20) : retirer 0,5 pt s'ils sont absents ou faux (plancher 0 sur la question)
- Sens du solde inversé sur une ligne (positif/négatif) : 0 pt pour la ligne

Q2 — Client le plus endetté (1 point)
- SKODA identifié : 0,5 pt
- Solde chiffré (+12 palettes) et/ou justification par comparaison avec FRUITS-ROUGES (+10) : 0,5 pt

Q3 — Action concernant SKODA (1 point)
- Constat que le BL signé établit la dette (12 livrées, 0 reprise) : 0,25 pt
- Enregistrement de la dette au compte palettes / bon de dette : 0,25 pt
- Relevé de compte palettes + demande écrite de restitution avec délai : 0,25 pt
- Alternative de facturation à 12 € la palette (144 €) et relance / mise en demeure si non-réponse : 0,25 pt

Q4 — Valeur financière (1 point)
- Méthode de calcul correcte (nombre de palettes × 12 €) : 0,5 pt
- Résultat exact 240 € (ou détail 288 € / 48 € / net 240 €) : 0,5 pt
- 288 € accepté (0,75 pt max sur la question) s'il est explicitement justifié comme total des seules créances clients sans compensation

Contrôle : 3 + 1 + 1 + 1 = 6 = max_score$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch16:ex16.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ EXERCICE 16.2 (6 points)

Contexte : client FRUITS SECS (Mâcon), 38 palettes Europe non restituées depuis 4 semaines, consigne contractuelle 12 € HT/palette, CGV : restitution sous 30 jours maximum.

1) Valeur financière totale de la dette palettes
38 palettes Europe × 12 € HT = **456 € HT**.
Si la refacturation est soumise à la TVA au taux normal (20 %) : 456 × 1,20 = 547,20 € TTC (mention valorisée, non exigée).
Remarque de méthode : la dette est constatée depuis 4 semaines (≈ 28 jours) ; le délai contractuel de 30 jours arrive donc à échéance et il est déjà dépassé pour les livraisons les plus anciennes. La consignation peut être convertie en facturation dès l'expiration de ce délai, après mise en demeure restée sans effet.

2) Documents justifiant la dette palettes (au moins trois attendus)
- les bons de livraison (BL) signés par le client, mentionnant le nombre de palettes livrées et le nombre de palettes reprises ;
- les lettres de voiture (CMR en international), support contractuel du transport, sur lesquelles figure l'échange ou l'absence d'échange de supports ;
- les bons d'échange de palettes (bons de dette / vouchers palettes) émis lorsque le client ne restitue pas les supports au déchargement ;
- le relevé ou compte palettes tenu par l'entreprise (tableau de suivi des mouvements entrées/sorties par client) ;
- les CGV acceptées par le client, qui fixent la consigne à 12 € HT et le délai de restitution de 30 jours ;
- accessoirement : la trace des relances (mails, comptes rendus d'appels), qui prouve l'absence de régularisation.

3) Mail de mise en demeure (client FRUITS SECS)
Objet : Mise en demeure — Restitution de 38 palettes Europe consignées ou règlement de 456 € HT

Madame, Monsieur,

Sauf erreur de notre part, notre compte palettes fait apparaître à ce jour une dette de 38 palettes Europe à votre charge, correspondant aux livraisons effectuées par nos soins et non suivies d'un échange de supports. Les bons de livraison signés, les lettres de voiture et le relevé de notre compte palettes, dont copies sont jointes, en attestent.

Nos conditions générales de vente, que vous avez acceptées, prévoient que les palettes consignées doivent être restituées dans un délai maximum de 30 jours. Ce délai est aujourd'hui échu et nos relances téléphoniques successives sont restées sans effet.

En conséquence, nous vous mettons en demeure de procéder, sous quinze jours à compter de la réception du présent courrier :
- soit à la restitution effective des 38 palettes Europe, à l'occasion d'une prochaine livraison ou par enlèvement organisé par vos soins ;
- soit au règlement de la valeur de consigne correspondante, soit 38 palettes × 12 € HT = 456 € HT, qui fera l'objet d'une facture.

À défaut de régularisation dans ce délai, nous nous verrons contraints d'émettre la facture correspondante, d'appliquer les pénalités de retard et l'indemnité forfaitaire de recouvrement prévues par nos CGV et le code de commerce, et d'engager toute action de recouvrement utile.

Nous restons à votre disposition pour convenir des modalités pratiques de la restitution et vous prions d'agréer, Madame, Monsieur, l'expression de nos salutations distinguées.

[Prénom NOM], Gestionnaire de transport
AUVERGNE LOGISTICS — [téléphone] — [email]
PJ : relevé du compte palettes, copies des BL signés, copie des CGV

(Remarque : pour être pleinement opposable et donner date certaine, cette mise en demeure doit être doublée d'un envoi en lettre recommandée avec accusé de réception.)

4) Actions en cas d'absence de réponse aux relances
- Envoyer une mise en demeure en LRAR (date certaine, point de départ des intérêts de retard).
- Facturer les palettes non restituées à la valeur de consigne (456 € HT) et appliquer les pénalités de retard ainsi que l'indemnité forfaitaire de recouvrement prévues par les CGV et le code de commerce.
- Bloquer ou conditionner les prochaines livraisons à un échange systématique de palettes, voire suspendre les échanges de supports pour ce client.
- Confier le dossier au service recouvrement ou à une société de recouvrement, puis, à défaut d'accord, engager une procédure judiciaire (injonction de payer devant le tribunal de commerce, ou assignation).
- En interne : provisionner la créance, tracer l'incident au dossier client et réviser les conditions commerciales (consigne facturée d'avance, dépôt de garantie, passage à un système de location de palettes).$corr$,
  scoring_grid    = $corr$Total : 6 points

Q1 — Valeur de la dette (1 point)
- Calcul posé : 38 × 12 € : 0,5 pt
- Résultat 456 € HT : 0,5 pt
- (Mention du TTC 547,20 € ou de l'échéance du délai de 30 jours : valorisée, non exigée)

Q2 — Documents justificatifs (1,5 point)
- 0,5 pt par document pertinent cité, dans la limite de 3 (BL signés ; lettre de voiture / CMR ; bons d'échange palettes ; relevé / compte palettes ; CGV)
- Aucun point pour une réponse générique (« les documents de transport ») sans nommer les pièces

Q3 — Mail de mise en demeure (2,5 points)
- Objet explicite et forme professionnelle (formules d'appel et de politesse, signature) : 0,5 pt
- Rappel des faits chiffrés : 38 palettes, référence aux BL signés et aux relances restées sans suite : 0,5 pt
- Référence à la clause des CGV (restitution sous 30 jours) et constat de l'échéance : 0,5 pt
- Alternative claire imposée au client : restitution des 38 palettes OU règlement de 456 € HT : 0,5 pt
- Délai impératif fixé et annonce des suites en cas de non-régularisation (facturation, pénalités, recouvrement, LRAR) : 0,5 pt

Q4 — Actions en cas de non-réponse (1 point)
- 0,25 pt par action pertinente citée, dans la limite de 4, parmi : mise en demeure en LRAR ; facturation des palettes + pénalités de retard ; suspension / conditionnement des échanges ou des livraisons ; recouvrement amiable puis judiciaire (injonction de payer) ; révision des conditions contractuelles (consigne payée d'avance, dépôt de garantie)

Contrôle : 1 + 1,5 + 2,5 + 1 = 6 = max_score$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch16:ex16.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ EXERCICE 17.1 (6 points)

Tableau de traduction (français → anglais). Les variantes acceptées figurent entre parenthèses.

| Français | Anglais |
|---|---|
| Expéditeur | Consignor (sender, shipper) |
| Destinataire | Consignee (receiver) |
| Panne | Breakdown |
| Retard | Delay |
| Bon de livraison signé | Signed delivery note (signed POD — proof of delivery) |
| Lettre de voiture | Consignment note (waybill ; CMR note en transport international) |
| Charge utile | Payload (useful load, carrying capacity) |
| Manquant | Shortage (missing item, short delivery) |
| Avarie | Damage |
| Fret de retour | Return load (backhaul, return freight) |
| Transporteur | Carrier (haulier, road haulier) |
| Sous-traitant | Subcontractor |

Points de vigilance à signaler aux stagiaires :
- ne pas confondre consignor (expéditeur) et consignee (destinataire) : ce sont les deux termes clés de la lettre de voiture CMR ;
- shipper est courant à l'oral, mais consignor est le terme figurant sur le CMR ;
- damage (avarie) est à distinguer de shortage (manquant) : les deux motifs donnent lieu à des réserves distinctes (reservations) sur la lettre de voiture ;
- payload (charge utile) est le poids de marchandise transportable, à distinguer du gross vehicle weight (PTAC).$corr$,
  scoring_grid    = $corr$Total : 6 points

- 0,5 point par terme correctement traduit, pour les 12 termes du tableau : 12 × 0,5 = 6 points.
- Termes attendus : consignor (ou sender / shipper) ; consignee ; breakdown ; delay ; signed delivery note (ou signed POD) ; consignment note (ou waybill / CMR note) ; payload ; shortage (ou missing item) ; damage ; return load (ou backhaul) ; carrier (ou haulier) ; subcontractor.
- Toute variante figurant entre parenthèses dans le corrigé donne droit à la totalité des 0,5 point.
- Faute d'orthographe n'empêchant pas la compréhension : 0,25 point.
- Confusion consignor / consignee : 0 point sur chacun des deux termes concernés.

Contrôle : 12 × 0,5 = 6 = max_score$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch17:ex17.1' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

UPDATE public.question_bank SET
  expected_answer = $corr$CORRIGÉ EXERCICE 17.2 (6 points)

1) Réponse professionnelle au client LONDON MOTORS (en anglais)

Proposition de réponse (au téléphone, puis confirmée par mail) :

« Good afternoon Mr [Name], thank you for calling, and please accept our sincere apologies for this delay. I fully understand your concern: your 20 Euro pallets of car parts were due in Birmingham this morning at 10:00.

Let me explain exactly what happened. Our vehicle left Clermont-Ferrand as planned, but the driver suffered a mechanical breakdown near Lyon at 09:30 this morning. The truck could not be repaired on site, so the goods were unable to continue their journey as scheduled.

We have already taken action: a replacement vehicle is being organised, the pallets are being transhipped and the shipment is back on the road. Your consignment is complete and undamaged.

The new estimated time of arrival at your premises in Birmingham is 17:00 today. Could you please confirm that your warehouse will still be able to receive the goods at that time? If not, we will arrange delivery first thing tomorrow morning at no extra cost.

I will personally keep you informed: I will call you back as soon as the replacement vehicle has departed, and I will send you a written confirmation by e-mail with the new ETA and the driver's contact details. Once again, please accept our apologies for the inconvenience caused. »

Structure attendue (les 5 points a→e de l'énoncé) :
a) excuses et prise en compte de la situation (apology and acknowledgement) ;
b) explication factuelle de la panne (breakdown near Lyon at 09:30, vehicle could not be repaired on site) ;
c) solution mise en place (replacement vehicle being organised, transhipment of the 20 pallets) ;
d) nouvelle heure d'arrivée estimée (new ETA: 17:00 today in Birmingham) ;
e) engagement d'information continue (I will keep you informed / call you back / written confirmation by e-mail).

2) Traduction en français
Phrase source : « The consignee refused the goods due to visible damage on two pallets. We need the signed CMR with reservations. »

Traduction attendue :
« Le destinataire a refusé la marchandise en raison d'une avarie apparente sur deux palettes. Nous avons besoin de la lettre de voiture CMR signée avec les réserves. »

Variantes acceptées : « Le destinataire a refusé les marchandises du fait de dommages visibles sur deux palettes. Il nous faut le CMR signé portant les réserves. »

Commentaire pédagogique (hors barème) : l'avarie étant apparente, les réserves doivent être portées sur la lettre de voiture au moment de la livraison, en présence du chauffeur, et être précises et motivées (nature et importance du dommage). Une avarie non apparente relève au contraire d'une protestation motivée écrite adressée au transporteur : en transport intérieur, dans les 3 jours, dimanches et jours fériés non compris (art. L.133-3 du code de commerce), à défaut de quoi l'action contre le transporteur est éteinte (forclusion). En transport international sous convention CMR (cas de Birmingham), les réserves pour perte ou avarie non apparente doivent être adressées dans les 7 jours de la livraison, dimanches et jours fériés non compris (art. 30 CMR).$corr$,
  scoring_grid    = $corr$Total : 6 points

Q1 — Réponse professionnelle en anglais (4 points)
- a) Excuses et prise en compte de l'inquiétude du client : 0,5 pt
- b) Explication factuelle de la panne (breakdown, secteur de Lyon, 09:30) : 0,75 pt
- c) Solution en place (replacement vehicle, transbordement des 20 palettes) : 0,75 pt
- d) Nouvelle ETA annoncée clairement (17:00 à Birmingham) : 0,75 pt
- e) Engagement de tenir le client informé (rappel, confirmation écrite) : 0,75 pt
- Qualité de la langue et registre professionnel (formules de politesse, anglais compréhensible, ton commercial) : 0,5 pt
- Réponse rédigée en français : 0 pt sur la qualité de langue et plafond de 2 pts sur la question
Sous-total : 0,5 + 0,75 + 0,75 + 0,75 + 0,75 + 0,5 = 4 pts

Q2 — Traduction en français (2 points)
- « Le destinataire a refusé la marchandise » (consignee = destinataire) : 0,75 pt
- « en raison d'une avarie apparente / de dommages visibles sur deux palettes » : 0,5 pt
- « la lettre de voiture CMR signée avec réserves » (CMR + réserves) : 0,75 pt
- Confusion destinataire / expéditeur : 0 pt sur le premier item

Contrôle : 4 + 2 = 6 = max_score$corr$,
  active = false
WHERE source_ref = 'mft-2026-gotrm-ccp1-qr-v2:ch17:ex17.2' AND type = 'qr'
  AND formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm');

COMMIT;

-- CONTRÔLE : doit renvoyer 0 (plus aucune QR GOTRM sans corrigé).
-- SELECT count(*) FROM public.question_bank qb
--   JOIN public.formations f ON f.id=qb.formation_id
--  WHERE f.slug='gotrm' AND qb.type='qr'
--    AND (qb.expected_answer IS NULL OR qb.scoring_grid IS NULL);