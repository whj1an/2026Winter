-- ============================================================
-- e-Hotels Data Population (2b)
-- CSI2132 - Databases I
-- 5 hotel chains, 8+ hotels each, 5+ rooms per hotel
-- 14+ distinct areas across North America
-- At least 2 hotels in the same area (New York, Toronto)
-- ============================================================


-- ------------------------------------------------------------
-- ROLES
-- ------------------------------------------------------------
INSERT INTO ROLE (role_name) VALUES
  ('manager'),
  ('receptionist'),
  ('housekeeper'),
  ('concierge'),
  ('maintenance');


-- ------------------------------------------------------------
-- HOTEL CHAINS
-- 5 chains, each with a distinct category (spread across 1-5)
-- chain_name added (consistent with DDL chain_name column)
-- ------------------------------------------------------------
INSERT INTO HOTEL_CHAIN (chain_name, central_office_address, category, num_hotels) VALUES
  ('Marriott International',   '7750 Wisconsin Ave, Bethesda, MD, USA',      5, 8),  -- chain_id=1
  ('Hilton Hotels',            '7930 Jones Branch Dr, McLean, VA, USA',       4, 8),  -- chain_id=2
  ('Holiday Inn (IHG)',        '3 Ravinia Dr, Atlanta, GA, USA',              3, 8),  -- chain_id=3
  ('Best Western',             '6201 N 24th Pkwy, Phoenix, AZ, USA',          2, 8),  -- chain_id=4
  ('Motel 6',                  '4001 International Pkwy, Carrollton, TX, USA',1, 8);  -- chain_id=5

-- Chain emails
INSERT INTO CHAIN_EMAIL (chain_id, email) VALUES
  (1,'contact@marriott.com'), (1,'support@marriott.com'),
  (2,'info@hilton.com'),      (2,'reservations@hilton.com'),
  (3,'hello@holidayinn.com'), (3,'support@ihg.com'),
  (4,'info@bestwestern.com'),
  (5,'info@motel6.com');

-- Chain phones
INSERT INTO CHAIN_PHONE (chain_id, phone) VALUES
  (1,'1-800-228-9290'), (1,'1-301-380-3000'),
  (2,'1-800-445-8667'),
  (3,'1-800-465-4329'),
  (4,'1-800-780-7234'),
  (5,'1-800-899-9841');


-- ------------------------------------------------------------
-- HOTELS  (8 per chain = 40 hotels total)
-- Areas used: New York, Toronto, Montreal, Chicago, Los Angeles,
--             Miami, Vancouver, Boston, Dallas, Seattle,
--             San Francisco, Ottawa, Las Vegas, Denver
-- New York and Toronto each appear in multiple chains → same area
-- ------------------------------------------------------------

-- === CHAIN 1: Marriott (category 5) ===
INSERT INTO HOTEL (chain_id, address, area, num_rooms) VALUES
  (1,'541 Lexington Ave, New York, NY',        'New York',      8),   -- hotel_id=1
  (1,'1285 Avenue of Americas, New York, NY',  'New York',      8),   -- hotel_id=2  (same area!)
  (1,'900 W Georgia St, Vancouver, BC',        'Vancouver',     8),   -- hotel_id=3
  (1,'1535 Broadway, Toronto, ON',             'Toronto',       8),   -- hotel_id=4
  (1,'160 E Huron St, Chicago, IL',            'Chicago',       8),   -- hotel_id=5
  (1,'333 Adams St, Boston, MA',               'Boston',        8),   -- hotel_id=6
  (1,'2901 Las Vegas Blvd S, Las Vegas, NV',   'Las Vegas',     8),   -- hotel_id=7
  (1,'1400 Market St, San Francisco, CA',      'San Francisco', 8);   -- hotel_id=8

-- === CHAIN 2: Hilton (category 4) ===
INSERT INTO HOTEL (chain_id, address, area, num_rooms) VALUES
  (2,'1335 Ave of the Americas, New York, NY', 'New York',      8),   -- hotel_id=9  (same area as 1,2!)
  (2,'145 Richmond St W, Toronto, ON',         'Toronto',       8),   -- hotel_id=10
  (2,'720 S Michigan Ave, Chicago, IL',        'Chicago',       8),   -- hotel_id=11
  (2,'5765 Blue Lagoon Dr, Miami, FL',         'Miami',         8),   -- hotel_id=12
  (2,'1301 Pennsylvania Ave, Washington, DC',  'Washington DC', 8),   -- hotel_id=13
  (2,'1150 22nd St NW, Seattle, WA',           'Seattle',       8),   -- hotel_id=14
  (2,'9876 Wilshire Blvd, Los Angeles, CA',    'Los Angeles',   8),   -- hotel_id=15
  (2,'1600 Glenarm Pl, Denver, CO',            'Denver',        8);   -- hotel_id=16

