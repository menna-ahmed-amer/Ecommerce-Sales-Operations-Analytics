# Data profiling, cleaning and SQL transformations

## What was actually checked

My SQL scripts cover: row counts; primary and composite key checks; duplicate observations; foreign-key/orphan validation; invalid values and chronological dates; outlier profiling using `PERCENTILE_CONT`; creation of six analysis views; and reconciliation of output row/key counts. The scripts contain **checks and derived flags**, not a universal deletion of every anomalous row.

## Evidence from the original CSVs

| Observation | Verified value | Why it matters / treatment |
|---|---:|---|
| Unique order records | 99,441 | denominator for full-platform delivery rate |
| Orders marked delivered | 96,478 | operational completion cohort |
| Delivered orders without `order_delivered_customer_date` | 8 | exclude from metrics requiring actual delivery dates; do not invent a date |
| Orders with no item records across statuses | 775 | preserve in order-level counts, not product/item sums |
| Of those no-item orders: unavailable + canceled | 603 + 164 = 767 | diagnosing order availability/cancellation, not all no-item statuses |
| Payments with `payment_value = 0` | 9 | monitor/validate; not positive value transactions |
| Payments with `payment_installments = 0` | 2 | flag invalid installment count instead of treating as a plan |
| `customer_id` unique | 99,441 | assigned to order-level customer records |
| `customer_unique_id` unique | 96,096 | identity across repeat transactions |

## Actual view-level transformations

| SQL view | Grain / key | Why it was built |
|---|---|---|
| `dbo.vw_Orders_Analysis` | `order_id` | creates `Invalid_Shipping_Flag`, `Delivery_Days`, `Delivery_Status`, and `Delay_Days` based on status/date validation |
| `dbo.vw_Order_Items_Analysis` | (`order_id`,`order_item_id`) | joins items to order status, product category and English category translation; provides `Is_Delivered` |
| `dbo.vw_Customers_Analysis` | `customer_unique_id` | groups order history to person level and derives counts / first/last dates / repeat flag (see scope note below) |
| `dbo.vw_Payments_Analysis` | (`order_id`,`payment_sequential`) | preserves payment-record grain, flags invalid installments and creates credit-card installment groups |
| `dbo.vw_Order_Reviews_Analysis` | `order_id` | aggregates multi-row raw reviews to order-level scores and review counts before combining with order-level status |
| `dbo.vw_Geolocation_Clean` | ZIP prefix | `TRY_CONVERT` coordinates, Brazil-range eligibility, average usable coordinates, usable/excluded counts and quality flag |

### Why these approaches?

- **Derived flags instead of blind deletion:** keeps auditability and makes eligibility a reporting definition rather than an undocumented change to the source.
- **Pre-aggregating reviews to `order_id`:** prevents multiple reviews multiplying order-level measures and supports one-row-per-reviewed-order summaries.
- **`COUNT(DISTINCT)` and explicit grains:** protect order counts from duplication after joins.
- **SQL views instead of an untracked manual spreadsheet workflow:** reusable, reviewable T-SQL logic that can be rerun before Power BI loads.
- **Outlier profiling (P99) rather than automatic trimming:** large prices and freight charges may be valid; anomaly classification requires context.

### Scope distinction to explain in an interview

`vw_Customers_Analysis` determines repeat status from **delivered orders**, whereas the reported Power BI dashboard shows **3.12% repeat customers across all order statuses** in the historical data (2,997 of 96,096 people). These are **different definitions**, not interchangeable numerator/denominator pairs. If reproducing the dashboard measure, inspect the actual DAX rather than assuming it matches the SQL view's delivered-only flag.

### Reproduction caution

The original script `02_primary_keys_and_translation_repair.sql` includes a special-case `DELETE` and `sp_rename` for a previously mis-imported category translation table. Your included CSV already has correct column headers. Skip the repair section unless the SQL Server table truly contains legacy generic `column1` / `column2` headers; always take a backup and inspect before executing destructive SQL.
