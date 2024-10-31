--Funciones
--Calcular la Comisión Total de un Empleado de Ventas:
CREATE FUNCTION CalcularComisionTotalEmpleado (
@id_empleado INT,
@fecha_inicio DATETIME,
@fecha_fin DATETIME
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
DECLARE @comision_total DECIMAL(18, 2);
SELECT @comision_total = SUM(ev.comisiones)
FROM EmpleadoVentas ev
JOIN Venta v ON v.id_empleado = ev.id_empleado
WHERE ev.id_empleado = @id_empleado
AND v.fecha BETWEEN @fecha_inicio AND @fecha_fin;
RETURN ISNULL(@comision_total, 0);
END;
GO
--Calcular el Descuento Promedio en Ventas:
CREATE FUNCTION CalcularDescuentoPromedio()
RETURNS DECIMAL(18, 2)
AS
BEGIN
DECLARE @descuento_promedio DECIMAL(18, 2);
SELECT @descuento_promedio = AVG((v.precio - dv.pago_inicial) / v.precio * 100)
FROM Vehiculo v
JOIN Venta dv ON v.id_vehiculo = dv.id_vehiculo;
RETURN ISNULL(@descuento_promedio, 0);
END;
GO
--Determinar la Capacidad Disponible en Talleres
CREATE FUNCTION CapacidadDisponibleTaller (
@id_taller INT
)
RETURNS INT
AS
BEGIN
DECLARE @capacidad_total INT;
DECLARE @mantenimientos_programados INT;
SELECT @capacidad_total = capacidad
FROM Taller
WHERE id_taller = @id_taller;
SELECT @mantenimientos_programados = COUNT(*)
FROM Mantenimiento
WHERE id_taller = @id_taller;
RETURN @capacidad_total - @mantenimientos_programados;
END;
GO
--Vistas
--Vista de Información de Vehículos en Venta
CREATE VIEW VistaVehiculosDisponibles AS
SELECT
v.id_vehiculo,
v.modelo,
v.marca,
v.año,
v.precio,
c.nombre_concesionario
FROM Vehiculo v
JOIN Concesionario c ON v.id_vehiculo = c.id_concesionario
WHERE v.id_vehiculo NOT IN (
SELECT id_vehiculo FROM Venta
);
GO
--Vista de Ventas por Cliente
CREATE VIEW VistaVentasPorCliente AS
SELECT
c.nombre AS nombre_cliente,
c.telefono,
v.id_venta,
ve.modelo AS vehiculo_comprado,
v.fecha AS fecha_compra,
v.pago_inicial + v.saldo_pendiente AS total_pagado
FROM Venta v
JOIN Cliente c ON v.id_cliente = c.id_cliente
JOIN Vehiculo ve ON v.id_vehiculo = ve.id_vehiculo;
GO
--Vista de Mantenimientos por Vehículo
CREATE VIEW VistaMantenimientosPorVehiculo AS
SELECT
v.id_vehiculo,
v.modelo,
m.tipo AS tipo_mantenimiento,
m.fecha,
t.ubicacion AS taller,
e.nombre AS empleado
FROM Mantenimiento m
JOIN Vehiculo v ON m.id_vehiculo = v.id_vehiculo
JOIN Taller t ON m.id_taller = t.id_taller
JOIN Empleado e ON m.id_empleado = e.id_empleado;
GO
--Procedimientos almacenados
--Registrar un nuevo cliente
CREATE PROCEDURE RegistrarCliente (
@nombre NVARCHAR(100),
@telefono NVARCHAR(20),
@direccion NVARCHAR(200),
@email NVARCHAR(100),
@RUC NVARCHAR(20),
@historial_compras TEXT,
@preferencias NVARCHAR(255)
)
AS
BEGIN
INSERT INTO Cliente (nombre, telefono, direccion, email, RUC, historial_compras,
preferencias)
VALUES (@nombre, @telefono, @direccion, @email, @RUC, @historial_compras,
@preferencias);
END;
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
