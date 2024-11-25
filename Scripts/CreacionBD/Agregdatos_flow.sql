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
    ABS(CHECKSUM(NEWID())) % 3 + 1
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
    ABS(CHECKSUM(NEWID())) % 10 + 1,
    'Sin historial',
    CONCAT('cliente', id_cliente, '@correo.com'),
    ABS(CHECKSUM(NEWID())) % 100 + 3
FROM Cliente;

SET @i = 1;
WHILE @i <= 100
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
SELECT TOP 33 id_empleado, CAST(RAND(CHECKSUM(NEWID())) * 1000 AS DECIMAL(18,2))
FROM Empleado ORDER BY NEWID();

INSERT INTO EmpleadoAdministrativo (id_empleado, actividades_admin)
SELECT TOP 33 id_empleado, 'Actividades administrativas generales'
FROM Empleado WHERE id_empleado NOT IN (SELECT id_empleado FROM EmpleadoVentas)
ORDER BY NEWID();

INSERT INTO EmpleadoOperativo (id_empleado, disponibilidad)
SELECT id_empleado, 'Disponible'
FROM Empleado WHERE id_empleado NOT IN (SELECT id_empleado FROM EmpleadoVentas)
AND id_empleado NOT IN (SELECT id_empleado FROM EmpleadoAdministrativo);

SET @i = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO Vehiculo (id_cliente, precio, estado)
    VALUES (
        ABS(CHECKSUM(NEWID())) % 500 + 1,
        20000 + (ABS(CHECKSUM(NEWID())) % 30000),
        0
    );
    SET @i = @i + 1;
END;

INSERT INTO Detalle_Vehiculo (id_vehiculo, año, id_marca, modelo, potencia, kms)
SELECT 
    id_vehiculo,
    2020 + (ABS(CHECKSUM(NEWID())) % 5),
    ABS(CHECKSUM(NEWID())) % 3 + 1,
    CONCAT('Modelo', id_vehiculo),
    CONCAT(100 + (ABS(CHECKSUM(NEWID())) % 200), ' HP'),
    CAST(RAND(CHECKSUM(NEWID())) * 100000 AS DECIMAL(10,2))
FROM Vehiculo;

INSERT INTO Concesionario (nombre_concesionario, direccion, id_ciudad, capacidad)
SELECT TOP 10
    CONCAT('Concesionario ', ROW_NUMBER() OVER (ORDER BY NEWID())),
    CONCAT('Dirección ', ROW_NUMBER() OVER (ORDER BY NEWID())),
    ABS(CHECKSUM(NEWID())) % 10 + 1,
    50 + (ABS(CHECKSUM(NEWID())) % 50)
FROM sys.all_columns;

INSERT INTO Taller (id_concesionario, capacidad, direccion, id_ciudad)
SELECT TOP 50
    ABS(CHECKSUM(NEWID())) % 10 + 1,
    30 + (ABS(CHECKSUM(NEWID())) % 20),
    CONCAT('Dirección Taller ', ROW_NUMBER() OVER (ORDER BY NEWID())),
    ABS(CHECKSUM(NEWID())) % 10 + 1
FROM sys.all_columns;

INSERT INTO Marca_Repuesto (nombre_marca)
VALUES ('Toyota'), ('Nissan'), ('Ford');

INSERT INTO Modelo_Repuesto (nombre_modelo)
VALUES ('Llantas'), ('Motor'), ('Carburador'), ('Frenos'), ('Rotadores');


SET @i = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO Mantenimiento (id_vehiculo, id_empleado, id_taller, tipo, fecha, observaciones)
    VALUES (
        ABS(CHECKSUM(NEWID())) % 500 + 1,
        ABS(CHECKSUM(NEWID ())) % 100 + 1,
        ABS(CHECKSUM(NEWID())) % 50 + 1,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'Correctivo' ELSE 'Preventivo' END,
        GETDATE(),
        'Observaciones del mantenimiento'
    );
    SET @i = @i + 1;
END;


SET @i = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO Repuestos (id_mantenimiento, id_marca, id_modelo, nombre, precio, fecha_de_compra, estado)
    VALUES (
        ABS(CHECKSUM(NEWID())) % 500 + 1,
        ABS(CHECKSUM(NEWID())) % 3 + 1,
        ABS(CHECKSUM(NEWID())) % 3 + 1,
        CONCAT('Repuesto ', @i),
        CAST(RAND(CHECKSUM(NEWID())) * 1000 AS DECIMAL(18,2)),
        GETDATE(),
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'Nuevo' ELSE 'Usado' END
    );
    SET @i = @i + 1;
