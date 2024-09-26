SELECT
    process_name,
    received_date,
    status_name,
   
    -- TAT hours calculation based on TAT days
    CASE 
        WHEN process_id IN (16677, 16889, 4871, 12628, 12631, 12818, 4291, 12815, 16686, 16689, 1848, 5164, 5165, 12273, 16961, 16936, 16691) THEN 1 * 24
        WHEN process_id IN (16981, 13657, 12682, 1889, 4688, 1958, 5315, 5166, 12412, 1396, 4002, 12988, 1960, 3391, 12812) THEN 2 * 24
        WHEN process_id IN (12636, 16679, 16681, 4690, 16743) THEN 7 * 24
        WHEN process_id IN (1868, 1871) THEN 5 * 24
        WHEN process_id IN (2018, 2016, 1063, 2006, 2004, 988) THEN 45 * 24
        WHEN process_id = 13217 THEN 21 * 24
        WHEN process_id IN (12257, 12318) THEN 30 * 24
        WHEN process_id IN (5167, 1179, 16959, 16963) THEN 10 * 24
        WHEN process_id IN (13214, 16685) THEN 14 * 24
        ELSE 0  -- Default TAT_hours for other processes
    END AS TAT_hours,
    
    -- TAT days calculation
    CASE 
        WHEN process_id IN (16677, 16889, 4871, 12628, 12631, 12818, 4291, 12815, 16686, 16689, 1848, 5164, 5165, 12273, 16961, 16936, 16691) THEN 1
        WHEN process_id IN (16981, 13657, 12682, 1889, 4688, 1958, 5315, 5166, 12412, 1396, 4002, 12988, 1960, 3391, 12812) THEN 2
        WHEN process_id IN (12636, 16679, 16681, 4690, 16743) THEN 7
        WHEN process_id IN (1868, 1871) THEN 5
        WHEN process_id IN (2018, 2016, 1063, 2006, 2004, 988) THEN 45
        WHEN process_id = 13217 THEN 21
        WHEN process_id IN (12257, 12318) THEN 30
        WHEN process_id IN (5167, 1179, 16959, 16963) THEN 10
        WHEN process_id IN (13214, 16685) THEN 14
        ELSE 0  -- Default TAT_days for other processes
    END AS TAT_days,

    -- Time difference between end_time and received_date in hours
    TIMESTAMPDIFF(HOUR, received_date, end_time) AS time_diff_hours,

    -- Time difference between end_time and received_date in days
    TIMESTAMPDIFF(DAY, received_date, end_time) AS time_diff_days,

    -- Rule to determine "Green" status based on process_id, status_name, and TAT rules
    CASE 
        WHEN process_id IN (16677, 16889, 4871, 12628, 12631, 12818, 4291, 12815, 16686, 16689, 1848, 5164, 5165, 12273, 16961, 16936, 16691) THEN
            CASE
                WHEN CONVERT(status_name USING utf8mb4) = 'Completed' AND TIMESTAMPDIFF(DAY, received_date, end_time) <= 1 THEN 'Green'
                WHEN CONVERT(status_name USING utf8mb4) IN ('Not Completed', 'Additional information needed – Pending') AND TIMESTAMPDIFF(DAY, received_date, NOW()) <= 1 THEN 'Green'
                ELSE 'Red'
            END
        WHEN process_id IN (16981, 13657, 12682, 1889, 4688, 1958, 5315, 5166, 12412, 1396, 4002, 12988, 1960, 3391, 12812) THEN
            CASE
                WHEN CONVERT(status_name USING utf8mb4) = 'Completed' AND TIMESTAMPDIFF(DAY, received_date, end_time) <= 2 THEN 'Green'
                WHEN CONVERT(status_name USING utf8mb4) IN ('Not Completed', 'Additional information needed – Pending') AND TIMESTAMPDIFF(DAY, received_date, NOW()) <= 2 THEN 'Green'
                ELSE 'Red'
            END
        WHEN process_id IN (12636, 16679, 16681, 4690, 16743) THEN
            CASE
                WHEN CONVERT(status_name USING utf8mb4) = 'Completed' AND TIMESTAMPDIFF(DAY, received_date, end_time) <= 7 THEN 'Green'
                WHEN CONVERT(status_name USING utf8mb4) IN ('Not Completed', 'Additional information needed – Pending') AND TIMESTAMPDIFF(DAY, received_date, NOW()) <= 7 THEN 'Green'
                ELSE 'Red'
            END
        WHEN process_id IN (1868, 1871) THEN
            CASE
                WHEN CONVERT(status_name USING utf8mb4) = 'Completed' AND TIMESTAMPDIFF(DAY, received_date, end_time) <= 5 THEN 'Green'
                WHEN CONVERT(status_name USING utf8mb4) IN ('Not Completed', 'Additional information needed – Pending') AND TIMESTAMPDIFF(DAY, received_date, NOW()) <= 5 THEN 'Green'
                ELSE 'Red'
            END
        WHEN process_id IN (2018, 2016, 1063, 2006, 2004, 988) THEN
            CASE
                WHEN CONVERT(status_name USING utf8mb4) = 'Completed' AND TIMESTAMPDIFF(DAY, end_time, effective_date) > 45 THEN 'Green'
                WHEN CONVERT(status_name USING utf8mb4) IN ('Not Completed', 'Additional information needed – Pending') AND TIMESTAMPDIFF(DAY, NOW(), effective_date) > 45 THEN 'Green'
                ELSE 'Red'
            END
        WHEN process_id = 13217 THEN
            CASE
                WHEN CONVERT(status_name USING utf8mb4) = 'Completed' AND TIMESTAMPDIFF(DAY, end_time, effective_date) >= 21 THEN 'Green'
                WHEN CONVERT(status_name USING utf8mb4) IN ('Not Completed', 'Additional information needed – Pending') AND TIMESTAMPDIFF(DAY, NOW(), effective_date) >= 21 THEN 'Green'
                ELSE 'Red'
            END
        WHEN process_id IN (12257, 12318) THEN
            CASE
                WHEN CONVERT(status_name USING utf8mb4) = 'Completed' AND TIMESTAMPDIFF(DAY, end_time, effective_date) <= 30 THEN 'Green'
                WHEN CONVERT(status_name USING utf8mb4) IN ('Not Completed', 'Additional information needed – Pending') AND TIMESTAMPDIFF(DAY, NOW(), effective_date) <= 30 THEN 'Green'
                ELSE 'Red'
            END
        WHEN process_id IN (5167, 1179, 16959, 16963) THEN
            CASE
                WHEN CONVERT(status_name USING utf8mb4) = 'Completed' AND TIMESTAMPDIFF(DAY, end_time, effective_date) <= 10 THEN 'Green'
                WHEN CONVERT(status_name USING utf8mb4) IN ('Not Completed', 'Additional information needed – Pending') AND TIMESTAMPDIFF(DAY, NOW(), effective_date) <= 10 THEN 'Green'
                ELSE 'Red'
            END
        WHEN process_id IN (13214, 16685) THEN
            CASE
                WHEN CONVERT(status_name USING utf8mb4) = 'Completed' AND TIMESTAMPDIFF(DAY, received_date, end_time) <= 14 THEN 'Green'
                WHEN CONVERT(status_name USING utf8mb4) IN ('Not Completed', 'Additional information needed – Pending') AND TIMESTAMPDIFF(DAY, received_date, NOW()) <= 14 THEN 'Green'
                ELSE 'Red'
            END
        ELSE 'Ignore'
    END AS rule_status


FROM
    restorefinal.club_task_enriched_last_2_years
WHERE
    client_id = 89
AND project_id = 179
AND received_date <> '0000-00-00 00:00:00'
AND end_time <> '0000-00-00 00:00:00'
AND TIMESTAMPDIFF(HOUR,
received_date,
end_time) >= 0
AND received_date BETWEEN '{{ $json.body.recieved_date_from }}' AND '{{ $json.body.recieved_date_to }} 23:59:59'
AND status_name IN ('Completed', 'Not Completed', 'Additional information needed – Pending')
AND process_id NOT IN (
    2014,
-- Growpro New Business Rating Large
    2012,
-- Growpro New Business Rating Medium
    1062,
-- Growpro New Business Rating Small
    2002,
-- Program New Business Rating Large
    866,
-- Program New Business Rating Medium
    2000,
-- Program New Business Rating Small
    2601,
-- WC New Business Rating
    16676,
-- Stewardship Reports
    17240,
-- AmTrust New Business Rating_Large
    17238,
-- AmTrust New Business Rating_Medium
    17236,
-- AmTrust New Business Rating_Small
    17201,
-- Billing contact update
    868,
-- Other Activity
    3625
-- OTT-Miscellaneous
);
  ;
