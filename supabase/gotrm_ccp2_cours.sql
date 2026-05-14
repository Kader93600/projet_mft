📄 PDF chargé : 1116 Ko
📑 46 pages, 73895 caractères
📚 12 chapitres, 74 leçons
-- =====================================================================
-- COURS GOTRM CCP2 — Piloter les trafics réguliers sous contrat de
-- sous-traitance
-- 
-- Généré automatiquement depuis COURS_CCP2_GOTRM.pdf
-- 12 chapitres, 74 leçons
-- 
-- Rattachement : formation GOTRM (slug) × bloc BC2
-- Idempotent : peut être rejoué (ON CONFLICT DO NOTHING sur slugs)
-- =====================================================================

DO $$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_count_modules int := 0;
  v_count_lessons int := 0;
BEGIN
  -- 1) Récupère la formation GOTRM + bloc BC2
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable'; END IF;

  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC2';
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Bloc BC2 introuvable'; END IF;

  -- ─── Chapitre 1 : La sous-traitance reguliere : cadre et ───
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp2-ch01-la-sous-traitance-reguliere-cadre-et',
    'Chapitre 1 — La sous-traitance régulière : cadre et enjeux',
    'CCP2 GOTRM · 7 leçons',
    'debutant', 84, 21)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 21, true)
  ON CONFLICT DO NOTHING;

  v_count_modules := v_count_modules + 1;

  -- Leçon 1.1 : Qu'est-ce que la sous-traitance régulière ?
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '1-1-qu-est-ce-que-la-sous-traitance-reguliere',
    '1.1 — Qu''est-ce que la sous-traitance régulière ?',
    '<p>Toute entreprise de transport connait des situations ou ses propres moyens humains et matériels ne suffisent pas à répondre à l''ensemble de la demande. La sous-traitance est la solution qui permet de confier tout ou partie de ses opérations de transport a un transporteur externe. On distingue deux formes de sous-traitance :</p>
<ul><li>La sous-traitance ponctuelle (spot) : recours a un sous-traitant pour une opération unique,</li></ul>
<p>en dehors de tout contrat. Traitée en CCP1.</p>
<ul><li>La sous-traitance régulière : partenariat avec un ou plusieurs transporteurs pour des trafics</li></ul>
<p>récurrents, formalise dans un contrat d''une durée minimale d''un an. C''est l''objet du CCP2.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>La sous-traitance régulière désigne le fait de confier de façon régulière et significative des opérations de transport a un transporteur externe, dans le cadre d''un contrat formalise d''une durée minimale annuelle. Le gestionnaire pilote ces trafics : il négocie, contractualise, supervise et assure le SAV.</p></blockquote>',
    1)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 1.2 : Pourquoi recourir a la sous-traitance régulière ?
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '1-2-pourquoi-recourir-a-la-sous-traitance-regulie',
    '1.2 — Pourquoi recourir a la sous-traitance régulière ?',
    '<p>Les avantages pour l''entreprise donneuse d''ordres Avantage Description Flexibilité S''adapter aux variations saisonnières ou aux pics d''activité sans investir dans du matériel ou embaucher Accès a une expertise Bénéficier du savoir-faire d''un spécialiste (ADR, ATP, transport exceptionnel, international) Couverture géographique Desservir des zones non couvertes par ses propres agences grâce au réseau du sous-traitant Optimisation des couts Eviter les charges fixes liées a des véhicules sous-utilises sur certains axes Réactivité Absorber rapidement un accroissement temporaire de l''activité Les risques a maitriser</p>
<ul><li>Dépendance vis-à-vis du sous-traitant : si le sous-traitant défaille, l''activité est impactée</li><li>Qualité de service : le client final ne fait pas la différence entre le transporteur principal et</li></ul>
<p>son sous-traitant — la réputation de l''entreprise est en jeu</p>
<ul><li>Responsabilité juridique : le donneur d''ordres reste responsable devant le client final de</li></ul>
<p>l''exécution du transport, même sous-traite</p>
<ul><li>Risques sociaux : si le sous-traitant ne respecte pas ses obligations sociales, le donneur</li></ul>
<p>d''ordres peut être mis en cause</p>
<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRE REGLEMENTATION</strong></p><p>Le donneur d''ordres reste pleinement RESPONSABLE vis-à-vis du client final de l''exécution du transport, même lorsqu''il a confié l''opération a un sous-traitant. C''est pourquoi la sélection, la qualification et le suivi des sous-traitants réguliers sont des actes critiques.</p></blockquote>',
    2)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 1.3 : Les acteurs de la sous-traitance régulière
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '1-3-les-acteurs-de-la-sous-traitance-reguliere',
    '1.3 — Les acteurs de la sous-traitance régulière',
    '<p>Acteur Rôle Responsabilité Donneur d''ordres (operateur de transport) Confie les trafics récurrents au sous- traitant — pilote les opérations — assure le SAV client Responsable vis-à-vis du client final Sous-traitant (tractionnaire) Exécute les opérations de transport confiées dans le cadre du contrat Responsable de la bonne exécution de sa prestation Client final A l''origine des trafics réguliers — ne connait pas forcement l''existence du sous-traitant Partie au contrat de transport principal Conducteur sous- traitant Réalise physiquement le transport — représente l''image du donneur d''ordres sur le terrain Respecte les instructions du donneur d''ordres</p>',
    3)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 1.4 : Le cadre règlementaire : le Code des transports
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '1-4-le-cadre-reglementaire-le-code-des-transports',
    '1.4 — Le cadre règlementaire : le Code des transports',
    '<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRE REGLEMENTATION</strong></p><p>Article D.3224-3 du Code des transports : le contrat type applicable aux transports publics routiers de marchandises exécutés par des sous-traitants définit le cadre juridique de la relation entre le donneur d''ordres et le sous-traitant. Ce contrat type s''applique automatiquement a toute relation de sous-traitance régulière en l''absence de contrat particulier. Obligation de vigilance du donneur d''ordres : Pour tout contrat &gt;= 5 000 euros HT, le donneur d''ordres doit vérifier la régularité administrative du sous-traitant.</p></blockquote>',
    4)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 1.5 : Les obligations respectives des parties
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '1-5-les-obligations-respectives-des-parties',
    '1.5 — Les obligations respectives des parties',
    '<p>Obligations du sous-traitant</p>
<ul><li>Exécuter les transports confies dans le respect des conditions contractuelles et</li></ul>
<p>règlementaires</p>
<ul><li>Respecter la règlementation sociale (RSE, Code du travail, Convention collective des</li></ul>
<p>transports routiers)</p>
<ul><li>Assurer l''entretien régulier et la sécurité des véhicules utilises</li><li>Maintenir une communication claire avec le donneur d''ordres — signaler tout problème ou</li></ul>
<p>retard</p>
<ul><li>Fournir tous les documents de transport nécessaires</li></ul>
<ul><li>Collaborer pour la résolution rapide des litiges</li><li>Veiller aux conditions de travail et de sécurité de ses conducteurs</li></ul>
<p>Obligations du donneur d''ordres</p>
<ul><li>Confier les trafics dans les conditions prévues au contrat (volumes, fréquences, délais)</li><li>Transmettre toutes les informations nécessaires a l''exécution des transports</li><li>Payer le prix convenu dans les délais contractuels</li><li>Exercer son obligation de vigilance : vérifier la régularité administrative du sous-traitant</li></ul>
<p>tous les 6 mois</p>
<ul><li>Inclure dans le cahier des charges les consignes relatives au respect des obligations</li></ul>
<p>sociales</p>',
    5)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 1.6 : Qualifier et référencer un sous-traitant régulier
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '1-6-qualifier-et-referencer-un-sous-traitant-regu',
    '1.6 — Qualifier et référencer un sous-traitant régulier',
    '<p>Avant de confier des trafics réguliers a un sous-traitant, le gestionnaire doit le qualifier, c''est-à-dire vérifier qu''il réunit toutes les conditions nécessaires a une collaboration sérieuse.</p>
<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>🛠️ METHODE</strong></p><p>Qualification d''un sous-traitant régulier GRILLE DE QUALIFICATION D''UN SOUS-TRAITANT REGULIER : DOCUMENTS ADMINISTRATIFS (à vérifier à la signature et tous les 6 mois) :</p>
<ul><li>Extrait Kbis &lt; 3 mois</li><li>Licence de transport communautaire ou intérieure en cours de validité</li><li>Attestation d''assurance RC en cours de validité</li><li>Attestation URSSAF &lt; 6 mois</li><li>Attestation de vigilance fiscale &lt; 6 mois</li></ul>
<p>CAPACITE TECHNIQUE :</p>
<ul><li>Parc de véhicules adaptés aux trafics confies</li><li>Qualifications des conducteurs (FIMO/FCO, ADR si nécessaire)</li><li>Présence sur la zone géographique concernée</li></ul>
<p>PERFORMANCE :</p>
<ul><li>Références et historique de la société</li><li>Capacite à respecter les délais et les consignes qualité</li><li>Organisation SAV en cas d''anomalie</li></ul></blockquote>
<blockquote data-callout="example" style="border-left:4px solid #6B7280;background:#F9FAFB;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💼 EXEMPLE</strong></p><p>Qualification sous-traitant — ATLANTIQUE FRET La société ATLANTIQUE FRET souhaite travailler avec TRANSPORTS GARCIA (sous- traitant potentiel). Gestionnaire DUBOIS V. procède a la qualification : -&gt; Kbis : obtenu, date de moins de 3 mois. OK -&gt; Licence communautaire : valide jusqu''en 2029. OK -&gt; Assurance RC : attestation en cours — couvre la marchandise jusqu''à 2 000 000 €. OK -&gt; URSSAF : attestation de 2 mois. OK -&gt; Véhicules : 3 semi-remorques tautliners + 2 frigos FRC. Adaptés aux trafics alimentaires. OK -&gt; Conducteurs : 5 conducteurs, FIMO/FCO a jour, CQC valide. OK -&gt; GARCIA référencé comme sous-traitant régulier sur l''axe Sud-Ouest</p></blockquote>',
    6)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 1.7 : Vocabulaire essentiel du Chapitre 1
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '1-7-vocabulaire-essentiel-du-chapitre-1',
    '1.7 — Vocabulaire essentiel du Chapitre 1',
    '<p>Terme Définition Sous-traitance régulière Partenariat contractualise avec un transporteur externe pour des trafics récurrents sur au moins un an Sous-traitance ponctuelle (spot) Recours a un sous-traitant pour une opération unique, sans contrat préétabli Donneur d''ordres L''entreprise qui confie les trafics au sous-traitant — reste responsable vis-à-vis du client final Tractionnaire Transporteur qui assure la traction entre deux plateformes dans le cadre de la messagerie Obligation de vigilance Obligation légale du donneur d''ordres de vérifier la régularité administrative du sous-traitant Qualification Processus de vérification et de validation d''un sous-traitant avant de lui confier des trafics Contrat type sous- traitance Contrat défini par le Code des transports (art. D.3224-3) — s''applique à défaut de contrat particulier Trafic régulier Flux de transport récurrent, identifie, pouvant faire l''objet d''une contractualisation durable</p>',
    7)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- ─── Chapitre 2 : Le contrat type sous-traitance ───
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp2-ch02-le-contrat-type-sous-traitance',
    'Chapitre 2 — Le contrat type sous-traitance',
    'CCP2 GOTRM · 6 leçons',
    'debutant', 72, 22)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 22, true)
  ON CONFLICT DO NOTHING;

  v_count_modules := v_count_modules + 1;

  -- Leçon 2.1 : Qu'est-ce qu'un contrat type ?
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '2-1-qu-est-ce-qu-un-contrat-type',
    '2.1 — Qu''est-ce qu''un contrat type ?',
    '<p>Les contrats types sont des modèles de contrats établis par les pouvoirs publics pour encadrer les relations entre les parties dans le transport routier. Ils s''appliquent automatiquement en l''absence de contrat particulier ou en cas d''insuffisance de celui-ci. Le contrat type sous-traitance est fixe par l''annexe a l''article D.3224-3 du Code des transports. Il régit les relations entre l''opérateur de transport (donneur d''ordres) et le sous-traitant régulier. C''est la référencé juridique de base pour toute relation de sous-traitance régulière.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>Les contrats types ne sont PAS des cahiers des charges. Ils décrivent les règles générales d''exécution du contrat de transport, pas les conditions tarifaires ou les spécifications techniques. Les conditions tarifaires appartiennent à la libre appréciation des parties (sous réserve que le prix permette une juste rémunération du transporteur).</p></blockquote>',
    1)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 2.2 : Structure et contenu du contrat type sous-traitance
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '2-2-structure-et-contenu-du-contrat-type-sous-tra',
    '2.2 — Structure et contenu du contrat type sous-traitance',
    '<p>Le contrat type sous-traitance a le même squelette que les autres contrats types du transport. Il aborde l''ensemble des modalités techniques de l''exécution du transport. STRUCTURE DU CONTRAT TYPE SOUS-TRAITANCE ARTICLE 1 — OBJET DU CONTRAT : Nature et volume des prestations confiées de façon régulière et significative au sous- traitant ARTICLE 2 — NATURE ET VOLUME DES PRESTATIONS : Description des marchandises, des trafics (origines/destinations), des fréquences et des volumes ARTICLE 3 — DUREE DU CONTRAT : Période de validité, dates de début et de fin, conditions de renouvellement ou de résiliation ARTICLE 4 — OBLIGATIONS DU SOUS-TRAITANT : Exécution des transports, respect des consignes, entretien véhicules, communication ARTICLE 5 — OBLIGATIONS DU DONNEUR D''ORDRES : Transmission des informations, paiement, fourniture des documents, vigilance administrative ARTICLE 6 — CONDITIONS FINANCIERES : Prix convenu, modalités de paiement, révision des prix (indexation carburant)</p>
