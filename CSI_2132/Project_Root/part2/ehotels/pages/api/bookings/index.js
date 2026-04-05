// pages/api/bookings/index.js
import { query } from '../../../lib/db'

export default async function handler(req, res) {
  if (req.method === 'GET') {
    // List bookings — optionally filter by customer_id
    const { customer_id } = req.query
    const params = []
    let where = `WHERE NOT EXISTS (
      SELECT 1 FROM RENTING RT WHERE RT.booking_id = B.booking_id
    )`
    if (customer_id) {
      where += ` AND B.customer_id = $1`
      params.push(parseInt(customer_id))
    }
    try {
      const result = await query(`
        SELECT
          B.booking_id,
          B.customer_id,
          B.room_id,
          B.start_date,
          B.end_date,
          B.created_at,
          C.full_name   AS customer_name,
          R.capacity,
          R.price,
          R.view_type,
          H.address     AS hotel_address,
          H.area,
          HC.chain_name,
          HC.category,
          (SELECT RT.renting_id FROM RENTING RT WHERE RT.booking_id = B.booking_id LIMIT 1) AS renting_id
        FROM BOOKING B
        JOIN CUSTOMER    C  ON B.customer_id = C.customer_id
        JOIN ROOM        R  ON B.room_id     = R.room_id
        JOIN HOTEL       H  ON R.hotel_id    = H.hotel_id
        JOIN HOTEL_CHAIN HC ON H.chain_id    = HC.chain_id
        ${where}
        ORDER BY B.start_date ASC
      `, params)
      res.status(200).json({ bookings: result.rows })
    } catch (err) {
      res.status(500).json({ error: err.message })
    }
  }

  else if (req.method === 'POST') {
    const { customer_id, room_id, start_date, end_date } = req.body
    if (!customer_id || !room_id || !start_date || !end_date)
      return res.status(400).json({ error: 'Missing required fields.' })
    if (start_date >= end_date)
      return res.status(400).json({ error: 'start_date must be before end_date.' })
    try {
      const result = await query(`
        INSERT INTO BOOKING (customer_id, room_id, start_date, end_date)
        VALUES ($1, $2, $3, $4)
        RETURNING booking_id
      `, [customer_id, room_id, start_date, end_date])
      res.status(201).json({ booking_id: result.rows[0].booking_id })
    } catch (err) {
      // Trigger violation comes back as a raised exception
      res.status(400).json({ error: err.message })
    }
  }

  else {
    res.status(405).end()
  }
}
