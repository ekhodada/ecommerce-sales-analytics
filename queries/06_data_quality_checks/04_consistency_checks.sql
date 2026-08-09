-- ════════════════════════════════════════════════════════════
-- SECTION D: CONSISTENCY — cross-table referential integrity
-- ════════════════════════════════════════════════════════════

SELECT * FROM (

-- D1. Orders referencing non-existent customers
SELECT
    'fact_orders'                                        AS table_name,
    'Orphan customer_id (no match in dim_customers)'     AS check_name,
    'Consistency'                                        AS check_type,
    COUNT(*)                                             AS records_checked,
    COUNT(*) FILTER (WHERE o.customer_id NOT IN (SELECT customer_id FROM dim_customers)) AS records_failed,
    0.0                                                  AS threshold_pct,
    CASE WHEN COUNT(*) FILTER (WHERE o.customer_id NOT IN
        (SELECT customer_id FROM dim_customers)) = 0
         THEN 'PASS' ELSE 'FAIL' END                     AS status,
    NULL                                                 AS notes
FROM fact_orders o

UNION ALL

-- D2. Ship date before order date
SELECT
    'fact_orders',
    'Ship date precedes order date',
    'Consistency',
    COUNT(*) FILTER (WHERE ship_date IS NOT NULL),
    COUNT(*) FILTER (WHERE ship_date IS NOT NULL AND ship_date < order_date),
    0.0,
    CASE WHEN COUNT(*) FILTER (WHERE ship_date IS NOT NULL AND ship_date < order_date) = 0
         THEN 'PASS' ELSE 'FAIL' END,
    NULL
FROM fact_orders

UNION ALL

-- D3. Returns for non-delivered orders
SELECT
    'fact_returns',
    'Return linked to non-Delivered order',
    'Consistency',
    COUNT(DISTINCT r.return_id),
    COUNT(DISTINCT r.return_id) FILTER (WHERE o.order_status <> 'Delivered'),
    0.0,
    CASE WHEN COUNT(DISTINCT r.return_id) FILTER (WHERE o.order_status <> 'Delivered') = 0
         THEN 'PASS' ELSE 'FAIL' END,
    'Only delivered orders can generate returns'
FROM fact_returns r
JOIN fact_orders  o ON r.order_id = o.order_id

) checks
ORDER BY table_name;
