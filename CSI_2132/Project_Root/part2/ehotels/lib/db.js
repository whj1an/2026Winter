// lib/db.js
// PostgreSQL connection pool using the 'pg' library.
// Set the DATABASE_URL environment variable in .env.local:
//   DATABASE_URL=postgresql://user:password@localhost:5432/ehotels

import { Pool } from 'pg'

let pool

export function getPool() {
  if (!pool) {
    pool = new Pool({
      connectionString: process.env.DATABASE_URL,
    })
  }
  return pool
}

export async function query(text, params) {
  const pool = getPool()
  const result = await pool.query(text, params)
  return result
}
