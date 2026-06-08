/* =========================================
   SECTION 1: KPI CALCULATIONS
========================================= */
USE OnlineRetailDB
SELECT COUNT(*) FROM OnlineRetail

CREATE CLUSTERED INDEX IX_OnlineRetail_InvoiceDate
ON OnlineRetail(InvoiceDate);

CREATE NONCLUSTERED INDEX IX_Online_Retail_Customer
ON OnlineRetail (Customer_ID)
INCLUDE(TotalPrice);

ALTER TABLE OnlineRetail
ALTER COLUMN StockCode VARCHAR(50) NOT NULL;
GO

ALTER TABLE OnlineRetail
ALTER COLUMN Description VARCHAR(255) NOT NULL;
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Online_Retail_StockCode' AND object_id = OBJECT_ID('OnlineRetail'))
DROP INDEX IX_Online_Retail_StockCode ON OnlineRetail;

CREATE NONCLUSTERED INDEX IX_Online_Retail_StockCode
ON OnlineRetail (StockCode)
INCLUDE (TotalPrice, Quantity);

--1. Total Revenue
SELECT
	ROUND(SUM(TotalPrice),2) AS Total_Revenue
FROM OnlineRetail;

--2. Total Orders
SELECT
	COUNT(DISTINCT Invoice) AS Total_Orders
FROM OnlineRetail;

--3. Total Cusotmers
SELECT 
	COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM OnlineRetail;

--4. Average Order Value (AOV)
SELECT
	ROUND(SUM(TotalPrice) / COUNT(DISTINCT Invoice), 2) AS Average_Order_Value
FROM OnlineRetail;

--5. Average Revenue per Customer
SELECT
	ROUND(SUM(TotalPrice) / COUNT(DISTINCT Customer_ID), 2) AS Average_Revenue_Per_Customer
FROM OnlineRetail;

--6. Total Units Sold
SELECT
	SUM(Quantity) AS Total_Units_Sold
FROM OnlineRetail;

/*=====================================
SECTION 2: TIME-BASED ANALYSIS
=====================================*/

--1. Monthly Revenue Trend
SELECT
	YEAR(InvoiceDate) AS Year,
	MONTH(InvoiceDate) AS Month,
	DATEFROMPARTS(YEAR(InvoiceDate), Month(InvoiceDate), 1) AS Month_Start,
	ROUND(SUM(TotalPrice), 2) AS Monthly_Revenue,
	COUNT(DISTINCT Invoice) AS Orders,
	COUNT(DISTINCT Customer_ID) AS Customers
FROM OnlineRetail
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY Year, Month;

--2. Year-on-Year (YoY) Revenue Comparison
WITH MonthlyRevenue AS (
SELECT
	YEAR(InvoiceDate) AS Year,
	MONTH(InvoiceDate) AS Month,
	ROUND(SUM(TotalPrice),2) AS Revenue
FROM OnlineRetail
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
)
SELECT
	Month,
	MAX(CASE WHEN Year = 2010 THEN Revenue END)AS Revenue_2010,
	MAX(CASE WHEN Year = 2011 THEN Revenue END) AS Revenue_2011,
	ROUND(MAX(CASE WHEN Year = 2011 THEN Revenue END)-
	MAX(CASE WHEN Year = 2010 THEN Revenue END ) / 
	MAX(CASE WHEN Year = 2010 THEN Revenue END ) * 100,
	2
	) AS YoY_Growth_Percentage
FROM MonthlyRevenue
GROUP BY Month
ORDER BY Month;

--3. Quarterly Performance analysis
SELECT
	YEAR(InvoiceDate) AS Year,
	'Q' + CAST(CEILING(CAST(MONTH(InvoiceDate) AS FLOAT) / 3)AS VARCHAR) AS Quarter,
	ROUND(SUM(TotalPrice),2) AS Quarterly_Revenue,
	COUNT(DISTINCT Invoice) AS Orders,
	ROUND(SUM(TotalPrice)/COUNT(DISTINCT Invoice),2) AS Avg_Order_Value
FROM OnlineRetail
GROUP BY YEAR(InvoiceDate), CEILING(CAST(MONTH(InvoiceDate) AS FLOAT)/3)
ORDER BY Year, Quarter;

--4. Seasonal Sales Analysis (Monthly Comparison Across Years)
SELECT 
	MONTH(InvoiceDate) AS Month,
	CASE
		WHEN MONTH(InvoiceDate) IN (12, 1, 2) THEN 'Winter'
		WHEN MONTH(InvoiceDate) IN (3, 4, 5) THEN 'Spring'
		WHEN MONTH(InvoiceDate) IN (6 ,7, 8) THEN 'Summer'
		WHEN MONTH(InvoiceDate) IN (9, 10, 11) THEN 'Fall'
	END AS Season,
	ROUND(AVG(TotalPrice), 2) AS Avg_Transaction_value,
	ROUND(SUM(TotalPrice), 2) AS Total_Seasonal_Revenue,
	COUNT(DISTINCT Invoice) AS Total_Orders
FROM OnlineRetail
GROUP BY MONTH(InvoiceDate),
	CASE
		WHEN MONTH(InvoiceDate) IN (12, 1, 2) THEN 'Winter'
		WHEN MONTH(InvoiceDate) IN (3, 4, 5) THEN 'Spring'
		WHEN MONTH(InvoiceDate) IN (6 ,7, 8) THEN 'Summer'
		WHEN MONTH(InvoiceDate) IN (9, 10, 11) THEN 'Fall'
	END
ORDER BY Month;

