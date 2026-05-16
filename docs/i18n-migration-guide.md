# Guide de migration i18n — MA FORMATION TRANSPORT

> 🌍 Comment ajouter des traductions dans une page existante.
> Foundation `next-intl` posée le 16 mai 2026.

---

## 🧠 Architecture en 30 secondes

```
i18n/request.ts          ← résout la locale (cookie NEXT_LOCALE → header → fr par défaut)
messages/fr.json         ← dictionnaire français (langue principale)
messages/en.json         ← dictionnaire anglais
app/layout.tsx           ← <NextIntlClientProvider> wrappe toute l'app
components/locale-toggle ← toggle FR/EN dans le header
```

**Pas de routing `[locale]/`** : les URLs restent identiques (`/login`, pas `/fr/login`). La langue est déterminée serveur-side via cookie.

---

## ✅ Pages déjà migrées (référence)

| Page | Pattern |
|---|---|
| `app/login/page.tsx` | Server Component + `getTranslations` |
| `app/offline/page.tsx` | Server Component + `getTranslations` |

Vous pouvez ouvrir ces 2 fichiers comme **modèles** pour migrer les autres.

---

## 📋 Migrer une page (Server Component / RSC)

### Étape 1 — Importer les helpers

```tsx
import { getTranslations } from "next-intl/server";
```

### Étape 2 — Rendre la fonction async (si elle ne l'est pas déjà)

```tsx
// Avant
export default function MaPage() { … }

// Après
export default async function MaPage() {
  const t = await getTranslations("nav");
  …
}
```

### Étape 3 — Remplacer les strings en dur

```tsx
// Avant
<h1>Tableau de bord</h1>

// Après
<h1>{t("dashboard")}</h1>
```

### Étape 4 — Ajouter la clé dans messages/

Dans **`messages/fr.json`** :

```json
{
  "nav": {
    "dashboard": "Tableau de bord"
  }
}
```

Dans **`messages/en.json`** :

```json
{
  "nav": {
    "dashboard": "Dashboard"
  }
}
```

⚠️ Les 2 fichiers doivent avoir **exactement les mêmes clés**, sinon `useTranslations` throw côté EN.

---

## 📋 Migrer un Client Component

```tsx
"use client";
import { useTranslations } from "next-intl";

export function MonBouton() {
  const t = useTranslations("common");
  return <button>{t("save")}</button>;
}
```

---

## 🔢 Pluriels (ICU MessageFormat)

```tsx
const t = useTranslations("dashboard");
<p>{t("lessonsDone", { done: 5, total: 10 })}</p>
```

Dans `messages/fr.json` :
```json
{
  "dashboard": {
    "lessonsDone": "{done} / {total} leçons"
  }
}
```

Pour les pluriels variables :
```json
{
  "dashboard": {
    "modulesCount": "{count, plural, =0 {Aucun module} =1 {1 module} other {# modules}}"
  }
}
```

---

## 🗂️ Convention de nommage des clés

Pour éviter le chaos, organisez par **scope** :

| Préfixe | Quoi | Exemple |
|---|---|---|
| `common.*` | Strings universelles | `save`, `cancel`, `loading` |
| `nav.*` | Labels de navigation | `dashboard`, `modules` |
| `auth.*` | Login / signup / reset | `loginButton`, `email` |
| `dashboard.*` | Page dashboard stagiaire | `welcome`, `myProgress` |
| `quiz.*` | Runner de quiz | `start`, `passed` |
| `footer.*` | Liens légaux du footer | `legal`, `cgu` |
| `a11y.*` | Aria-labels accessibilité | `openMenu`, `notifications` |
| `<page>.*` | Strings spécifiques à une page | `tarifs.heroTitle` |

---

## 🎯 Ordre de migration suggéré (par impact)

### Tier 1 — Visibilité maximale (à faire en priorité)
1. ✅ `app/login/page.tsx` — fait
2. `app/signup/page.tsx`
3. `app/forgot-password/page.tsx`
4. `app/reset-password/page.tsx`
5. `app/page.tsx` (home publique)
6. `app/tarifs/page.tsx`
7. `components/cookie-banner.tsx`

### Tier 2 — Navigation (impact sur toutes les pages connectées)
8. `components/nav-groups.ts` — labels du menu sidebar
9. `components/app-shell.tsx` — strings de la topbar
10. `components/mobile-nav-sheet.tsx`

### Tier 3 — Pages stagiaire principales
11. `app/dashboard/page.tsx`
12. `app/modules/page.tsx`
13. `app/exercices/page.tsx`
14. `app/examens-blancs/page.tsx`
15. `app/quiz/[id]/quiz-runner.tsx`
16. `app/quiz/results/[attemptId]/page.tsx`

