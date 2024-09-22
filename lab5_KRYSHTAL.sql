-- Вариант 11 - Котнроль Исполнения
-- Вычисление итогов выполненных поручений помесячно, за квартал, за полгода, за год.
select 
    year(deadline) as Year,
    deadline as Month,
    sum(case when statusid = 4 then 1 else 0 end) over (partition by year(deadline)) as TasksCompleted,
    sum(case when statusid = 4 then 1 else 0 end) over (partition by year(deadline), datepart(quarter, deadline) order by month(deadline) rows between 2 preceding and current row) as TasksCompletedQuarter,
    sum(case when statusid = 4 then 1 else 0 end) over (partition by year(deadline) order by month(deadline) rows between 5 preceding and current row) as TasksCompletedHalfYear,
    sum(case when statusid = 4 then 1 else 0 end) over (partition by year(deadline) order by month(deadline) rows between 11 preceding and current row) as TasksCompletedYear
from 
    tasks
where 
    deadline <= getdate()	
order by 
    Year, Month;


-- Вычисление итогов выполненных поручений за определенный период:
-- •	количество выполненных поручений;
-- •	сравнение их с общим количеством выполненных поручений (в %);
-- •	сравнение с общим количеством не выполненных поручений (в %).
declare @StartDate date = '2024-01-23';
declare @EndDate date = '2024-02-24';
with TotalCompletedTasks as (
    select
        count(case when statusid = 4 then 1 end) over () as totalcompleted
    from
        tasks
),
CompletedTasks as (
    select
        count(case when statusid = 4 then 1 end) over () as completed
    from
        tasks
    where
        deadline between @StartDate and @EndDate
)
select
    completed,
    completed * 100.0 / totalcompleted as completedpercentage,
    (totalcompleted - completed) * 100.0 / totalcompleted as incompletepercentage
from
    CompletedTasks, TotalCompletedTasks;

-- 5.	Продемонстрируйте применение функции ранжирования ROW_NUMBER() 
-- для разбиения результатов запроса на страницы (по 20 строк на каждую страницу).
declare @page int = 1;
declare @pageSize int = 20;

with RankedTasks as (
    select
        taskid,
        taskname,
        description,
        row_number() over (order by taskid) as RowNum
    from
        tasks
)
select
    taskid,
    taskname,
    description
from
    RankedTasks
where
    RowNum > (@page - 1) * @pagesize
    and RowNum <= @page * @pagesize;

-- 6.	Продемонстрируйте применение функции ранжирования ROW_NUMBER() для удаления дубликатов.
with DeduplicatedTasks as (
    select
        taskid,
        taskname,
        description,
        row_number() over (partition by taskname order by taskid) as RowNum
    from
        tasks
)
select
    taskid,
    taskname,
    description
from
    DeduplicatedTasks
where
    RowNum = 1;

-- 7. Вернуть для каждого сотрудника количество выполненных и не выполненных заданий за последние 6 месяцев помесячно.
select 
     u.userid,
     u.username,
     year(t.deadline) as year,
     month(t.deadline) as month,
     sum(case when t.statusid = 4 then 1 else 0 end) over (partition by u.userid, year(t.deadline), month(t.deadline)) as completedtasks,
     sum(case when t.statusid <> 4 then 1 else 0 end) over (partition by u.userid, year(t.deadline), month(t.deadline)) as incompletetasks
from 
    users u
join 
    tasks t on u.userid = t.assignedtouserid
          and t.deadline >= dateadd(month, -6, getdate())
          and t.deadline <= getdate()


-- 8. Какой сотрудник выполнил наибольшее число поручений определенного вида? Вернуть для всех видов.
with TaskCounts as (
    select
        u.userid,
        u.username,
        tc.categoryid,
        tc.categoryname,
        count(case when t.statusid = 4 then 1 end) as completedtasks
    from
        users u
    join
        tasks t on u.userid = t.assignedtouserid
    join
        taskcategories tc on t.categoryid = tc.categoryid
    group by
        u.userid,
        u.username,
        tc.categoryid,
        tc.categoryname
),
RankedTaskCounts as (
    select
        userid,
        username,
        categoryid,
        categoryname,
        completedtasks,
        row_number() over (partition by categoryid order by completedtasks desc) as rank
    from
        TaskCounts
)
select
    userid,
    username,
    categoryid,
    categoryname,
    completedtasks
from
    RankedTaskCounts
where
    rank = 1;