USE master
GO

if exists (select * from sysdatabases where name='Example3')
	drop database Example3
GO

CREATE DATABASE Example3
GO

USE Example3
GO

CREATE TABLE Teachers(
	Teacher_id		INT			NOT NULL,
	Name			VARCHAR(20)	NULL,
	Surname			VARCHAR(50)	NULL,
	Is_member		BIT			NOT NULL,
	CONSTRAINT PK_Teachers PRIMARY KEY (Teacher_id)
)

CREATE TABLE Courses(
	Course_id		INT			NOT NULL,
	Teacher_id		INT			NOT NULL REFERENCES Teachers(Teacher_id),
	Description		VARCHAR(MAX) NOT NULL,
	Price			MONEY		NOT NULL,
	CONSTRAINT PK_Courses PRIMARY KEY (Course_id)
)

CREATE TABLE Groups(
	Group_id		INT			NOT NULL,
	CONSTRAINT PK_Groups PRIMARY KEY (Group_id)
)

CREATE TABLE Employees(
	Employee_id		INT			NOT NULL,
	Name			VARCHAR(20)	NULL,
	Surname			VARCHAR(50)	NULL,
	CONSTRAINT PK_Employees	PRIMARY KEY (Employee_id)
)

CREATE TABLE Group_employees(
	Group_id		INT			NOT NULL REFERENCES Groups(Group_id),
	Employee_id		INT			NOT NULL REFERENCES Employees(Employee_id),
	CONSTRAINT PK_Group_employees PRIMARY KEY (Group_id, Employee_id)
)

CREATE TABLE Languages(
	Language_id		INT			NOT NULL,
	Name			VARCHAR(50)	NOT NULL,
	CONSTRAINT PK_Language PRIMARY KEY (Language_id)
)

CREATE TABLE Runs(
	Course_id		INT			NOT NULL REFERENCES Courses(Course_id),
	Group_id		INT			NOT NULL REFERENCES Groups(Group_id),
	Language_id		INT			NOT NULL REFERENCES Languages(Language_id),
	CONSTRAINT PK_Runs PRIMARY KEY (Course_id, Group_id)
)
GO


