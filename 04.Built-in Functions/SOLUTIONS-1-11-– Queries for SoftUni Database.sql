USE SoftUni

--1.	Find Names of All Employees by First Name

SELECT [FirstName], [LastName] FROM [Employees]
WHERE [FirstName] LIKE 'Sa%'

--2.	Find Names of All Employees by Last Name 

SELECT [FirstName], [LastName] FROM [Employees]
WHERE [LastName] LIKE '%ei%'

--3.	Find First Names of All Employees

SELECT [FirstName] FROM [Employees]
WHERE [DepartmentID] = 3 OR [DepartmentID] = 10 

--4.	Find All Employees Except Engineers

SELECT [FirstName], [LastName] FROM [Employees]
WHERE [JobTitle] NOT LIKE  '%Engineer%'

--5.	Find Towns with Name Length

SELECT    [Name] FROM [Towns]
WHERE LEN([Name]) IN (5,6)
 ORDER BY [Name]

 --6.	Find Towns Starting With

  SELECT * FROM [Towns]
   WHERE [Name] LIKE 'M%' OR [Name] LIKE 'K%' OR [Name] LIKE 'B%' OR [Name] LIKE 'E%'
ORDER BY [Name]

--7.	Find Towns Not Starting With

SELECT * FROM [Towns]
   WHERE LEFT([Name],1) NOT IN ('R', 'B', 'D') 
ORDER BY [Name]

--8.	Create View Employees Hired After 2000 Year

CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT [FirstName], [LastName] FROM [Employees]
WHERE YEAR([HireDate]) > 2000

SELECT * from V_EmployeesHiredAfter2000

--9.	Length of Last Name

SELECT [FirstName], [LastName] FROM [Employees]
WHERE LEN([LastName]) = 5

--10.	Rank Employees by Salary

SELECT [EmployeeID], [FirstName], [LastName], [Salary],
DENSE_RANK() OVER(PARTITION BY [Salary] ORDER BY [EmployeeID])
AS [Rank]
FROM [Employees]
WHERE [Salary] BETWEEN 10000 AND 50000
ORDER BY [Salary] DESC

--11.	Find All Employees with Rank 2

SELECT * FROM(
SELECT [EmployeeID], [FirstName], [LastName], [Salary],
DENSE_RANK() OVER(PARTITION BY [Salary] ORDER BY [EmployeeID])
AS [Rank]
FROM [Employees]
WHERE [Salary] BETWEEN 10000 AND 50000
)
AS [RankSubquery]
WHERE [Rank] = 2
ORDER BY [Salary] DESC