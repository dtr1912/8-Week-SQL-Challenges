-- 1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
WITH temp AS 
(SELECT pizza_name, COUNT(c.pizza_id) as 'number_of_pizza',
(CASE WHEN pizza_name = 'Meatlovers' THEN 12
WHEN pizza_name = 'Vegetarian' THEN 10
ELSE NULL 
END) as price 
from customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id =r1.order_id
JOIN pizza_names p1 ON  c.pizza_id = p1.pizza_id
WHERE cancellation is null
GROUP BY pizza_name
)
SELECT  CONCAT(SUM(number_of_pizza*price),'$') as total_sale
FROM temp
-- 2.What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra
DROP TABLE IF EXISTS pizza_price;
CREATE TEMPORARY TABLE pizza_price AS 
(SELECT 
SUM(CASE WHEN pizza_name = 'Meatlovers' THEN 12
WHEN pizza_name = 'Vegetarian' THEN 10
ELSE ''
END) as total
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id =r1.order_id
JOIN pizza_names p1 ON c.pizza_id = p1.pizza_id
WHERE cancellation is null 
)
DROP TABLE IF EXISTS pizza_extra;
CREATE TEMPORARY TABLE pizza_extra AS 
(SELECT COUNT(extra) total
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id =r1.order_id
JOIN JSON_TABLE(TRIM(REPLACE(JSON_ARRAY(c.extras),',','","')),'$[*]' columns(extra varchar(5) path '$')) j
WHERE cancellation is null 
)
WITH temp AS 
(SELECT total 
FROM pizza_price
UNION 
SELECT total 
FROm pizza_extra)
SELECT SUM(total) as total_sales
FROM temp
-- 3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings 
(rating
-- 4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas
-- 5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?