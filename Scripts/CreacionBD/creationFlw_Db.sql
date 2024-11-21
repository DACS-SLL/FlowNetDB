-- Verificar y eliminar la base de datos si existe
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'FlowNet')
BEGIN
    DROP DATABASE FlowNet;
END
GO

-- Creación de la base de datos FlowNet
CREATE DATABASE FlowNet
ON 
PRIMARY 
(
    NAME = 'FlowNetPrimary',
    FILENAME = 'D:\DBS\Fl\FlowNetPrimary.mdf', --Cambiar
    SIZE = 50MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetDataAut
(
    NAME = 'FlowNetDataAut1',
    FILENAME = 'D:\DBS\Fl\FlowNetDataAut1.ndf', --Cambiar
    SIZE = 50MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetDataAut2
(
    NAME = 'FlowNetDataAut2',
    FILENAME = 'D:\DBS\Fl\FlowNetDataAut2.ndf', --Cambiar
    SIZE = 50MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetDataVent
(
    NAME = 'FlowNetDataVent1',
    FILENAME = 'D:\DBS\Fl\FlowNetDataVent1.ndf', --Cambiar
    SIZE = 80MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetDataVent2
(
    NAME = 'FlowNetDataVent2',
    FILENAME = 'D:\DBS\Fl\FlowNetDataVent2.ndf', --Cambiar
    SIZE = 80MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetDataVent3
(
    NAME = 'FlowNetDataVent3',
    FILENAME = 'D:\DBS\Fl\FlowNetDataVent3.ndf', --Cambiar
    SIZE = 80MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetDataRep
(
    NAME = 'FlowNetDataRep',
    FILENAME = 'D:\DBS\Fl\FlowNetDataRep.ndf', --Cambiar
    SIZE = 50MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetLogs
(
    NAME = 'FlowNetLog1',
    FILENAME = 'D:\DBS\Fl\FlowNetLog.ndf', --Cambiar
    SIZE = 5MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
)
LOG ON 
(
    NAME = 'FlowNetLog',
    FILENAME = 'D:\DBS\Fl\FlowNetLog.ldf', --Cambiar
    SIZE = 5MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
);
GO

USE FlowNet;
GO
-- Verificar y eliminar las tablas si existen
IF OBJECT_ID('Man_Pais', 'U') IS NOT NULL DROP TABLE Man_Pais;
IF OBJECT_ID('Man_ciudad', 'U') IS NOT NULL DROP TABLE Man_ciudad;
IF OBJECT_ID('Empleado', 'U') IS NOT NULL DROP TABLE Empleado;
IF OBJECT_ID('EmpleadoVentas', 'U') IS NOT NULL DROP TABLE EmpleadoVentas;
IF OBJECT_ID('EmpleadoAdministrativo', 'U') IS NOT NULL DROP TABLE EmpleadoAdministrativo;
IF OBJECT_ID('EmpleadoOperativo', 'U') IS NOT NULL DROP TABLE EmpleadoOperativo;
IF OBJECT_ID('Metodo_Pago', 'U') IS NOT NULL DROP TABLE Metodo_Pago;
IF OBJECT_ID('Tipo_Comprobante', 'U') IS NOT NULL DROP TABLE Tipo_Comprobante;
IF OBJECT_ID('Marca', 'U') IS NOT NULL DROP TABLE Marca;
IF OBJECT_ID('Preferencias', 'U') IS NOT NULL DROP TABLE Preferencias;
IF OBJECT_ID('Cliente', 'U') IS NOT NULL DROP TABLE Cliente;
IF OBJECT_ID('InformCliente', 'U') IS NOT NULL DROP TABLE InformCliente;
IF OBJECT_ID('Vehiculo', 'U') IS NOT NULL DROP TABLE Vehiculo;
IF OBJECT_ID('Detalle_Vehiculo', 'U') IS NOT NULL DROP TABLE Detalle_Vehiculo;
IF OBJECT_ID('Venta', 'U') IS NOT NULL DROP TABLE Venta;
IF OBJECT_ID('DetalleVenta', 'U ```sql
') IS NOT NULL DROP TABLE DetalleVenta;
IF OBJECT_ID('Taller', 'U') IS NOT NULL DROP TABLE Taller;
IF OBJECT_ID('Mantenimiento', 'U') IS NOT NULL DROP TABLE Mantenimiento;
IF OBJECT_ID('Marca_Repuesto', 'U') IS NOT NULL DROP TABLE Marca_Repuesto;
IF OBJECT_ID('Modelo_Repuesto', 'U') IS NOT NULL DROP TABLE Modelo_Repuesto;
IF OBJECT_ID('Repuestos', 'U') IS NOT NULL DROP TABLE Repuestos;
IF OBJECT_ID('Concesionario', 'U') IS NOT NULL DROP TABLE Concesionario;
IF OBJECT_ID('ContratoCompra', 'U') IS NOT NULL DROP TABLE ContratoCompra;
IF OBJECT_ID('DetalleContrato', 'U') IS NOT NULL DROP TABLE DetalleContrato;
IF OBJECT_ID('ComprobanteElectronico', 'U') IS NOT NULL DROP TABLE ComprobanteElectronico;

-- Tablas principales
CREATE TABLE Man_Pais (
    id_pais INT PRIMARY KEY IDENTITY(1,1),
    nombre_pais NVARCHAR(10) NOT NULL
);

CREATE TABLE Man_ciudad (
    id_ciudad INT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(100) NOT NULL,
	id_pais INT FOREIGN KEY REFERENCES Man_Pais(id_pais)
);

CREATE TABLE Empleado (
    id_empleado INT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(100) NOT NULL,
    dni NVARCHAR(15) NOT NULL UNIQUE,
    disponibilidad BIT DEFAULT 1 -- Significa 1 disponible, 0 no disponible
);
GO

IF OBJECT_ID('Empleado', 'U') IS NOT NULL
BEGIN
    ALTER TABLE Empleado ADD fecha_ingreso DATETIME NULL;
END

CREATE TABLE EmpleadoVentas (
    id_empleado INT PRIMARY KEY, 
    comisiones DECIMAL(18, 2),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);
GO

CREATE TABLE EmpleadoAdministrativo (
    id_empleado INT PRIMARY KEY,
    actividades_admin NVARCHAR(255),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);
GO

CREATE TABLE EmpleadoOperativo (
    id_empleado INT PRIMARY KEY,
    disponibilidad NVARCHAR(50),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);

GO

CREATE TABLE Metodo_Pago (
    id_metodo_pago INT PRIMARY KEY IDENTITY(1,1),
    tipo NVARCHAR(50)
);

GO

CREATE TABLE Tipo_Comprobante (
    id_tipoC INT PRIMARY KEY IDENTITY(1,1),
    tipo NVARCHAR(50)
);

GO

CREATE TABLE Marca (
    id_marca INT PRIMARY KEY IDENTITY(1,1),
    tipo NVARCHAR(50)
);

GO

CREATE TABLE Preferencias (
    id_preferencia INT PRIMARY KEY IDENTITY(1,1),
    id_marca INT,
    id_metodopago INT
	FOREIGN KEY (id_metodopago) REFERENCES Metodo_Pago(id_metodo_pago),  -- FK a Metodo_Pago
    FOREIGN KEY (id_marca) REFERENCES Marca(id_marca)   
);

GO

CREATE TABLE Cliente (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(100) NOT NULL,
    telefono NVARCHAR(20),
    RUC NVARCHAR(20),
	dni NVARCHAR(15) UNIQUE
);
GO

CREATE TABLE InformCliente (
    id_cliente INT PRIMARY KEY,
    direccion NVARCHAR(200),
    id_ciudad INT,
    historial_compras TEXT,
	email NVARCHAR(100),
    id_preferencia INT,
	FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
	FOREIGN KEY (id_preferencia) REFERENCES Preferencias(id_preferencia),
	FOREIGN KEY (id_ciudad) REFERENCES Man_Ciudad(id_ciudad)
);

GO

CREATE TABLE Vehiculo (
    id_vehiculo INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT FOREIGN KEY REFERENCES Cliente(id_cliente),
    precio DECIMAL(18, 2),
);
GO

CREATE TABLE Detalle_Vehiculo (
    id_vehiculo INT PRIMARY KEY,
    año INT,
    id_marca INT,
    modelo NVARCHAR(100),
    potencia NVARCHAR(50),
    kms DECIMAL(10, 2),
    FOREIGN KEY (id_vehiculo) REFERENCES Vehiculo(id_vehiculo),
	FOREIGN KEY (id_marca) REFERENCES Marca(id_marca)
);

GO

CREATE TABLE Venta (
    id_venta INT PRIMARY KEY IDENTITY(1,1),
    id_empleado INT FOREIGN KEY REFERENCES Empleado(id_empleado),
    fecha DATETIME NOT NULL,
    id_tipoC INT FOREIGN KEY REFERENCES Tipo_Comprobante (id_tipoC),
    XMLSUNAT TEXT,
);
GO

CREATE TABLE DetalleVenta (
    id_venta INT FOREIGN KEY REFERENCES Venta(id_venta),
    id_vehiculo INT FOREIGN KEY REFERENCES Vehiculo(id_vehiculo),
	id_metodo_pago INT FOREIGN KEY REFERENCES Metodo_Pago(id_metodo_pago),
	pago_inicial DECIMAL(18,2),
	saldo_pendiente DECIMAL(18,2),
	id_cliente INT FOREIGN KEY REFERENCES Cliente(id_cliente),
    re_registro BIT DEFAULT 0 -- 1 si requiere re-registro, 0 si no
);
GO

CREATE TABLE Concesionario (
    id_concesionario INT PRIMARY KEY IDENTITY(1,1),
    nombre_concesionario NVARCHAR(100),
    direccion NVARCHAR(200),
    id_ciudad INT,
    capacidad INT,
	FOREIGN KEY (id_ciudad) REFERENCES Man_Ciudad(id_ciudad)
);
GO

CREATE TABLE Taller (
    id_taller INT PRIMARY KEY IDENTITY(1,1),
    id_concesionario INT FOREIGN KEY REFERENCES Concesionario(id_concesionario),
    capacidad INT,
    direccion NVARCHAR(200),
    id_ciudad INT,
	FOREIGN KEY (id_ciudad) REFERENCES Man_Ciudad(id_ciudad)
);
GO

CREATE TABLE Mantenimiento (
    id_mantenimiento INT PRIMARY KEY IDENTITY(1,1),
    id_vehiculo INT FOREIGN KEY REFERENCES Vehiculo(id_vehiculo),
    id_empleado INT FOREIGN KEY REFERENCES Empleado(id_empleado),
	id_taller INT,
    tipo NVARCHAR(50) CHECK(tipo IN ('Correctivo', 'Preventivo')),
    fecha DATETIME NOT NULL,
    observaciones TEXT,
	FOREIGN KEY (id_taller) REFERENCES Taller(id_taller)
);
GO

CREATE TABLE Marca_Repuesto (
    id_marca INT PRIMARY KEY IDENTITY(1,1),
    nombre_marca NVARCHAR(100)
);

GO

CREATE TABLE Modelo_Repuesto (
    id_modelo INT PRIMARY KEY IDENTITY(1,1),
    nombre_modelo NVARCHAR(100)
);

GO
CREATE TABLE Repuestos (
    id_repuesto INT PRIMARY KEY IDENTITY(1,1),
    id_mantenimiento INT FOREIGN KEY REFERENCES Mantenimiento(id_mantenimiento),
    nombre NVARCHAR(100),
    id_marca INT FOREIGN KEY REFERENCES Marca_Repuesto(id_marca),
    id_modelo INT FOREIGN KEY REFERENCES Modelo_Repuesto(id_modelo),
    precio DECIMAL(18, 2),
    estado NVARCHAR(50) CHECK(estado IN ('Nuevo', 'Usado')),
    fecha_de_compra DATETIME
);
GO

CREATE TABLE ContratoCompra (
    id_contrato INT PRIMARY KEY IDENTITY(1,1),
    id_venta INT FOREIGN KEY REFERENCES Venta(id_venta),
    fecha DATETIME NOT NULL
);
GO

CREATE TABLE DetalleContrato (
    id_detallecontrato INT PRIMARY KEY IDENTITY(1,1),
    id_contrato INT,
    termino_condiciones TEXT,
    politicas TEXT,
    FOREIGN KEY (id_contrato) REFERENCES ContratoCompra(id_contrato)
);

GO

CREATE TABLE ComprobanteElectronico (
    id_comprobante INT PRIMARY KEY IDENTITY(1,1),
    id_venta INT FOREIGN KEY REFERENCES Venta(id_venta),
    id_tipoC INT FOREIGN KEY REFERENCES Tipo_Comprobante (id_tipoC),
    formatoXML TEXT,
    fecha_emision DATETIME,
    impuestos DECIMAL(18, 2)
);
GO
