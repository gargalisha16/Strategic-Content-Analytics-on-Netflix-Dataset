-- Netflix Project
CREATE TABLE netflix(
	show_id VARCHAR(10),
	type VARCHAR(10),
	title VARCHAR(110),
	director VARCHAR(210),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added DATE,
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	genre VARCHAR(30),
	description VARCHAR(260),
	movie_duration_min INT,
	tv_show_seasons INT,
	year_added INT
);

SELECT * FROM netflix;
SELECT COUNT(*) FROM netflix; --25884

-- question 1: How many titles are there in total?
-- Use Case: Gives a high-level overview of the dataset size.
SELECT COUNT(DISTINCT show_id) as total_titles FROM netflix;

-- question 2: How many movies and TV shows are there separately?
-- Use Case: Helps analyze the content type distribution on the platform- useful for understanding the platform’s format preference.
SELECT type, COUNT(DISTINCT show_id) FROM netflix GROUP BY type;
-- the presence of year 0 in output means that some rows in table have NULL values.

-- question 3: Which are the top 10 countries with the highest number of titles?
-- Use Case: Helps identify which countries contribute the most content, useful for content sourcing strategy, regional licensing and market strength analysis.
SELECT country, COUNT(DISTINCT show_id) FROM netflix GROUP BY country HAVING COUNTRY IS NOT NULL ORDER BY COUNT(DISTINCT show_id) DESC LIMIT 10;

-- question 4: Which are the top 10 most common genres on the platform?
-- Use Case: Helps identify dominant content themes and user preferences- useful for content planning, recommendation systems, and editorial focus.
SELECT genre, COUNT(DISTINCT show_id) FROM netflix GROUP BY genre ORDER BY COUNT(DISTINCT show_id) DESC LIMIT 10;

-- question 5: Which directors have directed the most titles on the platform?
-- Use Case: Identifies the most prolific directors featured on the platform- valuable for content promotion, partnerships, and analyzing creator influence.
SELECT director, COUNT(DISTINCT show_id) FROM netflix GROUP BY director HAVING DIRECTOR IS NOT NULL ORDER BY COUNT(DISTINCT show_id) DESC LIMIT 5;

-- question 6: Which are the top 10 most frequent combinations of type and genre on the platform?
-- Use Case: Helps understand which content formats (Movie/TV Show) are most associated with specific genres- useful for analyzing popular format-genre pairings and guiding future content development.
SELECT type, genre, COUNT(DISTINCT show_id) FROM netflix GROUP BY type, genre ORDER BY COUNT(DISTINCT show_id) DESC LIMIT 10;

-- question 7: How many titles were added each month over the years?
-- Use Case: Helps identify seasonal patterns in content addition- useful for scheduling releases, trend forecasting and content acquisition strategy.
SELECT EXTRACT(YEAR FROM date_added) as year, EXTRACT(MONTH FROM date_added) as month, COUNT(DISTINCT show_id) FROM netflix GROUP BY year, month ORDER BY year DESC, month DESC;

-- question 8: What is the average duration of movies, grouped by genre?
-- Use Case: Helps understand which genres tend to have longer or shorter runtimes- useful for content planning, recommendation logic and understanding user engagement patterns.
SELECT genre, AVG(movie_duration_min) FROM netflix where type= 'Movie' GROUP BY genre ORDER BY AVG(movie_duration_min) DESC;

-- question 9: Which genres are most commonly associated with TV Shows?
-- Use Case: Helps determine what kinds of genres are most frequently delivered in an episodic format- valuable for understanding long-form content trends and user engagement patterns.
SELECT genre, COUNT(DISTINCT show_id) FROM netflix WHERE type= 'TV Show' GROUP BY genre ORDER BY COUNT(DISTINCT show_id) DESC LIMIT 5;

-- question 10: What is the distribution of TV Shows by number of seasons?
-- Use Case: Helps analyze how long-running the platform’s TV content typically is- useful for understanding bingeability, viewer retention strategy, and production trends.
SELECT title, tv_show_seasons FROM netflix WHERE type= 'TV Show' ORDER BY tv_show_seasons DESC; 

