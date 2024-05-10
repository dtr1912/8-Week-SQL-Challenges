-- What was the total quantity sold for all products?
SELECT SUM(qty) AS total_quantity
FROM sales
-- What is the total generated revenue for all products before discounts?
SELECT SUM(qty*price) AS revenue
FROM sales
-- What was the total discount amount for all products?
SELECT SUM(qty*price*discount/100) AS revenue
FROM sales