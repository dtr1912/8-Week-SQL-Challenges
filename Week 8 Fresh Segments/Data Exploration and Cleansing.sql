-- Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
ALTER TABLE interest_metrics 
MODIFY COLUMN month_year VARCHAR(10)
UPDATE interest_metrics 
SET month_year = CAST(CONCAT(_year,'-',_month,'-','01') AS DATE) 
-- What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order 
-- (earliest to latest) with the null values appearing first?
SELECT 
  month_year,
  COUNT(*) AS cnt
FROM interest_metrics
GROUP BY month_year
ORDER BY month_year;
-- What do you think we should do with these null values in the fresh_segments.interest_metrics
SELECT *
FROM interest_metrics
WHERE month_year IS NULL
ORDER BY interest_id DESC;
-- Since the corresponding values in composition, index_value, ranking, and percentile_ranking fields are not meaningful without the specific information on interest_id, I will delete rows with null interest_id.
DELETE FROM interest_metrics
WHERE interest_id IS NULL;
-- How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
SELECT 
COUNT(id) AS num_ma_not_me
FROM interest_map ma
LEFT JOIN interest_metrics me ON me.interest_id = ma.id
WHERE interest_id IS NULL
-- There are 7 values exist in the fresh_segments.interest_map table but not in the fresh_segments.interest_metrics table
SELECT 
COUNT(interest_id) AS num_me_not_ma
FROM interest_metrics me
LEFT JOIN interest_map ma ON me.interest_id = ma.id
WHERE id IS NULL
-- 0 value exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table

-- Summarise the id values in the fresh_segments.interest_map by its total record count in this table
SELECT COUNT(*) AS num_map_id
FROM interest_map;
-- What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
SELECT 
      me.*,
      ma.interest_name,
      ma.interest_summary,
      ma.created_at,
      ma.last_modified
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
WHERE interest_id = 21246
-- Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?
SELECT 
      SUM(CASE WHEN DATEDIFF(month_year,created_at) < 0 THEN 1 ELSE 0 END) AS check_value
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
-- Yes these records are valid because both the dates have the same month and we set the date for the month_year column to be the first day of the month
SELECT 
      month_year,
      created_at
FROM interest_metrics me
JOIN interest_map ma ON me.interest_id = ma.id
WHERE DATEDIFF(month_year,created_at) < 0