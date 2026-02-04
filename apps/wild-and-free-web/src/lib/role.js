import { supabase } from './supabase'

export const getSession = async () => {
  const { data, error } = await supabase.auth.getSession()
  if (error) return { session: null, error }
  return { session: data?.session ?? null, error: null }
}

export const getRole = async () => {
  const { session, error } = await getSession()
  if (error || !session) return { role: 'guest', session, error }

  const metaRole = session?.user?.user_metadata?.role
  const { data: profileData } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', session.user.id)
    .single()

  const profileRole = profileData?.role || profileData?.rol
  return { role: profileRole || metaRole || 'fan', session, error: null }
}

export const requireRole = async (roles, options = {}) => {
  const allowed = Array.isArray(roles) ? roles : [roles]
  const redirectTo = options.redirectTo || '/login'
  const { role, session } = await getRole()
  if (!session) {
    window.location.replace(redirectTo)
    return { ok: false, role }
  }
  if (!allowed.includes(role)) {
    window.location.replace(options.forbiddenRedirectTo || '/')
    return { ok: false, role }
  }
  return { ok: true, role }
}
