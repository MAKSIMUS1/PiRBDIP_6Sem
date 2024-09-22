create role C##ROLE_LABFOUR;
grant create session,
      create table, 
      create view, 
      create procedure,
      create trigger,
      create SEQUENCE,
      drop any SEQUENCE,
      drop any trigger,
      drop any table,
      drop any view,
      drop any procedure to C##ROLE_LABFOUR;    
grant create session to C##ROLE_LABFOUR;
commit;

create profile C##PROFILE_LABFOUR limit
    password_life_time 180     
    sessions_per_user 3         
    failed_login_attempts 7     
    password_lock_time 1        
    password_reuse_time 10      
    password_grace_time default 
    connect_time 180            
    idle_time 30 ;  
    
create user C##USER_LABFOUR identified by 1234
default tablespace KMO_QDATA quota unlimited on KMO_QDATA
profile C##PROFILE_LABFOUR
account unlock;

CREATE TABLE Users (
    UserID NUMBER PRIMARY KEY,
    Username VARCHAR2(100),
    Password VARCHAR2(100),
    Email VARCHAR2(100),
    RoleID NUMBER,
    ProjectID NUMBER
);

CREATE TABLE Tasks (
    TaskID NUMBER PRIMARY KEY,
    TaskName VARCHAR2(100),
    Description VARCHAR2(255),
    Deadline DATE,
    AssignedToUserID NUMBER,
    StatusID NUMBER,
    CategoryID NUMBER,
    PriorityID NUMBER,
    ProjectID NUMBER
);

CREATE TABLE Projects (
    ProjectID NUMBER PRIMARY KEY,
    ProjectName VARCHAR2(100),
    ProjectDescription VARCHAR2(255),
    StartDate DATE,
    EndDate DATE,
    TotalTasks NUMBER
);

CREATE TABLE TaskCategories (
    CategoryID NUMBER PRIMARY KEY,
    CategoryName VARCHAR2(100)
);

CREATE TABLE TaskStatuses (
    StatusID NUMBER PRIMARY KEY,
    StatusName VARCHAR2(100)
);

CREATE TABLE TaskComments (
    CommentID NUMBER PRIMARY KEY,
    TaskID NUMBER,
    UserID NUMBER,
    CommentText VARCHAR2(255),
    Timestamp TIMESTAMP
);

CREATE TABLE TaskPriorities (
    PriorityID NUMBER PRIMARY KEY,
    PriorityName VARCHAR2(100)
);

CREATE TABLE TaskFiles (
    FileID NUMBER PRIMARY KEY,
    TaskID NUMBER,
    FileName VARCHAR2(100),
    FilePath VARCHAR2(255)
);

CREATE TABLE ProjectParticipants (
    ParticipantID NUMBER PRIMARY KEY,
    UserID NUMBER,
    ProjectID NUMBER
);

CREATE TABLE ProjectFiles (
    FileID NUMBER PRIMARY KEY,
    ProjectID NUMBER,
    FileName VARCHAR2(100),
    FilePath VARCHAR2(255)
);

CREATE TABLE Roles (
    RoleID NUMBER PRIMARY KEY,
    RoleName VARCHAR2(100)
);

CREATE TABLE AuditTrail (
    AuditTrailID NUMBER PRIMARY KEY,
    TaskID NUMBER,
    OldStatusID NUMBER,
    NewStatusID NUMBER,
    ChangedByUserID NUMBER,
    ChangeTimestamp TIMESTAMP
);

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

CREATE OR REPLACE PROCEDURE InsertTask(
    p_TaskID IN NUMBER,
    p_TaskName IN VARCHAR2,
    p_Description IN VARCHAR2,
    p_Deadline IN DATE,
    p_AssignedToUserID IN NUMBER,
    p_StatusID IN NUMBER,
    p_CategoryID IN NUMBER,
    p_PriorityID IN NUMBER,
    p_ProjectID IN NUMBER
) AS
    v_UserID INT;
    v_StatusID INT;
    v_CategoryID INT;
    v_PriorityID INT;
    v_ProjectID INT;
