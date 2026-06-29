import type { APIRoute } from "astro";
import { createClient } from "@supabase/supabase-js";

export const POST: APIRoute = async ({ request }) => {
  try {
    const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
    const supabaseServiceKey = import.meta.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(
        JSON.stringify({ error: "Supabase no está configurado correctamente" }),
        { status: 500 },
      );
    }

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    // Authenticate the user from the request cookie
    const authHeader = request.headers.get("authorization") || "";
    let accessToken = authHeader.replace("Bearer ", "");

    if (!accessToken) {
      const allCookies = request.headers.get("cookie") || "";
      const cookieMatch = allCookies.match(/sb-[^-]+-auth-token=([^;]+)/);
      if (cookieMatch) {
        try {
          const parsed = JSON.parse(decodeURIComponent(cookieMatch[1]));
          accessToken = parsed.access_token;
        } catch {}
      }
    }

    if (!accessToken) {
      return new Response(JSON.stringify({ error: "No autenticado" }), {
        status: 401,
      });
    }

    const {
      data: { user },
      error: userError,
    } = await supabaseAdmin.auth.getUser(accessToken);

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: "Token inválido o expirado" }),
        { status: 401 },
      );
    }

    // Check if user is admin
    const { data: isAdmin } = await supabaseAdmin.rpc('is_admin');
    if (!isAdmin) {
      return new Response(
        JSON.stringify({ error: "Se requieren permisos de administrador" }),
        { status: 403 },
      );
    }

    // Parse the multipart form
    const formData = await request.formData();
    const file = formData.get("audio") as File | null;
    const cover = formData.get("cover") as File | null;
    const title = formData.get("title") as string | null;
    const description = formData.get("description") as string | null;
    const host = formData.get("host") as string | null;
    const category = formData.get("category") as string | null;
    const duration = formData.get("duration") as string | null;
    const isLive = formData.get("is_live") === "true";
    const zenoUrl = formData.get("live_url") as string | null;

    if (!file || !title) {
      return new Response(
        JSON.stringify({ error: "Faltan campos requeridos: audio y título" }),
        { status: 400 },
      );
    }

    // Validate audio file type
    const allowedAudioTypes = ["audio/mpeg", "audio/mp3", "audio/wav", "audio/ogg", "audio/aac", "audio/m4a", "audio/mp4"];
    if (!allowedAudioTypes.includes(file.type) && !file.name.match(/\.(mp3|wav|ogg|aac|m4a|mp4)$/i)) {
      return new Response(
        JSON.stringify({ error: "Formato de audio no soportado. Usa MP3, WAV, OGG, AAC o M4A" }),
        { status: 400 },
      );
    }

    // Max 100MB for audio
    if (file.size > 100 * 1024 * 1024) {
      return new Response(
        JSON.stringify({ error: "El archivo de audio no puede superar los 100MB" }),
        { status: 400 },
      );
    }

    // Upload audio to Supabase Storage bucket "radio-audio"
    const fileExt = file.name.split(".").pop() || "mp3";
    const fileName = `episodes/${Date.now()}-${Math.random().toString(36).substring(2, 8)}.${fileExt}`;

    const arrayBuffer = await file.arrayBuffer();
    const buffer = new Uint8Array(arrayBuffer);

    const { data: uploadData, error: uploadError } = await supabaseAdmin.storage
      .from("radio-audio")
      .upload(fileName, buffer, {
        contentType: file.type || "audio/mpeg",
        upsert: false,
      });

    if (uploadError) {
      // If bucket doesn't exist, create it and retry
      if (
        uploadError.message?.includes("bucket") ||
        (uploadError as any)?.statusCode === 404
      ) {
        await supabaseAdmin.storage.createBucket("radio-audio", {
          public: true,
          fileSizeLimit: 104857600,
        });
        const retry = await supabaseAdmin.storage
          .from("radio-audio")
          .upload(fileName, buffer, {
            contentType: file.type || "audio/mpeg",
            upsert: false,
          });
        if (retry.error) {
          return new Response(JSON.stringify({ error: retry.error.message }), {
            status: 500,
          });
        }
      } else {
        return new Response(JSON.stringify({ error: uploadError.message }), {
          status: 500,
        });
      }
    }

    // Get public URL for audio
    const { data: audioPublicUrl } = supabaseAdmin.storage
      .from("radio-audio")
      .getPublicUrl(fileName);
    const audioUrl = audioPublicUrl.publicUrl;

    // Upload cover image if provided
    let coverUrl = "";
    if (cover) {
      const allowedImageTypes = ["image/jpeg", "image/png", "image/webp", "image/gif"];
      if (allowedImageTypes.includes(cover.type) && cover.size <= 5 * 1024 * 1024) {
        const coverExt = cover.name.split(".").pop() || "jpg";
        const coverFileName = `covers/${Date.now()}-${Math.random().toString(36).substring(2, 8)}.${coverExt}`;
        const coverBuffer = new Uint8Array(await cover.arrayBuffer());

        const { error: coverError } = await supabaseAdmin.storage
          .from("radio-audio")
          .upload(coverFileName, coverBuffer, {
            contentType: cover.type,
            upsert: false,
          });

        if (!coverError) {
          const { data: coverPublicUrl } = supabaseAdmin.storage
            .from("radio-audio")
            .getPublicUrl(coverFileName);
          coverUrl = coverPublicUrl.publicUrl;
        }
      }
    }

    // Create record in radio_episodes
    const { data: episode, error: insertError } = await supabaseAdmin
      .from("radio_episodes")
      .insert({
        title,
        description: description || "",
        host: host || "KAZTA",
        audio_url: audioUrl,
        cover_url: coverUrl || null,
        duration: duration || null,
        category: category || "mix",
        is_published: !isLive,
        is_live: isLive,
        live_url: zenoUrl || null,
        created_by: user.id,
        published_at: !isLive ? new Date().toISOString() : null,
      })
      .select()
      .single();

    if (insertError) {
      return new Response(JSON.stringify({ error: insertError.message }), {
        status: 500,
      });
    }

    return new Response(
      JSON.stringify({ success: true, episode }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message || "Error interno del servidor" }),
      { status: 500 },
    );
  }
};

