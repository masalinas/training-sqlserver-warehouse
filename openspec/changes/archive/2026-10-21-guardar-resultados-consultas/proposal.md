# Proposal

## Why

Para facilitar la verificación funcional, auditoría y revisión técnica de los datos del almacén sin necesidad de ejecutar manualmente el motor de base de datos en cada inspección, es necesario documentar formalmente la ejecución de `queries.sql` mediante el servidor MCP `mssql` y volcar cada consulta junto a su conjunto de resultados en un archivo estructurado y legible denominado `results.md`.

## What Changes

- Ejecución de las 4 consultas analíticas de `queries.sql` utilizando el MCP `mssql` (`execute_sql`).
- Creación del archivo `results.md` en la raíz del proyecto, conteniendo para cada consulta:
  - Título y objetivo descriptivo de la consulta.
  - Código SQL exacto ejecutado.
  - Tabla de resultados formateada en Markdown con columnas y datos reales obtenidos de SQL Server.

## Capabilities

### New Capabilities
<!-- Ninguna nueva capacidad independiente -->

### Modified Capabilities
- `warehouse`: Incorporación de la especificación de documentación y persistencia de resultados analíticos en `results.md`.

## Impact

- **Código y Documentación**: Creación del archivo `results.md`.
- **Integraciones**: Servidor MCP `mssql` mediante la herramienta `execute_sql`.
- **Dependencias**: Depende de la presencia previa de `queries.sql` y de los datos cargados mediante `mocks.sql`.
