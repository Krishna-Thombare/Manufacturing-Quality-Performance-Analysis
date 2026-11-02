-- -----------------------------------------------------------------------------
-- QUESTION 1: Which plants and production lines have the highest defect rates?
-- -----------------------------------------------------------------------------
SELECT
    plant_location,
    production_line,
    COUNT(*) AS total_inspections,
    SUM(sample_size) AS total_sampled_units,
    SUM(units_defective) AS total_defective_units,
    ROUND(SUM(units_defective) * 100.0 / NULLIF(SUM(sample_size), 0), 2) AS defect_rate_pct

FROM quality_inspections

WHERE sample_size > 0 AND units_defective IS NOT NULL
GROUP BY plant_location, production_line
ORDER BY defect_rate_pct DESC;

-- ----------------------------------------------------------------------------------------
-- KEY FINDINGS: 
-- 1. Hosur has the highest-risk production lines. -> defect rate = 3.24%
-- 2. Pune shows relatively strong quality performance. -> defect rate = 1.77%
-- 3. HSR-L2 has nearly twice the defect rate of PUN-L3. -> HSR-L2: 3.24% | PUN-L3: 1.77%
-- ----------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- QUESTION 2: Which machines and shifts show the poorest quality performance?
-- -----------------------------------------------------------------------------
SELECT
    plant_location,
    machine_id,
    shift,
    COUNT(*) AS total_inspections,
    SUM(sample_size) AS total_sampled_units,
    SUM(units_defective) AS total_defective_units,
    ROUND(SUM(units_defective) * 100.0 / NULLIF(SUM(sample_size), 0), 2) AS defect_rate_pct

FROM quality_inspections

WHERE sample_size > 0
  AND units_defective IS NOT NULL
  AND machine_id IS NOT NULL
  AND shift IS NOT NULL
  AND machine_id <> 'Unknown'
  AND shift <> 'Unknown'
  
GROUP BY plant_location, machine_id, shift
HAVING COUNT(*) >= 30
ORDER BY defect_rate_pct DESC;

-- ----------------------------------
-- Overall Shift Quality Performance
-- ----------------------------------
SELECT
    shift,
    COUNT(*) AS total_inspections,
    SUM(sample_size) AS total_sampled_units,
    SUM(units_defective) AS total_defective_units,
    ROUND(SUM(units_defective) * 100.0 / NULLIF(SUM(sample_size), 0), 2) AS defect_rate_pct

FROM quality_inspections

WHERE sample_size > 0
  AND units_defective IS NOT NULL
  AND shift IN ('Morning', 'Afternoon', 'Night')
  
GROUP BY shift
ORDER BY defect_rate_pct DESC;

-- ------------------------------------------------------------------------------------------------------
-- KEY FINDINGS: 
-- 1. HSR-L1-M2 at Night shift has 5.79% defect rate.
-- 2. Night shift has the highest defect rate (3.05%).
-- 3. Morning shift performs best with defect rate (1.95%)
-- 4. Afternoon shift has the most defective units (8,013) but lower defect rate than Night shift (2.34%)
-- ------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------
-- QUESTION 3: What are the most common defect types, severities, and root causes?
-- --------------------------------------------------------------------------------
-- Q3A: Defect Type and Severity Analysis

SELECT
    defect_type,
    defect_severity,
    COUNT(*) AS total_inspections

FROM quality_inspections

WHERE defect_type IS NOT NULL
  AND defect_type NOT IN ('No Defect', 'Unknown')
  AND defect_severity IS NOT NULL
  AND defect_severity NOT IN ('None', 'Unknown')

GROUP BY defect_type, defect_severity
ORDER BY total_inspections DESC;

-- -----------------------------
-- Q3B: Root Cause Distribution
-- -----------------------------
SELECT
    root_cause_category,
    COUNT(*) AS total_inspections

FROM quality_inspections

WHERE root_cause_category IS NOT NULL
  AND root_cause_category <> 'Unknown'
  
