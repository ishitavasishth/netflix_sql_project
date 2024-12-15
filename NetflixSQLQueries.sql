 --double checking on the dataset being imported properly
 select * from netflix;

--double checking on the total count for cross verification
select count(*) from netflix; 


-- How many different types of of content do we have in the dataset?
select count(distinct type)
from netflix;

-- 2 types, let's see which are those?

select distinct type
from netflix;
--movies and TV Shows

---Let's solve 15 Business Problems I plan to cater in the Project!

--1. Count the number of Movies and TV Shows in the Dataset

select type, count(show_id) as Total_Number
from netflix
group by type; 
-- It shows we have 6131 Movies and 2676 TV Shows in the dataset which totals to 
--8807(Total) number of rows in the dataset

--2. Find the Most Common Rating for Movies and TV Shows

select type, 
rating,
count(*)
from netflix
group by type, rating
order by type, count(*) desc;

-- This code stacked the data by Type(TV and Movie Shows)
--We can see Movie has TV-MA ranked highest and for TV Show TV-MA ranked highest again


--3. List all movies released in a specific year(eg, 2020)
select type, title, release_year
from netflix
where (type = 'Movie') and (release_year = 2020); 

-- The resulting table helped me sort all the movies for 2020 using a simple filter and function combination

---4. Find the top 5 countries with the most content on Netflix

select country, count(show_id) as Total_Content
from netflix
group by country
order by count(show_id) desc
limit 5;

--I can see the data is not clean and requires cleaning attention

select country
from netflix; --- Multiple countries are grouped together and are required to be delimited by comma

select unnest(string_to_array(country, ',')) as new_country
from netflix; 

-- rerunning the query to understand if it works- after splitting basis the comma

select unnest(string_to_array(country, ',')) as new_country,
count(show_id) as Total_Content
from netflix
group by new_country
order by count(show_id) desc
limit 5;

-- Top 5 countries therefore are US, India, UK, US Again and Canada

--5. Identify the longest movie 

--I know the duration column is listed as 'text' hence to keep that in mind

select *
from netflix
where 
type = 'Movie'
and
duration = (Select max(duration) from netflix);
-- this query helped filter out and arrange the query starting from the max which was 99 minutes


--6. Find all the movies/TV Shows by Director = 'Rajiv Chilaka';

select *
from netflix;

select title, type, director
from netflix
where director Ilike '%Rajiv Chilaka%';
--22 movies directed by Rajiv, a like and % option let's me filter all rows where
-- his name is mentioned separately and with someone!!
-- sometimes, a couple of people direct the movie, hence like helped

--7. List TV all show with more than 5 seasons
--Objective: Identify TV shows with more than 5 seasons.
select 
*,
split_part(duration, ' ', 1) as Seasons 
from netflix
where type = 'TV Show' and 
split_part(duration, ' ', 1):: numeric > 5;

-- used split part function, subtract the number and convert that into numeric


--8. Count the number of content items in each genre

select 
unnest(string_to_array(listed_in, ',')) as Genre,
count(show_id) as Total_Records
from netflix
group by 1;
--This gives a clear view of content items without any duplication basis genre!

--9. Find each year and the average numbers of content release in India on netflix
SELECT 
    country,
    release_year, 
	count(show_id) as Total_Records, 
	ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) as average_release
	from netflix
	where country like  '%India%'
	group by country, release_year
	order by average_release desc
	limit 5;

	--This shows 2017 was the release_year for India that had the maximym average release!


	--10. List all the movies that are Documentaries

	select * from netflix;

	select title, type, listed_in
	from netflix
	where type = 'Movie' and
	listed_in ilike '%Documentaries%';

	---Total such enteries are 869 which have Documentaries!

	--11. All content without a Director

	select *
	from netflix
	where director is null;

	-- such are 2634 in total!!

--12. How many movies Actor 'Salman Khan' appeared in last 10 years

select *
from netflix
where casts ilike '%Salman Khan%' and
release_year > extract(year from current_date) - 10;

--Two records show the movie and the details!!

--13. Top 10 actors who appeared in the highest number of movies produced in India
select show_id, casts, unnest(string_to_array(casts, ','))
from netflix; ---All casts are now delimieted because of the function above


select 
unnest(string_to_array(casts, ',')) as Actors,
count(*) as Total_Content
from netflix
where country ilike '%India%'
group by 1 
order by 2 desc
limit 10; 

