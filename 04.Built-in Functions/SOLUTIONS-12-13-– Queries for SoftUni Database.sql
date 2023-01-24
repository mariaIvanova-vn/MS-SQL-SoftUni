USE Geography

--12.	Countries Holding 'A' 3 or More Times

   SELECT [CountryName], [ISOCode] 
     FROM [Countries]
    WHERE [CountryName] LIKE '%A%A%A%'
 ORDER BY [IsoCode]

 --13.	 Mix of Peak and River Names

 SELECT [p].[PeakName], [r].[RiverName],
 LOWER(CONCAT([p].[PeakName], RIGHT([r].[RiverName],LEN([r].[RiverName])-1))) AS [Mix]
   FROM [Rivers] AS [r],
        [Peaks] AS [p]
  WHERE RIGHT([p].[PeakName],1) = LEFT([r].[RiverName],1)
  ORDER BY [Mix]