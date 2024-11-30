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
CREATE PROCEDURE InsertarVenta(
    @id_empleado INT,
    @fecha DATETIME,
    @id_tipoC INT,
    @id_cliente INT,
    @id_vehiculo INT,
    @pago_inicial DECIMAL(18, 2),
    @id_metodo_pago INT
)
AS
BEGIN
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
        INSERT INTO DetalleVenta (id_venta, id_vehiculo, id_metodo_pago, pago_inicial, id_cliente, re_registro)
        VALUES (@id_venta, @id_vehiculo, @id_metodo_pago, @pago_inicial, @id_cliente, 0);

        -- Actualizar el estado del vehículo a no disponible (estado = 0)
        UPDATE Vehiculo
        SET estado = 0 -- No disponible
        WHERE id_vehiculo = @id_vehiculo;

		UPDATE DetalleVenta
		SET saldo_pendiente = v.precio - @pago_inicial
		FROM DetalleVenta d
		JOIN Vehiculo v ON d.id_vehiculo = v.id_vehiculo
		WHERE d.id_venta = @id_venta;


        -- Si todo ha ido bien, confirmamos la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, hacemos un rollback
        ROLLBACK TRANSACTION;
        -- Opcionalmente, lanzar el error para capturarlo en la capa de aplicación
        THROW;
    END CATCH
END;
GO

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

        -- Restaurar el estado del vehículo a disponible (estado = 1)
        -- Para hacerlo, primero necesitamos obtener el id_vehiculo asociado
        DECLARE @id_vehiculo INT;
        
        SELECT @id_vehiculo = id_vehiculo
        FROM DetalleVenta
        WHERE id_venta = @id_venta;

        -- Restauramos el vehículo a estado disponible
        UPDATE Vehiculo
        SET estado = 1  -- Disponible
        WHERE id_vehiculo = @id_vehiculo;

        -- Eliminar la venta de la tabla Venta
        DELETE FROM Venta
        WHERE id_venta = @id_venta;

        -- Si todo ha ido bien, confirmamos la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, hacemos un rollback
        ROLLBACK TRANSACTION;
        -- Opcionalmente, lanzar el error para capturarlo en la capa de aplicación
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
v.pago_inicial + v.saldo_pendiente AS total_pagado,
v.metodo_pago
FROM Venta v
JOIN Cliente c ON v.id_cliente = c.id_cliente
JOIN Empleado e ON v.id_empleado = e.id_empleado
WHERE MONTH(v.fecha) = @mes AND YEAR(v.fecha) = @anio;
END;
GO

-- AgreaciOn de %ROWTYPE, %TYPE
  
CREATE OR REPLACE PROCEDURE insertar_cliente_nuevo IS
    nuevo_cliente Cliente%ROWTYPE;  
BEGIN
    -- Asignar valores a los campos del cliente nuevo
    nuevo_cliente.nombre := 'Carlos Gómez';
    nuevo_cliente.telefono := '987654321';
    nuevo_cliente.direccion := 'Calle Ejemplo 123';
    nuevo_cliente.email := 'carlos.gomez@mail.com';
    nuevo_cliente.historia_compras := NULL;  

    INSERT INTO Cliente VALUES nuevo_cliente;
END;


CREATE OR REPLACE PROCEDURE registrar_venta_detallada(
    p_nombre_cliente Cliente.nombre%TYPE,  
    p_modelo_vehiculo Vehiculo.modelo%TYPE,  
    p_precio_detalle Venta.precio%TYPE  
) IS
    nueva_venta Venta%ROWTYPE;   
    id_vehiculo Vehiculo.id_vehiculo%TYPE;  
BEGIN
    SELECT id_vehiculo INTO id_vehiculo
    FROM Vehiculo
    WHERE modelo = p_modelo_vehiculo;

    nueva_venta.id_cliente := (SELECT id FROM Cliente WHERE nombre = p_nombre_cliente);
    nueva_venta.id_empleado := (SELECT id FROM Empleado WHERE nombre = 'Carlos Gómez');
    nueva_venta.tipo_comprobante := 'Factura';
    nueva_venta.fecha := SYSDATE;
    nueva_venta.pago_inicial := 3000.00;
    nueva_venta.metodo_pago := 'Efectivo';

    INSERT INTO Venta VALUES nueva_venta;

    INSERT INTO Detalle_Venta (id_venta, id_vehiculo, precio)
    VALUES (
        nueva_venta.id_venta,
        id_vehiculo,
        p_precio_detalle
    );
END;
