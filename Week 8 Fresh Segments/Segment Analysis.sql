-- Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year
DROP TABLE IF EXISTS filtered;
CREATE TEMPORARY TABLE filtered AS
(
SELECT 
      interest_id, 
      COUNT(month_year) AS num_month
FROM interest_metrics
GROUP BY interest_id
HAVING COUNT(DISTINCT month_year) >= 6
)
SELECT * FROM filtered
-- top 10 interests which have the largest composition values
WITH cte AS
(
SELECT i.month_year,
       i.interest_id,
       MAX(i.composition) AS max_com
FROM interest_metrics i 
JOIN filtered f ON i.interest_id = f.interest_id
GROUP BY i.month_year,
		 i.interest_id
ORDER BY max_com DESC
),
ranker AS(
SELECT *,
       RANK() OVER(PARTITION BY interest_id ORDER BY max_com DESC) AS ranker
FROM cte
)
SELECT month_year,
       r.interest_id,
       interest_name,
       max_com
FROM ranker r
JOIN interest_map i ON r.interest_id = i.id
WHERE ranker = 1
ORDER BY max_com DESC LIMIT 10
-- Bottom 10 interests which have the largest composition values
WITH cte AS
(
SELECT i.month_year,
       i.interest_id,
       MAX(i.composition) AS max_com
FROM interest_metrics i 
JOIN filtered f ON i.interest_id = f.interest_id
GROUP BY i.month_year,
		 i.interest_id
ORDER BY max_com DESC
),
ranker AS(
SELECT *,
       RANK() OVER(PARTITION BY interest_id ORDER BY max_com ) AS ranker
FROM cte
)
SELECT month_year,
       r.interest_id,
       interest_name,
       max_com
FROM ranker r
JOIN interest_map i ON r.interest_id = i.id
WHERE ranker = 1
ORDER BY max_com LIMIT 10
-- Which 5 interests had the lowest average ranking value?
SELECT 
interest_id,
interest_name,
CAST(AVG(ranking) AS DECIMAL(10,1)) AS avg_rank
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
GROUP BY interest_id
ORDER BY avg_rank LIMIT 5
-- Which 5 interests had the largest standard deviation in their percentile_ranking value?
SELECT 
interest_id,
interest_name,
CAST(STDDEV(percentile_ranking) AS DECIMAL(10,2)) AS std_pct
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
GROUP BY interest_id
ORDER BY std_pct DESC LIMIT 5
-- For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?
WITH cte AS
(
SELECT 
interest_id,
interest_name,
interest_summary,
CAST(STDDEV(percentile_ranking) AS DECIMAL(10,2)) AS std_pct
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
GROUP BY interest_id
ORDER BY std_pct DESC LIMIT 5
),
max_min AS 
(
SELECT i.interest_id,
	   c.interest_name,
       interest_summary,
       std_pct,
       MAX(percentile_ranking) AS max_pr,
       MIN(percentile_ranking) AS min_pr 
FROM cte c
JOIN interest_metrics i ON c.interest_id = i.interest_id
GROUP BY interest_id
)
SELECT m.interest_id,
	   m.interest_name,
       interest_summary,
       std_pct,
	   max_pr,
       min_pr,
       i1.month_year AS max_date,
       i2.month_year AS min_date
FROM max_min m 
JOIN interest_metrics i1 ON m.interest_id = i1.interest_id AND m.max_pr = i1.percentile_ranking
JOIN interest_metrics i2 ON m.interest_id = i2.interest_id AND m.min_pr = i2.percentile_ranking
