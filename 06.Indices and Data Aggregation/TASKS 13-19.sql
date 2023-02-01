USE SoftUni

--Part II – Queries for SoftUni Database
---------------------------------------------------------------
--13. Departments Total Salaries

SELECT 
		 DepartmentID, 
  	     SUM(Salary)
	FROM Employees
GROUP BY DepartmentID

---------------------------------------------------------------
--14. Employees Minimum Salaries

SELECT 
		 DepartmentID, 
  	     MIN(Salary)
	FROM Employees
	WHERE DepartmentID IN (2,5,7)
GROUP BY DepartmentID

---------------------------------------------------------------
--15. Employees Average Salaries

SELECT * INTO [AverageSalaries]
	FROM [Employees]
   WHERE [Salary] > 30000

DELETE FROM [AverageSalaries]
	WHERE [ManagerID] = 42

UPDATE [AverageSalaries]
	SET [Salary] += 5000
	WHERE [DepartmentID] = 1

SELECT [DepartmentID], AVG([Salary]) AS [AverageSalary]
	FROM [AverageSalaries]
	GROUP BY [DepartmentID]

---------------------------------------------------------------
--16. Employees Maximum Salaries

SELECT 
		 DepartmentID, 
  	     MAX(Salary)
	FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

---------------------------------------------------------------
--17. Employees Count Salaries

SELECT 
  	     COUNT(*) AS [Count]
	FROM Employees
	WHERE ManagerID IS NULL

---------------------------------------------------------------
--18. *3rd Highest Salary

SELECT [DepartmentID], [Salary] AS [ThirdHighestSalary]
	FROM(
		SELECT [DepartmentID], [Salary],
		DENSE_RANK() OVER (PARTITION BY [DepartmentID] ORDER BY [Salary] DESC) AS [Rank]
		FROM [Employees]
		GROUP BY DepartmentID, Salary) AS t
	WHERE [Rank] = 3

---------------------------------------------------------------
--19. **Salary Challenge

SELECT TOP(10) [FirstName], [LastName], [DepartmentID]
	FROM [Employees] AS [emp]
	WHERE [Salary] > (SELECT AVG([Salary])
						FROM [Employees]
					   WHERE [DepartmentID] = [emp].[DepartmentID]
					GROUP BY ([DepartmentID]))
	ORDER BY [DepartmentID]