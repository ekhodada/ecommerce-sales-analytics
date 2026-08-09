-- ════════════════════════════════════════════════════════════
-- SECTION A: COMPLETENESS — required fields must not be NULL
-- ════════════════════════════════════════════════════════════

SELECT * FROM (

-- A1. Customers with NULL email or NULL registration_date
SELECT
    'dim_customers'                                                  AS table_name,
    'Null critical fields (email, registration_date)'                AS check_name,
    'Completeness'                                                   AS check_type,
    COUNT(*)                                                         AS records_checked,
    COUNT(*) FILTER (WHERE email IS NULL OR registration_date IS NULL) AS records_failed,
    1.0                                                              AS threshold_pct,
    CASE WHEN COUNT(*) FILTER (WHERE email IS NULL OR registration_date IS NULL)
              ::NUMERIC / NULLIF(COUNT(*), 0) * 100 <= 1.0
         THEN 'PASS' ELSE 'FAIL' END                                 AS status,
    'Email and registration_date are required for all customers'     AS notes
FROM dim_customers

UNION ALL

-- A2. Orders with NULL customer_id or order_date
SELECT
    'fact_orders',
    'Null FK or order_date',
    'Completeness',
    COUNT(*),
    COUNT(*) FILTER (WHERE customer_id IS NULL OR order_date IS NULL),
    0.0,
    CASE WHEN COUNT(*) FILTER (WHERE customer_id IS NULL OR order_date IS NULL) = 0
         THEN 'PASS' ELSE 'FAIL' END,
    'customer_id and order_date are mandatory on every order'
FROM fact_orders

UNION ALL

-- A3. Order items with NULL product_id or quantity
SELECT
    'fact_order_items',
    'Null product_id or quantity',
    'Completeness',
    COUNT(*),
    COUNT(*) FILTER (WHERE product_id IS NULL OR quantity IS NULL),
    0.0,
    CASE WHEN COUNT(*) FILTER (WHERE product_id IS NULL OR quantity IS NULL) = 0
         THEN 'PASS' ELSE 'FAIL' END,
    NULL
FROM fact_order_items

) checks
ORDER BY table_name;
