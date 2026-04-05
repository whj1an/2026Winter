// pages/customer/bookings.js
import { useEffect, useState } from 'react'

export default function CustomerBookings({ user }) {
  const [bookings, setBookings] = useState([])
  const [loading, setLoading] = useState(true)

  async function load() {
    if (!user?.id) return
    setLoading(true)
    try {
      const res = await fetch(`/api/bookings?customer_id=${user.id}`)
      const data = await res.json()
      setBookings(data.bookings || [])
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { load() }, [user])

  async function handleCancel(bookingId) {
    if (!confirm('Cancel this booking?')) return
    await fetch(`/api/bookings/${bookingId}`, { method: 'DELETE' })
    load()
  }

  if (!user || user.role !== 'customer') {
    return (
      <div style={{ textAlign: 'center', padding: '4rem', color: '#8A8480' }}>
        <div style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>🔒</div>
        Please <a href="/login?role=customer" style={{ color: '#C9A84C' }}>sign in as a customer</a> to view your bookings.
      </div>
    )
  }

  return (
    <div style={{ maxWidth: '900px', margin: '0 auto', padding: '2.5rem 2rem' }}>
      <div style={{ marginBottom: '2rem' }}>
        <div style={{ fontSize: '0.65rem', letterSpacing: '0.2em', textTransform: 'uppercase', color: '#C9A84C' }}>My Account</div>
        <h1 style={{ fontFamily: 'Georgia, serif', fontSize: '2rem', fontWeight: 'normal', marginTop: '0.25rem' }}>
          My Bookings
        </h1>
        <p style={{ color: '#8A8480', marginTop: '0.5rem', fontSize: '0.875rem' }}>
          Welcome back, {user.name}. Here are your upcoming reservations.
        </p>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '3rem', color: '#8A8480' }}>Loading your bookings...</div>
      ) : bookings.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '3rem', background: 'white', borderRadius: '4px', border: '1px solid #E8E4DF' }}>
          <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>◻</div>
          <div style={{ color: '#8A8480', marginBottom: '1rem' }}>No bookings yet.</div>
          <a href="/search"><button className="btn-gold">Find Rooms</button></a>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          {bookings.map(b => {
            const nights = Math.ceil((new Date(b.end_date) - new Date(b.start_date)) / 86400000)
            const total = (nights * Number(b.price)).toFixed(2)
            const isPast = new Date(b.end_date) < new Date()
            return (
              <div key={b.booking_id} className="card-hover" style={{
                background: 'white',
                borderRadius: '4px',
                border: '1px solid #E8E4DF',
                padding: '1.5rem',
                display: 'grid',
                gridTemplateColumns: '1fr auto',
                gap: '1.5rem',
                alignItems: 'center',
              }}>
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.5rem' }}>
                    <span style={{ fontFamily: 'Georgia, serif', fontSize: '1rem', color: '#1C1C1E' }}>
                      Booking #{b.booking_id}
                    </span>
                    {isPast
                      ? <span className="badge badge-gray">Past</span>
                      : <span className="badge badge-green">Upcoming</span>}
                    {b.renting_id && <span className="badge badge-gold">Checked In</span>}
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))', gap: '0.5rem' }}>
                    <div>
                      <div style={{ fontSize: '0.65rem', letterSpacing: '0.1em', textTransform: 'uppercase', color: '#8A8480' }}>Hotel</div>
                      <div style={{ fontSize: '0.875rem' }}>{b.chain_name}</div>
                      <div style={{ fontSize: '0.75rem', color: '#555' }}>{b.area}</div>
                    </div>
                    <div>
                      <div style={{ fontSize: '0.65rem', letterSpacing: '0.1em', textTransform: 'uppercase', color: '#8A8480' }}>Room</div>
                      <div style={{ fontSize: '0.875rem', textTransform: 'capitalize' }}>{b.capacity} (#{b.room_id})</div>
                      <div style={{ fontSize: '0.75rem', color: '#555' }}>${Number(b.price).toFixed(0)}/night</div>
                    </div>
                    <div>
                      <div style={{ fontSize: '0.65rem', letterSpacing: '0.1em', textTransform: 'uppercase', color: '#8A8480' }}>Dates</div>
                      <div style={{ fontSize: '0.875rem' }}>{b.start_date?.slice(0,10)}</div>
                      <div style={{ fontSize: '0.75rem', color: '#555' }}>to {b.end_date?.slice(0,10)}</div>
                    </div>
                    <div>
                      <div style={{ fontSize: '0.65rem', letterSpacing: '0.1em', textTransform: 'uppercase', color: '#8A8480' }}>Total</div>
                      <div style={{ fontSize: '1rem', fontFamily: 'Georgia, serif', color: '#C9A84C' }}>${total}</div>
                      <div style={{ fontSize: '0.75rem', color: '#555' }}>{nights} nights</div>
                    </div>
                  </div>
                </div>

                <div>
                  {!isPast && !b.renting_id && (
                    <button
                      className="btn-outline"
                      style={{ borderColor: '#8B1A1A', color: '#8B1A1A', fontSize: '0.8rem' }}
                      onClick={() => handleCancel(b.booking_id)}
                    >
                      Cancel
                    </button>
                  )}
                </div>
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}
