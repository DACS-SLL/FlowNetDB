USE FlowNet;
GO

INSERT INTO Man_Pais (nombre_pais)
VALUES ('Perú'), ('Chile'), ('Colombia'), ('Argentina'), ('México');

INSERT INTO Man_ciudad (nombre, id_pais)
VALUES 
('Lima', 1), ('Santiago', 2), ('Bogotá', 3), ('Buenos Aires', 4), ('Ciudad de México', 5),
('Arequipa', 1), ('Valparaíso', 2), ('Medellín', 3), ('Córdoba', 4), ('Guadalajara', 5),
('Huanuco', 1), ('Osorno', 2), ('Cali', 3), ('Mendoza', 4), ('Monterrey', 5);

INSERT INTO Metodo_Pago (tipo)
VALUES ('Efectivo'), ('Tarjeta de Crédito'), ('Transferencia Bancaria'), ('Cheque'), ('PayPal');

INSERT INTO Tipo_Comprobante (tipo)
VALUES ('Factura'), ('Boleta'), ('Nota de Crédito'), ('Nota de Débito');

INSERT INTO Marca (tipo)
VALUES ('Toyota'), ('Nissan'), ('Ford');

INSERT INTO Preferencias (id_marca, id_metodopago)
SELECT TOP 100 
    ABS(CHECKSUM(NEWID())) % 3 + 1,
    ABS(CHECKSUM(NEWID())) % 5 + 1
FROM sys.all_columns;

DECLARE @i INT = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO Cliente (nombre, telefono, RUC, dni)
    VALUES (
        CONCAT('Cliente', @i), 
        CONCAT('99', RIGHT('00000000' + CAST(ABS(CHECKSUM(NEWID())) % 90000000 + 10000000 AS VARCHAR(8)), 8)),
        RIGHT('00000000' + CAST(ABS(CHECKSUM(NEWID())) % 90000000 + 10000000 AS VARCHAR(8)), 8),
        RIGHT('00000000' + CAST(ABS(CHECKSUM(NEWID())) % 90000000 + 10000000 AS VARCHAR(8)), 8)
    );
    SET @i = @i + 1;
END;

INSERT INTO InformCliente (id_cliente, direccion, id_ciudad, historial_compras, email, id_preferencia)
SELECT 
    id_cliente,
    CONCAT('Calle ', id_cliente, ' #', ABS(CHECKSUM(NEWID())) % 100),
    ABS(CHECKSUM(NEWID())) % 16 + 1, 
    'Sin historial',
    CONCAT('cliente', id_cliente, '@correo.com'),
    ABS(CHECKSUM(NEWID())) % 50 + 1 
FROM Cliente
WHERE id_cliente NOT IN (SELECT id_cliente FROM InformCliente);




SET @i = 1;
WHILE @i <= 5
BEGIN
    INSERT INTO Empleado (nombre, dni, disponibilidad)
    VALUES (
        CONCAT('Empleado', @i), 
        RIGHT('00000000' + CAST(ABS(CHECKSUM(NEWID())) % 90000000 + 10000000 AS VARCHAR(8)), 8),
        ABS(CHECKSUM(NEWID())) % 2
    );
    SET @i = @i + 1;
END;

INSERT INTO EmpleadoVentas (id_empleado, comisiones)
SELECT TOP 2 id_empleado, CAST(RAND(CHECKSUM(NEWID())) * 1000 AS DECIMAL(18,2))
FROM Empleado
WHERE id_empleado NOT IN (SELECT id_empleado FROM EmpleadoVentas)
ORDER BY NEWID();


INSERT INTO EmpleadoAdministrativo (id_empleado, actividades_admin)
SELECT TOP 5 id_empleado, 'Actividades administrativas generales'
FROM Empleado
WHERE id_empleado NOT IN (SELECT id_empleado FROM EmpleadoVentas)
  AND id_empleado NOT IN (SELECT id_empleado FROM EmpleadoAdministrativo)
ORDER BY NEWID();


INSERT INTO EmpleadoOperativo (id_empleado, disponibilidad)
SELECT id_empleado, 'Disponible'
FROM Empleado
WHERE id_empleado NOT IN (SELECT id_empleado FROM EmpleadoVentas)
  AND id_empleado NOT IN (SELECT id_empleado FROM EmpleadoAdministrativo)
  AND id_empleado NOT IN (SELECT id_empleado FROM EmpleadoOperativo);


SET @i = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO Vehiculo (id_cliente, precio, estado)
    VALUES (
        (SELECT TOP 1 id_cliente FROM Cliente ORDER BY NEWID()), 
        20000 + (ABS(CHECKSUM(NEWID())) % 30000),
        0
    );
    SET @i = @i + 1;
END;


INSERT INTO Detalle_Vehiculo (id_vehiculo, año, id_marca, modelo, potencia, kms)
SELECT DISTINCT 
    id_vehiculo,
    2020 + (ABS(CHECKSUM(NEWID())) % 5),
    ABS(CHECKSUM(NEWID())) % 3 + 1,
    CONCAT('Modelo', id_vehiculo),
    CONCAT(100 + (ABS(CHECKSUM(NEWID())) % 200), ' HP'),
    CAST(RAND(CHECKSUM(NEWID())) * 100000 AS DECIMAL(10,2))
