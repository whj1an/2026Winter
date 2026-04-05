// pages/employee/rentings.js
import { useEffect, useState } from 'react'

export default function EmployeeRentings({ user }) {
  const [rentings, setRentings] = useState([])
  const [loading, setLoading] = useState(true)
  const [payingRenting, setPayingRenting] = useState(null)
  const [paymentAmount, setPaymentAmount] = useState('')

  async function load() {
    setLoading(true)
    try {
      const res = await fetch('/api/rentings')
      const data = await res.json()
      setRentings(data.rentings || [])
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { load() }, [])

  if (!user || user.role !== 'employee') {
    return (
      <div style={{ textAlign: 'center', padding: '4rem', color: '#8A8480' }}>
        Staff access only. <a href="/login?role=employee" style={{ color: '#C9A84C' }}>Sign in →</a>
      </div>
    )
  }

  return (
    <div style={{ maxWidth: '1100px', margin: '0 auto', padding: '2.5rem 2rem' }}>
      <div style={{ marginBottom: '2rem' }}>
        <div style={{ fontSize: '0.65rem', letterSpacing: '0.2em', textTransform: 'uppercase', color: '#C9A84C' }}>Employee Portal</div>
        <h1 style={{ fontFamily: 'Georgia, serif', fontSize: '2rem', fontWeight: 'normal', marginTop: '0.25rem' }}>Active Rentings</h1>
        <p style={{ color: '#8A8480', marginTop: '0.5rem', fontSize: '0.875rem' }}>
          Manage current guest stays. Record payments on check-out.
        </p>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '3rem', color: '#8A8480' }}>Loading rentings...</div>
      ) : rentings.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '3rem', color: '#8A8480' }}>No active rentings found.</div>
      ) : (
        <div style={{ background: 'white', borderRadius: '4px', border: '1px solid #E8E4DF', overflow: 'hidden' }}>
          <table className="elegant-table">
            <thead>
              <tr>
                <th>Renting</th>
                <th>Customer</th>
                <th>Room</th>
                <th>Hotel</th>
                <th>Dates</th>
                <th>Type</th>
                <th>Employee</th>
                <th>Payment</th>
              </tr>
            </thead>
            <tbody>
              {rentings.map(r => {
                const nights = Math.ceil((new Date(r.end_date) - new Date(r.start_date)) / 86400000)
                const total = (nights * Number(r.price)).toFixed(2)
                return (
                  <tr key={r.renting_id}>
                    <td>
                      <span style={{ fontFamily: 'Georgia, serif' }}>#{r.renting_id}</span>
                      <div style={{ fontSize: '0.7rem', color: '#8A8480' }}>
                        {new Date(r.checkin_time).toLocaleDateString()}
                      </div>
                    </td>
                    <td>
                      <div style={{ fontSize: '0.875rem' }}>{r.customer_name}</div>
                      <div style={{ fontSize: '0.7rem', color: '#8A8480' }}>ID: {r.customer_id}</div>
                    </td>
                    <td>
                      <span className="badge badge-gold" style={{ textTransform: 'capitalize' }}>{r.capacity}</span>
                      <div style={{ fontSize: '0.7rem', color: '#8A8480', marginTop: '0.2rem' }}>#{r.room_id}</div>
                    </td>
                    <td>
                      <div style={{ fontSize: '0.8rem' }}>{r.chain_name}</div>
                      <div style={{ fontSize: '0.7rem', color: '#8A8480' }}>{r.area}</div>
                    </td>
                    <td>
                      <div style={{ fontSize: '0.8rem' }}>{r.start_date?.slice(0,10)}</div>
                      <div style={{ fontSize: '0.7rem', color: '#8A8480' }}>to {r.end_date?.slice(0,10)}</div>
                    </td>
                    <td>
                      {r.booking_id
                        ? <span className="badge badge-green">From Booking #{r.booking_id}</span>
                        : <span className="badge badge-gray">Walk-in</span>}
                    </td>
                    <td style={{ fontSize: '0.8rem' }}>{r.employee_name}</td>
                    <td>
                      <div style={{ fontSize: '0.8rem', fontFamily: 'Georgia, serif', color: '#C9A84C' }}>${total}</div>
                      <div style={{ fontSize: '0.65rem', color: '#8A8480' }}>{nights} nights</div>
                      <button
                        className="btn-gold"
                        style={{ fontSize: '0.7rem', padding: '0.3rem 0.6rem', marginTop: '0.3rem' }}
                        onClick={() => { setPayingRenting(r); setPaymentAmount(total) }}
                      >
                        Record Payment
                      </button>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      )}

      {/* Payment modal */}
      {payingRenting && (
        <div className="modal-overlay" onClick={() => setPayingRenting(null)}>
          <div className="modal-box" onClick={e => e.stopPropagation()}>
            <div style={{ marginBottom: '1.5rem' }}>
              <div style={{ fontSize: '0.65rem', letterSpacing: '0.2em', textTransform: 'uppercase', color: '#C9A84C' }}>Record Payment</div>
              <h2 style={{ fontFamily: 'Georgia, serif', fontSize: '1.4rem', fontWeight: 'normal', marginTop: '0.25rem' }}>
                Renting #{payingRenting.renting_id}
              </h2>
              <div style={{ fontSize: '0.8rem', color: '#8A8480' }}>
                {payingRenting.customer_name} · {payingRenting.capacity} room
              </div>
            </div>
            <div className="field" style={{ marginBottom: '1rem' }}>
              <label>Payment Amount ($)</label>
              <input
                type="number"
                step="0.01"
                value={paymentAmount}
                onChange={e => setPaymentAmount(e.target.value)}
              />
            </div>
            <div style={{ background: '#F0EDE8', padding: '0.75rem', borderRadius: '2px', fontSize: '0.8rem', color: '#555', marginBottom: '1rem' }}>
              Note: Payment history is not stored in the database (per project spec).
              This action records receipt of payment.
            </div>
            <div style={{ display: 'flex', gap: '0.75rem' }}>
              <button className="btn-outline" onClick={() => setPayingRenting(null)} style={{ flex: 1 }}>Cancel</button>
              <button className="btn-gold" onClick={() => { alert(`Payment of $${paymentAmount} recorded for renting #${payingRenting.renting_id}.`); setPayingRenting(null) }} style={{ flex: 1 }}>
                Confirm Payment
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
