--  Phase 2: Business KPI & Analytical Model Building
use RetailInventoryAnalysis;


SELECT TOP 10 * FROM dbo.begin_inventory;
SELECT TOP 10 * FROM dbo.end_inventory;
SELECT TOP 10 * FROM dbo.purchase_prices;
SELECT TOP 10 * FROM dbo.purchases;
SELECT TOP 10 * FROM sales; 
SELECT TOP 10 * FROM dbo.vendor_invoice; 

-- Underperforming Brands
-- 🎯 Goal:
-- Identify brands/products that aren't selling well or have poor profitability.

UPDATE STATISTICS sales;
UPDATE STATISTICS purchases;

-- Step 1: Aggregate sales data (recent period)
WITH SalesAgg AS (
    SELECT 
        Brand,
        Description,
        SUM(SalesQuantity) AS TotalUnitsSold,
        SUM(SalesDollars) AS TotalRevenue
    FROM dbo.sales
    WHERE SalesDate BETWEEN '2024-01-01' AND '2024-01-31'
    GROUP BY Brand, Description
),

-- Step 2: Aggregate purchase data (only recent relevant invoices)
PurchaseAgg AS (
    SELECT
        Brand,
        Description,
        SUM(Dollars) AS TotalCost,
        SUM(Quantity) AS TotalQty
    FROM dbo.purchases
    WHERE InvoiceDate BETWEEN '2023-12-01' AND '2024-01-31'
      AND Dollars IS NOT NULL
    GROUP BY Brand, Description
)

-- Step 3: Join and calculate margin
SELECT TOP 10 
    S.Brand,
    S.Description,
    S.TotalUnitsSold,
    S.TotalRevenue,

    -- Adjusted cost estimation based on proportional cost of purchased quantity
    ROUND(
        COALESCE(
            (S.TotalUnitsSold * 1.0 / NULLIF(P.TotalQty, 0)) * P.TotalCost,
            0
        ), 
        2
    ) AS AdjustedCost,

    -- Profit Margin %
    ROUND(
        (
            (S.TotalRevenue - 
             COALESCE((S.TotalUnitsSold * 1.0 / NULLIF(P.TotalQty, 0)) * P.TotalCost, 0))
            / NULLIF(S.TotalRevenue, 0)
        ) * 100.0, 
        2
    ) AS ProfitMarginPct

FROM SalesAgg S
LEFT JOIN PurchaseAgg P
    ON S.Brand = P.Brand AND S.Description = P.Description

-- Show underperforming: low volume or low margin
WHERE S.TotalUnitsSold < 10
    OR (
        (
            S.TotalRevenue - 
            COALESCE((S.TotalUnitsSold * 1.0 / NULLIF(P.TotalQty, 0)) * P.TotalCost, 0)
        ) / NULLIF(S.TotalRevenue, 0)
    ) * 100.0 < 20

ORDER BY ProfitMarginPct;



SELECT COUNT(*) 
FROM dbo.sales s
JOIN dbo.purchases p  ON s.InventoryId = p.InventoryId AND s.Store = p.Store;

select COUNT(*) from dbo.purchases



-- ✅ 2. 🏆 Top Vendors by Sales and Profit
-- 🎯 Goal:
-- Rank vendors contributing most to profit and revenue.

select top 10 * from purchases;
select top 10 * from sales;

-- Sales Summary by Vendor
WITH SalesData AS (
    SELECT
        VendorNo,
        VendorName,
        SUM(SalesDollars) AS TotalSales,
        SUM(SalesQuantity) AS TotalUnits
    FROM sales
    GROUP BY VendorNo, VendorName
),
PurchaseCost AS (
    SELECT
        VendorNumber,
        VendorName,
        SUM(Dollars) AS TotalCost
    FROM purchases
    GROUP BY VendorNumber, VendorName
)
SELECT TOP 10 
    s.VendorNo AS VendorNumber,
    s.VendorName,
    S.TotalUnits,
    s.TotalSales,
    p.TotalCost,
    (s.TotalSales - p.TotalCost) AS GrossProfit,
    ROUND((s.TotalSales - ISNULL(p.TotalCost, 0)) / s.TotalSales * 100, 2) AS ProfitMarginPct
FROM SalesData s
LEFT JOIN PurchaseCost p
    ON s.VendorNo = p.VendorNumber AND s.VendorName = p.VendorName
ORDER BY GrossProfit DESC;