BEGIN
    SELECT COUNT(*) INTO v_UserID FROM Users WHERE UserID = p_AssignedToUserID;
    SELECT COUNT(*) INTO v_StatusID FROM TaskStatuses WHERE StatusID = p_StatusID;
    SELECT COUNT(*) INTO v_CategoryID FROM TaskCategories WHERE CategoryID = p_CategoryID;
    SELECT COUNT(*) INTO v_PriorityID FROM TaskPriorities WHERE PriorityID = p_PriorityID;
    SELECT COUNT(*) INTO v_ProjectID FROM Projects WHERE ProjectID = p_ProjectID;
    
    IF (v_UserID = 0) THEN
        DBMS_OUTPUT.PUT_LINE('Error: AssignedToUserID does not exist');
    ELSIF (v_StatusID = 0) THEN
        DBMS_OUTPUT.PUT_LINE('Error: StatusID does not exist');
    ELSIF (v_CategoryID = 0) THEN
        DBMS_OUTPUT.PUT_LINE('Error: CategoryID does not exist');
    ELSIF (v_PriorityID = 0) THEN
        DBMS_OUTPUT.PUT_LINE('Error: PriorityID does not exist');
    ELSIF (v_ProjectID = 0) THEN
        DBMS_OUTPUT.PUT_LINE('Error: ProjectID does not exist');
    ELSE
        BEGIN
            INSERT INTO Tasks (TaskID, TaskName, Description, Deadline, AssignedToUserID, StatusID, CategoryID, PriorityID, ProjectID)
            VALUES (p_TaskID, p_TaskName, p_Description, p_Deadline, p_AssignedToUserID, p_StatusID, p_CategoryID, p_PriorityID, p_ProjectID);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
        END;
    END IF;
END InsertTask;

CREATE OR REPLACE PROCEDURE GetAllTasks AS
    CURSOR task_cursor IS
        SELECT * FROM Tasks;
    task_rec Tasks%ROWTYPE;
BEGIN
    OPEN task_cursor;
    LOOP
        FETCH task_cursor INTO task_rec;
        EXIT WHEN task_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('TaskID: ' || task_rec.TaskID || ', TaskName: ' || task_rec.TaskName || ', Description: ' || task_rec.Description);

    END LOOP;
    CLOSE task_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END GetAllTasks;


CREATE OR REPLACE PROCEDURE UpdateTask(
    p_TaskID IN NUMBER,
    p_TaskName IN VARCHAR2,
    p_Description IN VARCHAR2,
    p_Deadline IN DATE,
    p_AssignedToUserID IN NUMBER,
    p_StatusID IN NUMBER,
    p_CategoryID IN NUMBER,
    p_PriorityID IN NUMBER,
    p_ProjectID IN NUMBER
) AS
    v_UserID INT;
    v_StatusID INT;
    v_CategoryID INT;
    v_PriorityID INT;
    v_ProjectID INT;
BEGIN
    SELECT COUNT(*) INTO v_UserID FROM Users WHERE UserID = p_AssignedToUserID;
    SELECT COUNT(*) INTO v_StatusID FROM TaskStatuses WHERE StatusID = p_StatusID;
    SELECT COUNT(*) INTO v_CategoryID FROM TaskCategories WHERE CategoryID = p_CategoryID;
    SELECT COUNT(*) INTO v_PriorityID FROM TaskPriorities WHERE PriorityID = p_PriorityID;
    SELECT COUNT(*) INTO v_ProjectID FROM Projects WHERE ProjectID = p_ProjectID;
    
    IF (v_UserID = 0) THEN
        DBMS_OUTPUT.PUT_LINE('Error: AssignedToUserID does not exist');
    ELSIF (v_StatusID = 0) THEN
        DBMS_OUTPUT.PUT_LINE('Error: StatusID does not exist');
    ELSIF (v_CategoryID = 0) THEN
        DBMS_OUTPUT.PUT_LINE('Error: CategoryID does not exist');
    ELSIF (v_PriorityID = 0) THEN
        DBMS_OUTPUT.PUT_LINE('Error: PriorityID does not exist');
    ELSIF (v_ProjectID = 0) THEN
        DBMS_OUTPUT.PUT_LINE('Error: ProjectID does not exist');
    ELSE
        BEGIN
            UPDATE Tasks
            SET TaskName = p_TaskName, Description = p_Description, Deadline = p_Deadline, AssignedToUserID = p_AssignedToUserID, StatusID = p_StatusID, CategoryID = p_CategoryID, PriorityID = p_PriorityID, ProjectID = p_ProjectID
            WHERE TaskID = p_TaskID;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
        END;
    END IF;
END UpdateTask;

CREATE OR REPLACE PROCEDURE DeleteTask(
    p_TaskID IN NUMBER
) AS
BEGIN
    DELETE FROM Tasks WHERE TaskID = p_TaskID;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END DeleteTask;

