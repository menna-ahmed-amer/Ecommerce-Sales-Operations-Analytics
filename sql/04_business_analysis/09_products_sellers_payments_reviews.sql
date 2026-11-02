--Product & Category Performance
--أنهي تصنيفات منتجات بتحقق أعلى قيمة مبيعات؟
-- Top 10 Categories by Sales
SELECT TOP 10
    COALESCE(t.product_category_name_english, 'Unknown') AS Category,
    COUNT(DISTINCT oi.order_id) AS Total_Orders,
    COUNT(*) AS Total_Items,
    ROUND(SUM(oi.price), 2) AS Product_Sales_Value
FROM dbo.olist_order_items_dataset oi
INNER JOIN dbo.olist_orders_dataset o
    ON oi.order_id = o.order_id
LEFT JOIN dbo.olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN dbo.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY COALESCE(t.product_category_name_english, 'Unknown')
ORDER BY Product_Sales_Value DESC;
--التصنيفات الأعلى مبيعات، هل بتعتمد على بيع منتجات أغلى ولا بيع عدد أكبر من المنتجات؟
SELECT TOP 10
    COALESCE(t.product_category_name_english, 'Unknown') AS Category,
    COUNT(*) AS Total_Items,
    ROUND(SUM(oi.price), 2) AS Product_Sales_Value,
    ROUND(AVG(oi.price), 2) AS Avg_Item_Price
FROM dbo.olist_order_items_dataset oi
INNER JOIN dbo.olist_orders_dataset o
    ON oi.order_id = o.order_id
LEFT JOIN dbo.olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN dbo.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY COALESCE(t.product_category_name_english, 'Unknown')
ORDER BY Product_Sales_Value DESC;
--أنهي منتجات بعينها بتحقق أعلى قيمة مبيعات؟
SELECT TOP 10
    oi.product_id,
    COALESCE(t.product_category_name_english, 'Unknown') AS Category,
    COUNT(*) AS Units_Sold,
    COUNT(DISTINCT oi.order_id) AS Total_Orders,
    ROUND(SUM(oi.price), 2) AS Product_Sales_Value,
    ROUND(AVG(oi.price), 2) AS Avg_Selling_Price
FROM dbo.olist_order_items_dataset oi
INNER JOIN dbo.olist_orders_dataset o
    ON oi.order_id = o.order_id
LEFT JOIN dbo.olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN dbo.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY
    oi.product_id,
    t.product_category_name_english
ORDER BY Product_Sales_Value DESC;
--أنهي منتجات عليها أكبر عدد وحدات مباعة، حتى لو أسعارها قليلة؟
SELECT TOP 10
    oi.product_id,
    COALESCE(t.product_category_name_english, 'Unknown') AS Category,
    COUNT(*) AS Units_Sold,
    COUNT(DISTINCT oi.order_id) AS Total_Orders,
    ROUND(SUM(oi.price), 2) AS Product_Sales_Value,
    ROUND(AVG(oi.price), 2) AS Avg_Selling_Price
FROM dbo.olist_order_items_dataset oi
INNER JOIN dbo.olist_orders_dataset o
    ON oi.order_id = o.order_id
LEFT JOIN dbo.olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN dbo.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY
    oi.product_id,
    t.product_category_name_english
ORDER BY Units_Sold DESC, Product_Sales_Value DESC;

--Payment Analysis
--العملاء بيستخدموا أنهي طرق دفع أكتر؟
SELECT
    p.payment_type,
    COUNT(*) AS Payment_Records,
    COUNT(DISTINCT p.order_id) AS Total_Orders,
    ROUND(SUM(p.payment_value), 2) AS Total_Payment_Value
FROM dbo.olist_order_payments_dataset p
INNER JOIN dbo.olist_orders_dataset o
    ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY Total_Orders DESC;
--قد إيه العملاء بيستخدموا التقسيط؟ وهل أغلب عمليات الدفع بالكارت بتكون على قسط واحد ولا أكتر؟
SELECT
    p.payment_installments,
    COUNT(*) AS Payment_Records,
    COUNT(DISTINCT p.order_id) AS Total_Orders,
    ROUND(SUM(p.payment_value), 2) AS Total_Payment_Value
FROM dbo.olist_order_payments_dataset p
INNER JOIN dbo.olist_orders_dataset o
    ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND p.payment_type = 'credit_card'
