-- =====================================================
-- WILD AND FREE LEAGUE — estado del bracket en tiempo real
-- Ejecutar en el SQL Editor de Supabase.
-- =====================================================

-- Helper de permisos (idempotente): admin o staff
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

CREATE TABLE IF NOT EXISTS public.league_bracket_state (
  id TEXT PRIMARY KEY,
  state JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

ALTER TABLE public.league_bracket_state ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read league bracket" ON public.league_bracket_state;
CREATE POLICY "Public can read league bracket" ON public.league_bracket_state
  FOR SELECT TO public USING (TRUE);

DROP POLICY IF EXISTS "Staff can manage league bracket" ON public.league_bracket_state;
CREATE POLICY "Staff can manage league bracket" ON public.league_bracket_state
  FOR ALL TO authenticated
  USING (public.is_staff_or_admin())
  WITH CHECK (public.is_staff_or_admin());

GRANT SELECT ON public.league_bracket_state TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.league_bracket_state TO authenticated;

-- Habilitar Realtime para la tabla (sin fallar si ya está agregada)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'league_bracket_state'
  ) THEN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.league_bracket_state';
  END IF;
END $$;
