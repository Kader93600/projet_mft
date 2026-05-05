-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-01 : Traiter une demande de transport
-- Version 2 (mai 2026) — module pilote.
--
-- Bloc 01 (Concevoir, organiser et piloter des opérations de transport)
-- Module 1 sur 10 du BC01.
--
-- Objectifs pédagogiques :
--   - Comprendre l'écosystème du transport et le rôle de chaque acteur
--   - Qualifier une demande de transport (informations clés)
--   - Maîtriser le cadre juridique de la demande
--   - Traiter une demande incomplète (méthodologie MSP)
--
-- ▸ 4 leçons rédigées (180 min total)
-- ▸ 30 QCM reformulés (mft-2026-gotrm:bc01-01:qcm:N)
-- ▸ 6 QR transport (max_score 5)
-- ▸ Quizzes par leçon + 1 examen blanc module
--
-- Idempotent. Pré-requis : formation 'gotrm' présente.
-- =====================================================================

DO $bc01_01$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc dans la table blocs.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc01-01-demande-transport';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC01-01 — Traiter une demande de transport',
    'gotrm-bc01-01-demande-transport',
    v_bloc,
    'Comprendre l''écosystème du transport, identifier les acteurs, qualifier une demande client et traiter une demande incomplète. Le module fondateur de l''exploitant transport.',
    'debutant', 180, 10
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 10, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-01:%';

  -- =================================================================
  -- LEÇON 1 — L'écosystème du transport et les acteurs
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'L''écosystème du transport et les acteurs',
    'gotrm-bc01-01-01-ecosysteme-acteurs',
    1, 40,
$lesson1$
# L'écosystème du transport et les acteurs

Avant de **traiter** une demande de transport, il faut comprendre **qui parle à qui** dans la chaîne logistique. C'est la première compétence de l'exploitant : savoir identifier les rôles, les responsabilités et les enjeux de chacun.

> 🎯 **Objectifs de la leçon**
>
> - Identifier les **5 acteurs** du transport et leur rôle juridique.
> - Distinguer **commissionnaire**, **transporteur** et **affréteur**.
> - Comprendre les modes de relation : **vente directe**, **commission**, **sous-traitance**.
> - Situer le rôle du **gestionnaire d'exploitation** dans l'organisation.

---

## 1. Les 5 acteurs essentiels

| Acteur | Définition | Position dans la chaîne |
|---|---|---|
| **Expéditeur** (chargeur) | Celui qui confie la marchandise au transporteur | Origine du flux |
| **Destinataire** | Celui à qui la marchandise est livrée | Fin du flux |
| **Transporteur** | Celui qui exécute matériellement le transport | Intermédiaire opérationnel |
| **Commissionnaire** | Organise le transport en son nom propre pour un client | Intermédiaire commercial |
| **Donneur d'ordre** | Celui qui passe la commande de transport (souvent l'expéditeur, parfois un tiers) | Décideur de l'opération |

> 📌 **Important**
>
> L'expéditeur **n'est pas toujours** le donneur d'ordre. Exemple : une usine de meubles vend à un magasin. Le magasin (donneur d'ordre / acheteur) commande le transport, mais c'est l'usine qui charge la marchandise (expéditeur). Cette distinction est fondamentale en cas de litige.

---

## 2. Transporteur vs commissionnaire vs affréteur

C'est **LA** confusion classique du métier. Voici les différences essentielles :

| Critère | Transporteur | Commissionnaire | Affréteur |
|---|---|---|---|
| **Rôle** | Exécute le transport | Organise le transport | Cherche un transporteur pour le compte d'un client |
| **Qui possède le véhicule ?** | Lui-même | Pas forcément | Pas forcément |
| **Identité sur la lettre de voiture** | Nom du transporteur | Pas obligatoirement nommé | Pas nommé |
| **Régime juridique** | Code des transports + contrat type | Contrat de commission | Mandat |
| **Responsabilité** | Présomption (article L. 133-1 C. com.) | Responsable des fautes propres + des fautes des transporteurs choisis | Responsable de la prestation de mandat |
| **Exigences pour exercer** | Inscription au registre des transporteurs | Inscription au registre des commissionnaires + capacité de commission | Variable selon mandat |

> 🚛 **Cas pratique**
>
> Vous gérez les opérations chez **TRANSGO**, transporteur. Un client vous demande d'organiser une livraison à Berlin. Vous n'avez pas de licence internationale. Vous achetez le service à un confrère allemand. Vous êtes en train d'agir en **commissionnaire** : vous vendez à votre client une prestation que vous **organisez** mais que vous ne **réalisez pas vous-même**.

### 2.1 Le commissionnaire en détail

Le commissionnaire répond :
- De ses **fautes propres** (mauvais choix d'un sous-traitant)
- Des **fautes commises par les transporteurs qu'il a sélectionnés** (responsabilité du fait d'autrui)

Régime **plus lourd** qu'un simple intermédiaire. Il agit en **son nom propre** : c'est lui qui apparaît sur la facture client, et c'est lui qui paie le transporteur.

### 2.2 L'affréteur

L'**affréteur** est un mandataire : il agit **au nom et pour le compte** du client. Sa rémunération est généralement une commission. Pas obligé d'être inscrit au registre des transporteurs.

---

## 3. Les modes de relation

| Mode | Schéma | Risque commercial pour le client |
|---|---|---|
| **Vente directe** | Client ↔ Transporteur | Maîtrise totale, mais nécessite gestion individuelle |
| **Commission** | Client ↔ Commissionnaire ↔ Transporteur | Commissionnaire responsable, le client n'a qu'un seul interlocuteur |
| **Sous-traitance** | Client ↔ Transporteur principal ↔ Sous-traitant | Le transporteur principal reste responsable vis-à-vis du client |

> ⚠️ **Action directe (rappel important)**
>
> En cas de sous-traitance impayée, le sous-traitant peut **agir directement** contre l'expéditeur final pour obtenir paiement (loi LOTI). Cette protection limite les abus dans la chaîne.

---

## 4. Le gestionnaire d'exploitation : votre rôle

L'exploitant transport est au **carrefour** des informations. Il doit :

| Mission | Détail |
|---|---|
| **Recueillir** la demande | Comprendre le besoin, qualifier l'opération |
| **Qualifier** | Identifier les contraintes (ADR, température, délai…) et les risques |
| **Planifier** | Choisir le véhicule, le conducteur, les horaires |
| **Coter** | Calculer un prix viable (couvre les coûts + dégage une marge) |
| **Coordonner** | Suivre l'exécution, gérer les imprévus |
| **Assurer la qualité** | Mesurer la satisfaction, traiter les réclamations |
| **Rendre compte** | Tableaux de bord, KPI, reporting à la direction |

### 4.1 Compétences clés

- **Réglementation** (R561, AETR, ADR, contrat-type, droit social transport)
- **Géographie** logistique (axes, ZFE, restrictions)
- **Outils** : TMS (Transport Management System), Excel avancé, planning
- **Communication** client : écrite, téléphonique, gestion de crise
- **Calcul** : coût de revient, marge, ratios

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| 5 acteurs du transport | Expéditeur, destinataire, transporteur, commissionnaire, donneur d'ordre |
| Différence transporteur / commissionnaire | Transporteur EXÉCUTE, commissionnaire ORGANISE |
| Le commissionnaire répond de | Ses fautes propres + des fautes des transporteurs choisis |
| L'affréteur agit | Au nom et pour le compte du client (mandat) |
| Action directe du sous-traitant impayé | Contre l'expéditeur final (loi LOTI) |
| Mission centrale du gestionnaire d'exploitation | Recueillir, qualifier, planifier, coter, coordonner |
$lesson1$,
'5 acteurs (expéditeur, destinataire, transporteur, commissionnaire, donneur d''ordre), distinction transporteur/commissionnaire/affréteur, modes de relation et action directe loi LOTI.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Qualifier une demande de transport
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Qualifier une demande de transport',
    'gotrm-bc01-01-02-qualifier-demande',
    2, 50,
$lesson2$
# Qualifier une demande de transport

Une demande mal qualifiée, c'est une opération mal exécutée, un client mécontent, une marge perdue. La qualification est la **compétence socle** de l'exploitant transport.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser la **fiche de qualification** : 8 dimensions à couvrir.
> - Identifier les **pièges classiques** (informations cachées ou ambiguës).
> - Distinguer **besoin explicite** et **besoin implicite**.
> - Construire votre **questionnaire de prise de commande** standardisé.

---

## 1. Les 8 dimensions à qualifier

C'est la **méthode QQOQCCP** adaptée au transport. Aucune demande ne doit être traitée sans avoir balayé ces 8 dimensions.

