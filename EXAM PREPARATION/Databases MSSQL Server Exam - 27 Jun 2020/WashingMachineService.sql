CREATE DATABASE WashingMachineService

USE WashingMachineService

CREATE TABLE Clients(
ClientId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50) NOT NULL,        --String up to 50 symbols, ASCII
LastName VARCHAR(50) NOT NULL,
Phone CHAR(12) NOT NULL                --String containing 12 symbols. String length is exactly 12 chars long
)

CREATE TABLE Mechanics(
MechanicId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
[Address] VARCHAR(255) NOT NULL               
)

CREATE TABLE Models(
ModelId	INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Jobs(
JobId INT PRIMARY KEY IDENTITY,
ModelId INT NOT NULL FOREIGN KEY REFERENCES Models(ModelId),
[Status] VARCHAR(11) NOT NULL DEFAULT('Pending') CHECK([Status] IN ('Pending', 'In Progress', 'Finished')),
ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(ClientId),
MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId),
IssueDate DATE NOT NULL,
FinishDate DATE
)

CREATE TABLE Orders(
OrderId	INT PRIMARY KEY IDENTITY,
JobId	INT NOT NULL FOREIGN KEY REFERENCES Jobs(JobId),
IssueDate	Date,
Delivered BIT DEFAULT(0) NOT NULL                      --Boolean. Default value is False
)

CREATE TABLE Vendors(
VendorId INT PRIMARY KEY IDENTITY,
Name	VARCHAR(50)	Unique NOT NULL
)

CREATE TABLE Parts(
PartId	INT PRIMARY KEY IDENTITY,
SerialNumber	VARCHAR(50)	Unique NOT NULL,
[Description]	VARCHAR(255),	
Price	MONEY CHECK(Price > 0) NOT NULL,                          --Monetary value up to 9999.99. Cannot be zero or negative
VendorId	INT NOT NULL FOREIGN KEY REFERENCES Vendors(VendorId),
StockQty INT NOT NULL DEFAULT(0) CHECK(StockQty >= 0) 
)

CREATE TABLE OrderParts(
OrderId	INT NOT NULL FOREIGN KEY REFERENCES Orders(OrderId),
PartId	INT NOT NULL FOREIGN KEY REFERENCES Parts(PartId),
Quantity	INT	NOT NULL Default 1 CHECK(Quantity>0),          --32-bit Integer	Cannot be zero or negative; Default value is 1
PRIMARY KEY(OrderId, PartId)
)

CREATE TABLE PartsNeeded(
JobId INT NOT NULL FOREIGN KEY REFERENCES Jobs(JobId),
PartId INT NOT NULL FOREIGN KEY REFERENCES Parts(PartId),
Quantity INT NOT NULL Default 1 CHECK(Quantity>0),             --32-bit Integer	Cannot be zero or negative; Default value is 1
PRIMARY KEY(JobId, PartId)
)


--Section 2. DML (10 pts)--------------------------------
--2.	Insert

INSERT INTO Clients --(ClientId, FirstName, LastName, Phone) 
VALUES
( 'Teri', 'Ennaco', '570-889-5187'),
('Merlyn', 'Lawler', '201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie', 'Mconnell', '908-802-3564'),
('Lemuel', 'Latzke', '631-748-6479'),
('Melodie', 'Knipp', '805-690-1682'),
('Candida', 'Corbley', '908-275-8357')

INSERT INTO Parts --(PartId, SerialNumber, [Description], Price, VendorId, StockQty) 
VALUES
('WP8182119', 'Door Boot Seal', 117.86, 2, 1),
('W10780048', 'Suspension Rod', 42.81, 1, 1),
('W10841140', 'Silicone Adhesive', 6.77, 4, 1),
('WPY055980', 'High Temperature Adhesive', 13.94, 3, 1)


--3.	Update--------
--Assign all Pending jobs to the mechanic Ryan Harnos (look up his ID manually, there is no need to use table joins) 
--and change their status to 'In Progress'.

	 UPDATE Jobs
		SET MechanicId = 3,
      Status = 'In Progress'    
WHERE Status = 'Pending'

  --4.	Delete------

DELETE FROM OrderParts
      WHERE OrderId = 19

DELETE FROM Orders
      WHERE OrderId=19


-------------------------------------------------------
--Section 3. Querying (40 pts)

--5.	Mechanic Assignments

SELECT 
	CONCAT(m.FirstName, ' ', m.LastName) AS Mechanic,
	j.Status,
	j.IssueDate
	FROM Mechanics AS m
	JOIN Jobs AS j
	ON m.MechanicId=j.MechanicId
ORDER BY m.MechanicId, j.IssueDate, j.JobId


--6.	Current Clients------------------------------------------------

SELECT    
		CONCAT(c.FirstName, ' ', c.LastName) AS Client,
		DATEDIFF(DAY, j.IssueDate,'2017-04-24') AS [Days going],
		j.Status
		FROM Clients AS c
		LEFT JOIN Jobs AS j
		ON j.ClientId=c.ClientId
	WHERE j.Status='In Progress' OR j.Status='Pending'
	ORDER BY [Days going] DESC, c.ClientId

