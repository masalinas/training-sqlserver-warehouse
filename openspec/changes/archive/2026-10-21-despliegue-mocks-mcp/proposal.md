# Proposal

## Why

Una vez creado el script `mocks.sql` y actualizada la restricción de integridad `UQ_Estanteria_Ubicacion` en `model.sql`, se requiere formalizar como capacidad del sistema el aprovisionamiento automatizado y la verificación remota de los datos mock en Microsoft SQL Server utilizando el servidor MCP `mssql`. Esto garantiza que los entornos de prueba puedan poblarse e inspeccionarse de manera programática mediante herramientas basadas en agentes y MCP.

## What Changes

- Verificación y garantía de la restricción de unicidad compuesta `UQ_Estanteria_Ubicacion` en la tabla `dbo.Estanteria` en SQL Server mediante el MCP `mssql`.
- Ejecución idempotente del script `mocks.sql` utilizando la herramienta `execute_sql` del servidor MCP `mssql`.
- Validación automatizada de las reglas de negocio resultantes en la base de datos (36 ubicaciones en `Estanteria`, stock asignado exclusivamente en `E01` y `E02`, y 0 registros de stock en `E03`).

## Capabilities

### Modified Capabilities
- `mcp-schema-deployment`: Añade el requisito de aprovisionamiento y validación de datos de prueba (`mocks.sql`) a través del servidor MCP `mssql`.

## Impact

- **Base de Datos (SQL Server)**: Tabla `dbo.Estanteria` y `dbo.Stock` aprovisionadas con datos mock certificados a través de MCP.
- **Servidor MCP (`mssql`)**: Operaciones de inserción y consulta analítica ejecutadas y validadas mediante `execute_sql`.
