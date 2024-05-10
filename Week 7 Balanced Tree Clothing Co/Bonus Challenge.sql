-- Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.

-- Hint: you may want to consider using a recursive CTE to solve this problem!
WITH RECURSIVE cte AS (
SELECT parent_id AS id,
       id AS id_hierarchy,
       level_text,
       level_name
FROM product_hierarchy 
WHERE parent_id IS NOT NULL

UNION 

SELECT cte.id,
       ph.id AS id_hierarchy,
       cte.level_text,
       cte.level_name
FROM product_hierarchy ph
JOIN cte ON ph.parent_id = cte.id_hierarchy

)

SELECT product_id,
       price,
       CONCAT( c2.level_text, '', c1.level_text, '', '-', '', ph.level_text) AS product_name,
       c1.id AS category_id,
       c1.id_hierarchy AS segment_id,
       c2.id_hierarchy AS style_id, 
       ph.level_text AS category_name,
       c1.level_text AS segment_name,
       c2.level_text AS style_name
FROM cte c1 
JOIN cte c2 ON c1.id_hierarchy= c2.id
JOIN product_hierarchy ph ON c1.id = ph.id 
JOIN product_prices pp ON c2.id_hierarchy = pp.id


 