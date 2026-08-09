-- Product inventory status (conditional bucketing)
SELECT
    product_id,
    product_name,
    category,
    stock_quantity,
    CASE
        WHEN stock_quantity = 0              THEN 'Out of Stock'
        WHEN stock_quantity BETWEEN 1 AND 20 THEN 'Low Stock'
        WHEN stock_quantity BETWEEN 21 AND 100 THEN 'Normal'
        ELSE                                      'Overstocked'
    END AS stock_status
FROM dim_products
WHERE is_active = TRUE
ORDER BY stock_quantity ASC;
