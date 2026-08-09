-- ════════════════════════════════════════════════════════════
-- SECTION C: VALIDITY — values within allowed ranges/sets
-- ════════════════════════════════════════════════════════════

SELECT * FROM (

-- C1. Invalid order_status values
SELECT
    'fact_orders'                        AS table_name,
    'Invalid order_status value'         AS check_name,
    'Validity'                           AS check_type,
    COUNT(*)                             AS records_checked,
    COUNT(*) FILTER (WHERE order_status NOT IN
        ('Pending','Processing','Shipped','Delivered','Cancelled')) AS records_failed,
    0.0                                  AS threshold_pct,
    CASE WHEN COUNT(*) FILTER (WHERE order_status NOT IN
        ('Pending','Processing','Shipped','Delivered','Cancelled')) = 0
         THEN 'PASS' ELSE 'FAIL' END     AS status,
    NULL                                 AS notes
FROM fact_orders

UNION ALL

-- C2. Unit price ≤ 0 in order items
SELECT
    'fact_order_items',
    'Unit price zero or negative',
    'Validity',
    COUNT(*),
    COUNT(*) FILTER (WHERE unit_price <= 0),
    0.0,
    CASE WHEN COUNT(*) FILTER (WHERE unit_price <= 0) = 0 THEN 'PASS' ELSE 'FAIL' END,
    'All sold items must have a positive price'
FROM fact_order_items

UNION ALL

-- C3. Customer segment outside allowed values
SELECT
    'dim_customers',
    'Invalid customer_segment value',
    'Validity',
    COUNT(*),
    COUNT(*) FILTER (WHERE customer_segment NOT IN ('Bronze','Silver','Gold','Platinum')),
    0.0,
    CASE WHEN COUNT(*) FILTER (WHERE customer_segment NOT IN
        ('Bronze','Silver','Gold','Platinum')) = 0
         THEN 'PASS' ELSE 'FAIL' END,
    NULL
FROM dim_customers

UNION ALL

-- C4. Products where cost_price >= unit_price (negative margin)
SELECT
    'dim_products',
    'Cost price >= unit price (negative or zero margin)',
    'Validity',
    COUNT(*),
    COUNT(*) FILTER (WHERE cost_price >= unit_price),
    0.0,
    CASE WHEN COUNT(*) FILTER (WHERE cost_price >= unit_price) = 0
         THEN 'PASS' ELSE 'FAIL' END,
    'Every product should have a positive margin'
FROM dim_products

) checks
ORDER BY table_name;
