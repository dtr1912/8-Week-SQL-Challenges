-- What is the total amount each customer spent at the restaurant?
select customer_id, sum(price)
from sales s
join menu m 
on s.product_id = m.product_id
group by customer_id
-- How many days has each customer visited the restaurant? 
select customer_id,count(distinct(order_date)) as days_visited
from sales
group by customer_id
-- What was the first item from the menu purchased by each customer?
with cte as(
select s.customer_id, s.order_date, m.product_name,
dense_rank() over(partition by customer_id order by order_date asc) ranker
from sales s
join menu m 
on s.product_id =m.product_id )
select customer_id, order_date, product_name
from cte 
where ranker = 1
-- What is the most purchased item on the menu and how many times was it purchased by all customers?
select s.product_id, m.product_name,count(s.product_id) amount
from sales s
join menu m 
on s.product_id =m.product_id 
group by product_name
order by amount desc
-- Which item was the most popular for each customer?
with cte as(
select customer_id, s.product_id, m.product_name, count(customer_id) amount,
rank() over(partition by customer_id order by count(customer_id) desc) ranker
from sales s
join menu m 
on s.product_id =m.product_id 
group by customer_id, product_name
)
select customer_id, product_name, amount
from cte
where ranker=1
-- Which item was purchased first by the customer after they became a member?
with cte as (
select s.customer_id, order_date, m.product_name
from menu m
join sales s 
on s.product_id = m.product_id 
), cte1 as(
select c.customer_id, join_date,order_date, product_name, rank() over(partition by customer_id order by order_date asc) ranker
from cte c
join members m
on c.customer_id = m.customer_id 
where join_date <= order_date  
order by  c.customer_id)
select customer_id, product_name
from cte1 
where ranker = 1
-- Which item was purchased just before the customer became a member?
with cte as (
select s.customer_id, order_date, m.product_name
from menu m
join sales s 
on s.product_id = m.product_id )
,cte1 as (select c.customer_id, join_date,order_date, product_name, rank() over(partition by customer_id order by order_date desc ) ranker
from cte c
join members m
on c.customer_id = m.customer_id 
where join_date > order_date 
order by  c.customer_id
)
select customer_id, product_name 
from cte1
where ranker =1 
-- What is the total items and amount spent for each member before they became a member?
with cte1 as (
select s.customer_id, order_date, count(s.product_id) item, sum(m.price) total_price
from sales s
join menu m
where s.product_id=m.product_id
group by  customer_id, order_date),
cte2 as (
select s.customer_id, order_date, join_date 
from sales s
join members m 
on s.customer_id = m.customer_id 
where order_date < join_date
group by customer_id,order_date )
select cte1.customer_id, sum(item) item_amount , sum(total_price) total_amount
from cte1
join cte2
where cte1.order_date = cte2.order_date and cte1.customer_id = cte2.customer_id
group by cte1.customer_id
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte1 as 
(select s.customer_id, product_name, case 
when product_name = 'sushi' then sum(2*price)
else sum(price)
end as point
from sales s 
join menu m
on s.product_id = m.product_id
group by  customer_id, product_name
)
select customer_id, product_name, sum(point)*10 total_points
from cte1
group by customer_id
-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
with cte1
as (
select customer_id, join_date, date(join_date+6) first_week, last_day('2021-01-01') as jan
from members
)
, cte2 as (
select s.customer_id, product_id, join_date, order_date, first_week, jan
from sales s
join cte1 c1
on s.customer_id = c1.customer_id )
-- where join_date <= order_date < first_week )
, cte3 as (
select customer_id, c2.product_id, order_date, price
,case 
when c2.product_id = 1 then (20*price)
when order_date between join_date and first_week then (20*price)
else (10*price)
end as point
from cte2 c2
join menu m
on m.product_id = c2.product_id
where order_date < jan
order by customer_id 
)
select customer_id, sum(point)
from cte3
group by customer_id
order by  customer_id