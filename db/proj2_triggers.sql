-- Dong Chen & Weiqing Huang
-- Project 2 Triggers Part

USE flight_delays;
-- Trigger 1
-- This trigger insert scheduled_time table with SCHEDULED_TIME Automatically after insert into schedule_time. 
DROP TRIGGER IF EXISTS scheduled_time_after_insert;
DELIMITER // 
CREATE TRIGGER scheduled_time_after_insert
AFTER INSERT
ON flight_delays.schedule_info
FOR EACH ROW
BEGIN
	IF NOT EXISTS(SELECT SCHEDULED_DEPARTURE,SCHEDULED_ARRIVAL
		  FROM scheduled_time_info
          WHERE SCHEDULED_DEPARTURE=NEW.SCHEDULED_DEPARTURE
                AND SCHEDULED_ARRIVAL=NEW.SCHEDULED_ARRIVAL)THEN
        INSERT INTO scheduled_time_info
        VALUES(NEW.SCHEDULED_DEPARTURE,NEW.SCHEDULED_ARRIVAL,TIMESTAMPDIFF(MINUTE, NEW.SCHEDULED_DEPARTURE,NEW.SCHEDULED_ARRIVAL));
	
	END IF;
END//
DELIMITER ;

-- Trigger test
INSERT INTO schedule_info
VALUES(2015,1,1,'AA',2323644,'LAX','PBI','00:10',1000,'23:59');

SELECT * 
FROM scheduled_time_info
WHERE SCHEDULED_DEPARTURE = '00:10'
		AND SCHEDULED_ARRIVAL = '23:59';

-- Trigger 2
-- This trigger gives a backup information on updating delay_info table.
-- Create backup table
DROP TABLE IF EXISTS update_delay_change;
CREATE TABLE update_delay_change(
	MONTH INT, 
    DAY INT, 
    AIRLINE VARCHAR(100), 
    FLIGHT_NUMBER INT, 
    ORIGIN_AIRPORT VARCHAR(100), 
    DESTINATION_AIRPORT VARCHAR(100), 
    AIR_SYSTEM_DELAY INT, 
    SECURITY_DELAY INT, 
    AIRLINE_DELAY INT, 
    LATE_AIRCRAFT_DELAY INT, 
    WEATHER_DELAY INT,
    changing_time DATETIME);

DROP TRIGGER IF EXISTS backup_update_delay_info;
CREATE  TRIGGER backup_update_delay_info
AFTER UPDATE
ON delay_info
FOR EACH ROW
INSERT INTO update_delay_change(
	MONTH, 
    DAY, 
    AIRLINE, 
    FLIGHT_NUMBER, 
    ORIGIN_AIRPORT, 
    DESTINATION_AIRPORT, 
    AIR_SYSTEM_DELAY, 
    SECURITY_DELAY, 
    AIRLINE_DELAY, 
    LATE_AIRCRAFT_DELAY, 
    WEATHER_DELAY,
    changing_time)
VALUES(
	OLD.MONTH,
	OLD.DAY,
	OLD.AIRLINE,
	OLD.FLIGHT_NUMBER,
	OLD.ORIGIN_AIRPORT,
	OLD.DESTINATION_AIRPORT,
	OLD.AIR_SYSTEM_DELAY, 
    OLD.SECURITY_DELAY, 
    OLD.AIRLINE_DELAY, 
    OLD.LATE_AIRCRAFT_DELAY, 
    OLD.WEATHER_DELAY,
    NOW());


-- Trigger 3
-- This trigger gives a backup information on deleting schedule_info table
-- Create backup table
DROP TABLE IF EXISTS schedule_change;
CREATE TABLE schedule_change (
	original_YEAR INT,
    original_MONTH INT,
    original_DAY INT,
    original_AIRLINE VARCHAR(100),
    original_FLIGHT_NUMBER INT,
    original_ORIGIN_AIRPORT VARCHAR(100),
    original_DESTINATION_AIRPORT VARCHAR(100),
    original_SCHEDULED_DEPARTURE TIME,
    original_DISTANCE INT,
    original_SCHEDULED_ARRIVAL TIME,
    changing_time DATETIME
);


DROP TRIGGER IF EXISTS schedule_after_delete;
CREATE TRIGGER schedule_after_delete
AFTER DELETE 
ON schedule_info
FOR EACH ROW
INSERT INTO schedule_change
(original_YEAR,original_MONTH,original_DAY,original_AIRLINE,original_FLIGHT_NUMBER,
    original_ORIGIN_AIRPORT,original_DESTINATION_AIRPORT,original_SCHEDULED_DEPARTURE,
    original_DISTANCE,original_SCHEDULED_ARRIVAL,changing_time)
VALUES (
	OLD.YEAR,
	OLD.MONTH,
	OLD.DAY,
	OLD.AIRLINE,
	OLD.FLIGHT_NUMBER,
	OLD.ORIGIN_AIRPORT,
	OLD.DESTINATION_AIRPORT,
	OLD.SCHEDULED_DEPARTURE,
	OLD.DISTANCE,
	OLD.SCHEDULED_ARRIVAL,
	NOW() );

DELETE FROM schedule_info
WHERE MONTH=1
	  AND DAY=1
      AND AIRLINE='AA'
      AND FLIGHT_NUMBER=233644
      AND ORIGIN_AIRPORT= 'LAX'
      AND DESTINATION_AIRPORT='PBI';