| # | Dimension | Question type | Exemple |
|---|---|---|---|
| 1 | **Qui** | Qui sont les parties ? Expéditeur, destinataire, donneur d'ordre, contacts | Société, adresse, n° SIRET, contact opérationnel, contact comptable |
| 2 | **Quoi** | Quelle marchandise ? | Nature, poids, volume, conditionnement, valeur, dangerosité |
| 3 | **Où** | Origine et destination | Adresses précises, accessibilité, restrictions ZFE |
| 4 | **Quand** | Délais d'enlèvement et de livraison | Date / heure d'enlèvement, date / heure de livraison, plages horaires |
| 5 | **Comment** | Mode opératoire | Type de véhicule requis (frigo, plateau…), équipements (hayon, sangles…), manutention au chargement / déchargement |
| 6 | **Combien** | Volume, poids, quantité | Nb de palettes, m³, kg, dimensions |
| 7 | **Pourquoi** | Raison du transport, contexte | Vente, retour, transfert interne, inventaire — impacte les contraintes douanières |
| 8 | **Précautions** | Contraintes spécifiques | Température dirigée, fragilité, ADR, urgence, confidentialité, RDV obligatoire |

### 1.1 Fiche de qualification standardisée

Une bonne fiche de qualification se présente en **deux blocs** :

#### Bloc « Identité »

```
Donneur d'ordre  : ___________________________
Contact         : ___________________ (tél / email)
Référence       : ___________________________

Expéditeur      : ___________________________
Adresse         : ___________________________
Heures d'enlèvement : ___________________________
Contact terrain : ___________________________

Destinataire    : ___________________________
Adresse         : ___________________________
Heures de livraison : ___________________________
Contact terrain : ___________________________
```

#### Bloc « Marchandise et opération »

```
Nature de la marchandise   : ___________________________
Conditionnement            : __ palettes EUR / palettes perdues / cartons / vrac
Poids brut total           : __ kg
Volume / dimensions        : __ m³ / L × l × h
Température                : ambiante / +4 °C / surgelé / etc.
Matières dangereuses (ADR) : oui / non — si oui, n° UN, classe, quantité
Valeur déclarée            : __ € (ou non déclarée)
Mode de port               : payé / dû
Type de véhicule requis    : VUL / Porteur / Tracteur+remorque
Équipements particuliers   : hayon / frigo / sangles / chariot embarqué
Délai exigé                : J+1 / J+2 / RDV impératif / autre
Prix proposé / budget      : __ € HT (ou demande de cotation)
```

---

## 2. Les pièges classiques d'une demande client

> ⚠️ **Les 7 pièges à débusquer**

| # | Piège | Conséquence si ignoré |
|---|---|---|
| 1 | **Adresse imprécise** ("livraison Paris 15e") | Itinéraire, restrictions, RDV impossible à anticiper |
| 2 | **Pas de contact opérationnel** sur site | Conducteur perdu, retard, double déplacement |
| 3 | **Heures vagues** ("matinée") | Conflit de planning chez le destinataire |
| 4 | **Poids ou volume estimé "à vue"** | Surcharge, véhicule sous-dimensionné |
| 5 | **Conditionnement non précisé** (palette EUR ? perdue ? carton ?) | Hayon non prévu, manutention impossible |
| 6 | **Restrictions ZFE non mentionnées** | Véhicule refusé, retour à vide |
| 7 | **Manutention au chargement / déchargement** | Conducteur seul vs équipe — temps d'attente non couvert |

### 2.1 La règle d'or

> **Une information non écrite est une information perdue.**

Tout doit être consigné par écrit (mail, devis signé, fiche de prise de commande) avant d'engager l'opération. C'est la base juridique du contrat consensuel : si vous n'avez rien d'écrit et que ça part mal, vous ne pourrez rien prouver.

---

## 3. Besoin explicite vs besoin implicite

Le client ne dit pas tout. **Votre métier est de remonter aux besoins implicites.**

| Demande explicite du client | Besoin implicite à anticiper |
|---|---|
| « Livraison demain matin » | RDV pris avec destinataire ? Récépissé signé ? |
| « Palette à expédier » | Palette EUR consignée à récupérer ? |
| « Marchandise fragile » | Sangles spécifiques ? Mention sur la lettre de voiture ? |
| « Livraison à un particulier » | Hayon nécessaire ? Téléphone pour prise de RDV ? |
| « Prix le plus bas » | Mode de port ? Volume groupé ? Délai flexible ? |
| « Transport régulier » | Tarif annuel négocié vs spot ? Engagement volume ? |

> 💡 **L'écoute active**
>
> Reformulez systématiquement la demande au client : *« Si je comprends bien, vous souhaitez X palettes, enlevées tel jour entre telle heure et telle heure, livrées à telle adresse avec hayon. C'est exact ? »*. C'est la meilleure façon de détecter les ambiguïtés.

---

## 4. Le canal de la demande influe sur la qualification

| Canal | Avantage | Risque |
|---|---|---|
| **Téléphone** | Réactivité, dialogue | Pas de trace écrite, oubli |
| **E-mail** | Trace écrite | Souvent incomplet, ambigu |
| **Portail / EDI** | Standardisé, intégré au TMS | Rigide, perte du contexte |
| **Fax / courrier** | (Encore courant en industrie) | Lent, qualité d'image |
| **Visite commerciale** | Lien client fort | Engagement oral à formaliser |

> 📌 **Bonne pratique**
>
> Quel que soit le canal, **toute demande doit être transcrite dans le TMS** (Transport Management System) avec :
> 1. Une **référence unique** (n° de commande)
> 2. La **date / heure** de réception
> 3. Le **canal** d'origine
> 4. La **fiche de qualification** complète
>
> C'est le point de départ de la traçabilité.

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Méthode de qualification | **QQOQCCP** appliquée au transport (8 dimensions) |
| Bloc essentiel d'identité | Donneur d'ordre, expéditeur, destinataire, contacts |
| Bloc essentiel marchandise | Nature, poids, volume, conditionnement, valeur |
| Règle d'or | **Une information non écrite est perdue** |
| Outils d'enregistrement | TMS + référence unique + fiche qualifiée |
| Reformulation client | Indispensable — méthode de l'écoute active |
| Au moins 7 pièges classiques | Adresse imprécise, contacts, heures vagues, poids estimé, conditionnement, ZFE, manutention |
$lesson2$,
'8 dimensions de qualification (QQOQCCP transport), fiche de qualification, 7 pièges classiques, distinction besoin explicite / implicite, traçabilité TMS.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Le cadre juridique de la demande
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Le cadre juridique de la demande de transport',
    'gotrm-bc01-01-03-cadre-juridique',
    3, 40,
$lesson3$
# Le cadre juridique de la demande de transport

Une demande de transport, c'est une **proposition de contrat**. Sans un cadre juridique clair, vous prenez des risques qui se paient cher en cas de litige. Cette leçon couvre le minimum vital pour rester en conformité.

> 🎯 **Objectifs de la leçon**
>
> - Comprendre le caractère **consensuel** du contrat de transport.
> - Maîtriser le **document de cadrage** (loi sécurité et modernisation).
> - Distinguer **devis**, **bon de commande**, **lettre de voiture**.
> - Connaître le **contrat-type général** applicable à défaut.

---

## 1. Le contrat de transport : 3 caractéristiques à retenir

| Caractéristique | Conséquence |
|---|---|
| **Consensuel** | Se forme par le simple **échange des consentements** (article 1101 C. civ.). Aucune forme imposée. |
| **Tripartite** | 3 parties au minimum : **expéditeur**, **transporteur**, **destinataire**. |
| **Obligation de résultat** | Le transporteur est **présumé responsable** en cas d'anomalie (article L. 133-1 C. com.). |

> 📌 **« Consensuel » ne veut pas dire « informel »**
>
> Le contrat se forme à l'oral, mais en cas de litige, vous devrez **prouver** ce qui a été convenu. D'où l'importance absolue du document de cadrage écrit.

---

## 2. Le document de cadrage

> **Loi du 1er février 1995** (« sécurité et modernisation des transports ») : les informations relatives à la prestation doivent être récapitulées dans un **document de cadrage** établi par le donneur d'ordre.

### 2.1 Forme acceptable

| Forme | Acceptée ? |
|---|---|
| Bon de commande | ✅ Oui |
| Devis accepté | ✅ Oui |
| E-mail récapitulatif | ✅ Oui (si suffisamment précis) |
| Verbal seul | ❌ Non |

### 2.2 Contenu obligatoire du document de cadrage

| Catégorie | Détail |
|---|---|
| **Identité des parties** | Expéditeur, transporteur, destinataire, donneur d'ordre |
| **Marchandise** | Poids, volume, composition, emballage, nature, déclaration de valeur, contre-remboursement |
| **Lieu et conditions** | Date, heure, accessibilité, prescriptions de sécurité |
| **Durées prévues** | Attente au chargement / déchargement, prestations annexes |
| **Type de matériel** | Carrosserie, équipements particuliers |
| **Mode de port** | **Port dû** ou **port payé** |
| **Prestations annexes** | Manutention, contre-remboursement, etc. |
| **Délais** | Délai de parcours, attentes, conditions de rémunération |
| **Prix et conditions de paiement** | Exigible au plus 30 jours fin de décade |

