-- ===================================================================
-- RCM Real-Time Denial Prevention Engine - ML Model Deployment
-- Run this fourth in Snowsight (after 03_sample_data.sql)
-- ===================================================================

USE DATABASE QUADAX_DENIAL_PREVENTION;
USE WAREHOUSE ML_TRAINING_WH;

-- ===================================================================
-- STORED PROCEDURES FOR ML MODEL OPERATIONS
-- ===================================================================

USE SCHEMA ML_MODELS;

-- Stored procedure to calculate denial risk using ML model
CREATE OR REPLACE PROCEDURE sp_calculate_denial_risk()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('snowflake-snowpark-python', 'scikit-learn', 'pandas', 'numpy')
HANDLER = 'calculate_risk'
AS
$$
import snowflake.snowpark as snowpark
import pandas as pd
import numpy as np
from datetime import datetime
import json

def calculate_risk(session: snowpark.Session) -> str:
    """
    Calculate denial risk for new claims using ML model
    This is a simplified implementation for demonstration
    """
    try:
        # Check for new claims to process
        new_claims_df = session.table("RAW_DATA.claims_stream").to_pandas()
        
        if new_claims_df.empty:
            return "No new claims to process"
        
        # Feature engineering (simplified)
        features = []
        for _, claim in new_claims_df.iterrows():
            # Get provider history
            provider_history = session.sql(f"""
                SELECT historical_denial_rate, volume_last_30_days 
                FROM RAW_DATA.providers 
                WHERE provider_id = '{claim['PROVIDER_ID']}'
            """).to_pandas()
            
            # Get payer history
            payer_history = session.sql(f"""
                SELECT historical_denial_rate, avg_processing_time_days 
                FROM RAW_DATA.payers 
                WHERE payer_id = '{claim['PAYER_ID']}'
            """).to_pandas()
            
            # Get patient history
            patient_history = session.sql(f"""
                SELECT previous_denials, age 
                FROM RAW_DATA.patients 
                WHERE patient_id = '{claim['PATIENT_ID']}'
            """).to_pandas()
            
            # Simple risk calculation (in production, this would use trained ML model)
            base_risk = 0.1
            
            # Provider risk factor
            if not provider_history.empty:
                provider_risk = provider_history.iloc[0]['HISTORICAL_DENIAL_RATE'] or 0.05
            else:
                provider_risk = 0.05
                
            # Payer risk factor
            if not payer_history.empty:
                payer_risk = payer_history.iloc[0]['HISTORICAL_DENIAL_RATE'] or 0.05
            else:
                payer_risk = 0.05
                
            # Patient risk factor
            if not patient_history.empty:
                patient_risk = min(patient_history.iloc[0]['PREVIOUS_DENIALS'] * 0.1, 0.3)
            else:
                patient_risk = 0.0
            
            # Amount risk factor
            amount_risk = min(claim['CLAIM_AMOUNT'] / 100000, 0.2)  # Higher amounts = higher risk
            
            # Prior auth risk
            prior_auth_risk = 0.3 if claim['PRIOR_AUTH_REQUIRED'] and claim['PRIOR_AUTH_STATUS'] != 'APPROVED' else 0.0
            
            # Calculate final risk score
            risk_score = min(base_risk + provider_risk + payer_risk + patient_risk + amount_risk + prior_auth_risk, 0.95)
            
            # Determine risk factors
            risk_factors = []
            if provider_risk > 0.1:
                risk_factors.append('High Provider Denial Rate')
            if payer_risk > 0.1:
                risk_factors.append('High Payer Denial Rate')
            if patient_risk > 0.1:
                risk_factors.append('Patient History of Denials')
            if amount_risk > 0.1:
                risk_factors.append('High Claim Amount')
            if prior_auth_risk > 0:
                risk_factors.append('Prior Auth Issues')
                
            features.append({
                'claim_id': claim['CLAIM_ID'],
                'denial_probability': round(risk_score, 6),
                'risk_factors': risk_factors,
                'confidence_score': 0.85,  # Simulated confidence
                'intervention_recommended': risk_score > 0.6,
                'estimated_savings': claim['CLAIM_AMOUNT'] * 0.8 if risk_score > 0.6 else 0
            })
        
        # Insert risk scores
        for feature in features:
            session.sql(f"""
                INSERT INTO PROCESSED_DATA.claim_risk_scores 
                (claim_id, denial_probability, risk_factors, confidence_score, 
                 model_version, intervention_recommended, estimated_savings)
                VALUES ('{feature['claim_id']}', {feature['denial_probability']}, 
                        ARRAY_CONSTRUCT{tuple(feature['risk_factors']) if feature['risk_factors'] else '()'}, 
                        {feature['confidence_score']}, 'v1.2.1', 
                        {feature['intervention_recommended']}, {feature['estimated_savings']})
            """).collect()
            
            # Create high-risk alerts if needed
            if feature['denial_probability'] > 0.7:
                session.sql(f"""
                    INSERT INTO PROCESSED_DATA.high_risk_alerts 
                    (claim_id, risk_score, alert_type, priority_level, alert_message, assigned_to)
                    VALUES ('{feature['claim_id']}', {feature['denial_probability']}, 
                            'HIGH_RISK_CLAIM', 'HIGH', 
                            'Claim has high denial probability: {feature['denial_probability']:.3f}', 
                            'Claims Review Team')
                """).collect()
        
        return f"Processed {len(features)} claims with risk scores"
        
    except Exception as e:
        return f"Error processing claims: {str(e)}"
