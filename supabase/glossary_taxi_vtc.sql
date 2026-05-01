-- =====================================================================
-- GLOSSAIRE — Taxi / VTC (Voiture de Transport avec Chauffeur)
-- 50 termes essentiels.
-- =====================================================================

DO $glo_taxi$
DECLARE
  v_formation uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'taxi-vtc';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation taxi-vtc introuvable.';
  END IF;

  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source)
  VALUES
    -- ─── Distinction Taxi vs VTC ───────────────────────────────────
    ('Taxi', 'Véhicule de transport public particulier autorisé à stationner et circuler en quête de clientèle, à utiliser une voie réservée et à accepter une course hélée dans la rue.', v_formation, ARRAY[]::text[], 'Code des transports L. 3121-1'),
    ('VTC', 'Voiture de Transport avec Chauffeur. Service réservé à l''avance uniquement (pas de maraude). Tarification libre négociée avant le départ.', v_formation, ARRAY['Voiture de Transport avec Chauffeur'], 'Code des transports L. 3122-1'),
    ('Maraude', 'Pratique de circuler en attente de clientèle. Réservée aux taxis. Interdite aux VTC sous peine d''amende.', v_formation, ARRAY['Maraude électronique'], 'Code des transports'),
    ('Maraude électronique', 'Captation de clients via application mobile sans réservation préalable, considérée illégale pour les VTC. Distinction floue, source de contentieux.', v_formation, ARRAY[]::text[], 'Jurisprudence'),
    ('Réservation préalable', 'Obligation pour les VTC : la course doit être réservée en amont (même quelques minutes avant). Justifie le service.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Stationnement à la borne', 'Droit exclusif des taxis de stationner sur les bornes officielles dédiées (gares, aéroports, etc.).', v_formation, ARRAY[]::text[], 'Code des transports'),

    -- ─── Accès à la profession ──────────────────────────────────────
    ('Carte professionnelle taxi', 'Document obligatoire délivré par la préfecture après réussite de l''examen taxi. Permet d''exercer.', v_formation, ARRAY['CP taxi'], 'Code des transports'),
    ('Carte VTC', 'Document obligatoire délivré par la préfecture après réussite de l''examen VTC. Validité 5 ans, renouvelable.', v_formation, ARRAY['Carte professionnelle VTC'], 'Code des transports'),
    ('Examen taxi', 'Épreuve écrite (réglementation, gestion, sécurité, langue) + épreuve pratique (conduite + connaissance du territoire). Réussite obligatoire.', v_formation, ARRAY[]::text[], 'Arrêté du 6 avril 2017'),
    ('Examen VTC', 'Épreuve écrite (réglementation, gestion, sécurité, anglais) + épreuve pratique (conduite). Différent de l''examen taxi (pas de connaissance du territoire).', v_formation, ARRAY[]::text[], 'Arrêté du 6 avril 2017'),
    ('Permis B 3 ans', 'Permis de conduire B obligatoire depuis au moins 3 ans (réduit à 2 ans après conduite accompagnée) pour exercer comme taxi ou VTC.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Visite médicale taxi/VTC', 'Examen médical obligatoire chez un médecin agréé préfecture. Initial puis tous les 5 ans avant 60 ans, plus fréquent après.', v_formation, ARRAY[]::text[], 'Réglementation'),
    ('Casier B2 vierge', 'Bulletin n° 2 du casier judiciaire vierge obligatoire pour exercer. Vérifié à l''inscription et au renouvellement.', v_formation, ARRAY[]::text[], 'CPP'),

    -- ─── Réglementation des courses ─────────────────────────────────
    ('Course taxi', 'Trajet effectué par un taxi avec un client. Tarif réglementé : prix au km + temps + suppléments officiels (gare, bagages, animaux).', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Tarif réglementé', 'Prix encadré pour les taxis, fixé annuellement par arrêté préfectoral. Affichage obligatoire dans le véhicule.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Tarif libre', 'Prix négocié librement avec le client AVANT le départ pour les VTC. Doit figurer sur la facture émise systématiquement.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Compteur horokilométrique', 'Appareil obligatoire dans les taxis affichant le tarif applicable selon la distance et le temps. Inviolable, plombé par les services préfectoraux.', v_formation, ARRAY['Taximètre'], 'Code des transports'),
    ('Lumineux', 'Dispositif lumineux placé sur le toit des taxis indiquant la disponibilité (vert) ou occupation (rouge). Obligatoire.', v_formation, ARRAY[]::text[], 'Arrêté'),
    ('Plaque taxi', 'Plaque numérotée délivrée par la mairie/préfecture. Spécifie le territoire d''exercice et le numéro de licence.', v_formation, ARRAY[]::text[], 'Réglementation locale'),
    ('Pavé VTC', 'Macaron rouge obligatoire à l''avant et l''arrière des VTC. Distingue les véhicules autorisés des particuliers.', v_formation, ARRAY['Macaron VTC'], 'Code des transports'),

    -- ─── Spécificités VTC ───────────────────────────────────────────
    ('Plateforme VTC', 'Application mobile mettant en relation chauffeurs VTC et clients (Uber, Bolt, Heetch, etc.). Statut juridique en évolution.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Capacitaire VTC', 'Document obligatoire de l''entreprise VTC, justifie la capacité financière (1 500 €/véhicule), professionnelle (carte) et honorabilité.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Inscription au registre', 'Inscription obligatoire au registre des exploitants VTC tenu par le ministère. Numéro EVTC attribué.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Numéro EVTC', 'Identifiant unique de l''entreprise VTC, attribué après inscription. À mentionner sur les factures et documents commerciaux.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Auto-entrepreneur VTC', 'Régime fiscal souvent choisi par les chauffeurs VTC indépendants. Plafond CA 77 700 € HT/an. Possible mais pas optimal au-delà.', v_formation, ARRAY[]::text[], 'Code général des impôts'),

    -- ─── Spécificités Taxi ──────────────────────────────────────────
    ('Licence ADS', 'Autorisation De Stationnement. Licence taxi numérotée délivrée par la mairie ou la préfecture. Devenue précieuse (entre 50 000 et 250 000 €) jusqu''à la loi Thévenoud.', v_formation, ARRAY['Licence taxi'], 'Loi du 1er octobre 2014'),
    ('Loi Thévenoud', 'Loi du 1er octobre 2014 réformant le secteur taxi/VTC : non transmissibilité à titre onéreux des nouvelles licences, distinction taxi/VTC clarifiée.', v_formation, ARRAY[]::text[], 'Loi n° 2014-1104'),
    ('CMS taxi', 'Conducteur Mécanicien Spécialisé. Carte professionnelle taxi exclusive d''une mention plus large.', v_formation, ARRAY[]::text[], 'Réglementation'),
    ('Maître artisan taxi', 'Statut réservé aux artisans taxi avec plusieurs années d''expérience. Avantages fiscaux et sociaux spécifiques.', v_formation, ARRAY[]::text[], 'Réglementation'),
    ('Coopérative taxi', 'Structure collective de chauffeurs taxi indépendants pour mutualiser radio, dispatching, service client.', v_formation, ARRAY[]::text[], 'Pratique'),

    -- ─── Véhicule ───────────────────────────────────────────────────
    ('Véhicule éligible VTC', 'Véhicule de moins de 6 ans (ou neuf), 4 portes, 4 à 9 places conducteur compris. Critères techniques précis.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Véhicule éligible taxi', 'Véhicule habillé selon les normes (lumineux, plaque, taximètre, imprimante). Pas de critère d''âge mais visite spécifique.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Imprimante taxi', 'Dispositif obligatoire connecté au taximètre permettant l''émission d''une facture papier. Loi anti-fraude.', v_formation, ARRAY[]::text[], 'Décret n° 2015-1116'),
    ('Visite technique pro', 'Contrôle technique spécifique pour les taxis et VTC. Plus fréquent que pour un véhicule particulier.', v_formation, ARRAY[]::text[], 'Code de la route'),

    -- ─── Tarification & paiement ────────────────────────────────────
    ('Forfait aéroport', 'Tarif fixe pour les courses entre aéroport et zone définie (Paris CDG/Orly, etc.). Ex : Paris-CDG : 56 € rive droite, 65 € rive gauche.', v_formation, ARRAY[]::text[], 'Arrêté préfectoral'),
    ('Course longue', 'Course hors agglomération. Tarif réglementé selon distance + retour à vide. Encadré par la préfecture.', v_formation, ARRAY[]::text[], 'Tarification taxi'),
    ('Supplément bagage', 'Supplément réglementé pour transport de bagages encombrants ou volumineux. Affiché obligatoirement.', v_formation, ARRAY[]::text[], 'Tarification'),
    ('Supplément animal', 'Supplément réglementé en cas de transport d''animal. Sauf chien guide d''aveugle (transport gratuit obligatoire).', v_formation, ARRAY[]::text[], 'Tarification'),
    ('TPE obligatoire', 'Terminal de Paiement Électronique obligatoire dans les taxis depuis 2014 (CB acceptée systématiquement). Recommandé pour VTC.', v_formation, ARRAY[]::text[], 'Loi consommation'),

    -- ─── Sécurité & qualité ─────────────────────────────────────────
    ('Refus de course', 'Le taxi en service ne peut refuser une course pour la destination. Sanctions : amende 4ème classe. Sauf motif légitime (sécurité, état du client).', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Discrimination', 'Refus de prise en charge pour motifs raciaux, religieux, etc. : délit pénal (1 an de prison + 45 000 €). Cas fréquents dans la profession.', v_formation, ARRAY[]::text[], 'Code pénal'),
    ('Trajet le plus court', 'Obligation pour le taxi d''emprunter l''itinéraire le plus court ou demandé par le client. Sanctions en cas de détour injustifié.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Médaille', 'Plaque d''identification du chauffeur (taxi ou VTC) à apposer en évidence dans le véhicule. Permet l''identification par le client.', v_formation, ARRAY[]::text[], 'Réglementation'),

    -- ─── Comptabilité & gestion ─────────────────────────────────────
    ('Facture obligatoire', 'Facture systématique pour course VTC ; pour taxi à la demande du client ou si > 25 €. Mentions obligatoires : prix, date, identifiant chauffeur, immatriculation.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Recettes journalières', 'Tenue d''un livre de recettes obligatoire (taxi en société). Permet la déclaration TVA et IS.', v_formation, ARRAY[]::text[], 'Code commerce'),
    ('Frais déductibles', 'Charges fiscalement déductibles : carburant, entretien véhicule, assurances, péages, location véhicule. Optimisation fiscale clé.', v_formation, ARRAY[]::text[], 'CGI'),
    ('Amortissement véhicule', 'Étalement comptable du prix du véhicule sur sa durée d''utilisation (généralement 5 ans linéaire). Déductible fiscalement.', v_formation, ARRAY[]::text[], 'PCG'),
    ('Forfaitaire kilométrique', 'Méthode de défraiement basée sur barème fiscal (~0,50 €/km). Alternative à la déduction des frais réels.', v_formation, ARRAY['Barème kilométrique'], 'CGI'),

    -- ─── Réglementation territoriale ───────────────────────────────
    ('CGS', 'Commission de Garantie de Sécurité. Compétente sur les questions taxis dans certains départements.', v_formation, ARRAY[]::text[], 'Réglementation locale'),
    ('PVE', 'Procès-Verbal Électronique. Outil de constatation des infractions par les agents (stationnement illicite, exercice illégal).', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('LOTI', 'Loi d''Orientation des Transports Intérieurs (1982). Cadre historique du secteur, partiellement remplacé par le Code des transports (2010).', v_formation, ARRAY[]::text[], 'Loi n° 82-1153'),
    ('Tarification dynamique', 'Pratique des plateformes VTC ajustant les prix en temps réel selon offre/demande. Légale tant que clairement annoncée avant la course.', v_formation, ARRAY['Surge pricing'], 'Pratique commerciale')
  ON CONFLICT (lower(term)) DO NOTHING;

  RAISE NOTICE 'Glossaire Taxi/VTC : 50 termes insérés.';
END
$glo_taxi$;
