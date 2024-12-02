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
-- Procedimiento InsertarVenta con GETDATE() directamente

-- Procedimiento InsertarVenta con GETDATE() directamente
CREATE PROCEDURE InsertarVenta (
    @id_empleado INT,
    @fecha DATETIME = NULL,  -- Se permite un valor NULL para la fecha
    @id_tipoC INT,
    @id_cliente INT,
    @id_vehiculo INT,
    @pago_inicial DECIMAL(18, 2),
    @id_metodo_pago INT
)
AS
BEGIN
    -- Si no se pasa la fecha, usar GETDATE() por defecto
    IF @fecha IS NULL
    BEGIN
        SET @fecha = GETDATE();  -- Asignar la fecha y hora actuales
    END

    -- Variable para almacenar el ID de la nueva venta
    DECLARE @id_venta INT;

    -- Comienza la transacción
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Insertar una nueva venta en la tabla Venta
        INSERT INTO Venta (id_empleado, fecha, id_tipoC)
        VALUES (@id_empleado, @fecha, @id_tipoC);

        -- Obtener el ID de la nueva venta
        SET @id_venta = SCOPE_IDENTITY();

        -- Insertar detalles de la venta en la tabla DetalleVenta
        INSERT INTO DetalleVenta (id_venta, id_vehiculo, id_metodo_pago, pago_inicial, saldo_pendiente, id_cliente, re_registro)
        VALUES (@id_venta, @id_vehiculo, @id_metodo_pago, @pago_inicial, 0, @id_cliente, 0);

        -- Actualizar el estado del vehículo a no disponible (estado = 0)
        UPDATE Vehiculo
        SET estado = 0  -- No disponible
        WHERE id_vehiculo = @id_vehiculo;

        -- Mensaje de confirmación de la venta registrada
        PRINT 'Venta registrada exitosamente.';

        -- Si todo ha ido bien, confirmamos la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, hacemos un rollback
        ROLLBACK TRANSACTION;
        -- Mensaje de error
        PRINT 'Error: No se pudo registrar la venta.';
        -- Opcionalmente, lanzar el error para capturarlo en la capa de aplicación
        THROW;
    END CATCH
END;
GO
DROP PROCEDURE IF EXISTS EliminarVenta;

CREATE PROCEDURE EliminarVenta(
    @id_venta INT
)
AS
BEGIN
    -- Comienza la transacción
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Eliminar los detalles de la venta en la tabla DetalleVenta
        DELETE FROM DetalleVenta
        WHERE id_venta = @id_venta;

        -- Obtener el id_vehiculo asociado a la venta eliminada
        DECLARE @id_vehiculo INT;
        SELECT @id_vehiculo = id_vehiculo
        FROM DetalleVenta
        WHERE id_venta = @id_venta;

        -- Restaurar el estado del vehículo a disponible (estado = 1)
        UPDATE Vehiculo
        SET estado = 1  -- Disponible
        WHERE id_vehiculo = @id_vehiculo;

        -- Eliminar la venta de la tabla Venta
        DELETE FROM Venta
        WHERE id_venta = @id_venta;

        -- Si todo ha ido bien, confirmamos la transacción
        COMMIT TRANSACTION;

        -- Imprimir mensaje indicando que la venta fue eliminada
        PRINT 'Venta eliminada con éxito. ID Venta: ' + CAST(@id_venta AS NVARCHAR(10));
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, hacemos un rollback
        ROLLBACK TRANSACTION;
        -- Opcionalmente, lanzar el error para capturarlo en la capa de aplicación
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE ConsultarVenta(
    @id_venta INT
)
AS
BEGIN
    -- Consulta para obtener la información de la venta
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
END;
GO

