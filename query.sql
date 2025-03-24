SELECT
    `p`.`name` AS `process_name`,
    `ts`.`received_date` AS `received_date`,
    `s`.`name` AS `status_name`,
    TIMESTAMPDIFF(DAY, `ts`.`received_date`, `ts`.`end_timestamp`) AS `time_diff_days`,
    TIMESTAMPDIFF(HOUR, `ts`.`received_date`, `ts`.`end_timestamp`) AS `time_diff_hours`,
    CASE
        -- For "Completed" status: Check time between start and end timestamps
        WHEN `s`.`id` = 5 AND 
             TIMESTAMPDIFF(HOUR, `ts`.`start_timestamp`, `ts`.`end_timestamp`) <= `p`.`expected_tat_hrs` 
             THEN 'Green'
        -- For pending statuses: Check time from start to NOW()
        WHEN `s`.`id` IN (10,6) AND 
             TIMESTAMPDIFF(HOUR, `ts`.`start_timestamp`, NOW()) <= `p`.`expected_tat_hrs` 
             THEN 'Green'
        ELSE 'Red'
    END AS `rule_status`
FROM
    `timesheets` `ts`
JOIN `statuses` `s` 
    ON `ts`.`status_id` = `s`.`id`
JOIN `processes` `p` 
    ON `ts`.`process_id` = `p`.`id`  -- Link to new 3.x process IDs
WHERE
    `ts`.`project_id` = 29
    AND `ts`.`record_type` = 1
    AND `ts`.`received_date` IS NOT NULL
    AND `ts`.`end_timestamp` IS NOT NULL
    AND `ts`.`received_date` BETWEEN '{{ $json.body.recieved_date_from }}' AND '{{ $json.body.recieved_date_to }} 23:59:59'
    AND `ts`.`end_timestamp` <> '0000-00-00 00:00:00'
    AND `ts`.`received_date` <> '0000-00-00 00:00:00'
    AND `s`.`id` IN (5,6,10)
    -- Excluded processes (using new 3.x IDs from your mapping table)
    AND `p`.`id` NOT IN (
        593, 596, 645, 646, 647, 648, 677  -- Example: Growpro/Program Renewal Ratings, etc.
    );
