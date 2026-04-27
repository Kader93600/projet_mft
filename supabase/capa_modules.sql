-- =====================================================================
-- Modules pédagogiques — Capacité de transport léger -3,5T
--
-- 6 modules (A→F) inspirés du référentiel officiel, avec ~3 leçons riches
-- chacun. Contenus rédigés en markdown étendu (callouts, mémos, pièges,
-- cas pratiques, conseils) pour mobiliser le composant <LessonContent>.
--
-- À jouer APRÈS formations_v2.sql (qui crée la formation 'capacite-3-5t').
-- Idempotent grâce aux ON CONFLICT DO NOTHING / UPDATE.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Bloc unique "Capacité -3,5T"
-- ---------------------------------------------------------------------
INSERT INTO public.blocs (code, title, description, "order")
VALUES ('CAPA-3-5T', 'Capacité de transport léger -3,5T',
        'Programme de préparation à l''examen national de capacité professionnelle pour les véhicules ≤ 3,5 tonnes.',
        100)
ON CONFLICT (code) DO UPDATE
  SET title = EXCLUDED.title,
      description = EXCLUDED.description;

-- ---------------------------------------------------------------------
-- 2) Modules A → F
-- ---------------------------------------------------------------------
DO $$
DECLARE
  bloc_id_var int;
  formation_id_var uuid;
  m_a uuid; m_b uuid; m_c uuid; m_d uuid; m_e uuid; m_f uuid;
BEGIN
  SELECT id INTO bloc_id_var FROM public.blocs WHERE code = 'CAPA-3-5T';
  SELECT id INTO formation_id_var FROM public.formations WHERE slug = 'capacite-3-5t';

  IF formation_id_var IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable. Lancez formations_v2.sql d''abord.';
  END IF;

  -- ===== Module A : Droit civil et commercial =====
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (bloc_id_var, 'capa-a-droit-civil-commercial',
          'Module A — Droit civil et commercial',
          'Formes juridiques, statut commerçant, contrats, recouvrement de créances et procédures collectives.',
          'debutant', 240, 10)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO m_a;

  -- ===== Module B : Activité commerciale =====
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (bloc_id_var, 'capa-b-activite-commerciale',
          'Module B — Activité commerciale',
          'Prospection, devis, facturation, relation client et politique commerciale du transporteur.',
          'debutant', 120, 20)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO m_b;

  -- ===== Module C : Cadre réglementaire =====
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (bloc_id_var, 'capa-c-reglementation-transport',
          'Module C — Cadre réglementaire du transport',
          'Conditions d''accès à la profession, registre, contrats type, responsabilité du transporteur.',
          'intermediaire', 300, 30)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO m_c;

  -- ===== Module D : Activité financière =====
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (bloc_id_var, 'capa-d-activite-financiere',
          'Module D — Activité financière',
          'Bilan, compte de résultat, capacité d''autofinancement, coût de revient kilométrique, BFR.',
          'intermediaire', 240, 40)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO m_d;

  -- ===== Module E : Salariés =====
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (bloc_id_var, 'capa-e-salaries',
          'Module E — Gestion du personnel',
          'Contrat de travail, CCNTRAAT, durée du travail, formation, rupture du contrat.',
          'intermediaire', 240, 50)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO m_e;

  -- ===== Module F : Sécurité =====
  INSERT INTO public.modules (bloc_id, slug, title, summary, difficulty, duration_min, "order")
  VALUES (bloc_id_var, 'capa-f-securite',
          'Module F — Sécurité routière',
          'Permis de conduire, alcoolémie, équipements véhicule, prévention des risques.',
          'debutant', 180, 60)
  ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary
  RETURNING id INTO m_f;

  -- Si les modules existaient déjà, on récupère leurs IDs
  IF m_a IS NULL THEN SELECT id INTO m_a FROM public.modules WHERE slug = 'capa-a-droit-civil-commercial'; END IF;
  IF m_b IS NULL THEN SELECT id INTO m_b FROM public.modules WHERE slug = 'capa-b-activite-commerciale'; END IF;
  IF m_c IS NULL THEN SELECT id INTO m_c FROM public.modules WHERE slug = 'capa-c-reglementation-transport'; END IF;
  IF m_d IS NULL THEN SELECT id INTO m_d FROM public.modules WHERE slug = 'capa-d-activite-financiere'; END IF;
  IF m_e IS NULL THEN SELECT id INTO m_e FROM public.modules WHERE slug = 'capa-e-salaries'; END IF;
  IF m_f IS NULL THEN SELECT id INTO m_f FROM public.modules WHERE slug = 'capa-f-securite'; END IF;

  -- ---------------------------------------------------------------------
  -- 3) Lier modules ↔ formation capacite-3-5t
  -- ---------------------------------------------------------------------
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES
    (formation_id_var, m_a, 10, true),
    (formation_id_var, m_b, 20, true),
    (formation_id_var, m_c, 30, true),
    (formation_id_var, m_d, 40, true),
    (formation_id_var, m_e, 50, true),
    (formation_id_var, m_f, 60, true)
  ON CONFLICT (formation_id, module_id) DO NOTHING;

  -- ---------------------------------------------------------------------
  -- 4) Leçons — chaque leçon utilise les blocs MDX :::callout, :::memo, etc.
  -- ---------------------------------------------------------------------

  -- ===== MODULE A — Droit civil et commercial =====
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order") VALUES
  (m_a, 'a1-formes-juridiques',
   'Choisir la forme juridique de son entreprise',
   $MD$
:::objectifs
- Différencier les principales formes juridiques (EI, EURL, SARL, SAS, SASU)
- Identifier les conséquences fiscales et sociales de chaque structure
- Choisir la forme adaptée à son projet de transport léger
:::

## Personne physique ou personne morale ?

Pour exercer une activité de transport léger, le créateur doit choisir entre **deux grandes catégories** de structures :

- **L'entreprise individuelle (EI)** : pas de personnalité morale distincte de l'entrepreneur.
- **La société** (EURL, SARL, SAS, SASU…) : personne morale distincte, dotée d'un patrimoine propre.

:::memo title="Distinction fondamentale"
Une **personne physique** est un individu (l'entrepreneur lui-même).
Une **personne morale** est une entité juridique fictive (la société) — elle peut posséder, contracter, ester en justice.
:::

## Les principales formes en transport léger

### Entreprise Individuelle (EI)

- **Création simple** : déclaration au CFE compétent, pas de capital minimum.
- **Responsabilité illimitée sur le patrimoine personnel** depuis la suppression du statut EIRL en 2022 — sauf si l'on opte pour le **régime de l'entrepreneur individuel à responsabilité limitée de plein droit** (loi du 14 février 2022).
- **Régime fiscal** : impôt sur le revenu (IR) — bénéfices industriels et commerciaux (BIC).

### EURL — Entreprise Unipersonnelle à Responsabilité Limitée

- Société à associé unique.
- Responsabilité **limitée aux apports**.
- Régime fiscal : IR par défaut, option IS possible.

### SARL — Société À Responsabilité Limitée

- 2 à 100 associés.
- Capital social librement fixé.
- Gérant nommé par les associés à la majorité (pas systématiquement commerçant).
- Régime fiscal : **IS** par défaut.

### SAS / SASU — Société par Actions Simplifiée

- Souplesse statutaire maximale.
- **Le président peut être personne physique ou morale**.
- Pas d'obligation pour le président d'être associé.
- Régime social du président : **assimilé salarié** (cotise au régime général).

:::piege
Dans une **SARL**, le gérant majoritaire est **TNS** (travailleur non salarié) — il ne bénéficie pas de l'assurance chômage.
Dans une **SAS**, le président est assimilé salarié et bénéficie de la sécurité sociale (mais pas non plus du chômage).
**Cette distinction est très souvent piégée à l'examen.**
:::

## Tableau comparatif

| Forme | Capital | Responsabilité | Fiscalité par défaut | Statut social du dirigeant |
|---|---|---|---|---|
| EI | Aucun | Illimitée (sauf option) | IR | TNS |
| EURL | Libre | Limitée aux apports | IR (option IS) | TNS |
| SARL | Libre | Limitée aux apports | IS | TNS si gérant majoritaire |
| SAS / SASU | Libre | Limitée aux apports | IS | Assimilé salarié |

:::caspratique title="Cas pratique : Karim crée son activité"
Karim souhaite démarrer en transport léger avec un véhicule de 2,5 t. Il est seul, n'a pas d'apport important, veut bénéficier du régime social général (santé) et envisage d'embaucher un salarié dans 2 ans.

→ La **SASU** est probablement la forme la plus adaptée : statut assimilé salarié, ouverture vers une SAS si associés futurs, fiscalité IS qui permet de capitaliser dans la société.
:::

:::conseil
Avant l'examen, sache citer **au moins 3 critères** pour choisir une forme juridique :
1) protection du patrimoine personnel
2) régime social du dirigeant
3) fiscalité (IR/IS)
4) facilité d'entrée d'associés.
:::
$MD$,
   $MS$
