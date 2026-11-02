CREATE DATABASE manufacturing_quality;
USE manufacturing_quality;

-- Make inspection_id as Primary Key
ALTER TABLE quality_inspections ADD PRIMARY KEY (inspection_id);

SELECT COUNT(*) AS total_records
FROM quality_inspections;
                           
SELECT COUNT(*) FROM quality_inspections WHERE defect_type = 'None';   

SELECT * FROM quality_inspections
LIMIT 5;

SELECT COUNT(*) AS records_after_2020
FROM quality_inspections
WHERE inspection_date > '2020-01-01';

SELECT
    YEAR(inspection_date) AS inspection_year,
    COUNT(*) AS total_records
FROM quality_inspections
GROUP BY YEAR(inspection_date)
ORDER BY inspection_year;
