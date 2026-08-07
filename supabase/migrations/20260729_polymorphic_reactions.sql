-- =====================================================
-- Make reactions polymorphic: allow likes/comments/reposts
-- on both wall_posts AND crew_posts
-- We drop the FK so any UUID post can be referenced
-- =====================================================

-- Drop FK constraints on reactions to allow crew_posts ids
ALTER TABLE public.wall_likes DROP CONSTRAINT IF EXISTS wall_likes_post_id_fkey;
ALTER TABLE public.wall_comments DROP CONSTRAINT IF EXISTS wall_comments_post_id_fkey;
ALTER TABLE public.wall_reposts DROP CONSTRAINT IF EXISTS wall_reposts_post_id_fkey;

-- Add index on post_id for performance (was covered by FK before)
CREATE INDEX IF NOT EXISTS idx_wall_likes_post_id ON public.wall_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_wall_comments_post_id ON public.wall_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_wall_reposts_post_id ON public.wall_reposts(post_id);

-- Also ensure the seed crew_posts get some reactions
-- (add likes/comments for the crew posts we just inserted)
INSERT INTO public.wall_likes (post_id, user_id)
SELECT cp.id, 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'
FROM public.crew_posts cp
ON CONFLICT DO NOTHING;

INSERT INTO public.wall_likes (post_id, user_id)
SELECT cp.id, 'ab563ebf-1396-4b0f-a4b7-8d1dec846790'
FROM public.crew_posts cp
WHERE cp.author_id = 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5'
ON CONFLICT DO NOTHING;
