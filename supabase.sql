-- future publics deck · shared gallery
-- run this once in Supabase → SQL editor. then paste Project URL + anon public key into SHARED in index.html.

create table if not exists public.inventions (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  author_id text not null,          -- public, random, per browser: used to mark "mine"
  owner_token text not null,        -- secret, random, per browser: proves ownership for deletion. never readable.
  author_name text,
  place text,
  lang text,
  hand jsonb not null,
  name text not null,
  pitch text,
  steps jsonb,
  question text,
  visual text,
  blender jsonb,
  rejected jsonb,
  image_url text,
  tr jsonb,                          -- translations: {"es": {name,pitch,steps,question}, "en": {...}}
  hidden boolean not null default false
);
alter table public.inventions enable row level security;

-- the anonymous web role can read every column except owner_token
revoke all on public.inventions from anon;
grant select (id, created_at, author_id, author_name, place, lang, hand, name, pitch, steps, question, visual, blender, rejected, image_url, tr, hidden) on public.inventions to anon;
grant insert (author_id, owner_token, author_name, place, lang, hand, name, pitch, steps, question, visual, blender, rejected, image_url, tr) on public.inventions to anon;
grant delete on public.inventions to anon;

-- anyone can read what is not hidden; anyone can add (with size limits);
-- a row can be deleted only by a request that carries the row's owner token (the browser that published it).
-- to moderate: set hidden = true from the Supabase table editor.
create policy "read visible inventions" on public.inventions
  for select to anon using (hidden = false);
create policy "add inventions" on public.inventions
  for insert to anon with check (
    char_length(owner_token) >= 24
    and char_length(name) <= 120 and char_length(coalesce(pitch,'')) <= 1200 and char_length(coalesce(author_name,'')) <= 60
    and char_length(coalesce(place,'')) <= 80 and char_length(coalesce(question,'')) <= 600 and char_length(coalesce(visual,'')) <= 600
    and pg_column_size(hand) < 4000 and pg_column_size(steps) < 6000 and pg_column_size(blender) < 6000 and pg_column_size(tr) < 12000
  );
create policy "delete own inventions" on public.inventions
  for delete to anon using (
    owner_token = coalesce(current_setting('request.headers', true)::json->>'x-owner-token', '')
  );

-- drawings: a public bucket where anyone can upload a jpeg (max 2 MB) and everyone can see them.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
  values ('drawings', 'drawings', true, 2097152, array['image/jpeg','image/png'])
  on conflict (id) do nothing;
create policy "upload drawings" on storage.objects
  for insert to anon with check (bucket_id = 'drawings');
create policy "read drawings" on storage.objects
  for select to anon using (bucket_id = 'drawings');

-- likes: one vote per browser per invention. the voter is the secret owner token (never readable); counts are public.
create table if not exists public.likes (
  invention_id uuid not null references public.inventions(id) on delete cascade,
  voter text not null,
  created_at timestamptz not null default now(),
  primary key (invention_id, voter)
);
alter table public.likes enable row level security;
revoke all on public.likes from anon;
grant select (invention_id, created_at) on public.likes to anon;
grant insert (invention_id, voter) on public.likes to anon;
grant delete on public.likes to anon;
create policy "count likes" on public.likes
  for select to anon using (true);
create policy "vote once" on public.likes
  for insert to anon with check (char_length(voter) >= 24);
create policy "remove own vote" on public.likes
  for delete to anon using (voter = coalesce(current_setting('request.headers', true)::json->>'x-owner-token', ''));
