-- ── 1. Overall revenue KPI summary ───────────────────────────
SELECT
    COUNT(DISTINCT o.order_id)                              AS total_orders,
    COUNT(DISTINCT o.customer_id)                          AS unique_customers,
    ROUND(SUM(oi.line_total), 2)                           AS gross_revenue,
    ROUND(SUM(oi.line_total - (oi.quantity * p.cost_price)), 2) AS gross_profit,
    ROUND(
        SUM(oi.line_total - (oi.quantity * p.cost_price))
        / NULLIF(SUM(oi.line_total), 0) * 100, 2
    )                                                       AS overall_margin_pct,
    ROUND(SUM(oi.line_total) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS avg_order_value
FROM fact_orders      o
JOIN fact_order_items oi ON o.order_id   = oi.order_id
JOIN dim_products     p  ON oi.product_id = p.product_id
WHERE o.order_status <> 'Cancelled';
