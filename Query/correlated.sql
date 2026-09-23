-- Correlated subqueries in MySQL
CREATE DATABASE IF NOT EXISTS warehouse_db;
USE warehouse_db;

SELECT 'Dataset check' AS status,
       (SELECT COUNT(*) FROM data_1) +
       (SELECT COUNT(*) FROM data_2) +
       (SELECT COUNT(*) FROM data_3) AS total_rows;

SELECT 'Run Query/data.sql first if this value is 0.' AS note
WHERE (SELECT COUNT(*) FROM data_1) +
      (SELECT COUNT(*) FROM data_2) +
      (SELECT COUNT(*) FROM data_3) = 0;

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

-- Products whose price is above the average price in their own category.
SELECT i.product_id, i.product_name, i.category, i.price
FROM (
    SELECT * FROM data_1
    UNION ALL SELECT * FROM data_2
    UNION ALL SELECT * FROM data_3
) AS i
WHERE i.price > (
    SELECT AVG(category_rows.price)
    FROM (
        SELECT * FROM data_1
        UNION ALL SELECT * FROM data_2
        UNION ALL SELECT * FROM data_3
    ) AS category_rows
    WHERE category_rows.category = i.category
);

-- Warehouses containing at least one out-of-stock product.
SELECT DISTINCT outer_rows.warehouse
FROM (
    SELECT * FROM data_1
    UNION ALL SELECT * FROM data_2
    UNION ALL SELECT * FROM data_3
) AS outer_rows
WHERE EXISTS (
    SELECT 1
    FROM (
        SELECT * FROM data_1
        UNION ALL SELECT * FROM data_2
        UNION ALL SELECT * FROM data_3
    ) AS inner_rows
    WHERE inner_rows.warehouse = outer_rows.warehouse
      AND inner_rows.status = 'Out of Stock'
);

-- Products with quantity greater than every product from the same warehouse.
SELECT outer_rows.product_id, outer_rows.product_name, outer_rows.warehouse,
       outer_rows.quantity
FROM (
    SELECT * FROM data_1
    UNION ALL SELECT * FROM data_2
    UNION ALL SELECT * FROM data_3
) AS outer_rows
WHERE outer_rows.quantity IS NOT NULL
  AND outer_rows.quantity > ALL (
      SELECT inner_rows.quantity
      FROM (
          SELECT * FROM data_1
          UNION ALL SELECT * FROM data_2
          UNION ALL SELECT * FROM data_3
      ) AS inner_rows
      WHERE inner_rows.warehouse = outer_rows.warehouse
        AND inner_rows.quantity IS NOT NULL
        AND inner_rows.product_id <> outer_rows.product_id
  );
