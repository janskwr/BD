USE master
GO

if exists(select * from sysdatabases where name='Example1')
	drop database Example1
GO

CREATE DATABASE Example1
GO

USE Example1
GO

CREATE TABLE Divisions(
	Division_id				INT NOT NULL PRIMARY KEY,
	Division_name			nchar(50) NULL
)

CREATE TABLE Managers(
	Manager_id				INT NOT NULL PRIMARY KEY,
	Division_id				INT NOT NULL REFERENCES Divisions(Division_id)
)

CREATE TABLE Product_groups(
	Product_group_id		INT	NOT NULL PRIMARY KEY,
	Manager_id				INT NOT NULL REFERENCES Managers(Manager_id)
)


CREATE TABLE Countries(
	Country_id				INT NOT NULL PRIMARY KEY,
	Country_name			NVARCHAR(50) NOT NULL
)

-- Inny sposob na tworzenie PRIMARY KEY
CREATE TABLE Parts(
	Part_id					INT NOT NULL,
	Origin_Country_id		INT NOT NULL REFERENCES Countries(Country_id),
	Price					INT NOT NULL,
	Product_start_date		DATE	NOT NULL,
	Product_end_date		DATE NULL,
	Stat_number				INT	NOT NULL,
	Description				NVARCHAR(MAX) NULL,
	PRIMARY KEY (Part_id),							
)

CREATE TABLE Products(
	Product_id				INT	NOT NULL PRIMARY KEY,
	Assembly_Country_id		INT	NOT NULL REFERENCES Countries(Country_id),
	Product_group_id		INT NOT NULL REFERENCES Product_groups(Product_group_id),
	GTN						INT NOT NULL
)

-- Klucze zlozone musimy tworzyc w nastepujacy sposob
CREATE TABLE Prod_parts(
	Product_id				INT NOT NULL REFERENCES Products(Product_id),
	Part_id					INT NOT NULL REFERENCES Parts(Part_id),
	PRIMARY KEY(Product_id, Part_id)
)

GO
