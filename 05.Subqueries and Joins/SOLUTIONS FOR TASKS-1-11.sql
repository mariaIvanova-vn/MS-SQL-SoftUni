USE SoftUni
-------------------------------------------------------
--1.	Employee Address

SELECT 
 TOP(5) [e].[EmployeeID],
		[e].[JobTitle],[e].
		[AddressID], 
		[a].[AddressText]
     FROM Employees AS [e]
LEFT JOIN [Addresses] AS [a]
       ON [e].[AddressID] = [a].[AddressID]
 ORDER BY [e].[AddressID]
 --------------------------------------------------------
 --2.	Addresses with Towns

 SELECT TOP(50) 
		[e].[FirstName], 
		[e].[LastName], 
		[t].[Name],
		[a].[AddressText]
      FROM Employees AS [e]
 LEFT JOIN [Addresses] AS [a]
	    ON [e].[AddressID] = [a].[AddressID]
      JOIN [Towns] AS [t]
        ON [a].[TownID] = [t].[TownID]
  ORDER BY [e].[FirstName], [e].[LastName]

 --------------------------------------------------------
  --3.	Sales Employee

 SELECT 
		e.EmployeeID,
		e.FirstName,
		e.LastName,
		d.[Name] AS [DepartmentName]
   FROM Employees AS e
   JOIN Departments AS d
     ON e.DepartmentID = d.DepartmentID
  WHERE d.Name = 'Sales'
 ORDER BY e.EmployeeID

 -------------------------------------------------------
 --4.	Employee Departments

 SELECT TOP(5)
        e.EmployeeID,
		e.FirstName,
		e.Salary,
		d.[Name] AS [DepartmentName]
 FROM Employees AS e
 JOIN Departments AS d
 ON e.DepartmentID = d.DepartmentID
 WHERE e.Salary > 15000
 ORDER BY e.DepartmentID

 -------------------------------------------------------
 --5.	Employees Without Project

 SELECT TOP(3)
		e.EmployeeID,
		e.FirstName
   FROM Employees AS e
   LEFT JOIN EmployeesProjects AS ep
     ON e.EmployeeID = ep.EmployeeID
  WHERE ep.EmployeeID IS NULL
ORDER BY e.EmployeeID

-------------------------------------------------------
 --6.	Employees Hired After

 SELECT 
		 e.FirstName,
		 e.LastName,
		 e.HireDate,
		 d.[Name] AS DeptName
    FROM Employees AS e
    JOIN Departments AS d
      ON e.DepartmentID = d.DepartmentID
   WHERE d.Name IN ('Sales', 'Finance')
     AND e.HireDate > '1.1.1999'
ORDER BY e.HireDate

-------------------------------------------------------
 --7.	Employees with Project

 SELECT TOP(5)
		 e.EmployeeID,
  		 e.FirstName,
 		 p.[Name] AS [ProjectName]
    FROM Employees AS e
    JOIN EmployeesProjects AS ep
      ON e.EmployeeID=ep.EmployeeID
    JOIN Projects AS p
      ON ep.ProjectID=p.ProjectID
   WHERE p.EndDate IS NULL
ORDER BY e.EmployeeID ASC

-------------------------------------------------------
 --8.	Employee 24

 SELECT 
		 e.EmployeeID,
  		 e.FirstName,
 		 CASE	
			WHEN DATEPART(YEAR, [p].[StartDate]) > '2004' THEN NULL
			ELSE [p].[Name]
		END AS [ProjectName]
    FROM Employees AS e
    JOIN EmployeesProjects AS ep
      ON e.EmployeeID=ep.EmployeeID
    JOIN Projects AS p
      ON ep.ProjectID=p.ProjectID
   WHERE e.EmployeeID = 24

-------------------------------------------------------
 --9.	Employee Manager

 SELECT 
 e.EmployeeID,
 e.FirstName,
 e.ManagerID,
 m.FirstName
 FROM Employees AS e
 JOIN Employees AS m
 ON e.ManagerID=m.EmployeeID
 WHERE e.ManagerID IN (3,7)
 ORDER BY e.EmployeeID ASC
   
-----------------------------------------------------------
--10.	Employees Summary

SELECT TOP(50)
		 e.EmployeeID,
		 e.FirstName+' ' +e.LastName AS EmployeeName,
		 m.FirstName+' ' +m.LastName AS ManagerName,
		 d.[Name] AS DepartmentName 
    FROM Employees AS e
    JOIN Employees AS m
      ON e.ManagerID=m.EmployeeID
    JOIN Departments AS d
      ON e.DepartmentID=d.DepartmentID
ORDER BY e.EmployeeID ASC

-------------------------------------------------------------
--11.	Min Average Salary

SELECT MIN([Avg]) AS [MinAverageSalary]
	FROM(
	SELECT AVG([Salary]) AS [Avg]
		  FROM [Employees]
	  GROUP BY [DepartmentID]
	) AS [AverageSalaries]