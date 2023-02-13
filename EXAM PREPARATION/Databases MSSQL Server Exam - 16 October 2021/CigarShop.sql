CREATE DATABASE CigarShop

USE CigarShop


CREATE TABLE Sizes(
Id INT PRIMARY KEY IDENTITY,
[Length] INT NOT NULL CHECK([Length]>=10 AND [Length]<=25),
RingRange DECIMAL(2,1) NOT NULL CHECK(RingRange>=1.5 AND RingRange<=7.5)
)

CREATE TABLE Tastes(
Id INT PRIMARY KEY IDENTITY,
TasteType VARCHAR(20) NOT NULL,
TasteStrength VARCHAR(15) NOT NULL,
ImageURL VARCHAR(100) NOT NULL
)

CREATE TABLE Brands(
Id INT PRIMARY KEY IDENTITY,
BrandName VARCHAR(30) UNIQUE NOT NULL,
BrandDescription VARCHAR(MAX)
)

CREATE TABLE Cigars(
Id INT PRIMARY KEY IDENTITY,
CigarName VARCHAR(80) NOT NULL,
BrandId INT NOT NULL FOREIGN KEY REFERENCES Brands(Id),
TastId INT NOT NULL FOREIGN KEY REFERENCES Tastes(Id),
SizeId INT NOT NULL FOREIGN KEY REFERENCES Sizes(Id),   -- PRIMARY KEY ???????????
PriceForSingleCigar MONEY NOT NULL,                    -- A decimal number used for money calculations.
ImageURL NVARCHAR(100) NOT NULL                         -- Unicode ???????NVARCHAR
)

CREATE TABLE Addresses(
Id INT PRIMARY KEY IDENTITY,
Town VARCHAR(30) NOT NULL,
Country NVARCHAR(30) NOT NULL,
Streat NVARCHAR(100) NOT NULL,
ZIP VARCHAR(20) NOT NULL
)

CREATE TABLE Clients(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL,
LastName NVARCHAR(30) NOT NULL,
Email NVARCHAR(50) NOT NULL,
AddressId INT NOT NULL FOREIGN KEY REFERENCES Addresses(Id)
)

CREATE TABLE ClientsCigars(
ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(Id),
CigarId INT NOT NULL FOREIGN KEY REFERENCES Cigars(Id),
PRIMARY KEY(ClientId, CigarId)
)


--Section 2. DML (10 pts)--------------------------------
--2.	Insert

INSERT INTO Cigars
VALUES
 ('COHIBA ROBUSTO', 9, 1, 5, 15.50, 'cohiba-robusto-stick_18.jpg'),
 ('COHIBA SIGLO I', 9, 1, 10, 410.00, 'cohiba-siglo-i-stick_12.jpg'),
 ('HOYO DE MONTERREY LE HOYO DU MAIRE', 14, 5, 11, 7.50, 'hoyo-du-maire-stick_17.jpg'),
 ('HOYO DE MONTERREY LE HOYO DE SAN JUAN', 14, 4, 15, 32.00, 'hoyo-de-san-juan-stick_20.jpg'),
 ('TRINIDAD COLONIALES', 2, 3, 8, 85.21, 'trinidad-coloniales-stick_30.jpg')

INSERT INTO Addresses
VALUES 
 ('Sofia', 'Bulgaria', '18 Bul. Vasil levski', '1000'),
 ('Athens', 'Greece', '4342 McDonald Avenue', '10435'),
 ('Zagreb', 'Croatia', '4333 Lauren Drive', '10000')


 --3.	Update--------

 UPDATE Cigars
 SET PriceForSingleCigar+= PriceForSingleCigar*0.2
 WHERE TastId = 1

  UPDATE Brands
  SET BrandDescription = 'New description'
  WHERE BrandDescription IS NULL


    --4.	Delete------

	DELETE
  FROM Clients
 WHERE AddressId IN (7, 8, 10)


DELETE FROM Addresses
WHERE Country LIKE 'C%'


-------------------------------------------------------
--Section 3. Querying (40 pts)

--5.	Cigars by Price

SELECT 
		CigarName,
		PriceForSingleCigar,
		ImageURL
		FROM Cigars
	ORDER BY PriceForSingleCigar, CigarName DESC


