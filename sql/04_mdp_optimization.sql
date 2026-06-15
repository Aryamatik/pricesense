-- ================================================
-- PriceSense | 04_mdp_optimization.sql
-- MDP Optimization: Find optimal price state
-- for every persona x geography x occasion combo
-- ================================================

-- Step 1: Define states (price buckets) and 
-- calculate reward (revenue) for each state
CREATE OR REPLACE TABLE price_states AS
SELECT
    persona,
    city_tier,
    occasion,
    CASE
        WHEN price < 10 THEN 'S1_under10'
        WHEN price < 20 THEN 'S2_10to19'
        WHEN price < 30 THEN 'S3_20to29'
        WHEN price < 40 THEN 'S4_30to39'
        WHEN price < 50 THEN 'S5_40to49'
        ELSE                 'S6_50plus'
    END AS price_state,
    CASE
        WHEN price < 10 THEN 5
        WHEN price < 20 THEN 15
        WHEN price < 30 THEN 25
        WHEN price < 40 THEN 35
        WHEN price < 50 THEN 45
        ELSE                 60
    END AS state_midpoint,
    COUNT(*)                AS num_transactions,
    SUM(quantity)           AS total_units,
    ROUND(SUM(revenue), 2)  AS total_reward,
    ROUND(AVG(revenue), 2)  AS avg_reward_per_txn
FROM master
WHERE persona IS NOT NULL
  AND city_tier IS NOT NULL
  AND occasion IS NOT NULL
GROUP BY persona, city_tier, occasion, price_state, state_midpoint;

-- Step 2: Find the OPTIMAL state (highest reward)
-- for each persona x city_tier x occasion combination
-- This is your MDP policy table
CREATE OR REPLACE TABLE optimal_policy AS
WITH ranked AS (
    SELECT *,
        RANK() OVER (
            PARTITION BY persona, city_tier, occasion
            ORDER BY total_reward DESC
        ) AS reward_rank
    FROM price_states
)
SELECT
    persona,
    city_tier,
    occasion,
    price_state         AS optimal_price_state,
    state_midpoint      AS optimal_price_point,
    total_units         AS units_at_optimal,
    total_reward        AS max_revenue,
    avg_reward_per_txn  AS avg_order_value
FROM ranked
WHERE reward_rank = 1
ORDER BY persona, city_tier, total_reward DESC;

-- Step 3: Show the policy — 
-- "For this persona in this city on this occasion, charge THIS"
SELECT * FROM optimal_policy;

-- Step 4: Demand drop % between states (transition probability proxy)
-- Shows how sensitive demand is when you move between price states
-- Step 4: Demand drop % between states (transition probability proxy)
WITH state_demand AS (
    SELECT
        persona,
        CASE
            WHEN price < 10 THEN 'S1_under10'
            WHEN price < 20 THEN 'S2_10to19'
            WHEN price < 30 THEN 'S3_20to29'
            WHEN price < 40 THEN 'S4_30to39'
            WHEN price < 50 THEN 'S5_40to49'
            ELSE                 'S6_50plus'
        END AS price_bucket,
        CASE
            WHEN price < 10 THEN 1
            WHEN price < 20 THEN 2
            WHEN price < 30 THEN 3
            WHEN price < 40 THEN 4
            WHEN price < 50 THEN 5
            ELSE                 6
        END AS state_order,
        SUM(quantity) AS total_units
    FROM master
    WHERE persona IS NOT NULL
    GROUP BY persona, price_bucket, state_order
),
with_previous AS (
    SELECT *,
        LAG(total_units) OVER (
            PARTITION BY persona
            ORDER BY state_order
        ) AS prev_units
    FROM state_demand
)
SELECT
    persona,
    price_bucket,
    total_units,
    prev_units,
    ROUND(
        (total_units - prev_units) * 100.0 / NULLIF(prev_units, 0),
    1) AS pct_demand_change
FROM with_previous
ORDER BY persona, state_order;