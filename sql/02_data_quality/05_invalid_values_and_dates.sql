-- Step 5: Invalid Values & Dates
-- هنا محتاجين نفهم حالات الطلب قبل التحليل
SELECT
    order_status,
    COUNT(*) AS Total_Orders
FROM dbo.olist_orders_dataset
GROUP BY order_status
ORDER BY Total_Orders DESC;
-- Delivered Status => لوحدها مش كفاية لتاكيد سلامة التوصيل يبقى لازم نفحص التواريخ
SELECT
  COUNT(*) AS Total_Delivered_Orders,

  SUM(CASE
        WHEN order_delivered_customer_date IS NULL
        THEN 1 ELSE 0
    END) AS Missing_Delivery_Date,

      SUM(CASE
        WHEN order_delivered_customer_date < order_purchase_timestamp
        THEN 1 ELSE 0
    END) AS Delivery_Before_Purchase    
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered';

-- Date Sequence Validation
-- Purchase → Approval → Carrier → Customer Delivery
SELECT
    COUNT(*) AS Total_Orders,
	-- الاحدث والاقدم
    SUM(CASE
        WHEN order_approved_at < order_purchase_timestamp
        THEN 1 ELSE 0
    END) AS Approval_Before_Purchase,

    SUM(CASE
        WHEN order_delivered_carrier_date < order_approved_at
        THEN 1 ELSE 0
    END) AS Carrier_Before_Approval,

    SUM(CASE
        WHEN order_delivered_customer_date < order_delivered_carrier_date
        THEN 1 ELSE 0
    END) AS Customer_Before_Carrier

FROM dbo.olist_orders_dataset;
-- لقيت ان فيه مشكلة لذلك لازم نفحص فرق التوقيت للحالات غير الطبيعية
SELECT
    order_id,
    order_status,
    order_approved_at,
    order_delivered_carrier_date,

    DATEDIFF(
        MINUTE,
        order_delivered_carrier_date,
        order_approved_at
    ) AS Difference_Minutes

FROM dbo.olist_orders_dataset

WHERE order_delivered_carrier_date < order_approved_at

ORDER BY Difference_Minutes DESC;
--فحص Customer Before Carrier
SELECT
    order_id,
    order_status,
    order_delivered_carrier_date,
    order_delivered_customer_date,

    DATEDIFF(
        MINUTE,
        order_delivered_customer_date,
        order_delivered_carrier_date
    ) AS Difference_Minutes

FROM dbo.olist_orders_dataset

WHERE order_delivered_customer_date < order_delivered_carrier_date

ORDER BY Difference_Minutes DESC;

