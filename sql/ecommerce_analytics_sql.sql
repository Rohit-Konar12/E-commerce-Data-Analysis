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
ALTER TABLE orders ADD COLUMN is_valid_sale TINYINT;
SET SQL_SAFE_UPDATES = 0;
UPDATE orders
SET is_valid_sale = CASE
    WHEN order_status IN ('cancelled', 'returned') THEN 0
    ELSE 1
END;
SET SQL_SAFE_UPDATES = 1;
SELECT is_valid_sale, COUNT(*) AS Order_Count, ROUND(SUM(total_amount), 2) AS Revenue
FROM orders
GROUP BY is_valid_sale;
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

-- Gross vs Net KPIs (net = excluding cancelled and returned orders)
SELECT
    COUNT(*) AS Orders_Placed,
    SUM(is_valid_sale) AS Valid_Orders,
    ROUND(SUM(total_amount), 2) AS Gross_Revenue,
    ROUND(SUM(CASE WHEN is_valid_sale = 1 THEN total_amount ELSE 0 END), 2) AS Net_Revenue,
    ROUND(AVG(CASE WHEN is_valid_sale = 1 THEN total_amount END), 2) AS Net_Avg_Order_Value
FROM orders;

-- Business Questions
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
-- Top 10 Customers by Net Spending (valid sales only)
SELECT u.user_id, u.name, ROUND(SUM(o.total_amount), 2) AS Net_Spending FROM users u JOIN orders o ON u.user_id = o.user_id WHERE o.is_valid_sale = 1 GROUP BY u.user_id, u.name ORDER BY Net_Spending DESC LIMIT 10;
-- Which products generated the highest net revenue? (valid sales only)
SELECT p.product_id, p.product_name, ROUND(SUM(oi.item_total), 2) AS Net_Product_Revenue FROM order_items oi JOIN orders o ON oi.order_id = o.order_id JOIN products p ON oi.product_id = p.product_id WHERE o.is_valid_sale = 1 GROUP BY p.product_id, p.product_name ORDER BY Net_Product_Revenue DESC LIMIT 10;
-- Which product category generated the highest net revenue? (valid sales only)
SELECT p.category, ROUND(SUM(oi.item_total), 2) AS Net_Category_Revenue FROM order_items oi JOIN orders o ON oi.order_id = o.order_id JOIN products p ON oi.product_id = p.product_id WHERE o.is_valid_sale = 1 GROUP BY p.category ORDER BY Net_Category_Revenue DESC;
-- Which cities generated the highest net revenue? (valid sales only)
SELECT u.city, ROUND(SUM(o.total_amount), 2) AS Net_City_Revenue FROM users u JOIN orders o ON u.user_id = o.user_id WHERE o.is_valid_sale = 1 GROUP BY u.city ORDER BY Net_City_Revenue DESC LIMIT 10;
-- Top 10 brands by net revenue (valid sales only)
SELECT p.brand, ROUND(SUM(oi.item_total), 2) AS Net_Brand_Revenue FROM order_items oi JOIN orders o ON oi.order_id = o.order_id JOIN products p ON oi.product_id = p.product_id WHERE o.is_valid_sale = 1 GROUP BY p.brand ORDER BY Net_Brand_Revenue DESC LIMIT 10;
-- Top 10 customers by net quantity purchased (valid sales only)
SELECT u.user_id, u.name, SUM(oi.quantity) AS Net_Quantity FROM users u JOIN orders o ON u.user_id = o.user_id JOIN order_items oi ON o.order_id = oi.order_id WHERE o.is_valid_sale = 1 GROUP BY u.user_id, u.name ORDER BY Net_Quantity DESC LIMIT 10;
-- Which products have never been ordered?
SELECT products.product_name, products.brand, products.category FROM products LEFT JOIN order_items ON products.product_id = order_items.product_id WHERE order_items.product_id IS NULL;
SELECT COUNT(*) AS Total_Products FROM products;
SELECT COUNT(DISTINCT product_id) AS Products_Sold FROM order_items;
-- Customers with more than 5 valid orders (cancelled and returned excluded)
SELECT u.user_id, u.name, COUNT(o.order_id) AS Valid_Order_Count FROM users u JOIN orders o ON u.user_id = o.user_id WHERE o.is_valid_sale = 1 GROUP BY u.user_id, u.name HAVING COUNT(o.order_id) > 5 ORDER BY Valid_Order_Count DESC;
SELECT COUNT(*) AS Customers_With_More_Than_5_Orders FROM (SELECT u.user_id FROM users u JOIN orders o ON u.user_id = o.user_id GROUP BY u.user_id HAVING COUNT(o.order_id) > 5) AS customer_orders;
-- Top 10 cities by net average order value (valid sales only)
SELECT u.city, ROUND(AVG(o.total_amount), 2) AS Net_AVG_Order_Value, COUNT(*) AS Valid_Orders FROM users u JOIN orders o ON u.user_id = o.user_id WHERE o.is_valid_sale = 1 GROUP BY u.city ORDER BY Net_AVG_Order_Value DESC LIMIT 10;
-- Which brands sold the highest net quantity? (valid sales only)
SELECT p.brand, SUM(oi.quantity) AS Net_Quantity_Sold FROM order_items oi JOIN orders o ON oi.order_id = o.order_id JOIN products p ON oi.product_id = p.product_id WHERE o.is_valid_sale = 1 GROUP BY p.brand ORDER BY Net_Quantity_Sold DESC LIMIT 10;
-- Categorize customers by net spending (valid sales only; customers with no valid sale are Low Value)
SELECT u.user_id, u.name, ROUND(SUM(CASE WHEN o.is_valid_sale = 1 THEN o.total_amount ELSE 0 END), 2) AS Net_Spending, CASE WHEN SUM(CASE WHEN o.is_valid_sale = 1 THEN o.total_amount ELSE 0 END) > 5000 THEN 'High Value' WHEN SUM(CASE WHEN o.is_valid_sale = 1 THEN o.total_amount ELSE 0 END) >= 2000 THEN 'Medium Value' ELSE 'Low Value' END AS Customer_Segment FROM users u JOIN orders o ON u.user_id = o.user_id GROUP BY u.user_id, u.name ORDER BY Net_Spending DESC;
-- Which months generate the highest net revenue (valid sales, complete months only).
SELECT YEAR(order_date) AS Year, MONTHNAME(order_date) AS Month, ROUND(SUM(total_amount), 2) AS Net_Revenue FROM orders WHERE is_valid_sale = 1 AND order_date < '2025-11-01' GROUP BY YEAR(order_date), MONTH(order_date), MONTHNAME(order_date) ORDER BY Net_Revenue DESC;
-- Top net-spending customer in each city (valid sales only)
WITH Customer_Spending AS ( SELECT u.city, u.user_id, u.name, ROUND(SUM(o.total_amount), 2) AS Net_Spending, ROW_NUMBER() OVER (PARTITION BY u.city ORDER BY SUM(o.total_amount) DESC) AS rn FROM users u JOIN orders o ON u.user_id = o.user_id WHERE o.is_valid_sale = 1 GROUP BY u.city, u.user_id, u.name )
SELECT city, user_id, name, Net_Spending FROM Customer_Spending WHERE rn = 1 ORDER BY Net_Spending DESC;
-- Rank all customers by net spending (valid sales only)
SELECT u.user_id, u.name, ROUND(SUM(o.total_amount), 2) AS Net_Spending, RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS Customer_Rank FROM users u JOIN orders o ON u.user_id = o.user_id WHERE o.is_valid_sale = 1 GROUP BY u.user_id, u.name ORDER BY Customer_Rank;
-- Which customers have never placed an order?
SELECT u.name, u.city, u.signup_date FROM users u LEFT JOIN orders o ON u.user_id = o.user_id WHERE o.order_id IS NULL;
-- Which categories contribute the highest percentage of total net revenue? (valid sales only)
SELECT p.category, ROUND(SUM(oi.item_total), 2) AS Net_Category_Revenue, ROUND(SUM(oi.item_total) * 100 / SUM(SUM(oi.item_total)) OVER (), 2) AS Revenue_Percentage FROM order_items oi JOIN orders o ON oi.order_id = o.order_id JOIN products p ON oi.product_id = p.product_id WHERE o.is_valid_sale = 1 GROUP BY p.category ORDER BY Net_Category_Revenue DESC;
-- Top 3 net-spending customers in each city (valid sales only)
WITH CustomerSpending AS ( SELECT u.city, u.user_id, u.name, ROUND(SUM(o.total_amount), 2) AS Net_Spending, ROW_NUMBER() OVER (PARTITION BY u.city ORDER BY SUM(o.total_amount) DESC) AS rn FROM users u JOIN orders o ON u.user_id = o.user_id WHERE o.is_valid_sale = 1 GROUP BY u.city, u.user_id, u.name ) 
SELECT city, user_id, name, Net_Spending, rn AS City_Rank FROM CustomerSpending WHERE rn <= 3 ORDER BY city, rn;
-- Highest net revenue product in each category (valid sales only)
WITH ProductRevenue AS (
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        ROUND(SUM(oi.item_total), 2) AS Net_Revenue,
        ROW_NUMBER() OVER (
            PARTITION BY p.category
            ORDER BY SUM(oi.item_total) DESC
        ) AS rn
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.is_valid_sale = 1
    GROUP BY p.category, p.product_id, p.product_name
)
SELECT category, product_id, product_name, Net_Revenue
FROM ProductRevenue
WHERE rn = 1
ORDER BY category;
-- Customers who spent more than the average customer (net spending, customers with at least one valid sale)
WITH CustomerSpending AS (
    SELECT
        u.user_id,
        u.name,
        ROUND(SUM(o.total_amount), 2) AS Net_Spending
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    WHERE o.is_valid_sale = 1
    GROUP BY u.user_id, u.name
)
SELECT user_id, name, Net_Spending
FROM CustomerSpending
WHERE Net_Spending > (SELECT AVG(Net_Spending) FROM CustomerSpending)
ORDER BY Net_Spending DESC;
-- Show the cumulative (running) net revenue over time (valid sales, complete months only).
WITH MonthlyRevenue AS (
    SELECT
        YEAR(order_date) AS Year,
        MONTH(order_date) AS Month,
        MONTHNAME(order_date) AS Month_Name,
        SUM(total_amount) AS Monthly_Revenue
    FROM orders
    WHERE is_valid_sale = 1
      AND order_date < '2025-11-01'
    GROUP BY YEAR(order_date), MONTH(order_date), MONTHNAME(order_date)
)
SELECT
    Year,
    Month_Name,
    ROUND(Monthly_Revenue, 2) AS Monthly_Revenue,
    ROUND(SUM(Monthly_Revenue) OVER (ORDER BY Year, Month), 2) AS Running_Revenue
