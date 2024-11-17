-- CURSOR PARA GENERAR UN REPORTE DE VENTAS
DECLARE @id_cliente INT, @nombre_cliente NVARCHAR(100), @telefono NVARCHAR(20);
DECLARE @id_venta INT, @fecha DATETIME, @total_pagado DECIMAL(18, 2);
DECLARE @id_vehiculo INT, @modelo NVARCHAR(100), @precio DECIMAL(18, 2);
DECLARE @metodo_pago NVARCHAR(50), @pago DECIMAL(18, 2);

-- Cursor del Nivel 1: Clientes
DECLARE cursor_clientes CURSOR FOR
SELECT id_cliente, nombre, telefono
FROM Cliente;

OPEN cursor_clientes;
FETCH NEXT FROM cursor_clientes INTO @id_cliente, @nombre_cliente, @telefono;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Cliente: ' + @nombre_cliente + ' | Teléfono: ' + @telefono;

    -- Cursor del Nivel 2: Ventas por cliente
    DECLARE cursor_ventas CURSOR FOR
    SELECT id_venta, fecha, (pago_inicial + saldo_pendiente) AS total_pagado
    FROM Venta
    WHERE id_cliente = @id_cliente;

    OPEN cursor_ventas;
    FETCH NEXT FROM cursor_ventas INTO @id_venta, @fecha, @total_pagado;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '    Venta ID: ' + CAST(@id_venta AS NVARCHAR) + ' | Fecha: ' + CAST(@fecha AS NVARCHAR) + ' | Total Pagado: ' + CAST(@total_pagado AS NVARCHAR);

        -- Cursor del Nivel 3: Vehículos en la venta
        DECLARE cursor_vehiculos CURSOR FOR
        SELECT v.id_vehiculo, dv.modelo, v.precio
        FROM Vehiculo v
        JOIN Detalle_Vehiculo dv ON v.id_vehiculo = dv.id_vehiculo
        JOIN DetalleVenta dv2 ON v.id_vehiculo = dv2.id_vehiculo
        WHERE dv2.id_venta = @id_venta;

        OPEN cursor_vehiculos;
        FETCH NEXT FROM cursor_vehiculos INTO @id_vehiculo, @modelo, @precio;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            PRINT '        Vehículo: ' + @modelo + ' | Precio: ' + CAST(@precio AS NVARCHAR);

            -- Cursor del Nivel 4: Métodos de pago utilizados
            DECLARE cursor_metodos_pago CURSOR FOR
            SELECT mp.tipo AS metodo_pago, dvp.pago
            FROM Metodo_Pago mp
            JOIN DetalleVenta dvp ON mp.id_metodo_pago = dvp.id_metodo_pago
            WHERE dvp.id_vehiculo = @id_vehiculo;

            OPEN cursor_metodos_pago;
            FETCH NEXT FROM cursor_metodos_pago INTO @metodo_pago, @pago;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                PRINT '            Método de Pago: ' + @metodo_pago + ' | Pago: ' + CAST(@pago AS NVARCHAR);
                FETCH NEXT FROM cursor_metodos_pago INTO @metodo_pago, @pago;
            END

            CLOSE cursor_metodos_pago;
            DEALLOCATE cursor_metodos_pago;

            FETCH NEXT FROM cursor_vehiculos INTO @id_vehiculo, @modelo, @precio;
        END

        CLOSE cursor_vehiculos;
        DEALLOCATE cursor_vehiculos;

        FETCH NEXT FROM cursor_ventas INTO @id_venta, @fecha, @total_pagado;
    END

    CLOSE cursor_ventas;
    DEALLOCATE cursor_ventas;

    FETCH NEXT FROM cursor_clientes INTO @id_cliente, @nombre_cliente, @telefono;
END

CLOSE cursor_clientes;
DEALLOCATE cursor_clientes;


-- Capacidad utilizada por taller

DECLARE @id_taller INT, @nombre_taller NVARCHAR(100), @capacidad_total INT;
DECLARE @tipo_mantenimiento NVARCHAR(100);
DECLARE @id_vehiculo INT, @modelo NVARCHAR(100);
DECLARE @nombre_empleado NVARCHAR(100), @fecha_mantenimiento DATETIME;

-- Cursor del Nivel 1: Talleres
DECLARE cursor_talleres CURSOR FOR
SELECT id_taller, nombre, capacidad
FROM Taller;

OPEN cursor_talleres;
FETCH NEXT FROM cursor_talleres INTO @id_taller, @nombre_taller, @capacidad_total;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Taller: ' + @nombre_taller + ' | Capacidad Total: ' + CAST(@capacidad_total AS NVARCHAR);

    -- Cursor del Nivel 2: Tipos de mantenimiento en cada taller
    DECLARE cursor_tipos_mantenimiento CURSOR FOR
    SELECT DISTINCT tipo
    FROM Mantenimiento
    WHERE id_taller = @id_taller;

    OPEN cursor_tipos_mantenimiento;
    FETCH NEXT FROM cursor_tipos_mantenimiento INTO @tipo_mantenimiento;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '    Tipo de Mantenimiento: ' + @tipo_mantenimiento;

        -- Cursor del Nivel 3: Vehículos atendidos para este tipo de mantenimiento
        DECLARE cursor_vehiculos CURSOR FOR
        SELECT DISTINCT v.id_vehiculo, v.modelo
        FROM Vehiculo v
        JOIN Mantenimiento m ON v.id_vehiculo = m.id_vehiculo
        WHERE m.id_taller = @id_taller AND m.tipo = @tipo_mantenimiento;

        OPEN cursor_vehiculos;
        FETCH NEXT FROM cursor_vehiculos INTO @id_vehiculo, @modelo;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            PRINT '        Vehículo: ' + @modelo + ' (ID: ' + CAST(@id_vehiculo AS NVARCHAR) + ')';

            -- Cursor del Nivel 4: Empleados que realizaron el mantenimiento
            DECLARE cursor_empleados CURSOR FOR
            SELECT e.nombre, m.fecha
            FROM Empleado e
            JOIN Mantenimiento m ON e.id_empleado = m.id_empleado
            WHERE m.id_taller = @id_taller AND m.tipo = @tipo_mantenimiento AND m.id_vehiculo = @id_vehiculo;

            OPEN cursor_empleados;
            FETCH NEXT FROM cursor_empleados INTO @nombre_empleado, @fecha_mantenimiento;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                PRINT '            Empleado: ' + @nombre_empleado + ' | Fecha: ' + CAST(@fecha_mantenimiento AS NVARCHAR);
                FETCH NEXT FROM cursor_empleados INTO @nombre_empleado, @fecha_mantenimiento;
            END

            CLOSE cursor_empleados;
            DEALLOCATE cursor_empleados;

            FETCH NEXT FROM cursor_vehiculos INTO @id_vehiculo, @modelo;
        END

        CLOSE cursor_vehiculos;
        DEALLOCATE cursor_vehiculos;

        FETCH NEXT FROM cursor_tipos_mantenimiento INTO @tipo_mantenimiento;
    END

    CLOSE cursor_tipos_mantenimiento;
    DEALLOCATE cursor_tipos_mantenimiento;

    FETCH NEXT FROM cursor_talleres INTO @id_taller, @nombre_taller, @capacidad_total;
END

CLOSE cursor_talleres;
DEALLOCATE cursor_talleres;
