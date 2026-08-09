-- ── 6. Regional performance KPIs ─────────────────────────────
SELECT
    r.region_name,
    COUNT(DISTINCT o.customer_id)     AS customers,
    COUNT(DISTINCT o.order_id)        AS orders,
    ROUND(SUM(oi.line_total), 2)      AS revenue,
    ROUND(SUM(oi.line_total) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS aov,
    ROUND(SUM(ret.refund_amount), 2)  AS total_refunds
FROM dim_regions      r
JOIN fact_orders      o   ON r.region_id  = o.region_id
JOIN fact_order_items oi  ON o.order_id   = oi.order_id
LEFT JOIN fact_returns ret ON o.order_id  = ret.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY r.region_name
ORDER BY revenue DESC;
