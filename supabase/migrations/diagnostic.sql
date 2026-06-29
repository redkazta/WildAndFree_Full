-- =====================================================
-- DIAGNÓSTICO: Ver estado actual de tablas, RLS y permisos
-- =====================================================
-- EJECUTAR ESTO PRIMERO para ver qué falta

-- 1. Ver tablas con RLS activado
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'store_orders', 'store_products', 'store_order_items',
                    'product_variants', 'exclusive_content', 'events', 'user_tokens',
                    'user_has_tags', 'tags', 'user_roles', 'roles', 'permissions', 'role_permissions')
ORDER BY tablename;

-- 2. Ver todas las RLS policies existentes en estas tablas
SELECT schemaname, tablename, policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'store_orders', 'store_products', 'store_order_items',
                    'product_variants', 'exclusive_content', 'events', 'user_tokens',
                    'user_has_tags', 'tags', 'user_roles', 'roles', 'permissions', 'role_permissions')
ORDER BY tablename, policyname;

-- 3. Ver roles existentes
SELECT id, name, internal_name, display_name FROM public.roles ORDER BY id;

-- 4. Ver permisos existentes
SELECT id, name, module FROM public.permissions ORDER BY id;

-- 5. Ver role_permissions existentes (cuántos tiene admin)
SELECT r.name as role_name, COUNT(rp.permission_id) as perm_count
FROM public.roles r
LEFT JOIN public.role_permissions rp ON rp.role_id = r.id
GROUP BY r.name
ORDER BY r.name;

-- 6. Verificar la función get_my_role
SELECT proname, prosrc
FROM pg_proc
WHERE proname = 'get_my_role';

-- 7. Ver políticas de profiles específicamente
SELECT schemaname, tablename, policyname, cmd, qual
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'profiles'
ORDER BY policyname;