FROM MonthlyRevenue
ORDER BY Year, Month;
-- Net spending vs the customer's previous valid order (cancelled and returned excluded)
SELECT
    u.user_id,
    u.name,
    o.order_id,
    o.order_date,
    o.total_amount,
    LAG(o.total_amount) OVER (
        PARTITION BY u.user_id
        ORDER BY o.order_date, o.order_id
    ) AS Previous_Order_Amount,
    CASE
        WHEN LAG(o.total_amount) OVER (
                 PARTITION BY u.user_id
                 ORDER BY o.order_date, o.order_id
             ) IS NULL THEN 'First order'
        WHEN o.total_amount > LAG(o.total_amount) OVER (
                 PARTITION BY u.user_id
                 ORDER BY o.order_date, o.order_id
             ) THEN 'Yes'
        ELSE 'No'
    END AS Increased
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.is_valid_sale = 1
ORDER BY u.user_id, o.order_date, o.order_id;
-- Calculate the Month-over-Month (MoM) Net Revenue Growth (valid sales, complete months only).
WITH MonthlyRevenue AS (
    SELECT
        YEAR(order_date) AS Year,
        MONTH(order_date) AS Month,
        MONTHNAME(order_date) AS Month_Name,
        SUM(total_amount) AS Monthly_Revenue
    FROM orders
    WHERE is_valid_sale = 1
      AND order_date < '2025-11-01'
    GROUP BY YEAR(order_date), MONTH(order_date), MONTHNAME(order_date)
)
SELECT
    Year,
    Month_Name,
    ROUND(Monthly_Revenue, 2) AS Monthly_Revenue,
    ROUND(LAG(Monthly_Revenue) OVER (ORDER BY Year, Month), 2) AS Previous_Month_Revenue,
    ROUND(Monthly_Revenue - LAG(Monthly_Revenue) OVER (ORDER BY Year, Month), 2) AS Revenue_Growth,
    ROUND((Monthly_Revenue - LAG(Monthly_Revenue) OVER (ORDER BY Year, Month))
          / LAG(Monthly_Revenue) OVER (ORDER BY Year, Month) * 100, 2) AS Growth_Percentage
