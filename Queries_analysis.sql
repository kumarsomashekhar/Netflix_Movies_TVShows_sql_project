select * from netflix;

select 
	count(*) as total_contents
from netflix;

select Distinct(type) from netflix;

select * from netflix;

--Querie Analysis

-- 1. count the no of movie and tv shows

select type,count(type) from netflix
group by type;

-- 2. Which countries contribute the highest number of titles to Netflix?
SELECT
    country,
    COUNT(*) AS total_titles
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_titles DESC
LIMIT 10;

--3. Which audience ratings dominate Netflix?

select 
type,
rating,
rating_count
from  
(
select 
type,
rating,
count(*) as rating_count,
rank() over(partition by type order by count(*) desc)
as ranking
from netflix
group by type,rating
) as t1
where ranking =1;

--4. How much recent content exists?
--Movies Released After 2020

select * from netflix;

select *
from netflix
where type='Movie' and release_year>=2020;

--5.Which 10 countries contribute the highest number 
--of titles to Netflix?
select 
unnest(STRING_TO_ARRAY(country, ',')) AS new_country,
count(show_id) as total_count
from netflix 
group by unnest(STRING_TO_ARRAY(country, ','))
order by total_count desc limit 10;


--6. Which movies have the longest duration?

select  * from netflix;

select title,
duration
from netflix
where type ='Movie'
and duration is not null
ORDER BY
CAST(
    SPLIT_PART(duration,' ',1)
    AS INTEGER
) DESC
LIMIT 10;


--7. content added in last 5 years

select *
from netflix
where 
to_date(date_added, 'Month DD, YYYY') >=current_date -
Interval '5 years'

--8. Top 10 the most influential directors?
WITH directors AS
(
    SELECT
        TRIM(
            UNNEST(
                STRING_TO_ARRAY(director, ',')
            )
        ) AS director_name
    FROM netflix
    WHERE director IS NOT NULL
)

SELECT
    director_name,
    COUNT(*) AS total_titles,
    RANK() OVER(
        ORDER BY COUNT(*) DESC
    ) AS director_rank
FROM directors
GROUP BY director_name
ORDER BY director_rank limit 10;

--9. All tvshows with seasons > 5

select
* 
from netflix
where
type = 'TV Show'
and 
split_part(duration, ' ',1)::numeric >5

--10.Number of content items in each genre

select 
unnest(string_to_array(listed_in, ',')) as genre,
count(show_id) as total_counts
from netflix
group by unnest(string_to_array(listed_in, ','))
order by total_counts desc;

--11 find each year and the average numbers of content release
--by india on netflix, return top 5 highest avg content release
select * from netflix;

select
extract(year from to_date(date_Added,'Month DD,YYYY')) as year,
count(*),
round(count(*)::numeric / ( select count(*) from netflix where country = 'India')::numeric  * 100,2)
as avg_content_peryear
from netflix
where country = 'India'
group by extract(year from to_date(date_Added,'Month DD,YYYY'))

--12. list all movies that are documentries

select * from netflix
where listed_in ILIKE '%documentaries'

--13th find all content without a director
select * from netflix
where director is null

--14th How have genres evolved over time?
WITH genre_data AS
(
    SELECT
        release_year,
        TRIM(
            UNNEST(
                STRING_TO_ARRAY(listed_in, ',')
            )
        ) AS genre
    FROM netflix
)

SELECT
    release_year,
    genre,
    COUNT(*) AS total_titles
FROM genre_data
GROUP BY
    release_year,
    genre
ORDER BY
    release_year DESC;

--15th. Which genres are growing the fastest?
WITH genre_yearly AS
(
    SELECT
        release_year,
        TRIM(
            UNNEST(
                STRING_TO_ARRAY(listed_in, ',')
            )
        ) AS genre
    FROM netflix
),

genre_counts AS
(
    SELECT
        release_year,
        genre,
        COUNT(*) AS total_titles
    FROM genre_yearly
    GROUP BY
        release_year,
        genre
)

SELECT
    release_year,
    genre,
    total_titles,
    total_titles -
    LAG(total_titles)
    OVER(
        PARTITION BY genre
        ORDER BY release_year
    ) AS yoy_growth
FROM genre_counts
ORDER BY
    genre,
    release_year;

--16th 
WITH genre_yearly AS
(
    SELECT
        release_year,
        TRIM(
            UNNEST(
                STRING_TO_ARRAY(listed_in, ',')
            )
        ) AS genre
    FROM netflix
),

genre_counts AS
(
    SELECT
        release_year,
        genre,
        COUNT(*) AS total_titles
    FROM genre_yearly
    GROUP BY
        release_year,
        genre
)

SELECT
    release_year,
    genre,
    total_titles,
    ROUND(
        (
            total_titles -
            LAG(total_titles)
            OVER(
                PARTITION BY genre
                ORDER BY release_year
            )
        ) * 100.0
        /
        NULLIF(
            LAG(total_titles)
            OVER(
                PARTITION BY genre
                ORDER BY release_year
            ),
            0
        ),
        2
    ) AS growth_percent
FROM genre_counts
ORDER BY
    genre,
    release_year;











































