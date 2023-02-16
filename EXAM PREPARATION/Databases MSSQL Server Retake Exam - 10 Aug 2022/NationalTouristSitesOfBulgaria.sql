CREATE DATABASE NationalTouristSitesOfBulgaria

USE NationalTouristSitesOfBulgaria


--Section 1. DDL (30 pts)

CREATE TABLE Categories(
Id INT PRIMARY KEY IDENTITY,        --PK, Unique table identification, Identity
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Locations(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
Municipality VARCHAR(50),
Province VARCHAR(50)
)

CREATE TABLE Sites(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(100) NOT NULL,
LocationId INT NOT NULL FOREIGN KEY REFERENCES Locations(Id),
CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(Id),
Establishment VARCHAR(15)
)

CREATE TABLE Tourists(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
Age INT NOT NULL CHECK(Age>=0 AND Age<=120),
PhoneNumber VARCHAR(20) NOT NULL,
Nationality VARCHAR(30) NOT NULL,
Reward VARCHAR(20)
)

CREATE TABLE SitesTourists(
TouristId INT NOT NULL FOREIGN KEY REFERENCES Tourists(Id),   --PK, Unique table identification, Relationship with table TouristsNull is not allowed
SiteId INT NOT NULL FOREIGN KEY REFERENCES Sites(Id),
PRIMARY KEY(TouristId, SiteId)
)

CREATE TABLE BonusPrizes(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE TouristsBonusPrizes(
TouristId INT NOT NULL FOREIGN KEY REFERENCES Tourists(Id),
BonusPrizeId INT NOT NULL FOREIGN KEY REFERENCES BonusPrizes(Id),
PRIMARY KEY(TouristId, BonusPrizeId)
)



--Section 2. DML (10 pts)--------------------------------
--2.	Insert

INSERT INTO Tourists([Name],	Age,	PhoneNumber,	Nationality,	Reward)
VALUES
('Borislava Kazakova',	52,	'+359896354244',	'Bulgaria',	NULL),
('Peter Bosh',	48,	'+447911844141',	'UK',	NULL),
('Martin Smith',	29,	'+353863818592',	'Ireland',	'Bronze badge'),
('Svilen Dobrev',	49,	'+359986584786',	'Bulgaria',	'Silver badge'),
('Kremena Popova',	38,	'+359893298604',	'Bulgaria',	NULL)


INSERT INTO Sites([Name],	LocationId,	CategoryId,	Establishment)
VALUES
('Ustra fortress',	90,	7,	'X'),
('Karlanovo Pyramids',	65,	7,	NULL),
('The Tomb of Tsar Sevt',	63,	8,	'V BC'),
('Sinite Kamani Natural Park',	17,	1,	NULL),
('St. Petka of Bulgaria – Rupite',	92,	6,	'1994')


--3.	Update--------

UPDATE Sites
SET Establishment = '(not defined)'
WHERE Establishment IS NULL


 --4.	Delete------

 SELECT Id
FROM BonusPrizes
WHERE [Name] = 'Sleeping bag'

DELETE FROM TouristsBonusPrizes
WHERE BonusPrizeId = 5

DELETE FROM BonusPrizes
WHERE Id = 5




-------------------------------------------------------
--Section 3. Querying (40 pts)

--5.	Tourists

SELECT
	[Name],
	Age,
	PhoneNumber,
	Nationality
	FROM Tourists
ORDER BY Nationality, Age DESC, [Name]


--6.	Sites with Their Location and Category--------------

SELECT
	s.[Name] AS [Site],
	l.[Name] AS [Location],
	s.Establishment,
	c.[Name] AS Category
	FROM Sites AS s
	JOIN Locations AS l
	ON l.Id=s.LocationId
	JOIN Categories AS c
	ON c.Id=s.CategoryId
ORDER BY c.[Name] DESC, l.[Name], s.[Name]


--7.	Count of Sites in Sofia Province------------

SELECT 
		l.Province,
		l.Municipality,
		l.[Name] AS [Location],
   COUNT(s.LocationId) AS CountOfSites
	FROM Locations AS l
	JOIN Sites AS s
	  ON l.Id=s.LocationId
   WHERE Province = 'Sofia' 
GROUP BY s.LocationId, l.[Name], l.Province, l.Municipality
ORDER BY COUNT(s.LocationId) DESC, l.[Name]

--8.	Tourist Sites established BC--------------------------------------

SELECT 
	s.[Name] AS [Site],
	l.[Name] AS [Location],
	l.Municipality,
	l.Province,
	s.Establishment
	FROM Sites AS s
	JOIN Locations AS l
	ON s.LocationId=l.Id
  WHERE l.[Name] NOT LIKE 'B%' AND l.[Name] NOT LIKE 'M%' AND l.[Name] NOT LIKE 'D%'
		AND s.Establishment LIKE '%BC%'
  ORDER BY s.[Name]

--9.	Tourists with their Bonus Prizes------------------------

SELECT 
	t.[Name],
	t.Age,
	t.PhoneNumber,
	t.Nationality,
	ISNULL(bp.[Name], '(no bonus prize)') AS Reward
	FROM Tourists AS t
	LEFT JOIN TouristsBonusPrizes AS tbp
	ON t.Id=tbp.TouristId
	LEFT JOIN BonusPrizes AS bp
	ON tbp.BonusPrizeId=bp.Id
ORDER BY t.[Name]


--10.	Tourists visiting History and Archaeology sites----------------

SELECT DISTINCT
	SUBSTRING(t.Name, (SELECT CHARINDEX(' ',t.Name)), LEN(t.Name)) AS LastName,
	t.Nationality,
	t.Age,
	t.PhoneNumber
	FROM Tourists AS t
	JOIN SitesTourists AS st
	ON t.Id=st.TouristId
	JOIN Sites AS s
	ON st.SiteId=s.Id
	JOIN Categories AS c
	ON c.Id=S.CategoryId
WHERE c.[Name] = 'History and archaeology'
ORDER BY LastName


--Section 4. Programmability (20 pts)
--11.	Tourists Count on a Tourist Site-------------------------------
GO

CREATE FUNCTION udf_GetTouristsCountOnATouristSite (@Site VARCHAR(100))
RETURNS INT
AS
BEGIN
	DECLARE @counts INT = 
			(
			SELECT COUNT(*) FROM Sites AS s
			JOIN SitesTourists AS st
			ON st.SiteId=s.Id
			WHERE Name = @Site
			)
	RETURN @counts
END

GO




--12.	Annual Reward Lottery-----------------------------------------
GO

CREATE OR ALTER PROCEDURE usp_AnnualRewardLottery @TouristName VARCHAR(100)
AS
BEGIN
	SELECT  t.[Name],
		CASE
    WHEN COUNT(t.Id) >= 25 AND COUNT(t.Id)<50 THEN 'Bronze badge'
    WHEN COUNT(t.Id) >= 50 AND COUNT(t.Id)<100 THEN 'Silver badge'
	WHEN COUNT(t.Id) >= 1000 THEN 'Gold badge'
    END AS Reward
		FROM
		Tourists AS t
		JOIN SitesTourists AS st
		ON t.Id=st.TouristId
		WHERE t.[Name] = @TouristName
		GROUP BY t.Name,t.Id
END

GO

EXEC usp_AnnualRewardLottery 'Gerhild Lutgard'
EXEC usp_AnnualRewardLottery 'Teodor Petrov'
EXEC usp_AnnualRewardLottery 'Zac Walsh'
EXEC usp_AnnualRewardLottery 'Brus Brown'
