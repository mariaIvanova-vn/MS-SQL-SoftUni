CREATE DATABASE Movies

USE Movies

CREATE TABLE Directors(
Id INT PRIMARY KEY,
DirectorName NVARCHAR(50) NOT NULL,
NOTES NVARCHAR(MAX)
)

CREATE TABLE Genres(
Id INT PRIMARY KEY,
GenreName NVARCHAR(50) NOT NULL,
Notes NVARCHAR(MAX)
)

CREATE TABLE Categories(
Id INT PRIMARY KEY,
CategoryName NVARCHAR(50) NOT NULL,
Notes NVARCHAR(MAX)
)

CREATE TABLE Movies(
Id INT PRIMARY KEY,
Title NVARCHAR(50) NOT NULL,
DirectorId INT NOT NULL, 
CopyrightYear INT NOT NULL,
[Length] TIME NOT NULL,
GenreId INT NOT NULL,
CategoryId INT NOT NULL,
Rating TINYINT NOT NULL,
Notes NVARCHAR(MAX)
)

INSERT INTO Directors(Id, DirectorName)
VALUES
(1, 'Some name'),
(2, 'Maria'),
(3, 'Diana'),
(4, 'Sashko'),
(5, 'Director name')

INSERT INTO Genres(Id, GenreName)
VALUES
(1, 'Some name'),
(2, 'Maria'),
(3, 'Diana'),
(4, 'Sashko'),
(5, 'name')

INSERT INTO Categories(Id, CategoryName)
VALUES
(1, 'Some name'),
(2, 'Comedy'),
(3, 'Family movie'),
(4, 'Horror'),
(5, 'Action')

INSERT INTO Movies(Id, Title, DirectorId, CopyrightYear, [Length], GenreId, CategoryId, Rating)
VALUES
(1, 'Some name', 2, 5,'2:33', 10, 2, 3),
(2, 'Comedy', 4, 5,'2:19', 10, 2, 3),
(3, 'Family movie', 4, 3,'4:12', 10, 2, 3),
(4, 'Horror', 2, 5,'4:03', 10, 2, 3),
(5, 'Action', 3, 5,'2:33', 9, 5, 6)