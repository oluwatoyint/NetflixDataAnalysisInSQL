--1.	Display the total Number of Movies vs TV Shows
	SELECT 
		type,
		COUNT(*) count_type
	FROM netflix_titles
	GROUP BY type

	--Objective: Determine the distribution of content types on Netflix.


--2.	Count the Number of Content Items in Each Genre
		SELECT 
			Trim(Value) AS genre,  
			COUNT(*) AS total_content  
		FROM netflix_titles
		   CROSS APPLY string_split (listed_in, ',') 
		GROUP BY Trim(Value);

		--Objective: Count the number of content items in each genre.

--3.	List All Movies Released in a 2020
		SELECT * FROM netflix_titlesCopy
		WHERE Type = 'Movie' AND Release_Year = 2020


		--Objective: Retrieve all movies released in a specific year.

--4.	Find the Top 5 Countries with the Most Content on Netflix
		SELECT Top(5) * 
		FROM
		(
			SELECT 
			Trim(Value) AS country,  
			COUNT(*) AS total_content  
			FROM netflix_titles
			   CROSS APPLY string_split (country, ',') 
			GROUP BY Trim(Value)

		) AS temp
		WHERE country IS NOT NULL
		ORDER BY total_content DESC

		--Objective: Identify the top 5 countries with the highest number of content items.

--5.	Find Content Added in the Last 5 Years
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	date_added >= DATEADD(Year, -5, GetDate())

--6.	 All Movies that are Documentaries
SELECT
	* 
FROM 
	netflix_titlesCopy
WHERE 
	Type='Movie' AND 
	Listed_in LIKE '%Documentaries%'

--Method 2 - for normalized tables

SELECT 
	ntf.*, 
	nli.listed_in 
FROM 
	netflix_titlesCopy ntf
JOIN 
	netflix_listed_in nli ON ntf.show_id = nli.show_id
WHERE 
	nli.Listed_in = 'Documentaries'

--7.	Find All Content Without a Director
-- In Director column Null was replaced with NA

SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE director ='NA'

--Method 2

SELECT 
	ntf.*, 
	nd.director 
FROM 
	netflix_titlesCopy ntf
JOIN 
	netflix_director nd ON ntf.show_id = nd.show_id
WHERE 
	nd.director = 'NA'

 --8.	Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
 SELECT 
	* 
FROM 
	netflix_titlesCopy
 WHERE 
	Type='Movie' 
	AND cast LIKE '%Salman Khan%' 
	AND release_year > YEAR(GetDate()) - 10

 -- Method 2: For normalized Cast table
SELECT 
	ntf.*, 
	nc.cast 
FROM 
	netflix_titlesCopy ntf
JOIN 
	netflix_cast nc ON ntf.show_id = nc.show_id
WHERE nc.cast= 'Salman Khan' 
AND  ntf.release_year > YEAR(GetDate()) - 10

--9.	Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT TOP(10)
	Trim(Value) AS Actor,
	COUNT(*) HighestNumber
FROM 
	netflix_titles
CROSS APPLY 
	STRING_SPLIT(cast,',')
WHERE 
	country LIKE '%India%' 
	AND type = 'Movie'
GROUP BY 
	Trim(Value)
Order BY 
	COUNT(*) DESC
--Method 2:Rewrite using string_Split
--9 Method 2 11, 12, 14, 15
 
--10.	Categorize the content based on the presence of the keywords 
--     'kill' and 'violence' in the description field. 
--      Label content containing these keywords as 'Bad' and all other content as 'Good'. 
--      Count how many items fall into each category.
 
 
SELECT 
	Category,
	Count(*) As CountContent
FROM
	(
		SELECT 
			CASE 
				WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
			ELSE
				'Good'
			END AS Category 
		FROM netflix_titlesCopy
	) AS Categorised_Content
	Group BY 
		Category     -- and all other content as 'Good'. Count how many items fall into each category.


--11.	Identify the Longest Movie
SELECT 
	value from string_split('113 min',' ')
-- The above was to explain the concept of value
-- Method
SELECT 
    value 
FROM 
    STRING_SPLIT('113 min', ' ')

