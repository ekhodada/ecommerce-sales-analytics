-- ── 2. Revenue by year and quarter ───────────────────────────
SELECT
    d.year,
    d.quarter,
    ROUND(SUM(oi.line_total), 2)                     AS revenue,
    ROUND(SUM(oi.line_total - oi.quantity * p.cost_price), 2) AS profit,
    COUNT(DISTINCT o.order_id)                       AS orders,
    COUNT(DISTINCT o.customer_id)                    AS customers
FROM fact_orders      o
JOIN dim_date         d  ON o.order_date  = d.date_id
JOIN fact_order_items oi ON o.order_id   = oi.order_id
JOIN dim_products     p  ON oi.product_id = p.product_id
WHERE o.order_status <> 'Cancelled'
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;
