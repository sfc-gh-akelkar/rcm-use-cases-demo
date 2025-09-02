-- ===================================================================
-- RCM Real-Time Denial Prevention Engine - Sample Data
-- Run this third in Snowsight (after 02_tables.sql)
-- ===================================================================

USE DATABASE RCM_DENIAL_PREVENTION;
USE WAREHOUSE ANALYTICS_WH;

-- ===================================================================
-- SAMPLE DATA - RAW DATA TABLES
-- ===================================================================

USE SCHEMA RAW_DATA;

-- Insert sample payers
INSERT INTO payers (payer_id, payer_name, payer_type, avg_processing_time_days, historical_denial_rate, payment_terms, contact_info) 
SELECT 
    payer_id, 
    payer_name, 
    payer_type, 
    avg_processing_time_days, 
    historical_denial_rate, 
    payment_terms,
    OBJECT_CONSTRUCT('phone', phone, 'email', email) as contact_info
FROM VALUES
('PAY001', 'BlueCross BlueShield', 'Commercial', 14, 0.0680, 'Net 30', '1-800-555-0101', 'claims@bcbs.com'),
('PAY002', 'Aetna', 'Commercial', 12, 0.0720, 'Net 30', '1-800-555-0102', 'claims@aetna.com'),
('PAY003', 'Cigna', 'Commercial', 16, 0.0650, 'Net 45', '1-800-555-0103', 'claims@cigna.com'),
('PAY004', 'Humana', 'Commercial', 18, 0.0780, 'Net 30', '1-800-555-0104', 'claims@humana.com'),
('PAY005', 'UnitedHealthcare', 'Commercial', 10, 0.0590, 'Net 30', '1-800-555-0105', 'claims@uhc.com'),
('PAY006', 'Medicare', 'Government', 21, 0.0450, 'Net 14', '1-800-555-0106', 'claims@medicare.gov'),
('PAY007', 'Medicaid', 'Government', 28, 0.0850, 'Net 45', '1-800-555-0107', 'claims@medicaid.gov')
AS t(payer_id, payer_name, payer_type, avg_processing_time_days, historical_denial_rate, payment_terms, phone, email);

-- Insert sample providers
INSERT INTO providers (provider_id, provider_name, provider_type, specialty, npi, historical_denial_rate, volume_last_30_days, credentialing_status) VALUES
('PROV001', 'Metro General Hospital', 'Hospital', 'Multi-Specialty', '1234567890', 0.0520, 1250, 'Active'),
('PROV002', 'City Medical Center', 'Hospital', 'Multi-Specialty', '1234567891', 0.0680, 980, 'Active'),
('PROV003', 'Advanced Orthopedic Specialists', 'Clinic', 'Orthopedics', '1234567892', 0.0450, 450, 'Active'),
('PROV004', 'Family Health Associates', 'Clinic', 'Family Medicine', '1234567893', 0.0380, 650, 'Active'),
('PROV005', 'Regional Imaging Center', 'Diagnostic', 'Radiology', '1234567894', 0.0320, 850, 'Active'),
('PROV006', 'Westside Surgery Center', 'Surgery Center', 'Surgery', '1234567895', 0.0580, 320, 'Active'),
('PROV007', 'Community Lab Services', 'Laboratory', 'Laboratory', '1234567896', 0.0280, 1100, 'Active');

-- Insert sample patients (using individual INSERT statements to avoid VALUES clause limitations)
INSERT INTO patients (patient_id, age, gender, zip_code, insurance_type, chronic_conditions, previous_denials) 
SELECT 'PAT001', 45, 'Female', '10001', 'Commercial', ARRAY_CONSTRUCT('Diabetes', 'Hypertension'), 2;

INSERT INTO patients (patient_id, age, gender, zip_code, insurance_type, chronic_conditions, previous_denials) 
SELECT 'PAT002', 67, 'Male', '10002', 'Medicare', ARRAY_CONSTRUCT('COPD', 'Heart Disease'), 1;

