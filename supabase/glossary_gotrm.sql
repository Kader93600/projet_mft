-- =====================================================================
-- GLOSSAIRE — GOTRM (Gestionnaire des Opérations de Transport Routier
-- de Marchandises) — Titre pro RNCP 40990, niveau 5.
-- 50 termes essentiels.
-- =====================================================================

DO $glo_gotrm$
DECLARE
  v_formation uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable.';
  END IF;

  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source)
  VALUES
    -- ─── Exploitation transport ──────────────────────────────────────
    ('Tractionnaire', 'Entreprise qui possède la traction (le tracteur routier) mais pas la marchandise. Vend ses prestations de traction à des donneurs d''ordre.', v_formation, ARRAY[]::text[], 'Vocabulaire transport'),
    ('Affrètement', 'Opération par laquelle un transporteur (l''affréteur) confie l''exécution d''un transport à un autre transporteur. Pratique courante en transport routier.', v_formation, ARRAY[]::text[], 'Code commerce'),
    ('Commissionnaire de transport', 'Intermédiaire qui organise un transport en son nom propre pour le compte d''un commettant. Diffère du transporteur (qui exécute) et du courtier (qui négocie).', v_formation, ARRAY[]::text[], 'Code commerce art. L. 132-1'),
    ('Lettre de voiture', 'Document obligatoire qui accompagne la marchandise transportée. Contient les mentions obligatoires : expéditeur, destinataire, nature, masse, prix.', v_formation, ARRAY['CMR'], 'Convention CMR'),
    ('CMR', 'Convention de Marchandise par Route. Document de transport international standardisé. Convention de Genève du 19 mai 1956.', v_formation, ARRAY['Lettre de voiture internationale'], 'Convention CMR'),
    ('Groupage', 'Technique consistant à regrouper plusieurs envois de différents expéditeurs vers une même destination dans un même véhicule. Optimise le taux de remplissage.', v_formation, ARRAY[]::text[], 'Vocabulaire transport'),
    ('Dégroupage', 'Opération inverse du groupage : séparation de la cargaison consolidée vers ses différents destinataires finaux à l''arrivée.', v_formation, ARRAY[]::text[], 'Vocabulaire transport'),
    ('Affréteur', 'Personne qui sollicite un transporteur pour l''exécution d''un transport. Synonyme moderne : commissionnaire.', v_formation, ARRAY[]::text[], 'Code commerce'),
    ('Plate-forme logistique', 'Site organisé pour stocker, trier et redistribuer des marchandises. Équipée de quais, racks, EDI. Différente d''un entrepôt simple.', v_formation, ARRAY[]::text[], 'Vocabulaire logistique'),

    -- ─── Réglementation européenne ──────────────────────────────────
    ('AETR', 'Accord Européen sur les Transports Routiers. Régit les temps de conduite et de repos hors UE (Suisse, Norvège, Russie...).', v_formation, ARRAY[]::text[], 'Accord AETR'),
    ('Règlement CE 561/2006', 'Règlement européen fixant les temps de conduite, pauses et repos pour les conducteurs en UE. Référence majeure de la profession.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 561/2006'),
    ('Loi LOM', 'Loi d''Orientation des Mobilités du 24 décembre 2019. Réforme majeure : mobilités douces, droit à la mobilité, transport de marchandises.', v_formation, ARRAY['Loi d''Orientation des Mobilités'], 'Loi n° 2019-1428'),
    ('Cabotage', 'Transport intérieur effectué par un transporteur étranger après un transport international. Encadré : 3 opérations en 7 jours maximum.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 1072/2009'),
    ('Licence communautaire', 'Document délivré par la DREAL autorisant les transports internationaux entre États membres de l''UE. Distinct de la licence intérieure.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 1072/2009'),
    ('Eurovignette', 'Système de péage variable selon les émissions et le poids des véhicules sur le réseau autoroutier européen.', v_formation, ARRAY[]::text[], 'Directive UE 1999/62'),

    -- ─── Tachygraphe & temps de service ─────────────────────────────
    ('Tachygraphe numérique', 'Tachygraphe électronique obligatoire depuis 2006 (V1) puis 2019 (V2 intelligent). Enregistre activités du conducteur sur une carte personnelle.', v_formation, ARRAY[]::text[], 'Règlement (UE) n° 165/2014'),
    ('Carte conducteur', 'Carte personnelle insérée dans le tachygraphe. Délivrée par l''Imprimerie Nationale. Validité 5 ans. Obligatoire pour tout conducteur > 3,5 T.', v_formation, ARRAY[]::text[], 'Règlement (UE) n° 165/2014'),
    ('Temps de service', 'Total des temps de conduite, des autres tâches, et de la disponibilité. Limité à 12h max (10h en règle générale) avec pause de 30min après 6h.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Temps de disponibilité', 'Période où le conducteur n''est pas tenu de rester à son poste mais doit être prêt à reprendre la conduite. Compte dans le temps de service.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Repos hebdomadaire', 'Repos d''au moins 45 heures consécutives par semaine. Réductible à 24h une semaine sur deux, avec compensation.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 561/2006'),

    -- ─── Gestion d'exploitation ─────────────────────────────────────
    ('Tarification au km', 'Méthode de calcul du prix d''un transport basée sur la distance parcourue. Varie selon type de véhicule, nature des marchandises, urgence.', v_formation, ARRAY[]::text[], 'Pratique commerciale'),
    ('Tarification au point', 'Tarif fixe pour livraison sur une zone géographique définie, indépendant du temps. Utilisé en messagerie et coursier.', v_formation, ARRAY[]::text[], 'Pratique commerciale'),
    ('Coût horaire', 'Coût total de l''exploitation d''un véhicule par heure : amortissement, salaires, charges, carburant, entretien. Base de la tarification temps.', v_formation, ARRAY[]::text[], 'CNR'),
    ('CNR', 'Comité National Routier. Organisme de référence pour les indices et coûts du transport routier de marchandises en France. Publications mensuelles.', v_formation, ARRAY['Comité National Routier'], 'Comité National Routier'),
    ('Optimisation des tournées', 'Méthode visant à organiser plusieurs livraisons pour minimiser distance, temps et coûts. Utilise algorithmes (TSP, VRP) et outils logiciels.', v_formation, ARRAY['Tournée optimisée'], 'Recherche opérationnelle'),
    ('Taux de remplissage', 'Ratio entre le volume effectivement transporté et la capacité totale du véhicule. Indicateur clé de productivité.', v_formation, ARRAY[]::text[], 'KPI exploitation'),
    ('Taux de retour à vide', 'Ratio des kilomètres parcourus à vide sur le total. Indicateur d''inefficience ; cible < 20% pour la rentabilité.', v_formation, ARRAY[]::text[], 'KPI exploitation'),

    -- ─── Documents & justificatifs ──────────────────────────────────
    ('Bon de livraison', 'Document remis au destinataire confirmant la livraison. Émargé par le destinataire ; preuve du transfert de responsabilité.', v_formation, ARRAY['BL'], 'Pratique commerciale'),
    ('Émargement électronique', 'Signature numérique sur PDA/smartphone à la livraison. Remplace le bon papier ; tracé horodaté géolocalisé.', v_formation, ARRAY['POD','Proof of delivery'], 'Vocabulaire transport'),
    ('Empotage', 'Action de remplir un conteneur avec la marchandise. Document associé : note d''empotage. Important pour responsabilité et assurance.', v_formation, ARRAY['Stuffing'], 'Vocabulaire transport'),

    -- ─── Sécurité & qualité ─────────────────────────────────────────
    ('ADR', 'Accord européen sur le transport international de marchandises Dangereuses par Route. Classification en 9 classes. Formation conducteur certifiée.', v_formation, ARRAY['Matières dangereuses'], 'Accord ADR'),
    ('Eco-conduite', 'Style de conduite visant à réduire la consommation de carburant et l''usure : anticipation, vitesse stable, frein moteur, pression pneus.', v_formation, ARRAY[]::text[], 'Démarche RSE'),
    ('Norme Euro', 'Réglementation européenne sur les émissions polluantes des véhicules motorisés. Euro 6 actuel ; Euro 7 en préparation.', v_formation, ARRAY[]::text[], 'Réglementation UE'),
    ('Charte CO2', 'Démarche volontaire de réduction des émissions CO2 dans le transport routier de marchandises. Signée avec l''ADEME.', v_formation, ARRAY['Objectif CO2'], 'ADEME'),

    -- ─── Économie & financier ───────────────────────────────────────
    ('TIPP/TICPE', 'Taxe Intérieure de Consommation sur les Produits Énergétiques (ex-TIPP). Représente une part importante du coût du carburant. Remboursement partiel possible pour les pros.', v_formation, ARRAY['TIPP','TICPE'], 'CGI'),
    ('Indice gazole CNR', 'Indice mensuel publié par le CNR reflétant l''évolution du coût du gazole pour les transporteurs. Utilisé dans les clauses d''indexation tarifaire.', v_formation, ARRAY[]::text[], 'CNR'),
    ('Clause de révision', 'Disposition contractuelle permettant d''adapter le prix d''un contrat aux variations d''indices (gazole, salaires, péages).', v_formation, ARRAY['Indexation'], 'Pratique commerciale'),
    ('Dommages indirects', 'Préjudices subis indirectement par une partie suite à un sinistre (perte de production, perte de marché). Couverture spécifique en transport.', v_formation, ARRAY[]::text[], 'Droit des assurances'),

    -- ─── RH & social ────────────────────────────────────────────────
    ('IRP', 'Instances Représentatives du Personnel. Comité Social et Économique (CSE) depuis 2017 pour entreprises ≥ 11 salariés.', v_formation, ARRAY['CSE'], 'Code travail'),
    ('Médecine du travail', 'Service obligatoire de prévention santé au travail. Visite d''embauche, périodique, de reprise. SPSTI ou service interne selon taille.', v_formation, ARRAY['SPSTI'], 'Code travail art. L. 4624-1'),
    ('IPRP', 'Intervenant en Prévention des Risques Professionnels. Acteur de la prévention en entreprise (interne ou externe via SPSTI).', v_formation, ARRAY[]::text[], 'Code travail'),
    ('AT-MP', 'Accidents du Travail et Maladies Professionnelles. Branche dédiée de la Sécurité Sociale. Cotisations patronales selon sinistralité.', v_formation, ARRAY['Accident du travail'], 'Code Sécurité Sociale'),
    ('Convention 79', 'Annexe de la CCNTRAAT spécifique aux personnels roulants marchandises. Régit primes, indemnités, durée du travail.', v_formation, ARRAY[]::text[], 'Convention collective'),

    -- ─── International ──────────────────────────────────────────────
    ('Incoterms', 'International Commercial Terms. Règles standardisées définissant les responsabilités acheteur/vendeur dans les transactions internationales (EXW, FOB, CIF, DAP, DDP...).', v_formation, ARRAY[]::text[], 'CCI 2020'),
    ('Carnet TIR', 'Document douanier international permettant le transit de marchandises sous scellés sans contrôles intermédiaires. Garantie financière par cautionnement.', v_formation, ARRAY[]::text[], 'Convention TIR'),
    ('DAU', 'Document Administratif Unique. Déclaration douanière standard pour l''import/export hors UE. Remplacé progressivement par voie électronique (DELTA-T).', v_formation, ARRAY[]::text[], 'Code des douanes UE'),
    ('Eurolicence', 'Synonyme de licence communautaire. Autorise les transports entre États membres UE sans formalités.', v_formation, ARRAY['Licence communautaire'], 'Règlement UE'),
    ('Compte propre', 'Transport effectué pour ses propres besoins (par opposition au transport public pour autrui). Pas de licence requise mais conditions à respecter.', v_formation, ARRAY[]::text[], 'Code des transports'),

    -- ─── Qualité ─────────────────────────────────────────────────────
    ('Démarche RSE', 'Responsabilité Sociétale des Entreprises. Engagement volontaire intégrant préoccupations sociales, environnementales et économiques.', v_formation, ARRAY['Responsabilité sociétale'], 'ISO 26000'),
    ('Bilan GES', 'Bilan des émissions de Gaz à Effet de Serre. Obligatoire pour entreprises > 500 salariés. Périmètre Scope 1, 2 et parfois 3.', v_formation, ARRAY['Bilan carbone'], 'Loi n° 2010-788')
  ON CONFLICT (lower(term)) DO NOTHING;

  RAISE NOTICE 'Glossaire GOTRM : 50 termes insérés (ou existants).';
END
$glo_gotrm$;
