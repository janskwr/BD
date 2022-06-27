use Northwind
go


select 
	e.EmployeeID,
	max(e.FirstName) as FirstName,
	max(e.LastName) as LastName,
	count(*) as Count
from Employees e
join Orders o on e.EmployeeID = o.EmployeeID
group by e.EmployeeID
having count(*) > 1.2 * (
	select avg(tmp.Count) from (
		select count(*) as 'Count'
		from Employees e 
		join Orders o on o.EmployeeID = e.EmployeeID
		group by e.EmployeeID
	) tmp
)


with emp_ordrs as (
	select 
		e.EmployeeID, 
		max(e.FirstName) FirstName, 
		max(e.LastName) LastName, 
		count(*) as ordr_cnt
	  from Employees e 
	  join Orders o on e.EmployeeID = o.EmployeeID
	  group by e.EmployeeID
)
select 
	*
from emp_ordrs
where ordr_cnt > (select 1.2 * avg(ordr_cnt) from emp_ordrs)

select * from Orders where OrderID in (
	select TOP 5 od.OrderID 
	from [Order Details] od
	group by od.OrderID
	order by count(*) desc
)

--with A as (
--	select od.OrderID, count(*) as cnt
--	from [Order Details] od
--	group by od.OrderID
--)
--select 
--	A1.OrderID,
--	count(*) as cnt
--from A A1
--left join A A2 on A1.cnt < A2.cnt
--group by A1.OrderID
--order by count(*) 

with A as (
	select od.OrderID, count(*) as cnt
	from [Order Details] od
	group by od.OrderID
)
select 
	*
from A A1
left join A A2 on A1.cnt < A2.cnt
where A2.OrderID is null





select od.OrderID, count(*) as cnt
	from [Order Details] od
	group by od.OrderID
	having od.OrderID = 10657



select
	p.ProductName,
	ISNULL(cnt_1996,0) as TotalQuantityIn1996,
	cnt_1997 as TotalQuantityIn1997
from Products p
left join (
	select 
		od.ProductID,
		sum(od.Quantity) as cnt_1996
	from [Order Details] od
	join Orders o on od.OrderID = o.OrderID
	where o.OrderDate  >= '1996-01-01' AND o.OrderDate < '1997-01-01'
	group by od.ProductID
) Y1996 on p.ProductID = Y1996.ProductID
join (
	select 
		od2.ProductID,
		sum(od2.Quantity) as cnt_1997
	from [Order Details] od2
	join Orders o2 on od2.OrderID = o2.OrderID
	where year(o2.OrderDate) = 1997
	group by od2.ProductID
) Y1997 on p.ProductID = Y1997.ProductID
where cnt_1997 > ISNULL(cnt_1996, 0)


select
	p.ProductName,
	cnt_1996 as TotalQuantityIn1996,
	cnt_1997 as TotalQuantityIn1997
from Products P
join (
	select 
		od.ProductID, 
		sum(case when (year(OrderDate) = 1996) then Quantity else 0 end) cnt_1996,
		sum(case when (year(OrderDate) = 1997) then Quantity else 0 end) cnt_1997
	from [Order Details] od
	join Orders o on od.OrderID = o.OrderID
	group by od.ProductID
) A on A.ProductID = P.ProductID
where A.cnt_1997 > A.cnt_1996


select
	p.ProductName,
	cnt_1996 as NumberOfOrdersIn1996,
	cnt_1997 as NumberOfOrdersIn1997
from Products P
join (
	select 
		od.ProductID, 
		sum(case when (year(OrderDate) = 1996) then 1 else 0 end) cnt_1996,
		sum(case when (year(OrderDate) = 1997) then 1 else 0 end) cnt_1997
	from [Order Details] od
	join Orders o on od.OrderID = o.OrderID
	group by od.ProductID
) A on A.ProductID = P.ProductID
where A.cnt_1997 > A.cnt_1996

