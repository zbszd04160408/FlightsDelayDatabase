-- Dong Chen & Weiqing Huang
-- Project 2 Procedures Part

USE flight_delays;
-- Procedure 1
-- Find Flights Information
-- In this function, users can specify an origin airport and a destination airport, and a schedule information of 
-- all the flights that flights from the origin airport to the destination airport will be shown up here.
DROP PROCEDURE IF EXISTS findAirlineInfo;
DELIMITER //
CREATE  PROCEDURE findAirlineInfo(origin VARCHAR(100), destination VARCHAR(100))
BEGIN
  
    SELECT DISTINCT AIRLINE, FLIGHT_NUMBER, s1.SCHEDULED_DEPARTURE, s1.SCHEDULED_ARRIVAL, SCHEDULED_TIME
    FROM schedule_info s1
		JOIN scheduled_time_info  s2 ON s1.SCHEDULED_DEPARTURE = s2.SCHEDULED_DEPARTURE AND s1.SCHEDULED_ARRIVAL = s2.SCHEDULED_ARRIVAL
    WHERE s1.ORIGIN_AIRPORT = origin AND s1.DESTINATION_AIRPORT = destination;
    
END //
DELIMITER ;

-- Test call
CALL findAirlineInfo('SFO', 'LAX');

-- Procedure 2
-- Find Flights Delay Information
-- In this function, users can find out delayed information by entering the airline and  flight number.
DROP PROCEDURE IF EXISTS findFlightsDelayInfo;
DELIMITER //
CREATE  PROCEDURE findFlightsDelayInfo(al VARCHAR(100), fn VARCHAR(100))
BEGIN
    SELECT s.AIRLINE, s.FLIGHT_NUMBER, d2.DEPARTURE_DELAY, d1.ARRIVAL_DELAY
    FROM schedule_info AS s 
		JOIN real_info AS R ON s.MONTH=r.MONTH AND s.DAY=r.DAY AND s.AIRLINE=r.AIRLINE AND
			s.FLIGHT_NUMBER=r.FLIGHT_NUMBER AND s.ORIGIN_AIRPORT=r.ORIGIN_AIRPORT AND s.DESTINATION_AIRPORT=r.DESTINATION_AIRPORT
		JOIN arrival_delay AS d1 ON s.SCHEDULED_ARRIVAL=d1.SCHEDULED_ARRIVAL AND r.ARRIVAL_TIME=d1.ARRIVAL_TIME
        JOIN departure_delay AS d2 ON s.SCHEDULED_DEPARTURE=d2.SCHEDULED_DEPARTURE AND r.DEPARTURE_TIME=d2.DEPARTURE_TIME
    WHERE s.AIRLINE = al and s.FLIGHT_NUMBER = fn;
END //
DELIMITER ;

-- Test call
CALL findFlightsDelayInfo("UA", "544");

-- Procedure 3
-- Insert A New Flight Information
-- In this function, users can insert a new flight information into schedule_info table.
DROP PROCEDURE IF EXISTS insert_schedule_info;
DELIMITER //
CREATE  PROCEDURE insert_schedule_info(
	var_YEAR INT,
    var_MONTH INT,
    var_DAY INT,
    var_AIRLINE VARCHAR(100),
    var_FLIGHT_NUMBER INT,
    var_ORIGIN_AIRPORT VARCHAR(100),
    var_DESTINATION_AIRPORT VARCHAR(100),
    var_SCHEDULED_DEPARTURE TIME,
    var_DISTANCE INT,
    var_SCHEDULED_ARRIVAL TIME)
