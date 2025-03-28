 -- Netflix Data Analysis using SQL
 -- Solutions of 15 business problems



 
 -- 1. Count the number of Movies vs TV Shows

SELECT type,COUNT(*)
FROM netflix
GROUP BY 1

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
	COUNT(*) AS total_content
	FROM netflix
	GROUP BY 1
)AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5

-- 5. Identify the longest movie

SELECT title,duration 
FROM
(SELECT title,duration,SPLIT_PART(duration, ' ', 1)::INT AS new_duration
FROM netflix
WHERE type='Movie' AND duration IS NOT NULL
ORDER BY new_duration DESC LIMIT 1) AS T1

-- 6. Find content added in the last 5 years

SELECT *
FROM netflix 
WHERE TO_DATE(date_added,'Month DD,YYYY') >= (CURRENT_DATE - INTERVAL '5 year')

 -- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM
(SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
FROM netflix ) AS T1
WHERE director_name = 'Rajiv Chilaka'

-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE TYPE = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5

-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
	COUNT(*) AS total_content
FROM netflix
GROUP BY 1

-- 10.Find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release!

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) AS year,
	COUNT(*),
	ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM netflix WHERE country='India') * 100,2) AS avg_by_year
FROM netflix 
WHERE country='India'  
GROUP BY 1

-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in iLIKE '%Documentaries%'

-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *
FROM netflix 
WHERE casts ILIKE '%Salman Khan%'
AND TO_DATE(date_added,'Month DD,YYYY') >= (CURRENT_DATE - INTERVAL '10 year')

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

SELECT 
	catogories,
	COUNT(*) AS total_content
FROM
(SELECT title,
CASE 
	WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
	ELSE 'Good'
END AS catogories
FROM netflix) AS T1 
GROUP BY catogories



-- End of reports