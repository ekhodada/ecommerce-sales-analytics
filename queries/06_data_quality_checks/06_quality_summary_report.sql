-- ════════════════════════════════════════════════════════════
-- QUALITY SUMMARY REPORT
-- ════════════════════════════════════════════════════════════
SELECT
    status,
    check_type,
    COUNT(*)             AS checks_run,
    SUM(records_failed)  AS total_records_failed
FROM data_quality_log
GROUP BY status, check_type
ORDER BY
    CASE status WHEN 'FAIL' THEN 1 WHEN 'WARNING' THEN 2 ELSE 3 END,
    check_type;
