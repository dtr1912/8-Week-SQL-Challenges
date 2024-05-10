-- What are the top 3 products by total revenue before discount?
SELECT 
       product_name,
	   SUM(qty*s.price) AS total_revenue
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
GROUP BY product_name
ORDER BY total_revenue DESC LIMIT 3
-- What is the total quantity, revenue and discount for each segment?
SELECT segment_id, 
       segment_name,
       SUM(qty) AS total_qty,
       SUM(qty*s.price) AS revenue,
       SUM(discount) AS total_discount
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
GROUP BY segment_id
-- What is the top selling product for each segment?
WITH temp AS(
SELECT segment_id,
       segment_name, 
       product_name,
       SUM(qty) as num_qty,
       RANK() OVER(PARTITION BY segment_id ORDER BY SUM(qty) DESC) rank_qty
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
GROUP BY segment_id, prod_id
ORDER BY segment_id
)
SELECT segment_id,
       segment_name, 
       product_name,
       num_qty AS top_qty
FROM temp 
WHERE rank_qty =1 
-- What is the total quantity, revenue and discount for each category?
SELECT category_id,
       category_name,
       SUM(qty) AS total_qty,
       SUM(s.price*qty) AS revenue,
       SUM(qty*s.price*discount/100) AS discount
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
GROUP BY category_id
-- What is the top selling product for each category?
WITH temp AS(
SELECT category_id,
       category_name, 
       product_name,
       SUM(qty) as num_qty,
       RANK() OVER(PARTITION BY category_id ORDER BY SUM(qty) DESC) rank_qty
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
GROUP BY category_id, prod_id
ORDER BY category_id
)
SELECT category_id,
       category_name, 
       product_name,
       num_qty AS top_qty
FROM temp 
WHERE rank_qty =1 
-- What is the percentage split of revenue by product for each segment?
WITH temp AS (
SELECT segment_id,
       segment_name, 
       product_id,
       product_name,
       s.price,
       qty,
       SUM(s.price*qty) OVER(PARTITION BY product_id)/SUM(s.price*qty) OVER(PARTITION BY segment_id) AS pct
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
ORDER BY segment_id 
)
SELECT  segment_name,
        product_name,
        CAST(pct*100 AS DECIMAL(10,2)) AS pct
FROM temp 
GROUP BY product_id
-- What is the percentage split of revenue by segment for each category?
WITH temp AS (
SELECT category_id,
       category_name, 
       segment_id,
       segment_name,
       s.price,
       qty,
       SUM(s.price*qty) OVER(PARTITION BY segment_id)/SUM(s.price*qty) OVER(PARTITION BY category_id) AS pct
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
ORDER BY category_id
)
SELECT  category_name,
        segment_name,
        CAST(pct*100 AS DECIMAL(10,2)) AS pct
FROM temp 
GROUP BY segment_id
-- What is the percentage split of total revenue by category?
WITH temp AS
(SELECT category_name,
	   SUM(s.price*qty) revenue
FROM sales s
LEFT JOIN product_details p ON s.prod_id = p.product_id
GROUP BY category_id
)
SELECT *,
       CAST(100*revenue/SUM(revenue) OVER() AS DECIMAL(10,2)) AS pct
FROM temp
-- What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
WITH temp AS
(SELECT prod_id,
        txn_id
FROM sales
WHERE qty >= 1
)
,penetration AS
(SELECT DISTINCT prod_id,
	   product_name,
       COUNT(DISTINCT txn_id) AS prod_txn,
       (SELECT COUNT(DISTINCT txn_id) FROM sales) AS total_txn
FROM temp t
LEFT JOIN product_details p ON t.prod_id = p.product_id
GROUP BY prod_id
)
SELECT *,
       CAST(100*prod_txn/total_txn AS DECIMAL(10,2)) AS penetration 
FROM penetration
-- What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
WITH prod AS (
SELECT
    txn_id, 
    product_name 
FROM sales s
LEFT JOIN product_details PD ON s.prod_id = pd.product_id
WHERE qty >=1
) 
SELECT
  p1.product_name as product_1, 
  p2.product_name as product_2, 
  p3.product_name as product_3, 
  COUNT(*) as purchase_count 
FROM 
  prod AS p1 
  JOIN prod AS p2 ON p1.txn_id = p2.txn_id 
  AND p1.product_name != p2.product_name 
  JOIN prod AS p3 ON p1.txn_id = p3.txn_id 
  AND p1.product_name != p3.product_name 
  AND p2.product_name != p3.product_name 
GROUP BY  
  product_1, 
  product_2, 
  product_3 
ORDER BY purchase_count DESC LIMIT 1
