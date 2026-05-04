-- =====================================================================
-- MODULE F — L'ENTREPRISE ET LA SÉCURITÉ (Capacité ≤ 3,5 T)
-- Version 2 (mai 2026) — refonte complète depuis PDF officiels.
--
-- Référentiel (décision du 2 avril 2012) : 6 QCM (12 pts) + 1 QR (10 pts)
-- = 22 points sur 84.
--
-- ▸ 4 leçons (permis et conduite / véhicule et entretien / chargement et
--   transports spéciaux / sécurité travail et environnement)
-- ▸ 30 QCM reformulés (préfixe mft-2026:moduleF:qcm:N)
-- ▸ 6 QR transport
-- ▸ Quizzes par leçon + 1 examen blanc
-- =====================================================================

DO $module_f_v2$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation capacite-3-5t introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'capa-securite';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module F — L''entreprise et la sécurité',
    'capa-securite', v_bloc,
    'Maîtriser le permis à points, la sécurité routière, l''entretien du véhicule, le chargement / déchargement, les transports spéciaux (TMD, denrées périssables), la conduite en cas d''accident et l''impact environnemental.',
    'intermediaire', 150, 60
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 60, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026:moduleF:%';

  -- =================================================================
  -- LEÇON 1 — Permis et conduite
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Le permis de conduire et la sécurité routière', 'permis-conduite-securite',
    1, 40,
$lesson1$
# Le permis de conduire et la sécurité routière

Le permis de conduire est l'**outil de travail** du transporteur. Sa perte = la fin de l'activité. Vous devez maîtriser le système à points, les règles de prudence, et organiser la prévention du risque routier dans votre entreprise.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser le **permis à points** (capital, retrait, récupération).
> - Connaître les obligations de l'**employeur** vis-à-vis du permis du salarié.
> - Identifier les principales **infractions** et leurs conséquences.
> - Organiser la **prévention du risque routier**.

---

## 1. Le permis à points

### 1.1 Capital initial

| Type | Capital |
|---|---|
| **Permis probatoire** (3 ans après obtention, ou 2 ans en conduite accompagnée) | 6 points → 12 points (acquis progressivement) |
| **Permis définitif** | **12 points** |

### 1.2 Retraits de points

> Les points sont retirés dès que la **réalité de l'infraction est établie** par :
> - Paiement d'une **amende forfaitaire**
> - **Titre exécutoire** d'une amende forfaitaire majorée
> - Exécution d'une **composition pénale**
> - **Condamnation définitive**

> ⚠️ **Plafond simultané**
>
> En cas d'infractions simultanées, **maximum 8 points** peuvent être retirés en une fois (dans la limite du capital).

### 1.3 Principales infractions et points retirés

| Infraction | Points retirés |
|---|---|
| **Excès de vitesse < 20 km/h** | 1 |
| **Excès de vitesse 20-30 km/h** | 2 |
| **Excès de vitesse 30-40 km/h** | 3 |
| **Excès de vitesse 40-50 km/h** | 4 |
| **Excès de vitesse > 50 km/h** | 6 |
| **Téléphone tenu en main au volant** | 3 + suspension possible |
| **Non-port de la ceinture** | 3 |
| **Stop, feu rouge, sens interdit** | 4 |
| **Alcoolémie 0,5-0,8 g/l** | 6 |
| **Alcoolémie ≥ 0,8 g/l ou stupéfiants** | 6 + délit |

### 1.4 Récupération des points

#### Récupération automatique

