-- ── 7. Monthly new vs. returning customers ────────────────────
WITH customer_order_dates AS (
    SELECT
        customer_id,
        order_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_seq
    FROM fact_orders
    WHERE order_status <> 'Cancelled'
)
SELECT
    TO_CHAR(order_date, 'YYYY-MM')               AS month,
    COUNT(*) FILTER (WHERE order_seq = 1)        AS new_customers,
    COUNT(*) FILTER (WHERE order_seq > 1)        AS returning_customers,
    COUNT(*)                                     AS total_orders
FROM customer_order_dates
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;
