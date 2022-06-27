begin transaction

update Orders
set CustomerID='ALFKI'
where OrderID=10407


ROLLBACK

ALTER TABLE Customers ADD orderCount INT NOT NULL DEFAULT(0)

UPDATE Customers
SET orderCount = (SELECT COUNT(*) FROM Orders O where Customers.CustomerID = O.CustomerID)

SELECT * FROM Customers