-- =====================================================================
-- MODULE C — CADRE RÉGLEMENTAIRE DU TRANSPORT (Capacité ≤ 3,5 T)
-- Version 2 (mai 2026) — refonte complète depuis PDF officiels.
--
-- Référentiel (décision du 2 avril 2012) : 13 QCM (2 pts) + 1 QR (10 pts)
-- = 36 points sur 84 — le module le plus important de l'examen national.
--
-- ▸ 4 leçons (organisation profession / accès profession / contrat
--   transport / contrats spéciaux & assurances)
-- ▸ 35 QCM reformulés (préfixe mft-2026:moduleC:qcm:N)
-- ▸ 6 QR transport (max_score 5)
-- ▸ Quizzes par leçon + 1 examen blanc Module C
--
-- Idempotent. Pré-requis : formation 'capacite-3-5t'.
-- =====================================================================

DO $module_c_v2$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson_1 uuid;
  v_lesson_2 uuid;
  v_lesson_3 uuid;
  v_lesson_4 uuid;
  v_quiz_1 uuid;
  v_quiz_2 uuid;
  v_quiz_3 uuid;
  v_quiz_4 uuid;
  v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable.';
  END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'capa-cadre-reglementaire';

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'Module C — Cadre réglementaire du transport',
    'capa-cadre-reglementaire',
    v_bloc,
    'Maîtriser l''organisation de la profession, les conditions d''accès, le contrat de transport et ses contentieux, les contrats spéciaux et les assurances obligatoires.',
    'avance',
    180,
    30
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 30, true)
  ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026:moduleC:%';

  -- =================================================================
  -- LEÇON 1 — L'organisation de la profession
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'L''organisation de la profession de transporteur',
    'organisation-profession',
    1, 25,
$lesson1$
# L'organisation de la profession de transporteur

Le transport routier est une profession **réglementée**. Connaître les acteurs qui définissent, contrôlent et représentent la profession, c'est savoir vers qui se tourner quand on crée son entreprise, qu'on subit un contrôle ou qu'on défend ses intérêts.

> 🎯 **Objectifs de la leçon**
>
> - Identifier les **3 volets** de l'organisation : pouvoirs publics, organismes consultatifs, organisations professionnelles.
> - Distinguer **transport pour compte d'autrui** vs **compte propre**.
> - Connaître le rôle des **DREAL**, du **CNR**, des **CTSA**.

---

## 1. Compte d'autrui vs compte propre

C'est la première distinction à maîtriser, car elle conditionne **tout le cadre réglementaire**.

| Type | Définition | Régime |
|---|---|---|
| **Compte d'autrui** (transport public) | Transport effectué pour un client tiers contre rémunération | **Réglementé** : inscription DREAL, 4 exigences, licence |
| **Compte propre** (transport privé) | Transport effectué par une entreprise pour ses propres besoins | **Libéralisé** : pas d'inscription au registre des transporteurs |

> 🚛 **Exemple**
>
> - Une boulangerie qui livre ses propres pâtisseries à ses propres boutiques = **compte propre** (libre).
> - Vous, transporteur indépendant, qui livrez des colis pour des e-commerçants = **compte d'autrui** (réglementé).

### 1.1 Cas particuliers libéralisés (article R. 3211-3 à R. 3211-5)

Certains transports échappent à la réglementation même s'ils sont effectués pour autrui :

- Transports avec **véhicules ou appareils agricoles**
- Transports d'**entraide entre exploitations agricoles** (occasionnel, gratuit, ≤ 100 km)
- **Collecte du lait** dans le cadre d'une exploitation
- Transports de **La Poste** avec ses propres véhicules
- Transports au sein des **groupements d'entreprises agricoles**
- Transports de **marchandises par autocars de ligne**
- Véhicules à **emplois très spéciaux** (vitesse ≤ 25 km/h, engins spéciaux)
- Transports de **véhicules accidentés ou en panne** (dépanneuse)
- Transports de **wagons sur routes**

---

## 2. Les 3 volets de l'organisation

### 2.1 Les pouvoirs publics

Définissent et appliquent la politique nationale des transports.

| Niveau | Acteur | Rôle |
|---|---|---|
| **National** | Ministère des Transports | Définit la politique nationale, signe les textes de loi |
| **National** | DGITM (Direction générale des infrastructures, transports et mobilités) | Administration centrale |
| **Régional** | Préfet de région | Met en œuvre la politique de l'État, prononce les sanctions |
| **Régional** | DREAL (Direction régionale de l'environnement, de l'aménagement et du logement) | Inscription au registre, contrôles, instruction des dossiers |
| **Départemental** | DDT (Direction départementale des territoires) | Application locale |
| **Routier** | DIR (Directions interdépartementales des routes) | Gestion du réseau routier |

> 📌 **À retenir**
>
> En Île-de-France, la DREAL s'appelle **DRIEAT** (Direction régionale et interdépartementale de l'environnement, de l'aménagement et des transports).

### 2.2 Les organismes consultatifs et contentieux

Émettent des avis sur les textes de loi et les sanctions.

| Organisme | Rôle |
|---|---|
| **CTSA** (Commission territoriale des sanctions administratives) | Consulte le préfet de région **avant** toute sanction administrative contre un transporteur, son représentant légal ou son gestionnaire |

### 2.3 Les organisations professionnelles

Représentent et défendent les intérêts des transporteurs.

| Organisme | Rôle |
|---|---|
| **CNR** (Comité National Routier) | Observe les prix et coûts du transport, élabore les statistiques de bases tarifaires |
| **FNTR** (Fédération Nationale des Transports Routiers) | Premier syndicat patronal du TRM |
| **OTRE** (Organisation des Transporteurs Routiers Européens) | Représente les TPE/PME du transport |
| **TLF** (Fédération des entreprises de Transport et Logistique de France) | Logistique + transport |
| **CSD** (Chambre Syndicale des entreprises de Déménagement) | Spécifique au déménagement |

> 💡 **Conseil pratique**
>
> Adhérer à une organisation professionnelle (FNTR, OTRE, TLF) coûte 200 € à 1 500 €/an mais donne accès à : conventions cadres, conseils juridiques, formations, lobbying. Indispensable dès que vous embauchez.

---

## 🧠 Synthèse

| Question | Réponse |
|---|---|
| Compte d'autrui | Transport pour un client tiers, **réglementé** |
| Compte propre | Transport pour ses propres besoins, **libéralisé** |
| Administration qui inscrit au registre | **DREAL** (DRIEAT en Île-de-France) |
| Organisme qui consulte avant sanction | **CTSA** |
| Organisme qui observe les prix et coûts | **CNR** |
| Premier syndicat de transporteurs | **FNTR** |
| Préfet qui prononce les sanctions | Préfet de **région** |
$lesson1$,
'Compte d''autrui vs compte propre, DREAL, CTSA, CNR, FNTR, OTRE — les acteurs qui structurent la profession.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — L'accès à la profession
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'L''accès à la profession',
    'acces-profession',
    2, 50,
$lesson2$
# L'accès à la profession

Pour exercer le transport public routier de marchandises, **toute entreprise** doit s'inscrire au registre des transporteurs tenu par la DREAL. Et pour s'inscrire, elle doit satisfaire à **4 exigences cumulatives**. C'est le cœur du référentiel — et de l'examen.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser les **4 exigences** d'accès à la profession.
> - Connaître les seuils de **capacité financière** pour ≤ 3,5 t.
> - Comprendre les **3 voies d'obtention** de l'attestation de capacité professionnelle.
> - Identifier les conditions de **perte de l'honorabilité**.
> - Maîtriser les **titres administratifs** (licences) et leur durée.
> - Connaître les **délais de régularisation** en cas d'incident.

---

## 1. Les 4 exigences à satisfaire

Tout transporteur en compte d'autrui doit, pour s'inscrire au registre des transporteurs DREAL, justifier des 4 exigences cumulatives :

| Exigence | Ce qu'elle vérifie |
|---|---|
| **Établissement** | L'entreprise est-elle physiquement implantée et opérationnelle en France ? |
| **Capacité professionnelle** | Le dirigeant ou le gestionnaire de transport a-t-il les compétences ? |
| **Capacité financière** | L'entreprise a-t-elle assez de fonds propres pour fonctionner ? |
| **Honorabilité professionnelle** | Les dirigeants n'ont-ils pas un casier ou des antécédents disqualifiants ? |

> ⚠️ **Important**
>
> Le **non-respect** de l'inscription au registre est qualifié de **délit pénal**. La demande s'effectue auprès de la **DREAL de la région où l'entreprise a son siège**.

---

## 2. Détail des 4 exigences

### 2.1 L'exigence d'établissement

L'entreprise doit disposer en France :

- D'un **établissement** constituant le siège (ou pour une entreprise étrangère, son établissement principal)
- De **locaux** où elle conserve ses **principaux documents**
- D'au moins **un véhicule motorisé** (en pleine propriété, location-vente, location, crédit-bail, ou mise à disposition)
- D'**équipements administratifs et installations techniques** dans la région ou une région limitrophe

> 💡 **Cas typique**
>
> Une boîte aux lettres + un téléphone portable **ne suffisent pas**. Il faut un **lieu physique** avec des moyens d'exploitation réels.

### 2.2 La capacité professionnelle

