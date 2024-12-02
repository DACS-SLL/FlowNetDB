


-- Paso 1: Crear la nueva tabla 'VentaFinanciera' con las columnas a particionar
CREATE TABLE VentaFinanciera (
    id_venta INT PRIMARY KEY,
    pago_inicial DECIMAL(18, 2),
    saldo_pendiente DECIMAL(18, 2),
    tipo_comprobante NVARCHAR(50),
    XMLSUNAT TEXT,
    FOREIGN KEY (id_venta) REFERENCES Venta(id_venta)
);
go


-- Paso 2: Copiar los datos de 'Venta' a 'VentaFinanciera'
-- Copiar los datos de 'Venta' a 'VentaFinanciera'
INSERT INTO VentaFinanciera (id_venta, pago_inicial, saldo_pendiente, tipo_comprobante, XMLSUNAT)
SELECT id_venta, pago_inicial, saldo_pendiente, tipo_comprobante, XMLSUNAT 
FROM DetalleVenta;
GO


-- Paso 3: Eliminar las columnas particionadas de la tabla 'Venta'
ALTER TABLE Venta
DROP COLUMN pago_inicial,
            saldo_pendiente,
            tipo_comprobante,
            XMLSUNAT;
GO

-- Crear un índice en la columna 'fecha' para optimizar las consultas por fecha
CREATE INDEX idx_fecha_venta ON Venta(fecha);
GO

-- Crear un índice en 'id_empleado' para acelerar las consultas por empleado
CREATE INDEX idx_empleado_venta ON Venta(id_empleado);
GO

-- Crear un índice en 'id_tipoC' para acelerar las consultas por tipo de comprobante
CREATE INDEX idx_tipo_comprobante_venta ON Venta(id_tipoC);
GO

-- Crear un índice en 'id_venta' para acelerar las consultas en la tabla 'VentaFinanciera'
CREATE INDEX idx_id_venta_financiera ON VentaFinanciera(id_venta);
GO
