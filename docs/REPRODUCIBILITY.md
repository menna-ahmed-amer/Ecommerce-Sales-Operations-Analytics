# Reproduce the SQL analysis and open the report

## Requirements

- SQL Server instance and SQL Server Management Studio (SSMS), with access to import CSVs.
- Microsoft Power BI Desktop to open the final [Olist Power BI report (.pbix)](https://github.com/menna-ahmed-amer/Ecommerce-Sales-Operations-Analytics/releases/download/v1.0.0/Olist_Ecommerce_Analysis.pbix), attached to [GitHub Release v1.0.0](https://github.com/menna-ahmed-amer/Ecommerce-Sales-Operations-Analytics/releases/tag/v1.0.0).
- The nine original CSV files, downloaded separately from [Olist on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). They are **not checked into this repository**.

## Steps

**Before step 1:** Download the Olist dataset archive from Kaggle, extract it, and place the nine CSV files in a local `data/raw/` folder alongside your project files. See [`../data/README.md`](../data/README.md). The `data/raw/` folder is not part of the published repository.

1. Create a local SQL Server database called `Olist_Ecommerce` (or update connection context and table names in the project SQL scripts).
2. Import each of the nine downloaded `data/raw/*.csv` files into the corresponding `dbo` table using SSMS's **Import Flat File** or Import Data wizard. Use the file's first row as column headers. Convert date columns to suitable datetime types and price/payment columns to numeric types; review the inferred schema before completing.
3. Confirm SQL tables are named `dbo.olist_orders_dataset`, `dbo.olist_order_items_dataset`, `dbo.olist_customers_dataset`, `dbo.olist_order_payments_dataset`, `dbo.olist_order_reviews_dataset`, `dbo.olist_products_dataset`, `dbo.olist_sellers_dataset`, `dbo.olist_geolocation_dataset`, `dbo.product_category_name_translation`.
4. Run `sql/01_data_profiling/01_row_counts.sql` and inspect the counts before continuing.
5. **Inspect** `sql/01_data_profiling/02_primary_keys_and_translation_repair.sql` before execution. Its first statements `DELETE` a duplicate header row and rename `column1/column2` in a *previously malformed* translation-table import. The original Kaggle CSV is already correctly headed: **skip those repair statements** when the table is imported correctly. Run only the applicable read-only key-check statements.
6. Run the read-only validations in `sql/02_data_quality/` and inspect results, especially invalid dates and outliers.
7. Run `sql/03_analytical_views/07_create_six_views.sql` inside `Olist_Ecommerce`. It contains `GO` batch separators and `CREATE VIEW` statements, so run it **once** on a fresh database; if views already exist, drop/alter them carefully before rerunning (do not simply rerun `CREATE VIEW`).
8. Run the business analyses in `sql/04_business_analysis/`.
9. Run `sql/05_validation/10_validate_six_views.sql` and verify each view's row counts and grain. This is a query-level check, not a formal integration-test suite.
10. Download the [Power BI `.pbix` file from GitHub Releases](https://github.com/menna-ahmed-amer/Ecommerce-Sales-Operations-Analytics/releases/download/v1.0.0/Olist_Ecommerce_Analysis.pbix) and open it in Power BI Desktop. Repoint data-source settings to the local database / desired files, inspect model relationships, refresh and validate KPI totals against the SQL/source values.

**What is not provided:** A fully automated SQL staging `CREATE TABLE` / `BULK INSERT` script or a hosted Power BI Service deployment. This is a reproducible analytical portfolio project, not a one-click production deployment.

## Known discrepancies worth validating

- SQL `vw_Customers_Analysis` uses delivered-only repeat behavior; Power BI 3.12% is all-order historical repeat incidence. Choose and document the desired definition before reconciling the two.
- Platform delivery rate, seller completion rate and on-time rate have different populations and therefore should not match.
- A status value `shipped` on a historical snapshot is not, by itself, evidence of permanent loss.
