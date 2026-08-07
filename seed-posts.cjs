const globalRoot = require("child_process").execSync("npm root -g").toString().trim();
const { Client } = require(globalRoot + "/pg");

const DB_URL =
  "postgresql://postgres:Pedrito1122**@db.cfsqhbisrkqhbupyjrwz.supabase.co:5432/postgres";

// KAZTA y Ralf UUIDs
const KAZTA = "ec7ba40e-971a-4729-ad17-e83a0fdd42b5";
const RALF = "cd2611f7-1ad1-4fff-8032-77f8ee616fbb";
const ADMIN3 = "ab563ebf-1396-4b0f-a4b7-8d1dec846790";

const TYPE_LABELS = {
  announcement: "📢 ANUNCIO",
  event: "🎤 EVENTO",
  promotion: "🏷️ PROMO",
  general: "📝 NOTICIA",
};

const crewPosts = [
  // ANNOUNCEMENTS (sidebar)
  { author: KAZTA, title: "Wild Gvng llega a Spotify", type: "announcement", image: "https://images.unsplash.com/photo-1611339555312-e607c8352fd7?w=1200&q=80", content: `Después de meses de negociaciones, toda la discografía de Wild Gvng ya está disponible en Spotify. 12 tracks, 3 EPs y un álbum completo.\n\n🔗 Enlace directo: https://open.spotify.com/artist/wildgvng\n\nEsto es apenas el comienzo.` },
  { author: KAZTA, title: "Convocatoria: Nuevos Talentos 2026", type: "announcement", image: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=1200&q=80", content: `¿Eres rapero o productor de Torreón? Abrimos convocatoria.\n\n• 5 sesiones gratis en Wild Gvng Studios\n• Producción de un track profesional\n• Distribución completa\n\nManda tu demo a crew@wildgvng.com` },
  { author: KAZTA, title: "Wild Battle Vol. 13 — Fecha confirmada", type: "announcement", image: "https://images.unsplash.com/photo-1460723237483-7a6dc9d0b212?w=1200&q=80", content: `La próxima edición del Wild Battle será el 30 de agosto.\n\n🏆 Premio: $8,000 MXN\n🎤 16 competidores\n📍 Foro Wild Gvng\n⏰ 8:00 PM\n\nInscripciones abiertas hasta el 25 de agosto.` },
  { author: KAZTA, title: "Nueva sudadera edición limitada", type: "announcement", image: "https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=1200&q=80", content: `Sudadera Wild Gvng edición "Desierto".\n\n• 50 unidades\n• Diseño exclusivo\n• Parche bordado\n\n🏷️ $650 MXN\nDisponible en la tienda.` },
  // EVENT
  { author: RALF, title: "Noche de Freestyle en el Centro", type: "event", image: "https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=1200&q=80", content: `Este sábado 10 de agosto, sesión de freestyle sorpresa en el centro de Torreón.\n\n📍 Plaza Mayor a las 8 PM.\nTrae tu crew, tus rimas y tu hambre.\n\nVamos a hacer historia.` },
  // GENERAL
  { author: KAZTA, title: "Detrás del micrófono: Fuego del Desierto", type: "general", image: "https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?w=1200&q=80", content: `Behind the scenes de la grabación de nuestro hit.\n\nProducido por KAZTA, grabado en Wild Gvng Studios.\nEl video completo está en nuestro canal de YouTube.` },
  { author: KAZTA, title: "Colaboración sorpresa en camino", type: "general", image: null, content: `No podemos decir con quién todavía, pero la colaboración que viene va a romperla.\n\nGrabando toda la semana. Estén atentos 🔥` },
  { author: RALF, title: "Mixtape de verano en selección", type: "general", image: "https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=1200&q=80", content: `Seleccionando tracks para el mixtape de verano.\n\nColaboraciones, freestyles y beats que guardamos por años.\n\nAparten el 15 de agosto. 🔥` },
  // PROMOTION
  { author: KAZTA, title: "Merch preview: Diseño Desierto", type: "promotion", image: "https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=1200&q=80", content: `Nuevo merch preview 🔥\n\nDiseño "Desierto" — edición limitada.\nPronto disponibles en la tienda.` },
];

async function main() {
  const client = new Client({ connectionString: DB_URL, ssl: { rejectUnauthorized: false } });
  await client.connect();
  console.log("✅ Conectado\n");

  // Insert crew_posts (sin ID hardcodeado, dejamos que genere UUID)
  console.log("=== CREW POSTS ===");
  const postIds = {};
  for (let i = 0; i < crewPosts.length; i++) {
    const p = crewPosts[i];
    const now = new Date(Date.now() - i * 3600000 * 4).toISOString();
    const res = await client.query(
      `INSERT INTO crew_posts (author_id, title, content, image_url, post_type, status, published_at)
       VALUES ($1,$2,$3,$4,$5,'published',$6) RETURNING id`,
      [p.author, p.title, p.content, p.image, p.type, now]
    );
    postIds[p.title] = res.rows[0].id;
    console.log(`  + ${TYPE_LABELS[p.type]} ${p.title}`);
  }

  // Insert wall_posts (feed social)
  console.log("\n=== WALL POSTS ===");
  const wallPosts = [
    { author: KAZTA, content: "🔥 Acabo de terminar la mezcla del nuevo track. ¿Quién quiere un preview?", image: null },
    { author: KAZTA, content: "Noche de estudio en el laboratorio. Así se construye el sonido del desierto 🏜️", image: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=80" },
    { author: KAZTA, content: "Gracias a todos los que vinieron al Wild Battle Vol. 12! La próxima viene con sorpresa 💪", image: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&q=80" },
    { author: RALF, content: "Haciendo selección de tracks para el mixtape de verano. Esto se viene con todo 🔥", image: "https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=800&q=80" },
  ];
  const wallData = [];
  for (let i = 0; i < wallPosts.length; i++) {
    const p = wallPosts[i];
    const now = new Date(Date.now() - i * 7200000).toISOString();
    const res = await client.query(
      `INSERT INTO wall_posts (user_id, content, image_url, created_at) VALUES ($1,$2,$3,$4) RETURNING id`,
      [p.author, p.content, p.image, now]
    );
    wallData.push(res.rows[0].id);
    console.log(`  + ${p.content.slice(0, 40)}...`);
  }

  // Likes y comentarios SOLO en wall_posts (FK apunta a wall_posts)
  console.log("\n=== REACCIONES (wall_posts) ===");
  for (const pid of wallData) {
    await client.query(`INSERT INTO wall_likes (post_id, user_id) VALUES ($1,$2) ON CONFLICT DO NOTHING`, [pid, RALF]);
    if (Math.random() > 0.5) {
      await client.query(`INSERT INTO wall_likes (post_id, user_id) VALUES ($1,$2) ON CONFLICT DO NOTHING`, [pid, ADMIN3]);
    }
  }
  console.log("  + Likes agregados a wall_posts");

  // Comentarios en wall_posts
  const wallComments = [
    [wallData[0], RALF, "Yo quiero escucharlo! Avienta un snippet 🔥"],
    [wallData[0], ADMIN3, "Siempre rompiendo cabezas 💪"],
    [wallData[2], RALF, "Estuvo al cien! La próxima vamos con más 🏆"],
  ];
  for (const [pid, uid, content] of wallComments) {
    if (pid) await client.query(`INSERT INTO wall_comments (post_id, user_id, content) VALUES ($1,$2,$3)`, [pid, uid, content]);
  }
  console.log("  + Comentarios agregados a wall_posts");



  console.log("\n✅ Seed completo!");
  await client.end();
}

main().catch((e) => { console.error(e); process.exit(1); });
