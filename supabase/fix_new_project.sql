-- =====================================================
-- FIX DEL PROYECTO NUEVO (hepsyuwaymwlvyaddecs)
-- Idempotente: se puede ejecutar varias veces.
--
-- 1) Bucket público de imágenes de producto + políticas
-- 2) Reapuntar URLs del proyecto eliminado
-- 3) radio_config con fila singleton (evita el 406)
-- 4) Permisos de lectura pública para tienda y radio
--
-- Ejecutar en el SQL Editor DESPUÉS de las migraciones.
-- =====================================================

-- -----------------------------------------------------
-- 1. Storage: bucket público 'product-images'
-- -----------------------------------------------------
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', TRUE)
ON CONFLICT (id) DO UPDATE SET public = TRUE;

DROP POLICY IF EXISTS "product-images public read" ON storage.objects;
CREATE POLICY "product-images public read" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'product-images');

DROP POLICY IF EXISTS "product-images staff write" ON storage.objects;
CREATE POLICY "product-images staff write" ON storage.objects
  FOR ALL TO authenticated
  USING (bucket_id = 'product-images' AND public.is_staff_or_admin())
  WITH CHECK (bucket_id = 'product-images' AND public.is_staff_or_admin());

-- -----------------------------------------------------
-- 2. Reapuntar URLs del proyecto eliminado
--    (cfsqhbisrkqhbupyjrwz -> hepsyuwaymwlvyaddecs)
--    Recorre todas las columnas de texto de public.
-- -----------------------------------------------------
DO $$
DECLARE
  old_ref CONSTANT TEXT := 'cfsqhbisrkqhbupyjrwz';
  new_ref CONSTANT TEXT := 'hepsyuwaymwlvyaddecs';
  r RECORD;
BEGIN
  FOR r IN
    SELECT c.table_name, c.column_name
    FROM information_schema.columns c
    JOIN information_schema.tables t
      ON t.table_schema = c.table_schema
     AND t.table_name = c.table_name
    WHERE c.table_schema = 'public'
      AND t.table_type = 'BASE TABLE'
      AND c.data_type IN ('text', 'character varying')
  LOOP
    EXECUTE format(
      'UPDATE public.%I SET %I = replace(%I, %L, %L) WHERE %I LIKE %L',
      r.table_name, r.column_name, r.column_name,
      old_ref, new_ref,
      r.column_name, '%' || old_ref || '%'
    );
  END LOOP;
END $$;

-- Galerías en JSONB (store_products.gallery)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'store_products'
      AND column_name = 'gallery'
  ) THEN
    EXECUTE $sql$
      UPDATE public.store_products
      SET gallery = replace(gallery::text, 'cfsqhbisrkqhbupyjrwz', 'hepsyuwaymwlvyaddecs')::jsonb
      WHERE gallery::text LIKE '%cfsqhbisrkqhbupyjrwz%'
    $sql$;
  END IF;
END $$;

-- -----------------------------------------------------
-- 3. radio_config: fila singleton id = 1
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.radio_config (
  id SERIAL PRIMARY KEY,
  zeno_stream_url TEXT DEFAULT 'https://stream.zeno.fm/placeholder',
  zeno_embed_url TEXT DEFAULT 'https://zeno.fm/embed/placeholder',
  is_live BOOLEAN DEFAULT false,
  current_show TEXT DEFAULT 'Wild Gvng Radio',
  current_host TEXT DEFAULT 'KAZTA',
  whatsapp TEXT DEFAULT '+52 (871) 111-1111',
  auto_radio BOOLEAN DEFAULT false,
  auto_radio_spotify_playlist TEXT DEFAULT '',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO public.radio_config
  (id, zeno_stream_url, zeno_embed_url, current_show, current_host)
VALUES
  (1, 'https://stream.zeno.fm/a3gxu5m2rxzuv', 'https://zeno.fm/embed/a3gxu5m2rxzuv', 'Wild Gvng Radio', 'KAZTA')
ON CONFLICT (id) DO NOTHING;

-- Sincronizar la secuencia por si ya existían filas
SELECT setval(
  pg_get_serial_sequence('public.radio_config', 'id'),
  GREATEST((SELECT MAX(id) FROM public.radio_config), 1)
);

-- -----------------------------------------------------
-- 4. Lectura pública de tienda y radio
-- -----------------------------------------------------
ALTER TABLE public.store_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.radio_config ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read active products" ON public.store_products;
CREATE POLICY "Public can read active products" ON public.store_products
  FOR SELECT TO public USING (is_active = TRUE);

DROP POLICY IF EXISTS "Public can read variants" ON public.product_variants;
CREATE POLICY "Public can read variants" ON public.product_variants
  FOR SELECT TO public USING (TRUE);

DROP POLICY IF EXISTS "Anyone can read config" ON public.radio_config;
CREATE POLICY "Anyone can read config" ON public.radio_config
  FOR SELECT TO public USING (TRUE);

DROP POLICY IF EXISTS "Admins can manage config" ON public.radio_config;
CREATE POLICY "Admins can manage config" ON public.radio_config
  FOR ALL TO authenticated USING (public.is_admin())
  WITH CHECK (public.is_admin());

GRANT SELECT ON public.store_products, public.product_variants TO anon, authenticated;
GRANT SELECT ON public.radio_config TO anon, authenticated;

-- -----------------------------------------------------
-- 5. Verificación
-- -----------------------------------------------------
SELECT id, zeno_stream_url, current_show, is_live FROM public.radio_config ORDER BY id;

SELECT id, name, public FROM storage.buckets WHERE id = 'product-images';

SELECT count(*) AS productos_con_ref_vieja
FROM public.store_products
WHERE image_url LIKE '%cfsqhbisrkqhbupyjrwz%'
   OR gallery::text LIKE '%cfsqhbisrkqhbupyjrwz%';
