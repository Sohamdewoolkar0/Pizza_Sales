CREATE DATABASE pizzahut ;
USE pizzahut;

CREATE TABLE orders(
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
PRIMARY KEY (order_id)
) ;

CREATE TABLE order_details(
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT  NOT NULL,
quantity INT NOT NULL,
PRIMARY KEY (order_details_id)
) ;

SELECT * FROM order_details ; #( order_details_id, order_id, pizza_id, quantity)  
SELECT * FROM orders ;        #( order_id, order_time, order_date)
SELECT * FROM pizza_types ;   #( pizza_type_id, name, category, ingredients)
SELECT * FROM pizzas ;        #( pizza_id, pizza_type_id, size, price)

#   Basic:

--  Retrieve the total number of orders placed.

SELECT count(order_id) 
AS Total_no_of_Orders 
FROM orders ;

--  Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM((od.quantity*p.price)), 2) AS total_sales
FROM order_details AS od
JOIN pizzas AS p
ON p.pizza_id = od.pizza_id  ;

--  Identify the highest-priced pizza.

SELECT pizza_id, max(price) AS highest_priced_pizza
FROM pizzas
GROUP BY pizza_id
ORDER BY highest_priced_pizza DESC
LIMIT 1  ;
-- or
SELECT pt.name,  p.price AS pizza_price
FROM pizza_types AS pt
join pizzas AS p
ON pt.pizza_type_id = p.pizza_type_id
ORDER BY pizza_price DESC
LIMIT 1;

--  Identify the most common pizza size ordered.

SELECT p.size, count(od.quantity) AS common_pizza_size
FROM order_details AS od
JOIN pizzas AS p
ON od.pizza_id = p.pizza_id
GROUP BY 1 
ORDER BY p.size ; 

--  List the top 5 most ordered pizza types along with their quantities.

SELECT pt.name AS Pizza_Name , SUM(od.quantity) AS Total_Quantity
FROM pizza_types AS pt
JOIN pizzas AS p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details AS od 
ON od.pizza_id = p.pizza_id 
GROUP BY pizza_name 
ORDER BY total_quantity DESC
LIMIT 5 ;

--  Determine the distribution of orders by hour of the day.
SELECT COUNT(order_id) AS total_orders,  HOUR(order_time) AS Order_time
FROM orders
GROUP BY HOUR(order_time) ;

--  Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name) AS numbers FROM pizza_types
GROUP BY 1 ; 


#   Intermediate:

--  Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT SUM(od.quantity) AS total_quantity , pt.name AS name
FROM order_details AS od
JOIN pizzas AS p
ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY name
ORDER BY  total_quantity DESC
LIMIT 5 ; 

--  Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day FROM 
(SELECT o.order_date, SUM(od.quantity) AS quantity
FROM orders AS o
JOIN order_details AS od
ON od.order_id = o.order_id
group by 1) AS order_quantity ;

--  Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name, SUM(od.quantity * p.price) AS revenue
FROM pizza_types AS pt
JOIN pizzas AS p
ON  p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od
ON od.pizza_id = p.pizza_id
GROUP BY  pt.name
ORDER BY revenue DESC
LIMIT 3 ; 


--  Advanced:

--  Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.category, ROUND((SUM(od.quantity * p.price) / (  SELECT ROUND(SUM((od.quantity*p.price)), 2) AS total_sales
FROM order_details AS od
JOIN pizzas AS p
ON p.pizza_id = od.pizza_id  ) ) * 100, 2) AS revenue
FROM order_details AS od
JOIN  pizzas AS p
ON p.pizza_id = od.pizza_id
JOIN pizza_types AS pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY  revenue  DESC ;

--  Analyze the cumulative revenue generated over time.
SELECT order_date, SUM(revenue) OVER(ORDER BY order_date) AS cumulative_revenue 
FROM 
(SELECT o.order_date, ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM order_details AS od
JOIN pizzas AS p 
ON od.pizza_id = p.pizza_id
JOIN orders as o
ON o.order_id = od.order_id
GROUP BY o.order_date ) AS sales ;

--  Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, revenue, rankk
FROM 
(SELECT category, name, revenue, RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rankk 
FROM
(SELECT pt.category , pt.name, ROUND(SUM(od.quantity * p.price), 2) AS revenue 
FROM order_details AS od
JOIN pizzas AS p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt
ON pt.pizza_type_id = p.pizza_type_id 
GROUP BY pt.category, pt.name ) AS a) AS b
WHERE rankk <= 3 ;