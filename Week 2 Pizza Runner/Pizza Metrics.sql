-- A. Pizza Metrics
-- How many pizzas were ordered?
SELECT COUNT(order_id) AS 'Total number of pizza ordered'
FROM customer_orders_cleaned
-- How many unique customer orders were made?
SELECT COUNT(DISTINCT(order_id)) as 'Number of unique order'
FROM customer_orders_cleaned
-- How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) as 'Number of successful orders'
FROM runner_orders_cleaned
WHERE cancellation IS NULL
GROUP BY runner_id 
-- How many of each type of pizza was delivered?
SELECT c.pizza_id, count(pizza_id) as 'Number of pizza was delivered'
FROM customer_orders_pre c
INNER JOIN runner_orders_cleaned r1 on c.order_id = r1.order_id
WHERE cancellation is null
GROUP BY pizza_id
-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id, pizza_name, count(p1.pizza_name)
FROM customer_orders_pre c
JOIN pizza_names p1 ON c.pizza_id = p1.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id
-- What was the maximum number of pizzas delivered in a single order?
SELECT r1.order_id, count(c.pizza_id) as s_pizza
FROM customer_orders_pre c
INNER JOIN runner_orders_cleaned r1 ON c.order_id= r1.order_id
WHERE cancellation IS NULL
GROUP BY r1.order_id
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT c.customer_id, pizza_id, 
SUM(CASE WHEN exclusions is NULL and extras is NULL then 1  -- If no change then value 1 else 0
else 0
end ) no_change,
SUM(CASE WHEN exclusions is NULL and extras is NULL then 0  -- If no change then value 0 else 1
else 1
end ) had_change
FROM customer_orders_pre c
INNER JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
WHERE cancellation is NULL
GROUP BY customer_id
ORDER BY customer_id
-- How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(c.order_id) as 'Number of pizza had both exclusions and extras'
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id 
WHERE cancellation is null and exclusions is not null and extras is not null
-- What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time) , count(pizza_id)
FROM customer_orders_pre
GROUP BY hour(order_time)
ORDER BY count(pizza_id)
-- What was the volume of orders for each day of the week? 
SELECT DAYOFWEEK(order_time),DAYNAME(order_time),COUNT(order_id)
FROM customer_orders_pre
GROUP BY DAYOFWEEK(order_time)