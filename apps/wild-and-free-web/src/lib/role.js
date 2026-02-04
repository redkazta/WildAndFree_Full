import { supabase } from './supabase'

export const getSession = async () => {
  const { data, error } = await supabase.auth.getSession()
  if (error) return { session: null, error }
  return { session: data?.session ?? null, error: null }
}

const normalizeRole = (role) => {
  if (!role) return null
  return String(role).trim().toLowerCase()
}

const pickHighestRole = (roles) => {
  const normalized = (roles || []).map(normalizeRole).filter(Boolean)
  if (normalized.includes('admin')) return 'admin'
  if (normalized.includes('artist')) return 'artist'
  if (normalized.includes('fan')) return 'fan'
  return normalized[0] || null
}

const getRoleFromUserRoles = async (userId) => {
  const attempts = [
    () => supabase.from('user_roles').select('roles(name)').eq('user_id', userId),
    () => supabase.from('user_roles').select('role:roles(name)').eq('user_id', userId),
    () => supabase.from('user_roles').select('roles:role_id(name)').eq('user_id', userId),
    () => supabase.from('user_roles').select('roles(*)').eq('user_id', userId),
  ]

  for (const run of attempts) {
    try {
      const { data, error } = await run()
      if (error || !Array.isArray(data) || data.length === 0) continue

      const found = []
      for (const row of data) {
        const direct = row?.role || row?.rol || row?.name
        if (direct) found.push(direct)

        const nestedCandidates = [row?.roles, row?.role]
        for (const nested of nestedCandidates) {
          if (Array.isArray(nested)) {
            nested.forEach((r) => found.push(r?.name || r?.role || r?.slug || r?.code))
          } else if (nested && typeof nested === 'object') {
            found.push(nested?.name || nested?.role || nested?.slug || nested?.code)
          }
        }
      }

      const picked = pickHighestRole(found)
      if (picked) return picked
    } catch {
      continue
    }
  }

  return null
}

export const getRole = async () => {
  const { session, error } = await getSession()
  if (error || !session) return { role: 'guest', session, error }

  const userId = session?.user?.id
  const metaRole = normalizeRole(session?.user?.user_metadata?.role)

  const joinRole = userId ? await getRoleFromUserRoles(userId) : null
  if (joinRole) return { role: joinRole, session, error: null }

  try {
    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single()
    if (!profileError) {
      const profileRole = normalizeRole(profileData?.role || profileData?.rol)
      if (profileRole) return { role: profileRole, session, error: null }
    }
  } catch {}

  return { role: metaRole || 'fan', session, error: null }
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
