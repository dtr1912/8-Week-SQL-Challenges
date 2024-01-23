-- 1.What are the standard ingredients for each pizza?
SELECT p1.pizza_id, topping_name
FROM pizza_recipes_cleaned p1
JOIN pizza_toppings p2 ON p1.topping = p2.topping_id
-- 2.What was the most commonly added extra?
SELECT trim(j.extra) as extra,topping_name, COUNT(extra) as 'number of the most added extra'
FROM customer_orders_pre c 
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN pizza_toppings p2 ON c.extras = p2.topping_id
JOIN JSON_TABLE(TRIM(REPLACE(JSON_ARRAY(c.extras),',','","')),'$[*]' columns(extra varchar(5) path '$')) j
WHERE cancellation is null and extras is not null
GROUP BY extra
ORDER BY count(extra) DESC LIMIT 1
-- 3.What was the most common exclusion?
SELECT trim(j.exclusion) as exclusion,topping_name, COUNT(exclusion) as 'number of the most added exclusion'
FROM customer_orders_pre c 
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN pizza_toppings p2 ON c.exclusions = p2.topping_id
JOIN JSON_TABLE(TRIM(REPLACE(JSON_ARRAY(c.exclusions),',','","')),'$[*]' columns(exclusion varchar(5) path '$')) j
WHERE cancellation is null and exclusion is not null
GROUP BY exclusion
ORDER BY count(exclusion) DESC LIMIT 1
-- 4.Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
WITH item_order AS
(SELECT c.order_id, pizza_name,
(CASE WHEN extras is not null then 'Extra'
ELSE null
END) AS e1,
(CASE WHEN exclusions is not null then 'Exclude'
ELSE null
END) AS e2,  
(CASE WHEN extras is not null then SPLIT_STR(extras,',',1)
ELSE '' 
END ) AS extra_1,
(CASE WHEN extras is not null then SPLIT_STR(extras,',',2) 
ELSE ''
END) AS extra_2,
(CASE WHEN exclusions is not null THEN SPLIT_STR(exclusions,',',1) 
ELSE ''
END) AS exclude_1 ,
(CASE WHEN exclusions is not null THEN SPLIT_STR(exclusions,',',2) 
ELSE ''
END) AS exclude_2
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN pizza_names p1 ON c.pizza_id = p1.pizza_id
WHERE cancellation is null 
)
,item_name as(
SELECT i.order_id, pizza_name, e1, e2, t1.topping_name as extra_name_1, t2.topping_name as extra_name_2, t3.topping_name as exclude_name_1, t4.topping_name as exclude_name_2
FROM item_order i
LEFT JOIN pizza_toppings t1 ON i.extra_1 = t1.topping_id
LEFT JOIN pizza_toppings t2 ON i.extra_2 = t2.topping_id
LEFT JOIN pizza_toppings t3 ON i.exclude_1 = t3.topping_id
LEFT JOIN pizza_toppings t4 ON i.exclude_2 = t4.topping_id
)
SELECT order_id,
(CASE 
WHEN e1 is not null and e2 is not null THEN CONCAT(pizza_name,' - ',e1,' ', extra_name_1,',', IFNULL(extra_name_2,''),' - ', e2,' ', exclude_name_1,',',IFNULL(exclude_name_2,''))
WHEN e1 = 'Extra' and e2 is null THEN CONCAT(pizza_name,' - ',e1,' ', extra_name_1,IFNULL(extra_name_2,''))
WHEN e1 is null and e2 = 'Exclude' THEN CONCAT(pizza_name,' - ',e2,' ', exclude_name_1,IFNULL(exclude_name_2,''))
ELSE pizza_name
END)
AS 'Item name of order'
FROM item_name
ORDER BY order_id
-- 5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH temp AS 
(SELECT c.order_id, pizza_name, exclusions, 
(CASE 
WHEN extras is not null then CONCAT(toppings,', ',IFNULL(extras,''))
ELSE toppings
END) as topping_extra
FROM customer_orders_pre c
JOIN pizza_names p1 ON c.pizza_id = p1.pizza_id
JOIN pizza_recipes p2 ON c.pizza_id = p2.pizza_id
ORDER BY order_id, toppings
)
SELECT order_id, pizza_name, exclusions,JSON_SEARCH(JSON_ARRAY(topping_extra),'one',exclusions) 
FROM temp
-- 6.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
DROP TABLE IF EXISTS quantity_extra;
CREATE TEMPORARY TABLE quantity_extra as(
SELECT trim(j.extra) as extra,COUNT(extra) as number_extra
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN JSON_TABLE(TRIM(REPLACE(JSON_ARRAY(c.extras),',','","')),'$[*]' columns(extra varchar(5) path '$')) j
WHERE cancellation is null and extras is not null
GROUP BY j.extra
);
DROP TABLE IF EXISTS quantity_exclude;
CREATE TEMPORARY TABLE quantity_exclude As
(SELECT trim(j1.exclusion) as exclusion, COUNT(exclusion) as number_exclude
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN JSON_TABLE(TRIM(REPLACE(JSON_ARRAY(c.exclusions),',','","')),'$[*]' columns(exclusion varchar(5) path '$')) j1
WHERE cancellation is null and exclusions is not null
GROUP BY j1.exclusion
);
SELECT topping ,(COUNT(c.pizza_id) + IFNULL(number_extra,'') - IFNULL(number_exclude,'')) as number_topping
FROM customer_orders_pre c
JOIN pizza_recipes_cleaned p1 ON c.pizza_id = p1.pizza_id
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
LEFT JOIN quantity_extra q1 ON p1.topping = q1.extra
LEFT JOIN quantity_exclude q2 ON p1.topping = q2.exclusion
WHERE cancellation is null
GROUP BY topping 
ORDER BY number_topping DESC
