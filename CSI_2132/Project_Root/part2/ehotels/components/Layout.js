// components/Layout.js
import Link from 'next/link'
import { useRouter } from 'next/router'

export default function Layout({ children, user, setUser }) {
  const router = useRouter()

  function handleLogout() {
    setUser(null)
    router.push('/')
  }

  return (
    <div className="min-h-screen flex flex-col" style={{ background: '#FAF7F2' }}>
      {/* Top banner */}
      <div style={{ background: '#1C1C1E', color: '#C9A84C', padding: '6px 0', textAlign: 'center' }}>
        <span style={{ fontSize: '0.65rem', letterSpacing: '0.2em', textTransform: 'uppercase' }}>
          Luxury Hotel Reservations — North America's Finest Properties
        </span>
      </div>

      {/* Main header */}
      <header style={{
        background: 'white',
        borderBottom: '1px solid #E8E4DF',
        padding: '1.25rem 2rem',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        position: 'sticky',
        top: 0,
        zIndex: 40,
        boxShadow: '0 2px 20px rgba(0,0,0,0.06)',
      }}>
        {/* Logo */}
        <Link href="/" style={{ textDecoration: 'none' }}>
          <div>
            <div style={{ fontFamily: 'Georgia, serif', fontSize: '1.4rem', color: '#1C1C1E', letterSpacing: '0.04em', fontWeight: 'normal' }}>
              e<span style={{ color: '#C9A84C' }}>Hotels</span>
            </div>
            <div style={{ fontSize: '0.58rem', letterSpacing: '0.2em', textTransform: 'uppercase', color: '#8A8480', marginTop: '-2px' }}>
              Five Chains · Fourteen Cities
            </div>
          </div>
        </Link>

        {/* Nav links */}
        <nav style={{ display: 'flex', gap: '2rem', alignItems: 'center' }}>
          <Link href="/search" className={`nav-link ${router.pathname === '/search' ? 'active' : ''}`}>
            Find Rooms
          </Link>

          {user?.role === 'employee' && (
            <>
              <Link href="/employee/bookings" className={`nav-link ${router.pathname.startsWith('/employee/bookings') ? 'active' : ''}`}>
                Bookings
              </Link>
              <Link href="/employee/rentings" className={`nav-link ${router.pathname.startsWith('/employee/rentings') ? 'active' : ''}`}>
                Rentings
              </Link>
              <Link href="/employee/customers" className={`nav-link ${router.pathname.startsWith('/employee/customers') ? 'active' : ''}`}>
                Customers
              </Link>
            </>
          )}

          {user?.role === 'customer' && (
            <Link href="/customer/bookings" className={`nav-link ${router.pathname.startsWith('/customer') ? 'active' : ''}`}>
              My Bookings
            </Link>
          )}

          <Link href="/views" className={`nav-link ${router.pathname === '/views' ? 'active' : ''}`}>
            Analytics
          </Link>
        </nav>

        {/* Auth area */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
          {user ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: '0.8rem', color: '#1C1C1E', fontFamily: 'Georgia, serif' }}>{user.name}</div>
                <div style={{ fontSize: '0.6rem', letterSpacing: '0.1em', textTransform: 'uppercase', color: '#C9A84C' }}>{user.role}</div>
              </div>
              <button className="btn-outline" onClick={handleLogout}>Sign Out</button>
            </div>
          ) : (
            <div style={{ display: 'flex', gap: '0.75rem' }}>
              <Link href="/login?role=customer"><button className="btn-outline">Guest Login</button></Link>
              <Link href="/login?role=employee"><button className="btn-gold">Staff Login</button></Link>
            </div>
          )}
        </div>
      </header>

      {/* Page content */}
      <main style={{ flex: 1 }}>
        {children}
      </main>

      {/* Footer */}
      <footer style={{
        background: '#1C1C1E',
        color: '#8A8480',
        padding: '2.5rem 2rem',
        textAlign: 'center',
        marginTop: 'auto',
      }}>
        <div style={{ color: '#C9A84C', fontFamily: 'Georgia, serif', fontSize: '1.1rem', marginBottom: '0.5rem' }}>eHotels</div>
        <div style={{ fontSize: '0.68rem', letterSpacing: '0.15em', textTransform: 'uppercase' }}>
          CSI2132 Databases I · University of Ottawa · 2026
        </div>
        <div style={{ marginTop: '1rem', fontSize: '0.72rem', color: '#555' }}>
          Marriott · Hilton · Holiday Inn · Best Western · Motel 6
        </div>
      </footer>
    </div>
  )
}
