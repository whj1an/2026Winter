// pages/api/employees/[id].js
import { query } from '../../../lib/db'

export default async function handler(req, res) {
  const { id } = req.query

  if (req.method === 'GET') {
    try {
      const result = await query(
        'SELECT * FROM EMPLOYEE WHERE employee_id = $1', [id]
      )
      if (result.rows.length === 0) return res.status(404).json({ error: 'Not found' })
      res.status(200).json(result.rows[0])
    } catch (err) {
      res.status(500).json({ error: err.message })
    }
  } else {
    res.status(405).end()
  }
}
