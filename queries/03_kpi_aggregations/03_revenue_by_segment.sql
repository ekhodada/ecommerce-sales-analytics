-- ── 3. Revenue by customer segment ───────────────────────────
SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_id)            AS customers,
    COUNT(DISTINCT o.order_id)               AS orders,
    ROUND(SUM(oi.line_total), 2)             AS revenue,
    ROUND(SUM(oi.line_total) / NULLIF(COUNT(DISTINCT c.customer_id), 0), 2) AS revenue_per_customer,
    ROUND(AVG(oi.line_total), 2)             AS avg_line_value
FROM dim_customers       c
JOIN fact_orders         o  ON c.customer_id = o.customer_id
JOIN fact_order_items    oi ON o.order_id    = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_segment
ORDER BY revenue DESC;
