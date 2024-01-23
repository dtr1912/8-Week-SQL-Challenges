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
	   COUNT(DISTINCT customer_id)  
FROM temp 
WHERE deposit_count > 1 AND  (withdrawl_count >= 1 OR purchase_count >= 1)
GROUP BY month_name
-- What is the closing balance for each customer at the end of the month?

-- What is the percentage of customers who increase their closing balance by more than 5%?

