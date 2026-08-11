
--NETFLIX DATA ANALYSIS 

USE new;
GO 

SELECT * FROM netflix_titles;

--DATA VALIDATION AND CLEANING 

SELECT COUNT(*) AS DATA 
FROM netflix_titles;


--CHECK for null values 
 
 SELECT  
 SUM(CASE WHEN type IS NULL THEN 1 ELSE 0 END ) AS null_type,  
 SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END ) AS null_director , 
 SUM(CASE WHEN cast IS NULL THEN 1 ELSE 0 END) AS null_cast  ,
 SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS null_country,
 SUM(CASE WHEN date_added IS NULL THEN 1 ELSE 0 END) AS null_date_ad,
 SUM(CASE WHEN release_year IS NULL THEN 1 ELSE 0 END) AS null_rel_yr,
 SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
  SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS null_dur,
   SUM(CASE WHEN listed_in IS NULL THEN 1 ELSE 0 END) AS null_list,
 SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS null_description
 FROM netflix_titles ;

--check and remove duplicates 
WITH duplicates AS
(
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY
               type,
               title,
               listed_in,
               director,cast,
               country,
               date_added,
               release_year ,
               rating,
               duration,
               description
    
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM netflix_titles
)
DELETE FROM duplicates
WHERE rn > 1;

--1. Count the number of Movies vs TV Shows\
SELECT type , COUNT(*) AS 
category  
FROM netflix_titles
GROUP BY type ;

--2. Find the most common rating for movies and TV shows
WITH rate AS (
   SELECT
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix_titles
    
    GROUP BY type, rating
    ),
    rate_rank AS 
    (
    SELECT 
    type,
        rating,
         rating_count,
         RANK() OVER 
         (
         PARTITION BY  type  
         ORDER BY rating_count DESC 
         )AS rn 
         FROM rate 
         )
         SELECT 
         type,
         rating,
         rating_count
         FROM rate_rank
         WHERE rn =1;
----3. List all movies released in a specific year (e.g., 2020)

SELECT release_year ,
COUNT(*) AS movies_released 
FROM netflix_titles
WHERE type ='movie'
GROUP BY release_year 
HAVING release_year = 2020;

--4. Find the top 5 countries with the most content on Netflix

SELECT TOP 5 country,
COUNT(*) AS total_content 
 FROM netflix_titles 
 GROUP BY country
 ORDER BY total_content DESC ;


 --5. Identify the longest movie
 
SELECT TOP 1
    title,
    duration
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY CAST(REPLACE(duration, ' min', '') AS INT) DESC;

--6. Find content added in the last 5 years

SELECT  
type,
title, 
date_added
FROM 
netflix_titles
WHERE YEAR(date_added) BETWEEN 2017 AND 2021
ORDER BY YEAR(date_added) DESC ;

SELECT*FROM netflix_titles;

-- 8. List all TV shows with more than 5 seasons

SELECT 
    type,
    title,

   CAST(LEFT(duration,CHARINDEX(' ',duration) -1) AS INT)AS season
   FROM netflix_titles
   WHERE type = 'TV Show'
   AND CAST(LEFT(duration,CHARINDEX(' ',duration) -1) AS INT)>5
   ORDER BY season DESC;
   --9. Count the number of content items in each genre

SELECT listed_in ,COUNT (*)AS content 
FROM netflix_titles 
GROUP  BY listed_in
ORDER BY content ;

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

WITH cont
AS 
(
SELECT 
DATEPART(YEAR,date_added) AS year_added ,
COUNT(*) AS content
FROM netflix_titles
GROUP BY DATEPART(YEAR,date_added)
),
avg_cont
AS (
SELECT year_added,
AVG(content) AS avrg_content 
FROM cont
GROUP BY year_added
)
SELECT TOP 5 
* FROM avg_cont
ORDER BY avrg_content DESC;

--12. Find all content without a director
SELECT 
* FROM 
netflix_titles
WHERE director IS NULL ;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT 
title,
release_year ,
COUNT(*) AS total_movies 
FROM netflix_titles 
WHERE type ='movie'
AND cast LIKE '%salman khan%' 
AND release_year BETWEEN 2011 AND 2021
GROUP BY title,release_year
ORDER BY release_year DESC ;






