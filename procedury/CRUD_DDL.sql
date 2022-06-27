-- Task #1
UPDATE Orders
SET EmployeeId = 4
WHERE EmployeeId = 1

-- Task #2
UPDATE [Order Details]
SET Quantity = ROUND(0.8*Quantity, 0)
WHERE EXISTS (SELECT * FROM Products P WHERE P.ProductID = [Order Details].ProductID AND P.ProductName = 'Ikura') AND
	EXISTS (SELECT * FROM Orders O WHERE O.OrderID = [Order Details].OrderID AND O.OrderDate > '1997-05-15')
;

SELECT 
	OD.Quantity,
	O.OrderDate,
	P.ProductName
FROM [Order Details] OD
JOIN Orders O on OD.OrderID = O.OrderID
JOIN Products P on OD.ProductID = P.ProductID
WHERE P.ProductName = 'Ikura' AND O.OrderDate > '1997-05-15'
;

-- Task #3
-- MANUAL SEARCH
SELECT O.OrderID, O.CustomerID, O.OrderDate, P.ProductName, OD.* FROM Orders O
JOIN [Order Details] OD on O.OrderID = OD.OrderID
JOIN Products P on OD.ProductID = P.ProductID
WHERE O.CustomerID = 'ALFKI'
ORDER BY O.OrderDate DESC
;

-- LAST ALFKI ORDER WITHOUT Chocolade 
GO
CREATE VIEW LastALFKIWithoutChocolade AS (
	SELECT TOP 1
		O.OrderID,
		MAX(O.OrderDate) AS OrderDate
	FROM Orders O
	JOIN [Order Details] OD on O.OrderID = OD.OrderID
	WHERE O.CustomerID = 'ALFKI'
	GROUP BY O.OrderID, O.OrderDate
	HAVING O.OrderID NOT IN (
		SELECT O2.OrderID FROM Orders O2
		JOIN [Order Details] OD2 on O2.OrderID = OD2.OrderID
		JOIN Products P2 on P2.ProductID = OD2.ProductID
		WHERE O2.CustomerID = 'ALFKI' AND P2.ProductName = 'Chocolade'
	)
	ORDER BY O.OrderDate DESC
);
GO

SELECT * FROM LastALFKIWithoutChocolade;

-- FANCY TOP 1 :) 
WITH A AS (
	SELECT 
		O.OrderID,
		MAX(O.OrderDate) AS OrderDate
	FROM Orders O
	JOIN [Order Details] OD on O.OrderID = OD.OrderID
	WHERE O.CustomerID = 'ALFKI'
	GROUP BY O.OrderID
	HAVING O.OrderID NOT IN (
		SELECT O2.OrderID FROM Orders O2
		JOIN [Order Details] OD2 on O2.OrderID = OD2.OrderID
		JOIN Products P2 on P2.ProductID = OD2.ProductID
		WHERE O2.CustomerID = 'ALFKI' AND P2.ProductName = 'Chocolade'
)
)
SELECT
	A.OrderID
FROM A
LEFT JOIN A A2 on A.OrderDate <= A2.OrderDate
GROUP BY A.OrderID
HAVING COUNT(*) = 1


-- INSERT INTO
INSERT INTO [Order Details]
SELECT 
	L.OrderID,
	P.ProductID,
	14.5 AS UnitPrice,
	1 AS Quantity,
	0 AS Discount
FROM Products P 
JOIN LastALFKIWithoutChocolade L ON 1=1
WHERE P.ProductName = 'Chocolade'


-- TASK #4

GO
CREATE VIEW ALLALFKIWithoutChocolade AS (
	SELECT
		O.OrderID,
		MAX(O.OrderDate) AS OrderDate
	FROM Orders O
	JOIN [Order Details] OD on O.OrderID = OD.OrderID
	WHERE O.CustomerID = 'ALFKI'
	GROUP BY O.OrderID, O.OrderDate
	HAVING O.OrderID NOT IN (
		SELECT O2.OrderID FROM Orders O2
		JOIN [Order Details] OD2 on O2.OrderID = OD2.OrderID
		JOIN Products P2 on P2.ProductID = OD2.ProductID
		WHERE O2.CustomerID = 'ALFKI' AND P2.ProductName = 'Chocolade'
	)
);
GO

SELECT * FROM ALLALFKIWithoutChocolade;


INSERT INTO [Order Details]
SELECT 
	L.OrderID,
	P.ProductID,
	14.5 AS UnitPrice,
	1 AS Quantity,
	0 AS Discount
FROM Products P 
JOIN ALLALFKIWithoutChocolade L ON 1=1
WHERE P.ProductName = 'Chocolade'


