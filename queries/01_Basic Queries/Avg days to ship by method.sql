-- Average days to ship by shipping method
SELECT
    shipping_method,
    COUNT(*)                                          AS orders_shipped,
    ROUND(AVG(ship_date - order_date), 1)             AS avg_days_to_ship,
    MIN(ship_date - order_date)                       AS min_days,
    MAX(ship_date - order_date)                       AS max_days
FROM fact_orders
WHERE ship_date IS NOT NULL
GROUP BY shipping_method
ORDER BY avg_days_to_ship;
