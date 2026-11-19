USE ecommerce_analytics;

SELECT
    COUNT(*) AS total_delivered_orders,

    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ), 2
    ) AS avg_actual_delivery_days,

    ROUND(
        AVG(
            DATEDIFF(
                order_estimated_delivery_date,
                order_purchase_timestamp
            )
        ), 2
    ) AS avg_estimated_delivery_days,

    SUM(
        CASE
            WHEN order_delivered_customer_date <= order_estimated_delivery_date
            THEN 1 ELSE 0
        END
    ) AS delivered_on_time,

    SUM(
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 1 ELSE 0
        END
    ) AS delivered_late

FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL;

SELECT
    CASE
        WHEN DATEDIFF(
            order_delivered_customer_date,
            order_estimated_delivery_date
        ) > 0 THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,

    COUNT(*) AS total_orders,

    ROUND(AVG(r.review_score), 2) AS avg_review_score

FROM orders o
JOIN reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL

GROUP BY delivery_status;