-- ============================================================
-- e-Hotels Database Indexes (2e)
-- CSI2132 - Databases I
--
-- At least 3 indexes with justification.
-- Syntax: PostgreSQL  (CREATE INDEX)
-- Reference: Slide 11.156 — "create index <name> on <relation>(<attrs>)"
-- ============================================================


-- ------------------------------------------------------------
-- INDEX 1: HOTEL.area  (secondary index)
-- ------------------------------------------------------------
-- Type: B+-tree (PostgreSQL default), secondary (non-clustering)
--
-- Expected queries:
--   - The most common user search is filtering rooms BY AREA
--     (Query 1 in 2c, View 1 in 2f, web app search form).
--     Example: WHERE H.area = 'New York'
--   - View 1 groups rooms by area: GROUP BY H.area
--
-- Why useful:
--   Without this index, every room search by area requires a
--   full sequential scan of HOTEL (40 rows here, but thousands
--   in a real deployment). With a B+-tree index on area,
--   the DBMS can jump directly to matching hotels in O(log n).
--   As the slides state, secondary indexes allow efficient lookup
--   on non-primary-key attributes (slide 11.41 "Use of Secondary Indexes").
--
-- Update cost: low — area rarely changes after hotel creation.
-- ------------------------------------------------------------
CREATE INDEX idx_hotel_area
ON HOTEL (area);


-- ------------------------------------------------------------
-- INDEX 2: BOOKING (room_id, start_date, end_date)  (composite)
-- ------------------------------------------------------------
-- Type: B+-tree, composite secondary index
--
-- Expected queries:
--   - The no-double-booking trigger (Trigger 1) runs this check
--     on EVERY INSERT/UPDATE of BOOKING:
--       WHERE room_id = X AND start_date < Y AND end_date > Z
--   - Query 1 (room availability) also checks BOOKING for overlaps.
--   - This is a range query on dates — B+-trees support range
--     queries efficiently (slide 11.66 "Range queries find all
--     records with search key values in a given range").
--
-- Why composite:
--   Filtering first by room_id (equality), then by date range,
--   means the index can narrow to one room's bookings and then
--   scan only those dates — far fewer comparisons than two
--   separate indexes.
--
-- Update cost: moderate — new bookings inserted frequently,
--   but this is an expected write-heavy table and the index
--   overhead is justified by the read benefit.
-- ------------------------------------------------------------
CREATE INDEX idx_booking_room_dates
ON BOOKING (room_id, start_date, end_date);


-- ------------------------------------------------------------
-- INDEX 3: RENTING (room_id, start_date, end_date)  (composite)
-- ------------------------------------------------------------
-- Type: B+-tree, composite secondary index
--
-- Expected queries:
--   - Same overlap check as BOOKING, done in Trigger 1 and Query 1:
--       WHERE room_id = X AND start_date < Y AND end_date > Z
--   - Also used by View 1 to determine which rooms are currently
--     rented (not available).
--
-- Why useful:
--   Without an index, every availability check requires a full
--   scan of RENTING. In a busy system with thousands of rentings,
--   this becomes very expensive. The B+-tree composite index
--   makes both equality (room_id) and range (dates) lookups fast.
--
-- Update cost: similar to BOOKING — moderate write frequency,
--   high read benefit for the availability use case.
-- ------------------------------------------------------------
CREATE INDEX idx_renting_room_dates
ON RENTING (room_id, start_date, end_date);


-- ------------------------------------------------------------
-- INDEX 4 (BONUS): ROOM (hotel_id, capacity, price)  (composite)
-- ------------------------------------------------------------
-- Type: B+-tree, composite secondary index
--
-- Expected queries:
--   - Web app search filters rooms by: hotel, capacity, price range.
--     Example: WHERE hotel_id = X AND capacity = 'double'
--              AND price BETWEEN 100 AND 200
--   - View 2 (aggregated capacity per hotel) groups by hotel_id.
--   - Query 2 (aggregation) joins ROOM with HOTEL and groups by area.
--
-- Why composite:
--   hotel_id is the leading column (equality filter), capacity
--   is the second (equality), price is the third (range filter).
--   The index supports all three in one scan, consistent with
--   the "bucket idea" for multi-attribute queries (slide 11.44).
--
-- Update cost: low — room prices and capacities change rarely.
-- ------------------------------------------------------------
CREATE INDEX idx_room_hotel_capacity_price
ON ROOM (hotel_id, capacity, price);


-- ------------------------------------------------------------
-- INDEX 5 (BONUS): EMPLOYEE.hotel_id  (secondary index)
-- ------------------------------------------------------------
-- Type: B+-tree, secondary index
--
-- Expected queries:
--   - Finding all employees of a hotel (for check-in UI):
--       WHERE hotel_id = X
--   - HOTEL_MANAGER join with EMPLOYEE for manager lookup.
--   - Trigger 4 (num_rooms sync) and cascade deletes touch EMPLOYEE
--     when a hotel is deleted.
--
-- Why useful:
--   Employees are looked up by hotel constantly (every check-in
--   requires fetching hotel employees). Without this index,
--   a full scan of EMPLOYEE (45+ rows, scales to thousands) is
--   needed for every check-in operation.
-- ------------------------------------------------------------
CREATE INDEX idx_employee_hotel
ON EMPLOYEE (hotel_id);
