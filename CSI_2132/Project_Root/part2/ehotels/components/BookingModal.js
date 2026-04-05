// components/BookingModal.js
import { useState } from 'react'

export default function BookingModal({ room, user, checkin, checkout, onClose, onSuccess }) {
  const [startDate, setStartDate] = useState(checkin || '')
  const [endDate, setEndDate] = useState(checkout || '')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  async function handleSubmit(e) {
    e.preventDefault()
    setError('')
    if (!startDate || !endDate) { setError('Please select both dates.'); return }
    if (startDate >= endDate) { setError('Check-out must be after check-in.'); return }
    setLoading(true)
    try {
      const res = await fetch('/api/bookings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          customer_id: user.id,
          room_id: room.room_id,
          start_date: startDate,
          end_date: endDate,
        }),
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Failed to book')
      onSuccess()
      alert(`✓ Booking confirmed! Booking ID: ${data.booking_id}`)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-box" onClick={e => e.stopPropagation()}>
        <div style={{ marginBottom: '1.5rem' }}>
          <div style={{ fontSize: '0.65rem', letterSpacing: '0.2em', textTransform: 'uppercase', color: '#C9A84C' }}>New Booking</div>
          <h2 style={{ fontFamily: 'Georgia, serif', fontSize: '1.4rem', fontWeight: 'normal', marginTop: '0.25rem' }}>
            {room.capacity.charAt(0).toUpperCase() + room.capacity.slice(1)} Room #{room.room_id}
          </h2>
          <div style={{ fontSize: '0.8rem', color: '#8A8480' }}>{room.chain_name} · {room.area} · ${Number(room.price).toFixed(0)}/night</div>
        </div>

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
            <div className="field">
              <label>Check-in Date</label>
              <input type="date" value={startDate} onChange={e => setStartDate(e.target.value)} required />
            </div>
            <div className="field">
              <label>Check-out Date</label>
              <input type="date" value={endDate} onChange={e => setEndDate(e.target.value)} required />
            </div>
          </div>

          {startDate && endDate && startDate < endDate && (
            <div style={{ background: '#F0EDE8', borderRadius: '2px', padding: '0.75rem 1rem', fontSize: '0.85rem' }}>
              <strong>Summary:</strong> {Math.ceil((new Date(endDate) - new Date(startDate)) / 86400000)} nights ·{' '}
              <strong>${(Math.ceil((new Date(endDate) - new Date(startDate)) / 86400000) * Number(room.price)).toFixed(2)}</strong> total
            </div>
          )}

          {error && (
            <div className="badge badge-red" style={{ padding: '0.6rem', fontSize: '0.8rem', display: 'block' }}>{error}</div>
          )}

          <div style={{ display: 'flex', gap: '0.75rem', marginTop: '0.5rem' }}>
            <button type="button" className="btn-outline" onClick={onClose} style={{ flex: 1 }}>Cancel</button>
            <button type="submit" className="btn-gold" disabled={loading} style={{ flex: 1 }}>
              {loading ? 'Booking...' : 'Confirm Booking'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