<p>ARTICLE 7 — CONFIDENTIALITE : Protection des informations commerciales et techniques échangées ARTICLE 8 — ASSURANCE ET RESPONSABILITE : Assurances requises, plafonds de responsabilité, déclaration de valeur ARTICLE 9 — RESILIATION : Conditions et conséquences de la résiliation anticipée ARTICLE 10 — LITIGES : Mode de résolution : conciliation, arbitrage ou juridiction compétente ARTICLE 11 — LOI APPLICABLE : Droit français — juridictions compétentes</p>',
    2)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 2.3 : Les avantages du contrat type
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '2-3-les-avantages-du-contrat-type',
    '2.3 — Les avantages du contrat type',
    '<ul><li>Uniformise le système : tous les contrats types ont la même structure — facilite la lecture et</li></ul>
<p>la négociation</p>
<ul><li>Descriptif complet de l''exécution : informations a fournir, conditionnement, chargement,</li></ul>
<p>livraison, immobilisation, réparation maximale...</p>
<ul><li>Source de droit : révisés périodiquement, ils font avancer la jurisprudence</li><li>Aide à la rédaction : beaucoup de contrats entre chargeurs et transporteurs s''en inspirent</li></ul>',
    3)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 2.4 : Les limites du contrat type
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '2-4-les-limites-du-contrat-type',
    '2.4 — Les limites du contrat type',
    '<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRE REGLEMENTATION</strong></p><p>Les contrats types NE PEUVENT PAS aller à l''encontre :</p>
<ul><li>de la volonté des parties (qui peuvent les écarter ou les modifier par accord mutuel)</li><li>de la loi</li><li>des conventions internationales (CMR pour le transport international)</li></ul>
<p>Les contrats types ne traitent PAS de :</p>
<ul><li>La responsabilité pénale du transporteur</li><li>Les formalités à accomplir lors de la livraison (traitées par le Code civil et de commerce)</li><li>Les conditions tarifaires (librement négociées entre les parties)</li></ul></blockquote>',
    4)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 2.5 : La clause de révision des prix
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '2-5-la-clause-de-revision-des-prix',
    '2.5 — La clause de révision des prix',
    '<p>Tout contrat de sous-traitance régulier doit contenir une clause de révision des prix, notamment pour les variations du cout du carburant. Cette clause est d''ordre public (articles L.3222-1 et L.3222-2 du Code des transports).</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>La clause d''indexation indique que le prix du transport est révisé en cas de variations significatives des charges du transporteur qui tiennent à des conditions extérieures. En pratique : le gestionnaire négocie en début de contrat les modalités de révision (indice CNR, périodicité, seuil de déclenchement). SANCTION : 15 000 € pour le donneur d''ordres qui refuse un pied de facture carburant justifie.</p></blockquote>',
    5)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 2.6 : Vocabulaire essentiel du Chapitre 2
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '2-6-vocabulaire-essentiel-du-chapitre-2',
    '2.6 — Vocabulaire essentiel du Chapitre 2',
    '<p>Terme Définition Contrat type sous-traitance Contrat défini par le Code des transports (art. D.3224- 3) — cadre juridique de la sous-traitance régulière Clause d''indexation Clause prévoyant la révision automatique du prix en cas de variation des charges extérieures (carburant) Operateur de transport Terme utilise dans le contrat type pour désigner le donneur d''ordres Plafond de responsabilité Limite maximale d''indemnisation prévue dans le contrat — peut être modifiée par déclaration de valeur Résiliation Fin anticipée du contrat — conditions et conséquences précisées dans le contrat Conciliation Mode amiable de résolution des litiges — à tenter avant toute procédure judiciaire Force majeure Evènement imprévisible, irrésistible et extérieur — exonère le transporteur de sa responsabilité</p>',
    6)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- ─── Chapitre 3 : Négocier avec les sous-traitants ───
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp2-ch03-negocier-avec-les-sous-traitants',
    'Chapitre 3 — Négocier avec les sous-traitants réguliers',
    'CCP2 GOTRM · 6 leçons',
    'debutant', 72, 23)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 23, true)
  ON CONFLICT DO NOTHING;

  v_count_modules := v_count_modules + 1;

  -- Leçon 3.1 : Les enjeux de la négociation avec les sous-traitants
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '3-1-les-enjeux-de-la-negociation-avec-les-sous-tr',
    '3.1 — Les enjeux de la négociation avec les sous-traitants',
    '<p>La négociation des conditions de sous-traitance régulière est un acte stratégique. Elle conditionne la rentabilité de l''entreprise sur les trafics concernes et la qualité du service rendu au client final. Objectifs en tension :</p>
<ul><li>Objectif du donneur d''ordres : obtenir le meilleur service au prix le plus bas pour atteindre</li></ul>
<p>ses objectifs de rentabilité</p>
<ul><li>Objectif du sous-traitant : vendre sa prestation a un prix qui couvre ses couts et dégage</li></ul>
<p>une marge suffisante pour la qualité attendue</p>
<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRE REGLEMENTATION</strong></p><p>La loi impose que le prix du transport permette une JUSTE REMUNERATION du transporteur. Un donneur d''ordres qui imposerait des prix ne permettant pas au sous-traitant de respecter ses obligations sociales et la RSE peut voir sa responsabilité engagée.</p></blockquote>',
    1)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 3.2 : Préparer la négociation
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '3-2-preparer-la-negociation',
    '3.2 — Préparer la négociation',
    '<p>Une négociation bien préparée est une négociation a moitie gagnée. Le gestionnaire doit rassembler tous les éléments avant d''entrer en séance.</p>
<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>🛠️ METHODE</strong></p><p>Préparer une négociation de sous-traitance PREPARATION DE LA NEGOCIATION :</p>
<ol><li>CONNAITRE SES PROPRES COUTS :</li></ol>
<p>Calculer le cout de revient interne de l''opération (trinôme TK/TH/TJ ou référence CNR) Définir le budget maximum allouable a la sous-traitance Identifier la marge minimale à préserver</p>
<ol><li>CONNAITRE LES INDICES DE REFERENCE :</li></ol>
<p>Consulter les indices CNR en vigueur (TK, TH, TJ selon la catégorie) Analyser les tarifs pratiqués par les confrères sur les mêmes trafics</p>
<ol><li>CONNAITRE SON BESOIN PRECIS :</li></ol>
<p>Volumes et fréquences des trafics a sous-traiter Spécifications techniques (véhicule, température, ADR...) Niveau de qualité attendu (délais, SAV, traçabilité)</p>
<ol><li>CONNAITRE SES ALTERNATIVES :</li></ol>
<p>Autres sous-traitants potentiels consultes Possibilité de traiter en interne si négociation échoue Delai avant le début du contrat</p></blockquote>',
    2)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 3.3 : Les éléments à négocier
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '3-3-les-elements-a-negocier',
    '3.3 — Les éléments à négocier',
    '<p>Elément Contenu à négocier Points de vigilance Le prix Tarif au km, à la tonne, au voyage, au ml, à la palette ou forfait Doit permettre une juste rémunération — vérifier cohérence avec CNR La révision des prix Indice de référence (CNR), périodicité, seuil de déclenchement Préciser clairement les modalités dans le contrat Les frais annexes Péages, temps d''attente, prestations hors standard Lister exhaustivement pour éviter les litiges Les délais de paiement 30 jours fin de mois, 45 jours date de facture... Vérifier la conformité avec la loi LME (60 jours max) Les volumes et fréquences Nombre de voyages par semaine, tonnes mensuelles garanties Prévoir une clause de variation +/- X% Les pénalités Retard, avarie, non-présentation véhicule Encadrer et plafonner les pénalités mutuelles La durée Contrat a durée déterminée ou indéterminée Prévoir préavis de résiliation (3 mois minimum)</p>',
    3)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 3.4 : Les techniques de négociation
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '3-4-les-techniques-de-negociation',
    '3.4 — Les techniques de négociation',
    '<p>Principe fondamental On ne cède sur le prix qu''en dernier ressort. La survie économique de l''entreprise en dépend. Avant de baisser un prix ou d''accepter une hausse, le gestionnaire doit démontrer que le prix est justifié par les couts réels. Si une concession est accordée, elle doit être compensée (par un volume supplémentaire, une durée plus longue, des conditions de paiement améliorées...). Stratégies selon la situation Situation Stratégie recommandée Sous-traitant avec qui on travaille depuis longtemps Miser sur la relation de confiance — négocier une reconduction avec ajustement limite des prix Nouveau sous-traitant à intégrer Proposer une période d''essai de 3 mois avant contractualisation définitive</p>
