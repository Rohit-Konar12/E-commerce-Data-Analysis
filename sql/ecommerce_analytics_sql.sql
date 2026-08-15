create DATABASE ecommerce_analytics;
use ecommerce_analytics;
create TABLE users(
user_id VARCHAR(10) PRIMARY KEY,
name VARCHAR(100),
email VARCHAR(100) UNIQUE,
gender VARCHAR(10),
city VARCHAR(100),
signup_date DATE
);
describe users;
create TABLE products(
product_id VARCHAR(10) PRIMARY KEY,
product_name VARCHAR(255),
category VARCHAR (100),
brand VARCHAR (100),
price DECIMAL (10,2),
rating DECIMAL (3,2)
);
describe products;
create TABLE orders(
order_id VARCHAR(15) PRIMARY KEY,
user_id VARCHAR(10),
order_date DATE,
order_status VARCHAR(50),
total_amount DECIMAL (10,2),

constraint fk_orders_users
foreign key(user_id)
references users(user_id)
);
describe orders;
SHOW CREATE TABLE orders;
CREATE TABLE order_items (
    order_item_id VARCHAR(10) PRIMARY KEY,
    order_id VARCHAR(15),
    product_id VARCHAR(10),
    user_id VARCHAR(10),
    quantity INT,
    item_price DECIMAL(10,2),
    item_total DECIMAL(10,2),

    CONSTRAINT fk_order_items_orders
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_order_items_products
        FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    CONSTRAINT fk_order_items_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);
