-- =====================================================
-- SEED: Wild Gang Collection (7 borradores de producto)
-- Requiere la migración 20260821_store_product_drafts.sql
-- =====================================================

INSERT INTO public.store_products
  (name, description, base_price, image_url, category, is_active, slug, collection, tags, alt_text, seo_title, seo_description, gallery)
VALUES
  (
    'Gorro Bucket WILD GVNG Anubis "Banda Salvaje" (Árabe)',
    $desc$Eleva tu estilo con este bucket hat negro. Presenta un logo geométrico bordado en el frente, un imponente diseño de Anubis y texto en árabe que significa "Banda Salvaje". Perfecto para completar un look urbano.$desc$,
    649.00,
    '/product-images/bucket-hat-anubis-arabe/vista-principal-anubis.jpg',
    'gorras',
    TRUE,
    'bucket-hat-wild-gvng-anubis-arabe',
    'Anubis Arabic Collection',
    ARRAY['Streetwear','Anubis','Wild GVNG','Egyptian','Black','Unisex'],
    'Gorro de pescador negro WILD GVNG con logo geométrico, gráfico de Anubis y texto en árabe.',
    'Gorro Bucket WILD GVNG Anubis "Banda Salvaje" (Árabe)',
    'Bucket hat negro WILD GVNG con bordado de Anubis y texto árabe. Streetwear premium de la colección Wild Gang.',
    '[{"alt":"Bucket hat negro WILD GVNG con ilustración de Anubis y texto árabe en la banda","url":"/product-images/bucket-hat-anubis-arabe/vista-principal-anubis.jpg"},{"alt":"Bucket hat negro WILD GVNG con logo geométrico y texto árabe en la banda","url":"/product-images/bucket-hat-anubis-arabe/vista-principal-logo.jpg"},{"alt":"Interior del bucket hat con etiqueta WILD GVNG y texto árabe Banda Salvaje","url":"/product-images/bucket-hat-anubis-arabe/etiqueta-interior.jpg"},{"alt":"Close-up de la etiqueta con QR","url":"/product-images/bucket-hat-anubis-arabe/etiqueta-qr.jpg"},{"alt":"Close-up del bordado de Anubis con detalles dorados","url":"/product-images/bucket-hat-anubis-arabe/bordado-anubis.jpg"}]'::jsonb
  ),
  (
    'Gorro Beanie WILD GVNG Anubis "Banda Salvaje" (Árabe)',
    $desc$Mantente abrigado sin perder el estilo. Este beanie negro de WILD GVNG cuenta con bordados de alta calidad del dios Anubis y la frase en árabe "Banda Salvaje".$desc$,
    449.00,
    '/product-images/beanie-anubis-arabe/vista-principal-anubis.jpg',
    'gorras',
    TRUE,
    'beanie-wild-gvng-anubis-arabe',
    'Anubis Arabic Collection',
    ARRAY['Streetwear','Anubis','Wild GVNG','Egyptian','Black','Unisex'],
    'Gorro beanie negro WILD GVNG con diseño de Anubis y texto en árabe en el dobladillo.',
    'Gorro Beanie WILD GVNG Anubis "Banda Salvaje" (Árabe)',
    'Beanie negro WILD GVNG con bordado de Anubis y frase árabe. Colección Wild Gang.',
    '[{"alt":"Beanie negro WILD GVNG con bordado de Anubis en el frente","url":"/product-images/beanie-anubis-arabe/vista-principal-anubis.jpg"},{"alt":"Beanie negro WILD GVNG con logo geométrico y texto árabe en el dobladillo","url":"/product-images/beanie-anubis-arabe/vista-principal-logo.jpg"},{"alt":"Etiqueta interior WILD GVNG con el texto árabe Banda Salvaje","url":"/product-images/beanie-anubis-arabe/etiqueta-interior.jpg"},{"alt":"Close-up del bordado de Anubis con detalles dorados","url":"/product-images/beanie-anubis-arabe/bordado-anubis.jpg"},{"alt":"Close-up de la etiqueta con QR","url":"/product-images/beanie-anubis-arabe/etiqueta-qr.jpg"}]'::jsonb
  ),
  (
    'Playera Oversize WILD GVNG Anubis "Banda Salvaje" (Árabe)',
    $desc$Playera negra de corte urbano. Logo en el pecho, gráfico de gran formato de Anubis en la espalda y detalles en las mangas con texto árabe. Confeccionada para destacar.$desc$,
    749.00,
    '/product-images/playera-anubis-arabe/vista-principal-anubis.jpg',
    'playeras',
    TRUE,
    'playera-oversize-wild-gvng-anubis-arabe',
    'Anubis Arabic Collection',
    ARRAY['Streetwear','Anubis','Wild GVNG','Egyptian','Black','Oversize','Unisex'],
    'Playera negra WILD GVNG con logo en el pecho, gran gráfico de Anubis en la espalda y texto en árabe en las mangas.',
    'Playera Oversize WILD GVNG Anubis "Banda Salvaje" (Árabe)',
    'Playera oversize negra WILD GVNG con Anubis en la espalda y texto árabe en mangas. Colección Wild Gang.',
    '[{"alt":"Playera negra WILD GVNG espalda con ilustración de Anubis y texto árabe en mangas","url":"/product-images/playera-anubis-arabe/vista-principal-anubis.jpg"},{"alt":"Playera negra WILD GVNG frente con logo en el pecho y texto árabe en mangas","url":"/product-images/playera-anubis-arabe/vista-principal-frente.jpg"},{"alt":"Etiqueta interior WILD GVNG con texto árabe Banda Salvaje","url":"/product-images/playera-anubis-arabe/etiqueta-interior.jpg"},{"alt":"Close-up de la etiqueta con QR","url":"/product-images/playera-anubis-arabe/etiqueta-qr.jpg"},{"alt":"Close-up del logo geométrico bordado","url":"/product-images/playera-anubis-arabe/bordado-logo.jpg"},{"alt":"Close-up del texto árabe bordado en la manga","url":"/product-images/playera-anubis-arabe/bordado-manga-arabe.jpg"}]'::jsonb
  ),
  (
    'Sudadera con Capucha WILD GVNG Anubis "Banda Salvaje" (Árabe)',
    $desc$Sudadera negra de WILD GVNG. Detalles bordados del logo en el pecho, una ilustración masiva de Anubis en la espalda y el texto árabe "Banda Salvaje" a lo largo de las mangas. Comodidad y actitud.$desc$,
    1299.00,
    '/product-images/hoodie-anubis-arabe/vista-principal-anubis.jpg',
    'sudaderas',
    TRUE,
    'hoodie-wild-gvng-anubis-arabe',
    'Anubis Arabic Collection',
    ARRAY['Streetwear','Anubis','Wild GVNG','Egyptian','Black','Oversize','Unisex'],
    'Sudadera negra con capucha WILD GVNG, logo en el pecho, Anubis en la espalda y texto árabe en las mangas.',
    'Sudadera con Capucha WILD GVNG Anubis "Banda Salvaje" (Árabe)',
    'Hoodie negro WILD GVNG con Anubis bordado en la espalda y texto árabe en mangas. Colección Wild Gang.',
    '[{"alt":"Sudadera negra con capucha WILD GVNG espalda con ilustración de Anubis y mangas con texto árabe","url":"/product-images/hoodie-anubis-arabe/vista-principal-anubis.jpg"},{"alt":"Sudadera negra con capucha WILD GVNG frente con logo bordado en el pecho","url":"/product-images/hoodie-anubis-arabe/vista-principal-frente.jpg"},{"alt":"Etiqueta interior WILD GVNG con texto árabe Banda Salvaje","url":"/product-images/hoodie-anubis-arabe/etiqueta-interior.jpg"},{"alt":"Close-up de la etiqueta con QR","url":"/product-images/hoodie-anubis-arabe/etiqueta-qr.jpg"},{"alt":"Close-up del logo geométrico bordado","url":"/product-images/hoodie-anubis-arabe/bordado-logo.jpg"},{"alt":"Close-up del texto árabe bordado en la manga","url":"/product-images/hoodie-anubis-arabe/bordado-manga-arabe.jpg"}]'::jsonb
  ),
  (
    'Sudadera con Capucha WILD GVNG "Banda Salvaje" (Chino - Mangas)',
    $desc$Diseño minimalista en la espalda, pero con un mensaje contundente en las mangas. Esta sudadera negra de WILD GVNG presenta el logo geométrico en el pecho y texto chino en las mangas que reafirma tu pertenencia a la "Banda Salvaje".$desc$,
    1299.00,
    '/product-images/hoodie-chino-mangas/vista-principal-frente.jpg',
    'sudaderas',
    TRUE,
    'hoodie-wild-gvng-banda-salvaje-chino-mangas',
    'Anubis Chinese Collection',
    ARRAY['Streetwear','Anubis','Wild GVNG','Egyptian','Black','Oversize','Unisex'],
    'Sudadera negra WILD GVNG con logo en el pecho y texto en chino a lo largo de las mangas.',
    'Sudadera con Capucha WILD GVNG "Banda Salvaje" (Chino - Mangas)',
    'Hoodie negro WILD GVNG con logo bordado y texto chino en mangas. Colección Wild Gang.',
    '[{"alt":"Sudadera negra con capucha WILD GVNG frente con logo en el pecho y 狂野帮派 en las mangas","url":"/product-images/hoodie-chino-mangas/vista-principal-frente.jpg"},{"alt":"Sudadera negra WILD GVNG espalda lisa","url":"/product-images/hoodie-chino-mangas/vista-principal-espalda.jpg"},{"alt":"Etiqueta interior WILD GVNG 狂野帮派","url":"/product-images/hoodie-chino-mangas/etiqueta-interior.jpg"},{"alt":"Close-up de la etiqueta con QR","url":"/product-images/hoodie-chino-mangas/etiqueta-qr.jpg"},{"alt":"Close-up del logo geométrico bordado","url":"/product-images/hoodie-chino-mangas/bordado-logo.jpg"}]'::jsonb
  ),
  (
    'Sudadera con Capucha WILD GVNG "Banda Salvaje" (Chino - Espalda)',
    $desc$Haz una declaración de intenciones. Sudadera negra con el logo bordado en el pecho y la frase en chino "狂野帮派" (Banda Salvaje) estampada en gran formato en la espalda.$desc$,
    1299.00,
    '/product-images/hoodie-chino-espalda/vista-principal-espalda.jpg',
    'sudaderas',
    TRUE,
    'hoodie-wild-gvng-banda-salvaje-chino-espalda',
    'Anubis Chinese Collection',
    ARRAY['Streetwear','Anubis','Wild GVNG','Egyptian','Black','Oversize','Unisex'],
    'Sudadera negra WILD GVNG con logo en el pecho y texto chino grande en la espalda.',
    'Sudadera con Capucha WILD GVNG "Banda Salvaje" (Chino - Espalda)',
    'Hoodie negro WILD GVNG con tipografía china 狂野帮派 en la espalda. Colección Wild Gang.',
    '[{"alt":"Sudadera negra WILD GVNG espalda con tipografía china 狂野帮派","url":"/product-images/hoodie-chino-espalda/vista-principal-espalda.jpg"},{"alt":"Sudadera negra con capucha WILD GVNG frente con logo bordado en el pecho","url":"/product-images/hoodie-chino-espalda/vista-principal-frente.jpg"},{"alt":"Etiqueta interior WILD GVNG 狂野帮派","url":"/product-images/hoodie-chino-espalda/etiqueta-interior.jpg"},{"alt":"Close-up de la etiqueta con QR","url":"/product-images/hoodie-chino-espalda/etiqueta-qr.jpg"},{"alt":"Close-up del logo geométrico bordado","url":"/product-images/hoodie-chino-espalda/bordado-logo.jpg"}]'::jsonb
  ),
  (
    'Playera Oversize WILD GVNG "Banda Salvaje" (Chino)',
    $desc$Playera negra de WILD GVNG. Un diseño limpio al frente con el logo de la marca, y un impacto visual en la espalda con la tipografía en chino "狂野帮派". Ideal para el día a día.$desc$,
    749.00,
    '/product-images/playera-chino/vista-principal-espalda.jpg',
    'playeras',
    TRUE,
    'playera-oversize-wild-gvng-banda-salvaje-chino',
    'Anubis Chinese Collection',
    ARRAY['Streetwear','Anubis','Wild GVNG','Egyptian','Black','Oversize','Unisex'],
    'Playera negra WILD GVNG con logo en el pecho y texto chino en gran formato en la espalda.',
    'Playera Oversize WILD GVNG "Banda Salvaje" (Chino)',
    'Playera oversize negra WILD GVNG con tipografía china 狂野帮派 en la espalda. Colección Wild Gang.',
    '[{"alt":"Playera negra WILD GVNG espalda con tipografía china 狂野帮派","url":"/product-images/playera-chino/vista-principal-espalda.jpg"},{"alt":"Playera negra WILD GVNG frente con logo bordado en el pecho","url":"/product-images/playera-chino/vista-principal-frente.jpg"},{"alt":"Etiqueta interior WILD GVNG 狂野帮派","url":"/product-images/playera-chino/etiqueta-interior.jpg"},{"alt":"Close-up de la etiqueta con QR","url":"/product-images/playera-chino/etiqueta-qr.jpg"},{"alt":"Close-up del logo geométrico bordado","url":"/product-images/playera-chino/bordado-logo.jpg"}]'::jsonb
  )
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  base_price = EXCLUDED.base_price,
  category = EXCLUDED.category,
  image_url = COALESCE(EXCLUDED.image_url, public.store_products.image_url),
  collection = EXCLUDED.collection,
  tags = EXCLUDED.tags,
  alt_text = EXCLUDED.alt_text,
  seo_title = EXCLUDED.seo_title,
  seo_description = EXCLUDED.seo_description,
  gallery = EXCLUDED.gallery,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- =====================================================
