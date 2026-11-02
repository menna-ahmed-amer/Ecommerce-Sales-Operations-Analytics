-- Outlier Check
--إحنا عايزين نعرف
-- هل فيه أسعار منتجات بصفر أو بالسالب؟
-- هل فيه تكاليف شحن سالبة؟
-- كام سطر منتج تكلفة شحنه صفر؟
-- إيه أقل وأعلى سعر منتج وتكلفة شحن؟
-- Check1 => olist_order_items_dataset
SELECT
    COUNT(*) AS Total_Items,

    SUM(CASE
        WHEN price <= 0 THEN 1 ELSE 0
    END) AS Invalid_Prices,

    SUM(CASE
        WHEN freight_value < 0 THEN 1 ELSE 0
    END) AS Negative_Freight,

    SUM(CASE
        WHEN freight_value = 0 THEN 1 ELSE 0
    END) AS Zero_Freight,

    MIN(price) AS Min_Price,
    MAX(price) AS Max_Price,

    MIN(freight_value) AS Min_Freight,
    MAX(freight_value) AS Max_Freight

FROM dbo.olist_order_items_dataset;
-- Check2 => olist_order_payments_dataset
-- Invalid Payment Values
SELECT
    COUNT(*) AS Total_Payments,

    SUM(CASE
        WHEN payment_value < 0 THEN 1 ELSE 0
    END) AS Negative_Payments,

    SUM(CASE
        WHEN payment_value = 0 THEN 1 ELSE 0
    END) AS Zero_Payments,

    SUM(CASE
        WHEN payment_installments < 0 THEN 1 ELSE 0
    END) AS Negative_Installments,

    SUM(CASE
        WHEN payment_installments = 0 THEN 1 ELSE 0
    END) AS Zero_Installments,

    MIN(payment_value) AS Min_Payment,
    MAX(payment_value) AS Max_Payment,

    MIN(payment_installments) AS Min_Installments,
    MAX(payment_installments) AS Max_Installments

FROM dbo.olist_order_payments_dataset;
-- عايزين نعرف اي السبب ان فيه 9 Payments ملهمش دفع و2 ملهمش اقساط
SELECT
    order_id,
    payment_type,
    payment_sequential,
    payment_installments,
    payment_value
FROM dbo.olist_order_payments_dataset
WHERE payment_value = 0
   OR payment_installments = 0
ORDER BY payment_value, payment_installments;
-- Check3 => Review Score Validation
SELECT
    review_score,
    COUNT(*) AS Total_Reviews
FROM dbo.olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score;
-- Check4 => Products Numeric Validation
SELECT
    COUNT(*) AS Total_Products,

    SUM(CASE
        WHEN product_weight_g <= 0 THEN 1 ELSE 0
    END) AS Invalid_Weight,

    SUM(CASE
        WHEN product_length_cm <= 0 THEN 1 ELSE 0
    END) AS Invalid_Length,

    SUM(CASE
        WHEN product_height_cm <= 0 THEN 1 ELSE 0
    END) AS Invalid_Height,

    SUM(CASE
        WHEN product_width_cm <= 0 THEN 1 ELSE 0
    END) AS Invalid_Width,

    SUM(CASE
        WHEN product_photos_qty <= 0 THEN 1 ELSE 0
    END) AS Invalid_Photos,

    MIN(product_weight_g) AS Min_Weight,
    MAX(product_weight_g) AS Max_Weight

FROM dbo.olist_products_dataset;


-- Step 7: Outlier Detection
-- 1 => Order_items Percentile
--قبل ما نقرر هل الأسعار والأوزان المرتفعة Outliers فعلًا، هنفحص توزيع القيم.
SELECT DISTINCT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY price)
        OVER () AS P25_Price,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY price)
        OVER () AS Median_Price,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY price)
        OVER () AS P75_Price,

    PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY price)
        OVER () AS P99_Price

FROM dbo.olist_order_items_dataset;
-- هنا عشان اعرف عدد الصفوف اللي فعلا اكبر من P99
-- Order Outliers
WITH Price_Percentile AS
(
    SELECT DISTINCT
        PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY price)
        OVER () AS P99_Price
    FROM dbo.olist_order_items_dataset
)
SELECT
    COUNT(*) AS High_Price_Items,
    MIN(oi.price) AS Min_High_Price,
    MAX(oi.price) AS Max_High_Price
FROM dbo.olist_order_items_dataset oi
CROSS JOIN Price_Percentile p
WHERE oi.price > p.P99_Price;
--Freight Percentiles
SELECT DISTINCT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY freight_value)
        OVER () AS P25_Freight,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY freight_value)
        OVER () AS Median_Freight,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY freight_value)
        OVER () AS P75_Freight,

    PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY freight_value)
        OVER () AS P99_Freight

FROM dbo.olist_order_items_dataset;
--Freight Outliers
WITH Freight_Percentile AS
(
    SELECT DISTINCT
        PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY freight_value)
        OVER () AS P99_Freight
    FROM dbo.olist_order_items_dataset
)
SELECT
    COUNT(*) AS High_Freight_Items,
    MIN(oi.freight_value) AS Min_High_Freight,
    MAX(oi.freight_value) AS Max_High_Freight
FROM dbo.olist_order_items_dataset oi
CROSS JOIN Freight_Percentile f
WHERE oi.freight_value > f.P99_Freight;
-- Payment_value percentile
SELECT DISTINCT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY payment_value)
        OVER () AS P25_Payment,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY payment_value)
        OVER () AS Median_Payment,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY payment_value)
        OVER () AS P75_Payment,

    PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY payment_value)
        OVER () AS P99_Payment

FROM dbo.olist_order_payments_dataset;
-- Payment_value Outlier
WITH Payment_Percentile AS
(
    SELECT DISTINCT
        PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY payment_value)
        OVER () AS P99_Payment
    FROM dbo.olist_order_payments_dataset
)
SELECT
    COUNT(*) AS High_Payment_Records,
    MIN(p.payment_value) AS Min_High_Payment,
    MAX(p.payment_value) AS Max_High_Payment
FROM dbo.olist_order_payments_dataset p
CROSS JOIN Payment_Percentile pp
WHERE p.payment_value > pp.P99_Payment;
--Product Weight Percentile
SELECT DISTINCT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY product_weight_g)
        OVER () AS P25_Weight,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY product_weight_g)
        OVER () AS Median_Weight,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY product_weight_g)
        OVER () AS P75_Weight,

    PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY product_weight_g)
        OVER () AS P99_Weight

FROM dbo.olist_products_dataset
WHERE product_weight_g > 0;
-- Product Weight Outlier
WITH Weight_Percentile AS
(
    SELECT DISTINCT
        PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY product_weight_g)
        OVER () AS P99_Weight
    FROM dbo.olist_products_dataset
    WHERE product_weight_g > 0
)
SELECT
    COUNT(*) AS High_Weight_Products,
    MIN(p.product_weight_g) AS Min_High_Weight,
    MAX(p.product_weight_g) AS Max_High_Weight
FROM dbo.olist_products_dataset p
CROSS JOIN Weight_Percentile w
WHERE p.product_weight_g > w.P99_Weight;

