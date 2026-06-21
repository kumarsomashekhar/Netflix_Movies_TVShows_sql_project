📺 Netflix Movies and TV Shows Data Analysis using SQL

![Netflix Logo](https://github.com/kumarsomashekhar/Netflix_Movies_TVShows_sql_project/blob/main/Netflix-Logo.webp)

# 📋 Overview  
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

# 🎯 Objectives
Analyze the distribution of content types (movies vs TV shows)

Identify the most common ratings for movies and TV shows

Determine top contributing countries for Netflix content

Analyze content trends over time (release years, date added)

Identify top directors and actors

Explore and categorize content based on specific criteria and keywords

Analyze genre evolution and growth patterns

## 📊 Dataset
The data for this project is sourced from the Kaggle dataset:

Dataset Link: [Netflix Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows)

## 📁 Schema
```sql
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix (
    show_id      VARCHAR(6),
    type         VARCHAR(10),
    title        VARCHAR(150),
    director     VARCHAR(208),
    casts        VARCHAR(1000),
    country      VARCHAR(150),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(10),
    listed_in    VARCHAR(100),
    description  VARCHAR(250)
);
```
## 🔍 Business Problems and Solutions
### 1. Count the Number of Movies vs TV Shows
```sql
SELECT 
    type,
    COUNT(type) AS total_count
FROM netflix
GROUP BY type;
```
#### Objective: Determine the distribution of content types on Netflix.

### 2. Top 10 Countries with Most Content
```sql
SELECT
    country,
    COUNT(*) AS total_titles
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_titles DESC
LIMIT 10;
```
#### Objective: Identify which countries contribute the highest number of titles to Netflix.

### 3. Most Common Rating for Movies and TV Shows
```sql
SELECT 
    type,
    rating,
    rating_count
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
) AS t1
WHERE ranking = 1;
```
#### Objective: Identify the most frequent rating for each content type.

### 4. Recent Content Analysis
```sql
-- Movies Released After 2020
SELECT *
FROM netflix
WHERE type = 'Movie' 
AND release_year >= 2020;

-- Content Added in Last 5 Years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```
#### Objective: Analyze recent content additions and releases.

### 5. Top 10 Contributing Countries (Handling Multiple Countries)
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
    COUNT(show_id) AS total_count
FROM netflix 
GROUP BY UNNEST(STRING_TO_ARRAY(country, ','))
ORDER BY total_count DESC 
LIMIT 10;
```
#### Objective: Identify top countries when multiple countries are listed per title.

### 6. Longest Movies
```sql
SELECT 
    title,
    duration
FROM netflix
WHERE type = 'Movie'
AND duration IS NOT NULL
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC
LIMIT 10;
```
#### Objective: Find movies with the longest duration.

### 7. Most Influential Directors
```sql
WITH directors AS (
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS director_name
    FROM netflix
    WHERE director IS NOT NULL
)
SELECT
    director_name,
    COUNT(*) AS total_titles,
    RANK() OVER(ORDER BY COUNT(*) DESC) AS director_rank
FROM directors
GROUP BY director_name
ORDER BY director_rank 
LIMIT 10;
```
#### Objective: Identify top 10 directors with most content on Netflix.

### 8. TV Shows with More Than 5 Seasons
```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
AND SPLIT_PART(duration, ' ', 1)::NUMERIC > 5;
```
#### Objective: List all TV shows with more than 5 seasons.

### 9. Content Distribution by Genre
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(show_id) AS total_counts
FROM netflix
GROUP BY UNNEST(STRING_TO_ARRAY(listed_in, ','))
ORDER BY total_counts DESC;
```
#### Objective: Count the number of content items in each genre.

### 10. India Content Release Analysis
```sql
SELECT
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(*) AS total_releases,
    ROUND(
        COUNT(*)::NUMERIC / 
        (SELECT COUNT(*) FROM netflix WHERE country = 'India')::NUMERIC * 100, 
        2
    ) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY'))
ORDER BY avg_content_per_year DESC;
```
#### Objective: Calculate average content releases by India per year and return top years.

### 11. Documentaries
```sql
SELECT * 
FROM netflix
WHERE listed_in ILIKE '%documentaries';
```
#### Objective: List all movies that are documentaries.

### 12. Content Without Director
```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```
#### Objective: Find all content without a director listed.

### 13. Genre Evolution Over Time
```sql
WITH genre_data AS (
    SELECT
        release_year,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
    FROM netflix
)
SELECT
    release_year,
    genre,
    COUNT(*) AS total_titles
FROM genre_data
GROUP BY release_year, genre
ORDER BY release_year DESC;
```
#### Objective: Analyze how genres have evolved over time.

### 14. Genre Growth Analysis
```sql
WITH genre_yearly AS (
    SELECT
        release_year,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
    FROM netflix
),
genre_counts AS (
    SELECT
        release_year,
        genre,
        COUNT(*) AS total_titles
    FROM genre_yearly
    GROUP BY release_year, genre
)
SELECT
    release_year,
    genre,
    total_titles,
    total_titles - LAG(total_titles) OVER(PARTITION BY genre ORDER BY release_year) AS yoy_growth
FROM genre_counts
ORDER BY genre, release_year;
```
#### Objective: Identify which genres are growing fastest year-over-year.

### 15. Genre Growth Percentage
```sql
WITH genre_yearly AS (
    SELECT
        release_year,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
    FROM netflix
),
genre_counts AS (
    SELECT
        release_year,
        genre,
        COUNT(*) AS total_titles
    FROM genre_yearly
    GROUP BY release_year, genre
)
SELECT
    release_year,
    genre,
    total_titles,
    ROUND(
        (total_titles - LAG(total_titles) OVER(PARTITION BY genre ORDER BY release_year)) * 100.0 /
        NULLIF(LAG(total_titles) OVER(PARTITION BY genre ORDER BY release_year), 0),
        2
    ) AS growth_percent
FROM genre_counts
ORDER BY genre, release_year;
```
#### Objective: Calculate percentage growth for each genre year-over-year.

## 📈 Key Findings
#### Metric	Insight
Content Distribution: The dataset contains a balanced mix of movies and TV shows
Top Country	United States leads in content production
Common Ratings	TV-MA and TV-14 are the most common ratings
Recent Content: Significant increase in content added post-2020
Genre Trends: Documentaries, Stand-up Comedy, and International shows are growing
Directors: Top directors have multiple shows/movies on Netflix
Content Quality	No director listed in a significant portion of content

## 📝 Key SQL Techniques Used
Technique	Description
Window Functions: RANK(), LAG() for advanced analytics
Array Functions: UNNEST(), STRING_TO_ARRAY() for handling delimited data
String Functions: SPLIT_PART(), TRIM() for data cleaning
Subqueries: Common Table Expressions (CTEs) for complex analysis
Conditional Logic: CASE statements for categorization
Date Functions: TO_DATE(), EXTRACT() for temporal analysis

## Reference
youtube - Zero Analyst
Creator - Najir H