FROM MonthlyRevenue
ORDER BY Year, Month;
-- Top 5 products by net revenue in each category (valid sales only)
WITH ProductRevenue AS (
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        ROUND(SUM(oi.item_total), 2) AS Net_Revenue,
        RANK() OVER (
            PARTITION BY p.category
            ORDER BY SUM(oi.item_total) DESC
        ) AS product_rank
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.is_valid_sale = 1
    GROUP BY p.category, p.product_id, p.product_name
)
SELECT category, product_id, product_name, Net_Revenue, product_rank
FROM ProductRevenue
WHERE product_rank <= 5
ORDER BY category, product_rank;
-- Customer Lifetime Value based on net spending (valid sales only)
SELECT
    u.user_id,
    u.name,
    COUNT(o.order_id) AS Valid_Orders,
    ROUND(SUM(o.total_amount), 2) AS Customer_Lifetime_Value,
    ROUND(AVG(o.total_amount), 2) AS Average_Order_Value
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.is_valid_sale = 1
GROUP BY u.user_id, u.name
ORDER BY Customer_Lifetime_Value DESC;
-- Best product by net revenue in each complete month (valid sales only)
WITH MonthlyProductRevenue AS (
    SELECT
        YEAR(o.order_date) AS Year,
        MONTH(o.order_date) AS Month,
        MONTHNAME(o.order_date) AS Month_Name,
        p.product_id,
        p.product_name,
        ROUND(SUM(oi.item_total), 2) AS Net_Revenue,
        ROW_NUMBER() OVER (
            PARTITION BY YEAR(o.order_date), MONTH(o.order_date)
            ORDER BY SUM(oi.item_total) DESC
        ) AS rn
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.is_valid_sale = 1
      AND o.order_date < '2025-11-01'
    GROUP BY YEAR(o.order_date), MONTH(o.order_date), MONTHNAME(o.order_date),
             p.product_id, p.product_name
)
SELECT Year, Month_Name, product_id, product_name, Net_Revenue
FROM MonthlyProductRevenue
WHERE rn = 1
ORDER BY Year, Month;
-- What percentage of the total net revenue does each brand contribute? (valid sales only)
SELECT
    p.brand,
    ROUND(SUM(oi.item_total), 2) AS Net_Brand_Revenue,
    ROUND(SUM(oi.item_total) * 100 / SUM(SUM(oi.item_total)) OVER (), 2) AS Revenue_Percentage
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.is_valid_sale = 1
GROUP BY p.brand
ORDER BY Net_Brand_Revenue DESC;
-- Classify customers as One-time or Repeat buyers (valid orders only)
SELECT
    u.user_id,
    u.name,
    COUNT(o.order_id) AS Valid_Orders,
    CASE
        WHEN COUNT(o.order_id) = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS Customer_Type
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.is_valid_sale = 1
GROUP BY u.user_id, u.name
ORDER BY Valid_Orders DESC, u.user_id;

