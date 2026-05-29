-- =====================================================================
-- Journal des emails envoyés depuis la plateforme (composer interne).
-- À appliquer dans l'éditeur SQL Supabase. Régénérer ensuite le baseline :
--   node scripts/introspect-schema.mjs
-- =====================================================================

create table if not exists public.email_log (
  id              uuid primary key default gen_random_uuid(),
  sender_id       uuid references public.profiles(id) on delete set null,
  sender_email    text,
  recipients      text[] not null default '{}',
  cc              text[] not null default '{}',
  bcc             text[] not null default '{}',
  subject         text not null default '',
  body_html       text,
  status          text not null default 'sent',   -- sent | error | queued | opened
  provider_id     text,                            -- id Resend
  error           text,
  attachments_meta jsonb not null default '[]',    -- [{name, size}]
  related_user_id uuid references public.profiles(id) on delete set null,
  context         text,                            -- ex: "enrollment", "lead"
  created_at      timestamptz not null default now()
);

create index if not exists email_log_created_idx on public.email_log (created_at desc);
create index if not exists email_log_sender_idx on public.email_log (sender_id);

alter table public.email_log enable row level security;

-- Le staff (admin / super_admin / formateur) peut lire et insérer.
drop policy if exists email_log_staff_select on public.email_log;
create policy email_log_staff_select on public.email_log
  for select using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.role in ('admin', 'super_admin', 'trainer')
    )
  );

drop policy if exists email_log_staff_insert on public.email_log;
create policy email_log_staff_insert on public.email_log
  for insert with check (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.role in ('admin', 'super_admin', 'trainer')
    )
  );

comment on table public.email_log is
  'Historique des emails envoyés depuis le composer interne (statut, destinataires, contenu).';
