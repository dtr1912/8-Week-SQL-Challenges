-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT week(registration_date + interval 2 day) as number_of_week, min(registration_date) start_day,
count(runner_id) number_of_runner
FROM runners
GROUP BY number_of_week
-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT runner_id, ROUND(AVG(TIMESTAMPDIFF(minute, order_time, pickup_time)))
FROM runner_orders_cleaned r1
JOIN customer_orders_pre c ON r1.order_id = c.order_id
WHERE cancellation IS NULL 
GROUP BY runner_id
-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT c.order_id, count(c.pizza_id), ROUND(TIMESTAMPDIFF(minute,order_time,pickup_time))
FROM runner_orders_cleaned r1
JOIN customer_orders_pre c ON r1.order_id = c.order_id
WHERE cancellation is null
GROUP BY c.order_id
-- CMT: The number of pizzas is proportional to the preparation time
-- What was the average distance travelled for each customer?
SELECT c.customer_id, ROUND(AVG(distance_km))
FROM runner_orders_cleaned r1
JOIN customer_orders_pre c ON r1.order_id = c.order_id
WHERE cancellation IS NULL 
GROUP BY customer_id
-- What was the difference between the longest and shortest delivery times for all orders?
SELECT 
	MAX(duration_mins) AS longest_delivery_time, 
	MIN(duration_mins) AS shortest_delivery_time,
	MAX(duration_mins) - MIN(duration_mins) AS time_diff
FROM runner_orders_cleaned;
WHERE cancellation IS NULL 
-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, CONCAT(ROUND(AVG(distance_km/(duration_mins/60))), '(km/h)') Speed
FROM runner_orders_cleaned r1
WHERE cancellation IS NULL 
GROUP BY runner_id
-- What is the successful delivery percentage for each runner ?
WITH temp AS 
(SELECT runner_id,
SUM(
CASE WHEN cancellation IS NULL THEN 1
ELSE 0
END) AS success,
SUM(CASE WHEN cancellation IS NULL THEN 0 
ELSE 1
END) AS no_success, 
COUNT(order_id) all_order
FROM runner_orders_cleaned
GROUP BY runner_id
)
SELECT t.runner_id, CONCAT(ROUND((success/all_order)*100),'%') as 'Percentage of successfull delivery'
FROM temp t



