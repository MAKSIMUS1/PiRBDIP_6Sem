GRANT CREATE ANY DIRECTORY TO C##USER_LABFOUR;


CREATE TABLESPACE lob_ts
    DATAFILE 'C:\Tablespaces\lob_ts.dbf'
    SIZE 100M
    AUTOEXTEND ON;

CREATE DIRECTORY external_docs_dir AS 'C:\external\docs';

create user C##lob_user identified by 123456789
    default tablespace lob_ts
    quota unlimited on lob_ts
    account unlock;


GRANT CREATE SESSION TO C##lob_user;
GRANT RESOURCE TO C##lob_user;
GRANT UNLIMITED TABLESPACE TO C##lob_user;

ALTER USER C##lob_user QUOTA UNLIMITED ON lob_ts;

CREATE TABLE BigTable (
    ID NUMBER PRIMARY KEY,
    FOTO BLOB,
    DOC BFILE
);

ALTER TABLE BigTable ADD (DESCRIPTION CLOB);

INSERT INTO BigTable (ID, FOTO) 
VALUES (1, EMPTY_BLOB());

-- 1.jpeg
DECLARE
    v_blob BLOB;
    v_bfile BFILE;
BEGIN
    DBMS_LOB.createtemporary(v_blob, FALSE);
    v_bfile := BFILENAME('EXTERNAL_DOCS_DIR', '1.jpeg');
    DBMS_LOB.fileopen(v_bfile, DBMS_LOB.file_readonly);
    DBMS_LOB.loadfromfile(v_blob, v_bfile, DBMS_LOB.getlength(v_bfile));
    
    INSERT INTO BigTable (ID, FOTO) VALUES (2, v_blob);
    
    DBMS_LOB.fileclose(v_bfile);
    DBMS_LOB.freetemporary(v_blob);
END;

--  2.jpg
DECLARE
    v_blob BLOB;
    v_bfile BFILE;
BEGIN
    DBMS_LOB.createtemporary(v_blob, FALSE);
    v_bfile := BFILENAME('EXTERNAL_DOCS_DIR', '2.jpg');
    DBMS_LOB.fileopen(v_bfile, DBMS_LOB.file_readonly);
    DBMS_LOB.loadfromfile(v_blob, v_bfile, DBMS_LOB.getlength(v_bfile));
    
    INSERT INTO BigTable (ID, FOTO) VALUES (3, v_blob);
    
    DBMS_LOB.fileclose(v_bfile);
    DBMS_LOB.freetemporary(v_blob);
END;

-- asp.pdf
DECLARE
    v_bfile BFILE;
BEGIN
    v_bfile := BFILENAME('EXTERNAL_DOCS_DIR', 'asp.pdf');
    
    INSERT INTO BigTable (ID, DOC) VALUES (4, v_bfile);
END;

DECLARE
    v_clob CLOB;
BEGIN
    v_clob := 'Description for asp.pdf';
    
    INSERT INTO BigTable (ID, DESCRIPTION) VALUES (5, v_clob);
END;



SELECT * FROM BigTable;

