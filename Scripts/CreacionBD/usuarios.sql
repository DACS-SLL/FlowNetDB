USE FlowNet;
GO

CREATE LOGIN administrador WITH PASSWORD = 'AdminDcs';
CREATE USER administrador FOR LOGIN administrador;

CREATE LOGIN analista_datos WITH PASSWORD = 'AnBrt';
CREATE USER analista_datos FOR LOGIN analista_datos;

CREATE LOGIN revisor WITH PASSWORD = 'RevEny';
CREATE USER revisor FOR LOGIN revisor;

CREATE LOGIN empleado1 WITH PASSWORD = 'EmplAndr';
CREATE USER empleado1 FOR LOGIN empleado1;

CREATE LOGIN empleado2 WITH PASSWORD = 'EmplAlv';
CREATE USER empleado2 FOR LOGIN empleado2;

ALTER ROLE db_owner ADD MEMBER administrador;

ALTER ROLE db_datareader ADD MEMBER analista_datos;
ALTER ROLE db_datawriter ADD MEMBER analista_datos;

ALTER ROLE db_datareader ADD MEMBER revisor;

ALTER ROLE db_datareader ADD MEMBER empleado1;
ALTER ROLE db_datawriter ADD MEMBER empleado1;

ALTER ROLE db_datareader ADD MEMBER empleado2;
ALTER ROLE db_datawriter ADD MEMBER empleado2;
