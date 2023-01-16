CREATE DATABASE CarRental

USE CarRental

--Categories (Id, CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
CREATE TABLE Categories(
Id INT PRIMARY KEY IDENTITY,
CategoryName NVARCHAR(50) NOT NULL,
DailyRate  DECIMAL (15,2) NOT NULL,
WeeklyRate  DECIMAL (15,2) NOT NULL,
MonthlyRate  DECIMAL (15,2) NOT NULL,
WeekendRate  DECIMAL (15,2) NOT NULL
)
--Cars (Id, PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Picture, Condition, Available)
CREATE TABLE Cars(
Id INT PRIMARY KEY IDENTITY,
PlateNumber NVARCHAR(20) NOT NULL, 
Manufacturer NVARCHAR(40) NOT NULL,
Model NVARCHAR(40) NOT NULL,
CarYear SMALLINT NOT NULL,
CategoryId INT NOT NULL,
Doors TINYINT NOT NULL,
Picture VARBINARY(MAX),
Condition NVARCHAR(50) NOT NULL, 
Available BIT NOT NULL
)
--	Employees (Id, FirstName, LastName, Title, Notes)
CREATE TABLE Employees(
Id INT PRIMARY KEY,
FirstName NVARCHAR(40) NOT NULL,
LastName NVARCHAR(40) NOT NULL, 
Title NVARCHAR(50) NOT NULL,
Notes NVARCHAR(MAX)
)
--	Customers (Id, DriverLicenceNumber, FullName, Address, City, ZIPCode, Notes)
CREATE TABLE Customers(
Id INT PRIMARY KEY, 
DriverLicenceNumber NVARCHAR(30) NOT NULL, 
FullName NVARCHAR(80) NOT NULL,
[Address] NVARCHAR(100) NOT NULL,
City NVARCHAR(30) NOT NULL, 
ZIPCode NVARCHAR(10) NOT NULL,
Notes NVARCHAR(MAX)
)
--	RentalOrders (Id, EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd, TotalKilometrage, StartDate, EndDate, TotalDays, RateApplied, TaxRate, OrderStatus, Notes)
CREATE TABLE RentalOrders(
Id INT PRIMARY KEY,
EmployeeId INT NOT NULL,
CustomerId INT NOT NULL,
CarId INT NOT NULL, 
TankLevel  DECIMAL (2,2) NOT NULL, 
KilometrageStart  DECIMAL (15,2) NOT NULL,
KilometrageEnd  DECIMAL (15,2) NOT NULL,
TotalKilometrage  DECIMAL (15,2) NOT NULL,
StartDate DATE NOT NULL,
EndDate DATE NOT NULL, 
TotalDays INT NOT NULL, 
RateApplied  DECIMAL(5,2) NOT NULL, 
TaxRate TINYINT NOT NULL,
OrderStatus NVARCHAR(10) NOT NULL, 
Notes NVARCHAR(MAX)
)


INSERT INTO Categories ( CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
VALUES
( 'FirstCategory', 33.55, 43.60, 12.55, 60.00),
( 'SecondCategory', 30.51, 43.66, 10.55, 60.00),
( 'TirthCategory', 30.05, 40.00, 10.55, 60.00)

INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Condition, Available)
      VALUES
('EH0212BP', 'Opel', 'Astra', 1992, 1, 4, 'new', 1),
('EH02da2BP', 'Oasdel', 'Astasda', 2005, 2, 4, 'new', 1),
('EHasd212BP', 'Opasdl', 'Astasdasa', 2022, 3, 2, 'new', 0)


INSERT INTO Employees(Id,FirstName, LastName, Title)
	VALUES
(1,'Petar', 'Ivanov', 'CEO'),
(2,'Stoyan', 'Georgiev', 'CFO'),
(3,'Ivan', 'Petrov', 'CTO')

INSERT INTO Customers(Id, DriverLicenceNumber, FullName, [Address], City, ZIPCode)
	VALUES
(1,'JIGLAKFJFJHGDHASF', 'Petar Georgiev', 'George Street', 'Sydney', '528000BT'),
(2,'JIdasdFJFJHGDHASF', 'Milen Georgiev', 'Nedelyq', 'Sofia', '5246540BT'),
(3, 'JIGLAKFJFgfdgfDHASF', 'Petar Stoyanov','Bunar Hisar 8' , 'VT', '5280655BT')

INSERT INTO RentalOrders(Id, EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd, TotalKilometrage, StartDate, EndDate, TotalDays, RateApplied, TaxRate, OrderStatus)
	VALUES
(1, 1, 3, 2, 0,  1.10, 1.10, 1.10, '1988-09-27', '1988-10-27', 1, 1.10, 1, 'Complete'),
(2,2,  3, 3, 0, 1.10, 1.10, 1.10, '2022-05-27', '2022-10-15', 1, 1.10, 1, 'Alive'),
(3, 3, 1, 1, 0, 1.10, 1.10, 1.10, '1989-12-27', '1990-11-05', 1, 1.10, 1, 'Complete')