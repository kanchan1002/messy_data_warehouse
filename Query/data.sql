-- DML data load: distribute cleaned CSV rows across three tables
-- Run from the project root containing Cleaned_Data/warehouse_cleaned_data.csv.
CREATE DATABASE IF NOT EXISTS warehouse_db;
USE warehouse_db;

DROP TEMPORARY TABLE IF EXISTS warehouse_stage;
CREATE TEMPORARY TABLE warehouse_stage (
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    warehouse VARCHAR(50),
    location VARCHAR(50),
    quantity INT NULL,
    price DECIMAL(10, 2) NULL,
    supplier VARCHAR(50),
    status VARCHAR(30),
    last_restocked DATE NULL
);

LOAD DATA LOCAL INFILE 'Cleaned_Data/warehouse_cleaned_data.csv'
INTO TABLE warehouse_stage
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, product_name, category, warehouse, location, quantity, price, supplier, status, @last_restocked)
SET last_restocked = COALESCE(
    STR_TO_DATE(NULLIF(TRIM(@last_restocked), ''), '%Y-%m-%d'),
    STR_TO_DATE(NULLIF(TRIM(@last_restocked), ''), '%d/%m/%Y')
);

TRUNCATE TABLE data_1;
TRUNCATE TABLE data_2;
TRUNCATE TABLE data_3;

INSERT INTO data_1
SELECT product_id, product_name, category, warehouse, location, quantity, price,
       supplier, status, last_restocked
FROM (
    SELECT warehouse_stage.*, ROW_NUMBER() OVER (ORDER BY product_id) AS row_num
    FROM warehouse_stage
) AS numbered_rows
WHERE MOD(row_num, 3) = 1;

INSERT INTO data_2
SELECT product_id, product_name, category, warehouse, location, quantity, price,
       supplier, status, last_restocked
FROM (
    SELECT warehouse_stage.*, ROW_NUMBER() OVER (ORDER BY product_id) AS row_num
    FROM warehouse_stage
) AS numbered_rows
WHERE MOD(row_num, 3) = 2;

INSERT INTO data_3
SELECT product_id, product_name, category, warehouse, location, quantity, price,
       supplier, status, last_restocked
FROM (
    SELECT warehouse_stage.*, ROW_NUMBER() OVER (ORDER BY product_id) AS row_num
    FROM warehouse_stage
) AS numbered_rows
WHERE MOD(row_num, 3) = 0;

SELECT 'data_1' AS table_name, COUNT(*) AS row_count FROM data_1
UNION ALL SELECT 'data_2', COUNT(*) FROM data_2
UNION ALL SELECT 'data_3', COUNT(*) FROM data_3;
