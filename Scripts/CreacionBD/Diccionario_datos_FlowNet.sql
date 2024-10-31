---Nombre de todas las bases de datos
SELECT name AS NombreBaseDatos
FROM sys.databases
ORDER BY name;

----Nombre de todas las tablas,esquemas en todas las bases de datos
EXEC sp_MSforeachdb 
'USE [?]; 
 SELECT 
     DB_NAME() AS NombreBaseDatos, 
     schema_name(t.schema_id) AS Esquema, 
     t.name AS NombreTabla
 FROM 
     sys.tables t
 ORDER BY 
     NombreBaseDatos, Esquema, NombreTabla;';

---Restricciones de todas las bases de datos
EXEC sp_MSforeachdb 
'USE [?];

-- Claves Primarias
SELECT 
    DB_NAME() AS NombreBaseDatos,
    schema_name(t.schema_id) AS Esquema,
    t.name AS Tabla,
    kc.name AS NombreRestriccion,
    ''PRIMARY KEY'' AS TipoRestriccion
FROM 
    sys.key_constraints kc
JOIN 
    sys.tables t ON kc.parent_object_id = t.object_id
WHERE 
    kc.type = ''PK''

UNION ALL

-- Claves Foráneas
SELECT 
    DB_NAME() AS NombreBaseDatos,
    schema_name(t.schema_id) AS Esquema,
    t.name AS Tabla,
    kc.name AS NombreRestriccion,
    ''FOREIGN KEY'' AS TipoRestriccion
FROM 
    sys.key_constraints kc
JOIN 
    sys.tables t ON kc.parent_object_id = t.object_id
WHERE 
    kc.type = ''F''

UNION ALL

-- Restricciones Únicas
SELECT 
    DB_NAME() AS NombreBaseDatos,
    schema_name(t.schema_id) AS Esquema,
    t.name AS Tabla,
    kc.name AS NombreRestriccion,
    ''UNIQUE'' AS TipoRestriccion
FROM 
    sys.key_constraints kc
JOIN 
    sys.tables t ON kc.parent_object_id = t.object_id
WHERE 
    kc.type = ''UQ''

ORDER BY 
    NombreBaseDatos, Esquema, Tabla;';

---Campos de todas las tablas de todas las bases de datos
EXEC sp_MSforeachdb 
'USE [?];
 SELECT 
    DB_NAME() AS NombreBaseDatos,
    schema_name(t.schema_id) AS Esquema,
    t.name AS NombreTabla,
    c.name AS NombreColumna,
    ty.name AS TipoDeDato

 FROM 
    sys.columns c
 JOIN 
    sys.tables t ON c.object_id = t.object_id
 JOIN 
    sys.types ty ON c.user_type_id = ty.user_type_id
 ORDER BY 
    NombreBaseDatos, Esquema, NombreTabla, c.column_id;';

---Vistas de todas las tablas
EXEC sp_MSforeachdb 
'USE [?];
 SELECT 
    DB_NAME() AS NombreBaseDatos,
    schema_name(v.schema_id) AS Esquema,
    v.name AS NombreVista,
    m.definition AS Definicion
 FROM 
    sys.views v
 JOIN 
    sys.sql_modules m ON v.object_id = m.object_id
 ORDER BY 
    NombreBaseDatos, Esquema, NombreVista;';

----Procedimentos almacenados de todas las bases de datos
EXEC sp_MSforeachdb 
'USE [?];
 SELECT 
    DB_NAME() AS NombreBaseDatos,
    schema_name(p.schema_id) AS Esquema,
    p.name AS NombreProcedimiento,
    m.definition AS Definicion
 FROM 
    sys.procedures p
 JOIN 
    sys.sql_modules m ON p.object_id = m.object_id
 ORDER BY 
    NombreBaseDatos, Esquema, NombreProcedimiento;';

---Detonadores de todas las bases de datos
EXEC sp_MSforeachdb 
'USE [?];
 SELECT 
    DB_NAME() AS NombreBaseDatos,
    schema_name(t.schema_id) AS Esquema,
    tbl.name AS TablaAsociada,
    trg.name AS NombreTrigger,
    trg.is_disabled AS Deshabilitado,
    m.definition AS Definicion
 FROM 
    sys.triggers trg
 JOIN 
    sys.tables tbl ON trg.parent_id = tbl.object_id
 JOIN 
    sys.schemas t ON tbl.schema_id = t.schema_id
 JOIN 
    sys.sql_modules m ON trg.object_id = m.object_id
 ORDER BY 
    NombreBaseDatos, Esquema, TablaAsociada, NombreTrigger;';

---Usuarios de todas las bases de datos
EXEC sp_MSforeachdb 
'USE [?];
 SELECT 
    DB_NAME() AS NombreBaseDatos,
    dp.name AS NombreUsuario,
    dp.type_desc AS TipoUsuario
 FROM 
    sys.database_principals dp
 WHERE 
    dp.type IN (''S'', ''U'', ''G'', ''R'') -- Usuarios SQL, Usuarios, Grupos y Roles
    AND dp.name NOT IN (''INFORMATION_SCHEMA'', ''sys'', ''guest'')
 ORDER BY 
    NombreBaseDatos, NombreUsuario;';

---Roles en todas las bases de datos
EXEC sp_MSforeachdb 
'USE [?];
 SELECT 
    DB_NAME() AS NombreBaseDatos,
    dp.name AS NombreRol,
    dp.type_desc AS TipoRol
 FROM 
    sys.database_principals dp
 WHERE 
    dp.type IN (''R'', ''G'') -- Roles y Grupos
 ORDER BY 
    NombreBaseDatos, NombreRol;';

