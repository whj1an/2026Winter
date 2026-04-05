-- ============================================================
-- e-Hotels Database Schema (2a)
-- CSI2132 - Databases I
-- Consistent with Report of Part 1 (1st Deliverable)
-- ============================================================

-- Drop tables in reverse dependency order (safe re-run)
DROP TABLE IF EXISTS RENTING_ARCHIVE;
DROP TABLE IF EXISTS BOOKING_ARCHIVE;
DROP TABLE IF EXISTS RENTING;
DROP TABLE IF EXISTS BOOKING;
DROP TABLE IF EXISTS HOTEL_MANAGER;
DROP TABLE IF EXISTS EMPLOYEE_ROLE;
DROP TABLE IF EXISTS ROLE;
DROP TABLE IF EXISTS EMPLOYEE;
DROP TABLE IF EXISTS ROOM_AMENITY;
DROP TABLE IF EXISTS ROOM;
DROP TABLE IF EXISTS HOTEL_PHONE;
DROP TABLE IF EXISTS HOTEL_EMAIL;
DROP TABLE IF EXISTS HOTEL;
DROP TABLE IF EXISTS CHAIN_PHONE;
DROP TABLE IF EXISTS CHAIN_EMAIL;
DROP TABLE IF EXISTS CUSTOMER;
DROP TABLE IF EXISTS HOTEL_CHAIN;


-- ------------------------------------------------------------
-- HOTEL_CHAIN
-- category: 1-star to 5-star
-- ------------------------------------------------------------
CREATE TABLE HOTEL_CHAIN (
    chain_id                SERIAL          PRIMARY KEY,
    chain_name              VARCHAR(100)    NOT NULL,
    central_office_address  VARCHAR(255)    NOT NULL,
    category                INTEGER         NOT NULL
                                            CHECK (category BETWEEN 1 AND 5),
    num_hotels              INTEGER         NOT NULL DEFAULT 0
                                            CHECK (num_hotels >= 0)
);

-- Multi-valued: emails of a hotel chain
CREATE TABLE CHAIN_EMAIL (
    chain_id    INTEGER         NOT NULL
                                REFERENCES HOTEL_CHAIN(chain_id)
                                ON DELETE CASCADE,
    email       VARCHAR(100)    NOT NULL,
    PRIMARY KEY (chain_id, email)
);

-- Multi-valued: phone numbers of a hotel chain
CREATE TABLE CHAIN_PHONE (
    chain_id    INTEGER         NOT NULL
                                REFERENCES HOTEL_CHAIN(chain_id)
                                ON DELETE CASCADE,
    phone       VARCHAR(20)     NOT NULL,
    PRIMARY KEY (chain_id, phone)
);


-- ------------------------------------------------------------
-- HOTEL
-- Cannot exist without its hotel chain (CASCADE DELETE)
-- area extracted from address for query use
-- ------------------------------------------------------------
CREATE TABLE HOTEL (
    hotel_id    SERIAL          PRIMARY KEY,
    chain_id    INTEGER         NOT NULL
                                REFERENCES HOTEL_CHAIN(chain_id)
                                ON DELETE CASCADE,
    address     VARCHAR(255)    NOT NULL,
    area        VARCHAR(100)    NOT NULL,   -- city/region for View 1 queries
    num_rooms   INTEGER         NOT NULL DEFAULT 0
                                CHECK (num_rooms >= 0)
);

CREATE TABLE HOTEL_EMAIL (
    hotel_id    INTEGER         NOT NULL
                                REFERENCES HOTEL(hotel_id)
                                ON DELETE CASCADE,
    email       VARCHAR(100)    NOT NULL,
    PRIMARY KEY (hotel_id, email)
);

CREATE TABLE HOTEL_PHONE (
    hotel_id    INTEGER         NOT NULL
                                REFERENCES HOTEL(hotel_id)
                                ON DELETE CASCADE,
    phone       VARCHAR(20)     NOT NULL,
    PRIMARY KEY (hotel_id, phone)
);


-- ------------------------------------------------------------
-- ROOM
-- Cannot exist without its hotel (CASCADE DELETE)
-- capacity: 'single', 'double', 'triple', 'quad', 'suite'
-- view_type: 'sea', 'mountain', 'city', 'none'
-- ------------------------------------------------------------
CREATE TABLE ROOM (
    room_id             SERIAL          PRIMARY KEY,
    hotel_id            INTEGER         NOT NULL
                                        REFERENCES HOTEL(hotel_id)
                                        ON DELETE CASCADE,
    price               NUMERIC(10,2)   NOT NULL
                                        CHECK (price > 0),
    capacity            VARCHAR(20)     NOT NULL
                                        CHECK (capacity IN ('single','double','triple','quad','suite')),
    view_type           VARCHAR(20)     NOT NULL DEFAULT 'none'
                                        CHECK (view_type IN ('sea','mountain','city','none')),
    extendable          BOOLEAN         NOT NULL DEFAULT FALSE,
    problems_or_damages TEXT            DEFAULT NULL   -- NULL means no problems
);

-- Multi-valued: amenities of a room (e.g. 'TV', 'fridge', 'AC')
CREATE TABLE ROOM_AMENITY (
    room_id     INTEGER         NOT NULL
                                REFERENCES ROOM(room_id)
                                ON DELETE CASCADE,
    amenity     VARCHAR(50)     NOT NULL,
    PRIMARY KEY (room_id, amenity)
);


