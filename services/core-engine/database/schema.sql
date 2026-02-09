-- COMPREHENSIVE TAG SYSTEM SCHEMA
-- This script creates the complete tag system with security in mind
-- All tag logic is backend-driven, no frontend exposure of internal data

-- =====================================================
-- CORE TAGS TABLE
-- Stores all available tags with their visual properties
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tags (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  color VARCHAR(7) DEFAULT '#ffffff',
  animation VARCHAR(50) DEFAULT 'none',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- USER-TAG RELATIONSHIP TABLE
-- Junction table for many-to-many relationship
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_has_tags (
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  tag_id INTEGER REFERENCES public.tags(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, tag_id)
);

-- =====================================================
-- USER TAGS CACHE COLUMN
-- Array of tag IDs for quick access (maintained by triggers)
-- =====================================================
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS user_tags INTEGER[] DEFAULT '{}';

-- =====================================================
-- ROLE-BASED TAG SYSTEM
-- Separate table for invisible roles (permissions only)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  permissions JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- USER-ROLE RELATIONSHIP
-- Invisible roles for permissions (not displayed as tags)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_has_roles (
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  role_id INTEGER REFERENCES public.roles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, role_id)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_user_has_tags_user_id ON public.user_has_tags(user_id);
CREATE INDEX IF NOT EXISTS idx_user_has_tags_tag_id ON public.user_has_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_user_has_roles_user_id ON public.user_has_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_has_roles_role_id ON public.user_has_roles(role_id);
CREATE INDEX IF NOT EXISTS idx_tags_name ON public.tags(name);

-- =====================================================
-- TRIGGERS TO MAINTAIN USER_TAGS COLUMN
-- Automatically updates user_tags array when tags change
-- =====================================================
CREATE OR REPLACE FUNCTION update_user_tags_column()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    UPDATE public.users 
    SET user_tags = (
      SELECT COALESCE(array_agg(tag_id ORDER BY tag_id), '{}')
      FROM public.user_has_tags 
      WHERE user_id = NEW.user_id
    )
    WHERE id = NEW.user_id;
    
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.users 
    SET user_tags = (
      SELECT COALESCE(array_agg(tag_id ORDER BY tag_id), '{}')
      FROM public.user_has_tags 
      WHERE user_id = OLD.user_id
    )
    WHERE id = OLD.user_id;
    
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
DROP TRIGGER IF EXISTS update_user_tags_after_insert ON public.user_has_tags;
DROP TRIGGER IF EXISTS update_user_tags_after_update ON public.user_has_tags;
DROP TRIGGER IF EXISTS update_user_tags_after_delete ON public.user_has_tags;

CREATE TRIGGER update_user_tags_after_insert
  AFTER INSERT ON public.user_has_tags
  FOR EACH ROW
  EXECUTE FUNCTION update_user_tags_column();

CREATE TRIGGER update_user_tags_after_update
  AFTER UPDATE ON public.user_has_tags
  FOR EACH ROW
  EXECUTE FUNCTION update_user_tags_column();

CREATE TRIGGER update_user_tags_after_delete
  AFTER DELETE ON public.user_has_tags
  FOR EACH ROW
  EXECUTE FUNCTION update_user_tags_column();

-- =====================================================
-- INITIAL TAGS DATA
-- Visual tags that users can display
-- =====================================================
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
  ('Photo Editor', '#FD79B8', 'editor-creative'),
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
  ('Legendary', '#FFEAA7', 'golden-pulse'),
  
  -- Wild And Free Legacy (roles convertidos a tags visibles)
  ('Wild Gvng Member', '#00BFFF', 'member-shine'),
  ('Wild Gvng Artist', '#FF1493', 'artist-sparkle'),
  ('Wild Gvng Media', '#FF4500', 'media-pulse'),
  ('Wild Gvng Developer', '#00FF00', 'developer-code'),
  ('Wild Gvng Visual Designer', '#FF69B4', 'designer-flow'),
  ('Wild Gvng Graphic Editor', '#FF8C00', 'editor-creative')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- INITIAL ROLES DATA
-- Invisible roles for permissions only (not displayed as tags)
-- =====================================================
INSERT INTO public.roles (name, permissions) VALUES
  ('admin', '{"can_manage_tags": true, "can_manage_users": true, "can_manage_roles": true}'),
  ('moderator', '{"can_manage_tags": true, "can_manage_users": false, "can_manage_roles": false}'),
  ('member', '{"can_manage_tags": false, "can_manage_users": false, "can_manage_roles": false}'),
  ('guest', '{"can_manage_tags": false, "can_manage_users": false, "can_manage_roles": false}')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- DEFAULT FAN TAG
-- Fallback tag for users without tags
-- =====================================================
INSERT INTO public.tags (name, color, animation) VALUES
  ('FAN', '#6366F1', 'member-shine')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- UPDATE EXISTING USERS
-- Migrate existing data to new system
-- =====================================================
-- Update all existing users with their current tags
UPDATE public.users 
SET user_tags = (
  SELECT COALESCE(array_agg(uht.tag_id ORDER BY uht.tag_id), '{}')
  FROM public.user_has_tags uht
  WHERE uht.user_id = users.id
)
WHERE EXISTS (
  SELECT 1 
  FROM public.user_has_tags uht2 
  WHERE uht2.user_id = users.id
);

-- =====================================================
-- SECURITY NOTES
-- =====================================================
-- 1. Frontend NEVER accesses these tables directly
-- 2. All tag operations go through API Gateway → Core Engine → Database
-- 3. Frontend only receives processed data (CSS classes, display names)
-- 4. Role-based permissions are invisible to users (backend only)
-- 5. Tag IDs are used for all operations, never exposed names
-- 6. Default FAN tag ensures every user has at least one tag