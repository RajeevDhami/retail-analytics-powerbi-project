# 🎁 UK & International Wholesale Gift-Ware Analytics Platform

## 📌 Project Overview

This project is an end-to-end Business Intelligence solution developed using SQL Server, Python, and Power BI to analyze sales performance, customer behavior, product profitability, and operational risks for an international wholesale gift-ware retailer.

The solution transforms raw transactional retail data into actionable business insights through interactive dashboards covering:

- Executive Performance Monitoring
- Customer Intelligence & Retention Analytics
- Product Performance & Inventory Value Analysis
- Operational Risk & Order Cancellation Analysis

---

## 🏗️ Technology Stack

| Technology | Purpose |
|------------|----------|
| SQL Server | Data Cleaning, Transformation & View Creation |
| Python (Pandas) | Exploratory Data Analysis (EDA) |
| Jupyter Notebook | Data Exploration & Validation |
| Power BI | Dashboard Development & Visualization |
| DAX | KPI Calculations & Business Metrics |

---

## 📊 Dashboard Architecture

### 1. Executive Overview

Provides a high-level summary of business performance.

#### KPIs
- Net Sales Revenue
- Total Orders
- Average Order Value
- Total Units Sold
- Active Customers

#### Visuals
- Monthly Revenue & Orders Trend
- Average Order Value Trend
- International Revenue by Country
- Quarterly Revenue Performance

#### Business Value
Provides stakeholders with a quick overview of revenue growth, customer activity, and country-level performance.

---

### 2. Customer Intelligence & Retention Analytics

Focuses on customer segmentation, loyalty, and retention behavior.

#### KPIs
- New Customers
- Repeat Customers
- Average Revenue per Customer
- Repeat Rate %

#### Advanced Analytics

##### RFM Segmentation
Customers are classified into:

- Strategic Partner
- Key Account
- Regular Partner
- Growing Partnership
- Seasonal Partner
- Emerging Account
- Inactive – Reactivation Needed

##### Cohort Analysis
Tracks customer retention performance across monthly acquisition cohorts.

#### Visuals
- Customer Retention Cohort Heatmap
- Customer Distribution by Segment
- Revenue by Customer Segment
- Cohort Revenue Performance

#### Business Value
Helps identify:
- High-value customer segments
- Customer loyalty trends
- Retention opportunities
- Segment-wise revenue contribution

---

### 3. Product Performance & Inventory Value Analysis

Evaluates product contribution using Pareto Analysis and ABC Classification.

#### KPIs
- Total Products
- High Value Products
- A-Class Revenue %
- Average Revenue per Product

#### Advanced Analytics

##### ABC Classification

| Class | Description |
|---------|---------|
| A | Top 80% Revenue Contributors |
| B | Next 15% Revenue Contributors |
| C | Remaining Products |

##### Pareto Analysis
Demonstrates the 80/20 rule where a small percentage of products generate the majority of revenue.

#### Visuals
- Revenue Contribution by ABC Class
- Product Count & Revenue by ABC Class
- Product Performance Matrix
- Revenue Trend by ABC Class
- Top Products by Revenue

#### Business Value
Helps identify:
- Revenue-driving products
- Inventory optimization opportunities
- Revenue concentration risk
- Product portfolio performance

---

### 4. Operational Risk & Order Cancellation Analysis

Analyzes revenue leakage caused by order cancellations.

#### KPIs
- Cancelled Orders
- Cancellation Rate
- Highest Cancellation Risk Market
- Revenue Lost

#### Visuals
- Cancellation Rate by Country
- Cancellation Analysis by Customer Segment
- Country Risk Heatmap
- Products Driving Revenue Loss

#### Business Value
Enables stakeholders to:
- Monitor cancellation risk
- Identify high-risk markets
- Reduce revenue leakage
- Detect cancellation-prone products

---

## 🛠️ Data Engineering Process

### Step 1: Data Cleaning

Performed using SQL Server and Python.

Key Activities:

- Removed missing Customer IDs
- Handled cancelled invoices
- Removed duplicate records
- Standardized date formats
- Created revenue-related calculated fields

---

### Step 2: Feature Engineering

#### Revenue Metrics
- Sales Revenue
- Net Sales Revenue
- Revenue Lost
- Cancellation Rate

#### Customer Metrics
- Recency
- Frequency
- Monetary Value
- Customer Segment
- Repeat Rate

#### Product Metrics
- ABC Classification
- Product Ranking
- Cumulative Revenue Percentage

---

### Step 3: SQL View Layer

Created analytical SQL views to support dashboard reporting:

- vw_Valid_Sales_Only
- vw_Cancellations_Only
- vw_Product_ABC_Analysis
- vw_Customer_RFM_Segments
- vw_Customer_Cohorts
- vw_Monthly_New_Vs_Repeat_Dynamics

These views serve as the semantic layer for Power BI.

---

## 📈 Key Business Insights

### Customer Intelligence

- Seasonal Partners contribute the highest revenue.
- Repeat customers account for approximately 69% of total customers.
- Retention performance varies significantly across cohorts.

### Product Analytics

- Approximately 20% of products generate 80% of total revenue.
- A-Class products dominate overall sales contribution.
- Revenue concentration exists within a small group of products.

### Operational Risk

- United Kingdom has the highest cancellation risk among major revenue-generating markets.
- Cancellation rates vary significantly by country.
- Certain products contribute disproportionately to revenue loss.

---

## 🎯 Business Impact

This solution enables stakeholders to:

✅ Monitor revenue performance

✅ Understand customer behavior

✅ Improve customer retention strategies

✅ Optimize product portfolio decisions

✅ Reduce cancellation-related revenue loss

✅ Identify country-specific business opportunities

---

## 🚀 Future Enhancements

- Customer Lifetime Value (CLV) Analysis
- Time-Series Forecasting
- Market Basket Analysis
- Inventory Optimization Dashboard
- Profitability Analysis
- Automated Data Refresh Pipelines
- What-If Scenario Modeling

---

## 📸 Dashboard Pages

### Executive Overview
Business performance monitoring and revenue analysis.
<img width="1222" height="776" alt="Executive Overview" src="https://github.com/user-attachments/assets/c713b25d-1faf-4064-a683-55075a4afe07" />

### Customer Intelligence & Retention
Customer segmentation, cohort analysis, and retention insights.
<img width="1223" height="780" alt="Customer Intelligence" src="https://github.com/user-attachments/assets/df61b68c-5a99-40d6-90a4-550b0530cdd6" />


### Product Performance & Inventory Analysis
ABC Classification, Pareto Analysis, and product profitability.
<img width="1222" height="780" alt="Product Analysis" src="https://github.com/user-attachments/assets/88d24279-b4ec-47be-9f63-93cc2395fe10" />


### Operational Risk & Cancellation Analysis
Revenue leakage monitoring and cancellation risk assessment.
<img width="1221" height="777" alt="Operations And Risk" src="https://github.com/user-attachments/assets/ec283b4b-e52b-4f44-ae5a-2c01de87045c" />


---

## 👨‍💻 Author

**Rajeev Dhami**

Aspiring Data Analyst | SQL | Python | Power BI

Focused on building business-driven analytics solutions that transform raw data into actionable insights.
