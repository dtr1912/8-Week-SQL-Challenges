# 8 Week SQL Challenges
The solution for the 8 case studies from the **[#8WeekSQLChallenge](https://8weeksqlchallenge.com)**. 
## 📚 Table of Contents
Please find the solution links for the case studies below. Simply click on the links to access each solution.
- [Case Study #1: Danny's Diner](#case-study-1-dannys-diner)
  - [Case Study Questions](#case-study-questions)
  - [Bonus Questions](#bonus-questions)
- [Case Study #2: Pizza Runner](#case-study-2-pizza-runner)
  - [Data Cleaning](#data-cleaning)
  - [A. Pizza Metrics](#a-pizza-metrics)
  - [B. Runner and Customer Experience]
  - [C. Ingredient Optimisation]
  - [D. Pricing and Ratings]
  - [E. Bonus Questions]
- [Case Study #3: Foodie-Fi](#case-study-3-foodie-fi)
- [Case Study #4: Data Bank](#case-study-4-data-bank)
- [Case Study #5: Data Mart](#case-study-5-data-mart)
- [Case Study #6: Clique Bait](#case-study-6-clique-bait)
- [Case Study #7: Balanced Tree](#case-study-7-balanced-tree)
- [Case Study #8: Fresh Segments](#case-study-8-fresh-segments)
## Case Study #1: Danny's Diner
### Introduction
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

### Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

### Case Study Questions

**Q1: What is the total amount each customer spent at the restaurant?**

```sql
SELECT customer_id,
       SUM(price) AS total_price 
FROM   sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP  BY customer_id;
```

Result: 
| customer_id   |   total_price |
|:--------------|--------------:|
| A             |            76 |
| B             |            74 |
| C             |            36 |


**Q2: How many days has each customer visited the restaurant?**

```sql
SELECT customer_id,
       COUNT(DISTINCT(order_date)) AS days_visited
FROM sales
GROUP BY customer_id;
```

| customer_id   |   days_visited |
|:--------------|---------------:|
| A             |              4 |
| B             |              6 |
| C             |              2 |

**Q3: What was the first item from the menu purchased by each customer?**
```sql
WITH cte AS(
SELECT s.customer_id,
	   s.order_date, 
       m.product_name,
Dense_rank() OVER(partition BY customer_id ORDER BY order_date ASC) ranker
FROM sales s
JOIN menu m
ON s.product_id =m.product_id )
SELECT customer_id, 
       order_date, 
       product_name
FROM cte
WHERE ranker = 1
```
Result:

| customer_id   | order_date   | product_name   |
|:--------------|:-------------|:---------------|
| A             | 2021-01-01   | sushi          |
| A             | 2021-01-01   | curry          |
| B             | 2021-01-01   | curry          |
| C             | 2021-01-01   | ramen          |
| C             | 2021-01-01   | ramen          |


**Q4: What is the most purchased item on the menu and how many times was it purchased by all customers?**

```sql
SELECT s.product_id, 
       m.product_name,
       Count(s.product_id) amount
FROM sales s
JOIN menu m
ON s.product_id =m.product_id
GROUP BY product_name
ORDER BY amount DESC
```
Result:

|   product_id | product_name   |   amount |
|-------------:|:---------------|---------:|
|            3 | ramen          |        8 |
|            2 | curry          |        4 |
|            1 | sushi          |        3 |


**Q5: Which item was the most popular for each customer?**

```sql
WITH cte AS(
SELECT customer_id, s.product_id, m.product_name, count(customer_id) amount,
RANK() OVER(PARTITION BY customer_id ORDER BY count(customer_id) DESC) ranker
FROM sales s
JOIN menu m
ON s.product_id =m.product_id
GROUP BY customer_id, product_name
)
SELECT customer_id, product_name, amount
FROM cte
WHERE ranker=1
```

Result:

| customer_id   | product_name   |   amount |
|:--------------|:---------------|---------:|
| A             | ramen          |        3 |
| B             | curry          |        2 |
| B             | sushi          |        2 |
| B             | ramen          |        2 |
| C             | ramen          |        3 |


**Q6: Which item was purchased first by the customer after they became a member?**

```sql
WITH cte AS (
SELECT s.customer_id, order_date, m.product_name
FROM menu m
JOIN sales s
ON s.product_id = m.product_id
), cte1 AS(
SELECT c.customer_id, join_date,order_date, product_name, rank() over(partition BY customer_id ORDER BY order_date ASC) ranker
FROM cte c
JOIN members m
ON c.customer_id = m.customer_id
WHERE join_date <= order_date
ORDER BY  c.customer_id)
SELECT customer_id, product_name
FROM cte1
WHERE ranker = 1
```

Result:

| customer_id   | product_name   |
|:--------------|:---------------|
| A             | curry          |
| B             | sushi          |


**Q7: Which item was purchased just before the customer became a member?**

```sql
WITH cte AS (
SELECT s.customer_id, order_date, m.product_name
FROM menu m
JOIN sales s
ON s.product_id = m.product_id )
,cte1 AS (SELECT c.customer_id, join_date,order_date, product_name, rank() over(partition BY customer_id ORDER BY order_date DESC ) ranker
FROM cte c
JOIN members m
ON c.customer_id = m.customer_id
WHERE join_date > order_date
ORDER BY  c.customer_id
)
SELECT customer_id, product_name
FROM cte1
WHERE ranker =1
```

Result:

| customer_id   | product_name   |
|:--------------|:---------------|
| A             | sushi          |
| A             | curry          |
| B             | sushi          |


**Q8: What is the total items and amount spent for each member before they became a member?**

```sql
WITH cte1 AS (
SELECT s.customer_id, order_date, count(s.product_id) item, sum(m.price) total_price
FROM sales s
JOIN menu m
WHERE s.product_id=m.product_id
GROUP BY  customer_id, order_date),
cte2 AS (
SELECT s.customer_id, order_date, join_date
FROM sales s
JOIN members m
ON s.customer_id = m.customer_id
WHERE order_date < join_date
GROUP BY customer_id,order_date )
SELECT cte1.customer_id, sum(item) item_amount , sum(total_price) total_amount
FROM cte1
JOIN cte2
WHERE cte1.order_date = cte2.order_date AND cte1.customer_id = cte2.customer_id
GROUP BY cte1.customer_id
```

Result:

| customer_id   |   item_amount |   total_amount |
|:--------------|--------------:|---------------:|
| A             |             2 |             25 |
| B             |             3 |             40 |


**Q9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

```sql
WITH cte1 AS
(SELECT s.customer_id, product_name, CASE
WHEN product_name = 'sushi' THEN sum(2*price)
ELSE sum(price)
end AS point
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY  customer_id, product_name
)
SELECT customer_id, product_name, sum(point)*10 total_points
FROM cte1
GROUP BY customer_id
```

Result:

| customer_id   | product_name   |   total_points |
|:--------------|:---------------|---------------:|
| A             | sushi          |            860 |
| B             | curry          |            940 |
| C             | ramen          |            360 |

**Q10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

```sql
WITH cte1
AS (
SELECT customer_id, join_date, date(join_date+6) first_week, last_day('2021-01-01') AS jan
FROM members
)
, cte2 AS (
SELECT s.customer_id, product_id, join_date, order_date, first_week, jan
FROM sales s
JOIN cte1 c1
ON s.customer_id = c1.customer_id )
-- where join_date <= order_date < first_week )
, cte3 AS (
SELECT customer_id, c2.product_id, order_date, price
,CASE
WHEN c2.product_id = 1 THEN (20*price)
WHEN order_date BETWEEN join_date AND first_week THEN (20*price)
ELSE (10*price)
end AS point
FROM cte2 c2
JOIN menu m
ON m.product_id = c2.product_id
WHERE order_date < jan
ORDER BY customer_id
)
SELECT customer_id, sum(point) as total_point
FROM cte3
GROUP BY customer_id
ORDER BY  customer_id
```

Result:

| customer_id   |   total_point |
|:--------------|--------------:|
| A             |          1370 |
| B             |           820 |

### Bonus Questions
**Join All The Things**

The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

```sql
SELECT 
      s.customer_id,
      s.order_date,
      m.product_name,
      m.price,
      CASE WHEN mb.customer_id IS NOT NULL THEN 'Y'
           ELSE 'N'
	  END AS member
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mb ON s.customer_id = mb.customer_id AND s.order_date >= mb.join_date
```
Result:

| customer_id   | order_date   | product_name   |   price | member   |
|:--------------|:-------------|:---------------|--------:|:---------|
| A             | 2021-01-01   | sushi          |      10 | N        |
| A             | 2021-01-01   | curry          |      15 | N        |
| A             | 2021-01-07   | curry          |      15 | Y        |
| A             | 2021-01-10   | ramen          |      12 | Y        |
| A             | 2021-01-11   | ramen          |      12 | Y        |
| A             | 2021-01-11   | ramen          |      12 | Y        |
| B             | 2021-01-01   | curry          |      15 | N        |
| B             | 2021-01-02   | curry          |      15 | N        |
| B             | 2021-01-04   | sushi          |      10 | N        |
| B             | 2021-01-11   | sushi          |      10 | Y        |
| B             | 2021-01-16   | ramen          |      12 | Y        |
| B             | 2021-02-01   | ramen          |      12 | Y        |
| C             | 2021-01-01   | ramen          |      12 | N        |
| C             | 2021-01-01   | ramen          |      12 | N        |
| C             | 2021-01-07   | ramen          |      12 | N        |

**Rank All The Things**

Danny also requires further information about the `ranking` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null `ranking` values for the records when customers are not yet part of the loyalty program.

```sql
WITH cte1 AS(
SELECT 
      ROW_NUMBER() OVER (ORDER BY s.customer_id, s.order_date ASC) AS order_id,
      s.customer_id,
      s.order_date,
      m.product_name,
      m.price,
      CASE WHEN mb.customer_id IS NOT NULL THEN 'Y'
           ELSE 'N'
	  END AS member
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mb ON s.customer_id = mb.customer_id AND s.order_date >= mb.join_date
),
cte2 AS(
SELECT *,
	   RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk
FROM cte1
WHERE member = 'Y'
)

SELECT c1.customer_id,
       c1.order_date,
       c1.product_name,
       c1.price,
       c1.member,
       c2.rnk
FROM cte1 c1
LEFT JOIN cte2 c2 ON c1.order_id = c2.order_id;
```

Result:
| customer_id   | order_date   | product_name   |   price | member   |   rnk |
|:--------------|:-------------|:---------------|--------:|:---------|------:|
| A             | 2021-01-01   | sushi          |      10 | N        |   nan |
| A             | 2021-01-01   | curry          |      15 | N        |   nan |
| A             | 2021-01-07   | curry          |      15 | Y        |     1 |
| A             | 2021-01-10   | ramen          |      12 | Y        |     2 |
| A             | 2021-01-11   | ramen          |      12 | Y        |     3 |
| A             | 2021-01-11   | ramen          |      12 | Y        |     3 |
| B             | 2021-01-01   | curry          |      15 | N        |   nan |
| B             | 2021-01-02   | curry          |      15 | N        |   nan |
| B             | 2021-01-04   | sushi          |      10 | N        |   nan |
| B             | 2021-01-11   | sushi          |      10 | Y        |     1 |
| B             | 2021-01-16   | ramen          |      12 | Y        |     2 |
| B             | 2021-02-01   | ramen          |      12 | Y        |     3 |
| C             | 2021-01-01   | ramen          |      12 | N        |   nan |
| C             | 2021-01-01   | ramen          |      12 | N        |   nan |
| C             | 2021-01-07   | ramen          |      12 | N        |   nan |


## Case Study #2: Pizza Runner
### Introduction
Did you know that over 115 million kilograms of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

### Data Cleaning
```sql
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
```

#customer_order_cleaned

|   order_id |   customer_id |   pizza_id |   exclusions |   extras | order_time          |
|-----------:|--------------:|-----------:|-------------:|---------:|:--------------------|
|          1 |           101 |          1 |          nan |      nan | 2020-01-01 18:05:02 |
|          2 |           101 |          1 |          nan |      nan | 2020-01-01 19:00:52 |
|          3 |           102 |          1 |          nan |      nan | 2020-01-02 23:51:23 |
|          3 |           102 |          2 |          nan |      nan | 2020-01-02 23:51:23 |
|          4 |           103 |          1 |            4 |      nan | 2020-01-04 13:23:46 |
|          4 |           103 |          1 |            4 |      nan | 2020-01-04 13:23:46 |
|          4 |           103 |          2 |            4 |      nan | 2020-01-04 13:23:46 |
|          5 |           104 |          1 |          nan |        1 | 2020-01-08 21:00:29 |
|          6 |           101 |          2 |          nan |      nan | 2020-01-08 21:03:13 |
|          7 |           105 |          2 |          nan |        1 | 2020-01-08 21:20:29 |
|          8 |           102 |          1 |          nan |      nan | 2020-01-09 23:54:33 |
|          9 |           103 |          1 |            4 |        1 | 2020-01-10 11:22:59 |
|          9 |           103 |          1 |            4 |        5 | 2020-01-10 11:22:59 |
|         10 |           104 |          1 |          nan |      nan | 2020-01-11 18:34:49 |
|         10 |           104 |          1 |            2 |        1 | 2020-01-11 18:34:49 |
|         10 |           104 |          1 |            2 |        4 | 2020-01-11 18:34:49 |
|         10 |           104 |          1 |            6 |        1 | 2020-01-11 18:34:49 |
|         10 |           104 |          1 |            6 |        4 | 2020-01-11 18:34:49 |


#pizza_recipes_cleaned

|   pizza_id |   topping |
|-----------:|----------:|
|          1 |         1 |
|          1 |         2 |
|          1 |         3 |
|          1 |         4 |
|          1 |         5 |
|          1 |         6 |
|          1 |         8 |
|          1 |        10 |
|          2 |         4 |
|          2 |         6 |
|          2 |         7 |
|          2 |         9 |
|          2 |        11 |
|          2 |        12 |
|          3 |         1 |
|          3 |         2 |
|          3 |         3 |
|          3 |         4 |
|          3 |         5 |
|          3 |         6 |
|          3 |         7 |
|          3 |         8 |
|          3 |         9 |
|          3 |        10 |
|          3 |        11 |
|          3 |        12 |


#runner_orders_cleand

|   order_id |   runner_id | pickup_time         |   distance_km |   duration_mins | cancellation            |
|-----------:|------------:|:--------------------|--------------:|----------------:|:------------------------|
|          1 |           1 | 2020-01-01 18:15:34 |          20   |              32 | nan                     |
|          2 |           1 | 2020-01-01 19:10:54 |          20   |              27 | nan                     |
|          3 |           1 | 2020-01-03 00:12:37 |          13.4 |              20 | nan                     |
|          4 |           2 | 2020-01-04 13:53:03 |          23.4 |              40 | nan                     |
|          5 |           3 | 2020-01-08 21:10:57 |          10   |              15 | nan                     |
|          6 |           3 | nan                 |         nan   |             nan | Restaurant Cancellation |
|          7 |           2 | 2020-01-08 21:30:45 |          25   |              25 | nan                     |
|          8 |           2 | 2020-01-10 00:15:02 |          23.4 |              15 | nan                     |
|          9 |           2 | nan                 |         nan   |             nan | Customer Cancellation   |
|         10 |           1 | 2020-01-11 18:50:20 |          10   |              10 | nan                     |

### A. Pizza Metrics

**Q1: How many pizzas were ordered?**
```sql
SELECT COUNT(order_id) AS 'Total number of pizza ordered'
FROM customer_orders_cleaned;
```
Result:

|   Total number of pizza ordered |
|--------------------------------:|
|                              18 |

**Q2: How many unique customer orders were made?**
```sql
SELECT COUNT(DISTINCT(order_id)) as 'Number of unique order'
FROM customer_orders_cleaned;
```
Result:
|   Number of unique order |
|-------------------------:|
|                       10 |

**Q3: How many successful orders were delivered by each runner?**
```sql
SELECT runner_id, COUNT(order_id) as 'Number of successful orders'
FROM runner_orders_cleaned
WHERE cancellation IS NULL
GROUP BY runner_id;
```
Result:
|   runner_id |   Number of successful orders |
|------------:|------------------------------:|
|           1 |                             4 |
|           2 |                             3 |
|           3 |                             1 |

**Q4: How many of each type of pizza was delivered?**
```sql
SELECT c.pizza_id, count(pizza_id) as 'Number of pizza was delivered'
FROM customer_orders_pre c
INNER JOIN runner_orders_cleaned r1 on c.order_id = r1.order_id
WHERE cancellation IS NULL
GROUP BY pizza_id
```
Result:
|   pizza_id |   Number of pizza was delivered |
|-----------:|--------------------------------:|
|          1 |                               9 |
|          2 |                               3 |

**Q5: How many Vegetarian and Meatlovers were ordered by each customer?**
```sql
SELECT customer_id, pizza_name, count(p1.pizza_name) as num_pizza
FROM customer_orders_pre c
JOIN pizza_names p1 ON c.pizza_id = p1.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id
```
Result:
|   customer_id | pizza_name   |   num_pizza |
|--------------:|:-------------|------------:|
|           101 | Meatlovers   |           2 |
|           101 | Vegetarian   |           1 |
|           102 | Meatlovers   |           2 |
|           102 | Vegetarian   |           1 |
|           103 | Meatlovers   |           3 |
|           103 | Vegetarian   |           1 |
|           104 | Meatlovers   |           3 |
|           105 | Vegetarian   |           1 |

**Q6: What was the maximum number of pizzas delivered in a single order?**
```sql
SELECT r1.order_id, count(c.pizza_id) as s_pizza
FROM customer_orders_pre c
INNER JOIN runner_orders_cleaned r1 ON c.order_id= r1.order_id
WHERE cancellation IS NULL
GROUP BY r1.order_id
```
Result:

|   order_id |   s_pizza |
|-----------:|----------:|
|          1 |         1 |
|          2 |         1 |
|          3 |         2 |
|          4 |         3 |
|          5 |         1 |
|          7 |         1 |
|          8 |         1 |
|         10 |         2 |


**Q7: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
```sql
SELECT c.customer_id, pizza_id, 
SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1  -- If no change then value 1 else 0
ELSE 0
END ) no_change,
SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 0  -- If no change then value 0 else 1
ELSE 1
END ) had_change
FROM customer_orders_pre c
INNER JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
WHERE cancellation IS NULL
GROUP BY customer_id
ORDER BY customer_id
```
Result:

|   customer_id |   pizza_id |   no_change |   had_change |
|--------------:|-----------:|------------:|-------------:|
|           101 |          1 |           2 |            0 |
|           102 |          1 |           3 |            0 |
|           103 |          1 |           0 |            3 |
|           104 |          1 |           1 |            2 |
|           105 |          2 |           0 |            1 |

**Q8: How many pizzas were delivered that had both exclusions and extras?**
```sql
SELECT COUNT(c.order_id) AS 'Number of pizza had both exclusions and extras'
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id 
WHERE cancellation IS NULL AND exclusions IS NOT NULL AND extras IS NOT NULL
```
|   Number of pizza had both exclusions and extras |
|-------------------------------------------------:|
|                                                1 |

**Q9: What was the total volume of pizzas ordered for each hour of the day?**
```sql
SELECT 
       HOUR(order_time) AS order_hour,
       COUNT(order_id) AS num_pizza
FROM customer_orders_pre
GROUP BY 
         HOUR(order_time) 
ORDER BY COUNT(order_id)
```
Result:

|   order_hour |   num_pizza |
|-------------:|------------:|
|           19 |           1 |
|           11 |           1 |
|           18 |           3 |
|           23 |           3 |
|           13 |           3 |
|           21 |           3 |

**Q10: What was the volume of orders for each day of the week?** 
```sql
SELECT  DAYNAME(order_time) AS day_name, 
        COUNT(order_id) AS volume_orders
FROM customer_orders_pre
GROUP BY DAYOFWEEK(order_time)
ORDER BY COUNT(order_id)
```
Result:

| day_name   |   volume_orders |
|:-----------|----------------:|
| Friday     |               1 |
| Thursday   |               3 |
| Wednesday  |               5 |
| Saturday   |               5 |

## Case Study #3: Foodie-Fi
## Case Study #4: Data Bank
## Case Study #5: Data Mart
## Case Study #6: Clique Bait
## Case Study #7: Balanced Tree
## Case Study #8: Fresh Segments
