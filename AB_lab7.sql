select * from all_sales;

WITH sales_2022 AS (
    SELECT year, month, prd_type_id, emp_id, amount AS amount_2022
    FROM all_sales
)
SELECT * FROM (
    SELECT year, month, prd_type_id, emp_id, amount_2022,
        CASE
            WHEN emp_id IN (21, 22) THEN ROUND(amount_2022 * 1.05, 2)
            ELSE ROUND(amount_2022 * 1.1, 2)
        END AS plan_amount
    FROM
        sales_2022
)
MODEL
    PARTITION BY (year, month, prd_type_id)
    DIMENSION BY (emp_id)
    MEASURES (amount_2022, plan_amount)
    RULES (
        plan_amount[21] = ROUND(amount_2022[21] * 1.05, 2),
        plan_amount[22] = ROUND(amount_2022[22] * 1.05, 2),
        plan_amount[23] = ROUND(amount_2022[23] * 1.1, 2),
        plan_amount[24] = ROUND(amount_2022[24] * 1.1, 2)
    );

WITH sales_2 AS (
    SELECT year, month, prd_type_id, emp_id, AVG(amount) AS avg_amount_3m
    FROM all_sales
    GROUP BY year, month, prd_type_id, emp_id
)
SELECT
    *
FROM (
    SELECT year, month, prd_type_id, emp_id, avg_amount_3m,
        CASE
            WHEN emp_id IN (21, 22) THEN ROUND(avg_amount_3m * 1.05, 2)
            ELSE ROUND(avg_amount_3m * 1.1, 2)
        END AS plan_amount
    FROM
        sales_2
)
MODEL
    PARTITION BY (year, month, prd_type_id)
    DIMENSION BY (emp_id)
    MEASURES (avg_amount_3m, plan_amount)
    RULES (
        plan_amount[21] = ROUND(avg_amount_3m[21] * 1.05, 2),
        plan_amount[22] = ROUND(avg_amount_3m[22] * 1.05, 2),
        plan_amount[23] = ROUND(avg_amount_3m[23] * 1.1, 2),
        plan_amount[24] = ROUND(avg_amount_3m[24] * 1.1, 2)
    );


WITH sales_comparison AS (
    SELECT
        year,
        month,
        prd_type_id,
        emp_id,
        SUM(amount) AS total_sales
    FROM
        all_sales
    WHERE
        year = 2003
    GROUP BY
        year, month, prd_type_id, emp_id
),
max_sales_per_product AS (
    SELECT year, month, prd_type_id, MAX(total_sales) AS max_sales
    FROM sales_comparison
    GROUP BY year, month, prd_type_id
)
SELECT
    s.year,
    s.month,
    s.prd_type_id,
    s.emp_id,
    s.total_sales,
    ROUND((COALESCE(m.max_sales, 0) - COALESCE(s.total_sales, 0)) / 2 + COALESCE(s.total_sales, 0), 2) AS sales_plan
FROM
    sales_comparison s
LEFT JOIN
    max_sales_per_product m ON s.year = m.year AND s.month = m.month AND s.prd_type_id = m.prd_type_id;


