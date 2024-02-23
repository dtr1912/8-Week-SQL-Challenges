-- 1.How would you calculate the rate of growth for Foodie-Fi?
WITH monthlyRevenue AS (
  SELECT 
    MONTH(payment_date) AS months,
    SUM(amount) AS revenue
  FROM payments
  GROUP BY MONTH(payment_date)
)
SELECT 
  months,
  revenue,
  LAG(revenue) OVER(ORDER BY months) pre_revenue,
  (revenue-LAG(revenue) OVER(ORDER BY months))/revenue AS revenue_growth
FROM monthlyRevenue;
-- 2.What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
-- Key metrics: revenue growth by monthly, churn rate, customer growth
-- 3.What are some key customer journeys or experiences that you would analyse further to improve customer retention?
-- Customers who downgraded their plan
-- Customers who upgraded from basic monthly to pro monthly or pro annual
-- Customers who cancelled the subscription
