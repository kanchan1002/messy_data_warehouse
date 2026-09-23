-- Stored procedure examples for MySQL
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

CREATE OR REPLACE VIEW inventory_all AS
SELECT 'data_1' AS source_table, product_id, product_name, category, warehouse,
       location, quantity, price, supplier, status, last_restocked
FROM data_1
UNION ALL
SELECT 'data_2', product_id, product_name, category, warehouse,
       location, quantity, price, supplier, status, last_restocked
FROM data_2
UNION ALL
SELECT 'data_3', product_id, product_name, category, warehouse,
       location, quantity, price, supplier, status, last_restocked
FROM data_3;

DROP PROCEDURE IF EXISTS get_inventory_by_warehouse;
DROP PROCEDURE IF EXISTS restock_product;

DELIMITER $$
CREATE PROCEDURE get_inventory_by_warehouse(IN requested_warehouse VARCHAR(50))
BEGIN
    SELECT *
    FROM inventory_all
    WHERE warehouse = requested_warehouse
    ORDER BY category, product_name, product_id;
END$$

CREATE PROCEDURE restock_product(
    IN requested_product_id INT,
    IN additional_quantity INT,
    IN target_table VARCHAR(10)
)
BEGIN
    IF additional_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'additional_quantity must be greater than zero';
    ELSEIF target_table = 'data_1' THEN
        UPDATE data_1
        SET quantity = COALESCE(quantity, 0) + additional_quantity,
            status = 'In Stock'
        WHERE product_id = requested_product_id;
    ELSEIF target_table = 'data_2' THEN
        UPDATE data_2
        SET quantity = COALESCE(quantity, 0) + additional_quantity,
            status = 'In Stock'
        WHERE product_id = requested_product_id;
    ELSEIF target_table = 'data_3' THEN
        UPDATE data_3
        SET quantity = COALESCE(quantity, 0) + additional_quantity,
            status = 'In Stock'
        WHERE product_id = requested_product_id;
    ELSE
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'target_table must be data_1, data_2, or data_3';
    END IF;
END$$
DELIMITER ;

CALL get_inventory_by_warehouse('Warehouse 1');
-- Example: CALL restock_product(1102, 50, 'data_1');
