# Tasks

## 1. Verificación de Esquema e Integridad

- [x] 1.1 Consultar las restricciones de `dbo.Estanteria` en SQL Server mediante `execute_sql` del servidor MCP `mssql` y verificar que la restricción `UQ_Estanteria_Ubicacion` sobre las columnas `(CodigoEstanteria, x, y)` esté activa en el catálogo del sistema.

## 2. Ejecución y Carga de Mocks

- [x] 2.1 Ejecutar las sentencias de `mocks.sql` en SQL Server utilizando la herramienta `execute_sql` del MCP `mssql`, asegurando la limpieza previa de `Stock` y `Estanteria` y el reinicio de contadores autonuméricos (`IDENTITY`).
- [x] 2.2 Confirmar la inserción de las 36 ubicaciones en `dbo.Estanteria` y los registros de stock aleatorio en `dbo.Stock` mediante la respuesta devuelta por la ejecución en el MCP.

## 3. Validación y Telemetría

- [x] 3.1 Consultar mediante `execute_sql` el resumen agrupado por `CodigoEstanteria` y certificar que `E01` y `E02` concentren todos los registros de stock, que `E03` permanezca con 0 registros y que coexistan stocks con fecha futura y valores `NULL`.
