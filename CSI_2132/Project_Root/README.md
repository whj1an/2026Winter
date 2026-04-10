## e‑Hotels Web Application (CSI2132 Project – 2nd Deliverable)

This repository contains the implementation of the **e‑Hotels** project for the course **CSI2132 – Databases I (Winter 2025‑26)**.  
It combines a relational database (PostgreSQL‑style SQL) with a modern web application (Next.js + React) to allow customers and hotel employees to **search, book, rent, and analyse hotel rooms across multiple hotel chains**.

The project is organised to satisfy the requirements of the **2nd deliverable** in the course project description (`courseproject2026.pdf`): database implementation (DDL, data population, queries, triggers, indexes, views) and a fully working web user interface.

---

## 0. Repository Layout

- `part2/ehotels/` – **Main deliverable (database + web application)**  
  Contains the full SQL implementation (`schema.sql`, `populate.sql`, `queries.sql`, `triggers.sql`, `indexes.sql`, `views.sql`) and the Next.js application (`pages/`, `pages/api/`, etc.).

- `part1/` (if present) – **First deliverable artifacts**  
  Typically contains the ER design / report material submitted for Deliverable 1.

If you are a TA/grader, start from `part2/ehotels/`:

- Run the SQL scripts to create and populate the database (see [Section 5](#5-installation-and-setup-local-development)).
- Start the web app from `part2/ehotels` and verify the flows in [Section 4](#4-application-pages-and-flows).

---

## 1. Features Overview

- **Customer features**
  - Search for **available rooms** using multiple criteria: date range, room capacity, area (city), hotel chain, hotel category (stars), number of rooms in the hotel, and price range.
  - View rich details of matching rooms (capacity, price, view type, chain, hotel, area, etc.).
  - Create **bookings** for selected rooms.

- **Employee features**
  - Log in as a hotel employee to access management pages.
  - Manage **customers, bookings, and rentings** through web forms (insert / update / delete).
  - Convert a **booking into a renting** when a customer checks in.
  - Create a **direct renting** (walk‑in) for customers without a prior booking.
  - Record **payments** for a renting.

- **Analytics & views (SQL Views – requirement 2f)**
  - View 1 – **Available rooms per area**: shows, for each area, how many rooms are currently available plus min / max / average price.
  - View 2 – **Hotel room capacity**: for a selected hotel, shows how many rooms exist per capacity (single, double, etc.) and the average price for each type.
  - View 4 (bonus) – **Chain summary**: for each hotel chain, shows total hotels, areas covered, total rooms, and price statistics.

---

## 2. Technology Stack

- **Database**
  - PostgreSQL‑style SQL (the scripts use `SERIAL`, `BOOLEAN`, `CURRENT_DATE`, etc., which are PostgreSQL‑compatible).
  - All database logic is defined in the SQL files under `part2/ehotels` (see [Section 3](#3-database-structure)).

- **Backend / API**
  - **Node.js** runtime.
  - **Next.js** API routes under `part2/ehotels/pages/api`:
    - `/api/rooms/available` – search for available rooms given filter criteria.
    - `/api/hotels` – fetch list of hotels for dropdowns and views.
    - `/api/views/available-per-area`, `/api/views/hotel-capacity`, `/api/views/chain-summary` – serve data from SQL views.
    - `/api/customers`, `/api/bookings`, `/api/rentings`, `/api/employees` – CRUD‑style endpoints to manage core entities.

- **Frontend**
  - **Next.js + React** with classic `pages/` routing under `part2/ehotels`.
  - Key pages:
    - `pages/index.js` – home page with search form (criteria from requirement 2g).
    - `pages/search.js` – search results and filters + booking / renting modals.
    - `pages/views.js` – analytics dashboard that visualises SQL views.
    - `pages/login.js` – login page for employees.
    - `pages/employee/customers.js`, `pages/employee/bookings.js`, `pages/employee/rentings.js` – management UIs for staff.
  - Styling uses a mix of custom CSS and utility classes (Tailwind‑style configuration is provided in `tailwind.config.js`).

---

## 3. Database Structure

All core SQL files are located in `part2/ehotels`:

- `schema.sql` – defines the **relational schema** for the e‑Hotels domain:
  - `HOTEL_CHAIN`, `HOTEL`, `ROOM` (+ amenities and damage flags).
  - `CUSTOMER`, `EMPLOYEE`, `ROLE`, `EMPLOYEE_ROLE`, `HOTEL_MANAGER`.
  - `BOOKING`, `RENTING` and their archive tables `BOOKING_ARCHIVE`, `RENTING_ARCHIVE`.
  - Primary keys, foreign keys, domain constraints, and user‑defined constraints implement the business rules described in the project statement (e.g., every hotel belongs to one chain, every room belongs to one hotel, each hotel has exactly one manager, etc.).

- `populate.sql` – **data population script**:
  - Inserts data for 5 hotel chains, each with multiple hotels across at least three categories and multiple areas.
  - Populates enough rooms of different capacities per hotel to demonstrate queries, triggers, and views.

- `queries.sql` – sample **SQL queries (requirement 2c)**:
  - At least four queries, including:
    - Queries with **aggregation** (e.g., counts, averages).
    - Queries with **nested subqueries**.

- `triggers.sql` – database **triggers and modification logic (requirement 2d)**:
  - Implements business rules for insert / update / delete operations (e.g., maintaining archives of bookings / rentings, enforcing constraints such as one manager per hotel, or keeping summary attributes consistent).

- `indexes.sql` – **indexes (requirement 2e)**:
  - At least three indexes on frequently queried attributes (e.g., by area, by date range, by chain / hotel).
  - Each index is chosen to speed up typical queries in the web application (searching available rooms, filtering by area / chain / category, etc.).

- `views.sql` – **SQL views (requirement 2f)**:
  - `view_available_rooms_per_area` – View 1: number of currently available rooms per area with price statistics.
  - `view_hotel_room_capacity` – View 2: aggregated capacity and average price per room type for each hotel.
  - `view_active_bookings` – View 3 (bonus): all active bookings with details (useful for the employee UI and for “upcoming bookings” views).
  - `view_chain_summary` – View 4 (bonus): per‑chain statistics (hotels, areas, rooms, prices).

---

## 4. Application Pages and Flows

### 4.1 Customer flow

1. **Search for rooms**  
   - The customer visits `/` (served by `part2/ehotels/pages/index.js`) and fills in:
     - Check‑in and check‑out dates.
     - Room capacity.
     - Area (city).
     - Hotel chain.
     - Hotel category (stars).
     - Minimum total number of rooms in the hotel.
     - Maximum price per night.
   - The app sends a request to `/api/rooms/available`, which queries the database for rooms that:
     - Have no recorded problems or damages.
     - Are not part of any booking or renting overlapping the selected date range.

2. **View results and filter further**  
   - `/search` (served by `part2/ehotels/pages/search.js`) displays matching rooms as cards, with side filters that can be changed interactively.
   - Changing any criterion triggers a new call to `/api/rooms/available`, updating the list of available options.

3. **Book a room**  
   - From the search results, the customer can open a **booking modal** and confirm a booking for the selected room and dates.

### 4.2 Employee flow

1. **Login**  
   - The employee accesses `/login` (served by `part2/ehotels/pages/login.js`) and logs in using an employee identifier (served by `/api/employees/[id]`).

2. **Manage entities**  
   - `pages/employee/customers.js` + `/api/customers/*` allow creating, updating, and deleting customers.
   - `pages/employee/bookings.js` + `/api/bookings/*` allow employees to review, update, or cancel bookings.
   - `pages/employee/rentings.js` + `/api/rentings/*` allow employees to:
     - Convert an existing booking into a renting during check‑in.
     - Create a direct renting for walk‑in customers without a prior booking.
     - Record payments associated with a renting.

3. **Archives and history**  
   - Through the triggers in `triggers.sql`, bookings and rentings can be archived into `BOOKING_ARCHIVE` and `RENTING_ARCHIVE` so that historical data is preserved even if the original room or customer record is removed, as required by the project description.

### 4.3 Analytics and SQL views UI

- The `/views` route (served by `part2/ehotels/pages/views.js`) is an **“Analytics Dashboard”** driven by the SQL views defined in `views.sql`:
  - **View 1 – Available rooms per area**  
    - Frontend: `pages/views.js` (first section).  
    - Backend: `/api/views/available-per-area` → `view_available_rooms_per_area`.  
    - Shows for each area: available rooms, min/max/avg price, and a small visual bar for relative availability.

  - **View 2 – Hotel room capacity**  
    - Frontend: `pages/views.js` (second section with the hotel dropdown).  
    - Backend: `/api/views/hotel-capacity?hotel_id=...` → `view_hotel_room_capacity`.  
    - After selecting a hotel, shows how many rooms exist by capacity and their average price.

  - **View 4 – Chain summary (bonus)**  
    - Frontend: `pages/views.js` (third section).  
    - Backend: `/api/views/chain-summary` → `view_chain_summary`.  
    - Displays per‑chain statistics: stars, number of hotels, areas covered, total rooms, and price range.

---

## 5. Installation and Setup (Local Development)

> **Note:** The exact commands may vary slightly depending on your environment (PostgreSQL version, Node.js version, etc.). The steps below describe a typical setup.

### 5.1 Prerequisites

- **Database**: PostgreSQL (or a compatible system) installed and running.
- **Node.js**: LTS version (e.g., Node 18+).
- **npm**: comes with Node.js.

### 5.2 Database creation

1. Create a new PostgreSQL database, e.g.:

   ```sql
   CREATE DATABASE ehotels;
   ```

2. Connect to the new database and run the SQL scripts in the following order (from `part2/ehotels`):

   ```sql
   \c ehotels;
   \i schema.sql;
   \i populate.sql;
   \i indexes.sql;
   \i triggers.sql;
   \i views.sql;
   \i queries.sql; -- optional: for testing / examples
   ```

3. Verify that the main tables, constraints, and views exist by running some of the sample queries included in the SQL files.

### 5.3 Web application configuration

1. Install Node.js dependencies (from `part2/ehotels`):

   ```bash
   cd part2/ehotels
   npm install
   ```

2. Create a `.env.local` file to configure the database connection (an example structure):

   ```bash
   DATABASE_URL=postgres://username:password@localhost:5432/ehotels
   ```

   Replace `username`, `password`, and `localhost:5432` with your local PostgreSQL configuration.

### 5.4 Running the application

- For development:

  ```bash
  npm run dev
  ```

  This starts the Next.js dev server (by default on `http://localhost:3000`).

- For production build:

  ```bash
  npm run build
  npm start
  ```

---

## 6. Mapping to Course Requirements (2nd Deliverable)

This section shows how the implementation corresponds to the items in the project description (Section 2 in `courseproject2026.pdf`).

- **2a – Database implementation**  
  - Implemented in `part2/ehotels/schema.sql`, with all relations and constraints derived from the e‑Hotels description.

- **2b – Database population**  
  - Implemented in `part2/ehotels/populate.sql` with five hotel chains, multiple hotels and areas, and diverse room capacities.

- **2c – Database queries**  
  - Implemented in `part2/ehotels/queries.sql` with at least four queries, including aggregation and nested queries.

- **2d – Database modifications and triggers**  
  - Implemented in `part2/ehotels/triggers.sql` (and partly through constraints in `schema.sql`), ensuring safe insert / update / delete operations and user‑defined business rules.

- **2e – Database indexes**  
  - Implemented in `part2/ehotels/indexes.sql` with at least three indexes supporting common query patterns (search by area, dates, etc.).

- **2f – Database views**  
  - Implemented in `part2/ehotels/views.sql`:
    - View 1: `view_available_rooms_per_area`.  
    - View 2: `view_hotel_room_capacity`.  
    - Additional views: `view_active_bookings`, `view_chain_summary`.
  - Exposed in the web UI via `part2/ehotels/pages/views.js` and `/api/views/*`.

- **2g – Web application**  
  - Implemented using Next.js and React under `part2/ehotels`:
    - Search, booking, and renting flows: `pages/index.js`, `pages/search.js`, `/api/rooms/available`, `/api/bookings/*`, `/api/rentings/*`.
    - Insert / delete / update of customers, employees, hotels, and rooms (where applicable) through the employee pages and corresponding APIs.
    - Display of the two required views via `/views` page and `/api/views/*` endpoints.

---

## 7. Notes for Grading and Demonstration

- The **video presentation** mentioned in the project statement should follow the required structure (technologies used, schema overview, constraints, data, queries, triggers, indexes, views, and UI demo).  
- This README, together with the SQL scripts and source code in `part2/ehotels/pages/` and `part2/ehotels/pages/api/`, provides the textual documentation required for the **2nd deliverable report**:
  - Technologies used.
  - Installation and run instructions.
  - List of DDL statements and supporting SQL code.
  - Description of how the web application implements the required functionality.