END;

SET @i = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO Venta (id_empleado, fecha, id_tipoC, XMLSUNAT)
    VALUES (
        ABS(CHECKSUM(NEWID())) % 100 + 1,
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE()),
        ABS(CHECKSUM(NEWID())) % 4 + 1,
        '<xml>Ejemplo de XML SUNAT</xml>'
    );
    SET @i = @i + 1;
END;

INSERT INTO DetalleVenta (id_venta, id_vehiculo, id_metodo_pago, pago_inicial, saldo_pendiente, id_cliente, re_registro)
SELECT 
    v.id_venta,
    ABS(CHECKSUM(NEWID())) % 500 + 1,
    ABS(CHECKSUM(NEWID())) % 5 + 1,
    CAST(RAND(CHECKSUM(NEWID())) * 10000 AS DECIMAL(18,2)),
    CAST(RAND(CHECKSUM(NEWID())) * 10000 AS DECIMAL(18,2)),
    ABS(CHECKSUM(NEWID())) % 500 + 1,
    ABS(CHECKSUM(NEWID())) % 2
FROM Venta v;

INSERT INTO ContratoCompra (id_venta, fecha)
SELECT id_venta, GETDATE()
FROM Venta;

INSERT INTO DetalleContrato (id_contrato, termino_condiciones, politicas)
SELECT 
    id_contrato,
    'Términos y condiciones del contrato',
    'Políticas del contrato'
FROM ContratoCompra;

INSERT INTO ComprobanteElectronico (id_venta, id_tipoC, formatoXML, fecha_emision, impuestos)
SELECT 
    id_venta,
    ABS(CHECKSUM(NEWID())) % 4 + 1,
    'Formato XML del comprobante electrónico',
    GETDATE(),
    CAST(RAND(CHECKSUM(NEWID())) * 1000 AS DECIMAL(18,2))
FROM Venta;

-- INSERCIONES CON SUBCONSULTAS
INSERT INTO Venta (id_empleado, fecha, id_tipoC, XMLSUNAT)
VALUES (
    (SELECT id_empleado FROM Empleado WHERE nombre = 'Carlos Gómez'),  
    GETDATE(), 
    (SELECT id_tipoC FROM Tipo_Comprobante WHERE tipo = 'Factura'),
    NULL
);

INSERT INTO Mantenimiento (id_vehiculo, id_empleado, tipo, fecha, observaciones)
VALUES (
    (SELECT id_vehiculo FROM Detalle_Vehiculo WHERE modelo = 'Toyota Corolla' AND año = 2020),
    (SELECT id_empleado FROM Empleado WHERE nombre = 'Carlos Gómez'),
    'Preventivo', 
    GETDATE(), 
    'Cambio de aceite y revisión general'
);

INSERT INTO DetalleVenta (id_venta, id_vehiculo, id_metodo_pago, pago_inicial)
VALUES (
    (SELECT TOP 1 id_venta FROM DetalleVenta WHERE id_cliente = (SELECT id_cliente FROM Cliente WHERE nombre = 'Juan Pérez')), 
    (SELECT id_vehiculo FROM Detalle_Vehiculo WHERE modelo = 'Ford' AND año = 2019),
    (SELECT id_metodo_pago FROM Metodo_Pago WHERE tipo = 'Tarjeta de Crédito'),
    18000.00
);

INSERT INTO Repuestos (nombre, precio, estado, id_mantenimiento)
VALUES (
    'Filtro de aceite', 
    50.00, 
    'Nuevo', 
    (SELECT TOP 1 id_mantenimiento FROM Mantenimiento ORDER BY fecha DESC)
);

INSERT INTO Taller (id_concesionario, capacidad, direccion)
VALUES (
    (SELECT id_concesionario FROM Concesionario WHERE nombre_concesionario = 'Concesionaria XYZ'),
    50, 
    'Av. Principal 456'
);

INSERT INTO ContratoCompra (id_venta, fecha)
VALUES (
    (SELECT TOP 1 id_venta 
     FROM Venta 
     WHERE id_empleado = (SELECT id_empleado FROM Empleado WHERE nombre = 'Sofía Martínez') 
     ORDER BY fecha DESC),
    (SELECT TOP 1 fecha 
     FROM Venta 
     WHERE id_empleado = (SELECT id_empleado FROM Empleado WHERE nombre = 'Sofía Martínez') 
     ORDER BY fecha DESC)
);

