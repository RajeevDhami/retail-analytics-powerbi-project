# 🛒 Retail Analytics Power BI Project

## 📌 Project Overview

This project demonstrates an end-to-end retail analytics workflow using Python, SQL, and Power BI. It covers data extraction, cleaning, transformation, analysis, and dashboard creation with advanced features like incremental refresh and dynamic row-level security (RLS).

---

## 🧰 Tools & Technologies

* Python (Pandas, Jupyter Notebook)
* SQL Server (Data cleaning & analysis)
* Power BI (Dashboard & visualization)
* Power Query (ETL)
* DAX (Measures & KPIs)

---

## 📂 Project Structure

Retail-Analytics-Project/
│
├── data/
├── notebooks/
├── sql/
├── powerbi/
├── screenshots/
└── README.md

---

## 🔄 Workflow

### 1️⃣ Data Collection

* Dataset sourced from Kaggle
* Imported using Python (JSON format)

### 2️⃣ Data Cleaning (Python)

* Removed null values
* Handled duplicates
* Converted data types

### 3️⃣ SQL Analysis

* Data validation & cleaning
* KPI calculations
* Business queries (Top products, customers, segmentation, Pareto)

### 4️⃣ Power BI Dashboard

* Revenue trends
* Customer segmentation
* Product performance
* Cohort analysis

### Advanced Features:

* Incremental Refresh
* Dynamic Row-Level Security (RLS)

---

## 📊 Key Insights

* Revenue follows Pareto distribution at product level
* Few products contribute majority of revenue
* Customer revenue is more distributed
* High-value customers drive major revenue
* Strong seasonal trends

---

## 🔐 Row-Level Security (RLS)

* Implemented dynamic RLS using user email mapping
* Users can only view data for assigned country

---

## ⚡ Incremental Refresh

* Configured using RangeStart & RangeEnd
* Improves performance by refreshing only recent data

---

## 📸 Dashboard Screenshots

![Overview](screenshots/dashboard_overview.png)
![Pareto](screenshots/pareto_analysis.png)
![Cohort](screenshots/cohort_analysis.png)
![Revenue Cohort](screenshots/revenue_cohort_analysis.png)
![RLS](screenshots/rls_demo.png)

---

## 🚀 Key Learnings

* End-to-end data analytics workflow
* SQL optimization & business analysis
* Power BI advanced features (RLS, Incremental Refresh)
* Data storytelling

---

## 👨‍💻 Author

Rajeev Dhami

