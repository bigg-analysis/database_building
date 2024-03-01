USE hospitality
GO

SELECT * FROM bookings

-- Testing Queries --
SELECT b.booking_id as "Booking ID", c.coordinator_firstname + ' ' + c.coordinator_lastname as 'Coordinator Name', c.coordinator_job_title_code as 'Job Title',
    r.registrant_firstname + ' ' + r.registrant_lastname as 'Registrant Name', b.booking_event_type_code as 'Event Type'
FROM bookings b
JOIN registrants r on r.registrant_id = b.booking_registrant_id
JOIN coordinators c on c.coordinator_id = b.booking_coordinator_id
WHERE b.booking_event_status_code = 'PEN'

SELECT * FROM registrants

-- Adding/Editing a Registrant --
DROP PROCEDURE IF EXISTS dbo.p_upsert_registrant
GO
CREATE PROCEDURE dbo.p_upsert_registrant (
    @registrant_firstname VARCHAR(50),
    @registrant_lastname VARCHAR(50),
    @registrant_phone BIGINT,
    @registrant_email VARCHAR(100)
) AS BEGIN
    BEGIN TRANSACTION
        BEGIN TRY
        -- DATA LOGIC --
        IF EXISTS (SELECT * FROM registrants WHERE registrant_email = @registrant_email) BEGIN 
            UPDATE registrants SET registrant_firstname = @registrant_firstname WHERE registrant_email = @registrant_email
            UPDATE registrants SET registrant_lastname = @registrant_lastname WHERE registrant_email = @registrant_email
            UPDATE registrants SET registrant_phone = @registrant_phone WHERE registrant_email = @registrant_email
            IF @@ROWCOUNT <> 1 THROW 6001, 'Unable to Update Registrant Information', 1
        END
        ELSE BEGIN
            DECLARE @registrant_id int = (SELECT MAX(registrant_id) FROM registrants) + 1
            INSERT INTO registrants (registrant_id, registrant_firstname, registrant_lastname, registrant_phone, registrant_email)
            VALUES (@registrant_id, @registrant_firstname, @registrant_lastname, @registrant_phone, @registrant_email)
            IF @@ROWCOUNT <> 1 THROW 6002, 'Unable to Insert Registrant Information', 1
        END COMMIT
        END TRY
        BEGIN CATCH
            ROLLBACK;
            THROW
        END CATCH
    END
GO

EXEC p_upsert_registrant @registrant_firstname = 'Gerald', @registrant_lastname = 'McMayhem', @registrant_phone = 3975574410, @registrant_email = 'grizzbaldo@mail.com'

SELECT * FROM registrants
WHERE registrant_email = 'grizzbaldo@mail.com'
GO

-- Editing Status on Bookings --
DROP PROCEDURE IF EXISTS dbo.p_update_booking_event_status
GO
CREATE PROCEDURE dbo.p_update_booking_event_status (
    @booking_id INT,
    @booking_event_status_code CHAR(3)
) AS BEGIN
    BEGIN TRANSACTION
        BEGIN TRY
        IF EXISTS (SELECT * FROM bookings WHERE booking_id = @booking_id) BEGIN
            UPDATE bookings SET booking_event_status_code = @booking_event_status_code WHERE booking_id = @booking_id
            IF @@ROWCOUNT <> 1 THROW 6003, 'Unable to Update Event Status Code', 1
        END COMMIT
        END TRY
        BEGIN CATCH
            ROLLBACK;
            THROW
        END CATCH
    END
GO

EXEC p_update_booking_event_status @booking_id = 10003, @booking_event_status_code = 'CMP'
SELECT * FROM bookings

-- Inserting a Booking into the Booking Table --
DROP PROCEDURE IF EXISTS dbo.p_insert_booking
GO
CREATE PROCEDURE dbo.p_insert_booking (
    @booking_registrant_id INT,
    @booking_coordinator_id INT,
    @booking_date_booked DATETIME2,
    @booking_event_start DATETIME2,
    @booking_event_end DATETIME2,
    @booking_event_type_code CHAR(3),
    @booking_attendance INT,
    @booking_location_code CHAR(3),
    @booking_minimum_price INT,
    @booking_maximum_price INT,
    @booking_vendor_id_one INT = NULL,
    @booking_vendor_id_two INT = NULL,
    @booking_vendor_id_three INT = NULL
) AS BEGIN
    BEGIN TRANSACTION
        BEGIN TRY
        BEGIN
        DECLARE @booking_id INT = (SELECT MAX(booking_id) FROM bookings) + 1
        DECLARE @booking_event_status_code CHAR(3) = 'PEN'
        INSERT INTO bookings (
            booking_id,
            booking_registrant_id,
            booking_coordinator_id,
            booking_date_booked,
            booking_event_start,
            booking_event_end,
            booking_event_type_code,
            booking_attendance,
            booking_location_code,
            booking_event_status_code,
            booking_minimum_price,
            booking_maximum_price,
            booking_vendor_id_one,
            booking_vendor_id_two,
            booking_vendor_id_three
        ) VALUES (
            @booking_id,
            @booking_registrant_id,
            @booking_coordinator_id,
            @booking_date_booked,
            @booking_event_start,
            @booking_event_end,
            @booking_event_type_code,
            @booking_attendance,
            @booking_location_code,
            @booking_event_status_code,
            @booking_minimum_price,
            @booking_maximum_price,
            @booking_vendor_id_one,
            @booking_vendor_id_two,
            @booking_vendor_id_three
        )
        IF @@ROWCOUNT <> 1 THROW 6004, 'Unable to Insert Booking', 1
        END COMMIT
        END TRY
        BEGIN CATCH
            ROLLBACK;
            THROW
        END CATCH
    END
