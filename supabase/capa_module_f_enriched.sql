-- =====================================================================
-- MODULE F — SÉCURITÉ ET PRÉVENTION (Capa -3,5T)
-- 5 leçons premium ~ 170 min.
-- =====================================================================

DO $mod_f$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation capacite-3-5t introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc défini.'; END IF;

  SELECT id INTO v_module FROM public.modules WHERE slug = 'capa-securite-prevention' LIMIT 1;
  IF v_module IS NULL THEN
    INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
    VALUES (
      'Sécurité et prévention',
      'capa-securite-prevention',
      v_bloc,
      'Code de la route, alcoolémie, équipements obligatoires, DUERP et culture sécurité. Les leviers pour exercer sans accident grave.',
      'intermediaire', 170, 60
    ) RETURNING id INTO v_module;
    INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
    VALUES (v_formation, v_module, 60, true) ON CONFLICT DO NOTHING;
  END IF;

  -- LEÇON 1 — Code de la route appliqué au transport
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'code-route-transport') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'Code de la route appliqué au transport', 'code-route-transport', 1, 35,
$l$
Le **Code de la route** s'applique à tous, mais le transporteur professionnel doit en maîtriser les **subtilités spécifiques** : permis à points, sanctions aggravées, responsabilités étendues.

:::objectifs
- Maîtriser le système du **permis à points**.
- Connaître les **infractions les plus fréquentes** et leurs sanctions.
- Comprendre la **responsabilité du transporteur** vs celle du conducteur.
:::

## Le permis à points

**Système** : votre permis est affecté de **12 points** (6 pendant la période probatoire de 3 ans, ou 2 ans avec conduite accompagnée).

### Les retraits classiques

| Infraction | Points retirés | Amende |
|---|---|---|
| Excès vitesse < 20 km/h | 1 | 68-135 € |
| Excès vitesse 20-29 km/h | 2 | 135 € |
| Excès vitesse 30-39 km/h | 3 | 135 € |
| Excès vitesse 40-49 km/h | 4 | 1 500 € |
| Excès vitesse ≥ 50 km/h | 6 | 1 500 € + suspension |
| Téléphone tenu en main | 3 | 135 € |
| Stop non respecté | 4 | 135 € |
| Refus de priorité | 4 | 135 € |
| Alcoolémie 0,5-0,8 g/L | 6 | 135 € (puis 750 € au tribunal) |
| Alcoolémie > 0,8 g/L | 6 | Délit (4 500 € + suspension + prison possible) |

### Récupération de points

**Naturelle** :
- 1 point récupéré après 6 mois sans nouvelle infraction.
- Récupération totale après 2 ans (3 ans pour les contraventions 4-5 classes).

**Stage de sensibilisation** :
- **Volontaire** : 4 points récupérés, 1 stage par an maximum.
- **Coût** : ~ 200-280 €.
- **Durée** : 2 jours (14h).

**Obligatoire** :
- Si retrait de **6 points en période probatoire** : stage de récupération obligatoire.

:::caspratique
**Patrick (chauffeur, capital 7 points)** est verbalisé :
- Vitesse +35 km/h en agglomération : 3 points retirés.
- Téléphone en main : 3 points retirés.
- **Capital restant : 1 point**.

**Au prochain manquement** : invalidation du permis. Patrick perd son emploi.

**Que faire ?**
1. Stage de récupération volontaire immédiat (+4 points → 5 points).
2. Vigilance maximale les 6 prochains mois (1 point récupéré naturellement).
3. Formation interne à l'éco-conduite et à la gestion du stress.
4. Carnet de bord pour traçabilité.

**Pour Karim (employeur)** :
- Information écrite à Patrick sur le risque pour son emploi (CDI nécessite permis valide).
- Mise en place d'un suivi régulier des infractions.
:::

## Les responsabilités du transporteur

### En tant que conducteur

**Responsable de** :
- Respect du Code de la route.
- État technique du véhicule (avant départ).
- Arrimage de la marchandise.
- Documents à bord.

### En tant qu'employeur

**Responsable de** :
- Mise à disposition d'un véhicule conforme.
- Vérification du permis du conducteur.
- Formation à la sécurité.
- Suivi des temps de conduite et repos.

**Obligation de moyens** : si vous prouvez avoir mis tous les moyens nécessaires pour éviter une faute, votre responsabilité peut être atténuée.

:::law code="Code du travail" article="L. 4121-1" date="01/01/2024"
L'employeur prend les mesures nécessaires pour assurer la sécurité et protéger la santé physique et mentale des travailleurs.
:::