-- === CHAIN 3: Holiday Inn (category 3) ===
INSERT INTO HOTEL (chain_id, address, area, num_rooms) VALUES
  (3,'440 W 57th St, New York, NY',            'New York',      8),   -- hotel_id=17 (same area again!)
  (3,'370 King St W, Toronto, ON',             'Toronto',       8),   -- hotel_id=18
  (3,'300 Burrard St, Vancouver, BC',          'Vancouver',     8),   -- hotel_id=19
  (3,'506 Rue Sherbrooke O, Montreal, QC',     'Montreal',      8),   -- hotel_id=20
  (3,'200 S Michigan Ave, Chicago, IL',        'Chicago',       8),   -- hotel_id=21
  (3,'4300 Hampton Ave, Dallas, TX',           'Dallas',        8),   -- hotel_id=22
  (3,'2050 Stemmons Fwy, Dallas, TX',          'Dallas',        8),   -- hotel_id=23 (same area!)
  (3,'101 S 1st St, Las Vegas, NV',            'Las Vegas',     8);   -- hotel_id=24

-- === CHAIN 4: Best Western (category 2) ===
INSERT INTO HOTEL (chain_id, address, area, num_rooms) VALUES
  (4,'511 N Columbus Dr, Chicago, IL',         'Chicago',       8),   -- hotel_id=25
  (4,'1600 Ste-Catherine W, Montreal, QC',     'Montreal',      8),   -- hotel_id=26
  (4,'1100 Colonel By Dr, Ottawa, ON',         'Ottawa',        8),   -- hotel_id=27
  (4,'3600 Las Vegas Blvd, Las Vegas, NV',     'Las Vegas',     8),   -- hotel_id=28
  (4,'2200 Market St, San Francisco, CA',      'San Francisco', 8),   -- hotel_id=29
  (4,'8888 Pacific Hwy, Seattle, WA',          'Seattle',       8),   -- hotel_id=30
  (4,'1222 Spruce St, Denver, CO',             'Denver',        8),   -- hotel_id=31
  (4,'4600 Sunset Blvd, Los Angeles, CA',      'Los Angeles',   8);   -- hotel_id=32

-- === CHAIN 5: Motel 6 (category 1) ===
INSERT INTO HOTEL (chain_id, address, area, num_rooms) VALUES
  (5,'2323 Main St, Dallas, TX',               'Dallas',        8),   -- hotel_id=33
  (5,'7777 Sunset Blvd, Los Angeles, CA',      'Los Angeles',   8),   -- hotel_id=34
  (5,'1010 Decatur St, New Orleans, LA',       'New Orleans',   8),   -- hotel_id=35
  (5,'5001 Yonge St, Toronto, ON',             'Toronto',       8),   -- hotel_id=36
  (5,'3900 Rue Ontario E, Montreal, QC',       'Montreal',      8),   -- hotel_id=37
  (5,'850 King St, Ottawa, ON',                'Ottawa',        8),   -- hotel_id=38
  (5,'2400 Bank St, Ottawa, ON',               'Ottawa',        8),   -- hotel_id=39 (same area!)
  (5,'400 Granville St, Vancouver, BC',        'Vancouver',     8);   -- hotel_id=40

-- Hotel emails
INSERT INTO HOTEL_EMAIL (hotel_id, email) VALUES
  (1,'nyc1@marriott.com'),(2,'nyc2@marriott.com'),(3,'van@marriott.com'),
  (4,'tor@marriott.com'),(5,'chi@marriott.com'),(6,'bos@marriott.com'),
  (7,'lv@marriott.com'),(8,'sf@marriott.com'),
  (9,'nyc@hilton.com'),(10,'tor@hilton.com'),(11,'chi@hilton.com'),
  (12,'mia@hilton.com'),(13,'dc@hilton.com'),(14,'sea@hilton.com'),
  (15,'la@hilton.com'),(16,'den@hilton.com'),
  (17,'nyc@holidayinn.com'),(18,'tor@holidayinn.com'),(19,'van@holidayinn.com'),
  (20,'mtl@holidayinn.com'),(21,'chi@holidayinn.com'),(22,'dal1@holidayinn.com'),
  (23,'dal2@holidayinn.com'),(24,'lv@holidayinn.com'),
  (25,'chi@bestwestern.com'),(26,'mtl@bestwestern.com'),(27,'ott@bestwestern.com'),
  (28,'lv@bestwestern.com'),(29,'sf@bestwestern.com'),(30,'sea@bestwestern.com'),
  (31,'den@bestwestern.com'),(32,'la@bestwestern.com'),
  (33,'dal@motel6.com'),(34,'la@motel6.com'),(35,'no@motel6.com'),
  (36,'tor@motel6.com'),(37,'mtl@motel6.com'),(38,'ott1@motel6.com'),
  (39,'ott2@motel6.com'),(40,'van@motel6.com');

-- Hotel phones
INSERT INTO HOTEL_PHONE (hotel_id, phone) VALUES
  (1,'212-555-0101'),(2,'212-555-0102'),(3,'604-555-0103'),
  (4,'416-555-0104'),(5,'312-555-0105'),(6,'617-555-0106'),
  (7,'702-555-0107'),(8,'415-555-0108'),
  (9,'212-555-0201'),(10,'416-555-0202'),(11,'312-555-0203'),
  (12,'305-555-0204'),(13,'202-555-0205'),(14,'206-555-0206'),
  (15,'310-555-0207'),(16,'720-555-0208'),
  (17,'212-555-0301'),(18,'416-555-0302'),(19,'604-555-0303'),
  (20,'514-555-0304'),(21,'312-555-0305'),(22,'214-555-0306'),
  (23,'214-555-0307'),(24,'702-555-0308'),
  (25,'312-555-0401'),(26,'514-555-0402'),(27,'613-555-0403'),
  (28,'702-555-0404'),(29,'415-555-0405'),(30,'206-555-0406'),
  (31,'720-555-0407'),(32,'310-555-0408'),
  (33,'214-555-0501'),(34,'310-555-0502'),(35,'504-555-0503'),
  (36,'416-555-0504'),(37,'514-555-0505'),(38,'613-555-0506'),
  (39,'613-555-0507'),(40,'604-555-0508');


