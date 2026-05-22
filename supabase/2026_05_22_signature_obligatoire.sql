-- ============================================================
-- Signature obligatoire à la première connexion + signature de référence
--   - user_signatures : signature dessinée, UNE par stagiaire, réutilisable
--     (documents obligatoires ET émargement de présence).
--   - profiles.mandatory_signature_at : marqueur de complétion (gate middleware).
--   - complete_mandatory_signature() : RPC atomique (signature + acceptation de
--     tous les documents publiés + notification des admins).
--
-- À appliquer AVANT d'activer le blocage middleware (Phase 2).
-- ============================================================

-- 1. Signature de référence (dessinée), une par utilisateur
create table if not exists public.user_signatures (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  signature_data text not null,          -- image PNG en data URL (base64)
  hash text,                             -- empreinte (anti-falsification simple)
  signed_at timestamptz not null default now(),
  ip_address inet,
  user_agent text
);

alter table public.user_signatures enable row level security;

drop policy if exists us_own_read on public.user_signatures;
create policy us_own_read on public.user_signatures
  for select using (user_id = auth.uid());

drop policy if exists us_own_insert on public.user_signatures;
create policy us_own_insert on public.user_signatures
  for insert with check (user_id = auth.uid());

drop policy if exists us_admin_read on public.user_signatures;
create policy us_admin_read on public.user_signatures
  for select using (public.is_admin());

-- 2. Marqueur de complétion sur le profil
alter table public.profiles
  add column if not exists mandatory_signature_at timestamptz;

-- 3. RPC atomique : signature + acceptations + notification admin
create or replace function public.complete_mandatory_signature(
  p_signature_data text,
  p_hash text default null,
  p_ip text default null,
  p_user_agent text default null,
  p_signature_name text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_ip inet;
  v_name text;
  v_doc record;
begin
  if v_uid is null then
    raise exception 'Non authentifié';
  end if;
  if coalesce(trim(p_signature_data), '') = '' then
    raise exception 'Signature manquante';
  end if;

  begin
    v_ip := nullif(trim(p_ip), '')::inet;
  exception when others then
    v_ip := null;
  end;

  v_name := coalesce(
    nullif(trim(p_signature_name), ''),
    (select full_name from public.profiles where id = v_uid)
  );

  -- a) Signature de référence (upsert : on garde une seule signature à jour)
  insert into public.user_signatures (user_id, signature_data, hash, ip_address, user_agent)
  values (v_uid, p_signature_data, p_hash, v_ip, p_user_agent)
  on conflict (user_id) do update set
    signature_data = excluded.signature_data,
    hash = excluded.hash,
    signed_at = now(),
    ip_address = excluded.ip_address,
    user_agent = excluded.user_agent;

  -- b) Acceptation horodatée de tous les documents publiés
  for v_doc in
    select id, type, version from public.onboarding_documents where published
  loop
    insert into public.document_acceptances
      (user_id, document_id, document_type, document_version,
       user_agent, ip_address, signature_name)
    values
      (v_uid, v_doc.id, v_doc.type, v_doc.version,
       p_user_agent, v_ip, v_name)
    on conflict (user_id, document_id) do nothing;
  end loop;

  -- c) Marqueurs de complétion
  update public.profiles
     set mandatory_signature_at = coalesce(mandatory_signature_at, now()),
         onboarding_completed_at = coalesce(onboarding_completed_at, now())
   where id = v_uid;

  -- d) Notification des admins / super-admins
  insert into public.notifications (user_id, title, body, type, link_url)
  select p.id,
         'Documents signés',
         coalesce(v_name, 'Un stagiaire') || ' a signé tous les documents obligatoires.',
         'system',
         '/admin/signatures'
    from public.profiles p
   where p.role in ('admin', 'super_admin');
end;
$$;

grant execute on function
  public.complete_mandatory_signature(text, text, text, text, text) to authenticated;