-- This helped us understand Anupam, Om... and so on are the top 10 Actors basis the number of films!


--14. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

With new_table
as
(select *,
case 
when description ilike '%kill%' or
description ilike '%violence%'
then 'Bad_Content'
else 'Good_Content'
end Category
from netflix)
select category,
count(*) as Total_Records
from new_table
group by 1;


---This shows Bad_Content is 342 and Good_Content is 8465

	--15.  Determine the average duration of movies across all countries
--Objective: Understand global trends in the average length of movies

select country, 
avg(cast(split_part(duration, ' ', 1) as Integer)) as Average_Duration
from netflix
where type = 'Movie' and country is not null
group by 1
order by 2 desc;

---16. Identify countries producing the highest number of TV shows

--Objective: Understand the geographic distribution of TV show production

select *
from netflix;

select country, count(title) as Distribution_Count
from netflix
where type = 'TV Show' and country is not null
group by country
order by count(title) desc;
--US has the highest number of TV Show Productions


--17. Identify the oldest content still available on Netflix
-- Objective: Find the oldest movie or TV show in the library
select * from netflix;

select title, type, min(release_year)
from netflix
group by title, type
order by min(release_year) asc;

-- This shows TV Show titled 'Pioneers: First Women Filmmakers' is the oldest released in 1925


--18. Determine the director with the highest average IMDb-equivalent rating
--Objective: Evaluate which director consistently delivers highly-rated content
drop table user_activity;

CREATE TABLE user_activity (
    user_id SERIAL PRIMARY KEY,
    show_id VARCHAR,
    watch_time_minutes INT,
    rating FLOAT,
    watch_date DATE
);


SELECT *
FROM netflix
WHERE show_id IN (SELECT show_id FROM user_activity);


SELECT n.show_id AS Netflix_Show_ID, ua.show_id AS UserActivity_Show_ID
FROM netflix n
FULL OUTER JOIN user_activity ua 
ON n.show_id = ua.show_id
WHERE n.show_id IS NULL 
OR 
ua.show_id IS NULL;

INSERT INTO user_activity (show_id, watch_time_minutes, rating, watch_date)
SELECT 
    show_id, 
    FLOOR(RANDOM() * 200 + 1) AS watch_time_minutes, -- Random watch time
    ROUND(CAST((RANDOM() * 5) AS NUMERIC), 1) AS rating, -- Random ratings between 0 and 5
    CURRENT_DATE - CAST(FLOOR(RANDOM() * 30) AS INTEGER) AS watch_date -- Random watch dates in the last 30 days
FROM netflix
LIMIT 100;

--Finally Running the Query
SELECT 
    n.director, 
    AVG(ua.rating) AS Average_UserRating
FROM netflix n
JOIN user_activity ua
USING (show_id)
WHERE n.director IS NOT NULL
GROUP BY n.director
ORDER BY Average_UserRating DESC;

--Dennis Dugan has the average highest user rating

--19. Track the yearly growth of Netflix's library.

select release_year, count(title) as Total_Titles
from netflix
group by release_year
order by 2 desc
limit 5;

-- NF's library gre the most in 2018,2017, 2019 and 2020

--20. Find the most common combinations of actors appearing together in content
--Objective: Analyze frequently recurring actor pairings in titles

-- Step 1: Split `casts` into arrays and generate all actor pairs
-- Step 1: Create actor pairs from the `casts` column
-- Step 1: Create actor pairs from the `casts` column
WITH ActorPairs AS (
    SELECT 
        actor1.title AS Title, -- Specify `title` from actor1 to resolve ambiguity
        LEAST(actor1.actor, actor2.actor) AS Actor1,
        GREATEST(actor1.actor, actor2.actor) AS Actor2
    FROM (
        SELECT title, unnest(string_to_array(casts, ',')) AS actor
        FROM netflix
        WHERE casts IS NOT NULL
    ) actor1
    CROSS JOIN (
        SELECT title, unnest(string_to_array(casts, ',')) AS actor
        FROM netflix
        WHERE casts IS NOT NULL
    ) actor2
    WHERE actor1.title = actor2.title AND actor1.actor < actor2.actor
)
SELECT 
    Actor1,
    Actor2,
    COUNT(*) AS PairFrequency
FROM ActorPairs
GROUP BY Actor1, Actor2
ORDER BY PairFrequency DESC
LIMIT 10;


