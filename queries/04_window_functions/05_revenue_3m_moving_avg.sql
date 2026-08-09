-- ── 5. 3-month moving average of monthly revenue ─────────────
WITH monthly AS (
    SELECT
        d.year,
        d.month,
        ROUND(SUM(oi.line_total), 2) AS revenue
    FROM fact_orders      o
    JOIN dim_date         d  ON o.order_date  = d.date_id
    JOIN fact_order_items oi ON o.order_id   = oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY d.year, d.month
)
SELECT
    year,
    month,
    revenue,
    ROUND(
        AVG(revenue) OVER (
            ORDER BY year, month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moving_avg_3m
FROM monthly
ORDER BY year, month;
