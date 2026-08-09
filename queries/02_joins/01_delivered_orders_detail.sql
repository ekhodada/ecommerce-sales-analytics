-- ── 1. INNER JOIN — Orders with full customer & region detail ─
--    Returns only rows that have a match in all joined tables.
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.customer_segment,
    r.region_name,
    e.first_name || ' ' || e.last_name AS sales_rep,
    SUM(oi.line_total)                 AS order_total
FROM fact_orders      o
INNER JOIN dim_customers  c  ON o.customer_id = c.customer_id
INNER JOIN dim_regions    r  ON o.region_id   = r.region_id
INNER JOIN dim_employees  e  ON o.employee_id = e.employee_id
INNER JOIN fact_order_items oi ON o.order_id  = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY o.order_id, o.order_date, o.order_status,
         c.first_name, c.last_name, c.customer_segment,
         r.region_name, e.first_name, e.last_name
ORDER BY order_total DESC
LIMIT 20;
