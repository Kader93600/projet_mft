-- =====================================================================
-- GOTRM — Chapitre 4 : Calculer le coût de revient et tarifer une prestation
-- Source : Livret CCP1 GOTRM V2 (pages 15 à 18)
-- Idempotent — relance possible sans casser les FK
-- =====================================================================

DO $ch04_v4$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid; v_lesson uuid; v_quiz uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;

  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
  IF v_bloc IS NULL THEN
    INSERT INTO public.blocs (code, title, description, "order")
    VALUES ('BC1', 'Bloc 1 — Compétences générales', 'Bloc générique partagé.', 1)
    ON CONFLICT (code) DO NOTHING RETURNING id INTO v_bloc;
    IF v_bloc IS NULL THEN SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1'; END IF;
  END IF;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Bloc BC1 introuvable.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-ch04-cout-revient-tarification';
  DELETE FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref LIKE 'mft-2026-gotrm-livret:ch04:%';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Chapitre 4 — Calculer le coût de revient et tarifer une prestation',
          'gotrm-ch04-cout-revient-tarification', v_bloc,
          'Maîtriser les références CNR, la structure des coûts (TK/TH/TJ), les formules binôme/trinôme et les méthodes de tarification (messagerie, lots partiels, lots complets). Comprendre la révision de prix et le pied de facture carburant.',
          'avance', 80, 40)
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 40, true) ON CONFLICT DO NOTHING;

  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (v_module, 'Calculer le coût de revient et tarifer une prestation',
          'cout-revient-tarification', 1, 80,
$lesson$
# Calculer le coût de revient et tarifer une prestation

> 🎯 **Objectifs pédagogiques**
>
> - Identifier les références tarifaires publiées par le CNR.
> - Connaître la structure des coûts d'exploitation (TK / TH / TJ / structure).
> - Maîtriser les formules binôme et trinôme du coût de revient.
> - Appliquer les méthodes de tarification : messagerie, lots partiels, lots complets.
> - Distinguer les prestations annexes facturables.
> - Comprendre la révision de prix et le pied de facture carburant (art. L.3222-1, L.3222-2).

La tarification est au cœur du métier de gestionnaire. Savoir calculer précisément le coût d'une opération, appliquer les règles de tarification selon le type de transport et construire un prix de vente cohérent sont des compétences directement évaluées à l'examen. Ce chapitre présente les méthodes essentielles.

## 4.1 — Les références tarifaires

Chaque entreprise de transport construit ses propres grilles tarifaires à partir de ses coûts réels d'exploitation. Pour aider les entreprises à connaître les coûts du marché et à construire leurs prix, le **Comité National Routier (CNR)** publie régulièrement des indices de coûts de référence : coût au kilomètre, coût horaire, coût journalier, évolution du prix du gazole.

## 4.2 — La structure des coûts d'exploitation

| Catégorie de charges | Composantes | Caractéristique |
|---|---|---|
| Charges variables (TK) | Carburant, pneumatiques, entretien courant, péages | Évoluent proportionnellement au kilométrage parcouru |
| Charges de conduite (TH) | Salaires des conducteurs, charges sociales, frais de route | Liées au nombre d'heures de service du conducteur |
| Charges fixes (TJ) | Amortissement du véhicule, assurances, taxes, frais financiers | Supportées que le véhicule roule ou non |
| Charges de structure | Frais administratifs, informatique, loyers, encadrement | Réparties sur l'ensemble de la flotte |

## 4.3 — Le coût de revient : formules binôme et trinôme

> 📌 **À retenir**
>
> Trois termes correspondent aux trois unités d'œuvre du transport :
>
> - **TK** = terme kilométrique (coût par km parcouru — charges variables)
> - **TH** = terme horaire (coût par heure de service — charges de conduite)
> - **TJ** = terme journalier (coût par jour d'exploitation — charges fixes)
>
> **FORMULE TRINÔME (complète) :**
> Coût global = (TK × km) + (TH × heures) + (TJ × jours)
>
> **FORMULE BINÔME (simplifiée) :**
> Coût global = (TK × km) + (TJ × jours)

Prix de vente HT = Coût global × (1 + taux de marge)

> 📌 **Exemple — Clermont-Ferrand → Marseille**
>
> **Données :** TK = 0,615 €/km — TH = 27,08 €/h — TJ = 198,35 €/j
> **Mission :** Clermont-Ferrand → Marseille — 420 km — 8 h de service — 1 jour
>
> Coût = (0,615 × 420) + (27,08 × 8) + (198,35 × 1)
>      = 258,30 + 216,64 + 198,35 = **673,29 €**
>
> Marge souhaitée : 15 %
> Prix de vente HT = 673,29 × 1,15 = **774,28 €**

## 4.4 — La tarification en messagerie

En messagerie, le **poids taxable** est égal au maximum du poids réel et du poids volumétrique (le poids métrique est rarement appliqué en messagerie). Le prix se lit dans une grille tarifaire à partir du poids taxable et de la zone de destination.

> 💡 **Méthode — Tarification messagerie en 6 étapes**
>
> **Étape 1 :** Calculer le poids taxable = max (poids réel / poids volumétrique). Arrondir au kg supérieur.
>
> **Étape 2 :** Identifier le prix dans la grille selon le poids taxable et la zone.
> - Si poids < 100 kg → appliquer le prix forfaitaire de la tranche
> - Si poids ≥ 100 kg → prix = (poids taxable × prix aux 100 kg) / 100
>
> **Étape 3 :** Calculer le prix de transport.
>
> **Étape 4 :** Appliquer la règle du « payant pour » : comparer le prix de la tranche réelle avec celui de la tranche supérieure. Retenir le moins cher.
>
> **Étape 5 :** Ajouter les frais accessoires (port payé/port dû, valeur déclarée, contre-remboursement…)
>
> **Étape 6 :** Prix HT = Prix de transport + frais accessoires

> 📌 **Exemple — Envoi 290 kg, zone 3**
>
> Poids taxable : 290 kg — Tarif zone 3 :
> Tranche 180–300 kg = 4,50 €/100 kg — Tranche 300–500 kg = 3,80 €/100 kg
>
> **Option 1 (tarif normal 290 kg) :** (290 × 4,50) / 100 = **13,05 €**
>
> **Option 2 (payant pour 300 kg) :** (300 × 3,80) / 100 = **11,40 €**
>
> → On retient **11,40 €** — le payant pour s'applique ici.

## 4.5 — La tarification des lots partiels

En lots partiels, le poids taxable est le maximum des trois valeurs : **poids réel, poids volumétrique, poids métrique**. Il est arrondi aux 100 kg supérieurs. Trois méthodes de tarification coexistent selon les entreprises.

| Méthode | Formule | Usage |
|---|---|---|
| À la tonne | Prix de transport = Poids taxable (en t) × Prix à la tonne (grille) | Envois lourds |
| À la palette | Prix de transport = Nombre de palettes × Prix à la palette (grille) | Envois palettisés |
| Au mètre linéaire | Prix de transport = Forfait lu dans la grille (zone × mètres linéaires) | Envois occupant beaucoup de plancher |

## 4.6 — La tarification des lots complets

Pour un lot complet, le véhicule est entièrement dédié à un seul client. Le prix se calcule à partir du **coût de revient** (formule binôme ou trinôme) auquel on ajoute la **marge commerciale**.

## 4.7 — Les prestations annexes

| Prestation | Description |
|---|---|
| Péages | Autoroutes, tunnels, ponts — facturés au réel ou intégrés dans le TK selon le contrat |
| Chargement / déchargement | Facturable si le conducteur participe aux manutentions |
| Valeur déclarée | Couverture d'assurance complémentaire sur la valeur réelle de la marchandise |
| Contre-remboursement | Encaissement du paiement auprès du destinataire — frais fixes + pourcentage |
| Avis de passage / RDV | Notification préalable au destinataire — facturable |
| ADR | Supplément lié au transport de matières dangereuses |
| Température dirigée | Supplément lié à l'utilisation d'un véhicule frigorifique certifié ATP |
| Attente | Temps d'attente au chargement ou au déchargement dépassant une franchise contractuelle |

## 4.8 — La révision de prix : le pied de facture carburant

> ⚠️ **Réglementation**
>
> **Articles L.3222-1 et L.3222-2 du Code des transports :**
>
> Le prix du transport doit être révisé en cas de variations significatives du prix du carburant.
> Le CNR publie chaque mois un indice d'évolution du gazole professionnel.
>
> **Formule de calcul :**
> Supplément = Prix HT × Part carburant contractuelle × [(Indice mois facturation − Indice référence) / Indice référence]
>
> **Sanction : 15 000 € d'amende** pour tout cocontractant refusant de payer un pied de facture justifié.

## 4.9 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| CNR | Comité National Routier — publie les indices de coûts de référence du transport routier |
| TK | Terme kilométrique — coût par kilomètre parcouru (charges variables) |
| TH | Terme horaire — coût par heure de service (charges de conduite) |
| TJ | Terme journalier — coût par jour d'exploitation (charges fixes) |
| Formule trinôme | Coût = TK × km + TH × heures + TJ × jours |
| Poids taxable | Maximum des trois : poids réel / poids volumétrique / poids métrique |
| Règle du payant pour | Possibilité d'appliquer le tarif d'une tranche supérieure si celui-ci est plus avantageux |
| Frais accessoires | Prestations supplémentaires s'ajoutant au prix de transport de base |
| Pied de facture | Révision du prix de transport liée à l'évolution du prix du carburant |
| Marge | Différence entre le prix de vente HT et le coût de revient de la prestation |
$lesson$,
'Coût de revient (binôme/trinôme), tarification messagerie/lots/LC, prestations annexes, pied de facture.')
  RETURNING id INTO v_lesson;

  -- =================================================================
  -- BANQUE DE QUESTIONS — 12 QCM + 4 QR
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES

  -- QCM 1 (facile)
  (v_formation, v_module, 'qcm',
   'Que signifie l''acronyme CNR dans le contexte du transport routier ?',
   '[
     {"id":"a","label":"Conseil National des Routiers","is_correct":false},
     {"id":"b","label":"Comité National Routier","is_correct":true},
     {"id":"c","label":"Centre National de Régulation","is_correct":false},
     {"id":"d","label":"Commission Nationale Routière","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['cnr','references','tarification'],
   'mft-2026-gotrm-livret:ch04:qcm:01', true,
   'Le Comité National Routier (CNR) publie régulièrement des indices de coûts de référence : coût au kilomètre, coût horaire, coût journalier, évolution du prix du gazole.'),

  -- QCM 2 (facile)
  (v_formation, v_module, 'qcm',
   'À quoi correspond le terme TK dans la structure des coûts ?',
   '[
     {"id":"a","label":"Terme kilométrique — coût par km parcouru (charges variables)","is_correct":true},
     {"id":"b","label":"Terme kilométrique — coût par km parcouru (charges fixes)","is_correct":false},
     {"id":"c","label":"Tarif kilométrique pratiqué par le CNR","is_correct":false},
     {"id":"d","label":"Taxe kilométrique applicable aux poids lourds","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['tk','structure-couts'],
   'mft-2026-gotrm-livret:ch04:qcm:02', true,
   'TK = terme kilométrique = coût par km parcouru, qui regroupe les charges variables (carburant, pneumatiques, entretien courant, péages).'),

  -- QCM 3 (facile)
  (v_formation, v_module, 'qcm',
   'Quelles charges composent le terme TJ (terme journalier) ?',
   '[
     {"id":"a","label":"Salaires des conducteurs et charges sociales","is_correct":false},
     {"id":"b","label":"Carburant, pneumatiques et entretien","is_correct":false},
     {"id":"c","label":"Amortissement du véhicule, assurances, taxes, frais financiers","is_correct":true},
     {"id":"d","label":"Frais administratifs et loyers","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['tj','charges-fixes'],
   'mft-2026-gotrm-livret:ch04:qcm:03', true,
   'Le TJ correspond aux charges fixes : amortissement, assurances, taxes, frais financiers. Elles sont supportées que le véhicule roule ou non.'),

  -- QCM 4 (facile)
  (v_formation, v_module, 'qcm',
   'Quelle est la formule trinôme du coût de revient ?',
   '[
     {"id":"a","label":"Coût global = (TK × km) + (TJ × jours)","is_correct":false},
     {"id":"b","label":"Coût global = (TK × km) + (TH × heures) + (TJ × jours)","is_correct":true},
     {"id":"c","label":"Coût global = (TK × heures) + (TH × jours) + (TJ × km)","is_correct":false},
     {"id":"d","label":"Coût global = TK + TH + TJ","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['formule-trinome'],
   'mft-2026-gotrm-livret:ch04:qcm:04', true,
   'Formule trinôme : Coût global = (TK × km) + (TH × heures) + (TJ × jours). La formule binôme simplifiée est : Coût global = (TK × km) + (TJ × jours).'),

  -- QCM 5 (moyen)
  (v_formation, v_module, 'qcm',
   'Comment se calcule le prix de vente HT à partir du coût global ?',
   '[
     {"id":"a","label":"Prix de vente HT = Coût global + Marge fixe","is_correct":false},
     {"id":"b","label":"Prix de vente HT = Coût global × (1 + taux de marge)","is_correct":true},
     {"id":"c","label":"Prix de vente HT = Coût global / (1 − taux de marge)","is_correct":false},
     {"id":"d","label":"Prix de vente HT = Coût global × taux de marge","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['prix-vente','marge'],
   'mft-2026-gotrm-livret:ch04:qcm:05', true,
   'Prix de vente HT = Coût global × (1 + taux de marge). Exemple : 673,29 × 1,15 = 774,28 € pour une marge de 15 %.'),

  -- QCM 6 (moyen)
  (v_formation, v_module, 'qcm',
   'En messagerie, comment se définit le poids taxable ?',
   '[
     {"id":"a","label":"Le poids réel uniquement","is_correct":false},
     {"id":"b","label":"Le maximum du poids réel et du poids volumétrique","is_correct":true},
     {"id":"c","label":"La moyenne du poids réel et du poids métrique","is_correct":false},
     {"id":"d","label":"Le minimum des trois poids","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['messagerie','poids-taxable'],
   'mft-2026-gotrm-livret:ch04:qcm:06', true,
   'En messagerie, le poids taxable est égal au maximum du poids réel et du poids volumétrique. Le poids métrique est rarement appliqué en messagerie.'),

  -- QCM 7 (moyen)
  (v_formation, v_module, 'qcm',
   'Que prévoit la règle du « payant pour » en messagerie ?',
   '[
     {"id":"a","label":"Imposer le tarif de la tranche supérieure dans tous les cas","is_correct":false},
     {"id":"b","label":"Comparer le prix de la tranche réelle et celui de la tranche supérieure et retenir le moins cher","is_correct":true},
     {"id":"c","label":"Appliquer le tarif moyen entre deux tranches","is_correct":false},
     {"id":"d","label":"Refuser tout envoi non conforme à la grille","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['messagerie','payant-pour'],
   'mft-2026-gotrm-livret:ch04:qcm:07', true,
   'La règle du payant pour permet d''appliquer le tarif d''une tranche supérieure si celui-ci est plus avantageux pour le client.'),

  -- QCM 8 (moyen)
  (v_formation, v_module, 'qcm',
   'En lots partiels, comment est défini le poids taxable ?',
   '[
     {"id":"a","label":"Le maximum du poids réel et du poids volumétrique uniquement","is_correct":false},
     {"id":"b","label":"Le maximum des trois valeurs (poids réel, poids volumétrique, poids métrique), arrondi aux 100 kg supérieurs","is_correct":true},
     {"id":"c","label":"Le poids volumétrique uniquement","is_correct":false},
     {"id":"d","label":"La moyenne des trois poids arrondie au kg supérieur","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['lots-partiels','poids-taxable'],
   'mft-2026-gotrm-livret:ch04:qcm:08', true,
   'En lots partiels, le poids taxable est le maximum des trois valeurs : poids réel, poids volumétrique, poids métrique. Il est arrondi aux 100 kg supérieurs.'),

  -- QCM 9 (moyen)
  (v_formation, v_module, 'qcm',
   'Quelles sont les trois méthodes de tarification des lots partiels ?',
   '[
     {"id":"a","label":"À la tonne, à la palette, au mètre linéaire","is_correct":true},
     {"id":"b","label":"Au km, à l''heure, à la journée","is_correct":false},
     {"id":"c","label":"À la tonne, au volume, au forfait","is_correct":false},
     {"id":"d","label":"Au poids réel, au poids volumétrique, au poids métrique","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['lots-partiels','methodes'],
   'mft-2026-gotrm-livret:ch04:qcm:09', true,
   'Trois méthodes coexistent : à la tonne (envois lourds), à la palette (envois palettisés), au mètre linéaire (envois occupant beaucoup de plancher).'),

  -- QCM 10 (difficile)
  (v_formation, v_module, 'qcm',
   'Comment se calcule le prix d''un lot complet ?',
   '[
     {"id":"a","label":"À partir d''une grille de messagerie selon la zone","is_correct":false},
     {"id":"b","label":"À partir du coût de revient (formule binôme ou trinôme) auquel on ajoute la marge commerciale","is_correct":true},
     {"id":"c","label":"Selon le nombre de palettes uniquement","is_correct":false},
     {"id":"d","label":"À partir du seul terme journalier (TJ)","is_correct":false}
   ]'::jsonb,
   1, 'difficile', ARRAY['lots-complets','tarification'],
   'mft-2026-gotrm-livret:ch04:qcm:10', true,
   'Pour un lot complet, le véhicule est entièrement dédié à un seul client : prix = coût de revient (binôme/trinôme) + marge commerciale.'),

  -- QCM 11 (difficile)
  (v_formation, v_module, 'qcm',
   'Quels articles du Code des transports encadrent la révision du prix carburant ?',
   '[
     {"id":"a","label":"Articles L.1411-1 et L.1411-2","is_correct":false},
     {"id":"b","label":"Articles L.3222-1 et L.3222-2","is_correct":true},
     {"id":"c","label":"Articles L.3261-1 et L.3261-2","is_correct":false},
     {"id":"d","label":"Articles L.3411-1 et L.3411-2","is_correct":false}
   ]'::jsonb,
   1, 'difficile', ARRAY['pied-facture','reglementation'],
   'mft-2026-gotrm-livret:ch04:qcm:11', true,
   'Articles L.3222-1 et L.3222-2 du Code des transports : le prix du transport doit être révisé en cas de variations significatives du prix du carburant.'),

  -- QCM 12 (difficile)
  (v_formation, v_module, 'qcm',
   'Quelle est la sanction applicable au cocontractant refusant un pied de facture justifié ?',
   '[
     {"id":"a","label":"7 500 € d''amende","is_correct":false},
     {"id":"b","label":"15 000 € d''amende","is_correct":true},
     {"id":"c","label":"30 000 € d''amende","is_correct":false},
     {"id":"d","label":"Une simple mise en demeure sans amende","is_correct":false}
   ]'::jsonb,
   1, 'difficile', ARRAY['pied-facture','sanction'],
   'mft-2026-gotrm-livret:ch04:qcm:12', true,
   'Sanction : 15 000 € d''amende pour tout cocontractant refusant de payer un pied de facture justifié (articles L.3222-1 et L.3222-2).'),

  -- QR 1 (cas pratique calcul trinôme)
  (v_formation, v_module, 'qr',
   'Calculez le coût de revient et le prix de vente HT pour la mission Clermont-Ferrand → Marseille avec : TK = 0,615 €/km, TH = 27,08 €/h, TJ = 198,35 €/j, distance 420 km, 8 h de service, 1 jour, marge 15 %. Détaillez la formule trinôme et chaque étape.',
   NULL,
   6, 'difficile', ARRAY['cas-pratique','trinome','calcul'],
   'mft-2026-gotrm-livret:ch04:qr:01', true,
   'Formule trinôme : Coût = (TK × km) + (TH × h) + (TJ × j) = (0,615 × 420) + (27,08 × 8) + (198,35 × 1) = 258,30 + 216,64 + 198,35 = 673,29 €. Prix de vente HT = 673,29 × 1,15 = 774,28 €.'),

  -- QR 2 (cas pratique messagerie)
  (v_formation, v_module, 'qr',
   'Un envoi messagerie pèse 290 kg en zone 3. Tarifs : tranche 180–300 kg = 4,50 €/100 kg ; tranche 300–500 kg = 3,80 €/100 kg. Calculez l''option 1 (tarif normal), l''option 2 (payant pour 300 kg) et indiquez le prix retenu.',
   NULL,
   5, 'moyen', ARRAY['cas-pratique','messagerie','payant-pour'],
   'mft-2026-gotrm-livret:ch04:qr:02', true,
   'Option 1 (tarif normal 290 kg) : (290 × 4,50) / 100 = 13,05 €. Option 2 (payant pour 300 kg) : (300 × 3,80) / 100 = 11,40 €. On retient 11,40 € — la règle du payant pour s''applique car la tranche supérieure est plus avantageuse.'),

  -- QR 3 (méthode 6 étapes)
  (v_formation, v_module, 'qr',
   'Énoncez les 6 étapes de la méthode de tarification messagerie.',
   NULL,
   6, 'moyen', ARRAY['cas-pratique','messagerie','methode'],
   'mft-2026-gotrm-livret:ch04:qr:03', true,
   'Étape 1 : poids taxable = max (poids réel / poids volumétrique), arrondi au kg supérieur. Étape 2 : identifier le prix dans la grille (poids taxable et zone) — < 100 kg = forfait, ≥ 100 kg = (poids × prix aux 100 kg)/100. Étape 3 : calculer le prix de transport. Étape 4 : appliquer la règle du payant pour (retenir le moins cher). Étape 5 : ajouter les frais accessoires. Étape 6 : Prix HT = prix de transport + frais accessoires.'),

  -- QR 4 (formule pied de facture)
  (v_formation, v_module, 'qr',
   'Donnez la formule de calcul du supplément carburant (pied de facture) et citez deux prestations annexes facturables au-delà du transport principal.',
   NULL,
   5, 'difficile', ARRAY['cas-pratique','pied-facture','annexes'],
   'mft-2026-gotrm-livret:ch04:qr:04', true,
   'Formule : Supplément = Prix HT × Part carburant contractuelle × [(Indice mois facturation − Indice référence) / Indice référence]. Prestations annexes : péages, chargement/déchargement, valeur déclarée, contre-remboursement, avis de passage/RDV, ADR, température dirigée, attente.');

  -- =================================================================
  -- QUIZ
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Chapitre 4 — Quiz d''entraînement',
          'Quiz d''entraînement (12 questions) sur le calcul du coût de revient et la tarification.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm-livret:ch04:qcm:%';

  RAISE NOTICE '✓ Module Ch4 importé.';
END $ch04_v4$;
