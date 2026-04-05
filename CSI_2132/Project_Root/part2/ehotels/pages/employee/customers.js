// pages/employee/customers.js
import { useEffect, useState } from 'react'

const EMPTY = { full_name: '', address: '', id_type: 'SIN', id_value: '', registration_date: '' }

export default function EmployeeCustomers({ user }) {
  const [customers, setCustomers] = useState([])
  const [loading, setLoading] = useState(true)
  const [editing, setEditing] = useState(null)   // null | 'new' | customer object
  const [form, setForm] = useState(EMPTY)
  const [error, setError] = useState('')

  async function load() {
    setLoading(true)
    try {
      const res = await fetch('/api/customers')
      const data = await res.json()
      setCustomers(data.customers || [])
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { load() }, [])

  function startNew() { setEditing('new'); setForm(EMPTY); setError('') }
  function startEdit(c) { setEditing(c); setForm({ ...c }); setError('') }

  async function handleSave() {
    setError('')
    try {
      const isNew = editing === 'new'
      const url = isNew ? '/api/customers' : `/api/customers/${editing.customer_id}`
      const res = await fetch(url, {
        method: isNew ? 'POST' : 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Failed')
      setEditing(null)
      load()
    } catch (err) {
      setError(err.message)
    }
  }

  async function handleDelete(id) {
    if (!confirm('Delete this customer?')) return
    await fetch(`/api/customers/${id}`, { method: 'DELETE' })
    load()
  }

  if (!user || user.role !== 'employee') {
    return <div style={{ textAlign: 'center', padding: '4rem', color: '#8A8480' }}>Staff access only.</div>
  }

  return (
    <div style={{ maxWidth: '1100px', margin: '0 auto', padding: '2.5rem 2rem' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '2rem' }}>
        <div>
          <div style={{ fontSize: '0.65rem', letterSpacing: '0.2em', textTransform: 'uppercase', color: '#C9A84C' }}>Employee Portal</div>
          <h1 style={{ fontFamily: 'Georgia, serif', fontSize: '2rem', fontWeight: 'normal', marginTop: '0.25rem' }}>Customer Management</h1>
        </div>
        <button className="btn-gold" onClick={startNew}>+ New Customer</button>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '3rem', color: '#8A8480' }}>Loading...</div>
      ) : (
        <div style={{ background: 'white', borderRadius: '4px', border: '1px solid #E8E4DF', overflow: 'hidden' }}>
          <table className="elegant-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Address</th>
                <th>ID Type</th>
                <th>ID Value</th>
                <th>Registered</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {customers.map(c => (
                <tr key={c.customer_id}>
                  <td style={{ fontFamily: 'Georgia, serif' }}>#{c.customer_id}</td>
                  <td style={{ fontSize: '0.875rem' }}>{c.full_name}</td>
                  <td style={{ fontSize: '0.8rem', color: '#555' }}>{c.address}</td>
                  <td><span className="badge badge-gray">{c.id_type}</span></td>
                  <td style={{ fontSize: '0.8rem' }}>{c.id_value}</td>
                  <td style={{ fontSize: '0.8rem', color: '#8A8480' }}>{c.registration_date?.slice(0,10)}</td>
                  <td>
                    <div style={{ display: 'flex', gap: '0.5rem' }}>
                      <button className="btn-outline" style={{ fontSize: '0.75rem', padding: '0.3rem 0.7rem' }} onClick={() => startEdit(c)}>Edit</button>
                      <button
                        className="btn-outline"
                        style={{ fontSize: '0.75rem', padding: '0.3rem 0.7rem', borderColor: '#8B1A1A', color: '#8B1A1A' }}
                        onClick={() => handleDelete(c.customer_id)}
                      >Delete</button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Edit/Create modal */}
      {editing !== null && (
        <div className="modal-overlay" onClick={() => setEditing(null)}>
          <div className="modal-box" onClick={e => e.stopPropagation()}>
            <div style={{ marginBottom: '1.5rem' }}>
              <div style={{ fontSize: '0.65rem', letterSpacing: '0.2em', textTransform: 'uppercase', color: '#C9A84C' }}>
                {editing === 'new' ? 'New Customer' : 'Edit Customer'}
              </div>
              <h2 style={{ fontFamily: 'Georgia, serif', fontSize: '1.4rem', fontWeight: 'normal', marginTop: '0.25rem' }}>
                {editing === 'new' ? 'Register a New Customer' : `Customer #${editing.customer_id}`}
              </h2>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              <div className="field">
                <label>Full Name</label>
                <input value={form.full_name} onChange={e => setForm({...form, full_name: e.target.value})} placeholder="Full name" />
              </div>
              <div className="field">
                <label>Address</label>
                <input value={form.address} onChange={e => setForm({...form, address: e.target.value})} placeholder="Street, City, Province" />
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: '1rem' }}>
                <div className="field">
                  <label>ID Type</label>
                  <select value={form.id_type} onChange={e => setForm({...form, id_type: e.target.value})}>
                    <option value="SIN">SIN</option>
                    <option value="SSN">SSN</option>
                    <option value="DRIVER_LICENSE">Driver's License</option>
                  </select>
                </div>
                <div className="field">
                  <label>ID Value</label>
                  <input value={form.id_value} onChange={e => setForm({...form, id_value: e.target.value})} placeholder="e.g. 123-456-789" />
                </div>
              </div>
              <div className="field">
                <label>Registration Date</label>
                <input type="date" value={form.registration_date?.slice(0,10) || ''} onChange={e => setForm({...form, registration_date: e.target.value})} />
              </div>

              {error && <div className="badge badge-red" style={{ padding: '0.6rem', fontSize: '0.8rem', display: 'block' }}>{error}</div>}

              <div style={{ display: 'flex', gap: '0.75rem', marginTop: '0.5rem' }}>
                <button className="btn-outline" onClick={() => setEditing(null)} style={{ flex: 1 }}>Cancel</button>
                <button className="btn-gold" onClick={handleSave} style={{ flex: 1 }}>
                  {editing === 'new' ? 'Create Customer' : 'Save Changes'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
