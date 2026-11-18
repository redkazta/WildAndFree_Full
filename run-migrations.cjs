const globalRoot = require("child_process").execSync("npm root -g").toString().trim();
const { Client } = require(globalRoot + "/pg");
const fs = require("fs");
const path = require("path");

// Credenciales de la DB de Supabase (service role)
// Configura SUPABASE_DB_URL en tu entorno antes de ejecutar.
const DB_URL = process.env.SUPABASE_DB_URL || process.env.DATABASE_URL;
if (!DB_URL) {
  console.error('Falta SUPABASE_DB_URL (o DATABASE_URL) con la cadena de conexión de Postgres.');
  process.exit(1);
}

// NOTA: en un proyecto Supabase nuevo, ejecuta primero
// supabase/bootstrap_new_project.sql en el SQL Editor.

// Migraciones a ejecutar en orden
const migrations = [
  "supabase/migrations/20260726_seed_roles_permissions.sql",
  "supabase/migrations/20260726_seed_wall_posts.sql",
  "supabase/migrations/20260726_seed_crew_posts_and_feed.sql",
  "supabase/migrations/20260726_functions_feed.sql",
  "supabase/migrations/20260726_functions_tokens.sql",
  "supabase/migrations/20260727_seed_crew_posts_final.sql",
  "supabase/migrations/20260728_seed_exclusive_content.sql",
  "supabase/migrations/20261118_league_bracket_realtime.sql",
];

async function applyMigrations(client) {
  const applied = [];
  const failed = [];

  for (const rel of migrations) {
    const abs = path.resolve(__dirname, rel);
    if (!fs.existsSync(abs)) {
      console.log(`[SKIP] ${rel} (no existe)`);
      continue;
    }
    const sql = fs.readFileSync(abs, "utf8");
    try {
      console.log(`[EJECUTANDO] ${rel}...`);
      await client.query(sql);
      applied.push(rel);
      console.log(`[OK] ${rel}`);
    } catch (err) {
      // Ignorar errores de "already exists" que son inofensivos
      const msg = err.message || "";
      if (msg.includes("already exists")) {
        console.log(`[YA EXISTE] ${rel} (ok)`);
        applied.push(rel);
      } else {
        failed.push({ rel, msg });
        console.error(`[ERROR] ${rel}:\n${msg}`);
      }
    }
  }

  return { applied, failed };
}

async function main() {
  const client = new Client({
    connectionString: DB_URL,
    ssl: { rejectUnauthorized: false },
  });

  try {
    await client.connect();
    console.log("✅ Conectado a Supabase DB\n");
    const { applied, failed } = await applyMigrations(client);
    console.log(`\n=== RESULTADO ===`);
    console.log(`Aplicadas: ${applied.join("\n - ")}`);
    if (failed.length) {
      console.log(`\nFallidas: `);
      failed.forEach((f) => console.log(`  - ${f.rel}: ${f.msg}`));
    } else {
      console.log("\n✅ Todas las migraciones aplicadas correctamente.");
    }
  } catch (err) {
    console.error("Error de conexión:", err);
  } finally {
    await client.end();
  }
}

main();
