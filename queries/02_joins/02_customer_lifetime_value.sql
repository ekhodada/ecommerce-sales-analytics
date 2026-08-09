-- ── 2. LEFT JOIN — All customers, including those with no orders ─
--    Reveals "registered but never purchased" customers.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.customer_segment,
    c.registration_date,
    COUNT(o.order_id)                  AS total_orders,
    COALESCE(SUM(oi.line_total), 0)    AS lifetime_value
FROM dim_customers       c
LEFT JOIN fact_orders    o  ON c.customer_id = o.customer_id
LEFT JOIN fact_order_items oi ON o.order_id  = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name,
         c.customer_segment, c.registration_date
ORDER BY lifetime_value DESC;
