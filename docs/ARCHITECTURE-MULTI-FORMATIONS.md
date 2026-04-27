# Architecture multi-formations — modèle de données et permissions

Document de référence pour la plateforme MA FORMATION TRANSPORT.

---

## 1. Les 4 rôles

| Rôle | Code | Pour quoi faire |
|---|---|---|
| **Stagiaire** | `student` | Suivre ses formations, faire ses quiz, voir ses résultats |
| **Formateur** | `trainer` | Encadrer les stagiaires de ses formations habilitées |
| **Admin** | `admin` | Gérer utilisateurs, contenus, affectations, financements |
| **Super Admin** | `super_admin` | Gérer les rôles, voir l'audit, configurer la plateforme |

Hiérarchie : `super_admin > admin > trainer > student`. Un super_admin peut tout faire qu'un admin peut faire (les helpers `is_admin()` retournent `true` pour les deux).

---

## 2. Helpers SQL disponibles

### Vérifier le rôle

```sql
public.is_admin()        -- admin OR super_admin (rétro-compat)
public.is_super_admin()  -- super_admin uniquement
public.is_staff()        -- alias = is_admin()
public.is_trainer()      -- trainer uniquement
```

### Vérifier l'accès à une formation

```sql
-- p_user a-t-il accès à cette formation ?
-- Vrai si : staff (voit tout) OU stagiaire inscrit OU formateur habilité
public.has_formation_access(p_user uuid, p_slug text) → boolean

-- p_user est-il inscrit à cette formation comme stagiaire ?
public.is_enrolled_in(p_user uuid, p_slug text) → boolean
```

### Modifier un rôle (super_admin uniquement)

```sql
SELECT public.update_user_role('user-uuid', 'trainer');
-- Loggé automatiquement dans audit_logs.
-- Refuse de modifier son propre rôle (sécurité).
```

---

## 3. Modèle de données

### Tables principales

```
profiles
  id uuid PK
  role user_role  ← {student, trainer, admin, super_admin}
  ...

formations                              ← catalogue en BDD
  id uuid PK
  slug text UNIQUE                      ← 'gotrm', 'fimo-fco', etc.
  code, title, tagline, category, ...
  active, display_order

formation_modules                       ← N-N module ↔ formation
  formation_id ← formations.id
  module_id    ← modules.id
  display_order, required

formation_quizzes                       ← N-N quiz ↔ formation
  formation_id, quiz_id, is_mock_exam

trainer_formations                      ← habilitations formateur
  trainer_id   ← profiles.id (rôle 'trainer')
  formation_id ← formations.id
  can_grade, can_edit_content, is_lead

trainer_assignments                     ← affectations 1↔1 formateur/stagiaire
  trainer_id, student_id, formation_slug, role (main|support)

enrollments                             ← inscription d'un stagiaire
  user_id, formation_slug, formation_id (FK auto-résolue par trigger)
  status, funding_kind, ...

audit_logs                              ← traçabilité des actions sensibles
  actor_id, action, target_type, target_id, payload
```

### Pourquoi un slug **et** une FK formation_id ?

- **`formation_slug` (text)** : compatible avec le code marketing existant (`?formation=gotrm`), résistant aux changements d'UUID, lisible dans les URLs et les exports.
- **`formation_id` (uuid FK)** : intégrité référentielle stricte (CASCADE), jointures rapides, garantie que la formation existe.

Le **trigger `tg_enrollment_resolve_formation`** maintient la cohérence : à chaque INSERT/UPDATE de `formation_slug`, le `formation_id` est résolu automatiquement.

### Pourquoi `formations` en BDD **et** dans `lib/formations-config.ts` ?

| Source | Usage |
|---|---|
| **`lib/formations-config.ts`** | Marketing : descriptions longues, programme, objectifs, prérequis. Versionné dans Git. |
| **`public.formations`** | Affectations : FK, RLS, requêtes SQL, vues d'analyse. |

Le seed dans `formations_v2.sql` synchronise les 2. Pour propager une modif marketing vers la BDD : rejouer le bloc `INSERT … ON CONFLICT DO UPDATE`.

---

## 4. Cas d'usage typiques

### Inscrire un stagiaire à une formation (admin)

```sql
INSERT INTO public.enrollments (
  user_id, formation_slug, funding_kind, status
) VALUES (
  'user-uuid', 'fimo-fco', 'opco', 'en_cours'
);
-- formation_id est résolu automatiquement par le trigger.
```

### Habiliter un formateur sur 2 formations

```sql
INSERT INTO public.trainer_formations
  (trainer_id, formation_id, can_grade, can_edit_content)
SELECT
  'trainer-uuid',
  id,
  true,   -- peut noter les copies
  false   -- ne peut pas modifier les contenus
FROM public.formations
WHERE slug IN ('gotrm', 'fimo-fco');
```

### Promouvoir un user en formateur (super_admin)

```sql
SELECT public.update_user_role('user-uuid', 'trainer');
-- Loggé dans audit_logs.
```

### Vérifier qu'un user a accès à une formation (RLS)

```sql
-- Dans une policy :
USING (public.has_formation_access(auth.uid(), 'gotrm'))
```

---

## 5. Ordre d'application des migrations

Les fichiers SQL doivent être joués **dans cet ordre** :

```
1. supabase/permissions_v2_step1.sql   ← ajout enum 'super_admin' (commit isolé)
2. supabase/permissions_v2_step2.sql   ← helpers + audit_logs + RPC update_user_role
3. supabase/formations_v2.sql          ← table formations + jointures + seed
```

Entre `step1` et `step2` : **commit obligatoire** (Postgres l'exige pour les enums). En SQL Editor Supabase, c'est automatique entre 2 clics sur Run.

---

## 6. Promouvoir le 1er super_admin

Comme `update_user_role` exige déjà d'être super_admin, il faut bootstrapper le 1er manuellement :

```sql
-- Dans le SQL Editor, après avoir joué les 3 migrations :
UPDATE public.profiles
   SET role = 'super_admin'
 WHERE email = 'TON_EMAIL_ADMIN@example.com';
```

Une fois fait, ce super_admin pourra promouvoir/rétrograder les autres via l'UI (à venir en S4-S5).

---

## 7. Points d'attention

- **L'ancien rôle `admin` continue de fonctionner** : tous les helpers `is_admin()` retournent `true` pour `admin` ET `super_admin`. Aucun écran admin existant ne casse.
- **La RLS sur `modules`/`quizzes` n'est pas encore restreinte par formation** : c'est volontaire pour S1, on touchera ces RLS en S4 avec les nouveaux dashboards. En attendant, tout user authentifié continue de voir tous les modules (comportement actuel inchangé).
- **`trainer_assignments` (créée précédemment) coexiste avec `trainer_formations`** : elles ont des rôles différents.
  - `trainer_formations` = habilitation **par formation** (un formateur peut enseigner GOTRM)
  - `trainer_assignments` = affectation **par stagiaire** (ce formateur suit ces stagiaires-là)

---

## 8. Roadmap des sprints suivants

- **S2** : Charte unifiée (`navy` → `brand`, `gold` → `signal` via aliases Tailwind)
- **S3** : Refonte des 4 shells (student/trainer/admin/super_admin) + login/signup
- **S4** : Dashboards par rôle avec sélecteur de formation pour le stagiaire et onglets habilitations pour le formateur
- **S5** : Pages détail (`/formateur/stagiaires/[id]`, `/admin/affectations`)
- **S6** : OG images dynamiques + page témoignages + polish SEO
