# RCM Analytics Platform - Snowsight Deployment Guide

## 🚀 Quick Deployment in Snowsight

This guide provides a streamlined deployment process using Snowsight worksheets. Simply copy and paste the SQL scripts in order.

### ⚡ Quick Start (5 Steps)

1. **Setup Database & Warehouses** → Run `01_setup.sql`
2. **Create Tables** → Run `02_tables.sql` 
3. **Load Sample Data** → Run `03_sample_data.sql`
4. **Deploy ML Models** → Run `04_ml_deployment.sql`
5. **Create Streamlit App** → Upload `streamlit_app.py` to Streamlit in Snowflake

**Total Time**: ~15 minutes

---

## 📋 Detailed Steps

### Step 1: Database Setup
```sql
-- Copy contents of 01_setup.sql into a new Snowsight worksheet
-- Run all commands
```

### Step 2: Create Tables
```sql
-- Copy contents of 02_tables.sql into a new Snowsight worksheet  
-- Run all commands
```

### Step 3: Load Sample Data
```sql
-- Copy contents of 03_sample_data.sql into a new Snowsight worksheet
-- Run all commands
```

### Step 4: ML Model Deployment
```sql
-- Copy contents of 04_ml_deployment.sql into a new Snowsight worksheet
-- Run all commands
```

### Step 5: Streamlit App
1. Go to **Streamlit** in Snowsight
2. Click **+ Streamlit App**
3. Name: `RCM Analytics Platform`
4. Upload or copy contents of `streamlit_app.py`
5. Click **Create**

---

## ✅ Verification

After deployment, verify:
- [ ] Database `RCM_DENIAL_PREVENTION` exists
- [ ] All 17 tables created successfully
- [ ] Sample data loaded (check record counts)
- [ ] ML models registered in model registry
- [ ] Streamlit app accessible and displaying data

---

## 🔧 Prerequisites

- Snowflake account with ACCOUNTADMIN or sufficient privileges
- Streamlit in Snowflake enabled
- Python packages available (handled automatically in SiS)

---

## 🔧 Troubleshooting

### Common Issues

#### "Table does not exist or not authorized" Errors
**Cause:** Scripts run out of order or table creation failed
**Solution:**
1. **Re-run 02_tables.sql** - Always run this before 03_sample_data.sql
2. **Check verification output** - 02_tables.sql includes verification queries that show:
   - Count of tables per schema
   - List of all created tables
   - Specific check for collections_performance table
3. **Verify schema context** - Ensure you're in the correct database (`RCM_DENIAL_PREVENTION`)

#### "SQL compilation error: Invalid expression in VALUES clause"
**Cause:** Snowflake doesn't support complex functions in VALUES clauses
**Solution:** Already fixed - we use individual INSERT...SELECT statements

#### Missing Privileges
**Cause:** Insufficient database/schema permissions
**Solution:** Ensure ACCOUNTADMIN or CREATE privileges on database/schemas

### Debugging Steps
1. **Check current database**: `SELECT CURRENT_DATABASE();`
2. **List schemas**: `SHOW SCHEMAS;`
3. **List tables in schema**: `SHOW TABLES IN SCHEMA ANALYTICS;`
4. **Verify table exists**: Run the verification queries from 02_tables.sql

---

## 📞 Support

If you encounter issues:
1. Check that all prerequisite privileges are granted
2. Ensure Streamlit in Snowflake is enabled
3. **Always run scripts in order: 01_setup.sql → 02_tables.sql → 03_sample_data.sql → 04_ml_deployment.sql**
4. Use the verification queries in each script to confirm successful execution