describe order_items;
show create table order_items;
-- How many users, products, orders, order items does the business have?
SELECT COUNT(*) AS Total_users FROM users;
SELECT COUNT(*) AS Total_products FROM products;
SELECT COUNT(*) AS Total_orders FROM orders;
SELECT COUNT(*) AS Total_order_items FROM order_items;
-- Total revenue?
SELECT SUM(total_amount) AS Total_revenue FROM orders;
-- What is the avarage order value? 
SELECT ROUND(AVG(total_amount), 2) AS Avarage_total_amount FROM orders;
-- How many orders are there in each order status?
SELECT order_status, COUNT(*) AS Order_Count FROM orders GROUP BY order_status ORDER BY Order_Count DESC;
-- Which are the Top 10 Customers by Total Spending?
SELECT users.name, SUM(orders.total_amount) AS Total_Spending FROM users JOIN orders ON users.user_id = orders.user_id GROUP BY users.name ORDER BY Total_Spending DESC LIMIT 10;
-- Which product generated the highest revenue?
SELECT products.product_name, SUM(order_items.item_total) AS Product_Revenue FROM products JOIN order_items ON products.product_id = order_items.product_id GROUP BY products.product_id, products.product_name ORDER BY Product_Revenue DESC LIMIT 10;
-- Which product category generated the highest revenue?
SELECT products.category, SUM(order_items.item_total) AS Category_Revenue FROM products JOIN order_items ON products.product_id = order_items.product_id GROUP BY products.category ORDER BY Category_Revenue DESC;
-- Which city generated the highest revenue?
SELECT users.city, SUM(orders.total_amount) AS City_Revenue FROM users JOIN orders ON users.user_id = orders.user_id GROUP BY users.city ORDER BY City_Revenue DESC LIMIT 10;
-- Top 10 brands by revenue.
SELECT products.brand, SUM(order_items.item_total) AS Brand_Revenue FROM products JOIN order_items ON products.product_id = order_items.product_id GROUP BY products.brand ORDER BY Brand_Revenue DESC LIMIT 10;
-- Top 10 customers who purchased the highest quantity of products.
SELECT users.name, SUM(order_items.quantity) AS Quantity FROM users JOIN orders ON users.user_id = orders.user_id JOIN order_items ON orders.order_id = order_items.order_id GROUP BY users.user_id, users.name ORDER BY Quantity DESC LIMIT 10;
-- Which products have never been ordered?
SELECT products.product_name, products.brand, products.category FROM products LEFT JOIN order_items ON products.product_id = order_items.product_id WHERE order_items.product_id IS NULL;
SELECT COUNT(*) AS Total_Products FROM products;
SELECT COUNT(DISTINCT product_id) AS Products_Sold FROM order_items;
-- Customers who have placed more than 5 orders.
SELECT users.name, COUNT(orders.order_id) AS Order_Count FROM users JOIN orders ON users.user_id = orders.user_id GROUP BY users.user_id, users.name HAVING COUNT(orders.order_id) > 5 ORDER BY Order_Count DESC;
SELECT COUNT(*) AS Customers_With_More_Than_5_Orders FROM (SELECT u.user_id FROM users u JOIN orders o ON u.user_id = o.user_id GROUP BY u.user_id HAVING COUNT(o.order_id) > 5) AS customer_orders;
-- Top 10 cities by avarage order value.
SELECT users.city, ROUND(AVG(orders.total_amount), 2) AS AVG_City FROM users JOIN orders ON users.user_id = orders.user_id GROUP BY users.city ORDER BY AVG_City DESC LIMIT 10;
-- Which brands have sold the highest quantity of products?
SELECT products.brand, SUM(order_items.quantity) AS Quantity_Sold FROM products JOIN order_items ON products.product_id = order_items.product_id GROUP BY products.brand ORDER BY Quantity_Sold DESC LIMIT 10;
-- Categorize customers based on their total spending.
SELECT users.name, ROUND(SUM(orders.total_amount), 2) AS Total_Spending, CASE WHEN SUM(orders.total_amount) > 5000 THEN 'High Value' WHEN SUM(orders.total_amount) BETWEEN 2000 AND 5000 THEN 'Medium Value' ELSE 'Low Value' END AS Customer_Segment FROM users JOIN orders ON users.user_id = orders.user_id GROUP BY users.user_id, users.name ORDER BY Total_Spending DESC;
-- Which months generate the highest revenue.
SELECT YEAR(order_date) AS Year, MONTHNAME(order_date) AS Month, ROUND(SUM(total_amount), 2) AS Revenue FROM orders GROUP BY YEAR(order_date), MONTH(order_date), MONTHNAME(order_date) ORDER BY Revenue DESC;
-- Which customers have spent the most money in each city?
WITH Customer_Spending AS ( SELECT u.city, u.name, SUM(o.total_amount) AS Total_Spending, ROW_NUMBER() OVER ( PARTITION BY u.city ORDER BY SUM(o.total_amount) DESC ) AS rn FROM users u JOIN orders o ON u.user_id = o.user_id GROUP BY u.city, u.user_id, u.name)
SELECT city, name, Total_Spending FROM Customer_Spending WHERE rn = 1;
-- Rank all customers based on their total spending.
SELECT u.name, SUM(o.total_amount) AS Total_Spending, RANK() OVER ( ORDER BY SUM(o.total_amount) DESC ) AS Customer_Rank FROM users u JOIN orders o ON u.user_id = o.user_id GROUP BY u.user_id, u.name;
-- Which customers have never placed an order?
SELECT u.name, u.city, u.signup_date FROM users u LEFT JOIN orders o ON u.user_id = o.user_id WHERE o.order_id IS NULL;
-- Which categories contribute the highest percentage of total revenue?
SELECT p.category, ROUND(SUM(oi.item_total), 2) AS Category_Revenue, ROUND( SUM(oi.item_total) * 100 / ( SELECT SUM(item_total) FROM order_items ), 2 ) AS Revenue_Percentage FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.category ORDER BY Category_Revenue DESC;
-- Show the top 3 highest-spending customers in each city.
WITH CustomerSpending AS ( SELECT u.city, u.name, SUM(o.total_amount) AS Total_Spending, ROW_NUMBER() OVER ( PARTITION BY u.city ORDER BY SUM(o.total_amount) DESC ) AS rn FROM users u JOIN orders o ON u.user_id = o.user_id GROUP BY u.city, u.user_id, u.name )
SELECT city, name, Total_Spending FROM CustomerSpending WHERE rn <= 3 ORDER BY city, rn;
-- Find the highest revenue-generating product in each category.
WITH ProductRevenue AS (
    SELECT
        p.category,
        p.product_name,
        SUM(oi.item_total) AS Total_Revenue,
        ROW_NUMBER() OVER (
            PARTITION BY p.category
            ORDER BY SUM(oi.item_total) DESC
        ) AS rn
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.category,
        p.product_id,
        p.product_name
)

