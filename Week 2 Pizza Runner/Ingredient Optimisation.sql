-- 1.What are the standard ingredients for each pizza?
SELECT p1.pizza_id, topping_name
FROM pizza_recipes_cleaned p1
JOIN pizza_toppings p2 ON p1.topping = p2.topping_id
-- 2.What was the most commonly added extra?
SELECT trim(j.extra) AS extra,topping_name, count(extra) AS 'number of the most added extra'
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN pizza_toppings p2 ON c.extras = p2.topping_id
JOIN json_table(trim(REPLACE(json_array(c.extras),',','","')),'$[*]' columns(extra VARCHAR(5) path '$')) j
WHERE cancellation IS NULL AND extras IS NOT NULL
GROUP BY extra
ORDER BY count(extra) DESC LIMIT 1
-- 3.What was the most common exclusion?
SELECT trim(j.exclusion) AS exclusion,topping_name, count(exclusion) AS 'number of the most added exclusion'
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN pizza_toppings p2 ON c.exclusions = p2.topping_id
JOIN json_table(trim(REPLACE(json_array(c.exclusions),',','","')),'$[*]' columns(exclusion VARCHAR(5) path '$')) j
WHERE cancellation IS NULL AND exclusion IS NOT NULL
GROUP BY exclusion
ORDER BY count(exclusion) DESC LIMIT 1
-- 4.Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
WITH item_order AS
(SELECT c.order_id, pizza_name,
(CASE WHEN extras IS NOT NULL THEN 'Extra'
ELSE NULL
end) AS e1,
(CASE WHEN exclusions IS NOT NULL THEN 'Exclude'
ELSE NULL
end) AS e2,
(CASE WHEN extras IS NOT NULL THEN split_str(extras,',',1)
ELSE ''
end ) AS extra_1,
(CASE WHEN extras IS NOT NULL THEN split_str(extras,',',2)
ELSE ''
end) AS extra_2,
(CASE WHEN exclusions IS NOT NULL THEN split_str(exclusions,',',1)
ELSE ''
end) AS exclude_1 ,
(CASE WHEN exclusions IS NOT NULL THEN split_str(exclusions,',',2)
ELSE ''
end) AS exclude_2
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN pizza_names p1 ON c.pizza_id = p1.pizza_id
WHERE cancellation IS NULL
)
,item_name AS(
SELECT i.order_id, pizza_name, e1, e2, t1.topping_name AS extra_name_1, t2.topping_name AS extra_name_2, t3.topping_name AS exclude_name_1, t4.topping_name AS exclude_name_2
FROM item_order i
LEFT JOIN pizza_toppings t1 ON i.extra_1 = t1.topping_id
LEFT JOIN pizza_toppings t2 ON i.extra_2 = t2.topping_id
LEFT JOIN pizza_toppings t3 ON i.exclude_1 = t3.topping_id
LEFT JOIN pizza_toppings t4 ON i.exclude_2 = t4.topping_id
)
SELECT order_id,
(CASE
WHEN e1 IS NOT NULL AND e2 IS NOT NULL THEN concat(pizza_name,' - ',e1,' ', extra_name_1,',', ifnull(extra_name_2,''), ' - ' , e2, ' ', exclude_name_1, ',', ifnull(exclude_name_2,''))
WHEN e1 = 'Extra' AND e2 IS NULL THEN concat(pizza_name,' - ',e1,' ', extra_name_1, ifnull(extra_name_2,''))
WHEN e1 IS NULL AND e2 = 'Exclude' THEN concat(pizza_name,' - ',e2,' ', exclude_name_1, ifnull(exclude_name_2,''))
ELSE pizza_name
end)
AS 'Item name of order'
FROM item_name
ORDER BY order_id
-- 5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH item_order AS
(SELECT c.order_id, pizza_name,
(CASE WHEN extras IS NOT NULL THEN split_str(extras,',',1)
ELSE ''
end ) AS extra_1,
(CASE WHEN extras IS NOT NULL THEN split_str(extras,',',2)
ELSE ''
end) AS extra_2,
rn.topping_name AS ingredients
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN pizza_names p1 ON c.pizza_id = p1.pizza_id
LEFT JOIN pizza_recipes_name rn ON c.pizza_id =  rn.pizza_id
WHERE cancellation IS NULL
)
,item_name AS(
SELECT i.order_id, 
       pizza_name,
       ingredients,
	   t1.topping_name AS extra_name_1, 
       t2.topping_name AS extra_name_2
FROM item_order i
LEFT JOIN pizza_toppings t1 ON i.extra_1 = t1.topping_id
LEFT JOIN pizza_toppings t2 ON i.extra_2 = t2.topping_id

)
SELECT order_id,
       CONCAT(pizza_name, ' : ' ,
			  CASE 
                   WHEN LOCATE(extra_name_1, ingredients) > 0 AND 
                        LOCATE(extra_name_2, ingredients) > 0 
                   THEN REPLACE(REPLACE(ingredients, extra_name_2, CONCAT('2x',extra_name_2)), extra_name_1, CONCAT('2x',extra_name_1))
			  ELSE ingredients
			  END) AS ingredients_list
FROM item_name
ORDER BY order_id

-- 6.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
DROP TABLE IF EXISTS quantity_extra;CREATE temporary TABLE quantity_extra AS(
SELECT Trim(j.extra) AS extra,Count(extra) AS number_extra
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN json_table(trim(REPLACE(json_array(c.extras),',','","')),'$[*]' columns(extra VARCHAR(5) path '$')) j
WHERE cancellation IS NULL AND extras IS NOT NULL
GROUP BY j.extra
);DROP TABLE IF EXISTS quantity_exclude;CREATE temporary TABLE quantity_exclude AS
(SELECT Trim(j1.exclusion) AS exclusion, Count(exclusion) AS number_exclude
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN json_table(trim(REPLACE(json_array(c.exclusions),',','","')),'$[*]' columns(exclusion VARCHAR(5) path '$')) j1
WHERE cancellation IS NULL AND exclusions IS NOT NULL
GROUP BY j1.exclusion
);SELECT topping ,(Count(c.pizza_id) + Ifnull(number_extra,'') - Ifnull(number_exclude,'')) AS number_topping
FROM customer_orders_pre c
JOIN pizza_recipes_cleaned p1 ON c.pizza_id = p1.pizza_id
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
LEFT JOIN quantity_extra q1 ON p1.topping = q1.extra
LEFT JOIN quantity_exclude q2 ON p1.topping = q2.exclusion
WHERE cancellation IS NULL
GROUP BY topping
ORDER BY number_topping DESC