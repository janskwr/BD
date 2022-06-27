-- create simple index (iddsd - this is index name)
CREATE NONCLUSTERED INDEX iddsd ON dbo.Managers(Division_id) ;

DROP INDEX Managers.iddsd; 

SELECT * FROM Managers M JOIN Divisions D ON M.Division_id = D.Division_id

CREATE NONCLUSTERED INDEX IX_parts_dates ON dbo.Parts (prod_start_date DESC , prod_end_date DESC);

CREATE INDEX IX_parts_stat1 ON dbo.Parts(stat_number DESC) 
CREATE INDEX IX_parts_country ON dbo.Parts(country_id) 


---------------------- Case study #0 ---------------------------------------
-- remove default indexies
DROP INDEX Categories.CategoryName
DROP INDEX Customers.City
DROP INDEX Customers.CompanyName
DROP INDEX Customers.PostalCode
DROP INDEX Customers.Region
DROP INDEX [Order Details].OrderID
DROP INDEX [Order Details].OrdersOrder_Details
DROP INDEX [Order Details].ProductID
DROP INDEX [Order Details].ProductsOrder_Details
DROP INDEX Orders.CustomerId
DROP INDEX Orders.CustomersOrders
DROP INDEX Orders.EmployeeID
DROP INDEX Orders.EmployeesOrders
DROP INDEX Orders.OrderDate
DROP INDEX Orders.ShippedDate
DROP INDEX Orders.ShippersOrders
DROP INDEX Orders.ShipPostalCode
DROP INDEX Products.CategoriesProducts
DROP INDEX Products.CategoryID
DROP INDEX Products.ProductName
DROP INDEX Products.SupplierID
DROP INDEX Products.SuppliersProducts

-- mark the query and investigate execution plan (hit CTRL-L)
SELECT firstname, lastname 
FROM employees e 
WHERE e.EmployeeID IN (
	SELECT o.EmployeeID 
	FROM orders o 
	WHERE o.customerid='ALFKI'
)

SELECT firstname, lastname 
FROM employees e 
WHERE EXISTS (
	SELECT * 
	FROM orders o 
	WHERE customerid='ALFKI' AND e.employeeid=o.employeeid
)

SELECT e.firstname, e.lastname 
FROM employees e 
JOIN Orders O ON e.EmployeeID = O.EmployeeID
WHERE O.CustomerID = 'ALFKI'

-- index scan ON the index PK_Orders has gratest cost in whole plan
-- add non-clustered index HHH and compare execution plan
CREATE INDEX HHH ON Orders(CustomerID,EmployeeID)

CREATE INDEX BBB ON Employees(EmployeeID,Firstname, lastname)
-- adding new index BBB does not improve query performance, but the BBB index is used insted of the PK_Employees

-- it is possible to add additinal columns only to index 'leafs' not only to the key
CREATE INDEX CCC ON Orders(CustomerID) INCLUDE (EmployeeID)

DROP INDEX Orders.HHH
DROP INDEX Employees.BBB
DROP INDEX Orders.CCC


---------------------- Case study #1 ---------------------------------------
-- mark the query and investigate execution plan (hit CTRL-L)
SELECT * 
FROM orders o 
WHERE NOT EXISTS (
	SELECT * 
	FROM [order details] od 
	JOIN products p ON p.productid=od.productid 
	WHERE productname='Scottish Longbreads' 
		AND od.orderid=o.orderid
	)
AND EXISTS (
	SELECT * 
	FROM [order details] od 
	JOIN products p ON p.productid=od.productid 
	WHERE productname='Chocolade' AND od.orderid=o.orderid
	)

-- Author: Chrab¹szcz Maciej
CREATE INDEX AAA ON [order details](ProductID)
CREATE INDEX BBB ON Products(productname)
CREATE INDEX CCC ON [order details](orderid)
-----------------------------------------------

-- check the optimized version 
SELECT * 
FROM orders o 
LEFT JOIN ( 
	SELECT orderID 
	FROM [order details] od
	WHERE od.ProductID = (
		SELECT ProductID 
		FROM products 
		WHERE productname='Scottish Longbreads'  
		) 
	) T ON T.orderid=o.orderid
JOIN (
	SELECT OrderID 
	FROM [order details] od1
	WHERE  od1.productid= (
		SELECT productid 
		FROM products 
		WHERE productname='Chocolade' 
		) 
	) T2 ON T2.OrderID = O.orderID
WHERE T.OrderID IS NULL 



