-- ================================================
-- PriceSense | 01_data_cleaning.sql
-- ================================================

CREATE OR REPLACE TABLE transactions AS 
SELECT * FROM read_csv_auto('data/transactions.csv');

CREATE OR REPLACE TABLE consumer_insights AS 
SELECT * FROM read_csv_auto('data/consumer_insights.csv');

CREATE OR REPLACE TABLE geography_occasion AS 
SELECT * FROM read_csv_auto('data/geography_occasion.csv');

CREATE OR REPLACE TABLE product_metadata AS 
SELECT * FROM read_csv_auto('data/product_metadata.csv');

CREATE OR REPLACE TABLE competitor_pricing AS 
SELECT * FROM read_csv_auto('data/competitor_pricing.csv');

-- Remove impossible values
CREATE OR REPLACE TABLE transactions_clean AS
SELECT * FROM transactions
WHERE price > 0 AND quantity > 0;

-- Fix missing personas
CREATE OR REPLACE TABLE consumer_clean AS
SELECT
    user_id,
    COALESCE(persona, 'unknown') AS persona,
    trend_affinity,
    age_group,
    income_bracket,
    COALESCE(dietary_restriction, 'None') AS dietary_restriction
FROM consumer_insights;

-- Fix product category typos
CREATE OR REPLACE TABLE product_clean AS
SELECT
    product_id,
    TRIM(LOWER(category)) AS category,
    claims,
    ingredient_tags,
    pack_size
FROM product_metadata;

CREATE OR REPLACE TABLE geography_clean AS
SELECT
    order_id,
    TRIM(state)           AS state,
    TRIM(city_tier)       AS city_tier,
    TRIM(LOWER(occasion)) AS occasion
FROM geography_occasion
WHERE order_id IS NOT NULL;

-- Check results
SELECT 'original transactions' AS label, COUNT(*) AS rows FROM transactions
UNION ALL
SELECT 'after cleaning', COUNT(*) FROM transactions_clean;

-- Find Duplicate transactions
SELECT order_id, COUNT(*) FROM transactions
GROUP BY order_id HAVING COUNT(*) > 1;