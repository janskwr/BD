USE master
GO

if exists(select * from sysdatabases where name='Example4')
	DROP DATABASE Example4
GO

CREATE DATABASE Example4
GO

USE Example4
GO

CREATE TABLE Employees(
	employee_id		int			NOT NULL PRIMARY KEY,
	name			varchar(20)	NOT NULL,
	surname			varchar(50)	NOT NULL,
)

CREATE TABLE Clients(
	client_id		int			NOT NULL PRIMARY KEY,
	responsible_employee_id		int	NOT NULL FOREIGN KEY REFERENCES Employees(employee_id),
	name			varchar(20) NOT NULL,
	surname			varchar(50) NOT NULL 
)

CREATE TABLE Computers(
	computer_id		int			NOT NULL PRIMARY KEY,
	computer_code	int			NOT NULL,
	owner_id		int			NOT NULL FOREIGN KEY REFERENCES Clients(client_id)
)
CREATE TABLE Parts(
	part_id			int			NOT NULL PRIMARY KEY,
	type			varchar(30)	NOT NULL,
	price			money		NOT NULL,
	description		varchar(MAX)NOT NULL,
)

CREATE TABLE Computers_Parts(
	computer_id		int		NOT NULL FOREIGN KEY REFERENCES Computers(computer_id),
	part_id			int		NOT NULL FOREIGN KEY REFERENCES Parts(part_id),
)

CREATE TABLE Orders(
	order_id		int			NOT NULL PRIMARY KEY,
	client_id		int			NOT NULL FOREIGN KEY REFERENCES Clients(client_id),
	date			date		NOT NULL,
	priority		int			NOT NULL,
	price			money		NOT NULL,
)

CREATE TABLE Computers_problems(
	id				int			NOT NULL PRIMARY KEY,
	order_id		int			NOT NULL FOREIGN KEY REFERENCES Orders(order_id),
	computer_id		int			NOT NULL FOREIGN KEY REFERENCES Computers(computer_id),
)

CREATE TABLE Problem_categories(
	category_id		int			NOT NULL PRIMARY KEY,
	problem			varchar(MAX)NOT NULL
)

CREATE TABLE Computers_problems_Problem_categories(
	computer_problem_id		int NOT NULL FOREIGN KEY REFERENCES Computers_problems(id),
	category_id				int NOT NULL FOREIGN KEY REFERENCES Problem_categories(category_id)
)

