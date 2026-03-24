CREATE DATABASE mp;
USE mp;


SELECT* FROM order_details;
SELECT* FROM orders;
SELECT* FROM pizza_types;
SELECT* FROM pizzas;

-- Task 1: Retrive the total number of orders placed.

SELECT count(distinct order_id) from orders;
SELECT count(distinct order_id) from order_details;


-- Task 2: Calculate the total revenue generated from pizza sales.
-- revenue = price * quantity 

SELECT round(sum(price*quantity), 2) as revenue
FROM pizzas as p
inner join order_details as od on od.pizza_id = p.pizza_id;

-- Task 3: Identify the top 5 highest-priced pizza.

SELECT p.pizza_id, pt.name, p.price
FROM pizzas as p
left join pizza_types as pt 
on p.pizza_type_id = pt.pizza_type_id
order by p.price desc
limit 5;

-- Task 4: Identify the most common pizza ordered
   SELECT * from pizzas;
   SELECT * from order_details;
   
   SELECT p.size, count(distinct order_id) as orders, sum(od.quantity) as quantity
   from pizzas as p
   inner join order_details as od 
   on od.pizza_id = p.pizza_id
   group by p.size;
   
-- SALES
-- Task 1: List the top 5 most ordered pizza types along with their quantities.
   
   SELECT pt.name as pizza_name, sum(od.quantity) as quantity
   from pizza_types as pt
   left join pizzas as p on pt.pizza_type_id = p.pizza_type_id
   left join order_details as od on od.pizza_id = p.pizza_id
   group by pt.name
   order by quantity desc
   limit 5;
   
   -- Task 2: At which hour do we get how many orders, and what percentage of total orders does each hour contribute
  
   SELECT *
   , sum(hour_orders) over () as total_orders
   , hour_orders * 1.0 / sum(hour_orders) over () as order_percentage
   from (
   SELECT hour(time) as hours, count(distinct order_id) as hour_orders
   from orders
   group by hour(time)
   ) as a;
   
   
   -- Task 3: Determine the top 3 most ordered pizza types based on revenue.
   -- REVENUE = PRICE * QUANTITY
   
   
   SELECT* from order_details;
   SELECT* from pizza_types;
   SELECT* from pizzas;
   
   SELECT pt.name as pizza_name, sum(od.quantity * p.price) as revenue
   from pizza_types as pt
   left join pizzas as p on pt.pizza_type_id = p.pizza_type_id
   left join order_details as od on od.pizza_id = p.pizza_id
   group by pt.name
   order by revenue desc
   limit 3;
   
   
   -- OPERATIONAL INSIGHTS
   
   -- Task 1: How much revenue each pizza generates and what percentage it contributes to total sales
   -- REV = PRICE * QUANTITY
   -- pizza_types, pizzas, order_details table should be used
   
   with pizza_type_rev as (
   select pt.name as pizza_name, round(sum(od.quantity * p.price),0) as rev
   from pizza_types as pt
   inner join pizzas as p on pt.pizza_type_id = p.pizza_type_id
   inner join order_details as od on od.pizza_id = p.pizza_id
   group by pt.name
   )
   select *
, sum(rev) over () as total_rev 
, round(rev *100/ sum(rev) over (), 2) as rev_distribution
from pizza_type_rev;
   

-- Task 2: Analyze the cumulative revenue(Running total) generated over time (date)

with final as (
select o.date, round(sum(od.quantity * p.price), 2) as rev
from orders as o
left join order_details as od on od.order_id = o.order_id
inner join pizzas as p on p.pizza_id = od.pizza_id
group by o.date
)

select *
, round(sum(rev) over (order by date rows between unbounded preceding and current row), 0) as running_total
from final;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


-- pizzas, order_details, pizza_types
select * from (
select *
, dense_rank() over (partition by category order by rev) as rn
from (
select pt.category, pt.name, sum(quantity * price) as rev
from pizza_types as pt
inner join pizzas as p on p.pizza_type_id = pt.pizza_type_id
inner join order_details as od on od.pizza_id = p.pizza_id
group by pt.category, pt.name
) as a
) as b
where rn <= 3;


-- Category wise analyse
-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pt.category, sum(quantity) as qnty
from pizza_types as pt
left join pizzas as p on pt.pizza_type_id = p.pizza_type_id
left join order_details as od on od.pizza_id = p.pizza_id
group by pt.category;


-- Task 2 : Join relevant tables to find the category-wise distribution of pizzas.
with final as (
select pt.category, sum(quantity) as qnty
from pizza_types as pt
left join pizzas as p on pt.pizza_type_id = p.pizza_type_id
left join order_details as od on od.pizza_id = p.pizza_id
group by pt.category
)

select *
, qnty/ sum(qnty) over () as distribution
from final;


-- Task 3: Group the orders by the date and calculate the average number of pizzas ordered per day.


select avg(day_quantity)
from (
select date, sum(quantity) as day_quantity
from orders as o
inner join order_details as od on o.order_id = od.order_id
group by date
) as a;
