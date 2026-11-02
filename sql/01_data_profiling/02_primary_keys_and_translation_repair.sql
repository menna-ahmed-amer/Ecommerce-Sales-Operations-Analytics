
USE Olist_Ecommerce;

-- To Repaire the Translation Table
DELETE FROM dbo.product_category_name_translation
WHERE column1 = 'product_category_name'
  AND column2 = 'product_category_name_english';


EXEC sp_rename
    'dbo.product_category_name_translation.column1',
    'product_category_name',
    'COLUMN';

EXEC sp_rename
    'dbo.product_category_name_translation.column2',
    'product_category_name_english',
    'COLUMN';

SELECT *
FROM dbo.product_category_name_translation;

SELECT COUNT(*) AS Total_Rows
FROM dbo.product_category_name_translation;

-- Step 1 — Check Duplicates in Primary Keys

-- In Customers Table => Primary key is Customer_Id
SELECT
    'Customers' AS Table_Name,
    COUNT(*) AS Total_Rows, --100
    COUNT(DISTINCT customer_id) AS Unique_IDs, -- 70
    COUNT(*) - COUNT(DISTINCT customer_id) AS Duplicates
FROM olist_customers_dataset

UNION ALL
-- In Orders Table => Order_ID is Primary key
SELECT
    'Orders',
    COUNT(*),
    COUNT(DISTINCT order_id),
    COUNT(*) - COUNT(DISTINCT order_id)
FROM olist_orders_dataset

UNION ALL
-- In Products => Product_ID is a primary key

SELECT
    'Products',
    COUNT(*),
    COUNT(DISTINCT product_id),
    COUNT(*) - COUNT(DISTINCT product_id)
FROM olist_products_dataset

UNION ALL
 -- In Sellers => Seller_ID is a primary_key
SELECT
    'Sellers',
    COUNT(*),
    COUNT(DISTINCT seller_id),
    COUNT(*) - COUNT(DISTINCT seller_id)
FROM olist_sellers_dataset

UNION ALL
-- in Category Translation => product_category_name is a primary_key
SELECT
    'Category Translation',
    COUNT(*),
    COUNT(DISTINCT product_category_name),
    COUNT(*) - COUNT(DISTINCT product_category_name)
FROM product_category_name_translation;

Select * From product_category_name_translation