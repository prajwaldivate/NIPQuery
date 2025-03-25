SELECT
    p.name AS process_name,
    ts.received_date AS received_date,
    s.name AS status_name,
    TIMESTAMPDIFF(DAY, ts.received_date, ts.end_timestamp) AS time_diff_days,
    TIMESTAMPDIFF(HOUR, ts.received_date, ts.end_timestamp) AS time_diff_hours,
    -- Updated Rule Logic
    CASE
        -- "Completed" Status (s.id = 5)
        WHEN s.id = 5 THEN 
            CASE 
                WHEN p.rule_type = 'Received Date' 
                    AND TIMESTAMPDIFF(HOUR, ts.received_date, ts.end_timestamp) <= p.expected_tat_hrs 
                THEN 'Green'

                WHEN p.rule_type = 'Date Received' 
                    AND TIMESTAMPDIFF(HOUR, ts.start_timestamp, ts.end_timestamp) <= p.expected_tat_hrs 
                THEN 'Green'
                
                WHEN p.rule_type = 'Effective Date in Future' 
                    AND TIMESTAMPDIFF(HOUR, ts.end_timestamp, ts.effective_date) > p.expected_tat_hrs 
                THEN 'Green'

                WHEN p.rule_type = 'Effective Date in Past' 
                    AND TIMESTAMPDIFF(HOUR, ts.effective_date, ts.end_timestamp) > p.expected_tat_hrs 
                THEN 'Green'

                ELSE 'Red'
            END

        -- "Not Completed" or "Pending Additional Information" (s.id IN (10,6))
        WHEN s.id IN (10,6) THEN 
            CASE
                WHEN p.rule_type = 'Received Date' 
                    AND TIMESTAMPDIFF(HOUR, ts.received_date, NOW()) <= p.expected_tat_hrs 
                THEN 'Green'

                WHEN p.rule_type = 'Date Received' 
                    AND TIMESTAMPDIFF(HOUR, ts.start_timestamp, NOW()) <= p.expected_tat_hrs 
                THEN 'Green'

                WHEN p.rule_type = 'Effective Date in Future' 
                    AND TIMESTAMPDIFF(HOUR, NOW(), ts.effective_date) > p.expected_tat_hrs 
                THEN 'Green'

                WHEN p.rule_type = 'Effective Date in Past' 
                    AND TIMESTAMPDIFF(HOUR, ts.effective_date, NOW()) > p.expected_tat_hrs
                THEN 'Green'

                ELSE 'Red'
            END

        ELSE 'Ignore'
    END AS rule_status
FROM
    timesheets ts
JOIN statuses s 
    ON ts.status_id = s.id
JOIN processes p 
    ON ts.process_id = p.id
WHERE
    ts.project_id = 29
    AND ts.record_type = 1
    AND ts.received_date BETWEEN $1 AND '$2 23:59:59'
    AND ts.received_date IS NOT NULL
    AND ts.end_timestamp IS NOT NULL
    AND s.id IN (5,6,10)
