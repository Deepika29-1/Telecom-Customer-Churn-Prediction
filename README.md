# Telco Customer Churn Prediction & Analysis

## Project Overview
This project focuses on predicting customer churn in a telecommunications dataset and providing actionable business recommendations to improve customer retention. It involves comprehensive data analysis, feature engineering, machine learning model training, and SQL-based insights.

## Dataset
The analysis is based on the Telco Customer Churn dataset, comprising 7043 customer records with 20 features and a `Churn` target variable. Initial analysis revealed an imbalanced target, with approximately 26.5% of customers having churned.

## Methodology

### 1. Data Cleaning & Preprocessing
-   **Handling Missing Values**: `TotalCharges` column, which initially contained blank strings, was converted to numeric, and missing values were imputed using the median.
-   **Feature Removal**: The `customerID` column was dropped as it holds no predictive value.
-   **Target Encoding**: The `Churn` target variable was mapped to a binary format (Yes=1, No=0).
-   **Categorical Encoding**: All categorical features were label-encoded.
-   **Data Splitting**: The dataset was split into training and testing sets (80/20 ratio), stratified to maintain the original churn distribution.
-   **Addressing Class Imbalance**: SMOTE (Synthetic Minority Over-sampling Technique) was applied to the training data to balance the classes.
-   **Feature Scaling**: Features were scaled using `StandardScaler` to optimize model performance.

### 2. Exploratory Data Analysis (EDA)
Key findings from the EDA included:
-   **Contract Type**: Month-to-month contracts showed significantly higher churn rates (~42.7%) compared to one-year (11.3%) and two-year (2.8%) contracts.
-   **Monthly Charges**: Churned customers generally incurred higher monthly charges, suggesting potential dissatisfaction with value for money.
-   **Internet Service**: Fiber optic internet users had the highest churn rate (~41.9%), indicating possible service-specific issues.
-   **Tenure**: Churned customers had a much lower median tenure, highlighting that newer customers are more prone to churn.

### 3. Feature Engineering
-   **Customer Lifetime Value (CLV)**: A proxy for CLV was created by multiplying `tenure` and `MonthlyCharges`.
-   **Services Count**: A feature representing the total number of active services for each customer was engineered.
-   **Security Services**: A binary feature `has_security` was created to indicate if a customer subscribed to online security, device protection, or tech support services.

### 4. Machine Learning Models
Three classification models were trained and evaluated:
-   **Logistic Regression**
-   **Decision Tree Classifier**
-   **Random Forest Classifier**

**Model Performance Summary:**
| Model               | Accuracy | ROC-AUC | F1 Score |
| :------------------ | :------- | :------ | :------- |
| Logistic Regression | 0.7566   | 0.8231  | 0.6044   |
| Decision Tree       | 0.7658   | 0.8174  | 0.6034   |
| **Random Forest**   | **0.7736** | **0.8343** | **0.6124** |

The **Random Forest Classifier** achieved the best overall performance, with the highest ROC-AUC and F1 Score, indicating its superior ability to identify churners while balancing precision and recall.

### 5. Model Interpretability
-   **Decision Tree Visualization**: A pruned Decision Tree (max depth 3) was visualized to provide interpretable insights into the model's decision-making process.
-   **Feature Importance**: The Random Forest model identified `Contract`, `TechSupport`, and `OnlineSecurity` as the top three most important features influencing churn.

### 6. Business Recommendations
Based on the analysis, five key recommendations were formulated:
1.  **Contract Upgrade Campaign**: Offer discounts to month-to-month customers to switch to longer-term contracts.
2.  **Early Onboarding**: Implement 60-day check-ins and 6-month surveys for new customers.
3.  **Fiber Optic Bundle**: Proactively offer security and tech support bundles to fiber optic users.
4.  **Prioritize High CLV Customers**: Focus retention efforts on high-risk customers with high estimated CLV.
5.  **Auto-Pay Enrollment**: Encourage switching to auto-pay methods by offering incentives.

### 7. SQL-Based Insights
An in-memory SQLite database was used to perform detailed SQL queries, confirming and extending insights:
-   **Overall Churn Rate**: Confirmed the overall churn rate of 26.54%.
-   **Churn by Contract**: Month-to-month contracts had a 42.71% churn rate.
-   **Churn by Internet Service**: Fiber optic had the highest churn rate at 41.89%.
-   **Average Monthly Charges/Tenure**: Churned customers had higher monthly charges ($74.44) and lower tenure (18.0 months).
-   **New Customer Churn**: Customers with 0-12 months tenure had a 47.44% churn rate.
-   **Payment Method**: Electronic check users showed the highest churn rate (45.29%).
-   **High-Risk Segment**: A specific segment (month-to-month, fiber optic, no security/tech support) consisting of 1524 customers had a 60.70% churn rate with high average monthly charges ($84.65).
-   **Predictions Analysis**: High-risk customers (from model predictions) showed an actual churn rate of 59.78% and an average predicted probability of 77.10%.

## Conclusion
This notebook provides a complete workflow from data loading and cleaning to advanced modeling and actionable business recommendations. The insights gained are crucial for developing targeted strategies to reduce customer churn and improve customer retention for Telco companies.
