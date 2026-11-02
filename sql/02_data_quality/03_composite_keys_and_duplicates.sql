-- Step 2 — Composite Key Duplicate Check

-- In Order_items table
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS Duplicate_Count
FROM dbo.olist_order_items_dataset
GROUP BY
    order_id,
    order_item_id
HAVING COUNT(*) > 1;

-- In Payment Table

USE Olist_Ecommerce;
GO

SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS Duplicate_Count
FROM dbo.olist_order_payments_dataset
GROUP BY
    order_id,
    payment_sequential
HAVING COUNT(*) > 1;

-- In Review Table
SELECT
    review_id,
    order_id,
    COUNT(*) AS Duplicate_Count
FROM dbo.olist_order_reviews_dataset
GROUP BY
    review_id,
    order_id
HAVING COUNT(*) > 1;

--Step 3: Full Row Duplicate Check => الصف كله لازم يكون متطابق
-- Foriegn key also
-- olist_geolocation Table
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS Duplicate_Count
FROM dbo.olist_geolocation_dataset
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;

-- Orders table
SELECT
    order_id,
    COUNT(*) AS Duplicate_Count
FROM dbo.olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;
-- Reviews Table
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    COUNT(*) AS Duplicate_Count
FROM dbo.olist_order_reviews_dataset
GROUP BY
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
HAVING COUNT(*) > 1;

--Order Payments
SELECT
    order_id,
    COUNT(*) AS Payment_Count
FROM dbo.olist_order_payments_dataset
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY Payment_Count DESC;

-- For Reviews Table
SELECT
    review_id,
    COUNT(*) AS Review_Count
FROM dbo.olist_order_reviews_dataset
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY Review_Count DESC;

SELECT
    review_id,
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT order_id) AS Different_Orders
FROM dbo.olist_order_reviews_dataset
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY Total_Records DESC;