-- ------------------------------------------------------------
-- ROOMS  (5 rooms per hotel, different capacities)
-- Capacities: single, double, triple, quad, suite
-- Prices reflect hotel category (chain 5 cheapest, chain 1 most expensive)
-- ------------------------------------------------------------

-- Helper: for each hotel we insert 5 rooms with distinct capacities.
-- Chain 1 (5-star): $200-$500
INSERT INTO ROOM (hotel_id, price, capacity, view_type, extendable, problems_or_damages) VALUES
  (1, 250.00,'single','city',   FALSE, NULL),
  (1, 350.00,'double','city',   TRUE,  NULL),
  (1, 420.00,'triple','none',   TRUE,  NULL),
  (1, 480.00,'quad',  'none',   FALSE, NULL),
  (1, 500.00,'suite', 'city',   FALSE, NULL),
  -- hotel 2
  (2, 260.00,'single','none',   FALSE, NULL),
  (2, 360.00,'double','city',   TRUE,  NULL),
  (2, 430.00,'triple','city',   FALSE, NULL),
  (2, 490.00,'quad',  'none',   TRUE,  NULL),
  (2, 520.00,'suite', 'city',   FALSE, NULL),
  -- hotel 3
  (3, 240.00,'single','mountain',TRUE, NULL),
  (3, 330.00,'double','mountain',TRUE, NULL),
  (3, 400.00,'triple','none',   FALSE, NULL),
  (3, 460.00,'quad',  'none',   TRUE,  NULL),
  (3, 510.00,'suite', 'mountain',FALSE,NULL),
  -- hotel 4
  (4, 245.00,'single','city',   FALSE, NULL),
  (4, 340.00,'double','city',   TRUE,  NULL),
  (4, 410.00,'triple','none',   FALSE, NULL),
  (4, 470.00,'quad',  'city',   TRUE,  NULL),
  (4, 505.00,'suite', 'city',   FALSE, NULL),
  -- hotel 5
  (5, 255.00,'single','none',   TRUE,  NULL),
  (5, 355.00,'double','city',   TRUE,  NULL),
  (5, 425.00,'triple','none',   FALSE, 'Minor stain on carpet'),
  (5, 485.00,'quad',  'none',   TRUE,  NULL),
  (5, 515.00,'suite', 'city',   FALSE, NULL),
  -- hotel 6
  (6, 235.00,'single','none',   FALSE, NULL),
  (6, 325.00,'double','none',   TRUE,  NULL),
  (6, 395.00,'triple','sea',    FALSE, NULL),
  (6, 455.00,'quad',  'sea',    TRUE,  NULL),
  (6, 495.00,'suite', 'sea',    FALSE, NULL),
  -- hotel 7
  (7, 300.00,'single','city',   FALSE, NULL),
  (7, 400.00,'double','city',   TRUE,  NULL),
  (7, 460.00,'triple','city',   TRUE,  NULL),
  (7, 500.00,'quad',  'none',   FALSE, NULL),
  (7, 550.00,'suite', 'city',   FALSE, NULL),
  -- hotel 8
  (8, 280.00,'single','city',   TRUE,  NULL),
  (8, 380.00,'double','sea',    TRUE,  NULL),
  (8, 440.00,'triple','sea',    FALSE, NULL),
  (8, 490.00,'quad',  'none',   FALSE, NULL),
  (8, 530.00,'suite', 'sea',    FALSE, NULL);

