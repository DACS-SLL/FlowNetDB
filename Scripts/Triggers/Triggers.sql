USE FlowNet;
GO
-- Trigger 1: Verificar existencia de RUC antes de insertar un cliente
-- Este trigger se ejecuta antes de insertar un cliente, verificando si el RUC ya existe en la base de datos
CREATE TRIGGER VerificarRUC
ON [dbo].[Cliente]
AFTER INSERT
AS
BEGIN
    DECLARE @RUC NVARCHAR(20);

    -- Obtener el RUC del cliente insertado
    SELECT @RUC = RUC FROM INSERTED;

    -- Verificar si el RUC ya existe en la tabla Cliente
    IF EXISTS (SELECT 1 FROM [dbo].[Cliente] WHERE RUC = @RUC)
    BEGIN
        PRINT 'Error: El RUC ya está registrado.'; -- Mensaje de error si el RUC ya existe
        ROLLBACK TRANSACTION; -- Cancelar la transacción
    END
END;
GO


-- Trigger 2: Actualizar estado de vehículo al insertar una venta
-- Este trigger se ejecuta después de insertar una venta y actualiza el estado del vehículo a "no disponible"
CREATE TRIGGER ActualizarEstadoVehiculo
ON [dbo].[DetalleVenta]
AFTER INSERT
AS
BEGIN
    DECLARE @id_vehiculo INT;

    -- Obtener el ID del vehículo de la venta insertada
    SELECT @id_vehiculo = id_vehiculo FROM INSERTED;

    -- Actualizar el estado del vehículo a "no disponible" (estado = 0)
    UPDATE Vehiculo
    SET estado = 0
    WHERE id_vehiculo = @id_vehiculo;
END;
GO


-- Trigger 3: Calcular saldo pendiente al insertar una venta
-- Este trigger se ejecuta después de insertar una venta, calculando el saldo pendiente basado en el precio del vehículo y el pago inicial
CREATE TRIGGER CalcularSaldoPendiente
ON [dbo].[DetalleVenta]
AFTER INSERT
AS
BEGIN
    DECLARE @id_venta INT, @pago_inicial DECIMAL(18, 2), @precio DECIMAL(18, 2);

    -- Obtener el ID de la venta y el pago inicial de la tabla INSERTED
    SELECT @id_venta = id_venta, @pago_inicial = pago_inicial
    FROM INSERTED;

    -- Obtener el precio del vehículo de la tabla Vehiculo
    SELECT @precio = precio
    FROM Vehiculo v
    JOIN DetalleVenta dv ON v.id_vehiculo = dv.id_vehiculo
    WHERE dv.id_venta = @id_venta;

    -- Actualizar el saldo pendiente en DetalleVenta
    UPDATE DetalleVenta
    SET saldo_pendiente = @precio - @pago_inicial
    WHERE id_venta = @id_venta;
END;
GO


-- Trigger 4: Restaurar vehículo a disponible cuando se elimina una venta
-- Este trigger se ejecuta después de eliminar una venta y devuelve el estado del vehículo a "disponible" (estado = 1)
CREATE TRIGGER RestaurarVehiculoEstado
ON [dbo].[Venta]
AFTER DELETE
AS
BEGIN
    DECLARE @id_vehiculo INT;

    -- Obtener el ID del vehículo asociado con la venta eliminada
    SELECT @id_vehiculo = id_vehiculo
    FROM DetalleVenta
    WHERE id_venta IN (SELECT id_venta FROM DELETED);

    -- Restaurar el estado del vehículo a "disponible" (estado = 1)
    UPDATE Vehiculo
    SET estado = 1
    WHERE id_vehiculo = @id_vehiculo;
END;
GO


-- Trigger 5: Generar un historial de cambios de precio de vehículos
-- Este trigger guarda el historial de precios cuando se actualiza el precio de un vehículo
CREATE TRIGGER RegistrarCambioPrecioVehiculo
ON [dbo].[Vehiculo]
AFTER UPDATE
AS
BEGIN
    DECLARE @id_vehiculo INT, @precio_anterior DECIMAL(18, 2), @precio_nuevo DECIMAL(18, 2);

    -- Obtener los datos del precio anterior y el nuevo precio
    SELECT @id_vehiculo = id_vehiculo, @precio_anterior = deleted.precio, @precio_nuevo = inserted.precio
    FROM DELETED deleted
    JOIN INSERTED inserted ON deleted.id_vehiculo = inserted.id_vehiculo
    WHERE deleted.precio != inserted.precio;

    -- Insertar el historial de precios en la tabla HistorialPrecioVehiculo
    INSERT INTO HistorialPrecioVehiculo (id_vehiculo, precio_anterior, precio_nuevo, fecha_cambio)
    VALUES (@id_vehiculo, @precio_anterior, @precio_nuevo, GETDATE());
END;
GO
