
-- Create a schema for our GoodReads table

CREATE TABLE goodreads_may(
	book_id int primary KEY, 
	cover_image_url VARCHAR(2083), 
	book_title text, 
	book_details text, 
	format VARCHAR(50), 
	publication_info DATE , 
	authorlink VARCHAR(2083), 
	author VARCHAR(255), 
	genres VARCHAR(1000), 
	num_ratings INT, 
	num_reviews INT, 
	average_rating FLOAT, 
	rating_distribution FLOAT
);

SELECT * 
FROM goodreads_may;

-- Check if the table exists 
select * 
from information_schema.tables
where table_name= 'goodreads_may';


SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';


-- Change the type if the columns due to transfer 
ALTER TABLE GOODREADS_MAY
ALTER COLUMn rating_distribution type text;

SELECT * FROM goodreads_may;

alter table goodreads_may
alter column publication_info type text

-- Exploring the table
SELECT * 
FROM goodreads_may;

-- Create a table of ex-books

CREATE TABLE ex_books (
	ISBN VARCHAR(20), 
	"Book-Title" VARCHAR(256), 
	"Book-Author" VARCHAR(256), 
	"year-of-publication" INT, 
	Publisher VARCHAR(256), 
	"Image-URL-S" text, 
	"Image-URL-M" text, 
	"Image-URL-L" TEXT
);

SELECT * FROM ex_books;

-- Create a table popular_books

create table popular_books(
	Title VARCHAR(256), 
	Author VARCHAR(256), 
	Score numeric,
	Ratings INT, 
	Shelvings INT, 
	Published INT, 
	Description TEXT, 
	Image TEXT
);

ALTER TABLE POPULAR_BOOKS
ALTER COLUMN Title type VARCHAR(500)

ALTER TABLE POPULAR_BOOKS
ALTER COLUMN Score type FLOAT

ALTER TABLE POPULAR_BOOKS
ALTER COLUMN Score type text

-- Data Cleaning 


ALTER TABLE popular_books 
DROP COLUMN "image-url-l",
DROP COLUMN "image-url-m",
DROP COLUMN "image-url-s",
DROP COLUMN "publisher",
DROP COLUMN "year-of-publication",
DROP COLUMN "book-author",
DROP COLUMN "book-title",
DROP COLUMN "isbn";

SELECT *
FROM popular_books pb 

ALTER TABLE GOODREADS_MAY 
DROP COLUMN cover_image_url;

SELECT *
FROM goodreads_may gm 

SELECT *
FROM popular_books pb 

SELECT *
FROM ex_books;







