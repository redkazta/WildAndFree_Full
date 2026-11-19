-- =====================================================
-- FIX: lectura pública de crew_posts (The Wild Times)
-- Proyecto: hepsyuwaymwlvyaddecs
--
-- Síntoma: hay publicaciones en la tabla pero /the-wild-times
-- muestra "No hay publicaciones del crew aún".
-- Causa: RLS habilitado sin policy de SELECT para anon.
-- Ejecutar en el SQL Editor de Supabase.
-- =====================================================

-- Helper de permisos (idempotente)
CREATE OR REPLACE FUNCTION public.is_staff_or_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid()
      AND r.name IN ('admin', 'staff')
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_staff_or_admin() TO authenticated;

ALTER TABLE public.crew_posts ENABLE ROW LEVEL SECURITY;

-- Grants (RLS sigue filtrando filas)
GRANT SELECT ON public.crew_posts TO anon, authenticated;

-- Público: solo publicadas
DROP POLICY IF EXISTS "Published crew posts are viewable by everyone" ON public.crew_posts;
CREATE POLICY "Published crew posts are viewable by everyone"
  ON public.crew_posts
  FOR SELECT
  TO public
  USING (status = 'published');

-- Staff/admin: ven todo (borradores incluidos) en el ERP
DROP POLICY IF EXISTS "Staff can read all crew posts" ON public.crew_posts;
CREATE POLICY "Staff can read all crew posts"
  ON public.crew_posts
  FOR SELECT
  TO authenticated
  USING (public.is_staff_or_admin());

-- Verificación
SELECT status, post_type, count(*)
FROM public.crew_posts
GROUP BY 1, 2
ORDER BY 1, 2;
