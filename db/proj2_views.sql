-- Dong Chen & Weiqing Huang
-- Project 2 Views Part

USE flight_delays;
-- View 1
-- View Airline Delay Information
-- In this function, users could look up the delayed flight count and average delayed time of each airline.
DROP VIEW IF EXISTS airline_delay_summary;
CREATE VIEW airline_delay_summary AS
	SELECT s.AIRLINE, count(ARRIVAL_DELAY) AS delay_count, AVG(ARRIVAL_DELAY) AS delay_average
    FROM schedule_info AS s 
		JOIN real_info AS R ON s.MONTH=r.MONTH AND s.DAY=r.DAY AND s.AIRLINE=r.AIRLINE AND
			s.FLIGHT_NUMBER=r.FLIGHT_NUMBER AND s.ORIGIN_AIRPORT=r.ORIGIN_AIRPORT AND s.DESTINATION_AIRPORT=r.DESTINATION_AIRPORT
		JOIN arrival_delay AS d ON s.SCHEDULED_ARRIVAL=d.SCHEDULED_ARRIVAL AND r.ARRIVAL_TIME=d.ARRIVAL_TIME
	WHERE ARRIVAL_DELAY > 0
	GROUP BY AIRLINE;

-- Check the view
SELECT *
FROM airline_delay_summary;
 
-- View 2
-- View Airport Delay Information
-- In this function, users could look up the delayed flight count and average delayed time of each airport. 
-- For each airport, the departure delay and arrival delay is calculated separately.
DROP VIEW IF EXISTS airport_delay_summary;
CREATE VIEW airport_delay_summary AS
	SELECT ORIGIN_AIRPORT as AIRPORT, departure_delay_count, departure_delay_average, arrival_delay_count, arrival_delay_average
    FROM (
		SELECT s.ORIGIN_AIRPORT, count(DEPARTURE_DELAY) as departure_delay_count, AVG(DEPARTURE_DELAY) AS departure_delay_average
		FROM schedule_info AS s 
			JOIN real_info AS R ON s.MONTH=r.MONTH AND s.DAY=r.DAY AND s.AIRLINE=r.AIRLINE AND s.FLIGHT_NUMBER=r.FLIGHT_NUMBER AND 
				 s.ORIGIN_AIRPORT=r.ORIGIN_AIRPORT AND s.DESTINATION_AIRPORT=r.DESTINATION_AIRPORT
			JOIN departure_delay AS d ON s.SCHEDULED_DEPARTURE=d.SCHEDULED_DEPARTURE AND r.DEPARTURE_TIME=d.DEPARTURE_TIME
		WHERE DEPARTURE_DELAY > 0
		GROUP BY ORIGIN_AIRPORT
	) a1
    JOIN (
		SELECT s.DESTINATION_AIRPORT, count(ARRIVAL_DELAY) AS arrival_delay_count, AVG(ARRIVAL_DELAY) AS arrival_delay_average
		FROM schedule_info AS s 
			JOIN real_info AS R ON s.MONTH=r.MONTH AND s.DAY=r.DAY AND s.AIRLINE=r.AIRLINE AND s.FLIGHT_NUMBER=r.FLIGHT_NUMBER AND 
				s.ORIGIN_AIRPORT=r.ORIGIN_AIRPORT AND s.DESTINATION_AIRPORT=r.DESTINATION_AIRPORT
			JOIN arrival_delay AS d ON s.SCHEDULED_ARRIVAL=d.SCHEDULED_ARRIVAL AND r.ARRIVAL_TIME=d.ARRIVAL_TIME
		 WHERE ARRIVAL_DELAY > 0
		 GROUP BY DESTINATION_AIRPORT
	)  a2 ON a1.ORIGIN_AIRPORT = a2.DESTINATION_AIRPORT;

-- Check the view
SELECT *
FROM airport_delay_summary;
 