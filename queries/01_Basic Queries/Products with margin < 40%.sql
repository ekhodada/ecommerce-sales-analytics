-- Products with margin below 40%
SELECT
    product_id,
    product_name,
    category,
    unit_price,
    cost_price,
    ROUND((unit_price - cost_price) / unit_price * 100, 2) AS margin_pct
FROM dim_products
WHERE is_active = TRUE
  AND (unit_price - cost_price) / unit_price < 0.40
ORDER BY margin_pct ASC;
