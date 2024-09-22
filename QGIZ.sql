SELECT SCHEMA_NAME
FROM INFORMATION_SCHEMA.SCHEMATA

-- 6.	Определите тип пространственных данных во всех таблицах.
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'

-- 7.	Определите SRID
select geometry_columns.srid as SRID from geometry_columns

-- 8.	Определите атрибутивные столбцы
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' AND DATA_TYPE != 'geometry'

-- 9.	Верните описания пространственных объектов в формате WKT
SELECT geom.STAsText() AS WKT_Description FROM ne_50m_land

-- 10
select * from ne_50m_land;

-- 10.1. Нахождение пересечения пространственных объектов

SELECT obj1.geom.STIntersection(obj2.geom) AS Intersection
FROM ne_50m_land obj1, ne_50m_land obj2
WHERE obj1.qgs_fid = 1 AND obj2.qgs_fid = 1

-- 10.2. Нахождение пересечения пространственных объектов

SELECT geom.STPointN(1).ToString() AS VertexCoordinates
FROM ne_50m_land
WHERE qgs_fid = 1

-- 10.3. Нахождение площади пространственных объектов;	
SELECT geom.STArea() AS ObjectArea
FROM ne_50m_land
WHERE qgs_fid = 5

-- 11. Создайте пространственный объект в виде точки (1) /линии (2) /полигона (3).	
DECLARE @pointGeometry GEOMETRY;
SET @pointGeometry = GEOMETRY::STGeomFromText('POINT(10 20)', 0); 
SELECT @pointGeometry AS PointGeometry;

DECLARE @lineGeometry GEOMETRY;
SET @lineGeometry = GEOMETRY::STGeomFromText('LINESTRING(1 5, 20 30)', 0); 
SELECT @lineGeometry AS LineGeometry;

DECLARE @polygonGeometry GEOMETRY;
SET @polygonGeometry = GEOMETRY::STGeomFromText('POLYGON((1 1, 50 1, 50 50, 1 50, 1 1))', 0);
SELECT @polygonGeometry AS PolygonGeometry;


-- 12. Создайте пространственный объект в виде точки (1) /линии (2) /полигона (3).	
DECLARE @point GEOMETRY = GEOMETRY::STGeomFromText('POINT(10 20)', 0); 
DECLARE @polygon GEOMETRY = GEOMETRY::STGeomFromText('POLYGON((10 10, 60 10, 60 60, 10 60, 10 10))', 0);
SELECT @point.STWithin(@polygon) AS PointWithinPolygon;

DECLARE @line GEOMETRY = GEOMETRY::STGeomFromText('LINESTRING(1 5, 10 5)', 0);
DECLARE @polygonn GEOMETRY = GEOMETRY::STGeomFromText('POLYGON((10 10, 60 10, 60 60, 10 60, 10 10))', 0);
SELECT @line.STIntersects(@polygonn) AS LineIntersectsPolygon;


-- 13. Продемонстрируйте индексирование пространственных объектов.
create index Geometry_index on ne_50m_land(qgs_fid);

-- 14. Разработайте хранимую процедуру, которая принимает координаты точки и возвращает пространственный объект, в который эта точка попадает.
create procedure PointCheckProc
@point geometry
as
begin
DECLARE @polygon GEOMETRY = GEOMETRY::STGeomFromText('POLYGON((1 1, 50 1, 50 50, 1 50, 1 1))', 0);
SELECT @point.STWithin(@polygon) AS PointWithinPolygon;
end;

exec PointCheckProc 'POINT(2 5)';
