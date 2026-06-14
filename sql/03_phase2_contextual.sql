-- ================================================
-- PriceSense | 03_phase2_contextual.sql
-- Phase 2: Geography, Occasions, Trend Claims, Competitors
-- ================================================

-- ------------------------------------------------
-- QUERY 1: Revenue and demand by State
-- Which states tolerate higher prices?
-- ------------------------------------------------
SELECT
    state,
    city_tier,
    COUNT(*)                    AS num_transactions,
    ROUND(AVG(price), 2)        AS avg_price,
    SUM(quantity)               AS total_units,
    ROUND(SUM(revenue), 2)      AS total_revenue,
    ROUND(AVG(revenue), 2)      AS avg_order_value
FROM master
WHERE state IS NOT NULL
GROUP BY state, city_tier
ORDER BY avg_price DESC;

-- ------------------------------------------------
-- QUERY 2: Revenue by City Tier
-- Do Tier 1 cities pay more?
-- ------------------------------------------------
SELECT
    city_tier,
    COUNT(*)                    AS num_transactions,
    ROUND(AVG(price), 2)        AS avg_price,
    SUM(quantity)               AS total_units,
    ROUND(SUM(revenue), 2)      AS total_revenue
FROM master
WHERE city_tier IS NOT NULL
GROUP BY city_tier
ORDER BY avg_price DESC;

-- ------------------------------------------------
-- QUERY 3: Occasion analysis
-- Which occasions drive highest prices and revenue?
-- ------------------------------------------------
SELECT
    occasion,
    COUNT(*)                    AS num_transactions,
    ROUND(AVG(price), 2)        AS avg_price,
    SUM(quantity)               AS total_units,
    ROUND(SUM(revenue), 2)      AS total_revenue,
    ROUND(AVG(quantity), 2)     AS avg_units_per_order
FROM master
WHERE occasion IS NOT NULL
GROUP BY occasion
ORDER BY avg_price DESC;

-- ------------------------------------------------
-- QUERY 4: Do trend claims justify higher prices?
-- Compare avg price of products with vs without claims
-- ------------------------------------------------
SELECT
    claims,
    COUNT(*)                    AS num_transactions,
    ROUND(AVG(price), 2)        AS avg_price,
    SUM(quantity)               AS total_units,
    ROUND(SUM(revenue), 2)      AS total_revenue
FROM master
WHERE claims IS NOT NULL
GROUP BY claims
ORDER BY avg_price DESC;

-- ------------------------------------------------
-- QUERY 5: Competitor pricing comparison
-- How do our prices compare to competitors?
-- ------------------------------------------------
SELECT
    'Our products'              AS source,
    ROUND(AVG(price), 2)        AS avg_price,
    ROUND(MIN(price), 2)        AS min_price,
    ROUND(MAX(price), 2)        AS max_price
FROM master
UNION ALL
SELECT
    'Competitors'               AS source,
    ROUND(AVG(price), 2)        AS avg_price,
    ROUND(MIN(price), 2)        AS min_price,
    ROUND(MAX(price), 2)        AS max_price
FROM competitor_pricing
WHERE price > 0;

-- ------------------------------------------------
-- QUERY 6: Persona x Occasion sweet spots
-- Which persona + occasion combo drives most revenue?
-- ------------------------------------------------
SELECT
    persona,
    occasion,
    ROUND(AVG(price), 2)        AS avg_price,
    ROUND(SUM(revenue), 2)      AS total_revenue,
    SUM(quantity)               AS total_units
FROM master
WHERE persona IS NOT NULL
AND occasion IS NOT NULL
GROUP BY persona, occasion
ORDER BY total_revenue DESC
LIMIT 15;