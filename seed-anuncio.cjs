const globalRoot = require("child_process").execSync("npm root -g").toString().trim();
const { Client } = require(globalRoot + "/pg");

const DB_URL =
  "postgresql://postgres:Pedrito1122**@db.cfsqhbisrkqhbupyjrwz.supabase.co:5432/postgres";

// Usuarios existentes (seed del repo)
const KAZTA = "ec7ba40e-971a-4729-ad17-e83a0fdd42b5";
const RALF = "cd2611f7-1ad1-4fff-8032-77f8ee616fbb";
const ADMIN3 = "ab563ebf-1396-4b0f-a4b7-8d1dec846790";

async function main() {
  const client = new Client({ connectionString: DB_URL, ssl: { rejectUnauthorized: false } });
  await client.connect();
  console.log("✅ Conectado\n");

  // 1) crew_post anuncio
  const { rows } = await client.query(
    `INSERT INTO crew_posts (author_id, title, content, image_url, post_type, status, published_at)
     VALUES ($1,$2,$3,$4,'announcement','published',$5)
     RETURNING id`,
    [
      KAZTA,
      "MEGA ANUNCIO: Gira Nacional Wild Gvng 2027",
      "Estamos celebrando 10 años de Wild Gvng y arrancamos nuestra primera gira nacional.\n\n📅 Fechas confirmadas: Monterrey, CDMX, Guadalajara y Torreón (cierre).\n🎟️ Preventa de boletos este viernes en la tienda.\n🔁 Comparte esta publicación para entrar al sorteo de un pase doble.\n\nNos vemos en la carretera. 🏜️🔥",
      "https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=1200&q=80",
      new Date(Date.now()).toISOString(),
    ]
  );
  const postId = rows[0].id;
  console.log("📢 Anuncio creado:", postId);

  // 2) Reacciones pool (varios tipos en wall_likes)
  await client.query(
    `INSERT INTO wall_likes (post_id, user_id, reaction_type) VALUES
      ($1,$2,'like'),
      ($1,$3,'like'),
      ($1,$4,'haha')`,
    [postId, RALF, ADMIN3, KAZTA]
  );
  console.log("  👍 Reacciones pool: 2 like + 1 haha");

  // 3) Comentarios
  await client.query(
    `INSERT INTO wall_comments (post_id, user_id, content) VALUES
      ($1,$2,'No me lo puedo perder, Monterrey va con todo 🔥'),
      ($1,$3,'¿El cierre es oficial en Torreón o es sorpresa? 👀')`,
    [postId, RALF, ADMIN3]
  );
  console.log("  💬 2 comentarios");

  // 4) Repost
  await client.query(
    `INSERT INTO wall_reposts (post_id, user_id) VALUES ($1,$2)`,
    [postId, RALF]
  );
  console.log("  🔁 1 repost");

  console.log("\n✅ Anuncio insertado con reacciones/comentarios/reposts.");
  await client.end();
}

main().catch((e) => { console.error(e); process.exit(1); });
