-- Which interests have been present in all month_year dates in our dataset?
SELECT COUNT(DISTINCT month_year) 
FROM interest_metrics
INTO @num_month

SELECT interest_id,
       interest_name,
       COUNT(month_year) AS cnt
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
GROUP BY interest_id 
HAVING  COUNT(month_year) = @num_month
-- Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
WITH cte AS
(
SELECT 
      interest_id, 
      COUNT(month_year) AS num_month
FROM interest_metrics
GROUP BY interest_id
)
SELECT DISTINCT num_month,
       COUNT(num_month) OVER(ORDER BY num_month DESC)/ COUNT(num_month) OVER() AS cumulative_pct
FROM cte
-- If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?
WITH cte AS
(
SELECT 
      interest_id, 
      COUNT(month_year) AS num_month
FROM interest_metrics
GROUP BY interest_id
HAVING COUNT(DISTINCT month_year) < 6
)
SELECT COUNT(i.interest_id) AS num_del
FROM interest_metrics i
JOIN cte c ON i.interest_id = c.interest_id
-- After removing these interests - how many unique interests are there for each month?
WITH cte AS
(
SELECT 
      interest_id, 
      COUNT(month_year) AS num_month
FROM interest_metrics
GROUP BY interest_id
HAVING COUNT(DISTINCT month_year) >= 6
)
SELECT month_year,
       COUNT(DISTINCT i.interest_id) AS num_del
FROM interest_metrics i
JOIN cte c ON i.interest_id = c.interest_id
WHERE month_year IS NOT NULL
GROUP BY month_year