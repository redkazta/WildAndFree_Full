-- =====================================================
-- Habilitar Realtime para crew_posts (feed en vivo)
-- =====================================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.crew_posts;
