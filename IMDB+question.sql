USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:



-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT 
    table_name, table_rows
FROM
    INFORMATION_SCHEMA.TABLES
WHERE
    TABLE_SCHEMA = 'imdb' ;


-- Q2. Which columns in the movie table have null values?
-- Type your code below:

SELECT 
    SUM(CASE
        WHEN id IS NULL THEN 1
        ELSE 0
    END) AS Id_nulls,
    SUM(CASE
        WHEN title IS NULL THEN 1
        ELSE 0
    END) AS Title_nulls,
    SUM(CASE
        WHEN year IS NULL THEN 1
        ELSE 0
    END) AS Year_nulls,
    SUM(CASE
        WHEN date_published IS NULL THEN 1
        ELSE 0
    END) AS Date_published_nulls,
    SUM(CASE
        WHEN duration IS NULL THEN 1
        ELSE 0
    END) AS Duration_nulls,
    SUM(CASE
        WHEN country IS NULL THEN 1
        ELSE 0
    END) AS Country_nulls,
    SUM(CASE
        WHEN worlwide_gross_income IS NULL THEN 1
        ELSE 0
    END) AS Worlwide_gross_income_nulls,
    SUM(CASE
        WHEN languages IS NULL THEN 1
        ELSE 0
    END) AS Languages_nulls,
    SUM(CASE
        WHEN production_company IS NULL THEN 1
        ELSE 0
    END) AS Production_company_nulls
FROM
    movie ;

-- Columns country, worlwide_gross_income, languages, production_company have 20,3724,194,528 null values respectively.


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 


-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


-- Number of movies released each year.
SELECT 
    year, COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY year
ORDER BY year ;

-- Number of movies released each month.
SELECT 
    MONTH(date_published) AS month_num,
    COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY MONTH(date_published)
ORDER BY MONTH(date_published) ;

-- Highest number of movies were released in 2017 and highest number of movies is produced in the month of March.

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
 
 
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT 
    year, COUNT(DISTINCT id) AS number_of_movies
FROM
    movie
WHERE
    (country LIKE '%INDIA%'
        OR country LIKE '%USA%')
        AND year = 2019 ; 

-- 1059 movies were produced in the USA or India in the year 2019.

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/


-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT
    genre
FROM
    genre ;

-- 'Drama', 'Fantasy', 'Thriller', 'Comedy', 'Horror', 'Family', 'Romance', 'Adventure', 'Action', 'Sci-Fi', 'Crime', 'Mystery' and  'Others' are the all genre.

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */


-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

WITH ranking AS(
SELECT genre, COUNT(genre) AS number_of_movies,
	RANK() OVER(ORDER BY COUNT(genre) DESC) AS genre_rank
FROM genre
GROUP BY genre
ORDER BY number_of_movies DESC)
SELECT genre, number_of_movies
FROM ranking
WHERE genre_rank=1 ;

-- 'Drama' genre have more than four thousand movies produced. 

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/


-- Q7. How many movies belong to only one genre?
-- Type your code below:

-- Using genre table to find movies which belong to only one genre
-- Grouping rows based on movie id and finding the distinct number of genre each movie belongs to
-- Using the result of CTE, we find the count of movies which belong to only one genre

WITH movies_with_one_genre
     AS (SELECT movie_id
         FROM   genre
         GROUP  BY movie_id
         HAVING Count(DISTINCT genre) = 1)
SELECT Count(*) AS one_genre_movies
FROM   movies_with_one_genre ; 

-- 3289 movies belong to only one genre.

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/


-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    genre, ROUND(AVG(duration), 2) AS avg_duration
FROM
    genre AS gen
        INNER JOIN
    movie AS mov ON gen.movie_id = mov.id
GROUP BY genre
ORDER BY AVG(duration) DESC ;

-- Action genre has the highest duration of 112.88 mins followed by romance and crime genres.

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/


-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH genre_ranking AS
(
	SELECT genre, COUNT(movie_id) AS movie_count,
			DENSE_RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS genre_rank 
	FROM genre
	GROUP BY genre
)

SELECT 
    *
FROM
    genre_ranking
WHERE
    genre = 'thriller' ;