<p>Sous-traitant en position de force (peu d''alternatives) Rechercher des alternatives avant la négociation — ne jamais être en situation de dépendance totale Sous-traitant demandant une hausse importante Demander la décomposition de ses couts — vérifier avec les indices CNR Négociation bloquée sur le prix Jouer sur d''autres leviers : volumes, fréquences, durée, conditions de paiement, simplification administrative</p>',
    4)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 3.5 : Les obligations sociales dans la négociation
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '3-5-les-obligations-sociales-dans-la-negociation',
    '3.5 — Les obligations sociales dans la négociation',
    '<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRE REGLEMENTATION</strong></p><p>Le gestionnaire doit inclure dans le cahier des charges et le contrat les consignes relatives au respect des obligations sociales du sous-traitant :</p>
<ul><li>Application de la RSE (règlement CE 561/2006)</li><li>Respect du Code du travail et de la Convention collective des transports routiers</li><li>Paiement des salaires au minimum au tarif de la convention collective</li><li>Respect de la FIMO/FCO pour tous les conducteurs affectes</li></ul>
<p>Un donneur d''ordres ne peut pas imposer des conditions qui conduisent le sous-traitant a enfreindre la RSE ou a sous-payer ses conducteurs.</p></blockquote>
<blockquote data-callout="example" style="border-left:4px solid #6B7280;background:#F9FAFB;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💼 EXEMPLE</strong></p><p>Négociation — MERIDIONAL TRANSPORT avec GARCIA LOGISTIQUE Trafic en question : 3 voyages/semaine Montpellier -&gt; Lyon, semi-remorque bâchée, 24 tonnes Proposition initiale GARCIA : 420 €/voyage Référence CNR : cout estimatif = 385 € -&gt; marge GARCIA = 8,8% Contre-proposition MERIDIONAL :</p>
<ul><li>Passer de 3 à 4 voyages/semaine (+33% volume) si le tarif est de 400 € -&gt; accepte par</li></ul>
<p>GARCIA</p>
<ul><li>Clause d''indexation CNR trimestrielle</li><li>Pénalités plafonnées a 50% du prix du voyage en cas de défaillance</li><li>Durée : 2 ans avec préavis de 3 mois</li></ul>
<p>Accord signe : 400 €/voyage x 4 voyages/semaine = budget annuel 83 200 €</p></blockquote>',
    5)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 3.6 : Vocabulaire essentiel du Chapitre 3
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '3-6-vocabulaire-essentiel-du-chapitre-3',
    '3.6 — Vocabulaire essentiel du Chapitre 3',
    '<p>Terme Définition Indice CNR Indice de référencé publie par le Comité National Routier — base de calcul des prix de sous-traitance Clause de variation Clause permettant une hausse ou baisse de volume sans pénalité dans une fourchette définie (ex : +/- 15%) Loi LME Loi de Modernisation de l''Economie — plafonne les délais de paiement à 60 jours date de facture ou 45 jours fin de mois Pénalité Indemnité due en cas de non-respect d''une obligation contractuelle (retard, avarie, non-présentation...) Préavis Delai à respecter avant la résiliation d''un contrat — en général 3 mois minimum en sous-traitance Offre compensatoire Alternative proposée a un refus de concession sur le prix : plus de volume, durée plus longue, paiement amélioré Appel d''offres Procédure par laquelle un donneur d''ordres consulte plusieurs sous-traitants pour un même trafic</p>',
    6)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- ─── Chapitre 4 : Le cahier des charges et la ───
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp2-ch04-le-cahier-des-charges-et-la',
    'Chapitre 4 — Le cahier des charges et la contractualisation',
    'CCP2 GOTRM · 5 leçons',
    'debutant', 60, 24)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 24, true)
  ON CONFLICT DO NOTHING;

  v_count_modules := v_count_modules + 1;

  -- Leçon 4.1 : La différence entre contrat type et cahier des charges
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '4-1-la-difference-entre-contrat-type-et-cahier-de',
    '4.1 — La différence entre contrat type et cahier des charges',
    '<p>Le contrat type définit les règles générales d''exécution du transport (qui fait quoi, quand, comment). Le cahier des charges, lui, est la matérialisation des besoins et exigences spécifiques du donneur d''ordres pour les trafics concernes. Ce n''est pas la même chose. Contrat type sous-traitance Cahier des charges Nature Document juridique d''ordre public Document technique et commercial Contenu Règles générales d''exécution — responsabilités — indemnisations Spécifications précises des trafics confies — qualité attendue — conditions opérationnelles Force juridique S''applique à défaut de contrat particulier Valeur contractuelle si intègre au contrat Auteur Les pouvoirs publics (Code des transports) Le donneur d''ordres</p>',
    1)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 4.2 : Rédiger un cahier des charges
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '4-2-rediger-un-cahier-des-charges',
    '4.2 — Rédiger un cahier des charges',
    '<p>Le cahier des charges est le document central de la contractualisation régulière. Il doit être suffisamment précis pour éviter tout litige sur l''interprétation des obligations de chaque partie. STRUCTURE D''UN CAHIER DES CHARGES SOUS-TRAITANCE CONTENU D''UN CAHIER DES CHARGES SOUS-TRAITANCE :</p>
<ol><li>PRESENTATION DES PARTIES :</li></ol>
<p>Raison sociale, adresse, SIRET, licence, contact principal des deux parties</p>
<ol><li>DESCRIPTION DES TRAFICS :</li></ol>
<p>Origines et destinations, nature des marchandises, volumes mensuels / annuels, fréquences (jours et horaires), variations saisonnières prévues</p>
<ol><li>SPECIFICATIONS TECHNIQUES :</li></ol>
<p>Type de véhicule et carrosserie requis, équipements spéciaux (ATP, ADR...),</p>
<ol><li>QUALITE DE SERVICE ATTENDUE :</li></ol>
<p>Taux de livraison a l''heure attendu (ex : &gt;= 98%), délais d''acheminement garantis, modalités de suivi et de traçabilité, procédure de signalement des aléas</p>
<ol><li>OBLIGATIONS REGLEMENTAIRES :</li></ol>
<p>Application de la RSE, FIMO/FCO à jour pour tous les conducteurs affectes, respect du Code du travail et de la Convention collective, gestion des ZFE</p>
<ol><li>CONDITIONS TARIFAIRES :</li></ol>
<p>Prix unitaire et base de calcul, frais annexes, clause d''indexation</p>
<ol><li>FACTURATION ET PAIEMENT :</li></ol>
<p>Fréquence de facturation, délais de paiement, modalités de contestation</p>
<ol><li>GESTION DES LITIGES :</li></ol>
<p>Procédure de traitement des réclamations, délais de réponse, plafonds d''indemnisation</p>
<ol><li>PENALITES :</li></ol>
<p>Pénalités mutuelles en cas de non-respect (retard, non-présentation véhicule, défaut qualité)</p>
<ol><li>CONDITIONS DE REVISION ET DE RESILIATION :</li></ol>
<p>Conditions de modification, préavis, indemnités éventuelles</p>',
    2)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 4.3 : Le modèle de contrat de sous-traitance
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '4-3-le-modele-de-contrat-de-sous-traitance',
    '4.3 — Le modèle de contrat de sous-traitance',
    '<p>A partir du cahier des charges, les parties formalisent leur accord dans un contrat écrit. Le livre source fournit un modèle de contrat de sous-traitance conforme au Code des transports que le gestionnaire peut utiliser et adapter. MENTIONS OBLIGATOIRES — Contrat de sous-traitance CLAUSES OBLIGATOIRES DU CONTRAT DE SOUS-TRAITANCE : EN-TETE : Mention ''Contrat de Sous-Traitance'' + identification complète des deux parties (Raison sociale, adresse, SIRET, numéro de licence, représentant légal) ARTICLE 1 — Objet : nature et volume des prestations confiées de façon régulière ARTICLE 2 — Description précise des marchandises et des trafics ARTICLE 3 — Durée (dates début/fin + conditions de renouvellement) ARTICLE 4 — Obligations du sous-traitant (dont respect RSE et obligations sociales) ARTICLE 5 — Obligations du donneur d''ordres (dont obligation de vigilance tous les 6 mois) ARTICLE 6 — Conditions financières (prix, modalités de paiement, clause indexation) ARTICLE 7 — Confidentialité ARTICLE 8 — Assurance et responsabilité (attestations d''assurance en annexe) ARTICLE 9 — Résiliation (conditions et préavis) ARTICLE 10 — Litiges (mode de résolution)</p>
<p>ARTICLE 11 — Loi applicable ARTICLE 12 — Modifications (procédure écrite, avenant) ARTICLE 13 — Dispositions générales SIGNATURES : représentants autorises de chaque partie + date</p>',
    3)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 4.4 : L'avenant au contrat
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '4-4-l-avenant-au-contrat',
    '4.4 — L''avenant au contrat',
    '<p>Tout modification des conditions contractuelles (changement de trafic, révision de tarif, extension de la durée...) doit faire l''objet d''un avenant écrit signe par les deux parties. Un accord verbal ne suffit pas et ne peut pas être oppose en cas de litige.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>Un avenant doit mentionner : la référence au contrat initial, la date de l''avenant, les clauses modifiées, la date d''effet des modifications, et les signatures des deux parties. Sans avenant écrit signé : les modifications ne sont pas opposables juridiquement.</p></blockquote>',
    4)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 4.5 : Vocabulaire essentiel du Chapitre 4
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '4-5-vocabulaire-essentiel-du-chapitre-4',
    '4.5 — Vocabulaire essentiel du Chapitre 4',
    '<p>Terme Définition Cahier des charges Document technique et commercial décrivant les besoins et exigences du donneur d''ordres Contrat de sous- traitance Accord écrit formalisant les conditions de la relation entre donneur d''ordres et sous-traitant régulier Avenant Modification d''un contrat existant — document écrit signe par les deux parties Clause de confidentialité Protection des informations commerciales et techniques échangées entre les parties Clause de non- concurrence Interdiction faite au sous-traitant de démarcher directement les clients du donneur d''ordres Indemnité de résiliation Compensation éventuellement due en cas de rupture anticipée du contrat Arbitrage Mode de résolution des litiges par un tiers indépendant — alternatif a la voie judiciaire</p>',
    5)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- ─── Chapitre 5 : L'organisation de type plateforme : ───
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp2-ch05-l-organisation-de-type-plateforme',
    'Chapitre 5 — L''organisation de type plateforme : messagerie et groupage',
    'CCP2 GOTRM · 6 leçons',
    'debutant', 72, 25)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 25, true)
  ON CONFLICT DO NOTHING;

  v_count_modules := v_count_modules + 1;

  -- Leçon 5.1 : La messagerie : définition et spécificités
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '5-1-la-messagerie-definition-et-specificites',
    '5.1 — La messagerie : définition et spécificités',
    '<p>La messagerie est le transport d''envois inferieurs a 3 tonnes, avec une multiplicité d''expéditeurs et de destinataires. Elle implique des opérations de regroupement (groupage) et d''éclatement (dégroupage) sur des plateformes intermédiaires. C''est le secteur ou la sous-traitance régulière est la plus structurante.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>La chaine logistique de la messagerie se décompose en 5 étapes :</p>