-- Seasonal Sales Aggregated
WITH SeasonData AS (
	SELECT
		CASE
			WHEN MONTH(InvoiceDate) IN (12,1,2) THEN 'Winter'
			WHEN MONTH(InvoiceDate) IN (3,4,5) THEN 'Spring'
			WHEN MONTH(InvoiceDate) IN (6,7,8) THEN 'Summer'
			WHEN MONTH(InvoiceDate) IN (9,10,11) THEN 'Fall'
		END AS Season,
		TotalPrice,
		Invoice,
		Customer_ID
	FROM OnlineRetail
)
SELECT
	Season,
	ROUND(AVG(TotalPrice),2) AS Avg_Transaction_Value,
	ROUND(SUM(TotalPrice),2) AS Total_Seasonal_Revenue,
	COUNT(DISTINCT Invoice) AS Total_Orders,
	COUNT(DISTINCT Customer_ID) AS Unique_Customers,
	ROUND(SUM(TotalPrice) / COUNT(DISTINCT Invoice),2) AS Avg_Order_Value
FROM SeasonData
GROUP BY Season
ORDER BY 
	CASE Season
		WHEN 'Winter' THEN 1
		WHEN 'Spring' THEN 2
		WHEN 'Summer' THEN 3
		WHEN 'Fall' THEN 4
	END;
--5. Customer Acquisition Trend (New Customer By month)
WITH FirstPurchase AS (
	SELECT 
		Customer_ID,
		MIN(YEAR(InvoiceDate)) AS First_Year,
		MIN(MONTH(InvoiceDate)) AS First_Month
	FROM OnlineRetail
	GROUP BY Customer_ID
)
SELECT 
	First_Year AS Year,
	First_Month AS Month,
	COUNT(Customer_ID) AS New_Customer_Acquired
FROM FirstPurchase
GROUP BY First_Year, First_Month
Order BY First_Year, First_Month


/*==========================================
SECTION 3: CUSTOMER ANALYSIS
=========================================*/

--1. Top 10 Customers By revenue
SELECT TOP 10
	Customer_ID,
	COUNT(DISTINCT Invoice) AS Total_Orders,
	COUNT(DISTINCT CAST(InvoiceDate AS DATE)) AS Unique_Purchase_Days,
	ROUND(SUM(TotalPrice),2) AS Total_Revenue,
	ROUND(AVG(TotalPrice),2) AS Avg_Transaction_Value,
	MIN(InvoiceDate) AS First_Purchase_Date,
	MAX(InvoiceDate) AS Last_Purchase_Date
FROM OnlineRetail
GROUP BY Customer_ID
ORDER BY Total_Revenue DESC

--2. Customer Count by Year (Growth Rate)

WITH YearlyCustomers AS (
	SELECT
		YEAR(InvoiceDate) AS Year,
		COUNT(DISTINCT Customer_ID) AS Total_Customers
	FROM OnlineRetail
	GROUP BY YEAR(InvoiceDate)
)
SELECT 
	Year,
	Total_Customers,
	LAG(Total_Customers) OVER (ORDER BY YEAR) AS Previous_Year_Customers,
	CASE
		WHEN LAG(Total_Customers) OVER (ORDER BY Year) IS NULL THEN NULL
		ELSE ROUND(
			((CAST(Total_Customers AS FLOAT) - LAG(Total_Customers) OVER (ORDER BY Year)) /
			LAG(Total_Customers) OVER (ORDER BY Year)) * 100,
			2
			) 
		END AS YoY_Growth_Percentage
FROM YearlyCustomers
ORDER BY Year;

--3. New vs Repeat Customers (Monthly)

ALTER VIEW vw_Monthly_New_Vs_Repeat_Dynamics AS

WITH CustomerCountry AS (
	SELECT
		Customer_ID,
		Country,
		ROW_NUMBER() OVER (
			PARTITION BY Customer_ID
			ORDER BY InvoiceDate
			) AS rn
	FROM OnlineRetail
	WHERE Customer_ID IS NOT NULL
	),

FirstPurchase AS (
	SELECT 
			Customer_ID,
			DATEFROMPARTS(MIN(YEAR(InvoiceDate)), MIN(MONTH(InvoiceDate)), 1) AS First_Purchase_Month
			FROM OnlineRetail
			WHERE Customer_ID IS NOT NULL
			GROUP BY CUSTOMER_ID
	),
MonthlyTransaction AS (
		SELECT
				Customer_ID,
				DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS Trans_Month_Date,
				SUM(TotalPrice) AS Total_Revenue
		FROM OnlineRetail
		WHERE Customer_ID IS NOT NULL
		GROUP BY Customer_ID, DATEFROMPARTS(YEAR(InvoiceDate), Month(InvoiceDate), 1) 
)

SELECT
	MT.Trans_Month_Date,
	YEAR(MT.Trans_Month_Date) AS Trans_Year,
	MONTH(MT.Trans_Month_Date) AS Trans_Month,
	CC.Country,
	CASE
			WHEN MT.Trans_Month_Date = FP.First_Purchase_Month THEN 'New Customer'
			ELSE 'Repeat Customer'
	END AS Customer_Type,
	MT.Customer_ID,
	ROUND(MT.Total_Revenue, 2) AS Revenue
FROM MonthlyTransaction MT
LEFT JOIN FirstPurchase FP ON MT.Customer_ID = FP.Customer_ID
LEFT JOIN CustomerCountry CC ON MT.Customer_ID = CC.Customer_ID
AND CC.rn = 1;




--4. Customer Lifetime Value (CLV) - Segmentation


