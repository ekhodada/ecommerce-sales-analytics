-- ── 3. LEFT JOIN — Products never ordered ────────────────────
--    Inventory items that have zero sales history.
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    p.stock_quantity
FROM dim_products        p
LEFT JOIN fact_order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL
  AND p.is_active = TRUE
ORDER BY p.category, p.product_name;
