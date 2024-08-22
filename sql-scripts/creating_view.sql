SELECT *
FROM ex_books eb 

SELECT *
FROM goodreads_may gm 

SELECT *
FROM popular_books pb 

-- Since the tables are unrelated, I will not create any foreign keys and will start exploring them. 


SELECT eb."Book-Author" AS author, 
       COUNT(DISTINCT eb."Book-Title") AS count_bx_books, 
       COUNT(DISTINCT pb.title) AS count_popular_books, 
       COUNT(DISTINCT gm.book_title) AS count_book_details
FROM ex_books eb
LEFT JOIN popular_books pb ON eb."Book-Author" = pb.author
LEFT JOIN goodreads_may gm ON eb."Book-Author" = gm.author
GROUP BY eb."Book-Author";


-- Creating a view

--ex_books_view

CREATE VIEW ex_books_view AS
SELECT isbn, "Book-Title", "Book-Author", "year-of-publication", publisher
FROM ex_books;

SELECT * FROM ex_books_view;


-- popular_books_view

CREATE VIEW popular_books_view AS
SELECT title, author, score, ratings, shelvings, published, description
FROM popular_books pb 
WHERE title IS NOT NULL 
	AND author IS NOT NULL 
	AND score IS NOT NULL 
	AND ratings IS NOT NULL 
	AND shelvings IS NOT NULL 
	AND published IS NOT NULL 
	AND description IS NOT NULL


SELECT * FROM popular_books_view;


-- Clean and create goodreads_may_view;
	

DROP VIEW IF EXISTS goodreads_may_view;

