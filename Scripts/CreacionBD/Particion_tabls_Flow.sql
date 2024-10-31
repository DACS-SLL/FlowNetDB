-- Paso 1: Crear la nueva tabla 'VentaFinanciera' con las columnas a particionar
CREATE TABLE VentaFinanciera (
    id_venta INT PRIMARY KEY,
    pago_inicial DECIMAL(18, 2),
    saldo_pendiente DECIMAL(18, 2),
    tipo_comprobante NVARCHAR(50),
    XMLSUNAT TEXT,
    FOREIGN KEY (id_venta) REFERENCES Venta(id_venta)
);
GO

-- Paso 2: Copiar los datos de 'Venta' a 'VentaFinanciera'
INSERT INTO VentaFinanciera (id_venta, pago_inicial, saldo_pendiente, tipo_comprobante, XMLSUNAT)
SELECT id_venta, pago_inicial, saldo_pendiente, tipo_comprobante, XMLSUNAT FROM Venta;
GO

-- Paso 3: Eliminar las columnas particionadas de la tabla 'Venta'
ALTER TABLE Venta
DROP COLUMN pago_inicial,
            saldo_pendiente,
            tipo_comprobante,
            XMLSUNAT;
GO