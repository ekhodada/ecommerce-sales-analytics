-- ── 5. CTE chain: Product bundle analysis ────────────────────
--    Find product pairs frequently ordered together
WITH order_pairs AS (
    SELECT
        a.order_id,
        LEAST(a.product_id, b.product_id)    AS product_a,
        GREATEST(a.product_id, b.product_id) AS product_b
    FROM fact_order_items a
    JOIN fact_order_items b
      ON a.order_id = b.order_id
     AND a.product_id < b.product_id   -- avoid duplicate pairs
),
pair_counts AS (
    SELECT product_a, product_b, COUNT(*) AS co_occurrences
    FROM   order_pairs
    GROUP  BY product_a, product_b
    HAVING COUNT(*) >= 5
)
SELECT
    pa.product_name  AS product_a_name,
    pb.product_name  AS product_b_name,
    pc.co_occurrences
FROM pair_counts    pc
JOIN dim_products   pa ON pc.product_a = pa.product_id
JOIN dim_products   pb ON pc.product_b = pb.product_id
ORDER BY co_occurrences DESC
LIMIT 20;