### Tier 4 — Pages secondaires
17. `app/messages/`, `/accompagnement/`, `/sessions/`, etc.
18. `app/admin/*` (interface admin — peut rester en FR uniquement)
19. `app/formateur/*` (interface formateur)

---

## 🛠️ Workflow pratique pour migrer une page

```bash
# 1. Identifier toutes les strings en dur dans le fichier
grep -E '">[^<]*[a-zA-ZÀ-ÿ]' app/ma-page/page.tsx

# 2. Ouvrir la page + le dictionnaire fr.json en split view

# 3. Pour chaque string en dur :
#    - Choisir une clé ('action.label' ou 'page.section.element')
#    - Ajouter dans fr.json ET en.json (DEFAULT: tradLittérale)
#    - Remplacer dans la page par t("scope.key")

# 4. Tester
npm run typecheck   # Vérifier qu'on n'a rien cassé
npm run build       # Build avec next-intl

# 5. Vérifier visuellement en dev
npm run dev
# → Toggle FR/EN dans le header → le texte change
```

---

## ⚠️ Pièges à éviter

### ❌ Ne PAS faire
```tsx
// Concaténation de strings traduits = mauvaise idée
<p>{t("hello")} {userName} {t("welcome")}</p>
```

### ✅ À faire
```tsx
// ICU placeholders
<p>{t("welcomeMessage", { name: userName })}</p>
```

```json
{
  "welcomeMessage": "Bonjour {name}, bienvenue !"
}
```

### ❌ Ne PAS faire
```tsx
// Mettre du HTML dans une traduction
<p>{t("warning")}</p>
// "warning": "Attention ! <strong>action</strong> irréversible."
```

### ✅ À faire
```tsx
// Utiliser le composant <NextIntlClientProvider> avec rich content
import { useTranslations } from "next-intl";
const t = useTranslations("alerts");
<p>{t.rich("warning", { strong: (chunks) => <strong>{chunks}</strong> })}</p>
```

```json
{
  "warning": "Attention ! <strong>action</strong> irréversible."
}
```

---

## 🌐 Ajouter une 3e langue (espagnol par exemple)

1. **`messages/es.json`** : copier `fr.json` et tout traduire
2. **`i18n/request.ts`** : ajouter `"es"` dans `locales`
3. **`components/locale-toggle.tsx`** : ajouter l'option `es`

C'est tout. Pas de configuration Next.js supplémentaire.

---

## 🧪 Tester localement

```bash
# Mode dev
npm run dev

# Aller sur la page → cliquer sur FR/EN dans le header
# Le toggle pose le cookie NEXT_LOCALE puis fait router.refresh()
# Les RSC re-renderent avec la nouvelle locale

# Cookie effacé ? L'app retombe sur Accept-Language puis "fr"
```

---

## 📊 État de la migration

| Catégorie | Statut |
|---|---|
| Foundation (next-intl, request, layout, toggle) | ✅ Livré 16 mai |
| Dictionnaires (~ 400 clés FR + EN, 16 namespaces) | ✅ |
| Pages auth (login, signup, forgot, reset) | ✅ |
| Cookie banner | ✅ |
| Navigation (nav-groups, sidebar, topbar, mobile, admin shell) | ✅ |
| Dashboard stagiaire | ✅ |
| Modules / Exercices / Examens blancs / Quiz index | ✅ |
| Accompagnement / Sessions (Premium upsell) | ✅ |
| Page Tarifs publique | ✅ |
| Quiz runner (`app/quiz/[id]/quiz-runner.tsx`) | ⏳ 1458 lignes, logique critique — à migrer dans un commit dédié |
| Page intro quiz (`app/quiz/[id]/page.tsx`) | ⏳ À migrer |
| Page résultats quiz (`app/quiz/results/[attemptId]/page.tsx`) | ⏳ À migrer |
| Home publique `app/page.tsx` | ⏳ 737 lignes marketing — à migrer par sections |
| Sessions list (`app/sessions/sessions-list.tsx`) | ⏳ 457 lignes client component |
| Messaging shell + components | ⏳ Composants client riches |
| Pages /messages /accompagnement détail | 🟡 Pages serveur migrées, sous-composants client en FR |
| Admin (`app/admin/*`) | ⏳ Plus tard (low priority, interface interne) |
| Formateur (`app/formateur/*`) | ⏳ Plus tard (low priority) |

La migration peut se faire **page par page** sans bloquer le reste — chaque page non-migrée garde simplement son contenu FR en dur, ce qui reste fonctionnel.

## 🧩 Namespaces disponibles (état des lieux)

`common`, `nav`, `navGroups`, `navShort`, `shell`, `auth`, `signup`,
`forgotPassword`, `resetPassword`, `cookies`, `dashboard`, `modules`,
`exercices`, `examensBlancs`, `quiz`, `coaching`, `sessions`, `tarifs`,
`footer`, `offline`, `theme`, `language`, `a11y`.
