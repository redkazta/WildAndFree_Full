import { supabase } from "./supabase";

export const ensureProfile = async (session) => {
  const user = session?.user;
  const userId = user?.id;
  if (!userId) return { ok: false, error: new Error("No session user") };

  const meta = user.user_metadata || {};
  const payload = { id: userId, updated_at: new Date().toISOString() };
  const nombre = meta.nombre || meta.full_name;
  if (nombre) payload.nombre = nombre;
  if (meta.username) payload.username = meta.username;
  if (meta.phone) payload.phone = meta.phone;
  if (meta.ubicacion) payload.ubicacion = meta.ubicacion;
  if (meta.birthdate) {
    if (/^\d{4}-\d{2}-\d{2}$/.test(meta.birthdate)) {
      payload.birthdate = meta.birthdate;
    } else {
      console.warn("Invalid birthdate format in metadata:", meta.birthdate);
    }
  }

  // 1. Upsert profile
  const { error: profileError } = await supabase
    .from("profiles")
    .upsert(payload, { onConflict: "id" });
  if (profileError) return { ok: false, error: profileError };

  // 2. Asignar rol 'fan' por defecto si no tiene ninguno
  const { data: existingRoles } = await supabase
    .from("user_roles")
    .select("role_id")
    .eq("user_id", userId)
    .limit(1);

  if (!existingRoles || existingRoles.length === 0) {
    const { data: fanRole } = await supabase
      .from("roles")
      .select("id")
      .eq("internal_name", "fan")
      .single();

    if (fanRole) {
      await supabase.from("user_roles").upsert(
        {
          user_id: userId,
          role_id: fanRole.id,
        },
        { onConflict: "user_id,role_id" },
      );
    }
  }

  // 3. Crear balance de tokens si no existe
  const { data: existingTokens } = await supabase
    .from("user_tokens")
    .select("user_id")
    .eq("user_id", userId)
    .limit(1);

  if (!existingTokens || existingTokens.length === 0) {
    await supabase.from("user_tokens").upsert(
      {
        user_id: userId,
        balance: 0,
      },
      { onConflict: "user_id" },
    );
  }

  return { ok: true, error: null };
};
