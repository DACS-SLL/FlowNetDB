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