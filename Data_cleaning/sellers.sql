-- View table structure
DESCRIBE olist_sellers_dataset;

-- Preview first 10 rows from the sellers dataset
SELECT * FROM olist_sellers_dataset LIMIT 10;

-- Check total rows and null values across seller columns
SELECT
    COUNT(*) AS total_rows,
    SUM(seller_id IS NULL) AS seller_id_nulls,
    SUM(seller_zip_code_prefix IS NULL) AS zip_nulls,
    SUM(seller_city IS NULL) AS city_nulls,
    SUM(seller_state IS NULL) AS state_nulls
FROM olist_sellers_dataset;
