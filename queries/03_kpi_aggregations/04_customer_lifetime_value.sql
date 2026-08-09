-- ── 4. Customer Lifetime Value (CLV) ─────────────────────────
--    CLV = total spend; also shows recency for churn analysis
WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name  AS customer_name,
        c.customer_segment,
        c.registration_date,
        MIN(o.order_date)                   AS first_order_date,
        MAX(o.order_date)                   AS last_order_date,
        COUNT(DISTINCT o.order_id)          AS total_orders,
        ROUND(SUM(oi.line_total), 2)        AS lifetime_value
    FROM dim_customers       c
    JOIN fact_orders         o  ON c.customer_id = o.customer_id
    JOIN fact_order_items    oi ON o.order_id    = oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY c.customer_id, c.first_name, c.last_name,
             c.customer_segment, c.registration_date
)
SELECT
    *,
    DATE '2024-12-31' - last_order_date       AS days_since_last_order,
    CASE
        WHEN DATE '2024-12-31' - last_order_date <= 90  THEN 'Active'
        WHEN DATE '2024-12-31' - last_order_date <= 180 THEN 'At Risk'
        ELSE 'Churned'
    END                                        AS churn_status
FROM customer_spend
ORDER BY lifetime_value DESC;
