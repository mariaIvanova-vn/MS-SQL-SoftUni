USE SoftUni

--Part I – Queries for SoftUni Database
----------------------------------------------------------------------
--1.	Employees with Salary Above 35000

CREATE PROCEDURE [usp_GetEmployeesSalaryAbove35000]
			  AS
		   BEGIN
				SELECT
					[FirstName],
					[LastName]
				  FROM
					[Employees]
				WHERE [Salary] > 35000
		     END

EXEC [dbo].[usp_GetEmployeesSalaryAbove35000]

----------------------------------------------------------------------
--2.	Employees with Salary Above Number

CREATE PROCEDURE [usp_GetEmployeesSalaryAboveNumber] @minSalari DECIMAL(18,4)
			  AS
		   BEGIN
				SELECT
					[FirstName],
					[LastName]
				  FROM
					[Employees]
				WHERE [Salary] >= @minSalari
			 END

EXEC [dbo].[usp_GetEmployeesSalaryAboveNumber] 78100

----------------------------------------------------------------------
--3.	Town Names Starting With

CREATE PROCEDURE [usp_GetTownsStartingWith] @string NVARCHAR(50)
			AS
			BEGIN
			     SELECT [Name]
				 FROM Towns
				 WHERE LEFT([Name], LEN(@string)) = @string
			END

EXEC [dbo].[usp_GetTownsStartingWith] 'D'

----------------------------------------------------------------------
--4.	Employees from Town

CREATE PROCEDURE [usp_GetEmployeesFromTown] @town VARCHAR(50)
			AS
			BEGIN
				SELECT e.FirstName, e.LastName
				FROM Employees AS e
				JOIN Addresses AS a
				ON e.AddressID=a.AddressID
				JOIN Towns AS t
				ON a.TownID=t.TownID
				WHERE t.Name = @town
			END

EXEC dbo.usp_GetEmployeesFromTown 'Sofia'

---------------------------------------------------------------
--5.	Salary Level Function

CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(8)
	AS
	BEGIN
		DECLARE @salaryLevel VARCHAR(8)

		IF @salary < 30000
		BEGIN
			SET @salaryLevel = 'Low'
		END
		ELSE IF @salary BETWEEN 30000 AND 50000
		BEGIN
			SET @salaryLevel = 'Average'
		END
		ELSE IF @salary > 50000
		BEGIN
			SET @salaryLevel = 'High'
		END
		RETURN @salaryLevel
	END

---------------------------------------------------------------
--6.	Employees by Salary Level

CREATE PROCEDURE usp_EmployeesBySalaryLevel @salaryLevel VARCHAR(8)
AS
	BEGIN
		SELECT FirstName, LastName
		FROM Employees
		WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
	END

EXEC dbo.usp_EmployeesBySalaryLevel 'High'

---------------------------------------------------------------
--7.	Define Function

GO
CREATE FUNCTION dbo.ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @count INT = 1;
	WHILE @count <= LEN(@word)
	BEGIN
		IF (CHARINDEX(SUBSTRING(@word, @count, 1), @setOfLetters)) = 0
			RETURN 0;
		SET @count += 1;
	END
	RETURN 1;
END
GO

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia')