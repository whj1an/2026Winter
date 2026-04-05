// pages/api/customers/index.js
import { query } from '../../../lib/db'

export default async function handler(req, res) {
  if (req.method === 'GET') {
    try {
      const result = await query(`
        SELECT customer_id, full_name, address, id_type, id_value, registration_date
        FROM CUSTOMER
        ORDER BY customer_id
      `)
      res.status(200).json({ customers: result.rows })
    } catch (err) {
      res.status(500).json({ error: err.message })
    }
  }

  else if (req.method === 'POST') {
    const { full_name, address, id_type, id_value, registration_date } = req.body
    if (!full_name || !address || !id_type || !id_value)
      return res.status(400).json({ error: 'Missing required fields.' })
    try {
      const result = await query(`
        INSERT INTO CUSTOMER (full_name, address, id_type, id_value, registration_date)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING customer_id
      `, [full_name, address, id_type, id_value, registration_date || new Date().toISOString().slice(0,10)])
      res.status(201).json({ customer_id: result.rows[0].customer_id })
    } catch (err) {
      res.status(400).json({ error: err.message })
    }
  }

  else {
    res.status(405).end()
  }
}
