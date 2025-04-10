-- Query 1: Total internet sales per year
-- This query joins the Internet Sales fact table with the Date dimension
-- and aggregates total sales per calendar year.
SELECT  d.CalendarYear AS Year,
        SUM(i.SalesAmount) AS InternetSalesAmount
FROM FactInternetSales AS i
JOIN DimDate AS d ON i.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY Year;

-- Query 2: Total internet sales per year and month
-- This query adds the month attribute from the Date dimension
-- to enable monthly aggregation in addition to yearly.
SELECT  d.CalendarYear AS Year,
        d.MonthNumberOfYear AS Month,
        SUM(i.SalesAmount) AS InternetSalesAmount
FROM FactInternetSales AS i
JOIN DimDate AS d ON i.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear, d.MonthNumberOfYear
ORDER BY Year, Month;

-- Query 3: Total internet sales per year and region
-- This query joins the Internet Sales fact table with Date, Customer, and Geography dimensions
-- to calculate annual sales grouped by country/region.
SELECT  d.CalendarYear AS Year,
        g.EnglishCountryRegionName AS Region,
        SUM(i.SalesAmount) AS InternetSalesAmount
FROM FactInternetSales AS i
JOIN DimDate AS d ON i.OrderDateKey = d.DateKey
JOIN DimCustomer AS c ON i.CustomerKey = c.CustomerKey
JOIN DimGeography AS g ON c.GeographyKey = g.GeographyKey
GROUP BY d.CalendarYear, g.EnglishCountryRegionName
ORDER BY Year, Region;

-- Query 4: Total internet sales per year, region, and product category
-- This query joins multiple dimension tables to represent a snowflake schema,
-- allowing aggregation of sales by year, product category, and region.
SELECT  d.CalendarYear AS Year,
        pc.EnglishProductCategoryName AS ProductCategory,
        g.EnglishCountryRegionName AS Region,
        SUM(i.SalesAmount) AS InternetSalesAmount
FROM FactInternetSales AS i
JOIN DimDate AS d ON i.OrderDateKey = d.DateKey
JOIN DimCustomer AS c ON i.CustomerKey = c.CustomerKey
JOIN DimGeography AS g ON c.GeographyKey = g.GeographyKey
JOIN DimProduct AS p ON i.ProductKey = p.ProductKey
JOIN DimProductSubcategory AS ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN DimProductCategory AS pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY d.CalendarYear, pc.EnglishProductCategoryName, g.EnglishCountryRegionName
ORDER BY Year, ProductCategory, Region;

-- Query 5: Sales order line items for 2022 with row numbers, regional totals and averages
-- This query partitions sales data by country/region and ranks each line item by sales amount.
-- It also calculates the total and average sales for each region using window functions.
SELECT  g.EnglishCountryRegionName AS Region,
        ROW_NUMBER() OVER(PARTITION BY g.EnglishCountryRegionName
                          ORDER BY i.SalesAmount ASC) AS RowNumber,
        i.SalesOrderNumber AS OrderNo,
        i.SalesOrderLineNumber AS LineItem,
        i.SalesAmount AS SalesAmount,
        SUM(i.SalesAmount) OVER(PARTITION BY g.EnglishCountryRegionName) AS RegionTotal,
        AVG(i.SalesAmount) OVER(PARTITION BY g.EnglishCountryRegionName) AS RegionAverage
FROM FactInternetSales AS i
JOIN DimDate AS d ON i.OrderDateKey = d.DateKey
JOIN DimCustomer AS c ON i.CustomerKey = c.CustomerKey
JOIN DimGeography AS g ON c.GeographyKey = g.GeographyKey
WHERE d.CalendarYear = 2022
ORDER BY Region;
GO

-- Query 6: Ranking cities within each region by their total sales
-- This query groups sales by city and region, and uses RANK() to rank cities by their sales totals within each region.
-- It also calculates the total sales for each region by summing city totals using a nested aggregation with windowing.
SELECT  g.EnglishCountryRegionName AS Region,
        g.City,
        SUM(i.SalesAmount) AS CityTotal,
        SUM(SUM(i.SalesAmount)) OVER(PARTITION BY g.EnglishCountryRegionName) AS RegionTotal,
        RANK() OVER(PARTITION BY g.EnglishCountryRegionName
                    ORDER BY SUM(i.SalesAmount) DESC) AS RegionalRank
FROM FactInternetSales AS i
JOIN DimDate AS d ON i.OrderDateKey = d.DateKey
JOIN DimCustomer AS c ON i.CustomerKey = c.CustomerKey
JOIN DimGeography AS g ON c.GeographyKey = g.GeographyKey
GROUP BY g.EnglishCountryRegionName, g.City
ORDER BY Region;
GO

-- Query 7: Exact count of distinct sales orders per year
-- This query uses COUNT(DISTINCT ...) to count the number of unique sales orders each calendar year.
-- It may be slower on large datasets but returns precise results.
SELECT d.CalendarYear AS CalendarYear,
    COUNT(DISTINCT i.SalesOrderNumber) AS Orders
FROM FactInternetSales AS i
JOIN DimDate AS d ON i.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY CalendarYear;
GO

-- Query 8: Approximate count of distinct sales orders per year
-- This query uses APPROX_COUNT_DISTINCT to estimate the number of unique sales orders per year.
-- It returns results with ~2% error margin but executes faster on large datasets.
SELECT d.CalendarYear AS CalendarYear,
    APPROX_COUNT_DISTINCT(i.SalesOrderNumber) AS Orders
FROM FactInternetSales AS i
JOIN DimDate AS d ON i.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY CalendarYear;
GO

