USE master
GO

if exists (select * from sysdatabases where name='orders_dwh')
		drop database orders_dwh
GO

CREATE DATABASE orders_dwh
GO

USE orders_dwh
GO

SELECT * INTO Customers FROM Northwind.dbo.Customers;
GO
ALTER TABLE Customers
	ADD CONSTRAINT PK_Customers PRIMARY KEY (CustomerID);

SELECT 
	P.ProductID,
	P.ProductName,
	C.CategoryName,
	P.QuantityPerUnit,
	P.UnitPrice,
	P.UnitsInStock,
	P.UnitsOnOrder,
	P.ReorderLevel,
	P.Discontinued
INTO Products FROM Northwind.dbo.Products P
JOIN Northwind.dbo.Categories C on C.CategoryID = P.CategoryID
GO
ALTER TABLE Products
	ADD CONSTRAINT PK_Products PRIMARY KEY (ProductID);

SELECT O.*, OD.ProductID, OD.UnitPrice, OD.Quantity, OD.Discount 
INTO Order_facts
FROM Northwind.dbo.Orders O
JOIN Northwind.dbo.[Order Details] OD on O.OrderID = OD.OrderID

ALTER TABLE Order_facts
	ADD CONSTRAINT PD_Order_facts PRIMARY KEY (OrderID, ProductID),
		CONSTRAINT FK_Order_facts_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
		CONSTRAINT FK_Order_facts_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID);
ALTER TABLE Order_facts
	DROP COLUMN EmployeeID, ShipVia






