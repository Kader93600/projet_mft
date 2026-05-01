-- =====================================================================
-- MODULE B — ACTIVITÉ COMMERCIALE ET DÉMARCHE CLIENT (Capa -3,5T)
-- 5 leçons premium ~ 170 min de contenu pédagogique.
-- Idempotent.
-- =====================================================================

DO $mod_b$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation capacite-3-5t introuvable.'; END IF;

  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc défini.'; END IF;

  SELECT id INTO v_module FROM public.modules WHERE slug = 'capa-activite-commerciale' LIMIT 1;

  IF v_module IS NULL THEN
    INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
    VALUES (
      'Activité commerciale et démarche client',
      'capa-activite-commerciale',
      v_bloc,
      'Construire et développer son activité de transport : offre, prospection, gestion client, recouvrement. Outils concrets pour sécuriser votre chiffre d''affaires.',
      'intermediaire',
      170,
      20
    ) RETURNING id INTO v_module;

    INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
    VALUES (v_formation, v_module, 20, true)
    ON CONFLICT DO NOTHING;
  END IF;

  -- ─── LEÇON 1 : Construire son offre commerciale ──────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'construire-offre') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Construire son offre commerciale',
      'construire-offre',
      1,
      35,
$lesson1$
Une offre commerciale solide n'est pas une simple liste de prix. C'est l'**équilibre** entre ce que vous savez faire, ce que vos clients valorisent, et le prix que le marché peut absorber. Mal construite, votre offre vous mettra en concurrence frontale sur le prix uniquement — combat perdu d'avance contre des plateformes ou des géants.