SELECT
    category,
    product_name,
    Total_Revenue
FROM ProductRevenue
WHERE rn = 1
ORDER BY category;
-- Which customers have spent more than the average customer spending?
WITH CustomerSpending AS (
    SELECT
        u.user_id,
        u.name,
        SUM(o.total_amount) AS Total_Spending
    FROM users u
    JOIN orders o
        ON u.user_id = o.user_id
    GROUP BY
        u.user_id,
        u.name
)

SELECT
    name,
    Total_Spending
FROM CustomerSpending
WHERE Total_Spending >
(
    SELECT AVG(Total_Spending)
    FROM CustomerSpending
)
ORDER BY Total_Spending DESC;
-- Show the cumulative (running) revenue over time.
WITH MonthlyRevenue AS (
    SELECT
        YEAR(order_date) AS Year,
        MONTH(order_date) AS Month,
        MONTHNAME(order_date) AS Month_Name,
        SUM(total_amount) AS Monthly_Revenue
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date),
        MONTHNAME(order_date)
)

SELECT
    Year,
    Month_Name,
    Monthly_Revenue,
    SUM(Monthly_Revenue) OVER (
        ORDER BY Year, Month
    ) AS Running_Revenue
FROM MonthlyRevenue
ORDER BY
    Year,
    Month;
-- Which customers increased their spending compared to their previous order?
SELECT
    u.name,
    o.order_date,
    o.total_amount,
    LAG(o.total_amount) OVER (
        PARTITION BY u.user_id
        ORDER BY o.order_date
    ) AS Previous_Order_Amount,
    CASE
        WHEN o.total_amount >
             LAG(o.total_amount) OVER (
                 PARTITION BY u.user_id
                 ORDER BY o.order_date
             )
        THEN 'Yes'
        ELSE 'No'
    END AS Increased
FROM users u
JOIN orders o
    ON u.user_id = o.user_id
ORDER BY
    u.name,
    o.order_date;
-- Calculate the Month-over-Month (MoM) Revenue Growth.
WITH MonthlyRevenue AS (
    SELECT
        YEAR(order_date) AS Year,
        MONTH(order_date) AS Month,
        MONTHNAME(order_date) AS Month_Name,
        SUM(total_amount) AS Monthly_Revenue
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date),
        MONTHNAME(order_date)
)

SELECT
    Year,
    Month_Name,
    Monthly_Revenue,
    LAG(Monthly_Revenue) OVER (
        ORDER BY Year, Month
    ) AS Previous_Month_Revenue,
    
    Monthly_Revenue -
    LAG(Monthly_Revenue) OVER (
        ORDER BY Year, Month
    ) AS Revenue_Growth,

    ROUND(
        (
            (Monthly_Revenue -
            LAG(Monthly_Revenue) OVER (
                ORDER BY Year, Month
            ))
            /
            LAG(Monthly_Revenue) OVER (
                ORDER BY Year, Month
            )
        ) * 100,
        2
    ) AS Growth_Percentage

FROM MonthlyRevenue
ORDER BY
    Year,
    Month;
-- Show the Top 5 highest-selling products in each category.
WITH ProductRevenue AS (
    SELECT
        p.category,
        p.product_name,
        SUM(oi.item_total) AS Total_Revenue,
        RANK() OVER (
            PARTITION BY p.category
            ORDER BY SUM(oi.item_total) DESC
        ) AS product_rank
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.category,
        p.product_id,
        p.product_name
)

SELECT
    category,
    product_name,
    Total_Revenue,
    product_rank
FROM ProductRevenue
WHERE product_rank <= 5
ORDER BY
    category,
    product_rank,
    Total_Revenue DESC;
