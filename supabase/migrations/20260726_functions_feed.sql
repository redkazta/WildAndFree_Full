-- =====================================================
-- Functions and views for the social feed
-- =====================================================

-- Get feed posts with real reaction counts
CREATE OR REPLACE FUNCTION public.get_feed_posts(
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0,
  p_user_id UUID DEFAULT NULL
)
RETURNS TABLE(
  id UUID,
  user_id UUID,
  username TEXT,
  nombre TEXT,
  avatar_url TEXT,
  content TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ,
  likes_count BIGINT,
  comments_count BIGINT,
  reposts_count BIGINT,
  is_liked BOOLEAN,
  is_reposted BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    wp.id,
    wp.user_id,
    p.username,
    p.nombre,
    p.avatar_url,
    wp.content,
    wp.image_url,
    wp.created_at,
    COALESCE(l.likes_count, 0)::BIGINT AS likes_count,
    COALESCE(c.comments_count, 0)::BIGINT AS comments_count,
    COALESCE(r.reposts_count, 0)::BIGINT AS reposts_count,
    CASE WHEN p_user_id IS NOT NULL THEN
      EXISTS (SELECT 1 FROM public.wall_likes wl WHERE wl.post_id = wp.id AND wl.user_id = p_user_id)
    ELSE FALSE END AS is_liked,
    CASE WHEN p_user_id IS NOT NULL THEN
      EXISTS (SELECT 1 FROM public.wall_reposts wr WHERE wr.post_id = wp.id AND wr.user_id = p_user_id)
    ELSE FALSE END AS is_reposted
  FROM public.wall_posts wp
  LEFT JOIN public.profiles p ON p.id = wp.user_id
  LEFT JOIN (SELECT post_id, COUNT(*) AS likes_count FROM public.wall_likes GROUP BY post_id) l ON l.post_id = wp.id
  LEFT JOIN (SELECT post_id, COUNT(*) AS comments_count FROM public.wall_comments WHERE deleted_at IS NULL GROUP BY post_id) c ON c.post_id = wp.id
  LEFT JOIN (SELECT post_id, COUNT(*) AS reposts_count FROM public.wall_reposts GROUP BY post_id) r ON r.post_id = wp.id
  WHERE wp.deleted_at IS NULL
  ORDER BY wp.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

-- Get crew posts (artist profile feed) with reaction counts
CREATE OR REPLACE FUNCTION public.get_crew_feed(
  p_author_id UUID,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0,
  p_user_id UUID DEFAULT NULL
)
RETURNS TABLE(
  id UUID,
  author_id UUID,
  username TEXT,
  nombre TEXT,
  avatar_url TEXT,
  title TEXT,
  content TEXT,
  image_url TEXT,
  post_type TEXT,
  published_at TIMESTAMPTZ,
  likes_count BIGINT,
  comments_count BIGINT,
  reposts_count BIGINT,
  is_liked BOOLEAN,
  is_reposted BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    cp.id,
    cp.author_id,
    p.username,
    p.nombre,
    p.avatar_url,
    cp.title,
    cp.content,
    cp.image_url,
    cp.post_type,
    cp.published_at,
    COALESCE(l.likes_count, 0)::BIGINT AS likes_count,
    COALESCE(c.comments_count, 0)::BIGINT AS comments_count,
    COALESCE(r.reposts_count, 0)::BIGINT AS reposts_count,
    CASE WHEN p_user_id IS NOT NULL THEN
      EXISTS (SELECT 1 FROM public.wall_likes wl WHERE wl.post_id = cp.id AND wl.user_id = p_user_id)
    ELSE FALSE END AS is_liked,
    CASE WHEN p_user_id IS NOT NULL THEN
      EXISTS (SELECT 1 FROM public.wall_reposts wr WHERE wr.post_id = cp.id AND wr.user_id = p_user_id)
    ELSE FALSE END AS is_reposted
  FROM public.crew_posts cp
  LEFT JOIN public.profiles p ON p.id = cp.author_id
  LEFT JOIN (SELECT post_id, COUNT(*) AS likes_count FROM public.wall_likes GROUP BY post_id) l ON l.post_id = cp.id
  LEFT JOIN (SELECT post_id, COUNT(*) AS comments_count FROM public.wall_comments WHERE deleted_at IS NULL GROUP BY post_id) c ON c.post_id = cp.id
  LEFT JOIN (SELECT post_id, COUNT(*) AS reposts_count FROM public.wall_reposts GROUP BY post_id) r ON r.post_id = cp.id
  WHERE cp.author_id = p_author_id
    AND cp.status = 'published'
  ORDER BY cp.published_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

-- Get comments for a post with user profiles
CREATE OR REPLACE FUNCTION public.get_post_comments(p_post_id UUID)
RETURNS TABLE(
  id UUID,
  post_id UUID,
  user_id UUID,
  username TEXT,
  nombre TEXT,
  avatar_url TEXT,
  content TEXT,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    wc.id,
    wc.post_id,
    wc.user_id,
    p.username,
    p.nombre,
    p.avatar_url,
    wc.content,
    wc.created_at
  FROM public.wall_comments wc
  LEFT JOIN public.profiles p ON p.id = wc.user_id
  WHERE wc.post_id = p_post_id
    AND wc.deleted_at IS NULL
  ORDER BY wc.created_at ASC;
END;
$$;

-- Toggle like (insert or delete)
CREATE OR REPLACE FUNCTION public.toggle_like(
  p_post_id UUID,
  p_user_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_exists BOOLEAN;
BEGIN
  SELECT EXISTS(SELECT 1 FROM public.wall_likes WHERE post_id = p_post_id AND user_id = p_user_id) INTO v_exists;
  
  IF v_exists THEN
    DELETE FROM public.wall_likes WHERE post_id = p_post_id AND user_id = p_user_id;
    RETURN FALSE;
  ELSE
    INSERT INTO public.wall_likes (post_id, user_id) VALUES (p_post_id, p_user_id);
    RETURN TRUE;
  END IF;
END;
$$;

-- Toggle repost
CREATE OR REPLACE FUNCTION public.toggle_repost(
  p_post_id UUID,
  p_user_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_exists BOOLEAN;
BEGIN
  SELECT EXISTS(SELECT 1 FROM public.wall_reposts WHERE post_id = p_post_id AND user_id = p_user_id) INTO v_exists;
  
  IF v_exists THEN
    DELETE FROM public.wall_reposts WHERE post_id = p_post_id AND user_id = p_user_id;
    RETURN FALSE;
  ELSE
    INSERT INTO public.wall_reposts (post_id, user_id) VALUES (p_post_id, p_user_id);
    RETURN TRUE;
  END IF;
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.get_feed_posts TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_crew_feed TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_post_comments TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.toggle_like TO authenticated;
GRANT EXECUTE ON FUNCTION public.toggle_repost TO authenticated;