**À retenir :**
- EI : illimité, IR, TNS
- EURL/SARL : limité aux apports, IR ou IS, TNS si gérant majoritaire
- SAS/SASU : limité aux apports, IS, président assimilé salarié
$MS$,
   10),

  (m_a, 'a2-actes-commerce-et-statut',
   'Actes de commerce et statut de commerçant',
   $MD$
:::objectifs
- Définir l'acte de commerce et le statut de commerçant
- Identifier les obligations comptables et déclaratives
- Reconnaître les juridictions compétentes en matière commerciale
:::

## Qui est commerçant ?

L'**article L. 121-1 du Code de commerce** définit le commerçant comme **celui qui exerce des actes de commerce et en fait sa profession habituelle**.

:::law code="Code de commerce" article="L. 121-1"
Sont commerçants ceux qui exercent des actes de commerce et en font leur profession habituelle.
:::

## Le tribunal de commerce

- Composé de juges **consulaires** : commerçants élus par leurs pairs (et non magistrats traditionnels).
- Compétent pour les litiges entre commerçants ou actes de commerce.
- En cas de **désaccord entre un commerçant et un particulier**, le particulier peut choisir : tribunal de commerce **ou** tribunal judiciaire.

:::piege
Le tribunal de commerce **n'est pas composé de magistrats traditionnels** mais de commerçants élus. C'est très souvent piégé en QCM.
:::

## Procédure d'injonction de payer

- Permet de **demander par voie de justice le recouvrement de créances** sans audience contradictoire.
- Compétence du tribunal du **siège du débiteur**, pas du créancier.
- Voie rapide et peu coûteuse pour les factures impayées.

:::caspratique title="Recouvrer une facture impayée"
Une entreprise lilloise (le créancier) facture un client commerçant à Brest (le débiteur). Le client ne paie pas.

→ La requête en injonction de payer doit être adressée au **tribunal de commerce de Brest** (lieu du débiteur), pas de Lille.
:::

## Effets de commerce

- **Lettre de change** : émise par le **tireur** (créancier), adressée au **tiré** (débiteur) pour acceptation.
- **Billet à ordre** : signé par le **souscripteur** (acheteur/débiteur) qui s'engage à payer.
- **Chèque certifié** : la banque atteste que la **provision existe** (non bloquée).
- **Chèque visé** : visa simple, sans blocage de la provision.

:::memo title="Mémo effets de commerce"
- **Lettre de change** = créancier qui réclame
- **Billet à ordre** = débiteur qui promet
- **Chèque certifié** = provision attestée (non bloquée)
- **Chèque de banque** = banque elle-même tireur ET tirée
:::
$MD$,
   $MS$
- Tribunal de commerce = juges consulaires (commerçants élus)
- Injonction de payer : tribunal du **débiteur**
- Lettre de change : créancier → débiteur
- Billet à ordre : débiteur s'engage à payer
$MS$,
   20),

  (m_a, 'a3-procedures-collectives',
   'Procédures collectives et difficultés d''entreprise',
   $MD$
:::objectifs
- Comprendre la différence entre redressement, liquidation et conciliation
- Identifier qui peut demander l'ouverture d'une procédure
- Anticiper les conséquences pour le dirigeant
:::

## Les procédures de prévention et de traitement

### Mandat ad hoc et conciliation
Procédures **confidentielles**, non collectives, à l'initiative du dirigeant en cas de difficultés naissantes.

### Procédure de sauvegarde
Préventive, ouverte à la demande du dirigeant **avant cessation des paiements**.

### Redressement judiciaire
Ouverte en cas de **cessation des paiements** : l'entreprise ne peut plus faire face à son passif exigible avec son actif disponible.

### Liquidation judiciaire
Lorsque le redressement est manifestement impossible.

## Qui peut demander l'ouverture ?

L'ouverture d'une procédure de redressement judiciaire peut être demandée :

- par le **chef d'entreprise** lui-même (déclaration de cessation des paiements dans les 45 jours),
- par les **créanciers**,
- par les **salariés** (via le procureur),
- par le **président du tribunal de commerce** (saisine d'office),
- par le **procureur de la République**.

:::piege
La compétence pour ouvrir une procédure est **partagée** entre tous ces acteurs. Une question d'examen demande "exclusivement le chef d'entreprise" → c'est **faux**.
:::

## La faillite personnelle

La **faillite personnelle** est une **sanction prononcée à l'encontre d'une personne physique** (le dirigeant) en cas de fautes graves : tenue de comptabilité fictive, détournement d'actif, etc.

:::memo title="Distinction importante"
- **Liquidation judiciaire** = procédure visant l'**entreprise**.
- **Faillite personnelle** = sanction visant le **dirigeant** personnellement (interdiction de gérer pendant 15 ans max).
:::
$MD$,
   $MS$
- Cessation des paiements = actif < passif exigible
- Demande RJ : chef, créancier, salarié, président TC, procureur
- Faillite personnelle = sanction du dirigeant
$MS$,
   30);

  -- ===== MODULE B — Activité commerciale =====
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order") VALUES
  (m_b, 'b1-prospection-et-devis',
   'Prospection commerciale et établissement du devis',
   $MD$
:::objectifs
- Construire une démarche de prospection efficace
- Établir un devis transport conforme et compétitif
- Comprendre la valeur juridique du devis
:::

## La prospection en transport léger

Trois canaux dominent dans le transport léger :

- **Bouche-à-oreille local** (artisans, commerçants, e-commerçants)
- **Plateformes B2B** : annuaires de transporteurs, marketplaces (en ligne ou via intermédiaires)
- **Démarchage direct** : visite d'entreprises potentielles (artisans BTP, e-commerce local)

:::conseil
Pour démarrer, le **bouche-à-oreille** local est souvent le levier #1. Soigner sa visibilité Google Maps + témoignages clients = retours rapides.
:::

## Le devis : élément clé du contrat

Le devis est une **offre commerciale**. Une fois **accepté par le client** (par signature ou bon pour accord), il devient **engagement contractuel**.

### Mentions obligatoires
- Identité du transporteur (raison sociale, SIRET)
- Identité du client
- Description précise de la prestation (origine, destination, nature des marchandises, dates)
- **Prix HT** (les transporteurs sont assujettis à la TVA — 20 % en métropole)
- Validité de l'offre (souvent 30 jours)
- Conditions de paiement

:::piege
**Erreur classique** : oublier de mentionner que le devis a une **durée de validité**. Sans validité écrite, le client peut accepter l'offre 6 mois plus tard… au tarif initial.
:::

:::caspratique title="Devis pour livraison régulière"
Un boulanger demande un devis pour livrer ses 12 boutiques 6 jours par semaine. Le devis doit prévoir :
- une **clause de révision** annuelle (carburant)
- une **clause de pénalités** pour non-paiement
- la **prestation type** : tournée, kilométrage, durée
- les **conditions de modification** de la tournée
:::
$MD$,
   $MS$
- Devis = offre + acceptation = contrat
- Mentions obligatoires : prix HT, validité, identité parties, description prestation
- Clauses utiles : révision carburant, pénalités, modifications
$MS$,
   10),

  (m_b, 'b2-facturation-et-cgv',
   'Facturation et conditions générales de vente',
   $MD$
:::objectifs
- Émettre une facture conforme à la réglementation
- Maîtriser les délais de paiement légaux
- Rédiger des CGV protectrices
:::

## La facture : mentions obligatoires

Une facture doit obligatoirement contenir :

- Numéro et date d'émission
- Identité complète du vendeur (raison sociale, SIRET, adresse, RCS si commerçant)
- Identité du client (raison sociale, adresse, **n° TVA intracommunautaire** pour B2B)
- Description et quantité des biens/services
- Prix HT, taux de TVA, montant TTC
- Conditions de règlement et **taux des pénalités de retard**
- Mention de l'**indemnité forfaitaire de 40 €** pour frais de recouvrement (Code de commerce L. 441-10)

## Délais de paiement

- **Délai légal supplétif** : 30 jours fin de mois.
- **Délai conventionnel maximum** : 60 jours date de facture (ou 45 jours fin de mois).
- En cas de dépassement : **pénalités de retard** dues sans mise en demeure préalable + indemnité forfaitaire 40 €.

:::law code="Code de commerce" article="L. 441-10"
Tout professionnel en situation de retard de paiement est de plein droit débiteur, à l'égard du créancier, d'une indemnité forfaitaire pour frais de recouvrement, dont le montant est fixé à 40 €.
:::

:::piege
La pénalité de retard ne se déclenche **pas seulement** si elle est mentionnée au contrat : elle s'applique **de plein droit** dès le 1er jour de retard.
:::

## Les CGV (Conditions Générales de Vente)

Obligatoires entre professionnels (B2B) **sur demande** : tout client peut demander les CGV, le transporteur doit les communiquer.

Doivent inclure :
- Tarifs
- Délais de paiement
- Pénalités de retard
- Conditions de remise et rabais
- Modalités de règlement

:::memo title="3 réflexes facturation"
1. **Facturer dès la prestation faite** (ne jamais attendre — la créance ne court qu'à partir de la facture)
2. **Toujours mentionner pénalité de retard + 40 €**
3. **Conserver toutes les factures 10 ans** (Code de commerce)
:::
$MD$,
   $MS$
- Facture = mentions complètes + conditions paiement
- Pénalités de retard automatiques + 40 € forfaitaire
- CGV à communiquer sur demande en B2B
- Conservation 10 ans
$MS$,
   20);

  -- ===== MODULE C — Cadre réglementaire =====
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order") VALUES
  (m_c, 'c1-acces-profession',
   'Conditions d''accès à la profession de transporteur',
   $MD$
:::objectifs
- Identifier les 4 conditions d'accès à la profession
- Comprendre le rôle de l'attestation de capacité
- Maîtriser les démarches d'inscription au registre
:::

## Les 4 conditions d'accès

Pour exercer le transport routier de marchandises avec véhicules ≤ 3,5 t (à but lucratif), 4 conditions cumulatives :

1. **Honorabilité professionnelle** (B2 du casier)
2. **Capacité financière**
3. **Capacité professionnelle** (cette formation !)
4. **Établissement stable** en France

:::law code="Décret 2011-2045" article="Art. 1er"
L'accès à la profession de transporteur public routier de marchandises avec des véhicules ≤ 3,5 t est subordonné à la délivrance d'une licence par le préfet de région, après vérification des conditions précitées.
:::

## La capacité financière

Montants exigés :

:::figures
- 1 800 € | premier véhicule
- 900 € | par véhicule supplémentaire
:::

Justifiée par :
- Capitaux propres et réserves de l'entreprise, OU
- Garanties bancaires délivrées par un établissement financier

## Le registre des transporteurs (DREAL)

Inscription **obligatoire** auprès de la DREAL de la région du siège.

Documents à fournir :
- Justificatifs des 4 conditions
- Statuts (si société)
- Pièce d'identité du dirigeant
- Justificatifs établissement (bail, K-bis)

:::piege
Beaucoup confondent **DREAL** (transport routier) et **DDT** (autres). C'est bien la **DREAL** qui gère le registre des transporteurs.
:::

:::caspratique title="Karim s'inscrit au registre"
Karim a obtenu son attestation de capacité. Il doit constituer son dossier auprès de la DREAL avec :
1. K-bis de moins de 3 mois
2. Attestation bancaire de capacité financière (1 800 €)
3. Bulletin n°2 du casier (honorabilité)
4. Attestation de capacité professionnelle
5. Justificatif d'établissement (bail commercial ou domiciliation)
:::

## La licence de transport intérieur

Une fois le dossier validé :
- **Licence de transport intérieur** délivrée pour 10 ans, renouvelable.
- Une **copie certifiée conforme** par véhicule exploité.
:::memo title="À retenir absolument"
- 4 conditions : honorabilité, financière, professionnelle, établissement
- Capacité financière : **1 800 € / 900 €**
- Inscription : **DREAL** régionale
- Licence valable **10 ans**
:::
$MD$,
   $MS$
- 4 conditions d'accès : honorabilité, financière (1 800 € / 900 €), capacité, établissement
- Inscription DREAL, licence 10 ans
- Bulletin n°2 du casier judiciaire pour honorabilité
$MS$,
   10),

  (m_c, 'c2-contrats-type',
   'Le contrat type de transport',
   $MD$
:::objectifs
- Connaître le rôle du contrat type général
- Maîtriser les principales clauses (responsabilité, prescription)
- Identifier les documents obligatoires à bord
:::

## Le contrat type général

Le **décret 99-269 du 6 avril 1999** fixe le **contrat type** applicable aux transports publics routiers de marchandises **en l'absence de convention écrite** entre le donneur d'ordre et le transporteur.

:::caspratique title="Quand s'applique-t-il ?"
Une PME demande à un transporteur léger de livrer 200 cartons à un client. Aucun contrat écrit n'a été signé. → Le **contrat type général** s'applique automatiquement, et fixe les règles :
- responsabilité du transporteur,
- délais de livraison,
- prescription de l'action en responsabilité…
:::

## Responsabilité du transporteur

- Présomption de responsabilité **pour perte, avarie ou retard**.
- Limitations d'indemnisation **par contrat type** :
  - Perte/avarie : **23 €/kg** ou **750 €/colis**
  - Retard : **prix du transport** (limite)

:::piege
Beaucoup pensent que le transporteur est responsable **sans limite** : c'est faux, les barèmes du contrat type plafonnent les indemnisations sauf faute lourde ou dol.
:::

## Action en responsabilité — Délai de prescription

**1 an** à compter de la livraison (ou de la date à laquelle elle aurait dû avoir lieu).
Délai très court → **réagir vite** en cas de litige.

## Documents obligatoires à bord

À tout moment, le conducteur doit pouvoir présenter :

1. **Lettre de voiture CMR** (pour international) ou bordereau de livraison (national)
2. **Copie certifiée conforme de la licence** de transport
3. **Attestation de conducteur** (si conducteur non-UE)
4. **Documents du véhicule** : certificat d'immatriculation, contrôle technique, attestation d'assurance
5. **Permis de conduire** valide

:::memo title="Réflexes contrôle"
- Toujours **CMR / bordereau** + **licence** dans le véhicule
- Délai de prescription : **1 an**
- Indemnisation perte : **23 €/kg ou 750 €/colis**
:::
$MD$,
   $MS$
- Contrat type 99-269 : responsabilité, délais, prescription
- Indemnisation : 23 €/kg ou 750 €/colis (perte/avarie)
- Prescription : 1 an
- Documents bord : CMR/bordereau + licence + immatriculation
$MS$,
   20),

  (m_c, 'c3-temps-conduite-tachy',
   'Temps de conduite et chronotachygraphe (-3,5T)',
   $MD$
:::objectifs
- Maîtriser les temps de conduite et de repos
- Comprendre l'usage du chronotachygraphe pour les véhicules concernés
- Identifier les sanctions en cas de dépassement
:::

## Cas particulier des -3,5 t

Pour les véhicules ≤ 3,5 t en transport pour compte d'autrui, **le chronotachygraphe n'est pas obligatoire**. Les temps de conduite restent toutefois encadrés par le **Code du travail** (durée du travail) et la **réglementation sociale européenne** lorsque le véhicule est conduit professionnellement.

:::piege
Beaucoup confondent : pour les véhicules **> 3,5 t**, c'est le **règlement (CE) 561/2006** qui s'applique avec chrono.
Pour les **≤ 3,5 t**, c'est le **Code du travail** qui prévaut, avec un suivi via **livret individuel de contrôle (LIC)** ou outils de pointage.
:::

## Repères pour les -3,5 t

:::figures
- 10h | conduite max / jour (Code du travail, conducteur seul)
- 11h | conduite max / jour (équipage)
- 35h | repos hebdomadaire min
:::

:::law code="Code du travail" article="L. 3312-1 et s."
La durée du travail effective d'un salarié ne peut excéder 10 heures par jour ni 48 heures par semaine, dérogations légales prévues pour le secteur transport.
:::

## Le LIC — Livret Individuel de Contrôle

Pour les véhicules non équipés de chrono :
- Livret papier ou électronique mis à disposition du conducteur
- Mentions : heures début/fin, pauses, kilométrage
- À conserver **52 jours** dans le véhicule + **3 ans** par l'employeur

:::memo title="Synthèse rapide"
- Chrono = **> 3,5 t** seulement
- LIC = ≤ 3,5 t
- Conduite max : **10 h / jour** (Code du travail)
- Conservation LIC : 52 jours véhicule, 3 ans employeur
:::
$MD$,
   $MS$
- ≤ 3,5 t : pas de chrono, mais LIC + Code du travail
- 10 h conduite/jour max
- 35 h repos hebdomadaire min
- LIC : 52 j véhicule, 3 ans employeur
$MS$,
   30);

  -- ===== MODULE D — Activité financière =====
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order") VALUES
  (m_d, 'd1-bilan-compte-resultat',
   'Lire un bilan et un compte de résultat',
   $MD$
:::objectifs
- Distinguer actif/passif, charges/produits
- Calculer les principaux soldes intermédiaires de gestion (SIG)
- Identifier la rentabilité de l'entreprise
:::

## Le bilan : photographie patrimoniale

Le bilan est une **photo à l'instant T** :

- À gauche, l'**ACTIF** : ce que l'entreprise possède (immobilisations, stocks, créances, trésorerie)
- À droite, le **PASSIF** : comment c'est financé (capitaux propres, dettes)

**Actif = Passif** toujours.

:::memo title="Logique bilan"
- Actif = **emplois** (où va l'argent)
- Passif = **ressources** (d'où vient l'argent)
- Capitaux propres = capital + réserves + résultat
:::

## Le compte de résultat : film de l'activité

Le compte de résultat couvre **une période** (en général 12 mois).

- **Produits** (ventes, autres produits) - **Charges** (achats, salaires, amortissements, impôts) = **Résultat net**

## Les Soldes Intermédiaires de Gestion (SIG)

```
Marge commerciale     = Ventes de marchandises - Achats marchandises
Valeur ajoutée (VA)   = Production - Consommations externes
EBE (excédent brut)   = VA - Charges de personnel - Impôts (hors IS)
Résultat exploitation = EBE - Dotations amortissements
Résultat courant      = Résultat exploitation + Résultat financier
Résultat net          = Résultat courant + Exceptionnel - IS
```

:::caspratique title="EBE positif mais résultat négatif ?"
Si l'EBE est positif mais le résultat net négatif, cela signifie probablement :
- des **dotations aux amortissements** importantes (achats récents de véhicules), ou
- des **charges financières** lourdes (emprunts en cours).

→ Ce n'est pas forcément alarmant si l'EBE reste solide.
:::

:::piege
Le **résultat net** ne mesure **pas la trésorerie**. Une entreprise peut être bénéficiaire et en cessation de paiement (BFR mal géré).
:::
$MD$,
   $MS$
- Bilan = patrimoine T (actif = passif)
- Compte de résultat = activité année (produits - charges)
- SIG : marge commerciale → VA → EBE → résultat
- Résultat ≠ trésorerie
$MS$,
   10),

  (m_d, 'd2-cout-revient-km',
   'Calculer le coût de revient kilométrique',
   $MD$
:::objectifs
- Identifier les charges fixes et variables d'une activité transport
- Calculer un coût de revient kilométrique
- Établir une grille tarifaire compétitive
:::

## Charges fixes vs variables

### Charges FIXES (indépendantes de l'activité)
- Loyer, assurances, abonnements
- Salaires + charges sociales du dirigeant et permanents
- Amortissements des véhicules
- Cotisations sociales fixes

### Charges VARIABLES (proportionnelles aux km)
- Carburant
- Pneumatiques
- Entretien-réparations
- Péages
- Heures supplémentaires des conducteurs

## Méthode de calcul

```
Coût de revient km = (CF + CV) / Nombre de km parcourus / an
```

**Exemple** : entreprise individuelle avec 1 véhicule

| Poste | Annuel |
|---|---:|
| Salaire dirigeant + cotisations | 30 000 € |
| Loyer / charges fixes structure | 6 000 € |
| Amortissement véhicule | 8 000 € |
| Assurance | 2 500 € |
| **Total CF** | **46 500 €** |
| Carburant (40 000 km × 0,15 €) | 6 000 € |
| Pneus | 800 € |
| Entretien | 1 500 € |
| **Total CV** | **8 300 €** |
| **TOTAL annuel** | **54 800 €** |

→ Coût de revient km = 54 800 / 40 000 = **1,37 € / km**

:::conseil
Pour fixer ton tarif client : ajoute une **marge de 15 à 25 %** au coût de revient. Avec 1,37 € de coût, tu factureras **1,60 à 1,75 € / km** en moyenne.
:::

:::piege
**Erreur fréquente** : oublier d'inclure son **propre salaire** dans les charges fixes. Sans cela, on calcule un coût de revient **sous-évalué** et on travaille à perte.
:::
$MD$,
   $MS$
- CF (loyer, salaires, amortissement) + CV (carburant, pneus, entretien)
- Coût km = (CF + CV) / km annuels
- Marge de 15-25 % pour le tarif client
- Toujours intégrer son propre salaire
$MS$,
   20),

  (m_d, 'd3-caf-bfr-tresorerie',
   'CAF, BFR et gestion de trésorerie',
   $MD$
:::objectifs
- Calculer la capacité d'autofinancement (CAF)
- Comprendre le besoin en fonds de roulement (BFR)
- Anticiper les tensions de trésorerie
:::

## La Capacité d'Autofinancement (CAF)

La CAF mesure les **liquidités générées** par l'activité, disponibles pour :
- rembourser les emprunts
- investir
- distribuer des dividendes

```
CAF = Résultat net + Dotations amortissements + Dotations provisions
      − Reprises sur amortissements/provisions
      + Valeur nette comptable des éléments cédés
      − Produits de cession
```

**Méthode simplifiée** : CAF ≈ Résultat net + Dotations amortissements

:::caspratique title="La banque accorde-t-elle un crédit ?"
TMG TRANSPORT veut emprunter 20 000 € pour un nouveau véhicule.

Bilan : Résultat net 12 000 € + Dotations amortissements 18 000 € = **CAF 30 000 €/an**.

Avec une CAF annuelle 1,5× supérieure au montant emprunté, et si le ratio d'endettement reste sain (< 60 %), la banque accordera très probablement le crédit.
:::

## Le Besoin en Fonds de Roulement (BFR)

```
BFR = Stocks + Créances clients − Dettes fournisseurs
```

En transport, les stocks sont marginaux. Le BFR vient surtout du **décalage clients/fournisseurs** :

- Clients (B2B) : payés à 30-60 jours
- Fournisseurs : payés à 30 jours
- Carburant : payé immédiatement

→ Le BFR transport est souvent **élevé** car les délais clients sont longs et le carburant cash.

:::piege
Le BFR n'apparaît **pas dans le compte de résultat**. Une entreprise peut être bénéficiaire mais avec un BFR énorme qui asphyxie la trésorerie. **Comprendre cela = clé de l'examen.**
:::

## Anticiper les tensions

3 leviers concrets :

1. **Affacturage** : céder ses créances à une banque/factor pour cash immédiat (coût ~1-3 %)
2. **Acompte client** : 30 % à la commande, solde à livraison
3. **Réduction délais clients** : escompte pour règlement comptant

:::memo title="Les 3 indicateurs vitaux"
- **CAF** : liquidités dégagées par an
- **BFR** : trésorerie immobilisée par le cycle d'exploitation
- **Trésorerie nette** = FRNG − BFR
:::
$MD$,
   $MS$
- CAF ≈ Résultat net + Dotations amort. (capacité à rembourser, investir)
- BFR = Stocks + Créances − Dettes fournisseurs (cycle d'exploitation)
- Levier tension : affacturage, acompte, escompte
$MS$,
   30);

  -- ===== MODULE E — Salariés =====
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order") VALUES
  (m_e, 'e1-contrat-travail-conducteur',
   'Le contrat de travail du conducteur routier',
   $MD$
:::objectifs
- Choisir le bon type de contrat (CDI, CDD)
- Rédiger un contrat conforme à la CCNTRAAT
- Identifier les clauses spécifiques au transport
:::

## Les types de contrats

- **CDI** : durée indéterminée, principe de droit commun.
- **CDD** : durée déterminée, motivé (remplacement, surcroît d'activité, saisonnalité).
- **Intérim** : via une entreprise de travail temporaire.

:::piege
Un CDD ne peut être conclu que pour un **motif précis et limité dans le temps**. Recourir au CDD pour un emploi permanent est une **fraude** (requalification en CDI possible par le conseil de prud'hommes).
:::

## La CCNTRAAT

**Convention Collective Nationale du Transport Routier et des Activités Auxiliaires de Transport** (IDCC 16).

- S'applique de **plein droit** à toute entreprise de transport routier (qu'elle soit signataire ou non).
- Définit grilles de salaires, durée du travail, primes, congés…

:::law code="Code du travail" article="L. 2261-2"
Les conventions collectives étendues s'appliquent à toutes les entreprises relevant de leur champ d'application, qu'elles soient ou non adhérentes à une organisation patronale signataire.
:::

## Mentions obligatoires d'un contrat conducteur

- Identité des parties
- Date d'embauche
- Lieu de travail (et clause de mobilité éventuelle)
- Fonction et coefficient (selon CCNTRAAT)
- Durée du travail
- Rémunération (salaire de base + primes + heures supplémentaires)
- **Clause permis** : obligation de maintenir un permis valide
- Mention de la convention collective applicable
- Période d'essai

:::caspratique title="Clause permis : indispensable ?"
Si la conduite **fait partie intégrante** du poste, la clause permis est **fortement recommandée**. En cas de retrait/suspension du permis :
- Le salarié doit **prévenir l'employeur sans délai**
- L'employeur peut envisager un licenciement disciplinaire (jurisprudence Cass. soc.)
- Sans clause, le licenciement peut être contesté
:::
$MD$,
   $MS$
- CDI / CDD / Intérim — CDD avec motif obligatoire
- CCNTRAAT s'applique de plein droit
- Mentions obligatoires : fonction, coefficient, salaire, clause permis
$MS$,
   10),

  (m_e, 'e2-duree-travail-tr',
   'Durée du travail dans le transport routier',
   $MD$
:::objectifs
- Maîtriser la durée légale et conventionnelle
- Comprendre le statut de "temps de service"
- Calculer les heures supplémentaires
:::

## Le temps de service

Notion **spécifique au transport** :

> Le **temps de service** comprend le temps de conduite, le temps passé à disposition du véhicule (chargement/déchargement) et tout autre temps lié à la prestation.

Il est **plus large** que le simple "temps de travail effectif" du Code du travail.

## Limites légales

:::figures
- 35h | durée légale hebdomadaire
- 48h | maximum absolu hebdomadaire
- 44h | moyenne sur 12 semaines consécutives
:::

Pour les conducteurs courte distance (≤ 3,5 t typiquement) :
- **Durée mensuelle de service** : 169 heures avec heures d'équivalence (CCNTRAAT)

## Heures supplémentaires

Au-delà de 35 h hebdomadaires :

- 36e à 43e heure : **+25 %**
- 44e à 48e heure : **+50 %**

Repos compensateur obligatoire au-delà du contingent annuel.

:::piege
Les **heures d'équivalence** (différence entre 169 h mensuelles et 152 h x 35 h) ne sont **pas des heures supplémentaires**. Elles sont rémunérées au taux normal selon la CCNTRAAT.
**Erreur fréquente à l'examen.**
:::

:::memo title="Les 3 plafonds à mémoriser"
- **35 h** : durée légale hebdomadaire (point de départ HS)
- **44 h** : moyenne sur 12 semaines max
- **48 h** : plafond absolu hebdomadaire
:::
$MD$,
   $MS$
- Temps de service = conduite + disposition + travaux annexes
- 35 h légales / 44 h moy 12 semaines / 48 h max
- Majoration HS : +25% (36-43h), +50% (44-48h)
$MS$,
   20),

  (m_e, 'e3-rupture-contrat',
   'Rupture du contrat de travail',
   $MD$
:::objectifs
- Distinguer les modes de rupture (démission, licenciement, rupture conventionnelle)
- Maîtriser la procédure disciplinaire
- Calculer l'indemnité de licenciement
:::

## Les modes de rupture

| Mode | Initiative | Indemnité légale |
|---|---|---|
| Démission | Salarié | Aucune (ni chômage en principe) |
| Licenciement personnel | Employeur | Selon ancienneté |
| Licenciement économique | Employeur | Selon ancienneté + spécial |
| Rupture conventionnelle | Accord mutuel | ≥ Indemnité légale licenciement |
| Prise d'acte / Résiliation judiciaire | Salarié | Selon issue |

## La procédure de licenciement

1. **Convocation à entretien préalable** (LRAR ou remise main propre, ≥ 5 jours ouvrables avant)
2. **Entretien préalable** : motif exposé, salarié peut être assisté
3. **Notification du licenciement** par LRAR (≥ 2 jours ouvrables après l'entretien, ≤ 1 mois pour faute)
4. **Préavis** + indemnités

## Indemnité légale de licenciement

```
< 10 ans d'ancienneté : 1/4 mois × ancienneté
≥ 10 ans              : 1/4 × 10 + 1/3 × (ancienneté − 10)
```

Salaire de référence = moyenne des **12 derniers mois** (ou 3 derniers, le plus favorable).

:::caspratique title="Calcul indemnité"
Salarié licencié après **15 ans** d'ancienneté, salaire moyen 2 400 €.

Indemnité = (1/4 × 10 × 2400) + (1/3 × 5 × 2400)
= 6 000 + 4 000 = **10 000 €**
:::

## Faute simple, grave, lourde

- **Faute simple** : motif suffisant pour licencier, mais préavis + indemnité dus.
- **Faute grave** : impossible de poursuivre la relation. Pas de préavis, pas d'indemnité légale.
- **Faute lourde** : intention de nuire à l'employeur. Pas de préavis, pas d'indemnité, parfois dommages-intérêts.

:::piege
La **faute lourde** exige une **intention de nuire**. Un simple manquement, même grave, n'est pas une faute lourde sans intention démontrée. Question récurrente à l'examen.
:::
$MD$,
   $MS$
- Modes : démission, licenciement, rupture conventionnelle
- Procédure licenciement : convoc → entretien → notification
- Indemnité : 1/4 mois × ancienneté (1/3 au-delà de 10 ans)
- Faute simple / grave (sans préavis) / lourde (intention de nuire)
$MS$,
   30);

  -- ===== MODULE F — Sécurité =====
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order") VALUES
  (m_f, 'f1-permis-points',
   'Le permis à points et les sanctions',
   $MD$
:::objectifs
- Maîtriser le système du permis à points
- Identifier les retraits par infraction
- Connaître les modalités de récupération
:::

## Le capital points

- Tout conducteur dispose d'un capital de **12 points** (6 pendant la période probatoire)
- Le capital se reconstitue automatiquement après une période sans infraction

## Retraits par infraction

| Infraction | Retrait |
|---|---:|
| Excès de vitesse < 20 km/h | 1 point |
| Excès de vitesse 20-30 km/h | 2 points |
| Excès de vitesse 30-40 km/h | 3 points |
| Excès de vitesse 40-50 km/h | 4 points |
| Excès de vitesse > 50 km/h | 6 points |
| Téléphone tenu en main | 3 points |
| Feu rouge / stop | 4 points |
| Alcoolémie 0,5-0,8 g/L | 6 points |
| Alcoolémie > 0,8 g/L ou refus | 6 points |
| Conduite sans permis | (délit, peine prison) |

:::piege
Le **maximum simultané** est de **8 points** retirés en une seule fois, même si plusieurs infractions sont constatées en même temps. Souvent piégé.
:::

## Récupération des points

- **Automatique** : 6 mois sans infraction → 1 point. 2 ans sans nouvelle infraction → tout le capital récupéré (3 ans pour infraction grave).
- **Stage de sensibilisation** : ≥ 1 an depuis le dernier stage → +4 points (sans dépasser 12).

## Période probatoire

- 3 ans (2 ans avec conduite accompagnée).
- Capital initial : **6 points**.
- Augmentation progressive : 2 points/an si pas d'infraction.

:::caspratique title="Jeune conducteur en alcoolémie"
Un conducteur en période probatoire avec 0,4 g/L d'alcool : la concentration autorisée pour les conducteurs en période probatoire est de **0,2 ‰**.

→ Il est en infraction. Conséquences :
- Suspension immédiate du permis 6 mois
- Prolongation de la période probatoire d'1 an
- Stage obligatoire à ses frais
:::
$MD$,
   $MS$
- Capital 12 (6 probatoire), max 8 retirés simultanés
- Récup auto : 6 mois (1 pt) / 2-3 ans (capital plein)
- Stage : +4 points (1× par an min)
- Probatoire : 0,2 ‰ alcool
$MS$,
   10),

  (m_f, 'f2-equipements-vehicule',
   'Équipements obligatoires du véhicule',
   $MD$
:::objectifs
- Identifier les équipements obligatoires à bord
- Connaître les contrôles et entretiens périodiques
- Comprendre les sanctions en cas de défaut
:::

## Documents obligatoires (à bord)

- **Certificat d'immatriculation** (carte grise)
- **Attestation d'assurance** + macaron sur pare-brise
- **Contrôle technique en cours de validité**
- **Permis de conduire** valide
- **Licence de transport** (copie certifiée conforme)
- **Lettre de voiture / bordereau de livraison**

## Équipements obligatoires

- **Gilet de haute visibilité** (réfléchissant) — accessible depuis l'habitacle
- **Triangle de pré-signalisation**
- **Éthylotest** (NF, à jour)
- **Roue de secours** ou kit de réparation
- **Extincteur** (obligatoire pour véhicules > 3,5 t — recommandé pour utilitaires)
- **Trousse de premiers secours** (recommandée)

## Contrôle technique

| Type véhicule | Premier CT | Périodicité |
|---|---|---|
| VL ≤ 3,5 t (perso) | 4 ans après 1ère immatriculation | Tous les 2 ans |
| VUL ≤ 3,5 t (pro) | 4 ans | **Tous les ans** (depuis 2018 pour pollution, 2 ans pour le reste) |

:::piege
Pour un véhicule **utilitaire** (VUL) en activité professionnelle, il faut un **contrôle pollution annuel** en plus du contrôle technique tous les 2 ans. Confusion fréquente.
:::

## Pneumatiques

- Profondeur minimale des **rainures** : **1,6 mm**
- Vérification mensuelle pression à froid recommandée
- Pression conforme à la **plaque constructeur** (ou portière)

:::caspratique title="Roulement avec pneus usés"
Un véhicule contrôlé avec rainures à 1,2 mm risque :
- **Amende forfaitaire de 135 €** par pneu non conforme
- **Immobilisation** possible du véhicule
- **Refus contrôle technique** lors du passage suivant
- En cas d'accident, **résiliation possible de l'assurance** (faute caractérisée)
:::

:::memo title="Avant chaque tournée"
1. Niveaux (huile, lave-glace, refroidissement)
2. Pneus (pression + état)
3. Éclairage (feux, clignotants, stop)
4. Documents bord vérifiés
5. Gilet + triangle accessibles
:::
$MD$,
   $MS$
- Documents : carte grise, assurance, CT, permis, licence, lettre voiture
- Équipements : gilet, triangle, éthylotest
- CT VUL pro : 2 ans + pollution annuelle
- Pneus : rainures ≥ 1,6 mm
$MS$,
   20),

  (m_f, 'f3-prevention-risques',
   'Prévention des risques professionnels',
   $MD$
:::objectifs
- Comprendre les obligations DUERP de l'employeur
- Identifier les risques spécifiques au transport
- Mettre en place un plan de prévention
:::

## Le Document Unique d'Évaluation des Risques Professionnels (DUERP)

**Obligatoire** dès **1 salarié**.

- Identifie tous les risques professionnels
- Classe par unité de travail
- Définit un plan d'action
- À mettre à jour **au moins une fois par an** ou à chaque changement significatif

:::law code="Code du travail" article="R. 4121-1"
L'employeur transcrit et met à jour dans un document unique les résultats de l'évaluation des risques pour la santé et la sécurité des travailleurs.
:::

## Risques typiques en transport léger

1. **Risque routier** : 1ère cause de mortalité au travail (51 % en 2022)
2. **Manutention manuelle** : TMS, lombalgies
3. **Chutes de plain-pied** ou de hauteur (descente cabine)
4. **Risque chimique** (transport de substances)
5. **Stress / fatigue** liés aux délais

## Plan de prévention

Pour les interventions ponctuelles d'une entreprise extérieure (entretien véhicule, lavage…) chez un client : **plan de prévention écrit obligatoire** si l'intervention dépasse 400 h/an ou en cas de travaux dangereux.

## Document Unique : risques d'amende

Absence de DUERP : **amende 1 500 € (3 000 € en récidive)** + responsabilité pénale en cas d'accident.

:::caspratique title="Accident grave et DUERP absent"
Un livreur tombe gravement en descendant d'un véhicule mal entretenu. L'inspection du travail découvre :
- Pas de DUERP
- Pas de visite médicale
- Pas de formation aux gestes et postures

→ **Faute inexcusable** possible de l'employeur, indemnisation majorée à la victime, condamnation pénale du dirigeant possible.
:::

:::conseil
Pour démarrer ton DUERP : **modèles INRS gratuits** (`inrs.fr`) + 1 réunion annuelle avec tes salariés. C'est moins lourd qu'on ne le pense, et c'est ta meilleure protection juridique.
:::
$MD$,
   $MS$
- DUERP obligatoire dès 1 salarié, MAJ annuelle
- Risque #1 transport = routier (51 % mortalité travail)
- Plan de prévention écrit pour entreprises extérieures
- Absence DUERP = 1 500 € / 3 000 € amende + responsabilité pénale
$MS$,
   30);

END $$;