## Les infractions les plus fréquentes en transport

### 1. Surcharge

**Mesure** : pesée du véhicule par les forces de l'ordre.

**Sanctions** :
- Surcharge < 5 % du PTAC : avertissement.
- Surcharge 5-20 % : amende 135 €.
- Surcharge > 20 % : amende 1 500 € + immobilisation.

**Solution** : vérification systématique avant départ (pesée si gros chargement, calcul si fractionné).

### 2. Mauvais arrimage

**Conséquences possibles** : déversement, accident, marchandise endommagée.

**Sanctions** : amende 4ème classe (135 €) à 5ème classe (1 500 €) selon gravité.

**Solution** : kit d'arrimage professionnel, formation continue.

### 3. Stationnement gênant en livraison

**Souvent inévitable** mais sanctionnable. **Solutions** :
- Arrêt de courte durée (< 5 min) : tolérance souvent.
- Aire de livraison dédiée : s'informer auprès de la mairie.
- Conventions livraisons : avec certaines villes (Paris, Lyon).

### 4. Vitesse en zone urbaine

**Particularité PL/utilitaires** : limites parfois plus basses que les VL.

| Zone | VL | Utilitaire | PL |
|---|---|---|---|
| Ville | 50 km/h | 50 km/h | 50 km/h |
| Hors agglomération | 80 km/h | 80 km/h | 80 km/h |
| Express | 110 km/h | 110 km/h | 90 km/h |
| Autoroute | 130 km/h | 130 km/h | 90 km/h |

## La gestion du parc en sécurité

### Vérifications quotidiennes (à faire faire au chauffeur)

- **Pneus** : pression, état (entaille, usure).
- **Éclairage** : phares, feux stop, clignotants.
- **Niveaux** : huile, liquide refroidissement, lave-glace.
- **Frein de service et de parking**.
- **Documents** à bord (carte grise, assurance, copie licence).

### Vérifications périodiques

- **Contrôle technique** : tous les 2 ans pour VU < 3,5 T (4 ans en première visite).
- **Contre-visite** si non-conformités relevées.
- **Maintenance préventive** : recommandée tous les 10 000-15 000 km (vidange).

:::piege
**Erreur fréquente** : laisser les chauffeurs faire des vérifications visuelles superficielles. **Mettre en place un check-list signée** quotidiennement → preuve en cas d'accident + sécurité réelle.
:::

## En synthèse

