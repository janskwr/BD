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
		p.ProductName,
		c.CustomerID,
		count(distinct o.OrderID) OrdersCount
	from Products p 
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on od.OrderID = o.OrderID 
	join Customers c on o.CustomerID = c.CustomerID
	where c.Country = 'Italy'
	group by p.ProductName, c.CustomerID
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