-- Variantes
-- =====================================================
INSERT INTO public.product_variants (product_id, size, color, stock, sku)
SELECT p.id, v.size, 'Negro', v.stock, v.sku
FROM public.store_products p
JOIN (VALUES
  ('bucket-hat-wild-gvng-anubis-arabe', 'Única', 15, 'WG-BUCKET-ARAB-BLK'),
  ('beanie-wild-gvng-anubis-arabe', 'Única', 15, 'WG-BEANIE-ARAB-BLK'),

  ('playera-oversize-wild-gvng-anubis-arabe', 'S', 10, 'WG-TEE-ARAB-BLK-S'),
  ('playera-oversize-wild-gvng-anubis-arabe', 'M', 10, 'WG-TEE-ARAB-BLK-M'),
  ('playera-oversize-wild-gvng-anubis-arabe', 'L', 10, 'WG-TEE-ARAB-BLK-L'),
  ('playera-oversize-wild-gvng-anubis-arabe', 'XL', 10, 'WG-TEE-ARAB-BLK-XL'),
  ('playera-oversize-wild-gvng-anubis-arabe', 'XXL', 10, 'WG-TEE-ARAB-BLK-XXL'),

  ('hoodie-wild-gvng-anubis-arabe', 'S', 10, 'WG-HOODIE-ARAB-BLK-S'),
  ('hoodie-wild-gvng-anubis-arabe', 'M', 10, 'WG-HOODIE-ARAB-BLK-M'),
  ('hoodie-wild-gvng-anubis-arabe', 'L', 10, 'WG-HOODIE-ARAB-BLK-L'),
  ('hoodie-wild-gvng-anubis-arabe', 'XL', 10, 'WG-HOODIE-ARAB-BLK-XL'),
  ('hoodie-wild-gvng-anubis-arabe', 'XXL', 10, 'WG-HOODIE-ARAB-BLK-XXL'),

  ('hoodie-wild-gvng-banda-salvaje-chino-mangas', 'S', 10, 'WG-HOODIE-CN-SLV-BLK-S'),
  ('hoodie-wild-gvng-banda-salvaje-chino-mangas', 'M', 10, 'WG-HOODIE-CN-SLV-BLK-M'),
  ('hoodie-wild-gvng-banda-salvaje-chino-mangas', 'L', 10, 'WG-HOODIE-CN-SLV-BLK-L'),
  ('hoodie-wild-gvng-banda-salvaje-chino-mangas', 'XL', 10, 'WG-HOODIE-CN-SLV-BLK-XL'),
  ('hoodie-wild-gvng-banda-salvaje-chino-mangas', 'XXL', 10, 'WG-HOODIE-CN-SLV-BLK-XXL'),

  ('hoodie-wild-gvng-banda-salvaje-chino-espalda', 'S', 10, 'WG-HOODIE-CN-BACK-BLK-S'),
  ('hoodie-wild-gvng-banda-salvaje-chino-espalda', 'M', 10, 'WG-HOODIE-CN-BACK-BLK-M'),
  ('hoodie-wild-gvng-banda-salvaje-chino-espalda', 'L', 10, 'WG-HOODIE-CN-BACK-BLK-L'),
  ('hoodie-wild-gvng-banda-salvaje-chino-espalda', 'XL', 10, 'WG-HOODIE-CN-BACK-BLK-XL'),
  ('hoodie-wild-gvng-banda-salvaje-chino-espalda', 'XXL', 10, 'WG-HOODIE-CN-BACK-BLK-XXL'),

  ('playera-oversize-wild-gvng-banda-salvaje-chino', 'S', 10, 'WG-TEE-CN-BLK-S'),
  ('playera-oversize-wild-gvng-banda-salvaje-chino', 'M', 10, 'WG-TEE-CN-BLK-M'),
  ('playera-oversize-wild-gvng-banda-salvaje-chino', 'L', 10, 'WG-TEE-CN-BLK-L'),
  ('playera-oversize-wild-gvng-banda-salvaje-chino', 'XL', 10, 'WG-TEE-CN-BLK-XL'),
  ('playera-oversize-wild-gvng-banda-salvaje-chino', 'XXL', 10, 'WG-TEE-CN-BLK-XXL')
) AS v(slug, size, stock, sku) ON v.slug = p.slug
WHERE NOT EXISTS (
  SELECT 1 FROM public.product_variants pv WHERE pv.sku = v.sku
);

-- Verificación
SELECT p.name, p.collection, p.base_price, count(v.id) AS variantes
FROM public.store_products p
LEFT JOIN public.product_variants v ON v.product_id = p.id
WHERE p.collection IN ('Anubis Arabic Collection', 'Anubis Chinese Collection')
GROUP BY p.id, p.name, p.collection, p.base_price
ORDER BY p.collection, p.name;
