# Design

> Système visuel de MA FORMATION TRANSPORT.
> Source de vérité pour les commandes `$impeccable craft`, `$impeccable polish`,
> `$impeccable colorize`. Synchronisé avec `tailwind.config.ts`.

## Visual Theme

**Premium tech sobre.** Inspiré de Stripe (rythme typographique, sections aérées),
Apple (espace et précision) et Linear (rigueur produit, micro-interactions).

Mode dominant : **clair sur fond ivory** (`#FAFAF7`) pour les surfaces produit.
Le mode sombre `night` est réservé à la vitrine marketing (home, formations,
tarifs) où il porte une identité plus affirmée.

## Color Palette

### Primaires

| Token | Hex | Usage |
|---|---|---|
| `brand-600` | `#2530D9` | Bleu royal du logo. Couleur primaire CTAs, liens, accents |
| `brand-950` | `#0E1240` | Profondeur — texte d'autorité, navigation |
| `signal-500` | `#9FE220` | Vert lime — accent secondaire, validation, hover, micro-anim |
| `night-500` | `#0B0F24` | Fond sombre vitrine, cards premium |
| `ivory` | `#FAFAF7` | Fond produit (dashboard, admin, formateur) |

### Aliases rétro-compat

`navy-*` → identique à `brand-*`
`gold-*` → identique à `signal-*`
*(le code existant utilise `navy/gold` ; aucun renommage nécessaire)*

### Accent par formation (multi-formations)

Chaque formation a sa couleur d'accent (cf. `lib/formations-config.ts`,
champ `accent`). Le `FormationBadge` et le `FormationStripe` la propagent.
**Règle** : la couleur formation prime sur `brand-600` dans tout contexte
identifié à une formation (badge, stripe, headers contextuels).

### Sémantiques

| Token | Hex | Usage |
|---|---|---|
| `emerald-500` | Tailwind | Succès (ex : copie corrigée) |
| `rose-500` | Tailwind | Erreur, retard |
| `amber-500` | `#F59E0B` | Or chaud — uniquement pour les certifications Qualiopi |

### Contrastes WCAG AA

- `brand-600` sur `ivory` → 8.7:1 ✅ AAA
- `signal-500` sur `night-500` → 12.4:1 ✅ AAA
- `slate-600` sur `white` → 7:1 ✅ AAA
- ⚠️ `signal-500` sur `ivory` insuffisant (3.2:1) → utiliser `signal-700` pour
  texte sur fond clair.

## Typography

### Stacks

```css
--font-fraunces: serif éditorial premium (titres, hero, accents)
--font-inter:    sans-serif neutre (corps, UI, navigation)
--font-jetbrains: monospace (code, tokens, données techniques)
```

### Échelle (mobile → desktop)

| Rôle | Mobile | Desktop | Famille | Weight |
|---|---|---|---|---|
| Hero H1 | 40-48 px | 64-80 px | Fraunces | 600 |
| Section H2 | 28-32 px | 40-48 px | Fraunces | 600 |
| Sous-titre H3 | 20-22 px | 24-28 px | Fraunces / Inter | 600 |
| Eyebrow | 11-12 px tracking-wider uppercase | idem | Inter | 600 |
| Body | 15-16 px | 16-17 px | Inter | 400-500 |
| Caption | 12-13 px | 13-14 px | Inter | 500 |

### Règles

- **Display = Fraunces** uniquement pour les vrais titres (h1/h2/h3 hero+section).
  Jamais pour les éléments UI (boutons, labels, navigation).
- **Body = Inter** partout ailleurs.
- **Tracking** : `tracking-tight` (-0.015em) sur les titres ≥ 28 px ;
  `tracking-wider` (+0.05em) sur les eyebrows.
- **Line-height** : 1.1 pour hero, 1.25 pour sections, 1.6 pour body.

## Spacing

Échelle Tailwind (4 px base). Conventions :