SELECT TOP (1)
    Type,
    Title,
    value AS TotalMinute,
    duration
FROM 
    netflix_titlesCopy
CROSS APPLY 
    STRING_SPLIT(duration, ' ', 1)
WHERE 
    type = 'Movie' 
    AND ordinal = 1
ORDER BY 
    CAST(TRIM(value) AS INT) DESC

--12.	Find All Movies/TV Shows by Director 'Rajiv Chilaka'
-- Need to normalize the table netflix_TitlesCopy and create Director Table 
SELECT 
	show_id, 
	TRIM(value) as director
INTO 
	netflix_director
FROM 
	netflix_titlesCopy
CROSS APPLY 
	string_split(director,',')

-- Method 1
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	Type IN ('Movie', 'TV Show') 
	AND Director LIKE '%Rajiv Chilaka%'

--Method 2
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	Director LIKE '%Rajiv Chilaka%'

--Method 3
SELECT 
	ntf.*, 
	nd.director 
FROM 
	netflix_titlesCopy ntf
JOIN 
	netflix_director nd ON ntf.show_id = nd.show_id
WHERE 
	nd.Director = 'Rajiv Chilaka'

--13.	List All TV Shows with More Than 5 Seasons
SELECT
	Title,
	TRIM(Value) Season
FROM
	netflix_titlesCopy
CROSS APPLY 
	string_split(duration,' ',1)
WHERE 
	type = 'TV Show' 
	AND Ordinal = 1
	AND TRY_CAST(TRIM(Value) AS INT) > 5
Order By 
	CAST(TRIM(Value) AS INT) DESC


--14.	List content items added after August 20, 2021
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	CAST(date_added as Date) > '2021-08-20'  -- We do not need to do this if this was converted before
-- Use method below if the date column values have already been formatted with the Date datatype
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	date_added > '2021-08-20'

--15.	List movies added to on June 15, 2019
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	date_added = '2019-06-15' AND type='Movie'

--16.	List content items added in 2021
--Method 1
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	date_added >= '2021-01-01' 
	AND date_added <= '2021-12-31'
 
 --Method 2
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	date_added BETWEEN '2021-01-01' 
	AND '2021-12-31'
  
--Method 3
Select 
	*  
FROM 
	netflix_titlesCopy
WHERE 
	date_added LIKE '%2021%'

--Method 4
SELECT 
	*
FROM
	netflix_titlesCopy where Year(date_added) = 2021

--17.	List movies added in 2021

--Method 1

SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	type = 'Movie' 
	AND date_added >= '2021-01-01' 
	AND date_added <= '2021-12-31'
  
--Method 2
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	type = 'Movie' 
	AND  date_added BETWEEN '2021-01-01' 
	AND '2021-12-31'

  --Method 3
SELECT 
	*  
 FROM 
	netflix_titlesCopy
 WHERE 
	type = 'Movie' 
	AND date_added LIKE '%2021%'

--Method 4
SELECT 
	*
FROM 
	netflix_titlesCopy 
WHERE 
	Year(date_added) = 2021 
	AND type='Movie'
 
--18.	Count the number of movies and tv series that each director has produced in different columns.
--Grok Solution
SELECT 
    d.director,
    SUM(CASE WHEN t.type = 'Movie' THEN 1 ELSE 0 END) as Movie_Count,
    SUM(CASE WHEN t.type = 'TV Show' THEN 1 ELSE 0 END) as TV_Series_Count
FROM 
	netflix_director d
LEFT JOIN 
	netflix_titlesCopy t ON d.show_id = t.show_id
WHERE 
	d.director IS NOT NULL
GROUP BY 
	d.director
ORDER BY 
	d.director


--19.	Which country has highest number of comedy movies?
--20.	For each year, which director has maximum number of movies released
--21.	What is the average running length of movies in each genre?
--22.	List directors who have directed both comedies and horror films.
--23.	List the director's name and the number of horror and comedy films that he or she has directed.
--24.	Find the Most Common Rating for Movies and TV Shows
--25.	Find each year and the average numbers of content release in India on netflix and return top 5 year with highest avg content release!
