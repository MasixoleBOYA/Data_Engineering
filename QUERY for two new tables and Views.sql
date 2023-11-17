USE CustomerTransactions;

-- query to calculate SalesAmount for customers
SELECT 
    c.id,
    c.first,
    c.last,
    SUM(ti.quantity * i.price) AS SalesAmount
INTO TempSales
FROM Customers c
JOIN Transactions t ON c.id = t.customer_id
JOIN TransactionItems ti ON t.id = ti.transaction_id
JOIN Items i ON ti.item_id = i.id
GROUP BY c.id, c.first, c.last;

-- Use GO to separate batches
GO

CREATE VIEW dbo.CustomerSales AS
SELECT 
    id,
    first AS CustomerFirstName,
    last AS CustomerLastName
FROM Customers;

GO

-- Query to create a table to store monthly sales
IF OBJECT_ID('dbo.TempMonthlySales') IS NOT NULL
    DROP TABLE dbo.TempMonthlySales;

CREATE TABLE dbo.TempMonthlySales (
    Month INT,
    SalesAmount DECIMAL(18, 2)
);

-- Insert data into the table
INSERT INTO dbo.TempMonthlySales (Month, SalesAmount)
SELECT 
    MONTH(date) AS Month,
    SUM(ti.quantity * i.price) AS SalesAmount
FROM Transactions t
JOIN TransactionItems ti ON t.id = ti.transaction_id
JOIN Items i ON ti.item_id = i.id
GROUP BY MONTH(date);

-- Query to display monthly sales
SELECT 
    Month,
    SalesAmount,
    LAG(SalesAmount) OVER (ORDER BY Month) AS PreviousMonthSales
FROM dbo.TempMonthlySales;
