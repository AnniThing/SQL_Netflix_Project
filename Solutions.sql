-- Netflix Project
create table netflix (
  show_id VARCHAR(6),
  type	VARCHAR(25),
  title	VARCHAR(150),
  director	VARCHAR(208),
  casts	VARCHAR(1000),
  country	VARCHAR(150),
  date_added VARCHAR(50),
  release_year	INT,
  rating	VARCHAR(20),
  duration	VARCHAR(15),
  listed_in	VARCHAR(80),
  description VARCHAR(250)
);

SELECT * FROM netflix

SELECT COUNT(*) as total_content
FROM netflix;

--Questions

--1. Count the number of Movies vs TV Shows

 SELECT type, COUNT(*) as total_Number
   FROM netflix
   GROUP BY type;

--2. Find the most common rating for movies and TV shows

SELECT
  type,
  rating
  FROM
  (
    SELECT
    type, rating,
    count(*),
    RANK()OVER(PARTITION BY type ORDER BY COUNT(*) DESC)AS ranking
    FROM netflix
    GROUP BY 1,2
  ) AS t1
 WHERE ranking = 1;



--3. List all movies released in a specific year (e.g., 2018)

SELECT * FROM netflix
WHERE release_year = 2018 AND type = 'Movie';

--4. Find the top 5 countries with the most content on Netflix

SELECT 
UNNEST(STRING_TO_ARRAY(country, ','))as new_country,
COUNT(show_id) as total_content 
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--5. Identify the longest movie

SELECT title, duration
FROM netflix
WHERE type = 'Movie'
 AND duration IS NOT NULL
ORDER BY 2 DESC;

--6. Find content added in the last 5 years

SELECT *,
TO_DATE(date_added, 'Month DD,YYYY') AS date
FROM netflix
WHERE TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

--8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE type = 'TV Show' 
AND 
SPLIT_PART(duration, ' ',1):: numeric  > 5 ;

--9. Count the number of content items in each genre

SELECT 
UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
COUNT(show_id) AS Total_content
FROM netflix
GROUP BY 1;

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
    COUNT(show_id)::numeric /
    (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

--11. List all movies that are documentaries

SELECT * FROM netflix
WHERE type = 'Movie' 
AND listed_in LIKE '%Documentaries%';

--12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE casts LIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
UNNEST(STRING_TO_ARRAY(casts, ','))as cast,
COUNT(*) as total_count
FROM netflix
WHERE country LIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 10;

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

WITH updated_table
AS(
SELECT *,
  CASE
  WHEN
   description LIKE '%kill%' 
  OR
  description LIKE '%violence%'
  THEN 
   'Bad'
  ELSE
   'Good'
  END Category 
FROM netflix
)
 SELECT
  Category,
  COUNT(*) as total_content
   FROM updated_table
   GROUP BY 1;
