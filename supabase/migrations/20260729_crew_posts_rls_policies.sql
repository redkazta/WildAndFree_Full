-- =====================================================
-- RLS policies para crew_posts (admin/staff pueden gestionar)
-- =====================================================

-- Helper: ¿el usuario actual es admin o staff?
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

-- INSERT: solo admin/staff
CREATE POLICY "Staff can insert crew posts" ON public.crew_posts
  FOR INSERT
  WITH CHECK (public.is_staff_or_admin());

-- UPDATE: solo admin/staff
CREATE POLICY "Staff can update crew posts" ON public.crew_posts
  FOR UPDATE
  USING (public.is_staff_or_admin());

-- DELETE: solo admin/staff
CREATE POLICY "Staff can delete crew posts" ON public.crew_posts
  FOR DELETE
  USING (public.is_staff_or_admin());

GRANT EXECUTE ON FUNCTION public.is_staff_or_admin() TO authenticated;