INSERT INTO patients (patient_id, age, gender, zip_code, insurance_type, chronic_conditions, previous_denials) 
SELECT 'PAT003', 34, 'Female', '10003', 'Commercial', ARRAY_CONSTRUCT(), 0;

INSERT INTO patients (patient_id, age, gender, zip_code, insurance_type, chronic_conditions, previous_denials) 
SELECT 'PAT004', 28, 'Male', '10004', 'Commercial', ARRAY_CONSTRUCT('Asthma'), 1;

INSERT INTO patients (patient_id, age, gender, zip_code, insurance_type, chronic_conditions, previous_denials) 
SELECT 'PAT005', 52, 'Female', '10005', 'Commercial', ARRAY_CONSTRUCT('Arthritis', 'Depression'), 3;

INSERT INTO patients (patient_id, age, gender, zip_code, insurance_type, chronic_conditions, previous_denials) 
SELECT 'PAT006', 71, 'Male', '10006', 'Medicare', ARRAY_CONSTRUCT('Diabetes', 'Kidney Disease'), 2;

INSERT INTO patients (patient_id, age, gender, zip_code, insurance_type, chronic_conditions, previous_denials) 
SELECT 'PAT007', 39, 'Female', '10007', 'Medicaid', ARRAY_CONSTRUCT('Anxiety'), 4;

INSERT INTO patients (patient_id, age, gender, zip_code, insurance_type, chronic_conditions, previous_denials) 
SELECT 'PAT008', 25, 'Male', '10008', 'Commercial', ARRAY_CONSTRUCT(), 0;

INSERT INTO patients (patient_id, age, gender, zip_code, insurance_type, chronic_conditions, previous_denials) 
SELECT 'PAT009', 58, 'Female', '10009', 'Commercial', ARRAY_CONSTRUCT('Cancer History'), 1;

INSERT INTO patients (patient_id, age, gender, zip_code, insurance_type, chronic_conditions, previous_denials) 
SELECT 'PAT010', 63, 'Male', '10010', 'Medicare', ARRAY_CONSTRUCT('Heart Disease', 'Diabetes'), 2;

-- Insert sample claims
INSERT INTO claims_data (claim_id, patient_id, provider_id, payer_id, claim_amount, service_date, submission_date, diagnosis_code, procedure_code, prior_auth_required, prior_auth_status, claim_status, denial_reason) VALUES
('CLM001', 'PAT001', 'PROV001', 'PAY001', 2500.00, '2024-11-15', '2024-11-16 09:30:00', 'E11.9', '99214', TRUE, 'APPROVED', 'SUBMITTED', NULL),
('CLM002', 'PAT002', 'PROV002', 'PAY006', 1200.00, '2024-11-16', '2024-11-17 14:20:00', 'J44.1', '94010', FALSE, NULL, 'PAID', NULL),
('CLM003', 'PAT003', 'PROV003', 'PAY002', 8500.00, '2024-11-17', '2024-11-18 11:45:00', 'M17.11', '27447', TRUE, 'PENDING', 'SUBMITTED', NULL),
('CLM004', 'PAT004', 'PROV004', 'PAY001', 350.00, '2024-11-18', '2024-11-19 08:15:00', 'Z00.00', '99214', FALSE, NULL, 'PAID', NULL),
('CLM005', 'PAT005', 'PROV005', 'PAY003', 1800.00, '2024-11-19', '2024-11-20 16:30:00', 'R91.1', '74176', FALSE, NULL, 'DENIED', 'Missing Documentation'),
('CLM006', 'PAT006', 'PROV001', 'PAY006', 4200.00, '2024-11-20', '2024-11-21 10:00:00', 'I25.10', '93458', TRUE, 'APPROVED', 'PAID', NULL),
('CLM007', 'PAT007', 'PROV004', 'PAY007', 280.00, '2024-11-21', '2024-11-22 13:45:00', 'F41.1', '90834', FALSE, NULL, 'SUBMITTED', NULL),
('CLM008', 'PAT008', 'PROV006', 'PAY005', 12000.00, '2024-11-22', '2024-11-23 07:20:00', 'K80.20', '47563', TRUE, 'APPROVED', 'PAID', NULL),
('CLM009', 'PAT009', 'PROV005', 'PAY002', 950.00, '2024-11-23', '2024-11-24 15:10:00', 'C78.00', '71250', FALSE, NULL, 'SUBMITTED', NULL),
('CLM010', 'PAT010', 'PROV002', 'PAY006', 3200.00, '2024-11-24', '2024-11-25 12:30:00', 'I21.9', '93010', FALSE, NULL, 'PAID', NULL);

