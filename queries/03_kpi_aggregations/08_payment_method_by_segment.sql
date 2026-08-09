-- ── 8. Payment method preference by segment ──────────────────
SELECT
    c.customer_segment,
    o.payment_method,
    COUNT(*)                               AS order_count,
    ROUND(SUM(oi.line_total), 2)           AS revenue,
    ROUND(
        COUNT(*)::NUMERIC
        / SUM(COUNT(*)) OVER (PARTITION BY c.customer_segment) * 100, 1
    )                                      AS pct_of_segment
FROM dim_customers   c
JOIN fact_orders     o  ON c.customer_id = o.customer_id
JOIN fact_order_items oi ON o.order_id   = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_segment, o.payment_method
ORDER BY c.customer_segment, order_count DESC;
