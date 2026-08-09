-- ── 4. INNER JOIN with date dimension — Monthly revenue trend ─
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(DISTINCT o.order_id)  AS orders,
    SUM(oi.line_total)          AS revenue,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM fact_orders      o
JOIN dim_date         d  ON o.order_date  = d.date_id
JOIN fact_order_items oi ON o.order_id   = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
