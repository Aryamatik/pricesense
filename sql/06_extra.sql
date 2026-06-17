WITH unit_calculated AS (
    -- Step 1: Calculate the units from the master table
    SELECT 
        *,
        CASE 
            WHEN pack_size = 'Single' THEN 1
            WHEN pack_size = '4-Pack' THEN 4
            WHEN pack_size = '12-Pack' THEN 12
            ELSE 1 
        END AS total_units_in_pack
    FROM master
)
-- Step 2: Query the temporary table and apply your filters/math
SELECT 
    *,
    COUNT(*) OVER (ORDER BY price) AS num_transactions_per_product,
    ROUND(price / total_units_in_pack, 2) AS unit_price
FROM unit_calculated
WHERE (price / total_units_in_pack) > 100;