-- TASK #5
SELECT * FROM Customers C 
LEFT JOIN Orders O on O.CustomerID = C.CustomerID
WHERE O.OrderID IS NULL;

DELETE FROM Customers
WHERE CustomerId IN (
	SELECT C.CustomerID FROM Customers C 
	LEFT JOIN Orders O on O.CustomerID = C.CustomerID
	WHERE O.OrderID IS NULL 
);


-- Task #6
GO
CREATE VIEW TotalChocoladeIn1997 AS (
SELECT 
	P.ProductID,
	MAX(P.ProductName) AS ProductName,
	SUM(OD.Quantity) AS TotalQuantity
FROM Products P 
JOIN [Order Details] OD on P.ProductID = OD.ProductID
JOIN Orders O on OD.OrderID = O.OrderID
WHERE O.OrderDate >= '1997-01-01' AND O.OrderDate < '1998-01-01' AND P.ProductName = 'Chocolade'
GROUP BY P.ProductID
);
GO

SELECT * FROM TotalChocoladeIn1997;

BEGIN TRANSACTION
	INSERT INTO Products(ProductName, Discontinued)
	VALUES ('Programming in Java', 0);

	UPDATE [Order Details]
	SET Quantity = Quantity + 1
	WHERE ProductID = (SELECT P.ProductID FROM Products P WHERE P.ProductName = 'Chocolade') AND
		OrderID IN (SELECT O.OrderID FROM Orders O WHERE YEAR(O.OrderDate) = 1997)
	SELECT * FROM TotalChocoladeIn1997;
COMMIT;
GO

SELECT * FROM TotalChocoladeIn1997;


-- Task #7
SELECT * FROM TotalChocoladeIn1997;

BEGIN TRANSACTION
	UPDATE [Order Details]
	SET Quantity = 2*Quantity
	WHERE ProductID = (SELECT P.ProductID FROM Products P WHERE P.ProductName = 'Chocolade') AND
		OrderID IN (SELECT O.OrderID FROM Orders O WHERE YEAR(O.OrderDate) = 1997)

	SELECT * FROM TotalChocoladeIn1997;
ROLLBACK;
GO

SELECT * FROM TotalChocoladeIn1997;

-- Task #8
-- NOT WORKING

--GO
--CREATE VIEW TotalIkura AS (
--	SELECT 
--		P.ProductID,
--		MAX(P.ProductName) as ProductName,
--		SUM(OD.Quantity) as TotalQuantity
--	FROM Products P
--	JOIN [Order Details] OD ON P.ProductID = OD.ProductId
--	WHERE P.ProductName = 'Ikura'
--	GROUP BY P.ProductID
--);
--GO

--select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where table_name = 'Order Details'

--BEGIN TRANSACTION T1
--	UPDATE [Order Details]
--		SET Quantity = 2*Quantity
--		WHERE ProductID = (SELECT P.ProductID FROM Products P WHERE P.ProductName = 'Chocolade') AND
--			OrderID IN (SELECT O.OrderID FROM Orders O WHERE YEAR(O.OrderDate) = 1997)
--	GO

--	BEGIN TRANSACTION T2
--		SELECT * FROM TotalIkura;

--		-- first delete from Order Details due to constraint FK_Order_Details_Orders
--		DELETE FROM [Order Details]
--		WHERE OrderID NOT IN (
--			SELECT DISTINCT OD.OrderID FROM [Order Details] OD
--			JOIN Products P on P.ProductID = OD.ProductID AND P.ProductName = 'Chocolade'
--			)

--		DELETE FROM Orders
--		WHERE OrderID NOT IN (
--			SELECT DISTINCT OD.OrderID FROM [Order Details] OD
--			JOIN Products P on P.ProductID = OD.ProductID AND P.ProductName = 'Chocolade'
--			)
--		GO
	

--		INSERT INTO [Order Details]
--		SELECT 
--			A.OrderID,
--			P2.ProductID,
--			14.5 AS UnitPrice,
--			1 AS Quantity,
--			0 AS Discount
--		FROM (
--			SELECT DISTINCT OD.OrderID FROM [Order Details] OD
--			WHERE NOT EXISTS (
--				SELECT * FROM [Order Details] OD2
--				JOIN Products P on OD2.ProductID = P.ProductID
--				WHERE P.ProductName = 'Ikura' and OD2.OrderID = OD.OrderID
--			)
--		) A
--		JOIN Products P2 ON 1=1 WHERE P2.ProductName = 'Ikura'
--		;
--		GO
--		SELECT * FROM TotalIkura;
--		GO
--	ROLLBACK TRAN T2_Save;
--		GO
--	COMMIT TRAN T2;
--		GO

