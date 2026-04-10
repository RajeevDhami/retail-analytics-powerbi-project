-- =============================================
-- Retail Analytics SQL Analysis
-- Author: Rajeev Dhami
-- Description: Data cleaning, transformation, and business insights
-- =============================================


/* =========================================
   1. DATA EXPLORATION
========================================= */

-- Total Records
SELECT COUNT(*) FROM OnlineRetail;

-- Sample Data
SELECT TOP 10 * FROM OnlineRetail;

-- Table Structure
EXEC sp_help 'OnlineRetail';


/* =========================================
   2. DATA CLEANING
========================================= */

-- Fix Data Type Issue
ALTER TABLE OnlineRetail
ALTER COLUMN StockCode VARCHAR(20);

-- Check Duplicates
SELECT COUNT(*)
FROM (
	SELECT *,
		COUNT(*) OVER(
		PARTITION BY Invoice, StockCode, Quantity, Price, InvoiceDate
		) AS dup_count
	FROM OnlineRetail
) t
WHERE dup_count > 1;

-- Remove Duplicates
WITH CTE AS (
	SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY Invoice, StockCode, Quantity, Price, InvoiceDate
			ORDER BY (SELECT NULL)
		) AS rn
	FROM OnlineRetail
)
DELETE FROM CTE
WHERE rn > 1;


/* =========================================
   3. KPI CALCULATIONS
========================================= */

-- Total Revenue
SELECT SUM(TotalPrice) AS Total_Revenue
FROM OnlineRetail;

-- Average Order Value
SELECT 
	SUM(TotalPrice) / COUNT(DISTINCT Invoice) AS Avg_Order_Value
FROM OnlineRetail;


/* =========================================
   4. TIME-BASED ANALYSIS
========================================= */

-- Monthly Revenue Trend
SELECT 
	YEAR(InvoiceDate) AS Year,
	MONTH(InvoiceDate) AS Month,
	SUM(TotalPrice) AS Revenue
FROM OnlineRetail
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY Year, Month;


/* =========================================
   5. PRODUCT ANALYSIS
========================================= */

-- Top Products by Revenue
SELECT TOP 10
	Description,
	SUM(TotalPrice) AS Revenue
FROM OnlineRetail
GROUP BY Description
ORDER BY Revenue DESC;


/* =========================================
   6. CUSTOMER ANALYSIS
========================================= */

-- Top Customers
SELECT TOP 10
	Customer_ID,
	SUM(TotalPrice) AS Total_Spent
FROM OnlineRetail
GROUP BY Customer_ID
ORDER BY Total_Spent DESC;


/* =========================================
   7. CUSTOMER SEGMENTATION
========================================= */

-- Customer Segmentation
SELECT
	Customer_ID,
	SUM(TotalPrice) AS Total_Spent,
	CASE
		WHEN SUM(TotalPrice) > 10000 THEN 'High Value'
		WHEN SUM(TotalPrice) > 5000 THEN 'Medium Value'
		ELSE 'Low Value'
	END AS Customer_Segment
FROM OnlineRetail
GROUP BY Customer_ID;


/* =========================================
   8. ADVANCED ANALYSIS (PARETO)
========================================= */

-- Top 20% Contribution
SELECT 
    SUM(TotalPrice) AS TotalRevenue,
    MAX(t2.Top20Revenue) AS Top20Revenue,
    MAX(t2.Top20Revenue) * 100.0 / SUM(TotalPrice) AS Contribution_Percentage
FROM OnlineRetail
CROSS JOIN (
    SELECT SUM(Revenue) AS Top20Revenue
    FROM (
        SELECT TOP 20 Customer_ID, SUM(TotalPrice) AS Revenue
        FROM OnlineRetail
        GROUP BY Customer_ID
        ORDER BY Revenue DESC
    ) t
) t2;
