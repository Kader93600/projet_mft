-- =====================================================================
-- GLOSSAIRE — Commissionnaire de transport
-- 50 termes essentiels.
-- =====================================================================

DO $glo_com$
DECLARE
  v_formation uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'commissionnaire';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation commissionnaire introuvable.';
  END IF;

  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source)
  VALUES
    -- ─── Définition de la profession ────────────────────────────────
    ('Commissionnaire de transport', 'Intermédiaire qui organise un transport de marchandises en son nom propre pour le compte d''un commettant. Responsable de l''exécution complète vis-à-vis du commettant.', v_formation, ARRAY[]::text[], 'Code commerce L. 132-1'),
    ('Commettant', 'Personne (entreprise) qui confie au commissionnaire l''organisation d''un transport. Donneur d''ordre.', v_formation, ARRAY[]::text[], 'Code commerce'),
    ('Transporteur effectif', 'Entreprise qui exécute physiquement le transport. Peut être un sous-traitant du commissionnaire ou son propre service.', v_formation, ARRAY[]::text[], 'Code commerce'),
    ('Liberté de choix', 'Droit du commissionnaire de choisir librement le transporteur effectif et le mode de transport (route, fer, mer, air, multimodal).', v_formation, ARRAY[]::text[], 'Code commerce'),
    ('Garant', 'Le commissionnaire est garant des avaries, pertes et retards survenus pendant le transport. Distinction clé avec le simple intermédiaire.', v_formation, ARRAY[]::text[], 'Code commerce L. 132-4'),
    ('Mandat vs commission', 'Différence essentielle : le mandataire agit AU NOM du commettant, le commissionnaire agit EN SON NOM. Conséquences : responsabilité, contrats.', v_formation, ARRAY[]::text[], 'Code civil et commerce'),

    -- ─── Cadre réglementaire ────────────────────────────────────────
    ('Inscription au registre', 'Obligation d''inscription au registre des commissionnaires de transport tenu par la DREAL. Conditions : capacité professionnelle, financière, honorabilité.', v_formation, ARRAY[]::text[], 'Décret n° 90-200'),
    ('Capacité professionnelle commissionnaire', 'Attestation obligatoire pour le dirigeant. Examen ou équivalence (3 ans expérience). Distincte de la capacité de transport.', v_formation, ARRAY[]::text[], 'Décret n° 90-200'),
    ('Capacité financière commissionnaire', '100 000 € minimum, attestée par fonds propres au bilan ou caution bancaire. Plus élevée qu''en transport routier classique.', v_formation, ARRAY[]::text[], 'Décret n° 90-200'),
    ('Licence commissionnaire', 'Document délivré par la DREAL après inscription. Prouve l''autorisation d''exercer. À présenter aux commettants.', v_formation, ARRAY[]::text[], 'Code des transports'),

    -- ─── Contrats commissionnaire ───────────────────────────────────
    ('Contrat type commission', 'Contrat type général de la commission de transport (décret n° 99-269). Applicable de plein droit en l''absence de convention spécifique.', v_formation, ARRAY[]::text[], 'Décret n° 99-269'),
    ('Lettre de voiture', 'Document accompagnant la marchandise. Le commissionnaire émet souvent SA propre lettre de voiture vis-à-vis du client (couvre la responsabilité).', v_formation, ARRAY[]::text[], 'Code commerce'),
    ('CMR', 'Convention de Marchandises par Route. Utilisée en transport international. Le commissionnaire est responsable de son émission correcte.', v_formation, ARRAY[]::text[], 'Convention CMR'),
    ('Convention écrite', 'Contrat spécifique négocié entre commissionnaire et commettant. Permet de fixer prix, délais, responsabilités au-delà des minima du contrat type.', v_formation, ARRAY[]::text[], 'Pratique commerciale'),
    ('Clause de réserve', 'Disposition contractuelle limitant la responsabilité du commissionnaire dans certains cas (force majeure, vice propre de la marchandise).', v_formation, ARRAY[]::text[], 'Code commerce'),

    -- ─── Modes de transport ─────────────────────────────────────────
    ('Multimodal', 'Combinaison de plusieurs modes de transport (route + fer, route + mer, etc.) pour une même expédition. Compétence clé du commissionnaire.', v_formation, ARRAY['Intermodal'], 'Vocabulaire transport'),
    ('Transport routier longue distance', 'Mode privilégié en France. Le commissionnaire négocie traction, retours à vide, optimisation des tournées.', v_formation, ARRAY[]::text[], 'Pratique'),
    ('Transport ferroviaire (combiné rail-route)', 'Acheminement par train de wagons ou de remorques. Adapté aux longues distances européennes. Commissionnaire spécialisé.', v_formation, ARRAY['Combiné'], 'Pratique'),
    ('Transport maritime (conteneurs)', 'Transport intercontinental par mer en conteneurs. Le commissionnaire gère réservations, dédouanement, livraison finale.', v_formation, ARRAY['Container shipping'], 'Pratique'),
    ('Transport aérien', 'Mode rapide pour fret urgent ou de valeur. Coûteux. Le commissionnaire optimise palettisation et déclaration douanière.', v_formation, ARRAY[]::text[], 'Pratique'),
    ('Cabotage maritime', 'Transport entre 2 ports de la même façade ou d''un même État. Alternative écologique à la route.', v_formation, ARRAY[]::text[], 'Code des transports'),

    -- ─── International & douanes ────────────────────────────────────
    ('Incoterms', 'International Commercial Terms (CCI). 11 règles standardisées définissant qui (vendeur/acheteur) paie quoi et porte quel risque dans une expédition internationale.', v_formation, ARRAY[]::text[], 'CCI 2020'),
    ('EXW', 'Ex Works. Vendeur livre dans ses locaux ; acheteur prend en charge tout le reste. Minimum d''obligations vendeur.', v_formation, ARRAY['Ex Works'], 'Incoterms 2020'),
    ('FOB', 'Free On Board. Vendeur livre la marchandise à bord du navire ; transfert risque au passage du bastingage.', v_formation, ARRAY[]::text[], 'Incoterms 2020'),
    ('CIF', 'Cost, Insurance and Freight. Vendeur paie transport et assurance jusqu''au port de destination ; risque transféré à l''embarquement.', v_formation, ARRAY[]::text[], 'Incoterms 2020'),
    ('DAP', 'Delivered At Place. Vendeur livre à destination convenue, hors déchargement. Très utilisé en routier.', v_formation, ARRAY[]::text[], 'Incoterms 2020'),
    ('DDP', 'Delivered Duty Paid. Maximum d''obligations vendeur : livraison à destination + dédouanement payé. Acheteur ne paie rien.', v_formation, ARRAY[]::text[], 'Incoterms 2020'),
    ('Carnet TIR', 'Document douanier international permettant le transit sous scellés sans contrôles intermédiaires. Garantie financière par cautionnement de la profession.', v_formation, ARRAY[]::text[], 'Convention TIR'),
    ('DAU', 'Document Administratif Unique. Déclaration douanière européenne. Transition vers DELTA-T (électronique).', v_formation, ARRAY[]::text[], 'Code des douanes'),
    ('Représentant douane direct', 'Auxiliaire qui agit au nom et pour le compte du déclarant (l''importateur). Responsabilité limitée.', v_formation, ARRAY['RDE'], 'Code des douanes'),
    ('Représentant douane indirect', 'Auxiliaire qui déclare en son nom propre pour le compte d''un commettant. Solidairement responsable de la dette douanière.', v_formation, ARRAY[]::text[], 'Code des douanes'),

    -- ─── Tarification & rémunération ───────────────────────────────
    ('Marge de commission', 'Différence entre le prix de vente facturé au commettant et le coût d''achat du transport. Rémunération du commissionnaire.', v_formation, ARRAY[]::text[], 'Pratique'),
    ('Forfait', 'Tarif fixe pour une expédition complète. Simple à comprendre, risque de marge variable selon coûts réels.', v_formation, ARRAY[]::text[], 'Pratique'),
    ('Cost+', 'Tarification basée sur le coût réel + marge négociée (ex : +12 %). Transparence pour le commettant, sécurité pour le commissionnaire.', v_formation, ARRAY['Cost-plus'], 'Pratique'),
    ('Surcharge gazole', 'Supplément tarifaire indexé sur l''évolution du prix du gazole (indice CNR). Permet d''absorber les variations.', v_formation, ARRAY['BAF','Bunker Adjustment Factor'], 'Pratique'),
    ('Surcharge devise', 'Supplément en cas de fluctuation des taux de change pour les expéditions internationales facturées en devise étrangère.', v_formation, ARRAY['CAF','Currency Adjustment Factor'], 'Pratique'),

    -- ─── Responsabilité ────────────────────────────────────────────
    ('Responsabilité présumée', 'Le commissionnaire est responsable de plein droit des avaries, pertes et retards. Inversion de la charge de la preuve : il doit prouver la cause étrangère.', v_formation, ARRAY[]::text[], 'Code commerce'),
    ('Cause étrangère', 'Événement libérant le commissionnaire de sa responsabilité : force majeure, fait du commettant, vice propre de la marchandise.', v_formation, ARRAY[]::text[], 'Code commerce'),
    ('Indemnisation plafonnée', 'En transport international (CMR) : 8,33 DTS/kg ≈ 9,5 €/kg. En national : 23 €/kg ou 750 €/colis (contrat type général).', v_formation, ARRAY[]::text[], 'CMR / CTG'),
    ('Assurance ad valorem', 'Assurance complémentaire couvrant la valeur réelle déclarée des marchandises. Au-delà des plafonds CMR/CTG. Prime ~0,5 % de la valeur.', v_formation, ARRAY[]::text[], 'Assurance transport'),

    -- ─── Logistique & supply chain ─────────────────────────────────
    ('Supply chain management', 'Gestion globale de la chaîne logistique de l''approvisionnement à la livraison finale. Compétence centrale du commissionnaire moderne.', v_formation, ARRAY['SCM'], 'Logistique'),
    ('Cross-docking', 'Technique d''entreposage : la marchandise transite quelques heures (pas de stockage long). Optimise le délai et les coûts.', v_formation, ARRAY[]::text[], 'Logistique'),
    ('Hub & spoke', 'Architecture logistique : une plate-forme centrale (hub) et des points de distribution (spokes). Modèle d''Amazon, FedEx, etc.', v_formation, ARRAY[]::text[], 'Logistique'),
    ('Just-in-time', 'Livraison au moment précis du besoin, sans stockage. Réduit les coûts mais exige une chaîne logistique impeccable.', v_formation, ARRAY['JIT'], 'Logistique'),
    ('EDI', 'Échange de Données Informatisé. Communication automatisée entre systèmes (commande, facture, suivi). Standard du commerce B2B moderne.', v_formation, ARRAY['Electronic Data Interchange'], 'Vocabulaire'),
    ('TMS', 'Transport Management System. Logiciel de gestion des opérations de transport : commandes, planification, suivi, facturation.', v_formation, ARRAY['Transport Management System'], 'Logistique'),

    -- ─── Économie & gestion ─────────────────────────────────────────
    ('Volume affrété', 'Volume total de transports sous-traités par le commissionnaire sur une période donnée. Indicateur d''activité majeur.', v_formation, ARRAY[]::text[], 'KPI'),
    ('Taux de marge', 'Marge brute / chiffre d''affaires. En commission de transport : typiquement 8-15 % selon le segment et la valeur ajoutée.', v_formation, ARRAY[]::text[], 'KPI'),
    ('DSO', 'Days Sales Outstanding. Délai moyen de paiement des clients. Crucial pour la trésorerie. En commission : 45-60 jours fréquents.', v_formation, ARRAY[]::text[], 'Finance'),
    ('Affacturage', 'Vente des créances clients à un factor (banque) contre paiement immédiat (-3 à -6 %). Améliore la trésorerie. Pratique courante.', v_formation, ARRAY['Factoring'], 'Finance'),
    ('Garantie de paiement', 'Cautionnement obligatoire de 50 000 € minimum couvrant les sommes encaissées pour le compte des donneurs d''ordre.', v_formation, ARRAY[]::text[], 'Code des transports')
  ON CONFLICT (lower(term)) DO NOTHING;

  RAISE NOTICE 'Glossaire Commissionnaire : 50 termes insérés.';
END
$glo_com$;
