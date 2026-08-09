-- ── 7. Revenue percentile distribution of customers ──────────
WITH clv AS (
    SELECT
        c.customer_id,
        c.customer_segment,
        ROUND(SUM(oi.line_total), 2) AS lifetime_value
    FROM dim_customers    c
    JOIN fact_orders      o  ON c.customer_id = o.customer_id
    JOIN fact_order_items oi ON o.order_id    = oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY c.customer_id, c.customer_segment
)
SELECT
    customer_id,
    customer_segment,
    lifetime_value,
    ROUND(PERCENT_RANK() OVER (ORDER BY lifetime_value) * 100, 1) AS percentile,
    NTILE(10)           OVER (ORDER BY lifetime_value)             AS decile
FROM clv
ORDER BY lifetime_value DESC;