CREATE SEQUENCE audittrail_sequence START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER TaskStatusUpdateTrigger
AFTER UPDATE OF StatusID ON Tasks
FOR EACH ROW
BEGIN
    IF :OLD.StatusID != :NEW.StatusID THEN
        INSERT INTO AuditTrail (AuditTrailID, TaskID, OldStatusID, NewStatusID, ChangedByUserID, ChangeTimestamp)
        VALUES (audittrail_sequence.NEXTVAL, :OLD.TaskID, :OLD.StatusID, :NEW.StatusID, USER, SYSDATE);
    END IF;
END;

CREATE OR REPLACE VIEW TasksView AS
SELECT t.TaskID, t.TaskName, t.Description, t.Deadline, t.AssignedToUserID, t.StatusID, s.StatusName, t.CategoryID, c.CategoryName, t.PriorityID, p.PriorityName, t.ProjectID
FROM Tasks t
JOIN TaskStatuses s ON t.StatusID = s.StatusID
JOIN TaskCategories c ON t.CategoryID = c.CategoryID
JOIN TaskPriorities p ON t.PriorityID = p.PriorityID;

CREATE INDEX idx_TaskName ON Tasks(TaskName);

CREATE SEQUENCE seq_TaskID START WITH 1 INCREMENT BY 1;

-----------------------------
EXEC InsertTask(1, 'New Task', 'Description of the task', SYSDATE, 1, 1, 1, 1, 1);

EXEC GetAllTasks;

EXEC UpdateTask(1, 'Updated Task', 'Updated description', SYSDATE, 1, 2, 1, 1, 1);

EXEC DeleteTask(1);

--data--


delete from Tasks;
delete from TaskCategories;
delete from Users;
delete from Projects;
delete from Roles;
delete from TaskPriorities;
delete from TaskStatuses;
-- «аполнение таблицы Roles
INSERT ALL 
INTO Roles (RoleID, RoleName) VALUES (1, 'Admin')
INTO Roles (RoleID, RoleName) VALUES (2, 'Manager')
INTO Roles (RoleID, RoleName) VALUES (3, 'Team Leader')
INTO Roles (RoleID, RoleName) VALUES (4, 'Developer')
INTO Roles (RoleID, RoleName) VALUES (5, 'QA Engineer')
SELECT * FROM dual;

-- «аполнение таблицы TaskStatuses
INSERT ALL 
INTO TaskStatuses (StatusID, StatusName) VALUES (1, 'Open')
INTO TaskStatuses (StatusID, StatusName) VALUES (2, 'In Progress')
INTO TaskStatuses (StatusID, StatusName) VALUES (3, 'Under Review')
INTO TaskStatuses (StatusID, StatusName) VALUES (4, 'Completed')
INTO TaskStatuses (StatusID, StatusName) VALUES (5, 'Cancelled')
SELECT * FROM dual;

-- √енераци€ дат дл€ проектов и заполнение таблицы Projects
INSERT INTO Projects (ProjectID, ProjectName, ProjectDescription, StartDate, EndDate, TotalTasks)
SELECT 
    LEVEL AS ProjectID, 
    'Project ' || TO_CHAR(LEVEL) AS ProjectName, 
    'Description for Project ' || TO_CHAR(LEVEL) AS ProjectDescription, 
    TRUNC(DATE '2024-01-01') + LEVEL - 1 AS StartDate, 
    TRUNC(DATE '2024-01-01') + LEVEL + 364 AS EndDate, 
    0 AS TotalTasks
FROM 
    dual
CONNECT BY 
    LEVEL <= 100;


-- «аполнение таблицы Users
INSERT INTO Users (UserID, Username, Password, Email, RoleID, ProjectID)
SELECT 
    LEVEL AS UserID,
    'User' || TO_CHAR(LEVEL) AS Username,
    'password' || TO_CHAR(LEVEL) AS Password,
    'user' || TO_CHAR(LEVEL) || '@example.com' AS Email,
    1 AS RoleID,
    MOD(LEVEL, 100) + 1 AS ProjectID
FROM 
    dual
CONNECT BY 
    LEVEL <= 100;

