# Import des QR du CCP1 GOTRM

> Pipeline automatisé pour générer les 66 Questions Rédigées du CCP1
> depuis les PDFs client fournis dans `QR_CCP1_GOTRM/`.

## TL;DR

```bash
npx tsx scripts/import-ccp1-qr.ts
```

Le script fait TOUT :

1. **Parse** les 89 PDFs (66 exercices + 23 annexes)
2. **Upload** les annexes vers Supabase Storage (bucket `question-attachments`, préfixe `ccp1-v2/`)
3. **Supprime** les anciens QR CCP1 en base (livret historique + ancienne v2 si présente)
4. **Insère** les 66 nouveaux QR dans `question_bank` + les 23 attachments dans `question_attachments`
5. **Génère** `supabase/gotrm_ccp1_qr_v2.sql` en backup git pour traçabilité

## Pré-requis

- `.env.local` doit contenir :
  - `NEXT_PUBLIC_SUPABASE_URL`
  - `SUPABASE_SERVICE_ROLE_KEY`
- Le dossier source doit exister à `/Users/abdelkader/Downloads/QR_CCP1_GOTRM`
  avec la structure `Chapitre_NN/ChNN_Exercice_X.Y.pdf` (+ éventuellement
  `ChNN_Exercice_X.Y_Annexe.pdf`).
- Les modules `gotrm-chNN-...` doivent déjà exister en base
  (cf. `supabase/gotrm_chNN_v4_livret.sql`).

## Stratégie d'identification

- Chaque QR est identifié par un `source_ref` unique :
  `mft-2026-gotrm-ccp1-qr-v2:chNN:exX.Y`
- Le tag `['CCP1', 'ChNN', 'QR-v2']` est appliqué pour faciliter le filtrage
  côté admin/statistiques.
- Les anciens QR du livret (`mft-2026-gotrm-livret:chNN:qr:N`) sont
  supprimés lors du reset (cascade sur attachments et quiz_question_bank).

## Format du statement HTML

Chaque QR est rendu avec 3 sections visuellement distinctes :

- **Bandeau titre** (navy + signal-lime accent) : numéro de chapitre et
  d'exercice + titre court.
- **Contexte** (bleu) : énoncé du cas pratique, entreprise, situation.
- **Travail à réaliser** (vert) : liste numérotée des consignes.
- **Bandeau annexe** (orange, si pertinent) : invite à consulter le PDF
  joint.

Les **tableaux** détectés dans les PDFs (alignement par espaces) sont
préservés en `<pre>` monospace pour rester lisibles.

## Sécurité / RLS

- Le bucket `question-attachments` est **privé** : les stagiaires y
  accèdent uniquement via signed URL (cf. `app/quiz/[id]/page.tsx`).
- Policy RLS sur `question_attachments` : un stagiaire ne voit l'annexe
  que si la question est rattachée à une formation où il est inscrit.

## UI

Le quiz-runner (`app/quiz/[id]/quiz-runner.tsx`) sait déjà afficher les
attachments PDF en iframe natif. Les images / documents sont gérés
comme cartes cliquables. La détection est automatique sur `kind` :
`image`, `pdf`, `document`, `other`.

## Idempotence

Le script peut être rejoué autant de fois que nécessaire :

- Upload Storage : `upsert: true` → remplace le fichier s'il existe.
- DELETE puis INSERT : aucun doublon possible en base.

## Rejouer sur une nouvelle base

Le fichier `supabase/gotrm_ccp1_qr_v2.sql` contient tout (DELETE + INSERT
+ HTML déjà rendu) et peut être exécuté seul via psql :

```bash
psql "$SUPABASE_DB_URL" -f supabase/gotrm_ccp1_qr_v2.sql
```

⚠️ Le SQL référence les `storage_path` des annexes. Si la base est neuve,
il faut d'abord uploader les annexes — le plus simple est de relancer
le script TS qui fait tout.

## Statistiques actuelles

- **66 QR** en base (`type='qr'`, `tags @> ARRAY['CCP1','QR-v2']`)
- **23 annexes PDF** dans le bucket `question-attachments`
- Répartition : Ch04 (10 QR), Ch02 (7), Ch05 (5), Ch12 (5), Ch01/06/09 (4),
  Ch03/07/08/10/11/13/15 (3), Ch14/16/17 (2)