---------------------- Case study #2 ---------------------------------------
SELECT * 
FROM customers c 
WHERE NOT EXISTS (
	SELECT *
	FROM orders o 
	WHERE o.customerid=c.customerid
	AND EXISTS (
		SELECT * 
		FROM [order details] od 
		JOIN products p ON p.productid=od.productid 
		WHERE od.orderid=o.orderid 
		AND p.productname='Chocolade'
		)
	)

SELECT *
FROM Customers C
LEFT JOIN (
	SELECT O.OrderID, O.CustomerID
	FROM Orders O
	JOIN [Order Details] OD ON O.OrderID = OD.OrderID 
		AND OD.ProductID = (
			SELECT P.ProductID 
			FROM Products P 
			WHERE P.ProductName = 'Chocolade'
			)
) A ON A.CustomerID = C.CustomerID
WHERE A.CustomerID IS NULL
;



---------------------- Case study #3 ---------------------------------------
GO
CREATE VIEW OrdersTotal as(
	SELECT 
		YEAR(O.OrderDate) as OrderYear,
		DATEPART(MONTH, O.OrderDate) as OrderMonth,
		O.OrderID,
		O.CustomerID,
		CS.CompanyName,
		CS.Country as CustomerCountry,
		CS.City as CustomerCity,
		O.ShipCountry,
		O.ShipCity,
		OD.ProductID,
		P.ProductName,
		CT.CategoryName,
		OD.UnitPrice,
		OD.Quantity,
		OD.UnitPrice * OD.Quantity as ProductValue
	FROM Orders O
	JOIN Customers CS ON O.CustomerID = CS.CustomerID
	JOIN [Order Details] OD ON OD.OrderID = O.OrderID
	JOIN Products P ON P.ProductID = OD.ProductID
	JOIN Categories CT ON CT.CategoryID = P.CategoryID
);
GO

SELECT 
	OrderId,
	ProductName,
	CategoryName, 
	ProductValue,
	SUM(ProductValue) OVER (PARTITION BY ProductName) as ProdTotalSale,
	SUM(ProductValue) OVER (PARTITION BY CategoryName) as CategoryTotalSale   
FROM OrdersTotal 
order by ProductName


SELECT 
	OrderId,
	ProductName,
	CategoryName, 
	ProductValue,
	SUM(ProductValue) OVER (PARTITION BY ProductName) as ProdTotalSale,
	SUM(ProductValue) OVER (PARTITION BY CategoryName) as CategoryTotalSale   
FROM (
	SELECT 
		OD.OrderID,
		P.ProductID,
		P.ProductName,
		C.CategoryName,
		OD.Quantity * OD.UnitPrice as ProductValue
	FROM [Order Details] OD
	JOIN Products P ON OD.ProductID = P.ProductID
	JOIN Categories C ON P.CategoryID = C.CategoryID
) A
order by ProductName

CREATE INDEX AAA ON Products(ProductName, ProductID)
CREATE INDEX BBB ON Categories(CategoryName, CategoryID)
CREATE INDEX CCC ON [Order Details](OrderID, ProductID) INCLUDE (Quantity, UnitPrice)

DROP index Products.AAA
DROP index Categories.BBB
DROP index [Order Details].CCC


---------------------- Case study #4 ---------------------------------------
SELECT
	p.ProductName,
	cnt_1996 as TotalQuantityIn1996,
	cnt_1997 as TotalQuantityIn1997
FROM Products P
JOIN (
	SELECT 
		od.ProductID, 
		sum(case when (year(OrderDate) = 1996) then Quantity else 0 end) cnt_1996,
		sum(case when (year(OrderDate) = 1997) then Quantity else 0 end) cnt_1997
	FROM [Order Details] od
	JOIN Orders o ON od.OrderID = o.OrderID
	group by od.ProductID
) A ON A.ProductID = P.ProductID
WHERE A.cnt_1997 > A.cnt_1996


SELECT
	p.ProductName,
	cnt_1996 as TotalQuantityIn1996,
	cnt_1997 as TotalQuantityIn1997
FROM Products P
JOIN (
	SELECT 
		od.ProductID, 
		sum(case when (OrderDate >= '1996-01-01' AND OrderDate < '1997-01-01') then Quantity else 0 end) cnt_1996,
		sum(case when (OrderDate >= '1997-01-01' AND OrderDate < '1998-01-01') then Quantity else 0 end) cnt_1997
	FROM [Order Details] od
	JOIN Orders o ON od.OrderID = o.OrderID
	WHERE o.OrderDate >= '1996-01-01' AND o.OrderDate < '1998-01-01'
	group by od.ProductID
) A ON A.ProductID = P.ProductID
WHERE A.cnt_1997 > A.cnt_1996

