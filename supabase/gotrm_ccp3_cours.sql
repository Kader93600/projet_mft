-- =====================================================================
-- COURS GOTRM CCP3 — Optimiser l'ensemble des moyens liés à l'activité
-- de transport
--
-- Généré depuis COURS_CCP3_GOTRM.pdf (43 pages, 12 chapitres, ~72 leçons)
--
-- Rattachement : formation GOTRM (slug) × bloc BC3
-- Idempotent : peut être rejoué (ON CONFLICT DO NOTHING / DO UPDATE)
-- =====================================================================

DO $$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_count_modules int := 0;
  v_count_lessons int := 0;
BEGIN
  -- 1) Récupère la formation GOTRM + bloc BC3
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable'; END IF;

  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC3';
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Bloc BC3 introuvable'; END IF;

  -- ═══════════════════════════════════════════════════════════════════
  -- CHAPITRE 1 — Management d'équipe et animation des conducteurs
  -- ═══════════════════════════════════════════════════════════════════
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp3-ch01-management-equipe-animation-conducteurs',
    'Chapitre 1 — Management d''équipe et animation des conducteurs',
    'CCP3 GOTRM · 7 leçons',
    'intermediaire', 90, 41)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 41, true)
  ON CONFLICT DO NOTHING;
  v_count_modules := v_count_modules + 1;

  INSERT INTO public.lessons (module_id, slug, title, content_md, "order") VALUES
  (v_module, '1-1-role-managerial-gestionnaire', '1.1 — Le rôle managérial du gestionnaire',
    '<p>En CCP3, le gestionnaire ne se contente plus de planifier et superviser les opérations. Il anime activement son équipe — conducteurs, exploitants, personnel de quai — pour maintenir la cohésion, la motivation et la performance collective. Le management est une compétence évaluée à l''examen.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>Animer une équipe = favoriser la cohésion et la motivation en tenant compte des aléas du service, des particularités individuelles et du programme QVCT de l''entreprise. Le gestionnaire est le premier niveau de management pour les conducteurs et le personnel d''exploitation.</p></blockquote>', 1),
  (v_module, '1-2-styles-de-management', '1.2 — Les styles de management',
    '<table><thead><tr><th>Style</th><th>Description</th><th>Quand l''utiliser</th></tr></thead><tbody><tr><td><strong>Directif</strong></td><td>Le gestionnaire donne des instructions précises, contrôle et décide seul</td><td>Urgence, aléa, conducteur novice</td></tr><tr><td><strong>Persuasif</strong></td><td>Le gestionnaire explique ses décisions et argumente pour convaincre</td><td>Changement de procédure, nouveau contexte</td></tr><tr><td><strong>Participatif</strong></td><td>Le gestionnaire consulte l''équipe avant de décider, favorise les échanges</td><td>Préparation d''un nouveau plan de transport, amélioration continue</td></tr><tr><td><strong>Délégatif</strong></td><td>Le gestionnaire fixe les objectifs et laisse l''équipe choisir les moyens</td><td>Profil expérimenté, tâches maîtrisées</td></tr></tbody></table>
<p>En pratique, un bon gestionnaire adapte son style selon la situation et le profil de chaque conducteur. La même personne peut recevoir un management directif en situation d''urgence et un management participatif en réunion d''équipe.</p>', 2),
  (v_module, '1-3-animer-reunions-equipe', '1.3 — Animer les réunions d''équipe',
    '<p>Les réunions d''équipe sont un outil essentiel du management. En service exploitation, elles permettent de partager les informations, de traiter les problèmes collectivement, de maintenir la cohésion et de favoriser l''adhésion aux objectifs de l''entreprise.</p>
<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📋 MÉTHODE — Conduire une réunion d''équipe</strong></p>
<p><strong>AVANT :</strong></p><ul><li>Définir l''objectif et l''ordre du jour</li><li>Convoquer avec un délai suffisant</li><li>Préparer les documents ou données nécessaires</li></ul>
<p><strong>PENDANT :</strong></p><ul><li>Ouvrir la réunion en rappelant l''objectif et la durée prévue</li><li>Assurer la parole à chacun — éviter les monopoles de parole</li><li>Rester centré sur l''ordre du jour</li><li>Recentrer en cas de dérive</li><li>Reformuler les décisions et les points de désaccord</li></ul>
<p><strong>APRÈS :</strong></p><ul><li>Rédiger et diffuser un compte-rendu avec les décisions prises et les actions à mener</li><li>Suivre les actions jusqu''à leur réalisation</li></ul></blockquote>', 3),
  (v_module, '1-4-mener-entretiens-individuels', '1.4 — Mener des entretiens individuels',
    '<p>L''entretien individuel est l''outil privilégié pour accompagner un conducteur dans son parcours professionnel, traiter un problème de comportement ou de performance, ou transmettre un feedback.</p>
<table><thead><tr><th>Type d''entretien</th><th>Objectif</th><th>Fréquence</th></tr></thead><tbody><tr><td>Entretien annuel d''évaluation</td><td>Faire le bilan de l''année — fixer les objectifs de l''année suivante — identifier les besoins de formation</td><td>Annuel</td></tr><tr><td>Entretien professionnel</td><td>Explorer les perspectives d''évolution professionnelle du salarié</td><td>Tous les 2 ans minimum (obligation légale)</td></tr><tr><td>Entretien de recadrage</td><td>Signaler un problème de comportement ou de performance — rappeler les règles</td><td>Dès qu''un problème est identifié</td></tr><tr><td>Entretien de retour d''absence</td><td>Accueillir un salarié revenant après une absence prolongée — faciliter la reprise</td><td>Au retour de toute absence > 1 mois</td></tr></tbody></table>', 4),
  (v_module, '1-5-sensibiliser-conducteurs', '1.5 — Sensibiliser les conducteurs',
    '<p>Le gestionnaire a un rôle de sensibilisation permanent auprès des conducteurs. C''est une compétence évaluée à l''examen.</p>
<ul><li><strong>Conduite rationnelle (Éco-conduite)</strong> : réduction de la consommation de carburant, meilleures pratiques sur route</li><li><strong>Qualité de service</strong> : importance de la relation client lors des livraisons, formulation des réserves, signalement des anomalies</li><li><strong>Satisfaction client</strong> : le conducteur est le représentant de l''entreprise sur le terrain — son comportement impacte directement l''image de l''entreprise</li><li><strong>Respect de la RSE</strong> : rappels réguliers sur les règles de temps de conduite et de repos, conséquences des infractions</li><li><strong>Sécurité et sûreté</strong> : règles de sécurité routière, procédures en cas d''accident, règles de sûreté du fret</li></ul>', 5),
  (v_module, '1-6-gestion-conflits', '1.6 — Gestion des conflits',
    '<p>Les conflits sont inévitables dans toute équipe. Le gestionnaire doit être capable de les identifier tôt, de les traiter avec méthode et d''en tirer des leçons pour l''avenir.</p>
<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📋 MÉTHODE — Gestion des conflits</strong></p>
<ol><li>IDENTIFIER le conflit — ne pas le laisser s''envenimer</li><li>COMPRENDRE les causes profondes (pas seulement les symptômes apparents)</li><li>ENTENDRE les deux parties séparément avant toute confrontation</li><li>RÉUNIR les parties dans un cadre structuré — rappeler les règles et les objectifs communs</li><li>TROUVER une solution acceptable pour les deux parties</li><li>FORMALISER l''accord — suivi dans le temps</li><li>Si le conflit dépasse le cadre de la délégation du gestionnaire : ALERTER LA HIÉRARCHIE</li></ol></blockquote>', 6),
  (v_module, '1-7-vocabulaire-chapitre-1', '1.7 — Vocabulaire essentiel du Chapitre 1',
    '<table><thead><tr><th>Terme</th><th>Définition</th></tr></thead><tbody><tr><td><strong>Management directif</strong></td><td>Style où le gestionnaire décide seul et donne des instructions précises — adapté à l''urgence</td></tr><tr><td><strong>Management participatif</strong></td><td>Style où le gestionnaire implique l''équipe dans les décisions — favorise l''adhésion</td></tr><tr><td><strong>QVCT</strong></td><td>Qualité de Vie et des Conditions de Travail — programme de l''entreprise visant le bien-être au travail</td></tr><tr><td><strong>Entretien d''évaluation</strong></td><td>Bilan annuel des objectifs et des performances d''un salarié</td></tr><tr><td><strong>Entretien professionnel</strong></td><td>Bilan bisannuel des perspectives d''évolution professionnelle — obligation légale</td></tr><tr><td><strong>Éco-conduite</strong></td><td>Comportements de conduite visant à réduire la consommation de carburant et les émissions</td></tr><tr><td><strong>Recadrage</strong></td><td>Signalement formel d''un problème de comportement ou de performance à un salarié</td></tr></tbody></table>', 7);
  v_count_lessons := v_count_lessons + 7;

  -- ═══════════════════════════════════════════════════════════════════
  -- CHAPITRE 2 — La convention collective des transports routiers
  -- ═══════════════════════════════════════════════════════════════════
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp3-ch02-convention-collective-transports-routiers',
    'Chapitre 2 — La convention collective des transports routiers',
    'CCP3 GOTRM · 7 leçons',
    'intermediaire', 90, 42)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 42, true) ON CONFLICT DO NOTHING;
  v_count_modules := v_count_modules + 1;

  INSERT INTO public.lessons (module_id, slug, title, content_md, "order") VALUES
  (v_module, '2-1-quest-ce-que-convention-collective', '2.1 — Qu''est-ce que la convention collective ?',
    '<p>La Convention Collective Nationale des Transports Routiers et Activités Auxiliaires (CCNTR) est un accord négocié entre les organisations patronales et les syndicats de salariés du secteur. Elle complète le Code du travail en définissant les conditions d''emploi, de travail et de rémunération spécifiques au transport routier.</p>
<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRÉ RÉGLEMENTATION</strong></p>
<ul><li>La CCNTR s''applique à toutes les entreprises dont l''activité principale relève des transports routiers de marchandises.</li><li>Elle est plus favorable que le Code du travail sur certains points — le plus favorable s''applique.</li><li>Des accords d''entreprise peuvent encore améliorer les conditions de la convention collective.</li><li>La CCNTR fixe notamment : les classifications des emplois, les salaires minima, les conditions de travail, les congés.</li></ul></blockquote>', 1),
  (v_module, '2-2-classification-conducteurs', '2.2 — La classification des conducteurs',
    '<p>La CCNTR classe le personnel roulant en groupes selon le PTAC du véhicule conduit. C''est le PTAC qui prime, mais d''autres critères peuvent élever un conducteur au groupe 7.</p>
<table><thead><tr><th>Groupe</th><th>Coefficient</th><th>Véhicule concerné</th></tr></thead><tbody><tr><td>Groupe 3</td><td>115M</td><td>Ouvrier accompagnant le conducteur</td></tr><tr><td>Groupe 3 bis</td><td>118M</td><td>Véhicule ≤ 3,5 t de PTAC (Giscard)</td></tr><tr><td>Groupe 4</td><td>120M</td><td>Véhicule de 3,5 t à 11 t de PTAC inclus</td></tr><tr><td>Groupe 5</td><td>128M</td><td>Véhicule de 11 t à 19 t de PTAC inclus</td></tr><tr><td>Groupe 6</td><td>138M</td><td>Véhicule de plus de 19 t de PTAC</td></tr><tr><td>Groupe 7</td><td>150M</td><td>Véhicule de plus de 19 t de PTAC + conditions supplémentaires</td></tr></tbody></table>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR — Classement Groupe 7 (coefficient 150M)</strong></p><p>Le conducteur doit obtenir AU MOINS 55 POINTS :</p>
<ul><li>Conduire un véhicule > 19 t de PTAC : 30 points (OBLIGATOIRE)</li><li>Parcourir au moins 250 km dans un sens : 20 points</li><li>Prendre au moins 30 repos hors domicile par 12 semaines : 15 points</li><li>Effectuer des services internationaux : 15 points</li><li>Conduire un ensemble articulé, train routier ou train double : 10 points</li><li>Posséder un diplôme de conducteur routier (CAP, BEP, FPA) : 10 points</li></ul></blockquote>', 2),
  (v_module, '2-3-categories-conducteurs', '2.3 — Les catégories de conducteurs',
    '<table><thead><tr><th>Catégorie</th><th>Définition</th><th>Durée légale hebdomadaire</th></tr></thead><tbody><tr><td>Grand routier / Longue distance</td><td>Prend moins de 6 repos journaliers à domicile par mois</td><td>43h (35h + 8h d''équivalence)</td></tr><tr><td>Conducteur messagerie</td><td>Affecté à des tournées régulières de messagerie avec contraintes de délais</td><td>35h (sans équivalence)</td></tr><tr><td>Convoyeur de fonds</td><td>Affecté au transport de fonds, bijoux ou métaux précieux</td><td>35h</td></tr><tr><td>Conducteur courte distance</td><td>Tout conducteur ne répondant pas aux 3 définitions précédentes</td><td>39h (35h + 4h d''équivalence)</td></tr></tbody></table>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>Les HEURES D''ÉQUIVALENCE sont des heures rémunérées compensant les périodes d''inactivité du conducteur (attentes au chargement/déchargement). Elles sont limitées à :</p><ul><li>8 heures pour les conducteurs longue distance</li><li>4 heures pour les conducteurs courte distance</li></ul><p>C''est pourquoi la durée légale de travail des conducteurs dépasse les 35 heures.</p></blockquote>', 3),
  (v_module, '2-4-smpg', '2.4 — Le salaire mensuel professionnel garanti (SMPG)',
    '<p>La rémunération des conducteurs ne peut pas être inférieure au Salaire Mensuel Professionnel Garanti (SMPG) fixé par la CCNTR pour chaque coefficient. Ce salaire est hors primes, hors indemnités conventionnelles et hors frais de déplacement.</p>
<p>Il existe un SMPG à l''embauche et des SMPG par tranche d''ancienneté. La convention collective prévoit des augmentations automatiques de salaire avec l''ancienneté dans l''entreprise.</p>', 4),
  (v_module, '2-5-heures-supplementaires', '2.5 — Les heures supplémentaires',
    '<table><thead><tr><th>Période</th><th>Par semaine</th><th>Par mois</th><th>Taux de majoration</th></tr></thead><tbody><tr><td>De la 36e à la 43e heure</td><td>De la 36e à la 43e h</td><td>De la 153e à la 186e h</td><td>25%</td></tr><tr><td>À partir de la 44e heure</td><td>À partir de la 44e h</td><td>À partir de la 187e h</td><td>50%</td></tr></tbody></table>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><ul><li>Contingent conventionnel d''heures supplémentaires : 195 heures par an.</li><li>Au-delà : autorisation de l''Inspection du travail requise (surcroît exceptionnel d''activité).</li><li>Les heures supplémentaires donnent droit à un repos compensateur en sus de la majoration salariale.</li></ul></blockquote>', 5),
  (v_module, '2-6-conges-jours-feries', '2.6 — Les congés et jours fériés',
    '<ul><li><strong>Congés payés</strong> : 2,5 jours ouvrables par mois de travail effectif (30 jours ouvrables = 5 semaines)</li><li><strong>Congé principal</strong> : 24 jours ouvrables continus entre le 1er juin et le 31 octobre (ou en 2 fractions 18+6 jours si l''exploitation l''exige)</li><li><strong>1er mai</strong> : obligatoirement chômé (dérogation possible pour les transports)</li><li>La CCNTR prévoit le chômage de 5 jours fériés choisis par l''employeur parmi les jours fériés légaux</li></ul>', 6),
  (v_module, '2-7-vocabulaire-chapitre-2', '2.7 — Vocabulaire essentiel du Chapitre 2',
    '<table><thead><tr><th>Terme</th><th>Définition</th></tr></thead><tbody><tr><td><strong>CCNTR</strong></td><td>Convention Collective Nationale des Transports Routiers — accord patronat/syndicats applicable au secteur</td></tr><tr><td><strong>SMPG</strong></td><td>Salaire Mensuel Professionnel Garanti — salaire minimal fixé par la CCNTR pour chaque coefficient</td></tr><tr><td><strong>Coefficient</strong></td><td>Niveau de classification du conducteur dans la CCNTR — détermine le salaire minimal</td></tr><tr><td><strong>Heures d''équivalence</strong></td><td>Heures rémunérées compensant les périodes d''inactivité — 8h (longue distance), 4h (courte distance)</td></tr><tr><td><strong>Heures supplémentaires</strong></td><td>Heures effectuées au-delà de la durée légale (incluant les heures d''équivalence)</td></tr><tr><td><strong>Contingent conventionnel</strong></td><td>Nombre maximal d''heures supplémentaires autorisé sans accord préalable : 195h/an</td></tr><tr><td><strong>Repos compensateur</strong></td><td>Repos additionnel dû au salarié en contrepartie des heures supplémentaires effectuées</td></tr><tr><td><strong>Grand routier</strong></td><td>Conducteur prenant moins de 6 repos journaliers à domicile par mois — coefficient 150M</td></tr></tbody></table>', 7);
  v_count_lessons := v_count_lessons + 7;

  -- ═══════════════════════════════════════════════════════════════════
  -- CHAPITRE 3 — Les temps de service et leur décompte
  -- ═══════════════════════════════════════════════════════════════════
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp3-ch03-temps-service-decompte',
    'Chapitre 3 — Les temps de service et leur décompte',
    'CCP3 GOTRM · 6 leçons',
    'intermediaire', 80, 43)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 43, true) ON CONFLICT DO NOTHING;
  v_count_modules := v_count_modules + 1;

  INSERT INTO public.lessons (module_id, slug, title, content_md, "order") VALUES
  (v_module, '3-1-pourquoi-decompter-temps-service', '3.1 — Pourquoi décompter les temps de service ?',
    '<p>Le décompte régulier des temps de service est une obligation légale et une nécessité pratique. Il permet de vérifier que les conducteurs ne dépassent pas les seuils légaux, de préparer les éléments variables de la paie, et d''anticiper les besoins en personnel pour les semaines à venir.</p>
<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRÉ RÉGLEMENTATION</strong></p>
<ul><li>L''employeur est tenu de tenir un registre du temps de travail des conducteurs.</li><li>Les données tachygraphe doivent être archivées pendant au moins 1 an.</li><li>Le gestionnaire doit réajuster l''activité afin de ne pas dépasser les seuils autorisés.</li></ul></blockquote>', 1),
  (v_module, '3-2-durees-maximales-par-categorie', '3.2 — Rappel des durées maximales selon la catégorie',
    '<table><thead><tr><th>Catégorie</th><th>Durée légale</th><th>Maxi semaine isolée</th><th>Maxi en moyenne</th></tr></thead><tbody><tr><td>Grand routier / longue distance</td><td>43h</td><td>56h</td><td>53h</td></tr><tr><td>Conducteur messagerie</td><td>35h</td><td>48h</td><td>44h</td></tr><tr><td>Conducteur courte distance</td><td>39h</td><td>52h</td><td>50h</td></tr></tbody></table>', 2),
  (v_module, '3-3-extraire-analyser-tachygraphe', '3.3 — Extraire et analyser les données tachygraphe',
    '<p>Le tachygraphe numérique enregistre en temps réel toutes les activités du conducteur. Le gestionnaire extrait ces données via un logiciel dédié pour les analyser et préparer la paie.</p>
<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📋 MÉTHODE — Analyse des données tachygraphe</strong></p>
<p><strong>DONNÉES EXTRAITES DU TACHYGRAPHE :</strong></p>
<ul><li>Temps de conduite (TC) : périodes où le conducteur est au volant</li><li>Temps d''autres travaux (AT) : chargement, déchargement, tâches administratives...</li><li>Temps de disponibilité (D) : attentes à l''arrêt à disposition de l''employeur</li><li>Temps de repos et pauses (R) : périodes de repos et pauses</li><li>Vitesses, positions, incidents</li></ul>
<p><strong>TEMPS DE SERVICE = TC + AT + D</strong> (sans les repos et pauses)</p>
<p><strong>PÉRIODICITÉ DES EXTRACTIONS :</strong></p>
<ul><li>Quotidienne (via TMS) : suivi en temps réel</li><li>Hebdomadaire : vérification des cumuls et anticipation des dépassements</li><li>Mensuelle : préparation des éléments de paie</li></ul></blockquote>', 3),
  (v_module, '3-4-calcul-bonus-amplitude', '3.4 — Le calcul du bonus d''amplitude pour les grands routiers',
    '<p>Pour les conducteurs grands routiers (longue distance), la CCNTR prévoit une garantie minimale de rémunération liée à l''amplitude des journées de travail. Le gestionnaire doit calculer cette garantie chaque mois.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>Le salaire à payer correspond au PLUS GRAND des trois calculs suivants :</p>
<ol><li>Temps de service effectif mensuel</li><li>75% × amplitude cumulée du mois</li><li>Amplitude cumulée du mois - 63 heures</li></ol>
<p>Si l''un des calculs 2 ou 3 dépasse le calcul 1 : l''écart constitue le BONUS D''AMPLITUDE à payer en supplément.</p></blockquote>
<blockquote data-callout="exemple" style="border-left:4px solid #DC2626;background:#FEF2F2;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📊 EXEMPLE — Calcul bonus d''amplitude — Conducteur MORETTI (Grand routier)</strong></p>
<p><strong>Mois de novembre :</strong></p>
<ul><li>Temps de service effectif mensuel = 201 heures</li><li>Amplitude cumulée mensuelle = 270 heures</li></ul>
<ul><li>Calcul 1 : 201 h</li><li>Calcul 2 : 75% × 270 = 202,5 h</li><li>Calcul 3 : 270 - 63 = 207 h</li></ul>
<p><strong>Maximum = 207 h</strong></p>
<p><strong>Bonus d''amplitude = 207 - 201 = 6 heures supplémentaires à rémunérer</strong></p></blockquote>', 4),
  (v_module, '3-5-repos-compensateurs', '3.5 — Les repos compensateurs',
    '<p>Les repos compensateurs sont dus au salarié en contrepartie des heures supplémentaires. Le gestionnaire doit en tenir un suivi rigoureux pour planifier leur prise sans perturber l''activité.</p>
<table><thead><tr><th>Catégorie d''heure</th><th>Repos compensateur obligatoire</th></tr></thead><tbody><tr><td>Heures supplémentaires de la 36e à la 43e h (dans une entreprise ≥ 20 salariés)</td><td>50% du temps effectué</td></tr><tr><td>Heures supplémentaires au-delà de la 44e h</td><td>100% du temps effectué</td></tr><tr><td>Heures de nuit (si ≥ 50h de nuit dans le mois)</td><td>5% des heures de nuit du mois</td></tr></tbody></table>', 5),
  (v_module, '3-6-vocabulaire-chapitre-3', '3.6 — Vocabulaire essentiel du Chapitre 3',
    '<table><thead><tr><th>Terme</th><th>Définition</th></tr></thead><tbody><tr><td><strong>Amplitude</strong></td><td>Heure de fin de service - heure de prise de service (inclut les pauses et repos)</td></tr><tr><td><strong>Bonus d''amplitude</strong></td><td>Heures de rémunération supplémentaire dues aux grands routiers quand l''amplitude dépasse le temps de service</td></tr><tr><td><strong>Extraction tachygraphe</strong></td><td>Opération consistant à télécharger les données du tachygraphe numérique pour analyse</td></tr><tr><td><strong>Repos compensateur</strong></td><td>Repos additionnel dû au salarié en contrepartie des heures supplémentaires</td></tr><tr><td><strong>Décompte mensuel</strong></td><td>Calcul du temps de service total effectué par un conducteur sur le mois</td></tr><tr><td><strong>Seuil légal</strong></td><td>Valeur maximale d''un indicateur au-delà de laquelle une action corrective est obligatoire</td></tr></tbody></table>', 6);
  v_count_lessons := v_count_lessons + 6;

  -- ═══════════════════════════════════════════════════════════════════
  -- CHAPITRE 4 — La prépaie des conducteurs
  -- ═══════════════════════════════════════════════════════════════════
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp3-ch04-prepaie-conducteurs',
    'Chapitre 4 — La prépaie des conducteurs',
    'CCP3 GOTRM · 5 leçons',
    'intermediaire', 75, 44)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 44, true) ON CONFLICT DO NOTHING;
  v_count_modules := v_count_modules + 1;

  INSERT INTO public.lessons (module_id, slug, title, content_md, "order") VALUES
  (v_module, '4-1-quest-ce-que-prepaie', '4.1 — Qu''est-ce que la prépaie ?',
    '<p>La prépaie (ou pré-paye) est l''ensemble des calculs préparatoires effectués par le gestionnaire pour établir les éléments variables du bulletin de salaire des conducteurs. Ces éléments sont transmis au service comptabilité ou ressources humaines qui établit le bulletin définitif.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR — Le gestionnaire GOTRM peut être amené à calculer :</strong></p>
<ul><li>Les heures de temps de service (régulières et supplémentaires)</li><li>Les heures de nuit et la prime de nuit correspondante</li><li>Le bonus d''amplitude (grands routiers)</li><li>Les frais de déplacements (repas, hébergement)</li><li>Les primes diverses (qualité, ancienneté, conduite rationnelle...)</li><li>Les repos compensateurs acquis et pris</li></ul></blockquote>', 1),
  (v_module, '4-2-remuneration-travail-nuit', '4.2 — La rémunération du travail de nuit',
    '<p>Le travail de nuit est la période entre 22h et 5h du matin pour les conducteurs. Il donne lieu à des contreparties spécifiques.</p>
<table><thead><tr><th>Contrepartie</th><th>Calcul</th><th>Bénéficiaires</th></tr></thead><tbody><tr><td>Prime de nuit</td><td>20% du taux horaire conventionnel à l''embauche du Coeff. 150M × heures de nuit</td><td>Tous les conducteurs travaillant entre 21h et 6h</td></tr><tr><td>Repos compensateur de nuit</td><td>5% des heures de nuit du mois</td><td>Conducteurs effectuant ≥ 50h de nuit dans le mois</td></tr><tr><td>Plafond horaire</td><td>Max 10h de travail par journée en cas de travail de nuit</td><td>Conducteurs roulants travaillant de nuit</td></tr></tbody></table>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR — CALCUL DU TAUX HORAIRE REVALORISÉ</strong> (pour les heures supplémentaires d''un conducteur de nuit) :</p>
<p><strong>Taux horaire = (152h × taux horaire normal + prime de nuit mensuelle) / 152h</strong></p>
<ul><li>Exemple : taux horaire normal 10,39 € — prime de nuit du mois = 51,95 €</li><li>Taux revalorisé = (152 × 10,39 + 51,95) / 152 = 10,73 €</li><li>Heure supplémentaire majorée à 50% = 10,73 × 1,50 = 16,10 €</li></ul></blockquote>', 2),
  (v_module, '4-3-frais-deplacement', '4.3 — Les frais de déplacement',
    '<p>Les conducteurs qui passent la nuit hors de leur domicile ont droit à des indemnités de déplacement (frais de repas, frais d''hébergement) selon des barèmes définis par la CCNTR.</p>
<ul><li><strong>Repas</strong> : indemnité forfaitaire pour chaque repas pris hors domicile</li><li><strong>Hébergement</strong> : indemnité forfaitaire pour chaque nuit passée hors domicile</li><li>Les montants sont fixés par la convention collective et révisés périodiquement</li><li>Ces indemnités ne sont pas soumises à cotisations sociales dans certaines limites</li></ul>', 3),
  (v_module, '4-4-structure-bulletin-salaire', '4.4 — Structure d''un bulletin de salaire de conducteur',
    '<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📋 STRUCTURE — Bulletin de salaire conducteur</strong></p>
<p><strong>PARTIE FIXE :</strong></p>
<ul><li>Identification employeur et salarié</li><li>Période de paie</li><li>Qualification et coefficient</li><li>Nombre d''heures de base et taux horaire</li><li>Salaire de base (SMPG minimum)</li></ul>
<p><strong>ÉLÉMENTS VARIABLES CALCULÉS PAR LE GESTIONNAIRE :</strong></p>
<ul><li>Heures supplémentaires (25% de la 36e à la 43e h, 50% au-delà)</li><li>Heures de nuit et prime de nuit correspondante</li><li>Bonus d''amplitude (grands routiers uniquement)</li><li>Primes conventionnelles (ancienneté, qualité...)</li><li>Indemnités de déplacement (repas, hébergement)</li><li>Repos compensateurs pris ou à prendre</li></ul>
<p><strong>ÉLÉMENTS DÉDUCTIBLES :</strong></p>
<ul><li>Cotisations sociales salariales (sécurité sociale, retraite, chômage...)</li><li>Avances sur salaire si applicable</li></ul>
<p><strong>RÉSULTAT :</strong> Net à payer</p></blockquote>
<blockquote data-callout="exemple" style="border-left:4px solid #DC2626;background:#FEF2F2;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📊 EXEMPLE — Calcul éléments de prépaie — Conducteur FERNANDES (Grand routier, Coeff 150M)</strong></p>
<p><strong>Mois d''octobre :</strong></p>
<ul><li>Temps de service effectif : 195 heures (dont 40h de nuit)</li><li>Amplitude cumulée : 250 heures</li><li>Taux horaire conventionnel Coeff 150M : 10,39 €</li></ul>
<p><strong>1. HEURES SUPPLÉMENTAIRES :</strong></p>
<ul><li>Base légale grand routier : 43h/semaine soit 186h/mois</li><li>HS de la 153e à la 186e h : 34h × 10,39 × 1,25 = 441,58 €</li><li>HS au-delà de la 186e h : (195-186) = 9h × 10,39 × 1,50 = 140,27 €</li></ul>
<p><strong>2. PRIME DE NUIT :</strong> 40h × (10,39 × 20%) = 40 × 2,078 = 83,12 €</p>
<p><strong>3. BONUS D''AMPLITUDE :</strong></p>
<ul><li>Calcul 1: 195h | Calcul 2: 75% × 250 = 187,5h | Calcul 3: 250-63 = 187h</li><li>Maximum = 195h (Calcul 1) → Pas de bonus d''amplitude</li></ul></blockquote>', 4),
  (v_module, '4-5-vocabulaire-chapitre-4', '4.5 — Vocabulaire essentiel du Chapitre 4',
    '<table><thead><tr><th>Terme</th><th>Définition</th></tr></thead><tbody><tr><td><strong>Prépaie</strong></td><td>Calculs préparatoires des éléments variables du bulletin de salaire — effectués par le gestionnaire</td></tr><tr><td><strong>Prime de nuit</strong></td><td>Compensation financière de 20% du taux horaire Coeff 150M pour les heures travaillées entre 21h et 6h</td></tr><tr><td><strong>Bonus d''amplitude</strong></td><td>Heures supplémentaires dues aux grands routiers quand l''amplitude dépasse le temps de service</td></tr><tr><td><strong>Frais de déplacement</strong></td><td>Indemnités conventionnelles pour les repas et hébergements lors des déplacements hors domicile</td></tr><tr><td><strong>Taux horaire revalorisé</strong></td><td>Taux horaire normal augmenté de la part de prime de nuit — base de calcul des HS nocturnes</td></tr><tr><td><strong>Net à payer</strong></td><td>Rémunération totale moins les cotisations sociales salariales — montant versé sur le compte du salarié</td></tr></tbody></table>', 5);
  v_count_lessons := v_count_lessons + 5;

  -- ═══════════════════════════════════════════════════════════════════
  -- CHAPITRE 5 — La formation professionnelle et les qualifications
  -- ═══════════════════════════════════════════════════════════════════
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp3-ch05-formation-professionnelle-qualifications',
    'Chapitre 5 — La formation professionnelle et les qualifications',
    'CCP3 GOTRM · 6 leçons',
    'intermediaire', 75, 45)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 45, true) ON CONFLICT DO NOTHING;
  v_count_modules := v_count_modules + 1;

  INSERT INTO public.lessons (module_id, slug, title, content_md, "order") VALUES
  (v_module, '5-1-obligations-formation', '5.1 — Les obligations de formation en transport routier',
    '<p>Le secteur du transport routier est l''un des secteurs les plus réglementés en matière de formation professionnelle. Plusieurs formations sont obligatoires pour les conducteurs et doivent être organisées et planifiées par le gestionnaire.</p>', 1),
  (v_module, '5-2-fimo-fco', '5.2 — La FIMO et la FCO',
    '<table><thead><tr><th>Formation</th><th>Durée</th><th>Public</th><th>Financement</th><th>Périodicité</th></tr></thead><tbody><tr><td>FIMO (Formation Initiale Minimale Obligatoire)</td><td>140 heures (4 semaines)</td><td>Tout nouveau conducteur professionnel</td><td>À la charge du candidat (sauf prise en charge entreprise)</td><td>Une seule fois en début de carrière</td></tr><tr><td>FCO (Formation Continue Obligatoire)</td><td>35 heures (5 jours)</td><td>Tout conducteur professionnel en activité</td><td>À LA CHARGE DE L''ENTREPRISE — sur temps de travail</td><td>Tous les 5 ans</td></tr></tbody></table>
<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRÉ RÉGLEMENTATION</strong></p>
<ul><li>Le financement de la FCO est à la charge de l''entreprise — obligation légale.</li><li>Le stage doit être organisé sur le temps de travail.</li><li>L''entreprise peut conclure une clause de dédit-formation avec le conducteur pour se protéger en cas de départ rapide après la FCO (remboursement de tout ou partie des frais).</li></ul></blockquote>', 2),
  (v_module, '5-3-planifier-formations', '5.3 — Planifier les formations réglementaires obligatoires',
    '<p>Le gestionnaire doit maintenir un tableau de bord des qualifications de tous les conducteurs pour anticiper les échéances de renouvellement et planifier les formations sans perturber l''exploitation.</p>
<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📋 TABLEAU DE BORD QUALIFICATIONS À TENIR À JOUR — Pour chaque conducteur :</strong></p>
<ul><li>Nom, prénom, date d''entrée dans l''entreprise</li><li>Type de permis (C, CE, C1, C1E) + date d''expiration</li><li>CQC (Carte de Qualification Conducteur) + date d''expiration</li><li>Date de la dernière FCO + date de la prochaine FCO (J + 5 ans)</li><li>Certificat ADR si applicable + date d''expiration</li><li>Carte conducteur (tachygraphe) + date d''expiration</li><li>Aptitude médicale + date de la prochaine visite médicale</li><li>Toute autre habilitation spécifique (transport de fonds, animaux, matières dangereuses...)</li></ul></blockquote>', 3),
  (v_module, '5-4-aptitude-medicale', '5.4 — L''aptitude médicale',
    '<p>Tous les conducteurs professionnels doivent passer une visite médicale auprès d''un médecin agréé pour conserver leur permis de conduire.</p>
<table><thead><tr><th>Âge du conducteur</th><th>Périodicité de la visite médicale</th></tr></thead><tbody><tr><td>Moins de 60 ans</td><td>Tous les 5 ans</td></tr><tr><td>60 à 75 ans</td><td>Tous les 2 ans</td></tr><tr><td>76 ans et plus</td><td>Chaque année</td></tr></tbody></table>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p>
<ul><li>La sécurité sociale ne rembourse pas la visite médicale.</li><li>La CCNTR prévoit la prise en charge de ces frais par l''entreprise.</li><li>Si le permis est expiré en attente de visite médicale : le conducteur ne peut PAS conduire.</li></ul></blockquote>', 4),
  (v_module, '5-5-plan-formation', '5.5 — Le plan de formation',
    '<p>Au-delà des formations réglementaires, le gestionnaire peut proposer à sa hiérarchie un plan de formation visant le développement des compétences de son équipe.</p>
<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📋 PLAN DE FORMATION — TYPES DE FORMATIONS NON-RÉGLEMENTAIRES UTILES EN TRANSPORT :</strong></p>
<p><strong>SÉCURITÉ ET TECHNIQUE :</strong></p>
<ul><li>Éco-conduite (conduite rationnelle) : réduction carburant, émission CO2</li><li>Techniques d''arrimage et de sécurisation des charges</li><li>Maniement du tachygraphe et saisie correcte des activités</li></ul>
<p><strong>QUALITÉ DE SERVICE :</strong></p>
<ul><li>Relation client lors des livraisons</li><li>Gestion des réclamations et des réserves</li><li>Communication professionnelle</li></ul>
<p><strong>MANAGEMENT (pour les gestionnaires eux-mêmes) :</strong></p>
<ul><li>Techniques d''animation d''équipe</li><li>Gestion des conflits</li><li>Conduite d''entretien</li></ul>
<p><strong>NUMÉRIQUE :</strong></p>
<ul><li>Utilisation du TMS</li><li>Géolocalisation et traçabilité</li><li>Sécurité des données (recommandations ANSSI)</li></ul></blockquote>', 5),
  (v_module, '5-6-vocabulaire-chapitre-5', '5.6 — Vocabulaire essentiel du Chapitre 5',
    '<table><thead><tr><th>Terme</th><th>Définition</th></tr></thead><tbody><tr><td><strong>FIMO</strong></td><td>Formation Initiale Minimale Obligatoire — 140h — une seule fois en début de carrière</td></tr><tr><td><strong>FCO</strong></td><td>Formation Continue Obligatoire — 35h tous les 5 ans — à la charge de l''entreprise</td></tr><tr><td><strong>CQC</strong></td><td>Carte de Qualification Conducteur — délivrée après FIMO ou FCO — renouvellement 5 ans</td></tr><tr><td><strong>Aptitude médicale</strong></td><td>Examen médical périodique conditionnant la validité du permis de conduire</td></tr><tr><td><strong>Médecin agréé</strong></td><td>Médecin habilité à délivrer l''attestation d''aptitude médicale pour les conducteurs</td></tr><tr><td><strong>Dédit-formation</strong></td><td>Clause contractuelle obligeant le salarié à rembourser les frais de formation en cas de départ rapide</td></tr><tr><td><strong>Plan de formation</strong></td><td>Document planifiant les formations prévues pour les salariés sur une période donnée</td></tr></tbody></table>', 6);
  v_count_lessons := v_count_lessons + 6;

  -- ═══════════════════════════════════════════════════════════════════
  -- CHAPITRE 6 — Le recrutement et la gestion des compétences
  -- ═══════════════════════════════════════════════════════════════════
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp3-ch06-recrutement-gestion-competences',
    'Chapitre 6 — Le recrutement et la gestion des compétences',
    'CCP3 GOTRM · 6 leçons',
    'intermediaire', 80, 46)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 46, true) ON CONFLICT DO NOTHING;
  v_count_modules := v_count_modules + 1;

  INSERT INTO public.lessons (module_id, slug, title, content_md, "order") VALUES
  (v_module, '6-1-anticiper-besoins-recrutement', '6.1 — Anticiper les besoins de recrutement',
    '<p>Le gestionnaire doit être capable d''identifier en amont les situations qui nécessiteront un recrutement : départs en retraite prévus, accroissement d''activité, non-renouvellement d''un contrat temporaire, ouverture d''un nouveau trafic. Ces besoins doivent être anticipés et transmis à la hiérarchie avec un délai suffisant.</p>
<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📋 SIGNAUX D''ALERTE — Recrutement à anticiper</strong></p>
<p><strong>INDICATEURS DÉCLENCHANT UN BESOIN DE RECRUTEMENT :</strong></p>
<ul><li>Départ en retraite d''un conducteur (à anticiper 3 à 6 mois avant)</li><li>Accroissement permanent du volume d''activité (nouveaux trafics, nouveaux clients)</li><li>Remplacement définitif d''un poste suite à une rupture de contrat</li><li>Ouverture d''une nouvelle ligne de traction ou d''une nouvelle tournée</li><li>Taux de recours à l''intérim trop élevé sur une durée prolongée</li></ul></blockquote>', 1),
  (v_module, '6-2-types-contrats-travail', '6.2 — Les types de contrats de travail',
    '<table><thead><tr><th>Type de contrat</th><th>Description</th><th>Usage en transport</th></tr></thead><tbody><tr><td>CDI (Contrat à Durée Indéterminée)</td><td>Contrat sans terme fixe — le plus stable pour le salarié</td><td>Conducteurs et exploitants permanents</td></tr><tr><td>CDD (Contrat à Durée Déterminée)</td><td>Contrat avec date de fin — motif obligatoire (accroissement, remplacement...)</td><td>Remplacement arrêt maladie, surcroît saisonnier</td></tr><tr><td>Intérim</td><td>Recours à une agence d''emploi temporaire — contrat de mission</td><td>Besoins ponctuels ou urgents — conducteur remplaçant</td></tr><tr><td>Contrat de professionnalisation</td><td>Alternance entre formation et travail — salarié en formation</td><td>Intégration de jeunes conducteurs en FIMO</td></tr><tr><td>Apprentissage</td><td>Alternance avec centre de formation — pour les moins de 30 ans</td><td>Jeunes conducteurs en formation initiale</td></tr></tbody></table>', 2),
  (v_module, '6-3-participer-recrutement', '6.3 — Participer au processus de recrutement',
    '<p>Le gestionnaire contribue au recrutement en définissant le profil recherché, en participant à la sélection des candidats et en accueillant les nouvelles recrues.</p>
<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📋 CRITÈRES DE SÉLECTION — Conducteur</strong></p>
<p><strong>OBLIGATOIRES :</strong></p>
<ul><li>Permis de conduire valide et adapté (C ou CE selon les véhicules)</li><li>CQC (FIMO) à jour</li><li>Carte conducteur valide</li><li>Aptitude médicale en cours de validité</li><li>Certificat ADR si nécessaire pour les trafics</li></ul>
<p><strong>PRIVILÉGIÉS :</strong></p>
<ul><li>Ancienneté dans le métier</li><li>Expérience sur des types de trafics similaires</li><li>Connaissance du secteur géographique</li><li>Comportement commercial (attitude cliente)</li><li>Bonne conduite (historique accidents, infractions)</li></ul></blockquote>', 3),
  (v_module, '6-4-accueil-integration', '6.4 — L''accueil et l''intégration d''un nouveau conducteur',
    '<p>Un nouveau conducteur bien accueilli et bien intégré est un conducteur qui reste. La période d''intégration est cruciale pour sa fidélisation.</p>
<ul><li>Remise des documents : contrat de travail, fiche de poste, règlement intérieur</li><li>Présentation de l''entreprise, des locaux, des collègues et de la hiérarchie</li><li>Formation aux outils : TMS, tachygraphe, procédures internes</li><li>Présentation du parc et des véhicules affectés</li><li>Accompagnement lors des premières tournées</li><li>Suivi pendant la période d''essai — entretiens réguliers</li></ul>', 4),
  (v_module, '6-5-irp', '6.5 — Les institutions représentatives du personnel (IRP)',
    '<p>Le gestionnaire doit connaître les institutions représentatives du personnel dans l''entreprise et savoir comment interagir avec elles de manière constructive.</p>
<table><thead><tr><th>Institution</th><th>Rôle</th><th>Composition</th></tr></thead><tbody><tr><td>CSE (Comité Social et Économique)</td><td>Regroupe les missions du CE, des DP et du CHSCT — représentation des salariés, consultation sur les décisions</td><td>Membres élus par les salariés selon l''effectif</td></tr><tr><td>Délégué syndical</td><td>Négocie les accords d''entreprise avec la direction</td><td>Désigné par les organisations syndicales représentatives</td></tr><tr><td>Référent harcèlement</td><td>Point de contact pour les salariés en situation de harcèlement</td><td>Membre du CSE</td></tr></tbody></table>', 5),
  (v_module, '6-6-vocabulaire-chapitre-6', '6.6 — Vocabulaire essentiel du Chapitre 6',
    '<table><thead><tr><th>Terme</th><th>Définition</th></tr></thead><tbody><tr><td><strong>CDI</strong></td><td>Contrat à Durée Indéterminée — contrat de droit commun sans terme fixe</td></tr><tr><td><strong>CDD</strong></td><td>Contrat à Durée Déterminée — nécessite un motif légal (remplacement, surcroît)</td></tr><tr><td><strong>Intérim</strong></td><td>Mise à disposition de main-d''œuvre via une agence — pas de lien direct de subordination</td></tr><tr><td><strong>CSE</strong></td><td>Comité Social et Économique — institution représentant les salariés dans les entreprises ≥ 11 salariés</td></tr><tr><td><strong>Période d''essai</strong></td><td>Période initiale du contrat permettant à chaque partie de vérifier l''adéquation du poste</td></tr><tr><td><strong>Accord d''entreprise</strong></td><td>Accord négocié entre la direction et les syndicats dans l''entreprise — peut aller au-delà de la CCNTR</td></tr><tr><td><strong>Fiche de poste</strong></td><td>Document décrivant les missions, responsabilités et compétences requises pour un emploi</td></tr></tbody></table>', 6);
  v_count_lessons := v_count_lessons + 6;

  -- ═══════════════════════════════════════════════════════════════════
  -- CHAPITRE 7 — La QVCT, le handicap et les risques psychosociaux
  -- ═══════════════════════════════════════════════════════════════════
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp3-ch07-qvct-handicap-rps',
    'Chapitre 7 — La QVCT, le handicap et les risques psychosociaux',
    'CCP3 GOTRM · 5 leçons',
    'intermediaire', 75, 47)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 47, true) ON CONFLICT DO NOTHING;
  v_count_modules := v_count_modules + 1;

  INSERT INTO public.lessons (module_id, slug, title, content_md, "order") VALUES
  (v_module, '7-1-qvct', '7.1 — La Qualité de Vie et des Conditions de Travail (QVCT)',
    '<p>La QVCT (Qualité de Vie et des Conditions de Travail) est un ensemble d''actions et de mesures visant à améliorer le bien-être au travail des salariés. Elle est codifiée par le Code du travail et fait l''objet de dispositions spécifiques dans la CCNTR.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p>
<ul><li>La QVCT est une COMPÉTENCE ÉVALUÉE À L''EXAMEN CCP3.</li><li>Le gestionnaire est l''acteur de première ligne de la QVCT de son équipe.</li><li>Il applique et met en œuvre les dispositions prévues par l''entreprise en matière de QVCT.</li></ul></blockquote>
<p>Les axes d''une démarche QVCT en transport routier :</p>
<ul><li><strong>Organisation du travail</strong> : réduction des horaires atypiques, planification qui respecte la vie personnelle</li><li><strong>Relations au travail</strong> : culture du respect mutuel, tolérance zéro harcèlement</li><li><strong>Santé et sécurité</strong> : prévention des accidents, réduction des TMS (troubles musculosquelettiques)</li><li><strong>Parcours professionnel</strong> : formation, évolution, valorisation des compétences</li><li><strong>Conciliation vie professionnelle / vie personnelle</strong> : gestion prévisionnelle des plannings</li></ul>', 1),
  (v_module, '7-2-gestion-handicap', '7.2 — La gestion des situations de handicap',
    '<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRÉ RÉGLEMENTATION</strong></p>
<p>Le référentiel impose <strong>EXPLICITEMENT</strong> au gestionnaire de prendre en compte les situations de handicap dans l''élaboration des actions de formation et dans les affectations (cf. CCP1 Ch.7).</p>
<p><strong>L''AMÉNAGEMENT RAISONNABLE</strong> (tel que défini par le Défenseur des droits) : Toute modification nécessaire et appropriée apportée, en fonction des besoins dans une situation donnée, pour permettre à une personne handicapée de jouir de tous les droits et libertés fondamentaux.</p>
<p><strong>En pratique pour le gestionnaire :</strong></p>
<ul><li>Adapter les horaires si nécessaire</li><li>Affecter le conducteur à un véhicule adapté à sa situation</li><li>Proposer des formations accessibles (locaux, supports)</li><li>Planifier les absences liées au handicap avec anticipation</li><li>Travailler avec la médecine du travail et les RH</li></ul></blockquote>', 2),
  (v_module, '7-3-rps', '7.3 — Les risques psychosociaux (RPS)',
    '<p>Les risques psychosociaux désignent les risques professionnels d''origine et de nature psychosociale qui menacent l''intégrité physique et mentale des salariés. En transport routier, les conducteurs sont particulièrement exposés.</p>
<table><thead><tr><th>Facteur de RPS</th><th>Manifestations en transport</th></tr></thead><tbody><tr><td>Intensité et durée du travail</td><td>Horaires décalés, nuits, semaines longues, pression des délais</td></tr><tr><td>Exigences émotionnelles</td><td>Gestion de la clientèle, conduite en milieu urbain dense, litiges</td></tr><tr><td>Manque d''autonomie</td><td>Instructions rigides, peu de latitude dans les décisions</td></tr><tr><td>Mauvaise qualité des relations</td><td>Isolement du conducteur, relations tendues avec l''encadrement</td></tr><tr><td>Conflits de valeur</td><td>Instructions contradictoires avec la sécurité ou la RSE</td></tr><tr><td>Insécurité de la situation de travail</td><td>Précarité, CDD, menace de restructuration</td></tr></tbody></table>
<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📋 SIGNAUX D''ALERTE RPS ET CONDUITE À TENIR</strong></p>
<p><strong>SIGNAUX D''ALERTE RPS À SURVEILLER :</strong></p>
<ul><li>Absentéisme en hausse pour un conducteur</li><li>Changement de comportement (agressivité, repli sur soi, perte de motivation)</li><li>Erreurs ou incidents inhabituels</li><li>Plaintes récurrentes sur les conditions de travail</li><li>Tensions persistantes dans l''équipe</li></ul>
<p><strong>QUE FAIRE ?</strong></p>
<ol><li>Engager un entretien individuel discret</li><li>Écouter sans juger</li><li>Orienter vers le service RH ou la médecine du travail si nécessaire</li><li>Alerter la hiérarchie si situation grave ou dépassant le cadre d''intervention du gestionnaire</li></ol></blockquote>', 3),
  (v_module, '7-4-sante-securite-travail', '7.4 — La santé et la sécurité au travail',
    '<p>Le gestionnaire contribue à la prévention des risques professionnels dans son périmètre :</p>
<ul><li>Appliquer et faire appliquer les règles de sécurité : port des EPI, respect des procédures, interdiction de l''alcool et des drogues au volant</li><li>Surveiller le taux d''accidentologie par conducteur pour proposer des formations adéquates</li><li>Signaler tout risque identifié au service prévention ou à la hiérarchie</li><li>Participer à l''analyse des accidents et incidents pour en tirer les leçons</li></ul>', 4),
  (v_module, '7-5-vocabulaire-chapitre-7', '7.5 — Vocabulaire essentiel du Chapitre 7',
    '<table><thead><tr><th>Terme</th><th>Définition</th></tr></thead><tbody><tr><td><strong>QVCT</strong></td><td>Qualité de Vie et des Conditions de Travail — programme de bien-être au travail</td></tr><tr><td><strong>Risques psychosociaux (RPS)</strong></td><td>Risques professionnels d''origine psychosociale : burn-out, harcèlement, stress chronique...</td></tr><tr><td><strong>Aménagement raisonnable</strong></td><td>Modification des conditions de travail pour permettre à une personne handicapée d''exercer son emploi</td></tr><tr><td><strong>TMS</strong></td><td>Troubles Musculosquelettiques — pathologies liées aux postures de travail et gestes répétitifs</td></tr><tr><td><strong>Burn-out</strong></td><td>Épuisement professionnel sévère — surcharge de travail prolongée</td></tr><tr><td><strong>Harcèlement moral</strong></td><td>Agissements répétés dégradant les conditions de travail d''un salarié — interdit par la loi</td></tr><tr><td><strong>DUERP</strong></td><td>Document Unique d''Évaluation des Risques Professionnels — obligatoire dans toute entreprise ≥ 1 salarié</td></tr><tr><td><strong>Médecine du travail</strong></td><td>Service médical indépendant consacré à la prévention et au suivi de la santé des travailleurs</td></tr></tbody></table>', 5);
  v_count_lessons := v_count_lessons + 5;

  -- ═══════════════════════════════════════════════════════════════════
  -- CHAPITRE 8 — Reconstituer les coûts d'exploitation (CK, CH, CJ)
  -- ═══════════════════════════════════════════════════════════════════
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp3-ch08-couts-exploitation-ck-ch-cj',
    'Chapitre 8 — Reconstituer les coûts d''exploitation (CK, CH, CJ)',
    'CCP3 GOTRM · 6 leçons',
    'avance', 90, 48)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 48, true) ON CONFLICT DO NOTHING;
  v_count_modules := v_count_modules + 1;

  INSERT INTO public.lessons (module_id, slug, title, content_md, "order") VALUES
  (v_module, '8-1-pourquoi-reconstituer-couts', '8.1 — Pourquoi reconstituer les coûts d''exploitation ?',
    '<p>La reconstitution des coûts d''exploitation est le fondement de toute analyse de performance en transport. Sans coûts précis, il est impossible de savoir si un trafic est rentable, si un prix de vente est suffisant, ou si les moyens sont utilisés efficacement.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR — Les trois indicateurs à calculer par véhicule (ou par type de véhicule) :</strong></p>
<ul><li><strong>CK = Coût au Kilomètre</strong> (charges variables)</li><li><strong>CH = Coût à l''Heure de service</strong> (charges de conduite)</li><li><strong>CJ = Coût à la Journée d''exploitation</strong> (charges fixes)</li></ul>
<p>Ces trois indicateurs sont comparés aux indices de référence CNR (Comité National Routier). Un écart significatif révèle un problème d''efficacité ou une opportunité d''amélioration.</p></blockquote>', 1),
  (v_module, '8-2-structure-charges', '8.2 — Structure des charges d''exploitation',
    '<table><thead><tr><th>Catégorie</th><th>Composantes</th><th>Calcul unitaire</th></tr></thead><tbody><tr><td><strong>CHARGES VARIABLES (→ CK)</strong></td><td>Carburant, pneumatiques, entretien/réparations, lubrifiants</td><td>Total annuel / km annuels</td></tr><tr><td><strong>CHARGES DE CONDUITE (→ CH)</strong></td><td>Salaires bruts, charges sociales, frais de route, remplaçant congés</td><td>Total annuel / heures de service annuelles</td></tr><tr><td><strong>CHARGES FIXES (→ CJ)</strong></td><td>Amortissement, crédit-bail, taxes (taxe à l''essieu), assurances, frais financiers</td><td>Total annuel / jours d''exploitation annuels</td></tr><tr><td><strong>CHARGES DE STRUCTURE</strong></td><td>Frais généraux, administratifs, direction — répartis sur le parc</td><td>Par convention selon la politique de l''entreprise</td></tr></tbody></table>', 2),
  (v_module, '8-3-charges-variables-ck', '8.3 — Calcul détaillé des charges variables (CK)',
    '<p><strong>Le carburant</strong> — Poste le plus important des charges variables. La consommation varie selon : le type de véhicule, l''activité (urbaine vs longue distance), le poids transporté, la conduite du chauffeur, la politique d''approvisionnement.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>Coût carburant au km = (Consommation moyenne aux 100 km × Prix moyen du litre) / 100</p></blockquote>
<p><strong>Les pneumatiques</strong></p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>Coût pneu au km = (Prix unitaire × Nombre de pneumatiques) / Durée de vie moyenne (km)</p></blockquote>
<p><strong>L''entretien et les réparations</strong> — Ce poste comprend l''entretien préventif (vidanges, graissages) et les réparations. Son estimation s''effectue à partir du coût horaire de la main-d''œuvre de l''atelier et des prix des pièces détachées.</p>', 3),
  (v_module, '8-4-charges-fixes-cj', '8.4 — Calcul détaillé des charges fixes (CJ)',
    '<p><strong>L''amortissement</strong> — L''amortissement comptabilise la dépréciation du véhicule dans le temps. Il en existe deux méthodes :</p>
<table><thead><tr><th>Méthode</th><th>Principe</th><th>Formule</th></tr></thead><tbody><tr><td><strong>Amortissement linéaire</strong></td><td>Dépréciation constante chaque année</td><td>Valeur d''achat HT / Durée de vie (années)</td></tr><tr><td><strong>Amortissement dégressif</strong></td><td>Dépréciation plus forte en début de vie</td><td>Taux linéaire × Coefficient fiscal dégressif (1,25 ; 1,75 ou 2,25 selon la durée)</td></tr></tbody></table>
<p><strong>La taxe à l''essieu</strong> — La taxe à l''essieu est une taxe annuelle due pour les véhicules de plus de 12 tonnes. Son montant varie selon le nombre d''essieux et le PTAC du véhicule. Elle doit impérativement être intégrée dans le calcul des charges fixes.</p>
<p><strong>La TIPCE (Taxe Intérieure de Consommation sur les Produits Énergétiques)</strong> — Une partie de la taxe sur le gazole est remboursable aux transporteurs routiers professionnels (TIPCE remboursable). Ce remboursement vient en déduction des charges variables. Le gestionnaire doit suivre et déclarer régulièrement le kilométrage parcouru pour en bénéficier.</p>', 4),
  (v_module, '8-5-references-cnr', '8.5 — Utilisation des références CNR',
    '<p>Le Comité National Routier publie mensuellement des indices de coûts de référence par type de véhicule (porteur 19t, semi-remorque 40t, fourgon...) pour différentes activités (longue distance, distribution, messagerie...). Ces indices permettent :</p>
<ul><li>De valider ses propres calculs de coûts de revient</li><li>D''identifier les postes où les coûts de l''entreprise sont supérieurs à la norme</li><li>De justifier les prix proposés aux clients ou négociés avec les sous-traitants</li><li>D''appliquer la clause d''indexation prévue dans les contrats</li></ul>
<blockquote data-callout="exemple" style="border-left:4px solid #DC2626;background:#FEF2F2;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📊 EXEMPLE — Reconstitution CK/CH/CJ — Semi-remorque ATLANTIS TRANSPORT</strong></p>
<p>Données annuelles véhicule réf AT-042 (Semi-remorque tautliner 40t) : Kilométrage annuel : 180 000 km — Heures de service : 2 200 h — Jours d''exploitation : 240 j</p>
<p><strong>CHARGES VARIABLES ANNUELLES :</strong></p>
<ul><li>Carburant (36L/100km × 1,55 €) : 180 000 × 0,558 = 100 440 €</li><li>Pneumatiques (18 pneus × 550 € / 120 000 km) : 180 000 × 0,0825 = 14 850 €</li><li>Entretien/réparations : 12 000 €</li><li><strong>TOTAL charges variables : 127 290 € → CK = 127 290 / 180 000 = 0,707 €/km</strong></li></ul>
<p><strong>CHARGES DE CONDUITE ANNUELLES :</strong></p>
<ul><li>Salaires + charges + frais de route : 56 000 €</li><li><strong>TOTAL charges conduite : 56 000 € → CH = 56 000 / 2 200 = 25,45 €/h</strong></li></ul>
<p><strong>CHARGES FIXES ANNUELLES :</strong></p>
<ul><li>Amortissement : 12 500 € | Taxe à l''essieu : 2 800 € | Assurances : 6 200 € | Financement : 4 500 €</li><li><strong>TOTAL charges fixes : 26 000 € → CJ = 26 000 / 240 = 108,33 €/j</strong></li></ul></blockquote>', 5),
  (v_module, '8-6-vocabulaire-chapitre-8', '8.6 — Vocabulaire essentiel du Chapitre 8',
    '<table><thead><tr><th>Terme</th><th>Définition</th></tr></thead><tbody><tr><td><strong>CK</strong></td><td>Coût au Kilomètre — charges variables annuelles / kilométrage annuel</td></tr><tr><td><strong>CH</strong></td><td>Coût à l''Heure — charges de conduite annuelles / heures de service annuelles</td></tr><tr><td><strong>CJ</strong></td><td>Coût à la Journée — charges fixes annuelles / jours d''exploitation annuels</td></tr><tr><td><strong>Amortissement linéaire</strong></td><td>Dépréciation constante chaque année = valeur / durée de vie</td></tr><tr><td><strong>Amortissement dégressif</strong></td><td>Dépréciation accélérée en début de vie — taux linéaire × coefficient fiscal</td></tr><tr><td><strong>Taxe à l''essieu</strong></td><td>Taxe annuelle sur les véhicules > 12 t — en fonction du nombre d''essieux et du PTAC</td></tr><tr><td><strong>TIPCE</strong></td><td>Taxe Intérieure de Consommation sur les Produits Énergétiques — partiellement remboursable aux transporteurs</td></tr><tr><td><strong>CNR</strong></td><td>Comité National Routier — publie les indices de coûts de référence mensuels</td></tr></tbody></table>', 6);
  v_count_lessons := v_count_lessons + 6;

  -- ═══════════════════════════════════════════════════════════════════
  -- CHAPITRE 9 — Le seuil de rentabilité
  -- ═══════════════════════════════════════════════════════════════════
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp3-ch09-seuil-rentabilite',
    'Chapitre 9 — Le seuil de rentabilité',
    'CCP3 GOTRM · 6 leçons',
    'avance', 80, 49)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 49, true) ON CONFLICT DO NOTHING;
  v_count_modules := v_count_modules + 1;

  INSERT INTO public.lessons (module_id, slug, title, content_md, "order") VALUES
  (v_module, '9-1-definition-seuil-rentabilite', '9.1 — Définition et utilité du seuil de rentabilité',
    '<p>Le seuil de rentabilité (ou Chiffre d''Affaires Critique — CAC) est le niveau d''activité à partir duquel l''entreprise couvre l''ensemble de ses charges et commence à dégager un bénéfice. En dessous du seuil : l''entreprise perd de l''argent. Au-dessus : elle est bénéficiaire.</p>
<p>En transport routier, le seuil de rentabilité peut être calculé pour un véhicule, un trafic ou une prestation dédiée. C''est un outil de décision fondamental : faut-il accepter ce trafic ? Ce prix est-il suffisant ? Ce véhicule est-il rentable ?</p>', 1),
  (v_module, '9-2-charges-fixes-variables', '9.2 — La distinction charges fixes / charges variables',
    '<table><thead><tr><th></th><th>Charges fixes</th><th>Charges variables</th></tr></thead><tbody><tr><td><strong>Caractéristique</strong></td><td>Restent constantes quelle que soit l''activité</td><td>Augmentent proportionnellement à l''activité</td></tr><tr><td><strong>Exemples transport</strong></td><td>Amortissement, assurances, taxes, loyers</td><td>Carburant, pneumatiques, entretien</td></tr><tr><td><strong>Comportement si kilométrage double</strong></td><td>Restent identiques (sur une année)</td><td>Doublent</td></tr><tr><td><strong>Incidence sur seuil de rentabilité</strong></td><td>Plus les CF sont élevés, plus le seuil est élevé</td><td>Plus le taux de marge sur coût variable est élevé, plus le seuil baisse</td></tr></tbody></table>', 2),
  (v_module, '9-3-mcv', '9.3 — La marge sur coût variable (MCV)',
    '<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p>
<ul><li>Marge sur Coût Variable (MCV) = Chiffre d''Affaires - Charges Variables</li><li>Taux de MCV = MCV / CA × 100</li><li>La MCV sert à couvrir les charges fixes.</li><li>Quand MCV = Charges fixes → on est exactement au seuil de rentabilité.</li></ul></blockquote>', 3),
  (v_module, '9-4-calcul-seuil', '9.4 — Calcul du seuil de rentabilité',
    '<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p>
<p><strong>FORMULE 1 — Seuil en chiffre d''affaires (CAC) :</strong></p>
<p>CAC = Charges Fixes / Taux de MCV</p>
<p><strong>FORMULE 2 — Seuil en kilométrage :</strong></p>
<p>Seuil en km = Charges Fixes / (Prix au km - Coût variable au km)</p>
<p><strong>FORMULE 3 — Seuil en journées d''exploitation :</strong></p>
<p>Seuil en jours = Charges Fixes annuelles / (CA journalier moyen - CV journaliers moyens)</p></blockquote>
<blockquote data-callout="exemple" style="border-left:4px solid #DC2626;background:#FEF2F2;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📊 EXEMPLE — Calcul seuil de rentabilité — Véhicule VE-08, NORD EXPRESS</strong></p>
<p>Données annuelles véhicule VE-08 :</p>
<ul><li>Charges fixes annuelles : 45 000 €</li><li>Charges variables : 0,58 €/km</li><li>Prix moyen facturé au km : 1,12 €/km</li></ul>
<p><strong>SEUIL EN KILOMÉTRAGE :</strong></p>
<ul><li>MCV par km = 1,12 - 0,58 = 0,54 €/km</li><li>Seuil = 45 000 / 0,54 = <strong>83 333 km/an</strong></li></ul>
<p><strong>Interprétation :</strong></p>
<ul><li>Si le véhicule parcourt moins de 83 333 km dans l''année : PERTE</li><li>Si le véhicule parcourt plus de 83 333 km : BÉNÉFICE</li><li>Avec 150 000 km réalisés : Bénéfice = (150 000 - 83 333) × 0,54 = 36 000 €</li></ul></blockquote>', 4),
  (v_module, '9-5-point-mort', '9.5 — Le point mort (date de passage du seuil)',
    '<p>Le point mort est la date à laquelle l''entreprise atteint son seuil de rentabilité dans l''année.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p>
<ul><li>Point mort (en jours) = Seuil de rentabilité / (CA annuel / 360)</li><li>Exemple : seuil = 180 000 € — CA annuel = 360 000 €</li><li>Point mort = 180 000 / (360 000 / 360) = 180 jours = fin juin</li><li>Interprétation : avant fin juin, l''entreprise perd de l''argent. Après : elle est bénéficiaire.</li></ul></blockquote>', 5),
  (v_module, '9-6-vocabulaire-chapitre-9', '9.6 — Vocabulaire essentiel du Chapitre 9',
    '<table><thead><tr><th>Terme</th><th>Définition</th></tr></thead><tbody><tr><td><strong>Seuil de rentabilité (CAC)</strong></td><td>Niveau d''activité à partir duquel l''entreprise couvre toutes ses charges</td></tr><tr><td><strong>Chiffre d''Affaires Critique (CAC)</strong></td><td>Autre nom du seuil de rentabilité — exprimé en euros de CA</td></tr><tr><td><strong>Marge sur Coût Variable (MCV)</strong></td><td>CA - Charges Variables — sert à couvrir les charges fixes</td></tr><tr><td><strong>Taux de MCV</strong></td><td>MCV / CA × 100 — indicateur de profitabilité marginale</td></tr><tr><td><strong>Point mort</strong></td><td>Date de l''année à laquelle le seuil de rentabilité est atteint</td></tr><tr><td><strong>Charges fixes (CF)</strong></td><td>Charges constantes indépendantes du volume d''activité</td></tr><tr><td><strong>Charges variables (CV)</strong></td><td>Charges proportionnelles au volume d''activité (km, heures...)</td></tr></tbody></table>', 6);
  v_count_lessons := v_count_lessons + 6;

  -- ═══════════════════════════════════════════════════════════════════
  -- CHAPITRE 10 — Les indicateurs financiers : SIG, BFR, FRNG et CAF
  -- ═══════════════════════════════════════════════════════════════════
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp3-ch10-indicateurs-financiers-sig-bfr-frng-caf',
    'Chapitre 10 — Les indicateurs financiers : SIG, BFR, FRNG et CAF',
    'CCP3 GOTRM · 7 leçons',
    'avance', 90, 50)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 50, true) ON CONFLICT DO NOTHING;
  v_count_modules := v_count_modules + 1;

  INSERT INTO public.lessons (module_id, slug, title, content_md, "order") VALUES
  (v_module, '10-1-sig', '10.1 — Les Soldes Intermédiaires de Gestion (SIG)',
    '<p>Les SIG décomposent le compte de résultat en indicateurs successifs pour comprendre pas à pas comment le résultat de l''entreprise s''est constitué. Ils permettent d''analyser la rentabilité et de comparer les performances dans le temps et avec les concurrents.</p>
<table><thead><tr><th>SIG</th><th>Formule</th><th>Ce qu''il mesure</th></tr></thead><tbody><tr><td>Marge commerciale brute</td><td>CA - Achats (consommables)</td><td>Valeur ajoutée au prix d''achat</td></tr><tr><td>Valeur Ajoutée (VA)</td><td>CA - Charges externes (sous-traitance, carburant, péages, frais généraux)</td><td>Richesse créée par l''entreprise</td></tr><tr><td>Excédent Brut d''Exploitation (EBE)</td><td>VA + Subventions - Salaires - Charges sociales - Impôts et taxes</td><td>Performance économique brute — indicateur de référence</td></tr><tr><td>Résultat d''exploitation (REX)</td><td>EBE - Dotations aux amortissements et provisions</td><td>Performance après amortissement</td></tr><tr><td>Résultat courant avant impôt (RCAI)</td><td>REX +/- Résultat financier</td><td>Performance après politique financière</td></tr><tr><td>Résultat exceptionnel</td><td>Produits exceptionnels - Charges exceptionnelles</td><td>Impact des opérations non courantes</td></tr><tr><td>Résultat net</td><td>RCAI + Rés. exceptionnel - Impôt sur sociétés - Participation</td><td>Bénéfice ou perte finale</td></tr></tbody></table>
<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRÉ RÉGLEMENTATION — RETRAITEMENTS SPÉCIFIQUES AU TRANSPORT :</strong></p><p>Pour que les SIG soient comparables entre entreprises de transport, 3 postes doivent être retraités :</p>
<ol><li><strong>SOUS-TRAITANCE :</strong> à déduire des charges externes ET du CA (car elle ne crée pas de VA interne)</li><li><strong>CRÉDIT-BAIL :</strong> à déduire des charges externes pour être réparti entre amortissements (80%) et charges financières (20%)</li><li><strong>PERSONNEL EXTÉRIEUR (intérimaires) :</strong> à déduire des charges externes pour être affecté aux charges de personnel</li></ol></blockquote>', 1),
  (v_module, '10-2-frng', '10.2 — Le Fonds de Roulement Net Global (FRNG)',
    '<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p>
<ul><li>FRNG = Ressources stables - Emplois stables</li><li>Ou : FRNG = Actif circulant - Dettes d''exploitation</li><li>FRNG > 0 : l''entreprise dispose d''un matelas de sécurité pour faire face aux aléas</li><li>FRNG < 0 : les actifs long terme ne sont pas couverts par les ressources long terme — situation risquée</li></ul></blockquote>', 2),
  (v_module, '10-3-bfr', '10.3 — Le Besoin en Fonds de Roulement (BFR)',
    '<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p>
<ul><li>BFR = Actif circulant d''exploitation - Dettes d''exploitation court terme</li><li>Le BFR mesure le besoin de trésorerie lié au cycle d''exploitation.</li><li>En transport : le BFR est généralement limité car les délais de paiement clients sont encadrés et les stocks sont faibles (pas de stock de marchandises à proprement parler).</li><li>BFR > 0 : l''entreprise a besoin de financement pour son cycle d''exploitation</li><li>BFR < 0 : l''exploitation génère de la trésorerie (rare en transport)</li></ul></blockquote>', 3),
  (v_module, '10-4-tresorerie-nette', '10.4 — La trésorerie nette (TN)',
    '<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p>
<ul><li>Trésorerie Nette (TN) = FRNG - BFR</li><li>TN > 0 : l''entreprise peut faire face à ses obligations à court terme</li><li>TN < 0 : risque d''illiquidité — l''entreprise doit recourir au crédit bancaire court terme</li></ul></blockquote>', 4),
  (v_module, '10-5-caf', '10.5 — La Capacité d''Autofinancement (CAF)',
    '<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p>
<ul><li>CAF = Résultat net + Dotations aux amortissements et provisions - Reprises</li><li>La CAF mesure la capacité de l''entreprise à financer ses investissements et à rembourser ses emprunts par ses propres ressources, sans recourir à des financements externes.</li><li>CAF élevée : l''entreprise peut renouveler son parc, investir, rembourser ses dettes sans recourir à l''emprunt</li><li>CAF faible ou négative : l''entreprise dépend des banques pour survivre — situation fragile</li></ul></blockquote>', 5),
  (v_module, '10-6-delais-paiement', '10.6 — Les délais de paiement',
    '<p>La loi LME (Loi de Modernisation de l''Économie) plafonne les délais de paiement pour éviter les abus.</p>
<table><thead><tr><th>Situation</th><th>Délai maximum</th></tr></thead><tbody><tr><td>Accord entre les parties</td><td>60 jours à compter de la date d''émission de la facture</td></tr><tr><td>Dérogation possible</td><td>45 jours fin de mois</td></tr><tr><td>Sans accord des parties</td><td>30 jours à compter de la réception des marchandises ou de la prestation</td></tr><tr><td>Factures périodiques</td><td>45 jours à compter de la date de facture</td></tr></tbody></table>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p>
<ul><li><em>Formule :</em> Délai moyen de paiement clients = (Créances clients / CA TTC) × 360 jours</li><li><em>Formule :</em> Délai de paiement fournisseurs = (Dettes fournisseurs / Achats TTC) × 360 jours</li><li><em>Objectif :</em> réduire le délai clients et allonger le délai fournisseurs pour optimiser la trésorerie.</li></ul></blockquote>', 6),
  (v_module, '10-7-vocabulaire-chapitre-10', '10.7 — Vocabulaire essentiel du Chapitre 10',
    '<table><thead><tr><th>Terme</th><th>Définition</th></tr></thead><tbody><tr><td><strong>SIG</strong></td><td>Soldes Intermédiaires de Gestion — décomposition du compte de résultat</td></tr><tr><td><strong>EBE</strong></td><td>Excédent Brut d''Exploitation — indicateur de performance économique indépendant de la politique d''amortissement</td></tr><tr><td><strong>REX</strong></td><td>Résultat d''Exploitation — EBE moins dotations aux amortissements</td></tr><tr><td><strong>FRNG</strong></td><td>Fonds de Roulement Net Global — surplus des ressources stables après financement des emplois stables</td></tr><tr><td><strong>BFR</strong></td><td>Besoin en Fonds de Roulement — besoin de financement lié au cycle d''exploitation</td></tr><tr><td><strong>TN</strong></td><td>Trésorerie Nette — FRNG - BFR — indicateur de liquidité à court terme</td></tr><tr><td><strong>CAF</strong></td><td>Capacité d''Autofinancement — ressources générées par l''activité pour financer les investissements</td></tr><tr><td><strong>Loi LME</strong></td><td>Loi de Modernisation de l''Économie — plafonne les délais de paiement à 60 jours</td></tr></tbody></table>', 7);
  v_count_lessons := v_count_lessons + 7;

  -- ═══════════════════════════════════════════════════════════════════
  -- CHAPITRE 11 — Le budget d'exploitation et le contrôle des écarts
  -- ═══════════════════════════════════════════════════════════════════
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp3-ch11-budget-exploitation-controle-ecarts',
    'Chapitre 11 — Le budget d''exploitation et le contrôle des écarts',
    'CCP3 GOTRM · 4 leçons',
    'avance', 60, 51)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 51, true) ON CONFLICT DO NOTHING;
  v_count_modules := v_count_modules + 1;

  INSERT INTO public.lessons (module_id, slug, title, content_md, "order") VALUES
  (v_module, '11-1-budget-exploitation', '11.1 — Le budget d''exploitation',
    '<p>Le budget d''exploitation est le document qui prévoit les produits (CA) et les charges pour la période à venir (généralement l''année). Il est établi par la direction en concertation avec les responsables d''exploitation et sert de référence pour l''ensemble des décisions.</p>
<table><thead><tr><th>Composante</th><th>Description</th></tr></thead><tbody><tr><td><strong>Budget de CA</strong></td><td>Prévision des recettes par type de trafic, client, véhicule ou zone</td></tr><tr><td><strong>Budget de charges variables</strong></td><td>Prévision du carburant, pneumatiques, entretien selon le kilométrage prévu</td></tr><tr><td><strong>Budget de charges de conduite</strong></td><td>Prévision des salaires, charges sociales, frais de déplacement</td></tr><tr><td><strong>Budget de charges fixes</strong></td><td>Prévision des amortissements, assurances, taxes, loyers</td></tr><tr><td><strong>Budget de sous-traitance</strong></td><td>Prévision des coûts d''affrètement ponctuel et régulier</td></tr><tr><td><strong>Budget de structure</strong></td><td>Prévision des frais généraux répartis sur l''exploitation</td></tr></tbody></table>', 1),
  (v_module, '11-2-identification-analyse-ecarts', '11.2 — L''identification et l''analyse des écarts',
    '<p>Le contrôle du budget consiste à comparer périodiquement (mois, trimestre) les résultats réels avec les prévisions. Les écarts identifiés doivent être analysés pour comprendre leurs causes et proposer des actions correctives.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p>
<ul><li>ÉCART = Réalisé - Prévu</li><li>Écart positif sur une charge : on a dépensé plus que prévu → à analyser</li><li>Écart négatif sur un produit : on a facturé moins que prévu → à analyser</li></ul>
<p><strong>Méthode d''analyse :</strong></p>
<ol><li>Calculer l''écart en valeur absolue et en pourcentage</li><li>Identifier si l''écart est significatif (≥ 5% ou montant important)</li><li>Identifier les causes : écart de volume (on a moins travaillé) ou écart de prix (le coût unitaire a changé)</li></ol></blockquote>
<table><thead><tr><th>Écart constaté</th><th>Cause possible</th><th>Action corrective</th></tr></thead><tbody><tr><td>Coût carburant > budget +12%</td><td>Hausse du prix du gazole non anticipée</td><td>Appliquer la clause d''indexation CNR sur les contrats clients</td></tr><tr><td>CA < budget -8% sur un trafic</td><td>Baisse des volumes d''un client</td><td>Analyser si le client est en difficulté — proposition commerciale</td></tr><tr><td>Frais de sous-traitance > budget</td><td>Recours excessif à l''affrètement spot</td><td>Vérifier si le planning est optimisé — anticiper les manques</td></tr><tr><td>Frais d''entretien > budget</td><td>Véhicule en fin de vie ou mal entretenu</td><td>Évaluer le report ou l''anticipation du renouvellement</td></tr><tr><td>Taux de km à vide élevé</td><td>Pas de fret de retour sur certains axes</td><td>Recherche systématique de fret retour sur bourse de fret</td></tr></tbody></table>', 2),
  (v_module, '11-3-outils-suivi-quotidien', '11.3 — Les outils de suivi quotidien',
    '<ul><li>Tableaux de bord d''exploitation : CA journalier, km parcourus, taux de remplissage, aléas</li><li>Rapports d''activité véhicule par véhicule : CK, CH, CJ calculés et comparés au budget</li><li>Suivi de consommation carburant : en litres et en euros, par véhicule et par conducteur</li><li>Suivi du taux de sous-traitance : part du CA sous-traitée vs. objectif</li><li>Tableau de bord clients : CA par client, évolution vs N-1, part dans le CA total</li></ul>
<blockquote data-callout="exemple" style="border-left:4px solid #DC2626;background:#FEF2F2;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📊 EXEMPLE — Analyse écart budget — BERGERAC FRET T3 2025</strong></p>
<p>Extrait du tableau de bord T3 (juillet-septembre) :</p>
<ul><li>CA réalisé : 285 000 € | CA prévu : 312 000 € | Écart : -27 000 € (-8,7%)</li><li>Cause identifiée : arrêt d''activité d''un client (3 semaines fermeture estivale) non prévue au budget</li><li>Charges carburant : 48 200 € | Prévu : 42 000 € | Écart : +6 200 € (+14,8%)</li><li>Cause : hausse du prix du gazole de +11 cts/L en juillet</li><li>Action : application pied de facture sur les contrats clients — notification envoyée</li><li>Charges sous-traitance : 31 500 € | Prévu : 22 000 € | Écart : +9 500 € (+43%)</li><li>Cause : 2 conducteurs en arrêt maladie en août → recours intensif à l''intérim</li><li>Action : lancer un recrutement CDI pour anticiper les remplacements futurs</li></ul></blockquote>', 3),
  (v_module, '11-4-vocabulaire-chapitre-11', '11.4 — Vocabulaire essentiel du Chapitre 11',
    '<table><thead><tr><th>Terme</th><th>Définition</th></tr></thead><tbody><tr><td><strong>Budget d''exploitation</strong></td><td>Prévision des produits et des charges pour la période — référence de gestion</td></tr><tr><td><strong>Écart</strong></td><td>Différence entre le réalisé et le prévu (positif = surcoût ou sous-recette)</td></tr><tr><td><strong>Contrôle budgétaire</strong></td><td>Comparaison périodique entre budget et réalisation — identification des écarts</td></tr><tr><td><strong>Action corrective</strong></td><td>Mesure mise en œuvre pour réduire un écart constaté</td></tr><tr><td><strong>Tableau de bord</strong></td><td>Outil synthétisant les indicateurs clés — vu quotidiennement ou hebdomadairement</td></tr><tr><td><strong>Reporting</strong></td><td>Transmission périodique des résultats et indicateurs à la hiérarchie</td></tr><tr><td><strong>Plan d''action</strong></td><td>Document formalisant les mesures correctives prévues avec responsables et échéances</td></tr></tbody></table>', 4);
  v_count_lessons := v_count_lessons + 4;

  -- ═══════════════════════════════════════════════════════════════════
  -- CHAPITRE 12 — Démarche qualité et amélioration continue
  -- ═══════════════════════════════════════════════════════════════════
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp3-ch12-demarche-qualite-amelioration-continue',
    'Chapitre 12 — Démarche qualité et amélioration continue',
    'CCP3 GOTRM · 7 leçons',
    'avance', 85, 52)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 52, true) ON CONFLICT DO NOTHING;
  v_count_modules := v_count_modules + 1;

  INSERT INTO public.lessons (module_id, slug, title, content_md, "order") VALUES
  (v_module, '12-1-qualite-transport-routier', '12.1 — La qualité dans le transport routier de marchandises',
    '<p>La démarche qualité vise à satisfaire les exigences des clients de manière systématique et constante, en impliquant l''ensemble du personnel. Elle ne se limite pas à corriger les problèmes — elle cherche à les prévenir.</p>
<p>En transport routier, la qualité se manifeste à tous les niveaux : qualité des véhicules, des conducteurs, des processus internes, de la relation client et de la gestion des anomalies.</p>', 1),
  (v_module, '12-2-certifications-qualite', '12.2 — Les certifications qualité en transport',
    '<table><thead><tr><th>Certification</th><th>Description</th><th>Avantages</th></tr></thead><tbody><tr><td>ISO 9001</td><td>Norme internationale de management de la qualité — applicable à tous les secteurs</td><td>Reconnaissance internationale, rigueur des processus, confiance des grands clients</td></tr><tr><td>OEA (Opérateur Économique Agréé)</td><td>Certification douanière européenne garantissant la fiabilité d''un opérateur dans la chaîne logistique internationale</td><td>Facilitation des formalités douanières, avantages aux contrôles</td></tr><tr><td>Label RSE</td><td>Reconnaissance de l''engagement social et environnemental de l''entreprise</td><td>Image employeur, clients sensibles à l''impact environnemental</td></tr></tbody></table>', 2),
  (v_module, '12-3-kpi-ccp3', '12.3 — Les indicateurs clés de performance (KPI) CCP3',
    '<table><thead><tr><th>Famille</th><th>Indicateur</th><th>Formule</th><th>Objectif type</th></tr></thead><tbody><tr><td>Qualité service</td><td>Taux de livraison à l''heure</td><td>Livraisons à l''heure / Total × 100</td><td>≥ 98%</td></tr><tr><td>Qualité service</td><td>Taux d''avaries</td><td>Envois avariés / Total × 100</td><td>< 0,5%</td></tr><tr><td>Rentabilité</td><td>CK réel vs CNR</td><td>CK calculé / CK CNR × 100</td><td>< 105%</td></tr><tr><td>Rentabilité</td><td>Marge brute par véhicule</td><td>CA véhicule - Coûts véhicule</td><td>> Seuil</td></tr><tr><td>RH</td><td>Taux d''absentéisme</td><td>Jours absences / Jours travaillés prévus × 100</td><td>< 4%</td></tr><tr><td>RH</td><td>Taux de turnover</td><td>Départs annuels / Effectif moyen × 100</td><td>< 15%</td></tr><tr><td>Environnement</td><td>Consommation carburant</td><td>L/100km réel vs objectif</td><td>Réduction annuelle</td></tr></tbody></table>', 3),
  (v_module, '12-4-pdca', '12.4 — La démarche d''amélioration continue (PDCA)',
    '<p>Le cycle PDCA (Plan-Do-Check-Act) est la méthode de référence pour l''amélioration continue. Elle s''applique à tout processus d''exploitation.</p>
<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>📋 LE CYCLE PDCA (Roue de Deming)</strong></p>
<p><strong>P — PLAN (Planifier) :</strong> Identifier le problème — Analyser les causes — Définir les objectifs — Choisir les actions</p>
<p><strong>D — DO (Faire) :</strong> Mettre en œuvre les actions planifiées</p>
<p><strong>C — CHECK (Vérifier) :</strong> Mesurer les résultats des actions — Comparer avec les objectifs</p>
<p><strong>A — ACT (Agir) :</strong></p>
<ul><li>Si résultats satisfaisants : standardiser la solution</li><li>Si résultats insuffisants : relancer un nouveau cycle PDCA</li></ul></blockquote>', 4),
  (v_module, '12-5-prevenir-litiges', '12.5 — Prévenir les litiges',
    '<p>La prévention des litiges est plus efficace et moins coûteuse que leur traitement. Le gestionnaire met en place des actions préventives :</p>
<ul><li>Formation des conducteurs aux procédures de réserves et à la vérification de l''état des marchandises</li><li>Rappel régulier des règles de chargement et d''arrimage</li><li>Vérification des documents de transport avant le départ</li><li>Procédures claires en cas de constat d''avarie ou de manquant</li><li>Suivi des statistiques de litiges par conducteur et par trafic pour cibler les actions préventives</li></ul>', 5),
  (v_module, '12-6-grilles-tarifaires-qualite', '12.6 — Grilles tarifaires et participation à la démarche qualité',
    '<p>Le gestionnaire CCP3 peut être associé à la création ou au renouvellement des grilles tarifaires, et à la mise en place de nouvelles procédures liées à la démarche qualité de l''entreprise.</p>
<ul><li><strong>Grilles tarifaires</strong> : analyser les écarts entre coûts réels et tarifs pratiqués — proposer des ajustements justifiés</li><li><strong>Nouvelles procédures</strong> : contribuer à la rédaction et à la diffusion des modes opératoires internes</li><li><strong>Formation qualité</strong> : sensibiliser l''équipe aux objectifs qualité et aux indicateurs suivis</li><li><strong>Processus d''amélioration continue</strong> : animer des groupes de travail pour identifier et traiter les causes de non-qualité</li></ul>', 6),
  (v_module, '12-7-vocabulaire-chapitre-12', '12.7 — Vocabulaire essentiel du Chapitre 12',
    '<table><thead><tr><th>Terme</th><th>Définition</th></tr></thead><tbody><tr><td><strong>ISO 9001</strong></td><td>Norme internationale de management de la qualité</td></tr><tr><td><strong>OEA</strong></td><td>Opérateur Économique Agréé — certification douanière européenne</td></tr><tr><td><strong>KPI</strong></td><td>Key Performance Indicator — indicateur clé de performance</td></tr><tr><td><strong>PDCA</strong></td><td>Plan-Do-Check-Act — cycle d''amélioration continue (Roue de Deming)</td></tr><tr><td><strong>Non-conformité</strong></td><td>Écart entre la réalité et ce qui est attendu (procédure, norme, engagement client)</td></tr><tr><td><strong>Action préventive</strong></td><td>Mesure prise pour éviter qu''un problème potentiel ne se produise</td></tr><tr><td><strong>Action corrective</strong></td><td>Mesure prise pour éliminer la cause d''un problème déjà survenu</td></tr><tr><td><strong>Standardisation</strong></td><td>Formalisation d''une bonne pratique pour qu''elle soit appliquée de manière systématique</td></tr><tr><td><strong>DUERP</strong></td><td>Document Unique d''Évaluation des Risques Professionnels — obligatoire, base de la prévention</td></tr></tbody></table>
<hr/>
<p>La réussite dans le transport routier de marchandises repose autant sur les compétences techniques que sur les qualités humaines, l''organisation et la capacité d''adaptation. À travers ce livret CCP3, vous avez découvert les principaux outils et méthodes permettant d''optimiser les moyens humains et organisationnels de l''entreprise de transport : management des équipes, suivi social, réglementation, prépaie, formation professionnelle, recrutement et qualité de vie au travail. Le gestionnaire de transport occupe une fonction centrale dans l''entreprise. Il assure le lien entre la direction, les conducteurs, les clients et les différents partenaires de la chaîne logistique. Son rôle contribue directement à la performance, à la sécurité, à la conformité réglementaire et à la satisfaction client. Nous vous souhaitons pleine réussite dans votre parcours de formation et dans votre future activité professionnelle de gestionnaire des opérations de transport routier de marchandises.</p>', 7);
  v_count_lessons := v_count_lessons + 7;

  RAISE NOTICE '────────────────────────────────────────────────────';
  RAISE NOTICE 'CCP3 GOTRM — Import terminé';
  RAISE NOTICE '────────────────────────────────────────────────────';
  RAISE NOTICE '  Modules créés/MAJ : %', v_count_modules;
  RAISE NOTICE '  Leçons créées/MAJ : %', v_count_lessons;
END $$;
