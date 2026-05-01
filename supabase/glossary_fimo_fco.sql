-- =====================================================================
-- GLOSSAIRE — FIMO / FCO (Formation Initiale et Continue Obligatoires
-- des conducteurs routiers, marchandises et voyageurs)
-- 50 termes essentiels.
-- =====================================================================

DO $glo_fimo$
DECLARE
  v_formation uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'fimo-fco';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation fimo-fco introuvable.';
  END IF;

  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source)
  VALUES
    -- ─── Cadre réglementaire ────────────────────────────────────────
    ('FIMO', 'Formation Initiale Minimale Obligatoire. 140 heures préalables à l''exercice de la profession de conducteur routier (marchandises ou voyageurs > 3,5 T).', v_formation, ARRAY['Formation Initiale Minimale Obligatoire'], 'Décret n° 2007-1340'),
    ('FCO', 'Formation Continue Obligatoire. 35 heures tous les 5 ans pour maintenir le droit d''exercer. Différente selon marchandises ou voyageurs.', v_formation, ARRAY['Formation Continue Obligatoire'], 'Décret n° 2007-1340'),
    ('CQC', 'Certificat de Qualification de Conducteur. Document délivré à l''issue de la FIMO ou FCO. Validité 5 ans, renouvelable par FCO.', v_formation, ARRAY[]::text[], 'Directive 2003/59/CE'),
    ('Carte de qualification', 'Carte plastique au format CB attestant la validité de la FIMO/FCO. Présentée lors des contrôles.', v_formation, ARRAY['CQC électronique'], 'Réglementation'),
    ('Directive 2003/59/CE', 'Texte européen fondateur instituant la qualification initiale et la formation continue obligatoires des conducteurs routiers.', v_formation, ARRAY[]::text[], 'UE'),
    ('Conducteur routier', 'Personne dont l''activité principale est de conduire un véhicule de transport de marchandises (PTAC > 3,5 T) ou de voyageurs (> 9 places). Soumise aux FIMO/FCO.', v_formation, ARRAY[]::text[], 'Code des transports'),

    -- ─── Permis de conduire ─────────────────────────────────────────
    ('Permis C', 'Permis pour véhicules de transport de marchandises de PTAC > 3,5 T (camion). Visite médicale à 18 ans, FIMO marchandises pour exercer.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Permis C1', 'Permis intermédiaire : véhicules de PTAC entre 3,5 T et 7,5 T. Délivrable dès 18 ans avec FIMO.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Permis CE', 'Permis camion + remorque > 750 kg (PTRA > 3,5 T). Couplé fréquemment à FIMO marchandises.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Permis D', 'Permis transport en commun > 9 places. FIMO voyageurs obligatoire pour exercer.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Permis D1', 'Permis transport en commun jusqu''à 16 + 1 places + remorque ≤ 750 kg.', v_formation, ARRAY[]::text[], 'Code de la route'),

    -- ─── Temps de conduite & repos ─────────────────────────────────
    ('Temps de conduite quotidien', 'Limite : 9 heures, pouvant être étendu à 10 heures deux fois par semaine maximum. Au-delà : sanctions.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 561/2006'),
    ('Temps de conduite hebdomadaire', 'Maximum 56 heures par semaine. Maximum 90 heures sur 2 semaines consécutives.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 561/2006'),
    ('Pause obligatoire', 'Après 4h30 de conduite continue, pause minimum de 45 minutes (fractionnable : 15 + 30 min).', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 561/2006'),
    ('Repos quotidien normal', '11 heures consécutives par 24 heures.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 561/2006'),
    ('Repos quotidien réduit', 'Réduction possible à 9 heures consécutives, maximum 3 fois par semaine.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 561/2006'),
    ('Repos quotidien fractionné', 'Possibilité de fractionner le repos en 2 périodes (3h + 9h minimum) la même journée.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 561/2006'),
    ('Repos hebdomadaire normal', '45 heures consécutives. Doit inclure le dimanche en règle générale.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 561/2006'),
    ('Repos hebdomadaire réduit', 'Réductible à 24 heures une semaine sur deux. Compensation à prendre dans les 3 semaines suivantes.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 561/2006'),

    -- ─── Tachygraphe ────────────────────────────────────────────────
    ('Tachygraphe analogique', 'Ancien tachygraphe à disques papier (avant 2006). Toujours toléré sur véhicules anciens. Lecture manuelle.', v_formation, ARRAY['Disque papier'], 'Réglement (CEE) n° 3821/85'),
    ('Tachygraphe numérique V1', 'Tachygraphe électronique obligatoire depuis mai 2006 sur véhicules neufs. Stockage sur carte conducteur + dans la masse.', v_formation, ARRAY[]::text[], 'Règlement (UE) n° 165/2014'),
    ('Tachygraphe intelligent V2', 'Génération obligatoire depuis juin 2019 sur véhicules neufs. Position GPS, communication à distance.', v_formation, ARRAY['Smart tachograph'], 'Règlement (UE) n° 165/2014'),
    ('Tachygraphe intelligent V2.2', 'Génération à compter de 2024 (rétrofit obligatoire pour transport international d''ici 2025-2026). Anti-fraude renforcé.', v_formation, ARRAY[]::text[], 'Mobility Package UE'),
    ('Carte conducteur', 'Carte personnelle, valable 5 ans. Délivrée par l''Imprimerie Nationale (~60 €). Insertion obligatoire à chaque prise de service.', v_formation, ARRAY[]::text[], 'Règlement (UE) n° 165/2014'),
    ('Carte entreprise', 'Carte du transporteur permettant la lecture des données tachygraphe et le verrouillage des activités. Obligatoire pour l''entreprise.', v_formation, ARRAY[]::text[], 'Règlement (UE) n° 165/2014'),
    ('Carte atelier', 'Carte des centres techniques agréés pour l''installation et la calibration des tachygraphes.', v_formation, ARRAY[]::text[], 'Règlement (UE) n° 165/2014'),
    ('Carte contrôleur', 'Carte des agents de contrôle (DREAL, gendarmerie) permettant la lecture des données.', v_formation, ARRAY[]::text[], 'Règlement (UE) n° 165/2014'),

    -- ─── Programme FIMO marchandises ────────────────────────────────
    ('Conduite rationnelle', 'Module FIMO sur l''éco-conduite : couple moteur, plage de régime optimale, anticipation. Économies de carburant 10-15 %.', v_formation, ARRAY['Éco-conduite'], 'Programme FIMO'),
    ('Réglementation routière', 'Module FIMO traitant des règles de circulation, signalisation, infractions, permis.', v_formation, ARRAY[]::text[], 'Programme FIMO'),
    ('Santé et sécurité', 'Module FIMO sur les risques professionnels, postures, manipulations, prévention.', v_formation, ARRAY[]::text[], 'Programme FIMO'),
    ('Service et logistique', 'Module FIMO marchandises sur les contrats de transport, lettres de voiture, responsabilités du conducteur.', v_formation, ARRAY[]::text[], 'Programme FIMO'),
    ('Documents de transport', 'Lettre de voiture, CMR, bon de livraison, certificat de chargement. Conduits dans le module FIMO.', v_formation, ARRAY[]::text[], 'Programme FIMO'),

    -- ─── Programme FIMO voyageurs ───────────────────────────────────
    ('Service à la clientèle', 'Module FIMO voyageurs sur l''accueil, la communication avec les passagers, la gestion des réclamations.', v_formation, ARRAY[]::text[], 'Programme FIMO voyageurs'),
    ('Confort des passagers', 'Conduite douce : freinages anticipés, virages mesurés, accélérations progressives. Critère de qualité du service voyageurs.', v_formation, ARRAY[]::text[], 'Pédagogie FIMO voyageurs'),
    ('Évacuation d''urgence', 'Procédures spécifiques aux autocars : marteau brise-vitre, issues de secours, comportement en cas d''incendie.', v_formation, ARRAY[]::text[], 'Programme FIMO voyageurs'),

    -- ─── ADR (matières dangereuses) ─────────────────────────────────
    ('ADR base', 'Formation conducteur ADR pour transporter des matières dangereuses en colis. 18 heures + examen. Validité 5 ans.', v_formation, ARRAY['ADR colis'], 'Accord ADR'),
    ('ADR citerne', 'Spécialisation ADR pour transport en citerne. Module supplémentaire de 13 heures + examen. Valable séparément.', v_formation, ARRAY[]::text[], 'Accord ADR'),
    ('ADR explosifs (classe 1)', 'Spécialisation ADR pour transport de matières explosives. Conditions d''accès renforcées.', v_formation, ARRAY[]::text[], 'Accord ADR'),
    ('ADR radioactifs (classe 7)', 'Spécialisation ADR pour transport de matières radioactives. Plus rare, certifications additionnelles.', v_formation, ARRAY[]::text[], 'Accord ADR'),
    ('Plaque ADR', 'Plaque orange réglementaire à apposer sur le véhicule transportant des matières dangereuses. Numéro UN + code danger.', v_formation, ARRAY[]::text[], 'ADR'),

    -- ─── Sécurité & prévention ──────────────────────────────────────
    ('Inspection avant départ', 'Vérifications obligatoires avant la prise de service : pneus, niveaux, éclairage, freinage, attelage. Documenté dans une fiche.', v_formation, ARRAY[]::text[], 'Bonnes pratiques'),
    ('Contrôle de la cargaison', 'Vérification de l''arrimage, de la conformité documentaire, du poids/volume. Responsabilité du conducteur.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Limiteur de vitesse PL', 'Limiteur obligatoire sur tous les véhicules > 3,5 T (90 km/h marchandises, 100 km/h voyageurs).', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Anti-démarrage par éthylotest', 'Dispositif obligatoire sur les autocars de transport scolaire et de tourisme. Le moteur ne démarre que sur taux conforme.', v_formation, ARRAY['EAD'], 'Décret n° 2009-911'),
    ('Aide à la conduite', 'Systèmes ADAS (régulateur, freinage automatique, alerte sortie de voie) de plus en plus présents sur les PL.', v_formation, ARRAY['ADAS'], 'Évolution technique'),

    -- ─── Sanctions et contrôles ─────────────────────────────────────
    ('Manquement FIMO/FCO', 'Conduire sans qualification valide : amende 4ème classe (135 €) + immobilisation du véhicule. Poursuite possible de l''entreprise.', v_formation, ARRAY[]::text[], 'Code des transports'),
    ('Sur-temps de conduite', 'Dépassement constaté du temps légal : amende selon gravité (de 135 à 1 500 €). Sanction du conducteur ET de l''entreprise.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 561/2006'),
    ('Falsification tachygraphe', 'Trafic des données tachygraphe : sanction pénale jusqu''à 1 an de prison + 30 000 €. Risque pour l''entreprise + perte de licence.', v_formation, ARRAY[]::text[], 'Code pénal'),
    ('Conduite sans carte', 'Conduire sans insérer la carte conducteur : amende 750 € + retrait de points. Tolérance pour les manœuvres < 100 m.', v_formation, ARRAY[]::text[], 'Règlement (UE) n° 165/2014'),
    ('Délit de fuite tachygraphe', 'Quitter un contrôle ou refuser de présenter les données : amende 6 000 € + suspension permis.', v_formation, ARRAY[]::text[], 'Code des transports')
  ON CONFLICT (lower(term)) DO NOTHING;

  RAISE NOTICE 'Glossaire FIMO/FCO : 50 termes insérés (ou existants).';
END
$glo_fimo$;
