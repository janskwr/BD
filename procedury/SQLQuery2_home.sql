select Distinct Substring(UPPER( ShipName ),1,10)
from Orders
where OrderDate between '19960701' and '19960731';


select CONVERT(varchar,X.Data,112) ISO,
	CONVERT(varchar,X.Data,110) USA,
	Substring(CONVERT(varchar,X.Data,112),1,6)+'01' First_Day,
	LEN(CONVERT(varchar,X.Data,112)) Len
from (select GETDATE() as Data) as X;

select distinct O.ShipCountry
from Orders O
join Customers C on O.CustomerID = C.CustomerID
where C.Country = 'Germany'

select O.*
from Orders O
join Customers C on O.CustomerID = C.CustomerID
where o.ShipCountry != c.Country

select * 
from Customers c
where not exists 
(
select * 
from Orders o 
join [Order Details] od on o.OrderID = od.OrderID
join Products p on p.ProductID = od.ProductID and p.ProductName='Chocolade'
where o.CustomerID = c.CustomerID
)

select * from customers c where not exists (select *
from orders o where o.customerid=c.customerid
and exists (select * from [order details] od join
products p on p.productid=od.productid where
od.orderid=o.orderid and
p.productname='Chocolade'))


select * 
from Customers c
where  exists 
(
select * 
from Orders o 
join [Order Details] od on o.OrderID = od.OrderID
join Products p on p.ProductID = od.ProductID and p.ProductName='Scottish Longbreads'
where o.CustomerID = c.CustomerID
)

select * from customers c where exists (select * from
orders o join [order details] od on od.orderid=o.orderid
join products p on p.productid=od.productid where
p.productname='Scottish Longbreads' and
o.customerid=c.customerid)

select * 
from Orders o
where  exists 
	(
	select * 
	from Customers c 
	join [Order Details] od on o.OrderID = od.OrderID
	join Products p on p.ProductID = od.ProductID and p.ProductName='Scottish Longbreads'
	where o.CustomerID = c.CustomerID
	)
and
not exists 
	(
	select * 
	from Customers c 
	join [Order Details] od on o.OrderID = od.OrderID
	join Products p on p.ProductID = od.ProductID and p.ProductName='Chocolade'
	where o.CustomerID = c.CustomerID
	)

	select * from orders o where
exists (select * from [order details] od join products p
on p.productid=od.productid where
productname='Scottish Longbreads' and
od.orderid=o.orderid)
and not exists (select * from [order details] od join
products p on p.productid=od.productid where
productname='Chocolade' and od.orderid=o.orderid)

select distinct e.FirstName [Employee name], e.LastName surname
from Employees e
join Orders o on e.EmployeeID = o.EmployeeID
join Customers c on o.CustomerID = c.CustomerID
where c.CustomerID ='ALFKI'

select firstname, lastname from employees e where
exists (select * from orders o
where customerid='ALFKI' and
e.employeeid=o.employeeid)

select e.FirstName, e.LastName, c.CompanyName, o.OrderDate,
	case when choco.OrderId is not null then 1 else 0 end as status
from Employees e 
join Orders o on e.EmployeeID = o.EmployeeID
left join ( 
select distinct od.OrderID 
from [Order Details] od 
join Products p on od.ProductID = p.ProductID and p.ProductName = 'Chocolade'
) choco
on o.OrderID = choco.OrderID
join Customers c on c.CustomerID = o.CustomerID

select firstname, lastname,companyname, orderdate,
(case when od.orderid is null then 0 else 1 end) as status 
from employees e
left join orders o on o.employeeid=e.employeeid
left join [order details] od on o.orderid=od.orderid and
od.productid=(
	select productid 
	from products 
	where productname='Chocolade'
	)
left join customers c on c.customerid=o.customerid

select e.FirstName, e.LastName, c.CompanyName, o.OrderDate,
(case when od.OrderID is null then 0 else 1 end)
from Customers c
left join  Orders o on o.CustomerID = c.CustomerID
left join [Order Details] od on od.OrderID = o.OrderID and od.ProductID = 
(select ProductID
from Products
where ProductName = 'Chocolade'
)
left join Employees e on e.EmployeeID = o.EmployeeID

