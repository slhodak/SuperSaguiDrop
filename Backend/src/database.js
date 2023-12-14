require('dotenv').config();
const { Pool } = require('pg');

const dbUser = process.env.DB_USER;
const dbPassword = process.env.DB_PASSWORD;
const dbHost = process.env.DB_HOST;
const dbName = process.env.DB_NAME;
const dbPort = process.env.DB_PORT;

const pool = new Pool({
  user: dbUser,
  host: dbHost,
  database: dbName,
  password: dbPassword,
  port: dbPort,
});

async function insertScore(data) {
  const query = `
    INSERT INTO high_scores (user_name, ts, saguis_saved, oncas_tamed, duration, total_score)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING *;`;

  const values = [
    data.user,
    data.ts,
    data.saguisSaved,
    data.oncasTamed,
    data.duration,
    data.totalScore
  ];
  
  try {
    const res = await pool.query(query, values);
    console.log(res.rows[0]);
  } catch (err) {
    console.error(err);
  }
}  