ALTER VIEW vw_Customer_RFM_Segments
AS

WITH CustomerCountry AS (
SELECT
Customer_ID,
Country,
ROW_NUMBER() OVER (
PARTITION BY Customer_ID
ORDER BY InvoiceDate
) AS rn
FROM OnlineRetail
WHERE Customer_ID IS NOT NULL
),

CustomerRFM AS (
SELECT
Customer_ID,
DATEDIFF(DAY, MAX(InvoiceDate), '2011-11-30') AS Recency_Days,
COUNT(DISTINCT Invoice) AS Frequency,
SUM(TotalPrice) AS Monetary,
MIN(InvoiceDate) AS First_Purchase_Date,
MAX(InvoiceDate) AS Last_Purchase_Date
FROM OnlineRetail
WHERE Customer_ID IS NOT NULL
GROUP BY Customer_ID
),

RFMPercentiles AS (
SELECT
Customer_ID,
Recency_Days,
Frequency,
Monetary,
First_Purchase_Date,
Last_Purchase_Date,
PERCENT_RANK() OVER (ORDER BY Recency_Days ASC) AS R_Pct,
PERCENT_RANK() OVER (ORDER BY Frequency ASC) AS F_Pct,
PERCENT_RANK() OVER (ORDER BY Monetary ASC) AS M_Pct
FROM CustomerRFM
),

RFMScores AS (
SELECT
*,
FLOOR(R_Pct * 4) + 1 AS R_Score,
FLOOR(F_Pct * 4) + 1 AS F_Score,
FLOOR(M_Pct * 4) + 1 AS M_Score
FROM RFMPercentiles
)

SELECT
R.Customer_ID,
CC.Country,
R.Recency_Days,
R.Frequency,
R.Monetary,
R.First_Purchase_Date,
R.Last_Purchase_Date,
R.R_Score,
R.F_Score,
R.M_Score,
CONCAT(R.R_Score, R.F_Score, R.M_Score) AS RFM_Score,
CASE
WHEN R.Recency_Days > 365 THEN 'Inactive-Reactivation Needed'
WHEN R.R_Score >= 4 AND R.F_Score >= 4 AND R.M_Score >= 4 THEN 'Strategic Partner'
WHEN R.R_Score >= 4 AND R.F_Score >= 3 AND R.M_Score >= 3 THEN 'Key Account'
WHEN R.R_Score >= 3 AND R.F_Score >= 3 AND R.M_Score >= 3 THEN 'Regular Partner'
WHEN R.R_Score >= 3 AND R.M_Score >= 3 THEN 'Growing Partnership'
WHEN R.R_Score < 3 AND R.M_Score >= 4 THEN 'Seasonal Partner'
ELSE 'Emerging Account'
END AS WholeSale_Segment
FROM RFMScores R
LEFT JOIN CustomerCountry CC
ON R.Customer_ID = CC.Customer_ID
AND CC.rn = 1
WHERE R.Customer_ID IS NOT NULL;


GO



--CLV Segment
SELECT 
	WholeSale_Segment,
	COUNT(*) AS Customer_Count,
	ROUND(AVG(Monetary), 2) AS Avg_Customer_Value,
	ROUND(AVG(Frequency),2) AS Avg_Order_Per_Customer,
	ROUND(AVG(CAST(Recency_Days AS FLOAT)),0) AS Avg_Days_Since_Purchase,
	MIN(Monetary) AS Min_Customer_Value,
	MAX(Monetary) AS Max_Customer_Value,
	ROUND(SUM(Monetary) * 100.0 / (SELECT SUM(Monetary) FROM vw_Customer_RFM_Segments),2) AS_Revenue_Contribution_Percentage
	FROM vw_Customer_RFM_Segments
	GROUP BY WholeSale_Segment
	ORDER BY Avg_Customer_Value DESC;




/*===================================================
 SECTION 4: PRODUCT ANALYSIS AND ABC CLASSIFICATION
 ===================================================*/

ALTER VIEW vw_Product_ABC_Analysis
AS

WITH ProductSummary AS (
    SELECT
        StockCode,
        MAX(TRIM(Description)) AS Description,
        SUM(TotalPrice) AS Total_Spent,
        COUNT(DISTINCT Invoice) AS Orders,
        SUM(Quantity) AS Units_Sold
    FROM OnlineRetail
    GROUP BY StockCode
),

TotalRevenueCTE AS (
    SELECT
        SUM(Total_Spent) AS GrandTotal
    FROM ProductSummary
),

CumulativeCTE AS (
    SELECT
        p.StockCode,
        p.Description,
        p.Total_Spent,
        p.Orders,
        p.Units_Sold,

        SUM(p.Total_Spent) OVER (
            ORDER BY p.Total_Spent DESC
        ) AS Cumulative_Revenue,

        ROUND(
            100.0 *
            SUM(p.Total_Spent) OVER (
                ORDER BY p.Total_Spent DESC
            ) / t.GrandTotal,
            2
        ) AS Cumulative_Percentages,

        ROW_NUMBER() OVER (
            ORDER BY p.Total_Spent DESC
        ) AS Product_Rank,

        COUNT(*) OVER() AS Total_Distinct_Products

    FROM ProductSummary p
    CROSS JOIN TotalRevenueCTE t
)

SELECT
    StockCode,
    Description,
    Total_Spent,
    Orders,
    Units_Sold,
    Cumulative_Percentages,
    Product_Rank,
    Total_Distinct_Products,

    CASE
        WHEN Cumulative_Percentages <= 80 THEN 'A'
        WHEN Cumulative_Percentages <= 95 THEN 'B'
        ELSE 'C'
    END AS ABC_Class

