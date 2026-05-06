-- =====================================================================
-- MA FORMATION TRANSPORT — Schéma PostgreSQL (Supabase)
-- RNCP 40990 — Gestionnaire des Opérations de Transport Routier de Marchandises
-- =====================================================================

-- Extensions
create extension if not exists "uuid-ossp";

-- =====================================================================
-- 1. PROFILES (étend auth.users de Supabase)
-- =====================================================================
create type user_role as enum ('student', 'admin');
create type user_level as enum ('debutant', 'intermediaire', 'avance', 'expert');

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  full_name text,
  role user_role not null default 'student',
  level user_level not null default 'debutant',
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- =====================================================================
-- 2. BLOCS DE COMPÉTENCES (référentiel RNCP 40990)
-- =====================================================================
create table if not exists blocs (
  id serial primary key,
  code text not null unique,             -- 'BC1', 'BC2', 'BC3'
  title text not null,
  description text,
  "order" int not null default 0,
  created_at timestamptz not null default now()
);

-- =====================================================================
-- 3. MODULES DE FORMATION
-- =====================================================================
create table if not exists modules (
  id uuid primary key default uuid_generate_v4(),
  bloc_id int not null references blocs(id) on delete cascade,
  slug text not null unique,
  title text not null,
  summary text,
  difficulty user_level not null default 'debutant',
  duration_min int not null default 30,
  "order" int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- =====================================================================
-- 4. LEÇONS (cours détaillé + fiche synthèse)
-- =====================================================================
create table if not exists lessons (
  id uuid primary key default uuid_generate_v4(),
  module_id uuid not null references modules(id) on delete cascade,
  slug text not null,
  title text not null,
  content_md text not null,              -- cours détaillé (markdown)
  summary_md text,                       -- fiche de synthèse
  "order" int not null default 0,
  created_at timestamptz not null default now(),
  unique (module_id, slug)
);

-- =====================================================================
-- 5. QUIZ & QUESTIONS
-- =====================================================================
create type quiz_type as enum ('entrainement', 'examen');

create table if not exists quizzes (
  id uuid primary key default uuid_generate_v4(),
  module_id uuid references modules(id) on delete cascade,
  title text not null,
  description text,
  type quiz_type not null default 'entrainement',
  time_limit_s int,                       -- null = pas de limite
  pass_threshold int not null default 70, -- % pour réussite
  created_at timestamptz not null default now()
);

create table if not exists questions (
  id uuid primary key default uuid_generate_v4(),
  quiz_id uuid not null references quizzes(id) on delete cascade,
  statement text not null,
  explanation text,                        -- correction automatique
  "order" int not null default 0
);

create table if not exists choices (
  id uuid primary key default uuid_generate_v4(),
  question_id uuid not null references questions(id) on delete cascade,
  label text not null,
  is_correct boolean not null default false,
  "order" int not null default 0
);

-- =====================================================================
-- 6. PROGRESSION & RÉSULTATS
-- =====================================================================
create table if not exists lesson_progress (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  lesson_id uuid not null references lessons(id) on delete cascade,
  completed boolean not null default false,
  completed_at timestamptz,
  unique (user_id, lesson_id)
);

create table if not exists quiz_attempts (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  quiz_id uuid not null references quizzes(id) on delete cascade,
  score int not null,                     -- nb de bonnes réponses
  total int not null,
  percentage int not null,
  passed boolean not null default false,
  duration_s int,
  answers jsonb,                          -- { question_id: choice_id[] }
  started_at timestamptz not null default now(),
  finished_at timestamptz
);

-- =====================================================================
-- 7. NOTIFICATIONS
-- =====================================================================
create table if not exists notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  body text,
  link text,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

-- =====================================================================
-- 8. TRIGGER : auto-création du profil à l'inscription
-- =====================================================================
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name', new.email));
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- =====================================================================
-- 9. ROW LEVEL SECURITY
-- =====================================================================
alter table profiles enable row level security;
alter table blocs enable row level security;
alter table modules enable row level security;
alter table lessons enable row level security;
alter table quizzes enable row level security;
alter table questions enable row level security;
alter table choices enable row level security;
alter table lesson_progress enable row level security;
alter table quiz_attempts enable row level security;
alter table notifications enable row level security;

-- Helper : est-on admin ?
create or replace function public.is_admin()
returns boolean language sql stable security definer as $$
  select exists(select 1 from profiles where id = auth.uid() and role = 'admin');
$$;

-- Profiles : chacun voit/édite le sien, admin voit tout
create policy "profiles_self_read" on profiles for select using (auth.uid() = id or public.is_admin());
create policy "profiles_self_update" on profiles for update using (auth.uid() = id);
create policy "profiles_admin_all" on profiles for all using (public.is_admin());

-- Contenu pédagogique : lecture publique connectée, écriture admin
create policy "content_read_authed" on blocs for select using (auth.role() = 'authenticated');
create policy "content_admin_all" on blocs for all using (public.is_admin());
create policy "modules_read_authed" on modules for select using (auth.role() = 'authenticated');
create policy "modules_admin_all" on modules for all using (public.is_admin());
create policy "lessons_read_authed" on lessons for select using (auth.role() = 'authenticated');
create policy "lessons_admin_all" on lessons for all using (public.is_admin());
create policy "quizzes_read_authed" on quizzes for select using (auth.role() = 'authenticated');
create policy "quizzes_admin_all" on quizzes for all using (public.is_admin());
create policy "questions_read_authed" on questions for select using (auth.role() = 'authenticated');
create policy "questions_admin_all" on questions for all using (public.is_admin());
create policy "choices_read_authed" on choices for select using (auth.role() = 'authenticated');
create policy "choices_admin_all" on choices for all using (public.is_admin());

-- Progression : chacun la sienne, admin voit tout
create policy "progress_self_all" on lesson_progress for all using (auth.uid() = user_id);
create policy "progress_admin_read" on lesson_progress for select using (public.is_admin());
create policy "attempts_self_all" on quiz_attempts for all using (auth.uid() = user_id);
create policy "attempts_admin_read" on quiz_attempts for select using (public.is_admin());
create policy "notifs_self_all" on notifications for all using (auth.uid() = user_id);
