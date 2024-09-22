-- Вариант 11 - Котнроль Исполнения
-- Вычисление итогов выполненных поручений помесячно, за квартал, за полгода, за год.
select 
    extract(year from deadline) as year,
    extract(month from deadline) as month,
    sum(case when statusid = 4 then 1 else 0 end) over (partition by extract(year from deadline)) as taskscompleted,
    sum(case when statusid = 4 then 1 else 0 end) over (partition by extract(year from deadline), to_char(deadline, 'Q') order by extract(month from deadline) rows between 2 preceding and current row) as taskscompletedquarter,
    sum(case when statusid = 4 then 1 else 0 end) over (partition by extract(year from deadline) order by extract(month from deadline) rows between 5 preceding and current row) as taskscompletedhalfyear,
    sum(case when statusid = 4 then 1 else 0 end) over (partition by extract(year from deadline) order by extract(month from deadline) rows between 11 preceding and current row) as taskscompletedyear
from 
    tasks
where 
    deadline <= sysdate
order by 
    year, month;
    
    
-- Для Oracle
-- Вычисление итогов выполненных поручений за определенный период
-- • количество выполненных поручений;
-- • сравнение их с общим количеством выполненных поручений (в %);
-- • сравнение с общим количеством не выполненных поручений (в %).

WITH TotalCompletedTasks AS (
    SELECT
        COUNT(CASE WHEN statusid = 4 THEN 1 END) AS totalcompleted
    FROM
        tasks
),
CompletedTasks AS (
    SELECT
        COUNT(CASE WHEN statusid = 4 THEN 1 END) AS completed
    FROM
        tasks
    WHERE
        deadline BETWEEN TO_DATE('2024-01-23', 'YYYY-MM-DD') AND TO_DATE('2024-02-24', 'YYYY-MM-DD')
)
SELECT
    completed,
    completed * 100.0 / totalcompleted AS completedpercentage,
    (totalcompleted - completed) * 100.0 / totalcompleted AS incompletepercentage
FROM
    CompletedTasks, TotalCompletedTasks;

-- Вернуть для каждого сотрудника количество выполненных и не выполненных заданий за последние 6 месяцев помесячно.
SELECT 
    u.userid,
    u.username,
    EXTRACT(YEAR FROM t.deadline) AS year,
    EXTRACT(MONTH FROM t.deadline) AS month,
    SUM(CASE WHEN t.statusid = 4 THEN 1 ELSE 0 END) OVER (PARTITION BY u.userid, EXTRACT(YEAR FROM t.deadline), EXTRACT(MONTH FROM t.deadline)) AS completedtasks,
    SUM(CASE WHEN t.statusid <> 4 THEN 1 ELSE 0 END) OVER (PARTITION BY u.userid, EXTRACT(YEAR FROM t.deadline), EXTRACT(MONTH FROM t.deadline)) AS incompletetasks
FROM 
    users u
JOIN 
    tasks t ON u.userid = t.assignedtouserid
          AND t.deadline >= ADD_MONTHS(CURRENT_DATE, -6)
          AND t.deadline <= CURRENT_DATE;
          
-- Какой сотрудник выполнил наибольшее число поручений определенного вида? Вернуть для всех видов.
WITH TaskCounts AS (
    SELECT
        u.userid,
        u.username,
        tc.categoryid,
        tc.categoryname,
        COUNT(CASE WHEN t.statusid = 4 THEN 1 END) AS completedtasks
    FROM
        users u
    JOIN
        tasks t ON u.userid = t.assignedtouserid
    JOIN
        taskcategories tc ON t.categoryid = tc.categoryid
    GROUP BY
        u.userid,
        u.username,
        tc.categoryid,
        tc.categoryname
),
RankedTaskCounts AS (
    SELECT
        userid,
        username,
        categoryid,
        categoryname,
        completedtasks,
        ROW_NUMBER() OVER (PARTITION BY categoryid ORDER BY completedtasks DESC) AS rank
    FROM
        TaskCounts
)
SELECT
    userid,
    username,
    categoryid,
    categoryname,
    completedtasks
FROM
    RankedTaskCounts
WHERE
    rank = 1;

          
          