| Délai sans infraction | Points récupérés |
|---|---|
| **6 mois** | Le 1er point retiré (s'il s'agit d'une infraction à 1 point) |
| **2 ans** | Capital plein restauré (sauf infraction délictuelle ou 4e/5e classe) |
| **3 ans** | Capital plein restauré pour les délits ou contraventions de 4e/5e classe |

#### Récupération par stage

> Un **stage de sensibilisation à la sécurité routière** de **2 jours** permet de récupérer **jusqu'à 4 points**, sans dépasser 12.
>
> Limites : un stage par an, permis non encore invalidé.

### 1.5 Invalidation du permis

> Lorsque le solde tombe à **0 point**, le permis est **invalidé**.

| Conséquence | Détail |
|---|---|
| Notification | LRAR du ministère de l'Intérieur |
| Restitution | Préfecture du domicile dans **10 jours** |
| Interdiction de conduire | **6 mois** (1 an si récidive sous 5 ans) |

> ⚠️ **Pour repasser le permis après invalidation**
>
> Visite médicale + tests psychotechniques + nouvelle épreuve théorique (code) ou pratique selon les cas.

---

## 2. Obligations de l'employeur

### 2.1 Vérifier la possession du permis

> Article L. 4121-1 C. trav. : l'employeur a une **obligation de sécurité de moyens renforcée**. Il doit s'assurer que le salarié possède un **permis valide et adapté** au véhicule.

#### Outils de contrôle

- **Demande au salarié** de présenter son permis (à l'embauche puis périodiquement)
- **Clause contractuelle** rappelant l'obligation de détenir un permis valide
- **Engagement** du salarié à informer l'employeur en cas de retrait/suspension

### 2.2 Le salarié n'est PAS obligé de communiquer son nombre de points

> ⚠️ **Information protégée**
>
> Le solde de points est une **information personnelle**. Le salarié n'a **aucune obligation légale** de le communiquer à son employeur, contrairement à l'invalidation du permis qui doit être signalée (par cohérence avec son contrat).

### 2.3 Les conséquences pour l'employeur

| Si le salarié... | Conséquence employeur |
|---|---|
| **Conduit sans permis valide** | Risque pénal pour l'employeur (mise en danger d'autrui), responsabilité civile en cas d'accident |
| **Cause un accident sans permis** | Faute inexcusable possible, prise en charge par l'employeur des compléments d'indemnisation |
| **Voit son permis suspendu/invalidé** | Peut être muté à un poste sans conduite, à défaut licenciement pour cause réelle et sérieuse possible |

### 2.4 Démarches préventives

- Sensibilisation aux **risques** : alcool, stupéfiants, médicaments, fatigue, téléphone
- **Stages d'éco-conduite** (récupération de points + économie carburant)
- **Audit régulier** du parc et des conducteurs
- Inscription du **risque routier au DUERP**

---

## 3. Les règles de circulation pour le transporteur léger

### 3.1 Limitations de vitesse

| Type de route | VL et VUL ≤ 3,5 t | PL > 3,5 t |
|---|---|---|
| **Agglomération** | 50 km/h | 50 km/h |
| **Route hors agglomération** | 80 km/h | 80 km/h |
| **Voie express (chaussées séparées)** | 110 km/h | 90 km/h |
| **Autoroute** | 130 km/h (110 par temps de pluie) | 90 km/h (80 par temps de pluie) |

### 3.2 Alcool et stupéfiants

| Niveau | Seuil légal | Sanction |
|---|---|---|
| **Conducteurs novices (< 3 ans)** | **0,2 g/l** (équivalent zéro) | Contravention 4e classe + 6 points |
| **Conducteurs confirmés** | < 0,5 g/l | Au-dessus : 6 points + amende, suspension |
| **Délit** | ≥ 0,8 g/l ou stupéfiants | 6 points + tribunal correctionnel |

### 3.3 Ceinture, téléphone, équipements

| Règle | Sanction |
|---|---|
| **Ceinture obligatoire** (sauf dispense médicale) | 4e classe + 3 points |
| **Téléphone tenu en main interdit** | 4e classe + 3 points + suspension possible |
| **Kit mains libres avec écouteurs** | Interdit depuis 2015, 4e classe + 3 points |
| **Bluetooth intégré au véhicule** | Autorisé |

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Capital de points permis définitif | **12** |
| Période probatoire après obtention | **3 ans** (2 ans en conduite accompagnée) |
| Points récupérables par stage | **Jusqu'à 4** (1 stage/an, permis non invalidé) |
| Récupération automatique délai standard | **2 ans** sans infraction |
| Récupération automatique pour délit/4e/5e classe | **3 ans** sans infraction |
| Maximum points retirés simultanément | **8** |
| Obligation à 0 point | Restituer le permis sous **10 jours**, suspension **6 mois** |
| Seuil légal alcool conducteur confirmé | **0,5 g/l** |
| Seuil légal alcool conducteur novice | **0,2 g/l** |
| Délit alcool | ≥ **0,8 g/l** |
$lesson1$,
'Permis 12 points, récupération automatique (6 mois / 2 ans / 3 ans) ou par stage (jusqu''à 4 points), invalidation à 0, alcoolémie 0,5 g/l (0,2 g/l novice), obligation de l''employeur.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Le véhicule et son entretien
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Le véhicule et son entretien', 'vehicule-entretien',
    2, 30,
$lesson2$
# Le véhicule et son entretien

Le **véhicule** est l'outil de production. Son **choix**, son **entretien** et sa **conformité technique** conditionnent votre rentabilité, votre sécurité et votre conformité réglementaire.

> 🎯 **Objectifs de la leçon**
>
> - Choisir un véhicule adapté à son activité.
> - Maîtriser les **obligations d'entretien** et de **contrôle technique**.
> - Connaître les **équipements obligatoires** d'un VUL.

---

## 1. Choisir son véhicule

### 1.1 Critères de choix

| Critère | Question à se poser |
|---|---|
| **PTAC** | Quelle charge utile pour mes besoins ? |
| **Volume utile** | Quel volume de chargement ? |
| **Carrosserie** | Fourgon, plateau, frigo, isotherme, hayon ? |
| **Type de motorisation** | Diesel, essence, hybride, électrique, GNV ? |
| **Mode de financement** | Achat, crédit, LLD, crédit-bail ? |
| **Coût total de possession (TCO)** | Achat + entretien + carburant + assurance + revente |
| **Conformité environnementale** | Norme Euro, Crit'Air, ZFE |

### 1.2 Équipements et options

| Équipement | Utilité |
|---|---|
| **GPS** | Itinéraire optimisé, traçabilité |
| **Caméra de recul** | Sécurité, parking en milieu urbain |
| **Géolocalisation flotte** | Suivi temps réel, optimisation |
| **Hayon élévateur** | Manutention de palettes |
| **Anti-démarrage (alcoolock)** | Prévention conduite avec alcool |
| **Boîtier télématique** | Suivi de la conduite, éco-conduite |

### 1.3 Choix d'une motorisation : impact ZFE

> Les **Zones à Faibles Émissions** (ZFE) interdisent progressivement les véhicules les plus polluants en agglomération.

| Norme Euro | Année | Crit'Air |
|---|---|---|
| Euro 1 | < 2001 | **Non classé** |
| Euro 2 | 2001-2005 | **Crit'Air 5** |
| Euro 3 | 2006-2010 | **Crit'Air 4** |
| Euro 4 | 2011-2014 | **Crit'Air 3** |
| Euro 5 | 2015-2019 | **Crit'Air 2** |
| Euro 6 | 2020+ | **Crit'Air 2** |
| Électrique / Hydrogène | - | **Crit'Air E** |

> ⚠️ **Anticipation ZFE**
>
> Les agglomérations majeures (Paris, Lyon, Grenoble, Marseille...) restreignent l'accès. Un VUL Crit'Air 3 ou plus ancien risque d'être interdit avant 2030.

---

## 2. L'entretien et le contrôle technique

### 2.1 Visite technique pour ≤ 3,5 t

| Type de véhicule | 1re visite | Périodicité |
|---|---|---|
| **VL et VUL ≤ 3,5 t propres usages** | 4 ans | Tous les **2 ans** |
| **VUL utilisé professionnellement (transport public)** | 4 ans | Tous les **2 ans** |
| **VL > 3,5 t / Camions** | 1 an | Tous les **ans** |

### 2.2 Contre-visite

> Si la visite technique révèle un défaut majeur ou critique : **contre-visite obligatoire dans les 2 mois**.

### 2.3 Entretien systématique recommandé

| Opération | Périodicité indicative |
|---|---|
| Vidange + filtres | 15 000 - 30 000 km ou 1 an |
| Filtre habitacle | 1 an |
| Plaquettes / disques de frein | Selon usure (30 - 60 000 km) |
| Pneumatiques | Selon usure (40 - 80 000 km) |
| Courroie de distribution | 80 000 - 160 000 km selon constructeur |
| Embrayage | 100 000 - 200 000 km |

### 2.4 Équipements particuliers (hayon, plateforme élévatrice)

| Équipement | Vérification |
|---|---|
| **Plateforme élévatrice de personnel (PEMP)** | Vérification générale **annuelle** par organisme agréé |
| **Hayon élévateur** | Vérification **6 mois** par organisme agréé |
| **Treuil, grue auxiliaire** | Vérification **annuelle** |

> 📌 **Document Unique des Risques (DUERP)**
>
> Tout équipement spécial doit figurer au DUERP avec son risque associé et le plan de prévention.

---

## 3. Équipements obligatoires d'un VUL

### 3.1 À bord du véhicule

| Équipement | Détail |
|---|---|
| **Triangle de pré-signalisation** | Article R. 416-19 C. route |
| **Gilet de haute visibilité** | À portée de main du conducteur |
| **Carte grise (CIV / certificat d'immatriculation)** | Origine ou copie certifiée pour société |
| **Permis de conduire** | Du conducteur |
| **Attestation d'assurance** (carte verte) | Avec papillon collé sur pare-brise |
| **Copie certifiée conforme de la licence** | Pour le transport pour compte d'autrui |

### 3.2 Pour le transporteur

| Document | Détail |
|---|---|
| **Lettre de voiture / CMR** | Pour chaque envoi |
| **Bon de livraison** | Pour la traçabilité |
| **Notice d'utilisation** | Selon nature de la marchandise |

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Périodicité contrôle technique VUL ≤ 3,5 t | Tous les **2 ans** (1re à 4 ans) |
| Délai contre-visite après défaut majeur | **2 mois** |
| Norme Euro permettant accès ZFE | Au minimum **Euro 5 / Crit'Air 2** (selon ZFE) |
| Vérification annuelle hayon | **Tous les 6 mois** par organisme agréé |
| Vérification plateforme élévatrice (PEMP) | **Annuelle** |
| Document obligatoire à bord (transport pour autrui) | **Copie certifiée conforme de la licence** |
| Équipement de signalisation obligatoire | **Triangle + gilet haute visibilité** |
$lesson2$,
'Choix véhicule (PTAC, volume, motorisation, ZFE), CT tous les 2 ans, vérifications hayon/PEMP, équipements obligatoires (triangle, gilet, CCC licence).'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Chargement, déchargement, transports spéciaux
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Chargement, déchargement et transports spéciaux', 'chargement-transports-speciaux',
    3, 40,
$lesson3$
# Chargement, déchargement et transports spéciaux

Le chargement / déchargement est le moment de **tous les risques** : accidents corporels, dommages aux marchandises, infractions à la surcharge. Les **transports spéciaux** (matières dangereuses, denrées périssables) sont strictement réglementés.

> 🎯 **Objectifs de la leçon**
>
> - Connaître les **obligations** de chargement / déchargement.
> - Maîtriser les règles de **surcharge** et le **PTAC**.
> - Connaître les bases de l'**ADR** (matières dangereuses).
> - Maîtriser les obligations pour les **denrées périssables**.

---

## 1. Le chargement et le déchargement

### 1.1 Les obligations de l'expéditeur

> **Article L. 1432-2 C. transports** : c'est l'**expéditeur** qui charge l'envoi, sauf accord contraire pour les envois < 3 tonnes.

| Obligation | Détail |
|---|---|
| **Emballage et conditionnement** | Adaptés à la marchandise et au transport |
| **Étiquetage** | Mention des risques (ADR), instructions de manipulation |
| **Respect des réglementations particulières** | Matières dangereuses, denrées périssables, tabac, alcool |
| **Remise** | Lieu, jour, heure, tonnage convenu |
| **Chargement et arrimage** (envois ≥ 3 t) | Selon les règles de l'art, vérifications |

### 1.2 Les obligations du transporteur

| Obligation | Détail |
|---|---|
| **Choix du véhicule** | Adapté au type de marchandise et au volume |
| **Véhicule en bon état** | CT à jour, équipements opérationnels |
| **Respect des horaires** | Heures de rendez-vous prévues |
| **Vérification du chargement** | Sécurité, arrimage, conformité aux documents |
| **Émission de réserves** | Si défaut visible (étiquetage, conditionnement, palette) |

### 1.3 Le protocole de sécurité

> **Document obligatoire** dès lors qu'un transporteur extérieur intervient régulièrement chez un donneur d'ordre.

#### Contenu

- Caractéristiques du transporteur, du conducteur, du véhicule
- Lieux et conditions du chargement
- Risques particuliers et mesures de prévention
- Modalités de contrôle d'accès, d'entrée / sortie
- Équipements de protection obligatoires sur site

> 📌 **Établi conjointement** par le donneur d'ordre et le transporteur. Mis à jour si l'activité ou les conditions changent.

---

## 2. La surcharge et le PTAC

### 2.1 Définitions

| Terme | Définition |
|---|---|
| **Tare** | Poids du véhicule à vide |
| **PTAC** (Poids Total Autorisé en Charge) | Poids maximum (véhicule + charge utile + carburant + conducteur + passagers) |
| **PTRA** (Poids Total Roulant Autorisé) | PTAC + remorque |
| **CU** (Charge Utile) | PTAC - Tare = capacité de transport |

### 2.2 Sanctions de la surcharge

| Surcharge | Sanction |
|---|---|
| **Tolérance < 5 %** | Aucune sanction (en pratique souvent appliquée) |
| **Surcharge 5-20 %** | Contravention 4e classe : **135 € + 3 points** |
| **Surcharge > 20 %** | Contravention 5e classe : **1 500 €** + immobilisation possible |

> ⚠️ **Responsabilité partagée**
>
> En cas de surcharge, **le donneur d'ordre, le chargeur ET le transporteur** peuvent être sanctionnés selon les contributions de chacun (article L. 3242-3 C. transp.).

---

## 3. Les transports de matières dangereuses (TMD / ADR)

### 3.1 Le règlement ADR

> **ADR** = **Accord européen relatif au transport international des marchandises Dangereuses par Route** (1957, mis à jour tous les 2 ans).

### 3.2 Les 9 classes de matières dangereuses

| Classe | Type |
|---|---|
| **1** | Matières et objets explosifs |
| **2** | Gaz |
| **3** | Liquides inflammables |
| **4** | Solides inflammables, matières spontanément inflammables, dégageant de l'hydrogène au contact de l'eau |
| **5** | Matières comburantes, peroxydes organiques |
| **6** | Matières toxiques et infectieuses |
| **7** | Matières radioactives |
| **8** | Matières corrosives |
| **9** | Autres matières dangereuses (lithium-ion, etc.) |

### 3.3 Seuils d'application et obligations

| Quantité transportée | Régime |
|---|---|
| **Faible** (sous-seuil ADR) | Allègements de l'ADR (sans formation ADR du conducteur) |
| **Au-delà du seuil** | ADR complet : conducteur **certifié ADR**, véhicule conforme, signalisation, documents |

#### Documents obligatoires (ADR plein régime)

- **Document de transport** indiquant le n° UN, les classes, le code de danger
- **Consignes écrites** au conducteur
- **Certificat de formation ADR** du conducteur
- **Certificat d'agrément** du véhicule

### 3.4 Équipements

- **Étiquettes orange** (numéro UN sur 4 chiffres)
- **Pancartes orange** (vide haut + n° UN bas)
- **Extincteurs** adaptés à la classe transportée
- **EPI** (lunettes, gants, lampe ATEX, etc.)

### 3.5 Le conseiller à la sécurité TMD

> **Obligatoire** pour toute entreprise expéditeur, transporteur ou destinataire de TMD au-dessus du seuil.

Désigné dans l'entreprise. Mission : conseil + rapport annuel + analyse incidents.

---

## 4. Le transport de denrées périssables

### 4.1 Réglementation

> **Accord ATP** (Accord relatif aux Transports Périssables, 1970) : encadre les températures et les véhicules autorisés.

### 4.2 Catégories de véhicules ATP

| Catégorie | Caractéristique |
|---|---|
| **IN** (Isotherme Normale) | Isolation modérée, sans groupe |
| **IR** (Isotherme Renforcée) | Isolation renforcée, sans groupe |
| **RNA** (Réfrigérant Normal classe A) | Maintien à 0 °C |
| **FRC** (Frigorifique classe C) | Maintien à -20 °C minimum |
| **FRA** (Frigorifique classe A) | Maintien à 0 °C |

### 4.3 Températures réglementaires

| Produit | Température maximale |
|---|---|
| **Crèmes glacées** | **-20 °C** |
| **Poissons surgelés** | -18 °C |
| **Viandes hachées congelées** | -18 °C |
| **Produits laitiers frais** | +4 à +8 °C selon produit |
| **Viandes fraîches** | +0 à +7 °C selon morceau |
| **Volailles** | 0 à +4 °C |

### 4.4 Hygiène et formation

| Obligation | Détail |
|---|---|
| **Plan de Maîtrise Sanitaire (PMS)** | Obligatoire dès qu'on transporte des denrées |
| **Formation hygiène alimentaire** | 14 h obligatoires pour le responsable |
| **Traçabilité** | Enregistrement des températures, durée, destinataire |
| **Nettoyage / désinfection** | Plan documenté, fréquences |

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Qui charge la marchandise (envoi ≥ 3 t) ? | L'**expéditeur** |
| Document de sécurité chez un donneur d'ordre régulier | **Protocole de sécurité** |
| PTAC | Poids Total Autorisé en Charge |
| Sanction surcharge < 20 % | Contravention 4e classe : **135 €** + 3 points |
| Sanction surcharge > 20 % | Contravention 5e classe : **1 500 €** + immobilisation |
| Règlement matières dangereuses | **ADR** (9 classes) |
| Document interne TMD | **Consignes écrites** + document de transport + certificat ADR conducteur |
| Conseiller à la sécurité TMD | Obligatoire au-dessus du seuil |
| Accord transport de denrées périssables | **Accord ATP** |
| Catégorie véhicule pour glaces | **FRC** classe C (-20 °C minimum) |
| Formation hygiène alimentaire obligatoire | **14 h** pour le responsable |
$lesson3$,
'Obligations chargement (expéditeur ≥ 3 t), protocole de sécurité, PTAC + sanction surcharge, ADR (9 classes), ATP (températures), formation hygiène 14 h.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Sécurité au travail et environnement
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Sécurité au travail et environnement', 'securite-environnement',
    4, 40,
$lesson4$
# Sécurité au travail et environnement

L'accident peut arriver à tout moment. Votre **savoir-réagir** et la **prévention** que vous mettez en place font la différence. Et l'environnement n'est plus une option : c'est une **obligation légale** et un avantage concurrentiel.

> 🎯 **Objectifs de la leçon**
>
> - Connaître la **conduite à tenir en cas d'accident**.
> - Maîtriser les obligations en matière de **conditions de travail**.
> - Connaître les obligations **environnementales** du transporteur.
> - Promouvoir l'**éco-conduite** et la prévention des risques.

---

## 1. La conduite à tenir en cas d'accident

### 1.1 Pour le conducteur

| Étape | Action |
|---|---|
| 1️⃣ | **Sécuriser** la zone (gilet, triangle, signalisation) |
| 2️⃣ | **Alerter** : 18 (pompiers) / 15 (SAMU) / 17 (police) ou **112** |
| 3️⃣ | **Secourir** les blessés (ne pas les déplacer sauf danger) |
| 4️⃣ | **Constat** : remplir le constat amiable, photos, témoins |
| 5️⃣ | **Informer** l'employeur immédiatement |

### 1.2 Pour l'employeur

| Étape | Action | Délai |
|---|---|---|
| Déclaration accident du travail | Si conducteur salarié blessé | **48 h** à la CPAM |
| Déclaration sinistre auto | À l'assureur | **5 jours ouvrés** |
| Information du donneur d'ordre / client | Si retard ou perte | Immédiate |
| Audit interne | Analyse des causes, plan d'action | < 30 jours |
| Mise à jour DUERP | Si nouveau risque identifié | < 1 mois |

### 1.3 En cas de matières dangereuses

> Réglementation ADR : alerte **immédiate** des autorités, fiche de consignes écrites, équipements de protection, périmètre de sécurité.

---

## 2. Les conditions de travail

### 2.1 Risques routiers

> Le risque routier est le **1er accident mortel** en France dans le cadre professionnel.

#### Mesures de prévention

| Mesure | Détail |
|---|---|
| **Inscription au DUERP** | Obligatoire |
| **Formation continue** | Éco-conduite, sécurité, premiers secours |
| **Limitation horaires** | Respect des temps de conduite et de repos |
| **Pause obligatoire** | 45 min après 4h30 de conduite |
| **Audit de la flotte** | Maintenance, équipements |
| **Sensibilisation** | Alcool, drogues, médicaments, fatigue, téléphone |

### 2.2 Risque physique : manutention

> **2e cause** d'accidents du travail.

#### Mesures

- **Aides à la manutention** : transpalette, hayon, chariot
- **Formation gestes et postures** (CACES, formation INRS)
- **Limitation des charges** : 30 kg max sans aide
- **EPI** : gants, chaussures de sécurité, baudrier de soutien

### 2.3 Risques psychosociaux (RPS)

| Risque | Manifestation |
|---|---|
| **Stress** | Délais, pression, isolement |
| **Charge mentale** | Multiplicité des tâches |
| **Harcèlement** | Moral, sexuel, agissements sexistes |
| **Solitude** | Conducteur seul en long-courrier |

#### Prévention

- **Charge de travail** mesurée
- **Communication** réguliers (entretiens, points équipe)
- **Cellule d'écoute** ou médiateur externe
- **Plan d'actions** dans le DUERP

---

## 3. Les obligations environnementales

### 3.1 Cadre réglementaire

| Texte | Objet |
|---|---|
| **Code de l'environnement** | Réglementation générale |
| **Loi LOM** (Loi d'Orientation des Mobilités, 2019) | Verdissement de la flotte |
| **Loi Climat et Résilience** (2021) | Décarbonation, ZFE |

### 3.2 Obligations sur le carburant

| Obligation | Détail |
|---|---|
| **Cuves de stockage carburant** | Déclaration ICPE selon volume |
| **Bac de rétention** sous cuve | Capacité ≥ 100 % du volume stocké |
| **Récupération des huiles usées** | Collecte par centre agréé |
| **Filtres usagés** | Idem (déchets dangereux) |

### 3.3 Obligations sur les véhicules

| Obligation | Détail |
|---|---|
| **Vignette Crit'Air** | Obligatoire pour circuler en ZFE |
| **Norme Euro** | Conforme à la zone de circulation |
| **Contrôle pollution** (au CT) | Tests obligatoires (CO, HC, opacité fumées) |
| **Recyclage VHU** (Véhicule Hors d'Usage) | Centre agréé en fin de vie |

### 3.4 Obligations en cas de sinistre environnemental

| Type | Obligation |
|---|---|
| **Fuite de carburant ou huile** | Confinement immédiat (sable, absorbant), alerte autorités |
| **Pollution accidentelle** | Déclaration à la préfecture, plan de dépollution |
| **Dommage environnemental** | Responsabilité civile + pénale possible |

> ⚠️ **Honorabilité du dirigeant**
>
> Une infraction environnementale grave (article L. 541-46 C. envir.) peut entraîner la **perte de l'honorabilité professionnelle** → radiation du registre des transporteurs.

---

## 4. L'éco-conduite

### 4.1 Avantages

| Bénéfice | Impact |
|---|---|
| **Économie carburant** | -10 à -15 % de consommation |
| **Diminution pollution** | -10 % émissions CO2 et particules |
| **Diminution bruit** | Confort des riverains |
| **Préservation matériel** | -20 % usure pneus, freins, embrayage |
| **Réduction accidents** | -15 % d'accidents matériels |

### 4.2 Bonnes pratiques

- **Anticiper** la circulation, freiner doucement
- **Maintenir une vitesse régulière** (régulateur)
- **Couper le moteur** lors d'arrêts > 30 secondes
- **Vérifier la pression des pneus** régulièrement
- **Limiter la climatisation** à l'utilisation nécessaire
- **Charger correctement** : pas de surcharge, marchandise bien arrimée

### 4.3 Stages d'éco-conduite

> Stages **2 jours** dispensés par centres agréés. **Récupération de 4 points** possible (1 stage par an).

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Numéro d'urgence européen | **112** |
| Délai déclaration AT à la CPAM | **48 h** |
| Délai déclaration sinistre auto | **5 jours ouvrés** |
| 1er accident mortel professionnel | **Accident de la route** |
| 2e cause d'AT | **Manutention** |
| Loi 2019 verdissement de la flotte | **Loi LOM** |
| Vignette obligatoire en ZFE | **Crit'Air** |
| Économie carburant éco-conduite | **-10 à -15 %** |
| Stage éco-conduite : récupération | **4 points** (1 stage / an) |
| Risque environnemental → honorabilité | **Article L. 541-46** C. envir. |
$lesson4$,
'Conduite après accident (sécuriser/alerter/secourir/constater/déclarer 48h CPAM, 5j sinistre), risques routier/manutention/RPS, ZFE/Crit''Air/LOM, éco-conduite -15 %.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE QCM REFORMULÉS — Module F (30 questions)
  -- =================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'Le permis de conduire définitif est doté d''un capital de :', '[{"id":"a","label":"6 points","is_correct":false},{"id":"b","label":"10 points","is_correct":false},{"id":"c","label":"12 points","is_correct":true},{"id":"d","label":"15 points","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-f','capa-3-5t','permis'], 'mft-2026:moduleF:qcm:1', true, 'Permis définitif = 12 points. Permis probatoire (3 ans, 2 ans en conduite accompagnée) commence à 6 points et progresse à 12.'),
  (v_formation, 'qcm', 'En cas d''infractions simultanées au Code de la route, le maximum de points pouvant être retirés en une fois est de :', '[{"id":"a","label":"4","is_correct":false},{"id":"b","label":"6","is_correct":false},{"id":"c","label":"8","is_correct":true},{"id":"d","label":"12","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-f','capa-3-5t','permis'], 'mft-2026:moduleF:qcm:2', true, 'Plafond simultané = 8 points (article L. 223-2 Code de la route), dans la limite du capital disponible.'),
  (v_formation, 'qcm', 'Un stage de sensibilisation à la sécurité routière permet de récupérer :', '[{"id":"a","label":"1 point","is_correct":false},{"id":"b","label":"Jusqu''à 4 points","is_correct":true},{"id":"c","label":"Jusqu''à 6 points","is_correct":false},{"id":"d","label":"L''intégralité du capital","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','permis','stage'], 'mft-2026:moduleF:qcm:3', true, 'Stage 2 jours dans un centre agréé : jusqu''à 4 points récupérés, sans dépasser 12 (un stage par an, permis non encore invalidé).'),
  (v_formation, 'qcm', 'En cas de perte totale des points, le permis est invalidé et la suspension est de :', '[{"id":"a","label":"3 mois","is_correct":false},{"id":"b","label":"6 mois (1 an si récidive sous 5 ans)","is_correct":true},{"id":"c","label":"12 mois","is_correct":false},{"id":"d","label":"Définitif","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-f','capa-3-5t','permis','invalidation'], 'mft-2026:moduleF:qcm:4', true, '6 mois d''interdiction de conduire à compter de la remise du permis (10 jours après la lettre recommandée). 1 an si retrait total dans les 5 ans suivant un précédent retrait total.'),
  (v_formation, 'qcm', 'Le seuil légal d''alcoolémie pour un conducteur confirmé (permis > 3 ans) est de :', '[{"id":"a","label":"0,2 g/l","is_correct":false},{"id":"b","label":"0,5 g/l","is_correct":true},{"id":"c","label":"0,8 g/l","is_correct":false},{"id":"d","label":"1,2 g/l","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-f','capa-3-5t','alcool'], 'mft-2026:moduleF:qcm:5', true, 'Seuil légal 0,5 g/l (0,25 mg/l air expiré). Au-delà : 6 points + amende. À 0,8 g/l : délit. Pour les conducteurs novices : 0,2 g/l (équivalent zéro).'),
  (v_formation, 'qcm', 'Le seuil d''alcoolémie pour un conducteur novice (permis < 3 ans) est de :', '[{"id":"a","label":"0,2 g/l","is_correct":true},{"id":"b","label":"0,5 g/l","is_correct":false},{"id":"c","label":"0,8 g/l","is_correct":false},{"id":"d","label":"Aucun, tolérance zéro absolue","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','alcool','novice'], 'mft-2026:moduleF:qcm:6', true, 'Conducteurs novices (permis probatoire) : seuil 0,2 g/l = équivalent zéro (mais pas zéro absolu pour tenir compte des taux endogènes). Sanction : 6 points + amende.'),
  (v_formation, 'qcm', 'L''utilisation d''un téléphone tenu en main au volant est sanctionnée par :', '[{"id":"a","label":"Avertissement seulement","is_correct":false},{"id":"b","label":"Contravention 4e classe + 3 points","is_correct":true},{"id":"c","label":"Délit + 6 points","is_correct":false},{"id":"d","label":"Suspension automatique du permis","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','telephone'], 'mft-2026:moduleF:qcm:7', true, 'Contravention 4e classe : 135 € + 3 points. Suspension possible si plusieurs infractions simultanées. Le kit mains libres avec écouteurs est aussi interdit depuis 2015.'),
  (v_formation, 'qcm', 'Combien de temps un employeur conserve-t-il l''obligation de s''assurer que son salarié dispose d''un permis valide ?', '[{"id":"a","label":"Uniquement à l''embauche","is_correct":false},{"id":"b","label":"Pendant toute la durée du contrat de travail","is_correct":true},{"id":"c","label":"Au moins 1 an","is_correct":false},{"id":"d","label":"Aucune obligation","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-f','capa-3-5t','employeur','permis'], 'mft-2026:moduleF:qcm:8', true, 'Article L. 4121-1 C. trav. : obligation de sécurité de moyens renforcée pendant toute la durée du contrat. Vérifications périodiques + clause contractuelle d''information en cas de retrait/suspension.'),
  (v_formation, 'qcm', 'Le contrôle technique d''un VUL ≤ 3,5 t utilisé professionnellement doit être effectué :', '[{"id":"a","label":"Tous les ans après la 1re visite","is_correct":false},{"id":"b","label":"Tous les 2 ans après la 1re visite à 4 ans","is_correct":true},{"id":"c","label":"Tous les 3 ans","is_correct":false},{"id":"d","label":"Tous les 5 ans","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','vehicule','ct'], 'mft-2026:moduleF:qcm:9', true, '1re visite à 4 ans, puis tous les 2 ans pour les VL et VUL ≤ 3,5 t. Pour les PL > 3,5 t : 1 an dès la 1re mise en circulation.'),
  (v_formation, 'qcm', 'Le délai pour effectuer une contre-visite après un défaut majeur ou critique au CT est de :', '[{"id":"a","label":"15 jours","is_correct":false},{"id":"b","label":"1 mois","is_correct":false},{"id":"c","label":"2 mois","is_correct":true},{"id":"d","label":"6 mois","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','vehicule','ct'], 'mft-2026:moduleF:qcm:10', true, '2 mois pour effectuer la contre-visite après un défaut majeur ou critique. Au-delà, le véhicule ne peut plus circuler.'),
  (v_formation, 'qcm', 'Un hayon élévateur doit être vérifié par un organisme agréé :', '[{"id":"a","label":"Tous les ans","is_correct":false},{"id":"b","label":"Tous les 6 mois","is_correct":true},{"id":"c","label":"Tous les 2 ans","is_correct":false},{"id":"d","label":"Uniquement à l''achat","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-f','capa-3-5t','hayon','vrgp'], 'mft-2026:moduleF:qcm:11', true, '6 mois pour les hayons élévateurs. Pour les PEMP (Plateformes Élévatrices Mobiles de Personnel) : 12 mois. Vérifications par organismes agréés.'),
  (v_formation, 'qcm', 'Pour un envoi de 3 tonnes ou plus, qui est responsable du chargement de la marchandise ?', '[{"id":"a","label":"Le transporteur","is_correct":false},{"id":"b","label":"L''expéditeur","is_correct":true},{"id":"c","label":"Le destinataire","is_correct":false},{"id":"d","label":"L''assureur","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','chargement'], 'mft-2026:moduleF:qcm:12', true, 'Article L. 1432-2 C. transp. : pour les envois ≥ 3 t, le chargement et l''arrimage incombent à l''expéditeur. Pour < 3 t, c''est généralement le transporteur qui prend en charge.'),
  (v_formation, 'qcm', 'Un protocole de sécurité doit être établi conjointement par :', '[{"id":"a","label":"Le transporteur seul","is_correct":false},{"id":"b","label":"Le donneur d''ordre et le transporteur","is_correct":true},{"id":"c","label":"L''inspection du travail","is_correct":false},{"id":"d","label":"L''assureur","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','protocole-securite'], 'mft-2026:moduleF:qcm:13', true, 'Protocole de sécurité co-établi par le donneur d''ordre et le transporteur extérieur intervenant régulièrement. Mis à jour si l''activité ou les conditions changent.'),
  (v_formation, 'qcm', 'Une surcharge supérieure à 20 % du PTAC est sanctionnée par :', '[{"id":"a","label":"Avertissement","is_correct":false},{"id":"b","label":"Contravention 4e classe : 135 €","is_correct":false},{"id":"c","label":"Contravention 5e classe : 1 500 €","is_correct":true},{"id":"d","label":"Délit pénal","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-f','capa-3-5t','surcharge'], 'mft-2026:moduleF:qcm:14', true, 'Surcharge > 20 % = 5e classe (1 500 €) + immobilisation possible. Surcharge 5-20 % = 4e classe (135 € + 3 points). Tolérance < 5 %. Responsabilité partagée donneur d''ordre / chargeur / transporteur.'),
  (v_formation, 'qcm', 'L''ADR est :', '[{"id":"a","label":"L''Accord européen relatif au transport international des marchandises Dangereuses par Route","is_correct":true},{"id":"b","label":"L''Autorité de Régulation des Transports","is_correct":false},{"id":"c","label":"Une convention sur les denrées périssables","is_correct":false},{"id":"d","label":"Une norme technique sur les véhicules","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-f','capa-3-5t','adr','tmd'], 'mft-2026:moduleF:qcm:15', true, 'ADR = Accord européen (signé en 1957 à Genève) qui réglemente le transport international des marchandises dangereuses par route. Mis à jour tous les 2 ans (versions 2025, 2027...).'),
  (v_formation, 'qcm', 'Combien de classes de matières dangereuses sont définies par l''ADR ?', '[{"id":"a","label":"5","is_correct":false},{"id":"b","label":"7","is_correct":false},{"id":"c","label":"9","is_correct":true},{"id":"d","label":"12","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','adr','classes'], 'mft-2026:moduleF:qcm:16', true, '9 classes : 1 (explosifs), 2 (gaz), 3 (liquides inflammables), 4 (solides inflammables), 5 (comburants), 6 (toxiques), 7 (radioactifs), 8 (corrosifs), 9 (autres dont Li-ion).'),
  (v_formation, 'qcm', 'Pour transporter des matières dangereuses au-dessus du seuil ADR, le conducteur doit avoir :', '[{"id":"a","label":"Aucun document spécifique","is_correct":false},{"id":"b","label":"Un certificat de formation ADR","is_correct":true},{"id":"c","label":"Le permis poids-lourd","is_correct":false},{"id":"d","label":"Une attestation médicale spéciale","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','adr','formation'], 'mft-2026:moduleF:qcm:17', true, 'Certificat de formation ADR obligatoire pour les conducteurs au-dessus des seuils. Formation initiale + formation de recyclage tous les 5 ans. Plus document de transport, consignes écrites, agrément du véhicule.'),
  (v_formation, 'qcm', 'L''accord ATP régit :', '[{"id":"a","label":"Les transports de matières dangereuses","is_correct":false},{"id":"b","label":"Les transports de denrées périssables (températures contrôlées)","is_correct":true},{"id":"c","label":"Les transports de marchandises générales","is_correct":false},{"id":"d","label":"Les transports d''animaux vivants","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','atp','denrees'], 'mft-2026:moduleF:qcm:18', true, 'ATP = Accord relatif aux Transports Périssables (1970). Définit les catégories de véhicules (IN, IR, RNA, FRC, FRA) et les températures réglementaires.'),
  (v_formation, 'qcm', 'Pour transporter des crèmes glacées, quelle catégorie de véhicule ATP est requise ?', '[{"id":"a","label":"IN (Isotherme Normale)","is_correct":false},{"id":"b","label":"FRC (Frigorifique classe C)","is_correct":true},{"id":"c","label":"RNA (Réfrigérant classe A)","is_correct":false},{"id":"d","label":"Aucune obligation","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-f','capa-3-5t','atp','glaces'], 'mft-2026:moduleF:qcm:19', true, 'Glaces : -20 °C minimum requis = catégorie FRC (Frigorifique classe C). Surgelés : -18 °C. Frais : 0 à +8 °C selon produit.'),
  (v_formation, 'qcm', 'La formation hygiène alimentaire obligatoire pour le responsable du transport de denrées dure :', '[{"id":"a","label":"7 heures","is_correct":false},{"id":"b","label":"14 heures","is_correct":true},{"id":"c","label":"21 heures","is_correct":false},{"id":"d","label":"35 heures","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-f','capa-3-5t','hygiene','formation'], 'mft-2026:moduleF:qcm:20', true, '14 heures de formation hygiène alimentaire obligatoires pour les responsables de transport de denrées (référence : décret n° 2011-731). Plan de Maîtrise Sanitaire (PMS) + traçabilité + nettoyage / désinfection.'),
  (v_formation, 'qcm', 'En cas d''accident impliquant un salarié blessé, dans quel délai l''employeur doit-il déclarer l''accident à la CPAM ?', '[{"id":"a","label":"24 heures","is_correct":false},{"id":"b","label":"48 heures","is_correct":true},{"id":"c","label":"5 jours ouvrés","is_correct":false},{"id":"d","label":"1 mois","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','accident','at'], 'mft-2026:moduleF:qcm:21', true, '48 heures pour la déclaration AT à la CPAM, articles L. 441-2 du Code de la sécurité sociale. Le salarié dispose de 24 h pour informer son employeur. Déclaration sinistre auto à l''assureur : 5 jours ouvrés.'),
  (v_formation, 'qcm', 'Quel est le numéro d''appel d''urgence européen unique ?', '[{"id":"a","label":"15","is_correct":false},{"id":"b","label":"17","is_correct":false},{"id":"c","label":"18","is_correct":false},{"id":"d","label":"112","is_correct":true}]'::jsonb, 1, 'facile', ARRAY['module-f','capa-3-5t','urgence'], 'mft-2026:moduleF:qcm:22', true, '112 = numéro d''urgence européen, valide dans toute l''UE et gratuit. Centralise SAMU, pompiers, police. Numéros nationaux : 15 (SAMU), 17 (police), 18 (pompiers).'),
  (v_formation, 'qcm', 'Quelle est la 1re cause d''accidents mortels en France dans le cadre professionnel ?', '[{"id":"a","label":"Chutes de hauteur","is_correct":false},{"id":"b","label":"Manutention","is_correct":false},{"id":"c","label":"Accidents de la route","is_correct":true},{"id":"d","label":"Risques chimiques","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','risque-routier'], 'mft-2026:moduleF:qcm:23', true, 'Les accidents de la route sont la 1re cause d''accidents mortels professionnels en France. D''où l''importance d''inscrire le risque routier au DUERP et de former les conducteurs.'),
  (v_formation, 'qcm', 'La vignette Crit''Air est obligatoire pour circuler dans :', '[{"id":"a","label":"Toute la France métropolitaine","is_correct":false},{"id":"b","label":"Les Zones à Faibles Émissions (ZFE)","is_correct":true},{"id":"c","label":"Uniquement Paris","is_correct":false},{"id":"d","label":"Les autoroutes","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','crit-air','zfe'], 'mft-2026:moduleF:qcm:24', true, 'Vignette Crit''Air obligatoire dans toutes les ZFE (Paris, Lyon, Grenoble, Marseille, Strasbourg...). Les véhicules trop polluants y sont progressivement interdits.'),
  (v_formation, 'qcm', 'Quelle norme Euro correspond à la vignette Crit''Air 2 ?', '[{"id":"a","label":"Euro 3","is_correct":false},{"id":"b","label":"Euro 4","is_correct":false},{"id":"c","label":"Euro 5 et 6 diesel","is_correct":true},{"id":"d","label":"Uniquement véhicules électriques","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-f','capa-3-5t','crit-air','euro'], 'mft-2026:moduleF:qcm:25', true, 'Crit''Air 2 = Euro 5 et 6 diesel (depuis 2015), Euro 4 essence. Crit''Air 1 = essence Euro 5/6, hybride. Crit''Air E = électrique / hydrogène.'),
  (v_formation, 'qcm', 'L''éco-conduite permet typiquement d''économiser :', '[{"id":"a","label":"2 à 5 % de carburant","is_correct":false},{"id":"b","label":"10 à 15 % de carburant","is_correct":true},{"id":"c","label":"30 % de carburant","is_correct":false},{"id":"d","label":"Aucune économie significative","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-f','capa-3-5t','eco-conduite'], 'mft-2026:moduleF:qcm:26', true, '10 à 15 % d''économie carburant via l''éco-conduite (anticipation, vitesse régulière, arrêt moteur > 30 s). Bénéfices secondaires : -10 % CO2, -20 % usure pneus/freins, -15 % accidents matériels.'),
  (v_formation, 'qcm', 'La loi LOM (Loi d''Orientation des Mobilités) de 2019 vise notamment à :', '[{"id":"a","label":"Augmenter les limitations de vitesse","is_correct":false},{"id":"b","label":"Verdir progressivement la flotte des entreprises","is_correct":true},{"id":"c","label":"Supprimer les ZFE","is_correct":false},{"id":"d","label":"Réduire le nombre de transporteurs","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-f','capa-3-5t','lom','environnement'], 'mft-2026:moduleF:qcm:27', true, 'Loi LOM (24 décembre 2019) : verdissement de la flotte (% de véhicules à faibles émissions imposé pour les flottes > 100 véhicules), développement du covoiturage, mise en place des ZFE.'),
  (v_formation, 'qcm', 'Les huiles usées d''un atelier intégré doivent être :', '[{"id":"a","label":"Évacuées avec les déchets ménagers","is_correct":false},{"id":"b","label":"Collectées par un centre agréé pour valorisation","is_correct":true},{"id":"c","label":"Brûlées sur site","is_correct":false},{"id":"d","label":"Rejetées dans le sol","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','environnement','dechets'], 'mft-2026:moduleF:qcm:28', true, 'Huiles usées = déchets dangereux à collecter par un centre agréé pour valorisation (régénération en huiles neuves ou combustible). Idem pour les filtres usagés, batteries, pneus.'),
  (v_formation, 'qcm', 'Une infraction environnementale grave peut entraîner pour le dirigeant :', '[{"id":"a","label":"Aucune conséquence professionnelle","is_correct":false},{"id":"b","label":"La perte de l''honorabilité professionnelle et la radiation du registre des transporteurs","is_correct":true},{"id":"c","label":"Une augmentation des cotisations URSSAF","is_correct":false},{"id":"d","label":"Une obligation de formation environnementale","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-f','capa-3-5t','environnement','honorabilite'], 'mft-2026:moduleF:qcm:29', true, 'Article L. 541-46 C. environ. : les infractions environnementales graves font partie des motifs de perte d''honorabilité professionnelle (cf. Module C), entraînant la radiation du registre DREAL.'),
  (v_formation, 'qcm', 'Le Document Unique d''Évaluation des Risques Professionnels (DUERP) doit obligatoirement inclure :', '[{"id":"a","label":"Uniquement les risques chimiques","is_correct":false},{"id":"b","label":"Le risque routier (1re cause d''accidents mortels au travail)","is_correct":true},{"id":"c","label":"Uniquement les risques liés aux machines","is_correct":false},{"id":"d","label":"Aucun risque spécifique au transport","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-f','capa-3-5t','duerp'], 'mft-2026:moduleF:qcm:30', true, 'Le DUERP doit recenser TOUS les risques. En transport, le risque routier est central et doit être documenté avec un plan d''actions de prévention (formation, contrôle des temps de conduite, audit flotte).');

  -- =================================================================
  -- BANQUE QR — Module F (6 mises en situation)
  -- =================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr',
    'Vous embauchez un chauffeur livreur. Comment vous assurez-vous qu''il dispose d''un permis valide pendant toute la durée de son contrat ?