:::objectifs
- Définir un **positionnement clair** sur votre marché.
- Construire des **devis et CGV** robustes juridiquement et commercialement.
- Appliquer une **méthode de tarification** logique (au km, au point, à l'heure).
:::

## Le positionnement avant tout

Avant de tarifier quoi que ce soit, posez-vous **3 questions fondamentales** :

1. **Pour qui** je travaille ? (Particuliers, TPE, grands comptes, e-commerçants…)
2. **Avec quoi** je me distingue ? (Rapidité, fiabilité, valeurs ajoutées, géographie…)
3. **Combien** coûte mon service ? (Coût de revient + marge cible)

:::memo
**Le piège de "je fais tout pour tout le monde"** : vous diluez votre offre, vos prix, votre image. Choisir, c'est éliminer — et c'est la clé d'une croissance durable.
:::

### 3 positionnements types pour un transporteur léger

| Positionnement | Cible | Prix | Volume |
|---|---|---|---|
| **Coursier urbain rapide** | Pharmacies, restaurants, e-commerce local | Élevé (15-30 €/course) | Fort, courses courtes |
| **Logistique B2B fiable** | Industries, distributeurs, grands comptes | Moyen (CRK + 15-25 %) | Régulier, planifié |
| **Spécialiste niche** | Pianos, valeurs, congelé, animaux | Premium (+50 % marché) | Faible, à forte valeur |

Choisissez **un** positionnement principal et orientez toute votre communication autour. Vous pourrez en ajouter un 2ème après 2 ans d'activité, jamais avant.

## Le devis : votre première impression

Le devis n'est pas un détail administratif. C'est **votre vitrine**. Un devis bâclé = un client qui doute de votre professionnalisme.

### Mentions obligatoires

- Nom et coordonnées du prestataire (raison sociale, SIRET, adresse).
- Nom et coordonnées du client.
- Description précise de la prestation.
- Prix unitaire HT, TVA, TTC.
- Date d'émission et **durée de validité** (souvent 30 jours).
- Conditions de règlement.
- Mentions légales (médiateur de la consommation pour les particuliers).

### Mentions recommandées (à fort impact commercial)

- **Délai de réalisation** précis.
- **Modalités de réservation** (anticipation requise, créneaux disponibles).
- **Conditions d'annulation** (frais éventuels).
- **Assurance** souscrite et son plafond (rassure pour la valeur).
- **Référence** unique pour le suivi (DEV-2025-001).

:::piege
**Sans mention de durée de validité**, votre devis vous engage **indéfiniment**. Un client peut vous opposer un prix de l'an dernier 8 mois plus tard. Toujours mentionner "valable 30 jours" sauf cas particulier.
:::

### Exemple de devis express vs détaillé

**Express (5 lignes)** :
- Course Paris → Roissy CDG, le 15/12, 14h.
- Véhicule fourgon ≤ 3,5 T.
- Prix : 65 € HT, 78 € TTC.
- Validité : 7 jours.
- Conditions : paiement à la livraison ou virement sous 30 jours.

**Détaillé (15+ lignes)** : pour B2B récurrent, contrats annuels, prestations complexes. Le client vous prend plus au sérieux.

## Les CGV : le bouclier juridique

Les **Conditions Générales de Vente** sont obligatoires en B2B (communication à toute demande d'un professionnel — Code de commerce L. 441-1). En B2C, elles doivent être présentées avant la conclusion du contrat.

### Les 8 clauses essentielles à inclure

1. **Champ d'application** : à qui s'appliquent-elles (B2B/B2C, type de prestation).
2. **Tarifs et modalités de paiement** : méthodes acceptées, délais.
3. **Délais de livraison** : engagement et exclusions (force majeure).
4. **Indemnisation perte/avarie** : référence au contrat type ou plafond négocié.
5. **Réclamations** : délai et modalité (LRAR, formulaire en ligne).
6. **Pénalités de retard** : taux applicable (souvent BCE + 10 points).
7. **Indemnité forfaitaire de recouvrement** : 40 € par facture.
8. **Loi applicable et juridiction compétente** : tribunal de commerce du siège.

:::caspratique
**Cas réel** : un transporteur sans CGV reçoit un client qui demande une remise rétroactive de 8 % sur 6 mois, sous menace de cesser. Sans CGV, le transporteur tombe sous le **contrat type général** : indemnisation plafonnée, pas de clause d'indexation gazole, etc.

**Avec des CGV bien rédigées** :
- Clause **de variation tarifaire** : "les prix peuvent être révisés selon l'indice CNR Gazole".
- Clause **de durée minimale** : "engagement de volume de 6 mois minimum".
- Clause de **résiliation** avec préavis et conditions.

Le transporteur peut s'opposer juridiquement à toute exigence rétroactive et négocier d'une position de force.
:::

## La tarification : 3 méthodes principales

### 1. Tarification au kilomètre

Calcul : (Coût de revient kilométrique × Distance) + Marge.

**Avantages** : transparente, équitable.
**Inconvénients** : ne valorise pas le temps perdu (attentes, manutention).

**Exemple** : CRK = 0,75 €/km. Course Paris-Lyon (470 km) = 470 × 0,75 = 352 € HT de coût. Avec marge 25 % : 440 € HT.

### 2. Tarification au point (forfait zonal)

Prix fixe pour une zone géographique définie (Paris intra-muros, banlieue 1ère couronne, etc.).

**Avantages** : simple pour le client, prévisible.
**Inconvénients** : marge variable selon trajet réel.

**Exemple** : forfait Paris intra-muros = 25 € par course (peu importe le trajet exact).

### 3. Tarification à l'heure

Prix horaire, démarrage à la prise en charge jusqu'à la libération.

**Avantages** : valorise le temps (manutentions, attentes).
**Inconvénients** : moins prévisible pour le client, exige confiance.

**Exemple** : 60 €/heure, démarrage minimum 1h. Idéal pour transports complexes (déménagements, manutentions).

:::conseil
**Combinez les 3 modes** selon le type de prestation. Beaucoup de transporteurs facturent au km pour le longue distance, au point pour l'urbain, à l'heure pour les missions complexes.
:::

## Le couple devis + CGV en pratique

Sur votre site web ou dans vos documents commerciaux, deux PDF distincts :

1. **Devis personnalisé** : adressé nominativement, signé par le client à l'acceptation.
2. **CGV** : un document standard joint à TOUS les devis. Reconnaissance par signature ou clic d'acceptation.

L'idéal : un **outil en ligne** (HelloAsso, Pennylane, etc.) qui :
- Génère le devis depuis un template.
- Joint automatiquement les CGV.
- Trace l'acceptation électronique (horodatage, IP).
- Convertit le devis accepté en facture en 1 clic.

:::memo
**À retenir** :
- Positionnement clair → tarification justifiable → croissance durable.
- Devis = 1ère impression : soigné, complet, daté.
- CGV = bouclier juridique en B2B : 8 clauses minimum.
- Tarification : combinez km / point / heure selon la prestation.
:::
$lesson1$,
$summary1$
**À retenir**

- Définir un positionnement clair (coursier urbain, logistique B2B, niche premium).
- Devis : 7 mentions obligatoires + 5 recommandées + durée de validité explicite.
- CGV obligatoires en B2B : 8 clauses essentielles.
- Tarification : km (longue distance) + point (urbain) + heure (complexe).
- Outils digitaux (Pennylane, etc.) : devis + CGV + facture en 1 flux.
$summary1$
    );
  END IF;

  -- ─── LEÇON 2 : Prospection et fidélisation ──────────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'prospection-fidelisation') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Prospection et fidélisation : trouver et garder ses clients',
      'prospection-fidelisation',
      2,
      35,
$lesson2$
La prospection est **la 1ère cause d'échec** des entreprises de transport en démarrage. On a souvent les compétences techniques mais pas la méthode commerciale. Cette leçon vous donne un cadre pour démarrer et développer votre portefeuille.

:::objectifs
- Cartographier votre **marché local**.
- Maîtriser **3 canaux de prospection** efficaces.
- Construire un **plan de fidélisation** simple et mesurable.
:::

## Cartographier son marché local

Avant de prospecter, **savoir qui prospecter** — sinon on disperse son énergie.

### L'exercice des "100 prospects qualifiés"

Listez **100 prospects** dans votre zone (rayon 30 min depuis votre base) :

