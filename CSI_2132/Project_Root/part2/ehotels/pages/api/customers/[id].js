// pages/api/customers/[id].js
import { query } from '../../../lib/db'

export default async function handler(req, res) {
  const { id } = req.query

  if (req.method === 'GET') {
    try {
      const result = await query(
        'SELECT * FROM CUSTOMER WHERE customer_id = $1', [id]
      )
      if (result.rows.length === 0) return res.status(404).json({ error: 'Not found' })
      res.status(200).json(result.rows[0])
    } catch (err) {
      res.status(500).json({ error: err.message })
    }
  }

  else if (req.method === 'PUT') {
    const { full_name, address, id_type, id_value, registration_date } = req.body
    try {
      await query(`
        UPDATE CUSTOMER
        SET full_name=$1, address=$2, id_type=$3, id_value=$4, registration_date=$5
        WHERE customer_id=$6
      `, [full_name, address, id_type, id_value, registration_date, id])
      res.status(200).json({ ok: true })
    } catch (err) {
      res.status(400).json({ error: err.message })
    }
  }

  else if (req.method === 'DELETE') {
    try {
      await query('DELETE FROM CUSTOMER WHERE customer_id = $1', [id])
      res.status(200).json({ ok: true })
    } catch (err) {
      res.status(500).json({ error: err.message })
    }
  }

  else {
    res.status(405).end()
  }
}
