--QUERY #1
select 
  od.ProductID, 
  o.ShipCountry, 
  sum(od.Quantity) as TotalQuantity
from [Order Details] od
join Orders o on od.OrderID = o.OrderID 
where o.EmployeeID = 2
group by od.ProductID, o.ShipCountry

--QUERY #2
select 
  e.FirstName as EmployeeName, 
  e.LastName  as EmployeeSurname, 
  sum(od.Quantity) as TotalQuantity 
from Employees e 
join Orders o on e.EmployeeID = o.EmployeeID
join [Order Details] od on o.OrderID = od.OrderID 
join Products p on od.ProductID = p.ProductID
where p.ProductName = 'Chocolade' and year(o.OrderDate) = 1998
group by e.EmployeeID, e.FirstName, e.LastName
having sum(od.Quantity) >= 100

--QUERY #3
SELECT
	ProductName,
	c.*,
	OrdersCount
FROM(
	select 
		MAX(p.ProductName) AS ProductName,
		c.CustomerID,
		count(distinct o.OrderID) OrdersCount
	from Products p 
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on od.OrderID = o.OrderID 
	join Customers c on o.CustomerID = c.CustomerID
	where c.Country = 'Italy'
	group by p.productID, c.CustomerID
	having avg(od.Quantity) >= 20
) A
join Customers c on c.CustomerID = A.CustomerID
order by OrdersCount desc

--QUERY #4
select 
  c.ContactName, 
  p.ProductName, 
  o.OrderDate, 
  od.Quantity 
from Products p 
join [Order Details] od on p.ProductID = od.ProductID
join Orders o on od.OrderID = o.OrderID 
join Customers c on o.CustomerID = c.CustomerID
where c.City = 'Berlin'
order by c.ContactName, p.ProductName, o.OrderDate

--QUERY #5
select distinct p.ProductName 
from Products p 
join [Order Details] od on p.ProductID = od.ProductID
join Orders o on od.OrderID = o.OrderID 
where o.ShipCountry = 'France' AND YEAR(o.ShippedDate) = 1998

--QUERY #6
select 
  c.ContactName 
from Customers c 
join Orders o on c.CustomerID = o.CustomerID
where not exists(
  select * from Orders o 
  join [Order Details] od on o.OrderID = od.OrderID 
  join Products p on od.ProductID = p.ProductID
  where p.ProductName like 'Ravioli%' 
    and c.CustomerID = o.CustomerID
)
group by c.ContactName
having count(*) >= 2

--QUERY #7
select 
  max(c.CompanyName) CompanyName,
  o.OrderID,
  count(distinct od.productID) as ProductCount
from Orders o
join [Order Details] od on o.OrderID = od.OrderID
join Customers c on o.CustomerID = c.CustomerID
where c.Country = 'France'
group by o.OrderID
having count(distinct od.productID) >= 4

--QUERY #8
select c.CompanyName from Customers c 
join Orders o on c.CustomerID = o.CustomerID
where o.ShipCountry = 'France' and not exists(
  select *  from Customers cc 
  join Orders o on cc.CustomerID = o.CustomerID
  where o.ShipCountry = 'Belgium' and c.CustomerID = cc.CustomerID
  group by cc.CompanyName
  having count(*) > 2
)
group by c.CompanyName
having count(*) >= 5

select CompanyName
from (
  select CompanyName,
    case when (ShipCountry = 'France' and OrdersCount >= 5) then 0 else 1 end as sh_fr,
    case when (ShipCountry = 'Belgium' and OrdersCount > 2) then 1 else 0 end as sh_bg
  from (
    select CompanyName, ShipCountry, count(*) as OrdersCount
    from Customers c 
    join Orders o on c.CustomerID = o.CustomerID
    and ShipCountry in ('France', 'Belgium')
    group by CompanyName, ShipCountry
  ) ordrs
) ordrs_reslt
group by CompanyName
having sum(sh_fr + sh_bg) = 0;

