## Database Design (e‑Hotels – CSI2132 Project)

This document describes the database implementation for the e‑Hotels project:

- **Schema & constraints**: `part2/ehotels/schema.sql`
- **Data population**: `part2/ehotels/populate.sql`
- **Queries**: `part2/ehotels/queries.sql`
- **Triggers (modifications)**: `part2/ehotels/triggers.sql`
- **Indexes**: `part2/ehotels/indexes.sql`
- **Views**: `part2/ehotels/views.sql`

The schema is designed to match the project statement (`courseproject2026.pdf`), including:

- hotel chains, hotels, and rooms (with amenities and damage flags),
- customers and employees (with roles and a manager per hotel),
- booking and renting flows (including walk-ins),
- and **archives** to keep historical booking/renting information even after deletions.

---

## 1. Core Entities and Relationships

### 1.1 Hotel chains and hotels

- **`HOTEL_CHAIN`**
  - Identified by `chain_id`.
  - Stores the chain name, central office address, and a `category` (1–5 stars).
  - Maintains a summary attribute `num_hotels`.
  - Multi-valued contact info is represented by separate relations:
    - `CHAIN_EMAIL(chain_id, email)`
    - `CHAIN_PHONE(chain_id, phone)`

- **`HOTEL`**
  - Each hotel belongs to exactly one chain: `HOTEL.chain_id → HOTEL_CHAIN.chain_id`.
  - Stores address, `area` (city/region), and a summary attribute `num_rooms`.
  - Multi-valued contacts:
    - `HOTEL_EMAIL(hotel_id, email)`
    - `HOTEL_PHONE(hotel_id, phone)`

**Deletion rule**: hotels cannot exist without their chain, and rooms cannot exist without their hotel.  
This is enforced through `ON DELETE CASCADE` along the chain → hotel → room hierarchy.

### 1.2 Rooms and amenities

- **`ROOM`**
  - Each room belongs to a hotel: `ROOM.hotel_id → HOTEL.hotel_id`.
  - Attributes include:
    - `price` (positive numeric),
    - `capacity` (enumerated: `single`, `double`, `triple`, `quad`, `suite`),
    - `view_type` (enumerated: `sea`, `mountain`, `city`, `none`),
    - `extendable` (boolean),
    - `problems_or_damages` (NULL means no reported damage).

- **`ROOM_AMENITY(room_id, amenity)`**
  - Models the multi-valued “amenities” attribute.
  - Cascades on room deletion.

### 1.3 Customers and employees

- **`CUSTOMER`**
  - Stores full name, address, ID type/value, and registration date.
  - Uniqueness constraint: `(id_type, id_value)` is unique (same person cannot register twice).

- **`EMPLOYEE`**
  - Employees belong to a hotel: `EMPLOYEE.hotel_id → HOTEL.hotel_id`.
  - Unique constraint on `ssn_sin`.

- **`ROLE`** and **`EMPLOYEE_ROLE`**
  - `ROLE` stores role names (e.g., manager, receptionist, etc.).
  - `EMPLOYEE_ROLE` models the many-to-many relationship between employees and roles.

### 1.4 Managers (user-defined constraint)

- **`HOTEL_MANAGER(hotel_id, employee_id)`**
  - Ensures a hotel has a manager entry:
    - `hotel_id` is the primary key (one manager per hotel).
    - `employee_id` is unique (an employee cannot manage multiple hotels).
  - `employee_id` uses `ON DELETE RESTRICT` to prevent deleting a manager without reassignment.

> Note: The schema includes a comment about a trigger enforcing “every hotel has exactly one manager”.  
> If this trigger is required in the final submission, ensure it exists in `triggers.sql` (or is enforced via controlled data + application logic).

---

## 2. Booking and Renting Model

### 2.1 Bookings

- **`BOOKING(booking_id, customer_id, room_id, start_date, end_date, created_at)`**
  - `start_date < end_date` is enforced with a CHECK constraint.
  - Deletion cascades from customer and room, but history is preserved through archives (see below).

### 2.2 Rentings

