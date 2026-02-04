import { supabase } from './supabase'

export const ensureProfile = async (session) => {
  const user = session?.user
  const userId = user?.id
  if (!userId) return { ok: false, error: new Error('No session user') }

  const meta = user.user_metadata || {}
  const payload = {
    id: userId,
    nombre: meta.nombre || meta.full_name || null,
    username: meta.username || null,
    phone: meta.phone || null,
    ubicacion: meta.ubicacion || null,
    birthdate: meta.birthdate || null,
    role: meta.role || null,
    updated_at: new Date().toISOString(),
  }

  const { error } = await supabase.from('profiles').upsert(payload, { onConflict: 'id' })
  if (error) return { ok: false, error }
  return { ok: true, error: null }
}
