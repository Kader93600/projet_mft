# Architecture pédagogique GOTRM (RNCP 40990)

> **Titre Professionnel niveau 5** — Gestionnaire des Opérations de Transport
> Routier de Marchandises. Délivré par le Ministère du Travail (arrêté du
> 16/07/2020, JO du 06/09/2020, date d'effet 24/08/2020).
>
> **Examen final** : 3 épreuves (mise en situation professionnelle écrite
> ~3 h, dossier professionnel à présenter, entretien technique avec jury).
> Pas de QCM officiel — la préparation par QCM/QR est un complément
> pédagogique, pas le format d'examen.

---

## 🏗️ Découpage en 3 blocs de compétences

### **BC01 — Concevoir, organiser et piloter des opérations de transport routier de marchandises**

10 modules. Cœur du métier d'exploitant : de la prise de commande à la
livraison, en passant par la conformité réglementaire et la qualité.

| # | Code | Titre | Durée | Niveau |
|---|---|---|---|---|
| 01 | `gotrm-bc01-01-demande-transport` | Traiter une demande de transport et qualifier le besoin | 180 min | Débutant |
| 02 | `gotrm-bc01-02-contrat-cmr` | Le contrat de transport : CMR, contrat type, droits et obligations | 220 min | Intermédiaire |
| 03 | `gotrm-bc01-03-cotation-offre` | Élaborer une cotation et une offre commerciale | 200 min | Intermédiaire |
| 04 | `gotrm-bc01-04-temps-conduite-r561` | Réglementation sociale R561/2006 et AETR | 240 min | Avancé |
| 05 | `gotrm-bc01-05-documents-douane` | Documents de transport et formalités douanières | 180 min | Intermédiaire |
| 06 | `gotrm-bc01-06-planification-tournees` | Planifier et optimiser les tournées | 220 min | Avancé |
| 07 | `gotrm-bc01-07-transports-specifiques` | Transports spécifiques : TMD/ADR, ATP, exceptionnel | 200 min | Avancé |
| 08 | `gotrm-bc01-08-relation-client-qualite` | Gérer la relation client et la qualité de service | 150 min | Intermédiaire |
| 09 | `gotrm-bc01-09-litiges-indemnisation` | Traiter les litiges, réclamations et indemnisations | 180 min | Avancé |
| 10 | `gotrm-bc01-10-kpi-exploitation` | Piloter avec des indicateurs (taux remplissage, ponctualité, NPS) | 150 min | Intermédiaire |

### **BC02 — Piloter les trafics sous-traités**

2 modules. La sous-traitance est centrale dans le transport (40 à 60 %
du CA chez les commissionnaires).

| # | Code | Titre | Durée | Niveau |
|---|---|---|---|---|
| 11 | `gotrm-bc02-01-appels-offres-soustraitance` | Élaborer un appel d'offres et sélectionner les sous-traitants | 180 min | Avancé |
| 12 | `gotrm-bc02-02-suivi-audit-soustraitants` | Suivre la qualité, la conformité et auditer les sous-traitants | 150 min | Intermédiaire |

### **BC03 — Optimiser les moyens liés à l'activité transport**

2 modules. Pilotage économique du parc et démarche RSE.

| # | Code | Titre | Durée | Niveau |
|---|---|---|---|---|
| 13 | `gotrm-bc03-01-cout-revient-rentabilite` | Calculer un coût de revient kilométrique et arbitrer les investissements | 220 min | Avancé |
| 14 | `gotrm-bc03-02-rse-transition-energetique` | Démarche RSE, transition énergétique et KPI rentabilité | 150 min | Intermédiaire |

---

## 📊 Volumétrie cible totale

| Élément | Cible |
|---|---|
| Modules | **14** |
| Leçons | **~50-60** (3-5 par module selon la densité) |
| QCM reformulés | **~450** (préfixe `mft-2026-gotrm:bcXX-NN:qcm:N`) |
| QR (questions rédigées) | **~80** |
| Quizzes | **~70** (5 par module en moyenne : 4 entraînement + 1 examen blanc) |
| Examens blancs synthétiques | **3** (1 par bloc) + **1 examen blanc final** au format MSP |
| Templates dossier pro | **1** structure type pour la soutenance jury |

---

## 🎯 Format pédagogique des quiz et examens

### Pour les modules

- **Quiz d'entraînement** par leçon : 5-10 QCM, seuil 70 %, sans limite de
  temps.
- **Examen blanc du module** : 10-15 QCM en 30 min, seuil 50 %.

### Pour les blocs (synthétiques)

- **Examen blanc BC01** : 30 QCM + 2 QR en 90 min, seuil 50 %.
- **Examen blanc BC02** : 15 QCM + 1 QR en 45 min, seuil 50 %.
- **Examen blanc BC03** : 15 QCM + 1 QR en 45 min, seuil 50 %.

### Pour la préparation à l'épreuve réelle (MSP)

- **Examen blanc final au format MSP** : 4 dossiers d'exploitation
  enchaînés (demande de transport, planification, étude de tournée,
  qualité), chronométré 3 h. Format identique à l'épreuve réelle mais
  contenu intégralement reformulé.
- **Template dossier professionnel** : structure de 25 pages avec
  consignes pour la soutenance.
- **Banque de questions d'entretien** : 30 questions techniques
  reformulées de jurys passés.

---

## 🗓️ Roadmap de production

| Session | Lot | Modules |
|---|---|---|
| **0** (architecture) | Cleanup + plan | _Cette session_ |
| **1** | Pilote | BC01-01 (demande de transport) |
| **2** | BC01 lot 1 | BC01-02, BC01-03, BC01-04 |
| **3** | BC01 lot 2 | BC01-05, BC01-06, BC01-07 |
| **4** | BC01 lot 3 | BC01-08, BC01-09, BC01-10 |
| **5** | BC02 | BC02-01, BC02-02 |
| **6** | BC03 | BC03-01, BC03-02 |
| **7** | Examens et dossier pro | 3 examens blancs synthétiques + MSP final + template dossier |

**Validation utilisateur entre chaque session.**

---

## 🔖 Convention de nommage

### Slug des modules

`gotrm-bcXX-NN-thematique-courte`

Ex : `gotrm-bc01-04-temps-conduite-r561`

### Préfixe `source_ref` des questions

`mft-2026-gotrm:bcXX-NN:type:N`

Ex : `mft-2026-gotrm:bc01-04:qcm:1`, `mft-2026-gotrm:bc01-04:qr:1`

### Slug des leçons

`gotrm-bcXX-NN-LL-titre-court`

Ex : `gotrm-bc01-04-01-cadre-r561`, `gotrm-bc01-04-02-temps-conduite`

---

## 📎 Sources documentaires

1. **Référentiel officiel RNCP 40990** (France Compétences) — fiche
   publique consultable sur `francecompetences.fr`.
2. **Arrêté du 16 juillet 2020** portant modification du titre
   professionnel "Gestionnaire des opérations de transport routier de
   marchandises".
3. **Code des transports**, **Code de commerce**, **Code du travail**.
4. **Règlement (CE) n° 561/2006** (temps de conduite) et **AETR**.
5. **Convention CMR** (transports internationaux).
6. **Contrat-type général** (décret 99-269 du 6 avril 1999, mis à jour).
7. **Accord ADR** pour les TMD.
8. **Accord ATP** pour les denrées périssables.
9. **Mises en situation professionnelle réelles** — utilisées comme
   inspiration pédagogique uniquement, contenu intégralement reformulé
   (noms, chiffres, contextes, dates), conformément à la consigne de
   l'utilisateur.

---

## ⚠️ Points de vigilance

- **Pas de copie brute** des sujets MSP fournis : changement
  systématique des noms, montants, dates et contextes.
- **Aucun contenu manuscrit** ou annotation des PDFs ne sera repris.
- **Niveau d'exigence aligné sur le niveau 5 RNCP** : cas pratiques
  réalistes, vocabulaire professionnel, mises en situation crédibles.
- **Cohérence avec Capa-3,5T** : convention de nommage homogène,
  format de quiz / examens identique pour faciliter la lecture pour
  le stagiaire.
