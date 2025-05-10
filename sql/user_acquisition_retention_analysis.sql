/*
  Description:
  This SQL script calculates the retention rate of players acquired through different user acquisition segments 
  (Influencer and Agents). It identifies valid depositors from the previous month and checks how many returned 
  to make deposits in the current month.

  Author: Dicky Setiawan
*/

-- Step 1: Identify valid depositors from March 2025 based on user acquisition segments
WITH previous_month_depositors AS (
    SELECT 
        uid,
        user_tags,
        registration_time,
        CASE 
            WHEN users_with_same_device_id > 0 AND total_deposit = 0 
                THEN 0 ELSE 1 
        END AS is_valid_depositor
    FROM player_list_2025_03
    WHERE user_tags IN ('Agents', 'Influencer') 
      AND total_deposit > 0
      AND DATE_TRUNC('month', registration_time)::DATE = DATE '2025-03-01'
),

-- Step 2: Filter only valid depositors and label the analysis period (March 2025)
filtered_previous_month AS (
    SELECT 
        uid,
        user_tags,
        DATE '2025-03-01' AS month
    FROM previous_month_depositors
    WHERE is_valid_depositor = 1
),

-- Step 3: Identify retained players who made successful deposits in April 2025
retained_players AS (
    SELECT DISTINCT 
        uid
    FROM online_recharge_2025_04
    WHERE payment_status = 'Paid' 
      AND paid_time IS NOT NULL
      AND DATE_TRUNC('month', paid_time)::DATE = DATE '2025-04-01'
)

-- Step 4: Calculate the retention rate by user acquisition segment
SELECT
    filtered.month,
    filtered.user_tags,
    COUNT(r.uid) AS total_retained_players,
    COUNT(p.uid) AS total_previous_players,
    ROUND(COUNT(r.uid) * 100.0 / NULLIF(COUNT(p.uid), 0), 2) AS retention_rate
FROM filtered_previous_month AS filtered
LEFT JOIN retained_players AS retained
    ON filtered.uid = retained.uid
GROUP BY filtered.month, filtered.user_tags;
