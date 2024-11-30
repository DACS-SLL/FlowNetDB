--Vistas
CREATE VIEW InformacionCliente
AS
SELECT 
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.telefono,
    c.RUC,
    c.dni AS dni_cliente,
    i.direccion,
    i.email,
    i.historial_compras,
    p.id_preferencia,
    m.tipo AS marca_preferencia,
    mp.tipo AS metodo_pago_preferencia,
    ci.nombre AS ciudad_cliente
FROM Cliente c
JOIN InformCliente i ON c.id_cliente = i.id_cliente
JOIN Preferencias p ON i.id_preferencia = p.id_preferencia
JOIN Marca m ON p.id_marca = m.id_marca
JOIN Metodo_Pago mp ON p.id_metodopago = mp.id_metodo_pago
JOIN Man_Ciudad ci ON i.id_ciudad = ci.id_ciudad;
GO

CREATE VIEW VentasDetalle
AS
SELECT 
    v.id_venta,
    v.fecha AS fecha_venta,
    e.nombre AS nombre_empleado,
    tc.tipo AS tipo_comprobante,
    dv.id_vehiculo,
    ve.precio,
    dv.pago_inicial,
    dv.saldo_pendiente,
    c.nombre AS nombre_cliente,
    ve.estado AS estado_vehiculo
FROM Venta v
JOIN Empleado e ON v.id_empleado = e.id_empleado
JOIN Tipo_Comprobante tc ON v.id_tipoC = tc.id_tipoC
JOIN DetalleVenta dv ON v.id_venta = dv.id_venta
JOIN Vehiculo ve ON dv.id_vehiculo = ve.id_vehiculo
JOIN Cliente c ON dv.id_cliente = c.id_cliente;
GO
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