- **Sections vitrine** : `py-20 md:py-28` minimum, `py-32` pour les hero.
- **Sections produit** : `py-8 md:py-12`.
- **Cards** : `p-5` (compact) à `p-8` (premium).
- **Stack interne** : `space-y-6` à `space-y-10` pour la hiérarchie d'une section.
- **Gutter horizontal max** : `max-w-6xl` (1152 px) pour la lecture, `max-w-7xl`
  pour les grilles immersives.

## Components

### Surfaces

- **Card produit** : `bg-white border border-navy-100 rounded-2xl shadow-soft`
- **Card premium vitrine** : `bg-white/[0.04] border border-white/10 rounded-3xl backdrop-blur-md`
- **Card highlight** : ajoute `shadow-raised` au hover, élévation +1

### Boutons

- **Primary (gold)** : `bg-signal-500 text-night-900 hover:bg-signal-600` —
  CTA principal exclusif (1 par écran, jamais 2 concurrents)
- **Secondary (navy)** : `bg-brand-900 text-white hover:bg-brand-800`
- **Ghost** : `bg-transparent text-brand-700 hover:bg-brand-50`
- **Hauteur** : 40 px (`h-10`) standard, 44 px (`h-11`) hero, 36 px (`h-9`) compact
- **Radius** : `rounded-xl` (12 px) standard, `rounded-full` pour les pills

### Stripes & Badges formation

- `<FormationStripe>` : 4 px de haut, gradient horizontal de la couleur
  formation. Posé en haut de toute page contextuelle.
- `<FormationBadge>` : pill avec icône + code formation (GOTRM, ECSR…).
  Variants : `chip` / `outline` / `soft` / `solid`.

### Inputs

- `bg-white border border-slate-200 rounded-xl h-10 px-3 focus:ring-2 focus:ring-brand-500/20`
- Labels : `text-sm font-medium text-slate-700 mb-1.5`

## Layout

### Grilles

- **Vitrine** : 12 colonnes sous `max-w-6xl mx-auto px-6`
- **Produit** : 12 colonnes sous `max-w-7xl mx-auto px-4 md:px-6`
- **Cards en grid** : `grid sm:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6`

### Header / Nav

- Vitrine : nav transparent → opaque au scroll, h-16 desktop, h-14 mobile
- Produit : sidebar gauche desktop, drawer mobile

## Motion

### Principes

- **Discrète, fonctionnelle.** Toute animation doit avoir une raison
  (feedback, transition d'état, hiérarchie). Pas de décoratif.
- **Durées** : 150-250 ms pour les UI, 400-700 ms pour les transitions de
  section, ≥ 1 s pour les ambiances de fond.
- **Easing par défaut** : `ease-out` pour entrées, `ease-in-out` pour boucles,
  `cubic-bezier(0.22, 1, 0.36, 1)` pour les transitions premium.
- **`prefers-reduced-motion`** : désactive `marquee-x`, `road-pulse`,
  `spin-slow`, `glow-pulse`, `float-slow`. Conserve les fades essentiels.

### Animations Tailwind disponibles

`fade-up`, `shimmer`, `road-pulse`, `float-slow`, `spin-slow`, `draw-path`,
`marquee-x`, `glow-pulse` (cf. `tailwind.config.ts`).

## Effects

### Ombres

- `shadow-soft` : élévation par défaut des cards
- `shadow-raised` : hover state, modals
- `shadow-float` : éléments flottants (toasts, dropdowns)
- `glow-brand` / `glow-signal` : lueurs autour des accents premium (vitrine)

### Patterns de fond

- `bg-grid-navy` / `bg-grid-night` : grille tech subtile (10 % opacité)
- `bg-mesh-navy` / `bg-mesh-night` : mesh radial premium pour les hero

## Anti-patterns à bannir

- ❌ Plus d'1 CTA primaire (signal) par écran
- ❌ Police display (Fraunces) sur des éléments UI ou < 20 px
- ❌ Couleurs hors palette (ex. orange, magenta) sauf raison sémantique forte
- ❌ Ombres lourdes type `shadow-2xl` ou plus
- ❌ Animations sur événements non-utilisateurs (auto-play)
- ❌ Texte centré sur > 60 caractères de ligne (lisibilité)
- ❌ Card avec gradient saturé (low-cost EdTech vibe)