- 30 commerçants/restaurants (livraisons régulières possibles).
- 20 e-commerçants locaux (pour livraison J+1 ou même jour).
- 20 TPE/PME industrielles (pour fournitures, échantillons).
- 15 cabinets professionnels (notaires, avocats, comptables — courrier, dossiers).
- 10 grands comptes accessibles (sous-traitance pour leurs transporteurs).
- 5 événementiels (concerts, mariages, conventions — transports ponctuels mais valorisés).

:::caspratique
**Sami à Lille** liste 100 prospects sur son territoire. Il identifie :
- 8 fleuristes qui livrent encore eux-mêmes le jour J.
- 12 e-commerçants Shopify locaux qui rament avec La Poste.
- 4 cabinets vétérinaires qui transportent du matériel chirurgical.
- 6 imprimeries qui livrent encore avec leurs propres voitures.

**Stratégie** : 4 angles précis avec un message ciblé pour chaque. Bien plus efficace qu'un message générique adressé à 1000 personnes.
:::

## 3 canaux de prospection efficaces

### 1. La porte-à-porte qualifiée

C'est **le canal n°1** des transporteurs locaux qui réussissent. Pourquoi ?

- Le contact humain crée de la confiance, surtout en B2B.
- Vous voyez l'activité réelle (plus utile qu'un site web).
- Vous laissez une carte / un flyer mémorable.

**Méthode :**
1. **Préparer** un mini pitch de 30 secondes.
2. **Visiter** 10 prospects par après-midi (2 demi-journées par semaine).
3. **Demander** systématiquement à parler à la personne en charge des envois.
4. **Laisser** un flyer + carte de visite, **noter** les retours.
5. **Relancer** par téléphone 1 semaine après.

Taux de conversion typique : **5-10 %**, soit 5-10 contrats sur 100 visites. Investissement temps : 4-6 semaines à plein temps pour saturer une zone.

### 2. LinkedIn local (B2B)

Pour les profils plus B2B (PME, e-commerce, cabinets) :

- Profil LinkedIn pro complet et travaillé.
- Connexion ciblée (responsable logistique, dirigeant, e-commerce manager).
- Message personnalisé (pas un copier-coller générique).
- Partage de **contenu utile** : "Top 3 des erreurs des e-commerçants en livraison".

**Indicateur** : viser **20 connexions qualifiées** par semaine + 1 conversation par jour.

### 3. Les recommandations

**Le canal le plus rentable** mais qui prend 6-12 mois à activer.

- Demander **systématiquement** à chaque client satisfait : "Connaissez-vous d'autres entreprises qui pourraient avoir ce besoin ?"
- Offrir un **avantage** (1 livraison gratuite, 5 % de remise) à toute recommandation aboutissant à un nouveau client.
- Encourager les **avis Google / Trustpilot** (impactent les nouveaux prospects qui vous découvrent).

:::memo
**Règle des 80/20 commerciale** : 80 % de votre CA viendra typiquement de 20 % de vos clients (les fidèles). C'est dans la **fidélisation** qu'on gagne, pas dans l'acquisition seule.
:::

## La fidélisation : 4 leviers concrets

### 1. La régularité

Un client qui sait qu'il peut compter sur vous chaque semaine ne va pas chercher ailleurs. Privilégiez les **abonnements** ou contrats récurrents :

- Tarif préférentiel pour engagement de volume (X courses/mois minimum).
- Créneau réservé hebdomadaire (mardi 14h-16h, par exemple).
- Facturation mensuelle simplifiée (1 facture vs 30).

### 2. La proactivité

Anticiper les besoins du client renforce la relation :

- "Je vois que vous avez beaucoup de commandes en fin de mois, voulez-vous un créneau dédié ?"
- "Pour Noël, on peut bloquer 3 véhicules dès maintenant."
- Un appel **trimestriel** de courtoisie sans rien à vendre.

### 3. La transparence en cas de problème

**Une livraison ratée bien gérée** vous renforce davantage qu'une livraison parfaite. La règle :

1. Prévenir le client AVANT qu'il s'en aperçoive.
2. Expliquer clairement ce qui s'est passé.
3. Proposer immédiatement une solution (re-livraison gratuite, remise sur la prochaine course).
4. Mettre en place un correctif pour éviter la récidive.

### 4. Le NPS — Net Promoter Score

Question simple à poser après chaque mission importante : "Sur une échelle de 0 à 10, recommanderiez-vous nos services à un confrère ?"

- **9-10 (Promoteurs)** : votre meilleur réseau. Encouragez-les à recommander.
- **7-8 (Passifs)** : risque de churn. Demandez ce qui manquerait pour atteindre 10.
- **0-6 (Détracteurs)** : alerte. Action correctrice immédiate.

NPS = % Promoteurs – % Détracteurs. Un NPS > 50 est excellent dans le transport.

:::piege
**L'erreur classique** : passer 90 % de son temps à chasser de nouveaux clients et 10 % à fidéliser les existants. Le bon ratio en croissance saine : **60 % fidélisation / 40 % acquisition** dès la 2ème année.
:::

## Le pipeline commercial en pratique

Tenez à jour un **fichier prospects/clients** simple (Excel suffit pour démarrer) :

