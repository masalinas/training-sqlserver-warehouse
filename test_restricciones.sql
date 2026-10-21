-- ============================================================================
-- Script: test_restricciones.sql
-- Descripción: Casos de prueba para verificar restricciones de dominio en T-SQL
-- ============================================================================

SET NOCOUNT ON;

PRINT '================================================================';
PRINT 'Iniciando pruebas del modelo de Almacén y Stock';
PRINT '================================================================';

DECLARE @EstanteriaId1 INT;
DECLARE @EstanteriaId2 INT;
DECLARE @TotalPruebas INT = 0;
DECLARE @PruebasExitosas INT = 0;

-- ----------------------------------------------------------------------------
-- 1. PRUEBAS POSITIVAS (Inserciones válidas esperadas)
-- ----------------------------------------------------------------------------
PRINT '';
PRINT '--- 1. Pruebas Positivas ---';

SET @TotalPruebas = @TotalPruebas + 1;
BEGIN TRY
    INSERT INTO dbo.Estanteria (CodigoEstanteria, x, y)
    VALUES ('E01', 0, 0);
    SET @EstanteriaId1 = SCOPE_IDENTITY();
    
    INSERT INTO dbo.Estanteria (CodigoEstanteria, x, y)
    VALUES ('E02', 15, 3);
    SET @EstanteriaId2 = SCOPE_IDENTITY();

    PRINT '  [OK] Prueba 1: Inserción de estanterías válidas (E01, E02).';
    SET @PruebasExitosas = @PruebasExitosas + 1;
END TRY
BEGIN CATCH
    PRINT '  [FALLO] Prueba 1: Error al insertar estanterías válidas: ' + ERROR_MESSAGE();
END CATCH;

SET @TotalPruebas = @TotalPruebas + 1;
BEGIN TRY
    -- Stock con fecha de caducidad
    INSERT INTO dbo.Stock (EstanteriaId, CodigoProducto, Cantidad, Caducidad)
    VALUES (@EstanteriaId1, 'P01', 15.50, '2026-12-31');

    -- Stock sin fecha de caducidad (NULL)
    INSERT INTO dbo.Stock (EstanteriaId, CodigoProducto, Cantidad, Caducidad)
    VALUES (@EstanteriaId1, 'P02', 1.00, NULL);

    PRINT '  [OK] Prueba 2: Inserción de stock válido con y sin fecha de caducidad.';
    SET @PruebasExitosas = @PruebasExitosas + 1;
END TRY
BEGIN CATCH
    PRINT '  [FALLO] Prueba 2: Error al insertar stock válido: ' + ERROR_MESSAGE();
END CATCH;

-- ----------------------------------------------------------------------------
-- 2. PRUEBAS NEGATIVAS (Deben fallar por restricciones)
-- ----------------------------------------------------------------------------
PRINT '';
PRINT '--- 2. Pruebas Negativas (Validación de Restricciones) ---';

-- Test 3: Rechazo de formato CodigoEstanteria ('A01')
SET @TotalPruebas = @TotalPruebas + 1;
BEGIN TRY
    INSERT INTO dbo.Estanteria (CodigoEstanteria, x, y) VALUES ('A01', 1, 1);
    PRINT '  [FALLO] Prueba 3: Se permitió formato inválido en CodigoEstanteria.';
END TRY
BEGIN CATCH
    PRINT '  [OK] Prueba 3: Rechazado formato inválido en CodigoEstanteria (esperado CHECK).';
    SET @PruebasExitosas = @PruebasExitosas + 1;
END CATCH;

-- Test 4: Rechazo por duplicidad de CodigoEstanteria
SET @TotalPruebas = @TotalPruebas + 1;
BEGIN TRY
    INSERT INTO dbo.Estanteria (CodigoEstanteria, x, y) VALUES ('E01', 5, 2);
    PRINT '  [FALLO] Prueba 4: Se permitió duplicar CodigoEstanteria existente.';
END TRY
BEGIN CATCH
    PRINT '  [OK] Prueba 4: Rechazada duplicidad en CodigoEstanteria (esperado UNIQUE).';
    SET @PruebasExitosas = @PruebasExitosas + 1;
END CATCH;

