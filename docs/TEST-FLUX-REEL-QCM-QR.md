# Guide de test — Flux réel quiz QCM + QR end-to-end

Ce guide décrit le parcours complet à tester avant validation par le client. Il
couvre **passage stagiaire**, **correction formateur** et **finalisation du résultat**.

---

## 0. Pré-requis

### Données minimales en base
- 1 formation `capacite-3-5t` active
- Banque chargée (`supabase/capa_questions_premium.sql` exécuté → 80+ questions)
- 1 quiz mixte (QCM + QR) lié à la formation
- 3 comptes :
  - **Stagiaire** : enrôlé sur la formation
  - **Formateur** : assigné à la formation via `trainer_formations`
  - **Admin** : pour audit final

### Création rapide d'un quiz mixte de test
Aller dans `/admin/quizzes/new` :
1. Titre : *"Examen blanc Capacité -3,5T (test)"*
2. Type : `examen`
3. Lier à la formation via `/admin/formations/[slug]/quiz`
4. Ajouter 5 QCM + 2 QR depuis la banque (`/admin/banque/quiz/[id]`)
5. Activer le timer (45 min) + seuil de validation (60 %)

---

## 1. Passage stagiaire

### 1.1 Identification visuelle
- [ ] Connexion stagiaire → `/quiz/[id]`
- [ ] **FormationStripe** visible en haut de page (couleur de la formation)
- [ ] **FormationBadge** affiché à côté du badge de mode (entraînement/examen)
- [ ] Le titre affiche bien le nom du quiz et l'icône de la formation

### 1.2 Flux QCM
- [ ] Lancer le quiz → bouton "Commencer"
- [ ] Cliquer sur les choix → sélection visible immédiatement
- [ ] Bouton "Suivant" actif uniquement si une réponse est sélectionnée
- [ ] Timer décompte correctement (si activé)

### 1.3 Flux QR
- [ ] Atteindre une question QR → textarea s'affiche
- [ ] Saisir une réponse de plusieurs lignes
- [ ] Soumettre → la réponse est persistée (RPC `submit_qr_response`)
- [ ] Possibilité de revenir en arrière sans perdre la saisie

### 1.4 Soumission finale
- [ ] À la dernière question, bouton "Terminer le quiz"
- [ ] Si quiz contient des QR → message **"En attente de correction"**
- [ ] Statut `quiz_attempts.status` = `awaiting_review` (vérifier via SQL)
- [ ] Stagiaire redirigé vers `/quiz/results/[attemptId]` avec message d'attente

### 1.5 Vérifications BDD
```sql
SELECT id, status, score_qcm, score_qr, score_total
FROM quiz_attempts WHERE id = '<attempt_id>';

SELECT question_id, response_text
FROM qr_responses WHERE attempt_id = '<attempt_id>';
```
- [ ] Une ligne `qr_responses` par QR
- [ ] `score_qcm` calculé, `score_qr` NULL, `status='awaiting_review'`

---

## 2. Correction formateur

### 2.1 Notification
- [ ] Connexion formateur → `/formateur`
- [ ] Carte "Copies à corriger" affiche +1
- [ ] Notification (email + in-app) `new_copy_to_grade` reçue

### 2.2 Tableau des copies
- [ ] Aller sur `/formateur/corrections`
- [ ] La copie apparaît avec **FormationBadge** identifiant la formation
- [ ] Filtres par formation fonctionnels
- [ ] Clic sur la copie → `/formateur/corrections/[attemptId]`

### 2.3 Page de correction
- [ ] **FormationStripe** visible en haut
- [ ] Métadonnées : stagiaire, quiz, date, score QCM partiel
- [ ] Pour chaque QR :
  - [ ] Énoncé + barème (`scoring_grid`) visibles
  - [ ] Réponse-modèle (`expected_answer`) visible (aide formateur)
  - [ ] Réponse stagiaire affichée
  - [ ] Champ note (0 → max_score) + feedback texte
- [ ] Bouton "Enregistrer brouillon" (par QR)
- [ ] Bouton "Valider toutes les corrections" (par lot)

### 2.4 Soumission de la correction
- [ ] Noter chaque QR + feedback
- [ ] Cliquer "Finaliser la correction" → RPC `finalize_quiz_grading`
- [ ] Statut bascule à `graded`
- [ ] `score_qr` calculé, `score_total` = 70 % QCM + 30 % QR (par défaut)
- [ ] Email "Copie corrigée" envoyé au stagiaire

---

## 3. Validation résultat (côté stagiaire)

- [ ] Stagiaire reçoit notification "Votre copie est corrigée"
- [ ] `/quiz/results/[attemptId]` affiche désormais :
  - [ ] Score total
  - [ ] Détail QCM (questions, bonnes réponses, explications)
  - [ ] Détail QR (sa réponse, note, feedback formateur, réponse-modèle)
  - [ ] Statut "Validé" ou "Échec" selon `pass_threshold`
- [ ] **FormationStripe** + **FormationBadge** affichent la bonne formation

---

## 4. Audit admin

- [ ] `/admin/quizzes/[id]` → la copie apparaît dans l'historique
- [ ] `/admin/stats` → KPI mis à jour (taux de réussite, moyenne)
- [ ] `/super-admin/audit` → entrée pour `finalize_quiz_grading`

---

## 5. Cas limites à tester

| Cas | Attendu |
|---|---|
| Quiz 100 % QCM → soumission | `status=completed` direct, pas de file de correction |
| Quiz 100 % QR → soumission | `status=awaiting_review`, score_qcm = 0 |
| Stagiaire abandonne en cours (timer expire) | `status=completed`, QR non répondues = 0 |
| Formateur corrige partiellement puis quitte | Brouillon conservé en `qr_responses.grader_score_draft` |
| Stagiaire repasse le même quiz | Nouvelle ligne `quiz_attempts`, ancien résultat consultable |
| Question QR vide à la soumission | Acceptée, score 0, formateur peut le valider tel quel |

---

## 6. Checklist finale avant signoff client

- [ ] Tous les points 1.x à 4 cochés en environnement préprod
- [ ] Captures d'écran consignées dans `docs/preuves/`
- [ ] Logs Supabase sans erreur 5xx pendant le test
- [ ] Délai moyen passage → résultat corrigé < 24 h documenté
- [ ] Email/notification testés avec un vrai compte SMTP

---

## Références techniques

- Schéma : `supabase/schema.sql`, `supabase/qr_grading.sql`
- Composants visuels : `components/formation/*`
- Helper résolveur : `lib/formation-resolver.ts`
- RPC clés : `submit_qr_response`, `mark_attempt_awaiting_review`,
  `grade_qr_response`, `finalize_quiz_grading`
- Pondération par défaut : 70 % QCM + 30 % QR (configurable via
  `quizzes.qcm_weight` / `quizzes.qr_weight`)
