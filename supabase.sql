-- Run this in the Supabase SQL Editor before using profile sync.
create table if not exists public.player_profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  profile jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.player_profiles enable row level security;

revoke all on table public.player_profiles from anon, authenticated;
grant select, insert, update on table public.player_profiles to authenticated;

drop policy if exists "Users can read their own player profile" on public.player_profiles;
create policy "Users can read their own player profile"
  on public.player_profiles for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can create their own player profile" on public.player_profiles;
create policy "Users can create their own player profile"
  on public.player_profiles for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own player profile" on public.player_profiles;
create policy "Users can update their own player profile"
  on public.player_profiles for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);