-- ================================================
-- PriceSense | 02_phase1_sensitivity.sql
-- Phase 1: Find price thresholds where demand drops
-- ================================================

-- First join all 3 tables together into one master table
CREATE OR REPLACE TABLE master AS
SELECT
    t.order_id,
    t.product_id,
    t.price,
    t.quantity,
    t.channel,
    t.price * t.quantity AS revenue,
    c.persona,
    c.income_bracket,
    c.trend_affinity,
    g.state,
    g.city_tier,
    g.occasion,
    p.category,
    p.claims,
    p.pack_size
FROM transactions_clean t
LEFT JOIN consumer_clean      c ON t.user_id   = c.user_id
LEFT JOIN geography_occasion  g ON t.order_id  = g.order_id
LEFT JOIN product_clean       p ON t.product_id = p.product_id;

-- ------------------------------------------------
-- QUERY 1: Demand distribution across price buckets
-- How many units sold at each price range?
-- ------------------------------------------------
SELECT
    CASE
        WHEN price < 10  THEN '1) Under $10'
        WHEN price < 20  THEN '2) $10-$19'
        WHEN price < 30  THEN '3) $20-$29'
        WHEN price < 40  THEN '4) $30-$39'
        WHEN price < 50  THEN '5) $40-$49'
        ELSE                  '6) $50+'
    END AS price_bucket,
    COUNT(*)            AS num_transactions,
    SUM(quantity)       AS total_units_sold,
    ROUND(AVG(quantity), 2) AS avg_units_per_order,
    ROUND(SUM(revenue), 2)  AS total_revenue
FROM master
GROUP BY price_bucket
ORDER BY price_bucket;

-- ------------------------------------------------
-- QUERY 2: Sensitivity by persona
-- Do budget users buy less when price goes up?
-- ------------------------------------------------
SELECT
    persona,
    CASE
        WHEN price < 10  THEN '1) Under $10'
        WHEN price < 20  THEN '2) $10-$19'
        WHEN price < 30  THEN '3) $20-$29'
        WHEN price < 40  THEN '4) $30-$39'
        WHEN price < 50  THEN '5) $40-$49'
        ELSE                  '6) $50+'
    END AS price_bucket,
    COUNT(*)                AS num_transactions,
    ROUND(AVG(quantity), 2) AS avg_units,
    ROUND(SUM(revenue), 2)  AS total_revenue
FROM master
WHERE persona IS NOT NULL
GROUP BY persona, price_bucket
ORDER BY persona, price_bucket;

-- ------------------------------------------------
-- QUERY 3: Best performing price per persona
-- Which price bucket makes the most revenue per persona?
-- ------------------------------------------------
SELECT
    persona,
    CASE
        WHEN price < 10  THEN '1) Under $10'
        WHEN price < 20  THEN '2) $10-$19'
        WHEN price < 30  THEN '3) $20-$29'
        WHEN price < 40  THEN '4) $30-$39'
        WHEN price < 50  THEN '5) $40-$49'
        ELSE                  '6) $50+'
    END AS price_bucket,
    ROUND(SUM(revenue), 2) AS total_revenue,
    SUM(quantity)          AS total_units
FROM master
WHERE persona IS NOT NULL
GROUP BY persona, price_bucket
ORDER BY persona, total_revenue DESC;