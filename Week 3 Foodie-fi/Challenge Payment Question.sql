-- The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the 
-- subscriptions table with the following requirements:
-- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
-- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
-- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
-- once a customer churns they will no longer make payments
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
)
SELECT * FROM payments