GO
CREATE VIEW OrdersTotal as(
	select 
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
	from Orders O
	join Customers CS on O.CustomerID = CS.CustomerID
	join [Order Details] OD on OD.OrderID = O.OrderID
	join Products P on P.ProductID = OD.ProductID
	join Categories CT on CT.CategoryID = P.CategoryID
);
GO

SELECT * FROM OrdersTotal;

SELECT 
	OrderID,
	ProductName,
	CategoryName,
	ProductValue,
	SUM(ProductValue) OVER (PARTITION BY ProductName) as ProdTotalSale,
	SUM(ProductValue) OVER (PARTITION BY CategoryName) as CategoryTotalSale
FROM OrdersTotal
order by ProductName
;

select 
	OrderID,
	ProductID,
	ProductValue,
	SUM(ProductValue) OVER (ORDER BY OrderId, ProductId ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as ProdTotalSale
from OrdersTotal
order by OrderID

select 
	OrderID,
	ProductID,
	ProductValue,
	SUM(ProductValue) OVER (ORDER BY OrderId, ProductId ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as ProdTotalSale
from OrdersTotal 
order by OrderID, ProductID

select 
	ProductName, 
	OrderYear, 
	OrderMonth,
	SUM(OrderTotal) OVER (PARTITION BY ProductName,OrderYear,OrderMonth) AS ProductMonthSale,
	SUM(OrderTotal) OVER (PARTITION BY ProductName,OrderYear ORDER BY OrderMonth) as ProdUntilMonthSale,
	count(*) OVER (PARTITION BY ProductName,OrderYear ORDER BY OrderMonth) as MonthCount
from (
	select 
		sum(ProductValue) as OrderTotal, 
		ProductName, 
		OrderYear, 
		OrderMonth
	from OrdersTotal
	group by ProductName, OrderYear, OrderMonth
) as OrdersGrouped
order by ProductName,OrderYear,OrderMonth

SELECT *
FROM Products P
WHERE P.ProductID = 48

UPDATE Products
SET ProductName = 'Choco'
WHERE ProductID = 48

DELETE FROM Products
WHERE ProductID = 48

DELETE FROM [Order Details]
WHERE ProductID = 48

SELECT *
FROM [Order Details]
WHERE ProductID = 48

SELECT * 
FROM [Order Details] OD


INSERT INTO [Order Details]
VALUES (10250, 48, 13.0, 10, 0), (10251, 48, 13.0, 10, 0)

INSERT INTO Customers (CustomerID, CompanyName)
VALUES ('ABCDE', 'MINI PW')

SELECT *
FROM Customers

INSERT INTO [Order Details]
SELECT 
	12293 as OrderId,
	OD.ProductID,
	OD.UnitPrice,
	OD.Quantity + 2 as Quantity,
	0 as Discount
FROM [Order Details] OD
WHERE OD.ProductID = 48

SELECT *
INTO Products_InOrder
FROM Products
WHERE 0=1


SELECT * FROM Products 

SELECT * FROM Products_InOrder

DELETE FROM Products_InOrder
WHERE 1=1

ALTER TABLE Products_InOrder
SET IDENTITY_INSERT Products_InOrder OFF

INSERT INTO Products_InOrder
SELECT * FROM Products
WHERE UnitsOnOrder > 0


SELECT 
	OD.Quantity,
	O.OrderDate,
	P.ProductName
FROM [Order Details] OD
JOIN Orders O on OD.OrderID = O.OrderID
JOIN Products P on OD.ProductID = P.ProductID
WHERE P.ProductName = 'Ikura' AND O.OrderDate > '1997-05-15'
;

UPDATE [Order Details]
SET Quantity = ROUND(0.8*Quantity, 0)
WHERE EXISTS (SELECT * FROM Products P WHERE P.ProductID = [Order Details].ProductID AND P.ProductName = 'Ikura') AND
	EXISTS (SELECT * FROM Orders O WHERE O.OrderID = [Order Details].OrderID AND O.OrderDate > '1997-05-15')
;

