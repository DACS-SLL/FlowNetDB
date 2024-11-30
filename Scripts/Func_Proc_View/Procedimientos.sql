--Procedimientos almacenados
--Registrar un nuevo cliente
CREATE PROCEDURE RegistrarCliente
    @nombre NVARCHAR(100),
    @telefono NVARCHAR(20) = NULL,
    @RUC NVARCHAR(20) = NULL,
    @dni NVARCHAR(15) = NULL
AS
BEGIN
    -- Verificar si el cliente ya existe por RUC o DNI
    IF EXISTS (SELECT 1 FROM [dbo].[Cliente] WHERE [RUC] = @RUC)
    BEGIN
        PRINT 'Error: El RUC ya está registrado.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[Cliente] WHERE [dni] = @dni)
    BEGIN
        PRINT 'Error: El DNI ya está registrado.';
        RETURN;
    END

    -- Insertar el nuevo cliente
    INSERT INTO [dbo].[Cliente] ([nombre], [telefono], [RUC], [dni])
    VALUES (@nombre, @telefono, @RUC, @dni);

    PRINT 'Cliente registrado exitosamente.';
END

GO
--Registrar una venta con comprobante electrónico
CREATE PROCEDURE RegistrarVentaConComprobante (
@id_cliente INT,
@id_empleado INT,
@id_vehiculo INT,
@fecha DATETIME,
@metodo_pago NVARCHAR(50),
@pago_inicial DECIMAL(18, 2),
@saldo_pendiente DECIMAL(18, 2),
@tipo_comprobante NVARCHAR(50),
@impuestos DECIMAL(18, 2)
)
AS
BEGIN
DECLARE @id_venta INT;
-- Registrar la venta
INSERT INTO Venta (id_cliente, id_empleado, id_vehiculo, fecha, metodo_pago,
pago_inicial, saldo_pendiente, tipo_comprobante)
VALUES (@id_cliente, @id_empleado, @id_vehiculo, @fecha, @metodo_pago,
@pago_inicial, @saldo_pendiente, @tipo_comprobante);
SET @id_venta = SCOPE_IDENTITY();
-- Generar el comprobante electrónico
INSERT INTO ComprobanteElectronico (id_venta, tipo, formatoXML, fecha_emision,
impuestos)
VALUES (@id_venta, @tipo_comprobante, '<XMLDatos>', @fecha, @impuestos);
END;
GO
--Generar un reporte de ventas mensuales
CREATE PROCEDURE ReporteVentasMensuales (
@mes INT,
@anio INT
)
AS
BEGIN
SELECT
v.id_venta,
c.nombre AS nombre_cliente,
e.nombre AS nombre_empleado,
v.fecha,
v.pago_inicial + v.saldo_pendiente AS total_pagado,
v.metodo_pago
FROM Venta v
JOIN Cliente c ON v.id_cliente = c.id_cliente
JOIN Empleado e ON v.id_empleado = e.id_empleado
WHERE MONTH(v.fecha) = @mes AND YEAR(v.fecha) = @anio;
END;
GO

-- AgreaciOn de %ROWTYPE, %TYPE
  
CREATE OR REPLACE PROCEDURE insertar_cliente_nuevo IS
    nuevo_cliente Cliente%ROWTYPE;  
BEGIN
    -- Asignar valores a los campos del cliente nuevo
    nuevo_cliente.nombre := 'Carlos Gómez';
    nuevo_cliente.telefono := '987654321';
    nuevo_cliente.direccion := 'Calle Ejemplo 123';
    nuevo_cliente.email := 'carlos.gomez@mail.com';
    nuevo_cliente.historia_compras := NULL;  

    INSERT INTO Cliente VALUES nuevo_cliente;
END;


CREATE OR REPLACE PROCEDURE registrar_venta_detallada(
    p_nombre_cliente Cliente.nombre%TYPE,  
    p_modelo_vehiculo Vehiculo.modelo%TYPE,  
    p_precio_detalle Venta.precio%TYPE  
) IS
    nueva_venta Venta%ROWTYPE;   
    id_vehiculo Vehiculo.id_vehiculo%TYPE;  
BEGIN
    SELECT id_vehiculo INTO id_vehiculo
    FROM Vehiculo
    WHERE modelo = p_modelo_vehiculo;

    nueva_venta.id_cliente := (SELECT id FROM Cliente WHERE nombre = p_nombre_cliente);
    nueva_venta.id_empleado := (SELECT id FROM Empleado WHERE nombre = 'Carlos Gómez');
    nueva_venta.tipo_comprobante := 'Factura';
    nueva_venta.fecha := SYSDATE;
    nueva_venta.pago_inicial := 3000.00;
    nueva_venta.metodo_pago := 'Efectivo';

    INSERT INTO Venta VALUES nueva_venta;

    INSERT INTO Detalle_Venta (id_venta, id_vehiculo, precio)
    VALUES (
        nueva_venta.id_venta,
        id_vehiculo,
        p_precio_detalle
    );
END;