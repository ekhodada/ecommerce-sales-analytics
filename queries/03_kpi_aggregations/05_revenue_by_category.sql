-- ── 5. Revenue by product category ───────────────────────────
SELECT
    p.category,
    COUNT(DISTINCT oi.order_id)              AS orders_containing_category,
    SUM(oi.quantity)                         AS units_sold,
    ROUND(SUM(oi.line_total), 2)             AS revenue,
    ROUND(SUM(oi.line_total - oi.quantity * p.cost_price), 2) AS profit,
    ROUND(
        SUM(oi.line_total - oi.quantity * p.cost_price)
        / NULLIF(SUM(oi.line_total), 0) * 100, 2
    )                                        AS margin_pct
FROM fact_order_items oi
JOIN dim_products     p ON oi.product_id = p.product_id
JOIN fact_orders      o ON oi.order_id   = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.category
ORDER BY revenue DESC;
