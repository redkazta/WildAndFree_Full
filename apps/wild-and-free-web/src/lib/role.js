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

const getRoleFromRpc = async () => {
  const candidates = ['get_my_role', 'getMyRole', 'current_role']
  for (const fn of candidates) {
    try {
      const { data, error } = await supabase.rpc(fn)
      if (error) continue
      if (typeof data === 'string') {
        const r = normalizeRole(data)
        if (r) return r
      }
      const objRole = data?.role || data?.name
      const r = normalizeRole(objRole)
      if (r) return r
    } catch {
      continue
    }
  }

  const listCandidates = ['get_my_roles', 'getMyRoles', 'current_roles']
  for (const fn of listCandidates) {
    try {
      const { data, error } = await supabase.rpc(fn)
      if (error) continue
      if (Array.isArray(data)) {
        const picked = pickHighestRole(
          data.map((v) => (typeof v === 'string' ? v : v?.name || v?.role || v?.slug || v?.code))
        )
        if (picked) return picked
      }
    } catch {
      continue
    }
  }

  return null
}

const getRoleFromUserRoles = async (userId) => {
  try {
    const { data: userRoleRows, error: userRolesError } = await supabase
      .from('user_roles')
      .select('role_id')
      .eq('user_id', userId)

    if (userRolesError || !Array.isArray(userRoleRows) || userRoleRows.length === 0) {
      return null
    }

    const roleIds = Array.from(
      new Set(
        userRoleRows
          .map((row) => row?.role_id)
          .filter((value) => Boolean(value))
      )
    )

    if (roleIds.length === 0) return null

    const { data: rolesRows, error: rolesError } = await supabase
      .from('roles')
      .select('name, internal_name')
      .in('id', roleIds)

    if (rolesError || !Array.isArray(rolesRows) || rolesRows.length === 0) {
      return null
    }

    const names = rolesRows.map((row) => row?.name || row?.internal_name).filter(Boolean)
    const picked = pickHighestRole(names)
    return picked
  } catch {
    return null
  }
}

export const getRole = async () => {
  const { session, error } = await getSession()
  if (error || !session) return { role: 'guest', session, error }

  const userId = session?.user?.id
  const metaRole = normalizeRole(session?.user?.user_metadata?.role)

  const rpcRole = await getRoleFromRpc()
  if (rpcRole) return { role: rpcRole, session, error: null }

  const joinRole = userId ? await getRoleFromUserRoles(userId) : null
  if (joinRole) return { role: joinRole, session, error: null }

  try {
    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single()
    if (!profileError) {
      const profileRole = normalizeRole(profileData?.role || profileData?.rol || profileData?.user_role)
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