select p.ProductID, o.ShipCountry, COUNT(*)
from Products p
join [Order Details] od on p.ProductID = od.ProductID
join Orders o on od.OrderID = o.OrderID
join Employees e on e.EmployeeID = o.EmployeeID
group by o.ShipCountry, p.ProductID

select c.CompanyName
from Customers c
where exists(
	select *
	from Orders o
	join [Order Details] od on od.OrderID = o.OrderID
	where od.ProductID = (select p.ProductID from Products p where p.ProductName = 'Chocolade')
	and c.CustomerID = o.CustomerID
)

select e.FirstName as Name, e.LastName as Surname, sum(od.Quantity) as Quantity
from Employees e
join Orders o on e.EmployeeID = o.EmployeeID and year(o.OrderDate) = 2000
join [Order Details] od on od.OrderID = o.OrderID 
and od.ProductID = (select p.ProductID from Products p where p.ProductName = 'Chocolade') 

group by e.FirstName,e.LastName
having sum(od.Quantity) >=100;

select  p.ProductName
from Products p
join [Order Details] od on od.ProductID = p.ProductID
join Orders o on o.OrderID = od.OrderID
join Customers c on c.CustomerID = o.CustomerID and c.Country = 'Italy'
group by  p.ProductName
having AVG(od.Quantity) >= 20
order by count(distinct o.OrderID) desc;

select p.ProductName
from Products p 
where exists(
	select *
	from Orders o
	join [Order Details] od on o.OrderID = od.OrderID
	where od.ProductID = p.ProductID and o.ShipCountry = 'France'
	)
	and
	not exists(
	select *
	from Orders o
	join [Order Details] od on o.OrderID = od.OrderID
	where od.ProductID = p.ProductID and o.ShipCountry = 'Belgium'
	)

select c.CompanyName, p.ProductName, o.OrderDate, od.Quantity
from Customers c
join Orders o on o.CustomerID = c.CustomerID and c.City ='Berlin'
join [Order Details] od on od.OrderID = o.OrderID
join Products p on p.ProductID = od.ProductID
order by c.CompanyName, p.ProductName, o.OrderDate

select distinct p.*
from Products p
join [Order Details] od on od.ProductID = p.ProductID
join Orders o on o.OrderID = od. OrderID
where o.ShipCountry = 'France' and o.OrderDate >= '19980101' and o.OrderDate < '19990101'
order by p.ProductID;

select c.CompanyName
from Customers c
join Orders o on o.CustomerID = c.CustomerID
where not exists
(select * from Orders o
join [Order Details] od on od.OrderID = o.OrderID
join Products p on od.ProductID = p.ProductID
where p.ProductName like 'Ravioli%' and o.CustomerID = c.CustomerID
)
group by c.CompanyName having COUNT(*)>=2;

select o.*
from Orders o
where exists(
select * from [Order Details] od where od.OrderID = o.OrderID group by od.OrderID having COUNT(*)>4
)
and o.CustomerID in (select c.CustomerID from Customers c where c.Country = 'France');

select od.OrderID,count(*) from [Order Details] od group by od.OrderID having count(*)>9

select c.* from Customers c
join Orders o on c.CustomerID  = o.CustomerID
where o.OrderID = (select od.OrderID from [Order Details] od group by od.OrderID having count(*)>9)


select c.CompanyName
from Customers c
where exists (
select * from Orders o
where o.CustomerID = c.CustomerID and o.ShipCountry ='France'
group by o.CustomerID
having count(*) >=5
)
and not exists
(
select * from Orders o
where o.CustomerID = c.CustomerID and o.ShipCountry ='Belgium'
group by o.CustomerID
having count(*) >2
);

select distinct od.ProductID,o.CustomerID, od.Quantity
from Orders o
join [Order Details] od on od.OrderID = o.OrderID
where od.Quantity = (select max(od2.Quantity) from [Order Details] od2 where od.ProductID = od2.ProductID)

select distinct ProductID, CustomerID, od.Quantity from
Orders o join [Order Details] od on o.OrderID = od.OrderID
where od.Quantity = 
(select max(od2.Quantity) from [Order Details] od2
where od2.ProductID = od.ProductID) ;

