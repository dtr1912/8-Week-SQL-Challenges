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
  MAX(IF(percentile = 50, day_diff, NULL)) as median, 
  MAX(IF(percentile = 80, day_diff, NULL)) as 80_percentile, 
  MAX(IF(percentile = 95, day_diff, NULL)) as 95_percentile
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

       






