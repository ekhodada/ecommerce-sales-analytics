-- ── 7. JOIN + aggregation — Customer + return behaviour ───────
--    Customers whose return rate exceeds 10 % of their orders.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.customer_segment,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    COUNT(DISTINCT ret.return_id)       AS total_returns,
    ROUND(
        COUNT(DISTINCT ret.return_id)::NUMERIC
        / NULLIF(COUNT(DISTINCT o.order_id), 0) * 100, 1
    )                                   AS return_rate_pct
FROM dim_customers    c
JOIN fact_orders      o   ON c.customer_id = o.customer_id
LEFT JOIN fact_returns ret ON o.order_id   = ret.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.first_name, c.last_name, c.customer_segment
HAVING COUNT(DISTINCT o.order_id) >= 3
ORDER BY return_rate_pct DESC
LIMIT 20;
