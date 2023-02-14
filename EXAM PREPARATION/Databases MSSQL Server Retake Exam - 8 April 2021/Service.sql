CREATE DATABASE Service

USE Service

CREATE TABLE Users(
Id INT PRIMARY KEY IDENTITY,
Username VARCHAR(30) UNIQUE NOT NULL,
[Password] VARCHAR(50) NOT NULL,
[Name] VARCHAR(50),
Birthdate DATETIME,
Age INT CHECK(Age>=14 AND Age<=110),
Email VARCHAR(50) NOT NULL
)

CREATE TABLE Departments(
Id INT PRIMARY KEY IDENTITY,        
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(25),
LastName VARCHAR(25),
Birthdate DATE,
Age INT CHECK(Age>=14 AND Age<=110),
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Categories(
Id INT PRIMARY KEY IDENTITY,        
[Name] VARCHAR(50) NOT NULL,
DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE [Status](
Id INT PRIMARY KEY IDENTITY,        
[Label] VARCHAR(20) NOT NULL
)

CREATE TABLE Reports(
Id INT PRIMARY KEY IDENTITY,  
CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(Id),
StatusId INT NOT NULL FOREIGN KEY REFERENCES [Status](Id),
OpenDate DATE NOT NULL,
CloseDate DATE,
Description VARCHAR(200) NOT NULL,
UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)


--Section 2. DML (10 pts)--------------------------------
--2.	Insert

INSERT INTO Employees
VALUES
('Marlo',	'O''Malley',	'1958-9-21', NULL,	1),
('Niki',	'Stanaghan',	'1969-11-26', NULL,	4),
('Ayrton',	'Senna',	'1960-03-21',	NULL, 9),
('Ronnie',	'Peterson',	'1944-02-14',	NULL, 9),
('Giovanna',	'Amati',	'1959-07-20',	NULL, 5)

INSERT INTO Reports
VALUES
(1,	1,	'2017-04-13',	NULL,	'Stuck Road on Str.133',	6,	2),
(6,	3,	'2015-09-05',	'2015-12-06',	'Charity trail running',	3,	5),
(14,	2,	'2015-09-07',NULL,		'Falling bricks on Str.58',	5,	2),
(4,	3,	'2017-07-03',	'2017-07-06',	'Cut off streetlight on Str.11',	1,	1)


----3.	Update------------------------------------------------------

UPDATE Reports
SET CloseDate = GETDATE()
WHERE CloseDate IS NULL

--4.	Delete-------------------------------------------

DELETE FROM Reports WHERE StatusId = 4


---------------------------------------------------------------------
--Section 3. Querying (40 pts)
--5.	Unassigned Reports

SELECT
	Description,
	FORMAT (OpenDate, 'dd-MM-yyyy')
	FROM Reports
	WHERE EmployeeId IS NULL
	ORDER BY OpenDate, Description


--6.	Reports & Categories----------------------------------

SELECT
	r.Description,
	c.Name AS CategoryName
	FROM Reports AS r
	LEFT JOIN Categories AS c
	ON r.CategoryId=c.Id
	ORDER BY r.Description, c.Name


--7.	Most Reported Category------------------------------------

SELECT TOP(5)
	c.[Name] AS CategoryName,
	COUNT(*) AS ReportsNumber
	FROM Categories AS c
	 JOIN Reports AS r
	ON r.CategoryId=c.Id
	GROUP BY c.Name
	ORDER BY COUNT(*) DESC, c.[Name]
	

--8.	Birthday Report-------------------------------------------

SELECT
	u.Username,
	c.[Name] AS CategoryName
	FROM Reports AS r
	 JOIN Categories AS c
	ON r.CategoryId=c.Id
	JOIN Users AS u
	ON u.Id=r.UserId
	WHERE DAY(u.Birthdate) = DAY(r.OpenDate)
	ORDER BY u.Username, c.[Name]

--9.	Users per Employee ---------------------

SELECT 
		CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
		COUNT(r.UserId) AS UsersCount
	FROM Employees AS e
	LEFT JOIN Reports AS r
	ON e.Id=r.EmployeeId 
	GROUP BY CONCAT(e.FirstName, ' ', e.LastName)
	ORDER BY UsersCount DESC, FullName


--10.	Full Info-----------------------------------------------

SELECT
	       IIF(e.FirstName IS NULL AND e.LastName IS NULL, 'None', CONCAT(e.FirstName, ' ' , e.LastName)) AS Employee,
		ISNULL(d.[Name], 'None') AS Department,
		c.[Name] AS Category,
		r.[Description],
		FORMAT (r.OpenDate, 'dd.MM.yyyy') AS [OpenDate],
		s.[Label] AS [Status],
		u.[Name] AS [User]
		FROM
		Reports AS r
		LEFT JOIN Employees AS e ON r.EmployeeId=e.Id
		LEFT JOIN Departments AS d ON d.Id=e.DepartmentId
		LEFT JOIN Categories AS c ON c.Id=r.CategoryId
		LEFT JOIN [Status] AS s ON s.Id=r.StatusId
		LEFT JOIN Users AS u ON u.Id=r.UserId
  ORDER BY e.FirstName DESC, e.LastName DESC, Department, Category, Description, OpenDate, Status, User



--Section 4. Programmability (20 pts)
--11.	Hours to Complete

GO

CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS
BEGIN
	IF (@StartDate IS NULL) RETURN 0
    IF (@EndDate IS NULL) RETURN 0

	DECLARE @TotalHours INT = DATEDIFF(Hour, @StartDate, @EndDate)

    RETURN @TotalHours
END

GO

SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours 
 FROM Reports


--12.	Assign Employee--------------------------------------------------

GO

CREATE PROCEDURE usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS
BEGIN
	 DECLARE @EmployeeDepartmentID INT = (SELECT DepartmentId FROM Employees WHERE Id = @EmployeeId)
   DECLARE @ReportDepartmentID INT = (SELECT c.DepartmentId FROM Reports AS r JOIN Categories AS c ON r.CategoryId = c.Id WHERE r.Id = @ReportId)

   IF(@EmployeeDepartmentID <> @ReportDepartmentID) 
     THROW 50001, 'Employee doesn''t belong to the appropriate department!', 1
   ELSE 
     UPDATE Reports
	    SET EmployeeId = @EmployeeId
	  WHERE Id = @ReportId
END

GO

