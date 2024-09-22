CREATE OR REPLACE TYPE task_objectt AS OBJECT (
    taskId NUMBER,
    taskName VARCHAR2(100),
    description VARCHAR2(1000),
    deadline DATE,
    assignedToUserId NUMBER,

    CONSTRUCTOR FUNCTION task_objectt(
        taskId NUMBER, 
        taskName VARCHAR2, 
        description VARCHAR2, 
        deadline DATE, 
        assignedToUserId NUMBER
    ) RETURN SELF AS RESULT,

    ORDER MEMBER FUNCTION compareTask(other IN task_objectt) RETURN NUMBER,

    MEMBER FUNCTION displayTaskInfo RETURN VARCHAR2,

    MEMBER PROCEDURE updateDescription(newDescription VARCHAR2),
    
    MEMBER FUNCTION years_at_task RETURN NUMBER DETERMINISTIC
);



CREATE OR REPLACE TYPE task_object AS OBJECT (
    taskId NUMBER,
    taskName VARCHAR2(100),
    description VARCHAR2(1000),
    deadline DATE,
    assignedToUserId NUMBER,

    CONSTRUCTOR FUNCTION task_object(
        taskId NUMBER, 
        taskName VARCHAR2, 
        description VARCHAR2, 
        deadline DATE, 
        assignedToUserId NUMBER
    ) RETURN SELF AS RESULT,

    ORDER MEMBER FUNCTION compareTask(other IN task_object) RETURN NUMBER,

    MEMBER FUNCTION displayTaskInfo RETURN VARCHAR2,

    MEMBER PROCEDURE updateDescription(newDescription VARCHAR2)
    
);

CREATE OR REPLACE TYPE executor_object AS OBJECT (
    userId NUMBER,
    userName VARCHAR2(100),

    CONSTRUCTOR FUNCTION executor_object(userId NUMBER, userName VARCHAR2) RETURN SELF AS RESULT,

    ORDER MEMBER FUNCTION compareExecutor(other IN executor_object) RETURN NUMBER,

    MEMBER FUNCTION displayExecutorInfo RETURN VARCHAR2,

    MEMBER PROCEDURE updateUserName(newName VARCHAR2)
);

