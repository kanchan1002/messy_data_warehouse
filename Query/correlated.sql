-- Correlated subqueries in MySQL
USE warehouse_db;

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
