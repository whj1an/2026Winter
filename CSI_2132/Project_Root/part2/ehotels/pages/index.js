// pages/index.js
import Link from 'next/link'
import { useRouter } from 'next/router'
import { useState } from 'react'

const AREAS = [
  'New York', 'Toronto', 'Montreal', 'Chicago', 'Los Angeles',
  'Miami', 'Vancouver', 'Boston', 'Dallas', 'Seattle',
  'San Francisco', 'Ottawa', 'Las Vegas', 'Denver', 'New Orleans', 'Washington DC',
]

const CHAINS = ['Marriott International', 'Hilton Hotels', 'Holiday Inn (IHG)', 'Best Western', 'Motel 6']

export default function Home() {
  const router = useRouter()
  const [area, setArea] = useState('')
  const [checkin, setCheckin] = useState('')
  const [checkout, setCheckout] = useState('')
  const [capacity, setCapacity] = useState('')

  function handleSearch(e) {
    e.preventDefault()
    const params = new URLSearchParams()
    if (area) params.set('area', area)
    if (checkin) params.set('checkin', checkin)
    if (checkout) params.set('checkout', checkout)
    if (capacity) params.set('capacity', capacity)
    router.push(`/search?${params.toString()}`)
  }

  return (
    <div>
      {/* Hero */}
      <section style={{
        background: 'linear-gradient(160deg, #1C1C1E 60%, #2C2416 100%)',
        padding: '6rem 2rem',
        position: 'relative',
        overflow: 'hidden',
      }}>
        {/* Decorative gold lines */}
        <div style={{
          position: 'absolute', top: 0, left: 0, right: 0, bottom: 0,
          backgroundImage: 'repeating-linear-gradient(90deg, rgba(201,168,76,0.04) 0px, rgba(201,168,76,0.04) 1px, transparent 1px, transparent 80px)',
          pointerEvents: 'none',
        }} />

        <div style={{ maxWidth: '900px', margin: '0 auto', textAlign: 'center', position: 'relative' }}>
          <div style={{ fontSize: '0.65rem', letterSpacing: '0.3em', textTransform: 'uppercase', color: '#C9A84C', marginBottom: '1.5rem' }}>
            Five Chains · Over 40 Properties · North America
          </div>

          <h1 style={{
            fontFamily: 'Georgia, serif',
            fontSize: 'clamp(2.2rem, 5vw, 4rem)',
            color: 'white',
            fontWeight: 'normal',
            lineHeight: 1.15,
            marginBottom: '1.25rem',
          }}>
            Reserve Your Perfect<br />
            <span style={{ color: '#C9A84C' }}>Hotel Room</span>
          </h1>

          <p style={{ color: '#8A8480', fontSize: '1.05rem', maxWidth: '500px', margin: '0 auto 3rem', lineHeight: 1.7 }}>
            From budget stays to five-star luxury across 14 cities in North America.
            Real-time availability, instant booking.
          </p>

          {/* Search card */}
          <form onSubmit={handleSearch} style={{
            background: 'white',
            borderRadius: '4px',
            padding: '1.75rem',
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))',
            gap: '1rem',
            alignItems: 'end',
            boxShadow: '0 20px 60px rgba(0,0,0,0.3)',
            textAlign: 'left',
          }}>
            <div className="field">
              <label>Area / City</label>
              <select value={area} onChange={e => setArea(e.target.value)}>
                <option value="">Any area</option>
                {AREAS.map(a => <option key={a} value={a}>{a}</option>)}
              </select>
            </div>
            <div className="field">
              <label>Check-in</label>
              <input type="date" value={checkin} onChange={e => setCheckin(e.target.value)} />
            </div>
            <div className="field">
              <label>Check-out</label>
              <input type="date" value={checkout} onChange={e => setCheckout(e.target.value)} />
            </div>
            <div className="field">
              <label>Room Type</label>
              <select value={capacity} onChange={e => setCapacity(e.target.value)}>
                <option value="">Any type</option>
                <option value="single">Single</option>
                <option value="double">Double</option>
                <option value="triple">Triple</option>
                <option value="quad">Quad</option>
                <option value="suite">Suite</option>
              </select>
            </div>
            <div>
              <button type="submit" className="btn-gold" style={{ width: '100%', padding: '0.6rem 1rem' }}>
                Search Rooms
              </button>
            </div>
          </form>
        </div>
      </section>

      {/* Features */}
      <section style={{ padding: '5rem 2rem', maxWidth: '1100px', margin: '0 auto' }}>
        <div style={{ textAlign: 'center', marginBottom: '3.5rem' }}>
          <div style={{ fontSize: '0.65rem', letterSpacing: '0.25em', textTransform: 'uppercase', color: '#C9A84C', marginBottom: '0.75rem' }}>Why eHotels</div>
          <h2 style={{ fontFamily: 'Georgia, serif', fontSize: '2rem', fontWeight: 'normal', color: '#1C1C1E' }}>A New Standard in Hotel Booking</h2>
          <div className="divider" />
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '2rem' }}>
          {[
            { icon: '⬡', title: 'Real-Time Availability', desc: 'Rooms update instantly as bookings are made. No double-bookings, guaranteed.' },
            { icon: '◈', title: 'Five Star Chains', desc: 'From 1-star budget to 5-star luxury — Marriott, Hilton, Holiday Inn, and more.' },
            { icon: '◉', title: '14 Cities', desc: 'New York, Toronto, Montreal, Vancouver, Chicago, Miami, and 8 more destinations.' },
            { icon: '◻', title: 'Easy Check-in', desc: 'Employees can convert bookings to rentings in one click, or do walk-in rentals.' },
          ].map(f => (
            <div key={f.title} className="card-hover" style={{
              background: 'white',
              borderRadius: '4px',
              padding: '2rem',
              border: '1px solid #E8E4DF',
            }}>
              <div style={{ fontSize: '1.5rem', color: '#C9A84C', marginBottom: '1rem' }}>{f.icon}</div>
              <h3 style={{ fontFamily: 'Georgia, serif', fontSize: '1.05rem', marginBottom: '0.5rem', fontWeight: 'normal' }}>{f.title}</h3>
              <p style={{ color: '#8A8480', fontSize: '0.875rem', lineHeight: 1.7 }}>{f.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Hotel chains showcase */}
      <section style={{ background: '#F0EDE8', padding: '5rem 2rem' }}>
        <div style={{ maxWidth: '1100px', margin: '0 auto' }}>
          <div style={{ textAlign: 'center', marginBottom: '3rem' }}>
            <div style={{ fontSize: '0.65rem', letterSpacing: '0.25em', textTransform: 'uppercase', color: '#C9A84C', marginBottom: '0.75rem' }}>Our Partners</div>
            <h2 style={{ fontFamily: 'Georgia, serif', fontSize: '2rem', fontWeight: 'normal' }}>Five Distinguished Chains</h2>
            <div className="divider" />
          </div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '1rem', justifyContent: 'center' }}>
            {[
              { name: 'Marriott International', stars: 5, rooms: '5-star luxury' },
              { name: 'Hilton Hotels', stars: 4, rooms: '4-star premium' },
              { name: 'Holiday Inn (IHG)', stars: 3, rooms: '3-star comfort' },
              { name: 'Best Western', stars: 2, rooms: '2-star value' },
              { name: 'Motel 6', stars: 1, rooms: '1-star budget' },
            ].map(c => (
              <div key={c.name} style={{
                background: 'white',
                borderRadius: '4px',
                padding: '1.5rem 2rem',
                minWidth: '180px',
                textAlign: 'center',
                border: '1px solid #E8E4DF',
              }}>
                <div className="stars" style={{ fontSize: '1rem', marginBottom: '0.5rem' }}>
                  {'★'.repeat(c.stars)}{'☆'.repeat(5 - c.stars)}
                </div>
                <div style={{ fontFamily: 'Georgia, serif', fontSize: '0.9rem', color: '#1C1C1E', marginBottom: '0.25rem' }}>{c.name}</div>
                <div style={{ fontSize: '0.7rem', color: '#8A8480', letterSpacing: '0.05em' }}>{c.rooms}</div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
