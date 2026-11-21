-- =====================================================
-- Historias y destacadas (tipo Instagram)
-- Ejecutar en el SQL Editor de Supabase.
-- Idempotente.
-- =====================================================

CREATE TABLE IF NOT EXISTS public.stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  media_url TEXT NOT NULL,
  caption TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.highlights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  cover_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.highlight_stories (
  highlight_id UUID NOT NULL REFERENCES public.highlights(id) ON DELETE CASCADE,
  story_id UUID NOT NULL REFERENCES public.stories(id) ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (highlight_id, story_id)
);

CREATE INDEX IF NOT EXISTS stories_user_idx ON public.stories(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS highlights_user_idx ON public.highlights(user_id, created_at);

ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.highlights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.highlight_stories ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON public.stories, public.highlights, public.highlight_stories TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.stories, public.highlights TO authenticated;
GRANT INSERT, DELETE ON public.highlight_stories TO authenticated;

DROP POLICY IF EXISTS "Stories are public" ON public.stories;
CREATE POLICY "Stories are public" ON public.stories FOR SELECT TO public USING (TRUE);

DROP POLICY IF EXISTS "Users manage own stories" ON public.stories;
CREATE POLICY "Users manage own stories" ON public.stories FOR ALL TO authenticated
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Highlights are public" ON public.highlights;
CREATE POLICY "Highlights are public" ON public.highlights FOR SELECT TO public USING (TRUE);

DROP POLICY IF EXISTS "Users manage own highlights" ON public.highlights;
CREATE POLICY "Users manage own highlights" ON public.highlights FOR ALL TO authenticated
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Highlight items are public" ON public.highlight_stories;
CREATE POLICY "Highlight items are public" ON public.highlight_stories FOR SELECT TO public USING (TRUE);

DROP POLICY IF EXISTS "Users manage own highlight items" ON public.highlight_stories;
CREATE POLICY "Users manage own highlight items" ON public.highlight_stories FOR ALL TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.highlights h
    WHERE h.id = highlight_stories.highlight_id AND h.user_id = auth.uid()
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.highlights h
    WHERE h.id = highlight_stories.highlight_id AND h.user_id = auth.uid()
  ));

-- Bucket de storage
INSERT INTO storage.buckets (id, name, public)
VALUES ('stories', 'stories', TRUE)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Stories media public read" ON storage.objects;
CREATE POLICY "Stories media public read" ON storage.objects
  FOR SELECT TO public USING (bucket_id = 'stories');

DROP POLICY IF EXISTS "Stories media owner write" ON storage.objects;
CREATE POLICY "Stories media owner write" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'stories'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "Stories media owner delete" ON storage.objects;
CREATE POLICY "Stories media owner delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'stories'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );
