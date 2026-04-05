// pages/api/hotels/index.js
import { query } from '../../../lib/db'

export default async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).end()
  try {
    const result = await query(`
      SELECT H.hotel_id, H.address, H.area, H.num_rooms,
             HC.chain_name, HC.category
      FROM HOTEL H
      JOIN HOTEL_CHAIN HC ON H.chain_id = HC.chain_id
      ORDER BY HC.category DESC, H.area
    `)
    res.status(200).json({ hotels: result.rows })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}
