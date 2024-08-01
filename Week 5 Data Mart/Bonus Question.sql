-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

-- region
-- platform
-- age_band
-- demographic
-- customer_type
-- Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?
WITH sales AS (
SELECT region,
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -12 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 12 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
GROUP BY region
)
SELECT region,
       before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales
-- platform
WITH sales AS (
SELECT platform,
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -12 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 12 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
GROUP BY platform
)
SELECT platform
       before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales
-- age_band
WITH sales AS (
SELECT age_band,
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -12 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 12 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
GROUP BY age_band
)
SELECT age_band,
       before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales
-- demographic
WITH sales AS (
SELECT demographic,
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -12 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 12 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
GROUP BY demographic
)
SELECT demographic,
       before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales
-- customer_type
WITH sales AS (
SELECT customer_type,
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -12 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 12 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
GROUP BY customer_type
)
SELECT customer_type,
       before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales