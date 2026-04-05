// pages/employee/bookings.js
import { useEffect, useState } from 'react'
import RentingModal from '../../components/RentingModal'

export default function EmployeeBookings({ user }) {
  const [bookings, setBookings] = useState([])
  const [loading, setLoading] = useState(true)
  const [convertingBooking, setConvertingBooking] = useState(null)

  async function loadBookings() {
    setLoading(true)
    try {
      const res = await fetch('/api/bookings')
      const data = await res.json()
      setBookings(data.bookings || [])
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { loadBookings() }, [])

  async function handleDelete(bookingId) {
    if (!confirm('Cancel this booking? It will be archived.')) return
    await fetch(`/api/bookings/${bookingId}`, { method: 'DELETE' })
    loadBookings()
  }

  if (!user || user.role !== 'employee') {
    return (
      <div style={{ textAlign: 'center', padding: '4rem', color: '#8A8480' }}>
        <div style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>🔒</div>
        Staff access only. <a href="/login?role=employee" style={{ color: '#C9A84C' }}>Sign in as employee →</a>
      </div>
    )
  }

  return (
    <div style={{ maxWidth: '1100px', margin: '0 auto', padding: '2.5rem 2rem' }}>
      <div style={{ marginBottom: '2rem' }}>
        <div style={{ fontSize: '0.65rem', letterSpacing: '0.2em', textTransform: 'uppercase', color: '#C9A84C' }}>Employee Portal</div>
        <h1 style={{ fontFamily: 'Georgia, serif', fontSize: '2rem', fontWeight: 'normal', marginTop: '0.25rem' }}>Active Bookings</h1>
        <p style={{ color: '#8A8480', marginTop: '0.5rem', fontSize: '0.875rem' }}>
          Convert bookings to rentings when customers check in.
        </p>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '3rem', color: '#8A8480' }}>Loading bookings...</div>
      ) : bookings.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '3rem', color: '#8A8480' }}>No active bookings found.</div>
      ) : (
        <div style={{ background: 'white', borderRadius: '4px', border: '1px solid #E8E4DF', overflow: 'hidden' }}>
          <table className="elegant-table">
            <thead>
              <tr>
                <th>Booking</th>
                <th>Customer</th>
                <th>Room</th>
                <th>Hotel</th>
                <th>Dates</th>
                <th>Price</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {bookings.map(b => (
                <tr key={b.booking_id}>
                  <td>
                    <span style={{ fontFamily: 'Georgia, serif', fontSize: '0.9rem' }}>#{b.booking_id}</span>
                    <div style={{ fontSize: '0.7rem', color: '#8A8480' }}>
                      {new Date(b.created_at).toLocaleDateString()}
                    </div>
                  </td>
                  <td>
                    <div style={{ fontSize: '0.875rem' }}>{b.customer_name}</div>
                    <div style={{ fontSize: '0.7rem', color: '#8A8480' }}>ID: {b.customer_id}</div>
                  </td>
                  <td>
                    <span className="badge badge-gold" style={{ textTransform: 'capitalize' }}>{b.capacity}</span>
                    <div style={{ fontSize: '0.7rem', color: '#8A8480', marginTop: '0.2rem' }}>#{b.room_id}</div>
                  </td>
                  <td>
                    <div style={{ fontSize: '0.8rem' }}>{b.chain_name}</div>
                    <div style={{ fontSize: '0.7rem', color: '#8A8480' }}>{b.area}</div>
                  </td>
                  <td>
                    <div style={{ fontSize: '0.8rem' }}>{b.start_date?.slice(0,10)}</div>
                    <div style={{ fontSize: '0.7rem', color: '#8A8480' }}>to {b.end_date?.slice(0,10)}</div>
                  </td>
                  <td style={{ fontFamily: 'Georgia, serif' }}>${Number(b.price).toFixed(0)}/night</td>
                  <td>
                    <div style={{ display: 'flex', gap: '0.5rem' }}>
                      <button
                        className="btn-gold"
                        style={{ fontSize: '0.75rem', padding: '0.4rem 0.8rem' }}
                        onClick={() => setConvertingBooking(b)}
                      >
                        Check In
                      </button>
                      <button
                        className="btn-outline"
                        style={{ fontSize: '0.75rem', padding: '0.4rem 0.8rem', borderColor: '#8B1A1A', color: '#8B1A1A' }}
                        onClick={() => handleDelete(b.booking_id)}
                      >
                        Cancel
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {convertingBooking && (
        <RentingModal
          room={{
            room_id: convertingBooking.room_id,
            capacity: convertingBooking.capacity,
            price: convertingBooking.price,
            chain_name: convertingBooking.chain_name,
            area: convertingBooking.area,
          }}
          user={user}
          checkin={convertingBooking.start_date?.slice(0,10)}
          checkout={convertingBooking.end_date?.slice(0,10)}
          bookingId={convertingBooking.booking_id}
          customerId={convertingBooking.customer_id}
          onClose={() => setConvertingBooking(null)}
          onSuccess={() => { setConvertingBooking(null); loadBookings() }}
        />
      )}
    </div>
  )
}