GROUP BY p.payment_installments
ORDER BY p.payment_installments;
--Installments vs Payment Value
--هل المدفوعات المقسطة مرتبطة بمتوسط قيمة دفع أعلى من المدفوعات ذات القسط الواحد؟
SELECT
    CASE
        WHEN p.payment_installments = 1
            THEN 'Single Payment'
        ELSE 'Installments'
    END AS Payment_Group,
    COUNT(*) AS Payment_Records,
    ROUND(AVG(p.payment_value), 2)
        AS Avg_Payment_Value,
    ROUND(SUM(p.payment_value), 2)
        AS Total_Payment_Value
FROM dbo.olist_order_payments_dataset p
INNER JOIN dbo.olist_orders_dataset o
    ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND p.payment_type = 'credit_card'
  AND p.payment_installments >= 1
GROUP BY
    CASE
        WHEN p.payment_installments = 1
            THEN 'Single Payment'
        ELSE 'Installments'
    END
ORDER BY Avg_Payment_Value DESC;
--Delivery Performance
--الطلب بياخد كام يوم من وقت الشراء لحد ما يوصل للعميل؟
SELECT
    COUNT(*) AS Valid_Delivered_Orders,
    ROUND(
        AVG(
            DATEDIFF(
                HOUR,
                order_purchase_timestamp,
                order_delivered_customer_date
            ) / 24.0
        ), 2
    ) AS Avg_Delivery_Days,

    MIN(
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        )
    ) AS Min_Delivery_Days,

    MAX(
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        )
    ) AS Max_Delivery_Days

FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date >= order_purchase_timestamp;
--كام في المية من الطلبات وصلت في موعدها المتوقع أو قبله؟
SELECT
    COUNT(*) AS Total_Delivered_Orders,
    SUM(CASE
        WHEN CAST(order_delivered_customer_date AS DATE)
             <= CAST(order_estimated_delivery_date AS DATE)
        THEN 1 ELSE 0
    END) AS On_Time_Orders,
    SUM(CASE
        WHEN CAST(order_delivered_customer_date AS DATE)
             > CAST(order_estimated_delivery_date AS DATE)
        THEN 1 ELSE 0
    END) AS Late_Orders,
    ROUND(
        100.0 * SUM(CASE
            WHEN CAST(order_delivered_customer_date AS DATE)
                 <= CAST(order_estimated_delivery_date AS DATE)
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0),
        2
    ) AS On_Time_Delivery_Rate

FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_delivered_customer_date >= order_purchase_timestamp;
--الطلبات المتأخرة دي بتتأخر يوم أو يومين، ولا فيه تأخير كبير؟
SELECT
    CASE
        WHEN DATEDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        ) BETWEEN 1 AND 3
            THEN '1-3 Days'
        WHEN DATEDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        ) BETWEEN 4 AND 7
            THEN '4-7 Days'
        WHEN DATEDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        ) BETWEEN 8 AND 14
            THEN '8-14 Days'
        ELSE '15+ Days'
    END AS Delay_Group,
    COUNT(*) AS Late_Orders
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_delivered_customer_date >= order_purchase_timestamp
  AND CAST(order_delivered_customer_date AS DATE)
      > CAST(order_estimated_delivery_date AS DATE)
GROUP BY
    CASE
        WHEN DATEDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        ) BETWEEN 1 AND 3
            THEN '1-3 Days'

        WHEN DATEDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        ) BETWEEN 4 AND 7
            THEN '4-7 Days'

        WHEN DATEDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        ) BETWEEN 8 AND 14
            THEN '8-14 Days'

        ELSE '15+ Days'
    END

ORDER BY MIN(DATEDIFF(
    DAY,
    order_estimated_delivery_date,
    order_delivered_customer_date
));
--Customer Satisfaction Analysis
--تقييمات العملاء موزعة إزاي؟ وهل أغلب التقييمات إيجابية ولا سلبية؟
SELECT
    r.review_score,
    COUNT(DISTINCT r.order_id) AS Reviewed_Orders,
    COUNT(*) AS Review_Records
FROM dbo.olist_order_reviews_dataset r
INNER JOIN dbo.olist_orders_dataset o
    ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY r.review_score