-- Insert payer policies (using individual INSERT statements to avoid VALUES clause limitations)
INSERT INTO payer_policies (policy_id, payer_id, procedure_code, prior_auth_required, documentation_requirements, coverage_limitations, effective_date, expiration_date) 
SELECT 'POL001', 'PAY001', '27447', TRUE, ARRAY_CONSTRUCT('X-rays', 'MRI', 'Conservative Treatment Documentation'), OBJECT_CONSTRUCT('max_amount', 15000), '2024-01-01', '2024-12-31';

INSERT INTO payer_policies (policy_id, payer_id, procedure_code, prior_auth_required, documentation_requirements, coverage_limitations, effective_date, expiration_date) 
SELECT 'POL002', 'PAY002', '93458', TRUE, ARRAY_CONSTRUCT('Stress Test', 'Echo', 'Clinical Notes'), OBJECT_CONSTRUCT('max_amount', 8000), '2024-01-01', '2024-12-31';

INSERT INTO payer_policies (policy_id, payer_id, procedure_code, prior_auth_required, documentation_requirements, coverage_limitations, effective_date, expiration_date) 
SELECT 'POL003', 'PAY003', '74176', FALSE, ARRAY_CONSTRUCT('Clinical Indication'), OBJECT_CONSTRUCT('max_amount', 2500), '2024-01-01', '2024-12-31';

INSERT INTO payer_policies (policy_id, payer_id, procedure_code, prior_auth_required, documentation_requirements, coverage_limitations, effective_date, expiration_date) 
SELECT 'POL004', 'PAY005', '47563', TRUE, ARRAY_CONSTRUCT('Ultrasound', 'HIDA Scan', 'Surgical Consultation'), OBJECT_CONSTRUCT('max_amount', 20000), '2024-01-01', '2024-12-31';

INSERT INTO payer_policies (policy_id, payer_id, procedure_code, prior_auth_required, documentation_requirements, coverage_limitations, effective_date, expiration_date) 
SELECT 'POL005', 'PAY006', '99214', FALSE, ARRAY_CONSTRUCT(), OBJECT_CONSTRUCT('max_visits_per_year', 12), '2024-01-01', '2024-12-31';

-- ===================================================================
-- SAMPLE DATA - PROCESSED DATA TABLES
-- ===================================================================

USE SCHEMA PROCESSED_DATA;

-- Insert sample risk scores (using individual INSERT statements to avoid VALUES clause limitations)
INSERT INTO PROCESSED_DATA.claim_risk_scores (claim_id, denial_probability, risk_factors, confidence_score, model_version, intervention_recommended, estimated_savings) 
SELECT 'CLM001', 0.234, ARRAY_CONSTRUCT('Prior Auth Approved', 'Provider History Good'), 0.8742, 'v1.2.1', FALSE, 0.00;

INSERT INTO PROCESSED_DATA.claim_risk_scores (claim_id, denial_probability, risk_factors, confidence_score, model_version, intervention_recommended, estimated_savings) 
SELECT 'CLM002', 0.156, ARRAY_CONSTRUCT('Government Payer', 'Simple Procedure'), 0.9123, 'v1.2.1', FALSE, 0.00;

INSERT INTO PROCESSED_DATA.claim_risk_scores (claim_id, denial_probability, risk_factors, confidence_score, model_version, intervention_recommended, estimated_savings) 
SELECT 'CLM003', 0.678, ARRAY_CONSTRUCT('High Value Claim', 'Prior Auth Pending'), 0.7865, 'v1.2.1', TRUE, 5780.00;

