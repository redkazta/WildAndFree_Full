-- =====================================================
-- SEED: Wall Posts, Comments, Likes, Reposts + Crew Posts
-- =====================================================

-- Seed wall_posts (feed público)
INSERT INTO public.wall_posts (id, user_id, content, image_url, created_at) VALUES
  ('f0000000-0000-0000-0000-000000000001', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5', '🔥 Noche de estudio en el laboratorio. Nuevo beat en camino. ¿Quién quiere escucharlo primero?', NULL, NOW() - INTERVAL '2 hours'),
  ('f0000000-0000-0000-0000-000000000002', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb', '🎬 Filmando el nuevo video. Esto va a estar cabrón.', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=80', NOW() - INTERVAL '5 hours'),
  ('f0000000-0000-0000-0000-000000000003', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5', 'Gracias a todos los que vinieron al Wild Battle Vol. 12! La próxima viene más fuerte 💪', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&q=80', NOW() - INTERVAL '1 day'),
  ('f0000000-0000-0000-0000-000000000004', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790', '📢 Recordatorio: Este sábado tenemos sesión de estudio abierta para miembros. Cupo limitado.', NULL, NOW() - INTERVAL '2 days'),
  ('f0000000-0000-0000-0000-000000000005', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb', 'Nuevo merch disponible en la tienda. Sudaderas edición limitada 🔥', 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&q=80', NOW() - INTERVAL '3 days')
ON CONFLICT (id) DO NOTHING;

-- Seed wall_comments
INSERT INTO public.wall_comments (id, post_id, user_id, content, created_at) VALUES
  ('c0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb', 'Yo quiero escucharlo! Avienta ese preview 🎧', NOW() - INTERVAL '1 hour'),
  ('c0000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000001', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790', 'Siempre rompiendo cabezas 🔥', NOW() - INTERVAL '30 minutes'),
  ('c0000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000002', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5', 'Se ve épico! Cuando sale?', NOW() - INTERVAL '4 hours'),
  ('c0000000-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000003', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb', 'Estuvo al cien! La próxima vamos con más 🏆', NOW() - INTERVAL '20 hours')
ON CONFLICT (id) DO NOTHING;

-- Seed wall_likes
INSERT INTO public.wall_likes (post_id, user_id) VALUES
  ('f0000000-0000-0000-0000-000000000001', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'),
  ('f0000000-0000-0000-0000-000000000001', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790'),
  ('f0000000-0000-0000-0000-000000000002', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5'),
  ('f0000000-0000-0000-0000-000000000002', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790'),
  ('f0000000-0000-0000-0000-000000000003', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'),
  ('f0000000-0000-0000-0000-000000000003', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790'),
  ('f0000000-0000-0000-0000-000000000004', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5'),
  ('f0000000-0000-0000-0000-000000000005', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5'),
  ('f0000000-0000-0000-0000-000000000005', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb')
ON CONFLICT DO NOTHING;

-- Seed wall_reposts
INSERT INTO public.wall_reposts (post_id, user_id) VALUES
  ('f0000000-0000-0000-0000-000000000001', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790'),
  ('f0000000-0000-0000-0000-000000000005', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5')
ON CONFLICT DO NOTHING;

-- Seed crew_posts (publicaciones de artistas/crew, visibles en perfil de artista)
INSERT INTO public.crew_posts (id, author_id, title, content, image_url, post_type, status, published_at) VALUES
  ('cp000000-0000-0000-0000-000000000001', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5', 'Nuevo Track: Fuego del Desierto', 'Después de semanas en el estudio, por fin les traigo mi nuevo sencillo. Producido por mí, grabado en Wild Gvng Studios. Espero que lo disfruten 🔥', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=80', 'announcement', 'published', NOW() - INTERVAL '1 day'),
  ('cp000000-0000-0000-0000-000000000002', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5', NULL, 'En el estudio toda la noche. Esto que viene va a romperla. ¿Adivinen quién está colaborando? 🔥', NULL, 'general', 'published', NOW() - INTERVAL '3 hours'),
  ('cp000000-0000-0000-0000-000000000003', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb', 'Freestyle Session: Tormenta en el Desierto', 'Grabamos una sesión de freestyle improvisado con la crew completa. Aquí el resultado 🎤', 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=800&q=80', 'announcement', 'published', NOW() - INTERVAL '2 days'),
  ('cp000000-0000-0000-0000-000000000004', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb', NULL, 'Colaboración en camino con un artista sorpresa. Pronto daré más detalles 🤫', NULL, 'promotion', 'published', NOW() - INTERVAL '1 week')
ON CONFLICT (id) DO NOTHING;
