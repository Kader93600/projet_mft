# Import des questions Capacité de transport léger -3,5T

Procédure complète pour importer les **694 QCM + 155 QR** des PDFs officiels
dans la banque de questions de la plateforme.

---

## Étapes

### 1. Pré-requis BDD (à jouer une seule fois)

Dans le SQL Editor Supabase, dans cet ordre :

```
supabase/permissions_v2_step1.sql      ← (déjà fait — enum super_admin)
supabase/permissions_v2_step2.sql      ← (déjà fait — helpers + audit)
supabase/formations_v2.sql             ← (déjà fait — table formations seedée)
supabase/question_bank.sql             ← Banque de questions + RPC examen aléatoire
supabase/qr_grading.sql                ← Workflow correction différée des QR
supabase/rls_formation_scoping.sql     ← Restrictions par formation (à jouer après mapping)
```

### 2. Parser les PDFs (script Python)

```bash
# Pré-requis : pypdf installé
pip3 install --user pypdf

# Lancement
cd /Users/abdelkader/Desktop/projet_gotrm
python3 scripts/parse_capa_pdf.py
```

Sorties générées dans `scripts/output/` :

- `capa_qcm.json` — 699 QCM extraits avec module + énoncé + 4 choix
- `capa_qr.json` — 155 QR extraites avec module + énoncé complet
- `capa_import.sql` — SQL prêt à exécuter (copié dans `supabase/capa_questions_import.sql`)

### 3. Importer en BDD

Dans le SQL Editor, joue :

```
supabase/capa_questions_import.sql
```

Toutes les questions sont insérées avec :

- `formation_id` = celui de `capacite-3-5t`
- `type` = `'qcm'` ou `'qr'`
- `tags` = `['module-X', '<thème>', 'capa-3-5t']`
- `source_ref` = `'base-2026:qcm:N'` ou `'base-2026:qr:N'` (traçabilité)
- **`active = false`** (les questions ne sont PAS en circulation tant qu'un
  formateur ne les a pas validées)
- Pour les QCM : `choices[].is_correct = false` partout (à valider)

### 4. Valider les QCM (page admin)

Connecte-toi en admin ou super_admin, puis va sur :

```
/admin/banque-questions
→ Cliquer sur "Capacité ≤ 3,5 t"
→ "À valider — 699 QCM"
```

Pour chaque QCM :

1. Sélectionne la **bonne réponse** parmi a/b/c/d
2. Clique sur **"Valider et activer"**
3. La question disparaît de la liste et entre en circulation

Tu peux :

- Filtrer par module (A, B, C, D, E, F)
- Passer une question (revenir plus tard)
- **Écarter** une question (la garder hors circulation définitivement)

### 5. Activer les QR

Les **155 QR** n'ont pas de bonne réponse à cocher (correction manuelle par
le formateur de chaque copie via le workflow `qr_grading.sql`). Pour les
activer en lot :

```sql
UPDATE public.question_bank
   SET active = true
 WHERE type = 'qr'
   AND tags @> ARRAY['capa-3-5t'];
```

Ou via une page de revue rapide à venir (sprint suivant).

---

## Reformulation et anti-copier-coller

Pour éviter un rendu trop "officiel copié-collé" :

- **Énoncés** : nettoyés (espaces, ponctuation), normalisés (`?` ou `:` final)
- **Choix** : capitalisation initiale, suppression de la ponctuation finale
- **Source tracée** dans `source_ref` : on garde le lien avec la version
  officielle pour audit.
- Le champ `reformulated_at` + `reformulated_by` est rempli au moment de la
  validation par le formateur.

Pour aller plus loin (variations de tournure plus poussées), il faudrait
brancher un LLM (Claude / GPT) avec une clé API — actuellement en pause
selon le cahier des charges.

---

## Statistiques d'extraction

| Module | QCM extraits | QR extraites |
|---|---:|---:|
| A — Droit civil et commercial | 175 | 0 |
| B — Activité commerciale | 24 | 0 |
| C — Cadre réglementaire | 176 | 24 |
| D — Activité financière | 92 | 51 |
| E — Salariés | 160 | 50 |
| F — Sécurité | 72 | 30 |
| **Total** | **699** | **155** |

→ Léger surcompte (+5 sur les QCM) tolérable, à vérifier ponctuellement
lors de la validation (doublons éventuels dans la numérotation source).

---

## Génération d'examens blancs

Une fois les questions validées et actives, on peut générer un examen blanc
aléatoire via la fonction SQL `generate_random_exam` :

```sql
-- Examen blanc capacité -3,5T : 30 QCM + 5 QR, difficulté moyenne et difficile
SELECT * FROM public.generate_random_exam(
  'capacite-3-5t',
  30,           -- nombre de QCM
  5,            -- nombre de QR
  ARRAY['moyen','difficile']::text[],
  NULL          -- modules (NULL = tous)
);
```

Cette fonction retournera N+M questions tirées aléatoirement, à insérer
dans `quiz_question_bank` pour figer un examen, ou à utiliser en mode
"static" si on veut conserver la même sélection.

---

## Maintenance

- **Mise à jour de l'examen officiel** : nouveau parsing, INSERT en BDD avec
  `ON CONFLICT DO NOTHING` (le `source_ref` UNIQUE évite les doublons).
- **Désactiver une question obsolète** : page admin → "Écarter".
- **Modifier l'énoncé** : passer par une page d'édition (à créer en S7.7).
