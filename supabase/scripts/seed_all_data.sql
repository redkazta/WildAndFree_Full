-- =====================================================
-- WILD GNVG - SEED DATA COMPLETO
-- Ejecutar DESPUÉS de las migraciones y RLS fixes
-- Usa service_role key (bypass RLS)
-- =====================================================

-- =====================================================
-- 0. OBTENER UUIDs DE LOS USUARIOS EXISTENTES
-- =====================================================
DO $$
DECLARE
  kazta_id UUID;
  ralf_id UUID;
  fan1_id UUID;
  fan2_id UUID;
  artista1_id UUID;
  artista2_id UUID;
  tag_cat_geek INT;
  tag_cat_era INT;
  tag_cat_style INT;
  tag_cat_badge INT;
  sp1_id UUID;
  sp2_id UUID;
  sp3_id UUID;
  prod1_id UUID;
  prod2_id UUID;
  prod3_id UUID;
  var1_id UUID;
  var2_id UUID;
  var3_id UUID;
  var4_id UUID;
  var5_id UUID;
  var6_id UUID;
  order1_id UUID;
  order2_id UUID;
  ep1_id UUID;
  ep2_id UUID;
  ep3_id UUID;
  free1_id UUID;
  free2_id UUID;
  free3_id UUID;
  battle1_id UUID;
  battle2_id UUID;