-- ------------------------------------------------------------
-- CUSTOMER
-- id_type: SSN, SIN, or DRIVER_LICENSE
-- ------------------------------------------------------------
CREATE TABLE CUSTOMER (
    customer_id         SERIAL          PRIMARY KEY,
    full_name           VARCHAR(100)    NOT NULL,
    address             VARCHAR(255)    NOT NULL,
    id_type             VARCHAR(20)     NOT NULL
                                        CHECK (id_type IN ('SSN','SIN','DRIVER_LICENSE')),
    id_value            VARCHAR(50)     NOT NULL,
    registration_date   DATE            NOT NULL DEFAULT CURRENT_DATE,
    UNIQUE (id_type, id_value)          -- same person cannot register twice
);


-- ------------------------------------------------------------
-- EMPLOYEE
-- Belongs to exactly one hotel
-- SSN/SIN must be unique across all employees
-- ------------------------------------------------------------
CREATE TABLE EMPLOYEE (
    employee_id SERIAL          PRIMARY KEY,
    hotel_id    INTEGER         NOT NULL
                                REFERENCES HOTEL(hotel_id)
                                ON DELETE CASCADE,
    full_name   VARCHAR(100)    NOT NULL,
    address     VARCHAR(255)    NOT NULL,
    ssn_sin     VARCHAR(20)     NOT NULL    UNIQUE
);


-- ------------------------------------------------------------
-- ROLE  (e.g. 'manager', 'receptionist', 'housekeeper')
-- ------------------------------------------------------------
CREATE TABLE ROLE (
    role_id     SERIAL          PRIMARY KEY,
    role_name   VARCHAR(50)     NOT NULL    UNIQUE
);

-- Employee can have many roles
CREATE TABLE EMPLOYEE_ROLE (
    employee_id INTEGER     NOT NULL
                            REFERENCES EMPLOYEE(employee_id)
                            ON DELETE CASCADE,
    role_id     INTEGER     NOT NULL
                            REFERENCES ROLE(role_id)
                            ON DELETE CASCADE,
    PRIMARY KEY (employee_id, role_id)
);


-- ------------------------------------------------------------
-- HOTEL_MANAGER
-- Every hotel must have exactly one manager.
-- The UNIQUE on employee_id ensures one manager per employee.
-- The trigger below enforces every hotel has exactly one entry.
-- ------------------------------------------------------------
CREATE TABLE HOTEL_MANAGER (
    hotel_id    INTEGER     NOT NULL    PRIMARY KEY
                            REFERENCES HOTEL(hotel_id)
                            ON DELETE CASCADE,
    employee_id INTEGER     NOT NULL    UNIQUE
                            REFERENCES EMPLOYEE(employee_id)
                            ON DELETE RESTRICT   -- cannot delete a manager without reassigning
);


-- ------------------------------------------------------------
-- BOOKING
-- customer_id / room_id: SET NULL on delete so archive can
-- still hold a snapshot (live booking is soft-deleted via archive)
-- start_date must be before end_date
-- ------------------------------------------------------------
CREATE TABLE BOOKING (
    booking_id  SERIAL          PRIMARY KEY,
    customer_id INTEGER         NOT NULL
                                REFERENCES CUSTOMER(customer_id)
                                ON DELETE CASCADE,
    room_id     INTEGER         NOT NULL
                                REFERENCES ROOM(room_id)
                                ON DELETE CASCADE,
    start_date  DATE            NOT NULL,
    end_date    DATE            NOT NULL,
    created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (start_date < end_date)
);


-- ------------------------------------------------------------
-- RENTING
-- booking_id is NULL for walk-in rentings (no prior booking)
-- booking_id UNIQUE ensures one-to-one booking→renting
-- employee_id: the employee who performed check-in
-- ------------------------------------------------------------
CREATE TABLE RENTING (
    renting_id  SERIAL          PRIMARY KEY,
    customer_id INTEGER         NOT NULL
                                REFERENCES CUSTOMER(customer_id)
                                ON DELETE CASCADE,
    room_id     INTEGER         NOT NULL
                                REFERENCES ROOM(room_id)
                                ON DELETE CASCADE,
    employee_id INTEGER         NOT NULL
                                REFERENCES EMPLOYEE(employee_id)
                                ON DELETE RESTRICT,
    booking_id  INTEGER         UNIQUE          -- NULL = walk-in
                                REFERENCES BOOKING(booking_id)
                                ON DELETE SET NULL,
    start_date  DATE            NOT NULL,
    end_date    DATE            NOT NULL,
    checkin_time TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (start_date < end_date)
);


-- ------------------------------------------------------------
-- BOOKING_ARCHIVE
-- Stores history even after room/customer is deleted.
-- Snapshots are stored as JSON text for flexibility.
-- ------------------------------------------------------------
CREATE TABLE BOOKING_ARCHIVE (
    booking_id          INTEGER         PRIMARY KEY,   -- original booking_id
    customer_snapshot   TEXT            NOT NULL,      -- JSON snapshot
    room_snapshot       TEXT            NOT NULL,
    hotel_snapshot      TEXT            NOT NULL,
    start_date          DATE            NOT NULL,
    end_date            DATE            NOT NULL,
    archived_at         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ------------------------------------------------------------
-- RENTING_ARCHIVE
-- Same idea: snapshots persist after deletion.
-- ------------------------------------------------------------
CREATE TABLE RENTING_ARCHIVE (
    renting_id          INTEGER         PRIMARY KEY,
    customer_snapshot   TEXT            NOT NULL,
    room_snapshot       TEXT            NOT NULL,
    hotel_snapshot      TEXT            NOT NULL,
    employee_snapshot   TEXT            NOT NULL,
    start_date          DATE            NOT NULL,
    end_date            DATE            NOT NULL,
    archived_at         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);
