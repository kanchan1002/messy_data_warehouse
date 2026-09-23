-- Trigger and audit examples for MySQL
CREATE DATABASE IF NOT EXISTS warehouse_db;
USE warehouse_db;

SET SQL_SAFE_UPDATES = 0;

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

DROP TRIGGER IF EXISTS data_1_after_update;
DROP TRIGGER IF EXISTS data_2_after_update;
DROP TRIGGER IF EXISTS data_3_after_update;

DELIMITER $$
CREATE TRIGGER data_1_after_update
AFTER UPDATE ON data_1
FOR EACH ROW
BEGIN
    IF NOT (OLD.quantity <=> NEW.quantity) THEN
        INSERT INTO inventory_audit
        (product_id, table_name, action_name, old_quantity, new_quantity, changed_by)
        VALUES (NEW.product_id, 'data_1', 'UPDATE', OLD.quantity, NEW.quantity, CURRENT_USER());
    END IF;
END$$

CREATE TRIGGER data_2_after_update
AFTER UPDATE ON data_2
FOR EACH ROW
BEGIN
    IF NOT (OLD.quantity <=> NEW.quantity) THEN
        INSERT INTO inventory_audit
        (product_id, table_name, action_name, old_quantity, new_quantity, changed_by)
        VALUES (NEW.product_id, 'data_2', 'UPDATE', OLD.quantity, NEW.quantity, CURRENT_USER());
    END IF;
END$$

CREATE TRIGGER data_3_after_update
AFTER UPDATE ON data_3
FOR EACH ROW
BEGIN
    IF NOT (OLD.quantity <=> NEW.quantity) THEN
        INSERT INTO inventory_audit
        (product_id, table_name, action_name, old_quantity, new_quantity, changed_by)
        VALUES (NEW.product_id, 'data_3', 'UPDATE', OLD.quantity, NEW.quantity, CURRENT_USER());
    END IF;
END$$
DELIMITER ;

-- Test the trigger with a transaction, then inspect the audit record.
SELECT 'Trigger test started' AS status;
SET @test_product_id = (SELECT MIN(product_id) FROM data_1);

SELECT @test_product_id AS test_product_id;

START TRANSACTION;
UPDATE data_1
SET quantity = COALESCE(quantity, 0) + 1
WHERE product_id = @test_product_id;
COMMIT;

SELECT * FROM inventory_audit ORDER BY audit_id DESC LIMIT 10;

SELECT 'No audit rows yet. Run Query/data.sql first.' AS note
WHERE NOT EXISTS (SELECT 1 FROM inventory_audit);
