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

    // Authenticate from header or cookie
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

    const formData = await request.formData();
    const file = formData.get("image") as File | null;

    if (!file) {
      return new Response(
        JSON.stringify({ error: "No se recibió ningún archivo" }),
        { status: 400 },
      );
    }

    const allowedTypes = ["image/jpeg", "image/png", "image/webp", "image/gif"];
    if (!allowedTypes.includes(file.type)) {
      return new Response(
        JSON.stringify({
          error: "Formato no soportado. Usa JPG, PNG, WebP o GIF",
        }),
        { status: 400 },
      );
    }

    // Max 5MB
    if (file.size > 5 * 1024 * 1024) {
      return new Response(
        JSON.stringify({ error: "La imagen no puede superar los 5MB" }),
        { status: 400 },
      );
    }

    const fileExt = file.name.split(".").pop() || "jpg";
    const fileName = `posts/${user.id}/${Date.now()}.${fileExt}`;

    const arrayBuffer = await file.arrayBuffer();
    const buffer = new Uint8Array(arrayBuffer);

    const { data: uploadData, error: uploadError } = await supabaseAdmin.storage
      .from("images")
      .upload(fileName, buffer, {
        contentType: file.type,
        upsert: true,
      });

    if (uploadError) {
      // Create bucket if missing and retry
      if (
        uploadError.message?.includes("bucket") ||
        (uploadError as any)?.statusCode === 404
      ) {
        await supabaseAdmin.storage.createBucket("images", {
          public: true,
          fileSizeLimit: 5242880,
        });
        const retry = await supabaseAdmin.storage
          .from("images")
          .upload(fileName, buffer, {
            contentType: file.type,
            upsert: true,
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

    const { data: publicUrlData } = supabaseAdmin.storage
      .from("images")
      .getPublicUrl(fileName);

    return new Response(
      JSON.stringify({ success: true, url: publicUrlData.publicUrl }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message || "Error interno del servidor" }),
      { status: 500 },
    );
  }
};