BEGIN

  -- Buscar UUIDs de admins existentes
  SELECT id INTO kazta_id FROM auth.users WHERE email = 'kazta@wildgvng.com.mx' LIMIT 1;
  SELECT id INTO ralf_id FROM auth.users WHERE email = 'ralfdiaz@wildgvng.com.mx' LIMIT 1;

  -- Si no existen, usar UUIDs placeholder (el admin debe crearlos primero via auth)
  IF kazta_id IS NULL THEN
    RAISE NOTICE 'AVISO: kazta@wildgvng.com.mx no existe en auth.users. Crea la cuenta primero.';
    kazta_id := 'a0000000-0000-0000-0000-000000000001';
  END IF;
  IF ralf_id IS NULL THEN
    RAISE NOTICE 'AVISO: ralfdiaz@wildgvng.com.mx no existe en auth.users. Crea la cuenta primero.';
    ralf_id := 'a0000000-0000-0000-0000-000000000002';
  END IF;

  RAISE NOTICE 'Kazta ID: %, Ralf ID: %', kazta_id, ralf_id;

  -- =====================================================
  -- 1. PROFILES (los admins ya pueden tener profile por trigger)
  -- =====================================================
  INSERT INTO public.profiles (id, nombre, username, bio, phone, ubicacion, website, instagram_url, is_verified_artist, verification_status)
  VALUES
    (kazta_id, 'KAZTA', 'kazta', 'Fundador de Wild Gvng. Productor musical y freestyler. Torreón, Coahuila.', '+52 (871) 200-0001', 'Torreón, Coahuila, México', 'https://wildgvng.com', 'https://instagram.com/kazta_wg', true, 'approved'),
    (ralf_id, 'RALF DÍAZ', 'ralfdiaz', 'Co-fundador Wild Gvng. DJ y manager de la crew. Siempre en la rima.', '+52 (871) 200-0002', 'Torreón, Coahuila, México', 'https://wildgvng.com', 'https://instagram.com/ralfdiaz_wg', true, 'approved')
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    username = EXCLUDED.username,
    bio = EXCLUDED.bio,
    ubicacion = EXCLUDED.ubicacion;

  -- Crear fans de ejemplo (UUIDs deterministas)
  fan1_id := 'f0000000-0000-0000-0000-000000000001';
  fan2_id := 'f0000000-0000-0000-0000-000000000002';
  artista1_id := 'a1000000-0000-0000-0000-000000000001';
  artista2_id := 'a1000000-0000-0000-0000-000000000002';

  -- Profiles de fans y artistas mock (solo si no existen)
  INSERT INTO public.profiles (id, nombre, username, bio, ubicacion, is_verified_artist, verification_status)
  VALUES
    (fan1_id, 'Carlos López', 'carlos_lo', 'Fan de Wild Gvng desde 2019. Torreón.', 'Torreón, Coahuila', false, 'none'),
    (fan2_id, 'María García', 'mari_garcia', 'Freestylera amateur. Sigo todas las batallas.', 'Gómez Palacio, Durango', false, 'none'),
    (artista1_id, 'MR. FLUX', 'mrflux', 'Rapero underground. flows sucios y punchlines pesados.', 'Torreón, Coahuila', true, 'approved'),
    (artista2_id, 'LIL BRAZA', 'lilbraza', 'Trapero del norte. beats pesados.', 'Monterrey, Nuevo León', true, 'approved')
  ON CONFLICT (id) DO NOTHING;

  -- =====================================================
  -- 2. USER ROLES
  -- =====================================================
  -- Asignar roles a los admins
  INSERT INTO public.user_roles (user_id, role_id)
  SELECT kazta_id, id FROM public.roles WHERE internal_name = 'owner'
  ON CONFLICT DO NOTHING;

  INSERT INTO public.user_roles (user_id, role_id)
  SELECT ralf_id, id FROM public.roles WHERE internal_name = 'admin'
  ON CONFLICT DO NOTHING;

  -- Artist roles
  INSERT INTO public.user_roles (user_id, role_id)
  SELECT artista1_id, id FROM public.roles WHERE internal_name = 'artist'
  ON CONFLICT DO NOTHING;

  INSERT INTO public.user_roles (user_id, role_id)
  SELECT artista2_id, id FROM public.roles WHERE internal_name = 'artist'
  ON CONFLICT DO NOTHING;

  -- Fan roles
  INSERT INTO public.user_roles (user_id, role_id)
  SELECT fan1_id, id FROM public.roles WHERE internal_name = 'fan'
  ON CONFLICT DO NOTHING;

  INSERT INTO public.user_roles (user_id, role_id)
  SELECT fan2_id, id FROM public.roles WHERE internal_name = 'fan'
  ON CONFLICT DO NOTHING;

  -- =====================================================
  -- 3. TOKENS
  -- =====================================================
  INSERT INTO public.user_tokens (user_id, balance)
  VALUES
    (kazta_id, 5000),
    (ralf_id, 3500),
    (fan1_id, 150),
    (fan2_id, 300),
    (artista1_id, 800),
    (artista2_id, 600)
  ON CONFLICT (user_id) DO UPDATE SET balance = EXCLUDED.balance;

  -- =====================================================
  -- 4. TAG CATEGORIES Y TAGS
  -- =====================================================
  INSERT INTO public.tag_categories (name, description) VALUES
    ('Era', 'Época o generación del freestyle'),
    ('Estilo', 'Estilo musical o de rima'),
    ('Logro', 'Logros y achievements'),
    ('Badge', 'Badges decorativos')
  ON CONFLICT (name) DO NOTHING
  RETURNING id, name INTO tag_cat_era, tag_cat_style;

  -- Si el RETURNING no funcionó por ON CONFLICT, buscar los IDs
  SELECT id INTO tag_cat_era FROM public.tag_categories WHERE name = 'Era';
  SELECT id INTO tag_cat_style FROM public.tag_categories WHERE name = 'Estilo';
  SELECT id INTO tag_cat_geek FROM public.tag_categories WHERE name = 'Logro';
  SELECT id INTO tag_cat_badge FROM public.tag_categories WHERE name = 'Badge';

  INSERT INTO public.tags (name, color, animation, category_id, is_purchasable, token_price) VALUES
    -- Era
    ('OG', '#FFD700', 'glow', tag_cat_era, true, 500),
    ('Clásico', '#C0C0C0', 'none', tag_cat_era, true, 200),
    ('Nueva Ola', '#00FF88', 'pulse', tag_cat_era, true, 150),
    -- Estilo
    ('Flow Lírico', '#FF6B35', 'none', tag_cat_style, true, 100),
    ('Punchline King', '#E91E63', 'bounce', tag_cat_style, true, 300),
    ('Doble Tempo', '#9C27B0', 'shake', tag_cat_style, true, 250),
    ('Storyteller', '#2196F3', 'none', tag_cat_style, true, 100),
    ('Battle Tested', '#FF5722', 'glow', tag_cat_style, true, 400),
    -- Logro
    ('Primer Battle', '#4CAF50', 'none', tag_cat_geek, false, null),
    ('10 Batallas', '#FF9800', 'none', tag_cat_geek, false, null),
    ('Top 5 Ranking', '#F44336', 'pulse', tag_cat_geek, false, null),
    ('Fan Leal', '#00BCD4', 'glow', tag_cat_geek, false, null),
    -- Badge
    ('Verified', '#FFD700', 'glow', tag_cat_badge, false, null),
    ('Staff', '#E040FB', 'none', tag_cat_badge, false, null),
    ('Fundador', '#FF6D00', 'pulse', tag_cat_badge, false, null)
  ON CONFLICT (name) DO NOTHING;

  -- Asignar tags a los admins
  INSERT INTO public.user_has_tags (user_id, tag_id)
  SELECT kazta_id, id FROM public.tags WHERE name IN ('OG', 'Verified', 'Fundador', 'Battle Tested', 'Punchline King')
  ON CONFLICT DO NOTHING;

  INSERT INTO public.user_has_tags (user_id, tag_id)
  SELECT ralf_id, id FROM public.tags WHERE name IN ('OG', 'Verified', 'Staff', 'Flow Lírico')
  ON CONFLICT DO NOTHING;

  INSERT INTO public.user_has_tags (user_id, tag_id)
  SELECT artista1_id, id FROM public.tags WHERE name IN ('Nueva Ola', 'Verified', 'Doble Tempo')
  ON CONFLICT DO NOTHING;

  INSERT INTO public.user_has_tags (user_id, tag_id)
  SELECT artista2_id, id FROM public.tags WHERE name IN ('Nueva Ola', 'Verified', 'Storyteller')
  ON CONFLICT DO NOTHING;

  INSERT INTO public.user_has_tags (user_id, tag_id)
  SELECT fan1_id, id FROM public.tags WHERE name IN ('Clásico', 'Fan Leal')
  ON CONFLICT DO NOTHING;

  INSERT INTO public.user_has_tags (user_id, tag_id)
  SELECT fan2_id, id FROM public.tags WHERE name IN ('Nueva Ola', 'Primer Battle')
  ON CONFLICT DO NOTHING;

  -- =====================================================
  -- 5. STORE PRODUCTS (merch Wild Gvng)
  -- =====================================================
  INSERT INTO public.store_products (id, name, description, base_price, category, is_active)
  VALUES
    ('p0000000-0000-0000-0000-000000000001', 'Playera Wild Gvng Logo', 'Playera negra bordada con el logo original de Wild Gvng. 100% algodón.', 350.00, 'playeras', true),
    ('p0000000-0000-0000-0000-000000000002', 'Gorra WG Snapback', 'Gorra snapback negra con logo WG bordado. Ajustable.', 280.00, 'gorras', true),
    ('p0000000-0000-0000-0000-000000000003', 'Sudadera Wild Gvng Premium', 'Sudadera con capucha, diseño exclusivo. Algodón franela.', 650.00, 'sudaderas', true)
  ON CONFLICT (id) DO NOTHING
  RETURNING id, name INTO prod1_id, prod2_id;

  SELECT id INTO prod1_id FROM public.store_products WHERE name = 'Playera Wild Gvng Logo';
  SELECT id INTO prod2_id FROM public.store_products WHERE name = 'Gorra WG Snapback';
  SELECT id INTO prod3_id FROM public.store_products WHERE name = 'Sudadera Wild Gvng Premium';

  -- Variantes
  INSERT INTO public.product_variants (id, product_id, size, color, stock, sku)
  VALUES
    (gen_random_uuid(), prod1_id, 'S', 'Negro', 25, 'WG-TSHIRT-S-BLK'),
    (gen_random_uuid(), prod1_id, 'M', 'Negro', 30, 'WG-TSHIRT-M-BLK'),
    (gen_random_uuid(), prod1_id, 'L', 'Negro', 20, 'WG-TSHIRT-L-BLK'),
    (gen_random_uuid(), prod1_id, 'XL', 'Negro', 15, 'WG-TSHIRT-XL-BLK'),
    (gen_random_uuid(), prod2_id, 'Única', 'Negro', 40, 'WG-CAP-ONE-BLK'),
    (gen_random_uuid(), prod2_id, 'Única', 'Blanco', 20, 'WG-CAP-ONE-WHT'),
    (gen_random_uuid(), prod3_id, 'M', 'Negro', 15, 'WG-HOODIE-M-BLK'),
    (gen_random_uuid(), prod3_id, 'L', 'Negro', 18, 'WG-HOODIE-L-BLK'),
    (gen_random_uuid(), prod3_id, 'XL', 'Gris oscuro', 12, 'WG-HOODIE-XL-DGR')
  ON CONFLICT DO NOTHING;

  -- =====================================================
  -- 6. STORE ORDERS (pedidos de ejemplo)
  -- =====================================================
  INSERT INTO public.store_orders (id, user_id, status, shipping_type, payment_method, total, shipping_address, notes)
  VALUES
    ('o0000000-0000-0000-0000-000000000001', fan1_id, 'delivered', 'carrier', 'transfer', 630.00, 'Calle Reforma 123, Torreón, Coahuila', 'Pedido completado - 1 playera M + 1 gorra'),
    ('o0000000-0000-0000-0000-000000000002', fan2_id, 'processing', 'pickup', 'cash', 350.00, null, 'Va por recoger a la tienda')
  ON CONFLICT (id) DO NOTHING;

  SELECT id INTO order1_id FROM public.store_orders WHERE id = 'o0000000-0000-0000-0000-000000000001';

  -- =====================================================
  -- 7. EVENTS (próximos eventos Wild Gvng)
  -- =====================================================
  INSERT INTO public.events (name, description, event_type, event_date, location, is_active, created_by)
  VALUES
    ('Wild Battle Vol. 12', 'Batalla de freestyle 1v1. 16 competidores. Premio: $5,000 MXN + tokens exclusivos.', 'battle', '2026-07-15 20:00:00-06', 'Foro Wild Gvng, Torreón, Coahuila', true, kazta_id),
    ('Noche Underground', 'Concierto con artistas de la crew. Invitados especiales del norte.', 'concert', '2026-08-02 21:00:00-06', 'Salón Caribe, Torreón, Coahuila', true, kazta_id),
    ('Meet & Greet Crew', 'Conoce a los artistas de Wild Gvng. Fotos, autógrafos y merch exclusivo.', 'meet_greet', '2026-08-20 17:00:00-06', 'Casa Bosque Venustiano Carranza, Torreón', true, ralf_id),
    ('Wild Battle Vol. 13', 'Batalla de freestyle 2v2. Equipmentos de 3. Premio: $8,000 MXN.', 'battle', '2026-09-05 20:00:00-06', 'Foro Wild Gvng, Torreón, Coahuila', true, kazta_id)
  ON CONFLICT DO NOTHING;

  -- =====================================================
  -- 8. EXCLUSIVE CONTENT
  -- =====================================================
  INSERT INTO public.exclusive_content (user_id, title, description, content_type, file_url, token_price, status, views, likes)
  VALUES
    (kazta_id, 'Behind the Scenes: Wild Battle Vol. 11', 'Video exclusivo del backstage de la última batalla. Preparación, nervios y la mejor rima del night.', 'video', 'https://storage.supabase.co/radio-audio/covers/bts-wb11.mp4', 50, 'published', 234, 45),
    (kazta_id, 'Freestyle Session #7 - KAZTA', 'Sesión de freestyle en vivo desde el estudio. 15 minutos de flow puro.', 'audio', 'https://storage.supabase.co/radio-audio/episodes/session-7-kazta.mp3', 30, 'published', 189, 32),
    (ralf_id, 'Mix: Los Mejores Punchlines 2025', 'Recopilación de los mejores punchlines del año. Solo para miembros.', 'audio', 'https://storage.supabase.co/radio-audio/episodes/mix-punchlines-2025.mp3', 40, 'published', 312, 67),
    (artista1_id, 'Studio Session: MR. FLUX x KAZTA', 'Colaboración exclusiva en estudio. Beat inédito.', 'video', 'https://storage.supabase.co/radio-audio/covers/flux-kazta-session.mp4', 75, 'published', 156, 28),
    (artista2_id, 'Acoustic Freestyle - LIL BRAZA', 'Freestyle acústico sin beat. Pura letra.', 'audio', 'https://storage.supabase.co/radio-audio/episodes/acoustic-lilbraza.mp3', 25, 'pending', 0, 0)
  ON CONFLICT DO NOTHING;

  -- =====================================================
  -- 9. FREESTYLERS (para el módulo Versus)
  -- =====================================================
  INSERT INTO public.freestylers (id, name, slug, bio, is_active)
  VALUES
    (gen_random_uuid(), 'KAZTA', 'kazta', 'Fundador de Wild Gvng. Flow letal y punchlines certificados.', true),
    (gen_random_uuid(), 'RALF DÍAZ', 'ralf-diaz', 'Co-fundador. Versátil, adapta su flow a cualquier beat.', true),
    (gen_random_uuid(), 'MR. FLUX', 'mr-flux', 'El más rápido del norte. Doble tempo letal.', true),
    (gen_random_uuid(), 'LIL BRAZA', 'lil-braza', 'Storyteller del trap norteño. Letras con profundidad.', true)
  ON CONFLICT (slug) DO NOTHING;

  -- =====================================================
  -- 10. RADIO CONFIG (ya tiene default por migración, actualizar)
  -- =====================================================
  UPDATE public.radio_config SET
    current_show = 'Wild Gvng Radio',
    current_host = 'KAZTA',
    whatsapp = '+52 (871) 200-0001',
    auto_radio = true,
    updated_at = NOW()
  WHERE id = 1;

  -- Tracks de auto-radio (Spotify embeds)
  INSERT INTO public.radio_auto_tracks (spotify_track_url, spotify_embed_url, title, artist, sort_order, is_active)
  VALUES
    ('https://open.spotify.com/track/4cOdK2wGTHBFjDClbCEJCl', 'https://open.spotify.com/embed/track/4cOdK2wGTHBFjDClbCEJCl?utm_source=generator&theme=0', 'Mock Track 1', 'Artista Mock A', 1, true),
    ('https://open.spotify.com/track/6rqhFgbbKwnb9MLmUQDhG4', 'https://open.spotify.com/embed/track/6rqhFgbbKwnb9MLmUQDhG4?utm_source=generator&theme=0', 'Mock Track 2', 'Artista Mock B', 2, true),
    ('https://open.spotify.com/track/3n3PpamBvE39lheLQC6TDr', 'https://open.spotify.com/embed
