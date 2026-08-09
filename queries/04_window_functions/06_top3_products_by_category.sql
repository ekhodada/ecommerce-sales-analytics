-- ── 6. Top 3 products per category (ROW_NUMBER) ───────────────
WITH product_sales AS (
    SELECT
        p.category,
        p.product_name,
        SUM(oi.quantity)        AS units_sold,
        ROUND(SUM(oi.line_total), 2) AS revenue,
        ROW_NUMBER() OVER (
            PARTITION BY p.category ORDER BY SUM(oi.line_total) DESC
        )                       AS rank_in_category
    FROM fact_order_items oi
    JOIN dim_products     p ON oi.product_id = p.product_id
    JOIN fact_orders      o ON oi.order_id   = o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY p.category, p.product_name
)
SELECT category, product_name, units_sold, revenue, rank_in_category
FROM   product_sales
WHERE  rank_in_category <= 3
ORDER BY category, rank_in_category;
