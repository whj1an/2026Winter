// pages/api/rooms/available.js
import { query } from '../../../lib/db'

export default async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).end()

  const { area, checkin, checkout, capacity, chain, stars, maxPrice, minRooms } = req.query

  // Build WHERE clauses dynamically
  const conditions = ['R.problems_or_damages IS NULL']
  const params = []
  let idx = 1

  if (area) {
    conditions.push(`H.area = $${idx++}`)
    params.push(area)
  }
  if (capacity) {
    conditions.push(`R.capacity = $${idx++}`)
    params.push(capacity)
  }
  if (chain) {
    conditions.push(`HC.chain_name = $${idx++}`)
    params.push(chain)
  }
  if (stars) {
    conditions.push(`HC.category = $${idx++}`)
    params.push(parseInt(stars))
  }
  if (maxPrice) {
    conditions.push(`R.price <= $${idx++}`)
    params.push(parseFloat(maxPrice))
  }
  if (minRooms) {
    conditions.push(`H.num_rooms >= $${idx++}`)
    params.push(parseInt(minRooms))
  }

  // Overlapping booking exclusion
  if (checkin && checkout) {
    conditions.push(`NOT EXISTS (
      SELECT 1 FROM BOOKING B
      WHERE B.room_id = R.room_id
        AND B.start_date < $${idx++}
        AND B.end_date   > $${idx++}
    )`)
    params.push(checkout, checkin)

    conditions.push(`NOT EXISTS (
      SELECT 1 FROM RENTING RT
      WHERE RT.room_id = R.room_id
        AND RT.start_date < $${idx++}
        AND RT.end_date   > $${idx++}
    )`)
    params.push(checkout, checkin)
  }

  const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''

  try {
    const result = await query(`
      SELECT
        R.room_id,
        R.price,
        R.capacity,
        R.view_type,
        R.extendable,
        H.hotel_id,
        H.address   AS hotel_address,
        H.area,
        H.num_rooms,
        HC.chain_name,
        HC.category,
        ARRAY_AGG(DISTINCT RA.amenity) FILTER (WHERE RA.amenity IS NOT NULL) AS amenities
      FROM ROOM R
      JOIN HOTEL H        ON R.hotel_id = H.hotel_id
      JOIN HOTEL_CHAIN HC ON H.chain_id = HC.chain_id
      LEFT JOIN ROOM_AMENITY RA ON R.room_id = RA.room_id
      ${whereClause}
      GROUP BY R.room_id, R.price, R.capacity, R.view_type, R.extendable,
               H.hotel_id, H.address, H.area, H.num_rooms,
               HC.chain_name, HC.category
      ORDER BY HC.category DESC, R.price ASC
      LIMIT 100
    `, params)

    res.status(200).json({ rooms: result.rows })
  } catch (err) {
    console.error(err)
    res.status(500).json({ error: err.message })
  }
}
