-- ── 4. Correlated subquery — Customers above average spend ────
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name  AS customer_name,
    c.customer_segment,
    ROUND(
        (SELECT SUM(oi2.line_total)
         FROM   fact_orders      o2
         JOIN   fact_order_items oi2 ON o2.order_id = oi2.order_id
         WHERE  o2.customer_id = c.customer_id
           AND  o2.order_status <> 'Cancelled'), 2
    )                                   AS lifetime_value
FROM dim_customers c
WHERE (
    SELECT SUM(oi.line_total)
    FROM   fact_orders      o
    JOIN   fact_order_items oi ON o.order_id = oi.order_id
    WHERE  o.customer_id = c.customer_id
      AND  o.order_status <> 'Cancelled'
) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(oi3.line_total) AS customer_total
        FROM   fact_orders      o3
        JOIN   fact_order_items oi3 ON o3.order_id = oi3.order_id
        WHERE  o3.order_status <> 'Cancelled'
        GROUP  BY o3.customer_id
    ) t
)
ORDER BY lifetime_value DESC;
