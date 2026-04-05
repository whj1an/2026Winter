// pages/views.js
import { useEffect, useState } from 'react'

export default function ViewsPage() {
  const [areaData, setAreaData] = useState([])
  const [hotelData, setHotelData] = useState([])
  const [selectedHotel, setSelectedHotel] = useState('')
  const [hotels, setHotels] = useState([])
  const [loading1, setLoading1] = useState(true)
  const [loading2, setLoading2] = useState(false)
  const [chainSummary, setChainSummary] = useState([])

  useEffect(() => {
    // Load View 1
    fetch('/api/views/available-per-area')
      .then(r => r.json())
      .then(d => { setAreaData(d.data || []); setLoading1(false) })

    // Load hotel list for View 2 dropdown
    fetch('/api/hotels')
      .then(r => r.json())
      .then(d => setHotels(d.hotels || []))

    // Load chain summary view
    fetch('/api/views/chain-summary')
      .then(r => r.json())
      .then(d => setChainSummary(d.data || []))
  }, [])

  useEffect(() => {
    if (!selectedHotel) return
    setLoading2(true)
    fetch(`/api/views/hotel-capacity?hotel_id=${selectedHotel}`)
      .then(r => r.json())
      .then(d => { setHotelData(d.data || []); setLoading2(false) })
  }, [selectedHotel])

  return (
    <div style={{ maxWidth: '1100px', margin: '0 auto', padding: '2.5rem 2rem' }}>
      <div style={{ textAlign: 'center', marginBottom: '3rem' }}>
        <div style={{ fontSize: '0.65rem', letterSpacing: '0.25em', textTransform: 'uppercase', color: '#C9A84C', marginBottom: '0.5rem' }}>
          SQL Views
        </div>
        <h1 style={{ fontFamily: 'Georgia, serif', fontSize: '2rem', fontWeight: 'normal' }}>Analytics Dashboard</h1>
        <div className="divider" />
        <p style={{ color: '#8A8480', fontSize: '0.875rem', marginTop: '1rem' }}>
          Live data from the database views defined in requirement 2f.
        </p>
      </div>

      {/* View 1 */}
      <section style={{ marginBottom: '3rem' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: '1rem' }}>
          <div>
            <h2 style={{ fontFamily: 'Georgia, serif', fontSize: '1.4rem', fontWeight: 'normal' }}>View 1: Available Rooms per Area</h2>
            <div style={{ fontSize: '0.72rem', color: '#8A8480', fontFamily: 'Courier New, monospace', marginTop: '0.25rem' }}>
              SELECT * FROM view_available_rooms_per_area;
            </div>
          </div>
          <span className="badge badge-gold">Live View</span>
        </div>

        {loading1 ? (
          <div style={{ textAlign: 'center', padding: '2rem', color: '#8A8480' }}>Loading...</div>
        ) : (
          <div style={{ background: 'white', borderRadius: '4px', border: '1px solid #E8E4DF', overflow: 'hidden' }}>
            <table className="elegant-table">
              <thead>
                <tr>
                  <th>Area</th>
                  <th>Available Rooms</th>
                  <th>Min Price</th>
                  <th>Max Price</th>
                  <th>Avg Price</th>
                  <th>Availability</th>
                </tr>
              </thead>
              <tbody>
                {areaData.map(row => (
                  <tr key={row.area}>
                    <td style={{ fontFamily: 'Georgia, serif' }}>{row.area}</td>
                    <td>
                      <span style={{ fontSize: '1.1rem', fontFamily: 'Georgia, serif', color: '#1C1C1E' }}>{row.available_rooms}</span>
                    </td>
                    <td>${Number(row.min_price).toFixed(0)}</td>
                    <td>${Number(row.max_price).toFixed(0)}</td>
                    <td style={{ color: '#C9A84C', fontFamily: 'Georgia, serif' }}>${Number(row.avg_price).toFixed(0)}</td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                        <div style={{
                          height: '6px',
                          width: `${Math.min(100, (row.available_rooms / 40) * 100)}%`,
                          maxWidth: '100px',
                          background: '#C9A84C',
                          borderRadius: '3px',
                        }} />
                        <span style={{ fontSize: '0.72rem', color: '#8A8480' }}>{row.available_rooms} rooms</span>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {/* View 2 */}
      <section style={{ marginBottom: '3rem' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: '1rem', flexWrap: 'wrap', gap: '0.75rem' }}>
          <div>
            <h2 style={{ fontFamily: 'Georgia, serif', fontSize: '1.4rem', fontWeight: 'normal' }}>View 2: Hotel Room Capacity</h2>
            <div style={{ fontSize: '0.72rem', color: '#8A8480', fontFamily: 'Courier New, monospace', marginTop: '0.25rem' }}>
              SELECT * FROM view_hotel_room_capacity WHERE hotel_id = ?;
            </div>
          </div>
          <div className="field" style={{ minWidth: '220px' }}>
            <label>Select Hotel</label>
            <select value={selectedHotel} onChange={e => setSelectedHotel(e.target.value)}>
              <option value="">Choose a hotel...</option>
              {hotels.map(h => (
                <option key={h.hotel_id} value={h.hotel_id}>
                  #{h.hotel_id} — {h.chain_name} ({h.area})
                </option>
              ))}
            </select>
          </div>
        </div>

        {!selectedHotel ? (
          <div style={{ textAlign: 'center', padding: '2rem', background: 'white', borderRadius: '4px', border: '1px solid #E8E4DF', color: '#8A8480', fontSize: '0.875rem' }}>
            Select a hotel above to see its room capacity breakdown.
          </div>
        ) : loading2 ? (
          <div style={{ textAlign: 'center', padding: '2rem', color: '#8A8480' }}>Loading...</div>
        ) : (
          <div style={{ background: 'white', borderRadius: '4px', border: '1px solid #E8E4DF', overflow: 'hidden' }}>
            {hotelData.length > 0 && (
              <div style={{ padding: '1rem 1.5rem', borderBottom: '1px solid #E8E4DF', background: '#F8F5F0' }}>
                <div style={{ fontFamily: 'Georgia, serif', fontSize: '1rem' }}>{hotelData[0]?.chain_name}</div>
                <div style={{ fontSize: '0.8rem', color: '#8A8480' }}>{hotelData[0]?.hotel_address} · {'★'.repeat(hotelData[0]?.hotel_stars || 0)}</div>
              </div>
            )}
            <table className="elegant-table">
              <thead>
                <tr>
                  <th>Room Type</th>
                  <th>Count</th>
                  <th>Avg Price / Night</th>
                </tr>
              </thead>
              <tbody>
                {hotelData.map(row => (
                  <tr key={row.capacity}>
                    <td>
                      <span className="badge badge-gold" style={{ textTransform: 'capitalize' }}>{row.capacity}</span>
                    </td>
                    <td style={{ fontFamily: 'Georgia, serif', fontSize: '1.1rem' }}>{row.num_rooms_of_capacity}</td>
                    <td style={{ color: '#C9A84C', fontFamily: 'Georgia, serif' }}>${Number(row.avg_price_for_capacity).toFixed(0)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {/* Chain summary view (bonus) */}
      <section>
        <div style={{ marginBottom: '1rem' }}>
          <h2 style={{ fontFamily: 'Georgia, serif', fontSize: '1.4rem', fontWeight: 'normal' }}>View 4: Chain Summary</h2>
          <div style={{ fontSize: '0.72rem', color: '#8A8480', fontFamily: 'Courier New, monospace', marginTop: '0.25rem' }}>
            SELECT * FROM view_chain_summary;
          </div>
        </div>
        <div style={{ background: 'white', borderRadius: '4px', border: '1px solid #E8E4DF', overflow: 'hidden' }}>
          <table className="elegant-table">
            <thead>
              <tr>
                <th>Chain</th>
                <th>Stars</th>
                <th>Hotels</th>
                <th>Areas</th>
                <th>Total Rooms</th>
                <th>Avg Price</th>
                <th>Price Range</th>
              </tr>
            </thead>
            <tbody>
              {chainSummary.map(c => (
                <tr key={c.chain_id}>
                  <td style={{ fontFamily: 'Georgia, serif', fontSize: '0.9rem' }}>{c.chain_name}</td>
                  <td><span className="stars" style={{ fontSize: '0.8rem' }}>{'★'.repeat(c.chain_stars)}</span></td>
                  <td>{c.total_hotels}</td>
                  <td>{c.areas_covered}</td>
                  <td style={{ fontFamily: 'Georgia, serif' }}>{c.total_rooms}</td>
                  <td style={{ color: '#C9A84C', fontFamily: 'Georgia, serif' }}>${c.avg_room_price}</td>
                  <td style={{ fontSize: '0.8rem', color: '#555' }}>${Number(c.cheapest_room).toFixed(0)} – ${Number(c.most_expensive_room).toFixed(0)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  )
}
