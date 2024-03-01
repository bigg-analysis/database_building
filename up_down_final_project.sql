-- Final Database Project --
-- Brandon's Hospitality Holdings --
-- Database DOWN/UP/VERIFY SQL --

-- DO NOT RUN FULL CODE --
-- ONLY PERFORM THE DROP CODE --
-- ONCE DROPPED, READ INFORMATION AFTER DROP SECTION --

IF EXISTS(SELECT * FROM sys.databases WHERE NAME = 'hospitality')
    DROP DATABASE hospitality
IF NOT EXISTS(SELECT * FROM sys.databases WHERE NAME = 'hospitality')
    CREATE DATABASE hospitality
GO

USE hospitality
GO

-- DOWN --
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_NAME = 'fk_bookings_booking_vendor_id_three')
    ALTER TABLE bookings DROP CONSTRAINT fk_bookings_booking_vendor_id_three
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_NAME = 'fk_bookings_booking_vendor_id_two')
    ALTER TABLE bookings DROP CONSTRAINT fk_bookings_booking_vendor_id_two
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_NAME = 'fk_bookings_booking_vendor_id_one')
    ALTER TABLE bookings DROP CONSTRAINT fk_bookings_booking_vendor_id_one
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_NAME = 'fk_bookings_booking_event_status_code')
    ALTER TABLE bookings DROP CONSTRAINT fk_bookings_booking_event_status_code
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_NAME = 'fk_bookings_booking_location_code')
    ALTER TABLE bookings DROP CONSTRAINT fk_bookings_booking_location_code
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_NAME = 'fk_bookings_booking_event_type_code')
    ALTER TABLE bookings DROP CONSTRAINT fk_bookings_booking_event_type_code
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_NAME = 'fk_bookings_booking_coordinator_id')
    ALTER TABLE bookings DROP CONSTRAINT fk_bookings_booking_coordinator_id
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_NAME = 'fk_bookings_booking_registrant_id')
    ALTER TABLE bookings DROP CONSTRAINT fk_bookings_booking_registrant_id
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_NAME = 'fk_coordinators_job_title_code')
    ALTER TABLE coordinators DROP CONSTRAINT fk_coordinators_job_title_code
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_NAME = 'fk_vendors_vendor_type_code')
    ALTER TABLE vendors DROP CONSTRAINT fk_vendors_vendor_type_code

DROP TABLE IF EXISTS bookings
DROP TABLE IF EXISTS registrants
DROP TABLE IF EXISTS coordinators
DROP TABLE IF EXISTS vendors
DROP TABLE IF EXISTS location_lookup
DROP TABLE IF EXISTS job_title_lookup
DROP TABLE IF EXISTS event_type_lookup
DROP TABLE IF EXISTS vendor_type_lookup
DROP TABLE IF EXISTS event_status_lookup
GO


-- WARNING --
-- DO NOT EXECUTE UP METADATA AND BEYOND --
-- IF YOU ARE WANTING TO USE THE CSV FILES, PLEASE USE THE SQL CSV FILE WIZARD EXTENSTION --
-- AFTER, RUN THE UP CONSTRAINTS AND KEYS CODE --


-- UP METADATA --
CREATE TABLE event_status_lookup (
    event_status_code CHAR(3) NOT NULL,
    event_status VARCHAR(20) NOT NULL,
    CONSTRAINT pk_event_status_lookup_event_status_code PRIMARY KEY(event_status_code)
)

CREATE TABLE vendor_type_lookup (
    vendor_type_code CHAR(3) NOT NULL,
    vendor_type VARCHAR(13) NOT NULL,
    CONSTRAINT pk_vendor_type_lookup_vendor_type_code PRIMARY KEY(vendor_type_code)
)

CREATE TABLE event_type_lookup (
    event_type_code CHAR(3) NOT NULL,
    event_type VARCHAR(20) NOT NULL,
    CONSTRAINT pk_event_type_lookup_event_type_code PRIMARY KEY(event_type_code)
)

CREATE TABLE job_title_lookup (
    job_title_code CHAR(3) NOT NULL,
    job_title VARCHAR(30) NOT NULL,
    CONSTRAINT pk_job_title_lookup_job_title_code PRIMARY KEY(job_title_code)
)

CREATE TABLE location_lookup (
    location_code CHAR (3) NOT NULL,
    location_name VARCHAR (30) NOT NULL,
    CONSTRAINT pk_location_lookup_location_code PRIMARY KEY(location_code)
)

CREATE TABLE vendors (
    vendor_id INT IDENTITY NOT NULL,
    vendor_name VARCHAR(60) NOT NULL,
    vendor_phone CHAR(10) NOT NULL,
    vendor_email VARCHAR(80) NOT NULL,
    vendor_type_code CHAR(3) NOT NULL,
    CONSTRAINT pk_vendors_vendor_id PRIMARY KEY(vendor_id)
)