GO

EXEC p_insert_booking
    @booking_registrant_id = 1741,
    @booking_coordinator_id = 533,
    @booking_date_booked = '2023-03-30 14:00:00',
    @booking_event_start = '2023-09-30 18:00:00',
    @booking_event_end = '2023-09-30 23:00:00',
    @booking_event_type_code = 'WED',
    @booking_attendance = 300,
    @booking_location_code = 'CMC',
    @booking_minimum_price = 35000,
    @booking_maximum_price = 46000,
    @booking_vendor_id_one = 423

-- Updating Booking --
DROP PROCEDURE IF EXISTS dbo.p_update_booking
GO
CREATE PROCEDURE dbo.p_update_booking (
    @booking_id INT,
    @booking_registrant_id INT,
    @booking_coordinator_id INT,
    @booking_date_booked DATETIME2,
    @booking_event_start DATETIME2,
    @booking_event_end DATETIME2,
    @booking_event_type_code CHAR(3),
    @booking_attendance INT,
    @booking_location_code CHAR(3),
    @booking_minimum_price INT,
    @booking_maximum_price INT,
    @booking_vendor_id_one INT = NULL,
    @booking_vendor_id_two INT = NULL,
    @booking_vendor_id_three INT = NULL
) AS BEGIN
    BEGIN TRANSACTION
        BEGIN TRY
        IF EXISTS (SELECT * FROM bookings WHERE booking_id = @booking_id) BEGIN
        UPDATE bookings SET booking_registrant_id = @booking_registrant_id WHERE booking_id = @booking_id
        UPDATE bookings SET booking_coordinator_id = @booking_coordinator_id WHERE booking_id = @booking_id
        UPDATE bookings SET booking_date_booked = @booking_date_booked WHERE booking_id = @booking_id
        UPDATE bookings SET booking_event_start = @booking_event_start WHERE booking_id = @booking_id
        UPDATE bookings SET booking_event_end = @booking_event_end WHERE booking_id = @booking_id
        UPDATE bookings SET booking_event_type_code = @booking_event_type_code WHERE booking_id = @booking_id
        UPDATE bookings SET booking_attendance = @booking_attendance WHERE booking_id = @booking_id
        UPDATE bookings SET booking_location_code = @booking_location_code WHERE booking_id = @booking_id
        UPDATE bookings SET booking_minimum_price = @booking_minimum_price WHERE booking_id = @booking_id
        UPDATE bookings SET booking_maximum_price = @booking_maximum_price WHERE booking_id = @booking_id
        UPDATE bookings SET booking_vendor_id_one = @booking_vendor_id_one WHERE booking_id = @booking_id
        UPDATE bookings SET booking_vendor_id_two = @booking_vendor_id_two WHERE booking_id = @booking_id
        UPDATE bookings SET booking_vendor_id_three = @booking_vendor_id_three WHERE booking_id = @booking_id
            IF @@ROWCOUNT <> 1 THROW 6005, 'Unable to Update Booking Information', 1
        END COMMIT
        END TRY
        BEGIN CATCH
        ROLLBACK;
        END CATCH
    END
GO

SELECT * FROM bookings WHERE booking_id = 10635

EXEC p_update_booking
    @booking_id = 10635,
    @booking_registrant_id = 1741,
    @booking_coordinator_id = 533,
    @booking_date_booked = '2023-03-30 14:00:00',
    @booking_event_start = '2023-09-30 18:00:00',
    @booking_event_end = '2023-09-30 23:00:00',
    @booking_event_type_code = 'WED',
    @booking_attendance = 300,
    @booking_location_code = 'CMC',
    @booking_minimum_price = 35000,
    @booking_maximum_price = 46000,
    @booking_vendor_id_one = 423

SELECT * FROM bookings WHERE booking_id = 10635