<ol><li>ENLEVEMENTS (ramasse chez les clients expéditeurs)</li><li>GROUPAGE (passage a quai de départ — tri et chargement en traction)</li><li>TRACTION (transport de quai a quai — nocturne en général)</li><li>DEGROUPAGE (passage a quai d''arrivée — tri et mise en tournée)</li><li>LIVRAISONS (distribution chez les destinataires finals)</li></ol></blockquote>',
    1)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 5.2 : L'organisation en Etoile (hub and spoke)
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '5-2-l-organisation-en-etoile-hub-and-spoke',
    '5.2 — L''organisation en Etoile (hub and spoke)',
    '<p>La plupart des réseaux de messagerie nationaux fonctionnent en Etoile : des plateformes régionales centralisent les flux provenant des agences locales, puis les redistribuent vers les autres régions. Ce modèle permet de massifier les tractions entre grandes villes et de desservir même des zones a faible densité.</p>
<blockquote data-callout="example" style="border-left:4px solid #6B7280;background:#F9FAFB;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💼 EXEMPLE</strong></p><p>Organisation en étoile Un colis envoyé d''Ajaccio (Corse) pour Brest (Finistère) :</p>
<ol><li>Enlèvement à Ajaccio -&gt; groupage sur la plateforme de Marseille</li><li>Traction Marseille -&gt; Toulouse (il n''existe pas de traction directe Marseille-Rennes)</li><li>Dégroupage à Toulouse -&gt; regroupage dans la traction Toulouse -&gt; Rennes</li><li>Dégroupage à Rennes -&gt; traction Rennes -&gt; Brest</li><li>Livraison à Brest</li></ol>
<p>Les plateformes de Marseille, Toulouse et Rennes = centres de transit (HUB)</p></blockquote>',
    2)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 5.3 : Le plan de transport
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '5-3-le-plan-de-transport',
    '5.3 — Le plan de transport',
    '<p>Le plan de transport est le document qui organise l''ensemble des flux réguliers d''une plateforme : quelles tractions partent a quelle heure, vers quels correspondants, et avec quels volumes prévus. Le gestionnaire s''appuie sur ce plan pour superviser les opérations au quotidien. CONTENU DU PLAN DE TRANSPORT QUOTIDIEN LE PLAN DE TRANSPORT D''UNE PLATEFORME RECENSE :</p>
<ul><li>Les tractions de départ : destination, heure de départ, sous-traitant ou conducteur</li></ul>
<p>interne, véhicule</p>
<ul><li>Les tractions d''arrivée : provenance, heure d''arrivée prévue, volumes attendus</li><li>Les tournées de livraison : conducteur, zone, nombre de points de livraison</li><li>Les tournées de ramasse : conducteur, zone, volumes attendus</li><li>Les incidents de la veille impactant les flux du jour</li></ul>',
    3)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 5.4 : Les intervenants sur la plateforme
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '5-4-les-intervenants-sur-la-plateforme',
    '5.4 — Les intervenants sur la plateforme',
    '<p>Intervenant Rôle principal Gestionnaire d''exploitation Organise les tournées, les tractions, supervise les opérations, gère les aléas Chef de quai Coordonne les opérations physiques sur le quai — interface exploitation/manutention Manutentionnaire Décharge, trie, zone et charge les colis — signale les avaries et manquants Pointeur Vérifie la conformité entre colis physiques et documents (bordereau de groupage, récépissé) Appeleur / Aboyeur Lit les étiquettes à voix haute lors des chargements/déchargements Zoneur / Marqueur Repère la destination des colis et les oriente vers les bonnes travées Cariste Manoeuvre les chariots élévateurs et transpalettes pour les palettes Conducteur livreur Effectue les livraisons chez les clients finals dans la zone de camionnage Tractionnaire Assure les tractions entre plateformes (souvent sous-traitant)</p>',
    4)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 5.5 : Les zones du quai
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '5-5-les-zones-du-quai',
    '5.5 — Les zones du quai',
    '<p>Un quai de messagerie est organisé en zones distinctes, chacune affectée a une fonction spécifique. Zone Fonction Zone de travail Interface quai/véhicule — opérations de chargement et déchargement Travees (surfaces d''accumulation) Emplacements identifies par destination ou tournée — tri et stockage temporaire des colis</p>
<p>Zone de souffrance Stockage des colis non livrés (avisés, refuses, avaries, en attente de retour) Zone de préparation Etiquetage et palettisation des colis non prépares par l''expéditeur Zone de circulation Allées pour les engins de manutention — sécurisées et matérialisées au sol Zone de rangement Stockage du matériel de manutention hors utilisation Zone d''exploitation (bureau) Poste de commande du chef de quai — surplombant idéalement le quai pour vision d''ensemble</p>',
    5)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 5.6 : Vocabulaire essentiel du Chapitre 5
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '5-6-vocabulaire-essentiel-du-chapitre-5',
    '5.6 — Vocabulaire essentiel du Chapitre 5',
    '<p>Terme Définition Messagerie Transport d''envois &lt; 3 tonnes avec multiplicité d''expéditeurs et de destinataires Groupage Regroupement des colis de plusieurs expéditeurs pour une même destination Dégroupage Eclatement des colis à l''arrivée vers les tournées de livraison ou nouvelles tractions Traction Véhicule de liaison entre deux plateformes — généralement nocturne Tractionnaire Sous-traitant assurant les liaisons inter-plateformes Hub Plateforme centrale dans une organisation en étoile — centre de transit Plan de transport Document organisant l''ensemble des flux réguliers d''une plateforme Travée Emplacement sur le quai affecte à une destination ou une tournée spécifique Zone de souffrance Zone accueillant les colis dont la livraison est en attente ou empêchée Pointage Vérification de la conformité entre colis physiques et documents de transport Récépissé Document de base de la messagerie — valeur de lettre de voiture en messagerie</p>',
    6)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- ─── Chapitre 6 : Les opérations de traction ───
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp2-ch06-les-operations-de-traction',
    'Chapitre 6 — Les opérations de traction',
    'CCP2 GOTRM · 7 leçons',
    'debutant', 84, 26)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 26, true)
  ON CONFLICT DO NOTHING;

  v_count_modules := v_count_modules + 1;

  -- Leçon 6.1 : Définition et rôle de la traction
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '6-1-definition-et-role-de-la-traction',
    '6.1 — Définition et rôle de la traction',
    '<p>La traction est la phase de transport pur qui relie deux plateformes. Elle ne se distingue pas techniquement d''un transport de lots partiels ou complets. Sa spécificité tient a son intégration dans une chaine logistique : elle est cadencée, souvent nocturne, et son non-respect impacte en cascade toute la chaine de livraison.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>La traction peut être assurée par l''entreprise elle-même ou par un confrère. Quand elle est sous-traitée a un confrère : on est dans le cas du TRANSPORT AVEC TRANSPORTEURS SUCCESSIFS, Éventuellement assujetti au contrat type sous-traitance.</p></blockquote>',
    1)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 6.2 : Pourquoi les tractions sont souvent nocturnes
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '6-2-pourquoi-les-tractions-sont-souvent-nocturnes',
    '6.2 — Pourquoi les tractions sont souvent nocturnes',
    '<p>Les nécessites commerciales imposent d''effectuer les tractions en nocturne pour plusieurs raisons :</p>
<ul><li>La marchandise est ramassée dans la journée — le groupage se fait en début de soirée —</li></ul>
<p>la traction part en fin de soirée pour arriver tôt le matin</p>
<ul><li>L''arrivée tôt le matin permet de démarrer le dégroupage et de préparer les tournées de</li></ul>
<p>livraison pour une livraison en J+1</p>
<ul><li>Les routes sont moins chargées la nuit — les temps de trajet sont plus prévisibles</li><li>La réglementation sur les interdictions de circulation (week-end, jours fériés) ne s''applique</li></ul>
<p>pas de la même façon</p>
<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRE REGLEMENTATION</strong></p><p>Le travail de nuit est la période entre 22h et 5h du matin pour les conducteurs. Toute heure effectuée entre 21h et 6h donne droit a une prime de nuit égale a 20% du taux horaire conventionnel (coefficient 150M). Les conducteurs effectuant au moins 50 heures de nuit par mois ont également droit a un repos compensateur de 5% des heures de nuit.</p></blockquote>',
    2)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 6.3 : Superviser le départ d'une traction
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '6-3-superviser-le-depart-d-une-traction',
    '6.3 — Superviser le départ d''une traction',
    '<p>SUPERVISION DEPART DE TRACTION AVANT LE DEPART DE LA TRACTION, LE GESTIONNAIRE VERIFIE :</p>
<ol><li>LE VEHICULE : immatriculation conforme a la confirmation d''affrètement, état général,</li></ol>
<p>plombage</p>
<ol><li>LE CHARGEMENT :</li></ol>
<ul><li>Rapprochement entre le bordereau de groupage et les colis effectivement charges</li><li>Pointage des colis charges (scan au pistolet ou vérification physique)</li><li>Etat de chargement établi par le correspondant expéditeur</li><li>Transfert informatique (EDI) valant bordereau de groupage transmis</li><li>Scannage des colis non-charges avec état des ''restes a quai''</li></ul>
<ol><li>LES DOCUMENTS :</li></ol>
<ul><li>Lettre de voiture ou bordereau de groupage</li><li>Confirmation d''affrètement si sous-traitant</li><li>Documents ADR si matières dangereuses</li><li>Ordre de mission du conducteur</li></ul>
<ol><li>LA CONFORMITE RSE :</li></ol>
<ul><li>Temps de service restant du conducteur</li><li>Respect des obligations de repos avant prise de service</li></ul>',
    3)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 6.4 : Superviser l'arrivée d'une traction
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '6-4-superviser-l-arrivee-d-une-traction',
    '6.4 — Superviser l''arrivée d''une traction',
    '<p>A l''arrivée d''une traction, la plateforme réceptionnaire doit réaliser un ensemble d’opérations de contrôle rigoureuses. Le moindre écart non signale à l''arrivée peut générer un litige non résolu. PROTOCOLE D''ARRIVEE DE TRACTION OPERATIONS DE MISE A QUAI A LA RECEPTION D''UNE TRACTION :</p>
<ol><li>Enregistrer l''heure d''arrivée du véhicule</li><li>Vérifier le bon calage du véhicule lors de son positionnement a quai</li><li>S''assurer que le véhicule n''a subi aucune effraction (portes, plombs)</li><li>Déplomber le véhicule — enregistrer le numéro du plomb</li><li>Examiner le chargement pour y déceler les avaries éventuelles</li><li>Formuler les réserves sur le bordereau de groupage si avaries ou manquants constates</li><li>Informer immédiatement le correspondant expéditeur de toute anomalie</li><li>Scanner les colis au déchargement</li><li>Scanner les colis non mis en livraison (restes a quai)</li><li>Etablir un état de déchargement</li><li>Comparer avec le transfert informatique reçu — identifier les écarts</li></ol>',
    4)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 6.5 : Le bordereau de groupage
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '6-5-le-bordereau-de-groupage',
    '6.5 — Le bordereau de groupage',
    '<p>Le bordereau de groupage est le document support de la traction. Il recapitule tous les envois charges dans le véhicule de traction. Il sert de base au pointage à l''arrivée. CONTENU — Bordereau de groupage CONTENU DU BORDEREAU DE GROUPAGE :</p>