SELECT Customer_Type, COUNT(*) AS Customers
FROM (
    SELECT u.user_id,
           CASE WHEN COUNT(o.order_id) = 1 THEN 'One-time Customer' ELSE 'Repeat Customer' END AS Customer_Type
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    WHERE o.is_valid_sale = 1
    GROUP BY u.user_id
) t
GROUP BY Customer_Type;
-- Our analysts keep writing the same customer spending query every day. Create a reusable SQL View so everyone can query it easily.
CREATE OR REPLACE VIEW Customer_Summary AS
SELECT
    u.user_id,
    u.name,
    COUNT(o.order_id) AS Total_Orders,
    SUM(o.total_amount) AS Total_Spending,
    ROUND(AVG(o.total_amount), 2) AS Average_Order_Value,
    SUM(o.is_valid_sale) AS Valid_Orders,
    ROUND(SUM(CASE WHEN o.is_valid_sale = 1 THEN o.total_amount ELSE 0 END), 2) AS Net_Spending
FROM users u
JOIN orders o
    ON u.user_id = o.user_id
GROUP BY
    u.user_id,
    u.name;
    
SELECT COUNT(*) AS Customers,
       ROUND(SUM(Total_Spending), 2) AS Gross,
       ROUND(SUM(Net_Spending), 2) AS Net
FROM Customer_Summary;

-- Use of the view Customer_Summery.
SELECT *
FROM Customer_Summary;
-- Top 10 customers by net spending (from the view)
SELECT user_id, name, Valid_Orders, Net_Spending
FROM Customer_Summary
ORDER BY Net_Spending DESC
LIMIT 10;
-- Customers with net spending above 5000 (from the view)
SELECT user_id, name, Valid_Orders, Net_Spending
FROM Customer_Summary
WHERE Net_Spending > 5000
ORDER BY Net_Spending DESC;
-- Top 3 net-spending customers per city with orders, spending, AOV and rank (valid sales only)
WITH CustomerSummary AS (
    SELECT
        u.city,
        u.user_id,
        u.name,
        COUNT(o.order_id) AS Valid_Orders,
        ROUND(SUM(o.total_amount), 2) AS Net_Spending,
        ROUND(AVG(o.total_amount), 2) AS Net_Average_Order_Value,
        ROW_NUMBER() OVER (
            PARTITION BY u.city
            ORDER BY SUM(o.total_amount) DESC
        ) AS rn
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    WHERE o.is_valid_sale = 1
    GROUP BY u.city, u.user_id, u.name
)
SELECT city, user_id, name, Valid_Orders, Net_Spending, Net_Average_Order_Value, rn AS Customer_Rank
FROM CustomerSummary
WHERE rn <= 3
ORDER BY city, Customer_Rank;