--	SELECT * FROM TotalIkura;
--	GO
--	UPDATE [Order Details]
--		SET Quantity = 2*Quantity
--		WHERE ProductID = (SELECT P.ProductID FROM Products P WHERE P.ProductName = 'Ikura') AND
--			OrderID IN (SELECT O.OrderID FROM Orders O WHERE YEAR(O.OrderDate) = 1997);
--	GO
--COMMIT TRAN T1;


-- SCENARIO #1
SELECT * 
INTO ArchivedOrders
FROM Orders
WHERE 0=1;
GO

ALTER TABLE ArchivedOrders
	ADD CONSTRAINT PK_ArchivedOrder PRIMARY KEY(OrderID),
		CONSTRAINT FK_ArchivedOrders_Clients FOREIGN KEY(CustomerID) REFERENCES Customers(CustomerID),
		CONSTRAINT FK_ArchivedOrders_Employees FOREIGN KEY(EmployeeID) REFERENCES Employees(EmployeeID),
		ArchiveDate DATETIME;
GO
SELECT *
INTO ArchivedOrderDetails
FROM [Order Details]
WHERE 0=1;
GO

-- DROP TABLE ArchivedOrders;
-- DROP TABLE ArchivedOrderDetails;
BEGIN TRY
BEGIN TRAN arch
	SET IDENTITY_INSERT ArchivedOrders ON;
	GO

	INSERT INTO ArchivedOrders(OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry)
	SELECT *
	FROM Orders O
	WHERE YEAR(O.OrderDate) = 1996;

	INSERT INTO ArchivedOrderDetails
	SELECT * 
	FROM [Order Details] OD
	WHERE EXISTS (
		SELECT *
		FROM Orders O
		WHERE YEAR(O.OrderDate) = 1996 AND O.OrderID = OD.OrderID
	)

	DELETE FROM [Order Details]
	WHERE EXISTS (
		SELECT *
		FROM Orders O
		WHERE YEAR(O.OrderDate) = 1996 AND O.OrderID = OrderID
	)

	DELETE FROM Orders
	WHERE YEAR(OrderDate) = 1996;

	UPDATE ArchivedOrders
	SET ArchiveDate = SYSDATETIME();

	SET IDENTITY_INSERT ArchivedOrders OFF;
	GO
COMMIT TRAN arch;
END TRY

BEGIN CATCH 
	ROLLBACK TRAN arch
END CATCH 

-- SCENARIO #2
ALTER TABLE orders 
ADD IsCancelled INT;
GO

UPDATE Orders SET IsCancelled = CASE WHEN CustomerID = 'ALFKI' THEN 1 ELSE 0 END;

UPDATE [Order Details] SET Quantity = 0 
WHERE OrderId IN (SELECT OrderID from Orders where IsCancelled = 1) ;

SELECT * FROM [Order Details] WHERE OrderId in (
	SELECT OrderID FROM Orders WHERE CustomerID = 'ALFKI'
)


-- SCENARIO #3
select * from sys.objects

IF OBJECT_ID('pricelist') IS NOT NULL 
	drop table pricelist;
GO

create table pricelist ( 
	productID int not null , 
	price money not null ,
	date_from datetime not null, 
	date_to datetime not null,
	CONSTRAINT  [PK_pricelist] PRIMARY KEY CLUSTERED (productID, date_from, date_to),
	CONSTRAINT  [FKP_product] FOREIGN KEY (productID) REFERENCES Products (ProductID) 
	)
GO

INSERT INTO pricelist 
select productID , ROUND(100*RAND(ABS(CHECKSUM(NewID()))),2) price,  t1 , t2 
from Products P , 
	( select distinct
		 DATEFROMPARTS( YEAR(OrderDate), 1, 1 )  t1 ,
		 DATEFROMPARTS( YEAR(OrderDate)+1, 1, 1 )  t2
	from Orders ) t
GO


alter table orders add totalvalue money;

update orders set totalvalue = (select sum(odvalue)
								from (select price*quantity as odvalue
										from [order details] od join pricelist pl on od.productid=pl.productid
										where od.orderid=orders.orderid
											 and orderdate< date_to
											 and orderdate>=date_from) linevals
								)
-- solution check 		 
	select COUNT(*) from orders where 
	totalvalue=(select sum(quantity*price) from
	[order details] od join pricelist pl on od.productid=pl.productid
	where od.orderid=orders.orderid and orderdate< date_to and orderdate>=date_from)
	
	select count(*) from orders

