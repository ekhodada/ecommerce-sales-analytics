-- ── 4. Customer rank by lifetime value within each segment ───
SELECT
    c.customer_segment,
    c.first_name || ' ' || c.last_name  AS customer_name,
    ROUND(SUM(oi.line_total), 2)        AS lifetime_value,
    RANK()       OVER (
        PARTITION BY c.customer_segment ORDER BY SUM(oi.line_total) DESC
    )                                   AS rank_in_segment,
    DENSE_RANK() OVER (
        PARTITION BY c.customer_segment ORDER BY SUM(oi.line_total) DESC
    )                                   AS dense_rank_in_segment,
    NTILE(4)     OVER (
        PARTITION BY c.customer_segment ORDER BY SUM(oi.line_total) DESC
    )                                   AS quartile
FROM dim_customers       c
JOIN fact_orders         o  ON c.customer_id = o.customer_id
JOIN fact_order_items    oi ON o.order_id    = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_id, c.customer_segment, c.first_name, c.last_name
ORDER BY c.customer_segment, rank_in_segment;
