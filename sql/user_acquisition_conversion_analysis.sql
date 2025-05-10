/*
  Description:
  This SQL script analyzes user acquisition performance by evaluating new user registrations 
  and their conversion to depositing users, segmented by acquisition channels (Influencer and Agents). 
  It excludes invalid registrations (potential spam users) and calculates conversion rates.

  Author: Dicky Setiawan
*/

-- Step 1: Filter player registrations to only include Influencer and Agent channels for March 2025
WITH registered_filtered AS (
    SELECT 
        user_tags,
        registration_time,
        CASE 
            WHEN users_with_same_device_id > 0 AND total_deposit = 0 
                THEN 0 ELSE 1 
        END AS is_valid_register,
        total_deposit
    FROM player_list_2025_03
    WHERE user_tags IN ('Influencer', 'Agents')
    AND DATE_TRUNC('month', registration_time)::DATE = DATE '2025-03-01'
),

-- Step 2: Summarize total valid registrations, total players who deposited, and total deposit amounts per segment
filtered_summary AS (
    SELECT 
        DATE '2025-03-01' AS month,
        user_tags,
        SUM(is_valid_register) AS total_register,
        COUNT(*) FILTER (WHERE total_deposit != 0) AS total_player_deposits,
        SUM(total_deposit) AS total_deposit
    FROM registered_filtered
    GROUP BY user_tags
)

-- Step 3: Calculate the conversion rate from registration to deposit for each segment
SELECT 
    *, 
    ROUND(
        (total_player_deposits::NUMERIC / NULLIF(total_register, 0)) * 100, 
        2
    ) AS conversion
FROM filtered_summary;
