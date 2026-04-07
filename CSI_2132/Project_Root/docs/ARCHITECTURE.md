## Architecture (e‑Hotels – CSI2132 Project)

This document explains how the **database**, **API**, and **web UI** in this project fit together.  
Implementation lives under `part2/ehotels/`.

---

## 1. High-Level Overview

The system is a classic 3‑layer setup:

- **Database layer** (PostgreSQL-style SQL)
  - Schema + constraints: `part2/ehotels/schema.sql`
  - Data: `part2/ehotels/populate.sql`
  - Views: `part2/ehotels/views.sql`
  - Triggers/modifications: `part2/ehotels/triggers.sql`
  - Indexes: `part2/ehotels/indexes.sql`

- **API layer** (Next.js API Routes)
  - HTTP endpoints implemented in `part2/ehotels/pages/api/**`
  - Each endpoint connects to the database and returns JSON.

- **UI layer** (Next.js Pages + React)
  - User-facing pages in `part2/ehotels/pages/**`
  - These pages call the API endpoints via `fetch()` and render forms/tables/cards.

---

## 2. Folder Layout (Part 2)

The main deliverable is located at `part2/ehotels/`.

Key areas:

- `pages/`
  - `index.js` – customer search form
  - `search.js` – room results + filters + booking/renting modals
  - `views.js` – analytics dashboard for SQL views (requirement 2f)
  - `login.js` – employee login
  - `customer/bookings.js` – customer booking list
  - `employee/*.js` – employee dashboards (customers, bookings, rentings)

- `pages/api/`
  - `rooms/available.js` – room availability search (core requirement 2g)
  - `bookings/*` – booking creation / updates / deletion
  - `rentings/*` – renting creation and operations
  - `customers/*` – customer CRUD
  - `employees/[id].js` – employee lookup (login support)
  - `hotels/index.js` – hotel list for dropdowns and view filtering
  - `views/*` – endpoints that expose SQL view results to the UI

---

## 3. Request/Response Data Flow

### 3.1 Customer Room Search

**Goal**: allow customers to see available rooms given a combination of criteria (dates, capacity, area, chain, hotel category, number of rooms, price), and update results when criteria change.

- **UI**:
  - `pages/index.js` collects the initial criteria and navigates to `/search`.
  - `pages/search.js` renders results, filters, and booking/renting actions.

- **API**:
  - `GET /api/rooms/available` (implemented in `pages/api/rooms/available.js`)
  - The endpoint translates the query parameters into an SQL query that filters rooms by:
    - date range overlap rules,
    - room capacity,
    - area,
    - chain and category (stars),
    - hotel size,
    - price constraints,
    - and “no problems/damages”.

- **Database**:
  - Reads from `ROOM`, `HOTEL`, `HOTEL_CHAIN` and checks conflicts in `BOOKING` and `RENTING`.
  - Overlap logic is also enforced at write-time by trigger(s) for bookings (see `triggers.sql`).

### 3.2 Booking Flow

**Goal**: create a booking for a customer and a room within a date range.

- **UI**:
  - Triggered from `/search` (booking modal).
  - The customer provides identity/customer info (depending on UI) and confirms.

- **API**:
  - `POST /api/bookings` and/or updates through `pages/api/bookings/index.js` and `pages/api/bookings/[id].js`.

- **Database**:
  - Inserts into `BOOKING`.
  - Trigger `trg_no_double_booking` (from `triggers.sql`) prevents overlapping bookings for the same room and also checks conflicts with `RENTING`.

### 3.3 Renting Flow (Check-in and Walk-in)

**Goal**: support both:

- **booking → renting** (customer checks in; employee converts booking), and
- **walk-in renting** (no prior booking; employee creates renting directly).

- **UI**:
  - Employee pages: `pages/employee/bookings.js` and `pages/employee/rentings.js`.
  - Renting actions can also be triggered from search (depending on UI).

- **API**:
  - `POST /api/rentings` (implemented in `pages/api/rentings/index.js`)

- **Database**:
  - Inserts into `RENTING` with:
    - `booking_id` set for check-in conversion, or `NULL` for walk-ins.
  - `RENTING.booking_id` is `UNIQUE`, enforcing a one-to-one conversion.

### 3.4 Analytics / SQL Views (Requirement 2f)

The UI exposes the two required views via `pages/views.js`.

- **View 1 – Available rooms per area**
  - SQL: `view_available_rooms_per_area` in `part2/ehotels/views.sql`
  - API: `GET /api/views/available-per-area` (`pages/api/views/available-per-area.js`)
  - UI: `pages/views.js` section “View 1: Available Rooms per Area”

- **View 2 – Hotel room capacity**
  - SQL: `view_hotel_room_capacity` in `part2/ehotels/views.sql`
  - API: `GET /api/views/hotel-capacity?hotel_id=...` (`pages/api/views/hotel-capacity.js`)
  - UI: `pages/views.js` section “View 2: Hotel Room Capacity”

- **Bonus view – Chain summary**
  - SQL: `view_chain_summary`
  - API: `GET /api/views/chain-summary`
  - UI: `pages/views.js` section “View 4: Chain Summary”

---

## 4. Security / Assumptions (Course Project Context)

This project is designed as a course deliverable and assumes:

- A trusted local environment (developer machine / TA machine).
- Authentication/authorization is minimal and primarily used to distinguish the customer vs employee UI flows.

---

## 5. What to Demo (TA Quick Checklist)

Suggested demo order (matches the required video structure):

- Start DB: run schema + populate, show key relations and constraints.
- Run the web app.
- Customer: `/` → `/search` with live filtering; create a booking.
- Employee: `/login` → manage customers; convert booking → renting; create walk-in renting.
- `/views`: show View 1 and View 2 results coming from SQL views.

