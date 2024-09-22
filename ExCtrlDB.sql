CREATE DATABASE ExecutionControlDB;
GO

USE ExecutionControlDB;
GO

CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    Username VARCHAR(100),
    [Password] VARCHAR(100),
    Email VARCHAR(100),
    RoleID INT,
    ProjectID INT
);

CREATE TABLE Tasks (
    TaskID INT PRIMARY KEY,
    TaskName VARCHAR(100),
    Description VARCHAR(255),
    Deadline DATE,
    AssignedToUserID INT,
    StatusID INT,
    CategoryID INT,
    PriorityID INT,
    ProjectID INT,
    ParentTaskHierarchy HIERARCHYID
);

CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY,
    ProjectName VARCHAR(100),
    ProjectDescription VARCHAR(255),
    StartDate DATE,
    EndDate DATE,
    TotalTasks INT
);

CREATE TABLE TaskCategories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100)
);

CREATE TABLE TaskStatuses (
    StatusID INT PRIMARY KEY,
    StatusName VARCHAR(100)
);

CREATE TABLE TaskComments (
    CommentID INT PRIMARY KEY,
    TaskID INT,
    UserID INT,
    CommentText VARCHAR(255),
    [Timestamp] DATETIME
);

CREATE TABLE TaskPriorities (
    PriorityID INT PRIMARY KEY,
    PriorityName VARCHAR(100)
);

CREATE TABLE TaskFiles (
    FileID INT PRIMARY KEY,
    TaskID INT,
    FileName VARCHAR(100),
    FilePath VARCHAR(255)
);

CREATE TABLE ProjectParticipants (
    ParticipantID INT PRIMARY KEY,
    UserID INT,
    ProjectID INT
);

CREATE TABLE ProjectFiles (
    FileID INT PRIMARY KEY,
    ProjectID INT,
    FileName VARCHAR(100),
    FilePath VARCHAR(255)
);

CREATE TABLE Roles (
    RoleID INT PRIMARY KEY,
    RoleName VARCHAR(100)
);

CREATE TABLE AuditTrail (
    AuditTrailID INT PRIMARY KEY,
    TaskID INT,
    OldStatusID INT,
    NewStatusID INT,
    ChangedByUserID INT,
    ChangeTimestamp DATETIME
);

-- Добавление внешних ключей (FK)
ALTER TABLE Users ADD CONSTRAINT fk_role FOREIGN KEY (RoleID) REFERENCES Roles(RoleID);
ALTER TABLE Users ADD CONSTRAINT fk_project FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID);

ALTER TABLE Tasks ADD CONSTRAINT fk_assigned_user FOREIGN KEY (AssignedToUserID) REFERENCES Users(UserID);
ALTER TABLE Tasks ADD CONSTRAINT fk_task_status FOREIGN KEY (StatusID) REFERENCES TaskStatuses(StatusID);
ALTER TABLE Tasks ADD CONSTRAINT fk_task_category FOREIGN KEY (CategoryID) REFERENCES TaskCategories(CategoryID);
ALTER TABLE Tasks ADD CONSTRAINT fk_task_priority FOREIGN KEY (PriorityID) REFERENCES TaskPriorities(PriorityID);
ALTER TABLE Tasks ADD CONSTRAINT fk_task_project FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID);

ALTER TABLE TaskComments ADD CONSTRAINT fk_comment_task FOREIGN KEY (TaskID) REFERENCES Tasks(TaskID);
ALTER TABLE TaskComments ADD CONSTRAINT fk_comment_user FOREIGN KEY (UserID) REFERENCES Users(UserID);

ALTER TABLE TaskFiles ADD CONSTRAINT fk_file_task FOREIGN KEY (TaskID) REFERENCES Tasks(TaskID);

ALTER TABLE ProjectParticipants ADD CONSTRAINT fk_participant_user FOREIGN KEY (UserID) REFERENCES Users(UserID);
ALTER TABLE ProjectParticipants ADD CONSTRAINT fk_participant_project FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID);

ALTER TABLE ProjectFiles ADD CONSTRAINT fk_project_file FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID);