-- Chain 2 (4-star): $150-$380
INSERT INTO ROOM (hotel_id, price, capacity, view_type, extendable, problems_or_damages) VALUES
  (9,  180.00,'single','city',    FALSE, NULL),
  (9,  250.00,'double','city',    TRUE,  NULL),
  (9,  300.00,'triple','none',    TRUE,  NULL),
  (9,  340.00,'quad',  'none',    FALSE, NULL),
  (9,  380.00,'suite', 'city',    FALSE, NULL),
  (10, 170.00,'single','none',    FALSE, NULL),
  (10, 240.00,'double','city',    TRUE,  NULL),
  (10, 290.00,'triple','city',    FALSE, NULL),
  (10, 330.00,'quad',  'none',    TRUE,  NULL),
  (10, 370.00,'suite', 'city',    FALSE, NULL),
  (11, 160.00,'single','none',    TRUE,  NULL),
  (11, 230.00,'double','none',    TRUE,  NULL),
  (11, 280.00,'triple','city',    FALSE, NULL),
  (11, 320.00,'quad',  'city',    TRUE,  NULL),
  (11, 360.00,'suite', 'city',    FALSE, NULL),
  (12, 190.00,'single','sea',     FALSE, NULL),
  (12, 260.00,'double','sea',     TRUE,  NULL),
  (12, 310.00,'triple','sea',     TRUE,  NULL),
  (12, 350.00,'quad',  'sea',     FALSE, NULL),
  (12, 390.00,'suite', 'sea',     FALSE, NULL),
  (13, 165.00,'single','city',    FALSE, NULL),
  (13, 235.00,'double','city',    TRUE,  NULL),
  (13, 285.00,'triple','none',    FALSE, NULL),
  (13, 325.00,'quad',  'none',    TRUE,  NULL),
  (13, 365.00,'suite', 'city',    FALSE, NULL),
  (14, 155.00,'single','mountain',FALSE, NULL),
  (14, 225.00,'double','mountain',TRUE,  NULL),
  (14, 275.00,'triple','none',    FALSE, NULL),
  (14, 315.00,'quad',  'none',    TRUE,  NULL),
  (14, 355.00,'suite', 'mountain',FALSE, NULL),
  (15, 175.00,'single','none',    FALSE, NULL),
  (15, 245.00,'double','none',    TRUE,  NULL),
  (15, 295.00,'triple','city',    FALSE, NULL),
  (15, 335.00,'quad',  'city',    FALSE, NULL),
  (15, 375.00,'suite', 'city',    FALSE, NULL),
  (16, 150.00,'single','mountain',FALSE, NULL),
  (16, 220.00,'double','mountain',TRUE,  NULL),
  (16, 270.00,'triple','none',    FALSE, NULL),
  (16, 310.00,'quad',  'none',    TRUE,  NULL),
  (16, 350.00,'suite', 'mountain',FALSE, NULL);

-- Chain 3 (3-star): $90-$220
INSERT INTO ROOM (hotel_id, price, capacity, view_type, extendable, problems_or_damages) VALUES
  (17,  95.00,'single','none',  FALSE, NULL),
  (17, 130.00,'double','city',  TRUE,  NULL),
  (17, 160.00,'triple','none',  FALSE, NULL),
  (17, 185.00,'quad',  'none',  TRUE,  NULL),
  (17, 210.00,'suite', 'city',  FALSE, NULL),
  (18,  90.00,'single','none',  FALSE, NULL),
  (18, 125.00,'double','none',  TRUE,  NULL),
  (18, 155.00,'triple','city',  FALSE, NULL),
  (18, 180.00,'quad',  'city',  TRUE,  NULL),
  (18, 205.00,'suite', 'city',  FALSE, NULL),
  (19,  98.00,'single','mountain',FALSE,NULL),
  (19, 135.00,'double','mountain',TRUE, NULL),
  (19, 165.00,'triple','none',  FALSE, NULL),
  (19, 190.00,'quad',  'none',  FALSE, NULL),
  (19, 215.00,'suite', 'mountain',FALSE,NULL),
  (20,  93.00,'single','none',  FALSE, NULL),
  (20, 128.00,'double','none',  TRUE,  NULL),
  (20, 158.00,'triple','none',  FALSE, 'Broken lamp'),
  (20, 183.00,'quad',  'none',  TRUE,  NULL),
  (20, 208.00,'suite', 'city',  FALSE, NULL),
  (21,  96.00,'single','none',  TRUE,  NULL),
  (21, 132.00,'double','city',  TRUE,  NULL),
  (21, 162.00,'triple','none',  FALSE, NULL),
  (21, 187.00,'quad',  'none',  TRUE,  NULL),
  (21, 212.00,'suite', 'city',  FALSE, NULL),
  (22,  91.00,'single','none',  FALSE, NULL),
  (22, 126.00,'double','none',  TRUE,  NULL),
  (22, 156.00,'triple','none',  FALSE, NULL),
  (22, 181.00,'quad',  'none',  FALSE, NULL),
  (22, 206.00,'suite', 'none',  FALSE, NULL),
  (23,  94.00,'single','none',  FALSE, NULL),
  (23, 129.00,'double','none',  TRUE,  NULL),
  (23, 159.00,'triple','none',  FALSE, NULL),
  (23, 184.00,'quad',  'none',  TRUE,  NULL),
  (23, 209.00,'suite', 'none',  FALSE, NULL),
  (24, 100.00,'single','city',  FALSE, NULL),
  (24, 140.00,'double','city',  TRUE,  NULL),
  (24, 170.00,'triple','none',  FALSE, NULL),
  (24, 195.00,'quad',  'none',  TRUE,  NULL),
  (24, 220.00,'suite', 'city',  FALSE, NULL);

