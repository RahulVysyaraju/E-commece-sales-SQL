-- 1.	GENERAL SALES INSIGHTS.

-- 1.1.	What is the total revenue generated over the entire period?

SELECT SUM(OD.quantity * p.price) AS total_revenue
FROM orderdetails OD 
JOIN products p On OD.productid = p.productid;

-- 1.2.	Revenue Excluding Returned Orders.

SELECT SUM(OD.quantity * p.price) AS total_revenue
FROM orderdetails OD 
JOIN products p ON OD.productid = p.productid
JOIN orders o ON OD.orderid = o.orderid
WHERE o.isreturned = 0;

-- 1.3.	Total Revenue per Year / Month.

SELECT YEAR(o.orderdate) AS year, MONTH(o.orderdate) AS month, SUM(OD.quantity * p.price) AS total_revenue
FROM orderdetails OD 
JOIN products p ON OD.productid = p.productid
JOIN orders o ON OD.orderid = o.orderid
GROUP BY YEAR(o.orderdate),MONTH(o.orderdate)
ORDER BY YEAR(o.orderdate),MONTH(o.orderdate); 

-- 1.4.	Revenue by Product / Category. 

SELECT productname, category, SUM(OD.quantity * p.price) AS ProductRevenue
FROM products p 
JOIN orderdetails od ON p.productid = od.productid
GROUP BY productname, category
ORDER BY category, ProductRevenue DESC;

-- 1.5.	What is the average order value (AOV) across all orders? 

SELECT AVG(revenue) AS avg_order_valuue
FROM(SELECT o.orderid, SUM(price * quantity) AS revenue
     FROM orderdetails OD 
     JOIN products p ON OD.productid = p.productid
	 JOIN orders o ON OD.orderid = o.orderid
     GROUP BY o.orderid) T;
     
-- 1.6.	AOV per Year / Month. 

SELECT YEAR(orderdate) AS `year`, MONTH(orderdate) AS `month`, AVG(revenue) AS avg_order_valuue
FROM(SELECT o.orderid, o.orderdate, SUM(price * quantity) AS revenue
     FROM orderdetails OD 
     JOIN products p ON OD.productid = p.productid
	 JOIN orders o ON OD.orderid = o.orderid
     GROUP BY o.orderid) T
GROUP BY YEAR(orderdate), MONTH(orderdate)
ORDER BY YEAR(orderdate), MONTH(orderdate) DESC; 

-- 1.7.	What is the average order size by region?

SELECT RegionName, AVG(TotalOrderSize) AS AvgOrderSize
FROM(SELECT O.OrderID, C.RegionID, R.RegionName, SUM(OD.Quantity) AS TotalOrderSize
	FROM orders O
	JOIN orderdetails OD ON O.OrderID = OD.OrderID
	JOIN customers C ON O.CustomerID = C.CustomerID
	JOIN regions R ON C.RegionID = R.RegionID
	GROUP BY O.OrderID, C.RegionID) T
GROUP BY RegionName
ORDER BY AvgOrderSize DESC;

-- 2.	CUSTOMER INSIGHTS 
-- 2.1.	Who are the top 10 customers by total revenue spent? 
SELECT c.customerid, c.customername, SUM(od.quantity * p.price) AS total_revenue_spent
FROM customers c
JOIN orders o ON c.customerid = o.customerid
JOIN orderdetails od ON o.orderid = od.orderid
JOIN products p ON od.productid = p.productid
GROUP BY c.customerid, c.customername
ORDER BY total_revenue_spent DESC
LIMIT 10;
 
-- 2.2.	What is the repeat customer rate? 

SELECT COUNT(DISTINCT CASE WHEN OrderCount > 1 THEN CustomerID END)/COUNT(DISTINCT CustomerID) AS RepeatCustomerRate
FROM (SELECT CustomerID, COUNT(OrderID) AS OrderCount
      FROM  orders 
      GROUP BY CustomerID ) T ;

-- 2.3.	What is the average time between two consecutive orders for the same customer Region-wise?

WITH RankOrders AS(
       SELECT O.CustomerID, O.OrderID, C.RegionID, O.OrderDate,
              ROW_NUMBER() OVER (PARTITION BY C.CustomerID ORDER BY O.OrderDate) AS rn
	   FROM orders O 
       JOIN customers C ON O.CustomerID = C.CustomerID
),
OrderPairs AS(
       SELECT curr.CustomerID, curr.RegionID, DATEDIFF(curr.OrderDate, `prev`.OrderDate) AS DaysBetween
       FROM RankOrders curr
       JOIN RankOrders `prev` ON curr.CustomerID = `prev`.CustomerID AND curr.rn = `prev`.rn + 1
),
Region AS(
       SELECT CustomerID, RegionName, DaysBetween
       FROM OrderPairs OP
       JOIN regions R ON OP.RegionId = R.RegionID
)
SELECT RegionName, AVG(DaysBetween) AS AvgDaysBetween
FROM Region 
GROUP BY RegionName
ORDER BY AvgDaysBetween;

