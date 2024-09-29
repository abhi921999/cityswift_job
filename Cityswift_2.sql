SELECT * FROM [cityswift_insight].[dbo].[public_transport_data]

-- To check if there are null values
SELECT * FROM [cityswift_insight].[dbo].[public_transport_data]
WHERE AVL_id IS NULL OR Ticket_id IS NULL  OR Bus_id IS NULL
OR Driver_id IS NULL OR Route_id IS NULL OR Timestamp IS NULL
OR Bus_Speed IS NULL OR Passenger_Count IS NULL OR Scheduled_Time IS NULL
OR Actual_Time IS NULL;

--checking duplicacy
DELETE FROM [cityswift_insight].[dbo].[public_transport_data]
WHERE AVL_id NOT IN (
    SELECT MIN(AVL_id)
    FROM public_transport_data
    GROUP BY Ticket_id, Schedule_id, Bus_id, Driver_id, Route_id, Timestamp
);

--top 10 routes with the most delays and their respective average delay times.
SELECT top 10 Route_id,
 AVG(Route_Delay) AS Average_Delay
FROM public_transport_data
GROUP BY Route_id
ORDER BY Average_Delay DESC

--Time of Day Analysis
SELECT Route_id,  AVG(Route_Delay) AS Average_Delay, DATEPART(HOUR, Timestamp) AS Hour_of_Day
FROM public_transport_data
WHERE Route_id IN (88, 65, 73, 38, 83, 54, 14, 48, 57, 58)
GROUP BY Route_id, DATEPART(HOUR, Timestamp)
ORDER BY Route_id, Hour_of_Day;


--Driver Performance Metrics
SELECT Driver_id,  AVG(Route_Delay) AS Avg_Delay,  AVG(Bus_Fuel_Consumption) AS Avg_Fuel_Consumption,
AVG(Bus_Behavior_Score) AS Avg_Behavior_Score
FROM public_transport_data
GROUP BY Driver_id
ORDER BY Avg_Behavior_Score DESC, Avg_Delay ASC, Avg_Fuel_Consumption ASC;

--Analyze Passenger Demand by Day of the Week
SELECT DATEPART(WEEKDAY, Timestamp) AS Day_of_Week, SUM(Passenger_Count) AS Total_Passenger_Count,
 AVG(Passenger_Count) AS Avg_Passenger_Count
FROM public_transport_data
GROUP BY DATEPART(WEEKDAY, Timestamp)
ORDER BY Total_Passenger_Count DESC;

--Analyze Passenger Demand by hour
SELECT DATEPART(HOUR, Timestamp) AS Hour_of_Day,  SUM(Passenger_Count) AS Total_Passenger_Count,
 AVG(Passenger_Count) AS Avg_Passenger_Count
FROM public_transport_data
GROUP BY DATEPART(HOUR, Timestamp)
ORDER BY Total_Passenger_Count DESC;

--Fuel Efficiency Optimization
SELECT Route_id,  Bus_id, AVG(Bus_Fuel_Consumption) AS Avg_Fuel_Consumption
FROM public_transport_data
GROUP BY Route_id, Bus_id
ORDER BY Avg_Fuel_Consumption DESC;

--Schedule Adherence
SELECT Route_id,  COUNT(*) AS Total_Trips, SUM(CASE WHEN Actual_Time <= Scheduled_Time THEN 1 ELSE 0 END) AS On_Time_Trips,
(SUM(CASE WHEN Actual_Time <= Scheduled_Time THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS Adherence_Rate
FROM public_transport_data
GROUP BY Route_id
ORDER BY Adherence_Rate DESC;

--kpis
SELECT CAST(Timestamp AS DATE) AS Date,
 COUNT(*) AS Total_Trips,  AVG(Route_Delay) AS Avg_Delay, AVG(Bus_Fuel_Consumption) AS Avg_Fuel_Consumption,  SUM(Passenger_Count) AS Total_Passenger_Count
FROM public_transport_data
GROUP BY CAST(Timestamp AS DATE)
ORDER BY Date DESC;

--Query to retrieve bus trips where the route delay is greater than 30 minutes.
SELECT Bus_id, Route_id, Passenger_Count, Route_Delay
FROM public_transport_data
WHERE Route_Delay > 30
ORDER BY Route_Delay DESC;

-- Query to find routes with an average delay greater than 15 minutes
SELECT Route_id, AVG(Route_Delay) AS Avg_Delay
FROM public_transport_data
GROUP BY Route_id
HAVING AVG(Route_Delay) > 15
ORDER BY Avg_Delay DESC;

---- Query to retrieve trips for routes that have an average delay greater than the overall system average
SELECT Bus_id, Route_id, Route_Delay
FROM public_transport_data
WHERE Route_id IN ( SELECT Route_id FROM public_transport_data
    GROUP BY Route_id
    HAVING AVG(Route_Delay) > (
        SELECT AVG(Route_Delay)
        FROM public_transport_data
    )
)
ORDER BY Route_Delay DESC;

---- Query to find the trip with the highest delay for each route
WITH RankedTrips AS (
 SELECT Route_id, Bus_id, Route_Delay,
  ROW_NUMBER() OVER (PARTITION BY Route_id ORDER BY Route_Delay DESC) AS row_num
  FROM public_transport_data
)
SELECT Route_id, Bus_id, Route_Delay
FROM RankedTrips
WHERE row_num = 1;

---- Query to classify trips based on delay and count the number of trips in each category
SELECT CASE 
        WHEN Route_Delay = 0 THEN 'On Time'
        WHEN Route_Delay BETWEEN 1 AND 15 THEN 'Slight Delay'
        WHEN Route_Delay BETWEEN 16 AND 30 THEN 'Moderate Delay'
        ELSE 'Severe Delay'
 END AS Delay_Category, COUNT(*) AS Trip_Count
FROM public_transport_data
GROUP BY  CASE 
        WHEN Route_Delay = 0 THEN 'On Time'
        WHEN Route_Delay BETWEEN 1 AND 15 THEN 'Slight Delay'
        WHEN Route_Delay BETWEEN 16 AND 30 THEN 'Moderate Delay'
        ELSE 'Severe Delay'
 END;











