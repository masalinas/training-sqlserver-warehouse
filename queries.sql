-- ============================================================================
-- Script: queries.sql
-- Descripción: Consultas analíticas y de prueba para Almacén y Stock
-- RDBMS: Microsoft SQL Server (T-SQL)
-- ============================================================================

SET NOCOUNT ON;

PRINT '================================================================';
PRINT 'Ejecutando consultas analíticas de Almacén y Stock';
PRINT '================================================================';

-- ----------------------------------------------------------------------------
-- 1. Consulta: Roturas de Stock (Productos sin existencias)
-- Descripción: Compara un catálogo de artículos esperados frente al stock real
--              para identificar aquellos productos sin unidades disponibles.
-- ----------------------------------------------------------------------------
PRINT '';
PRINT '--- 1. Productos con rotura de stock ---';

SELECT 
    C.CodigoProducto,
    C.Descripcion,
    ISNULL(SUM(S.Cantidad), 0.00) AS StockDisponible
FROM (VALUES 
    ('P00', 'Producto Sin Existencias'),
    ('P01', 'Producto P01'),
    ('P02', 'Producto P02'),
    ('P03', 'Producto P03')
) AS C(CodigoProducto, Descripcion)
LEFT JOIN dbo.Stock S ON C.CodigoProducto = S.CodigoProducto
GROUP BY C.CodigoProducto, C.Descripcion
HAVING COUNT(S.StockId) = 0 OR ISNULL(SUM(S.Cantidad), 0.00) = 0.00
ORDER BY C.CodigoProducto;

-- ----------------------------------------------------------------------------
-- 2. Consulta: Estanterías Vacías
-- Descripción: Identifica los códigos de estantería que carecen por completo
--              de existencias en todas sus ubicaciones.
-- ----------------------------------------------------------------------------
PRINT '';
PRINT '--- 2. Estanterías vacías (sin stock) ---';

SELECT 
    E.CodigoEstanteria,
    COUNT(DISTINCT E.EstanteriaId) AS TotalHuecosDisponibles,
    COUNT(S.StockId) AS TotalLotesStock,
    ISNULL(SUM(S.Cantidad), 0.00) AS TotalUnidades
FROM dbo.Estanteria E
LEFT JOIN dbo.Stock S ON E.EstanteriaId = S.EstanteriaId
GROUP BY E.CodigoEstanteria
HAVING COUNT(S.StockId) = 0
ORDER BY E.CodigoEstanteria;

-- ----------------------------------------------------------------------------
-- 3. Consulta: Estantería Más Llena y Menos Llena de Productos
-- Descripción: Obtiene en un único conjunto de resultados la estantería con mayor
--              volumen de existencias y la de menor volumen (por unidades totales).
-- ----------------------------------------------------------------------------
PRINT '';
PRINT '--- 3. Estantería más llena y menos llena ---';

SELECT * FROM (
    SELECT TOP 1 
        'MÁS LLENA' AS Categoria,
        E.CodigoEstanteria,
        COUNT(DISTINCT E.EstanteriaId) AS TotalHuecos,
        COUNT(S.StockId) AS TotalLotes,
        ISNULL(SUM(S.Cantidad), 0.00) AS TotalUnidades
    FROM dbo.Estanteria E
    LEFT JOIN dbo.Stock S ON E.EstanteriaId = S.EstanteriaId
    GROUP BY E.CodigoEstanteria
    ORDER BY TotalUnidades DESC, E.CodigoEstanteria ASC
) AS MasLlena

UNION ALL

SELECT * FROM (
    SELECT TOP 1 
        'MENOS LLENA' AS Categoria,
        E.CodigoEstanteria,
        COUNT(DISTINCT E.EstanteriaId) AS TotalHuecos,
        COUNT(S.StockId) AS TotalLotes,
        ISNULL(SUM(S.Cantidad), 0.00) AS TotalUnidades
    FROM dbo.Estanteria E
    LEFT JOIN dbo.Stock S ON E.EstanteriaId = S.EstanteriaId
    GROUP BY E.CodigoEstanteria
    ORDER BY TotalUnidades ASC, E.CodigoEstanteria ASC
) AS MenosLlena;

-- ----------------------------------------------------------------------------
-- 4. Consulta: Los 2 Productos que Antes Caduquen
-- Descripción: Identifica los 2 productos con menor fecha de caducidad informada,
--              ordenados cronológicamente por proximidad de vencimiento.
-- ----------------------------------------------------------------------------
PRINT '';
PRINT '--- 4. Los 2 productos con fecha de caducidad más cercana ---';

SELECT TOP 2 
    CodigoProducto, 
    MIN(Caducidad) AS ProximaCaducidad,
    COUNT(StockId) AS LotesConCaducidad,
    SUM(Cantidad) AS UnidadesEnRiesgo
FROM dbo.Stock
WHERE Caducidad IS NOT NULL
GROUP BY CodigoProducto
ORDER BY ProximaCaducidad ASC;
