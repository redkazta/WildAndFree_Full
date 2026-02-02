import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey || supabaseUrl === 'TU_SUPABASE_URL_AQUI') {
  console.warn(
    'Supabase credentials are not set. Please update your .env file with valid credentials.'
  );
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
