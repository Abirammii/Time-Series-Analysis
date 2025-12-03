-- Create master unified table by joining orders, customers, items, products, and sellers
CREATE TABLE master_dataa AS
SELECT
    -- ORDER INFO
    o.order_id,
    o.customer_id,
    o.order_purchase_timestamp,
    o.order_estimated_delivery_date,

    -- CUSTOMER INFO
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    -- PRODUCT INFO
    oi.product_id,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,

    -- SELLER INFO
    oi.seller_id,
    s.seller_city,
    s.seller_state,

    -- ORDER ITEM INFO
    oi.price,
    oi.freight_value,
    oi.shipping_limit_date,
    oi.qty,
    (oi.qty * oi.price) AS total_amount

FROM olist_orders_dataset o
JOIN olist_customers_dataset c 
    ON o.customer_id = c.customer_id

JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id

LEFT JOIN olist_products_dataset p
    ON oi.product_id = p.product_id

JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id;
