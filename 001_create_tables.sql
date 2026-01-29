{\rtf1\ansi\ansicpg1252\cocoartf2639
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- SentinelPay Fraud Risk Scoring System\
-- Schema: realistic star-ish model with fraud operations tables\
-- Works in PostgreSQL (also easy to adapt to Snowflake/BigQuery)\
\
CREATE TABLE IF NOT EXISTS dim_customer (\
  customer_id        VARCHAR(20) PRIMARY KEY,\
  full_name          VARCHAR(120) NOT NULL,\
  email              VARCHAR(140),\
  phone              VARCHAR(30),\
  date_of_birth      DATE,\
  state              VARCHAR(30),\
  created_at         TIMESTAMP NOT NULL\
);\
\
CREATE TABLE IF NOT EXISTS dim_account (\
  account_id         VARCHAR(20) PRIMARY KEY,\
  customer_id        VARCHAR(20) NOT NULL,\
  account_type       VARCHAR(30),             -- CHECKING, WALLET, CREDIT\
  kyc_level          VARCHAR(20),             -- BASIC, STANDARD, ENHANCED\
  account_status     VARCHAR(20),             -- ACTIVE, SUSPENDED, CLOSED\
  opened_at          TIMESTAMP NOT NULL,\
  credit_limit_usd   NUMERIC(12,2),\
  daily_spend_limit  NUMERIC(12,2),\
  baseline_risk_tier VARCHAR(10),             -- LOW, MED, HIGH\
  CONSTRAINT fk_account_customer\
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id)\
);\
\
CREATE TABLE IF NOT EXISTS dim_merchant (\
  merchant_id        VARCHAR(20) PRIMARY KEY,\
  merchant_name      VARCHAR(140) NOT NULL,\
  mcc_code           VARCHAR(10),             -- merchant category code\
  category           VARCHAR(60),             -- Gas, Electronics, Grocery, etc.\
  merchant_risk_tier VARCHAR(10),             -- LOW, MED, HIGH\
  country            VARCHAR(2),              -- US, CA, etc.\
  created_at         TIMESTAMP NOT NULL\
);\
\
CREATE TABLE IF NOT EXISTS dim_device (\
  device_id          VARCHAR(20) PRIMARY KEY,\
  customer_id        VARCHAR(20) NOT NULL,\
  device_type        VARCHAR(30),             -- IOS, ANDROID, WEB\
  device_trust_score INTEGER,                 -- 0-100\
  first_seen_at      TIMESTAMP NOT NULL,\
  last_seen_at       TIMESTAMP NOT NULL,\
  CONSTRAINT fk_device_customer\
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id)\
);\
\
CREATE TABLE IF NOT EXISTS fact_login_sessions (\
  session_id         VARCHAR(30) PRIMARY KEY,\
  customer_id        VARCHAR(20) NOT NULL,\
  device_id          VARCHAR(20),\
  login_ts           TIMESTAMP NOT NULL,\
  ip_address         VARCHAR(45),\
  geo_country        VARCHAR(2),\
  geo_region         VARCHAR(40),\
  geo_city           VARCHAR(60),\
  mfa_result         VARCHAR(20),             -- PASSED, FAILED, NOT_USED\
  login_result       VARCHAR(20),             -- SUCCESS, FAILED\
  failed_reason      VARCHAR(80),             -- BAD_PW, MFA_FAIL, LOCKED, etc.\
  CONSTRAINT fk_login_customer\
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id)\
);\
\
CREATE TABLE IF NOT EXISTS fact_transactions (\
  transaction_id     VARCHAR(30) PRIMARY KEY,\
  account_id         VARCHAR(20) NOT NULL,\
  customer_id        VARCHAR(20) NOT NULL,\
  merchant_id        VARCHAR(20) NOT NULL,\
  device_id          VARCHAR(20),\
  txn_ts             TIMESTAMP NOT NULL,\
  channel            VARCHAR(20),             -- CARD_PRESENT, ECOM, ACH\
  currency           VARCHAR(3) DEFAULT 'USD',\
  amount_usd         NUMERIC(12,2) NOT NULL,\
  txn_status         VARCHAR(20),             -- APPROVED, DECLINED, REVERSED\
  decline_reason     VARCHAR(80),\
  geo_country        VARCHAR(2),\
  geo_region         VARCHAR(40),\
  geo_city           VARCHAR(60),\
  is_international    BOOLEAN DEFAULT FALSE,\
  CONSTRAINT fk_txn_account\
    FOREIGN KEY (account_id) REFERENCES dim_account(account_id),\
  CONSTRAINT fk_txn_customer\
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),\
  CONSTRAINT fk_txn_merchant\
    FOREIGN KEY (merchant_id) REFERENCES dim_merchant(merchant_id)\
);\
\
CREATE TABLE IF NOT EXISTS fact_chargebacks (\
  chargeback_id      VARCHAR(30) PRIMARY KEY,\
  transaction_id     VARCHAR(30) NOT NULL,\
  account_id         VARCHAR(20) NOT NULL,\
  opened_ts          TIMESTAMP NOT NULL,\
  reason_code        VARCHAR(20),\
  confirmed_fraud    BOOLEAN DEFAULT FALSE,\
  resolution_status  VARCHAR(20),             -- OPEN, WON, LOST\
  CONSTRAINT fk_cb_txn\
    FOREIGN KEY (transaction_id) REFERENCES fact_transactions(transaction_id)\
);\
\
CREATE TABLE IF NOT EXISTS fraud_rule_hits (\
  rule_hit_id        VARCHAR(40) PRIMARY KEY,\
  transaction_id     VARCHAR(30),\
  account_id         VARCHAR(20),\
  customer_id        VARCHAR(20),\
  rule_code          VARCHAR(30),             -- e.g., VELOCITY_5MIN, GEO_MISMATCH\
  rule_description   VARCHAR(200),\
  rule_severity      VARCHAR(10),             -- LOW, MED, HIGH\
  hit_ts             TIMESTAMP NOT NULL,\
  evidence_json      TEXT                      -- store details for realism\
);\
\
CREATE TABLE IF NOT EXISTS fraud_cases (\
  case_id            VARCHAR(30) PRIMARY KEY,\
  customer_id        VARCHAR(20) NOT NULL,\
  account_id         VARCHAR(20),\
  opened_ts          TIMESTAMP NOT NULL,\
  case_status        VARCHAR(20),             -- OPEN, IN_REVIEW, ESCALATED, CLOSED\
  case_priority      VARCHAR(10),             -- P1, P2, P3\
  primary_reason     VARCHAR(120),\
  assigned_to        VARCHAR(80),\
  closed_ts          TIMESTAMP,\
  outcome            VARCHAR(30),             -- FRAUD_CONFIRMED, FALSE_POSITIVE, etc.\
  notes              TEXT\
);\
}