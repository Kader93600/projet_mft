# Vidéos d'introduction Capacité ≤ 3,5 t

> 6 vidéos intro (une par module A à F) hébergées dans Supabase Storage
> privé, affichées en haut du détail module.

## TL;DR

```bash
# 1. Applique la migration DB une seule fois (via Supabase Studio)
psql … -f supabase/2026_05_17_module_intro_video.sql

# 2. Dépose tes MP4 dans ~/Downloads/Capa_Intros/ (convention de nommage : capa-a.mp4, capa-b.mp4, …)

# 3. Upload + rattachement aux modules
npx tsx scripts/import-capa-intro-videos.ts
```

## Architecture

| Élément | Détail |
|---|---|
| Stockage | Bucket Supabase `module-intro-videos` (privé, 100 MB max/fichier) |
| Path | `capa/module-{a..f}.mp4` |
| DB | 3 colonnes sur `modules` : `intro_video_path`, `intro_video_label`, `intro_video_duration_s` |
| RLS Storage | Lecture stagiaire si inscrit à la formation `capacite-3-5t`, lecture/écriture admin |
| Accès | Signed URL 1h générée serveur-side à chaque chargement de page (jamais cachée CDN) |
| UI | `<ModuleIntroVideo />` Server Component, player HTML5 natif, aspect 16:9 |

## Conventions de nommage acceptées

Le script détecte automatiquement la lettre du module depuis le nom du fichier (priorité dans l'ordre) :

1. `capa-module-a.mp4`, `capa_module_a.mp4`
2. `capa-a.mp4`, `capa_a.mp4`, `capa a.mp4`
3. `module-a.mp4`, `module_a.mp4`
4. `a.mp4`, `b.mp4`, …
5. Tout nom contenant `-a-`, `_a_`, `_a.`, `-a.`

Les extensions acceptées : `.mp4`, `.m4v`, `.webm`, `.mov`

## Modules ciblés

| Lettre | Slug | Titre |
|---|---|---|
| A | `capa-droit-civil-commercial` | Droit civil et commercial |
| B | `capa-entreprise-activite-commerciale` | L'entreprise et son activité commerciale |
| C | `capa-cadre-reglementaire-transport` | Cadre réglementaire du transport |
| D | `capa-activite-financiere` | Activité financière (compta, bilan) |
| E | `capa-salaries-droit-social` | Salariés et droit social |
| F | `capa-securite` | Sécurité (FIMO/FCO, ADR, véhicule) |

## Mettre à jour une vidéo

Re-déposer le fichier (même nom) dans le dossier source et relancer le script. L'option `upsert: true` du Storage remplace l'ancienne version.

## Définir un dossier source différent

```bash
CAPA_VIDEOS_DIR=/chemin/personnalisé npx tsx scripts/import-capa-intro-videos.ts
```

## Personnaliser le libellé sous la vidéo

Édite `MODULE_LABEL_BY_LETTER` dans `scripts/import-capa-intro-videos.ts` ou modifie directement la colonne `modules.intro_video_label` via SQL.

## Sécurité

- Bucket **privé** : pas d'URL publique, signed URL 1h par chargement.
- Policy RLS Storage : un stagiaire ne voit la vidéo que si la formation Capa figure dans `has_formation_access(auth.uid(), 'capacite-3-5t')`.
- Téléchargement direct non bloqué (signed URL transmise au `<video src>`), mais expire après 1h.

## Si tu veux passer en hébergement spécialisé plus tard

Le composant `<ModuleIntroVideo />` est conçu pour pouvoir basculer facilement vers Mux / Bunny / Cloudflare Stream : il suffit de changer la logique de `createSignedUrl()` en remplaçant par un appel à l'API tiers retournant une URL `.m3u8` (HLS). Le tag `<video>` natif supporte HLS sur Safari (et hls.js sur Chrome / Firefox).
