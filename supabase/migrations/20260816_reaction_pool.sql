-- =====================================================
-- Reaction Pool para The Wild Times
-- ---------------------------------------------
-- Documenta / crea el soporte del pool de reacciones
-- (👍 like · ❤️ love · 😂 haha · 😢 sad · 😡 angry).
--
-- Idempotente: usa DROP FUNCTION IF EXISTS + `drop
-- column` seguro para poder re-aplicarse en cualquier
-- entorno (productivo, staging, local). Las firmas
-- coinciden con lo que el frontend espera.
-- =====================================================

-- 1) Soporte de tipos de reaccion en wall_likes
ALTER TABLE public.wall_likes
  ADD COLUMN IF NOT EXISTS reaction_type TEXT NOT NULL DEFAULT 'like'
  CONSTRAINT wall_likes_reaction_type_check
  CHECK (reaction_type IN ('like', 'love', 'haha', 'sad', 'angry'));


-- 2) Toggle de reaccion (insert / cambiar / eliminar)
DROP FUNCTION IF EXISTS public.toggle_reaction(uuid, uuid, text);
CREATE OR REPLACE FUNCTION public.toggle_reaction(
  p_post_id UUID,
  p_user_id UUID,
  p_reaction_type TEXT DEFAULT 'like'::text
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  DECLARE
    v_existing text;
    v_active text;
    v_count int;
  BEGIN
    IF p_reaction_type NOT IN ('like','love','haha','sad','angry') THEN
      RAISE EXCEPTION 'Invalid reaction type %', p_reaction_type;
    END IF;

    SELECT reaction_type INTO v_existing
    FROM public.wall_likes
    WHERE post_id = p_post_id AND user_id = p_user_id
    LIMIT 1;

    IF v_existing IS NULL THEN
      INSERT INTO public.wall_likes (post_id, user_id, reaction_type)
      VALUES (p_post_id, p_user_id, p_reaction_type);
      v_active := p_reaction_type;
    ELSIF v_existing = p_reaction_type THEN
      DELETE FROM public.wall_likes WHERE post_id = p_post_id AND user_id = p_user_id;
      v_active := NULL;
    ELSE
      UPDATE public.wall_likes
      SET reaction_type = p_reaction_type, created_at = now()
      WHERE post_id = p_post_id AND user_id = p_user_id;
      v_active := p_reaction_type;
    END IF;

    SELECT COUNT(*) INTO v_count FROM public.wall_likes WHERE post_id = p_post_id;
    RETURN json_build_object('active', v_active, 'count', v_count);
  END;
$$;


-- 3) Reacciones de un post (con perfil y tipo), con filtro opcional
DROP FUNCTION IF EXISTS public.get_post_likes(uuid, text);
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
    SELECT wl.id, wl.post_id, wl.user_id, p.username, p.nombre, p.avatar_url, wl.reaction_type, wl.created_at
    FROM public.wall_likes wl
    LEFT JOIN public.profiles p ON p.id = wl.user_id
    WHERE wl.post_id = p_post_id
      AND (p_reaction_type IS NULL OR wl.reaction_type = p_reaction_type)
    ORDER BY wl.created_at DESC;
  END;
$$;


-- 4) Reposts de un post (con perfil)
DROP FUNCTION IF EXISTS public.get_post_reposts(uuid);
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
  SELECT wr.id, wr.post_id, wr.user_id, p.username, p.nombre, p.avatar_url, wr.created_at
  FROM public.wall_reposts wr
  LEFT JOIN public.profiles p ON p.id = wr.user_id
  WHERE wr.post_id = p_post_id
  ORDER BY wr.created_at DESC;
END;
$$;


-- 5) Conteo por tipo (usado por el dialogo de reacciones)
DROP FUNCTION IF EXISTS public.get_post_reactions(uuid);
CREATE OR REPLACE FUNCTION public.get_post_reactions(p_post_id UUID)
RETURNS TABLE(reaction_type TEXT, count bigint)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  BEGIN
    RETURN QUERY
    SELECT wl.reaction_type, COUNT(*)::bigint
    FROM public.wall_likes wl
    WHERE wl.post_id = p_post_id
    GROUP BY wl.reaction_type;
  END;
$$;


-- 6) Reaccion del usuario logueado en un post
DROP FUNCTION IF EXISTS public.get_my_reaction(uuid, uuid);
CREATE OR REPLACE FUNCTION public.get_my_reaction(p_post_id UUID, p_user_id UUID)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  BEGIN
    RETURN (SELECT reaction_type FROM public.wall_likes WHERE post_id = p_post_id AND user_id = p_user_id LIMIT 1);
  END;
$$;


-- Permisos
GRANT EXECUTE ON FUNCTION public.toggle_reaction TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_post_likes TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_post_reposts TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_post_reactions TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_my_reaction TO authenticated, anon;
