-- ── 6. Weekly revenue seasonality (EXTRACT + CASE) ───────────
SELECT
    d.day_name,
    EXTRACT(ISODOW FROM o.order_date)   AS day_num,
    COUNT(DISTINCT o.order_id)          AS orders,
    ROUND(SUM(oi.line_total), 2)        AS revenue,
    ROUND(AVG(oi.line_total), 2)        AS avg_item_value,
    CASE
        WHEN EXTRACT(ISODOW FROM o.order_date) IN (6,7) THEN 'Weekend'
        ELSE 'Weekday'
    END                                 AS day_type
FROM fact_orders      o
JOIN dim_date         d  ON o.order_date  = d.date_id
JOIN fact_order_items oi ON o.order_id   = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY d.day_name, EXTRACT(ISODOW FROM o.order_date)
ORDER BY day_num;