CREATE PROCEDURE RegistrarVehiculo(
    @id_cliente INT,              
    @precio DECIMAL(18, 2),        
    @año INT,                      
    @id_marca INT,                 
    @modelo NVARCHAR(100),         
    @potencia NVARCHAR(50),        
    @kms DECIMAL(10, 2)           
)
AS
BEGIN
    -- Comienza la transacción
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Insertar el nuevo vehículo en la tabla Vehiculo
        INSERT INTO Vehiculo (id_cliente, precio)
        VALUES (@id_cliente, @precio);

        -- Obtener el ID del vehículo recién insertado
        DECLARE @id_vehiculo INT;
        SET @id_vehiculo = SCOPE_IDENTITY();

        -- Insertar los detalles del vehículo en la tabla Detalle_Vehiculo
        INSERT INTO Detalle_Vehiculo (id_vehiculo, año, id_marca, modelo, potencia, kms)
        VALUES (@id_vehiculo, @año, @id_marca, @modelo, @potencia, @kms);

        -- Confirmar la transacción si todo es exitoso
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, hacer un rollback
        ROLLBACK TRANSACTION;
        -- Lanzar el error para su captura en la capa de la aplicación
        THROW;
    END CATCH
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
        dv.pago_inicial + dv.saldo_pendiente AS total_pagado,
        mp.tipo -- Aquí se hace el JOIN con la tabla Metodo_Pago para obtener el nombre del metodo de pago
    FROM Venta v
    JOIN DetalleVenta dv ON v.id_venta = dv.id_venta -- Unimos con DetalleVenta para obtener el pago inicial y saldo pendiente
    JOIN Cliente c ON dv.id_cliente = c.id_cliente
    JOIN Empleado e ON v.id_empleado = e.id_empleado
    JOIN Metodo_Pago mp ON dv.id_metodo_pago = mp.id_metodo_pago -- Unimos con Metodo_Pago para obtener el metodo de pago
    WHERE MONTH(v.fecha) = @mes AND YEAR(v.fecha) = @anio;
END;
GO


-- AgreaciOn de %ROWTYPE, %TYPE
  
CREATE PROCEDURE insertar_cliente_nuevo
AS
BEGIN
    -- Declarar una variable tipo tabla para emular una fila
    DECLARE @nuevo_cliente TABLE (
        nombre NVARCHAR(100),
        telefono NVARCHAR(20),
        RUC NVARCHAR(20),
        dni NVARCHAR(15)
    );

    -- Insertar los datos del nuevo cliente en la tabla temporal
    INSERT INTO @nuevo_cliente (nombre, telefono, RUC, dni)
    VALUES ('Carlos Gómez', '987654321', '12345678910', '12345678');

    -- Verificar si el RUC o el DNI ya están registrados
    IF EXISTS (SELECT 1 FROM Cliente WHERE RUC = (SELECT RUC FROM @nuevo_cliente))
    BEGIN
        PRINT 'Error: El RUC ya está registrado.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Cliente WHERE dni = (SELECT dni FROM @nuevo_cliente))
    BEGIN
        PRINT 'Error: El DNI ya está registrado.';
        RETURN;
    END

    -- Insertar el nuevo cliente en la tabla Cliente desde la tabla temporal
    INSERT INTO Cliente (nombre, telefono, RUC, dni)
    SELECT nombre, telefono, RUC, dni FROM @nuevo_cliente;

    PRINT 'Cliente registrado exitosamente.';
END;
GO




CREATE PROCEDURE registrar_venta_detallada
    @p_nombre_cliente NVARCHAR(100),   -- Nombre del cliente
    @p_modelo_vehiculo NVARCHAR(100),  -- Modelo del vehículo
    @p_precio_detalle DECIMAL(18,2)    -- Precio del detalle
AS
BEGIN
    DECLARE @id_vehiculo INT;           -- Variable para almacenar el id del vehículo
    DECLARE @id_cliente INT;            -- Variable para almacenar el id del cliente
    DECLARE @id_empleado INT = 1;       -- Asumiendo que el empleado tiene id 1 (Carlos Gómez)
    DECLARE @id_tipoC INT = 1;          -- Asumiendo que el tipo de comprobante es 1 (Factura)
    DECLARE @id_venta INT;              -- Variable para almacenar el id de la nueva venta
    DECLARE @fecha DATETIME = GETDATE(); -- Fecha de la venta (actual)

    -- Obtener el id del vehículo según el modelo
    SELECT @id_vehiculo = id_vehiculo
    FROM Detalle_Vehiculo
    WHERE modelo = @p_modelo_vehiculo;

    -- Verificar que el cliente existe
    SELECT @id_cliente = id_cliente
    FROM Cliente
    WHERE nombre = @p_nombre_cliente;

    IF @id_cliente IS NULL
    BEGIN
        PRINT 'Error: Cliente no encontrado.';
        RETURN;
    END

    -- Insertar una nueva venta
    INSERT INTO Venta (id_empleado, fecha, id_tipoC)
    VALUES (@id_empleado, @fecha, @id_tipoC);

    -- Obtener el id de la nueva venta
    SET @id_venta = SCOPE_IDENTITY();

    -- Insertar los detalles de la venta en DetalleVenta
    INSERT INTO DetalleVenta (id_venta, id_vehiculo, id_metodo_pago, pago_inicial, saldo_pendiente, id_cliente, re_registro)
    VALUES (@id_venta, @id_vehiculo, 1, 3000.00, @p_precio_detalle - 3000.00, @id_cliente, 0);

    PRINT 'Venta registrada exitosamente.';
END;
GO
