-- Indexing examples for MySQL
USE warehouse_db;

CREATE INDEX idx_data_1_category_supplier ON data_1 (category, supplier);
CREATE INDEX idx_data_2_category_supplier ON data_2 (category, supplier);
CREATE INDEX idx_data_3_category_supplier ON data_3 (category, supplier);

CREATE INDEX idx_data_1_warehouse_status ON data_1 (warehouse, status);
CREATE INDEX idx_data_2_warehouse_status ON data_2 (warehouse, status);
CREATE INDEX idx_data_3_warehouse_status ON data_3 (warehouse, status);

CREATE INDEX idx_data_1_restocked ON data_1 (last_restocked);
CREATE INDEX idx_data_2_restocked ON data_2 (last_restocked);
CREATE INDEX idx_data_3_restocked ON data_3 (last_restocked);

-- Confirm index definitions and inspect the query plan.
SHOW INDEX FROM data_1;
EXPLAIN SELECT * FROM data_1
WHERE category = 'ELECTRONICS' AND supplier = 'Supplier B';
