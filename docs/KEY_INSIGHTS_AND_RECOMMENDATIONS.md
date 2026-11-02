# Key business insights & actionable recommendations

Figures reflect the final unfiltered dashboard views and underlying original dataset; recommendations are **proposed actions, not measured outcomes**.

| Domain | Evidence | Interpretation | Recommendation | KPI to monitor |
|---|---|---|---|---|
| Orders | 97.02% delivered; 1,107 shipped | most orders were delivered, but shipped remains the largest non-delivered status | review shipment status updates and unresolved outcomes | unresolved shipped count, delivered rate |
| Availability | 625 canceled + 609 unavailable = 1,234 orders | order availability/cancellation deserve targeted diagnostics | segment issues by seller/category and investigate stock accuracy | cancellation and unavailable rates |
| Sales | R$13.22M delivered item value; +141.13% Jan–Aug 2018 vs 2017 | significant growth from a lower comparison base; monthly values later plateau | examine the later plateau rather than claim ongoing 141% growth | delivered sales trend, YoY on matched periods |
| Product mix | leading five categories account for roughly 39.8% of delivered product sales | revenue depends on major categories | track assortment availability and concentration | leading-category contribution, out-of-stock orders |
| Geography | São Paulo drives roughly R$5.07M delivered sales | demand is geographically concentrated | strengthen service in high-volume states while comparing other markets | sales by state, service reliability |
| Customers | 96,096 unique people; repeat rate ~3.12% across all statuses | most identified people order once within observed history | pilot repeat-purchase programs, then evaluate with cohorts | repeat incidence, repeat sales/customer |
| Delivery | 93.23% on-time; 6,534 late orders | even modest late incidence can have service costs | track high-delay months, sellers and regions; pilot proactive messaging | late-delivery rate, average lateness |
| Reviews | rating ~4.3 on-time vs ~2.3 late | strong negative association with late delivery | investigate avoidable delays and service recovery | rating by timeliness, late review volume |
| Sellers | 73 sellers with <95% completion and ≥20 orders | concentrated group of potentially reviewable fulfillment risk | create risk queue and investigate root causes before penalties | seller completion rate, non-delivered seller orders |
| Payments | credit cards 78.34% of payment value; R$586.41K on non-delivered statuses | strong card dependence and payment-to-status reconciliation need | reconcile payments with refunds and settlements | unmatched/non-delivered payment amounts |

## Proposed implementation horizon (not achieved results)

- **First 30 days:** baseline delayed/unresolved orders, categorize failures, review 73 eligible sellers and reconcile suspicious payment statuses.
- **Days 31–60:** test proactive delay communications and a repeat-purchase pilot using pre-specified cohort metrics.
- **Days 61–90:** expand only successful pilots and add refund/settlement and order-status history data if available.
