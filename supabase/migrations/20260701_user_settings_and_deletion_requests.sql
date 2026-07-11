-- ============================================================
-- MIGRACIÓN: user_settings + account_deletion_requests
-- Fecha: 2026-07-01
-- Descripción: Tablas para configuración de usuario y solicitudes de eliminación
-- ============================================================

-- ── TABLA: user_settings ──
-- Almacena todas las preferencias/configuraciones del usuario
CREATE TABLE IF NOT EXISTS user_settings (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  
  -- Apariencia
  theme TEXT NOT NULL DEFAULT 'dark' CHECK (theme IN ('dark', 'light')),
  font_size TEXT NOT NULL DEFAULT 'medium' CHECK (font_size IN ('small', 'medium', 'large')),
  animations BOOLEAN NOT NULL DEFAULT true,
  
  -- Idioma y ubicación
  locale TEXT NOT NULL DEFAULT 'es' CHECK (locale IN ('es', 'en')),
  ubicacion TEXT NOT NULL DEFAULT 'Torreón',
  
  -- Reproducción
  autoplay BOOLEAN NOT NULL DEFAULT true,
  crossfade BOOLEAN NOT NULL DEFAULT false,
  streaming_quality TEXT NOT NULL DEFAULT 'medium' CHECK (streaming_quality IN ('low', 'medium', 'high')),
  offline_mode BOOLEAN NOT NULL DEFAULT false,
  auto_radio_spotify_playlist TEXT,
  
  -- Notificaciones push
  push_events BOOLEAN NOT NULL DEFAULT true,
  push_posts BOOLEAN NOT NULL DEFAULT true,
  push_comments BOOLEAN NOT NULL DEFAULT true,
  push_followers BOOLEAN NOT NULL DEFAULT false,
  
  -- Notificaciones email
  email_weekly BOOLEAN NOT NULL DEFAULT false,
  email_promos BOOLEAN NOT NULL DEFAULT false,
  
  -- Privacidad
  profile_public BOOLEAN NOT NULL DEFAULT true,
  show_ranking BOOLEAN NOT NULL DEFAULT true,
  history_enabled BOOLEAN NOT NULL DEFAULT true,
  share_data BOOLEAN NOT NULL DEFAULT false,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_user_settings_theme ON user_settings(theme);
CREATE INDEX IF NOT EXISTS idx_user_settings_locale ON user_settings(locale);

-- RLS (Row Level Security)
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- Policy: Usuarios pueden ver y editar su propia configuración
CREATE POLICY "Users can view own settings" ON user_settings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own settings" ON user_settings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own settings" ON user_settings
  FOR UPDATE USING (auth.uid() = user_id);

-- Policy: Admins pueden ver toda la configuración (para el ERP)
CREATE POLICY "Admins can view all settings" ON user_settings
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid() AND r.name = 'admin'
    )
  );

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_user_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_user_settings_updated_at();

-- ── TABLA: account_deletion_requests ──
-- Almacena solicitudes de eliminación de cuenta para revisión del ERP
CREATE TABLE IF NOT EXISTS account_deletion_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  reason TEXT,
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  processed_at TIMESTAMPTZ,
  processed_by UUID REFERENCES profiles(id),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_deletion_requests_user ON account_deletion_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_deletion_requests_status ON account_deletion_requests(status);
CREATE INDEX IF NOT EXISTS idx_deletion_requests_requested ON account_deletion_requests(requested_at DESC);

-- RLS
ALTER TABLE account_deletion_requests ENABLE ROW LEVEL SECURITY;

-- Policy: Usuarios pueden crear solicitudes para su propia cuenta
CREATE POLICY "Users can create own deletion request" ON account_deletion_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy: Usuarios pueden ver sus propias solicitudes
CREATE POLICY "Users can view own deletion requests" ON account_deletion_requests
  FOR SELECT USING (auth.uid() = user_id);

-- Policy: Admins pueden ver y gestionar todas las solicitudes (ERP)
CREATE POLICY "Admins can view all deletion requests" ON account_deletion_requests
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid() AND r.name = 'admin'
    )
  );

CREATE POLICY "Admins can update deletion requests" ON account_deletion_requests
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid() AND r.name = 'admin'
    )
  );

-- ── FUNCIÓN: Crear settings por defecto al registrar usuario ──
-- Trigger que crea user_settings cuando se crea un perfil
CREATE OR REPLACE FUNCTION create_default_user_settings()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_settings (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_default_user_settings
  AFTER INSERT ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION create_default_user_settings();

-- ── COMENTARIOS ──
COMMENT ON TABLE user_settings IS 'Preferencias/configuración de cada usuario en la plataforma Wild Gvng';
COMMENT ON TABLE account_deletion_requests IS 'Solicitudes de eliminación de cuenta enviadas por usuarios, revisables desde el ERP';
COMMENT ON COLUMN user_settings.theme IS 'Tema de la interfaz: dark o light';
COMMENT ON COLUMN user_settings.streaming_quality IS 'Calidad de streaming: low (128kbps), medium (256kbps), high (320kbps)';
COMMENT ON COLUMN account_deletion_requests.status IS 'Estado: pending, approved, rejected';