| Sujet | Point clé |
|---|---|
| Permis à points | 12 points, récupération naturelle ou stage |
| Alcoolémie | 0,5 g/L sang max, > 0,8 = délit |
| Téléphone | 3 points + 135 € |
| Vitesse | Plafonds spécifiques utilitaires/PL |
| Surcharge | Amende selon % de dépassement |
| Arrimage | Responsabilité du transporteur |
:::conseil
**Politique sécurité écrite** : règlement intérieur + clause contrat travail + formation annuelle. Coût ~ 500 €/an. Bénéfice : préservation des permis, sinistralité réduite, valorisation auprès des clients.
:::
$l$,
$s$
**À retenir**
- Permis à points : 12 points, retrait selon infraction.
- Récupération : 6 mois (1 point), 2 ans (toutes), stage volontaire (+4 points).
- Alcoolémie 0,5 g/L max, > 0,8 g/L = délit pénal.
- Surcharge, arrimage = responsabilité transporteur.
- Vérifications quotidiennes à formaliser dans un check-list signé.
$s$);
  END IF;

  -- LEÇON 2 — DUERP et prévention des risques
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'duerp-prevention') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'DUERP et prévention des risques', 'duerp-prevention', 2, 35,
$l$
Le **DUERP** (Document Unique d'Évaluation des Risques Professionnels) est la **colonne vertébrale** de la prévention en entreprise. Obligatoire depuis 2001 pour tout employeur, c'est aussi un outil concret pour réduire les accidents et les maladies pro.

:::objectifs
- Comprendre l'**obligation** DUERP et son contenu.
- Identifier les **risques propres** au transport léger.
- Mettre en place un **plan de prévention** opérationnel.
:::

## Le DUERP : obligation et contenu

### Cadre légal

:::law code="Code du travail" article="R. 4121-1" date="01/01/2024"
L'employeur transcrit et met à jour dans un document unique les résultats de l'évaluation des risques pour la santé et la sécurité des travailleurs.
:::

### Contenu obligatoire

1. **Inventaire** des risques par unité de travail (chauffeurs, manutention, administration).
2. **Évaluation** : probabilité × gravité.
3. **Hiérarchisation** des risques.
4. **Plan d'action** avec mesures et échéances.
5. **Mise à jour annuelle** OBLIGATOIRE (ou à chaque changement majeur).

### Les unités de travail typiques en transport

| Unité | Risques principaux |
|---|---|
| **Conducteur** | Accident routier, fatigue, TMS |
| **Manutention** | Lombaires, chutes, chocs |
| **Administration** | TMS bureau, stress |
| **Atelier** | Coupures, brûlures, projections |

## Les risques typiques du transport léger

### 1. Risque routier (le n° 1)

**Statistiques** : 1ère cause de mortalité au travail. **80 %** des accidents mortels chez les chauffeurs.

**Facteurs aggravants** :
- Fatigue (longues journées, repos insuffisant).
- Inattention (téléphone, GPS, fatigue cognitive).
- Pression de délai (livraison "à tout prix").
- Météo difficile (pluie, neige, brouillard).
- État technique du véhicule.

**Mesures de prévention** :
- Formation à l'**éco-conduite** (anticipation, vitesse stable).
- **Limitation des heures** au-delà du nécessaire.
- **Maintenance préventive** rigoureuse.
- **Téléphone interdit** au volant (pas même en kit mains-libres pour les long courses).
- **Pause obligatoire** toutes les 2-3 heures.

### 2. Troubles musculo-squelettiques (TMS)

**Causes** : manutention répétée, postures contraintes, vibrations.

**Symptômes** : lombalgies, tendinites, sciatiques.

**Prévention** :
- **Formation gestes et postures**.
- **Aides à la manutention** (transpalette, chariot).
- **Charges limitées** : 25 kg maximum (recommandation INRS).
- **Pauses récupération** régulières.

### 3. Stress et risques psychosociaux

**Sources** : pression délais, conflits clients, isolement, agression possible.

**Conséquences** : burn-out, absentéisme, accidents.

**Prévention** :
- **Communication** régulière.
- **Soutien psychologique** (numéro d'écoute, accompagnement).
- **Procédure agression** (geste à avoir, signalement).

### 4. Risques chimiques

**En transport classique** : limité (carburant, produits d'entretien).

**Si transport ADR** : multiplie les risques (vapeurs, contact, projection).

**Prévention** :
- **EPI** adaptés (gants, masque, lunettes).
- **Fiches de données de sécurité** à bord (ADR).
- **Formation spécifique** ADR si concerné.

### 5. Agression et vol

**Risque réel** en zones urbaines, livraison de valeurs.

**Prévention** :
- **Itinéraires variables** pour éviter la prévisibilité.
- **Caméras embarquées** dissuasives.
- **Procédure d'alerte** (silent alarm).
- **Formation gestion de crise**.

## Construire son DUERP en pratique

### Méthode en 5 étapes

**1. Lister les risques**

Brainstorming avec un échantillon de salariés. Chaque salarié peut-il identifier 3-5 risques de son poste ?

**2. Évaluer chaque risque**

Probabilité × Gravité.

| Probabilité | Gravité | Note |
|---|---|---|
| Improbable (1) | Négligeable (1) | 1 — Faible |
| Possible (2) | Significative (2) | 2-4 — Modéré |
| Probable (3) | Importante (3) | 5-7 — Élevé |
| Très probable (4) | Catastrophique (4) | 8-16 — Critique |

**3. Hiérarchiser**

Trier par note décroissante. Concentrer les efforts sur les risques **élevés** et **critiques**.

**4. Définir un plan d'action**

Pour chaque risque significatif :
- **Mesure** envisagée.
- **Responsable** de la mise en œuvre.
- **Échéance** précise.
- **Budget** prévu.

**5. Mettre à jour annuellement**

Refonte ou ajustement chaque année. Documenter les évolutions.

:::caspratique
**Karim** réalise son 1er DUERP avec 3 chauffeurs.

**Risque routier identifié comme critique** :
- Probabilité : élevée (déplacements quotidiens en zone urbaine + autoroute).
- Gravité : catastrophique (mortalité possible).
- Note : 12 sur 16.

**Plan d'action** :
- **Formation éco-conduite** : 1 jour/an pour tous les chauffeurs (coût 500 €/personne).
- **Maintenance** : suivi rigoureux par GPS et logiciel.
- **Pause toutes les 2h** : règle interne formalisée.
- **Téléphone interdit** au volant : clause contrat travail.
- **Suivi mensuel** des sinistres et infractions.

**Coût annuel** : ~ 3 000 € (formation + outils).
**Bénéfice** : réduction sinistralité de 30-50 % typiquement → économie sur primes d'assurance + arrêts de travail évités.
:::

## Les sanctions du non-DUERP

| Manquement | Sanction |
|---|---|
| Pas de DUERP | Amende 1 500 € (3 000 € pers. morale) par unité de travail |
| DUERP non mis à jour | Idem |
| DUERP non communiqué au CSE | Délit |
| Accident grave + DUERP absent | Faute inexcusable → majoration indemnités |

:::piege
**Faux DUERP** : un document copié-collé d'internet, non personnalisé, sans plan d'action réel = **présumé absent** en cas de contrôle.

**Vrai DUERP** : adapté à votre activité, mis à jour, accompagné d'un plan d'action documenté.
:::

## En synthèse

| Élément | Obligation |
|---|---|
| DUERP | Tout employeur ≥ 1 salarié |
| Mise à jour | Annuelle minimum |
| Plan d'action | Lié au DUERP |
| Communication CSE | Obligatoire si CSE existe |
| Communication salariés | Affichage et accès libre |
| Sanction non-DUERP | 1 500 €/3 000 € par unité de travail |
:::conseil
Faire **rédiger ou auditer** votre DUERP par un IPRP (Intervenant en Prévention des Risques Professionnels) externalisé. Coût : 800-1 500 €. Bénéfice : crédibilité juridique, qualité, sécurité juridique.
:::
$l$,
$s$
**À retenir**
- DUERP obligatoire pour tout employeur (≥ 1 salarié).
- Mise à jour annuelle obligatoire.
- 5 risques majeurs en transport : routier, TMS, stress, chimique, agression.
- Méthode : lister, évaluer (proba × gravité), hiérarchiser, plan d'action, MAJ.
- Faux DUERP = présumé absent → sanctions identiques.
- Sous-traiter à un IPRP = sécurité juridique.
$s$);
  END IF;

  -- LEÇON 3 — Accidents du travail et procédures
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'accidents-travail') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'Accidents du travail : procédures et prévention', 'accidents-travail', 3, 35,
$l$
Un accident du travail bouleverse instantanément l'équilibre d'une TPE. Maîtriser les procédures, c'est réduire l'impact humain, juridique et financier.

:::objectifs
- Maîtriser la **procédure de déclaration** d'un AT.
- Comprendre la **prise en charge** par la CPAM (AT-MP).
- Mettre en œuvre les **mesures correctives** post-accident.
:::

## Définition d'un AT

**Accident du Travail (AT)** : événement soudain à l'origine d'une lésion physique ou psychique, **survenu** :
- Au temps de travail.
- Au lieu de travail.
- Pendant un trajet domicile-travail (accident de trajet, régime distinct).

### AT vs maladie professionnelle (MP)

| Critère | AT | MP |
|---|---|---|
| Cause | Événement ponctuel | Exposition durable |
| Délai | Soudain | Progressif |
| Tableau | Pas nécessaire | Tableaux officiels |
| Exemple | Chute, accrochage | TMS, surdité |

## La procédure de déclaration

### Côté salarié

**Obligation** :
1. **Informer** l'employeur dans les **24 heures**.
2. **Consulter un médecin** (généraliste ou spécialiste).
3. **Obtenir un certificat médical initial** (CMI).

### Côté employeur

**Obligation** :
1. **Déclarer** l'AT à la CPAM dans les **48 heures** (jours ouvrables).
2. Mode : déclaration en ligne sur **net-entreprises.fr**.
3. **Émettre une attestation de salaire** (pour calcul des IJSS).
4. **Conserver** les pièces (CMI, déclaration, attestations).

### Sanctions retard

- Retard déclaration : amende administrative.
- Non-déclaration : majoration des cotisations + responsabilité civile + risque pénal si découvert.

:::caspratique
**Patrick (chauffeur)** glisse en chargeant. Lombalgie aiguë.

**Chronologie** :
- **J0** (lundi 15h) : accident.
- **J0** (lundi 17h) : Patrick téléphone à Karim, signale.
- **J1** (mardi) : Patrick consulte son généraliste, obtient un CMI avec arrêt 7 jours.
- **J2** (mercredi) : Karim envoie la **déclaration AT** sur net-entreprises.fr.
- **J3** : la CPAM accuse réception, ouvre le dossier.
- **J9** : Patrick reprend le travail. Visite de reprise médecine du travail si arrêt > 30 j (pas le cas ici).

**Conséquences financières** :
- Patrick perçoit des **IJSS AT-MP** (60 % salaire les 28 premiers jours, 80 % au-delà).
- Karim peut compléter (selon convention collective, ici 90 % salaire complet pendant les 7 jours).
- L'AT impacte le **taux de cotisation AT-MP** de l'entreprise sur 3 ans (lissage).
:::

## La prise en charge AT-MP

### Cotisation AT-MP

L'entreprise paie chaque mois une **cotisation AT-MP** à la CPAM, taux variable selon :

- **Effectif** : taux mutualisé (< 20 sal.), mixte (20-149), individuel (≥ 150).
- **Sinistralité** : nombre et gravité des accidents sur 3 ans.

**Taux moyen transport routier** : ~ 4-6 % du salaire brut (vs 1-2 % en bureau).

### Réduction du taux

- Maintenir un **bilan AT** faible (peu d'accidents, peu de gravité).
- Mettre en place une **politique de prévention** active.
- Adhérer à des **programmes** type "Prévention AT-MP" CARSAT.

**Bénéfice** : 0,5-1 % de réduction = des milliers d'euros économisés annuellement.

## Les indemnités AT

### Pour le salarié

**Pendant l'arrêt** :
- IJSS AT-MP : 60 % salaire journalier (28 premiers jours), 80 % au-delà.
- Pas de jour de carence (vs maladie classique).

**En cas d'incapacité permanente** :
- **Rente** : si IPP > 10 %.
- **Capital** : si IPP < 10 %.

**En cas de décès** :
- **Capital décès** aux ayants droit.
- **Rente d'orphelin** ou de conjoint.

### Pour l'employeur

**Si AT reconnu** : pas d'impact direct sur la trésorerie immédiate (CPAM prend en charge).

**Effet différé** :
- Augmentation de la cotisation AT-MP.
- Coûts indirects (remplacement, baisse de productivité, gestion administrative).

## La faute inexcusable

**Quand** : l'employeur **avait conscience** du danger et **n'a pas pris les mesures** nécessaires.

**Conséquences** :
- **Majoration de la rente** AT (de 30 % à 50 % en fonction de la gravité).
- **Indemnités complémentaires** (préjudices personnels) : 5 000 à 50 000 €.
- **Procédure pénale** possible (mise en danger d'autrui).

:::piege
**Cas typique** de faute inexcusable :
- Pas de DUERP ou DUERP non à jour.
- Risques identifiés sans mesures correctives.
- Chauffeur qui dépasse les temps de conduite avec accord tacite.
- Pas d'EPI fournis.

→ La preuve de la "conscience du danger" est aisée pour le juge.
:::

## La prévention post-accident

### Étape 1 : Analyse à chaud

**Sous 48h**, analyser les causes :
- Mécaniques (état véhicule).
- Humaines (comportement, formation).
- Organisationnelles (planning, pression).
- Environnementales (météo, route).

**Outil** : arbre des causes (méthode INRS).

### Étape 2 : Plan d'action correctif

Définir les actions à mettre en œuvre pour éviter la récidive :

- Formation complémentaire.
- Modification du processus.
- Investissement en équipement.
- Mise à jour du DUERP.

### Étape 3 : Communication interne

- **Réunion d'équipe** pour analyser collectivement.
- **Affichage** des leçons retenues.
- **Suivi** des actions correctives sur 3-6 mois.

:::caspratique
**Suite à l'AT de Patrick** (lombalgie en chargeant) :

**Analyse des causes** :
- Patrick a chargé un colis de 35 kg seul (limite recommandée 25 kg).
- Pas de transpalette disponible sur ce site client.
- Pas de procédure formalisée pour les charges > 25 kg.

**Plan d'action** :
1. **Achat transpalettes** pour véhicules (500 €/véhicule).
2. **Formation gestes et postures** pour les 3 chauffeurs (1 jour, 1 500 €).
3. **Procédure formalisée** : si charge > 25 kg, demander aide ou refuser.
4. **Mise à jour DUERP** : risque "manutention" avec mesures correctives.

**Coût total** : ~ 3 000 €.
**Bénéfice** : éviter un autre AT (qui pourrait coûter 5 000-10 000 € en coûts directs et indirects, sans parler du préjudice humain).
:::

## En synthèse

| Étape | Délai | Acteur |
|---|---|---|
| Accident | J0 | Salarié + témoins |
| Information employeur | J0-J1 | Salarié |
| Consultation médicale | J0-J1 | Salarié + médecin |
| Déclaration AT | < 48h | Employeur |
| Attestation salaire | < 48h | Employeur |
| Reconnaissance AT | < 30 j | CPAM |
| Analyse causes | < 1 sem | Employeur + IPRP |
| Plan d'action | < 1 mois | Employeur |
:::conseil
**Tenir un registre des AT** même en cas de bénin (sans arrêt). Cela permet de détecter des tendances avant l'accident grave.
:::
$l$,
$s$
**À retenir**
- AT = événement soudain au travail. MP = exposition durable.
- Déclaration employeur sous 48h sur net-entreprises.fr.
- IJSS AT-MP : 60 % puis 80 % du salaire (sans carence).
- Cotisation AT-MP variable selon sinistralité (4-6 % en transport).
- Faute inexcusable si DUERP absent ou risques connus non traités.
- Analyse arbre des causes + plan d'action systématique post-AT.
$s$);
  END IF;

  -- LEÇON 4 — Hygiène, EPI et environnement
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'hygiene-epi-environnement') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'Hygiène, EPI et environnement', 'hygiene-epi-environnement', 4, 30,
$l$
Au-delà du Code de la route et du DUERP, le transporteur a des obligations en matière d'**hygiène**, de **protection individuelle** et d'**environnement**.

:::objectifs
- Connaître les **EPI** obligatoires en transport.
- Maîtriser les règles d'**hygiène** (animaux, produits alimentaires, ADR).
- Comprendre l'**impact environnemental** et les leviers d'action.
:::

## Les EPI (Équipements de Protection Individuelle)

### Obligation employeur

:::law code="Code du travail" article="R. 4321-1" date="01/01/2024"
L'employeur met à la disposition des travailleurs les équipements de travail et les équipements de protection individuelle nécessaires.
:::

**Conséquence** : si vous fournissez les EPI **gratuitement** ET que le salarié refuse de les porter, c'est **lui** qui est en faute.

### EPI typiques en transport

| EPI | Quand |
|---|---|
| **Gilet haute visibilité** | À chaque sortie du véhicule sur la chaussée |
| **Chaussures de sécurité** | Manutention, chargement |
| **Gants** | Manutention de colis |
| **Casque** | Si chantier ou travail sur palette |
| **Lunettes** | Soleil, projections (atelier) |
| **Protection auditive** | Atelier > 80 dB |

### Bonnes pratiques

- **Stocker** les EPI dans chaque véhicule.
- **Renouveler** régulièrement (gants tous les 6-12 mois, gilet 2 ans).
- **Former** les salariés à leur usage correct.
- **Faire signer** une remise de dotation.

## L'hygiène en transport

### Transport de produits alimentaires

**Réglementation** : Règlement européen CE 852/2004 sur l'hygiène alimentaire.

**Obligations** :
- **Compartiment propre** et désinfecté.
- **Température dirigée** (frigo) pour produits frais.
- **Documents** : agrément, certificat ATP (frigos), traçabilité.
- **Formation HACCP** pour les conducteurs.

### Transport d'animaux vivants

**Réglementation** : Règlement CE 1/2005.

**Obligations** :
- **Autorisation de transporteur** (numéro ASV).
- **Compartiment adapté** : aération, séparations, abreuvement.
- **Durée maximale** : 8h (animaux non agréés), 24-29h (animaux agréés selon espèce).
- **Carnet de bord** des transports longs.

### Transport ADR

**Cf. leçon dédiée**. Hygiène = port d'EPI complets, fiches de données de sécurité, plan d'urgence.

## Hygiène du conducteur

### Au poste de travail

- **Pause repas** dans un environnement propre.
- **Hydratation** régulière (1,5-2 L d'eau/jour).
- **Sommeil** réparateur (7-8h/nuit).
- **Activité physique** (lutte contre la sédentarité).

### Risques sanitaires

- **Sédentarité** : marche, étirements aux pauses.
- **Fatigue visuelle** : examens ophtalmologiques réguliers.
- **Stress** : techniques de respiration, ressources psychologiques.

## L'impact environnemental

### Émissions CO2

**Transport routier** = ~ 30 % des émissions CO2 françaises.

**Solutions** :
- **Éco-conduite** : 10-15 % de carburant économisé.
- **Pneus basse consommation** : 5 % de carburant.
- **Optimisation tournées** : 10-20 % de km évités.
- **Renouvellement flotte** : véhicules Euro 6 ou électriques.

### Charte CO2 (ADEME)

**Démarche volontaire** : engagements quantifiés sur 3 ans pour réduire les émissions.

**Bénéfices** :
- Image positive auprès des clients (RFP exigent souvent la charte).
- Subventions ADEME pour certains investissements.
- Baisse des coûts (carburant économisé).

### Recyclage et déchets

- **Pneus usagés** : filière REP (responsabilité élargie producteur).
- **Huiles** : collecte par centres agréés.
- **Batteries** : ECO-PILES.
- **Déchets de bureau** : tri sélectif obligatoire ≥ 11 salariés.

## En synthèse

| Sujet | Obligation |
|---|---|
| EPI | Fournis gratuitement par l'employeur |
| HACCP alimentaire | Si transport de produits alimentaires |
| Agrément ASV | Si transport d'animaux |
| ADR | Si transport de matières dangereuses |
| Charte CO2 | Volontaire, recommandée |
| Tri déchets | Obligatoire ≥ 11 salariés |
:::conseil
**RSE = avantage commercial** : de plus en plus de clients (notamment grands comptes et e-commerçants premium) intègrent la RSE dans leurs critères de choix de transporteur. Investir = se différencier.
:::
$l$,
$s$
**À retenir**
- EPI fournis gratuitement par l'employeur (gilet, chaussures, gants...).
- Transport alimentaire : HACCP + compartiment propre + ATP frigo.
- Transport animal : agrément ASV + carnet bord.
- Charte CO2 ADEME : démarche volontaire, avantage commercial.
- Tri sélectif obligatoire ≥ 11 salariés.
$s$);
  END IF;

  -- LEÇON 5 — Cas pratiques sécurité
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'cas-pratiques-securite') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'Cas pratiques de synthèse — Sécurité', 'cas-pratiques-securite', 5, 35,
$l$
4 cas pratiques mobilisant l'ensemble du module.

