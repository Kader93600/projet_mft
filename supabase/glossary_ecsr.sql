-- =====================================================================
-- GLOSSAIRE — ECSR (Enseignant de la Conduite et de la Sécurité Routière)
-- 50 termes essentiels.
-- =====================================================================

DO $glo_ecsr$
DECLARE
  v_formation uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'ecsr';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation ecsr introuvable.';
  END IF;

  INSERT INTO public.glossary_terms (term, definition_md, formation_id, synonyms, source)
  VALUES
    -- ─── Cadre & accès à la profession ──────────────────────────────
    ('Titre Pro ECSR', 'Titre professionnel de niveau 4 (Bac) délivré par le Ministère du Travail. Habilite à enseigner la conduite des catégories B, A et C/D selon les mentions complémentaires.', v_formation, ARRAY['Titre ECSR'], 'RNCP 36063'),
    ('BEPECASER', 'Brevet pour l''Exercice de la Profession d''Enseignant de la Conduite Automobile et de la Sécurité Routière. Ancien titre, remplacé par le Titre Pro ECSR depuis 2014. Toujours valable.', v_formation, ARRAY['Ancien titre'], 'Décret n° 87-997'),
    ('Autorisation d''enseigner', 'Document obligatoire pour exercer délivré par la préfecture. Renouvelée tous les 5 ans après visite médicale et stage.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Mention deux-roues (A)', 'Mention complémentaire au Titre Pro ECSR pour enseigner la conduite des deux-roues motorisés. Formation et examen spécifiques.', v_formation, ARRAY[]::text[], 'Arrêté du 16 octobre 2014'),
    ('Mention groupe lourd', 'Mention complémentaire pour enseigner les permis C, CE, D, DE. Préparation distincte au Titre Pro ECSR.', v_formation, ARRAY[]::text[], 'Réglementation'),
    ('Casier judiciaire', 'Bulletin n° 2 obligatoirement vierge pour exercer comme ECSR. Vérifié à l''embauche et au renouvellement de l''autorisation.', v_formation, ARRAY[]::text[], 'CPP'),

    -- ─── Pédagogie de la conduite ───────────────────────────────────
    ('REMC', 'Référentiel pour l''Éducation à une Mobilité Citoyenne. Référentiel pédagogique national qui structure l''enseignement de la conduite en 4 compétences.', v_formation, ARRAY[]::text[], 'Arrêté du 13 mai 2013'),
    ('Compétence 1 (REMC)', 'Maîtriser le maniement du véhicule dans un trafic faible ou nul. Premier niveau, permet de circuler en autonomie sur parkings et zones peu fréquentées.', v_formation, ARRAY[]::text[], 'REMC'),
    ('Compétence 2 (REMC)', 'Appréhender la route et circuler dans des conditions normales. Maîtrise de la circulation urbaine et péri-urbaine.', v_formation, ARRAY[]::text[], 'REMC'),
    ('Compétence 3 (REMC)', 'Circuler dans des conditions difficiles et partager la route avec les autres usagers. Conduite de nuit, autoroute, intempéries.', v_formation, ARRAY[]::text[], 'REMC'),
    ('Compétence 4 (REMC)', 'Pratiquer une conduite autonome, sûre et économique. Préparation à l''examen et conduite responsable.', v_formation, ARRAY[]::text[], 'REMC'),
    ('Livret d''apprentissage', 'Document de suivi pédagogique de l''élève. Trace les heures effectuées, les compétences acquises. Présenté à l''examen.', v_formation, ARRAY[]::text[], 'Réglementation'),
    ('Évaluation initiale', 'Évaluation préalable obligatoire (depuis 2014) pour déterminer le volume d''heures nécessaire à l''élève. Réalisée en simulateur ou en circulation.', v_formation, ARRAY[]::text[], 'Arrêté du 22 décembre 2009'),

    -- ─── Examens permis ─────────────────────────────────────────────
    ('ETG', 'Examen Théorique Général. Examen du Code de la route, 40 questions QCM, 35 bonnes réponses requises. Validité 5 ans (illimité après réussite épreuve pratique).', v_formation, ARRAY['Code de la route'], 'Arrêté du 12 mars 1980'),
    ('Épreuve pratique', 'Examen de conduite, 32 minutes. Évalué par un Inspecteur du Permis de Conduire (IPCSR). Note sur 20 minimum 20 points pour réussir.', v_formation, ARRAY[]::text[], 'Arrêté du 13 mai 2013'),
    ('IPCSR', 'Inspecteur du Permis de Conduire et de la Sécurité Routière. Fonctionnaire d''État qui fait passer les examens. Différent du formateur (ECSR).', v_formation, ARRAY['Inspecteur'], 'Décret n° 2014-1057'),
    ('CEPC', 'Certificat d''Examen du Permis de Conduire. Délivré à l''issue de l''examen pratique. Document à présenter pour la délivrance du permis.', v_formation, ARRAY[]::text[], 'Réglementation'),
    ('Période probatoire', 'Période de 3 ans (2 ans après conduite accompagnée) suivant l''obtention du permis B. 6 points seulement, restrictions vitesse et alcoolémie.', v_formation, ARRAY['Permis probatoire'], 'Code de la route art. L. 223-1'),
    ('Capital points', 'Permis affecté de 12 points (6 pendant probatoire). Retrait progressif selon la gravité des infractions. Reconstitution automatique sans nouvelle infraction.', v_formation, ARRAY[]::text[], 'Code de la route'),

    -- ─── Conduite accompagnée & supervisée ──────────────────────────
    ('AAC', 'Apprentissage Anticipé de la Conduite (conduite accompagnée). À partir de 15 ans, après formation initiale en auto-école. Période d''accompagnement min. 1 an + 3000 km.', v_formation, ARRAY['Conduite accompagnée'], 'Arrêté du 13 mai 2013'),
    ('CS', 'Conduite Supervisée. Formule alternative pour les + 18 ans après échec ou abandon. Période d''accompagnement min. 3 mois + 1000 km.', v_formation, ARRAY['Conduite supervisée'], 'Arrêté du 13 mai 2013'),
    ('Accompagnateur', 'Personne titulaire du permis depuis ≥ 5 ans qui accompagne l''élève en AAC ou CS. Formation préalable de 3 heures obligatoire.', v_formation, ARRAY[]::text[], 'Réglementation'),
    ('Disque A', 'Disque rouge avec un A blanc à apposer à l''arrière du véhicule pendant la conduite accompagnée et la période probatoire. Signalisation obligatoire.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Rendez-vous pédagogique', 'Bilan obligatoire entre élève, accompagnateur et formateur en AAC : 1 au début, 1 vers 1000 km, 1 avant l''examen.', v_formation, ARRAY['RVP'], 'Arrêté du 13 mai 2013'),

    -- ─── Sécurité routière ──────────────────────────────────────────
    ('Distance d''arrêt', 'Distance totale entre la perception du danger et l''arrêt complet du véhicule. = Distance de réaction + distance de freinage.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Temps de réaction', 'Délai entre la perception d''un danger et l''action sur les commandes. Estimé à 1 seconde en conditions normales, 1,5 s avec fatigue ou alcool.', v_formation, ARRAY[]::text[], 'Étude sécurité routière'),
    ('Distance de freinage', 'Distance parcourue entre le début du freinage et l''arrêt. Augmente avec le carré de la vitesse : doubler la vitesse = freinage 4x plus long.', v_formation, ARRAY[]::text[], 'Physique appliquée'),
    ('Zone d''accumulation', 'Zone géographique où se concentrent les accidents. Identifiée pour cibler la prévention. Concept clé en analyse accidentologique.', v_formation, ARRAY[]::text[], 'Statistiques sécurité'),
    ('Risque routier professionnel', 'Risque encouru par les salariés effectuant des trajets domicile-travail ou des déplacements professionnels. Principale cause de mortalité au travail.', v_formation, ARRAY[]::text[], 'INRS'),

    -- ─── Sanctions et infractions ──────────────────────────────────
    ('Délit routier', 'Infraction grave passible du tribunal correctionnel : conduite sans permis, sous emprise alcool > 0,8 g/L, délit de fuite, homicide involontaire.', v_formation, ARRAY[]::text[], 'Code de la route L. 234, L. 235'),
    ('Contravention 4ème classe', 'Infraction sanctionnée d''une amende forfaitaire 135 € (75 € minoré, 375 € majoré). Ex : feu rouge, téléphone tenu en main.', v_formation, ARRAY[]::text[], 'CPP'),
    ('Suspension administrative', 'Retrait temporaire du permis prononcé par le préfet (vs suspension judiciaire prononcée par le juge). Durée 6 mois maximum, renouvelable.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Annulation du permis', 'Sanction la plus lourde, prononcée par un juge. Le permis disparaît juridiquement. Repassage complet (théorique + pratique) après période d''interdiction.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Stage de récupération', 'Stage de sensibilisation à la sécurité routière (2 jours, ~ 200 €) qui permet de récupérer 4 points. 1 stage par an maximum.', v_formation, ARRAY['Stage points'], 'Code de la route art. L. 223-6'),

    -- ─── Pédagogie et techniques ────────────────────────────────────
    ('Approche par compétences', 'Méthode pédagogique du REMC : on enseigne des compétences globales (savoir-faire en situation) plutôt que des savoirs isolés.', v_formation, ARRAY['APC'], 'REMC'),
    ('Méthode active', 'Pédagogie où l''élève est acteur de son apprentissage. Découverte, manipulation, questionnement plutôt que cours magistral.', v_formation, ARRAY[]::text[], 'Sciences de l''éducation'),
    ('Démonstration commentée', 'Technique pédagogique : le formateur montre tout en expliquant. Particulièrement efficace pour les manœuvres complexes.', v_formation, ARRAY[]::text[], 'Pédagogie conduite'),
    ('Évaluation formative', 'Évaluation en cours d''apprentissage pour ajuster (vs évaluation sommative en fin de parcours pour valider). Au cœur de l''approche par compétences.', v_formation, ARRAY[]::text[], 'Sciences de l''éducation'),
    ('Auto-évaluation', 'Capacité de l''élève à juger son propre niveau. Compétence transversale clé de l''approche moderne.', v_formation, ARRAY[]::text[], 'REMC'),

    -- ─── Auto-école : gestion ─────────────────────────────────────
    ('Agrément auto-école', 'Autorisation préfectorale d''exploiter une auto-école. Conditions strictes : locaux, pédagogie, gestion. Durée 5 ans renouvelable.', v_formation, ARRAY[]::text[], 'Code de la route R. 213-2'),
    ('CFP', 'Conseil de Formation Pédagogique. Personne agréée chargée de la pédagogie au sein de l''auto-école. Obligatoire si ≥ 4 enseignants.', v_formation, ARRAY[]::text[], 'Réglementation'),
    ('Forfait permis', 'Tarif global incluant un nombre d''heures et l''accompagnement à l''examen. Encadré pour la transparence (loi du 27 octobre 2015).', v_formation, ARRAY[]::text[], 'Loi conduite'),
    ('Convention de formation', 'Contrat écrit obligatoire entre l''auto-école et l''élève : prestations, prix, modalités. Loi consommation.', v_formation, ARRAY[]::text[], 'Code consommation'),
    ('Délai de rétractation', 'Période de 14 jours pendant laquelle l''élève peut se rétracter sans frais (depuis 2014). Convention de formation à distance ou hors établissement.', v_formation, ARRAY[]::text[], 'Code consommation'),

    -- ─── Sécurité véhicule ──────────────────────────────────────────
    ('Double commande', 'Pédales (frein, embrayage) côté passager dans les véhicules d''auto-école. Permet à l''ECSR d''intervenir en sécurité. Obligatoire.', v_formation, ARRAY[]::text[], 'Code de la route'),
    ('Pictogramme auto-école', 'Signalisation lumineuse ou en panneau à apposer sur les véhicules d''auto-école pour informer les autres usagers.', v_formation, ARRAY['Triangle auto-école'], 'Réglementation'),
    ('Carte d''auto-école', 'Document à bord du véhicule attestant son rattachement à un établissement agréé. Vérifié lors des contrôles.', v_formation, ARRAY[]::text[], 'Réglementation'),
    ('CT auto-école', 'Contrôle Technique spécifique pour les véhicules d''auto-école. Plus fréquent que pour un VP standard.', v_formation, ARRAY[]::text[], 'Code de la route')
  ON CONFLICT (lower(term)) DO NOTHING;

  RAISE NOTICE 'Glossaire ECSR : 50 termes insérés (ou existants).';
END
$glo_ecsr$;
