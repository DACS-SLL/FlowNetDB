CREATE TRIGGER trg_AfterInsertCliente
ON Cliente
AFTER INSERT
AS
BEGIN
    DECLARE @cliente_nombre NVARCHAR(100);
    DECLARE @cliente_dni NVARCHAR(15);

    -- Obtener el nombre y el DNI del cliente insertado
    SELECT @cliente_nombre = nombre, @cliente_dni = dni
    FROM inserted;

    -- Imprimir mensaje
    PRINT 'Cliente registrado: ' + @cliente_nombre + ' con DNI: ' + @cliente_dni;
END;
GO

CREATE TRIGGER trg_AfterInsertVehiculo
ON Vehiculo
AFTER INSERT
AS
BEGIN
    DECLARE @id_vehiculo INT;
    DECLARE @id_cliente INT;
    DECLARE @precio DECIMAL(18,2);

    -- Obtener los datos del vehículo insertado
    SELECT @id_vehiculo = id_vehiculo, @id_cliente = id_cliente, @precio = precio
    FROM inserted;

    -- Imprimir mensaje
    PRINT 'Nuevo vehículo registrado: ID Vehículo: ' + CAST(@id_vehiculo AS NVARCHAR(10)) + ', Cliente ID: ' + CAST(@id_cliente AS NVARCHAR(10)) + ', Precio: ' + CAST(@precio AS NVARCHAR(18));
END;
GO

CREATE TRIGGER trg_AfterDeleteVenta
ON Venta
AFTER DELETE
AS
BEGIN
    DECLARE @id_venta INT;
    DECLARE @id_vehiculo INT;
    DECLARE @cliente_nombre NVARCHAR(100);

    -- Obtener el id_venta de la fila eliminada en la tabla Venta (tabla 'deleted' en un trigger AFTER DELETE)
    SELECT @id_venta = id_venta FROM deleted;

    -- Obtener el nombre del cliente relacionado con la venta eliminada
    SELECT @cliente_nombre = c.nombre
    FROM Cliente c
    INNER JOIN DetalleVenta dv ON c.id_cliente = dv.id_cliente
    WHERE dv.id_venta = @id_venta;

    -- Comienza la transacción para restaurar el estado del vehículo
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Obtener el id_vehiculo asociado a la venta eliminada
        SELECT @id_vehiculo = id_vehiculo
        FROM DetalleVenta
        WHERE id_venta = @id_venta;

        -- Restaurar el estado del vehículo a disponible (estado = 1)
        UPDATE Vehiculo
        SET estado = 1  -- Disponible
        WHERE id_vehiculo = @id_vehiculo;

        -- Confirmar la transacción
        COMMIT TRANSACTION;

        -- Imprimir mensaje indicando que la venta fue eliminada
        PRINT 'Venta eliminada con éxito. Cliente: ' + @cliente_nombre + ', ID Venta: ' + CAST(@id_venta AS NVARCHAR(10));
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, hacer rollback de la transacción
        ROLLBACK TRANSACTION;
        -- Lanzar el error
        THROW;
    END CATCH
END;
GO

CREATE TRIGGER trg_AfterInsertVenta_ReporteMensual
ON Venta
AFTER INSERT
AS
BEGIN
    DECLARE @fecha DATETIME;
    DECLARE @mes INT;
    DECLARE @anio INT;

    -- Obtener la fecha de la venta insertada
    SELECT @fecha = fecha FROM inserted;

    -- Extraer el mes y año de la fecha de la venta
    SET @mes = MONTH(@fecha);
    SET @anio = YEAR(@fecha);

    -- Comprobar si la venta pertenece al mes y año de interés
    -- Aquí podrías agregar un proceso que active algún reporte o log
    PRINT 'Nueva venta registrada. Fecha: ' + CAST(@fecha AS NVARCHAR(20)) + 
          ', Mes: ' + CAST(@mes AS NVARCHAR(2)) + ', Año: ' + CAST(@anio AS NVARCHAR(4));

END;
GO

CREATE TRIGGER trg_AfterInsertDetalleVenta
ON DetalleVenta
AFTER INSERT
AS
BEGIN
    DECLARE @id_vehiculo INT;
    DECLARE @id_cliente INT;
    DECLARE @id_venta INT;
    DECLARE @pago_inicial DECIMAL(18, 2);

    -- Obtener los datos del detalle de la venta insertada
    SELECT @id_vehiculo = id_vehiculo, @id_cliente = id_cliente, @id_venta = id_venta, @pago_inicial = pago_inicial
    FROM inserted;

    -- Imprimir mensaje con detalles de la venta
    PRINT 'Detalle de venta registrado: ID Venta: ' + CAST(@id_venta AS NVARCHAR(10)) + ', Vehículo ID: ' + CAST(@id_vehiculo AS NVARCHAR(10)) + ', Cliente ID: ' + CAST(@id_cliente AS NVARCHAR(10)) + ', Pago Inicial: ' + CAST(@pago_inicial AS NVARCHAR(18));
END;
GO



--Pruebas
-- Registrar un cliente
EXEC RegistrarCliente
    @nombre = 'Juan Pérez',
    @telefono = '987654325',
    @RUC = '22345678402',
    @dni = '113456078';


	-- Registrar un vehículo para el cliente
EXEC RegistrarVehiculo
    @id_cliente = 1, 
    @precio = 15000.00,
    @año = 2020,
    @id_marca = 1,  
    @modelo = 'Toyota Corolla',
    @potencia = '150 HP',
    @kms = 12000.00;

	-- Registrar una venta (no funciona con el GETDATE())
EXEC InsertarVenta 
    @id_empleado = 1, 
    @fecha = '2024-12-02 10:30:00', 
    @id_tipoC = 1, 
    @id_cliente = 1, 
    @id_vehiculo = 1, 
    @pago_inicial = 5000.00, 
    @id_metodo_pago = 1;



DELETE FROM Venta
WHERE id_venta = (SELECT MAX(id_venta) FROM Venta); 

-- Primero, insertar una venta para asegurarte de que hay una venta para eliminar
EXEC InsertarVenta
    @id_empleado = 1, 
    @fecha = '2024-12-10',  
    @id_tipoC = 1, 
    @id_cliente = 3,  
    @id_vehiculo = 4, 
    @pago_inicial = 2000.00,  
    @id_metodo_pago = 1;

-- Ejecutar el procedimiento de eliminación de venta
EXEC EliminarVenta
    @id_venta = 1; 
