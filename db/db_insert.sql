-- Dong Chen & Weiqing Huang
-- Project 2 Database Insert Part

-- Loading data part
-- Data website: https://www.kaggle.com/usdot/flight-delays
-- Notice that the where clause is because there has some bigs in the mega table. In order to ensure completeness, we added where clause. 
-- The sample data is not affected by this

-- Load data into schedule_info table
INSERT INTO schedule_info (
	SELECT YEAR,MONTH,DAY,AIRLINE,FLIGHT_NUMBER,ORIGIN_AIRPORT ,
			DESTINATION_AIRPORT,SCHEDULED_DEPARTURE,DISTANCE,SCHEDULED_ARRIVAL
	FROM flights
    WHERE SCHEDULED_TIME != '');

-- Load data into date_info table
INSERT INTO date_info (
	SELECT DISTINCT MONTH,DAY,DAY_OF_WEEK
	FROM flights
    WHERE SCHEDULED_TIME != '');
    
-- Load data into flight_info table
INSERT INTO flight_info (
	SELECT DISTINCT AIRLINE,FLIGHT_NUMBER,TAIL_NUMBER
	FROM flights
    WHERE SCHEDULED_TIME != '');
 
-- Load data into scheduled_time_info table
INSERT INTO scheduled_time_info (
	SELECT DISTINCT SCHEDULED_DEPARTURE,SCHEDULED_ARRIVAL,SCHEDULED_TIME
	FROM flights
    WHERE SCHEDULED_TIME != ''); 

-- Load data into real_info table
INSERT INTO real_info (
	SELECT MONTH, DAY, AIRLINE, FLIGHT_NUMBER, ORIGIN_AIRPORT, 
			DESTINATION_AIRPORT, DEPARTURE_TIME, WHEELS_OFF, 
			WHEELS_ON, ARRIVAL_TIME
	FROM flights
    WHERE CANCELLED = 0 AND SCHEDULED_TIME != '');

-- Load data into taxi_out_interval
INSERT INTO taxi_out_interval (
	SELECT DISTINCT DEPARTURE_TIME,WHEELS_OFF,TAXI_OUT
	FROM flights
    WHERE CANCELLED = 0 AND SCHEDULED_TIME != '');
    
-- Load data into taxi_in_interval
INSERT INTO taxi_in_interval (
	SELECT DISTINCT WHEELS_ON,ARRIVAL_TIME,TAXI_IN
	FROM flights
    WHERE CANCELLED = 0 AND SCHEDULED_TIME != ''
		AND WHEELS_ON IS NOT NULL);

-- Load data into air_time_interval
INSERT INTO air_time_interval (
	SELECT DISTINCT WHEELS_OFF,WHEELS_ON,AIR_TIME
	FROM flights
    WHERE CANCELLED = 0 AND SCHEDULED_TIME != '' AND AIR_TIME != ''
		AND WHEELS_ON IS NOT NULL);

-- Load data into elapsed_time_interval
INSERT INTO elapsed_time_interval (
	SELECT DISTINCT TAXI_OUT,AIR_TIME,TAXI_IN,ELAPSED_TIME
	FROM flights
    WHERE CANCELLED = 0 AND SCHEDULED_TIME != '' AND AIR_TIME != '');

-- Load data into departure_delay
INSERT INTO departure_delay (
	SELECT DISTINCT SCHEDULED_DEPARTURE,DEPARTURE_TIME,DEPARTURE_DELAY
	FROM flights
    WHERE CANCELLED = 0 AND SCHEDULED_TIME != '');
    
-- Load data into arrival_delay
INSERT INTO arrival_delay (
	SELECT DISTINCT SCHEDULED_ARRIVAL, ARRIVAL_TIME,ARRIVAL_DELAY
	FROM flights
    WHERE CANCELLED = 0 AND SCHEDULED_TIME != '' AND ARRIVAL_DELAY != '');

-- Load data into diverted_info table
INSERT INTO diverted_info (
	SELECT MONTH,DAY,AIRLINE,FLIGHT_NUMBER,ORIGIN_AIRPORT,DESTINATION_AIRPORT,DIVERTED
	FROM flights
    WHERE SCHEDULED_TIME != '');

-- Load data into cancelled_info table
INSERT INTO cancelled_info (
	SELECT MONTH,DAY,AIRLINE,FLIGHT_NUMBER,ORIGIN_AIRPORT,DESTINATION_AIRPORT,CANCELLED,CANCELLATION_REASON
	FROM flights
    WHERE SCHEDULED_TIME != '');
    
-- Load data into delay_info table
INSERT INTO delay_info (
	SELECT MONTH,DAY,AIRLINE,FLIGHT_NUMBER,ORIGIN_AIRPORT,DESTINATION_AIRPORT,
			SCHEDULED_ARRIVAL,ARRIVAL_TIME, AIR_SYSTEM_DELAY, SECURITY_DELAY, AIRLINE_DELAY,LATE_AIRCRAFT_DELAY, WEATHER_DELAY
	FROM flights
    WHERE CANCELLED = 0 AND SCHEDULED_TIME != '' AND AIR_SYSTEM_DELAY != '');
    