CREATE OR REPLACE VIEW goodreads_may_view AS
SELECT 
    book_id, 
    author,
    book_title, 
    book_details, 
    num_ratings,
    num_reviews, 
    average_rating,
    REPLACE(REPLACE(REPLACE(num_pages, '[', ''), ']', ''), '''', '') AS cleaned_num_pages, 
    TRIM(BOTH ' ' FROM TRIM(BOTH '''' FROM SPLIT_PART(REPLACE(REPLACE(format, '[', ''), ']', ''), ',', 2))) AS format_type, 
    TRIM(BOTH ' ' FROM TRIM(BOTH '''' FROM SPLIT_PART(REPLACE(REPLACE(genres, '[', ''), ']', ''), ',', 1))) AS primary_genre, 
    NULLIF(REPLACE(SPLIT_PART(SPLIT_PART(REPLACE(REPLACE(REPLACE(rating_distribution, '{', ''), '}', ''), '''', ''), ',', 1), ':', 2), ',', ''), '')::int AS five_star_count,
    NULLIF(REPLACE(SPLIT_PART(SPLIT_PART(REPLACE(REPLACE(REPLACE(rating_distribution, '{', ''), '}', ''), '''', ''), ',', 2), ':', 2), ',', ''), '')::int AS four_star_count,
    NULLIF(REPLACE(SPLIT_PART(SPLIT_PART(REPLACE(REPLACE(REPLACE(rating_distribution, '{', ''), '}', ''), '''', ''), ',', 3), ':', 2), ',', ''), '')::int AS three_star_count,
    NULLIF(REPLACE(SPLIT_PART(SPLIT_PART(REPLACE(REPLACE(REPLACE(rating_distribution, '{', ''), '}', ''), '''', ''), ',', 4), ':', 2), ',', ''), '')::int AS two_star_count,
    NULLIF(REPLACE(SPLIT_PART(SPLIT_PART(REPLACE(REPLACE(REPLACE(rating_distribution, '{', ''), '}', ''), '''', ''), ',', 5), ':', 2), ',', ''), '')::int AS one_star_count
FROM goodreads_may;

SELECT * FROM goodreads_may_view;
SELECT * FROM popular_books_view pbv ;
SELECT * FROM ex_books_view ebv ;

-- Analysis goodreads_may_view


SELECT COUNT(*)
FROM goodreads_may_view gmv 

SELECT COUNT(DISTINCT author)
FROM goodreads_may_view gmv 



-- Most popular book format

SELECT 
    format_type, 
    COUNT(format_type) AS format_count
FROM 
    goodreads_may_view
GROUP BY 
    format_type
ORDER BY 
    format_count DESC;

-- Most popular genre 
   
SELECT primary_genre, COUNT(primary_genre) AS genre_count
FROM goodreads_may_view gmv 
GROUP BY primary_genre 
ORDER BY genre_count DESC

-- Books by author

SELECT author, COUNT(author) AS author_count
FROM goodreads_may_view gmv 
GROUP BY author 
ORDER BY author_count DESC

-- How many avg rating a booka and an author has?

SELECT author, book_title, COUNT(average_rating) AS avg_count
FROM goodreads_may_view gmv 
GROUP BY author , book_title 
ORDER BY avg_count DESC

-- Average rating by author

SELECT author, ROUND(CAST(AVG(average_rating)AS NUMERIC), 2) AS avg_count
FROM goodreads_may_view gmv 
GROUP BY author 
ORDER BY avg_count DESC

-- Top rated books by genre

SELECT book_title, AVG(average_rating) AS avg_rate, primary_genre 
FROM goodreads_may_view gmv 
GROUP BY primary_genre, book_title 
ORDER BY avg_rate DESC

-- 1star, 2star, 3star, 4star, 5stars reviews of author

SELECT 
	author, 
	book_title, 
	ROUND(CAST(AVG(five_star_count) AS NUMERIC), 3) AS five_star, 
	ROUND(CAST(AVG(four_star_count) AS NUMERIC), 3) AS four_star, 
	ROUND(CAST(AVG(three_star_count) AS NUMERIC), 3) AS three_star, 
	ROUND(CAST(AVG(two_star_count) AS NUMERIC), 3) AS two_star,
	ROUND(CAST(AVG(one_star_count) AS NUMERIC), 3) AS two_star
FROM goodreads_may_view gmv 
GROUP BY author, book_title 
	
-- Most popular books and authors based on total reviews given

SELECT author, book_title, num_reviews
FROM goodreads_may_view gmv 
ORDER BY num_reviews DESC

-- AVerage number of pages per author

SELECT 
    author, 
    AVG(CAST(NULLIF(NULLIF(cleaned_num_pages, 'None'), '') AS NUMERIC)) AS avg_number_pages
FROM 
    goodreads_may_view gmv 
GROUP BY 
    author
ORDER BY 
    avg_number_pages;

   
-- Books with the Highest Rating Variability
   
SELECT 
    author, 
    book_title, 
    COUNT(average_rating) AS rating_count
FROM 
    goodreads_may_view
GROUP BY 
    author, book_title
HAVING 
    COUNT(average_rating) <= 1;

   
-- Analysis ex_books
   
SELECT * FROM ex_books_view;

--- total rows 
SELECT COUNT(*) AS total_rows
FROM ex_books_view ebv ;

SELECT COUNT(DISTINCT "Book-Author") AS total_authors
FROM ex_books_view ebv ;

SELECT COUNT(DISTINCT "Book-Title") AS different_books
FROM ex_books_view ebv ;
   
SELECT COUNT(DISTINCT publisher) AS total_publishers
FROM ex_books_view ebv ;
   
-- Counting publishers and authors books


SELECT publisher, COUNT("Book-Title") AS count_books_publishers
FROM ex_books_view ebv 
GROUP BY publisher
ORDER BY  count_books_publishers DESC;

SELECT "Book-Author", COUNT("Book-Title") AS total_books_per_author
FROM ex_books_view ebv 
GROUP BY "Book-Author" 
ORDER BY total_books_per_author DESC;

-- cirulation of books per year and decade

SELECT "year-of-publication", COUNT("Book-Title") AS total_books
FROM ex_books_view ebv 
GROUP BY "year-of-publication"
ORDER BY "year-of-publication" ASC, total_books DESC; 



SELECT ("year-of-publication" / 10) * 10 AS decade, COUNT("Book-Title") AS total_books
FROM ex_books_view ebv 
WHERE "year-of-publication" > 0
GROUP BY decade
ORDER BY decade ASC; 

-- published books per author in years

SELECT 
    ("year-of-publication" / 10) * 10 AS decade, 
    "Book-Author", 
    COUNT("Book-Title") AS total_books
FROM 
    ex_books_view
WHERE 
    "year-of-publication" > 0
GROUP BY 
    decade, "Book-Author"
ORDER BY 
    decade ASC, total_books DESC;

-- Anaysis popular_books_view
   
SELECT * FROM popular_books_view pbv ;


SELECT COUNT(*)
FROM popular_books_view pbv ;

-- books per author

SELECT author, COUNT(title) AS total_books_per_authors
FROM popular_books_view pbv 
GROUP BY author 
ORDER BY total_books_per_authors DESC


-- average score per author

SELECT author, ROUND(AVG(CAST(score AS NUMERIC)), 2) AS authors_avg_score
FROM popular_books_view pbv 
GROUP BY author 
ORDER BY authors_avg_score DESC

-- books published per author

SELECT (published / 10) * 10 AS decade, author, COUNT(title) AS count_books
FROM popular_books_view pbv 
WHERE published > 0
GROUP BY author, decade
ORDER BY decade DESC, count_books DESC

-- average ratings per author

SELECT author, ROUND(AVG(ratings), 0) AS average_rating
FROM popular_books_view pbv 
GROUP BY author 
ORDER BY average_rating DESC


-- top authors by total ratings
SELECT author, SUM(ratings) AS total_sum_rating
FROM popular_books_view pbv 
GROUP BY author 
ORDER BY total_sum_rating DESC;


-- authors with most top scoring books

SELECT author, COUNT(title) AS count_score
FROM popular_books_view pbv 
WHERE CAST(score AS NUMERIC) > 4.5
GROUP BY author 
ORDER BY count_score DESC;

-- longest title

SELECT title, author, LENGTH(title) AS title_length
FROM popular_books_view pbv 
ORDER BY title_length DESC
LIMIT 10;

SELECT author, ROUND(AVG(ratings), 2) AS avg_ratings_per_book
FROM popular_books_view pbv 
GROUP BY author 
ORDER BY avg_ratings_per_book DESC;