FROM CumulativeCTE;





GO


-- Product contribution percentages
SELECT
	ABC_Class,
	COUNT(*) AS Product_Count,
	ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(),2) AS Inventory_Share_Percentages,
	SUM(Total_Spent) AS Total_Revenue_Contribution,
	MAX(Cumulative_Percentages) AS Cumulative_Revenue_Percentages
FROM vw_Product_ABC_Analysis
GROUP BY ABC_Class
ORDER BY ABC_Class;

-- Detailed Product Performances

SELECT
	ABC_Class,
	COUNT(*) AS Total_Products,
	ROUND(AVG(Total_Spent),2) AS Avg_Product_Revenue,
	ROUND(MAX(Total_Spent),2) AS Top_Product_Revenue,
	ROUND(MIN(Total_Spent),2) AS Lowest_Product_Revenue,
	SUM(Units_Sold) AS Total_Units_Sold
FROM vw_Product_ABC_Analysis
GROUP BY ABC_Class
ORDER BY ABC_Class;

-- Top 10 Product by Revenue
SELECT TOP 10
	StockCode,
	Description,
	Total_Spent AS Revenue
FROM vw_Product_ABC_Analysis
ORDER BY Total_Spent DESC;


CREATE VIEW Dim_Product AS
SELECT
	StockCode,
	MAX(TRIM(Description)) AS Description
FROM OnlineRetail
GROUP BY StockCode; 


ALTER VIEW Dim_Country AS
SELECT DISTINCT
	TRIM(Country) AS Country
FROM OnlineRetail
WHERE Country IS NOT NULL;






/* =====================================================================
   SECTION 5: ADVANCED BEHAVIORAL SEGMENTATION & CROSS-ANALYSIS
   ===================================================================== */


WITH RankedCustomers AS (
    SELECT 
        Customer_ID,
        Monetary,
        SUM(Monetary) OVER (ORDER BY Monetary DESC) AS Running_Revenue,
        (SELECT SUM(Monetary) FROM vw_Customer_RFM_Segments) AS Total_Company_Revenue,
        ROW_NUMBER() OVER (ORDER BY Monetary DESC) AS Customer_Rank,
        (SELECT COUNT(*) FROM vw_Customer_RFM_Segments) AS Total_Customers
    FROM vw_Customer_RFM_Segments
),
ParetoCalculation AS (
    SELECT 
        Customer_ID,
        Monetary,
        Customer_Rank,
        ROUND(100.0 * Customer_Rank / Total_Customers, 2) AS Cumulative_Customer_Pct,
        ROUND(100.0 * Running_Revenue / Total_Company_Revenue, 2) AS Cumulative_Revenue_Pct
    FROM RankedCustomers
)
-- Now we query the finished calculation cleanly
SELECT * FROM ParetoCalculation
-- This rough rounding check ensures we grab rows near our targets
WHERE ROUND(Cumulative_Customer_Pct, 0) IN (5.00, 10.00, 20.00, 30.00, 50.00)
   OR Customer_Rank IN (1, 10, 100, 500, 1000)
ORDER BY Customer_Rank;


-- Cross-Analysis Matrix: Customer Segments by Product ABC Revenue

WITH TransactionMediation AS (
	SELECT 
		cust.Wholesale_Segment,
		prod.ABC_Class,
		SUM(tx.TotalPrice) AS Segment_Product_Revenue
	FROM OnlineRetail tx
	INNER JOIN vw_Customer_RFM_Segments cust ON tx.Customer_ID = cust.Customer_ID
	INNER JOIN vw_Product_ABC_Analysis prod ON tx.StockCode = prod.StockCode AND tx.Description = prod.Description
	GROUP BY cust.WholeSale_Segment, prod.ABC_Class
	),
SegmentTotals AS (
	SELECT
		Wholesale_Segment,
		SUM(Segment_Product_Revenue) AS Total_Segment_Revenue
	FROM TransactionMediation
	GROUP BY WholeSale_Segment
)
SELECT
	tm.Wholesale_Segment,
	ROUND(SUM(CASE WHEN tm.ABC_CLASS = 'A' THEN tm.Segment_Product_Revenue ELSE 0 END), 2) AS Spent_On_Class_A,
	ROUND(SUM(CASE WHEN tm.ABC_CLASS = 'B' THEN tm.Segment_Product_Revenue ELSE 0 END), 2) AS Spent_On_Class_B,
	ROUND(SUM(CASE WHEN tm.ABC_CLASS = 'C' THEN tm.Segment_Product_Revenue ELSE 0 END), 2) AS Spent_On_Class_C,
	ROUND(100.0 * SUM(CASE WHEN tm.ABC_CLASS = 'A' THEN tm.Segment_Product_Revenue ELSE 0 END) / st.Total_Segment_Revenue, 2) AS Class_A_Budget_Share_Pct
FROM TransactionMediation tm
INNER JOIN SegmentTotals st ON tm.WholeSale_Segment = st.WholeSale_Segment
GROUP BY tm.WholeSale_Segment, st.Total_Segment_Revenue
ORDER BY Class_A_Budget_Share_Pct DESC;




SELECT 
	Wholesale_Segment,
	COUNT(DISTINCT Customer_ID) AS Unique_Customers,
	ROUND(AVG(Monetary), 2) AS Avg_Lifetime_Spend,
	ROUND(AVG(CAST(frequency AS FLOAT)), 2) AS Avg_Order_Value
