CREATE FUNCTION dbo.GetSelectedData
(
    @StartDate DATE,
    @EndDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT u.UserID, u.UserName, t.TaskID, t.TaskName, t.Description, t.Deadline, t.AssignedToUserID, t.StatusID, t.CategoryID, t.PriorityID, t.ProjectID
    FROM Users u
    INNER JOIN Tasks t ON u.UserID = t.AssignedToUserID
    WHERE t.Deadline BETWEEN @StartDate AND @EndDate
);

SELECT * FROM dbo.GetSelectedData('2024-01-01', '2024-12-31');

select * from tasks;

select * from [dbo].[data];
