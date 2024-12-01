--1. Cursor para Reporte de Empleados Trabajando
USE FlowNet;

DECLARE @id_empleado INT, @nombre NVARCHAR(50), @disponibilidad NVARCHAR(50);

DECLARE cursor_empleados CURSOR FOR
SELECT id_empleado, nombre, disponibilidad
FROM Empleado
WHERE disponibilidad = 1; -- 1: Disponible para trabajar

OPEN cursor_empleados;
FETCH NEXT FROM cursor_empleados INTO @id_empleado, @nombre, @disponibilidad;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Empleado ID: ' + CAST(@id_empleado AS VARCHAR(10)) + 
          ', Nombre: ' + @nombre + 
          ', Disponibilidad: ' + @disponibilidad;

    FETCH NEXT FROM cursor_empleados INTO @id_empleado, @nombre, @disponibilidad;
END;

CLOSE cursor_empleados;
DEALLOCATE cursor_empleados;



--2.Cursor para Reporte de Vehículos Vendidos

USE FlowNet;

DECLARE @id_vehiculo INT, @modelo NVARCHAR(50), @precio DECIMAL(18, 2);

DECLARE cursor_vehiculos_vendidos CURSOR FOR
SELECT v.id_vehiculo, dv.modelo, v.precio
FROM Vehiculo v
JOIN Detalle_Vehiculo dv ON v.id_vehiculo = dv.id_vehiculo
WHERE v.estado = 1; -- Estado 1: Vehículo vendido

OPEN cursor_vehiculos_vendidos;
FETCH NEXT FROM cursor_vehiculos_vendidos INTO @id_vehiculo, @modelo, @precio;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Vehículo ID: ' + CAST(@id_vehiculo AS VARCHAR(10)) + 
          ', Modelo: ' + @modelo + 
          ', Precio: ' + CAST(@precio AS VARCHAR(10));

    FETCH NEXT FROM cursor_vehiculos_vendidos INTO @id_vehiculo, @modelo, @precio;
END;

CLOSE cursor_vehiculos_vendidos;
DEALLOCATE cursor_vehiculos_vendidos;



--3.Cursor para Reporte de Vehículos en Stock

USE FlowNet;

DECLARE @id_vehiculo INT, @modelo NVARCHAR(50), @precio DECIMAL(18, 2);

DECLARE cursor_vehiculos_stock CURSOR FOR
SELECT v.id_vehiculo, dv.modelo, v.precio
FROM Vehiculo v
JOIN Detalle_Vehiculo dv ON v.id_vehiculo = dv.id_vehiculo
WHERE v.estado = 0; -- Estado 0: Vehículo en stock

OPEN cursor_vehiculos_stock;
FETCH NEXT FROM cursor_vehiculos_stock INTO @id_vehiculo, @modelo, @precio;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Vehículo ID: ' + CAST(@id_vehiculo AS VARCHAR(10)) + 
          ', Modelo: ' + @modelo + 
          ', Precio: ' + CAST(@precio AS VARCHAR(10));

    FETCH NEXT FROM cursor_vehiculos_stock INTO @id_vehiculo, @modelo, @precio;
END;

CLOSE cursor_vehiculos_stock;
DEALLOCATE cursor_vehiculos_stock;





--4.Cursor para Reporte de Clientes Activos
USE FlowNet;

DECLARE @id_cliente INT, @nombre NVARCHAR(50), @historial_compras NVARCHAR(MAX);

DECLARE cursor_clientes_activos CURSOR FOR
SELECT c.id_cliente, c.nombre, CAST(ic.historial_compras AS NVARCHAR(MAX)) AS historial_compras
FROM Cliente c
JOIN InformCliente ic ON c.id_cliente = ic.id_cliente
WHERE CAST(ic.historial_compras AS NVARCHAR(MAX)) <> 'Sin historial'; -- Clientes con historial de compras

OPEN cursor_clientes_activos;
FETCH NEXT FROM cursor_clientes_activos INTO @id_cliente, @nombre, @historial_compras;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Cliente ID: ' + CAST(@id_cliente AS VARCHAR(10)) + 
          ', Nombre: ' + @nombre + 
          ', Historial de Compras: ' + @historial_compras;

    FETCH NEXT FROM cursor_clientes_activos INTO @id_cliente, @nombre, @historial_compras;
END;

CLOSE cursor_clientes_activos;
DEALLOCATE cursor_clientes_activos;





--5.Cursor para listar vehículos según su estado
-- Cursor principal para recorrer los estados
DECLARE cursor_estados CURSOR FOR
SELECT DISTINCT estado
FROM Vehiculo;

DECLARE @estado BIT;

OPEN cursor_estados;
FETCH NEXT FROM cursor_estados INTO @estado;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @estado = 1
        PRINT 'Vehículos vendidos:';
    ELSE
        PRINT 'Vehículos en stock:';
    
    -- Cursor secundario para listar vehículos según el estado actual
    DECLARE cursor_vehiculos CURSOR FOR
    SELECT id_vehiculo, id_cliente, precio
    FROM Vehiculo
    WHERE estado = @estado;
    
    DECLARE @id_vehiculo INT;
    DECLARE @id_cliente INT;
    DECLARE @precio DECIMAL(18, 2);
    
    OPEN cursor_vehiculos;
    FETCH NEXT FROM cursor_vehiculos INTO @id_vehiculo, @id_cliente, @precio;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '  Vehículo ID: ' + CAST(@id_vehiculo AS VARCHAR) + 
              ', Cliente ID: ' + ISNULL(CAST(@id_cliente AS VARCHAR), 'N/A') + 
              ', Precio: ' + CAST(@precio AS VARCHAR);
        FETCH NEXT FROM cursor_vehiculos INTO @id_vehiculo, @id_cliente, @precio;
    END;
    
    CLOSE cursor_vehiculos;
    DEALLOCATE cursor_vehiculos;
    
    FETCH NEXT FROM cursor_estados INTO @estado;
END;

CLOSE cursor_estados;
DEALLOCATE cursor_estados;

