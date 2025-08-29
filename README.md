# End To End Analysis For Netflix Dataset Using Microsoft SQL

![Netsoft Logo](https://github.com/oluwatoyint/NetflixDataAnalysisInSQL/blob/main/NetflixLogo.png)

## Overview
This project requires a thorough examination of Netflix's movie and TV show data using SQL. The purpose is to extract relevant insights and answer a variety of (20+) business questions using the dataset. This paper details the project's objectives, business challenges, solutions, findings, and conclusions.
 
## Objectives
 
- Examine the distribution of content types (movies versus television shows).
- Determine the most frequent ratings for films and television shows.
- Organise and analyse content by release year, country, and duration.
- Analyse and categorise information using precise criteria and keywords.
 
## Dataset
 
Though the dataset for this project is sourced from the <a href ='https://www.kaggle.com/datasets'>Kaggle</a> datasets website, but its uploaded here: Netflix_titles.csv
 
 
## Business Problems and Solutions
 
### 1. Display the total Number of Movies vs TV Shows
```sql
SELECT 
	type,
	COUNT(*) count_type
FROM 
	netflix_titles
GROUP BY 
  	type
```
**Objective:** Determine the distribution of content types on Netflix

### 2. 	Count the Number of Content Items in Each Genre
```sql
SELECT 
	Trim(Value) AS genre,  
	COUNT(*) AS total_content  
FROM
	netflix_titles
CROSS APPLY
	string_split (listed_in, ',') 
GROUP BY
	Trim(Value)
```
**Objective:** Count the number of content items in each genre.

### 3.	List All Movies Released in a 2020
```sql
SELECT
	*
FROM
	netflix_titlesCopy
WHERE
	Type = 'Movie'
	AND Release_Year = 2020
```
**Objective:** Retrieve all movies released in a specific year.

### 4.	Find the Top 5 Countries with the Most Content on Netflix
```sql
SELECT Top(5) 
	* 
FROM
	(
		SELECT 
		Trim(Value) AS country,  
		COUNT(*) AS total_content  
		FROM 
  			netflix_titles
		CROSS APPLY 
  			string_split (country, ',') 
		GROUP BY 
  			Trim(Value)

		) AS temp
WHERE
	country IS NOT NULL
ORDER BY 
	total_content DESC
```
**Objective:** Identify the top 5 countries with the highest number of content items.

### 5.	Find Content Added in the Last 5 Years
```sql
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	date_added >= DATEADD(Year, -5, GetDate())
```
**Objective:** Identify Content added to data in the last 5 years

### 6.	 All Movies that are Documentaries 
#### Method 1:
```sql
SELECT
	* 
FROM 
	netflix_titlesCopy
WHERE 
	Type='Movie' AND 
	Listed_in LIKE '%Documentaries%'
```

#### Method 2: Using the normalized tables
```sql
SELECT 
	ntc.*, 
	nli.listed_in 
FROM 
	netflix_titlesCopy ntc
JOIN 
	netflix_listed_in nli ON ntc.show_id = nli.show_id
WHERE 
	nli.Listed_in = 'Documentaries'
```
**Objective:** Identify the movies that are documentaries

### 7. Find All Content Without a Director. Note In Director column Null was replaced with NA
#### Method 1:
```sql
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE director ='NA'
```
#### Method 2:
```sql
SELECT 
	ntc.*, 
	nd.director 
FROM 
	netflix_titlesCopy ntc
JOIN 
	netflix_director nd ON ntc.show_id = nd.show_id
WHERE 
	nd.director = 'NA'
```
**Objective:** Identify the content without Director(s)

### 8.	Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
#### Method 1:
```sql
 SELECT 
	* 
FROM 
	netflix_titlesCopy
 WHERE 
	Type='Movie' 
	AND cast LIKE '%Salman Khan%' 
	AND release_year > YEAR(GetDate()) - 10
```
#### Method 2: For normalized Cast table
 ```sql
SELECT 
	ntc.*, 
	nc.cast 
FROM 
	netflix_titlesCopy ntc
JOIN 
	netflix_cast nc ON ntc.show_id = nc.show_id
WHERE nc.cast= 'Salman Khan' 
AND  ntc.release_year > YEAR(GetDate()) - 10
```
**Objective:** Identify How Many Movies Actor 'Salman Khan' featured in the Last 10 Years

### 9.	Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
```sql
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
```
**Objective:** Identify The Top 10 Actors who have appeared in the highest number of Movies produced in India

### 10.	Categorize the content based on the presence of the keyword 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
 
```sql 
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
		Category     
```

**Objectives:** Identify productions that contain the words 'kill' and 'violence' and label them as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

### 11.	Identify the Longest Movie
**Example:** This example is to illustrate What 'value' signifies when using string_split
```sql
SELECT 
	value from string_split('113 min',' ')
```
**Result:** The result is 113 since the delimiter here is space
****Solution to Question 11:****
```sql
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
```
