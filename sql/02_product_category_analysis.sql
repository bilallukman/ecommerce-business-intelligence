USE ecommerce_analytics;

-- Product category performance

SELECT
    COALESCE(
        ct.product_category_name_english,
        'unknown'
    ) AS product_category,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS units_sold,

    ROUND(SUM(oi.price), 2) AS total_revenue,

    ROUND(AVG(oi.price), 2) AS average_item_price

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY product_category

ORDER BY total_revenue DESC;