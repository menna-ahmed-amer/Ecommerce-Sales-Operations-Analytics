--View 1 — dbo.vw_Orders_Analysis
-- هنا كل صف بيمثل اوردر كامل
CREATE VIEW dbo.vw_Orders_Analysis
AS
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    -- 1. Check the shipping date sequence
    CASE
        WHEN order_delivered_carrier_date IS NOT NULL
         AND order_delivered_customer_date IS NOT NULL
         AND order_delivered_customer_date
             < order_delivered_carrier_date
        THEN 1
        ELSE 0
    END AS Invalid_Shipping_Flag,
    -- 2. Calculate delivery duration
    CASE
        WHEN order_status = 'delivered'
         AND order_delivered_customer_date IS NOT NULL
         AND order_delivered_customer_date
             >= order_purchase_timestamp
        THEN ROUND(
            DATEDIFF(
                HOUR,
                order_purchase_timestamp,
                order_delivered_customer_date
            ) / 24.0, 2
        )
        ELSE NULL
    END AS Delivery_Days,
    -- 3. Classify delivery performance
    CASE
        WHEN order_status <> 'delivered'
          OR order_delivered_customer_date IS NULL
          OR order_estimated_delivery_date IS NULL
          OR order_delivered_customer_date
             < order_purchase_timestamp
        THEN 'Not Applicable'
        WHEN CAST(order_delivered_customer_date AS DATE)
             > CAST(order_estimated_delivery_date AS DATE)
        THEN 'Late'
        ELSE 'On-Time'
    END AS Delivery_Status,
    -- 4. Calculate late delivery days
    CASE
        WHEN order_status = 'delivered'
         AND order_delivered_customer_date IS NOT NULL
         AND order_estimated_delivery_date IS NOT NULL
         AND order_delivered_customer_date
             >= order_purchase_timestamp
         AND CAST(order_delivered_customer_date AS DATE)
             > CAST(order_estimated_delivery_date AS DATE)
        THEN DATEDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        )
        ELSE NULL
    END AS Delay_Days

FROM dbo.olist_orders_dataset;
GO
--View 2 — Order Items Analysis
-- كل صف بيمثل وحدة منتج
CREATE VIEW dbo.vw_Order_Items_Analysis
AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,

    oi.price,
    oi.freight_value,
    oi.shipping_limit_date,

    o.order_status,
    o.order_purchase_timestamp,

    p.product_category_name,

    COALESCE(
        t.product_category_name_english,
        'Unknown'
    ) AS Category_English,

    CASE
        WHEN o.order_status = 'delivered'
        THEN 1
        ELSE 0
    END AS Is_Delivered

FROM dbo.olist_order_items_dataset oi

INNER JOIN dbo.olist_orders_dataset o
    ON oi.order_id = o.order_id

LEFT JOIN dbo.olist_products_dataset p
    ON oi.product_id = p.product_id

LEFT JOIN dbo.product_category_name_translation t
    ON p.product_category_name = t.product_category_name;
GO
--View 3 — Customers Analysis
-- كل صف بيمثل عميل 
CREATE VIEW dbo.vw_Customers_Analysis
AS
SELECT
    c.customer_unique_id,

    COUNT(DISTINCT o.order_id) AS Total_Orders,

    COUNT(DISTINCT CASE
        WHEN o.order_status = 'delivered'
        THEN o.order_id
    END) AS Delivered_Orders,

    MIN(o.order_purchase_timestamp) AS First_Order_Date,

    MAX(o.order_purchase_timestamp) AS Last_Order_Date,

    CASE
        WHEN COUNT(DISTINCT CASE
            WHEN o.order_status = 'delivered'
            THEN o.order_id
        END) > 1
        THEN 1
        ELSE 0
    END AS Is_Repeat_Customer

FROM dbo.olist_customers_dataset c

INNER JOIN dbo.olist_orders_dataset o
    ON c.customer_id = o.customer_id

GROUP BY c.customer_unique_id;
GO
--View 4 — Payments Analysis
--كل صف = Payment Record واحد.
CREATE VIEW dbo.vw_Payments_Analysis
AS
SELECT
    p.order_id,
    p.payment_sequential,
    p.payment_type,
    p.payment_installments,
    p.payment_value,

    o.order_status,

    CASE
        WHEN p.payment_installments <= 0
        THEN 1
        ELSE 0
    END AS Invalid_Installments_Flag,

    CASE
        WHEN p.payment_type <> 'credit_card'
        THEN 'Not Applicable'

        WHEN p.payment_installments IS NULL
          OR p.payment_installments <= 0
        THEN 'Invalid'

        WHEN p.payment_installments = 1
        THEN 'Single Payment'

        ELSE 'Installments'
    END AS Credit_Card_Installment_Group

FROM dbo.olist_order_payments_dataset p

INNER JOIN dbo.olist_orders_dataset o
    ON p.order_id = o.order_id;
GO
--View 5 — Reviews Analysis
-- كل صف عباره عن تقييم واحد لكل طلب
CREATE VIEW dbo.vw_Order_Reviews_Analysis
AS
WITH Reviews_Summary AS
(
    SELECT
        order_id,

        COUNT(*) AS Review_Count,

        ROUND(
            AVG(CAST(review_score AS FLOAT)), 2
        ) AS Average_Review_Score,

        MIN(review_score) AS Min_Review_Score,

        MAX(review_score) AS Max_Review_Score

    FROM dbo.olist_order_reviews_dataset

    GROUP BY order_id
)
SELECT
    r.order_id,
    r.Review_Count,
    r.Average_Review_Score,
    r.Min_Review_Score,
    r.Max_Review_Score,

    o.order_status,
    o.Delivery_Status

FROM Reviews_Summary r

INNER JOIN dbo.vw_Orders_Analysis o
    ON r.order_id = o.order_id;
GO
--View 6 — Geolocation Clean
CREATE OR ALTER VIEW dbo.vw_Geolocation_Clean
AS

WITH Geo_Converted AS
(
    SELECT
        geolocation_zip_code_prefix,
        TRY_CONVERT(FLOAT, geolocation_lat) AS Latitude,
        TRY_CONVERT(FLOAT, geolocation_lng) AS Longitude
    FROM dbo.olist_geolocation_dataset
),

Geo_Flagged AS
(
    SELECT
        geolocation_zip_code_prefix,
        Latitude,
        Longitude,

        CASE
            WHEN Latitude BETWEEN -35 AND 6
             AND Longitude BETWEEN -75 AND -30
            THEN 1 ELSE 0
        END AS Is_Usable
    FROM Geo_Converted
)

SELECT
    geolocation_zip_code_prefix,

    ROUND(AVG(CASE WHEN Is_Usable = 1
        THEN Latitude END), 6) AS Latitude,

    ROUND(AVG(CASE WHEN Is_Usable = 1
        THEN Longitude END), 6) AS Longitude,

    COUNT(*) AS Geo_Records_Count,

    SUM(CASE WHEN Is_Usable = 1
        THEN 1 ELSE 0 END) AS Usable_Records,

    SUM(CASE WHEN Is_Usable = 0
        THEN 1 ELSE 0 END) AS Excluded_Records,

    CASE
        WHEN SUM(Is_Usable) = 0
        THEN 'No Usable Coordinates'
        ELSE 'Usable'
    END AS Geo_Status

FROM Geo_Flagged

GROUP BY geolocation_zip_code_prefix;
GO