<ul><li>Identification de la plateforme expéditrice</li><li>Identification de la plateforme destinatrice</li><li>Date et heure de départ</li><li>Numéro d''immatriculation du véhicule de traction</li><li>Nom du conducteur</li><li>Liste exhaustive des envois charges :</li><li>Numéro de récépissé</li><li>Expéditeur et destinataire</li><li>Nombre de colis et poids</li><li>Zone de destination ou code tournée</li></ul>',
    5)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 6.6 : L'EDI (Echange de Données Informatisé)
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '6-6-l-edi-echange-de-donnees-informatise',
    '6.6 — L''EDI (Echange de Données Informatisé)',
    '<p>Les grandes plateformes de messagerie utilisent l''EDI pour échanger les informations relatives aux tractions. Avant le départ de la traction, la plateforme expéditrice transmet un flux EDI qui vaut bordereau de groupage électronique. La plateforme destinatrice peut ainsi préparer la réception avant même l''arrivée physique du véhicule.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>L''EDI permet :</p>
<ul><li>De préparer le déchargement avant l''arrivée physique de la traction</li><li>De créer les récépissés à l''arrivée par flashage des étiquettes (plutôt qu''a l''enlèvement)</li><li>De détecter les écarts immédiatement (colis manquants, dévoyés) par comparaison</li></ul>
<p>automatique</p>
<ul><li>D''assurer la traçabilité en temps réel de chaque envoi</li></ul></blockquote>',
    6)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 6.7 : Vocabulaire essentiel du Chapitre 6
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '6-7-vocabulaire-essentiel-du-chapitre-6',
    '6.7 — Vocabulaire essentiel du Chapitre 6',
    '<p>Terme Définition Traction Véhicule de liaison entre deux plateformes — phase de transport pur Bordereau de groupage Document recapitulant tous les envois charges dans un véhicule de traction Plomb / Plombage Dispositif de sécurité scellant les portes du véhicule — garantit l''intégrité du chargement EDI Echange de Données Informatise — transmission électronique du bordereau de groupage Rapport d''arrivage Document constatant l''état des colis a la réception d''une traction — base des réserves Etat de chargement Document établi par la plateforme expéditrice listant les colis charges Transfert informatique Envoi EDI valant bordereau de groupage — base du contrôle a l''arrivée Transporteurs successifs Plusieurs transporteurs se relayant pour la même opération — chacun responsable de sa partie</p>',
    7)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- ─── Chapitre 7 : Superviser le groupage et le ───
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp2-ch07-superviser-le-groupage-et-le',
    'Chapitre 7 — Superviser le groupage et le dégroupage à quai',
    'CCP2 GOTRM · 6 leçons',
    'debutant', 72, 27)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 27, true)
  ON CONFLICT DO NOTHING;

  v_count_modules := v_count_modules + 1;

  -- Leçon 7.1 : Le groupage : opérations et organisation
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '7-1-le-groupage-operations-et-organisation',
    '7.1 — Le groupage : opérations et organisation',
    '<p>Le groupage comprend deux grandes phases : la réception des envois (enlèves ou déposes par les clients) et leur réexpédition groupée vers les plateformes destinatrices. Phase 1 — La réception</p>
<ul><li>Déchargement des véhicules de ramasse par les manutentionnaires</li><li>Pointage des colis et des récépissés — vérification de la conformité quantitative et</li></ul>
<p>qualitative</p>
<ul><li>Enregistrement dans le système informatique (par saisie ou flashage code-barres)</li><li>Etiquetage si non fait par l''expéditeur</li></ul>
<p>Phase 2 — La réexpédition</p>
<ul><li>Etiquetage directionnel : apposition d''une étiquette code-barres indiquant la plateforme de</li></ul>
<p>destination</p>
<ul><li>Zonage : placement des colis dans la travée correspondante à leur destination</li><li>Chargement dans les véhicules de traction selon l''ordre des destinations</li><li>Etablissement du bordereau de groupage et transmission EDI</li></ul>',
    1)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 7.2 : Les deux modes de chargement
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '7-2-les-deux-modes-de-chargement',
    '7.2 — Les deux modes de chargement',
    '<p>Mode Description Avantages Inconvénients Chargement différé Les marchandises sont d''abord triées et mises en travées, puis rechargées en bloc Pointage de qualité — flexibilité dans l''organisation Nécessite plus de surface de quai et de temps Chargement direct Les marchandises sont transbordées directement du véhicule d''arrivée au véhicule de départ Gain de temps et de manutention Qualité du pointage moindre — nécessite la disponibilité du véhicule de départ</p>',
    2)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 7.3 : Le dégroupage : opérations et organisation
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '7-3-le-degroupage-operations-et-organisation',
    '7.3 — Le dégroupage : opérations et organisation',
    '<p>Le dégroupage est l''opération symétrique du groupage. Il consiste à décharger le véhicule de traction et à disposer les colis dans des travées affectées aux tournées de livraison ou aux nouvelles tractions. OPERATIONS DE DEGROUPAGE OPERATIONS DE DEGROUPAGE</p>
<ol><li>Mise a quai du véhicule de traction (selon le protocole d''arrivée)</li><li>Déchargement et pointage des colis (rapprochement avec le bordereau de groupage /</li></ol>
<p>EDI)</p>
<ol><li>Tri et zonage des colis dans les travées :</li></ol>
<ul><li>Travees de livraison (par tournée)</li><li>Travees de nouvelles tractions (colis en transit vers une 3eme plateforme)</li></ul>
<ol><li>Préparation des feuilles de tournée</li><li>Chargement des véhicules de livraison en respectant l''ordre de livraison prévu</li><li>Départ des tournées (en général avant 8h00)</li></ol>',
    3)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 7.4 : L'étiquetage des colis
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '7-4-l-etiquetage-des-colis',
    '7.4 — L''étiquetage des colis',
    '<p>L''étiquetage est une opération clé de la messagerie. Une étiquette mal lisible ou mal apposée peut engendrer un dévoyé, c''est-à-dire un acheminement vers la mauvaise plateforme. Type d''étiquette Contenu Apposée par Etiquette d''expédition Expéditeur, destinataire, adresse complète, référence commande, code-barres récépissé L''expéditeur ou le conducteur a la ramasse Etiquette d''acheminement (directionnelle) Code de la plateforme de destination, numéro de ligne de traction, code tournée La plateforme de départ</p>
<p>Etiquette de régularisation (''regul'') Reprend les informations manquantes — créée par la plateforme en cas d''absence de récépissé La plateforme réceptionnaire</p>',
    4)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 7.5 : La sécurité sur le quai
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '7-5-la-securite-sur-le-quai',
    '7.5 — La sécurité sur le quai',
    '<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRE REGLEMENTATION</strong></p><p>Le quai est un environnement a risques : circulation de chariots élévateurs, palettes lourdes, surfaces glissantes, travail de nuit. Obligations réglementaires :</p>
<ul><li>Allées de circulation matérialisées au sol — largeur minimum selon le type d''engin</li><li>Caristes : plus de 18 ans, visite médicale, formation CACES obligatoire</li><li>Equipements de protection individuelle (EPI) : chaussures de sécurité, gilet haute</li></ul>
<p>visibilité</p>
<ul><li>Procédure d''urgence en cas d''incident affichée et connue de tous</li><li>Maintien de l''ordre et de la propreté du quai — facteur de sécurité ET d''efficacité</li></ul></blockquote>',
    5)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 7.6 : Vocabulaire essentiel du Chapitre 7
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '7-6-vocabulaire-essentiel-du-chapitre-7',
    '7.6 — Vocabulaire essentiel du Chapitre 7',
    '<p>Terme Définition Travee Emplacement identifie sur le quai affecte a une destination, une tournée ou une traction spécifique Dévoyé Colis achemine vers la mauvaise plateforme — erreur d''adressage Régularisation (''régul'') Création d''un récépissé de remplacement quand le document original est absent à l''arrivée CACES Certificat d''Aptitude à la Conduite En Sécurité — obligatoire pour les conducteurs de chariots élévateurs Transbordement Transfert direct d''une marchandise d''un véhicule a un autre sans stockage intermédiaire Mise a quai Positionnement d''un véhicule en position de chargement ou déchargement contre le quai Pont de liaison Dispositif compense la dénivellation entre le quai et le plancher du véhicule Manutention Operations de chargement, déchargement, transfert et stockage des colis sur le quai</p>',
    6)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- ─── Chapitre 8 : Optimiser les tournées de distribution et ───
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp2-ch08-optimiser-les-tournees-de-distribution-et',
    'Chapitre 8 — Optimiser les tournées de distribution et de ramasse',
    'CCP2 GOTRM · 7 leçons',
    'debutant', 84, 28)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 28, true)
  ON CONFLICT DO NOTHING;

  v_count_modules := v_count_modules + 1;

  -- Leçon 8.1 : Pourquoi optimiser les tournées ?
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '8-1-pourquoi-optimiser-les-tournees',
    '8.1 — Pourquoi optimiser les tournées ?',
    '<p>Une tournée est un circuit qui permet a un conducteur de livrer ou d''enlever chez plusieurs clients a partir d''un point central. L''optimisation des tournées vise a minimiser les kilomètres parcourus (et donc les couts) tout en respectant les contraintes horaires, les capacités des véhicules et la qualité de service due aux clients.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>L''optimisation des tournées est une compétence directement évaluée à l''examen CCP2. Elle mobilise à la fois la connaissance géographique (carte routière), les contraintes RSE et les capacités véhicule. Les logiciels de tournées (bases sur l''algorithme de KRUSKAL / méthode des écarts) automatisent ce travail.</p></blockquote>',
    1)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 8.2 : Les types de tournées
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '8-2-les-types-de-tournees',
    '8.2 — Les types de tournées',
    '<p>Type de tournée Description Usage Tournée fixe immuable Circuit identique tous les jours de la semaine Activités très régulières — abonnements — flux constants Tournée fixe par jour de semaine Circuit diffèrent selon le jour (lundi circuit A, mardi circuit B...) Clients a fréquences variables — grande distribution Tournée semi- variable Zone fixe mais clients et quantités variables à l''intérieur Messagerie — distribution urbaine Tournée variable Circuit établi strictement en fonction des besoins du jour Enlèvements a la demande — sous- traitance ponctuelle</p>',
    2)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 8.3 : La préparation d'une tournée de livraison
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '8-3-la-preparation-d-une-tournee-de-livraison',
    '8.3 — La préparation d''une tournée de livraison',
    '<p>En messagerie, la tournée de livraison se prépare le matin à l''arrivée de la traction :</p>