ALTER TABLE AuditTrail ADD CONSTRAINT fk_audit_task FOREIGN KEY (TaskID) REFERENCES Tasks(TaskID);
ALTER TABLE AuditTrail ADD CONSTRAINT fk_audit_old_status FOREIGN KEY (OldStatusID) REFERENCES TaskStatuses(StatusID);
ALTER TABLE AuditTrail ADD CONSTRAINT fk_audit_new_status FOREIGN KEY (NewStatusID) REFERENCES TaskStatuses(StatusID);
ALTER TABLE AuditTrail ADD CONSTRAINT fk_audit_changed_by_user FOREIGN KEY (ChangedByUserID) REFERENCES Users(UserID);

-----------------------------------------------------------------

CREATE PROCEDURE InsertTask(
    @TaskID INT,
    @TaskName VARCHAR(100),
    @Description VARCHAR(255),
    @Deadline DATE,
    @AssignedToUserID INT,
    @StatusID INT,
    @CategoryID INT,
    @PriorityID INT,
    @ProjectID INT
) AS
BEGIN
    DECLARE @UserID INT;
    DECLARE @StatusIDCheck INT;
    DECLARE @CategoryIDCheck INT;
    DECLARE @PriorityIDCheck INT;
    DECLARE @ProjectIDCheck INT;

    SELECT @UserID = COUNT(*) FROM Users WHERE UserID = @AssignedToUserID;
    SELECT @StatusIDCheck = COUNT(*) FROM TaskStatuses WHERE StatusID = @StatusID;
    SELECT @CategoryIDCheck = COUNT(*) FROM TaskCategories WHERE CategoryID = @CategoryID;
    SELECT @PriorityIDCheck = COUNT(*) FROM TaskPriorities WHERE PriorityID = @PriorityID;
    SELECT @ProjectIDCheck = COUNT(*) FROM Projects WHERE ProjectID = @ProjectID;

    IF (@UserID = 0) 
    BEGIN
        PRINT 'Error: AssignedToUserID does not exist';
    END
    ELSE IF (@StatusIDCheck = 0) 
    BEGIN
        PRINT 'Error: StatusID does not exist';
    END
    ELSE IF (@CategoryIDCheck = 0) 
    BEGIN
        PRINT 'Error: CategoryID does not exist';
    END
    ELSE IF (@PriorityIDCheck = 0) 
    BEGIN
        PRINT 'Error: PriorityID does not exist';
    END
    ELSE IF (@ProjectIDCheck = 0) 
    BEGIN
        PRINT 'Error: ProjectID does not exist';
    END
    ELSE 
    BEGIN
        BEGIN TRY
            INSERT INTO Tasks (TaskID, TaskName, Description, Deadline, AssignedToUserID, StatusID, CategoryID, PriorityID, ProjectID)
            VALUES (@TaskID, @TaskName, @Description, @Deadline, @AssignedToUserID, @StatusID, @CategoryID, @PriorityID, @ProjectID);
        END TRY
        BEGIN CATCH
            PRINT 'Error occurred: ' + ERROR_MESSAGE();
        END CATCH;
    END
END;

CREATE PROCEDURE GetAllTasks AS
BEGIN
    SELECT * FROM Tasks;
END;

