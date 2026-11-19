USE ecommerce_analytics;

SELECT
    customer_type,
    COUNT(*) AS total_customers
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        CASE
            WHEN COUNT(DISTINCT o.order_id) = 1
                THEN 'One-time Customer'
            ELSE 'Repeat Customer'
        END AS customer_type
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) AS customer_orders
GROUP BY customer_type;

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;