const { Client } = require("pg");

const DB_URL =
  "postgresql://postgres:Pedrito1122**@db.cfsqhbisrkqhbupyjrwz.supabase.co:5432/postgres";
const SUPABASE_URL = "https://cfsqhbisrkqhbupyjrwz.supabase.co";
const SERVICE_ROLE_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNmc3FoYmlzcmtxaGJ1cHlqcnd6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjYwMTA0OSwiZXhwIjoyMDk4MTc3MDQ5fQ.neLLjRHAkZ8yBS0LulP7M5qa2Vh2IA2KycD6t5x7-dM";

const client = new Client({
  connectionString: DB_URL,
  ssl: { rejectUnauthorized: false },
});

async function createUser(email, password, metadata) {
  const res = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
      apikey: SERVICE_ROLE_KEY,
    },
    body: JSON.stringify({
      email,
      password,
      email_confirm: true,
      user_metadata: metadata,
    }),
  });
  const data = await res.json();
  if (data.id) return data.id;
  if (data.error_code === "email_exists") {
    const { rows } = await client.query(
      `SELECT id FROM auth.users WHERE email = $1`,
      [email],
    );
    if (rows[0]) return rows[0].id;
  }
  throw new Error(JSON.stringify(data));
}

async function main() {
  try {
    await client.connect();
    console.log("✅ Conectado\n");

    // TAGS
    const tags = [
      { name: "FOUNDER", color: "#FFD700", cat: "cosmetic", anim: "glow" },
      { name: "WILD", color: "#C98300", cat: "cosmetic", anim: "pulse" },
      {
        name: "FREESTYLER",
        color: "#FF4444",
        cat: "achievement",
        anim: "shake",
      },
      {
        name: "VERIFIED ARTIST",
        color: "#00FF88",
        cat: "achievement",
        anim: "none",
      },
      { name: "OG MEMBER", color: "#8A0303", cat: "cosmetic", anim: "glow" },
      {
        name: "BATTLE CHAMPION",
        color: "#FFD700",
        cat: "achievement",
        anim: "pulse",
      },
      {
        name: "FIRST UPLOAD",
        color: "#00BFFF",
        cat: "achievement",
        anim: "none",
      },
      {
        name: "WILD PASS",
        color: "#C98300",
        cat: "purchasable",
        anim: "shimmer",
      },
      { name: "HONOR FAN", color: "#FF69B4", cat: "event", anim: "none" },
      {
        name: "ASCENSION VIP",
        color: "#9B59B6",
        cat: "purchasable",
        anim: "glow",
      },
    ];
    for (const t of tags) {
      await client.query(
        `INSERT INTO tags (name, color, animation, category_id)
        VALUES ($1, $2, $3, (SELECT id FROM tag_categories WHERE name = $4)) ON CONFLICT (name) DO NOTHING`,
        [t.name, t.color, t.anim, t.cat],
      );
    }
    console.log(`✅ ${tags.length} tags creados`);

    // ADMIN
    const adminId = await createUser("admin@wildgvng.com.mx", "Admin1122**", {
      nombre: "Kazta Admin",
      username: "kazta_admin",
      phone: "+528712345678",
      ubicacion: "Torreón Coahuila",
      birthdate: "1995-01-15",
    });
    await client.query(`DELETE FROM user_roles WHERE user_id = $1`, [adminId]);
    await client.query(
      `INSERT INTO user_roles (user_id, role_id) SELECT $1, id FROM roles WHERE internal_name = 'admin' ON CONFLICT DO NOTHING`,
      [adminId],
    );
    for (const t of [
      "FOUNDER",
      "WILD",
      "OG MEMBER",
      "VERIFIED ARTIST",
      "WILD PASS",
    ]) {
      await client.query(
        `INSERT INTO user_has_tags (user_id, tag_id, assigned_by) SELECT $1, id, $1 FROM tags WHERE name = $2 ON CONFLICT DO NOTHING`,
        [adminId, t],
      );
    }
    console.log("✅ Admin: admin@wildgvng.com.mx / Admin1122**");

    // ARTISTAS
    const artists = [
      {
        email: "young_kazta@wildgvng.com.mx",
        name: "Young Kazta",
        user: "young_kazta",
        bio: "Freestyler y productor musical. Fundador de Wild Gvng.",
        tags: ["WILD", "FREESTYLER", "VERIFIED ARTIST", "OG MEMBER"],
      },
      {
        email: "mc_delta@wildgvng.com.mx",
        name: "MC Delta",
        user: "mc_delta",
        bio: "Voz del bajo mundo. Flow imparable.",
        tags: ["WILD", "FREESTYLER", "BATTLE CHAMPION"],
      },
      {
        email: "lil_fuego@wildgvng.com.mx",
        name: "Lil Fuego",
        user: "lil_fuego",
        bio: "Joven promesa del freestyle torreonense.",
        tags: ["WILD", "FREESTYLER", "FIRST UPLOAD"],
      },
    ];
    for (const a of artists) {
      try {
        const uid = await createUser(a.email, "Artist1122**", {
          nombre: a.name,
          username: a.user,
          ubicacion: "Torreón Coahuila",
        });
        await client.query(`DELETE FROM user_roles WHERE user_id = $1`, [uid]);
        await client.query(
          `INSERT INTO user_roles (user_id, role_id) SELECT $1, id FROM roles WHERE internal_name = 'artist' ON CONFLICT DO NOTHING`,
          [uid],
        );
        await client.query(`UPDATE profiles SET bio = $2 WHERE id = $1`, [
          uid,
          a.bio,
        ]);
        for (const t of a.tags) {
          await client.query(
            `INSERT INTO user_has_tags (user_id, tag_id, assigned_by) SELECT $1, id, $1 FROM tags WHERE name = $2 ON CONFLICT DO NOTHING`,
            [uid, t],
          );
        }
        console.log(`✅ Artista: ${a.email} / Artist1122**`);
      } catch (e) {
        console.log(`ℹ️  ${a.email} ya existe`);
      }
    }

    // FANS
    const fans = [
      {
        email: "fan_torreon@wildgvng.com.mx",
        name: "Carlos Méndez",
        user: "carlos_mx",
        tags: ["WILD", "HONOR FAN"],
      },
      {
        email: "fan_mty@wildgvng.com.mx",
        name: "Ana Reyes",
        user: "ana_reyes_mty",
        tags: ["WILD"],
      },
      {
        email: "fan_cdmx@wildgvng.com.mx",
        name: "Luis García",
        user: "luis_garcia_cdmx",
        tags: ["WILD", "ASCENSION VIP"],
      },
    ];
    for (const f of fans) {
      try {
        const uid = await createUser(f.email, "Fan1122**", {
          nombre: f.name,
          username: f.user,
          ubicacion: "México",
        });
        for (const t of f.tags) {
          await client.query(
            `INSERT INTO user_has_tags (user_id, tag_id, assigned_by) SELECT $1, id, $1 FROM tags WHERE name = $2 ON CONFLICT DO NOTHING`,
            [uid, t],
          );
        }
        console.log(`✅ Fan: ${f.email} / Fan1122**`);
      } catch (e) {
        console.log(`ℹ️  ${f.email} ya existe`);
      }
    }

    // RESUMEN
    const { rows: users } = await client.query(`
      SELECT p.nombre, p.username, r.internal_name as role,
        (SELECT array_agg(t.name) FROM user_has_tags uht JOIN tags t ON t.id = uht.tag_id WHERE uht.user_id = p.id) as tags
      FROM profiles p
      LEFT JOIN user_roles ur ON ur.user_id = p.id
      LEFT JOIN roles r ON r.id = ur.role_id
      ORDER BY r.internal_name, p.username
    `);
    console.log("\n📋 Usuarios:");
    for (const u of users) {
      console.log(
        `   @${u.username} (${u.nombre}) [${u.role}] → ${u.tags?.filter(Boolean).join(", ") || "sin tags"}`,
      );
    }
  } catch (err) {
    console.error("❌ Error:", err.message);
  } finally {
    await client.end();
  }
}

main();