GROUP BY root_cause_category
ORDER BY total_inspections DESC;

-- ---------------------------------------------------------------------------------------------------------
-- KEY FINDINGS: 
-- 1. Surface Scratch (Minor) is the top recorded defect-severity combination, with 1,141 total inspections.
-- 2. Material related issues are the top root-cause category with 1,757 inspections.
-- ----------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------
-- QUESTION 4: Which suppliers are associated with higher defect rates?
-- ---------------------------------------------------------------------
SELECT
    supplier_name,
    COUNT(*) AS total_inspections,
    SUM(sample_size) AS total_sampled_units,
    SUM(units_defective) AS total_defective_units,
    ROUND(SUM(units_defective) * 100.0 / NULLIF(SUM(sample_size), 0), 2) AS defect_rate_pct

FROM quality_inspections

WHERE sample_size > 0
  AND units_defective IS NOT NULL
  AND supplier_name IS NOT NULL
  AND supplier_name NOT IN ('Unknown', 'Not Applicable')
  
GROUP BY supplier_name
HAVING COUNT(*) >= 30
ORDER BY defect_rate_pct DESC;

-- -----------------------------------------------------------------------------------------------------
-- KEY FINDINGS: 
-- 1. Orion Fasteners (3.14%) and Gamma Plastics (3.12%) have the highest defect rates.
-- 2. Apex Castings (1.49%) has the lowest defect rate, followed by Bharat Precision Components (1.60%).
-- ------------------------------------------------------------------------------------------------------


-- -------------------------------------------------------------
-- QUESTION 5: How is manufacturing quality changing over time?
-- -------------------------------------------------------------
SELECT
    DATE_FORMAT(inspection_date, '%Y-%m') AS inspection_month,
    COUNT(*) AS total_inspections,
    SUM(sample_size) AS total_sampled_units,
    SUM(units_defective) AS total_defective_units,
    ROUND(SUM(units_defective) * 100.0 / NULLIF(SUM(sample_size), 0), 2) AS defect_rate_pct,
    SUM(CASE WHEN inspection_result = 'Fail' THEN 1 ELSE 0 END) AS failed_inspections,
    SUM(CASE WHEN inspection_result = 'Rework' THEN 1 ELSE 0 END) AS rework_inspections

FROM quality_inspections

WHERE inspection_date IS NOT NULL
  AND sample_size > 0
  AND units_defective IS NOT NULL

GROUP BY DATE_FORMAT(inspection_date, '%Y-%m')
ORDER BY inspection_month;

-- ------------------------------------------------------------------------------------------------------------------------------
-- KEY FINDINGS: 
-- 1. May 2026 the highest defect rate (2.52%), defective units (2,172), failed inspections (335), and rework inspections (328).
-- 2. December 2025 performed best, recording the lowest defect rate of 2.16%.
-- ------------------------------------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------
-- QUESTION 6: Which plants and production lines contribute most to rework and scrap costs?
-- -----------------------------------------------------------------------------------------
SELECT
    plant_location,
    production_line,
    COUNT(*) AS total_inspections,
    ROUND(SUM(rework_cost_inr), 2) AS total_rework_cost,
    ROUND(SUM(scrap_cost_inr), 2) AS total_scrap_cost,
    ROUND(SUM(rework_cost_inr) + SUM(scrap_cost_inr), 2) AS total_quality_cost

FROM quality_inspections

WHERE rework_cost_inr IS NOT NULL
  AND scrap_cost_inr IS NOT NULL
GROUP BY plant_location, production_line
ORDER BY total_quality_cost DESC;

-- ------------------------------------------------------------------------------------------------------------------------------
-- KEY FINDINGS: 
-- 1. Pune's PUN-L4 has the highest total quality cost (₹11.85 lakh) with scrap costs of ₹10.79 lakh.
-- 2. CSN-L2 has the lowest total quality cost (₹6.18 lakh).
-- ------------------------------------------------------------------------------------------------------------------------------