SELECT CompanyName
FROM Customers c
WHERE
    (SELECT COUNT(*)
    FROM Orders o
    WHERE o.CustomerID=c.CustomerID AND o.ShipCountry='France')>= 5
    AND
    (SELECT COUNT(*)
    FROM Orders o
    WHERE o.CustomerID=c.CustomerID AND o.ShipCountry = 'Belgium')<=2

--QUERY #9
select distinct 
  p.ProductName, 
  c.CompanyName, 
  od.Quantity as MaxQuantity
from Orders o 
join [Order Details] od on o.OrderID = od.OrderID
join Products p on p.ProductID = od.productID
join Customers c on o.CustomerID = c.CustomerID
where od.Quantity = (
  select max(od2.Quantity) from [Order Details] od2
  where od2.ProductID = od.ProductID
)

--QUERY #10
select 
	e.EmployeeID, 
	max(e.FirstName) FirstName, 
	max(e.LastName) LastName 
from Employees e 
join Orders o on e.EmployeeID = o.EmployeeID
group by e.EmployeeID
having count(*) > 1.2 *(
	select avg(tmp.Count) from(
		select count(*) as 'Count' 
		from Employees e 
		join Orders o on e.EmployeeID = o.EmployeeID
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
select EmployeeID, FirstName, LastName
from emp_ordrs
where ordr_cnt > (select 1.2 * avg(ordr_cnt) from emp_ordrs);

--QUERY #11
SELECT TOP 5 WITH TIES
    OD.OrderID, 
    COUNT(DISTINCT OD.ProductID) AS ProductCount
FROM [Order Details] AS OD
GROUP BY OD.OrderID
ORDER BY ProductCount DESC

--QUERY #12
select
	p.ProductName,
	ISNULL(cnt_1996, 0) as TotalQuantityIn1996,
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
	cnt_1996 as TotalQuantityIn1996,
	cnt_1997 as TotalQuantityIn1997
from Products P
join (
	select 
		od.ProductID, 
		sum(case when (OrderDate >= '1996-01-01' AND OrderDate < '1997-01-01') then Quantity else 0 end) cnt_1996,
		sum(case when (OrderDate >= '1997-01-01' AND OrderDate < '1998-01-01') then Quantity else 0 end) cnt_1997
	from [Order Details] od
	join Orders o on od.OrderID = o.OrderID
	where o.OrderDate >= '1996-01-01' AND o.OrderDate < '1998-01-01'
	group by od.ProductID
) A on A.ProductID = P.ProductID
where A.cnt_1997 > A.cnt_1996

--QUERY #13
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

--QUERY #14
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

--QUERY #15
SELECT 
	OrderID,
	ProductName,
	CategoryName,
	ProductValue,
	SUM(ProductValue) OVER (PARTITION BY ProductName) as ProdTotalSale,
	SUM(ProductValue) OVER (PARTITION BY CategoryName) as CategoryTotalSale
FROM OrdersTotal
order by ProductName

--QUERY #16
select distinct 
	ProductName,
	CategoryName,
	SUM(ProductValue) OVER (PARTITION BY ProductName) as ProdTotalSale,
	SUM(ProductValue) OVER (PARTITION BY CategoryName) as CategoryTotalSale,
	SUM(ProductValue) OVER () as TotalSale
from OrdersTotal
order by ProductName

--QUERY #17
select 
	OrderID,
	ProductID,
	ProductValue,
	SUM(ProductValue) OVER (ORDER BY OrderId, ProductId ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as ProdTotalSale
from OrdersTotal
order by OrderID

--QUERY #18
select 
	OrderID,
	ProductID,
	ProductValue,
	SUM(ProductValue) OVER (ORDER BY OrderId, ProductId ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as ProdTotalSale
from OrdersTotal 
order by OrderID, ProductID

--QUERY #19
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