// PATCH handler to update episode fields (publish/unpublish, etc.)
export const PATCH: APIRoute = async ({ request }) => {
  try {
    const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
    const supabaseServiceKey = import.meta.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(
        JSON.stringify({ error: "Supabase no está configurado correctamente" }),
        { status: 500 },
      );
    }

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    // Authenticate
    const authHeader = request.headers.get("authorization") || "";
    let accessToken = authHeader.replace("Bearer ", "");

    if (!accessToken) {
      const allCookies = request.headers.get("cookie") || "";
      const cookieMatch = allCookies.match(/sb-[^-]+-auth-token=([^;]+)/);
      if (cookieMatch) {
        try {
          const parsed = JSON.parse(decodeURIComponent(cookieMatch[1]));
          accessToken = parsed.access_token;
        } catch {}
      }
    }

    if (!accessToken) {
      return new Response(JSON.stringify({ error: "No autenticado" }), { status: 401 });
    }

    const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(accessToken);
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Token inválido" }), { status: 401 });
    }

    const { data: isAdmin } = await supabaseAdmin.rpc('is_admin');
    if (!isAdmin) {
      return new Response(JSON.stringify({ error: "Se requieren permisos de administrador" }), { status: 403 });
    }

    const body = await request.json();
    const { id, ...fields } = body;

    if (!id) {
      return new Response(JSON.stringify({ error: "Se requiere ID del episodio" }), { status: 400 });
    }

    const { data, error } = await supabaseAdmin
      .from("radio_episodes")
      .update({ ...fields, updated_at: new Date().toISOString() })
      .eq("id", id)
      .select()
      .single();

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), { status: 500 });
    }

    return new Response(
      JSON.stringify({ success: true, episode: data }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message || "Error interno del servidor" }),
      { status: 500 },
    );
  }
};

// DELETE handler to remove an episode
export const DELETE: APIRoute = async ({ request }) => {
  try {
    const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
    const supabaseServiceKey = import.meta.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(
        JSON.stringify({ error: "Supabase no está configurado correctamente" }),
        { status: 500 },
      );
    }

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    // Authenticate
    const authHeader = request.headers.get("authorization") || "";
    let accessToken = authHeader.replace("Bearer ", "");

    if (!accessToken) {
      const allCookies = request.headers.get("cookie") || "";
      const cookieMatch = allCookies.match(/sb-[^-]+-auth-token=([^;]+)/);
      if (cookieMatch) {
        try {
          const parsed = JSON.parse(decodeURIComponent(cookieMatch[1]));
          accessToken = parsed.access_token;
        } catch {}
      }
    }

    if (!accessToken) {
      return new Response(JSON.stringify({ error: "No autenticado" }), { status: 401 });
    }

    const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(accessToken);
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Token inválido" }), { status: 401 });
    }

    const { data: isAdmin } = await supabaseAdmin.rpc('is_admin');
    if (!isAdmin) {
      return new Response(JSON.stringify({ error: "Se requieren permisos de administrador" }), { status: 403 });
    }

    const url = new URL(request.url);
    const id = url.searchParams.get("id");

    if (!id) {
      return new Response(JSON.stringify({ error: "Se requiere ID del episodio" }), { status: 400 });
    }

    const { error } = await supabaseAdmin
      .from("radio_episodes")
      .delete()
      .eq("id", id);

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), { status: 500 });
    }

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message || "Error interno del servidor" }),
      { status: 500 },
    );
  }
};