--7.	Mechanic Performance-------------------------------------------

SELECT  CONCAT(m.FirstName, ' ', m.LastName) AS Mechanic,
		AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS [Average Days]
		FROM Mechanics AS m
		JOIN Jobs AS j
		ON m.MechanicId=j.MechanicId
		GROUP BY CONCAT(m.FirstName, ' ', m.LastName), m.MechanicId
	    ORDER BY m.MechanicId


--8.	Available Mechanics------------------------------------------

SELECT  CONCAT(FirstName, ' ', LastName) AS Available		
		FROM Mechanics 
		WHERE MechanicId NOT IN
		(
			SELECT MechanicId 
			FROM Jobs
			WHERE [Status] = 'In Progress'
		)
      ORDER BY MechanicId


--9.	Past Expenses--------------------------------------------

SELECT	j.JobId,
	ISNULL(SUM(p.Price * op.Quantity), 0.00) AS Total

	FROM Jobs AS j 
  LEFT JOIN Orders AS o ON j.JobId = o.JobId
  LEFT JOIN OrderParts AS op ON o.OrderId = op.OrderId
  LEFT JOIN Parts AS p ON op.PartId = p.PartId
  WHERE j.Status = 'Finished'
	GROUP BY j.JobId
	ORDER BY Total DESC, j.JobId


--10.	Missing Parts---------------------------------------------------
--List all parts that are needed for active jobs (not Finished) without sufficient quantity in stock and 
--in pending orders (the sum of parts in stock and parts ordered is less than the required quantity). Order them by part ID (ascending).

	SELECT
    p.PartId,
    p.Description,
    SUM(pn.Quantity) AS Required,
    SUM(p.StockQty) AS InStock,
    ISNULL(SUM(t.Quantity), 0) AS Ordered
FROM Parts AS p
LEFT JOIN PartsNeeded AS pn ON p.PartId = pn.PartId
LEFT JOIN Jobs AS j ON pn.JobId = j.JobId
LEFT JOIN
    (
        SELECT PartId, Quantity        
        FROM Orders AS o
        JOIN OrderParts AS op ON o.OrderId = op.OrderId
        WHERE o.Delivered = 0    
    ) AS t ON p.PartId = t.PartId
WHERE j.Status <> 'Finished'
GROUP BY p.PartId, p.Description
HAVING SUM(pn.Quantity) > SUM(p.StockQty) + ISNULL(SUM(t.Quantity), 0)
ORDER BY p.PartId ASC


--Section 4. Programmability---------------------------------------
--11.	Place Order

GO

CREATE PROC usp_PlaceOrder
(@jobId INT, @serial VARCHAR(50), @quantity INT)
AS
BEGIN
IF (@jobId IN (SELECT JobId FROM Jobs WHERE Status = 'Finished')) THROW 50011, 'This job is not active!', 1
IF (@quantity <= 0) THROW 50012, 'Part quantity must be more than zero!', 1
IF (@jobId NOT IN (SELECT JobId FROM Jobs)) THROW 50013, 'Job not found!', 1
IF (@serial NOT IN (SELECT SerialNumber FROM Parts)) THROW 50014, 'Part not found!', 1

DECLARE @partId INT = (SELECT TOP(1) PartId FROM Parts WHERE SerialNumber = @serial)
DECLARE @orderId INT

IF (@jobId IN (SELECT JobId FROM Orders WHERE IssueDate IS NULL))
    BEGIN
    SET @OrderId = (SELECT TOP(1) OrderId FROM Orders WHERE JobId = @jobId)
    IF (@partId IN (SELECT PartId FROM OrderParts WHERE OrderId = @OrderId))
        BEGIN
        UPDATE OrderParts
            SET Quantity += @quantity 
            WHERE OrderId = @OrderId AND PartId = @partId
        RETURN
        END
    INSERT INTO OrderParts VALUES (@OrderId, @partId, @quantity)
    RETURN
    END

INSERT INTO Orders VALUES (@jobId, NULL, 0)
SET @orderId = (SELECT TOP(1) OrderId FROM Orders ORDER BY OrderId DESC)
INSERT INTO OrderParts VALUES (@OrderId, @partId, @quantity)
END



--12.	Cost Of Order-------------------------------------------

GO

CREATE FUNCTION udf_GetCost (@JobId INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
 
DECLARE @cost DECIMAL(18, 2) = (
									SELECT SUM(p.Price * op.Quantity) FROM Jobs AS j
                                      LEFT JOIN Orders AS o ON j.JobId = o.JobId
									  LEFT JOIN OrderParts AS op ON o.OrderId = op.OrderId
									  LEFT JOIN Parts AS p ON op.PartId = p.PartId
									 WHERE j.JobId = @JobId)

IF (@cost IS NULL) RETURN 0.00

RETURN @cost

END

GO

SELECT dbo.udf_GetCost(1)