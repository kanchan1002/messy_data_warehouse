-- Indexing examples for MySQL
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

CREATE INDEX IF NOT EXISTS idx_data_1_category_supplier ON data_1 (category, supplier);
CREATE INDEX IF NOT EXISTS idx_data_2_category_supplier ON data_2 (category, supplier);
CREATE INDEX IF NOT EXISTS idx_data_3_category_supplier ON data_3 (category, supplier);

CREATE INDEX IF NOT EXISTS idx_data_1_warehouse_status ON data_1 (warehouse, status);
CREATE INDEX IF NOT EXISTS idx_data_2_warehouse_status ON data_2 (warehouse, status);
CREATE INDEX IF NOT EXISTS idx_data_3_warehouse_status ON data_3 (warehouse, status);

CREATE INDEX IF NOT EXISTS idx_data_1_restocked ON data_1 (last_restocked);
CREATE INDEX IF NOT EXISTS idx_data_2_restocked ON data_2 (last_restocked);
CREATE INDEX IF NOT EXISTS idx_data_3_restocked ON data_3 (last_restocked);

-- Confirm index definitions and inspect the query plan.
SHOW INDEX FROM data_1;
EXPLAIN SELECT * FROM data_1
WHERE category = 'ELECTRONICS' AND supplier = 'Supplier B';
