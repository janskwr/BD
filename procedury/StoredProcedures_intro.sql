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
	execute myProc @param2 = 20, @param1 = 10;
	select * from myStats

-- call that raises an error 
	execute myProc 2000 , 20
	select * from myStats

-- passing OUTPUT from a procedure
	declare @prodSales int;
	execute myProc @param1= 10, @param2= 20, @prodCnt = @prodSales OUTPUT;
	print 'Total Number of orders is: ' + CONVERT(varchar(10), @prodSales);
	GO