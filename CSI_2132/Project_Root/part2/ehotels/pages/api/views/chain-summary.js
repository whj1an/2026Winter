// pages/api/views/chain-summary.js
import { query } from '../../../lib/db'

export default async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).end()
  try {
    const result = await query('SELECT * FROM view_chain_summary')
    res.status(200).json({ data: result.rows })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}
