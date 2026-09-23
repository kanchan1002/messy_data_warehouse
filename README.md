# Warehouse DBMS SQL Project

This project cleans warehouse inventory data and provides MySQL scripts for loading, querying, and managing it.

## Dataset

- `Raw Data/warehouse_messy_data.csv`: original uncleaned warehouse data.
- `Cleaned_Data/warehouse_cleaned_data.csv`: cleaned dataset with normalized column names, numeric values, and dates.
- `clean_warehouse_data.py`: Python cleaning script.

The inventory columns are:

`product_id`, `product_name`, `category`, `warehouse`, `location`, `quantity`, `price`, `supplier`, `status`, `last_restocked`

## Database Tables

The cleaned records are distributed across three tables with the same structure:

- `data_1`
- `data_2`
- `data_3`

Rows are distributed deterministically using `ROW_NUMBER()` modulo 3. For 1,000 rows, the tables receive approximately 334, 333, and 333 rows.

## SQL Files

| File | Purpose |
|---|---|
| `Query/schema.sql` | Combined DDL, DML, and DCL script |
| `Query/data.sql` | Loads the cleaned CSV and distributes rows across the three tables |
| `Query/join.sql` | Inner, left, cross, and self joins |
| `Query/correlated.sql` | Correlated subquery examples |
| `Query/trigger.sql` | Quantity-change audit triggers |
| `Query/stored.sql` | Stored procedures for warehouse lookup and restocking |
| `Query/views.sql` | Consolidated inventory and stock summary views |
| `Query/Indexing.sql` | Index creation and `EXPLAIN` example |

## Requirements

- MySQL 8.0 or later
- MySQL client or MySQL Workbench
- `LOCAL INFILE` enabled for CSV loading

## Execution

Run the combined script from the project directory:

```bash
mysql --local-infile=1 -u root -p < Query/schema.sql
```

For MySQL Workbench:

1. Open the SQL script in the editor.
2. Enable Local Infile in the connection settings if prompted.
3. Make sure the database connection has access to the project folder.
4. Run the contents of `Query/schema.sql` after selecting the target schema or letting the script create `warehouse_db`.

Alternatively, run the scripts separately in this order:

```text
1. Run `Query/schema.sql` to create tables, load data, and apply DCL.
2. Run `Query/views.sql`.
3. Run `Query/trigger.sql`.
4. Run `Query/stored.sql`.
5. Run `Query/Indexing.sql`.
6. Run `Query/join.sql`.
7. Run `Query/correlated.sql`.
```

The `Query/data.sql` and `Query/schema.sql` loaders expect to be run from the project root and load `Cleaned_Data/warehouse_cleaned_data.csv`. If MySQL rejects local file loading, enable it on both the client and server, or load the CSV through MySQL Workbench.

## Important Notes

- `schema.sql` executes DDL, loads data, runs example DML, and then applies DCL permissions.
- The DCL section creates example users with placeholder passwords. Change these passwords before production use.
- Run DCL statements with a MySQL administrative account.
- The stored procedure `restock_product` updates the selected partition table and validates the requested quantity and table name.
- The trigger scripts write quantity changes to `inventory_audit`.

## Cleaning the Dataset

To regenerate the cleaned CSV:

```bash
python clean_warehouse_data.py
```