-- «аполнение таблицы TaskCategories
INSERT ALL 
INTO TaskCategories (CategoryID, CategoryName) VALUES (1, 'Development')
INTO TaskCategories (CategoryID, CategoryName) VALUES (2, 'Testing')
INTO TaskCategories (CategoryID, CategoryName) VALUES (3, 'Design')
INTO TaskCategories (CategoryID, CategoryName) VALUES (4, 'Maintenance')
INTO TaskCategories (CategoryID, CategoryName) VALUES (5, 'Sales')
INTO TaskCategories (CategoryID, CategoryName) VALUES (6, 'Marketing')
INTO TaskCategories (CategoryID, CategoryName) VALUES (7, 'Project Management')
INTO TaskCategories (CategoryID, CategoryName) VALUES (8, 'Accounting')
INTO TaskCategories (CategoryID, CategoryName) VALUES (9, 'Legal')
INTO TaskCategories (CategoryID, CategoryName) VALUES (10, 'Training and Development')
SELECT * FROM dual;


-- «аполнение таблицы TaskPriorities
INSERT ALL 
INTO TaskPriorities (PriorityID, PriorityName) VALUES (1, 'Low')
INTO TaskPriorities (PriorityID, PriorityName) VALUES (2, 'Low-Medium')
INTO TaskPriorities (PriorityID, PriorityName) VALUES (3, 'Medium')
INTO TaskPriorities (PriorityID, PriorityName) VALUES (4, 'Medium-High')
INTO TaskPriorities (PriorityID, PriorityName) VALUES (5, 'High')
INTO TaskPriorities (PriorityID, PriorityName) VALUES (6, 'Critical')
SELECT * FROM dual;

commit;

DESC Tasks;

-- ¬ставл€ем корневую задачу (уровень 1)
INSERT INTO Tasks (TASKID, TASKNAME, DESCRIPTION, DEADLINE, ASSIGNEDTOUSERID, STATUSID, CATEGORYID, PRIORITYID, PROJECTID, PARENTTASKID)
VALUES (1, 'Task 1', 'Description of Task 1', TO_DATE('2024-02-20', 'YYYY-MM-DD'), 1, 1, 1, 1, 1, NULL);

-- ¬ставл€ем дочерние задачи дл€ корневой задачи (уровень 2)
INSERT INTO Tasks (TASKID, TASKNAME, DESCRIPTION, DEADLINE, ASSIGNEDTOUSERID, STATUSID, CATEGORYID, PRIORITYID, PROJECTID, PARENTTASKID)
VALUES (2, 'Task 2', 'Description of Task 2', TO_DATE('2024-02-21', 'YYYY-MM-DD'), 2, 2, 2, 2, 1, 1);

INSERT INTO Tasks (TASKID, TASKNAME, DESCRIPTION, DEADLINE, ASSIGNEDTOUSERID, STATUSID, CATEGORYID, PRIORITYID, PROJECTID, PARENTTASKID)
VALUES (3, 'Task 3', 'Description of Task 3', TO_DATE('2024-02-22', 'YYYY-MM-DD'), 3, 3, 3, 3, 1, 1);

-- ¬ставл€ем дочерние задачи дл€ второй задачи (уровень 3)
INSERT INTO Tasks (TASKID, TASKNAME, DESCRIPTION, DEADLINE, ASSIGNEDTOUSERID, STATUSID, CATEGORYID, PRIORITYID, PROJECTID, PARENTTASKID)
VALUES (4, 'Task 4', 'Description of Task 4', TO_DATE('2024-02-23', 'YYYY-MM-DD'), 4, 4, 4, 4, 1, 2);

INSERT INTO Tasks (TASKID, TASKNAME, DESCRIPTION, DEADLINE, ASSIGNEDTOUSERID, STATUSID, CATEGORYID, PRIORITYID, PROJECTID, PARENTTASKID)
VALUES (5, 'Task 5', 'Description of Task 5', TO_DATE('2024-02-24', 'YYYY-MM-DD'), 5, 5, 5, 5, 1, 2);

-- ¬ставл€ем дочерние задачи дл€ третьей задачи (уровень 3)
INSERT INTO Tasks (TASKID, TASKNAME, DESCRIPTION, DEADLINE, ASSIGNEDTOUSERID, STATUSID, CATEGORYID, PRIORITYID, PROJECTID, PARENTTASKID)
VALUES (6, 'Task 6', 'Description of Task 6', TO_DATE('2024-02-25', 'YYYY-MM-DD'), 6, 1, 1, 2, 1, 3);

INSERT INTO Tasks (TASKID, TASKNAME, DESCRIPTION, DEADLINE, ASSIGNEDTOUSERID, STATUSID, CATEGORYID, PRIORITYID, PROJECTID, PARENTTASKID)
VALUES (7, 'Task 7', 'Description of Task 7', TO_DATE('2024-02-26', 'YYYY-MM-DD'), 7, 2, 2, 3, 1, 3);

