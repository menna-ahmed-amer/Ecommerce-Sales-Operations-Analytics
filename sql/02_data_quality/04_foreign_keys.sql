-- Step 3: Foreign Key Validation
-- Orphan Record => دا معناه ان جدول ال Orders فيه اوردر مش مرتبط بعميل في جدول ال Cust
-- Orphan Record => يعني سجل مش لاقي السجل الأساسي اللي المفروض يرتبط بيه

-- Check1 => -- Orders → Customers
SELECT
    COUNT(*) AS Orphan_Orders
FROM dbo.olist_orders_dataset o
LEFT JOIN dbo.olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
-- Check2 => Order Items → Orders
SELECT
    COUNT(*) AS Orphan_Order_Items
FROM dbo.olist_order_items_dataset oi
LEFT JOIN dbo.olist_orders_dataset o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
-- Check2 => Order Items → Products
SELECT
    COUNT(*) AS Orphan_Products
FROM dbo.olist_order_items_dataset oi
LEFT JOIN dbo.olist_products_dataset p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
-- Check3 => Order Items → Sellers
SELECT
    COUNT(*) AS Orphan_Sellers
FROM dbo.olist_order_items_dataset oi
LEFT JOIN dbo.olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;
-- Check4 => Order Items → Sellers
SELECT
    COUNT(*) AS Orphan_Payments
FROM dbo.olist_order_payments_dataset p
LEFT JOIN dbo.olist_orders_dataset o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;
-- Check5 => Reviews → Orders
SELECT
    COUNT(*) AS Orphan_Reviews
FROM dbo.olist_order_reviews_dataset r
LEFT JOIN dbo.olist_orders_dataset o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;
-- Check5 => Products → Category Translation (Lookup Translation)
SELECT
    COUNT(*) AS Missing_Translations
FROM dbo.olist_products_dataset p
LEFT JOIN dbo.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL
  AND p.product_category_name IS NOT NULL;
-- Check Product Names
SELECT
    p.product_category_name,
    COUNT(*) AS Products_Count
FROM dbo.olist_products_dataset p
LEFT JOIN dbo.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL
  AND p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY Products_Count DESC;



