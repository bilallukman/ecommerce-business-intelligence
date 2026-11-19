USE ecommerce_analytics;

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_payment,
    ROUND(AVG(payment_value), 2) AS avg_payment_value
FROM payments
GROUP BY payment_type
ORDER BY total_payment DESC;