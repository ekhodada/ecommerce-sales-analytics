-- ── 5. FULL OUTER JOIN — Return rate by product ───────────────
--    Joins sales summary with returns summary; shows products
--    with returns but no active sales (discontinued).
SELECT
    COALESCE(s.product_id, ret.product_id) AS product_id,
    p.product_name,
    p.category,
    COALESCE(s.units_sold, 0)              AS units_sold,
    COALESCE(ret.units_returned, 0)        AS units_returned,
    ROUND(
        COALESCE(ret.units_returned, 0)::NUMERIC
        / NULLIF(COALESCE(s.units_sold, 0), 0) * 100, 2
    )                                      AS return_rate_pct
FROM (
    SELECT product_id, SUM(quantity) AS units_sold
    FROM   fact_order_items
    GROUP  BY product_id
) s
FULL OUTER JOIN (
    SELECT product_id, SUM(quantity_returned) AS units_returned
    FROM   fact_returns
    GROUP  BY product_id
) ret ON s.product_id = ret.product_id
LEFT JOIN dim_products p ON COALESCE(s.product_id, ret.product_id) = p.product_id
ORDER BY return_rate_pct DESC NULLS LAST;
