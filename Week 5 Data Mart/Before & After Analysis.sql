-- This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

-- Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

-- We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

-- Using this analysis approach - answer the following questions:

-- What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
WITH sales AS (
SELECT 
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -4 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 4 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
)
SELECT before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales
-- What about the entire 12 weeks before and after?
WITH sales AS (
SELECT 
       SUM(CASE WHEN week_date BETWEEN DATE_ADD("2020-06-15", INTERVAL -12 WEEK) AND "2020-06-15" THEN sales ELSE 0 END) before_sales,
       SUM(CASE WHEN week_date BETWEEN "2020-06-15" AND DATE_ADD("2020-06-15", INTERVAL 12 WEEK) THEN sales ELSE 0 END) after_sales
FROM clean_weekly_sales
)
SELECT before_sales,
       after_sales,
       after_sales - before_sales as actual_growth, 
       ROUND(100 *(after_sales - before_sales)/ before_sales, 2) as percent_growth 
FROM sales
-- How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
