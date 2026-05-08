-- =====================================================================
-- GLOSSAIRE GOTRM — refresh v4 livret CCP1 (mai 2026)
--
-- Stratégie demandée par le client :
--   ▸ AJOUTER les nouvelles notions du livret CCP1 GOTRM V2.
--   ▸ NE PAS SUPPRIMER les termes du glossaire existant qui ne sont pas
--     dans le livret (anciens termes restent disponibles).
--   ▸ REMPLACER la définition si un terme du livret existait déjà
--     (l'ancienne définition est écrasée par la version livret).
--
-- Implémentation : pour chaque terme du livret on fait DELETE WHERE
-- lower(term) IN (...) AND formation_id = v_formation_gotrm, puis INSERT.
-- Le DELETE est ciblé : il ne touche QUE les termes listés ci-dessous,
-- pour la formation GOTRM uniquement. Les autres glossaires (Capa,
-- ECSR, ERTV...) sont intacts.
--
-- Source pour chaque terme : "Livret CCP1 GOTRM V2 — Ch N" pour
-- traçabilité Qualiopi.
--
-- Mapping par chapitre du livret :
--   Ch 1  Environnement TRM (1.6)         12 termes
--   Ch 2  Véhicules & marchandises (2.8)  12 termes
--   Ch 3  Analyser une demande (3.6)       9 termes (dont 1 nouveau)
--   Ch 4  Coût de revient & tarif (4.9)    9 termes
--   Ch 5  Offre commerciale (5.7)          6 termes
--   Ch 6  Affecter les moyens (6.6)        9 termes
--   Ch 7  Documents de transport (7.6)    10 termes
--   Ch 8  Planifier les opérations (8.5)  10 termes
--   Ch 9  RSE conducteurs (9.8)            8 termes
--   Ch 10 Encadrer une équipe (10.6)       8 termes
--   Ch 11 Suivi & aléas (11.8)             8 termes
--   Ch 12 Facturation & litiges (12.5)    13 termes
--   Ch 13 KPI & analyse financière (13.6) 11 termes
--   Ch 14 Environnement & RSE (14.6)      10 termes
--   Ch 15 Transport international (15.7)   9 termes
--   Ch 16 Supports de charge (16.4)        9 termes
--   Ch 17 Anglais professionnel (17.4)    14 termes
--   ─────────────────────────────────────────────────────
--   TOTAL après dédoublonnage : ~155 termes uniques
--
-- Idempotent : ré-exécutable. La 2e exécution écrase la 1ʳᵉ.
-- =====================================================================

DO $glo_gotrm_v4$
DECLARE
  v_formation uuid;
  v_count int;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable.';
  END IF;

  -- ─── DELETE ciblé : uniquement les termes du livret ────────────────
  -- (les autres termes du glossaire — anciens GOTRM v2 ou termes
  -- d'autres formations — sont préservés)
  WITH deleted AS (
    DELETE FROM public.glossary_terms
     WHERE lower(term) IN (
       -- Ch 1
       'trm', 'chargeur', 'destinataire', 'donneur d''ordres', 'port payé',
       'port dû', 'commissionnaire de transport', 'contrat type', 'rse',
       'ccntr', 'tms', 'bourse de fret',
       -- Ch 2
       'ptac', 'ptra', 'pma', 'tare', 'charge utile', 'tautliner', 'atp',
       'adr', 'poids volumétrique', 'poids taxable', 'mètre linéaire',
       'arrimage',
       -- Ch 3
       'faisabilité', 'temps de service', 'équipage double', 'zfe',
       'crit''air', 'convoi exceptionnel', 'solution intermodale', 'norme euro',
       -- Ch 4
       'cnr', 'tk', 'th', 'tj', 'formule trinôme', 'règle du payant pour',
       'frais accessoires', 'pied de facture', 'marge',
       -- Ch 5
       'offre commerciale', 'confirmation d''affrètement', 'exonération tva',
       'valeur déclarée',
       -- Ch 6
       'affectation', 'affrètement ponctuel', 'fimo', 'fco', 'cqc',
       'carte conducteur', 'aménagement raisonnable', 'km à vide',
       -- Ch 7
       'lettre de voiture', 'cmr', 'ordre de mission', 'pochette de bord',
       'réserves', 'lrar', '3 jours francs', 'forclusion', 'avarie',
       'manquant',
       -- Ch 8
       'planning d''exploitation', 'tournée', 'séquencement', 'groupage',
       'dégroupage', 'créneau horaire', 'rechargement', 'lignier', 'livreur',
       -- Ch 9
       'amplitude', 'pause', 'repos journalier normal', 'repos hebdomadaire normal',
       'grand routier',
       -- Ch 10
       'plan de marche', 'conduite continue', 'pause obligatoire',
       'infraction rse', 'immobilisation', 'heures supplémentaires',
       'frais de route',
       -- Ch 11
       'aléa d''exploitation', 'eta', 'traçabilité', 'transbordement',
       'relivraison', 'retour à vide', 'sav',
       -- Ch 12
       'clôture de dossier', 'facture', 'avoir', 'litige transport',
       'avarie caractérisée', 'avarie occulte', 'plafond d''indemnisation',
       'déclaration de valeur', 'prescription commerciale',
       -- Ch 13
       'kpi', 'taux de ponctualité', 'seuil de rentabilité', 'point mort',
       'charges fixes', 'charges variables', 'mcv', 'ebe', 'sig', 'écart',
       'mesure corrective',
       -- Ch 14
       'kgco2e', 'ademe', 'facteur d''émission', 'éco-conduite',
       'rse entreprise', 'qvct', 'tipce', 'gnv',
       -- Ch 15
       'licence communautaire', 'cabotage', 'carnet tir', 'dau',
       'autorisation bilatérale', 'eurovignette', 'maut', 'incoterms', 'dts',
       -- Ch 16
       'support de charge', 'palette consignée', 'palette pool',
       'échange de palettes', 'bon de décharge', 'dette palettes', 'chep',
       'epal', 'consigne',
       -- Ch 17
       'carrier', 'consignee', 'consignor', 'shipper', 'freight', 'haulier',
       'pod', 'breakdown', 'claim', 'shortage', 'reefer', 'back load',
       'payload', 'waybill'
     )
    RETURNING 1
  )
  SELECT COUNT(*) INTO v_count FROM deleted;
  RAISE NOTICE '→ % termes existants supprimés (avant ré-insertion à jour).', v_count;

  -- ─── INSERT — Ch 1 — Environnement du transport routier de marchandises
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('TRM', 'Transport Routier de Marchandises. Mode dominant en France assurant plus de 85 % des échanges intérieurs. Secteur employant plus de 600 000 salariés dont 400 000 conducteurs.', v_formation, ARRAY['Transport routier']::text[], 'Livret CCP1 GOTRM — Ch 1'),
  ('Chargeur', 'Entreprise ou personne qui remet la marchandise au transporteur. C''est chez lui que se fait le chargement du véhicule. Synonyme : expéditeur.', v_formation, ARRAY['Expéditeur']::text[], 'Livret CCP1 GOTRM — Ch 1'),
  ('Destinataire', 'Entreprise ou personne qui doit recevoir la marchandise. C''est chez lui que se fait le déchargement.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 1'),
  ('Donneur d''ordres', 'Celui qui passe commande du transport et qui sera facturé. Peut être l''expéditeur, le destinataire ou un tiers.', v_formation, ARRAY['DO']::text[], 'Livret CCP1 GOTRM — Ch 1'),
  ('Port payé', 'Les frais de transport sont à la charge de l''expéditeur. Le destinataire ne paie rien à la livraison.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 1'),
  ('Port dû', 'Les frais de transport sont à la charge du destinataire. Réglés à la réception de la marchandise.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 1'),
  ('Commissionnaire de transport', 'Organise le transport pour le compte d''autrui sans posséder ses propres véhicules. Responsable comme s''il effectuait lui-même le transport.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 1'),
  ('Contrat type', 'Contrat s''appliquant automatiquement en l''absence de contrat particulier entre les parties. Plusieurs existent : général, messagerie, sous-traitance, déménagement, température dirigée.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 1'),
  ('RSE', 'Réglementation Sociale Européenne. Règles fixant les durées maximales de conduite et les temps de repos obligatoires (règlement CE 561/2006).', v_formation, ARRAY['Réglementation sociale européenne']::text[], 'Livret CCP1 GOTRM — Ch 1'),
  ('CCNTR', 'Convention Collective Nationale des Transports Routiers. Encadre les conditions de travail et de rémunération des salariés du secteur.', v_formation, ARRAY['Convention Collective Nationale des Transports Routiers']::text[], 'Livret CCP1 GOTRM — Ch 1'),
  ('TMS', 'Transport Management System — logiciel centralisant la gestion des opérations de transport (planning, ordres de mission, suivi, traçabilité).', v_formation, ARRAY['Transport Management System']::text[], 'Livret CCP1 GOTRM — Ch 1'),
  ('Bourse de fret', 'Plateforme numérique de mise en relation entre chargeurs ayant de la marchandise à expédier et transporteurs disposant de capacité disponible.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 1');

  -- ─── Ch 2 — Véhicules, carrosseries et marchandises
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('PTAC', 'Poids Total Autorisé en Charge — poids maximum légal d''un véhicule chargé, indiqué sur la carte grise.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 2'),
  ('PTRA', 'Poids Total Roulant Autorisé — pour un ensemble de véhicules (tracteur + semi-remorque).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 2'),
  ('PMA', 'Poids Maximum Autorisé — le plus petit entre le PTAC de la carte grise et le poids maximum autorisé par le Code de la route.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 2'),
  ('Tare', 'Poids du véhicule à vide, équipé et plein de carburant. Aussi noté PV (Poids à Vide).', v_formation, ARRAY['PV', 'Poids à vide']::text[], 'Livret CCP1 GOTRM — Ch 2'),
  ('Charge utile', 'Poids maximum de marchandise transportable = PMA – tare. Aussi noté CU.', v_formation, ARRAY['CU']::text[], 'Livret CCP1 GOTRM — Ch 2'),
  ('Tautliner', 'Semi-remorque à bâches latérales coulissantes sur toute la longueur. Permet le chargement par les côtés.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 2'),
  ('ATP', 'Accord sur les Transports Périssables — certification des véhicules frigorifiques. Classes principales : FRA (jusqu''à -20 °C), FRB (-10 °C), FRC (0 à +4 °C).', v_formation, ARRAY['Accord sur les Transports Périssables']::text[], 'Livret CCP1 GOTRM — Ch 2'),
  ('ADR', 'Accord pour le transport de marchandises Dangereuses par la Route. Réglementation européenne imposant véhicule homologué et conducteur certifié.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 2'),
  ('Poids volumétrique', 'Volume (m³) × coefficient volumétrique de l''entreprise (kg/m³). Coefficients courants : 250 kg/m³ messagerie, 330 kg/m³ lots partiels.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 2'),
  ('Poids taxable', 'Maximum des trois valeurs : poids réel, poids volumétrique, poids métrique. C''est sur ce poids que s''applique le tarif.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 2'),
  ('Mètre linéaire', 'Longueur de plancher occupée par un envoi dans le véhicule. Coefficient ml : 0,40 (palette EUR côte à côte) ou 0,50 (palette ISO).', v_formation, ARRAY['ml']::text[], 'Livret CCP1 GOTRM — Ch 2'),
  ('Arrimage', 'Positionnement et maintien sécurisé des charges dans le véhicule. Sangles obligatoires norme NF G 36-034 ; bâches et ridelles ne sont PAS des moyens d''arrimage.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 2');

  -- ─── Ch 3 — Analyser une demande et vérifier la faisabilité
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('Faisabilité', 'Capacité à réaliser une opération dans le respect de toutes les contraintes (techniques, réglementaires, RSE, capacité véhicule, créneaux client).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 3'),
  ('Temps de service', 'Conduite + autres tâches + disponibilité — exclut les pauses et les repos. Limité à 12 h max journalier (10 h si travail de nuit).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 3'),
  ('Équipage double', 'Deux conducteurs se relayant dans le même véhicule pour les longues distances. Permet d''aller au-delà des limites RSE individuelles.', v_formation, ARRAY['Double équipage']::text[], 'Livret CCP1 GOTRM — Ch 3'),
  ('ZFE', 'Zone à Faibles Émissions — zone urbaine restreignant la circulation des véhicules polluants selon leur vignette Crit''Air.', v_formation, ARRAY['Zone à Faibles Émissions']::text[], 'Livret CCP1 GOTRM — Ch 3'),
  ('Crit''Air', 'Vignette classant les véhicules selon leurs émissions polluantes (de 0 à 5). Détermine l''accès aux ZFE.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 3'),
  ('Convoi exceptionnel', 'Transport hors gabarit réglementaire (>16,50 m, >2,55 m, >4 m, >44 t). Autorisation préfectorale obligatoire + escorte selon la classe du convoi.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 3'),
  ('Solution intermodale', 'Transport combinant plusieurs modes : route + fer, route + fleuve, route + maritime. Réduit les km routiers et la pollution.', v_formation, ARRAY['Intermodal']::text[], 'Livret CCP1 GOTRM — Ch 3'),
  ('Norme Euro', 'Classification européenne des véhicules selon leurs émissions de polluants atmosphériques (Euro 1 à Euro 6/7). Conditionne l''accès aux ZFE et certaines taxes.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 3');

  -- ─── Ch 4 — Calculer le coût de revient et tarifer
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('CNR', 'Comité National Routier — publie les indices de coûts de référence du transport routier (coût au km, horaire, journalier, évolution gazole). Référence sectorielle.', v_formation, ARRAY['Comité National Routier']::text[], 'Livret CCP1 GOTRM — Ch 4'),
  ('TK', 'Terme Kilométrique — coût par kilomètre parcouru. Reflète les charges variables (carburant, pneus, entretien courant, péages).', v_formation, ARRAY['Terme kilométrique']::text[], 'Livret CCP1 GOTRM — Ch 4'),
  ('TH', 'Terme Horaire — coût par heure de service. Reflète les charges de conduite (salaires conducteurs, charges sociales, frais de route).', v_formation, ARRAY['Terme horaire']::text[], 'Livret CCP1 GOTRM — Ch 4'),
  ('TJ', 'Terme Journalier — coût par jour d''exploitation. Reflète les charges fixes (amortissement véhicule, assurances, taxes, frais financiers).', v_formation, ARRAY['Terme journalier']::text[], 'Livret CCP1 GOTRM — Ch 4'),
  ('Formule trinôme', 'Méthode complète de calcul du coût d''une mission : Coût = (TK × km) + (TH × heures) + (TJ × jours). La formule binôme simplifiée omet le TH.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 4'),
  ('Règle du payant pour', 'Règle de tarification : possibilité d''appliquer le tarif d''une tranche supérieure si celui-ci est plus avantageux que celui de la tranche réelle.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 4'),
  ('Frais accessoires', 'Prestations supplémentaires s''ajoutant au prix de transport de base : péages, valeur déclarée, contre-remboursement, attente, ADR, température dirigée…', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 4'),
  ('Pied de facture', 'Révision du prix de transport liée à l''évolution du prix du carburant. Articles L.3222-1 et L.3222-2 du Code des transports. Sanction 15 000 € si refus.', v_formation, ARRAY['Pied carburant']::text[], 'Livret CCP1 GOTRM — Ch 4'),
  ('Marge', 'Différence entre le prix de vente HT et le coût de revient de la prestation. Formule : Prix de vente = Coût × (1 + taux de marge).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 4');

  -- ─── Ch 5 — Rédiger une offre commerciale
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('Offre commerciale', 'Proposition technique et tarifaire formalisée par écrit qui engage l''entreprise vis-à-vis du client. Doit être précise, complète et professionnelle.', v_formation, ARRAY['Devis']::text[], 'Livret CCP1 GOTRM — Ch 5'),
  ('Confirmation d''affrètement', 'Document contractuel obligatoire liant le donneur d''ordres et le sous-traitant. Mentionne identité, opération, prix, véhicule et conducteur.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 5'),
  ('Exonération TVA', 'Absence de TVA sur les transports internationaux — règle de territorialité (CGI art. 262). Mention obligatoire sur la facture.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 5'),
  ('Valeur déclarée', 'Déclaration préalable de la valeur réelle de la marchandise par l''expéditeur. Modifie les limites d''indemnisation des contrats types.', v_formation, ARRAY['Déclaration de valeur']::text[], 'Livret CCP1 GOTRM — Ch 5');

  -- ─── Ch 6 — Choisir et affecter les moyens
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('Affectation', 'Attribution d''une opération à un conducteur, un véhicule ou un sous-traitant. Doit respecter critères matériels, humains et réglementaires.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 6'),
  ('Affrètement ponctuel', 'Recours à un sous-traitant pour une opération unique non contractualisée à long terme. Aussi appelé spot.', v_formation, ARRAY['Spot']::text[], 'Livret CCP1 GOTRM — Ch 6'),
  ('FIMO', 'Formation Initiale Minimale Obligatoire — 140 heures, obtenue une seule fois. Pré-requis à la conduite professionnelle marchandises >3,5 t.', v_formation, ARRAY['Formation Initiale Minimale Obligatoire']::text[], 'Livret CCP1 GOTRM — Ch 6'),
  ('FCO', 'Formation Continue Obligatoire — 35 heures tous les 5 ans. Financée par l''entreprise. Obligatoire pour maintenir la qualification professionnelle.', v_formation, ARRAY['Formation Continue Obligatoire']::text[], 'Livret CCP1 GOTRM — Ch 6'),
  ('CQC', 'Carte de Qualification Conducteur — délivrée après FIMO ou FCO. Renouvellement obligatoire tous les 5 ans. À présenter en cas de contrôle.', v_formation, ARRAY['Carte de Qualification Conducteur']::text[], 'Livret CCP1 GOTRM — Ch 6'),
  ('Carte conducteur', 'Carte à puce personnelle et nominative pour le tachygraphe numérique. Délivrée par l''Imprimerie Nationale. Validité 5 ans.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 6'),
  ('Aménagement raisonnable', 'Adaptation des conditions de travail aux besoins d''une personne handicapée. Obligation légale de l''employeur lors des affectations.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 6'),
  ('Km à vide', 'Kilomètres parcourus sans marchandise — indicateur de rentabilité à minimiser via groupage et fret retour. Cible < 15 %.', v_formation, ARRAY['Retour à vide']::text[], 'Livret CCP1 GOTRM — Ch 6');

  -- ─── Ch 7 — Documents de transport
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('Lettre de voiture', 'Document central du contrat de transport accompagnant la marchandise. Mentions obligatoires : parties, lieux/dates, marchandise, conditions commerciales. 3 exemplaires minimum.', v_formation, ARRAY['LV']::text[], 'Livret CCP1 GOTRM — Ch 7'),
  ('CMR', 'Convention relative au contrat de transport international de marchandises par route (Genève, 19 mai 1956). Plafond d''indemnisation 8,33 DTS/kg.', v_formation, ARRAY['Lettre de voiture internationale']::text[], 'Livret CCP1 GOTRM — Ch 7'),
  ('Ordre de mission', 'Document interne donnant au conducteur les instructions précises de sa mission : prise de service, chargement, livraison, contacts, instructions particulières.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 7'),
  ('Pochette de bord', 'Ensemble des documents remis au conducteur avant son départ : licence, carte grise, attestation assurance, permis, CQC, carte conducteur, lettre de voiture, documents ADR.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 7'),
  ('Réserves', 'Annotations écrites sur le document de transport signalant une anomalie. Doivent être précises, motivées et identifiables.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 7'),
  ('LRAR', 'Lettre Recommandée avec Accusé de Réception — mode de confirmation légale des réserves dans les délais réglementaires.', v_formation, ARRAY['Lettre recommandée AR']::text[], 'Livret CCP1 GOTRM — Ch 7'),
  ('3 jours francs', 'Délai légal de confirmation des réserves par LRAR (article L.133-3 du Code de commerce). Hors dimanches et jours fériés.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 7'),
  ('Forclusion', 'Perte du droit d''agir en justice faute d''avoir respecté les délais légaux (3 jours francs pour confirmer une réserve, par exemple).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 7'),
  ('Avarie', 'Dommage subi par la marchandise pendant le transport. Caractérisée si visible au déchargement, occulte si découverte au déballage.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 7'),
  ('Manquant', 'Colis présent sur le document de transport mais absent à la livraison. Doit être noté dans les réserves immédiates puis confirmé par LRAR.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 7');

  -- ─── Ch 8 — Planifier et optimiser les opérations
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('Planning d''exploitation', 'Outil récapitulant en temps réel toutes les affectations de véhicules et conducteurs : numéro de dossier, lieux, dates, statut.', v_formation, ARRAY['Planning']::text[], 'Livret CCP1 GOTRM — Ch 8'),
  ('Tournée', 'Ensemble de livraisons et/ou ramasses réalisées par un véhicule en une journée. Fréquente en messagerie et distribution régionale.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 8'),
  ('Séquencement', 'Détermination de l''ordre optimal des points de livraison dans une tournée (méthode du plus proche voisin, contraintes RSE, créneaux client).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 8'),
  ('Groupage', 'Regroupement d''envois de plusieurs expéditeurs sur un même véhicule à destination d''une même zone géographique. Optimise le taux de remplissage.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 8'),
  ('Dégroupage', 'Tri des envois à l''arrivée sur une plateforme pour la distribution locale par tournées dédiées. Opération inverse du groupage.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 8'),
  ('Créneau horaire', 'Plage de temps imposée par le client pour la livraison ou le chargement. Le respect conditionne souvent la qualité de service.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 8'),
  ('Rechargement', 'Chargement d''une nouvelle marchandise sur le trajet de retour du véhicule. Aussi appelé fret retour. Recherché via bourses de fret pour réduire les km à vide.', v_formation, ARRAY['Fret retour']::text[], 'Livret CCP1 GOTRM — Ch 8'),
  ('Lignier', 'Conducteur assurant les trajets entre plateformes de messagerie (longue distance, généralement de nuit).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 8'),
  ('Livreur', 'Conducteur assurant la distribution locale des envois en tournée (généralement de jour).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 8');

  -- ─── Ch 9 — Réglementation sociale européenne (RSE)
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('Amplitude', 'Durée totale entre l''heure de prise de service et l''heure de fin de service. Inclut les pauses et la conduite. À distinguer du temps de service.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 9'),
  ('Pause', 'Période obligatoire interrompant la conduite continue pendant laquelle le conducteur ne peut ni conduire ni effectuer d''autres tâches. 45 min après 4h30 de conduite continue.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 9'),
  ('Repos journalier normal', '11 heures consécutives entre deux journées de travail. Réductible à 9 h trois fois par semaine maximum, avec compensation.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 9'),
  ('Repos hebdomadaire normal', '45 heures consécutives par semaine calendaire. Interdit de prendre le repos hebdomadaire normal à bord du véhicule.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 9'),
  ('Grand routier', 'Conducteur prenant moins de 6 repos journaliers à domicile par mois. Durée légale hebdomadaire 43 h, maxi semaine isolée 56 h.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 9');

  -- ─── Ch 10 — Encadrer une équipe de conducteurs
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('Plan de marche', 'Feuille de route détaillée décomposant heure par heure une mission de transport. Vérifie AVANT le départ que la mission est réalisable dans le respect de la RSE.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 10'),
  ('Conduite continue', 'Durée de conduite sans interruption — limitée à 4h30. Doit être suivie d''une pause de 45 min (ou fractionnée en 15 + 30 min dans cet ordre).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 10'),
  ('Pause obligatoire', '45 minutes (ou 15 + 30 min dans le bon ordre) interrompant la conduite continue après 4h30. Ne compte pas dans le temps de service.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 10'),
  ('Infraction RSE', 'Non-respect des durées de conduite ou de repos imposées par le règlement CE 561/2006. Peut être contravention, délit ou délit grave selon la gravité.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 10'),
  ('Immobilisation', 'Mesure imposée lors d''un contrôle en cas d''infraction grave (dépassement >20 % conduite journalière, repos <6 h…). Le véhicule ne peut plus circuler tant que la situation n''est pas régularisée.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 10'),
  ('Heures supplémentaires', 'Heures travaillées au-delà de la durée légale — majorées à 25 % pour les 8 premières puis à 50 %. Obligation d''affichage et de paiement par l''employeur.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 10'),
  ('Frais de route', 'Indemnités compensant les repas et hébergements en déplacement professionnel. Non soumis aux cotisations sociales dans les limites URSSAF.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 10');

  -- ─── Ch 11 — Suivi d'exploitation et gestion des aléas
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('Aléa d''exploitation', 'Événement imprévu perturbant le déroulement normal d''une opération : panne, accident, embouteillage, marchandise non prête, intempéries, absence conducteur.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 11'),
  ('ETA', 'Estimated Time of Arrival — heure d''arrivée estimée. Information clé à transmettre au client en cas d''aléa pour préserver la relation commerciale.', v_formation, ARRAY['Heure d''arrivée estimée']::text[], 'Livret CCP1 GOTRM — Ch 11'),
  ('Traçabilité', 'Suivi chronologique et documenté de toutes les étapes d''une opération. Centralisé dans le TMS pour preuve en cas de litige.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 11'),
  ('Transbordement', 'Transfert d''une marchandise d''un véhicule vers un autre. Décision obligatoire en cas de panne véhicule frigorifique avec rupture de la chaîne du froid.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 11'),
  ('Relivraison', 'Nouvelle tentative de livraison après un premier échec (destinataire absent, refus, créneau dépassé). Souvent facturable.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 11'),
  ('Retour à vide', 'Retour d''un véhicule sans marchandise — perte sèche de rentabilité. À éviter via bourse de fret et politique de rechargement systématique.', v_formation, ARRAY['Vide retour']::text[], 'Livret CCP1 GOTRM — Ch 11'),
  ('SAV', 'Service Après-Vente — traitement des litiges et réclamations clients. Premier point de contact pour les avaries, manquants ou retards.', v_formation, ARRAY['Service Après-Vente']::text[], 'Livret CCP1 GOTRM — Ch 11');

  -- ─── Ch 12 — Facturation, litiges et clôture
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('Clôture de dossier', 'Validation finale après livraison : contrôle des documents signés, mise à jour du TMS, déclenchement de la facturation, archivage.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 12'),
  ('Facture', 'Document comptable réclamant le paiement d''une prestation réalisée. Mentions obligatoires CGI art. 289 + LME (pénalités, indemnité 40 €).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 12'),
  ('Avoir', 'Document correctif réduisant ou annulant une facture émise. Émis en cas d''erreur, de litige ou de geste commercial.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 12'),
  ('Litige transport', 'Désaccord entre client et transporteur sur l''exécution du contrat : avarie, manquant, retard, prix, conformité.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 12'),
  ('Avarie caractérisée', 'Dommage visible au déchargement ou lors de la manutention. Réserves immédiates obligatoires + confirmation LRAR sous 3 jours francs.', v_formation, ARRAY['Avarie apparente']::text[], 'Livret CCP1 GOTRM — Ch 12'),
  ('Avarie occulte', 'Dommage non visible à la livraison — découvert au déballage par le destinataire. Confirmation par LRAR dans les 3 jours francs suivant la découverte.', v_formation, ARRAY['Avarie cachée']::text[], 'Livret CCP1 GOTRM — Ch 12'),
  ('Plafond d''indemnisation', 'Limite maximale de remboursement prévue par les contrats types. Contrat type général : 33 €/kg pour <3 t (1 000 €/colis), 20 €/kg pour ≥3 t (3 200 €/tonne).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 12'),
  ('Déclaration de valeur', 'Déclaration préalable supprimant les plafonds légaux d''indemnisation. À recommander au client pour les marchandises de valeur élevée.', v_formation, ARRAY['Valeur déclarée']::text[], 'Livret CCP1 GOTRM — Ch 12'),
  ('Prescription commerciale', 'Délai de 5 ans au-delà duquel une action en justice n''est plus recevable. Distinct du délai de réclamation transport (1 an national, 1 an CMR).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 12');

  -- ─── Ch 13 — KPI et analyse financière
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('KPI', 'Key Performance Indicator — indicateur clé de performance. Mesure quantifiée d''un objectif (ponctualité, taux de remplissage, marge…).', v_formation, ARRAY['Indicateur clé de performance']::text[], 'Livret CCP1 GOTRM — Ch 13'),
  ('Taux de ponctualité', 'Pourcentage de livraisons réalisées dans le délai convenu. Cible ≥ 98 %. Mesure le respect des engagements client.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 13'),
  ('Seuil de rentabilité', 'Niveau de chiffre d''affaires à partir duquel toutes les charges sont couvertes. Formule : Charges fixes / Taux de MCV. Aussi appelé point mort.', v_formation, ARRAY['Point mort']::text[], 'Livret CCP1 GOTRM — Ch 13'),
  ('Point mort', 'Date de l''année à laquelle le seuil de rentabilité est atteint. Formule : (SR / CA annuel) × 365. Indicateur visuel de performance.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 13'),
  ('Charges fixes', 'Charges indépendantes du niveau d''activité : amortissement véhicule, assurances, taxes, loyer, frais de structure.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 13'),
  ('Charges variables', 'Charges évoluant proportionnellement à l''activité : carburant, pneus, péages, entretien courant.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 13'),
  ('MCV', 'Marge sur Coût Variable = CA – Charges Variables. Part du CA qui contribue à couvrir les charges fixes puis à dégager du bénéfice.', v_formation, ARRAY['Marge sur Coût Variable']::text[], 'Livret CCP1 GOTRM — Ch 13'),
  ('EBE', 'Excédent Brut d''Exploitation — principal indicateur de performance économique. Formule : VA – (Salaires + Charges sociales + Impôts).', v_formation, ARRAY['Excédent Brut d''Exploitation']::text[], 'Livret CCP1 GOTRM — Ch 13'),
  ('SIG', 'Soldes Intermédiaires de Gestion — décomposition analytique du résultat (CA, VA, EBE, Résultat d''exploitation, Résultat net).', v_formation, ARRAY['Soldes Intermédiaires de Gestion']::text[], 'Livret CCP1 GOTRM — Ch 13'),
  ('Écart', 'Différence entre un résultat réalisé et un objectif budgété. Doit être analysé pour identifier causes (km à vide, surconsommation, sous-tarification…).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 13'),
  ('Mesure corrective', 'Action mise en place pour réduire un écart constaté : formation éco-conduite, refacturation prestations annexes, révision grille tarifaire…', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 13');

  -- ─── Ch 14 — Obligations environnementales et RSE entreprise
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('kgCO2e', 'Kilogramme équivalent CO₂ — unité de mesure des gaz à effet de serre. Base de l''information CO₂ obligatoire (décret 2011-1336).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 14'),
  ('ADEME', 'Agence de la Transition Écologique — publie les facteurs d''émission officiels utilisés pour calculer l''empreinte carbone des transports.', v_formation, ARRAY['Agence de la Transition Écologique']::text[], 'Livret CCP1 GOTRM — Ch 14'),
  ('Facteur d''émission', 'Valeur en kgCO₂e/km utilisée pour calculer l''empreinte carbone d''un trajet. Exemples : fourgon <3,5 t = 0,200 ; ensemble articulé 44 t = 0,820.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 14'),
  ('Éco-conduite', 'Pratiques de conduite réduisant la consommation de carburant et les émissions : anticipation, vitesse constante, rapports élevés, pneus gonflés. Gain 5 à 10 %.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 14'),
  ('RSE entreprise', 'Responsabilité Sociétale des Entreprises — engagement environnemental et social de l''entreprise. À ne pas confondre avec la RSE règlementation sociale européenne.', v_formation, ARRAY['Responsabilité Sociétale des Entreprises']::text[], 'Livret CCP1 GOTRM — Ch 14'),
  ('QVCT', 'Qualité de Vie et des Conditions de Travail — démarche d''amélioration continue intégrant santé, organisation, équilibre vie pro/perso, dialogue social.', v_formation, ARRAY['Qualité de Vie et des Conditions de Travail']::text[], 'Livret CCP1 GOTRM — Ch 14'),
  ('TIPCE', 'Taxe Intérieure de Consommation sur les Produits Énergétiques — taxe sur le gazole. Partiellement remboursable aux transporteurs (CGI art. 265).', v_formation, ARRAY['Taxe Intérieure de Consommation sur les Produits Énergétiques']::text[], 'Livret CCP1 GOTRM — Ch 14'),
  ('GNV', 'Gaz Naturel Véhicule — carburant alternatif moins émetteur de CO₂ que le gazole. Disponible en bio-GNV pour des émissions encore réduites.', v_formation, ARRAY['Gaz Naturel Véhicule']::text[], 'Livret CCP1 GOTRM — Ch 14');

  -- ─── Ch 15 — Transport international opérationnel
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('Licence communautaire', 'Autorisation de transport dans toute l''Union Européenne — validité 10 ans. Copie certifiée à bord obligatoire pour chaque véhicule.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 15'),
  ('Cabotage', 'Transport national effectué par un transporteur étranger dans un pays tiers. Limité à 3 opérations en 7 jours suivant une livraison internationale (règlement UE 1072/2009).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 15'),
  ('Carnet TIR', 'Document douanier permettant le transit international sans contrôle systématique à chaque frontière. Garanti par une caisse de cautionnement.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 15'),
  ('DAU', 'Document Administratif Unique — déclaration douanière d''exportation hors UE. Obligatoire pour Suisse, Royaume-Uni, Maroc, Turquie…', v_formation, ARRAY['Document Administratif Unique']::text[], 'Livret CCP1 GOTRM — Ch 15'),
  ('Autorisation bilatérale', 'Accord entre deux pays autorisant un transporteur à effectuer des voyages entre eux (ex. Maroc, Turquie, certains pays hors UE).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 15'),
  ('Eurovignette', 'Taxe kilométrique applicable aux poids lourds dans plusieurs pays du nord de l''UE (Allemagne, Belgique, Pays-Bas, Luxembourg…).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 15'),
  ('Maut', 'Péage autoroutier allemand — calculé au km selon le poids du véhicule et la norme Euro. À facturer au client ou intégrer au TK.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 15'),
  ('Incoterms', 'Termes commerciaux internationaux définissant la répartition des risques et des coûts entre vendeur et acheteur. Principaux : EXW, FCA, DAP, DDP.', v_formation, ARRAY['International Commercial Terms']::text[], 'Livret CCP1 GOTRM — Ch 15'),
  ('DTS', 'Droits de Tirage Spéciaux — unité de compte du FMI utilisée pour les plafonds d''indemnisation CMR. 1 DTS ≈ 11 à 13 € en 2025.', v_formation, ARRAY['Droit de Tirage Spécial']::text[], 'Livret CCP1 GOTRM — Ch 15');

  -- ─── Ch 16 — Gestion des supports de charge
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('Support de charge', 'Dispositif permettant le groupage et la manutention des marchandises : palette EUR, palette ISO, roll cage, caisse palette.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 16'),
  ('Palette consignée', 'Palette appartenant à l''expéditeur, remise contre restitution. Échange 1 pour 1 à la livraison ou bon de décharge si impossible.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 16'),
  ('Palette pool', 'Palette appartenant à un prestataire spécialisé (CHEP, LPR…) louée par les utilisateurs. Restitution dans n''importe quel dépôt du réseau.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 16'),
  ('Échange de palettes', 'Remise de palettes pleines contre récupération de palettes vides à la livraison. Évite le rachat et préserve la trésorerie.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 16'),
  ('Bon de décharge', 'Document signé attestant l''impossibilité d''échange immédiat de palettes à la livraison. Génère une dette palette à régulariser.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 16'),
  ('Dette palettes', 'Solde net des palettes : positif = le client doit des palettes à l''entreprise. Négatif = l''entreprise doit des palettes au client (avoir à régulariser).', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 16'),
  ('CHEP', 'Prestataire de palettes pool bleues — réseau mondial. Les palettes sont louées et restituées dans n''importe quel dépôt CHEP.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 16'),
  ('EPAL', 'European Pallet Association — certification qualité des palettes EUR (1 200 × 800 mm). Marquage obligatoire sur les palettes consignées.', v_formation, ARRAY['European Pallet Association']::text[], 'Livret CCP1 GOTRM — Ch 16'),
  ('Consigne', 'Valeur monétaire d''un support de charge, récupérée à la restitution. Indicative : 8 à 12 € pour palette EUR, 25 à 50 € pour roll cage.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 16');

  -- ─── Ch 17 — Anglais professionnel en transport (B1 CECRL)
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source) VALUES
  ('Carrier', 'Transporteur (anglais). Phrase type : "The carrier is liable for the goods." (Le transporteur est responsable des marchandises.)', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 17'),
  ('Consignee', 'Destinataire (anglais). Phrase type : "The consignee refused the delivery." (Le destinataire a refusé la livraison.)', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 17'),
  ('Consignor', 'Expéditeur (anglais). Synonyme : Shipper. Phrase type : "The shipper is responsible for loading."', v_formation, ARRAY['Shipper']::text[], 'Livret CCP1 GOTRM — Ch 17'),
  ('Shipper', 'Expéditeur (anglais). Synonyme : Consignor. Utilisé sur le CMR international.', v_formation, ARRAY['Consignor']::text[], 'Livret CCP1 GOTRM — Ch 17'),
  ('Freight', 'Fret / marchandise / prix de transport (anglais). Multi-sens selon le contexte commercial ou logistique.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 17'),
  ('Haulier', 'Transporteur routier (anglais britannique). Équivalent américain : trucker.', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 17'),
  ('POD', 'Proof of Delivery — bon de livraison signé par le destinataire. Phrase type : "Send the signed POD back to us."', v_formation, ARRAY['Proof of Delivery']::text[], 'Livret CCP1 GOTRM — Ch 17'),
  ('Breakdown', 'Panne mécanique (anglais). Phrase type : "The vehicle has broken down on the motorway."', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 17'),
  ('Claim', 'Réclamation / dossier litige (anglais). Phrase type : "We will investigate the claim within 48 hours."', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 17'),
  ('Shortage', 'Manquant (anglais). Phrase type : "Two pallets are missing." (Deux palettes manquent.)', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 17'),
  ('Reefer', 'Véhicule frigorifique (anglais — argot du métier). Phrase type : "We need a reefer for this shipment."', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 17'),
  ('Back load', 'Fret de retour (anglais). Phrase type : "Can you find a back load from Bordeaux?"', v_formation, ARRAY['Return load']::text[], 'Livret CCP1 GOTRM — Ch 17'),
  ('Payload', 'Charge utile (anglais). Phrase type : "The maximum payload is 24,000 kg."', v_formation, ARRAY[]::text[], 'Livret CCP1 GOTRM — Ch 17'),
  ('Waybill', 'Lettre de voiture (anglais). CMR consignment note pour le transport international.', v_formation, ARRAY['CMR consignment note']::text[], 'Livret CCP1 GOTRM — Ch 17');

  -- ─── Récap final
  SELECT COUNT(*) INTO v_count
    FROM public.glossary_terms
   WHERE formation_id = v_formation;

  RAISE NOTICE '╔═════════════════════════════════════════════════════════════';
  RAISE NOTICE '║ ✓ GLOSSAIRE GOTRM v4 RAFRAÎCHI (livret CCP1)';
  RAISE NOTICE '╠═════════════════════════════════════════════════════════════';
  RAISE NOTICE '║ Termes GOTRM en BDD après refresh : %', v_count;
  RAISE NOTICE '║ Source pour les nouveaux : "Livret CCP1 GOTRM V2 — Ch N"';
  RAISE NOTICE '║ Anciens termes GOTRM (non listés) : préservés.';
  RAISE NOTICE '║ Glossaires Capa / ECSR / ERTV / autres : intacts.';
  RAISE NOTICE '╚═════════════════════════════════════════════════════════════';

END $glo_gotrm_v4$;
