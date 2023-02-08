CREATE DATABASE Airport

USE Airport


CREATE TABLE Passengers(
Id INT PRIMARY KEY IDENTITY,
FullName VARCHAR(100) UNIQUE NOT NULL,
Email VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Pilots(
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(30) UNIQUE NOT NULL,
LastName VARCHAR(30) UNIQUE NOT NULL,
Age TINYINT NOT NULL CHECK(Age>=21 AND Age<=62),
Rating FLOAT CHECK(Rating>=0.0 AND Rating<=10.0)
)

CREATE TABLE AircraftTypes(
Id INT PRIMARY KEY IDENTITY,
TypeName VARCHAR(30) UNIQUE NOT NULL,
)

CREATE TABLE Aircraft(
Id INT PRIMARY KEY IDENTITY,
Manufacturer VARCHAR(25) NOT NULL,
Model VARCHAR(30) NOT NULL,
[Year] INT NOT NULL,
FlightHours INT,
Condition CHAR NOT NULL,
TypeId INT NOT NULL FOREIGN KEY REFERENCES AircraftTypes(Id)
)

CREATE TABLE PilotsAircraft(
AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft(Id),
PilotId INT NOT NULL FOREIGN KEY REFERENCES Pilots(Id),
PRIMARY KEY(AircraftId, PilotId)
)

CREATE TABLE Airports(
Id INT PRIMARY KEY IDENTITY,
AirportName VARCHAR(70) UNIQUE NOT NULL,
Country VARCHAR(100) UNIQUE NOT NULL,
)

CREATE TABLE FlightDestinations(
Id INT PRIMARY KEY IDENTITY,
AirportId INT NOT NULL FOREIGN KEY REFERENCES Airports(Id),
[Start] DateTime NOT NULL,
AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft(Id),
PassengerId INT NOT NULL FOREIGN KEY REFERENCES Passengers(Id),
TicketPrice DECIMAL(18,2) NOT NULL DEFAULT 15
)


--Section 2. DML (10 pts)--------------------------------
--2.	Insert

INSERT INTO Passengers(FullName, Email)
SELECT 
	CONCAT(FirstName, ' ', LastName) AS FullName,
	CONCAT(FirstName, LastName, '@gmail.com') AS Email
FROM Pilots
WHERE Id BETWEEN 5 AND 15


--3.	Update--------

UPDATE Aircraft
   SET Condition = 'A'
 WHERE (Condition='B' OR Condition='C')
 AND (FlightHours IS NULL OR FlightHours<=100)
 AND [Year]>=2013


  --4.	Delete------

  SELECT 
	  FullName
 FROM Passengers
WHERE LEN(FullName)<=10

DELETE FROM Passengers
WHERE LEN(FullName)<=10


-------------------------------------------------------
--Section 3. Querying (40 pts)

--5.	Aircraft

  SELECT
		 Manufacturer,
		 Model,
		 FlightHours,
		 Condition
    FROM Aircraft
ORDER BY FlightHours DESC


--6.	Pilots and Aircraft

SELECT
		p.FirstName,
		p.LastName,
		a.Manufacturer,
		a.Model,
		a.FlightHours
	FROM Pilots AS p
	JOIN PilotsAircraft AS pa
	ON p.Id=pa.PilotId
	JOIN Aircraft AS a
	ON pa.AircraftId=a.Id
	WHERE a.FlightHours<=304
ORDER BY a.FlightHours DESC, p.FirstName
	

--7.	Top 20 Flight Destinations

SELECT TOP(20)
		fd.Id,
		fd.Start,
		p.FullName, 
		a.AirportName, 
		fd.TicketPrice
	FROM FlightDestinations AS fd
	JOIN Passengers AS p
	ON fd.PassengerId=p.Id
	JOIN Airports AS a
	ON a.Id=fd.AirportId
	WHERE DAY(fd.Start) % 2 = 0
ORDER BY fd.TicketPrice DESC, a.AirportName


--8.	Number of Flights for Each Aircraft--------------

SELECT
		a.Id,
		a.Manufacturer,
		a.FlightHours,
		COUNT(a.Id) AS FlightDestinationsCount,
		ROUND(AVG(fd.TicketPrice),2) AS AvgPrice
	  FROM Aircraft AS a
	  JOIN FlightDestinations AS fd
	  ON a.Id=fd.AircraftId
GROUP BY a.Id, a.Manufacturer, a.FlightHours
HAVING COUNT(a.Id) >=2
ORDER BY FlightDestinationsCount DESC, a.Id


--9.	Regular Passengers------------------------

SELECT 
		 p.FullName, 
		 COUNT(p.Id) AS CountOfAircraft, 
		 SUM(fd.TicketPrice) AS TotalPayed
	FROM Passengers AS p
	JOIN FlightDestinations AS fd
	ON p.Id=fd.PassengerId
	WHERE p.FullName LIKE '_a%'
	GROUP BY p.FullName
	HAVING COUNT(p.Id) >1
	ORDER BY p.FullName


--10.	Full Info for Flight Destinations------------

SELECT 
		a.AirportName,
	    fd.Start AS DayTime,
		fd.TicketPrice,
		p.FullName,
		af.Manufacturer,
		af.Model
		FROM
		FlightDestinations AS fd
		JOIN Airports AS a
		ON fd.AirportId=a.Id
		JOIN Passengers AS p
		ON p.Id=fd.PassengerId
		JOIN Aircraft AS af
		ON af.Id=fd.AircraftId
	WHERE fd.TicketPrice > 2500 AND DATEPART(HOUR, fd.Start) BETWEEN 6 AND 20
ORDER BY af.Model


--Section 4. Programmability (20 pts)
--11.	Find all Destinations by Email Address

GO

CREATE FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(50))
	RETURNS INT
	AS
	BEGIN
	DECLARE @counts INT
		SET @counts = (
			SELECT 
			COUNT(fd.TicketPrice) 
			FROM Passengers AS p
			JOIN FlightDestinations AS fd
			ON p.Id=fd.PassengerId
			WHERE Email = @email
						)
	RETURN @counts
END

GO

SELECT dbo.udf_FlightDestinationsByEmail ('PierretteDunmuir@gmail.com')


--12.	Full Info for Airports-------------------------

GO

CREATE OR ALTER PROCEDURE usp_SearchByAirportName(@airportName VARCHAR(70))
AS
BEGIN
	SELECT 
		a.AirportName,
		p.FullName,
		CASE
    WHEN fd.TicketPrice <= 400 THEN 'Low'
    WHEN fd.TicketPrice BETWEEN 401 AND 1500  THEN 'Medium' 
    ELSE 'High'
    END AS LevelOfTickerPrice,
	af.Manufacturer,
	af.Condition,
	at.TypeName
	FROM Airports AS a
	JOIN FlightDestinations AS fd
	ON a.Id=fd.AirportId
	JOIN Passengers AS p
	ON p.Id=fd.PassengerId
	JOIN Aircraft AS af
	ON af.Id=fd.AircraftId
	JOIN AircraftTypes AS at
	ON at.Id=af.TypeId
	WHERE AirportName = @airportName
	ORDER BY af.Manufacturer, p.FullName
END

GO