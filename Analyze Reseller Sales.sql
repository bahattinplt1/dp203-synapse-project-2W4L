-- Query 1: Total quantity sold per fiscal year and quarter
-- Aggregates the total sales quantity from reseller sales grouped by fiscal year and quarter.
SELECT d.FiscalYear,
       d.FiscalQuarter,
       SUM(f.OrderQuantity) AS TotalQuantity
FROM FactResellerSales AS f
JOIN DimDate AS d ON f.OrderDateKey = d.DateKey
GROUP BY d.FiscalYear, d.FiscalQuarter
ORDER BY d.FiscalYear, d.FiscalQuarter;
GO

-- Query 2: Total quantity sold per fiscal year, quarter, and sales territory region
-- Uses DimSalesTerritory instead of DimGeography for region data.
SELECT d.FiscalYear,
       d.FiscalQuarter,
       t.SalesTerritoryRegion,
       SUM(f.OrderQuantity) AS TotalQuantity
FROM FactResellerSales AS f
JOIN DimDate AS d ON f.OrderDateKey = d.DateKey
JOIN DimEmployee AS e ON f.EmployeeKey = e.EmployeeKey
JOIN DimSalesTerritory AS t ON e.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY d.FiscalYear, d.FiscalQuarter, t.SalesTerritoryRegion
ORDER BY d.FiscalYear, d.FiscalQuarter, t.SalesTerritoryRegion;
GO

-- Query 3: Total quantity sold per fiscal year, quarter, region, and product category
-- Combines sales region and product category using the snowflake schema.
SELECT d.FiscalYear,
       d.FiscalQuarter,
       t.SalesTerritoryRegion,
       pc.EnglishProductCategoryName AS ProductCategory,
       SUM(f.OrderQuantity) AS TotalQuantity
FROM FactResellerSales AS f
JOIN DimDate AS d ON f.OrderDateKey = d.DateKey
JOIN DimEmployee AS e ON f.EmployeeKey = e.EmployeeKey
JOIN DimSalesTerritory AS t ON e.SalesTerritoryKey = t.SalesTerritoryKey
JOIN DimProduct AS p ON f.ProductKey = p.ProductKey
JOIN DimProductSubcategory AS ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN DimProductCategory AS pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY d.FiscalYear, d.FiscalQuarter, t.SalesTerritoryRegion, pc.EnglishProductCategoryName
ORDER BY d.FiscalYear, d.FiscalQuarter, t.SalesTerritoryRegion, pc.EnglishProductCategoryName;
GO

-- Query 4: Rank of each sales territory per fiscal year based on total sales amount
-- Ranks each region based on total reseller sales amount using the RANK() function.
SELECT d.FiscalYear,
       t.SalesTerritoryRegion,
       SUM(f.SalesAmount) AS TotalSalesAmount,
       RANK() OVER(PARTITION BY d.FiscalYear ORDER BY SUM(f.SalesAmount) DESC) AS RegionalRank
FROM FactResellerSales AS f
JOIN DimDate AS d ON f.OrderDateKey = d.DateKey
JOIN DimEmployee AS e ON f.EmployeeKey = e.EmployeeKey
JOIN DimSalesTerritory AS t ON e.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY d.FiscalYear, t.SalesTerritoryRegion
ORDER BY d.FiscalYear, RegionalRank;
GO

-- Query 5: Approximate number of reseller sales orders per year and territory
-- Uses APPROX_COUNT_DISTINCT for fast approximate order counts by region and year.
SELECT d.CalendarYear,
       t.SalesTerritoryRegion,
       APPROX_COUNT_DISTINCT(f.SalesOrderNumber) AS ApproxOrderCount
FROM FactResellerSales AS f
JOIN DimDate AS d ON f.OrderDateKey = d.DateKey
JOIN DimEmployee AS e ON f.EmployeeKey = e.EmployeeKey
JOIN DimSalesTerritory AS t ON e.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY d.CalendarYear, t.SalesTerritoryRegion
ORDER BY d.CalendarYear, t.SalesTerritoryRegion;
GO