INSERT INTO PROCESSED_DATA.claim_risk_scores (claim_id, denial_probability, risk_factors, confidence_score, model_version, intervention_recommended, estimated_savings) 
SELECT 'CLM004', 0.089, ARRAY_CONSTRUCT('Routine Visit', 'Low Amount'), 0.9456, 'v1.2.1', FALSE, 0.00;

INSERT INTO PROCESSED_DATA.claim_risk_scores (claim_id, denial_probability, risk_factors, confidence_score, model_version, intervention_recommended, estimated_savings) 
SELECT 'CLM005', 0.892, ARRAY_CONSTRUCT('Missing Documentation', 'Historical Denials'), 0.8234, 'v1.2.1', TRUE, 1440.00;

INSERT INTO PROCESSED_DATA.claim_risk_scores (claim_id, denial_probability, risk_factors, confidence_score, model_version, intervention_recommended, estimated_savings) 
SELECT 'CLM006', 0.123, ARRAY_CONSTRUCT('Prior Auth Approved', 'Medicare'), 0.8967, 'v1.2.1', FALSE, 0.00;

INSERT INTO PROCESSED_DATA.claim_risk_scores (claim_id, denial_probability, risk_factors, confidence_score, model_version, intervention_recommended, estimated_savings) 
SELECT 'CLM007', 0.345, ARRAY_CONSTRUCT('Medicaid', 'Mental Health'), 0.7654, 'v1.2.1', FALSE, 0.00;

INSERT INTO PROCESSED_DATA.claim_risk_scores (claim_id, denial_probability, risk_factors, confidence_score, model_version, intervention_recommended, estimated_savings) 
SELECT 'CLM008', 0.234, ARRAY_CONSTRUCT('Prior Auth Approved', 'High Volume Provider'), 0.8876, 'v1.2.1', FALSE, 0.00;

INSERT INTO PROCESSED_DATA.claim_risk_scores (claim_id, denial_probability, risk_factors, confidence_score, model_version, intervention_recommended, estimated_savings) 
SELECT 'CLM009', 0.445, ARRAY_CONSTRUCT('Cancer Diagnosis', 'Imaging'), 0.8123, 'v1.2.1', TRUE, 475.00;

INSERT INTO PROCESSED_DATA.claim_risk_scores (claim_id, denial_probability, risk_factors, confidence_score, model_version, intervention_recommended, estimated_savings) 
SELECT 'CLM010', 0.167, ARRAY_CONSTRUCT('Emergency', 'Medicare'), 0.9234, 'v1.2.1', FALSE, 0.00;

-- Insert high-risk alerts
INSERT INTO PROCESSED_DATA.high_risk_alerts (claim_id, risk_score, alert_type, priority_level, alert_message, assigned_to) VALUES
('CLM003', 0.678, 'PRIOR_AUTH_PENDING', 'HIGH', 'High-value orthopedic procedure with pending prior authorization', 'Prior Auth Team'),
('CLM005', 0.892, 'DOCUMENTATION_MISSING', 'CRITICAL', 'Imaging claim missing required documentation - high denial risk', 'Documentation Team'),
('CLM009', 0.445, 'DIAGNOSIS_REVIEW', 'MEDIUM', 'Cancer-related imaging may need additional clinical correlation', 'Clinical Review Team');

-- Insert interventions (using individual INSERT statements to avoid VALUES clause limitations)
INSERT INTO PROCESSED_DATA.claim_interventions (claim_id, intervention_type, intervention_details, recommended_by, status, outcome) 
SELECT 'CLM003', 'EXPEDITE_PRIOR_AUTH', OBJECT_CONSTRUCT('action', 'Contact payer for expedited review', 'contact_method', 'phone'), 'ML Model v1.2.1', 'APPLIED', 'IN_PROGRESS';

