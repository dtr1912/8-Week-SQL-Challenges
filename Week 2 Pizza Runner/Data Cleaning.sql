-- Check table customer_orders
-- SELECT * FROM customer_orders
-- DESCRIBE customer_orders
-- Replace blank strings and Null (as text) with NULL and seperate string into rows
DROP TABLE IF EXISTS customer_orders_pre;
CREATE TEMPORARY TABLE customer_orders_pre AS (
  SELECT 
  	order_id,
  	customer_id,
  	pizza_id, 
  	CASE 
  		WHEN exclusions = '' THEN NULL
  		WHEN exclusions = 'null' THEN NULL
  		ELSE exclusions
  	END AS exclusions, 
  	CASE 
  		WHEN extras = '' THEN NULL
  		WHEN extras = 'null' THEN NULL
  		ELSE extras
  	END AS extras,
  	order_time
  FROM customer_orders);
SELECT * FROM customer_orders_pre
DROP TABLE IF EXISTS customer_orders_cleaned;
CREATE TEMPORARY TABLE customer_orders_cleaned AS (
SELECT t.order_id,
       t.customer_id,
       t.pizza_id,
	   trim(j1.exclusions) as exclusions,
       trim(j2.extras) as extras,
       t.order_time
FROM customer_orders_pre t
INNER JOIN JSON_TABLE(trim(replace(json_array(t.exclusions),',','","')), '$[*]' columns (exclusions varchar(5) path '$')) j1
INNER JOIN JSON_TABLE(trim(replace(json_array(t.extras),',','","')),'$[*]' columns (extras varchar(5) path '$')) j2
);
SELECT * FROM customer_orders_cleaned
-- Check table runner_orders 
-- SELECT * FROM runnner_orders
-- DESCRIBE runner_orders 
-- replace blank or null as text with NULL type and remove the text from the stringed numerical values.
DROP TABLE IF EXISTS runner_orders_pre;
CREATE TEMPORARY TABLE runner_orders_pre AS(
SELECT
	order_id,
	runner_id,
	CASE
		WHEN pickup_time = 'null' or pickup_time='' THEN NULL
		ELSE pickup_time
	END AS pickup_time,
	CASE
		WHEN distance = 'null' or distance='' THEN NULL
		ELSE regexp_replace(distance, '[a-z]+', '')
	END AS distance_km,
	CASE
		WHEN duration = 'null' or duration='' THEN NULL
		ELSE regexp_replace(duration, '[a-z]+', '')
		END AS duration_mins,
	CASE
		WHEN cancellation = '' or cancellation = 'null'  THEN NULL
		ELSE cancellation
		END AS cancellation               
FROM runner_orders);
SELECT * FROM runner_orders_pre;
-- Changing data type 
-- Using CAST function
DROP TABLE IF EXISTS runner_orders_cleaned;
CREATE TEMPORARY TABLE runner_orders_cleaned AS (
	SELECT
		order_id,
		runner_id,
		CAST(pickup_time AS datetime) AS pickup_time,
		CAST(distance_km AS DECIMAL(3,1)) AS distance_km, 
		CAST(duration_mins AS SIGNED INT) AS duration_mins,
		cancellation
    FROM runner_orders_pre);
SELECT * FROM runner_orders_cleaned
-- Check table pizza_recipes
-- SELECT * FROM pizza_recipes
-- DESCRIBE pizza_recipes
-- Expanding the comma seperated string into rows
DROP TABLE IF EXISTS pizza_recipes_cleaned; 
CREATE TEMPORARY TABLE pizza_recipes_cleaned(
SELECT p.pizza_id,
trim(j3.topping) as topping
FROM pizza_recipes p 
JOIN JSON_TABLE(TRIM(REPLACE(JSON_ARRAY(p.toppings),',','","')),'$[*]' columns (topping varchar(50) path '$')) j3
);
SELECT * FROM pizza_recipes_cleaned
-- Check table runners
-- SELECT * FROM runners
-- DESCRIBE runner
-- Check table pizza_names 
-- SELECT * FROM pizza_names 
-- DESCRIBE pizza_names
-- Check table pizza_toppings
-- SELECT * FROM pizza_toppings
-- DESCIRBE pizza_toppings
SELECT * FROM pizza_recipes