-- question 11: How many titles are there for each content type (Movie vs TV Show) over the years?
-- Use Case: Analyzes how the platform’s focus has shifted between Movies and TV Shows across years- useful for spotting consumption trends.
SELECT EXTRACT(YEAR FROM date_added), type, COUNT(DISTINCT show_id) FROM netflix WHERE EXTRACT(YEAR FROM date_added) IS NOT NULL GROUP BY EXTRACT(YEAR FROM date_added), type ORDER BY EXTRACT(YEAR FROM date_added) DESC;

-- question 12: What is the average number of seasons for TV Shows in each genre?
-- Use Case: Reveals how long TV content typically runs in each genre- useful for planning series length, analyzing content depth and viewer retention strategies.
SELECT genre, ROUND(AVG(tv_show_seasons), 2) FROM netflix WHERE type= 'TV Show' AND tv_show_seasons IS NOT NULL AND tv_show_seasons NOT IN(0) GROUP BY genre ORDER BY ROUND(AVG(tv_show_seasons), 2);

-- question 13: Which genres have the highest number of movies?
-- Use Case: Identifies the most dominant genres in the movie segment- useful for analyzing viewer demand, content inventory and recommendation engine training.
SELECT genre, COUNT(DISTINCT show_id) FROM netflix WHERE type= 'Movie' GROUP BY genre ORDER BY COUNT(DISTINCT show_id) DESC LIMIT 5;

-- question 14: Which movies are longer than the average movie duration on Netflix?
-- Use Case: Helps highlight above-average length movies, useful for analyzing long-form content, audience attention span or special-feature content strategy.
SELECT DISTINCT show_id, title FROM netflix WHERE type= 'Movie' AND movie_duration_min!= 0 AND movie_duration_min IS NOT NULL AND movie_duration_min> (SELECT AVG(movie_duration_min) FROM netflix WHERE type= 'Movie' AND movie_duration_min!= 0 AND movie_duration_min IS NOT NULL) ORDER BY show_id;

-- question 15: Which director–genre pairs are most common across the platform?
-- Reveals the preferred creative focus areas of top directors- useful for identifying specialization patterns and content strategy alignment.
SELECT director, genre, COUNT(DISTINCT show_id) FROM netflix WHERE director IS NOT NULL AND genre IS NOT NULL GROUP BY director, genre ORDER BY COUNT(DISTINCT show_id) DESC;

-- question 16: What percentage of titles were added to Netflix in the same year they were released, versus later?
-- Use Case: Helps measure how much Netflix content is new vs old, supporting decisions on licensing speed and content freshness.
SELECT 
CASE
	WHEN year_added IS NULL OR release_year IS NULL THEN 'not available'
	WHEN year_added= release_year THEN 'same'
	ELSE 'not same'
END AS added_status, 
COUNT(DISTINCT show_id)
FROM netflix GROUP BY added_status;

-- question 17: How many movies fall into each duration category: Short, Medium, or Long?
-- Use Case: Helps analyze how Netflix segments its movie content by length- useful for content planning and audience targeting.
SELECT
CASE
	WHEN movie_duration_min IS NULL OR movie_duration_min= 0 THEN 'not-available'
	WHEN movie_duration_min<=60 THEN 'short'
	WHEN movie_duration_min BETWEEN 61 AND 90 THEN 'medium'
	ELSE 'long'
END AS movie_duration_status,
COUNT(DISTINCT show_id)
FROM netflix WHERE type= 'Movie' GROUP BY movie_duration_status ORDER BY COUNT(DISTINCT show_id);

-- question 18: How is the content rating distributed across Movies and TV Shows?
-- Use Case: Helps understand which age group (Kids, Teens, Adults) each content type targets- valuable for audience strategy and parental controls.
SELECT type,
CASE
	WHEN rating IN('TV-Y', 'TV-Y7', 'G') THEN 'Kids'
	WHEN rating IN('PG', 'TV-PG', 'TV-Y7-FV') THEN 'Teens'
	WHEN rating IN('PG-13', 'TV-14') THEN 'Young Adults'
	WHEN rating IN('R', 'NC-17', 'TV-MA') THEN 'Adults'
	ELSE 'Unknown'
END AS 	age_group,
COUNT(DISTINCT show_id)
FROM netflix GROUP BY type, age_group;
