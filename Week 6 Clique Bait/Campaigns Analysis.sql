-- Generate a table that has 1 single row for every unique visit_id record and has the following columns:
-- user_id
-- visit_id
-- visit_start_time: the earliest event_time for each visit
-- page_views: count of page views for each visit
-- cart_adds: count of product cart add events for each visit
-- purchase: 1/0 flag if a purchase event exists for each visit
-- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
-- impression: count of ad impressions for each visit
-- click: count of ad clicks for each visit
-- (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)
DROP TABLE IF EXISTS campaign_summary;
CREATE TABLE campaign_summary AS(
SELECT 
      u.user_id,
      e.visit_id,
      MIN(event_time) AS visit_start_time,
      SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS page_views,
      SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS cart_adds,
      SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase,
      CASE WHEN c.campaign_name IS NOT NULL THEN c.campaign_name
           ELSE 'No Campaign'
	  END AS campaign_name,
	  SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression,
	  SUM(CASE WHEN ei.event_name = 'Ad Click' THEN 1 ELSE 0 END) AS click
FROM events e
LEFT JOIN users u 
    ON e.cookie_id = u.cookie_id
JOIN event_identifier ei 
    ON e.event_type = ei.event_type
JOIN page_hierarchy ph 
    ON e.page_id = ph.page_id
LEFT JOIN campaign_identifier c 
    ON  c.start_date <= e.event_time AND e.event_time <= c.end_date
GROUP BY u.user_id, e.visit_id, c.campaign_name)
-- Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.
-- Some ideas you might want to investigate further include:
-- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
-- Number of users who received impressions during campaign periods 
SELECT COUNT(DISTINCT user_id) AS received_impressions
FROM campaign_summary
WHERE impression > 0
AND campaign_name != 'No Campaign';
-- Number of users who  didn't  received impressions during campaign periods 
SELECT COUNT(DISTINCT user_id) AS no_received_impressions
FROM campaign_summary
WHERE user_id NOT IN (
  SELECT user_id
  FROM campaign_summary
  WHERE impression > 0)
AND campaign_name != 'No Campaign'
-- Number of users who received impressions but didn't click on the ad during campaign periods
SELECT COUNT(DISTINCT user_id) AS received_impressions_not_click
FROM campaign_summary
WHERE impression > 0 AND click = 0 
AND campaign_name != 'No Campaign';
-- Now we know:
-- The number of users who received impressions during campaign periods is 417.
-- The number of users who received impressions but didn't click on the ad is 127.
-- The number of users who didn't receive impressions during campaign periods is 56.
-- Using those numbers, we can calculate:
-- Overall, impression rate = 100 * 417 / (417+56) = 88.2 %
-- Overall, click rate = 100-(100 * 127 / 417) = 69.5 %
-- Does clicking on an impression lead to higher purchase rates?
-- For received impression group
SELECT  SUM(purchase)/COUNT(DISTINCT user_id) AS purchase_rate_impression
FROM campaign_summary
WHERE impression > 0
AND campaign_name != 'No Campaign'
-- For received impression but not clicked
SELECT SUM(purchase)/COUNT(DISTINCT user_id) AS purchase_rate_impressions_not_click
FROM campaign_summary
WHERE impression > 0 AND click = 0 
AND campaign_name != 'No Campaign';
-- For didn't received impression group 
SELECT SUM(purchase)/COUNT(DISTINCT user_id) AS purchase_rate_no_impression
FROM campaign_summary
WHERE campaign_name != 'No Campaign' AND
user_id NOT IN (
SELECT user_id 
FROM campaign_summary 
WHERE impression > 0 )
-- The purchase rate of customers who received impressions is 1.5228
-- The purchase rate of customers who didn't received impressions is 1.2321
-- The purchase rate of customers who received impressions but didn't click on the ad is 0.7717
-- Insights: clicking on an impression lead to higher purchase rates