FROM vw_Customer_RFM_Segments
GROUP BY WholeSale_Segment
ORDER BY Avg_Order_Value DESC;



/*=======================================================
SECTION 6: TIME-SERIES, SEASONALITY, AND OPERATIONAL PEAK
=======================================================*/

-- Monthly Revenue Velocity and Transaction Trends
SELECT 
	YEAR(InvoiceDate) AS Calender_Year,
	MONTH(InvoiceDate) AS Calender_Month,
	DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS Month_Start_Date,
	ROUND(SUM(TotalPrice), 2) AS Monthly_Revenue,
	COUNT(DISTINCT Invoice) AS Total_Orders,
	COUNT(DISTINCT Customer_ID) AS Active_Buyers,
	ROUND(SUM(TotalPrice) / COUNT(DISTINCT Invoice), 2) AS Avg_Order_Value
FROM OnlineRetail
GROUP BY YEAR(InvoiceDate), Month(InvoiceDate)
ORDER BY Calender_Year, Calender_Month

--Weekly and Hourly Operational Peak Demand
SELECT
	DATEPART(WEEKDAY, InvoiceDate) AS Day_Of_Week_Numeric,
	DATENAME(WEEKDAY, InvoiceDate) AS Day_Of_Week_Name,
	DATEPART(HOUR, InvoiceDate) AS Transaction_Hour,
	COUNT(DISTINCT Invoice) AS Total_Orders_Placed,
	SUM(Quantity) AS Total_items_Picked,
	ROUND(SUM(TotalPrice), 2) AS Total_Hourly_Revenue
FROM OnlineRetail
GROUP BY DATEPART(WEEKDAY, InvoiceDate), DATENAME(WEEKDAY, InvoiceDate), DATEPART(HOUR, InvoiceDate)
ORDER BY Day_Of_Week_Numeric,Transaction_Hour;

--YoY Growth Rate
WITH MonthlyData AS (
	SELECT 
		YEAR(InvoiceDate) AS Calender_Year,
		MONTH(InvoiceDate) AS Calender_Month,
		SUM(TotalPrice) AS Revenue
	FROM OnlineRetail
	GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
	),
YoY_Comparision AS (
	SELECT
		Y10.Calender_Month,
		DATENAME(MONTH, DATEFROMPARTS(2010, Y10.Calender_Month, 1)) AS Month_Name,
		ROUND(Y10.Revenue, 2) AS Revenue_2010,
		ROUND(Y11.Revenue, 2) AS Revenue_2011,
		ROUND(Y11.Revenue - Y10.Revenue, 2) AS Net_Cash_Change
	FROM MonthlyData Y10
	LEFT JOIN MonthlyData Y11 ON Y10.Calender_Month = Y11.Calender_Month AND Y11.Calender_Year = 2011
	WHERE Y10.Calender_Year = 2010 AND Y10.Calender_Month <= 11
	)

SELECT 
	Calender_Month,
	Month_Name,
	Revenue_2010,
	Revenue_2011,
	Net_Cash_Change,
	ROUND((Net_Cash_Change / Revenue_2010) * 100.0, 2) AS Growth_Percentage
FROM YoY_Comparision
ORDER BY Calender_Month


/*============================
SECTION  7: COHORT ANALYSIS
=============================*/

--Step 1: Create Cohort Base View

ALTER VIEW vw_Customer_Cohorts
AS

WITH FirstPurchase AS (
SELECT
Customer_ID,
MIN(YEAR(InvoiceDate)) AS Cohort_Year,
MIN(MONTH(InvoiceDate)) AS Cohort_Month,
DATEFROMPARTS(
MIN(YEAR(InvoiceDate)),
MIN(MONTH(InvoiceDate)),
1
) AS Cohort_Date
FROM OnlineRetail
WHERE Customer_ID IS NOT NULL
GROUP BY Customer_ID
),

CustomerCountry AS (
SELECT
Customer_ID,
Country,
ROW_NUMBER() OVER (
PARTITION BY Customer_ID
ORDER BY InvoiceDate
) AS rn
FROM OnlineRetail
WHERE Customer_ID IS NOT NULL
),

AllTransactions AS (
SELECT
fp.Customer_ID,
cc.Country,
fp.Cohort_Year,
fp.Cohort_Month,
fp.Cohort_Date,
YEAR(tx.InvoiceDate) AS Trans_Year,
MONTH(tx.InvoiceDate) AS Trans_Month,
DATEFROMPARTS(
YEAR(tx.InvoiceDate),
MONTH(tx.InvoiceDate),
1
) AS Trans_Month_Date,
DATEDIFF(
MONTH,
fp.Cohort_Date,
DATEFROMPARTS(
YEAR(tx.InvoiceDate),
MONTH(tx.InvoiceDate),
1
)
) AS Cohort_Age_Months,
tx.TotalPrice,
tx.Invoice
FROM FirstPurchase fp
INNER JOIN OnlineRetail tx
ON fp.Customer_ID = tx.Customer_ID
LEFT JOIN CustomerCountry cc
ON fp.Customer_ID = cc.Customer_ID
AND cc.rn = 1
)

SELECT
Customer_ID,
Country,
Cohort_Year,
Cohort_Month,
Cohort_Date,
Trans_Year,
Trans_Month,
Trans_Month_Date,
Cohort_Age_Months,
TotalPrice,
Invoice
FROM AllTransactions;

GO

--Step 2: Customer Cohort Retention Analysis
WITH CohortData AS (
	SELECT
		Cohort_Date,
		Cohort_Age_Months,
		COUNT(DISTINCT Customer_ID) AS Customers_Retained,
		COUNT(DISTINCT Invoice) AS Orders_Placed
	FROM vw_Customer_Cohorts
	GROUP BY Cohort_Date, Cohort_Age_Months
	),