BEGIN
# Set conditions
IF EXISTS(SELECT YEAR,MONTH,DAY,AIRLINE,FLIGHT_NUMBER,ORIGIN_AIRPORT,
				DESTINATION_AIRPORT,SCHEDULED_DEPARTURE,DISTANCE,SCHEDULED_ARRIVAL
		  FROM schedule_info
          WHERE var_MONTH = MONTH
                AND var_DAY = DAY
                AND var_AIRLINE =AIRLINE
                AND var_FLIGHT_NUMBER = FLIGHT_NUMBER
                AND var_ORIGIN_AIRPORT = ORIGIN_AIRPORT
                AND var_DESTINATION_AIRPORT = DESTINATION_AIRPORT) THEN
	SELECT 'This flight infomation already exists, please try another one! ' AS message;
ELSE
	INSERT INTO schedule_info
	VALUES (var_YEAR,var_MONTH,var_DAY,var_AIRLINE,var_FLIGHT_NUMBER,var_ORIGIN_AIRPORT,
			var_DESTINATION_AIRPORT,var_SCHEDULED_DEPARTURE,var_DISTANCE,var_SCHEDULED_ARRIVAL);
	SELECT 'Success! ' AS message;
END IF;
END//
DELIMITER ;

-- Test call
CALL insert_schedule_info(2015,1,1,'AA',2336,'LAX','PBI','00:10',1000,'00:40');

-- Procedurec 4
-- Update Delayed Information
-- In this function, users can update a flight’s delayed information. 
DROP PROCEDURE IF EXISTS update_delay_info;
DELIMITER //
CREATE  PROCEDURE update_delay_info(
	var_MONTH INT, 
    var_DAY INT, 
    var_AIRLINE VARCHAR(100), 
    var_FLIGHT_NUMBER INT, 
    var_ORIGIN_AIRPORT VARCHAR(100), 
    var_DESTINATION_AIRPORT VARCHAR(100), 
    var_AIR_SYSTEM_DELAY INT, 
    var_SECURITY_DELAY INT, 
    var_AIRLINE_DELAY INT, 
    var_LATE_AIRCRAFT_DELAY INT, 
    var_WEATHER_DELAY INT)
BEGIN
# Set conditions
IF EXISTS(SELECT *
		  FROM schedule_info AS s 
				JOIN real_info AS R ON s.MONTH=r.MONTH AND s.DAY=r.DAY AND s.AIRLINE=r.AIRLINE AND
					s.FLIGHT_NUMBER=r.FLIGHT_NUMBER AND s.ORIGIN_AIRPORT=r.ORIGIN_AIRPORT AND s.DESTINATION_AIRPORT=r.DESTINATION_AIRPORT
				JOIN arrival_delay AS d ON s.SCHEDULED_ARRIVAL=d.SCHEDULED_ARRIVAL AND r.ARRIVAL_TIME=d.ARRIVAL_TIME
          WHERE var_MONTH = s.MONTH
                AND var_DAY = s.DAY
                AND var_AIRLINE =s.AIRLINE
                AND var_FLIGHT_NUMBER = s.FLIGHT_NUMBER
                AND var_ORIGIN_AIRPORT = s.ORIGIN_AIRPORT
                AND var_DESTINATION_AIRPORT = s.DESTINATION_AIRPORT
                AND var_AIR_SYSTEM_DELAY+var_SECURITY_DELAY+var_AIRLINE_DELAY+var_LATE_AIRCRAFT_DELAY+var_WEATHER_DELAY=ARRIVAL_DELAY) THEN
	UPDATE delay_info
	SET AIR_SYSTEM_DELAY=var_AIR_SYSTEM_DELAY,
		SECURITY_DELAY=var_SECURITY_DELAY,
        AIRLINE_DELAY=var_AIRLINE_DELAY,
        LATE_AIRCRAFT_DELAY=var_LATE_AIRCRAFT_DELAY,
        WEATHER_DELAY=var_WEATHER_DELAY
	WHERE MONTH= var_MONTH
		  AND DAY = var_DAY
          AND AIRLINE=var_AIRLINE
          AND FLIGHT_NUMBER=var_FLIGHT_NUMBER
          AND ORIGIN_AIRPORT=var_ORIGIN_AIRPORT
          AND DESTINATION_AIRPORT=var_DESTINATION_AIRPORT;
	SELECT 'Success! ' AS message;