-- 'Thriller' genre has rank 3 and movie count is 1484.

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/



-- Segment 2:



-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM
    ratings ;

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/


-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

SELECT title, avg_rating,
		ROW_NUMBER() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM movie AS mov
INNER JOIN ratings AS rat
ON rat.movie_id = mov.id
LIMIT 10 ;

-- Top three movies have average rating >= 9.8

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/


-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT 
    median_rating, COUNT(movie_id) AS movie_count
FROM
    ratings
GROUP BY median_rating
ORDER BY median_rating ;

-- Movies with a median rating of 7 is highest in number followed by median rating of 6.

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/


-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT production_company, COUNT(id) AS movie_count,
		DENSE_RANK() OVER(ORDER BY COUNT(id) DESC) AS prod_company_rank
FROM movie AS mov
INNER JOIN ratings AS rat
ON mov.id = rat.movie_id
WHERE avg_rating > 8 AND production_company IS NOT NULL
GROUP BY production_company
ORDER BY movie_count DESC
limit 5 ;

-- Dream Warrior Pictures and National Theatre Live production houses have produced the most number of hit movies (average rating > 8)

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both


-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    gen.genre, COUNT(gen.movie_id) AS movie_count
FROM
    genre AS gen
        INNER JOIN
    ratings AS rat ON gen.movie_id = rat.movie_id
        INNER JOIN
    movie AS mov ON mov.id = gen.movie_id
WHERE
    mov.country LIKE '%USA%'
        AND rat.total_votes > 1000
        AND MONTH(date_published) = 3
        AND year = 2017
GROUP BY gen.genre
ORDER BY movie_count DESC ;

-- 'Drama' genre had highest movies during March 2017 in the USA that had more than 1,000 votes.

-- Lets try to analyse with a unique problem statement.


-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
    title, avg_rating, genre
FROM
    movie AS mov
        INNER JOIN
    ratings AS rat ON rat.movie_id = mov.id
        INNER JOIN
    genre AS gen ON gen.movie_id = mov.id
WHERE
    title LIKE 'THE%' AND avg_rating > 8
GROUP BY title
ORDER BY avg_rating DESC ;

/* 
	There are 8 movies which begin with "The" in their title.
	The Brighton Miracle has highest average rating of 9.5.
*/ 

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.


-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT 
    median_rating, COUNT(movie_id) AS movie_count
FROM
    movie AS mov
        INNER JOIN
    ratings AS rat ON mov.id = rat.movie_id
WHERE
    median_rating = 8
        AND date_published BETWEEN '2018-04-01' AND '2019-04-01'
GROUP BY median_rating ;

-- 361 movies released between 1 April 2018 and 1 April 2019 that have median rating of 8.

-- Once again, try to solve the problem given below.


-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT 
    country, SUM(total_votes) AS total_votes
FROM
    movie AS mov
        INNER JOIN
    ratings AS rat ON mov.id = rat.movie_id
WHERE
    country LIKE 'Germany'
        OR country = 'Italy'
GROUP BY country;

-- Yes, German movies get more votes than Italian movies.

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/



-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT 
    SUM(CASE
        WHEN name IS NULL THEN 1
        ELSE 0
    END) AS name_nulls,
    SUM(CASE
        WHEN height IS NULL THEN 1
        ELSE 0
    END) AS height_nulls,
    SUM(CASE
        WHEN date_of_birth IS NULL THEN 1
        ELSE 0
    END) AS date_of_birth_nulls,
    SUM(CASE
        WHEN known_for_movies IS NULL THEN 1
        ELSE 0
    END) AS known_for_movies_nulls
FROM
    names ;

-- Columns height, date_of_birth, known_for_movies have 17335,13431,15226 null values respectively.

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/


