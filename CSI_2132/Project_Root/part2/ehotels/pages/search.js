// pages/search.js
import { useState, useEffect, useCallback } from 'react'
import { useRouter } from 'next/router'
import BookingModal from '../components/BookingModal'
import RentingModal from '../components/RentingModal'

const AREAS = [
  '', 'New York', 'Toronto', 'Montreal', 'Chicago', 'Los Angeles',
  'Miami', 'Vancouver', 'Boston', 'Dallas', 'Seattle',
  'San Francisco', 'Ottawa', 'Las Vegas', 'Denver', 'New Orleans', 'Washington DC',
]
const CHAINS = ['', 'Marriott International', 'Hilton Hotels', 'Holiday Inn (IHG)', 'Best Western', 'Motel 6']

function Stars({ n }) {
  return <span className="stars">{'★'.repeat(n)}{'☆'.repeat(5 - n)}</span>
}

export default function Search({ user }) {
  const router = useRouter()

  // Filters
  const [area, setArea] = useState(router.query.area || '')
  const [checkin, setCheckin] = useState(router.query.checkin || '')
  const [checkout, setCheckout] = useState(router.query.checkout || '')
  const [capacity, setCapacity] = useState(router.query.capacity || '')
  const [chain, setChain] = useState('')
  const [stars, setStars] = useState('')
  const [maxPrice, setMaxPrice] = useState('')
  const [minRooms, setMinRooms] = useState('')

  // Results
  const [rooms, setRooms] = useState([])
  const [loading, setLoading] = useState(false)
  const [searched, setSearched] = useState(false)

  // Modal state
  const [bookingRoom, setBookingRoom] = useState(null)
  const [rentingRoom, setRentingRoom] = useState(null)

  const search = useCallback(async () => {
    setLoading(true)
    setSearched(true)
    const params = new URLSearchParams()
    if (area) params.set('area', area)
    if (checkin) params.set('checkin', checkin)
    if (checkout) params.set('checkout', checkout)
    if (capacity) params.set('capacity', capacity)
    if (chain) params.set('chain', chain)
    if (stars) params.set('stars', stars)
    if (maxPrice) params.set('maxPrice', maxPrice)
    if (minRooms) params.set('minRooms', minRooms)
    try {
      const res = await fetch(`/api/rooms/available?${params}`)
      const data = await res.json()
      setRooms(data.rooms || [])
    } catch {
      setRooms([])
    } finally {
      setLoading(false)
    }
  }, [area, checkin, checkout, capacity, chain, stars, maxPrice, minRooms])

  // Auto-search on filter change
  useEffect(() => {
    const t = setTimeout(search, 300)
    return () => clearTimeout(t)
  }, [search])

  return (
    <div style={{ display: 'flex', minHeight: '80vh' }}>
      {/* Sidebar filters */}
      <aside style={{
        width: '260px',
        flexShrink: 0,
        borderRight: '1px solid #E8E4DF',
        padding: '2rem 1.5rem',
        background: 'white',
        position: 'sticky',
        top: '73px',
        height: 'calc(100vh - 73px)',
        overflowY: 'auto',
      }}>
        <div style={{ fontSize: '0.65rem', letterSpacing: '0.2em', textTransform: 'uppercase', color: '#C9A84C', marginBottom: '1.5rem' }}>
          Filter Rooms
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
          <div className="field">
            <label>Area / City</label>
            <select value={area} onChange={e => setArea(e.target.value)}>
              {AREAS.map(a => <option key={a} value={a}>{a || 'Any area'}</option>)}
            </select>
          </div>

          <div className="field">
            <label>Check-in Date</label>
            <input type="date" value={checkin} onChange={e => setCheckin(e.target.value)} />
          </div>

          <div className="field">
            <label>Check-out Date</label>
            <input type="date" value={checkout} onChange={e => setCheckout(e.target.value)} />
          </div>

          <div className="field">
            <label>Room Capacity</label>
            <select value={capacity} onChange={e => setCapacity(e.target.value)}>
              <option value="">Any</option>
              <option value="single">Single</option>
              <option value="double">Double</option>
              <option value="triple">Triple</option>
              <option value="quad">Quad</option>
              <option value="suite">Suite</option>
            </select>
          </div>

          <div className="field">
            <label>Hotel Chain</label>
            <select value={chain} onChange={e => setChain(e.target.value)}>
              {CHAINS.map(c => <option key={c} value={c}>{c || 'Any chain'}</option>)}
            </select>
          </div>

          <div className="field">
            <label>Hotel Category (stars)</label>
            <select value={stars} onChange={e => setStars(e.target.value)}>
              <option value="">Any</option>
              {[5,4,3,2,1].map(s => <option key={s} value={s}>{s} ★</option>)}
            </select>
          </div>

          <div className="field">
            <label>Max Price ($/night)</label>
            <input type="number" placeholder="e.g. 300" value={maxPrice} onChange={e => setMaxPrice(e.target.value)} min="0" />
          </div>

          <div className="field">
            <label>Min Rooms in Hotel</label>
            <input type="number" placeholder="e.g. 5" value={minRooms} onChange={e => setMinRooms(e.target.value)} min="0" />
          </div>

          <button className="btn-gold" onClick={search} style={{ width: '100%' }}>
            Search
          </button>
        </div>
      </aside>

      {/* Results */}
      <main style={{ flex: 1, padding: '2rem' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: '1.5rem' }}>
          <div>
            <h1 style={{ fontFamily: 'Georgia, serif', fontSize: '1.5rem', fontWeight: 'normal', color: '#1C1C1E' }}>
              Available Rooms
            </h1>
            {searched && !loading && (
              <div style={{ fontSize: '0.75rem', color: '#8A8480', marginTop: '0.25rem' }}>
                {rooms.length} room{rooms.length !== 1 ? 's' : ''} found
              </div>
            )}
          </div>
        </div>

        {loading && (
          <div style={{ textAlign: 'center', padding: '4rem', color: '#8A8480' }}>
            <div style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>⏳</div>
            Searching available rooms...
          </div>
        )}

        {!loading && searched && rooms.length === 0 && (
          <div style={{ textAlign: 'center', padding: '4rem', color: '#8A8480' }}>
            <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>◻</div>
            No rooms match your criteria. Try adjusting the filters.
          </div>
        )}

        {!loading && !searched && (
          <div style={{ textAlign: 'center', padding: '4rem', color: '#8A8480' }}>
            <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>◈</div>
            Set your dates and preferences to find available rooms.
          </div>
        )}

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '1.25rem' }}>
          {rooms.map(room => (
            <div key={room.room_id} className="card-hover fade-up" style={{
              background: 'white',
              borderRadius: '4px',
              border: '1px solid #E8E4DF',
              overflow: 'hidden',
            }}>
              {/* Room header */}
              <div style={{ background: '#1C1C1E', padding: '1rem 1.25rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <div style={{ color: '#C9A84C', fontSize: '0.65rem', letterSpacing: '0.15em', textTransform: 'uppercase' }}>
                    Room #{room.room_id}
                  </div>
                  <div style={{ color: 'white', fontFamily: 'Georgia, serif', fontSize: '1.1rem', textTransform: 'capitalize' }}>
                    {room.capacity} Room
                  </div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div style={{ color: '#C9A84C', fontFamily: 'Georgia, serif', fontSize: '1.4rem' }}>
                    ${Number(room.price).toFixed(0)}
                  </div>
                  <div style={{ color: '#555', fontSize: '0.65rem', letterSpacing: '0.1em' }}>PER NIGHT</div>
                </div>
              </div>

              {/* Room details */}
              <div style={{ padding: '1rem 1.25rem' }}>
                <div style={{ marginBottom: '0.5rem' }}>
                  <Stars n={room.category} />
                  <span style={{ fontSize: '0.75rem', color: '#8A8480', marginLeft: '0.5rem' }}>{room.chain_name}</span>
                </div>

                <div style={{ fontSize: '0.8rem', color: '#555', marginBottom: '0.25rem' }}>
                  📍 {room.area} — {room.hotel_address?.split(',').slice(0,2).join(',')}
                </div>

                <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap', margin: '0.75rem 0' }}>
                  {room.view_type !== 'none' && (
                    <span className="badge badge-gold">{room.view_type} view</span>
                  )}
                  {room.extendable && (
                    <span className="badge badge-green">Extendable</span>
                  )}
                  {room.amenities?.slice(0,3).map(a => (
                    <span key={a} className="badge badge-gray">{a}</span>
                  ))}
                </div>

                <div style={{ display: 'flex', gap: '0.5rem', marginTop: '1rem' }}>
                  {user?.role === 'customer' && (
                    <button
                      className="btn-gold"
                      style={{ flex: 1, fontSize: '0.8rem' }}
                      onClick={() => setBookingRoom(room)}
                    >
                      Book Room
                    </button>
                  )}
                  {user?.role === 'employee' && (
                    <>
                      <button
                        className="btn-gold"
                        style={{ flex: 1, fontSize: '0.8rem' }}
                        onClick={() => setRentingRoom(room)}
                      >
                        Walk-in Rent
                      </button>
                    </>
                  )}
                  {!user && (
                    <a href="/login?role=customer" style={{ flex: 1 }}>
                      <button className="btn-outline" style={{ width: '100%', fontSize: '0.8rem' }}>
                        Login to Book
                      </button>
                    </a>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </main>

      {/* Booking modal */}
      {bookingRoom && (
        <BookingModal
          room={bookingRoom}
          user={user}
          checkin={checkin}
          checkout={checkout}
          onClose={() => setBookingRoom(null)}
          onSuccess={() => { setBookingRoom(null); search() }}
        />
      )}

      {/* Walk-in renting modal */}
      {rentingRoom && (
        <RentingModal
          room={rentingRoom}
          user={user}
          checkin={checkin}
          checkout={checkout}
          bookingId={null}
          onClose={() => setRentingRoom(null)}
          onSuccess={() => { setRentingRoom(null); search() }}
        />
      )}
    </div>
  )
}