ELSE
	SELECT 'The sum of delay time you input is not equal to total delay time.' AS message;
END IF;
END//
DELIMITER ;

-- Test call
CALL update_delay_info(1,1,'DL',2440,'SEA','MSP',1,2,3,4,5);

-- Procedure 4 - Additional 
-- Get arrival delay information from the primary key
DROP PROCEDURE IF EXISTS select_delay_info;
DELIMITER //
CREATE  PROCEDURE select_delay_info(
	var_MONTH INT, 
    var_DAY INT, 
    var_AIRLINE VARCHAR(100), 
    var_FLIGHT_NUMBER INT, 
    var_ORIGIN_AIRPORT VARCHAR(100), 
    var_DESTINATION_AIRPORT VARCHAR(100))
BEGIN
SELECT ARRIVAL_DELAY
FROM schedule_info AS s 
	JOIN real_info AS R ON s.MONTH=r.MONTH AND s.DAY=r.DAY AND s.AIRLINE=r.AIRLINE AND
		s.FLIGHT_NUMBER=r.FLIGHT_NUMBER AND s.ORIGIN_AIRPORT=r.ORIGIN_AIRPORT AND s.DESTINATION_AIRPORT=r.DESTINATION_AIRPORT
	JOIN arrival_delay AS d ON s.SCHEDULED_ARRIVAL=d.SCHEDULED_ARRIVAL AND r.ARRIVAL_TIME=d.ARRIVAL_TIME
WHERE var_MONTH = s.MONTH
	AND var_DAY = s.DAY
	AND var_AIRLINE =s.AIRLINE
	AND var_FLIGHT_NUMBER = s.FLIGHT_NUMBER
	AND var_ORIGIN_AIRPORT = s.ORIGIN_AIRPORT
	AND var_DESTINATION_AIRPORT = s.DESTINATION_AIRPORT;
END //
DELIMITER ;

-- Test call
CALL select_delay_info(1,1,'DL',2440,'SEA','MSP');

-- Procedure 5
-- Delete An Existed Flight
-- In this function, users can delete a flight information by specifying the airline, flight number, origin airport, destination airport, and the date of the flight.
DROP PROCEDURE IF EXISTS deleteAirlineInfo;
DELIMITER //
CREATE  PROCEDURE deleteAirlineInfo(var_MONTH INT, 
									var_DAY INT, 
									var_AIRLINE VARCHAR(100), 
									var_FLIGHT_NUMBER INT, 
									var_ORIGIN_AIRPORT VARCHAR(100), 
									var_DESTINATION_AIRPORT VARCHAR(100))
BEGIN
# Set conditions
IF EXISTS(SELECT *
	FROM schedule_info AS s 
		  WHERE var_MONTH = s.MONTH
				AND var_DAY = s.DAY
				AND var_AIRLINE =s.AIRLINE
				AND var_FLIGHT_NUMBER = s.FLIGHT_NUMBER
				AND var_ORIGIN_AIRPORT = s.ORIGIN_AIRPORT
				AND var_DESTINATION_AIRPORT = s.DESTINATION_AIRPORT) THEN  
	DELETE FROM schedule_info
	WHERE var_MONTH=MONTH
	AND var_DAY=DAY
		  AND var_AIRLINE=AIRLINE
		  AND var_FLIGHT_NUMBER=FLIGHT_NUMBER
		  AND var_ORIGIN_AIRPORT=ORIGIN_AIRPORT
		  AND var_DESTINATION_AIRPORT=DESTINATION_AIRPORT;
	SELECT 'Success! ' AS message;
ELSE 
	SELECT 'The flight you input does not exist!' AS message;
END IF;    
END //
DELIMITER ;

-- Test call
CALL deleteAirlineInfo(1,1,'DL',2440,'SEA','MSP');