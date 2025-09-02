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
- [ ] Database `QUADAX_DENIAL_PREVENTION` exists
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

## 📞 Support

If you encounter issues:
1. Check that all prerequisite privileges are granted
2. Ensure Streamlit in Snowflake is enabled
3. Verify all SQL scripts run without errors before proceeding to next step
