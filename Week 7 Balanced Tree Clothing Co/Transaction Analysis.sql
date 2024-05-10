-- How many unique transactions were there?
SELECT COUNT(DISTINCT txn_id) AS num_txn
FROM sales
-- What is the average unique products purchased in each transaction?
WITH unique_prod AS (
SELECT txn_id,
       COUNT(prod_id) AS num_prod
FROM sales
GROUP BY txn_id
)
SELECT AVG(num_prod) AS avg_prod_each_txn
FROM unique_prod
-- What are the 25th, 50th and 75th percentile values for the revenue per transaction?
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
-- What is the average discount value per transaction?
WITH temp AS(
SELECT txn_id,
	   CAST(SUM(qty*price*discount/100) AS FLOAT) AS total_discount
FROM sales 
GROUP BY txn_id
)
SELECT CAST(AVG(total_discount) AS FLOAT) AS avg_discount
FROM temp 
-- What is the percentage split of all transactions for members vs non-members?
SELECT 
  CAST(100.0*COUNT(DISTINCT CASE WHEN member = 't' THEN txn_id END) / COUNT(DISTINCT txn_id) AS FLOAT) AS members_pct,
  CAST(100.0*COUNT(DISTINCT CASE WHEN member = 'f' THEN txn_id END) / COUNT(DISTINCT txn_id) AS FLOAT) AS non_members_pct
FROM sales;
-- What is the average revenue for member transactions and non-member transactions?
SELECT
  CASE WHEN member = 'f' THEN 'member'
  ELSE 'non_member'
  END AS member, 
  ROUND( SUM(qty * price) / COUNT(distinct txn_id), 2) as avg_revenue 
FROM sales 
GROUP BY member