-- 2.4.	Customer Segment (based on total spend)
-- •	Platinum: Total Spend > 1500
-- •	Gold: 1000–1500
-- •	Silver: 500–999
-- •	Bronze: < 500

SELECT CustomerID, CustomerName,
       CASE WHEN TotalSpend > 1500 THEN "Platinum"
            WHEN TotalSpend BETWEEN 1000 AND 1499 THEN "Gold"
            WHEN TotalSpend BETWEEN 500 AND 999 THEN "Silver"
            WHEN TotalSpend < 500 THEN "Bronze"
	   END AS Segment
FROM(SELECT O.CustomerID, C.CustomerName, SUM(OD.Quantity*P.Price) AS TotalSpend
	 FROM orders O 
	 JOIN orderdetails OD ON O.OrderID = OD.OrderID
	 JOIN customers C ON C.CustomerID = O.CustomerID
	 JOIN products P ON P.ProductID = OD.ProductID
	 GROUP BY O.CustomerID, C.CustomerName) T ;

-- 2.5.	What is the customer lifetime value (CLV)?

SELECT C.CustomerID, C.CustomerName, SUM(OD.Quantity*P.Price) AS CLV
FROM orderdetails OD
JOIN products P ON OD.ProductID = P.ProductID
JOIN orders O ON O.OrderID = OD.OrderID
JOIN customers C ON C.CustomerID = O.OrderID
GROUP BY C.CustomerID, C.CustomerName
ORDER BY CLV DESC;


-- 3.	Product & Order Insights
-- 3.1.	What are the top 10 most sold products (by quantity)?

SELECT P.ProductID, P.Productname, SUM(OD.Quantity) AS TotalQty
FROM orderdetails OD
JOIN products P ON OD.ProductID = P.ProductID
GROUP BY P.ProductID, P.ProductName
ORDER BY TotalQty DESC
LIMIT 10;

-- 3.2.	What are the top 10 most sold products (by revenue)?

SELECT P.ProductID, P.Productname, SUM(OD.Quantity * P.Price) AS TotalRev
FROM orderdetails OD
JOIN products P ON OD.ProductID = P.ProductID
GROUP BY P.ProductID, P.ProductName
ORDER BY TotalRev DESC
LIMIT 10;

-- 3.3.	Which products have the highest return rate?

WITH Sold AS(
     SELECT ProductID, SUM(Quantity) AS TotalQty
     FROM orderdetails
     GROUP BY ProductID ),
    Returned AS(
     SELECT ProductID, SUM(Quantity) AS TotalQtyReturned
     FROM orderdetails OD
     JOIN Orders O ON OD.OrderID = O.OrderID
     WHERE IsReturned = 1
     GROUP BY ProductID )
SELECT ProductName, ROUND((TotalQtyReturned/TotalQty),2) AS ReturnRate
FROM products P 
JOIN Sold S ON P.ProductID = S.ProductID
JOIN Returned R ON P.ProductID = R.ProductID
ORDER BY ReturnRate DESC;

-- 3.4.	Return Rate by Category

WITH Sold AS(
     SELECT Category, SUM(Quantity) AS TotalQty
     FROM orderdetails OD
     JOIN products P ON OD.ProductID = P.ProductID
     GROUP BY Category ),
    Returned AS(
     SELECT Category, SUM(Quantity) AS TotalQtyReturned
     FROM orderdetails OD
     JOIN Orders O ON OD.OrderID = O.OrderID
     JOIN products p ON OD.ProductID = P.ProductID
     WHERE IsReturned = 1
     GROUP BY Category )
SELECT  S.Category, ROUND((TotalQtyReturned/TotalQty),2) AS ReturnRate
FROM  Sold S 
JOIN Returned R ON S.Category = R.Category
ORDER BY ReturnRate DESC;

-- 3.5.	What is the average price of products per region?

SELECT RegionName, (SUM(OD.Quantity*P.Price)/SUM(OD.Quantity)) AS AveragePrice
FROM customers C 
JOIN orders O ON C.CustomerID = O.CustomerID
JOIN orderdetails OD ON O.OrderID = OD.OrderID
JOIN products P ON P.ProductID = OD.ProductID
JOIN regions R ON C.RegionID = R.RegionID
GROUP BY RegionName
ORDER BY AveragePrice DESC;

-- 3.6.	What is the sales trend for each product category?

SELECT DATE_FORMAT(OrderDate, "%Y-%m") AS Period, category, SUM(OD.Quantity*P.Price) AS Revenue
FROM orderdetails OD
JOIN orders O ON OD.OrderID = O.OrderID
JOIN products P ON OD.ProductID = P.ProductID
GROUP BY Period, category
ORDER BY Period, category;

-- 4.	Temporal Trends
-- 4.1.	What are the monthly sales trends over the past year?

SELECT YEAR(OrderDate) AS `Year`, MONTH(OrderDate) AS `Month` ,  SUM(OD.Quantity*P.Price) AS Revenue
FROM orderdetails OD
JOIN orders O ON OD.OrderID = O.OrderID
JOIN products P ON OD.ProductID = P.ProductID
WHERE OrderDate >= CURRENT_DATE() - INTERVAL 12 MONTH
GROUP BY `Year`, `Month`
ORDER BY `Year`, `Month` ;

-- 4.2.	How does the average order value (AOV) change by month ?

SELECT DATE_FORMAT(OrderDate, "%Y-%m") AS Period, ROUND(SUM(OD.Quantity*P.Price)/COUNT(O.OrderID ),2) AS AOV
FROM orderdetails OD
JOIN orders O ON OD.OrderID = O.OrderID
JOIN products P ON OD.ProductID = P.ProductID
GROUP BY Period 
ORDER BY Period;

-- 5.	Regional Insights
-- 5.1.	Which regions have the highest order volume ?

SELECT RegionName, COUNT(O.OrderID) AS OrderVolume
FROM Regions R 
JOIN customers C ON C.RegionID = R.RegionID
JOIN Orders O ON O.CustomerID = C.CustomerID
JOIN orderdetails OD ON OD.OrderID = O.OrderID
GROUP BY RegionName
ORDER BY OrderVolume DESC LIMIT 1;

-- 5.2.	What is the revenue per region and how does it compare across different regions?

SELECT RegionName, SUM(OD.Quantity*P.Price) AS Revenue
FROM Regions R 
JOIN customers C ON C.RegionID = R.RegionID
JOIN Orders O ON O.CustomerID = C.CustomerID
JOIN orderdetails OD ON OD.OrderID = O.OrderID
JOIN products P ON P.ProductID = OD.ProductID
GROUP BY RegionName
ORDER BY OrderVolume DESC ;

-- BONUS - (5.1 + 5.2)

WITH T1 AS (
	SELECT RegionName, COUNT(O.OrderID) AS OrderVolume
	FROM Regions R 
	JOIN customers C ON C.RegionID = R.RegionID
	JOIN Orders O ON O.CustomerID = C.CustomerID
	JOIN orderdetails OD ON OD.OrderID = O.OrderID
	GROUP BY RegionName
	ORDER BY OrderVolume DESC),
T2 AS (
	SELECT RegionName, SUM(OD.Quantity*P.Price) AS Revenue
	FROM Regions R 
	JOIN customers C ON C.RegionID = R.RegionID
	JOIN Orders O ON O.CustomerID = C.CustomerID
	JOIN orderdetails OD ON OD.OrderID = O.OrderID
	JOIN products P ON P.ProductID = OD.ProductID
	GROUP BY RegionName
	ORDER BY Revenue DESC )
SELECT T1.RegionName, OrderVolume, Revenue
FROM T1
JOIN T2 ON T1.RegionName = T2.RegionName
GROUP BY RegionName
ORDER BY Revenue;

-- 6.	Return & Refund Insights
-- 6.1.	What is the overall return rate by product category?

SELECT Category,
       ROUND(SUM(CASE WHEN IsReturned = 1 THEN 1 ELSE 0 END)/COUNT(O.OrderID),2) AS ReturnRate
FROM products P 
JOIN orders O ON P.ProductID = O.OrderID
JOIN orderdetails OD ON O.OrderID = OD.OrderID
GROUP BY Category
ORDER BY ReturnRate DESC;

-- 6.2.	What is the overall return rate by region?

SELECT RegionName,
       ROUND(SUM(CASE WHEN IsReturned = 1 THEN 1 ELSE 0 END)/COUNT(O.OrderID),3) AS ReturnRate
FROM products P 
JOIN orders O ON P.ProductID = O.OrderID
JOIN customers C ON C.CustomerID = O.CustomerID
JOIN regions R ON R.RegionID = C.CustomerID
GROUP BY RegionName
ORDER BY ReturnRate DESC ;

-- 6.3.	Which customers are making frequent returns?

SELECT C.CustomerID, CustomerName, COUNT(O.OrderID) AS `No.Of_Returns`
	FROM customers C 
	JOIN orders O ON C.CustomerID = O.CustomerID
    WHERE IsReturned = 1
	GROUP BY C.CustomerID, CustomerName
    ORDER BY `No.Of_Returns` DESC;