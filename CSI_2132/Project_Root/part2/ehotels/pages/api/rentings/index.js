// pages/api/rentings/index.js
import { query } from '../../../lib/db'

export default async function handler(req, res) {
  if (req.method === 'GET') {
    try {
      const result = await query(`
        SELECT
          RT.renting_id,
          RT.customer_id,
          RT.room_id,
          RT.employee_id,
          RT.booking_id,
          RT.start_date,
          RT.end_date,
          RT.checkin_time,
          C.full_name   AS customer_name,
          E.full_name   AS employee_name,
          R.capacity,
          R.price,
          R.view_type,
          H.address     AS hotel_address,
          H.area,
          HC.chain_name
        FROM RENTING RT
        JOIN CUSTOMER    C  ON RT.customer_id = C.customer_id
        JOIN EMPLOYEE    E  ON RT.employee_id = E.employee_id
        JOIN ROOM        R  ON RT.room_id     = R.room_id
        JOIN HOTEL       H  ON R.hotel_id     = H.hotel_id
        JOIN HOTEL_CHAIN HC ON H.chain_id     = HC.chain_id
        ORDER BY RT.checkin_time DESC
      `)
      res.status(200).json({ rentings: result.rows })
    } catch (err) {
      res.status(500).json({ error: err.message })
    }
  }

  else if (req.method === 'POST') {
    const { customer_id, room_id, employee_id, booking_id, start_date, end_date } = req.body
    if (!customer_id || !room_id || !employee_id || !start_date || !end_date)
      return res.status(400).json({ error: 'Missing required fields.' })
    if (start_date >= end_date)
      return res.status(400).json({ error: 'start_date must be before end_date.' })
    try {
      const result = await query(`
        INSERT INTO RENTING (customer_id, room_id, employee_id, booking_id, start_date, end_date)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING renting_id
      `, [customer_id, room_id, employee_id, booking_id || null, start_date, end_date])
      res.status(201).json({ renting_id: result.rows[0].renting_id })
    } catch (err) {
      res.status(400).json({ error: err.message })
    }
  }

  else {
    res.status(405).end()
  }
}
