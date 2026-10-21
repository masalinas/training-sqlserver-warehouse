-- ============================================================================
-- Script: model.sql
-- Descripción: Modelo de dominio para gestión de stock y estanterías en almacén
-- RDBMS: Microsoft SQL Server (T-SQL)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Limpieza idempotente previa (orden según integridad referencial)
-- ----------------------------------------------------------------------------
IF OBJECT_ID('dbo.Stock', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Stock;
END;
GO

IF OBJECT_ID('dbo.Estanteria', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Estanteria;
END;
GO

-- ----------------------------------------------------------------------------
-- Tabla: Estanteria
-- Representa un conjunto de ubicaciones en donde se pueden almacenar productos.
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Estanteria (
    EstanteriaId INT IDENTITY(1,1) NOT NULL,
    CodigoEstanteria CHAR(3) NOT NULL,
    x INT NOT NULL,
    y INT NOT NULL,

    -- Clave Primaria
    CONSTRAINT PK_Estanteria PRIMARY KEY CLUSTERED (EstanteriaId),

    -- Unicidad de ubicación (una estantería no puede repetir coordenadas x, y)
    CONSTRAINT UQ_Estanteria_Ubicacion UNIQUE (CodigoEstanteria, x, y),

    -- Formato: 'E' mayúscula seguida de 2 dígitos numéricos (ej. E00 - E99)
    CONSTRAINT CK_Estanteria_CodigoEstanteria CHECK (
        LEN(CodigoEstanteria) = 3
        AND CodigoEstanteria COLLATE Latin1_General_BIN2 LIKE 'E[0-9][0-9]'
    ),

    -- Posición longitudinal: entero mayor o igual a 0
    CONSTRAINT CK_Estanteria_x CHECK (x >= 0),

    -- Posición en altura: entero mayor o igual a 0
    CONSTRAINT CK_Estanteria_y CHECK (y >= 0)
);
GO

-- ----------------------------------------------------------------------------
-- Tabla: Stock
-- Representa la cantidad de producto ubicado en una posición exacta de una estantería.
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Stock (
    StockId INT IDENTITY(1,1) NOT NULL,
    EstanteriaId INT NOT NULL,
    CodigoProducto CHAR(3) NOT NULL,
    Cantidad DECIMAL(5,2) NOT NULL,
    Caducidad DATE NULL,

    -- Clave Primaria
    CONSTRAINT PK_Stock PRIMARY KEY CLUSTERED (StockId),

    -- Clave Foránea hacia Estanteria
    CONSTRAINT FK_Stock_Estanteria FOREIGN KEY (EstanteriaId)
        REFERENCES dbo.Estanteria (EstanteriaId),

    -- Formato: 'P' mayúscula seguida de 2 dígitos numéricos (ej. P00 - P99)
    CONSTRAINT CK_Stock_CodigoProducto CHECK (
        LEN(CodigoProducto) = 3
        AND CodigoProducto COLLATE Latin1_General_BIN2 LIKE 'P[0-9][0-9]'
    ),

    -- Cantidad: estrictamente positiva (> 0) con 3 dígitos enteros y 2 decimales
    CONSTRAINT CK_Stock_Cantidad CHECK (Cantidad > 0.00)
);
GO
