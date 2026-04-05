import '../styles/globals.css'
import { useState } from 'react'
import Layout from '../components/Layout'

export default function App({ Component, pageProps }) {
  // Global user session: { role: 'customer'|'employee', id, name }
  const [user, setUser] = useState(null)

  return (
    <Layout user={user} setUser={setUser}>
      <Component {...pageProps} user={user} setUser={setUser} />
    </Layout>
  )
}
