-- ******************************************
-- ** EDA  - ex_books  **
-- ******************************************

-- Viewing Simple Data
SELECT * 
FROM ex_books eb 
LIMIT 10;

-- Counting Total Rows

SELECT COUNT(*) AS total_rows
FROM ex_books eb 

-- Counting Unique Authors, Books, and ISBNs

SELECT COUNT(DISTINCT "Book-Author") AS total_authors
FROM ex_books eb 

SELECT COUNT(DISTINCT "Book-Title") AS total_books
FROM ex_books eb 

SELECT COUNT(DISTINCT isbn) AS total_isbn
FROM ex_books eb 

-- Identifying Duplicate Rows
SELECT isbn,"Book-Title", "Book-Author", "year-of-publication", publisher, COUNT(*)
FROM ex_books eb 
GROUP BY isbn,"Book-Title", "Book-Author", "year-of-publication", publisher
HAVING COUNT(*) > 1
ORDER BY COUNT(*);

-- Counting Groups of Duplicates

-- There are 813 combinations of rows with more than 2 duplicates

SELECT duplicate_count, COUNT(*) AS number_of_groups
FROM (
	SELECT COUNT(*) AS duplicate_count
	FROM ex_books eb 
	GROUP BY isbn,"Book-Title", "Book-Author", "year-of-publication", publisher
	HAVING COUNT(*) > 1
) AS subquery
GROUP BY duplicate_count
ORDER BY duplicate_count;

-- Check for Missing Values

SELECT COUNT(*) AS missing_isbn
FROM ex_books eb 
WHERE isbn IS NULL;

SELECT COUNT(*) AS missing_books_title
FROM ex_books 
WHERE "Book-Title" IS NULL

SELECT COUNT(*) AS missing_book_author
FROM ex_books 
WHERE "Book-Author" IS NULL

SELECT COUNT(*) AS missing_year_publication
FROM ex_books 
WHERE "year-of-publication" IS NULL

SELECT COUNT(*) AS missing_publisher
FROM ex_books 
WHERE publisher IS NULL

-- ******************************************
-- ** EDA  - goodreads_may  **
-- ******************************************

SELECT *
FROM goodreads_may gm 
LIMIT 10;

SELECT COUNT(*) AS missing_book_id
FROM goodreads_may gm 
WHERE book_id IS NULL

SELECT COUNT(*) AS missing_book_title
FROM goodreads_may gm 
WHERE book_title IS NULL

SELECT COUNT(*) AS missing_book_details
FROM goodreads_may gm 
WHERE book_details IS NULL

SELECT COUNT(*) AS missing_format
FROM goodreads_may gm 
WHERE format IS NULL

SELECT COUNT(*) AS publication_info
FROM goodreads_may gm 
WHERE publication_info IS NULL

SELECT COUNT(*) AS missing_author
FROM goodreads_may gm 
WHERE author IS NULL

SELECT COUNT(*) AS missing_genres
FROM goodreads_may gm 
WHERE genres IS NULL

SELECT COUNT(*) AS missing_num_ratings
FROM goodreads_may gm 
WHERE num_ratings IS NULL

SELECT COUNT(*) AS missing_num_reviews
FROM goodreads_may gm 
WHERE num_reviews IS NULL

SELECT COUNT(*) AS missing_average_rating
FROM goodreads_may gm 
WHERE average_rating IS NULL

SELECT COUNT(*) AS missing_rating_distribution
FROM goodreads_may gm 
WHERE rating_distribution IS NULL

SELECT COUNT(*) AS missing_num_pages
FROM goodreads_may gm 
WHERE num_pages IS NULL

-- Identifying Duplicate Rows/No duplicate rows

SELECT book_id, book_title, book_details, FORMAT, publication_info, authorlink, author, genres, num_ratings, num_reviews, average_rating,rating_distribution, column1, cover_image_uri, num_pages, COUNT(*)
FROM goodreads_may gm 
GROUP BY book_id, book_title, book_details, FORMAT, publication_info, authorlink, author, genres, num_ratings, num_reviews, average_rating,rating_distribution, column1, cover_image_uri, num_pages
HAVING COUNT(*) > 1
ORDER BY COUNT(*)


