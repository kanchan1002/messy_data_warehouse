-- Views for consolidated warehouse reporting
USE warehouse_db;

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

CREATE OR REPLACE VIEW warehouse_stock_summary AS
SELECT warehouse,
       COUNT(*) AS product_count,
       COALESCE(SUM(quantity), 0) AS total_units,
       ROUND(AVG(price), 2) AS average_price,
       SUM(status = 'In Stock') AS in_stock_products,
       SUM(status = 'Out of Stock') AS out_of_stock_products
FROM inventory_all
GROUP BY warehouse;

CREATE OR REPLACE VIEW low_stock_products AS
SELECT *
FROM inventory_all
WHERE quantity IS NULL OR quantity < 100;

SELECT * FROM warehouse_stock_summary ORDER BY warehouse;
SELECT * FROM low_stock_products ORDER BY warehouse, product_id;
