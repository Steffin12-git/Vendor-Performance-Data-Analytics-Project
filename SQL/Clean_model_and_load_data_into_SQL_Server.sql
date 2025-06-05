-- ✅ GOAL: Clean, model, and load data into SQL Server 
-- 1. Create a Database in SSMS
CREATE DATABASE RetailInventoryAnalysis;

GO
USE RetailInventoryAnalysis;

-- Design Tables for Each CSV

-- 1) begin_inventory
CREATE TABLE begin_inventory(
	InventoryId VARCHAR(100),
    Store INT,
    City VARCHAR(100),
    Brand INT,
    Description VARCHAR(255),
    Size VARCHAR(50),
    onHand INT,
    Price DECIMAL(10,2),
    startDate DATE
)

-- INSERTING VALUES
BULK INSERT begin_inventory
FROM 'D:\Data\Projects\Vendor-Performance-Data-Analytics-Project\dataset\data\begin_inventory.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SELECT Top 10 * FROM dbo.begin_inventory;


-- 2) end_inventory
CREATE TABLE end_inventory(
    InventoryId VARCHAR(100),
    Store INT,
    City VARCHAR(100),
    Brand INT,
    Description VARCHAR(255),
    Size VARCHAR(50),
    onHand INT,
    Price DECIMAL(10,2),
    endDate DATE
)
-- INSERTING VALUES
BULK INSERT end_inventory
FROM 'D:\Data\Projects\Vendor-Performance-Data-Analytics-Project\dataset\data\end_inventory.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SELECT TOP 10 * FROM dbo.end_inventory;



-- 3) purchase_prices
CREATE TABLE purchase_prices(
   Brand INT,
    Description VARCHAR(255),
    Price DECIMAL(10,2),
    Size VARCHAR(50),
    Volume INT,
    Classification INT,
    PurchasePrice DECIMAL(10,2),
    VendorNumber INT,
    VendorName VARCHAR(255) 
)

-- INSERTING VALUES
BULK INSERT purchase_prices
FROM 'D:\Data\Projects\Vendor-Performance-Data-Analytics-Project\dataset\data\purchase_prices.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SELECT TOP 10 * FROM dbo.purchase_prices;



-- 4) purchases
CREATE TABLE purchases (
    InventoryId VARCHAR(100),
    Store INT,
    Brand INT,
    Description VARCHAR(255),
    Size VARCHAR(50),
    VendorNumber INT,
    VendorName VARCHAR(255),
    PONumber INT,
    PODate DATE,
    ReceivingDate DATE,
    InvoiceDate DATE,
    PayDate DATE,
    PurchasePrice DECIMAL(10,2),
    Quantity INT,
    Dollars DECIMAL(12,2),
    Classification INT
);

-- INSERTING VALUES
BULK INSERT purchases
FROM 'D:\Data\Projects\Vendor-Performance-Data-Analytics-Project\dataset\data\purchases.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SELECT TOP 10 * FROM dbo.purchases;


-- 5) sales_
CREATE TABLE sales (
    InventoryId VARCHAR(100),
    Store INT,
    Brand INT,
    Description VARCHAR(255),
    Size VARCHAR(50),
    SalesQuantity INT,
    SalesDollars DECIMAL(10,2),
    SalesPrice DECIMAL(10,2),
    SalesDate DATE,
    Volume INT,
    Classification INT,
    ExciseTax DECIMAL(10,2),
    VendorNo INT,
    VendorName VARCHAR(255)
);

-- INSERTING VALUES
BULK INSERT sales
FROM 'D:\Data\Projects\Vendor-Performance-Data-Analytics-Project\dataset\data\sales.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    BATCHSIZE = 100000,  -- controls memory usage
    ERRORFILE = 'D:\Data\error_log_sales.txt'
);

truncate table dbo.sales
SELECT top 10 * FROM dbo.sales;




-- 6) vendor_invoice
CREATE TABLE vendor_invoice (
    VendorNumber INT,
    VendorName VARCHAR(255),
    InvoiceDate DATE,
    PONumber INT,
    PODate DATE,
    PayDate DATE,
    Quantity INT,
    Dollars DECIMAL(12,2),
    Freight DECIMAL(10,2),
    Approval BIT NULL
);
-- INSERTING VALUES
BULK INSERT vendor_invoice
FROM 'D:\Data\Projects\Vendor-Performance-Data-Analytics-Project\dataset\data\vendor_invoice.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SELECT TOP 10 * FROM dbo.vendor_invoice;

drop table dbo.sales
