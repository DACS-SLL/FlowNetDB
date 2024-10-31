-- Creación de la base de datos FlowNet
CREATE DATABASE FlowNet
ON 
PRIMARY 
(
    NAME = 'FlowNetPrimary',
    FILENAME = 'C:\FlowNet\FlowNetPrimary.mdf', --Cambiar
    SIZE = 50MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetDataAut
(
    NAME = 'FlowNetDataAut1',
    FILENAME = 'C:\FlowNet\FlowNetDataAut1.ndf', --Cambiar
    SIZE = 50MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetDataAut2
(
    NAME = 'FlowNetDataAut2',
    FILENAME = 'C:\FlowNet\FlowNetDataAut2.ndf', --Cambiar
    SIZE = 50MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetDataVent
(
    NAME = 'FlowNetDataVent1',
    FILENAME = 'C:\FlowNet\FlowNetDataVent1.ndf', --Cambiar
    SIZE = 80MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetDataVent2
(
    NAME = 'FlowNetDataVent2',
    FILENAME = 'C:\FlowNet\FlowNetDataVent2.ndf', --Cambiar
    SIZE = 80MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetDataVent3
(
    NAME = 'FlowNetDataVent3',
    FILENAME = 'C:\FlowNet\FlowNetDataVent3.ndf', --Cambiar
    SIZE = 80MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetDataRep
(
    NAME = 'FlowNetDataRep',
    FILENAME = 'C:\FlowNet\FlowNetDataRep.ndf', --Cambiar
    SIZE = 50MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
),
FILEGROUP FlowNetLogs
(
    NAME = 'FlowNetLogs',
    FILENAME = 'C:\FlowNet\FlowNetLog.ndf', --Cambiar
    SIZE = 5MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
)
LOG ON 
(
    NAME = 'FlowNetLog',
    FILENAME = 'C:\FlowNet\FlowNetLog.ldf', --Cambiar
    SIZE = 5MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 15%
);
GO

-- Tablas principales
use FlowNet

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

-- Tabla EmpleadoVentas (Hereda de Empleado)
CREATE TABLE EmpleadoVentas (
    id_empleado INT PRIMARY KEY, 
    comisiones DECIMAL(18, 2),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);
GO

-- Tabla EmpleadoAdministrativo (Hereda de Empleado)
CREATE TABLE EmpleadoAdministrativo (
    id_empleado INT PRIMARY KEY,
    actividades_admin NVARCHAR(255),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);
GO

-- Tabla EmpleadoOperativo (Hereda de Empleado)
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

-- Tabla Vehículo
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

-- Tabla Venta
CREATE TABLE Venta (
    id_venta INT PRIMARY KEY IDENTITY(1,1),
    id_empleado INT FOREIGN KEY REFERENCES Empleado(id_empleado),
    fecha DATETIME NOT NULL,
    id_tipoC INT FOREIGN KEY REFERENCES Tipo_Comprobante (id_tipoC),
    XMLSUNAT TEXT,
);
GO

-- Tabla Detalle Venta
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


-- Tabla Taller
CREATE TABLE Taller (
    id_taller INT PRIMARY KEY IDENTITY(1,1),
    id_concesionario INT FOREIGN KEY REFERENCES Concesionario(id_concesionario),
    capacidad INT,
    direccion NVARCHAR(200),
    id_ciudad INT,
	FOREIGN KEY (id_ciudad) REFERENCES Man_Ciudad(id_ciudad)
);
GO

-- Tabla Mantenimiento
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
-- Tabla Repuestos
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

-- Tabla Concesionario
CREATE TABLE Concesionario (
    id_concesionario INT PRIMARY KEY IDENTITY(1,1),
    nombre_concesionario NVARCHAR(100),
    direccion NVARCHAR(200),
    id_ciudad INT,
    capacidad INT,
	FOREIGN KEY (id_ciudad) REFERENCES Man_Ciudad(id_ciudad)
);
GO


-- Tabla Contrato de Compra


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

-- Tabla Comprobante Electrónico
CREATE TABLE ComprobanteElectronico (
    id_comprobante INT PRIMARY KEY IDENTITY(1,1),
    id_venta INT FOREIGN KEY REFERENCES Venta(id_venta),
    id_tipoC INT FOREIGN KEY REFERENCES Tipo_Comprobante (id_tipoC),
    formatoXML TEXT,
    fecha_emision DATETIME,
    impuestos DECIMAL(18, 2)
);
GO