INSERT INTO PROCESSED_DATA.claim_interventions (claim_id, intervention_type, intervention_details, recommended_by, status, outcome) 
SELECT 'CLM005', 'REQUEST_DOCUMENTATION', OBJECT_CONSTRUCT('action', 'Request missing radiology report from provider', 'documents_needed', 'Clinical indication, comparison studies'), 'ML Model v1.2.1', 'APPLIED', 'COMPLETED';

INSERT INTO PROCESSED_DATA.claim_interventions (claim_id, intervention_type, intervention_details, recommended_by, status, outcome) 
SELECT 'CLM009', 'CLINICAL_REVIEW', OBJECT_CONSTRUCT('action', 'Route to clinical team for medical necessity review', 'reviewer', 'Dr. Smith'), 'ML Model v1.2.1', 'PENDING', NULL;

-- ===================================================================
-- SAMPLE DATA - ENHANCED ANALYTICS TABLES
-- ===================================================================

USE SCHEMA ANALYTICS;

-- Collections performance data
INSERT INTO ANALYTICS.collections_performance (
    patient_id, outstanding_balance, days_outstanding, payment_probability,
    recommended_strategy, collection_attempts, last_contact_date, 
    payment_plan_eligible, estimated_recovery_amount
) VALUES
('PAT001', 2500.00, 45, 0.85, 'Phone + Email', 3, '2024-11-15', TRUE, 2125.00),
('PAT002', 1200.00, 120, 0.65, 'Payment Plan', 5, '2024-10-10', TRUE, 780.00),
('PAT003', 890.00, 30, 0.78, 'Email + Text', 2, '2024-11-20', FALSE, 695.00),
('PAT004', 5600.00, 90, 0.72, 'Family Contact', 4, '2024-09-15', TRUE, 4032.00),
('PAT005', 750.00, 15, 0.92, 'Digital Only', 1, '2024-12-01', FALSE, 690.00);

-- Contract scenarios
INSERT INTO ANALYTICS.contract_scenarios (
    scenario_name, payer_id, contract_type, base_reimbursement_rate,
    quality_bonus_percentage, risk_adjustment_factor, estimated_annual_volume,
    projected_revenue_impact, risk_level, implementation_date, created_by
) VALUES
('BlueCross Value-Based 2025', 'PAY001', 'Value-Based', 108.50, 12.0, 1.0250, 2500, 325000.00, 'Medium', '2025-01-01', 'Contract Team'),
('Medicare Advantage Bundle', 'PAY006', 'Bundled Payment', 95.75, 8.5, 0.9850, 3200, -48000.00, 'High', '2025-03-01', 'Contract Team'),
('Aetna Premium Network', 'PAY002', 'Fee-for-Service', 115.25, 5.0, 1.0150, 1800, 275400.00, 'Low', '2025-02-01', 'Contract Team');

-- Workforce productivity
INSERT INTO ANALYTICS.workforce_productivity (
    employee_id, employee_name, department, role_title, claims_processed_daily,
    accuracy_rate, processing_time_avg_minutes, productivity_score,
    training_hours_completed, performance_trend, last_evaluation_date, manager_feedback
) VALUES
('EMP001', 'Sarah Mitchell', 'Claims Processing', 'Senior Claims Specialist', 186, 0.9850, 8.2, 92.5, 24.5, 'Improving', '2024-11-15', 'Excellent performer'),
('EMP002', 'John Davis', 'Claims Processing', 'Claims Specialist', 162, 0.9680, 9.8, 78.3, 18.0, 'Stable', '2024-11-10', 'Solid performer'),
('EMP003', 'Lisa Kim', 'Claims Processing', 'Lead Claims Specialist', 198, 0.9910, 7.5, 95.2, 32.0, 'Excellent', '2024-11-20', 'Top performer');