## Cas n° 1 — Le chauffeur en alcoolémie

**Situation** : police vous appelle. Votre chauffeur est positif à 1,1 g/L d'alcool en plein service. Il s'agit d'un délit.

**Question** : que faites-vous ?

:::caspratique
**Démarche immédiate** :
1. **Mise à pied conservatoire** par téléphone : "Tu rentres immédiatement, tu es suspendu en attendant la suite."
2. **Récupération du véhicule** par un autre chauffeur ou dépanneur.
3. **Information** de l'assurance (sinistralité aggravée, mais pas d'accident heureusement).
4. **Vérification** : a-t-il déjà eu des problèmes ? L'avez-vous formé ? Est-ce dans le contrat de travail ?

**Procédure de licenciement** :
1. **Convocation** à entretien préalable (LRAR sous 48h).
2. **Entretien** (5 jours minimum après convocation).
3. **Notification du licenciement pour faute grave** :
   - Pas de préavis.
   - Pas d'indemnité de licenciement.
   - Pas d'indemnité de congés payés.

**Risques pour vous (employeur)** :
- **Pénal** : vous pouvez être poursuivi pour "complicité" si négligence prouvée (pas de DUERP, pas de formation, etc.).
- **Civil** : si accident, responsabilité civile engagée.

**Prévention** :
- **Clause** alcoolémie 0 dans contrat travail.
- **Mention** dans règlement intérieur.
- **Formation annuelle** des chauffeurs.
- **Éthylotests** dans les véhicules (obligatoires depuis 2013).

