-- Data cleaning
USE RetailInventoryAnalysis;

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM 
    INFORMATION_SCHEMA.COLUMNS
ORDER BY 
    TABLE_NAME, ORDINAL_POSITION;

-------------------------------------------------------------------------------------

---
-- begin_inventory
-- Convert onHand to INT

SELECT * FROM begin_inventory
WHERE TRY_CAST(onHand AS INT) IS NULL;

-- First, update all rows to proper INT values if necessary
UPDATE begin_inventory
SET onHand = TRY_CAST(onHand AS INT)
WHERE onHand IS NOT NULL;

ALTER TABLE begin_inventory
ALTER COLUMN onHand INT;

-- converting dates
ALTER TABLE begin_inventory
ALTER COLUMN startDate DATE;

select top 10 * from begin_inventory;

-------------------------------------------------------------------------------------

-- end_inventory
-- Convert onHand to INT

SELECT * FROM end_inventory
WHERE TRY_CAST(onHand AS INT) IS NULL;

-- First, update all rows to proper INT values if necessary
UPDATE end_inventory
SET onHand = TRY_CAST(onHand AS INT)
WHERE onHand IS NOT NULL;

ALTER TABLE end_inventory
ALTER COLUMN onHand INT;

-- converting dates
ALTER TABLE end_inventory
ALTER COLUMN endDate DATE; 

select top 10 * from end_inventory;
-------------------------------------------------------------------------------------

-- purchase prices
-- Check if there are non-numeric values
SELECT DISTINCT Volume
FROM purchase_prices
WHERE ISNUMERIC(Volume) = 0 AND Volume IS NOT NULL;

SELECT DISTINCT Classification
FROM purchase_prices
WHERE ISNUMERIC(Classification) = 0 AND Classification IS NOT NULL;

-- Trim whitespace
UPDATE purchase_prices
SET Volume = LTRIM(RTRIM(Volume)),
    Classification = LTRIM(RTRIM(Classification));


-- OPTIONAL: Set non-numeric values to NULL (if any)
UPDATE purchase_prices
SET Volume = NULL
WHERE ISNUMERIC(Volume) = 0;

UPDATE purchase_prices
SET Classification = NULL
WHERE ISNUMERIC(Classification) = 0;

-- Convert Volume and Classification
ALTER TABLE purchase_prices
ALTER COLUMN Volume FLOAT;


ALTER TABLE purchase_prices
ALTER COLUMN Classification INT;

select top 10 * from dbo.purchase_prices;

-------------------------------------------------------------------------------------

--purchases
-- Check Quantity for non-numeric values
SELECT * FROM purchases
WHERE ISNUMERIC(Quantity) = 0 AND Quantity IS NOT NULL;

-- for Classification
SELECT * FROM purchases
WHERE ISNUMERIC(Classification) = 0 AND Classification IS NOT NULL;

-- First convert all values safely to INT
UPDATE purchases
SET Quantity = NULL
WHERE ISNUMERIC(Quantity) = 0;

ALTER TABLE purchases
ALTER COLUMN Quantity INT;

-- Same for Classification
UPDATE purchases
SET Classification = NULL
WHERE ISNUMERIC(Classification) = 0;

ALTER TABLE purchases
ALTER COLUMN Classification INT;

-- No check needed for floats if you're confident all are numeric
ALTER TABLE purchases
ALTER COLUMN PurchasePrice DECIMAL(10,2);

ALTER TABLE purchases
ALTER COLUMN Dollars DECIMAL(10,2);

SELECT SUM(Quantity), AVG(PurchasePrice), SUM(Dollars)
FROM purchases
WHERE VendorNumber IS NOT NULL;

-- converting dates
ALTER TABLE purchases
ALTER COLUMN PayDate DATE; 

ALTER TABLE purchases
ALTER COLUMN PODate DATE; 

ALTER TABLE purchases
ALTER COLUMN ReceivingDate DATE; 

ALTER TABLE purchases
ALTER COLUMN InvoiceDate DATE; 

select top 10 * from purchases

-------------------------------------------------------------------------------------
--sales
--Check  SalesDollars, SalesPrice, and ExciseTax for NULLs
SELECT 
  COUNT(*) AS TotalRows,
  SUM(CASE WHEN SalesDollars IS NULL THEN 1 ELSE 0 END) AS SalesDollars_NULLs,
  SUM(CASE WHEN SalesPrice IS NULL THEN 1 ELSE 0 END) AS SalesPrice_NULLs,
  SUM(CASE WHEN ExciseTax IS NULL THEN 1 ELSE 0 END) AS ExciseTax_NULLs
FROM sales;

-- Convert SalesDollars
ALTER TABLE sales
ALTER COLUMN SalesDollars DECIMAL(10,2);

-- Convert SalesPrice
ALTER TABLE sales
ALTER COLUMN SalesPrice DECIMAL(10,2);

-- Convert ExciseTax
ALTER TABLE sales
ALTER COLUMN ExciseTax DECIMAL(10,2);

select top 10 * from sales;

-------------------------------------------------------------------------------------
--vendor_invoice
-- Check for Non-Numeric or NULL Values
SELECT Quantity
FROM vendor_invoice
WHERE TRY_CAST(Quantity AS INT) IS NULL AND Quantity IS NOT NULL;

-- Convert safely
UPDATE vendor_invoice
SET Quantity = NULL
WHERE TRY_CAST(Quantity AS INT) IS NULL;

--  Change column type
ALTER TABLE vendor_invoice
ALTER COLUMN Quantity INT;


select * from vendor_invoice

-- Step 1: Add new BIT column temporarily
ALTER TABLE dbo.vendor_invoice
ADD ApprovalFlag BIT;

UPDATE dbo.vendor_invoice
SET ApprovalFlag = CASE
    WHEN Approval IS NOT NULL THEN 1
    ELSE 0
END;

--convert invoice date and etc
ALTER TABLE vendor_invoice
ALTER COLUMN InvoiceDate DATE;

ALTER TABLE vendor_invoice
ALTER COLUMN PODate DATE; 

ALTER TABLE vendor_invoice
ALTER COLUMN PayDate DATE; 

select * from dbo.vendor_invoice where Approval is not null;
select * from dbo.vendor_invoice where Approval is null;
select * from dbo.vendor_invoice;
Truncate table dbo.vendor_invoice