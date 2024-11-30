--Funciones
--Calcular la Comisión Total de un Empleado de Ventas:
CREATE FUNCTION CalcularComisionTotalEmpleado (
@id_empleado INT,
@fecha_inicio DATETIME,
@fecha_fin DATETIME
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
DECLARE @comision_total DECIMAL(18, 2);
SELECT @comision_total = SUM(ev.comisiones)
FROM EmpleadoVentas ev
JOIN Venta v ON v.id_empleado = ev.id_empleado
WHERE ev.id_empleado = @id_empleado
AND v.fecha BETWEEN @fecha_inicio AND @fecha_fin;
RETURN ISNULL(@comision_total, 0);
END;
GO
--Calcular el Descuento Promedio en Ventas:
CREATE FUNCTION CalcularDescuentoPromedio()
RETURNS DECIMAL(18, 2)
AS
BEGIN
DECLARE @descuento_promedio DECIMAL(18, 2);
SELECT @descuento_promedio = AVG((v.precio - dv.pago_inicial) / v.precio * 100)
FROM Vehiculo v
JOIN Venta dv ON v.id_vehiculo = dv.id_vehiculo;
RETURN ISNULL(@descuento_promedio, 0);
END;
GO
--Determinar la Capacidad Disponible en Talleres
CREATE FUNCTION CapacidadDisponibleTaller (
@id_taller INT
)
RETURNS INT
AS
BEGIN
DECLARE @capacidad_total INT;
DECLARE @mantenimientos_programados INT;
SELECT @capacidad_total = capacidad
FROM Taller
WHERE id_taller = @id_taller;
SELECT @mantenimientos_programados = COUNT(*)
FROM Mantenimiento
WHERE id_taller = @id_taller;
RETURN @capacidad_total - @mantenimientos_programados;
END;
GO


CREATE OR REPLACE FUNCTION verificar_cliente_existente(
    p_nombre Cliente.nombre%TYPE,  
    p_email Cliente.email%TYPE     
) RETURN BOOLEAN IS
    cliente_existente BOOLEAN;
BEGIN
    SELECT COUNT(*) > 0 INTO cliente_existente
    FROM Cliente
    WHERE nombre = p_nombre AND email = p_email;

    RETURN cliente_existente;
END;