---Julie and Rupa Bhimani have the highest pair frequency!

--21-Identify content aimed at children based on keywords

--Objective: Understand the prevalence of children's content in Netflix’s library.
select count(title) as count_title,
case 
when description ilike '%kid%' then 'Kid_Content'
when description ilike '%family%' then 'Kid_Content'
when description ilike '%animated%' then 'Kid_Content'
else 'Other_Content'
end as Description_Type
from netflix
group by 2
order by 2;

---This shows the Kid Content when made case when statements!

--22.Analyze the seasonal trend in content releases

--Objective: Identify which months of the year see the highest number of releases

SELECT 
    release_year, 
    EXTRACT(MONTH FROM TO_DATE(date_added, 'DD-Mon-YY')) AS Month
FROM netflix
WHERE date_added ~ '^[0-9]{2}-[A-Za-z]{3}-[0-9]{2}$';

UPDATE netflix
SET date_added = NULL
WHERE NOT date_added ~ '^[0-9]{2}-[A-Za-z]{3}-[0-9]{2}$';

-- running to see the actual query again
    select 
	type, 
	count(release_year), 
    EXTRACT(MONTH FROM TO_DATE(date_added, 'DD-Mon-YY')) AS Month
FROM netflix
WHERE date_added IS NOT NULL
group by 1,3
ORDER BY 2 DESC;

--23. Identify movies with the most diverse production teams.

--Objective: Analyze the number of directors or casts listed for a single title

select title, count(*) as count_directors
from 
(select title, unnest(string_to_array(director, ',')) as director_name
from netflix
where type = 'Movie' and director is not null) as subquery
group by title
order by 2 desc;

-- This shows maximum directors have accounted for "Walt Disney Animation Studios Short Films Collection"

--24. Measure the percentage of content with no release date

select type,  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix) AS percentage_of_content
from netflix 
where date_added is null
group by 1;

--Out of the null dates- the breakup is Movie ~31.8% and TV Show ~12.41%


--25. Find the genres with the most titles directed by women
--Objective: Analyze which genres have the highest representation of women directors
WITH FemaleDirectors AS (
    SELECT 
        title,
        unnest(string_to_array(listed_in, ',')) AS genre,
        director
    FROM netflix
    WHERE 
        director ILIKE ANY (ARRAY['%Jane Campion%', '%Sofia Coppola%', '%Kathryn Bigelow%', '%Greta Gerwig%'])
),
GenreCount AS (
    SELECT 
        genre, 
        COUNT(title) AS Total_Titles
    FROM FemaleDirectors
    GROUP BY genre
)
SELECT 
    genre, 
    Total_Titles
FROM GenreCount
ORDER BY Total_Titles DESC;

--Females have produced 'Independent Movies' the most out of the lot


--26. Identify the most common keywords in Netflix descriptions
--Objective: Find recurring themes or topics in content descriptions
WITH CleanedDescriptions AS (
    SELECT 
        unnest(string_to_array(
            regexp_replace(lower(description), '[^a-z0-9 ]', '', 'g'), 
            ' '
        )) AS keyword
    FROM netflix
    WHERE description IS NOT NULL
),
FilteredKeywords AS (
    SELECT 
        keyword
    FROM CleanedDescriptions
    WHERE keyword NOT IN (
        'the', 'and', 'of', 'to', 'in', 'a', 'is', 'for', 'on', 'this', 'with', 
        'it', 'that', 'as', 'an', 'by', 'from', 'at', 'be', 'about', 'or'
    )
),
KeywordCounts AS (
    SELECT 
        keyword, 
        COUNT(*) AS frequency
    FROM FilteredKeywords
    GROUP BY keyword
)
SELECT 
    keyword, 
    frequency
FROM KeywordCounts
ORDER BY frequency DESC
LIMIT 10;
-- top 10 keywords with 'his' being the most popular




--27.  Compare content availability in multiple countries
--Find titles available in the highest number of countries
WITH SplitCountries AS (
    SELECT 
        title, 
        unnest(string_to_array(country, ',')) AS individual_country
    FROM netflix
    WHERE country IS NOT NULL
)
SELECT 
    title, 
    COUNT(DISTINCT individual_country) AS unique_country_count
FROM SplitCountries
GROUP BY title
ORDER BY unique_country_count DESC, title;


