-- Calcular saldo pendiente de una venta
SELECT v.precio - dv.pago_inicial AS saldo_pendiente
FROM DetalleVenta dv
JOIN Vehiculo v ON dv.id_vehiculo = v.id_vehiculo
WHERE dv.id_venta = 12345; -- Reemplazar 12345 con el ID de la venta

-- Obtener el estado de un vehículo
SELECT estado
FROM Vehiculo
WHERE id_vehiculo = 123; -- Reemplazar 123 con el ID del vehículo

-- Verificar si un vehículo está asignado a un cliente
SELECT 1
FROM Vehiculo
WHERE id_cliente = 1212 -- Reemplazar 1212 con el ID del cliente
AND id_vehiculo = 1231; -- Reemplazar 1231 con el ID del vehículo

-- Calcular la comisión total de un empleado de ventas
SELECT SUM(ev.comisiones) AS comision_total
FROM EmpleadoVentas ev
JOIN Venta v ON v.id_empleado = ev.id_empleado
WHERE ev.id_empleado = 5555 -- Reemplazar 5555 con el ID del empleado
AND v.fecha BETWEEN '2024-01-01' AND '2024-12-31'; -- Reemplazar con el rango que se desea

-- Calcular el descuento promedio en ventas
SELECT AVG((v.precio - dv.pago_inicial) / v.precio * 100) AS descuento_promedio
FROM Vehiculo v
JOIN Venta dv ON v.id_vehiculo = dv.id_vehiculo;

-- Determinar la capacidad disponible en talleres
SELECT capacidad
FROM Taller
WHERE id_taller = 2222; -- Reemplazar 2222 con el ID del taller ??

SELECT COUNT(*) AS mantenimientos_programados
FROM Mantenimiento
WHERE id_taller = 2222; -- Reemplazar 2222 con el ID del taller???

SELECT capacidad - COUNT(*) AS capacidad_disponible
FROM Taller t
JOIN Mantenimiento m ON t.id_taller = m.id_taller
WHERE t.id_taller = 2222; -- Reemplazar 2222 con el ID del taller???


-- Verificar si un cliente ya existe
SELECT COUNT(*) > 0 AS cliente_existente
FROM Cliente
WHERE nombre = 'Juan Pérez' -- Reemplazar con el nombre del cliente
AND email = 'juan.perez@example.com'; -- Reemplazar con el email del cliente

-- Consulta para obtener la información de una venta específica
SELECT v.id_venta,
       v.fecha,
       e.nombre AS empleado_nombre,
       tc.tipo AS tipo_comprobante,
       dv.id_vehiculo,
       ve.precio AS precio_vehiculo,
       dv.pago_inicial,
       dv.saldo_pendiente,
       dv.id_cliente,
       c.nombre AS cliente_nombre
FROM Venta v
INNER JOIN Empleado e ON v.id_empleado = e.id_empleado
INNER JOIN Tipo_Comprobante tc ON v.id_tipoC = tc.id_tipoC
INNER JOIN DetalleVenta dv ON v.id_venta = dv.id_venta
INNER JOIN Vehiculo ve ON dv.id_vehiculo = ve.id_vehiculo
INNER JOIN Cliente c ON dv.id_cliente = c.id_cliente
WHERE v.id_venta = @id_venta;

-- Reporte de ventas mensuales
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
WHERE MONTH(v.fecha) = @mes 
  AND YEAR(v.fecha) = @anio;

-- Obtener ID de vehículo por modelo
SELECT id_vehiculo 
INTO id_vehiculo
FROM Vehiculo
WHERE modelo = p_modelo_vehiculo;

-- Obtener ID de cliente por nombre
SELECT id 
FROM Cliente 
WHERE nombre = p_nombre_cliente;

-- Obtener ID de empleado por nombre (en este caso, 'Carlos Gómez')
SELECT id 
FROM Empleado 
WHERE nombre = 'Carlos Gómez';

-- Consultar los usuarios y verificar la contraseña desencriptando en la comparación
DECLARE @input_contraseña NVARCHAR(50) = 'password123'; --(cambiar por contraseña)

SELECT nombreusuario, rol
FROM Usuarios
WHERE nombreusuario = 'usuario1' --(cambiar por nombre de usuario)
AND contraseña = HASHBYTES('SHA2_256', @input_contraseña);  -- Comparar la contraseña encriptada