CREATE OR REPLACE TYPE BODY task_objectt AS 
    CONSTRUCTOR FUNCTION task_objectt(
        taskId NUMBER, 
        taskName VARCHAR2, 
        description VARCHAR2, 
        deadline DATE, 
        assignedToUserId NUMBER
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.taskId := taskId;
        SELF.taskName := taskName;
        SELF.description := description;
        SELF.deadline := deadline;
        SELF.assignedToUserId := assignedToUserId;
        RETURN;
    END;

    ORDER MEMBER FUNCTION compareTask(other IN task_objectt) RETURN NUMBER IS
    BEGIN
        IF SELF.taskId = other.taskId THEN
            RETURN 0; 
        ELSIF SELF.taskId > other.taskId THEN
            RETURN 1; 
        ELSE
            RETURN -1; 
        END IF;
    END compareTask;

    MEMBER FUNCTION displayTaskInfo RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Task ID: ' || TO_CHAR(SELF.taskId) || ', Task Name: ' || SELF.taskName || ', Description: ' || SELF.description || ', Deadline: ' || TO_CHAR(SELF.deadline, 'DD-MON-YYYY') || ', Assigned To User ID: ' || TO_CHAR(SELF.assignedToUserId);
    END;

    MEMBER PROCEDURE updateDescription(newDescription VARCHAR2) IS
    BEGIN
        SELF.description := newDescription;
    END;
    
    MEMBER FUNCTION years_at_task RETURN NUMBER DETERMINISTIC
    IS
         rc NUMBER := 0;
         BEGIN
            rc := months_between(sysdate, deadline)/12;
            return rc;
        end;
END;

CREATE OR REPLACE TYPE BODY executor_object AS 
    CONSTRUCTOR FUNCTION executor_object(userId NUMBER, userName VARCHAR2) RETURN SELF AS RESULT IS
    BEGIN
        SELF.userId := userId;
        SELF.userName := userName;
        RETURN;
    END;

    ORDER MEMBER FUNCTION compareExecutor(other IN executor_object) RETURN NUMBER IS
    BEGIN
        IF SELF.userId = other.userId THEN
            RETURN 0; 
        ELSIF SELF.userId > other.userId THEN
            RETURN 1; 
        ELSE
            RETURN -1;
        END IF;
    END compareExecutor;

    MEMBER FUNCTION displayExecutorInfo RETURN VARCHAR2 IS
    BEGIN
        RETURN 'User ID: ' || TO_CHAR(SELF.userId) || ', User Name: ' || SELF.userName;
    END;

    MEMBER PROCEDURE updateUserName(newName VARCHAR2) IS
    BEGIN
        SELF.userName := newName;
    END;
END;

SELECT task_object(
           taskId,
           taskName,
           description,
           deadline,
           assignedToUserId
       ) AS taskobject
FROM Tasks;

SELECT executor_object(
           userId,
           userName
       ) AS executorobject
FROM Users;

CREATE TABLE task_objectt_table OF task_objectt;

CREATE TABLE executor_object_table OF executor_object;

INSERT INTO task_objectt_table (
    SELECT task_objectt(1, 'Task 1', 'Description of Task 1', TO_DATE('2024-04-15', 'YYYY-MM-DD'), 101) FROM DUAL UNION ALL
    SELECT task_objectt(2, 'Task 2', 'Description of Task 2', TO_DATE('2024-04-16', 'YYYY-MM-DD'), 102) FROM DUAL UNION ALL
    SELECT task_objectt(3, 'Task 3', 'Description of Task 3', TO_DATE('2024-04-17', 'YYYY-MM-DD'), 103) FROM DUAL
);

INSERT INTO executor_object_table (
    SELECT executor_object(101, 'User 1') FROM DUAL UNION ALL
    SELECT executor_object(102, 'User 2') FROM DUAL UNION ALL
    SELECT executor_object(103, 'User 3') FROM DUAL
);

select * from task_object_table;
select * from executor_object_table;

DECLARE
    t1 task_object;
    t2 task_object;
    e1 executor_object;
    e2 executor_object;
    comparison_result NUMBER;
BEGIN
    t1 := task_object(1, 'Task 1', 'Description of Task 1', TO_DATE('2024-04-15', 'YYYY-MM-DD'), 100);
    t2 := task_object(2, 'Task 2', 'Description of Task 2', TO_DATE('2024-04-16', 'YYYY-MM-DD'), 101);

    e1 := executor_object(100, 'John');
    e2 := executor_object(101, 'Alice');

    comparison_result := t1.compareTask(t2);
    IF comparison_result = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Task t1 is equal to Task t2');
    ELSIF comparison_result = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Task t1 is greater than Task t2');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Task t1 is less than Task t2');
    END IF;

    comparison_result := e1.compareExecutor(e2);
    IF comparison_result = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Executor e1 is equal to Executor e2');
    ELSIF comparison_result = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Executor e1 is greater than Executor e2');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Executor e1 is less than Executor e2');
    END IF;
END;

DECLARE
    task_obj task_object;
BEGIN
    task_obj := task_object(1, 'Task 1', 'Description of Task 1', TO_DATE('2024-04-15', 'YYYY-MM-DD'), 101);
    
    DBMS_OUTPUT.PUT_LINE(task_obj.displayTaskInfo);
    
    task_obj.updateDescription('New description for Task 1');
    DBMS_OUTPUT.PUT_LINE('Updated description: ' || task_obj.description);
END;


DECLARE
    executor_obj executor_object;
BEGIN
    executor_obj := executor_object(101, 'User 1');
    
    DBMS_OUTPUT.PUT_LINE(executor_obj.displayExecutorInfo);
    
    executor_obj.updateUserName('New User 1');
    DBMS_OUTPUT.PUT_LINE('Updated user name: ' || executor_obj.userName);
END;

drop index task_id_index;
CREATE INDEX task_id_index ON task_object_table (taskId);

SELECT * FROM task_object_table t WHERE t.taskId = 2;


-----


drop index task_id_index_method;
CREATE BITMAP INDEX task_id_index_method ON task_objectt_table t (t.years_at_task());

SELECT * FROM task_objectt_table t WHERE t.years_at_task() = 1;


create view task_ov of task_object
with object identifier (taskId) as
select  t.taskId, t.taskName, 
        t.description, t.deadline, 
        t.assignedToUserId
from tasks t;

select t.taskName, t.displayTaskInfo()
from task_ov t;

describe task_object_table;
select value(e) from task_object_table e;
select ref(e) from task_object_table e;

