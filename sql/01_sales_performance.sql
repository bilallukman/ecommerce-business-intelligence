-- PROJECT 4: E-COMMERCE BUSINESS INTELLIGENCE
-- SECTION 1: SALES PERFORMANCE ANALYSIS

USE ecommerce_analytics;

-- 1. Total orders
SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;

-- 2. Total customers
SELECT
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers;

-- 3. Total product sales revenue
SELECT
    ROUND(SUM(price), 2) AS total_sales_revenue
FROM order_items;

-- 4. Total freight revenue
SELECT
    ROUND(SUM(freight_value), 2) AS total_freight_value
FROM order_items;

-- 5. Average order value (product sales only)
SELECT
    ROUND(SUM(price) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM order_items;

-- 6. Order status distribution
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 7. Monthly sales revenue and order volume

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS monthly_revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price

FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')

ORDER BY sales_month;