:::

## Cas n° 2 — L'AT lourd

**Situation** : votre chauffeur a un accident grave (collision avec un véhicule particulier). 1 mort dans l'autre véhicule. Le chauffeur est en arrêt 6 mois.

**Question** : conséquences pour votre entreprise ?

:::caspratique
**Conséquences immédiates** :
1. **Procédure pénale** ouverte : homicide involontaire potentiel.
2. **Enquête** : tachygraphe (si > 3,5 T), GPS, arrimage, état du véhicule, alcoolémie/stupéfiants.
3. **Saisie** du véhicule pendant l'enquête.

**Pour votre chauffeur** :
- **AT déclaré** dans les 48h.
- **IJSS AT-MP** pendant l'arrêt.
- **Reclassement** possible à la reprise (visite de reprise médecine du travail).

**Pour vous (employeur)** :
- **Responsabilité civile** : couverte par RC pro.
- **Responsabilité pénale** possible si faute inexcusable :
  - Tachygraphe falsifié, sur-temps de conduite tolérés.
  - Pas de DUERP ou DUERP non à jour.
  - Pas d'entretien véhicule régulier.
- **Coût direct** : franchise assurance (1 000-5 000 €).
- **Coût indirect** : augmentation primes assurance, perte de productivité, gestion procédure.