-- Chain 4 (2-star): $60-$130
INSERT INTO ROOM (hotel_id, price, capacity, view_type, extendable, problems_or_damages) VALUES
  (25,  65.00,'single','none',  FALSE, NULL),
  (25,  85.00,'double','none',  TRUE,  NULL),
  (25, 100.00,'triple','none',  FALSE, NULL),
  (25, 115.00,'quad',  'none',  TRUE,  NULL),
  (25, 130.00,'suite', 'city',  FALSE, NULL),
  (26,  62.00,'single','none',  FALSE, NULL),
  (26,  82.00,'double','none',  TRUE,  NULL),
  (26,  97.00,'triple','none',  FALSE, NULL),
  (26, 112.00,'quad',  'none',  FALSE, NULL),
  (26, 127.00,'suite', 'none',  FALSE, NULL),
  (27,  60.00,'single','none',  FALSE, NULL),
  (27,  80.00,'double','none',  TRUE,  NULL),
  (27,  95.00,'triple','none',  FALSE, NULL),
  (27, 110.00,'quad',  'none',  TRUE,  NULL),
  (27, 125.00,'suite', 'none',  FALSE, NULL),
  (28,  70.00,'single','city',  FALSE, NULL),
  (28,  90.00,'double','city',  TRUE,  NULL),
  (28, 105.00,'triple','none',  FALSE, NULL),
  (28, 120.00,'quad',  'none',  FALSE, NULL),
  (28, 135.00,'suite', 'city',  FALSE, NULL),
  (29,  68.00,'single','none',  FALSE, NULL),
  (29,  88.00,'double','none',  TRUE,  NULL),
  (29, 103.00,'triple','sea',   FALSE, NULL),
  (29, 118.00,'quad',  'sea',   TRUE,  NULL),
  (29, 133.00,'suite', 'sea',   FALSE, NULL),
  (30,  63.00,'single','none',  FALSE, NULL),
  (30,  83.00,'double','none',  TRUE,  NULL),
  (30,  98.00,'triple','mountain',FALSE,NULL),
  (30, 113.00,'quad',  'mountain',TRUE, NULL),
  (30, 128.00,'suite', 'mountain',FALSE,NULL),
  (31,  61.00,'single','mountain',FALSE,NULL),
  (31,  81.00,'double','mountain',TRUE, NULL),
  (31,  96.00,'triple','none',  FALSE, NULL),
  (31, 111.00,'quad',  'none',  FALSE, NULL),
  (31, 126.00,'suite', 'none',  FALSE, NULL),
  (32,  67.00,'single','none',  FALSE, NULL),
  (32,  87.00,'double','none',  TRUE,  NULL),
  (32, 102.00,'triple','none',  FALSE, NULL),
  (32, 117.00,'quad',  'none',  TRUE,  NULL),
  (32, 132.00,'suite', 'city',  FALSE, NULL);

-- Chain 5 (1-star): $40-$80
INSERT INTO ROOM (hotel_id, price, capacity, view_type, extendable, problems_or_damages) VALUES
  (33,  42.00,'single','none',  FALSE, NULL),
  (33,  55.00,'double','none',  TRUE,  NULL),
  (33,  63.00,'triple','none',  FALSE, NULL),
  (33,  70.00,'quad',  'none',  FALSE, NULL),
  (33,  80.00,'suite', 'none',  FALSE, NULL),
  (34,  40.00,'single','none',  FALSE, NULL),
  (34,  53.00,'double','none',  TRUE,  NULL),
  (34,  61.00,'triple','none',  FALSE, NULL),
  (34,  68.00,'quad',  'none',  FALSE, NULL),
  (34,  78.00,'suite', 'none',  FALSE, NULL),
  (35,  44.00,'single','none',  FALSE, NULL),
  (35,  57.00,'double','none',  TRUE,  NULL),
  (35,  65.00,'triple','none',  FALSE, NULL),
  (35,  72.00,'quad',  'none',  TRUE,  NULL),
  (35,  82.00,'suite', 'none',  FALSE, NULL),
  (36,  41.00,'single','none',  FALSE, NULL),
  (36,  54.00,'double','none',  TRUE,  NULL),
  (36,  62.00,'triple','none',  FALSE, NULL),
  (36,  69.00,'quad',  'none',  FALSE, NULL),
  (36,  79.00,'suite', 'none',  FALSE, NULL),
  (37,  43.00,'single','none',  FALSE, NULL),
  (37,  56.00,'double','none',  TRUE,  NULL),
  (37,  64.00,'triple','none',  FALSE, 'Broken AC'),
  (37,  71.00,'quad',  'none',  FALSE, NULL),
  (37,  81.00,'suite', 'none',  FALSE, NULL),
  (38,  45.00,'single','none',  FALSE, NULL),
  (38,  58.00,'double','none',  TRUE,  NULL),
  (38,  66.00,'triple','none',  FALSE, NULL),
  (38,  73.00,'quad',  'none',  TRUE,  NULL),
  (38,  83.00,'suite', 'none',  FALSE, NULL),
  (39,  46.00,'single','none',  FALSE, NULL),
  (39,  59.00,'double','none',  TRUE,  NULL),
  (39,  67.00,'triple','none',  FALSE, NULL),
  (39,  74.00,'quad',  'none',  FALSE, NULL),
  (39,  84.00,'suite', 'none',  FALSE, NULL),
  (40,  48.00,'single','none',  FALSE, NULL),
  (40,  61.00,'double','none',  TRUE,  NULL),
  (40,  69.00,'triple','mountain',FALSE,NULL),
  (40,  76.00,'quad',  'mountain',TRUE, NULL),
  (40,  86.00,'suite', 'mountain',FALSE,NULL);


