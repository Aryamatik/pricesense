SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE price > 1000) AS rows_above_1000,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE price > 1000) / COUNT(*),
        2
    ) AS pct_above_1000
FROM master;