<ul><li>1. Les récépissés sont triés par tournée après le dégroupage</li><li>2. Les colis sont disposés dans les travées correspondant à chaque tournée</li><li>3. Le gestionnaire ou le chef de quai établit la feuille de tournée</li><li>4. Les colis sont charges dans le véhicule dans l''ordre inverse des livraisons (dernier livré =</li></ul>
<p>charge en premier)</p>
<ul><li>5. Le véhicule doit être parti au plus tard a 8h00 pour une livraison en J+1</li></ul>',
    3)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 8.4 : La préparation d'une tournée de ramasse
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '8-4-la-preparation-d-une-tournee-de-ramasse',
    '8.4 — La préparation d''une tournée de ramasse',
    '<p>En messagerie, les tournées de ramasse se constituent à partir des demandes d''enlèvement formulées par les clients (par téléphone, mail ou EDI).</p>
<ul><li>Les exploitants enregistrent les enlèvements à effectuer dans l''après-midi</li></ul>
<ul><li>Ils établissent un bordereau d''enlèvement pour chaque conducteur</li><li>Le conducteur se rend chez chaque client, fait établir le récépissé (prise en charge</li></ul>
<p>juridique), et rapporte les colis à l''agence</p>
<ul><li>Les clients peuvent aussi déposer leurs colis directement a l''agence jusqu''a une heure</li></ul>
<p>limite — évite la taxe d''enlèvement</p>',
    4)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 8.5 : La méthode des écarts (algorithme de KRUSKAL)
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '8-5-la-methode-des-ecarts-algorithme-de-kruskal',
    '8.5 — La méthode des écarts (algorithme de KRUSKAL)',
    '<p>La méthode des écarts est la base algorithmique des logiciels de tournées. Le principe consiste a calculer l''économie réalisée (l''écart) en regroupant deux clients dans la même tournée plutôt qu''en faisant deux trajets distincts depuis le dépôt.</p>
<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>🛠️ METHODE</strong></p><p>DES ECARTS — Principe PRINCIPE DE LA METHODE DES ECARTS : Supposons que le dépôt D dessert les clients A et B. OPTION 1 : Deux allers-retours séparés Distance totale = (D-&gt;A-&gt;D) + (D-&gt;B-&gt;D) OPTION 2 : Une tournée groupée Distance totale = D-&gt;A-&gt;B-&gt;D ou D-&gt;B-&gt;A-&gt;D L''écart = Distance option 1 - Distance option 2 Un écart positif signifie qu''il est plus économique de regrouper A et B dans la même tournée. Les logiciels calculent ces écarts pour toutes les combinaisons possibles et construisent les tournées en commençant par les écarts les plus importants (économies maximales).</p></blockquote>',
    5)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 8.6 : Les contraintes à intégrer dans l'optimisation
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '8-6-les-contraintes-a-integrer-dans-l-optimisatio',
    '8.6 — Les contraintes à intégrer dans l''optimisation',
    '<p>Contrainte Description Capacite du véhicule Le poids total des livraisons ne dépasse pas la charge utile du véhicule Contraintes horaires clients Créneaux de livraison imposes par les clients (horaires d''ouverture, plages réservées) Durée de service RSE La tournée doit être réalisable dans le respect des temps de conduite et de service du conducteur Ordre de livraison Cohérence géographique — éviter les retours en arrière inutiles Priorités de livraison Express, J+1 garanti, marchandises périssables — a livrer en premier Contraintes de circulation ZFE, interdictions horaires, accès restreints</p>
<blockquote data-callout="example" style="border-left:4px solid #6B7280;background:#F9FAFB;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💼 EXEMPLE</strong></p><p>Optimisation tournee — AGENCE EUROFLUX NANTES Livraisons du matin : 8 clients dans la zone de Nantes Est Véhicule : porteur 12 t — CU : 7 500 kg — Temps de service max : 12h Contrainte : 2 clients avec livraison impérative avant 9h30 (alimentaire frais) Etape 1 : Placer les 2 clients ''impératifs'' en début de tournée Etape 2 : Organiser les 6 autres clients par écarts croissants Etape 3 : Vérifier le poids total : 6 450 kg &lt; 7 500 kg -&gt; OK Etape 4 : Estimer le temps : 8 livraisons x 15 min + 2h30 de conduite = 4h30 -&gt; OK RSE Tournée validée — conducteur MARTIN F. — départ 7h00</p></blockquote>',
    6)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 8.7 : Vocabulaire essentiel du Chapitre 8
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '8-7-vocabulaire-essentiel-du-chapitre-8',
    '8.7 — Vocabulaire essentiel du Chapitre 8',
    '<p>Terme Définition Tournée de livraison Circuit permettant a un conducteur de livrer plusieurs clients a partir d''un dépôt Tournée de ramasse Circuit permettant a un conducteur d''enlever les marchandises chez plusieurs clients expéditeurs Feuille de tournée Document remis au conducteur listant les clients a livrer ou enlever dans l''ordre prévu</p>
<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>🛠️ Méthode</strong></p><p>des écarts Algorithme d''optimisation des tournées — base des logiciels de gestion Logiciel de tournées Outil informatique construisant automatiquement les tournées optimisées Taxe d''enlèvement Frais supplémentaires factures pour un enlèvement à domicile (par opposition au dépôt en agence) Point de livraison Adresse d''un destinataire à visiter dans une tournée Taux de charge Rapport entre le poids total livre et la charge utile du véhicule — indicateur d''optimisation</p></blockquote>',
    7)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- ─── Chapitre 9 : Le service après-vente (SAV) : traiter les ───
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp2-ch09-le-service-apres-vente-sav-traiter-les',
    'Chapitre 9 — Le service après-vente (SAV) : traiter les réclamations',
    'CCP2 GOTRM · 7 leçons',
    'debutant', 84, 29)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 29, true)
  ON CONFLICT DO NOTHING;

  v_count_modules := v_count_modules + 1;

  -- Leçon 9.1 : Le rôle du SAV en messagerie
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '9-1-le-role-du-sav-en-messagerie',
    '9.1 — Le rôle du SAV en messagerie',
    '<p>Le service après-vente (SAV) est le point de contact des clients pour toute réclamation liée à une livraison. En messagerie, la multiplicité des intervenants (enlèvement, groupage, traction, dégroupage, livraison) multiplie les sources de dysfonctionnement potentiels. Un SAV efficace est un facteur clé de fidélisation client. Le gestionnaire du service exploitation joue souvent un rôle de premier niveau dans le traitement des réclamations : il qualifie la demande, apporte une réponse immédiate si possible, ou transmet au service SAV dédié.</p>',
    1)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 9.2 : Les types d'anomalies traitées par le SAV
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '9-2-les-types-d-anomalies-traitees-par-le-sav',
    '9.2 — Les types d''anomalies traitées par le SAV',
    '<p>Type d''anomalie Description Cause fréquente Avarie caractérisée Dommage visible au déchargement ou lors de la manutention Mauvais arrimage, choc pendant le transport, manutention brutale Avarie occulte Dommage non visible a la livraison — découvert au déballage Casse interne, mouille, gel sur produit sensible Manquant total Colis présent sur le document mais absent à la livraison Perte, vol, mauvais adressage (dévoyé non- retrouve) Manquant partiel Contenu du colis incomplet — objets manquants a l''intérieur Effraction, palette filmée non contrôlée à l''enlèvement Retard Livraison hors délai contractuel Traction en retard, problème technique, conditions météorologiques Dévoyé non- retrouve Colis achemine vers la mauvaise destination et non retrouve Erreur d''étiquetage ou de zonage Non-livraison Colis en souffrance — destinataire absent ou refus Destinataire absent, adresse incorrecte, refus de réception</p>',
    2)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 9.3 : La procédure de traitement des réclamations
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '9-3-la-procedure-de-traitement-des-reclamations',
    '9.3 — La procédure de traitement des réclamations',
    '<blockquote data-callout="method" style="border-left:4px solid #059669;background:#ECFDF5;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>🛠️ METHODE</strong></p><p>Traitement d''une reclamation SAV PROCEDURE SAV — TRAITEMENT D''UNE RECLAMATION : ETAPE 1 — RECEPTION ET QUALIFICATION Identifier le type de réclamation (avarie, manquant, retard...) Vérifier la recevabilité : les réserves ont-elles été formulées ? Dans les délais légaux ? Collecter les informations : numéro de récépissé, date de livraison, description du dommage ETAPE 2 — VERIFICATION DES RESERVES Pour être recevables, les réserves doivent être :</p>
<ul><li>Ecrites, précises et motivées sur le document de transport</li><li>Confirmées par LRAR dans les 3 jours francs (art. L.133-3 Code de commerce)</li><li>Pour les particuliers : 10 jours (art. L.224-65 Code de la consommation)</li></ul>
<p>ETAPE 3 — INSTRUCTION DU DOSSIER Rassembler les pièces justificatives :</p>
<ul><li>Copie du récépissé émargé</li><li>Copie de la facture d''achat de la marchandise</li><li>Bordereau de groupage de la traction concernée</li><li>Rapport d''arrivage si des réserves ont été prises</li><li>Photos des dommages si disponibles</li></ul>
<p>ETAPE 4 — DETERMINATION DES RESPONSABILITES</p>
<ul><li>Rapprocher le rapport d''arrivage et les réserves du client</li><li>Identifier à quel stade le dommage s''est produit</li><li>Déterminer si la responsabilité incombe au transporteur ou si une exonération est</li></ul>
<p>possible ETAPE 5 — TRAITEMENT ET REPONSE</p>
<ul><li>Si responsabilité du transporteur : calculer l''indemnisation selon les plafonds</li></ul>
<p>contractuels</p>
<ul><li>Transmettre le dossier au service dédié (si SAV distinct)</li><li>Informer le client du résultat avec le délai de règlement</li></ul></blockquote>',
    3)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 9.4 : Rappel des plafonds d'indemnisation
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '9-4-rappel-des-plafonds-d-indemnisation',
    '9.4 — Rappel des plafonds d''indemnisation',
    '<p>Contrat type Envoi &lt; 3 t Envoi &gt;= 3 t Général — par kg 33 €/kg 20 €/kg Général — par colis 1 000 €/colis — Général — par tonne — 3 200 €/tonne Température dirigée — par kg 23 €/kg 14 €/kg Température dirigée — par colis 750 €/colis — Température dirigée — par tonne — 4 000 €/tonne</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>Les plafonds ne s''appliquent PAS si : DOL ou faute lourde / déclaration de valeur préalable. En cas de retard : plafond = montant du prix du transport. La FORCLUSION supprime tout droit à indemnisation si les réserves ne sont pas confirmées dans les délais.</p></blockquote>',
    4)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 9.5 : Le geste commercial
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '9-5-le-geste-commercial',
    '9.5 — Le geste commercial',
    '<p>Même lorsque le client est forclos (réserves non confirmées dans les délais) ou que la réclamation n''est pas fondée, l''entreprise peut choisir d''accorder un geste commercial pour préserver la relation client. Ce n''est pas une obligation juridique, c''est une décision commerciale. Le gestionnaire doit être capable d''évaluer : la valeur du client pour l''entreprise, la fréquence des incidents avec ce client, l''impact d''un refus sur la relation commerciale, et le cout du geste commercial par rapport a la perte client potentielle.</p>',
    5)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 9.6 : La communication SAV avec le client
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '9-6-la-communication-sav-avec-le-client',
    '9.6 — La communication SAV avec le client',
    '<p>La qualité de la communication SAV est aussi importante que la solution apportée. Un client qui se sent pris en charge, informe et respecte, reste fidèle même en cas de problème. Un client laisse sans réponse cherche un autre transporteur. BONNES PRATIQUES SAV BONNES PRATIQUES DE COMMUNICATION SAV :</p>
