-- =====================================================================
-- MA FORMATION TRANSPORT — Documents importés par le stagiaire
-- Table + bucket Storage privé + RLS (stagiaire = ses docs, staff = lecture
-- + statut/remarque). À appliquer dans l'éditeur SQL Supabase (idempotent).
-- =====================================================================

create table if not exists public.student_documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  formation_id uuid references public.formations(id) on delete set null,
  title text not null,
  reason text not null,                 -- motif (clé) parmi la liste prédéfinie ou 'autres'
  custom_reason text,                   -- motif libre si reason = 'autres'
  storage_path text not null,           -- chemin dans le bucket student-documents
  file_name text not null,
  mime_type text,
  size_bytes integer,
  status text not null default 'recu'
    check (status in ('recu','en_attente','valide','refuse')),
  admin_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists student_documents_user_idx
  on public.student_documents(user_id, created_at desc);
create index if not exists student_documents_status_idx
  on public.student_documents(status);
create index if not exists student_documents_formation_idx
  on public.student_documents(formation_id);

alter table public.student_documents enable row level security;

-- Lecture : le stagiaire ses docs ; admin + formateur tout.
drop policy if exists student_docs_select on public.student_documents;
create policy student_docs_select on public.student_documents
  for select using (
    auth.uid() = user_id
    or public.is_admin()
    or (select role from public.profiles where id = auth.uid()) = 'trainer'
  );

-- Insertion : uniquement pour soi-même.
drop policy if exists student_docs_insert on public.student_documents;
create policy student_docs_insert on public.student_documents
  for insert with check (auth.uid() = user_id);

-- Mise à jour (statut, remarque) : staff uniquement.
drop policy if exists student_docs_update_staff on public.student_documents;
create policy student_docs_update_staff on public.student_documents
  for update using (
    public.is_admin()
    or (select role from public.profiles where id = auth.uid()) = 'trainer'
  ) with check (
    public.is_admin()
    or (select role from public.profiles where id = auth.uid()) = 'trainer'
  );

-- Suppression : le stagiaire ses docs ; admin tout.
drop policy if exists student_docs_delete on public.student_documents;
create policy student_docs_delete on public.student_documents
  for delete using (auth.uid() = user_id or public.is_admin());

-- updated_at automatique.
create or replace function public.tg_student_docs_touch()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;
drop trigger if exists tg_student_docs_touch on public.student_documents;
create trigger tg_student_docs_touch
  before update on public.student_documents
  for each row execute function public.tg_student_docs_touch();

-- ---------------------------------------------------------------------
-- Bucket Storage privé + RLS par préfixe {user_id}/...
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('student-documents', 'student-documents', false)
on conflict (id) do nothing;

-- Upload : chemin doit commencer par l'uid du stagiaire.
drop policy if exists student_docs_storage_insert on storage.objects;
create policy student_docs_storage_insert on storage.objects
  for insert with check (
    bucket_id = 'student-documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Lecture : propriétaire, admin ou formateur.
drop policy if exists student_docs_storage_select on storage.objects;
create policy student_docs_storage_select on storage.objects
  for select using (
    bucket_id = 'student-documents'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or public.is_admin()
      or (select role from public.profiles where id = auth.uid()) = 'trainer'
    )
  );

-- Suppression : propriétaire ou admin.
drop policy if exists student_docs_storage_delete on storage.objects;
create policy student_docs_storage_delete on storage.objects
  for delete using (
    bucket_id = 'student-documents'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or public.is_admin()
    )
  );
