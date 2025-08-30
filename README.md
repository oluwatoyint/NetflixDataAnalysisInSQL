# End To End Analysis For Netflix Dataset Using Microsoft SQL

![Netsoft Logo](https://github.com/oluwatoyint/NetflixDataAnalysisInSQL/blob/main/NetflixLogo.png)

## Overview
This project requires a thorough examination of Netflix's movie and TV show data using SQL. The purpose is to extract relevant insights and answer a variety of (20+) business questions using the dataset. This paper details the project's objectives, business challenges, solutions, findings, and conclusions.
 
## Objectives
 
- Examine the distribution of content types (movies versus television shows).
- Determine the most frequent ratings for films and television shows.
- Organise and analyse content by release year, country, and duration.
- Analyse and categorise information using precise criteria and keywords.
 
## Dataset Sourcing & Cleaning
 
Though the dataset for this project is sourced from the <a href ='https://www.kaggle.com/datasets'>Kaggle</a> datasets website, but its uploaded here: Netflix_titles.csv
The first thing we want to do after the data is downloaded as a csv (flat file) is to import it into Microsoft SQL Server. You must have installed your Microsoft SQL Server 2022 and the Microsoft SQL Server Management Studio 21. 

## Importing the dataset into Microsoft SQL Server 
#### Step 1
Launch your Microsoft SQL Server Management Studio 21 and create a database called Movies
Select New Query from the menu bar and type the sql statement below, after which you click the Execute button on the Menu bar:
```sql
CREATE DATABASE Movies
```
**Objective:** Create the Movies database that will contain the netflix table
#### Step 2
In Microsoft SQL Server Managment Studio right click on the Movies database, select Tasks and Import Flat File from the menus.
Click on Next. 
Then select the netflix.csv file from the location on your computer, give it a table name netflix_titles
Click on Next.
Then preview Click on Next and then we get to the Modify Columns window
#### Step 3: Ensuring that the data is imported without any errors
To do this we make sure all the table columns have the datatype of nvarchar(MAX) and we allow null to all the columns except the show_id which will serve as PRIMARY KEY.
Click on next and finish the import.

![Modify Column](https://github.com/oluwatoyint/NetflixDataAnalysisInSQL/blob/main/Modify.png)

#### Step 4: We now run the SQL code below to identify the maximum column size for the content in each of the columns of the netflix_titles table imported. Select New Query and enter the SQL statements below execute
```sql
USE Movies
 SELECT
	MAX(LEN(show_id)) ShowID,
	MAX(LEN(type)) type,
	MAX(LEN(title)) title,
	MAX(LEN(director))director,
	MAX(LEN(cast)) cast,
	MAX(LEN(country))country,
	MAX(LEN(date_added)) date_added,
	MAX(LEN(release_year)) release_year,
	MAX(LEN(rating))rating,
	MAX(LEN(duration))duration,
	MAX(LEN(listed_in)) listed_in,
	MAX(LEN(description))description
FROM 
	netflix_titles
```
**Objective:** To identifty the maximum column size in each of the columns of the netflix_titles table so we can remodify the datatype sizes of the column. This is for performance optimization.

**Result:** When you execute the code above the result gives the maximum column size of each column in the netflix_titles table which we see in the figure below. Right click on the table netflix_titles and select the design view. Using this view, readjust all the sizes of the datatypes to the value we see in the result.

![Maximum Column Size](https://github.com/oluwatoyint/NetflixDataAnalysisInSQL/blob/main/maximumcolumns.png)

## Dataset Cleaning
### Stage 1: Make a duplicate copy of the netflix_titles named netflix_titlesCopy by using the SQL statements below. 

```sql
SELECT
	*
INTO
	netflix_titlesCopy
FROM
	netflix_titles
```
**Objective:** To avoid fatal errors like mistakenly deleting the dataset. It is the professional best practise to first make a duplicate copy of dataset to be analysed.
### Stage 2: Create make the show_id column the Primary Key for the table
```sql
ALTER TABLE 
	netflix_titlesCopy
ADD CONSTRAINT pk_ntc
PRIMARY KEY (show_id)
```
**Objective:** To begin to find duplicates we have to create a primary key for the table. We have chose show_id column because it has no Null values.
### Stage 3: We do a record count, and take note of the total number of records
#### Method 1:
```sql
SELECT
	*
FROM
	netflix_titlesCopy   
```
#### Method 2:
```sql
SELECT
	COUNT(*)
FROM
	netflix_titlesCopy   
```
**Objective:** To identify the original total number of records in the dataset we imported. Here we see it is 8807
### Stage 4: Check for and replace all Null values in the columns of the table netflix_copy with 'NA' (Not Available)
```sql
UPDATE 
	netflix_titlesCopy
SET 
	type='NA' 
WHERE type Is Null

UPDATE 
	netflix_titlesCopy
SET 
	title='NA' 
WHERE title Is Null

UPDATE 
	netflix_titlesCopy
SET 
	director='NA' 
WHERE director Is Null

UPDATE 
	netflix_titlesCopy
SET 
	cast='NA' 
WHERE cast Is Null

UPDATE 
	netflix_titlesCopy
SET 
	country='NA' 
WHERE country Is Null

UPDATE 
	netflix_titlesCopy
SET 
	date_added='NA' 
WHERE date_added Is Null

UPDATE 
	netflix_titlesCopy
SET 
	release_year='NA' 
WHERE release_year Is Null

UPDATE 
	netflix_titlesCopy
SET 
	rating = 'NA' 
WHERE rating Is Null

UPDATE 
	netflix_titlesCopy
SET 
	duration = 'NA' 
WHERE duration Is Null

UPDATE 
	netflix_titlesCopy
SET 
	listed_in = 'NA' 
WHERE listed_in Is Null

UPDATE 
	netflix_titlesCopy
SET 
	description = 'NA' 
WHERE description Is Null
```
**Objective:** To make the table easier to view by identifying and  replacing Null values with 'NA'
### Stage 5: We begin to run several SQL queries to check for duplicate records
```sql
SELECT DISTINCT [type] FROM netflix_titlesCopy
```
**Objective:** To identify if the original total number of records in the dataset we imported. Here we see it is 8807
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
#### Example: This example is to illustrate what 'value' signifies when using string_split
```sql
SELECT 
	value from string_split('113 min',' ')
```
**Result:** The content of value is 113 since the delimiter here is space.
#### Solution to Question 11:
```sql
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
**Objective:** To Identify record with the longest movie duration.

### 12.	Find All Movies/TV Shows by Director 'Rajiv Chilaka'
#### Solution Stage 1: The first thing we need to do is to normalize the table netflix_TitlesCopy and create Director Table 
```sql
SELECT 
	show_id, 
	TRIM(value) as director
INTO 
	netflix_director
FROM 
	netflix_titlesCopy
CROSS APPLY 
	string_split(director,',')
```
#### Method 1: Using LIKE on the unnormalized table and IN
```sql
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	Type IN ('Movie', 'TV Show') 
	AND Director LIKE '%Rajiv Chilaka%'
```
#### Method 2:
```sql
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	Director LIKE '%Rajiv Chilaka%'
```
#### Method 3: Using JOIN to connect the netflix_titlesCopy table with the netflix_director table obtained by using CROSS APPLY and string_split function
```sql
SELECT 
	ntf.*, 
	nd.director 
FROM 
	netflix_titlesCopy ntf
JOIN 
	netflix_director nd ON ntf.show_id = nd.show_id
WHERE 
	nd.Director = 'Rajiv Chilaka'
```
**Objective:** To Identify All Movies/TV Shows directed by Director 'Rajiv Chilaka'

### 13.	List All TV Shows with More Than 5 Seasons
```sql
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
```
**Objective:** To Identify and list all TV shows with more than 5 seasons.

### 14.	List content items added after August 20, 2021
#### Method 1:
```sql
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	CAST(date_added as Date) > '2021-08-20'
```
**Explanation:**
- We do not need to do the above if the values in the date column were previously converted to the Date datatype
- Use method 2 below if the date column values have already been formatted with the Date datatype
#### Method 2:
```sql
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	date_added > '2021-08-20'
```
**Objective:** To Identify and list content items added after the date August 20, 2021
### 15.	List movies added to on June 15, 2019
```sql
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	date_added = '2019-06-15' AND type='Movie'
```
**Objective:** To Identify and list movies added on June 15, 2019
### 16.	List content items added in 2021
#### Method 1:
```sql
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	date_added >= '2021-01-01' 
	AND date_added <= '2021-12-31'
``` 
 #### Method 2:
 ```sql
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	date_added BETWEEN '2021-01-01' 
	AND '2021-12-31'
```  
#### Method 3:
```sql
Select 
	*  
FROM 
	netflix_titlesCopy
WHERE 
	date_added LIKE '%2021%'
```
#### Method 4:
```sql
SELECT 
	*
FROM
	netflix_titlesCopy where Year(date_added) = 2021
```
**Objective:** To Identify content added in 2021
### 17.	List movies added in 2021
#### Method 1:
```sql
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	type = 'Movie' 
	AND date_added >= '2021-01-01' 
	AND date_added <= '2021-12-31'
  ```
#### Method 2:
```sql
SELECT 
	* 
FROM 
	netflix_titlesCopy
WHERE 
	type = 'Movie' 
	AND  date_added BETWEEN '2021-01-01' 
	AND '2021-12-31'
```
#### Method 3:
  ```sql
SELECT 
	*  
 FROM 
	netflix_titlesCopy
 WHERE 
	type = 'Movie' 
	AND date_added LIKE '%2021%'
```
#### Method 4:
```sql
SELECT 
	*
FROM 
	netflix_titlesCopy 
WHERE 
	Year(date_added) = 2021 
	AND type='Movie'
 ```
**Objective:** To Identify and list movies added in 2021
