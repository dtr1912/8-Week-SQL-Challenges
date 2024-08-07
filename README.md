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
  - [A. Customer Journey](#a-customer-journey)
  - [B. Data Analysis Questions](#b-data-analysis)
  - [C. Challenge Payment Question](#c-challenge-payment-question)
  - [D. Outside The Box Questions](#d-outside-the-box-questions)
- [Case Study #4: Data Bank](#case-study-4-data-bank)
  - [A. Customer Nodes Exploration](#a-customer-nodes-exploration)
  - [B. Customer Transactions](#b-customer-transactions)
  - [C. Data Allocation Challenge](#c-data-allocation-challenge)
  - [D. Extra Challenge](#d-extra-challenge)
  - [E. Extension Request](#e-extension-request)
- [Case Study #5: Data Mart](#case-study-5-data-mart)
  - [A. Data Cleansing Steps](#a-data-cleansing-steps)
  - [B. Data Exploration](#b-data-exploration)
  - [C. Before & After Analysis](#c-before--after-analysis)
  - [D. Bonus Question](#d-bonus-question)
- [Case Study #6: Clique Bait](#case-study-6-clique-bait)
  - [A. Enterprise Relationship Diagram](#a-enterprise-relationship-diagram)
  - [B. Digital Analysis](#b-digital-analysis)
  - [C. Product Funnel Analysis](#c-product-funnel-analysis)
  - [D. Campaigns Analysis](#d-campaigns-analysis)
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
  - [D. Index Analysis](#d-index-analysis)

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

### B. Bonus Questions
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
### Introduction
There is a new innovation in the financial industry called Neo-Banks: new aged digital only banks without physical branches.

Danny thought that there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so he decides to launch a new initiative - Data Bank!

Data Bank runs just like any other digital bank - but it isn’t only for banking activities, they also have the world’s most secure distributed data storage platform!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help!

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!
### A. Customer Nodes Exploration
**Q1. How many unique nodes are there on the Data Bank system? There are 5 unique nodes on the Data Bank system**
```sql
SELECT COUNT(DISTINCT node_id) 'Number of node'
FROM  customer_nodes
```
Result:

|   Number of node |
|-----------------:|
|                5 |

**Q2. What is the number of nodes per region?**
```sql
SELECT region_name, 
       COUNT(node_id) as 'Number of nodes per region'
FROM customer_nodes n
JOIN regions r ON n.region_id=r.region_id
GROUP BY n.region_id
```
Result:'

| region_name   |   Number of nodes per region |
|:--------------|-----------------------------:|
| Australia     |                          770 |
| America       |                          735 |
| Africa        |                          714 |
| Asia          |                          665 |
| Europe        |                          616 |

**Q3. How many customers are allocated to each region?**
```sql
SELECT region_name, 
       COUNT(DISTINCT customer_id)  'Number of customers each region'
FROM customer_nodes n
JOIN regions r ON n.region_id = r.region_id
GROUP BY n.region_id
```
Result:

| region_name   |   Number of customers each region |
|:--------------|----------------------------------:|
| Australia     |                               110 |
| America       |                               105 |
| Africa        |                               102 |
| Asia          |                                95 |
| Europe        |                                88 |

**Q4. How many days on average are customers reallocated to a different node?**
```sql
SELECT ROUND(AVG(DATEDIFF(end_date,start_date))) avg_reallocation_days
FROM customer_nodes 
WHERE end_date != '9999-12-31'
```
Result:
On average, customers are reallocated to a different node every 15 days.

|   avg_reallocation_days |
|------------------------:|
|                      15 |

**Q5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**
```sql
WITH  temp_cte AS (
SELECT *, 
       SUM(DATEDIFF(end_date, start_date)) day_diff, 
	   NTILE(100) OVER(PARTITION BY region_id ORDER BY SUM(DATEDIFF(end_date, start_date))) percentile 
FROM customer_nodes 
WHERE end_date != '9999-12-31' 
GROUP BY customer_id, 
         region_id, 
         node_id, 
         start_date, 
         end_date
) 
SELECT
  region_name, 
  MAX(IF(percentile = 50, day_diff, NULL)) AS median, 
  MAX(IF(percentile = 80, day_diff, NULL)) AS 80_percentile, 
  MAX(IF(percentile = 95, day_diff, NULL)) AS 95_percentile
FROM
(
    SELECT  
      region_id, 
      day_diff, 
      percentile 
    FROM
      temp_cte 
    WHERE 
      percentile IN (50, 80, 95) 
    GROUP BY 
      region_id, 
      day_diff, 
      percentile
) temp 
LEFT JOIN regions ON temp.region_id = regions.region_id 
GROUP BY region_name;
```
Result:

| region_name   |   median |   80_percentile |   95_percentile |
|:--------------|---------:|----------------:|----------------:|
| Australia     |       16 |              24 |              28 |
| America       |       16 |              23 |              28 |
| Africa        |       15 |              24 |              28 |
| Asia          |       15 |              24 |              28 |
| Europe        |       16 |              24 |              28 |

### B. Customer Transactions
**Q1. What is the unique count and total amount for each transaction type?**
SELECT txn_type 'Transaction Type',
	   COUNT(txn_type) 'Number of Unique Type',
       SUM(txn_amount) 'Total Amount'
FROM customer_transactions
GROUP BY txn_type

Result:

| Transaction Type   |   Number of Unique Type |   Total Amount |
|:-------------------|------------------------:|---------------:|
| deposit            |                    2671 |        1359168 |
| withdrawal         |                    1580 |         793003 |
| purchase           |                    1617 |         806537 |

**Q2. What is the average total historical deposit counts and amounts for all customers?**
```sql
WITH deposit AS (
SELECT customer_id,
	   COUNT(txn_type) deposit_count,
       SUM(txn_amount) amount
FROM customer_transactions
WHERE txn_type = 'deposit'
GROUP BY customer_id
)
SELECT AVG(deposit_count) avg_deposit_count,
       AVG(amount) avg_amount
FROM deposit
```
Result:
|   avg_deposit_count |   avg_amount |
|--------------------:|-------------:|
|               5.342 |      2718.34 |

**Q3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**
```sql
WITH temp AS (
SELECT  MONTHNAME(txn_date) as  Month_name,
        customer_id,
        SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) deposit_count,
        SUM(CASE WHEN txn_type = 'withdrawl' THEN 1 ELSE 0 END) withdrawl_count,
        SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) purchase_count
FROM customer_transactions
GROUP BY MONTHNAME(txn_date), customer_id
)
SELECT month_name, 
	   COUNT(customer_id)  customer_count
FROM temp 
WHERE deposit_count > 1 AND  (withdrawl_count >= 1 OR purchase_count >= 1)
GROUP BY month_name
```
Result:
| month_name   |   customer_count |
|:-------------|-----------------:|
| January      |              128 |
| March        |              146 |
| April        |               55 |
| February     |              135 |

**Q4. What is the closing balance for each customer at the end of the month?**
```sql 
-- End date in the month of the max date of our dataset
WITH RECURSIVE recursive_dates AS (
  SELECT
    DISTINCT customer_id,
    CAST("2020-01-31" AS DATE) AS end_date
  FROM customer_transactions
  UNION ALL
  SELECT 
    customer_id,
    LAST_DAY(DATE_ADD(end_date, INTERVAL 1 MONTH)) AS end_date
  FROM recursive_dates
  WHERE LAST_DAY(DATE_ADD(end_date, INTERVAL 1 MONTH)) <= (SELECT LAST_DAY(MAX(txn_date)) FROM customer_transactions)
), 
monthly_transactions AS (
  SELECT
    customer_id,
    LAST_DAY(txn_date) AS end_date,
    SUM(CASE WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
             ELSE txn_amount 
	    END) AS transactions
  FROM customer_transactions
  GROUP BY customer_id, LAST_DAY(txn_date)
)				
SELECT 
  r.customer_id,
  r.end_date,
  COALESCE(m.transactions, 0) AS transactions,
  SUM(m.transactions) OVER (PARTITION BY r.customer_id ORDER BY r.end_date ROWS UNBOUNDED PRECEDING) AS closing_balance
FROM recursive_dates r
LEFT JOIN  monthly_transactions m ON r.customer_id = m.customer_id AND r.end_date = m.end_date;
```
Result: (Limit 17 rows)
|   customer_id | end_date   |   transactions |   closing_balance |
|--------------:|:-----------|---------------:|------------------:|
|             1 | 2020-01-31 |            312 |               312 |
|             1 | 2020-02-29 |              0 |               312 |
|             1 | 2020-03-31 |           -952 |              -640 |
|             1 | 2020-04-30 |              0 |              -640 |
|             2 | 2020-01-31 |            549 |               549 |
|             2 | 2020-02-29 |              0 |               549 |
|             2 | 2020-03-31 |             61 |               610 |
|             2 | 2020-04-30 |              0 |               610 |
|             3 | 2020-01-31 |            144 |               144 |
|             3 | 2020-02-29 |           -965 |              -821 |
|             3 | 2020-03-31 |           -401 |             -1222 |
|             3 | 2020-04-30 |            493 |              -729 |
|             4 | 2020-01-31 |            848 |               848 |
|             4 | 2020-02-29 |              0 |               848 |
|             4 | 2020-03-31 |           -193 |               655 |
|             4 | 2020-04-30 |              0 |               655 |
|             5 | 2020-01-31 |            954 |               954 |

**Q5. What is the percentage of customers who increase their closing balance by more than 5%?**
```sql
-- 75.8% of customers increasing their closing balance by more than 5% compared to the previous month.
WITH RECURSIVE recursive_dates AS (
  SELECT
    DISTINCT customer_id,
    CAST("2020-01-31" AS DATE) AS end_date
  FROM customer_transactions
  UNION ALL
  SELECT 
    customer_id,
    LAST_DAY(DATE_ADD(end_date, INTERVAL 1 MONTH)) AS end_date
  FROM recursive_dates
  WHERE LAST_DAY(DATE_ADD(end_date, INTERVAL 1 MONTH)) <= (SELECT LAST_DAY(MAX(txn_date)) FROM customer_transactions)
), 
monthly_transactions AS (
  SELECT
    customer_id,
    LAST_DAY(txn_date) AS end_date,
    SUM(CASE WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
             ELSE txn_amount 
	    END) AS transactions
  FROM customer_transactions
  GROUP BY customer_id, LAST_DAY(txn_date)
),
customers_balance AS (
SELECT 
  r.customer_id,
  r.end_date,
  COALESCE(m.transactions, 0) AS transactions,
  SUM(m.transactions) OVER (PARTITION BY r.customer_id ORDER BY r.end_date ROWS UNBOUNDED PRECEDING) AS closing_balance
FROM recursive_dates r
LEFT JOIN  monthly_transactions m ON r.customer_id = m.customer_id AND r.end_date = m.end_date
),
customers_next_balance AS (
  SELECT *,
    LEAD(closing_balance) OVER(PARTITION BY customer_id ORDER BY end_date) AS next_balance
  FROM customers_balance
),
pct_increase AS (
  SELECT *,
    100.0*(next_balance-closing_balance)/closing_balance AS pct
  FROM customers_next_balance
  WHERE closing_balance != 0 AND next_balance IS NOT NULL
)
SELECT (100.0*COUNT(DISTINCT customer_id)) / (SELECT COUNT(DISTINCT customer_id) FROM customer_transactions) AS pct_customers
FROM pct_increase
WHERE pct > 5;
```
Result:

|   pct_customers |
|----------------:|
|            75.8 |

### C. Data Allocation Challenge
To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:
 
- Option 1: data is allocated based off the amount of money at the end of the previous month
- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
- Option 3: data is updated real-time
For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

- running customer balance column that includes the impact each transaction
- customer balance at the end of each month
- minimum, average and maximum values of the running balance for each customer
  
Using all of the data available - how much data would have been required for each option on a monthly basis?**

Solution:

```sql
WITH RECURSIVE recursive_dates AS (
SELECT DISTINCT customer_id,
       CAST("2020-01-31" AS DATE) AS end_date
FROM customer_transactions 
UNION ALL
SELECT customer_id,
       LAST_DAY(DATE_ADD(end_date, INTERVAL 1 MONTH)) AS end_date
FROM recursive_dates 
WHERE LAST_DAY(DATE_ADD(end_date, INTERVAL 1 MONTH)) <= (SELECT LAST_DAY(MAX(txn_date)) FROM customer_transactions)
),
transactions AS (
SELECT customer_id,
       LAST_DAY(txn_date) end_date,
       txn_date,
       SUM(CASE WHEN txn_type IN ('purchase', 'withdrawal') THEN -txn_amount
                 ELSE txn_amount
			END) transactions
FROM customer_transactions 
GROUP BY customer_id, txn_date
),
monthly_transactions AS (
SELECT customer_id,
       LAST_DAY(txn_date) end_date,
       txn_date,
       SUM(CASE WHEN txn_type IN ('purchase', 'withdrawal') THEN -txn_amount
                 ELSE txn_amount
			END) transactions
FROM customer_transactions 
GROUP BY customer_id, end_date
),
balance AS (
SELECT r.customer_id,
       r.end_date,
       txn_date,
	   COALESCE(transactions, 0) transactions,
       SUM(transactions) OVER(PARTITION BY customer_id ORDER BY txn_date ROWS UNBOUNDED PRECEDING) running_balance
FROM recursive_dates r
LEFT JOIN transactions t ON r.customer_id = t.customer_id AND r.end_date = t.end_date
ORDER BY r.customer_id,r.end_date
),
pre_balance AS (
SELECT *,
       LAG(running_balance,1) OVER(PARTITION BY customer_id ORDER BY end_date) pre_balance
FROM balance
),
monthly_balance AS (
SELECT r.customer_id,
       r.end_date,
	   COALESCE(transactions, 0) transactions,
       SUM(transactions) OVER(PARTITION BY customer_id ORDER BY end_date ROWS UNBOUNDED PRECEDING) monthly_balance
FROM recursive_dates r
LEFT JOIN monthly_transactions m ON r.customer_id = m.customer_id AND r.end_date = m.end_date
)
SELECT b.customer_id,
       b.end_date,
       txn_date,
       b.transactions,
       (CASE WHEN txn_date IS NULL THEN pre_balance
			 ELSE running_balance 
		END) running_balance,
        MIN(running_balance) OVER(PARTITION BY customer_id) min_balance,
	    MAX(running_balance) OVER(PARTITION BY customer_id) max_balance,
	    AVG(running_balance) OVER(PARTITION BY customer_id) avg_balance,
        monthly_balance
FROM pre_balance b
LEFT JOIN monthly_balance m ON b.customer_id = m.customer_id AND b.end_date = m.end_date
```

Result: 
|   customer_id | end_date   | txn_date   |   transactions |   running_balance |   min_balance |   max_balance |   avg_balance |   monthly_balance |
|--------------:|:-----------|:-----------|---------------:|------------------:|--------------:|--------------:|--------------:|------------------:|
|             1 | 2020-01-31 | 2020-01-02 |            312 |               312 |          -640 |           312 |     -151      |               312 |
|             1 | 2020-02-29 | nan        |              0 |               312 |          -640 |           312 |     -151      |               312 |
|             1 | 2020-03-31 | 2020-03-05 |           -612 |              -300 |          -640 |           312 |     -151      |              -640 |
|             1 | 2020-03-31 | 2020-03-17 |            324 |                24 |          -640 |           312 |     -151      |              -640 |
|             1 | 2020-03-31 | 2020-03-19 |           -664 |              -640 |          -640 |           312 |     -151      |              -640 |
|             1 | 2020-04-30 | nan        |              0 |              -640 |          -640 |           312 |     -151      |              -640 |
|             2 | 2020-01-31 | 2020-01-03 |            549 |               549 |           549 |           610 |      579.5    |               549 |
|             2 | 2020-02-29 | nan        |              0 |               549 |           549 |           610 |      579.5    |               549 |
|             2 | 2020-03-31 | 2020-03-24 |             61 |               610 |           549 |           610 |      579.5    |               610 |
|             2 | 2020-04-30 | nan        |              0 |               610 |           549 |           610 |      579.5    |               610 |
|             3 | 2020-01-31 | 2020-01-27 |            144 |               144 |         -1222 |           144 |     -732.4    |               144 |
|             3 | 2020-02-29 | 2020-02-22 |           -965 |              -821 |         -1222 |           144 |     -732.4    |              -821 |
|             3 | 2020-03-31 | 2020-03-05 |           -213 |             -1034 |         -1222 |           144 |     -732.4    |             -1222 |
|             3 | 2020-03-31 | 2020-03-19 |           -188 |             -1222 |         -1222 |           144 |     -732.4    |             -1222 |
|             3 | 2020-04-30 | 2020-04-12 |            493 |              -729 |         -1222 |           144 |     -732.4    |              -729 |
|             4 | 2020-01-31 | 2020-01-07 |            458 |               458 |           458 |           848 |      653.667  |               848 |
|             4 | 2020-01-31 | 2020-01-21 |            390 |               848 |           458 |           848 |      653.667  |               848 |
|             4 | 2020-02-29 | nan        |              0 |               848 |           458 |           848 |      653.667  |               848 |
|             4 | 2020-03-31 | 2020-03-25 |           -193 |               655 |           458 |           848 |      653.667  |               655 |
|             4 | 2020-04-30 | nan        |              0 |               655 |           458 |           848 |      653.667  |               655 |
|             5 | 2020-01-31 | 2020-01-15 |            974 |               974 |         -2413 |          1780 |     -120.2    |               954 |
|             5 | 2020-01-31 | 2020-01-25 |            806 |              1780 |         -2413 |          1780 |     -120.2    |               954 |

### D. Extra Challenge
Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest calculation, just like in a traditional savings account you might have with a bank.

If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their data allocation based off the interest calculated on a daily basis at the end of each day, how much data would be required for this option on a monthly basis?

Special notes:
- Data Bank wants an initial calculation which does not allow for compounding interest, however they may also be interested in a daily compounding interest calculation so you can try to perform this calculation if you have the stamina!

### E. Extension Request
The Data Bank team wants you to use the outputs generated from the above sections to create a quick Powerpoint presentation which will be used as marketing materials for both external investors who might want to buy 

Data Bank shares and new prospective customers who might want to bank with Data Bank.

**Q1. Using the outputs generated from the customer node questions, generate a few headline insights which Data Bank might use to market it’s world-leading security features to potential investors and customers.**

**Q2. With the transaction analysis - prepare a 1 page presentation slide which contains all the relevant information about the various options for the data provisioning so the Data Bank management team can make an informed decision.**

## Case Study #5: Data Mart
### Introduction
Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance.

In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

The key business question he wants you to help him answer are the following:

What was the quantifiable impact of the changes introduced in June 2020?

Which platform, region, segment and customer types were the most impacted by this change?

What can we do about future introduction of similar sustainability updates to the business to minimise impact on sales?
### A. Data Cleansing Steps

```sql
-- In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TABLE clean_weekly_sales AS (
WITH clean AS (
SELECT CAST(CONCAT(substring_index(substring_index(week_date,'/',3 ),'/',-1), "-",
				   substring_index(substring_index(week_date,'/',2 ),'/',-1), "-",
				   substring_index(week_date,'/',1)) AS DATE) week_date,
		region,
        platform,
        customer_type,
		CASE WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
             WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
             WHEN RIGHT(segment,1) IN ('3','4') THEN 'Retirees'
		     ELSE "unknown"
		END as age_band,
        CASE WHEN LEFT(segment,1) = 'C' THEN 'Couples'
             WHEN LEFT(segment,1) = 'F' THEN 'Families'
             ELSE "unknown"
		END as demographic,
        transactions,
        sales,
        ROUND(sales/transactions, 2) avg_transactions
FROM weekly_sales 
)
SELECT week_date,
       WEEK(week_date) as week_number,
       MONTH(week_date) as month_number,
       YEAR(week_date) as calendar_year,
       region,
       platform,
       customer_type,
       age_band,
       demographic,
       transactions,
       sales,
       avg_transactions
FROM clean
)
SELECT * FROM clean_weekly_sales;
```

Result:
| week_date   |   week_number |   month_number |   calendar_year | region   | platform   | customer_type   | age_band     | demographic   |   transactions |    sales |   avg_transactions |
|:------------|--------------:|---------------:|----------------:|:---------|:-----------|:----------------|:-------------|:--------------|---------------:|---------:|-------------------:|
| 2020-08-31  |            35 |              8 |            2020 | ASIA     | Retail     | New             | Retirees     | Couples       |         120631 |  3656163 |              30.31 |
| 2020-08-31  |            35 |              8 |            2020 | ASIA     | Retail     | New             | Young Adults | Families      |          31574 |   996575 |              31.56 |
| 2020-08-31  |            35 |              8 |            2020 | USA      | Retail     | Guest           | unknown      | unknown       |         529151 | 16509610 |              31.2  |
| 2020-08-31  |            35 |              8 |            2020 | EUROPE   | Retail     | New             | Young Adults | Couples       |           4517 |   141942 |              31.42 |
| 2020-08-31  |            35 |              8 |            2020 | AFRICA   | Retail     | New             | Middle Aged  | Couples       |          58046 |  1758388 |              30.29 |
| 2020-08-31  |            35 |              8 |            2020 | CANADA   | Shopify    | Existing        | Middle Aged  | Families      |           1336 |   243878 |             182.54 |
| 2020-08-31  |            35 |              8 |            2020 | AFRICA   | Shopify    | Existing        | Retirees     | Families      |           2514 |   519502 |             206.64 |
| 2020-08-31  |            35 |              8 |            2020 | ASIA     | Shopify    | Existing        | Young Adults | Families      |           2158 |   371417 |             172.11 |
| 2020-08-31  |            35 |              8 |            2020 | AFRICA   | Shopify    | New             | Middle Aged  | Families      |            318 |    49557 |             155.84 |
| 2020-08-31  |            35 |              8 |            2020 | AFRICA   | Retail     | New             | Retirees     | Couples       |         111032 |  3888162 |              35.02 |

### B. Data Exploration
**Q1. What day of the week is used for each week_date value?**
```sql
SELECT DISTINCT(dayname(week_date)) AS week_day 
FROM clean_weekly_sales
```
Result:

| week_day   |
|:-----------|
| Monday     |


**Q2. What range of week numbers are missing from the dataset?**
```sql
WITH RECURSIVE all_week AS 
(
SELECT 1 AS week_number
UNION ALL 
SELECT week_number + 1 AS week_number
FROM all_week
WHERE week_number < 52
)
SELECT week_number
FROM all_week
WHERE week_number NOT IN (SELECT week_number FROM clean_weekly_sales)
```
Result:

|   week_number |
|--------------:|
|             1 |
|             2 |
|             3 |
|             4 |
|             5 |
|             6 |
|             7 |
|             8 |
|             9 |
|            10 |
|            11 |
|            36 |
|            37 |
|            38 |
|            39 |
|            40 |
|            41 |
|            42 |
|            43 |
|            44 |
|            45 |
|            46 |
|            47 |
|            48 |
|            49 |
|            50 |
|            51 |
|            52 |


**Q3. How many total transactions were there for each year in the dataset?**
```sql
SELECT calendar_year,
       SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year
```
Result:
|   calendar_year |   total_transactions |
|----------------:|---------------------:|
|            2018 |          346406460   |
|            2019 |          365639285   |
|            2020 |          375813651   |

**Q4. What is the total sales for each region for each month?**
```sql
SELECT region, 
       calendar_year,
	   month_number,
       SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region,
         month_number,
         calendar_year
ORDER BY region,
         calendar_year,
         month_number
```
Result:
| region   |   calendar_year |   month_number |   total_sales |
|:---------|----------------:|---------------:|--------------:|
| AFRICA   |            2018 |              3 |     130542213 |
| AFRICA   |            2018 |              4 |     650194751 |
| AFRICA   |            2018 |              5 |     522814997 |
| AFRICA   |            2018 |              6 |     519127094 |
| AFRICA   |            2018 |              7 |     674135866 |
| AFRICA   |            2018 |              8 |     539077371 |
| AFRICA   |            2018 |              9 |     135084533 |
| AFRICA   |            2019 |              3 |     141619349 |
| AFRICA   |            2019 |              4 |     700447301 |
| AFRICA   |            2019 |              5 |     553828220 |


**Q5. What is the total count of transactions for each platform**
```sql
SELECT 
  platform,
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform
```
Result:

| platform   |   total_transactions |
|:-----------|---------------------:|
| Retail     |           1081934227 |
| Shopify    |              5925169 |


**Q6. What is the percentage of sales for Retail vs Shopify for each month?**
```sql
SELECT 
       calendar_year,
       month_number,
       SUM(CASE WHEN platform = 'Retail' THEN sales 
				ELSE 0
		   END) *100/SUM(sales) AS retail_sales_pct,
	   SUM(CASE WHEN platform = 'Shopify' THEN sales 
				ELSE 0
		   END) *100/SUM(sales)  AS shopify_sales_pct
FROM clean_weekly_sales
GROUP BY month_number,
         calendar_year
ORDER BY calendar_year, month_number
```
Result:
|   calendar_year |   month_number |   retail_sales_pct |   shopify_sales_pct |
|----------------:|---------------:|-------------------:|--------------------:|
|            2018 |              3 |            97.9185 |              2.0815 |
|            2018 |              4 |            97.9259 |              2.0741 |
|            2018 |              5 |            97.7279 |              2.2721 |
|            2018 |              6 |            97.7555 |              2.2445 |
|            2018 |              7 |            97.753  |              2.247  |
|            2018 |              8 |            97.7063 |              2.2937 |
|            2018 |              9 |            97.6786 |              2.3214 |
|            2019 |              3 |            97.7066 |              2.2934 |
|            2019 |              4 |            97.8002 |              2.1998 |
|            2019 |              5 |            97.5249 |              2.4751 |


**Q7. What is the percentage of sales by demographic for each year in the dataset?**
```sql
SELECT 
       calendar_year,
       demographic,
       SUM(sales)*100/ (SELECT SUM(sales) FROM clean_weekly_sales) AS demographic_sales_pct
FROM clean_weekly_sales
GROUP BY calendar_year, 
         demographic
```
Result:

|   calendar_year | demographic   |   demographic_sales_pct |
|----------------:|:--------------|------------------------:|
|            2020 | Couples       |                  9.9391 |
|            2020 | Families      |                 11.3253 |
|            2020 | unknown       |                 13.3427 |
|            2019 | unknown       |                 13.5797 |
|            2019 | Couples       |                  9.2021 |
|            2019 | Families      |                 10.9561 |
|            2018 | unknown       |                 13.1786 |
|            2018 | Couples       |                  8.3507 |
|            2018 | Families      |                 10.1257 |

**Q8. Which age_band and demographic values contribute the most to Retail sales?**
```sql
SELECT
  age_band, 
  demographic, 
  sum(sales) total_sales 
FROM
  clean_weekly_sales 
WHERE
  platform = "Retail" 
GROUP BY 
  age_band, 
  demographic;
```
Result:

| age_band     | demographic   |   total_sales |
|:-------------|:--------------|--------------:|
| Retirees     | Couples       |    6370580014 |
| Young Adults | Families      |    1770889293 |
| unknown      | unknown       |   16067285533 |
| Young Adults | Couples       |    2602922797 |
| Middle Aged  | Couples       |    1854160330 |
| Retirees     | Families      |    6634686916 |
| Middle Aged  | Families      |    4354091554 |


**Q9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?**
```sql
SELECT 
  calendar_year, 
  platform, 
  SUM(sales)/ SUM(transactions) AS avg_transaction
FROM
  clean_weekly_sales 
GROUP BY
  calendar_year, 
  platform 
ORDER BY
  calendar_year;
```
Result:

|   calendar_year | platform   |   avg_transaction |
|----------------:|:-----------|------------------:|
|            2018 | Retail     |           36.5626 |
|            2018 | Shopify    |          192.481  |
|            2019 | Retail     |           36.8335 |
|            2019 | Shopify    |          183.361  |
|            2020 | Retail     |           36.5566 |
|            2020 | Shopify    |          179.033  |

### C. Before & After Analysis
This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:

**Q1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?**

```sql 
WITH sales AS (
SELECT 
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -4 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 4 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
)
SELECT before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales
```
Result:

|   before_sales |   after_sales |   actual_growth |   percent_growth |
|---------------:|--------------:|----------------:|-----------------:|
|     2.9159e+09 |   2.90493e+09 |    -1.09731e+07 |            -0.38 |


**Q2. What about the entire 12 weeks before and after?**

```sql
WITH sales AS (
SELECT 
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -12 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 12 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
)
SELECT before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales
```
Result: 

|   before_sales |   after_sales |   actual_growth |   percent_growth |
|---------------:|--------------:|----------------:|-----------------:|
|    7696298495	 |   6973947753	 |   -722350742	   |           -9.39  |

**Q3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?** 

Solution: 

### D. Bonus Question

Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

- region
- platform
- age_band
- demographic
- customer_type

**Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?**

```sql
-- region
WITH sales AS (
SELECT region,
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -12 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 12 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
GROUP BY region
)
SELECT region,
       before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales
```
| region        |   before_sales |   after_sales |   actual_growth |   percent_growth |
|:--------------|---------------:|--------------:|----------------:|-----------------:|
| ASIA          |     1767003725 |    1583807621 |      -183196104 |           -10.37 |
| USA           |      731431645 |     666198715 |       -65232930 |            -8.92 |
| EUROPE        |      118115153 |     114038959 |        -4076194 |            -3.45 |
| AFRICA        |     1847459695 |    1700390294 |      -147069401 |            -7.96 |
| CANADA        |      461233687 |     418264441 |       -42969246 |            -9.32 |
| OCEANIA       |     2540728923 |    2282795690 |      -257933233 |           -10.15 |
| SOUTH AMERICA |      230325667 |     208452033 |       -21873634 |            -9.5  |

```sql
-- platform 
WITH sales AS (
SELECT platform,
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -12 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 12 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
GROUP BY platform
)
SELECT platform
       before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales
```
| before_sales   |   after_sales |   actual_growth |   percent_growth |
|:---------------|--------------:|----------------:|-----------------:|
| Retail         |    6738777279 |      -718830501 |            -9.64 |
| Shopify        |     235170474 |        -3520241 |            -1.47 |

```sql
-- age_band
WITH sales AS (
SELECT age_band,
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -12 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 12 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
GROUP BY age_band
)
SELECT age_band,
       before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales
```
| age_band     |   before_sales |   after_sales |   actual_growth |   percent_growth |
|:-------------|---------------:|--------------:|----------------:|-----------------:|
| Retirees     |     2589271613 |    2365714994 |      -223556619 |            -8.63 |
| Young Adults |      866960357 |     794417968 |       -72542389 |            -8.37 |
| unknown      |     2981006335 |    2671961443 |      -309044892 |           -10.37 |
| Middle Aged  |     1259060190 |    1141853348 |      -117206842 |            -9.31 |

```sql
-- demographic
WITH sales AS (
SELECT demographic,
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -12 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 12 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
GROUP BY demographic
)
SELECT demographic,
       before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales
```
| demographic   |   before_sales |   after_sales |   actual_growth |   percent_growth |
|:--------------|---------------:|--------------:|----------------:|-----------------:|
| Couples       |     2197905564 |    2015977285 |      -181928279 |            -8.28 |
| Families      |     2517386596 |    2286009025 |      -231377571 |            -9.19 |
| unknown       |     2981006335 |    2671961443 |      -309044892 |           -10.37 |

```sql
-- customer_type
WITH sales AS (
SELECT customer_type,
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -12 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 12 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
GROUP BY customer_type
)
SELECT customer_type,
       before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales
```
| customer_type   |   before_sales |   after_sales |   actual_growth |   percent_growth |
|:----------------|---------------:|--------------:|----------------:|-----------------:|
| New             |      931238185 |     871470664 |       -59767521 |            -6.42 |
| Guest           |     2777319056 |    2496233635 |      -281085421 |           -10.12 |
| Existing        |     3987741254 |    3606243454 |      -381497800 |            -9.57 |

Solution: 

## Case Study #6: Clique Bait
### Introduction
Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!

In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.
### A. Enterprise Relationship Diagram
```sql
CREATE SCHEMA `clique_bait`;

CREATE TABLE `clique_bait`.`event_identifier` (
  `event_type` INTEGER,
  `event_name` VARCHAR(13)
);

CREATE TABLE `clique_bait`.`campaign_identifier` (
  `campaign_id` INTEGER,
  `products` VARCHAR(3),
  `campaign_name` VARCHAR(33),
  `start_date` TIMESTAMP,
  `end_date` TIMESTAMP
);

CREATE TABLE `clique_bait`.`page_hierarchy` (
  `page_id` integer,
  `page_name` VARCHAR(14),
  `product_category` VARCHAR(9),
  `product_id` INTEGER
);

CREATE TABLE `clique_bait`.`users` (
  `user_id` INTEGER,
  `cookie_id` VARCHAR(6),
  `start_date` TIMESTAMP
);

CREATE TABLE `clique_bait`.`events` (
  `visit_id` VARCHAR(6),
  `cookie_id` VARCHAR(6),
  `page_id` INTEGER,
  `event_type` INTEGER,
  `sequence_number` INTEGER,
  `event_time` TIMESTAMP
);

ALTER TABLE `clique_bait`.`events` ADD FOREIGN KEY (`event_type`) REFERENCES `clique_bait`.`event_identifier` (`event_type`);

ALTER TABLE `clique_bait`.`users` ADD FOREIGN KEY (`cookie_id`) REFERENCES `clique_bait`.`events` (`cookie_id`);

ALTER TABLE `clique_bait`.`events` ADD FOREIGN KEY (`page_id`) REFERENCES `clique_bait`.`page_hierarchy` (`page_id`);
```
### B. Digital Analysis

Using the available datasets - answer the following questions using a single query for each one:

**Q1. How many users are there?**
```sql
SELECT COUNT(DISTINCT user_id) num_users
FROM users
```

|   num_users |
|------------:|
|         500 |

**Q2. How many cookies does each user have on average?**
```sql
WITH count_cookie AS(
SELECT user_id, 
       COUNT(cookie_id) num_cookies
FROM users
GROUP BY user_id
)
SELECT AVG(num_cookies) AS avg_cookie
FROM count_cookie
```
|   num_users |
|------------:|
|         500 |

**Q3. What is the unique number of visits by all users per month?**
```sql
SELECT
  MONTHNAME(event_time) AS months, 
  COUNT(DISTINCT visit_id) AS num_of_visits 
FROM events 
GROUP BY months, 
         MONTH(event_time) 
ORDER BY MONTH(event_time);
```

| months   |   num_of_visits |
|:---------|----------------:|
| January  |             876 |
| February |            1488 |
| March    |             916 |
| April    |             248 |
| May      |              36 |

**Q4. What is the number of events for each event type?**
```sql
SELECT event_name,
       COUNT(*) num_of_events
FROM events e
JOIN event_identifier i ON e.event_type = i.event_type
GROUP BY event_name
```

| event_name    |   num_of_events |
|:--------------|----------------:|
| Page View     |           20928 |
| Add to Cart   |            8451 |
| Purchase      |            1777 |
| Ad Impression |             876 |
| Ad Click      |             702 |

**Q5. What is the percentage of visits which have a purchase event?**

```sql
SELECT 100*COUNT(DISTINCT visit_id) / (SELECT COUNT(DISTINCT visit_id) FROM events) AS pct_of_purchase
FROM events e
JOIN event_identifier i ON e.event_type = i.event_type
WHERE event_name = 'Purchase'
```

|   pct_of_purchase |
|------------------:|
|           49.8597 |

**Q6. What is the percentage of visits which view the checkout page but do not have a purchase event?**

```sql
WITH view_checkout AS (
  SELECT COUNT(e.visit_id) AS cnt
  FROM events e
  JOIN event_identifier ei ON e.event_type = ei.event_type
  JOIN page_hierarchy p ON e.page_id = p.page_id
  WHERE ei.event_name = 'Page View'
    AND p.page_name = 'Checkout'
)
SELECT CAST(100-(100.0 * COUNT(DISTINCT e.visit_id) 
		/ (SELECT cnt FROM view_checkout)) AS decimal(10, 2)) AS pct_view_checkout_not_purchase
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase'
```

|   pct_view_checkout_not_purchase |
|---------------------------------:|
|                             15.5 |

**Q7. What are the top 3 pages by number of views?**

```sql
SELECT 
  ph.page_name,
  COUNT(*) AS page_views
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE ei.event_name = 'Page View'
GROUP BY ph.page_name
ORDER BY page_views DESC LIMIT 3
```

| page_name    |   page_views |
|:-------------|-------------:|
| All Products |         3174 |
| Checkout     |         2103 |
| Home Page    |         1782 |


**Q8. What is the number of views and cart adds for each product category?**

```sql
SELECT 
  product_category,
  SUM(CASE WHEN event_name = 'Page View' THEN 1 ELSE 0 END) page_views,
  SUM(CASE WHEN event_name = 'Add to Cart' THEN 1 ELSE 0 END) add_cart
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE product_category IS NOT NULL
GROUP BY product_category
```

| product_category   |   page_views |   add_cart |
|:-------------------|-------------:|-----------:|
| Luxury             |         3032 |       1870 |
| Shellfish          |         6204 |       3792 |
| Fish               |         4633 |       2789 |

**Q9. What are the top 3 products by purchases?**

```sql
SELECT product_id,
	   page_name,
       COUNT(*) AS num_purchase
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE event_name = 'Add to Cart' AND 
visit_id IN 
(SELECT visit_id 
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
WHERE event_name = 'Purchase')
GROUP BY  product_id,
	      page_name
ORDER BY COUNT(*) DESC LIMIT 3
```

|   product_id | page_name   |   num_purchase |
|-------------:|:------------|---------------:|
|            7 | Lobster     |            754 |
|            9 | Oyster      |            726 |
|            8 | Crab        |            719 |

### C. Product Funnel Analysis
Using a single SQL query - create a new output table which has the following details:

- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?

Create product table:
```sql
DROP TABLE IF EXISTS product; 
CREATE TABLE product AS(
WITH product AS(
SELECT 
product_id,
page_name,
product_category,
SUM(CASE WHEN event_name = 'Page View' THEN 1 ELSE 0 END) product_viewed ,
SUM(CASE WHEN event_name = 'Add to Cart' THEN 1 ELSE 0 END) added_cart
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE product_id IS NOT NULL
GROUP BY product_id,
page_name,
product_category
),
abandoned AS (
SELECT 
product_id,
page_name,
product_category,
COUNT(*) abandoned_product
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE event_name = 'Add to Cart' AND 
visit_id NOT IN 
(SELECT visit_id 
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
WHERE event_name = 'Purchase')
GROUP BY  product_id,
	      page_name,
          product_category
),
purchased AS (
SELECT 
product_id,
page_name,
product_category,
COUNT(*) purchased_product
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE event_name = 'Add to Cart' AND 
visit_id IN 
(SELECT visit_id 
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
WHERE event_name = 'Purchase')
GROUP BY  product_id,
	      page_name,
          product_category)
SELECT p.product_id,
       p.page_name,
       p.product_category,
       product_viewed,
       added_cart,
       abandoned_product,
       purchased_product
FROM product p
LEFT JOIN abandoned a ON p.product_id = a.product_id
LEFT JOIN purchased pc ON p.product_id = pc.product_id
ORDER BY product_id
)

SELECT * FROM product
```
#product

|   product_id | page_name      | product_category   |   product_viewed |   added_cart |   abandoned_product |   purchased_product |
|-------------:|:---------------|:-------------------|-----------------:|-------------:|--------------------:|--------------------:|
|            1 | Salmon         | Fish               |             1559 |          938 |                 227 |                 711 |
|            2 | Kingfish       | Fish               |             1559 |          920 |                 213 |                 707 |
|            3 | Tuna           | Fish               |             1515 |          931 |                 234 |                 697 |
|            4 | Russian Caviar | Luxury             |             1563 |          946 |                 249 |                 697 |
|            5 | Black Truffle  | Luxury             |             1469 |          924 |                 217 |                 707 |
|            6 | Abalone        | Shellfish          |             1525 |          932 |                 233 |                 699 |
|            7 | Lobster        | Shellfish          |             1547 |          968 |                 214 |                 754 |
|            8 | Crab           | Shellfish          |             1564 |          949 |                 230 |                 719 |
|            9 | Oyster         | Shellfish          |             1568 |          943 |                 217 |                 726 |

Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

Create product_category table:
```sql
DROP TABLE IF EXISTS product_category; 
CREATE TABLE product_category AS(
WITH product AS(
SELECT 
product_category,
SUM(CASE WHEN event_name = 'Page View' THEN 1 ELSE 0 END) product_viewed ,
SUM(CASE WHEN event_name = 'Add to Cart' THEN 1 ELSE 0 END) added_cart
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE product_category IS NOT NULL
GROUP BY 
product_category
),
abandoned AS (
SELECT 
product_category,
COUNT(*) abandoned_product
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE event_name = 'Add to Cart' AND 
visit_id NOT IN 
(SELECT visit_id 
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
WHERE event_name = 'Purchase')
GROUP BY product_category
),
purchased AS (
SELECT 
product_category,
COUNT(*) purchased_product
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE event_name = 'Add to Cart' AND 
visit_id IN 
(SELECT visit_id 
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
WHERE event_name = 'Purchase')
GROUP BY product_category)
SELECT p.product_category,
       product_viewed,
       added_cart,
       abandoned_product,
       purchased_product
FROM product p
LEFT JOIN abandoned a ON p.product_category = a.product_category
LEFT JOIN purchased pc ON p.product_category = pc.product_category
ORDER BY product_category
)

SELECT * FROM product_category
```
#product_category

| product_category   |   product_viewed |   added_cart |   abandoned_product |   purchased_product |
|:-------------------|-----------------:|-------------:|--------------------:|--------------------:|
| Fish               |             4633 |         2789 |                 674 |                2115 |
| Luxury             |             3032 |         1870 |                 466 |                1404 |
| Shellfish          |             6204 |         3792 |                 894 |                2898 |

Use your 2 new output tables - answer the following questions:

**Q1. Which product had the most views, cart adds and purchases?**
```sql
-- the most views
SELECT product_id,
       page_name,
       product_category,
       product_viewed
FROM product
ORDER BY product_viewed DESC LIMIT 1
-- the most cart adds 
SELECT product_id,
       page_name,
       product_category,
       added_cart
FROM product
ORDER BY added_cart DESC LIMIT 1
```

|   product_id | page_name   | product_category   |   product_viewed |
|-------------:|:------------|:-------------------|-----------------:|
|            9 | Oyster      | Shellfish          |             1568 |


|   product_id | page_name   | product_category   |   added_cart |
|-------------:|:------------|:-------------------|-------------:|
|            7 | Lobster     | Shellfish          |          968 |


|   product_id | page_name   | product_category   |   purchased_product |
|-------------:|:------------|:-------------------|--------------------:|
|            7 | Lobster     | Shellfish          |                 754 |


**Q2. Which product was most likely to be abandoned?**
```sql
SELECT product_id,
       page_name,
       product_category,
       abandoned_product
FROM product
ORDER BY abandoned_product DESC LIMIT 1
```

|   product_id | page_name      | product_category   |   abandoned_product |
|-------------:|:---------------|:-------------------|--------------------:|
|            4 | Russian Caviar | Luxury             |                 249 |

**Q3. Which product had the highest view to purchase percentage?**

```sql
SELECT product_id,
       page_name,
       product_category,
       100*purchased_product/product_viewed AS pct_view_to_purchase
FROM product
ORDER BY 100*purchased_product/product_viewed DESC LIMIT 1
```

|   product_id | page_name   | product_category   |   pct_view_to_purchase |
|-------------:|:------------|:-------------------|-----------------------:|
|            7 | Lobster     | Shellfish          |                48.7395 |

**Q4. What is the average conversion rate from view to cart add?**
```sql
SELECT product_id,
       page_name,
       product_category,
       100*purchased_product/product_viewed AS pct_view_to_purchase
FROM product
ORDER BY 100*purchased_product/product_viewed DESC LIMIT 1
```

|   avg_view_to_cart |
|-------------------:|
|            60.9512 |

**Q5. What is the average conversion rate from cart add to purchase?**

```sql
SELECT 
       AVG(100*purchased_product/added_cart) AS avg_cart_to_purchase
FROM product
```

|   avg_cart_to_purchase |
|-----------------------:|
|                 75.928 |

### D. Campaigns Analysis
Generate a table that has 1 single row for every unique visit_id record and has the following columns:

- user_id
- visit_id
- visit_start_time: the earliest event_time for each visit
- page_views: count of page views for each visit
- cart_adds: count of product cart add events for each visit
- purchase: 1/0 flag if a purchase event exists for each visit
- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
- impression: count of ad impressions for each visit
- click: count of ad clicks for each visit
- **(Optional column)** cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)

Create campaign_summary table: 

```sql
DROP TABLE IF EXISTS campaign_summary;
CREATE TABLE campaign_summary AS(
SELECT 
      u.user_id,
      e.visit_id,
      MIN(event_time) AS visit_start_time,
      SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS page_views,
      SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS cart_adds,
      SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase,
      CASE WHEN c.campaign_name IS NOT NULL THEN c.campaign_name
           ELSE 'No Campaign'
	  END AS campaign_name,
	  SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression,
	  SUM(CASE WHEN ei.event_name = 'Ad Click' THEN 1 ELSE 0 END) AS click
FROM events e
LEFT JOIN users u 
    ON e.cookie_id = u.cookie_id
JOIN event_identifier ei 
    ON e.event_type = ei.event_type
JOIN page_hierarchy ph 
    ON e.page_id = ph.page_id
LEFT JOIN campaign_identifier c 
    ON  c.start_date <= e.event_time AND e.event_time <= c.end_date
GROUP BY u.user_id, e.visit_id, c.campaign_name)
```
#campaign_summary 
|   user_id | visit_id   | visit_start_time    |   page_views |   cart_adds |   purchase | campaign_name                     |   impression |   click |
|----------:|:-----------|:--------------------|-------------:|------------:|-----------:|:----------------------------------|-------------:|--------:|
|       439 | 73d7e8     | 2020-03-08 07:12:11 |            5 |           2 |          1 | Half Off - Treat Your Shellf(ish) |            0 |       0 |
|        41 | 6c312a     | 2020-02-05 15:40:41 |            8 |           2 |          1 | Half Off - Treat Your Shellf(ish) |            0 |       0 |
|        99 | 484cf5     | 2020-03-06 20:50:12 |            8 |           2 |          1 | Half Off - Treat Your Shellf(ish) |            0 |       0 |
|       476 | 280969     | 2020-01-21 20:03:34 |            7 |           1 |          1 | 25% Off - Living The Lux Life     |            0 |       0 |
|       360 | 3a588b     | 2020-02-27 04:00:09 |            5 |           2 |          0 | Half Off - Treat Your Shellf(ish) |            0 |       0 |
|       194 | 373a4b     | 2020-02-21 09:54:32 |            1 |           0 |          0 | Half Off - Treat Your Shellf(ish) |            0 |       0 |
|       342 | a38b2f     | 2020-02-20 02:59:58 |            6 |           3 |          0 | Half Off - Treat Your Shellf(ish) |            0 |       0 |
|       118 | 6fa366     | 2020-01-19 16:19:26 |            7 |           3 |          0 | 25% Off - Living The Lux Life     |            0 |       0 |
|       469 | 064835     | 2020-02-25 09:48:46 |            7 |           1 |          0 | Half Off - Treat Your Shellf(ish) |            0 |       0 |
|       290 | 252236     | 2020-02-12 02:38:57 |            6 |           2 |          1 | Half Off - Treat Your Shellf(ish) |            0 |       0 |

Use the subsequent dataset to generate at least 5 insights for the Clique Bait team.

Solution:

**Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event**

```sql
-- Number of users who received impressions during campaign periods 
SELECT COUNT(DISTINCT user_id) AS received_impressions
FROM campaign_summary
WHERE impression > 0
AND campaign_name != 'No Campaign';
```
|   received_impressions |
|-----------------------:|
|                    417 |

```sql
-- Number of users who  didn't  received impressions during campaign periods 
SELECT COUNT(DISTINCT user_id) AS no_received_impressions
FROM campaign_summary
WHERE user_id NOT IN (
  SELECT user_id
  FROM campaign_summary
  WHERE impression > 0)
AND campaign_name != 'No Campaign'
```
|   no_received_impressions |
|--------------------------:|
|                        56 |

```sql
-- Number of users who received impressions but didn't click on the ad during campaign periods
SELECT COUNT(DISTINCT user_id) AS received_impressions_not_click
FROM campaign_summary
WHERE impression > 0 AND click = 0 
AND campaign_name != 'No Campaign';
```
|   received_impressions_not_click |
|---------------------------------:|
|                              127 |

Now we know:
- The number of users who received impressions during campaign periods is 417.
- The number of users who received impressions but didn't click on the ad is 127.
- The number of users who didn't receive impressions during campaign periods is 56.
- Using those numbers, we can calculate:
- Overall, impression rate = 100 * 417 / (417+56) = 88.2 %
- Overall, click rate = 100-(100 * 127 / 417) = 69.5 %

**What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click. Does clicking on an impression lead to higher purchase rates?**

```sql
-- For clicked ad group
SELECT SUM(purchase)/COUNT(DISTINCT user_id) AS purchase_rate_impression
FROM campaign_summary
WHERE click > 0
AND campaign_name != 'No Campaign'
```
|   purchase_rate_impression |
|---------------------------:|
|                     1.4632 |

```sql
-- For didn't received impression group 
SELECT SUM(purchase)/COUNT(DISTINCT user_id) AS purchase_rate_no_impression
FROM campaign_summary
WHERE campaign_name != 'No Campaign' AND
user_id NOT IN (
SELECT user_id 
FROM campaign_summary 
WHERE impression > 0 )
```
|   purchase_rate_no_impression |
|------------------------------:|
|                        1.2321 |

```sql
-- For received impression but not clicked
SELECT SUM(purchase)/COUNT(DISTINCT user_id) AS purchase_rate_impressions_not_click
FROM campaign_summary
WHERE impression > 0 AND click = 0 
AND campaign_name != 'No Campaign';
```
|   purchase_rate_impressions_not_click |
|--------------------------------------:|
|                                0.7717 |
Now we know:
- The purchase rate of customers who clicked in campaign is 1.4632
- The purchase rate of customers who didn't received impressions is 1.2321
- The purchase rate of customers who received impressions but didn't click on the ad is 0.7717

**What metrics can you use to quantify the success or failure of each campaign compared to eachother?**
- 

## Case Study #7: Balanced Tree
### Introduction
Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.

### A. High Level Sales Analysis

**Q1. What was the total quantity sold for all products?**
```sql
SELECT SUM(qty) AS total_quantity
FROM sales
```
|   total_quantity |
|-----------------:|
|            45216 |
**Q2. What is the total generated revenue for all products before discounts?**
```sql
SELECT SUM(qty*price) AS revenue
FROM sales
```
|     revenue |
|------------:|
| 1.28945e+06 |

**Q3. What was the total discount amount for all products?**
```sql
SELECT SUM(qty*price*discount/100) AS revenue
FROM sales
```

|   revenue |
|----------:|
|    156229 |

### B. Transactional Analysis

**Q1. How many unique transactions were there?**
```sql
SELECT COUNT(DISTINCT txn_id) AS num_txn
FROM sales
```

|   num_txn |
|----------:|
|      2500 |


**Q2. What is the average unique products purchased in each transaction?**
```sql
WITH unique_prod AS (
SELECT txn_id,
       COUNT(prod_id) AS num_prod
FROM sales
GROUP BY txn_id
)
SELECT AVG(num_prod) AS avg_prod_each_txn
FROM unique_prod
```

|   avg_prod_each_txn |
|--------------------:|
|               6.038 |


**Q3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?**
```sql
WITH revenue_per_txn AS 
(
SELECT txn_id,
       CAST(SUM(qty*price) AS FLOAT) AS revenue_txn
FROM sales
GROUP BY txn_id
ORDER BY revenue_txn ASC
)
, pct AS (
SELECT txn_id,
       revenue_txn,
       NTILE(100) OVER (ORDER BY revenue_txn) pct
FROM revenue_per_txn 
)
SELECT 
       MAX(IF(pct = 25, revenue_txn, NULL)) AS q1,
       MAX(IF(pct = 50, revenue_txn, NULL)) AS q2,
       MAX(IF(pct = 75, revenue_txn, NULL)) AS q3
FROM pct
```

|   q1 |   q2 |   q3 |
|-----:|-----:|-----:|
|  375 |  509 |  647 |


**Q4. What is the average discount value per transaction?**
```sql
WITH temp AS(
SELECT txn_id,
	   CAST(SUM(qty*price*discount/100) AS FLOAT) AS total_discount
FROM sales 
GROUP BY txn_id
)
SELECT CAST(AVG(total_discount) AS FLOAT) AS avg_discount
FROM temp 
```

|   avg_discount |
|---------------:|
|        62.4917 |

**Q5. What is the percentage split of all transactions for members vs non-members?**
```sql
SELECT 
  CAST(100.0*COUNT(DISTINCT CASE WHEN member = 't' THEN txn_id END) / COUNT(DISTINCT txn_id) AS FLOAT) AS members_pct,
  CAST(100.0*COUNT(DISTINCT CASE WHEN member = 'f' THEN txn_id END) / COUNT(DISTINCT txn_id) AS FLOAT) AS non_members_pct
FROM sales;
```

|   members_pct |   non_members_pct |
|--------------:|------------------:|
|          60.2 |              39.8 |

**Q6. What is the average revenue for member transactions and non-member transactions?**
```sql
SELECT
  CASE WHEN member = 'f' THEN 'member'
  ELSE 'non_member'
  END AS member, 
  ROUND( SUM(qty * price) / COUNT(distinct txn_id), 2) as avg_revenue 
FROM sales 
GROUP BY member
```
| member     |   avg_revenue |
|:-----------|--------------:|
| member     |        515.04 |
| non_member |        516.27 |

### C. Product Analysis
**Q1. What are the top 3 products by total revenue before discount?**
```sql
SELECT 
       product_name,
	   SUM(qty*s.price) AS total_revenue
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
GROUP BY product_name
ORDER BY total_revenue DESC LIMIT 3
```
| product_name                 |   total_revenue |
|:-----------------------------|----------------:|
| Blue Polo Shirt - Mens       |          217683 |
| Grey Fashion Jacket - Womens |          209304 |
| White Tee Shirt - Mens       |          152000 |

**Q2. What is the total quantity, revenue and discount for each segment?**
```sql
SELECT segment_id, 
       segment_name,
       SUM(qty) AS total_qty,
       SUM(qty*s.price) AS revenue,
       SUM(discount) AS total_discount
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
GROUP BY segment_id
```
|   segment_id | segment_name   |   total_qty |   revenue |   total_discount |
|-------------:|:---------------|------------:|----------:|-----------------:|
|            3 | Jeans          |       11349 |    208350 |            45740 |
|            5 | Shirt          |       11265 |    406143 |            46043 |
|            6 | Socks          |       11217 |    307977 |            45465 |
|            4 | Jacket         |       11385 |    366983 |            45452 |


**Q3. What is the top selling product for each segment?**
```sql
WITH temp AS(
SELECT segment_id,
       segment_name, 
       product_name,
       SUM(qty) as num_qty,
       RANK() OVER(PARTITION BY segment_id ORDER BY SUM(qty) DESC) rank_qty
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
GROUP BY segment_id, prod_id
ORDER BY segment_id
)
SELECT segment_id,
       segment_name, 
       product_name,
       num_qty AS top_qty
FROM temp 
WHERE rank_qty =1 
```

|   segment_id | segment_name   | product_name                  |   top_qty |
|-------------:|:---------------|:------------------------------|----------:|
|            3 | Jeans          | Navy Oversized Jeans - Womens |      3856 |
|            4 | Jacket         | Grey Fashion Jacket - Womens  |      3876 |
|            5 | Shirt          | Blue Polo Shirt - Mens        |      3819 |
|            6 | Socks          | Navy Solid Socks - Mens       |      3792 |

**Q4. What is the total quantity, revenue and discount for each category?**
```sql
SELECT category_id,
       category_name,
       SUM(qty) AS total_qty,
       SUM(s.price*qty) AS revenue,
       SUM(qty*s.price*discount/100) AS discount
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
GROUP BY category_id
```
|   category_id | category_name   |   total_qty |   revenue |   discount |
|--------------:|:----------------|------------:|----------:|-----------:|
|             1 | Womens          |       22734 |    575333 |    69621.4 |
|             2 | Mens            |       22482 |    714120 |    86607.7 |

**Q5. What is the top selling product for each category?**
```sql
WITH temp AS(
SELECT category_id,
       category_name, 
       product_name,
       SUM(qty) as num_qty,
       RANK() OVER(PARTITION BY category_id ORDER BY SUM(qty) DESC) rank_qty
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
GROUP BY category_id, prod_id
ORDER BY category_id
)
SELECT category_id,
       category_name, 
       product_name,
       num_qty AS top_qty
FROM temp 
WHERE rank_qty =1 
```
|   category_id | category_name   | product_name                 |   top_qty |
|--------------:|:----------------|:-----------------------------|----------:|
|             1 | Womens          | Grey Fashion Jacket - Womens |      3876 |
|             2 | Mens            | Blue Polo Shirt - Mens       |      3819 |

**Q6. What is the percentage split of revenue by product for each segment?**
```sql
WITH temp AS (
SELECT segment_id,
       segment_name, 
       product_id,
       product_name,
       s.price,
       qty,
       SUM(s.price*qty) OVER(PARTITION BY product_id)/SUM(s.price*qty) OVER(PARTITION BY segment_id) AS pct
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
ORDER BY segment_id 
)
SELECT  segment_name,
        product_name,
        CAST(pct*100 AS DECIMAL(10,2)) AS pct
FROM temp 
GROUP BY product_id
```
| segment_name   | product_name                     |   pct |
|:---------------|:---------------------------------|------:|
| Jeans          | Black Straight Jeans - Womens    | 58.15 |
| Jeans          | Cream Relaxed Jeans - Womens     | 17.79 |
| Jeans          | Navy Oversized Jeans - Womens    | 24.06 |
| Jacket         | Khaki Suit Jacket - Womens       | 23.51 |
| Jacket         | Indigo Rain Jacket - Womens      | 19.45 |
| Jacket         | Grey Fashion Jacket - Womens     | 57.03 |
| Shirt          | White Tee Shirt - Mens           | 37.43 |
| Shirt          | Blue Polo Shirt - Mens           | 53.6  |
| Shirt          | Teal Button Up Shirt - Mens      |  8.98 |
| Socks          | Navy Solid Socks - Mens          | 44.33 |
| Socks          | Pink Fluro Polkadot Socks - Mens | 35.5  |
| Socks          | White Striped Socks - Mens       | 20.18 |

**Q7. What is the percentage split of revenue by segment for each category?**
```sql
WITH temp AS (
SELECT category_id,
       category_name, 
       segment_id,
       segment_name,
       s.price,
       qty,
       SUM(s.price*qty) OVER(PARTITION BY segment_id)/SUM(s.price*qty) OVER(PARTITION BY category_id) AS pct
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
ORDER BY category_id
)
SELECT  category_name,
        segment_name,
        CAST(pct*100 AS DECIMAL(10,2)) AS pct
FROM temp 
GROUP BY segment_id
```
| category_name   | segment_name   |   pct |
|:----------------|:---------------|------:|
| Womens          | Jacket         | 63.79 |
| Womens          | Jeans          | 36.21 |
| Mens            | Socks          | 43.13 |
| Mens            | Shirt          | 56.87 |

**Q8. What is the percentage split of total revenue by category?**
```sql
WITH temp AS
(SELECT category_name,
	   SUM(s.price*qty) revenue
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
GROUP BY category_id
)
SELECT *,
       CAST(100*revenue/SUM(revenue) OVER() AS DECIMAL(10,2)) AS pct
FROM temp
```
| category_name   |   revenue |   pct |
|:----------------|----------:|------:|
| Womens          |    575333 | 44.62 |
| Mens            |    714120 | 55.38 |

**Q9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)**
```sql
WITH temp AS
(SELECT prod_id,
        txn_id
FROM sales
WHERE qty >= 1
)
,penetration AS
(SELECT DISTINCT prod_id,
	   product_name,
       COUNT(DISTINCT txn_id) AS prod_txn,
       (SELECT COUNT(DISTINCT txn_id) FROM sales) AS total_txn
FROM temp t
LEFT JOIN product_details p ON t.prod_id = p.product_id
GROUP BY prod_id
)
SELECT *,
       CAST(100*prod_txn/total_txn AS DECIMAL(10,2)) AS penetration 
FROM penetration
```
| prod_id   | product_name                     |   prod_txn |   total_txn |   penetration |
|:----------|:---------------------------------|-----------:|------------:|--------------:|
| 2a2353    | Blue Polo Shirt - Mens           |       1268 |        2500 |         50.72 |
| 2feb6b    | Pink Fluro Polkadot Socks - Mens |       1258 |        2500 |         50.32 |
| 5d267b    | White Tee Shirt - Mens           |       1268 |        2500 |         50.72 |
| 72f5d4    | Indigo Rain Jacket - Womens      |       1250 |        2500 |         50    |
| 9ec847    | Grey Fashion Jacket - Womens     |       1275 |        2500 |         51    |
| b9a74d    | White Striped Socks - Mens       |       1243 |        2500 |         49.72 |
| c4a632    | Navy Oversized Jeans - Womens    |       1274 |        2500 |         50.96 |
| c8d436    | Teal Button Up Shirt - Mens      |       1242 |        2500 |         49.68 |
| d5e9a6    | Khaki Suit Jacket - Womens       |       1247 |        2500 |         49.88 |
| e31d39    | Cream Relaxed Jeans - Womens     |       1243 |        2500 |         49.72 |
| e83aa3    | Black Straight Jeans - Womens    |       1246 |        2500 |         49.84 |
| f084eb    | Navy Solid Socks - Mens          |       1281 |        2500 |         51.24 |

**Q10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?**
```sql
WITH prod AS (
SELECT
    txn_id, 
    product_name 
FROM sales s
LEFT JOIN product_details PD ON s.prod_id = pd.product_id
WHERE qty >=1
) 
SELECT
  p1.product_name as product_1, 
  p2.product_name as product_2, 
  p3.product_name as product_3, 
  COUNT(*) as purchase_count 
FROM 
  prod AS p1 
  JOIN prod AS p2 ON p1.txn_id = p2.txn_id 
  AND p1.product_name != p2.product_name 
  JOIN prod AS p3 ON p1.txn_id = p3.txn_id 
  AND p1.product_name != p3.product_name 
  AND p2.product_name != p3.product_name 
GROUP BY  
  product_1, 
  product_2, 
  product_3 
ORDER BY purchase_count DESC LIMIT 1
```
| product_1                    | product_2              | product_3                   |   purchase_count |
|:-----------------------------|:-----------------------|:----------------------------|-----------------:|
| Grey Fashion Jacket - Womens | White Tee Shirt - Mens | Teal Button Up Shirt - Mens |              352 |

### D. Reporting Challenge 
Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)

```sql
SELECT monthname(start_txn_time) AS month,
       SUM(qty) AS total_quantity,
       SUM(qty*price) AS revenue,
       SUM(qty*price*discount/100) AS net_revenue,
       COUNT(DISTINCT txn_id) AS num_txn
FROM sales
WHERE monthname(start_txn_time) = 'January'
```

| month   |   total_quantity |   revenue |   net_revenue |   num_txn |
|:--------|-----------------:|----------:|--------------:|----------:|
| January |            14788 |    420672 |       51589.1 |       828 |



### E. Bonus Challenge
Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.

Hint: you may want to consider using a recursive CTE to solve this problem!
Solution:
```sql
WITH RECURSIVE cte AS (
SELECT parent_id AS id,
       id AS id_hierarchy,
       level_text,
       level_name
FROM product_hierarchy 
WHERE parent_id IS NOT NULL

UNION 

SELECT cte.id,
       ph.id AS id_hierarchy,
       cte.level_text,
       cte.level_name
FROM product_hierarchy ph
JOIN cte ON ph.parent_id = cte.id_hierarchy

)

SELECT product_id,
       price,
       CONCAT( c2.level_text, '', c1.level_text, '', '-', '', ph.level_text) AS product_name,
       c1.id AS category_id,
       c1.id_hierarchy AS segment_id,
       c2.id_hierarchy AS style_id, 
       ph.level_text AS category_name,
       c1.level_text AS segment_name,
       c2.level_text AS style_name
FROM cte c1 
JOIN cte c2 ON c1.id_hierarchy= c2.id
JOIN product_hierarchy ph ON c1.id = ph.id 
JOIN product_prices pp ON c2.id_hierarchy = pp.id
```
| product_id   |   price | product_name                  |   category_id |   segment_id |   style_id | category_name   | segment_name   | style_name          |
|:-------------|--------:|:------------------------------|--------------:|-------------:|-----------:|:----------------|:---------------|:--------------------|
| 9ec847       |      54 | Grey FashionJacket-Womens     |             1 |            4 |         12 | Womens          | Jacket         | Grey Fashion        |
| 72f5d4       |      19 | Indigo RainJacket-Womens      |             1 |            4 |         11 | Womens          | Jacket         | Indigo Rain         |
| d5e9a6       |      23 | Khaki SuitJacket-Womens       |             1 |            4 |         10 | Womens          | Jacket         | Khaki Suit          |
| e31d39       |      10 | Cream RelaxedJeans-Womens     |             1 |            3 |          9 | Womens          | Jeans          | Cream Relaxed       |
| e83aa3       |      32 | Black StraightJeans-Womens    |             1 |            3 |          8 | Womens          | Jeans          | Black Straight      |
| c4a632       |      13 | Navy OversizedJeans-Womens    |             1 |            3 |          7 | Womens          | Jeans          | Navy Oversized      |
| 2feb6b       |      29 | Pink Fluro PolkadotSocks-Mens |             2 |            6 |         18 | Mens            | Socks          | Pink Fluro Polkadot |
| b9a74d       |      17 | White StripedSocks-Mens       |             2 |            6 |         17 | Mens            | Socks          | White Striped       |
| f084eb       |      36 | Navy SolidSocks-Mens          |             2 |            6 |         16 | Mens            | Socks          | Navy Solid          |
| 2a2353       |      57 | Blue PoloShirt-Mens           |             2 |            5 |         15 | Mens            | Shirt          | Blue Polo           |
| c8d436       |      10 | Teal Button UpShirt-Mens      |             2 |            5 |         14 | Mens            | Shirt          | Teal Button Up      |
| 5d267b       |      40 | White TeeShirt-Mens           |             2 |            5 |         13 | Mens            | Shirt          | White Tee           |

## Case Study #8: Fresh Segments
### Introduction
Danny created Fresh Segments, a digital marketing agency that helps other businesses analyse trends in online ad click behaviour for their unique customer base.

Clients share their customer lists with the Fresh Segments team who then aggregate interest metrics and generate a single dataset worth of metrics for further analysis.

In particular - the composition and rankings for different interests are provided for each client showing the proportion of their customer list who interacted with online assets related to each interest for each month.

Danny has asked for your assistance to analyse aggregated metrics for an example client and provide some high level insights about the customer list and their interests.

### A. Data Exploration and Cleansing
**Q1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month**
```sql
ALTER TABLE interest_metrics 
MODIFY COLUMN month_year VARCHAR(10)

UPDATE interest_metrics 
SET month_year = CAST(CONCAT(_year,'-',_month,'-','01') AS DATE) 
```
**Q2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?**
```sql
SELECT 
  month_year,
  COUNT(*) AS cnt
FROM interest_metrics
GROUP BY month_year
ORDER BY month_year;
```
| month_year   |   cnt |
|:-------------|------:|
| nan          |     1 |
| 2018-07-01   |   729 |
| 2018-08-01   |   767 |
| 2018-09-01   |   780 |
| 2018-10-01   |   857 |
| 2018-11-01   |   928 |
| 2018-12-01   |   995 |
| 2019-01-01   |   973 |
| 2019-02-01   |  1121 |
| 2019-03-01   |  1136 |

**Q3. What do you think we should do with these null values in the fresh_segments.interest_metrics**
```sql
SELECT *
FROM interest_metrics
WHERE month_year IS NULL
ORDER BY interest_id DESC;
```

|   _month |   _year |   month_year |   interest_id |   composition |   index_value |   ranking |   percentile_ranking |
|---------:|--------:|-------------:|--------------:|--------------:|--------------:|----------:|---------------------:|
|      nan |     nan |          nan |         21246 |          1.61 |          0.68 |      1191 |                 0.25 |

Since the corresponding values in composition, index_value, ranking, and percentile_ranking fields are not meaningful without the specific information on interest_id, I will delete rows with null interest_id.

```sql
DELETE FROM interest_metrics
WHERE interest_id IS NULL;
```
**Q4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?**
```sql
SELECT 
COUNT(id) AS num_ma_not_me
FROM interest_map ma
LEFT JOIN interest_metrics me ON me.interest_id = ma.id
WHERE interest_id IS NULL
```
|   num_ma_not_me |
|----------------:|
|               7 |

**Q5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table**
```sql
SELECT 
COUNT(interest_id) AS num_me_not_ma
FROM interest_metrics me
LEFT JOIN interest_map ma ON me.interest_id = ma.id
WHERE id IS NULL
```
|   num_me_not_ma |
|----------------:|
|               0 |

**Q6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from 
fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.**
```sql
SELECT 
      me.*,
      ma.interest_name,
      ma.interest_summary,
      ma.created_at,
      ma.last_modified
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
WHERE interest_id = 21246
```
|   num_map_id |
|-------------:|
|         1209 |
**Q7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?**
```sql
SELECT 
      SUM(CASE WHEN DATEDIFF(month_year,created_at) < 0 THEN 1 ELSE 0 END) AS check_value
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
```

|   _month |   _year | month_year   |   interest_id |   composition |   index_value |   ranking |   percentile_ranking | interest_name                    | interest_summary                                      | created_at          | last_modified       |
|---------:|--------:|:-------------|--------------:|--------------:|--------------:|----------:|---------------------:|:---------------------------------|:------------------------------------------------------|:--------------------|:--------------------|
|        7 |    2018 | 2018-07-01   |         21246 |          2.26 |          0.65 |       722 |                 0.96 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|        8 |    2018 | 2018-08-01   |         21246 |          2.13 |          0.59 |       765 |                 0.26 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|        9 |    2018 | 2018-09-01   |         21246 |          2.06 |          0.61 |       774 |                 0.77 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|       10 |    2018 | 2018-10-01   |         21246 |          1.74 |          0.58 |       855 |                 0.23 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|       11 |    2018 | 2018-11-01   |         21246 |          2.25 |          0.78 |       908 |                 2.16 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|       12 |    2018 | 2018-12-01   |         21246 |          1.97 |          0.7  |       983 |                 1.21 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|        1 |    2019 | 2019-01-01   |         21246 |          2.05 |          0.76 |       954 |                 1.95 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|        2 |    2019 | 2019-02-01   |         21246 |          1.84 |          0.68 |      1109 |                 1.07 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|        3 |    2019 | 2019-03-01   |         21246 |          1.75 |          0.67 |      1123 |                 1.14 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|        4 |    2019 | 2019-04-01   |         21246 |          1.58 |          0.63 |      1092 |                 0.64 | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |

Yes these records are valid because both the dates have the same month and we set the date for the month_year column to be the first day of the month
```sql
SELECT 
      month_year,
      created_at
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
WHERE DATEDIFF(month_year,created_at) < 0
```
| month_year   | created_at          |
|:-------------|:--------------------|
| 2018-07-01   | 2018-07-06 14:35:04 |
| 2018-07-01   | 2018-07-17 10:40:03 |
| 2018-07-01   | 2018-07-06 14:35:04 |
| 2018-07-01   | 2018-07-06 14:35:03 |
| 2018-07-01   | 2018-07-06 14:35:04 |
| 2018-07-01   | 2018-07-06 14:35:04 |
| 2018-08-01   | 2018-08-15 18:00:04 |
| 2018-08-01   | 2018-08-15 18:00:04 |
| 2018-08-01   | 2018-08-15 18:00:04 |
| 2018-08-01   | 2018-08-02 16:05:03 |



### B. Interest Analysis
**Q1. Which interests have been present in all month_year dates in our dataset?**
```sql
SELECT COUNT(DISTINCT month_year) 
FROM interest_metrics
INTO @num_month

SELECT interest_id,
       interest_name,
       COUNT(month_year) AS cnt
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
GROUP BY interest_id 
HAVING  COUNT(month_year) = @num_month
```
|   interest_id | interest_name             |   cnt |
|--------------:|:--------------------------|------:|
|             4 | Luxury Retail Researchers |    14 |
|             5 | Brides & Wedding Planners |    14 |
|             6 | Vacation Planners         |    14 |
|            12 | Thrift Store Shoppers     |    14 |
|            15 | NBA Fans                  |    14 |
|            16 | NCAA Fans                 |    14 |
|            17 | MLB Fans                  |    14 |
|            18 | Nascar Fans               |    14 |
|            20 | Moviegoers                |    14 |
|            25 | Doctors                   |    14 |


**Q2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?**
```sql
WITH cte AS
(
SELECT 
      interest_id, 
      COUNT(month_year) AS num_month
FROM interest_metrics
GROUP BY interest_id
)
SELECT DISTINCT num_month,
       COUNT(num_month) OVER(ORDER BY num_month DESC)/ COUNT(num_month) OVER() AS cumulative_pct
FROM cte
```
|   num_month |   cumulative_pct |
|------------:|-----------------:|
|          14 |           0.3993 |
|          13 |           0.4676 |
|          12 |           0.5216 |
|          11 |           0.5998 |
|          10 |           0.6714 |
|           9 |           0.7504 |
|           8 |           0.8062 |
|           7 |           0.881  |
|           6 |           0.9085 |
|           5 |           0.9401 |
|           4 |           0.9667 |
|           3 |           0.9792 |
|           2 |           0.9892 |
|           1 |           1      |

**Q3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?**
```sql
WITH cte AS
(
SELECT 
      interest_id, 
      COUNT(month_year) AS num_month
FROM interest_metrics
GROUP BY interest_id
HAVING COUNT(DISTINCT month_year) < 6
)
SELECT COUNT(i.interest_id) AS num_del
FROM interest_metrics i
JOIN cte c ON i.interest_id = c.interest_id
```
|   num_del |
|----------:|
|       400 |

**Q4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.**

Solution:

**Q5. After removing these interests - how many unique interests are there for each month?**
```sql
WITH cte AS
(
SELECT 
      interest_id, 
      COUNT(month_year) AS num_month
FROM interest_metrics
GROUP BY interest_id
HAVING COUNT(DISTINCT month_year) >= 6
)
SELECT month_year,
       COUNT(DISTINCT i.interest_id) AS num_del
FROM interest_metrics i
JOIN cte c ON i.interest_id = c.interest_id
WHERE month_year IS NOT NULL
GROUP BY month_year
```
| month_year   |   num_del |
|:-------------|----------:|
| 2018-07-01   |       709 |
| 2018-08-01   |       752 |
| 2018-09-01   |       774 |
| 2018-10-01   |       853 |
| 2018-11-01   |       925 |
| 2018-12-01   |       986 |
| 2019-01-01   |       966 |
| 2019-02-01   |      1072 |
| 2019-03-01   |      1078 |
| 2019-04-01   |      1035 |
| 2019-05-01   |       827 |
| 2019-06-01   |       804 |
| 2019-07-01   |       836 |
| 2019-08-01   |      1062 |

### C. Segment Analysis
**Q1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year**
```sql
DROP TABLE IF EXISTS filtered;
CREATE TEMPORARY TABLE filtered AS
(
SELECT 
      interest_id, 
      COUNT(month_year) AS num_month
FROM interest_metrics
GROUP BY interest_id
HAVING COUNT(DISTINCT month_year) >= 6
)
```
|   interest_id |   num_month |
|--------------:|------------:|
|             1 |          12 |
|           100 |          14 |
|         10007 |          11 |
|         10008 |          14 |
|         10009 |          14 |
|         10010 |          14 |
|           101 |          14 |
|           102 |          14 |
|         10249 |          14 |
|         10250 |          14 |

```sql
-- top 10 interests which have the largest composition values
WITH cte AS
(
SELECT i.month_year,
       i.interest_id,
       MAX(i.composition) AS max_com
FROM interest_metrics i 
JOIN filtered f ON i.interest_id = f.interest_id
GROUP BY i.month_year,
		 i.interest_id
ORDER BY max_com DESC
),
ranker AS(
SELECT *,
       RANK() OVER(PARTITION BY interest_id ORDER BY max_com DESC) AS ranker
FROM cte
)
SELECT month_year,
       r.interest_id,
       interest_name,
       max_com
FROM ranker r
JOIN interest_map i ON r.interest_id = i.id
WHERE ranker = 1
ORDER BY max_com DESC LIMIT 10
```
| month_year   |   interest_id | interest_name                     |   max_com |
|:-------------|--------------:|:----------------------------------|----------:|
| 2018-12-01   |         21057 | Work Comes First Travelers        |     21.2  |
| 2018-07-01   |          6284 | Gym Equipment Owners              |     18.82 |
| 2018-07-01   |            39 | Furniture Shoppers                |     17.44 |
| 2018-07-01   |            77 | Luxury Retail Shoppers            |     17.19 |
| 2018-10-01   |         12133 | Luxury Boutique Hotel Researchers |     15.15 |
| 2018-12-01   |          5969 | Luxury Bedding Shoppers           |     15.05 |
| 2018-07-01   |           171 | Shoe Shoppers                     |     14.91 |
| 2018-07-01   |          4898 | Cosmetics and Beauty Shoppers     |     14.23 |
| 2018-07-01   |          6286 | Luxury Hotel Guests               |     14.1  |
| 2018-07-01   |             4 | Luxury Retail Researchers         |     13.97 |

```sql
-- Bottom 10 interests which have the largest composition values
WITH cte AS
(
SELECT i.month_year,
       i.interest_id,
       MAX(i.composition) AS max_com
FROM interest_metrics i 
JOIN filtered f ON i.interest_id = f.interest_id
GROUP BY i.month_year,
		 i.interest_id
ORDER BY max_com DESC
),
ranker AS(
SELECT *,
       RANK() OVER(PARTITION BY interest_id ORDER BY max_com ) AS ranker
FROM cte
)
SELECT month_year,
       r.interest_id,
       interest_name,
       max_com
FROM ranker r
JOIN interest_map i ON r.interest_id = i.id
WHERE ranker = 1
ORDER BY max_com LIMIT 10
```
| month_year   |   interest_id | interest_name                |   max_com |
|:-------------|--------------:|:-----------------------------|----------:|
| 2019-05-01   |         45524 | Mowing Equipment Shoppers    |      1.51 |
| 2019-05-01   |          4918 | Gastrointestinal Researchers |      1.52 |
| 2019-06-01   |         35742 | Disney Fans                  |      1.52 |
| 2019-04-01   |         44449 | United Nations Donors        |      1.52 |
| 2019-06-01   |         34083 | New York Giants Fans         |      1.52 |
| 2019-05-01   |         20768 | Beer Aficionados             |      1.52 |
| 2019-05-01   |         39336 | Philadelphia 76ers Fans      |      1.52 |
| 2019-05-01   |          6127 | LED Lighting Shoppers        |      1.53 |
| 2019-05-01   |         36877 | Crochet Enthusiasts          |      1.53 |
| 2019-06-01   |          6314 | Online Directory Searchers   |      1.53 |

**Q2. Which 5 interests had the lowest average ranking value?**
```sql
SELECT 
interest_id,
interest_name,
CAST(AVG(ranking) AS DECIMAL(10,1)) AS avg_rank
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
GROUP BY interest_id
ORDER BY avg_rank LIMIT 5
```

|   interest_id | interest_name                  |   avg_rank |
|--------------:|:-------------------------------|-----------:|
|         41548 | Winter Apparel Shoppers        |        1   |
|         42203 | Fitness Activity Tracker Users |        4.1 |
|           115 | Mens Shoe Shoppers             |        5.9 |
|         48154 | Elite Cycling Gear Shoppers    |        7.8 |
|           171 | Shoe Shoppers                  |        9.4 |

**Q3. Which 5 interests had the largest standard deviation in their percentile_ranking value?**
```sql
SELECT 
interest_id,
interest_name,
CAST(STDDEV(percentile_ranking) AS DECIMAL(10,2)) AS std_pct
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
GROUP BY interest_id
ORDER BY std_pct DESC LIMIT 5
```
|   interest_id | interest_name          |   std_pct |
|--------------:|:-----------------------|----------:|
|          6260 | Blockbuster Movie Fans |     29.19 |
|            23 | Techies                |     27.55 |
|           131 | Android Fans           |     27.48 |
|           150 | TV Junkies             |     27.16 |
|         38992 | Oregon Trip Planners   |     26.87 |

**Q4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?**
```sql
WITH cte AS
(
SELECT 
interest_id,
interest_name,
interest_summary,
CAST(STDDEV(percentile_ranking) AS DECIMAL(10,2)) AS std_pct
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
GROUP BY interest_id
ORDER BY std_pct DESC LIMIT 5
),
max_min AS 
(
SELECT i.interest_id,
	   c.interest_name,
       interest_summary,
       std_pct,
       MAX(percentile_ranking) AS max_pr,
       MIN(percentile_ranking) AS min_pr 
FROM cte c
JOIN interest_metrics i ON c.interest_id = i.interest_id
GROUP BY interest_id
)
SELECT m.interest_id,
	   m.interest_name,
       interest_summary,
       std_pct,
	   max_pr,
       min_pr,
       i1.month_year AS max_date,
       i2.month_year AS min_date
FROM max_min m 
JOIN interest_metrics i1 ON m.interest_id = i1.interest_id AND m.max_pr = i1.percentile_ranking
JOIN interest_metrics i2 ON m.interest_id = i2.interest_id AND m.min_pr = i2.percentile_ranking
```
|   interest_id | interest_name          | interest_summary                                                                                                                             |   std_pct |   max_pr |   min_pr | max_date   | min_date   |
|--------------:|:-----------------------|:---------------------------------------------------------------------------------------------------------------------------------------------|----------:|---------:|---------:|:-----------|:-----------|
|           131 | Android Fans           | Readers of Android news and product reviews.                                                                                                 |     27.48 |    75.03 |     4.84 | 2018-07-01 | 2019-03-01 |
|         38992 | Oregon Trip Planners   | People researching attractions and accommodations in Oregon. These consumers are more likely to spend money on travel and local attractions. |     26.87 |    82.44 |     2.2  | 2018-11-01 | 2019-07-01 |
|           150 | TV Junkies             | Consumers researching TV listings.                                                                                                           |     27.16 |    93.28 |    10.01 | 2018-07-01 | 2019-08-01 |
|            23 | Techies                | Readers of tech news and gadget reviews.                                                                                                     |     27.55 |    86.69 |     7.92 | 2018-07-01 | 2019-08-01 |
|          6260 | Blockbuster Movie Fans | Consumers reading reviews of major movie releases.                                                                                           |     29.19 |    60.63 |     2.26 | 2018-07-01 | 2019-08-01 |


**Q5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?**

Solution:

### D. Index Analysis
The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

**Q1. What is the top 10 interests by the average composition for each month?**
```sql
WITH avg_com AS
(
SELECT  interest_id,
        interest_name,
		month_year,
	    composition,
        index_value,
        CAST(composition/index_value AS DECIMAL(10,2)) AS avg_composition
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
WHERE month_year IS NOT NULL
),
rnk AS 
(
SELECT *,
       DENSE_RANK() OVER(PARTITION BY month_year ORDER BY avg_composition DESC) AS rnk
FROM avg_com
)
SELECT *
FROM rnk
WHERE rnk <= 10 
ORDER BY month_year
```
|   interest_id | interest_name                                        | month_year   |   composition |   index_value |   avg_composition |   rnk |
|--------------:|:-----------------------------------------------------|:-------------|--------------:|--------------:|------------------:|------:|
|          6324 | Las Vegas Trip Planners                              | 2018-07-01   |         10.3  |          1.4  |              7.36 |     1 |
|          6284 | Gym Equipment Owners                                 | 2018-07-01   |         18.82 |          2.71 |              6.94 |     2 |
|          4898 | Cosmetics and Beauty Shoppers                        | 2018-07-01   |         14.23 |          2.1  |              6.78 |     3 |
|            77 | Luxury Retail Shoppers                               | 2018-07-01   |         17.19 |          2.6  |              6.61 |     4 |
|            39 | Furniture Shoppers                                   | 2018-07-01   |         17.44 |          2.68 |              6.51 |     5 |
|         18619 | Asian Food Enthusiasts                               | 2018-07-01   |          9.15 |          1.5  |              6.1  |     6 |
|          6208 | Recently Retired Individuals                         | 2018-07-01   |          9.67 |          1.69 |              5.72 |     7 |
|         21060 | Family Adventures Travelers                          | 2018-07-01   |          8.58 |          1.77 |              4.85 |     8 |
|         21057 | Work Comes First Travelers                           | 2018-07-01   |         10.95 |          2.28 |              4.8  |     9 |
|            82 | HDTV Researchers                                     | 2018-07-01   |          9.99 |          2.12 |              4.71 |    10 |
|          6324 | Las Vegas Trip Planners                              | 2018-08-01   |          8.43 |          1.17 |              7.21 |     1 |
|          6284 | Gym Equipment Owners                                 | 2018-08-01   |         13.9  |          2.1  |              6.62 |     2 |
|            77 | Luxury Retail Shoppers                               | 2018-08-01   |         12.73 |          1.95 |              6.53 |     3 |
|            39 | Furniture Shoppers                                   | 2018-08-01   |         12.03 |          1.91 |              6.3  |     4 |
|          4898 | Cosmetics and Beauty Shoppers                        | 2018-08-01   |          7.98 |          1.27 |              6.28 |     5 |
|         21057 | Work Comes First Travelers                           | 2018-08-01   |         12.42 |          2.18 |              5.7  |     6 |
|         18619 | Asian Food Enthusiasts                               | 2018-08-01   |          6.59 |          1.16 |              5.68 |     7 |
|          6208 | Recently Retired Individuals                         | 2018-08-01   |          6.59 |          1.18 |              5.58 |     8 |
|          7541 | Alabama Trip Planners                                | 2018-08-01   |          6.09 |          1.26 |              4.83 |     9 |
|          5969 | Luxury Bedding Shoppers                              | 2018-08-01   |         10.85 |          2.3  |              4.72 |    10 |
|         21057 | Work Comes First Travelers                           | 2018-09-01   |         18.18 |          2.2  |              8.26 |     1 |
|         21245 | Readers of Honduran Content                          | 2018-09-01   |          3.95 |          0.52 |              7.6  |     2 |
|          7541 | Alabama Trip Planners                                | 2018-09-01   |          9.23 |          1.27 |              7.27 |     3 |
|          5969 | Luxury Bedding Shoppers                              | 2018-09-01   |         14.29 |          2.03 |              7.04 |     4 |
|         18783 | Nursing and Physicians Assistant Journal Researchers | 2018-09-01   |          8.51 |          1.27 |              6.7  |     5 |
|         10981 | New Years Eve Party Ticket Purchasers                | 2018-09-01   |          8.77 |          1.33 |              6.59 |     6 |
|            34 | Teen Girl Clothing Shoppers                          | 2018-09-01   |          9.08 |          1.39 |              6.53 |     7 |
|         10977 | Christmas Celebration Researchers                    | 2018-09-01   |         10.61 |          1.64 |              6.47 |     8 |
|         13497 | Restaurant Supply Shoppers                           | 2018-09-01   |          8.12 |          1.3  |              6.25 |     9 |
|          6065 | Solar Energy Researchers                             | 2018-09-01   |          4.24 |          0.68 |              6.24 |    10 |
|         21057 | Work Comes First Travelers                           | 2018-10-01   |         20.28 |          2.22 |              9.14 |     1 |
|          7541 | Alabama Trip Planners                                | 2018-10-01   |          9.3  |          1.31 |              7.1  |     2 |
|         21245 | Readers of Honduran Content                          | 2018-10-01   |          3.3  |          0.47 |              7.02 |     3 |
|         18783 | Nursing and Physicians Assistant Journal Researchers | 2018-10-01   |          9.83 |          1.4  |              7.02 |     3 |
|          5969 | Luxury Bedding Shoppers                              | 2018-10-01   |         14.15 |          2.04 |              6.94 |     4 |
|         10981 | New Years Eve Party Ticket Purchasers                | 2018-10-01   |         10.09 |          1.46 |              6.91 |     5 |
|            34 | Teen Girl Clothing Shoppers                          | 2018-10-01   |         10.04 |          1.48 |              6.78 |     6 |
|         10977 | Christmas Celebration Researchers                    | 2018-10-01   |         12.16 |          1.81 |              6.72 |     7 |
|         12133 | Luxury Boutique Hotel Researchers                    | 2018-10-01   |         15.15 |          2.32 |              6.53 |     8 |
|          6065 | Solar Energy Researchers                             | 2018-10-01   |          4.03 |          0.62 |              6.5  |     9 |
|         15879 | Freelancers                                          | 2018-10-01   |          8.65 |          1.35 |              6.41 |    10 |
|         21057 | Work Comes First Travelers                           | 2018-11-01   |         19.45 |          2.35 |              8.28 |     1 |
|         21245 | Readers of Honduran Content                          | 2018-11-01   |          3.83 |          0.54 |              7.09 |     2 |
|          6065 | Solar Energy Researchers                             | 2018-11-01   |          3.95 |          0.56 |              7.05 |     3 |
|          7541 | Alabama Trip Planners                                | 2018-11-01   |          8.43 |          1.26 |              6.69 |     4 |
|         18783 | Nursing and Physicians Assistant Journal Researchers | 2018-11-01   |          9.04 |          1.36 |              6.65 |     5 |
|          5969 | Luxury Bedding Shoppers                              | 2018-11-01   |         14.92 |          2.28 |              6.54 |     6 |
|         10981 | New Years Eve Party Ticket Purchasers                | 2018-11-01   |          9.85 |          1.56 |              6.31 |     7 |
|         10977 | Christmas Celebration Researchers                    | 2018-11-01   |         10.88 |          1.79 |              6.08 |     8 |
|            34 | Teen Girl Clothing Shoppers                          | 2018-11-01   |          9.34 |          1.57 |              5.95 |     9 |
|         13497 | Restaurant Supply Shoppers                           | 2018-11-01   |          8.1  |          1.45 |              5.59 |    10 |
|         21057 | Work Comes First Travelers                           | 2018-12-01   |         21.2  |          2.55 |              8.31 |     1 |
|         18783 | Nursing and Physicians Assistant Journal Researchers | 2018-12-01   |          9.6  |          1.38 |              6.96 |     2 |
|          7541 | Alabama Trip Planners                                | 2018-12-01   |          9.62 |          1.44 |              6.68 |     3 |
|          5969 | Luxury Bedding Shoppers                              | 2018-12-01   |         15.05 |          2.27 |              6.63 |     4 |
|         21245 | Readers of Honduran Content                          | 2018-12-01   |          3.49 |          0.53 |              6.58 |     5 |
|          6065 | Solar Energy Researchers                             | 2018-12-01   |          3.47 |          0.53 |              6.55 |     6 |
|         10981 | New Years Eve Party Ticket Purchasers                | 2018-12-01   |         10.62 |          1.64 |              6.48 |     7 |
|            34 | Teen Girl Clothing Shoppers                          | 2018-12-01   |         11.23 |          1.76 |              6.38 |     8 |
|         10977 | Christmas Celebration Researchers                    | 2018-12-01   |         11.57 |          1.9  |              6.09 |     9 |
|         21237 | Chelsea Fans                                         | 2018-12-01   |          9.72 |          1.66 |              5.86 |    10 |
|         21057 | Work Comes First Travelers                           | 2019-01-01   |         18.99 |          2.48 |              7.66 |     1 |
|          6065 | Solar Energy Researchers                             | 2019-01-01   |          4.02 |          0.57 |              7.05 |     2 |
|         21245 | Readers of Honduran Content                          | 2019-01-01   |          3.8  |          0.57 |              6.67 |     3 |
|         18783 | Nursing and Physicians Assistant Journal Researchers | 2019-01-01   |          9.04 |          1.4  |              6.46 |     4 |
|          5969 | Luxury Bedding Shoppers                              | 2019-01-01   |         14.92 |          2.31 |              6.46 |     4 |
|          7541 | Alabama Trip Planners                                | 2019-01-01   |          9.6  |          1.49 |              6.44 |     5 |
|         10981 | New Years Eve Party Ticket Purchasers                | 2019-01-01   |          9.91 |          1.61 |              6.16 |     6 |
|            34 | Teen Girl Clothing Shoppers                          | 2019-01-01   |         10.07 |          1.69 |              5.96 |     7 |
|         10977 | Christmas Celebration Researchers                    | 2019-01-01   |         10.96 |          1.94 |              5.65 |     8 |
|         21237 | Chelsea Fans                                         | 2019-01-01   |          9.2  |          1.68 |              5.48 |     9 |
|         15878 | Readers of Catholic News                             | 2019-01-01   |          4.77 |          0.87 |              5.48 |     9 |
|         19621 | Portugal Trip Planners                               | 2019-01-01   |          9.08 |          1.69 |              5.37 |    10 |
|         21057 | Work Comes First Travelers                           | 2019-02-01   |         18.39 |          2.4  |              7.66 |     1 |
|         18783 | Nursing and Physicians Assistant Journal Researchers | 2019-02-01   |          8.28 |          1.21 |              6.84 |     2 |
|          5969 | Luxury Bedding Shoppers                              | 2019-02-01   |         14.39 |          2.13 |              6.76 |     3 |
|          7541 | Alabama Trip Planners                                | 2019-02-01   |          9.98 |          1.5  |              6.65 |     4 |
|          6065 | Solar Energy Researchers                             | 2019-02-01   |          3.95 |          0.6  |              6.58 |     5 |
|         10981 | New Years Eve Party Ticket Purchasers                | 2019-02-01   |          9.65 |          1.47 |              6.56 |     6 |
|            34 | Teen Girl Clothing Shoppers                          | 2019-02-01   |          9.24 |          1.47 |              6.29 |     7 |
|         21245 | Readers of Honduran Content                          | 2019-02-01   |          3.18 |          0.51 |              6.24 |     8 |
|         19620 | PlayStation Enthusiasts                              | 2019-02-01   |          3.99 |          0.64 |              6.23 |     9 |
|         10977 | Christmas Celebration Researchers                    | 2019-02-01   |         10.52 |          1.76 |              5.98 |    10 |
|          7541 | Alabama Trip Planners                                | 2019-03-01   |          9.88 |          1.51 |              6.54 |     1 |
|         18783 | Nursing and Physicians Assistant Journal Researchers | 2019-03-01   |          8.87 |          1.36 |              6.52 |     2 |
|          5969 | Luxury Bedding Shoppers                              | 2019-03-01   |         12.3  |          1.9  |              6.47 |     3 |
|          6065 | Solar Energy Researchers                             | 2019-03-01   |          3.84 |          0.6  |              6.4  |     4 |
|         21245 | Readers of Honduran Content                          | 2019-03-01   |          2.98 |          0.48 |              6.21 |     5 |
|         10981 | New Years Eve Party Ticket Purchasers                | 2019-03-01   |          9.06 |          1.46 |              6.21 |     5 |
|         19620 | PlayStation Enthusiasts                              | 2019-03-01   |          4.24 |          0.7  |              6.06 |     6 |
|            34 | Teen Girl Clothing Shoppers                          | 2019-03-01   |          8.48 |          1.41 |              6.01 |     7 |
|         15878 | Readers of Catholic News                             | 2019-03-01   |          4.58 |          0.81 |              5.65 |     8 |
|         10977 | Christmas Celebration Researchers                    | 2019-03-01   |         10.5  |          1.87 |              5.61 |     9 |
|         13497 | Restaurant Supply Shoppers                           | 2019-03-01   |          8.31 |          1.48 |              5.61 |     9 |
|          6343 | Patio Furniture Shoppers                             | 2019-03-01   |         10.48 |          1.91 |              5.49 |    10 |
|          6065 | Solar Energy Researchers                             | 2019-04-01   |          3.64 |          0.58 |              6.28 |     1 |
|          7541 | Alabama Trip Planners                                | 2019-04-01   |          8.94 |          1.44 |              6.21 |     2 |
|          5969 | Luxury Bedding Shoppers                              | 2019-04-01   |         11.01 |          1.82 |              6.05 |     3 |
|         21245 | Readers of Honduran Content                          | 2019-04-01   |          3.19 |          0.53 |              6.02 |     4 |
|         18783 | Nursing and Physicians Assistant Journal Researchers | 2019-04-01   |          7.87 |          1.31 |              6.01 |     5 |
|         10981 | New Years Eve Party Ticket Purchasers                | 2019-04-01   |          8.36 |          1.48 |              5.65 |     6 |
|         19620 | PlayStation Enthusiasts                              | 2019-04-01   |          3.92 |          0.71 |              5.52 |     7 |
|            34 | Teen Girl Clothing Shoppers                          | 2019-04-01   |          7.87 |          1.46 |              5.39 |     8 |
|         15878 | Readers of Catholic News                             | 2019-04-01   |          4.08 |          0.77 |              5.3  |     9 |
|         13497 | Restaurant Supply Shoppers                           | 2019-04-01   |          7.46 |          1.47 |              5.07 |    10 |
|         21245 | Readers of Honduran Content                          | 2019-05-01   |          2.91 |          0.66 |              4.41 |     1 |
|         15878 | Readers of Catholic News                             | 2019-05-01   |          3.02 |          0.74 |              4.08 |     2 |
|          6065 | Solar Energy Researchers                             | 2019-05-01   |          2.78 |          0.71 |              3.92 |     3 |
|         19620 | PlayStation Enthusiasts                              | 2019-05-01   |          2.59 |          0.73 |              3.55 |     4 |
|          7541 | Alabama Trip Planners                                | 2019-05-01   |          5.31 |          1.59 |              3.34 |     5 |
|             2 | Gamers                                               | 2019-05-01   |          2.27 |          0.69 |              3.29 |     6 |
|          5969 | Luxury Bedding Shoppers                              | 2019-05-01   |          7.53 |          2.32 |              3.25 |     7 |
|         10981 | New Years Eve Party Ticket Purchasers                | 2019-05-01   |          6.02 |          1.89 |              3.19 |     8 |
|         15884 | Video Gamers                                         | 2019-05-01   |          2.23 |          0.7  |              3.19 |     8 |
|         18783 | Nursing and Physicians Assistant Journal Researchers | 2019-05-01   |          4.57 |          1.45 |              3.15 |     9 |
|          4917 | Teen Content Readers                                 | 2019-05-01   |          2.95 |          0.94 |              3.14 |    10 |
|          6324 | Las Vegas Trip Planners                              | 2019-06-01   |          4.59 |          1.66 |              2.77 |     1 |
|          6284 | Gym Equipment Owners                                 | 2019-06-01   |          6.94 |          2.72 |              2.55 |     2 |
|          4898 | Cosmetics and Beauty Shoppers                        | 2019-06-01   |          3.54 |          1.39 |              2.55 |     2 |
|         18619 | Asian Food Enthusiasts                               | 2019-06-01   |          3.32 |          1.32 |              2.52 |     3 |
|            77 | Luxury Retail Shoppers                               | 2019-06-01   |          5.53 |          2.25 |              2.46 |     4 |
|            39 | Furniture Shoppers                                   | 2019-06-01   |          6.03 |          2.52 |              2.39 |     5 |
|          6253 | Medicare Researchers                                 | 2019-06-01   |          3.85 |          1.64 |              2.35 |     6 |
|          6208 | Recently Retired Individuals                         | 2019-06-01   |          4.24 |          1.87 |              2.27 |     7 |
|          7535 | Medicare Provider Researchers                        | 2019-06-01   |          4.67 |          2.11 |              2.21 |     8 |
|           107 | Cruise Travel Intenders                              | 2019-06-01   |          4.15 |          1.89 |              2.2  |     9 |
|            82 | HDTV Researchers                                     | 2019-06-01   |          4.05 |          1.96 |              2.07 |    10 |
|          6324 | Las Vegas Trip Planners                              | 2019-07-01   |          4.17 |          1.48 |              2.82 |     1 |
|            77 | Luxury Retail Shoppers                               | 2019-07-01   |          6.52 |          2.32 |              2.81 |     2 |
|          6284 | Gym Equipment Owners                                 | 2019-07-01   |          7.19 |          2.58 |              2.79 |     3 |
|            39 | Furniture Shoppers                                   | 2019-07-01   |          7.16 |          2.57 |              2.79 |     3 |
|         18619 | Asian Food Enthusiasts                               | 2019-07-01   |          3.7  |          1.33 |              2.78 |     4 |
|          4898 | Cosmetics and Beauty Shoppers                        | 2019-07-01   |          3.98 |          1.43 |              2.78 |     4 |
|          6253 | Medicare Researchers                                 | 2019-07-01   |          4.8  |          1.73 |              2.77 |     5 |
|          7535 | Medicare Provider Researchers                        | 2019-07-01   |          5.67 |          2.08 |              2.73 |     6 |
|          6208 | Recently Retired Individuals                         | 2019-07-01   |          4.98 |          1.83 |              2.72 |     7 |
|          7536 | Medicare Price Shoppers                              | 2019-07-01   |          4.63 |          1.74 |              2.66 |     8 |
|           107 | Cruise Travel Intenders                              | 2019-07-01   |          4.81 |          1.88 |              2.56 |     9 |
|            82 | HDTV Researchers                                     | 2019-07-01   |          4.61 |          1.87 |              2.47 |    10 |
|          4898 | Cosmetics and Beauty Shoppers                        | 2019-08-01   |          4.12 |          1.51 |              2.73 |     1 |
|          6284 | Gym Equipment Owners                                 | 2019-08-01   |          7.1  |          2.61 |              2.72 |     2 |
|          6324 | Las Vegas Trip Planners                              | 2019-08-01   |          4    |          1.48 |              2.7  |     3 |
|         18619 | Asian Food Enthusiasts                               | 2019-08-01   |          3.67 |          1.37 |              2.68 |     4 |
|          6065 | Solar Energy Researchers                             | 2019-08-01   |          2.13 |          0.8  |              2.66 |     5 |
|            77 | Luxury Retail Shoppers                               | 2019-08-01   |          6.48 |          2.5  |              2.59 |     6 |
|            39 | Furniture Shoppers                                   | 2019-08-01   |          6.76 |          2.61 |              2.59 |     6 |
|          4931 | Marijuana Legalization Advocates                     | 2019-08-01   |          2.46 |          0.96 |              2.56 |     7 |
|          6253 | Medicare Researchers                                 | 2019-08-01   |          4.28 |          1.68 |              2.55 |     8 |
|          6208 | Recently Retired Individuals                         | 2019-08-01   |          4.41 |          1.74 |              2.53 |     9 |
|          6225 | Piercing Fans                                        | 2019-08-01   |          2.15 |          0.86 |              2.5  |    10 |


**Q2. For all of these top 10 interests - which interest appears the most often?**
```sql
WITH avg_com AS
(
SELECT  interest_id,
        interest_name,
		month_year,
	    composition,
        index_value,
        CAST(composition/index_value AS DECIMAL(10,2)) AS avg_composition
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
WHERE month_year IS NOT NULL
),
rnk AS 
(
SELECT *,
       DENSE_RANK() OVER(PARTITION BY month_year ORDER BY avg_composition DESC) AS rnk
FROM avg_com
),
count_id AS
(
SELECT interest_id, 
       COUNT(*) AS num_id
FROM rnk
WHERE rnk <= 10 
GROUP BY interest_id
ORDER BY num_id DESC 
)
SELECT interest_id,
       num_id
FROM count_id
WHERE num_id = (SELECT MAX(num_id) FROM count_id)
```
|   interest_id |   num_id |
|--------------:|---------:|
|          6065 |       10 |
|          7541 |       10 |
|          5969 |       10 |

**Q3. What is the average of the average composition for the top 10 interests for each month?**
```sql
WITH avg_com AS
(
SELECT  interest_id,
        interest_name,
		month_year,
	    composition,
        index_value,
        CAST(composition/index_value AS DECIMAL(10,2)) AS avg_composition
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
WHERE month_year IS NOT NULL
),
rnk AS 
(
SELECT *,
       DENSE_RANK() OVER(PARTITION BY month_year ORDER BY avg_composition DESC) AS rnk
FROM avg_com
)
SELECT month_year,
       CAST(AVG(avg_composition) AS DECIMAL(10,2)) AS avg_com_month
FROM rnk
WHERE rnk <= 10 
GROUP BY month_year
ORDER BY month_year
```
| month_year   |   avg_com_month |
|:-------------|----------------:|
| 2018-07-01   |            6.04 |
| 2018-08-01   |            5.95 |
| 2018-09-01   |            6.9  |
| 2018-10-01   |            7.01 |
| 2018-11-01   |            6.62 |
| 2018-12-01   |            6.65 |
| 2019-01-01   |            6.24 |
| 2019-02-01   |            6.58 |
| 2019-03-01   |            6.07 |
| 2019-04-01   |            5.75 |
| 2019-05-01   |            3.5  |
| 2019-06-01   |            2.39 |
| 2019-07-01   |            2.72 |
| 2019-08-01   |            2.62 |

**Q4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.**
```sql
WITH avg_com AS 
(
SELECT  
		month_year,
        interest_name,
        MAX(CAST(composition/index_value AS DECIMAL(10,2))) AS max_index_composition
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
GROUP BY month_year
), 
rolling_avg AS 
(
SELECT *,
	   CAST((max_index_composition + LAG(max_index_composition,1) OVER()  + LAG(max_index_composition,2) OVER())/3 AS DECIMAL(10,2)) AS 3_month_moving_avg,
       CONCAT(LAG(interest_name,1) OVER(), 
			  " : ",
              LAG(max_index_composition,1) OVER()
			 ) AS 1_month_ago,
       CONCAT(LAG(interest_name,2) OVER(), 
			  " : ",
              LAG(max_index_composition,2) OVER()
			 ) AS 2_month_ago
FROM avg_com
)
SELECT *
FROM rolling_avg
WHERE month_year BETWEEN '2018-09-01' AND '2019-08-01'
```
| month_year   | interest_name            |   max_index_composition |   3_month_moving_avg | 1_month_ago                     | 2_month_ago                                      |
|:-------------|:-------------------------|------------------------:|---------------------:|:--------------------------------|:-------------------------------------------------|
| 2018-09-01   | Running Enthusiasts      |                    8.26 |                 7.61 | Running Enthusiasts : 7.21      | Vacation Rental Accommodation Researchers : 7.36 |
| 2018-10-01   | Running Enthusiasts      |                    9.14 |                 8.2  | Running Enthusiasts : 8.26      | Running Enthusiasts : 7.21                       |
| 2018-11-01   | Competitive Tri-Athletes |                    8.28 |                 8.56 | Running Enthusiasts : 9.14      | Running Enthusiasts : 8.26                       |
| 2018-12-01   | Winter Apparel Shoppers  |                    8.31 |                 8.58 | Competitive Tri-Athletes : 8.28 | Running Enthusiasts : 9.14                       |
| 2019-01-01   | Winter Apparel Shoppers  |                    7.66 |                 8.08 | Winter Apparel Shoppers : 8.31  | Competitive Tri-Athletes : 8.28                  |
| 2019-02-01   | Winter Apparel Shoppers  |                    7.66 |                 7.88 | Winter Apparel Shoppers : 7.66  | Winter Apparel Shoppers : 8.31                   |
| 2019-03-01   | Winter Apparel Shoppers  |                    6.54 |                 7.29 | Winter Apparel Shoppers : 7.66  | Winter Apparel Shoppers : 7.66                   |
| 2019-04-01   | Winter Apparel Shoppers  |                    6.28 |                 6.83 | Winter Apparel Shoppers : 6.54  | Winter Apparel Shoppers : 7.66                   |
| 2019-05-01   | Winter Apparel Shoppers  |                    4.41 |                 5.74 | Winter Apparel Shoppers : 6.28  | Winter Apparel Shoppers : 6.54                   |
| 2019-06-01   | Winter Apparel Shoppers  |                    2.77 |                 4.49 | Winter Apparel Shoppers : 4.41  | Winter Apparel Shoppers : 6.28                   |
| 2019-07-01   | Winter Apparel Shoppers  |                    2.82 |                 3.33 | Winter Apparel Shoppers : 2.77  | Winter Apparel Shoppers : 4.41                   |
| 2019-08-01   | Winter Apparel Shoppers  |                    2.73 |                 2.77 | Winter Apparel Shoppers : 2.82  | Winter Apparel Shoppers : 2.77                   |

**Q5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?**

Solution:
