USE Northwind
GO

SELECT *
FROM Categories;

SELECT CategoryID, CategoryName
FROM Categories;

SELECT 
	CategoryID AS ID, 
	CategoryName AS Name
FROM Categories;

SELECT *
FROM Products
WHERE UnitsInStock >= 15 AND UnitsInStock < 29
;

SELECT *
FROM Products
WHERE UnitsInStock BETWEEN 15 AND 29
;

SELECT City
FROM Customers;

SELECT DISTINCT City
FROM Customers;


SELECT * FROM Orders;

SELECT * FROM Orders
WHERE ShippedDate = '1996-07-25';

SELECT * FROM Orders
WHERE ShippedDate = '19960725';



SELECT * FROM Orders
WHERE ShipRegion = NULL;

SELECT * FROM Orders
WHERE ShipRegion != NULL;

SELECT * FROM Orders
WHERE ShipRegion IS NULL;

SELECT 
	ShippedDate,
	YEAR(ShippedDate) AS YearShipped,
	MONTH(ShippedDate) AS MonthShipped,
	DaY(ShippedDate) aS DayShipped
FROM Orders
WHERE ShippedDate is not null;
;

SELECT SUBSTRING(ShipCountry,1,3)
FROM Orders;

SELECT UPPER(SUBSTRING(ShipCountry,1,3))
FROM Orders;

SELECT LOWER(SUBSTRING(ShipCountry,1,3))
FROM Orders;

SELECT 
	LEN(ShipCity) AS LenOfShipCity,
	ShipCity
FROM Orders;

-- JOIN
SELECT 
	O.ShipAddress,
	O.ShipCountry,
	O.ShipCity
FROM Orders as O
WHERE YEAR(ShippedDate) = 1996;

SELECT 
	O.ShipAddress,
	O.ShipCountry,
	O.ShipCity,
	S.CompanyName,
	S.Phone
FROM Orders as O
JOIN Shippers as S ON S.ShipperID = O.ShipVia
WHERE YEAR(ShippedDate) = 1996;

SELECT *
FROM Products P
JOIN [Order Details] OD on P.ProductID = OD.ProductID
JOIN Orders O on O.OrderID = OD.OrderID
;

SELECT COUNT(*)
FROM Customers C
JOIN Orders O on C.CustomerID = O.CustomerID
;

SELECT COUNT(*)
FROM Customers C
LEFT JOIN Orders O on C.CustomerID = O.CustomerID
;

(
	SELECT *
	FROM Customers C
	LEFT JOIN Orders O on C.CustomerID = O.CustomerID
) EXCEPT (
	SELECT *
	FROM Customers C
	JOIN Orders O on C.CustomerID = O.CustomerID
)

SELECT *
FROM Customers C
LEFT JOIN Orders O on C.CustomerID = O.CustomerID
WHERE O.CustomerID IS NULL
;



