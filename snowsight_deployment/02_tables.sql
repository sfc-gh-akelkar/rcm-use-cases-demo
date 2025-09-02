-- ===================================================================
-- RCM Real-Time Denial Prevention Engine - Table Creation
-- Run this second in Snowsight (after 01_setup.sql)
-- ===================================================================

USE DATABASE QUADAX_DENIAL_PREVENTION;
USE WAREHOUSE ANALYTICS_WH;

-- ===================================================================
-- RAW DATA TABLES
-- ===================================================================

USE SCHEMA RAW_DATA;

-- Main claims table
CREATE OR REPLACE TABLE claims_data (
    claim_id VARCHAR PRIMARY KEY,
    patient_id VARCHAR,
    provider_id VARCHAR,
    payer_id VARCHAR,
    claim_amount DECIMAL(18, 2),
    service_date DATE,
    submission_date TIMESTAMP_NTZ,
    diagnosis_code VARCHAR,
    procedure_code VARCHAR,
    prior_auth_required BOOLEAN,
    prior_auth_status VARCHAR,
    claim_status VARCHAR,
    denial_reason VARCHAR,
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Patient demographics
CREATE OR REPLACE TABLE patients (
    patient_id VARCHAR PRIMARY KEY,
    age INTEGER,
    gender VARCHAR(10),
    zip_code VARCHAR(10),
    insurance_type VARCHAR(50),
    chronic_conditions ARRAY,
    previous_denials INTEGER DEFAULT 0,
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Healthcare providers
CREATE OR REPLACE TABLE providers (
    provider_id VARCHAR PRIMARY KEY,
    provider_name VARCHAR(200),
    provider_type VARCHAR(50),
    specialty VARCHAR(100),
    npi VARCHAR(20),
    historical_denial_rate DECIMAL(5, 4),
    volume_last_30_days INTEGER,
    credentialing_status VARCHAR(20),
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Insurance payers
CREATE OR REPLACE TABLE payers (
    payer_id VARCHAR PRIMARY KEY,
    payer_name VARCHAR(200),
    payer_type VARCHAR(50),
    avg_processing_time_days INTEGER,
    historical_denial_rate DECIMAL(5, 4),
    payment_terms VARCHAR(50),
    contact_info OBJECT,
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Payer policies and requirements
CREATE OR REPLACE TABLE payer_policies (
    policy_id VARCHAR PRIMARY KEY,
    payer_id VARCHAR,
    procedure_code VARCHAR,
    prior_auth_required BOOLEAN,
    documentation_requirements ARRAY,
    coverage_limitations OBJECT,
    effective_date DATE,
    expiration_date DATE,
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ===================================================================
-- PROCESSED DATA TABLES
-- ===================================================================

USE SCHEMA PROCESSED_DATA;

-- Risk scores for claims
CREATE OR REPLACE TABLE claim_risk_scores (
    risk_id VARCHAR DEFAULT UUID_STRING() PRIMARY KEY,
    claim_id VARCHAR NOT NULL,
    denial_probability DECIMAL(8, 6),
    risk_factors ARRAY,
    confidence_score DECIMAL(5, 4),
    model_version VARCHAR,
    processing_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    intervention_recommended BOOLEAN DEFAULT FALSE,
    estimated_savings DECIMAL(12, 2)
);

-- High-risk alerts
CREATE OR REPLACE TABLE high_risk_alerts (
    alert_id VARCHAR DEFAULT UUID_STRING() PRIMARY KEY,
    claim_id VARCHAR NOT NULL,
    risk_score DECIMAL(8, 6),
    alert_type VARCHAR(50),
    priority_level VARCHAR(20),
    alert_message VARCHAR(500),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    assigned_to VARCHAR(100),
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    resolved_timestamp TIMESTAMP_NTZ
);

-- Claim interventions and outcomes
CREATE OR REPLACE TABLE claim_interventions (
    intervention_id VARCHAR DEFAULT UUID_STRING() PRIMARY KEY,
    claim_id VARCHAR NOT NULL,
    intervention_type VARCHAR(100),
    intervention_details OBJECT,
    recommended_by VARCHAR(50),
    status VARCHAR(20) DEFAULT 'PENDING',
    outcome VARCHAR(50),
    actual_impact DECIMAL(12, 2),
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    applied_timestamp TIMESTAMP_NTZ,
    completed_timestamp TIMESTAMP_NTZ
);

-- Collections performance data
CREATE OR REPLACE TABLE collections_performance (
    collection_id STRING DEFAULT UUID_STRING() PRIMARY KEY,
    patient_id STRING NOT NULL,
    outstanding_balance NUMBER(12,2),
    days_outstanding NUMBER(5,0),
    payment_probability NUMBER(5,4),
    recommended_strategy STRING,
    collection_attempts NUMBER(3,0),
    last_contact_date DATE,
    payment_plan_eligible BOOLEAN,
    collection_agency_assigned BOOLEAN,
    estimated_recovery_amount NUMBER(12,2),
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ===================================================================
-- ANALYTICS TABLES
-- ===================================================================

USE SCHEMA ANALYTICS;

-- Contract scenarios and simulations
CREATE OR REPLACE TABLE contract_scenarios (
    scenario_id STRING DEFAULT UUID_STRING() PRIMARY KEY,
    scenario_name STRING NOT NULL,
    payer_id STRING,
    contract_type STRING,
    base_reimbursement_rate NUMBER(5,2),
    quality_bonus_percentage NUMBER(5,2),
    risk_adjustment_factor NUMBER(5,4),
    estimated_annual_volume NUMBER(8,0),
    projected_revenue_impact NUMBER(12,2),
    risk_level STRING,
    implementation_date DATE,
    created_by STRING,
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Workforce productivity tracking
CREATE OR REPLACE TABLE workforce_productivity (
    productivity_id STRING DEFAULT UUID_STRING() PRIMARY KEY,
    employee_id STRING NOT NULL,
    employee_name STRING,
    department STRING,
    role_title STRING,
    claims_processed_daily NUMBER(5,0),
    accuracy_rate NUMBER(5,4),
    processing_time_avg_minutes NUMBER(5,2),
    productivity_score NUMBER(5,2),
    training_hours_completed NUMBER(5,1),
    performance_trend STRING,
    last_evaluation_date DATE,
    manager_feedback STRING,
    improvement_plan BOOLEAN DEFAULT FALSE,
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Process bottleneck tracking
CREATE OR REPLACE TABLE process_bottlenecks (
    bottleneck_id STRING DEFAULT UUID_STRING() PRIMARY KEY,
    process_step STRING NOT NULL,
    department STRING,
    avg_processing_time_minutes NUMBER(5,2),
    bottleneck_score NUMBER(3,0),
    volume_processed_daily NUMBER(6,0),
    error_rate NUMBER(5,4),
    improvement_opportunity STRING,
    recommended_action STRING,
    estimated_time_savings NUMBER(5,2),
    implementation_effort STRING,
    measurement_date DATE DEFAULT CURRENT_DATE(),
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Multi-entity performance tracking
CREATE OR REPLACE TABLE entity_performance (
    entity_id STRING DEFAULT UUID_STRING() PRIMARY KEY,
    entity_name STRING NOT NULL,
    entity_type STRING,
    acquisition_date DATE,
    integration_status STRING,
    data_migration_percentage NUMBER(5,2),
    ytd_revenue NUMBER(12,2),
    denial_rate NUMBER(5,4),
    collection_rate NUMBER(5,4),
    staff_count NUMBER(4,0),
    optimization_potential STRING,
    integration_complexity STRING,
    synergy_opportunities ARRAY,
    estimated_synergy_value NUMBER(12,2),
    parent_organization_id STRING,
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Synergy tracking and realization
CREATE OR REPLACE TABLE synergy_tracking (
    synergy_id STRING DEFAULT UUID_STRING() PRIMARY KEY,
    entity_id STRING,
    synergy_type STRING,
    description STRING,
    estimated_savings NUMBER(12,2),
    actual_savings NUMBER(12,2),
    implementation_status STRING,
    start_date DATE,
    target_completion_date DATE,
    actual_completion_date DATE,
    implementation_effort STRING,
    roi_percentage NUMBER(5,2),
    responsible_team STRING,
    progress_notes STRING,
    created_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ===================================================================
-- REFERENCE TABLES
-- ===================================================================

-- Provider directory
CREATE OR REPLACE TABLE provider_directory (
    directory_id VARCHAR DEFAULT UUID_STRING() PRIMARY KEY,
    provider_id VARCHAR NOT NULL,
    directory_source VARCHAR(50),
    verification_status VARCHAR(20),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Payer directory
CREATE OR REPLACE TABLE payer_directory (
    directory_id VARCHAR DEFAULT UUID_STRING() PRIMARY KEY,
    payer_id VARCHAR NOT NULL,
    contact_method VARCHAR(50),
    api_endpoint VARCHAR(200),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ===================================================================
-- AUDIT AND MONITORING TABLES
-- ===================================================================

-- Audit log
CREATE OR REPLACE TABLE audit_log (
    log_id VARCHAR DEFAULT UUID_STRING() PRIMARY KEY,
    table_name VARCHAR NOT NULL,
    operation VARCHAR(20),
    user_name VARCHAR(100),
    timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    old_values OBJECT,
    new_values OBJECT
);

-- Data quality monitoring
CREATE OR REPLACE TABLE data_quality_log (
    quality_id VARCHAR DEFAULT UUID_STRING() PRIMARY KEY,
    table_name VARCHAR NOT NULL,
    quality_check VARCHAR(100),
    check_result VARCHAR(20),
    issue_count INTEGER,
    check_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    details OBJECT
);

-- ===================================================================
-- CREATE STREAMS FOR REAL-TIME PROCESSING
-- ===================================================================

USE SCHEMA RAW_DATA;

-- Stream on claims data for real-time processing
CREATE OR REPLACE STREAM claims_stream ON TABLE claims_data;

-- Stream on risk scores for alerting
CREATE OR REPLACE STREAM risk_scores_stream ON TABLE PROCESSED_DATA.claim_risk_scores;

-- ===================================================================
-- VERIFICATION
-- ===================================================================

-- Count tables created
SELECT 
    SCHEMA_NAME,
    COUNT(*) as TABLE_COUNT
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_CATALOG = 'QUADAX_DENIAL_PREVENTION'
    AND TABLE_SCHEMA IN ('RAW_DATA', 'PROCESSED_DATA', 'ANALYTICS')
GROUP BY SCHEMA_NAME
ORDER BY SCHEMA_NAME;

SELECT 'All tables created successfully!' as STATUS;
