-- ════════════════════════════════════════════════════════════
-- SECTION B: UNIQUENESS — no duplicate key values
-- ════════════════════════════════════════════════════════════

WITH dupes AS (
    SELECT order_id, product_id, COUNT(*) AS cnt
    FROM   fact_order_items
    GROUP  BY order_id, product_id
    HAVING COUNT(*) > 1
)
SELECT * FROM (

-- B1. Duplicate emails in dim_customers
SELECT
    'dim_customers'                            AS table_name,
    'Duplicate email addresses'                AS check_name,
    'Uniqueness'                               AS check_type,
    COUNT(*)                                   AS records_checked,
    COUNT(*) - COUNT(DISTINCT email)           AS records_failed,
    0.0                                        AS threshold_pct,
    CASE WHEN COUNT(*) - COUNT(DISTINCT email) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    'Email must be unique across all customers' AS notes
FROM dim_customers

UNION ALL

-- B2. Duplicate (order_id, product_id) in fact_order_items
SELECT
    'fact_order_items',
    'Duplicate (order_id, product_id) combinations',
    'Uniqueness',
    (SELECT COUNT(*) FROM fact_order_items),
    COALESCE((SELECT SUM(cnt - 1) FROM dupes), 0),
    0.0,
    CASE WHEN (SELECT COUNT(*) FROM dupes) = 0 THEN 'PASS' ELSE 'FAIL' END,
    'Each product should appear once per order line'
FROM (SELECT 1) t

) checks
ORDER BY table_name;