-- Process bottlenecks
INSERT INTO ANALYTICS.process_bottlenecks (
    process_step, department, avg_processing_time_minutes, bottleneck_score,
    volume_processed_daily, error_rate, improvement_opportunity,
    recommended_action, estimated_time_savings, implementation_effort
) VALUES
('Claims Entry', 'Claims Processing', 8.5, 3, 1200, 0.0250, 'Medium', 'Implement auto-data entry', 2.1, 'Medium'),
('Prior Authorization', 'Prior Authorization', 25.6, 9, 350, 0.0320, 'Critical', 'Automate payer lookups', 8.5, 'High'),
('Payment Follow-up', 'Collections', 15.8, 7, 600, 0.0280, 'High', 'Predictive payment alerts', 5.2, 'Medium');

-- Entity performance
INSERT INTO ANALYTICS.entity_performance (
    entity_name, entity_type, acquisition_date, integration_status,
    data_migration_percentage, ytd_revenue, denial_rate, collection_rate,
    staff_count, optimization_potential, integration_complexity,
    synergy_opportunities, estimated_synergy_value, parent_organization_id
) VALUES
('Metro General Hospital', 'Hospital', '2022-06-15', 'Complete', 100.00, 45200000.00, 0.0520, 0.8650, 450, 'Low', 'Low', 
 ARRAY_CONSTRUCT('Workflow Standardization', 'Technology Upgrade'), 1200000.00, 'ORG001'),
('Westside Family Clinic', 'Clinic', '2023-03-20', 'In Progress', 75.00, 8700000.00, 0.0810, 0.7920, 85, 'Medium', 'Medium',
 ARRAY_CONSTRUCT('Process Optimization', 'Staff Training'), 850000.00, 'ORG001');

-- Synergy tracking
INSERT INTO ANALYTICS.synergy_tracking (
    entity_id, synergy_type, description, estimated_savings, actual_savings,
    implementation_status, start_date, target_completion_date,
    implementation_effort, roi_percentage, responsible_team, progress_notes
) VALUES
('ENT001', 'Workflow Standardization', 'Standardize claims processing workflows', 800000.00, 650000.00, 'Complete', '2023-01-01', '2023-06-30', 'Medium', 162.5, 'Operations Team', 'Delivered results'),
('ENT002', 'Technology Integration', 'Integrate EHR systems for data consistency', 1200000.00, 950000.00, 'In Progress', '2023-06-01', '2024-03-31', 'High', 190.0, 'IT Team', 'On track');

-- ===================================================================
-- VERIFICATION
-- ===================================================================

-- Count records in each table
SELECT 'Claims Data: ' || COUNT(*) as summary FROM RAW_DATA.claims_data
UNION ALL
SELECT 'Patients: ' || COUNT(*) FROM RAW_DATA.patients
UNION ALL
SELECT 'Providers: ' || COUNT(*) FROM RAW_DATA.providers
UNION ALL
SELECT 'Payers: ' || COUNT(*) FROM RAW_DATA.payers
UNION ALL
SELECT 'Risk Scores: ' || COUNT(*) FROM PROCESSED_DATA.claim_risk_scores
UNION ALL
SELECT 'High Risk Alerts: ' || COUNT(*) FROM PROCESSED_DATA.high_risk_alerts
UNION ALL
SELECT 'Interventions: ' || COUNT(*) FROM PROCESSED_DATA.claim_interventions
UNION ALL
SELECT 'Collections Performance: ' || COUNT(*) FROM ANALYTICS.collections_performance
UNION ALL
SELECT 'Contract Scenarios: ' || COUNT(*) FROM ANALYTICS.contract_scenarios
UNION ALL
SELECT 'Workforce Productivity: ' || COUNT(*) FROM ANALYTICS.workforce_productivity
UNION ALL
SELECT 'Process Bottlenecks: ' || COUNT(*) FROM ANALYTICS.process_bottlenecks
UNION ALL
SELECT 'Entity Performance: ' || COUNT(*) FROM ANALYTICS.entity_performance
UNION ALL
SELECT 'Synergy Tracking: ' || COUNT(*) FROM ANALYTICS.synergy_tracking;

SELECT 'Sample data loaded successfully!' as STATUS;
