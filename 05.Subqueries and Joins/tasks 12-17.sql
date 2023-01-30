USE Geography

---------------------------------------------------------
--12.	Highest Peaks in Bulgaria

SELECT 
		 mc.CountryCode,
		 m.MountainRange,
		 p.PeakName,
		 p.Elevation
    FROM MountainsCountries AS mc
    JOIN Mountains AS m
      ON mc.MountainId=m.Id
    JOIN Peaks AS p
      ON m.Id=p.MountainId
   WHERE mc.CountryCode = 'BG'
	 AND p.Elevation>2835
ORDER BY p.Elevation DESC

---------------------------------------------------------
--13.	Count Mountain Ranges

SELECT 
		 CountryCode,
		 COUNT(MountainId) AS MountainRanges 
    FROM MountainsCountries 
   WHERE CountryCode IN ('BG','RU','US')
GROUP BY CountryCode

---------------------------------------------------------
--14.	Countries With or Without Rivers

SELECT TOP(5) 
	 	  c.CountryName,
	 	  r.RiverName
	 FROM Countries AS c
LEFT JOIN CountriesRivers AS cr
	   ON c.CountryCode=cr.CountryCode
LEFT JOIN Rivers AS r
	   ON cr.RiverId=r.Id
    WHERE c.ContinentCode='AF'
 ORDER BY c.CountryName

---------------------------------------------------------
--15.	*Continents and Currencies

SELECT [ContinentCode], [CurrencyCode], [CurrencyUsage]
	FROM(
		SELECT [ContinentCode], [CurrencyCode], COUNT([CurrencyCode]) AS [CurrencyUsage],
		DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY COUNT([CurrencyCode]) DESC) AS [Rank] 
			FROM [Countries]
		GROUP BY [ContinentCode], [CurrencyCode]
		) AS k
	WHERE [Rank] = 1 AND [CurrencyUsage] > 1
	ORDER BY [ContinentCode]

---------------------------------------------------------
--16.	Countries Without Any Mountains

SELECT COUNT(*) AS [Count]
	FROM (
		SELECT [mc].[MountainId] AS [m]
			FROM [MountainsCountries] AS [mc]
	  RIGHT JOIN [Countries] AS [c]
			  ON [c].[CountryCode] = [mc].[CountryCode]
		WHERE [mc].[MountainId] IS NULL
		) AS c

---------------------------------------------------------
--17.	Highest Peak and Longest River by Country

SELECT TOP(5)
				 [c].[CountryName],
			 MAX([p].[Elevation]) AS HighestPeakElevation,
			 MAX([r].[Length]) AS [LongestRiverLength]
			FROM [Countries] AS [c]
	   LEFT JOIN [MountainsCountries] AS [mc]
			  ON [mc].[CountryCode] = [c].[CountryCode]
	   LEFT JOIN [Peaks] AS [p]
			  ON [p].[MountainId] = [mc].[MountainId]
	   LEFT JOIN [CountriesRivers] AS [cr]
			  ON [cr].[CountryCode] = [c].[CountryCode]
	   LEFT JOIN [Rivers] AS [r]
			  ON [r].[Id] = [cr].[RiverId]
		GROUP BY [c].[CountryName]
		ORDER BY [HighestPeakElevation] DESC,
				 [LongestRiverLength] DESC,
			     [c].[CountryName]