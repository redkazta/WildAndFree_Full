-- =====================================================
-- Add artist-specific fields to profiles
-- =====================================================
-- These columns are nullable — only filled when role = 'artista'
-- Fans ("La Jauría") leave them null

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS stage_name TEXT,
  ADD COLUMN IF NOT EXISTS genres TEXT[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS social_links TEXT,
  ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'fan' CHECK (role IN ('fan', 'artist', 'staff', 'admin'));

-- Index for filtering artists
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
