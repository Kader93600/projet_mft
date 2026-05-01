-- =====================================================================
-- GLOSSAIRE — Capacité de transport léger (-3,5T)
-- 50 termes essentiels pour la préparation à l'examen.
-- Couvre : droit, commercial, réglementation, financier, salariés, sécurité.
--
-- Idempotent : ON CONFLICT (lower(term)) DO NOTHING.
-- Pré-requis : supabase/glossary_extensions.sql (ajoute formation_id).
-- =====================================================================

DO $glo_capa$
DECLARE
  v_formation uuid;
BEGIN
  SELECT id INTO v_formation
    FROM public.formations
   WHERE slug = 'capacite-3-5t';

  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable. '
      'Jouez le seed des formations d''abord.';
  END IF;

  -- Insertion par lots — chaque ligne : term, definition, synonymes, source
  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source)
  VALUES
    -- ─── Droit civil & commercial ─────────────────────────────────────
    ('Capacité juridique', 'Aptitude à être titulaire de droits et à les exercer. La capacité de jouissance s''acquiert à la naissance ; la capacité d''exercice à la majorité (18 ans en droit commun).', v_formation, ARRAY['Capacité de droit'], 'Code civil art. 16, 414'),
    ('SASU', 'Société par Actions Simplifiée Unipersonnelle. Forme juridique très utilisée par les coursiers indépendants : associé unique, statut d''assimilé-salarié pour le dirigeant, responsabilité limitée aux apports.', v_formation, ARRAY['Société par actions simplifiée unipersonnelle'], 'Code commerce art. L. 227-1'),
    ('EURL', 'Entreprise Unipersonnelle à Responsabilité Limitée. SARL avec un seul associé. Le gérant est TNS (Travailleur Non Salarié).', v_formation, ARRAY['SARL unipersonnelle'], 'Code commerce art. L. 223-1'),
    ('Cessation des paiements', 'État dans lequel une entreprise est dans l''impossibilité de faire face au passif exigible avec son actif disponible. Déclaration obligatoire au tribunal sous 45 jours.', v_formation, ARRAY['Dépôt de bilan'], 'Code commerce art. L. 631-1'),
    ('Procédure collective', 'Procédure judiciaire visant à traiter les difficultés d''une entreprise : sauvegarde (préventive), redressement (cessation déjà constatée mais redressement possible), liquidation (impossible).', v_formation, ARRAY['Sauvegarde','Redressement','Liquidation judiciaire'], 'Code commerce livre VI'),
    ('Lettre de change', 'Effet de commerce par lequel le tireur donne ordre au tiré de payer une somme à une date déterminée à un bénéficiaire. Trois acteurs minimum.', v_formation, ARRAY['Traite'], 'Code commerce art. L. 511-1'),
    ('Conjoint collaborateur', 'Statut du conjoint du chef d''entreprise qui participe régulièrement à l''activité sans rémunération et sans être associé. Affiliation obligatoire au régime social du chef.', v_formation, ARRAY[]::text[], 'Code commerce art. L. 121-4'),

    -- ─── Activité commerciale ─────────────────────────────────────────
    ('CGV', 'Conditions Générales de Vente. Document précisant les modalités de relations commerciales (prix, paiement, livraison, responsabilité). Communication obligatoire à tout professionnel qui en fait la demande.', v_formation, ARRAY['Conditions générales'], 'Code commerce art. L. 441-1'),
    ('Devis', 'Document précontractuel décrivant la prestation et son prix. Engageant pour le professionnel sauf mention de validité limitée. La signature du client vaut acceptation.', v_formation, ARRAY['Estimation'], 'Code consommation art. L. 111-1'),
    ('Indemnité forfaitaire de recouvrement', 'Somme de 40 € due de plein droit en cas de retard de paiement entre professionnels. S''ajoute aux pénalités de retard.', v_formation, ARRAY[]::text[], 'Code commerce art. L. 441-10'),
    ('Délai de paiement B2B', 'Maximum 60 jours date de facture OU 45 jours fin de mois. Délai supplétif (sans accord) : 30 jours fin de mois.', v_formation, ARRAY[]::text[], 'Code commerce art. L. 441-10'),
    ('Sous-traitance', 'Opération par laquelle un entrepreneur confie tout ou partie d''un contrat à un tiers. En transport, vérification obligatoire de l''inscription du sous-traitant au registre DREAL.', v_formation, ARRAY[]::text[], 'Loi n° 75-1334 du 31 décembre 1975'),
    ('Solidarité financière', 'Mécanisme par lequel le donneur d''ordre est tenu solidairement responsable des dettes sociales et fiscales de son sous-traitant non vérifié.', v_formation, ARRAY['Vigilance'], 'Code travail art. L. 8222-1'),
    ('Injonction de payer', 'Procédure judiciaire simplifiée pour recouvrer une créance certaine, liquide et exigible. Coût ~35 € de greffe, sans avocat obligatoire.', v_formation, ARRAY[]::text[], 'Code de procédure civile art. 1405'),
    ('RFA', 'Remise de Fin d''Année. Réduction commerciale calculée sur le chiffre d''affaires annuel d''un client. Doit être prévue contractuellement et figurer sur la facture.', v_formation, ARRAY['Remise de fin d''année'], 'Code commerce art. L. 441-3'),

    -- ─── Cadre réglementaire transport léger ─────────────────────────
    ('Capacité de transport léger', 'Attestation de capacité professionnelle obligatoire pour exercer le transport public routier de marchandises avec véhicules de PTAC ≤ 3,5 tonnes. Délivrée après examen ou équivalence.', v_formation, ARRAY['Capa -3,5T','Capacité légère'], 'Décret n° 99-752 du 30 août 1999'),
    ('PTAC', 'Poids Total Autorisé en Charge. Masse maximale d''un véhicule chargé fixée par le constructeur. Détermine la catégorie réglementaire du véhicule.', v_formation, ARRAY['PMA','Poids Total Autorisé en Charge'], 'Code de la route art. R. 312-2'),
    ('PTRA', 'Poids Total Roulant Autorisé. Masse maximale d''un véhicule attelé à sa remorque. Différent du PTAC du véhicule seul.', v_formation, ARRAY[]::text[], 'Code de la route art. R. 312-2'),
    ('Licence de transport intérieur', 'Document obligatoire pour exercer le transport routier de marchandises pour compte d''autrui en France. Délivrée par la DREAL aux entreprises titulaires de la capacité.', v_formation, ARRAY['Licence intérieure'], 'Décret n° 99-752'),
    ('DREAL', 'Direction Régionale de l''Environnement, de l''Aménagement et du Logement. Service déconcentré de l''État compétent pour le registre des transporteurs et la délivrance des licences.', v_formation, ARRAY['Direction Régionale Environnement'], 'Décret n° 2009-235'),
    ('Capacité financière', 'Garantie financière que doit justifier l''entreprise de transport pour son inscription : 1 800 € par véhicule ≤ 3,5T (premier véhicule) puis 900 € par véhicule supplémentaire.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 1071/2009'),
    ('Honorabilité professionnelle', 'Condition d''accès à la profession : absence de condamnations pénales graves liées à la gestion d''entreprise ou au transport. Vérifiée pour le dirigeant et le gestionnaire de transport.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 1071/2009 art. 6'),
    ('Contrat type général', 'Contrat applicable de plein droit en l''absence de convention écrite. Fixe les obligations minimales (délais, indemnités, responsabilités) entre transporteur et donneur d''ordre.', v_formation, ARRAY['CTG'], 'Décret n° 99-269'),
    ('Indemnisation pour perte ou avarie', 'Plafond légal en transport intérieur : 23 € HT par kilogramme manquant ou avarié, dans la limite de 750 € par colis.', v_formation, ARRAY[]::text[], 'Contrat type général'),

    -- ─── Activité financière ─────────────────────────────────────────
    ('Bilan', 'État comptable photographique du patrimoine de l''entreprise à une date donnée. Actif = ce que l''entreprise possède ; Passif = ce qu''elle doit (capitaux + dettes).', v_formation, ARRAY[]::text[], 'PCG'),
    ('Compte de résultat', 'État qui retrace l''activité sur une période (l''exercice) : produits (ventes) – charges = résultat (bénéfice ou perte).', v_formation, ARRAY[]::text[], 'PCG'),
    ('EBE', 'Excédent Brut d''Exploitation. Indicateur de performance : valeur ajoutée – impôts, taxes, frais de personnel. Mesure la rentabilité avant amortissements et frais financiers.', v_formation, ARRAY['Excédent brut d''exploitation'], 'PCG'),
    ('CAF', 'Capacité d''Autofinancement. Ressource interne dégagée par l''activité, disponible pour autofinancer les investissements ou rembourser les emprunts. ≈ Résultat + Amortissements.', v_formation, ARRAY['Capacité d''autofinancement'], 'PCG'),
    ('BFR', 'Besoin en Fonds de Roulement. Montant nécessaire pour financer le décalage entre encaissements clients et décaissements fournisseurs/salaires. BFR = Stocks + Créances – Dettes d''exploitation.', v_formation, ARRAY['Besoin en fonds de roulement'], 'Analyse financière'),
    ('Amortissement', 'Constatation comptable de la perte de valeur d''un bien immobilisé due à l''usure ou l''obsolescence. Étalé sur la durée d''utilisation. Charge déductible fiscalement.', v_formation, ARRAY[]::text[], 'PCG'),
    ('TVA', 'Taxe sur la Valeur Ajoutée. Impôt indirect sur la consommation, collecté par l''entreprise. Taux normal 20 %, intermédiaire 10 %, réduit 5,5 %, particulier 2,1 %.', v_formation, ARRAY['Taxe valeur ajoutée'], 'CGI art. 256'),
    ('Coût de revient kilométrique', 'Coût total au km parcouru. Somme des charges fixes (assurance, amortissement, salaires) et variables (carburant, péages, entretien) divisée par le nombre de km parcourus.', v_formation, ARRAY['CRK'], 'Comité National Routier'),
    ('Rentabilité', 'Capacité d''une entreprise à générer du profit. Rentabilité économique = résultat / actif total. Rentabilité financière = résultat / capitaux propres.', v_formation, ARRAY[]::text[], 'Analyse financière'),
    ('Trésorerie', 'Solde des liquidités disponibles (banque + caisse) à un instant T. Différence entre fonds de roulement et BFR.', v_formation, ARRAY[]::text[], 'Analyse financière'),

    -- ─── Salariés & droit du travail ─────────────────────────────────
    ('CDI', 'Contrat à Durée Indéterminée. Forme normale et générale du contrat de travail. Pas de terme fixé à l''avance. Rupture par démission, licenciement ou rupture conventionnelle.', v_formation, ARRAY['Contrat à durée indéterminée'], 'Code travail art. L. 1221-2'),
    ('CDD', 'Contrat à Durée Déterminée. Contrat d''exception, autorisé uniquement dans les cas listés par la loi (remplacement, accroissement, saisonnier). Durée limitée, renouvellements encadrés.', v_formation, ARRAY['Contrat à durée déterminée'], 'Code travail art. L. 1242-1'),
    ('Heures supplémentaires', 'Heures effectuées au-delà de la durée légale du travail (35h/semaine). Majoration légale : 25 % les 8 premières, 50 % au-delà. Contingent annuel défini par accord.', v_formation, ARRAY['HS'], 'Code travail art. L. 3121-28'),
    ('CCNTRAAT', 'Convention Collective Nationale des Transports Routiers et Activités Auxiliaires du Transport. Texte de référence pour les conditions de travail dans le secteur. IDCC 0016.', v_formation, ARRAY['Convention transport routier'], 'IDCC 0016'),
    ('Tachygraphe', 'Instrument embarqué obligatoire dans les véhicules > 3,5 T. Enregistre temps de conduite, repos, vitesse. Numérique depuis 2006, intelligent depuis 2019.', v_formation, ARRAY['Chrono-tachygraphe'], 'Règlement (UE) n° 165/2014'),
    ('Temps de conduite', 'Période pendant laquelle le conducteur conduit. Limite : 9h/jour (10h max 2 fois/semaine), 56h/semaine, 90h/2 semaines. Pause obligatoire après 4h30 de conduite continue.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 561/2006'),
    ('Repos quotidien', 'Période de repos d''au moins 11 heures consécutives par 24 heures. Réductible à 9h trois fois par semaine.', v_formation, ARRAY[]::text[], 'Règlement (CE) n° 561/2006'),

    -- ─── Sécurité & prévention ───────────────────────────────────────
    ('DUERP', 'Document Unique d''Évaluation des Risques Professionnels. Obligation pour tout employeur depuis 2001. Recense les risques, hiérarchise les actions de prévention. Mise à jour annuelle.', v_formation, ARRAY['Document unique'], 'Code travail art. R. 4121-1'),
    ('Permis à points', 'Permis de conduire affecté de 12 points (6 pendant la période probatoire). Retrait progressif selon la gravité de l''infraction. Reconstitution automatique sans nouvelle infraction.', v_formation, ARRAY[]::text[], 'Code de la route art. L. 223-1'),
    ('Alcoolémie', 'Taux d''alcool dans le sang. Limite : 0,5 g/L (sang) ou 0,25 mg/L (air expiré) pour le permis B. Limite abaissée à 0,2 g/L pour les permis probatoires et le transport en commun.', v_formation, ARRAY[]::text[], 'Code de la route art. R. 234-1'),
    ('FIMO', 'Formation Initiale Minimale Obligatoire. 140h pour les conducteurs de transport de marchandises (catégories C, CE, C1, C1E). Préalable à l''exercice de la profession.', v_formation, ARRAY[]::text[], 'Décret n° 2007-1340'),
    ('FCO', 'Formation Continue Obligatoire. 35h tous les 5 ans pour maintenir l''autorisation d''exercer. Obligatoire pour conducteurs de transport de marchandises et voyageurs.', v_formation, ARRAY['Formation continue obligatoire'], 'Décret n° 2007-1340'),
    ('CACES', 'Certificat d''Aptitude à la Conduite En Sécurité. Recommandation CNAM pour les engins de manutention (chariots élévateurs, nacelles, grues). Validité 5 ans.', v_formation, ARRAY[]::text[], 'Code travail art. R. 4323-55'),
    ('Matières dangereuses (ADR)', 'Accord européen relatif au transport international des marchandises Dangereuses par Route. Classification en 9 classes (explosifs, gaz, liquides inflammables, etc.). Formation conducteur obligatoire.', v_formation, ARRAY['ADR'], 'Accord ADR'),
    ('Aire de repos', 'Zone aménagée le long des routes pour la halte et le repos. Distincte des aires de service (avec carburant et restauration).', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Distance de sécurité', 'Espacement minimum entre deux véhicules en circulation. Calculée selon la vitesse : minimum 2 secondes en conditions normales, 4 secondes par temps de pluie ou poids lourd.', v_formation, ARRAY[]::text[], 'Code de la route art. R. 412-12')
  ON CONFLICT (lower(term)) DO NOTHING;

  RAISE NOTICE 'Glossaire Capa -3,5T : 50 termes insérés (ou existants).';
END
$glo_capa$;
