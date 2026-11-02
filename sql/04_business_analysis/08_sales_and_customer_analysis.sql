-- SQL Business Analysis
-- Step 1: Sales Analysis by Order Status
--إجمالي قيمة المنتجات اللي اتطلبت كام؟ وقد إيه منها اتسلّم للعملاء فعلًا؟ وهل فيه طلبات اتلغت رغم إن ليها قيمة؟
SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    COUNT(oi.order_item_id) AS Total_Order_Items,
    SUM(oi.price) AS Product_Value,
    SUM(oi.freight_value) AS Freight_Value
FROM dbo.olist_orders_dataset o
LEFT JOIN dbo.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY Product_Value DESC;
--Step 2 — Monthly Sales Trend
SELECT
    YEAR(o.order_purchase_timestamp) AS Order_Year,
    MONTH(o.order_purchase_timestamp) AS Order_Month,
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    COUNT(oi.order_item_id) AS Total_Items,
    SUM(oi.price) AS Product_Sales_Value
FROM dbo.olist_orders_dataset o
INNER JOIN dbo.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY
    Order_Year,
    Order_Month;
-- MOM => Month over Month ((Current_Month- Previous_Month)/Previous_month)*100%
WITH Monthly_Sales AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        ) AS Sales_Month,

        COUNT(DISTINCT o.order_id) AS Total_Orders,

        SUM(oi.price) AS Product_Sales_Value

    FROM dbo.olist_orders_dataset o
    INNER JOIN dbo.olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'

    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
),
Sales_With_Previous AS
(
    SELECT
        Sales_Month,
        Total_Orders,
        Product_Sales_Value,

        LAG(Product_Sales_Value)
        OVER (ORDER BY Sales_Month)
            AS Previous_Month_Sales

    FROM Monthly_Sales
)
SELECT
    Sales_Month,
    Total_Orders,
    Product_Sales_Value,
    Previous_Month_Sales,
    ROUND(
        100.0 *
        (Product_Sales_Value - Previous_Month_Sales)
        / NULLIF(Previous_Month_Sales, 0),
        2
    ) AS MoM_Growth_Percent
FROM Sales_With_Previous
ORDER BY Sales_Month;
-- AOV
SELECT
    YEAR(o.order_purchase_timestamp) AS Order_Year,
    MONTH(o.order_purchase_timestamp) AS Order_Month,
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    SUM(oi.price) AS Product_Sales_Value,
    CAST(
        SUM(oi.price) * 1.0 /
        NULLIF(COUNT(DISTINCT o.order_id), 0)
        AS DECIMAL(18,2)
    ) AS Average_Order_Value
FROM dbo.olist_orders_dataset o
INNER JOIN dbo.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY
    Order_Year,
    Order_Month;
--Step 3: Customer Analysis
--How many unique customers does Olist have, and how many purchased more than once?

--Step 3.1 — Customer Purchase Frequency
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS Total_Orders
FROM dbo.olist_customers_dataset c
INNER JOIN dbo.olist_orders_dataset o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY Total_Orders DESC;
--Step 3.2: Repeat Customer Rate
WITH Customer_Orders AS
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS Total_Orders
    FROM dbo.olist_customers_dataset c
    INNER JOIN dbo.olist_orders_dataset o
        ON c.customer_id = o.customer_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS Unique_Customers,
    SUM(CASE
        WHEN Total_Orders = 1 THEN 1
        ELSE 0
    END) AS One_Time_Customers,
    SUM(CASE
        WHEN Total_Orders > 1 THEN 1
        ELSE 0
    END) AS Repeat_Customers,
    ROUND(
        100.0 * SUM(CASE
            WHEN Total_Orders > 1 THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS Repeat_Customer_Rate

FROM Customer_Orders;
--العملاء اللي بيرجعوا يشتروا، بيشتروا كام مرة بالضبط؟
WITH Customer_Orders AS
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS Total_Orders
    FROM dbo.olist_customers_dataset c
    INNER JOIN dbo.olist_orders_dataset o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    Total_Orders AS Number_Of_Orders,
    COUNT(*) AS Number_Of_Customers
FROM Customer_Orders
GROUP BY Total_Orders
ORDER BY Total_Orders;


