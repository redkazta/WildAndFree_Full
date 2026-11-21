-- =====================================================
-- SEED: información de ejemplo para TODOS los usuarios
-- - Completa nombre, usuario, avatar, bio y ubicación
-- - Crea 3 historias y 2 destacadas por usuario
-- Ejecutar en el SQL Editor de Supabase.
-- Idempotente: no duplica historias ni destacadas.
-- =====================================================

DO $$
DECLARE
  r RECORD;
  i INTEGER := 0;
  v_base TEXT;
  v_username TEXT;
  v_avatar TEXT;
  v_bio TEXT;
  v_hl UUID;
  avatars TEXT[] := ARRAY[
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=240&h=240&fit=crop&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=240&h=240&fit=crop&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=240&h=240&fit=crop&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=240&h=240&fit=crop&q=80',
    'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=240&h=240&fit=crop&q=80',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=240&h=240&fit=crop&q=80'
  ];
  bios TEXT[] := ARRAY[
    'Freestyler de Torreón. La calle es el escenario y la rima la única ley.',
    'Productor y beatmaker. Buscando texturas nuevas para la Banda Salvaje.',
    'Miembro de Wild Gvng. Amor por el hip-hop y la cultura underground.',
    'Escribo lo que otros callan. La pluma también es un arma.',
    'Del barrio para el mundo. Si no es real, no cuenta.',
    'Fan de la vieja escuela, aquí por la música y la crew.'
  ];
  story_imgs TEXT[] := ARRAY[
    'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=700&q=80',
    'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=700&q=80',
    'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=700&q=80',
    'https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?w=700&q=80',
    'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=700&q=80',
    'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=700&q=80'
  ];
BEGIN
  FOR r IN
    SELECT p.id, p.nombre, p.username, p.bio, p.avatar_url, p.ubicacion,
           u.email, u.raw_user_meta_data AS meta
    FROM public.profiles p
    LEFT JOIN auth.users u ON u.id = p.id
    ORDER BY p.created_at NULLS FIRST
  LOOP
    i := i + 1;

    -- Nombre
    IF r.nombre IS NULL OR BTRIM(r.nombre) = '' THEN
      v_base := COALESCE(
        NULLIF(BTRIM(r.meta->>'nombre'), ''),
        NULLIF(BTRIM(r.meta->>'full_name'), ''),
        NULLIF(BTRIM(r.meta->>'name'), ''),
        NULLIF(split_part(COALESCE(r.email, ''), '@', 1), ''),
        'Wild Member'
      );
      UPDATE public.profiles SET nombre = initcap(v_base) WHERE id = r.id;
    END IF;

    -- Usuario
    IF r.username IS NULL OR BTRIM(r.username) = '' THEN
      v_base := COALESCE(
        NULLIF(BTRIM(r.meta->>'username'), ''),
        NULLIF(split_part(COALESCE(r.email, ''), '@', 1), ''),
        'wild' || left(r.id::text, 6)
      );
      v_username := lower(regexp_replace(v_base, '[^a-zA-Z0-9._-]', '', 'g'));
      IF v_username = '' THEN
        v_username := 'wild' || left(r.id::text, 6);
      END IF;
      IF EXISTS (
        SELECT 1 FROM public.profiles
        WHERE lower(username) = v_username AND id <> r.id
      ) THEN
        v_username := v_username || '_' || left(r.id::text, 4);
      END IF;
      UPDATE public.profiles SET username = v_username WHERE id = r.id;
    END IF;

    -- Avatar
    IF r.avatar_url IS NULL OR BTRIM(r.avatar_url) = '' THEN
      v_avatar := avatars[((i - 1) % array_length(avatars, 1)) + 1];
      UPDATE public.profiles SET avatar_url = v_avatar WHERE id = r.id;
    END IF;

    -- Bio
    IF r.bio IS NULL OR BTRIM(r.bio) = '' THEN
      v_bio := bios[((i - 1) % array_length(bios, 1)) + 1];
      UPDATE public.profiles SET bio = v_bio WHERE id = r.id;
    END IF;

    -- Ubicación
    IF r.ubicacion IS NULL OR BTRIM(r.ubicacion) = '' THEN
      UPDATE public.profiles SET ubicacion = 'Torreón, Coahuila' WHERE id = r.id;
    END IF;

    -- Historias (3 por usuario)
    IF NOT EXISTS (SELECT 1 FROM public.stories WHERE user_id = r.id) THEN
      INSERT INTO public.stories (user_id, media_url, created_at) VALUES
        (r.id, story_imgs[((i - 1) % array_length(story_imgs, 1)) + 1], NOW() - INTERVAL '3 days'),
        (r.id, story_imgs[(i % array_length(story_imgs, 1)) + 1], NOW() - INTERVAL '2 days'),
        (r.id, story_imgs[((i + 1) % array_length(story_imgs, 1)) + 1], NOW() - INTERVAL '1 day');
    END IF;

    -- Destacadas (2 por usuario)
    IF NOT EXISTS (SELECT 1 FROM public.highlights WHERE user_id = r.id) THEN
      -- Destacada 1: Shows (historias 1 y 2)
      INSERT INTO public.highlights (user_id, title, cover_url)
      SELECT r.id, 'Shows', s.media_url
      FROM public.stories s
      WHERE s.user_id = r.id
      ORDER BY s.created_at ASC
      LIMIT 1
      RETURNING id INTO v_hl;

      IF v_hl IS NOT NULL THEN
        INSERT INTO public.highlight_stories (highlight_id, story_id, position)
        SELECT v_hl, id, (row_number() OVER (ORDER BY created_at))::int - 1
        FROM (
          SELECT id, created_at
          FROM public.stories
          WHERE user_id = r.id
          ORDER BY created_at ASC
          LIMIT 2
        ) s;
      END IF;

      -- Destacada 2: Estudio (historias 2 y 3)
      v_hl := NULL;
      INSERT INTO public.highlights (user_id, title, cover_url)
      SELECT r.id, 'Estudio', s.media_url
      FROM public.stories s
      WHERE s.user_id = r.id
      ORDER BY s.created_at DESC
      LIMIT 1
      RETURNING id INTO v_hl;

      IF v_hl IS NOT NULL THEN
        INSERT INTO public.highlight_stories (highlight_id, story_id, position)
        SELECT v_hl, id, (row_number() OVER (ORDER BY created_at))::int - 1
        FROM (
          SELECT id, created_at
          FROM public.stories
          WHERE user_id = r.id
          ORDER BY created_at DESC
          LIMIT 2
        ) s;
      END IF;
    END IF;
  END LOOP;
END $$;

-- Verificación
SELECT
  (SELECT count(*) FROM public.profiles) AS perfiles,
  (SELECT count(*) FROM public.stories) AS historias,
  (SELECT count(*) FROM public.highlights) AS destacadas,
  (SELECT count(*) FROM public.highlight_stories) AS historias_en_destacadas;
