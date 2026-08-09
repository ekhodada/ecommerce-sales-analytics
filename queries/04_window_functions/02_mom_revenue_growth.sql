-- ── 2. Month-over-month revenue growth (LAG) ─────────────────
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
    LAG(revenue) OVER (ORDER BY year, month)                    AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY year, month))
        / NULLIF(LAG(revenue) OVER (ORDER BY year, month), 0) * 100, 2
    )                                                           AS mom_growth_pct
FROM monthly
ORDER BY year, month;
