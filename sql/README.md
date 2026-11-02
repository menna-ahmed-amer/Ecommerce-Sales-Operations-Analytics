# SQL analysis scripts

**Dialect:** Microsoft SQL Server / T-SQL. **Source:** my original SQL project scripts. Each source script is represented exactly once; original Arabic/English comments were converted to UTF-8 for GitHub readability. T-SQL statements were not rewritten or newly invented.

| Order | Script | Purpose |
|---|---|---|
| 01 | `01_data_profiling/01_row_counts.sql` | record counts for all nine tables |
| 02 | `01_data_profiling/02_primary_keys_and_translation_repair.sql` | PK profiling; includes **legacy destructive translation repair** (see warning) |
| 03 | `02_data_quality/03_composite_keys_and_duplicates.sql` | composite and full-row duplicate checks |
| 04 | `02_data_quality/04_foreign_keys.sql` | orphan / missing foreign references |
| 05 | `02_data_quality/05_invalid_values_and_dates.sql` | order statuses, missing/invalid chronology, numeric validity |
| 06 | `02_data_quality/06_outlier_profiling.sql` | PERCENTILE_CONT and distribution diagnostics |
| 07 | `03_analytical_views/07_create_six_views.sql` | six SQL Server views with business derivations |
| 08 | `04_business_analysis/08_sales_and_customer_analysis.sql` | sales, time trends, `LAG`, order/customer analysis |
| 09 | `04_business_analysis/09_products_sellers_payments_reviews.sql` | categories, products, sellers, reviews, payments |
| 10 | `05_validation/10_validate_six_views.sql` | validation queries for all six views |

**Important:** The second script contains a `DELETE FROM` and `EXEC sp_rename` for a legacy incorrectly imported translation table. If the columns are already named `product_category_name` and `product_category_name_english`, **do not run those repair statements**. Review first; the repository intentionally preserves the original code for transparency.

Other SQL scripts are intended for profiling/querying or creating views and assume the raw CSV data has already been imported into correctly named `dbo` tables. See [`docs/REPRODUCIBILITY.md`](../docs/REPRODUCIBILITY.md).
