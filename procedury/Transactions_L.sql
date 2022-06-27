---------------------- Example #1 ---------------------------------------
SELECT * FROM Orders


---------------------- Example #2 ---------------------------------------
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION 
	UPDATE Customers
	SET orderCount = 2
	WHERE CustomerID='ALFKI';

--------- WAIT ---------

ROLLBACK


---------------------- Example #3 ---------------------------------------
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION 
	UPDATE Customers
	SET orderCount = 2
	WHERE CustomerID='ALFKI';

--------- WAIT ---------

COMMIT


---------------------- Example #4 ---------------------------------------
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION 
	SELECT CustomerID, orderCount 
	FROM Customers
	WHERE CustomerID='ALFKI'

--------- WAIT ---------

	SELECT CustomerID, orderCount 
	FROM Customers
	WHERE CustomerID='ALFKI'
COMMIT


---------------------- Example #5 ---------------------------------------
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRANSACTION 
	SELECT CustomerID, orderCount 
	FROM Customers
	WHERE CustomerID='ALFKI'

--------- WAIT ---------

	SELECT CustomerID, orderCount 
	FROM Customers
	WHERE CustomerID='ALFKI'
COMMIT

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION 
	UPDATE [Order Details]
	SET Quantity = 1
	WHERE OrderID = 10248

	UPDATE [Order Details]
	SET Quantity = 1
	WHERE OrderID = 10249
ROLLBACK


