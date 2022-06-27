---------------------- Example #1 ---------------------------------------
begin transaction

update Orders
set CustomerID='ALFKI'
where OrderID=10407

--------- WAIT ---------

ROLLBACK


---------------------- Example #2 ---------------------------------------
ALTER TABLE Customers ADD orderCount INT NOT NULL DEFAULT(0)

UPDATE Customers
SET orderCount = (SELECT COUNT(*) FROM Orders O where Customers.CustomerID = O.CustomerID)

SELECT * FROM Customers

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRANSACTION
	SELECT * FROM Customers
	WHERE CustomerID='ALFKI'
COMMIT


---------------------- Example #3 ---------------------------------------
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION
	SELECT * FROM Customers
	WHERE CustomerID='ALFKI'
COMMIT

---------------------- Example #4 ---------------------------------------
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION 
	UPDATE Customers
	SET orderCount = 4
	WHERE CustomerID='ALFKI';
COMMIT

---------------------- Example #5 ---------------------------------------
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION 
	UPDATE Customers
	SET orderCount = 6
	WHERE CustomerID='ALFKI';
COMMIT


SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION 
	UPDATE [Order Details]
	SET Quantity = 1
	WHERE OrderID = 10249

	UPDATE [Order Details]
	SET Quantity = 1
	WHERE OrderID = 10248
ROLLBACK