| Statut | Définition | Action |
|---|---|---|
| Lead | Contact pris, intérêt indéfini | Appel suivi |
| Prospect qualifié | A confirmé un besoin | Devis sous 48h |
| Client actif | A passé ≥ 1 commande dans les 3 mois | Fidélisation |
| Client dormant | Inactif depuis > 3 mois | Relance commerciale |
| Client perdu | Inactif depuis > 12 mois | Enquête de feedback |

**Indicateurs hebdomadaires à suivre** :
- Nombre de leads contactés.
- Nombre de devis envoyés.
- Taux de transformation devis → client.
- CA récurrent (clients fidèles) vs nouveau.

:::conseil
Investissez **30 minutes par jour** dans la prospection et la fidélisation. Pas de chamboulement, juste de la régularité. C'est ce qui fait la différence entre un transporteur qui survit et un qui se développe.
:::
$lesson2$,
$summary2$
**À retenir**

- Cartographier 100 prospects qualifiés sur sa zone avant de prospecter.
- 3 canaux : porte-à-porte (B2B local), LinkedIn (PME / e-commerce), recommandations.
- Fidélisation : régularité + proactivité + transparence + NPS.
- 60 % fidélisation / 40 % acquisition dès la 2ème année.
- Pipeline commercial simple : leads → prospects → clients → dormants.
- 30 min/jour minimum sur la prospection et la fidélisation.
$summary2$
    );
  END IF;

  -- ─── LEÇON 3 : Gestion de la relation client ─────────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'gestion-relation-client') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Gestion de la relation client : contrats, litiges et sous-traitance',
      'gestion-relation-client',
      3,
      35,
$lesson3$
La relation client ne s'arrête pas à la signature du devis. Elle se construit au quotidien à travers les **contrats** que vous formalisez, les **litiges** que vous gérez, et les **partenaires** (sous-traitants) que vous engagez à vos côtés.

:::objectifs
- Maîtriser les **contrats commerciaux** structurants (annuels, ponctuels).
- Gérer professionnellement un **litige** sans casser la relation.
- Sécuriser une **relation de sous-traitance** (vous ou votre partenaire).
:::

## Les contrats structurants

### 1. Le contrat ponctuel (one-shot)

Pour une mission unique. Devis + CGV signés suffisent généralement.

**Quand l'utiliser** : transports occasionnels, événements, missions ponctuelles.

### 2. Le contrat annuel cadre

Pour un client récurrent. Engagement réciproque sur 12 mois.

**Clauses clés** :
- **Volume minimum** garanti (ex : 50 courses/mois).
- **Tarif unitaire** négocié + clause de variation (indice CNR Gazole).
- **Engagement de qualité** (taux de ponctualité, gestion des retours).
- **Pénalités** en cas de non-respect (par les 2 parties).
- **Conditions de résiliation** (préavis 3 mois minimum).

### 3. Le contrat-cadre groupage

Pour les e-commerçants ou industries qui mutualisent leurs envois.

- Tarif basé sur le volume mensuel cumulé.
- Lignes dédiées (ex : Paris-Lyon 3x/semaine).
- Reporting régulier de l'activité.

:::law code="Code de commerce" article="L. 441-3" date="01/01/2024"
Tout producteur, prestataire de services, grossiste ou importateur est tenu de communiquer à tout acheteur de produits ou tout demandeur de prestations de services pour une activité professionnelle qui en fait la demande ses conditions générales de vente.
:::

## La gestion des litiges

**Tous** les transporteurs vivent des litiges. Le **professionnalisme** se révèle dans la gestion, pas dans l'évitement.

### La règle d'or : ne jamais botter en touche

Un litige mal géré = perte du client + bouche-à-oreille négatif. Un litige **bien géré** = renforcement de la confiance.

### Les 5 étapes d'une gestion pro

1. **Accuser réception immédiatement** (sous 24h).
2. **Enquêter sérieusement** (chauffeur, lettre de voiture, photos, GPS).
3. **Reconnaître ou contester** clairement, avec preuves.
4. **Proposer une solution** : indemnité, geste commercial, re-livraison.
5. **Mettre en place un correctif** pour éviter la récidive.

:::caspratique
**Cas réel** : un client e-commerce vous accuse d'avoir perdu un colis valeur 850 €. Votre lettre de voiture indique 3 colis remis en bon état. Le bon de livraison signé "OK" sans réserve.

**Mauvaise réaction** : "Le bon est signé OK, je ne peux rien faire."
→ Conséquence : le client crée un litige public sur les avis, tweet négatif, perte d'autres clients.

**Bonne réaction** :
1. "Je suis désolé que vous fassiez face à ce problème. Pouvez-vous me confirmer la date et l'heure exacte de la livraison, et m'envoyer le bon signé ?"
2. Vous obtenez les éléments. Vous voyez que la signature est faite par un employé du destinataire qui n'a peut-être pas vérifié les colis.
3. "Effectivement, le bon est signé sans réserve, donc juridiquement ma responsabilité est limitée à 23 €/kg (276 € pour 12 kg). Mais je comprends votre situation. Je vous propose un geste commercial : 2 livraisons offertes sur vos 3 prochaines courses (~ 90 € de remise) et je passe en revue mes process pour éviter ça à l'avenir."

