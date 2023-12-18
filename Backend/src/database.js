require('dotenv').config();
const { Pool } = require('pg');

const dbUser = process.env.DB_USER;
const dbPassword = process.env.DB_PASSWORD;
const dbHost = process.env.DB_HOST;
const dbName = process.env.DB_NAME;
const dbPort = process.env.DB_PORT;


class Database {
  constructor() {
    this.pool = new Pool({
      user: dbUser,
      host: dbHost,
      database: dbName,
      password: dbPassword,
      port: dbPort,
    });
  }

  async insertScore(data) {
    const query = `
      INSERT INTO scores (user_name, ts, saguis_saved, oncas_tamed, duration, total_score)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *;`;

    const values = [
      data.un,
      data.tis,
      data.ss,
      data.ot,
      data.d,
      data.tos
    ];
    
    try {
      const res = await this.pool.query(query, values);
    } catch (err) {
      console.error(err);
    }
  }

  async fetchRecentScores(userName) {
    // TODO: Exclude scores more than a week old
    const query = `
      SELECT user_name, ts, saguis_saved, oncas_tamed, duration, total_score
      FROM scores
      WHERE user_name = $1`;
    
    try {
      const res = await this.pool.query(query, [userName]);
      return res.rows;
    } catch (err) {
      console.error(err);
      return [];
    }
  }
}

module.exports = Database;
