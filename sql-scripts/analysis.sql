SET search_path TO public;

SELECT * FROM ex_books_view ebv ;
SELECT * FROM goodreads_may_view gmv ;
SELECT * FROM popular_books_view pbv ;


SELECT COUNT(*) FROM ex_books_view ebv ;
SELECT COUNT(*) FROM popular_books_view pbv;


--- Window Functions

-- Ranking Books by rating within each author

SELECT DISTINCT
	title, 
	author, 
	score, 
	ROW_NUMBER() OVER (PARTITION BY author ORDER BY score DESC) AS book_rank
FROM popular_books_view pbv 


-- The difference in scores between books / LAG(), LEAD()


SELECT DISTINCT
    author, 
    title, 
    score,
    LAG(CAST(score AS NUMERIC)) OVER (PARTITION BY author ORDER BY CAST(score AS NUMERIC) DESC) AS previous_score,
    CAST(score AS NUMERIC) - LAG(CAST(score AS NUMERIC)) OVER (PARTITION BY author ORDER BY CAST(score AS NUMERIC) DESC) AS score_difference
FROM 
    popular_books_view
ORDER BY 
    author, score DESC;
   
--- Difference between the current book and the next one.   
   
 SELECT DISTINCT
    author, 
    title, 
    score,
    LEAD(CAST(score AS NUMERIC)) OVER (PARTITION BY author ORDER BY CAST(score AS NUMERIC) DESC) AS next_score,
    LEAD(CAST(score AS NUMERIC)) OVER (PARTITION BY author ORDER BY CAST(score AS NUMERIC) DESC) - CAST(score AS NUMERIC) AS score_difference_next
FROM 
    popular_books_view
ORDER BY 
    author, score DESC;

   
-- ******************************************
-- **  Impact of Book Format and Genre on Ratings and Scores **
-- ******************************************
   
WITH avg_rating_by_format_genre AS (
	SELECT 
		format_type, 
		primary_genre, 
		ROUND(AVG(CAST(gmv.average_rating AS NUMERIC)),2) AS average_rating, 
		ROUND(AVG(CAST(pbv.score AS NUMERIC)), 2) AS avg_score
	FROM goodreads_may_view gmv 
	LEFT JOIN popular_books_view pbv 
	ON gmv.book_title = pbv.title
	GROUP BY format_type, primary_genre
)
, ranked_genres_by_format AS (
	SELECT 
		format_type, 
		primary_genre, 
		average_rating, 
		avg_score, 
		RANK() OVER (PARTITION BY format_type ORDER BY average_rating DESC) AS genre_rank
	FROM avg_rating_by_format_genre
)
SELECT 
	format_type, 
	primary_genre, 
	average_rating, 
	avg_score, 
	genre_rank
FROM ranked_genres_by_format
ORDER BY format_type, average_rating DESC;



-- ******************************************
-- **  Author Success Analysis **
-- ******************************************   


SELECT 
	author,  
	primary_genre,
	format_type, 
	COUNT(primary_genre) AS count_genres,
	ROUND(AVG(CAST(gmv.average_rating AS NUMERIC)),2) AS average_rating, 
	SUM(num_ratings) AS total_ratings, 
	SUM(num_reviews) AS total_reviews, 
	ROUND(stddev(CAST(average_rating AS NUMERIC)), 2) AS rating_variability
FROM goodreads_may_view gmv 
GROUP BY author, primary_genre, format_type 
ORDER BY average_rating DESC



-- ******************************************
-- **  Reader Engagement Analysis **
-- ****************************************** 	

	
   
   
WITH generic_table AS (
    SELECT 
        gmv.author, 
        gmv.book_title, 
        ROUND(AVG(CAST(gmv.average_rating AS NUMERIC)), 2) AS average_rating, 
        ROUND(AVG(CAST(gmv.num_reviews AS NUMERIC)), 2) AS avg_reviews, 
        gmv.format_type, 
        gmv.primary_genre, 
        pbv.score
    FROM 
        goodreads_may_view gmv 
    LEFT JOIN 
        popular_books_view pbv 
    ON 
        gmv.book_title = pbv.title
    GROUP BY 
        gmv.author, gmv.book_title, gmv.format_type, gmv.primary_genre, pbv.score
), 
summary_table AS (
    SELECT 
        primary_genre, 
        ROUND(AVG(CAST(score AS NUMERIC)), 2) AS genre_avg_score, 
        ROUND(AVG(CAST(average_rating AS NUMERIC)), 2) AS genre_avg_rating
    FROM 
        generic_table
    GROUP BY 
        primary_genre
)
SELECT
    gt.author, 
    gt.book_title, 
    gt.primary_genre, 
    gt.average_rating, 
    st.genre_avg_rating, 
    gt.score, 
    st.genre_avg_score
FROM 
    generic_table gt
JOIN 
    summary_table st
ON 
    gt.primary_genre = st.primary_genre
ORDER BY 
    gt.average_rating DESC;



	
	
	
	
	
	