$$;

-- Stored procedure to send risk alerts
CREATE OR REPLACE PROCEDURE sp_send_risk_alerts()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
try {
    // Get active high-risk alerts
    var query = `
        SELECT alert_id, claim_id, risk_score, alert_message, assigned_to
        FROM PROCESSED_DATA.high_risk_alerts 
        WHERE status = 'ACTIVE' 
        AND created_timestamp > DATEADD(hour, -1, CURRENT_TIMESTAMP())
    `;
    
    var statement = snowflake.createStatement({sqlText: query});
    var resultSet = statement.execute();
    
    var alertCount = 0;
    while (resultSet.next()) {
        var alertId = resultSet.getColumnValue(1);
        var claimId = resultSet.getColumnValue(2);
        var riskScore = resultSet.getColumnValue(3);
        var alertMessage = resultSet.getColumnValue(4);
        var assignedTo = resultSet.getColumnValue(5);
        
        // In production, this would send actual notifications
        // For demo, we'll just log the alert
        alertCount++;
    }
    
    return `Sent ${alertCount} risk alerts`;
    
} catch (err) {
    return `Error sending alerts: ${err.message}`;
}
$$;

-- Stored procedure to apply interventions
CREATE OR REPLACE PROCEDURE sp_apply_intervention(claim_id STRING, intervention_type STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Update intervention status
    UPDATE PROCESSED_DATA.claim_interventions 
    SET status = 'APPLIED', applied_timestamp = CURRENT_TIMESTAMP()
    WHERE claim_id = :claim_id AND intervention_type = :intervention_type;
    
    -- Log the intervention application
    INSERT INTO PROCESSED_DATA.audit_log (table_name, operation, user_name, new_values)
    VALUES ('claim_interventions', 'UPDATE', CURRENT_USER(), 
            OBJECT_CONSTRUCT('claim_id', :claim_id, 'intervention_type', :intervention_type, 
                           'status', 'APPLIED', 'applied_timestamp', CURRENT_TIMESTAMP()));
    
    RETURN 'Intervention applied successfully';
END;
$$;

-- ===================================================================
-- TASKS FOR AUTOMATED PROCESSING
-- ===================================================================

-- Task to process new claims every 5 minutes
CREATE OR REPLACE TASK task_process_claims
    WAREHOUSE = REALTIME_PROCESSING_WH
    SCHEDULE = '5 MINUTE'
AS
    CALL sp_calculate_denial_risk();

-- Task to send alerts every 15 minutes
CREATE OR REPLACE TASK task_send_alerts
    WAREHOUSE = REALTIME_PROCESSING_WH
    SCHEDULE = '15 MINUTE'
    AFTER task_process_claims
AS
    CALL sp_send_risk_alerts();

-- ===================================================================
-- VIEWS FOR ANALYTICS
-- ===================================================================

USE SCHEMA ANALYTICS;

-- Real-time metrics view
CREATE OR REPLACE VIEW v_realtime_metrics AS
SELECT 
    COUNT(*) as total_claims_today,
    AVG(denial_probability) as avg_risk_score,
    COUNT(CASE WHEN denial_probability > 0.7 THEN 1 END) as high_risk_claims,
    COUNT(CASE WHEN denial_probability BETWEEN 0.3 AND 0.7 THEN 1 END) as medium_risk_claims,
    COUNT(CASE WHEN denial_probability < 0.3 THEN 1 END) as low_risk_claims,
    MAX(processing_timestamp) as last_processed_time,
    SUM(CASE WHEN intervention_recommended = TRUE THEN 1 ELSE 0 END) as interventions_recommended,
    AVG(CASE WHEN intervention_recommended = TRUE THEN estimated_savings ELSE 0 END) as avg_potential_savings
FROM PROCESSED_DATA.claim_risk_scores 
WHERE DATE(processing_timestamp) = CURRENT_DATE();

-- Performance analytics view
CREATE OR REPLACE VIEW v_performance_analytics AS
SELECT 
    p.payer_name,
    COUNT(c.claim_id) as total_claims,
    AVG(r.denial_probability) as avg_risk_score,
    COUNT(CASE WHEN c.claim_status = 'DENIED' THEN 1 END) as actual_denials,
    COUNT(CASE WHEN c.claim_status = 'DENIED' THEN 1 END) / COUNT(c.claim_id)::FLOAT as actual_denial_rate,
    AVG(CASE WHEN c.claim_status = 'DENIED' THEN r.denial_probability END) as avg_risk_of_denied_claims,
    SUM(CASE WHEN r.intervention_recommended AND c.claim_status != 'DENIED' THEN r.estimated_savings ELSE 0 END) as potential_savings_realized
FROM RAW_DATA.claims_data c
JOIN RAW_DATA.payers p ON c.payer_id = p.payer_id
LEFT JOIN PROCESSED_DATA.claim_risk_scores r ON c.claim_id = r.claim_id
WHERE c.submission_date >= DATEADD(day, -30, CURRENT_DATE())
GROUP BY p.payer_name;

-- Provider performance view
CREATE OR REPLACE VIEW v_provider_performance AS
SELECT 
    pr.provider_name,
    pr.specialty,
    COUNT(c.claim_id) as total_claims,
    AVG(r.denial_probability) as avg_predicted_risk,
    COUNT(CASE WHEN c.claim_status = 'DENIED' THEN 1 END) / COUNT(c.claim_id)::FLOAT as actual_denial_rate,
    pr.historical_denial_rate,
    AVG(c.claim_amount) as avg_claim_amount,
    SUM(CASE WHEN r.intervention_recommended THEN r.estimated_savings ELSE 0 END) as total_potential_savings
FROM RAW_DATA.claims_data c
JOIN RAW_DATA.providers pr ON c.provider_id = pr.provider_id
LEFT JOIN PROCESSED_DATA.claim_risk_scores r ON c.claim_id = r.claim_id
WHERE c.submission_date >= DATEADD(day, -30, CURRENT_DATE())
GROUP BY pr.provider_name, pr.specialty, pr.historical_denial_rate;

-- ===================================================================
-- ENABLE TASKS
-- ===================================================================

-- Resume tasks (they start as suspended)
ALTER TASK task_process_claims RESUME;
ALTER TASK task_send_alerts RESUME;

-- ===================================================================
-- VERIFICATION
-- ===================================================================

-- Show created procedures
SHOW PROCEDURES IN SCHEMA ML_MODELS;

-- Show created tasks
SHOW TASKS IN DATABASE QUADAX_DENIAL_PREVENTION;

-- Show created views
SHOW VIEWS IN SCHEMA ANALYTICS;

-- Test the real-time metrics view
SELECT * FROM ANALYTICS.v_realtime_metrics;

SELECT 'ML deployment completed successfully!' as STATUS;
