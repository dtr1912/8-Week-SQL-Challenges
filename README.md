# 8 Week SQL Challenges
The solution for the 8 case studies from the **[#8WeekSQLChallenge](https://8weeksqlchallenge.com)**. 
## 📚 Table of Contents
Please find the solution links for the case studies below. Simply click on the links to access each solution.
- [Case Study #1: Danny's Diner](#case-study-1---dannys-diner)
- [Case Study #2: Pizza Runner](#case-study-2---pizza-runner)
- [Case Study #3: Foodie-Fi](#case-study-3---foodie-fi)
- [Case Study #4: Data Bank](#case-study-4---data-bank)
- [Case Study #5: Data Mart](#case-study-5---data-mart)
- [Case Study #6: Clique Bait](#case-study-6---clique-bait)
- [Case Study #7: Balanced Tree](#case-study-7---balanced-tree)
- [Case Study #8: Fresh Segments](#case-study-8---fresh-segments)
## Case Study #1 - Danny's Diner
### Introduction
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

### Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

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

## Case Study #2: Pizza Runner
## Case Study #3: Foodie-Fi
## Case Study #4: Data Bank
## Case Study #5: Data Mart
## Case Study #6: Clique Bait
## Case Study #7: Balanced Tree
## Case Study #8: Fresh Segments
