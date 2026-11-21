-- =====================================================
-- Nombres en comentarios / reposts / reacciones
-- Fallback a auth.users cuando el perfil no tiene nombre.
-- Ejecutar en el SQL Editor de Supabase.
-- =====================================================

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
    COALESCE(
      NULLIF(BTRIM(p.nombre), ''),
      NULLIF(BTRIM(p.username), ''),
      NULLIF(split_part(COALESCE(u.email, ''), '@', 1), ''),
      'Anónimo'
    ) AS nombre,
    p.avatar_url,
    wc.content,
    wc.created_at
  FROM public.wall_comments wc
  LEFT JOIN public.profiles p ON p.id = wc.user_id
  LEFT JOIN auth.users u ON u.id = wc.user_id
  WHERE wc.post_id = p_post_id
    AND wc.deleted_at IS NULL
  ORDER BY wc.created_at ASC;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_post_reposts(p_post_id UUID)
RETURNS TABLE(
  id UUID,
  post_id UUID,
  user_id UUID,
  username TEXT,
  nombre TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    wr.id,
    wr.post_id,
    wr.user_id,
    p.username,
    COALESCE(
      NULLIF(BTRIM(p.nombre), ''),
      NULLIF(BTRIM(p.username), ''),
      NULLIF(split_part(COALESCE(u.email, ''), '@', 1), ''),
      'Anónimo'
    ) AS nombre,
    p.avatar_url,
    wr.created_at
  FROM public.wall_reposts wr
  LEFT JOIN public.profiles p ON p.id = wr.user_id
  LEFT JOIN auth.users u ON u.id = wr.user_id
  WHERE wr.post_id = p_post_id
  ORDER BY wr.created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_post_likes(p_post_id UUID, p_reaction_type TEXT DEFAULT NULL::text)
RETURNS TABLE(
  id UUID,
  post_id UUID,
  user_id UUID,
  username TEXT,
  nombre TEXT,
  avatar_url TEXT,
  reaction_type TEXT,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    wl.id,
    wl.post_id,
    wl.user_id,
    p.username,
    COALESCE(
      NULLIF(BTRIM(p.nombre), ''),
      NULLIF(BTRIM(p.username), ''),
      NULLIF(split_part(COALESCE(u.email, ''), '@', 1), ''),
      'Anónimo'
    ) AS nombre,
    p.avatar_url,
    wl.reaction_type,
    wl.created_at
  FROM public.wall_likes wl
  LEFT JOIN public.profiles p ON p.id = wl.user_id
  LEFT JOIN auth.users u ON u.id = wl.user_id
  WHERE wl.post_id = p_post_id
    AND (p_reaction_type IS NULL OR wl.reaction_type = p_reaction_type)
  ORDER BY wl.created_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_post_comments(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_post_reposts(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_post_likes(UUID, TEXT) TO anon, authenticated;
