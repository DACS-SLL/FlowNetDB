--Estadisticas de rendimiento

SELECT * FROM sys.dm_exec_query_stats

--Integridad de datos

SELECT * FROM sys.check_constraints;
SELECT * FROM sys.foreign_keys;


--Auditoria de CRUD
USE [master]
GO

-- Crear una auditoría
CREATE SERVER AUDIT [AuditoriaFlowNet]
TO FILE 
(
    FILEPATH = 'D:\DBS\Fl\Audit', -- Cambiar esta ruta a donde quieras guardar los archivos de auditoría
    MAXSIZE = 10 MB,
    MAX_ROLLOVER_FILES = 5,
    RESERVE_DISK_SPACE = OFF
)
WITH 
(
    QUEUE_DELAY = 1000, 
    ON_FAILURE = CONTINUE
);
GO

-- Habilitar la auditoría
ALTER SERVER AUDIT [AuditoriaFlowNet] WITH (STATE = ON);
GO

USE [FlowNet]
GO

-- Crear una especificación de auditoría para la base de datos
CREATE DATABASE AUDIT SPECIFICATION [EspecificacionAuditoriaFlowNet]
FOR SERVER AUDIT [AuditoriaFlowNet]
ADD (SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo BY [public]) -- Auditar todas las operaciones en el esquema dbo
WITH (STATE = ON);
GO

Select * from Cliente
--Revisamos registros
SELECT 
    event_time,
    action_id,
    succeeded,
    session_id,
    server_principal_name,
    database_name,
    object_name,
    statement
FROM 
    sys.fn_get_audit_file('D:\DBS\Fl\Audit\*.sqlaudit', DEFAULT, DEFAULT);


--Auditoría de Usuarios

USE [master]
GO

-- Crear una auditoría para inicios de sesión
CREATE SERVER AUDIT [AuditoriaIniciosDeSesion]
TO FILE 
(
    FILEPATH = 'D:\DBS\Fl\Audit\Us', -- Cambiar esta ruta a donde quieras guardar los archivos de auditoría
    MAXSIZE = 10 MB,
    MAX_ROLLOVER_FILES = 5,
    RESERVE_DISK_SPACE = OFF
)
WITH 
(
    QUEUE_DELAY = 1000, 
    ON_FAILURE = CONTINUE
);
GO

-- Habilitar la auditoría
ALTER SERVER AUDIT [AuditoriaIniciosDeSesion] WITH (STATE = ON);
GO

USE [master]
GO

-- Crear una especificación de auditoría para inicios de sesión
CREATE SERVER AUDIT SPECIFICATION [EspecificacionIniciosDeSesion]
FOR SERVER AUDIT [AuditoriaIniciosDeSesion]
ADD (FAILED_LOGIN_GROUP),  -- Auditar intentos de inicio de sesión fallidos
ADD (SUCCESSFUL_LOGIN_GROUP) -- Auditar inicios de sesión exitosos
WITH (STATE = ON);
GO

SELECT 
    event_time,
    action_id,
    succeeded,
    session_id,
    server_principal_name,
    client_ip,
    database_name,
    statement
FROM 
    sys.fn_get_audit_file('D:\DBS\Fl\Audit\Us\*.sqlaudit', DEFAULT, DEFAULT);