-- Calculate the Customer Lifetime Value (CLV) for every customer.
SELECT
    u.name,
    COUNT(o.order_id) AS Total_Orders,
    SUM(o.total_amount) AS Customer_Lifetime_Value,
    ROUND(AVG(o.total_amount), 2) AS Average_Order_Value
FROM users u
JOIN orders o
    ON u.user_id = o.user_id
GROUP BY
    u.user_id,
    u.name
ORDER BY
    Customer_Lifetime_Value DESC;
-- Find the best-selling product in each month based on revenue.
WITH MonthlyProductRevenue AS (
    SELECT
        YEAR(o.order_date) AS Year,
        MONTH(o.order_date) AS Month,
        MONTHNAME(o.order_date) AS Month_Name,
        p.product_name,
        SUM(oi.item_total) AS Total_Revenue,
        ROW_NUMBER() OVER (
            PARTITION BY YEAR(o.order_date), MONTH(o.order_date)
            ORDER BY SUM(oi.item_total) DESC
        ) AS rn
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date),
        MONTHNAME(o.order_date),
        p.product_id,
        p.product_name
)

SELECT
    Year,
    Month_Name,
    product_name,
    Total_Revenue
FROM MonthlyProductRevenue
WHERE rn = 1
ORDER BY
    Year,
    Month;
-- What percentage of the total revenue does each brand contribute?
WITH BrandRevenue AS (
    SELECT
        p.brand,
        SUM(oi.item_total) AS Brand_Revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.brand
)

SELECT
    brand,
    Brand_Revenue,
    ROUND(
        (Brand_Revenue /
        (SELECT SUM(Brand_Revenue) FROM BrandRevenue)) * 100,
        2
    ) AS Revenue_Percentage
FROM BrandRevenue
ORDER BY
    Revenue_Percentage DESC;
-- Classify customers as New or Repeat customers.
SELECT
    u.name,
    COUNT(o.order_id) AS Total_Orders,
    CASE
        WHEN COUNT(o.order_id) = 1 THEN 'New Customer'
        ELSE 'Repeat Customer'
    END AS Customer_Type
FROM users u
JOIN orders o
    ON u.user_id = o.user_id
GROUP BY
    u.user_id,
    u.name
ORDER BY
    Total_Orders DESC;
-- Our analysts keep writing the same customer spending query every day. Create a reusable SQL View so everyone can query it easily.
CREATE VIEW Customer_Summary AS
SELECT
    u.user_id,
    u.name,
    COUNT(o.order_id) AS Total_Orders,
    SUM(o.total_amount) AS Total_Spending,
    ROUND(AVG(o.total_amount), 2) AS Average_Order_Value
FROM users u
JOIN orders o
    ON u.user_id = o.user_id
GROUP BY
    u.user_id,
    u.name;
-- Use of the view Customer_Summery.
SELECT *
FROM Customer_Summary;
-- Top 10 Customer
SELECT *
FROM Customer_Summary
ORDER BY Total_Spending DESC
LIMIT 10;
-- Customer spending above 5000.
SELECT *
FROM Customer_Summary
WHERE Total_Spending > 5000;
-- For each city, show the top 3 customers based on their total spending. Also display their total orders, total spending, average order value, and their rank within the city.
WITH CustomerSummary AS (
    SELECT
        u.city,
        u.user_id,
        u.name,
        COUNT(o.order_id) AS Total_Orders,
        SUM(o.total_amount) AS Total_Spending,
        ROUND(AVG(o.total_amount), 2) AS Average_Order_Value,
        ROW_NUMBER() OVER (
            PARTITION BY u.city
            ORDER BY SUM(o.total_amount) DESC
        ) AS rn
    FROM users u
    JOIN orders o
        ON u.user_id = o.user_id
    GROUP BY
        u.city,
        u.user_id,
        u.name
)

SELECT
    city,
    name,
    Total_Orders,
    Total_Spending,
    Average_Order_Value,
    rn AS Customer_Rank
FROM CustomerSummary
WHERE rn <= 3
ORDER BY
    city,
    Customer_Rank;
