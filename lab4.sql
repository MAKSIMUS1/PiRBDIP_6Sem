ALTER DATABASE OPEN;

-- 1
select tablespace_name, contents from DBA_TABLESPACES;
-- 2
create tablespace KMO_QDATA
  datafile 'C:\Tablespaces\KMO_QDATA.dbf'
  size 10 M
  offline;
  
alter tablespace KMO_QDATA online;

DROP TABLESPACE KMO_QDATA INCLUDING CONTENTS AND DATAFILES; 

create role C##ROLE_LABFOUR;
grant create session,
      create table, 
      create view, 
      create procedure,
      create trigger,
      drop any trigger,
      drop any table,
      drop any view,
      drop any procedure to C##ROLE_LABFOUR;    
grant create session to C##ROLE_LABFOUR;
commit;

create profile C##PROFILE_LABFOUR limit
    password_life_time 180      --кол-во дней жизни пароля
    sessions_per_user 3         --кол-во сессий для юзера
    failed_login_attempts 7     --кол-во попыток ввода
    password_lock_time 1        --кол-во дней блока после ошибок
    password_reuse_time 10      --через скок дней можно повторить пароль
    password_grace_time default --кол-во дней предупрежд.о смене пароля
    connect_time 180            --время соед (мин)
    idle_time 30 ;  
    
create user C##USER_LABFOUR identified by 1234
default tablespace KMO_QDATA quota unlimited on KMO_QDATA
profile C##PROFILE_LABFOUR
account unlock;

alter user C##USER_LABFOUR quota 2m on KMO_QDATA;
grant C##ROLE_LABFOUR to C##USER_LABFOUR;

create table KMO_T1(
id number(15) PRIMARY KEY,
name varchar2(10))
tablespace KMO_QDATA;

insert into KMO_T1 values(1, 'A');
insert into KMO_T1 values(2, 'B');
insert into KMO_T1 values(3, 'C');

SELECT * FROM KMO_T1;

DROP TABLE KMO_T1;

-- 3
select segment_type from DBA_SEGMENTS where tablespace_name='KMO_QDATA';

-- 4
drop table KMO_T1;
--(список сегментов)
select * from DBA_SEGMENTS where tablespace_name='KMO_QDATA';
--(запрос к представление)
select * from user_recyclebin;

-- 5
flashback table KMO_T1 to before drop;

-- 6
BEGIN
  FOR k IN 4..10004
  LOOP
    insert into KMO_T1 values(k, 'A');
  END LOOP;
END;


SELECT * FROM KMO_T1 order by id;

-- 7
select extent_id, blocks, bytes from DBA_EXTENTS where SEGMENT_NAME='KMO_T1';

-- 8
DROP TABLESPACE KMO_QDATA INCLUDING CONTENTS AND DATAFILES;

-- 9
SELECT group#, sequence#, bytes, members, status, first_change# FROM V$LOG;

-- 10
SELECT * FROM V$LOGFILE;

-- 11
ALTER SYSTEM SWITCH LOGFILE; 15:30:25
SELECT * FROM V$LOG;

-- 12
alter database add logfile group 4 ('REDO040.LOG') size 50m blocksize 512;
alter database add logfile member 'REDO041.LOG'  to group 4;
alter database add logfile member 'REDO042.LOG'  to group 4;

SELECT group#, sequence#, bytes, members, status, first_change# FROM V$LOG;

-- 13
alter database clear logfile group 4;
alter database drop logfile group 4;
SELECT group#, sequence#, bytes, members, status, first_change# FROM V$LOG;

-- 14
SELECT NAME, LOG_MODE FROM V$DATABASE;
SELECT INSTANCE_NAME, ARCHIVER, ACTIVE_STATE FROM V$INSTANCE;

-- 15
ALTER SYSTEM SWITCH LOGFILE;
SELECT NAME, FIRST_CHANGE#, NEXT_CHANGE# FROM V$ARCHIVED_LOG;

-- 16
--sql plus
--connect /as sysdba
--shutdown immediate;
--startup mount;
--alter database archivelog;
--archive log list;
--alter database open;

-- 17
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1 ='LOCATION=C:\Archives';
ALTER SYSTEM SWITCH LOGFILE;
SELECT NAME, FIRST_CHANGE#, NEXT_CHANGE# FROM V$ARCHIVED_LOG;
-- 18

--shutdown immediate;
--startup mount;
--alter database noarchivelog;
--select name, log_mode from v$database;
--alter database open;

-- 19

select name from v$controlfile;

-- 20
show parameter control;

-- 21
ALTER DATABASE BACKUP CONTROLFILE TO TRACE;
show parameter spfile ;

--              TASK 22

CREATE PFILE='user_pf.ora' FROM SPFILE;
-- \database

--              TASK 23
SELECT * FROM V$PWFILE_USERS;
show parameter password;
select * from v$passwordfile_info;

--              TASK 24
SELECT * FROM V$DIAG_INFO;

--              TASK 25
--C:\Oracle_setup\app\ora_install_user\diag\rdbms\orcl\orcl\alert