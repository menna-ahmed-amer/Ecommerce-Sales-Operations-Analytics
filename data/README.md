# Original Olist Dataset — Download Instructions

This repository does not include the original raw CSV files. The dataset is available from its original publisher, Olist, on Kaggle.

## Dataset Source

**Dataset:** Brazilian E-Commerce Public Dataset by Olist  
**Publisher:** Olist  
**Source:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce  
**License:** CC BY-NC-SA 4.0

## Original Dataset Files

The source contains nine CSV files:

- `olist_customers_dataset.csv`
- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_order_payments_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `olist_products_dataset.csv`
- `olist_sellers_dataset.csv`
- `olist_geolocation_dataset.csv`
- `product_category_name_translation.csv`

## How to Reproduce the Analysis

1. Download the original dataset from the Kaggle link above.
2. Extract the nine CSV files.
3. Create a local `data/raw/` directory and place the CSV files inside it.
4. Import the source data into SQL Server, using the first CSV row as column headers.
5. Follow the SQL scripts and the [Reproducibility Guide](../docs/REPRODUCIBILITY.md) to prepare the data and rebuild the analytical views.
6. Open the Power BI dashboard and configure the data source connection if a refresh is required.

**Important:** The original translation CSV already has column headers. Do not run legacy cleanup or deletion commands against a correctly imported table without reviewing them first.

## Project Resources

- [Main Project README](../README.md)
- [SQL Scripts](../sql/)
- [Data Quality and ETL Documentation](../docs/DATA_QUALITY_AND_ETL.md)
- [KPI Dictionary](../docs/KPI_DICTIONARY.md)
- [Dataset Source and License](../DATASET_SOURCE_AND_LICENSE.md)
- [Download Power BI Dashboard](https://github.com/menna-ahmed-amer/Ecommerce-Sales-Operations-Analytics/releases/tag/v1.0.0)

## Data Availability

The raw CSV files are intentionally not stored in this GitHub repository. They can be downloaded directly from the original Kaggle source.

The SQL scripts, documentation, dashboard screenshots, reports, and downloadable Power BI file are provided to demonstrate the end-to-end analytical workflow.
