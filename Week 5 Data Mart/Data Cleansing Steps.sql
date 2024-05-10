-- In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TABLE clean_weekly_sales AS (
WITH clean AS (
SELECT CAST(CONCAT(substring_index(substring_index(week_date,'/',3 ),'/',-1), "-",
				   substring_index(substring_index(week_date,'/',2 ),'/',-1), "-",
				   substring_index(week_date,'/',1)) AS DATE) week_date,
		region,
        platform,
        customer_type,
		CASE WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
             WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
             WHEN RIGHT(segment,1) IN ('3','4') THEN 'Retirees'
		     ELSE "unknown"
		END as age_band,
        CASE WHEN LEFT(segment,1) = 'C' THEN 'Couples'
             WHEN LEFT(segment,1) = 'F' THEN 'Families'
             ELSE "unknown"
		END as demographic,
        transactions,
        sales,
        ROUND(sales/transactions, 2) avg_transactions
FROM weekly_sales 
)
SELECT week_date,
       WEEK(week_date) as week_number,
       MONTH(week_date) as month_number,
       YEAR(week_date) as calendar_year,
       region,
       platform,
       customer_type,
       age_band,
       demographic,
       transactions,
       sales,
       avg_transactions
FROM clean
)
       