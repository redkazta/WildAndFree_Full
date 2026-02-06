import { supabase } from './supabase'

export const ensureProfile = async (session) => {
  const user = session?.user
  const userId = user?.id
  if (!userId) return { ok: false, error: new Error('No session user') }

  const meta = user.user_metadata || {}
  const payload = { id: userId, updated_at: new Date().toISOString() }
  const nombre = meta.nombre || meta.full_name
  if (nombre) payload.nombre = nombre
  if (meta.username) payload.username = meta.username
  if (meta.phone) payload.phone = meta.phone
  if (meta.ubicacion) payload.ubicacion = meta.ubicacion
  if (meta.birthdate) {
    // Validar formato YYYY-MM-DD
    if (/^\d{4}-\d{2}-\d{2}$/.test(meta.birthdate)) {
      payload.birthdate = meta.birthdate;
    } else {
      console.warn('Invalid birthdate format in metadata:', meta.birthdate);
    }
  }
  if (meta.role) payload.role = meta.role

  const { error } = await supabase.from('profiles').upsert(payload, { onConflict: 'id' })
  if (error) return { ok: false, error }
  return { ok: true, error: null }
}
