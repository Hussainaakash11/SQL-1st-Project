CREATE DATABASE Project;
USE Project;

CReATE TABLE ORDERS(
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id));

select * from orders;

CReATE TABLE ORDERS_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id));

alter table orders_details
rename to order_details;

select * from order_details;

-- Q1 Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- Q2 Calculate the total revenue generated from pizza sales.
SELECT 
    SUM(order_details.quantity * pizzas.price) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
    -- Q3 Identify the highest-priced pizza.
SELECT 
    pizzat.name, pizzas.price
FROM
    pizzat
        JOIN
    pizzas ON pizzat.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1; 

-- Q4 Identify the most common pizza size ordered.

SELECT 
    pizzas.size, COUNT(order_details.order_details_id) as order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- Q5 List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizzat.name, SUM(order_details.quantity) as quantity
FROM
    pizzat
        JOIN
    pizzas ON pizzat.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzat.name
ORDER BY quantity DESC
LIMIT 5;

-- Q6 List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizzat.category, SUM(order_details.quantity) AS quantity
FROM
    pizzat
        JOIN
    pizzas ON pizzat.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzat.category
ORDER BY quantity DESC;

-- Q7 Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);

-- Q8 Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizzat
GROUP BY category;

-- Q9 Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(quantity)
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
    -- Q10 Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizzat.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizzat
        JOIN
    pizzas ON pizzas.pizza_type_id = pizzat.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzat.name
ORDER BY revenue desc limit 3;

-- Q11 Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizzat.category,
    (SUM(order_details.quantity * pizzas.price) / (SELECT 
            SUM(order_details.quantity * pizzas.price) AS total_sales
        FROM
            order_details
                JOIN
            pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100 AS revenue
FROM
    pizzat
        JOIN
    pizzas ON pizzas.pizza_type_id = pizzat.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzat.category
ORDER BY revenue;

-- Q12 Analyze the cumulative revenue generated over time.
select order_date ,
sum(revenue) over (order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id 
group by order_date) as sales ;

-- Q13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name , revenue 
from 
(select category , name , revenue , rank()
over (partition by category order by revenue desc ) as rn
from
(SELECT 
    pizzat.category,
    pizzat.name,
    SUM((order_details.quantity) * pizzas.price) AS revenue
FROM
    pizzat
        JOIN
    pizzas ON pizzat.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzat.category , pizzat.name) as a) as b
where rn<=3;