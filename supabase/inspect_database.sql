-- =====================================================
-- INVENTARIO COMPLETO DE LA BASE DE DATOS (SUPABASE)
-- Ejecuta este archivo en el SQL Editor y comparte el resultado.
-- =====================================================

-- 1) ¿Existen las tablas que el proyecto necesita?
SELECT
  expected.name AS tabla_esperada,
  CASE WHEN to_regclass('public.' || expected.name) IS NULL
       THEN 'FALTA' ELSE 'OK' END AS estado
FROM unnest(ARRAY[
  'profiles', 'roles', 'permissions', 'role_permissions', 'user_roles',
  'crew_posts', 'wall_posts', 'wall_comments', 'wall_likes', 'wall_reposts',
  'events', 'tickets', 'sponsors', 'event_sponsors', 'tournament_sponsors',
  'written_submissions', 'versus_battles', 'freestylers', 'freestyler_stats',
  'versus_votes', 'radio_config', 'radio_episodes', 'radio_schedule',
  'store_products', 'product_variants', 'store_orders', 'order_items',
  'exclusive_content', 'content_purchases', 'user_tokens',
  'token_purchases', 'token_transactions', 'tags', 'tag_categories',
  'user_has_tags', 'notifications', 'user_settings',
  'account_deletion_requests', 'cart_items', 'wishlist_items', 'favorites'
]) AS expected(name)
ORDER BY estado DESC, tabla_esperada;

-- 2) Columnas reales de profiles (aquí se ve si falta username)
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'profiles'
ORDER BY ordinal_position;

-- 3) Todas las columnas de todas las tablas públicas
SELECT
  table_name,
  ordinal_position,
  column_name,
  data_type,
  udt_name,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- 4) Primary keys, foreign keys y unique constraints
SELECT
  tc.table_name,
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name,
  ccu.table_name  AS foreign_table,
  ccu.column_name AS foreign_column
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu
  ON kcu.constraint_name = tc.constraint_name
 AND kcu.table_schema = tc.table_schema
LEFT JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
 AND ccu.table_schema = tc.table_schema
WHERE tc.table_schema = 'public'
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

-- 5) Políticas RLS
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 6) Funciones / RPCs públicas
SELECT
  p.proname AS funcion,
  pg_get_function_identity_arguments(p.oid) AS argumentos,
  pg_get_function_result(p.oid) AS retorna
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
ORDER BY p.proname;

-- 7) Triggers
SELECT
  event_object_table AS tabla,
  trigger_name,
  event_manipulation AS evento,
  action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- 8) Buckets de Storage
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets
ORDER BY id;

-- 9) Conteo de filas por tabla pública
SELECT
  table_name,
  (xpath('/row/c/text()',
    query_to_xml(format('SELECT count(*) AS c FROM public.%I', table_name), false, true, '')
  ))[1]::text::int AS filas
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 10) Usuarios de Auth (solo emails y fechas)
SELECT id, email, created_at, last_sign_in_at, email_confirmed_at
FROM auth.users
ORDER BY created_at DESC;
