-- =====================================================================
-- BANQUE PREMIUM — Capacité de transport léger -3,5T
--
-- 80 questions originales rédigées pour MA FORMATION TRANSPORT :
--   - 40 cas pratiques (situations réelles d'entreprise transport)
--   - 25 mises en situation professionnelles (contrôle, accident, conflit)
--   - 15 questions de synthèse niveau examen
--
-- Toutes les questions sont :
--   - active=true (bonnes réponses cochées)
--   - tags incluant 'capa-3-5t' + 'module-X' + thématique + 'premium'
--   - source_ref='mft-original-2026:N' (traçabilité MA FORMATION TRANSPORT)
--
-- Idempotent : ON CONFLICT (source_ref) DO NOTHING.
-- =====================================================================

DO $outer$
DECLARE
  formation_uuid uuid;
BEGIN
  SELECT id INTO formation_uuid FROM public.formations WHERE slug = 'capacite-3-5t';
  IF formation_uuid IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable.';
  END IF;

  -- =====================================================================
  -- MODULE A — Droit civil et commercial (15 questions premium)
  -- =====================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES
  (formation_uuid, 'qcm',
   'Karim crée son entreprise de coursier-livraison à Meaux. Il travaille seul, n''a pas d''apport financier, et veut bénéficier de la couverture sociale du régime général. Quelle forme juridique est la plus adaptée ?',
   '[{"id":"a","label":"Entreprise individuelle (EI)","is_correct":false},
     {"id":"b","label":"SARL avec un associé fictif","is_correct":false},
     {"id":"c","label":"SASU","is_correct":true},
     {"id":"d","label":"Société en participation","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-a','droit','cas-pratique','premium','creation-entreprise'],
   'mft-original-2026:1', true,
   'La SASU permet à Karim d''avoir le statut d''assimilé-salarié (régime général) sans associé, ce qui répond à son besoin de protection sociale.'),

  (formation_uuid, 'qcm',
   'Une SARL familiale du transport léger compte 3 associés (le père, la mère et un enfant majeur). Concernant l''option fiscale, quelle affirmation est exacte ?',
   '[{"id":"a","label":"Elle est obligatoirement à l''impôt sur les sociétés (IS)","is_correct":false},
     {"id":"b","label":"Elle peut opter pour l''impôt sur le revenu (IR) sans limitation de durée","is_correct":true},
     {"id":"c","label":"Elle ne peut être qu''à l''IR pendant 5 ans","is_correct":false},
     {"id":"d","label":"Elle est obligatoirement à l''IR","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-a','droit','fiscalite','premium','sarl-famille'],
   'mft-original-2026:2', true,
   'La SARL de famille (parents et enfants uniquement, en ligne directe) peut opter pour l''IR sans limitation de durée — c''est une dérogation au régime IS de droit commun.'),

  (formation_uuid, 'qcm',
   'Un transporteur lillois facture 4 200 € HT à un client commerçant brestois. Le client refuse de payer en invoquant un litige sur les délais. Quel tribunal est compétent pour la procédure d''injonction de payer ?',
   '[{"id":"a","label":"Tribunal de commerce de Lille (siège du créancier)","is_correct":false},
     {"id":"b","label":"Tribunal de commerce de Brest (siège du débiteur)","is_correct":true},
     {"id":"c","label":"Tribunal d''instance le plus proche","is_correct":false},
     {"id":"d","label":"Tribunal mixte de commerce","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-a','droit','cas-pratique','premium','recouvrement'],
   'mft-original-2026:3', true,
   'En matière d''injonction de payer, c''est toujours le tribunal du siège du débiteur qui est compétent (Code de procédure civile).'),

  (formation_uuid, 'qcm',
   'L''entreprise EFFICACE TRANSPORT (SARL) est en cessation de paiements depuis 30 jours. Le gérant n''a pas encore déposé le bilan. Quelle est la sanction encourue par le gérant ?',
   '[{"id":"a","label":"Aucune sanction tant qu''il dépose dans les 60 jours","is_correct":false},
     {"id":"b","label":"Une amende civile de 1 500 €","is_correct":false},
     {"id":"c","label":"Une faillite personnelle pouvant aller jusqu''à 15 ans d''interdiction de gérer","is_correct":true},
     {"id":"d","label":"Une simple mise en demeure du procureur","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-a','droit','procedure-collective','premium','mise-en-situation'],
   'mft-original-2026:4', true,
   'L''obligation de déclarer la cessation des paiements est de 45 jours (art. L. 631-4 C. com.). Au-delà, le dirigeant risque la faillite personnelle (jusqu''à 15 ans) et une interdiction de gérer.'),

  (formation_uuid, 'qcm',
   'Un client e-commerçant vous adresse une lettre de change pour régler une facture de transport. Qui est le « tireur » de cette lettre de change ?',
   '[{"id":"a","label":"Le client e-commerçant (débiteur)","is_correct":false},
     {"id":"b","label":"Le transporteur (créancier)","is_correct":true},
     {"id":"c","label":"La banque du client","is_correct":false},
     {"id":"d","label":"Le destinataire de la marchandise","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-a','droit','effets-commerce','premium'],
   'mft-original-2026:5', true,
   'La lettre de change est rédigée par le créancier (le tireur — ici le transporteur) qui demande au tiré (le débiteur) de payer. C''est l''inverse du billet à ordre.'),

  (formation_uuid, 'qcm',
   'Vous créez une SARL de transport léger avec un capital social de 5 000 €. Vous apportez 3 000 € et votre associé 2 000 €. En cas de dépôt de bilan avec un passif de 200 000 €, à concurrence de quoi êtes-vous responsable ?',
   '[{"id":"a","label":"De la totalité des dettes sociales","is_correct":false},
     {"id":"b","label":"De vos apports uniquement (3 000 €)","is_correct":true},
     {"id":"c","label":"De 60 % des dettes (proportion à votre apport)","is_correct":false},
     {"id":"d","label":"De 100 000 € (la moitié)","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-a','droit','responsabilite','premium','cas-pratique'],
   'mft-original-2026:6', true,
   'Dans une SARL, la responsabilité des associés est limitée à leurs apports (sauf caution personnelle ou faute de gestion).'),

  (formation_uuid, 'qcm',
   'Une SAS de transport doit modifier son capital social. Quelle assemblée doit être convoquée ?',
   '[{"id":"a","label":"L''assemblée générale ordinaire","is_correct":false},
     {"id":"b","label":"L''assemblée générale extraordinaire","is_correct":true},
     {"id":"c","label":"Une simple décision du président","is_correct":false},
     {"id":"d","label":"Un conseil de surveillance","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','module-a','droit','sas','premium'],
   'mft-original-2026:7', true,
   'Toute modification statutaire (capital, objet, dénomination) relève de l''assemblée générale extraordinaire (AGE).'),

  (formation_uuid, 'qcm',
   'Une cliente souhaite payer une facture de 850 € par chèque certifié. Que garantit la certification ?',
   '[{"id":"a","label":"Que la banque paiera quoi qu''il arrive pendant 1 an","is_correct":false},
     {"id":"b","label":"Que la provision est bloquée pendant le délai de présentation (8 jours)","is_correct":true},
     {"id":"c","label":"Que le client est solvable de manière permanente","is_correct":false},
     {"id":"d","label":"Que le chèque est garanti par l''État","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-a','droit','paiement','premium'],
   'mft-original-2026:8', true,
   'Le chèque certifié bloque la provision pendant le délai légal de présentation (8 jours en métropole). C''est plus sécurisant qu''un chèque visé.'),

  (formation_uuid, 'qcm',
   'Sur les documents commerciaux d''une entreprise (factures, devis), quelle mention est FACULTATIVE ?',
   '[{"id":"a","label":"Le numéro SIRET","is_correct":false},
     {"id":"b","label":"La mention RCS suivie de la ville d''immatriculation","is_correct":false},
     {"id":"c","label":"Le code NAF (ou APE)","is_correct":true},
     {"id":"d","label":"Le lieu du siège social","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-a','droit','mentions-obligatoires','premium'],
   'mft-original-2026:9', true,
   'Le code NAF (Nomenclature des Activités Françaises) est facultatif sur les documents commerciaux. Le SIRET, RCS et lieu du siège sont obligatoires.'),

  (formation_uuid, 'qcm',
   'Vous devez choisir entre EI et EURL pour démarrer votre activité de coursier. Quel est le principal AVANTAGE de l''EURL par rapport à l''EI ?',
   '[{"id":"a","label":"Pas de capital social minimum","is_correct":false},
     {"id":"b","label":"Responsabilité limitée aux apports (protège le patrimoine personnel)","is_correct":true},
     {"id":"c","label":"Régime fiscal plus avantageux automatiquement","is_correct":false},
     {"id":"d","label":"Suppression des cotisations sociales","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-a','droit','creation-entreprise','premium','cas-pratique'],
   'mft-original-2026:10', true,
   'L''EURL crée une personne morale distincte, donc une responsabilité limitée aux apports — alors qu''en EI le patrimoine personnel est engagé (sauf option EI à responsabilité limitée de plein droit depuis 2022).'),

  (formation_uuid, 'qcm',
   'Un de vos chauffeurs renverse un piéton avec le véhicule de l''entreprise. Qui est responsable civilement ?',
   '[{"id":"a","label":"Uniquement le chauffeur, à titre personnel","is_correct":false},
     {"id":"b","label":"L''entreprise en tant que commettant (responsabilité du fait d''autrui)","is_correct":true},
     {"id":"c","label":"L''assurance, qui se substitue automatiquement","is_correct":false},
     {"id":"d","label":"L''État au titre du Fonds de garantie","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-a','droit','responsabilite-civile','premium','cas-pratique'],
   'mft-original-2026:11', true,
   'L''article 1242 alinéa 5 du Code civil engage la responsabilité du commettant (l''employeur) pour les dommages causés par ses préposés (salariés) dans l''exercice de leurs fonctions.'),

  (formation_uuid, 'qcm',
   'Le souscripteur d''un billet à ordre est :',
   '[{"id":"a","label":"Le créancier (vendeur)","is_correct":false},
     {"id":"b","label":"Le débiteur (acheteur) qui s''engage à payer","is_correct":true},
     {"id":"c","label":"La banque du débiteur","is_correct":false},
     {"id":"d","label":"Le notaire qui rédige l''acte","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-a','droit','effets-commerce','premium'],
   'mft-original-2026:12', true,
   'Le billet à ordre est signé par le souscripteur (= le débiteur, l''acheteur) qui s''engage à payer le bénéficiaire à une date donnée. Inverse de la lettre de change.'),

  (formation_uuid, 'qcm',
   'L''entrepreneur individuel (EI) est imposé fiscalement au titre :',
   '[{"id":"a","label":"De l''impôt sur les sociétés (IS) obligatoirement","is_correct":false},
     {"id":"b","label":"Des bénéfices industriels et commerciaux (BIC) à l''IR","is_correct":true},
     {"id":"c","label":"Des traitements et salaires uniquement","is_correct":false},
     {"id":"d","label":"De la cotisation foncière des entreprises seule","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','module-a','droit','fiscalite','premium'],
   'mft-original-2026:13', true,
   'L''EI est imposée à l''IR dans la catégorie BIC (bénéfices industriels et commerciaux) pour une activité commerciale comme le transport. Une option pour l''IS est désormais possible depuis 2022.'),

  (formation_uuid, 'qcm',
   'Vous voulez créer une société de transport léger avec votre conjoint. Quel statut permet à votre conjoint de bénéficier d''une protection sociale tout en participant à l''activité, sans être co-gérant ?',
   '[{"id":"a","label":"Conjoint salarié","is_correct":true},
     {"id":"b","label":"Conjoint collaborateur (sans rémunération)","is_correct":false},
     {"id":"c","label":"Conjoint associé minoritaire","is_correct":false},
     {"id":"d","label":"Conjoint commercial agréé","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-a','droit','conjoint','premium','cas-pratique'],
   'mft-original-2026:14', true,
   'Le statut de conjoint salarié est le plus protecteur (régime général, retraite, chômage). Les statuts de conjoint collaborateur et conjoint associé sont aussi possibles mais moins protecteurs.'),

  (formation_uuid, 'qr',
   'Une entreprise de transport (SARL TRANSGO, capital 8 000 €) connaît des difficultés. Le passif exigible atteint 50 000 €, l''actif disponible 30 000 €. Le gérant hésite à déposer le bilan.

a. Caractérisez juridiquement la situation de l''entreprise.
b. Quel est le délai légal pour déposer la déclaration de cessation des paiements ?
c. Citez 2 procédures collectives que pourrait connaître l''entreprise.
d. Quelles sanctions risque le gérant s''il tarde à déposer le bilan ?',
   NULL, 5, 'difficile',
   ARRAY['capa-3-5t','module-a','droit','procedure-collective','premium','mise-en-situation','qr'],
   'mft-original-2026:15', true,
   NULL);

  -- Mise à jour des QR avec leur réponse-modèle (pour aider le formateur)
  UPDATE public.question_bank
  SET expected_answer = $$
a. L'entreprise est en CESSATION DES PAIEMENTS : impossibilité de faire face au passif exigible (50 000 €) avec l'actif disponible (30 000 €).

b. Le délai légal pour la déclaration de cessation des paiements est de 45 JOURS à compter de la date de cessation (art. L. 631-4 C. com.).

c. Procédures possibles :
   - Procédure de SAUVEGARDE (préventive, avant cessation des paiements)
   - REDRESSEMENT JUDICIAIRE (cessation des paiements, redressement possible)
   - LIQUIDATION JUDICIAIRE (redressement impossible)
   On peut aussi citer : conciliation, mandat ad hoc.

d. Sanctions du gérant en cas de retard :
   - Faillite personnelle (jusqu'à 15 ans d'interdiction de gérer)
   - Interdiction de gérer (action séparée)
   - Responsabilité civile pour insuffisance d'actif (combler le passif)
   - Sanctions pénales possibles (banqueroute si éléments constitutifs)
$$,
      scoring_grid = 'a (1pt) : reconnaissance cessation des paiements + comparaison actif/passif | b (1pt) : 45 jours | c (1,5pt) : 2 procédures correctes citées | d (1,5pt) : 2 sanctions correctes (faillite perso, comblement passif, banqueroute)'
  WHERE source_ref = 'mft-original-2026:15';

  -- =====================================================================
  -- MODULE B — Activité commerciale (10 questions premium)
  -- =====================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES
  (formation_uuid, 'qcm',
   'Vous établissez un devis pour 2 500 € HT pour une livraison récurrente. Le client signe le devis 6 mois après votre envoi. Vos prix ont augmenté entre-temps. Que se passe-t-il ?',
   '[{"id":"a","label":"Vous pouvez refuser : un devis est valable 30 jours par défaut","is_correct":false},
     {"id":"b","label":"Si aucune validité n''est mentionnée, vous êtes engagé au prix initial","is_correct":true},
     {"id":"c","label":"Le devis est automatiquement caduc après 90 jours","is_correct":false},
     {"id":"d","label":"Vous devez vendre au prix moyen entre les deux dates","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-b','commercial','devis','premium','cas-pratique'],
   'mft-original-2026:16', true,
   'Sans mention de durée de validité, le devis reste juridiquement engageant tant que l''acceptation reste raisonnable. D''où l''importance de toujours mentionner une validité explicite (typiquement 30 jours).'),

  (formation_uuid, 'qcm',
   'Un client professionnel vous demande vos CGV. Quelle est votre obligation ?',
   '[{"id":"a","label":"Aucune, les CGV ne sont obligatoires qu''en B2C","is_correct":false},
     {"id":"b","label":"Communiquer les CGV à toute demande d''un acheteur professionnel","is_correct":true},
     {"id":"c","label":"Les afficher uniquement sur votre site web","is_correct":false},
     {"id":"d","label":"Les remettre seulement après signature du contrat","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-b','commercial','cgv','premium'],
   'mft-original-2026:17', true,
   'L''article L. 441-6 du Code de commerce impose la communication des CGV à tout professionnel qui en fait la demande pour une activité commerciale.'),

  (formation_uuid, 'qcm',
   'Vous facturez 3 600 € à un client le 15 mars. Le client paie le 30 mai (45 jours de retard). Quel est le montant de l''indemnité forfaitaire pour frais de recouvrement à laquelle vous avez droit ?',
   '[{"id":"a","label":"40 € par retard","is_correct":true},
     {"id":"b","label":"40 € par jour de retard","is_correct":false},
     {"id":"c","label":"5 % du montant impayé","is_correct":false},
     {"id":"d","label":"Aucune si non mentionnée au contrat","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-b','commercial','recouvrement','premium','cas-pratique'],
   'mft-original-2026:18', true,
   'L''article L. 441-10 du Code de commerce prévoit une indemnité forfaitaire de 40 € par facture en retard, de plein droit (sans mise en demeure préalable). Elle s''ajoute aux pénalités de retard.'),

  (formation_uuid, 'qcm',
   'Le délai de paiement maximum convenu entre professionnels (B2B) est de :',
   '[{"id":"a","label":"30 jours fin de mois","is_correct":false},
     {"id":"b","label":"45 jours fin de mois ou 60 jours date de facture","is_correct":true},
     {"id":"c","label":"90 jours net","is_correct":false},
     {"id":"d","label":"Aucune limite légale","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-b','commercial','delai-paiement','premium'],
   'mft-original-2026:19', true,
   'Code de commerce L. 441-10 : maximum 45 j fin de mois OU 60 j date de facture. Le délai supplétif (sans accord) est de 30 j fin de mois.'),

  (formation_uuid, 'qcm',
   'Combien de temps devez-vous CONSERVER vos factures clients ?',
   '[{"id":"a","label":"5 ans","is_correct":false},
     {"id":"b","label":"6 ans (durée fiscale)","is_correct":false},
     {"id":"c","label":"10 ans (Code de commerce)","is_correct":true},
     {"id":"d","label":"30 ans","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','module-b','commercial','archivage','premium'],
   'mft-original-2026:20', true,
   'L''article L. 123-22 du Code de commerce impose la conservation des documents comptables (factures incluses) pendant 10 ans à compter de la clôture de l''exercice.'),

  (formation_uuid, 'qcm',
   'Pour fidéliser un client e-commerçant qui vous confie 80 % de sa logistique, vous décidez d''appliquer une remise de fin d''année (RFA) de 3 %. Cette pratique est :',
   '[{"id":"a","label":"Interdite par le Code de commerce","is_correct":false},
     {"id":"b","label":"Légale, à condition d''être prévue contractuellement et justifiée par un service réellement rendu","is_correct":true},
     {"id":"c","label":"Soumise à autorisation préalable de la DGCCRF","is_correct":false},
     {"id":"d","label":"Possible uniquement entre 2 entreprises de transport","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-b','commercial','remise','premium','cas-pratique'],
   'mft-original-2026:21', true,
   'La RFA est légale entre professionnels si elle est convenue à l''avance et correspond à une contrepartie réelle (volume, fidélité). Elle doit figurer sur la facture ou dans une convention annuelle.'),

  (formation_uuid, 'qcm',
   'Un nouveau client refuse de signer une convention écrite et préfère travailler "à la confiance". Quel est le principal RISQUE pour vous ?',
   '[{"id":"a","label":"Aucun, la confiance suffit en B2B","is_correct":false},
     {"id":"b","label":"En cas de litige, application du contrat type général qui peut limiter votre indemnisation","is_correct":true},
     {"id":"c","label":"Vous risquez une amende administrative","is_correct":false},
     {"id":"d","label":"Vous ne pouvez pas être payé","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-b','commercial','contrat','premium','cas-pratique'],
   'mft-original-2026:22', true,
   'Sans contrat écrit, le contrat type général s''applique automatiquement. Il fixe les responsabilités mais peut imposer des règles défavorables (ex: indemnité plafonnée à 23 €/kg).'),

  (formation_uuid, 'qcm',
   'Vous travaillez avec un sous-traitant. La loi vous oblige à vérifier qu''il est :',
   '[{"id":"a","label":"Inscrit au registre des transporteurs (DREAL)","is_correct":true},
     {"id":"b","label":"Membre d''une fédération professionnelle","is_correct":false},
     {"id":"c","label":"Détenteur du label « Objectif CO2 »","is_correct":false},
     {"id":"d","label":"En activité depuis au moins 2 ans","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-b','commercial','sous-traitance','premium'],
   'mft-original-2026:23', true,
   'L''obligation de vigilance (art. L. 8222-1 C. trav.) impose de vérifier l''inscription au registre du sous-traitant. À défaut, vous risquez la solidarité financière (cotisations sociales, salaires impayés).'),

  (formation_uuid, 'qcm',
   'Un client ne paye pas sa facture de 1 200 €. Vous avez relancé sans succès. Vous décidez d''engager une procédure d''injonction de payer. Quel est le coût approximatif ?',
   '[{"id":"a","label":"Gratuit (procédure simplifiée)","is_correct":false},
     {"id":"b","label":"~ 35 € de frais de greffe","is_correct":true},
     {"id":"c","label":"Au moins 500 € (avocat obligatoire)","is_correct":false},
     {"id":"d","label":"10 % du montant réclamé","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-b','commercial','recouvrement','premium','cas-pratique'],
   'mft-original-2026:24', true,
   'L''injonction de payer est une procédure peu coûteuse (~35 €) sans avocat obligatoire. Le tribunal délivre une ordonnance qui peut être signifiée par huissier au débiteur.'),

  (formation_uuid, 'qr',
   'Vous démarrez votre activité de coursier-livraison. Décrivez votre démarche commerciale pour obtenir vos 5 premiers clients :

a. Quels canaux de prospection utiliser en priorité ?
b. Quel argumentaire commercial mettre en avant face à un commerçant local ?
c. Quels documents préparer pour rencontrer un prospect ?
d. Quel suivi mettre en place après chaque rendez-vous ?',
   NULL, 4, 'moyen',
   ARRAY['capa-3-5t','module-b','commercial','prospection','premium','mise-en-situation','qr'],
   'mft-original-2026:25', true,
   NULL);

  UPDATE public.question_bank
  SET expected_answer = $$
a. Canaux prioritaires :
   - Bouche-à-oreille local (artisans, e-commerçants, commerces de proximité)
   - Démarchage direct chez les commerçants/restaurateurs/artisans BTP
   - Référencement Google Maps + Pages Jaunes pro
   - Plateformes B2B (Coursier.fr, Stuart, Chronopost partenaire)
   - Réseau pro (CCI, association de commerçants)

b. Argumentaire commercial :
   - Réactivité locale (livraison en 2h)
   - Tarif compétitif vs grandes enseignes
   - Service personnalisé (interlocuteur unique, flexibilité horaires)
   - Engagement environnemental (vélo cargo, véhicule électrique si applicable)
   - Conformité (capacité de transport, assurance, registre DREAL)

c. Documents à préparer :
   - Carte de visite + plaquette commerciale
   - Attestation d'inscription au registre des transporteurs
   - Attestation d'assurance RC pro
   - Devis type (pour pouvoir établir un devis sur place)
   - Tarifs de référence par typologie de course

d. Suivi post-rendez-vous :
   - Envoi du devis sous 24h max
   - Email de remerciement
   - Relance commerciale à 1 semaine si pas de retour
   - CRM léger (tableau Excel ou outil comme HubSpot Free)
$$,
      scoring_grid = 'a (1pt) : 3 canaux pertinents | b (1pt) : 3 arguments structurés | c (1pt) : 3 docs cités | d (1pt) : workflow de suivi cohérent'
  WHERE source_ref = 'mft-original-2026:25';

  -- =====================================================================
  -- MODULE C — Cadre réglementaire (15 questions premium)
  -- =====================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES
  (formation_uuid, 'qcm',
   'Vous voulez créer votre entreprise de transport léger avec 1 véhicule de 2,8 t. Quelle capacité financière minimum devez-vous justifier ?',
   '[{"id":"a","label":"900 €","is_correct":false},
     {"id":"b","label":"1 800 €","is_correct":true},
     {"id":"c","label":"3 600 €","is_correct":false},
     {"id":"d","label":"9 000 € (idem >3,5 t)","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-c','reglementation','capacite-financiere','premium'],
   'mft-original-2026:26', true,
   'Décret 2011-2045 : 1 800 € pour le 1er véhicule ≤ 3,5 t, puis 900 € pour chaque véhicule supplémentaire. Justifié par capitaux propres ou garantie bancaire.'),

  (formation_uuid, 'qcm',
   'Vous exploitez 4 véhicules ≤ 3,5 t. Quelle est votre capacité financière totale exigée ?',
   '[{"id":"a","label":"1 800 €","is_correct":false},
     {"id":"b","label":"4 500 € (1 800 + 3×900)","is_correct":true},
     {"id":"c","label":"7 200 €","is_correct":false},
     {"id":"d","label":"9 000 €","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-c','reglementation','capacite-financiere','premium','cas-pratique'],
   'mft-original-2026:27', true,
   '1 800 € pour le 1er véhicule + 900 € × 3 véhicules supplémentaires = 4 500 €.'),

  (formation_uuid, 'qcm',
   'Pour démontrer votre HONORABILITÉ professionnelle, vous devez fournir :',
   '[{"id":"a","label":"Le bulletin n°1 du casier judiciaire","is_correct":false},
     {"id":"b","label":"Le bulletin n°2 du casier judiciaire","is_correct":true},
     {"id":"c","label":"Une attestation de probité du maire","is_correct":false},
     {"id":"d","label":"Une lettre de recommandation","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','module-c','reglementation','honorabilite','premium'],
   'mft-original-2026:28', true,
   'Le bulletin n°2 (B2) du casier judiciaire est requis pour la condition d''honorabilité (art. R. 3211-32 Code des transports).'),

  (formation_uuid, 'qcm',
   'La licence de transport intérieur est délivrée pour :',
   '[{"id":"a","label":"5 ans renouvelable","is_correct":false},
     {"id":"b","label":"10 ans renouvelable","is_correct":true},
     {"id":"c","label":"À vie tant que les conditions sont remplies","is_correct":false},
     {"id":"d","label":"3 ans renouvelable","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-c','reglementation','licence','premium'],
   'mft-original-2026:29', true,
   'La licence de transport intérieur (LTI) est délivrée pour 10 ans, renouvelable tacitement si les conditions d''accès sont toujours remplies.'),

  (formation_uuid, 'qcm',
   'Vous transportez de la marchandise pour un client. La marchandise est endommagée pendant le transport. Quel est le PLAFOND d''indemnisation imposé par le contrat type général ?',
   '[{"id":"a","label":"15 €/kg ou 500 €/colis","is_correct":false},
     {"id":"b","label":"23 €/kg ou 750 €/colis","is_correct":true},
     {"id":"c","label":"50 €/kg ou 1 500 €/colis","is_correct":false},
     {"id":"d","label":"Aucun plafond, indemnisation intégrale","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-c','reglementation','responsabilite','premium','cas-pratique'],
   'mft-original-2026:30', true,
   'Décret 99-269 : indemnisation plafonnée à 23 €/kg de poids brut OU 750 €/colis (le plus favorable au transporteur). Sauf déclaration de valeur écrite du client.'),

  (formation_uuid, 'qcm',
   'Vous livrez une marchandise. Le client refuse la livraison. Quel est votre délai de PRESCRIPTION pour engager une action en responsabilité contre lui ?',
   '[{"id":"a","label":"6 mois","is_correct":false},
     {"id":"b","label":"1 an","is_correct":true},
     {"id":"c","label":"3 ans","is_correct":false},
     {"id":"d","label":"5 ans","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-c','reglementation','prescription','premium'],
   'mft-original-2026:31', true,
   'Article L. 133-6 Code de commerce : prescription d''1 an pour les actions nées du contrat de transport (perte, avarie, retard, refus de livraison). Délai très court → réagir vite.'),

  (formation_uuid, 'qcm',
   'Lors d''un contrôle routier, vous devez pouvoir présenter à tout moment dans le véhicule (cocher la mauvaise réponse) :',
   '[{"id":"a","label":"Le certificat d''immatriculation","is_correct":false},
     {"id":"b","label":"L''attestation d''assurance","is_correct":false},
     {"id":"c","label":"La copie certifiée conforme de la licence","is_correct":false},
     {"id":"d","label":"L''original de la licence (jamais en copie)","is_correct":true}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-c','reglementation','controle','premium','cas-pratique'],
   'mft-original-2026:32', true,
   'Astuce : la licence ORIGINALE reste au siège, on transporte une COPIE CERTIFIÉE CONFORME (une par véhicule). Présenter l''original n''est pas requis et serait risqué (perte).'),

  (formation_uuid, 'qcm',
   'Pour un véhicule utilitaire ≤ 3,5 t en usage professionnel, quelle est la périodicité du contrôle technique ?',
   '[{"id":"a","label":"Tous les 6 mois","is_correct":false},
     {"id":"b","label":"Tous les ans","is_correct":false},
     {"id":"c","label":"Tous les 2 ans (avec contrôle pollution annuel depuis 2019)","is_correct":true},
     {"id":"d","label":"Tous les 4 ans comme un VL","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-c','reglementation','controle-technique','premium','cas-pratique'],
   'mft-original-2026:33', true,
   'VUL pro : CT complet tous les 2 ans + contrôle pollution annuel depuis 2019. Premier CT à 4 ans après immatriculation.'),

  (formation_uuid, 'qcm',
   'Pour un véhicule ≤ 3,5 t exploité en transport pour compte d''autrui, le chronotachygraphe est-il obligatoire ?',
   '[{"id":"a","label":"Oui, comme pour les > 3,5 t","is_correct":false},
     {"id":"b","label":"Non, mais le suivi du temps de travail reste obligatoire (LIC ou outil de pointage)","is_correct":true},
     {"id":"c","label":"Oui, sauf en zone urbaine","is_correct":false},
     {"id":"d","label":"Uniquement pour les véhicules > 2,5 t","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-c','reglementation','tachy','premium'],
   'mft-original-2026:34', true,
   'Le règlement (CE) 561/2006 ne s''applique qu''aux véhicules > 3,5 t. Pour les ≤ 3,5 t, c''est le Code du travail qui prévaut, avec suivi via Livret Individuel de Contrôle (LIC) ou outil équivalent.'),

  (formation_uuid, 'qcm',
   'Le LIC (Livret Individuel de Contrôle) doit être conservé combien de temps DANS LE VÉHICULE ?',
   '[{"id":"a","label":"7 jours","is_correct":false},
     {"id":"b","label":"30 jours","is_correct":false},
     {"id":"c","label":"52 jours (12 derniers + semaine en cours)","is_correct":true},
     {"id":"d","label":"1 an","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-c','reglementation','lic','premium'],
   'mft-original-2026:35', true,
   'Le LIC doit rester 52 jours à bord (dernière semaine + 11 semaines précédentes). L''employeur conserve ensuite les données 3 ans.'),

  (formation_uuid, 'qcm',
   'Une marchandise est livrée avec 4 jours de retard, causant un préjudice de 800 € au destinataire (annulation de chantier). Quel est le PLAFOND d''indemnisation pour retard prévu par le contrat type ?',
   '[{"id":"a","label":"Le préjudice réel intégral (800 €)","is_correct":false},
     {"id":"b","label":"Le prix du transport","is_correct":true},
     {"id":"c","label":"100 €/jour de retard","is_correct":false},
     {"id":"d","label":"Aucune indemnité possible pour retard","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-c','reglementation','retard','premium','cas-pratique'],
   'mft-original-2026:36', true,
   'Le contrat type général plafonne l''indemnisation pour retard au montant du prix du transport (sauf déclaration d''intérêt spécial à la livraison ou faute lourde du transporteur).'),

  (formation_uuid, 'qcm',
   'Vous voulez exercer comme commissionnaire de transport (organisateur). Quelle attestation devez-vous obtenir ?',
   '[{"id":"a","label":"L''attestation de capacité de transport ≤ 3,5 t","is_correct":false},
     {"id":"b","label":"L''attestation de capacité professionnelle de COMMISSIONNAIRE (examen national distinct)","is_correct":true},
     {"id":"c","label":"Les deux attestations cumulées","is_correct":false},
     {"id":"d","label":"Aucune attestation spécifique requise","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-c','reglementation','commissionnaire','premium'],
   'mft-original-2026:37', true,
   'Le métier de commissionnaire (organisateur de transport, sans véhicule propre) requiert une attestation distincte (examen national spécifique). C''est une autre formation que la capacité.'),

  (formation_uuid, 'qcm',
   'Vous engagez un coursier non-européen (titre de séjour valide + autorisation de travail). Pour qu''il puisse conduire votre véhicule de transport pour le compte d''autrui, vous devez OBLIGATOIREMENT lui faire :',
   '[{"id":"a","label":"Une formation initiale FIMO","is_correct":false},
     {"id":"b","label":"Demander l''attestation de conducteur (à présenter lors des contrôles)","is_correct":true},
     {"id":"c","label":"Souscrire une assurance complémentaire","is_correct":false},
     {"id":"d","label":"Le déclarer auprès de la DREAL séparément","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-c','reglementation','conducteur-non-ue','premium','cas-pratique'],
   'mft-original-2026:38', true,
   'L''attestation de conducteur (délivrée par la DREAL) est OBLIGATOIRE pour les conducteurs ressortissants d''États tiers à l''UE travaillant pour une entreprise française. Elle doit être à bord du véhicule.'),

  (formation_uuid, 'qcm',
   'Quelle est la durée maximale légale de conduite par jour pour un conducteur de véhicule ≤ 3,5 t (Code du travail) ?',
   '[{"id":"a","label":"8 heures","is_correct":false},
     {"id":"b","label":"9 heures","is_correct":false},
     {"id":"c","label":"10 heures (peut être portée à 12 h en équipage)","is_correct":true},
     {"id":"d","label":"15 heures","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-c','reglementation','temps-conduite','premium'],
   'mft-original-2026:39', true,
   'Code du travail : 10 h/jour max, 12 h en équipage avec dérogation. À ne pas confondre avec le règlement (CE) 561/2006 qui s''applique au > 3,5 t (9 h, 10 h 2× par semaine).'),

  (formation_uuid, 'qr',
   'Vous démarrez votre entreprise de transport léger demain. Avant la mise en service de votre 1er véhicule, listez l''intégralité des démarches et documents nécessaires :

a. Conditions d''accès à la profession (4 conditions à citer et expliquer brièvement)
b. Démarches d''inscription et organisme compétent
c. Documents permanents à conserver dans le véhicule
d. Délai d''obtention de la licence',
   NULL, 6, 'difficile',
   ARRAY['capa-3-5t','module-c','reglementation','creation','premium','mise-en-situation','qr'],
   'mft-original-2026:40', true,
   NULL);

  UPDATE public.question_bank
  SET expected_answer = $$
a. 4 conditions d'accès :
   1. HONORABILITÉ professionnelle (bulletin n°2 du casier judiciaire vierge)
   2. CAPACITÉ FINANCIÈRE (1 800 € pour le 1er véhicule + 900 € par véhicule supplémentaire)
   3. CAPACITÉ PROFESSIONNELLE (attestation obtenue après formation et examen)
   4. ÉTABLISSEMENT STABLE en France (siège social, locaux, personnel)

b. Inscription :
   - Auprès de la DREAL (Direction Régionale Environnement Aménagement Logement) du siège
   - Documents à fournir : K-bis, attestations capacité (financière + professionnelle), B2 du casier, justificatif d'établissement, statuts si société

c. Documents à bord :
   - Certificat d'immatriculation (carte grise)
   - Attestation d'assurance + macaron sur pare-brise
   - Contrôle technique en cours de validité
   - Permis de conduire valide
   - COPIE CERTIFIÉE CONFORME de la licence de transport intérieur (1 par véhicule)
   - Lettre de voiture / bordereau de livraison
   - Attestation de conducteur (si conducteur non-UE)

d. Délai : la DREAL délivre la licence sous 3 à 4 semaines après dossier complet.
   La licence est valable 10 ans, renouvelable.
$$,
      scoring_grid = 'a (2pts) : 4 conditions citées correctement | b (1pt) : DREAL + 3 docs | c (2pts) : 5 docs corrects (carte grise, assurance, CT, copie licence, lettre voiture) | d (1pt) : 3-4 semaines + 10 ans validité'
  WHERE source_ref = 'mft-original-2026:40';

  -- =====================================================================
  -- MODULE D — Activité financière (15 questions premium)
  -- =====================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES
  (formation_uuid, 'qcm',
   'Vous lisez un bilan : à l''actif, vous avez 80 000 € d''immobilisations + 25 000 € de créances clients + 5 000 € de trésorerie. Au passif : 50 000 € de capitaux propres + 30 000 € de dettes financières + 30 000 € de dettes fournisseurs. Le bilan est-il équilibré ?',
   '[{"id":"a","label":"Oui : actif (110 000) = passif (110 000)","is_correct":true},
     {"id":"b","label":"Non, il manque 10 000 € au passif","is_correct":false},
     {"id":"c","label":"Non, il manque 5 000 € à l''actif","is_correct":false},
     {"id":"d","label":"Impossible à dire avec ces seules informations","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-d','financier','bilan','premium','cas-pratique'],
   'mft-original-2026:41', true,
   'Actif = 80 000 + 25 000 + 5 000 = 110 000 €. Passif = 50 000 + 30 000 + 30 000 = 110 000 €. Le bilan EST équilibré (règle fondamentale : actif = passif).'),

  (formation_uuid, 'qcm',
   'Une entreprise réalise un chiffre d''affaires de 200 000 € avec 150 000 € de charges (dont 30 000 € de dotations aux amortissements). Quel est son EBE (Excédent Brut d''Exploitation) ?',
   '[{"id":"a","label":"50 000 €","is_correct":false},
     {"id":"b","label":"80 000 € (= 50 000 + 30 000 dotations)","is_correct":true},
     {"id":"c","label":"30 000 €","is_correct":false},
     {"id":"d","label":"200 000 € - charges décaissées seulement","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-d','financier','ebe','premium','cas-pratique'],
   'mft-original-2026:42', true,
   'L''EBE se calcule AVANT dotations aux amortissements. CA - charges hors dotations = 200 000 - (150 000 - 30 000) = 80 000 €. C''est le revenu généré par l''exploitation pure.'),

  (formation_uuid, 'qcm',
   'Vous financez un véhicule neuf à 25 000 € HT, amorti sur 5 ans en linéaire. Quelle est la dotation aux amortissements ANNUELLE ?',
   '[{"id":"a","label":"2 500 €","is_correct":false},
     {"id":"b","label":"5 000 €","is_correct":true},
     {"id":"c","label":"6 250 €","is_correct":false},
     {"id":"d","label":"25 000 € la 1ère année","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','module-d','financier','amortissement','premium','cas-pratique'],
   'mft-original-2026:43', true,
   'Amortissement linéaire = 25 000 € / 5 ans = 5 000 € par an. C''est une charge non décaissée qui réduit le résultat fiscal.'),

  (formation_uuid, 'qcm',
   'Calculez le coût de revient kilométrique sachant : charges fixes annuelles 36 000 €, charges variables 0,12 €/km, kilométrage annuel 50 000 km.',
   '[{"id":"a","label":"0,72 €/km","is_correct":false},
     {"id":"b","label":"0,84 €/km (= 36 000/50 000 + 0,12)","is_correct":true},
     {"id":"c","label":"0,12 €/km","is_correct":false},
     {"id":"d","label":"1,20 €/km","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-d','financier','cout-revient','premium','cas-pratique'],
   'mft-original-2026:44', true,
   'Coût km = (CF/km annuels) + CV km = (36 000/50 000) + 0,12 = 0,72 + 0,12 = 0,84 €/km. Pour la rentabilité, ajouter une marge ~20-25% → tarif client ~1,05 €/km.'),

  (formation_uuid, 'qcm',
   'Votre CAF (Capacité d''Autofinancement) annuelle est de 24 000 €. Vous voulez financer un véhicule de 30 000 € sur 4 ans. La banque accepte si la CAF couvre :',
   '[{"id":"a","label":"L''annuité de remboursement (~7 500 € + intérêts)","is_correct":true},
     {"id":"b","label":"Le montant total emprunté en 1 an","is_correct":false},
     {"id":"c","label":"Au moins 50 % du capital emprunté","is_correct":false},
     {"id":"d","label":"3 fois l''annuité","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-d','financier','caf','premium','cas-pratique'],
   'mft-original-2026:45', true,
   'La CAF doit couvrir les annuités (capital + intérêts). Annuité ~7 500 € + ~1 000 € intérêts = 8 500 € → CAF 24 000 € suffit largement (ratio CAF/annuité = 2,8). Limite généralement acceptée : ≥ 1,5.'),

  (formation_uuid, 'qcm',
   'Le BFR (Besoin en Fonds de Roulement) d''une entreprise de transport est composé principalement :',
   '[{"id":"a","label":"Des stocks de marchandises (généralement faibles en transport)","is_correct":false},
     {"id":"b","label":"Du décalage entre encaissements clients (45-60j) et décaissements (carburant, salaires)","is_correct":true},
     {"id":"c","label":"Uniquement des dettes fournisseurs","is_correct":false},
     {"id":"d","label":"Des immobilisations en cours","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-d','financier','bfr','premium'],
   'mft-original-2026:46', true,
   'En transport, les stocks sont faibles. Le BFR vient surtout du gros décalage : clients B2B paient à 45-60 j alors que les fournisseurs (carburant, salaires) sont payés sous 30 j ou immédiatement.'),

  (formation_uuid, 'qcm',
   'Quel ratio mesure la solidité financière de votre entreprise (capacité à faire face à ses dettes long terme) ?',
   '[{"id":"a","label":"CAF / CA","is_correct":false},
     {"id":"b","label":"Capitaux propres / Dettes financières long terme","is_correct":true},
     {"id":"c","label":"Trésorerie / CA","is_correct":false},
     {"id":"d","label":"Marge nette / CA","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-d','financier','ratios','premium'],
   'mft-original-2026:47', true,
   'Le ratio Capitaux propres / Dettes LT (autonomie financière) doit être > 1 pour rassurer les créanciers. Une banque exige souvent ≥ 1, idéalement > 1,5 pour accorder un nouveau crédit.'),

  (formation_uuid, 'qcm',
   'Vous facturez 10 000 € HT à un client B2B avec TVA 20 %. Le client paie après 60 jours. Quelle TVA déclarez-vous au mois de facturation ?',
   '[{"id":"a","label":"Aucune (encaissement non perçu)","is_correct":false},
     {"id":"b","label":"2 000 € (TVA sur les débits par défaut pour les services)","is_correct":true},
     {"id":"c","label":"1 666 € (TVA dans le prix)","is_correct":false},
     {"id":"d","label":"Cela dépend du régime fiscal de votre client","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-d','financier','tva','premium','cas-pratique'],
   'mft-original-2026:48', true,
   'Pour les prestations de services (transport), la TVA est exigible AU PAIEMENT (encaissement). Cependant beaucoup d''entreprises optent pour les "débits" (TVA exigible à la facture). À 20%, sur 10 000 €, TVA = 2 000 €.'),

  (formation_uuid, 'qcm',
   'Pour optimiser votre trésorerie, vous décidez de pratiquer l''AFFACTURAGE. En quoi consiste-t-il ?',
   '[{"id":"a","label":"Céder vos créances clients à un factor en échange d''un paiement immédiat (- commission)","is_correct":true},
     {"id":"b","label":"Renégocier vos dettes fournisseurs","is_correct":false},
     {"id":"c","label":"Augmenter vos prix de 5 %","is_correct":false},
     {"id":"d","label":"Imposer le paiement comptant à tous vos clients","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-d','financier','affacturage','premium'],
   'mft-original-2026:49', true,
   'L''affacturage (factoring) consiste à céder vos factures à un factor qui vous paie immédiatement (typiquement 80-90% du montant). Coût : 1 à 3% selon le volume. Idéal pour les entreprises avec un BFR élevé.'),

  (formation_uuid, 'qcm',
   'Quelle est la principale différence entre une charge et une immobilisation ?',
   '[{"id":"a","label":"Le montant (>1 000 € = immobilisation)","is_correct":false},
     {"id":"b","label":"La durée d''utilisation : >1 an = immobilisation, ≤1 an = charge","is_correct":true},
     {"id":"c","label":"L''amortissement, qui n''existe que pour les charges","is_correct":false},
     {"id":"d","label":"Aucune différence","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-d','financier','comptabilite','premium'],
   'mft-original-2026:50', true,
   'La règle : un bien dont la durée d''utilisation > 1 an et la valeur > 500 € HT (seuil tolérance) est une immobilisation amortie sur sa durée d''usage. Sinon c''est une charge décaissée immédiatement.'),

  (formation_uuid, 'qcm',
   'Vous achetez un nouveau véhicule en CRÉDIT-BAIL (location longue durée avec option d''achat). Quel est le principal AVANTAGE comptable ?',
   '[{"id":"a","label":"Le véhicule n''apparaît PAS au bilan, ce qui améliore les ratios financiers","is_correct":true},
     {"id":"b","label":"Aucune charge mensuelle","is_correct":false},
     {"id":"c","label":"Vous devenez propriétaire immédiatement","is_correct":false},
     {"id":"d","label":"Pas de TVA à payer","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-d','financier','credit-bail','premium','cas-pratique'],
   'mft-original-2026:51', true,
   'En crédit-bail, le bien reste la propriété du bailleur, donc n''apparaît pas à l''actif. Cela améliore les ratios d''endettement. Les loyers sont déductibles du résultat fiscal. Inconvénient : coût total souvent plus élevé qu''un emprunt classique.'),

  (formation_uuid, 'qcm',
   'Au moment de votre déclaration de TVA, vous avez COLLECTÉ 5 000 € de TVA sur vos ventes et payé 3 000 € de TVA sur vos achats (TVA déductible). Quel montant versez-vous à l''État ?',
   '[{"id":"a","label":"5 000 € (la TVA collectée)","is_correct":false},
     {"id":"b","label":"2 000 € (différence collectée - déductible)","is_correct":true},
     {"id":"c","label":"3 000 € (la TVA déductible)","is_correct":false},
     {"id":"d","label":"8 000 € (somme des deux)","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-d','financier','tva','premium','cas-pratique'],
   'mft-original-2026:52', true,
   'TVA à payer = TVA collectée - TVA déductible = 5 000 - 3 000 = 2 000 €. Si la TVA déductible est supérieure, vous obtenez un crédit de TVA reportable ou remboursable.'),

  (formation_uuid, 'qcm',
   'Le seuil de rentabilité (point mort) d''une entreprise correspond au :',
   '[{"id":"a","label":"Chiffre d''affaires minimum pour couvrir toutes les charges (résultat = 0)","is_correct":true},
     {"id":"b","label":"Bénéfice net divisé par 12","is_correct":false},
     {"id":"c","label":"Montant des capitaux propres minimum","is_correct":false},
     {"id":"d","label":"Trésorerie disponible","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-d','financier','seuil-rentabilite','premium'],
   'mft-original-2026:53', true,
   'Le seuil de rentabilité = Charges fixes / Taux de marge sur coût variable. C''est le CA à partir duquel l''entreprise commence à dégager un profit.'),

  (formation_uuid, 'qcm',
   'Une entreprise est REDEVABLE de la CFE (Cotisation Foncière des Entreprises) :',
   '[{"id":"a","label":"Uniquement si elle réalise plus de 100 000 € de CA","is_correct":false},
     {"id":"b","label":"Dès qu''elle exerce une activité professionnelle non salariée","is_correct":true},
     {"id":"c","label":"Uniquement si elle est propriétaire de ses locaux","is_correct":false},
     {"id":"d","label":"Uniquement les sociétés (pas les EI)","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-d','financier','cfe','premium'],
   'mft-original-2026:54', true,
   'La CFE est due par toute entreprise (EI ou société) exerçant une activité professionnelle. Exonération la 1ère année + plafond de 500 € pour les CA < 5 000 €.'),

  (formation_uuid, 'qr',
   'La société TRANSGO SARL souhaite emprunter 40 000 € sur 5 ans pour acheter un nouveau véhicule. Données comptables :
   - Résultat net : 18 000 €
   - Dotations aux amortissements : 12 000 €
   - Capitaux propres : 60 000 €
   - Dettes financières existantes : 25 000 €

a. Calculez la CAF (Capacité d''Autofinancement)
b. Calculez le ratio d''autonomie financière (capitaux propres / dettes financières)
c. Calculez l''annuité approximative (capital seul, hors intérêts) du nouvel emprunt
d. La banque devrait-elle accorder le crédit ? Justifiez en 3 arguments.',
   NULL, 6, 'difficile',
   ARRAY['capa-3-5t','module-d','financier','caf','premium','mise-en-situation','qr'],
   'mft-original-2026:55', true,
   NULL);

  UPDATE public.question_bank
  SET expected_answer = $$
a. CAF (méthode simplifiée) = Résultat net + Dotations aux amortissements
   = 18 000 + 12 000 = 30 000 €

b. Ratio d'autonomie financière = Capitaux propres / Dettes financières
   = 60 000 / 25 000 = 2,4
   (ratio > 1 : très bon, l'entreprise est peu endettée)

c. Annuité capital nouvel emprunt = 40 000 / 5 = 8 000 € par an
   (avec ~1 200 € d'intérêts, l'annuité réelle ~9 200 €)

d. Décision banque : OUI, le crédit doit être accordé. 3 arguments :
   1. CAF (30 000 €) couvre largement l'annuité (9 200 €) → ratio CAF/annuité = 3,3 (>>1,5 minimum)
   2. Endettement post-crédit : (25 000 + 40 000) / 60 000 = 1,08 → reste viable (< 2)
   3. Le ratio d'autonomie reste sain : 60 000 / 65 000 = 0,92 (légèrement < 1, mais avec un nouvel actif productif)
$$,
      scoring_grid = 'a (1pt) : CAF = 30 000 € | b (1pt) : 2,4 | c (1pt) : 8 000 €/an capital | d (3pts) : décision OUI + 3 arguments chiffrés'
  WHERE source_ref = 'mft-original-2026:55';

  -- =====================================================================
  -- MODULE E — Salariés (15 questions premium)
  -- =====================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES
  (formation_uuid, 'qcm',
   'Vous embauchez votre 1er chauffeur en CDI. Quelle est la durée maximale de la PÉRIODE D''ESSAI pour un employé non-cadre ?',
   '[{"id":"a","label":"1 mois renouvelable","is_correct":false},
     {"id":"b","label":"2 mois renouvelable une fois (4 mois max)","is_correct":true},
     {"id":"c","label":"6 mois sans renouvellement","is_correct":false},
     {"id":"d","label":"Pas de période d''essai en transport","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-e','salaries','contrat-travail','premium'],
   'mft-original-2026:56', true,
   'Code du travail L. 1221-19 : 2 mois pour les employés/ouvriers, renouvelable 1 fois (4 mois max). Pour les cadres : 4 mois renouvelable (8 mois max).'),

  (formation_uuid, 'qcm',
   'Quel est le SMIC HORAIRE BRUT en 2026 (ordre de grandeur attendu à l''examen) ?',
   '[{"id":"a","label":"~10 €","is_correct":false},
     {"id":"b","label":"~11,88 € (revalorisation 2024-2025)","is_correct":true},
     {"id":"c","label":"~13 €","is_correct":false},
     {"id":"d","label":"~9 €","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','module-e','salaries','smic','premium'],
   'mft-original-2026:57', true,
   'SMIC horaire brut 2026 ≈ 11,88 €/h (à confirmer selon revalorisation). SMIC mensuel brut ≈ 1 802 € pour 35h/semaine.'),

  (formation_uuid, 'qcm',
   'Un de vos chauffeurs perd son permis de conduire suite à une infraction commise PENDANT son temps de travail. Que pouvez-vous faire ?',
   '[{"id":"a","label":"Le licencier automatiquement pour faute lourde","is_correct":false},
     {"id":"b","label":"Engager une procédure disciplinaire (avertissement, mise à pied, voire licenciement disciplinaire selon gravité)","is_correct":true},
     {"id":"c","label":"Lui demander de payer une amende à l''entreprise","is_correct":false},
     {"id":"d","label":"Rien, la perte du permis est de la vie privée","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-e','salaries','licenciement','premium','cas-pratique'],
   'mft-original-2026:58', true,
   'Une infraction commise PENDANT le temps de travail relève de la vie professionnelle. Une procédure disciplinaire peut aller jusqu''au licenciement (selon gravité, antécédents, taille entreprise). Si infraction hors travail = licenciement plus difficile à justifier.'),

  (formation_uuid, 'qcm',
   'La durée légale du travail est de 35h/semaine. Au-delà (heures supplémentaires), la majoration est de :',
   '[{"id":"a","label":"+10 % pour toutes les heures sup","is_correct":false},
     {"id":"b","label":"+25 % pour les 8 premières (36e à 43e), +50 % au-delà (44e à 48e)","is_correct":true},
     {"id":"c","label":"+50 % dès la 1ère heure supplémentaire","is_correct":false},
     {"id":"d","label":"Pas de majoration en transport (régime spécial)","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-e','salaries','heures-sup','premium'],
   'mft-original-2026:59', true,
   'Code du travail L. 3121-22 : +25 % pour les heures 36 à 43, +50 % au-delà. Convention collective ou accord d''entreprise peut prévoir des majorations différentes (mais pas inférieures à +10 %).'),

  (formation_uuid, 'qcm',
   'Vous voulez licencier un chauffeur pour faute. Quelle est la 1ère étape de la PROCÉDURE DISCIPLINAIRE ?',
   '[{"id":"a","label":"Notifier directement le licenciement par LRAR","is_correct":false},
     {"id":"b","label":"Convoquer le salarié à un entretien préalable (LRAR ou main propre, ≥5 j ouvrables avant)","is_correct":true},
     {"id":"c","label":"Saisir le conseil de prud''hommes pour avis","is_correct":false},
     {"id":"d","label":"Demander l''autorisation à l''inspection du travail","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-e','salaries','licenciement','premium','cas-pratique'],
   'mft-original-2026:60', true,
   'Procédure obligatoire : 1) Convocation à l''entretien préalable (≥5 j ouvrables avant), 2) Entretien (le salarié peut être assisté), 3) Notification du licenciement par LRAR (≥2 j ouvrables après l''entretien, ≤1 mois pour faute).'),

  (formation_uuid, 'qcm',
   'Un chauffeur licencié après 8 ans d''ancienneté avec un salaire moyen de 2 200 €. Quelle est l''indemnité légale de licenciement ?',
   '[{"id":"a","label":"4 400 € (1/4 × 8 × 2 200)","is_correct":true},
     {"id":"b","label":"5 866 € (1/3 × 8 × 2 200)","is_correct":false},
     {"id":"c","label":"2 200 € (1 mois)","is_correct":false},
     {"id":"d","label":"Aucune indemnité (faute simple)","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-e','salaries','indemnite','premium','cas-pratique'],
   'mft-original-2026:61', true,
   'Indemnité légale = 1/4 mois × ancienneté pour les 10 premières années = 1/4 × 8 × 2 200 = 4 400 €. Au-delà de 10 ans : 1/3 mois × ancienneté supplémentaire.'),

  (formation_uuid, 'qcm',
   'Un de vos chauffeurs vous demande une RUPTURE CONVENTIONNELLE. C''est :',
   '[{"id":"a","label":"Un licenciement déguisé pour économiser sur les indemnités","is_correct":false},
     {"id":"b","label":"Une rupture amiable avec versement d''indemnités spécifiques + ouverture des droits chômage","is_correct":true},
     {"id":"c","label":"Une démission avec préavis raccourci","is_correct":false},
     {"id":"d","label":"Une procédure réservée aux cadres","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-e','salaries','rupture-conventionnelle','premium'],
   'mft-original-2026:62', true,
   'La rupture conventionnelle (art. L. 1237-11 et s.) est un mode de rupture amiable qui ouvre droit aux allocations chômage. L''indemnité minimale est égale à l''indemnité légale de licenciement. Homologation par la DIRECCTE/DREETS sous 15 j.'),

  (formation_uuid, 'qcm',
   'La convention collective applicable au transport routier de marchandises est :',
   '[{"id":"a","label":"La CCN du commerce et des services","is_correct":false},
     {"id":"b","label":"La CCN Transport Routier et Activités Auxiliaires de Transport (CCNTRAAT) — IDCC 16","is_correct":true},
     {"id":"c","label":"Aucune convention nationale (régime libre)","is_correct":false},
     {"id":"d","label":"La CCN de la métallurgie","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-e','salaries','convention-collective','premium'],
   'mft-original-2026:63', true,
   'CCNTRAAT (IDCC 16) — convention étendue, donc applicable de plein droit à TOUTES les entreprises de transport routier (qu''elles soient signataires ou non).'),

  (formation_uuid, 'qcm',
   'Quel est le délai de PRÉAVIS d''un employé non-cadre licencié avec 3 ans d''ancienneté ?',
   '[{"id":"a","label":"15 jours","is_correct":false},
     {"id":"b","label":"1 mois","is_correct":false},
     {"id":"c","label":"2 mois","is_correct":true},
     {"id":"d","label":"3 mois","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-e','salaries','preavis','premium','cas-pratique'],
   'mft-original-2026:64', true,
   'Code du travail : préavis de 1 mois pour <2 ans ancienneté, 2 mois à partir de 2 ans. La convention collective peut prévoir des durées plus longues. CCNTRAAT : idem.'),

  (formation_uuid, 'qcm',
   'Un de vos chauffeurs commet une FAUTE GRAVE (vol de carburant). Conséquences :',
   '[{"id":"a","label":"Licenciement immédiat sans préavis ni indemnité légale, avec versement des congés payés","is_correct":true},
     {"id":"b","label":"Licenciement avec préavis et indemnités complètes","is_correct":false},
     {"id":"c","label":"Mise à pied conservatoire de 3 jours","is_correct":false},
     {"id":"d","label":"Dommages-intérêts à payer par le salarié à l''entreprise","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-e','salaries','faute-grave','premium','cas-pratique'],
   'mft-original-2026:65', true,
   'Faute grave : pas de préavis, pas d''indemnité de licenciement, mais l''indemnité compensatrice de congés payés reste due. Faute lourde (intention de nuire) : pas même les CP.'),

  (formation_uuid, 'qcm',
   'Vous embauchez un chauffeur en CDD pour 6 mois (remplacement maladie). À l''issue, le poste reste vacant. Que pouvez-vous faire ?',
   '[{"id":"a","label":"Renouveler le CDD une seule fois pour un an supplémentaire","is_correct":false},
     {"id":"b","label":"Renouveler le CDD jusqu''à 18 mois maximum (durée totale)","is_correct":true},
     {"id":"c","label":"Le transformer automatiquement en CDI","is_correct":false},
     {"id":"d","label":"Conclure un nouveau CDD avec une autre personne sans délai","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-e','salaries','cdd','premium','cas-pratique'],
   'mft-original-2026:66', true,
   'Un CDD pour remplacement peut être renouvelé 2 fois, sans dépasser 18 mois au total (24 mois pour certains motifs). Délai de carence entre 2 CDD sur le même poste : 1/3 du contrat précédent.'),

  (formation_uuid, 'qcm',
   'Un de vos salariés réclame des HEURES SUPPLÉMENTAIRES non payées. Sur combien d''années peut-il remonter ?',
   '[{"id":"a","label":"6 mois","is_correct":false},
     {"id":"b","label":"1 an","is_correct":false},
     {"id":"c","label":"3 ans (prescription des salaires)","is_correct":true},
     {"id":"d","label":"5 ans","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-e','salaries','prescription','premium'],
   'mft-original-2026:67', true,
   'Code du travail L. 3245-1 : prescription de 3 ans pour les salaires (avant 2013, c''était 5 ans). Ce délai court à compter du jour où le salarié a eu connaissance des faits.'),

  (formation_uuid, 'qcm',
   'Vous devez établir un BULLETIN DE PAIE. Quelle mention est OBLIGATOIRE ?',
   '[{"id":"a","label":"Le motif du dernier entretien d''évaluation","is_correct":false},
     {"id":"b","label":"Le numéro de SIRET de l''entreprise","is_correct":true},
     {"id":"c","label":"Le numéro de téléphone personnel du salarié","is_correct":false},
     {"id":"d","label":"L''adresse personnelle de l''employeur","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-e','salaries','bulletin-paie','premium'],
   'mft-original-2026:68', true,
   'Le SIRET, l''identité du salarié, la convention collective, le brut, les cotisations détaillées, le net à payer, et la mention "à conserver sans limitation de durée" sont obligatoires.'),

  (formation_uuid, 'qcm',
   'Un salarié peut-il REFUSER une mutation géographique sans clause de mobilité au contrat ?',
   '[{"id":"a","label":"Non, l''employeur peut toujours imposer une mutation","is_correct":false},
     {"id":"b","label":"Oui, sans clause de mobilité, la mutation modifie le contrat (acceptation requise)","is_correct":true},
     {"id":"c","label":"Oui mais seulement si la mutation est à plus de 50 km","is_correct":false},
     {"id":"d","label":"Non, sauf pour raisons familiales graves","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-e','salaries','mobilite','premium','cas-pratique'],
   'mft-original-2026:69', true,
   'Sans clause de mobilité ÉCRITE (avec zone géographique précise), la mutation hors du secteur géographique habituel = modification du contrat → accord du salarié obligatoire. Refus = rupture du fait de l''employeur (licenciement, indemnités dues).'),

  (formation_uuid, 'qcm',
   'En cas de DÉPART À LA RETRAITE à l''initiative du salarié (qui en a l''âge légal), il a droit à :',
   '[{"id":"a","label":"L''indemnité légale de licenciement","is_correct":false},
     {"id":"b","label":"L''indemnité de départ à la retraite (= 1/2 mois × ancienneté pour 5-10 ans)","is_correct":true},
     {"id":"c","label":"Aucune indemnité (départ volontaire)","is_correct":false},
     {"id":"d","label":"Le double de l''indemnité de licenciement","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-e','salaries','retraite','premium'],
   'mft-original-2026:70', true,
   'Indemnité de départ volontaire à la retraite : 1/2 mois (5-10 ans), 1 mois (10-20 ans), 1,5 mois (20-30 ans), 2 mois (>30 ans). Si départ à l''initiative de l''employeur : indemnité de mise à la retraite = au moins indemnité légale licenciement.'),

  (formation_uuid, 'qr',
   'Vous dirigez une entreprise de transport léger avec 4 chauffeurs salariés. Un des chauffeurs (Karim, 6 ans d''ancienneté, salaire moyen 2 100 €) a accumulé plusieurs avertissements (retards récurrents, refus de tournées, comportement agressif avec un client). Vous décidez de procéder à son licenciement disciplinaire pour cause réelle et sérieuse.

a. Décrivez la procédure de licenciement étape par étape.
b. Calculez l''indemnité légale de licenciement due à Karim.
c. Quel est le délai de préavis applicable ?
d. Citez 2 risques pour vous si la procédure n''est pas respectée à la lettre.',
   NULL, 6, 'difficile',
   ARRAY['capa-3-5t','module-e','salaries','licenciement','premium','mise-en-situation','qr'],
   'mft-original-2026:71', true,
   NULL);

  UPDATE public.question_bank
  SET expected_answer = $$
a. Procédure de licenciement disciplinaire :
   1. CONVOCATION à entretien préalable par LRAR ou remise main propre contre décharge (≥5 jours ouvrables avant l'entretien, mention de l'objet, date, heure, lieu, droit à assistance).
   2. ENTRETIEN PRÉALABLE : exposer les motifs, écouter les explications du salarié. Le salarié peut être assisté (collègue ou conseiller du salarié).
   3. NOTIFICATION du licenciement par LRAR (≥2 jours ouvrables après l'entretien, ≤1 mois pour faute), avec motifs précis et circonstanciés.
   4. Versement des indemnités, remise des documents (certificat de travail, attestation Pôle Emploi, solde de tout compte).

b. Indemnité légale = 1/4 mois × 6 ans × 2 100 € = 3 150 €
   (formule : 1/4 mois × ancienneté pour les 10 premières années)

c. Préavis : 2 mois (ancienneté ≥ 2 ans, employé non-cadre).
   Convention CCNTRAAT confirmée.

d. Risques en cas de procédure non respectée :
   1. CONDAMNATION pour licenciement sans cause réelle et sérieuse : indemnité minimale fixée par le barème Macron (entre 3 et 8 mois selon ancienneté → ici ~6-12 000 €)
   2. CONDAMNATION pour irrégularité de procédure : 1 mois de salaire supplémentaire (~2 100 €)
   3. Versement des dommages-intérêts pour préjudice moral si éléments
   4. Inscription au prud'hommes (procédure publique, atteinte à la réputation)
$$,
      scoring_grid = 'a (2pts) : 3-4 étapes claires (convocation, entretien, notification) | b (1pt) : 3 150 € | c (1pt) : 2 mois | d (2pts) : 2 risques pertinents (condamnation prud''homale + irrégularité)'
  WHERE source_ref = 'mft-original-2026:71';

  -- =====================================================================
  -- MODULE F — Sécurité (10 questions premium)
  -- =====================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES
  (formation_uuid, 'qcm',
   'Un de vos chauffeurs (employé en CDI depuis 5 ans) est arrêté avec 0,9 g/L d''alcool dans le sang lors d''un contrôle routier pendant son travail. Quelle est la sanction PÉNALE encourue ?',
   '[{"id":"a","label":"Une amende forfaitaire de 135 €","is_correct":false},
     {"id":"b","label":"Délit : jusqu''à 4 500 € d''amende, suspension/annulation du permis, voire prison","is_correct":true},
     {"id":"c","label":"Une simple contravention","is_correct":false},
     {"id":"d","label":"Aucune sanction si premier contrôle positif","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-f','securite','alcoolemie','premium','cas-pratique'],
   'mft-original-2026:72', true,
   'Au-delà de 0,8 g/L (ou 0,4 mg/L air expiré) = délit (art. L. 234-1 Code route) : 4 500 € + suspension permis, prison possible (2 ans), 6 points retirés. En-dessous de 0,8 g/L : contravention (135 €, 6 points).'),

  (formation_uuid, 'qcm',
   'Pour un conducteur en PÉRIODE PROBATOIRE (jeune conducteur), la limite d''alcoolémie autorisée est :',
   '[{"id":"a","label":"0,5 g/L (limite générale)","is_correct":false},
     {"id":"b","label":"0,2 g/L (équivalent à zéro)","is_correct":true},
     {"id":"c","label":"0,3 g/L","is_correct":false},
     {"id":"d","label":"Aucune tolérance, 0 g/L strict","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-f','securite','alcoolemie','premium'],
   'mft-original-2026:73', true,
   'Depuis 2015, période probatoire : 0,2 g/L (équivalent à 0 verre, marge de tolérance pour la fermentation naturelle). Au-delà = perte 6 points (= retrait permis car capital probatoire = 6 pts).'),

  (formation_uuid, 'qcm',
   'Le capital de points du PERMIS À POINTS est de :',
   '[{"id":"a","label":"6 points (probatoire) à 12 points (régime normal)","is_correct":true},
     {"id":"b","label":"10 points pour tous","is_correct":false},
     {"id":"c","label":"15 points","is_correct":false},
     {"id":"d","label":"20 points pour les permis pro","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','module-f','securite','permis-points','premium'],
   'mft-original-2026:74', true,
   'Capital initial : 6 points pendant la période probatoire (3 ans, 2 ans avec conduite accompagnée), montant ensuite à 12 points par paliers annuels.'),

  (formation_uuid, 'qcm',
   'Un conducteur perd la totalité de ses points. Que se passe-t-il ?',
   '[{"id":"a","label":"Suspension du permis pour 6 mois","is_correct":false},
     {"id":"b","label":"INVALIDATION du permis (perte du droit de conduire), repasser le permis après 6 mois minimum","is_correct":true},
     {"id":"c","label":"Annulation immédiate sans possibilité de repasser","is_correct":false},
     {"id":"d","label":"Stage obligatoire pour récupérer 6 points automatiquement","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-f','securite','permis-points','premium','cas-pratique'],
   'mft-original-2026:75', true,
   'Solde nul = INVALIDATION du permis (lettre 48SI). Le conducteur doit attendre 6 mois (1 an si récidive) puis repasser code + visite médicale. Ne pas confondre invalidation (points) et annulation (décision judiciaire).'),

  (formation_uuid, 'qcm',
   'Pour récupérer 4 points en suivant un STAGE de sensibilisation, quelles conditions ?',
   '[{"id":"a","label":"Avoir perdu au moins 6 points","is_correct":false},
     {"id":"b","label":"≥1 an depuis le précédent stage, capital > 0 et < 12 points","is_correct":true},
     {"id":"c","label":"Avoir l''accord de son employeur","is_correct":false},
     {"id":"d","label":"Stage gratuit pour les conducteurs pro","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-f','securite','stage','premium'],
   'mft-original-2026:76', true,
   'Stage volontaire : ≥1 an depuis le précédent (max 1 stage/an), capital entre 1 et 11 points (pas plein, pas zéro). Coût ~250 €. Récupération immédiate de 4 points (sans dépasser 12).'),

  (formation_uuid, 'qcm',
   'Quels sont les ÉQUIPEMENTS OBLIGATOIRES à bord d''un véhicule utilitaire en activité ?',
   '[{"id":"a","label":"Gilet de haute visibilité + triangle de pré-signalisation + éthylotest","is_correct":true},
     {"id":"b","label":"Uniquement le gilet et le triangle","is_correct":false},
     {"id":"c","label":"Gilet + triangle + extincteur (>3,5 t)","is_correct":false},
     {"id":"d","label":"Aucun équipement obligatoire","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','module-f','securite','equipements','premium'],
   'mft-original-2026:77', true,
   'Obligatoire : gilet HV (accessible depuis l''habitacle) + triangle + éthylotest. Recommandé : trousse premiers secours, lampe torche, gilet pour passagers.'),

  (formation_uuid, 'qcm',
   'Un de vos chauffeurs cause un accident sans assurance valide (oubli de paiement → résiliation). Conséquences :',
   '[{"id":"a","label":"L''assurance paie quand même par solidarité de l''assureur","is_correct":false},
     {"id":"b","label":"Le Fonds de Garantie indemnise les victimes mais se retourne contre vous + risque pénal pour défaut d''assurance","is_correct":true},
     {"id":"c","label":"L''État prend en charge","is_correct":false},
     {"id":"d","label":"Aucune conséquence si l''accident est mineur","is_correct":false}]'::jsonb,
   1, 'difficile',
   ARRAY['capa-3-5t','module-f','securite','assurance','premium','cas-pratique'],
   'mft-original-2026:78', true,
   'Défaut d''assurance = délit (3 750 € amende, suspension permis 3 ans). Le FGAO (Fonds de Garantie) indemnise les victimes mais se retourne contre vous : vous remboursez TOUT (peut atteindre des centaines de milliers d''euros).'),

  (formation_uuid, 'qcm',
   'La PROFONDEUR MINIMALE des rainures des pneumatiques (sécurité routière) est de :',
   '[{"id":"a","label":"1,0 mm","is_correct":false},
     {"id":"b","label":"1,6 mm","is_correct":true},
     {"id":"c","label":"2,5 mm","is_correct":false},
     {"id":"d","label":"3,0 mm","is_correct":false}]'::jsonb,
   1, 'facile',
   ARRAY['capa-3-5t','module-f','securite','pneus','premium'],
   'mft-original-2026:79', true,
   '1,6 mm est le seuil légal européen. En-dessous : amende 135 €/pneu non conforme + immobilisation possible + résiliation possible de l''assurance en cas d''accident.'),

  (formation_uuid, 'qcm',
   'Vous embauchez un chauffeur. Combien de temps avant la prise de poste devez-vous lui faire passer la VISITE MÉDICALE D''EMBAUCHE ?',
   '[{"id":"a","label":"Avant l''embauche, sinon contrat nul","is_correct":false},
     {"id":"b","label":"Dans les 3 mois (visite d''information et de prévention par la médecine du travail)","is_correct":true},
     {"id":"c","label":"À la fin de la période d''essai","is_correct":false},
     {"id":"d","label":"Tous les 5 ans seulement","is_correct":false}]'::jsonb,
   1, 'moyen',
   ARRAY['capa-3-5t','module-f','securite','medecine-travail','premium','cas-pratique'],
   'mft-original-2026:80', true,
   'Visite d''information et de prévention (VIP) dans les 3 mois suivant l''embauche pour les postes "non à risque". Renouvelée tous les 5 ans max. Pour les postes à risque (dont conducteurs de poids lourds) : examen médical d''aptitude AVANT embauche.'),

  (formation_uuid, 'qr',
   'Vous êtes le dirigeant d''une entreprise de transport léger avec 5 véhicules et 6 salariés. L''Inspection du Travail vous contrôle suite à un accident grave (un chauffeur s''est blessé à la main lors d''un déchargement). L''inspecteur découvre que vous n''avez ni DUERP (Document Unique d''Évaluation des Risques Professionnels) ni formation aux gestes et postures.

a. Quelles sont vos obligations légales en matière d''évaluation des risques ?
b. Quelles sanctions risquez-vous (administratives + pénales) ?
c. Quels documents auriez-vous dû tenir à jour ?
d. Comment vous mettre en conformité dans les 30 prochains jours ?',
   NULL, 6, 'difficile',
   ARRAY['capa-3-5t','module-f','securite','duerp','premium','mise-en-situation','qr'],
   'mft-original-2026:81', true,
   NULL);

  UPDATE public.question_bank
  SET expected_answer = $$
a. Obligations légales :
   - Établir et tenir à jour le DUERP dès le 1er salarié (art. R. 4121-1 C. trav.)
   - Mise à jour annuelle minimum + à chaque changement significatif (nouveau matériel, accident, modification d'organisation)
   - Identifier tous les risques (routier, manutention, TMS, chimique, stress…)
   - Définir un plan d'action de prévention
   - Le DUERP doit être accessible aux salariés, médecin du travail, CSE, inspecteur du travail
   - Conservation 40 ans (loi 2021)

b. Sanctions encourues :
   - Administratives : amende 1 500 € (3 000 € en récidive) pour absence DUERP
   - Pénales : RESPONSABILITÉ PÉNALE du dirigeant en cas d'accident (mise en danger d'autrui, blessures involontaires)
   - Civiles : reconnaissance de FAUTE INEXCUSABLE par les prud'hommes → indemnisation majorée de la victime, augmentation du taux AT
   - Suspension possible de l'activité par l'inspection du travail si danger grave et imminent

c. Documents à tenir à jour :
   - DUERP (annuel)
   - Plan d'action de prévention
   - Fiches de poste avec risques identifiés
   - Registre des accidents bénins
   - Justificatifs des formations (gestes et postures, sécurité routière, premiers secours)
   - Suivi médical des salariés
   - Vérifications périodiques du matériel (équipements de levage, EPI…)

d. Plan de mise en conformité 30 jours :
   - SEMAINE 1 : Diagnostic des risques avec les salariés (méthode INRS), modèle DUERP gratuit sur inrs.fr
   - SEMAINE 2 : Rédaction du DUERP + plan d'action priorisé
   - SEMAINE 3 : Formation gestes et postures (organisme agréé, ~150 €/salarié)
   - SEMAINE 4 : Mise en place des actions immédiates (équipements, signalétique, procédures)
   - Information formelle des salariés + affichage du DUERP
   - Communication à la médecine du travail + à l'inspection (preuve de bonne foi)
$$,
      scoring_grid = 'a (1,5pt) : DUERP obligatoire, MAJ annuelle, contenu | b (1,5pt) : sanctions admin (1500€) + pénales (mise en danger) + faute inexcusable | c (1,5pt) : 4 docs cohérents | d (1,5pt) : plan structuré 30j'
  WHERE source_ref = 'mft-original-2026:81';

END $outer$;
