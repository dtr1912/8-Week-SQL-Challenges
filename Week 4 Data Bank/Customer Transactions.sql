-- What is the unique count and total amount for each transaction type?
SELECT txn_type 'Transaction Type',
	   COUNT(txn_type) 'Number of Unique Type',
       SUM(txn_amount) 'Total Amount'
FROM customer_transactions
GROUP BY txn_type
-- What is the average total historical deposit counts and amounts for all customers?
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
-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
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
-- What is the closing balance for each customer at the end of the month?
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
-- What is the percentage of customers who increase their closing balance by more than 5%?
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
