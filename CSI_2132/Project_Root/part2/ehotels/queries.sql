-- ============================================================
-- e-Hotels SQL Queries (2c)
-- CSI2132 - Databases I
-- At least 4 queries, including:
--   - at least 1 with aggregation (GROUP BY / HAVING)
--   - at least 1 with a nested query (subquery)
-- ============================================================


-- ------------------------------------------------------------
-- Query 1: Find all available rooms in a given area for a date range
-- (Simple join query – core use case of the application)
--
-- A room is "available" if it has NO overlapping booking AND
-- NO overlapping renting for the requested dates.
-- This uses NOT EXISTS (nested subquery) on both BOOKING and RENTING.
-- ------------------------------------------------------------
-- Example: available rooms in 'New York' from 2026-05-01 to 2026-05-07

SELECT
    R.room_id,
    H.hotel_id,
    H.address        AS hotel_address,
    HC.chain_name,
    HC.category      AS hotel_stars,
    R.capacity,
    R.price,
    R.view_type,
    R.extendable
FROM ROOM R
JOIN HOTEL H        ON R.hotel_id  = H.hotel_id
JOIN HOTEL_CHAIN HC ON H.chain_id  = HC.chain_id
WHERE H.area = 'New York'
  AND R.problems_or_damages IS NULL           -- only undamaged rooms
  AND NOT EXISTS (
        SELECT 1 FROM BOOKING B
        WHERE B.room_id    = R.room_id
          AND B.start_date < '2026-05-07'
          AND B.end_date   > '2026-05-01'
  )
  AND NOT EXISTS (
        SELECT 1 FROM RENTING RT
        WHERE RT.room_id    = R.room_id
          AND RT.start_date < '2026-05-07'
          AND RT.end_date   > '2026-05-01'
  )
ORDER BY HC.category DESC, R.price ASC;


-- ------------------------------------------------------------
-- Query 2 (AGGREGATION): Number of rooms per hotel chain per area,
-- grouped and filtered to chains that have more than 2 rooms in an area.
--
-- Uses GROUP BY + HAVING (aggregation with filter).
-- Shows chains with significant presence in each area.
-- ------------------------------------------------------------

SELECT
    HC.chain_name,
    H.area,
    COUNT(R.room_id)        AS total_rooms,
    AVG(R.price)            AS avg_price,
    MIN(R.price)            AS min_price,
    MAX(R.price)            AS max_price
FROM ROOM R
JOIN HOTEL H        ON R.hotel_id = H.hotel_id
JOIN HOTEL_CHAIN HC ON H.chain_id = HC.chain_id
GROUP BY HC.chain_name, H.area
HAVING COUNT(R.room_id) > 2
ORDER BY HC.chain_name, H.area;


-- ------------------------------------------------------------
-- Query 3 (NESTED QUERY): Find customers who have made at least
-- one booking but have NEVER completed a renting.
--
-- Uses NOT IN with a subquery on RENTING — identifies customers
-- who booked but never actually checked in.
-- ------------------------------------------------------------

SELECT
    C.customer_id,
    C.full_name,
    C.address,
    C.registration_date
FROM CUSTOMER C
WHERE C.customer_id IN (
    SELECT DISTINCT customer_id FROM BOOKING
)
AND C.customer_id NOT IN (
    SELECT DISTINCT customer_id FROM RENTING
)
ORDER BY C.customer_id;


-- ------------------------------------------------------------
-- Query 4 (AGGREGATION + NESTED): For each hotel, show the total
-- number of bookings and the average room price of booked rooms,
-- but only for hotels whose average booked room price is above
-- the overall average room price across all hotels.
--
-- Uses GROUP BY + HAVING with a subquery in the HAVING clause.
-- ------------------------------------------------------------

SELECT
    H.hotel_id,
    H.address,
    H.area,
    HC.chain_name,
    COUNT(B.booking_id)     AS total_bookings,
    AVG(R.price)            AS avg_booked_room_price
FROM BOOKING B
JOIN ROOM  R  ON B.room_id  = R.room_id
JOIN HOTEL H  ON R.hotel_id = H.hotel_id
JOIN HOTEL_CHAIN HC ON H.chain_id = HC.chain_id
GROUP BY H.hotel_id, H.address, H.area, HC.chain_name
HAVING AVG(R.price) > (
    SELECT AVG(price) FROM ROOM
)
ORDER BY avg_booked_room_price DESC;


-- ------------------------------------------------------------
-- Query 5 (BONUS): Find all employees who are managers and the
-- hotel they manage, along with the hotel chain name and category.
--
-- Useful for the employee-facing UI to verify manager assignments.
-- ------------------------------------------------------------

SELECT
    E.employee_id,
    E.full_name         AS manager_name,
    H.hotel_id,
    H.address           AS hotel_address,
    H.area,
    HC.chain_name,
    HC.category         AS hotel_stars
FROM HOTEL_MANAGER HM
JOIN EMPLOYEE    E  ON HM.employee_id = E.employee_id
JOIN HOTEL       H  ON HM.hotel_id    = H.hotel_id
JOIN HOTEL_CHAIN HC ON H.chain_id     = HC.chain_id
ORDER BY HC.chain_name, H.area;


-- ------------------------------------------------------------
-- Query 6 (BONUS – NESTED IN FROM): Find the area with the
-- highest number of available (undamaged) rooms.
--
-- Uses a subquery in the FROM clause (derived table), a pattern
-- shown in the course slides (slide 3.52).
-- ------------------------------------------------------------

SELECT area, available_rooms
FROM (
    SELECT
        H.area,
        COUNT(R.room_id) AS available_rooms
    FROM ROOM R
    JOIN HOTEL H ON R.hotel_id = H.hotel_id
    WHERE R.problems_or_damages IS NULL
    GROUP BY H.area
) AS area_counts
ORDER BY available_rooms DESC
LIMIT 5;