- **`RENTING(renting_id, customer_id, room_id, employee_id, booking_id, start_date, end_date, checkin_time)`**
  - Supports two renting modes:
    - **Check-in conversion**: `booking_id` references an existing booking.
    - **Walk-in renting**: `booking_id` is `NULL`.
  - `booking_id` is `UNIQUE`, enforcing a one-to-one booking → renting conversion.
  - `employee_id` is the staff member responsible for check-in.

---

## 3. Archives (History Preservation Requirement)

The project statement requires storing booking/renting history even if the original room or customer no longer exists.

This is implemented using archive tables that store **snapshots** as JSON text:

- **`BOOKING_ARCHIVE`**
  - Stores:
    - `booking_id` (original id),
    - `customer_snapshot`, `room_snapshot`, `hotel_snapshot`,
    - the booking date range,
    - `archived_at`.

- **`RENTING_ARCHIVE`**
  - Stores:
    - `renting_id`,
    - snapshots for customer, room, hotel, and employee,
    - date range and archive timestamp.

**Archiving mechanism**: triggers in `part2/ehotels/triggers.sql` copy a snapshot into the archive tables when a booking or renting is deleted.

---

## 4. Triggers and User-Defined Constraints (Requirement 2d)

All triggers are defined in `part2/ehotels/triggers.sql` (PL/pgSQL).

### 4.1 Prevent double-booking (required business rule)

- Trigger: `trg_no_double_booking` (BEFORE INSERT OR UPDATE ON `BOOKING`)
- Function: `check_no_overlapping_booking()`

Guarantees:

- no overlapping bookings for the same room, and
- a booking cannot overlap an active renting for the same room.

### 4.2 Auto-archive on delete

- Trigger: `trg_archive_booking` (AFTER DELETE ON `BOOKING`)
  - Function: `archive_deleted_booking()`
- Trigger: `trg_archive_renting` (AFTER DELETE ON `RENTING`) — bonus
  - Function: `archive_deleted_renting()`

Guarantees:

- historical information is preserved even after the original rows are deleted.

### 4.3 Keep summary attributes in sync (bonus)

- Trigger: `trg_sync_num_rooms` (AFTER INSERT OR DELETE ON `ROOM`)
  - Maintains `HOTEL.num_rooms`.
- Trigger: `trg_sync_num_hotels` (AFTER INSERT OR DELETE ON `HOTEL`)
  - Maintains `HOTEL_CHAIN.num_hotels`.

---

## 5. Indexes (Requirement 2e)

Indexes are defined in `part2/ehotels/indexes.sql`.  
They should be chosen to accelerate the most frequent workload in this project:

- searching available rooms by area/date/capacity/price,
- filtering by chain/category,
- and joining `ROOM` ↔ `HOTEL` ↔ `HOTEL_CHAIN`.

> For the final report/video, include a short justification for each index: what query it supports and why it helps.

---

## 6. Views (Requirement 2f)

Views are defined in `part2/ehotels/views.sql`.

### 6.1 Required views

- **View 1: available rooms per area**
  - Name: `view_available_rooms_per_area`
  - Meaning: rooms with **no damage** and with **no booking/renting overlapping today**.
  - Output: area, available room count, and min/max/avg prices.

- **View 2: hotel room capacity**
  - Name: `view_hotel_room_capacity`
  - Meaning: per hotel and per capacity type, count rooms and compute average price.

### 6.2 Bonus views

- `view_active_bookings` – helpful for employee workflows (pending bookings not converted to rentings).
- `view_chain_summary` – chain-level aggregated statistics (hotels, areas, rooms, prices).

---

## 7. Script Execution Order (Recommended)

When creating a fresh database, run the scripts in this order from `part2/ehotels/`:

1. `schema.sql`
2. `populate.sql`
3. `indexes.sql`
4. `triggers.sql`
5. `views.sql`
6. `queries.sql` (optional; for demonstrations/testing)

If you change views/triggers during development, re-run the relevant file(s) (`CREATE OR REPLACE` is used where appropriate).