CohortSize AS (
	SELECT 
		Cohort_Date,
		COUNT (DISTINCT Customer_ID) AS Cohort_Size
	FROM vw_Customer_Cohorts
	WHERE Cohort_Age_Months = 0
	GROUP BY Cohort_Date
	),
RetentionRates AS (
	SELECT 
		cd.Cohort_Date,
		cd.Cohort_Age_Months,
		cd.Customers_Retained,
		cs.Cohort_Size,
		ROUND(100.0 * cd.Customers_Retained / cs.Cohort_Size,2) AS Retention_Percentage
	FROM CohortData cd
	INNER JOIN CohortSize cs ON cd.Cohort_Date = cs.Cohort_Date
	)
SELECT
	FORMAT (Cohort_Date, 'yyyy-MM') AS Cohort_Month,
	Cohort_Size,
	Cohort_Age_Months,
	Customers_Retained,
	Retention_Percentage
FROM RetentionRates
ORDER BY Cohort_Date, Cohort_Age_Months;
GO

--Step 3: Revenue Cohort Analysis
WITH CohortRevenue AS (
	SELECT
		Cohort_Date,
		Cohort_Age_Months,
		SUM(TotalPrice) AS Revenue_This_Month
	FROM vw_Customer_Cohorts
	GROUP BY Cohort_Date, Cohort_Age_Months
	),
CohortFirstMonthRevenue AS (
	SELECT
		Cohort_Date,
		SUM(TotalPrice) AS Initial_Cohort_Revenue
		FROM vw_Customer_Cohorts
		WHERE Cohort_Age_Months = 0
		GROUP BY Cohort_Date
	),
RevenueRetention AS (
	SELECT 
		cr.Cohort_Date,
		cr.Cohort_Age_Months,
		cr.Revenue_This_Month,
		cfr.Initial_Cohort_Revenue,
		ROUND( 100.0 * cr.Revenue_This_Month / cfr.Initial_Cohort_Revenue, 2) AS Revenue_Retention_Percentage
		FROM CohortRevenue cr
		INNER JOIN CohortFirstMonthRevenue cfr ON cr.Cohort_Date = cfr.Cohort_Date
	)
SELECT
	FORMAT(Cohort_Date, 'yyyy-MM') AS Cohort_Month,
	Cohort_Age_Months,
	ROUND(Initial_Cohort_Revenue, 2) AS Initial_Cohort_Revenue,
	ROUND(Revenue_This_Month, 2) AS Revenue_This_Month,
	Revenue_Retention_Percentage
FROM RevenueRetention
ORDER BY Cohort_Date, Cohort_Age_Months;
GO

--Step 4: Cohort Comparision Summary 
WITH CohortMetrics AS (
	SELECT
		Cohort_Date,
		COUNT(DISTINCT Customer_ID) AS Cohort_Size,
		COUNT(DISTINCT CASE WHEN Cohort_Age_Months > 0 THEN Customer_ID END) AS Retained_Customers,
		COUNT(DISTINCT Invoice) AS Total_Orders,
		SUM(TotalPrice) AS Total_Revenue
	FROM vw_Customer_Cohorts
	GROUP BY Cohort_Date
)
SELECT 
	FORMAT(Cohort_Date, 'yyyy-MM') AS Cohort_Month,
	Cohort_Size,
	Retained_Customers,
	ROUND(100.0 * Retained_Customers / Cohort_Size, 2) AS Retention_Rate_Pct,
	Total_Orders,
	ROUND(Total_Revenue, 2) AS Total_Revenue,
	ROUND(Total_Revenue / Total_Orders, 2) AS Avg_Order_Value
FROM CohortMetrics
ORDER BY Cohort_Date DESC;
GO


SELECT 
    Cohort_Date,
    Cohort_Age_Months,
    COUNT(DISTINCT Customer_ID) AS Customer_Count,
    SUM(TotalPrice) AS Revenue,
    COUNT(*) AS Transaction_Count
FROM vw_Customer_Cohorts
GROUP BY Cohort_Date, Cohort_Age_Months
ORDER BY Cohort_Date, Cohort_Age_Months;



-- Check Month 0 counts for each cohort
SELECT 
    Cohort_Date,
    COUNT(DISTINCT Customer_ID) AS Customers_At_Month_0
FROM vw_Customer_Cohorts
WHERE Cohort_Age_Months = 0
GROUP BY Cohort_Date
ORDER BY Cohort_Date;


-- Show Jan 2010 cohort detail
SELECT 
    Cohort_Date,
    Cohort_Age_Months,
    COUNT(DISTINCT Customer_ID) AS Customer_Count
FROM vw_Customer_Cohorts
WHERE Cohort_Date = '2010-01-01'
GROUP BY Cohort_Date, Cohort_Age_Months
ORDER BY Cohort_Age_Months;


--STEP 5: Purchase Cycle Analysis (Wholesale Seasonality)
WITH CohortPurchaseCycle AS (
	SELECT
		Cohort_Date,
		Cohort_Age_Months,
		COUNT(DISTINCT Customer_ID) AS Customers_Active,
		LAG(COUNT(DISTINCT Customer_ID)) OVER(PARTITION BY Cohort_Date ORDER BY Cohort_Age_Months) AS Customers_Previous_Month
	FROM vw_Customer_Cohorts
	GROUP BY Cohort_Date, Cohort_Age_Months
)


