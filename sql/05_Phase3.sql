-- ================================================
-- PriceSense | 05_phase3_recommendations.sql
-- Phase 3: Pricing Strategy Recommendations
-- ================================================

-- QUERY 1: Best Revenue Price Bands

SELECT
    FLOOR(price/10)*10 AS price_band,
    ROUND(SUM(revenue),2) AS total_revenue,
    SUM(quantity) AS units_sold
FROM master_analysis
GROUP BY price_band
ORDER BY total_revenue DESC;


-- QUERY 2: Category Pricing Power

SELECT
    category,
    ROUND(AVG(price),2) AS avg_price,
    ROUND(SUM(revenue),2) AS total_revenue,
    SUM(quantity) AS total_units
FROM master_analysis
WHERE category IS NOT NULL
GROUP BY category
ORDER BY avg_price DESC;


-- QUERY 3: Geographic Pricing Strategy

SELECT
    city_tier,
    ROUND(AVG(price),2) AS avg_price,
    ROUND(SUM(revenue),2) AS total_revenue
FROM master_analysis
WHERE city_tier IS NOT NULL
GROUP BY city_tier
ORDER BY avg_price DESC;


-- QUERY 4: Most Valuable Personas

SELECT
    persona,
    ROUND(SUM(revenue),2) AS total_revenue,
    SUM(quantity) AS total_units
FROM master_analysis
GROUP BY persona
ORDER BY total_revenue DESC;


-- QUERY 5: Best Occasions

SELECT
    occasion,
    ROUND(SUM(revenue),2) AS total_revenue,
    SUM(quantity) AS total_units
FROM master_analysis
WHERE occasion IS NOT NULL
GROUP BY occasion
ORDER BY total_revenue DESC;


-- QUERY 6: Premium Product Claims

SELECT
    claims,
    ROUND(AVG(price),2) AS avg_price,
    ROUND(SUM(revenue),2) AS total_revenue
FROM master_analysis
WHERE claims IS NOT NULL
GROUP BY claims
ORDER BY avg_price DESC
LIMIT 20;


-- QUERY 7: Executive Recommendations

SELECT
    'Price Strategy' AS recommendation_type,
    'Focus pricing around the highest revenue price bands' AS recommendation

UNION ALL

SELECT
    'Occasion Strategy',
    'Prioritize late-night and religious-fasting campaigns'

UNION ALL

SELECT
    'Geographic Strategy',
    'Maintain premium pricing in Tier 1 cities'

UNION ALL

SELECT
    'Category Strategy',
    'Expand protein bars, protein shakes and supplements'

UNION ALL

SELECT
    'Product Claims',
    'Promote high-protein, low-sugar and keto-friendly products';