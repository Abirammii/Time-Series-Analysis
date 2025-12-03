-- View table structure
DESCRIBE olist_customers_dataset;


-- Preview first 10 rows
SELECT * FROM olist_customers_dataset LIMIT 10;

-- Check total rows and null values in important columns
SELECT
    COUNT(*) AS total_rows,
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(customer_unique_id IS NULL) AS unique_id_nulls,
    SUM(customer_zip_code_prefix IS NULL) AS zip_nulls,
    SUM(customer_city IS NULL) AS city_nulls,
    SUM(customer_state IS NULL) AS state_nulls
FROM olist_customers_dataset;

-- Check for duplicate customer_id values
SELECT customer_id, COUNT(*) AS freq
FROM olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Describe table again (if needed for review)
DESCRIBE olist_customers_dataset;
