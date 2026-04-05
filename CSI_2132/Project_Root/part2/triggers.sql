-- ============================================================
-- e-Hotels Database Modifications & Triggers (2d)
-- CSI2132 - Databases I
--
-- Triggers implement the user-defined constraints from Part 1:
--   1. No overlapping bookings for the same room (no double-booking)
--   2. Auto-archive booking/renting on delete
--   3. Keep HOTEL.num_rooms in sync when rooms are added/deleted
--   4. Keep HOTEL_CHAIN.num_hotels in sync when hotels are added/deleted
--
-- Syntax: PostgreSQL (PL/pgSQL)
-- ============================================================


-- ============================================================
-- TRIGGER 1: Prevent overlapping bookings for the same room
-- ------------------------------------------------------------
-- User-defined constraint from Part 1 (c.4 #2):
--   "No double booking of the same room at the same time"
--
-- Fires BEFORE INSERT OR UPDATE on BOOKING.
-- Uses FOR EACH ROW to check per-booking.
-- Raises an exception if an overlapping booking exists.
-- Also checks RENTING so a booked room cannot be rented again.
-- ============================================================

CREATE OR REPLACE FUNCTION check_no_overlapping_booking()
RETURNS TRIGGER AS $$
BEGIN
    -- Check for overlap with existing BOOKINGS on the same room
    IF EXISTS (
        SELECT 1 FROM BOOKING
        WHERE room_id    = NEW.room_id
          AND booking_id <> COALESCE(NEW.booking_id, -1)  -- skip self on UPDATE
          AND start_date  < NEW.end_date
          AND end_date    > NEW.start_date
    ) THEN
        RAISE EXCEPTION
            'Room % is already booked between % and %.',
            NEW.room_id, NEW.start_date, NEW.end_date;
    END IF;

    -- Check for overlap with existing RENTINGS on the same room
    IF EXISTS (
        SELECT 1 FROM RENTING
        WHERE room_id    = NEW.room_id
          AND start_date  < NEW.end_date
          AND end_date    > NEW.start_date
    ) THEN
        RAISE EXCEPTION
            'Room % is already rented between % and %.',
            NEW.room_id, NEW.start_date, NEW.end_date;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_no_double_booking
BEFORE INSERT OR UPDATE ON BOOKING
FOR EACH ROW
EXECUTE FUNCTION check_no_overlapping_booking();


-- ============================================================
-- TRIGGER 2: Auto-archive a booking when it is deleted
-- ------------------------------------------------------------
-- Requirement from project spec:
--   "We need to store in the database the history of both
--    bookings and rentings (archives)"
--   "Information about an old booking must exist even if
--    information about the room or customer no longer exists."
--
-- Fires AFTER DELETE on BOOKING.
-- Captures a JSON snapshot of customer, room, and hotel data
-- at the time of deletion and stores it in BOOKING_ARCHIVE.
-- ============================================================

CREATE OR REPLACE FUNCTION archive_deleted_booking()
RETURNS TRIGGER AS $$
DECLARE
    v_customer_snap TEXT;
    v_room_snap     TEXT;
    v_hotel_snap    TEXT;
BEGIN
    -- Build customer snapshot (may already be deleted → use COALESCE)
    SELECT INTO v_customer_snap
        json_build_object(
            'customer_id', C.customer_id,
            'full_name',   C.full_name,
            'id_type',     C.id_type,
            'id_value',    C.id_value
        )::TEXT
    FROM CUSTOMER C
    WHERE C.customer_id = OLD.customer_id;

    -- Fallback if customer was already deleted
    IF v_customer_snap IS NULL THEN
        v_customer_snap := json_build_object(
            'customer_id', OLD.customer_id,
            'full_name',   'DELETED'
        )::TEXT;
    END IF;

    -- Build room + hotel snapshot
    SELECT INTO v_room_snap, v_hotel_snap
        json_build_object(
            'room_id',   R.room_id,
            'price',     R.price,
            'capacity',  R.capacity,
            'view_type', R.view_type
        )::TEXT,
        json_build_object(
            'hotel_id',  H.hotel_id,
            'address',   H.address,
            'area',      H.area,
            'chain',     HC.chain_name
        )::TEXT
    FROM ROOM R
    JOIN HOTEL H        ON R.hotel_id = H.hotel_id
    JOIN HOTEL_CHAIN HC ON H.chain_id = HC.chain_id
    WHERE R.room_id = OLD.room_id;

    -- Fallback if room was already deleted
    IF v_room_snap IS NULL THEN
        v_room_snap  := json_build_object('room_id', OLD.room_id, 'note', 'DELETED')::TEXT;
        v_hotel_snap := '{"note": "DELETED"}'::TEXT;
    END IF;

    -- Insert into archive (only if not already archived)
    INSERT INTO BOOKING_ARCHIVE (
        booking_id, customer_snapshot, room_snapshot,
        hotel_snapshot, start_date, end_date, archived_at
    )
    VALUES (
        OLD.booking_id,
        v_customer_snap,
        v_room_snap,
        v_hotel_snap,
        OLD.start_date,
        OLD.end_date,
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (booking_id) DO NOTHING;  -- safe re-run guard

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_archive_booking
AFTER DELETE ON BOOKING
FOR EACH ROW
EXECUTE FUNCTION archive_deleted_booking();


-- ============================================================
-- TRIGGER 3 (BONUS): Auto-archive a renting when it is deleted
-- ------------------------------------------------------------
-- Same archiving requirement applies to RENTING.
-- Fires AFTER DELETE on RENTING.
-- ============================================================

CREATE OR REPLACE FUNCTION archive_deleted_renting()
RETURNS TRIGGER AS $$
DECLARE
    v_customer_snap  TEXT;
    v_room_snap      TEXT;
    v_hotel_snap     TEXT;
    v_employee_snap  TEXT;
BEGIN
    SELECT INTO v_customer_snap
        json_build_object(
            'customer_id', C.customer_id,
            'full_name',   C.full_name
        )::TEXT
    FROM CUSTOMER C WHERE C.customer_id = OLD.customer_id;

    IF v_customer_snap IS NULL THEN
        v_customer_snap := json_build_object('customer_id', OLD.customer_id, 'note','DELETED')::TEXT;
    END IF;

    SELECT INTO v_room_snap, v_hotel_snap
        json_build_object(
            'room_id',  R.room_id,
            'price',    R.price,
            'capacity', R.capacity
        )::TEXT,
        json_build_object(
            'hotel_id', H.hotel_id,
            'address',  H.address,
            'area',     H.area,
            'chain',    HC.chain_name
        )::TEXT
    FROM ROOM R
    JOIN HOTEL H        ON R.hotel_id = H.hotel_id
    JOIN HOTEL_CHAIN HC ON H.chain_id = HC.chain_id
    WHERE R.room_id = OLD.room_id;

    IF v_room_snap IS NULL THEN
        v_room_snap  := json_build_object('room_id', OLD.room_id, 'note','DELETED')::TEXT;
        v_hotel_snap := '{"note":"DELETED"}'::TEXT;
    END IF;

    SELECT INTO v_employee_snap
        json_build_object(
            'employee_id', E.employee_id,
            'full_name',   E.full_name
        )::TEXT
    FROM EMPLOYEE E WHERE E.employee_id = OLD.employee_id;

    IF v_employee_snap IS NULL THEN
        v_employee_snap := json_build_object('employee_id', OLD.employee_id, 'note','DELETED')::TEXT;
    END IF;

    INSERT INTO RENTING_ARCHIVE (
        renting_id, customer_snapshot, room_snapshot,
        hotel_snapshot, employee_snapshot,
        start_date, end_date, archived_at
    )
    VALUES (
        OLD.renting_id,
        v_customer_snap,
        v_room_snap,
        v_hotel_snap,
        v_employee_snap,
        OLD.start_date,
        OLD.end_date,
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (renting_id) DO NOTHING;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_archive_renting
AFTER DELETE ON RENTING
FOR EACH ROW
EXECUTE FUNCTION archive_deleted_renting();


-- ============================================================
-- TRIGGER 4 (BONUS): Keep HOTEL.num_rooms accurate
-- ------------------------------------------------------------
-- User-defined constraint: num_rooms reflects actual room count.
-- Fires AFTER INSERT OR DELETE on ROOM.
-- Uses FOR EACH ROW + REFERENCING NEW/OLD ROW (as in slides).
-- ============================================================

CREATE OR REPLACE FUNCTION sync_hotel_num_rooms()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE HOTEL
        SET num_rooms = num_rooms + 1
        WHERE hotel_id = NEW.hotel_id;

    ELSIF TG_OP = 'DELETE' THEN
        UPDATE HOTEL
        SET num_rooms = num_rooms - 1
        WHERE hotel_id = OLD.hotel_id;
    END IF;

    RETURN NULL;  -- AFTER trigger: return value is ignored
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_num_rooms
AFTER INSERT OR DELETE ON ROOM
FOR EACH ROW
EXECUTE FUNCTION sync_hotel_num_rooms();


-- ============================================================
-- TRIGGER 5 (BONUS): Keep HOTEL_CHAIN.num_hotels accurate
-- ------------------------------------------------------------
-- Fires AFTER INSERT OR DELETE on HOTEL.
-- ============================================================

CREATE OR REPLACE FUNCTION sync_chain_num_hotels()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE HOTEL_CHAIN
        SET num_hotels = num_hotels + 1
        WHERE chain_id = NEW.chain_id;

    ELSIF TG_OP = 'DELETE' THEN
        UPDATE HOTEL_CHAIN
        SET num_hotels = num_hotels - 1
        WHERE chain_id = OLD.chain_id;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_num_hotels
AFTER INSERT OR DELETE ON HOTEL
FOR EACH ROW
EXECUTE FUNCTION sync_chain_num_hotels();


-- ============================================================
-- SAMPLE MODIFICATIONS to demonstrate triggers firing
-- ============================================================

-- --- Test Trigger 1: attempt a double-booking (should FAIL) ---
-- This INSERT overlaps with booking_id=1 (room 1, Apr 10-15)
-- Uncomment to test:
-- INSERT INTO BOOKING (customer_id, room_id, start_date, end_date)
-- VALUES (2, 1, '2026-04-13', '2026-04-17');
-- Expected: ERROR "Room 1 is already booked between 2026-04-13 and 2026-04-17."


-- --- Test Trigger 2: delete a booking → auto-archives it ---
-- DELETE FROM BOOKING WHERE booking_id = 10;
-- Then check: SELECT * FROM BOOKING_ARCHIVE WHERE booking_id = 10;


-- --- Test Trigger 4: insert a new room → num_rooms increments ---
-- INSERT INTO ROOM (hotel_id, price, capacity, view_type, extendable)
-- VALUES (1, 299.00, 'double', 'city', TRUE);
-- Then check: SELECT num_rooms FROM HOTEL WHERE hotel_id = 1;  -- should be 6


-- --- Normal INSERT: add a new walk-in renting ---
INSERT INTO RENTING (customer_id, room_id, employee_id, booking_id, start_date, end_date)
VALUES (6, 43, 16, NULL, '2026-04-15', '2026-04-18');

-- --- Normal UPDATE: fix a room price ---
UPDATE ROOM
SET price = 275.00
WHERE room_id = 1;

-- --- Normal DELETE: remove a future booking (triggers archive) ---
-- (booking_id=10 is a future booking for Aug 2026, safe to delete for demo)
DELETE FROM BOOKING WHERE booking_id = 10;
