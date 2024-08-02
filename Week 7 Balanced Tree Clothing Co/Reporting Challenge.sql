-- Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

-- Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

-- He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).

-- Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :

SELECT monthname(start_txn_time) AS month,
       SUM(qty) AS total_quantity,
       SUM(qty*price) AS revenue,
       SUM(qty*price*discount/100) AS net_revenue,
       COUNT(DISTINCT txn_id) AS num_txn
FROM sales
WHERE monthname(start_txn_time) = 'January'

WITH unique_prod AS (
SELECT txn_id,
       COUNT(prod_id) AS num_prod
FROM sales
GROUP BY txn_id
)
SELECT CAST(AVG(num_prod) AS DECIMAL(10,2)) AS avg_prod_per_txn
FROM unique_prod