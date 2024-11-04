USE FlowNet3;
GO

-- Insertar datos en Man_Pais
INSERT INTO Man_Pais (nombre_pais)
VALUES ('Perú'), ('Chile'), ('Colombia'), ('Argentina'), ('México');

-- Insertar datos en Man_ciudad
INSERT INTO Man_ciudad (nombre, id_pais)
VALUES 
('Lima', 1), ('Santiago', 2), ('Bogotá', 3), ('Buenos Aires', 4), ('Ciudad de México', 5),
('Arequipa', 1), ('Valparaíso', 2), ('Medellín', 3), ('Córdoba', 4), ('Guadalajara', 5);

-- Insertar datos en Metodo_Pago
INSERT INTO Metodo_Pago (tipo)
VALUES ('Efectivo'), ('Tarjeta de Crédito'), ('Transferencia Bancaria'), ('Cheque'), ('PayPal');

-- Insertar datos en Tipo_Comprobante
INSERT INTO Tipo_Comprobante (tipo)
VALUES ('Factura'), ('Boleta'), ('Nota de Crédito'), ('Nota de Débito');

-- Insertar datos en Marca
INSERT INTO Marca (tipo)
VALUES ('Toyota'), ('Nissan'), ('Ford');

-- Insertar datos en Preferencias
INSERT INTO Preferencias (id_marca, id_metodopago)
SELECT TOP 100 
    ABS(CHECKSUM(NEWID())) % 5 + 1,
    ABS(CHECKSUM(NEWID())) % 5 + 1
FROM sys.all_columns;

-- Insertar 500 clientes
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

-- Insertar datos en InformCliente
INSERT INTO InformCliente (id_cliente, direccion, id_ciudad, historial_compras, email, id_preferencia)
SELECT 
    id_cliente,
    CONCAT('Calle ', id_cliente, ' #', ABS(CHECKSUM(NEWID())) % 100),
    ABS(CHECKSUM(NEWID())) % 10 + 1,
    'Sin historial',
    CONCAT('cliente', id_cliente, '@correo.com'),
    ABS(CHECKSUM(NEWID())) % 100 + 1
FROM Cliente;

-- Insertar 100 empleados
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

-- Insertar datos en EmpleadoVentas, EmpleadoAdministrativo y EmpleadoOperativo
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

-- Insertar 500 vehículos
SET @i = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO Vehiculo (id_cliente, precio)
    VALUES (
        ABS(CHECKSUM(NEWID())) % 500 + 1,
        20000 + (ABS(CHECKSUM(NEWID())) % 30000)
    );
    SET @i = @i + 1;
END;

-- Insertar datos en Detalle_Vehiculo
INSERT INTO Detalle_Vehiculo (id_vehiculo, año, id_marca, modelo, potencia, kms)
SELECT 
    id_vehiculo,
    2020 + (ABS(CHECKSUM(NEWID())) % 5),
    ABS(CHECKSUM(NEWID())) % 5 + 1,
    CONCAT('Modelo', id_vehiculo),
    CONCAT(100 + (ABS(CHECKSUM(NEWID())) % 200), ' HP'),
    CAST(RAND(CHECKSUM(NEWID())) * 100000 AS DECIMAL(10,2))
FROM Vehiculo;

-- Insertar 10 concesionarios
INSERT INTO Concesionario (nombre_concesionario, direccion, id_ciudad, capacidad)
SELECT TOP 10
    CONCAT('Concesionario ', ROW_NUMBER() OVER (ORDER BY NEWID())),
    CONCAT('Dirección ', ROW_NUMBER() OVER (ORDER BY NEWID())),
    ABS(CHECKSUM(NEWID())) % 10 + 1,
    50 + (ABS(CHECKSUM(NEWID())) % 50)
FROM sys.all_columns;

-- Insertar 50 talleres
INSERT INTO Taller (id_concesionario, capacidad, direccion, id_ciudad)
SELECT TOP 50
    ABS(CHECKSUM(NEWID())) % 10 + 1,
    30 + (ABS(CHECKSUM(NEWID())) % 20),
    CONCAT('Dirección Taller ', ROW_NUMBER() OVER (ORDER BY NEWID())),
    ABS(CHECKSUM(NEWID())) % 10 + 1
FROM sys.all_columns;

-- Insertar datos en Marca_Repuesto y Modelo_Repuesto
INSERT INTO Marca_Repuesto (nombre_marca)
VALUES ('MarcaRepuesto1'), ('MarcaRepuesto2'), ('MarcaRepuesto3'), ('MarcaRepuesto4'), ('MarcaRepuesto5');

INSERT INTO Modelo_Repuesto (nombre_modelo)
VALUES ('ModeloRepuesto1'), ('ModeloRepuesto2'), ('ModeloRepuesto3'), ('ModeloRepuesto4'), ('ModeloRepuesto5');

-- Insertar 500 mantenimientos
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

-- Insertar 500 repuestos
SET @i = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO Repuestos (id_mantenimiento, id_marca, id_modelo, nombre, precio, fecha_de_compra, estado)
    VALUES (
        ABS(CHECKSUM(NEWID())) % 500 + 1,
        ABS(CHECKSUM(NEWID())) % 5 + 1,
        ABS(CHECKSUM(NEWID())) % 5 + 1,
        CONCAT('Repuesto ', @i),
        CAST(RAND(CHECKSUM(NEWID())) * 1000 AS DECIMAL(18,2)),
        GETDATE(),
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'Nuevo' ELSE 'Usado' END
    );
    SET @i = @i + 1;
