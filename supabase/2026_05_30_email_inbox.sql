-- =====================================================================
-- Boîte de réception : ajoute direction / état de lecture / attribution /
-- libellés à email_log. À appliquer dans l'éditeur SQL Supabase puis :
--   node scripts/introspect-schema.mjs
-- =====================================================================

alter table public.email_log
  add column if not exists direction   text not null default 'outbound'
    check (direction in ('outbound', 'inbound')),
  add column if not exists read_at     timestamptz,
  add column if not exists assigned_to uuid references public.profiles(id) on delete set null,
  add column if not exists labels      text[] not null default '{}',
  add column if not exists from_name   text;

create index if not exists email_log_direction_idx on public.email_log (direction);
create index if not exists email_log_unread_idx
  on public.email_log (created_at desc)
  where direction = 'inbound' and read_at is null;
create index if not exists email_log_assigned_idx on public.email_log (assigned_to);

-- Le webhook entrant insère via la service-role. Pas de policy spécifique
-- nécessaire pour l'inbound (les policies staff existantes couvrent la
-- lecture / mise à jour côté UI).

comment on column public.email_log.direction is 'inbound (reçu) ou outbound (envoyé)';
comment on column public.email_log.read_at is 'Horodatage de la lecture (uniquement pour direction=inbound).';
comment on column public.email_log.assigned_to is 'Admin/super-admin en charge du traitement de cet email.';
comment on column public.email_log.labels is 'Libellés (catalogue côté code : lib/email-labels.ts).';
