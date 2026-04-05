// pages/login.js
import { useState } from 'react'
import { useRouter } from 'next/router'

export default function Login({ setUser }) {
  const router = useRouter()
  const { role } = router.query   // 'customer' or 'employee'

  const [id, setId] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const isEmployee = role === 'employee'

  async function handleLogin(e) {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const endpoint = isEmployee ? `/api/employees/${id}` : `/api/customers/${id}`
      const res = await fetch(endpoint)
      if (!res.ok) throw new Error('Not found')
      const data = await res.json()
      setUser({
        role: isEmployee ? 'employee' : 'customer',
        id: data.employee_id || data.customer_id,
        name: data.full_name,
        hotelId: data.hotel_id || null,
      })
      router.push(isEmployee ? '/employee/bookings' : '/customer/bookings')
    } catch {
      setError(`No ${isEmployee ? 'employee' : 'customer'} found with that ID.`)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{ minHeight: '80vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '2rem' }}>
      <div style={{ width: '100%', maxWidth: '420px' }}>
        {/* Header */}
        <div style={{ textAlign: 'center', marginBottom: '2.5rem' }}>
          <div style={{ fontSize: '0.65rem', letterSpacing: '0.25em', textTransform: 'uppercase', color: '#C9A84C', marginBottom: '0.75rem' }}>
            {isEmployee ? 'Staff Access' : 'Guest Access'}
          </div>
          <h1 style={{ fontFamily: 'Georgia, serif', fontSize: '1.75rem', fontWeight: 'normal', color: '#1C1C1E' }}>
            {isEmployee ? 'Employee Login' : 'Customer Login'}
          </h1>
          <div className="divider" />
          <p style={{ color: '#8A8480', fontSize: '0.875rem', marginTop: '1rem', lineHeight: 1.6 }}>
            {isEmployee
              ? 'Enter your Employee ID to access check-in and management features.'
              : 'Enter your Customer ID to view and manage your bookings.'}
          </p>
        </div>

        {/* Login card */}
        <div style={{
          background: 'white',
          borderRadius: '4px',
          padding: '2rem',
          border: '1px solid #E8E4DF',
          boxShadow: '0 4px 30px rgba(0,0,0,0.08)',
        }}>
          <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
            <div className="field">
              <label>{isEmployee ? 'Employee ID' : 'Customer ID'}</label>
              <input
                type="number"
                value={id}
                onChange={e => setId(e.target.value)}
                placeholder={isEmployee ? 'e.g. 1' : 'e.g. 1'}
                required
                min="1"
              />
            </div>

            {error && (
              <div style={{ background: '#FFEBEE', color: '#8B1A1A', fontSize: '0.8rem', padding: '0.6rem 0.75rem', borderRadius: '2px' }}>
                {error}
              </div>
            )}

            <button className="btn-gold" type="submit" disabled={loading} style={{ width: '100%', padding: '0.75rem' }}>
              {loading ? 'Signing in...' : 'Sign In'}
            </button>
          </form>

          <div style={{ marginTop: '1.5rem', paddingTop: '1.5rem', borderTop: '1px solid #F0EDE8', textAlign: 'center' }}>
            <span style={{ fontSize: '0.8rem', color: '#8A8480' }}>
              {isEmployee ? 'Not an employee?' : 'Are you staff?'}{' '}
            </span>
            <a
              href={isEmployee ? '/login?role=customer' : '/login?role=employee'}
              style={{ fontSize: '0.8rem', color: '#C9A84C', textDecoration: 'none' }}
            >
              {isEmployee ? 'Guest login →' : 'Staff login →'}
            </a>
          </div>
        </div>

        {/* Demo hint */}
        <div style={{ marginTop: '1rem', textAlign: 'center', fontSize: '0.72rem', color: '#8A8480' }}>
          Demo: {isEmployee ? 'Employee IDs 1–45' : 'Customer IDs 1–10'}
        </div>
      </div>
    </div>
  )
}
