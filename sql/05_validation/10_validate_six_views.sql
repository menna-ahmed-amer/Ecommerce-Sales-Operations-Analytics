
-- Final Validation for all 6 Views

SELECT
    '01 - Orders' AS View_Name,
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT order_id) AS Unique_Keys,
    SUM(CASE WHEN Delivery_Status = 'Late'
        THEN 1 ELSE 0 END) AS Check_Value
FROM dbo.vw_Orders_Analysis

UNION ALL

SELECT
    '02 - Order Items',
    COUNT(*),
    COUNT(DISTINCT order_id),
    SUM(CASE WHEN Is_Delivered = 1
        THEN 1 ELSE 0 END)
FROM dbo.vw_Order_Items_Analysis

UNION ALL

SELECT
    '03 - Customers',
    COUNT(*),
    COUNT(DISTINCT customer_unique_id),
    SUM(CASE WHEN Is_Repeat_Customer = 1
        THEN 1 ELSE 0 END)
FROM dbo.vw_Customers_Analysis

UNION ALL

SELECT
    '04 - Payments',
    COUNT(*),
    COUNT(DISTINCT order_id),
    SUM(CASE WHEN Invalid_Installments_Flag = 1
        THEN 1 ELSE 0 END)
FROM dbo.vw_Payments_Analysis

UNION ALL

SELECT
    '05 - Reviews',
    COUNT(*),
    COUNT(DISTINCT order_id),
    SUM(CASE WHEN Review_Count > 1
        THEN 1 ELSE 0 END)
FROM dbo.vw_Order_Reviews_Analysis

UNION ALL

SELECT
    '06 - Geolocation',
    COUNT(*),
    COUNT(DISTINCT geolocation_zip_code_prefix),
    SUM(Excluded_Records)
FROM dbo.vw_Geolocation_Clean;
