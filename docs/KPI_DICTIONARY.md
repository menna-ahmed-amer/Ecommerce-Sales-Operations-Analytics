# KPI dictionary, scope and reconciliation

This table ties each metric to its business question, grain and inclusion rules. Published report-card values refer to the **unfiltered dashboard screenshots**; dynamic slicers can change them.

| KPI | Business question | Logic & population | Dashboard value |
|---|---|---|---:|
| Total orders | How many orders were recorded? | distinct `order_id`, all order statuses | 99,441 |
| Delivered orders | How many orders reached delivered status? | distinct orders with `order_status = 'delivered'` | 96,478 |
| Delivered rate | What share of orders were delivered? | 96,478 / 99,441 | 97.02% |
| Ordered product value | What was the total item-level merchandise value? | sum order-item `price`; **not** payment total | R$13.59M |
| Delivered sales | How much item value belongs to delivered orders? | sum `price` in delivered order items; **freight excluded** | R$13.22M |
| Delivered units | How many individual delivered item rows? | item rows on delivered orders | 110.2K |
| Delivered AOV | Average delivered item value per delivered order? | delivered merchandise value / relevant delivered-order count | R$137.04 |
| Unique customers | How many identifiable people? | distinct `customer_unique_id` | 96,096 |
| Repeat customer rate | What fraction purchased more than once? | 2,997 / 96,096 people, **all-status historical orders** | 3.12% |
| Avg orders / customer | How frequently were orders placed? | unique orders / unique people | 1.03 |
| On-time delivery rate | What fraction of evaluable delivered orders were on time? | on-time delivered / eligible delivered with valid dates | 93.23% |
| Late orders | How many eligible deliveries missed the estimate? | order delivered to customer after estimated date | 6,534 |
| Avg review score | How was overall experience rated? | average recorded reviews, **all statuses** | 4.09 / 5 |
| Seller completion rate | What share of seller-linked orders were delivered? | seller-linked delivered orders / seller-linked orders | 97.78% |
| Sellers below 95% completion | Which high-enough-volume sellers need review? | seller completion <95% AND seller orders >=20 | 73 |
| Total payment value | How much payment value was recorded? | sum `payment_value`, **all statuses** | R$16.01M |
| Credit card share | Which payment method carries most recorded value? | credit-card value / total payment value | 78.34% |
| Multi-payment orders rate | What share of paid orders have multiple payment records? | orders with >1 payment records / paid orders | 2.98% |
| Non-delivered payment value | What recorded value belongs to non-delivered status orders? | sum payment records on orders not in delivered status | R$586.41K |

## Common defense questions

**Why is seller completion 97.78% but platform delivery 97.02%?** The denominator differs: seller-linked orders omit some platform orders without item/seller assignments and an order can be linked to multiple sellers. It is not a contradiction to have different percentages for different populations.

**Why are payment value R$16.01M and delivered sales R$13.22M different?** Payments include all order statuses, freight and potentially multiple records; delivered product sales include only item prices linked to delivered orders. Neither is automatically audited recognized/net revenue.

**Why repeat rate 3.12%?** The card uses person-level, all-status order history. This is **repeat-purchase incidence in the observed dataset**, not long-term customer retention or churn. The SQL `vw_Customers_Analysis` has a delivered-only definition; keep them distinct.

**Why is the average rating 4.09 while on-time and late deliveries show roughly 4.3 and 2.3?** Overall rating covers recorded reviews across statuses; delivery slices are subsets conditioned on delivery eligibility. The raw review file has 99,224 review records covering 98,673 distinct orders; those are not interchangeable grains.

**Why not report accuracy or model lift?** No machine learning model was trained or evaluated in the completed artifact. Late-delivery prediction is a future project idea, **not** a reported result.
