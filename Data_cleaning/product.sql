-- View table structure
DESCRIBE olist_products_dataset;

-- Preview first 10 rows of the dataset
SELECT * FROM olist_products_dataset LIMIT 10;

-- Check total rows and count null values in major product columns
SELECT 
    COUNT(*) AS total_rows,
    SUM(product_id IS NULL) AS product_id_nulls,
    SUM(product_category_name IS NULL) AS category_nulls,
    SUM(product_name_lenght IS NULL) AS name_length_nulls,
    SUM(product_description_lenght IS NULL) AS desc_length_nulls,
    SUM(product_photos_qty IS NULL) AS photos_nulls,
    SUM(product_weight_g IS NULL) AS weight_nulls,
    SUM(product_length_cm IS NULL) AS length_nulls,
    SUM(product_height_cm IS NULL) AS height_nulls,
    SUM(product_width_cm IS NULL) AS width_nulls
FROM olist_products_dataset;

-- Check for duplicate product_id values
SELECT product_id, COUNT(*) AS freq
FROM olist_products_dataset
GROUP BY product_id
HAVING COUNT(*) > 1;
