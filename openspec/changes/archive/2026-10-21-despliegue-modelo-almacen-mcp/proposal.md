# Proposal: Despliegue del Modelo de Almacén mediante MCP mssql

## Why

El esquema relacional de almacén y stock definido en `model.sql` requiere ser aprovisionado y validado de manera confiable en una instancia de Microsoft SQL Server utilizando el servidor MCP `mssql`. Debido a que los controladores de base de datos DB-API/TDS no admiten nativamente separadores de lote cliente como `GO`, es necesario formalizar un procedimiento estructurado de ejecución por lotes secuenciales y la posterior verificación de restricciones con `test_restricciones.sql`.

## What Changes

- Despliegue idempotente del esquema de datos en SQL Server (`dbo.Estanteria` y `dbo.Stock`) mediante llamadas secuenciales a la herramienta `execute_sql` del servidor MCP `mssql`.
- Manejo y segmentación de sentencias T-SQL delimitadas por `GO` para su envío individual por el canal MCP.
- Ejecución de la suite automatizada de pruebas de integridad (`test_restricciones.sql`) para certificar el cumplimiento de restricciones `CHECK`, `UNIQUE` y `FOREIGN KEY`.
- Verificación de la exposición de los nuevos recursos de datos (`mssql://Estanteria/data` y `mssql://Stock/data`) a través de la API del MCP.

## Capabilities

### New Capabilities
- `mcp-schema-deployment`: Capacidad de despliegue y validación automatizada de esquemas DDL y pruebas de integridad referencial en SQL Server a través del MCP `mssql`.

### Modified Capabilities
<!-- None -->

## Impact

- **Base de datos**: Creación de las tablas de usuario `dbo.Estanteria` y `dbo.Stock` junto con sus restricciones asociadas en la base de datos `training`.
- **Servidor MCP**: Actualización del catálogo de recursos expuestos por `mssql_mcp_server`.
- **Dependencias**: Configuración validada en `.agents/mcp_config.json` y compatibilidad garantizada con `mcp<2`.
