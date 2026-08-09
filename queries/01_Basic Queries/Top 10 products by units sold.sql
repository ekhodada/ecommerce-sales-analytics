-- Top 10 best-selling products by units sold
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity)   AS total_units_sold,
    SUM(oi.line_total) AS total_revenue
FROM fact_order_items oi
JOIN dim_products     p  ON oi.product_id = p.product_id
JOIN fact_orders      o  ON oi.order_id   = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_units_sold DESC
LIMIT 10;