-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH genre_selection AS(
WITH top_genre AS(
SELECT genre, COUNT(title) AS movie_count,
	RANK() OVER(ORDER BY COUNT(title) DESC) AS genre_rank
FROM movie AS mov
	INNER JOIN ratings AS rat ON rat.movie_id=mov.id
	INNER JOIN genre AS gen ON gen.movie_id=mov.id
WHERE avg_rating>8
GROUP BY genre)
SELECT genre
FROM top_genre
WHERE genre_rank<4),
-- top 3 ranked genres have been identified. We will use these in the following query
top_directors AS(
SELECT nam.name AS director_name, COUNT(gen.movie_id) AS movie_count,
	RANK() OVER(ORDER BY COUNT(gen.movie_id) DESC) AS director_rank
FROM names AS nam
	INNER JOIN director_mapping AS dm ON nam.id=dm.name_id 
	INNER JOIN genre AS gen ON dm.movie_id=gen.movie_id 
	INNER JOIN ratings rat ON rat.movie_id= gen.movie_id,
	genre_selection
WHERE gen.genre IN (genre_selection.genre) AND avg_rating>8
GROUP BY director_name
ORDER BY movie_count DESC)
SELECT *
FROM top_directors
WHERE director_rank<=3 ;

-- Top director are James Mangold, Anthony Russo, Joe Russo, Soubin Shahir.

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/


-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH actor_ranking AS(
SELECT name AS actor_name, COUNT(rat.movie_id) AS movie_count,
	RANK() OVER(ORDER BY COUNT(rat.movie_id) DESC) AS actor_rank
FROM names AS nam
	INNER JOIN role_mapping AS rm ON rm.name_id= nam.id
	INNER JOIN ratings AS rat ON rat.movie_id= rm.movie_id
WHERE median_rating>=8
GROUP BY name
ORDER BY movie_count DESC)
SELECT actor_name, movie_count
FROM actor_ranking
WHERE actor_rank<3 ;

-- Mammootty and Mohanlal are the top two actors whose movies have a median rating >= 8.

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/


-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH ranking AS(
SELECT production_company, sum(total_votes) AS vote_count,
	RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM movie AS mov
	INNER JOIN ratings AS rat ON rat.movie_id=mov.id
GROUP BY production_company)
SELECT production_company, vote_count, prod_comp_rank
FROM ranking
WHERE prod_comp_rank<4 ;

-- Top three production houses based on the number of votes received by their movies are Marvel Studios, Twentieth Century Fox and Warner Bros.

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/


-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT name AS actor_name, total_votes,
                COUNT(mov.id) as movie_count,
                ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actor_avg_rating,
                RANK() OVER(ORDER BY avg_rating DESC) AS actor_rank
		
FROM movie AS mov 
INNER JOIN ratings AS rat 
ON mov.id = rat.movie_id 
INNER JOIN role_mapping AS rm 
ON mov.id=rm.movie_id 
INNER JOIN names AS nam
ON rm.name_id=nam.id
WHERE category='actor' AND country like '%india%'
GROUP BY name
HAVING COUNT(mov.id)>=5
LIMIT 10 ;

-- Top actor is Vijay Sethupathi.


-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT name AS actress_name, total_votes,
                COUNT(mov.id) AS movie_count,
                ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actress_avg_rating,
                RANK() OVER(ORDER BY avg_rating DESC) AS actress_rank
		
FROM movie AS mov
INNER JOIN ratings AS rat
ON mov.id = rat.movie_id 
INNER JOIN role_mapping AS rm 
ON mov.id=rm.movie_id 
INNER JOIN names AS nam 
ON rm.name_id=nam.id
WHERE category='actress' AND country='india' AND languages='hindi'
GROUP BY name
HAVING COUNT(mov.id)>=3
LIMIT 5 ;

-- Top actresses in Hindi movies released in India based on their average ratings are Taapsee Pannu, Divya Dutta, Kriti Kharbanda, Sonakshi Sinha.

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

WITH thriller_movies
     AS (SELECT DISTINCT title,
                         avg_rating
         FROM   movie AS mov
                INNER JOIN ratings AS rat
                        ON rat.movie_id = mov.id
                INNER JOIN genre AS gen using(movie_id)
         WHERE  genre LIKE 'THRILLER')
SELECT *,
       CASE
         WHEN avg_rating > 8 THEN 'Superhit movies'
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         ELSE 'Flop movies'
       END AS avg_rating_category
FROM   thriller_movies ; 

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/



-- Segment 4:



-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT genre,
		ROUND(AVG(duration),2) AS avg_duration,
        SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
        AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM movie AS mov
