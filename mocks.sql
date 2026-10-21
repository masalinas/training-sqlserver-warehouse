-- ============================================================================
-- Script: mocks.sql
-- Descripción: Generación y carga de datos mock para Almacén y Stock
-- RDBMS: Microsoft SQL Server (T-SQL)
-- ============================================================================

SET NOCOUNT ON;

PRINT '================================================================';
PRINT 'Iniciando generación de datos mock para Almacén';
PRINT '================================================================';

-- ----------------------------------------------------------------------------
-- 1. Limpieza ordenada idempotente
-- ----------------------------------------------------------------------------
PRINT '';
PRINT '1. Limpiando tablas Stock y Estanteria...';

DELETE FROM dbo.Stock;
DELETE FROM dbo.Estanteria;

DBCC CHECKIDENT ('dbo.Stock', RESEED, 0);
DBCC CHECKIDENT ('dbo.Estanteria', RESEED, 0);

PRINT '   Tablas limpiadas y contadores IDENTITY reiniciados a 0.';

-- ----------------------------------------------------------------------------
-- 2. Creación de 3 Estanterías con 3 posiciones (x) y 4 alturas (y) = 36 ubicaciones
-- ----------------------------------------------------------------------------
PRINT '';
PRINT '2. Creando estanterías y ubicaciones (E01, E02, E03 con x in 1..3 y in 1..4)...';

INSERT INTO dbo.Estanteria (CodigoEstanteria, x, y)
SELECT 
    E.CodigoEstanteria, 
    X.x, 
    Y.y
FROM (VALUES ('E01'), ('E02'), ('E03')) AS E(CodigoEstanteria)
CROSS JOIN (VALUES (1), (2), (3)) AS X(x)
CROSS JOIN (VALUES (1), (2), (3), (4)) AS Y(y)
ORDER BY E.CodigoEstanteria, Y.y, X.x;

DECLARE @TotalEstanteriasCreadas INT;
SELECT @TotalEstanteriasCreadas = COUNT(*) FROM dbo.Estanteria;
PRINT '   Total ubicaciones creadas: ' + CAST(@TotalEstanteriasCreadas AS VARCHAR(10));

-- ----------------------------------------------------------------------------
-- 3. Creación de Stock aleatorio solo en Estanterías E01 y E02
--    Productos: P01, P02, P03
--    Cantidades: DECIMAL(5,2) estrictamente positivas
--    Caducidad: Aleatoria futura o NULL para algunos registros
-- ----------------------------------------------------------------------------
PRINT '';
PRINT '3. Generando stock aleatorio en estanterías autorizadas (E01 y E02)...';

-- Tabla temporal para seleccionar ubicaciones disponibles de E01 y E02
DECLARE @UbicacionesAutorizadas TABLE (
    Orden INT IDENTITY(1,1),
    EstanteriaId INT NOT NULL,
    CodigoEstanteria CHAR(3) NOT NULL,
    x INT NOT NULL,
    y INT NOT NULL
);

INSERT INTO @UbicacionesAutorizadas (EstanteriaId, CodigoEstanteria, x, y)
SELECT EstanteriaId, CodigoEstanteria, x, y
FROM dbo.Estanteria
WHERE CodigoEstanteria IN ('E01', 'E02')
ORDER BY NEWID(); -- Orden aleatorio

DECLARE @TotalUbicacionesValidas INT;
SELECT @TotalUbicacionesValidas = COUNT(*) FROM @UbicacionesAutorizadas;

-- Generamos 18 registros de stock (6 por cada producto: P01, P02, P03)
;WITH Repeticiones AS (
    SELECT 1 AS Num UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
    SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
),
Productos AS (
    SELECT CodigoProducto FROM (VALUES ('P01'), ('P02'), ('P03')) AS P(CodigoProducto)
),
DatosStock AS (
    SELECT 
        P.CodigoProducto,
        R.Num,
        -- Asignamos cíclicamente entre las ubicaciones aleatorias
        ROW_NUMBER() OVER (ORDER BY NEWID()) AS UbicacionIndex,
        -- Cantidad aleatoria entre 1.00 y 99.99
        CAST(ROUND((ABS(CHECKSUM(NEWID())) % 9900 + 100) / 100.0, 2) AS DECIMAL(5,2)) AS CantidadGenerada,
        -- Caducidad: si Num <= 2 será NULL (~33% de los registros), si Num > 2 será fecha futura aleatoria
        CASE 
            WHEN R.Num <= 2 THEN NULL
            ELSE DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 360) + 15, CAST(GETDATE() AS DATE))
        END AS CaducidadGenerada
    FROM Productos P
    CROSS JOIN Repeticiones R
)
INSERT INTO dbo.Stock (EstanteriaId, CodigoProducto, Cantidad, Caducidad)
SELECT 
    U.EstanteriaId,
    D.CodigoProducto,
    D.CantidadGenerada,
    D.CaducidadGenerada
FROM DatosStock D
JOIN @UbicacionesAutorizadas U 
    ON U.Orden = ((D.UbicacionIndex - 1) % @TotalUbicacionesValidas) + 1;

DECLARE @TotalStockCreado INT;
SELECT @TotalStockCreado = COUNT(*) FROM dbo.Stock;
PRINT '   Total registros de stock creados: ' + CAST(@TotalStockCreado AS VARCHAR(10));

-- ----------------------------------------------------------------------------
-- 4. Verificación de reglas de negocio
-- ----------------------------------------------------------------------------
PRINT '';
PRINT '4. Comprobaciones de validación:';

-- Verificación de stock en E03 (debe ser estrictamente 0)
DECLARE @StockEnE03 INT;
SELECT @StockEnE03 = COUNT(*)
FROM dbo.Stock S
JOIN dbo.Estanteria E ON S.EstanteriaId = E.EstanteriaId
WHERE E.CodigoEstanteria = 'E03';

IF @StockEnE03 = 0
    PRINT '   [OK] La estantería E03 no tiene ningún stock asignado.';
ELSE
    PRINT '   [ERROR] Se encontró stock en la estantería E03.';

-- Verificación de registros sin caducidad (NULL)
DECLARE @StockSinCaducidad INT;
SELECT @StockSinCaducidad = COUNT(*) FROM dbo.Stock WHERE Caducidad IS NULL;
PRINT '   [OK] Registros de stock sin fecha de caducidad (NULL): ' + CAST(@StockSinCaducidad AS VARCHAR(10));

-- Verificación de registros con caducidad
DECLARE @StockConCaducidad INT;
SELECT @StockConCaducidad = COUNT(*) FROM dbo.Stock WHERE Caducidad IS NOT NULL;
PRINT '   [OK] Registros de stock con fecha de caducidad: ' + CAST(@StockConCaducidad AS VARCHAR(10));

PRINT '';
PRINT '================================================================';
PRINT 'Resumen por Estantería:';
PRINT '================================================================';

SELECT 
    E.CodigoEstanteria,
    COUNT(DISTINCT E.EstanteriaId) AS TotalUbicaciones,
    COUNT(S.StockId) AS TotalRegistrosStock,
    ISNULL(SUM(S.Cantidad), 0.00) AS TotalCantidadStock
FROM dbo.Estanteria E
LEFT JOIN dbo.Stock S ON E.EstanteriaId = S.EstanteriaId
GROUP BY E.CodigoEstanteria
ORDER BY E.CodigoEstanteria;