ORDER BY r.review_score;
--هل الطلبات اللي بتوصل متأخرة بتحصل على تقييمات أقل من الطلبات اللي بتوصل في موعدها؟
WITH Order_Reviews AS
(
    SELECT
        order_id,
        AVG(CAST(review_score AS FLOAT)) AS Avg_Review_Score

    FROM dbo.olist_order_reviews_dataset

    GROUP BY order_id
)
SELECT
    CASE
        WHEN CAST(o.order_delivered_customer_date AS DATE)
           > CAST(o.order_estimated_delivery_date AS DATE)
        THEN 'Late'
        ELSE 'On-Time'
    END AS Delivery_Status,

    COUNT(*) AS Reviewed_Orders,

    ROUND(AVG(r.Avg_Review_Score), 2)
        AS Average_Review_Score
FROM dbo.olist_orders_dataset o
INNER JOIN Order_Reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND o.order_delivered_customer_date >= o.order_purchase_timestamp
GROUP BY
    CASE
        WHEN CAST(o.order_delivered_customer_date AS DATE)
           > CAST(o.order_estimated_delivery_date AS DATE)
        THEN 'Late'
        ELSE 'On-Time'
    END
ORDER BY Average_Review_Score DESC;
--هل اللي اتأخر يومين تقييمه مختلف عن اللي اتأخر 15 يوم؟
WITH Order_Reviews AS
(
    SELECT
        order_id,
        AVG(CAST(review_score AS FLOAT)) AS Avg_Review_Score
    FROM dbo.olist_order_reviews_dataset
    GROUP BY order_id
),
Late_Orders AS
(
    SELECT
        o.order_id,

        DATEDIFF(
            DAY,
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date
        ) AS Delay_Days,

        r.Avg_Review_Score

    FROM dbo.olist_orders_dataset o

    INNER JOIN Order_Reviews r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
      AND o.order_delivered_customer_date >= o.order_purchase_timestamp

      AND CAST(o.order_delivered_customer_date AS DATE)
          > CAST(o.order_estimated_delivery_date AS DATE)
)
SELECT
    CASE
        WHEN Delay_Days BETWEEN 1 AND 3
            THEN '1-3 Days'
        WHEN Delay_Days BETWEEN 4 AND 7
            THEN '4-7 Days'
        WHEN Delay_Days BETWEEN 8 AND 14
            THEN '8-14 Days'
        ELSE '15+ Days'
    END AS Delay_Group,
    COUNT(*) AS Reviewed_Orders,
    ROUND(AVG(Avg_Review_Score), 2)
        AS Average_Review_Score
FROM Late_Orders
GROUP BY
    CASE
        WHEN Delay_Days BETWEEN 1 AND 3
            THEN '1-3 Days'
        WHEN Delay_Days BETWEEN 4 AND 7
            THEN '4-7 Days'
        WHEN Delay_Days BETWEEN 8 AND 14
            THEN '8-14 Days'
        ELSE '15+ Days'
    END
ORDER BY MIN(Delay_Days);
--Seller Performance
--مين البائعين اللي بيحققوا أعلى قيمة مبيعات
SELECT TOP 10
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS Total_Orders,
    COUNT(*) AS Units_Sold,
    ROUND(SUM(oi.price), 2) AS Product_Sales_Value,
    ROUND(AVG(oi.price), 2) AS Avg_Item_Price
FROM dbo.olist_order_items_dataset oi
INNER JOIN dbo.olist_orders_dataset o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
ORDER BY Product_Sales_Value DESC;
--الطلبات المرتبطة بكل بائع، كام منها اتسلّم وكام اتلغى وكام لسه في حالات تانية؟
SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    COUNT(DISTINCT oi.seller_id) AS Total_Sellers
FROM dbo.olist_orders_dataset o
INNER JOIN dbo.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY Total_Orders DESC;
--أنهي بائعين عندهم نسبة أعلى من الطلبات الملغية ضمن الطلبات المرتبطة بيهم؟
SELECT TOP 10
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    COUNT(DISTINCT CASE
        WHEN o.order_status = 'canceled'
        THEN o.order_id
    END) AS Canceled_Orders,
    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN o.order_status = 'canceled'
            THEN o.order_id
        END)
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS Cancellation_Rate
FROM dbo.olist_order_items_dataset oi
INNER JOIN dbo.olist_orders_dataset o
    ON oi.order_id = o.order_id
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT o.order_id) >= 30
ORDER BY Cancellation_Rate DESC,
         Canceled_Orders DESC;