<ul><li>Accuser réception de la réclamation dans les 24 heures</li><li>Informer le client des délais de traitement prévus</li><li>Tenir le client informe de l''avancement (même si le dossier n''est pas résolu)</li><li>Répondre par le même canal que la réclamation (email si email, téléphone si appel)</li><li>Eviter le jargon technique incompréhensible pour le client</li><li>Proposer une solution concrète et un délai de règlement précis</li><li>Confirmer les accords verbaux par écrit</li></ul>',
    6)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 9.7 : Vocabulaire essentiel du Chapitre 9
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '9-7-vocabulaire-essentiel-du-chapitre-9',
    '9.7 — Vocabulaire essentiel du Chapitre 9',
    '<p>Terme Définition SAV Service Après-Vente — traitement des réclamations clients liées a l''exécution du transport Rapport d''arrivage Document constatant les anomalies à la réception d''une traction — base des réserves inter-agences Avis d''avarie Notification formelle d''un dommage constate — ouvre le dossier litige Forclusion Perte définitive du droit a indemnisation — délais de réserves non respectes Dossier litige Ensemble des pièces justificatives : récépissé émargé + facture d''achat + bordereau de groupage Geste commercial Décision de l''entreprise d''indemniser partiellement ou totalement même sans obligation juridique Réserves précises Annotations écrites, précises et motivées sur le document de transport — condition de recevabilité Recevabilité Caractère d''une réclamation qui peut être examinée (réserves dans les délais, dossier complet)</p>',
    7)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- ─── Chapitre 10 : Les retours de marchandises ───
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp2-ch10-les-retours-de-marchandises',
    'Chapitre 10 — Les retours de marchandises',
    'CCP2 GOTRM · 5 leçons',
    'debutant', 60, 30)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 30, true)
  ON CONFLICT DO NOTHING;

  v_count_modules := v_count_modules + 1;

  -- Leçon 10.1 : Pourquoi les retours ?
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '10-1-pourquoi-les-retours',
    '10.1 — Pourquoi les retours ?',
    '<p>Un retour de marchandise survient lorsque la livraison n''a pas pu être effectuée, ou lorsque le client destinataire souhaite retourner la marchandise a l''expéditeur. La gestion des retours est un service à part entière, de plus en plus valorise par les clients (notamment en e-commerce).</p>',
    1)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 10.2 : Les principales causes de retours
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '10-2-les-principales-causes-de-retours',
    '10.2 — Les principales causes de retours',
    '<p>Cause Description Action du gestionnaire Destinataire absent Personne n’absente lors de la tentative de livraison Avis de passage — planifier une nouvelle présentation ou mise en souffrance Refus du destinataire Le destinataire refuse la livraison (avarie, erreur de commande) Constater le refus avec réserves — retour à l''expéditeur + information SAV Adresse incorrecte ou introuvable L''adresse de livraison est erronée ou ne correspond à aucun site Recherche de l''adresse correcte — retour si introuvable Marchandise non conforme Le destinataire refuse car la marchandise ne correspond pas a sa commande Retour coordonne avec le service commercial du client Retour client e- commerce Le client final renvoie un produit commande en ligne Organisation du retour depuis le domicile du client</p>',
    2)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 10.3 : La procédure de gestion des retours
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '10-3-la-procedure-de-gestion-des-retours',
    '10.3 — La procédure de gestion des retours',
    '<p>PROCEDURE — Gestion d''un retour de marchandise PROCEDURE DE GESTION D''UN RETOUR :</p>
<ol><li>RECEPTION DE LA DEMANDE DE RETOUR :</li></ol>
<p>Identifier l''expéditeur d''origine, le destinataire, le numéro de récépissé, la nature du retour</p>
<ol><li>PLANIFICATION DES OPERATIONS :</li></ol>
<ul><li>Déterminer si le retour est pris en charge par le transporteur original ou un sous-</li></ul>
<p>traitant</p>
<ul><li>Fixer la date d''enlèvement chez le destinataire</li><li>Prévoir le véhicule et le conducteur</li></ul>
<ol><li>TRANSMISSION DES INSTRUCTIONS :</li></ol>
<p>Instruire le conducteur : adresse d''enlèvement, nature de la marchandise, conditions Etablir le document de transport pour le retour (nouveau récépissé)</p>
<ol><li>EXECUTION ET SUIVI :</li></ol>
<ul><li>S''assurer de la bonne prise en charge chez le destinataire</li><li>Vérifier l''état de la marchandise au retour</li><li>Livrer a l''expéditeur d''origine</li></ul>
<ol><li>CLOTURE :</li></ol>
<ul><li>Informer le client du retour effectue</li><li>Traiter la facturation du retour (tarif convenu dans le contrat initial)</li></ul>',
    3)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 10.4 : Le colis en souffrance
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '10-4-le-colis-en-souffrance',
    '10.4 — Le colis en souffrance',
    '<p>Lorsqu''un colis ne peut pas être livre ni retourne immédiatement (destinataire absent, adresse incorrecte...), il est place en zone de souffrance sur la plateforme.</p>
<ul><li>La plateforme contacte l''expéditeur et le destinataire pour débloquer la situation</li><li>Un avis de passage est colle sur le colis et envoyé au destinataire</li><li>Les colis en souffrance font l''objet d''un suivi informatique régulier</li><li>Passe un certain délai sans résolution, l''expéditeur est informe pour décision (retour,</li></ul>
<p>destruction, vente aux enchères selon les cas)</p>
<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRE REGLEMENTATION</strong></p><p>Le transporteur est responsable de la marchandise pendant toute la durée du dépôt en souffrance. Il doit assurer la conservation de la marchandise et la tenir a disposition de l''expéditeur. Au-delà d''un délai de garde raisonnable, il peut facturer des frais de stockage.</p></blockquote>',
    4)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 10.5 : Vocabulaire essentiel du Chapitre 10
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '10-5-vocabulaire-essentiel-du-chapitre-10',
    '10.5 — Vocabulaire essentiel du Chapitre 10',
    '<p>Terme Définition Retour de marchandise Transport d''une marchandise du destinataire vers l''expéditeur — après refus ou demande Colis en souffrance Colis non-livre stocke sur la plateforme dans l''attente d''une résolution Avis de passage Notification laissée au destinataire absent lui indiquant une tentative de livraison Laissé pour compte Colis refuse par le destinataire — en attente d''instruction de l''expéditeur Retour e-commerce Retour d''un article commande en ligne par un consommateur final Frais de stockage Facturation du dépôt de marchandise en souffrance au-delà d''un délai raisonnable</p>',
    5)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- ─── Chapitre 11 : La gestion des supports de charge ───
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp2-ch11-la-gestion-des-supports-de-charge',
    'Chapitre 11 — La gestion des supports de charge consignés ou loués',
    'CCP2 GOTRM · 6 leçons',
    'debutant', 72, 31)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 31, true)
  ON CONFLICT DO NOTHING;

  v_count_modules := v_count_modules + 1;

  -- Leçon 11.1 : Pourquoi gérer les supports de charge ?
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '11-1-pourquoi-gerer-les-supports-de-charge',
    '11.1 — Pourquoi gérer les supports de charge ?',
    '<p>Les supports de charge (palettes, Rolls, caisses palettes, big-bags...) sont des actifs qui ont une valeur économique. Quand ils sont consignes ou loues, ils doivent être retournes ou remplacés. Un gestionnaire qui ne suit pas ses supports de charge accumule des pertes financières (palettes non retournées) et des litiges avec ses clients et sous-traitants.</p>',
    1)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 11.2 : Les systèmes de gestion des supports de charge
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '11-2-les-systemes-de-gestion-des-supports-de-charg',
    '11.2 — Les systèmes de gestion des supports de charge',
    '<p>Système Description Suivi requis Palette propriétaire L''entreprise possède ses propres palettes — les gère en interne Comptage à chaque échange — écart = perte directe Palette consignée Le client fournit des palettes consignées — à retourner en échange à la livraison Fiche de suivi par client — échange palette pleine contre palette vide Palette pool (CHEP, EPS...) Palettes louées a un prestataire — utilisation puis restitution au réseau Bon de restitution — vérification des stocks au départ/arrivée Palette a usage unique Palette non récupérable — destruction apres usage Pas de suivi de retour — suivi du cout</p>',
    2)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 11.3 : Le suivi des palettes consignées
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '11-3-le-suivi-des-palettes-consignees',
    '11.3 — Le suivi des palettes consignées',
    '<p>Pour les palettes consignées, le gestionnaire tient un compte palette par client. Chaque livraison génère un échange : palettes chargées en sortie contre palettes vides reçues en entrée. Un solde négatif signifie que le client doit des palettes, un solde positif que le transporteur en doit.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>SUIVI DU COMPTE PALETTE PAR CLIENT : Palettes livrées (débits) - Palettes reçues en échange (crédits) = SOLDE Solde positif du compte client -&gt; le CLIENT doit des palettes au transporteur Solde négatif -&gt; le TRANSPORTEUR doit des palettes au client Un suivi rigoureux évite les litiges et les pertes financières liées aux palettes non retournées.</p></blockquote>
<blockquote data-callout="example" style="border-left:4px solid #6B7280;background:#F9FAFB;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💼 EXEMPLE</strong></p><p>Suivi compte palette — CLIENT SODICHOIX Début du mois : solde 0 palette Livraison 15/05 : 24 palettes chargées — échange 20 palettes vides -&gt; Débit 24 / Credit 20 -&gt; Solde : +4 (SODICHOIX doit 4 palettes) Livraison 22/05 : 18 palettes chargées — échange 22 palettes vides -&gt; Débit 18 / Credit 22 -&gt; Solde cumule : 4 + 18 - 22 = 0 Fin de mois : solde équilibré -&gt; pas de régularisation nécessaire</p></blockquote>',
    3)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 11.4 : Les Rolls en messagerie
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '11-4-les-rolls-en-messagerie',
    '11.4 — Les Rolls en messagerie',
    '<p>Le roll est un châssis roulant sur roues, utilise en messagerie et en grande distribution. Les Rolls permettent une manutention rapide sans chariot élévateur. Ils sont généralement la propriété des messagers ou loues à des prestataires.</p>