CREATE PROCEDURE UpdateTask(
    @TaskID INT,
    @TaskName VARCHAR(100),
    @Description VARCHAR(255),
    @Deadline DATE,
    @AssignedToUserID INT,
    @StatusID INT,
    @CategoryID INT,
    @PriorityID INT,
    @ProjectID INT
) AS
BEGIN
    DECLARE @UserID INT;
    DECLARE @StatusIDCheck INT;
    DECLARE @CategoryIDCheck INT;
    DECLARE @PriorityIDCheck INT;
    DECLARE @ProjectIDCheck INT;

    SELECT @UserID = COUNT(*) FROM Users WHERE UserID = @AssignedToUserID;
    SELECT @StatusIDCheck = COUNT(*) FROM TaskStatuses WHERE StatusID = @StatusID;
    SELECT @CategoryIDCheck = COUNT(*) FROM TaskCategories WHERE CategoryID = @CategoryID;
    SELECT @PriorityIDCheck = COUNT(*) FROM TaskPriorities WHERE PriorityID = @PriorityID;
    SELECT @ProjectIDCheck = COUNT(*) FROM Projects WHERE ProjectID = @ProjectID;

    IF (@UserID = 0) 
    BEGIN
        PRINT 'Error: AssignedToUserID does not exist';
    END
    ELSE IF (@StatusIDCheck = 0) 
    BEGIN
        PRINT 'Error: StatusID does not exist';
    END
    ELSE IF (@CategoryIDCheck = 0) 
    BEGIN
        PRINT 'Error: CategoryID does not exist';
    END
    ELSE IF (@PriorityIDCheck = 0) 
    BEGIN
        PRINT 'Error: PriorityID does not exist';
    END
    ELSE IF (@ProjectIDCheck = 0) 
    BEGIN
        PRINT 'Error: ProjectID does not exist';
    END
    ELSE 
    BEGIN
        BEGIN TRY
            UPDATE Tasks
            SET TaskName = @TaskName, Description = @Description, Deadline = @Deadline, AssignedToUserID = @AssignedToUserID, 
                StatusID = @StatusID, CategoryID = @CategoryID, PriorityID = @PriorityID, ProjectID = @ProjectID
            WHERE TaskID = @TaskID;
        END TRY
        BEGIN CATCH
            PRINT 'Error occurred: ' + ERROR_MESSAGE();
        END CATCH;
    END
END;

CREATE PROCEDURE DeleteTask(
    @TaskID INT
) AS
BEGIN
    DELETE FROM Tasks WHERE TaskID = @TaskID;
END;

CREATE TRIGGER TaskStatusUpdateTrigger
ON Tasks
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(StatusID)
    BEGIN
        INSERT INTO AuditTrail (TaskID, OldStatusID, NewStatusID, ChangedByUserID, ChangeTimestamp)
        SELECT d.TaskID, d.StatusID, i.StatusID, SYSTEM_USER, GETDATE()
        FROM inserted i
        JOIN deleted d ON i.TaskID = d.TaskID
        WHERE i.StatusID <> d.StatusID;
    END
END;

CREATE VIEW TasksView AS
SELECT t.TaskID, t.TaskName, t.Description, t.Deadline, t.AssignedToUserID, t.StatusID, s.StatusName, 
    t.CategoryID, c.CategoryName, t.PriorityID, p.PriorityName, t.ProjectID
FROM Tasks t
JOIN TaskStatuses s ON t.StatusID = s.StatusID
JOIN TaskCategories c ON t.CategoryID = c.CategoryID
JOIN TaskPriorities p ON t.PriorityID = p.PriorityID;

CREATE INDEX idx_TaskName ON Tasks(TaskName);

CREATE SEQUENCE seq_TaskID START WITH 1 INCREMENT BY 1;

------
ALTER TABLE Tasks
ADD ParentTaskHierarchy HIERARCHYID;


-------------------------------
INSERT INTO Roles (RoleID, RoleName)
VALUES 
    (1, 'Admin'),
    (2, 'Manager'),
    (3, 'Team Leader'),
    (4, 'Developer'),
    (5, 'QA Engineer');

-------------------------------
INSERT INTO TaskStatuses (StatusID, StatusName)
VALUES 
    (1, 'Open'),
    (2, 'In Progress'),
    (3, 'Under Review'),
    (4, 'Completed'),
    (5, 'Cancelled');
	
-------------------------------
DECLARE @i INT = 1;
DECLARE @StartDate DATE = '2024-01-01';
DECLARE @EndDate DATE = '2024-12-31';

WHILE @i <= 100
BEGIN
    INSERT INTO Projects (ProjectID, ProjectName, ProjectDescription, StartDate, EndDate, TotalTasks)
    VALUES 
        (@i, 'Project ' + CAST(@i AS VARCHAR(10)), 'Description for Project ' + CAST(@i AS VARCHAR(10)), @StartDate, @EndDate, 0);

    SET @i = @i + 1;

    SET @StartDate = DATEADD(day, 1, @StartDate);
    SET @EndDate = DATEADD(day, 365, @EndDate);
