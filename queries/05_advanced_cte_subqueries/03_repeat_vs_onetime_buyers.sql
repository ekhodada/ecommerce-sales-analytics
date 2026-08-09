-- ── 3. CTE: Identify repeat vs. one-time buyers ───────────────
WITH order_counts AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS n_orders
    FROM   fact_orders
    WHERE  order_status <> 'Cancelled'
    GROUP  BY customer_id
),
labelled AS (
    SELECT
        oc.customer_id,
        oc.n_orders,
        CASE WHEN oc.n_orders = 1 THEN 'One-Time Buyer'
             WHEN oc.n_orders BETWEEN 2 AND 4 THEN 'Occasional'
             ELSE 'Loyal' END AS buyer_type
    FROM order_counts oc
)
SELECT
    buyer_type,
    COUNT(*)                                AS customers,
    ROUND(COUNT(*)::NUMERIC
          / SUM(COUNT(*)) OVER () * 100, 1) AS pct_of_total,
    ROUND(AVG(n_orders), 1)                 AS avg_orders
FROM labelled
GROUP BY buyer_type
ORDER BY customers DESC;