CREATE TABLE coordinators (
    coordinator_id INT IDENTITY NOT NULL,
    coordinator_firstname VARCHAR(25) NOT NULL,
    coordinator_lastname VARCHAR(25) NOT NULL,
    coordinator_phone CHAR(10) NOT NULL,
    coordinator_email VARCHAR(80) NOT NULL,
    coordinator_job_title_code CHAR(3) NOT NULL,
    CONSTRAINT pk_coordinators_coordinator_id PRIMARY KEY(coordinator_id)
)

CREATE TABLE registrants (
    registrant_id INT IDENTITY NOT NULL,
    registrant_firstname VARCHAR(25) NOT NULL,
    registrant_lastname VARCHAR(25) NOT NULL,
    registrant_phone CHAR(10) NOT NULL,
    registrant_email VARCHAR(80) NOT NULL,
    CONSTRAINT pk_registrants_registrant_id PRIMARY KEY(registrant_id)
)

CREATE TABLE bookings (
    booking_id INT IDENTITY NOT NULL,
    booking_registrant_id INT NOT NULL,
    booking_coordinator_id INT NOT NULL,
    booking_date_booked SMALLDATETIME NOT NULL,
    booking_event_start SMALLDATETIME NOT NULL,
    booking_event_end SMALLDATETIME NOT NULL,
    booking_event_type_code CHAR(3) NOT NULL,
    booking_attendance SMALLINT NOT NULL,
    booking_location_code CHAR(3) NOT NULL,
    booking_event_status_code CHAR(3) NOT NULL,
    booking_minimum_price MONEY NOT NULL,
    booking_maximum_price MONEY NOT NULL,
    booking_vendor_id_one INT NULL,
    booking_vendor_id_two INT NULL,
    booking_vendor_id_three INT NULL,
    CONSTRAINT pk_bookings_booking_id PRIMARY KEY(booking_id)
)
GO


-- UP CONSTRAINTS AND KEYS--
ALTER TABLE vendors ADD
    CONSTRAINT u_vendors_vendor_email UNIQUE(vendor_email),
    CONSTRAINT ck_vendors_vendor_phone CHECK(vendor_phone NOT LIKE '%[^0-9]%'),
    CONSTRAINT fk_vendors_vendor_type_code FOREIGN KEY(vendor_type_code)
        REFERENCES vendor_type_lookup(vendor_type_code)

ALTER TABLE coordinators ADD
    CONSTRAINT u_coordinators_coordinator_email UNIQUE(coordinator_email),
    CONSTRAINT ck_coordinators_coordinator_phone CHECK(coordinator_phone NOT LIKE '%[^0-9}%'),    
    CONSTRAINT fk_coordinators_job_title_code FOREIGN KEY(coordinator_job_title_code)
        REFERENCES job_title_lookup(job_title_code)

ALTER TABLE registrants ADD
    CONSTRAINT u_registrants_registrant_email UNIQUE(registrant_email),
    CONSTRAINT ck_registrants_registrant_phone CHECK(registrant_phone NOT LIKE '%[^0-9}%')

ALTER TABLE bookings ADD
    CONSTRAINT ck_bookings_valud_attendance CHECK(booking_attendance > 0 AND booking_attendance <= 500),
    CONSTRAINT fk_bookings_booking_registrant_id FOREIGN KEY(booking_registrant_id)
        REFERENCES registrants(registrant_id),
    CONSTRAINT fk_bookings_booking_coordinator_id FOREIGN KEY(booking_coordinator_id)
        REFERENCES coordinators(coordinator_id),
    CONSTRAINT fk_bookings_booking_event_type_code FOREIGN KEY(booking_event_type_code)
        REFERENCES event_type_lookup(event_type_code),
    CONSTRAINT fk_bookings_booking_location_code FOREIGN KEY(booking_location_code)
        REFERENCES location_lookup(location_code),
    CONSTRAINT fk_bookings_booking_event_status_code FOREIGN KEY(booking_event_status_code)
        REFERENCES event_status_lookup(event_status_code),
    CONSTRAINT fk_bookings_booking_vendor_id_one FOREIGN KEY(booking_vendor_id_one)
        REFERENCES vendors(vendor_id),
    CONSTRAINT fk_bookings_booking_vendor_id_two FOREIGN KEY(booking_vendor_id_two)
        REFERENCES vendors(vendor_id),
    CONSTRAINT fk_bookings_booking_vendor_id_three FOREIGN KEY(booking_vendor_id_three)
        REFERENCES vendors(vendor_id)


-- UP DATA --
-- For the UP DATA, CSV Files Will be Provided and imported through the wizard. --
-- For Whatever Reason, I was unable to load information through 'BULK INSERT' --