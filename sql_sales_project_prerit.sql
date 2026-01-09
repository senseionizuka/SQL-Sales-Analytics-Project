-- Q1)Retrive the total numbers of orders placed 

select count(order_id) as total_orders from orders;
-- Q2) Calculate the total revenue generated from pizza sales.
-- ctrl+b to beautify
SELECT 
    ROUND(SUM((order_details.quantity * pizzas.price)),
            2) AS total_sales
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
    
-- Q3)Identify the highest-priced pizza.
select pizza_types.name, pizzas.price
from pizza_types
join pizzas  
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc
limit 1; 

-- Q4)Identify the most common pizza size ordered.

select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size order by order_count desc;
-- 	Q5) list the top 5 most ordered pizza types  along with their quantities 

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- Q6)Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category, 
    SUM(order_details.quantity) AS total_quantity
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    total_quantity DESC;
    
    -- Q7) Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- 9)Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity),0)as avg_pizza_ordered_per_day
from 
(SELECT orders.order_date, sum(order_details.quantity) as quantity
FROM orders join order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) as order_quantity;

-- 10)Determine the top 3 most ordered pizza types based on revenue.
 

SELECT name, SUM(quantity * price) AS revenue
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;	

-- Q11)Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND(
        (SUM(od.quantity * p.price) / 
        (SELECT SUM(od2.quantity * p2.price) 
         FROM order_details od2 
         JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id)) * 100, 
    2) AS revenue_percentage
FROM 
    pizza_types pt
JOIN 
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN 
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY 
    pt.category
ORDER BY 
    revenue_percentage DESC;	
    
    
    -- Q12)Analyze the cumulative revenue generated over time.
SELECT 
    category,
    name,
    revenue
FROM (
    SELECT 
        pt.category,
        pt.`name`,
        SUM(od.quantity * p.price) AS revenue,
        DENSE_RANK() OVER (
            PARTITION BY pt.category
            ORDER BY SUM(od.quantity * p.price) DESC
        ) AS rank_in_category
    FROM order_details od
    JOIN pizzas p
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt
        ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.`name`
) ranked_pizzas
WHERE rank_in_category <= 3
ORDER BY category, revenue DESC;

-- 13)Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH CategoryRevenue AS (
    SELECT 
        pt.category, 
        pt.name, 
        SUM(od.quantity * p.price) AS revenue
    FROM 
        pizza_types pt
    JOIN 
        pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN 
        order_details od ON od.pizza_id = p.pizza_id
    GROUP BY 
        pt.category, pt.name
),
RankedCategoryRevenue AS (
    SELECT 
        category, 
        name, 
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) as rn
    FROM 
        CategoryRevenue
)
SELECT 
    category, 
    name, 
    revenue
FROM 
    RankedCategoryRevenue
WHERE 
    rn <= 3
ORDER BY 
    category, revenue DESC;