**À faire** :
1. **Avocat spécialisé** (transport/droit pénal du travail) : 2 000-5 000 € minimum.
2. **Communication** : préparer un message à l'équipe, aux clients (sans détails sur la procédure).
3. **Soutien psychologique** au chauffeur (s'il survit) et à l'équipe.
4. **Analyse complète** des causes pour éviter la récidive.

**Préventif** :
- **DUERP** à jour, plan d'action sécurité visible.
- **Formation continue** sur la sécurité.
- **Bilan AT-MP** annuel avec CARSAT.
:::

## Cas n° 3 — L'inspection du travail

**Situation** : inspection inopinée à 9h. L'inspecteur demande à voir DUERP, registre du personnel, contrats, bulletins de paie.

**Question** : que se passe-t-il si vous n'avez **pas de DUERP** ?

:::caspratique
**Conséquences** :

**Sanction immédiate** :
- **Mise en demeure** de produire un DUERP sous 1 mois.
- En cas de non-production : **amende administrative 1 500 €** (3 000 € pour une personne morale).

**Si AT survient pendant cette période** :
- **Faute inexcusable** automatiquement engagée.
- **Majoration des indemnités** au salarié.
- **Risque pénal** si gravité.

**Que faire dans l'immédiat** :
1. **Reconnaître** l'absence : "Je ne l'ai pas formalisé, c'est une erreur que je vais corriger immédiatement."
2. **Demander un délai** : généralement 1 mois est accordé.
3. **Faire appel à un IPRP** ou au CARSAT pour rédiger un DUERP de qualité.
4. **Mettre en place** un plan d'action visible.

**Investissement** :
- **DUERP rédigé en interne** avec aide IPRP : 800-1 500 €.
- **DUERP fait par un cabinet** : 2 000-3 500 €.

**Bénéfice** : conformité immédiate, sécurité juridique, base solide pour la prévention.
:::

## Cas n° 4 — Le chauffeur qui refuse l'EPI

**Situation** : un chauffeur refuse de porter le gilet haute visibilité lors des arrêts en bord de route. Vous avez fourni l'équipement, mais il dit "ça me gêne".

**Question** : que faites-vous ?

:::caspratique
**Analyse juridique** :
- **Code du travail R. 4321-1** : l'employeur a fourni l'EPI.
- **Code du travail L. 4122-1** : le salarié doit prendre soin de sa sécurité.
- **Refus de port d'EPI** = manquement à l'obligation de sécurité.

**Démarche graduée** :

**1. Rappel à l'ordre verbal** :
- "Tu sais que c'est obligatoire. Quel est le problème ?"
- Comprendre la raison : taille inadaptée, gêne, principe.

**2. Adaptation si motif légitime** :
- Si la taille ne convient pas : **fournir une autre taille**.
- Si modèle inadapté : tester d'autres modèles.

**3. Avertissement écrit** si refus persistant :
- Lettre signée mentionnant le manquement.
- Rappel de la règle et des conséquences.

**4. Sanction disciplinaire** si récidive :
- Mise à pied disciplinaire (1-3 jours sans solde).

**5. Licenciement** si refus persistant :
- Faute professionnelle caractérisée.
- Cause réelle et sérieuse établie si vous avez bien gradé les sanctions.

**Risque pour vous si vous laissez faire** :
- **AT en bord de route** : faute inexcusable + responsabilité pénale.
- Le chauffeur (ou ses ayants droit) pourra vous reprocher de ne pas avoir fait respecter les règles.

**Préventif** :
- **Formation** annuelle sur l'importance des EPI.
- **Affichage** des règles en évidence.
- **Mention dans le règlement intérieur**.
:::

## En synthèse module F

Vous maîtrisez les **4 piliers** de la sécurité en transport :

1. **Code de la route** : permis à points, alcoolémie, responsabilités.
2. **DUERP** : évaluation et plan d'action des risques.
3. **AT et procédures** : déclaration, prise en charge, prévention.
4. **EPI, hygiène, environnement** : obligations quotidiennes.

:::conseil
La **sécurité n'est pas une contrainte** mais un **avantage compétitif** : moins d'arrêts de travail, primes d'assurance réduites, image positive auprès des clients, conformité juridique. Le ROI est largement positif.
:::
$l$,
$s$
**À retenir — Synthèse module F**
- Alcoolémie en service = mise à pied + licenciement faute grave.
- AT lourd : procédure pénale + faute inexcusable possible.
- Pas de DUERP = mise en demeure + 1 500 €/3 000 €.
- Refus EPI = sanction graduée jusqu'au licenciement.
- Sécurité = avantage compétitif (assurance, image, productivité).
$s$);
  END IF;

  RAISE NOTICE 'Module F (Capa - Sécurité) : 5 leçons premium créées.';
END $mod_f$;
