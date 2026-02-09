-- Agregar tags adicionales para más personalización
INSERT INTO public.tags (name, color, animation) VALUES
  -- VIP y Premium
  ('VIP Member', '#FFD700', 'member-shine'),
  ('Premium Member', '#C0C0C0', 'member-shine'),
  ('Elite Member', '#4169E1', 'member-shine'),
  
  -- Creativos
  ('Music Producer', '#FF6347', 'artist-sparkle'),
  ('Beat Maker', '#FF1493', 'artist-sparkle'),
  ('Sound Engineer', '#00CED1', 'artist-sparkle'),
  ('Video Creator', '#FF4500', 'media-pulse'),
  ('Content Creator', '#FF69B4', 'media-pulse'),
  ('Photographer', '#8B4513', 'media-pulse'),
  
  -- Tecnología
  ('Frontend Developer', '#61DAFB', 'developer-code'),
  ('Backend Developer', '#68A063', 'developer-code'),
  ('Full Stack Developer', '#3178C6', 'developer-code'),
  ('Mobile Developer', '#F0DB4F', 'developer-code'),
  ('DevOps Engineer', '#2496ED', 'developer-code'),
  
  -- Diseño
  ('UI Designer', '#FF6B6B', 'designer-flow'),
  ('UX Designer', '#4ECDC4', 'designer-flow'),
  ('Brand Designer', '#45B7D1', 'designer-flow'),
  ('Motion Designer', '#96CEB4', 'designer-flow'),
  ('3D Artist', '#FFEAA7', 'designer-flow'),
  
  -- Edición
  ('Video Editor', '#E17055', 'editor-creative'),
  ('Photo Editor', '#FD79A8', 'editor-creative'),
  ('Graphic Designer', '#FDCB6E', 'editor-creative'),
  ('Digital Artist', '#6C5CE7', 'editor-creative'),
  
  -- Música y Cultura
  ('Rapper', '#00B894', 'artist-sparkle'),
  ('Singer', '#E84393', 'artist-sparkle'),
  ('DJ', '#0984E3', 'artist-sparkle'),
  ('Dancer', '#FDCB6E', 'artist-sparkle'),
  ('Poet', '#A29BFE', 'artist-sparkle'),
  ('Writer', '#FD79A8', 'artist-sparkle'),
  
  -- Comunidad
  ('Community Manager', '#00B894', 'media-pulse'),
  ('Event Organizer', '#E17055', 'media-pulse'),
  ('Promoter', '#FDCB6E', 'media-pulse'),
  ('Influencer', '#E84393', 'media-pulse'),
  
  -- Soporte
  ('Support Team', '#00CEC9', 'member-shine'),
  ('Moderator', '#6C5CE7', 'member-shine'),
  ('Helper', '#A8E6CF', 'member-shine'),
  ('Guide', '#FFD93D', 'member-shine'),
  
  -- Especial
  ('Beta Tester', '#FF6B6B', 'member-shine'),
  ('Early Adopter', '#4ECDC4', 'member-shine'),
  ('Founding Member', '#45B7D1', 'member-shine'),
  ('OG Member', '#96CEB4', 'member-shine'),
  ('Legendary', '#FFEAA7', 'golden-pulse')
ON CONFLICT (name) DO NOTHING;