a. Quelles vérifications à l''embauche ?
b. Le salarié doit-il vous communiquer son nombre de points ? Pourquoi ?
c. Quelles clauses prévoir dans son contrat ?
d. Que faire si vous découvrez qu''il a perdu son permis sans vous en informer ?',
    NULL, 5, 'moyen',
    ARRAY['module-f','capa-3-5t','qr','permis','employeur','cas-pratique'],
    'mft-2026:moduleF:qr:1', true,
    'Correction : a. Demande de présentation du permis original + photocopie + vérification de la catégorie adaptée au véhicule (B pour VUL ≤ 3,5 t). b. NON, le solde de points est une information personnelle (CNIL). Il doit en revanche vous informer de toute SUSPENSION ou INVALIDATION en cohérence avec son contrat. c. Clauses : (1) obligation de détenir un permis valide pendant toute la durée du contrat, (2) obligation d''informer immédiatement de toute suspension/invalidation, (3) interdiction formelle de conduire en cas de perte de permis, (4) sanctions disciplinaires possibles en cas de manquement. d. (1) Mise à pied conservatoire immédiate, (2) entretien préalable, (3) selon gravité : avertissement, mutation à un poste sans conduite, ou licenciement pour cause réelle et sérieuse. Si accident sans permis : faute inexcusable possible.'),

  (v_formation, 'qr',
    'Un de vos chauffeurs cause un accident matériel sans tiers identifié sur l''autoroute. Pas de blessé. Le véhicule est à remorquer.

a. Quels documents le chauffeur doit-il remplir et conserver ?
b. Quelles déclarations devez-vous faire en tant qu''employeur (qui, quand) ?
c. Quel impact comptable et financier (immobilisations, primes, franchises) ?
d. Quelles actions préventives mettre en place pour l''avenir ?',
    NULL, 5, 'difficile',
    ARRAY['module-f','capa-3-5t','qr','accident','cas-pratique'],
    'mft-2026:moduleF:qr:2', true,
    'Correction : a. (1) Constat amiable européen, (2) photos détaillées (véhicule, lieu, dégâts), (3) note manuscrite avec heure/lieu/circonstances, (4) coordonnées éventuels témoins. b. (1) Déclaration sinistre à l''assureur sous 5 jours ouvrés, (2) si chauffeur blessé : déclaration AT à la CPAM sous 48h, (3) information du donneur d''ordre / clients (retard/perte), (4) information CSE si présent, (5) mise à jour DUERP et registre des accidents. c. (1) Comptabilité : passage en charges exceptionnelles, (2) primes assurance susceptibles d''augmenter au renouvellement, (3) franchise à supporter, (4) valeur nette comptable du véhicule en perte. d. (1) Audit causes (vitesse, fatigue, mécanique?), (2) formation éco-conduite et anticipation pour l''équipe, (3) renforcement contrôle des temps de conduite, (4) contrôle technique anticipé du parc, (5) mise à jour du plan de prévention dans le DUERP, (6) sensibilisation préventive sur les risques routiers.'),

  (v_formation, 'qr',
    'Vous êtes contrôlé sur autoroute. Surcharge constatée : votre VUL (PTAC 3 500 kg) est chargé à 4 200 kg.

a. Quelle infraction est constatée et quelle sanction ?
b. Qui peut être sanctionné en plus du conducteur ?
c. Quelles obligations l''employeur a-t-il pour prévenir ce risque ?
d. Quels équipements ou outils peuvent éviter ce type d''infraction ?',
    NULL, 5, 'difficile',
    ARRAY['module-f','capa-3-5t','qr','surcharge','cas-pratique'],
    'mft-2026:moduleF:qr:3', true,
    'Correction : a. Surcharge = (4 200 - 3 500) / 3 500 = 20 %. À 20 % exactement, on est encore en 4e classe (135 € + 3 points). Mais > 20 % bascule en 5e classe (1 500 €) + immobilisation possible du véhicule jusqu''au déchargement. b. Article L. 3242-3 C. transp. : responsabilité partagée entre le donneur d''ordre, le chargeur ET le transporteur. Tous peuvent être verbalisés selon leurs contributions respectives. c. (1) Sensibiliser et former les chauffeurs au PTAC et à la lecture du document de pesée, (2) prévoir des pesées avant départ (notamment vrac), (3) mise à jour DUERP avec risque de surcharge identifié, (4) plan de prévention écrit avec procédures de chargement, (5) rappel à l''ordre / sanctions disciplinaires en cas de récidive. d. (1) Pèse-essieux portatifs ou intégrés au site, (2) capteur de charge utile à bord (option), (3) procédures écrites de chargement pour chaque type de marchandise, (4) clause donneur d''ordre l''obligeant à fournir les poids exacts, (5) contrôles aléatoires aux dépôts.'),

  (v_formation, 'qr',
    'Vous voulez transporter des matières classifiées ADR (gazole en quantité supérieure au seuil pour un client industriel).

a. Quelles obligations pour vos conducteurs ?
b. Quelles obligations pour vos véhicules ?
c. Quels documents doivent être à bord lors du transport ?
d. Devez-vous désigner un conseiller à la sécurité TMD ? Avec quelles missions ?',
    NULL, 5, 'difficile',
    ARRAY['module-f','capa-3-5t','qr','adr','tmd','cas-pratique'],
    'mft-2026:moduleF:qr:4', true,
    'Correction : a. Conducteurs : (1) certificat de formation ADR initiale + spécialisation classe (3 = liquides inflammables pour le gazole), (2) recyclage tous les 5 ans, (3) consignes écrites remises avant le transport, (4) EPI (lunettes, gants, etc.). b. Véhicules : (1) certificat d''agrément ADR pour le véhicule (visite spécifique, équipements anti-déflagration), (2) signalisation ADR (étiquettes orange avec n° UN du gazole = UN 1202, code danger 30), (3) extincteurs adaptés (poids minimum selon PTAC), (4) trousses de premiers secours. c. À bord : (1) document de transport indiquant n° UN, classes, poids/volume, (2) consignes écrites au conducteur dans la langue qu''il comprend, (3) certificat de formation ADR du conducteur, (4) certificat d''agrément du véhicule, (5) attestation d''assurance avec couverture ADR. d. OUI obligatoire (article 1.8.3 ADR) au-dessus du seuil. Missions : (1) conseiller la direction et les opérateurs, (2) suivre la conformité, (3) rapport annuel à la direction, (4) analyse des incidents, (5) formation interne, (6) rapport au préfet en cas d''incident grave.'),

  (v_formation, 'qr',
    'Vous mettez en place une démarche de prévention du risque routier dans votre entreprise (8 chauffeurs, 5 VUL).

a. Quel document obligatoire devez-vous mettre à jour et avec quels éléments ?
b. Quelles 5 actions concrètes proposer dans votre plan de prévention ?
c. Quels indicateurs suivre pour mesurer l''efficacité ?
d. Quel impact financier pouvez-vous espérer (estimation ordres de grandeur) ?',
    NULL, 5, 'moyen',
    ARRAY['module-f','capa-3-5t','qr','prevention','duerp','cas-pratique'],
    'mft-2026:moduleF:qr:5', true,
    'Correction : a. DUERP : recenser le risque routier (1re cause AT mortels), avec analyse des causes spécifiques (vitesse, fatigue, alcool, téléphone, distraction), niveaux de risque et plan d''actions. Conservation 40 ans. b. (1) Formation initiale et continue : éco-conduite, sécurité routière (renouvellement annuel), (2) Limitation des heures de conduite (respect 9 h max + pauses + repos), (3) Politique « tolérance zéro » alcool/téléphone, contrôles aléatoires, (4) Audit régulier du parc (CT à jour, pneus, freins, éclairage), (5) Animation : retours d''expérience d''accidents, partage des bonnes pratiques. c. (1) Nb d''accidents matériels par 100 000 km, (2) Nb d''AT routiers, (3) Coût total des sinistres, (4) Consommation moyenne (proxy éco-conduite), (5) Score de conduite par chauffeur (boîtier télématique). d. Estimation : -15 % consommation = ≈ 3 000-5 000 €/véhicule/an de carburant. -20 % usure pneus/freins ≈ 500-1 000 €/véhicule/an. Diminution sinistralité = baisse des primes assurance (-5 à -15 % à terme). Total potentiel : 5 000 à 8 000 €/véhicule/an. Sur 5 véhicules = 25 000 à 40 000 €/an d''économies.'),

  (v_formation, 'qr',
    'Vous gérez un atelier intégré pour entretenir vos 6 véhicules.

a. Quels déchets dangereux générez-vous typiquement ?
b. Quelles obligations de stockage et d''évacuation ?
c. Que se passe-t-il en cas de pollution accidentelle (fuite carburant, déversement huile) ?
d. Quel impact possible sur votre honorabilité professionnelle de transporteur ?',
    NULL, 5, 'moyen',
    ARRAY['module-f','capa-3-5t','qr','environnement','dechets','cas-pratique'],
    'mft-2026:moduleF:qr:6', true,
    'Correction : a. Déchets dangereux : (1) huiles usées (vidanges), (2) filtres à huile et à gazole usagés, (3) liquides de frein et de refroidissement, (4) batteries usagées, (5) pneus en fin de vie (déchets non dangereux mais filière dédiée), (6) chiffons souillés, (7) emballages contaminés. b. (1) Stockage en zone de rétention étanche (capacité ≥ 100 % du volume stocké), (2) collecte par centre agréé (BSD : Bordereau de Suivi des Déchets), (3) durée de stockage limitée (1 an max pour les déchets dangereux), (4) registre des déchets sortants à conserver 5 ans, (5) déclaration ICPE selon volumes (certains seuils). c. (1) Confinement immédiat avec absorbant (sable, sciure, kit anti-pollution), (2) alerte des autorités (préfecture, sapeurs-pompiers si déversement important), (3) déclaration assureur, (4) plan de dépollution (entreprise spécialisée), (5) sanction administrative et pénale possibles, (6) responsabilité civile pour les dommages aux tiers. d. Article L. 541-46 C. environ. : les infractions environnementales graves figurent dans la liste des infractions susceptibles d''entraîner la perte de l''honorabilité professionnelle (cf. Module C). Conséquences : (1) perte d''honorabilité, (2) radiation du registre DREAL des transporteurs, (3) retrait des licences, (4) impossibilité de continuer à exercer la profession.');

  -- =================================================================
  -- QUIZZES par leçon + examen blanc
  -- =================================================================

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Permis et conduite — Quiz', 'Quiz sur le permis à points, l''alcool, le téléphone, les obligations employeur.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleF:qcm:1','mft-2026:moduleF:qcm:2','mft-2026:moduleF:qcm:3','mft-2026:moduleF:qcm:4','mft-2026:moduleF:qcm:5','mft-2026:moduleF:qcm:6','mft-2026:moduleF:qcm:7','mft-2026:moduleF:qcm:8');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Véhicule et entretien — Quiz', 'Quiz sur le contrôle technique, les vérifications, les équipements obligatoires.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleF:qcm:9','mft-2026:moduleF:qcm:10','mft-2026:moduleF:qcm:11','mft-2026:moduleF:qcm:24','mft-2026:moduleF:qcm:25');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Chargement et transports spéciaux — Quiz', 'Quiz sur le chargement, la surcharge, l''ADR, les denrées périssables.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleF:qcm:12','mft-2026:moduleF:qcm:13','mft-2026:moduleF:qcm:14','mft-2026:moduleF:qcm:15','mft-2026:moduleF:qcm:16','mft-2026:moduleF:qcm:17','mft-2026:moduleF:qcm:18','mft-2026:moduleF:qcm:19','mft-2026:moduleF:qcm:20');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Sécurité travail et environnement — Quiz', 'Quiz sur la conduite après accident, la prévention, l''environnement, l''éco-conduite.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleF:qcm:21','mft-2026:moduleF:qcm:22','mft-2026:moduleF:qcm:23','mft-2026:moduleF:qcm:26','mft-2026:moduleF:qcm:27','mft-2026:moduleF:qcm:28','mft-2026:moduleF:qcm:29','mft-2026:moduleF:qcm:30');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — Module F', 'Examen blanc Module F : 6 QCM en 14 min, seuil 50 %.', 'examen', 840, 50)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleF:qcm:1','mft-2026:moduleF:qcm:5','mft-2026:moduleF:qcm:9','mft-2026:moduleF:qcm:14','mft-2026:moduleF:qcm:21','mft-2026:moduleF:qcm:26');

  RAISE NOTICE '✅ Module F v2 chargé : 4 leçons, 30 QCM, 6 QR, 5 quizzes.';
END
$module_f_v2$;
