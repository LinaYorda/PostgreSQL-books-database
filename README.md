# Book Dataset Analysis with PostgreSQL

This project involves exploratory data analysis (EDA) on a dataset of books using PostgreSQL. The SQL scripts included in this repository perform various analyses to understand the structure and quality of the data, identify duplicates, and prepare the data for further analysis or modeling. As a data source I used three separate CSVs from Kaggle. 

## Files

- **`data`**: contains the three CSV files, used for this project.
- **`sql-scripts`**: contains PostgreSQL queries for creating all tables and analysis on the dataset.


### Overview of EDA PostgreSQL Queries

The `exploratory-analysis.sql` file contains PostgreSQL queries such as:

 **Checking for missing values**:
   ```sql
    SELECT COUNT(*) AS missing_num_reviews
    FROM goodreads_may gm 
    WHERE num_reviews IS NULL;
```

 **Counting Groups of Duplicates**:
   ```sql
    SELECT duplicate_count, COUNT(*) AS number_of_groups
    FROM (
	    SELECT COUNT(*) AS duplicate_count
	    FROM ex_books eb 
	    GROUP BY isbn,"Book-Title", "Book-Author", "year-of-publication", publisher
	    HAVING COUNT(*) > 1
        ) AS subquery
    GROUP BY duplicate_count
    ORDER BY duplicate_count;
```

 **Correlation between numeric columns**:
   ```sql
    SELECT 
        corr(num_ratings, num_reviews) AS corr_num_ratings_reviews,
        corr(num_ratings, average_rating) AS corr_num_ratings_avg_rating,
        corr(num_reviews, average_rating) AS corr_num_reviews_avg_rating
    FROM goodreads_may gm ;
```
