-- Order count and revenue by status
SELECT
    order_status,
    COUNT(DISTINCT o.order_id)  AS order_count,
    SUM(oi.line_total)          AS gross_revenue,
    ROUND(AVG(oi.line_total),2) AS avg_line_value
FROM fact_orders      o
JOIN fact_order_items oi ON o.order_id = oi.order_id
GROUP BY order_status
ORDER BY gross_revenue DESC;
