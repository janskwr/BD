
--QUERY #1
SELECT * 
FROM Orders;

--QUERY #2
SELECT * 
FROM Orders 
WHERE ShipCountry = 'Brazil' or ShipCountry = 'Mexico' or ShipCountry = 'Germany'

SELECT * 
FROM Orders 
WHERE ShipCountry in ('Brazil','Mexico','Germany')


--QUERY #3
SELECT DISTINCT ShipCity 
FROM Orders
WHERE ShipCountry = 'Germany'


--QUERY #4
SELECT * 
FROM Orders 
WHERE OrderDate >= '1996-07-01' AND OrderDate < '1996-08-01'

SELECT * 
FROM Orders 
WHERE MONTH(OrderDate) = 7 AND YEAR(OrderDate) = 1996


--QUERY #5
SELECT UPPER(SUBSTRING(CompanyName,1,10)) AS 'Company code' 
FROM Customers


--QUERY #6
SELECT o.* 
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.Country = 'France'


--QUERY #7
SELECT DISTINCT ShipCountry 
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID 
WHERE c.Country = 'Germany'


--QUERY #8
SELECT o.* 
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID 
WHERE c.Country != o.ShipCountry


--QUERY #9
SELECT * 
FROM Customers c 
WHERE NOT EXISTS (SELECT *FROM Orders o WHERE o.CustomerID = c.CustomerID)

SELECT * 
FROM Customers c
LEFT OUTER JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;

WITH ord_cust AS (
  SELECT DISTINCT CustomerID FROM Orders
)
SELECT * 
FROM Customers c 
LEFT OUTER JOIN ord_cust oc ON c.CustomerID = oc.CustomerID
WHERE oc.CustomerID IS NULL;

SELECT * FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
except
SELECT * FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID

--QUERY #10
SELECT * FROM Customers c WHERE NOT EXISTS (
  SELECT *
  FROM Orders o 
  WHERE o.CustomerID = c.CustomerID
  AND EXISTS (
    SELECT * 
    FROM [Order Details] od 
    JOIN Products p ON p.ProductID = od.ProductID 
    WHERE od.OrderID = o.OrderID AND p.ProductName = 'Chocolade'
    )
  )

SELECT * 
FROM Customers c 
WHERE NOT EXISTS (
  SELECT *
  FROM Orders o 
  WHERE o.CustomerID = c.CustomerID AND EXISTS (
    SELECT * 
    FROM [Order Details] od 
    WHERE od.OrderID = o.OrderID AND od.ProductID = (
      SELECT ProductID 
      FROM Products p 
      WHERE p.ProductName = 'Chocolade'
      )
    )
  )


--QUERY #11
SELECT * 
FROM Customers c 
WHERE EXISTS (
  SELECT * 
  FROM Orders o 
  JOIN [Order Details] od ON od.OrderID = o.OrderID
  JOIN Products p ON p.ProductID = od.ProductID 
  WHERE p.ProductName = 'ScottISh LONgbreads' AND o.CustomerID = c.CustomerID
  )


--QUERY #12
SELECT * 
FROM Orders o 
WHERE EXISTS (
  SELECT * 
  FROM [Order Details] od 
  JOIN Products p ON p.ProductID = od.ProductID 
  WHERE ProductName = 'ScottISh LONgbreads' AND od.OrderID = o.OrderID
  )
AND NOT EXISTS (
  SELECT * 
  FROM [Order Details] od 
  JOIN Products p ON p.ProductID = od.ProductID 
  WHERE ProductName = 'Chocolade' AND od.OrderID = o.OrderID
  )


--QUERY #13
SELECT e.FirstName, e.LAStName 
FROM Employees e 
WHERE EXISTS (
  SELECT * 
  FROM Orders o
  WHERE o.CustomerID = 'ALFKI' AND e.EmployeeID = o.EmployeeID
)


--QUERY #14
SELECT 
  e.FirstName, 
  e.LAStName, 
  c.CompanyName, 
  o.OrderDate,
  (CASE WHEN od.OrderID IS NULL THEN 0 ELSE 1 END) AS 'Status' 
FROM Employees e
LEFT JOIN Orders o ON o.EmployeeID = e.EmployeeID
LEFT JOIN [Order Details] od ON o.OrderID = od.OrderID AND od.ProductID = (
  SELECT ProductID 
  FROM Products 
  WHERE ProductName = 'Chocolade'
  )
LEFT JOIN Customers c ON c.CustomerID = o.CustomerID


--QUERY #15
SELECT 
  e.FirstName, 
  e.LAStName, 
  c.CompanyName, 
  o.OrderDate,
  (CASE WHEN od.OrderID IS NULL THEN 0 ELSE 1 END) AS status 
FROM Customers c
LEFT JOIN Orders o ON o.CustomerID = c.CustomerID
LEFT JOIN [Order Details] od ON o.OrderID = od.OrderID AND od.ProductID = (
  SELECT ProductID 
  FROM Products 
  WHERE ProductName = 'Chocolade'
  )
LEFT JOIN Employees e ON e.EmployeeID = o.EmployeeID