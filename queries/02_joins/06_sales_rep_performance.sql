-- ── 6. Multi-table JOIN — Sales rep performance ───────────────
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS sales_rep,
    e.role,
    r.region_name,
    COUNT(DISTINCT o.order_id)          AS orders_handled,
    COUNT(DISTINCT o.customer_id)       AS unique_customers,
    ROUND(SUM(oi.line_total), 2)        AS total_revenue,
    ROUND(AVG(oi.line_total), 2)        AS avg_order_item_value
FROM dim_employees    e
JOIN dim_regions      r  ON e.region_id   = r.region_id
JOIN fact_orders      o  ON e.employee_id = o.employee_id
JOIN fact_order_items oi ON o.order_id    = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY e.employee_id, e.first_name, e.last_name, e.role, r.region_name
ORDER BY total_revenue DESC;
