-- How many unique nodes are there on the Data Bank system? There are 5 unique nodes on the Data Bank system
SELECT COUNT(DISTINCT node_id) 'Number of node'
FROM  customer_nodes
-- What is the number of nodes per region?
SELECT region_name, 
       COUNT(node_id) as 'Number of nodes per region'
FROM customer_nodes n
JOIN regions r ON n.region_id=r.region_id
GROUP BY n.region_id 
-- How many customers are allocated to each region?
SELECT region_name, 
       COUNT(DISTINCT customer_id)  'Number of customers each region'
FROM customer_nodes n
JOIN regions r ON n.region_id = r.region_id
GROUP BY n.region_id
-- How many days on average are customers reallocated to a different node?
-- On average, customers are reallocated to a different node every 15 days.
SELECT ROUND(AVG(DATEDIFF(end_date,start_date))) avg_reallocation_days
FROM customer_nodes 
WHERE end_date != '9999-12-31'
-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH CTE AS (
SELECT region_id,
       start_date,
       end_date,
	   DATEDIFF(end_date, start_date) reallocation_day
FROM customer_nodes c
WHERE end_date != '9999-12-31'
ORDER BY region_id, reallocation_day
)
SELECT DISTINCT(region_id),
       