END;

-------------------------------
DECLARE @i INT = 1;

WHILE @i <= 100
BEGIN
    INSERT INTO Users (UserID, Username, [Password], Email, RoleID, ProjectID)
    VALUES 
        (@i, 'User' + CAST(@i AS VARCHAR(10)), 'password' + CAST(@i AS VARCHAR(10)), 'user' + CAST(@i AS VARCHAR(10)) + '@example.com', 1, @i % 100 + 1);

    SET @i = @i + 1;
END;

------------------------------
INSERT INTO TaskCategories (CategoryID, CategoryName)
VALUES 
    (1, 'Development'),
    (2, 'Testing'),
    (3, 'Design'),
    (4, 'Maintenance'),
    (5, 'Sales'),
    (6, 'Marketing'),
    (7, 'Project Management'),
    (8, 'Accounting'),
    (9, 'Legal'),
    (10, 'Training and Development');

---------------------------------
INSERT INTO TaskPriorities (PriorityID, PriorityName)
VALUES 
    (1, 'Low'),
    (2, 'Low-Medium'),
    (3, 'Medium'),
    (4, 'Medium-High'),
    (5, 'High'),
    (6, 'Critical');

--------------------------------------------
DECLARE @root hierarchyid;
DECLARE @level1 hierarchyid;
DECLARE @level2 hierarchyid;
DECLARE @level3 hierarchyid;
DECLARE @level hierarchyid;
SET @root = hierarchyid::GetRoot();

SET @level1 = @root.GetDescendant(NULL, NULL);
INSERT INTO Tasks (TaskID, TaskName, Description, Deadline, AssignedToUserID, StatusID, CategoryID, PriorityID, ProjectID, ParentTaskHierarchy) 
VALUES (1, 'Task 1', 'Description of Task 1', '2024-02-20', 1, 1, 1, 1, 1, @level1);

SET @level2 = @level1.GetDescendant(NULL, NULL);
INSERT INTO Tasks (TaskID, TaskName, Description, Deadline, AssignedToUserID, StatusID, CategoryID, PriorityID, ProjectID, ParentTaskHierarchy) 
VALUES (2, 'Task 2', 'Description of Task 2', '2024-02-21', 2, 2, 2, 2, 1, @level2);
select @level=ParentTaskHierarchy from Tasks where TaskID = 2;
SET @level2 = @level1.GetDescendant(@level, NULL);
INSERT INTO Tasks (TaskID, TaskName, Description, Deadline, AssignedToUserID, StatusID, CategoryID, PriorityID, ProjectID, ParentTaskHierarchy) 
VALUES (3, 'Task 3', 'Description of Task 3', '2024-02-22', 3, 3, 3, 3, 1, @level2);

SET @level3 = @level2.GetDescendant(NULL, NULL);
INSERT INTO Tasks (TaskID, TaskName, Description, Deadline, AssignedToUserID, StatusID, CategoryID, PriorityID, ProjectID, ParentTaskHierarchy) 
VALUES (4, 'Task 4', 'Description of Task 4', '2024-02-23', 4, 4, 4, 4, 1, @level3);
select @level=ParentTaskHierarchy from Tasks where TaskID = 4;
SET @level3 = @level2.GetDescendant(@level, NULL);
INSERT INTO Tasks (TaskID, TaskName, Description, Deadline, AssignedToUserID, StatusID, CategoryID, PriorityID, ProjectID, ParentTaskHierarchy) 
VALUES (5, 'Task 5', 'Description of Task 5', '2024-02-24', 5, 5, 5, 5, 1, @level3);


EXEC AddChildTask 
    @ParentTaskID = 2,
	@TaskID = 6,
    @TaskName = 'Task 6',
    @Description = 'Description for Task 6',
    @Deadline = '2023-11-22',
    @AssignedToUserID = 4,
    @StatusID = 4,
    @CategoryID = 4,
    @PriorityID = 4,
    @ProjectID = 1;


