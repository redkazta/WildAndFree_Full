-- PERMITIR LECTURA SEGURA DE TAGS PARA FRONTEND
-- Ejecuta esto en Supabase SQL Editor para desbloquear la carga del perfil

-- 1. Permitir que usuarios autenticados vean SUS propias relaciones de tags
DROP POLICY IF EXISTS "Users can view their own tags" ON public.user_has_tags;
CREATE POLICY "Users can view their own tags" ON public.user_has_tags
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- 2. Permitir que cualquiera (autenticado o no) vea las definiciones de tags (colores, nombres)
DROP POLICY IF EXISTS "Tags are viewable by everyone" ON public.tags;
CREATE POLICY "Tags are viewable by everyone" ON public.tags
FOR SELECT
TO public
USING (true);

-- 3. Permitir leer roles asignados al usuario (NUEVO)
DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;
CREATE POLICY "Users can view their own roles" ON public.user_roles
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- 4. Permitir leer definiciones de roles (NUEVO)
DROP POLICY IF EXISTS "Roles are viewable by everyone" ON public.roles;
CREATE POLICY "Roles are viewable by everyone" ON public.roles
FOR SELECT
TO public
USING (true);

-- 5. Asegurar que RLS esté activo
ALTER TABLE public.user_has_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
