# Technical choices and trade-offs

## Why SQL Server and T-SQL rather than Python for the completed ETL?

The work was relational: matching order keys, auditing many-row joins, validating dates, deduplicating identities, aggregating reviews, grouping ZIP prefixes and defining reusable analytical views. In this context, T-SQL offered a concise and auditable in-database workflow; it could be validated using the same SQL Server objects later consumed by reporting. **This is a project rationale, not a claim that Python would be inferior or that the author benchmarked the two.** Python could be helpful for advanced ML, automated data tests or orchestration in future work, but it was not required for the delivered SQL-and-Power-BI analysis.

## Why dimensional modeling rather than one flattened table?

Orders, items, payments and reviews do not share one natural row-grain. Flattening them creates **fan-out** when multiple order items multiply multiple payment records. Separate facts and dimension-like tables help preserve correct aggregation, slicer behavior and maintainability. The actual report is **a hybrid multi-fact dimensional model**, not an assertion of a perfect single-fact textbook star schema.

## Key trade-offs

| Choice | Benefit | Trade-off / risk | Mitigation |
|---|---|---|---|
| Keep independent facts | accurate item/payment/review grain | DAX can become more complex across facts | document denominator and bridging filter context (`TREATAS` where needed) |
| Use SQL views | reproducible, reviewable transformations | view logic depends on SQL Server schema and raw import | provide original SQL, setup steps, validation queries |
| Preserve outlier values | avoid deleting genuine expensive orders | extreme points can influence averages | P99 profiling; compare median/percentiles; no unwarranted deletion claim |
| Filter delivered orders for sales | describes completed merchandise transactions | not equal to ordered demand or accounting revenue | label the measure and exclusions consistently |
| Treat missing delivery timestamps as ineligible | avoids fabricated dates and false punctuality | smaller denominator than all delivered orders | document excluded cases and eligibility rule |
| Use `customer_unique_id` for people | correct repeat person identity | person-level and order-level IDs differ | separate dimensions and clear KPI grain |
| Use some bidirectional 1:1 relationships as modeled | can propagate needed filters | can create ambiguity or unanticipated context | explicitly test measures across slicers; consider simplification before production |
| Link original raw CSVs from Kaggle instead of redistributing them | authoritative source, clearer provenance, lighter repository | external download may require Kaggle access and dataset releases can change | document exact filenames, expected row counts and reference SHA-256 hashes; link source and license; describe local import |

## Assumptions and limitations

- All metrics describe the historical public Olist sample (2016–2018), not a current live marketplace.
- No refund or settlement records are available to label recorded payment value as realized or lost revenue.
- Low repeat incidence observed during a limited window does not measure cohort retention or customer lifetime value.
- Differences in review ratings between on-time and late groups show association, not demonstrated causal effect.
- Neither a deployed production data pipeline nor an evaluated ML model is claimed here.
