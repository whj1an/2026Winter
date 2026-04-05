# eHotels — CSI2132 Project (2nd Deliverable)

## Technologies Used
- **Database**: PostgreSQL 15+
- **Backend**: Next.js 14 API Routes (Node.js)
- **Frontend**: Next.js 14 (React 18) + Tailwind CSS
- **DB Driver**: `pg` (node-postgres)

---

## Installation Steps

### 1. Prerequisites
- Node.js 18+ installed
- PostgreSQL 15+ running locally
- `npm` available

### 2. Create the database
```bash
psql -U postgres
CREATE DATABASE ehotels;
\q
```

### 3. Run the SQL scripts in order
```bash
psql -U postgres -d ehotels -f schema.sql
psql -U postgres -d ehotels -f triggers.sql
psql -U postgres -d ehotels -f views.sql
psql -U postgres -d ehotels -f indexes.sql
psql -U postgres -d ehotels -f populate.sql
psql -U postgres -d ehotels -f queries.sql   # optional: run sample queries
```

### 4. Configure the web app
```bash
cd ehotels-webapp
cp .env.local.example .env.local
# Edit .env.local and set your PostgreSQL credentials:
# DATABASE_URL=postgresql://postgres:yourpassword@localhost:5432/ehotels
```

### 5. Install dependencies and start
```bash
npm install
npm run dev
```

The app runs at **http://localhost:3000**

---

## Application Structure

```
ehotels/
├── pages/
│   ├── index.js              # Homepage with hero search
│   ├── search.js             # Room search (customer view)
│   ├── login.js              # Login for customer or employee
│   ├── views.js              # Analytics: SQL View 1 & 2
│   ├── customer/
│   │   └── bookings.js       # Customer: my bookings
│   ├── employee/
│   │   ├── bookings.js       # Employee: all bookings + check-in
│   │   ├── rentings.js       # Employee: active rentings + payment
│   │   └── customers.js      # Employee: customer CRUD
│   └── api/
│       ├── rooms/available.js
│       ├── bookings/index.js
│       ├── bookings/[id].js
│       ├── rentings/index.js
│       ├── customers/index.js
│       ├── customers/[id].js
│       ├── employees/[id].js
│       ├── hotels/index.js
│       └── views/
│           ├── available-per-area.js
│           ├── hotel-capacity.js
│           └── chain-summary.js
├── components/
│   ├── Layout.js             # Header, nav, footer
│   ├── BookingModal.js       # Customer booking form
│   └── RentingModal.js       # Employee check-in / walk-in form
├── lib/
│   └── db.js                 # PostgreSQL connection pool
└── styles/
    └── globals.css           # Global styles + design system
```

---

## Key Features

### Customer View
- Search available rooms by: area, dates, capacity, chain, stars, price, # of rooms
- Filters update results in real time (300ms debounce)
- Book a room via modal form
- View and cancel upcoming bookings

### Employee View
- See all active bookings
- **Convert booking → renting** (check-in) with one click
- Create **walk-in rentings** directly from room search
- Record guest payments
- Full customer CRUD (create, read, update, delete)

### Analytics (Views)
- **View 1**: Available rooms per area (live, uses `view_available_rooms_per_area`)
- **View 2**: Room capacity breakdown per hotel (uses `view_hotel_room_capacity`)
- **View 4**: Chain summary statistics (uses `view_chain_summary`)

---

## SQL Files Summary

| File          | Purpose                                 |
|---------------|-----------------------------------------|
| schema.sql    | CREATE TABLE statements (2a)            |
| populate.sql  | INSERT data — 5 chains, 40 hotels (2b)  |
| queries.sql   | 4+ SELECT queries (2c)                  |
| triggers.sql  | 5 triggers + sample DML (2d)            |
| indexes.sql   | 5 indexes with justification (2e)       |
| views.sql     | 4 views including required View 1&2 (2f)|