FROM Vehiculo
WHERE id_vehiculo NOT IN (SELECT id_vehiculo FROM Detalle_Vehiculo);


INSERT INTO Concesionario (nombre_concesionario, direccion, id_ciudad, capacidad)
SELECT TOP 10
    "Concesionario La Salle",
    CONCAT('Dirección ', ROW_NUMBER() OVER (ORDER BY NEWID())),
    ABS(CHECKSUM(NEWID())) % 10 + 1,
    50 + (ABS(CHECKSUM(NEWID())) % 50)
FROM sys.all_columns;

INSERT INTO Taller (id_concesionario, capacidad, direccion, id_ciudad)
SELECT TOP 50
    id_concesionario, 
    30 + (ABS(CHECKSUM(NEWID())) % 20), 
    CONCAT('Dirección Taller ', ROW_NUMBER() OVER (ORDER BY NEWID())),
    id_ciudad 
FROM (
    SELECT 
        c.id_concesionario,
        m.id_ciudad
    FROM Concesionario c
    CROSS JOIN Man_Ciudad m 
) AS valid_ids
ORDER BY NEWID(); 


INSERT INTO Marca_Repuesto (nombre_marca)
VALUES ('Toyota'), ('Nissan'), ('Ford');

INSERT INTO Modelo_Repuesto (nombre_modelo)
VALUES ('Llantas'), ('Motor'), ('Carburador'), ('Frenos'), ('Rotadores');


INSERT INTO Mantenimiento (id_vehiculo, id_empleado, id_concesionario, tipo, fecha, observaciones)
VALUES (
        id_vehiculo,
        id_empleado,
        id_concesionario,
        tipo,
        GETDATE(),
        observaciones,
    );

SET @i = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO Repuestos (id_mantenimiento, id_marca, id_modelo, nombre, precio, fecha_de_compra, estado)
    VALUES (
        ABS(CHECKSUM(NEWID())) % 500 + 1,
        ABS(CHECKSUM(NEWID())) % 3 + 1,
        ABS(CHECKSUM(NEWID())) % 5 + 1,
        CONCAT('Repuesto ', @i),
        CAST(RAND(CHECKSUM(NEWID())) * 1000 AS DECIMAL(18,2)),
        GETDATE(),
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'Nuevo' ELSE 'Usado' END
    );
    SET @i = @i + 1;
END;


-- INSERCIONES CON SUBCONSULTAS
INSERT INTO Mantenimiento (id_vehiculo, id_empleado, tipo, fecha, observaciones)
VALUES (
    (SELECT id_vehiculo FROM Detalle_Vehiculo WHERE modelo = 'Toyota Corolla' AND año = 2020),
    (SELECT id_empleado FROM Empleado WHERE nombre = 'Carlos Gómez'),
    'Preventivo', 
    GETDATE(), 
    'Cambio de aceite y revisión general'
);



--NO MOVER
-- Insertar un usuario con la contraseña encriptada se usará SHA2_256 para encriptar la contraseña
-- Admin Daniel
DECLARE @nombreusuario NVARCHAR(50) = 'DanPk';
DECLARE @contraseña NVARCHAR(50) = 'AdminDcs';
DECLARE @rol NVARCHAR(20) = 'admin';

INSERT INTO Usuarios (nombreusuario, contraseña, rol)
VALUES (
    @nombreusuario,
    HASHBYTES('SHA2_256', @contraseña),  -- Encriptar la contraseña
    @rol
);


-- AnalistaBryan
DECLARE @nombreusuario NVARCHAR(50) = 'FireB';
DECLARE @contraseña NVARCHAR(50) = 'AnBrt';
DECLARE @rol NVARCHAR(20) = 'analista';

INSERT INTO Usuarios (nombreusuario, contraseña, rol)
VALUES (
    @nombreusuario,
    HASHBYTES('SHA2_256', @contraseña),  -- Encriptar la contraseña
    @rol
);

-- Revisor Enyel
DECLARE @nombreusuario NVARCHAR(50) = 'WEnyel';
DECLARE @contraseña NVARCHAR(50) = 'RevEny';
DECLARE @rol NVARCHAR(20) = 'revisor';

INSERT INTO Usuarios (nombreusuario, contraseña, rol)
VALUES (
    @nombreusuario,
    HASHBYTES('SHA2_256', @contraseña),  -- Encriptar la contraseña
    @rol
);

-- Empleados Andrea y Alvaro
DECLARE @nombreusuario NVARCHAR(50) = 'Andrea_V';
DECLARE @contraseña NVARCHAR(50) = 'EmplAndr';
DECLARE @rol NVARCHAR(20) = 'empleado';

INSERT INTO Usuarios (nombreusuario, contraseña, rol)
VALUES (
    @nombreusuario,
    HASHBYTES('SHA2_256', @contraseña),  -- Encriptar la contraseña
    @rol
);

DECLARE @nombreusuario NVARCHAR(50) = 'AlvMax';
DECLARE @contraseña NVARCHAR(50) = 'EmplAlv';
DECLARE @rol NVARCHAR(20) = 'empleado';

INSERT INTO Usuarios (nombreusuario, contraseña, rol)
VALUES (
    @nombreusuario,
    HASHBYTES('SHA2_256', @contraseña),  -- Encriptar la contraseña
    @rol
);





