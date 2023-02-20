CREATE DATABASE Boardgames 

USE Boardgames 


 CREATE TABLE Categories(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

 CREATE TABLE Addresses(
Id INT PRIMARY KEY IDENTITY,
StreetName NVARCHAR(100) NOT NULL,
StreetNumber INT NOT NULL,
Town	VARCHAR(30),
Country	VARCHAR(50),
ZIP INT NOT NULL
)

 CREATE TABLE Publishers(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL UNIQUE,
AddressId	INT NOT NULL FOREIGN KEY REFERENCES Addresses(Id), 
Website	NVARCHAR(40),
Phone	NVARCHAR(20)
)

 CREATE TABLE PlayersRanges(
Id INT PRIMARY KEY IDENTITY,
PlayersMin	INT NOT NULL,
PlayersMax	INT NOT NULL
)

 CREATE TABLE Boardgames(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL ,
YearPublished	INT NOT NULL,
Rating	DECIMAL(2,1) NOT NULL,
CategoryId	INT NOT NULL FOREIGN KEY REFERENCES Categories(Id), 
PublisherId	INT NOT NULL FOREIGN KEY REFERENCES Publishers(Id),
PlayersRangeId	INT NOT NULL FOREIGN KEY REFERENCES PlayersRanges(Id)
)

 CREATE TABLE Creators(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL ,
LastName NVARCHAR(30) NOT NULL ,
Email NVARCHAR(30) NOT NULL 
)

CREATE TABLE CreatorsBoardgames(
CreatorId INT NOT NULL FOREIGN KEY REFERENCES Creators(Id),   
BoardgameId INT NOT NULL FOREIGN KEY REFERENCES Boardgames(Id),
PRIMARY KEY(CreatorId, BoardgameId)
)


--Section 2. DML (10 pts)--------------------------------
--2.	Insert

INSERT INTO Boardgames 
VALUES
('Deep Blue',	2019,	5.67,	1,	15,	7),
('Paris',	2016,	9.78,	7,	1,	5),
('Catan: Starfarers',	2021,	9.87,	7,	13,	6),
('Bleeding Kansas',	2020,	3.25,	3,	7,	4),
('One Small Step',	2019,	5.75,	5,	9,	2)

INSERT INTO Publishers 
VALUES
('Agman Games',	5,	'www.agmangames.com',	'+16546135542'),
('Amethyst Games',	7,	'www.amethystgames.com',	'+15558889992'),
('BattleBooks',	13,	'www.battlebooks.com',	'+12345678907')


--3.	Update--------

UPDATE  Boardgames 
  SET  Name = CONCAT(Name, 'V2')
  WHERE YearPublished>=2020

 --SELECT * FROM PlayersRanges-- WHERE PlayersMax = 2

 UPDATE PlayersRanges
 SET PlayersMax+=1
 WHERE PlayersMax = 2

 --4.	Delete------


  DELETE FROM CreatorsBoardgames
 WHERE BoardgameId IN(SELECT BoardgameId FROM Boardgames WHERE PublisherId IN (SELECT Id FROM Publishers WHERE AddressId IN (SELECT Id FROM Addresses WHERE Country = 'USA')))

 DELETE FROM Boardgames
 WHERE PublisherId IN (SELECT Id FROM Publishers WHERE AddressId IN (SELECT Id FROM Addresses WHERE Country = 'USA'))

  DELETE FROM Publishers
 WHERE AddressId IN (SELECT Id FROM Addresses WHERE Country = 'USA')

  DELETE FROM Addresses
WHERE  Country = 'USA'




-------------------------------------------------------
--Section 3. Querying (40 pts)

--5.	Boardgames by Year of Publication

SELECT
	Name,Rating
	FROM Boardgames
	ORDER BY YearPublished, Name DESC


--6.	Boardgames by Category---------------

SELECT
	b.Id, b.Name, b.YearPublished,c.Name 
	FROM Boardgames AS b
	JOIN Categories AS c
	ON b.CategoryId=c.Id
	WHERE c.Name='Strategy Games' OR c.Name='Wargames'
ORDER BY b.YearPublished DESC


--7.	Creators without Boardgames---------------------

SELECT
	c.Id, CONCAT(c.FirstName, ' ', c.LastName), c.Email
	FROM Creators AS c
	LEFT JOIN CreatorsBoardgames AS cb
	ON c.Id= cb.CreatorId
	LEFT JOIN Boardgames AS b
	ON b.Id=cb.BoardgameId
	WHERE b.Id IS NULL


--8.	First 5 Boardgames---------------------------

SELECT TOP(5)
	b.Name,b.Rating,c.Name
	FROM Boardgames AS b
	JOIN Categories AS c
	ON c.Id=b.CategoryId
	WHERE (b.Rating>7.0 AND b.Name LIKE '%a%')
	OR b.Rating>7.5
	ORDER BY b.Name,b.Rating DESC


--9.	Creators with Emails---------------------

SELECT
	CONCAT(c.FirstName, ' ', c.LastName), c.Email,
	MAX(b.Rating)
	FROM Creators AS c
	 JOIN CreatorsBoardgames AS cb
	ON c.Id= cb.CreatorId
	 JOIN Boardgames AS b
	ON b.Id=cb.BoardgameId
	WHERE c.Email LIKE '%.com'
	GROUP BY CONCAT(c.FirstName, ' ', c.LastName), c.Email
	ORDER BY CONCAT(c.FirstName, ' ', c.LastName)


--10.	Creators by Rating--------------------------

SELECT
	c.LastName, CEILING(AVG(b.Rating)), p.Name
	FROM Creators AS c
	 JOIN CreatorsBoardgames AS cb
	ON c.Id= cb.CreatorId
	 JOIN Boardgames AS b
	ON b.Id=cb.BoardgameId
	JOIN Publishers AS p
	ON p.Id=b.PublisherId
	WHERE p.Name='Stonemaier Games'
	GROUP BY c.LastName, p.Name
	ORDER BY AVG(b.Rating) DESC


----Section 4. Programmability (20 pts)
--11.	Creator with Boardgames

GO

CREATE FUNCTION udf_CreatorWithBoardgames(@name NVARCHAR(30)) 
RETURNS INT
AS
BEGIN
	DECLARE @counts INT = 
			(
				SELECT
				COUNT(*)
				FROM Creators AS c
				 JOIN CreatorsBoardgames AS cb
				ON c.Id= cb.CreatorId
				 JOIN Boardgames AS b
				ON b.Id=cb.BoardgameId
				JOIN Publishers AS p
				ON p.Id=b.PublisherId
				WHERE c.FirstName = @name
			)
	RETURN @counts
END

GO


SELECT dbo.udf_CreatorWithBoardgames('Bruno')


--12.	Search for Boardgame with Specific Category---------------

GO

CREATE PROCEDURE usp_SearchByCategory(@category VARCHAR(50))
AS
BEGIN
	SELECT
	b.Name, b.YearPublished, b.Rating, c.Name, p.Name,
	CONCAT(plr.PlayersMin, ' ', 'people'),
	CONCAT(plr.PlayersMax, ' ', 'people')
	FROM Boardgames AS b
	LEFT JOIN Categories AS c
	ON c.Id=b.CategoryId
	LEFT JOIN Publishers AS p
	ON p.Id=b.PublisherId
	JOIN PlayersRanges AS plr
	ON plr.Id=b.PlayersRangeId
	WHERE c.Name = @category
	ORDER BY p.Name,b.YearPublished DESC
END

GO

EXEC usp_SearchByCategory 'Wargames'