-- ------------------------------------------------------------
-- ROOM AMENITIES  (sample, not exhaustive)
-- ------------------------------------------------------------
INSERT INTO ROOM_AMENITY (room_id, amenity) VALUES
  -- hotel 1 rooms (room_id 1-5): 5-star amenities
  (1,'TV'),(1,'WiFi'),(1,'AC'),
  (2,'TV'),(2,'WiFi'),(2,'AC'),(2,'Fridge'),
  (3,'TV'),(3,'WiFi'),(3,'AC'),(3,'Fridge'),(3,'Minibar'),
  (4,'TV'),(4,'WiFi'),(4,'AC'),(4,'Fridge'),(4,'Minibar'),
  (5,'TV'),(5,'WiFi'),(5,'AC'),(5,'Fridge'),(5,'Minibar'),(5,'Jacuzzi'),
  -- hotel 9 rooms (room_id 41-45): 4-star
  (41,'TV'),(41,'WiFi'),(41,'AC'),
  (42,'TV'),(42,'WiFi'),(42,'AC'),(42,'Fridge'),
  (43,'TV'),(43,'WiFi'),(43,'AC'),(43,'Fridge'),
  (44,'TV'),(44,'WiFi'),(44,'AC'),(44,'Fridge'),(44,'Minibar'),
  (45,'TV'),(45,'WiFi'),(45,'AC'),(45,'Fridge'),(45,'Minibar'),
  -- hotel 17 rooms (room_id 81-85): 3-star
  (81,'TV'),(81,'WiFi'),
  (82,'TV'),(82,'WiFi'),(82,'AC'),
  (83,'TV'),(83,'WiFi'),(83,'AC'),
  (84,'TV'),(84,'WiFi'),(84,'AC'),(84,'Fridge'),
  (85,'TV'),(85,'WiFi'),(85,'AC'),(85,'Fridge'),
  -- hotel 25 rooms (room_id 121-125): 2-star
  (121,'TV'),(121,'WiFi'),
  (122,'TV'),(122,'WiFi'),
  (123,'TV'),(123,'WiFi'),(123,'AC'),
  (124,'TV'),(124,'WiFi'),(124,'AC'),
  (125,'TV'),(125,'WiFi'),(125,'AC'),
  -- hotel 33 rooms (room_id 161-165): 1-star
  (161,'TV'),
  (162,'TV'),
  (163,'TV'),(163,'WiFi'),
  (164,'TV'),(164,'WiFi'),
  (165,'TV'),(165,'WiFi');


-- ------------------------------------------------------------
-- CUSTOMERS  (10 customers)
-- ------------------------------------------------------------
INSERT INTO CUSTOMER (full_name, address, id_type, id_value, registration_date) VALUES
  ('Alice Martin',    '12 Maple Ave, Toronto, ON',        'SIN',            '123-456-789', '2024-01-10'),
  ('Bob Smith',       '88 King St, Montreal, QC',         'SIN',            '987-654-321', '2024-02-15'),
  ('Carol White',     '55 Park Ave, New York, NY',        'SSN',            '111-22-3333', '2024-03-01'),
  ('David Lee',       '200 Main St, Chicago, IL',         'SSN',            '444-55-6666', '2024-03-20'),
  ('Emma Brown',      '300 Oak Rd, Vancouver, BC',        'SIN',            '321-654-987', '2024-04-05'),
  ('Frank Chen',      '10 Robson St, Vancouver, BC',      'DRIVER_LICENSE', 'DL-BC-001',   '2024-05-01'),
  ('Grace Kim',       '77 Bloor St, Toronto, ON',         'SIN',            '555-777-888', '2024-06-10'),
  ('Henry Dupont',    '90 Rue Ste-Catherine, Montreal, QC','SIN',           '222-333-444', '2024-07-15'),
  ('Irene Nguyen',    '400 Las Vegas Blvd, Las Vegas, NV','SSN',            '777-88-9999', '2024-08-01'),
  ('James Wilson',    '500 Pacific Ave, Seattle, WA',     'SSN',            '666-77-8888', '2024-09-01');


-- ------------------------------------------------------------
-- EMPLOYEES  (2 per hotel for hotels 1-10, 1 per hotel for rest)
-- We need at least one manager per hotel.
-- We add 2 employees for hotels 1-5 to have enough for triggers/queries.
-- ------------------------------------------------------------
INSERT INTO EMPLOYEE (hotel_id, full_name, address, ssn_sin) VALUES
  -- hotel 1
  (1, 'Laura Adams',    '1 Staff Rd, New York, NY',      'EMP-001'),
  (1, 'Mike Davis',     '2 Staff Rd, New York, NY',      'EMP-002'),
  -- hotel 2
  (2, 'Nina Evans',     '3 Staff Rd, New York, NY',      'EMP-003'),
  (2, 'Omar Farouk',    '4 Staff Rd, New York, NY',      'EMP-004'),
  -- hotel 3
  (3, 'Paula Garcia',   '5 Staff Rd, Vancouver, BC',     'EMP-005'),
  (3, 'Quinn Hall',     '6 Staff Rd, Vancouver, BC',     'EMP-006'),
  -- hotel 4
  (4, 'Rachel Ingram',  '7 Staff Rd, Toronto, ON',       'EMP-007'),
  (4, 'Sam Jones',      '8 Staff Rd, Toronto, ON',       'EMP-008'),
  -- hotel 5
  (5, 'Tina Kim',       '9 Staff Rd, Chicago, IL',       'EMP-009'),
  (5, 'Uma Lopez',      '10 Staff Rd, Chicago, IL',      'EMP-010'),
  -- hotels 6-40: one employee each (manager only)
  (6,  'Victor Marsh',    '11 Staff Rd, Boston, MA',      'EMP-011'),
  (7,  'Wendy Nash',      '12 Staff Rd, Las Vegas, NV',   'EMP-012'),
  (8,  'Xander Owen',     '13 Staff Rd, San Francisco, CA','EMP-013'),
  (9,  'Yara Patel',      '14 Staff Rd, New York, NY',    'EMP-014'),
  (10, 'Zoe Quinn',       '15 Staff Rd, Toronto, ON',     'EMP-015'),
  (11, 'Aaron Reed',      '16 Staff Rd, Chicago, IL',     'EMP-016'),
  (12, 'Bella Scott',     '17 Staff Rd, Miami, FL',       'EMP-017'),
  (13, 'Carlos Turner',   '18 Staff Rd, Washington, DC',  'EMP-018'),
  (14, 'Diana Upton',     '19 Staff Rd, Seattle, WA',     'EMP-019'),
  (15, 'Evan Vance',      '20 Staff Rd, Los Angeles, CA', 'EMP-020'),
  (16, 'Fiona Webb',      '21 Staff Rd, Denver, CO',      'EMP-021'),
  (17, 'George Xiao',     '22 Staff Rd, New York, NY',    'EMP-022'),
  (18, 'Hannah Young',    '23 Staff Rd, Toronto, ON',     'EMP-023'),
  (19, 'Ian Zimmerman',   '24 Staff Rd, Vancouver, BC',   'EMP-024'),
  (20, 'Julia Archer',    '25 Staff Rd, Montreal, QC',    'EMP-025'),
  (21, 'Kevin Blake',     '26 Staff Rd, Chicago, IL',     'EMP-026'),
  (22, 'Lisa Carter',     '27 Staff Rd, Dallas, TX',      'EMP-027'),
  (23, 'Mark Dunn',       '28 Staff Rd, Dallas, TX',      'EMP-028'),
  (24, 'Nancy Ellis',     '29 Staff Rd, Las Vegas, NV',   'EMP-029'),
  (25, 'Oscar Ford',      '30 Staff Rd, Chicago, IL',     'EMP-030'),
  (26, 'Penny Grant',     '31 Staff Rd, Montreal, QC',    'EMP-031'),
  (27, 'Ryan Hughes',     '32 Staff Rd, Ottawa, ON',      'EMP-032'),
  (28, 'Sara Irving',     '33 Staff Rd, Las Vegas, NV',   'EMP-033'),
  (29, 'Tom Jordan',      '34 Staff Rd, San Francisco, CA','EMP-034'),
  (30, 'Uma King',        '35 Staff Rd, Seattle, WA',     'EMP-035'),
  (31, 'Vince Lane',      '36 Staff Rd, Denver, CO',      'EMP-036'),
  (32, 'Wendy Moore',     '37 Staff Rd, Los Angeles, CA', 'EMP-037'),
  (33, 'Xavier Noble',    '38 Staff Rd, Dallas, TX',      'EMP-038'),
  (34, 'Yolanda Park',    '39 Staff Rd, Los Angeles, CA', 'EMP-039'),
  (35, 'Zachary Quinn',   '40 Staff Rd, New Orleans, LA', 'EMP-040'),
  (36, 'Amy Ross',        '41 Staff Rd, Toronto, ON',     'EMP-041'),
  (37, 'Brian Stone',     '42 Staff Rd, Montreal, QC',    'EMP-042'),
  (38, 'Clara Trent',     '43 Staff Rd, Ottawa, ON',      'EMP-043'),
  (39, 'Derek Upton',     '44 Staff Rd, Ottawa, ON',      'EMP-044'),
  (40, 'Elena Voss',      '45 Staff Rd, Vancouver, BC',   'EMP-045');


-- ------------------------------------------------------------
-- EMPLOYEE ROLES
-- ------------------------------------------------------------
-- All first employees of each hotel are managers
INSERT INTO EMPLOYEE_ROLE (employee_id, role_id) VALUES
  (1,1),(2,2),   -- hotel 1: Laura=manager, Mike=receptionist
  (3,1),(4,2),   -- hotel 2
  (5,1),(6,3),   -- hotel 3: Paula=manager, Quinn=housekeeper
  (7,1),(8,2),   -- hotel 4
  (9,1),(10,2),  -- hotel 5
  (11,1),(12,1),(13,1),(14,1),(15,1),  -- hotels 6-10: single manager each
  (16,1),(17,1),(18,1),(19,1),(20,1),
  (21,1),(22,1),(23,1),(24,1),(25,1),
  (26,1),(27,1),(28,1),(29,1),(30,1),
  (31,1),(32,1),(33,1),(34,1),(35,1),
  (36,1),(37,1),(38,1),(39,1),(40,1),
  (41,1),(42,1),(43,1),(44,1),(45,1);


