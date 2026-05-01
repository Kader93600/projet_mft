-- =====================================================================
-- GLOSSAIRE — ERTV (Exploitant en Transport Routier de Voyageurs)
-- 50 termes essentiels.
-- Idempotent : ON CONFLICT (lower(term)) DO NOTHING.
-- =====================================================================

DO $glo_ertv$
DECLARE
  v_formation uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'ertv';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation ertv introuvable.';
  END IF;

  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source)
  VALUES
    -- ─── Cadre réglementaire transport voyageurs ────────────────────
    ('Capacité de transport voyageurs', 'Attestation de capacité professionnelle obligatoire pour exercer le transport public routier de voyageurs. Délivrée après examen écrit ou équivalence (3 ans d''expérience en gestion).', v_formation, ARRAY['Capa voyageurs'], 'Règlement (CE) n° 1071/2009'),
    ('Licence de transport intérieur voyageurs', 'Document obligatoire délivré par la DREAL pour exercer le transport routier de voyageurs en France. Distinct de la licence marchandises.', v_formation, ARRAY[]::text[], 'Décret n° 99-752'),
    ('Licence communautaire voyageurs', 'Document UE permettant les services réguliers internationaux ou occasionnels entre États membres. Renouvelable tous les 10 ans.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 1073/2009'),
    ('Service régulier', 'Service de transport effectué selon une fréquence et un itinéraire préétablis, où les voyageurs sont pris en charge à des arrêts déterminés. Ex : ligne d''autocar urbaine.', v_formation, ARRAY[]::text[], 'Code des transports L. 3111-1'),
    ('Service occasionnel', 'Service de transport non régulier : groupes constitués à l''avance, voyages organisés, transport scolaire occasionnel. Souplesse d''horaires et d''itinéraires.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('AOM', 'Autorité Organisatrice de la Mobilité. Collectivité (commune, intercommunalité, région) qui définit les services de transport public sur son territoire.', v_formation, ARRAY['Autorité organisatrice de la mobilité'], 'Loi LOM'),
    ('DSP', 'Délégation de Service Public. Contrat par lequel une AOM confie à un exploitant la gestion d''un service public de transport (ligne, réseau).', v_formation, ARRAY[]::text[], 'CCP'),
    ('Cabotage voyageurs', 'Transport intérieur effectué par un transporteur étranger en complément d''un service international. Strictement encadré.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 1073/2009'),

    -- ─── Véhicules et équipements ───────────────────────────────────
    ('Autocar', 'Véhicule de transport en commun de voyageurs > 9 places assises (conducteur compris). Catégorie M3 (PTAC > 5 T) ou M2 (PTAC ≤ 5 T).', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Minibus', 'Véhicule de transport en commun de 9 places maximum (conducteur compris) — catégorie M2. Permis B + FIMO suffisants pour le transport public.', v_formation, ARRAY['Minicar'], 'Code de la route'),
    ('Capacité d''emport', 'Nombre total de personnes transportables dans un véhicule, indiqué sur la carte grise. Inclut le conducteur.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Limiteur de vitesse', 'Dispositif obligatoire sur les autocars depuis 1992 limitant la vitesse à 100 km/h sur autoroute, 80 km/h sur route.', v_formation, ARRAY[]::text[], 'Décret n° 90-1051'),
    ('Éthylotest anti-démarrage', 'Dispositif obligatoire depuis 2010 sur les autocars de transport scolaire et de tourisme. Le moteur ne démarre que si le conducteur souffle un taux conforme.', v_formation, ARRAY['EAD'], 'Décret n° 2009-911'),
    ('Tachygraphe voyageurs', 'Tachygraphe numérique obligatoire pour les véhicules de plus de 9 places > 9 m de long et/ou affectés à la ligne régulière > 50 km.', v_formation, ARRAY[]::text[], 'Règlement (UE) n° 165/2014'),

    -- ─── Sécurité passagers ─────────────────────────────────────────
    ('Ceinture de sécurité', 'Obligation pour tous les passagers d''autocar (sauf très anciens véhicules). Le conducteur doit informer les passagers à chaque montée.', v_formation, ARRAY[]::text[], 'Code de la route art. R. 412-2'),
    ('Marteau brise-vitre', 'Dispositif d''évacuation d''urgence obligatoire dans les autocars. Au moins un par fenêtre. Test régulier à effectuer.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Issue de secours', 'Sortie destinée à l''évacuation rapide en cas d''urgence. Nombre minimum réglementaire selon la capacité du véhicule.', v_formation, ARRAY[]::text[], 'Norme R107'),
    ('Plan d''évacuation', 'Document détaillant la procédure d''évacuation d''un véhicule. Doit être affiché à bord et le conducteur formé.', v_formation, ARRAY[]::text[], 'Réglementation transport'),
    ('Visite technique passagers', 'Contrôle technique obligatoire des véhicules de transport en commun : tous les 6 mois (autocars) ou annuel selon catégorie.', v_formation, ARRAY[]::text[], 'Code de la route'),

    -- ─── Réglementation conducteur ──────────────────────────────────
    ('FIMO voyageurs', 'Formation Initiale Minimale Obligatoire — voyageurs. 140 heures préalables à l''exercice de la profession de conducteur de transport en commun.', v_formation, ARRAY[]::text[], 'Décret n° 2007-1340'),
    ('FCO voyageurs', 'Formation Continue Obligatoire — voyageurs. 35 heures tous les 5 ans, distincte de la FCO marchandises.', v_formation, ARRAY[]::text[], 'Décret n° 2007-1340'),
    ('Permis D', 'Permis de conduire pour véhicules de transport en commun > 9 places (autocars, autobus). Visite médicale obligatoire tous les 5 ans.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Permis D1', 'Permis pour véhicules de transport en commun jusqu''à 16 + 1 places + remorque ≤ 750 kg. Catégorie intermédiaire.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Visite médicale conducteur', 'Examen médical périodique obligatoire pour le maintien des permis de transport en commun (D, D1) : tous les 5 ans avant 60 ans, tous les 2 ans après 60 ans, annuel après 76 ans.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Casier B2', 'Bulletin n° 2 du casier judiciaire, plus restreint que le B1. Doit être vierge pour exercer le transport en commun (transport scolaire en particulier).', v_formation, ARRAY[]::text[], 'CPP'),

    -- ─── Conventions et tarification ────────────────────────────────
    ('CCNTRAAT 1671', 'Convention Collective Nationale Transports Routiers — annexe 1 voyageurs. Régit conditions de travail des conducteurs voyageurs.', v_formation, ARRAY['Convention voyageurs'], 'IDCC 0016'),
    ('Salaire minimum conventionnel', 'Salaire plancher fixé par la CCNTRAAT par coefficient hiérarchique. Supérieur au SMIC dans certains coefficients.', v_formation, ARRAY['SMC'], 'CCNTRAAT'),
    ('Tarification urbaine', 'Tarif unique ou par zones défini par l''AOM. Souvent abonnement mensuel/annuel. Subventionnée par la collectivité.', v_formation, ARRAY[]::text[], 'AOM'),
    ('Tarification interurbaine', 'Tarif au kilomètre ou forfaitaire pour les services entre communes. Plus libre que l''urbaine.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Versement transport (mobilité)', 'Contribution obligatoire des employeurs > 11 salariés dans les zones AOM avec service public. Finance les transports collectifs.', v_formation, ARRAY['VT','Versement mobilité'], 'CGI art. L. 2333-64'),

    -- ─── Transport scolaire ─────────────────────────────────────────
    ('Transport scolaire', 'Service organisé pour le transport régulier d''élèves vers leurs établissements. Compétence des Régions depuis 2017 (loi NOTRe).', v_formation, ARRAY[]::text[], 'Loi NOTRe'),
    ('Convoyeur scolaire', 'Personne accompagnant les élèves dans le car scolaire. Obligatoire pour les classes maternelles/primaires dans certains cas.', v_formation, ARRAY['Accompagnateur'], 'Réglementation locale'),
    ('Étiquette Transport Scolaire', 'Signalisation jaune obligatoire à l''avant et l''arrière des véhicules transportant des élèves.', v_formation, ARRAY[]::text[], 'Arrêté du 2 juillet 1982'),
    ('Limiteur 90 km/h', 'Limitation spécifique sur autoroute pour les véhicules transportant des élèves. Affichage obligatoire.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Plan transport scolaire', 'Document de l''AOM (Région) définissant lignes, horaires, points d''arrêt, élèves transportés. Révisable annuellement.', v_formation, ARRAY[]::text[], 'Réglementation Région'),

    -- ─── Tourisme & événementiel ────────────────────────────────────
    ('Voyage organisé', 'Forfait combinant transport, hébergement et/ou autres prestations. Régi par le Code du tourisme (immatriculation au registre des opérateurs de voyages).', v_formation, ARRAY['Forfait touristique'], 'Code du tourisme'),
    ('Carnet TIR voyageurs', 'Document douanier pour le transit international de voyageurs hors UE. Plus rare qu''en marchandises mais existe.', v_formation, ARRAY[]::text[], 'Convention TIR'),
    ('Service Interbus', 'Accord multilatéral facilitant les services occasionnels internationaux de transport de voyageurs entre 19 pays européens.', v_formation, ARRAY[]::text[], 'Accord Interbus 2002'),
    ('Affichage des tarifs', 'Obligation d''afficher clairement les tarifs des services de transport de voyageurs (urbain, occasionnel, tourisme) au point de vente et à bord.', v_formation, ARRAY[]::text[], 'Code consommation'),

    -- ─── Économie et gestion ────────────────────────────────────────
    ('Coefficient de remplissage', 'Ratio entre le nombre de passagers transportés et la capacité du véhicule. Indicateur clé de productivité.', v_formation, ARRAY['Taux de remplissage'], 'KPI exploitation'),
    ('Voyageur-kilomètre', 'Unité de mesure du trafic : 1 voyageur transporté sur 1 km. Permet de comparer l''activité de différents services.', v_formation, ARRAY['Pkm'], 'Statistiques transport'),
    ('Recettes commerciales', 'Recettes issues des billets et abonnements vendus aux voyageurs. À distinguer des subventions des AOM.', v_formation, ARRAY[]::text[], 'Comptabilité transport'),
    ('Subvention d''équilibre', 'Versement de l''AOM à l''exploitant pour couvrir l''écart entre coûts d''exploitation et recettes commerciales sur une ligne déficitaire.', v_formation, ARRAY[]::text[], 'DSP'),

    -- ─── Qualité de service ─────────────────────────────────────────
    ('Indicateur de ponctualité', 'Pourcentage de courses réalisées à l''heure (tolérance ±5 min). Engagement contractuel souvent dans les DSP.', v_formation, ARRAY[]::text[], 'KPI qualité'),
    ('Régularité', 'Indicateur de respect du cadencement (intervalles entre passages). Important sur les lignes urbaines à haute fréquence.', v_formation, ARRAY[]::text[], 'KPI qualité'),
    ('Charte qualité voyageur', 'Document définissant les engagements de l''exploitant envers les voyageurs (info, propreté, accessibilité, ponctualité).', v_formation, ARRAY[]::text[], 'Démarche qualité'),
    ('Voyageurs PMR', 'Personnes à Mobilité Réduite. Obligation d''accessibilité des véhicules et points d''arrêt depuis la loi handicap de 2005.', v_formation, ARRAY['Personnes à mobilité réduite'], 'Loi n° 2005-102'),
    ('Information voyageurs', 'Système d''info en temps réel sur horaires, retards, perturbations. Obligation contractuelle dans la plupart des DSP modernes.', v_formation, ARRAY['SAEIV'], 'Démarche qualité'),

    -- ─── Sûreté ─────────────────────────────────────────────────────
    ('Sûreté transport public', 'Ensemble des mesures pour prévenir les actes malveillants (terrorisme, agressions). Distincte de la sécurité (accidents).', v_formation, ARRAY[]::text[], 'Code sécurité intérieure'),
    ('Vidéosurveillance autocar', 'Système de caméras embarqué pour la sécurité voyageurs et conducteurs. Encadré par la CNIL : signalisation, durée de conservation.', v_formation, ARRAY[]::text[], 'CNIL'),
    ('Plan Vigipirate', 'Plan gouvernemental de vigilance contre le terrorisme. Niveaux : alerte, urgence attentat. Mesures spécifiques pour les transports en commun.', v_formation, ARRAY[]::text[], 'SGDSN')
  ON CONFLICT (lower(term)) DO NOTHING;

  RAISE NOTICE 'Glossaire ERTV : 50 termes insérés (ou existants).';
END
$glo_ertv$;
