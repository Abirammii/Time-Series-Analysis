-- View table structure
DESCRIBE olist_order_items_dataset;

-- Preview first 10 rows
SELECT * FROM olist_order_items_dataset LIMIT 10;

-- Check total rows and null values across key columns
SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(order_item_id IS NULL) AS item_id_nulls,
    SUM(product_id IS NULL) AS product_id_nulls,
    SUM(seller_id IS NULL) AS seller_id_nulls,
    SUM(price IS NULL) AS price_nulls,
    SUM(freight_value IS NULL) AS freight_nulls
FROM olist_order_items_dataset;

-- Check for duplicate (order_id + order_item_id) combinations
SELECT order_id, order_item_id, COUNT(*) AS freq
FROM olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- Rename order_item_id column to qty
ALTER TABLE olist_order_items_dataset
CHANGE COLUMN order_item_id qty INT;

-- Verify updated structure
DESCRIBE olist_order_items_dataset;