EXEC AddChildTask 
    @ParentTaskID = 2,
	@TaskID = 7,
    @TaskName = 'Task 7',
    @Description = 'Description for Task 7',
    @Deadline = '2023-11-22',
    @AssignedToUserID = 4,
    @StatusID = 4,
    @CategoryID = 4,
    @PriorityID = 4,
    @ProjectID = 1;


EXEC AddChildTask 
    @ParentTaskID = 4,
	@TaskID = 8,
    @TaskName = 'Task 8',
    @Description = 'Description for Task 8',
    @Deadline = '2023-11-22',
    @AssignedToUserID = 4,
    @StatusID = 4,
    @CategoryID = 4,
    @PriorityID = 4,
    @ProjectID = 1;

delete from tasks;
-------------------

	SELECT MAX(ParentTaskHierarchy) FROM Tasks 
	WHERE ParentTaskHierarchy.GetAncestor(1) = 
	(select ParentTaskHierarchy from tasks where TaskID = 3)

	
	SELECT ParentTaskHierarchy.ToString() FROM Tasks 
	WHERE ParentTaskHierarchy.GetAncestor(0) = 
	(select ParentTaskHierarchy from tasks where TaskID = 3)

	select ParentTaskHierarchy.ToString() from tasks where TaskID = 3




CREATE PROCEDURE ShowSubTasksWithLevel
    @ParentTaskID INT
AS
BEGIN
    DECLARE @ParentHierarchy hierarchyid;
    SELECT @ParentHierarchy = ParentTaskHierarchy
    FROM Tasks
    WHERE TaskID = @ParentTaskID;

    WITH RecursiveCTE AS (
        SELECT 
            ParentTaskHierarchy.ToString() AS NodeAsString,
            ParentTaskHierarchy AS NodeAsBinary,
            ParentTaskHierarchy.GetLevel() AS Level,
            TaskID,
            TaskName
        FROM 
            Tasks
        WHERE 
            ParentTaskHierarchy = @ParentHierarchy

        UNION ALL

        SELECT 
            t.ParentTaskHierarchy.ToString() AS NodeAsString,
            t.ParentTaskHierarchy AS NodeAsBinary,
            t.ParentTaskHierarchy.GetLevel() AS Level,
            t.TaskID,
            t.TaskName
        FROM 
            Tasks t
        JOIN 
            RecursiveCTE r ON t.ParentTaskHierarchy.GetAncestor(r.Level) = r.NodeAsBinary
    )
    SELECT 
        NodeAsString,
        NodeAsBinary,
        Level,
        TaskID,
        TaskName
    FROM 
        RecursiveCTE;
END;

EXEC ShowSubTasksWithLevel @ParentTaskID = 3;



----------------------------
DROP PROCEDURE IF EXISTS AddChildTask;

CREATE PROCEDURE AddChildTask
    @ParentTaskID INT,
    @TaskID INT,
    @TaskName NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @Deadline DATE,
    @AssignedToUserID INT,
    @StatusID INT,
    @CategoryID INT,
    @PriorityID INT,
    @ProjectID INT
AS
BEGIN
    DECLARE @ParentHierarchyID hierarchyid;
	DECLARE @level hierarchyid;

    SELECT @ParentHierarchyID = ParentTaskHierarchy 
    FROM Tasks 
    WHERE TaskID = @ParentTaskID;
	
	SELECT @level=MAX(ParentTaskHierarchy) FROM Tasks WHERE ParentTaskHierarchy.GetAncestor(1) = @ParentHierarchyID
	
    DECLARE @NewTaskHierarchy hierarchyid;
    SET @NewTaskHierarchy = @ParentHierarchyID.GetDescendant(@level, NULL);

    INSERT INTO Tasks (TaskID, TaskName, Description, Deadline, AssignedToUserID, StatusID, CategoryID, PriorityID, ProjectID, ParentTaskHierarchy)
    VALUES (@TaskID, @TaskName, @Description, @Deadline, @AssignedToUserID, @StatusID, @CategoryID, @PriorityID, @ProjectID, @NewTaskHierarchy);
