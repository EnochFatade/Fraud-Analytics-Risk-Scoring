# Fraud Analytics & Risk Scoring Dashboard

## Project Overview
This project demonstrates an end-to-end **fraud analytics and risk scoring workflow**, from raw transactional data through rule evaluation, account-level risk scoring, and an operational summary dashboard.

The goal of the project is to replicate how fraud and risk teams:
- Monitor suspicious activity using rules
- Classify severity (HIGH / MED)
- Aggregate risk at the account and customer level
- Surface actionable insights for fraud operations and investigations

The final output is a **Fraud Operations Summary dashboard** designed for analysts, risk managers, and decision-makers.

---

## Data Model

The project follows a **star-schema-style layout** with clear separation between dimensions, facts, and curated outputs.

### Dimension Tables (`data/raw`)
- `dim_customers.csv` – customer identifiers and attributes
- `dim_accounts.csv` – account-level identifiers and metadata
- `dim_merchants.csv` – merchant reference data
- `dim_devices.csv` – device identifiers and attributes

### Fact Tables (`data/raw`)
- `fact_transactions.csv` – transaction-level data including international indicators
- `fact_login_sessions.csv` – authentication and login session activity
- `fraud_rule_hits.csv` – fraud rule triggers with severity and timestamps

### Curated Outputs (`data/curated`)
- `account_risk_scores.csv` – account-level risk scoring output derived from transactional and rule activity

---

## Fraud Rules & Severity
Fraud rules are evaluated at the transaction level and recorded in `fraud_rule_hits`.

Each rule hit includes:
- `rule_code`
- `rule_severity` (HIGH / MED)
- `hit_ts` (timestamp of rule trigger)
- Associated `account_id` and `customer_id`

Severity is used throughout the analysis to differentiate:
- **High-confidence fraud signals**
- **Medium-risk or investigatory signals**

---

## Risk Scoring Logic
Account-level risk is computed in the curated layer (`Account_Risk_Scoring`) using:
- Frequency of fraud rule hits
- Severity of triggered rules
- Transaction behavior patterns (e.g., international activity rate)
- Recency of suspicious activity

Key outputs include:
- `risk_score` – composite numeric risk score
- `risk_tier` – HIGH / MED / LOW classification
- `last_txn_ts` – most recent transaction timestamp
- `last_hit_ts` – most recent fraud rule trigger

---

## Summary Dashboard

The **Fraud Operations Summary** dashboard provides a consolidated operational view of fraud activity.

### Dashboard Sections

1. **Executive Fraud & Risk Overview**  
   High-level KPIs summarizing transaction volume, declines, rule hits, and severity distribution.

2. **Fraud Rule Activity Over Time**  
   Rule hit volume across recent monitoring windows (24 hours, 7 days, 30 days).

3. **Highest Risk Accounts (Model Output)**  
   Accounts ranked by composite risk score and risk tier.

4. **Fraud Rule Effectiveness & Severity Breakdown**  
   Rule-level performance showing total hits and severity mix.

5. **Account-Level Rule Activity**  
   Accounts generating the highest volume of fraud alerts, including recency and rule diversity.

6. **Customer-Level Rule Activity**  
   Aggregated fraud rule activity across customers for exposure analysis.

---

## Screenshots

The following screenshots illustrate key dashboard views:

- `summary_kpis.png`
- `top_risk_accounts.png`
- `rule_effectiveness.png`
- `account_rule_activity.png`
- `customer_rule_activity.png`
- `fraud_rule_activity_over_time_.png`

---

## SQL Structure

The SQL folder reflects a production-style analytics pipeline:

sql/
├── 00_schema/
│   └── 001_create_tables.sql
├── 10_staging/
│   └── stg_transactions.sql
├── 20_rules/
│   └── rule_severity_logic.sql
├── 30_scoring/
│   └── account_risk_scoring.sql
├── 40_reporting/
│   └── fraud_summary.sql


This structure separates schema creation, staging logic, rule logic, scoring, and reporting.

---

## Tools & Skills Demonstrated
- Fraud analytics & rule-based detection
- Risk scoring and tiering
- Data modeling (fact / dimension design)
- Google Sheets for analytical prototyping
- SQL for schema, scoring, and reporting logic
- Dashboard design for fraud operations
- Data export and project packaging for analytics portfolios

---

## How to Use This Project
1. Review raw and curated datasets in the `data/` directory
2. Examine scoring and reporting logic in the `sql/` directory
3. Open the dashboard file in `dashboards/` to explore fraud insights
4. Reference screenshots for a quick visual overview

---

## Notes
This project is designed as a **portfolio demonstration** of fraud analytics concepts and workflows.  
All data is synthetic and intended for educational and professional showcase purposes only.


