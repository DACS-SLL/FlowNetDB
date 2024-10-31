--1. Facturación mensual total (por mes actual) por método de pago
SELECT 
    MONTH(v.fecha) AS mes,
    YEAR(v.fecha) AS año,
    v.metodo_pago,
    SUM(v.pago_inicial + v.saldo_pendiente) AS total_facturado
FROM 
    Venta v
GROUP BY YEAR(v.fecha), MONTH(v.fecha), v.metodo_pago
ORDER BY año DESC, mes DESC, total_facturado DESC;

--2. Análisis de ventas y mantenimientos por vehículo, ordenando de manera ascendente
--resumiendo los mantenimientos e ingresos

SELECT 
    veh.marca,
    veh.modelo,
    veh.año,
    COUNT(v.id_venta) AS total_ventas,
    COUNT(m.id_mantenimiento) AS total_mantenimientos,
    SUM(v.pago_inicial + v.saldo_pendiente) AS ingresos_por_vehiculo,
    SUM(CASE WHEN m.tipo = 'Correctivo' THEN 1 ELSE 0 END) AS correctivos,
    SUM(CASE WHEN m.tipo = 'Preventivo' THEN 1 ELSE 0 END) AS preventivos
FROM 
    Vehiculo veh
LEFT JOIN Venta v ON veh.id_vehiculo = v.id_vehiculo
LEFT JOIN Mantenimiento m ON veh.id_vehiculo = m.id_vehiculo
GROUP BY veh.marca, veh.modelo, veh.año
ORDER BY ingresos_por_vehiculo ASC;

--3. Inventario de repuestos por estado y proveedor 

SELECT 
    r.nombre AS nombre_repuesto,
    r.marca,
    r.modelo,
    r.estado,
    COUNT(r.id_repuesto) AS cantidad,
    MAX(r.fecha_de_compra) AS ultima_compra
FROM 
    Repuestos r
GROUP BY r.nombre, r.marca, r.modelo, r.estado
ORDER BY cantidad DESC;

--4. Empleados disponibles y sus asignaciones de mantenimiento y ventas (mostrando con 0 
--si estan disponible)

SELECT 
    e.nombre,
    e.dni,
    COUNT(m.id_mantenimiento) AS mantenimientos_asignados,
    COUNT(v.id_venta) AS ventas_asignadas
FROM 
    Empleado e
LEFT JOIN Mantenimiento m ON e.id_empleado = m.id_empleado
LEFT JOIN Venta v ON e.id_empleado = v.id_empleado
WHERE e.disponibilidad = 1
GROUP BY e.nombre, e.dni
ORDER BY mantenimientos_asignados DESC, ventas_asignadas DESC;

--5. Correctivo contra preventivo para la fecha actual

SELECT 
    MONTH(m.fecha) AS mes,
    YEAR(m.fecha) AS año,
    SUM(CASE WHEN m.tipo = 'Preventivo' THEN 1 ELSE 0 END) AS mantenimientos_preventivos,
    SUM(CASE WHEN m.tipo = 'Correctivo' THEN 1 ELSE 0 END) AS mantenimientos_correctivos
FROM 
    Mantenimiento m
GROUP BY YEAR(m.fecha), MONTH(m.fecha)
ORDER BY año DESC, mes DESC;

--6. Resumen completo de ventas, clientes, y vehículos

SELECT 
    v.id_venta,
    c.nombre AS nombre_cliente,
    c.telefono,
    c.direccion,
    c.email,
    c.RUC,
    veh.marca,
    veh.modelo,
    veh.año,
    veh.precio,
    v.fecha,
    v.metodo_pago,
    v.pago_inicial,
    v.saldo_pendiente,
    v.tipo_comprobante,
    ce.tipo AS tipo_comprobante_electronico,
    ce.formatoXML AS XML_comprobante_electronico,
    ce.fecha_emision,
    ce.impuestos,
    d.id_detalleventa,
    d.re_registro
FROM 
    Venta v
JOIN Cliente c ON v.id_cliente = c.id_cliente
JOIN Vehiculo veh ON v.id_vehiculo = veh.id_vehiculo
LEFT JOIN ComprobanteElectronico ce ON v.id_venta = ce.id_venta
LEFT JOIN DetalleVenta d ON v.id_venta = d.id_venta;

--7. Historial de mantenimiento de vehículos por cliente y empleado

SELECT 
    e.nombre AS nombre_empleado,
    c.nombre AS nombre_cliente,
    COUNT(v.id_venta) AS total_ventas,
    SUM(v.pago_inicial) AS total_pagado,
    SUM(v.saldo_pendiente) AS saldo_pendiente_total,
    MAX(v.fecha) AS ultima_venta
FROM 
    Venta v
LEFT JOIN Empleado e ON v.id_empleado = e.id_empleado
LEFT JOIN Cliente c ON v.id_cliente = c.id_cliente
GROUP BY e.nombre, c.nombre
HAVING SUM(v.pago_inicial) > 0
ORDER BY total_ventas DESC;

