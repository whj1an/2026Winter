-- ============================================================
-- e-Hotels Database Views (2f)
--
-- View 1 (required): Number of available rooms per area
-- View 2 (required): Aggregated capacity of all rooms in a hotel
-- View 3 (bonus): All current bookings with full details
-- View 4 (bonus): Hotel chain summary (hotels, rooms, avg price)
--
-- Syntax: CREATE VIEW v AS <query expression>
-- ============================================================


-- ------------------------------------------------------------
-- VIEW 1 : Number of available rooms per area
-- ------------------------------------------------------------
-- "Available" means a room has no active booking AND no active
-- renting overlapping today's date, and has no damage reported.
--
-- The web UI will query this view to show room availability
-- per area in real time. The view acts as a virtual relation —
-- the query expression is stored and evaluated at query time
-- (slide 6.87: "the definition of the view means that an expression
-- is created and maintained, which during execution is substituted
-- in the queries that use it").
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_available_rooms_per_area AS
SELECT
    H.area,
    COUNT(R.room_id)        AS available_rooms,
    MIN(R.price)            AS min_price,
    MAX(R.price)            AS max_price,
    AVG(R.price)            AS avg_price
FROM ROOM R
JOIN HOTEL H ON R.hotel_id = H.hotel_id
WHERE
    -- Room has no damage
    R.problems_or_damages IS NULL
    -- Room has no active booking overlapping today
    AND NOT EXISTS (
        SELECT 1 FROM BOOKING B
        WHERE B.room_id    = R.room_id
          AND B.start_date <= CURRENT_DATE
          AND B.end_date   >= CURRENT_DATE
    )
    -- Room has no active renting overlapping today
    AND NOT EXISTS (
        SELECT 1 FROM RENTING RT
        WHERE RT.room_id    = R.room_id
          AND RT.start_date <= CURRENT_DATE
          AND RT.end_date   >= CURRENT_DATE
    )
GROUP BY H.area
ORDER BY available_rooms DESC;

-- Sample query on View 1:
-- SELECT * FROM view_available_rooms_per_area;
-- SELECT * FROM view_available_rooms_per_area WHERE area = 'New York';


-- ------------------------------------------------------------
-- VIEW 2 (required): Aggregated capacity of all rooms in a hotel
-- ------------------------------------------------------------
-- "Aggregated capacity" = total number of rooms broken down by
-- capacity type for each hotel. This gives a quick summary of
-- what a hotel offers.
--
-- The web UI shows this in the hotel detail page so customers
-- can see how many singles, doubles, etc. are in a hotel.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_hotel_room_capacity AS
SELECT
    H.hotel_id,
    H.address           AS hotel_address,
    H.area,
    HC.chain_name,
    HC.category         AS hotel_stars,
    R.capacity,
    COUNT(R.room_id)    AS num_rooms_of_capacity,
    AVG(R.price)        AS avg_price_for_capacity
FROM ROOM R
JOIN HOTEL H        ON R.hotel_id = H.hotel_id
JOIN HOTEL_CHAIN HC ON H.chain_id = HC.chain_id
GROUP BY H.hotel_id, H.address, H.area, HC.chain_name, HC.category, R.capacity
ORDER BY H.hotel_id, R.capacity;

-- Sample query on View 2:
-- SELECT * FROM view_hotel_room_capacity WHERE hotel_id = 1;
-- SELECT * FROM view_hotel_room_capacity WHERE area = 'Toronto';


-- ------------------------------------------------------------
-- VIEW 3 (bonus): All current active bookings with full details
-- ------------------------------------------------------------
-- Useful for the employee UI: shows all pending bookings that
-- need to be converted to rentings when customers check in.
-- Also useful for the customer UI to show "my upcoming bookings".
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_active_bookings AS
SELECT
    B.booking_id,
    B.start_date,
    B.end_date,
    B.created_at,
    C.customer_id,
    C.full_name         AS customer_name,
    C.id_type,
    C.id_value,
    R.room_id,
    R.capacity,
    R.price,
    R.view_type,
    H.hotel_id,
    H.address           AS hotel_address,
    H.area,
    HC.chain_name,
    HC.category         AS hotel_stars
FROM BOOKING B
JOIN CUSTOMER    C  ON B.customer_id = C.customer_id
JOIN ROOM        R  ON B.room_id     = R.room_id
JOIN HOTEL       H  ON R.hotel_id    = H.hotel_id
JOIN HOTEL_CHAIN HC ON H.chain_id    = HC.chain_id
-- Only bookings not yet converted to a renting
WHERE NOT EXISTS (
    SELECT 1 FROM RENTING RT
    WHERE RT.booking_id = B.booking_id
)
ORDER BY B.start_date ASC;

-- Sample query on View 3:
-- SELECT * FROM view_active_bookings;
-- SELECT * FROM view_active_bookings WHERE area = 'New York';
-- SELECT * FROM view_active_bookings WHERE customer_id = 1;


-- ------------------------------------------------------------
-- VIEW 4 (bonus): Hotel chain summary
-- ------------------------------------------------------------
-- Shows each chain's total hotels, total rooms, average room
-- price, and number of distinct areas covered.
-- Useful for the admin UI and for the web app's chain filter.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_chain_summary AS
SELECT
    HC.chain_id,
    HC.chain_name,
    HC.category         AS chain_stars,
    COUNT(DISTINCT H.hotel_id)  AS total_hotels,
    COUNT(DISTINCT H.area)      AS areas_covered,
    COUNT(R.room_id)            AS total_rooms,
    ROUND(AVG(R.price)::NUMERIC, 2) AS avg_room_price,
    MIN(R.price)                AS cheapest_room,
    MAX(R.price)                AS most_expensive_room
FROM HOTEL_CHAIN HC
JOIN HOTEL H ON HC.chain_id = H.chain_id
JOIN ROOM  R ON H.hotel_id  = R.hotel_id
GROUP BY HC.chain_id, HC.chain_name, HC.category
ORDER BY HC.category DESC;

-- Sample query on View 4:
-- SELECT * FROM view_chain_summary;
-- SELECT chain_name, total_rooms, avg_room_price
-- FROM view_chain_summary
-- WHERE chain_stars >= 3;