Pour les véhicules ≤ 3,5 t (exploitation nationale ou internationale en deçà de 2,5 t à l'international) :

> Il faut détenir **l'attestation de capacité professionnelle en transport routier léger de marchandises**.

#### Les 3 voies d'obtention

| Voie | Condition |
|---|---|
| **1. Examen** | Suivre une formation de **105 h** dans un centre agréé + réussir l'examen final |
| **2. Diplôme** | Être titulaire du **bac pro Exploitation des transports** ou **bac pro Transport** |
| **3. Expérience** | Avoir dirigé en continu une entreprise de TRM pendant **≥ 2 ans**, sans interruption supérieure à **10 ans** |

> ⚠️ **Important**
>
> Pour les véhicules de **2,5 t < PTAC ≤ 3,5 t** en transport **international intra-EEE**, il faut désormais l'attestation de capacité **transport routier LOURD** de marchandises (pas seulement légère).

### 2.3 La capacité financière

Le seuil minimum dépend du nombre de véhicules et du territoire :

| Configuration | Métropole | DOM-TOM |
|---|---|---|
| **1er véhicule** | **1 800 €** | 900 € |
| **Chaque véhicule supplémentaire** | **900 €** | 600 € |

L'entreprise doit justifier ce montant en **capitaux propres** ou en **garanties** (établissements financiers, assurances).

> ⚠️ **Limites des garanties**
>
> Les garanties accordées par les banques ou les assurances **ne peuvent pas dépasser la moitié** du montant total exigé. L'autre moitié doit être en **capitaux propres effectifs**.

#### Exemple de calcul

Pour une flotte de **3 véhicules** ≤ 3,5 t en métropole :
- 1 800 € (1er véhicule)
- + 900 € × 2 (2 véhicules supplémentaires)
- **= 3 600 € de capacité financière minimum**

La DREAL **vérifie en permanence** ce niveau, pas seulement à l'inscription.

### 2.4 L'honorabilité professionnelle

Doit être satisfaite par **toutes les personnes suivantes** :

- Tous les **représentants légaux** de l'entreprise
- La **personne physique** détentrice de la capacité professionnelle (gestionnaire de transport)

#### Causes de perte d'honorabilité

L'honorabilité **n'est plus remplie** lorsque la personne :

| Situation | Détail |
|---|---|
| **Interdiction d'exercer** | Pour vol, escroquerie, abus de confiance, etc. |
| **Infraction délictuelle grave** | Sécurité routière, temps de conduite, repos des conducteurs |
| **Plusieurs condamnations B2** | Inscrites au bulletin n° 2 du casier judiciaire pour des infractions visées par le Code pénal, le Code de commerce, le Code de la route, le Code du travail, le Code des transports, le Code de l'environnement ou le CGI |

> 📌 **Pour les résidents en France depuis < 5 ans**
>
> Ils doivent fournir une **preuve de non-condamnation** pour des faits similaires dans leur pays d'origine.

---

## 3. Le gestionnaire de transport

C'est la personne physique qui satisfait aux exigences de **capacité** et d'**honorabilité**, et qui dirige effectivement et en permanence les activités de transport de l'entreprise.

| Caractéristique | Détail |
|---|---|
| Désigné par | Le **représentant légal** de l'entreprise |
| En cas de groupe | **1 gestionnaire par filiale** obligatoirement |
| Cadre légal | Arrêté du 28 décembre 2011 |
| Responsabilité | **Pénale**, voire financière en cas d'infraction grave |

### 3.1 Ses missions (article R. 3211-43 Code des transports)

- Affectation des chargements et services aux conducteurs et véhicules
- Vérification des contrats et documents de transport
- **Comptabilité de base**
- Gestion de l'**entretien** des véhicules
- Vérification des **procédures de sécurité**

### 3.2 Stage de remise à niveau

> Une personne titulaire de l'attestation de capacité **qui n'a pas dirigé d'entreprise depuis ≥ 5 ans** doit suivre une **formation de 35 h** agréée pour actualiser ses connaissances avant d'être à nouveau désignée gestionnaire.

---

## 4. Les titres administratifs (licences)

Une fois inscrit au registre, l'entreprise reçoit ses **licences**. Ce sont les documents qui prouvent la régularité de la situation.

### 4.1 Licence de transport intérieur

Pour ≤ 3,5 t sur le territoire national, ou ≤ 2,5 t en transport international :

| Élément | Caractéristique |
|---|---|
| Titulaire | Entreprises non tenues de posséder une licence communautaire |
| Originale | **Une seule par entreprise**, conservée au siège |
| Copie certifiée conforme | **Une par véhicule** (PTAC ≤ 3,5 t y compris < 4 roues) |
| À bord du véhicule | La **copie**, pas l'original |
| Durée de validité | **Maximum 10 ans**, renouvellement à demander avant expiration |

### 4.2 Récap : les 5 étapes pour démarrer

| # | Étape | Détail |
|---|---|---|
| 1 | Vérifier les 4 exigences | Capacité financière, capacité pro, honorabilité, établissement |
| 2 | Désigner le gestionnaire de transport | Personne physique satisfaisant capacité + honorabilité |
| 3 | Inscription au registre des transporteurs | Auprès de la **DREAL** de la région du siège |
| 4 | Inscription au RNE (Registre National des Entreprises) | Sur `procedures.inpi.fr` |
| 5 | Délivrance des licences | Original au siège, copie certifiée à bord de chaque véhicule |

> ⚠️ **Depuis le 1er janvier 2023**
>
> Les **CFE** (Centres de formalités des entreprises) sont **supprimés**. Toutes les démarches d'immatriculation passent par le portail INPI : `procedures.inpi.fr`.

---

## 5. Les délais de régularisation

Tout changement modifiant la situation au regard des 4 exigences doit être porté à la connaissance du **préfet de région** dans un délai de **28 jours** (article R. 3411-14).

| Incident | Délai de régularisation |
|---|---|
| **Décès ou incapacité physique** du gestionnaire de transport | **9 mois** |
| **Perte d'honorabilité** du gestionnaire ou du représentant | **6 mois** |
| **Inaptitude** déclarée du gestionnaire | **6 mois** |
| **Perte de l'exigence d'établissement** | **6 mois** |
| **Perte de la capacité financière** | **6 mois** (démontrer un retour à la normale) |

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| 4 exigences | Établissement, capacité pro, capacité financière, honorabilité |
| Capacité financière 1er véhicule (métropole) | **1 800 €** |
| Capacité financière véhicule suppl. | **900 €** |
| Voies d'obtention attestation pro | Examen (105 h), diplôme (bac pro), expérience (≥ 2 ans, < 10 ans d'arrêt) |
| Garanties bancaires/assurances | **Maximum 50 %** de la capacité financière exigée |
| Délai notification de changement au préfet | **28 jours** |
| Délai régularisation après décès du gestionnaire | **9 mois** |
| Stage remise à niveau si arrêt > 5 ans | **35 h** |
| Durée validité licence | **10 ans maximum** |
| Document à bord du véhicule | **Copie certifiée conforme** de la licence |
$lesson2$,
'Les 4 exigences (établissement, capacité pro, capacité financière à 1 800 €, honorabilité), le gestionnaire de transport, les licences, les délais de régularisation.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Le contrat de transport
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Le contrat de transport : formation, exécution, responsabilité',
    'contrat-transport',
    3, 60,
$lesson3$
# Le contrat de transport : formation, exécution, responsabilité

Le contrat de transport est le **cœur juridique de votre activité**. Sa qualification, son exécution et la responsabilité qui en découle sont la matière la plus testée à l'examen — et celle qui peut vous coûter le plus cher en pratique.

> 🎯 **Objectifs de la leçon**
>
> - Définir le **contrat de transport** et ses 3 parties.
> - Maîtriser les obligations à la **prise en charge**, l'**acheminement** et la **livraison**.
> - Connaître les **3 causes d'exonération** de responsabilité.
> - Appliquer les **plafonds d'indemnisation** des contrats-types.
> - Comprendre la **lettre de voiture**, le **port dû** vs **port payé**, la **déclaration de valeur**.

---

## 1. Définition et cadre juridique

> **Contrat de transport** : convention par laquelle un transporteur professionnel (le **voiturier**) s'engage à déplacer une marchandise (l'**envoi**) d'un point à un autre, contre rémunération, dans un délai fixé par la loi, la convention des parties ou l'usage.

### 1.1 Cadre juridique des transports intérieurs

| Source | Articles |
|---|---|
| **Code civil** | Articles 1101 à 1369 (contrats en général) + 1782 à 1786 (contrat de transport) |
| **Code de commerce** | Articles L. 132-1 à L. 133-7 |
| **Code des transports** | Notamment LOTI + loi du 1er février 1995 « sécurité et modernisation » |
| **Conventions écrites des parties** | Font loi pour les parties |
| **Contrats-types** | À défaut de convention particulière, les contrats-types s'appliquent automatiquement |

### 1.2 Caractéristiques du contrat

Le contrat de transport est :
- **Consensuel** : il se forme par le simple échange des consentements
- **Tripartite** : 3 parties au minimum (expéditeur, transporteur, destinataire)
- **À obligation de résultat** : le transporteur est **automatiquement présumé responsable** en cas d'anomalie

> 📌 **Présomption de responsabilité**
>
> Le donneur d'ordre n'a **pas** à prouver que l'anomalie est due au transport. C'est au **transporteur** de prouver une cause d'exonération pour s'en dégager. Cette obligation court de la **prise en charge** à la **livraison effective**.

### 1.3 Les 3 parties