-- ------------------------------------------------------------
-- HOTEL MANAGERS  (one per hotel, employee_id = first employee)
-- ------------------------------------------------------------
INSERT INTO HOTEL_MANAGER (hotel_id, employee_id) VALUES
  (1,1),(2,3),(3,5),(4,7),(5,9),(6,11),(7,12),(8,13),
  (9,14),(10,15),(11,16),(12,17),(13,18),(14,19),(15,20),(16,21),
  (17,22),(18,23),(19,24),(20,25),(21,26),(22,27),(23,28),(24,29),
  (25,30),(26,31),(27,32),(28,33),(29,34),(30,35),(31,36),(32,37),
  (33,38),(34,39),(35,40),(36,41),(37,42),(38,43),(39,44),(40,45);


-- ------------------------------------------------------------
-- BOOKINGS  (active bookings for queries/views)
-- Rooms used: 1,2,3,6,9,41,81,121,161 (a mix of chains/areas)
-- ------------------------------------------------------------
INSERT INTO BOOKING (customer_id, room_id, start_date, end_date, created_at) VALUES
  (1,  1,  '2026-04-10', '2026-04-15', '2026-03-01 10:00:00'),  -- booking_id=1
  (2,  6,  '2026-04-12', '2026-04-18', '2026-03-05 11:00:00'),  -- booking_id=2
  (3,  9,  '2026-04-20', '2026-04-25', '2026-03-10 09:00:00'),  -- booking_id=3
  (4,  41, '2026-05-01', '2026-05-05', '2026-03-15 14:00:00'),  -- booking_id=4
  (5,  81, '2026-05-10', '2026-05-14', '2026-03-20 16:00:00'),  -- booking_id=5
  (6,  121,'2026-06-01', '2026-06-07', '2026-04-01 08:00:00'),  -- booking_id=6
  (7,  2,  '2026-06-15', '2026-06-20', '2026-04-02 09:00:00'),  -- booking_id=7
  (8,  3,  '2026-07-01', '2026-07-05', '2026-04-03 10:00:00'),  -- booking_id=8
  (9,  161,'2026-07-10', '2026-07-14', '2026-04-04 11:00:00'),  -- booking_id=9
  (10, 42, '2026-08-01', '2026-08-06', '2026-04-05 12:00:00');  -- booking_id=10


-- ------------------------------------------------------------
-- RENTINGS  (some converted from bookings, one walk-in)
-- booking_id=1 → renting (check-in by employee 2)
-- booking_id=2 → renting (check-in by employee 11)
-- booking_id=3 → renting (check-in by employee 14)
-- renting with NULL booking_id = walk-in
-- ------------------------------------------------------------
INSERT INTO RENTING (customer_id, room_id, employee_id, booking_id, start_date, end_date, checkin_time) VALUES
  (1, 1,  2,  1, '2026-04-10', '2026-04-15', '2026-04-10 14:00:00'),  -- from booking 1
  (2, 6,  11, 2, '2026-04-12', '2026-04-18', '2026-04-12 15:00:00'),  -- from booking 2
  (3, 9,  14, 3, '2026-04-20', '2026-04-25', '2026-04-20 13:00:00'),  -- from booking 3
  (4, 41, 14, 4, '2026-05-01', '2026-05-05', '2026-05-01 12:00:00'),  -- from booking 4
  (5, 22, 27, NULL,'2026-04-05','2026-04-08', '2026-04-05 16:00:00'); -- walk-in (no booking)


-- ------------------------------------------------------------
-- ARCHIVES  (historical records - room/customer may be deleted)
-- ------------------------------------------------------------
INSERT INTO BOOKING_ARCHIVE (booking_id, customer_snapshot, room_snapshot, hotel_snapshot, start_date, end_date, archived_at) VALUES
  (1001,
   '{"customer_id":99,"full_name":"John Doe","id_type":"SSN","id_value":"000-11-2222"}',
   '{"room_id":999,"price":199.00,"capacity":"double","view_type":"sea"}',
   '{"hotel_id":99,"address":"Old St, Boston, MA","chain":"Marriott"}',
   '2025-06-01','2025-06-05','2025-06-05 12:00:00'),
  (1002,
   '{"customer_id":98,"full_name":"Jane Roe","id_type":"SIN","id_value":"000-22-3333"}',
   '{"room_id":998,"price":120.00,"capacity":"single","view_type":"none"}',
   '{"hotel_id":98,"address":"Old Ave, Chicago, IL","chain":"Hilton"}',
   '2025-07-10','2025-07-14','2025-07-14 11:00:00');

INSERT INTO RENTING_ARCHIVE (renting_id, customer_snapshot, room_snapshot, hotel_snapshot, employee_snapshot, start_date, end_date, archived_at) VALUES
  (2001,
   '{"customer_id":99,"full_name":"John Doe"}',
   '{"room_id":999,"price":199.00,"capacity":"double"}',
   '{"hotel_id":99,"address":"Old St, Boston, MA"}',
   '{"employee_id":88,"full_name":"Old Staff"}',
   '2025-06-01','2025-06-05','2025-06-05 14:00:00'),
  (2002,
   '{"customer_id":98,"full_name":"Jane Roe"}',
   '{"room_id":998,"price":120.00,"capacity":"single"}',
   '{"hotel_id":98,"address":"Old Ave, Chicago, IL"}',
   '{"employee_id":87,"full_name":"Another Staff"}',
   '2025-07-10','2025-07-14','2025-07-14 13:00:00');
