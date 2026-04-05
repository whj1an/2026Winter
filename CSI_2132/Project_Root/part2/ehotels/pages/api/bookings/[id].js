// pages/api/bookings/[id].js
import { query } from '../../../lib/db'

export default async function handler(req, res) {
  const { id } = req.query

  if (req.method === 'DELETE') {
    try {
      // Deleting triggers trg_archive_booking automatically
      await query('DELETE FROM BOOKING WHERE booking_id = $1', [id])
      res.status(200).json({ ok: true })
    } catch (err) {
      res.status(500).json({ error: err.message })
    }
  } else {
    res.status(405).end()
  }
}
