-- =====================================================
-- SEED: Crew posts (noticias) + Wall posts (feed social)
-- Usuario admin: ec7ba40e-971a-4729-ad17-e83a0fdd42b5 (KAZTA)
-- =====================================================

-- Crew posts (noticias que aparecen en The Wild Times)
INSERT INTO public.crew_posts (id, author_id, title, content, image_url, post_type, status, published_at) VALUES
  ('cp200000-0000-0000-0000-000000000001', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Wild Gvng llega a Spotify',
    'Después de meses de negociaciones, toda la discografía de Wild Gvng ya está disponible en Spotify. 12 tracks, 3 EPs y un álbum completo. Enlace en nuestra bio.',
    'https://images.unsplash.com/photo-1611339555312-e607c8352fd7?w=800&q=80',
    'announcement', 'published', NOW() - INTERVAL '2 hours'),

  ('cp200000-0000-0000-0000-000000000002', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Convocatoria: Nuevos Talentos 2026',
    '¿Eres rapero, productor o beatmaker de Torreón y zona? Abrimos convocatoria para nuevos talentos. Los seleccionados tendrán sesiones gratis en Wild Gvng Studios. Manda tu demo a crew@wildgvng.com',
    'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=800&q=80',
    'announcement', 'published', NOW() - INTERVAL '1 day'),

  ('cp200000-0000-0000-0000-000000000003', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Wild Battle Vol. 13 — Fecha confirmada',
    'La próxima edición del Wild Battle será el 30 de agosto en el Foro Wild Gvng. 16 competidores, premio de $8,000 MXN + merch. Inscripciones abiertas hasta el 25 de agosto.',
    'https://images.unsplash.com/photo-1460723237483-7a6dc9d0b212?w=800&q=80',
    'event', 'published', NOW() - INTERVAL '3 days'),

  ('cp200000-0000-0000-0000-000000000004', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Nueva sudadera edición limitada',
    'Acaba de llegar la sudadera Wild Gvng edición "Desierto". 50 unidades, diseño exclusivo. Disponible en la tienda. Incluye parche bordado y estampado de alta calidad.',
    'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&q=80',
    'promotion', 'published', NOW() - INTERVAL '5 days'),

  ('cp200000-0000-0000-0000-000000000005', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Detrás del micrófono: Así grabamos "Fuego del Desierto"',
    'Les compartimos el behind the scenes de la grabación de nuestro hit más reciente. Producido por KAZTA, grabado en Wild Gvng Studios. El video completo ya está en nuestro canal de YouTube.',
    'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?w=800&q=80',
    'general', 'published', NOW() - INTERVAL '1 week'),

  ('cp200000-0000-0000-0000-000000000006', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb',
    'Noche de Freestyle en el Centro Histórico',
    'Este sábado 10 de agosto, sesión de freestyle sorpresa en el centro de Torreón. Punto de encuentro: Plaza Mayor a las 8 PM. Trae tu crew. Vamos a hacer historia.',
    'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=800&q=80',
    'event', 'published', NOW() - INTERVAL '8 hours'),

  ('cp200000-0000-0000-0000-000000000007', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Colaboración sorpresa en camino',
    'No podemos decir con quién todavía, pero la colaboración que viene va a romperla. Grabando toda la semana. Estén atentos 🔥',
    NULL,
    'general', 'published', NOW() - INTERVAL '6 hours'),

  ('cp200000-0000-0000-0000-000000000008', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Tips de producción para beats underground',
    'KAZTA comparte 5 tips para mejorar tus beats desde casa. Spoiler: el secreto está en las percusiones y el sample selection. Artículo completo en Wild Writings.',
    'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=800&q=80',
    'general', 'published', NOW() - INTERVAL '2 days')
ON CONFLICT (id) DO NOTHING;

