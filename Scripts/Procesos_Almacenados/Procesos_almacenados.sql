--Calcular la Comisión Total de un Empleado de Ventas
CREATE PROCEDURE CalcularComisionTotalEmpleado (
    IN empleado_id INT,
    OUT comision_total DECIMAL(10, 2)
)
BEGIN
    SELECT SUM(comision) 
    INTO comision_total
    FROM Ventas
    WHERE id_empleado = empleado_id;
END;
-- Calcular el Descuento Promedio en Ventas
CREATE PROCEDURE CalcularDescuentoPromedio (
    OUT descuento_promedio DECIMAL(5, 2)
)
BEGIN
    SELECT AVG(descuento) 
    INTO descuento_promedio
    FROM Ventas;
END;
--Determinar la Capacidad Disponible en Talleres
CREATE PROCEDURE DeterminarCapacidadDisponible (
    OUT capacidad_disponible INT
)
BEGIN
    SELECT (T.capacidad_maxima - COUNT(R.id_reserva)) AS capacidad_disponible
    INTO capacidad_disponible
    FROM Talleres T
    LEFT JOIN Reservas R ON T.id_taller = R.id_taller
    WHERE R.fecha_fin IS NULL;
END;
--Registrar un Nuevo Cliente

CREATE PROCEDURE RegistrarNuevoCliente (
    IN nombre_cliente Clientes.nombre%TYPE,
    IN apellido_cliente Clientes.apellido%TYPE,
    IN telefono_cliente Clientes.telefono%TYPE,
    IN correo_cliente Clientes.correo%TYPE
)
BEGIN
    INSERT INTO Clientes (nombre, apellido, telefono, correo)
    VALUES (nombre_cliente, apellido_cliente, telefono_cliente, correo_cliente);
END;

--Registrar una Venta con Comprobante Electrónico
CREATE PROCEDURE RegistrarVentaConComprobante (
    IN cliente_id INT,
    IN vehiculo_id INT,
    IN precio DECIMAL(10, 2),
    IN tipo_comprobante VARCHAR(20)
)
BEGIN
    DECLARE nuevo_id_venta INT;

    INSERT INTO Ventas (id_cliente, id_vehiculo, fecha_venta, precio)
    VALUES (cliente_id, vehiculo_id, NOW(), precio);

    SET nuevo_id_venta = LAST_INSERT_ID();

    INSERT INTO Comprobantes (id_venta, tipo, fecha_emision)
    VALUES (nuevo_id_venta, tipo_comprobante, NOW());
END;
--Generar un Reporte de Ventas Mensuales
CREATE PROCEDURE GenerarReporteVentasMensuales (
    IN mes INT,
    IN anio INT,
    OUT total_ventas DECIMAL(10, 2)
)
BEGIN
    SELECT SUM(precio) 
    INTO total_ventas
    FROM Ventas
    WHERE MONTH(fecha_venta) = mes AND YEAR(fecha_venta) = anio;
END;

--Vista de Información de Vehículos en Venta
CREATE VIEW Vista_VehiculosEnVenta AS
SELECT 
    id_vehiculo,
    marca,
    modelo,
    anio,
    precio,
    color,
    tipo_combustible,
    estado
FROM Vehiculos
WHERE estado = 'En Venta';

--Vista de Ventas por Cliente
CREATE VIEW Vista_VentasPorCliente AS
SELECT 
    C.id_cliente,
    C.nombre,
    C.apellido,
    V.fecha_venta,
    Ve.marca,
    Ve.modelo,
    V.precio AS monto_venta
FROM Ventas V
JOIN Clientes C ON V.id_cliente = C.id_cliente
JOIN Vehiculos Ve ON V.id_vehiculo = Ve.id_vehiculo;
--Vista de Mantenimientos por Vehículo
CREATE VIEW Vista_MantenimientosPorVehiculo AS
SELECT 
    Ve.id_vehiculo,
    Ve.marca,
    Ve.modelo,
    M.fecha_mantenimiento,
    M.tipo_servicio,
    T.nombre AS taller
FROM Mantenimientos M
JOIN Vehiculos Ve ON M.id_vehiculo = Ve.id_vehiculo
JOIN Talleres T ON M.id_taller = T.id_taller;