SELECT 
	FORMAT(Cohort_Date, 'yyyy-MM') AS Cohort_Month,
	Cohort_Age_Months,
	Customers_Active,
	Customers_Previous_Month,
	ROUND(100.0 * (Customers_Previous_Month - Customers_Active) /
	Customers_Previous_Month,2) AS Monthly_Purchase_Gap_Pct,

CASE	
	WHEN Customers_Active = Customers_Previous_Month THEN 'Consistent_Buying'
	WHEN Customers_Active < Customers_Previous_Month THEN 'Seasonal Gap'
	ELSE 'Seasonal Spike'
	END AS Purchase_Pattern
FROM CohortPurchaseCycle
ORDER BY Cohort_Date, Cohort_Age_Months;
GO

--Step 6: High-Value Cohort Analysis (Wholesale Perspective)
WITH CohortSegmentation AS (
	SELECT
		cc.Cohort_Date,
		rs.WholeSale_Segment,
		COUNT(DISTINCT cc.Customer_ID) AS Segment_Customers,
		SUM(cc.TotalPrice) AS Segment_Revenue,
		COUNT(DISTINCT cc.Invoice) AS Segment_Orders
	FROM vw_Customer_Cohorts cc
	INNER JOIN vw_Customer_RFM_Segments rs ON cc.Customer_ID = rs.Customer_ID
	WHERE cc.Cohort_Age_Months = 0
	GROUP BY cc.Cohort_Date, rs.WholeSale_Segment
)
SELECT
	FORMAT(Cohort_Date, 'yyyy-MM') AS Cohort_Month,
	WholeSale_Segment,
	Segment_Customers,
	ROUND(Segment_Revenue, 2) AS Month_0_Revenue,
	ROUND (Segment_Revenue / Segment_Orders, 2) AS Avg_Orders_Value
FROM CohortSegmentation
ORDER BY Cohort_Date DESC, Month_0_Revenue DESC;
GO


/* ===================
GEOGRAPHIC QUERIES
=====================*/

-- The Macro Split: Domestic vs International Core KPIs
SELECT
	CASE WHEN Country = 'United Kingdom' THEN 'Domestic (UK)' ELSE 'International' END AS Market_Type,
	COUNT(DISTINCT Customer_ID) AS Total_Wholesale_Accounts,
	COUNT(DISTINCT Invoice) AS Total_Orders,
	SUM(Quantity * Price) AS Total_Revenue,
	ROUND(SUM(Quantity * Price) / SUM(SUM(Quantity * Price)) OVER() * 100, 2) AS Revenue_Contribution_Pct
FROM OnlineRetail
WHERE Quantity > 0 AND Price > 0 AND Customer_ID IS NOT NULL
GROUP BY CASE WHEN Country = 'United Kingdom' THEN 'Domestic (UK)' ELSE 'International' END;


--International Leaderboard (Excluding the UK Skew)
SELECT TOP 10
	Country,
	COUNT (DISTINCT Customer_ID) AS International_Accounts,
	COUNT(DISTINCT Invoice) AS Total_Orders,
	SUM(Quantity * Price) AS International_Revenue,
	ROUND(SUM(Quantity * Price) / COUNT(DISTINCT Invoice),2) AS Average_Order_Value_AOV
FROM OnlineRetail
WHERE Quantity > 0
	AND Price > 0
	AND Country <> 'United Kingdom'
GROUP BY Country
ORDER BY International_Revenue DESC



--Cross-Border Order Profile (WholeSale Archetype by Region)
SELECT
	CASE WHEN Country = 'United Kingdom' THEN 'Domestic (UK)' ELSE 'International' END AS Market_Type,
	ROUND(SUM(Quantity * Price) / COUNT(DISTINCT Invoice),2) AS Avg_Order_Value_AOV,
	ROUND(SUM(Quantity) / COUNT(DISTINCT Invoice), 0) AS Avg_Units_Per_Order,
	ROUND(SUM(Quantity * Price) / SUM(Quantity), 2) AS Avg_Price_Per_Item
FROM OnlineRetail
GROUP BY CASE WHEN Country = 'United Kingdom' THEN 'Domestic (UK)' ELSE 'International' END

/*==========================
CANCELLATIION ANALYSIS
===========================*/

--SELECT COUNT(*) AS TotalRows FROM OnlineRetailRaw

--EXEC sp_help 'OnlineRetailRaw'

-- Cancellation View
ALTER VIEW dbo.vw_Cancellations_Only AS
SELECT
	Invoice,
	StockCode,
	Description,
	ABS(Quantity) AS Cancelled_Quantity,
	InvoiceDate,
	Price,
	Customer_ID,
	Country,
	ABS(TotalPrice) AS Cancelled_Value
FROM OnlineRetailRaw
WHERE (Invoice LIKE 'C%' OR Quantity < 0)
AND Description NOT IN (
	'POST', 'BANK CHARGES', 'AMAZON FEE', 'M', 'D', 'S', 'PADS', 'DOT'
	)
AND Description IS NOT NULL
AND TRIM(Description) NOT IN ('', ' ')
AND StockCode NOT IN ('POST', 'D', 'M', 'BANK CHARGES', 'AMAZONFEE', 'CRUK', 'S', 'DOT', 'PADS')

GO


-- Valid Sales View
ALTER VIEW vw_Valid_Sales_Only AS
SELECT DISTINCT
    Invoice,
    StockCode,
    TRIM(Description) AS Description,
    Quantity,
    CAST(InvoiceDate AS Date) AS InvoiceDate,
    Price,
    Customer_ID,
    Country,
    TotalPrice AS SalesRevenue