<ul><li>Les Rolls sont comptes au départ de chaque traction et à l''arrivée</li><li>Un bon de transfert de Rolls accompagne chaque traction</li><li>Les écarts de Rolls entre agences font l''objet d''une régularisation financière ou physique</li><li>Les Rolls endommages sont signales et répares ou retires du service</li></ul>',
    4)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 11.5 : La responsabilité du gestionnaire
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '11-5-la-responsabilite-du-gestionnaire',
    '11.5 — La responsabilité du gestionnaire',
    '<blockquote data-callout="regulation" style="border-left:4px solid #1D4ED8;background:#F0F4FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>⚖️ ENCADRE REGLEMENTATION</strong></p><p>Le gestionnaire est responsable du suivi des supports de charge confies a son service. En cas de perte ou de détérioration d''un support de charge consigne, l''entreprise peut être tenue de le rembourser ou de le remplacer. La procédure de contrôle doit être systématique :</p>
<ul><li>Comptage à chaque chargement et déchargement</li><li>Signature du bon d''échange par les deux parties</li><li>Signalement immédiat de tout écart</li><li>Mise à jour du compte palette dans le système informatique</li></ul></blockquote>',
    5)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 11.6 : Vocabulaire essentiel du Chapitre 11
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '11-6-vocabulaire-essentiel-du-chapitre-11',
    '11.6 — Vocabulaire essentiel du Chapitre 11',
    '<p>Terme Définition Palette consignée Palette de valeur fournie par le client — doit être retournée en échange Palette pool Palette gérée par un prestataire (CHEP, EPS) — location à la rotation</p>
<p>CHEP Prestataire de gestion de palettes en pool — identifiable à leur couleur bleue Roll Chassis roulant sur roues pour la messagerie et la grande distribution Compte palette Suivi comptable des palettes par client : entrées / sorties / solde Bon d''échange Document constatant l''échange de palettes pleines contre palettes vides a la livraison Solde palette Différence entre palettes dues par le client et palettes dues par le transporteur Régularisation Remboursement ou retour physique des palettes manquantes en fin de période</p>',
    6)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- ─── Chapitre 12 : Qualité de service et indicateurs de ───
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (v_bloc,
    'ccp2-ch12-qualite-de-service-et-indicateurs-de',
    'Chapitre 12 — Qualité de service et indicateurs de performance CCP2',
    'CCP2 GOTRM · 6 leçons',
    'debutant', 72, 32)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 32, true)
  ON CONFLICT DO NOTHING;

  v_count_modules := v_count_modules + 1;

  -- Leçon 12.1 : Les spécificités de la qualité en messagerie et en sous-trai
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '12-1-les-specificites-de-la-qualite-en-messagerie-',
    '12.1 — Les spécificités de la qualité en messagerie et en sous-traitance',
    '<p>régulière La qualité de service en CCP2 a des spécificités importantes par rapport au CCP1 : le nombre d''intervenants est beaucoup plus élevé (enlèvement, quai départ, traction, quai arrivée, livraison), chacun étant une source potentielle d''anomalie. Le gestionnaire doit donc piloter la qualité sur toute la chaine, y compris chez les sous-traitants.</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>En messagerie, on comptabilise 10 points de rupture de charge pour un envoi avec une seule traction et 18 points pour un envoi avec une plateforme intermédiaire. Chaque point de rupture est une source potentielle de litige. La traçabilité informatique (EDI, scan, suivi en temps réel) est indispensable pour maitriser ces risques.</p></blockquote>',
    1)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 12.2 : Les indicateurs qualité spécifiques CCP2
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '12-2-les-indicateurs-qualite-specifiques-ccp2',
    '12.2 — Les indicateurs qualité spécifiques CCP2',
    '<p>Indicateur Formule Objectif courant Signification Taux de livraison a l''heure Livraisons dans les délais / Total x 100 &gt;= 98% Respect des engagements client Taux d''avaries Envois avaries / Total x &lt; 0,5% Qualité de la manutention et du transport Taux de manquants Envois avec manquant / Total x 100 &lt; 0,1% Sécurisation des flux (vol, dévoyé, perte) Taux de dévoyés Colis achemines a la mauvaise destination / Total x 100 &lt; 0,1% Qualité de l''étiquetage et du zonage Taux de litiges Litiges ouverts / Total x &lt; 1% Qualité globale du service Taux de retours Colis retournes non- livres / Total x 100 &lt; 2% Qualité des informations destinataires Taux de souffrance Colis en attente depuis &gt; 48h / Total x 100 &lt; 0,5% Réactivité SAV et gestion des retours</p>',
    2)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 12.3 : Le pilotage des sous-traitants réguliers
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '12-3-le-pilotage-des-sous-traitants-reguliers',
    '12.3 — Le pilotage des sous-traitants réguliers',
    '<p>Le gestionnaire ne suit pas seulement sa propre qualité — il évalue également la qualité de service de ses sous-traitants réguliers. Des grilles d''évaluation périodiques permettent de détecter les dérives avant qu''elles n''impactent la relation client.</p>
<p>GRILLE D''EVALUATION — Sous-traitant regulier CRITERES D''EVALUATION D''UN SOUS-TRAITANT REGULIER : PERFORMANCE OPERATIONNELLE :</p>
<ul><li>Respect des horaires de prise en charge et de livraison</li><li>Taux d''avaries et de manquants génères</li><li>Taux de présentabilité des véhicules (propretés, équipements conformes)</li><li>Réactivité en cas d''alea (signalement, solution de substitution)</li></ul>
<p>CONFORMITE REGLEMENTAIRE :</p>
<ul><li>Respect de la RSE (constate par les relevés tachygraphe)</li><li>Documents de bord complets et conformes</li><li>Qualifications conducteurs a jour (FIMO/FCO, ADR si applicable)</li></ul>
<p>CONFORMITE ADMINISTRATIVE :</p>
<ul><li>Situation administrative a jour (licence, URSSAF, assurance)</li><li>A vérifier tous les 6 mois minimum</li></ul>
<p>COMMUNICATION :</p>
<ul><li>Signalement proactif des aléas</li><li>Qualité des documents fournis (bordereau, EDI)</li><li>Réactivité en cas de litige</li></ul>',
    3)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 12.4 : Les actions correctives
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '12-4-les-actions-correctives',
    '12.4 — Les actions correctives',
    '<p>Dérive constatée Action corrective possible Taux d''avaries élevé chez un sous-traitant Audit des pratiques de chargement / rappel des consignes / visite sur site Retards chroniques sur un trafic Analyse des causes (RSE, distance, horaires) / révision du plan de transport Dévoyés fréquents Contrôle de l''étiquetage / formation des équipes quai / révision des codes d''acheminement SAV client insatisfaisant Mise en place d''un suivi en temps réel / amélioration procédure de réserves Taux de souffrance élevé Amélioration des informations destinataires / relance systématique sous 24h Non-conformité administrative d''un sous- traitant Suspension jusqu''à régularisation / chercher un sous-traitant de remplacement</p>',
    4)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 12.5 : Le rapport d'activité et la remontée d'information
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '12-5-le-rapport-d-activite-et-la-remontee-d-inform',
    '12.5 — Le rapport d''activité et la remontée d''information',
    '<p>Le gestionnaire remonte régulièrement a sa hiérarchie les indicateurs de performance de son activité. Ce reporting permet à la direction de suivre l''évolution de la qualité et de la rentabilité, et de prendre les décisions stratégiques nécessaires (investissement, renforcement des effectifs, renégociation des contrats...).</p>
<blockquote data-callout="retain" style="border-left:4px solid #2563EB;background:#EEF6FF;padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>💡 A RETENIR</strong></p><p>Un bon rapport d''activité CCP2 comprend :</p>
<ul><li>Les indicateurs qualité de la période (vs objectifs et vs période précédente)</li><li>L''analyse des écarts significatifs et leurs causes identifiées</li><li>Les actions correctives mises en œuvre ou proposées</li><li>Le suivi des performances des sous-traitants réguliers</li><li>Les sujets nécessitant une décision de la hiérarchie</li></ul></blockquote>',
    5)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  -- Leçon 12.6 : Vocabulaire essentiel du Chapitre 12
  INSERT INTO public.lessons (module_id, slug, title, content_md, "order")
  VALUES (v_module,
    '12-6-vocabulaire-essentiel-du-chapitre-12',
    '12.6 — Vocabulaire essentiel du Chapitre 12',
    '<p>Terme Définition Taux de dévoyés Pourcentage de colis achemines vers la mauvaise destination Taux de souffrance Pourcentage de colis en attente de livraison depuis plus de 48h Traçabilité Capacite à connaitre la position et le statut d''un envoi à tout moment Audit Vérification systématique des pratiques d''un sous-traitant ou d''un service interne Grille d''évaluation Outil de mesure périodique de la performance d''un sous- traitant régulier Reporting Remontée périodique des indicateurs de performance a la hiérarchie Plan de progrès Document fixant les objectifs d''amélioration et les actions a mettre en œuvre KPI Key Performance Indicator — indicateur clé de performance — mesure un objectif spécifique</p>
<p>Félicitations pour votre progression dans ce livret consacré au CCP2 du Titre Professionnel Gestionnaire des Opérations de Transport Routier de Marchandises (GOTRM). Au fil des chapitres, vous avez découvert les méthodes, outils et règles indispensables au pilotage des trafics réguliers, à la gestion de la sous-traitance, à l’organisation des flux de messagerie ainsi qu’au suivi de la qualité de service dans une exploitation transport. Le métier de gestionnaire transport exige à la fois :</p>
<ul><li>de la rigueur ;</li><li>de l’organisation ;</li><li>de la réactivité ;</li><li>une bonne maîtrise réglementaire ;</li><li>et une forte capacité d’anticipation.</li></ul>
<p>Derrière chaque livraison réussie se trouvent des femmes et des hommes capables d’organiser, coordonner et sécuriser l’ensemble des opérations de transport. Ce livret constitue une base solide pour :</p>
<ul><li>préparer votre examen ;</li><li>développer vos compétences professionnelles ;</li><li>et évoluer dans le secteur du transport et de la logistique.</li></ul>
<p>La réussite dans ce métier repose avant tout sur la pratique, l’analyse des situations réelles et la capacité à trouver des solutions efficaces face aux aléas du quotidien. Nous vous invitons désormais à poursuivre votre entraînement avec le livret d’exercices CCP2, afin de mettre en application les connaissances acquises au travers de cas professionnels proches des conditions réelles d’exploitation. Nous vous souhaitons une excellente réussite dans votre parcours de formation et dans votre future carrière professionnelle dans le transport routier de marchandises. « Le transport ne consiste pas uniquement à déplacer des marchandises, mais à organiser des flux, garantir des délais et assurer la satisfaction des clients au quotidien. »</p>',
    6)
  ON CONFLICT (module_id, slug) DO UPDATE
    SET title = EXCLUDED.title, content_md = EXCLUDED.content_md;
  v_count_lessons := v_count_lessons + 1;

  RAISE NOTICE '────────────────────────────────────────────────────';
  RAISE NOTICE 'CCP2 GOTRM — Import terminé';
  RAISE NOTICE '────────────────────────────────────────────────────';
  RAISE NOTICE '  Modules créés/MAJ : %', v_count_modules;
  RAISE NOTICE '  Leçons créées/MAJ : %', v_count_lessons;
END $$;
