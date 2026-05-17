# IA tuteur — Installation Phase 1 (foundation)

> Sprint 3 du plan P3 #1 « Pédagogie augmentée » — étape 1/2.
> Cette phase met en place l'infrastructure (DB, SDK, ingestion). La
> phase 2 (chat UI, endpoint streaming, correction QR) suivra.

---

## Pré-requis

1. **Compte Anthropic** avec une clé API (`sk-ant-…`).
   Crée-la sur https://console.anthropic.com/settings/keys.
   Coût estimé : ~20 €/mois pour 50 stagiaires actifs Premium.

2. **Compte OpenAI** avec une clé API (`sk-…`).
   Crée-la sur https://platform.openai.com/api-keys.
   Utilisé uniquement pour les embeddings (`text-embedding-3-small`).
   Coût : ~0,01 €/run complet d'ingestion (négligeable).

3. **Supabase** : extension `vector` (pgvector) activable côté projet.

---

## Étape 1 — Variables d'environnement

Ajoute dans `.env.local` (et dans Vercel pour la prod) :

```bash
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
FEATURE_AI_TUTOR=true
```

Redémarre `npm run dev` après l'ajout.

---

## Étape 2 — Migration DB

Sur Supabase Studio (SQL editor), exécute dans l'ordre :

```sql
-- 1. Activer pgvector (si pas déjà fait dans un autre projet)
CREATE EXTENSION IF NOT EXISTS vector;

-- 2. Exécuter la migration
\i supabase/2026_05_18_ia_tutor.sql
```

ou colle directement le contenu du fichier dans l'éditeur.

Vérifie ensuite :

```sql
-- Tables créées
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'lesson_chunks','tutor_conversations',
    'tutor_messages','tutor_quotas'
  );
-- Doit retourner 4 lignes.

-- Extension active
SELECT extname FROM pg_extension WHERE extname = 'vector';
-- Doit retourner 1 ligne.

-- RPC search disponible
SELECT proname FROM pg_proc WHERE proname = 'search_lesson_chunks';
```

---

## Étape 3 — Ingestion des embeddings

Avec les leçons existantes en DB, lance :

```bash
# Toutes les formations (par défaut)
npx tsx scripts/ingest-lessons-embeddings.ts

# Limité à une formation
npx tsx scripts/ingest-lessons-embeddings.ts --formation=gotrm-rncp-40990

# Rebuild complet (recommandé pour les premiers tests)
npx tsx scripts/ingest-lessons-embeddings.ts --rebuild

# Dry-run pour vérifier le découpage sans toucher la DB
npx tsx scripts/ingest-lessons-embeddings.ts --dry-run
```

Compte ~30 s à ~2 min selon la taille du catalogue.

Vérification post-ingestion :

```sql
SELECT count(*) FROM lesson_chunks;
SELECT lesson_id, count(*) AS chunks
FROM lesson_chunks
GROUP BY lesson_id
ORDER BY chunks DESC
LIMIT 10;
```

---

## Étape 4 — Re-build de l'index ivfflat (optionnel, après gros import)

Si tu as ingéré >10 000 chunks, le pruning de l'index ivfflat est
sub-optimal. Re-construis-le :

```sql
REINDEX INDEX public.lesson_chunks_embedding_ivfflat_idx;
```

---

## Vérification finale

Une petite sanity-check pour s'assurer que la recherche sémantique
fonctionne :

```sql
-- Génère un faux embedding (zéros) — ne donnera pas de bonne pertinence
-- mais la requête doit s'exécuter sans erreur :
SELECT lesson_title, similarity
FROM search_lesson_chunks(
  array_fill(0::real, ARRAY[1536])::vector(1536),
  3,
  null
);
```

Pour un test réel, lance l'endpoint `/api/tutor/ask` (à venir en Phase 2)
ou écris un mini script qui appelle `embedOne` puis `search_lesson_chunks`.

---

## Architecture des fichiers livrés dans cette phase

```
supabase/2026_05_18_ia_tutor.sql           # Migration pgvector + tables tutor
lib/tutor/access.ts                        # Gate Premium (getTutorAccess)
lib/tutor/claude.ts                        # Wrapper Anthropic SDK
lib/tutor/embeddings.ts                    # Wrapper OpenAI embeddings
lib/tutor/prompts.ts                       # System prompts (chat + QR)
lib/tutor/chunking.ts                      # Découpage markdown → chunks
scripts/ingest-lessons-embeddings.ts       # Pipeline d'ingestion RAG
lib/packs.ts                               # Ajout feature "ai_tutor_chat"
```

---

## Prochaine étape (Phase 2)

Une fois cette foundation déployée et l'ingestion réussie :

1. `app/api/tutor/ask/route.ts` — endpoint streaming SSE
2. `components/tutor/tutor-fab.tsx` — bouton flottant (FAB)
3. `components/tutor/tutor-drawer.tsx` — drawer chat avec citations
4. `app/tuteur/page.tsx` — version plein écran mobile
5. `app/api/tutor/grade-qr/route.ts` — correction QR auto
6. `app/admin/qr-review/page.tsx` — file de validation formateur
7. Rate limit + modération pré-prompt
8. Tests E2E

À planifier dans une session dédiée (3-5 j).
