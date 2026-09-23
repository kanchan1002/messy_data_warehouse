-- Combined MySQL schema script: DDL, DML, and DCL
-- Recommended execution order: definitions, data operations, permissions.
SET GLOBAL local_infile = 1;

/* ================================
   DDL: database and table definitions
   ================================ */
CREATE DATABASE IF NOT EXISTS warehouse_db;
USE warehouse_db;

CREATE TABLE IF NOT EXISTS data_1 (
    product_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    warehouse VARCHAR(50) NOT NULL,
    location VARCHAR(50) NOT NULL,
    quantity INT NULL,
    price DECIMAL(10, 2) NULL,
    supplier VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL,
    last_restocked DATE NULL,
    PRIMARY KEY (product_id)
);

CREATE TABLE IF NOT EXISTS data_2 LIKE data_1;
CREATE TABLE IF NOT EXISTS data_3 LIKE data_1;

CREATE TABLE IF NOT EXISTS inventory_audit (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    table_name VARCHAR(30) NOT NULL,
    action_name VARCHAR(20) NOT NULL,
    old_quantity INT NULL,
    new_quantity INT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(255) NOT NULL
);

/* ================================
   DML: data loading and operations
   ================================ */
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

LOAD DATA LOCAL INFILE 'C:/Users/ANAND HARAK/pma dashboard/KANCHAN DBMS/Cleaned_Data/warehouse_cleaned_data.csv'
INTO TABLE warehouse_stage
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, product_name, category, warehouse, location, @quantity, @price, supplier, status, @last_restocked)
SET
    quantity = NULLIF(TRIM(@quantity), ''),
    price = NULLIF(TRIM(@price), ''),
    last_restocked = COALESCE(
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

-- Example read, insert, update, delete, and transaction operations.
SELECT * FROM data_1;
SELECT * FROM data_2;
SELECT * FROM data_3;

INSERT INTO data_1
(product_id, product_name, category, warehouse, location, quantity, price, supplier, status, last_restocked)
VALUES
(900001, 'sample product', 'TEST', 'Warehouse 1', 'Aisle 1', 25, 12.50, 'Supplier A', 'In Stock', CURRENT_DATE);

UPDATE data_1
SET quantity = quantity + 10,
    status = CASE WHEN quantity + 10 > 0 THEN 'In Stock' ELSE 'Out of Stock' END
WHERE product_id = 900001;

DELETE FROM data_1 WHERE product_id = 900001;

START TRANSACTION;
UPDATE data_1 SET quantity = quantity - 5 WHERE product_id = 1102 AND quantity >= 5;
UPDATE data_2 SET quantity = quantity + 5 WHERE product_id = 1435;
COMMIT;

SELECT COUNT(*) AS total_rows
FROM (
    SELECT product_id FROM data_1
    UNION ALL SELECT product_id FROM data_2
    UNION ALL SELECT product_id FROM data_3
) AS all_inventory;

/* ================================
   DCL: roles, users, and privileges
   Execute this section with an administrative account.
   ================================ */
CREATE ROLE IF NOT EXISTS warehouse_readonly;
CREATE ROLE IF NOT EXISTS warehouse_operator;

GRANT SELECT ON warehouse_db.* TO warehouse_readonly;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON warehouse_db.* TO warehouse_operator;

-- Replace these example passwords before production use.
CREATE USER IF NOT EXISTS 'warehouse_reader'@'localhost' IDENTIFIED BY 'ChangeThisReaderPassword!';
CREATE USER IF NOT EXISTS 'warehouse_operator'@'localhost' IDENTIFIED BY 'ChangeThisOperatorPassword!';

GRANT warehouse_readonly TO 'warehouse_reader'@'localhost';
GRANT warehouse_operator TO 'warehouse_operator'@'localhost';
SET DEFAULT ROLE warehouse_readonly TO 'warehouse_reader'@'localhost';
SET DEFAULT ROLE warehouse_operator TO 'warehouse_operator'@'localhost';

SHOW GRANTS FOR 'warehouse_reader'@'localhost';
-- REVOKE DELETE ON warehouse_db.* FROM 'warehouse_operator';
-- DROP USER 'warehouse_reader'@'localhost';
