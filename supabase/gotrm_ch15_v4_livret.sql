-- ============================================================================
-- GOTRM — Chapitre 15 : Transport international opérationnel
-- Source : Livret pro CCP1 GOTRM v2 (pages 59-62)
-- Fichier idempotent : peut être ré-exécuté sans doublon.
-- ============================================================================

DO $ch15_v4$
DECLARE
  v_formation uuid;
  v_bloc      int;
  v_module    uuid;
  v_lesson    uuid;
  v_quiz      uuid;
BEGIN
  -- 1) Formation GOTRM
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable.';
  END IF;

  -- 2) Bloc BC1
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
  IF v_bloc IS NULL THEN
    INSERT INTO public.blocs (code, title, description, "order")
    VALUES ('BC1', 'Bloc 1 — Compétences générales', 'Bloc générique partagé.', 1)
    ON CONFLICT (code) DO NOTHING
    RETURNING id INTO v_bloc;
    IF v_bloc IS NULL THEN
      SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
    END IF;
  END IF;
  IF v_bloc IS NULL THEN
    RAISE EXCEPTION 'Bloc BC1 introuvable.';
  END IF;

  -- 3) Nettoyage idempotent
  DELETE FROM public.modules WHERE slug = 'gotrm-ch15-international';
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch15:%';

  -- 4) Module
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Chapitre 15 — Transport international opérationnel',
    'gotrm-ch15-international',
    v_bloc,
    'Maîtriser le transport international : CMR, formalités douanières (intra-UE, hors UE, TIR), cabotage (règlement UE 1072/2009), taxes de transit (Eurovignette, Maut, RPLP) et Incoterms (EXW, FCA, DAP, DDP).',
    'avance',
    70,
    150
  )
  RETURNING id INTO v_module;

  -- 5) Lien formation ↔ module
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 150, true)
  ON CONFLICT DO NOTHING;

  -- 6) Leçon
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module,
    'Transport international opérationnel',
    'international',
    1,
    70,
$lesson$
# Chapitre 15 — Transport international opérationnel

Le transport international implique des contraintes supplémentaires par rapport au transport national : documents spécifiques, formalités douanières, régimes de responsabilité particuliers, taxes de transit et règles de cabotage. Ce chapitre donne les bases nécessaires pour organiser et tarifer une opération internationale.

---

## 15.1 — Ce qui change par rapport au transport national

| Critère | Transport national | Transport international |
|---|---|---|
| Document principal | Lettre de voiture française | CMR (Convention de Genève) |
| TVA | 20 % | 0 % (exonération de TVA) |
| Douane | Inexistante (marché unique UE) | Obligatoire hors UE (Suisse, Royaume-Uni, Maroc…) |
| Licence requise | Licence transport intérieur | Licence communautaire (intra-UE) ou autorisation bilatérale (hors UE) |
| Cabotage | Non applicable | Strictement encadré : 3 opérations en 7 jours maximum |

---

## 15.2 — La lettre de voiture CMR

La CMR est obligatoire pour tout transport entre pays signataires de la Convention de Genève. Elle est établie en 3 exemplaires originaux signés par l'expéditeur et le transporteur :

- **Exemplaire rouge** — pour l'expéditeur
- **Exemplaire bleu** — accompagne la marchandise (remis au destinataire)
- **Exemplaire vert** — conservé par le transporteur

> **À RETENIR**
>
> La CMR engage la responsabilité du transporteur dès la prise en charge jusqu'à la livraison.
>
> Plafond d'indemnisation CMR : **8,33 DTS par kg brut manquant ou avarié**.
>
> (DTS = Droit de Tirage Spécial — unité monétaire du FMI, environ 11 à 13 € en 2025)
>
> Pour les marchandises de valeur élevée : recommander la déclaration de valeur avant le transport.

---

## 15.3 — La douane et les régimes douaniers

### Transport intra-Union Européenne

Au sein de l'UE, la libre circulation des marchandises supprime les formalités douanières entre États membres. Le gestionnaire n'a pas à gérer de passage en douane, sauf pour certaines marchandises soumises à des contrôles spécifiques (médicaments, armes, espèces protégées…).

### Transport hors UE

