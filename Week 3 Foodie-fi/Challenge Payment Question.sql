-- The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the 
-- subscriptions table with the following requirements:
-- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
-- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
-- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
-- once a customer churns they will no longer make payments

DROP TABLE IF EXISTS payment_2020;
CREATE TABLE payment_2020 
(            customer_id INT primary key,
             plan_id INT,
             plan_name varchar(50),
             payment_date date,
             amount decimal(10,2)
)
WITH next_date AS 
(SELECT customer_id,
        s.plan_id,
        plan_name,
        price,
        start_date,
        LEAD(start_date,1) OVER(PARTITION BY customer_id ORDER BY s.plan_id) as next_date,
        CASE WHEN LEAD(start_date,1) OVER(PARTITION BY customer_id ORDER BY s.plan_id) is null OR LEAD(start_date,1) OVER(PARTITION BY customer_id ORDER BY s.plan_id) >= '2020-12-31' THEN '2020-12-31'
             ELSE LEAD(start_date,1) OVER(PARTITION BY customer_id ORDER BY s.plan_id)
		END as end_date
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
)
SELECT customer_id,
        plan_id,
        plan_name,
        start_date,
        end_date
FROM next_date
WHERE plan_name !='trial' and plan_name != 'churn'