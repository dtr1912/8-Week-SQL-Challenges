-- Using a single SQL query - create a new output table which has the following details:

-- How many times was each product viewed?
-- How many times was each product added to cart?
-- How many times was each product added to a cart but not purchased (abandoned)?
-- How many times was each product purchased?
DROP TABLE IF EXISTS product; 
CREATE TABLE product AS(
WITH product AS(
SELECT 
product_id,
page_name,
product_category,
SUM(CASE WHEN event_name = 'Page View' THEN 1 ELSE 0 END) product_viewed ,
SUM(CASE WHEN event_name = 'Add to Cart' THEN 1 ELSE 0 END) added_cart
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE product_id IS NOT NULL
GROUP BY product_id,
page_name,
product_category
),
abandoned AS (
SELECT 
product_id,
page_name,
product_category,
COUNT(*) abandoned_product
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE event_name = 'Add to Cart' AND 
visit_id NOT IN 
(SELECT visit_id 
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
WHERE event_name = 'Purchase')
GROUP BY  product_id,
	      page_name,
          product_category
),
purchased AS (
SELECT 
product_id,
page_name,
product_category,
COUNT(*) purchased_product
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE event_name = 'Add to Cart' AND 
visit_id IN 
(SELECT visit_id 
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
WHERE event_name = 'Purchase')
GROUP BY  product_id,
	      page_name,
          product_category)
SELECT p.product_id,
       p.page_name,
       p.product_category,
       product_viewed,
       added_cart,
       abandoned_product,
       purchased_product
FROM product p
LEFT JOIN abandoned a ON p.product_id = a.product_id
LEFT JOIN purchased pc ON p.product_id = pc.product_id
ORDER BY product_id
)

SELECT * FROM product

-- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
DROP TABLE IF EXISTS product_category; 
CREATE TABLE product_category AS(
WITH product AS(
SELECT 
product_category,
SUM(CASE WHEN event_name = 'Page View' THEN 1 ELSE 0 END) product_viewed ,
SUM(CASE WHEN event_name = 'Add to Cart' THEN 1 ELSE 0 END) added_cart
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE product_category IS NOT NULL
GROUP BY 
product_category
),
abandoned AS (
SELECT 
product_category,
COUNT(*) abandoned_product
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE event_name = 'Add to Cart' AND 
visit_id NOT IN 
(SELECT visit_id 
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
WHERE event_name = 'Purchase')
GROUP BY product_category
),
purchased AS (
SELECT 
product_category,
COUNT(*) purchased_product
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE event_name = 'Add to Cart' AND 
visit_id IN 
(SELECT visit_id 
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
WHERE event_name = 'Purchase')
GROUP BY product_category)
SELECT p.product_category,
       product_viewed,
       added_cart,
       abandoned_product,
       purchased_product
FROM product p
LEFT JOIN abandoned a ON p.product_category = a.product_category
LEFT JOIN purchased pc ON p.product_category = pc.product_category
ORDER BY product_category
)

SELECT * FROM product_category

-- Use your 2 new output tables - answer the following questions:

-- Which product had the most views, cart adds and purchases?
-- the most views
SELECT product_id,
       page_name,
       product_category,
       product_viewed
FROM product
ORDER BY product_viewed DESC LIMIT 1
-- the most cart adds 
SELECT product_id,
       page_name,
       product_category,
       added_cart
FROM product
ORDER BY added_cart DESC LIMIT 1
-- the most purchases
SELECT product_id,
       page_name,
       product_category,
       purchased_product
FROM product
ORDER BY purchased_product DESC LIMIT 1
-- Which product was most likely to be abandoned?
SELECT product_id,
       page_name,
       product_category,
       abandoned_product
FROM product
ORDER BY abandoned_product DESC LIMIT 1
-- Which product had the highest view to purchase percentage?
SELECT product_id,
       page_name,
       product_category,
       100*purchased_product/product_viewed AS pct_view_to_purchase
FROM product
ORDER BY 100*purchased_product/product_viewed DESC LIMIT 1
-- What is the average conversion rate from view to cart add?
SELECT product_id,
       page_name,
       product_category,
       100*purchased_product/product_viewed AS pct_view_to_purchase
FROM product
ORDER BY 100*purchased_product/product_viewed DESC LIMIT 1
-- What is the average conversion rate from cart add to purchase?
SELECT 
       AVG(100*purchased_product/added_cart) AS avg_cart_to_purchase
FROM product