| Destination | Formalité principale | Document clé |
|---|---|---|
| Suisse | Déclaration douanière à chaque frontière | DAU (Document Administratif Unique) |
| Royaume-Uni (post-Brexit) | Contrôle douanier complet — délais importants depuis 2021 | DAU export + customs declaration UK |
| Maroc, Turquie, pays hors UE | Transit douanier — régime TIR recommandé | Carnet TIR + CMR + autorisation bilatérale ou CEMT |

Le carnet TIR est un document douanier qui permet le transit international sans contrôle systématique à chaque frontière. Il est garanti par une caisse de cautionnement en cas d'incident.

---

## 15.4 — Le cabotage

> **RÈGLEMENTATION**
>
> Règlement UE n°1072/2009 :
> Le cabotage est le transport national effectué par un transporteur étranger dans un pays tiers.
>
> **RÈGLE EN VIGUEUR :**
> - Maximum **3 opérations de cabotage en 7 jours** suivant une livraison internationale.
> - Après 7 jours, le véhicule doit quitter le pays concerné pendant **4 jours minimum**.
>
> **INFRACTION** : cabotage illégal = immobilisation du véhicule + amende jusqu'à **15 000 €**.

---

## 15.5 — Les taxes de transit et coûts à intégrer

| Taxe / Redevance | Pays / Zone | Calcul |
|---|---|---|
| Eurovignette | Allemagne, Belgique, Pays-Bas, Luxembourg… | Par km selon norme Euro du véhicule |
| Maut (péage PL) | Allemagne | Par km × PTAC × facteur émission |
| Taxe poids lourd (RPLP) | Suisse | Par km × poids × facteur d'émission (env. 0,03 CHF/t-km) |
| Vignette autoroute | Autriche, Slovénie, République tchèque… | Forfait par période — à acheter avant l'entrée |
| Péages autoroutiers | France, Espagne, Italie, Portugal… | Par trajet — facturer au réel ou intégrer au TK |

---

## 15.6 — Les Incoterms

Les Incoterms (International Commercial Terms) sont des termes commerciaux internationaux qui définissent la répartition des obligations, des coûts et des risques entre le vendeur et l'acheteur. Le gestionnaire doit en comprendre les principaux pour savoir qui organise et paie le transport.

| Incoterm | Signification | Qui organise le transport ? | Transfert de risque |
|---|---|---|---|
| EXW | Ex Works — à l'usine | Acheteur | Dès que marchandise disponible à l'usine |
| FCA | Free Carrier — franco transporteur | Acheteur | À la remise au transporteur désigné |
| DAP | Delivered at Place — rendu au lieu | Vendeur | À la livraison, avant déchargement |
| DDP | Delivered Duty Paid — rendu droits acquittés | Vendeur (tout inclus) | À la livraison, droits de douane inclus |

---

