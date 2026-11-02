-- To Check the number of columns and Nulls

SELECT 'Customers' AS Table_Name, COUNT_BIG(*) AS Total_Rows
FROM dbo.olist_customers_dataset

UNION ALL
SELECT 'Orders', COUNT_BIG(*)
FROM dbo.olist_orders_dataset

UNION ALL
SELECT 'Order Items', COUNT_BIG(*)
FROM dbo.olist_order_items_dataset

UNION ALL
SELECT 'Payments', COUNT_BIG(*)
FROM dbo.olist_order_payments_dataset

UNION ALL
SELECT 'Reviews', COUNT_BIG(*)
FROM dbo.olist_order_reviews_dataset

UNION ALL
SELECT 'Products', COUNT_BIG(*)
FROM dbo.olist_products_dataset

UNION ALL
SELECT 'Sellers', COUNT_BIG(*)
FROM dbo.olist_sellers_dataset

UNION ALL
SELECT 'Geolocation', COUNT_BIG(*)
FROM dbo.olist_geolocation_dataset

UNION ALL
SELECT 'Category Translation', COUNT_BIG(*)
FROM dbo.product_category_name_translation;




