-- Example procedures 

-- 1. Prelimiary setup

IF OBJECT_ID('dbo.myStats') IS NOT NULL
  DROP TABLE dbo.myStats;
GO

create table myStats  (
	prod1 int,
	prod2 int,
	cnt int ) ;

-- 2. Creating stored procedure
IF OBJECT_ID('dbo.myProc') IS NOT NULL
  DROP PROC dbo.myProc;
GO

CREATE PROCEDURE myProc
--ALTER PROCEDURE myProc
	@param1 int,
	@param2 int,
	@prodCnt int OUTPUT 
AS
BEGIN

	DECLARE @msg AS NVARCHAR(500);
	DECLARE @tmpVal float;

	-- Parameter validation
	IF @param1 > 1000
	BEGIN
	  SET @msg = N'Prod ID must be < 1000';
	  RAISERROR(@msg,16,1);
	  RETURN;
	END
	--  variables declaration
	
	SET @tmpVal = (SELECT COUNT(*) FROM Northwind.dbo.Products 
					WHERE ProductID BETWEEN @param1 and @param2);
	
	SELECT @prodCnt = COUNT(*) FROM Northwind.dbo.[Order Details] WHERE ProductID BETWEEN @param1 and @param2;
	
	-- main SQL code
	INSERT INTO myStats values (@param1, @param2, @tmpVal) ;

END

-- 3. Calling stored procedures  

-- simple call with unnamed parameters
	execute myProc 10, 20;
	select * from myStats

-- call with named parameters
	execute myProc @param1 = 34, @param2 = 50;
	select * from myStats

-- call that raises an error 
	execute myProc 2000 , 20
	select * from myStats

-- passing OUTPUT from a procedure
	declare @prodSales int;
	execute myProc @param1= 10, @param2= 20, @prodCnt = @prodSales OUTPUT;
	print 'Total Number of orders is: ' + CONVERT(varchar(10), @prodSales);
	GO

-- SCENARIO #1 ---------------------------------------------------------------------------------------

-- STEP 1 (prepare archive tables)
USE Northwind
GO

	if OBJECT_ID('ArchiveOrders') IS NOT NULL  drop table ArchiveOrders ;
	select * into ArchiveOrders from Orders where 0=1;

	Alter table ArchiveOrders
	add ArchiveDate datetime,
		CONSTRAINT  [PKC_OrderID] Primary Key ( OrderID ),
		CONSTRAINT [FKC_Customers] Foreign Key ( CustomerID ) References Customers(CustomerID),
		CONSTRAINT [FKC_emps] Foreign Key ( EmployeeID ) References Employees(EmployeeID);

	set Identity_insert dbo.ArchiveOrders ON;

	if OBJECT_ID('ArchiveOrderDetails') IS NOT NULL drop table [ArchiveOrderDetails];    
	select * into [ArchiveOrderDetails] from [Order Details] where 1=0;

	Alter Table ArchiveOrderDetails
	add ArchiveDate datetime,
		CONSTRAINT [PKC_aod] Primary Key Clustered (OrderID ASC, ProductID ASC);
GO
-- STEP 2   

IF OBJECT_ID('arch') IS NOT NULL 
	DROP PROC arch;
GO
CREATE PROCEDURE arch 
	@years int
AS
BEGIN
	set Identity_insert dbo.ArchiveOrders ON;
 
	DECLARE @archiveDate  datetime;
	DECLARE @currentDate  datetime;
	DECLARE @archivedOrderIDs TABLE(OrderID int);

	SET @currentDate = getdate();
	SET @archiveDate = dateadd(yyyy, -@years,@currentDate);
	
	IF (SELECT COUNT(*) FROM Orders WHERE OrderDate <= @archiveDate) = 0 
	BEGIN
		print 'There are no records to archive... ';
		RETURN;
	END;

	print 'Archiving records older than ' + CONVERT(varchar(4),@years) + ' years' ;

	set transaction isolation level serializable ;
	
	begin transaction
	begin try 
		
		INSERT INTO ArchiveOrders([OrderID], [CustomerID], [EmployeeID], [OrderDate], [RequiredDate], [ShippedDate], [ShipVia], [Freight], [ShipName], [ShipAddress], [ShipCity], [ShipRegion], [ShipPostalCode], [ShipCountry], [ArchiveDate])
		OUTPUT INSERTED.OrderID INTO @archivedOrderIDs
		SELECT * , @currentDate FROM Orders WHERE OrderDate <= @archiveDate;

		INSERT INTO ArchiveOrderDetails
		SELECT OD.*, @currentDate
		FROM [Order Details] OD JOIN @archivedOrderIDs AO ON OD.OrderID = AO.OrderID ;
		
		DELETE FROM [Order Details]
		FROM [Order Details] OD JOIN @archivedOrderIDs AO ON OD.OrderID = AO.OrderID;
		
		DELETE FROM [Orders]
		FROM [Orders] O JOIN @archivedOrderIDs AO ON O.OrderID = AO.OrderID;
	commit transaction
	END TRY

	BEGIN CATCH
		ROLLBACK transaction 

	END CATCH
