const globalRoot = require("child_process").execSync("npm root -g").toString().trim();
const { Client } = require(globalRoot + "/pg");
const fs = require("fs");
const path = require("path");

const DB_URL =
  "postgresql://postgres:Pedrito1122**@db.cfsqhbisrkqhbupyjrwz.supabase.co:5432/postgres";

const file = process.argv[2] || "supabase/migrations/20260816_reaction_pool.sql";

async function main() {
  const client = new Client({ connectionString: DB_URL, ssl: { rejectUnauthorized: false } });
  try {
    await client.connect();
    const sql = fs.readFileSync(path.resolve(__dirname, file), "utf8");
    console.log("Aplicando:", file);
    await client.query(sql);
    console.log("✅ Migracion aplicada correctamente.");
  } catch (err) {
    console.error("ERROR:", err.message);
    process.exitCode = 1;
  } finally {
    await client.end();
  }
}
main();
