������, [17.05.2024 10:59]
-- ������� ��������� ��� �����������
CREATE OR REPLACE TYPE EmployeeCollection AS TABLE OF EmployeeType;

-- ������� ��������� ��� ��������
CREATE OR REPLACE TYPE HolidaysCollection AS TABLE OF HolidaysType;


--1 �������
-- ������� ��� ������ ��� ���������� ���������� � ��������� ���������� ��������
CREATE OR REPLACE TYPE EmployeeWithHolidaysType AS OBJECT (
    employee EmployeeType,
    holidays HolidaysCollection
);

-- ������� ��� ��������� ��� ����������� � �� ���������
CREATE OR REPLACE TYPE EmployeeWithHolidaysCollection AS TABLE OF EmployeeWithHolidaysType;


--��������, �������� �� ������ ��������� �����-�� ������������ �������:
DECLARE
    emp_collection EmployeeCollection;
    emp_id NUMBER := 1; -- ������ �������������� ����������, �������� �� ����

BEGIN
    SELECT CAST(MULTISET(
               SELECT EmployeeType(id, ���, �������, �����������_ID, ��������_���������, ���������_�����_ID, ���)
               FROM ����������) AS EmployeeCollection)
    INTO emp_collection
    FROM dual;

    FOR i IN 1..emp_collection.COUNT LOOP
        IF emp_collection(i).id = emp_id THEN
            DBMS_OUTPUT.PUT_LINE('��������� ������!');
            EXIT;
        END IF;
    END LOOP;
END;


--����� ������ ���������:
DECLARE
    emp_collection EmployeeCollection := EmployeeCollection();
BEGIN
    SELECT CAST(MULTISET(
               SELECT EmployeeType(id, ���, �������, �����������_ID, ��������_���������, ���������_�����_ID, ���)
               FROM ����������) AS EmployeeCollection)
    INTO emp_collection
    FROM dual;

    -- ���������, ����� �� ��������� �����������
    IF emp_collection.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('��������� ����������� �����.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('��������� ����������� �� �����.');
    END IF;
END;

--***************
DECLARE
    emp_collection EmployeeCollection;
    holidays_collection HolidaysCollection;
BEGIN
    -- ��������� ��������� �����������
    SELECT CAST(MULTISET(
               SELECT EmployeeType(id, ���, �������, �����������_ID, ��������_���������, ���������_�����_ID, ���)
               FROM ����������) AS EmployeeCollection)
    INTO emp_collection
    FROM dual;

    -- ��������� ��������� ��������
    SELECT CAST(MULTISET(
               SELECT HolidaysType(id, ���������_ID, ����_������,���_�������, ����_���������)
               FROM �������) AS HolidaysCollection)
    INTO holidays_collection
    FROM dual;

    -- ��������� ��� ������� ����������, ���� �� ������ �� �������
    FOR i IN 1..emp_collection.COUNT LOOP
        DECLARE
            holiday_count NUMBER;
        BEGIN
            SELECT COUNT(*)
            INTO holiday_count
            FROM TABLE(holidays_collection)
            WHERE employee_id  = emp_collection(i).id;

            IF holiday_count = 0 THEN
                DBMS_OUTPUT.PUT_LINE('��������� '  emp_collection(i).id  ' �� ����� �������.');
            END IF;

             IF holiday_count != 0 THEN
                DBMS_OUTPUT.PUT_LINE('��������� '  emp_collection(i).id  ' ����� ������.');
            END IF;
        END;
    END LOOP;
END;

--������������� ��������� � ������� ����:
DECLARE
    emp_collection EmployeeCollection;
    hol_collection HolidaysCollection := HolidaysCollection(); -- ������������� ��������� ��������
BEGIN
    -- ��������� ��������� ����������� emp_collection ������� �� ������� ����������
    SELECT CAST(MULTISET(
               SELECT EmployeeType(id, ���, �������, �����������_ID, ��������_���������, ���������_�����_ID, ���)
               FROM ����������) AS EmployeeCollection)
    INTO emp_collection
    FROM dual;

    -- ����������� ��������� ����������� � ��������� ��������
    FOR i IN 1..emp_collection.COUNT LOOP
        hol_collection.EXTEND;
        hol_collection(i) := HolidaysType(
                                emp_collection(i).id,
                                emp_collection(i).id,
                                SYSDATE,
                                '�������� ������',
                                SYSDATE + 14
                             );
    END LOOP;
END;

������, [17.05.2024 10:59]
--����������� ��

CREATE TABLE �������_���� (
    ID NUMBER PRIMARY KEY,
    ���������_ID NUMBER,
    ����_������ DATE,
    ���_������� NVARCHAR2(100),
    ����_��������� DATE,
    FOREIGN KEY (���������_ID) REFERENCES ����������(ID)
);


DECLARE
    emp_collection EmployeeCollection;
    hol_collection HolidaysCollection := HolidaysCollection(); -- ������������� ��������� ��������
BEGIN
    -- ��������� ��������� ����������� emp_collection ������� �� ������� ����������
    SELECT CAST(MULTISET(
               SELECT EmployeeType(id, ���, �������, �����������_ID, ��������_���������, ���������_�����_ID, ���)
               FROM ����������) AS EmployeeCollection)
    INTO emp_collection
    FROM dual;

    -- ����������� ��������� ����������� � ��������� ��������
    FOR i IN 1..emp_collection.COUNT LOOP
        hol_collection.EXTEND;
        hol_collection(i) := HolidaysType(
                                emp_collection(i).id,
                                emp_collection(i).id,
                                SYSDATE,
                                '�������� ������',
                                SYSDATE + 14
                             );
    END LOOP;

    -- ��������� ������ �� ��������� � �������
    FORALL i IN 1..hol_collection.COUNT
        INSERT INTO �������_���� (ID, ���������_ID, ����_������, ����_���������, ���_�������)
        VALUES (hol_collection(i).id, hol_collection(i).employee_id, hol_collection(i).start_date, hol_collection(i).end_date, hol_collection(i).vacation_type);
END;

--���������� BULK ��������:
CREATE TABLE Test_table (
    first_name NVARCHAR2(100),
    last_name NVARCHAR2(100)
);

DECLARE
    emp_collection EmployeeCollection;
BEGIN
    -- ��������� ��������� ����������� emp_collection ������� �� ������� ����������
    SELECT CAST(MULTISET(
               SELECT EmployeeType(id, ���, �������, �����������_ID, ��������_���������, ���������_�����_ID, ���)
               FROM ����������) AS EmployeeCollection)
    INTO emp_collection
    FROM dual;

    -- ��������� BULK �������� ��� ������� ������ �� ��������� � �������
    FORALL i IN 1..emp_collection.COUNT
        INSERT INTO Test_table VALUES (emp_collection(i).first_name, emp_collection(i).last_name);
END;

select *
from Test_table;