FROM OnlineRetail
WHERE Invoice NOT LIKE 'C%'
  AND Quantity > 0
  AND StockCode NOT IN (
      'ADJUST', 'M', 'AMAZONFEE', 'BANK CHARGES', 
      'D', 'CRUK', 'S'
  )
  AND InvoiceDate >= '2010-01-01'
  AND InvoiceDate < '2011-12-01'

--Geographic Cancellation Analysis
WITH CleanSalesSummary AS (
    -- Group clean sales down to 1 row per country first
    SELECT 
        Country,
        SUM(SalesRevenue) AS Net_Sales_Revenue
    FROM vw_Valid_Sales_Only
    GROUP BY Country
),
CancellationSummary AS (
    -- Group raw cancellations down to 1 row per country first
    SELECT 
        Country,
        SUM(ABS(Quantity * Price)) AS Total_Cancelled_Value
    FROM OnlineRetail
    WHERE Invoice LIKE 'C%' OR Quantity < 0
    GROUP BY Country
)
SELECT 
    clean.Country,
    clean.Net_Sales_Revenue,
    COALESCE(cancel.Total_Cancelled_Value, 0) AS Total_Cancelled_Value,
    ROUND(
        COALESCE(cancel.Total_Cancelled_Value, 0) / NULLIF(clean.Net_Sales_Revenue, 0) * 100, 2
    ) AS Cancellation_Rate_Pct
FROM CleanSalesSummary clean
LEFT JOIN CancellationSummary cancel ON clean.Country = cancel.Country
ORDER BY clean.Net_Sales_Revenue DESC;


--Investigation for nigeria
SELECT * FROM OnlineRetail
WHERE Country = 'Nigeria';

SELECT * FROM OnlineRetailRaw
WHERE Country = 'Nigeria'


-- Product Level Cancellation Analysis
WITH ModernProductNames AS (
    -- Group names by stockcode and pick the most frequent/recent one to avoid duplicates
    SELECT 
        StockCode,
        TRIM(Description) AS Clean_Description,
        ROW_NUMBER() OVER (PARTITION BY StockCode ORDER BY COUNT(*) DESC) as rn
    FROM OnlineRetail
    WHERE Description IS NOT NULL AND Description NOT IN ('?', 'NULL')
    GROUP BY StockCode, TRIM(Description)
),
ProductSales AS (
    -- Clean physical product sales only
    SELECT 
        StockCode,
        SUM(SalesRevenue) AS Gross_Sales_Value,
        SUM(Quantity) AS Gross_Qty_Sold
    FROM vw_Valid_Sales_Only
    WHERE StockCode NOT IN ('M', 'AMAZONFEE', 'BANK CHARGES', 'D', 'POST', 'CRUK')
    GROUP BY StockCode
),
ProductCancellations AS (
    -- Clean physical product cancellations only
    SELECT 
        StockCode,
        SUM(ABS(Quantity * Price)) AS Cancelled_Value,
        SUM(ABS(Quantity)) AS Cancelled_Qty
    FROM OnlineRetail
    WHERE (Invoice LIKE 'C%' OR Quantity < 0)
      AND StockCode NOT IN ('M', 'AMAZONFEE', 'BANK CHARGES', 'D', 'POST', 'CRUK')
    GROUP BY StockCode
)
SELECT TOP 15
    sales.StockCode,
    name.Clean_Description AS Description,
    sales.Gross_Sales_Value,
    COALESCE(cancel.Cancelled_Value, 0) AS Total_Cancelled_Value,
    COALESCE(cancel.Cancelled_Qty, 0) AS Total_Cancelled_Qty,
    ROUND(
        COALESCE(cancel.Cancelled_Value, 0) / NULLIF(sales.Gross_Sales_Value, 0) * 100, 2
    ) AS Product_Cancellation_Rate_Pct
FROM ProductSales sales
INNER JOIN ModernProductNames name ON sales.StockCode = name.StockCode AND name.rn = 1
LEFT JOIN ProductCancellations cancel ON sales.StockCode = cancel.StockCode
ORDER BY Total_Cancelled_Value DESC;



WITH CustomerCancellations AS (
    -- Total cancellation value generated by each unique customer
    SELECT 
        Customer_ID,
        SUM(ABS(Quantity * Price)) AS Total_Customer_Cancelled_Value,
        COUNT(DISTINCT Invoice) AS Cancelled_Orders_Count
    FROM OnlineRetail
    WHERE Customer_ID IS NOT NULL 
      AND (Invoice LIKE 'C%' OR Quantity < 0)
    GROUP BY Customer_ID
)
SELECT 
    rfm.WholeSale_Segment AS RFM_Segment,
    COUNT(DISTINCT rfm.Customer_ID) AS Total_Customers_In_Segment,
    ROUND(SUM(COALESCE(cancel.Total_Customer_Cancelled_Value, 0)), 2) AS Total_Segment_Cancelled_Value,
    SUM(COALESCE(cancel.Cancelled_Orders_Count, 0)) AS Total_Segment_Cancelled_Orders,
    ROUND(AVG(COALESCE(cancel.Total_Customer_Cancelled_Value, 0)), 2) AS Avg_Cancellation_Cost_Per_Customer
FROM vw_Customer_RFM_Segments rfm
LEFT JOIN CustomerCancellations cancel ON rfm.Customer_ID = cancel.Customer_ID
GROUP BY rfm.WholeSale_Segment
ORDER BY Total_Segment_Cancelled_Value DESC;


SELECT * FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME