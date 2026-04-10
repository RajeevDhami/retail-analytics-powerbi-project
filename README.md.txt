# 🛒 Retail Analytics Power BI Project

## 📌 Project Overview
This project demonstrates an end-to-end retail analytics workflow using Python, SQL, and Power BI. It covers data extraction, cleaning, transformation, analysis, and dashboard creation with advanced features like incremental refresh and dynamic row-level security (RLS).

---

## 🧰 Tools & Technologies
- Python (Pandas, Jupyter Notebook)
- SQL Server (Data cleaning & analysis)
- Power BI (Dashboard & visualization)
- Power Query (ETL)
- DAX (Measures & KPIs)

---

## 📂 Project Structure

Retail-Analytics-Project/
│
├── data/ # Raw dataset
├── notebooks/ # Data cleaning using Python
├── sql/ # SQL queries & analysis
├── powerbi/ # Power BI dashboard (.pbix)
├── screenshots/ # Dashboard visuals
└── README.md


---

## 🔄 Workflow

### 1️⃣ Data Collection
- Dataset sourced from Kaggle
- Imported using Python (JSON format)

### 2️⃣ Data Cleaning (Python)
- Removed null values
- Handled duplicates
- Converted data types

### 3️⃣ SQL Analysis
- Data validation & cleaning
- KPI calculations:
  - Total Revenue
  - Average Order Value
- Business queries:
  - Top products
  - Top customers
  - Customer segmentation
  - Pareto analysis

### 4️⃣ Power BI Dashboard
- Interactive dashboard with:
  - Revenue trends
  - Customer segmentation
  - Product performance
  - Cohort analysis
- Implemented:
  - Incremental Refresh
  - Dynamic Row-Level Security (RLS)

---

## 📊 Key Insights

- 📌 Revenue follows a Pareto distribution at the product level
- 📌 A small number of products contribute majority of revenue
- 📌 Customer revenue is relatively distributed (low dependency risk)
- 📌 High-value customers drive significant revenue share
- 📌 Strong seasonal trends observed

---

## 🔐 Row-Level Security (RLS)

- Implemented dynamic RLS using user email mapping
- Users can only view data for their assigned country
- Demonstrates real-world data access control

---

## ⚡ Incremental Refresh

- Configured using RangeStart and RangeEnd parameters
- Optimizes performance for large datasets
- Refreshes only recent data instead of full dataset

---

## 📸 Dashboard Screenshots

### 📍 Overview Dashboard
![Overview](screenshots/dashboard_overview.png)

### 📍 Pareto Analysis
![Pareto](screenshots/pareto_analysis.png)

### 📍 Customer Cohort Analysis
![Cohort](screenshots/cohort_analysis.png)

### 📍 Revenue Cohort Analysis
![Revenue Cohort](screenshots/revenue_cohort_analysis.png)

### 📍 RLS Demonstration
![RLS](screenshots/rls_demo.png)

---

## 🚀 Key Learnings

- End-to-end data analytics workflow
- SQL optimization and business query writing
- Power BI advanced features (RLS, Incremental Refresh)
- Data storytelling and dashboard design

---

## 📌 Future Improvements

- Deploy dashboard to Power BI Service with live data
- Automate data pipeline
- Add predictive analytics

---

## 👨‍💻 Author
**Rajeev Dhami**

---
