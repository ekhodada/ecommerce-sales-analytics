-- ── 7. CTE: Escalation alert — orders late to ship ───────────
--    Orders in 'Processing' status older than 3 days
WITH processing_orders AS (
    SELECT
        o.order_id,
        o.order_date,
        o.order_status,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.email,
        DATE '2024-12-31' - o.order_date   AS days_in_processing,
        SUM(oi.line_total)                 AS order_value
    FROM fact_orders      o
    JOIN dim_customers    c  ON o.customer_id = c.customer_id
    JOIN fact_order_items oi ON o.order_id    = oi.order_id
    WHERE o.order_status = 'Processing'
    GROUP BY o.order_id, o.order_date, o.order_status,
             c.first_name, c.last_name, c.email
)
SELECT
    *,
    CASE
        WHEN days_in_processing > 7  THEN 'CRITICAL'
        WHEN days_in_processing > 3  THEN 'WARNING'
        ELSE                              'NORMAL'
    END AS alert_level
FROM processing_orders
WHERE days_in_processing > 3
ORDER BY days_in_processing DESC;
