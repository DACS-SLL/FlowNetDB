--1. Proceso Almacenado: Calcular la Comisión Total de un Empleado de Ventas:
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
--2. Proceso Almacenado: Calcular el Descuento Promedio en Ventas
CREATE PROCEDURE CalcularDescuentoPromedio (
    OUT descuento_promedio DECIMAL(5, 2)
)
BEGIN
    SELECT AVG(descuento)
    INTO descuento_promedio
    FROM Ventas;
END;
--3. Proceso Almacenado: Determinar la Capacidad Disponible en Talleres (Corregir)
CREATE PROCEDURE DeterminarCapacidadDisponible (
    OUT capacidad_disponible INT
)
BEGIN
    SELECT (capacidad_maxima - COUNT(*)) AS capacidad_disponible
    FROM Talleres
    LEFT JOIN Reservas ON Talleres.id_taller = Reservas.id_taller
    WHERE Reservas.fecha_fin IS NULL; 
END;

--Registrar un Nuevo Cliente
CREATE PROCEDURE RegistrarNuevoCliente (
    IN nombre_cliente VARCHAR(50),
    IN apellido_cliente VARCHAR(50),
    IN telefono_cliente VARCHAR(15),
    IN correo_cliente VARCHAR(50)
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

    -- Insertar la venta
    INSERT INTO Ventas (id_cliente, id_vehiculo, fecha_venta, precio)
    VALUES (cliente_id, vehiculo_id, NOW(), precio);

    -- Obtener el último ID de venta insertado
    SET nuevo_id_venta = LAST_INSERT_ID();

    -- Generar el comprobante electrónico
    INSERT INTO Comprobantes (id_venta, tipo, fecha_emision)
    VALUES (nuevo_id_venta, tipo_comprobante, NOW());
END;

-- Generar un Reporte de Ventas Mensuales
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

--Vistas
--4. Vista de Información de Vehículos en Venta
CREATE VIEW Vista_VehiculosEnVenta AS
SELECT 
    Vehiculos.id_vehiculo,
    Vehiculos.marca,
    Vehiculos.modelo,
    Vehiculos.anio,
    Vehiculos.precio,
    Vehiculos.color,
    Vehiculos.tipo_combustible,
    Vehiculos.estado
FROM 
    Vehiculos
WHERE 
    Vehiculos.estado = 'En Venta';

--5. Vista de Ventas por Cliente
CREATE VIEW Vista_VentasPorCliente AS
SELECT 
    Clientes.id_cliente,
    Clientes.nombre,
    Clientes.apellido,
    Ventas.fecha_venta,
    Vehiculos.marca,
    Vehiculos.modelo,
    Vehiculos.precio AS monto_venta
FROM 
    Ventas
JOIN 
    Clientes ON Ventas.id_cliente = Clientes.id_cliente
JOIN 
    Vehiculos ON Ventas.id_vehiculo = Vehiculos.id_vehiculo;
 
--6. Vista de Mantenimientos por Vehículo
CREATE VIEW Vista_MantenimientosPorVehiculo AS
SELECT 
    Vehiculos.id_vehiculo,
    Vehiculos.marca,
    Vehiculos.modelo,
    Mantenimientos.fecha_mantenimiento,
    Mantenimientos.tipo_servicio,
    Talleres.nombre AS taller
FROM 
    Mantenimientos
JOIN 
    Vehiculos ON Mantenimientos.id_vehiculo = Vehiculos.id_vehiculo
JOIN 
    Talleres ON Mantenimientos.id_taller = Talleres.id_taller;