-- Test 5: Rechazo por coordenada x negativa
SET @TotalPruebas = @TotalPruebas + 1;
BEGIN TRY
    INSERT INTO dbo.Estanteria (CodigoEstanteria, x, y) VALUES ('E03', -1, 0);
    PRINT '  [FALLO] Prueba 5: Se permitió coordenada x negativa.';
END TRY
BEGIN CATCH
    PRINT '  [OK] Prueba 5: Rechazada coordenada x negativa (esperado CHECK).';
    SET @PruebasExitosas = @PruebasExitosas + 1;
END CATCH;

-- Test 6: Rechazo por coordenada y negativa
SET @TotalPruebas = @TotalPruebas + 1;
BEGIN TRY
    INSERT INTO dbo.Estanteria (CodigoEstanteria, x, y) VALUES ('E04', 0, -5);
    PRINT '  [FALLO] Prueba 6: Se permitió coordenada y negativa.';
END TRY
BEGIN CATCH
    PRINT '  [OK] Prueba 6: Rechazada coordenada y negativa (esperado CHECK).';
    SET @PruebasExitosas = @PruebasExitosas + 1;
END CATCH;

-- Test 7: Rechazo por clave foránea inexistente en Stock
SET @TotalPruebas = @TotalPruebas + 1;
BEGIN TRY
    INSERT INTO dbo.Stock (EstanteriaId, CodigoProducto, Cantidad, Caducidad)
    VALUES (99999, 'P01', 10.00, NULL);
    PRINT '  [FALLO] Prueba 7: Se permitió insertar Stock con EstanteriaId inexistente.';
END TRY
BEGIN CATCH
    PRINT '  [OK] Prueba 7: Rechazada referencia foránea inexistente (esperado FK).';
    SET @PruebasExitosas = @PruebasExitosas + 1;
END CATCH;

-- Test 8: Rechazo por formato de CodigoProducto ('X01')
SET @TotalPruebas = @TotalPruebas + 1;
BEGIN TRY
    INSERT INTO dbo.Stock (EstanteriaId, CodigoProducto, Cantidad, Caducidad)
    VALUES (@EstanteriaId1, 'X01', 5.00, NULL);
    PRINT '  [FALLO] Prueba 8: Se permitió formato inválido en CodigoProducto.';
END TRY
BEGIN CATCH
    PRINT '  [OK] Prueba 8: Rechazado formato inválido en CodigoProducto (esperado CHECK).';
    SET @PruebasExitosas = @PruebasExitosas + 1;
END CATCH;

-- Test 9: Rechazo por Cantidad = 0.00 (debe ser estrictamente > 0)
SET @TotalPruebas = @TotalPruebas + 1;
BEGIN TRY
    INSERT INTO dbo.Stock (EstanteriaId, CodigoProducto, Cantidad, Caducidad)
    VALUES (@EstanteriaId1, 'P03', 0.00, NULL);
    PRINT '  [FALLO] Prueba 9: Se permitió Cantidad igual a 0.00.';
END TRY
BEGIN CATCH
    PRINT '  [OK] Prueba 9: Rechazada Cantidad = 0.00 (esperado CHECK > 0).';
    SET @PruebasExitosas = @PruebasExitosas + 1;
END CATCH;

-- Test 10: Rechazo por Cantidad negativa
SET @TotalPruebas = @TotalPruebas + 1;
BEGIN TRY
    INSERT INTO dbo.Stock (EstanteriaId, CodigoProducto, Cantidad, Caducidad)
    VALUES (@EstanteriaId1, 'P04', -2.50, NULL);
    PRINT '  [FALLO] Prueba 10: Se permitió Cantidad negativa.';
END TRY
BEGIN CATCH
    PRINT '  [OK] Prueba 10: Rechazada Cantidad negativa (esperado CHECK > 0).';
    SET @PruebasExitosas = @PruebasExitosas + 1;
END CATCH;

PRINT '';
PRINT '================================================================';
PRINT 'Resumen de ejecución: ' + CAST(@PruebasExitosas AS VARCHAR(5)) + ' de ' + CAST(@TotalPruebas AS VARCHAR(5)) + ' pruebas completadas exitosamente.';
PRINT '================================================================';
