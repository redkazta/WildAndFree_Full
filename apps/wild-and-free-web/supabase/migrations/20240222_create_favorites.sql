-- Create favorites table
create table public.favorites (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  track_id text not null,
  track_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  
  -- Unique constraint per user and track to avoid duplicates
  unique(user_id, track_id)
);

-- Set up Row Level Security (RLS)
alter table public.favorites enable row level security;

-- Policy: Users can insert their own favorites
create policy "Users can insert their own favorites"
  on public.favorites for insert
  with check (auth.uid() = user_id);

-- Policy: Users can view their own favorites
create policy "Users can view their own favorites"
  on public.favorites for select
  using (auth.uid() = user_id);

-- Policy: Users can delete their own favorites
create policy "Users can delete their own favorites"
  on public.favorites for delete
  using (auth.uid() = user_id);
