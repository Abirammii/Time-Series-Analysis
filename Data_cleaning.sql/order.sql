-- Switch to the working database
USE testdb;

-- Check table structure
DESCRIBE olist_orders_dataset;

-- Preview data
SELECT * FROM olist_orders_dataset LIMIT 10;

-- Check total rows and null values in key columns
SELECT 
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(order_purchase_timestamp IS NULL) AS order_date_nulls
FROM olist_orders_dataset;

-- Identify duplicate order IDs
SELECT order_id, COUNT(*) AS freq
FROM olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Convert order_purchase_timestamp to datetime format (into new column: order_date)
UPDATE olist_orders_dataset
SET order_date = STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')
WHERE order_purchase_timestamp IS NOT NULL AND order_purchase_timestamp != '';

-- Verify conversion
SELECT order_id, order_purchase_timestamp, order_date
FROM olist_orders_dataset
LIMIT 10;

-- Convert order_approved_at to proper datetime format
UPDATE olist_orders_dataset
SET order_approved_at = STR_TO_DATE(order_approved_at, '%Y-%m-%d %H:%i:%s')
WHERE order_approved_at IS NOT NULL AND order_approved_at != '';

-- Convert delivered carrier date
UPDATE olist_orders_dataset
SET order_delivered_carrier_date = STR_TO_DATE(order_delivered_carrier_date, '%Y-%m-%d %H:%i:%s')
WHERE order_delivered_carrier_date IS NOT NULL AND order_delivered_carrier_date != '';

-- Convert delivered customer date
UPDATE olist_orders_dataset
SET order_delivered_customer_date = STR_TO_DATE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s')
WHERE order_delivered_customer_date IS NOT NULL AND order_delivered_customer_date != '';

-- Convert estimated delivery date
UPDATE olist_orders_dataset
SET order_estimated_delivery_date = STR_TO_DATE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s')
WHERE order_estimated_delivery_date IS NOT NULL AND order_estimated_delivery_date != '';

-- Final verification
SELECT 
    order_id, 
    order_purchase_timestamp, 
    order_date,
    order_estimated_delivery_date
FROM olist_orders_dataset
LIMIT 10;

