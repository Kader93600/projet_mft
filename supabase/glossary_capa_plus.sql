-- =====================================================================
-- GLOSSAIRE — Capacité de transport lourd (+3,5T)
-- 50 termes essentiels.
-- Couvre les spécificités du transport routier > 3,5 T (réglementation
-- européenne plus stricte, FIMO, ADR, infrastructures).
-- =====================================================================

DO $glo_capap$
DECLARE
  v_formation uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-plus-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-plus-3-5t introuvable.';
  END IF;

  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source)
  VALUES
    -- ─── Cadre réglementaire ────────────────────────────────────────
    ('Capacité de transport lourd', 'Attestation de capacité professionnelle obligatoire pour exercer le transport public routier de marchandises avec des véhicules de PTAC > 3,5 T. Examen plus exigeant que pour le transport léger.', v_formation, ARRAY['Capa +3,5T'], 'Règlement (CE) n° 1071/2009'),
    ('Règlement (CE) 1071/2009', 'Règlement européen fixant les conditions d''accès à la profession de transporteur. Référence majeure : honorabilité, capacité financière, capacité professionnelle, établissement.', v_formation, ARRAY[]::text[], 'UE'),
    ('Règlement (CE) 1072/2009', 'Règlement sur l''accès au marché du transport international de marchandises. Encadre licence communautaire, cabotage, etc.', v_formation, ARRAY[]::text[], 'UE'),
    ('Mobility Package I (2020)', 'Paquet législatif européen majeur : nouvelles règles sur le détachement, retour du véhicule au pays d''établissement, cabotage, tachygraphe intelligent V2.', v_formation, ARRAY['Paquet Mobilité 1'], 'Règlement (UE) 2020/1054'),
    ('Capacité financière lourde', 'Pour transport > 3,5 T : 9 000 € pour le 1er véhicule motorisé, puis 5 000 € par véhicule supplémentaire. Très supérieure au léger (1 800 + 900).', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 1071/2009 art. 7'),
    ('Établissement stable', 'Lieu de gestion effective des opérations dans l''État membre où l''entreprise est inscrite. Documentation obligatoire au siège.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 1071/2009'),

    -- ─── Véhicules et catégories ────────────────────────────────────
    ('PL (Poids Lourd)', 'Véhicule de PTAC > 3,5 T. Catégories N2 (3,5-12 T) et N3 (>12 T) selon la directive UE.', v_formation, ARRAY['Poids lourd'], 'Code de la route'),
    ('PTAC', 'Poids Total Autorisé en Charge. Masse maximale d''un véhicule chargé fixée par le constructeur. Détermine la catégorie réglementaire.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('PTRA', 'Poids Total Roulant Autorisé. PTAC du véhicule + masse de la remorque ou semi-remorque. Limite supérieure pour rouler.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Tracteur routier', 'Véhicule motorisé conçu uniquement pour tirer une semi-remorque (sellette d''attelage). Pas de plateau propre.', v_formation, ARRAY['Tracteur'], 'Code de la route'),
    ('Semi-remorque', 'Remorque sans roues directrices avant, attelée par sellette à un tracteur. Charge utile élevée, polyvalente.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Porteur', 'Véhicule motorisé portant lui-même sa charge utile. Peut tirer une remorque indépendante (avec timon).', v_formation, ARRAY['Camion porteur'], 'Code de la route'),
    ('Bétaillère', 'Véhicule aménagé pour le transport d''animaux vivants. Conditions sanitaires, formation conducteur ASV (transport animal).', v_formation, ARRAY[]::text[], 'Réglementation'),

    -- ─── Permis et formations ──────────────────────────────────────
    ('Permis C', 'Permis pour véhicules de transport de marchandises de PTAC > 3,5 T (camion). 18 ans, FIMO marchandises pour exercer.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Permis CE', 'Permis camion + remorque > 750 kg (PTRA significatif). Prérequis : permis C valide.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Permis C1', 'Permis intermédiaire : véhicules de PTAC entre 3,5 T et 7,5 T. Délivrable dès 18 ans.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('FIMO marchandises', 'Formation Initiale Minimale Obligatoire — 140 heures préalables à l''exercice professionnel de conducteur de transport de marchandises > 3,5 T.', v_formation, ARRAY[]::text[], 'Décret n° 2007-1340'),
    ('FCO marchandises', '35 heures tous les 5 ans pour maintenir l''autorisation d''exercer.', v_formation, ARRAY[]::text[], 'Décret n° 2007-1340'),

    -- ─── Tachygraphe & temps ────────────────────────────────────────
    ('Tachygraphe intelligent V2', 'Tachygraphe numérique 2ème génération obligatoire depuis juin 2019 sur véhicules neufs > 3,5 T. Position GPS, communication à distance.', v_formation, ARRAY['Smart tachograph V2'], 'Règlement (UE) n° 165/2014'),
    ('Tachygraphe V2.2', 'Génération à partir de 2024. Anti-fraude renforcé. Rétrofit obligatoire en transport international d''ici 2025.', v_formation, ARRAY[]::text[], 'Mobility Package'),
    ('Carte conducteur', 'Carte personnelle pour le tachygraphe numérique. Obligatoire pour tout conducteur > 3,5 T. Validité 5 ans.', v_formation, ARRAY[]::text[], 'Règlement (UE) n° 165/2014'),
    ('Carte entreprise', 'Carte du transporteur pour télécharger les données tachygraphe et verrouiller les activités. Obligatoire.', v_formation, ARRAY[]::text[], 'Règlement (UE) n° 165/2014'),
    ('Détachement chauffeur', 'Mise à disposition temporaire d''un conducteur dans un autre État membre. Conditions strictes depuis le Mobility Package : salaire local, durée limite.', v_formation, ARRAY[]::text[], 'Directive (UE) 2020/1057'),
    ('Retour du véhicule', 'Obligation de retour du véhicule au pays d''établissement toutes les 8 semaines (Mobility Package). Lutte contre la délocalisation fictive.', v_formation, ARRAY[]::text[], 'Règlement (UE) 2020/1054'),

    -- ─── Cabotage ───────────────────────────────────────────────────
    ('Cabotage marchandises', 'Transport intérieur effectué par un transporteur étranger après un transport international vers le pays. 3 opérations en 7 jours maximum.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 1072/2009'),
    ('Période de carence cabotage', '4 jours d''interdiction de cabotage dans le même pays après les 3 opérations autorisées. Lutte contre le dumping.', v_formation, ARRAY[]::text[], 'Mobility Package'),

    -- ─── Infrastructure et péages ──────────────────────────────────
    ('Péage PL', 'Péage routier différencié pour les poids lourds (souvent classe 3 ou 4). Coût significatif dans le coût de revient kilométrique.', v_formation, ARRAY[]::text[], 'Pratique'),
    ('Eurovignette', 'Système européen de redevance d''usage des autoroutes pour les PL. Modulée selon classe Euro et CO2.', v_formation, ARRAY[]::text[], 'Directive (UE) 1999/62'),
    ('TIPP/TICPE', 'Taxe Intérieure sur la Consommation des Produits Énergétiques. Représente une part importante du prix du gazole. Remboursement partiel possible (12,4 c€/L à 13,4 c€/L).', v_formation, ARRAY['TIPP'], 'CGI'),
    ('Indice gazole CNR', 'Indice mensuel publié par le CNR reflétant l''évolution du coût du gazole. Base des clauses d''indexation tarifaire.', v_formation, ARRAY[]::text[], 'CNR'),

    -- ─── Documents de transport ────────────────────────────────────
    ('Lettre de voiture nationale', 'Document obligatoire accompagnant la marchandise en France. Mentions : expéditeur, destinataire, transporteur, marchandise, conditions.', v_formation, ARRAY['LDV'], 'Code de commerce'),
    ('CMR', 'Convention de Marchandises par Route. Document standard du transport international. Convention de Genève 1956.', v_formation, ARRAY[]::text[], 'Convention CMR'),
    ('Bordereau de suivi des déchets', 'Document obligatoire pour le transport de déchets dangereux. 3 exemplaires. Traçabilité complète.', v_formation, ARRAY['BSD'], 'Code de l''environnement'),
    ('Attestation de chargement', 'Document optionnel attestant la qualité du chargement, l''arrimage, l''absence de débordement. Recommandé.', v_formation, ARRAY[]::text[], 'Bonnes pratiques'),

    -- ─── ADR (matières dangereuses) ─────────────────────────────────
    ('ADR', 'Accord européen sur le transport international de marchandises Dangereuses par Route. Fondamental pour le transport > 3,5 T.', v_formation, ARRAY['Accord ADR'], 'Accord ADR'),
    ('Classes ADR', '9 classes de dangers : 1 explosifs, 2 gaz, 3 liquides inflammables, 4 solides inflammables, 5 oxydants, 6 toxiques, 7 radioactifs, 8 corrosifs, 9 divers.', v_formation, ARRAY[]::text[], 'ADR'),
    ('Numéro UN', 'Identifiant à 4 chiffres de chaque matière dangereuse. Affiché sur la plaque orange du véhicule.', v_formation, ARRAY['Numéro Onu'], 'ADR'),
    ('Conseiller à la sécurité (CSTMD)', 'Personne obligatoire dans les entreprises transportant ≥ 1 t/an de matières dangereuses. Formation et examen ADR conseiller.', v_formation, ARRAY['CSTMD'], 'Code des transports'),

    -- ─── Sécurité et contrôle ─────────────────────────────────────
    ('Limiteur de vitesse PL', 'Obligatoire sur tous les PL : 90 km/h marchandises, 100 km/h voyageurs.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Antiblocage ABS', 'Système de sécurité obligatoire sur tous les PL neufs. Évite le blocage des roues lors d''un freinage d''urgence.', v_formation, ARRAY['ABS'], 'Code de la route'),
    ('ESP poids lourd', 'Programme de stabilité électronique. Aide au contrôle dans les virages serrés ou conditions glissantes. Obligatoire sur PL neufs depuis 2014.', v_formation, ARRAY[]::text[], 'Règlement (UE)'),
    ('Visite technique PL', 'Contrôle technique obligatoire annuel pour les PL > 3,5 T. Plus fréquent que pour véhicule particulier (4 ans + 2 ans).', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Taxe à l''essieu', 'Taxe spéciale sur les véhicules de PTAC ≥ 12 T. Calcul selon nombre d''essieux et suspension. Recettes affectées à l''entretien des routes.', v_formation, ARRAY['TSVR'], 'CGI'),

    -- ─── Économie et gestion ────────────────────────────────────────
    ('Coût de revient kilométrique PL', 'CRK calculé pour PL : significativement plus élevé que pour VU (carburant, péages, salaires conducteurs +).', v_formation, ARRAY['CRK'], 'CNR'),
    ('Surcharge gazole', 'Supplément tarifaire indexé sur l''évolution mensuelle du gazole. Indispensable pour absorber les variations.', v_formation, ARRAY[]::text[], 'Pratique'),
    ('Surcoût détachement', 'Coût supplémentaire lié à l''application des règles de détachement (salaire local, frais). Impact tarifaire pour le transport international.', v_formation, ARRAY[]::text[], 'Mobility Package'),
    ('Charte CO2', 'Démarche volontaire ADEME de réduction des émissions CO2 dans le transport routier de marchandises. Engagements quantifiés.', v_formation, ARRAY['Objectif CO2'], 'ADEME'),
    ('Leasing PL', 'Location longue durée avec option d''achat. Très utilisé pour financer la flotte. Avantage : préservation de la trésorerie, déductibilité.', v_formation, ARRAY['Crédit-bail'], 'Finance'),
    ('Coût total de possession', 'TCO (Total Cost of Ownership) : achat + carburant + entretien + assurance + amortissement. À évaluer avant chaque investissement.', v_formation, ARRAY['TCO'], 'Gestion flotte')
  ON CONFLICT (lower(term)) DO NOTHING;

  RAISE NOTICE 'Glossaire Capa +3,5T : 50 termes insérés.';
END
$glo_capap$;