-- Wall posts (feed social en The Wild Times)
INSERT INTO public.wall_posts (id, user_id, content, image_url, created_at) VALUES
  ('f2000000-0000-0000-0000-000000000001', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    '🔥 Acabo de terminar la mezcla del nuevo track. Esto suena como nada que hayan escuchado antes. ¿Quién quiere un preview?',
    NULL, NOW() - INTERVAL '30 minutes'),

  ('f2000000-0000-0000-0000-000000000002', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Noche de estudio en el laboratorio. Beat seleccion, escritura y grabación. Así se construye el sonido del desierto 🏜️🎤',
    'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=80',
    NOW() - INTERVAL '4 hours'),

  ('f2000000-0000-0000-0000-000000000003', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Gracias a todos los que vinieron al Wild Battle Vol. 12! La energía estuvo insane. El nivel de los competidores cada vez más alto. La próxima viene con sorpresa 💪',
    'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&q=80',
    NOW() - INTERVAL '1 day'),

  ('f2000000-0000-0000-0000-000000000004', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Recibiendo beats para el próximo proyecto. Si eres productor y quieres colaborar, mándame tu material por DM. Busco sonidos oscuros con texturas del norte 🎧',
    NULL, NOW() - INTERVAL '2 days'),

  ('f2000000-0000-0000-0000-000000000005', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb',
    'Haciendo selección de tracks para el mixtape de verano. Aparten el 15 de agosto. Esto se viene con todo 🔥🎶',
    'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=800&q=80',
    NOW() - INTERVAL '3 days'),

  ('f2000000-0000-0000-0000-000000000006', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'La disciplina vence al talento cuando el talento no trabaja. 8 horas en el estudio hoy. Mañana más. Esto es Wild Gvng.',
    NULL, NOW() - INTERVAL '4 days'),

  ('f2000000-0000-0000-0000-000000000007', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Nuevo merch preview 🔥 ¿Qué les parece el diseño? Pronto disponibles en la tienda',
    'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&q=80',
    NOW() - INTERVAL '5 days'),

  ('f2000000-0000-0000-0000-000000000008', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Colaboración confirmada con @ralfdiaz. Esto que viene es historia pura. Dos estilos, una visión. Pronto 📀',
    NULL, NOW() - INTERVAL '6 days')
ON CONFLICT (id) DO NOTHING;

-- Likes en algunos posts de KAZTA
INSERT INTO public.wall_likes (post_id, user_id) VALUES
  ('f2000000-0000-0000-0000-000000000001', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'),
  ('f2000000-0000-0000-0000-000000000001', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790'),
  ('f2000000-0000-0000-0000-000000000002', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'),
  ('f2000000-0000-0000-0000-000000000003', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'),
  ('f2000000-0000-0000-0000-000000000003', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790'),
  ('f2000000-0000-0000-0000-000000000005', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5'),
  ('f2000000-0000-0000-0000-000000000007', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb')
ON CONFLICT DO NOTHING;

-- Comentarios en posts
INSERT INTO public.wall_comments (id, post_id, user_id, content, created_at) VALUES
  ('c2000000-0000-0000-0000-000000000001', 'f2000000-0000-0000-0000-000000000001', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb',
    'Yo quiero escucharlo hermano! Avienta un snippet 🔥', NOW() - INTERVAL '25 minutes'),
  ('c2000000-0000-0000-0000-000000000002', 'f2000000-0000-0000-0000-000000000001', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790',
    'Siempre rompiendo cabezas. Este año es nuestro 💪', NOW() - INTERVAL '20 minutes'),
  ('c2000000-0000-0000-0000-000000000003', 'f2000000-0000-0000-0000-000000000003', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb',
    'Estuvo al cien viejo! La próxima vamos con más 🏆', NOW() - INTERVAL '12 hours'),
  ('c2000000-0000-0000-0000-000000000004', 'f2000000-0000-0000-0000-000000000002', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790',
    'Se ve cabrón el estudio. Algún día me das el tour 👀', NOW() - INTERVAL '3 hours'),
  ('c2000000-0000-0000-0000-000000000005', 'f2000000-0000-0000-0000-000000000005', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Vamos con todo Ralf! Este mixtape va a estar épico 🔥', NOW() - INTERVAL '2 days'),
  ('c2000000-0000-0000-0000-000000000006', 'f2000000-0000-0000-0000-000000000007', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb',
    'Ese diseño está brutal. Me apunto una sudadera!', NOW() - INTERVAL '4 days')
ON CONFLICT (id) DO NOTHING;
