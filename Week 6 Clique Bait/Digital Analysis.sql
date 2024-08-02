-- How many users are there?
SELECT COUNT(DISTINCT user_id) num_users
FROM users
-- How many cookies does each user have on average?
WITH count_cookie AS(
SELECT user_id, 
       COUNT(cookie_id) num_cookies
FROM users
GROUP BY user_id
)
SELECT AVG(num_cookies) AS avg_cookie
FROM count_cookie
-- What is the unique number of visits by all users per month?
SELECT
  MONTHNAME(event_time) AS months, 
  COUNT(DISTINCT visit_id) AS num_of_visits 
FROM events 
GROUP BY months, 
         MONTH(event_time) 
ORDER BY MONTH(event_time);
-- What is the number of events for each event type?
SELECT event_name,
       COUNT(*) num_of_events
FROM events e
JOIN event_identifier i ON e.event_type = i.event_type
GROUP BY event_name

-- What is the percentage of visits which have a purchase event?
SELECT 100*COUNT(DISTINCT visit_id) / (SELECT COUNT(DISTINCT visit_id) FROM events) AS pct_of_purchase
FROM events e
JOIN event_identifier i ON e.event_type = i.event_type
WHERE event_name = 'Purchase'
-- What is the percentage of visits which view the checkout page but do not have a purchase event?
WITH view_checkout AS (
  SELECT COUNT(e.visit_id) AS cnt
  FROM events e
  JOIN event_identifier ei ON e.event_type = ei.event_type
  JOIN page_hierarchy p ON e.page_id = p.page_id
  WHERE ei.event_name = 'Page View'
    AND p.page_name = 'Checkout'
)
SELECT CAST(100-(100.0 * COUNT(DISTINCT e.visit_id) 
		/ (SELECT cnt FROM view_checkout)) AS decimal(10, 2)) AS pct_view_checkout_not_purchase
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase'
-- What are the top 3 pages by number of views?
SELECT 
  ph.page_name,
  COUNT(*) AS page_views
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE ei.event_name = 'Page View'
GROUP BY ph.page_name
ORDER BY page_views DESC LIMIT 3
-- What is the number of views and cart adds for each product category?
SELECT 
  product_category,
  SUM(CASE WHEN event_name = 'Page View' THEN 1 ELSE 0 END) page_views,
  SUM(CASE WHEN event_name = 'Add to Cart' THEN 1 ELSE 0 END) add_cart
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE product_category IS NOT NULL
GROUP BY product_category
-- What are the top 3 products by purchases?
SELECT product_id,
	   page_name,
       COUNT(*) AS num_purchase
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
	      page_name
ORDER BY COUNT(*) DESC LIMIT 3
