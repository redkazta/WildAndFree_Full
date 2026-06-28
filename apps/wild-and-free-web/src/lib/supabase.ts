import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

const validateSupabaseUrl = (url: string | undefined) => {
  if (!url) return false;
  try {
    new URL(url);
    return true;
  } catch (e) {
    return false;
  }
};

export const isSupabaseConfigured = Boolean(
  supabaseUrl && supabaseAnonKey && validateSupabaseUrl(supabaseUrl),
);

if (typeof window !== "undefined") {
  console.log("[WG] supabase init:", {
    url: supabaseUrl ? "SET" : "MISSING",
    key: supabaseAnonKey ? "SET" : "MISSING",
    configured: isSupabaseConfigured,
  });
}

const notConfiguredError = new Error(
  "Supabase no está configurado: falta PUBLIC_SUPABASE_URL / PUBLIC_SUPABASE_ANON_KEY",
);

const makeStub = () => {
  const errorResult = { data: null, error: notConfiguredError };
  const emptySession = { data: { session: null }, error: null };
  const stubChannel = {
    on() {
      return stubChannel;
    },
    subscribe() {
      return stubChannel;
    },
    send() {
      return { data: null, error: notConfiguredError };
    },
  };

  return {
    auth: {
      async getSession() {
        return emptySession;
      },
      onAuthStateChange() {
        return { data: { subscription: { unsubscribe() {} } }, error: null };
      },
      async signOut() {
        return { error: null };
      },
      async signInWithOAuth() {
        return errorResult;
      },
      async signInWithPassword() {
        return errorResult;
      },
      async signUp() {
        return errorResult;
      },
      async exchangeCodeForSession() {
        return errorResult;
      },
      async resetPasswordForEmail() {
        return errorResult;
      },
      async updateUser() {
        return errorResult;
      },
    },
    from() {
      return {
        select() {
          return {
            eq() {
              return {
                single: async () => errorResult,
              };
            },
            single: async () => errorResult,
          };
        },
      };
    },
    channel() {
      return stubChannel;
    },
  };
};

export const supabase = isSupabaseConfigured
  ? createClient(supabaseUrl!, supabaseAnonKey!, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
      },
    })
  : (makeStub() as any);
