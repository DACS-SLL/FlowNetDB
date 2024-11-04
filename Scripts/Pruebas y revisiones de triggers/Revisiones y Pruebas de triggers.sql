--1. Revisión Adecuada de los Procedimientos, Vistas y Funciones

USE FlowNet2;

-- Listar todos los procedimientos almacenados
SELECT * 
FROM sys.procedures;

-- Listar todas las vistas
SELECT * 
FROM sys.views;

-- Listar todas las funciones definidas por el usuario
SELECT * 
FROM sys.objects 
WHERE type IN ('FN', 'IF', 'TF');


EXEC sp_helptext 'CalcularComisionTotalEmpleado';

--2. Pruebas con los Triggers en la Base de Datos

USE FlowNet2;

SELECT name, parent_class_desc, create_date
FROM sys.triggers;

EXEC sp_helptext 'ActualizarInventarioVehiculo';
DECLARE @id_vehiculo INT;

SET @id_vehiculo = 1;  -- Asigna el valor real del id_vehiculo que necesitas

INSERT INTO Venta (id_empleado, fecha, id_tipoC, XMLSUNAT)
VALUES (1, GETDATE(), 1, '<xml>Ejemplo</xml>');

SELECT estado FROM Vehiculo WHERE id_vehiculo = @id_vehiculo;


INSERT INTO Venta (id_empleado, fecha, id_tipoC, XMLSUNAT)
VALUES (2, GETDATE(), 2, '<xml>Ejemplo</xml>');

SELECT comisiones FROM EmpleadoVentas WHERE id_empleado = 2;

INSERT INTO Pagos (id_venta, monto) VALUES (1, 500);
SELECT saldo_pendiente FROM DetalleVenta WHERE id_venta = 1;
