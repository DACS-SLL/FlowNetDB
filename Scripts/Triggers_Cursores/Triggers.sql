-- Antes del Trigger 1: crear la columna Estado 
alter table Vehiculo
add estado nvarchar(10)
go
-- Trigger 1: Actualizar inventario de vehículos después de una venta
CREATE TRIGGER ActualizarInventarioVehiculo
ON Vehiculo
AFTER INSERT
AS
BEGIN
    DECLARE @id_vehiculo INT;

    -- Obtener el id_vehiculo de la nueva venta
    SELECT @id_vehiculo = id_vehiculo
    FROM inserted;

    -- Actualizar el estado del vehículo a "Vendido"
    UPDATE Vehiculo
    SET estado = 'Vendido'
    WHERE id_vehiculo = @id_vehiculo;
END;
GO

-- Trigger 2: Calcular comisiones de vendedores después de una venta
CREATE TRIGGER CalcularComisionVenta
ON Venta
AFTER INSERT
AS
BEGIN
    DECLARE @idVenta INT;
    DECLARE @idEmpleado INT;
    DECLARE @totalVenta DECIMAL(18, 2);
    DECLARE @comision DECIMAL(18, 2);

    -- Asumimos que la comisión es del 5%
    DECLARE @porcentajeComision DECIMAL(5, 2) = 0.05;

    -- Obtener la información de la venta registrada
    SELECT @idVenta = id_venta, @idEmpleado = id_empleado
    FROM INSERTED;

    -- Calcular el total de la venta sumando los precios de los vehículos involucrados en ella
    SELECT @totalVenta = SUM(v.precio)
    FROM DetalleVenta dv
    JOIN Vehiculo v ON dv.id_vehiculo = v.id_vehiculo
    WHERE dv.id_venta = @idVenta;

    -- Calcular la comisión basada en el porcentaje
    SET @comision = @totalVenta * @porcentajeComision;

    -- Actualizar el campo de comisiones en EmpleadoVentas
    UPDATE EmpleadoVentas
    SET comisiones = comisiones + @comision
    WHERE id_empleado = @idEmpleado;
END;
GO

-- Trigger 3: Registrar el historial de mantenimiento de un vehículo
CREATE TRIGGER RegistrarHistorialMantenimiento
ON Mantenimiento
AFTER INSERT
AS
BEGIN
    DECLARE @idMantenimiento INT;
    DECLARE @idVehiculo INT;
    DECLARE @fecha DATETIME;
    DECLARE @tipo NVARCHAR(50);
     

    -- Obtener los datos del mantenimiento desde la tabla INSERTED
    SELECT 
        @idMantenimiento = id_mantenimiento,
        @idVehiculo = id_vehiculo,
        @fecha = fecha,
        @tipo = tipo
        
    FROM INSERTED;

    -- Insertar un nuevo registro en HistorialMantenimiento con los datos del mantenimiento
    INSERT INTO HistorialMantenimiento (id_vehiculo, id_mantenimiento, fecha, tipo)
    VALUES (@idVehiculo, @idMantenimiento, @fecha, @tipo);
END;
GO

-- Trigger 4: Controlar la capacidad disponible en los talleres
CREATE TRIGGER ControlCapacidadTaller
ON Mantenimiento
AFTER INSERT
AS
BEGIN
    DECLARE @idTaller INT;
    DECLARE @capacidadActual INT;

    -- Obtener el ID del taller desde la tabla INSERTED
    SELECT @idTaller = id_taller
    FROM INSERTED;

    -- Obtener la capacidad actual del taller
    SELECT @capacidadActual = capacidad
    FROM Taller
    WHERE id_taller = @idTaller;

    -- Verificar si el taller tiene capacidad
    IF @capacidadActual > 0
    BEGIN
        -- Actualizar la capacidad del taller restando 1
        UPDATE Taller
        SET capacidad = capacidad - 1
        WHERE id_taller = @idTaller;
    END
    ELSE
    BEGIN
        -- Si no hay capacidad disponible, revertir la operación de inserción y mostrar un mensaje de error
        RAISERROR ('No hay capacidad disponible en el taller seleccionado.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
-- Antes del Trigger 5: Crear una tabla Pagos para registrar cada pago que se haga
CREATE TABLE Pagos (
    id_pago INT PRIMARY KEY IDENTITY(1,1),
    id_venta INT,                  -- Relaciona el pago con una venta
    monto DECIMAL(18, 2) NOT NULL, -- Monto del pago realizado
    fecha DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_venta) REFERENCES Venta(id_venta)
);
GO

-- Trigger 5: Actualizar el saldo pendiente después de un pago
CREATE TRIGGER trg_ActualizarSaldoPendiente
ON Pagos
AFTER INSERT
AS
BEGIN
    DECLARE @idVenta INT;
    DECLARE @montoPago DECIMAL(18, 2);

    -- Obtener el ID de la venta y el monto del pago desde la tabla INSERTED
    SELECT 
        @idVenta = id_venta,
        @montoPago = monto
    FROM INSERTED;

    -- Actualizar el saldo pendiente en la tabla DetalleVenta
    UPDATE DetalleVenta
    SET saldo_pendiente = saldo_pendiente - @montoPago
    WHERE id_venta = @idVenta;

    -- Verificar si el saldo pendiente es menor que cero y ajustarlo a cero
    UPDATE DetalleVenta
    SET saldo_pendiente = 0
    WHERE id_venta = @idVenta AND saldo_pendiente < 0;
END;
GO
