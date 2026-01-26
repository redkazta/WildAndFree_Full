import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY

const missingConfig = !supabaseUrl || !supabaseAnonKey

const stubClient = {
	auth: {
		async getSession() {
			return { data: { session: null }, error: null }
		},
		onAuthStateChange() {
			return { data: { subscription: { unsubscribe() {} } }, error: null }
		},
		async signOut() {
			return { error: null }
		},
		async signInWithOAuth() {
			alert('Auth no está configurado: falta PUBLIC_SUPABASE_URL / PUBLIC_SUPABASE_ANON_KEY')
			return { data: null, error: new Error('Supabase no configurado') }
		},
		async signInWithPassword() {
			alert('Auth no está configurado: falta PUBLIC_SUPABASE_URL / PUBLIC_SUPABASE_ANON_KEY')
			return { data: null, error: new Error('Supabase no configurado') }
		},
		async signUp() {
			alert('Auth no está configurado: falta PUBLIC_SUPABASE_URL / PUBLIC_SUPABASE_ANON_KEY')
			return { data: null, error: new Error('Supabase no configurado') }
		},
		async exchangeCodeForSession() {
			return { data: null, error: null }
		}
	}
}

export const supabase = missingConfig ? (stubClient as any) : createClient(supabaseUrl, supabaseAnonKey)
