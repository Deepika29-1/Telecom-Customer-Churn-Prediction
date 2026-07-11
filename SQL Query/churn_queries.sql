-- ============================================================
-- CHURN PREDICTION PROJECT — SQLITE QUERY REFERENCE
-- Database: data/churn.db
-- Tables:   customers   (raw cleaned data)
--           predictions (model output with churn probabilities)
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- SECTION A: EXPLORING THE customers TABLE
-- ────────────────────────────────────────────────────────────

-- A1. Overall churn rate
SELECT
    COUNT(*)                          AS total_customers,
    SUM(Churn)                        AS churned,
    ROUND(AVG(Churn) * 100, 2)        AS churn_rate_pct
FROM customers;


-- A2. Churn rate by contract type
SELECT
    Contract,
    COUNT(*)                          AS customers,
    SUM(Churn)                        AS churned,
    ROUND(AVG(Churn) * 100, 2)        AS churn_rate_pct
FROM customers
GROUP BY Contract
ORDER BY churn_rate_pct DESC;


-- A3. Churn rate by tenure bucket
SELECT
    CASE
        WHEN tenure <= 12  THEN '1. 0–12 months'
        WHEN tenure <= 24  THEN '2. 13–24 months'
        WHEN tenure <= 48  THEN '3. 25–48 months'
        ELSE                    '4. 49+ months'
    END AS tenure_group,
    COUNT(*)                          AS customers,
    SUM(Churn)                        AS churned,
    ROUND(AVG(Churn) * 100, 2)        AS churn_rate_pct
FROM customers
GROUP BY tenure_group
ORDER BY tenure_group;


-- A4. Churn rate by internet service type
SELECT
    InternetService,
    COUNT(*)                          AS customers,
    ROUND(AVG(Churn) * 100, 2)        AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2)     AS avg_monthly_charges
FROM customers
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;


-- A5. Average charges and tenure: churned vs retained
SELECT
    CASE WHEN Churn = 1 THEN 'Churned' ELSE 'Retained' END AS status,
    COUNT(*)                          AS customers,
    ROUND(AVG(MonthlyCharges), 2)     AS avg_monthly_charges,
    ROUND(AVG(TotalCharges), 2)       AS avg_total_charges,
    ROUND(AVG(tenure), 1)             AS avg_tenure_months
FROM customers
GROUP BY Churn;


-- A6. Churn by payment method
SELECT
    PaymentMethod,
    COUNT(*)                          AS customers,
    ROUND(AVG(Churn) * 100, 2)        AS churn_rate_pct
FROM customers
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;


-- A7. Churn by senior citizen status
SELECT
    CASE WHEN SeniorCitizen = 1 THEN 'Senior' ELSE 'Non-Senior' END AS segment,
    COUNT(*)                          AS customers,
    ROUND(AVG(Churn) * 100, 2)        AS churn_rate_pct
FROM customers
GROUP BY SeniorCitizen;


-- A8. High-risk segment: Month-to-month + Fiber + no security
SELECT
    COUNT(*)                          AS high_risk_count,
    ROUND(AVG(Churn) * 100, 2)        AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2)     AS avg_monthly_charges,
    ROUND(AVG(tenure), 1)             AS avg_tenure
FROM customers
WHERE Contract        = 'Month-to-month'
  AND InternetService = 'Fiber optic'
  AND OnlineSecurity  = 'No'
  AND TechSupport     = 'No';


-- A9. Multi-service customers vs single-service
SELECT
    CASE
        WHEN services_count >= 5 THEN 'High (5+)'
        WHEN services_count >= 3 THEN 'Medium (3–4)'
        ELSE                          'Low (0–2)'
    END AS service_tier,
    COUNT(*)                          AS customers,
    ROUND(AVG(Churn) * 100, 2)        AS churn_rate_pct
FROM customers
GROUP BY service_tier
ORDER BY churn_rate_pct DESC;


-- A10. Paperless billing + churn
SELECT
    PaperlessBilling,
    COUNT(*)                          AS customers,
    ROUND(AVG(Churn) * 100, 2)        AS churn_rate_pct
FROM customers
GROUP BY PaperlessBilling;


-- ────────────────────────────────────────────────────────────
-- SECTION B: QUERYING THE predictions TABLE
-- (Run after executing the Python script)
-- ────────────────────────────────────────────────────────────

-- B1. Risk tier summary
SELECT
    risk_tier,
    COUNT(*)                              AS customers,
    ROUND(AVG(actual_churn) * 100, 2)    AS actual_churn_rate_pct,
    ROUND(AVG(churn_prob) * 100, 2)      AS avg_predicted_prob_pct
FROM predictions
GROUP BY risk_tier
ORDER BY avg_predicted_prob_pct DESC;


-- B2. High-risk customers (churn prob ≥ 70%)
SELECT
    COUNT(*)                              AS high_risk_customers,
    ROUND(AVG(MonthlyCharges), 2)         AS avg_monthly_charges,
    ROUND(AVG(tenure), 1)                 AS avg_tenure_months,
    ROUND(AVG(CLV), 0)                    AS avg_clv,
    ROUND(AVG(actual_churn) * 100, 2)    AS actual_churn_rate_pct
FROM predictions
WHERE churn_prob >= 0.70;


-- B3. Model accuracy check (predicted vs actual)
SELECT
    predicted_churn,
    actual_churn,
    COUNT(*)                              AS count
FROM predictions
GROUP BY predicted_churn, actual_churn
ORDER BY predicted_churn, actual_churn;
-- Rows where predicted=1, actual=1 → True Positives
-- Rows where predicted=1, actual=0 → False Positives
-- Rows where predicted=0, actual=1 → False Negatives (missed churners)
-- Rows where predicted=0, actual=0 → True Negatives


-- B4. False negatives — customers who churned but we missed
SELECT
    COUNT(*)                              AS missed_churners,
    ROUND(AVG(MonthlyCharges), 2)         AS avg_monthly_charges,
    ROUND(AVG(churn_prob) * 100, 2)      AS avg_predicted_prob_pct
FROM predictions
WHERE actual_churn = 1
  AND predicted_churn = 0;


-- B5. Top CLV customers at high churn risk (priority retention)
SELECT
    CLV,
    MonthlyCharges,
    tenure,
    ROUND(churn_prob * 100, 2)           AS churn_prob_pct,
    actual_churn
FROM predictions
WHERE churn_prob >= 0.60
ORDER BY CLV DESC
LIMIT 20;


-- B6. Monthly revenue at risk
SELECT
    ROUND(SUM(MonthlyCharges), 2)        AS monthly_revenue_at_risk,
    COUNT(*)                              AS high_risk_customers
FROM predictions
WHERE churn_prob >= 0.70;
