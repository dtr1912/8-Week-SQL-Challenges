# 8 Week SQL Challenges
The solution for the 8 case studies from the **[#8WeekSQLChallenge](https://8weeksqlchallenge.com)**. 
## 📚 Table of Contents
Please find the solution links for the case studies below. Simply click on the links to access each solution.
- [Case Study #1: Danny's Diner](#case-study-1-dannys-diner)
  - [A. Case Study Questions](#a-case-study-questions)
  - [B. Bonus Questions](#b-bonus-questions)
- [Case Study #2: Pizza Runner](#case-study-2-pizza-runner)
  - [Data Cleaning](#data-cleaning)
  - [A. Pizza Metrics](#a-pizza-metrics)
  - [B. Runner and Customer Experience](#b-runner-and-customer-experience)
  - [C. Ingredient Optimisation](#c-ingredient-optimisation)
  - [D. Pricing and Ratings](#d-pricing-and-ratings)
  - [E. Bonus Questions](#e-bonus-questions)
- [Case Study #3: Foodie-Fi](#case-study-3-foodie-fi)
  - [A. Customer Journey)](#a-customer-journey)
  - [B. Data Analysis Questions](#b-data-analysis)
  - [C. Challenge Payment Question](#c-challenge-payment-question)
  - [D. Outside The Box Questions](#d-outside-the-box-questions)
- [Case Study #4: Data Bank](#case-study-4-data-bank)
  - [A. Customer Nodes Exploration](#a-customer-nodes-exploration)
  - [B. Customer Transactions](#b-customer-transaction)
  - [C. Data Allocation Challenge](#c-data-allocation-challenge)
  - [D. Extra Challenge](#d-extra-challenge)
  - [E. Extension Request](#e-extension-request)
- [Case Study #5: Data Mart](#case-study-5-data-mart)
  - [A. Data Cleansing Steps](#a-data-cleansing-steps)
  - [B. Data Exploration](#b-data-exploration)
  - [C. Before & After Analysis](#c-before-&after-analysis)
  - [D. Bonus Question](#d-bonus-questions)
- [Case Study #6: Clique Bait](#case-study-6-clique-bait)
  - [A. Enterprise Relationship Diagram](#a-enterprise-relationship-diagram)
  - [B. Digital Analysis](#b-digital-analysis)
  - [C. Product Funnel Analysis](#c-product-funel-analysis)
  - [D. Campaigns Analysis](#d-campaign-analysis)
- [Case Study #7: Balanced Tree](#case-study-7-balanced-tree)
  - [A. High Level Sales Analysis](#a-high-level-sales-analysis)
  - [B. Transaction Analysis](#b-transaction-analysis)
  - [C. Product Analysis](#c-product-analysis)
  - [D. Reporting Challenge](#d-reporting-challenge)
  - [E. Bonus Challenge](#e-bonus-challenge)
- [Case Study #8: Fresh Segments](#case-study-8-fresh-segments)
  - [A. Data Exploration and Cleansing](#a-data-exploration-and-cleansing)
  - [B. Interest Analysis](#b-interest-analysis)
  - [C. Segment analysis](#c-segment-analysis)
  - [D. Index Analysis](#a-index-analysis)

## Case Study #1: Danny's Diner
### Introduction
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

### Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

### A. Case Study Questions

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
Result: 
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

### B.Bonus Questions
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
DROP TABLE IF EXISTS pizza_recipes_name; 
CREATE TEMPORARY TABLE pizza_recipes_name(
SELECT pizza_id, 
	   GROUP_CONCAT(topping_name ORDER BY pizza_id ASC SEPARATOR ', ') AS topping_name
FROM pizza_recipes_cleaned r
JOIN pizza_toppings t  ON r.topping = t.topping_id
GROUP BY pizza_id
)
SELECT * FROM pizza_recipes_name
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

#pizza_recipes_name

|   pizza_id | topping_name                                                                                                   |
|-----------:|:---------------------------------------------------------------------------------------------------------------|
|          1 | Salami, Pepperoni, Mushrooms, Chicken, Cheese, Beef, BBQ Sauce, Bacon                                          |
|          2 | Tomato Sauce, Tomatoes, Peppers, Onions, Mushrooms, Cheese                                                     |
|          3 | Tomato Sauce, Tomatoes, Salami, Peppers, Pepperoni, Onions, Mushrooms, Chicken, Cheese, Beef, BBQ Sauce, Bacon |

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
Result: 
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

### B. Runner and Customer Experience

**Q1: How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**
```sql
SELECT Week(registration_date + INTERVAL 2 day) AS number_of_week,
       Min(registration_date) start_day,
Count(runner_id) number_of_runner
FROM runners
GROUP BY number_of_week
```

Result:

|   number_of_week | start_day   |   number_of_runner |
|-----------------:|:------------|-------------------:|
|                1 | 2021-01-01  |                  2 |
|                2 | 2021-01-08  |                  1 |
|                3 | 2021-01-15  |                  1 |

**Q2: What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```sql
SELECT runner_id,
       round(avg(timestampdiff(minute, order_time, pickup_time))) AS avg_time
FROM runner_orders_cleaned r1
JOIN customer_orders_pre c ON r1.order_id = c.order_id
WHERE cancellation IS NULL
GROUP BY runner_id
```

Result:

|   runner_id |   avg_time |
|------------:|-----------:|
|           1 |         15 |
|           2 |         23 |
|           3 |         10 |

**Q3: Is there any relationship between the number of pizzas and how long the order takes to prepare?**
```sql
SELECT c.order_id,
       count(c.pizza_id) AS num_pizza,
       round(timestampdiff(minute,order_time,pickup_time)) AS avg_time
FROM runner_orders_cleaned r1
JOIN customer_orders_pre c ON r1.order_id = c.order_id
WHERE cancellation IS NULL
GROUP BY c.order_id

```

Result: The number of pizzas is proportional to the preparation time

|   order_id |   num_pizza |   avg_time |
|-----------:|------------:|-----------:|
|          1 |           1 |         10 |
|          2 |           1 |         10 |
|          3 |           2 |         21 |
|          4 |           3 |         29 |
|          5 |           1 |         10 |
|          7 |           1 |         10 |
|          8 |           1 |         20 |
|         10 |           2 |         15 |



**Q4: What was the average distance travelled for each customer?**
```sql
SELECT c.customer_id, 
       round(avg(distance_km)) AS avg_distance
FROM runner_orders_cleaned r1
JOIN customer_orders_pre c ON r1.order_id = c.order_id
WHERE cancellation IS NULL
GROUP BY customer_id
```

Result:

|   customer_id |   avg_distance |
|--------------:|---------------:|
|           101 |             20 |
|           102 |             17 |
|           103 |             23 |
|           104 |             10 |
|           105 |             25 |

**Q5: What was the difference between the longest and shortest delivery times for all orders?**
```sql
SELECT
  max(duration_mins) AS longest_delivery_time,
  min(duration_mins) AS shortest_delivery_time,
  max(duration_mins) - min(duration_mins) AS time_diff
FROM runner_orders_cleaned;WHERE cancellation IS NULL
```

Result:

|   longest_delivery_time |   shortest_delivery_time |   time_diff |
|------------------------:|-------------------------:|------------:|
|                      40 |                       10 |          30 |


**Q6: What was the average speed for each runner for each delivery and do you notice any trend for these values?**
```sql
SELECT runner_id, concat(round(avg(distance_km/(duration_mins/60))), '(km/h)') speed
FROM runner_orders_cleaned r1
WHERE cancellation IS NULL
GROUP BY runner_id
```

Result:

|   runner_id | speed    |
|------------:|:---------|
|           1 | 46(km/h) |
|           2 | 63(km/h) |
|           3 | 40(km/h) |

**Q7: What is the successful delivery percentage for each runner?**
```sql
WITH temp AS
(SELECT runner_id,
SUM(
CASE WHEN cancellation IS NULL THEN 1
ELSE 0
END) AS success,
SUM(CASE WHEN cancellation IS NULL THEN 0
ELSE 1
END) AS no_success,
count(order_id) all_order
FROM runner_orders_cleaned
GROUP BY runner_id
)
SELECT t.runner_id, concat(round((success/all_order)*100),'%') AS 'Percentage of successfull delivery'
FROM temp t
```

Result:

|   runner_id | Percentage of successfull delivery   |
|------------:|:-------------------------------------|
|           1 | 100%                                 |
|           2 | 75%                                  |
|           3 | 50%                                  |

### C. Ingredient Optimisation
**Q1: What are the standard ingredients for each pizza?**
```sql
SELECT p1.pizza_id, topping_name
FROM pizza_recipes_cleaned p1
JOIN pizza_toppings p2 ON p1.topping = p2.topping_id
```

Result:

|   pizza_id | topping_name   |
|-----------:|:---------------|
|          1 | Bacon          |
|          1 | BBQ Sauce      |
|          1 | Beef           |
|          1 | Cheese         |
|          1 | Chicken        |
|          1 | Mushrooms      |
|          1 | Pepperoni      |
|          1 | Salami         |
|          2 | Cheese         |
|          2 | Mushrooms      |
|          2 | Onions         |
|          2 | Peppers        |
|          2 | Tomatoes       |
|          2 | Tomato Sauce   |
|          3 | Bacon          |
|          3 | BBQ Sauce      |
|          3 | Beef           |
|          3 | Cheese         |
|          3 | Chicken        |
|          3 | Mushrooms      |
|          3 | Onions         |
|          3 | Pepperoni      |
|          3 | Peppers        |
|          3 | Salami         |
|          3 | Tomatoes       |
|          3 | Tomato Sauce   |

**Q2: What was the most commonly added extra?**
```sql
SELECT trim(j.extra) AS extra,topping_name, count(extra) AS 'number of the most added extra'
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN pizza_toppings p2 ON c.extras = p2.topping_id
JOIN json_table(trim(REPLACE(json_array(c.extras),',','","')),'$[*]' columns(extra VARCHAR(5) path '$')) j
WHERE cancellation IS NULL AND extras IS NOT NULL
GROUP BY extra
ORDER BY count(extra) DESC LIMIT 1
```

Result:

|   extra | topping_name   |   number of the most added extra |
|--------:|:---------------|---------------------------------:|
|       1 | Bacon          |                                3 |

**Q3: What was the most common exclusion?**
```sql
SELECT trim(j.exclusion) AS exclusion,topping_name, count(exclusion) AS 'number of the most added exclusion'
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN pizza_toppings p2 ON c.exclusions = p2.topping_id
JOIN json_table(trim(REPLACE(json_array(c.exclusions),',','","')),'$[*]' columns(exclusion VARCHAR(5) path '$')) j
WHERE cancellation IS NULL AND exclusion IS NOT NULL
GROUP BY exclusion
ORDER BY count(exclusion) DESC LIMIT 1
```

Result:

|   exclusion | topping_name   |   number of the most added exclusion |
|------------:|:---------------|-------------------------------------:|
|           4 | Cheese         |                                    3 |

**Q4: Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers**
```sql
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
WHEN e1 IS NOT NULL AND e2 IS NOT NULL THEN concat(pizza_name,' - ',e1,' ', extra_name_1,',', ifnull(extra_name_2,''),' - ', e2,' ', exclude_name_1,',',ifnull(exclude_name_2,''))
WHEN e1 = 'Extra' AND e2 IS NULL THEN concat(pizza_name,' - ',e1,' ', extra_name_1,ifnull(extra_name_2,''))
WHEN e1 IS NULL AND e2 = 'Exclude' THEN concat(pizza_name,' - ',e2,' ', exclude_name_1,ifnull(exclude_name_2,''))
ELSE pizza_name
end)
AS 'Item name of order'
FROM item_name
ORDER BY order_id
```

Result:
|   order_id | Item name of order                                            |
|-----------:|:--------------------------------------------------------------|
|          1 | Meatlovers                                                    |
|          2 | Meatlovers                                                    |
|          3 | Meatlovers                                                    |
|          3 | Vegetarian                                                    |
|          4 | Meatlovers - Exclude Cheese                                   |
|          4 | Meatlovers - Exclude Cheese                                   |
|          4 | Vegetarian - Exclude Cheese                                   |
|          5 | Meatlovers - Extra Bacon                                      |
|          7 | Vegetarian - Extra Bacon                                      |
|          8 | Meatlovers                                                    |
|         10 | Meatlovers - Extra Bacon,Cheese - Exclude BBQ Sauce,Mushrooms |
|         10 | Meatlovers                                                    |

**Q5: Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"**
```sql
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

```

Result:

|   order_id | ingredients_list                                                                       |
|-----------:|:---------------------------------------------------------------------------------------|
|          1 | Meatlovers : Salami, Pepperoni, Mushrooms, Chicken, Cheese, Beef, BBQ Sauce, Bacon     |
|          2 | Meatlovers : Salami, Pepperoni, Mushrooms, Chicken, Cheese, Beef, BBQ Sauce, Bacon     |
|          3 | Meatlovers : Salami, Pepperoni, Mushrooms, Chicken, Cheese, Beef, BBQ Sauce, Bacon     |
|          3 | Vegetarian : Tomato Sauce, Tomatoes, Peppers, Onions, Mushrooms, Cheese                |
|          4 | Meatlovers : Salami, Pepperoni, Mushrooms, Chicken, Cheese, Beef, BBQ Sauce, Bacon     |
|          4 | Meatlovers : Salami, Pepperoni, Mushrooms, Chicken, Cheese, Beef, BBQ Sauce, Bacon     |
|          4 | Vegetarian : Tomato Sauce, Tomatoes, Peppers, Onions, Mushrooms, Cheese                |
|          5 | Meatlovers : Salami, Pepperoni, Mushrooms, Chicken, Cheese, Beef, BBQ Sauce, Bacon     |
|          7 | Vegetarian : Tomato Sauce, Tomatoes, Peppers, Onions, Mushrooms, Cheese                |
|          8 | Meatlovers : Salami, Pepperoni, Mushrooms, Chicken, Cheese, Beef, BBQ Sauce, Bacon     |
|         10 | Meatlovers : Salami, Pepperoni, Mushrooms, Chicken, 2xCheese, Beef, BBQ Sauce, 2xBacon |
|         10 | Meatlovers : Salami, Pepperoni, Mushrooms, Chicken, Cheese, Beef, BBQ Sauce, Bacon     |

**Q6: What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?**
```sql
DROP TABLE IF EXISTS quantity_extra;
CREATE temporary TABLE quantity_extra AS(
SELECT Trim(j.extra) AS extra,Count(extra) AS number_extra
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN json_table(trim(REPLACE(json_array(c.extras),',','","')),'$[*]' columns(extra VARCHAR(5) path '$')) j
WHERE cancellation IS NULL AND extras IS NOT NULL
GROUP BY j.extra
);

DROP TABLE IF EXISTS quantity_exclude;
CREATE temporary TABLE quantity_exclude AS
(SELECT Trim(j1.exclusion) AS exclusion, Count(exclusion) AS number_exclude
FROM customer_orders_pre c
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
JOIN json_table(trim(REPLACE(json_array(c.exclusions),',','","')),'$[*]' columns(exclusion VARCHAR(5) path '$')) j1
WHERE cancellation IS NULL AND exclusions IS NOT NULL
GROUP BY j1.exclusion
);

SELECT topping ,(Count(c.pizza_id) + Ifnull(number_extra,'') - Ifnull(number_exclude,'')) AS number_topping
FROM customer_orders_pre c
JOIN pizza_recipes_cleaned p1 ON c.pizza_id = p1.pizza_id
JOIN runner_orders_cleaned r1 ON c.order_id = r1.order_id
LEFT JOIN quantity_extra q1 ON p1.topping = q1.extra
LEFT JOIN quantity_exclude q2 ON p1.topping = q2.exclusion
WHERE cancellation IS NULL
GROUP BY topping
ORDER BY number_topping DESC
```

Result:
|   topping |   number_topping |
|----------:|-----------------:|
|         1 |               12 |
|         6 |               11 |
|         4 |               10 |
|         3 |                9 |
|         5 |                9 |
|         8 |                9 |
|        10 |                9 |
|         2 |                8 |
|         7 |                3 |
|         9 |                3 |
|        11 |                3 |
|        12 |                3 |


### D. Pricing and Ratings

**Q1: If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**
```sql
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
```

Result:

| total_sale   |
|:-------------|
| 138$         |

**Q2: What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra**

```sql
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
```

Result:

|   total_sales |
|--------------:|
|           142 |

**Q3: The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.**
```sql
DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
  order_id INT,
  rating INT);
INSERT INTO ratings (order_id, rating)
VALUES 
  (1,3),
  (2,5),
  (3,3),
  (4,1),
  (5,5),
  (7,3),
  (8,4),
  (10,3);
  
 SELECT *
 FROM ratings;
```

Result:

|   order_id |   rating |
|-----------:|---------:|
|          1 |        3 |
|          2 |        5 |
|          3 |        3 |
|          4 |        1 |
|          5 |        5 |
|          7 |        3 |
|          8 |        4 |
|         10 |        3 |

**Q4: Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas**
```sql
SELECT c.customer_id,
       c.order_id,
       runner_id,
       rating,
       order_time,
       pickup_time,
       TIMESTAMPDIFF(MINUTE, order_time, pickup_time) as time_between,
       duration_mins,
       AVG(distance_km/duration_mins) avg_speed,
       COUNT(*) AS pizza_count
FROM customer_orders c
LEFT JOIN runner_orders_cleaned r ON c.order_id = r.order_id
LEFT JOIN ratings rt ON c.order_id = rt.order_id
WHERE cancellation is null
GROUP BY c.customer_id,
       c.order_id,
       runner_id,
       rating,
       order_time,
       pickup_time,
       time_between,
       duration_mins

```

Result:

|   customer_id |   order_id |   runner_id |   rating | order_time          | pickup_time         |   time_between |   duration_mins |   avg_speed |   pizza_count |
|--------------:|-----------:|------------:|---------:|:--------------------|:--------------------|---------------:|----------------:|------------:|--------------:|
|           101 |          1 |           1 |        3 | 2020-01-01 18:05:02 | 2020-01-01 18:15:34 |             10 |              32 |     0.625   |             1 |
|           101 |          2 |           1 |        5 | 2020-01-01 19:00:52 | 2020-01-01 19:10:54 |             10 |              27 |     0.74074 |             1 |
|           102 |          3 |           1 |        3 | 2020-01-02 23:51:23 | 2020-01-03 00:12:37 |             21 |              20 |     0.67    |             2 |
|           103 |          4 |           2 |        1 | 2020-01-04 13:23:46 | 2020-01-04 13:53:03 |             29 |              40 |     0.585   |             3 |
|           104 |          5 |           3 |        5 | 2020-01-08 21:00:29 | 2020-01-08 21:10:57 |             10 |              15 |     0.66667 |             1 |
|           105 |          7 |           2 |        3 | 2020-01-08 21:20:29 | 2020-01-08 21:30:45 |             10 |              25 |     1       |             1 |
|           102 |          8 |           2 |        4 | 2020-01-09 23:54:33 | 2020-01-10 00:15:02 |             20 |              15 |     1.56    |             1 |
|           104 |         10 |           1 |        3 | 2020-01-11 18:34:49 | 2020-01-11 18:50:20 |             15 |              10 |     1       |             2 |

**Q5: If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?**
```sql
SELECT (SUM(CASE WHEN pizza_name = 'Meatlovers' THEN 12
			     WHEN pizza_name = 'Vegetarian' THEN 10
		         ELSE 0
		    END) - SUM(0.3*distance_km) ) AS profit
 FROM customer_orders c
 LEFT JOIN runner_orders_cleaned r ON c.order_id = r.order_id
 LEFT JOIN pizza_names p ON c.pizza_id = p.pizza_id
 WHERE cancellation IS NULL
```

Result:

|   profit |
|---------:|
|    73.38 |

### E. Bonus Questions
**If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?**

```sql
INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES (3, 'Supreme');

ALTER TABLE pizza_recipes
MODIFY COLUMN toppings VARCHAR(50);

INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
```

## Case Study #3: Foodie-Fi
### Introduction 

Subscription based businesses are super popular and Danny realised that there was a large gap in the market - he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows!

Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

### A. Customer Journey

Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

Solution: 
- Customer 1 started a trial plan on 2020-08-01 and after 7 days of the trial, they subscribed to Plan 1.
- Customer 2 started a trial plan on 2020-09-20 and after completing the 7-day trial, they subscribed to Plan 3.
- Customer 11 started a trial plan on 2020-12-15, then subscribed to Plan 1 on 2020-12-22, and subscribed to Plan 2 on 2021-03-29.
- Customer 15 started a trial plan on 2020-03-17, then subscribed to Plan 2 on 2020-03-24, and canceled the subscription on 2020-04-29.
- Customer 16 started a trial plan on 2020-05-31, then subscribed to Plan 1 on 2020-06-07, and subscribed to Plan 3 on 2020-10-21.
- Customer 18 started a trial plan on 2020-07-06 and subscribed to Plan 2 on 2020-07-13.
- Customer 19 started a trial plan on 2020-06-22 and subscribed to Plan 2 on 2020-06-29, then subscribed to Plan 3 on 2020-08-29.
- 
### B. Data Analysis Questions

**Q1. How many customers has Foodie-Fi ever had?**
```sql
SELECT COUNT(DISTINCT(customer_id)) as 'Number of customer'
FROM subscriptions
```
Result:

|   Number of customer |
|---------------------:|
|                 1000 |

**Q2.What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value**
```sql 
SELECT MONTH(start_date) as start_month, 
       YEAR(start_date) as start_year,
       COUNT(s.plan_id) as 'Number of trial plan'
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.plan_id = 0
GROUP BY start_month, start_year
ORDER BY COUNT(s.plan_id) DESC
```
Result:

|   start_month |   start_year |   Number of trial plan |
|--------------:|-------------:|-----------------------:|
|             3 |         2020 |                     94 |
|             7 |         2020 |                     89 |
|             8 |         2020 |                     88 |
|             1 |         2020 |                     88 |
|             5 |         2020 |                     88 |
|             9 |         2020 |                     87 |
|            12 |         2020 |                     84 |
|             4 |         2020 |                     81 |
|            10 |         2020 |                     79 |
|             6 |         2020 |                     79 |

**Q3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name**

```sql
SELECT plan_name, 
       COUNT(s.plan_id) as 'number of plan',
       YEAR(start_date) start_year
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE  YEAR(start_date) > 2020
GROUP BY s.plan_id
ORDER BY COUNT(s.plan_id) DESC
```
Result:

| plan_name     |   number of plan |   start_year |
|:--------------|-----------------:|-------------:|
| churn         |               71 |         2021 |
| pro annual    |               63 |         2021 |
| pro monthly   |               60 |         2021 |
| basic monthly |                8 |         2021 |

**Q4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**

```sql
SELECT COUNT(DISTINCT(customer_id)) as 'Total numver of customer',
SUM(CASE WHEN plan_name= 'churn' THEN 1 ELSE 0 END) AS churned_customers,
ROUND(CAST(SUM(CASE WHEN plan_name = 'churn' THEN 1 ELSE NULL END) as decimal(5,1)) / CAST(COUNT(DISTINCT customer_id) as decimal(5,1)) * 100,1) AS perc_churn
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
```
Result:

|   Total numver of customer |   churned_customers |   perc_churn |
|---------------------------:|--------------------:|-------------:|
|                       1000 |                 307 |         30.7 |

**Q5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number**
```sql
WITH temp AS
(SELECT customer_id,
        s.plan_id,
        plan_name, 
        LEAD (plan_name, 1) OVER (PARTITION BY customer_id ORDER BY s.plan_id) next_plan
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
)
SELECT (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS number_customer, 
	   COUNT(customer_id) AS churned_customer,
       CONCAT (ROUND((COUNT(customer_id)*100) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions)), '%' ) AS perc_churn
FROM temp t
WHERE plan_name = 'trial' AND next_plan = 'churn'
```
Result:

|   number_customer |   churned_customer | perc_churn   |
|------------------:|-------------------:|:-------------|
|              1000 |                 92 | 9%           |

**Q6.What is the number and percentage of customer plans after their initial free trial?**
```sql
WITH temp AS
(SELECT customer_id,s.plan_id,plan_name, 
LEAD (plan_name, 1) OVER (PARTITION BY customer_id order by s.plan_id) next_plan
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
)
SELECT next_plan, 
	   COUNT(DISTINCT customer_id) as customer_plan,
	   (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS number_customer, 
	   CONCAT (CAST(COUNT(DISTINCT customer_id) as float)*100 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), '%' ) AS perc_plan
FROM temp 
WHERE plan_name = 'trial' and next_plan is not null
GROUP BY next_plan
```
Result:

| next_plan     |   customer_plan |   number_customer | perc_plan   |
|:--------------|----------------:|------------------:|:------------|
| basic monthly |             546 |              1000 | 54.6%       |
| churn         |              92 |              1000 | 9.2%        |
| pro annual    |              37 |              1000 | 3.7%        |
| pro monthly   |             325 |              1000 | 32.5%       |

**Q7.What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**
```sql
WITH temp AS 
(SELECT customer_id, 
		s.plan_id, 
        start_date, 
        LEAD(start_date, 1) OVER (PARTITION BY customer_id ORDER BY plan_id) as next_date
FROM subscriptions s
WHERE start_date <= '2020-12-31'
)
SELECT plan_name, 
       COUNT(customer_id) as num_customer,
       CONCAT(CAST(COUNT(customer_id) as float)*100/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions WHERE start_date <= '2020-12-31'),'%') as perc_plan
FROM temp t
JOIN plans p ON t.plan_id = p.plan_id
WHERE next_date is null or next_date > '2020-12-31'
GROUP BY plan_name
```
Result:

| plan_name     |   num_customer | perc_plan   |
|:--------------|---------------:|:------------|
| trial         |             19 | 1.9%        |
| basic monthly |            224 | 22.4%       |
| pro monthly   |            326 | 32.6%       |
| pro annual    |            195 | 19.5%       |
| churn         |            236 | 23.6%       |

**Q8.How many customers have upgraded to an annual plan in 2020?**
```sql
SELECT plan_name, 
        COUNT(s.plan_id) as number_annual_plan
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE plan_name = 'pro annual' and start_date <='2020-12-31'
GROUP BY plan_name;
```
Result:

| plan_name   |   number_annual_plan |
|:------------|---------------------:|
| pro annual  |                  195 |

**Q9.How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**
```sql
DROP TABLE IF EXISTS annual_date;
CREATE temporary TABLE annual_date AS(
SELECT customer_id,
       start_date
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE plan_name = 'pro annual')
WITH temp1 AS (
SELECT s.customer_id,
       s.start_date, 
       a.start_date as annual_date,
       RANK() OVER(PARTITION BY customer_id ORDER BY s.plan_id) as join_date
FROM subscriptions s
LEFT JOIN annual_date a ON s.start_date = a.start_date AND s.customer_id = a.customer_id)
, temp2 AS (
SELECT customer_id, 
       start_date,
       LEAD(start_date,1) OVER(PARTITION BY customer_id) AS annual
FROM temp1
WHERE join_date = 1 or annual_date is not null )
SELECT ROUND(AVG(DATEDIFF(annual,start_date))) as 'avg days from join to annual'
FROM temp2
```
Result:

|   avg days from join to annual |
|-------------------------------:|
|                            105 |

**10.Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**
```sql
WITH trial_plan AS (
    SELECT customer_id, 
	   start_date AS trial_date
    FROM subscriptions
    WHERE plan_id = 0
),
annual_plan AS (
    SELECT customer_id,
	   start_date as annual_date
    FROM subscriptions
    WHERE plan_id = 3
)
SELECT
    CONCAT(FLOOR(TIMESTAMPDIFF(day, trial_date, annual_date) / 30) * 30, '-', FLOOR(TIMESTAMPDIFF(day, trial_date, annual_date) / 30) * 30 + 30, ' days') AS period,
    COUNT(*) AS total_customers,
    ROUND(AVG(TIMESTAMPDIFF(day, trial_date, annual_date)), 0) AS avg_days_to_upgrade
FROM trial_plan tp
JOIN annual_plan ap ON tp.customer_id = ap.customer_id
WHERE ap.annual_date IS NOT NULL
GROUP BY FLOOR(TIMESTAMPDIFF(day, trial_date, annual_date) / 30);
```
Result:

| period       |   total_customers |   avg_days_to_upgrade |
|:-------------|------------------:|----------------------:|
| 0-30 days    |                48 |                    10 |
| 120-150 days |                43 |                   133 |
| 60-90 days   |                33 |                    71 |
| 30-60 days   |                25 |                    42 |
| 150-180 days |                35 |                   162 |
| 90-120 days  |                35 |                   100 |
| 180-210 days |                27 |                   190 |
| 330-360 days |                 1 |                   346 |
| 240-270 days |                 5 |                   257 |
| 210-240 days |                 4 |                   224 |
| 270-300 days |                 1 |                   285 |
| 300-330 days |                 1 |                   327 |

**Q11.How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**
```sql
WITH temp AS
(SELECT *, 
        LEAD(plan_id,1) OVER( PARTITION BY customer_id ORDER BY plan_id) as next_plan
FROM subscriptions
WHERE start_date <= '2020-12-31')
SELECT COUNT(*) as num_downgrade
FROM temp
WHERE next_plan = 1 AND plan_id = 2;
```
Result:
|   num_downgrade |
|----------------:|
|               0 |

### C. Challenge Payment Question
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
once a customer churns they will no longer make payments

Solution:
```sql
DROP TABLE IF EXISTS payments;
CREATE TABLE payments AS (
WITH RECURSIVE payment_dates AS (
SELECT s.customer_id,
       s.plan_id,
       p.plan_name,
       s.start_date AS payment_date, 
       CASE WHEN LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) IS NULL THEN '2020-12-31'
			ELSE DATE_ADD( start_date, INTERVAL TIMESTAMPDIFF(MONTH,start_date,LEAD(start_date) OVER(PARTITION BY s.customer_id ORDER BY start_date)) MONTH)
            END AS last_date,
       p.price AS amount
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE p.plan_name NOT IN ('trial','churn') AND YEAR(start_date) = 2020
UNION ALL 
SELECT customer_id,
       plan_id,
       plan_name,
       DATE_ADD(payment_date, INTERVAL 1 MONTH) payment_date,
       last_date,
       amount
FROM payment_dates
WHERE DATE_ADD(payment_date, INTERVAL 1 MONTH) < last_date AND plan_name NOT IN ( 'pro annual')

),
upgrade_plan AS (
SELECT customer_id,
	   plan_id,
       LAG(plan_id,1) OVER(PARTITION BY customer_id ORDER BY payment_date) pre_plan,
       plan_name,
       payment_date,
       last_date,
       amount,
       LAG(amount,1) OVER (PARTITION BY customer_id ORDER BY payment_date) pre_amount
FROM payment_dates
)
SELECT customer_id,
	   plan_id,
       plan_name,
       payment_date,       
       CASE WHEN plan_name IN ('pro monthly', 'pro annual') AND pre_plan = 1 THEN amount - pre_amount
            ELSE amount
		END AS amount,
        RANK() OVER(PARTITION BY customer_id ORDER BY payment_date) payment_order
FROM upgrade_plan
WHERE plan_name != 'churn'
ORDER BY customer_id
);
SELECT * FROM payments
```
Result:
|   customer_id |   plan_id | plan_name     | payment_date   |   amount |   payment_order |
|--------------:|----------:|:--------------|:---------------|---------:|----------------:|
|             1 |         1 | basic monthly | 2020-08-08     |      9.9 |               1 |
|             1 |         1 | basic monthly | 2020-09-08     |      9.9 |               2 |
|             1 |         1 | basic monthly | 2020-10-08     |      9.9 |               3 |
|             1 |         1 | basic monthly | 2020-11-08     |      9.9 |               4 |
|             1 |         1 | basic monthly | 2020-12-08     |      9.9 |               5 |
|             2 |         3 | pro annual    | 2020-09-27     |      199 |               1 |
|             3 |         1 | basic monthly | 2020-01-20     |      9.9 |               1 |
|             3 |         1 | basic monthly | 2020-02-20     |      9.9 |               2 |
|             3 |         1 | basic monthly | 2020-03-20     |      9.9 |               3 |
|             3 |         1 | basic monthly | 2020-04-20     |      9.9 |               4 |

### D. Outside The Box Questions
The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!

**Q1. How would you calculate the rate of growth for Foodie-Fi?**
```sql
WITH monthlyRevenue AS (
  SELECT 
    MONTH(payment_date) AS months,
    SUM(amount) AS revenue
  FROM payments
  GROUP BY MONTH(payment_date)
)
SELECT 
  months,
  revenue,
  LAG(revenue) OVER(ORDER BY months) pre_revenue,
  (revenue-LAG(revenue) OVER(ORDER BY months))/revenue AS revenue_growth
FROM monthlyRevenue;
```
Result: 
|   months |   revenue |   pre_revenue |   revenue_growth |
|---------:|----------:|--------------:|-----------------:|
|        1 |    1272.1 |           nan |              nan |
|        2 |      2753 |        1272.1 |         0.537922 |
|        3 |    4184.3 |          2753 |         0.342064 |
|        4 |    5785.1 |        4184.3 |         0.276711 |
|        5 |    7097.2 |        5785.1 |         0.184876 |
|        6 |    8548.8 |        7097.2 |         0.169802 |
|        7 |     10180 |        8548.8 |         0.160236 |
|        8 |   11950.6 |         10180 |         0.14816  |
|        9 |   13114.1 |       11950.6 |         0.088721 |
|       10 |   15312.7 |       13114.1 |         0.14358  |
|       11 |     13610 |       15312.7 |        -0.125107 |
|       12 |   14712.9 |         13610 |         0.074961 |

**Q2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?**

Solution:
Key metrics: revenue growth by monthly, churn rate, customer growth

**Q3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?**

Solution:
- Customers who downgraded their plan
- Customers who upgraded from basic monthly to pro monthly or pro annual
- Customers who cancelled the subscription

**Q4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?**

Solution:

**Q5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?**

Solution:

## Case Study #4: Data Bank

### A. Customer Nodes Exploration
### B. Customer Transactions
### C. Data Allocation Challenge
### D. Extra Challenge
### E. Extension Request

## Case Study #5: Data Mart
### A. Data Cleansing Steps
### B. Data Exploration
### C. Before & After Analysis
### D. Bonus Question

## Case Study #6: Clique Bait
### A. Enterprise Relationship Diagram
### B. Digital Analysis
### C. Product Funnel Analysis
### D. Campaigns Analysis

## Case Study #7: Balanced Tree
### A. High Level Sales Analysis
### B. Transactional Analysis
### C. Product Analysis
### D. Reporting Challenge 
### E. Bonus Challenge

## Case Study #8: Fresh Segments
### A. Data Exploration and Cleansing
### B. Interest Anlysis
### C. Segment Analysis
### D. Index Analysis