END;


EXEC AddChildTask 
    @ParentTaskID = 9,
	@TaskID = 12,
    @TaskName = 'Child Task 7',
    @Description = 'Description. Parent Task 9',
    @Deadline = '2024-02-25',
    @AssignedToUserID = 2,
    @StatusID = 1,
    @CategoryID = 1,
    @PriorityID = 1,
    @ProjectID = 1;
----------------

EXEC AddChildTask
    @ParentTaskID = 1,
	@TaskID = 101,
    @TaskName = 'Task 101',
    @Description = 'Description for Task 101',
    @Deadline = '2024-02-20',
    @AssignedToUserID = 1,
    @StatusID = 1,
    @CategoryID = 1,
    @PriorityID = 1,
    @ProjectID = 1;

EXEC AddChildTask 
    @ParentTaskID = 1,
	@TaskID = 102,
    @TaskName = 'Task 102',
    @Description = 'Description for Task 102',
    @Deadline = '2024-02-21',
    @AssignedToUserID = 2,
    @StatusID = 2,
    @CategoryID = 2,
    @PriorityID = 2,
    @ProjectID = 1;

EXEC AddChildTask 
    @ParentTaskID = 1,
	@TaskID = 2320,
    @TaskName = 'Task 2320',
    @Description = 'Description for Task 2330',
    @Deadline = '2023-11-22',
    @AssignedToUserID = 4,
    @StatusID = 3,
    @CategoryID = 3,
    @PriorityID = 3,
    @ProjectID = 1;

EXEC AddChildTask 
    @ParentTaskID = 5,
	@TaskID = 6,
    @TaskName = 'Task 6',
    @Description = 'Description for Task 6',
    @Deadline = '2023-11-22',
    @AssignedToUserID = 4,
    @StatusID = 4,
    @CategoryID = 4,
    @PriorityID = 4,
    @ProjectID = 1;

EXEC AddChildTask 
    @ParentTaskID = 1,
	@TaskID = 105,
    @TaskName = 'Task 105',
    @Description = 'Description for Task 105',
    @Deadline = '2024-02-24',
    @AssignedToUserID = 5,
    @StatusID = 5, 
    @CategoryID = 5,
    @PriorityID = 5,
    @ProjectID = 1;

delete from tasks

SELECT ParentTaskHierarchy.ToString() AS NodeAsString,
	ParentTaskHierarchy AS NodeAsBinary,
	ParentTaskHierarchy.GetLevel() AS Level, 
	TaskID,
	TaskName,
	Description
	FROM Tasks;

EXEC sp_columns 'Tasks';

DROP PROCEDURE IF EXISTS ChangeRoot;


EXEC ChangeRoot @oldRootId = 3, @newRootId = 105;

CREATE OR PROCEDURE ChangeRoot
    @oldRootId int, 
    @newRootId int
AS
BEGIN
    DECLARE @oldRoot hierarchyid;
    DECLARE @newRoot hierarchyid;

    SELECT @oldRoot = ParentTaskHierarchy 
    FROM Tasks 
    WHERE TaskID = @oldRootId;

    SELECT @newRoot = ParentTaskHierarchy 
    FROM Tasks 
    WHERE TaskID = @newRootId;

    DECLARE @newMaxRoot hierarchyid;

    SELECT @newMaxRoot = @newRoot.GetDescendant(MAX(ParentTaskHierarchy), NULL)
    FROM Tasks 
    WHERE ParentTaskHierarchy.GetAncestor(1) = @newRoot;

    UPDATE Tasks
    SET ParentTaskHierarchy = ParentTaskHierarchy.GetReparentedValue(@oldRoot, @newMaxRoot)
    WHERE ParentTaskHierarchy.IsDescendantOf(@oldRoot) = 1;

    UPDATE Tasks
    SET ParentTaskHierarchy = @newMaxRoot
    WHERE ParentTaskHierarchy = @oldRoot;
END;