Le client repart satisfait. Vous avez préservé la relation **et** votre marge.
:::

### Les délais de réclamation

| Type | Délai légal | Point de départ |
|---|---|---|
| Réserves à la livraison | Avant signature ou 3 jours ouvrables après | Date de livraison |
| Réclamation perte/avarie | 3 jours ouvrables (si dommage non visible : 7) | Livraison |
| Action judiciaire transport | 1 an | Livraison ou date prévue |

:::piege
**Ne jamais répondre par email** à une réclamation ouverte. **Toujours téléphoner d'abord**. L'écrit transforme un échange en bras de fer juridique. La voix permet de désamorcer.
:::

## La sous-traitance : être donneur d'ordre

Quand vous sous-traitez (ex : besoin d'un véhicule complémentaire en cas de pic), vous **engagez votre responsabilité** vis-à-vis de votre client.

### L'obligation de vigilance

**Avant** chaque mission sous-traitée, vérifier que votre partenaire :

1. Est inscrit au **registre des transporteurs** (DREAL).
2. Possède une **licence valide** (intérieure ou communautaire).
3. Est à jour des **cotisations URSSAF** (attestation de vigilance, valable 6 mois).
4. A une **assurance RC professionnelle** active.
5. Respecte la **réglementation sociale** (paie minimum conventionnel).

:::law code="Code du travail" article="L. 8222-1" date="01/01/2024"
Toute personne qui s'assure les services d'une personne morale ou physique vérifie, lors de la conclusion du contrat puis tous les 6 mois jusqu'à la fin du contrat, qu'elle s'acquitte de ses obligations de déclaration et de paiement aux organismes de protection sociale et fiscaux.
:::

### La solidarité financière

Si vous **n'avez pas vérifié** et que votre sous-traitant fraude (URSSAF, salariés non déclarés), vous êtes **solidairement responsable** : l'administration peut vous demander de payer ses dettes.

Le coût d'une vérification : **5 minutes** sur l'attestation de vigilance URSSAF (en ligne, gratuit). Le coût d'une omission : potentiellement des **dizaines de milliers d'euros**.

### Le contrat de sous-traitance

Doit comporter :

- Description de la prestation déléguée.
- Tarification (souvent inférieure à votre tarif client : votre marge).
- Engagement de qualité (délais, fiabilité).
- Responsabilité en cas de problème (transfert vers le sous-traitant).
- Confidentialité (vos clients ne doivent pas être contactés directement).
- Durée et conditions de résiliation.

## Être sous-traitant : sécuriser votre rôle

Si vous êtes sous-traitant pour un autre transporteur, **inversez la perspective** :

- Demandez le **donneur d'ordre** par écrit (pas de mission orale).
- Vérifiez **vos** marges (si vous gagnez 70 % du tarif client, c'est correct).
- Sécurisez votre **paiement** (acompte, échéancier, retenue de garantie).
- Évitez la **dépendance** (max 30-40 % du CA chez 1 seul donneur d'ordre).

:::conseil
**Garder une porte de sortie** : la dépendance à un seul donneur d'ordre est mortifère. Si demain il vous laisse tomber ou abaisse les tarifs, vous êtes en danger immédiat. Diversifiez.
:::

## En synthèse

Une relation client de qualité repose sur :

1. **Des contrats clairs** dès le démarrage (annuel-cadre pour les récurrents).
2. **Une gestion professionnelle des litiges** (pas de fuite, pas d'agressivité).
3. **Une sous-traitance maîtrisée** (vigilance, contrats, diversification).

Ces 3 axes vous distinguent des transporteurs amateurs et vous positionnent comme **partenaire de confiance** — pas comme prestataire interchangeable.
$lesson3$,
$summary3$
**À retenir**

- 3 types de contrats : ponctuel, annuel-cadre, contrat groupage.
- Litige = test du professionnalisme : 5 étapes (accusé réception, enquête, position claire, solution, correctif).
- Téléphoner avant de répondre par écrit à une réclamation.
- Vigilance sous-traitance : DREAL, licence, attestation URSSAF, assurance.
- Sous-traitant : ne pas dépasser 30-40 % du CA chez un seul donneur d'ordre.
$summary3$
    );
  END IF;

  -- ─── LEÇON 4 : Recouvrement et impayés ─────────────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'recouvrement-impayes') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Recouvrement et impayés : protéger sa trésorerie',
      'recouvrement-impayes',
      4,
      35,
$lesson4$
**Une facture impayée, c'est zéro chiffre d'affaires.** Pire : c'est de la trésorerie que vous avez avancée (carburant, salaires, péages) et qui ne reviendra peut-être jamais. La gestion du recouvrement est une compétence vitale du transporteur indépendant.

:::objectifs
- Anticiper les impayés par une **politique de crédit client**.
- Maîtriser la **procédure amiable** (relance, mise en demeure, transaction).
- Connaître les **procédures judiciaires** (injonction de payer, assignation).
:::

## La prévention : le meilleur recouvrement

### Évaluer la solvabilité avant de travailler

Pour tout client B2B avec un encours > 1 000 €, **3 réflexes** :

1. **Vérification de l'existence** : recherche INSEE / Infogreffe (gratuit). Une société qui n'apparaît pas = signal d'alerte.
2. **Procédures collectives en cours** ? Consultation du **BODACC** (gratuit) — alertes redressement, liquidation.
3. **Notation financière** : sites comme societe.com (gratuits) ou Creditsafe (payant) donnent des notes de solvabilité.

:::caspratique
**Cas réel** : un nouveau client demande 5 000 € de transport sur 30 jours. Vous vérifiez sur Infogreffe : société créée il y a 3 mois, capital 100 €, dirigeant a déposé bilan d'une autre société il y a 2 ans.

**Action** : refuser le crédit. Proposer un acompte 50 % à la commande, solde à la livraison. Le client refuse ? Tant pis. Cette précaution évite probablement un impayé de 5 000 €.
:::

### La politique de crédit client

Définissez **vos règles** pour chaque profil de client :

| Profil | Encours max | Délai paiement | Garanties |
|---|---|---|---|
| Particulier | 0 € | À la livraison | CB ou virement immédiat |
| TPE moins de 1 an | 500 € | Échéance courte (15 jours) | Acompte ≥ 50 % |
| TPE/PME 1-3 ans | 2 000 € | 30 jours date facture | LCR ou prélèvement SEPA |
| PME établie | 5 000 € | 45 jours fin de mois | Convention écrite |
| Grand compte | Sur dossier | 60 jours date facture | Compte ouvert |

**Rigueur** : appliquer la même règle pour tous, sans dérogations affectives.

## La procédure amiable

C'est **80 % des recouvrements**. Bien faite, elle évite la procédure judiciaire.

### Étape 1 : la relance amiable (J+1 après échéance)

Email cordial le **lendemain** de l'échéance non honorée :

> Bonjour [prénom],
> Sauf erreur de ma part, la facture FA-2025-038 d'un montant de 1 850 € HT n'a pas encore été réglée à son échéance d'hier.
> Pouvez-vous m'indiquer la date de règlement prévue ?
> Cordialement,

**80 %** des retards trouvent ici une solution (oubli, erreur de saisie, etc.).

### Étape 2 : la 2ème relance (J+15)

Plus formelle, par téléphone si possible, suivie d'un email récapitulatif. Mentionner les pénalités de retard contractuelles.

### Étape 3 : la mise en demeure (J+30)

**Étape juridiquement importante**. Doit être envoyée par **lettre recommandée avec accusé de réception** (LRAR).

**Mentions obligatoires** :
- Référence de la facture impayée.
- Montant exact (principal + pénalités + indemnité forfaitaire 40 €).
- Délai de paiement accordé (généralement 8 à 15 jours).
- Mention "Mise en demeure" en titre.
- Avertissement : "À défaut de règlement, je serai contraint d'engager une procédure judiciaire."

:::law code="Code de commerce" article="L. 441-10" date="01/01/2024"
Lorsque la créance n'a pas été acquittée à son échéance, le débiteur est de plein droit redevable d'une indemnité forfaitaire pour frais de recouvrement de 40 € en sus des pénalités de retard.
:::

### Étape 4 : la transaction

Si le débiteur est en difficulté mais de bonne foi, **mieux vaut un mauvais accord qu'un bon procès**. Proposez :

- **Échéancier** sur 3 à 12 mois.
- **Remise** en contrepartie d'un paiement immédiat (ex : 90 % du dû en cash dans 7 jours).
- **Compensation** avec une prochaine commande.

Formaliser **par écrit** (protocole transactionnel) signé par les deux parties.

:::piege
**Erreur fréquente** : continuer à facturer un client en retard de paiement. Vous **augmentez votre exposition** sans aucune garantie. Stoppez les nouvelles missions tant que les anciennes ne sont pas réglées.
:::

## Les procédures judiciaires

Si l'amiable a échoué, plusieurs options selon le contexte.

### Injonction de payer (la voie royale)

**Procédure** simple, rapide, peu coûteuse pour les **créances certaines, liquides et exigibles**.

| Caractéristique | Détail |
|---|---|
| Coût | ~ 35 € (greffe) + ~ 100 € si signification par huissier |
| Délai | 1 à 3 mois |
| Avocat | Pas obligatoire |
| Tribunal | Commerce (B2B) ou judiciaire (B2C) |

**Étapes** :
1. Déposer une requête en injonction de payer au tribunal compétent.
2. Le juge délivre une ordonnance (sans audience).
3. L'huissier la **signifie** au débiteur.
4. Le débiteur a **1 mois** pour faire opposition. Sinon, l'ordonnance devient **exécutoire**.

### Assignation au fond

Si le débiteur conteste, ou si l'injonction de payer fait l'objet d'opposition, on bascule en **procédure au fond** :

- **Coût** plus élevé (avocat conseillé : 1 500-3 000 €).
- **Délai** plus long (6-18 mois).
- **Audience** au tribunal de commerce.

:::caspratique
**Pratique réelle** : un client refuse de payer une facture de 4 200 € prétextant un retard de livraison non prouvé.

1. **Mise en demeure LRAR** : ignorée.
2. **Injonction de payer** : 35 € au greffe + 90 € huissier.
3. **Délai 1 mois** : opposition du client (il prétend retard de livraison).
4. **Procédure au fond** : avocat 1 800 €, audience 4 mois plus tard.
5. **Jugement** : créancier gagne (preuves à l'appui). Le débiteur paye 4 200 € + 40 € indemnité + 1 800 € frais d'avocat + 350 € de dépens.

**Bilan** : 12 mois et 1 925 € avancés pour récupérer 4 200 €. Stressant et coûteux mais récupérable. Et SURTOUT préventif : un débiteur qui sait que vous engagez la procédure tend à payer la prochaine fois.
:::

## Les outils modernes

### L'affacturage

Vendre vos **créances clients** à une banque (factor) pour récupérer la trésorerie immédiatement (-3 à -7 %).

**Avantages** : vous êtes payé sous 48h, le factor gère le recouvrement.
**Inconvénients** : coût (3-7 % du montant), perception négative possible par le client.

### L'assurance-crédit

Couvre les impayés clients (Coface, Atradius, Euler Hermès).

**Avantages** : vous êtes indemnisé en cas d'impayé majeur.
**Inconvénients** : coût (0,1 à 0,5 % du CA).

### Le prélèvement SEPA

Pour les clients récurrents, **mettre en place un prélèvement automatique** mensuel.

**Avantages** : zéro action, zéro retard.
**Inconvénients** : nécessite mandat signé du client, un peu de complexité technique.

## En synthèse

| Étape | Action | Délai |
|---|---|---|
| Avant facturation | Vérification solvabilité | Continue |
| Échéance + 1 j | Relance email amiable | Continue |
| Échéance + 15 j | Relance téléphone + email | Continue |
| Échéance + 30 j | **Mise en demeure LRAR** | 8-15 j |
| Échéance + 60 j | **Injonction de payer** | 1-3 mois |
| Échéance + 12 mois | Procédure au fond si opposition | 6-18 mois |

:::conseil
**Comptabilisez chaque action** dans votre logiciel ou un tableau Excel. Un dossier impayé bien tenu (preuves, dates, échanges) augmente vos chances de gagner judiciairement de **70 %**.
:::
$lesson4$,
$summary4$
**À retenir**

- Prévention par vérification de solvabilité (Infogreffe, BODACC) + politique de crédit.
- Procédure amiable : 4 étapes (relance, 2ème relance, mise en demeure LRAR, transaction).
- Injonction de payer : ~35 € + huissier, 1-3 mois, sans avocat. Voie royale.
- Mise en demeure LRAR : étape obligatoire avant action judiciaire.
- Outils modernes : affacturage (-3 à -7 %), assurance-crédit, SEPA.
- Documenter tout (preuves, dates) augmente de 70 % les chances de gagner judiciairement.
$summary4$
    );
  END IF;

  -- ─── LEÇON 5 : Cas pratiques de synthèse ───────────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'cas-pratiques-commercial') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Cas pratiques de synthèse — Activité commerciale',
      'cas-pratiques-commercial',
      5,
      30,
$lesson5$
4 cas pratiques inspirés du quotidien d'un transporteur léger. Ils mobilisent l'ensemble du module : positionnement, devis, contrats, recouvrement.

## Cas n° 1 — Le grand compte qui exige des prix bas

**Situation** : un grand groupe e-commerce vous propose 200 livraisons/mois à condition que votre prix unitaire baisse de 20 % vs vos tarifs habituels. Volume = potentiellement 30 % de votre CA.

**Question** : acceptez-vous ?

:::caspratique
**Analyse** :
1. **Calcul de marge** : si votre marge actuelle est 25 %, baisser de 20 % le prix réduit votre marge à environ 5 %. Tout aléa (panne, retour à vide, augmentation gazole) vous met en perte.
2. **Risque de dépendance** : 30 % du CA chez 1 client = très dangereux. Si demain ils baissent encore ou changent de prestataire : vous mourez.
3. **Effet d'éviction** : vos autres clients (PME locales) peuvent être délaissés ; vous perdez ce qui était votre vraie force.

**Solution** :
- **Refuser** le -20 % ferme.
- **Contre-proposer** : -10 % avec engagement minimum 24 mois + clause d'exclusivité partielle (ils ne donnent pas à un concurrent direct sur leur zone).
- **Plafonner** la dépendance : pas plus de 30 % du CA chez ce client.

**Si refus** : négocier minimum -10 % avec engagement, ou laisser passer. Votre marge passée 5 % vous condamne plus que la perte du contrat.
:::

## Cas n° 2 — Le client fidèle qui devient mauvais payeur

**Situation** : votre client depuis 3 ans (5 % du CA, paiement régulier) commence à payer à 75 jours au lieu de 30. La 4ème facture impayée arrive ; il prétexte des "difficultés temporaires".

**Question** : que faites-vous ?

:::caspratique
**Analyse** :
1. **Diagnostic financier** : vérifier sur Infogreffe + BODACC. S'il est en procédure ou notation dégradée, **stopper immédiatement** les nouvelles missions.
2. **Bonne foi vs mauvaise foi** : un client qui prévient et propose un échéancier = bonne foi. Un client qui esquive = mauvaise foi.
3. **Encours** : 4 factures à 1 500 € = 6 000 € exposés. Limiter immédiatement.

**Solution** :
- **Téléphone** : "J'ai bien compris que tu traverses une période difficile. Mais 4 factures impayées, je ne peux pas continuer comme ça. Je propose qu'on signe un protocole d'échéancier sur 6 mois pour les arriérés. Et pour les nouvelles missions, on bascule en paiement comptant ou avec acompte 50 %."
- **Si refus** : suspendre toute nouvelle mission, mise en demeure pour les anciennes.
- **Si OK** : signer un **protocole transactionnel** (pas un simple email).

**Erreur à éviter** : continuer à facturer "par fidélité". L'amitié ne paie pas les charges.
:::

## Cas n° 3 — Le devis verbal qui se retourne

**Situation** : vous avez fait, par téléphone, un devis verbal à 320 € pour un transport. Le client a accepté oralement. À la livraison, il refuse de payer plus de 250 €, prétextant un autre tarif convenu.

**Question** : votre position juridique et commerciale ?

:::caspratique
**Analyse** :
1. **Juridique** : un contrat verbal est valide juridiquement (Code civil art. 1101) MAIS la **preuve** est très difficile à apporter sans écrit. Sans email, SMS ou témoin, c'est votre parole contre la sienne.
2. **Tarif** : sans accord écrit, le **contrat type général** s'applique : prix selon "marché habituel" — donc plus proche de 320 € que de 250 €, mais difficile à imposer judiciairement pour 70 € de différence.
3. **Coût récupération** : injonction de payer ~ 135 €. Économiquement rationnel ? Limite.

**Solution** :
- **Court terme** : encaisser les 250 € (mieux que rien) et faire signer un bon de livraison mentionnant "Litige sur le solde de 70 €, paiement partiel sans renonciation à l'action ultérieure."
- **Court terme bis** : **mise en demeure** pour les 70 €. Souvent ça paie.
- **Long terme** : **plus jamais de devis verbal**. Tout par email/SMS, devis signé pour les missions > 100 €.

**Leçon** : un devis verbal coûte typiquement 100 à 500 € à chaque incident. Sur 50 missions/an, c'est 5 000 € à 25 000 € perdus. Les devis écrits prennent 5 minutes : économie majeure.
:::

## Cas n° 4 — La sous-traitance non vérifiée

**Situation** : vous avez sous-traité des courses urgentes à un autre transporteur (recommandé par un confrère). 6 mois plus tard, l'URSSAF vous notifie une dette de 12 000 € : votre sous-traitant n'a pas déclaré ses salariés.

**Question** : êtes-vous responsable ? Que faire ?

:::caspratique
**Analyse** :
1. **Solidarité financière** (Code travail L. 8222-1) : oui, vous êtes solidairement responsable des dettes URSSAF de votre sous-traitant si vous n'avez pas vérifié son **attestation de vigilance**.
2. **Démontrer la vigilance** : si vous avez la copie de l'attestation valide à la date du contrat, vous êtes exonéré. Si non : payer.
3. **Action récursoire** : vous pouvez ensuite poursuivre votre sous-traitant pour les 12 000 € — mais souvent insolvable.

**Solution** :
- **Court terme** : payer les 12 000 € à l'URSSAF (sinon majorations + saisies).
- **Récursoire** : assignation contre le sous-traitant (faible chance de récupérer).
- **Long terme** : process strict en interne. **Avant chaque mission** : copie de l'attestation de vigilance dans un dossier "fournisseurs". Vérification auto **tous les 6 mois**.

**Leçon** : l'attestation prend 30 secondes à demander. Cette précaution évite des dizaines de milliers d'euros.
:::

## En synthèse du module

Vous maîtrisez désormais les 4 piliers commerciaux du transporteur léger :

1. **Construire** une offre claire et tarifée (devis + CGV).
2. **Trouver** des clients (prospection ciblée, fidélisation).
3. **Gérer** la relation (contrats, litiges, sous-traitance).
4. **Recouvrer** rapidement et professionnellement.

:::conseil
La différence entre un transporteur **stressé** et un transporteur **serein** : ces 4 éléments sont en place et **structurés**. Pas par chance — par méthode.
:::
$lesson5$,
$summary5$
**À retenir — Synthèse module B**

- Méfiance grand compte qui demande -20 % : risque marge + dépendance.
- Client fidèle mauvais payeur : diagnostic Infogreffe, protocole écrit, suspendre nouvelles missions.
- Toujours devis écrit (zéro verbal pour > 100 €).
- Sous-traitance : attestation de vigilance avant ET tous les 6 mois.
- Méthode > chance : 4 piliers commerciaux structurés (offre, prospection, gestion, recouvrement).
$summary5$
    );
  END IF;

  RAISE NOTICE 'Module B (Capa -3,5T - Activité commerciale) : 5 leçons premium créées.';
END
$mod_b$;
