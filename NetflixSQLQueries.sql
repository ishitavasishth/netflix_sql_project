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
		