--6.	Cigars by Taste

SELECT 
		c.Id,
		c.CigarName,
		c.PriceForSingleCigar,
		t.TasteType,
		t.TasteStrength
		FROM
		Cigars AS c
		JOIN Tastes AS t
		ON t.Id=c.TastId
		WHERE TasteType = 'Earthy' OR TasteType = 'Woody'
	ORDER BY c.PriceForSingleCigar DESC


--7.	Clients without Cigars---------------------------

SELECT
		c.Id,
		CONCAT(c.FirstName, ' ', c.LastName) AS ClientName,
		c.Email
		FROM Clients AS c
		LEFT JOIN ClientsCigars AS cc
		ON
		cc.ClientId=c.Id
		WHERE cc.ClientId IS NULL
	ORDER BY c.FirstName


--8.	First 5 Cigars---------------------------------------

SELECT TOP(5)
	c.CigarName,
	c.PriceForSingleCigar,
	c.ImageURL
	FROM Cigars AS c
	 JOIN Sizes AS s
	ON c.SizeId=s.Id
   WHERE s.[Length] >= 12 AND (c.CigarName LIKE '%ci%' OR c.PriceForSingleCigar > 50)
   AND  s.RingRange > 2.55
   ORDER BY c.CigarName, c.PriceForSingleCigar DESC

--9.	Clients with ZIP Codes-------------------------------------------
--Select all clients which have addresses with ZIP code that contains only digits, and display they're the most expensive cigar. Order by client full name ascending.
SELECT 
	CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
	a.Country,
	a.ZIP,
	CONCAT('$',MAX(cig.PriceForSingleCigar))-- AS CigarPrice
	FROM Clients AS c
	JOIN Addresses AS a
	ON c.AddressId=a.Id
	JOIN ClientsCigars AS cc
	ON cc.ClientId=c.Id
	JOIN Cigars AS cig
	ON cc.CigarId=cig.Id
WHERE a.ZIP NOT LIKE '%[^0-9]%'
 GROUP BY a.Country, a.ZIP, CONCAT(c.FirstName, ' ', c.LastName)
ORDER BY CONCAT(c.FirstName, ' ', c.LastName)


--10.	Cigars by Size-----------------------------------------------

SELECT 
	c.LastName,
	 ROUND(AVG(s.[Length]), 0) AS CiagrLength,        --average length  
	CEILING(AVG(s.RingRange)) AS CiagrRingRange       --ring range (rounded up to the next biggest integer)
	FROM Clients AS c
	JOIN ClientsCigars AS cc
	ON cc.ClientId=c.Id
	JOIN Cigars AS cig
	ON cc.CigarId=cig.Id
	JOIN Sizes AS s
	ON cig.SizeId=s.Id
GROUP BY c.LastName
ORDER BY AVG(s.Length) DESC


--Section 4. Programmability (20 pts)
--11.	Client with Cigars

GO

CREATE FUNCTION udf_ClientWithCigars(@name NVARCHAR(30))
RETURNS INT
AS
BEGIN
	DECLARE @counts INT = 
			(
			SELECT COUNT(*) FROM Clients AS c
			JOIN ClientsCigars AS cc
			ON c.Id=cc.ClientId
			WHERE c.FirstName = @name
			)
	RETURN @counts
END

GO
SELECT dbo.udf_ClientWithCigars('Betty')

--12.	Search for Cigar with Specific Taste---------------------
GO

CREATE  PROCEDURE usp_SearchByTaste @taste VARCHAR(20)
AS
BEGIN
	SELECT 
	c.CigarName,
	CONCAT('$', c.PriceForSingleCigar) AS Price,
	t.TasteType,
	b.BrandName, 
	CONCAT(s.[Length], ' ', 'cm') AS CigarLength,
	CONCAT(s.RingRange, ' ', 'cm') AS CigarRingRange
	FROM Cigars AS c
	JOIN Tastes AS t
	ON c.TastId=t.Id
	JOIN Brands AS b
	ON b.Id=c.BrandId
	JOIN Sizes AS s
	ON s.Id=c.SizeId
WHERE t.TasteType = @taste
ORDER BY s.[Length], s.RingRange DESC
END



EXEC usp_SearchByTaste 'Woody'