INNER JOIN genre AS gen 
ON mov.id= gen.movie_id
GROUP BY genre
ORDER BY genre ;

-- Round is good to have and not a must have; Same thing applies to sorting

-- Let us find top 5 movies of each year with top 3 genres.


-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

WITH top_genres AS
(
           SELECT     genre,
                      Count(mov.id) AS movie_count ,
                      Rank() OVER(ORDER BY Count(mov.id) DESC) AS genre_rank
           FROM       movie AS mov
           INNER JOIN genre AS gen
           ON         gen.movie_id = mov.id
           INNER JOIN ratings AS rat
           ON         rat.movie_id = mov.id
           WHERE      avg_rating > 8
           GROUP BY   genre limit 3 ), movie_summary AS
(
           SELECT     genre,
                      year,
                      title AS movie_name,
                      CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10)) AS worlwide_gross_income ,
                      DENSE_RANK() OVER(partition BY year ORDER BY CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10))  DESC ) AS movie_rank
           FROM       movie AS mov
           INNER JOIN genre  AS gen
           ON         mov.id = gen.movie_id
           WHERE      genre IN
                      (
                             SELECT genre
                             FROM   top_genres)
            GROUP BY   movie_name
           )
SELECT *
FROM   movie_summary
WHERE  movie_rank<=5
ORDER BY YEAR ;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.


-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH ranking AS(
SELECT production_company, COUNT(mov.id) AS movie_count,
	RANK() OVER(ORDER BY COUNT(id) DESC) AS prod_comp_rank
FROM movie AS mov
	INNER JOIN ratings AS rat ON mov.id=rat.movie_id
WHERE median_rating>=8 AND production_company IS NOT NULL AND POSITION(',' IN languages)>0
GROUP BY production_company)
SELECT *
FROM ranking
WHERE prod_comp_rank<3 ;

-- Star Cinema and Twentieth Century Fox are the top two production houses that have produced the highest number of hits among multilingual movies.

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH ranking AS(
SELECT name AS actress_name, SUM(total_votes) AS total_votes, COUNT(mov.id) AS movie_count,
	ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actress_avg_rating,
	RANK() OVER(ORDER BY COUNT(mov.id) DESC) AS actress_rank
FROM genre AS gen
	INNER JOIN movie AS mov ON gen.movie_id= mov.id 
	INNER JOIN ratings AS rat ON mov.id= rat.movie_id 
	INNER JOIN role_mapping AS rm ON mov.id=rm.movie_id 
	INNER JOIN names AS nam ON rm.name_id=nam.id
WHERE genre= 'drama' AND category= 'actress' AND avg_rating>8
GROUP BY name)
SELECT * 
FROM ranking
WHERE actress_rank<=3 ;



/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH top_directors AS
(
SELECT name_id AS director_id, name AS director_name, dm.movie_id, duration,
	   avg_rating AS avg_rating, total_votes AS total_votes, avg_rating * total_votes AS rating_count,
	   date_published,
       LEAD(date_published, 1) OVER (PARTITION BY name ORDER BY date_published, name) AS next_publish_date
FROM director_mapping AS dm
INNER JOIN names AS nam ON dm.name_id = nam.id
INNER JOIN movie AS mov ON dm.movie_id = mov.id 
INNER JOIN ratings AS rat ON mov.id = rat.movie_id)

SELECT director_id, director_name,
        COUNT(movie_id) AS number_of_movies,
        CAST(SUM(rating_count)/SUM(total_votes)AS DECIMAL(4,2)) AS avg_rating,
        ROUND(SUM(DATEDIFF(Next_publish_date, date_published))/(COUNT(movie_id)-1)) AS avg_inter_movie_days,
        SUM(total_votes) AS total_votes, MIN(avg_rating) AS min_rating, MAX(avg_Rating) AS max_rating,
        SUM(duration) AS total_duration
FROM top_directors
GROUP BY director_id
ORDER BY number_of_movies DESC
LIMIT 9 ;

-- Top 9 directors are A.L. Vijay, Andrew Jones, Jesse V. Johnson, Justin Price, Steven Soderbergh, Özgür Bakar, Sam Liu, Sion Sono and Chris Stokes.



