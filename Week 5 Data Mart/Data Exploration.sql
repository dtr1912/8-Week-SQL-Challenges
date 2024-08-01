-- What day of the week is used for each week_date value?
SELECT DISTINCT(dayname(week_date)) AS week_day 
FROM clean_weekly_sales 
-- What range of week numbers are missing from the dataset?
WITH RECURSIVE all_week AS 
(
SELECT 1 AS week_number
UNION ALL 
SELECT week_number + 1 AS week_number
FROM all_week
WHERE week_number < 52
)
SELECT week_number
FROM all_week
WHERE week_number NOT IN (SELECT week_number FROM clean_weekly_sales)
-- How many total transactions were there for each year in the dataset?
SELECT calendar_year,
       SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year
-- What is the total sales for each region for each month?
SELECT region, 
       calendar_year,
	   month_number,
       SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region,
         month_number,
         calendar_year
ORDER BY region,
         calendar_year,
         month_number
-- What is the total count of transactions for each platform
SELECT 
  platform,
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform
-- What is the percentage of sales for Retail vs Shopify for each month?
SELECT 
       calendar_year,
       month_number,
       SUM(CASE WHEN platform = 'Retail' THEN sales 
				ELSE 0
		   END) *100/SUM(sales) AS retail_sales_pct,
	   SUM(CASE WHEN platform = 'Shopify' THEN sales 
				ELSE 0
		   END) *100/SUM(sales)  AS shopify_sales_pct
FROM clean_weekly_sales
GROUP BY month_number,
         calendar_year
ORDER BY calendar_year, month_number
-- What is the percentage of sales by demographic for each year in the dataset?
SELECT 
       calendar_year,
       demographic,
       SUM(sales)*100/ (SELECT SUM(sales) FROM clean_weekly_sales) AS demographic_sales_pct
FROM clean_weekly_sales
GROUP BY calendar_year, 
         demographic
         
-- Which age_band and demographic values contribute the most to Retail sales?
SELECT
  age_band, 
  demographic, 
  sum(sales) total_sales 
FROM
  clean_weekly_sales 
WHERE
  platform = "Retail" 
GROUP BY 
  age_band, 
  demographic;
-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT 
  calendar_year, 
  platform, 
  SUM(sales)/ SUM(transactions) AS avg_transaction
FROM
  clean_weekly_sales 
GROUP BY
  calendar_year, 
  platform 
ORDER BY
  calendar_year;