> ⚠️ **Délai de paiement transport (article L. 441-11 C. com.)**
>
> Le délai de paiement entre transporteurs ne peut excéder **30 jours** à compter de la date d'émission de la facture. Toute clause contraire est réputée non écrite.

---

## 3. Devis vs bon de commande vs lettre de voiture

Trois documents bien distincts, souvent confondus.

| Document | Émis par | Quand | Rôle |
|---|---|---|---|
| **Devis** | Le transporteur | **Avant** acceptation | Propose un prix, valable un temps déterminé |
| **Bon de commande** | Le donneur d'ordre | **Après** acceptation | Acceptation du devis, déclenche la prestation |
| **Lettre de voiture** (CMR à l'international) | Le transporteur | **Au moment** de l'enlèvement | Trace l'exécution réelle, accompagne la marchandise |

### 3.1 Le devis : 5 mentions essentielles

| Mention | Pourquoi |
|---|---|
| **Identification précise** des parties | Capacité à contracter |
| **Description complète** de la prestation | Éviter les ambiguïtés sur les bornes |
| **Prix HT, TVA, TTC** détaillés | Conformité comptable et TVA |
| **Conditions générales** annexées (CGT) | Limitations, plafonds, force majeure |
| **Date de validité** du devis | Évite l'engagement perpétuel |

### 3.2 La lettre de voiture : 6 mentions obligatoires

| Mention | Article CMR / contrat type |
|---|---|
| Lieu et date de réalisation | Article 6 CMR |
| Désignation du tireur (expéditeur) | Article 6 CMR |
| Désignation du tiré (transporteur) | Article 6 CMR |
| Montant de la créance / prix | Article 6 CMR |
| Échéance du paiement | Article 6 CMR |
| Lieu de paiement | Article 6 CMR |

> 🚛 **CMR à l'international**
>
> Pour les transports internationaux entre 2 pays signataires (la majorité des pays UE + nombreux pays tiers), c'est la **CMR** (Convention de transport de marchandises par route, 1956) qui régit le contrat. La lettre de voiture CMR est obligatoire.

---

## 4. Le contrat-type général : la règle de fallback

> **Décret 99-269 du 6 avril 1999** (mis à jour) : à défaut de convention écrite particulière entre les parties, c'est le **contrat-type général** qui s'applique automatiquement.

### 4.1 Pourquoi c'est important

Si vous n'avez rien rédigé, vous ne pouvez **pas** dire « il n'y avait pas d'accord ». Le contrat-type **comble le silence des parties** sur :
- Les délais
- Les responsabilités
- Les plafonds d'indemnisation
- Les conditions de chargement et déchargement

### 4.2 Les contrats-types principaux

| Contrat-type | Domaine d'application |
|---|---|
| **Contrat-type général** | Tout transport de marchandises ≥ 3 t (à défaut de spécifique) |
| **Envois inférieurs à 3 tonnes** | Messagerie, petits colis |
| **Citerne** | Liquides en vrac |
| **Bois** | Grumes, sciés |
| **Animaux vivants** | Bétail, équidés |
| **Matières dangereuses** | TMD/ADR |
| **Température dirigée** | Frais, surgelé |
| **Location de véhicule industriel avec conducteur** | Locations |
| **Sous-traitance** | Relations transporteur principal / sous-traitant |
| **Commission de transport** | Relations commissionnaire / sous-traitants |
| **Déménagement** | Spécifique |

> 📌 **À retenir**
>
> Quand un client demande « un transport simple », c'est le **contrat-type général** qui s'applique. Vous bénéficiez de plafonds d'indemnisation (33 €/kg ou 1 000 €/colis pour < 3 t ; 20 €/kg ou 3 200 €/tonne pour ≥ 3 t) — sauf déclaration de valeur.

---

## 5. Les Incoterms (à connaître pour l'international)

> Les **Incoterms** définissent qui (vendeur / acheteur) paie le transport, l'assurance, les douanes, et qui supporte les risques.

### 5.1 Les 11 Incoterms 2020

| Code | Sens | Qui paie le transport principal ? |
|---|---|---|
| **EXW** | Ex Works | Acheteur (totalement) |
| **FCA** | Free Carrier | Acheteur |
| **CPT** | Carriage Paid To | Vendeur |
| **CIP** | Carriage and Insurance Paid To | Vendeur (+ assurance) |
| **DAP** | Delivered At Place | Vendeur |
| **DPU** | Delivered at Place Unloaded | Vendeur (+ déchargement) |
| **DDP** | Delivered Duty Paid | Vendeur (tout, douane comprise) |
| **FAS** | Free Alongside Ship | Acheteur (maritime uniquement) |
| **FOB** | Free On Board | Acheteur (maritime uniquement) |
| **CFR** | Cost and Freight | Vendeur (maritime uniquement) |
| **CIF** | Cost, Insurance and Freight | Vendeur (maritime uniquement) |

> 💡 **Pour le routier**
>
> Les Incoterms multimodaux (EXW, FCA, CPT, CIP, DAP, DPU, DDP) sont les seuls applicables au transport routier pur. Les 4 derniers (FAS, FOB, CFR, CIF) sont **réservés au maritime**.

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Caractère du contrat de transport | **Consensuel**, **tripartite**, à **obligation de résultat** |
| Document obligatoire selon loi sécurité et modernisation | **Document de cadrage** (bon de commande, devis accepté, e-mail récap) |
| Délai de paiement maximum entre transporteurs | **30 jours** (L. 441-11 C. com.) |
| Document accompagnant la marchandise | **Lettre de voiture** (CMR à l'international) |
| Règle de fallback en l'absence d'accord écrit | **Contrat-type général** (décret 99-269) |
| Plafond d'indemnisation général < 3 t | 33 €/kg ou 1 000 €/colis (le plus petit) |
| Plafond général ≥ 3 t | 20 €/kg ou 3 200 €/tonne |
| Incoterm où le vendeur paie tout y compris la douane | **DDP** |
| Incoterm où l'acheteur paie tout (départ usine) | **EXW** |
$lesson3$,
'Contrat consensuel + tripartite + obligation de résultat, document de cadrage obligatoire, délai 30 j L.441-11, contrat-type général en fallback, lettre de voiture / CMR, Incoterms 2020.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Méthodologie : traiter une demande incomplète
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Traiter une demande incomplète : la méthodologie',
    'gotrm-bc01-01-04-demande-incomplete',
    4, 50,
$lesson4$
# Traiter une demande incomplète : la méthodologie

C'est **LE** cas concret de l'épreuve d'examen MSP : un client envoie une demande mal formulée, et vous devez répondre **professionnellement** pour obtenir les informations manquantes sans paraître incompétent. Voici la méthode complète.

> 🎯 **Objectifs de la leçon**
>
> - Détecter rapidement les **informations manquantes**.
> - Hiérarchiser les questions par **priorité** (bloquant / important / secondaire).
> - Rédiger une **relance professionnelle** courtoise et efficace.
> - Construire la **cotation** une fois les informations recueillies.

---

## 1. La grille d'audit en 8 dimensions

Reprenez **systématiquement** la grille QQOQCCP (Leçon 2) et confrontez-la à la demande reçue.

| # | Dimension | Information attendue | Demande typique du client |
|---|---|---|---|
| 1 | Qui | Identités complètes | Souvent l'expéditeur seul est mentionné |
| 2 | Quoi | Nature, poids, volume, conditionnement | « Quelques palettes » → ambigü |
| 3 | Où | Adresses précises avec accès | « À Paris » → insuffisant |
| 4 | Quand | Dates et plages horaires | « Dès que possible » → flou |
| 5 | Comment | Type de véhicule, équipements | Rarement précisé spontanément |
| 6 | Combien | Volume, poids exact | Souvent estimé « à la louche » |
| 7 | Pourquoi | Contexte (vente / retour / transfert) | Souvent omis |
| 8 | Précautions | ADR, température, fragilité, RDV | Découvert au pire moment |

### 1.1 Le test de complétude

> **Une demande est complète SEULEMENT si les 8 dimensions sont renseignées.**
>
> Si une seule dimension est absente ou ambiguë, vous **ne pouvez pas** établir une cotation fiable.

---

## 2. Hiérarchiser les informations manquantes

Toutes les informations ne se valent pas. Voici la grille de priorité :

| Priorité | Type d'information | Effet si manquante |
|---|---|---|
| 🔴 **Bloquant** | Adresse, poids/volume, dates précises | Impossible d'évaluer faisabilité ou prix |
| 🟠 **Important** | Conditionnement, contacts terrain, manutention | Risque opérationnel élevé |
| 🟡 **Secondaire** | Valeur déclarée, contre-remboursement, RDV | Peut s'ajuster en cours d'opération |

### 2.1 Règle pratique

- Posez **toutes les questions bloquantes** dans **un seul mail**.
- Évitez de relancer plusieurs fois pour des questions oubliées.
- Soyez **bref et structuré** : le client n'a pas le temps.

---

## 3. La rédaction d'une relance professionnelle

### 3.1 Structure type de l'e-mail

```
Objet : [Réf demande] — Précisions complémentaires pour cotation

Bonjour [Prénom],

Merci de votre demande de transport reçue ce jour. Pour pouvoir vous
adresser une cotation précise et garantir la bonne exécution de
l'opération, j'aurais besoin des précisions suivantes :

1. [Question bloquante 1, formulée précisément]
2. [Question bloquante 2]
3. [Question bloquante 3]
[…]

Dès réception de ces éléments, je m'engage à vous transmettre une offre
sous [délai].

Restant à votre disposition pour tout complément.

Cordialement,

[Signature avec nom, fonction, n° tél, e-mail]
```

### 3.2 Les 5 règles de rédaction

| Règle | Détail |
|---|---|
| **Courtoise mais professionnelle** | Vouvoiement, ton neutre, pas d'excès de politesse |
| **Structurée** | Liste numérotée, jamais de longues phrases |
| **Précise** | « Adresse exacte avec code postal et accès véhicule » plutôt que « adresse » |
| **Engageante** | Indiquer un délai de retour de devis : « sous 24 h ouvrées après réception » |
| **Tracée** | Joindre une référence interne, archiver la copie dans le TMS |

### 3.3 Erreurs classiques à éviter

| ❌ À éviter | ✅ À faire |
|---|---|
| « Vous avez oublié de me dire… » | « Pour pouvoir vous coter avec précision, j'aurais besoin de… » |
| Mail trop long, copies à 5 personnes | Mail court, ciblé sur les questions bloquantes |
| « Pourriez-vous me dire si possible…» | Question fermée et précise : « Quel poids brut total ? » |
| Pas de signature professionnelle | Signature complète : nom, fonction, contacts |

---

## 4. Élaborer la cotation une fois les informations recueillies

Une fois les réponses obtenues, vous pouvez établir le devis. Voici le **mini-process** :

### 4.1 Vérifier la faisabilité

| Vérification | Question |
|---|---|
| Capacité du véhicule | Le PTAC est-il respecté ? Le volume tient-il ? |
| Disponibilité conducteur | Temps de conduite restant ? Repos respecté ? |
| Réglementation | ADR / TMD ? ATP ? ZFE ? |
| Distance et délai | Compatible avec le R561 ? |
| Coût de revient | Marge ≥ 20 % par défaut ? |

### 4.2 Calculer le prix

```
Prix HT = Coût de revient kilométrique × Distance
        + Coût horaire × Heures attente / manutention
        + Coût journalier × Jours d'immobilisation
        + Surcharges éventuelles (carburant, péages, ADR)
        + Marge commerciale

Prix TTC = Prix HT × (1 + TVA 20 %)
```

### 4.3 Mentionner sur le devis

| Mention | Détail |
|---|---|
| Réf. demande client | Permet de tracer |
| Détail de la prestation | Bornes A → B, poids, volume |
| Prix HT, TVA, TTC | Détaillé |
| Conditions de paiement | 30 jours fin de décade par défaut |
| **Validité du devis** | 15 ou 30 jours typiquement |
| **CGT annexées** (Conditions Générales de Transport) | Limitations, plafonds, force majeure, médiation |

> ⚠️ **À ne pas oublier**
>
> Sans **CGT annexées**, le contrat-type général s'applique de plein droit. Selon votre stratégie, c'est parfois plus avantageux pour vous. Mais alors, il faut le mentionner explicitement : « *À défaut de stipulation contraire, le contrat-type général s'applique* ».

---

## 5. Cas pratique : la demande de M. RAYNAUD (entreprise EUROPACK)

> 🚛 **Mise en situation**
>
> Vous travaillez chez **TRANSEXPRESS**, exploitant national. Vous recevez ce mail :
>
> *De : pierre.raynaud@europack-fr.com*
> *À : exploitation@transexpress.fr*
> *Objet : Demande de transport*
>
> *Bonjour,*
>
> *Je dois faire transporter rapidement nos cartonnages à un client. C'est urgent et il faut que ça soit fait avant la fin de la semaine prochaine. Le coût ne doit pas dépasser notre budget habituel.*
>
> *Merci de me confirmer.*
>
> *Pierre RAYNAUD — EUROPACK*

### 5.1 Audit de la demande

| Dimension | Renseigné ? |
|---|---|
| Qui (donneur d'ordre / expéditeur) | EUROPACK / Pierre RAYNAUD ✅ partiel |
| Qui (destinataire) | « un client » ❌ |
| Quoi | « cartonnages » 🟡 vague |
| Où (origine) | ❌ non précisé |
| Où (destination) | ❌ non précisée |
| Quand | « avant fin de semaine prochaine » 🟡 imprécis |
| Comment | ❌ aucun élément |
| Combien | ❌ aucun poids / volume |
| Précautions | ❌ aucune |
| Budget | « budget habituel » ❌ vague |

**Résultat** : 8 informations bloquantes manquantes. **Ne PAS établir de cotation**, sous peine de devoir renégocier ou perdre la marge.

### 5.2 Rédaction de la relance

```
Objet : Réf TR-2026-1287 — Précisions pour la cotation EUROPACK

Bonjour Pierre,

Merci de votre demande reçue ce jour. Pour pouvoir vous adresser une
cotation précise et garantir la bonne exécution de l'opération, j'aurais
besoin de quelques précisions :

1. Lieu d'enlèvement : adresse complète et plage horaire d'enlèvement
2. Lieu de livraison : adresse complète, contact terrain et plage horaire
3. Volume et poids : nombre de palettes ou cartons, dimensions, poids
   total brut
4. Conditionnement : palettes EUR consignées / palettes perdues / cartons
   en vrac
5. Date d'enlèvement souhaitée et date / heure de livraison impérative
6. Manutention : avez-vous un quai et un transpalette à l'enlèvement et à
   la livraison, ou un hayon est-il nécessaire ?
7. Mode de port : payé (par EUROPACK) ou dû (par le destinataire) ?

Dès réception de ces éléments, je m'engage à vous transmettre une offre
sous 24 h ouvrées.

Cordialement,

Sophie LEROUX
Exploitante Transport — TRANSEXPRESS
01 47 85 22 14 — sophie.leroux@transexpress.fr
```

### 5.3 Une fois les réponses obtenues

> *De : Pierre RAYNAUD*
>
> *Bonjour Sophie,*
>
> *Voici les précisions :*
>
> *1. Enlèvement à Aulnay-sous-Bois (93), 7 rue de l'Industrie, du lundi au vendredi de 8 h à 17 h.*
> *2. Livraison à Bordeaux (33000), rue des Quais, contact M. Lemaire 06 12 34 56 78.*
> *3. 12 palettes EUR, 1 200 kg total, 1 m × 1,2 m × 1,8 m chacune.*
> *4. Palettes EUR consignées (à récupérer après livraison).*
> *5. Enlèvement souhaité jeudi 25 mai matin, livraison impérative lundi 29 avant 11 h.*
> *6. Quai et transpalette aux deux extrémités. Pas de hayon.*
> *7. Port payé.*

Vous pouvez désormais établir le devis. Vérifiez :
- Faisabilité réglementaire (R561 : Aulnay → Bordeaux ≈ 600 km soit 7 h, faisable en J+1 + 1 jour de repos avant retour)
- Charge utile (1 200 kg + palettes ≈ 1 500 kg → VUL 3,5 t suffit)
- Volume (12 m³ environ → fourgon 20 m³ adapté)
- Coût de revient + marge → cotation ferme

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Test de complétude d'une demande | Les 8 dimensions QQOQCCP sont-elles renseignées ? |
| Priorité 1 | Adresse, poids/volume, dates précises |
| Méthode de relance | E-mail courtois + structuré + numéroté + signature pro |
| Erreur fatale | « Vous avez oublié… » → toujours dire « pour vous coter avec précision » |
| Engager un délai | « Devis sous 24-48 h ouvrées après réception » |
| Avant cotation, vérifier | Faisabilité (PTAC, R561, ADR, ZFE) + coût de revient + marge |
| Document à annexer au devis | **CGT** (Conditions Générales de Transport) |
$lesson4$,
'Audit en 8 dimensions, hiérarchie des manques (bloquant/important/secondaire), modèle de relance professionnelle, mini-process de cotation, cas pratique EUROPACK.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE QCM REFORMULÉS — Module BC01-01 (30 questions)
  -- =================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'Quels sont les 5 acteurs essentiels d''une opération de transport routier de marchandises ?', '[{"id":"a","label":"Producteur, distributeur, client, banquier, assureur","is_correct":false},{"id":"b","label":"Expéditeur, destinataire, transporteur, commissionnaire, donneur d''ordre","is_correct":true},{"id":"c","label":"Acheteur, vendeur, transporteur, douanier, comptable","is_correct":false},{"id":"d","label":"Voiturier, marin, livreur, dockerie, courtier","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['gotrm','bc01-01','acteurs'], 'mft-2026-gotrm:bc01-01:qcm:1', true, 'Les 5 acteurs essentiels sont : expéditeur (chargeur), destinataire, transporteur (voiturier), commissionnaire (organisateur), donneur d''ordre. À distinguer des rôles annexes (assureur, banquier, douanier).'),
  (v_formation, 'qcm', 'Quelle est la différence FONDAMENTALE entre un transporteur et un commissionnaire de transport ?', '[{"id":"a","label":"Le commissionnaire fait du transport international, le transporteur national","is_correct":false},{"id":"b","label":"Le transporteur exécute matériellement, le commissionnaire organise en son nom propre","is_correct":true},{"id":"c","label":"Le commissionnaire est moins responsable que le transporteur","is_correct":false},{"id":"d","label":"Aucune différence juridique","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','acteurs','commissionnaire'], 'mft-2026-gotrm:bc01-01:qcm:2', true, 'Le transporteur EXÉCUTE le transport. Le commissionnaire ORGANISE le transport en son nom propre pour le compte d''un client. Le commissionnaire est responsable de ses fautes propres + des fautes des transporteurs qu''il a sélectionnés.'),
  (v_formation, 'qcm', 'L''affréteur de transport agit :', '[{"id":"a","label":"En son nom propre","is_correct":false},{"id":"b","label":"Au nom et pour le compte du client (mandat)","is_correct":true},{"id":"c","label":"Au nom du transporteur","is_correct":false},{"id":"d","label":"En franchise sans contrat","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','affreteur'], 'mft-2026-gotrm:bc01-01:qcm:3', true, 'L''affréteur est un MANDATAIRE : il agit AU NOM ET POUR LE COMPTE de son client (mandat). À distinguer du commissionnaire qui agit en son nom propre. La rémunération est généralement une commission.'),
  (v_formation, 'qcm', 'Lorsqu''un commissionnaire choisit un sous-traitant qui commet une faute, le commissionnaire est :', '[{"id":"a","label":"Totalement exonéré","is_correct":false},{"id":"b","label":"Responsable du fait d''autrui en plus de ses fautes propres","is_correct":true},{"id":"c","label":"Responsable seulement si la faute est intentionnelle","is_correct":false},{"id":"d","label":"Responsable seulement si la faute concerne le prix","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-01','commissionnaire','responsabilite'], 'mft-2026-gotrm:bc01-01:qcm:4', true, 'Régime de responsabilité du commissionnaire : ses fautes propres (mauvais choix) + responsabilité du fait d''autrui (fautes des transporteurs choisis). Régime plus lourd qu''un simple intermédiaire.'),
  (v_formation, 'qcm', 'En cas de sous-traitance impayée par le donneur d''ordre intermédiaire, le sous-traitant peut :', '[{"id":"a","label":"Refuser de continuer ses prestations uniquement","is_correct":false},{"id":"b","label":"Exercer une action directe contre l''expéditeur final","is_correct":true},{"id":"c","label":"Saisir le tribunal des prud''hommes","is_correct":false},{"id":"d","label":"Aucun recours possible","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-01','sous-traitance','action-directe'], 'mft-2026-gotrm:bc01-01:qcm:5', true, 'La loi LOTI a instauré l''ACTION DIRECTE du sous-traitant impayé contre l''expéditeur final. Cette protection limite les abus dans la chaîne de transport et engage indirectement votre client.'),
  (v_formation, 'qcm', 'L''expéditeur d''une opération de transport est forcément le donneur d''ordre :', '[{"id":"a","label":"Vrai, c''est toujours le cas","is_correct":false},{"id":"b","label":"Faux, l''expéditeur peut être différent du donneur d''ordre","is_correct":true},{"id":"c","label":"Vrai, sauf en transport international","is_correct":false},{"id":"d","label":"Vrai, sauf pour le déménagement","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','acteurs','expediteur'], 'mft-2026-gotrm:bc01-01:qcm:6', true, 'Distinction fondamentale : l''EXPÉDITEUR est celui qui charge la marchandise, le DONNEUR D''ORDRE est celui qui passe la commande. Souvent les deux coïncident, mais pas toujours. Exemple : usine (expéditeur) qui livre à un magasin (acheteur = donneur d''ordre).'),
  (v_formation, 'qcm', 'Quelle méthode permet de qualifier complètement une demande de transport ?', '[{"id":"a","label":"L''analyse SWOT","is_correct":false},{"id":"b","label":"La méthode QQOQCCP appliquée au transport","is_correct":true},{"id":"c","label":"Le diagramme de Pareto","is_correct":false},{"id":"d","label":"L''analyse PESTEL","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','qualification','methodologie'], 'mft-2026-gotrm:bc01-01:qcm:7', true, 'QQOQCCP = Qui, Quoi, Où, Quand, Comment, Combien, Pourquoi, Précautions. Méthode classique de questionnement adaptée au transport en 8 dimensions. SWOT et PESTEL sont stratégiques (analyse externe), Pareto est statistique.'),
  (v_formation, 'qcm', 'Une demande de transport "complète" est définie par :', '[{"id":"a","label":"Le simple fait que le client ait téléphoné","is_correct":false},{"id":"b","label":"Le renseignement des 8 dimensions QQOQCCP transport","is_correct":true},{"id":"c","label":"Un mail signé électroniquement","is_correct":false},{"id":"d","label":"Un contrat-cadre signé","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','qualification'], 'mft-2026-gotrm:bc01-01:qcm:8', true, 'Une demande est COMPLÈTE quand les 8 dimensions sont renseignées : Qui (parties), Quoi (marchandise), Où (origine/destination), Quand (dates), Comment (mode opératoire), Combien (volume), Pourquoi (contexte), Précautions (contraintes).'),
  (v_formation, 'qcm', 'Quelle information est BLOQUANTE pour pouvoir établir une cotation ?', '[{"id":"a","label":"Le prénom du destinataire","is_correct":false},{"id":"b","label":"Le poids et le volume de la marchandise","is_correct":true},{"id":"c","label":"L''heure d''ouverture du destinataire (si flexible)","is_correct":false},{"id":"d","label":"La couleur de l''emballage","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['gotrm','bc01-01','qualification','bloquant'], 'mft-2026-gotrm:bc01-01:qcm:9', true, 'Le poids et le volume sont des informations BLOQUANTES : sans elles, impossible de choisir le véhicule, de calculer le coût, ni de vérifier le respect du PTAC. Les contraintes horaires et l''emballage sont importants mais ajustables.'),
  (v_formation, 'qcm', 'La RÈGLE D''OR de la qualification d''une demande de transport est :', '[{"id":"a","label":"Toujours faire confiance au client","is_correct":false},{"id":"b","label":"Une information non écrite est une information perdue","is_correct":true},{"id":"c","label":"Le téléphone vaut mieux que l''e-mail","is_correct":false},{"id":"d","label":"Le client a toujours raison","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['gotrm','bc01-01','tracabilite'], 'mft-2026-gotrm:bc01-01:qcm:10', true, 'Toute information doit être consignée par écrit (e-mail, devis signé, fiche TMS). Sans trace écrite, vous ne pouvez rien prouver en cas de litige. Le contrat de transport étant consensuel, la preuve écrite est essentielle.'),
  (v_formation, 'qcm', 'Le contrat de transport routier de marchandises est qualifié de :', '[{"id":"a","label":"Solennel et bipartite","is_correct":false},{"id":"b","label":"Consensuel, tripartite, à obligation de résultat","is_correct":true},{"id":"c","label":"Aléatoire et unilatéral","is_correct":false},{"id":"d","label":"De moyens","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','contrat','caracteristiques'], 'mft-2026-gotrm:bc01-01:qcm:11', true, '3 caractéristiques fondamentales : CONSENSUEL (formé par échange des consentements), TRIPARTITE (expéditeur, transporteur, destinataire), à OBLIGATION DE RÉSULTAT (présomption de responsabilité du transporteur, art. L. 133-1 C. com.).'),
  (v_formation, 'qcm', 'La loi de 1995 dite "sécurité et modernisation des transports" impose l''établissement :', '[{"id":"a","label":"D''un devis écrit obligatoire","is_correct":false},{"id":"b","label":"D''un document de cadrage récapitulant les informations de la prestation","is_correct":true},{"id":"c","label":"D''une lettre de change","is_correct":false},{"id":"d","label":"D''un certificat d''origine","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','document-cadrage'], 'mft-2026-gotrm:bc01-01:qcm:12', true, 'Loi du 1er février 1995 : document de cadrage obligatoire, établi par le donneur d''ordre, récapitulant les informations essentielles. Un bon de commande, un devis accepté ou un e-mail récap peut tenir lieu de document de cadrage.'),
  (v_formation, 'qcm', 'Quel est le délai de paiement maximum entre transporteurs en sous-traitance routière ?', '[{"id":"a","label":"15 jours","is_correct":false},{"id":"b","label":"30 jours","is_correct":true},{"id":"c","label":"45 jours fin de mois","is_correct":false},{"id":"d","label":"60 jours date de facture","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','delais','paiement'], 'mft-2026-gotrm:bc01-01:qcm:13', true, 'Article L. 441-11 Code de commerce : délai maximum 30 jours entre transporteurs (régime spécifique transport, plus strict que le délai général de 60 j). Toute clause contraire est réputée non écrite.'),
  (v_formation, 'qcm', 'Le devis émis par un transporteur doit obligatoirement comporter :', '[{"id":"a","label":"Le numéro de plaque du véhicule prévu","is_correct":false},{"id":"b","label":"Le prix HT, TVA, TTC, et la date de validité","is_correct":true},{"id":"c","label":"Le nom du conducteur","is_correct":false},{"id":"d","label":"L''itinéraire détaillé","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['gotrm','bc01-01','devis'], 'mft-2026-gotrm:bc01-01:qcm:14', true, 'Mentions essentielles d''un devis : identification précise des parties, description complète de la prestation, prix HT/TVA/TTC, conditions générales annexées, et DATE DE VALIDITÉ (sinon engagement perpétuel).'),
  (v_formation, 'qcm', 'À DÉFAUT de convention écrite particulière entre les parties, quel texte s''applique automatiquement ?', '[{"id":"a","label":"Le Code civil seul","is_correct":false},{"id":"b","label":"Le contrat-type général (décret 99-269 du 6 avril 1999)","is_correct":true},{"id":"c","label":"La CMR uniquement","is_correct":false},{"id":"d","label":"Les CGV du transporteur s''appliquent toujours","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-01','contrat-type'], 'mft-2026-gotrm:bc01-01:qcm:15', true, 'Décret 99-269 (mis à jour) : à défaut de convention écrite, le contrat-type général s''applique de plein droit. Il comble les silences sur les délais, responsabilités, plafonds, conditions de chargement / déchargement.'),
  (v_formation, 'qcm', 'Quel contrat-type s''applique au transport de marchandises sous température dirigée ?', '[{"id":"a","label":"Le contrat-type général","is_correct":false},{"id":"b","label":"Le contrat-type "température dirigée"","is_correct":true},{"id":"c","label":"Le contrat-type "matières dangereuses"","is_correct":false},{"id":"d","label":"Aucun contrat-type spécifique","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','contrat-type','temperature'], 'mft-2026-gotrm:bc01-01:qcm:16', true, 'Plusieurs contrats-types existent : général, < 3 t, citerne, bois, animaux vivants, matières dangereuses, TEMPÉRATURE DIRIGÉE, location, sous-traitance, commission, déménagement. Chacun adapte les règles selon la spécificité.'),
  (v_formation, 'qcm', 'Le plafond d''indemnisation général applicable à un envoi de moins de 3 tonnes est de :', '[{"id":"a","label":"33 €/kg ou 1 000 €/colis (le plus petit)","is_correct":true},{"id":"b","label":"20 €/kg ou 3 200 €/tonne","is_correct":false},{"id":"c","label":"100 €/kg sans limite","is_correct":false},{"id":"d","label":"La valeur facturée","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-01','indemnisation','plafond'], 'mft-2026-gotrm:bc01-01:qcm:17', true, 'Contrat-type général < 3 t : 33 €/kg OU 1 000 €/colis perdu/avarié, le PLUS PETIT des deux. Pour ≥ 3 t : 20 €/kg ou 3 200 €/tonne. Pour température dirigée, plafonds différents (14 €/kg ou 4 000 €/tonne).'),
  (v_formation, 'qcm', 'L''Incoterm DDP (Delivered Duty Paid) signifie :', '[{"id":"a","label":"Le vendeur livre à l''acheteur, douane à la charge de l''acheteur","is_correct":false},{"id":"b","label":"Le vendeur livre à l''acheteur, douane et toutes formalités à la charge du vendeur","is_correct":true},{"id":"c","label":"Le vendeur livre à un transporteur, l''acheteur prend en charge à partir du quai","is_correct":false},{"id":"d","label":"L''acheteur va chercher la marchandise à l''usine du vendeur","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-01','incoterms'], 'mft-2026-gotrm:bc01-01:qcm:18', true, 'DDP = "Delivered Duty Paid" = le vendeur prend TOUT en charge : transport, assurance, formalités douanières (import) jusqu''à la livraison à l''acheteur. C''est l''Incoterm le plus engageant pour le vendeur. Inverse : EXW (Ex Works) où l''acheteur prend tout en charge à partir de l''usine.'),
  (v_formation, 'qcm', 'L''Incoterm EXW (Ex Works) place la responsabilité du transport sur :', '[{"id":"a","label":"Le vendeur","is_correct":false},{"id":"b","label":"L''acheteur, dès le départ de l''usine du vendeur","is_correct":true},{"id":"c","label":"Le commissionnaire","is_correct":false},{"id":"d","label":"L''assureur","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','incoterms','exw'], 'mft-2026-gotrm:bc01-01:qcm:19', true, 'EXW = Ex Works : le vendeur met la marchandise à disposition à son usine. L''acheteur supporte TOUT à partir de là (transport, assurance, douanes). C''est l''Incoterm le plus favorable au vendeur, le plus engageant pour l''acheteur.'),
  (v_formation, 'qcm', 'Combien d''Incoterms 2020 sont utilisables pour un transport routier pur (multimodal) ?', '[{"id":"a","label":"4","is_correct":false},{"id":"b","label":"7","is_correct":true},{"id":"c","label":"11","is_correct":false},{"id":"d","label":"3","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-01','incoterms'], 'mft-2026-gotrm:bc01-01:qcm:20', true, '7 Incoterms multimodaux applicables au routier : EXW, FCA, CPT, CIP, DAP, DPU, DDP. Les 4 autres (FAS, FOB, CFR, CIF) sont RÉSERVÉS au maritime.'),
  (v_formation, 'qcm', 'Quelle est la différence entre "port dû" et "port payé" ?', '[{"id":"a","label":"Port dû = paiement à l''avance, port payé = à la livraison","is_correct":false},{"id":"b","label":"Port dû = à la charge du destinataire (paiement à l''arrivée), port payé = à la charge de l''expéditeur","is_correct":true},{"id":"c","label":"Port dû = international, port payé = national","is_correct":false},{"id":"d","label":"Aucune différence pratique","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','port'], 'mft-2026-gotrm:bc01-01:qcm:21', true, 'Port dû = paiement par le destinataire à l''arrivée. Port payé = paiement par l''expéditeur (le vendeur) au départ. Cette mention est obligatoire sur la lettre de voiture.'),
  (v_formation, 'qcm', 'Quel document accompagne obligatoirement la marchandise pendant le transport ?', '[{"id":"a","label":"Le devis","is_correct":false},{"id":"b","label":"La lettre de voiture (CMR à l''international)","is_correct":true},{"id":"c","label":"Le bon de commande","is_correct":false},{"id":"d","label":"Le contrat-cadre annuel","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['gotrm','bc01-01','lettre-voiture'], 'mft-2026-gotrm:bc01-01:qcm:22', true, 'La lettre de voiture (ou CMR à l''international) accompagne la marchandise. Elle trace l''exécution réelle du contrat de transport et sert de preuve en cas de litige.'),
  (v_formation, 'qcm', 'Au moment de traiter une demande incomplète, vous devez :', '[{"id":"a","label":"Établir un devis approximatif et l''ajuster ensuite","is_correct":false},{"id":"b","label":"Solliciter d''abord les informations bloquantes manquantes auprès du client","is_correct":true},{"id":"c","label":"Refuser la demande","is_correct":false},{"id":"d","label":"Demander à voir la marchandise sur place","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','demande-incomplete'], 'mft-2026-gotrm:bc01-01:qcm:23', true, 'Une cotation établie sur des données floues = engagement risqué. Toujours collecter les informations BLOQUANTES (adresse, poids, volume, dates) AVANT de chiffrer. Délai de retour annoncé : 24-48 h ouvrées.'),
  (v_formation, 'qcm', 'Une relance professionnelle pour informations manquantes doit ÉVITER :', '[{"id":"a","label":"D''utiliser une liste numérotée","is_correct":false},{"id":"b","label":"D''attribuer la responsabilité au client (\"vous avez oublié...\")","is_correct":true},{"id":"c","label":"De préciser un délai de retour de devis","is_correct":false},{"id":"d","label":"D''avoir une signature professionnelle complète","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','relance','communication'], 'mft-2026-gotrm:bc01-01:qcm:24', true, 'Bonne formulation : "Pour pouvoir vous coter avec précision, j''aurais besoin de..." (collaboratif). Mauvaise formulation : "Vous avez oublié de me dire..." (accusatoire). La relance doit être courtoise, structurée et engageante.'),
  (v_formation, 'qcm', 'Pour un transport routier intracommunautaire, quelle convention internationale s''applique ?', '[{"id":"a","label":"La convention de Bruxelles","is_correct":false},{"id":"b","label":"La CMR (Convention de transport de marchandises par route, 1956)","is_correct":true},{"id":"c","label":"La convention de Berne","is_correct":false},{"id":"d","label":"La convention IATA","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','cmr','international'], 'mft-2026-gotrm:bc01-01:qcm:25', true, 'CMR (Convention relative au contrat de transport international de marchandises par route, signée à Genève en 1956) régit les transports internationaux entre 2 pays signataires. La majorité des pays UE + nombreux pays tiers en sont signataires.'),
  (v_formation, 'qcm', 'L''écoute active dans la qualification d''une demande client consiste à :', '[{"id":"a","label":"Écouter sans interrompre uniquement","is_correct":false},{"id":"b","label":"Reformuler systématiquement la demande pour valider la compréhension","is_correct":true},{"id":"c","label":"Prendre des notes en silence","is_correct":false},{"id":"d","label":"Refuser tout questionnement","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['gotrm','bc01-01','communication','ecoute-active'], 'mft-2026-gotrm:bc01-01:qcm:26', true, 'Écoute active = REFORMULATION : "Si je comprends bien, vous souhaitez X palettes, enlevées le Y, livrées avec hayon...". Méthode efficace pour détecter les ambiguïtés et faire confirmer le client.'),
  (v_formation, 'qcm', 'Une "ZFE" (Zone à Faibles Émissions) impacte la qualification d''une demande car :', '[{"id":"a","label":"Elle restreint l''accès des véhicules selon leur Crit''Air","is_correct":true},{"id":"b","label":"Elle augmente les amendes routières","is_correct":false},{"id":"c","label":"Elle interdit toute livraison","is_correct":false},{"id":"d","label":"Elle ne concerne que les particuliers","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','zfe','reglementation'], 'mft-2026-gotrm:bc01-01:qcm:27', true, 'Les ZFE (Paris, Lyon, Grenoble, Marseille...) restreignent progressivement l''accès des véhicules les plus polluants. À qualifier dès la prise de commande pour éviter un véhicule refusé à l''entrée.'),
  (v_formation, 'qcm', 'L''outil informatique central pour tracer une demande de transport est :', '[{"id":"a","label":"Le tableur Excel uniquement","is_correct":false},{"id":"b","label":"Le TMS (Transport Management System)","is_correct":true},{"id":"c","label":"Le CRM commercial","is_correct":false},{"id":"d","label":"Le serveur de fichiers","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','tms','outils'], 'mft-2026-gotrm:bc01-01:qcm:28', true, 'Le TMS (Transport Management System) centralise les commandes, le planning, les véhicules, les tournées, la facturation. C''est l''ERP des exploitants transport. Toute demande doit y être tracée avec une référence unique.'),
  (v_formation, 'qcm', 'Une demande de transport mentionne "fragile" mais ne précise pas le conditionnement. Comment réagir ?', '[{"id":"a","label":"Prévoir un véhicule frigorifique","is_correct":false},{"id":"b","label":"Solliciter des précisions et envisager des sangles spécifiques","is_correct":true},{"id":"c","label":"Annuler la commande","is_correct":false},{"id":"d","label":"Augmenter le prix arbitrairement","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-01','qualification','besoin-implicite'], 'mft-2026-gotrm:bc01-01:qcm:29', true, '"Fragile" est un besoin EXPLICITE qui implique des besoins implicites : sangles spécifiques, mention sur la lettre de voiture, conduite adaptée, choix du véhicule. À toujours qualifier pour éviter les avaries.'),
  (v_formation, 'qcm', 'À l''issue de la phase de qualification, avant d''émettre la cotation, l''exploitant doit toujours vérifier :', '[{"id":"a","label":"L''activité de la concurrence","is_correct":false},{"id":"b","label":"La faisabilité (PTAC, R561, ADR, ZFE) et le coût de revient","is_correct":true},{"id":"c","label":"La couleur du véhicule","is_correct":false},{"id":"d","label":"Le prénom du conducteur","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-01','cotation','faisabilite'], 'mft-2026-gotrm:bc01-01:qcm:30', true, 'Avant cotation, vérifier la FAISABILITÉ : PTAC respecté, R561 (temps de conduite), ADR si applicable, ZFE, et calculer le coût de revient + marge. Une cotation "à l''aveugle" sans ces vérifs = engagement risqué.');

  -- =================================================================
  -- BANQUE QR — Module BC01-01 (6 mises en situation)
  -- =================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr',
    'Vous travaillez chez TRANSEXPRESS, exploitant transport. Vous recevez le mail suivant :

"Bonjour, je voudrais transporter du matériel à un de nos clients. C''est un peu urgent. Pouvez-vous me faire une offre ? Cordialement, Pierre RAYNAUD - Société EUROPACK"

a. Identifiez TOUTES les informations manquantes pour pouvoir établir une cotation.
b. Hiérarchisez ces informations par priorité (bloquant / important / secondaire).
c. Rédigez une relance professionnelle structurée à envoyer au client.
d. Quel délai de retour devez-vous vous engager à respecter ?',
    NULL, 5, 'moyen',
    ARRAY['gotrm','bc01-01','qr','demande-incomplete','cas-pratique'],
    'mft-2026-gotrm:bc01-01:qr:1', true,
    'Correction attendue : a. Manquent : identité destinataire, lieu d''enlèvement, lieu de livraison, dates, heures, nature précise de la marchandise (combien, poids, volume), conditionnement, contraintes (température, ADR), mode de port, budget, équipements requis. b. Bloquants : adresses, poids/volume, dates précises. Importants : conditionnement, contacts terrain, manutention, type de véhicule. Secondaires : valeur déclarée, contre-remboursement. c. Mail structuré : objet avec référence, salutation, demande des 7-8 questions bloquantes en liste numérotée, engagement de délai (24-48 h ouvrées), signature pro complète. d. 24 à 48 h ouvrées après réception des informations complètes.'),

  (v_formation, 'qr',
    'Un client industriel régulier (LOGISMETAL) vous envoie un mail rapide : "Demain 12 palettes EUR à livrer à Lyon, port payé."

a. Quelles sont les 5 informations bloquantes que vous DEVEZ confirmer avant d''accepter ?
b. Comment procéder concrètement (étapes) ?
c. Si le client refuse de répondre rapidement, que faire ?
d. Comment formaliser l''accord final ?',
    NULL, 5, 'moyen',
    ARRAY['gotrm','bc01-01','qr','client-regulier','cas-pratique'],
    'mft-2026-gotrm:bc01-01:qr:2', true,
    'Correction attendue : a. (1) Adresse exacte d''enlèvement avec horaires, (2) Adresse exacte de livraison + contact terrain, (3) Poids total et nature de la marchandise (palettes EUR consignées ou non), (4) Heures de livraison ou plage, (5) Manutention (hayon nécessaire ?). b. Étapes : (1) Réponse rapide (sous 30 min) confirmant la prise en compte, (2) Demande des 5 infos par mail/téléphone, (3) Au retour, vérification faisabilité (R561, PTAC, ZFE Lyon), (4) Cotation envoyée, (5) Acceptation par le client par mail = bon de commande, (6) Saisie dans TMS. c. Refuser de s''engager sans données complètes. Proposer un appel de 5 min pour les recueillir. Sinon, envoyer une cotation conditionnelle "sous réserve de confirmation des éléments manquants". d. Mail récapitulatif avec accord du client (= bon de commande), édition de la lettre de voiture la veille, planification dans TMS.'),

  (v_formation, 'qr',
    'Distinguez clairement, dans une situation B2B, le rôle :
a. De l''expéditeur
b. Du transporteur
c. Du commissionnaire
d. Du destinataire
Donnez pour chacun : sa fonction principale, sa responsabilité juridique, et un exemple concret.',
    NULL, 5, 'moyen',
    ARRAY['gotrm','bc01-01','qr','acteurs','distinction'],
    'mft-2026-gotrm:bc01-01:qr:3', true,
    'Correction attendue : a. EXPÉDITEUR (chargeur) : confie la marchandise, charge l''envoi (≥ 3 t), responsable de l''emballage et du conditionnement. Exemple : usine de pâtes qui charge un camion. b. TRANSPORTEUR (voiturier) : exécute le déplacement contre rémunération. Présomption de responsabilité L. 133-1 entre prise en charge et livraison. Exemple : votre flotte de VUL. c. COMMISSIONNAIRE : organise le transport en son nom propre pour un client. Responsable de ses fautes propres + des fautes des transporteurs choisis (responsabilité du fait d''autrui). Exemple : Bolloré Logistics, DSV qui ne possèdent pas tous les véhicules mais organisent des chaînes. d. DESTINATAIRE : reçoit la marchandise, vérifie son état, émet d''éventuelles réserves. Devient partie au contrat dès l''origine. Exemple : un magasin qui réceptionne une livraison.'),

  (v_formation, 'qr',
    'Un nouveau client demande "le prix le plus bas pour transporter régulièrement des palettes en France."

a. Identifiez 5 questions à poser pour qualifier précisément ce besoin.
b. Quel besoin EXPLICITE et quels besoins IMPLICITES devez-vous explorer ?
c. Quelles solutions pouvez-vous proposer (au moins 3) ?
d. Comment construire une offre adaptée à ce client ?',
    NULL, 5, 'difficile',
    ARRAY['gotrm','bc01-01','qr','besoin','offre','cas-pratique'],
    'mft-2026-gotrm:bc01-01:qr:4', true,
    'Correction attendue : a. (1) Volume mensuel ou annuel attendu (nb expéditions, nb palettes) ? (2) Origines / destinations (couloirs principaux) ? (3) Délais souhaités (J+1, J+2, J+3) ? (4) Type de palettes (EUR, perdues, palettisées vs vrac) ? (5) Engagement contractuel possible (1, 2, 3 ans) ? b. Explicite : "prix le plus bas". Implicites : fiabilité (à quel niveau de service ?), engagement de volume contre tarif, possibilité de groupage, optimisation des couloirs, mode de port, conditions de paiement. c. Solutions : (1) Tarif annuel négocié contre engagement de volume, (2) Groupage messagerie pour les petits envois, (3) Tournée régulière dédiée si volume suffisant, (4) Offre "premier prix" avec délai souple. d. Construire une offre à 2 niveaux : (1) tarif spot pour ponctuel, (2) tarif annuel négocié si engagement de X palettes/mois minimum. Documenter le contrat-cadre avec niveau de service défini, KPI suivis et révision annuelle.'),

  (v_formation, 'qr',
    'Un client français vous demande d''organiser une livraison à Madrid (Espagne). Vous n''avez pas de véhicule disponible.

a. Quel rôle juridique allez-vous prendre vis-à-vis du client : transporteur ou commissionnaire ?
b. Quelles sont les conséquences juridiques et opérationnelles pour vous ?
c. Comment sélectionnez-vous votre sous-traitant espagnol ou français ?
d. Quels documents devez-vous établir vis-à-vis du client ET du sous-traitant ?',
    NULL, 5, 'difficile',
    ARRAY['gotrm','bc01-01','qr','commission','international','cas-pratique'],
    'mft-2026-gotrm:bc01-01:qr:5', true,
    'Correction attendue : a. COMMISSIONNAIRE : vous organisez en votre nom propre, vous facturez le client, vous payez le sous-traitant. b. Conséquences : (1) Inscription au registre des commissionnaires nécessaire (capacité de commission), (2) Responsabilité du fait d''autrui (responsable des fautes du sous-traitant), (3) Régime fiscal différent (vous êtes "vendeur de service"), (4) Couverture par votre RC commission. c. Sélection : (1) Vérifier inscription au registre et licence communautaire, (2) Examiner sa responsabilité civile (mini 200 000 €), (3) Demander attestations sociales et fiscales, (4) Vérifier la non-faillite récente, (5) Signer un contrat de sous-traitance avec engagement de service. d. Documents : VIS-À-VIS DU CLIENT : devis + bon de commande + lettre de voiture CMR + facture. VIS-À-VIS DU SOUS-TRAITANT : contrat-type sous-traitance, ordre de mission, lettre de voiture CMR (au nom du sous-traitant), bon de livraison, attestation de sous-traitance.'),

  (v_formation, 'qr',
    'Vous gérez un grand compte (DISTRINORD) qui vous confie 30 % de votre chiffre d''affaires. Sa nouvelle responsable achats vous écrit : "Je veux un audit complet de votre service. Réponses sous 5 jours svp."

a. Comment recevez-vous cette demande (ton, posture) ?
b. Quels documents préparer pour démontrer votre professionnalisme ?
c. Quels indicateurs (KPI) pouvez-vous présenter ?
d. Cette situation présente-t-elle un risque ? Comment le réduire à terme ?',
    NULL, 5, 'difficile',
    ARRAY['gotrm','bc01-01','qr','grand-compte','cas-pratique','strategique'],
    'mft-2026-gotrm:bc01-01:qr:6', true,
    'Correction attendue : a. Recevoir POSITIVEMENT : c''est une opportunité de renforcer la relation, pas un examen. Ton coopératif, ne PAS se plaindre du délai. Confirmer la prise en compte sous 24 h, demander les axes d''audit prioritaires. b. Documents : (1) Liste des prestations réalisées sur les 12 derniers mois (volume, CA, ponctualité), (2) Tableau des incidents et résolutions, (3) Factures et conditions de paiement, (4) Rapport qualité avec KPI, (5) Procédures internes (TMS, contrôle qualité), (6) Attestations URSSAF, fiscales, RC, responsabilité commission. c. KPI : taux de ponctualité (cible 95 %+), taux de litige (cible < 1 %), délai moyen de traitement d''une réclamation, NPS, taux de prise de RDV à l''heure, nb d''avaries / mille envois, score de qualité environnementale (Crit''Air, éco-conduite). d. RISQUE : 30 % de CA = dépendance critique. Si DISTRINORD se désengage, perte massive. Stratégie : (1) Diversification commerciale active : prospection 5-10 nouveaux clients/an, (2) Clauses contractuelles : préavis de rupture de 6 mois min, engagement volume, (3) Suivi mensuel de la part de chaque client dans le CA, alerte à 25 %, (4) Investissement dans une marque forte indépendante de DISTRINORD.');

  -- =================================================================
  -- QUIZZES par leçon + examen blanc
  -- =================================================================

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Acteurs du transport — Quiz', 'Quiz d''entraînement sur les acteurs et l''écosystème du transport.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026-gotrm:bc01-01:qcm:1','mft-2026-gotrm:bc01-01:qcm:2','mft-2026-gotrm:bc01-01:qcm:3','mft-2026-gotrm:bc01-01:qcm:4','mft-2026-gotrm:bc01-01:qcm:5','mft-2026-gotrm:bc01-01:qcm:6');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Qualifier une demande — Quiz', 'Quiz d''entraînement sur la qualification des demandes.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026-gotrm:bc01-01:qcm:7','mft-2026-gotrm:bc01-01:qcm:8','mft-2026-gotrm:bc01-01:qcm:9','mft-2026-gotrm:bc01-01:qcm:10','mft-2026-gotrm:bc01-01:qcm:26','mft-2026-gotrm:bc01-01:qcm:27','mft-2026-gotrm:bc01-01:qcm:28','mft-2026-gotrm:bc01-01:qcm:29');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Cadre juridique de la demande — Quiz', 'Quiz sur le contrat consensuel, document de cadrage, contrat-type, Incoterms.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026-gotrm:bc01-01:qcm:11','mft-2026-gotrm:bc01-01:qcm:12','mft-2026-gotrm:bc01-01:qcm:13','mft-2026-gotrm:bc01-01:qcm:14','mft-2026-gotrm:bc01-01:qcm:15','mft-2026-gotrm:bc01-01:qcm:16','mft-2026-gotrm:bc01-01:qcm:17','mft-2026-gotrm:bc01-01:qcm:18','mft-2026-gotrm:bc01-01:qcm:19','mft-2026-gotrm:bc01-01:qcm:20','mft-2026-gotrm:bc01-01:qcm:21','mft-2026-gotrm:bc01-01:qcm:22','mft-2026-gotrm:bc01-01:qcm:25');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Traiter une demande incomplète — Quiz', 'Quiz sur la méthodologie de relance et de cotation.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026-gotrm:bc01-01:qcm:23','mft-2026-gotrm:bc01-01:qcm:24','mft-2026-gotrm:bc01-01:qcm:30');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — BC01-01', 'Examen blanc Module BC01-01 : 12 QCM en 25 min, seuil 50 %.', 'examen', 1500, 50)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026-gotrm:bc01-01:qcm:1','mft-2026-gotrm:bc01-01:qcm:2','mft-2026-gotrm:bc01-01:qcm:5','mft-2026-gotrm:bc01-01:qcm:7','mft-2026-gotrm:bc01-01:qcm:9','mft-2026-gotrm:bc01-01:qcm:11','mft-2026-gotrm:bc01-01:qcm:13','mft-2026-gotrm:bc01-01:qcm:15','mft-2026-gotrm:bc01-01:qcm:18','mft-2026-gotrm:bc01-01:qcm:22','mft-2026-gotrm:bc01-01:qcm:23','mft-2026-gotrm:bc01-01:qcm:30');

  RAISE NOTICE '✅ GOTRM BC01-01 v2 chargé : 4 leçons, 30 QCM, 6 QR, 5 quizzes (4 entraînement + 1 examen blanc).';
END
$bc01_01$;
