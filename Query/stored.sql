-- Stored procedure examples for MySQL
USE warehouse_db;

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
