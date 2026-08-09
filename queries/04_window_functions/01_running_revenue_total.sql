-- ── 1. Running revenue total (cumulative sum) ─────────────────
SELECT
    d.year,
    d.month,
    d.month_name,
    ROUND(SUM(oi.line_total), 2)               AS monthly_revenue,
    ROUND(
        SUM(SUM(oi.line_total)) OVER (
            PARTITION BY d.year ORDER BY d.month
        ), 2
    )                                          AS ytd_revenue,
    ROUND(
        SUM(SUM(oi.line_total)) OVER (
            ORDER BY d.year, d.month
        ), 2
    )                                          AS all_time_running_total
FROM fact_orders      o
JOIN dim_date         d  ON o.order_date  = d.date_id
JOIN fact_order_items oi ON o.order_id   = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
