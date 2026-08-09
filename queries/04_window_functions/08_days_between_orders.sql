-- ── 8. Days between consecutive orders per customer (LAG) ─────
WITH ordered AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date
    FROM fact_orders
    WHERE order_status <> 'Cancelled'
)
SELECT
    customer_id,
    ROUND(AVG(order_date - prev_order_date), 1) AS avg_days_between_orders,
    MIN(order_date - prev_order_date)           AS min_days,
    MAX(order_date - prev_order_date)           AS max_days,
    COUNT(*)                                    AS repeat_orders
FROM ordered
WHERE prev_order_date IS NOT NULL
GROUP BY customer_id
ORDER BY avg_days_between_orders
LIMIT 20;
