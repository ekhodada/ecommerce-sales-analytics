-- ════════════════════════════════════════════════════════════
-- SECTION E: ANOMALY DETECTION
-- ════════════════════════════════════════════════════════════

WITH daily_orders AS (
    SELECT customer_id, order_date, COUNT(*) AS n
    FROM   fact_orders
    GROUP  BY customer_id, order_date
    HAVING COUNT(*) > 3
)
SELECT * FROM (

-- E1. Orders with unusually high discount (> 50 %)
SELECT
    'fact_orders'                        AS table_name,
    'Discount percentage exceeds 50%'    AS check_name,
    'Validity'                           AS check_type,
    COUNT(*)                             AS records_checked,
    COUNT(*) FILTER (WHERE discount_pct > 50) AS records_failed,
    1.0                                  AS threshold_pct,
    CASE WHEN COUNT(*) FILTER (WHERE discount_pct > 50)
              ::NUMERIC / NULLIF(COUNT(*), 0) * 100 <= 1.0
         THEN 'WARNING' ELSE 'FAIL' END  AS status,
    'Discounts >50% require review'      AS notes
FROM fact_orders

UNION ALL

-- E2. Customers with more than 3 orders in a single day (bot/fraud signal)
SELECT
    'fact_orders',
    'Customer with >3 orders on the same day',
    'Consistency',
    (SELECT COUNT(DISTINCT customer_id) FROM fact_orders),
    COUNT(DISTINCT customer_id),
    1.0,
    CASE WHEN COUNT(DISTINCT customer_id) = 0 THEN 'PASS' ELSE 'WARNING' END,
    'Possible duplicate or automated orders'
FROM daily_orders

) checks
ORDER BY table_name;