-- ¬ставл€ем дочерние задачи дл€ четвертой задачи (уровень 4)
INSERT INTO Tasks (TASKID, TASKNAME, DESCRIPTION, DEADLINE, ASSIGNEDTOUSERID, STATUSID, CATEGORYID, PRIORITYID, PROJECTID, PARENTTASKID)
VALUES (8, 'Task 8', 'Description of Task 8', TO_DATE('2024-02-27', 'YYYY-MM-DD'), 8, 3, 3, 4, 1, 4);

INSERT INTO Tasks (TASKID, TASKNAME, DESCRIPTION, DEADLINE, ASSIGNEDTOUSERID, STATUSID, CATEGORYID, PRIORITYID, PROJECTID, PARENTTASKID)
VALUES (9, 'Task 9', 'Description of Task 9', TO_DATE('2024-02-28', 'YYYY-MM-DD'), 9, 4, 4, 5, 1, 4);

-- ¬ставл€ем дочерние задачи дл€ п€той задачи (уровень 4)
INSERT INTO Tasks (TASKID, TASKNAME, DESCRIPTION, DEADLINE, ASSIGNEDTOUSERID, STATUSID, CATEGORYID, PRIORITYID, PROJECTID, PARENTTASKID)
VALUES (10, 'Task 10', 'Description of Task 10', TO_DATE('2024-02-29', 'YYYY-MM-DD'), 10, 5, 5, 6, 1, 5);


------- lab 3 hierarhy 
ALTER TABLE Tasks ADD ParentTaskID NUMBER;

drop procedure ShowSubTasksWithLevel;

-- ex 2
CREATE OR REPLACE PROCEDURE ShowSubTasksWithLevel
(
    p_ParentTaskID IN NUMBER
)
IS
BEGIN
    FOR task IN (
        SELECT TaskID, ParentTaskID
        FROM Tasks
        START WITH TaskID = p_ParentTaskID
        CONNECT BY PRIOR TaskID = ParentTaskID
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('TaskID: ' || task.TaskID || '   ParentTaskID: ' || task.ParentTaskID);
    END LOOP;
END;


exec ShowSubTasksWithLevel(5);

-- add proc 
CREATE OR REPLACE PROCEDURE AddChildTask (
    p_ParentTaskID IN NUMBER,
    p_TaskName IN VARCHAR2,
    p_Description IN VARCHAR2,
    p_Deadline IN DATE,
    p_AssignedToUserID IN NUMBER,
    p_StatusID IN NUMBER,
    p_CategoryID IN NUMBER,
    p_PriorityID IN NUMBER,
    p_ProjectID IN NUMBER
)
IS
BEGIN
    INSERT INTO Tasks (TaskID, TaskName, Description, Deadline, AssignedToUserID, StatusID, CategoryID, PriorityID, ProjectID, ParentTaskID)
    VALUES (
        (SELECT COALESCE(MAX(TaskID), 0) + 1 FROM Tasks),
        p_TaskName,
        p_Description,
        p_Deadline,
        p_AssignedToUserID,
        p_StatusID,
        p_CategoryID,
        p_PriorityID,
        p_ProjectID,
        p_ParentTaskID
    );
END;

BEGIN
    AddChildTask(
        p_ParentTaskID => 5,
        p_TaskName => 'Subtask 23',
        p_Description => 'Description of Subtask 23',
        p_Deadline => TO_DATE('2024-02-28', 'YYYY-MM-DD'),
        p_AssignedToUserID => 2,
        p_StatusID => 1,
        p_CategoryID => 1,
        p_PriorityID => 2,
        p_ProjectID => 1
    );
END;


CREATE OR REPLACE PROCEDURE MoveSubtasks (
    p_OldParentTaskID IN NUMBER,
    p_NewParentTaskID IN NUMBER
)
IS
BEGIN
    UPDATE Tasks
    SET ParentTaskID = p_NewParentTaskID
    WHERE ParentTaskID = p_OldParentTaskID;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Subtasks moved successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;

BEGIN
    MoveSubtasks(4, 5);
END;

-- out
SELECT 
    LPAD(' ', 2*(LEVEL-1)) || TaskID AS Node,
    LEVEL AS HierarchyLevel,
    TaskName,
    ParentTaskID
FROM 
    Tasks
START WITH 
    ParentTaskID IS NULL
CONNECT BY 
    PRIOR TaskID = ParentTaskID;
    






