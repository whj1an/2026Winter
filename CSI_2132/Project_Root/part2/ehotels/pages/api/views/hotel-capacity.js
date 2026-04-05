// pages/api/views/hotel-capacity.js
import { query } from '../../../lib/db'

export default async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).end()
  const { hotel_id } = req.query
  if (!hotel_id) return res.status(400).json({ error: 'hotel_id required' })
  try {
    const result = await query(
      'SELECT * FROM view_hotel_room_capacity WHERE hotel_id = $1',
      [hotel_id]
    )
    res.status(200).json({ data: result.rows })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}
