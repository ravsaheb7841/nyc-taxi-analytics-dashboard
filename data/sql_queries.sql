-- Query 0: Sample Data Preview
-- Fetches 10 sample records to understand the raw data structure, column formats, and value ranges before performing detailed analysis
SELECT 
  pickup_datetime,
  dropoff_datetime,
  trip_distance,
  fare_amount,
  total_amount
FROM `bigquery-public-data.new_york.tlc_yellow_trips_2015`
LIMIT 10;


-- Query 1: Peak Hours Analysis
-- Identifies the busiest hours of the day based on trip volume
SELECT 
  EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
  COUNT(*) AS total_trips,
  ROUND(AVG(total_amount), 2) AS avg_revenue_per_hour
FROM `bigquery-public-data.new_york.tlc_yellow_trips_2015`
GROUP BY pickup_hour
ORDER BY total_trips DESC
LIMIT 5;


-- Query 2: Weekly Trend Analysis
-- Shows which day of the week has the highest trip volume
SELECT 
  FORMAT_DATE('%A', DATE(pickup_datetime)) AS day_of_week,
  COUNT(*) AS total_trips,
  ROUND(AVG(trip_distance), 2) AS avg_distance
FROM `bigquery-public-data.new_york.tlc_yellow_trips_2015`
GROUP BY day_of_week
ORDER BY total_trips DESC;


-- Query 3: Monthly Revenue Analysis
-- Identifies which months generate the highest revenue
SELECT 
  EXTRACT(MONTH FROM pickup_datetime) AS pickup_month,
  COUNT(*) AS total_trips,
  ROUND(SUM(total_amount), 2) AS total_revenue,
  ROUND(AVG(total_amount), 2) AS avg_fare
FROM `bigquery-public-data.new_york.tlc_yellow_trips_2015`
GROUP BY pickup_month
ORDER BY total_revenue DESC
LIMIT 10;


-- Query 4: Payment Type Analysis
-- Shows payment method preferences and average tip amounts
SELECT 
  payment_type,
  CASE 
    WHEN payment_type = '1' THEN 'Credit Card'
    WHEN payment_type = '2' THEN 'Cash'
    WHEN payment_type = '3' THEN 'No Charge'
    WHEN payment_type = '4' THEN 'Dispute'
    ELSE 'Unknown'
  END AS payment_method_name,
  COUNT(*) AS total_trips,
  ROUND(AVG(tip_amount), 2) AS avg_tip
FROM `bigquery-public-data.new_york.tlc_yellow_trips_2015`
GROUP BY payment_type
ORDER BY total_trips DESC;


-- Query 5: Distance Analysis
-- Calculates min, max, average, median, and 90th percentile of trip distances
SELECT 
  MIN(trip_distance) AS min_distance,
  MAX(trip_distance) AS max_distance,
  ROUND(AVG(trip_distance), 2) AS avg_distance
FROM `bigquery-public-data.new_york.tlc_yellow_trips_2015`
WHERE trip_distance > 0 AND trip_distance < 100;


-- Query 6: Vendor Performance Comparison
-- Compares two taxi vendors based on trips, revenue, and average metrics
SELECT 
  vendor_id,
  COUNT(*) AS total_trips,
  ROUND(SUM(total_amount), 2) AS total_revenue,
  ROUND(AVG(trip_distance), 2) AS avg_distance,
  ROUND(AVG(total_amount), 2) AS avg_fare
FROM `bigquery-public-data.new_york.tlc_yellow_trips_2015`
GROUP BY vendor_id
ORDER BY total_revenue DESC;


-- Query 7: Top Pickup Locations
-- Identifies the most popular pickup zones using JOIN with taxi_zone table
SELECT 
  zones.zone_name AS pickup_zone,
  COUNT(*) AS trip_count
FROM `bigquery-public-data.new_york.tlc_yellow_trips_2015` AS trips
JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` AS zones
  ON ST_Within(
      ST_GeogPoint(trips.pickup_longitude, trips.pickup_latitude),
      zones.zone_geom
  )
WHERE trips.pickup_longitude IS NOT NULL 
  AND trips.pickup_latitude IS NOT NULL
  AND trips.pickup_longitude BETWEEN -180 AND 180
  AND trips.pickup_latitude BETWEEN -90 AND 90
  AND EXTRACT(MONTH FROM trips.pickup_datetime) = 1
GROUP BY pickup_zone
ORDER BY trip_count DESC
LIMIT 10;


-- Query 8: Average Fare by Passenger Count
-- Analyzes how passenger count affects average fare
SELECT 
  passenger_count,
  COUNT(*) AS total_trips,
  ROUND(AVG(fare_amount), 2) AS avg_fare,
  ROUND(AVG(trip_distance), 2) AS avg_distance
FROM `bigquery-public-data.new_york.tlc_yellow_trips_2015`
WHERE passenger_count > 0
GROUP BY passenger_count
ORDER BY passenger_count;