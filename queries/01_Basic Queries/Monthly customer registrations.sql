-- Customers registered each month (2022–2024)
SELECT
    TO_CHAR(registration_date, 'YYYY-MM') AS month,
    COUNT(*)                               AS new_customers,
    COUNT(*) FILTER (WHERE customer_segment = 'Gold')     AS gold,
    COUNT(*) FILTER (WHERE customer_segment = 'Platinum') AS platinum
FROM dim_customers
GROUP BY TO_CHAR(registration_date, 'YYYY-MM')
ORDER BY month;
