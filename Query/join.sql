-- MySQL joins across the three inventory partitions
USE warehouse_db;

-- Reusable logical view of all three tables for query examples.
WITH all_inventory AS (
    SELECT 'data_1' AS source_table, d.* FROM data_1 AS d
    UNION ALL SELECT 'data_2', d.* FROM data_2 AS d
    UNION ALL SELECT 'data_3', d.* FROM data_3 AS d
)
SELECT category, supplier, SUM(COALESCE(quantity, 0)) AS total_quantity,
       ROUND(AVG(price), 2) AS average_price
FROM all_inventory
GROUP BY category, supplier
ORDER BY category, supplier;

-- INNER JOIN: products sharing category and supplier across partitions.
SELECT a.product_id AS data_1_product_id, b.product_id AS data_2_product_id,
       a.category, a.supplier, a.product_name AS product_1, b.product_name AS product_2
FROM data_1 AS a
INNER JOIN data_2 AS b
    ON a.category = b.category AND a.supplier = b.supplier
ORDER BY a.category, a.product_id, b.product_id;

-- LEFT JOIN: compare every data_1 product with matching data_3 products.
SELECT a.product_id, a.product_name, a.warehouse,
       b.product_id AS matching_data_3_product_id,
       b.quantity AS matching_data_3_quantity
FROM data_1 AS a
LEFT JOIN data_3 AS b
    ON a.category = b.category AND a.warehouse = b.warehouse
ORDER BY a.product_id;

-- CROSS JOIN: category/supplier combinations, limited for readability.
SELECT DISTINCT a.category, b.supplier
FROM data_1 AS a
CROSS JOIN data_2 AS b
ORDER BY a.category, b.supplier
LIMIT 50;

-- SELF JOIN: products in data_1 in the same warehouse with different IDs.
SELECT a.product_id AS first_product, b.product_id AS second_product,
       a.warehouse, a.category
FROM data_1 AS a
JOIN data_1 AS b
    ON a.warehouse = b.warehouse
   AND a.product_id < b.product_id
LIMIT 50;
