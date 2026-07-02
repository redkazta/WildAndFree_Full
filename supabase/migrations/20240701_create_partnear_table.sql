-- Migration: Create partnear table (fan-artist follow system)
-- Each row = one user "partneando" (following) an artist

CREATE TABLE IF NOT EXISTS public.partnear (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  artist_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, artist_id)
);

-- Enable RLS
ALTER TABLE public.partnear ENABLE ROW LEVEL SECURITY;

-- Public can read partnear counts (for display)
CREATE POLICY public_read_partnear ON public.partnear FOR SELECT USING (true);

-- Only authenticated users can insert/delete their own partnear
CREATE POLICY user_insert_partnear ON public.partnear
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY user_delete_partnear ON public.partnear
  FOR DELETE USING (auth.uid() = user_id);

-- Index for fast count queries
CREATE INDEX IF NOT EXISTS idx_partnear_artist ON public.partnear(artist_id);
CREATE INDEX IF NOT EXISTS idx_partnear_user ON public.partnear(user_id);