| Partie | Définition |
|---|---|
| **Expéditeur** | Conclut le contrat en son nom (pas nécessairement le lieu d'enlèvement) |
| **Transporteur** (voiturier) | Figure comme tel sur le document de transport |
| **Destinataire** | Figure comme tel sur le document, associé au contrat dès l'origine |

---

## 2. La formation du contrat

### 2.1 Le document de cadrage

La loi « sécurité et modernisation » impose un **document de cadrage** récapitulant les informations essentielles. Un **bon de commande / devis accepté** par le chargeur sert de document de cadrage.

#### Contenu obligatoire

| Catégorie | Détail |
|---|---|
| **Identité des parties** | Expéditeur, transporteur, destinataire |
| **Marchandise** | Poids, volume, composition, emballage, nature, déclaration de valeur, contre-remboursement |
| **Lieu et conditions** | Date, heure, accessibilité, prescriptions de sécurité |
| **Durées prévues** | Attente au chargement/déchargement, prestations annexes |
| **Type de matériel** | Carrosserie, équipements particuliers |
| **Mode de port** | **Port dû** ou **port payé** |
| **Prestations annexes** | Manutention, contre-remboursement, etc. |
| **Délais** | Délai de parcours, attentes, conditions de rémunération |
| **Prix et conditions de paiement** | Exigible au plus 30 jours fin de mois |

### 2.2 Port dû vs port payé

| Mode | Définition | Qui paie ? |
|---|---|---|
| **Port dû** | Frais de transport à la charge du **destinataire** | Le destinataire à l'arrivée |
| **Port payé** | Frais de transport à la charge de l'**expéditeur** | Le vendeur au départ |

### 2.3 La matérialisation

Trois documents matérialisent le contrat :

- **Document de suivi** : vérifie l'exécution conformément au devis accepté
- **Lettre de voiture** (ou récépissé en messagerie) : définit les conditions d'accompagnement de la marchandise
- **Ordre de mission** : confie au conducteur la mission de transporter (non obligatoire)

> 💡 **En pratique**
>
> Ces 3 documents sont souvent fusionnés dans un **document unique** : la **lettre de voiture** (ou CMR à l'international).

---

## 3. L'exécution du contrat

### 3.1 La prise en charge

C'est la **remise physique** de la marchandise au transporteur, qui l'**accepte juridiquement**. Le transporteur procède à plusieurs vérifications :

| Vérification | Objet |
|---|---|
| **État des marchandises** | Visible, externe |
| **Vérification du poids** | Confronter à ce qui est annoncé |
| **Nombre de colis** | Compter à la réception |
| **Vérification des emballages et supports** | Conformité au transport prévu |
| **Réserves éventuelles** | À noter par écrit, signées |

#### Effets des réserves vs absence de réserves

| Cas | Conséquence |
|---|---|
| **Réserves** prises au départ | Le transporteur s'exonère pour les anomalies signalées (avarie, défaut d'emballage) |
| **Aucune réserve** au départ | Le transporteur est **présumé** avoir reçu les marchandises en bon état → il devra les livrer dans cet état |

### 3.2 L'acheminement

Le transporteur a **3 obligations principales** :

- **Soigner la marchandise** (sécurité, propreté, climat)
- **Acheminer** : itinéraire le plus direct, signaler les empêchements, respecter les modifications du contrat initial
- **Livrer** : bon lieu, bon destinataire, bon moment

### 3.3 La livraison

| Type d'envoi | Lieu de mise à disposition |
|---|---|
| **≥ 3 tonnes** | Le **destinataire effectue le déchargement** lui-même |
| **< 3 tonnes — particulier** | **Au seuil de l'habitation** |
| **< 3 tonnes — commerces sur rue** | **Au seuil du magasin** |
| **< 3 tonnes — établissement industriel/commercial** | **Au pied du véhicule** dans l'enceinte |

> 🚛 **Le bon destinataire**
>
> - **Bon** : le destinataire réel, son conjoint, un mandataire dûment accrédité
> - **Douteux** : un tiers chez qui il est domicilié, un voisin, le concierge
> - **Indélicat** : un tiers qui prend livraison frauduleusement

> ⚠️ **Risque transporteur**
>
> Une livraison à un **tiers non mandaté** équivaut à une **perte totale** pour le destinataire. La responsabilité du transporteur est engagée, parfois pour **faute inexcusable**.

---

## 4. Les contentieux : responsabilité du transporteur

### 4.1 Le principe : présomption de responsabilité

> **Article L. 133-1 Code de commerce** : « Le voiturier est garant de la perte des objets à transporter et des avaries, hors le cas des forces majeures. »

Le transporteur a une **obligation de résultat**. Pour s'exonérer, il doit prouver l'une des **3 causes d'exonération** :

| Cause d'exonération | Définition |
|---|---|
| **Force majeure** | Événement irrésistible, imprévisible, extérieur (3 conditions cumulatives) |
| **Vice propre de la chose** | Détérioration due à une cause interne à la marchandise |
| **Faute du contractant** | Faute de l'expéditeur ou du destinataire (ex : mauvais emballage, absence à la livraison) |

> 📌 **Force majeure : 3 conditions cumulatives**
>
> 1. **Irrésistibilité** : événement insurmontable, le transporteur ne peut empêcher / exécuter ses obligations
> 2. **Imprévisibilité** : (de moins en moins exigée si le transporteur prouve qu'il a pris toutes les précautions)
> 3. **Extériorité** : extérieur à l'entreprise

### 4.2 Les causes d'exonération en cas de retard

Identiques à celles pour pertes/avaries, **sauf le vice propre** (qui ne s'applique pas en cas de retard).

> 💡 **Article L. 133-2 Code de commerce**
>
> *« Si, par l'effet de la force majeure, le transport n'est pas effectué dans le délai convenu, il n'y a pas lieu à indemnité contre les voituriers pour cause de retard. »*

L'ayant droit doit **justifier d'un préjudice direct** lié au retard pour être indemnisé.

---

## 5. Les plafonds d'indemnisation

Quand le transporteur ne peut pas s'exonérer, il indemnise — mais avec des **plafonds** définis par les contrats-types.

### 5.1 Contrat-type général : pertes ou avaries

> **On retient le montant LE PLUS PETIT entre les deux calculs.**

| Envoi | Plafond | Plafond alternatif |
|---|---|---|
| **< 3 tonnes** | **33 €/kg** de marchandise manquante ou avariée | **1 000 €/colis** perdu, incomplet ou avarié |
| **≥ 3 tonnes** | **20 €/kg** | **3 200 €/tonne d'envoi** |

#### Exemple de calcul

Vous perdez un colis de 50 kg, valeur réelle 1 500 €.
- Calcul kg : 50 × 33 € = **1 650 €**
- Calcul colis : **1 000 €**
- Plafond appliqué = le plus petit = **1 000 €**
- Vous indemnisez : min(préjudice réel, plafond) = min(1 500, 1 000) = **1 000 €**

### 5.2 Contrat-type température dirigée

| Envoi | Plafond | Plafond alternatif |
|---|---|---|
| **< 3 tonnes** | 23 €/kg | 750 €/colis |
| **≥ 3 tonnes** | 14 €/kg | 4 000 €/tonne |

### 5.3 Plafond en cas de retard

> **Plafond = montant du prix du transport** (pas de la marchandise).

### 5.4 Quand le transporteur **ne peut pas** invoquer les plafonds

| Cas | Conséquence |
|---|---|
| **Dol** (manquement grave et intentionnel) | Indemnisation **intégrale** |
| **Faute lourde ou inexcusable** | Indemnisation intégrale |
| **Déclaration de valeur** ou **intérêt spécial à la livraison** | Le montant déclaré se substitue au plafond |

---

## 6. La déclaration de valeur et l'intérêt spécial à la livraison

| Outil | Effet | Conditions |
|---|---|---|
| **Déclaration de valeur** | Substitue le montant déclaré au **plafond pour pertes/avaries** | Écrite, paiement d'un prix convenu, avant conclusion du contrat |
| **Intérêt spécial à la livraison** | Substitue le montant déclaré au **plafond pour retard** | Idem |

> ⚠️ **Marchandise volée vs avariée**
>
> - **Marchandise perdue ou volée** (sans dépôt de plainte) → indemnisée sur la base du **TTC**
> - **Marchandise avariée ou détruite** → indemnisée sur la base du **HT**

---

## 7. Le privilège du transporteur

> Le transporteur dispose légalement d'un **privilège** gagé sur la marchandise transportée pour s'assurer du paiement de ses services.

Concrètement, **il peut conserver la marchandise** en sa possession pour servir de gage à sa créance impayée. Les créances couvertes :

- Prix du transport
- Compléments (prestations annexes, immobilisations)
- Frais engagés dans l'intérêt de la marchandise
- Débours de douane

---

## 8. Les délais de réserves à la livraison

| Type de destinataire | Délai pour confirmer les réserves par LRAR |
|---|---|
| **Professionnel** (article L. 133-3 Code de commerce) | **3 jours francs** |
| **Particulier** (article L. 224-65 Code de la consommation) | **10 jours** |

À défaut de confirmation dans ces délais : **forclusion** (perte du droit de recours).

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Définition du contrat de transport | Convention par laquelle un voiturier déplace un envoi contre rémunération |
| Le contrat est | Consensuel, tripartite, à obligation de résultat |
| 3 parties | Expéditeur, transporteur (voiturier), destinataire |
| 3 causes d'exonération | Force majeure, vice propre, faute du contractant |
| Conditions de la force majeure | Irrésistibilité, imprévisibilité, extériorité |
| Plafond < 3 t (général) | **33 €/kg** ou **1 000 €/colis** (le plus petit) |
| Plafond ≥ 3 t (général) | **20 €/kg** ou **3 200 €/tonne** (le plus petit) |
| Plafond en cas de retard | **Prix du transport** |
| Pas de plafond si | Dol, faute inexcusable, déclaration de valeur |
| Délai de réserves PRO après livraison | **3 jours francs** par LRAR |
| Délai de réserves PARTICULIER | **10 jours** |
| Marchandise volée → indemnisation sur | **TTC** |
| Marchandise avariée → indemnisation sur | **HT** |
$lesson3$,
'3 parties au contrat, prise en charge / acheminement / livraison, 3 causes d''exonération, plafonds d''indemnisation 33 €/kg ou 1 000 €/colis (< 3 t).'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Contrats spéciaux et assurances
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Contrats spéciaux et assurances',
    'contrats-speciaux-assurances',
    4, 45,
$lesson4$
# Contrats spéciaux et assurances

Au-delà du contrat de transport classique, le transporteur léger croise 3 autres contrats fréquents : **location**, **sous-traitance**, **commission**. Et il ne peut pas exercer sans **assurances obligatoires**. Ces sujets sont régulièrement testés à l'examen.

> 🎯 **Objectifs de la leçon**
>
> - Distinguer **contrat de location** vs **contrat de transport**.
> - Comprendre la **sous-traitance** et le **contrat de commission**.
> - Connaître les **assurances obligatoires** du transporteur.
> - Maîtriser la **lettre de voiture déménagement** et ses 4 exemplaires.

---

## 1. Le contrat de location de véhicules

### 1.1 Définition

> **Contrat de location** : convention par laquelle un loueur met à la disposition d'un preneur un véhicule pour un temps (ou une opération) déterminé, moyennant le paiement d'un prix.

### 1.2 Location vs transport : quelle différence ?

C'est la question piège classique. Les deux régimes juridiques sont **très différents**, surtout en matière de responsabilité.

| Critère | Contrat de transport | Contrat de location |
|---|---|---|
| Maîtrise des opérations | Le **transporteur** | Le **locataire** |
| Obligation principale | **Résultat** (livrer la marchandise) | **Mise à disposition** d'un véhicule |
| Responsabilité | Présomption forte sur le transporteur | Partagée selon la nature du dommage |
| Facturation | À la course / au tonnage | Au temps de mise à disposition |
| Documents | Lettre de voiture | Feuille de location |

### 1.3 Indices retenus par le juge pour qualifier en location

- Inscription au **registre des loueurs** + RCS comme loueur
- Précision dans la convention du **type de véhicule, charge utile, volume**
- Facturation au **temps**, pas aux courses
- **Documents de transport établis par le locataire**

À défaut, le juge **requalifie** en contrat de transport (régime plus sévère).

### 1.4 Location avec conducteur : qui répond de quoi ?

Le décret du 21 juin 2014 + contrat-type encadrent les responsabilités.

| Acteur | Responsabilité |
|---|---|
| **Loueur** | Opérations de **conduite** : conduite, protection contre vol, préparation technique du véhicule, manipulation des équipements spéciaux |
| **Locataire** | Opérations de **transport** : nature/quantité des marchandises, lieu et délais, documents de transport, chargement / arrimage, déchargement |

#### Imputation des dommages

| Type de dommage | Qui répond ? |
|---|---|
| **Dommages à la marchandise transportée** | Le **locataire** (sauf s'il prouve un vice du véhicule, faute de conduite, manquement du loueur) |
| **Dommages au véhicule du loueur** | Le **locataire** si manquement à ses obligations |
| **Dommages aux tiers** | Le **loueur** (assurance RC du véhicule) |
| **Dommages aux biens du locataire** (remorque, semi) | Le **loueur** si vice caché ou faute de conduite |

### 1.5 Feuille de location

Document obligatoire avant la mise à disposition. **Forme libre** (papier ou électronique). Au moins **un exemplaire à bord du véhicule**.

#### Mentions minimales

- Date d'établissement
- N° d'immatriculation du véhicule loué
- Dates prévues de début / fin de mise à disposition
- Nom et adresse du **locataire**
- Régime de location (avec ou sans conducteur)
- Nom, adresse, **SIRET** ou identification intracommunautaire du **loueur**

> 📌 **Délai de prescription**
>
> Toutes les actions nées du contrat de location sont **prescrites à 1 an** (article 19 du décret 21/06/2014).

---

## 2. La sous-traitance de transport

### 2.1 Définition

C'est l'opération par laquelle le **transporteur principal** (donneur d'ordre) confie tout ou partie de l'exécution du transport à un autre transporteur (le **sous-traitant**), tout en restant responsable vis-à-vis de l'expéditeur initial.

### 2.2 Contrat-type sous-traitance

Le contrat-type encadre les rapports entre transporteur principal et sous-traitant. Points clés :

| Sujet | Règle |
|---|---|
| Forme du contrat | Écrite, conforme au contrat-type sauf convention contraire |
| Rémunération | Doit couvrir l'ensemble des coûts du sous-traitant (carburant, personnel, charges, marge) |
| Responsabilité | Le sous-traitant répond vis-à-vis du transporteur principal selon les règles du contrat de transport |
| Délai de paiement | **30 jours** maximum (article L. 441-11 Code de commerce) |
| Action directe | Le sous-traitant non payé par le donneur d'ordre peut **agir directement** contre l'expéditeur final (loi LOTI) |

> ⚠️ **Action directe (cruciale)**
>
> Si vous sous-traitez et que vous ne payez pas votre sous-traitant, **votre client final peut être poursuivi** par ce dernier. Cette protection a été instaurée pour limiter les abus dans la chaîne de transport.

---

## 3. Le contrat de commission de transport

### 3.1 Définition

> **Commissionnaire de transport** : intermédiaire qui organise un transport en son nom propre pour le compte d'un client (commettant), en choisissant les modes et les transporteurs.

### 3.2 Différence avec le transporteur

| Critère | Transporteur | Commissionnaire |
|---|---|---|
| Rôle | Effectue le transport | **Organise** le transport |
| Identité | Identifié sur le document de transport | Pas nécessairement |
| Responsabilité | Présomption art. L. 133-1 | Responsable des **fautes propres** + responsable des **fautes des sous-traitants** qu'il a choisis |
| Formation | Capacité de transport | **Capacité de commissionnaire** (formation spécifique) |

### 3.3 Régime de responsabilité

Le commissionnaire répond :
- De ses **fautes personnelles** (mauvais choix d'un sous-traitant)
- Des **fautes commises par les transporteurs** qu'il a sélectionnés (responsabilité **du fait d'autrui**)

C'est donc un régime **plus lourd** qu'une simple intermédiation.

---

## 4. Le contrat de déménagement et la lettre de voiture

### 4.1 Une activité spécifique

Le déménagement n'est pas un transport classique : c'est une **prestation globale** qui inclut transport + manutention + emballage + assurance. Encadrée par le Code de commerce (articles L. 132-8 et suivants) et le Code des transports.

### 4.2 Obligations contractuelles

| Élément | Obligation |
|---|---|
| **Devis** | Écrit, obligatoire avant toute prestation |
| **Contrat** | Écrit, précisant les termes, obligations, modalités de règlement |
| **Charte qualité** | Volontaire mais fréquente |

### 4.3 La lettre de voiture déménagement : 4 exemplaires

> Document essentiel qui formalise le contrat. Rédigée en **4 exemplaires** identiques :

| # | Destinataire | Rôle |
|---|---|---|
| **1** | Le **client** | Suivi de l'opération, vérification à la livraison, preuve en cas de litige |
| **2** | L'**entreprise de déménagement** | Trace du contrat, justification en cas de contrôle ou réclamation |
| **3** | À bord du **véhicule** | Justification légale du transport en cas de contrôle routier |
| **4** | L'**équipe de manutention** | Détails opérationnels (volume, contenu, lieux, dates) |

### 4.4 Limitation de responsabilité

Le déménageur **ne peut pas s'exonérer totalement** de sa responsabilité (article L. 133-1 Code de commerce). Il peut prévoir un **plafond d'indemnisation** par contrat, mais le client conserve un **droit à indemnisation** en cas de sinistre causé par l'entreprise.

---

## 5. Les assurances obligatoires

### 5.1 Le panel d'assurances du transporteur léger

| Assurance | Obligatoire ? | Couvre |
|---|---|---|
| **Responsabilité civile véhicule** | **OUI** (loi du 27/02/1958) | Dommages causés aux tiers par le véhicule |
| **Responsabilité civile professionnelle (RC pro)** | Oui pour le déménagement, recommandée pour le TRM | Dommages dans l'exercice de l'activité hors transport |
| **Marchandises transportées** | Souscrite par le **donneur d'ordre** (faculté), non par le transporteur | Le transporteur reste responsable selon les contrats-types |
| **Locaux professionnels** | Recommandée | Bâtiment, matériel, stocks |
| **Assurance perte d'exploitation** | Recommandée | Continuité d'activité après sinistre |

### 5.2 Assurance véhicule : règle de base

> Tout véhicule motorisé en circulation **DOIT** être couvert par une assurance responsabilité civile, qu'il soit propriété de l'entreprise ou loué (article L. 211-1 Code des assurances).

### 5.3 Assurance marchandises (faculté du donneur d'ordre)

- **Souscrite par le donneur d'ordre** (l'expéditeur)
- Couvre la marchandise « **de magasin à magasin** »
- Permet l'indemnisation **même si le transporteur invoque une cause d'exonération**
- Mécanisme de subrogation : l'assureur peut ensuite se retourner contre le transporteur

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Différence location / transport | Le **locataire** maîtrise les opérations de transport ; le **loueur** maîtrise la conduite |
| Document obligatoire avant location | **Feuille de location** (1 exemplaire à bord) |
| Prescription des actions sur contrat de location | **1 an** |
| Délai de paiement sous-traitance transport | **30 jours** maximum (L. 441-11) |
| Mécanisme protégeant le sous-traitant impayé | **Action directe** contre l'expéditeur final |
| Le commissionnaire est responsable | De ses fautes propres + des fautes des transporteurs choisis |
| Lettre de voiture déménagement | **4 exemplaires** (client, entreprise, véhicule, équipe) |
| Assurance obligatoire transporteur | **Responsabilité civile véhicule** |
| L'assurance marchandises est souscrite par | Le **donneur d'ordre** (l'expéditeur), pas le transporteur |
$lesson4$,
'Location vs transport, sous-traitance et action directe, commissionnaire de transport, lettre de voiture déménagement, assurance RC obligatoire.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE QCM REFORMULÉS — Module C (35 questions)
  -- =================================================================

  -- QCM 1 — Compte d'autrui (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le transport routier "pour compte d''autrui" désigne :',
    '[
      {"id":"a","label":"Un transport effectué par une entreprise pour ses propres besoins","is_correct":false},
      {"id":"b","label":"Un transport effectué par un transporteur pour le compte d''un client tiers contre rémunération","is_correct":true},
      {"id":"c","label":"Un transport bénévole entre particuliers","is_correct":false},
      {"id":"d","label":"Un transport gratuit entre filiales d''un même groupe","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-c','capa-3-5t','organisation','compte-autrui'],
    'mft-2026:moduleC:qcm:1', true,
    'Compte d''autrui = transport rémunéré pour un client tiers, soumis à la réglementation (DREAL, 4 exigences). Compte propre = pour ses propres besoins, libéralisé.');

  -- QCM 2 — Compte propre (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le transport "pour compte propre" est :',
    '[
      {"id":"a","label":"Strictement interdit en France","is_correct":false},
      {"id":"b","label":"Réglementé comme le compte d''autrui","is_correct":false},
      {"id":"c","label":"Libéralisé : non soumis à inscription au registre des transporteurs","is_correct":true},
      {"id":"d","label":"Soumis à un agrément spécifique","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-c','capa-3-5t','organisation','compte-propre'],
    'mft-2026:moduleC:qcm:2', true,
    'Le compte propre est libre car l''entreprise transporte pour ses propres besoins. Aucune inscription ni licence n''est requise.');

  -- QCM 3 — DREAL (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'L''inscription au registre des transporteurs s''effectue auprès de :',
    '[
      {"id":"a","label":"L''URSSAF","is_correct":false},
      {"id":"b","label":"La DREAL de la région du siège de l''entreprise","is_correct":true},
      {"id":"c","label":"Le tribunal de commerce","is_correct":false},
      {"id":"d","label":"Le ministère des Transports","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-c','capa-3-5t','acces-profession','dreal'],
    'mft-2026:moduleC:qcm:3', true,
    'C''est la DREAL (DRIEAT en Île-de-France) qui instruit la demande d''inscription au registre des transporteurs.');

  -- QCM 4 — 4 exigences (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quelles sont les 4 exigences cumulatives pour s''inscrire au registre des transporteurs ?',
    '[
      {"id":"a","label":"Capacité financière, professionnelle, honorabilité, établissement","is_correct":true},
      {"id":"b","label":"Permis B, capacité financière, casier judiciaire vierge, RCS","is_correct":false},
      {"id":"c","label":"Capacité fiscale, sociale, économique et logistique","is_correct":false},
      {"id":"d","label":"Diplôme, capital, agrément, formation continue","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-c','capa-3-5t','acces-profession','exigences'],
    'mft-2026:moduleC:qcm:4', true,
    'Les 4 exigences sont strictement définies : (1) Capacité financière, (2) Capacité professionnelle, (3) Honorabilité professionnelle, (4) Établissement.');

  -- QCM 5 — Capacité financière 1er véhicule (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Pour un transporteur léger ≤ 3,5 t exerçant en métropole, quelle capacité financière est exigée pour le PREMIER véhicule ?',
    '[
      {"id":"a","label":"900 €","is_correct":false},
      {"id":"b","label":"1 800 €","is_correct":true},
      {"id":"c","label":"3 600 €","is_correct":false},
      {"id":"d","label":"9 000 €","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','capacite-financiere'],
    'mft-2026:moduleC:qcm:5', true,
    'Capacité financière en métropole : 1 800 € pour le 1er véhicule + 900 € par véhicule supplémentaire. Outre-mer : 900 € + 600 €.');

  -- QCM 6 — Capacité financière véhicule supplémentaire (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Pour chaque véhicule supplémentaire, quelle capacité financière s''ajoute en métropole ?',
    '[
      {"id":"a","label":"450 €","is_correct":false},
      {"id":"b","label":"900 €","is_correct":true},
      {"id":"c","label":"1 800 €","is_correct":false},
      {"id":"d","label":"3 000 €","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','capacite-financiere'],
    'mft-2026:moduleC:qcm:6', true,
    'Chaque véhicule supplémentaire = 900 € en métropole. Pour 3 véhicules : 1 800 + 900 + 900 = 3 600 €.');

  -- QCM 7 — Garanties bancaires plafond (difficile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quelle est la part maximale de la capacité financière qui peut être couverte par des garanties bancaires ou d''assurance ?',
    '[
      {"id":"a","label":"100 %","is_correct":false},
      {"id":"b","label":"75 %","is_correct":false},
      {"id":"c","label":"50 %","is_correct":true},
      {"id":"d","label":"25 %","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-c','capa-3-5t','capacite-financiere','garanties'],
    'mft-2026:moduleC:qcm:7', true,
    'Les garanties (banque, assurance) ne peuvent couvrir QUE LA MOITIÉ de la capacité financière exigée. L''autre moitié doit être en capitaux propres réels.');

  -- QCM 8 — Voies d'obtention attestation (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'L''attestation de capacité professionnelle en transport routier léger peut s''obtenir par :',
    '[
      {"id":"a","label":"Examen, équivalence de diplôme, ou expérience professionnelle ≥ 2 ans","is_correct":true},
      {"id":"b","label":"Uniquement par examen","is_correct":false},
      {"id":"c","label":"Achat auprès d''un organisme privé","is_correct":false},
      {"id":"d","label":"Simple déclaration en préfecture","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','capacite-professionnelle'],
    'mft-2026:moduleC:qcm:8', true,
    '3 voies : (1) examen après 105 h de formation en centre agréé, (2) bac pro Exploitation transports ou Transport, (3) expérience continue de ≥ 2 ans, sans interruption supérieure à 10 ans.');

  -- QCM 9 — Durée formation capa pro (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quelle est la durée de la formation préparant à l''attestation de capacité professionnelle légère ?',
    '[
      {"id":"a","label":"35 heures","is_correct":false},
      {"id":"b","label":"105 heures","is_correct":true},
      {"id":"c","label":"140 heures","is_correct":false},
      {"id":"d","label":"210 heures","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-c','capa-3-5t','capacite-professionnelle','formation'],
    'mft-2026:moduleC:qcm:9', true,
    'Formation de 105 h obligatoire en centre agréé, suivie de l''examen national (QCM + QR). À ne pas confondre avec le stage de remise à niveau de 35 h.');

  -- QCM 10 — Stage remise à niveau (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Un titulaire de l''attestation de capacité qui n''a pas dirigé d''entreprise de transport depuis plus de 5 ans doit suivre :',
    '[
      {"id":"a","label":"Une nouvelle formation complète de 105 h","is_correct":false},
      {"id":"b","label":"Un stage de remise à niveau de 35 h dans un centre agréé","is_correct":true},
      {"id":"c","label":"Un examen oral en préfecture","is_correct":false},
      {"id":"d","label":"Aucune formation, l''attestation reste valable à vie","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','capacite-professionnelle','remise-niveau'],
    'mft-2026:moduleC:qcm:10', true,
    'Article R. 3211-43 du Code des transports. Stage de 35 h obligatoire pour actualiser ses connaissances après une interruption supérieure à 5 ans.');

  -- QCM 11 — Délai notification changement (difficile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Tout changement modifiant la situation de l''entreprise au regard des conditions d''exercice doit être notifié au préfet de région dans un délai de :',
    '[
      {"id":"a","label":"7 jours","is_correct":false},
      {"id":"b","label":"15 jours","is_correct":false},
      {"id":"c","label":"28 jours","is_correct":true},
      {"id":"d","label":"60 jours","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-c','capa-3-5t','obligations','delais'],
    'mft-2026:moduleC:qcm:11', true,
    'Article R. 3411-14 du Code des transports : 28 jours pour notifier au préfet de région tout changement (siège, gestionnaire, capacité, etc.).');

  -- QCM 12 — Délai régularisation décès gestionnaire (difficile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En cas de décès ou d''incapacité physique du gestionnaire de transport, l''entreprise dispose pour se régulariser de :',
    '[
      {"id":"a","label":"3 mois","is_correct":false},
      {"id":"b","label":"6 mois","is_correct":false},
      {"id":"c","label":"9 mois","is_correct":true},
      {"id":"d","label":"12 mois","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-c','capa-3-5t','gestionnaire','delais'],
    'mft-2026:moduleC:qcm:12', true,
    '9 mois en cas de décès ou incapacité du gestionnaire (vs 6 mois pour perte d''honorabilité, capacité financière ou établissement).');

  -- QCM 13 — Licence durée (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quelle est la durée maximale de validité de la licence de transport intérieur ?',
    '[
      {"id":"a","label":"3 ans","is_correct":false},
      {"id":"b","label":"5 ans","is_correct":false},
      {"id":"c","label":"10 ans","is_correct":true},
      {"id":"d","label":"À vie","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','licence'],
    'mft-2026:moduleC:qcm:13', true,
    'La licence de transport intérieur est valable 10 ans maximum. Renouvellement à demander avant expiration.');

  -- QCM 14 — Document à bord (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel document doit obligatoirement se trouver à bord du véhicule de transport ?',
    '[
      {"id":"a","label":"L''original de la licence de transport intérieur","is_correct":false},
      {"id":"b","label":"Une copie certifiée conforme de la licence de transport intérieur","is_correct":true},
      {"id":"c","label":"L''attestation de capacité professionnelle du dirigeant","is_correct":false},
      {"id":"d","label":"Le KBIS de l''entreprise","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','licence','controle'],
    'mft-2026:moduleC:qcm:14', true,
    'L''ORIGINAL reste au siège. À bord du véhicule : la COPIE CERTIFIÉE CONFORME, délivrée par véhicule selon la capacité financière de l''entreprise.');

  -- QCM 15 — Caractéristiques contrat de transport (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le contrat de transport est qualifié de :',
    '[
      {"id":"a","label":"Solennel et bipartite","is_correct":false},
      {"id":"b","label":"Consensuel et tripartite, avec obligation de résultat","is_correct":true},
      {"id":"c","label":"Aléatoire et unilatéral","is_correct":false},
      {"id":"d","label":"Conditionnel et de moyens","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-c','capa-3-5t','contrat-transport'],
    'mft-2026:moduleC:qcm:15', true,
    'Consensuel (par échange des consentements), tripartite (expéditeur, transporteur, destinataire), à obligation de résultat (le transporteur est présumé responsable).');

  -- QCM 16 — Présomption de responsabilité (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En cas d''avarie de la marchandise transportée, qui doit prouver la cause de l''anomalie ?',
    '[
      {"id":"a","label":"Le donneur d''ordre doit prouver que l''avarie est due au transport","is_correct":false},
      {"id":"b","label":"Le transporteur, présumé responsable, doit prouver une cause d''exonération","is_correct":true},
      {"id":"c","label":"L''assureur seul doit instruire le dossier","is_correct":false},
      {"id":"d","label":"Aucune des parties, c''est le tribunal qui décide","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','contrat-transport','responsabilite'],
    'mft-2026:moduleC:qcm:16', true,
    'Article L. 133-1 Code de commerce : présomption de responsabilité du transporteur. C''est à lui de prouver une cause d''exonération (force majeure, vice propre, faute du contractant).');

  -- QCM 17 — Causes exonération (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Combien de causes d''exonération de responsabilité existe-t-il en cas de pertes ou avaries ?',
    '[
      {"id":"a","label":"1","is_correct":false},
      {"id":"b","label":"2","is_correct":false},
      {"id":"c","label":"3","is_correct":true},
      {"id":"d","label":"5","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','contrat-transport','exoneration'],
    'mft-2026:moduleC:qcm:17', true,
    '3 causes d''exonération : force majeure, vice propre de la chose, faute d''un tiers (expéditeur ou destinataire).');

  -- QCM 18 — Force majeure conditions (difficile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'La force majeure est caractérisée par 3 conditions cumulatives :',
    '[
      {"id":"a","label":"Imprévisibilité, irrésistibilité, extériorité","is_correct":true},
      {"id":"b","label":"Force, durée, intensité","is_correct":false},
      {"id":"c","label":"Faute, dommage, lien de causalité","is_correct":false},
      {"id":"d","label":"Météo, infrastructure, mécanique","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-c','capa-3-5t','contrat-transport','force-majeure'],
    'mft-2026:moduleC:qcm:18', true,
    'Force majeure (article 1218 Code civil) : événement imprévisible, irrésistible et extérieur. Toutefois, la jurisprudence n''exige plus systématiquement l''imprévisibilité si le transporteur prouve avoir pris toutes les précautions.');

  -- QCM 19 — Plafond pertes/avaries < 3t (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En contrat-type général, le plafond d''indemnisation pour un envoi de moins de 3 tonnes est de :',
    '[
      {"id":"a","label":"33 €/kg ou 1 000 €/colis (le plus petit des deux)","is_correct":true},
      {"id":"b","label":"20 €/kg ou 3 200 €/tonne","is_correct":false},
      {"id":"c","label":"100 €/kg sans limite","is_correct":false},
      {"id":"d","label":"La valeur déclarée à la facture","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','indemnisation','plafond'],
    'mft-2026:moduleC:qcm:19', true,
    'Contrat-type général < 3 t : 33 €/kg OU 1 000 €/colis perdu/avarié. On retient le PLUS PETIT des deux montants. Au-delà de 3 t : 20 €/kg ou 3 200 €/tonne.');

  -- QCM 20 — Plafond pertes/avaries ≥ 3t (difficile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Pour un envoi de 3 tonnes ou plus, le plafond d''indemnisation général est de :',
    '[
      {"id":"a","label":"33 €/kg ou 1 000 €/colis","is_correct":false},
      {"id":"b","label":"20 €/kg ou 3 200 €/tonne (le plus petit)","is_correct":true},
      {"id":"c","label":"50 €/kg sans condition","is_correct":false},
      {"id":"d","label":"Le prix de la marchandise neuve","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-c','capa-3-5t','indemnisation','plafond'],
    'mft-2026:moduleC:qcm:20', true,
    'Pour ≥ 3 t : 20 €/kg OU 3 200 €/tonne d''envoi. On retient toujours le plus petit. Pour le contrat-type "température dirigée", les plafonds sont différents (14 €/kg ou 4 000 €/tonne).');

  -- QCM 21 — Plafond retard (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En cas de retard du transporteur, le plafond d''indemnisation est égal :',
    '[
      {"id":"a","label":"À la valeur de la marchandise","is_correct":false},
      {"id":"b","label":"Au prix du transport","is_correct":true},
      {"id":"c","label":"Au double du prix du transport","is_correct":false},
      {"id":"d","label":"À 100 €/jour de retard","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','indemnisation','retard'],
    'mft-2026:moduleC:qcm:21', true,
    'Plafond retard = montant du prix du transport (pas la valeur de la marchandise). Pour aller au-delà : déclaration d''intérêt spécial à la livraison.');

  -- QCM 22 — Déclaration de valeur (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'La déclaration de valeur effectuée par le donneur d''ordre :',
    '[
      {"id":"a","label":"Est gratuite et automatique","is_correct":false},
      {"id":"b","label":"Substitue le montant déclaré au plafond pour pertes/avaries, contre paiement d''un prix convenu","is_correct":true},
      {"id":"c","label":"Permet de doubler le délai de transport","is_correct":false},
      {"id":"d","label":"Engage uniquement l''assurance personnelle du conducteur","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','declaration-valeur'],
    'mft-2026:moduleC:qcm:22', true,
    'Déclaration de valeur écrite, formulée au plus tard à la conclusion du contrat, contre paiement d''un prix convenu. Substitue le montant déclaré au plafond. Pour le retard, c''est la déclaration d''intérêt spécial à la livraison.');

  -- QCM 23 — Réserves PRO délai (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel est le délai pour qu''un destinataire PROFESSIONNEL confirme par lettre recommandée des réserves émises à la livraison ?',
    '[
      {"id":"a","label":"24 heures","is_correct":false},
      {"id":"b","label":"3 jours francs","is_correct":true},
      {"id":"c","label":"10 jours","is_correct":false},
      {"id":"d","label":"30 jours","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','reserves','livraison'],
    'mft-2026:moduleC:qcm:23', true,
    'Article L. 133-3 Code de commerce : 3 jours francs (hors jours fériés) pour confirmer par LRAR. Pour les particuliers : 10 jours (article L. 224-65 Code consommation).');

  -- QCM 24 — Indemnisation HT vs TTC (difficile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Une marchandise est volée pendant le transport (sans dépôt de plainte). Sur quelle base est-elle indemnisée ?',
    '[
      {"id":"a","label":"Sur le montant HT","is_correct":false},
      {"id":"b","label":"Sur le montant TTC","is_correct":true},
      {"id":"c","label":"Sur la valeur d''achat fournisseur","is_correct":false},
      {"id":"d","label":"Sur 50 % de la valeur facturée","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-c','capa-3-5t','indemnisation','vol'],
    'mft-2026:moduleC:qcm:24', true,
    'Marchandise PERDUE ou VOLÉE (sans plainte) → indemnisée sur le TTC. Marchandise AVARIÉE ou DÉTRUITE → indemnisée sur le HT.');

  -- QCM 25 — Privilège transporteur (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le "privilège du transporteur" lui permet de :',
    '[
      {"id":"a","label":"Refuser de respecter les délais en cas de retard du client","is_correct":false},
      {"id":"b","label":"Conserver la marchandise transportée comme gage de sa créance impayée","is_correct":true},
      {"id":"c","label":"Doubler le prix du transport en cas de litige","is_correct":false},
      {"id":"d","label":"Bénéficier d''une prime fiscale","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','privilege'],
    'mft-2026:moduleC:qcm:25', true,
    'Privilège légal du transporteur : il peut conserver la marchandise comme gage pour s''assurer du paiement (prix de transport, prestations annexes, frais).');

  -- QCM 26 — Document de cadrage (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le "document de cadrage" du contrat de transport peut être matérialisé par :',
    '[
      {"id":"a","label":"Un simple échange oral","is_correct":false},
      {"id":"b","label":"Un bon de commande ou devis accepté par le chargeur","is_correct":true},
      {"id":"c","label":"La carte grise du véhicule","is_correct":false},
      {"id":"d","label":"L''attestation d''assurance","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','contrat-transport','cadrage'],
    'mft-2026:moduleC:qcm:26', true,
    'Loi sécurité et modernisation des transports : le document de cadrage récapitule les informations essentielles. Un bon de commande ou devis signé/accepté en tient lieu.');

  -- QCM 27 — Port dû vs port payé (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    '"Port dû" signifie que les frais de transport sont :',
    '[
      {"id":"a","label":"À la charge de l''expéditeur","is_correct":false},
      {"id":"b","label":"À la charge du destinataire (payés à l''arrivée)","is_correct":true},
      {"id":"c","label":"Pris en charge par l''assurance","is_correct":false},
      {"id":"d","label":"Annulés gracieusement","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-c','capa-3-5t','contrat-transport','port'],
    'mft-2026:moduleC:qcm:27', true,
    'Port dû = paiement par le destinataire à l''arrivée. Port payé = paiement par l''expéditeur (le vendeur) au départ.');

  -- QCM 28 — Location vs transport critère (difficile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel critère distingue principalement le contrat de location avec chauffeur du contrat de transport ?',
    '[
      {"id":"a","label":"La couleur du véhicule","is_correct":false},
      {"id":"b","label":"La maîtrise des opérations de transport (locataire) vs de conduite (loueur)","is_correct":true},
      {"id":"c","label":"L''âge du conducteur","is_correct":false},
      {"id":"d","label":"Le nombre de passagers","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-c','capa-3-5t','location'],
    'mft-2026:moduleC:qcm:28', true,
    'Décret 21/06/2014 : le LOUEUR maîtrise les opérations de conduite (article 5), le LOCATAIRE maîtrise les opérations de transport (article 6). Ce critère détermine la qualification juridique.');

  -- QCM 29 — Feuille de location (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En matière de location de véhicule industriel, la "feuille de location" doit :',
    '[
      {"id":"a","label":"Être tenue exclusivement au siège du loueur","is_correct":false},
      {"id":"b","label":"Comporter au moins un exemplaire à bord du véhicule","is_correct":true},
      {"id":"c","label":"Être déposée à la DREAL chaque mois","is_correct":false},
      {"id":"d","label":"Être renouvelée chaque jour","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','location','feuille'],
    'mft-2026:moduleC:qcm:29', true,
    'La feuille de location (forme libre, papier ou électronique) doit comporter au minimum 1 exemplaire à bord du véhicule. La copie du contrat de location vaut feuille de location.');

  -- QCM 30 — Lettre voiture déménagement nb exemplaires (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En activité de déménagement, en combien d''exemplaires la lettre de voiture doit-elle être établie ?',
    '[
      {"id":"a","label":"2","is_correct":false},
      {"id":"b","label":"3","is_correct":false},
      {"id":"c","label":"4","is_correct":true},
      {"id":"d","label":"5","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','demenagement','lettre-voiture'],
    'mft-2026:moduleC:qcm:30', true,
    '4 exemplaires : (1) client, (2) entreprise, (3) à bord du véhicule, (4) équipe de manutention. Encadré par les articles L. 132-8 et suivants du Code de commerce.');

  -- QCM 31 — Action directe sous-traitant (difficile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Si vous sous-traitez un transport et ne payez pas votre sous-traitant, ce dernier peut :',
    '[
      {"id":"a","label":"Uniquement vous attaquer en justice","is_correct":false},
      {"id":"b","label":"Exercer une action directe contre votre client final (l''expéditeur)","is_correct":true},
      {"id":"c","label":"Saisir le tribunal des prud''hommes","is_correct":false},
      {"id":"d","label":"Refuser à jamais d''effectuer du transport","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-c','capa-3-5t','sous-traitance'],
    'mft-2026:moduleC:qcm:31', true,
    'Loi LOTI : action directe du sous-traitant impayé contre l''expéditeur final. Cette protection limite les abus dans la chaîne de transport, et engage indirectement votre client.');

  -- QCM 32 — Délai paiement sous-traitance (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel est le délai maximal de paiement entre transporteurs en sous-traitance routière ?',
    '[
      {"id":"a","label":"15 jours","is_correct":false},
      {"id":"b","label":"30 jours","is_correct":true},
      {"id":"c","label":"45 jours fin de mois","is_correct":false},
      {"id":"d","label":"60 jours","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','sous-traitance','delais'],
    'mft-2026:moduleC:qcm:32', true,
    'Article L. 441-11 Code de commerce : 30 jours maximum entre transporteurs (régime spécifique au transport, plus strict que le délai général de 60 j).');

  -- QCM 33 — Commissionnaire responsabilité (difficile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le commissionnaire de transport est responsable :',
    '[
      {"id":"a","label":"Uniquement de ses fautes personnelles","is_correct":false},
      {"id":"b","label":"De ses fautes propres ET des fautes des transporteurs qu''il a choisis","is_correct":true},
      {"id":"c","label":"Uniquement des fautes des conducteurs","is_correct":false},
      {"id":"d","label":"Aucunement, c''est un simple intermédiaire","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-c','capa-3-5t','commission'],
    'mft-2026:moduleC:qcm:33', true,
    'Le commissionnaire répond de ses fautes propres (mauvais choix d''un sous-traitant) ET des fautes des transporteurs sélectionnés (responsabilité du fait d''autrui). Régime plus lourd qu''un simple intermédiaire.');

  -- QCM 34 — Assurance RC obligatoire (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quelle assurance est OBLIGATOIRE pour tout véhicule motorisé en circulation ?',
    '[
      {"id":"a","label":"L''assurance perte d''exploitation","is_correct":false},
      {"id":"b","label":"L''assurance responsabilité civile véhicule (RC)","is_correct":true},
      {"id":"c","label":"L''assurance marchandises transportées","is_correct":false},
      {"id":"d","label":"L''assurance incendie des locaux","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-c','capa-3-5t','assurance'],
    'mft-2026:moduleC:qcm:34', true,
    'Article L. 211-1 Code des assurances : tout véhicule motorisé en circulation doit être couvert en RC (loi du 27 février 1958). Couvre les dommages causés aux tiers.');

  -- QCM 35 — Assurance marchandises souscripteur (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'L''assurance des marchandises transportées est généralement souscrite par :',
    '[
      {"id":"a","label":"Le transporteur lui-même","is_correct":false},
      {"id":"b","label":"Le donneur d''ordre (l''expéditeur)","is_correct":true},
      {"id":"c","label":"L''État","is_correct":false},
      {"id":"d","label":"L''assureur du véhicule","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-c','capa-3-5t','assurance','marchandises'],
    'mft-2026:moduleC:qcm:35', true,
    'L''assurance "ad valorem" est une faculté du donneur d''ordre, qui couvre les marchandises de magasin à magasin. Permet l''indemnisation même si le transporteur invoque une cause d''exonération.');

  -- =================================================================
  -- BANQUE QR — Module C (6 mises en situation)
  -- =================================================================

  -- QR 1 — Création d'entreprise et exigences
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Vous créez votre entreprise de coursier en SASU avec 2 véhicules ≤ 3,5 t en métropole. Vous envisagez d''ajouter un 3e véhicule dans 4 mois.

a. Quel montant minimum de capacité financière devez-vous justifier au démarrage ?
b. Quel sera le montant à atteindre quand vous passerez à 3 véhicules ?
c. Quelle proportion peut être couverte par garanties bancaires / assurance ?
d. Quelles sont les autres exigences à satisfaire pour vous inscrire au registre DREAL ?',
    NULL, 5, 'moyen',
    ARRAY['module-c','capa-3-5t','qr','capacite-financiere','cas-pratique'],
    'mft-2026:moduleC:qr:1', true,
    'Correction : a. 2 700 € (1 800 € + 900 €). b. 3 600 € (1 800 + 900 + 900). c. 50 % maximum, le reste en capitaux propres. d. (1) Établissement (locaux + équipements en France), (2) Capacité professionnelle (attestation transport routier léger), (3) Honorabilité (casier B2 vierge sur infractions visées par le Code des transports, du travail, etc.).');

  -- QR 2 — Présomption de responsabilité et exonération
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Votre véhicule est immobilisé 4 jours suite à une inondation exceptionnelle. La cargaison de denrées non périssables (2 tonnes de cartons en métal, valeur 8 000 €) arrive endommagée par l''humidité chez le destinataire.

a. Êtes-vous présumé responsable ? Pourquoi ?
b. Quelle cause d''exonération pouvez-vous invoquer ? Sous quelles conditions ?
c. Quel plafond d''indemnisation s''applique en l''absence d''exonération ?
d. Si l''indemnisation est due, calculez-la (l''envoi pèse 2 000 kg, 25 cartons de 80 kg).',
    NULL, 5, 'difficile',
    ARRAY['module-c','capa-3-5t','qr','responsabilite','exoneration','cas-pratique'],
    'mft-2026:moduleC:qr:2', true,
    'Correction : a. Oui (article L. 133-1 C. com.) : présomption de responsabilité du transporteur entre prise en charge et livraison. b. Force majeure (inondation exceptionnelle) si 3 conditions : irrésistibilité (vous ne pouvez l''empêcher), imprévisibilité, extériorité. À documenter par bulletins météo + arrêté de catastrophe naturelle. c. Plafond < 3 t = 33 €/kg ou 1 000 €/colis (le plus petit). d. Calcul kg : 2 000 × 33 = 66 000 € — Calcul colis : 25 × 1 000 = 25 000 €. Plafond retenu = 25 000 € (le plus petit). Indemnisation = min(préjudice 8 000 €, 25 000 €) = 8 000 € HT.');

  -- QR 3 — Litige réserves à la livraison
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Un client professionnel reçoit une livraison de matériel électronique le mardi à 14 h. Il signe la lettre de voiture sans réserve. Le mercredi à 10 h, il vous appelle pour vous signaler 3 colis cassés.

a. Le client peut-il encore engager votre responsabilité ? À quelles conditions ?
b. Quel délai et quel formalisme doit-il respecter ?
c. Que se passe-t-il s''il n''agit pas dans les délais ?
d. Si le client est un PARTICULIER, le délai change-t-il ? Pourquoi ?',
    NULL, 5, 'moyen',
    ARRAY['module-c','capa-3-5t','qr','reserves','livraison','cas-pratique'],
    'mft-2026:moduleC:qr:3', true,
    'Correction : a. Oui, en formulant des réserves a posteriori par lettre recommandée. b. Article L. 133-3 C. com. : 3 jours francs (hors fériés) à compter de la livraison, par LRAR avec réserves précises et motivées. Donc avant lundi minuit (jeudi+vendredi+lundi car samedi/dimanche non comptés ; à vérifier selon période). c. Forclusion : déchéance du droit de recours. La loi établit une fin de non-recevoir. d. Oui : 10 jours pour le particulier (article L. 224-65 Code de la consommation), sauf si le transporteur ne lui a pas laissé la possibilité effective de vérifier l''état du bien à la livraison.');

  -- QR 4 — Sous-traitance et chaîne contractuelle
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Vous êtes transporteur principal et confiez 30 % de votre activité à un sous-traitant local. Suite à une trésorerie tendue, vous accumulez 25 000 € d''impayés envers ce sous-traitant.

a. Quel délai de paiement maximal est imposé par la loi ?
b. Le sous-traitant peut-il agir directement contre vos clients finaux ? Quel cadre légal ?
c. Quelles conséquences pour votre relation commerciale et votre image ?
d. Comment éviter ce risque structurellement ?',
    NULL, 5, 'difficile',
    ARRAY['module-c','capa-3-5t','qr','sous-traitance','cas-pratique'],
    'mft-2026:moduleC:qr:4', true,
    'Correction : a. 30 jours maximum entre transporteurs (article L. 441-11 C. com.), régime plus strict que les 60 j classiques. b. OUI : action directe du sous-traitant impayé contre l''expéditeur final (loi LOTI). Le sous-traitant peut directement assigner votre client en paiement de ses prestations. c. Conséquences : perte de confiance des clients sollicités, dégradation réputation, surcoût juridique, risque de défection du sous-traitant, possibles intérêts moratoires. d. Sécuriser : (1) ligne de crédit court terme négociée avec la banque, (2) facturation rapide aux clients (à l''enlèvement ou à la livraison), (3) escompte ou affacturage, (4) acompte sur commandes longues, (5) clauses de paiement échelonné acceptables.');

  -- QR 5 — Choix entre location et transport (très examen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Un client industriel vous propose un partenariat : il met à disposition vos véhicules à plein temps pour ses besoins, vous fournissez le conducteur. Il décide des destinations, des chargements, des horaires. La facturation se fera au mois forfaitaire.

a. S''agit-il d''un contrat de transport ou de location ? Justifiez par 3 éléments.
b. Quelles sont les conséquences juridiques de cette qualification ?
c. Sur qui pèse la responsabilité des dommages aux marchandises ?
d. Quels documents devez-vous établir avant la mise à disposition ?',
    NULL, 5, 'difficile',
    ARRAY['module-c','capa-3-5t','qr','location','cas-pratique'],
    'mft-2026:moduleC:qr:5', true,
    'Correction : a. CONTRAT DE LOCATION AVEC CONDUCTEUR. Indices : (1) le client maîtrise les opérations de transport (destinations, chargements, horaires), (2) facturation au temps (forfait mois) et pas aux courses, (3) le conducteur devient le préposé occasionnel du locataire pour les opérations de transport. b. Régime juridique différent : le LOUEUR (vous) est responsable des opérations de conduite, le LOCATAIRE (le client) des opérations de transport. Pas de présomption de responsabilité au sens du transport. c. Le LOCATAIRE répond des dommages aux marchandises sauf s''il prouve un vice du véhicule, faute de conduite ou manquement du loueur. Vous (loueur) répondez des dommages aux tiers via votre RC véhicule. d. Feuille de location obligatoire avant mise à disposition (au moins 1 exemplaire à bord), avec les mentions du décret 21/06/2014 : date, immatriculation, dates début/fin, nom/adresse locataire, régime avec/sans conducteur, SIRET loueur.');

  -- QR 6 — Assurances et risque global
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Vous démarrez votre activité de transport avec 2 VUL ≤ 3,5 t. Votre courtier vous propose plusieurs assurances. Quelles sont les couvertures à souscrire ?

a. Quelles assurances sont LÉGALEMENT obligatoires ?
b. Quelles assurances sont fortement recommandées sans être obligatoires ?
c. Qui souscrit l''assurance des marchandises transportées et pourquoi ?
d. Que couvre l''assurance perte d''exploitation et pourquoi y souscrire ?',
    NULL, 5, 'moyen',
    ARRAY['module-c','capa-3-5t','qr','assurance','cas-pratique'],
    'mft-2026:moduleC:qr:6', true,
    'Correction : a. Obligatoires : assurance Responsabilité Civile véhicule (1 par véhicule motorisé, article L. 211-1 C. assurances). b. Recommandées : RC professionnelle (couvre les fautes hors transport), assurance locaux (incendie, vol, dégâts des eaux), perte d''exploitation, assurance de protection juridique, complémentaire santé/prévoyance dirigeant. c. Le DONNEUR D''ORDRE (l''expéditeur). Couvre la marchandise "de magasin à magasin", indemnisation même si le transporteur invoque une exonération. Le transporteur n''a pas à s''en charger. d. Couvre la baisse de chiffre d''affaires consécutive à un sinistre couvert (incendie, dégât des eaux, vol). Permet de continuer à payer les charges fixes (loyer, salaires, leasing) même quand l''exploitation est arrêtée. Indispensable pour une TPE.');

  -- =================================================================
  -- QUIZZES par leçon + examen blanc
  -- =================================================================

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Organisation de la profession — Quiz', 'Quiz d''entraînement sur les acteurs et l''organisation du transport routier.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleC:qcm:1','mft-2026:moduleC:qcm:2','mft-2026:moduleC:qcm:3');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Accès à la profession — Quiz', 'Quiz sur les 4 exigences, le gestionnaire de transport, les licences.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleC:qcm:4','mft-2026:moduleC:qcm:5','mft-2026:moduleC:qcm:6','mft-2026:moduleC:qcm:7',
      'mft-2026:moduleC:qcm:8','mft-2026:moduleC:qcm:9','mft-2026:moduleC:qcm:10','mft-2026:moduleC:qcm:11',
      'mft-2026:moduleC:qcm:12','mft-2026:moduleC:qcm:13','mft-2026:moduleC:qcm:14'
    );

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Contrat de transport — Quiz', 'Quiz sur le contrat de transport, sa formation, son exécution, la responsabilité.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleC:qcm:15','mft-2026:moduleC:qcm:16','mft-2026:moduleC:qcm:17','mft-2026:moduleC:qcm:18',
      'mft-2026:moduleC:qcm:19','mft-2026:moduleC:qcm:20','mft-2026:moduleC:qcm:21','mft-2026:moduleC:qcm:22',
      'mft-2026:moduleC:qcm:23','mft-2026:moduleC:qcm:24','mft-2026:moduleC:qcm:25','mft-2026:moduleC:qcm:26',
      'mft-2026:moduleC:qcm:27'
    );

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Contrats spéciaux et assurances — Quiz', 'Quiz sur la location, la sous-traitance, le commissionnaire, les assurances.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleC:qcm:28','mft-2026:moduleC:qcm:29','mft-2026:moduleC:qcm:30','mft-2026:moduleC:qcm:31',
      'mft-2026:moduleC:qcm:32','mft-2026:moduleC:qcm:33','mft-2026:moduleC:qcm:34','mft-2026:moduleC:qcm:35'
    );

  -- Examen blanc Module C — 13 QCM en 30 min (comme l'examen national, on n'inclut pas la QR ici, l'utilisateur peut faire les QR séparément)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — Module C', 'Examen blanc reproduisant les conditions du module C de l''examen national : 13 QCM en 30 min, seuil 50 %.', 'examen', 1800, 50)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleC:qcm:1','mft-2026:moduleC:qcm:4','mft-2026:moduleC:qcm:5','mft-2026:moduleC:qcm:8',
      'mft-2026:moduleC:qcm:11','mft-2026:moduleC:qcm:13','mft-2026:moduleC:qcm:15','mft-2026:moduleC:qcm:18',
      'mft-2026:moduleC:qcm:19','mft-2026:moduleC:qcm:23','mft-2026:moduleC:qcm:28','mft-2026:moduleC:qcm:31',
      'mft-2026:moduleC:qcm:34'
    );

  RAISE NOTICE '✅ Module C v2 chargé : 4 leçons, 35 QCM reformulés, 6 QR, 5 quizzes (4 entraînement + 1 examen blanc 13 QCM).';
END
$module_c_v2$;
