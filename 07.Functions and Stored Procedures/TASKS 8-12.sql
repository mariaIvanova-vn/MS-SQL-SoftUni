USE Bank

--Part II – Queries for Bank Database
------------------------------------------------------------
--9.	Find Full Name

CREATE PROCEDURE usp_GetHoldersFullName
	   AS
	BEGIN
		SELECT 
		CONCAT(FirstName,' ', LastName) AS [Full Name]
		FROM AccountHolders
	  END

------------------------------------------------------------
--10.	People with Balance Higher Than

CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan(@suppliedNumber DECIMAL(18,4))
	AS
	BEGIN
		SELECT 
		ah.FirstName,
		ah.LastName
		FROM AccountHolders AS ah
		JOIN 
		Accounts AS a
		ON ah.Id = a.AccountHolderId
		GROUP BY FirstName, LastName
		HAVING SUM(Balance) > @suppliedNumber
		ORDER BY FirstName, LastName
	END

------------------------------------------------------------
--11.	Future Value Function

CREATE FUNCTION dbo.ufn_CalculateFutureValue(@Sum DECIMAL(15,4), @YearlyRate FLOAT, @Years INT)
RETURNS DECIMAL(15,4)
AS
BEGIN
	DECLARE @FutureReturn DECIMAL(15,4);
	SET @FutureReturn = @Sum * POWER((1+@YearlyRate), @Years);
RETURN @FutureReturn;
END

SELECT dbo.ufn_CalculateFutureValue (1000, 0.1, 5)

------------------------------------------------------------
--12.	Calculating Interest

CREATE PROC dbo.usp_CalculateFutureValueForAccount (@AccountID INT, @InterestRate FLOAT)
AS
	SELECT [a].[Id] AS [Account Id],
		   [ah].[FirstName] AS [First Name],
		   [ah].[LastName] AS [Last Name],
		   [a].[Balance] AS [Current Balance],
		   (SELECT dbo.ufn_CalculateFutureValue ([a].[Balance], @InterestRate, 5)) AS [Balance in 5 years]
		FROM [Accounts] AS [a]
		JOIN [AccountHolders] AS [ah]
		  ON [ah].[Id] = [a].[AccountHolderId]
		WHERE [a].[Id] = @AccountID