-- Descriptive statistics for numeric columns
-- Extract and convert the JSON values to numeric types, then calculate statistics
-- Extract and convert the JSON values to numeric types, then calculate statistics
WITH extracted_data AS (
    SELECT 
        num_ratings,
        num_reviews,
        CAST(average_rating AS FLOAT) AS average_rating,
        (CAST(regexp_replace((regexp_replace(rating_distribution::text, '''', '"', 'g'))::json->>'5', '[^0-9]', '', 'g') AS INTEGER) +
        CAST(regexp_replace((regexp_replace(rating_distribution::text, '''', '"', 'g'))::json->>'4', '[^0-9]', '', 'g') AS INTEGER) +
        CAST(regexp_replace((regexp_replace(rating_distribution::text, '''', '"', 'g'))::json->>'3', '[^0-9]', '', 'g') AS INTEGER) +
        CAST(regexp_replace((regexp_replace(rating_distribution::text, '''', '"', 'g'))::json->>'2', '[^0-9]', '', 'g') AS INTEGER) +
        CAST(regexp_replace((regexp_replace(rating_distribution::text, '''', '"', 'g'))::json->>'1', '[^0-9]', '', 'g') AS INTEGER)) AS total_ratings
    FROM goodreads_may
)
SELECT 
    AVG(num_ratings) AS avg_ratings, 
    MIN(num_ratings) AS min_ratings, 
    MAX(num_ratings) AS max_ratings, 
    STDDEV(num_ratings) AS stddev_ratings, 
    AVG(num_reviews) AS avg_reviews, 
    MIN(num_reviews) AS min_reviews, 
    MAX(num_reviews) AS max_reviews, 
    STDDEV(num_reviews) AS stddev_reviews, 
    AVG(average_rating) AS avg_average_rating, 
    MIN(average_rating) AS min_average_rating, 
    MAX(average_rating) AS max_average_rating, 
    STDDEV(average_rating) AS stddev_average_rating, 
    AVG(total_ratings) AS avg_rating_distribution, 
    MIN(total_ratings) AS min_rating_distribution, 
    MAX(total_ratings) AS max_rating_distribution, 
    STDDEV(total_ratings) AS stddev_rating_distribution
FROM extracted_data;

-- Correlation Analysis
SELECT
    CORR(num_ratings, num_reviews) AS corr_num_ratings_reviews,
    CORR(num_ratings, average_rating) AS corr_num_ratings_avg_rating,
    CORR(num_reviews, average_rating) AS corr_num_reviews_avg_rating
FROM goodreads_may gm ;

-- Correlation between num_ratings and num_reviews:
-- Correlation Coefficient: 0.7922
-- Interpretation: There is a strong positive correlation between the number of ratings and the number of reviews. This means that books with more ratings tend to have more reviews.



-- ******************************************
-- ** Exploratory Data Analysis - popular_books  **
-- ******************************************

-- View a sample of the data
SELECT *
FROM popular_books pb 
LIMIT 10;

-- Count total rows
SELECT COUNT(*) AS total_rows
FROM popular_books pb;

-- Counting missing values in the columns
SELECT 
    COUNT(*) FILTER (WHERE title IS NULL) AS missing_title,
    COUNT(*) FILTER (WHERE author IS NULL) AS missing_author,
    COUNT(*) FILTER (WHERE score IS NULL) AS missing_score,
    COUNT(*) FILTER (WHERE ratings IS NULL) AS missing_ratings,
    COUNT(*) FILTER (WHERE shelvings IS NULL) AS missing_shelvings,
    COUNT(*) FILTER (WHERE published IS NULL) AS missing_published,
    COUNT(*) FILTER (WHERE description IS NULL) AS missing_description,
    COUNT(*) FILTER (WHERE image IS NULL) AS missing_image
FROM popular_books pb;

-- Identifying a combination of duplicate rows
SELECT title, author, score, ratings, shelvings, published, description, image, COUNT(*)
FROM popular_books pb 
GROUP BY title, author, score, ratings, shelvings, published, description, image
HAVING COUNT(*) > 1
ORDER BY COUNT(*);

-- Descriptive statistics for numeric columns
SELECT 
    AVG(CAST(score AS NUMERIC)) AS avg_score, 
    MIN(CAST(score AS NUMERIC)) AS min_score, 
    MAX(CAST(score AS NUMERIC)) AS max_score, 
    STDDEV(CAST(score AS NUMERIC)) AS stddev_score, 
    AVG(ratings) AS avg_ratings, 
    MIN(ratings) AS min_ratings, 
    MAX(ratings) AS max_ratings, 
    STDDEV(ratings) AS stddev_ratings, 
    AVG(shelvings) AS avg_shelvings, 
    MIN(shelvings) AS min_shelvings, 
    MAX(shelvings) AS max_shelvings, 
    STDDEV(shelvings) AS stddev_shelvings
FROM popular_books pb;

-- Check data types of columns
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'popular_books';

-- Correlation Analysis
SELECT 
    CORR(CAST(score AS NUMERIC), ratings) AS corr_score_ratings,
    CORR(CAST(score AS NUMERIC), shelvings) AS corr_score_shelvings,
    CORR(ratings, shelvings) AS corr_ratings_shelvings
FROM popular_books pb;

-- Interpretation of Correlation Results
-- Correlation between ratings and shelvings:
-- Correlation Coefficient: 0.9206261385851587
-- Interpretation: There is a very strong positive correlation between the number of ratings and shelvings. This means that books with higher ratings tend to be shelved more frequently, which is expected as popular books are likely to be both highly rated and widely shelved.




