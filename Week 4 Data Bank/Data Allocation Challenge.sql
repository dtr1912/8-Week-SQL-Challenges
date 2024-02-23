-- To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:

-- Option 1: data is allocated based off the amount of money at the end of the previous month
-- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
-- Option 3: data is updated real-time
-- For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

-- running customer balance column that includes the impact each transaction
-- customer balance at the end of each month
-- minimum, average and maximum values of the running balance for each customer
-- Using all of the data available - how much data would have been required for each option on a monthly basis?
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


       