END;

-- Insertar 500 ventas
SET @i = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO Venta (id_empleado, fecha, id_tipoC, XMLSUNAT)
    VALUES (
        ABS(CHECKSUM(NEWID())) % 100 + 1,  -- id_empleado
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE()),  -- fecha aleatoria en el último año
        ABS(CHECKSUM(NEWID())) % 4 + 1,  -- id_tipoC
        '<xml>Ejemplo de XML SUNAT</xml>'  -- XMLSUNAT
    );
    SET @i = @i + 1;
END;

-- Insertar datos en DetalleVenta
INSERT INTO DetalleVenta (id_venta, id_vehiculo, id_metodo_pago, pago_inicial, saldo_pendiente, id_cliente, re_registro)
SELECT 
    v.id_venta,
    ABS(CHECKSUM(NEWID())) % 500 + 1,  -- id_vehiculo
    ABS(CHECKSUM(NEWID())) % 5 + 1,  -- id_metodo_pago
    CAST(RAND(CHECKSUM(NEWID())) * 10000 AS DECIMAL(18,2)),  -- pago_inicial
    CAST(RAND(CHECKSUM(NEWID())) * 10000 AS DECIMAL(18,2)),  -- saldo_pendiente
    ABS(CHECKSUM(NEWID())) % 500 + 1,  -- id_cliente
    ABS(CHECKSUM(NEWID())) % 2  -- re_registro
FROM Venta v;

-- Insertar datos en ContratoCompra y DetalleContrato
INSERT INTO ContratoCompra (id_venta, fecha)
SELECT id_venta, GETDATE()
FROM Venta;

INSERT INTO DetalleContrato (id_contrato, termino_condiciones, politicas)
SELECT 
    id_contrato,
    'Términos y condiciones del contrato',
    'Políticas del contrato'
FROM ContratoCompra;

-- Insertar datos en ComprobanteElectronico
INSERT INTO ComprobanteElectronico (id_venta, id_tipoC, formatoXML, fecha_emision, impuestos)
SELECT 
    id_venta,
    ABS(CHECKSUM(NEWID())) % 4 + 1,
    'Formato XML del comprobante electrónico',
    GETDATE(),
    CAST(RAND(CHECKSUM(NEWID())) * 1000 AS DECIMAL(18,2))
FROM Venta;

-- INSERCIONES CON SUBCONSULTAS
-- Insertar una venta con un empleado y un cliente existente
INSERT INTO Venta (id_cliente, id_empleado, tipo_comprobante, fecha, pago_inicial, metodo_pago)
VALUES (
    (SELECT id FROM Cliente WHERE nombre = 'Juan Pérez'),  
    (SELECT id FROM Empleado WHERE nombre = 'Carlos Gómez'),  
    'Factura', 
    GETDATE(), 
    5000.00, 
    'Tarjeta de Crédito'
);

-- Obtener el id_vehiculo
INSERT INTO Mantenimiento (id_vehiculo, tipo, fecha, detalles)
VALUES (
    (SELECT id_vehiculo FROM Vehiculo WHERE modelo = 'Toyota Corolla' AND año = 2020),  -- Subconsulta para obtener el id del vehículo
    'Preventivo', 
    GETDATE(), 
    'Cambio de aceite y revisión general'
);

-- Insertar un Detalle de Venta para obtener el id_venta y id_vehiculo
INSERT INTO Detalle_Venta (id_venta, id_vehiculo, precio)
VALUES (
    (SELECT TOP 1 id_venta FROM Venta WHERE id_cliente = (SELECT id FROM Cliente WHERE nombre = 'Juan Pérez') ORDER BY fecha DESC),  -- Subconsulta para obtener la venta más reciente del cliente
    (SELECT id_vehiculo FROM Vehiculo WHERE modelo = 'Honda Civic' AND año = 2019),  -- Subconsulta para obtener el id del vehículo
    18000.00
);

-- Insertar un registro de capacitación en un concesionario
INSERT INTO Capacitado (id_concesionario, id_empleado, fecha)
VALUES (
    (SELECT id FROM Concesionario WHERE nombre = 'Concesionaria ABC'),  -- Subconsulta para obtener el id del concesionario
    (SELECT id FROM Empleado WHERE nombre = 'María López'),  -- Subconsulta para obtener el id del empleado
    GETDATE()
);

-- Insertar un cliente nuevo asociado a una historia de compras
INSERT INTO Cliente (nombre, telefono, direccion, email, historia_compras)
VALUES (
    'Pedro Díaz', 
    '987654321', 
    'Calle Falsa 123', 
    'pedro.diaz@mail.com', 
    (SELECT TOP 1 id_venta FROM Venta ORDER BY fecha DESC)  -- Subconsulta para obtener la venta más reciente
);

-- Insertar un vehículo y asignarle una marca existente
INSERT INTO Vehiculo (modelo, año, precio, id_marca)
VALUES (
    'Ford Fiesta', 
    2021, 
    15000.00, 
    (SELECT id FROM Marca WHERE nombre = 'Ford')  -- Subconsulta para obtener el id de la marca
);