select distinct od2.ProductID,od2.Quantity,o.CustomerID
from [Order Details] od2
join
(select x1.ProductID,x1.Quantity from 
(select distinct od.ProductID,od.Quantity
from [Order Details] od
) as x1
join (select distinct od.ProductID,od.Quantity
from [Order Details] od
) as x2
on x1.ProductID = x2.ProductID and x1.Quantity <= x2.Quantity
group by x1.ProductID,x1.Quantity
having count(*) =1) as x
on x.ProductID = od2.ProductID and x.Quantity = od2.Quantity
join Orders o on o.OrderID = od2.OrderID
order by 1,2

with emp_orders as 
		(select e.EmployeeID,e.FirstName,e.LastName, count(*) Orders_serviced
		from Employees e
		join Orders o on e.EmployeeID=o.EmployeeID
		group by e.EmployeeID,e.FirstName,e.LastName)

	select *
	from emp_orders
	where Orders_serviced > (select 1.2*avg(Orders_serviced) from emp_orders);

select o.EmployeeID, e.FirstName, e.LastName, count(*) as Orders_serviced
from Orders o 
	join Employees e
	on e.EmployeeID = o.EmployeeID
group by o.EmployeeID, e.FirstName, e.LastName
having count(*) > (select 1.2 * count(o2.EmployeeID)/ count(distinct o2.EmployeeID) from Orders o2 );

select * from Orders o
where o.OrderID in
(select top 5 o.OrderID
from Orders o 
join [Order Details] od on od.OrderID = o.OrderID
group by o.OrderID
order by count(*) desc)

select *
from Products p 
where
(select COUNT(*)
from [Order Details] od
where p.ProductID = od.ProductID and od.OrderID in (select o.OrderID from Orders o where year(o.OrderDate) = 1997)
) >
(select COUNT(*)
from [Order Details] od
where p.ProductID = od.ProductID and od.OrderID in (select o.OrderID from Orders o where year(o.OrderDate) = 1996)
)

select count(*),count(ShipRegion) from Orders;

select p.ProductName as ProductName,
(select  count(*) from [Order Details] od 
join Orders o on od.OrderID = o.OrderID  where od.ProductID =p.ProductID and year(o.OrderDate)=1996) as NoOfOrders1996,
(select  count(*) from [Order Details] od 
join Orders o on od.OrderID = o.OrderID  where od.ProductID =p.ProductID and year(o.OrderDate)=1997) as NoOfOrders1997,
(select  count(*) from [Order Details] od 
join Orders o on od.OrderID = o.OrderID  where od.ProductID =p.ProductID and year(o.OrderDate)=1998) as NoOfOrders1998
from Products p

select p.ProductID,
sum(case when o.OrderDate >= '19960101' and o.OrderDate < '19970101' then 1 else 0 end) as NoOfOrders1996,
sum(case when o.OrderDate >= '19970101' and o.OrderDate < '19980101' then 1 else 0 end) as NoOfOrders1997,
sum(case when o.OrderDate >= '19980101' and o.OrderDate < '19990101' then 1 else 0 end) as NoOfOrders1998
from Products p
join [Order Details] od on od.ProductID = p.ProductID
join Orders o on o.OrderID = od.OrderID
group by p.ProductID;

with emp as (
select e.EmployeeID as ID,
sum(case when o.OrderDate >= '19961201' and o.OrderDate < '19970101' then 1 else 0 end) as NoOfOrders1996,
sum(case when o.OrderDate >= '19971201' and o.OrderDate < '19980101' then 1 else 0 end) as NoOfOrders1997
from Employees e
join Orders o on o.EmployeeID = e.EmployeeID
group by e.EmployeeID
)
select top 2 e.*
from Employees e
where e.EmployeeID in (select ID from emp where  emp.NoOfOrders1996 > emp.NoOfOrders1997)



with emp_orders as 
		(select e.EmployeeID,e.FirstName,e.LastName, count(*) Orders_serviced
		from Employees e
		join Orders o on e.EmployeeID=o.EmployeeID
		group by e.EmployeeID,e.FirstName,e.LastName)

	select *
	from emp_orders
	where Orders_serviced > (select 1.2*avg(Orders_serviced) from emp_orders);