-- Join Back to flights data with decomposed tables
SELECT
	s.YEAR,
    s.MONTH,
    s.DAY,
    d2.DAY_OF_WEEK,
    s.AIRLINE,
    s.FLIGHT_NUMBER,
    f.TAIL_NUMBER,
    s.ORIGIN_AIRPORT,
    s.DESTINATION_AIRPORT,
    s.SCHEDULED_DEPARTURE,
    r.DEPARTURE_TIME,
    d3.DEPARTURE_DELAY,
    t1.TAXI_OUT,
    r.WHEELS_OFF,
    s2.SCHEDULED_TIME,
    e.ELAPSED_TIME,
    t3.AIR_TIME,
    s.DISTANCE,
    r.WHEELS_ON,
    t2.TAXI_IN,
    s.SCHEDULED_ARRIVAL,
    r.ARRIVAL_TIME,
    d1.ARRIVAL_DELAY,
    d4.DIVERTED,
    c.CANCELLED,
    c.CANCELLATION_REASON,
    d5.AIR_SYSTEM_DELAY,
    d5.SECURITY_DELAY,
    d5.AIRLINE_DELAY,
    d5.LATE_AIRCRAFT_DELAY,
    d5.WEATHER_DELAY
FROM schedule_info AS s 
		LEFT JOIN real_info AS r ON s.MONTH=r.MONTH AND s.DAY=r.DAY AND s.AIRLINE=r.AIRLINE AND
				s.FLIGHT_NUMBER=r.FLIGHT_NUMBER AND s.ORIGIN_AIRPORT=r.ORIGIN_AIRPORT AND s.DESTINATION_AIRPORT=r.DESTINATION_AIRPORT
		LEFT JOIN arrival_delay AS d1 ON s.SCHEDULED_ARRIVAL=d1.SCHEDULED_ARRIVAL AND r.ARRIVAL_TIME=d1.ARRIVAL_TIME 
        LEFT JOIN date_info AS d2 ON s.MONTH=d2.MONTH AND s.DAY=d2.DAY
        LEFT JOIN flight_info AS f ON s.AIRLINE=f.AIRLINE AND s.FLIGHT_NUMBER=f.FLIGHT_NUMBER
        LEFT JOIN scheduled_time_info AS s2 ON s.SCHEDULED_DEPARTURE=s2.SCHEDULED_DEPARTURE AND s.SCHEDULED_ARRIVAL=s2.SCHEDULED_ARRIVAL 
		LEFT JOIN taxi_out_interval AS t1 ON t1.DEPARTURE_TIME=r.DEPARTURE_TIME AND t1.WHEELS_OFF=r.WHEELS_OFF 
		LEFT JOIN taxi_in_interval AS t2 ON t2.ARRIVAL_TIME=r.ARRIVAL_TIME AND t2.WHEELS_ON=r.WHEELS_ON 
		LEFT JOIN air_time_interval AS t3 ON t3.WHEELS_OFF=r.WHEELS_OFF AND t3.WHEELS_ON = r.WHEELS_ON 
		LEFT JOIN elapsed_time_interval AS e ON e.TAXI_OUT=t1.TAXI_OUT AND e.TAXI_IN=t2.TAXI_IN AND e.AIR_TIME=t3.AIR_TIME
        LEFT JOIN departure_delay AS d3 ON s.SCHEDULED_DEPARTURE=d3.SCHEDULED_DEPARTURE AND r.DEPARTURE_TIME=d3.DEPARTURE_TIME 
		LEFT JOIN diverted_info AS d4 ON s.MONTH=d4.MONTH AND s.DAY=d4.DAY AND s.AIRLINE=d4.AIRLINE AND
				s.FLIGHT_NUMBER=d4.FLIGHT_NUMBER AND s.ORIGIN_AIRPORT=d4.ORIGIN_AIRPORT AND s.DESTINATION_AIRPORT=d4.DESTINATION_AIRPORT
		LEFT JOIN cancelled_info AS c ON s.MONTH=c.MONTH AND s.DAY=c.DAY AND s.AIRLINE=c.AIRLINE AND
				s.FLIGHT_NUMBER=c.FLIGHT_NUMBER AND s.ORIGIN_AIRPORT=c.ORIGIN_AIRPORT AND s.DESTINATION_AIRPORT=c.DESTINATION_AIRPORT
		LEFT JOIN delay_info AS d5 ON s.MONTH=d5.MONTH AND s.DAY=d5.DAY AND s.AIRLINE=d5.AIRLINE AND
				s.FLIGHT_NUMBER=d5.FLIGHT_NUMBER AND s.ORIGIN_AIRPORT=d5.ORIGIN_AIRPORT AND s.DESTINATION_AIRPORT=d5.DESTINATION_AIRPORT;
        