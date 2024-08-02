-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT(customer_id)) as 'Number of customer'
FROM subscriptions
-- 2.What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT MONTH(start_date) as start_month, 
       YEAR(start_date) as start_year,
       COUNT(s.plan_id) as 'Number of trial plan'
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.plan_id = 0
GROUP BY start_month, start_year
ORDER BY COUNT(s.plan_id) DESC
-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT plan_name, 
       COUNT(s.plan_id) as 'number of plan',
       YEAR(start_date) start_year
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE  YEAR(start_date) > 2020
GROUP BY s.plan_id
ORDER BY COUNT(s.plan_id) DESC
-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT COUNT(DISTINCT(customer_id)) as 'Total numver of customer',
SUM(CASE WHEN plan_name= 'churn' THEN 1 ELSE 0 END) AS churned_customers,
ROUND(CAST(SUM(CASE WHEN plan_name = 'churn' THEN 1 ELSE NULL END) as decimal(5,1)) / CAST(COUNT(DISTINCT customer_id) as decimal(5,1)) * 100,1) AS perc_churn
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number
WITH temp AS
(SELECT customer_id,
        s.plan_id,
        plan_name, 
        LEAD (plan_name, 1) OVER (PARTITION BY customer_id ORDER BY s.plan_id) next_plan
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
)
SELECT (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS number_customer, 
	   COUNT(customer_id) AS churned_customer,
       CONCAT (ROUND((COUNT(customer_id)*100) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions)), '%' ) AS perc_churn
FROM temp t
WHERE plan_name = 'trial' AND next_plan = 'churn' 
-- 6.What is the number and percentage of customer plans after their initial free trial?
WITH temp AS
(SELECT customer_id,s.plan_id,plan_name, 
LEAD (plan_name, 1) OVER (PARTITION BY customer_id order by s.plan_id) next_plan
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
)
SELECT next_plan, 
	   COUNT(DISTINCT customer_id) as customer_plan,
	   (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS number_customer, 
	   CONCAT (CAST(COUNT(DISTINCT customer_id) as float)*100 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), '%' ) AS perc_plan
FROM temp 
WHERE plan_name = 'trial' and next_plan is not null
GROUP BY next_plan
-- 7.What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH temp AS 
(SELECT customer_id, 
		s.plan_id, 
        start_date, 
        LEAD(start_date, 1) OVER (PARTITION BY customer_id ORDER BY plan_id) as next_date
FROM subscriptions s
WHERE start_date <= '2020-12-31'
)
SELECT plan_name, 
       COUNT(customer_id) as num_customer,
       CONCAT(CAST(COUNT(customer_id) as float)*100/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions WHERE start_date <= '2020-12-31'),'%') as perc_plan
FROM temp t
JOIN plans p ON t.plan_id = p.plan_id
WHERE next_date is null or next_date > '2020-12-31'
GROUP BY plan_name
-- 8.How many customers have upgraded to an annual plan in 2020?
SELECT plan_name, 
        COUNT(s.plan_id) as number_annual_plan
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE plan_name = 'pro annual' and start_date <='2020-12-31'
GROUP BY plan_name;
-- 9.How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
DROP TABLE IF EXISTS annual_date;
CREATE temporary TABLE annual_date AS(
SELECT customer_id,
       start_date
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE plan_name = 'pro annual')

WITH temp1 AS (
SELECT s.customer_id,
       s.start_date, 
       a.start_date as annual_date,
       RANK() OVER(PARTITION BY customer_id ORDER BY s.plan_id) as join_date
FROM subscriptions s
LEFT JOIN annual_date a ON s.start_date = a.start_date AND s.customer_id = a.customer_id)
, temp2 AS (
SELECT customer_id, 
       start_date,
       LEAD(start_date,1) OVER(PARTITION BY customer_id) AS annual
FROM temp1
WHERE join_date = 1 or annual_date is not null )
SELECT ROUND(AVG(DATEDIFF(annual,start_date))) as 'avg days from join to annual'
FROM temp2
-- 10.Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH trial_plan AS (
    SELECT customer_id, 
	   start_date AS trial_date
    FROM subscriptions
    WHERE plan_id = 0
),
annual_plan AS (
    SELECT customer_id,
	   start_date as annual_date
    FROM subscriptions
    WHERE plan_id = 3
)
SELECT
    CONCAT(FLOOR(TIMESTAMPDIFF(day, trial_date, annual_date) / 30) * 30, '-', FLOOR(TIMESTAMPDIFF(day, trial_date, annual_date) / 30) * 30 + 30, ' days') AS period,
    COUNT(*) AS total_customers,
    ROUND(AVG(TIMESTAMPDIFF(day, trial_date, annual_date)), 0) AS avg_days_to_upgrade
FROM trial_plan tp
JOIN annual_plan ap ON tp.customer_id = ap.customer_id
WHERE ap.annual_date IS NOT NULL
GROUP BY FLOOR(TIMESTAMPDIFF(day, trial_date, annual_date) / 30);

-- 11.How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH temp AS
(SELECT *, 
        LEAD(plan_id,1) OVER( PARTITION BY customer_id ORDER BY plan_id) as next_plan
FROM subscriptions
WHERE start_date <= '2020-12-31')
SELECT COUNT(*) as num_downgrade
FROM temp
WHERE next_plan = 1 AND plan_id = 2;