## 15.7 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| Licence communautaire | Autorisation de transport dans toute l'UE — validité 10 ans — copie certifiée à bord obligatoire |
| Cabotage | Transport national effectué par un transporteur étranger — limité à 3 opérations / 7 jours |
| Carnet TIR | Document douanier permettant le transit international sans contrôle à chaque frontière |
| DAU | Document Administratif Unique — déclaration douanière d'exportation hors UE |
| Autorisation bilatérale | Accord entre deux pays autorisant un transporteur à effectuer des voyages entre eux |
| Eurovignette | Taxe kilométrique applicable aux poids lourds dans plusieurs pays du nord de l'UE |
| Maut | Péage autoroutier allemand — calculé au km selon le poids et la norme Euro |
| Incoterms | Termes commerciaux internationaux définissant la répartition des risques et des coûts |
| DTS | Droits de Tirage Spéciaux — unité de compte FMI pour les plafonds d'indemnisation CMR |
| Exonération TVA | Absence de TVA sur les transports internationaux — art. 262 CGI |
$lesson$,
    'CMR, douane, cabotage, taxes transit, Incoterms.'
  )
  RETURNING id INTO v_lesson;

  -- 7) Banque de questions : 12 QCM + 4 QR
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES
  -- ===================== QCM 1 (facile) =====================
  (v_formation, v_module, 'qcm',
   'Quel est le document principal qui accompagne une marchandise en transport international entre pays signataires de la Convention de Genève ?',
   '[{"id":"a","label":"La lettre de voiture française","is_correct":false},
     {"id":"b","label":"La CMR (Convention de Genève)","is_correct":true},
     {"id":"c","label":"Le DAU (Document Administratif Unique)","is_correct":false},
     {"id":"d","label":"Le carnet TIR","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch15','livret','cmr'],
   'mft-2026-gotrm-livret:ch15:qcm:1', true,
   'La CMR (Convention de Genève) est le document principal du transport international entre pays signataires.'),

  -- ===================== QCM 2 (facile) =====================
  (v_formation, v_module, 'qcm',
   'Quel est le taux de TVA applicable à un transport international ?',
   '[{"id":"a","label":"20 %","is_correct":false},
     {"id":"b","label":"10 %","is_correct":false},
     {"id":"c","label":"0 % (exonération de TVA)","is_correct":true},
     {"id":"d","label":"5,5 %","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch15','livret','tva'],
   'mft-2026-gotrm-livret:ch15:qcm:2', true,
   'Les transports internationaux sont exonérés de TVA (0 %) — article 262 CGI.'),

  -- ===================== QCM 3 (facile) =====================
  (v_formation, v_module, 'qcm',
   'En combien d''exemplaires originaux la CMR est-elle établie ?',
   '[{"id":"a","label":"2 exemplaires","is_correct":false},
     {"id":"b","label":"3 exemplaires","is_correct":true},
     {"id":"c","label":"4 exemplaires","is_correct":false},
     {"id":"d","label":"5 exemplaires","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch15','livret','cmr'],
   'mft-2026-gotrm-livret:ch15:qcm:3', true,
   'La CMR est établie en 3 exemplaires originaux : rouge (expéditeur), bleu (marchandise), vert (transporteur).'),

  -- ===================== QCM 4 (facile) =====================
  (v_formation, v_module, 'qcm',
   'Quelle couleur d''exemplaire CMR accompagne la marchandise et est remis au destinataire ?',
   '[{"id":"a","label":"L''exemplaire rouge","is_correct":false},
     {"id":"b","label":"L''exemplaire bleu","is_correct":true},
     {"id":"c","label":"L''exemplaire vert","is_correct":false},
     {"id":"d","label":"L''exemplaire jaune","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch15','livret','cmr'],
   'mft-2026-gotrm-livret:ch15:qcm:4', true,
   'L''exemplaire bleu accompagne la marchandise et est remis au destinataire. Le rouge est pour l''expéditeur, le vert pour le transporteur.'),

  -- ===================== QCM 5 (moyen) =====================
  (v_formation, v_module, 'qcm',
   'Quel est le plafond d''indemnisation prévu par la CMR en cas de marchandise manquante ou avariée ?',
   '[{"id":"a","label":"5,00 DTS par kg brut","is_correct":false},
     {"id":"b","label":"8,33 DTS par kg brut","is_correct":true},
     {"id":"c","label":"11,50 DTS par kg brut","is_correct":false},
     {"id":"d","label":"15,00 DTS par kg brut","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch15','livret','cmr','indemnisation'],
   'mft-2026-gotrm-livret:ch15:qcm:5', true,
   'Le plafond d''indemnisation CMR est de 8,33 DTS par kg brut manquant ou avarié (DTS = unité monétaire du FMI, environ 11 à 13 € en 2025).'),

  -- ===================== QCM 6 (moyen) =====================
  (v_formation, v_module, 'qcm',
   'Quelle règle s''applique au cabotage selon le règlement UE n°1072/2009 ?',
   '[{"id":"a","label":"Maximum 5 opérations en 10 jours","is_correct":false},
     {"id":"b","label":"Maximum 3 opérations en 7 jours suivant une livraison internationale","is_correct":true},
     {"id":"c","label":"Maximum 2 opérations en 5 jours","is_correct":false},
     {"id":"d","label":"Aucune limite tant que la licence communautaire est valide","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch15','livret','cabotage'],
   'mft-2026-gotrm-livret:ch15:qcm:6', true,
   'Le règlement UE n°1072/2009 limite le cabotage à 3 opérations en 7 jours suivant une livraison internationale.'),

  -- ===================== QCM 7 (moyen) =====================
  (v_formation, v_module, 'qcm',
   'Quel est le montant maximal de l''amende en cas de cabotage illégal ?',
   '[{"id":"a","label":"5 000 €","is_correct":false},
     {"id":"b","label":"10 000 €","is_correct":false},
     {"id":"c","label":"15 000 €","is_correct":true},
     {"id":"d","label":"30 000 €","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch15','livret','cabotage','sanction'],
   'mft-2026-gotrm-livret:ch15:qcm:7', true,
   'Cabotage illégal = immobilisation du véhicule + amende jusqu''à 15 000 €.'),

  -- ===================== QCM 8 (moyen) =====================
  (v_formation, v_module, 'qcm',
   'Quel document douanier permet le transit international sans contrôle systématique à chaque frontière (notamment vers le Maroc ou la Turquie) ?',
   '[{"id":"a","label":"Le DAU","is_correct":false},
     {"id":"b","label":"La CMR","is_correct":false},
     {"id":"c","label":"Le carnet TIR","is_correct":true},
     {"id":"d","label":"La licence communautaire","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch15','livret','douane','tir'],
   'mft-2026-gotrm-livret:ch15:qcm:8', true,
   'Le carnet TIR permet le transit international sans contrôle systématique à chaque frontière. Il est garanti par une caisse de cautionnement.'),

  -- ===================== QCM 9 (moyen) =====================
  (v_formation, v_module, 'qcm',
   'Pour un transport en Suisse, quelle taxe poids lourd s''applique et selon quel calcul ?',
   '[{"id":"a","label":"Eurovignette — par km selon norme Euro","is_correct":false},
     {"id":"b","label":"Maut — par km × PTAC × facteur émission","is_correct":false},
     {"id":"c","label":"RPLP — par km × poids × facteur d''émission (env. 0,03 CHF/t-km)","is_correct":true},
     {"id":"d","label":"Vignette autoroute — forfait par période","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch15','livret','taxes','suisse'],
   'mft-2026-gotrm-livret:ch15:qcm:9', true,
   'En Suisse, la RPLP (taxe poids lourd) se calcule en km × poids × facteur d''émission, environ 0,03 CHF/t-km.'),

  -- ===================== QCM 10 (difficile) =====================
  (v_formation, v_module, 'qcm',
   'Pour un Incoterm DDP (Delivered Duty Paid), qui organise le transport et où s''effectue le transfert de risque ?',
   '[{"id":"a","label":"Acheteur — transfert dès mise à disposition à l''usine","is_correct":false},
     {"id":"b","label":"Vendeur (tout inclus) — transfert à la livraison, droits de douane inclus","is_correct":true},
     {"id":"c","label":"Acheteur — transfert à la remise au transporteur désigné","is_correct":false},
     {"id":"d","label":"Vendeur — transfert à la livraison avant déchargement, hors droits de douane","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch15','livret','incoterms'],
   'mft-2026-gotrm-livret:ch15:qcm:10', true,
   'En DDP, le vendeur organise tout le transport, paie les droits de douane et le risque ne se transfère qu''à la livraison.'),

  -- ===================== QCM 11 (difficile) =====================
  (v_formation, v_module, 'qcm',
   'Pour un Incoterm EXW (Ex Works), où s''effectue le transfert de risque entre vendeur et acheteur ?',
   '[{"id":"a","label":"Dès que la marchandise est disponible à l''usine","is_correct":true},
     {"id":"b","label":"À la remise au transporteur désigné","is_correct":false},
     {"id":"c","label":"À la livraison, avant déchargement","is_correct":false},
     {"id":"d","label":"À la livraison, droits de douane inclus","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch15','livret','incoterms'],
   'mft-2026-gotrm-livret:ch15:qcm:11', true,
   'En EXW (Ex Works — à l''usine), l''acheteur organise le transport et le risque lui est transféré dès que la marchandise est mise à disposition à l''usine.'),

  -- ===================== QCM 12 (difficile) =====================
  (v_formation, v_module, 'qcm',
   'Pour un transport vers le Royaume-Uni post-Brexit, quels documents douaniers sont nécessaires ?',
   '[{"id":"a","label":"CMR uniquement (libre circulation maintenue)","is_correct":false},
     {"id":"b","label":"DAU export + customs declaration UK","is_correct":true},
     {"id":"c","label":"Carnet TIR + autorisation CEMT","is_correct":false},
     {"id":"d","label":"Aucun document douanier requis","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch15','livret','douane','brexit'],
   'mft-2026-gotrm-livret:ch15:qcm:12', true,
   'Depuis 2021 (post-Brexit), le transport vers le Royaume-Uni nécessite un contrôle douanier complet : DAU export côté UE + customs declaration côté UK.'),

  -- ===================== QR 1 =====================
  (v_formation, v_module, 'qr',
   'Citez les 5 critères qui distinguent le transport national du transport international (selon le tableau du chapitre 15.1).',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch15','livret','qr','national-international'],
   'mft-2026-gotrm-livret:ch15:qr:1', true,
   'Les 5 critères : (1) Document principal — lettre de voiture française vs CMR ; (2) TVA — 20 % vs 0 % (exonération) ; (3) Douane — inexistante (UE) vs obligatoire hors UE ; (4) Licence requise — licence transport intérieur vs licence communautaire ou autorisation bilatérale ; (5) Cabotage — non applicable vs encadré (3 opérations en 7 jours maximum).'),

  -- ===================== QR 2 =====================
  (v_formation, v_module, 'qr',
   'Décrivez la règle de cabotage applicable depuis le règlement UE n°1072/2009 (nombre d''opérations, délais, sortie obligatoire) et indiquez la sanction en cas d''infraction.',
   NULL,
   6, 'moyen', ARRAY['gotrm','ch15','livret','qr','cabotage'],
   'mft-2026-gotrm-livret:ch15:qr:2', true,
   'Règle (règlement UE n°1072/2009) : maximum 3 opérations de cabotage en 7 jours suivant une livraison internationale ; après 7 jours, le véhicule doit quitter le pays concerné pendant 4 jours minimum. Infraction : cabotage illégal = immobilisation du véhicule + amende jusqu''à 15 000 €.'),

  -- ===================== QR 3 =====================
  (v_formation, v_module, 'qr',
   'Listez les 4 principaux Incoterms vus au chapitre 15.6 (sigle, signification, qui organise le transport, transfert de risque).',
   NULL,
   6, 'difficile', ARRAY['gotrm','ch15','livret','qr','incoterms'],
   'mft-2026-gotrm-livret:ch15:qr:3', true,
   '(1) EXW — Ex Works (à l''usine) : acheteur organise ; transfert de risque dès marchandise disponible à l''usine. (2) FCA — Free Carrier (franco transporteur) : acheteur organise ; transfert à la remise au transporteur désigné. (3) DAP — Delivered at Place (rendu au lieu) : vendeur organise ; transfert à la livraison, avant déchargement. (4) DDP — Delivered Duty Paid (rendu droits acquittés) : vendeur (tout inclus) ; transfert à la livraison, droits de douane inclus.'),

  -- ===================== QR 4 =====================
  (v_formation, v_module, 'qr',
   'Le plafond CMR est de 8,33 DTS/kg. Pour un sinistre concernant 250 kg de marchandise (DTS ≈ 12 € en 2025), calculez l''indemnisation maximale et expliquez la précaution à prendre pour les marchandises de valeur élevée.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch15','livret','qr','cmr','calcul'],
   'mft-2026-gotrm-livret:ch15:qr:4', true,
   'Calcul : 250 kg × 8,33 DTS/kg = 2 082,5 DTS. Conversion : 2 082,5 × 12 € ≈ 24 990 €. Précaution : pour les marchandises de valeur élevée (au-delà du plafond CMR de 8,33 DTS/kg), il est recommandé d''effectuer une déclaration de valeur avant le transport pour relever le plafond d''indemnisation, ou de souscrire une assurance ad valorem complémentaire.');

  -- 8) Quiz d'entraînement
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Chapitre 15 — Quiz d''entraînement',
    'Quiz d''entraînement (12 questions) sur le transport international : CMR, douane, cabotage, taxes de transit et Incoterms.',
    'entrainement',
    NULL,
    70
  )
  RETURNING id INTO v_quiz;

  -- 9) Lien quiz ↔ banque (les 12 QCM)
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch15:qcm:%';

  RAISE NOTICE '✓ Module Ch15 (Transport international opérationnel) importé.';
END
$ch15_v4$;
