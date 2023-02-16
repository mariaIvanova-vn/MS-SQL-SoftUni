create database BAKERY

USE BAKERY


CREATE TABLE Countries(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE Customers(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(25) NOT NULL,	
LastName NVARCHAR(25) NOT NULL,
Gender CHAR(1) NOT NULL,
Age INT NOT NULL,
PhoneNumber CHAR(10) NOT NULL,
CountryId INT NOT NULL FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Products(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(25) NOT NULL UNIQUE,
[Description] NVARCHAR(250) NOT NULL,
Recipe NVARCHAR(MAX) NOT NULL,
Price MONEY CHECK(Price >= 0) NOT NULL
)

CREATE TABLE Feedbacks(
Id INT PRIMARY KEY IDENTITY,
[Description] NVARCHAR(250),
Rate	FLOAT CHECK(Rate>=0.0 AND Rate<=10.0),
ProductId	INT NOT NULL FOREIGN KEY REFERENCES Products(Id),
CustomerId	INT NOT NULL FOREIGN KEY REFERENCES Customers(Id)
)

CREATE TABLE Distributors(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(25) NOT NULL UNIQUE,
AddressText	NVARCHAR(30) NOT NULL,
Summary	NVARCHAR(200) NOT NULL,	
CountryId	INT NOT NULL FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Ingredients(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL,
[Description] NVARCHAR(200) NOT NULL,
OriginCountryId	INT NOT NULL FOREIGN KEY REFERENCES Countries(Id),
DistributorId	INT NOT NULL FOREIGN KEY REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients(
ProductId INT NOT NULL FOREIGN KEY REFERENCES Products(Id),  
IngredientId INT NOT NULL FOREIGN KEY REFERENCES Ingredients(Id),
PRIMARY KEY(ProductId, IngredientId)
)


--Section 2. DML (10 pts)--------------------------------
--2.	Insert

INSERT INTO Distributors
VALUES
('Deloitte & Touche',	2,	'6 Arch St #9757',	'Customizable neutral traveling'),
('Congress Title',	13,	'58 Hancock St',	'Customer loyalty'),
('Kitchen People',	1,	'3 E 31st St #77',	'Triple-buffered stable delivery'),
('General Color Co Inc',	21,	'6185 Bohn St #72',	'Focus group'),
('Beck Corporation',	23,	'21 E 64th Ave',	'Quality-focused 4th generation hardware')

INSERT INTO Customers
VALUES
('Francoise',	'Rautenstrauch',	15,	'M',	'0195698399',	5),
('Kendra',	'Loud',	22,	'F',	'0063631526',	11),
('Lourdes',	'Bauswell',	50,	'M',	'0139037043',	8),
('Hannah',	'Edmison',	18,	'F',	'0043343686',	1),
('Tom',	'Loeza',	31,	'M',	'0144876096',	23),
('Queenie',	'Kramarczyk',	30,	'F',	'0064215793',	29),
('Hiu',	'Portaro',	25,	'M',	'0068277755',	16),
('Josefa',	'Opitz',	43,	'F',	'0197887645',	17)


--3.	Update--------

UPDATE Ingredients
SET DistributorId = 35
WHERE Name = 'Paprika' OR Name = 'Bay Leaf' OR Name = 'Poppy'

UPDATE Ingredients 
SET OriginCountryId = 14
WHERE OriginCountryId = 8

 --4.	Delete------

 SELECT * FROM Feedbacks

 DELETE FROM Feedbacks
 WHERE ProductId=5

  DELETE FROM Feedbacks
 WHERE CustomerId=14

 
-------------------------------------------------------
--Section 3. Querying (40 pts)

--5.	Products by Price

SELECT
	Name,
	Price,
	Description
	FROM Products
ORDER BY Price DESC, Name


--6.	Negative Feedback-----------------------

SELECT 
		 f.ProductId,
		 f.Rate,
		 f.Description,
		 f.CustomerId,
		 c.Age,
		 c.Gender
	FROM Feedbacks AS f
	JOIN Customers AS c
	  ON f.CustomerId=c.Id
   WHERE f.Rate<5.0
ORDER BY f.ProductId DESC, f.Rate


--7.	Customers without Feedback----------------

SELECT
	CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
	c.PhoneNumber,
	c.Gender
	FROM Customers AS c
	LEFT JOIN Feedbacks AS f
	ON c.Id=f.CustomerId
	WHERE f.Id IS NULL
	ORDER BY c.Id


--8.	Customers by Criteria---------------------------

SELECT
		 cus.FirstName,
		 cus.Age,
	     cus.PhoneNumber
	FROM Customers AS cus
	JOIN Countries AS c
	  ON cus.CountryId=c.Id
   WHERE cus.Age>=21 AND (cus.FirstName LIKE '%an%' OR cus.PhoneNumber LIKE '%38')
   AND c.Name <> 'Greece'
ORDER BY cus.FirstName, cus.Age DESC


--9.	Middle Range Distributors--------------

SELECT 
	d.Name AS DistributorName,
	i.Name AS IngredientName,
	p.Name AS ProductName,
	AVG(f.Rate) AS AverageRate
	FROM Distributors AS d
	JOIN Ingredients AS i
	ON d.Id=i.DistributorId
	JOIN ProductsIngredients AS pin
	ON pin.IngredientId=i.Id
	JOIN Products AS p
	ON pin.ProductId=p.Id
	JOIN Feedbacks AS f
	ON f.ProductId=p.Id
	GROUP BY d.Name, i.Name, p.Name
	HAVING AVG(f.Rate) BETWEEN 5 AND 8
ORDER BY d.Name, i.Name, p.Name


--10.	Country Representative-----------------------------
SELECT
    CountryName,
    DistributorName
FROM
(
    SELECT
        c.Name AS CountryName, 
        d.Name AS DistributorName,             
        RANK() OVER (PARTITION BY c.Name ORDER BY COUNT(i.Id) DESC) AS Rank    
    FROM Countries AS c
    LEFT JOIN Distributors AS d ON c.Id = d.CountryId
    LEFT JOIN Ingredients AS i ON d.Id = i.DistributorId    
    GROUP BY c.Name, d.Name
) AS rankedTable
WHERE Rank = 1
ORDER BY CountryName, DistributorName


--Section 4. Programmability (20 pts)
--11.	Customers with Countries
GO

CREATE VIEW v_UserWithCountries
AS
SELECT 
    CONCAT(cu.FirstName, ' ', cu.LastName) AS CustomerName,
    cu.Age,
    cu.Gender,
    co.Name AS CountryName
FROM Customers AS cu
JOIN Countries AS co ON cu.CountryId = co.Id

GO 

SELECT TOP 5 *
  FROM v_UserWithCountries
 ORDER BY Age



 --12.	Delete Products

Go

CREATE TRIGGER tr_DeleteProducts
ON Products 
INSTEAD OF DELETE
AS
BEGIN
DECLARE @productId INT = (SELECT Id FROM deleted)
DELETE FROM Feedbacks WHERE ProductId = @productId
DELETE FROM ProductsIngredients WHERE ProductId = @productId
DELETE FROM Products WHERE Id = @productId
END

GO

DELETE FROM Products WHERE Id = 7