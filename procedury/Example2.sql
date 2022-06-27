-- Example 2
USE master
GO

if exists(select * from sysdatabases where name='Example2')
	drop database Example2
GO

CREATE DATABASE Example2
GO

USE Example2
GO

/*
	W tym przykladzie PRIMARY KEY oraz relacje pomiedzy tabelami
	sa tworzone w dluzszy sposob.
	CONSTRAINT <nazwa> pozwala nadac nazwę np. dla relacji.
	W przeciwnym przypadku nazwa zostanie wygenerowana automatycznie
*/

CREATE TABLE Plants(
	Plant_id		INT				NOT NULL,
	Description		NVARCHAR(MAX)	NOT NULL,
	Value			MONEY			NOT NULL,
	CONSTRAINT PK_Plants PRIMARY KEY (Plant_id)
)

CREATE TABLE Object_types(
	Type_id			INT				NOT NULL,
	Type_name		INT				NOT NULL,
	CONSTRAINT PK_Object_types PRIMARY KEY (Type_id)
)

CREATE TABLE Departaments(
	Departament_id	INT				NOT NULL,
	CONSTRAINT PK_Departaments PRIMARY KEY (Departament_id)
)

CREATE TABLE Employees(
	Employee_id		INT				NOT NULL,
	Name			VARCHAR(20)		NOT NULL,
	Surname			VARCHAR(50)		NOT NULL,
	CONSTRAINT PK_Employees PRIMARY KEY (Employee_id)
)

CREATE TABLE Power(
	Power_id		INT				NOT NULL,
	Voltage			VARCHAR(50)		NOT NULL,
	CONSTRAINT PK_Power PRIMARY KEY (Power_id)
)

CREATE TABLE Objects(
	Object_id		INT				NOT NULL,
	Name			VARCHAR(50)		NOT NULL,
	Type_id			INT				NOT NULL,
	Departament_id	INT				NOT NULL,
	Power_id		INT				NOT NULL,
	Employee_id		INT				NOT NULL,
	CONSTRAINT PK_Objects PRIMARY KEY (Object_id),
	CONSTRAINT FK_Objects_Type FOREIGN KEY (Type_id) REFERENCES Object_types(Type_id),
	CONSTRAINT FK_Objects_Departament FOREIGN KEY (Departament_id) REFERENCES Departaments(Departament_id),
	CONSTRAINT FK_Objects_Power FOREIGN KEY (Power_id) REFERENCES Power(Power_id),
	CONSTRAINT FK_Objects_Employees FOREIGN KEY (Employee_id) REFERENCES Employees(Employee_id)
)

CREATE TABLE Plant_objects(
	Plant_id		INT				NOT NULL,
	Object_id		INT				NOT NULL,
	CONSTRAINT PK_Plant_objects PRIMARY KEY (Plant_id, Object_id),
	CONSTRAINT FK_Plant_objects_Plants FOREIGN KEY (Plant_id) REFERENCES Plants(Plant_id),
	CONSTRAINT FK_Plant_objects_Objects FOREIGN KEY (Object_id) REFERENCES Objects(Object_id)
)

CREATE TABLE Objects_hierarchy(
	Object_id		INT				NOT NULL,
	Child_object_id	INT				NOT NULL
	CONSTRAINT PK_Objects_hierarchy PRIMARY KEY (Object_id, Child_object_id),
	CONSTRAINT FK_Objects_hierarchy_Objects FOREIGN KEY (Object_id) REFERENCES Objects(Object_id),
	CONSTRAINT FK_Objects_hierarchy_Objects_childs FOREIGN KEY (Child_object_id) REFERENCES Objects(Object_id)
)

CREATE TABLE Dimensions(
	Dim_id			INT				NOT NULL,
	Dim_name		VARCHAR(50)		NOT NULL,
	CONSTRAINT PK_Dimensions PRIMARY KEY (Dim_id)
)

CREATE TABLE Object_dims(
	Object_id		INT				NOT NULL,
	Dim_id			INT				NOT NULL,
	Value			VARCHAR(50)		NOT NULL,
	CONSTRAINT PK_Objects_dims PRIMARY KEY (Object_id, Dim_id),
	CONSTRAINT FK_Object_dims_Object FOREIGN KEY (Object_id) REFERENCES Objects(Object_id),
	CONSTRAINT FK_Object_dims_Dimensions FOREIGN KEY (Dim_id) REFERENCES Dimensions(Dim_id)
)
GO
