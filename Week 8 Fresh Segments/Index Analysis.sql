-- What is the top 10 interests by the average composition for each month?
WITH avg_com AS
(
SELECT  interest_id,
        interest_name,
		month_year,
	    composition,
        index_value,
        CAST(composition/index_value AS DECIMAL(10,2)) AS avg_composition
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
WHERE month_year IS NOT NULL
),
rnk AS 
(
SELECT *,
       DENSE_RANK() OVER(PARTITION BY month_year ORDER BY avg_composition DESC) AS rnk
FROM avg_com
)
SELECT *
FROM rnk
WHERE rnk <= 10 
ORDER BY month_year
-- For all of these top 10 interests - which interest appears the most often?
WITH avg_com AS
(
SELECT  interest_id,
        interest_name,
		month_year,
	    composition,
        index_value,
        CAST(composition/index_value AS DECIMAL(10,2)) AS avg_composition
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
WHERE month_year IS NOT NULL
),
rnk AS 
(
SELECT *,
       DENSE_RANK() OVER(PARTITION BY month_year ORDER BY avg_composition DESC) AS rnk
FROM avg_com
),
count_id AS
(
SELECT interest_id, 
       COUNT(*) AS num_id
FROM rnk
WHERE rnk <= 10 
GROUP BY interest_id
ORDER BY num_id DESC 
)
SELECT interest_id,
       num_id
FROM count_id
WHERE num_id = (SELECT MAX(num_id) FROM count_id)
-- What is the average of the average composition for the top 10 interests for each month?
WITH avg_com AS
(
SELECT  interest_id,
        interest_name,
		month_year,
	    composition,
        index_value,
        CAST(composition/index_value AS DECIMAL(10,2)) AS avg_composition
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
WHERE month_year IS NOT NULL
),
rnk AS 
(
SELECT *,
       DENSE_RANK() OVER(PARTITION BY month_year ORDER BY avg_composition DESC) AS rnk
FROM avg_com
)
SELECT month_year,
       CAST(AVG(avg_composition) AS DECIMAL(10,2)) AS avg_com_month
FROM rnk
WHERE rnk <= 10 
GROUP BY month_year
ORDER BY month_year
-- What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
WITH avg_com AS 
(
SELECT  
		month_year,
        interest_name,
        MAX(CAST(composition/index_value AS DECIMAL(10,2))) AS max_index_composition
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
GROUP BY month_year
), 
rolling_avg AS 
(
SELECT *,
	   CAST((max_index_composition + LAG(max_index_composition,1) OVER()  + LAG(max_index_composition,2) OVER())/3 AS DECIMAL(10,2)) AS 3_month_moving_avg,
       CONCAT(LAG(interest_name,1) OVER(), 
			  " : ",
              LAG(max_index_composition,1) OVER()
			 ) AS 1_month_ago,
       CONCAT(LAG(interest_name,2) OVER(), 
			  " : ",
              LAG(max_index_composition,2) OVER()
			 ) AS 2_month_ago
FROM avg_com
)
SELECT *
FROM rolling_avg
WHERE month_year BETWEEN '2018-09-01' AND '2019-08-01'
-- Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?