END

-- execute procedure
EXECUTE  arch 25;

-- check solution
select datediff(yy,OrderDate,getdate()) years , count(*) 
from Orders group by datediff(yy,OrderDate,getdate());



-- setup Scheduled job to archive orders older than 25

-- pick one customer 
select * from Orders where CustomerID = 'PICCO'
-- set the OrderDate to some old date 
update orders 
	set OrderDate = '1950/01/01'
		where  CustomerID = 'PICCO';

-- run the archivization job (Go to SQL Server Agent => Jobs => start job at step... )

-- check if the old records for selected customer have been migrated to the archive 
select * from Orders where CustomerID = 'PICCO';
select * from ArchiveOrders where CustomerID = 'PICCO';

-- SCENARIO #2 ---------------------------------------------------------------------------------------

--1. Info on Cursors
	declare @p int; 

	declare  test cursor local for SELECT DISTINCT ProductID from ArchiveOrderDetails ;
	open test
	fetch next from test into @p

	while @@FETCH_STATUS=0
	BEGIN
		print @p
		fetch next from test into @p
	END
	close test
	deallocate test
go

--2. Procedure
CREATE PROCEDURE calculate_discount
	@CustomerID nchar(5)
AS
BEGIN
	print 'Calculating discount for customer ' + @CustomerID

	DECLARE @c_product int, @c_order int, @counter int, @discount float;

	DECLARE products_crs cursor local for
		SELECT DISTINCT OD.ProductID 
		FROM Orders O
		JOIN [Order Details] OD on O.OrderID = OD.OrderID
		WHERE O.CustomerID = @CustomerID
	;
	OPEN products_crs
	fetch next from products_crs into @c_product

	WHILE @@FETCH_STATUS=0
	BEGIN
		print 'Product ' + CONVERT(varchar(4),@c_product)

		DECLARE order_crs cursor local for
			SELECT OD.OrderID
			FROM Orders O
			JOIN [Order Details] OD on O.OrderID = OD.OrderID
			WHERE O.CustomerID = @CustomerID AND OD.ProductID = @c_product
			ORDER BY O.OrderDate ASC
		;
		OPEN order_crs
		fetch next from order_crs into @c_order
		SET @counter = 1;
		WHILE @@FETCH_STATUS=0
		BEGIN
			IF @counter = 1 SET @discount = 0
			IF @counter = 2 OR @counter = 3 SET @discount = 0.05
			IF @counter = 4 SET @discount = 0.1
			IF @counter >= 5 SET @discount = 0.2

			print '      Order ' + CONVERT(varchar(8),@c_order) + ' discount ' + CONVERT(varchar(8),@discount)

			UPDATE [Order Details]
			SET Discount = @discount
			WHERE ProductID = @c_product AND OrderID = @c_order

			SET @counter = @counter + 1
			fetch next from order_crs into @c_order
		END

		close order_crs
		deallocate order_crs
		fetch next from products_crs into @c_product
	END
	close products_crs
	deallocate products_crs
END


--DROP PROCEDURE calculate_discount;

EXECUTE calculate_discount 'ALFKI';

SELECT CustomerID, COUNT(*) FROM Orders GROUP BY CustomerID ORDER BY COUNT(*) DESC

EXECUTE calculate_discount 'SAVEA';
